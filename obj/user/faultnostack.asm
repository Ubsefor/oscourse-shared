
obj/user/faultnostack:     file format elf64-x86-64


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
  800023:	e8 2e 00 00 00       	callq  800056 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
#include <inc/lib.h>

void _pgfault_upcall();

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  sys_env_set_pgfault_upcall(0, (void *)_pgfault_upcall);
  80002e:	48 be 6e 04 80 00 00 	movabs $0x80046e,%rsi
  800035:	00 00 00 
  800038:	bf 00 00 00 00       	mov    $0x0,%edi
  80003d:	48 b8 8b 03 80 00 00 	movabs $0x80038b,%rax
  800044:	00 00 00 
  800047:	ff d0                	callq  *%rax
  *(volatile int *)0 = 0;
  800049:	c7 04 25 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 00 
}
  800054:	5d                   	pop    %rbp
  800055:	c3                   	retq   

0000000000800056 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800056:	55                   	push   %rbp
  800057:	48 89 e5             	mov    %rsp,%rbp
  80005a:	41 56                	push   %r14
  80005c:	41 55                	push   %r13
  80005e:	41 54                	push   %r12
  800060:	53                   	push   %rbx
  800061:	41 89 fd             	mov    %edi,%r13d
  800064:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800067:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80006e:	00 00 00 
  800071:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800078:	00 00 00 
  80007b:	48 39 c2             	cmp    %rax,%rdx
  80007e:	73 23                	jae    8000a3 <libmain+0x4d>
  800080:	48 89 d3             	mov    %rdx,%rbx
  800083:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800087:	48 29 d0             	sub    %rdx,%rax
  80008a:	48 c1 e8 03          	shr    $0x3,%rax
  80008e:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800093:	b8 00 00 00 00       	mov    $0x0,%eax
  800098:	ff 13                	callq  *(%rbx)
    ctor++;
  80009a:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80009e:	4c 39 e3             	cmp    %r12,%rbx
  8000a1:	75 f0                	jne    800093 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  8000a3:	48 b8 c1 01 80 00 00 	movabs $0x8001c1,%rax
  8000aa:	00 00 00 
  8000ad:	ff d0                	callq  *%rax
  8000af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b4:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000b8:	48 c1 e0 05          	shl    $0x5,%rax
  8000bc:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000c3:	00 00 00 
  8000c6:	48 01 d0             	add    %rdx,%rax
  8000c9:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000d0:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000d3:	45 85 ed             	test   %r13d,%r13d
  8000d6:	7e 0d                	jle    8000e5 <libmain+0x8f>
    binaryname = argv[0];
  8000d8:	49 8b 06             	mov    (%r14),%rax
  8000db:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000e2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000e5:	4c 89 f6             	mov    %r14,%rsi
  8000e8:	44 89 ef             	mov    %r13d,%edi
  8000eb:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000f2:	00 00 00 
  8000f5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f7:	48 b8 0c 01 80 00 00 	movabs $0x80010c,%rax
  8000fe:	00 00 00 
  800101:	ff d0                	callq  *%rax
#endif
}
  800103:	5b                   	pop    %rbx
  800104:	41 5c                	pop    %r12
  800106:	41 5d                	pop    %r13
  800108:	41 5e                	pop    %r14
  80010a:	5d                   	pop    %rbp
  80010b:	c3                   	retq   

000000000080010c <exit>:

#include <inc/lib.h>

void
exit(void) {
  80010c:	55                   	push   %rbp
  80010d:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800110:	bf 00 00 00 00       	mov    $0x0,%edi
  800115:	48 b8 61 01 80 00 00 	movabs $0x800161,%rax
  80011c:	00 00 00 
  80011f:	ff d0                	callq  *%rax
}
  800121:	5d                   	pop    %rbp
  800122:	c3                   	retq   

0000000000800123 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800123:	55                   	push   %rbp
  800124:	48 89 e5             	mov    %rsp,%rbp
  800127:	53                   	push   %rbx
  800128:	48 89 fa             	mov    %rdi,%rdx
  80012b:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  80012e:	b8 00 00 00 00       	mov    $0x0,%eax
  800133:	48 89 c3             	mov    %rax,%rbx
  800136:	48 89 c7             	mov    %rax,%rdi
  800139:	48 89 c6             	mov    %rax,%rsi
  80013c:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80013e:	5b                   	pop    %rbx
  80013f:	5d                   	pop    %rbp
  800140:	c3                   	retq   

0000000000800141 <sys_cgetc>:

int
sys_cgetc(void) {
  800141:	55                   	push   %rbp
  800142:	48 89 e5             	mov    %rsp,%rbp
  800145:	53                   	push   %rbx
  asm volatile("int %1\n"
  800146:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014b:	b8 01 00 00 00       	mov    $0x1,%eax
  800150:	48 89 ca             	mov    %rcx,%rdx
  800153:	48 89 cb             	mov    %rcx,%rbx
  800156:	48 89 cf             	mov    %rcx,%rdi
  800159:	48 89 ce             	mov    %rcx,%rsi
  80015c:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %rbx
  80015f:	5d                   	pop    %rbp
  800160:	c3                   	retq   

0000000000800161 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800161:	55                   	push   %rbp
  800162:	48 89 e5             	mov    %rsp,%rbp
  800165:	53                   	push   %rbx
  800166:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80016a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80016d:	be 00 00 00 00       	mov    $0x0,%esi
  800172:	b8 03 00 00 00       	mov    $0x3,%eax
  800177:	48 89 f1             	mov    %rsi,%rcx
  80017a:	48 89 f3             	mov    %rsi,%rbx
  80017d:	48 89 f7             	mov    %rsi,%rdi
  800180:	cd 30                	int    $0x30
  if (check && ret > 0)
  800182:	48 85 c0             	test   %rax,%rax
  800185:	7f 07                	jg     80018e <sys_env_destroy+0x2d>
}
  800187:	48 83 c4 08          	add    $0x8,%rsp
  80018b:	5b                   	pop    %rbx
  80018c:	5d                   	pop    %rbp
  80018d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80018e:	49 89 c0             	mov    %rax,%r8
  800191:	b9 03 00 00 00       	mov    $0x3,%ecx
  800196:	48 ba 10 15 80 00 00 	movabs $0x801510,%rdx
  80019d:	00 00 00 
  8001a0:	be 22 00 00 00       	mov    $0x22,%esi
  8001a5:	48 bf 2f 15 80 00 00 	movabs $0x80152f,%rdi
  8001ac:	00 00 00 
  8001af:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b4:	49 b9 b9 04 80 00 00 	movabs $0x8004b9,%r9
  8001bb:	00 00 00 
  8001be:	41 ff d1             	callq  *%r9

00000000008001c1 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001c1:	55                   	push   %rbp
  8001c2:	48 89 e5             	mov    %rsp,%rbp
  8001c5:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001cb:	b8 02 00 00 00       	mov    $0x2,%eax
  8001d0:	48 89 ca             	mov    %rcx,%rdx
  8001d3:	48 89 cb             	mov    %rcx,%rbx
  8001d6:	48 89 cf             	mov    %rcx,%rdi
  8001d9:	48 89 ce             	mov    %rcx,%rsi
  8001dc:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001de:	5b                   	pop    %rbx
  8001df:	5d                   	pop    %rbp
  8001e0:	c3                   	retq   

00000000008001e1 <sys_yield>:

void
sys_yield(void) {
  8001e1:	55                   	push   %rbp
  8001e2:	48 89 e5             	mov    %rsp,%rbp
  8001e5:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001f0:	48 89 ca             	mov    %rcx,%rdx
  8001f3:	48 89 cb             	mov    %rcx,%rbx
  8001f6:	48 89 cf             	mov    %rcx,%rdi
  8001f9:	48 89 ce             	mov    %rcx,%rsi
  8001fc:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001fe:	5b                   	pop    %rbx
  8001ff:	5d                   	pop    %rbp
  800200:	c3                   	retq   

0000000000800201 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  800201:	55                   	push   %rbp
  800202:	48 89 e5             	mov    %rsp,%rbp
  800205:	53                   	push   %rbx
  800206:	48 83 ec 08          	sub    $0x8,%rsp
  80020a:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  80020d:	4c 63 c7             	movslq %edi,%r8
  800210:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  800213:	be 00 00 00 00       	mov    $0x0,%esi
  800218:	b8 04 00 00 00       	mov    $0x4,%eax
  80021d:	4c 89 c2             	mov    %r8,%rdx
  800220:	48 89 f7             	mov    %rsi,%rdi
  800223:	cd 30                	int    $0x30
  if (check && ret > 0)
  800225:	48 85 c0             	test   %rax,%rax
  800228:	7f 07                	jg     800231 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80022a:	48 83 c4 08          	add    $0x8,%rsp
  80022e:	5b                   	pop    %rbx
  80022f:	5d                   	pop    %rbp
  800230:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800231:	49 89 c0             	mov    %rax,%r8
  800234:	b9 04 00 00 00       	mov    $0x4,%ecx
  800239:	48 ba 10 15 80 00 00 	movabs $0x801510,%rdx
  800240:	00 00 00 
  800243:	be 22 00 00 00       	mov    $0x22,%esi
  800248:	48 bf 2f 15 80 00 00 	movabs $0x80152f,%rdi
  80024f:	00 00 00 
  800252:	b8 00 00 00 00       	mov    $0x0,%eax
  800257:	49 b9 b9 04 80 00 00 	movabs $0x8004b9,%r9
  80025e:	00 00 00 
  800261:	41 ff d1             	callq  *%r9

0000000000800264 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  800264:	55                   	push   %rbp
  800265:	48 89 e5             	mov    %rsp,%rbp
  800268:	53                   	push   %rbx
  800269:	48 83 ec 08          	sub    $0x8,%rsp
  80026d:	41 89 f9             	mov    %edi,%r9d
  800270:	49 89 f2             	mov    %rsi,%r10
  800273:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  800276:	4d 63 c9             	movslq %r9d,%r9
  800279:	48 63 da             	movslq %edx,%rbx
  80027c:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80027f:	b8 05 00 00 00       	mov    $0x5,%eax
  800284:	4c 89 ca             	mov    %r9,%rdx
  800287:	4c 89 d1             	mov    %r10,%rcx
  80028a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80028c:	48 85 c0             	test   %rax,%rax
  80028f:	7f 07                	jg     800298 <sys_page_map+0x34>
}
  800291:	48 83 c4 08          	add    $0x8,%rsp
  800295:	5b                   	pop    %rbx
  800296:	5d                   	pop    %rbp
  800297:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800298:	49 89 c0             	mov    %rax,%r8
  80029b:	b9 05 00 00 00       	mov    $0x5,%ecx
  8002a0:	48 ba 10 15 80 00 00 	movabs $0x801510,%rdx
  8002a7:	00 00 00 
  8002aa:	be 22 00 00 00       	mov    $0x22,%esi
  8002af:	48 bf 2f 15 80 00 00 	movabs $0x80152f,%rdi
  8002b6:	00 00 00 
  8002b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002be:	49 b9 b9 04 80 00 00 	movabs $0x8004b9,%r9
  8002c5:	00 00 00 
  8002c8:	41 ff d1             	callq  *%r9

00000000008002cb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002cb:	55                   	push   %rbp
  8002cc:	48 89 e5             	mov    %rsp,%rbp
  8002cf:	53                   	push   %rbx
  8002d0:	48 83 ec 08          	sub    $0x8,%rsp
  8002d4:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002d7:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002da:	be 00 00 00 00       	mov    $0x0,%esi
  8002df:	b8 06 00 00 00       	mov    $0x6,%eax
  8002e4:	48 89 f3             	mov    %rsi,%rbx
  8002e7:	48 89 f7             	mov    %rsi,%rdi
  8002ea:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002ec:	48 85 c0             	test   %rax,%rax
  8002ef:	7f 07                	jg     8002f8 <sys_page_unmap+0x2d>
}
  8002f1:	48 83 c4 08          	add    $0x8,%rsp
  8002f5:	5b                   	pop    %rbx
  8002f6:	5d                   	pop    %rbp
  8002f7:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002f8:	49 89 c0             	mov    %rax,%r8
  8002fb:	b9 06 00 00 00       	mov    $0x6,%ecx
  800300:	48 ba 10 15 80 00 00 	movabs $0x801510,%rdx
  800307:	00 00 00 
  80030a:	be 22 00 00 00       	mov    $0x22,%esi
  80030f:	48 bf 2f 15 80 00 00 	movabs $0x80152f,%rdi
  800316:	00 00 00 
  800319:	b8 00 00 00 00       	mov    $0x0,%eax
  80031e:	49 b9 b9 04 80 00 00 	movabs $0x8004b9,%r9
  800325:	00 00 00 
  800328:	41 ff d1             	callq  *%r9

