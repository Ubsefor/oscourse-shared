
obj/user/breakpoint:     file format elf64-x86-64


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
  800023:	e8 04 00 00 00       	callq  80002c <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  asm volatile("int $3");
  80002a:	cc                   	int3   
}
  80002b:	c3                   	retq   

000000000080002c <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80002c:	55                   	push   %rbp
  80002d:	48 89 e5             	mov    %rsp,%rbp
  800030:	41 56                	push   %r14
  800032:	41 55                	push   %r13
  800034:	41 54                	push   %r12
  800036:	53                   	push   %rbx
  800037:	41 89 fd             	mov    %edi,%r13d
  80003a:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80003d:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800044:	00 00 00 
  800047:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80004e:	00 00 00 
  800051:	48 39 c2             	cmp    %rax,%rdx
  800054:	73 23                	jae    800079 <libmain+0x4d>
  800056:	48 89 d3             	mov    %rdx,%rbx
  800059:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80005d:	48 29 d0             	sub    %rdx,%rax
  800060:	48 c1 e8 03          	shr    $0x3,%rax
  800064:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
  80006e:	ff 13                	callq  *(%rbx)
    ctor++;
  800070:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800074:	4c 39 e3             	cmp    %r12,%rbx
  800077:	75 f0                	jne    800069 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800079:	48 b8 97 01 80 00 00 	movabs $0x800197,%rax
  800080:	00 00 00 
  800083:	ff d0                	callq  *%rax
  800085:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008a:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80008e:	48 c1 e0 05          	shl    $0x5,%rax
  800092:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800099:	00 00 00 
  80009c:	48 01 d0             	add    %rdx,%rax
  80009f:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000a6:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000a9:	45 85 ed             	test   %r13d,%r13d
  8000ac:	7e 0d                	jle    8000bb <libmain+0x8f>
    binaryname = argv[0];
  8000ae:	49 8b 06             	mov    (%r14),%rax
  8000b1:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000b8:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000bb:	4c 89 f6             	mov    %r14,%rsi
  8000be:	44 89 ef             	mov    %r13d,%edi
  8000c1:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000c8:	00 00 00 
  8000cb:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000cd:	48 b8 e2 00 80 00 00 	movabs $0x8000e2,%rax
  8000d4:	00 00 00 
  8000d7:	ff d0                	callq  *%rax
#endif
}
  8000d9:	5b                   	pop    %rbx
  8000da:	41 5c                	pop    %r12
  8000dc:	41 5d                	pop    %r13
  8000de:	41 5e                	pop    %r14
  8000e0:	5d                   	pop    %rbp
  8000e1:	c3                   	retq   

00000000008000e2 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000e2:	55                   	push   %rbp
  8000e3:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8000eb:	48 b8 37 01 80 00 00 	movabs $0x800137,%rax
  8000f2:	00 00 00 
  8000f5:	ff d0                	callq  *%rax
}
  8000f7:	5d                   	pop    %rbp
  8000f8:	c3                   	retq   

00000000008000f9 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8000f9:	55                   	push   %rbp
  8000fa:	48 89 e5             	mov    %rsp,%rbp
  8000fd:	53                   	push   %rbx
  8000fe:	48 89 fa             	mov    %rdi,%rdx
  800101:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800104:	b8 00 00 00 00       	mov    $0x0,%eax
  800109:	48 89 c3             	mov    %rax,%rbx
  80010c:	48 89 c7             	mov    %rax,%rdi
  80010f:	48 89 c6             	mov    %rax,%rsi
  800112:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800114:	5b                   	pop    %rbx
  800115:	5d                   	pop    %rbp
  800116:	c3                   	retq   

0000000000800117 <sys_cgetc>:

int
sys_cgetc(void) {
  800117:	55                   	push   %rbp
  800118:	48 89 e5             	mov    %rsp,%rbp
  80011b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	b8 01 00 00 00       	mov    $0x1,%eax
  800126:	48 89 ca             	mov    %rcx,%rdx
  800129:	48 89 cb             	mov    %rcx,%rbx
  80012c:	48 89 cf             	mov    %rcx,%rdi
  80012f:	48 89 ce             	mov    %rcx,%rsi
  800132:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800134:	5b                   	pop    %rbx
  800135:	5d                   	pop    %rbp
  800136:	c3                   	retq   

0000000000800137 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800137:	55                   	push   %rbp
  800138:	48 89 e5             	mov    %rsp,%rbp
  80013b:	53                   	push   %rbx
  80013c:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800140:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800143:	be 00 00 00 00       	mov    $0x0,%esi
  800148:	b8 03 00 00 00       	mov    $0x3,%eax
  80014d:	48 89 f1             	mov    %rsi,%rcx
  800150:	48 89 f3             	mov    %rsi,%rbx
  800153:	48 89 f7             	mov    %rsi,%rdi
  800156:	cd 30                	int    $0x30
  if (check && ret > 0)
  800158:	48 85 c0             	test   %rax,%rax
  80015b:	7f 07                	jg     800164 <sys_env_destroy+0x2d>
}
  80015d:	48 83 c4 08          	add    $0x8,%rsp
  800161:	5b                   	pop    %rbx
  800162:	5d                   	pop    %rbp
  800163:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800164:	49 89 c0             	mov    %rax,%r8
  800167:	b9 03 00 00 00       	mov    $0x3,%ecx
  80016c:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800173:	00 00 00 
  800176:	be 22 00 00 00       	mov    $0x22,%esi
  80017b:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800182:	00 00 00 
  800185:	b8 00 00 00 00       	mov    $0x0,%eax
  80018a:	49 b9 44 04 80 00 00 	movabs $0x800444,%r9
  800191:	00 00 00 
  800194:	41 ff d1             	callq  *%r9

0000000000800197 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  800197:	55                   	push   %rbp
  800198:	48 89 e5             	mov    %rsp,%rbp
  80019b:	53                   	push   %rbx
  asm volatile("int %1\n"
  80019c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a6:	48 89 ca             	mov    %rcx,%rdx
  8001a9:	48 89 cb             	mov    %rcx,%rbx
  8001ac:	48 89 cf             	mov    %rcx,%rdi
  8001af:	48 89 ce             	mov    %rcx,%rsi
  8001b2:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001b4:	5b                   	pop    %rbx
  8001b5:	5d                   	pop    %rbp
  8001b6:	c3                   	retq   

00000000008001b7 <sys_yield>:

void
sys_yield(void) {
  8001b7:	55                   	push   %rbp
  8001b8:	48 89 e5             	mov    %rsp,%rbp
  8001bb:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001c6:	48 89 ca             	mov    %rcx,%rdx
  8001c9:	48 89 cb             	mov    %rcx,%rbx
  8001cc:	48 89 cf             	mov    %rcx,%rdi
  8001cf:	48 89 ce             	mov    %rcx,%rsi
  8001d2:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001d4:	5b                   	pop    %rbx
  8001d5:	5d                   	pop    %rbp
  8001d6:	c3                   	retq   

00000000008001d7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001d7:	55                   	push   %rbp
  8001d8:	48 89 e5             	mov    %rsp,%rbp
  8001db:	53                   	push   %rbx
  8001dc:	48 83 ec 08          	sub    $0x8,%rsp
  8001e0:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8001e3:	4c 63 c7             	movslq %edi,%r8
  8001e6:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8001e9:	be 00 00 00 00       	mov    $0x0,%esi
  8001ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f3:	4c 89 c2             	mov    %r8,%rdx
  8001f6:	48 89 f7             	mov    %rsi,%rdi
  8001f9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8001fb:	48 85 c0             	test   %rax,%rax
  8001fe:	7f 07                	jg     800207 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  800200:	48 83 c4 08          	add    $0x8,%rsp
  800204:	5b                   	pop    %rbx
  800205:	5d                   	pop    %rbp
  800206:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800207:	49 89 c0             	mov    %rax,%r8
  80020a:	b9 04 00 00 00       	mov    $0x4,%ecx
  80020f:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800216:	00 00 00 
  800219:	be 22 00 00 00       	mov    $0x22,%esi
  80021e:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  800225:	00 00 00 
  800228:	b8 00 00 00 00       	mov    $0x0,%eax
  80022d:	49 b9 44 04 80 00 00 	movabs $0x800444,%r9
  800234:	00 00 00 
  800237:	41 ff d1             	callq  *%r9

000000000080023a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80023a:	55                   	push   %rbp
  80023b:	48 89 e5             	mov    %rsp,%rbp
  80023e:	53                   	push   %rbx
  80023f:	48 83 ec 08          	sub    $0x8,%rsp
  800243:	41 89 f9             	mov    %edi,%r9d
  800246:	49 89 f2             	mov    %rsi,%r10
  800249:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80024c:	4d 63 c9             	movslq %r9d,%r9
  80024f:	48 63 da             	movslq %edx,%rbx
  800252:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  800255:	b8 05 00 00 00       	mov    $0x5,%eax
  80025a:	4c 89 ca             	mov    %r9,%rdx
  80025d:	4c 89 d1             	mov    %r10,%rcx
  800260:	cd 30                	int    $0x30
  if (check && ret > 0)
  800262:	48 85 c0             	test   %rax,%rax
  800265:	7f 07                	jg     80026e <sys_page_map+0x34>
}
  800267:	48 83 c4 08          	add    $0x8,%rsp
  80026b:	5b                   	pop    %rbx
  80026c:	5d                   	pop    %rbp
  80026d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80026e:	49 89 c0             	mov    %rax,%r8
  800271:	b9 05 00 00 00       	mov    $0x5,%ecx
  800276:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  80027d:	00 00 00 
  800280:	be 22 00 00 00       	mov    $0x22,%esi
  800285:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  80028c:	00 00 00 
  80028f:	b8 00 00 00 00       	mov    $0x0,%eax
  800294:	49 b9 44 04 80 00 00 	movabs $0x800444,%r9
  80029b:	00 00 00 
  80029e:	41 ff d1             	callq  *%r9

00000000008002a1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002a1:	55                   	push   %rbp
  8002a2:	48 89 e5             	mov    %rsp,%rbp
  8002a5:	53                   	push   %rbx
  8002a6:	48 83 ec 08          	sub    $0x8,%rsp
  8002aa:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002ad:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002b0:	be 00 00 00 00       	mov    $0x0,%esi
  8002b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8002ba:	48 89 f3             	mov    %rsi,%rbx
  8002bd:	48 89 f7             	mov    %rsi,%rdi
  8002c0:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002c2:	48 85 c0             	test   %rax,%rax
  8002c5:	7f 07                	jg     8002ce <sys_page_unmap+0x2d>
}
  8002c7:	48 83 c4 08          	add    $0x8,%rsp
  8002cb:	5b                   	pop    %rbx
  8002cc:	5d                   	pop    %rbp
  8002cd:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002ce:	49 89 c0             	mov    %rax,%r8
  8002d1:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002d6:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  8002dd:	00 00 00 
  8002e0:	be 22 00 00 00       	mov    $0x22,%esi
  8002e5:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  8002ec:	00 00 00 
  8002ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f4:	49 b9 44 04 80 00 00 	movabs $0x800444,%r9
  8002fb:	00 00 00 
  8002fe:	41 ff d1             	callq  *%r9

