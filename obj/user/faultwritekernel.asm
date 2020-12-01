
obj/user/faultwritekernel:     file format elf64-x86-64


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
  800023:	e8 13 00 00 00       	callq  80003b <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  *(volatile unsigned *)0x8040000000 = 0;
  80002a:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  800031:	00 00 00 
  800034:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
}
  80003a:	c3                   	retq   

000000000080003b <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80003b:	55                   	push   %rbp
  80003c:	48 89 e5             	mov    %rsp,%rbp
  80003f:	41 56                	push   %r14
  800041:	41 55                	push   %r13
  800043:	41 54                	push   %r12
  800045:	53                   	push   %rbx
  800046:	41 89 fd             	mov    %edi,%r13d
  800049:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80004c:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800053:	00 00 00 
  800056:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  80005d:	00 00 00 
  800060:	48 39 c2             	cmp    %rax,%rdx
  800063:	73 23                	jae    800088 <libmain+0x4d>
  800065:	48 89 d3             	mov    %rdx,%rbx
  800068:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80006c:	48 29 d0             	sub    %rdx,%rax
  80006f:	48 c1 e8 03          	shr    $0x3,%rax
  800073:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800078:	b8 00 00 00 00       	mov    $0x0,%eax
  80007d:	ff 13                	callq  *(%rbx)
    ctor++;
  80007f:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800083:	4c 39 e3             	cmp    %r12,%rbx
  800086:	75 f0                	jne    800078 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800088:	48 b8 a6 01 80 00 00 	movabs $0x8001a6,%rax
  80008f:	00 00 00 
  800092:	ff d0                	callq  *%rax
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  80009d:	48 c1 e0 05          	shl    $0x5,%rax
  8000a1:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000a8:	00 00 00 
  8000ab:	48 01 d0             	add    %rdx,%rax
  8000ae:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000b5:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000b8:	45 85 ed             	test   %r13d,%r13d
  8000bb:	7e 0d                	jle    8000ca <libmain+0x8f>
    binaryname = argv[0];
  8000bd:	49 8b 06             	mov    (%r14),%rax
  8000c0:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000c7:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000ca:	4c 89 f6             	mov    %r14,%rsi
  8000cd:	44 89 ef             	mov    %r13d,%edi
  8000d0:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000d7:	00 00 00 
  8000da:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000dc:	48 b8 f1 00 80 00 00 	movabs $0x8000f1,%rax
  8000e3:	00 00 00 
  8000e6:	ff d0                	callq  *%rax
#endif
}
  8000e8:	5b                   	pop    %rbx
  8000e9:	41 5c                	pop    %r12
  8000eb:	41 5d                	pop    %r13
  8000ed:	41 5e                	pop    %r14
  8000ef:	5d                   	pop    %rbp
  8000f0:	c3                   	retq   

00000000008000f1 <exit>:

#include <inc/lib.h>

void
exit(void) {
  8000f1:	55                   	push   %rbp
  8000f2:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  8000f5:	bf 00 00 00 00       	mov    $0x0,%edi
  8000fa:	48 b8 46 01 80 00 00 	movabs $0x800146,%rax
  800101:	00 00 00 
  800104:	ff d0                	callq  *%rax
}
  800106:	5d                   	pop    %rbp
  800107:	c3                   	retq   

0000000000800108 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800108:	55                   	push   %rbp
  800109:	48 89 e5             	mov    %rsp,%rbp
  80010c:	53                   	push   %rbx
  80010d:	48 89 fa             	mov    %rdi,%rdx
  800110:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800113:	b8 00 00 00 00       	mov    $0x0,%eax
  800118:	48 89 c3             	mov    %rax,%rbx
  80011b:	48 89 c7             	mov    %rax,%rdi
  80011e:	48 89 c6             	mov    %rax,%rsi
  800121:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800123:	5b                   	pop    %rbx
  800124:	5d                   	pop    %rbp
  800125:	c3                   	retq   

0000000000800126 <sys_cgetc>:

int
sys_cgetc(void) {
  800126:	55                   	push   %rbp
  800127:	48 89 e5             	mov    %rsp,%rbp
  80012a:	53                   	push   %rbx
  asm volatile("int %1\n"
  80012b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800130:	b8 01 00 00 00       	mov    $0x1,%eax
  800135:	48 89 ca             	mov    %rcx,%rdx
  800138:	48 89 cb             	mov    %rcx,%rbx
  80013b:	48 89 cf             	mov    %rcx,%rdi
  80013e:	48 89 ce             	mov    %rcx,%rsi
  800141:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800143:	5b                   	pop    %rbx
  800144:	5d                   	pop    %rbp
  800145:	c3                   	retq   

0000000000800146 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  800146:	55                   	push   %rbp
  800147:	48 89 e5             	mov    %rsp,%rbp
  80014a:	53                   	push   %rbx
  80014b:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014f:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  800152:	be 00 00 00 00       	mov    $0x0,%esi
  800157:	b8 03 00 00 00       	mov    $0x3,%eax
  80015c:	48 89 f1             	mov    %rsi,%rcx
  80015f:	48 89 f3             	mov    %rsi,%rbx
  800162:	48 89 f7             	mov    %rsi,%rdi
  800165:	cd 30                	int    $0x30
  if (check && ret > 0)
  800167:	48 85 c0             	test   %rax,%rax
  80016a:	7f 07                	jg     800173 <sys_env_destroy+0x2d>
}
  80016c:	48 83 c4 08          	add    $0x8,%rsp
  800170:	5b                   	pop    %rbx
  800171:	5d                   	pop    %rbp
  800172:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800173:	49 89 c0             	mov    %rax,%r8
  800176:	b9 03 00 00 00       	mov    $0x3,%ecx
  80017b:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800182:	00 00 00 
  800185:	be 22 00 00 00       	mov    $0x22,%esi
  80018a:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800191:	00 00 00 
  800194:	b8 00 00 00 00       	mov    $0x0,%eax
  800199:	49 b9 53 04 80 00 00 	movabs $0x800453,%r9
  8001a0:	00 00 00 
  8001a3:	41 ff d1             	callq  *%r9

00000000008001a6 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  8001a6:	55                   	push   %rbp
  8001a7:	48 89 e5             	mov    %rsp,%rbp
  8001aa:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b5:	48 89 ca             	mov    %rcx,%rdx
  8001b8:	48 89 cb             	mov    %rcx,%rbx
  8001bb:	48 89 cf             	mov    %rcx,%rdi
  8001be:	48 89 ce             	mov    %rcx,%rsi
  8001c1:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001c3:	5b                   	pop    %rbx
  8001c4:	5d                   	pop    %rbp
  8001c5:	c3                   	retq   

00000000008001c6 <sys_yield>:

void
sys_yield(void) {
  8001c6:	55                   	push   %rbp
  8001c7:	48 89 e5             	mov    %rsp,%rbp
  8001ca:	53                   	push   %rbx
  asm volatile("int %1\n"
  8001cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001d5:	48 89 ca             	mov    %rcx,%rdx
  8001d8:	48 89 cb             	mov    %rcx,%rbx
  8001db:	48 89 cf             	mov    %rcx,%rdi
  8001de:	48 89 ce             	mov    %rcx,%rsi
  8001e1:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001e3:	5b                   	pop    %rbx
  8001e4:	5d                   	pop    %rbp
  8001e5:	c3                   	retq   

00000000008001e6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8001e6:	55                   	push   %rbp
  8001e7:	48 89 e5             	mov    %rsp,%rbp
  8001ea:	53                   	push   %rbx
  8001eb:	48 83 ec 08          	sub    $0x8,%rsp
  8001ef:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8001f2:	4c 63 c7             	movslq %edi,%r8
  8001f5:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8001f8:	be 00 00 00 00       	mov    $0x0,%esi
  8001fd:	b8 04 00 00 00       	mov    $0x4,%eax
  800202:	4c 89 c2             	mov    %r8,%rdx
  800205:	48 89 f7             	mov    %rsi,%rdi
  800208:	cd 30                	int    $0x30
  if (check && ret > 0)
  80020a:	48 85 c0             	test   %rax,%rax
  80020d:	7f 07                	jg     800216 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  80020f:	48 83 c4 08          	add    $0x8,%rsp
  800213:	5b                   	pop    %rbx
  800214:	5d                   	pop    %rbp
  800215:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800216:	49 89 c0             	mov    %rax,%r8
  800219:	b9 04 00 00 00       	mov    $0x4,%ecx
  80021e:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  800225:	00 00 00 
  800228:	be 22 00 00 00       	mov    $0x22,%esi
  80022d:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  800234:	00 00 00 
  800237:	b8 00 00 00 00       	mov    $0x0,%eax
  80023c:	49 b9 53 04 80 00 00 	movabs $0x800453,%r9
  800243:	00 00 00 
  800246:	41 ff d1             	callq  *%r9

0000000000800249 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  800249:	55                   	push   %rbp
  80024a:	48 89 e5             	mov    %rsp,%rbp
  80024d:	53                   	push   %rbx
  80024e:	48 83 ec 08          	sub    $0x8,%rsp
  800252:	41 89 f9             	mov    %edi,%r9d
  800255:	49 89 f2             	mov    %rsi,%r10
  800258:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  80025b:	4d 63 c9             	movslq %r9d,%r9
  80025e:	48 63 da             	movslq %edx,%rbx
  800261:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  800264:	b8 05 00 00 00       	mov    $0x5,%eax
  800269:	4c 89 ca             	mov    %r9,%rdx
  80026c:	4c 89 d1             	mov    %r10,%rcx
  80026f:	cd 30                	int    $0x30
  if (check && ret > 0)
  800271:	48 85 c0             	test   %rax,%rax
  800274:	7f 07                	jg     80027d <sys_page_map+0x34>
}
  800276:	48 83 c4 08          	add    $0x8,%rsp
  80027a:	5b                   	pop    %rbx
  80027b:	5d                   	pop    %rbp
  80027c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80027d:	49 89 c0             	mov    %rax,%r8
  800280:	b9 05 00 00 00       	mov    $0x5,%ecx
  800285:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80028c:	00 00 00 
  80028f:	be 22 00 00 00       	mov    $0x22,%esi
  800294:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80029b:	00 00 00 
  80029e:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a3:	49 b9 53 04 80 00 00 	movabs $0x800453,%r9
  8002aa:	00 00 00 
  8002ad:	41 ff d1             	callq  *%r9

00000000008002b0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  8002b0:	55                   	push   %rbp
  8002b1:	48 89 e5             	mov    %rsp,%rbp
  8002b4:	53                   	push   %rbx
  8002b5:	48 83 ec 08          	sub    $0x8,%rsp
  8002b9:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  8002bc:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8002bf:	be 00 00 00 00       	mov    $0x0,%esi
  8002c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8002c9:	48 89 f3             	mov    %rsi,%rbx
  8002cc:	48 89 f7             	mov    %rsi,%rdi
  8002cf:	cd 30                	int    $0x30
  if (check && ret > 0)
  8002d1:	48 85 c0             	test   %rax,%rax
  8002d4:	7f 07                	jg     8002dd <sys_page_unmap+0x2d>
}
  8002d6:	48 83 c4 08          	add    $0x8,%rsp
  8002da:	5b                   	pop    %rbx
  8002db:	5d                   	pop    %rbp
  8002dc:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8002dd:	49 89 c0             	mov    %rax,%r8
  8002e0:	b9 06 00 00 00       	mov    $0x6,%ecx
  8002e5:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8002ec:	00 00 00 
  8002ef:	be 22 00 00 00       	mov    $0x22,%esi
  8002f4:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8002fb:	00 00 00 
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	49 b9 53 04 80 00 00 	movabs $0x800453,%r9
  80030a:	00 00 00 
  80030d:	41 ff d1             	callq  *%r9

0000000000800310 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  800310:	55                   	push   %rbp
  800311:	48 89 e5             	mov    %rsp,%rbp
  800314:	53                   	push   %rbx
  800315:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800319:	48 63 d7             	movslq %edi,%rdx
  80031c:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  80031f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800324:	b8 08 00 00 00       	mov    $0x8,%eax
  800329:	48 89 df             	mov    %rbx,%rdi
  80032c:	48 89 de             	mov    %rbx,%rsi
  80032f:	cd 30                	int    $0x30
  if (check && ret > 0)
  800331:	48 85 c0             	test   %rax,%rax
  800334:	7f 07                	jg     80033d <sys_env_set_status+0x2d>
}
  800336:	48 83 c4 08          	add    $0x8,%rsp
  80033a:	5b                   	pop    %rbx
  80033b:	5d                   	pop    %rbp
  80033c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80033d:	49 89 c0             	mov    %rax,%r8
  800340:	b9 08 00 00 00       	mov    $0x8,%ecx
  800345:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80034c:	00 00 00 
  80034f:	be 22 00 00 00       	mov    $0x22,%esi
  800354:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80035b:	00 00 00 
  80035e:	b8 00 00 00 00       	mov    $0x0,%eax
  800363:	49 b9 53 04 80 00 00 	movabs $0x800453,%r9
  80036a:	00 00 00 
  80036d:	41 ff d1             	callq  *%r9