000000000080032b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  80032b:	55                   	push   %rbp
  80032c:	48 89 e5             	mov    %rsp,%rbp
  80032f:	53                   	push   %rbx
  800330:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800334:	48 63 d7             	movslq %edi,%rdx
  800337:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80033a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033f:	b8 08 00 00 00       	mov    $0x8,%eax
  800344:	48 89 df             	mov    %rbx,%rdi
  800347:	48 89 de             	mov    %rbx,%rsi
  80034a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80034c:	48 85 c0             	test   %rax,%rax
  80034f:	7f 07                	jg     800358 <sys_env_set_status+0x2d>
}
  800351:	48 83 c4 08          	add    $0x8,%rsp
  800355:	5b                   	pop    %rbx
  800356:	5d                   	pop    %rbp
  800357:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800358:	49 89 c0             	mov    %rax,%r8
  80035b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800360:	48 ba 10 15 80 00 00 	movabs $0x801510,%rdx
  800367:	00 00 00 
  80036a:	be 22 00 00 00       	mov    $0x22,%esi
  80036f:	48 bf 2f 15 80 00 00 	movabs $0x80152f,%rdi
  800376:	00 00 00 
  800379:	b8 00 00 00 00       	mov    $0x0,%eax
  80037e:	49 b9 b9 04 80 00 00 	movabs $0x8004b9,%r9
  800385:	00 00 00 
  800388:	41 ff d1             	callq  *%r9

000000000080038b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80038b:	55                   	push   %rbp
  80038c:	48 89 e5             	mov    %rsp,%rbp
  80038f:	53                   	push   %rbx
  800390:	48 83 ec 08          	sub    $0x8,%rsp
  800394:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  800397:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80039a:	be 00 00 00 00       	mov    $0x0,%esi
  80039f:	b8 09 00 00 00       	mov    $0x9,%eax
  8003a4:	48 89 f3             	mov    %rsi,%rbx
  8003a7:	48 89 f7             	mov    %rsi,%rdi
  8003aa:	cd 30                	int    $0x30
  if (check && ret > 0)
  8003ac:	48 85 c0             	test   %rax,%rax
  8003af:	7f 07                	jg     8003b8 <sys_env_set_pgfault_upcall+0x2d>
}
  8003b1:	48 83 c4 08          	add    $0x8,%rsp
  8003b5:	5b                   	pop    %rbx
  8003b6:	5d                   	pop    %rbp
  8003b7:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8003b8:	49 89 c0             	mov    %rax,%r8
  8003bb:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003c0:	48 ba 10 15 80 00 00 	movabs $0x801510,%rdx
  8003c7:	00 00 00 
  8003ca:	be 22 00 00 00       	mov    $0x22,%esi
  8003cf:	48 bf 2f 15 80 00 00 	movabs $0x80152f,%rdi
  8003d6:	00 00 00 
  8003d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003de:	49 b9 b9 04 80 00 00 	movabs $0x8004b9,%r9
  8003e5:	00 00 00 
  8003e8:	41 ff d1             	callq  *%r9

00000000008003eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003eb:	55                   	push   %rbp
  8003ec:	48 89 e5             	mov    %rsp,%rbp
  8003ef:	53                   	push   %rbx
  8003f0:	49 89 f0             	mov    %rsi,%r8
  8003f3:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003f6:	48 63 d7             	movslq %edi,%rdx
  8003f9:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003fc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800401:	be 00 00 00 00       	mov    $0x0,%esi
  800406:	4c 89 c1             	mov    %r8,%rcx
  800409:	cd 30                	int    $0x30
}
  80040b:	5b                   	pop    %rbx
  80040c:	5d                   	pop    %rbp
  80040d:	c3                   	retq   

000000000080040e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  80040e:	55                   	push   %rbp
  80040f:	48 89 e5             	mov    %rsp,%rbp
  800412:	53                   	push   %rbx
  800413:	48 83 ec 08          	sub    $0x8,%rsp
  800417:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  80041a:	be 00 00 00 00       	mov    $0x0,%esi
  80041f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800424:	48 89 f1             	mov    %rsi,%rcx
  800427:	48 89 f3             	mov    %rsi,%rbx
  80042a:	48 89 f7             	mov    %rsi,%rdi
  80042d:	cd 30                	int    $0x30
  if (check && ret > 0)
  80042f:	48 85 c0             	test   %rax,%rax
  800432:	7f 07                	jg     80043b <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  800434:	48 83 c4 08          	add    $0x8,%rsp
  800438:	5b                   	pop    %rbx
  800439:	5d                   	pop    %rbp
  80043a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80043b:	49 89 c0             	mov    %rax,%r8
  80043e:	b9 0c 00 00 00       	mov    $0xc,%ecx
  800443:	48 ba 10 15 80 00 00 	movabs $0x801510,%rdx
  80044a:	00 00 00 
  80044d:	be 22 00 00 00       	mov    $0x22,%esi
  800452:	48 bf 2f 15 80 00 00 	movabs $0x80152f,%rdi
  800459:	00 00 00 
  80045c:	b8 00 00 00 00       	mov    $0x0,%eax
  800461:	49 b9 b9 04 80 00 00 	movabs $0x8004b9,%r9
  800468:	00 00 00 
  80046b:	41 ff d1             	callq  *%r9

000000000080046e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  80046e:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  800471:	48 a1 10 20 80 00 00 	movabs 0x802010,%rax
  800478:	00 00 00 
	call *%rax
  80047b:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  80047d:	41 5f                	pop    %r15
	popq %r15
  80047f:	41 5f                	pop    %r15
	popq %r15
  800481:	41 5f                	pop    %r15
	popq %r14
  800483:	41 5e                	pop    %r14
	popq %r13
  800485:	41 5d                	pop    %r13
	popq %r12
  800487:	41 5c                	pop    %r12
	popq %r11
  800489:	41 5b                	pop    %r11
	popq %r10
  80048b:	41 5a                	pop    %r10
	popq %r9
  80048d:	41 59                	pop    %r9
	popq %r8
  80048f:	41 58                	pop    %r8
	popq %rsi
  800491:	5e                   	pop    %rsi
	popq %rdi
  800492:	5f                   	pop    %rdi
	popq %rbp
  800493:	5d                   	pop    %rbp
	popq %rdx
  800494:	5a                   	pop    %rdx
	popq %rcx
  800495:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  800496:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  80049b:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  8004a0:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  8004a4:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  8004a7:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  8004ac:	5b                   	pop    %rbx
	popq %rax
  8004ad:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  8004ae:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  8004b2:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  8004b3:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  8004b8:	c3                   	retq   

