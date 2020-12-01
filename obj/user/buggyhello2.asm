
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
  800040:	48 b8 1b 01 80 00 00 	movabs $0x80011b,%rax
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
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  80009b:	48 b8 b9 01 80 00 00 	movabs $0x8001b9,%rax
  8000a2:	00 00 00 
  8000a5:	ff d0                	callq  *%rax
  8000a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ac:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000b0:	48 c1 e0 05          	shl    $0x5,%rax
  8000b4:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000bb:	00 00 00 
  8000be:	48 01 d0             	add    %rdx,%rax
  8000c1:	48 a3 10 20 80 00 00 	movabs %rax,0x802010
  8000c8:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000cb:	45 85 ed             	test   %r13d,%r13d
  8000ce:	7e 0d                	jle    8000dd <libmain+0x8f>
    binaryname = argv[0];
  8000d0:	49 8b 06             	mov    (%r14),%rax
  8000d3:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000da:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000dd:	4c 89 f6             	mov    %r14,%rsi
  8000e0:	44 89 ef             	mov    %r13d,%edi
  8000e3:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000ea:	00 00 00 
  8000ed:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000ef:	48 b8 04 01 80 00 00 	movabs $0x800104,%rax
  8000f6:	00 00 00 
  8000f9:	ff d0                	callq  *%rax
#endif
}
  8000fb:	5b                   	pop    %rbx
  8000fc:	41 5c                	pop    %r12
  8000fe:	41 5d                	pop    %r13
  800100:	41 5e                	pop    %r14
  800102:	5d                   	pop    %rbp
  800103:	c3                   	retq   

0000000000800104 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800104:	55                   	push   %rbp
  800105:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800108:	bf 00 00 00 00       	mov    $0x0,%edi
  80010d:	48 b8 59 01 80 00 00 	movabs $0x800159,%rax
  800114:	00 00 00 
  800117:	ff d0                	callq  *%rax
}
  800119:	5d                   	pop    %rbp
  80011a:	c3                   	retq   

000000000080011b <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  80011b:	55                   	push   %rbp
  80011c:	48 89 e5             	mov    %rsp,%rbp
  80011f:	53                   	push   %rbx
  800120:	48 89 fa             	mov    %rdi,%rdx
  800123:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800126:	b8 00 00 00 00       	mov    $0x0,%eax
  80012b:	48 89 c3             	mov    %rax,%rbx
  80012e:	48 89 c7             	mov    %rax,%rdi
  800131:	48 89 c6             	mov    %rax,%rsi
  800134:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800136:	5b                   	pop    %rbx
  800137:	5d                   	pop    %rbp
  800138:	c3                   	retq   

0000000000800139 <sys_cgetc>:

int
sys_cgetc(void) {
  800139:	55                   	push   %rbp
  80013a:	48 89 e5             	mov    %rsp,%rbp
  80013d:	53                   	push   %rbx
  asm volatile("int %1\n"
  80013e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800143:	b8 01 00 00 00       	mov    $0x1,%eax
  800148:	48 89 ca             	mov    %rcx,%rdx
  80014b:	48 89 cb             	mov    %rcx,%rbx
  80014e:	48 89 cf             	mov    %rcx,%rdi
  800151:	48 89 ce             	mov    %rcx,%rsi
  800154:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %rbx
  800157:	5d                   	pop    %rbp
  800158:	c3                   	retq   

0000000000800159 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800159:	55                   	push   %rbp
  80015a:	48 89 e5             	mov    %rsp,%rbp
  80015d:	53                   	push   %rbx
  80015e:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800162:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800165:	be 00 00 00 00       	mov    $0x0,%esi
  80016a:	b8 03 00 00 00       	mov    $0x3,%eax
  80016f:	48 89 f1             	mov    %rsi,%rcx
  800172:	48 89 f3             	mov    %rsi,%rbx
  800175:	48 89 f7             	mov    %rsi,%rdi
  800178:	cd 30                	int    $0x30
  if (check && ret > 0)
  80017a:	48 85 c0             	test   %rax,%rax
  80017d:	7f 07                	jg     800186 <sys_env_destroy+0x2d>
}
  80017f:	48 83 c4 08          	add    $0x8,%rsp
  800183:	5b                   	pop    %rbx
  800184:	5d                   	pop    %rbp
  800185:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800186:	49 89 c0             	mov    %rax,%r8
  800189:	b9 03 00 00 00       	mov    $0x3,%ecx
  80018e:	48 ba 18 14 80 00 00 	movabs $0x801418,%rdx
  800195:	00 00 00 
  800198:	be 22 00 00 00       	mov    $0x22,%esi
  80019d:	48 bf 37 14 80 00 00 	movabs $0x801437,%rdi
  8001a4:	00 00 00 
  8001a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ac:	49 b9 66 04 80 00 00 	movabs $0x800466,%r9
  8001b3:	00 00 00 
  8001b6:	41 ff d1             	callq  *%r9

00000000008001b9 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001b9:	55                   	push   %rbp
  8001ba:	48 89 e5             	mov    %rsp,%rbp
  8001bd:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8001c8:	48 89 ca             	mov    %rcx,%rdx
  8001cb:	48 89 cb             	mov    %rcx,%rbx
  8001ce:	48 89 cf             	mov    %rcx,%rdi
  8001d1:	48 89 ce             	mov    %rcx,%rsi
  8001d4:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001d6:	5b                   	pop    %rbx
  8001d7:	5d                   	pop    %rbp
  8001d8:	c3                   	retq   

00000000008001d9 <sys_yield>:

void
sys_yield(void) {
  8001d9:	55                   	push   %rbp
  8001da:	48 89 e5             	mov    %rsp,%rbp
  8001dd:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001e8:	48 89 ca             	mov    %rcx,%rdx
  8001eb:	48 89 cb             	mov    %rcx,%rbx
  8001ee:	48 89 cf             	mov    %rcx,%rdi
  8001f1:	48 89 ce             	mov    %rcx,%rsi
  8001f4:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001f6:	5b                   	pop    %rbx
  8001f7:	5d                   	pop    %rbp
  8001f8:	c3                   	retq   

00000000008001f9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001f9:	55                   	push   %rbp
  8001fa:	48 89 e5             	mov    %rsp,%rbp
  8001fd:	53                   	push   %rbx
  8001fe:	48 83 ec 08          	sub    $0x8,%rsp
  800202:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  800205:	4c 63 c7             	movslq %edi,%r8
  800208:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  80020b:	be 00 00 00 00       	mov    $0x0,%esi
  800210:	b8 04 00 00 00       	mov    $0x4,%eax
  800215:	4c 89 c2             	mov    %r8,%rdx
  800218:	48 89 f7             	mov    %rsi,%rdi
  80021b:	cd 30                	int    $0x30
  if (check && ret > 0)
  80021d:	48 85 c0             	test   %rax,%rax
  800220:	7f 07                	jg     800229 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  800222:	48 83 c4 08          	add    $0x8,%rsp
  800226:	5b                   	pop    %rbx
  800227:	5d                   	pop    %rbp
  800228:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800229:	49 89 c0             	mov    %rax,%r8
  80022c:	b9 04 00 00 00       	mov    $0x4,%ecx
  800231:	48 ba 18 14 80 00 00 	movabs $0x801418,%rdx
  800238:	00 00 00 
  80023b:	be 22 00 00 00       	mov    $0x22,%esi
  800240:	48 bf 37 14 80 00 00 	movabs $0x801437,%rdi
  800247:	00 00 00 
  80024a:	b8 00 00 00 00       	mov    $0x0,%eax
  80024f:	49 b9 66 04 80 00 00 	movabs $0x800466,%r9
  800256:	00 00 00 
  800259:	41 ff d1             	callq  *%r9

000000000080025c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  80025c:	55                   	push   %rbp
  80025d:	48 89 e5             	mov    %rsp,%rbp
  800260:	53                   	push   %rbx
  800261:	48 83 ec 08          	sub    $0x8,%rsp
  800265:	41 89 f9             	mov    %edi,%r9d
  800268:	49 89 f2             	mov    %rsi,%r10
  80026b:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80026e:	4d 63 c9             	movslq %r9d,%r9
  800271:	48 63 da             	movslq %edx,%rbx
  800274:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  800277:	b8 05 00 00 00       	mov    $0x5,%eax
  80027c:	4c 89 ca             	mov    %r9,%rdx
  80027f:	4c 89 d1             	mov    %r10,%rcx
  800282:	cd 30                	int    $0x30
  if (check && ret > 0)
  800284:	48 85 c0             	test   %rax,%rax
  800287:	7f 07                	jg     800290 <sys_page_map+0x34>
}
  800289:	48 83 c4 08          	add    $0x8,%rsp
  80028d:	5b                   	pop    %rbx
  80028e:	5d                   	pop    %rbp
  80028f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800290:	49 89 c0             	mov    %rax,%r8
  800293:	b9 05 00 00 00       	mov    $0x5,%ecx
  800298:	48 ba 18 14 80 00 00 	movabs $0x801418,%rdx
  80029f:	00 00 00 
  8002a2:	be 22 00 00 00       	mov    $0x22,%esi
  8002a7:	48 bf 37 14 80 00 00 	movabs $0x801437,%rdi
  8002ae:	00 00 00 
  8002b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b6:	49 b9 66 04 80 00 00 	movabs $0x800466,%r9
  8002bd:	00 00 00 
  8002c0:	41 ff d1             	callq  *%r9

00000000008002c3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002c3:	55                   	push   %rbp
  8002c4:	48 89 e5             	mov    %rsp,%rbp
  8002c7:	53                   	push   %rbx
  8002c8:	48 83 ec 08          	sub    $0x8,%rsp
  8002cc:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002cf:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002d2:	be 00 00 00 00       	mov    $0x0,%esi
  8002d7:	b8 06 00 00 00       	mov    $0x6,%eax
  8002dc:	48 89 f3             	mov    %rsi,%rbx
  8002df:	48 89 f7             	mov    %rsi,%rdi
  8002e2:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002e4:	48 85 c0             	test   %rax,%rax
  8002e7:	7f 07                	jg     8002f0 <sys_page_unmap+0x2d>
}
  8002e9:	48 83 c4 08          	add    $0x8,%rsp
  8002ed:	5b                   	pop    %rbx
  8002ee:	5d                   	pop    %rbp
  8002ef:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002f0:	49 89 c0             	mov    %rax,%r8
  8002f3:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002f8:	48 ba 18 14 80 00 00 	movabs $0x801418,%rdx
  8002ff:	00 00 00 
  800302:	be 22 00 00 00       	mov    $0x22,%esi
  800307:	48 bf 37 14 80 00 00 	movabs $0x801437,%rdi
  80030e:	00 00 00 
  800311:	b8 00 00 00 00       	mov    $0x0,%eax
  800316:	49 b9 66 04 80 00 00 	movabs $0x800466,%r9
  80031d:	00 00 00 
  800320:	41 ff d1             	callq  *%r9

