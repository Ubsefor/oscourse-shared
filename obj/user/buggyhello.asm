
obj/user/buggyhello:     file format elf64-x86-64


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
  800023:	e8 1e 00 00 00       	callq  800046 <libmain>
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
  sys_cputs((char *)1, 1);
  80002e:	be 01 00 00 00       	mov    $0x1,%esi
  800033:	bf 01 00 00 00       	mov    $0x1,%edi
  800038:	48 b8 13 01 80 00 00 	movabs $0x800113,%rax
  80003f:	00 00 00 
  800042:	ff d0                	callq  *%rax
}
  800044:	5d                   	pop    %rbp
  800045:	c3                   	retq   

0000000000800046 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800046:	55                   	push   %rbp
  800047:	48 89 e5             	mov    %rsp,%rbp
  80004a:	41 56                	push   %r14
  80004c:	41 55                	push   %r13
  80004e:	41 54                	push   %r12
  800050:	53                   	push   %rbx
  800051:	41 89 fd             	mov    %edi,%r13d
  800054:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800057:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  80005e:	00 00 00 
  800061:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800068:	00 00 00 
  80006b:	48 39 c2             	cmp    %rax,%rdx
  80006e:	73 23                	jae    800093 <libmain+0x4d>
  800070:	48 89 d3             	mov    %rdx,%rbx
  800073:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800077:	48 29 d0             	sub    %rdx,%rax
  80007a:	48 c1 e8 03          	shr    $0x3,%rax
  80007e:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
  800088:	ff 13                	callq  *(%rbx)
    ctor++;
  80008a:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80008e:	4c 39 e3             	cmp    %r12,%rbx
  800091:	75 f0                	jne    800083 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800093:	48 b8 b1 01 80 00 00 	movabs $0x8001b1,%rax
  80009a:	00 00 00 
  80009d:	ff d0                	callq  *%rax
  80009f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a4:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000a8:	48 c1 e0 05          	shl    $0x5,%rax
  8000ac:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000b3:	00 00 00 
  8000b6:	48 01 d0             	add    %rdx,%rax
  8000b9:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000c0:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000c3:	45 85 ed             	test   %r13d,%r13d
  8000c6:	7e 0d                	jle    8000d5 <libmain+0x8f>
    binaryname = argv[0];
  8000c8:	49 8b 06             	mov    (%r14),%rax
  8000cb:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000d2:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000d5:	4c 89 f6             	mov    %r14,%rsi
  8000d8:	44 89 ef             	mov    %r13d,%edi
  8000db:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000e2:	00 00 00 
  8000e5:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000e7:	48 b8 fc 00 80 00 00 	movabs $0x8000fc,%rax
  8000ee:	00 00 00 
  8000f1:	ff d0                	callq  *%rax
#endif
}
  8000f3:	5b                   	pop    %rbx
  8000f4:	41 5c                	pop    %r12
  8000f6:	41 5d                	pop    %r13
  8000f8:	41 5e                	pop    %r14
  8000fa:	5d                   	pop    %rbp
  8000fb:	c3                   	retq   

00000000008000fc <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000fc:	55                   	push   %rbp
  8000fd:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800100:	bf 00 00 00 00       	mov    $0x0,%edi
  800105:	48 b8 51 01 80 00 00 	movabs $0x800151,%rax
  80010c:	00 00 00 
  80010f:	ff d0                	callq  *%rax
}
  800111:	5d                   	pop    %rbp
  800112:	c3                   	retq   

0000000000800113 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800113:	55                   	push   %rbp
  800114:	48 89 e5             	mov    %rsp,%rbp
  800117:	53                   	push   %rbx
  800118:	48 89 fa             	mov    %rdi,%rdx
  80011b:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  80011e:	b8 00 00 00 00       	mov    $0x0,%eax
  800123:	48 89 c3             	mov    %rax,%rbx
  800126:	48 89 c7             	mov    %rax,%rdi
  800129:	48 89 c6             	mov    %rax,%rsi
  80012c:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  80012e:	5b                   	pop    %rbx
  80012f:	5d                   	pop    %rbp
  800130:	c3                   	retq   

0000000000800131 <sys_cgetc>:

int
sys_cgetc(void) {
  800131:	55                   	push   %rbp
  800132:	48 89 e5             	mov    %rsp,%rbp
  800135:	53                   	push   %rbx
  asm volatile("int %1\n"
  800136:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013b:	b8 01 00 00 00       	mov    $0x1,%eax
  800140:	48 89 ca             	mov    %rcx,%rdx
  800143:	48 89 cb             	mov    %rcx,%rbx
  800146:	48 89 cf             	mov    %rcx,%rdi
  800149:	48 89 ce             	mov    %rcx,%rsi
  80014c:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80014e:	5b                   	pop    %rbx
  80014f:	5d                   	pop    %rbp
  800150:	c3                   	retq   

0000000000800151 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800151:	55                   	push   %rbp
  800152:	48 89 e5             	mov    %rsp,%rbp
  800155:	53                   	push   %rbx
  800156:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80015d:	be 00 00 00 00       	mov    $0x0,%esi
  800162:	b8 03 00 00 00       	mov    $0x3,%eax
  800167:	48 89 f1             	mov    %rsi,%rcx
  80016a:	48 89 f3             	mov    %rsi,%rbx
  80016d:	48 89 f7             	mov    %rsi,%rdi
  800170:	cd 30                	int    $0x30
  if (check && ret > 0)
  800172:	48 85 c0             	test   %rax,%rax
  800175:	7f 07                	jg     80017e <sys_env_destroy+0x2d>
}
  800177:	48 83 c4 08          	add    $0x8,%rsp
  80017b:	5b                   	pop    %rbx
  80017c:	5d                   	pop    %rbp
  80017d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80017e:	49 89 c0             	mov    %rax,%r8
  800181:	b9 03 00 00 00       	mov    $0x3,%ecx
  800186:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80018d:	00 00 00 
  800190:	be 22 00 00 00       	mov    $0x22,%esi
  800195:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80019c:	00 00 00 
  80019f:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a4:	49 b9 5e 04 80 00 00 	movabs $0x80045e,%r9
  8001ab:	00 00 00 
  8001ae:	41 ff d1             	callq  *%r9

00000000008001b1 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001b1:	55                   	push   %rbp
  8001b2:	48 89 e5             	mov    %rsp,%rbp
  8001b5:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8001c0:	48 89 ca             	mov    %rcx,%rdx
  8001c3:	48 89 cb             	mov    %rcx,%rbx
  8001c6:	48 89 cf             	mov    %rcx,%rdi
  8001c9:	48 89 ce             	mov    %rcx,%rsi
  8001cc:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001ce:	5b                   	pop    %rbx
  8001cf:	5d                   	pop    %rbp
  8001d0:	c3                   	retq   

00000000008001d1 <sys_yield>:

void
sys_yield(void) {
  8001d1:	55                   	push   %rbp
  8001d2:	48 89 e5             	mov    %rsp,%rbp
  8001d5:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001e0:	48 89 ca             	mov    %rcx,%rdx
  8001e3:	48 89 cb             	mov    %rcx,%rbx
  8001e6:	48 89 cf             	mov    %rcx,%rdi
  8001e9:	48 89 ce             	mov    %rcx,%rsi
  8001ec:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001ee:	5b                   	pop    %rbx
  8001ef:	5d                   	pop    %rbp
  8001f0:	c3                   	retq   

00000000008001f1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001f1:	55                   	push   %rbp
  8001f2:	48 89 e5             	mov    %rsp,%rbp
  8001f5:	53                   	push   %rbx
  8001f6:	48 83 ec 08          	sub    $0x8,%rsp
  8001fa:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8001fd:	4c 63 c7             	movslq %edi,%r8
  800200:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  800203:	be 00 00 00 00       	mov    $0x0,%esi
  800208:	b8 04 00 00 00       	mov    $0x4,%eax
  80020d:	4c 89 c2             	mov    %r8,%rdx
  800210:	48 89 f7             	mov    %rsi,%rdi
  800213:	cd 30                	int    $0x30
  if (check && ret > 0)
  800215:	48 85 c0             	test   %rax,%rax
  800218:	7f 07                	jg     800221 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80021a:	48 83 c4 08          	add    $0x8,%rsp
  80021e:	5b                   	pop    %rbx
  80021f:	5d                   	pop    %rbp
  800220:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800221:	49 89 c0             	mov    %rax,%r8
  800224:	b9 04 00 00 00       	mov    $0x4,%ecx
  800229:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800230:	00 00 00 
  800233:	be 22 00 00 00       	mov    $0x22,%esi
  800238:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80023f:	00 00 00 
  800242:	b8 00 00 00 00       	mov    $0x0,%eax
  800247:	49 b9 5e 04 80 00 00 	movabs $0x80045e,%r9
  80024e:	00 00 00 
  800251:	41 ff d1             	callq  *%r9

0000000000800254 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  800254:	55                   	push   %rbp
  800255:	48 89 e5             	mov    %rsp,%rbp
  800258:	53                   	push   %rbx
  800259:	48 83 ec 08          	sub    $0x8,%rsp
  80025d:	41 89 f9             	mov    %edi,%r9d
  800260:	49 89 f2             	mov    %rsi,%r10
  800263:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  800266:	4d 63 c9             	movslq %r9d,%r9
  800269:	48 63 da             	movslq %edx,%rbx
  80026c:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80026f:	b8 05 00 00 00       	mov    $0x5,%eax
  800274:	4c 89 ca             	mov    %r9,%rdx
  800277:	4c 89 d1             	mov    %r10,%rcx
  80027a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80027c:	48 85 c0             	test   %rax,%rax
  80027f:	7f 07                	jg     800288 <sys_page_map+0x34>
}
  800281:	48 83 c4 08          	add    $0x8,%rsp
  800285:	5b                   	pop    %rbx
  800286:	5d                   	pop    %rbp
  800287:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800288:	49 89 c0             	mov    %rax,%r8
  80028b:	b9 05 00 00 00       	mov    $0x5,%ecx
  800290:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800297:	00 00 00 
  80029a:	be 22 00 00 00       	mov    $0x22,%esi
  80029f:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8002a6:	00 00 00 
  8002a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ae:	49 b9 5e 04 80 00 00 	movabs $0x80045e,%r9
  8002b5:	00 00 00 
  8002b8:	41 ff d1             	callq  *%r9

00000000008002bb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002bb:	55                   	push   %rbp
  8002bc:	48 89 e5             	mov    %rsp,%rbp
  8002bf:	53                   	push   %rbx
  8002c0:	48 83 ec 08          	sub    $0x8,%rsp
  8002c4:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002c7:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002ca:	be 00 00 00 00       	mov    $0x0,%esi
  8002cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8002d4:	48 89 f3             	mov    %rsi,%rbx
  8002d7:	48 89 f7             	mov    %rsi,%rdi
  8002da:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002dc:	48 85 c0             	test   %rax,%rax
  8002df:	7f 07                	jg     8002e8 <sys_page_unmap+0x2d>
}
  8002e1:	48 83 c4 08          	add    $0x8,%rsp
  8002e5:	5b                   	pop    %rbx
  8002e6:	5d                   	pop    %rbp
  8002e7:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002e8:	49 89 c0             	mov    %rax,%r8
  8002eb:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002f0:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8002f7:	00 00 00 
  8002fa:	be 22 00 00 00       	mov    $0x22,%esi
  8002ff:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800306:	00 00 00 
  800309:	b8 00 00 00 00       	mov    $0x0,%eax
  80030e:	49 b9 5e 04 80 00 00 	movabs $0x80045e,%r9
  800315:	00 00 00 
  800318:	41 ff d1             	callq  *%r9