00000000008004b9 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8004b9:	55                   	push   %rbp
  8004ba:	48 89 e5             	mov    %rsp,%rbp
  8004bd:	41 56                	push   %r14
  8004bf:	41 55                	push   %r13
  8004c1:	41 54                	push   %r12
  8004c3:	53                   	push   %rbx
  8004c4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004cb:	49 89 fd             	mov    %rdi,%r13
  8004ce:	41 89 f6             	mov    %esi,%r14d
  8004d1:	49 89 d4             	mov    %rdx,%r12
  8004d4:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  8004db:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  8004e2:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  8004e9:	84 c0                	test   %al,%al
  8004eb:	74 26                	je     800513 <_panic+0x5a>
  8004ed:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8004f4:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8004fb:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8004ff:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800503:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800507:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80050b:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80050f:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800513:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80051a:	00 00 00 
  80051d:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800524:	00 00 00 
  800527:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80052b:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800532:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800539:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800540:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  800547:	00 00 00 
  80054a:	48 8b 18             	mov    (%rax),%rbx
  80054d:	48 b8 c1 01 80 00 00 	movabs $0x8001c1,%rax
  800554:	00 00 00 
  800557:	ff d0                	callq  *%rax
  800559:	45 89 f0             	mov    %r14d,%r8d
  80055c:	4c 89 e9             	mov    %r13,%rcx
  80055f:	48 89 da             	mov    %rbx,%rdx
  800562:	89 c6                	mov    %eax,%esi
  800564:	48 bf 40 15 80 00 00 	movabs $0x801540,%rdi
  80056b:	00 00 00 
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	48 bb 5b 06 80 00 00 	movabs $0x80065b,%rbx
  80057a:	00 00 00 
  80057d:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80057f:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800586:	4c 89 e7             	mov    %r12,%rdi
  800589:	48 b8 f3 05 80 00 00 	movabs $0x8005f3,%rax
  800590:	00 00 00 
  800593:	ff d0                	callq  *%rax
  cprintf("\n");
  800595:	48 bf 68 15 80 00 00 	movabs $0x801568,%rdi
  80059c:	00 00 00 
  80059f:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a4:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8005a6:	cc                   	int3   
  while (1)
  8005a7:	eb fd                	jmp    8005a6 <_panic+0xed>

00000000008005a9 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  8005a9:	55                   	push   %rbp
  8005aa:	48 89 e5             	mov    %rsp,%rbp
  8005ad:	53                   	push   %rbx
  8005ae:	48 83 ec 08          	sub    $0x8,%rsp
  8005b2:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  8005b5:	8b 06                	mov    (%rsi),%eax
  8005b7:	8d 50 01             	lea    0x1(%rax),%edx
  8005ba:	89 16                	mov    %edx,(%rsi)
  8005bc:	48 98                	cltq   
  8005be:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  8005c3:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  8005c9:	74 0b                	je     8005d6 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  8005cb:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  8005cf:	48 83 c4 08          	add    $0x8,%rsp
  8005d3:	5b                   	pop    %rbx
  8005d4:	5d                   	pop    %rbp
  8005d5:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  8005d6:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  8005da:	be ff 00 00 00       	mov    $0xff,%esi
  8005df:	48 b8 23 01 80 00 00 	movabs $0x800123,%rax
  8005e6:	00 00 00 
  8005e9:	ff d0                	callq  *%rax
    b->idx = 0;
  8005eb:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  8005f1:	eb d8                	jmp    8005cb <putch+0x22>

00000000008005f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8005f3:	55                   	push   %rbp
  8005f4:	48 89 e5             	mov    %rsp,%rbp
  8005f7:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8005fe:	48 89 fa             	mov    %rdi,%rdx
  800601:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800604:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80060b:	00 00 00 
  b.cnt = 0;
  80060e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800615:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800618:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  80061f:	48 bf a9 05 80 00 00 	movabs $0x8005a9,%rdi
  800626:	00 00 00 
  800629:	48 b8 19 08 80 00 00 	movabs $0x800819,%rax
  800630:	00 00 00 
  800633:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800635:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80063c:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800643:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800647:	48 b8 23 01 80 00 00 	movabs $0x800123,%rax
  80064e:	00 00 00 
  800651:	ff d0                	callq  *%rax

  return b.cnt;
}
  800653:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800659:	c9                   	leaveq 
  80065a:	c3                   	retq   

000000000080065b <cprintf>:

int
cprintf(const char *fmt, ...) {
  80065b:	55                   	push   %rbp
  80065c:	48 89 e5             	mov    %rsp,%rbp
  80065f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800666:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80066d:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800674:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80067b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800682:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800689:	84 c0                	test   %al,%al
  80068b:	74 20                	je     8006ad <cprintf+0x52>
  80068d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800691:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800695:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800699:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80069d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8006a1:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8006a5:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8006a9:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8006ad:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8006b4:	00 00 00 
  8006b7:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8006be:	00 00 00 
  8006c1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8006c5:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8006cc:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8006d3:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8006da:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8006e1:	48 b8 f3 05 80 00 00 	movabs $0x8005f3,%rax
  8006e8:	00 00 00 
  8006eb:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8006ed:	c9                   	leaveq 
  8006ee:	c3                   	retq   

00000000008006ef <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8006ef:	55                   	push   %rbp
  8006f0:	48 89 e5             	mov    %rsp,%rbp
  8006f3:	41 57                	push   %r15
  8006f5:	41 56                	push   %r14
  8006f7:	41 55                	push   %r13
  8006f9:	41 54                	push   %r12
  8006fb:	53                   	push   %rbx
  8006fc:	48 83 ec 18          	sub    $0x18,%rsp
  800700:	49 89 fc             	mov    %rdi,%r12
  800703:	49 89 f5             	mov    %rsi,%r13
  800706:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80070a:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80070d:	41 89 cf             	mov    %ecx,%r15d
  800710:	49 39 d7             	cmp    %rdx,%r15
  800713:	76 45                	jbe    80075a <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800715:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800719:	85 db                	test   %ebx,%ebx
  80071b:	7e 0e                	jle    80072b <printnum+0x3c>
      putch(padc, putdat);
  80071d:	4c 89 ee             	mov    %r13,%rsi
  800720:	44 89 f7             	mov    %r14d,%edi
  800723:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800726:	83 eb 01             	sub    $0x1,%ebx
  800729:	75 f2                	jne    80071d <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80072b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
  800734:	49 f7 f7             	div    %r15
  800737:	48 b8 6a 15 80 00 00 	movabs $0x80156a,%rax
  80073e:	00 00 00 
  800741:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800745:	4c 89 ee             	mov    %r13,%rsi
  800748:	41 ff d4             	callq  *%r12
}
  80074b:	48 83 c4 18          	add    $0x18,%rsp
  80074f:	5b                   	pop    %rbx
  800750:	41 5c                	pop    %r12
  800752:	41 5d                	pop    %r13
  800754:	41 5e                	pop    %r14
  800756:	41 5f                	pop    %r15
  800758:	5d                   	pop    %rbp
  800759:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80075a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80075e:	ba 00 00 00 00       	mov    $0x0,%edx
  800763:	49 f7 f7             	div    %r15
  800766:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80076a:	48 89 c2             	mov    %rax,%rdx
  80076d:	48 b8 ef 06 80 00 00 	movabs $0x8006ef,%rax
  800774:	00 00 00 
  800777:	ff d0                	callq  *%rax
  800779:	eb b0                	jmp    80072b <printnum+0x3c>

000000000080077b <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80077b:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80077f:	48 8b 06             	mov    (%rsi),%rax
  800782:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800786:	73 0a                	jae    800792 <sprintputch+0x17>
    *b->buf++ = ch;
  800788:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80078c:	48 89 16             	mov    %rdx,(%rsi)
  80078f:	40 88 38             	mov    %dil,(%rax)
}
  800792:	c3                   	retq   

0000000000800793 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800793:	55                   	push   %rbp
  800794:	48 89 e5             	mov    %rsp,%rbp
  800797:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80079e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8007a5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8007ac:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8007b3:	84 c0                	test   %al,%al
  8007b5:	74 20                	je     8007d7 <printfmt+0x44>
  8007b7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8007bb:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8007bf:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8007c3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8007c7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8007cb:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8007cf:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8007d3:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8007d7:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8007de:	00 00 00 
  8007e1:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8007e8:	00 00 00 
  8007eb:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8007ef:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8007f6:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8007fd:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800804:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80080b:	48 b8 19 08 80 00 00 	movabs $0x800819,%rax
  800812:	00 00 00 
  800815:	ff d0                	callq  *%rax
}
  800817:	c9                   	leaveq 
  800818:	c3                   	retq   

