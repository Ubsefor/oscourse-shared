
obj/user/memlayout:     file format elf64-x86-64


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
  800023:	e8 27 03 00 00       	callq  80034f <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <memlayout>:
#ifndef PTE_SHARE
#define PTE_SHARE 0x400
#endif // PTE_SHARE

void
memlayout(void) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 57                	push   %r15
  800030:	41 56                	push   %r14
  800032:	41 55                	push   %r13
  800034:	41 54                	push   %r12
  800036:	53                   	push   %rbx
  800037:	48 83 ec 28          	sub    $0x28,%rsp
  size_t total_p   = 0;
  size_t total_u   = 0;
  size_t total_w   = 0;
  size_t total_cow = 0;

  cprintf("EID: %d, PEID: %d\n", thisenv->env_id, thisenv->env_parent_id);
  80003b:	49 bc 08 30 80 00 00 	movabs $0x803008,%r12
  800042:	00 00 00 
  800045:	49 8b 04 24          	mov    (%r12),%rax
  800049:	8b 90 cc 00 00 00    	mov    0xcc(%rax),%edx
  80004f:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  800055:	48 bf cc 1c 80 00 00 	movabs $0x801ccc,%rdi
  80005c:	00 00 00 
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
  800064:	48 bb be 05 80 00 00 	movabs $0x8005be,%rbx
  80006b:	00 00 00 
  80006e:	ff d3                	callq  *%rbx
  cprintf("pml4e: %lx, uvpd: %lx, uvpt: %lx\n",
          (unsigned long)thisenv->env_pml4e,
  800070:	49 8b 04 24          	mov    (%r12),%rax
  800074:	48 8b b0 e8 00 00 00 	mov    0xe8(%rax),%rsi
  cprintf("pml4e: %lx, uvpd: %lx, uvpt: %lx\n",
  80007b:	48 b9 00 00 00 00 00 	movabs $0x10000000000,%rcx
  800082:	01 00 00 
  800085:	48 ba 00 00 00 80 00 	movabs $0x10080000000,%rdx
  80008c:	01 00 00 
  80008f:	48 bf 70 1d 80 00 00 	movabs $0x801d70,%rdi
  800096:	00 00 00 
  800099:	b8 00 00 00 00       	mov    $0x0,%eax
  80009e:	ff d3                	callq  *%rbx
  size_t total_cow = 0;
  8000a0:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  8000a7:	00 
  size_t total_w   = 0;
  8000a8:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8000af:	00 
  size_t total_u   = 0;
  8000b0:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8000b7:	00 
  size_t total_p   = 0;
  8000b8:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8000bf:	00 
          (unsigned long)uvpd,
          (unsigned long)uvpt);

  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
  8000c0:	bb 00 00 00 00       	mov    $0x0,%ebx
    if ((uvpml4e[PML4(addr)] & PTE_P) == 0 ||
  8000c5:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  8000cc:	01 00 00 
        (uvpde[VPDPE(addr)] & PTE_P) == 0 ||
  8000cf:	49 bd 00 00 40 80 00 	movabs $0x10080400000,%r13
  8000d6:	01 00 00 
        (uvpd[VPD(addr)] & PTE_P) == 0 ||
  8000d9:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  8000e0:	01 00 00 
        uvpt[VPN(addr)] == 0)
  8000e3:	49 be 00 00 00 00 00 	movabs $0x10000000000,%r14
  8000ea:	01 00 00 
  8000ed:	eb 44                	jmp    800133 <memlayout+0x109>
      continue;
    pg = (pte_t *)uvpt + VPN(addr);
    cprintf("[%p] %lx -> %08lx: %c %c %c |%s%s\n",
  8000ef:	48 83 ec 08          	sub    $0x8,%rsp
  8000f3:	50                   	push   %rax
  8000f4:	57                   	push   %rdi
  8000f5:	52                   	push   %rdx
  8000f6:	48 89 da             	mov    %rbx,%rdx
  8000f9:	48 bf 98 1d 80 00 00 	movabs $0x801d98,%rdi
  800100:	00 00 00 
  800103:	b8 00 00 00 00       	mov    $0x0,%eax
  800108:	49 ba be 05 80 00 00 	movabs $0x8005be,%r10
  80010f:	00 00 00 
  800112:	41 ff d2             	callq  *%r10
  800115:	48 83 c4 20          	add    $0x20,%rsp
  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
  800119:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  800120:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  800127:	00 00 00 
  80012a:	48 39 c3             	cmp    %rax,%rbx
  80012d:	0f 84 ca 00 00 00    	je     8001fd <memlayout+0x1d3>
    if ((uvpml4e[PML4(addr)] & PTE_P) == 0 ||
  800133:	48 89 d8             	mov    %rbx,%rax
  800136:	48 c1 e8 27          	shr    $0x27,%rax
  80013a:	25 ff 01 00 00       	and    $0x1ff,%eax
  80013f:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  800143:	a8 01                	test   $0x1,%al
  800145:	74 d2                	je     800119 <memlayout+0xef>
        (uvpde[VPDPE(addr)] & PTE_P) == 0 ||
  800147:	48 89 d8             	mov    %rbx,%rax
  80014a:	48 c1 e8 1e          	shr    $0x1e,%rax
  80014e:	49 8b 44 c5 00       	mov    0x0(%r13,%rax,8),%rax
    if ((uvpml4e[PML4(addr)] & PTE_P) == 0 ||
  800153:	a8 01                	test   $0x1,%al
  800155:	74 c2                	je     800119 <memlayout+0xef>
        (uvpd[VPD(addr)] & PTE_P) == 0 ||
  800157:	48 89 d8             	mov    %rbx,%rax
  80015a:	48 c1 e8 15          	shr    $0x15,%rax
  80015e:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
        (uvpde[VPDPE(addr)] & PTE_P) == 0 ||
  800162:	a8 01                	test   $0x1,%al
  800164:	74 b3                	je     800119 <memlayout+0xef>
        uvpt[VPN(addr)] == 0)
  800166:	48 89 d8             	mov    %rbx,%rax
  800169:	48 c1 e8 0c          	shr    $0xc,%rax
  80016d:	49 8b 14 c6          	mov    (%r14,%rax,8),%rdx
        (uvpd[VPD(addr)] & PTE_P) == 0 ||
  800171:	48 85 d2             	test   %rdx,%rdx
  800174:	74 a3                	je     800119 <memlayout+0xef>
    pg = (pte_t *)uvpt + VPN(addr);
  800176:	49 8d 34 c6          	lea    (%r14,%rax,8),%rsi
            pg, (unsigned long)addr, (unsigned long)*pg,
            (*pg & PTE_P) ? total_p++, 'P' : '-',
            (*pg & PTE_U) ? total_u++, 'U' : '-',
            (*pg & PTE_W) ? total_w++, 'W' : '-',
            (*pg & PTE_COW) ? total_cow++, " COW" : "",
            (*pg & PTE_SHARE) ? " SHARE" : "");
  80017a:	48 8b 0e             	mov    (%rsi),%rcx
    cprintf("[%p] %lx -> %08lx: %c %c %c |%s%s\n",
  80017d:	48 89 c8             	mov    %rcx,%rax
  800180:	25 00 04 00 00       	and    $0x400,%eax
  800185:	48 b8 c0 1c 80 00 00 	movabs $0x801cc0,%rax
  80018c:	00 00 00 
  80018f:	48 ba f5 1c 80 00 00 	movabs $0x801cf5,%rdx
  800196:	00 00 00 
  800199:	48 0f 44 c2          	cmove  %rdx,%rax
  80019d:	48 89 d7             	mov    %rdx,%rdi
  8001a0:	f6 c5 08             	test   $0x8,%ch
  8001a3:	74 0f                	je     8001b4 <memlayout+0x18a>
            (*pg & PTE_COW) ? total_cow++, " COW" : "",
  8001a5:	48 83 45 b0 01       	addq   $0x1,-0x50(%rbp)
    cprintf("[%p] %lx -> %08lx: %c %c %c |%s%s\n",
  8001aa:	48 bf c7 1c 80 00 00 	movabs $0x801cc7,%rdi
  8001b1:	00 00 00 
  8001b4:	ba 2d 00 00 00       	mov    $0x2d,%edx
  8001b9:	f6 c1 02             	test   $0x2,%cl
  8001bc:	74 0a                	je     8001c8 <memlayout+0x19e>
            (*pg & PTE_W) ? total_w++, 'W' : '-',
  8001be:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
    cprintf("[%p] %lx -> %08lx: %c %c %c |%s%s\n",
  8001c3:	ba 57 00 00 00       	mov    $0x57,%edx
  8001c8:	41 b9 2d 00 00 00    	mov    $0x2d,%r9d
  8001ce:	f6 c1 04             	test   $0x4,%cl
  8001d1:	74 0b                	je     8001de <memlayout+0x1b4>
            (*pg & PTE_U) ? total_u++, 'U' : '-',
  8001d3:	48 83 45 c0 01       	addq   $0x1,-0x40(%rbp)
    cprintf("[%p] %lx -> %08lx: %c %c %c |%s%s\n",
  8001d8:	41 b9 55 00 00 00    	mov    $0x55,%r9d
  8001de:	41 b8 2d 00 00 00    	mov    $0x2d,%r8d
  8001e4:	f6 c1 01             	test   $0x1,%cl
  8001e7:	0f 84 02 ff ff ff    	je     8000ef <memlayout+0xc5>
            (*pg & PTE_P) ? total_p++, 'P' : '-',
  8001ed:	48 83 45 c8 01       	addq   $0x1,-0x38(%rbp)
    cprintf("[%p] %lx -> %08lx: %c %c %c |%s%s\n",
  8001f2:	41 b8 50 00 00 00    	mov    $0x50,%r8d
  8001f8:	e9 f2 fe ff ff       	jmpq   8000ef <memlayout+0xc5>
  }

  cprintf("Memory usage summary:\n");
  8001fd:	48 bf df 1c 80 00 00 	movabs $0x801cdf,%rdi
  800204:	00 00 00 
  800207:	b8 00 00 00 00       	mov    $0x0,%eax
  80020c:	48 bb be 05 80 00 00 	movabs $0x8005be,%rbx
  800213:	00 00 00 
  800216:	ff d3                	callq  *%rbx
  cprintf("  PTE_P: %lu\n", (unsigned long)total_p);
  800218:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80021c:	48 bf f6 1c 80 00 00 	movabs $0x801cf6,%rdi
  800223:	00 00 00 
  800226:	b8 00 00 00 00       	mov    $0x0,%eax
  80022b:	ff d3                	callq  *%rbx
  cprintf("  PTE_U: %lu\n", (unsigned long)total_u);
  80022d:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  800231:	48 bf 04 1d 80 00 00 	movabs $0x801d04,%rdi
  800238:	00 00 00 
  80023b:	b8 00 00 00 00       	mov    $0x0,%eax
  800240:	ff d3                	callq  *%rbx
  cprintf("  PTE_W: %lu\n", (unsigned long)total_w);
  800242:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  800246:	48 bf 12 1d 80 00 00 	movabs $0x801d12,%rdi
  80024d:	00 00 00 
  800250:	b8 00 00 00 00       	mov    $0x0,%eax
  800255:	ff d3                	callq  *%rbx
  cprintf("  PTE_COW: %lu\n", (unsigned long)total_cow);
  800257:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  80025b:	48 bf 20 1d 80 00 00 	movabs $0x801d20,%rdi
  800262:	00 00 00 
  800265:	b8 00 00 00 00       	mov    $0x0,%eax
  80026a:	ff d3                	callq  *%rbx
}
  80026c:	48 8d 65 d8          	lea    -0x28(%rbp),%rsp
  800270:	5b                   	pop    %rbx
  800271:	41 5c                	pop    %r12
  800273:	41 5d                	pop    %r13
  800275:	41 5e                	pop    %r14
  800277:	41 5f                	pop    %r15
  800279:	5d                   	pop    %rbp
  80027a:	c3                   	retq   

000000000080027b <umain>:

void
umain(int argc, char *argv[]) {
  80027b:	55                   	push   %rbp
  80027c:	48 89 e5             	mov    %rsp,%rbp
  80027f:	41 54                	push   %r12
  800281:	53                   	push   %rbx
  envid_t ceid;

  memlayout();
  800282:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800289:	00 00 00 
  80028c:	ff d0                	callq  *%rax

  ceid = fork();
  80028e:	48 b8 7e 18 80 00 00 	movabs $0x80187e,%rax
  800295:	00 00 00 
  800298:	ff d0                	callq  *%rax
  if (ceid < 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	78 2e                	js     8002cc <umain+0x51>
    panic("fork() failed\n");

  if (ceid == 0) {
  80029e:	74 56                	je     8002f6 <umain+0x7b>
    cprintf("==== Child\n");
    memlayout();
    return;
  }

  cprintf("==== Parent\n");
  8002a0:	48 bf 5c 1d 80 00 00 	movabs $0x801d5c,%rdi
  8002a7:	00 00 00 
  8002aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8002af:	48 ba be 05 80 00 00 	movabs $0x8005be,%rdx
  8002b6:	00 00 00 
  8002b9:	ff d2                	callq  *%rdx
  memlayout();
  8002bb:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8002c2:	00 00 00 
  8002c5:	ff d0                	callq  *%rax
}
  8002c7:	5b                   	pop    %rbx
  8002c8:	41 5c                	pop    %r12
  8002ca:	5d                   	pop    %rbp
  8002cb:	c3                   	retq   
    panic("fork() failed\n");
  8002cc:	48 ba 30 1d 80 00 00 	movabs $0x801d30,%rdx
  8002d3:	00 00 00 
  8002d6:	be 38 00 00 00       	mov    $0x38,%esi
  8002db:	48 bf 3f 1d 80 00 00 	movabs $0x801d3f,%rdi
  8002e2:	00 00 00 
  8002e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ea:	48 b9 1c 04 80 00 00 	movabs $0x80041c,%rcx
  8002f1:	00 00 00 
  8002f4:	ff d1                	callq  *%rcx
    cprintf("\n");
  8002f6:	48 bf f4 1c 80 00 00 	movabs $0x801cf4,%rdi
  8002fd:	00 00 00 
  800300:	48 ba be 05 80 00 00 	movabs $0x8005be,%rdx
  800307:	00 00 00 
  80030a:	ff d2                	callq  *%rdx
  80030c:	bb 00 90 01 00       	mov    $0x19000,%ebx
      sys_yield();
  800311:	49 bc 70 14 80 00 00 	movabs $0x801470,%r12
  800318:	00 00 00 
  80031b:	41 ff d4             	callq  *%r12
    for (i = 0; i < 102400; i++)
  80031e:	83 eb 01             	sub    $0x1,%ebx
  800321:	75 f8                	jne    80031b <umain+0xa0>
    cprintf("==== Child\n");
  800323:	48 bf 50 1d 80 00 00 	movabs $0x801d50,%rdi
  80032a:	00 00 00 
  80032d:	b8 00 00 00 00       	mov    $0x0,%eax
  800332:	48 ba be 05 80 00 00 	movabs $0x8005be,%rdx
  800339:	00 00 00 
  80033c:	ff d2                	callq  *%rdx
    memlayout();
  80033e:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800345:	00 00 00 
  800348:	ff d0                	callq  *%rax
    return;
  80034a:	e9 78 ff ff ff       	jmpq   8002c7 <umain+0x4c>

000000000080034f <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  80034f:	55                   	push   %rbp
  800350:	48 89 e5             	mov    %rsp,%rbp
  800353:	41 56                	push   %r14
  800355:	41 55                	push   %r13
  800357:	41 54                	push   %r12
  800359:	53                   	push   %rbx
  80035a:	41 89 fd             	mov    %edi,%r13d
  80035d:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800360:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  800367:	00 00 00 
  80036a:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  800371:	00 00 00 
  800374:	48 39 c2             	cmp    %rax,%rdx
  800377:	73 23                	jae    80039c <libmain+0x4d>
  800379:	48 89 d3             	mov    %rdx,%rbx
  80037c:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800380:	48 29 d0             	sub    %rdx,%rax
  800383:	48 c1 e8 03          	shr    $0x3,%rax
  800387:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80038c:	b8 00 00 00 00       	mov    $0x0,%eax
  800391:	ff 13                	callq  *(%rbx)
    ctor++;
  800393:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800397:	4c 39 e3             	cmp    %r12,%rbx
  80039a:	75 f0                	jne    80038c <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  80039c:	48 b8 50 14 80 00 00 	movabs $0x801450,%rax
  8003a3:	00 00 00 
  8003a6:	ff d0                	callq  *%rax
  8003a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003ad:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8003b1:	48 c1 e0 05          	shl    $0x5,%rax
  8003b5:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8003bc:	00 00 00 
  8003bf:	48 01 d0             	add    %rdx,%rax
  8003c2:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  8003c9:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8003cc:	45 85 ed             	test   %r13d,%r13d
  8003cf:	7e 0d                	jle    8003de <libmain+0x8f>
    binaryname = argv[0];
  8003d1:	49 8b 06             	mov    (%r14),%rax
  8003d4:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  8003db:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8003de:	4c 89 f6             	mov    %r14,%rsi
  8003e1:	44 89 ef             	mov    %r13d,%edi
  8003e4:	48 b8 7b 02 80 00 00 	movabs $0x80027b,%rax
  8003eb:	00 00 00 
  8003ee:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8003f0:	48 b8 05 04 80 00 00 	movabs $0x800405,%rax
  8003f7:	00 00 00 
  8003fa:	ff d0                	callq  *%rax
#endif
}
  8003fc:	5b                   	pop    %rbx
  8003fd:	41 5c                	pop    %r12
  8003ff:	41 5d                	pop    %r13
  800401:	41 5e                	pop    %r14
  800403:	5d                   	pop    %rbp
  800404:	c3                   	retq   

0000000000800405 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800405:	55                   	push   %rbp
  800406:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800409:	bf 00 00 00 00       	mov    $0x0,%edi
  80040e:	48 b8 f0 13 80 00 00 	movabs $0x8013f0,%rax
  800415:	00 00 00 
  800418:	ff d0                	callq  *%rax
}
  80041a:	5d                   	pop    %rbp
  80041b:	c3                   	retq   

000000000080041c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80041c:	55                   	push   %rbp
  80041d:	48 89 e5             	mov    %rsp,%rbp
  800420:	41 56                	push   %r14
  800422:	41 55                	push   %r13
  800424:	41 54                	push   %r12
  800426:	53                   	push   %rbx
  800427:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80042e:	49 89 fd             	mov    %rdi,%r13
  800431:	41 89 f6             	mov    %esi,%r14d
  800434:	49 89 d4             	mov    %rdx,%r12
  800437:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  80043e:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800445:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80044c:	84 c0                	test   %al,%al
  80044e:	74 26                	je     800476 <_panic+0x5a>
  800450:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800457:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  80045e:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800462:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800466:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80046a:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  80046e:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800472:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800476:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80047d:	00 00 00 
  800480:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800487:	00 00 00 
  80048a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80048e:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800495:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80049c:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  8004a3:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  8004aa:	00 00 00 
  8004ad:	48 8b 18             	mov    (%rax),%rbx
  8004b0:	48 b8 50 14 80 00 00 	movabs $0x801450,%rax
  8004b7:	00 00 00 
  8004ba:	ff d0                	callq  *%rax
  8004bc:	45 89 f0             	mov    %r14d,%r8d
  8004bf:	4c 89 e9             	mov    %r13,%rcx
  8004c2:	48 89 da             	mov    %rbx,%rdx
  8004c5:	89 c6                	mov    %eax,%esi
  8004c7:	48 bf c8 1d 80 00 00 	movabs $0x801dc8,%rdi
  8004ce:	00 00 00 
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	48 bb be 05 80 00 00 	movabs $0x8005be,%rbx
  8004dd:	00 00 00 
  8004e0:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8004e2:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8004e9:	4c 89 e7             	mov    %r12,%rdi
  8004ec:	48 b8 56 05 80 00 00 	movabs $0x800556,%rax
  8004f3:	00 00 00 
  8004f6:	ff d0                	callq  *%rax
  cprintf("\n");
  8004f8:	48 bf f4 1c 80 00 00 	movabs $0x801cf4,%rdi
  8004ff:	00 00 00 
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800509:	cc                   	int3   
  while (1)
  80050a:	eb fd                	jmp    800509 <_panic+0xed>

000000000080050c <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80050c:	55                   	push   %rbp
  80050d:	48 89 e5             	mov    %rsp,%rbp
  800510:	53                   	push   %rbx
  800511:	48 83 ec 08          	sub    $0x8,%rsp
  800515:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800518:	8b 06                	mov    (%rsi),%eax
  80051a:	8d 50 01             	lea    0x1(%rax),%edx
  80051d:	89 16                	mov    %edx,(%rsi)
  80051f:	48 98                	cltq   
  800521:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800526:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80052c:	74 0b                	je     800539 <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80052e:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800532:	48 83 c4 08          	add    $0x8,%rsp
  800536:	5b                   	pop    %rbx
  800537:	5d                   	pop    %rbp
  800538:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800539:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80053d:	be ff 00 00 00       	mov    $0xff,%esi
  800542:	48 b8 b2 13 80 00 00 	movabs $0x8013b2,%rax
  800549:	00 00 00 
  80054c:	ff d0                	callq  *%rax
    b->idx = 0;
  80054e:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800554:	eb d8                	jmp    80052e <putch+0x22>

0000000000800556 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800556:	55                   	push   %rbp
  800557:	48 89 e5             	mov    %rsp,%rbp
  80055a:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800561:	48 89 fa             	mov    %rdi,%rdx
  800564:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800567:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80056e:	00 00 00 
  b.cnt = 0;
  800571:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800578:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80057b:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800582:	48 bf 0c 05 80 00 00 	movabs $0x80050c,%rdi
  800589:	00 00 00 
  80058c:	48 b8 7c 07 80 00 00 	movabs $0x80077c,%rax
  800593:	00 00 00 
  800596:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800598:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  80059f:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8005a6:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8005aa:	48 b8 b2 13 80 00 00 	movabs $0x8013b2,%rax
  8005b1:	00 00 00 
  8005b4:	ff d0                	callq  *%rax

  return b.cnt;
}
  8005b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8005bc:	c9                   	leaveq 
  8005bd:	c3                   	retq   

00000000008005be <cprintf>:

int
cprintf(const char *fmt, ...) {
  8005be:	55                   	push   %rbp
  8005bf:	48 89 e5             	mov    %rsp,%rbp
  8005c2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8005c9:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8005d0:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8005d7:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8005de:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8005e5:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8005ec:	84 c0                	test   %al,%al
  8005ee:	74 20                	je     800610 <cprintf+0x52>
  8005f0:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8005f4:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8005f8:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8005fc:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800600:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800604:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800608:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80060c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800610:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800617:	00 00 00 
  80061a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800621:	00 00 00 
  800624:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800628:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80062f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800636:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80063d:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800644:	48 b8 56 05 80 00 00 	movabs $0x800556,%rax
  80064b:	00 00 00 
  80064e:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800650:	c9                   	leaveq 
  800651:	c3                   	retq   

0000000000800652 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800652:	55                   	push   %rbp
  800653:	48 89 e5             	mov    %rsp,%rbp
  800656:	41 57                	push   %r15
  800658:	41 56                	push   %r14
  80065a:	41 55                	push   %r13
  80065c:	41 54                	push   %r12
  80065e:	53                   	push   %rbx
  80065f:	48 83 ec 18          	sub    $0x18,%rsp
  800663:	49 89 fc             	mov    %rdi,%r12
  800666:	49 89 f5             	mov    %rsi,%r13
  800669:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80066d:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800670:	41 89 cf             	mov    %ecx,%r15d
  800673:	49 39 d7             	cmp    %rdx,%r15
  800676:	76 45                	jbe    8006bd <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800678:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80067c:	85 db                	test   %ebx,%ebx
  80067e:	7e 0e                	jle    80068e <printnum+0x3c>
      putch(padc, putdat);
  800680:	4c 89 ee             	mov    %r13,%rsi
  800683:	44 89 f7             	mov    %r14d,%edi
  800686:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800689:	83 eb 01             	sub    $0x1,%ebx
  80068c:	75 f2                	jne    800680 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80068e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800692:	ba 00 00 00 00       	mov    $0x0,%edx
  800697:	49 f7 f7             	div    %r15
  80069a:	48 b8 eb 1d 80 00 00 	movabs $0x801deb,%rax
  8006a1:	00 00 00 
  8006a4:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8006a8:	4c 89 ee             	mov    %r13,%rsi
  8006ab:	41 ff d4             	callq  *%r12
}
  8006ae:	48 83 c4 18          	add    $0x18,%rsp
  8006b2:	5b                   	pop    %rbx
  8006b3:	41 5c                	pop    %r12
  8006b5:	41 5d                	pop    %r13
  8006b7:	41 5e                	pop    %r14
  8006b9:	41 5f                	pop    %r15
  8006bb:	5d                   	pop    %rbp
  8006bc:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8006bd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8006c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c6:	49 f7 f7             	div    %r15
  8006c9:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8006cd:	48 89 c2             	mov    %rax,%rdx
  8006d0:	48 b8 52 06 80 00 00 	movabs $0x800652,%rax
  8006d7:	00 00 00 
  8006da:	ff d0                	callq  *%rax
  8006dc:	eb b0                	jmp    80068e <printnum+0x3c>

00000000008006de <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8006de:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8006e2:	48 8b 06             	mov    (%rsi),%rax
  8006e5:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8006e9:	73 0a                	jae    8006f5 <sprintputch+0x17>
    *b->buf++ = ch;
  8006eb:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8006ef:	48 89 16             	mov    %rdx,(%rsi)
  8006f2:	40 88 38             	mov    %dil,(%rax)
}
  8006f5:	c3                   	retq   

00000000008006f6 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8006f6:	55                   	push   %rbp
  8006f7:	48 89 e5             	mov    %rsp,%rbp
  8006fa:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800701:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800708:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80070f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800716:	84 c0                	test   %al,%al
  800718:	74 20                	je     80073a <printfmt+0x44>
  80071a:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80071e:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800722:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800726:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80072a:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80072e:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800732:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800736:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80073a:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800741:	00 00 00 
  800744:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80074b:	00 00 00 
  80074e:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800752:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800759:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800760:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800767:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80076e:	48 b8 7c 07 80 00 00 	movabs $0x80077c,%rax
  800775:	00 00 00 
  800778:	ff d0                	callq  *%rax
}
  80077a:	c9                   	leaveq 
  80077b:	c3                   	retq   

000000000080077c <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80077c:	55                   	push   %rbp
  80077d:	48 89 e5             	mov    %rsp,%rbp
  800780:	41 57                	push   %r15
  800782:	41 56                	push   %r14
  800784:	41 55                	push   %r13
  800786:	41 54                	push   %r12
  800788:	53                   	push   %rbx
  800789:	48 83 ec 48          	sub    $0x48,%rsp
  80078d:	49 89 fd             	mov    %rdi,%r13
  800790:	49 89 f7             	mov    %rsi,%r15
  800793:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  800796:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80079a:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80079e:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8007a2:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007a6:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8007aa:	41 0f b6 3e          	movzbl (%r14),%edi
  8007ae:	83 ff 25             	cmp    $0x25,%edi
  8007b1:	74 18                	je     8007cb <vprintfmt+0x4f>
      if (ch == '\0')
  8007b3:	85 ff                	test   %edi,%edi
  8007b5:	0f 84 8c 06 00 00    	je     800e47 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8007bb:	4c 89 fe             	mov    %r15,%rsi
  8007be:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8007c1:	49 89 de             	mov    %rbx,%r14
  8007c4:	eb e0                	jmp    8007a6 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8007c6:	49 89 de             	mov    %rbx,%r14
  8007c9:	eb db                	jmp    8007a6 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8007cb:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8007cf:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8007d3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8007da:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8007e0:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8007e4:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8007e9:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8007ef:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8007f5:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8007fa:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8007ff:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800803:	0f b6 13             	movzbl (%rbx),%edx
  800806:	8d 42 dd             	lea    -0x23(%rdx),%eax
  800809:	3c 55                	cmp    $0x55,%al
  80080b:	0f 87 8b 05 00 00    	ja     800d9c <vprintfmt+0x620>
  800811:	0f b6 c0             	movzbl %al,%eax
  800814:	49 bb c0 1e 80 00 00 	movabs $0x801ec0,%r11
  80081b:	00 00 00 
  80081e:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800822:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800825:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  800829:	eb d4                	jmp    8007ff <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80082b:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80082e:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800832:	eb cb                	jmp    8007ff <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800834:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800837:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80083b:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80083f:	8d 50 d0             	lea    -0x30(%rax),%edx
  800842:	83 fa 09             	cmp    $0x9,%edx
  800845:	77 7e                	ja     8008c5 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800847:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80084b:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80084f:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800854:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800858:	8d 50 d0             	lea    -0x30(%rax),%edx
  80085b:	83 fa 09             	cmp    $0x9,%edx
  80085e:	76 e7                	jbe    800847 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800860:	4c 89 f3             	mov    %r14,%rbx
  800863:	eb 19                	jmp    80087e <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800865:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800868:	83 f8 2f             	cmp    $0x2f,%eax
  80086b:	77 2a                	ja     800897 <vprintfmt+0x11b>
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	4c 01 d2             	add    %r10,%rdx
  800872:	83 c0 08             	add    $0x8,%eax
  800875:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800878:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80087b:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80087e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800882:	0f 89 77 ff ff ff    	jns    8007ff <vprintfmt+0x83>
          width = precision, precision = -1;
  800888:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80088c:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  800892:	e9 68 ff ff ff       	jmpq   8007ff <vprintfmt+0x83>
        precision = va_arg(aq, int);
  800897:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80089b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80089f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008a3:	eb d3                	jmp    800878 <vprintfmt+0xfc>
        if (width < 0)
  8008a5:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	41 0f 48 c0          	cmovs  %r8d,%eax
  8008ae:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8008b1:	4c 89 f3             	mov    %r14,%rbx
  8008b4:	e9 46 ff ff ff       	jmpq   8007ff <vprintfmt+0x83>
  8008b9:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8008bc:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8008c0:	e9 3a ff ff ff       	jmpq   8007ff <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8008c5:	4c 89 f3             	mov    %r14,%rbx
  8008c8:	eb b4                	jmp    80087e <vprintfmt+0x102>
        lflag++;
  8008ca:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8008cd:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8008d0:	e9 2a ff ff ff       	jmpq   8007ff <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8008d5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008d8:	83 f8 2f             	cmp    $0x2f,%eax
  8008db:	77 19                	ja     8008f6 <vprintfmt+0x17a>
  8008dd:	89 c2                	mov    %eax,%edx
  8008df:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008e3:	83 c0 08             	add    $0x8,%eax
  8008e6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008e9:	4c 89 fe             	mov    %r15,%rsi
  8008ec:	8b 3a                	mov    (%rdx),%edi
  8008ee:	41 ff d5             	callq  *%r13
        break;
  8008f1:	e9 b0 fe ff ff       	jmpq   8007a6 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8008f6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008fa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008fe:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800902:	eb e5                	jmp    8008e9 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800904:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800907:	83 f8 2f             	cmp    $0x2f,%eax
  80090a:	77 5b                	ja     800967 <vprintfmt+0x1eb>
  80090c:	89 c2                	mov    %eax,%edx
  80090e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800912:	83 c0 08             	add    $0x8,%eax
  800915:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800918:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80091a:	89 c8                	mov    %ecx,%eax
  80091c:	c1 f8 1f             	sar    $0x1f,%eax
  80091f:	31 c1                	xor    %eax,%ecx
  800921:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800923:	83 f9 0b             	cmp    $0xb,%ecx
  800926:	7f 4d                	jg     800975 <vprintfmt+0x1f9>
  800928:	48 63 c1             	movslq %ecx,%rax
  80092b:	48 ba 80 21 80 00 00 	movabs $0x802180,%rdx
  800932:	00 00 00 
  800935:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  800939:	48 85 c0             	test   %rax,%rax
  80093c:	74 37                	je     800975 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80093e:	48 89 c1             	mov    %rax,%rcx
  800941:	48 ba 0c 1e 80 00 00 	movabs $0x801e0c,%rdx
  800948:	00 00 00 
  80094b:	4c 89 fe             	mov    %r15,%rsi
  80094e:	4c 89 ef             	mov    %r13,%rdi
  800951:	b8 00 00 00 00       	mov    $0x0,%eax
  800956:	48 bb f6 06 80 00 00 	movabs $0x8006f6,%rbx
  80095d:	00 00 00 
  800960:	ff d3                	callq  *%rbx
  800962:	e9 3f fe ff ff       	jmpq   8007a6 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800967:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80096b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80096f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800973:	eb a3                	jmp    800918 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800975:	48 ba 03 1e 80 00 00 	movabs $0x801e03,%rdx
  80097c:	00 00 00 
  80097f:	4c 89 fe             	mov    %r15,%rsi
  800982:	4c 89 ef             	mov    %r13,%rdi
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
  80098a:	48 bb f6 06 80 00 00 	movabs $0x8006f6,%rbx
  800991:	00 00 00 
  800994:	ff d3                	callq  *%rbx
  800996:	e9 0b fe ff ff       	jmpq   8007a6 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80099b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80099e:	83 f8 2f             	cmp    $0x2f,%eax
  8009a1:	77 4b                	ja     8009ee <vprintfmt+0x272>
  8009a3:	89 c2                	mov    %eax,%edx
  8009a5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8009a9:	83 c0 08             	add    $0x8,%eax
  8009ac:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8009af:	48 8b 02             	mov    (%rdx),%rax
  8009b2:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8009b6:	48 85 c0             	test   %rax,%rax
  8009b9:	0f 84 05 04 00 00    	je     800dc4 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8009bf:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009c3:	7e 06                	jle    8009cb <vprintfmt+0x24f>
  8009c5:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009c9:	75 31                	jne    8009fc <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009cb:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8009cf:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8009d3:	0f b6 00             	movzbl (%rax),%eax
  8009d6:	0f be f8             	movsbl %al,%edi
  8009d9:	85 ff                	test   %edi,%edi
  8009db:	0f 84 c3 00 00 00    	je     800aa4 <vprintfmt+0x328>
  8009e1:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009e5:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009e9:	e9 85 00 00 00       	jmpq   800a73 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8009ee:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8009f2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8009f6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8009fa:	eb b3                	jmp    8009af <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8009fc:	49 63 f4             	movslq %r12d,%rsi
  8009ff:	48 89 c7             	mov    %rax,%rdi
  800a02:	48 b8 53 0f 80 00 00 	movabs $0x800f53,%rax
  800a09:	00 00 00 
  800a0c:	ff d0                	callq  *%rax
  800a0e:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a11:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800a14:	85 f6                	test   %esi,%esi
  800a16:	7e 22                	jle    800a3a <vprintfmt+0x2be>
            putch(padc, putdat);
  800a18:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  800a1c:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800a20:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800a24:	4c 89 fe             	mov    %r15,%rsi
  800a27:	89 df                	mov    %ebx,%edi
  800a29:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  800a2c:	41 83 ec 01          	sub    $0x1,%r12d
  800a30:	75 f2                	jne    800a24 <vprintfmt+0x2a8>
  800a32:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800a36:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a3a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800a3e:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800a42:	0f b6 00             	movzbl (%rax),%eax
  800a45:	0f be f8             	movsbl %al,%edi
  800a48:	85 ff                	test   %edi,%edi
  800a4a:	0f 84 56 fd ff ff    	je     8007a6 <vprintfmt+0x2a>
  800a50:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a54:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a58:	eb 19                	jmp    800a73 <vprintfmt+0x2f7>
            putch(ch, putdat);
  800a5a:	4c 89 fe             	mov    %r15,%rsi
  800a5d:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a60:	41 83 ee 01          	sub    $0x1,%r14d
  800a64:	48 83 c3 01          	add    $0x1,%rbx
  800a68:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  800a6c:	0f be f8             	movsbl %al,%edi
  800a6f:	85 ff                	test   %edi,%edi
  800a71:	74 29                	je     800a9c <vprintfmt+0x320>
  800a73:	45 85 e4             	test   %r12d,%r12d
  800a76:	78 06                	js     800a7e <vprintfmt+0x302>
  800a78:	41 83 ec 01          	sub    $0x1,%r12d
  800a7c:	78 48                	js     800ac6 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  800a7e:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800a82:	74 d6                	je     800a5a <vprintfmt+0x2de>
  800a84:	0f be c0             	movsbl %al,%eax
  800a87:	83 e8 20             	sub    $0x20,%eax
  800a8a:	83 f8 5e             	cmp    $0x5e,%eax
  800a8d:	76 cb                	jbe    800a5a <vprintfmt+0x2de>
            putch('?', putdat);
  800a8f:	4c 89 fe             	mov    %r15,%rsi
  800a92:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800a97:	41 ff d5             	callq  *%r13
  800a9a:	eb c4                	jmp    800a60 <vprintfmt+0x2e4>
  800a9c:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800aa0:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  800aa4:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  800aa7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800aab:	0f 8e f5 fc ff ff    	jle    8007a6 <vprintfmt+0x2a>
          putch(' ', putdat);
  800ab1:	4c 89 fe             	mov    %r15,%rsi
  800ab4:	bf 20 00 00 00       	mov    $0x20,%edi
  800ab9:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  800abc:	83 eb 01             	sub    $0x1,%ebx
  800abf:	75 f0                	jne    800ab1 <vprintfmt+0x335>
  800ac1:	e9 e0 fc ff ff       	jmpq   8007a6 <vprintfmt+0x2a>
  800ac6:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  800aca:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  800ace:	eb d4                	jmp    800aa4 <vprintfmt+0x328>
  if (lflag >= 2)
  800ad0:	83 f9 01             	cmp    $0x1,%ecx
  800ad3:	7f 1d                	jg     800af2 <vprintfmt+0x376>
  else if (lflag)
  800ad5:	85 c9                	test   %ecx,%ecx
  800ad7:	74 5e                	je     800b37 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  800ad9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800adc:	83 f8 2f             	cmp    $0x2f,%eax
  800adf:	77 48                	ja     800b29 <vprintfmt+0x3ad>
  800ae1:	89 c2                	mov    %eax,%edx
  800ae3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800ae7:	83 c0 08             	add    $0x8,%eax
  800aea:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800aed:	48 8b 1a             	mov    (%rdx),%rbx
  800af0:	eb 17                	jmp    800b09 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800af2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800af5:	83 f8 2f             	cmp    $0x2f,%eax
  800af8:	77 21                	ja     800b1b <vprintfmt+0x39f>
  800afa:	89 c2                	mov    %eax,%edx
  800afc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b00:	83 c0 08             	add    $0x8,%eax
  800b03:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b06:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  800b09:	48 85 db             	test   %rbx,%rbx
  800b0c:	78 50                	js     800b5e <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  800b0e:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800b11:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b16:	e9 b4 01 00 00       	jmpq   800ccf <vprintfmt+0x553>
    return va_arg(*ap, long long);
  800b1b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b1f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b23:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b27:	eb dd                	jmp    800b06 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  800b29:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b2d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b31:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b35:	eb b6                	jmp    800aed <vprintfmt+0x371>
    return va_arg(*ap, int);
  800b37:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b3a:	83 f8 2f             	cmp    $0x2f,%eax
  800b3d:	77 11                	ja     800b50 <vprintfmt+0x3d4>
  800b3f:	89 c2                	mov    %eax,%edx
  800b41:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b45:	83 c0 08             	add    $0x8,%eax
  800b48:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b4b:	48 63 1a             	movslq (%rdx),%rbx
  800b4e:	eb b9                	jmp    800b09 <vprintfmt+0x38d>
  800b50:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800b54:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800b58:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800b5c:	eb ed                	jmp    800b4b <vprintfmt+0x3cf>
          putch('-', putdat);
  800b5e:	4c 89 fe             	mov    %r15,%rsi
  800b61:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800b66:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  800b69:	48 89 da             	mov    %rbx,%rdx
  800b6c:	48 f7 da             	neg    %rdx
        base = 10;
  800b6f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b74:	e9 56 01 00 00       	jmpq   800ccf <vprintfmt+0x553>
  if (lflag >= 2)
  800b79:	83 f9 01             	cmp    $0x1,%ecx
  800b7c:	7f 25                	jg     800ba3 <vprintfmt+0x427>
  else if (lflag)
  800b7e:	85 c9                	test   %ecx,%ecx
  800b80:	74 5e                	je     800be0 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800b82:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800b85:	83 f8 2f             	cmp    $0x2f,%eax
  800b88:	77 48                	ja     800bd2 <vprintfmt+0x456>
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800b90:	83 c0 08             	add    $0x8,%eax
  800b93:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800b96:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800b99:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b9e:	e9 2c 01 00 00       	jmpq   800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800ba3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800ba6:	83 f8 2f             	cmp    $0x2f,%eax
  800ba9:	77 19                	ja     800bc4 <vprintfmt+0x448>
  800bab:	89 c2                	mov    %eax,%edx
  800bad:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bb1:	83 c0 08             	add    $0x8,%eax
  800bb4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bb7:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  800bba:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bbf:	e9 0b 01 00 00       	jmpq   800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800bc4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bc8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bcc:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bd0:	eb e5                	jmp    800bb7 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  800bd2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800bd6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800bda:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800bde:	eb b6                	jmp    800b96 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  800be0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800be3:	83 f8 2f             	cmp    $0x2f,%eax
  800be6:	77 18                	ja     800c00 <vprintfmt+0x484>
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800bee:	83 c0 08             	add    $0x8,%eax
  800bf1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800bf4:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800bf6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800bfb:	e9 cf 00 00 00       	jmpq   800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c00:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c04:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c08:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c0c:	eb e6                	jmp    800bf4 <vprintfmt+0x478>
  if (lflag >= 2)
  800c0e:	83 f9 01             	cmp    $0x1,%ecx
  800c11:	7f 25                	jg     800c38 <vprintfmt+0x4bc>
  else if (lflag)
  800c13:	85 c9                	test   %ecx,%ecx
  800c15:	74 5b                	je     800c72 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800c17:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c1a:	83 f8 2f             	cmp    $0x2f,%eax
  800c1d:	77 45                	ja     800c64 <vprintfmt+0x4e8>
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c25:	83 c0 08             	add    $0x8,%eax
  800c28:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c2b:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c2e:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c33:	e9 97 00 00 00       	jmpq   800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c38:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c3b:	83 f8 2f             	cmp    $0x2f,%eax
  800c3e:	77 16                	ja     800c56 <vprintfmt+0x4da>
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c46:	83 c0 08             	add    $0x8,%eax
  800c49:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c4c:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800c4f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c54:	eb 79                	jmp    800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800c56:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c5a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c5e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c62:	eb e8                	jmp    800c4c <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800c64:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c68:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c6c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c70:	eb b9                	jmp    800c2b <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800c72:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800c75:	83 f8 2f             	cmp    $0x2f,%eax
  800c78:	77 15                	ja     800c8f <vprintfmt+0x513>
  800c7a:	89 c2                	mov    %eax,%edx
  800c7c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800c80:	83 c0 08             	add    $0x8,%eax
  800c83:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800c86:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800c88:	b9 08 00 00 00       	mov    $0x8,%ecx
  800c8d:	eb 40                	jmp    800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800c8f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800c93:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800c97:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800c9b:	eb e9                	jmp    800c86 <vprintfmt+0x50a>
        putch('0', putdat);
  800c9d:	4c 89 fe             	mov    %r15,%rsi
  800ca0:	bf 30 00 00 00       	mov    $0x30,%edi
  800ca5:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  800ca8:	4c 89 fe             	mov    %r15,%rsi
  800cab:	bf 78 00 00 00       	mov    $0x78,%edi
  800cb0:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cb3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800cb6:	83 f8 2f             	cmp    $0x2f,%eax
  800cb9:	77 34                	ja     800cef <vprintfmt+0x573>
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800cc1:	83 c0 08             	add    $0x8,%eax
  800cc4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800cc7:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800cca:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  800ccf:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  800cd4:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  800cd8:	4c 89 fe             	mov    %r15,%rsi
  800cdb:	4c 89 ef             	mov    %r13,%rdi
  800cde:	48 b8 52 06 80 00 00 	movabs $0x800652,%rax
  800ce5:	00 00 00 
  800ce8:	ff d0                	callq  *%rax
        break;
  800cea:	e9 b7 fa ff ff       	jmpq   8007a6 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800cef:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800cf3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800cf7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800cfb:	eb ca                	jmp    800cc7 <vprintfmt+0x54b>
  if (lflag >= 2)
  800cfd:	83 f9 01             	cmp    $0x1,%ecx
  800d00:	7f 22                	jg     800d24 <vprintfmt+0x5a8>
  else if (lflag)
  800d02:	85 c9                	test   %ecx,%ecx
  800d04:	74 58                	je     800d5e <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800d06:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d09:	83 f8 2f             	cmp    $0x2f,%eax
  800d0c:	77 42                	ja     800d50 <vprintfmt+0x5d4>
  800d0e:	89 c2                	mov    %eax,%edx
  800d10:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d14:	83 c0 08             	add    $0x8,%eax
  800d17:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d1a:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d1d:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d22:	eb ab                	jmp    800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d24:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d27:	83 f8 2f             	cmp    $0x2f,%eax
  800d2a:	77 16                	ja     800d42 <vprintfmt+0x5c6>
  800d2c:	89 c2                	mov    %eax,%edx
  800d2e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d32:	83 c0 08             	add    $0x8,%eax
  800d35:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d38:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  800d3b:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d40:	eb 8d                	jmp    800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800d42:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d46:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d4a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d4e:	eb e8                	jmp    800d38 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800d50:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d54:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d58:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d5c:	eb bc                	jmp    800d1a <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  800d5e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800d61:	83 f8 2f             	cmp    $0x2f,%eax
  800d64:	77 18                	ja     800d7e <vprintfmt+0x602>
  800d66:	89 c2                	mov    %eax,%edx
  800d68:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800d6c:	83 c0 08             	add    $0x8,%eax
  800d6f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800d72:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800d74:	b9 10 00 00 00       	mov    $0x10,%ecx
  800d79:	e9 51 ff ff ff       	jmpq   800ccf <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800d7e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800d82:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800d86:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800d8a:	eb e6                	jmp    800d72 <vprintfmt+0x5f6>
        putch(ch, putdat);
  800d8c:	4c 89 fe             	mov    %r15,%rsi
  800d8f:	bf 25 00 00 00       	mov    $0x25,%edi
  800d94:	41 ff d5             	callq  *%r13
        break;
  800d97:	e9 0a fa ff ff       	jmpq   8007a6 <vprintfmt+0x2a>
        putch('%', putdat);
  800d9c:	4c 89 fe             	mov    %r15,%rsi
  800d9f:	bf 25 00 00 00       	mov    $0x25,%edi
  800da4:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  800da7:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  800dab:	0f 84 15 fa ff ff    	je     8007c6 <vprintfmt+0x4a>
  800db1:	49 89 de             	mov    %rbx,%r14
  800db4:	49 83 ee 01          	sub    $0x1,%r14
  800db8:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  800dbd:	75 f5                	jne    800db4 <vprintfmt+0x638>
  800dbf:	e9 e2 f9 ff ff       	jmpq   8007a6 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  800dc4:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  800dc8:	74 06                	je     800dd0 <vprintfmt+0x654>
  800dca:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800dce:	7f 21                	jg     800df1 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dd0:	bf 28 00 00 00       	mov    $0x28,%edi
  800dd5:	48 bb fd 1d 80 00 00 	movabs $0x801dfd,%rbx
  800ddc:	00 00 00 
  800ddf:	b8 28 00 00 00       	mov    $0x28,%eax
  800de4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800de8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800dec:	e9 82 fc ff ff       	jmpq   800a73 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800df1:	49 63 f4             	movslq %r12d,%rsi
  800df4:	48 bf fc 1d 80 00 00 	movabs $0x801dfc,%rdi
  800dfb:	00 00 00 
  800dfe:	48 b8 53 0f 80 00 00 	movabs $0x800f53,%rax
  800e05:	00 00 00 
  800e08:	ff d0                	callq  *%rax
  800e0a:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800e0d:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800e10:	48 be fc 1d 80 00 00 	movabs $0x801dfc,%rsi
  800e17:	00 00 00 
  800e1a:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	0f 8f f2 fb ff ff    	jg     800a18 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e26:	48 bb fd 1d 80 00 00 	movabs $0x801dfd,%rbx
  800e2d:	00 00 00 
  800e30:	b8 28 00 00 00       	mov    $0x28,%eax
  800e35:	bf 28 00 00 00       	mov    $0x28,%edi
  800e3a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800e3e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800e42:	e9 2c fc ff ff       	jmpq   800a73 <vprintfmt+0x2f7>
}
  800e47:	48 83 c4 48          	add    $0x48,%rsp
  800e4b:	5b                   	pop    %rbx
  800e4c:	41 5c                	pop    %r12
  800e4e:	41 5d                	pop    %r13
  800e50:	41 5e                	pop    %r14
  800e52:	41 5f                	pop    %r15
  800e54:	5d                   	pop    %rbp
  800e55:	c3                   	retq   