000000000080031b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  80031b:	55                   	push   %rbp
  80031c:	48 89 e5             	mov    %rsp,%rbp
  80031f:	53                   	push   %rbx
  800320:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800324:	48 63 d7             	movslq %edi,%rdx
  800327:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80032a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032f:	b8 08 00 00 00       	mov    $0x8,%eax
  800334:	48 89 df             	mov    %rbx,%rdi
  800337:	48 89 de             	mov    %rbx,%rsi
  80033a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80033c:	48 85 c0             	test   %rax,%rax
  80033f:	7f 07                	jg     800348 <sys_env_set_status+0x2d>
}
  800341:	48 83 c4 08          	add    $0x8,%rsp
  800345:	5b                   	pop    %rbx
  800346:	5d                   	pop    %rbp
  800347:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800348:	49 89 c0             	mov    %rax,%r8
  80034b:	b9 08 00 00 00       	mov    $0x8,%ecx
  800350:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800357:	00 00 00 
  80035a:	be 22 00 00 00       	mov    $0x22,%esi
  80035f:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800366:	00 00 00 
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	49 b9 5e 04 80 00 00 	movabs $0x80045e,%r9
  800375:	00 00 00 
  800378:	41 ff d1             	callq  *%r9

000000000080037b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80037b:	55                   	push   %rbp
  80037c:	48 89 e5             	mov    %rsp,%rbp
  80037f:	53                   	push   %rbx
  800380:	48 83 ec 08          	sub    $0x8,%rsp
  800384:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  800387:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80038a:	be 00 00 00 00       	mov    $0x0,%esi
  80038f:	b8 09 00 00 00       	mov    $0x9,%eax
  800394:	48 89 f3             	mov    %rsi,%rbx
  800397:	48 89 f7             	mov    %rsi,%rdi
  80039a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80039c:	48 85 c0             	test   %rax,%rax
  80039f:	7f 07                	jg     8003a8 <sys_env_set_pgfault_upcall+0x2d>
}
  8003a1:	48 83 c4 08          	add    $0x8,%rsp
  8003a5:	5b                   	pop    %rbx
  8003a6:	5d                   	pop    %rbp
  8003a7:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8003a8:	49 89 c0             	mov    %rax,%r8
  8003ab:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003b0:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8003b7:	00 00 00 
  8003ba:	be 22 00 00 00       	mov    $0x22,%esi
  8003bf:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8003c6:	00 00 00 
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	49 b9 5e 04 80 00 00 	movabs $0x80045e,%r9
  8003d5:	00 00 00 
  8003d8:	41 ff d1             	callq  *%r9

00000000008003db <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003db:	55                   	push   %rbp
  8003dc:	48 89 e5             	mov    %rsp,%rbp
  8003df:	53                   	push   %rbx
  8003e0:	49 89 f0             	mov    %rsi,%r8
  8003e3:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003e6:	48 63 d7             	movslq %edi,%rdx
  8003e9:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003ec:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003f1:	be 00 00 00 00       	mov    $0x0,%esi
  8003f6:	4c 89 c1             	mov    %r8,%rcx
  8003f9:	cd 30                	int    $0x30
}
  8003fb:	5b                   	pop    %rbx
  8003fc:	5d                   	pop    %rbp
  8003fd:	c3                   	retq   

00000000008003fe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8003fe:	55                   	push   %rbp
  8003ff:	48 89 e5             	mov    %rsp,%rbp
  800402:	53                   	push   %rbx
  800403:	48 83 ec 08          	sub    $0x8,%rsp
  800407:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  80040a:	be 00 00 00 00       	mov    $0x0,%esi
  80040f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800414:	48 89 f1             	mov    %rsi,%rcx
  800417:	48 89 f3             	mov    %rsi,%rbx
  80041a:	48 89 f7             	mov    %rsi,%rdi
  80041d:	cd 30                	int    $0x30
  if (check && ret > 0)
  80041f:	48 85 c0             	test   %rax,%rax
  800422:	7f 07                	jg     80042b <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  800424:	48 83 c4 08          	add    $0x8,%rsp
  800428:	5b                   	pop    %rbx
  800429:	5d                   	pop    %rbp
  80042a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80042b:	49 89 c0             	mov    %rax,%r8
  80042e:	b9 0c 00 00 00       	mov    $0xc,%ecx
  800433:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80043a:	00 00 00 
  80043d:	be 22 00 00 00       	mov    $0x22,%esi
  800442:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800449:	00 00 00 
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	49 b9 5e 04 80 00 00 	movabs $0x80045e,%r9
  800458:	00 00 00 
  80045b:	41 ff d1             	callq  *%r9

000000000080045e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80045e:	55                   	push   %rbp
  80045f:	48 89 e5             	mov    %rsp,%rbp
  800462:	41 56                	push   %r14
  800464:	41 55                	push   %r13
  800466:	41 54                	push   %r12
  800468:	53                   	push   %rbx
  800469:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800470:	49 89 fd             	mov    %rdi,%r13
  800473:	41 89 f6             	mov    %esi,%r14d
  800476:	49 89 d4             	mov    %rdx,%r12
  800479:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800480:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800487:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80048e:	84 c0                	test   %al,%al
  800490:	74 26                	je     8004b8 <_panic+0x5a>
  800492:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800499:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  8004a0:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  8004a4:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  8004a8:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8004ac:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8004b0:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8004b4:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004b8:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004bf:	00 00 00 
  8004c2:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004c9:	00 00 00 
  8004cc:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004d0:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004d7:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004de:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004e5:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004ec:	00 00 00 
  8004ef:	48 8b 18             	mov    (%rax),%rbx
  8004f2:	48 b8 b1 01 80 00 00 	movabs $0x8001b1,%rax
  8004f9:	00 00 00 
  8004fc:	ff d0                	callq  *%rax
  8004fe:	45 89 f0             	mov    %r14d,%r8d
  800501:	4c 89 e9             	mov    %r13,%rcx
  800504:	48 89 da             	mov    %rbx,%rdx
  800507:	89 c6                	mov    %eax,%esi
  800509:	48 bf 40 14 80 00 00 	movabs $0x801440,%rdi
  800510:	00 00 00 
  800513:	b8 00 00 00 00       	mov    $0x0,%eax
  800518:	48 bb 00 06 80 00 00 	movabs $0x800600,%rbx
  80051f:	00 00 00 
  800522:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800524:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  80052b:	4c 89 e7             	mov    %r12,%rdi
  80052e:	48 b8 98 05 80 00 00 	movabs $0x800598,%rax
  800535:	00 00 00 
  800538:	ff d0                	callq  *%rax
  cprintf("\n");
  80053a:	48 bf 68 14 80 00 00 	movabs $0x801468,%rdi
  800541:	00 00 00 
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
  800549:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  80054b:	cc                   	int3   
  while (1)
  80054c:	eb fd                	jmp    80054b <_panic+0xed>