0000000000800819 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  800819:	55                   	push   %rbp
  80081a:	48 89 e5             	mov    %rsp,%rbp
  80081d:	41 57                	push   %r15
  80081f:	41 56                	push   %r14
  800821:	41 55                	push   %r13
  800823:	41 54                	push   %r12
  800825:	53                   	push   %rbx
  800826:	48 83 ec 48          	sub    $0x48,%rsp
  80082a:	49 89 fd             	mov    %rdi,%r13
  80082d:	49 89 f7             	mov    %rsi,%r15
  800830:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800833:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  800837:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80083b:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80083f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800843:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  800847:	41 0f b6 3e          	movzbl (%r14),%edi
  80084b:	83 ff 25             	cmp    $0x25,%edi
  80084e:	74 18                	je     800868 <vprintfmt+0x4f>
      if (ch == '\0')
  800850:	85 ff                	test   %edi,%edi
  800852:	0f 84 8c 06 00 00    	je     800ee4 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800858:	4c 89 fe             	mov    %r15,%rsi
  80085b:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80085e:	49 89 de             	mov    %rbx,%r14
  800861:	eb e0                	jmp    800843 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800863:	49 89 de             	mov    %rbx,%r14
  800866:	eb db                	jmp    800843 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800868:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80086c:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800870:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800877:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80087d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800886:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80088c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800892:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800897:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80089c:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8008a0:	0f b6 13             	movzbl (%rbx),%edx
  8008a3:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8008a6:	3c 55                	cmp    $0x55,%al
  8008a8:	0f 87 8b 05 00 00    	ja     800e39 <vprintfmt+0x620>
  8008ae:	0f b6 c0             	movzbl %al,%eax
  8008b1:	49 bb 40 16 80 00 00 	movabs $0x801640,%r11
  8008b8:	00 00 00 
  8008bb:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8008bf:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8008c2:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8008c6:	eb d4                	jmp    80089c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008c8:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8008cb:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8008cf:	eb cb                	jmp    80089c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008d1:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8008d4:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  8008d8:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8008dc:	8d 50 d0             	lea    -0x30(%rax),%edx
  8008df:	83 fa 09             	cmp    $0x9,%edx
  8008e2:	77 7e                	ja     800962 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8008e4:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8008e8:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8008ec:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8008f1:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8008f5:	8d 50 d0             	lea    -0x30(%rax),%edx
  8008f8:	83 fa 09             	cmp    $0x9,%edx
  8008fb:	76 e7                	jbe    8008e4 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8008fd:	4c 89 f3             	mov    %r14,%rbx
  800900:	eb 19                	jmp    80091b <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800902:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800905:	83 f8 2f             	cmp    $0x2f,%eax
  800908:	77 2a                	ja     800934 <vprintfmt+0x11b>
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	4c 01 d2             	add    %r10,%rdx
  80090f:	83 c0 08             	add    $0x8,%eax
  800912:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800915:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  800918:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80091b:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80091f:	0f 89 77 ff ff ff    	jns    80089c <vprintfmt+0x83>
          width = precision, precision = -1;
  800925:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800929:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80092f:	e9 68 ff ff ff       	jmpq   80089c <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800934:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800938:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80093c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800940:	eb d3                	jmp    800915 <vprintfmt+0xfc>
        if (width < 0)
  800942:	8b 45 ac             	mov    -0x54(%rbp),%eax
  800945:	85 c0                	test   %eax,%eax
  800947:	41 0f 48 c0          	cmovs  %r8d,%eax
  80094b:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80094e:	4c 89 f3             	mov    %r14,%rbx
  800951:	e9 46 ff ff ff       	jmpq   80089c <vprintfmt+0x83>
  800956:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800959:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80095d:	e9 3a ff ff ff       	jmpq   80089c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800962:	4c 89 f3             	mov    %r14,%rbx
  800965:	eb b4                	jmp    80091b <vprintfmt+0x102>
        lflag++;
  800967:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80096a:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80096d:	e9 2a ff ff ff       	jmpq   80089c <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800972:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800975:	83 f8 2f             	cmp    $0x2f,%eax
  800978:	77 19                	ja     800993 <vprintfmt+0x17a>
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800980:	83 c0 08             	add    $0x8,%eax
  800983:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800986:	4c 89 fe             	mov    %r15,%rsi
  800989:	8b 3a                	mov    (%rdx),%edi
  80098b:	41 ff d5             	callq  *%r13
        break;
  80098e:	e9 b0 fe ff ff       	jmpq   800843 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800993:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800997:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80099b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099f:	eb e5                	jmp    800986 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8009a1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009a4:	83 f8 2f             	cmp    $0x2f,%eax
  8009a7:	77 5b                	ja     800a04 <vprintfmt+0x1eb>
  8009a9:	89 c2                	mov    %eax,%edx
  8009ab:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009af:	83 c0 08             	add    $0x8,%eax
  8009b2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009b5:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8009b7:	89 c8                	mov    %ecx,%eax
  8009b9:	c1 f8 1f             	sar    $0x1f,%eax
  8009bc:	31 c1                	xor    %eax,%ecx
  8009be:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c0:	83 f9 0b             	cmp    $0xb,%ecx
  8009c3:	7f 4d                	jg     800a12 <vprintfmt+0x1f9>
  8009c5:	48 63 c1             	movslq %ecx,%rax
  8009c8:	48 ba 00 19 80 00 00 	movabs $0x801900,%rdx
  8009cf:	00 00 00 
  8009d2:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8009d6:	48 85 c0             	test   %rax,%rax
  8009d9:	74 37                	je     800a12 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8009db:	48 89 c1             	mov    %rax,%rcx
  8009de:	48 ba 8b 15 80 00 00 	movabs $0x80158b,%rdx
  8009e5:	00 00 00 
  8009e8:	4c 89 fe             	mov    %r15,%rsi
  8009eb:	4c 89 ef             	mov    %r13,%rdi
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	48 bb 93 07 80 00 00 	movabs $0x800793,%rbx
  8009fa:	00 00 00 
  8009fd:	ff d3                	callq  *%rbx
  8009ff:	e9 3f fe ff ff       	jmpq   800843 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800a04:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a08:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a0c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a10:	eb a3                	jmp    8009b5 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800a12:	48 ba 82 15 80 00 00 	movabs $0x801582,%rdx
  800a19:	00 00 00 
  800a1c:	4c 89 fe             	mov    %r15,%rsi
  800a1f:	4c 89 ef             	mov    %r13,%rdi
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	48 bb 93 07 80 00 00 	movabs $0x800793,%rbx
  800a2e:	00 00 00 
  800a31:	ff d3                	callq  *%rbx
  800a33:	e9 0b fe ff ff       	jmpq   800843 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  800a38:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800a3b:	83 f8 2f             	cmp    $0x2f,%eax
  800a3e:	77 4b                	ja     800a8b <vprintfmt+0x272>
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800a46:	83 c0 08             	add    $0x8,%eax
  800a49:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800a4c:	48 8b 02             	mov    (%rdx),%rax
  800a4f:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800a53:	48 85 c0             	test   %rax,%rax
  800a56:	0f 84 05 04 00 00    	je     800e61 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800a5c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a60:	7e 06                	jle    800a68 <vprintfmt+0x24f>
  800a62:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a66:	75 31                	jne    800a99 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a68:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a6c:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a70:	0f b6 00             	movzbl (%rax),%eax
  800a73:	0f be f8             	movsbl %al,%edi
  800a76:	85 ff                	test   %edi,%edi
  800a78:	0f 84 c3 00 00 00    	je     800b41 <vprintfmt+0x328>
  800a7e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a82:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a86:	e9 85 00 00 00       	jmpq   800b10 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a8b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a8f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a93:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a97:	eb b3                	jmp    800a4c <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a99:	49 63 f4             	movslq %r12d,%rsi
  800a9c:	48 89 c7             	mov    %rax,%rdi
  800a9f:	48 b8 f0 0f 80 00 00 	movabs $0x800ff0,%rax
  800aa6:	00 00 00 
  800aa9:	ff d0                	callq  *%rax
  800aab:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800aae:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800ab1:	85 f6                	test   %esi,%esi
  800ab3:	7e 22                	jle    800ad7 <vprintfmt+0x2be>
            putch(padc, putdat);
  800ab5:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800ab9:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800abd:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800ac1:	4c 89 fe             	mov    %r15,%rsi
  800ac4:	89 df                	mov    %ebx,%edi
  800ac6:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800ac9:	41 83 ec 01          	sub    $0x1,%r12d
  800acd:	75 f2                	jne    800ac1 <vprintfmt+0x2a8>
  800acf:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800ad3:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ad7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800adb:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800adf:	0f b6 00             	movzbl (%rax),%eax
  800ae2:	0f be f8             	movsbl %al,%edi
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	0f 84 56 fd ff ff    	je     800843 <vprintfmt+0x2a>
  800aed:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800af1:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800af5:	eb 19                	jmp    800b10 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800af7:	4c 89 fe             	mov    %r15,%rsi
  800afa:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800afd:	41 83 ee 01          	sub    $0x1,%r14d
  800b01:	48 83 c3 01          	add    $0x1,%rbx
  800b05:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800b09:	0f be f8             	movsbl %al,%edi
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	74 29                	je     800b39 <vprintfmt+0x320>
  800b10:	45 85 e4             	test   %r12d,%r12d
  800b13:	78 06                	js     800b1b <vprintfmt+0x302>
  800b15:	41 83 ec 01          	sub    $0x1,%r12d
  800b19:	78 48                	js     800b63 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800b1b:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800b1f:	74 d6                	je     800af7 <vprintfmt+0x2de>
  800b21:	0f be c0             	movsbl %al,%eax
  800b24:	83 e8 20             	sub    $0x20,%eax
  800b27:	83 f8 5e             	cmp    $0x5e,%eax
  800b2a:	76 cb                	jbe    800af7 <vprintfmt+0x2de>
            putch('?', putdat);
  800b2c:	4c 89 fe             	mov    %r15,%rsi
  800b2f:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800b34:	41 ff d5             	callq  *%r13
  800b37:	eb c4                	jmp    800afd <vprintfmt+0x2e4>
  800b39:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b3d:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800b41:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800b44:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800b48:	0f 8e f5 fc ff ff    	jle    800843 <vprintfmt+0x2a>
          putch(' ', putdat);
  800b4e:	4c 89 fe             	mov    %r15,%rsi
  800b51:	bf 20 00 00 00       	mov    $0x20,%edi
  800b56:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800b59:	83 eb 01             	sub    $0x1,%ebx
  800b5c:	75 f0                	jne    800b4e <vprintfmt+0x335>
  800b5e:	e9 e0 fc ff ff       	jmpq   800843 <vprintfmt+0x2a>
  800b63:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b67:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b6b:	eb d4                	jmp    800b41 <vprintfmt+0x328>
  if (lflag >= 2)
  800b6d:	83 f9 01             	cmp    $0x1,%ecx
  800b70:	7f 1d                	jg     800b8f <vprintfmt+0x376>
  else if (lflag)
  800b72:	85 c9                	test   %ecx,%ecx
  800b74:	74 5e                	je     800bd4 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b76:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b79:	83 f8 2f             	cmp    $0x2f,%eax
  800b7c:	77 48                	ja     800bc6 <vprintfmt+0x3ad>
  800b7e:	89 c2                	mov    %eax,%edx
  800b80:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b84:	83 c0 08             	add    $0x8,%eax
  800b87:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b8a:	48 8b 1a             	mov    (%rdx),%rbx
  800b8d:	eb 17                	jmp    800ba6 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b8f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b92:	83 f8 2f             	cmp    $0x2f,%eax
  800b95:	77 21                	ja     800bb8 <vprintfmt+0x39f>
  800b97:	89 c2                	mov    %eax,%edx
  800b99:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b9d:	83 c0 08             	add    $0x8,%eax
  800ba0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ba3:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800ba6:	48 85 db             	test   %rbx,%rbx
  800ba9:	78 50                	js     800bfb <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800bab:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800bae:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bb3:	e9 b4 01 00 00       	jmpq   800d6c <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800bb8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bbc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bc0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bc4:	eb dd                	jmp    800ba3 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800bc6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bca:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bce:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bd2:	eb b6                	jmp    800b8a <vprintfmt+0x371>
    return va_arg(*ap, int);
  800bd4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bd7:	83 f8 2f             	cmp    $0x2f,%eax
  800bda:	77 11                	ja     800bed <vprintfmt+0x3d4>
  800bdc:	89 c2                	mov    %eax,%edx
  800bde:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800be2:	83 c0 08             	add    $0x8,%eax
  800be5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800be8:	48 63 1a             	movslq (%rdx),%rbx
  800beb:	eb b9                	jmp    800ba6 <vprintfmt+0x38d>
  800bed:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bf1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bf5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bf9:	eb ed                	jmp    800be8 <vprintfmt+0x3cf>
          putch('-', putdat);
  800bfb:	4c 89 fe             	mov    %r15,%rsi
  800bfe:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800c03:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800c06:	48 89 da             	mov    %rbx,%rdx
  800c09:	48 f7 da             	neg    %rdx
        base = 10;
  800c0c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c11:	e9 56 01 00 00       	jmpq   800d6c <vprintfmt+0x553>
  if (lflag >= 2)
  800c16:	83 f9 01             	cmp    $0x1,%ecx
  800c19:	7f 25                	jg     800c40 <vprintfmt+0x427>
  else if (lflag)
  800c1b:	85 c9                	test   %ecx,%ecx
  800c1d:	74 5e                	je     800c7d <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800c1f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c22:	83 f8 2f             	cmp    $0x2f,%eax
  800c25:	77 48                	ja     800c6f <vprintfmt+0x456>
  800c27:	89 c2                	mov    %eax,%edx
  800c29:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c2d:	83 c0 08             	add    $0x8,%eax
  800c30:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c33:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800c36:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c3b:	e9 2c 01 00 00       	jmpq   800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c40:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c43:	83 f8 2f             	cmp    $0x2f,%eax
  800c46:	77 19                	ja     800c61 <vprintfmt+0x448>
  800c48:	89 c2                	mov    %eax,%edx
  800c4a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c4e:	83 c0 08             	add    $0x8,%eax
  800c51:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c54:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800c57:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c5c:	e9 0b 01 00 00       	jmpq   800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c61:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c65:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c69:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c6d:	eb e5                	jmp    800c54 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c6f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c73:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c77:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c7b:	eb b6                	jmp    800c33 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c7d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c80:	83 f8 2f             	cmp    $0x2f,%eax
  800c83:	77 18                	ja     800c9d <vprintfmt+0x484>
  800c85:	89 c2                	mov    %eax,%edx
  800c87:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c8b:	83 c0 08             	add    $0x8,%eax
  800c8e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c91:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c93:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c98:	e9 cf 00 00 00       	jmpq   800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c9d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ca1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ca5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ca9:	eb e6                	jmp    800c91 <vprintfmt+0x478>
  if (lflag >= 2)
  800cab:	83 f9 01             	cmp    $0x1,%ecx
  800cae:	7f 25                	jg     800cd5 <vprintfmt+0x4bc>
  else if (lflag)
  800cb0:	85 c9                	test   %ecx,%ecx
  800cb2:	74 5b                	je     800d0f <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800cb4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cb7:	83 f8 2f             	cmp    $0x2f,%eax
  800cba:	77 45                	ja     800d01 <vprintfmt+0x4e8>
  800cbc:	89 c2                	mov    %eax,%edx
  800cbe:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cc2:	83 c0 08             	add    $0x8,%eax
  800cc5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cc8:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800ccb:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cd0:	e9 97 00 00 00       	jmpq   800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800cd5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cd8:	83 f8 2f             	cmp    $0x2f,%eax
  800cdb:	77 16                	ja     800cf3 <vprintfmt+0x4da>
  800cdd:	89 c2                	mov    %eax,%edx
  800cdf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ce3:	83 c0 08             	add    $0x8,%eax
  800ce6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ce9:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800cec:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cf1:	eb 79                	jmp    800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800cf3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cf7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cfb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cff:	eb e8                	jmp    800ce9 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800d01:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d05:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d09:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d0d:	eb b9                	jmp    800cc8 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800d0f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d12:	83 f8 2f             	cmp    $0x2f,%eax
  800d15:	77 15                	ja     800d2c <vprintfmt+0x513>
  800d17:	89 c2                	mov    %eax,%edx
  800d19:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d1d:	83 c0 08             	add    $0x8,%eax
  800d20:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d23:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800d25:	b9 08 00 00 00       	mov    $0x8,%ecx
  800d2a:	eb 40                	jmp    800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800d2c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d30:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d34:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d38:	eb e9                	jmp    800d23 <vprintfmt+0x50a>
        putch('0', putdat);
  800d3a:	4c 89 fe             	mov    %r15,%rsi
  800d3d:	bf 30 00 00 00       	mov    $0x30,%edi
  800d42:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800d45:	4c 89 fe             	mov    %r15,%rsi
  800d48:	bf 78 00 00 00       	mov    $0x78,%edi
  800d4d:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d50:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d53:	83 f8 2f             	cmp    $0x2f,%eax
  800d56:	77 34                	ja     800d8c <vprintfmt+0x573>
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d5e:	83 c0 08             	add    $0x8,%eax
  800d61:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d64:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d67:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d6c:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d71:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d75:	4c 89 fe             	mov    %r15,%rsi
  800d78:	4c 89 ef             	mov    %r13,%rdi
  800d7b:	48 b8 ef 06 80 00 00 	movabs $0x8006ef,%rax
  800d82:	00 00 00 
  800d85:	ff d0                	callq  *%rax
        break;
  800d87:	e9 b7 fa ff ff       	jmpq   800843 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d8c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d90:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d94:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d98:	eb ca                	jmp    800d64 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d9a:	83 f9 01             	cmp    $0x1,%ecx
  800d9d:	7f 22                	jg     800dc1 <vprintfmt+0x5a8>
  else if (lflag)
  800d9f:	85 c9                	test   %ecx,%ecx
  800da1:	74 58                	je     800dfb <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800da3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800da6:	83 f8 2f             	cmp    $0x2f,%eax
  800da9:	77 42                	ja     800ded <vprintfmt+0x5d4>
  800dab:	89 c2                	mov    %eax,%edx
  800dad:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800db1:	83 c0 08             	add    $0x8,%eax
  800db4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800db7:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800dba:	b9 10 00 00 00       	mov    $0x10,%ecx
  800dbf:	eb ab                	jmp    800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800dc1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800dc4:	83 f8 2f             	cmp    $0x2f,%eax
  800dc7:	77 16                	ja     800ddf <vprintfmt+0x5c6>
  800dc9:	89 c2                	mov    %eax,%edx
  800dcb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800dcf:	83 c0 08             	add    $0x8,%eax
  800dd2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800dd5:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800dd8:	b9 10 00 00 00       	mov    $0x10,%ecx
  800ddd:	eb 8d                	jmp    800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ddf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800de3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800de7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800deb:	eb e8                	jmp    800dd5 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800ded:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800df1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800df5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800df9:	eb bc                	jmp    800db7 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800dfb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800dfe:	83 f8 2f             	cmp    $0x2f,%eax
  800e01:	77 18                	ja     800e1b <vprintfmt+0x602>
  800e03:	89 c2                	mov    %eax,%edx
  800e05:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800e09:	83 c0 08             	add    $0x8,%eax
  800e0c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800e0f:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800e11:	b9 10 00 00 00       	mov    $0x10,%ecx
  800e16:	e9 51 ff ff ff       	jmpq   800d6c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800e1b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800e1f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800e23:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800e27:	eb e6                	jmp    800e0f <vprintfmt+0x5f6>
        putch(ch, putdat);
  800e29:	4c 89 fe             	mov    %r15,%rsi
  800e2c:	bf 25 00 00 00       	mov    $0x25,%edi
  800e31:	41 ff d5             	callq  *%r13
        break;
  800e34:	e9 0a fa ff ff       	jmpq   800843 <vprintfmt+0x2a>
        putch('%', putdat);
  800e39:	4c 89 fe             	mov    %r15,%rsi
  800e3c:	bf 25 00 00 00       	mov    $0x25,%edi
  800e41:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800e44:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800e48:	0f 84 15 fa ff ff    	je     800863 <vprintfmt+0x4a>
  800e4e:	49 89 de             	mov    %rbx,%r14
  800e51:	49 83 ee 01          	sub    $0x1,%r14
  800e55:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800e5a:	75 f5                	jne    800e51 <vprintfmt+0x638>
  800e5c:	e9 e2 f9 ff ff       	jmpq   800843 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800e61:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800e65:	74 06                	je     800e6d <vprintfmt+0x654>
  800e67:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e6b:	7f 21                	jg     800e8e <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e6d:	bf 28 00 00 00       	mov    $0x28,%edi
  800e72:	48 bb 7c 15 80 00 00 	movabs $0x80157c,%rbx
  800e79:	00 00 00 
  800e7c:	b8 28 00 00 00       	mov    $0x28,%eax
  800e81:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e85:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e89:	e9 82 fc ff ff       	jmpq   800b10 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e8e:	49 63 f4             	movslq %r12d,%rsi
  800e91:	48 bf 7b 15 80 00 00 	movabs $0x80157b,%rdi
  800e98:	00 00 00 
  800e9b:	48 b8 f0 0f 80 00 00 	movabs $0x800ff0,%rax
  800ea2:	00 00 00 
  800ea5:	ff d0                	callq  *%rax
  800ea7:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800eaa:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800ead:	48 be 7b 15 80 00 00 	movabs $0x80157b,%rsi
  800eb4:	00 00 00 
  800eb7:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	0f 8f f2 fb ff ff    	jg     800ab5 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ec3:	48 bb 7c 15 80 00 00 	movabs $0x80157c,%rbx
  800eca:	00 00 00 
  800ecd:	b8 28 00 00 00       	mov    $0x28,%eax
  800ed2:	bf 28 00 00 00       	mov    $0x28,%edi
  800ed7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800edb:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800edf:	e9 2c fc ff ff       	jmpq   800b10 <vprintfmt+0x2f7>
}
  800ee4:	48 83 c4 48          	add    $0x48,%rsp
  800ee8:	5b                   	pop    %rbx
  800ee9:	41 5c                	pop    %r12
  800eeb:	41 5d                	pop    %r13
  800eed:	41 5e                	pop    %r14
  800eef:	41 5f                	pop    %r15
  800ef1:	5d                   	pop    %rbp
  800ef2:	c3                   	retq   

