
obj/user/evilhello:     file format elf64-x86-64


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
  800023:	e8 23 00 00 00       	callq  80004b <libmain>
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
  // try to print the kernel entry point as a string!  mua ha ha!
  sys_cputs((char *)0x804020000c, 100);
  80002e:	be 64 00 00 00       	mov    $0x64,%esi
  800033:	48 bf 0c 00 20 40 80 	movabs $0x804020000c,%rdi
  80003a:	00 00 00 
  80003d:	48 b8 18 01 80 00 00 	movabs $0x800118,%rax
  800044:	00 00 00 
  800047:	ff d0                	callq  *%rax
}
  800049:	5d                   	pop    %rbp
  80004a:	c3                   	retq   

000000000080004b <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80004b:	55                   	push   %rbp
  80004c:	48 89 e5             	mov    %rsp,%rbp
  80004f:	41 56                	push   %r14
  800051:	41 55                	push   %r13
  800053:	41 54                	push   %r12
  800055:	53                   	push   %rbx
  800056:	41 89 fd             	mov    %edi,%r13d
  800059:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80005c:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800063:	00 00 00 
  800066:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80006d:	00 00 00 
  800070:	48 39 c2             	cmp    %rax,%rdx
  800073:	73 23                	jae    800098 <libmain+0x4d>
  800075:	48 89 d3             	mov    %rdx,%rbx
  800078:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80007c:	48 29 d0             	sub    %rdx,%rax
  80007f:	48 c1 e8 03          	shr    $0x3,%rax
  800083:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800088:	b8 00 00 00 00       	mov    $0x0,%eax
  80008d:	ff 13                	callq  *(%rbx)
    ctor++;
  80008f:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800093:	4c 39 e3             	cmp    %r12,%rbx
  800096:	75 f0                	jne    800088 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800098:	48 b8 b6 01 80 00 00 	movabs $0x8001b6,%rax
  80009f:	00 00 00 
  8000a2:	ff d0                	callq  *%rax
  8000a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a9:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000ad:	48 c1 e0 05          	shl    $0x5,%rax
  8000b1:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000b8:	00 00 00 
  8000bb:	48 01 d0             	add    %rdx,%rax
  8000be:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000c5:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000c8:	45 85 ed             	test   %r13d,%r13d
  8000cb:	7e 0d                	jle    8000da <libmain+0x8f>
    binaryname = argv[0];
  8000cd:	49 8b 06             	mov    (%r14),%rax
  8000d0:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000d7:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000da:	4c 89 f6             	mov    %r14,%rsi
  8000dd:	44 89 ef             	mov    %r13d,%edi
  8000e0:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000e7:	00 00 00 
  8000ea:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000ec:	48 b8 01 01 80 00 00 	movabs $0x800101,%rax
  8000f3:	00 00 00 
  8000f6:	ff d0                	callq  *%rax
#endif
}
  8000f8:	5b                   	pop    %rbx
  8000f9:	41 5c                	pop    %r12
  8000fb:	41 5d                	pop    %r13
  8000fd:	41 5e                	pop    %r14
  8000ff:	5d                   	pop    %rbp
  800100:	c3                   	retq   

0000000000800101 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800101:	55                   	push   %rbp
  800102:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800105:	bf 00 00 00 00       	mov    $0x0,%edi
  80010a:	48 b8 56 01 80 00 00 	movabs $0x800156,%rax
  800111:	00 00 00 
  800114:	ff d0                	callq  *%rax
}
  800116:	5d                   	pop    %rbp
  800117:	c3                   	retq   

0000000000800118 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800118:	55                   	push   %rbp
  800119:	48 89 e5             	mov    %rsp,%rbp
  80011c:	53                   	push   %rbx
  80011d:	48 89 fa             	mov    %rdi,%rdx
  800120:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800123:	b8 00 00 00 00       	mov    $0x0,%eax
  800128:	48 89 c3             	mov    %rax,%rbx
  80012b:	48 89 c7             	mov    %rax,%rdi
  80012e:	48 89 c6             	mov    %rax,%rsi
  800131:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800133:	5b                   	pop    %rbx
  800134:	5d                   	pop    %rbp
  800135:	c3                   	retq   

0000000000800136 <sys_cgetc>:

int
sys_cgetc(void) {
  800136:	55                   	push   %rbp
  800137:	48 89 e5             	mov    %rsp,%rbp
  80013a:	53                   	push   %rbx
  asm volatile("int %1\n"
  80013b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800140:	b8 01 00 00 00       	mov    $0x1,%eax
  800145:	48 89 ca             	mov    %rcx,%rdx
  800148:	48 89 cb             	mov    %rcx,%rbx
  80014b:	48 89 cf             	mov    %rcx,%rdi
  80014e:	48 89 ce             	mov    %rcx,%rsi
  800151:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800153:	5b                   	pop    %rbx
  800154:	5d                   	pop    %rbp
  800155:	c3                   	retq   

0000000000800156 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800156:	55                   	push   %rbp
  800157:	48 89 e5             	mov    %rsp,%rbp
  80015a:	53                   	push   %rbx
  80015b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015f:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800162:	be 00 00 00 00       	mov    $0x0,%esi
  800167:	b8 03 00 00 00       	mov    $0x3,%eax
  80016c:	48 89 f1             	mov    %rsi,%rcx
  80016f:	48 89 f3             	mov    %rsi,%rbx
  800172:	48 89 f7             	mov    %rsi,%rdi
  800175:	cd 30                	int    $0x30
  if (check && ret > 0)
  800177:	48 85 c0             	test   %rax,%rax
  80017a:	7f 07                	jg     800183 <sys_env_destroy+0x2d>
}
  80017c:	48 83 c4 08          	add    $0x8,%rsp
  800180:	5b                   	pop    %rbx
  800181:	5d                   	pop    %rbp
  800182:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800183:	49 89 c0             	mov    %rax,%r8
  800186:	b9 03 00 00 00       	mov    $0x3,%ecx
  80018b:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800192:	00 00 00 
  800195:	be 22 00 00 00       	mov    $0x22,%esi
  80019a:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8001a1:	00 00 00 
  8001a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a9:	49 b9 63 04 80 00 00 	movabs $0x800463,%r9
  8001b0:	00 00 00 
  8001b3:	41 ff d1             	callq  *%r9

00000000008001b6 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001b6:	55                   	push   %rbp
  8001b7:	48 89 e5             	mov    %rsp,%rbp
  8001ba:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8001c5:	48 89 ca             	mov    %rcx,%rdx
  8001c8:	48 89 cb             	mov    %rcx,%rbx
  8001cb:	48 89 cf             	mov    %rcx,%rdi
  8001ce:	48 89 ce             	mov    %rcx,%rsi
  8001d1:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001d3:	5b                   	pop    %rbx
  8001d4:	5d                   	pop    %rbp
  8001d5:	c3                   	retq   

00000000008001d6 <sys_yield>:

void
sys_yield(void) {
  8001d6:	55                   	push   %rbp
  8001d7:	48 89 e5             	mov    %rsp,%rbp
  8001da:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001e5:	48 89 ca             	mov    %rcx,%rdx
  8001e8:	48 89 cb             	mov    %rcx,%rbx
  8001eb:	48 89 cf             	mov    %rcx,%rdi
  8001ee:	48 89 ce             	mov    %rcx,%rsi
  8001f1:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001f3:	5b                   	pop    %rbx
  8001f4:	5d                   	pop    %rbp
  8001f5:	c3                   	retq   

00000000008001f6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001f6:	55                   	push   %rbp
  8001f7:	48 89 e5             	mov    %rsp,%rbp
  8001fa:	53                   	push   %rbx
  8001fb:	48 83 ec 08          	sub    $0x8,%rsp
  8001ff:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  800202:	4c 63 c7             	movslq %edi,%r8
  800205:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  800208:	be 00 00 00 00       	mov    $0x0,%esi
  80020d:	b8 04 00 00 00       	mov    $0x4,%eax
  800212:	4c 89 c2             	mov    %r8,%rdx
  800215:	48 89 f7             	mov    %rsi,%rdi
  800218:	cd 30                	int    $0x30
  if (check && ret > 0)
  80021a:	48 85 c0             	test   %rax,%rax
  80021d:	7f 07                	jg     800226 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80021f:	48 83 c4 08          	add    $0x8,%rsp
  800223:	5b                   	pop    %rbx
  800224:	5d                   	pop    %rbp
  800225:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800226:	49 89 c0             	mov    %rax,%r8
  800229:	b9 04 00 00 00       	mov    $0x4,%ecx
  80022e:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800235:	00 00 00 
  800238:	be 22 00 00 00       	mov    $0x22,%esi
  80023d:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800244:	00 00 00 
  800247:	b8 00 00 00 00       	mov    $0x0,%eax
  80024c:	49 b9 63 04 80 00 00 	movabs $0x800463,%r9
  800253:	00 00 00 
  800256:	41 ff d1             	callq  *%r9

0000000000800259 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  800259:	55                   	push   %rbp
  80025a:	48 89 e5             	mov    %rsp,%rbp
  80025d:	53                   	push   %rbx
  80025e:	48 83 ec 08          	sub    $0x8,%rsp
  800262:	41 89 f9             	mov    %edi,%r9d
  800265:	49 89 f2             	mov    %rsi,%r10
  800268:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80026b:	4d 63 c9             	movslq %r9d,%r9
  80026e:	48 63 da             	movslq %edx,%rbx
  800271:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  800274:	b8 05 00 00 00       	mov    $0x5,%eax
  800279:	4c 89 ca             	mov    %r9,%rdx
  80027c:	4c 89 d1             	mov    %r10,%rcx
  80027f:	cd 30                	int    $0x30
  if (check && ret > 0)
  800281:	48 85 c0             	test   %rax,%rax
  800284:	7f 07                	jg     80028d <sys_page_map+0x34>
}
  800286:	48 83 c4 08          	add    $0x8,%rsp
  80028a:	5b                   	pop    %rbx
  80028b:	5d                   	pop    %rbp
  80028c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80028d:	49 89 c0             	mov    %rax,%r8
  800290:	b9 05 00 00 00       	mov    $0x5,%ecx
  800295:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80029c:	00 00 00 
  80029f:	be 22 00 00 00       	mov    $0x22,%esi
  8002a4:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8002ab:	00 00 00 
  8002ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b3:	49 b9 63 04 80 00 00 	movabs $0x800463,%r9
  8002ba:	00 00 00 
  8002bd:	41 ff d1             	callq  *%r9

00000000008002c0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002c0:	55                   	push   %rbp
  8002c1:	48 89 e5             	mov    %rsp,%rbp
  8002c4:	53                   	push   %rbx
  8002c5:	48 83 ec 08          	sub    $0x8,%rsp
  8002c9:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002cc:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002cf:	be 00 00 00 00       	mov    $0x0,%esi
  8002d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8002d9:	48 89 f3             	mov    %rsi,%rbx
  8002dc:	48 89 f7             	mov    %rsi,%rdi
  8002df:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002e1:	48 85 c0             	test   %rax,%rax
  8002e4:	7f 07                	jg     8002ed <sys_page_unmap+0x2d>
}
  8002e6:	48 83 c4 08          	add    $0x8,%rsp
  8002ea:	5b                   	pop    %rbx
  8002eb:	5d                   	pop    %rbp
  8002ec:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002ed:	49 89 c0             	mov    %rax,%r8
  8002f0:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002f5:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8002fc:	00 00 00 
  8002ff:	be 22 00 00 00       	mov    $0x22,%esi
  800304:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80030b:	00 00 00 
  80030e:	b8 00 00 00 00       	mov    $0x0,%eax
  800313:	49 b9 63 04 80 00 00 	movabs $0x800463,%r9
  80031a:	00 00 00 
  80031d:	41 ff d1             	callq  *%r9

