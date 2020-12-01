
obj/user/faultwrite:     file format elf64-x86-64


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
  800023:	e8 0e 00 00 00       	callq  800036 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  *(volatile unsigned *)0 = 0;
  80002a:	c7 04 25 00 00 00 00 	movl   $0x0,0x0
  800031:	00 00 00 00 
}
  800035:	c3                   	retq   

0000000000800036 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800036:	55                   	push   %rbp
  800037:	48 89 e5             	mov    %rsp,%rbp
  80003a:	41 56                	push   %r14
  80003c:	41 55                	push   %r13
  80003e:	41 54                	push   %r12
  800040:	53                   	push   %rbx
  800041:	41 89 fd             	mov    %edi,%r13d
  800044:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800047:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80004e:	00 00 00 
  800051:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800058:	00 00 00 
  80005b:	48 39 c2             	cmp    %rax,%rdx
  80005e:	73 23                	jae    800083 <libmain+0x4d>
  800060:	48 89 d3             	mov    %rdx,%rbx
  800063:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800067:	48 29 d0             	sub    %rdx,%rax
  80006a:	48 c1 e8 03          	shr    $0x3,%rax
  80006e:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800073:	b8 00 00 00 00       	mov    $0x0,%eax
  800078:	ff 13                	callq  *(%rbx)
    ctor++;
  80007a:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80007e:	4c 39 e3             	cmp    %r12,%rbx
  800081:	75 f0                	jne    800073 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800083:	48 b8 a1 01 80 00 00 	movabs $0x8001a1,%rax
  80008a:	00 00 00 
  80008d:	ff d0                	callq  *%rax
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800098:	48 c1 e0 05          	shl    $0x5,%rax
  80009c:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000a3:	00 00 00 
  8000a6:	48 01 d0             	add    %rdx,%rax
  8000a9:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000b0:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000b3:	45 85 ed             	test   %r13d,%r13d
  8000b6:	7e 0d                	jle    8000c5 <libmain+0x8f>
    binaryname = argv[0];
  8000b8:	49 8b 06             	mov    (%r14),%rax
  8000bb:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000c2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000c5:	4c 89 f6             	mov    %r14,%rsi
  8000c8:	44 89 ef             	mov    %r13d,%edi
  8000cb:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000d2:	00 00 00 
  8000d5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000d7:	48 b8 ec 00 80 00 00 	movabs $0x8000ec,%rax
  8000de:	00 00 00 
  8000e1:	ff d0                	callq  *%rax
#endif
}
  8000e3:	5b                   	pop    %rbx
  8000e4:	41 5c                	pop    %r12
  8000e6:	41 5d                	pop    %r13
  8000e8:	41 5e                	pop    %r14
  8000ea:	5d                   	pop    %rbp
  8000eb:	c3                   	retq   

00000000008000ec <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000ec:	55                   	push   %rbp
  8000ed:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f5:	48 b8 41 01 80 00 00 	movabs $0x800141,%rax
  8000fc:	00 00 00 
  8000ff:	ff d0                	callq  *%rax
}
  800101:	5d                   	pop    %rbp
  800102:	c3                   	retq   

0000000000800103 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800103:	55                   	push   %rbp
  800104:	48 89 e5             	mov    %rsp,%rbp
  800107:	53                   	push   %rbx
  800108:	48 89 fa             	mov    %rdi,%rdx
  80010b:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  80010e:	b8 00 00 00 00       	mov    $0x0,%eax
  800113:	48 89 c3             	mov    %rax,%rbx
  800116:	48 89 c7             	mov    %rax,%rdi
  800119:	48 89 c6             	mov    %rax,%rsi
  80011c:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80011e:	5b                   	pop    %rbx
  80011f:	5d                   	pop    %rbp
  800120:	c3                   	retq   

0000000000800121 <sys_cgetc>:

int
sys_cgetc(void) {
  800121:	55                   	push   %rbp
  800122:	48 89 e5             	mov    %rsp,%rbp
  800125:	53                   	push   %rbx
  asm volatile("int %1\n"
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	b8 01 00 00 00       	mov    $0x1,%eax
  800130:	48 89 ca             	mov    %rcx,%rdx
  800133:	48 89 cb             	mov    %rcx,%rbx
  800136:	48 89 cf             	mov    %rcx,%rdi
  800139:	48 89 ce             	mov    %rcx,%rsi
  80013c:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %rbx
  80013f:	5d                   	pop    %rbp
  800140:	c3                   	retq   

0000000000800141 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800141:	55                   	push   %rbp
  800142:	48 89 e5             	mov    %rsp,%rbp
  800145:	53                   	push   %rbx
  800146:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80014d:	be 00 00 00 00       	mov    $0x0,%esi
  800152:	b8 03 00 00 00       	mov    $0x3,%eax
  800157:	48 89 f1             	mov    %rsi,%rcx
  80015a:	48 89 f3             	mov    %rsi,%rbx
  80015d:	48 89 f7             	mov    %rsi,%rdi
  800160:	cd 30                	int    $0x30
  if (check && ret > 0)
  800162:	48 85 c0             	test   %rax,%rax
  800165:	7f 07                	jg     80016e <sys_env_destroy+0x2d>
}
  800167:	48 83 c4 08          	add    $0x8,%rsp
  80016b:	5b                   	pop    %rbx
  80016c:	5d                   	pop    %rbp
  80016d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80016e:	49 89 c0             	mov    %rax,%r8
  800171:	b9 03 00 00 00       	mov    $0x3,%ecx
  800176:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80017d:	00 00 00 
  800180:	be 22 00 00 00       	mov    $0x22,%esi
  800185:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80018c:	00 00 00 
  80018f:	b8 00 00 00 00       	mov    $0x0,%eax
  800194:	49 b9 4e 04 80 00 00 	movabs $0x80044e,%r9
  80019b:	00 00 00 
  80019e:	41 ff d1             	callq  *%r9

00000000008001a1 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001a1:	55                   	push   %rbp
  8001a2:	48 89 e5             	mov    %rsp,%rbp
  8001a5:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b0:	48 89 ca             	mov    %rcx,%rdx
  8001b3:	48 89 cb             	mov    %rcx,%rbx
  8001b6:	48 89 cf             	mov    %rcx,%rdi
  8001b9:	48 89 ce             	mov    %rcx,%rsi
  8001bc:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001be:	5b                   	pop    %rbx
  8001bf:	5d                   	pop    %rbp
  8001c0:	c3                   	retq   

00000000008001c1 <sys_yield>:

void
sys_yield(void) {
  8001c1:	55                   	push   %rbp
  8001c2:	48 89 e5             	mov    %rsp,%rbp
  8001c5:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001d0:	48 89 ca             	mov    %rcx,%rdx
  8001d3:	48 89 cb             	mov    %rcx,%rbx
  8001d6:	48 89 cf             	mov    %rcx,%rdi
  8001d9:	48 89 ce             	mov    %rcx,%rsi
  8001dc:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001de:	5b                   	pop    %rbx
  8001df:	5d                   	pop    %rbp
  8001e0:	c3                   	retq   

00000000008001e1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001e1:	55                   	push   %rbp
  8001e2:	48 89 e5             	mov    %rsp,%rbp
  8001e5:	53                   	push   %rbx
  8001e6:	48 83 ec 08          	sub    $0x8,%rsp
  8001ea:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8001ed:	4c 63 c7             	movslq %edi,%r8
  8001f0:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8001f3:	be 00 00 00 00       	mov    $0x0,%esi
  8001f8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001fd:	4c 89 c2             	mov    %r8,%rdx
  800200:	48 89 f7             	mov    %rsi,%rdi
  800203:	cd 30                	int    $0x30
  if (check && ret > 0)
  800205:	48 85 c0             	test   %rax,%rax
  800208:	7f 07                	jg     800211 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80020a:	48 83 c4 08          	add    $0x8,%rsp
  80020e:	5b                   	pop    %rbx
  80020f:	5d                   	pop    %rbp
  800210:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800211:	49 89 c0             	mov    %rax,%r8
  800214:	b9 04 00 00 00       	mov    $0x4,%ecx
  800219:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800220:	00 00 00 
  800223:	be 22 00 00 00       	mov    $0x22,%esi
  800228:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80022f:	00 00 00 
  800232:	b8 00 00 00 00       	mov    $0x0,%eax
  800237:	49 b9 4e 04 80 00 00 	movabs $0x80044e,%r9
  80023e:	00 00 00 
  800241:	41 ff d1             	callq  *%r9

0000000000800244 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  800244:	55                   	push   %rbp
  800245:	48 89 e5             	mov    %rsp,%rbp
  800248:	53                   	push   %rbx
  800249:	48 83 ec 08          	sub    $0x8,%rsp
  80024d:	41 89 f9             	mov    %edi,%r9d
  800250:	49 89 f2             	mov    %rsi,%r10
  800253:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  800256:	4d 63 c9             	movslq %r9d,%r9
  800259:	48 63 da             	movslq %edx,%rbx
  80025c:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80025f:	b8 05 00 00 00       	mov    $0x5,%eax
  800264:	4c 89 ca             	mov    %r9,%rdx
  800267:	4c 89 d1             	mov    %r10,%rcx
  80026a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80026c:	48 85 c0             	test   %rax,%rax
  80026f:	7f 07                	jg     800278 <sys_page_map+0x34>
}
  800271:	48 83 c4 08          	add    $0x8,%rsp
  800275:	5b                   	pop    %rbx
  800276:	5d                   	pop    %rbp
  800277:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800278:	49 89 c0             	mov    %rax,%r8
  80027b:	b9 05 00 00 00       	mov    $0x5,%ecx
  800280:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800287:	00 00 00 
  80028a:	be 22 00 00 00       	mov    $0x22,%esi
  80028f:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800296:	00 00 00 
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
  80029e:	49 b9 4e 04 80 00 00 	movabs $0x80044e,%r9
  8002a5:	00 00 00 
  8002a8:	41 ff d1             	callq  *%r9

00000000008002ab <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002ab:	55                   	push   %rbp
  8002ac:	48 89 e5             	mov    %rsp,%rbp
  8002af:	53                   	push   %rbx
  8002b0:	48 83 ec 08          	sub    $0x8,%rsp
  8002b4:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002b7:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002ba:	be 00 00 00 00       	mov    $0x0,%esi
  8002bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8002c4:	48 89 f3             	mov    %rsi,%rbx
  8002c7:	48 89 f7             	mov    %rsi,%rdi
  8002ca:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002cc:	48 85 c0             	test   %rax,%rax
  8002cf:	7f 07                	jg     8002d8 <sys_page_unmap+0x2d>
}
  8002d1:	48 83 c4 08          	add    $0x8,%rsp
  8002d5:	5b                   	pop    %rbx
  8002d6:	5d                   	pop    %rbp
  8002d7:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002d8:	49 89 c0             	mov    %rax,%r8
  8002db:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002e0:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8002e7:	00 00 00 
  8002ea:	be 22 00 00 00       	mov    $0x22,%esi
  8002ef:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8002f6:	00 00 00 
  8002f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fe:	49 b9 4e 04 80 00 00 	movabs $0x80044e,%r9
  800305:	00 00 00 
  800308:	41 ff d1             	callq  *%r9