000000000080054e <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80054e:	55                   	push   %rbp
  80054f:	48 89 e5             	mov    %rsp,%rbp
  800552:	53                   	push   %rbx
  800553:	48 83 ec 08          	sub    $0x8,%rsp
  800557:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80055a:	8b 06                	mov    (%rsi),%eax
  80055c:	8d 50 01             	lea    0x1(%rax),%edx
  80055f:	89 16                	mov    %edx,(%rsi)
  800561:	48 98                	cltq   
  800563:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800568:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80056e:	74 0b                	je     80057b <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800570:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800574:	48 83 c4 08          	add    $0x8,%rsp
  800578:	5b                   	pop    %rbx
  800579:	5d                   	pop    %rbp
  80057a:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80057b:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80057f:	be ff 00 00 00       	mov    $0xff,%esi
  800584:	48 b8 13 01 80 00 00 	movabs $0x800113,%rax
  80058b:	00 00 00 
  80058e:	ff d0                	callq  *%rax
    b->idx = 0;
  800590:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800596:	eb d8                	jmp    800570 <putch+0x22>

0000000000800598 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800598:	55                   	push   %rbp
  800599:	48 89 e5             	mov    %rsp,%rbp
  80059c:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8005a3:	48 89 fa             	mov    %rdi,%rdx
  8005a6:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  8005a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8005b0:	00 00 00 
  b.cnt = 0;
  8005b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005ba:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005bd:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005c4:	48 bf 4e 05 80 00 00 	movabs $0x80054e,%rdi
  8005cb:	00 00 00 
  8005ce:	48 b8 be 07 80 00 00 	movabs $0x8007be,%rax
  8005d5:	00 00 00 
  8005d8:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005da:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005e1:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005e8:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005ec:	48 b8 13 01 80 00 00 	movabs $0x800113,%rax
  8005f3:	00 00 00 
  8005f6:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8005fe:	c9                   	leaveq 
  8005ff:	c3                   	retq   

0000000000800600 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800600:	55                   	push   %rbp
  800601:	48 89 e5             	mov    %rsp,%rbp
  800604:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80060b:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800612:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800619:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800620:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800627:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80062e:	84 c0                	test   %al,%al
  800630:	74 20                	je     800652 <cprintf+0x52>
  800632:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800636:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80063a:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80063e:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800642:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800646:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80064a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80064e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800652:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800659:	00 00 00 
  80065c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800663:	00 00 00 
  800666:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80066a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800671:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800678:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80067f:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800686:	48 b8 98 05 80 00 00 	movabs $0x800598,%rax
  80068d:	00 00 00 
  800690:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800692:	c9                   	leaveq 
  800693:	c3                   	retq   

0000000000800694 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800694:	55                   	push   %rbp
  800695:	48 89 e5             	mov    %rsp,%rbp
  800698:	41 57                	push   %r15
  80069a:	41 56                	push   %r14
  80069c:	41 55                	push   %r13
  80069e:	41 54                	push   %r12
  8006a0:	53                   	push   %rbx
  8006a1:	48 83 ec 18          	sub    $0x18,%rsp
  8006a5:	49 89 fc             	mov    %rdi,%r12
  8006a8:	49 89 f5             	mov    %rsi,%r13
  8006ab:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8006af:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8006b2:	41 89 cf             	mov    %ecx,%r15d
  8006b5:	49 39 d7             	cmp    %rdx,%r15
  8006b8:	76 45                	jbe    8006ff <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006ba:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006be:	85 db                	test   %ebx,%ebx
  8006c0:	7e 0e                	jle    8006d0 <printnum+0x3c>
      putch(padc, putdat);
  8006c2:	4c 89 ee             	mov    %r13,%rsi
  8006c5:	44 89 f7             	mov    %r14d,%edi
  8006c8:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006cb:	83 eb 01             	sub    $0x1,%ebx
  8006ce:	75 f2                	jne    8006c2 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006d0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d9:	49 f7 f7             	div    %r15
  8006dc:	48 b8 6a 14 80 00 00 	movabs $0x80146a,%rax
  8006e3:	00 00 00 
  8006e6:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006ea:	4c 89 ee             	mov    %r13,%rsi
  8006ed:	41 ff d4             	callq  *%r12
}
  8006f0:	48 83 c4 18          	add    $0x18,%rsp
  8006f4:	5b                   	pop    %rbx
  8006f5:	41 5c                	pop    %r12
  8006f7:	41 5d                	pop    %r13
  8006f9:	41 5e                	pop    %r14
  8006fb:	41 5f                	pop    %r15
  8006fd:	5d                   	pop    %rbp
  8006fe:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ff:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800703:	ba 00 00 00 00       	mov    $0x0,%edx
  800708:	49 f7 f7             	div    %r15
  80070b:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80070f:	48 89 c2             	mov    %rax,%rdx
  800712:	48 b8 94 06 80 00 00 	movabs $0x800694,%rax
  800719:	00 00 00 
  80071c:	ff d0                	callq  *%rax
  80071e:	eb b0                	jmp    8006d0 <printnum+0x3c>

0000000000800720 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800720:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800724:	48 8b 06             	mov    (%rsi),%rax
  800727:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80072b:	73 0a                	jae    800737 <sprintputch+0x17>
    *b->buf++ = ch;
  80072d:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800731:	48 89 16             	mov    %rdx,(%rsi)
  800734:	40 88 38             	mov    %dil,(%rax)
}
  800737:	c3                   	retq   

0000000000800738 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800738:	55                   	push   %rbp
  800739:	48 89 e5             	mov    %rsp,%rbp
  80073c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800743:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80074a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800751:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800758:	84 c0                	test   %al,%al
  80075a:	74 20                	je     80077c <printfmt+0x44>
  80075c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800760:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800764:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800768:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80076c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800770:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800774:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800778:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80077c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800783:	00 00 00 
  800786:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80078d:	00 00 00 
  800790:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800794:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80079b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8007a2:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8007a9:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8007b0:	48 b8 be 07 80 00 00 	movabs $0x8007be,%rax
  8007b7:	00 00 00 
  8007ba:	ff d0                	callq  *%rax
}
  8007bc:	c9                   	leaveq 
  8007bd:	c3                   	retq   