0000000000800320 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  800320:	55                   	push   %rbp
  800321:	48 89 e5             	mov    %rsp,%rbp
  800324:	53                   	push   %rbx
  800325:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800329:	48 63 d7             	movslq %edi,%rdx
  80032c:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80032f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800334:	b8 08 00 00 00       	mov    $0x8,%eax
  800339:	48 89 df             	mov    %rbx,%rdi
  80033c:	48 89 de             	mov    %rbx,%rsi
  80033f:	cd 30                	int    $0x30
  if (check && ret > 0)
  800341:	48 85 c0             	test   %rax,%rax
  800344:	7f 07                	jg     80034d <sys_env_set_status+0x2d>
}
  800346:	48 83 c4 08          	add    $0x8,%rsp
  80034a:	5b                   	pop    %rbx
  80034b:	5d                   	pop    %rbp
  80034c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80034d:	49 89 c0             	mov    %rax,%r8
  800350:	b9 08 00 00 00       	mov    $0x8,%ecx
  800355:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80035c:	00 00 00 
  80035f:	be 22 00 00 00       	mov    $0x22,%esi
  800364:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80036b:	00 00 00 
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	49 b9 63 04 80 00 00 	movabs $0x800463,%r9
  80037a:	00 00 00 
  80037d:	41 ff d1             	callq  *%r9

0000000000800380 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  800380:	55                   	push   %rbp
  800381:	48 89 e5             	mov    %rsp,%rbp
  800384:	53                   	push   %rbx
  800385:	48 83 ec 08          	sub    $0x8,%rsp
  800389:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80038c:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80038f:	be 00 00 00 00       	mov    $0x0,%esi
  800394:	b8 09 00 00 00       	mov    $0x9,%eax
  800399:	48 89 f3             	mov    %rsi,%rbx
  80039c:	48 89 f7             	mov    %rsi,%rdi
  80039f:	cd 30                	int    $0x30
  if (check && ret > 0)
  8003a1:	48 85 c0             	test   %rax,%rax
  8003a4:	7f 07                	jg     8003ad <sys_env_set_pgfault_upcall+0x2d>
}
  8003a6:	48 83 c4 08          	add    $0x8,%rsp
  8003aa:	5b                   	pop    %rbx
  8003ab:	5d                   	pop    %rbp
  8003ac:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8003ad:	49 89 c0             	mov    %rax,%r8
  8003b0:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003b5:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8003bc:	00 00 00 
  8003bf:	be 22 00 00 00       	mov    $0x22,%esi
  8003c4:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8003cb:	00 00 00 
  8003ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d3:	49 b9 63 04 80 00 00 	movabs $0x800463,%r9
  8003da:	00 00 00 
  8003dd:	41 ff d1             	callq  *%r9

00000000008003e0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003e0:	55                   	push   %rbp
  8003e1:	48 89 e5             	mov    %rsp,%rbp
  8003e4:	53                   	push   %rbx
  8003e5:	49 89 f0             	mov    %rsi,%r8
  8003e8:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003eb:	48 63 d7             	movslq %edi,%rdx
  8003ee:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003f1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003f6:	be 00 00 00 00       	mov    $0x0,%esi
  8003fb:	4c 89 c1             	mov    %r8,%rcx
  8003fe:	cd 30                	int    $0x30
}
  800400:	5b                   	pop    %rbx
  800401:	5d                   	pop    %rbp
  800402:	c3                   	retq   

0000000000800403 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  800403:	55                   	push   %rbp
  800404:	48 89 e5             	mov    %rsp,%rbp
  800407:	53                   	push   %rbx
  800408:	48 83 ec 08          	sub    $0x8,%rsp
  80040c:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  80040f:	be 00 00 00 00       	mov    $0x0,%esi
  800414:	b8 0c 00 00 00       	mov    $0xc,%eax
  800419:	48 89 f1             	mov    %rsi,%rcx
  80041c:	48 89 f3             	mov    %rsi,%rbx
  80041f:	48 89 f7             	mov    %rsi,%rdi
  800422:	cd 30                	int    $0x30
  if (check && ret > 0)
  800424:	48 85 c0             	test   %rax,%rax
  800427:	7f 07                	jg     800430 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  800429:	48 83 c4 08          	add    $0x8,%rsp
  80042d:	5b                   	pop    %rbx
  80042e:	5d                   	pop    %rbp
  80042f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800430:	49 89 c0             	mov    %rax,%r8
  800433:	b9 0c 00 00 00       	mov    $0xc,%ecx
  800438:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80043f:	00 00 00 
  800442:	be 22 00 00 00       	mov    $0x22,%esi
  800447:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80044e:	00 00 00 
  800451:	b8 00 00 00 00       	mov    $0x0,%eax
  800456:	49 b9 63 04 80 00 00 	movabs $0x800463,%r9
  80045d:	00 00 00 
  800460:	41 ff d1             	callq  *%r9