0000000000800323 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  800323:	55                   	push   %rbp
  800324:	48 89 e5             	mov    %rsp,%rbp
  800327:	53                   	push   %rbx
  800328:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80032c:	48 63 d7             	movslq %edi,%rdx
  80032f:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  800332:	bb 00 00 00 00       	mov    $0x0,%ebx
  800337:	b8 08 00 00 00       	mov    $0x8,%eax
  80033c:	48 89 df             	mov    %rbx,%rdi
  80033f:	48 89 de             	mov    %rbx,%rsi
  800342:	cd 30                	int    $0x30
  if (check && ret > 0)
  800344:	48 85 c0             	test   %rax,%rax
  800347:	7f 07                	jg     800350 <sys_env_set_status+0x2d>
}
  800349:	48 83 c4 08          	add    $0x8,%rsp
  80034d:	5b                   	pop    %rbx
  80034e:	5d                   	pop    %rbp
  80034f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800350:	49 89 c0             	mov    %rax,%r8
  800353:	b9 08 00 00 00       	mov    $0x8,%ecx
  800358:	48 ba 18 14 80 00 00 	movabs $0x801418,%rdx
  80035f:	00 00 00 
  800362:	be 22 00 00 00       	mov    $0x22,%esi
  800367:	48 bf 37 14 80 00 00 	movabs $0x801437,%rdi
  80036e:	00 00 00 
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	49 b9 66 04 80 00 00 	movabs $0x800466,%r9
  80037d:	00 00 00 
  800380:	41 ff d1             	callq  *%r9

0000000000800383 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  800383:	55                   	push   %rbp
  800384:	48 89 e5             	mov    %rsp,%rbp
  800387:	53                   	push   %rbx
  800388:	48 83 ec 08          	sub    $0x8,%rsp
  80038c:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80038f:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800392:	be 00 00 00 00       	mov    $0x0,%esi
  800397:	b8 09 00 00 00       	mov    $0x9,%eax
  80039c:	48 89 f3             	mov    %rsi,%rbx
  80039f:	48 89 f7             	mov    %rsi,%rdi
  8003a2:	cd 30                	int    $0x30
  if (check && ret > 0)
  8003a4:	48 85 c0             	test   %rax,%rax
  8003a7:	7f 07                	jg     8003b0 <sys_env_set_pgfault_upcall+0x2d>
}
  8003a9:	48 83 c4 08          	add    $0x8,%rsp
  8003ad:	5b                   	pop    %rbx
  8003ae:	5d                   	pop    %rbp
  8003af:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8003b0:	49 89 c0             	mov    %rax,%r8
  8003b3:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003b8:	48 ba 18 14 80 00 00 	movabs $0x801418,%rdx
  8003bf:	00 00 00 
  8003c2:	be 22 00 00 00       	mov    $0x22,%esi
  8003c7:	48 bf 37 14 80 00 00 	movabs $0x801437,%rdi
  8003ce:	00 00 00 
  8003d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d6:	49 b9 66 04 80 00 00 	movabs $0x800466,%r9
  8003dd:	00 00 00 
  8003e0:	41 ff d1             	callq  *%r9

00000000008003e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003e3:	55                   	push   %rbp
  8003e4:	48 89 e5             	mov    %rsp,%rbp
  8003e7:	53                   	push   %rbx
  8003e8:	49 89 f0             	mov    %rsi,%r8
  8003eb:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003ee:	48 63 d7             	movslq %edi,%rdx
  8003f1:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003f4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003f9:	be 00 00 00 00       	mov    $0x0,%esi
  8003fe:	4c 89 c1             	mov    %r8,%rcx
  800401:	cd 30                	int    $0x30
}
  800403:	5b                   	pop    %rbx
  800404:	5d                   	pop    %rbp
  800405:	c3                   	retq   

0000000000800406 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  800406:	55                   	push   %rbp
  800407:	48 89 e5             	mov    %rsp,%rbp
  80040a:	53                   	push   %rbx
  80040b:	48 83 ec 08          	sub    $0x8,%rsp
  80040f:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  800412:	be 00 00 00 00       	mov    $0x0,%esi
  800417:	b8 0c 00 00 00       	mov    $0xc,%eax
  80041c:	48 89 f1             	mov    %rsi,%rcx
  80041f:	48 89 f3             	mov    %rsi,%rbx
  800422:	48 89 f7             	mov    %rsi,%rdi
  800425:	cd 30                	int    $0x30
  if (check && ret > 0)
  800427:	48 85 c0             	test   %rax,%rax
  80042a:	7f 07                	jg     800433 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  80042c:	48 83 c4 08          	add    $0x8,%rsp
  800430:	5b                   	pop    %rbx
  800431:	5d                   	pop    %rbp
  800432:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800433:	49 89 c0             	mov    %rax,%r8
  800436:	b9 0c 00 00 00       	mov    $0xc,%ecx
  80043b:	48 ba 18 14 80 00 00 	movabs $0x801418,%rdx
  800442:	00 00 00 
  800445:	be 22 00 00 00       	mov    $0x22,%esi
  80044a:	48 bf 37 14 80 00 00 	movabs $0x801437,%rdi
  800451:	00 00 00 
  800454:	b8 00 00 00 00       	mov    $0x0,%eax
  800459:	49 b9 66 04 80 00 00 	movabs $0x800466,%r9
  800460:	00 00 00 
  800463:	41 ff d1             	callq  *%r9

0000000000800466 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800466:	55                   	push   %rbp
  800467:	48 89 e5             	mov    %rsp,%rbp
  80046a:	41 56                	push   %r14
  80046c:	41 55                	push   %r13
  80046e:	41 54                	push   %r12
  800470:	53                   	push   %rbx
  800471:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800478:	49 89 fd             	mov    %rdi,%r13
  80047b:	41 89 f6             	mov    %esi,%r14d
  80047e:	49 89 d4             	mov    %rdx,%r12
  800481:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800488:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80048f:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800496:	84 c0                	test   %al,%al
  800498:	74 26                	je     8004c0 <_panic+0x5a>
  80049a:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  8004a1:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8004a8:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8004ac:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8004b0:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8004b4:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8004b8:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8004bc:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004c0:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004c7:	00 00 00 
  8004ca:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004d1:	00 00 00 
  8004d4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004d8:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004df:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004e6:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ed:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  8004f4:	00 00 00 
  8004f7:	48 8b 18             	mov    (%rax),%rbx
  8004fa:	48 b8 b9 01 80 00 00 	movabs $0x8001b9,%rax
  800501:	00 00 00 
  800504:	ff d0                	callq  *%rax
  800506:	45 89 f0             	mov    %r14d,%r8d
  800509:	4c 89 e9             	mov    %r13,%rcx
  80050c:	48 89 da             	mov    %rbx,%rdx
  80050f:	89 c6                	mov    %eax,%esi
  800511:	48 bf 48 14 80 00 00 	movabs $0x801448,%rdi
  800518:	00 00 00 
  80051b:	b8 00 00 00 00       	mov    $0x0,%eax
  800520:	48 bb 08 06 80 00 00 	movabs $0x800608,%rbx
  800527:	00 00 00 
  80052a:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  80052c:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800533:	4c 89 e7             	mov    %r12,%rdi
  800536:	48 b8 a0 05 80 00 00 	movabs $0x8005a0,%rax
  80053d:	00 00 00 
  800540:	ff d0                	callq  *%rax
  cprintf("\n");
  800542:	48 bf 0c 14 80 00 00 	movabs $0x80140c,%rdi
  800549:	00 00 00 
  80054c:	b8 00 00 00 00       	mov    $0x0,%eax
  800551:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800553:	cc                   	int3   
  while (1)
  800554:	eb fd                	jmp    800553 <_panic+0xed>