0000000000800ef3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800ef3:	55                   	push   %rbp
  800ef4:	48 89 e5             	mov    %rsp,%rbp
  800ef7:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800efb:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800eff:	48 63 c6             	movslq %esi,%rax
  800f02:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800f07:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800f0b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800f12:	48 85 ff             	test   %rdi,%rdi
  800f15:	74 2a                	je     800f41 <vsnprintf+0x4e>
  800f17:	85 f6                	test   %esi,%esi
  800f19:	7e 26                	jle    800f41 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800f1b:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800f1f:	48 bf 7b 07 80 00 00 	movabs $0x80077b,%rdi
  800f26:	00 00 00 
  800f29:	48 b8 19 08 80 00 00 	movabs $0x800819,%rax
  800f30:	00 00 00 
  800f33:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800f35:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800f39:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800f3c:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800f3f:	c9                   	leaveq 
  800f40:	c3                   	retq   
    return -E_INVAL;
  800f41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f46:	eb f7                	jmp    800f3f <vsnprintf+0x4c>

0000000000800f48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800f48:	55                   	push   %rbp
  800f49:	48 89 e5             	mov    %rsp,%rbp
  800f4c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800f53:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800f5a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f61:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f68:	84 c0                	test   %al,%al
  800f6a:	74 20                	je     800f8c <snprintf+0x44>
  800f6c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f70:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f74:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f78:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f7c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f80:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f84:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f88:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f8c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f93:	00 00 00 
  800f96:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f9d:	00 00 00 
  800fa0:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800fa4:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800fab:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800fb2:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800fb9:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800fc0:	48 b8 f3 0e 80 00 00 	movabs $0x800ef3,%rax
  800fc7:	00 00 00 
  800fca:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800fcc:	c9                   	leaveq 
  800fcd:	c3                   	retq   