0000000000800301 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  800301:	55                   	push   %rbp
  800302:	48 89 e5             	mov    %rsp,%rbp
  800305:	53                   	push   %rbx
  800306:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80030a:	48 63 d7             	movslq %edi,%rdx
  80030d:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  800310:	bb 00 00 00 00       	mov    $0x0,%ebx
  800315:	b8 08 00 00 00       	mov    $0x8,%eax
  80031a:	48 89 df             	mov    %rbx,%rdi
  80031d:	48 89 de             	mov    %rbx,%rsi
  800320:	cd 30                	int    $0x30
  if (check && ret > 0)
  800322:	48 85 c0             	test   %rax,%rax
  800325:	7f 07                	jg     80032e <sys_env_set_status+0x2d>
}
  800327:	48 83 c4 08          	add    $0x8,%rsp
  80032b:	5b                   	pop    %rbx
  80032c:	5d                   	pop    %rbp
  80032d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80032e:	49 89 c0             	mov    %rax,%r8
  800331:	b9 08 00 00 00       	mov    $0x8,%ecx
  800336:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  80033d:	00 00 00 
  800340:	be 22 00 00 00       	mov    $0x22,%esi
  800345:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  80034c:	00 00 00 
  80034f:	b8 00 00 00 00       	mov    $0x0,%eax
  800354:	49 b9 44 04 80 00 00 	movabs $0x800444,%r9
  80035b:	00 00 00 
  80035e:	41 ff d1             	callq  *%r9

0000000000800361 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  800361:	55                   	push   %rbp
  800362:	48 89 e5             	mov    %rsp,%rbp
  800365:	53                   	push   %rbx
  800366:	48 83 ec 08          	sub    $0x8,%rsp
  80036a:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80036d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800370:	be 00 00 00 00       	mov    $0x0,%esi
  800375:	b8 09 00 00 00       	mov    $0x9,%eax
  80037a:	48 89 f3             	mov    %rsi,%rbx
  80037d:	48 89 f7             	mov    %rsi,%rdi
  800380:	cd 30                	int    $0x30
  if (check && ret > 0)
  800382:	48 85 c0             	test   %rax,%rax
  800385:	7f 07                	jg     80038e <sys_env_set_pgfault_upcall+0x2d>
}
  800387:	48 83 c4 08          	add    $0x8,%rsp
  80038b:	5b                   	pop    %rbx
  80038c:	5d                   	pop    %rbp
  80038d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80038e:	49 89 c0             	mov    %rax,%r8
  800391:	b9 09 00 00 00       	mov    $0x9,%ecx
  800396:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  80039d:	00 00 00 
  8003a0:	be 22 00 00 00       	mov    $0x22,%esi
  8003a5:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  8003ac:	00 00 00 
  8003af:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b4:	49 b9 44 04 80 00 00 	movabs $0x800444,%r9
  8003bb:	00 00 00 
  8003be:	41 ff d1             	callq  *%r9

00000000008003c1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003c1:	55                   	push   %rbp
  8003c2:	48 89 e5             	mov    %rsp,%rbp
  8003c5:	53                   	push   %rbx
  8003c6:	49 89 f0             	mov    %rsi,%r8
  8003c9:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003cc:	48 63 d7             	movslq %edi,%rdx
  8003cf:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003d2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003d7:	be 00 00 00 00       	mov    $0x0,%esi
  8003dc:	4c 89 c1             	mov    %r8,%rcx
  8003df:	cd 30                	int    $0x30
}
  8003e1:	5b                   	pop    %rbx
  8003e2:	5d                   	pop    %rbp
  8003e3:	c3                   	retq   

00000000008003e4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8003e4:	55                   	push   %rbp
  8003e5:	48 89 e5             	mov    %rsp,%rbp
  8003e8:	53                   	push   %rbx
  8003e9:	48 83 ec 08          	sub    $0x8,%rsp
  8003ed:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8003f0:	be 00 00 00 00       	mov    $0x0,%esi
  8003f5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003fa:	48 89 f1             	mov    %rsi,%rcx
  8003fd:	48 89 f3             	mov    %rsi,%rbx
  800400:	48 89 f7             	mov    %rsi,%rdi
  800403:	cd 30                	int    $0x30
  if (check && ret > 0)
  800405:	48 85 c0             	test   %rax,%rax
  800408:	7f 07                	jg     800411 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80040a:	48 83 c4 08          	add    $0x8,%rsp
  80040e:	5b                   	pop    %rbx
  80040f:	5d                   	pop    %rbp
  800410:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800411:	49 89 c0             	mov    %rax,%r8
  800414:	b9 0c 00 00 00       	mov    $0xc,%ecx
  800419:	48 ba f0 13 80 00 00 	movabs $0x8013f0,%rdx
  800420:	00 00 00 
  800423:	be 22 00 00 00       	mov    $0x22,%esi
  800428:	48 bf 0f 14 80 00 00 	movabs $0x80140f,%rdi
  80042f:	00 00 00 
  800432:	b8 00 00 00 00       	mov    $0x0,%eax
  800437:	49 b9 44 04 80 00 00 	movabs $0x800444,%r9
  80043e:	00 00 00 
  800441:	41 ff d1             	callq  *%r9

0000000000800444 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800444:	55                   	push   %rbp
  800445:	48 89 e5             	mov    %rsp,%rbp
  800448:	41 56                	push   %r14
  80044a:	41 55                	push   %r13
  80044c:	41 54                	push   %r12
  80044e:	53                   	push   %rbx
  80044f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800456:	49 89 fd             	mov    %rdi,%r13
  800459:	41 89 f6             	mov    %esi,%r14d
  80045c:	49 89 d4             	mov    %rdx,%r12
  80045f:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800466:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80046d:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800474:	84 c0                	test   %al,%al
  800476:	74 26                	je     80049e <_panic+0x5a>
  800478:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80047f:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800486:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  80048a:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80048e:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800492:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800496:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  80049a:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80049e:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004a5:	00 00 00 
  8004a8:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004af:	00 00 00 
  8004b2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004b6:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004bd:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004c4:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004cb:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004d2:	00 00 00 
  8004d5:	48 8b 18             	mov    (%rax),%rbx
  8004d8:	48 b8 97 01 80 00 00 	movabs $0x800197,%rax
  8004df:	00 00 00 
  8004e2:	ff d0                	callq  *%rax
  8004e4:	45 89 f0             	mov    %r14d,%r8d
  8004e7:	4c 89 e9             	mov    %r13,%rcx
  8004ea:	48 89 da             	mov    %rbx,%rdx
  8004ed:	89 c6                	mov    %eax,%esi
  8004ef:	48 bf 20 14 80 00 00 	movabs $0x801420,%rdi
  8004f6:	00 00 00 
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	48 bb e6 05 80 00 00 	movabs $0x8005e6,%rbx
  800505:	00 00 00 
  800508:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80050a:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800511:	4c 89 e7             	mov    %r12,%rdi
  800514:	48 b8 7e 05 80 00 00 	movabs $0x80057e,%rax
  80051b:	00 00 00 
  80051e:	ff d0                	callq  *%rax
  cprintf("\n");
  800520:	48 bf 48 14 80 00 00 	movabs $0x801448,%rdi
  800527:	00 00 00 
  80052a:	b8 00 00 00 00       	mov    $0x0,%eax
  80052f:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800531:	cc                   	int3   
  while (1)
  800532:	eb fd                	jmp    800531 <_panic+0xed>