0000000000800463 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800463:	55                   	push   %rbp
  800464:	48 89 e5             	mov    %rsp,%rbp
  800467:	41 56                	push   %r14
  800469:	41 55                	push   %r13
  80046b:	41 54                	push   %r12
  80046d:	53                   	push   %rbx
  80046e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800475:	49 89 fd             	mov    %rdi,%r13
  800478:	41 89 f6             	mov    %esi,%r14d
  80047b:	49 89 d4             	mov    %rdx,%r12
  80047e:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800485:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80048c:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800493:	84 c0                	test   %al,%al
  800495:	74 26                	je     8004bd <_panic+0x5a>
  800497:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80049e:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8004a5:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8004a9:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8004ad:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8004b1:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8004b5:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8004b9:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004bd:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004c4:	00 00 00 
  8004c7:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004ce:	00 00 00 
  8004d1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004d5:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004dc:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004e3:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ea:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004f1:	00 00 00 
  8004f4:	48 8b 18             	mov    (%rax),%rbx
  8004f7:	48 b8 b6 01 80 00 00 	movabs $0x8001b6,%rax
  8004fe:	00 00 00 
  800501:	ff d0                	callq  *%rax
  800503:	45 89 f0             	mov    %r14d,%r8d
  800506:	4c 89 e9             	mov    %r13,%rcx
  800509:	48 89 da             	mov    %rbx,%rdx
  80050c:	89 c6                	mov    %eax,%esi
  80050e:	48 bf 40 14 80 00 00 	movabs $0x801440,%rdi
  800515:	00 00 00 
  800518:	b8 00 00 00 00       	mov    $0x0,%eax
  80051d:	48 bb 05 06 80 00 00 	movabs $0x800605,%rbx
  800524:	00 00 00 
  800527:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800529:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800530:	4c 89 e7             	mov    %r12,%rdi
  800533:	48 b8 9d 05 80 00 00 	movabs $0x80059d,%rax
  80053a:	00 00 00 
  80053d:	ff d0                	callq  *%rax
  cprintf("\n");
  80053f:	48 bf 68 14 80 00 00 	movabs $0x801468,%rdi
  800546:	00 00 00 
  800549:	b8 00 00 00 00       	mov    $0x0,%eax
  80054e:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800550:	cc                   	int3   
  while (1)
  800551:	eb fd                	jmp    800550 <_panic+0xed>

0000000000800553 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800553:	55                   	push   %rbp
  800554:	48 89 e5             	mov    %rsp,%rbp
  800557:	53                   	push   %rbx
  800558:	48 83 ec 08          	sub    $0x8,%rsp
  80055c:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80055f:	8b 06                	mov    (%rsi),%eax
  800561:	8d 50 01             	lea    0x1(%rax),%edx
  800564:	89 16                	mov    %edx,(%rsi)
  800566:	48 98                	cltq   
  800568:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80056d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800573:	74 0b                	je     800580 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800575:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800579:	48 83 c4 08          	add    $0x8,%rsp
  80057d:	5b                   	pop    %rbx
  80057e:	5d                   	pop    %rbp
  80057f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800580:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800584:	be ff 00 00 00       	mov    $0xff,%esi
  800589:	48 b8 18 01 80 00 00 	movabs $0x800118,%rax
  800590:	00 00 00 
  800593:	ff d0                	callq  *%rax
    b->idx = 0;
  800595:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80059b:	eb d8                	jmp    800575 <putch+0x22>

000000000080059d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80059d:	55                   	push   %rbp
  80059e:	48 89 e5             	mov    %rsp,%rbp
  8005a1:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8005a8:	48 89 fa             	mov    %rdi,%rdx
  8005ab:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8005ae:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8005b5:	00 00 00 
  b.cnt = 0;
  8005b8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005bf:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005c2:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005c9:	48 bf 53 05 80 00 00 	movabs $0x800553,%rdi
  8005d0:	00 00 00 
  8005d3:	48 b8 c3 07 80 00 00 	movabs $0x8007c3,%rax
  8005da:	00 00 00 
  8005dd:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005df:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005e6:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005ed:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005f1:	48 b8 18 01 80 00 00 	movabs $0x800118,%rax
  8005f8:	00 00 00 
  8005fb:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800603:	c9                   	leaveq 
  800604:	c3                   	retq   

0000000000800605 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800605:	55                   	push   %rbp
  800606:	48 89 e5             	mov    %rsp,%rbp
  800609:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800610:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800617:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80061e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800625:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80062c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800633:	84 c0                	test   %al,%al
  800635:	74 20                	je     800657 <cprintf+0x52>
  800637:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80063b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80063f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800643:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800647:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80064b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80064f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800653:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800657:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80065e:	00 00 00 
  800661:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800668:	00 00 00 
  80066b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80066f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800676:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80067d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800684:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80068b:	48 b8 9d 05 80 00 00 	movabs $0x80059d,%rax
  800692:	00 00 00 
  800695:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800697:	c9                   	leaveq 
  800698:	c3                   	retq   

0000000000800699 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800699:	55                   	push   %rbp
  80069a:	48 89 e5             	mov    %rsp,%rbp
  80069d:	41 57                	push   %r15
  80069f:	41 56                	push   %r14
  8006a1:	41 55                	push   %r13
  8006a3:	41 54                	push   %r12
  8006a5:	53                   	push   %rbx
  8006a6:	48 83 ec 18          	sub    $0x18,%rsp
  8006aa:	49 89 fc             	mov    %rdi,%r12
  8006ad:	49 89 f5             	mov    %rsi,%r13
  8006b0:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8006b4:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8006b7:	41 89 cf             	mov    %ecx,%r15d
  8006ba:	49 39 d7             	cmp    %rdx,%r15
  8006bd:	76 45                	jbe    800704 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006bf:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006c3:	85 db                	test   %ebx,%ebx
  8006c5:	7e 0e                	jle    8006d5 <printnum+0x3c>
      putch(padc, putdat);
  8006c7:	4c 89 ee             	mov    %r13,%rsi
  8006ca:	44 89 f7             	mov    %r14d,%edi
  8006cd:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006d0:	83 eb 01             	sub    $0x1,%ebx
  8006d3:	75 f2                	jne    8006c7 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006d5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006de:	49 f7 f7             	div    %r15
  8006e1:	48 b8 6a 14 80 00 00 	movabs $0x80146a,%rax
  8006e8:	00 00 00 
  8006eb:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006ef:	4c 89 ee             	mov    %r13,%rsi
  8006f2:	41 ff d4             	callq  *%r12
}
  8006f5:	48 83 c4 18          	add    $0x18,%rsp
  8006f9:	5b                   	pop    %rbx
  8006fa:	41 5c                	pop    %r12
  8006fc:	41 5d                	pop    %r13
  8006fe:	41 5e                	pop    %r14
  800700:	41 5f                	pop    %r15
  800702:	5d                   	pop    %rbp
  800703:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  800704:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800708:	ba 00 00 00 00       	mov    $0x0,%edx
  80070d:	49 f7 f7             	div    %r15
  800710:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800714:	48 89 c2             	mov    %rax,%rdx
  800717:	48 b8 99 06 80 00 00 	movabs $0x800699,%rax
  80071e:	00 00 00 
  800721:	ff d0                	callq  *%rax
  800723:	eb b0                	jmp    8006d5 <printnum+0x3c>

0000000000800725 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800725:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800729:	48 8b 06             	mov    (%rsi),%rax
  80072c:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800730:	73 0a                	jae    80073c <sprintputch+0x17>
    *b->buf++ = ch;
  800732:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800736:	48 89 16             	mov    %rdx,(%rsi)
  800739:	40 88 38             	mov    %dil,(%rax)
}
  80073c:	c3                   	retq   

000000000080073d <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80073d:	55                   	push   %rbp
  80073e:	48 89 e5             	mov    %rsp,%rbp
  800741:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800748:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80074f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800756:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80075d:	84 c0                	test   %al,%al
  80075f:	74 20                	je     800781 <printfmt+0x44>
  800761:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800765:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800769:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80076d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800771:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800775:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800779:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80077d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800781:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800788:	00 00 00 
  80078b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800792:	00 00 00 
  800795:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800799:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8007a0:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8007a7:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8007ae:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8007b5:	48 b8 c3 07 80 00 00 	movabs $0x8007c3,%rax
  8007bc:	00 00 00 
  8007bf:	ff d0                	callq  *%rax
}
  8007c1:	c9                   	leaveq 
  8007c2:	c3                   	retq   