000000000080030b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  80030b:	55                   	push   %rbp
  80030c:	48 89 e5             	mov    %rsp,%rbp
  80030f:	53                   	push   %rbx
  800310:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800314:	48 63 d7             	movslq %edi,%rdx
  800317:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80031a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031f:	b8 08 00 00 00       	mov    $0x8,%eax
  800324:	48 89 df             	mov    %rbx,%rdi
  800327:	48 89 de             	mov    %rbx,%rsi
  80032a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80032c:	48 85 c0             	test   %rax,%rax
  80032f:	7f 07                	jg     800338 <sys_env_set_status+0x2d>
}
  800331:	48 83 c4 08          	add    $0x8,%rsp
  800335:	5b                   	pop    %rbx
  800336:	5d                   	pop    %rbp
  800337:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800338:	49 89 c0             	mov    %rax,%r8
  80033b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800340:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800347:	00 00 00 
  80034a:	be 22 00 00 00       	mov    $0x22,%esi
  80034f:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800356:	00 00 00 
  800359:	b8 00 00 00 00       	mov    $0x0,%eax
  80035e:	49 b9 4e 04 80 00 00 	movabs $0x80044e,%r9
  800365:	00 00 00 
  800368:	41 ff d1             	callq  *%r9

000000000080036b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80036b:	55                   	push   %rbp
  80036c:	48 89 e5             	mov    %rsp,%rbp
  80036f:	53                   	push   %rbx
  800370:	48 83 ec 08          	sub    $0x8,%rsp
  800374:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  800377:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80037a:	be 00 00 00 00       	mov    $0x0,%esi
  80037f:	b8 09 00 00 00       	mov    $0x9,%eax
  800384:	48 89 f3             	mov    %rsi,%rbx
  800387:	48 89 f7             	mov    %rsi,%rdi
  80038a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80038c:	48 85 c0             	test   %rax,%rax
  80038f:	7f 07                	jg     800398 <sys_env_set_pgfault_upcall+0x2d>
}
  800391:	48 83 c4 08          	add    $0x8,%rsp
  800395:	5b                   	pop    %rbx
  800396:	5d                   	pop    %rbp
  800397:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800398:	49 89 c0             	mov    %rax,%r8
  80039b:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003a0:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8003a7:	00 00 00 
  8003aa:	be 22 00 00 00       	mov    $0x22,%esi
  8003af:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8003b6:	00 00 00 
  8003b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003be:	49 b9 4e 04 80 00 00 	movabs $0x80044e,%r9
  8003c5:	00 00 00 
  8003c8:	41 ff d1             	callq  *%r9

00000000008003cb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003cb:	55                   	push   %rbp
  8003cc:	48 89 e5             	mov    %rsp,%rbp
  8003cf:	53                   	push   %rbx
  8003d0:	49 89 f0             	mov    %rsi,%r8
  8003d3:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003d6:	48 63 d7             	movslq %edi,%rdx
  8003d9:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003dc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003e1:	be 00 00 00 00       	mov    $0x0,%esi
  8003e6:	4c 89 c1             	mov    %r8,%rcx
  8003e9:	cd 30                	int    $0x30
}
  8003eb:	5b                   	pop    %rbx
  8003ec:	5d                   	pop    %rbp
  8003ed:	c3                   	retq   

00000000008003ee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8003ee:	55                   	push   %rbp
  8003ef:	48 89 e5             	mov    %rsp,%rbp
  8003f2:	53                   	push   %rbx
  8003f3:	48 83 ec 08          	sub    $0x8,%rsp
  8003f7:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8003fa:	be 00 00 00 00       	mov    $0x0,%esi
  8003ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800404:	48 89 f1             	mov    %rsi,%rcx
  800407:	48 89 f3             	mov    %rsi,%rbx
  80040a:	48 89 f7             	mov    %rsi,%rdi
  80040d:	cd 30                	int    $0x30
  if (check && ret > 0)
  80040f:	48 85 c0             	test   %rax,%rax
  800412:	7f 07                	jg     80041b <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  800414:	48 83 c4 08          	add    $0x8,%rsp
  800418:	5b                   	pop    %rbx
  800419:	5d                   	pop    %rbp
  80041a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80041b:	49 89 c0             	mov    %rax,%r8
  80041e:	b9 0c 00 00 00       	mov    $0xc,%ecx
  800423:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80042a:	00 00 00 
  80042d:	be 22 00 00 00       	mov    $0x22,%esi
  800432:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800439:	00 00 00 
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	49 b9 4e 04 80 00 00 	movabs $0x80044e,%r9
  800448:	00 00 00 
  80044b:	41 ff d1             	callq  *%r9

000000000080044e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80044e:	55                   	push   %rbp
  80044f:	48 89 e5             	mov    %rsp,%rbp
  800452:	41 56                	push   %r14
  800454:	41 55                	push   %r13
  800456:	41 54                	push   %r12
  800458:	53                   	push   %rbx
  800459:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800460:	49 89 fd             	mov    %rdi,%r13
  800463:	41 89 f6             	mov    %esi,%r14d
  800466:	49 89 d4             	mov    %rdx,%r12
  800469:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800470:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800477:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80047e:	84 c0                	test   %al,%al
  800480:	74 26                	je     8004a8 <_panic+0x5a>
  800482:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800489:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800490:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800494:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800498:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80049c:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8004a0:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8004a4:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004a8:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004af:	00 00 00 
  8004b2:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004b9:	00 00 00 
  8004bc:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004c0:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004c7:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004ce:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004d5:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004dc:	00 00 00 
  8004df:	48 8b 18             	mov    (%rax),%rbx
  8004e2:	48 b8 a1 01 80 00 00 	movabs $0x8001a1,%rax
  8004e9:	00 00 00 
  8004ec:	ff d0                	callq  *%rax
  8004ee:	45 89 f0             	mov    %r14d,%r8d
  8004f1:	4c 89 e9             	mov    %r13,%rcx
  8004f4:	48 89 da             	mov    %rbx,%rdx
  8004f7:	89 c6                	mov    %eax,%esi
  8004f9:	48 bf 40 14 80 00 00 	movabs $0x801440,%rdi
  800500:	00 00 00 
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	48 bb f0 05 80 00 00 	movabs $0x8005f0,%rbx
  80050f:	00 00 00 
  800512:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800514:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80051b:	4c 89 e7             	mov    %r12,%rdi
  80051e:	48 b8 88 05 80 00 00 	movabs $0x800588,%rax
  800525:	00 00 00 
  800528:	ff d0                	callq  *%rax
  cprintf("\n");
  80052a:	48 bf 68 14 80 00 00 	movabs $0x801468,%rdi
  800531:	00 00 00 
  800534:	b8 00 00 00 00       	mov    $0x0,%eax
  800539:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80053b:	cc                   	int3   
  while (1)
  80053c:	eb fd                	jmp    80053b <_panic+0xed>