0000000000800370 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  800370:	55                   	push   %rbp
  800371:	48 89 e5             	mov    %rsp,%rbp
  800374:	53                   	push   %rbx
  800375:	48 83 ec 08          	sub    $0x8,%rsp
  800379:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  80037c:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80037f:	be 00 00 00 00       	mov    $0x0,%esi
  800384:	b8 09 00 00 00       	mov    $0x9,%eax
  800389:	48 89 f3             	mov    %rsi,%rbx
  80038c:	48 89 f7             	mov    %rsi,%rdi
  80038f:	cd 30                	int    $0x30
  if (check && ret > 0)
  800391:	48 85 c0             	test   %rax,%rax
  800394:	7f 07                	jg     80039d <sys_env_set_pgfault_upcall+0x2d>
}
  800396:	48 83 c4 08          	add    $0x8,%rsp
  80039a:	5b                   	pop    %rbx
  80039b:	5d                   	pop    %rbp
  80039c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80039d:	49 89 c0             	mov    %rax,%r8
  8003a0:	b9 09 00 00 00       	mov    $0x9,%ecx
  8003a5:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  8003ac:	00 00 00 
  8003af:	be 22 00 00 00       	mov    $0x22,%esi
  8003b4:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  8003bb:	00 00 00 
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	49 b9 53 04 80 00 00 	movabs $0x800453,%r9
  8003ca:	00 00 00 
  8003cd:	41 ff d1             	callq  *%r9

00000000008003d0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  8003d0:	55                   	push   %rbp
  8003d1:	48 89 e5             	mov    %rsp,%rbp
  8003d4:	53                   	push   %rbx
  8003d5:	49 89 f0             	mov    %rsi,%r8
  8003d8:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  8003db:	48 63 d7             	movslq %edi,%rdx
  8003de:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  8003e1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8003e6:	be 00 00 00 00       	mov    $0x0,%esi
  8003eb:	4c 89 c1             	mov    %r8,%rcx
  8003ee:	cd 30                	int    $0x30
}
  8003f0:	5b                   	pop    %rbx
  8003f1:	5d                   	pop    %rbp
  8003f2:	c3                   	retq   

00000000008003f3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8003f3:	55                   	push   %rbp
  8003f4:	48 89 e5             	mov    %rsp,%rbp
  8003f7:	53                   	push   %rbx
  8003f8:	48 83 ec 08          	sub    $0x8,%rsp
  8003fc:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8003ff:	be 00 00 00 00       	mov    $0x0,%esi
  800404:	b8 0c 00 00 00       	mov    $0xc,%eax
  800409:	48 89 f1             	mov    %rsi,%rcx
  80040c:	48 89 f3             	mov    %rsi,%rbx
  80040f:	48 89 f7             	mov    %rsi,%rdi
  800412:	cd 30                	int    $0x30
  if (check && ret > 0)
  800414:	48 85 c0             	test   %rax,%rax
  800417:	7f 07                	jg     800420 <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  800419:	48 83 c4 08          	add    $0x8,%rsp
  80041d:	5b                   	pop    %rbx
  80041e:	5d                   	pop    %rbp
  80041f:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  800420:	49 89 c0             	mov    %rax,%r8
  800423:	b9 0c 00 00 00       	mov    $0xc,%ecx
  800428:	48 ba 10 14 80 00 00 	movabs $0x801410,%rdx
  80042f:	00 00 00 
  800432:	be 22 00 00 00       	mov    $0x22,%esi
  800437:	48 bf 2f 14 80 00 00 	movabs $0x80142f,%rdi
  80043e:	00 00 00 
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	49 b9 53 04 80 00 00 	movabs $0x800453,%r9
  80044d:	00 00 00 
  800450:	41 ff d1             	callq  *%r9