00000000008007c3 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007c3:	55                   	push   %rbp
  8007c4:	48 89 e5             	mov    %rsp,%rbp
  8007c7:	41 57                	push   %r15
  8007c9:	41 56                	push   %r14
  8007cb:	41 55                	push   %r13
  8007cd:	41 54                	push   %r12
  8007cf:	53                   	push   %rbx
  8007d0:	48 83 ec 48          	sub    $0x48,%rsp
  8007d4:	49 89 fd             	mov    %rdi,%r13
  8007d7:	49 89 f7             	mov    %rsi,%r15
  8007da:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007dd:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007e1:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007e5:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007e9:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007ed:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007f1:	41 0f b6 3e          	movzbl (%r14),%edi
  8007f5:	83 ff 25             	cmp    $0x25,%edi
  8007f8:	74 18                	je     800812 <vprintfmt+0x4f>
      if (ch == '\0')
  8007fa:	85 ff                	test   %edi,%edi
  8007fc:	0f 84 8c 06 00 00    	je     800e8e <vprintfmt+0x6cb>
      putch(ch, putdat);
  800802:	4c 89 fe             	mov    %r15,%rsi
  800805:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800808:	49 89 de             	mov    %rbx,%r14
  80080b:	eb e0                	jmp    8007ed <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80080d:	49 89 de             	mov    %rbx,%r14
  800810:	eb db                	jmp    8007ed <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800812:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800816:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80081a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800821:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800827:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80082b:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800830:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800836:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80083c:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800841:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800846:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80084a:	0f b6 13             	movzbl (%rbx),%edx
  80084d:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800850:	3c 55                	cmp    $0x55,%al
  800852:	0f 87 8b 05 00 00    	ja     800de3 <vprintfmt+0x620>
  800858:	0f b6 c0             	movzbl %al,%eax
  80085b:	49 bb 40 15 80 00 00 	movabs $0x801540,%r11
  800862:	00 00 00 
  800865:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800869:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80086c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800870:	eb d4                	jmp    800846 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800872:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800875:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800879:	eb cb                	jmp    800846 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80087b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80087e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800882:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800886:	8d 50 d0             	lea    -0x30(%rax),%edx
  800889:	83 fa 09             	cmp    $0x9,%edx
  80088c:	77 7e                	ja     80090c <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80088e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800892:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800896:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80089b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80089f:	8d 50 d0             	lea    -0x30(%rax),%edx
  8008a2:	83 fa 09             	cmp    $0x9,%edx
  8008a5:	76 e7                	jbe    80088e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8008a7:	4c 89 f3             	mov    %r14,%rbx
  8008aa:	eb 19                	jmp    8008c5 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8008ac:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008af:	83 f8 2f             	cmp    $0x2f,%eax
  8008b2:	77 2a                	ja     8008de <vprintfmt+0x11b>
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	4c 01 d2             	add    %r10,%rdx
  8008b9:	83 c0 08             	add    $0x8,%eax
  8008bc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008bf:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008c2:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008c5:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008c9:	0f 89 77 ff ff ff    	jns    800846 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008cf:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008d3:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008d9:	e9 68 ff ff ff       	jmpq   800846 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008de:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008e2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ea:	eb d3                	jmp    8008bf <vprintfmt+0xfc>
        if (width < 0)
  8008ec:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008f5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008f8:	4c 89 f3             	mov    %r14,%rbx
  8008fb:	e9 46 ff ff ff       	jmpq   800846 <vprintfmt+0x83>
  800900:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  800903:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800907:	e9 3a ff ff ff       	jmpq   800846 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80090c:	4c 89 f3             	mov    %r14,%rbx
  80090f:	eb b4                	jmp    8008c5 <vprintfmt+0x102>
        lflag++;
  800911:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800914:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800917:	e9 2a ff ff ff       	jmpq   800846 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80091c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091f:	83 f8 2f             	cmp    $0x2f,%eax
  800922:	77 19                	ja     80093d <vprintfmt+0x17a>
  800924:	89 c2                	mov    %eax,%edx
  800926:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80092a:	83 c0 08             	add    $0x8,%eax
  80092d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800930:	4c 89 fe             	mov    %r15,%rsi
  800933:	8b 3a                	mov    (%rdx),%edi
  800935:	41 ff d5             	callq  *%r13
        break;
  800938:	e9 b0 fe ff ff       	jmpq   8007ed <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80093d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800941:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800945:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800949:	eb e5                	jmp    800930 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80094b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80094e:	83 f8 2f             	cmp    $0x2f,%eax
  800951:	77 5b                	ja     8009ae <vprintfmt+0x1eb>
  800953:	89 c2                	mov    %eax,%edx
  800955:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800959:	83 c0 08             	add    $0x8,%eax
  80095c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800961:	89 c8                	mov    %ecx,%eax
  800963:	c1 f8 1f             	sar    $0x1f,%eax
  800966:	31 c1                	xor    %eax,%ecx
  800968:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80096a:	83 f9 0b             	cmp    $0xb,%ecx
  80096d:	7f 4d                	jg     8009bc <vprintfmt+0x1f9>
  80096f:	48 63 c1             	movslq %ecx,%rax
  800972:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  800979:	00 00 00 
  80097c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800980:	48 85 c0             	test   %rax,%rax
  800983:	74 37                	je     8009bc <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800985:	48 89 c1             	mov    %rax,%rcx
  800988:	48 ba 8b 14 80 00 00 	movabs $0x80148b,%rdx
  80098f:	00 00 00 
  800992:	4c 89 fe             	mov    %r15,%rsi
  800995:	4c 89 ef             	mov    %r13,%rdi
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
  80099d:	48 bb 3d 07 80 00 00 	movabs $0x80073d,%rbx
  8009a4:	00 00 00 
  8009a7:	ff d3                	callq  *%rbx
  8009a9:	e9 3f fe ff ff       	jmpq   8007ed <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8009ae:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009b2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009ba:	eb a3                	jmp    80095f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009bc:	48 ba 82 14 80 00 00 	movabs $0x801482,%rdx
  8009c3:	00 00 00 
  8009c6:	4c 89 fe             	mov    %r15,%rsi
  8009c9:	4c 89 ef             	mov    %r13,%rdi
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	48 bb 3d 07 80 00 00 	movabs $0x80073d,%rbx
  8009d8:	00 00 00 
  8009db:	ff d3                	callq  *%rbx
  8009dd:	e9 0b fe ff ff       	jmpq   8007ed <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009e2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e5:	83 f8 2f             	cmp    $0x2f,%eax
  8009e8:	77 4b                	ja     800a35 <vprintfmt+0x272>
  8009ea:	89 c2                	mov    %eax,%edx
  8009ec:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009f0:	83 c0 08             	add    $0x8,%eax
  8009f3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f6:	48 8b 02             	mov    (%rdx),%rax
  8009f9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009fd:	48 85 c0             	test   %rax,%rax
  800a00:	0f 84 05 04 00 00    	je     800e0b <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800a06:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a0a:	7e 06                	jle    800a12 <vprintfmt+0x24f>
  800a0c:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a10:	75 31                	jne    800a43 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a12:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a16:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a1a:	0f b6 00             	movzbl (%rax),%eax
  800a1d:	0f be f8             	movsbl %al,%edi
  800a20:	85 ff                	test   %edi,%edi
  800a22:	0f 84 c3 00 00 00    	je     800aeb <vprintfmt+0x328>
  800a28:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a2c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a30:	e9 85 00 00 00       	jmpq   800aba <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a35:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a39:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a3d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a41:	eb b3                	jmp    8009f6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a43:	49 63 f4             	movslq %r12d,%rsi
  800a46:	48 89 c7             	mov    %rax,%rdi
  800a49:	48 b8 9a 0f 80 00 00 	movabs $0x800f9a,%rax
  800a50:	00 00 00 
  800a53:	ff d0                	callq  *%rax
  800a55:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a58:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a5b:	85 f6                	test   %esi,%esi
  800a5d:	7e 22                	jle    800a81 <vprintfmt+0x2be>
            putch(padc, putdat);
  800a5f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a63:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a67:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a6b:	4c 89 fe             	mov    %r15,%rsi
  800a6e:	89 df                	mov    %ebx,%edi
  800a70:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a73:	41 83 ec 01          	sub    $0x1,%r12d
  800a77:	75 f2                	jne    800a6b <vprintfmt+0x2a8>
  800a79:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a7d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a81:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a85:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a89:	0f b6 00             	movzbl (%rax),%eax
  800a8c:	0f be f8             	movsbl %al,%edi
  800a8f:	85 ff                	test   %edi,%edi
  800a91:	0f 84 56 fd ff ff    	je     8007ed <vprintfmt+0x2a>
  800a97:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a9b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a9f:	eb 19                	jmp    800aba <vprintfmt+0x2f7>
            putch(ch, putdat);
  800aa1:	4c 89 fe             	mov    %r15,%rsi
  800aa4:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa7:	41 83 ee 01          	sub    $0x1,%r14d
  800aab:	48 83 c3 01          	add    $0x1,%rbx
  800aaf:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800ab3:	0f be f8             	movsbl %al,%edi
  800ab6:	85 ff                	test   %edi,%edi
  800ab8:	74 29                	je     800ae3 <vprintfmt+0x320>
  800aba:	45 85 e4             	test   %r12d,%r12d
  800abd:	78 06                	js     800ac5 <vprintfmt+0x302>
  800abf:	41 83 ec 01          	sub    $0x1,%r12d
  800ac3:	78 48                	js     800b0d <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800ac5:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800ac9:	74 d6                	je     800aa1 <vprintfmt+0x2de>
  800acb:	0f be c0             	movsbl %al,%eax
  800ace:	83 e8 20             	sub    $0x20,%eax
  800ad1:	83 f8 5e             	cmp    $0x5e,%eax
  800ad4:	76 cb                	jbe    800aa1 <vprintfmt+0x2de>
            putch('?', putdat);
  800ad6:	4c 89 fe             	mov    %r15,%rsi
  800ad9:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ade:	41 ff d5             	callq  *%r13
  800ae1:	eb c4                	jmp    800aa7 <vprintfmt+0x2e4>
  800ae3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800ae7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800aeb:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800aee:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800af2:	0f 8e f5 fc ff ff    	jle    8007ed <vprintfmt+0x2a>
          putch(' ', putdat);
  800af8:	4c 89 fe             	mov    %r15,%rsi
  800afb:	bf 20 00 00 00       	mov    $0x20,%edi
  800b00:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800b03:	83 eb 01             	sub    $0x1,%ebx
  800b06:	75 f0                	jne    800af8 <vprintfmt+0x335>
  800b08:	e9 e0 fc ff ff       	jmpq   8007ed <vprintfmt+0x2a>
  800b0d:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b11:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b15:	eb d4                	jmp    800aeb <vprintfmt+0x328>
  if (lflag >= 2)
  800b17:	83 f9 01             	cmp    $0x1,%ecx
  800b1a:	7f 1d                	jg     800b39 <vprintfmt+0x376>
  else if (lflag)
  800b1c:	85 c9                	test   %ecx,%ecx
  800b1e:	74 5e                	je     800b7e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b20:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b23:	83 f8 2f             	cmp    $0x2f,%eax
  800b26:	77 48                	ja     800b70 <vprintfmt+0x3ad>
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b2e:	83 c0 08             	add    $0x8,%eax
  800b31:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b34:	48 8b 1a             	mov    (%rdx),%rbx
  800b37:	eb 17                	jmp    800b50 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b39:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b3c:	83 f8 2f             	cmp    $0x2f,%eax
  800b3f:	77 21                	ja     800b62 <vprintfmt+0x39f>
  800b41:	89 c2                	mov    %eax,%edx
  800b43:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b47:	83 c0 08             	add    $0x8,%eax
  800b4a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b4d:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b50:	48 85 db             	test   %rbx,%rbx
  800b53:	78 50                	js     800ba5 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b55:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b58:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b5d:	e9 b4 01 00 00       	jmpq   800d16 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b62:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b66:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b6a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b6e:	eb dd                	jmp    800b4d <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b70:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b74:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b78:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b7c:	eb b6                	jmp    800b34 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b7e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b81:	83 f8 2f             	cmp    $0x2f,%eax
  800b84:	77 11                	ja     800b97 <vprintfmt+0x3d4>
  800b86:	89 c2                	mov    %eax,%edx
  800b88:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b8c:	83 c0 08             	add    $0x8,%eax
  800b8f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b92:	48 63 1a             	movslq (%rdx),%rbx
  800b95:	eb b9                	jmp    800b50 <vprintfmt+0x38d>
  800b97:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b9b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b9f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ba3:	eb ed                	jmp    800b92 <vprintfmt+0x3cf>
          putch('-', putdat);
  800ba5:	4c 89 fe             	mov    %r15,%rsi
  800ba8:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800bad:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800bb0:	48 89 da             	mov    %rbx,%rdx
  800bb3:	48 f7 da             	neg    %rdx
        base = 10;
  800bb6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bbb:	e9 56 01 00 00       	jmpq   800d16 <vprintfmt+0x553>
  if (lflag >= 2)
  800bc0:	83 f9 01             	cmp    $0x1,%ecx
  800bc3:	7f 25                	jg     800bea <vprintfmt+0x427>
  else if (lflag)
  800bc5:	85 c9                	test   %ecx,%ecx
  800bc7:	74 5e                	je     800c27 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bc9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bcc:	83 f8 2f             	cmp    $0x2f,%eax
  800bcf:	77 48                	ja     800c19 <vprintfmt+0x456>
  800bd1:	89 c2                	mov    %eax,%edx
  800bd3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bd7:	83 c0 08             	add    $0x8,%eax
  800bda:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bdd:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800be0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800be5:	e9 2c 01 00 00       	jmpq   800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bea:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bed:	83 f8 2f             	cmp    $0x2f,%eax
  800bf0:	77 19                	ja     800c0b <vprintfmt+0x448>
  800bf2:	89 c2                	mov    %eax,%edx
  800bf4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bf8:	83 c0 08             	add    $0x8,%eax
  800bfb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bfe:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800c01:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c06:	e9 0b 01 00 00       	jmpq   800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c0b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c0f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c13:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c17:	eb e5                	jmp    800bfe <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c19:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c1d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c21:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c25:	eb b6                	jmp    800bdd <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c27:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c2a:	83 f8 2f             	cmp    $0x2f,%eax
  800c2d:	77 18                	ja     800c47 <vprintfmt+0x484>
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c35:	83 c0 08             	add    $0x8,%eax
  800c38:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c3b:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c42:	e9 cf 00 00 00       	jmpq   800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c47:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c4b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c4f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c53:	eb e6                	jmp    800c3b <vprintfmt+0x478>
  if (lflag >= 2)
  800c55:	83 f9 01             	cmp    $0x1,%ecx
  800c58:	7f 25                	jg     800c7f <vprintfmt+0x4bc>
  else if (lflag)
  800c5a:	85 c9                	test   %ecx,%ecx
  800c5c:	74 5b                	je     800cb9 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c5e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c61:	83 f8 2f             	cmp    $0x2f,%eax
  800c64:	77 45                	ja     800cab <vprintfmt+0x4e8>
  800c66:	89 c2                	mov    %eax,%edx
  800c68:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c6c:	83 c0 08             	add    $0x8,%eax
  800c6f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c72:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c75:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c7a:	e9 97 00 00 00       	jmpq   800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c7f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c82:	83 f8 2f             	cmp    $0x2f,%eax
  800c85:	77 16                	ja     800c9d <vprintfmt+0x4da>
  800c87:	89 c2                	mov    %eax,%edx
  800c89:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c8d:	83 c0 08             	add    $0x8,%eax
  800c90:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c93:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c96:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c9b:	eb 79                	jmp    800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c9d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800ca1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ca5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ca9:	eb e8                	jmp    800c93 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800cab:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800caf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cb3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cb7:	eb b9                	jmp    800c72 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800cb9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cbc:	83 f8 2f             	cmp    $0x2f,%eax
  800cbf:	77 15                	ja     800cd6 <vprintfmt+0x513>
  800cc1:	89 c2                	mov    %eax,%edx
  800cc3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cc7:	83 c0 08             	add    $0x8,%eax
  800cca:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800ccd:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800ccf:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cd4:	eb 40                	jmp    800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cd6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cda:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cde:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ce2:	eb e9                	jmp    800ccd <vprintfmt+0x50a>
        putch('0', putdat);
  800ce4:	4c 89 fe             	mov    %r15,%rsi
  800ce7:	bf 30 00 00 00       	mov    $0x30,%edi
  800cec:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cef:	4c 89 fe             	mov    %r15,%rsi
  800cf2:	bf 78 00 00 00       	mov    $0x78,%edi
  800cf7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cfa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cfd:	83 f8 2f             	cmp    $0x2f,%eax
  800d00:	77 34                	ja     800d36 <vprintfmt+0x573>
  800d02:	89 c2                	mov    %eax,%edx
  800d04:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d08:	83 c0 08             	add    $0x8,%eax
  800d0b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d0e:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d11:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d16:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d1b:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d1f:	4c 89 fe             	mov    %r15,%rsi
  800d22:	4c 89 ef             	mov    %r13,%rdi
  800d25:	48 b8 99 06 80 00 00 	movabs $0x800699,%rax
  800d2c:	00 00 00 
  800d2f:	ff d0                	callq  *%rax
        break;
  800d31:	e9 b7 fa ff ff       	jmpq   8007ed <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d36:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d3a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d3e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d42:	eb ca                	jmp    800d0e <vprintfmt+0x54b>
  if (lflag >= 2)
  800d44:	83 f9 01             	cmp    $0x1,%ecx
  800d47:	7f 22                	jg     800d6b <vprintfmt+0x5a8>
  else if (lflag)
  800d49:	85 c9                	test   %ecx,%ecx
  800d4b:	74 58                	je     800da5 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d4d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d50:	83 f8 2f             	cmp    $0x2f,%eax
  800d53:	77 42                	ja     800d97 <vprintfmt+0x5d4>
  800d55:	89 c2                	mov    %eax,%edx
  800d57:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d5b:	83 c0 08             	add    $0x8,%eax
  800d5e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d61:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d64:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d69:	eb ab                	jmp    800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d6b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d6e:	83 f8 2f             	cmp    $0x2f,%eax
  800d71:	77 16                	ja     800d89 <vprintfmt+0x5c6>
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d79:	83 c0 08             	add    $0x8,%eax
  800d7c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d7f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d82:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d87:	eb 8d                	jmp    800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d89:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d8d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d91:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d95:	eb e8                	jmp    800d7f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d97:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d9b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d9f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800da3:	eb bc                	jmp    800d61 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800da5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800da8:	83 f8 2f             	cmp    $0x2f,%eax
  800dab:	77 18                	ja     800dc5 <vprintfmt+0x602>
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800db3:	83 c0 08             	add    $0x8,%eax
  800db6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800db9:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800dbb:	b9 10 00 00 00       	mov    $0x10,%ecx
  800dc0:	e9 51 ff ff ff       	jmpq   800d16 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800dc5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800dc9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800dcd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dd1:	eb e6                	jmp    800db9 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800dd3:	4c 89 fe             	mov    %r15,%rsi
  800dd6:	bf 25 00 00 00       	mov    $0x25,%edi
  800ddb:	41 ff d5             	callq  *%r13
        break;
  800dde:	e9 0a fa ff ff       	jmpq   8007ed <vprintfmt+0x2a>
        putch('%', putdat);
  800de3:	4c 89 fe             	mov    %r15,%rsi
  800de6:	bf 25 00 00 00       	mov    $0x25,%edi
  800deb:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800dee:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800df2:	0f 84 15 fa ff ff    	je     80080d <vprintfmt+0x4a>
  800df8:	49 89 de             	mov    %rbx,%r14
  800dfb:	49 83 ee 01          	sub    $0x1,%r14
  800dff:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800e04:	75 f5                	jne    800dfb <vprintfmt+0x638>
  800e06:	e9 e2 f9 ff ff       	jmpq   8007ed <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800e0b:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800e0f:	74 06                	je     800e17 <vprintfmt+0x654>
  800e11:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e15:	7f 21                	jg     800e38 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e17:	bf 28 00 00 00       	mov    $0x28,%edi
  800e1c:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e23:	00 00 00 
  800e26:	b8 28 00 00 00       	mov    $0x28,%eax
  800e2b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e2f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e33:	e9 82 fc ff ff       	jmpq   800aba <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e38:	49 63 f4             	movslq %r12d,%rsi
  800e3b:	48 bf 7b 14 80 00 00 	movabs $0x80147b,%rdi
  800e42:	00 00 00 
  800e45:	48 b8 9a 0f 80 00 00 	movabs $0x800f9a,%rax
  800e4c:	00 00 00 
  800e4f:	ff d0                	callq  *%rax
  800e51:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e54:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e57:	48 be 7b 14 80 00 00 	movabs $0x80147b,%rsi
  800e5e:	00 00 00 
  800e61:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	0f 8f f2 fb ff ff    	jg     800a5f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e6d:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e74:	00 00 00 
  800e77:	b8 28 00 00 00       	mov    $0x28,%eax
  800e7c:	bf 28 00 00 00       	mov    $0x28,%edi
  800e81:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e85:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e89:	e9 2c fc ff ff       	jmpq   800aba <vprintfmt+0x2f7>
}
  800e8e:	48 83 c4 48          	add    $0x48,%rsp
  800e92:	5b                   	pop    %rbx
  800e93:	41 5c                	pop    %r12
  800e95:	41 5d                	pop    %r13
  800e97:	41 5e                	pop    %r14
  800e99:	41 5f                	pop    %r15
  800e9b:	5d                   	pop    %rbp
  800e9c:	c3                   	retq   