00000000008007be <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007be:	55                   	push   %rbp
  8007bf:	48 89 e5             	mov    %rsp,%rbp
  8007c2:	41 57                	push   %r15
  8007c4:	41 56                	push   %r14
  8007c6:	41 55                	push   %r13
  8007c8:	41 54                	push   %r12
  8007ca:	53                   	push   %rbx
  8007cb:	48 83 ec 48          	sub    $0x48,%rsp
  8007cf:	49 89 fd             	mov    %rdi,%r13
  8007d2:	49 89 f7             	mov    %rsi,%r15
  8007d5:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007d8:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007dc:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007e0:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007e4:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007e8:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007ec:	41 0f b6 3e          	movzbl (%r14),%edi
  8007f0:	83 ff 25             	cmp    $0x25,%edi
  8007f3:	74 18                	je     80080d <vprintfmt+0x4f>
      if (ch == '\0')
  8007f5:	85 ff                	test   %edi,%edi
  8007f7:	0f 84 8c 06 00 00    	je     800e89 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8007fd:	4c 89 fe             	mov    %r15,%rsi
  800800:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  800803:	49 89 de             	mov    %rbx,%r14
  800806:	eb e0                	jmp    8007e8 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  800808:	49 89 de             	mov    %rbx,%r14
  80080b:	eb db                	jmp    8007e8 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80080d:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800811:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  800815:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80081c:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800822:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  800826:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80082b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800831:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800837:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80083c:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800841:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800845:	0f b6 13             	movzbl (%rbx),%edx
  800848:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80084b:	3c 55                	cmp    $0x55,%al
  80084d:	0f 87 8b 05 00 00    	ja     800dde <vprintfmt+0x620>
  800853:	0f b6 c0             	movzbl %al,%eax
  800856:	49 bb 40 15 80 00 00 	movabs $0x801540,%r11
  80085d:	00 00 00 
  800860:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800864:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800867:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80086b:	eb d4                	jmp    800841 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80086d:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800870:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800874:	eb cb                	jmp    800841 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800876:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800879:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80087d:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800881:	8d 50 d0             	lea    -0x30(%rax),%edx
  800884:	83 fa 09             	cmp    $0x9,%edx
  800887:	77 7e                	ja     800907 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800889:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80088d:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800891:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800896:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80089a:	8d 50 d0             	lea    -0x30(%rax),%edx
  80089d:	83 fa 09             	cmp    $0x9,%edx
  8008a0:	76 e7                	jbe    800889 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8008a2:	4c 89 f3             	mov    %r14,%rbx
  8008a5:	eb 19                	jmp    8008c0 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8008a7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008aa:	83 f8 2f             	cmp    $0x2f,%eax
  8008ad:	77 2a                	ja     8008d9 <vprintfmt+0x11b>
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	4c 01 d2             	add    %r10,%rdx
  8008b4:	83 c0 08             	add    $0x8,%eax
  8008b7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008ba:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008bd:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008c0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008c4:	0f 89 77 ff ff ff    	jns    800841 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008ca:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008ce:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008d4:	e9 68 ff ff ff       	jmpq   800841 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008d9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008dd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008e1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008e5:	eb d3                	jmp    8008ba <vprintfmt+0xfc>
        if (width < 0)
  8008e7:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008f0:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008f3:	4c 89 f3             	mov    %r14,%rbx
  8008f6:	e9 46 ff ff ff       	jmpq   800841 <vprintfmt+0x83>
  8008fb:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8008fe:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  800902:	e9 3a ff ff ff       	jmpq   800841 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800907:	4c 89 f3             	mov    %r14,%rbx
  80090a:	eb b4                	jmp    8008c0 <vprintfmt+0x102>
        lflag++;
  80090c:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80090f:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800912:	e9 2a ff ff ff       	jmpq   800841 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  800917:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091a:	83 f8 2f             	cmp    $0x2f,%eax
  80091d:	77 19                	ja     800938 <vprintfmt+0x17a>
  80091f:	89 c2                	mov    %eax,%edx
  800921:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800925:	83 c0 08             	add    $0x8,%eax
  800928:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092b:	4c 89 fe             	mov    %r15,%rsi
  80092e:	8b 3a                	mov    (%rdx),%edi
  800930:	41 ff d5             	callq  *%r13
        break;
  800933:	e9 b0 fe ff ff       	jmpq   8007e8 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800938:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80093c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800940:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800944:	eb e5                	jmp    80092b <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800946:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800949:	83 f8 2f             	cmp    $0x2f,%eax
  80094c:	77 5b                	ja     8009a9 <vprintfmt+0x1eb>
  80094e:	89 c2                	mov    %eax,%edx
  800950:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800954:	83 c0 08             	add    $0x8,%eax
  800957:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80095a:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80095c:	89 c8                	mov    %ecx,%eax
  80095e:	c1 f8 1f             	sar    $0x1f,%eax
  800961:	31 c1                	xor    %eax,%ecx
  800963:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800965:	83 f9 0b             	cmp    $0xb,%ecx
  800968:	7f 4d                	jg     8009b7 <vprintfmt+0x1f9>
  80096a:	48 63 c1             	movslq %ecx,%rax
  80096d:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  800974:	00 00 00 
  800977:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80097b:	48 85 c0             	test   %rax,%rax
  80097e:	74 37                	je     8009b7 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800980:	48 89 c1             	mov    %rax,%rcx
  800983:	48 ba 8b 14 80 00 00 	movabs $0x80148b,%rdx
  80098a:	00 00 00 
  80098d:	4c 89 fe             	mov    %r15,%rsi
  800990:	4c 89 ef             	mov    %r13,%rdi
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
  800998:	48 bb 38 07 80 00 00 	movabs $0x800738,%rbx
  80099f:	00 00 00 
  8009a2:	ff d3                	callq  *%rbx
  8009a4:	e9 3f fe ff ff       	jmpq   8007e8 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8009a9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009ad:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009b1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009b5:	eb a3                	jmp    80095a <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009b7:	48 ba 82 14 80 00 00 	movabs $0x801482,%rdx
  8009be:	00 00 00 
  8009c1:	4c 89 fe             	mov    %r15,%rsi
  8009c4:	4c 89 ef             	mov    %r13,%rdi
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	48 bb 38 07 80 00 00 	movabs $0x800738,%rbx
  8009d3:	00 00 00 
  8009d6:	ff d3                	callq  *%rbx
  8009d8:	e9 0b fe ff ff       	jmpq   8007e8 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009dd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009e0:	83 f8 2f             	cmp    $0x2f,%eax
  8009e3:	77 4b                	ja     800a30 <vprintfmt+0x272>
  8009e5:	89 c2                	mov    %eax,%edx
  8009e7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009eb:	83 c0 08             	add    $0x8,%eax
  8009ee:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009f1:	48 8b 02             	mov    (%rdx),%rax
  8009f4:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009f8:	48 85 c0             	test   %rax,%rax
  8009fb:	0f 84 05 04 00 00    	je     800e06 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  800a01:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800a05:	7e 06                	jle    800a0d <vprintfmt+0x24f>
  800a07:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a0b:	75 31                	jne    800a3e <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a11:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a15:	0f b6 00             	movzbl (%rax),%eax
  800a18:	0f be f8             	movsbl %al,%edi
  800a1b:	85 ff                	test   %edi,%edi
  800a1d:	0f 84 c3 00 00 00    	je     800ae6 <vprintfmt+0x328>
  800a23:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a27:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a2b:	e9 85 00 00 00       	jmpq   800ab5 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a30:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a34:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a38:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a3c:	eb b3                	jmp    8009f1 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a3e:	49 63 f4             	movslq %r12d,%rsi
  800a41:	48 89 c7             	mov    %rax,%rdi
  800a44:	48 b8 95 0f 80 00 00 	movabs $0x800f95,%rax
  800a4b:	00 00 00 
  800a4e:	ff d0                	callq  *%rax
  800a50:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a53:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a56:	85 f6                	test   %esi,%esi
  800a58:	7e 22                	jle    800a7c <vprintfmt+0x2be>
            putch(padc, putdat);
  800a5a:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a5e:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a62:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a66:	4c 89 fe             	mov    %r15,%rsi
  800a69:	89 df                	mov    %ebx,%edi
  800a6b:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a6e:	41 83 ec 01          	sub    $0x1,%r12d
  800a72:	75 f2                	jne    800a66 <vprintfmt+0x2a8>
  800a74:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a78:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a80:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a84:	0f b6 00             	movzbl (%rax),%eax
  800a87:	0f be f8             	movsbl %al,%edi
  800a8a:	85 ff                	test   %edi,%edi
  800a8c:	0f 84 56 fd ff ff    	je     8007e8 <vprintfmt+0x2a>
  800a92:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a96:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a9a:	eb 19                	jmp    800ab5 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a9c:	4c 89 fe             	mov    %r15,%rsi
  800a9f:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800aa2:	41 83 ee 01          	sub    $0x1,%r14d
  800aa6:	48 83 c3 01          	add    $0x1,%rbx
  800aaa:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800aae:	0f be f8             	movsbl %al,%edi
  800ab1:	85 ff                	test   %edi,%edi
  800ab3:	74 29                	je     800ade <vprintfmt+0x320>
  800ab5:	45 85 e4             	test   %r12d,%r12d
  800ab8:	78 06                	js     800ac0 <vprintfmt+0x302>
  800aba:	41 83 ec 01          	sub    $0x1,%r12d
  800abe:	78 48                	js     800b08 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800ac0:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800ac4:	74 d6                	je     800a9c <vprintfmt+0x2de>
  800ac6:	0f be c0             	movsbl %al,%eax
  800ac9:	83 e8 20             	sub    $0x20,%eax
  800acc:	83 f8 5e             	cmp    $0x5e,%eax
  800acf:	76 cb                	jbe    800a9c <vprintfmt+0x2de>
            putch('?', putdat);
  800ad1:	4c 89 fe             	mov    %r15,%rsi
  800ad4:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ad9:	41 ff d5             	callq  *%r13
  800adc:	eb c4                	jmp    800aa2 <vprintfmt+0x2e4>
  800ade:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800ae2:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800ae6:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800ae9:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800aed:	0f 8e f5 fc ff ff    	jle    8007e8 <vprintfmt+0x2a>
          putch(' ', putdat);
  800af3:	4c 89 fe             	mov    %r15,%rsi
  800af6:	bf 20 00 00 00       	mov    $0x20,%edi
  800afb:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800afe:	83 eb 01             	sub    $0x1,%ebx
  800b01:	75 f0                	jne    800af3 <vprintfmt+0x335>
  800b03:	e9 e0 fc ff ff       	jmpq   8007e8 <vprintfmt+0x2a>
  800b08:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b0c:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b10:	eb d4                	jmp    800ae6 <vprintfmt+0x328>
  if (lflag >= 2)
  800b12:	83 f9 01             	cmp    $0x1,%ecx
  800b15:	7f 1d                	jg     800b34 <vprintfmt+0x376>
  else if (lflag)
  800b17:	85 c9                	test   %ecx,%ecx
  800b19:	74 5e                	je     800b79 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b1b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b1e:	83 f8 2f             	cmp    $0x2f,%eax
  800b21:	77 48                	ja     800b6b <vprintfmt+0x3ad>
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b29:	83 c0 08             	add    $0x8,%eax
  800b2c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b2f:	48 8b 1a             	mov    (%rdx),%rbx
  800b32:	eb 17                	jmp    800b4b <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b34:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b37:	83 f8 2f             	cmp    $0x2f,%eax
  800b3a:	77 21                	ja     800b5d <vprintfmt+0x39f>
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b42:	83 c0 08             	add    $0x8,%eax
  800b45:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b48:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b4b:	48 85 db             	test   %rbx,%rbx
  800b4e:	78 50                	js     800ba0 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b50:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b53:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b58:	e9 b4 01 00 00       	jmpq   800d11 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b5d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b61:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b65:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b69:	eb dd                	jmp    800b48 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b6b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b6f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b73:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b77:	eb b6                	jmp    800b2f <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b79:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b7c:	83 f8 2f             	cmp    $0x2f,%eax
  800b7f:	77 11                	ja     800b92 <vprintfmt+0x3d4>
  800b81:	89 c2                	mov    %eax,%edx
  800b83:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b87:	83 c0 08             	add    $0x8,%eax
  800b8a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b8d:	48 63 1a             	movslq (%rdx),%rbx
  800b90:	eb b9                	jmp    800b4b <vprintfmt+0x38d>
  800b92:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b96:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b9a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b9e:	eb ed                	jmp    800b8d <vprintfmt+0x3cf>
          putch('-', putdat);
  800ba0:	4c 89 fe             	mov    %r15,%rsi
  800ba3:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800ba8:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800bab:	48 89 da             	mov    %rbx,%rdx
  800bae:	48 f7 da             	neg    %rdx
        base = 10;
  800bb1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bb6:	e9 56 01 00 00       	jmpq   800d11 <vprintfmt+0x553>
  if (lflag >= 2)
  800bbb:	83 f9 01             	cmp    $0x1,%ecx
  800bbe:	7f 25                	jg     800be5 <vprintfmt+0x427>
  else if (lflag)
  800bc0:	85 c9                	test   %ecx,%ecx
  800bc2:	74 5e                	je     800c22 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bc4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bc7:	83 f8 2f             	cmp    $0x2f,%eax
  800bca:	77 48                	ja     800c14 <vprintfmt+0x456>
  800bcc:	89 c2                	mov    %eax,%edx
  800bce:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bd2:	83 c0 08             	add    $0x8,%eax
  800bd5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bd8:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bdb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800be0:	e9 2c 01 00 00       	jmpq   800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800be5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800be8:	83 f8 2f             	cmp    $0x2f,%eax
  800beb:	77 19                	ja     800c06 <vprintfmt+0x448>
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bf3:	83 c0 08             	add    $0x8,%eax
  800bf6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bf9:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bfc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c01:	e9 0b 01 00 00       	jmpq   800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c06:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c0a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c0e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c12:	eb e5                	jmp    800bf9 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c14:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c18:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c1c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c20:	eb b6                	jmp    800bd8 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c22:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c25:	83 f8 2f             	cmp    $0x2f,%eax
  800c28:	77 18                	ja     800c42 <vprintfmt+0x484>
  800c2a:	89 c2                	mov    %eax,%edx
  800c2c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c30:	83 c0 08             	add    $0x8,%eax
  800c33:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c36:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c38:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c3d:	e9 cf 00 00 00       	jmpq   800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c42:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c46:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c4a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c4e:	eb e6                	jmp    800c36 <vprintfmt+0x478>
  if (lflag >= 2)
  800c50:	83 f9 01             	cmp    $0x1,%ecx
  800c53:	7f 25                	jg     800c7a <vprintfmt+0x4bc>
  else if (lflag)
  800c55:	85 c9                	test   %ecx,%ecx
  800c57:	74 5b                	je     800cb4 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c59:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c5c:	83 f8 2f             	cmp    $0x2f,%eax
  800c5f:	77 45                	ja     800ca6 <vprintfmt+0x4e8>
  800c61:	89 c2                	mov    %eax,%edx
  800c63:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c67:	83 c0 08             	add    $0x8,%eax
  800c6a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c6d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c70:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c75:	e9 97 00 00 00       	jmpq   800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c7a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c7d:	83 f8 2f             	cmp    $0x2f,%eax
  800c80:	77 16                	ja     800c98 <vprintfmt+0x4da>
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c88:	83 c0 08             	add    $0x8,%eax
  800c8b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c8e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c91:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c96:	eb 79                	jmp    800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c98:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c9c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ca0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ca4:	eb e8                	jmp    800c8e <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800ca6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800caa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cb2:	eb b9                	jmp    800c6d <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800cb4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cb7:	83 f8 2f             	cmp    $0x2f,%eax
  800cba:	77 15                	ja     800cd1 <vprintfmt+0x513>
  800cbc:	89 c2                	mov    %eax,%edx
  800cbe:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cc2:	83 c0 08             	add    $0x8,%eax
  800cc5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cc8:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cca:	b9 08 00 00 00       	mov    $0x8,%ecx
  800ccf:	eb 40                	jmp    800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cd1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cd5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cd9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cdd:	eb e9                	jmp    800cc8 <vprintfmt+0x50a>
        putch('0', putdat);
  800cdf:	4c 89 fe             	mov    %r15,%rsi
  800ce2:	bf 30 00 00 00       	mov    $0x30,%edi
  800ce7:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cea:	4c 89 fe             	mov    %r15,%rsi
  800ced:	bf 78 00 00 00       	mov    $0x78,%edi
  800cf2:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cf5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cf8:	83 f8 2f             	cmp    $0x2f,%eax
  800cfb:	77 34                	ja     800d31 <vprintfmt+0x573>
  800cfd:	89 c2                	mov    %eax,%edx
  800cff:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d03:	83 c0 08             	add    $0x8,%eax
  800d06:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d09:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d0c:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d11:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d16:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d1a:	4c 89 fe             	mov    %r15,%rsi
  800d1d:	4c 89 ef             	mov    %r13,%rdi
  800d20:	48 b8 94 06 80 00 00 	movabs $0x800694,%rax
  800d27:	00 00 00 
  800d2a:	ff d0                	callq  *%rax
        break;
  800d2c:	e9 b7 fa ff ff       	jmpq   8007e8 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d31:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d35:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d39:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d3d:	eb ca                	jmp    800d09 <vprintfmt+0x54b>
  if (lflag >= 2)
  800d3f:	83 f9 01             	cmp    $0x1,%ecx
  800d42:	7f 22                	jg     800d66 <vprintfmt+0x5a8>
  else if (lflag)
  800d44:	85 c9                	test   %ecx,%ecx
  800d46:	74 58                	je     800da0 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d48:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d4b:	83 f8 2f             	cmp    $0x2f,%eax
  800d4e:	77 42                	ja     800d92 <vprintfmt+0x5d4>
  800d50:	89 c2                	mov    %eax,%edx
  800d52:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d56:	83 c0 08             	add    $0x8,%eax
  800d59:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d5c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d5f:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d64:	eb ab                	jmp    800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d66:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d69:	83 f8 2f             	cmp    $0x2f,%eax
  800d6c:	77 16                	ja     800d84 <vprintfmt+0x5c6>
  800d6e:	89 c2                	mov    %eax,%edx
  800d70:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d74:	83 c0 08             	add    $0x8,%eax
  800d77:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d7a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d7d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d82:	eb 8d                	jmp    800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d84:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d88:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d8c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d90:	eb e8                	jmp    800d7a <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d92:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d96:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d9a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d9e:	eb bc                	jmp    800d5c <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800da0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800da3:	83 f8 2f             	cmp    $0x2f,%eax
  800da6:	77 18                	ja     800dc0 <vprintfmt+0x602>
  800da8:	89 c2                	mov    %eax,%edx
  800daa:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800dae:	83 c0 08             	add    $0x8,%eax
  800db1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800db4:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800db6:	b9 10 00 00 00       	mov    $0x10,%ecx
  800dbb:	e9 51 ff ff ff       	jmpq   800d11 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800dc0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800dc4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800dc8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dcc:	eb e6                	jmp    800db4 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800dce:	4c 89 fe             	mov    %r15,%rsi
  800dd1:	bf 25 00 00 00       	mov    $0x25,%edi
  800dd6:	41 ff d5             	callq  *%r13
        break;
  800dd9:	e9 0a fa ff ff       	jmpq   8007e8 <vprintfmt+0x2a>
        putch('%', putdat);
  800dde:	4c 89 fe             	mov    %r15,%rsi
  800de1:	bf 25 00 00 00       	mov    $0x25,%edi
  800de6:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800de9:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800ded:	0f 84 15 fa ff ff    	je     800808 <vprintfmt+0x4a>
  800df3:	49 89 de             	mov    %rbx,%r14
  800df6:	49 83 ee 01          	sub    $0x1,%r14
  800dfa:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800dff:	75 f5                	jne    800df6 <vprintfmt+0x638>
  800e01:	e9 e2 f9 ff ff       	jmpq   8007e8 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800e06:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800e0a:	74 06                	je     800e12 <vprintfmt+0x654>
  800e0c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e10:	7f 21                	jg     800e33 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e12:	bf 28 00 00 00       	mov    $0x28,%edi
  800e17:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e1e:	00 00 00 
  800e21:	b8 28 00 00 00       	mov    $0x28,%eax
  800e26:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e2a:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e2e:	e9 82 fc ff ff       	jmpq   800ab5 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e33:	49 63 f4             	movslq %r12d,%rsi
  800e36:	48 bf 7b 14 80 00 00 	movabs $0x80147b,%rdi
  800e3d:	00 00 00 
  800e40:	48 b8 95 0f 80 00 00 	movabs $0x800f95,%rax
  800e47:	00 00 00 
  800e4a:	ff d0                	callq  *%rax
  800e4c:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e4f:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e52:	48 be 7b 14 80 00 00 	movabs $0x80147b,%rsi
  800e59:	00 00 00 
  800e5c:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	0f 8f f2 fb ff ff    	jg     800a5a <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e68:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e6f:	00 00 00 
  800e72:	b8 28 00 00 00       	mov    $0x28,%eax
  800e77:	bf 28 00 00 00       	mov    $0x28,%edi
  800e7c:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e80:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e84:	e9 2c fc ff ff       	jmpq   800ab5 <vprintfmt+0x2f7>
}
  800e89:	48 83 c4 48          	add    $0x48,%rsp
  800e8d:	5b                   	pop    %rbx
  800e8e:	41 5c                	pop    %r12
  800e90:	41 5d                	pop    %r13
  800e92:	41 5e                	pop    %r14
  800e94:	41 5f                	pop    %r15
  800e96:	5d                   	pop    %rbp
  800e97:	c3                   	retq   