0000000000800556 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800556:	55                   	push   %rbp
  800557:	48 89 e5             	mov    %rsp,%rbp
  80055a:	53                   	push   %rbx
  80055b:	48 83 ec 08          	sub    $0x8,%rsp
  80055f:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800562:	8b 06                	mov    (%rsi),%eax
  800564:	8d 50 01             	lea    0x1(%rax),%edx
  800567:	89 16                	mov    %edx,(%rsi)
  800569:	48 98                	cltq   
  80056b:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800570:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800576:	74 0b                	je     800583 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800578:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  80057c:	48 83 c4 08          	add    $0x8,%rsp
  800580:	5b                   	pop    %rbx
  800581:	5d                   	pop    %rbp
  800582:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800583:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800587:	be ff 00 00 00       	mov    $0xff,%esi
  80058c:	48 b8 1b 01 80 00 00 	movabs $0x80011b,%rax
  800593:	00 00 00 
  800596:	ff d0                	callq  *%rax
    b->idx = 0;
  800598:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80059e:	eb d8                	jmp    800578 <putch+0x22>

00000000008005a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8005a0:	55                   	push   %rbp
  8005a1:	48 89 e5             	mov    %rsp,%rbp
  8005a4:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8005ab:	48 89 fa             	mov    %rdi,%rdx
  8005ae:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8005b1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8005b8:	00 00 00 
  b.cnt = 0;
  8005bb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005c2:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005c5:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005cc:	48 bf 56 05 80 00 00 	movabs $0x800556,%rdi
  8005d3:	00 00 00 
  8005d6:	48 b8 c6 07 80 00 00 	movabs $0x8007c6,%rax
  8005dd:	00 00 00 
  8005e0:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005e2:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005e9:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005f0:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005f4:	48 b8 1b 01 80 00 00 	movabs $0x80011b,%rax
  8005fb:	00 00 00 
  8005fe:	ff d0                	callq  *%rax

  return b.cnt;
}
  800600:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800606:	c9                   	leaveq 
  800607:	c3                   	retq   

0000000000800608 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800608:	55                   	push   %rbp
  800609:	48 89 e5             	mov    %rsp,%rbp
  80060c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800613:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  80061a:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800621:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800628:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80062f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800636:	84 c0                	test   %al,%al
  800638:	74 20                	je     80065a <cprintf+0x52>
  80063a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80063e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800642:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800646:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80064a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80064e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800652:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800656:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80065a:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800661:	00 00 00 
  800664:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80066b:	00 00 00 
  80066e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800672:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800679:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800680:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800687:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80068e:	48 b8 a0 05 80 00 00 	movabs $0x8005a0,%rax
  800695:	00 00 00 
  800698:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80069a:	c9                   	leaveq 
  80069b:	c3                   	retq   

000000000080069c <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80069c:	55                   	push   %rbp
  80069d:	48 89 e5             	mov    %rsp,%rbp
  8006a0:	41 57                	push   %r15
  8006a2:	41 56                	push   %r14
  8006a4:	41 55                	push   %r13
  8006a6:	41 54                	push   %r12
  8006a8:	53                   	push   %rbx
  8006a9:	48 83 ec 18          	sub    $0x18,%rsp
  8006ad:	49 89 fc             	mov    %rdi,%r12
  8006b0:	49 89 f5             	mov    %rsi,%r13
  8006b3:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8006b7:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8006ba:	41 89 cf             	mov    %ecx,%r15d
  8006bd:	49 39 d7             	cmp    %rdx,%r15
  8006c0:	76 45                	jbe    800707 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006c2:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006c6:	85 db                	test   %ebx,%ebx
  8006c8:	7e 0e                	jle    8006d8 <printnum+0x3c>
      putch(padc, putdat);
  8006ca:	4c 89 ee             	mov    %r13,%rsi
  8006cd:	44 89 f7             	mov    %r14d,%edi
  8006d0:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006d3:	83 eb 01             	sub    $0x1,%ebx
  8006d6:	75 f2                	jne    8006ca <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006d8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e1:	49 f7 f7             	div    %r15
  8006e4:	48 b8 70 14 80 00 00 	movabs $0x801470,%rax
  8006eb:	00 00 00 
  8006ee:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006f2:	4c 89 ee             	mov    %r13,%rsi
  8006f5:	41 ff d4             	callq  *%r12
}
  8006f8:	48 83 c4 18          	add    $0x18,%rsp
  8006fc:	5b                   	pop    %rbx
  8006fd:	41 5c                	pop    %r12
  8006ff:	41 5d                	pop    %r13
  800701:	41 5e                	pop    %r14
  800703:	41 5f                	pop    %r15
  800705:	5d                   	pop    %rbp
  800706:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800707:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80070b:	ba 00 00 00 00       	mov    $0x0,%edx
  800710:	49 f7 f7             	div    %r15
  800713:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800717:	48 89 c2             	mov    %rax,%rdx
  80071a:	48 b8 9c 06 80 00 00 	movabs $0x80069c,%rax
  800721:	00 00 00 
  800724:	ff d0                	callq  *%rax
  800726:	eb b0                	jmp    8006d8 <printnum+0x3c>

0000000000800728 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800728:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80072c:	48 8b 06             	mov    (%rsi),%rax
  80072f:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800733:	73 0a                	jae    80073f <sprintputch+0x17>
    *b->buf++ = ch;
  800735:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800739:	48 89 16             	mov    %rdx,(%rsi)
  80073c:	40 88 38             	mov    %dil,(%rax)
}
  80073f:	c3                   	retq   

0000000000800740 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800740:	55                   	push   %rbp
  800741:	48 89 e5             	mov    %rsp,%rbp
  800744:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80074b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800752:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800759:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800760:	84 c0                	test   %al,%al
  800762:	74 20                	je     800784 <printfmt+0x44>
  800764:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800768:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80076c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800770:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800774:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800778:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80077c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800780:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800784:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80078b:	00 00 00 
  80078e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800795:	00 00 00 
  800798:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80079c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8007a3:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8007aa:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8007b1:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8007b8:	48 b8 c6 07 80 00 00 	movabs $0x8007c6,%rax
  8007bf:	00 00 00 
  8007c2:	ff d0                	callq  *%rax
}
  8007c4:	c9                   	leaveq 
  8007c5:	c3                   	retq   