0000000000800e9d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e9d:	55                   	push   %rbp
  800e9e:	48 89 e5             	mov    %rsp,%rbp
  800ea1:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800ea5:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800ea9:	48 63 c6             	movslq %esi,%rax
  800eac:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800eb1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800eb5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800ebc:	48 85 ff             	test   %rdi,%rdi
  800ebf:	74 2a                	je     800eeb <vsnprintf+0x4e>
  800ec1:	85 f6                	test   %esi,%esi
  800ec3:	7e 26                	jle    800eeb <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ec5:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800ec9:	48 bf 25 07 80 00 00 	movabs $0x800725,%rdi
  800ed0:	00 00 00 
  800ed3:	48 b8 c3 07 80 00 00 	movabs $0x8007c3,%rax
  800eda:	00 00 00 
  800edd:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800edf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ee3:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ee6:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ee9:	c9                   	leaveq 
  800eea:	c3                   	retq   
    return -E_INVAL;
  800eeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef0:	eb f7                	jmp    800ee9 <vsnprintf+0x4c>

0000000000800ef2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ef2:	55                   	push   %rbp
  800ef3:	48 89 e5             	mov    %rsp,%rbp
  800ef6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800efd:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800f04:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f0b:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f12:	84 c0                	test   %al,%al
  800f14:	74 20                	je     800f36 <snprintf+0x44>
  800f16:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f1a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f1e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f22:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f26:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f2a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f2e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f32:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f36:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f3d:	00 00 00 
  800f40:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f47:	00 00 00 
  800f4a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f4e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f55:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f5c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f63:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f6a:	48 b8 9d 0e 80 00 00 	movabs $0x800e9d,%rax
  800f71:	00 00 00 
  800f74:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f76:	c9                   	leaveq 
  800f77:	c3                   	retq   