0000000000800534 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800534:	55                   	push   %rbp
  800535:	48 89 e5             	mov    %rsp,%rbp
  800538:	53                   	push   %rbx
  800539:	48 83 ec 08          	sub    $0x8,%rsp
  80053d:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800540:	8b 06                	mov    (%rsi),%eax
  800542:	8d 50 01             	lea    0x1(%rax),%edx
  800545:	89 16                	mov    %edx,(%rsi)
  800547:	48 98                	cltq   
  800549:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80054e:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800554:	74 0b                	je     800561 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800556:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80055a:	48 83 c4 08          	add    $0x8,%rsp
  80055e:	5b                   	pop    %rbx
  80055f:	5d                   	pop    %rbp
  800560:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800561:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800565:	be ff 00 00 00       	mov    $0xff,%esi
  80056a:	48 b8 f9 00 80 00 00 	movabs $0x8000f9,%rax
  800571:	00 00 00 
  800574:	ff d0                	callq  *%rax
    b->idx = 0;
  800576:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80057c:	eb d8                	jmp    800556 <putch+0x22>

000000000080057e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80057e:	55                   	push   %rbp
  80057f:	48 89 e5             	mov    %rsp,%rbp
  800582:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800589:	48 89 fa             	mov    %rdi,%rdx
  80058c:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80058f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800596:	00 00 00 
  b.cnt = 0;
  800599:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005a0:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005a3:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005aa:	48 bf 34 05 80 00 00 	movabs $0x800534,%rdi
  8005b1:	00 00 00 
  8005b4:	48 b8 a4 07 80 00 00 	movabs $0x8007a4,%rax
  8005bb:	00 00 00 
  8005be:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005c0:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005c7:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005ce:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005d2:	48 b8 f9 00 80 00 00 	movabs $0x8000f9,%rax
  8005d9:	00 00 00 
  8005dc:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005de:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8005e4:	c9                   	leaveq 
  8005e5:	c3                   	retq   

00000000008005e6 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8005e6:	55                   	push   %rbp
  8005e7:	48 89 e5             	mov    %rsp,%rbp
  8005ea:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8005f1:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8005f8:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8005ff:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800606:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80060d:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800614:	84 c0                	test   %al,%al
  800616:	74 20                	je     800638 <cprintf+0x52>
  800618:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80061c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800620:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800624:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800628:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80062c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800630:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800634:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800638:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80063f:	00 00 00 
  800642:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800649:	00 00 00 
  80064c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800650:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800657:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80065e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800665:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80066c:	48 b8 7e 05 80 00 00 	movabs $0x80057e,%rax
  800673:	00 00 00 
  800676:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800678:	c9                   	leaveq 
  800679:	c3                   	retq   

000000000080067a <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80067a:	55                   	push   %rbp
  80067b:	48 89 e5             	mov    %rsp,%rbp
  80067e:	41 57                	push   %r15
  800680:	41 56                	push   %r14
  800682:	41 55                	push   %r13
  800684:	41 54                	push   %r12
  800686:	53                   	push   %rbx
  800687:	48 83 ec 18          	sub    $0x18,%rsp
  80068b:	49 89 fc             	mov    %rdi,%r12
  80068e:	49 89 f5             	mov    %rsi,%r13
  800691:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800695:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800698:	41 89 cf             	mov    %ecx,%r15d
  80069b:	49 39 d7             	cmp    %rdx,%r15
  80069e:	76 45                	jbe    8006e5 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006a0:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006a4:	85 db                	test   %ebx,%ebx
  8006a6:	7e 0e                	jle    8006b6 <printnum+0x3c>
      putch(padc, putdat);
  8006a8:	4c 89 ee             	mov    %r13,%rsi
  8006ab:	44 89 f7             	mov    %r14d,%edi
  8006ae:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006b1:	83 eb 01             	sub    $0x1,%ebx
  8006b4:	75 f2                	jne    8006a8 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006b6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bf:	49 f7 f7             	div    %r15
  8006c2:	48 b8 4a 14 80 00 00 	movabs $0x80144a,%rax
  8006c9:	00 00 00 
  8006cc:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006d0:	4c 89 ee             	mov    %r13,%rsi
  8006d3:	41 ff d4             	callq  *%r12
}
  8006d6:	48 83 c4 18          	add    $0x18,%rsp
  8006da:	5b                   	pop    %rbx
  8006db:	41 5c                	pop    %r12
  8006dd:	41 5d                	pop    %r13
  8006df:	41 5e                	pop    %r14
  8006e1:	41 5f                	pop    %r15
  8006e3:	5d                   	pop    %rbp
  8006e4:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ee:	49 f7 f7             	div    %r15
  8006f1:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8006f5:	48 89 c2             	mov    %rax,%rdx
  8006f8:	48 b8 7a 06 80 00 00 	movabs $0x80067a,%rax
  8006ff:	00 00 00 
  800702:	ff d0                	callq  *%rax
  800704:	eb b0                	jmp    8006b6 <printnum+0x3c>

0000000000800706 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800706:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80070a:	48 8b 06             	mov    (%rsi),%rax
  80070d:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800711:	73 0a                	jae    80071d <sprintputch+0x17>
    *b->buf++ = ch;
  800713:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800717:	48 89 16             	mov    %rdx,(%rsi)
  80071a:	40 88 38             	mov    %dil,(%rax)
}
  80071d:	c3                   	retq   

000000000080071e <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80071e:	55                   	push   %rbp
  80071f:	48 89 e5             	mov    %rsp,%rbp
  800722:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800729:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800730:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800737:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80073e:	84 c0                	test   %al,%al
  800740:	74 20                	je     800762 <printfmt+0x44>
  800742:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800746:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80074a:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80074e:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800752:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800756:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80075a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80075e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800762:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800769:	00 00 00 
  80076c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800773:	00 00 00 
  800776:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80077a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800781:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800788:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80078f:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800796:	48 b8 a4 07 80 00 00 	movabs $0x8007a4,%rax
  80079d:	00 00 00 
  8007a0:	ff d0                	callq  *%rax
}
  8007a2:	c9                   	leaveq 
  8007a3:	c3                   	retq   