00000000008007c6 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007c6:	55                   	push   %rbp
  8007c7:	48 89 e5             	mov    %rsp,%rbp
  8007ca:	41 57                	push   %r15
  8007cc:	41 56                	push   %r14
  8007ce:	41 55                	push   %r13
  8007d0:	41 54                	push   %r12
  8007d2:	53                   	push   %rbx
  8007d3:	48 83 ec 48          	sub    $0x48,%rsp
  8007d7:	49 89 fd             	mov    %rdi,%r13
  8007da:	49 89 f7             	mov    %rsi,%r15
  8007dd:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007e0:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007e4:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007e8:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007ec:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007f0:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007f4:	41 0f b6 3e          	movzbl (%r14),%edi
  8007f8:	83 ff 25             	cmp    $0x25,%edi
  8007fb:	74 18                	je     800815 <vprintfmt+0x4f>
      if (ch == '\0')
  8007fd:	85 ff                	test   %edi,%edi
  8007ff:	0f 84 8c 06 00 00    	je     800e91 <vprintfmt+0x6cb>
      putch(ch, putdat);
  800805:	4c 89 fe             	mov    %r15,%rsi
  800808:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80080b:	49 89 de             	mov    %rbx,%r14
  80080e:	eb e0                	jmp    8007f0 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800810:	49 89 de             	mov    %rbx,%r14
  800813:	eb db                	jmp    8007f0 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800815:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800819:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80081d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800824:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80082a:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80082e:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800833:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800839:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80083f:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800844:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800849:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80084d:	0f b6 13             	movzbl (%rbx),%edx
  800850:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800853:	3c 55                	cmp    $0x55,%al
  800855:	0f 87 8b 05 00 00    	ja     800de6 <vprintfmt+0x620>
  80085b:	0f b6 c0             	movzbl %al,%eax
  80085e:	49 bb 40 15 80 00 00 	movabs $0x801540,%r11
  800865:	00 00 00 
  800868:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80086c:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80086f:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800873:	eb d4                	jmp    800849 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800875:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800878:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80087c:	eb cb                	jmp    800849 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80087e:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800881:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800885:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800889:	8d 50 d0             	lea    -0x30(%rax),%edx
  80088c:	83 fa 09             	cmp    $0x9,%edx
  80088f:	77 7e                	ja     80090f <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800891:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800895:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800899:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80089e:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8008a2:	8d 50 d0             	lea    -0x30(%rax),%edx
  8008a5:	83 fa 09             	cmp    $0x9,%edx
  8008a8:	76 e7                	jbe    800891 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8008aa:	4c 89 f3             	mov    %r14,%rbx
  8008ad:	eb 19                	jmp    8008c8 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8008af:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008b2:	83 f8 2f             	cmp    $0x2f,%eax
  8008b5:	77 2a                	ja     8008e1 <vprintfmt+0x11b>
  8008b7:	89 c2                	mov    %eax,%edx
  8008b9:	4c 01 d2             	add    %r10,%rdx
  8008bc:	83 c0 08             	add    $0x8,%eax
  8008bf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008c2:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008c5:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008c8:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008cc:	0f 89 77 ff ff ff    	jns    800849 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008d2:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008d6:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008dc:	e9 68 ff ff ff       	jmpq   800849 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008e1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ed:	eb d3                	jmp    8008c2 <vprintfmt+0xfc>
        if (width < 0)
  8008ef:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008f8:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008fb:	4c 89 f3             	mov    %r14,%rbx
  8008fe:	e9 46 ff ff ff       	jmpq   800849 <vprintfmt+0x83>
  800903:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800906:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80090a:	e9 3a ff ff ff       	jmpq   800849 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80090f:	4c 89 f3             	mov    %r14,%rbx
  800912:	eb b4                	jmp    8008c8 <vprintfmt+0x102>
        lflag++;
  800914:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800917:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80091a:	e9 2a ff ff ff       	jmpq   800849 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80091f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800922:	83 f8 2f             	cmp    $0x2f,%eax
  800925:	77 19                	ja     800940 <vprintfmt+0x17a>
  800927:	89 c2                	mov    %eax,%edx
  800929:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092d:	83 c0 08             	add    $0x8,%eax
  800930:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800933:	4c 89 fe             	mov    %r15,%rsi
  800936:	8b 3a                	mov    (%rdx),%edi
  800938:	41 ff d5             	callq  *%r13
        break;
  80093b:	e9 b0 fe ff ff       	jmpq   8007f0 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800940:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800944:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800948:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80094c:	eb e5                	jmp    800933 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80094e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800951:	83 f8 2f             	cmp    $0x2f,%eax
  800954:	77 5b                	ja     8009b1 <vprintfmt+0x1eb>
  800956:	89 c2                	mov    %eax,%edx
  800958:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80095c:	83 c0 08             	add    $0x8,%eax
  80095f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800962:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800964:	89 c8                	mov    %ecx,%eax
  800966:	c1 f8 1f             	sar    $0x1f,%eax
  800969:	31 c1                	xor    %eax,%ecx
  80096b:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80096d:	83 f9 0b             	cmp    $0xb,%ecx
  800970:	7f 4d                	jg     8009bf <vprintfmt+0x1f9>
  800972:	48 63 c1             	movslq %ecx,%rax
  800975:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  80097c:	00 00 00 
  80097f:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800983:	48 85 c0             	test   %rax,%rax
  800986:	74 37                	je     8009bf <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800988:	48 89 c1             	mov    %rax,%rcx
  80098b:	48 ba 91 14 80 00 00 	movabs $0x801491,%rdx
  800992:	00 00 00 
  800995:	4c 89 fe             	mov    %r15,%rsi
  800998:	4c 89 ef             	mov    %r13,%rdi
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	48 bb 40 07 80 00 00 	movabs $0x800740,%rbx
  8009a7:	00 00 00 
  8009aa:	ff d3                	callq  *%rbx
  8009ac:	e9 3f fe ff ff       	jmpq   8007f0 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8009b1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009b5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009bd:	eb a3                	jmp    800962 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009bf:	48 ba 88 14 80 00 00 	movabs $0x801488,%rdx
  8009c6:	00 00 00 
  8009c9:	4c 89 fe             	mov    %r15,%rsi
  8009cc:	4c 89 ef             	mov    %r13,%rdi
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	48 bb 40 07 80 00 00 	movabs $0x800740,%rbx
  8009db:	00 00 00 
  8009de:	ff d3                	callq  *%rbx
  8009e0:	e9 0b fe ff ff       	jmpq   8007f0 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009e5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e8:	83 f8 2f             	cmp    $0x2f,%eax
  8009eb:	77 4b                	ja     800a38 <vprintfmt+0x272>
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009f3:	83 c0 08             	add    $0x8,%eax
  8009f6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f9:	48 8b 02             	mov    (%rdx),%rax
  8009fc:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800a00:	48 85 c0             	test   %rax,%rax
  800a03:	0f 84 05 04 00 00    	je     800e0e <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800a09:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a0d:	7e 06                	jle    800a15 <vprintfmt+0x24f>
  800a0f:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a13:	75 31                	jne    800a46 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a15:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a19:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a1d:	0f b6 00             	movzbl (%rax),%eax
  800a20:	0f be f8             	movsbl %al,%edi
  800a23:	85 ff                	test   %edi,%edi
  800a25:	0f 84 c3 00 00 00    	je     800aee <vprintfmt+0x328>
  800a2b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a2f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a33:	e9 85 00 00 00       	jmpq   800abd <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a38:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a3c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a40:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a44:	eb b3                	jmp    8009f9 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a46:	49 63 f4             	movslq %r12d,%rsi
  800a49:	48 89 c7             	mov    %rax,%rdi
  800a4c:	48 b8 9d 0f 80 00 00 	movabs $0x800f9d,%rax
  800a53:	00 00 00 
  800a56:	ff d0                	callq  *%rax
  800a58:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a5b:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a5e:	85 f6                	test   %esi,%esi
  800a60:	7e 22                	jle    800a84 <vprintfmt+0x2be>
            putch(padc, putdat);
  800a62:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a66:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a6a:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a6e:	4c 89 fe             	mov    %r15,%rsi
  800a71:	89 df                	mov    %ebx,%edi
  800a73:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a76:	41 83 ec 01          	sub    $0x1,%r12d
  800a7a:	75 f2                	jne    800a6e <vprintfmt+0x2a8>
  800a7c:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a80:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a84:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a88:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a8c:	0f b6 00             	movzbl (%rax),%eax
  800a8f:	0f be f8             	movsbl %al,%edi
  800a92:	85 ff                	test   %edi,%edi
  800a94:	0f 84 56 fd ff ff    	je     8007f0 <vprintfmt+0x2a>
  800a9a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a9e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800aa2:	eb 19                	jmp    800abd <vprintfmt+0x2f7>
            putch(ch, putdat);
  800aa4:	4c 89 fe             	mov    %r15,%rsi
  800aa7:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aaa:	41 83 ee 01          	sub    $0x1,%r14d
  800aae:	48 83 c3 01          	add    $0x1,%rbx
  800ab2:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800ab6:	0f be f8             	movsbl %al,%edi
  800ab9:	85 ff                	test   %edi,%edi
  800abb:	74 29                	je     800ae6 <vprintfmt+0x320>
  800abd:	45 85 e4             	test   %r12d,%r12d
  800ac0:	78 06                	js     800ac8 <vprintfmt+0x302>
  800ac2:	41 83 ec 01          	sub    $0x1,%r12d
  800ac6:	78 48                	js     800b10 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800ac8:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800acc:	74 d6                	je     800aa4 <vprintfmt+0x2de>
  800ace:	0f be c0             	movsbl %al,%eax
  800ad1:	83 e8 20             	sub    $0x20,%eax
  800ad4:	83 f8 5e             	cmp    $0x5e,%eax
  800ad7:	76 cb                	jbe    800aa4 <vprintfmt+0x2de>
            putch('?', putdat);
  800ad9:	4c 89 fe             	mov    %r15,%rsi
  800adc:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ae1:	41 ff d5             	callq  *%r13
  800ae4:	eb c4                	jmp    800aaa <vprintfmt+0x2e4>
  800ae6:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800aea:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800aee:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800af1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800af5:	0f 8e f5 fc ff ff    	jle    8007f0 <vprintfmt+0x2a>
          putch(' ', putdat);
  800afb:	4c 89 fe             	mov    %r15,%rsi
  800afe:	bf 20 00 00 00       	mov    $0x20,%edi
  800b03:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800b06:	83 eb 01             	sub    $0x1,%ebx
  800b09:	75 f0                	jne    800afb <vprintfmt+0x335>
  800b0b:	e9 e0 fc ff ff       	jmpq   8007f0 <vprintfmt+0x2a>
  800b10:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b14:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b18:	eb d4                	jmp    800aee <vprintfmt+0x328>
  if (lflag >= 2)
  800b1a:	83 f9 01             	cmp    $0x1,%ecx
  800b1d:	7f 1d                	jg     800b3c <vprintfmt+0x376>
  else if (lflag)
  800b1f:	85 c9                	test   %ecx,%ecx
  800b21:	74 5e                	je     800b81 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b23:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b26:	83 f8 2f             	cmp    $0x2f,%eax
  800b29:	77 48                	ja     800b73 <vprintfmt+0x3ad>
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b31:	83 c0 08             	add    $0x8,%eax
  800b34:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b37:	48 8b 1a             	mov    (%rdx),%rbx
  800b3a:	eb 17                	jmp    800b53 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b3c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b3f:	83 f8 2f             	cmp    $0x2f,%eax
  800b42:	77 21                	ja     800b65 <vprintfmt+0x39f>
  800b44:	89 c2                	mov    %eax,%edx
  800b46:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b4a:	83 c0 08             	add    $0x8,%eax
  800b4d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b50:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b53:	48 85 db             	test   %rbx,%rbx
  800b56:	78 50                	js     800ba8 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b58:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b5b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b60:	e9 b4 01 00 00       	jmpq   800d19 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b65:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b69:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b6d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b71:	eb dd                	jmp    800b50 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b73:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b77:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b7b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b7f:	eb b6                	jmp    800b37 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b81:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b84:	83 f8 2f             	cmp    $0x2f,%eax
  800b87:	77 11                	ja     800b9a <vprintfmt+0x3d4>
  800b89:	89 c2                	mov    %eax,%edx
  800b8b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b8f:	83 c0 08             	add    $0x8,%eax
  800b92:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b95:	48 63 1a             	movslq (%rdx),%rbx
  800b98:	eb b9                	jmp    800b53 <vprintfmt+0x38d>
  800b9a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b9e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ba2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ba6:	eb ed                	jmp    800b95 <vprintfmt+0x3cf>
          putch('-', putdat);
  800ba8:	4c 89 fe             	mov    %r15,%rsi
  800bab:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800bb0:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800bb3:	48 89 da             	mov    %rbx,%rdx
  800bb6:	48 f7 da             	neg    %rdx
        base = 10;
  800bb9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bbe:	e9 56 01 00 00       	jmpq   800d19 <vprintfmt+0x553>
  if (lflag >= 2)
  800bc3:	83 f9 01             	cmp    $0x1,%ecx
  800bc6:	7f 25                	jg     800bed <vprintfmt+0x427>
  else if (lflag)
  800bc8:	85 c9                	test   %ecx,%ecx
  800bca:	74 5e                	je     800c2a <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bcc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bcf:	83 f8 2f             	cmp    $0x2f,%eax
  800bd2:	77 48                	ja     800c1c <vprintfmt+0x456>
  800bd4:	89 c2                	mov    %eax,%edx
  800bd6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bda:	83 c0 08             	add    $0x8,%eax
  800bdd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800be0:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800be3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800be8:	e9 2c 01 00 00       	jmpq   800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bed:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bf0:	83 f8 2f             	cmp    $0x2f,%eax
  800bf3:	77 19                	ja     800c0e <vprintfmt+0x448>
  800bf5:	89 c2                	mov    %eax,%edx
  800bf7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bfb:	83 c0 08             	add    $0x8,%eax
  800bfe:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c01:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800c04:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c09:	e9 0b 01 00 00       	jmpq   800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c0e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c12:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c16:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c1a:	eb e5                	jmp    800c01 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c1c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c20:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c24:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c28:	eb b6                	jmp    800be0 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c2a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c2d:	83 f8 2f             	cmp    $0x2f,%eax
  800c30:	77 18                	ja     800c4a <vprintfmt+0x484>
  800c32:	89 c2                	mov    %eax,%edx
  800c34:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c38:	83 c0 08             	add    $0x8,%eax
  800c3b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c3e:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c40:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c45:	e9 cf 00 00 00       	jmpq   800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c4a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c4e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c52:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c56:	eb e6                	jmp    800c3e <vprintfmt+0x478>
  if (lflag >= 2)
  800c58:	83 f9 01             	cmp    $0x1,%ecx
  800c5b:	7f 25                	jg     800c82 <vprintfmt+0x4bc>
  else if (lflag)
  800c5d:	85 c9                	test   %ecx,%ecx
  800c5f:	74 5b                	je     800cbc <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c61:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c64:	83 f8 2f             	cmp    $0x2f,%eax
  800c67:	77 45                	ja     800cae <vprintfmt+0x4e8>
  800c69:	89 c2                	mov    %eax,%edx
  800c6b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c6f:	83 c0 08             	add    $0x8,%eax
  800c72:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c75:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c78:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c7d:	e9 97 00 00 00       	jmpq   800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c82:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c85:	83 f8 2f             	cmp    $0x2f,%eax
  800c88:	77 16                	ja     800ca0 <vprintfmt+0x4da>
  800c8a:	89 c2                	mov    %eax,%edx
  800c8c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c90:	83 c0 08             	add    $0x8,%eax
  800c93:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c96:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c99:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c9e:	eb 79                	jmp    800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ca0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ca4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ca8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cac:	eb e8                	jmp    800c96 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800cae:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cb2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cb6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cba:	eb b9                	jmp    800c75 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800cbc:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cbf:	83 f8 2f             	cmp    $0x2f,%eax
  800cc2:	77 15                	ja     800cd9 <vprintfmt+0x513>
  800cc4:	89 c2                	mov    %eax,%edx
  800cc6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cca:	83 c0 08             	add    $0x8,%eax
  800ccd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cd0:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cd2:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cd7:	eb 40                	jmp    800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cd9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cdd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ce1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ce5:	eb e9                	jmp    800cd0 <vprintfmt+0x50a>
        putch('0', putdat);
  800ce7:	4c 89 fe             	mov    %r15,%rsi
  800cea:	bf 30 00 00 00       	mov    $0x30,%edi
  800cef:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cf2:	4c 89 fe             	mov    %r15,%rsi
  800cf5:	bf 78 00 00 00       	mov    $0x78,%edi
  800cfa:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cfd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d00:	83 f8 2f             	cmp    $0x2f,%eax
  800d03:	77 34                	ja     800d39 <vprintfmt+0x573>
  800d05:	89 c2                	mov    %eax,%edx
  800d07:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d0b:	83 c0 08             	add    $0x8,%eax
  800d0e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d11:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d14:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d19:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d1e:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d22:	4c 89 fe             	mov    %r15,%rsi
  800d25:	4c 89 ef             	mov    %r13,%rdi
  800d28:	48 b8 9c 06 80 00 00 	movabs $0x80069c,%rax
  800d2f:	00 00 00 
  800d32:	ff d0                	callq  *%rax
        break;
  800d34:	e9 b7 fa ff ff       	jmpq   8007f0 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d39:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d3d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d41:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d45:	eb ca                	jmp    800d11 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d47:	83 f9 01             	cmp    $0x1,%ecx
  800d4a:	7f 22                	jg     800d6e <vprintfmt+0x5a8>
  else if (lflag)
  800d4c:	85 c9                	test   %ecx,%ecx
  800d4e:	74 58                	je     800da8 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d50:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d53:	83 f8 2f             	cmp    $0x2f,%eax
  800d56:	77 42                	ja     800d9a <vprintfmt+0x5d4>
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d5e:	83 c0 08             	add    $0x8,%eax
  800d61:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d64:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d67:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d6c:	eb ab                	jmp    800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d6e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d71:	83 f8 2f             	cmp    $0x2f,%eax
  800d74:	77 16                	ja     800d8c <vprintfmt+0x5c6>
  800d76:	89 c2                	mov    %eax,%edx
  800d78:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d7c:	83 c0 08             	add    $0x8,%eax
  800d7f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d82:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d85:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d8a:	eb 8d                	jmp    800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d8c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d90:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d94:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d98:	eb e8                	jmp    800d82 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d9a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d9e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800da2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800da6:	eb bc                	jmp    800d64 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800da8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800dab:	83 f8 2f             	cmp    $0x2f,%eax
  800dae:	77 18                	ja     800dc8 <vprintfmt+0x602>
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800db6:	83 c0 08             	add    $0x8,%eax
  800db9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800dbc:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800dbe:	b9 10 00 00 00       	mov    $0x10,%ecx
  800dc3:	e9 51 ff ff ff       	jmpq   800d19 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800dc8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800dcc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800dd0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dd4:	eb e6                	jmp    800dbc <vprintfmt+0x5f6>
        putch(ch, putdat);
  800dd6:	4c 89 fe             	mov    %r15,%rsi
  800dd9:	bf 25 00 00 00       	mov    $0x25,%edi
  800dde:	41 ff d5             	callq  *%r13
        break;
  800de1:	e9 0a fa ff ff       	jmpq   8007f0 <vprintfmt+0x2a>
        putch('%', putdat);
  800de6:	4c 89 fe             	mov    %r15,%rsi
  800de9:	bf 25 00 00 00       	mov    $0x25,%edi
  800dee:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800df1:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800df5:	0f 84 15 fa ff ff    	je     800810 <vprintfmt+0x4a>
  800dfb:	49 89 de             	mov    %rbx,%r14
  800dfe:	49 83 ee 01          	sub    $0x1,%r14
  800e02:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800e07:	75 f5                	jne    800dfe <vprintfmt+0x638>
  800e09:	e9 e2 f9 ff ff       	jmpq   8007f0 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800e0e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800e12:	74 06                	je     800e1a <vprintfmt+0x654>
  800e14:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e18:	7f 21                	jg     800e3b <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e1a:	bf 28 00 00 00       	mov    $0x28,%edi
  800e1f:	48 bb 82 14 80 00 00 	movabs $0x801482,%rbx
  800e26:	00 00 00 
  800e29:	b8 28 00 00 00       	mov    $0x28,%eax
  800e2e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e32:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e36:	e9 82 fc ff ff       	jmpq   800abd <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e3b:	49 63 f4             	movslq %r12d,%rsi
  800e3e:	48 bf 81 14 80 00 00 	movabs $0x801481,%rdi
  800e45:	00 00 00 
  800e48:	48 b8 9d 0f 80 00 00 	movabs $0x800f9d,%rax
  800e4f:	00 00 00 
  800e52:	ff d0                	callq  *%rax
  800e54:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e57:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e5a:	48 be 81 14 80 00 00 	movabs $0x801481,%rsi
  800e61:	00 00 00 
  800e64:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	0f 8f f2 fb ff ff    	jg     800a62 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e70:	48 bb 82 14 80 00 00 	movabs $0x801482,%rbx
  800e77:	00 00 00 
  800e7a:	b8 28 00 00 00       	mov    $0x28,%eax
  800e7f:	bf 28 00 00 00       	mov    $0x28,%edi
  800e84:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e88:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e8c:	e9 2c fc ff ff       	jmpq   800abd <vprintfmt+0x2f7>
}
  800e91:	48 83 c4 48          	add    $0x48,%rsp
  800e95:	5b                   	pop    %rbx
  800e96:	41 5c                	pop    %r12
  800e98:	41 5d                	pop    %r13
  800e9a:	41 5e                	pop    %r14
  800e9c:	41 5f                	pop    %r15
  800e9e:	5d                   	pop    %rbp
  800e9f:	c3                   	retq   