0000000000800f78 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f78:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f7b:	74 17                	je     800f94 <strlen+0x1c>
  800f7d:	48 89 fa             	mov    %rdi,%rdx
  800f80:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f85:	29 f9                	sub    %edi,%ecx
    n++;
  800f87:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f8a:	48 83 c2 01          	add    $0x1,%rdx
  800f8e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f91:	75 f4                	jne    800f87 <strlen+0xf>
  800f93:	c3                   	retq   
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f99:	c3                   	retq   

0000000000800f9a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f9a:	48 85 f6             	test   %rsi,%rsi
  800f9d:	74 24                	je     800fc3 <strnlen+0x29>
  800f9f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800fa2:	74 25                	je     800fc9 <strnlen+0x2f>
  800fa4:	48 01 fe             	add    %rdi,%rsi
  800fa7:	48 89 fa             	mov    %rdi,%rdx
  800faa:	b9 01 00 00 00       	mov    $0x1,%ecx
  800faf:	29 f9                	sub    %edi,%ecx
    n++;
  800fb1:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fb4:	48 83 c2 01          	add    $0x1,%rdx
  800fb8:	48 39 f2             	cmp    %rsi,%rdx
  800fbb:	74 11                	je     800fce <strnlen+0x34>
  800fbd:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fc0:	75 ef                	jne    800fb1 <strnlen+0x17>
  800fc2:	c3                   	retq   
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc8:	c3                   	retq   
  800fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fce:	c3                   	retq   

0000000000800fcf <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fcf:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd7:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fdb:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fde:	48 83 c2 01          	add    $0x1,%rdx
  800fe2:	84 c9                	test   %cl,%cl
  800fe4:	75 f1                	jne    800fd7 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fe6:	c3                   	retq   

0000000000800fe7 <strcat>:

char *
strcat(char *dst, const char *src) {
  800fe7:	55                   	push   %rbp
  800fe8:	48 89 e5             	mov    %rsp,%rbp
  800feb:	41 54                	push   %r12
  800fed:	53                   	push   %rbx
  800fee:	48 89 fb             	mov    %rdi,%rbx
  800ff1:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800ff4:	48 b8 78 0f 80 00 00 	movabs $0x800f78,%rax
  800ffb:	00 00 00 
  800ffe:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  801000:	48 63 f8             	movslq %eax,%rdi
  801003:	48 01 df             	add    %rbx,%rdi
  801006:	4c 89 e6             	mov    %r12,%rsi
  801009:	48 b8 cf 0f 80 00 00 	movabs $0x800fcf,%rax
  801010:	00 00 00 
  801013:	ff d0                	callq  *%rax
  return dst;
}
  801015:	48 89 d8             	mov    %rbx,%rax
  801018:	5b                   	pop    %rbx
  801019:	41 5c                	pop    %r12
  80101b:	5d                   	pop    %rbp
  80101c:	c3                   	retq   

000000000080101d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80101d:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801020:	48 85 d2             	test   %rdx,%rdx
  801023:	74 1f                	je     801044 <strncpy+0x27>
  801025:	48 01 fa             	add    %rdi,%rdx
  801028:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  80102b:	48 83 c1 01          	add    $0x1,%rcx
  80102f:	44 0f b6 06          	movzbl (%rsi),%r8d
  801033:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801037:	41 80 f8 01          	cmp    $0x1,%r8b
  80103b:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  80103f:	48 39 ca             	cmp    %rcx,%rdx
  801042:	75 e7                	jne    80102b <strncpy+0xe>
  }
  return ret;
}
  801044:	c3                   	retq   