0000000000800453 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800453:	55                   	push   %rbp
  800454:	48 89 e5             	mov    %rsp,%rbp
  800457:	41 56                	push   %r14
  800459:	41 55                	push   %r13
  80045b:	41 54                	push   %r12
  80045d:	53                   	push   %rbx
  80045e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800465:	49 89 fd             	mov    %rdi,%r13
  800468:	41 89 f6             	mov    %esi,%r14d
  80046b:	49 89 d4             	mov    %rdx,%r12
  80046e:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800475:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  80047c:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800483:	84 c0                	test   %al,%al
  800485:	74 26                	je     8004ad <_panic+0x5a>
  800487:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  80048e:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800495:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800499:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  80049d:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  8004a1:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  8004a5:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  8004a9:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8004ad:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  8004b4:	00 00 00 
  8004b7:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  8004be:	00 00 00 
  8004c1:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004c5:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004cc:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  8004d3:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004da:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  8004e1:	00 00 00 
  8004e4:	48 8b 18             	mov    (%rax),%rbx
  8004e7:	48 b8 a6 01 80 00 00 	movabs $0x8001a6,%rax
  8004ee:	00 00 00 
  8004f1:	ff d0                	callq  *%rax
  8004f3:	45 89 f0             	mov    %r14d,%r8d
  8004f6:	4c 89 e9             	mov    %r13,%rcx
  8004f9:	48 89 da             	mov    %rbx,%rdx
  8004fc:	89 c6                	mov    %eax,%esi
  8004fe:	48 bf 40 14 80 00 00 	movabs $0x801440,%rdi
  800505:	00 00 00 
  800508:	b8 00 00 00 00       	mov    $0x0,%eax
  80050d:	48 bb f5 05 80 00 00 	movabs $0x8005f5,%rbx
  800514:	00 00 00 
  800517:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800519:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800520:	4c 89 e7             	mov    %r12,%rdi
  800523:	48 b8 8d 05 80 00 00 	movabs $0x80058d,%rax
  80052a:	00 00 00 
  80052d:	ff d0                	callq  *%rax
  cprintf("\n");
  80052f:	48 bf 68 14 80 00 00 	movabs $0x801468,%rdi
  800536:	00 00 00 
  800539:	b8 00 00 00 00       	mov    $0x0,%eax
  80053e:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800540:	cc                   	int3   
  while (1)
  800541:	eb fd                	jmp    800540 <_panic+0xed>

0000000000800543 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800543:	55                   	push   %rbp
  800544:	48 89 e5             	mov    %rsp,%rbp
  800547:	53                   	push   %rbx
  800548:	48 83 ec 08          	sub    $0x8,%rsp
  80054c:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  80054f:	8b 06                	mov    (%rsi),%eax
  800551:	8d 50 01             	lea    0x1(%rax),%edx
  800554:	89 16                	mov    %edx,(%rsi)
  800556:	48 98                	cltq   
  800558:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  80055d:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800563:	74 0b                	je     800570 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800565:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800569:	48 83 c4 08          	add    $0x8,%rsp
  80056d:	5b                   	pop    %rbx
  80056e:	5d                   	pop    %rbp
  80056f:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800570:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800574:	be ff 00 00 00       	mov    $0xff,%esi
  800579:	48 b8 08 01 80 00 00 	movabs $0x800108,%rax
  800580:	00 00 00 
  800583:	ff d0                	callq  *%rax
    b->idx = 0;
  800585:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  80058b:	eb d8                	jmp    800565 <putch+0x22>

000000000080058d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80058d:	55                   	push   %rbp
  80058e:	48 89 e5             	mov    %rsp,%rbp
  800591:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800598:	48 89 fa             	mov    %rdi,%rdx
  80059b:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  80059e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  8005a5:	00 00 00 
  b.cnt = 0;
  8005a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  8005af:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  8005b2:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  8005b9:	48 bf 43 05 80 00 00 	movabs $0x800543,%rdi
  8005c0:	00 00 00 
  8005c3:	48 b8 b3 07 80 00 00 	movabs $0x8007b3,%rax
  8005ca:	00 00 00 
  8005cd:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8005cf:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8005d6:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005dd:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005e1:	48 b8 08 01 80 00 00 	movabs $0x800108,%rax
  8005e8:	00 00 00 
  8005eb:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8005f3:	c9                   	leaveq 
  8005f4:	c3                   	retq   

00000000008005f5 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8005f5:	55                   	push   %rbp
  8005f6:	48 89 e5             	mov    %rsp,%rbp
  8005f9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800600:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800607:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80060e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800615:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80061c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800623:	84 c0                	test   %al,%al
  800625:	74 20                	je     800647 <cprintf+0x52>
  800627:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80062b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80062f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800633:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800637:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80063b:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80063f:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800643:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800647:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80064e:	00 00 00 
  800651:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800658:	00 00 00 
  80065b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80065f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800666:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80066d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800674:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80067b:	48 b8 8d 05 80 00 00 	movabs $0x80058d,%rax
  800682:	00 00 00 
  800685:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800687:	c9                   	leaveq 
  800688:	c3                   	retq   

0000000000800689 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800689:	55                   	push   %rbp
  80068a:	48 89 e5             	mov    %rsp,%rbp
  80068d:	41 57                	push   %r15
  80068f:	41 56                	push   %r14
  800691:	41 55                	push   %r13
  800693:	41 54                	push   %r12
  800695:	53                   	push   %rbx
  800696:	48 83 ec 18          	sub    $0x18,%rsp
  80069a:	49 89 fc             	mov    %rdi,%r12
  80069d:	49 89 f5             	mov    %rsi,%r13
  8006a0:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8006a4:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8006a7:	41 89 cf             	mov    %ecx,%r15d
  8006aa:	49 39 d7             	cmp    %rdx,%r15
  8006ad:	76 45                	jbe    8006f4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8006af:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8006b3:	85 db                	test   %ebx,%ebx
  8006b5:	7e 0e                	jle    8006c5 <printnum+0x3c>
      putch(padc, putdat);
  8006b7:	4c 89 ee             	mov    %r13,%rsi
  8006ba:	44 89 f7             	mov    %r14d,%edi
  8006bd:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8006c0:	83 eb 01             	sub    $0x1,%ebx
  8006c3:	75 f2                	jne    8006b7 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8006c5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ce:	49 f7 f7             	div    %r15
  8006d1:	48 b8 6a 14 80 00 00 	movabs $0x80146a,%rax
  8006d8:	00 00 00 
  8006db:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006df:	4c 89 ee             	mov    %r13,%rsi
  8006e2:	41 ff d4             	callq  *%r12
}
  8006e5:	48 83 c4 18          	add    $0x18,%rsp
  8006e9:	5b                   	pop    %rbx
  8006ea:	41 5c                	pop    %r12
  8006ec:	41 5d                	pop    %r13
  8006ee:	41 5e                	pop    %r14
  8006f0:	41 5f                	pop    %r15
  8006f2:	5d                   	pop    %rbp
  8006f3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fd:	49 f7 f7             	div    %r15
  800700:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  800704:	48 89 c2             	mov    %rax,%rdx
  800707:	48 b8 89 06 80 00 00 	movabs $0x800689,%rax
  80070e:	00 00 00 
  800711:	ff d0                	callq  *%rax
  800713:	eb b0                	jmp    8006c5 <printnum+0x3c>

0000000000800715 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  800715:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  800719:	48 8b 06             	mov    (%rsi),%rax
  80071c:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  800720:	73 0a                	jae    80072c <sprintputch+0x17>
    *b->buf++ = ch;
  800722:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800726:	48 89 16             	mov    %rdx,(%rsi)
  800729:	40 88 38             	mov    %dil,(%rax)
}
  80072c:	c3                   	retq   

000000000080072d <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80072d:	55                   	push   %rbp
  80072e:	48 89 e5             	mov    %rsp,%rbp
  800731:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800738:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80073f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800746:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80074d:	84 c0                	test   %al,%al
  80074f:	74 20                	je     800771 <printfmt+0x44>
  800751:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800755:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800759:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80075d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800761:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800765:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800769:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80076d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  800771:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800778:	00 00 00 
  80077b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800782:	00 00 00 
  800785:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800789:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800790:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800797:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80079e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8007a5:	48 b8 b3 07 80 00 00 	movabs $0x8007b3,%rax
  8007ac:	00 00 00 
  8007af:	ff d0                	callq  *%rax
}
  8007b1:	c9                   	leaveq 
  8007b2:	c3                   	retq   