000000000080053e <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80053e:	55                   	push   %rbp
  80053f:	48 89 e5             	mov    %rsp,%rbp
  800542:	53                   	push   %rbx
  800543:	48 83 ec 08          	sub    $0x8,%rsp
  800547:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80054a:	8b 06                	mov    (%rsi),%eax
  80054c:	8d 50 01             	lea    0x1(%rax),%edx
  80054f:	89 16                	mov    %edx,(%rsi)
  800551:	48 98                	cltq   
  800553:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800558:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80055e:	74 0b                	je     80056b <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800560:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800564:	48 83 c4 08          	add    $0x8,%rsp
  800568:	5b                   	pop    %rbx
  800569:	5d                   	pop    %rbp
  80056a:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80056b:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80056f:	be ff 00 00 00       	mov    $0xff,%esi
  800574:	48 b8 03 01 80 00 00 	movabs $0x800103,%rax
  80057b:	00 00 00 
  80057e:	ff d0                	callq  *%rax
    b->idx = 0;
  800580:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800586:	eb d8                	jmp    800560 <putch+0x22>

0000000000800588 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800588:	55                   	push   %rbp
  800589:	48 89 e5             	mov    %rsp,%rbp
  80058c:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800593:	48 89 fa             	mov    %rdi,%rdx
  800596:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800599:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8005a0:	00 00 00 
  b.cnt = 0;
  8005a3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005aa:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005ad:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005b4:	48 bf 3e 05 80 00 00 	movabs $0x80053e,%rdi
  8005bb:	00 00 00 
  8005be:	48 b8 ae 07 80 00 00 	movabs $0x8007ae,%rax
  8005c5:	00 00 00 
  8005c8:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005ca:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005d1:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005d8:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005dc:	48 b8 03 01 80 00 00 	movabs $0x800103,%rax
  8005e3:	00 00 00 
  8005e6:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8005ee:	c9                   	leaveq 
  8005ef:	c3                   	retq   

00000000008005f0 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8005f0:	55                   	push   %rbp
  8005f1:	48 89 e5             	mov    %rsp,%rbp
  8005f4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8005fb:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800602:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800609:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800610:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800617:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80061e:	84 c0                	test   %al,%al
  800620:	74 20                	je     800642 <cprintf+0x52>
  800622:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800626:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80062a:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80062e:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800632:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800636:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80063a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80063e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800642:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800649:	00 00 00 
  80064c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800653:	00 00 00 
  800656:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80065a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800661:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800668:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80066f:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800676:	48 b8 88 05 80 00 00 	movabs $0x800588,%rax
  80067d:	00 00 00 
  800680:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800682:	c9                   	leaveq 
  800683:	c3                   	retq   

0000000000800684 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800684:	55                   	push   %rbp
  800685:	48 89 e5             	mov    %rsp,%rbp
  800688:	41 57                	push   %r15
  80068a:	41 56                	push   %r14
  80068c:	41 55                	push   %r13
  80068e:	41 54                	push   %r12
  800690:	53                   	push   %rbx
  800691:	48 83 ec 18          	sub    $0x18,%rsp
  800695:	49 89 fc             	mov    %rdi,%r12
  800698:	49 89 f5             	mov    %rsi,%r13
  80069b:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80069f:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8006a2:	41 89 cf             	mov    %ecx,%r15d
  8006a5:	49 39 d7             	cmp    %rdx,%r15
  8006a8:	76 45                	jbe    8006ef <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006aa:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006ae:	85 db                	test   %ebx,%ebx
  8006b0:	7e 0e                	jle    8006c0 <printnum+0x3c>
      putch(padc, putdat);
  8006b2:	4c 89 ee             	mov    %r13,%rsi
  8006b5:	44 89 f7             	mov    %r14d,%edi
  8006b8:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006bb:	83 eb 01             	sub    $0x1,%ebx
  8006be:	75 f2                	jne    8006b2 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006c0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c9:	49 f7 f7             	div    %r15
  8006cc:	48 b8 6a 14 80 00 00 	movabs $0x80146a,%rax
  8006d3:	00 00 00 
  8006d6:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006da:	4c 89 ee             	mov    %r13,%rsi
  8006dd:	41 ff d4             	callq  *%r12
}
  8006e0:	48 83 c4 18          	add    $0x18,%rsp
  8006e4:	5b                   	pop    %rbx
  8006e5:	41 5c                	pop    %r12
  8006e7:	41 5d                	pop    %r13
  8006e9:	41 5e                	pop    %r14
  8006eb:	41 5f                	pop    %r15
  8006ed:	5d                   	pop    %rbp
  8006ee:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ef:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f8:	49 f7 f7             	div    %r15
  8006fb:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8006ff:	48 89 c2             	mov    %rax,%rdx
  800702:	48 b8 84 06 80 00 00 	movabs $0x800684,%rax
  800709:	00 00 00 
  80070c:	ff d0                	callq  *%rax
  80070e:	eb b0                	jmp    8006c0 <printnum+0x3c>

0000000000800710 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800710:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800714:	48 8b 06             	mov    (%rsi),%rax
  800717:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80071b:	73 0a                	jae    800727 <sprintputch+0x17>
    *b->buf++ = ch;
  80071d:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800721:	48 89 16             	mov    %rdx,(%rsi)
  800724:	40 88 38             	mov    %dil,(%rax)
}
  800727:	c3                   	retq   

0000000000800728 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800728:	55                   	push   %rbp
  800729:	48 89 e5             	mov    %rsp,%rbp
  80072c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800733:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80073a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800741:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800748:	84 c0                	test   %al,%al
  80074a:	74 20                	je     80076c <printfmt+0x44>
  80074c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800750:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800754:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800758:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80075c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800760:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800764:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800768:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80076c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800773:	00 00 00 
  800776:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80077d:	00 00 00 
  800780:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800784:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80078b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800792:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800799:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8007a0:	48 b8 ae 07 80 00 00 	movabs $0x8007ae,%rax
  8007a7:	00 00 00 
  8007aa:	ff d0                	callq  *%rax
}
  8007ac:	c9                   	leaveq 
  8007ad:	c3                   	retq   