0000000000800e98 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e98:	55                   	push   %rbp
  800e99:	48 89 e5             	mov    %rsp,%rbp
  800e9c:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800ea0:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800ea4:	48 63 c6             	movslq %esi,%rax
  800ea7:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800eac:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800eb0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800eb7:	48 85 ff             	test   %rdi,%rdi
  800eba:	74 2a                	je     800ee6 <vsnprintf+0x4e>
  800ebc:	85 f6                	test   %esi,%esi
  800ebe:	7e 26                	jle    800ee6 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ec0:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800ec4:	48 bf 20 07 80 00 00 	movabs $0x800720,%rdi
  800ecb:	00 00 00 
  800ece:	48 b8 be 07 80 00 00 	movabs $0x8007be,%rax
  800ed5:	00 00 00 
  800ed8:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800eda:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ede:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ee1:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ee4:	c9                   	leaveq 
  800ee5:	c3                   	retq   
    return -E_INVAL;
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eeb:	eb f7                	jmp    800ee4 <vsnprintf+0x4c>

0000000000800eed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800eed:	55                   	push   %rbp
  800eee:	48 89 e5             	mov    %rsp,%rbp
  800ef1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ef8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800eff:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f06:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f0d:	84 c0                	test   %al,%al
  800f0f:	74 20                	je     800f31 <snprintf+0x44>
  800f11:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f15:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f19:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f1d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f21:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f25:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f29:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f2d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f31:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f38:	00 00 00 
  800f3b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f42:	00 00 00 
  800f45:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f49:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f50:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f57:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f5e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f65:	48 b8 98 0e 80 00 00 	movabs $0x800e98,%rax
  800f6c:	00 00 00 
  800f6f:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f71:	c9                   	leaveq 
  800f72:	c3                   	retq   