00000000008007a4 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007a4:	55                   	push   %rbp
  8007a5:	48 89 e5             	mov    %rsp,%rbp
  8007a8:	41 57                	push   %r15
  8007aa:	41 56                	push   %r14
  8007ac:	41 55                	push   %r13
  8007ae:	41 54                	push   %r12
  8007b0:	53                   	push   %rbx
  8007b1:	48 83 ec 48          	sub    $0x48,%rsp
  8007b5:	49 89 fd             	mov    %rdi,%r13
  8007b8:	49 89 f7             	mov    %rsi,%r15
  8007bb:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007be:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007c2:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007c6:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007ca:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007ce:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007d2:	41 0f b6 3e          	movzbl (%r14),%edi
  8007d6:	83 ff 25             	cmp    $0x25,%edi
  8007d9:	74 18                	je     8007f3 <vprintfmt+0x4f>
      if (ch == '\0')
  8007db:	85 ff                	test   %edi,%edi
  8007dd:	0f 84 8c 06 00 00    	je     800e6f <vprintfmt+0x6cb>
      putch(ch, putdat);
  8007e3:	4c 89 fe             	mov    %r15,%rsi
  8007e6:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007e9:	49 89 de             	mov    %rbx,%r14
  8007ec:	eb e0                	jmp    8007ce <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8007ee:	49 89 de             	mov    %rbx,%r14
  8007f1:	eb db                	jmp    8007ce <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8007f3:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8007f7:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8007fb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800802:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800808:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800811:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800817:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80081d:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800822:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800827:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80082b:	0f b6 13             	movzbl (%rbx),%edx
  80082e:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800831:	3c 55                	cmp    $0x55,%al
  800833:	0f 87 8b 05 00 00    	ja     800dc4 <vprintfmt+0x620>
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	49 bb 20 15 80 00 00 	movabs $0x801520,%r11
  800843:	00 00 00 
  800846:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80084a:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80084d:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800851:	eb d4                	jmp    800827 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800853:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800856:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80085a:	eb cb                	jmp    800827 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80085c:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80085f:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800863:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800867:	8d 50 d0             	lea    -0x30(%rax),%edx
  80086a:	83 fa 09             	cmp    $0x9,%edx
  80086d:	77 7e                	ja     8008ed <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80086f:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800873:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800877:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80087c:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800880:	8d 50 d0             	lea    -0x30(%rax),%edx
  800883:	83 fa 09             	cmp    $0x9,%edx
  800886:	76 e7                	jbe    80086f <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800888:	4c 89 f3             	mov    %r14,%rbx
  80088b:	eb 19                	jmp    8008a6 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80088d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800890:	83 f8 2f             	cmp    $0x2f,%eax
  800893:	77 2a                	ja     8008bf <vprintfmt+0x11b>
  800895:	89 c2                	mov    %eax,%edx
  800897:	4c 01 d2             	add    %r10,%rdx
  80089a:	83 c0 08             	add    $0x8,%eax
  80089d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008a0:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008a3:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008a6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008aa:	0f 89 77 ff ff ff    	jns    800827 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008b0:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008b4:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008ba:	e9 68 ff ff ff       	jmpq   800827 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008bf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008c3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008c7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008cb:	eb d3                	jmp    8008a0 <vprintfmt+0xfc>
        if (width < 0)
  8008cd:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008d6:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008d9:	4c 89 f3             	mov    %r14,%rbx
  8008dc:	e9 46 ff ff ff       	jmpq   800827 <vprintfmt+0x83>
  8008e1:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8008e4:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8008e8:	e9 3a ff ff ff       	jmpq   800827 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008ed:	4c 89 f3             	mov    %r14,%rbx
  8008f0:	eb b4                	jmp    8008a6 <vprintfmt+0x102>
        lflag++;
  8008f2:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8008f5:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8008f8:	e9 2a ff ff ff       	jmpq   800827 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8008fd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800900:	83 f8 2f             	cmp    $0x2f,%eax
  800903:	77 19                	ja     80091e <vprintfmt+0x17a>
  800905:	89 c2                	mov    %eax,%edx
  800907:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80090b:	83 c0 08             	add    $0x8,%eax
  80090e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800911:	4c 89 fe             	mov    %r15,%rsi
  800914:	8b 3a                	mov    (%rdx),%edi
  800916:	41 ff d5             	callq  *%r13
        break;
  800919:	e9 b0 fe ff ff       	jmpq   8007ce <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80091e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800922:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800926:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80092a:	eb e5                	jmp    800911 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80092c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80092f:	83 f8 2f             	cmp    $0x2f,%eax
  800932:	77 5b                	ja     80098f <vprintfmt+0x1eb>
  800934:	89 c2                	mov    %eax,%edx
  800936:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80093a:	83 c0 08             	add    $0x8,%eax
  80093d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800940:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800942:	89 c8                	mov    %ecx,%eax
  800944:	c1 f8 1f             	sar    $0x1f,%eax
  800947:	31 c1                	xor    %eax,%ecx
  800949:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094b:	83 f9 0b             	cmp    $0xb,%ecx
  80094e:	7f 4d                	jg     80099d <vprintfmt+0x1f9>
  800950:	48 63 c1             	movslq %ecx,%rax
  800953:	48 ba e0 17 80 00 00 	movabs $0x8017e0,%rdx
  80095a:	00 00 00 
  80095d:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800961:	48 85 c0             	test   %rax,%rax
  800964:	74 37                	je     80099d <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800966:	48 89 c1             	mov    %rax,%rcx
  800969:	48 ba 6b 14 80 00 00 	movabs $0x80146b,%rdx
  800970:	00 00 00 
  800973:	4c 89 fe             	mov    %r15,%rsi
  800976:	4c 89 ef             	mov    %r13,%rdi
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	48 bb 1e 07 80 00 00 	movabs $0x80071e,%rbx
  800985:	00 00 00 
  800988:	ff d3                	callq  *%rbx
  80098a:	e9 3f fe ff ff       	jmpq   8007ce <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80098f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800993:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800997:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099b:	eb a3                	jmp    800940 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80099d:	48 ba 62 14 80 00 00 	movabs $0x801462,%rdx
  8009a4:	00 00 00 
  8009a7:	4c 89 fe             	mov    %r15,%rsi
  8009aa:	4c 89 ef             	mov    %r13,%rdi
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b2:	48 bb 1e 07 80 00 00 	movabs $0x80071e,%rbx
  8009b9:	00 00 00 
  8009bc:	ff d3                	callq  *%rbx
  8009be:	e9 0b fe ff ff       	jmpq   8007ce <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009c3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009c6:	83 f8 2f             	cmp    $0x2f,%eax
  8009c9:	77 4b                	ja     800a16 <vprintfmt+0x272>
  8009cb:	89 c2                	mov    %eax,%edx
  8009cd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009d1:	83 c0 08             	add    $0x8,%eax
  8009d4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009d7:	48 8b 02             	mov    (%rdx),%rax
  8009da:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009de:	48 85 c0             	test   %rax,%rax
  8009e1:	0f 84 05 04 00 00    	je     800dec <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8009e7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009eb:	7e 06                	jle    8009f3 <vprintfmt+0x24f>
  8009ed:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009f1:	75 31                	jne    800a24 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8009f7:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8009fb:	0f b6 00             	movzbl (%rax),%eax
  8009fe:	0f be f8             	movsbl %al,%edi
  800a01:	85 ff                	test   %edi,%edi
  800a03:	0f 84 c3 00 00 00    	je     800acc <vprintfmt+0x328>
  800a09:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a0d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a11:	e9 85 00 00 00       	jmpq   800a9b <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a16:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a1a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a1e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a22:	eb b3                	jmp    8009d7 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a24:	49 63 f4             	movslq %r12d,%rsi
  800a27:	48 89 c7             	mov    %rax,%rdi
  800a2a:	48 b8 7b 0f 80 00 00 	movabs $0x800f7b,%rax
  800a31:	00 00 00 
  800a34:	ff d0                	callq  *%rax
  800a36:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a39:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a3c:	85 f6                	test   %esi,%esi
  800a3e:	7e 22                	jle    800a62 <vprintfmt+0x2be>
            putch(padc, putdat);
  800a40:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a44:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a48:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a4c:	4c 89 fe             	mov    %r15,%rsi
  800a4f:	89 df                	mov    %ebx,%edi
  800a51:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a54:	41 83 ec 01          	sub    $0x1,%r12d
  800a58:	75 f2                	jne    800a4c <vprintfmt+0x2a8>
  800a5a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a5e:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a62:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a66:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a6a:	0f b6 00             	movzbl (%rax),%eax
  800a6d:	0f be f8             	movsbl %al,%edi
  800a70:	85 ff                	test   %edi,%edi
  800a72:	0f 84 56 fd ff ff    	je     8007ce <vprintfmt+0x2a>
  800a78:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a7c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a80:	eb 19                	jmp    800a9b <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a82:	4c 89 fe             	mov    %r15,%rsi
  800a85:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a88:	41 83 ee 01          	sub    $0x1,%r14d
  800a8c:	48 83 c3 01          	add    $0x1,%rbx
  800a90:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800a94:	0f be f8             	movsbl %al,%edi
  800a97:	85 ff                	test   %edi,%edi
  800a99:	74 29                	je     800ac4 <vprintfmt+0x320>
  800a9b:	45 85 e4             	test   %r12d,%r12d
  800a9e:	78 06                	js     800aa6 <vprintfmt+0x302>
  800aa0:	41 83 ec 01          	sub    $0x1,%r12d
  800aa4:	78 48                	js     800aee <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800aa6:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800aaa:	74 d6                	je     800a82 <vprintfmt+0x2de>
  800aac:	0f be c0             	movsbl %al,%eax
  800aaf:	83 e8 20             	sub    $0x20,%eax
  800ab2:	83 f8 5e             	cmp    $0x5e,%eax
  800ab5:	76 cb                	jbe    800a82 <vprintfmt+0x2de>
            putch('?', putdat);
  800ab7:	4c 89 fe             	mov    %r15,%rsi
  800aba:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800abf:	41 ff d5             	callq  *%r13
  800ac2:	eb c4                	jmp    800a88 <vprintfmt+0x2e4>
  800ac4:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800ac8:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800acc:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800acf:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800ad3:	0f 8e f5 fc ff ff    	jle    8007ce <vprintfmt+0x2a>
          putch(' ', putdat);
  800ad9:	4c 89 fe             	mov    %r15,%rsi
  800adc:	bf 20 00 00 00       	mov    $0x20,%edi
  800ae1:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800ae4:	83 eb 01             	sub    $0x1,%ebx
  800ae7:	75 f0                	jne    800ad9 <vprintfmt+0x335>
  800ae9:	e9 e0 fc ff ff       	jmpq   8007ce <vprintfmt+0x2a>
  800aee:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800af2:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800af6:	eb d4                	jmp    800acc <vprintfmt+0x328>
  if (lflag >= 2)
  800af8:	83 f9 01             	cmp    $0x1,%ecx
  800afb:	7f 1d                	jg     800b1a <vprintfmt+0x376>
  else if (lflag)
  800afd:	85 c9                	test   %ecx,%ecx
  800aff:	74 5e                	je     800b5f <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b01:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b04:	83 f8 2f             	cmp    $0x2f,%eax
  800b07:	77 48                	ja     800b51 <vprintfmt+0x3ad>
  800b09:	89 c2                	mov    %eax,%edx
  800b0b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b0f:	83 c0 08             	add    $0x8,%eax
  800b12:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b15:	48 8b 1a             	mov    (%rdx),%rbx
  800b18:	eb 17                	jmp    800b31 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b1a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b1d:	83 f8 2f             	cmp    $0x2f,%eax
  800b20:	77 21                	ja     800b43 <vprintfmt+0x39f>
  800b22:	89 c2                	mov    %eax,%edx
  800b24:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b28:	83 c0 08             	add    $0x8,%eax
  800b2b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b2e:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b31:	48 85 db             	test   %rbx,%rbx
  800b34:	78 50                	js     800b86 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b36:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b39:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b3e:	e9 b4 01 00 00       	jmpq   800cf7 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b43:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b47:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b4b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b4f:	eb dd                	jmp    800b2e <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b51:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b55:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b59:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b5d:	eb b6                	jmp    800b15 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b5f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b62:	83 f8 2f             	cmp    $0x2f,%eax
  800b65:	77 11                	ja     800b78 <vprintfmt+0x3d4>
  800b67:	89 c2                	mov    %eax,%edx
  800b69:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b6d:	83 c0 08             	add    $0x8,%eax
  800b70:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b73:	48 63 1a             	movslq (%rdx),%rbx
  800b76:	eb b9                	jmp    800b31 <vprintfmt+0x38d>
  800b78:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b7c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b80:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b84:	eb ed                	jmp    800b73 <vprintfmt+0x3cf>
          putch('-', putdat);
  800b86:	4c 89 fe             	mov    %r15,%rsi
  800b89:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800b8e:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800b91:	48 89 da             	mov    %rbx,%rdx
  800b94:	48 f7 da             	neg    %rdx
        base = 10;
  800b97:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b9c:	e9 56 01 00 00       	jmpq   800cf7 <vprintfmt+0x553>
  if (lflag >= 2)
  800ba1:	83 f9 01             	cmp    $0x1,%ecx
  800ba4:	7f 25                	jg     800bcb <vprintfmt+0x427>
  else if (lflag)
  800ba6:	85 c9                	test   %ecx,%ecx
  800ba8:	74 5e                	je     800c08 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800baa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bad:	83 f8 2f             	cmp    $0x2f,%eax
  800bb0:	77 48                	ja     800bfa <vprintfmt+0x456>
  800bb2:	89 c2                	mov    %eax,%edx
  800bb4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bb8:	83 c0 08             	add    $0x8,%eax
  800bbb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bbe:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bc1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bc6:	e9 2c 01 00 00       	jmpq   800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bcb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bce:	83 f8 2f             	cmp    $0x2f,%eax
  800bd1:	77 19                	ja     800bec <vprintfmt+0x448>
  800bd3:	89 c2                	mov    %eax,%edx
  800bd5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bd9:	83 c0 08             	add    $0x8,%eax
  800bdc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bdf:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800be2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800be7:	e9 0b 01 00 00       	jmpq   800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bec:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bf0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bf4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bf8:	eb e5                	jmp    800bdf <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800bfa:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bfe:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c02:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c06:	eb b6                	jmp    800bbe <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c08:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c0b:	83 f8 2f             	cmp    $0x2f,%eax
  800c0e:	77 18                	ja     800c28 <vprintfmt+0x484>
  800c10:	89 c2                	mov    %eax,%edx
  800c12:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c16:	83 c0 08             	add    $0x8,%eax
  800c19:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c1c:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c1e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c23:	e9 cf 00 00 00       	jmpq   800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c28:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c2c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c30:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c34:	eb e6                	jmp    800c1c <vprintfmt+0x478>
  if (lflag >= 2)
  800c36:	83 f9 01             	cmp    $0x1,%ecx
  800c39:	7f 25                	jg     800c60 <vprintfmt+0x4bc>
  else if (lflag)
  800c3b:	85 c9                	test   %ecx,%ecx
  800c3d:	74 5b                	je     800c9a <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c3f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c42:	83 f8 2f             	cmp    $0x2f,%eax
  800c45:	77 45                	ja     800c8c <vprintfmt+0x4e8>
  800c47:	89 c2                	mov    %eax,%edx
  800c49:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c4d:	83 c0 08             	add    $0x8,%eax
  800c50:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c53:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c56:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c5b:	e9 97 00 00 00       	jmpq   800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c60:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c63:	83 f8 2f             	cmp    $0x2f,%eax
  800c66:	77 16                	ja     800c7e <vprintfmt+0x4da>
  800c68:	89 c2                	mov    %eax,%edx
  800c6a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c6e:	83 c0 08             	add    $0x8,%eax
  800c71:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c74:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c77:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c7c:	eb 79                	jmp    800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c7e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c82:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c86:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c8a:	eb e8                	jmp    800c74 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800c8c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c90:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c94:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c98:	eb b9                	jmp    800c53 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800c9a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c9d:	83 f8 2f             	cmp    $0x2f,%eax
  800ca0:	77 15                	ja     800cb7 <vprintfmt+0x513>
  800ca2:	89 c2                	mov    %eax,%edx
  800ca4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ca8:	83 c0 08             	add    $0x8,%eax
  800cab:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cae:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cb0:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cb5:	eb 40                	jmp    800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cb7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cbb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cbf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cc3:	eb e9                	jmp    800cae <vprintfmt+0x50a>
        putch('0', putdat);
  800cc5:	4c 89 fe             	mov    %r15,%rsi
  800cc8:	bf 30 00 00 00       	mov    $0x30,%edi
  800ccd:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cd0:	4c 89 fe             	mov    %r15,%rsi
  800cd3:	bf 78 00 00 00       	mov    $0x78,%edi
  800cd8:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cdb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cde:	83 f8 2f             	cmp    $0x2f,%eax
  800ce1:	77 34                	ja     800d17 <vprintfmt+0x573>
  800ce3:	89 c2                	mov    %eax,%edx
  800ce5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ce9:	83 c0 08             	add    $0x8,%eax
  800cec:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cef:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800cf2:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800cf7:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800cfc:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d00:	4c 89 fe             	mov    %r15,%rsi
  800d03:	4c 89 ef             	mov    %r13,%rdi
  800d06:	48 b8 7a 06 80 00 00 	movabs $0x80067a,%rax
  800d0d:	00 00 00 
  800d10:	ff d0                	callq  *%rax
        break;
  800d12:	e9 b7 fa ff ff       	jmpq   8007ce <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d17:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d1b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d1f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d23:	eb ca                	jmp    800cef <vprintfmt+0x54b>
  if (lflag >= 2)
  800d25:	83 f9 01             	cmp    $0x1,%ecx
  800d28:	7f 22                	jg     800d4c <vprintfmt+0x5a8>
  else if (lflag)
  800d2a:	85 c9                	test   %ecx,%ecx
  800d2c:	74 58                	je     800d86 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d2e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d31:	83 f8 2f             	cmp    $0x2f,%eax
  800d34:	77 42                	ja     800d78 <vprintfmt+0x5d4>
  800d36:	89 c2                	mov    %eax,%edx
  800d38:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d3c:	83 c0 08             	add    $0x8,%eax
  800d3f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d42:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d45:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d4a:	eb ab                	jmp    800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d4c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d4f:	83 f8 2f             	cmp    $0x2f,%eax
  800d52:	77 16                	ja     800d6a <vprintfmt+0x5c6>
  800d54:	89 c2                	mov    %eax,%edx
  800d56:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d5a:	83 c0 08             	add    $0x8,%eax
  800d5d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d60:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d63:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d68:	eb 8d                	jmp    800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d6a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d6e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d72:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d76:	eb e8                	jmp    800d60 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d78:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d7c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d80:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d84:	eb bc                	jmp    800d42 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800d86:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d89:	83 f8 2f             	cmp    $0x2f,%eax
  800d8c:	77 18                	ja     800da6 <vprintfmt+0x602>
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d94:	83 c0 08             	add    $0x8,%eax
  800d97:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d9a:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800d9c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800da1:	e9 51 ff ff ff       	jmpq   800cf7 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800da6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800daa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800dae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800db2:	eb e6                	jmp    800d9a <vprintfmt+0x5f6>
        putch(ch, putdat);
  800db4:	4c 89 fe             	mov    %r15,%rsi
  800db7:	bf 25 00 00 00       	mov    $0x25,%edi
  800dbc:	41 ff d5             	callq  *%r13
        break;
  800dbf:	e9 0a fa ff ff       	jmpq   8007ce <vprintfmt+0x2a>
        putch('%', putdat);
  800dc4:	4c 89 fe             	mov    %r15,%rsi
  800dc7:	bf 25 00 00 00       	mov    $0x25,%edi
  800dcc:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800dcf:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800dd3:	0f 84 15 fa ff ff    	je     8007ee <vprintfmt+0x4a>
  800dd9:	49 89 de             	mov    %rbx,%r14
  800ddc:	49 83 ee 01          	sub    $0x1,%r14
  800de0:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800de5:	75 f5                	jne    800ddc <vprintfmt+0x638>
  800de7:	e9 e2 f9 ff ff       	jmpq   8007ce <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800dec:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800df0:	74 06                	je     800df8 <vprintfmt+0x654>
  800df2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800df6:	7f 21                	jg     800e19 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800df8:	bf 28 00 00 00       	mov    $0x28,%edi
  800dfd:	48 bb 5c 14 80 00 00 	movabs $0x80145c,%rbx
  800e04:	00 00 00 
  800e07:	b8 28 00 00 00       	mov    $0x28,%eax
  800e0c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e10:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e14:	e9 82 fc ff ff       	jmpq   800a9b <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e19:	49 63 f4             	movslq %r12d,%rsi
  800e1c:	48 bf 5b 14 80 00 00 	movabs $0x80145b,%rdi
  800e23:	00 00 00 
  800e26:	48 b8 7b 0f 80 00 00 	movabs $0x800f7b,%rax
  800e2d:	00 00 00 
  800e30:	ff d0                	callq  *%rax
  800e32:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e35:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e38:	48 be 5b 14 80 00 00 	movabs $0x80145b,%rsi
  800e3f:	00 00 00 
  800e42:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	0f 8f f2 fb ff ff    	jg     800a40 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e4e:	48 bb 5c 14 80 00 00 	movabs $0x80145c,%rbx
  800e55:	00 00 00 
  800e58:	b8 28 00 00 00       	mov    $0x28,%eax
  800e5d:	bf 28 00 00 00       	mov    $0x28,%edi
  800e62:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e66:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e6a:	e9 2c fc ff ff       	jmpq   800a9b <vprintfmt+0x2f7>
}
  800e6f:	48 83 c4 48          	add    $0x48,%rsp
  800e73:	5b                   	pop    %rbx
  800e74:	41 5c                	pop    %r12
  800e76:	41 5d                	pop    %r13
  800e78:	41 5e                	pop    %r14
  800e7a:	41 5f                	pop    %r15
  800e7c:	5d                   	pop    %rbp
  800e7d:	c3                   	retq   