00000000008007ae <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007ae:	55                   	push   %rbp
  8007af:	48 89 e5             	mov    %rsp,%rbp
  8007b2:	41 57                	push   %r15
  8007b4:	41 56                	push   %r14
  8007b6:	41 55                	push   %r13
  8007b8:	41 54                	push   %r12
  8007ba:	53                   	push   %rbx
  8007bb:	48 83 ec 48          	sub    $0x48,%rsp
  8007bf:	49 89 fd             	mov    %rdi,%r13
  8007c2:	49 89 f7             	mov    %rsi,%r15
  8007c5:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007c8:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007cc:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007d0:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007d4:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007d8:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007dc:	41 0f b6 3e          	movzbl (%r14),%edi
  8007e0:	83 ff 25             	cmp    $0x25,%edi
  8007e3:	74 18                	je     8007fd <vprintfmt+0x4f>
      if (ch == '\0')
  8007e5:	85 ff                	test   %edi,%edi
  8007e7:	0f 84 8c 06 00 00    	je     800e79 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8007ed:	4c 89 fe             	mov    %r15,%rsi
  8007f0:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007f3:	49 89 de             	mov    %rbx,%r14
  8007f6:	eb e0                	jmp    8007d8 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8007f8:	49 89 de             	mov    %rbx,%r14
  8007fb:	eb db                	jmp    8007d8 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8007fd:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800801:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800805:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80080c:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800812:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800816:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80081b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800821:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800827:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80082c:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800831:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800835:	0f b6 13             	movzbl (%rbx),%edx
  800838:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80083b:	3c 55                	cmp    $0x55,%al
  80083d:	0f 87 8b 05 00 00    	ja     800dce <vprintfmt+0x620>
  800843:	0f b6 c0             	movzbl %al,%eax
  800846:	49 bb 40 15 80 00 00 	movabs $0x801540,%r11
  80084d:	00 00 00 
  800850:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800854:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800857:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80085b:	eb d4                	jmp    800831 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80085d:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800860:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800864:	eb cb                	jmp    800831 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800866:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800869:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80086d:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800871:	8d 50 d0             	lea    -0x30(%rax),%edx
  800874:	83 fa 09             	cmp    $0x9,%edx
  800877:	77 7e                	ja     8008f7 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800879:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80087d:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800881:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800886:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80088a:	8d 50 d0             	lea    -0x30(%rax),%edx
  80088d:	83 fa 09             	cmp    $0x9,%edx
  800890:	76 e7                	jbe    800879 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800892:	4c 89 f3             	mov    %r14,%rbx
  800895:	eb 19                	jmp    8008b0 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800897:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089a:	83 f8 2f             	cmp    $0x2f,%eax
  80089d:	77 2a                	ja     8008c9 <vprintfmt+0x11b>
  80089f:	89 c2                	mov    %eax,%edx
  8008a1:	4c 01 d2             	add    %r10,%rdx
  8008a4:	83 c0 08             	add    $0x8,%eax
  8008a7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008aa:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008ad:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008b0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008b4:	0f 89 77 ff ff ff    	jns    800831 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008ba:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008be:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008c4:	e9 68 ff ff ff       	jmpq   800831 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008c9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008cd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008d5:	eb d3                	jmp    8008aa <vprintfmt+0xfc>
        if (width < 0)
  8008d7:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008e0:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008e3:	4c 89 f3             	mov    %r14,%rbx
  8008e6:	e9 46 ff ff ff       	jmpq   800831 <vprintfmt+0x83>
  8008eb:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8008ee:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8008f2:	e9 3a ff ff ff       	jmpq   800831 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008f7:	4c 89 f3             	mov    %r14,%rbx
  8008fa:	eb b4                	jmp    8008b0 <vprintfmt+0x102>
        lflag++;
  8008fc:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8008ff:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800902:	e9 2a ff ff ff       	jmpq   800831 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800907:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80090a:	83 f8 2f             	cmp    $0x2f,%eax
  80090d:	77 19                	ja     800928 <vprintfmt+0x17a>
  80090f:	89 c2                	mov    %eax,%edx
  800911:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800915:	83 c0 08             	add    $0x8,%eax
  800918:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80091b:	4c 89 fe             	mov    %r15,%rsi
  80091e:	8b 3a                	mov    (%rdx),%edi
  800920:	41 ff d5             	callq  *%r13
        break;
  800923:	e9 b0 fe ff ff       	jmpq   8007d8 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800928:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80092c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800930:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800934:	eb e5                	jmp    80091b <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800936:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800939:	83 f8 2f             	cmp    $0x2f,%eax
  80093c:	77 5b                	ja     800999 <vprintfmt+0x1eb>
  80093e:	89 c2                	mov    %eax,%edx
  800940:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800944:	83 c0 08             	add    $0x8,%eax
  800947:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80094a:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80094c:	89 c8                	mov    %ecx,%eax
  80094e:	c1 f8 1f             	sar    $0x1f,%eax
  800951:	31 c1                	xor    %eax,%ecx
  800953:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800955:	83 f9 0b             	cmp    $0xb,%ecx
  800958:	7f 4d                	jg     8009a7 <vprintfmt+0x1f9>
  80095a:	48 63 c1             	movslq %ecx,%rax
  80095d:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  800964:	00 00 00 
  800967:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80096b:	48 85 c0             	test   %rax,%rax
  80096e:	74 37                	je     8009a7 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800970:	48 89 c1             	mov    %rax,%rcx
  800973:	48 ba 8b 14 80 00 00 	movabs $0x80148b,%rdx
  80097a:	00 00 00 
  80097d:	4c 89 fe             	mov    %r15,%rsi
  800980:	4c 89 ef             	mov    %r13,%rdi
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
  800988:	48 bb 28 07 80 00 00 	movabs $0x800728,%rbx
  80098f:	00 00 00 
  800992:	ff d3                	callq  *%rbx
  800994:	e9 3f fe ff ff       	jmpq   8007d8 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800999:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80099d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009a5:	eb a3                	jmp    80094a <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009a7:	48 ba 82 14 80 00 00 	movabs $0x801482,%rdx
  8009ae:	00 00 00 
  8009b1:	4c 89 fe             	mov    %r15,%rsi
  8009b4:	4c 89 ef             	mov    %r13,%rdi
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bc:	48 bb 28 07 80 00 00 	movabs $0x800728,%rbx
  8009c3:	00 00 00 
  8009c6:	ff d3                	callq  *%rbx
  8009c8:	e9 0b fe ff ff       	jmpq   8007d8 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009cd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009d0:	83 f8 2f             	cmp    $0x2f,%eax
  8009d3:	77 4b                	ja     800a20 <vprintfmt+0x272>
  8009d5:	89 c2                	mov    %eax,%edx
  8009d7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009db:	83 c0 08             	add    $0x8,%eax
  8009de:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009e1:	48 8b 02             	mov    (%rdx),%rax
  8009e4:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009e8:	48 85 c0             	test   %rax,%rax
  8009eb:	0f 84 05 04 00 00    	je     800df6 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8009f1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009f5:	7e 06                	jle    8009fd <vprintfmt+0x24f>
  8009f7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009fb:	75 31                	jne    800a2e <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009fd:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a01:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a05:	0f b6 00             	movzbl (%rax),%eax
  800a08:	0f be f8             	movsbl %al,%edi
  800a0b:	85 ff                	test   %edi,%edi
  800a0d:	0f 84 c3 00 00 00    	je     800ad6 <vprintfmt+0x328>
  800a13:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a17:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a1b:	e9 85 00 00 00       	jmpq   800aa5 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a20:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a24:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a28:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a2c:	eb b3                	jmp    8009e1 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a2e:	49 63 f4             	movslq %r12d,%rsi
  800a31:	48 89 c7             	mov    %rax,%rdi
  800a34:	48 b8 85 0f 80 00 00 	movabs $0x800f85,%rax
  800a3b:	00 00 00 
  800a3e:	ff d0                	callq  *%rax
  800a40:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a43:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a46:	85 f6                	test   %esi,%esi
  800a48:	7e 22                	jle    800a6c <vprintfmt+0x2be>
            putch(padc, putdat);
  800a4a:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a4e:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a52:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a56:	4c 89 fe             	mov    %r15,%rsi
  800a59:	89 df                	mov    %ebx,%edi
  800a5b:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a5e:	41 83 ec 01          	sub    $0x1,%r12d
  800a62:	75 f2                	jne    800a56 <vprintfmt+0x2a8>
  800a64:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a68:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a70:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a74:	0f b6 00             	movzbl (%rax),%eax
  800a77:	0f be f8             	movsbl %al,%edi
  800a7a:	85 ff                	test   %edi,%edi
  800a7c:	0f 84 56 fd ff ff    	je     8007d8 <vprintfmt+0x2a>
  800a82:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a86:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a8a:	eb 19                	jmp    800aa5 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a8c:	4c 89 fe             	mov    %r15,%rsi
  800a8f:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a92:	41 83 ee 01          	sub    $0x1,%r14d
  800a96:	48 83 c3 01          	add    $0x1,%rbx
  800a9a:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800a9e:	0f be f8             	movsbl %al,%edi
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	74 29                	je     800ace <vprintfmt+0x320>
  800aa5:	45 85 e4             	test   %r12d,%r12d
  800aa8:	78 06                	js     800ab0 <vprintfmt+0x302>
  800aaa:	41 83 ec 01          	sub    $0x1,%r12d
  800aae:	78 48                	js     800af8 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800ab0:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800ab4:	74 d6                	je     800a8c <vprintfmt+0x2de>
  800ab6:	0f be c0             	movsbl %al,%eax
  800ab9:	83 e8 20             	sub    $0x20,%eax
  800abc:	83 f8 5e             	cmp    $0x5e,%eax
  800abf:	76 cb                	jbe    800a8c <vprintfmt+0x2de>
            putch('?', putdat);
  800ac1:	4c 89 fe             	mov    %r15,%rsi
  800ac4:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ac9:	41 ff d5             	callq  *%r13
  800acc:	eb c4                	jmp    800a92 <vprintfmt+0x2e4>
  800ace:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800ad2:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800ad6:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800ad9:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800add:	0f 8e f5 fc ff ff    	jle    8007d8 <vprintfmt+0x2a>
          putch(' ', putdat);
  800ae3:	4c 89 fe             	mov    %r15,%rsi
  800ae6:	bf 20 00 00 00       	mov    $0x20,%edi
  800aeb:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800aee:	83 eb 01             	sub    $0x1,%ebx
  800af1:	75 f0                	jne    800ae3 <vprintfmt+0x335>
  800af3:	e9 e0 fc ff ff       	jmpq   8007d8 <vprintfmt+0x2a>
  800af8:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800afc:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b00:	eb d4                	jmp    800ad6 <vprintfmt+0x328>
  if (lflag >= 2)
  800b02:	83 f9 01             	cmp    $0x1,%ecx
  800b05:	7f 1d                	jg     800b24 <vprintfmt+0x376>
  else if (lflag)
  800b07:	85 c9                	test   %ecx,%ecx
  800b09:	74 5e                	je     800b69 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b0b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b0e:	83 f8 2f             	cmp    $0x2f,%eax
  800b11:	77 48                	ja     800b5b <vprintfmt+0x3ad>
  800b13:	89 c2                	mov    %eax,%edx
  800b15:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b19:	83 c0 08             	add    $0x8,%eax
  800b1c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b1f:	48 8b 1a             	mov    (%rdx),%rbx
  800b22:	eb 17                	jmp    800b3b <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b24:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b27:	83 f8 2f             	cmp    $0x2f,%eax
  800b2a:	77 21                	ja     800b4d <vprintfmt+0x39f>
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b32:	83 c0 08             	add    $0x8,%eax
  800b35:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b38:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b3b:	48 85 db             	test   %rbx,%rbx
  800b3e:	78 50                	js     800b90 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b40:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b43:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b48:	e9 b4 01 00 00       	jmpq   800d01 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b4d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b51:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b55:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b59:	eb dd                	jmp    800b38 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b5b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b5f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b63:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b67:	eb b6                	jmp    800b1f <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b69:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b6c:	83 f8 2f             	cmp    $0x2f,%eax
  800b6f:	77 11                	ja     800b82 <vprintfmt+0x3d4>
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b77:	83 c0 08             	add    $0x8,%eax
  800b7a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b7d:	48 63 1a             	movslq (%rdx),%rbx
  800b80:	eb b9                	jmp    800b3b <vprintfmt+0x38d>
  800b82:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b86:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b8a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b8e:	eb ed                	jmp    800b7d <vprintfmt+0x3cf>
          putch('-', putdat);
  800b90:	4c 89 fe             	mov    %r15,%rsi
  800b93:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800b98:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800b9b:	48 89 da             	mov    %rbx,%rdx
  800b9e:	48 f7 da             	neg    %rdx
        base = 10;
  800ba1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba6:	e9 56 01 00 00       	jmpq   800d01 <vprintfmt+0x553>
  if (lflag >= 2)
  800bab:	83 f9 01             	cmp    $0x1,%ecx
  800bae:	7f 25                	jg     800bd5 <vprintfmt+0x427>
  else if (lflag)
  800bb0:	85 c9                	test   %ecx,%ecx
  800bb2:	74 5e                	je     800c12 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bb4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bb7:	83 f8 2f             	cmp    $0x2f,%eax
  800bba:	77 48                	ja     800c04 <vprintfmt+0x456>
  800bbc:	89 c2                	mov    %eax,%edx
  800bbe:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bc2:	83 c0 08             	add    $0x8,%eax
  800bc5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bc8:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bcb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bd0:	e9 2c 01 00 00       	jmpq   800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bd5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bd8:	83 f8 2f             	cmp    $0x2f,%eax
  800bdb:	77 19                	ja     800bf6 <vprintfmt+0x448>
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800be3:	83 c0 08             	add    $0x8,%eax
  800be6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800be9:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bf1:	e9 0b 01 00 00       	jmpq   800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bf6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bfa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bfe:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c02:	eb e5                	jmp    800be9 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c04:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c08:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c0c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c10:	eb b6                	jmp    800bc8 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c12:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c15:	83 f8 2f             	cmp    $0x2f,%eax
  800c18:	77 18                	ja     800c32 <vprintfmt+0x484>
  800c1a:	89 c2                	mov    %eax,%edx
  800c1c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c20:	83 c0 08             	add    $0x8,%eax
  800c23:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c26:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c28:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c2d:	e9 cf 00 00 00       	jmpq   800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c32:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c36:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c3a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c3e:	eb e6                	jmp    800c26 <vprintfmt+0x478>
  if (lflag >= 2)
  800c40:	83 f9 01             	cmp    $0x1,%ecx
  800c43:	7f 25                	jg     800c6a <vprintfmt+0x4bc>
  else if (lflag)
  800c45:	85 c9                	test   %ecx,%ecx
  800c47:	74 5b                	je     800ca4 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c49:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c4c:	83 f8 2f             	cmp    $0x2f,%eax
  800c4f:	77 45                	ja     800c96 <vprintfmt+0x4e8>
  800c51:	89 c2                	mov    %eax,%edx
  800c53:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c57:	83 c0 08             	add    $0x8,%eax
  800c5a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c5d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c60:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c65:	e9 97 00 00 00       	jmpq   800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c6a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c6d:	83 f8 2f             	cmp    $0x2f,%eax
  800c70:	77 16                	ja     800c88 <vprintfmt+0x4da>
  800c72:	89 c2                	mov    %eax,%edx
  800c74:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c78:	83 c0 08             	add    $0x8,%eax
  800c7b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c7e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c81:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c86:	eb 79                	jmp    800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c88:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c8c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c90:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c94:	eb e8                	jmp    800c7e <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800c96:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c9a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c9e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ca2:	eb b9                	jmp    800c5d <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800ca4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ca7:	83 f8 2f             	cmp    $0x2f,%eax
  800caa:	77 15                	ja     800cc1 <vprintfmt+0x513>
  800cac:	89 c2                	mov    %eax,%edx
  800cae:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cb2:	83 c0 08             	add    $0x8,%eax
  800cb5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cb8:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cba:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cbf:	eb 40                	jmp    800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cc1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cc5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cc9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ccd:	eb e9                	jmp    800cb8 <vprintfmt+0x50a>
        putch('0', putdat);
  800ccf:	4c 89 fe             	mov    %r15,%rsi
  800cd2:	bf 30 00 00 00       	mov    $0x30,%edi
  800cd7:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cda:	4c 89 fe             	mov    %r15,%rsi
  800cdd:	bf 78 00 00 00       	mov    $0x78,%edi
  800ce2:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800ce5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ce8:	83 f8 2f             	cmp    $0x2f,%eax
  800ceb:	77 34                	ja     800d21 <vprintfmt+0x573>
  800ced:	89 c2                	mov    %eax,%edx
  800cef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cf3:	83 c0 08             	add    $0x8,%eax
  800cf6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cf9:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800cfc:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d01:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d06:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d0a:	4c 89 fe             	mov    %r15,%rsi
  800d0d:	4c 89 ef             	mov    %r13,%rdi
  800d10:	48 b8 84 06 80 00 00 	movabs $0x800684,%rax
  800d17:	00 00 00 
  800d1a:	ff d0                	callq  *%rax
        break;
  800d1c:	e9 b7 fa ff ff       	jmpq   8007d8 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d21:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d25:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d29:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d2d:	eb ca                	jmp    800cf9 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d2f:	83 f9 01             	cmp    $0x1,%ecx
  800d32:	7f 22                	jg     800d56 <vprintfmt+0x5a8>
  else if (lflag)
  800d34:	85 c9                	test   %ecx,%ecx
  800d36:	74 58                	je     800d90 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d38:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d3b:	83 f8 2f             	cmp    $0x2f,%eax
  800d3e:	77 42                	ja     800d82 <vprintfmt+0x5d4>
  800d40:	89 c2                	mov    %eax,%edx
  800d42:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d46:	83 c0 08             	add    $0x8,%eax
  800d49:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d4c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d4f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d54:	eb ab                	jmp    800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d56:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d59:	83 f8 2f             	cmp    $0x2f,%eax
  800d5c:	77 16                	ja     800d74 <vprintfmt+0x5c6>
  800d5e:	89 c2                	mov    %eax,%edx
  800d60:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d64:	83 c0 08             	add    $0x8,%eax
  800d67:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d6a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d6d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d72:	eb 8d                	jmp    800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d74:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d78:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d7c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d80:	eb e8                	jmp    800d6a <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d82:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d86:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d8a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d8e:	eb bc                	jmp    800d4c <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800d90:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d93:	83 f8 2f             	cmp    $0x2f,%eax
  800d96:	77 18                	ja     800db0 <vprintfmt+0x602>
  800d98:	89 c2                	mov    %eax,%edx
  800d9a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d9e:	83 c0 08             	add    $0x8,%eax
  800da1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800da4:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800da6:	b9 10 00 00 00       	mov    $0x10,%ecx
  800dab:	e9 51 ff ff ff       	jmpq   800d01 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800db0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800db4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800db8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dbc:	eb e6                	jmp    800da4 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800dbe:	4c 89 fe             	mov    %r15,%rsi
  800dc1:	bf 25 00 00 00       	mov    $0x25,%edi
  800dc6:	41 ff d5             	callq  *%r13
        break;
  800dc9:	e9 0a fa ff ff       	jmpq   8007d8 <vprintfmt+0x2a>
        putch('%', putdat);
  800dce:	4c 89 fe             	mov    %r15,%rsi
  800dd1:	bf 25 00 00 00       	mov    $0x25,%edi
  800dd6:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800dd9:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800ddd:	0f 84 15 fa ff ff    	je     8007f8 <vprintfmt+0x4a>
  800de3:	49 89 de             	mov    %rbx,%r14
  800de6:	49 83 ee 01          	sub    $0x1,%r14
  800dea:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800def:	75 f5                	jne    800de6 <vprintfmt+0x638>
  800df1:	e9 e2 f9 ff ff       	jmpq   8007d8 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800df6:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800dfa:	74 06                	je     800e02 <vprintfmt+0x654>
  800dfc:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e00:	7f 21                	jg     800e23 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e02:	bf 28 00 00 00       	mov    $0x28,%edi
  800e07:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e0e:	00 00 00 
  800e11:	b8 28 00 00 00       	mov    $0x28,%eax
  800e16:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e1a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e1e:	e9 82 fc ff ff       	jmpq   800aa5 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e23:	49 63 f4             	movslq %r12d,%rsi
  800e26:	48 bf 7b 14 80 00 00 	movabs $0x80147b,%rdi
  800e2d:	00 00 00 
  800e30:	48 b8 85 0f 80 00 00 	movabs $0x800f85,%rax
  800e37:	00 00 00 
  800e3a:	ff d0                	callq  *%rax
  800e3c:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e3f:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e42:	48 be 7b 14 80 00 00 	movabs $0x80147b,%rsi
  800e49:	00 00 00 
  800e4c:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e50:	85 c0                	test   %eax,%eax
  800e52:	0f 8f f2 fb ff ff    	jg     800a4a <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e58:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e5f:	00 00 00 
  800e62:	b8 28 00 00 00       	mov    $0x28,%eax
  800e67:	bf 28 00 00 00       	mov    $0x28,%edi
  800e6c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e70:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e74:	e9 2c fc ff ff       	jmpq   800aa5 <vprintfmt+0x2f7>
}
  800e79:	48 83 c4 48          	add    $0x48,%rsp
  800e7d:	5b                   	pop    %rbx
  800e7e:	41 5c                	pop    %r12
  800e80:	41 5d                	pop    %r13
  800e82:	41 5e                	pop    %r14
  800e84:	41 5f                	pop    %r15
  800e86:	5d                   	pop    %rbp
  800e87:	c3                   	retq   