0000000000800f73 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f73:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f76:	74 17                	je     800f8f <strlen+0x1c>
  800f78:	48 89 fa             	mov    %rdi,%rdx
  800f7b:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f80:	29 f9                	sub    %edi,%ecx
    n++;
  800f82:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f85:	48 83 c2 01          	add    $0x1,%rdx
  800f89:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f8c:	75 f4                	jne    800f82 <strlen+0xf>
  800f8e:	c3                   	retq   
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f94:	c3                   	retq   

0000000000800f95 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f95:	48 85 f6             	test   %rsi,%rsi
  800f98:	74 24                	je     800fbe <strnlen+0x29>
  800f9a:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f9d:	74 25                	je     800fc4 <strnlen+0x2f>
  800f9f:	48 01 fe             	add    %rdi,%rsi
  800fa2:	48 89 fa             	mov    %rdi,%rdx
  800fa5:	b9 01 00 00 00       	mov    $0x1,%ecx
  800faa:	29 f9                	sub    %edi,%ecx
    n++;
  800fac:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800faf:	48 83 c2 01          	add    $0x1,%rdx
  800fb3:	48 39 f2             	cmp    %rsi,%rdx
  800fb6:	74 11                	je     800fc9 <strnlen+0x34>
  800fb8:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fbb:	75 ef                	jne    800fac <strnlen+0x17>
  800fbd:	c3                   	retq   
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	c3                   	retq   
  800fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fc9:	c3                   	retq   

0000000000800fca <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fca:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd2:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fd6:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fd9:	48 83 c2 01          	add    $0x1,%rdx
  800fdd:	84 c9                	test   %cl,%cl
  800fdf:	75 f1                	jne    800fd2 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fe1:	c3                   	retq   

0000000000800fe2 <strcat>:

char *
strcat(char *dst, const char *src) {
  800fe2:	55                   	push   %rbp
  800fe3:	48 89 e5             	mov    %rsp,%rbp
  800fe6:	41 54                	push   %r12
  800fe8:	53                   	push   %rbx
  800fe9:	48 89 fb             	mov    %rdi,%rbx
  800fec:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800fef:	48 b8 73 0f 80 00 00 	movabs $0x800f73,%rax
  800ff6:	00 00 00 
  800ff9:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800ffb:	48 63 f8             	movslq %eax,%rdi
  800ffe:	48 01 df             	add    %rbx,%rdi
  801001:	4c 89 e6             	mov    %r12,%rsi
  801004:	48 b8 ca 0f 80 00 00 	movabs $0x800fca,%rax
  80100b:	00 00 00 
  80100e:	ff d0                	callq  *%rax
  return dst;
}
  801010:	48 89 d8             	mov    %rbx,%rax
  801013:	5b                   	pop    %rbx
  801014:	41 5c                	pop    %r12
  801016:	5d                   	pop    %rbp
  801017:	c3                   	retq   

0000000000801018 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801018:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  80101b:	48 85 d2             	test   %rdx,%rdx
  80101e:	74 1f                	je     80103f <strncpy+0x27>
  801020:	48 01 fa             	add    %rdi,%rdx
  801023:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  801026:	48 83 c1 01          	add    $0x1,%rcx
  80102a:	44 0f b6 06          	movzbl (%rsi),%r8d
  80102e:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801032:	41 80 f8 01          	cmp    $0x1,%r8b
  801036:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  80103a:	48 39 ca             	cmp    %rcx,%rdx
  80103d:	75 e7                	jne    801026 <strncpy+0xe>
  }
  return ret;
}
  80103f:	c3                   	retq   

0000000000801040 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801040:	48 89 f8             	mov    %rdi,%rax
  801043:	48 85 d2             	test   %rdx,%rdx
  801046:	74 36                	je     80107e <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  801048:	48 83 fa 01          	cmp    $0x1,%rdx
  80104c:	74 2d                	je     80107b <strlcpy+0x3b>
  80104e:	44 0f b6 06          	movzbl (%rsi),%r8d
  801052:	45 84 c0             	test   %r8b,%r8b
  801055:	74 24                	je     80107b <strlcpy+0x3b>
  801057:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  80105b:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801060:	48 83 c0 01          	add    $0x1,%rax
  801064:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  801068:	48 39 d1             	cmp    %rdx,%rcx
  80106b:	74 0e                	je     80107b <strlcpy+0x3b>
  80106d:	48 83 c1 01          	add    $0x1,%rcx
  801071:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  801076:	45 84 c0             	test   %r8b,%r8b
  801079:	75 e5                	jne    801060 <strlcpy+0x20>
    *dst = '\0';
  80107b:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  80107e:	48 29 f8             	sub    %rdi,%rax
}
  801081:	c3                   	retq   