0000000000800e7e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e7e:	55                   	push   %rbp
  800e7f:	48 89 e5             	mov    %rsp,%rbp
  800e82:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800e86:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800e8a:	48 63 c6             	movslq %esi,%rax
  800e8d:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800e92:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800e96:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800e9d:	48 85 ff             	test   %rdi,%rdi
  800ea0:	74 2a                	je     800ecc <vsnprintf+0x4e>
  800ea2:	85 f6                	test   %esi,%esi
  800ea4:	7e 26                	jle    800ecc <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ea6:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800eaa:	48 bf 06 07 80 00 00 	movabs $0x800706,%rdi
  800eb1:	00 00 00 
  800eb4:	48 b8 a4 07 80 00 00 	movabs $0x8007a4,%rax
  800ebb:	00 00 00 
  800ebe:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ec0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ec4:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ec7:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800eca:	c9                   	leaveq 
  800ecb:	c3                   	retq   
    return -E_INVAL;
  800ecc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed1:	eb f7                	jmp    800eca <vsnprintf+0x4c>

0000000000800ed3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ed3:	55                   	push   %rbp
  800ed4:	48 89 e5             	mov    %rsp,%rbp
  800ed7:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ede:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ee5:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800eec:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ef3:	84 c0                	test   %al,%al
  800ef5:	74 20                	je     800f17 <snprintf+0x44>
  800ef7:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800efb:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800eff:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f03:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f07:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f0b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f0f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f13:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f17:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f1e:	00 00 00 
  800f21:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f28:	00 00 00 
  800f2b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f2f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f36:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f3d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f44:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f4b:	48 b8 7e 0e 80 00 00 	movabs $0x800e7e,%rax
  800f52:	00 00 00 
  800f55:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f57:	c9                   	leaveq 
  800f58:	c3                   	retq   