00000000008007b3 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8007b3:	55                   	push   %rbp
  8007b4:	48 89 e5             	mov    %rsp,%rbp
  8007b7:	41 57                	push   %r15
  8007b9:	41 56                	push   %r14
  8007bb:	41 55                	push   %r13
  8007bd:	41 54                	push   %r12
  8007bf:	53                   	push   %rbx
  8007c0:	48 83 ec 48          	sub    $0x48,%rsp
  8007c4:	49 89 fd             	mov    %rdi,%r13
  8007c7:	49 89 f7             	mov    %rsi,%r15
  8007ca:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8007cd:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8007d1:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8007d5:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007d9:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007dd:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007e1:	41 0f b6 3e          	movzbl (%r14),%edi
  8007e5:	83 ff 25             	cmp    $0x25,%edi
  8007e8:	74 18                	je     800802 <vprintfmt+0x4f>
      if (ch == '\0')
  8007ea:	85 ff                	test   %edi,%edi
  8007ec:	0f 84 8c 06 00 00    	je     800e7e <vprintfmt+0x6cb>
      putch(ch, putdat);
  8007f2:	4c 89 fe             	mov    %r15,%rsi
  8007f5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007f8:	49 89 de             	mov    %rbx,%r14
  8007fb:	eb e0                	jmp    8007dd <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8007fd:	49 89 de             	mov    %rbx,%r14
  800800:	eb db                	jmp    8007dd <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  800802:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  800806:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80080a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  800811:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  800817:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80081b:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  800820:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800826:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80082c:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  800831:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800836:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80083a:	0f b6 13             	movzbl (%rbx),%edx
  80083d:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800840:	3c 55                	cmp    $0x55,%al
  800842:	0f 87 8b 05 00 00    	ja     800dd3 <vprintfmt+0x620>
  800848:	0f b6 c0             	movzbl %al,%eax
  80084b:	49 bb 40 15 80 00 00 	movabs $0x801540,%r11
  800852:	00 00 00 
  800855:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800859:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80085c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800860:	eb d4                	jmp    800836 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800862:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  800865:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800869:	eb cb                	jmp    800836 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80086b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80086e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  800872:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800876:	8d 50 d0             	lea    -0x30(%rax),%edx
  800879:	83 fa 09             	cmp    $0x9,%edx
  80087c:	77 7e                	ja     8008fc <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80087e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  800882:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800886:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80088b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80088f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800892:	83 fa 09             	cmp    $0x9,%edx
  800895:	76 e7                	jbe    80087e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800897:	4c 89 f3             	mov    %r14,%rbx
  80089a:	eb 19                	jmp    8008b5 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80089c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80089f:	83 f8 2f             	cmp    $0x2f,%eax
  8008a2:	77 2a                	ja     8008ce <vprintfmt+0x11b>
  8008a4:	89 c2                	mov    %eax,%edx
  8008a6:	4c 01 d2             	add    %r10,%rdx
  8008a9:	83 c0 08             	add    $0x8,%eax
  8008ac:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008af:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8008b2:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8008b5:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8008b9:	0f 89 77 ff ff ff    	jns    800836 <vprintfmt+0x83>
          width = precision, precision = -1;
  8008bf:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8008c3:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8008c9:	e9 68 ff ff ff       	jmpq   800836 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8008ce:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008d2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008d6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008da:	eb d3                	jmp    8008af <vprintfmt+0xfc>
        if (width < 0)
  8008dc:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008e5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008e8:	4c 89 f3             	mov    %r14,%rbx
  8008eb:	e9 46 ff ff ff       	jmpq   800836 <vprintfmt+0x83>
  8008f0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8008f3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8008f7:	e9 3a ff ff ff       	jmpq   800836 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008fc:	4c 89 f3             	mov    %r14,%rbx
  8008ff:	eb b4                	jmp    8008b5 <vprintfmt+0x102>
        lflag++;
  800901:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  800904:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  800907:	e9 2a ff ff ff       	jmpq   800836 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80090c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80090f:	83 f8 2f             	cmp    $0x2f,%eax
  800912:	77 19                	ja     80092d <vprintfmt+0x17a>
  800914:	89 c2                	mov    %eax,%edx
  800916:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80091a:	83 c0 08             	add    $0x8,%eax
  80091d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800920:	4c 89 fe             	mov    %r15,%rsi
  800923:	8b 3a                	mov    (%rdx),%edi
  800925:	41 ff d5             	callq  *%r13
        break;
  800928:	e9 b0 fe ff ff       	jmpq   8007dd <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80092d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800931:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800935:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800939:	eb e5                	jmp    800920 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80093b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80093e:	83 f8 2f             	cmp    $0x2f,%eax
  800941:	77 5b                	ja     80099e <vprintfmt+0x1eb>
  800943:	89 c2                	mov    %eax,%edx
  800945:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800949:	83 c0 08             	add    $0x8,%eax
  80094c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80094f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  800951:	89 c8                	mov    %ecx,%eax
  800953:	c1 f8 1f             	sar    $0x1f,%eax
  800956:	31 c1                	xor    %eax,%ecx
  800958:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80095a:	83 f9 0b             	cmp    $0xb,%ecx
  80095d:	7f 4d                	jg     8009ac <vprintfmt+0x1f9>
  80095f:	48 63 c1             	movslq %ecx,%rax
  800962:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  800969:	00 00 00 
  80096c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800970:	48 85 c0             	test   %rax,%rax
  800973:	74 37                	je     8009ac <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  800975:	48 89 c1             	mov    %rax,%rcx
  800978:	48 ba 8b 14 80 00 00 	movabs $0x80148b,%rdx
  80097f:	00 00 00 
  800982:	4c 89 fe             	mov    %r15,%rsi
  800985:	4c 89 ef             	mov    %r13,%rdi
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
  80098d:	48 bb 2d 07 80 00 00 	movabs $0x80072d,%rbx
  800994:	00 00 00 
  800997:	ff d3                	callq  *%rbx
  800999:	e9 3f fe ff ff       	jmpq   8007dd <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80099e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009a2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009a6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009aa:	eb a3                	jmp    80094f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8009ac:	48 ba 82 14 80 00 00 	movabs $0x801482,%rdx
  8009b3:	00 00 00 
  8009b6:	4c 89 fe             	mov    %r15,%rsi
  8009b9:	4c 89 ef             	mov    %r13,%rdi
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	48 bb 2d 07 80 00 00 	movabs $0x80072d,%rbx
  8009c8:	00 00 00 
  8009cb:	ff d3                	callq  *%rbx
  8009cd:	e9 0b fe ff ff       	jmpq   8007dd <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8009d2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8009d5:	83 f8 2f             	cmp    $0x2f,%eax
  8009d8:	77 4b                	ja     800a25 <vprintfmt+0x272>
  8009da:	89 c2                	mov    %eax,%edx
  8009dc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009e0:	83 c0 08             	add    $0x8,%eax
  8009e3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009e6:	48 8b 02             	mov    (%rdx),%rax
  8009e9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009ed:	48 85 c0             	test   %rax,%rax
  8009f0:	0f 84 05 04 00 00    	je     800dfb <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8009f6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009fa:	7e 06                	jle    800a02 <vprintfmt+0x24f>
  8009fc:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800a00:	75 31                	jne    800a33 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a02:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a06:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a0a:	0f b6 00             	movzbl (%rax),%eax
  800a0d:	0f be f8             	movsbl %al,%edi
  800a10:	85 ff                	test   %edi,%edi
  800a12:	0f 84 c3 00 00 00    	je     800adb <vprintfmt+0x328>
  800a18:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a1c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a20:	e9 85 00 00 00       	jmpq   800aaa <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  800a25:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800a29:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800a2d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800a31:	eb b3                	jmp    8009e6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	49 63 f4             	movslq %r12d,%rsi
  800a36:	48 89 c7             	mov    %rax,%rdi
  800a39:	48 b8 8a 0f 80 00 00 	movabs $0x800f8a,%rax
  800a40:	00 00 00 
  800a43:	ff d0                	callq  *%rax
  800a45:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a48:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a4b:	85 f6                	test   %esi,%esi
  800a4d:	7e 22                	jle    800a71 <vprintfmt+0x2be>
            putch(padc, putdat);
  800a4f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a53:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a57:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a5b:	4c 89 fe             	mov    %r15,%rsi
  800a5e:	89 df                	mov    %ebx,%edi
  800a60:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a63:	41 83 ec 01          	sub    $0x1,%r12d
  800a67:	75 f2                	jne    800a5b <vprintfmt+0x2a8>
  800a69:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a6d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a71:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a75:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a79:	0f b6 00             	movzbl (%rax),%eax
  800a7c:	0f be f8             	movsbl %al,%edi
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	0f 84 56 fd ff ff    	je     8007dd <vprintfmt+0x2a>
  800a87:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a8b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a8f:	eb 19                	jmp    800aaa <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a91:	4c 89 fe             	mov    %r15,%rsi
  800a94:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a97:	41 83 ee 01          	sub    $0x1,%r14d
  800a9b:	48 83 c3 01          	add    $0x1,%rbx
  800a9f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800aa3:	0f be f8             	movsbl %al,%edi
  800aa6:	85 ff                	test   %edi,%edi
  800aa8:	74 29                	je     800ad3 <vprintfmt+0x320>
  800aaa:	45 85 e4             	test   %r12d,%r12d
  800aad:	78 06                	js     800ab5 <vprintfmt+0x302>
  800aaf:	41 83 ec 01          	sub    $0x1,%r12d
  800ab3:	78 48                	js     800afd <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800ab5:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800ab9:	74 d6                	je     800a91 <vprintfmt+0x2de>
  800abb:	0f be c0             	movsbl %al,%eax
  800abe:	83 e8 20             	sub    $0x20,%eax
  800ac1:	83 f8 5e             	cmp    $0x5e,%eax
  800ac4:	76 cb                	jbe    800a91 <vprintfmt+0x2de>
            putch('?', putdat);
  800ac6:	4c 89 fe             	mov    %r15,%rsi
  800ac9:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800ace:	41 ff d5             	callq  *%r13
  800ad1:	eb c4                	jmp    800a97 <vprintfmt+0x2e4>
  800ad3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800ad7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800adb:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800ade:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800ae2:	0f 8e f5 fc ff ff    	jle    8007dd <vprintfmt+0x2a>
          putch(' ', putdat);
  800ae8:	4c 89 fe             	mov    %r15,%rsi
  800aeb:	bf 20 00 00 00       	mov    $0x20,%edi
  800af0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800af3:	83 eb 01             	sub    $0x1,%ebx
  800af6:	75 f0                	jne    800ae8 <vprintfmt+0x335>
  800af8:	e9 e0 fc ff ff       	jmpq   8007dd <vprintfmt+0x2a>
  800afd:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800b01:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800b05:	eb d4                	jmp    800adb <vprintfmt+0x328>
  if (lflag >= 2)
  800b07:	83 f9 01             	cmp    $0x1,%ecx
  800b0a:	7f 1d                	jg     800b29 <vprintfmt+0x376>
  else if (lflag)
  800b0c:	85 c9                	test   %ecx,%ecx
  800b0e:	74 5e                	je     800b6e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800b10:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b13:	83 f8 2f             	cmp    $0x2f,%eax
  800b16:	77 48                	ja     800b60 <vprintfmt+0x3ad>
  800b18:	89 c2                	mov    %eax,%edx
  800b1a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b1e:	83 c0 08             	add    $0x8,%eax
  800b21:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b24:	48 8b 1a             	mov    (%rdx),%rbx
  800b27:	eb 17                	jmp    800b40 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800b29:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b2c:	83 f8 2f             	cmp    $0x2f,%eax
  800b2f:	77 21                	ja     800b52 <vprintfmt+0x39f>
  800b31:	89 c2                	mov    %eax,%edx
  800b33:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b37:	83 c0 08             	add    $0x8,%eax
  800b3a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b3d:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b40:	48 85 db             	test   %rbx,%rbx
  800b43:	78 50                	js     800b95 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b45:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b48:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b4d:	e9 b4 01 00 00       	jmpq   800d06 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b52:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b56:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b5a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b5e:	eb dd                	jmp    800b3d <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b60:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b64:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b68:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b6c:	eb b6                	jmp    800b24 <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b6e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b71:	83 f8 2f             	cmp    $0x2f,%eax
  800b74:	77 11                	ja     800b87 <vprintfmt+0x3d4>
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b7c:	83 c0 08             	add    $0x8,%eax
  800b7f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b82:	48 63 1a             	movslq (%rdx),%rbx
  800b85:	eb b9                	jmp    800b40 <vprintfmt+0x38d>
  800b87:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b8b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b8f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b93:	eb ed                	jmp    800b82 <vprintfmt+0x3cf>
          putch('-', putdat);
  800b95:	4c 89 fe             	mov    %r15,%rsi
  800b98:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800b9d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800ba0:	48 89 da             	mov    %rbx,%rdx
  800ba3:	48 f7 da             	neg    %rdx
        base = 10;
  800ba6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bab:	e9 56 01 00 00       	jmpq   800d06 <vprintfmt+0x553>
  if (lflag >= 2)
  800bb0:	83 f9 01             	cmp    $0x1,%ecx
  800bb3:	7f 25                	jg     800bda <vprintfmt+0x427>
  else if (lflag)
  800bb5:	85 c9                	test   %ecx,%ecx
  800bb7:	74 5e                	je     800c17 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800bb9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bbc:	83 f8 2f             	cmp    $0x2f,%eax
  800bbf:	77 48                	ja     800c09 <vprintfmt+0x456>
  800bc1:	89 c2                	mov    %eax,%edx
  800bc3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bc7:	83 c0 08             	add    $0x8,%eax
  800bca:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bcd:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bd0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bd5:	e9 2c 01 00 00       	jmpq   800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bda:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800bdd:	83 f8 2f             	cmp    $0x2f,%eax
  800be0:	77 19                	ja     800bfb <vprintfmt+0x448>
  800be2:	89 c2                	mov    %eax,%edx
  800be4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800be8:	83 c0 08             	add    $0x8,%eax
  800beb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bee:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bf1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bf6:	e9 0b 01 00 00       	jmpq   800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bfb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bff:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c03:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c07:	eb e5                	jmp    800bee <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800c09:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c0d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c11:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c15:	eb b6                	jmp    800bcd <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800c17:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c1a:	83 f8 2f             	cmp    $0x2f,%eax
  800c1d:	77 18                	ja     800c37 <vprintfmt+0x484>
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c25:	83 c0 08             	add    $0x8,%eax
  800c28:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c2b:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800c2d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c32:	e9 cf 00 00 00       	jmpq   800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c37:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c3b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c3f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c43:	eb e6                	jmp    800c2b <vprintfmt+0x478>
  if (lflag >= 2)
  800c45:	83 f9 01             	cmp    $0x1,%ecx
  800c48:	7f 25                	jg     800c6f <vprintfmt+0x4bc>
  else if (lflag)
  800c4a:	85 c9                	test   %ecx,%ecx
  800c4c:	74 5b                	je     800ca9 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c4e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c51:	83 f8 2f             	cmp    $0x2f,%eax
  800c54:	77 45                	ja     800c9b <vprintfmt+0x4e8>
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c5c:	83 c0 08             	add    $0x8,%eax
  800c5f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c62:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c65:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c6a:	e9 97 00 00 00       	jmpq   800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c6f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c72:	83 f8 2f             	cmp    $0x2f,%eax
  800c75:	77 16                	ja     800c8d <vprintfmt+0x4da>
  800c77:	89 c2                	mov    %eax,%edx
  800c79:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c7d:	83 c0 08             	add    $0x8,%eax
  800c80:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c83:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c86:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c8b:	eb 79                	jmp    800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c8d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c91:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c95:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c99:	eb e8                	jmp    800c83 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800c9b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c9f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800ca3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800ca7:	eb b9                	jmp    800c62 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800ca9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cac:	83 f8 2f             	cmp    $0x2f,%eax
  800caf:	77 15                	ja     800cc6 <vprintfmt+0x513>
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cb7:	83 c0 08             	add    $0x8,%eax
  800cba:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cbd:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800cbf:	b9 08 00 00 00       	mov    $0x8,%ecx
  800cc4:	eb 40                	jmp    800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800cc6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cca:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cce:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cd2:	eb e9                	jmp    800cbd <vprintfmt+0x50a>
        putch('0', putdat);
  800cd4:	4c 89 fe             	mov    %r15,%rsi
  800cd7:	bf 30 00 00 00       	mov    $0x30,%edi
  800cdc:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800cdf:	4c 89 fe             	mov    %r15,%rsi
  800ce2:	bf 78 00 00 00       	mov    $0x78,%edi
  800ce7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cea:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ced:	83 f8 2f             	cmp    $0x2f,%eax
  800cf0:	77 34                	ja     800d26 <vprintfmt+0x573>
  800cf2:	89 c2                	mov    %eax,%edx
  800cf4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cf8:	83 c0 08             	add    $0x8,%eax
  800cfb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cfe:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d01:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800d06:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800d0b:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800d0f:	4c 89 fe             	mov    %r15,%rsi
  800d12:	4c 89 ef             	mov    %r13,%rdi
  800d15:	48 b8 89 06 80 00 00 	movabs $0x800689,%rax
  800d1c:	00 00 00 
  800d1f:	ff d0                	callq  *%rax
        break;
  800d21:	e9 b7 fa ff ff       	jmpq   8007dd <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800d26:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d2a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d2e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d32:	eb ca                	jmp    800cfe <vprintfmt+0x54b>
  if (lflag >= 2)
  800d34:	83 f9 01             	cmp    $0x1,%ecx
  800d37:	7f 22                	jg     800d5b <vprintfmt+0x5a8>
  else if (lflag)
  800d39:	85 c9                	test   %ecx,%ecx
  800d3b:	74 58                	je     800d95 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d3d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d40:	83 f8 2f             	cmp    $0x2f,%eax
  800d43:	77 42                	ja     800d87 <vprintfmt+0x5d4>
  800d45:	89 c2                	mov    %eax,%edx
  800d47:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d4b:	83 c0 08             	add    $0x8,%eax
  800d4e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d51:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d54:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d59:	eb ab                	jmp    800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d5b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d5e:	83 f8 2f             	cmp    $0x2f,%eax
  800d61:	77 16                	ja     800d79 <vprintfmt+0x5c6>
  800d63:	89 c2                	mov    %eax,%edx
  800d65:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d69:	83 c0 08             	add    $0x8,%eax
  800d6c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d6f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d72:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d77:	eb 8d                	jmp    800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d79:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d7d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d81:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d85:	eb e8                	jmp    800d6f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d87:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d8b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d8f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d93:	eb bc                	jmp    800d51 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800d95:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d98:	83 f8 2f             	cmp    $0x2f,%eax
  800d9b:	77 18                	ja     800db5 <vprintfmt+0x602>
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800da3:	83 c0 08             	add    $0x8,%eax
  800da6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800da9:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800dab:	b9 10 00 00 00       	mov    $0x10,%ecx
  800db0:	e9 51 ff ff ff       	jmpq   800d06 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800db5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800db9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800dbd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800dc1:	eb e6                	jmp    800da9 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800dc3:	4c 89 fe             	mov    %r15,%rsi
  800dc6:	bf 25 00 00 00       	mov    $0x25,%edi
  800dcb:	41 ff d5             	callq  *%r13
        break;
  800dce:	e9 0a fa ff ff       	jmpq   8007dd <vprintfmt+0x2a>
        putch('%', putdat);
  800dd3:	4c 89 fe             	mov    %r15,%rsi
  800dd6:	bf 25 00 00 00       	mov    $0x25,%edi
  800ddb:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800dde:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800de2:	0f 84 15 fa ff ff    	je     8007fd <vprintfmt+0x4a>
  800de8:	49 89 de             	mov    %rbx,%r14
  800deb:	49 83 ee 01          	sub    $0x1,%r14
  800def:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800df4:	75 f5                	jne    800deb <vprintfmt+0x638>
  800df6:	e9 e2 f9 ff ff       	jmpq   8007dd <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800dfb:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800dff:	74 06                	je     800e07 <vprintfmt+0x654>
  800e01:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800e05:	7f 21                	jg     800e28 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e07:	bf 28 00 00 00       	mov    $0x28,%edi
  800e0c:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e13:	00 00 00 
  800e16:	b8 28 00 00 00       	mov    $0x28,%eax
  800e1b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e1f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e23:	e9 82 fc ff ff       	jmpq   800aaa <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800e28:	49 63 f4             	movslq %r12d,%rsi
  800e2b:	48 bf 7b 14 80 00 00 	movabs $0x80147b,%rdi
  800e32:	00 00 00 
  800e35:	48 b8 8a 0f 80 00 00 	movabs $0x800f8a,%rax
  800e3c:	00 00 00 
  800e3f:	ff d0                	callq  *%rax
  800e41:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e44:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e47:	48 be 7b 14 80 00 00 	movabs $0x80147b,%rsi
  800e4e:	00 00 00 
  800e51:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e55:	85 c0                	test   %eax,%eax
  800e57:	0f 8f f2 fb ff ff    	jg     800a4f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e5d:	48 bb 7c 14 80 00 00 	movabs $0x80147c,%rbx
  800e64:	00 00 00 
  800e67:	b8 28 00 00 00       	mov    $0x28,%eax
  800e6c:	bf 28 00 00 00       	mov    $0x28,%edi
  800e71:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e75:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e79:	e9 2c fc ff ff       	jmpq   800aaa <vprintfmt+0x2f7>
}
  800e7e:	48 83 c4 48          	add    $0x48,%rsp
  800e82:	5b                   	pop    %rbx
  800e83:	41 5c                	pop    %r12
  800e85:	41 5d                	pop    %r13
  800e87:	41 5e                	pop    %r14
  800e89:	41 5f                	pop    %r15
  800e8b:	5d                   	pop    %rbp
  800e8c:	c3                   	retq   