0000000000801045 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801045:	48 89 f8             	mov    %rdi,%rax
  801048:	48 85 d2             	test   %rdx,%rdx
  80104b:	74 36                	je     801083 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  80104d:	48 83 fa 01          	cmp    $0x1,%rdx
  801051:	74 2d                	je     801080 <strlcpy+0x3b>
  801053:	44 0f b6 06          	movzbl (%rsi),%r8d
  801057:	45 84 c0             	test   %r8b,%r8b
  80105a:	74 24                	je     801080 <strlcpy+0x3b>
  80105c:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801060:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801065:	48 83 c0 01          	add    $0x1,%rax
  801069:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  80106d:	48 39 d1             	cmp    %rdx,%rcx
  801070:	74 0e                	je     801080 <strlcpy+0x3b>
  801072:	48 83 c1 01          	add    $0x1,%rcx
  801076:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  80107b:	45 84 c0             	test   %r8b,%r8b
  80107e:	75 e5                	jne    801065 <strlcpy+0x20>
    *dst = '\0';
  801080:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  801083:	48 29 f8             	sub    %rdi,%rax
}
  801086:	c3                   	retq   

0000000000801087 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801087:	0f b6 07             	movzbl (%rdi),%eax
  80108a:	84 c0                	test   %al,%al
  80108c:	74 17                	je     8010a5 <strcmp+0x1e>
  80108e:	3a 06                	cmp    (%rsi),%al
  801090:	75 13                	jne    8010a5 <strcmp+0x1e>
    p++, q++;
  801092:	48 83 c7 01          	add    $0x1,%rdi
  801096:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  80109a:	0f b6 07             	movzbl (%rdi),%eax
  80109d:	84 c0                	test   %al,%al
  80109f:	74 04                	je     8010a5 <strcmp+0x1e>
  8010a1:	3a 06                	cmp    (%rsi),%al
  8010a3:	74 ed                	je     801092 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8010a5:	0f b6 c0             	movzbl %al,%eax
  8010a8:	0f b6 16             	movzbl (%rsi),%edx
  8010ab:	29 d0                	sub    %edx,%eax
}
  8010ad:	c3                   	retq   

00000000008010ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8010ae:	48 85 d2             	test   %rdx,%rdx
  8010b1:	74 2f                	je     8010e2 <strncmp+0x34>
  8010b3:	0f b6 07             	movzbl (%rdi),%eax
  8010b6:	84 c0                	test   %al,%al
  8010b8:	74 1f                	je     8010d9 <strncmp+0x2b>
  8010ba:	3a 06                	cmp    (%rsi),%al
  8010bc:	75 1b                	jne    8010d9 <strncmp+0x2b>
  8010be:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010c1:	48 83 c7 01          	add    $0x1,%rdi
  8010c5:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010c9:	48 39 d7             	cmp    %rdx,%rdi
  8010cc:	74 1a                	je     8010e8 <strncmp+0x3a>
  8010ce:	0f b6 07             	movzbl (%rdi),%eax
  8010d1:	84 c0                	test   %al,%al
  8010d3:	74 04                	je     8010d9 <strncmp+0x2b>
  8010d5:	3a 06                	cmp    (%rsi),%al
  8010d7:	74 e8                	je     8010c1 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010d9:	0f b6 07             	movzbl (%rdi),%eax
  8010dc:	0f b6 16             	movzbl (%rsi),%edx
  8010df:	29 d0                	sub    %edx,%eax
}
  8010e1:	c3                   	retq   
    return 0;
  8010e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e7:	c3                   	retq   
  8010e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ed:	c3                   	retq   

00000000008010ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010ee:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010f0:	0f b6 07             	movzbl (%rdi),%eax
  8010f3:	84 c0                	test   %al,%al
  8010f5:	74 1e                	je     801115 <strchr+0x27>
    if (*s == c)
  8010f7:	40 38 c6             	cmp    %al,%sil
  8010fa:	74 1f                	je     80111b <strchr+0x2d>
  for (; *s; s++)
  8010fc:	48 83 c7 01          	add    $0x1,%rdi
  801100:	0f b6 07             	movzbl (%rdi),%eax
  801103:	84 c0                	test   %al,%al
  801105:	74 08                	je     80110f <strchr+0x21>
    if (*s == c)
  801107:	38 d0                	cmp    %dl,%al
  801109:	75 f1                	jne    8010fc <strchr+0xe>
  for (; *s; s++)
  80110b:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  80110e:	c3                   	retq   
  return 0;
  80110f:	b8 00 00 00 00       	mov    $0x0,%eax
  801114:	c3                   	retq   
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
  80111a:	c3                   	retq   
    if (*s == c)
  80111b:	48 89 f8             	mov    %rdi,%rax
  80111e:	c3                   	retq   

000000000080111f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  80111f:	48 89 f8             	mov    %rdi,%rax
  801122:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  801124:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801127:	40 38 f2             	cmp    %sil,%dl
  80112a:	74 13                	je     80113f <strfind+0x20>
  80112c:	84 d2                	test   %dl,%dl
  80112e:	74 0f                	je     80113f <strfind+0x20>
  for (; *s; s++)
  801130:	48 83 c0 01          	add    $0x1,%rax
  801134:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801137:	38 ca                	cmp    %cl,%dl
  801139:	74 04                	je     80113f <strfind+0x20>
  80113b:	84 d2                	test   %dl,%dl
  80113d:	75 f1                	jne    801130 <strfind+0x11>
      break;
  return (char *)s;
}
  80113f:	c3                   	retq   

0000000000801140 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801140:	48 85 d2             	test   %rdx,%rdx
  801143:	74 3a                	je     80117f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801145:	48 89 f8             	mov    %rdi,%rax
  801148:	48 09 d0             	or     %rdx,%rax
  80114b:	a8 03                	test   $0x3,%al
  80114d:	75 28                	jne    801177 <memset+0x37>
    uint32_t k = c & 0xFFU;
  80114f:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801153:	89 f0                	mov    %esi,%eax
  801155:	c1 e0 08             	shl    $0x8,%eax
  801158:	89 f1                	mov    %esi,%ecx
  80115a:	c1 e1 18             	shl    $0x18,%ecx
  80115d:	41 89 f0             	mov    %esi,%r8d
  801160:	41 c1 e0 10          	shl    $0x10,%r8d
  801164:	44 09 c1             	or     %r8d,%ecx
  801167:	09 ce                	or     %ecx,%esi
  801169:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  80116b:	48 c1 ea 02          	shr    $0x2,%rdx
  80116f:	48 89 d1             	mov    %rdx,%rcx
  801172:	fc                   	cld    
  801173:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801175:	eb 08                	jmp    80117f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801177:	89 f0                	mov    %esi,%eax
  801179:	48 89 d1             	mov    %rdx,%rcx
  80117c:	fc                   	cld    
  80117d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  80117f:	48 89 f8             	mov    %rdi,%rax
  801182:	c3                   	retq   

0000000000801183 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  801183:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801186:	48 39 fe             	cmp    %rdi,%rsi
  801189:	73 40                	jae    8011cb <memmove+0x48>
  80118b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  80118f:	48 39 f9             	cmp    %rdi,%rcx
  801192:	76 37                	jbe    8011cb <memmove+0x48>
    s += n;
    d += n;
  801194:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801198:	48 89 fe             	mov    %rdi,%rsi
  80119b:	48 09 d6             	or     %rdx,%rsi
  80119e:	48 09 ce             	or     %rcx,%rsi
  8011a1:	40 f6 c6 03          	test   $0x3,%sil
  8011a5:	75 14                	jne    8011bb <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8011a7:	48 83 ef 04          	sub    $0x4,%rdi
  8011ab:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8011af:	48 c1 ea 02          	shr    $0x2,%rdx
  8011b3:	48 89 d1             	mov    %rdx,%rcx
  8011b6:	fd                   	std    
  8011b7:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011b9:	eb 0e                	jmp    8011c9 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011bb:	48 83 ef 01          	sub    $0x1,%rdi
  8011bf:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011c3:	48 89 d1             	mov    %rdx,%rcx
  8011c6:	fd                   	std    
  8011c7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011c9:	fc                   	cld    
  8011ca:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011cb:	48 89 c1             	mov    %rax,%rcx
  8011ce:	48 09 d1             	or     %rdx,%rcx
  8011d1:	48 09 f1             	or     %rsi,%rcx
  8011d4:	f6 c1 03             	test   $0x3,%cl
  8011d7:	75 0e                	jne    8011e7 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011d9:	48 c1 ea 02          	shr    $0x2,%rdx
  8011dd:	48 89 d1             	mov    %rdx,%rcx
  8011e0:	48 89 c7             	mov    %rax,%rdi
  8011e3:	fc                   	cld    
  8011e4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011e6:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011e7:	48 89 c7             	mov    %rax,%rdi
  8011ea:	48 89 d1             	mov    %rdx,%rcx
  8011ed:	fc                   	cld    
  8011ee:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011f0:	c3                   	retq   

00000000008011f1 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011f1:	55                   	push   %rbp
  8011f2:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011f5:	48 b8 83 11 80 00 00 	movabs $0x801183,%rax
  8011fc:	00 00 00 
  8011ff:	ff d0                	callq  *%rax
}
  801201:	5d                   	pop    %rbp
  801202:	c3                   	retq   