0000000000800f59 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f59:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f5c:	74 17                	je     800f75 <strlen+0x1c>
  800f5e:	48 89 fa             	mov    %rdi,%rdx
  800f61:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f66:	29 f9                	sub    %edi,%ecx
    n++;
  800f68:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f6b:	48 83 c2 01          	add    $0x1,%rdx
  800f6f:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f72:	75 f4                	jne    800f68 <strlen+0xf>
  800f74:	c3                   	retq   
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f7a:	c3                   	retq   

0000000000800f7b <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f7b:	48 85 f6             	test   %rsi,%rsi
  800f7e:	74 24                	je     800fa4 <strnlen+0x29>
  800f80:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f83:	74 25                	je     800faa <strnlen+0x2f>
  800f85:	48 01 fe             	add    %rdi,%rsi
  800f88:	48 89 fa             	mov    %rdi,%rdx
  800f8b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f90:	29 f9                	sub    %edi,%ecx
    n++;
  800f92:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f95:	48 83 c2 01          	add    $0x1,%rdx
  800f99:	48 39 f2             	cmp    %rsi,%rdx
  800f9c:	74 11                	je     800faf <strnlen+0x34>
  800f9e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fa1:	75 ef                	jne    800f92 <strnlen+0x17>
  800fa3:	c3                   	retq   
  800fa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa9:	c3                   	retq   
  800faa:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800faf:	c3                   	retq   

0000000000800fb0 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fb0:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb8:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fbc:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fbf:	48 83 c2 01          	add    $0x1,%rdx
  800fc3:	84 c9                	test   %cl,%cl
  800fc5:	75 f1                	jne    800fb8 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fc7:	c3                   	retq   

0000000000800fc8 <strcat>:

char *
strcat(char *dst, const char *src) {
  800fc8:	55                   	push   %rbp
  800fc9:	48 89 e5             	mov    %rsp,%rbp
  800fcc:	41 54                	push   %r12
  800fce:	53                   	push   %rbx
  800fcf:	48 89 fb             	mov    %rdi,%rbx
  800fd2:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800fd5:	48 b8 59 0f 80 00 00 	movabs $0x800f59,%rax
  800fdc:	00 00 00 
  800fdf:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800fe1:	48 63 f8             	movslq %eax,%rdi
  800fe4:	48 01 df             	add    %rbx,%rdi
  800fe7:	4c 89 e6             	mov    %r12,%rsi
  800fea:	48 b8 b0 0f 80 00 00 	movabs $0x800fb0,%rax
  800ff1:	00 00 00 
  800ff4:	ff d0                	callq  *%rax
  return dst;
}
  800ff6:	48 89 d8             	mov    %rbx,%rax
  800ff9:	5b                   	pop    %rbx
  800ffa:	41 5c                	pop    %r12
  800ffc:	5d                   	pop    %rbp
  800ffd:	c3                   	retq   

0000000000800ffe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ffe:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801001:	48 85 d2             	test   %rdx,%rdx
  801004:	74 1f                	je     801025 <strncpy+0x27>
  801006:	48 01 fa             	add    %rdi,%rdx
  801009:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  80100c:	48 83 c1 01          	add    $0x1,%rcx
  801010:	44 0f b6 06          	movzbl (%rsi),%r8d
  801014:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801018:	41 80 f8 01          	cmp    $0x1,%r8b
  80101c:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  801020:	48 39 ca             	cmp    %rcx,%rdx
  801023:	75 e7                	jne    80100c <strncpy+0xe>
  }
  return ret;
}
  801025:	c3                   	retq   