0000000000800e8d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e8d:	55                   	push   %rbp
  800e8e:	48 89 e5             	mov    %rsp,%rbp
  800e91:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800e95:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800e99:	48 63 c6             	movslq %esi,%rax
  800e9c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800ea1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800ea5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800eac:	48 85 ff             	test   %rdi,%rdi
  800eaf:	74 2a                	je     800edb <vsnprintf+0x4e>
  800eb1:	85 f6                	test   %esi,%esi
  800eb3:	7e 26                	jle    800edb <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800eb5:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800eb9:	48 bf 15 07 80 00 00 	movabs $0x800715,%rdi
  800ec0:	00 00 00 
  800ec3:	48 b8 b3 07 80 00 00 	movabs $0x8007b3,%rax
  800eca:	00 00 00 
  800ecd:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800ecf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800ed3:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ed6:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ed9:	c9                   	leaveq 
  800eda:	c3                   	retq   
    return -E_INVAL;
  800edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee0:	eb f7                	jmp    800ed9 <vsnprintf+0x4c>

0000000000800ee2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800ee2:	55                   	push   %rbp
  800ee3:	48 89 e5             	mov    %rsp,%rbp
  800ee6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800eed:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ef4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800efb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f02:	84 c0                	test   %al,%al
  800f04:	74 20                	je     800f26 <snprintf+0x44>
  800f06:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f0a:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f0e:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f12:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f16:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f1a:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f1e:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f22:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800f26:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800f2d:	00 00 00 
  800f30:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f37:	00 00 00 
  800f3a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f3e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f45:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f4c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f53:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f5a:	48 b8 8d 0e 80 00 00 	movabs $0x800e8d,%rax
  800f61:	00 00 00 
  800f64:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f66:	c9                   	leaveq 
  800f67:	c3                   	retq   