0000000000800fce <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800fce:	80 3f 00             	cmpb   $0x0,(%rdi)
  800fd1:	74 17                	je     800fea <strlen+0x1c>
  800fd3:	48 89 fa             	mov    %rdi,%rdx
  800fd6:	b9 01 00 00 00       	mov    $0x1,%ecx
  800fdb:	29 f9                	sub    %edi,%ecx
    n++;
  800fdd:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800fe0:	48 83 c2 01          	add    $0x1,%rdx
  800fe4:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fe7:	75 f4                	jne    800fdd <strlen+0xf>
  800fe9:	c3                   	retq   
  800fea:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fef:	c3                   	retq   

0000000000800ff0 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ff0:	48 85 f6             	test   %rsi,%rsi
  800ff3:	74 24                	je     801019 <strnlen+0x29>
  800ff5:	80 3f 00             	cmpb   $0x0,(%rdi)
  800ff8:	74 25                	je     80101f <strnlen+0x2f>
  800ffa:	48 01 fe             	add    %rdi,%rsi
  800ffd:	48 89 fa             	mov    %rdi,%rdx
  801000:	b9 01 00 00 00       	mov    $0x1,%ecx
  801005:	29 f9                	sub    %edi,%ecx
    n++;
  801007:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80100a:	48 83 c2 01          	add    $0x1,%rdx
  80100e:	48 39 f2             	cmp    %rsi,%rdx
  801011:	74 11                	je     801024 <strnlen+0x34>
  801013:	80 3a 00             	cmpb   $0x0,(%rdx)
  801016:	75 ef                	jne    801007 <strnlen+0x17>
  801018:	c3                   	retq   
  801019:	b8 00 00 00 00       	mov    $0x0,%eax
  80101e:	c3                   	retq   
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  801024:	c3                   	retq   

0000000000801025 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  801025:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  801028:	ba 00 00 00 00       	mov    $0x0,%edx
  80102d:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  801031:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  801034:	48 83 c2 01          	add    $0x1,%rdx
  801038:	84 c9                	test   %cl,%cl
  80103a:	75 f1                	jne    80102d <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  80103c:	c3                   	retq   

000000000080103d <strcat>:

char *
strcat(char *dst, const char *src) {
  80103d:	55                   	push   %rbp
  80103e:	48 89 e5             	mov    %rsp,%rbp
  801041:	41 54                	push   %r12
  801043:	53                   	push   %rbx
  801044:	48 89 fb             	mov    %rdi,%rbx
  801047:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  80104a:	48 b8 ce 0f 80 00 00 	movabs $0x800fce,%rax
  801051:	00 00 00 
  801054:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  801056:	48 63 f8             	movslq %eax,%rdi
  801059:	48 01 df             	add    %rbx,%rdi
  80105c:	4c 89 e6             	mov    %r12,%rsi
  80105f:	48 b8 25 10 80 00 00 	movabs $0x801025,%rax
  801066:	00 00 00 
  801069:	ff d0                	callq  *%rax
  return dst;
}
  80106b:	48 89 d8             	mov    %rbx,%rax
  80106e:	5b                   	pop    %rbx
  80106f:	41 5c                	pop    %r12
  801071:	5d                   	pop    %rbp
  801072:	c3                   	retq   

0000000000801073 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801073:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801076:	48 85 d2             	test   %rdx,%rdx
  801079:	74 1f                	je     80109a <strncpy+0x27>
  80107b:	48 01 fa             	add    %rdi,%rdx
  80107e:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  801081:	48 83 c1 01          	add    $0x1,%rcx
  801085:	44 0f b6 06          	movzbl (%rsi),%r8d
  801089:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  80108d:	41 80 f8 01          	cmp    $0x1,%r8b
  801091:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  801095:	48 39 ca             	cmp    %rcx,%rdx
  801098:	75 e7                	jne    801081 <strncpy+0xe>
  }
  return ret;
}
  80109a:	c3                   	retq   

000000000080109b <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  80109b:	48 89 f8             	mov    %rdi,%rax
  80109e:	48 85 d2             	test   %rdx,%rdx
  8010a1:	74 36                	je     8010d9 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  8010a3:	48 83 fa 01          	cmp    $0x1,%rdx
  8010a7:	74 2d                	je     8010d6 <strlcpy+0x3b>
  8010a9:	44 0f b6 06          	movzbl (%rsi),%r8d
  8010ad:	45 84 c0             	test   %r8b,%r8b
  8010b0:	74 24                	je     8010d6 <strlcpy+0x3b>
  8010b2:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  8010b6:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  8010bb:	48 83 c0 01          	add    $0x1,%rax
  8010bf:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  8010c3:	48 39 d1             	cmp    %rdx,%rcx
  8010c6:	74 0e                	je     8010d6 <strlcpy+0x3b>
  8010c8:	48 83 c1 01          	add    $0x1,%rcx
  8010cc:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  8010d1:	45 84 c0             	test   %r8b,%r8b
  8010d4:	75 e5                	jne    8010bb <strlcpy+0x20>
    *dst = '\0';
  8010d6:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  8010d9:	48 29 f8             	sub    %rdi,%rax
}
  8010dc:	c3                   	retq   