0000000000801026 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801026:	48 89 f8             	mov    %rdi,%rax
  801029:	48 85 d2             	test   %rdx,%rdx
  80102c:	74 36                	je     801064 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  80102e:	48 83 fa 01          	cmp    $0x1,%rdx
  801032:	74 2d                	je     801061 <strlcpy+0x3b>
  801034:	44 0f b6 06          	movzbl (%rsi),%r8d
  801038:	45 84 c0             	test   %r8b,%r8b
  80103b:	74 24                	je     801061 <strlcpy+0x3b>
  80103d:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801041:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801046:	48 83 c0 01          	add    $0x1,%rax
  80104a:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  80104e:	48 39 d1             	cmp    %rdx,%rcx
  801051:	74 0e                	je     801061 <strlcpy+0x3b>
  801053:	48 83 c1 01          	add    $0x1,%rcx
  801057:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  80105c:	45 84 c0             	test   %r8b,%r8b
  80105f:	75 e5                	jne    801046 <strlcpy+0x20>
    *dst = '\0';
  801061:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  801064:	48 29 f8             	sub    %rdi,%rax
}
  801067:	c3                   	retq   

0000000000801068 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801068:	0f b6 07             	movzbl (%rdi),%eax
  80106b:	84 c0                	test   %al,%al
  80106d:	74 17                	je     801086 <strcmp+0x1e>
  80106f:	3a 06                	cmp    (%rsi),%al
  801071:	75 13                	jne    801086 <strcmp+0x1e>
    p++, q++;
  801073:	48 83 c7 01          	add    $0x1,%rdi
  801077:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  80107b:	0f b6 07             	movzbl (%rdi),%eax
  80107e:	84 c0                	test   %al,%al
  801080:	74 04                	je     801086 <strcmp+0x1e>
  801082:	3a 06                	cmp    (%rsi),%al
  801084:	74 ed                	je     801073 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  801086:	0f b6 c0             	movzbl %al,%eax
  801089:	0f b6 16             	movzbl (%rsi),%edx
  80108c:	29 d0                	sub    %edx,%eax
}
  80108e:	c3                   	retq   

000000000080108f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  80108f:	48 85 d2             	test   %rdx,%rdx
  801092:	74 2f                	je     8010c3 <strncmp+0x34>
  801094:	0f b6 07             	movzbl (%rdi),%eax
  801097:	84 c0                	test   %al,%al
  801099:	74 1f                	je     8010ba <strncmp+0x2b>
  80109b:	3a 06                	cmp    (%rsi),%al
  80109d:	75 1b                	jne    8010ba <strncmp+0x2b>
  80109f:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010a2:	48 83 c7 01          	add    $0x1,%rdi
  8010a6:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010aa:	48 39 d7             	cmp    %rdx,%rdi
  8010ad:	74 1a                	je     8010c9 <strncmp+0x3a>
  8010af:	0f b6 07             	movzbl (%rdi),%eax
  8010b2:	84 c0                	test   %al,%al
  8010b4:	74 04                	je     8010ba <strncmp+0x2b>
  8010b6:	3a 06                	cmp    (%rsi),%al
  8010b8:	74 e8                	je     8010a2 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010ba:	0f b6 07             	movzbl (%rdi),%eax
  8010bd:	0f b6 16             	movzbl (%rsi),%edx
  8010c0:	29 d0                	sub    %edx,%eax
}
  8010c2:	c3                   	retq   
    return 0;
  8010c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c8:	c3                   	retq   
  8010c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ce:	c3                   	retq   

00000000008010cf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010cf:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010d1:	0f b6 07             	movzbl (%rdi),%eax
  8010d4:	84 c0                	test   %al,%al
  8010d6:	74 1e                	je     8010f6 <strchr+0x27>
    if (*s == c)
  8010d8:	40 38 c6             	cmp    %al,%sil
  8010db:	74 1f                	je     8010fc <strchr+0x2d>
  for (; *s; s++)
  8010dd:	48 83 c7 01          	add    $0x1,%rdi
  8010e1:	0f b6 07             	movzbl (%rdi),%eax
  8010e4:	84 c0                	test   %al,%al
  8010e6:	74 08                	je     8010f0 <strchr+0x21>
    if (*s == c)
  8010e8:	38 d0                	cmp    %dl,%al
  8010ea:	75 f1                	jne    8010dd <strchr+0xe>
  for (; *s; s++)
  8010ec:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8010ef:	c3                   	retq   
  return 0;
  8010f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f5:	c3                   	retq   
  8010f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fb:	c3                   	retq   
    if (*s == c)
  8010fc:	48 89 f8             	mov    %rdi,%rax
  8010ff:	c3                   	retq   

0000000000801100 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801100:	48 89 f8             	mov    %rdi,%rax
  801103:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  801105:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801108:	40 38 f2             	cmp    %sil,%dl
  80110b:	74 13                	je     801120 <strfind+0x20>
  80110d:	84 d2                	test   %dl,%dl
  80110f:	74 0f                	je     801120 <strfind+0x20>
  for (; *s; s++)
  801111:	48 83 c0 01          	add    $0x1,%rax
  801115:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801118:	38 ca                	cmp    %cl,%dl
  80111a:	74 04                	je     801120 <strfind+0x20>
  80111c:	84 d2                	test   %dl,%dl
  80111e:	75 f1                	jne    801111 <strfind+0x11>
      break;
  return (char *)s;
}
  801120:	c3                   	retq   

0000000000801121 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801121:	48 85 d2             	test   %rdx,%rdx
  801124:	74 3a                	je     801160 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801126:	48 89 f8             	mov    %rdi,%rax
  801129:	48 09 d0             	or     %rdx,%rax
  80112c:	a8 03                	test   $0x3,%al
  80112e:	75 28                	jne    801158 <memset+0x37>
    uint32_t k = c & 0xFFU;
  801130:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801134:	89 f0                	mov    %esi,%eax
  801136:	c1 e0 08             	shl    $0x8,%eax
  801139:	89 f1                	mov    %esi,%ecx
  80113b:	c1 e1 18             	shl    $0x18,%ecx
  80113e:	41 89 f0             	mov    %esi,%r8d
  801141:	41 c1 e0 10          	shl    $0x10,%r8d
  801145:	44 09 c1             	or     %r8d,%ecx
  801148:	09 ce                	or     %ecx,%esi
  80114a:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  80114c:	48 c1 ea 02          	shr    $0x2,%rdx
  801150:	48 89 d1             	mov    %rdx,%rcx
  801153:	fc                   	cld    
  801154:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801156:	eb 08                	jmp    801160 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801158:	89 f0                	mov    %esi,%eax
  80115a:	48 89 d1             	mov    %rdx,%rcx
  80115d:	fc                   	cld    
  80115e:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  801160:	48 89 f8             	mov    %rdi,%rax
  801163:	c3                   	retq   

0000000000801164 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  801164:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801167:	48 39 fe             	cmp    %rdi,%rsi
  80116a:	73 40                	jae    8011ac <memmove+0x48>
  80116c:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  801170:	48 39 f9             	cmp    %rdi,%rcx
  801173:	76 37                	jbe    8011ac <memmove+0x48>
    s += n;
    d += n;
  801175:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801179:	48 89 fe             	mov    %rdi,%rsi
  80117c:	48 09 d6             	or     %rdx,%rsi
  80117f:	48 09 ce             	or     %rcx,%rsi
  801182:	40 f6 c6 03          	test   $0x3,%sil
  801186:	75 14                	jne    80119c <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  801188:	48 83 ef 04          	sub    $0x4,%rdi
  80118c:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  801190:	48 c1 ea 02          	shr    $0x2,%rdx
  801194:	48 89 d1             	mov    %rdx,%rcx
  801197:	fd                   	std    
  801198:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80119a:	eb 0e                	jmp    8011aa <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  80119c:	48 83 ef 01          	sub    $0x1,%rdi
  8011a0:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011a4:	48 89 d1             	mov    %rdx,%rcx
  8011a7:	fd                   	std    
  8011a8:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011aa:	fc                   	cld    
  8011ab:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011ac:	48 89 c1             	mov    %rax,%rcx
  8011af:	48 09 d1             	or     %rdx,%rcx
  8011b2:	48 09 f1             	or     %rsi,%rcx
  8011b5:	f6 c1 03             	test   $0x3,%cl
  8011b8:	75 0e                	jne    8011c8 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011ba:	48 c1 ea 02          	shr    $0x2,%rdx
  8011be:	48 89 d1             	mov    %rdx,%rcx
  8011c1:	48 89 c7             	mov    %rax,%rdi
  8011c4:	fc                   	cld    
  8011c5:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011c7:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011c8:	48 89 c7             	mov    %rax,%rdi
  8011cb:	48 89 d1             	mov    %rdx,%rcx
  8011ce:	fc                   	cld    
  8011cf:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011d1:	c3                   	retq   

00000000008011d2 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011d2:	55                   	push   %rbp
  8011d3:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011d6:	48 b8 64 11 80 00 00 	movabs $0x801164,%rax
  8011dd:	00 00 00 
  8011e0:	ff d0                	callq  *%rax
}
  8011e2:	5d                   	pop    %rbp
  8011e3:	c3                   	retq   