0000000000801082 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801082:	0f b6 07             	movzbl (%rdi),%eax
  801085:	84 c0                	test   %al,%al
  801087:	74 17                	je     8010a0 <strcmp+0x1e>
  801089:	3a 06                	cmp    (%rsi),%al
  80108b:	75 13                	jne    8010a0 <strcmp+0x1e>
    p++, q++;
  80108d:	48 83 c7 01          	add    $0x1,%rdi
  801091:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  801095:	0f b6 07             	movzbl (%rdi),%eax
  801098:	84 c0                	test   %al,%al
  80109a:	74 04                	je     8010a0 <strcmp+0x1e>
  80109c:	3a 06                	cmp    (%rsi),%al
  80109e:	74 ed                	je     80108d <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8010a0:	0f b6 c0             	movzbl %al,%eax
  8010a3:	0f b6 16             	movzbl (%rsi),%edx
  8010a6:	29 d0                	sub    %edx,%eax
}
  8010a8:	c3                   	retq   

00000000008010a9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8010a9:	48 85 d2             	test   %rdx,%rdx
  8010ac:	74 2f                	je     8010dd <strncmp+0x34>
  8010ae:	0f b6 07             	movzbl (%rdi),%eax
  8010b1:	84 c0                	test   %al,%al
  8010b3:	74 1f                	je     8010d4 <strncmp+0x2b>
  8010b5:	3a 06                	cmp    (%rsi),%al
  8010b7:	75 1b                	jne    8010d4 <strncmp+0x2b>
  8010b9:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010bc:	48 83 c7 01          	add    $0x1,%rdi
  8010c0:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010c4:	48 39 d7             	cmp    %rdx,%rdi
  8010c7:	74 1a                	je     8010e3 <strncmp+0x3a>
  8010c9:	0f b6 07             	movzbl (%rdi),%eax
  8010cc:	84 c0                	test   %al,%al
  8010ce:	74 04                	je     8010d4 <strncmp+0x2b>
  8010d0:	3a 06                	cmp    (%rsi),%al
  8010d2:	74 e8                	je     8010bc <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010d4:	0f b6 07             	movzbl (%rdi),%eax
  8010d7:	0f b6 16             	movzbl (%rsi),%edx
  8010da:	29 d0                	sub    %edx,%eax
}
  8010dc:	c3                   	retq   
    return 0;
  8010dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e2:	c3                   	retq   
  8010e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e8:	c3                   	retq   

00000000008010e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010e9:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010eb:	0f b6 07             	movzbl (%rdi),%eax
  8010ee:	84 c0                	test   %al,%al
  8010f0:	74 1e                	je     801110 <strchr+0x27>
    if (*s == c)
  8010f2:	40 38 c6             	cmp    %al,%sil
  8010f5:	74 1f                	je     801116 <strchr+0x2d>
  for (; *s; s++)
  8010f7:	48 83 c7 01          	add    $0x1,%rdi
  8010fb:	0f b6 07             	movzbl (%rdi),%eax
  8010fe:	84 c0                	test   %al,%al
  801100:	74 08                	je     80110a <strchr+0x21>
    if (*s == c)
  801102:	38 d0                	cmp    %dl,%al
  801104:	75 f1                	jne    8010f7 <strchr+0xe>
  for (; *s; s++)
  801106:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  801109:	c3                   	retq   
  return 0;
  80110a:	b8 00 00 00 00       	mov    $0x0,%eax
  80110f:	c3                   	retq   
  801110:	b8 00 00 00 00       	mov    $0x0,%eax
  801115:	c3                   	retq   
    if (*s == c)
  801116:	48 89 f8             	mov    %rdi,%rax
  801119:	c3                   	retq   

000000000080111a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  80111a:	48 89 f8             	mov    %rdi,%rax
  80111d:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  80111f:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801122:	40 38 f2             	cmp    %sil,%dl
  801125:	74 13                	je     80113a <strfind+0x20>
  801127:	84 d2                	test   %dl,%dl
  801129:	74 0f                	je     80113a <strfind+0x20>
  for (; *s; s++)
  80112b:	48 83 c0 01          	add    $0x1,%rax
  80112f:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801132:	38 ca                	cmp    %cl,%dl
  801134:	74 04                	je     80113a <strfind+0x20>
  801136:	84 d2                	test   %dl,%dl
  801138:	75 f1                	jne    80112b <strfind+0x11>
      break;
  return (char *)s;
}
  80113a:	c3                   	retq   

000000000080113b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  80113b:	48 85 d2             	test   %rdx,%rdx
  80113e:	74 3a                	je     80117a <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801140:	48 89 f8             	mov    %rdi,%rax
  801143:	48 09 d0             	or     %rdx,%rax
  801146:	a8 03                	test   $0x3,%al
  801148:	75 28                	jne    801172 <memset+0x37>
    uint32_t k = c & 0xFFU;
  80114a:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  80114e:	89 f0                	mov    %esi,%eax
  801150:	c1 e0 08             	shl    $0x8,%eax
  801153:	89 f1                	mov    %esi,%ecx
  801155:	c1 e1 18             	shl    $0x18,%ecx
  801158:	41 89 f0             	mov    %esi,%r8d
  80115b:	41 c1 e0 10          	shl    $0x10,%r8d
  80115f:	44 09 c1             	or     %r8d,%ecx
  801162:	09 ce                	or     %ecx,%esi
  801164:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  801166:	48 c1 ea 02          	shr    $0x2,%rdx
  80116a:	48 89 d1             	mov    %rdx,%rcx
  80116d:	fc                   	cld    
  80116e:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801170:	eb 08                	jmp    80117a <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801172:	89 f0                	mov    %esi,%eax
  801174:	48 89 d1             	mov    %rdx,%rcx
  801177:	fc                   	cld    
  801178:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  80117a:	48 89 f8             	mov    %rdi,%rax
  80117d:	c3                   	retq   

000000000080117e <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  80117e:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801181:	48 39 fe             	cmp    %rdi,%rsi
  801184:	73 40                	jae    8011c6 <memmove+0x48>
  801186:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  80118a:	48 39 f9             	cmp    %rdi,%rcx
  80118d:	76 37                	jbe    8011c6 <memmove+0x48>
    s += n;
    d += n;
  80118f:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801193:	48 89 fe             	mov    %rdi,%rsi
  801196:	48 09 d6             	or     %rdx,%rsi
  801199:	48 09 ce             	or     %rcx,%rsi
  80119c:	40 f6 c6 03          	test   $0x3,%sil
  8011a0:	75 14                	jne    8011b6 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8011a2:	48 83 ef 04          	sub    $0x4,%rdi
  8011a6:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8011aa:	48 c1 ea 02          	shr    $0x2,%rdx
  8011ae:	48 89 d1             	mov    %rdx,%rcx
  8011b1:	fd                   	std    
  8011b2:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011b4:	eb 0e                	jmp    8011c4 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011b6:	48 83 ef 01          	sub    $0x1,%rdi
  8011ba:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011be:	48 89 d1             	mov    %rdx,%rcx
  8011c1:	fd                   	std    
  8011c2:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011c4:	fc                   	cld    
  8011c5:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011c6:	48 89 c1             	mov    %rax,%rcx
  8011c9:	48 09 d1             	or     %rdx,%rcx
  8011cc:	48 09 f1             	or     %rsi,%rcx
  8011cf:	f6 c1 03             	test   $0x3,%cl
  8011d2:	75 0e                	jne    8011e2 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011d4:	48 c1 ea 02          	shr    $0x2,%rdx
  8011d8:	48 89 d1             	mov    %rdx,%rcx
  8011db:	48 89 c7             	mov    %rax,%rdi
  8011de:	fc                   	cld    
  8011df:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011e1:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011e2:	48 89 c7             	mov    %rax,%rdi
  8011e5:	48 89 d1             	mov    %rdx,%rcx
  8011e8:	fc                   	cld    
  8011e9:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011eb:	c3                   	retq   

00000000008011ec <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011ec:	55                   	push   %rbp
  8011ed:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011f0:	48 b8 7e 11 80 00 00 	movabs $0x80117e,%rax
  8011f7:	00 00 00 
  8011fa:	ff d0                	callq  *%rax
}
  8011fc:	5d                   	pop    %rbp
  8011fd:	c3                   	retq   