0000000000800e88 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e88:	55                   	push   %rbp
  800e89:	48 89 e5             	mov    %rsp,%rbp
  800e8c:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800e90:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800e94:	48 63 c6             	movslq %esi,%rax
  800e97:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800e9c:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800ea0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ea7:	48 85 ff             	test   %rdi,%rdi
  800eaa:	74 2a                	je     800ed6 <vsnprintf+0x4e>
  800eac:	85 f6                	test   %esi,%esi
  800eae:	7e 26                	jle    800ed6 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800eb0:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800eb4:	48 bf 10 07 80 00 00 	movabs $0x800710,%rdi
  800ebb:	00 00 00 
  800ebe:	48 b8 ae 07 80 00 00 	movabs $0x8007ae,%rax
  800ec5:	00 00 00 
  800ec8:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800eca:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ece:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ed1:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ed4:	c9                   	leaveq 
  800ed5:	c3                   	retq   
    return -E_INVAL;
  800ed6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edb:	eb f7                	jmp    800ed4 <vsnprintf+0x4c>

0000000000800edd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800edd:	55                   	push   %rbp
  800ede:	48 89 e5             	mov    %rsp,%rbp
  800ee1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ee8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800eef:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ef6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800efd:	84 c0                	test   %al,%al
  800eff:	74 20                	je     800f21 <snprintf+0x44>
  800f01:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f05:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f09:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f0d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f11:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f15:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f19:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f1d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f21:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f28:	00 00 00 
  800f2b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f32:	00 00 00 
  800f35:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f39:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f40:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f47:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f4e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f55:	48 b8 88 0e 80 00 00 	movabs $0x800e88,%rax
  800f5c:	00 00 00 
  800f5f:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f61:	c9                   	leaveq 
  800f62:	c3                   	retq   