0000000000800e56 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800e56:	55                   	push   %rbp
  800e57:	48 89 e5             	mov    %rsp,%rbp
  800e5a:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800e5e:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800e62:	48 63 c6             	movslq %esi,%rax
  800e65:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800e6a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800e6e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800e75:	48 85 ff             	test   %rdi,%rdi
  800e78:	74 2a                	je     800ea4 <vsnprintf+0x4e>
  800e7a:	85 f6                	test   %esi,%esi
  800e7c:	7e 26                	jle    800ea4 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800e7e:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800e82:	48 bf de 06 80 00 00 	movabs $0x8006de,%rdi
  800e89:	00 00 00 
  800e8c:	48 b8 7c 07 80 00 00 	movabs $0x80077c,%rax
  800e93:	00 00 00 
  800e96:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800e98:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800e9c:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800e9f:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ea2:	c9                   	leaveq 
  800ea3:	c3                   	retq   
    return -E_INVAL;
  800ea4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea9:	eb f7                	jmp    800ea2 <vsnprintf+0x4c>

0000000000800eab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800eab:	55                   	push   %rbp
  800eac:	48 89 e5             	mov    %rsp,%rbp
  800eaf:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800eb6:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ebd:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ec4:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800ecb:	84 c0                	test   %al,%al
  800ecd:	74 20                	je     800eef <snprintf+0x44>
  800ecf:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ed3:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800ed7:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800edb:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800edf:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800ee3:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800ee7:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800eeb:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800eef:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800ef6:	00 00 00 
  800ef9:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f00:	00 00 00 
  800f03:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f07:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f0e:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f15:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800f1c:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800f23:	48 b8 56 0e 80 00 00 	movabs $0x800e56,%rax
  800f2a:	00 00 00 
  800f2d:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800f2f:	c9                   	leaveq 
  800f30:	c3                   	retq   