0000000000800f68 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f68:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f6b:	74 17                	je     800f84 <strlen+0x1c>
  800f6d:	48 89 fa             	mov    %rdi,%rdx
  800f70:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f75:	29 f9                	sub    %edi,%ecx
    n++;
  800f77:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f7a:	48 83 c2 01          	add    $0x1,%rdx
  800f7e:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f81:	75 f4                	jne    800f77 <strlen+0xf>
  800f83:	c3                   	retq   
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f89:	c3                   	retq   

0000000000800f8a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f8a:	48 85 f6             	test   %rsi,%rsi
  800f8d:	74 24                	je     800fb3 <strnlen+0x29>
  800f8f:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f92:	74 25                	je     800fb9 <strnlen+0x2f>
  800f94:	48 01 fe             	add    %rdi,%rsi
  800f97:	48 89 fa             	mov    %rdi,%rdx
  800f9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f9f:	29 f9                	sub    %edi,%ecx
    n++;
  800fa1:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fa4:	48 83 c2 01          	add    $0x1,%rdx
  800fa8:	48 39 f2             	cmp    %rsi,%rdx
  800fab:	74 11                	je     800fbe <strnlen+0x34>
  800fad:	80 3a 00             	cmpb   $0x0,(%rdx)
  800fb0:	75 ef                	jne    800fa1 <strnlen+0x17>
  800fb2:	c3                   	retq   
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb8:	c3                   	retq   
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800fbe:	c3                   	retq   

0000000000800fbf <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800fbf:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800fc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc7:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800fcb:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800fce:	48 83 c2 01          	add    $0x1,%rdx
  800fd2:	84 c9                	test   %cl,%cl
  800fd4:	75 f1                	jne    800fc7 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800fd6:	c3                   	retq   

0000000000800fd7 <strcat>:

char *
strcat(char *dst, const char *src) {
  800fd7:	55                   	push   %rbp
  800fd8:	48 89 e5             	mov    %rsp,%rbp
  800fdb:	41 54                	push   %r12
  800fdd:	53                   	push   %rbx
  800fde:	48 89 fb             	mov    %rdi,%rbx
  800fe1:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800fe4:	48 b8 68 0f 80 00 00 	movabs $0x800f68,%rax
  800feb:	00 00 00 
  800fee:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800ff0:	48 63 f8             	movslq %eax,%rdi
  800ff3:	48 01 df             	add    %rbx,%rdi
  800ff6:	4c 89 e6             	mov    %r12,%rsi
  800ff9:	48 b8 bf 0f 80 00 00 	movabs $0x800fbf,%rax
  801000:	00 00 00 
  801003:	ff d0                	callq  *%rax
  return dst;
}
  801005:	48 89 d8             	mov    %rbx,%rax
  801008:	5b                   	pop    %rbx
  801009:	41 5c                	pop    %r12
  80100b:	5d                   	pop    %rbp
  80100c:	c3                   	retq   

000000000080100d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80100d:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  801010:	48 85 d2             	test   %rdx,%rdx
  801013:	74 1f                	je     801034 <strncpy+0x27>
  801015:	48 01 fa             	add    %rdi,%rdx
  801018:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  80101b:	48 83 c1 01          	add    $0x1,%rcx
  80101f:	44 0f b6 06          	movzbl (%rsi),%r8d
  801023:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801027:	41 80 f8 01          	cmp    $0x1,%r8b
  80102b:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  80102f:	48 39 ca             	cmp    %rcx,%rdx
  801032:	75 e7                	jne    80101b <strncpy+0xe>
  }
  return ret;
}
  801034:	c3                   	retq   