00000000008011e4 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8011e4:	55                   	push   %rbp
  8011e5:	48 89 e5             	mov    %rsp,%rbp
  8011e8:	41 57                	push   %r15
  8011ea:	41 56                	push   %r14
  8011ec:	41 55                	push   %r13
  8011ee:	41 54                	push   %r12
  8011f0:	53                   	push   %rbx
  8011f1:	48 83 ec 08          	sub    $0x8,%rsp
  8011f5:	49 89 fe             	mov    %rdi,%r14
  8011f8:	49 89 f7             	mov    %rsi,%r15
  8011fb:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  8011fe:	48 89 f7             	mov    %rsi,%rdi
  801201:	48 b8 59 0f 80 00 00 	movabs $0x800f59,%rax
  801208:	00 00 00 
  80120b:	ff d0                	callq  *%rax
  80120d:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801210:	4c 89 ee             	mov    %r13,%rsi
  801213:	4c 89 f7             	mov    %r14,%rdi
  801216:	48 b8 7b 0f 80 00 00 	movabs $0x800f7b,%rax
  80121d:	00 00 00 
  801220:	ff d0                	callq  *%rax
  801222:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  801225:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801229:	4d 39 e5             	cmp    %r12,%r13
  80122c:	74 26                	je     801254 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  80122e:	4c 89 e8             	mov    %r13,%rax
  801231:	4c 29 e0             	sub    %r12,%rax
  801234:	48 39 d8             	cmp    %rbx,%rax
  801237:	76 2a                	jbe    801263 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801239:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  80123d:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801241:	4c 89 fe             	mov    %r15,%rsi
  801244:	48 b8 d2 11 80 00 00 	movabs $0x8011d2,%rax
  80124b:	00 00 00 
  80124e:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801250:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801254:	48 83 c4 08          	add    $0x8,%rsp
  801258:	5b                   	pop    %rbx
  801259:	41 5c                	pop    %r12
  80125b:	41 5d                	pop    %r13
  80125d:	41 5e                	pop    %r14
  80125f:	41 5f                	pop    %r15
  801261:	5d                   	pop    %rbp
  801262:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801263:	49 83 ed 01          	sub    $0x1,%r13
  801267:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80126b:	4c 89 ea             	mov    %r13,%rdx
  80126e:	4c 89 fe             	mov    %r15,%rsi
  801271:	48 b8 d2 11 80 00 00 	movabs $0x8011d2,%rax
  801278:	00 00 00 
  80127b:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80127d:	4d 01 ee             	add    %r13,%r14
  801280:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801285:	eb c9                	jmp    801250 <strlcat+0x6c>

0000000000801287 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801287:	48 85 d2             	test   %rdx,%rdx
  80128a:	74 3a                	je     8012c6 <memcmp+0x3f>
    if (*s1 != *s2)
  80128c:	0f b6 0f             	movzbl (%rdi),%ecx
  80128f:	44 0f b6 06          	movzbl (%rsi),%r8d
  801293:	44 38 c1             	cmp    %r8b,%cl
  801296:	75 1d                	jne    8012b5 <memcmp+0x2e>
  801298:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80129d:	48 39 d0             	cmp    %rdx,%rax
  8012a0:	74 1e                	je     8012c0 <memcmp+0x39>
    if (*s1 != *s2)
  8012a2:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012a6:	48 83 c0 01          	add    $0x1,%rax
  8012aa:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012b0:	44 38 c1             	cmp    %r8b,%cl
  8012b3:	74 e8                	je     80129d <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012b5:	0f b6 c1             	movzbl %cl,%eax
  8012b8:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012bc:	44 29 c0             	sub    %r8d,%eax
  8012bf:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c5:	c3                   	retq   
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cb:	c3                   	retq   

00000000008012cc <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012cc:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012d0:	48 39 c7             	cmp    %rax,%rdi
  8012d3:	73 19                	jae    8012ee <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012d5:	89 f2                	mov    %esi,%edx
  8012d7:	40 38 37             	cmp    %sil,(%rdi)
  8012da:	74 16                	je     8012f2 <memfind+0x26>
  for (; s < ends; s++)
  8012dc:	48 83 c7 01          	add    $0x1,%rdi
  8012e0:	48 39 f8             	cmp    %rdi,%rax
  8012e3:	74 08                	je     8012ed <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012e5:	38 17                	cmp    %dl,(%rdi)
  8012e7:	75 f3                	jne    8012dc <memfind+0x10>
  for (; s < ends; s++)
  8012e9:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8012ec:	c3                   	retq   
  8012ed:	c3                   	retq   
  for (; s < ends; s++)
  8012ee:	48 89 f8             	mov    %rdi,%rax
  8012f1:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8012f2:	48 89 f8             	mov    %rdi,%rax
  8012f5:	c3                   	retq   

00000000008012f6 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8012f6:	0f b6 07             	movzbl (%rdi),%eax
  8012f9:	3c 20                	cmp    $0x20,%al
  8012fb:	74 04                	je     801301 <strtol+0xb>
  8012fd:	3c 09                	cmp    $0x9,%al
  8012ff:	75 0f                	jne    801310 <strtol+0x1a>
    s++;
  801301:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801305:	0f b6 07             	movzbl (%rdi),%eax
  801308:	3c 20                	cmp    $0x20,%al
  80130a:	74 f5                	je     801301 <strtol+0xb>
  80130c:	3c 09                	cmp    $0x9,%al
  80130e:	74 f1                	je     801301 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801310:	3c 2b                	cmp    $0x2b,%al
  801312:	74 2b                	je     80133f <strtol+0x49>
  int neg  = 0;
  801314:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80131a:	3c 2d                	cmp    $0x2d,%al
  80131c:	74 2d                	je     80134b <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80131e:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801324:	75 0f                	jne    801335 <strtol+0x3f>
  801326:	80 3f 30             	cmpb   $0x30,(%rdi)
  801329:	74 2c                	je     801357 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80132b:	85 d2                	test   %edx,%edx
  80132d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801332:	0f 44 d0             	cmove  %eax,%edx
  801335:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80133a:	4c 63 d2             	movslq %edx,%r10
  80133d:	eb 5c                	jmp    80139b <strtol+0xa5>
    s++;
  80133f:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801343:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801349:	eb d3                	jmp    80131e <strtol+0x28>
    s++, neg = 1;
  80134b:	48 83 c7 01          	add    $0x1,%rdi
  80134f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801355:	eb c7                	jmp    80131e <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801357:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80135b:	74 0f                	je     80136c <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80135d:	85 d2                	test   %edx,%edx
  80135f:	75 d4                	jne    801335 <strtol+0x3f>
    s++, base = 8;
  801361:	48 83 c7 01          	add    $0x1,%rdi
  801365:	ba 08 00 00 00       	mov    $0x8,%edx
  80136a:	eb c9                	jmp    801335 <strtol+0x3f>
    s += 2, base = 16;
  80136c:	48 83 c7 02          	add    $0x2,%rdi
  801370:	ba 10 00 00 00       	mov    $0x10,%edx
  801375:	eb be                	jmp    801335 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801377:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80137b:	41 80 f8 19          	cmp    $0x19,%r8b
  80137f:	77 2f                	ja     8013b0 <strtol+0xba>
      dig = *s - 'a' + 10;
  801381:	44 0f be c1          	movsbl %cl,%r8d
  801385:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801389:	39 d1                	cmp    %edx,%ecx
  80138b:	7d 37                	jge    8013c4 <strtol+0xce>
    s++, val = (val * base) + dig;
  80138d:	48 83 c7 01          	add    $0x1,%rdi
  801391:	49 0f af c2          	imul   %r10,%rax
  801395:	48 63 c9             	movslq %ecx,%rcx
  801398:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80139b:	0f b6 0f             	movzbl (%rdi),%ecx
  80139e:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013a2:	41 80 f8 09          	cmp    $0x9,%r8b
  8013a6:	77 cf                	ja     801377 <strtol+0x81>
      dig = *s - '0';
  8013a8:	0f be c9             	movsbl %cl,%ecx
  8013ab:	83 e9 30             	sub    $0x30,%ecx
  8013ae:	eb d9                	jmp    801389 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013b0:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013b4:	41 80 f8 19          	cmp    $0x19,%r8b
  8013b8:	77 0a                	ja     8013c4 <strtol+0xce>
      dig = *s - 'A' + 10;
  8013ba:	44 0f be c1          	movsbl %cl,%r8d
  8013be:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013c2:	eb c5                	jmp    801389 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013c4:	48 85 f6             	test   %rsi,%rsi
  8013c7:	74 03                	je     8013cc <strtol+0xd6>
    *endptr = (char *)s;
  8013c9:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013cc:	48 89 c2             	mov    %rax,%rdx
  8013cf:	48 f7 da             	neg    %rdx
  8013d2:	45 85 c9             	test   %r9d,%r9d
  8013d5:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013d9:	c3                   	retq   
  8013da:	66 90                	xchg   %ax,%ax