0000000000800f63 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f63:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f66:	74 17                	je     800f7f <strlen+0x1c>
  800f68:	48 89 fa             	mov    %rdi,%rdx
  800f6b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f70:	29 f9                	sub    %edi,%ecx
    n++;
  800f72:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f75:	48 83 c2 01          	add    $0x1,%rdx
  800f79:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f7c:	75 f4                	jne    800f72 <strlen+0xf>
  800f7e:	c3                   	retq   
  800f7f:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f84:	c3                   	retq   

0000000000800f85 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f85:	48 85 f6             	test   %rsi,%rsi
  800f88:	74 24                	je     800fae <strnlen+0x29>
  800f8a:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f8d:	74 25                	je     800fb4 <strnlen+0x2f>
  800f8f:	48 01 fe             	add    %rdi,%rsi
  800f92:	48 89 fa             	mov    %rdi,%rdx
  800f95:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f9a:	29 f9                	sub    %edi,%ecx
    n++;
  800f9c:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9f:	48 83 c2 01          	add    $0x1,%rdx
  800fa3:	48 39 f2             	cmp    %rsi,%rdx
  800fa6:	74 11                	je     800fb9 <strnlen+0x34>
  800fa8:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fab:	75 ef                	jne    800f9c <strnlen+0x17>
  800fad:	c3                   	retq   
  800fae:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb3:	c3                   	retq   
  800fb4:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fb9:	c3                   	retq   

0000000000800fba <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fba:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fc6:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fc9:	48 83 c2 01          	add    $0x1,%rdx
  800fcd:	84 c9                	test   %cl,%cl
  800fcf:	75 f1                	jne    800fc2 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fd1:	c3                   	retq   

0000000000800fd2 <strcat>:

char *
strcat(char *dst, const char *src) {
  800fd2:	55                   	push   %rbp
  800fd3:	48 89 e5             	mov    %rsp,%rbp
  800fd6:	41 54                	push   %r12
  800fd8:	53                   	push   %rbx
  800fd9:	48 89 fb             	mov    %rdi,%rbx
  800fdc:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800fdf:	48 b8 63 0f 80 00 00 	movabs $0x800f63,%rax
  800fe6:	00 00 00 
  800fe9:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800feb:	48 63 f8             	movslq %eax,%rdi
  800fee:	48 01 df             	add    %rbx,%rdi
  800ff1:	4c 89 e6             	mov    %r12,%rsi
  800ff4:	48 b8 ba 0f 80 00 00 	movabs $0x800fba,%rax
  800ffb:	00 00 00 
  800ffe:	ff d0                	callq  *%rax
  return dst;
}
  801000:	48 89 d8             	mov    %rbx,%rax
  801003:	5b                   	pop    %rbx
  801004:	41 5c                	pop    %r12
  801006:	5d                   	pop    %rbp
  801007:	c3                   	retq   

0000000000801008 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801008:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  80100b:	48 85 d2             	test   %rdx,%rdx
  80100e:	74 1f                	je     80102f <strncpy+0x27>
  801010:	48 01 fa             	add    %rdi,%rdx
  801013:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  801016:	48 83 c1 01          	add    $0x1,%rcx
  80101a:	44 0f b6 06          	movzbl (%rsi),%r8d
  80101e:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801022:	41 80 f8 01          	cmp    $0x1,%r8b
  801026:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  80102a:	48 39 ca             	cmp    %rcx,%rdx
  80102d:	75 e7                	jne    801016 <strncpy+0xe>
  }
  return ret;
}
  80102f:	c3                   	retq   

0000000000801030 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801030:	48 89 f8             	mov    %rdi,%rax
  801033:	48 85 d2             	test   %rdx,%rdx
  801036:	74 36                	je     80106e <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  801038:	48 83 fa 01          	cmp    $0x1,%rdx
  80103c:	74 2d                	je     80106b <strlcpy+0x3b>
  80103e:	44 0f b6 06          	movzbl (%rsi),%r8d
  801042:	45 84 c0             	test   %r8b,%r8b
  801045:	74 24                	je     80106b <strlcpy+0x3b>
  801047:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  80104b:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801050:	48 83 c0 01          	add    $0x1,%rax
  801054:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  801058:	48 39 d1             	cmp    %rdx,%rcx
  80105b:	74 0e                	je     80106b <strlcpy+0x3b>
  80105d:	48 83 c1 01          	add    $0x1,%rcx
  801061:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  801066:	45 84 c0             	test   %r8b,%r8b
  801069:	75 e5                	jne    801050 <strlcpy+0x20>
    *dst = '\0';
  80106b:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  80106e:	48 29 f8             	sub    %rdi,%rax
}
  801071:	c3                   	retq   