0000000000801035 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801035:	48 89 f8             	mov    %rdi,%rax
  801038:	48 85 d2             	test   %rdx,%rdx
  80103b:	74 36                	je     801073 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  80103d:	48 83 fa 01          	cmp    $0x1,%rdx
  801041:	74 2d                	je     801070 <strlcpy+0x3b>
  801043:	44 0f b6 06          	movzbl (%rsi),%r8d
  801047:	45 84 c0             	test   %r8b,%r8b
  80104a:	74 24                	je     801070 <strlcpy+0x3b>
  80104c:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801050:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801055:	48 83 c0 01          	add    $0x1,%rax
  801059:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  80105d:	48 39 d1             	cmp    %rdx,%rcx
  801060:	74 0e                	je     801070 <strlcpy+0x3b>
  801062:	48 83 c1 01          	add    $0x1,%rcx
  801066:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  80106b:	45 84 c0             	test   %r8b,%r8b
  80106e:	75 e5                	jne    801055 <strlcpy+0x20>
    *dst = '\0';
  801070:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  801073:	48 29 f8             	sub    %rdi,%rax
}
  801076:	c3                   	retq   

0000000000801077 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801077:	0f b6 07             	movzbl (%rdi),%eax
  80107a:	84 c0                	test   %al,%al
  80107c:	74 17                	je     801095 <strcmp+0x1e>
  80107e:	3a 06                	cmp    (%rsi),%al
  801080:	75 13                	jne    801095 <strcmp+0x1e>
    p++, q++;
  801082:	48 83 c7 01          	add    $0x1,%rdi
  801086:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  80108a:	0f b6 07             	movzbl (%rdi),%eax
  80108d:	84 c0                	test   %al,%al
  80108f:	74 04                	je     801095 <strcmp+0x1e>
  801091:	3a 06                	cmp    (%rsi),%al
  801093:	74 ed                	je     801082 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  801095:	0f b6 c0             	movzbl %al,%eax
  801098:	0f b6 16             	movzbl (%rsi),%edx
  80109b:	29 d0                	sub    %edx,%eax
}
  80109d:	c3                   	retq   

000000000080109e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  80109e:	48 85 d2             	test   %rdx,%rdx
  8010a1:	74 2f                	je     8010d2 <strncmp+0x34>
  8010a3:	0f b6 07             	movzbl (%rdi),%eax
  8010a6:	84 c0                	test   %al,%al
  8010a8:	74 1f                	je     8010c9 <strncmp+0x2b>
  8010aa:	3a 06                	cmp    (%rsi),%al
  8010ac:	75 1b                	jne    8010c9 <strncmp+0x2b>
  8010ae:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8010b1:	48 83 c7 01          	add    $0x1,%rdi
  8010b5:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8010b9:	48 39 d7             	cmp    %rdx,%rdi
  8010bc:	74 1a                	je     8010d8 <strncmp+0x3a>
  8010be:	0f b6 07             	movzbl (%rdi),%eax
  8010c1:	84 c0                	test   %al,%al
  8010c3:	74 04                	je     8010c9 <strncmp+0x2b>
  8010c5:	3a 06                	cmp    (%rsi),%al
  8010c7:	74 e8                	je     8010b1 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8010c9:	0f b6 07             	movzbl (%rdi),%eax
  8010cc:	0f b6 16             	movzbl (%rsi),%edx
  8010cf:	29 d0                	sub    %edx,%eax
}
  8010d1:	c3                   	retq   
    return 0;
  8010d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d7:	c3                   	retq   
  8010d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010dd:	c3                   	retq   

00000000008010de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010de:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010e0:	0f b6 07             	movzbl (%rdi),%eax
  8010e3:	84 c0                	test   %al,%al
  8010e5:	74 1e                	je     801105 <strchr+0x27>
    if (*s == c)
  8010e7:	40 38 c6             	cmp    %al,%sil
  8010ea:	74 1f                	je     80110b <strchr+0x2d>
  for (; *s; s++)
  8010ec:	48 83 c7 01          	add    $0x1,%rdi
  8010f0:	0f b6 07             	movzbl (%rdi),%eax
  8010f3:	84 c0                	test   %al,%al
  8010f5:	74 08                	je     8010ff <strchr+0x21>
    if (*s == c)
  8010f7:	38 d0                	cmp    %dl,%al
  8010f9:	75 f1                	jne    8010ec <strchr+0xe>
  for (; *s; s++)
  8010fb:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8010fe:	c3                   	retq   
  return 0;
  8010ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801104:	c3                   	retq   
  801105:	b8 00 00 00 00       	mov    $0x0,%eax
  80110a:	c3                   	retq   
    if (*s == c)
  80110b:	48 89 f8             	mov    %rdi,%rax
  80110e:	c3                   	retq   

000000000080110f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  80110f:	48 89 f8             	mov    %rdi,%rax
  801112:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  801114:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801117:	40 38 f2             	cmp    %sil,%dl
  80111a:	74 13                	je     80112f <strfind+0x20>
  80111c:	84 d2                	test   %dl,%dl
  80111e:	74 0f                	je     80112f <strfind+0x20>
  for (; *s; s++)
  801120:	48 83 c0 01          	add    $0x1,%rax
  801124:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801127:	38 ca                	cmp    %cl,%dl
  801129:	74 04                	je     80112f <strfind+0x20>
  80112b:	84 d2                	test   %dl,%dl
  80112d:	75 f1                	jne    801120 <strfind+0x11>
      break;
  return (char *)s;
}
  80112f:	c3                   	retq   

0000000000801130 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801130:	48 85 d2             	test   %rdx,%rdx
  801133:	74 3a                	je     80116f <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801135:	48 89 f8             	mov    %rdi,%rax
  801138:	48 09 d0             	or     %rdx,%rax
  80113b:	a8 03                	test   $0x3,%al
  80113d:	75 28                	jne    801167 <memset+0x37>
    uint32_t k = c & 0xFFU;
  80113f:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801143:	89 f0                	mov    %esi,%eax
  801145:	c1 e0 08             	shl    $0x8,%eax
  801148:	89 f1                	mov    %esi,%ecx
  80114a:	c1 e1 18             	shl    $0x18,%ecx
  80114d:	41 89 f0             	mov    %esi,%r8d
  801150:	41 c1 e0 10          	shl    $0x10,%r8d
  801154:	44 09 c1             	or     %r8d,%ecx
  801157:	09 ce                	or     %ecx,%esi
  801159:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  80115b:	48 c1 ea 02          	shr    $0x2,%rdx
  80115f:	48 89 d1             	mov    %rdx,%rcx
  801162:	fc                   	cld    
  801163:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801165:	eb 08                	jmp    80116f <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801167:	89 f0                	mov    %esi,%eax
  801169:	48 89 d1             	mov    %rdx,%rcx
  80116c:	fc                   	cld    
  80116d:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  80116f:	48 89 f8             	mov    %rdi,%rax
  801172:	c3                   	retq   

0000000000801173 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  801173:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801176:	48 39 fe             	cmp    %rdi,%rsi
  801179:	73 40                	jae    8011bb <memmove+0x48>
  80117b:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  80117f:	48 39 f9             	cmp    %rdi,%rcx
  801182:	76 37                	jbe    8011bb <memmove+0x48>
    s += n;
    d += n;
  801184:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801188:	48 89 fe             	mov    %rdi,%rsi
  80118b:	48 09 d6             	or     %rdx,%rsi
  80118e:	48 09 ce             	or     %rcx,%rsi
  801191:	40 f6 c6 03          	test   $0x3,%sil
  801195:	75 14                	jne    8011ab <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  801197:	48 83 ef 04          	sub    $0x4,%rdi
  80119b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  80119f:	48 c1 ea 02          	shr    $0x2,%rdx
  8011a3:	48 89 d1             	mov    %rdx,%rcx
  8011a6:	fd                   	std    
  8011a7:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011a9:	eb 0e                	jmp    8011b9 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8011ab:	48 83 ef 01          	sub    $0x1,%rdi
  8011af:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8011b3:	48 89 d1             	mov    %rdx,%rcx
  8011b6:	fd                   	std    
  8011b7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8011b9:	fc                   	cld    
  8011ba:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8011bb:	48 89 c1             	mov    %rax,%rcx
  8011be:	48 09 d1             	or     %rdx,%rcx
  8011c1:	48 09 f1             	or     %rsi,%rcx
  8011c4:	f6 c1 03             	test   $0x3,%cl
  8011c7:	75 0e                	jne    8011d7 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8011c9:	48 c1 ea 02          	shr    $0x2,%rdx
  8011cd:	48 89 d1             	mov    %rdx,%rcx
  8011d0:	48 89 c7             	mov    %rax,%rdi
  8011d3:	fc                   	cld    
  8011d4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8011d6:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011d7:	48 89 c7             	mov    %rax,%rdi
  8011da:	48 89 d1             	mov    %rdx,%rcx
  8011dd:	fc                   	cld    
  8011de:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011e0:	c3                   	retq   

00000000008011e1 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011e1:	55                   	push   %rbp
  8011e2:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011e5:	48 b8 73 11 80 00 00 	movabs $0x801173,%rax
  8011ec:	00 00 00 
  8011ef:	ff d0                	callq  *%rax
}
  8011f1:	5d                   	pop    %rbp
  8011f2:	c3                   	retq   