0000000000800ea0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800ea0:	55                   	push   %rbp
  800ea1:	48 89 e5             	mov    %rsp,%rbp
  800ea4:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800ea8:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800eac:	48 63 c6             	movslq %esi,%rax
  800eaf:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800eb4:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800eb8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ebf:	48 85 ff             	test   %rdi,%rdi
  800ec2:	74 2a                	je     800eee <vsnprintf+0x4e>
  800ec4:	85 f6                	test   %esi,%esi
  800ec6:	7e 26                	jle    800eee <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ec8:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800ecc:	48 bf 28 07 80 00 00 	movabs $0x800728,%rdi
  800ed3:	00 00 00 
  800ed6:	48 b8 c6 07 80 00 00 	movabs $0x8007c6,%rax
  800edd:	00 00 00 
  800ee0:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ee2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ee6:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ee9:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800eec:	c9                   	leaveq 
  800eed:	c3                   	retq   
    return -E_INVAL;
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef3:	eb f7                	jmp    800eec <vsnprintf+0x4c>

0000000000800ef5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ef5:	55                   	push   %rbp
  800ef6:	48 89 e5             	mov    %rsp,%rbp
  800ef9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800f00:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800f07:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f0e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f15:	84 c0                	test   %al,%al
  800f17:	74 20                	je     800f39 <snprintf+0x44>
  800f19:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f1d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f21:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f25:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f29:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f2d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f31:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f35:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f39:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f40:	00 00 00 
  800f43:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f4a:	00 00 00 
  800f4d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f51:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f58:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f5f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f66:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f6d:	48 b8 a0 0e 80 00 00 	movabs $0x800ea0,%rax
  800f74:	00 00 00 
  800f77:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f79:	c9                   	leaveq 
  800f7a:	c3                   	retq   