0000000000800f31 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800f31:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f34:	74 17                	je     800f4d <strlen+0x1c>
  800f36:	48 89 fa             	mov    %rdi,%rdx
  800f39:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f3e:	29 f9                	sub    %edi,%ecx
    n++;
  800f40:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800f43:	48 83 c2 01          	add    $0x1,%rdx
  800f47:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f4a:	75 f4                	jne    800f40 <strlen+0xf>
  800f4c:	c3                   	retq   
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f52:	c3                   	retq   

0000000000800f53 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f53:	48 85 f6             	test   %rsi,%rsi
  800f56:	74 24                	je     800f7c <strnlen+0x29>
  800f58:	80 3f 00             	cmpb   $0x0,(%rdi)
  800f5b:	74 25                	je     800f82 <strnlen+0x2f>
  800f5d:	48 01 fe             	add    %rdi,%rsi
  800f60:	48 89 fa             	mov    %rdi,%rdx
  800f63:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f68:	29 f9                	sub    %edi,%ecx
    n++;
  800f6a:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f6d:	48 83 c2 01          	add    $0x1,%rdx
  800f71:	48 39 f2             	cmp    %rsi,%rdx
  800f74:	74 11                	je     800f87 <strnlen+0x34>
  800f76:	80 3a 00             	cmpb   $0x0,(%rdx)
  800f79:	75 ef                	jne    800f6a <strnlen+0x17>
  800f7b:	c3                   	retq   
  800f7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f81:	c3                   	retq   
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800f87:	c3                   	retq   