00000000008011f3 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8011f3:	55                   	push   %rbp
  8011f4:	48 89 e5             	mov    %rsp,%rbp
  8011f7:	41 57                	push   %r15
  8011f9:	41 56                	push   %r14
  8011fb:	41 55                	push   %r13
  8011fd:	41 54                	push   %r12
  8011ff:	53                   	push   %rbx
  801200:	48 83 ec 08          	sub    $0x8,%rsp
  801204:	49 89 fe             	mov    %rdi,%r14
  801207:	49 89 f7             	mov    %rsi,%r15
  80120a:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  80120d:	48 89 f7             	mov    %rsi,%rdi
  801210:	48 b8 68 0f 80 00 00 	movabs $0x800f68,%rax
  801217:	00 00 00 
  80121a:	ff d0                	callq  *%rax
  80121c:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  80121f:	4c 89 ee             	mov    %r13,%rsi
  801222:	4c 89 f7             	mov    %r14,%rdi
  801225:	48 b8 8a 0f 80 00 00 	movabs $0x800f8a,%rax
  80122c:	00 00 00 
  80122f:	ff d0                	callq  *%rax
  801231:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  801234:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801238:	4d 39 e5             	cmp    %r12,%r13
  80123b:	74 26                	je     801263 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  80123d:	4c 89 e8             	mov    %r13,%rax
  801240:	4c 29 e0             	sub    %r12,%rax
  801243:	48 39 d8             	cmp    %rbx,%rax
  801246:	76 2a                	jbe    801272 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801248:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  80124c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801250:	4c 89 fe             	mov    %r15,%rsi
  801253:	48 b8 e1 11 80 00 00 	movabs $0x8011e1,%rax
  80125a:	00 00 00 
  80125d:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80125f:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801263:	48 83 c4 08          	add    $0x8,%rsp
  801267:	5b                   	pop    %rbx
  801268:	41 5c                	pop    %r12
  80126a:	41 5d                	pop    %r13
  80126c:	41 5e                	pop    %r14
  80126e:	41 5f                	pop    %r15
  801270:	5d                   	pop    %rbp
  801271:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801272:	49 83 ed 01          	sub    $0x1,%r13
  801276:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  80127a:	4c 89 ea             	mov    %r13,%rdx
  80127d:	4c 89 fe             	mov    %r15,%rsi
  801280:	48 b8 e1 11 80 00 00 	movabs $0x8011e1,%rax
  801287:	00 00 00 
  80128a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80128c:	4d 01 ee             	add    %r13,%r14
  80128f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801294:	eb c9                	jmp    80125f <strlcat+0x6c>

0000000000801296 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801296:	48 85 d2             	test   %rdx,%rdx
  801299:	74 3a                	je     8012d5 <memcmp+0x3f>
    if (*s1 != *s2)
  80129b:	0f b6 0f             	movzbl (%rdi),%ecx
  80129e:	44 0f b6 06          	movzbl (%rsi),%r8d
  8012a2:	44 38 c1             	cmp    %r8b,%cl
  8012a5:	75 1d                	jne    8012c4 <memcmp+0x2e>
  8012a7:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8012ac:	48 39 d0             	cmp    %rdx,%rax
  8012af:	74 1e                	je     8012cf <memcmp+0x39>
    if (*s1 != *s2)
  8012b1:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8012b5:	48 83 c0 01          	add    $0x1,%rax
  8012b9:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8012bf:	44 38 c1             	cmp    %r8b,%cl
  8012c2:	74 e8                	je     8012ac <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8012c4:	0f b6 c1             	movzbl %cl,%eax
  8012c7:	45 0f b6 c0          	movzbl %r8b,%r8d
  8012cb:	44 29 c0             	sub    %r8d,%eax
  8012ce:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8012cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d4:	c3                   	retq   
  8012d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012da:	c3                   	retq   

00000000008012db <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012db:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012df:	48 39 c7             	cmp    %rax,%rdi
  8012e2:	73 19                	jae    8012fd <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012e4:	89 f2                	mov    %esi,%edx
  8012e6:	40 38 37             	cmp    %sil,(%rdi)
  8012e9:	74 16                	je     801301 <memfind+0x26>
  for (; s < ends; s++)
  8012eb:	48 83 c7 01          	add    $0x1,%rdi
  8012ef:	48 39 f8             	cmp    %rdi,%rax
  8012f2:	74 08                	je     8012fc <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012f4:	38 17                	cmp    %dl,(%rdi)
  8012f6:	75 f3                	jne    8012eb <memfind+0x10>
  for (; s < ends; s++)
  8012f8:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8012fb:	c3                   	retq   
  8012fc:	c3                   	retq   
  for (; s < ends; s++)
  8012fd:	48 89 f8             	mov    %rdi,%rax
  801300:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801301:	48 89 f8             	mov    %rdi,%rax
  801304:	c3                   	retq   

0000000000801305 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801305:	0f b6 07             	movzbl (%rdi),%eax
  801308:	3c 20                	cmp    $0x20,%al
  80130a:	74 04                	je     801310 <strtol+0xb>
  80130c:	3c 09                	cmp    $0x9,%al
  80130e:	75 0f                	jne    80131f <strtol+0x1a>
    s++;
  801310:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801314:	0f b6 07             	movzbl (%rdi),%eax
  801317:	3c 20                	cmp    $0x20,%al
  801319:	74 f5                	je     801310 <strtol+0xb>
  80131b:	3c 09                	cmp    $0x9,%al
  80131d:	74 f1                	je     801310 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  80131f:	3c 2b                	cmp    $0x2b,%al
  801321:	74 2b                	je     80134e <strtol+0x49>
  int neg  = 0;
  801323:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801329:	3c 2d                	cmp    $0x2d,%al
  80132b:	74 2d                	je     80135a <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80132d:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801333:	75 0f                	jne    801344 <strtol+0x3f>
  801335:	80 3f 30             	cmpb   $0x30,(%rdi)
  801338:	74 2c                	je     801366 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80133a:	85 d2                	test   %edx,%edx
  80133c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801341:	0f 44 d0             	cmove  %eax,%edx
  801344:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801349:	4c 63 d2             	movslq %edx,%r10
  80134c:	eb 5c                	jmp    8013aa <strtol+0xa5>
    s++;
  80134e:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801352:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801358:	eb d3                	jmp    80132d <strtol+0x28>
    s++, neg = 1;
  80135a:	48 83 c7 01          	add    $0x1,%rdi
  80135e:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801364:	eb c7                	jmp    80132d <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801366:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80136a:	74 0f                	je     80137b <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  80136c:	85 d2                	test   %edx,%edx
  80136e:	75 d4                	jne    801344 <strtol+0x3f>
    s++, base = 8;
  801370:	48 83 c7 01          	add    $0x1,%rdi
  801374:	ba 08 00 00 00       	mov    $0x8,%edx
  801379:	eb c9                	jmp    801344 <strtol+0x3f>
    s += 2, base = 16;
  80137b:	48 83 c7 02          	add    $0x2,%rdi
  80137f:	ba 10 00 00 00       	mov    $0x10,%edx
  801384:	eb be                	jmp    801344 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801386:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80138a:	41 80 f8 19          	cmp    $0x19,%r8b
  80138e:	77 2f                	ja     8013bf <strtol+0xba>
      dig = *s - 'a' + 10;
  801390:	44 0f be c1          	movsbl %cl,%r8d
  801394:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801398:	39 d1                	cmp    %edx,%ecx
  80139a:	7d 37                	jge    8013d3 <strtol+0xce>
    s++, val = (val * base) + dig;
  80139c:	48 83 c7 01          	add    $0x1,%rdi
  8013a0:	49 0f af c2          	imul   %r10,%rax
  8013a4:	48 63 c9             	movslq %ecx,%rcx
  8013a7:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8013aa:	0f b6 0f             	movzbl (%rdi),%ecx
  8013ad:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8013b1:	41 80 f8 09          	cmp    $0x9,%r8b
  8013b5:	77 cf                	ja     801386 <strtol+0x81>
      dig = *s - '0';
  8013b7:	0f be c9             	movsbl %cl,%ecx
  8013ba:	83 e9 30             	sub    $0x30,%ecx
  8013bd:	eb d9                	jmp    801398 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8013bf:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8013c3:	41 80 f8 19          	cmp    $0x19,%r8b
  8013c7:	77 0a                	ja     8013d3 <strtol+0xce>
      dig = *s - 'A' + 10;
  8013c9:	44 0f be c1          	movsbl %cl,%r8d
  8013cd:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8013d1:	eb c5                	jmp    801398 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8013d3:	48 85 f6             	test   %rsi,%rsi
  8013d6:	74 03                	je     8013db <strtol+0xd6>
    *endptr = (char *)s;
  8013d8:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013db:	48 89 c2             	mov    %rax,%rdx
  8013de:	48 f7 da             	neg    %rdx
  8013e1:	45 85 c9             	test   %r9d,%r9d
  8013e4:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013e8:	c3                   	retq   
  8013e9:	0f 1f 00             	nopl   (%rax)