0000000000800f7b <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f7b:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f7e:	74 17                	je     800f97 <strlen+0x1c>
  800f80:	48 89 fa             	mov    %rdi,%rdx
  800f83:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f88:	29 f9                	sub    %edi,%ecx
    n++;
  800f8a:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f8d:	48 83 c2 01          	add    $0x1,%rdx
  800f91:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f94:	75 f4                	jne    800f8a <strlen+0xf>
  800f96:	c3                   	retq   
  800f97:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f9c:	c3                   	retq   

0000000000800f9d <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9d:	48 85 f6             	test   %rsi,%rsi
  800fa0:	74 24                	je     800fc6 <strnlen+0x29>
  800fa2:	80 3f 00             	cmpb   $0x0,(%rdi)
  800fa5:	74 25                	je     800fcc <strnlen+0x2f>
  800fa7:	48 01 fe             	add    %rdi,%rsi
  800faa:	48 89 fa             	mov    %rdi,%rdx
  800fad:	b9 01 00 00 00       	mov    $0x1,%ecx
  800fb2:	29 f9                	sub    %edi,%ecx
    n++;
  800fb4:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fb7:	48 83 c2 01          	add    $0x1,%rdx
  800fbb:	48 39 f2             	cmp    %rsi,%rdx
  800fbe:	74 11                	je     800fd1 <strnlen+0x34>
  800fc0:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fc3:	75 ef                	jne    800fb4 <strnlen+0x17>
  800fc5:	c3                   	retq   
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	c3                   	retq   
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fd1:	c3                   	retq   

0000000000800fd2 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fd2:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fda:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fde:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fe1:	48 83 c2 01          	add    $0x1,%rdx
  800fe5:	84 c9                	test   %cl,%cl
  800fe7:	75 f1                	jne    800fda <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fe9:	c3                   	retq   

0000000000800fea <strcat>:

char *
strcat(char *dst, const char *src) {
  800fea:	55                   	push   %rbp
  800feb:	48 89 e5             	mov    %rsp,%rbp
  800fee:	41 54                	push   %r12
  800ff0:	53                   	push   %rbx
  800ff1:	48 89 fb             	mov    %rdi,%rbx
  800ff4:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800ff7:	48 b8 7b 0f 80 00 00 	movabs $0x800f7b,%rax
  800ffe:	00 00 00 
  801001:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  801003:	48 63 f8             	movslq %eax,%rdi
  801006:	48 01 df             	add    %rbx,%rdi
  801009:	4c 89 e6             	mov    %r12,%rsi
  80100c:	48 b8 d2 0f 80 00 00 	movabs $0x800fd2,%rax
  801013:	00 00 00 
  801016:	ff d0                	callq  *%rax
  return dst;
}
  801018:	48 89 d8             	mov    %rbx,%rax
  80101b:	5b                   	pop    %rbx
  80101c:	41 5c                	pop    %r12
  80101e:	5d                   	pop    %rbp
  80101f:	c3                   	retq   

0000000000801020 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801020:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801023:	48 85 d2             	test   %rdx,%rdx
  801026:	74 1f                	je     801047 <strncpy+0x27>
  801028:	48 01 fa             	add    %rdi,%rdx
  80102b:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  80102e:	48 83 c1 01          	add    $0x1,%rcx
  801032:	44 0f b6 06          	movzbl (%rsi),%r8d
  801036:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  80103a:	41 80 f8 01          	cmp    $0x1,%r8b
  80103e:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  801042:	48 39 ca             	cmp    %rcx,%rdx
  801045:	75 e7                	jne    80102e <strncpy+0xe>
  }
  return ret;
}
  801047:	c3                   	retq   