0000000000800f88 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800f88:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800f8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f90:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800f94:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800f97:	48 83 c2 01          	add    $0x1,%rdx
  800f9b:	84 c9                	test   %cl,%cl
  800f9d:	75 f1                	jne    800f90 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800f9f:	c3                   	retq   

0000000000800fa0 <strcat>:

char *
strcat(char *dst, const char *src) {
  800fa0:	55                   	push   %rbp
  800fa1:	48 89 e5             	mov    %rsp,%rbp
  800fa4:	41 54                	push   %r12
  800fa6:	53                   	push   %rbx
  800fa7:	48 89 fb             	mov    %rdi,%rbx
  800faa:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800fad:	48 b8 31 0f 80 00 00 	movabs $0x800f31,%rax
  800fb4:	00 00 00 
  800fb7:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800fb9:	48 63 f8             	movslq %eax,%rdi
  800fbc:	48 01 df             	add    %rbx,%rdi
  800fbf:	4c 89 e6             	mov    %r12,%rsi
  800fc2:	48 b8 88 0f 80 00 00 	movabs $0x800f88,%rax
  800fc9:	00 00 00 
  800fcc:	ff d0                	callq  *%rax
  return dst;
}
  800fce:	48 89 d8             	mov    %rbx,%rax
  800fd1:	5b                   	pop    %rbx
  800fd2:	41 5c                	pop    %r12
  800fd4:	5d                   	pop    %rbp
  800fd5:	c3                   	retq   