00000000008010dd <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  8010dd:	0f b6 07             	movzbl (%rdi),%eax
  8010e0:	84 c0                	test   %al,%al
  8010e2:	74 17                	je     8010fb <strcmp+0x1e>
  8010e4:	3a 06                	cmp    (%rsi),%al
  8010e6:	75 13                	jne    8010fb <strcmp+0x1e>
    p++, q++;
  8010e8:	48 83 c7 01          	add    $0x1,%rdi
  8010ec:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  8010f0:	0f b6 07             	movzbl (%rdi),%eax
  8010f3:	84 c0                	test   %al,%al
  8010f5:	74 04                	je     8010fb <strcmp+0x1e>
  8010f7:	3a 06                	cmp    (%rsi),%al
  8010f9:	74 ed                	je     8010e8 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8010fb:	0f b6 c0             	movzbl %al,%eax
  8010fe:	0f b6 16             	movzbl (%rsi),%edx
  801101:	29 d0                	sub    %edx,%eax
}
  801103:	c3                   	retq   

0000000000801104 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  801104:	48 85 d2             	test   %rdx,%rdx
  801107:	74 2f                	je     801138 <strncmp+0x34>
  801109:	0f b6 07             	movzbl (%rdi),%eax
  80110c:	84 c0                	test   %al,%al
  80110e:	74 1f                	je     80112f <strncmp+0x2b>
  801110:	3a 06                	cmp    (%rsi),%al
  801112:	75 1b                	jne    80112f <strncmp+0x2b>
  801114:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  801117:	48 83 c7 01          	add    $0x1,%rdi
  80111b:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  80111f:	48 39 d7             	cmp    %rdx,%rdi
  801122:	74 1a                	je     80113e <strncmp+0x3a>
  801124:	0f b6 07             	movzbl (%rdi),%eax
  801127:	84 c0                	test   %al,%al
  801129:	74 04                	je     80112f <strncmp+0x2b>
  80112b:	3a 06                	cmp    (%rsi),%al
  80112d:	74 e8                	je     801117 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  80112f:	0f b6 07             	movzbl (%rdi),%eax
  801132:	0f b6 16             	movzbl (%rsi),%edx
  801135:	29 d0                	sub    %edx,%eax
}
  801137:	c3                   	retq   
    return 0;
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
  80113d:	c3                   	retq   
  80113e:	b8 00 00 00 00       	mov    $0x0,%eax
  801143:	c3                   	retq   

0000000000801144 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  801144:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  801146:	0f b6 07             	movzbl (%rdi),%eax
  801149:	84 c0                	test   %al,%al
  80114b:	74 1e                	je     80116b <strchr+0x27>
    if (*s == c)
  80114d:	40 38 c6             	cmp    %al,%sil
  801150:	74 1f                	je     801171 <strchr+0x2d>
  for (; *s; s++)
  801152:	48 83 c7 01          	add    $0x1,%rdi
  801156:	0f b6 07             	movzbl (%rdi),%eax
  801159:	84 c0                	test   %al,%al
  80115b:	74 08                	je     801165 <strchr+0x21>
    if (*s == c)
  80115d:	38 d0                	cmp    %dl,%al
  80115f:	75 f1                	jne    801152 <strchr+0xe>
  for (; *s; s++)
  801161:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  801164:	c3                   	retq   
  return 0;
  801165:	b8 00 00 00 00       	mov    $0x0,%eax
  80116a:	c3                   	retq   
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
  801170:	c3                   	retq   
    if (*s == c)
  801171:	48 89 f8             	mov    %rdi,%rax
  801174:	c3                   	retq   

0000000000801175 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801175:	48 89 f8             	mov    %rdi,%rax
  801178:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  80117a:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  80117d:	40 38 f2             	cmp    %sil,%dl
  801180:	74 13                	je     801195 <strfind+0x20>
  801182:	84 d2                	test   %dl,%dl
  801184:	74 0f                	je     801195 <strfind+0x20>
  for (; *s; s++)
  801186:	48 83 c0 01          	add    $0x1,%rax
  80118a:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  80118d:	38 ca                	cmp    %cl,%dl
  80118f:	74 04                	je     801195 <strfind+0x20>
  801191:	84 d2                	test   %dl,%dl
  801193:	75 f1                	jne    801186 <strfind+0x11>
      break;
  return (char *)s;
}
  801195:	c3                   	retq   

0000000000801196 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801196:	48 85 d2             	test   %rdx,%rdx
  801199:	74 3a                	je     8011d5 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80119b:	48 89 f8             	mov    %rdi,%rax
  80119e:	48 09 d0             	or     %rdx,%rax
  8011a1:	a8 03                	test   $0x3,%al
  8011a3:	75 28                	jne    8011cd <memset+0x37>
    uint32_t k = c & 0xFFU;
  8011a5:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  8011a9:	89 f0                	mov    %esi,%eax
  8011ab:	c1 e0 08             	shl    $0x8,%eax
  8011ae:	89 f1                	mov    %esi,%ecx
  8011b0:	c1 e1 18             	shl    $0x18,%ecx
  8011b3:	41 89 f0             	mov    %esi,%r8d
  8011b6:	41 c1 e0 10          	shl    $0x10,%r8d
  8011ba:	44 09 c1             	or     %r8d,%ecx
  8011bd:	09 ce                	or     %ecx,%esi
  8011bf:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  8011c1:	48 c1 ea 02          	shr    $0x2,%rdx
  8011c5:	48 89 d1             	mov    %rdx,%rcx
  8011c8:	fc                   	cld    
  8011c9:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8011cb:	eb 08                	jmp    8011d5 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  8011cd:	89 f0                	mov    %esi,%eax
  8011cf:	48 89 d1             	mov    %rdx,%rcx
  8011d2:	fc                   	cld    
  8011d3:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  8011d5:	48 89 f8             	mov    %rdi,%rax
  8011d8:	c3                   	retq   

00000000008011d9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  8011d9:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8011dc:	48 39 fe             	cmp    %rdi,%rsi
  8011df:	73 40                	jae    801221 <memmove+0x48>
  8011e1:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  8011e5:	48 39 f9             	cmp    %rdi,%rcx
  8011e8:	76 37                	jbe    801221 <memmove+0x48>
    s += n;
    d += n;
  8011ea:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011ee:	48 89 fe             	mov    %rdi,%rsi
  8011f1:	48 09 d6             	or     %rdx,%rsi
  8011f4:	48 09 ce             	or     %rcx,%rsi
  8011f7:	40 f6 c6 03          	test   $0x3,%sil
  8011fb:	75 14                	jne    801211 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8011fd:	48 83 ef 04          	sub    $0x4,%rdi
  801201:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  801205:	48 c1 ea 02          	shr    $0x2,%rdx
  801209:	48 89 d1             	mov    %rdx,%rcx
  80120c:	fd                   	std    
  80120d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80120f:	eb 0e                	jmp    80121f <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  801211:	48 83 ef 01          	sub    $0x1,%rdi
  801215:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  801219:	48 89 d1             	mov    %rdx,%rcx
  80121c:	fd                   	std    
  80121d:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  80121f:	fc                   	cld    
  801220:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801221:	48 89 c1             	mov    %rax,%rcx
  801224:	48 09 d1             	or     %rdx,%rcx
  801227:	48 09 f1             	or     %rsi,%rcx
  80122a:	f6 c1 03             	test   $0x3,%cl
  80122d:	75 0e                	jne    80123d <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  80122f:	48 c1 ea 02          	shr    $0x2,%rdx
  801233:	48 89 d1             	mov    %rdx,%rcx
  801236:	48 89 c7             	mov    %rax,%rdi
  801239:	fc                   	cld    
  80123a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80123c:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80123d:	48 89 c7             	mov    %rax,%rdi
  801240:	48 89 d1             	mov    %rdx,%rcx
  801243:	fc                   	cld    
  801244:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  801246:	c3                   	retq   

0000000000801247 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  801247:	55                   	push   %rbp
  801248:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  80124b:	48 b8 d9 11 80 00 00 	movabs $0x8011d9,%rax
  801252:	00 00 00 
  801255:	ff d0                	callq  *%rax
}
  801257:	5d                   	pop    %rbp
  801258:	c3                   	retq   

0000000000801259 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  801259:	55                   	push   %rbp
  80125a:	48 89 e5             	mov    %rsp,%rbp
  80125d:	41 57                	push   %r15
  80125f:	41 56                	push   %r14
  801261:	41 55                	push   %r13
  801263:	41 54                	push   %r12
  801265:	53                   	push   %rbx
  801266:	48 83 ec 08          	sub    $0x8,%rsp
  80126a:	49 89 fe             	mov    %rdi,%r14
  80126d:	49 89 f7             	mov    %rsi,%r15
  801270:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801273:	48 89 f7             	mov    %rsi,%rdi
  801276:	48 b8 ce 0f 80 00 00 	movabs $0x800fce,%rax
  80127d:	00 00 00 
  801280:	ff d0                	callq  *%rax
  801282:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801285:	4c 89 ee             	mov    %r13,%rsi
  801288:	4c 89 f7             	mov    %r14,%rdi
  80128b:	48 b8 f0 0f 80 00 00 	movabs $0x800ff0,%rax
  801292:	00 00 00 
  801295:	ff d0                	callq  *%rax
  801297:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80129a:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  80129e:	4d 39 e5             	cmp    %r12,%r13
  8012a1:	74 26                	je     8012c9 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  8012a3:	4c 89 e8             	mov    %r13,%rax
  8012a6:	4c 29 e0             	sub    %r12,%rax
  8012a9:	48 39 d8             	cmp    %rbx,%rax
  8012ac:	76 2a                	jbe    8012d8 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  8012ae:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  8012b2:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8012b6:	4c 89 fe             	mov    %r15,%rsi
  8012b9:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  8012c0:	00 00 00 
  8012c3:	ff d0                	callq  *%rax
  return dstlen + srclen;
  8012c5:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  8012c9:	48 83 c4 08          	add    $0x8,%rsp
  8012cd:	5b                   	pop    %rbx
  8012ce:	41 5c                	pop    %r12
  8012d0:	41 5d                	pop    %r13
  8012d2:	41 5e                	pop    %r14
  8012d4:	41 5f                	pop    %r15
  8012d6:	5d                   	pop    %rbp
  8012d7:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  8012d8:	49 83 ed 01          	sub    $0x1,%r13
  8012dc:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8012e0:	4c 89 ea             	mov    %r13,%rdx
  8012e3:	4c 89 fe             	mov    %r15,%rsi
  8012e6:	48 b8 47 12 80 00 00 	movabs $0x801247,%rax
  8012ed:	00 00 00 
  8012f0:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  8012f2:	4d 01 ee             	add    %r13,%r14
  8012f5:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8012fa:	eb c9                	jmp    8012c5 <strlcat+0x6c>