0000000000801048 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801048:	48 89 f8             	mov    %rdi,%rax
  80104b:	48 85 d2             	test   %rdx,%rdx
  80104e:	74 36                	je     801086 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  801050:	48 83 fa 01          	cmp    $0x1,%rdx
  801054:	74 2d                	je     801083 <strlcpy+0x3b>
  801056:	44 0f b6 06          	movzbl (%rsi),%r8d
  80105a:	45 84 c0             	test   %r8b,%r8b
  80105d:	74 24                	je     801083 <strlcpy+0x3b>
  80105f:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801063:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801068:	48 83 c0 01          	add    $0x1,%rax
  80106c:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  801070:	48 39 d1             	cmp    %rdx,%rcx
  801073:	74 0e                	je     801083 <strlcpy+0x3b>
  801075:	48 83 c1 01          	add    $0x1,%rcx
  801079:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  80107e:	45 84 c0             	test   %r8b,%r8b
  801081:	75 e5                	jne    801068 <strlcpy+0x20>
    *dst = '\0';
  801083:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  801086:	48 29 f8             	sub    %rdi,%rax
}
  801089:	c3                   	retq   

000000000080108a <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  80108a:	0f b6 07             	movzbl (%rdi),%eax
  80108d:	84 c0                	test   %al,%al
  80108f:	74 17                	je     8010a8 <strcmp+0x1e>
  801091:	3a 06                	cmp    (%rsi),%al
  801093:	75 13                	jne    8010a8 <strcmp+0x1e>
    p++, q++;
  801095:	48 83 c7 01          	add    $0x1,%rdi
  801099:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  80109d:	0f b6 07             	movzbl (%rdi),%eax
  8010a0:	84 c0                	test   %al,%al
  8010a2:	74 04                	je     8010a8 <strcmp+0x1e>
  8010a4:	3a 06                	cmp    (%rsi),%al
  8010a6:	74 ed                	je     801095 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8010a8:	0f b6 c0             	movzbl %al,%eax
  8010ab:	0f b6 16             	movzbl (%rsi),%edx
  8010ae:	29 d0                	sub    %edx,%eax
}
  8010b0:	c3                   	retq   

00000000008010b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8010b1:	48 85 d2             	test   %rdx,%rdx
  8010b4:	74 2f                	je     8010e5 <strncmp+0x34>
  8010b6:	0f b6 07             	movzbl (%rdi),%eax
  8010b9:	84 c0                	test   %al,%al
  8010bb:	74 1f                	je     8010dc <strncmp+0x2b>
  8010bd:	3a 06                	cmp    (%rsi),%al
  8010bf:	75 1b                	jne    8010dc <strncmp+0x2b>
  8010c1:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010c4:	48 83 c7 01          	add    $0x1,%rdi
  8010c8:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010cc:	48 39 d7             	cmp    %rdx,%rdi
  8010cf:	74 1a                	je     8010eb <strncmp+0x3a>
  8010d1:	0f b6 07             	movzbl (%rdi),%eax
  8010d4:	84 c0                	test   %al,%al
  8010d6:	74 04                	je     8010dc <strncmp+0x2b>
  8010d8:	3a 06                	cmp    (%rsi),%al
  8010da:	74 e8                	je     8010c4 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010dc:	0f b6 07             	movzbl (%rdi),%eax
  8010df:	0f b6 16             	movzbl (%rsi),%edx
  8010e2:	29 d0                	sub    %edx,%eax
}
  8010e4:	c3                   	retq   
    return 0;
  8010e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ea:	c3                   	retq   
  8010eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f0:	c3                   	retq   

00000000008010f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010f1:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010f3:	0f b6 07             	movzbl (%rdi),%eax
  8010f6:	84 c0                	test   %al,%al
  8010f8:	74 1e                	je     801118 <strchr+0x27>
    if (*s == c)
  8010fa:	40 38 c6             	cmp    %al,%sil
  8010fd:	74 1f                	je     80111e <strchr+0x2d>
  for (; *s; s++)
  8010ff:	48 83 c7 01          	add    $0x1,%rdi
  801103:	0f b6 07             	movzbl (%rdi),%eax
  801106:	84 c0                	test   %al,%al
  801108:	74 08                	je     801112 <strchr+0x21>
    if (*s == c)
  80110a:	38 d0                	cmp    %dl,%al
  80110c:	75 f1                	jne    8010ff <strchr+0xe>
  for (; *s; s++)
  80110e:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  801111:	c3                   	retq   
  return 0;
  801112:	b8 00 00 00 00       	mov    $0x0,%eax
  801117:	c3                   	retq   
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	c3                   	retq   
    if (*s == c)
  80111e:	48 89 f8             	mov    %rdi,%rax
  801121:	c3                   	retq   

0000000000801122 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801122:	48 89 f8             	mov    %rdi,%rax
  801125:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  801127:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  80112a:	40 38 f2             	cmp    %sil,%dl
  80112d:	74 13                	je     801142 <strfind+0x20>
  80112f:	84 d2                	test   %dl,%dl
  801131:	74 0f                	je     801142 <strfind+0x20>
  for (; *s; s++)
  801133:	48 83 c0 01          	add    $0x1,%rax
  801137:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  80113a:	38 ca                	cmp    %cl,%dl
  80113c:	74 04                	je     801142 <strfind+0x20>
  80113e:	84 d2                	test   %dl,%dl
  801140:	75 f1                	jne    801133 <strfind+0x11>
      break;
  return (char *)s;
}
  801142:	c3                   	retq   

0000000000801143 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801143:	48 85 d2             	test   %rdx,%rdx
  801146:	74 3a                	je     801182 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801148:	48 89 f8             	mov    %rdi,%rax
  80114b:	48 09 d0             	or     %rdx,%rax
  80114e:	a8 03                	test   $0x3,%al
  801150:	75 28                	jne    80117a <memset+0x37>
    uint32_t k = c & 0xFFU;
  801152:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801156:	89 f0                	mov    %esi,%eax
  801158:	c1 e0 08             	shl    $0x8,%eax
  80115b:	89 f1                	mov    %esi,%ecx
  80115d:	c1 e1 18             	shl    $0x18,%ecx
  801160:	41 89 f0             	mov    %esi,%r8d
  801163:	41 c1 e0 10          	shl    $0x10,%r8d
  801167:	44 09 c1             	or     %r8d,%ecx
  80116a:	09 ce                	or     %ecx,%esi
  80116c:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  80116e:	48 c1 ea 02          	shr    $0x2,%rdx
  801172:	48 89 d1             	mov    %rdx,%rcx
  801175:	fc                   	cld    
  801176:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801178:	eb 08                	jmp    801182 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  80117a:	89 f0                	mov    %esi,%eax
  80117c:	48 89 d1             	mov    %rdx,%rcx
  80117f:	fc                   	cld    
  801180:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  801182:	48 89 f8             	mov    %rdi,%rax
  801185:	c3                   	retq   

0000000000801186 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  801186:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801189:	48 39 fe             	cmp    %rdi,%rsi
  80118c:	73 40                	jae    8011ce <memmove+0x48>
  80118e:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  801192:	48 39 f9             	cmp    %rdi,%rcx
  801195:	76 37                	jbe    8011ce <memmove+0x48>
    s += n;
    d += n;
  801197:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  80119b:	48 89 fe             	mov    %rdi,%rsi
  80119e:	48 09 d6             	or     %rdx,%rsi
  8011a1:	48 09 ce             	or     %rcx,%rsi
  8011a4:	40 f6 c6 03          	test   $0x3,%sil
  8011a8:	75 14                	jne    8011be <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8011aa:	48 83 ef 04          	sub    $0x4,%rdi
  8011ae:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8011b2:	48 c1 ea 02          	shr    $0x2,%rdx
  8011b6:	48 89 d1             	mov    %rdx,%rcx
  8011b9:	fd                   	std    
  8011ba:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011bc:	eb 0e                	jmp    8011cc <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011be:	48 83 ef 01          	sub    $0x1,%rdi
  8011c2:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011c6:	48 89 d1             	mov    %rdx,%rcx
  8011c9:	fd                   	std    
  8011ca:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011cc:	fc                   	cld    
  8011cd:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011ce:	48 89 c1             	mov    %rax,%rcx
  8011d1:	48 09 d1             	or     %rdx,%rcx
  8011d4:	48 09 f1             	or     %rsi,%rcx
  8011d7:	f6 c1 03             	test   $0x3,%cl
  8011da:	75 0e                	jne    8011ea <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011dc:	48 c1 ea 02          	shr    $0x2,%rdx
  8011e0:	48 89 d1             	mov    %rdx,%rcx
  8011e3:	48 89 c7             	mov    %rax,%rdi
  8011e6:	fc                   	cld    
  8011e7:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011e9:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011ea:	48 89 c7             	mov    %rax,%rdi
  8011ed:	48 89 d1             	mov    %rdx,%rcx
  8011f0:	fc                   	cld    
  8011f1:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011f3:	c3                   	retq   

00000000008011f4 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011f4:	55                   	push   %rbp
  8011f5:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011f8:	48 b8 86 11 80 00 00 	movabs $0x801186,%rax
  8011ff:	00 00 00 
  801202:	ff d0                	callq  *%rax
}
  801204:	5d                   	pop    %rbp
  801205:	c3                   	retq   