00000000008011fe <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8011fe:	55                   	push   %rbp
  8011ff:	48 89 e5             	mov    %rsp,%rbp
  801202:	41 57                	push   %r15
  801204:	41 56                	push   %r14
  801206:	41 55                	push   %r13
  801208:	41 54                	push   %r12
  80120a:	53                   	push   %rbx
  80120b:	48 83 ec 08          	sub    $0x8,%rsp
  80120f:	49 89 fe             	mov    %rdi,%r14
  801212:	49 89 f7             	mov    %rsi,%r15
  801215:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801218:	48 89 f7             	mov    %rsi,%rdi
  80121b:	48 b8 73 0f 80 00 00 	movabs $0x800f73,%rax
  801222:	00 00 00 
  801225:	ff d0                	callq  *%rax
  801227:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  80122a:	4c 89 ee             	mov    %r13,%rsi
  80122d:	4c 89 f7             	mov    %r14,%rdi
  801230:	48 b8 95 0f 80 00 00 	movabs $0x800f95,%rax
  801237:	00 00 00 
  80123a:	ff d0                	callq  *%rax
  80123c:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80123f:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801243:	4d 39 e5             	cmp    %r12,%r13
  801246:	74 26                	je     80126e <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801248:	4c 89 e8             	mov    %r13,%rax
  80124b:	4c 29 e0             	sub    %r12,%rax
  80124e:	48 39 d8             	cmp    %rbx,%rax
  801251:	76 2a                	jbe    80127d <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801253:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801257:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80125b:	4c 89 fe             	mov    %r15,%rsi
  80125e:	48 b8 ec 11 80 00 00 	movabs $0x8011ec,%rax
  801265:	00 00 00 
  801268:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80126a:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  80126e:	48 83 c4 08          	add    $0x8,%rsp
  801272:	5b                   	pop    %rbx
  801273:	41 5c                	pop    %r12
  801275:	41 5d                	pop    %r13
  801277:	41 5e                	pop    %r14
  801279:	41 5f                	pop    %r15
  80127b:	5d                   	pop    %rbp
  80127c:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80127d:	49 83 ed 01          	sub    $0x1,%r13
  801281:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801285:	4c 89 ea             	mov    %r13,%rdx
  801288:	4c 89 fe             	mov    %r15,%rsi
  80128b:	48 b8 ec 11 80 00 00 	movabs $0x8011ec,%rax
  801292:	00 00 00 
  801295:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801297:	4d 01 ee             	add    %r13,%r14
  80129a:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80129f:	eb c9                	jmp    80126a <strlcat+0x6c>

00000000008012a1 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8012a1:	48 85 d2             	test   %rdx,%rdx
  8012a4:	74 3a                	je     8012e0 <memcmp+0x3f>
    if (*s1 != *s2)
  8012a6:	0f b6 0f             	movzbl (%rdi),%ecx
  8012a9:	44 0f b6 06          	movzbl (%rsi),%r8d
  8012ad:	44 38 c1             	cmp    %r8b,%cl
  8012b0:	75 1d                	jne    8012cf <memcmp+0x2e>
  8012b2:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012b7:	48 39 d0             	cmp    %rdx,%rax
  8012ba:	74 1e                	je     8012da <memcmp+0x39>
    if (*s1 != *s2)
  8012bc:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012c0:	48 83 c0 01          	add    $0x1,%rax
  8012c4:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012ca:	44 38 c1             	cmp    %r8b,%cl
  8012cd:	74 e8                	je     8012b7 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012cf:	0f b6 c1             	movzbl %cl,%eax
  8012d2:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012d6:	44 29 c0             	sub    %r8d,%eax
  8012d9:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
  8012df:	c3                   	retq   
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e5:	c3                   	retq   

00000000008012e6 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012e6:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012ea:	48 39 c7             	cmp    %rax,%rdi
  8012ed:	73 19                	jae    801308 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012ef:	89 f2                	mov    %esi,%edx
  8012f1:	40 38 37             	cmp    %sil,(%rdi)
  8012f4:	74 16                	je     80130c <memfind+0x26>
  for (; s < ends; s++)
  8012f6:	48 83 c7 01          	add    $0x1,%rdi
  8012fa:	48 39 f8             	cmp    %rdi,%rax
  8012fd:	74 08                	je     801307 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012ff:	38 17                	cmp    %dl,(%rdi)
  801301:	75 f3                	jne    8012f6 <memfind+0x10>
  for (; s < ends; s++)
  801303:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801306:	c3                   	retq   
  801307:	c3                   	retq   
  for (; s < ends; s++)
  801308:	48 89 f8             	mov    %rdi,%rax
  80130b:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80130c:	48 89 f8             	mov    %rdi,%rax
  80130f:	c3                   	retq   

0000000000801310 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801310:	0f b6 07             	movzbl (%rdi),%eax
  801313:	3c 20                	cmp    $0x20,%al
  801315:	74 04                	je     80131b <strtol+0xb>
  801317:	3c 09                	cmp    $0x9,%al
  801319:	75 0f                	jne    80132a <strtol+0x1a>
    s++;
  80131b:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80131f:	0f b6 07             	movzbl (%rdi),%eax
  801322:	3c 20                	cmp    $0x20,%al
  801324:	74 f5                	je     80131b <strtol+0xb>
  801326:	3c 09                	cmp    $0x9,%al
  801328:	74 f1                	je     80131b <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80132a:	3c 2b                	cmp    $0x2b,%al
  80132c:	74 2b                	je     801359 <strtol+0x49>
  int neg  = 0;
  80132e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801334:	3c 2d                	cmp    $0x2d,%al
  801336:	74 2d                	je     801365 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801338:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80133e:	75 0f                	jne    80134f <strtol+0x3f>
  801340:	80 3f 30             	cmpb   $0x30,(%rdi)
  801343:	74 2c                	je     801371 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801345:	85 d2                	test   %edx,%edx
  801347:	b8 0a 00 00 00       	mov    $0xa,%eax
  80134c:	0f 44 d0             	cmove  %eax,%edx
  80134f:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801354:	4c 63 d2             	movslq %edx,%r10
  801357:	eb 5c                	jmp    8013b5 <strtol+0xa5>
    s++;
  801359:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80135d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801363:	eb d3                	jmp    801338 <strtol+0x28>
    s++, neg = 1;
  801365:	48 83 c7 01          	add    $0x1,%rdi
  801369:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80136f:	eb c7                	jmp    801338 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801371:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801375:	74 0f                	je     801386 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801377:	85 d2                	test   %edx,%edx
  801379:	75 d4                	jne    80134f <strtol+0x3f>
    s++, base = 8;
  80137b:	48 83 c7 01          	add    $0x1,%rdi
  80137f:	ba 08 00 00 00       	mov    $0x8,%edx
  801384:	eb c9                	jmp    80134f <strtol+0x3f>
    s += 2, base = 16;
  801386:	48 83 c7 02          	add    $0x2,%rdi
  80138a:	ba 10 00 00 00       	mov    $0x10,%edx
  80138f:	eb be                	jmp    80134f <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801391:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801395:	41 80 f8 19          	cmp    $0x19,%r8b
  801399:	77 2f                	ja     8013ca <strtol+0xba>
      dig = *s - 'a' + 10;
  80139b:	44 0f be c1          	movsbl %cl,%r8d
  80139f:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8013a3:	39 d1                	cmp    %edx,%ecx
  8013a5:	7d 37                	jge    8013de <strtol+0xce>
    s++, val = (val * base) + dig;
  8013a7:	48 83 c7 01          	add    $0x1,%rdi
  8013ab:	49 0f af c2          	imul   %r10,%rax
  8013af:	48 63 c9             	movslq %ecx,%rcx
  8013b2:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013b5:	0f b6 0f             	movzbl (%rdi),%ecx
  8013b8:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013bc:	41 80 f8 09          	cmp    $0x9,%r8b
  8013c0:	77 cf                	ja     801391 <strtol+0x81>
      dig = *s - '0';
  8013c2:	0f be c9             	movsbl %cl,%ecx
  8013c5:	83 e9 30             	sub    $0x30,%ecx
  8013c8:	eb d9                	jmp    8013a3 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013ca:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013ce:	41 80 f8 19          	cmp    $0x19,%r8b
  8013d2:	77 0a                	ja     8013de <strtol+0xce>
      dig = *s - 'A' + 10;
  8013d4:	44 0f be c1          	movsbl %cl,%r8d
  8013d8:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013dc:	eb c5                	jmp    8013a3 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013de:	48 85 f6             	test   %rsi,%rsi
  8013e1:	74 03                	je     8013e6 <strtol+0xd6>
    *endptr = (char *)s;
  8013e3:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013e6:	48 89 c2             	mov    %rax,%rdx
  8013e9:	48 f7 da             	neg    %rdx
  8013ec:	45 85 c9             	test   %r9d,%r9d
  8013ef:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013f3:	c3                   	retq   