0000000000801203 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  801203:	55                   	push   %rbp
  801204:	48 89 e5             	mov    %rsp,%rbp
  801207:	41 57                	push   %r15
  801209:	41 56                	push   %r14
  80120b:	41 55                	push   %r13
  80120d:	41 54                	push   %r12
  80120f:	53                   	push   %rbx
  801210:	48 83 ec 08          	sub    $0x8,%rsp
  801214:	49 89 fe             	mov    %rdi,%r14
  801217:	49 89 f7             	mov    %rsi,%r15
  80121a:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  80121d:	48 89 f7             	mov    %rsi,%rdi
  801220:	48 b8 78 0f 80 00 00 	movabs $0x800f78,%rax
  801227:	00 00 00 
  80122a:	ff d0                	callq  *%rax
  80122c:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  80122f:	4c 89 ee             	mov    %r13,%rsi
  801232:	4c 89 f7             	mov    %r14,%rdi
  801235:	48 b8 9a 0f 80 00 00 	movabs $0x800f9a,%rax
  80123c:	00 00 00 
  80123f:	ff d0                	callq  *%rax
  801241:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  801244:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801248:	4d 39 e5             	cmp    %r12,%r13
  80124b:	74 26                	je     801273 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  80124d:	4c 89 e8             	mov    %r13,%rax
  801250:	4c 29 e0             	sub    %r12,%rax
  801253:	48 39 d8             	cmp    %rbx,%rax
  801256:	76 2a                	jbe    801282 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801258:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  80125c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801260:	4c 89 fe             	mov    %r15,%rsi
  801263:	48 b8 f1 11 80 00 00 	movabs $0x8011f1,%rax
  80126a:	00 00 00 
  80126d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80126f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801273:	48 83 c4 08          	add    $0x8,%rsp
  801277:	5b                   	pop    %rbx
  801278:	41 5c                	pop    %r12
  80127a:	41 5d                	pop    %r13
  80127c:	41 5e                	pop    %r14
  80127e:	41 5f                	pop    %r15
  801280:	5d                   	pop    %rbp
  801281:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801282:	49 83 ed 01          	sub    $0x1,%r13
  801286:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80128a:	4c 89 ea             	mov    %r13,%rdx
  80128d:	4c 89 fe             	mov    %r15,%rsi
  801290:	48 b8 f1 11 80 00 00 	movabs $0x8011f1,%rax
  801297:	00 00 00 
  80129a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80129c:	4d 01 ee             	add    %r13,%r14
  80129f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8012a4:	eb c9                	jmp    80126f <strlcat+0x6c>

00000000008012a6 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8012a6:	48 85 d2             	test   %rdx,%rdx
  8012a9:	74 3a                	je     8012e5 <memcmp+0x3f>
    if (*s1 != *s2)
  8012ab:	0f b6 0f             	movzbl (%rdi),%ecx
  8012ae:	44 0f b6 06          	movzbl (%rsi),%r8d
  8012b2:	44 38 c1             	cmp    %r8b,%cl
  8012b5:	75 1d                	jne    8012d4 <memcmp+0x2e>
  8012b7:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012bc:	48 39 d0             	cmp    %rdx,%rax
  8012bf:	74 1e                	je     8012df <memcmp+0x39>
    if (*s1 != *s2)
  8012c1:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012c5:	48 83 c0 01          	add    $0x1,%rax
  8012c9:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012cf:	44 38 c1             	cmp    %r8b,%cl
  8012d2:	74 e8                	je     8012bc <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012d4:	0f b6 c1             	movzbl %cl,%eax
  8012d7:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012db:	44 29 c0             	sub    %r8d,%eax
  8012de:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012df:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e4:	c3                   	retq   
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ea:	c3                   	retq   

00000000008012eb <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012eb:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012ef:	48 39 c7             	cmp    %rax,%rdi
  8012f2:	73 19                	jae    80130d <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012f4:	89 f2                	mov    %esi,%edx
  8012f6:	40 38 37             	cmp    %sil,(%rdi)
  8012f9:	74 16                	je     801311 <memfind+0x26>
  for (; s < ends; s++)
  8012fb:	48 83 c7 01          	add    $0x1,%rdi
  8012ff:	48 39 f8             	cmp    %rdi,%rax
  801302:	74 08                	je     80130c <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801304:	38 17                	cmp    %dl,(%rdi)
  801306:	75 f3                	jne    8012fb <memfind+0x10>
  for (; s < ends; s++)
  801308:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80130b:	c3                   	retq   
  80130c:	c3                   	retq   
  for (; s < ends; s++)
  80130d:	48 89 f8             	mov    %rdi,%rax
  801310:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801311:	48 89 f8             	mov    %rdi,%rax
  801314:	c3                   	retq   

0000000000801315 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801315:	0f b6 07             	movzbl (%rdi),%eax
  801318:	3c 20                	cmp    $0x20,%al
  80131a:	74 04                	je     801320 <strtol+0xb>
  80131c:	3c 09                	cmp    $0x9,%al
  80131e:	75 0f                	jne    80132f <strtol+0x1a>
    s++;
  801320:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801324:	0f b6 07             	movzbl (%rdi),%eax
  801327:	3c 20                	cmp    $0x20,%al
  801329:	74 f5                	je     801320 <strtol+0xb>
  80132b:	3c 09                	cmp    $0x9,%al
  80132d:	74 f1                	je     801320 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80132f:	3c 2b                	cmp    $0x2b,%al
  801331:	74 2b                	je     80135e <strtol+0x49>
  int neg  = 0;
  801333:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801339:	3c 2d                	cmp    $0x2d,%al
  80133b:	74 2d                	je     80136a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80133d:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801343:	75 0f                	jne    801354 <strtol+0x3f>
  801345:	80 3f 30             	cmpb   $0x30,(%rdi)
  801348:	74 2c                	je     801376 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80134a:	85 d2                	test   %edx,%edx
  80134c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801351:	0f 44 d0             	cmove  %eax,%edx
  801354:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801359:	4c 63 d2             	movslq %edx,%r10
  80135c:	eb 5c                	jmp    8013ba <strtol+0xa5>
    s++;
  80135e:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801362:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801368:	eb d3                	jmp    80133d <strtol+0x28>
    s++, neg = 1;
  80136a:	48 83 c7 01          	add    $0x1,%rdi
  80136e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801374:	eb c7                	jmp    80133d <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801376:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80137a:	74 0f                	je     80138b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80137c:	85 d2                	test   %edx,%edx
  80137e:	75 d4                	jne    801354 <strtol+0x3f>
    s++, base = 8;
  801380:	48 83 c7 01          	add    $0x1,%rdi
  801384:	ba 08 00 00 00       	mov    $0x8,%edx
  801389:	eb c9                	jmp    801354 <strtol+0x3f>
    s += 2, base = 16;
  80138b:	48 83 c7 02          	add    $0x2,%rdi
  80138f:	ba 10 00 00 00       	mov    $0x10,%edx
  801394:	eb be                	jmp    801354 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801396:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80139a:	41 80 f8 19          	cmp    $0x19,%r8b
  80139e:	77 2f                	ja     8013cf <strtol+0xba>
      dig = *s - 'a' + 10;
  8013a0:	44 0f be c1          	movsbl %cl,%r8d
  8013a4:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8013a8:	39 d1                	cmp    %edx,%ecx
  8013aa:	7d 37                	jge    8013e3 <strtol+0xce>
    s++, val = (val * base) + dig;
  8013ac:	48 83 c7 01          	add    $0x1,%rdi
  8013b0:	49 0f af c2          	imul   %r10,%rax
  8013b4:	48 63 c9             	movslq %ecx,%rcx
  8013b7:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013ba:	0f b6 0f             	movzbl (%rdi),%ecx
  8013bd:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013c1:	41 80 f8 09          	cmp    $0x9,%r8b
  8013c5:	77 cf                	ja     801396 <strtol+0x81>
      dig = *s - '0';
  8013c7:	0f be c9             	movsbl %cl,%ecx
  8013ca:	83 e9 30             	sub    $0x30,%ecx
  8013cd:	eb d9                	jmp    8013a8 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013cf:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013d3:	41 80 f8 19          	cmp    $0x19,%r8b
  8013d7:	77 0a                	ja     8013e3 <strtol+0xce>
      dig = *s - 'A' + 10;
  8013d9:	44 0f be c1          	movsbl %cl,%r8d
  8013dd:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013e1:	eb c5                	jmp    8013a8 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013e3:	48 85 f6             	test   %rsi,%rsi
  8013e6:	74 03                	je     8013eb <strtol+0xd6>
    *endptr = (char *)s;
  8013e8:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013eb:	48 89 c2             	mov    %rax,%rdx
  8013ee:	48 f7 da             	neg    %rdx
  8013f1:	45 85 c9             	test   %r9d,%r9d
  8013f4:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013f8:	c3                   	retq   
  8013f9:	0f 1f 00             	nopl   (%rax)