0000000000800fd6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800fd6:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800fd9:	48 85 d2             	test   %rdx,%rdx
  800fdc:	74 1f                	je     800ffd <strncpy+0x27>
  800fde:	48 01 fa             	add    %rdi,%rdx
  800fe1:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800fe4:	48 83 c1 01          	add    $0x1,%rcx
  800fe8:	44 0f b6 06          	movzbl (%rsi),%r8d
  800fec:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800ff0:	41 80 f8 01          	cmp    $0x1,%r8b
  800ff4:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800ff8:	48 39 ca             	cmp    %rcx,%rdx
  800ffb:	75 e7                	jne    800fe4 <strncpy+0xe>
  }
  return ret;
}
  800ffd:	c3                   	retq   

0000000000800ffe <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800ffe:	48 89 f8             	mov    %rdi,%rax
  801001:	48 85 d2             	test   %rdx,%rdx
  801004:	74 36                	je     80103c <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  801006:	48 83 fa 01          	cmp    $0x1,%rdx
  80100a:	74 2d                	je     801039 <strlcpy+0x3b>
  80100c:	44 0f b6 06          	movzbl (%rsi),%r8d
  801010:	45 84 c0             	test   %r8b,%r8b
  801013:	74 24                	je     801039 <strlcpy+0x3b>
  801015:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  801019:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  80101e:	48 83 c0 01          	add    $0x1,%rax
  801022:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  801026:	48 39 d1             	cmp    %rdx,%rcx
  801029:	74 0e                	je     801039 <strlcpy+0x3b>
  80102b:	48 83 c1 01          	add    $0x1,%rcx
  80102f:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  801034:	45 84 c0             	test   %r8b,%r8b
  801037:	75 e5                	jne    80101e <strlcpy+0x20>
    *dst = '\0';
  801039:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  80103c:	48 29 f8             	sub    %rdi,%rax
}
  80103f:	c3                   	retq   

0000000000801040 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801040:	0f b6 07             	movzbl (%rdi),%eax
  801043:	84 c0                	test   %al,%al
  801045:	74 17                	je     80105e <strcmp+0x1e>
  801047:	3a 06                	cmp    (%rsi),%al
  801049:	75 13                	jne    80105e <strcmp+0x1e>
    p++, q++;
  80104b:	48 83 c7 01          	add    $0x1,%rdi
  80104f:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  801053:	0f b6 07             	movzbl (%rdi),%eax
  801056:	84 c0                	test   %al,%al
  801058:	74 04                	je     80105e <strcmp+0x1e>
  80105a:	3a 06                	cmp    (%rsi),%al
  80105c:	74 ed                	je     80104b <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  80105e:	0f b6 c0             	movzbl %al,%eax
  801061:	0f b6 16             	movzbl (%rsi),%edx
  801064:	29 d0                	sub    %edx,%eax
}
  801066:	c3                   	retq   

0000000000801067 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  801067:	48 85 d2             	test   %rdx,%rdx
  80106a:	74 2f                	je     80109b <strncmp+0x34>
  80106c:	0f b6 07             	movzbl (%rdi),%eax
  80106f:	84 c0                	test   %al,%al
  801071:	74 1f                	je     801092 <strncmp+0x2b>
  801073:	3a 06                	cmp    (%rsi),%al
  801075:	75 1b                	jne    801092 <strncmp+0x2b>
  801077:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  80107a:	48 83 c7 01          	add    $0x1,%rdi
  80107e:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  801082:	48 39 d7             	cmp    %rdx,%rdi
  801085:	74 1a                	je     8010a1 <strncmp+0x3a>
  801087:	0f b6 07             	movzbl (%rdi),%eax
  80108a:	84 c0                	test   %al,%al
  80108c:	74 04                	je     801092 <strncmp+0x2b>
  80108e:	3a 06                	cmp    (%rsi),%al
  801090:	74 e8                	je     80107a <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  801092:	0f b6 07             	movzbl (%rdi),%eax
  801095:	0f b6 16             	movzbl (%rsi),%edx
  801098:	29 d0                	sub    %edx,%eax
}
  80109a:	c3                   	retq   
    return 0;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	c3                   	retq   
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a6:	c3                   	retq   

00000000008010a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8010a7:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8010a9:	0f b6 07             	movzbl (%rdi),%eax
  8010ac:	84 c0                	test   %al,%al
  8010ae:	74 1e                	je     8010ce <strchr+0x27>
    if (*s == c)
  8010b0:	40 38 c6             	cmp    %al,%sil
  8010b3:	74 1f                	je     8010d4 <strchr+0x2d>
  for (; *s; s++)
  8010b5:	48 83 c7 01          	add    $0x1,%rdi
  8010b9:	0f b6 07             	movzbl (%rdi),%eax
  8010bc:	84 c0                	test   %al,%al
  8010be:	74 08                	je     8010c8 <strchr+0x21>
    if (*s == c)
  8010c0:	38 d0                	cmp    %dl,%al
  8010c2:	75 f1                	jne    8010b5 <strchr+0xe>
  for (; *s; s++)
  8010c4:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8010c7:	c3                   	retq   
  return 0;
  8010c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cd:	c3                   	retq   
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d3:	c3                   	retq   
    if (*s == c)
  8010d4:	48 89 f8             	mov    %rdi,%rax
  8010d7:	c3                   	retq   

00000000008010d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  8010d8:	48 89 f8             	mov    %rdi,%rax
  8010db:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  8010dd:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  8010e0:	40 38 f2             	cmp    %sil,%dl
  8010e3:	74 13                	je     8010f8 <strfind+0x20>
  8010e5:	84 d2                	test   %dl,%dl
  8010e7:	74 0f                	je     8010f8 <strfind+0x20>
  for (; *s; s++)
  8010e9:	48 83 c0 01          	add    $0x1,%rax
  8010ed:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  8010f0:	38 ca                	cmp    %cl,%dl
  8010f2:	74 04                	je     8010f8 <strfind+0x20>
  8010f4:	84 d2                	test   %dl,%dl
  8010f6:	75 f1                	jne    8010e9 <strfind+0x11>
      break;
  return (char *)s;
}
  8010f8:	c3                   	retq   

00000000008010f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  8010f9:	48 85 d2             	test   %rdx,%rdx
  8010fc:	74 3a                	je     801138 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8010fe:	48 89 f8             	mov    %rdi,%rax
  801101:	48 09 d0             	or     %rdx,%rax
  801104:	a8 03                	test   $0x3,%al
  801106:	75 28                	jne    801130 <memset+0x37>
    uint32_t k = c & 0xFFU;
  801108:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	c1 e0 08             	shl    $0x8,%eax
  801111:	89 f1                	mov    %esi,%ecx
  801113:	c1 e1 18             	shl    $0x18,%ecx
  801116:	41 89 f0             	mov    %esi,%r8d
  801119:	41 c1 e0 10          	shl    $0x10,%r8d
  80111d:	44 09 c1             	or     %r8d,%ecx
  801120:	09 ce                	or     %ecx,%esi
  801122:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  801124:	48 c1 ea 02          	shr    $0x2,%rdx
  801128:	48 89 d1             	mov    %rdx,%rcx
  80112b:	fc                   	cld    
  80112c:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80112e:	eb 08                	jmp    801138 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801130:	89 f0                	mov    %esi,%eax
  801132:	48 89 d1             	mov    %rdx,%rcx
  801135:	fc                   	cld    
  801136:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  801138:	48 89 f8             	mov    %rdi,%rax
  80113b:	c3                   	retq   

000000000080113c <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  80113c:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  80113f:	48 39 fe             	cmp    %rdi,%rsi
  801142:	73 40                	jae    801184 <memmove+0x48>
  801144:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  801148:	48 39 f9             	cmp    %rdi,%rcx
  80114b:	76 37                	jbe    801184 <memmove+0x48>
    s += n;
    d += n;
  80114d:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801151:	48 89 fe             	mov    %rdi,%rsi
  801154:	48 09 d6             	or     %rdx,%rsi
  801157:	48 09 ce             	or     %rcx,%rsi
  80115a:	40 f6 c6 03          	test   $0x3,%sil
  80115e:	75 14                	jne    801174 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  801160:	48 83 ef 04          	sub    $0x4,%rdi
  801164:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  801168:	48 c1 ea 02          	shr    $0x2,%rdx
  80116c:	48 89 d1             	mov    %rdx,%rcx
  80116f:	fd                   	std    
  801170:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  801172:	eb 0e                	jmp    801182 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  801174:	48 83 ef 01          	sub    $0x1,%rdi
  801178:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  80117c:	48 89 d1             	mov    %rdx,%rcx
  80117f:	fd                   	std    
  801180:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  801182:	fc                   	cld    
  801183:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801184:	48 89 c1             	mov    %rax,%rcx
  801187:	48 09 d1             	or     %rdx,%rcx
  80118a:	48 09 f1             	or     %rsi,%rcx
  80118d:	f6 c1 03             	test   $0x3,%cl
  801190:	75 0e                	jne    8011a0 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  801192:	48 c1 ea 02          	shr    $0x2,%rdx
  801196:	48 89 d1             	mov    %rdx,%rcx
  801199:	48 89 c7             	mov    %rax,%rdi
  80119c:	fc                   	cld    
  80119d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80119f:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8011a0:	48 89 c7             	mov    %rax,%rdi
  8011a3:	48 89 d1             	mov    %rdx,%rcx
  8011a6:	fc                   	cld    
  8011a7:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8011a9:	c3                   	retq   

00000000008011aa <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8011aa:	55                   	push   %rbp
  8011ab:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8011ae:	48 b8 3c 11 80 00 00 	movabs $0x80113c,%rax
  8011b5:	00 00 00 
  8011b8:	ff d0                	callq  *%rax
}
  8011ba:	5d                   	pop    %rbp
  8011bb:	c3                   	retq   

00000000008011bc <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8011bc:	55                   	push   %rbp
  8011bd:	48 89 e5             	mov    %rsp,%rbp
  8011c0:	41 57                	push   %r15
  8011c2:	41 56                	push   %r14
  8011c4:	41 55                	push   %r13
  8011c6:	41 54                	push   %r12
  8011c8:	53                   	push   %rbx
  8011c9:	48 83 ec 08          	sub    $0x8,%rsp
  8011cd:	49 89 fe             	mov    %rdi,%r14
  8011d0:	49 89 f7             	mov    %rsi,%r15
  8011d3:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  8011d6:	48 89 f7             	mov    %rsi,%rdi
  8011d9:	48 b8 31 0f 80 00 00 	movabs $0x800f31,%rax
  8011e0:	00 00 00 
  8011e3:	ff d0                	callq  *%rax
  8011e5:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  8011e8:	4c 89 ee             	mov    %r13,%rsi
  8011eb:	4c 89 f7             	mov    %r14,%rdi
  8011ee:	48 b8 53 0f 80 00 00 	movabs $0x800f53,%rax
  8011f5:	00 00 00 
  8011f8:	ff d0                	callq  *%rax
  8011fa:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  8011fd:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801201:	4d 39 e5             	cmp    %r12,%r13
  801204:	74 26                	je     80122c <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801206:	4c 89 e8             	mov    %r13,%rax
  801209:	4c 29 e0             	sub    %r12,%rax
  80120c:	48 39 d8             	cmp    %rbx,%rax
  80120f:	76 2a                	jbe    80123b <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801211:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801215:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801219:	4c 89 fe             	mov    %r15,%rsi
  80121c:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  801223:	00 00 00 
  801226:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801228:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  80122c:	48 83 c4 08          	add    $0x8,%rsp
  801230:	5b                   	pop    %rbx
  801231:	41 5c                	pop    %r12
  801233:	41 5d                	pop    %r13
  801235:	41 5e                	pop    %r14
  801237:	41 5f                	pop    %r15
  801239:	5d                   	pop    %rbp
  80123a:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80123b:	49 83 ed 01          	sub    $0x1,%r13
  80123f:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801243:	4c 89 ea             	mov    %r13,%rdx
  801246:	4c 89 fe             	mov    %r15,%rsi
  801249:	48 b8 aa 11 80 00 00 	movabs $0x8011aa,%rax
  801250:	00 00 00 
  801253:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801255:	4d 01 ee             	add    %r13,%r14
  801258:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80125d:	eb c9                	jmp    801228 <strlcat+0x6c>

000000000080125f <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80125f:	48 85 d2             	test   %rdx,%rdx
  801262:	74 3a                	je     80129e <memcmp+0x3f>
    if (*s1 != *s2)
  801264:	0f b6 0f             	movzbl (%rdi),%ecx
  801267:	44 0f b6 06          	movzbl (%rsi),%r8d
  80126b:	44 38 c1             	cmp    %r8b,%cl
  80126e:	75 1d                	jne    80128d <memcmp+0x2e>
  801270:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801275:	48 39 d0             	cmp    %rdx,%rax
  801278:	74 1e                	je     801298 <memcmp+0x39>
    if (*s1 != *s2)
  80127a:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80127e:	48 83 c0 01          	add    $0x1,%rax
  801282:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801288:	44 38 c1             	cmp    %r8b,%cl
  80128b:	74 e8                	je     801275 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80128d:	0f b6 c1             	movzbl %cl,%eax
  801290:	45 0f b6 c0          	movzbl %r8b,%r8d
  801294:	44 29 c0             	sub    %r8d,%eax
  801297:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801298:	b8 00 00 00 00       	mov    $0x0,%eax
  80129d:	c3                   	retq   
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a3:	c3                   	retq   