00000000008012fc <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8012fc:	48 85 d2             	test   %rdx,%rdx
  8012ff:	74 3a                	je     80133b <memcmp+0x3f>
    if (*s1 != *s2)
  801301:	0f b6 0f             	movzbl (%rdi),%ecx
  801304:	44 0f b6 06          	movzbl (%rsi),%r8d
  801308:	44 38 c1             	cmp    %r8b,%cl
  80130b:	75 1d                	jne    80132a <memcmp+0x2e>
  80130d:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801312:	48 39 d0             	cmp    %rdx,%rax
  801315:	74 1e                	je     801335 <memcmp+0x39>
    if (*s1 != *s2)
  801317:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80131b:	48 83 c0 01          	add    $0x1,%rax
  80131f:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801325:	44 38 c1             	cmp    %r8b,%cl
  801328:	74 e8                	je     801312 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80132a:	0f b6 c1             	movzbl %cl,%eax
  80132d:	45 0f b6 c0          	movzbl %r8b,%r8d
  801331:	44 29 c0             	sub    %r8d,%eax
  801334:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801335:	b8 00 00 00 00       	mov    $0x0,%eax
  80133a:	c3                   	retq   
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801340:	c3                   	retq   

0000000000801341 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801341:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801345:	48 39 c7             	cmp    %rax,%rdi
  801348:	73 19                	jae    801363 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80134a:	89 f2                	mov    %esi,%edx
  80134c:	40 38 37             	cmp    %sil,(%rdi)
  80134f:	74 16                	je     801367 <memfind+0x26>
  for (; s < ends; s++)
  801351:	48 83 c7 01          	add    $0x1,%rdi
  801355:	48 39 f8             	cmp    %rdi,%rax
  801358:	74 08                	je     801362 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80135a:	38 17                	cmp    %dl,(%rdi)
  80135c:	75 f3                	jne    801351 <memfind+0x10>
  for (; s < ends; s++)
  80135e:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801361:	c3                   	retq   
  801362:	c3                   	retq   
  for (; s < ends; s++)
  801363:	48 89 f8             	mov    %rdi,%rax
  801366:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801367:	48 89 f8             	mov    %rdi,%rax
  80136a:	c3                   	retq   

000000000080136b <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80136b:	0f b6 07             	movzbl (%rdi),%eax
  80136e:	3c 20                	cmp    $0x20,%al
  801370:	74 04                	je     801376 <strtol+0xb>
  801372:	3c 09                	cmp    $0x9,%al
  801374:	75 0f                	jne    801385 <strtol+0x1a>
    s++;
  801376:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80137a:	0f b6 07             	movzbl (%rdi),%eax
  80137d:	3c 20                	cmp    $0x20,%al
  80137f:	74 f5                	je     801376 <strtol+0xb>
  801381:	3c 09                	cmp    $0x9,%al
  801383:	74 f1                	je     801376 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801385:	3c 2b                	cmp    $0x2b,%al
  801387:	74 2b                	je     8013b4 <strtol+0x49>
  int neg  = 0;
  801389:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80138f:	3c 2d                	cmp    $0x2d,%al
  801391:	74 2d                	je     8013c0 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801393:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801399:	75 0f                	jne    8013aa <strtol+0x3f>
  80139b:	80 3f 30             	cmpb   $0x30,(%rdi)
  80139e:	74 2c                	je     8013cc <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8013a0:	85 d2                	test   %edx,%edx
  8013a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8013a7:	0f 44 d0             	cmove  %eax,%edx
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8013af:	4c 63 d2             	movslq %edx,%r10
  8013b2:	eb 5c                	jmp    801410 <strtol+0xa5>
    s++;
  8013b4:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8013b8:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8013be:	eb d3                	jmp    801393 <strtol+0x28>
    s++, neg = 1;
  8013c0:	48 83 c7 01          	add    $0x1,%rdi
  8013c4:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8013ca:	eb c7                	jmp    801393 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8013cc:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8013d0:	74 0f                	je     8013e1 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8013d2:	85 d2                	test   %edx,%edx
  8013d4:	75 d4                	jne    8013aa <strtol+0x3f>
    s++, base = 8;
  8013d6:	48 83 c7 01          	add    $0x1,%rdi
  8013da:	ba 08 00 00 00       	mov    $0x8,%edx
  8013df:	eb c9                	jmp    8013aa <strtol+0x3f>
    s += 2, base = 16;
  8013e1:	48 83 c7 02          	add    $0x2,%rdi
  8013e5:	ba 10 00 00 00       	mov    $0x10,%edx
  8013ea:	eb be                	jmp    8013aa <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8013ec:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8013f0:	41 80 f8 19          	cmp    $0x19,%r8b
  8013f4:	77 2f                	ja     801425 <strtol+0xba>
      dig = *s - 'a' + 10;
  8013f6:	44 0f be c1          	movsbl %cl,%r8d
  8013fa:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8013fe:	39 d1                	cmp    %edx,%ecx
  801400:	7d 37                	jge    801439 <strtol+0xce>
    s++, val = (val * base) + dig;
  801402:	48 83 c7 01          	add    $0x1,%rdi
  801406:	49 0f af c2          	imul   %r10,%rax
  80140a:	48 63 c9             	movslq %ecx,%rcx
  80140d:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801410:	0f b6 0f             	movzbl (%rdi),%ecx
  801413:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801417:	41 80 f8 09          	cmp    $0x9,%r8b
  80141b:	77 cf                	ja     8013ec <strtol+0x81>
      dig = *s - '0';
  80141d:	0f be c9             	movsbl %cl,%ecx
  801420:	83 e9 30             	sub    $0x30,%ecx
  801423:	eb d9                	jmp    8013fe <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801425:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801429:	41 80 f8 19          	cmp    $0x19,%r8b
  80142d:	77 0a                	ja     801439 <strtol+0xce>
      dig = *s - 'A' + 10;
  80142f:	44 0f be c1          	movsbl %cl,%r8d
  801433:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801437:	eb c5                	jmp    8013fe <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801439:	48 85 f6             	test   %rsi,%rsi
  80143c:	74 03                	je     801441 <strtol+0xd6>
    *endptr = (char *)s;
  80143e:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801441:	48 89 c2             	mov    %rax,%rdx
  801444:	48 f7 da             	neg    %rdx
  801447:	45 85 c9             	test   %r9d,%r9d
  80144a:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80144e:	c3                   	retq   

000000000080144f <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  80144f:	55                   	push   %rbp
  801450:	48 89 e5             	mov    %rsp,%rbp
  801453:	41 54                	push   %r12
  801455:	53                   	push   %rbx
  801456:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  801459:	48 b8 c1 01 80 00 00 	movabs $0x8001c1,%rax
  801460:	00 00 00 
  801463:	ff d0                	callq  *%rax
  801465:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  801467:	48 b8 10 20 80 00 00 	movabs $0x802010,%rax
  80146e:	00 00 00 
  801471:	48 83 38 00          	cmpq   $0x0,(%rax)
  801475:	74 2e                	je     8014a5 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801477:	4c 89 e0             	mov    %r12,%rax
  80147a:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  801481:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801484:	48 be 6e 04 80 00 00 	movabs $0x80046e,%rsi
  80148b:	00 00 00 
  80148e:	89 df                	mov    %ebx,%edi
  801490:	48 b8 8b 03 80 00 00 	movabs $0x80038b,%rax
  801497:	00 00 00 
  80149a:	ff d0                	callq  *%rax
  if (error < 0)
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 24                	js     8014c4 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  8014a0:	5b                   	pop    %rbx
  8014a1:	41 5c                	pop    %r12
  8014a3:	5d                   	pop    %rbp
  8014a4:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  8014a5:	ba 02 00 00 00       	mov    $0x2,%edx
  8014aa:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8014b1:	00 00 00 
  8014b4:	89 df                	mov    %ebx,%edi
  8014b6:	48 b8 01 02 80 00 00 	movabs $0x800201,%rax
  8014bd:	00 00 00 
  8014c0:	ff d0                	callq  *%rax
  8014c2:	eb b3                	jmp    801477 <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  8014c4:	89 c1                	mov    %eax,%ecx
  8014c6:	48 ba 60 19 80 00 00 	movabs $0x801960,%rdx
  8014cd:	00 00 00 
  8014d0:	be 2c 00 00 00       	mov    $0x2c,%esi
  8014d5:	48 bf 78 19 80 00 00 	movabs $0x801978,%rdi
  8014dc:	00 00 00 
  8014df:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e4:	49 b8 b9 04 80 00 00 	movabs $0x8004b9,%r8
  8014eb:	00 00 00 
  8014ee:	41 ff d0             	callq  *%r8
  8014f1:	0f 1f 00             	nopl   (%rax)