0000000000801206 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  801206:	55                   	push   %rbp
  801207:	48 89 e5             	mov    %rsp,%rbp
  80120a:	41 57                	push   %r15
  80120c:	41 56                	push   %r14
  80120e:	41 55                	push   %r13
  801210:	41 54                	push   %r12
  801212:	53                   	push   %rbx
  801213:	48 83 ec 08          	sub    $0x8,%rsp
  801217:	49 89 fe             	mov    %rdi,%r14
  80121a:	49 89 f7             	mov    %rsi,%r15
  80121d:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801220:	48 89 f7             	mov    %rsi,%rdi
  801223:	48 b8 7b 0f 80 00 00 	movabs $0x800f7b,%rax
  80122a:	00 00 00 
  80122d:	ff d0                	callq  *%rax
  80122f:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801232:	4c 89 ee             	mov    %r13,%rsi
  801235:	4c 89 f7             	mov    %r14,%rdi
  801238:	48 b8 9d 0f 80 00 00 	movabs $0x800f9d,%rax
  80123f:	00 00 00 
  801242:	ff d0                	callq  *%rax
  801244:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  801247:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  80124b:	4d 39 e5             	cmp    %r12,%r13
  80124e:	74 26                	je     801276 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801250:	4c 89 e8             	mov    %r13,%rax
  801253:	4c 29 e0             	sub    %r12,%rax
  801256:	48 39 d8             	cmp    %rbx,%rax
  801259:	76 2a                	jbe    801285 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  80125b:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  80125f:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801263:	4c 89 fe             	mov    %r15,%rsi
  801266:	48 b8 f4 11 80 00 00 	movabs $0x8011f4,%rax
  80126d:	00 00 00 
  801270:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801272:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801276:	48 83 c4 08          	add    $0x8,%rsp
  80127a:	5b                   	pop    %rbx
  80127b:	41 5c                	pop    %r12
  80127d:	41 5d                	pop    %r13
  80127f:	41 5e                	pop    %r14
  801281:	41 5f                	pop    %r15
  801283:	5d                   	pop    %rbp
  801284:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801285:	49 83 ed 01          	sub    $0x1,%r13
  801289:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80128d:	4c 89 ea             	mov    %r13,%rdx
  801290:	4c 89 fe             	mov    %r15,%rsi
  801293:	48 b8 f4 11 80 00 00 	movabs $0x8011f4,%rax
  80129a:	00 00 00 
  80129d:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80129f:	4d 01 ee             	add    %r13,%r14
  8012a2:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8012a7:	eb c9                	jmp    801272 <strlcat+0x6c>

00000000008012a9 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8012a9:	48 85 d2             	test   %rdx,%rdx
  8012ac:	74 3a                	je     8012e8 <memcmp+0x3f>
    if (*s1 != *s2)
  8012ae:	0f b6 0f             	movzbl (%rdi),%ecx
  8012b1:	44 0f b6 06          	movzbl (%rsi),%r8d
  8012b5:	44 38 c1             	cmp    %r8b,%cl
  8012b8:	75 1d                	jne    8012d7 <memcmp+0x2e>
  8012ba:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012bf:	48 39 d0             	cmp    %rdx,%rax
  8012c2:	74 1e                	je     8012e2 <memcmp+0x39>
    if (*s1 != *s2)
  8012c4:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012c8:	48 83 c0 01          	add    $0x1,%rax
  8012cc:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012d2:	44 38 c1             	cmp    %r8b,%cl
  8012d5:	74 e8                	je     8012bf <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012d7:	0f b6 c1             	movzbl %cl,%eax
  8012da:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012de:	44 29 c0             	sub    %r8d,%eax
  8012e1:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e7:	c3                   	retq   
  8012e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ed:	c3                   	retq   

00000000008012ee <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012ee:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012f2:	48 39 c7             	cmp    %rax,%rdi
  8012f5:	73 19                	jae    801310 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012f7:	89 f2                	mov    %esi,%edx
  8012f9:	40 38 37             	cmp    %sil,(%rdi)
  8012fc:	74 16                	je     801314 <memfind+0x26>
  for (; s < ends; s++)
  8012fe:	48 83 c7 01          	add    $0x1,%rdi
  801302:	48 39 f8             	cmp    %rdi,%rax
  801305:	74 08                	je     80130f <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801307:	38 17                	cmp    %dl,(%rdi)
  801309:	75 f3                	jne    8012fe <memfind+0x10>
  for (; s < ends; s++)
  80130b:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80130e:	c3                   	retq   
  80130f:	c3                   	retq   
  for (; s < ends; s++)
  801310:	48 89 f8             	mov    %rdi,%rax
  801313:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801314:	48 89 f8             	mov    %rdi,%rax
  801317:	c3                   	retq   

0000000000801318 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801318:	0f b6 07             	movzbl (%rdi),%eax
  80131b:	3c 20                	cmp    $0x20,%al
  80131d:	74 04                	je     801323 <strtol+0xb>
  80131f:	3c 09                	cmp    $0x9,%al
  801321:	75 0f                	jne    801332 <strtol+0x1a>
    s++;
  801323:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801327:	0f b6 07             	movzbl (%rdi),%eax
  80132a:	3c 20                	cmp    $0x20,%al
  80132c:	74 f5                	je     801323 <strtol+0xb>
  80132e:	3c 09                	cmp    $0x9,%al
  801330:	74 f1                	je     801323 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801332:	3c 2b                	cmp    $0x2b,%al
  801334:	74 2b                	je     801361 <strtol+0x49>
  int neg  = 0;
  801336:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80133c:	3c 2d                	cmp    $0x2d,%al
  80133e:	74 2d                	je     80136d <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801340:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801346:	75 0f                	jne    801357 <strtol+0x3f>
  801348:	80 3f 30             	cmpb   $0x30,(%rdi)
  80134b:	74 2c                	je     801379 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80134d:	85 d2                	test   %edx,%edx
  80134f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801354:	0f 44 d0             	cmove  %eax,%edx
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  80135c:	4c 63 d2             	movslq %edx,%r10
  80135f:	eb 5c                	jmp    8013bd <strtol+0xa5>
    s++;
  801361:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801365:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80136b:	eb d3                	jmp    801340 <strtol+0x28>
    s++, neg = 1;
  80136d:	48 83 c7 01          	add    $0x1,%rdi
  801371:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801377:	eb c7                	jmp    801340 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801379:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80137d:	74 0f                	je     80138e <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80137f:	85 d2                	test   %edx,%edx
  801381:	75 d4                	jne    801357 <strtol+0x3f>
    s++, base = 8;
  801383:	48 83 c7 01          	add    $0x1,%rdi
  801387:	ba 08 00 00 00       	mov    $0x8,%edx
  80138c:	eb c9                	jmp    801357 <strtol+0x3f>
    s += 2, base = 16;
  80138e:	48 83 c7 02          	add    $0x2,%rdi
  801392:	ba 10 00 00 00       	mov    $0x10,%edx
  801397:	eb be                	jmp    801357 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801399:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80139d:	41 80 f8 19          	cmp    $0x19,%r8b
  8013a1:	77 2f                	ja     8013d2 <strtol+0xba>
      dig = *s - 'a' + 10;
  8013a3:	44 0f be c1          	movsbl %cl,%r8d
  8013a7:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8013ab:	39 d1                	cmp    %edx,%ecx
  8013ad:	7d 37                	jge    8013e6 <strtol+0xce>
    s++, val = (val * base) + dig;
  8013af:	48 83 c7 01          	add    $0x1,%rdi
  8013b3:	49 0f af c2          	imul   %r10,%rax
  8013b7:	48 63 c9             	movslq %ecx,%rcx
  8013ba:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013bd:	0f b6 0f             	movzbl (%rdi),%ecx
  8013c0:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013c4:	41 80 f8 09          	cmp    $0x9,%r8b
  8013c8:	77 cf                	ja     801399 <strtol+0x81>
      dig = *s - '0';
  8013ca:	0f be c9             	movsbl %cl,%ecx
  8013cd:	83 e9 30             	sub    $0x30,%ecx
  8013d0:	eb d9                	jmp    8013ab <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013d2:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013d6:	41 80 f8 19          	cmp    $0x19,%r8b
  8013da:	77 0a                	ja     8013e6 <strtol+0xce>
      dig = *s - 'A' + 10;
  8013dc:	44 0f be c1          	movsbl %cl,%r8d
  8013e0:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013e4:	eb c5                	jmp    8013ab <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013e6:	48 85 f6             	test   %rsi,%rsi
  8013e9:	74 03                	je     8013ee <strtol+0xd6>
    *endptr = (char *)s;
  8013eb:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013ee:	48 89 c2             	mov    %rax,%rdx
  8013f1:	48 f7 da             	neg    %rdx
  8013f4:	45 85 c9             	test   %r9d,%r9d
  8013f7:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013fb:	c3                   	retq   