0000000000801072 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801072:	0f b6 07             	movzbl (%rdi),%eax
  801075:	84 c0                	test   %al,%al
  801077:	74 17                	je     801090 <strcmp+0x1e>
  801079:	3a 06                	cmp    (%rsi),%al
  80107b:	75 13                	jne    801090 <strcmp+0x1e>
    p++, q++;
  80107d:	48 83 c7 01          	add    $0x1,%rdi
  801081:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  801085:	0f b6 07             	movzbl (%rdi),%eax
  801088:	84 c0                	test   %al,%al
  80108a:	74 04                	je     801090 <strcmp+0x1e>
  80108c:	3a 06                	cmp    (%rsi),%al
  80108e:	74 ed                	je     80107d <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  801090:	0f b6 c0             	movzbl %al,%eax
  801093:	0f b6 16             	movzbl (%rsi),%edx
  801096:	29 d0                	sub    %edx,%eax
}
  801098:	c3                   	retq   

0000000000801099 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  801099:	48 85 d2             	test   %rdx,%rdx
  80109c:	74 2f                	je     8010cd <strncmp+0x34>
  80109e:	0f b6 07             	movzbl (%rdi),%eax
  8010a1:	84 c0                	test   %al,%al
  8010a3:	74 1f                	je     8010c4 <strncmp+0x2b>
  8010a5:	3a 06                	cmp    (%rsi),%al
  8010a7:	75 1b                	jne    8010c4 <strncmp+0x2b>
  8010a9:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010ac:	48 83 c7 01          	add    $0x1,%rdi
  8010b0:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010b4:	48 39 d7             	cmp    %rdx,%rdi
  8010b7:	74 1a                	je     8010d3 <strncmp+0x3a>
  8010b9:	0f b6 07             	movzbl (%rdi),%eax
  8010bc:	84 c0                	test   %al,%al
  8010be:	74 04                	je     8010c4 <strncmp+0x2b>
  8010c0:	3a 06                	cmp    (%rsi),%al
  8010c2:	74 e8                	je     8010ac <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010c4:	0f b6 07             	movzbl (%rdi),%eax
  8010c7:	0f b6 16             	movzbl (%rsi),%edx
  8010ca:	29 d0                	sub    %edx,%eax
}
  8010cc:	c3                   	retq   
    return 0;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d2:	c3                   	retq   
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d8:	c3                   	retq   

00000000008010d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010d9:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010db:	0f b6 07             	movzbl (%rdi),%eax
  8010de:	84 c0                	test   %al,%al
  8010e0:	74 1e                	je     801100 <strchr+0x27>
    if (*s == c)
  8010e2:	40 38 c6             	cmp    %al,%sil
  8010e5:	74 1f                	je     801106 <strchr+0x2d>
  for (; *s; s++)
  8010e7:	48 83 c7 01          	add    $0x1,%rdi
  8010eb:	0f b6 07             	movzbl (%rdi),%eax
  8010ee:	84 c0                	test   %al,%al
  8010f0:	74 08                	je     8010fa <strchr+0x21>
    if (*s == c)
  8010f2:	38 d0                	cmp    %dl,%al
  8010f4:	75 f1                	jne    8010e7 <strchr+0xe>
  for (; *s; s++)
  8010f6:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8010f9:	c3                   	retq   
  return 0;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ff:	c3                   	retq   
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	c3                   	retq   
    if (*s == c)
  801106:	48 89 f8             	mov    %rdi,%rax
  801109:	c3                   	retq   

000000000080110a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  80110a:	48 89 f8             	mov    %rdi,%rax
  80110d:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  80110f:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801112:	40 38 f2             	cmp    %sil,%dl
  801115:	74 13                	je     80112a <strfind+0x20>
  801117:	84 d2                	test   %dl,%dl
  801119:	74 0f                	je     80112a <strfind+0x20>
  for (; *s; s++)
  80111b:	48 83 c0 01          	add    $0x1,%rax
  80111f:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801122:	38 ca                	cmp    %cl,%dl
  801124:	74 04                	je     80112a <strfind+0x20>
  801126:	84 d2                	test   %dl,%dl
  801128:	75 f1                	jne    80111b <strfind+0x11>
      break;
  return (char *)s;
}
  80112a:	c3                   	retq   

000000000080112b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  80112b:	48 85 d2             	test   %rdx,%rdx
  80112e:	74 3a                	je     80116a <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801130:	48 89 f8             	mov    %rdi,%rax
  801133:	48 09 d0             	or     %rdx,%rax
  801136:	a8 03                	test   $0x3,%al
  801138:	75 28                	jne    801162 <memset+0x37>
    uint32_t k = c & 0xFFU;
  80113a:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  80113e:	89 f0                	mov    %esi,%eax
  801140:	c1 e0 08             	shl    $0x8,%eax
  801143:	89 f1                	mov    %esi,%ecx
  801145:	c1 e1 18             	shl    $0x18,%ecx
  801148:	41 89 f0             	mov    %esi,%r8d
  80114b:	41 c1 e0 10          	shl    $0x10,%r8d
  80114f:	44 09 c1             	or     %r8d,%ecx
  801152:	09 ce                	or     %ecx,%esi
  801154:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  801156:	48 c1 ea 02          	shr    $0x2,%rdx
  80115a:	48 89 d1             	mov    %rdx,%rcx
  80115d:	fc                   	cld    
  80115e:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801160:	eb 08                	jmp    80116a <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801162:	89 f0                	mov    %esi,%eax
  801164:	48 89 d1             	mov    %rdx,%rcx
  801167:	fc                   	cld    
  801168:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  80116a:	48 89 f8             	mov    %rdi,%rax
  80116d:	c3                   	retq   

000000000080116e <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  80116e:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801171:	48 39 fe             	cmp    %rdi,%rsi
  801174:	73 40                	jae    8011b6 <memmove+0x48>
  801176:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  80117a:	48 39 f9             	cmp    %rdi,%rcx
  80117d:	76 37                	jbe    8011b6 <memmove+0x48>
    s += n;
    d += n;
  80117f:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801183:	48 89 fe             	mov    %rdi,%rsi
  801186:	48 09 d6             	or     %rdx,%rsi
  801189:	48 09 ce             	or     %rcx,%rsi
  80118c:	40 f6 c6 03          	test   $0x3,%sil
  801190:	75 14                	jne    8011a6 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  801192:	48 83 ef 04          	sub    $0x4,%rdi
  801196:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  80119a:	48 c1 ea 02          	shr    $0x2,%rdx
  80119e:	48 89 d1             	mov    %rdx,%rcx
  8011a1:	fd                   	std    
  8011a2:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011a4:	eb 0e                	jmp    8011b4 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011a6:	48 83 ef 01          	sub    $0x1,%rdi
  8011aa:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011ae:	48 89 d1             	mov    %rdx,%rcx
  8011b1:	fd                   	std    
  8011b2:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011b4:	fc                   	cld    
  8011b5:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011b6:	48 89 c1             	mov    %rax,%rcx
  8011b9:	48 09 d1             	or     %rdx,%rcx
  8011bc:	48 09 f1             	or     %rsi,%rcx
  8011bf:	f6 c1 03             	test   $0x3,%cl
  8011c2:	75 0e                	jne    8011d2 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011c4:	48 c1 ea 02          	shr    $0x2,%rdx
  8011c8:	48 89 d1             	mov    %rdx,%rcx
  8011cb:	48 89 c7             	mov    %rax,%rdi
  8011ce:	fc                   	cld    
  8011cf:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011d1:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011d2:	48 89 c7             	mov    %rax,%rdi
  8011d5:	48 89 d1             	mov    %rdx,%rcx
  8011d8:	fc                   	cld    
  8011d9:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011db:	c3                   	retq   

00000000008011dc <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011dc:	55                   	push   %rbp
  8011dd:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011e0:	48 b8 6e 11 80 00 00 	movabs $0x80116e,%rax
  8011e7:	00 00 00 
  8011ea:	ff d0                	callq  *%rax
}
  8011ec:	5d                   	pop    %rbp
  8011ed:	c3                   	retq   