00000000008012a4 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8012a4:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8012a8:	48 39 c7             	cmp    %rax,%rdi
  8012ab:	73 19                	jae    8012c6 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012ad:	89 f2                	mov    %esi,%edx
  8012af:	40 38 37             	cmp    %sil,(%rdi)
  8012b2:	74 16                	je     8012ca <memfind+0x26>
  for (; s < ends; s++)
  8012b4:	48 83 c7 01          	add    $0x1,%rdi
  8012b8:	48 39 f8             	cmp    %rdi,%rax
  8012bb:	74 08                	je     8012c5 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8012bd:	38 17                	cmp    %dl,(%rdi)
  8012bf:	75 f3                	jne    8012b4 <memfind+0x10>
  for (; s < ends; s++)
  8012c1:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8012c4:	c3                   	retq   
  8012c5:	c3                   	retq   
  for (; s < ends; s++)
  8012c6:	48 89 f8             	mov    %rdi,%rax
  8012c9:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8012ca:	48 89 f8             	mov    %rdi,%rax
  8012cd:	c3                   	retq   

00000000008012ce <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8012ce:	0f b6 07             	movzbl (%rdi),%eax
  8012d1:	3c 20                	cmp    $0x20,%al
  8012d3:	74 04                	je     8012d9 <strtol+0xb>
  8012d5:	3c 09                	cmp    $0x9,%al
  8012d7:	75 0f                	jne    8012e8 <strtol+0x1a>
    s++;
  8012d9:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  8012dd:	0f b6 07             	movzbl (%rdi),%eax
  8012e0:	3c 20                	cmp    $0x20,%al
  8012e2:	74 f5                	je     8012d9 <strtol+0xb>
  8012e4:	3c 09                	cmp    $0x9,%al
  8012e6:	74 f1                	je     8012d9 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8012e8:	3c 2b                	cmp    $0x2b,%al
  8012ea:	74 2b                	je     801317 <strtol+0x49>
  int neg  = 0;
  8012ec:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8012f2:	3c 2d                	cmp    $0x2d,%al
  8012f4:	74 2d                	je     801323 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012f6:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8012fc:	75 0f                	jne    80130d <strtol+0x3f>
  8012fe:	80 3f 30             	cmpb   $0x30,(%rdi)
  801301:	74 2c                	je     80132f <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801303:	85 d2                	test   %edx,%edx
  801305:	b8 0a 00 00 00       	mov    $0xa,%eax
  80130a:	0f 44 d0             	cmove  %eax,%edx
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801312:	4c 63 d2             	movslq %edx,%r10
  801315:	eb 5c                	jmp    801373 <strtol+0xa5>
    s++;
  801317:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80131b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801321:	eb d3                	jmp    8012f6 <strtol+0x28>
    s++, neg = 1;
  801323:	48 83 c7 01          	add    $0x1,%rdi
  801327:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80132d:	eb c7                	jmp    8012f6 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80132f:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801333:	74 0f                	je     801344 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801335:	85 d2                	test   %edx,%edx
  801337:	75 d4                	jne    80130d <strtol+0x3f>
    s++, base = 8;
  801339:	48 83 c7 01          	add    $0x1,%rdi
  80133d:	ba 08 00 00 00       	mov    $0x8,%edx
  801342:	eb c9                	jmp    80130d <strtol+0x3f>
    s += 2, base = 16;
  801344:	48 83 c7 02          	add    $0x2,%rdi
  801348:	ba 10 00 00 00       	mov    $0x10,%edx
  80134d:	eb be                	jmp    80130d <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  80134f:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801353:	41 80 f8 19          	cmp    $0x19,%r8b
  801357:	77 2f                	ja     801388 <strtol+0xba>
      dig = *s - 'a' + 10;
  801359:	44 0f be c1          	movsbl %cl,%r8d
  80135d:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801361:	39 d1                	cmp    %edx,%ecx
  801363:	7d 37                	jge    80139c <strtol+0xce>
    s++, val = (val * base) + dig;
  801365:	48 83 c7 01          	add    $0x1,%rdi
  801369:	49 0f af c2          	imul   %r10,%rax
  80136d:	48 63 c9             	movslq %ecx,%rcx
  801370:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801373:	0f b6 0f             	movzbl (%rdi),%ecx
  801376:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80137a:	41 80 f8 09          	cmp    $0x9,%r8b
  80137e:	77 cf                	ja     80134f <strtol+0x81>
      dig = *s - '0';
  801380:	0f be c9             	movsbl %cl,%ecx
  801383:	83 e9 30             	sub    $0x30,%ecx
  801386:	eb d9                	jmp    801361 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801388:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80138c:	41 80 f8 19          	cmp    $0x19,%r8b
  801390:	77 0a                	ja     80139c <strtol+0xce>
      dig = *s - 'A' + 10;
  801392:	44 0f be c1          	movsbl %cl,%r8d
  801396:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80139a:	eb c5                	jmp    801361 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80139c:	48 85 f6             	test   %rsi,%rsi
  80139f:	74 03                	je     8013a4 <strtol+0xd6>
    *endptr = (char *)s;
  8013a1:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8013a4:	48 89 c2             	mov    %rax,%rdx
  8013a7:	48 f7 da             	neg    %rdx
  8013aa:	45 85 c9             	test   %r9d,%r9d
  8013ad:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8013b1:	c3                   	retq   

00000000008013b2 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  8013b2:	55                   	push   %rbp
  8013b3:	48 89 e5             	mov    %rsp,%rbp
  8013b6:	53                   	push   %rbx
  8013b7:	48 89 fa             	mov    %rdi,%rdx
  8013ba:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	48 89 c3             	mov    %rax,%rbx
  8013c5:	48 89 c7             	mov    %rax,%rdi
  8013c8:	48 89 c6             	mov    %rax,%rsi
  8013cb:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  8013cd:	5b                   	pop    %rbx
  8013ce:	5d                   	pop    %rbp
  8013cf:	c3                   	retq   

00000000008013d0 <sys_cgetc>:

int
sys_cgetc(void) {
  8013d0:	55                   	push   %rbp
  8013d1:	48 89 e5             	mov    %rsp,%rbp
  8013d4:	53                   	push   %rbx
  asm volatile("int %1\n"
  8013d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013da:	b8 01 00 00 00       	mov    $0x1,%eax
  8013df:	48 89 ca             	mov    %rcx,%rdx
  8013e2:	48 89 cb             	mov    %rcx,%rbx
  8013e5:	48 89 cf             	mov    %rcx,%rdi
  8013e8:	48 89 ce             	mov    %rcx,%rsi
  8013eb:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8013ed:	5b                   	pop    %rbx
  8013ee:	5d                   	pop    %rbp
  8013ef:	c3                   	retq   

00000000008013f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  8013f0:	55                   	push   %rbp
  8013f1:	48 89 e5             	mov    %rsp,%rbp
  8013f4:	53                   	push   %rbx
  8013f5:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8013f9:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  8013fc:	be 00 00 00 00       	mov    $0x0,%esi
  801401:	b8 03 00 00 00       	mov    $0x3,%eax
  801406:	48 89 f1             	mov    %rsi,%rcx
  801409:	48 89 f3             	mov    %rsi,%rbx
  80140c:	48 89 f7             	mov    %rsi,%rdi
  80140f:	cd 30                	int    $0x30
  if (check && ret > 0)
  801411:	48 85 c0             	test   %rax,%rax
  801414:	7f 07                	jg     80141d <sys_env_destroy+0x2d>
}
  801416:	48 83 c4 08          	add    $0x8,%rsp
  80141a:	5b                   	pop    %rbx
  80141b:	5d                   	pop    %rbp
  80141c:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80141d:	49 89 c0             	mov    %rax,%r8
  801420:	b9 03 00 00 00       	mov    $0x3,%ecx
  801425:	48 ba e0 21 80 00 00 	movabs $0x8021e0,%rdx
  80142c:	00 00 00 
  80142f:	be 22 00 00 00       	mov    $0x22,%esi
  801434:	48 bf ff 21 80 00 00 	movabs $0x8021ff,%rdi
  80143b:	00 00 00 
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
  801443:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  80144a:	00 00 00 
  80144d:	41 ff d1             	callq  *%r9

0000000000801450 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801450:	55                   	push   %rbp
  801451:	48 89 e5             	mov    %rsp,%rbp
  801454:	53                   	push   %rbx
  asm volatile("int %1\n"
  801455:	b9 00 00 00 00       	mov    $0x0,%ecx
  80145a:	b8 02 00 00 00       	mov    $0x2,%eax
  80145f:	48 89 ca             	mov    %rcx,%rdx
  801462:	48 89 cb             	mov    %rcx,%rbx
  801465:	48 89 cf             	mov    %rcx,%rdi
  801468:	48 89 ce             	mov    %rcx,%rsi
  80146b:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80146d:	5b                   	pop    %rbx
  80146e:	5d                   	pop    %rbp
  80146f:	c3                   	retq   

0000000000801470 <sys_yield>:

void
sys_yield(void) {
  801470:	55                   	push   %rbp
  801471:	48 89 e5             	mov    %rsp,%rbp
  801474:	53                   	push   %rbx
  asm volatile("int %1\n"
  801475:	b9 00 00 00 00       	mov    $0x0,%ecx
  80147a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80147f:	48 89 ca             	mov    %rcx,%rdx
  801482:	48 89 cb             	mov    %rcx,%rbx
  801485:	48 89 cf             	mov    %rcx,%rdi
  801488:	48 89 ce             	mov    %rcx,%rsi
  80148b:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80148d:	5b                   	pop    %rbx
  80148e:	5d                   	pop    %rbp
  80148f:	c3                   	retq   

0000000000801490 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  801490:	55                   	push   %rbp
  801491:	48 89 e5             	mov    %rsp,%rbp
  801494:	53                   	push   %rbx
  801495:	48 83 ec 08          	sub    $0x8,%rsp
  801499:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  80149c:	4c 63 c7             	movslq %edi,%r8
  80149f:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8014a2:	be 00 00 00 00       	mov    $0x0,%esi
  8014a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ac:	4c 89 c2             	mov    %r8,%rdx
  8014af:	48 89 f7             	mov    %rsi,%rdi
  8014b2:	cd 30                	int    $0x30
  if (check && ret > 0)
  8014b4:	48 85 c0             	test   %rax,%rax
  8014b7:	7f 07                	jg     8014c0 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8014b9:	48 83 c4 08          	add    $0x8,%rsp
  8014bd:	5b                   	pop    %rbx
  8014be:	5d                   	pop    %rbp
  8014bf:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8014c0:	49 89 c0             	mov    %rax,%r8
  8014c3:	b9 04 00 00 00       	mov    $0x4,%ecx
  8014c8:	48 ba e0 21 80 00 00 	movabs $0x8021e0,%rdx
  8014cf:	00 00 00 
  8014d2:	be 22 00 00 00       	mov    $0x22,%esi
  8014d7:	48 bf ff 21 80 00 00 	movabs $0x8021ff,%rdi
  8014de:	00 00 00 
  8014e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e6:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  8014ed:	00 00 00 
  8014f0:	41 ff d1             	callq  *%r9

00000000008014f3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  8014f3:	55                   	push   %rbp
  8014f4:	48 89 e5             	mov    %rsp,%rbp
  8014f7:	53                   	push   %rbx
  8014f8:	48 83 ec 08          	sub    $0x8,%rsp
  8014fc:	41 89 f9             	mov    %edi,%r9d
  8014ff:	49 89 f2             	mov    %rsi,%r10
  801502:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801505:	4d 63 c9             	movslq %r9d,%r9
  801508:	48 63 da             	movslq %edx,%rbx
  80150b:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80150e:	b8 05 00 00 00       	mov    $0x5,%eax
  801513:	4c 89 ca             	mov    %r9,%rdx
  801516:	4c 89 d1             	mov    %r10,%rcx
  801519:	cd 30                	int    $0x30
  if (check && ret > 0)
  80151b:	48 85 c0             	test   %rax,%rax
  80151e:	7f 07                	jg     801527 <sys_page_map+0x34>
}
  801520:	48 83 c4 08          	add    $0x8,%rsp
  801524:	5b                   	pop    %rbx
  801525:	5d                   	pop    %rbp
  801526:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801527:	49 89 c0             	mov    %rax,%r8
  80152a:	b9 05 00 00 00       	mov    $0x5,%ecx
  80152f:	48 ba e0 21 80 00 00 	movabs $0x8021e0,%rdx
  801536:	00 00 00 
  801539:	be 22 00 00 00       	mov    $0x22,%esi
  80153e:	48 bf ff 21 80 00 00 	movabs $0x8021ff,%rdi
  801545:	00 00 00 
  801548:	b8 00 00 00 00       	mov    $0x0,%eax
  80154d:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  801554:	00 00 00 
  801557:	41 ff d1             	callq  *%r9

000000000080155a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80155a:	55                   	push   %rbp
  80155b:	48 89 e5             	mov    %rsp,%rbp
  80155e:	53                   	push   %rbx
  80155f:	48 83 ec 08          	sub    $0x8,%rsp
  801563:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801566:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801569:	be 00 00 00 00       	mov    $0x0,%esi
  80156e:	b8 06 00 00 00       	mov    $0x6,%eax
  801573:	48 89 f3             	mov    %rsi,%rbx
  801576:	48 89 f7             	mov    %rsi,%rdi
  801579:	cd 30                	int    $0x30
  if (check && ret > 0)
  80157b:	48 85 c0             	test   %rax,%rax
  80157e:	7f 07                	jg     801587 <sys_page_unmap+0x2d>
}
  801580:	48 83 c4 08          	add    $0x8,%rsp
  801584:	5b                   	pop    %rbx
  801585:	5d                   	pop    %rbp
  801586:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801587:	49 89 c0             	mov    %rax,%r8
  80158a:	b9 06 00 00 00       	mov    $0x6,%ecx
  80158f:	48 ba e0 21 80 00 00 	movabs $0x8021e0,%rdx
  801596:	00 00 00 
  801599:	be 22 00 00 00       	mov    $0x22,%esi
  80159e:	48 bf ff 21 80 00 00 	movabs $0x8021ff,%rdi
  8015a5:	00 00 00 
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ad:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  8015b4:	00 00 00 
  8015b7:	41 ff d1             	callq  *%r9

00000000008015ba <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8015ba:	55                   	push   %rbp
  8015bb:	48 89 e5             	mov    %rsp,%rbp
  8015be:	53                   	push   %rbx
  8015bf:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8015c3:	48 63 d7             	movslq %edi,%rdx
  8015c6:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8015c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d3:	48 89 df             	mov    %rbx,%rdi
  8015d6:	48 89 de             	mov    %rbx,%rsi
  8015d9:	cd 30                	int    $0x30
  if (check && ret > 0)
  8015db:	48 85 c0             	test   %rax,%rax
  8015de:	7f 07                	jg     8015e7 <sys_env_set_status+0x2d>
}
  8015e0:	48 83 c4 08          	add    $0x8,%rsp
  8015e4:	5b                   	pop    %rbx
  8015e5:	5d                   	pop    %rbp
  8015e6:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8015e7:	49 89 c0             	mov    %rax,%r8
  8015ea:	b9 08 00 00 00       	mov    $0x8,%ecx
  8015ef:	48 ba e0 21 80 00 00 	movabs $0x8021e0,%rdx
  8015f6:	00 00 00 
  8015f9:	be 22 00 00 00       	mov    $0x22,%esi
  8015fe:	48 bf ff 21 80 00 00 	movabs $0x8021ff,%rdi
  801605:	00 00 00 
  801608:	b8 00 00 00 00       	mov    $0x0,%eax
  80160d:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  801614:	00 00 00 
  801617:	41 ff d1             	callq  *%r9

000000000080161a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80161a:	55                   	push   %rbp
  80161b:	48 89 e5             	mov    %rsp,%rbp
  80161e:	53                   	push   %rbx
  80161f:	48 83 ec 08          	sub    $0x8,%rsp
  801623:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801626:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801629:	be 00 00 00 00       	mov    $0x0,%esi
  80162e:	b8 09 00 00 00       	mov    $0x9,%eax
  801633:	48 89 f3             	mov    %rsi,%rbx
  801636:	48 89 f7             	mov    %rsi,%rdi
  801639:	cd 30                	int    $0x30
  if (check && ret > 0)
  80163b:	48 85 c0             	test   %rax,%rax
  80163e:	7f 07                	jg     801647 <sys_env_set_pgfault_upcall+0x2d>
}
  801640:	48 83 c4 08          	add    $0x8,%rsp
  801644:	5b                   	pop    %rbx
  801645:	5d                   	pop    %rbp
  801646:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801647:	49 89 c0             	mov    %rax,%r8
  80164a:	b9 09 00 00 00       	mov    $0x9,%ecx
  80164f:	48 ba e0 21 80 00 00 	movabs $0x8021e0,%rdx
  801656:	00 00 00 
  801659:	be 22 00 00 00       	mov    $0x22,%esi
  80165e:	48 bf ff 21 80 00 00 	movabs $0x8021ff,%rdi
  801665:	00 00 00 
  801668:	b8 00 00 00 00       	mov    $0x0,%eax
  80166d:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  801674:	00 00 00 
  801677:	41 ff d1             	callq  *%r9