00000000008011ee <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8011ee:	55                   	push   %rbp
  8011ef:	48 89 e5             	mov    %rsp,%rbp
  8011f2:	41 57                	push   %r15
  8011f4:	41 56                	push   %r14
  8011f6:	41 55                	push   %r13
  8011f8:	41 54                	push   %r12
  8011fa:	53                   	push   %rbx
  8011fb:	48 83 ec 08          	sub    $0x8,%rsp
  8011ff:	49 89 fe             	mov    %rdi,%r14
  801202:	49 89 f7             	mov    %rsi,%r15
  801205:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801208:	48 89 f7             	mov    %rsi,%rdi
  80120b:	48 b8 63 0f 80 00 00 	movabs $0x800f63,%rax
  801212:	00 00 00 
  801215:	ff d0                	callq  *%rax
  801217:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  80121a:	4c 89 ee             	mov    %r13,%rsi
  80121d:	4c 89 f7             	mov    %r14,%rdi
  801220:	48 b8 85 0f 80 00 00 	movabs $0x800f85,%rax
  801227:	00 00 00 
  80122a:	ff d0                	callq  *%rax
  80122c:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80122f:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801233:	4d 39 e5             	cmp    %r12,%r13
  801236:	74 26                	je     80125e <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801238:	4c 89 e8             	mov    %r13,%rax
  80123b:	4c 29 e0             	sub    %r12,%rax
  80123e:	48 39 d8             	cmp    %rbx,%rax
  801241:	76 2a                	jbe    80126d <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801243:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801247:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80124b:	4c 89 fe             	mov    %r15,%rsi
  80124e:	48 b8 dc 11 80 00 00 	movabs $0x8011dc,%rax
  801255:	00 00 00 
  801258:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80125a:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  80125e:	48 83 c4 08          	add    $0x8,%rsp
  801262:	5b                   	pop    %rbx
  801263:	41 5c                	pop    %r12
  801265:	41 5d                	pop    %r13
  801267:	41 5e                	pop    %r14
  801269:	41 5f                	pop    %r15
  80126b:	5d                   	pop    %rbp
  80126c:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80126d:	49 83 ed 01          	sub    $0x1,%r13
  801271:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801275:	4c 89 ea             	mov    %r13,%rdx
  801278:	4c 89 fe             	mov    %r15,%rsi
  80127b:	48 b8 dc 11 80 00 00 	movabs $0x8011dc,%rax
  801282:	00 00 00 
  801285:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801287:	4d 01 ee             	add    %r13,%r14
  80128a:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80128f:	eb c9                	jmp    80125a <strlcat+0x6c>

0000000000801291 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801291:	48 85 d2             	test   %rdx,%rdx
  801294:	74 3a                	je     8012d0 <memcmp+0x3f>
    if (*s1 != *s2)
  801296:	0f b6 0f             	movzbl (%rdi),%ecx
  801299:	44 0f b6 06          	movzbl (%rsi),%r8d
  80129d:	44 38 c1             	cmp    %r8b,%cl
  8012a0:	75 1d                	jne    8012bf <memcmp+0x2e>
  8012a2:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012a7:	48 39 d0             	cmp    %rdx,%rax
  8012aa:	74 1e                	je     8012ca <memcmp+0x39>
    if (*s1 != *s2)
  8012ac:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012b0:	48 83 c0 01          	add    $0x1,%rax
  8012b4:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012ba:	44 38 c1             	cmp    %r8b,%cl
  8012bd:	74 e8                	je     8012a7 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012bf:	0f b6 c1             	movzbl %cl,%eax
  8012c2:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012c6:	44 29 c0             	sub    %r8d,%eax
  8012c9:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cf:	c3                   	retq   
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d5:	c3                   	retq   

00000000008012d6 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012d6:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012da:	48 39 c7             	cmp    %rax,%rdi
  8012dd:	73 19                	jae    8012f8 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012df:	89 f2                	mov    %esi,%edx
  8012e1:	40 38 37             	cmp    %sil,(%rdi)
  8012e4:	74 16                	je     8012fc <memfind+0x26>
  for (; s < ends; s++)
  8012e6:	48 83 c7 01          	add    $0x1,%rdi
  8012ea:	48 39 f8             	cmp    %rdi,%rax
  8012ed:	74 08                	je     8012f7 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012ef:	38 17                	cmp    %dl,(%rdi)
  8012f1:	75 f3                	jne    8012e6 <memfind+0x10>
  for (; s < ends; s++)
  8012f3:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8012f6:	c3                   	retq   
  8012f7:	c3                   	retq   
  for (; s < ends; s++)
  8012f8:	48 89 f8             	mov    %rdi,%rax
  8012fb:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8012fc:	48 89 f8             	mov    %rdi,%rax
  8012ff:	c3                   	retq   

0000000000801300 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801300:	0f b6 07             	movzbl (%rdi),%eax
  801303:	3c 20                	cmp    $0x20,%al
  801305:	74 04                	je     80130b <strtol+0xb>
  801307:	3c 09                	cmp    $0x9,%al
  801309:	75 0f                	jne    80131a <strtol+0x1a>
    s++;
  80130b:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80130f:	0f b6 07             	movzbl (%rdi),%eax
  801312:	3c 20                	cmp    $0x20,%al
  801314:	74 f5                	je     80130b <strtol+0xb>
  801316:	3c 09                	cmp    $0x9,%al
  801318:	74 f1                	je     80130b <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80131a:	3c 2b                	cmp    $0x2b,%al
  80131c:	74 2b                	je     801349 <strtol+0x49>
  int neg  = 0;
  80131e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801324:	3c 2d                	cmp    $0x2d,%al
  801326:	74 2d                	je     801355 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801328:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80132e:	75 0f                	jne    80133f <strtol+0x3f>
  801330:	80 3f 30             	cmpb   $0x30,(%rdi)
  801333:	74 2c                	je     801361 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801335:	85 d2                	test   %edx,%edx
  801337:	b8 0a 00 00 00       	mov    $0xa,%eax
  80133c:	0f 44 d0             	cmove  %eax,%edx
  80133f:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801344:	4c 63 d2             	movslq %edx,%r10
  801347:	eb 5c                	jmp    8013a5 <strtol+0xa5>
    s++;
  801349:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80134d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801353:	eb d3                	jmp    801328 <strtol+0x28>
    s++, neg = 1;
  801355:	48 83 c7 01          	add    $0x1,%rdi
  801359:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80135f:	eb c7                	jmp    801328 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801361:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801365:	74 0f                	je     801376 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801367:	85 d2                	test   %edx,%edx
  801369:	75 d4                	jne    80133f <strtol+0x3f>
    s++, base = 8;
  80136b:	48 83 c7 01          	add    $0x1,%rdi
  80136f:	ba 08 00 00 00       	mov    $0x8,%edx
  801374:	eb c9                	jmp    80133f <strtol+0x3f>
    s += 2, base = 16;
  801376:	48 83 c7 02          	add    $0x2,%rdi
  80137a:	ba 10 00 00 00       	mov    $0x10,%edx
  80137f:	eb be                	jmp    80133f <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801381:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801385:	41 80 f8 19          	cmp    $0x19,%r8b
  801389:	77 2f                	ja     8013ba <strtol+0xba>
      dig = *s - 'a' + 10;
  80138b:	44 0f be c1          	movsbl %cl,%r8d
  80138f:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801393:	39 d1                	cmp    %edx,%ecx
  801395:	7d 37                	jge    8013ce <strtol+0xce>
    s++, val = (val * base) + dig;
  801397:	48 83 c7 01          	add    $0x1,%rdi
  80139b:	49 0f af c2          	imul   %r10,%rax
  80139f:	48 63 c9             	movslq %ecx,%rcx
  8013a2:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013a5:	0f b6 0f             	movzbl (%rdi),%ecx
  8013a8:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013ac:	41 80 f8 09          	cmp    $0x9,%r8b
  8013b0:	77 cf                	ja     801381 <strtol+0x81>
      dig = *s - '0';
  8013b2:	0f be c9             	movsbl %cl,%ecx
  8013b5:	83 e9 30             	sub    $0x30,%ecx
  8013b8:	eb d9                	jmp    801393 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013ba:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013be:	41 80 f8 19          	cmp    $0x19,%r8b
  8013c2:	77 0a                	ja     8013ce <strtol+0xce>
      dig = *s - 'A' + 10;
  8013c4:	44 0f be c1          	movsbl %cl,%r8d
  8013c8:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013cc:	eb c5                	jmp    801393 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013ce:	48 85 f6             	test   %rsi,%rsi
  8013d1:	74 03                	je     8013d6 <strtol+0xd6>
    *endptr = (char *)s;
  8013d3:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013d6:	48 89 c2             	mov    %rax,%rdx
  8013d9:	48 f7 da             	neg    %rdx
  8013dc:	45 85 c9             	test   %r9d,%r9d
  8013df:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013e3:	c3                   	retq   