000000000080167a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  80167a:	55                   	push   %rbp
  80167b:	48 89 e5             	mov    %rsp,%rbp
  80167e:	53                   	push   %rbx
  80167f:	49 89 f0             	mov    %rsi,%r8
  801682:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801685:	48 63 d7             	movslq %edi,%rdx
  801688:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  80168b:	b8 0b 00 00 00       	mov    $0xb,%eax
  801690:	be 00 00 00 00       	mov    $0x0,%esi
  801695:	4c 89 c1             	mov    %r8,%rcx
  801698:	cd 30                	int    $0x30
}
  80169a:	5b                   	pop    %rbx
  80169b:	5d                   	pop    %rbp
  80169c:	c3                   	retq   

000000000080169d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  80169d:	55                   	push   %rbp
  80169e:	48 89 e5             	mov    %rsp,%rbp
  8016a1:	53                   	push   %rbx
  8016a2:	48 83 ec 08          	sub    $0x8,%rsp
  8016a6:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8016a9:	be 00 00 00 00       	mov    $0x0,%esi
  8016ae:	b8 0c 00 00 00       	mov    $0xc,%eax
  8016b3:	48 89 f1             	mov    %rsi,%rcx
  8016b6:	48 89 f3             	mov    %rsi,%rbx
  8016b9:	48 89 f7             	mov    %rsi,%rdi
  8016bc:	cd 30                	int    $0x30
  if (check && ret > 0)
  8016be:	48 85 c0             	test   %rax,%rax
  8016c1:	7f 07                	jg     8016ca <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8016c3:	48 83 c4 08          	add    $0x8,%rsp
  8016c7:	5b                   	pop    %rbx
  8016c8:	5d                   	pop    %rbp
  8016c9:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8016ca:	49 89 c0             	mov    %rax,%r8
  8016cd:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8016d2:	48 ba e0 21 80 00 00 	movabs $0x8021e0,%rdx
  8016d9:	00 00 00 
  8016dc:	be 22 00 00 00       	mov    $0x22,%esi
  8016e1:	48 bf ff 21 80 00 00 	movabs $0x8021ff,%rdi
  8016e8:	00 00 00 
  8016eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f0:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  8016f7:	00 00 00 
  8016fa:	41 ff d1             	callq  *%r9

00000000008016fd <pgfault>:
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  8016fd:	55                   	push   %rbp
  8016fe:	48 89 e5             	mov    %rsp,%rbp
  801701:	53                   	push   %rbx
  801702:	48 83 ec 08          	sub    $0x8,%rsp
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr = (void *) utf->utf_fault_va;
  801706:	48 8b 1f             	mov    (%rdi),%rbx
	uint64_t err = utf->utf_err;
  801709:	4c 8b 47 08          	mov    0x8(%rdi),%r8
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  80170d:	41 f6 c0 02          	test   $0x2,%r8b
  801711:	0f 84 b2 00 00 00    	je     8017c9 <pgfault+0xcc>
  801717:	48 89 da             	mov    %rbx,%rdx
  80171a:	48 c1 ea 0c          	shr    $0xc,%rdx
  80171e:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801725:	01 00 00 
  801728:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80172c:	f6 c4 08             	test   $0x8,%ah
  80172f:	0f 84 94 00 00 00    	je     8017c9 <pgfault+0xcc>
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_W)) < 0) {
  801735:	ba 02 00 00 00       	mov    $0x2,%edx
  80173a:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  80173f:	bf 00 00 00 00       	mov    $0x0,%edi
  801744:	48 b8 90 14 80 00 00 	movabs $0x801490,%rax
  80174b:	00 00 00 
  80174e:	ff d0                	callq  *%rax
  801750:	85 c0                	test   %eax,%eax
  801752:	0f 88 9f 00 00 00    	js     8017f7 <pgfault+0xfa>
  }

#ifdef SANITIZE_USER_SHADOW_BASE 
  __nosan_memcpy((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
	memmove((void *) PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801758:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  80175f:	ba 00 10 00 00       	mov    $0x1000,%edx
  801764:	48 89 de             	mov    %rbx,%rsi
  801767:	bf 00 f0 5f 00       	mov    $0x5ff000,%edi
  80176c:	48 b8 3c 11 80 00 00 	movabs $0x80113c,%rax
  801773:	00 00 00 
  801776:	ff d0                	callq  *%rax
#endif

	if ((r = sys_page_map(0, (void *) PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
  801778:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  80177e:	48 89 d9             	mov    %rbx,%rcx
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
  801786:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  80178b:	bf 00 00 00 00       	mov    $0x0,%edi
  801790:	48 b8 f3 14 80 00 00 	movabs $0x8014f3,%rax
  801797:	00 00 00 
  80179a:	ff d0                	callq  *%rax
  80179c:	85 c0                	test   %eax,%eax
  80179e:	0f 88 80 00 00 00    	js     801824 <pgfault+0x127>
	  panic("pgfault error: sys_page_map: %i\n", r);
	}

	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0) {
  8017a4:	be 00 f0 5f 00       	mov    $0x5ff000,%esi
  8017a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8017ae:	48 b8 5a 15 80 00 00 	movabs $0x80155a,%rax
  8017b5:	00 00 00 
  8017b8:	ff d0                	callq  *%rax
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	0f 88 8f 00 00 00    	js     801851 <pgfault+0x154>
	  panic("pgfault error: sys_page_unmap: %i\n", r);
	}
  // LAB 9 code end
}
  8017c2:	48 83 c4 08          	add    $0x8,%rsp
  8017c6:	5b                   	pop    %rbx
  8017c7:	5d                   	pop    %rbp
  8017c8:	c3                   	retq   
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  8017c9:	48 89 d9             	mov    %rbx,%rcx
  8017cc:	48 ba 10 22 80 00 00 	movabs $0x802210,%rdx
  8017d3:	00 00 00 
  8017d6:	be 21 00 00 00       	mov    $0x21,%esi
  8017db:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  8017e2:	00 00 00 
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ea:	49 b9 1c 04 80 00 00 	movabs $0x80041c,%r9
  8017f1:	00 00 00 
  8017f4:	41 ff d1             	callq  *%r9
		panic("pgfault error: sys_page_alloc: %i\n", r);
  8017f7:	89 c1                	mov    %eax,%ecx
  8017f9:	48 ba 40 22 80 00 00 	movabs $0x802240,%rdx
  801800:	00 00 00 
  801803:	be 2f 00 00 00       	mov    $0x2f,%esi
  801808:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  80180f:	00 00 00 
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
  801817:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  80181e:	00 00 00 
  801821:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_map: %i\n", r);
  801824:	89 c1                	mov    %eax,%ecx
  801826:	48 ba 68 22 80 00 00 	movabs $0x802268,%rdx
  80182d:	00 00 00 
  801830:	be 39 00 00 00       	mov    $0x39,%esi
  801835:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  80183c:	00 00 00 
  80183f:	b8 00 00 00 00       	mov    $0x0,%eax
  801844:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  80184b:	00 00 00 
  80184e:	41 ff d0             	callq  *%r8
	  panic("pgfault error: sys_page_unmap: %i\n", r);
  801851:	89 c1                	mov    %eax,%ecx
  801853:	48 ba 90 22 80 00 00 	movabs $0x802290,%rdx
  80185a:	00 00 00 
  80185d:	be 3d 00 00 00       	mov    $0x3d,%esi
  801862:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  801869:	00 00 00 
  80186c:	b8 00 00 00 00       	mov    $0x0,%eax
  801871:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  801878:	00 00 00 
  80187b:	41 ff d0             	callq  *%r8

000000000080187e <fork>:
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  80187e:	55                   	push   %rbp
  80187f:	48 89 e5             	mov    %rsp,%rbp
  801882:	41 57                	push   %r15
  801884:	41 56                	push   %r14
  801886:	41 55                	push   %r13
  801888:	41 54                	push   %r12
  80188a:	53                   	push   %rbx
  80188b:	48 83 ec 28          	sub    $0x28,%rsp

  // LAB 9 code
  envid_t e;
  int r;

	set_pgfault_handler(pgfault);
  80188f:	48 bf fd 16 80 00 00 	movabs $0x8016fd,%rdi
  801896:	00 00 00 
  801899:	48 b8 bc 1b 80 00 00 	movabs $0x801bbc,%rax
  8018a0:	00 00 00 
  8018a3:	ff d0                	callq  *%rax

// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void) {
  envid_t ret;
  __asm __volatile("int %2"
  8018a5:	b8 07 00 00 00       	mov    $0x7,%eax
  8018aa:	cd 30                	int    $0x30
  8018ac:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  8018af:	89 45 c0             	mov    %eax,-0x40(%rbp)

  if ((e = sys_exofork()) < 0) {
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 38                	js     8018ee <fork+0x70>
    panic("fork error: %i\n", (int) e);
  }
  
	if (!e) {
  8018b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018bb:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8018bf:	74 5a                	je     80191b <fork+0x9d>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
	  uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8018c1:	49 bc 00 20 40 80 00 	movabs $0x10080402000,%r12
  8018c8:	01 00 00 
    for (i = 0; i < UTOP / PGSIZE; i++) {
  8018cb:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  8018d2:	00 00 00 
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  8018d5:	49 be 00 00 40 80 00 	movabs $0x10080400000,%r14
  8018dc:	01 00 00 
  8018df:	49 bf 00 00 00 80 00 	movabs $0x10080000000,%r15
  8018e6:	01 00 00 
  8018e9:	e9 2c 01 00 00       	jmpq   801a1a <fork+0x19c>
    panic("fork error: %i\n", (int) e);
  8018ee:	89 c1                	mov    %eax,%ecx
  8018f0:	48 ba 3b 23 80 00 00 	movabs $0x80233b,%rdx
  8018f7:	00 00 00 
  8018fa:	be 82 00 00 00       	mov    $0x82,%esi
  8018ff:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  801906:	00 00 00 
  801909:	b8 00 00 00 00       	mov    $0x0,%eax
  80190e:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  801915:	00 00 00 
  801918:	41 ff d0             	callq  *%r8
		thisenv = &envs[ENVX(sys_getenvid())];
  80191b:	48 b8 50 14 80 00 00 	movabs $0x801450,%rax
  801922:	00 00 00 
  801925:	ff d0                	callq  *%rax
  801927:	25 ff 03 00 00       	and    $0x3ff,%eax
  80192c:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  801930:	48 c1 e0 05          	shl    $0x5,%rax
  801934:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  80193b:	00 00 00 
  80193e:	48 01 d0             	add    %rdx,%rax
  801941:	48 a3 08 30 80 00 00 	movabs %rax,0x803008
  801948:	00 00 00 
		return 0;
  80194b:	e9 9d 01 00 00       	jmpq   801aed <fork+0x26f>
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  801950:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801957:	01 00 00 
  80195a:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  80195e:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  envid_t id = sys_getenvid();
  801962:	48 b8 50 14 80 00 00 	movabs $0x801450,%rax
  801969:	00 00 00 
  80196c:	ff d0                	callq  *%rax
  80196e:	89 c7                	mov    %eax,%edi
  801970:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  if (ent & (PTE_W | PTE_COW)) {
  801973:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  801977:	f7 c2 02 08 00 00    	test   $0x802,%edx
  80197d:	74 57                	je     8019d6 <fork+0x158>
    ent = (ent | PTE_COW) & ~PTE_W;
  80197f:	81 e2 05 06 00 00    	and    $0x605,%edx
  801985:	48 89 d0             	mov    %rdx,%rax
  801988:	80 cc 08             	or     $0x8,%ah
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  80198b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80198f:	48 c1 e6 0c          	shl    $0xc,%rsi
  801993:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  801997:	41 89 c0             	mov    %eax,%r8d
  80199a:	48 89 f1             	mov    %rsi,%rcx
  80199d:	8b 55 c0             	mov    -0x40(%rbp),%edx
  8019a0:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  8019a4:	48 b8 f3 14 80 00 00 	movabs $0x8014f3,%rax
  8019ab:	00 00 00 
  8019ae:	ff d0                	callq  *%rax
    if (r < 0) {
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	0f 88 ce 01 00 00    	js     801b86 <fork+0x308>
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  8019b8:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8019bc:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8019c0:	48 89 f1             	mov    %rsi,%rcx
  8019c3:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8019c6:	89 fa                	mov    %edi,%edx
  8019c8:	48 b8 f3 14 80 00 00 	movabs $0x8014f3,%rax
  8019cf:	00 00 00 
  8019d2:	ff d0                	callq  *%rax
  8019d4:	eb 28                	jmp    8019fe <fork+0x180>
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  8019d6:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8019da:	48 c1 e6 0c          	shl    $0xc,%rsi
  8019de:	44 8b 45 b8          	mov    -0x48(%rbp),%r8d
  8019e2:	41 81 e0 07 0e 00 00 	and    $0xe07,%r8d
  8019e9:	48 89 f1             	mov    %rsi,%rcx
  8019ec:	8b 55 c0             	mov    -0x40(%rbp),%edx
  8019ef:	8b 7d b4             	mov    -0x4c(%rbp),%edi
  8019f2:	48 b8 f3 14 80 00 00 	movabs $0x8014f3,%rax
  8019f9:	00 00 00 
  8019fc:	ff d0                	callq  *%rax
          continue;
        }
#endif

        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	0f 89 80 00 00 00    	jns    801a86 <fork+0x208>
  801a06:	89 45 c0             	mov    %eax,-0x40(%rbp)
  801a09:	e9 df 00 00 00       	jmpq   801aed <fork+0x26f>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  801a0e:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801a15:	4c 39 eb             	cmp    %r13,%rbx
  801a18:	74 75                	je     801a8f <fork+0x211>
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
  801a1a:	48 89 d8             	mov    %rbx,%rax
  801a1d:	48 c1 e8 27          	shr    $0x27,%rax
  801a21:	49 8b 04 c4          	mov    (%r12,%rax,8),%rax
  801a25:	a8 01                	test   $0x1,%al
  801a27:	74 e5                	je     801a0e <fork+0x190>
  801a29:	48 89 d8             	mov    %rbx,%rax
  801a2c:	48 c1 e8 1e          	shr    $0x1e,%rax
  801a30:	49 8b 04 c6          	mov    (%r14,%rax,8),%rax
  801a34:	a8 01                	test   $0x1,%al
  801a36:	74 d6                	je     801a0e <fork+0x190>
  801a38:	48 89 d8             	mov    %rbx,%rax
  801a3b:	48 c1 e8 15          	shr    $0x15,%rax
  801a3f:	49 8b 04 c7          	mov    (%r15,%rax,8),%rax
  801a43:	a8 01                	test   $0x1,%al
  801a45:	74 c7                	je     801a0e <fork+0x190>
        if (((uintptr_t) addr < UTOP) && ((uintptr_t) addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
  801a47:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  801a4e:	00 00 00 
  801a51:	48 39 c3             	cmp    %rax,%rbx
  801a54:	77 b8                	ja     801a0e <fork+0x190>
  801a56:	48 8d 80 01 f0 ff ff 	lea    -0xfff(%rax),%rax
  801a5d:	48 39 c3             	cmp    %rax,%rbx
  801a60:	74 ac                	je     801a0e <fork+0x190>
  801a62:	48 89 d8             	mov    %rbx,%rax
  801a65:	48 c1 e8 0c          	shr    $0xc,%rax
  801a69:	48 89 c1             	mov    %rax,%rcx
  801a6c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  801a70:	48 b8 00 00 00 00 00 	movabs $0x10000000000,%rax
  801a77:	01 00 00 
  801a7a:	48 8b 04 c8          	mov    (%rax,%rcx,8),%rax
  801a7e:	a8 01                	test   $0x1,%al
  801a80:	0f 85 ca fe ff ff    	jne    801950 <fork+0xd2>
    for (i = 0; i < UTOP / PGSIZE; i++) {
  801a86:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  801a8d:	eb 8b                	jmp    801a1a <fork+0x19c>
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
  801a8f:	48 a1 08 30 80 00 00 	movabs 0x803008,%rax
  801a96:	00 00 00 
  801a99:	48 8b b0 f8 00 00 00 	mov    0xf8(%rax),%rsi
  801aa0:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  801aa3:	48 b8 1a 16 80 00 00 	movabs $0x80161a,%rax
  801aaa:	00 00 00 
  801aad:	ff d0                	callq  *%rax
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 4c                	js     801aff <fork+0x281>
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *) UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
  801ab3:	ba 02 00 00 00       	mov    $0x2,%edx
  801ab8:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801abf:	00 00 00 
  801ac2:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  801ac5:	48 b8 90 14 80 00 00 	movabs $0x801490,%rax
  801acc:	00 00 00 
  801acf:	ff d0                	callq  *%rax
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 57                	js     801b2c <fork+0x2ae>
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *) addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
  801ad5:	be 02 00 00 00       	mov    $0x2,%esi
  801ada:	8b 7d c4             	mov    -0x3c(%rbp),%edi
  801add:	48 b8 ba 15 80 00 00 	movabs $0x8015ba,%rax
  801ae4:	00 00 00 
  801ae7:	ff d0                	callq  *%rax
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 6c                	js     801b59 <fork+0x2db>
    return e;
  }
  // LAB 9 code end

  // return -1;
}
  801aed:	8b 45 c0             	mov    -0x40(%rbp),%eax
  801af0:	48 83 c4 28          	add    $0x28,%rsp
  801af4:	5b                   	pop    %rbx
  801af5:	41 5c                	pop    %r12
  801af7:	41 5d                	pop    %r13
  801af9:	41 5e                	pop    %r14
  801afb:	41 5f                	pop    %r15
  801afd:	5d                   	pop    %rbp
  801afe:	c3                   	retq   
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
  801aff:	89 c1                	mov    %eax,%ecx
  801b01:	48 ba b8 22 80 00 00 	movabs $0x8022b8,%rdx
  801b08:	00 00 00 
  801b0b:	be a7 00 00 00       	mov    $0xa7,%esi
  801b10:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  801b17:	00 00 00 
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1f:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  801b26:	00 00 00 
  801b29:	41 ff d0             	callq  *%r8
      panic("fork error: sys_page_alloc: %i\n", r);
  801b2c:	89 c1                	mov    %eax,%ecx
  801b2e:	48 ba e8 22 80 00 00 	movabs $0x8022e8,%rdx
  801b35:	00 00 00 
  801b38:	be aa 00 00 00       	mov    $0xaa,%esi
  801b3d:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  801b44:	00 00 00 
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4c:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  801b53:	00 00 00 
  801b56:	41 ff d0             	callq  *%r8
      panic("fork error: sys_env_set_status: %i\n", r);
  801b59:	89 c1                	mov    %eax,%ecx
  801b5b:	48 ba 08 23 80 00 00 	movabs $0x802308,%rdx
  801b62:	00 00 00 
  801b65:	be bd 00 00 00       	mov    $0xbd,%esi
  801b6a:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  801b71:	00 00 00 
  801b74:	b8 00 00 00 00       	mov    $0x0,%eax
  801b79:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  801b80:	00 00 00 
  801b83:	41 ff d0             	callq  *%r8
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  801b86:	89 45 c0             	mov    %eax,-0x40(%rbp)
  801b89:	e9 5f ff ff ff       	jmpq   801aed <fork+0x26f>

0000000000801b8e <sfork>:

// Challenge!
int
sfork(void) {
  801b8e:	55                   	push   %rbp
  801b8f:	48 89 e5             	mov    %rsp,%rbp
  panic("sfork not implemented");
  801b92:	48 ba 4b 23 80 00 00 	movabs $0x80234b,%rdx
  801b99:	00 00 00 
  801b9c:	be c9 00 00 00       	mov    $0xc9,%esi
  801ba1:	48 bf 30 23 80 00 00 	movabs $0x802330,%rdi
  801ba8:	00 00 00 
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb0:	48 b9 1c 04 80 00 00 	movabs $0x80041c,%rcx
  801bb7:	00 00 00 
  801bba:	ff d1                	callq  *%rcx

0000000000801bbc <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  801bbc:	55                   	push   %rbp
  801bbd:	48 89 e5             	mov    %rsp,%rbp
  801bc0:	41 54                	push   %r12
  801bc2:	53                   	push   %rbx
  801bc3:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  801bc6:	48 b8 50 14 80 00 00 	movabs $0x801450,%rax
  801bcd:	00 00 00 
  801bd0:	ff d0                	callq  *%rax
  801bd2:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  801bd4:	48 b8 10 30 80 00 00 	movabs $0x803010,%rax
  801bdb:	00 00 00 
  801bde:	48 83 38 00          	cmpq   $0x0,(%rax)
  801be2:	74 2e                	je     801c12 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  801be4:	4c 89 e0             	mov    %r12,%rax
  801be7:	48 a3 10 30 80 00 00 	movabs %rax,0x803010
  801bee:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801bf1:	48 be 5e 1c 80 00 00 	movabs $0x801c5e,%rsi
  801bf8:	00 00 00 
  801bfb:	89 df                	mov    %ebx,%edi
  801bfd:	48 b8 1a 16 80 00 00 	movabs $0x80161a,%rax
  801c04:	00 00 00 
  801c07:	ff d0                	callq  *%rax
  if (error < 0)
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 24                	js     801c31 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  801c0d:	5b                   	pop    %rbx
  801c0e:	41 5c                	pop    %r12
  801c10:	5d                   	pop    %rbp
  801c11:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  801c12:	ba 02 00 00 00       	mov    $0x2,%edx
  801c17:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  801c1e:	00 00 00 
  801c21:	89 df                	mov    %ebx,%edi
  801c23:	48 b8 90 14 80 00 00 	movabs $0x801490,%rax
  801c2a:	00 00 00 
  801c2d:	ff d0                	callq  *%rax
  801c2f:	eb b3                	jmp    801be4 <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  801c31:	89 c1                	mov    %eax,%ecx
  801c33:	48 ba 61 23 80 00 00 	movabs $0x802361,%rdx
  801c3a:	00 00 00 
  801c3d:	be 2c 00 00 00       	mov    $0x2c,%esi
  801c42:	48 bf 79 23 80 00 00 	movabs $0x802379,%rdi
  801c49:	00 00 00 
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c51:	49 b8 1c 04 80 00 00 	movabs $0x80041c,%r8
  801c58:	00 00 00 
  801c5b:	41 ff d0             	callq  *%r8

0000000000801c5e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  801c5e:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  801c61:	48 a1 10 30 80 00 00 	movabs 0x803010,%rax
  801c68:	00 00 00 
	call *%rax
  801c6b:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  801c6d:	41 5f                	pop    %r15
	popq %r15
  801c6f:	41 5f                	pop    %r15
	popq %r15
  801c71:	41 5f                	pop    %r15
	popq %r14
  801c73:	41 5e                	pop    %r14
	popq %r13
  801c75:	41 5d                	pop    %r13
	popq %r12
  801c77:	41 5c                	pop    %r12
	popq %r11
  801c79:	41 5b                	pop    %r11
	popq %r10
  801c7b:	41 5a                	pop    %r10
	popq %r9
  801c7d:	41 59                	pop    %r9
	popq %r8
  801c7f:	41 58                	pop    %r8
	popq %rsi
  801c81:	5e                   	pop    %rsi
	popq %rdi
  801c82:	5f                   	pop    %rdi
	popq %rbp
  801c83:	5d                   	pop    %rbp
	popq %rdx
  801c84:	5a                   	pop    %rdx
	popq %rcx
  801c85:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  801c86:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  801c8b:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  801c90:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  801c94:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  801c97:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  801c9c:	5b                   	pop    %rbx
	popq %rax
  801c9d:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  801c9e:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  801ca2:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  801ca3:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  801ca8:	c3                   	retq   
  801ca9:	0f 1f 00             	nopl   (%rax)
