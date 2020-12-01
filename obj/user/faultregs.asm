
obj/user/faultregs:     file format elf64-x86-64


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
  800023:	e8 7b 0c 00 00       	callq  800ca3 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <check_regs>:

static struct regs before, during, after;

static void
check_regs(struct regs *a, const char *an, struct regs *b, const char *bn,
           const char *testname) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  80002e:	41 57                	push   %r15
  800030:	41 56                	push   %r14
  800032:	41 55                	push   %r13
  800034:	41 54                	push   %r12
  800036:	53                   	push   %rbx
  800037:	48 83 ec 08          	sub    $0x8,%rsp
  80003b:	49 89 fc             	mov    %rdi,%r12
  80003e:	48 89 d3             	mov    %rdx,%rbx
  800041:	4d 89 c6             	mov    %r8,%r14
  int mismatch = 0;

  cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800044:	48 89 f2             	mov    %rsi,%rdx
  800047:	48 be 73 21 80 00 00 	movabs $0x802173,%rsi
  80004e:	00 00 00 
  800051:	48 bf 40 21 80 00 00 	movabs $0x802140,%rdi
  800058:	00 00 00 
  80005b:	b8 00 00 00 00       	mov    $0x0,%eax
  800060:	49 bd 12 0f 80 00 00 	movabs $0x800f12,%r13
  800067:	00 00 00 
  80006a:	41 ff d5             	callq  *%r13
      cprintf("MISMATCH\n");                                                               \
      mismatch = 1;                                                                        \
    }                                                                                      \
  } while (0)

  CHECK(r14, regs.reg_r14);
  80006d:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
  800071:	49 8b 54 24 08       	mov    0x8(%r12),%rdx
  800076:	48 be 50 21 80 00 00 	movabs $0x802150,%rsi
  80007d:	00 00 00 
  800080:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800087:	00 00 00 
  80008a:	b8 00 00 00 00       	mov    $0x0,%eax
  80008f:	41 ff d5             	callq  *%r13
  800092:	48 8b 43 08          	mov    0x8(%rbx),%rax
  800096:	49 39 44 24 08       	cmp    %rax,0x8(%r12)
  80009b:	0f 84 48 06 00 00    	je     8006e9 <check_regs+0x6bf>
  8000a1:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8000a8:	00 00 00 
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8000b7:	00 00 00 
  8000ba:	ff d2                	callq  *%rdx
  8000bc:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(r13, regs.reg_r13);
  8000c2:	48 8b 4b 10          	mov    0x10(%rbx),%rcx
  8000c6:	49 8b 54 24 10       	mov    0x10(%r12),%rdx
  8000cb:	48 be 74 21 80 00 00 	movabs $0x802174,%rsi
  8000d2:	00 00 00 
  8000d5:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  8000dc:	00 00 00 
  8000df:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e4:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  8000eb:	00 00 00 
  8000ee:	41 ff d0             	callq  *%r8
  8000f1:	48 8b 43 10          	mov    0x10(%rbx),%rax
  8000f5:	49 39 44 24 10       	cmp    %rax,0x10(%r12)
  8000fa:	0f 84 06 06 00 00    	je     800706 <check_regs+0x6dc>
  800100:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  800107:	00 00 00 
  80010a:	b8 00 00 00 00       	mov    $0x0,%eax
  80010f:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  800116:	00 00 00 
  800119:	ff d2                	callq  *%rdx
  80011b:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(r12, regs.reg_r12);
  800121:	48 8b 4b 18          	mov    0x18(%rbx),%rcx
  800125:	49 8b 54 24 18       	mov    0x18(%r12),%rdx
  80012a:	48 be 78 21 80 00 00 	movabs $0x802178,%rsi
  800131:	00 00 00 
  800134:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  80013b:	00 00 00 
  80013e:	b8 00 00 00 00       	mov    $0x0,%eax
  800143:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  80014a:	00 00 00 
  80014d:	41 ff d0             	callq  *%r8
  800150:	48 8b 43 18          	mov    0x18(%rbx),%rax
  800154:	49 39 44 24 18       	cmp    %rax,0x18(%r12)
  800159:	0f 84 c7 05 00 00    	je     800726 <check_regs+0x6fc>
  80015f:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  800166:	00 00 00 
  800169:	b8 00 00 00 00       	mov    $0x0,%eax
  80016e:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  800175:	00 00 00 
  800178:	ff d2                	callq  *%rdx
  80017a:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(r11, regs.reg_r11);
  800180:	48 8b 4b 20          	mov    0x20(%rbx),%rcx
  800184:	49 8b 54 24 20       	mov    0x20(%r12),%rdx
  800189:	48 be 7c 21 80 00 00 	movabs $0x80217c,%rsi
  800190:	00 00 00 
  800193:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  80019a:	00 00 00 
  80019d:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a2:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  8001a9:	00 00 00 
  8001ac:	41 ff d0             	callq  *%r8
  8001af:	48 8b 43 20          	mov    0x20(%rbx),%rax
  8001b3:	49 39 44 24 20       	cmp    %rax,0x20(%r12)
  8001b8:	0f 84 88 05 00 00    	je     800746 <check_regs+0x71c>
  8001be:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8001c5:	00 00 00 
  8001c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cd:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8001d4:	00 00 00 
  8001d7:	ff d2                	callq  *%rdx
  8001d9:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(r10, regs.reg_r10);
  8001df:	48 8b 4b 28          	mov    0x28(%rbx),%rcx
  8001e3:	49 8b 54 24 28       	mov    0x28(%r12),%rdx
  8001e8:	48 be 80 21 80 00 00 	movabs $0x802180,%rsi
  8001ef:	00 00 00 
  8001f2:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  8001f9:	00 00 00 
  8001fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800201:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  800208:	00 00 00 
  80020b:	41 ff d0             	callq  *%r8
  80020e:	48 8b 43 28          	mov    0x28(%rbx),%rax
  800212:	49 39 44 24 28       	cmp    %rax,0x28(%r12)
  800217:	0f 84 49 05 00 00    	je     800766 <check_regs+0x73c>
  80021d:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  800224:	00 00 00 
  800227:	b8 00 00 00 00       	mov    $0x0,%eax
  80022c:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  800233:	00 00 00 
  800236:	ff d2                	callq  *%rdx
  800238:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rsi, regs.reg_rsi);
  80023e:	48 8b 4b 40          	mov    0x40(%rbx),%rcx
  800242:	49 8b 54 24 40       	mov    0x40(%r12),%rdx
  800247:	48 be 84 21 80 00 00 	movabs $0x802184,%rsi
  80024e:	00 00 00 
  800251:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800258:	00 00 00 
  80025b:	b8 00 00 00 00       	mov    $0x0,%eax
  800260:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  800267:	00 00 00 
  80026a:	41 ff d0             	callq  *%r8
  80026d:	48 8b 43 40          	mov    0x40(%rbx),%rax
  800271:	49 39 44 24 40       	cmp    %rax,0x40(%r12)
  800276:	0f 84 0a 05 00 00    	je     800786 <check_regs+0x75c>
  80027c:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  800283:	00 00 00 
  800286:	b8 00 00 00 00       	mov    $0x0,%eax
  80028b:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  800292:	00 00 00 
  800295:	ff d2                	callq  *%rdx
  800297:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rdi, regs.reg_rdi);
  80029d:	48 8b 4b 48          	mov    0x48(%rbx),%rcx
  8002a1:	49 8b 54 24 48       	mov    0x48(%r12),%rdx
  8002a6:	48 be 88 21 80 00 00 	movabs $0x802188,%rsi
  8002ad:	00 00 00 
  8002b0:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  8002b7:	00 00 00 
  8002ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8002bf:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  8002c6:	00 00 00 
  8002c9:	41 ff d0             	callq  *%r8
  8002cc:	48 8b 43 48          	mov    0x48(%rbx),%rax
  8002d0:	49 39 44 24 48       	cmp    %rax,0x48(%r12)
  8002d5:	0f 84 cb 04 00 00    	je     8007a6 <check_regs+0x77c>
  8002db:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8002e2:	00 00 00 
  8002e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ea:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8002f1:	00 00 00 
  8002f4:	ff d2                	callq  *%rdx
  8002f6:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rdi, regs.reg_rdi);
  8002fc:	48 8b 4b 48          	mov    0x48(%rbx),%rcx
  800300:	49 8b 54 24 48       	mov    0x48(%r12),%rdx
  800305:	48 be 88 21 80 00 00 	movabs $0x802188,%rsi
  80030c:	00 00 00 
  80030f:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800316:	00 00 00 
  800319:	b8 00 00 00 00       	mov    $0x0,%eax
  80031e:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  800325:	00 00 00 
  800328:	41 ff d0             	callq  *%r8
  80032b:	48 8b 43 48          	mov    0x48(%rbx),%rax
  80032f:	49 39 44 24 48       	cmp    %rax,0x48(%r12)
  800334:	0f 84 8c 04 00 00    	je     8007c6 <check_regs+0x79c>
  80033a:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  800341:	00 00 00 
  800344:	b8 00 00 00 00       	mov    $0x0,%eax
  800349:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  800350:	00 00 00 
  800353:	ff d2                	callq  *%rdx
  800355:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rsi, regs.reg_rsi);
  80035b:	48 8b 4b 40          	mov    0x40(%rbx),%rcx
  80035f:	49 8b 54 24 40       	mov    0x40(%r12),%rdx
  800364:	48 be 84 21 80 00 00 	movabs $0x802184,%rsi
  80036b:	00 00 00 
  80036e:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800375:	00 00 00 
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
  80037d:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  800384:	00 00 00 
  800387:	41 ff d0             	callq  *%r8
  80038a:	48 8b 43 40          	mov    0x40(%rbx),%rax
  80038e:	49 39 44 24 40       	cmp    %rax,0x40(%r12)
  800393:	0f 84 4d 04 00 00    	je     8007e6 <check_regs+0x7bc>
  800399:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8003a0:	00 00 00 
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8003af:	00 00 00 
  8003b2:	ff d2                	callq  *%rdx
  8003b4:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rbp, regs.reg_rbp);
  8003ba:	48 8b 4b 50          	mov    0x50(%rbx),%rcx
  8003be:	49 8b 54 24 50       	mov    0x50(%r12),%rdx
  8003c3:	48 be 8c 21 80 00 00 	movabs $0x80218c,%rsi
  8003ca:	00 00 00 
  8003cd:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  8003d4:	00 00 00 
  8003d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dc:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  8003e3:	00 00 00 
  8003e6:	41 ff d0             	callq  *%r8
  8003e9:	48 8b 43 50          	mov    0x50(%rbx),%rax
  8003ed:	49 39 44 24 50       	cmp    %rax,0x50(%r12)
  8003f2:	0f 84 0e 04 00 00    	je     800806 <check_regs+0x7dc>
  8003f8:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8003ff:	00 00 00 
  800402:	b8 00 00 00 00       	mov    $0x0,%eax
  800407:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80040e:	00 00 00 
  800411:	ff d2                	callq  *%rdx
  800413:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rbx, regs.reg_rbx);
  800419:	48 8b 4b 68          	mov    0x68(%rbx),%rcx
  80041d:	49 8b 54 24 68       	mov    0x68(%r12),%rdx
  800422:	48 be 90 21 80 00 00 	movabs $0x802190,%rsi
  800429:	00 00 00 
  80042c:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800433:	00 00 00 
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  800442:	00 00 00 
  800445:	41 ff d0             	callq  *%r8
  800448:	48 8b 43 68          	mov    0x68(%rbx),%rax
  80044c:	49 39 44 24 68       	cmp    %rax,0x68(%r12)
  800451:	0f 84 cf 03 00 00    	je     800826 <check_regs+0x7fc>
  800457:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  80045e:	00 00 00 
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80046d:	00 00 00 
  800470:	ff d2                	callq  *%rdx
  800472:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rdx, regs.reg_rdx);
  800478:	48 8b 4b 58          	mov    0x58(%rbx),%rcx
  80047c:	49 8b 54 24 58       	mov    0x58(%r12),%rdx
  800481:	48 be 94 21 80 00 00 	movabs $0x802194,%rsi
  800488:	00 00 00 
  80048b:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800492:	00 00 00 
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  8004a1:	00 00 00 
  8004a4:	41 ff d0             	callq  *%r8
  8004a7:	48 8b 43 58          	mov    0x58(%rbx),%rax
  8004ab:	49 39 44 24 58       	cmp    %rax,0x58(%r12)
  8004b0:	0f 84 90 03 00 00    	je     800846 <check_regs+0x81c>
  8004b6:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8004bd:	00 00 00 
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8004cc:	00 00 00 
  8004cf:	ff d2                	callq  *%rdx
  8004d1:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rcx, regs.reg_rcx);
  8004d7:	48 8b 4b 60          	mov    0x60(%rbx),%rcx
  8004db:	49 8b 54 24 60       	mov    0x60(%r12),%rdx
  8004e0:	48 be 98 21 80 00 00 	movabs $0x802198,%rsi
  8004e7:	00 00 00 
  8004ea:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  8004f1:	00 00 00 
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  800500:	00 00 00 
  800503:	41 ff d0             	callq  *%r8
  800506:	48 8b 43 60          	mov    0x60(%rbx),%rax
  80050a:	49 39 44 24 60       	cmp    %rax,0x60(%r12)
  80050f:	0f 84 51 03 00 00    	je     800866 <check_regs+0x83c>
  800515:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  80051c:	00 00 00 
  80051f:	b8 00 00 00 00       	mov    $0x0,%eax
  800524:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80052b:	00 00 00 
  80052e:	ff d2                	callq  *%rdx
  800530:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rax, regs.reg_rax);
  800536:	48 8b 4b 70          	mov    0x70(%rbx),%rcx
  80053a:	49 8b 54 24 70       	mov    0x70(%r12),%rdx
  80053f:	48 be 9c 21 80 00 00 	movabs $0x80219c,%rsi
  800546:	00 00 00 
  800549:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800550:	00 00 00 
  800553:	b8 00 00 00 00       	mov    $0x0,%eax
  800558:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  80055f:	00 00 00 
  800562:	41 ff d0             	callq  *%r8
  800565:	48 8b 43 70          	mov    0x70(%rbx),%rax
  800569:	49 39 44 24 70       	cmp    %rax,0x70(%r12)
  80056e:	0f 84 12 03 00 00    	je     800886 <check_regs+0x85c>
  800574:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  80057b:	00 00 00 
  80057e:	b8 00 00 00 00       	mov    $0x0,%eax
  800583:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80058a:	00 00 00 
  80058d:	ff d2                	callq  *%rdx
  80058f:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rip, rip);
  800595:	48 8b 4b 78          	mov    0x78(%rbx),%rcx
  800599:	49 8b 54 24 78       	mov    0x78(%r12),%rdx
  80059e:	48 be a0 21 80 00 00 	movabs $0x8021a0,%rsi
  8005a5:	00 00 00 
  8005a8:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  8005af:	00 00 00 
  8005b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b7:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  8005be:	00 00 00 
  8005c1:	41 ff d0             	callq  *%r8
  8005c4:	48 8b 43 78          	mov    0x78(%rbx),%rax
  8005c8:	49 39 44 24 78       	cmp    %rax,0x78(%r12)
  8005cd:	0f 84 d3 02 00 00    	je     8008a6 <check_regs+0x87c>
  8005d3:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8005da:	00 00 00 
  8005dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e2:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8005e9:	00 00 00 
  8005ec:	ff d2                	callq  *%rdx
  8005ee:	41 bd 01 00 00 00    	mov    $0x1,%r13d
  CHECK(rflags, rflags);
  8005f4:	48 8b 8b 80 00 00 00 	mov    0x80(%rbx),%rcx
  8005fb:	49 8b 94 24 80 00 00 	mov    0x80(%r12),%rdx
  800602:	00 
  800603:	48 be a4 21 80 00 00 	movabs $0x8021a4,%rsi
  80060a:	00 00 00 
  80060d:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800614:	00 00 00 
  800617:	b8 00 00 00 00       	mov    $0x0,%eax
  80061c:	49 b8 12 0f 80 00 00 	movabs $0x800f12,%r8
  800623:	00 00 00 
  800626:	41 ff d0             	callq  *%r8
  800629:	48 8b 83 80 00 00 00 	mov    0x80(%rbx),%rax
  800630:	49 39 84 24 80 00 00 	cmp    %rax,0x80(%r12)
  800637:	00 
  800638:	0f 84 88 02 00 00    	je     8008c6 <check_regs+0x89c>
  80063e:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  800645:	00 00 00 
  800648:	b8 00 00 00 00       	mov    $0x0,%eax
  80064d:	49 bd 12 0f 80 00 00 	movabs $0x800f12,%r13
  800654:	00 00 00 
  800657:	41 ff d5             	callq  *%r13
  CHECK(rsp, rsp);
  80065a:	48 8b 8b 88 00 00 00 	mov    0x88(%rbx),%rcx
  800661:	49 8b 94 24 88 00 00 	mov    0x88(%r12),%rdx
  800668:	00 
  800669:	48 be ab 21 80 00 00 	movabs $0x8021ab,%rsi
  800670:	00 00 00 
  800673:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  80067a:	00 00 00 
  80067d:	b8 00 00 00 00       	mov    $0x0,%eax
  800682:	41 ff d5             	callq  *%r13
  800685:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  80068c:	49 39 84 24 88 00 00 	cmp    %rax,0x88(%r12)
  800693:	00 
  800694:	0f 84 ea 02 00 00    	je     800984 <check_regs+0x95a>
  80069a:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8006a1:	00 00 00 
  8006a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a9:	48 bb 12 0f 80 00 00 	movabs $0x800f12,%rbx
  8006b0:	00 00 00 
  8006b3:	ff d3                	callq  *%rbx

#undef CHECK

  cprintf("Registers %s ", testname);
  8006b5:	4c 89 f6             	mov    %r14,%rsi
  8006b8:	48 bf af 21 80 00 00 	movabs $0x8021af,%rdi
  8006bf:	00 00 00 
  8006c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c7:	ff d3                	callq  *%rbx
  if (!mismatch)
    cprintf("OK\n");
  else
    cprintf("MISMATCH\n");
  8006c9:	48 bf 6a 21 80 00 00 	movabs $0x80216a,%rdi
  8006d0:	00 00 00 
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8006df:	00 00 00 
  8006e2:	ff d2                	callq  *%rdx
}
  8006e4:	e9 8c 02 00 00       	jmpq   800975 <check_regs+0x94b>
  CHECK(r14, regs.reg_r14);
  8006e9:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  8006f0:	00 00 00 
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	41 ff d5             	callq  *%r13
  int mismatch = 0;
  8006fb:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  800701:	e9 bc f9 ff ff       	jmpq   8000c2 <check_regs+0x98>
  CHECK(r13, regs.reg_r13);
  800706:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80070d:	00 00 00 
  800710:	b8 00 00 00 00       	mov    $0x0,%eax
  800715:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80071c:	00 00 00 
  80071f:	ff d2                	callq  *%rdx
  800721:	e9 fb f9 ff ff       	jmpq   800121 <check_regs+0xf7>
  CHECK(r12, regs.reg_r12);
  800726:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80072d:	00 00 00 
  800730:	b8 00 00 00 00       	mov    $0x0,%eax
  800735:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80073c:	00 00 00 
  80073f:	ff d2                	callq  *%rdx
  800741:	e9 3a fa ff ff       	jmpq   800180 <check_regs+0x156>
  CHECK(r11, regs.reg_r11);
  800746:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80074d:	00 00 00 
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
  800755:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80075c:	00 00 00 
  80075f:	ff d2                	callq  *%rdx
  800761:	e9 79 fa ff ff       	jmpq   8001df <check_regs+0x1b5>
  CHECK(r10, regs.reg_r10);
  800766:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80076d:	00 00 00 
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
  800775:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80077c:	00 00 00 
  80077f:	ff d2                	callq  *%rdx
  800781:	e9 b8 fa ff ff       	jmpq   80023e <check_regs+0x214>
  CHECK(rsi, regs.reg_rsi);
  800786:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80078d:	00 00 00 
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80079c:	00 00 00 
  80079f:	ff d2                	callq  *%rdx
  8007a1:	e9 f7 fa ff ff       	jmpq   80029d <check_regs+0x273>
  CHECK(rdi, regs.reg_rdi);
  8007a6:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  8007ad:	00 00 00 
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8007bc:	00 00 00 
  8007bf:	ff d2                	callq  *%rdx
  8007c1:	e9 36 fb ff ff       	jmpq   8002fc <check_regs+0x2d2>
  CHECK(rdi, regs.reg_rdi);
  8007c6:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  8007cd:	00 00 00 
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8007dc:	00 00 00 
  8007df:	ff d2                	callq  *%rdx
  8007e1:	e9 75 fb ff ff       	jmpq   80035b <check_regs+0x331>
  CHECK(rsi, regs.reg_rsi);
  8007e6:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  8007ed:	00 00 00 
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8007fc:	00 00 00 
  8007ff:	ff d2                	callq  *%rdx
  800801:	e9 b4 fb ff ff       	jmpq   8003ba <check_regs+0x390>
  CHECK(rbp, regs.reg_rbp);
  800806:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80080d:	00 00 00 
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80081c:	00 00 00 
  80081f:	ff d2                	callq  *%rdx
  800821:	e9 f3 fb ff ff       	jmpq   800419 <check_regs+0x3ef>
  CHECK(rbx, regs.reg_rbx);
  800826:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80082d:	00 00 00 
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
  800835:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80083c:	00 00 00 
  80083f:	ff d2                	callq  *%rdx
  800841:	e9 32 fc ff ff       	jmpq   800478 <check_regs+0x44e>
  CHECK(rdx, regs.reg_rdx);
  800846:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80084d:	00 00 00 
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
  800855:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80085c:	00 00 00 
  80085f:	ff d2                	callq  *%rdx
  800861:	e9 71 fc ff ff       	jmpq   8004d7 <check_regs+0x4ad>
  CHECK(rcx, regs.reg_rcx);
  800866:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80086d:	00 00 00 
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
  800875:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80087c:	00 00 00 
  80087f:	ff d2                	callq  *%rdx
  800881:	e9 b0 fc ff ff       	jmpq   800536 <check_regs+0x50c>
  CHECK(rax, regs.reg_rax);
  800886:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80088d:	00 00 00 
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
  800895:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  80089c:	00 00 00 
  80089f:	ff d2                	callq  *%rdx
  8008a1:	e9 ef fc ff ff       	jmpq   800595 <check_regs+0x56b>
  CHECK(rip, rip);
  8008a6:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  8008ad:	00 00 00 
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  8008bc:	00 00 00 
  8008bf:	ff d2                	callq  *%rdx
  8008c1:	e9 2e fd ff ff       	jmpq   8005f4 <check_regs+0x5ca>
  CHECK(rflags, rflags);
  8008c6:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  8008cd:	00 00 00 
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	49 bf 12 0f 80 00 00 	movabs $0x800f12,%r15
  8008dc:	00 00 00 
  8008df:	41 ff d7             	callq  *%r15
  CHECK(rsp, rsp);
  8008e2:	48 8b 8b 88 00 00 00 	mov    0x88(%rbx),%rcx
  8008e9:	49 8b 94 24 88 00 00 	mov    0x88(%r12),%rdx
  8008f0:	00 
  8008f1:	48 be ab 21 80 00 00 	movabs $0x8021ab,%rsi
  8008f8:	00 00 00 
  8008fb:	48 bf 54 21 80 00 00 	movabs $0x802154,%rdi
  800902:	00 00 00 
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	41 ff d7             	callq  *%r15
  80090d:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  800914:	49 39 84 24 88 00 00 	cmp    %rax,0x88(%r12)
  80091b:	00 
  80091c:	0f 85 78 fd ff ff    	jne    80069a <check_regs+0x670>
  800922:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  800929:	00 00 00 
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	48 bb 12 0f 80 00 00 	movabs $0x800f12,%rbx
  800938:	00 00 00 
  80093b:	ff d3                	callq  *%rbx
  cprintf("Registers %s ", testname);
  80093d:	4c 89 f6             	mov    %r14,%rsi
  800940:	48 bf af 21 80 00 00 	movabs $0x8021af,%rdi
  800947:	00 00 00 
  80094a:	b8 00 00 00 00       	mov    $0x0,%eax
  80094f:	ff d3                	callq  *%rbx
  if (!mismatch)
  800951:	45 85 ed             	test   %r13d,%r13d
  800954:	0f 85 6f fd ff ff    	jne    8006c9 <check_regs+0x69f>
    cprintf("OK\n");
  80095a:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  800961:	00 00 00 
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
  800969:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  800970:	00 00 00 
  800973:	ff d2                	callq  *%rdx
}
  800975:	48 83 c4 08          	add    $0x8,%rsp
  800979:	5b                   	pop    %rbx
  80097a:	41 5c                	pop    %r12
  80097c:	41 5d                	pop    %r13
  80097e:	41 5e                	pop    %r14
  800980:	41 5f                	pop    %r15
  800982:	5d                   	pop    %rbp
  800983:	c3                   	retq   
  CHECK(rsp, rsp);
  800984:	48 bf 66 21 80 00 00 	movabs $0x802166,%rdi
  80098b:	00 00 00 
  80098e:	b8 00 00 00 00       	mov    $0x0,%eax
  800993:	48 bb 12 0f 80 00 00 	movabs $0x800f12,%rbx
  80099a:	00 00 00 
  80099d:	ff d3                	callq  *%rbx
  cprintf("Registers %s ", testname);
  80099f:	4c 89 f6             	mov    %r14,%rsi
  8009a2:	48 bf af 21 80 00 00 	movabs $0x8021af,%rdi
  8009a9:	00 00 00 
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	ff d3                	callq  *%rbx
  if (!mismatch)
  8009b3:	e9 11 fd ff ff       	jmpq   8006c9 <check_regs+0x69f>

00000000008009b8 <pgfault>:

static void
pgfault(struct UTrapframe *utf) {
  8009b8:	55                   	push   %rbp
  8009b9:	48 89 e5             	mov    %rsp,%rbp
  int r;

  if (utf->utf_fault_va != (uint64_t)UTEMP)
  8009bc:	48 8b 0f             	mov    (%rdi),%rcx
  8009bf:	48 81 f9 00 00 40 00 	cmp    $0x400000,%rcx
  8009c6:	0f 85 d4 00 00 00    	jne    800aa0 <pgfault+0xe8>
    panic("pgfault expected at UTEMP, got 0x%08lx (rip %08lx)",
          (unsigned long)utf->utf_fault_va, (unsigned long)utf->utf_rip);

  // Check registers in UTrapframe
  during.regs   = utf->utf_regs;
  8009cc:	48 ba c0 30 80 00 00 	movabs $0x8030c0,%rdx
  8009d3:	00 00 00 
  8009d6:	f3 0f 6f 47 10       	movdqu 0x10(%rdi),%xmm0
  8009db:	0f 29 02             	movaps %xmm0,(%rdx)
  8009de:	f3 0f 6f 4f 20       	movdqu 0x20(%rdi),%xmm1
  8009e3:	0f 29 4a 10          	movaps %xmm1,0x10(%rdx)
  8009e7:	f3 0f 6f 57 30       	movdqu 0x30(%rdi),%xmm2
  8009ec:	0f 29 52 20          	movaps %xmm2,0x20(%rdx)
  8009f0:	f3 0f 6f 5f 40       	movdqu 0x40(%rdi),%xmm3
  8009f5:	0f 29 5a 30          	movaps %xmm3,0x30(%rdx)
  8009f9:	f3 0f 6f 67 50       	movdqu 0x50(%rdi),%xmm4
  8009fe:	0f 29 62 40          	movaps %xmm4,0x40(%rdx)
  800a02:	f3 0f 6f 6f 60       	movdqu 0x60(%rdi),%xmm5
  800a07:	0f 29 6a 50          	movaps %xmm5,0x50(%rdx)
  800a0b:	f3 0f 6f 77 70       	movdqu 0x70(%rdi),%xmm6
  800a10:	0f 29 72 60          	movaps %xmm6,0x60(%rdx)
  800a14:	48 8b 87 80 00 00 00 	mov    0x80(%rdi),%rax
  800a1b:	48 89 42 70          	mov    %rax,0x70(%rdx)
  during.rip    = utf->utf_rip;
  800a1f:	48 8b 87 88 00 00 00 	mov    0x88(%rdi),%rax
  800a26:	48 89 42 78          	mov    %rax,0x78(%rdx)
  during.rflags = utf->utf_rflags & 0xfff;
  800a2a:	48 8b 87 90 00 00 00 	mov    0x90(%rdi),%rax
  800a31:	25 ff 0f 00 00       	and    $0xfff,%eax
  800a36:	48 89 82 80 00 00 00 	mov    %rax,0x80(%rdx)
  during.rsp    = utf->utf_rsp;
  800a3d:	48 8b 87 98 00 00 00 	mov    0x98(%rdi),%rax
  800a44:	48 89 82 88 00 00 00 	mov    %rax,0x88(%rdx)
  check_regs(&before, "before", &during, "during", "in UTrapframe");
  800a4b:	49 b8 ce 21 80 00 00 	movabs $0x8021ce,%r8
  800a52:	00 00 00 
  800a55:	48 b9 dc 21 80 00 00 	movabs $0x8021dc,%rcx
  800a5c:	00 00 00 
  800a5f:	48 be e3 21 80 00 00 	movabs $0x8021e3,%rsi
  800a66:	00 00 00 
  800a69:	48 bf 60 31 80 00 00 	movabs $0x803160,%rdi
  800a70:	00 00 00 
  800a73:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800a7a:	00 00 00 
  800a7d:	ff d0                	callq  *%rax
  ;

  // Map UTEMP so the write succeeds
  if ((r = sys_page_alloc(0, UTEMP, PTE_U | PTE_P | PTE_W)) < 0)
  800a7f:	ba 07 00 00 00       	mov    $0x7,%edx
  800a84:	be 00 00 40 00       	mov    $0x400000,%esi
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	48 b8 e4 1d 80 00 00 	movabs $0x801de4,%rax
  800a95:	00 00 00 
  800a98:	ff d0                	callq  *%rax
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	78 34                	js     800ad2 <pgfault+0x11a>
    panic("sys_page_alloc: %i", r);
}
  800a9e:	5d                   	pop    %rbp
  800a9f:	c3                   	retq   
    panic("pgfault expected at UTEMP, got 0x%08lx (rip %08lx)",
  800aa0:	4c 8b 87 88 00 00 00 	mov    0x88(%rdi),%r8
  800aa7:	48 ba 18 22 80 00 00 	movabs $0x802218,%rdx
  800aae:	00 00 00 
  800ab1:	be 63 00 00 00       	mov    $0x63,%esi
  800ab6:	48 bf bd 21 80 00 00 	movabs $0x8021bd,%rdi
  800abd:	00 00 00 
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  800acc:	00 00 00 
  800acf:	41 ff d1             	callq  *%r9
    panic("sys_page_alloc: %i", r);
  800ad2:	89 c1                	mov    %eax,%ecx
  800ad4:	48 ba ea 21 80 00 00 	movabs $0x8021ea,%rdx
  800adb:	00 00 00 
  800ade:	be 6f 00 00 00       	mov    $0x6f,%esi
  800ae3:	48 bf bd 21 80 00 00 	movabs $0x8021bd,%rdi
  800aea:	00 00 00 
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
  800af2:	49 b8 70 0d 80 00 00 	movabs $0x800d70,%r8
  800af9:	00 00 00 
  800afc:	41 ff d0             	callq  *%r8

0000000000800aff <umain>:

void
umain(int argc, char **argv) {
  800aff:	55                   	push   %rbp
  800b00:	48 89 e5             	mov    %rsp,%rbp
  set_pgfault_handler(pgfault);
  800b03:	48 bf b8 09 80 00 00 	movabs $0x8009b8,%rdi
  800b0a:	00 00 00 
  800b0d:	48 b8 51 20 80 00 00 	movabs $0x802051,%rax
  800b14:	00 00 00 
  800b17:	ff d0                	callq  *%rax

  __asm __volatile(
  800b19:	48 b8 60 31 80 00 00 	movabs $0x803160,%rax
  800b20:	00 00 00 
  800b23:	48 ba 20 30 80 00 00 	movabs $0x803020,%rdx
  800b2a:	00 00 00 
  800b2d:	50                   	push   %rax
  800b2e:	52                   	push   %rdx
  800b2f:	50                   	push   %rax
  800b30:	9c                   	pushfq 
  800b31:	58                   	pop    %rax
  800b32:	48 0d d4 08 00 00    	or     $0x8d4,%rax
  800b38:	50                   	push   %rax
  800b39:	9d                   	popfq  
  800b3a:	4c 8b 7c 24 10       	mov    0x10(%rsp),%r15
  800b3f:	49 89 87 80 00 00 00 	mov    %rax,0x80(%r15)
  800b46:	48 8d 04 25 92 0b 80 	lea    0x800b92,%rax
  800b4d:	00 
  800b4e:	49 89 47 78          	mov    %rax,0x78(%r15)
  800b52:	58                   	pop    %rax
  800b53:	4d 89 77 08          	mov    %r14,0x8(%r15)
  800b57:	4d 89 6f 10          	mov    %r13,0x10(%r15)
  800b5b:	4d 89 67 18          	mov    %r12,0x18(%r15)
  800b5f:	4d 89 5f 20          	mov    %r11,0x20(%r15)
  800b63:	4d 89 57 28          	mov    %r10,0x28(%r15)
  800b67:	4d 89 4f 30          	mov    %r9,0x30(%r15)
  800b6b:	4d 89 47 38          	mov    %r8,0x38(%r15)
  800b6f:	49 89 77 40          	mov    %rsi,0x40(%r15)
  800b73:	49 89 7f 48          	mov    %rdi,0x48(%r15)
  800b77:	49 89 6f 50          	mov    %rbp,0x50(%r15)
  800b7b:	49 89 57 58          	mov    %rdx,0x58(%r15)
  800b7f:	49 89 4f 60          	mov    %rcx,0x60(%r15)
  800b83:	49 89 5f 68          	mov    %rbx,0x68(%r15)
  800b87:	49 89 47 70          	mov    %rax,0x70(%r15)
  800b8b:	49 89 a7 88 00 00 00 	mov    %rsp,0x88(%r15)
  800b92:	c7 04 25 00 00 40 00 	movl   $0x2a,0x400000
  800b99:	2a 00 00 00 
  800b9d:	4c 8b 3c 24          	mov    (%rsp),%r15
  800ba1:	4d 89 77 08          	mov    %r14,0x8(%r15)
  800ba5:	4d 89 6f 10          	mov    %r13,0x10(%r15)
  800ba9:	4d 89 67 18          	mov    %r12,0x18(%r15)
  800bad:	4d 89 5f 20          	mov    %r11,0x20(%r15)
  800bb1:	4d 89 57 28          	mov    %r10,0x28(%r15)
  800bb5:	4d 89 4f 30          	mov    %r9,0x30(%r15)
  800bb9:	4d 89 47 38          	mov    %r8,0x38(%r15)
  800bbd:	49 89 77 40          	mov    %rsi,0x40(%r15)
  800bc1:	49 89 7f 48          	mov    %rdi,0x48(%r15)
  800bc5:	49 89 6f 50          	mov    %rbp,0x50(%r15)
  800bc9:	49 89 57 58          	mov    %rdx,0x58(%r15)
  800bcd:	49 89 4f 60          	mov    %rcx,0x60(%r15)
  800bd1:	49 89 5f 68          	mov    %rbx,0x68(%r15)
  800bd5:	49 89 47 70          	mov    %rax,0x70(%r15)
  800bd9:	49 89 a7 88 00 00 00 	mov    %rsp,0x88(%r15)
  800be0:	4c 8b 7c 24 08       	mov    0x8(%rsp),%r15
  800be5:	4d 8b 77 08          	mov    0x8(%r15),%r14
  800be9:	4d 8b 6f 10          	mov    0x10(%r15),%r13
  800bed:	4d 8b 67 18          	mov    0x18(%r15),%r12
  800bf1:	4d 8b 5f 20          	mov    0x20(%r15),%r11
  800bf5:	4d 8b 57 28          	mov    0x28(%r15),%r10
  800bf9:	4d 8b 4f 30          	mov    0x30(%r15),%r9
  800bfd:	4d 8b 47 38          	mov    0x38(%r15),%r8
  800c01:	49 8b 77 40          	mov    0x40(%r15),%rsi
  800c05:	49 8b 7f 48          	mov    0x48(%r15),%rdi
  800c09:	49 8b 6f 50          	mov    0x50(%r15),%rbp
  800c0d:	49 8b 57 58          	mov    0x58(%r15),%rdx
  800c11:	49 8b 4f 60          	mov    0x60(%r15),%rcx
  800c15:	49 8b 5f 68          	mov    0x68(%r15),%rbx
  800c19:	49 8b 47 70          	mov    0x70(%r15),%rax
  800c1d:	49 8b a7 88 00 00 00 	mov    0x88(%r15),%rsp
  800c24:	50                   	push   %rax
  800c25:	9c                   	pushfq 
  800c26:	58                   	pop    %rax
  800c27:	4c 8b 7c 24 08       	mov    0x8(%rsp),%r15
  800c2c:	49 89 87 80 00 00 00 	mov    %rax,0x80(%r15)
  800c33:	58                   	pop    %rax
      : "memory", "cc");

  // Check UTEMP to roughly determine that EIP was restored
  // correctly (of course, we probably wouldn't get this far if
  // it weren't)
  if (*(int *)UTEMP != 42)
  800c34:	83 3c 25 00 00 40 00 	cmpl   $0x2a,0x400000
  800c3b:	2a 
  800c3c:	75 48                	jne    800c86 <umain+0x187>
    cprintf("RIP after page-fault MISMATCH\n");
  after.rip = before.rip;
  800c3e:	48 ba 20 30 80 00 00 	movabs $0x803020,%rdx
  800c45:	00 00 00 
  800c48:	48 bf 60 31 80 00 00 	movabs $0x803160,%rdi
  800c4f:	00 00 00 
  800c52:	48 8b 47 78          	mov    0x78(%rdi),%rax
  800c56:	48 89 42 78          	mov    %rax,0x78(%rdx)

  check_regs(&before, "before", &after, "after", "after page-fault");
  800c5a:	49 b8 fd 21 80 00 00 	movabs $0x8021fd,%r8
  800c61:	00 00 00 
  800c64:	48 b9 0e 22 80 00 00 	movabs $0x80220e,%rcx
  800c6b:	00 00 00 
  800c6e:	48 be e3 21 80 00 00 	movabs $0x8021e3,%rsi
  800c75:	00 00 00 
  800c78:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  800c7f:	00 00 00 
  800c82:	ff d0                	callq  *%rax
}
  800c84:	5d                   	pop    %rbp
  800c85:	c3                   	retq   
    cprintf("RIP after page-fault MISMATCH\n");
  800c86:	48 bf 50 22 80 00 00 	movabs $0x802250,%rdi
  800c8d:	00 00 00 
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
  800c95:	48 ba 12 0f 80 00 00 	movabs $0x800f12,%rdx
  800c9c:	00 00 00 
  800c9f:	ff d2                	callq  *%rdx
  800ca1:	eb 9b                	jmp    800c3e <umain+0x13f>

0000000000800ca3 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800ca3:	55                   	push   %rbp
  800ca4:	48 89 e5             	mov    %rsp,%rbp
  800ca7:	41 56                	push   %r14
  800ca9:	41 55                	push   %r13
  800cab:	41 54                	push   %r12
  800cad:	53                   	push   %rbx
  800cae:	41 89 fd             	mov    %edi,%r13d
  800cb1:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800cb4:	48 ba 08 30 80 00 00 	movabs $0x803008,%rdx
  800cbb:	00 00 00 
  800cbe:	48 b8 08 30 80 00 00 	movabs $0x803008,%rax
  800cc5:	00 00 00 
  800cc8:	48 39 c2             	cmp    %rax,%rdx
  800ccb:	73 23                	jae    800cf0 <libmain+0x4d>
  800ccd:	48 89 d3             	mov    %rdx,%rbx
  800cd0:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800cd4:	48 29 d0             	sub    %rdx,%rax
  800cd7:	48 c1 e8 03          	shr    $0x3,%rax
  800cdb:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce5:	ff 13                	callq  *(%rbx)
    ctor++;
  800ce7:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800ceb:	4c 39 e3             	cmp    %r12,%rbx
  800cee:	75 f0                	jne    800ce0 <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  800cf0:	48 b8 a4 1d 80 00 00 	movabs $0x801da4,%rax
  800cf7:	00 00 00 
  800cfa:	ff d0                	callq  *%rax
  800cfc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d01:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  800d05:	48 c1 e0 05          	shl    $0x5,%rax
  800d09:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  800d10:	00 00 00 
  800d13:	48 01 d0             	add    %rdx,%rax
  800d16:	48 a3 f0 31 80 00 00 	movabs %rax,0x8031f0
  800d1d:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  800d20:	45 85 ed             	test   %r13d,%r13d
  800d23:	7e 0d                	jle    800d32 <libmain+0x8f>
    binaryname = argv[0];
  800d25:	49 8b 06             	mov    (%r14),%rax
  800d28:	48 a3 00 30 80 00 00 	movabs %rax,0x803000
  800d2f:	00 00 00 

  // call user main routine
  umain(argc, argv);
  800d32:	4c 89 f6             	mov    %r14,%rsi
  800d35:	44 89 ef             	mov    %r13d,%edi
  800d38:	48 b8 ff 0a 80 00 00 	movabs $0x800aff,%rax
  800d3f:	00 00 00 
  800d42:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  800d44:	48 b8 59 0d 80 00 00 	movabs $0x800d59,%rax
  800d4b:	00 00 00 
  800d4e:	ff d0                	callq  *%rax
#endif
}
  800d50:	5b                   	pop    %rbx
  800d51:	41 5c                	pop    %r12
  800d53:	41 5d                	pop    %r13
  800d55:	41 5e                	pop    %r14
  800d57:	5d                   	pop    %rbp
  800d58:	c3                   	retq   

0000000000800d59 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800d59:	55                   	push   %rbp
  800d5a:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  800d5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d62:	48 b8 44 1d 80 00 00 	movabs $0x801d44,%rax
  800d69:	00 00 00 
  800d6c:	ff d0                	callq  *%rax
}
  800d6e:	5d                   	pop    %rbp
  800d6f:	c3                   	retq   

0000000000800d70 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  800d70:	55                   	push   %rbp
  800d71:	48 89 e5             	mov    %rsp,%rbp
  800d74:	41 56                	push   %r14
  800d76:	41 55                	push   %r13
  800d78:	41 54                	push   %r12
  800d7a:	53                   	push   %rbx
  800d7b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800d82:	49 89 fd             	mov    %rdi,%r13
  800d85:	41 89 f6             	mov    %esi,%r14d
  800d88:	49 89 d4             	mov    %rdx,%r12
  800d8b:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  800d92:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  800d99:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  800da0:	84 c0                	test   %al,%al
  800da2:	74 26                	je     800dca <_panic+0x5a>
  800da4:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  800dab:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  800db2:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  800db6:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  800dba:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  800dbe:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  800dc2:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  800dc6:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  800dca:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  800dd1:	00 00 00 
  800dd4:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  800ddb:	00 00 00 
  800dde:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800de2:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  800de9:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  800df0:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  800df7:	48 b8 00 30 80 00 00 	movabs $0x803000,%rax
  800dfe:	00 00 00 
  800e01:	48 8b 18             	mov    (%rax),%rbx
  800e04:	48 b8 a4 1d 80 00 00 	movabs $0x801da4,%rax
  800e0b:	00 00 00 
  800e0e:	ff d0                	callq  *%rax
  800e10:	45 89 f0             	mov    %r14d,%r8d
  800e13:	4c 89 e9             	mov    %r13,%rcx
  800e16:	48 89 da             	mov    %rbx,%rdx
  800e19:	89 c6                	mov    %eax,%esi
  800e1b:	48 bf 80 22 80 00 00 	movabs $0x802280,%rdi
  800e22:	00 00 00 
  800e25:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2a:	48 bb 12 0f 80 00 00 	movabs $0x800f12,%rbx
  800e31:	00 00 00 
  800e34:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  800e36:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  800e3d:	4c 89 e7             	mov    %r12,%rdi
  800e40:	48 b8 aa 0e 80 00 00 	movabs $0x800eaa,%rax
  800e47:	00 00 00 
  800e4a:	ff d0                	callq  *%rax
  cprintf("\n");
  800e4c:	48 bf 72 21 80 00 00 	movabs $0x802172,%rdi
  800e53:	00 00 00 
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5b:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  800e5d:	cc                   	int3   
  while (1)
  800e5e:	eb fd                	jmp    800e5d <_panic+0xed>

0000000000800e60 <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  800e60:	55                   	push   %rbp
  800e61:	48 89 e5             	mov    %rsp,%rbp
  800e64:	53                   	push   %rbx
  800e65:	48 83 ec 08          	sub    $0x8,%rsp
  800e69:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800e6c:	8b 06                	mov    (%rsi),%eax
  800e6e:	8d 50 01             	lea    0x1(%rax),%edx
  800e71:	89 16                	mov    %edx,(%rsi)
  800e73:	48 98                	cltq   
  800e75:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800e7a:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  800e80:	74 0b                	je     800e8d <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  800e82:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800e86:	48 83 c4 08          	add    $0x8,%rsp
  800e8a:	5b                   	pop    %rbx
  800e8b:	5d                   	pop    %rbp
  800e8c:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  800e8d:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  800e91:	be ff 00 00 00       	mov    $0xff,%esi
  800e96:	48 b8 06 1d 80 00 00 	movabs $0x801d06,%rax
  800e9d:	00 00 00 
  800ea0:	ff d0                	callq  *%rax
    b->idx = 0;
  800ea2:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800ea8:	eb d8                	jmp    800e82 <putch+0x22>

0000000000800eaa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800eaa:	55                   	push   %rbp
  800eab:	48 89 e5             	mov    %rsp,%rbp
  800eae:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800eb5:	48 89 fa             	mov    %rdi,%rdx
  800eb8:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800ebb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  800ec2:	00 00 00 
  b.cnt = 0;
  800ec5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800ecc:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  800ecf:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800ed6:	48 bf 60 0e 80 00 00 	movabs $0x800e60,%rdi
  800edd:	00 00 00 
  800ee0:	48 b8 d0 10 80 00 00 	movabs $0x8010d0,%rax
  800ee7:	00 00 00 
  800eea:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  800eec:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  800ef3:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  800efa:	48 8d 78 08          	lea    0x8(%rax),%rdi
  800efe:	48 b8 06 1d 80 00 00 	movabs $0x801d06,%rax
  800f05:	00 00 00 
  800f08:	ff d0                	callq  *%rax

  return b.cnt;
}
  800f0a:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  800f10:	c9                   	leaveq 
  800f11:	c3                   	retq   

0000000000800f12 <cprintf>:

int
cprintf(const char *fmt, ...) {
  800f12:	55                   	push   %rbp
  800f13:	48 89 e5             	mov    %rsp,%rbp
  800f16:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800f1d:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  800f24:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  800f2b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800f32:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800f39:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800f40:	84 c0                	test   %al,%al
  800f42:	74 20                	je     800f64 <cprintf+0x52>
  800f44:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800f48:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800f4c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800f50:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800f54:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800f58:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800f5c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800f60:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800f64:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800f6b:	00 00 00 
  800f6e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800f75:	00 00 00 
  800f78:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800f7c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800f83:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800f8a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  800f91:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800f98:	48 b8 aa 0e 80 00 00 	movabs $0x800eaa,%rax
  800f9f:	00 00 00 
  800fa2:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800fa4:	c9                   	leaveq 
  800fa5:	c3                   	retq   

0000000000800fa6 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800fa6:	55                   	push   %rbp
  800fa7:	48 89 e5             	mov    %rsp,%rbp
  800faa:	41 57                	push   %r15
  800fac:	41 56                	push   %r14
  800fae:	41 55                	push   %r13
  800fb0:	41 54                	push   %r12
  800fb2:	53                   	push   %rbx
  800fb3:	48 83 ec 18          	sub    $0x18,%rsp
  800fb7:	49 89 fc             	mov    %rdi,%r12
  800fba:	49 89 f5             	mov    %rsi,%r13
  800fbd:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800fc1:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800fc4:	41 89 cf             	mov    %ecx,%r15d
  800fc7:	49 39 d7             	cmp    %rdx,%r15
  800fca:	76 45                	jbe    801011 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800fcc:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  800fd0:	85 db                	test   %ebx,%ebx
  800fd2:	7e 0e                	jle    800fe2 <printnum+0x3c>
      putch(padc, putdat);
  800fd4:	4c 89 ee             	mov    %r13,%rsi
  800fd7:	44 89 f7             	mov    %r14d,%edi
  800fda:	41 ff d4             	callq  *%r12
    while (--width > 0)
  800fdd:	83 eb 01             	sub    $0x1,%ebx
  800fe0:	75 f2                	jne    800fd4 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  800fe2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800fe6:	ba 00 00 00 00       	mov    $0x0,%edx
  800feb:	49 f7 f7             	div    %r15
  800fee:	48 b8 a3 22 80 00 00 	movabs $0x8022a3,%rax
  800ff5:	00 00 00 
  800ff8:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  800ffc:	4c 89 ee             	mov    %r13,%rsi
  800fff:	41 ff d4             	callq  *%r12
}
  801002:	48 83 c4 18          	add    $0x18,%rsp
  801006:	5b                   	pop    %rbx
  801007:	41 5c                	pop    %r12
  801009:	41 5d                	pop    %r13
  80100b:	41 5e                	pop    %r14
  80100d:	41 5f                	pop    %r15
  80100f:	5d                   	pop    %rbp
  801010:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  801011:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  801015:	ba 00 00 00 00       	mov    $0x0,%edx
  80101a:	49 f7 f7             	div    %r15
  80101d:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  801021:	48 89 c2             	mov    %rax,%rdx
  801024:	48 b8 a6 0f 80 00 00 	movabs $0x800fa6,%rax
  80102b:	00 00 00 
  80102e:	ff d0                	callq  *%rax
  801030:	eb b0                	jmp    800fe2 <printnum+0x3c>

0000000000801032 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  801032:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  801036:	48 8b 06             	mov    (%rsi),%rax
  801039:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80103d:	73 0a                	jae    801049 <sprintputch+0x17>
    *b->buf++ = ch;
  80103f:	48 8d 50 01          	lea    0x1(%rax),%rdx
  801043:	48 89 16             	mov    %rdx,(%rsi)
  801046:	40 88 38             	mov    %dil,(%rax)
}
  801049:	c3                   	retq   

000000000080104a <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80104a:	55                   	push   %rbp
  80104b:	48 89 e5             	mov    %rsp,%rbp
  80104e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801055:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80105c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  801063:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80106a:	84 c0                	test   %al,%al
  80106c:	74 20                	je     80108e <printfmt+0x44>
  80106e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  801072:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  801076:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80107a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80107e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  801082:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  801086:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80108a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80108e:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  801095:	00 00 00 
  801098:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80109f:	00 00 00 
  8010a2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8010a6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8010ad:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8010b4:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8010bb:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8010c2:	48 b8 d0 10 80 00 00 	movabs $0x8010d0,%rax
  8010c9:	00 00 00 
  8010cc:	ff d0                	callq  *%rax
}
  8010ce:	c9                   	leaveq 
  8010cf:	c3                   	retq   

00000000008010d0 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8010d0:	55                   	push   %rbp
  8010d1:	48 89 e5             	mov    %rsp,%rbp
  8010d4:	41 57                	push   %r15
  8010d6:	41 56                	push   %r14
  8010d8:	41 55                	push   %r13
  8010da:	41 54                	push   %r12
  8010dc:	53                   	push   %rbx
  8010dd:	48 83 ec 48          	sub    $0x48,%rsp
  8010e1:	49 89 fd             	mov    %rdi,%r13
  8010e4:	49 89 f7             	mov    %rsi,%r15
  8010e7:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8010ea:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8010ee:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8010f2:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8010f6:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8010fa:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8010fe:	41 0f b6 3e          	movzbl (%r14),%edi
  801102:	83 ff 25             	cmp    $0x25,%edi
  801105:	74 18                	je     80111f <vprintfmt+0x4f>
      if (ch == '\0')
  801107:	85 ff                	test   %edi,%edi
  801109:	0f 84 8c 06 00 00    	je     80179b <vprintfmt+0x6cb>
      putch(ch, putdat);
  80110f:	4c 89 fe             	mov    %r15,%rsi
  801112:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  801115:	49 89 de             	mov    %rbx,%r14
  801118:	eb e0                	jmp    8010fa <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80111a:	49 89 de             	mov    %rbx,%r14
  80111d:	eb db                	jmp    8010fa <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80111f:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  801123:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  801127:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80112e:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  801134:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  801138:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80113d:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801143:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  801149:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80114e:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  801153:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  801157:	0f b6 13             	movzbl (%rbx),%edx
  80115a:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80115d:	3c 55                	cmp    $0x55,%al
  80115f:	0f 87 8b 05 00 00    	ja     8016f0 <vprintfmt+0x620>
  801165:	0f b6 c0             	movzbl %al,%eax
  801168:	49 bb 80 23 80 00 00 	movabs $0x802380,%r11
  80116f:	00 00 00 
  801172:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  801176:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  801179:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80117d:	eb d4                	jmp    801153 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80117f:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  801182:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  801186:	eb cb                	jmp    801153 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  801188:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80118b:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80118f:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  801193:	8d 50 d0             	lea    -0x30(%rax),%edx
  801196:	83 fa 09             	cmp    $0x9,%edx
  801199:	77 7e                	ja     801219 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80119b:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80119f:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8011a3:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8011a8:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8011ac:	8d 50 d0             	lea    -0x30(%rax),%edx
  8011af:	83 fa 09             	cmp    $0x9,%edx
  8011b2:	76 e7                	jbe    80119b <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8011b4:	4c 89 f3             	mov    %r14,%rbx
  8011b7:	eb 19                	jmp    8011d2 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8011b9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8011bc:	83 f8 2f             	cmp    $0x2f,%eax
  8011bf:	77 2a                	ja     8011eb <vprintfmt+0x11b>
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	4c 01 d2             	add    %r10,%rdx
  8011c6:	83 c0 08             	add    $0x8,%eax
  8011c9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8011cc:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  8011cf:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8011d2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8011d6:	0f 89 77 ff ff ff    	jns    801153 <vprintfmt+0x83>
          width = precision, precision = -1;
  8011dc:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8011e0:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8011e6:	e9 68 ff ff ff       	jmpq   801153 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8011eb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8011ef:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8011f3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8011f7:	eb d3                	jmp    8011cc <vprintfmt+0xfc>
        if (width < 0)
  8011f9:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	41 0f 48 c0          	cmovs  %r8d,%eax
  801202:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  801205:	4c 89 f3             	mov    %r14,%rbx
  801208:	e9 46 ff ff ff       	jmpq   801153 <vprintfmt+0x83>
  80120d:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  801210:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  801214:	e9 3a ff ff ff       	jmpq   801153 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  801219:	4c 89 f3             	mov    %r14,%rbx
  80121c:	eb b4                	jmp    8011d2 <vprintfmt+0x102>
        lflag++;
  80121e:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  801221:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  801224:	e9 2a ff ff ff       	jmpq   801153 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  801229:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80122c:	83 f8 2f             	cmp    $0x2f,%eax
  80122f:	77 19                	ja     80124a <vprintfmt+0x17a>
  801231:	89 c2                	mov    %eax,%edx
  801233:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801237:	83 c0 08             	add    $0x8,%eax
  80123a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80123d:	4c 89 fe             	mov    %r15,%rsi
  801240:	8b 3a                	mov    (%rdx),%edi
  801242:	41 ff d5             	callq  *%r13
        break;
  801245:	e9 b0 fe ff ff       	jmpq   8010fa <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80124a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80124e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  801252:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  801256:	eb e5                	jmp    80123d <vprintfmt+0x16d>
        err = va_arg(aq, int);
  801258:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80125b:	83 f8 2f             	cmp    $0x2f,%eax
  80125e:	77 5b                	ja     8012bb <vprintfmt+0x1eb>
  801260:	89 c2                	mov    %eax,%edx
  801262:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801266:	83 c0 08             	add    $0x8,%eax
  801269:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80126c:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80126e:	89 c8                	mov    %ecx,%eax
  801270:	c1 f8 1f             	sar    $0x1f,%eax
  801273:	31 c1                	xor    %eax,%ecx
  801275:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801277:	83 f9 0b             	cmp    $0xb,%ecx
  80127a:	7f 4d                	jg     8012c9 <vprintfmt+0x1f9>
  80127c:	48 63 c1             	movslq %ecx,%rax
  80127f:	48 ba 40 26 80 00 00 	movabs $0x802640,%rdx
  801286:	00 00 00 
  801289:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80128d:	48 85 c0             	test   %rax,%rax
  801290:	74 37                	je     8012c9 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  801292:	48 89 c1             	mov    %rax,%rcx
  801295:	48 ba c4 22 80 00 00 	movabs $0x8022c4,%rdx
  80129c:	00 00 00 
  80129f:	4c 89 fe             	mov    %r15,%rsi
  8012a2:	4c 89 ef             	mov    %r13,%rdi
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012aa:	48 bb 4a 10 80 00 00 	movabs $0x80104a,%rbx
  8012b1:	00 00 00 
  8012b4:	ff d3                	callq  *%rbx
  8012b6:	e9 3f fe ff ff       	jmpq   8010fa <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8012bb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8012bf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8012c3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8012c7:	eb a3                	jmp    80126c <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8012c9:	48 ba bb 22 80 00 00 	movabs $0x8022bb,%rdx
  8012d0:	00 00 00 
  8012d3:	4c 89 fe             	mov    %r15,%rsi
  8012d6:	4c 89 ef             	mov    %r13,%rdi
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	48 bb 4a 10 80 00 00 	movabs $0x80104a,%rbx
  8012e5:	00 00 00 
  8012e8:	ff d3                	callq  *%rbx
  8012ea:	e9 0b fe ff ff       	jmpq   8010fa <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8012ef:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8012f2:	83 f8 2f             	cmp    $0x2f,%eax
  8012f5:	77 4b                	ja     801342 <vprintfmt+0x272>
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8012fd:	83 c0 08             	add    $0x8,%eax
  801300:	89 45 b8             	mov    %eax,-0x48(%rbp)
  801303:	48 8b 02             	mov    (%rdx),%rax
  801306:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80130a:	48 85 c0             	test   %rax,%rax
  80130d:	0f 84 05 04 00 00    	je     801718 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  801313:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  801317:	7e 06                	jle    80131f <vprintfmt+0x24f>
  801319:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80131d:	75 31                	jne    801350 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80131f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  801323:	48 8d 58 01          	lea    0x1(%rax),%rbx
  801327:	0f b6 00             	movzbl (%rax),%eax
  80132a:	0f be f8             	movsbl %al,%edi
  80132d:	85 ff                	test   %edi,%edi
  80132f:	0f 84 c3 00 00 00    	je     8013f8 <vprintfmt+0x328>
  801335:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  801339:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80133d:	e9 85 00 00 00       	jmpq   8013c7 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  801342:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  801346:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80134a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80134e:	eb b3                	jmp    801303 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  801350:	49 63 f4             	movslq %r12d,%rsi
  801353:	48 89 c7             	mov    %rax,%rdi
  801356:	48 b8 a7 18 80 00 00 	movabs $0x8018a7,%rax
  80135d:	00 00 00 
  801360:	ff d0                	callq  *%rax
  801362:	29 45 ac             	sub    %eax,-0x54(%rbp)
  801365:	8b 75 ac             	mov    -0x54(%rbp),%esi
  801368:	85 f6                	test   %esi,%esi
  80136a:	7e 22                	jle    80138e <vprintfmt+0x2be>
            putch(padc, putdat);
  80136c:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  801370:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  801374:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  801378:	4c 89 fe             	mov    %r15,%rsi
  80137b:	89 df                	mov    %ebx,%edi
  80137d:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  801380:	41 83 ec 01          	sub    $0x1,%r12d
  801384:	75 f2                	jne    801378 <vprintfmt+0x2a8>
  801386:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80138a:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80138e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  801392:	48 8d 58 01          	lea    0x1(%rax),%rbx
  801396:	0f b6 00             	movzbl (%rax),%eax
  801399:	0f be f8             	movsbl %al,%edi
  80139c:	85 ff                	test   %edi,%edi
  80139e:	0f 84 56 fd ff ff    	je     8010fa <vprintfmt+0x2a>
  8013a4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8013a8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8013ac:	eb 19                	jmp    8013c7 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8013ae:	4c 89 fe             	mov    %r15,%rsi
  8013b1:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013b4:	41 83 ee 01          	sub    $0x1,%r14d
  8013b8:	48 83 c3 01          	add    $0x1,%rbx
  8013bc:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  8013c0:	0f be f8             	movsbl %al,%edi
  8013c3:	85 ff                	test   %edi,%edi
  8013c5:	74 29                	je     8013f0 <vprintfmt+0x320>
  8013c7:	45 85 e4             	test   %r12d,%r12d
  8013ca:	78 06                	js     8013d2 <vprintfmt+0x302>
  8013cc:	41 83 ec 01          	sub    $0x1,%r12d
  8013d0:	78 48                	js     80141a <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8013d2:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8013d6:	74 d6                	je     8013ae <vprintfmt+0x2de>
  8013d8:	0f be c0             	movsbl %al,%eax
  8013db:	83 e8 20             	sub    $0x20,%eax
  8013de:	83 f8 5e             	cmp    $0x5e,%eax
  8013e1:	76 cb                	jbe    8013ae <vprintfmt+0x2de>
            putch('?', putdat);
  8013e3:	4c 89 fe             	mov    %r15,%rsi
  8013e6:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8013eb:	41 ff d5             	callq  *%r13
  8013ee:	eb c4                	jmp    8013b4 <vprintfmt+0x2e4>
  8013f0:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8013f4:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8013f8:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8013fb:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8013ff:	0f 8e f5 fc ff ff    	jle    8010fa <vprintfmt+0x2a>
          putch(' ', putdat);
  801405:	4c 89 fe             	mov    %r15,%rsi
  801408:	bf 20 00 00 00       	mov    $0x20,%edi
  80140d:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  801410:	83 eb 01             	sub    $0x1,%ebx
  801413:	75 f0                	jne    801405 <vprintfmt+0x335>
  801415:	e9 e0 fc ff ff       	jmpq   8010fa <vprintfmt+0x2a>
  80141a:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80141e:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  801422:	eb d4                	jmp    8013f8 <vprintfmt+0x328>
  if (lflag >= 2)
  801424:	83 f9 01             	cmp    $0x1,%ecx
  801427:	7f 1d                	jg     801446 <vprintfmt+0x376>
  else if (lflag)
  801429:	85 c9                	test   %ecx,%ecx
  80142b:	74 5e                	je     80148b <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80142d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  801430:	83 f8 2f             	cmp    $0x2f,%eax
  801433:	77 48                	ja     80147d <vprintfmt+0x3ad>
  801435:	89 c2                	mov    %eax,%edx
  801437:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80143b:	83 c0 08             	add    $0x8,%eax
  80143e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  801441:	48 8b 1a             	mov    (%rdx),%rbx
  801444:	eb 17                	jmp    80145d <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  801446:	8b 45 b8             	mov    -0x48(%rbp),%eax
  801449:	83 f8 2f             	cmp    $0x2f,%eax
  80144c:	77 21                	ja     80146f <vprintfmt+0x39f>
  80144e:	89 c2                	mov    %eax,%edx
  801450:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801454:	83 c0 08             	add    $0x8,%eax
  801457:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80145a:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80145d:	48 85 db             	test   %rbx,%rbx
  801460:	78 50                	js     8014b2 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  801462:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  801465:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80146a:	e9 b4 01 00 00       	jmpq   801623 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80146f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  801473:	48 8d 42 08          	lea    0x8(%rdx),%rax
  801477:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80147b:	eb dd                	jmp    80145a <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80147d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  801481:	48 8d 42 08          	lea    0x8(%rdx),%rax
  801485:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  801489:	eb b6                	jmp    801441 <vprintfmt+0x371>
    return va_arg(*ap, int);
  80148b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80148e:	83 f8 2f             	cmp    $0x2f,%eax
  801491:	77 11                	ja     8014a4 <vprintfmt+0x3d4>
  801493:	89 c2                	mov    %eax,%edx
  801495:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801499:	83 c0 08             	add    $0x8,%eax
  80149c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80149f:	48 63 1a             	movslq (%rdx),%rbx
  8014a2:	eb b9                	jmp    80145d <vprintfmt+0x38d>
  8014a4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8014a8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8014ac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8014b0:	eb ed                	jmp    80149f <vprintfmt+0x3cf>
          putch('-', putdat);
  8014b2:	4c 89 fe             	mov    %r15,%rsi
  8014b5:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8014ba:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8014bd:	48 89 da             	mov    %rbx,%rdx
  8014c0:	48 f7 da             	neg    %rdx
        base = 10;
  8014c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014c8:	e9 56 01 00 00       	jmpq   801623 <vprintfmt+0x553>
  if (lflag >= 2)
  8014cd:	83 f9 01             	cmp    $0x1,%ecx
  8014d0:	7f 25                	jg     8014f7 <vprintfmt+0x427>
  else if (lflag)
  8014d2:	85 c9                	test   %ecx,%ecx
  8014d4:	74 5e                	je     801534 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8014d6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8014d9:	83 f8 2f             	cmp    $0x2f,%eax
  8014dc:	77 48                	ja     801526 <vprintfmt+0x456>
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8014e4:	83 c0 08             	add    $0x8,%eax
  8014e7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8014ea:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8014ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014f2:	e9 2c 01 00 00       	jmpq   801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8014f7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8014fa:	83 f8 2f             	cmp    $0x2f,%eax
  8014fd:	77 19                	ja     801518 <vprintfmt+0x448>
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801505:	83 c0 08             	add    $0x8,%eax
  801508:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80150b:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80150e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801513:	e9 0b 01 00 00       	jmpq   801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  801518:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80151c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  801520:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  801524:	eb e5                	jmp    80150b <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  801526:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80152a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80152e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  801532:	eb b6                	jmp    8014ea <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  801534:	8b 45 b8             	mov    -0x48(%rbp),%eax
  801537:	83 f8 2f             	cmp    $0x2f,%eax
  80153a:	77 18                	ja     801554 <vprintfmt+0x484>
  80153c:	89 c2                	mov    %eax,%edx
  80153e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801542:	83 c0 08             	add    $0x8,%eax
  801545:	89 45 b8             	mov    %eax,-0x48(%rbp)
  801548:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80154a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80154f:	e9 cf 00 00 00       	jmpq   801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  801554:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  801558:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80155c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  801560:	eb e6                	jmp    801548 <vprintfmt+0x478>
  if (lflag >= 2)
  801562:	83 f9 01             	cmp    $0x1,%ecx
  801565:	7f 25                	jg     80158c <vprintfmt+0x4bc>
  else if (lflag)
  801567:	85 c9                	test   %ecx,%ecx
  801569:	74 5b                	je     8015c6 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  80156b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80156e:	83 f8 2f             	cmp    $0x2f,%eax
  801571:	77 45                	ja     8015b8 <vprintfmt+0x4e8>
  801573:	89 c2                	mov    %eax,%edx
  801575:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801579:	83 c0 08             	add    $0x8,%eax
  80157c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80157f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  801582:	b9 08 00 00 00       	mov    $0x8,%ecx
  801587:	e9 97 00 00 00       	jmpq   801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80158c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80158f:	83 f8 2f             	cmp    $0x2f,%eax
  801592:	77 16                	ja     8015aa <vprintfmt+0x4da>
  801594:	89 c2                	mov    %eax,%edx
  801596:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80159a:	83 c0 08             	add    $0x8,%eax
  80159d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8015a0:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8015a3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8015a8:	eb 79                	jmp    801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8015aa:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8015ae:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8015b2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8015b6:	eb e8                	jmp    8015a0 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8015b8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8015bc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8015c0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8015c4:	eb b9                	jmp    80157f <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8015c6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8015c9:	83 f8 2f             	cmp    $0x2f,%eax
  8015cc:	77 15                	ja     8015e3 <vprintfmt+0x513>
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8015d4:	83 c0 08             	add    $0x8,%eax
  8015d7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8015da:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8015dc:	b9 08 00 00 00       	mov    $0x8,%ecx
  8015e1:	eb 40                	jmp    801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8015e3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8015e7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8015eb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8015ef:	eb e9                	jmp    8015da <vprintfmt+0x50a>
        putch('0', putdat);
  8015f1:	4c 89 fe             	mov    %r15,%rsi
  8015f4:	bf 30 00 00 00       	mov    $0x30,%edi
  8015f9:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8015fc:	4c 89 fe             	mov    %r15,%rsi
  8015ff:	bf 78 00 00 00       	mov    $0x78,%edi
  801604:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  801607:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80160a:	83 f8 2f             	cmp    $0x2f,%eax
  80160d:	77 34                	ja     801643 <vprintfmt+0x573>
  80160f:	89 c2                	mov    %eax,%edx
  801611:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801615:	83 c0 08             	add    $0x8,%eax
  801618:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80161b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80161e:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  801623:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  801628:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  80162c:	4c 89 fe             	mov    %r15,%rsi
  80162f:	4c 89 ef             	mov    %r13,%rdi
  801632:	48 b8 a6 0f 80 00 00 	movabs $0x800fa6,%rax
  801639:	00 00 00 
  80163c:	ff d0                	callq  *%rax
        break;
  80163e:	e9 b7 fa ff ff       	jmpq   8010fa <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  801643:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  801647:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80164b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80164f:	eb ca                	jmp    80161b <vprintfmt+0x54b>
  if (lflag >= 2)
  801651:	83 f9 01             	cmp    $0x1,%ecx
  801654:	7f 22                	jg     801678 <vprintfmt+0x5a8>
  else if (lflag)
  801656:	85 c9                	test   %ecx,%ecx
  801658:	74 58                	je     8016b2 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  80165a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80165d:	83 f8 2f             	cmp    $0x2f,%eax
  801660:	77 42                	ja     8016a4 <vprintfmt+0x5d4>
  801662:	89 c2                	mov    %eax,%edx
  801664:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801668:	83 c0 08             	add    $0x8,%eax
  80166b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80166e:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  801671:	b9 10 00 00 00       	mov    $0x10,%ecx
  801676:	eb ab                	jmp    801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  801678:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80167b:	83 f8 2f             	cmp    $0x2f,%eax
  80167e:	77 16                	ja     801696 <vprintfmt+0x5c6>
  801680:	89 c2                	mov    %eax,%edx
  801682:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  801686:	83 c0 08             	add    $0x8,%eax
  801689:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80168c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80168f:	b9 10 00 00 00       	mov    $0x10,%ecx
  801694:	eb 8d                	jmp    801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  801696:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80169a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80169e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8016a2:	eb e8                	jmp    80168c <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  8016a4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8016a8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8016ac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8016b0:	eb bc                	jmp    80166e <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  8016b2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8016b5:	83 f8 2f             	cmp    $0x2f,%eax
  8016b8:	77 18                	ja     8016d2 <vprintfmt+0x602>
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8016c0:	83 c0 08             	add    $0x8,%eax
  8016c3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8016c6:	8b 12                	mov    (%rdx),%edx
        base = 16;
  8016c8:	b9 10 00 00 00       	mov    $0x10,%ecx
  8016cd:	e9 51 ff ff ff       	jmpq   801623 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8016d2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8016d6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8016da:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8016de:	eb e6                	jmp    8016c6 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8016e0:	4c 89 fe             	mov    %r15,%rsi
  8016e3:	bf 25 00 00 00       	mov    $0x25,%edi
  8016e8:	41 ff d5             	callq  *%r13
        break;
  8016eb:	e9 0a fa ff ff       	jmpq   8010fa <vprintfmt+0x2a>
        putch('%', putdat);
  8016f0:	4c 89 fe             	mov    %r15,%rsi
  8016f3:	bf 25 00 00 00       	mov    $0x25,%edi
  8016f8:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8016fb:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8016ff:	0f 84 15 fa ff ff    	je     80111a <vprintfmt+0x4a>
  801705:	49 89 de             	mov    %rbx,%r14
  801708:	49 83 ee 01          	sub    $0x1,%r14
  80170c:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  801711:	75 f5                	jne    801708 <vprintfmt+0x638>
  801713:	e9 e2 f9 ff ff       	jmpq   8010fa <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  801718:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80171c:	74 06                	je     801724 <vprintfmt+0x654>
  80171e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  801722:	7f 21                	jg     801745 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801724:	bf 28 00 00 00       	mov    $0x28,%edi
  801729:	48 bb b5 22 80 00 00 	movabs $0x8022b5,%rbx
  801730:	00 00 00 
  801733:	b8 28 00 00 00       	mov    $0x28,%eax
  801738:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80173c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  801740:	e9 82 fc ff ff       	jmpq   8013c7 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  801745:	49 63 f4             	movslq %r12d,%rsi
  801748:	48 bf b4 22 80 00 00 	movabs $0x8022b4,%rdi
  80174f:	00 00 00 
  801752:	48 b8 a7 18 80 00 00 	movabs $0x8018a7,%rax
  801759:	00 00 00 
  80175c:	ff d0                	callq  *%rax
  80175e:	29 45 ac             	sub    %eax,-0x54(%rbp)
  801761:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  801764:	48 be b4 22 80 00 00 	movabs $0x8022b4,%rsi
  80176b:	00 00 00 
  80176e:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  801772:	85 c0                	test   %eax,%eax
  801774:	0f 8f f2 fb ff ff    	jg     80136c <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80177a:	48 bb b5 22 80 00 00 	movabs $0x8022b5,%rbx
  801781:	00 00 00 
  801784:	b8 28 00 00 00       	mov    $0x28,%eax
  801789:	bf 28 00 00 00       	mov    $0x28,%edi
  80178e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  801792:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  801796:	e9 2c fc ff ff       	jmpq   8013c7 <vprintfmt+0x2f7>
}
  80179b:	48 83 c4 48          	add    $0x48,%rsp
  80179f:	5b                   	pop    %rbx
  8017a0:	41 5c                	pop    %r12
  8017a2:	41 5d                	pop    %r13
  8017a4:	41 5e                	pop    %r14
  8017a6:	41 5f                	pop    %r15
  8017a8:	5d                   	pop    %rbp
  8017a9:	c3                   	retq   

00000000008017aa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8017aa:	55                   	push   %rbp
  8017ab:	48 89 e5             	mov    %rsp,%rbp
  8017ae:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  8017b2:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  8017b6:	48 63 c6             	movslq %esi,%rax
  8017b9:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  8017be:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8017c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  8017c9:	48 85 ff             	test   %rdi,%rdi
  8017cc:	74 2a                	je     8017f8 <vsnprintf+0x4e>
  8017ce:	85 f6                	test   %esi,%esi
  8017d0:	7e 26                	jle    8017f8 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  8017d2:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  8017d6:	48 bf 32 10 80 00 00 	movabs $0x801032,%rdi
  8017dd:	00 00 00 
  8017e0:	48 b8 d0 10 80 00 00 	movabs $0x8010d0,%rax
  8017e7:	00 00 00 
  8017ea:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  8017ec:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8017f0:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  8017f3:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  8017f6:	c9                   	leaveq 
  8017f7:	c3                   	retq   
    return -E_INVAL;
  8017f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017fd:	eb f7                	jmp    8017f6 <vsnprintf+0x4c>

00000000008017ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  8017ff:	55                   	push   %rbp
  801800:	48 89 e5             	mov    %rsp,%rbp
  801803:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80180a:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  801811:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  801818:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80181f:	84 c0                	test   %al,%al
  801821:	74 20                	je     801843 <snprintf+0x44>
  801823:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  801827:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80182b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80182f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  801833:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  801837:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80183b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80183f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  801843:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80184a:	00 00 00 
  80184d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  801854:	00 00 00 
  801857:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80185b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  801862:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  801869:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  801870:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  801877:	48 b8 aa 17 80 00 00 	movabs $0x8017aa,%rax
  80187e:	00 00 00 
  801881:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  801883:	c9                   	leaveq 
  801884:	c3                   	retq   

0000000000801885 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  801885:	80 3f 00             	cmpb   $0x0,(%rdi)
  801888:	74 17                	je     8018a1 <strlen+0x1c>
  80188a:	48 89 fa             	mov    %rdi,%rdx
  80188d:	b9 01 00 00 00       	mov    $0x1,%ecx
  801892:	29 f9                	sub    %edi,%ecx
    n++;
  801894:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  801897:	48 83 c2 01          	add    $0x1,%rdx
  80189b:	80 3a 00             	cmpb   $0x0,(%rdx)
  80189e:	75 f4                	jne    801894 <strlen+0xf>
  8018a0:	c3                   	retq   
  8018a1:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8018a6:	c3                   	retq   

00000000008018a7 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018a7:	48 85 f6             	test   %rsi,%rsi
  8018aa:	74 24                	je     8018d0 <strnlen+0x29>
  8018ac:	80 3f 00             	cmpb   $0x0,(%rdi)
  8018af:	74 25                	je     8018d6 <strnlen+0x2f>
  8018b1:	48 01 fe             	add    %rdi,%rsi
  8018b4:	48 89 fa             	mov    %rdi,%rdx
  8018b7:	b9 01 00 00 00       	mov    $0x1,%ecx
  8018bc:	29 f9                	sub    %edi,%ecx
    n++;
  8018be:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018c1:	48 83 c2 01          	add    $0x1,%rdx
  8018c5:	48 39 f2             	cmp    %rsi,%rdx
  8018c8:	74 11                	je     8018db <strnlen+0x34>
  8018ca:	80 3a 00             	cmpb   $0x0,(%rdx)
  8018cd:	75 ef                	jne    8018be <strnlen+0x17>
  8018cf:	c3                   	retq   
  8018d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d5:	c3                   	retq   
  8018d6:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8018db:	c3                   	retq   

00000000008018dc <strcpy>:

char *
strcpy(char *dst, const char *src) {
  8018dc:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  8018e8:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  8018eb:	48 83 c2 01          	add    $0x1,%rdx
  8018ef:	84 c9                	test   %cl,%cl
  8018f1:	75 f1                	jne    8018e4 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  8018f3:	c3                   	retq   

00000000008018f4 <strcat>:

char *
strcat(char *dst, const char *src) {
  8018f4:	55                   	push   %rbp
  8018f5:	48 89 e5             	mov    %rsp,%rbp
  8018f8:	41 54                	push   %r12
  8018fa:	53                   	push   %rbx
  8018fb:	48 89 fb             	mov    %rdi,%rbx
  8018fe:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  801901:	48 b8 85 18 80 00 00 	movabs $0x801885,%rax
  801908:	00 00 00 
  80190b:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  80190d:	48 63 f8             	movslq %eax,%rdi
  801910:	48 01 df             	add    %rbx,%rdi
  801913:	4c 89 e6             	mov    %r12,%rsi
  801916:	48 b8 dc 18 80 00 00 	movabs $0x8018dc,%rax
  80191d:	00 00 00 
  801920:	ff d0                	callq  *%rax
  return dst;
}
  801922:	48 89 d8             	mov    %rbx,%rax
  801925:	5b                   	pop    %rbx
  801926:	41 5c                	pop    %r12
  801928:	5d                   	pop    %rbp
  801929:	c3                   	retq   

000000000080192a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80192a:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  80192d:	48 85 d2             	test   %rdx,%rdx
  801930:	74 1f                	je     801951 <strncpy+0x27>
  801932:	48 01 fa             	add    %rdi,%rdx
  801935:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  801938:	48 83 c1 01          	add    $0x1,%rcx
  80193c:	44 0f b6 06          	movzbl (%rsi),%r8d
  801940:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  801944:	41 80 f8 01          	cmp    $0x1,%r8b
  801948:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  80194c:	48 39 ca             	cmp    %rcx,%rdx
  80194f:	75 e7                	jne    801938 <strncpy+0xe>
  }
  return ret;
}
  801951:	c3                   	retq   

0000000000801952 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  801952:	48 89 f8             	mov    %rdi,%rax
  801955:	48 85 d2             	test   %rdx,%rdx
  801958:	74 36                	je     801990 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  80195a:	48 83 fa 01          	cmp    $0x1,%rdx
  80195e:	74 2d                	je     80198d <strlcpy+0x3b>
  801960:	44 0f b6 06          	movzbl (%rsi),%r8d
  801964:	45 84 c0             	test   %r8b,%r8b
  801967:	74 24                	je     80198d <strlcpy+0x3b>
  801969:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  80196d:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  801972:	48 83 c0 01          	add    $0x1,%rax
  801976:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  80197a:	48 39 d1             	cmp    %rdx,%rcx
  80197d:	74 0e                	je     80198d <strlcpy+0x3b>
  80197f:	48 83 c1 01          	add    $0x1,%rcx
  801983:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  801988:	45 84 c0             	test   %r8b,%r8b
  80198b:	75 e5                	jne    801972 <strlcpy+0x20>
    *dst = '\0';
  80198d:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  801990:	48 29 f8             	sub    %rdi,%rax
}
  801993:	c3                   	retq   

0000000000801994 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  801994:	0f b6 07             	movzbl (%rdi),%eax
  801997:	84 c0                	test   %al,%al
  801999:	74 17                	je     8019b2 <strcmp+0x1e>
  80199b:	3a 06                	cmp    (%rsi),%al
  80199d:	75 13                	jne    8019b2 <strcmp+0x1e>
    p++, q++;
  80199f:	48 83 c7 01          	add    $0x1,%rdi
  8019a3:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  8019a7:	0f b6 07             	movzbl (%rdi),%eax
  8019aa:	84 c0                	test   %al,%al
  8019ac:	74 04                	je     8019b2 <strcmp+0x1e>
  8019ae:	3a 06                	cmp    (%rsi),%al
  8019b0:	74 ed                	je     80199f <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8019b2:	0f b6 c0             	movzbl %al,%eax
  8019b5:	0f b6 16             	movzbl (%rsi),%edx
  8019b8:	29 d0                	sub    %edx,%eax
}
  8019ba:	c3                   	retq   

00000000008019bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8019bb:	48 85 d2             	test   %rdx,%rdx
  8019be:	74 2f                	je     8019ef <strncmp+0x34>
  8019c0:	0f b6 07             	movzbl (%rdi),%eax
  8019c3:	84 c0                	test   %al,%al
  8019c5:	74 1f                	je     8019e6 <strncmp+0x2b>
  8019c7:	3a 06                	cmp    (%rsi),%al
  8019c9:	75 1b                	jne    8019e6 <strncmp+0x2b>
  8019cb:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8019ce:	48 83 c7 01          	add    $0x1,%rdi
  8019d2:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8019d6:	48 39 d7             	cmp    %rdx,%rdi
  8019d9:	74 1a                	je     8019f5 <strncmp+0x3a>
  8019db:	0f b6 07             	movzbl (%rdi),%eax
  8019de:	84 c0                	test   %al,%al
  8019e0:	74 04                	je     8019e6 <strncmp+0x2b>
  8019e2:	3a 06                	cmp    (%rsi),%al
  8019e4:	74 e8                	je     8019ce <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8019e6:	0f b6 07             	movzbl (%rdi),%eax
  8019e9:	0f b6 16             	movzbl (%rsi),%edx
  8019ec:	29 d0                	sub    %edx,%eax
}
  8019ee:	c3                   	retq   
    return 0;
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f4:	c3                   	retq   
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	c3                   	retq   

00000000008019fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8019fb:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8019fd:	0f b6 07             	movzbl (%rdi),%eax
  801a00:	84 c0                	test   %al,%al
  801a02:	74 1e                	je     801a22 <strchr+0x27>
    if (*s == c)
  801a04:	40 38 c6             	cmp    %al,%sil
  801a07:	74 1f                	je     801a28 <strchr+0x2d>
  for (; *s; s++)
  801a09:	48 83 c7 01          	add    $0x1,%rdi
  801a0d:	0f b6 07             	movzbl (%rdi),%eax
  801a10:	84 c0                	test   %al,%al
  801a12:	74 08                	je     801a1c <strchr+0x21>
    if (*s == c)
  801a14:	38 d0                	cmp    %dl,%al
  801a16:	75 f1                	jne    801a09 <strchr+0xe>
  for (; *s; s++)
  801a18:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  801a1b:	c3                   	retq   
  return 0;
  801a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a21:	c3                   	retq   
  801a22:	b8 00 00 00 00       	mov    $0x0,%eax
  801a27:	c3                   	retq   
    if (*s == c)
  801a28:	48 89 f8             	mov    %rdi,%rax
  801a2b:	c3                   	retq   

0000000000801a2c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  801a2c:	48 89 f8             	mov    %rdi,%rax
  801a2f:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  801a31:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  801a34:	40 38 f2             	cmp    %sil,%dl
  801a37:	74 13                	je     801a4c <strfind+0x20>
  801a39:	84 d2                	test   %dl,%dl
  801a3b:	74 0f                	je     801a4c <strfind+0x20>
  for (; *s; s++)
  801a3d:	48 83 c0 01          	add    $0x1,%rax
  801a41:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  801a44:	38 ca                	cmp    %cl,%dl
  801a46:	74 04                	je     801a4c <strfind+0x20>
  801a48:	84 d2                	test   %dl,%dl
  801a4a:	75 f1                	jne    801a3d <strfind+0x11>
      break;
  return (char *)s;
}
  801a4c:	c3                   	retq   

0000000000801a4d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  801a4d:	48 85 d2             	test   %rdx,%rdx
  801a50:	74 3a                	je     801a8c <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801a52:	48 89 f8             	mov    %rdi,%rax
  801a55:	48 09 d0             	or     %rdx,%rax
  801a58:	a8 03                	test   $0x3,%al
  801a5a:	75 28                	jne    801a84 <memset+0x37>
    uint32_t k = c & 0xFFU;
  801a5c:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  801a60:	89 f0                	mov    %esi,%eax
  801a62:	c1 e0 08             	shl    $0x8,%eax
  801a65:	89 f1                	mov    %esi,%ecx
  801a67:	c1 e1 18             	shl    $0x18,%ecx
  801a6a:	41 89 f0             	mov    %esi,%r8d
  801a6d:	41 c1 e0 10          	shl    $0x10,%r8d
  801a71:	44 09 c1             	or     %r8d,%ecx
  801a74:	09 ce                	or     %ecx,%esi
  801a76:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  801a78:	48 c1 ea 02          	shr    $0x2,%rdx
  801a7c:	48 89 d1             	mov    %rdx,%rcx
  801a7f:	fc                   	cld    
  801a80:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  801a82:	eb 08                	jmp    801a8c <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  801a84:	89 f0                	mov    %esi,%eax
  801a86:	48 89 d1             	mov    %rdx,%rcx
  801a89:	fc                   	cld    
  801a8a:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  801a8c:	48 89 f8             	mov    %rdi,%rax
  801a8f:	c3                   	retq   

0000000000801a90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  801a90:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  801a93:	48 39 fe             	cmp    %rdi,%rsi
  801a96:	73 40                	jae    801ad8 <memmove+0x48>
  801a98:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  801a9c:	48 39 f9             	cmp    %rdi,%rcx
  801a9f:	76 37                	jbe    801ad8 <memmove+0x48>
    s += n;
    d += n;
  801aa1:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801aa5:	48 89 fe             	mov    %rdi,%rsi
  801aa8:	48 09 d6             	or     %rdx,%rsi
  801aab:	48 09 ce             	or     %rcx,%rsi
  801aae:	40 f6 c6 03          	test   $0x3,%sil
  801ab2:	75 14                	jne    801ac8 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  801ab4:	48 83 ef 04          	sub    $0x4,%rdi
  801ab8:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  801abc:	48 c1 ea 02          	shr    $0x2,%rdx
  801ac0:	48 89 d1             	mov    %rdx,%rcx
  801ac3:	fd                   	std    
  801ac4:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  801ac6:	eb 0e                	jmp    801ad6 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  801ac8:	48 83 ef 01          	sub    $0x1,%rdi
  801acc:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  801ad0:	48 89 d1             	mov    %rdx,%rcx
  801ad3:	fd                   	std    
  801ad4:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  801ad6:	fc                   	cld    
  801ad7:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  801ad8:	48 89 c1             	mov    %rax,%rcx
  801adb:	48 09 d1             	or     %rdx,%rcx
  801ade:	48 09 f1             	or     %rsi,%rcx
  801ae1:	f6 c1 03             	test   $0x3,%cl
  801ae4:	75 0e                	jne    801af4 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  801ae6:	48 c1 ea 02          	shr    $0x2,%rdx
  801aea:	48 89 d1             	mov    %rdx,%rcx
  801aed:	48 89 c7             	mov    %rax,%rdi
  801af0:	fc                   	cld    
  801af1:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  801af3:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  801af4:	48 89 c7             	mov    %rax,%rdi
  801af7:	48 89 d1             	mov    %rdx,%rcx
  801afa:	fc                   	cld    
  801afb:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  801afd:	c3                   	retq   

0000000000801afe <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  801afe:	55                   	push   %rbp
  801aff:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  801b02:	48 b8 90 1a 80 00 00 	movabs $0x801a90,%rax
  801b09:	00 00 00 
  801b0c:	ff d0                	callq  *%rax
}
  801b0e:	5d                   	pop    %rbp
  801b0f:	c3                   	retq   

0000000000801b10 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  801b10:	55                   	push   %rbp
  801b11:	48 89 e5             	mov    %rsp,%rbp
  801b14:	41 57                	push   %r15
  801b16:	41 56                	push   %r14
  801b18:	41 55                	push   %r13
  801b1a:	41 54                	push   %r12
  801b1c:	53                   	push   %rbx
  801b1d:	48 83 ec 08          	sub    $0x8,%rsp
  801b21:	49 89 fe             	mov    %rdi,%r14
  801b24:	49 89 f7             	mov    %rsi,%r15
  801b27:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  801b2a:	48 89 f7             	mov    %rsi,%rdi
  801b2d:	48 b8 85 18 80 00 00 	movabs $0x801885,%rax
  801b34:	00 00 00 
  801b37:	ff d0                	callq  *%rax
  801b39:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  801b3c:	4c 89 ee             	mov    %r13,%rsi
  801b3f:	4c 89 f7             	mov    %r14,%rdi
  801b42:	48 b8 a7 18 80 00 00 	movabs $0x8018a7,%rax
  801b49:	00 00 00 
  801b4c:	ff d0                	callq  *%rax
  801b4e:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  801b51:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  801b55:	4d 39 e5             	cmp    %r12,%r13
  801b58:	74 26                	je     801b80 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  801b5a:	4c 89 e8             	mov    %r13,%rax
  801b5d:	4c 29 e0             	sub    %r12,%rax
  801b60:	48 39 d8             	cmp    %rbx,%rax
  801b63:	76 2a                	jbe    801b8f <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  801b65:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  801b69:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801b6d:	4c 89 fe             	mov    %r15,%rsi
  801b70:	48 b8 fe 1a 80 00 00 	movabs $0x801afe,%rax
  801b77:	00 00 00 
  801b7a:	ff d0                	callq  *%rax
  return dstlen + srclen;
  801b7c:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  801b80:	48 83 c4 08          	add    $0x8,%rsp
  801b84:	5b                   	pop    %rbx
  801b85:	41 5c                	pop    %r12
  801b87:	41 5d                	pop    %r13
  801b89:	41 5e                	pop    %r14
  801b8b:	41 5f                	pop    %r15
  801b8d:	5d                   	pop    %rbp
  801b8e:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  801b8f:	49 83 ed 01          	sub    $0x1,%r13
  801b93:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  801b97:	4c 89 ea             	mov    %r13,%rdx
  801b9a:	4c 89 fe             	mov    %r15,%rsi
  801b9d:	48 b8 fe 1a 80 00 00 	movabs $0x801afe,%rax
  801ba4:	00 00 00 
  801ba7:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  801ba9:	4d 01 ee             	add    %r13,%r14
  801bac:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  801bb1:	eb c9                	jmp    801b7c <strlcat+0x6c>

0000000000801bb3 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  801bb3:	48 85 d2             	test   %rdx,%rdx
  801bb6:	74 3a                	je     801bf2 <memcmp+0x3f>
    if (*s1 != *s2)
  801bb8:	0f b6 0f             	movzbl (%rdi),%ecx
  801bbb:	44 0f b6 06          	movzbl (%rsi),%r8d
  801bbf:	44 38 c1             	cmp    %r8b,%cl
  801bc2:	75 1d                	jne    801be1 <memcmp+0x2e>
  801bc4:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  801bc9:	48 39 d0             	cmp    %rdx,%rax
  801bcc:	74 1e                	je     801bec <memcmp+0x39>
    if (*s1 != *s2)
  801bce:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  801bd2:	48 83 c0 01          	add    $0x1,%rax
  801bd6:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  801bdc:	44 38 c1             	cmp    %r8b,%cl
  801bdf:	74 e8                	je     801bc9 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  801be1:	0f b6 c1             	movzbl %cl,%eax
  801be4:	45 0f b6 c0          	movzbl %r8b,%r8d
  801be8:	44 29 c0             	sub    %r8d,%eax
  801beb:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  801bec:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf1:	c3                   	retq   
  801bf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf7:	c3                   	retq   

0000000000801bf8 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  801bf8:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  801bfc:	48 39 c7             	cmp    %rax,%rdi
  801bff:	73 19                	jae    801c1a <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  801c01:	89 f2                	mov    %esi,%edx
  801c03:	40 38 37             	cmp    %sil,(%rdi)
  801c06:	74 16                	je     801c1e <memfind+0x26>
  for (; s < ends; s++)
  801c08:	48 83 c7 01          	add    $0x1,%rdi
  801c0c:	48 39 f8             	cmp    %rdi,%rax
  801c0f:	74 08                	je     801c19 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  801c11:	38 17                	cmp    %dl,(%rdi)
  801c13:	75 f3                	jne    801c08 <memfind+0x10>
  for (; s < ends; s++)
  801c15:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  801c18:	c3                   	retq   
  801c19:	c3                   	retq   
  for (; s < ends; s++)
  801c1a:	48 89 f8             	mov    %rdi,%rax
  801c1d:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  801c1e:	48 89 f8             	mov    %rdi,%rax
  801c21:	c3                   	retq   

0000000000801c22 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  801c22:	0f b6 07             	movzbl (%rdi),%eax
  801c25:	3c 20                	cmp    $0x20,%al
  801c27:	74 04                	je     801c2d <strtol+0xb>
  801c29:	3c 09                	cmp    $0x9,%al
  801c2b:	75 0f                	jne    801c3c <strtol+0x1a>
    s++;
  801c2d:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  801c31:	0f b6 07             	movzbl (%rdi),%eax
  801c34:	3c 20                	cmp    $0x20,%al
  801c36:	74 f5                	je     801c2d <strtol+0xb>
  801c38:	3c 09                	cmp    $0x9,%al
  801c3a:	74 f1                	je     801c2d <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  801c3c:	3c 2b                	cmp    $0x2b,%al
  801c3e:	74 2b                	je     801c6b <strtol+0x49>
  int neg  = 0;
  801c40:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  801c46:	3c 2d                	cmp    $0x2d,%al
  801c48:	74 2d                	je     801c77 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c4a:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  801c50:	75 0f                	jne    801c61 <strtol+0x3f>
  801c52:	80 3f 30             	cmpb   $0x30,(%rdi)
  801c55:	74 2c                	je     801c83 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  801c57:	85 d2                	test   %edx,%edx
  801c59:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c5e:	0f 44 d0             	cmove  %eax,%edx
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  801c66:	4c 63 d2             	movslq %edx,%r10
  801c69:	eb 5c                	jmp    801cc7 <strtol+0xa5>
    s++;
  801c6b:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  801c6f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  801c75:	eb d3                	jmp    801c4a <strtol+0x28>
    s++, neg = 1;
  801c77:	48 83 c7 01          	add    $0x1,%rdi
  801c7b:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  801c81:	eb c7                	jmp    801c4a <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c83:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  801c87:	74 0f                	je     801c98 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  801c89:	85 d2                	test   %edx,%edx
  801c8b:	75 d4                	jne    801c61 <strtol+0x3f>
    s++, base = 8;
  801c8d:	48 83 c7 01          	add    $0x1,%rdi
  801c91:	ba 08 00 00 00       	mov    $0x8,%edx
  801c96:	eb c9                	jmp    801c61 <strtol+0x3f>
    s += 2, base = 16;
  801c98:	48 83 c7 02          	add    $0x2,%rdi
  801c9c:	ba 10 00 00 00       	mov    $0x10,%edx
  801ca1:	eb be                	jmp    801c61 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  801ca3:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  801ca7:	41 80 f8 19          	cmp    $0x19,%r8b
  801cab:	77 2f                	ja     801cdc <strtol+0xba>
      dig = *s - 'a' + 10;
  801cad:	44 0f be c1          	movsbl %cl,%r8d
  801cb1:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  801cb5:	39 d1                	cmp    %edx,%ecx
  801cb7:	7d 37                	jge    801cf0 <strtol+0xce>
    s++, val = (val * base) + dig;
  801cb9:	48 83 c7 01          	add    $0x1,%rdi
  801cbd:	49 0f af c2          	imul   %r10,%rax
  801cc1:	48 63 c9             	movslq %ecx,%rcx
  801cc4:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  801cc7:	0f b6 0f             	movzbl (%rdi),%ecx
  801cca:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  801cce:	41 80 f8 09          	cmp    $0x9,%r8b
  801cd2:	77 cf                	ja     801ca3 <strtol+0x81>
      dig = *s - '0';
  801cd4:	0f be c9             	movsbl %cl,%ecx
  801cd7:	83 e9 30             	sub    $0x30,%ecx
  801cda:	eb d9                	jmp    801cb5 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  801cdc:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  801ce0:	41 80 f8 19          	cmp    $0x19,%r8b
  801ce4:	77 0a                	ja     801cf0 <strtol+0xce>
      dig = *s - 'A' + 10;
  801ce6:	44 0f be c1          	movsbl %cl,%r8d
  801cea:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  801cee:	eb c5                	jmp    801cb5 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  801cf0:	48 85 f6             	test   %rsi,%rsi
  801cf3:	74 03                	je     801cf8 <strtol+0xd6>
    *endptr = (char *)s;
  801cf5:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  801cf8:	48 89 c2             	mov    %rax,%rdx
  801cfb:	48 f7 da             	neg    %rdx
  801cfe:	45 85 c9             	test   %r9d,%r9d
  801d01:	48 0f 45 c2          	cmovne %rdx,%rax
}
  801d05:	c3                   	retq   

0000000000801d06 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  801d06:	55                   	push   %rbp
  801d07:	48 89 e5             	mov    %rsp,%rbp
  801d0a:	53                   	push   %rbx
  801d0b:	48 89 fa             	mov    %rdi,%rdx
  801d0e:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
  801d16:	48 89 c3             	mov    %rax,%rbx
  801d19:	48 89 c7             	mov    %rax,%rdi
  801d1c:	48 89 c6             	mov    %rax,%rsi
  801d1f:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  801d21:	5b                   	pop    %rbx
  801d22:	5d                   	pop    %rbp
  801d23:	c3                   	retq   

0000000000801d24 <sys_cgetc>:

int
sys_cgetc(void) {
  801d24:	55                   	push   %rbp
  801d25:	48 89 e5             	mov    %rsp,%rbp
  801d28:	53                   	push   %rbx
  asm volatile("int %1\n"
  801d29:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d2e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d33:	48 89 ca             	mov    %rcx,%rdx
  801d36:	48 89 cb             	mov    %rcx,%rbx
  801d39:	48 89 cf             	mov    %rcx,%rdi
  801d3c:	48 89 ce             	mov    %rcx,%rsi
  801d3f:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801d41:	5b                   	pop    %rbx
  801d42:	5d                   	pop    %rbp
  801d43:	c3                   	retq   

0000000000801d44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801d44:	55                   	push   %rbp
  801d45:	48 89 e5             	mov    %rsp,%rbp
  801d48:	53                   	push   %rbx
  801d49:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801d4d:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801d50:	be 00 00 00 00       	mov    $0x0,%esi
  801d55:	b8 03 00 00 00       	mov    $0x3,%eax
  801d5a:	48 89 f1             	mov    %rsi,%rcx
  801d5d:	48 89 f3             	mov    %rsi,%rbx
  801d60:	48 89 f7             	mov    %rsi,%rdi
  801d63:	cd 30                	int    $0x30
  if (check && ret > 0)
  801d65:	48 85 c0             	test   %rax,%rax
  801d68:	7f 07                	jg     801d71 <sys_env_destroy+0x2d>
}
  801d6a:	48 83 c4 08          	add    $0x8,%rsp
  801d6e:	5b                   	pop    %rbx
  801d6f:	5d                   	pop    %rbp
  801d70:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801d71:	49 89 c0             	mov    %rax,%r8
  801d74:	b9 03 00 00 00       	mov    $0x3,%ecx
  801d79:	48 ba a0 26 80 00 00 	movabs $0x8026a0,%rdx
  801d80:	00 00 00 
  801d83:	be 22 00 00 00       	mov    $0x22,%esi
  801d88:	48 bf c0 26 80 00 00 	movabs $0x8026c0,%rdi
  801d8f:	00 00 00 
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
  801d97:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  801d9e:	00 00 00 
  801da1:	41 ff d1             	callq  *%r9

0000000000801da4 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801da4:	55                   	push   %rbp
  801da5:	48 89 e5             	mov    %rsp,%rbp
  801da8:	53                   	push   %rbx
  asm volatile("int %1\n"
  801da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dae:	b8 02 00 00 00       	mov    $0x2,%eax
  801db3:	48 89 ca             	mov    %rcx,%rdx
  801db6:	48 89 cb             	mov    %rcx,%rbx
  801db9:	48 89 cf             	mov    %rcx,%rdi
  801dbc:	48 89 ce             	mov    %rcx,%rsi
  801dbf:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801dc1:	5b                   	pop    %rbx
  801dc2:	5d                   	pop    %rbp
  801dc3:	c3                   	retq   

0000000000801dc4 <sys_yield>:

void
sys_yield(void) {
  801dc4:	55                   	push   %rbp
  801dc5:	48 89 e5             	mov    %rsp,%rbp
  801dc8:	53                   	push   %rbx
  asm volatile("int %1\n"
  801dc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dce:	b8 0a 00 00 00       	mov    $0xa,%eax
  801dd3:	48 89 ca             	mov    %rcx,%rdx
  801dd6:	48 89 cb             	mov    %rcx,%rbx
  801dd9:	48 89 cf             	mov    %rcx,%rdi
  801ddc:	48 89 ce             	mov    %rcx,%rsi
  801ddf:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801de1:	5b                   	pop    %rbx
  801de2:	5d                   	pop    %rbp
  801de3:	c3                   	retq   

0000000000801de4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  801de4:	55                   	push   %rbp
  801de5:	48 89 e5             	mov    %rsp,%rbp
  801de8:	53                   	push   %rbx
  801de9:	48 83 ec 08          	sub    $0x8,%rsp
  801ded:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  801df0:	4c 63 c7             	movslq %edi,%r8
  801df3:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  801df6:	be 00 00 00 00       	mov    $0x0,%esi
  801dfb:	b8 04 00 00 00       	mov    $0x4,%eax
  801e00:	4c 89 c2             	mov    %r8,%rdx
  801e03:	48 89 f7             	mov    %rsi,%rdi
  801e06:	cd 30                	int    $0x30
  if (check && ret > 0)
  801e08:	48 85 c0             	test   %rax,%rax
  801e0b:	7f 07                	jg     801e14 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  801e0d:	48 83 c4 08          	add    $0x8,%rsp
  801e11:	5b                   	pop    %rbx
  801e12:	5d                   	pop    %rbp
  801e13:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801e14:	49 89 c0             	mov    %rax,%r8
  801e17:	b9 04 00 00 00       	mov    $0x4,%ecx
  801e1c:	48 ba a0 26 80 00 00 	movabs $0x8026a0,%rdx
  801e23:	00 00 00 
  801e26:	be 22 00 00 00       	mov    $0x22,%esi
  801e2b:	48 bf c0 26 80 00 00 	movabs $0x8026c0,%rdi
  801e32:	00 00 00 
  801e35:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3a:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  801e41:	00 00 00 
  801e44:	41 ff d1             	callq  *%r9

0000000000801e47 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801e47:	55                   	push   %rbp
  801e48:	48 89 e5             	mov    %rsp,%rbp
  801e4b:	53                   	push   %rbx
  801e4c:	48 83 ec 08          	sub    $0x8,%rsp
  801e50:	41 89 f9             	mov    %edi,%r9d
  801e53:	49 89 f2             	mov    %rsi,%r10
  801e56:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801e59:	4d 63 c9             	movslq %r9d,%r9
  801e5c:	48 63 da             	movslq %edx,%rbx
  801e5f:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  801e62:	b8 05 00 00 00       	mov    $0x5,%eax
  801e67:	4c 89 ca             	mov    %r9,%rdx
  801e6a:	4c 89 d1             	mov    %r10,%rcx
  801e6d:	cd 30                	int    $0x30
  if (check && ret > 0)
  801e6f:	48 85 c0             	test   %rax,%rax
  801e72:	7f 07                	jg     801e7b <sys_page_map+0x34>
}
  801e74:	48 83 c4 08          	add    $0x8,%rsp
  801e78:	5b                   	pop    %rbx
  801e79:	5d                   	pop    %rbp
  801e7a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801e7b:	49 89 c0             	mov    %rax,%r8
  801e7e:	b9 05 00 00 00       	mov    $0x5,%ecx
  801e83:	48 ba a0 26 80 00 00 	movabs $0x8026a0,%rdx
  801e8a:	00 00 00 
  801e8d:	be 22 00 00 00       	mov    $0x22,%esi
  801e92:	48 bf c0 26 80 00 00 	movabs $0x8026c0,%rdi
  801e99:	00 00 00 
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea1:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  801ea8:	00 00 00 
  801eab:	41 ff d1             	callq  *%r9

0000000000801eae <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  801eae:	55                   	push   %rbp
  801eaf:	48 89 e5             	mov    %rsp,%rbp
  801eb2:	53                   	push   %rbx
  801eb3:	48 83 ec 08          	sub    $0x8,%rsp
  801eb7:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801eba:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801ebd:	be 00 00 00 00       	mov    $0x0,%esi
  801ec2:	b8 06 00 00 00       	mov    $0x6,%eax
  801ec7:	48 89 f3             	mov    %rsi,%rbx
  801eca:	48 89 f7             	mov    %rsi,%rdi
  801ecd:	cd 30                	int    $0x30
  if (check && ret > 0)
  801ecf:	48 85 c0             	test   %rax,%rax
  801ed2:	7f 07                	jg     801edb <sys_page_unmap+0x2d>
}
  801ed4:	48 83 c4 08          	add    $0x8,%rsp
  801ed8:	5b                   	pop    %rbx
  801ed9:	5d                   	pop    %rbp
  801eda:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801edb:	49 89 c0             	mov    %rax,%r8
  801ede:	b9 06 00 00 00       	mov    $0x6,%ecx
  801ee3:	48 ba a0 26 80 00 00 	movabs $0x8026a0,%rdx
  801eea:	00 00 00 
  801eed:	be 22 00 00 00       	mov    $0x22,%esi
  801ef2:	48 bf c0 26 80 00 00 	movabs $0x8026c0,%rdi
  801ef9:	00 00 00 
  801efc:	b8 00 00 00 00       	mov    $0x0,%eax
  801f01:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  801f08:	00 00 00 
  801f0b:	41 ff d1             	callq  *%r9

0000000000801f0e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  801f0e:	55                   	push   %rbp
  801f0f:	48 89 e5             	mov    %rsp,%rbp
  801f12:	53                   	push   %rbx
  801f13:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801f17:	48 63 d7             	movslq %edi,%rdx
  801f1a:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  801f1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f22:	b8 08 00 00 00       	mov    $0x8,%eax
  801f27:	48 89 df             	mov    %rbx,%rdi
  801f2a:	48 89 de             	mov    %rbx,%rsi
  801f2d:	cd 30                	int    $0x30
  if (check && ret > 0)
  801f2f:	48 85 c0             	test   %rax,%rax
  801f32:	7f 07                	jg     801f3b <sys_env_set_status+0x2d>
}
  801f34:	48 83 c4 08          	add    $0x8,%rsp
  801f38:	5b                   	pop    %rbx
  801f39:	5d                   	pop    %rbp
  801f3a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801f3b:	49 89 c0             	mov    %rax,%r8
  801f3e:	b9 08 00 00 00       	mov    $0x8,%ecx
  801f43:	48 ba a0 26 80 00 00 	movabs $0x8026a0,%rdx
  801f4a:	00 00 00 
  801f4d:	be 22 00 00 00       	mov    $0x22,%esi
  801f52:	48 bf c0 26 80 00 00 	movabs $0x8026c0,%rdi
  801f59:	00 00 00 
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f61:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  801f68:	00 00 00 
  801f6b:	41 ff d1             	callq  *%r9

0000000000801f6e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  801f6e:	55                   	push   %rbp
  801f6f:	48 89 e5             	mov    %rsp,%rbp
  801f72:	53                   	push   %rbx
  801f73:	48 83 ec 08          	sub    $0x8,%rsp
  801f77:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801f7a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  801f7d:	be 00 00 00 00       	mov    $0x0,%esi
  801f82:	b8 09 00 00 00       	mov    $0x9,%eax
  801f87:	48 89 f3             	mov    %rsi,%rbx
  801f8a:	48 89 f7             	mov    %rsi,%rdi
  801f8d:	cd 30                	int    $0x30
  if (check && ret > 0)
  801f8f:	48 85 c0             	test   %rax,%rax
  801f92:	7f 07                	jg     801f9b <sys_env_set_pgfault_upcall+0x2d>
}
  801f94:	48 83 c4 08          	add    $0x8,%rsp
  801f98:	5b                   	pop    %rbx
  801f99:	5d                   	pop    %rbp
  801f9a:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801f9b:	49 89 c0             	mov    %rax,%r8
  801f9e:	b9 09 00 00 00       	mov    $0x9,%ecx
  801fa3:	48 ba a0 26 80 00 00 	movabs $0x8026a0,%rdx
  801faa:	00 00 00 
  801fad:	be 22 00 00 00       	mov    $0x22,%esi
  801fb2:	48 bf c0 26 80 00 00 	movabs $0x8026c0,%rdi
  801fb9:	00 00 00 
  801fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc1:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  801fc8:	00 00 00 
  801fcb:	41 ff d1             	callq  *%r9

0000000000801fce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  801fce:	55                   	push   %rbp
  801fcf:	48 89 e5             	mov    %rsp,%rbp
  801fd2:	53                   	push   %rbx
  801fd3:	49 89 f0             	mov    %rsi,%r8
  801fd6:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801fd9:	48 63 d7             	movslq %edi,%rdx
  801fdc:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  801fdf:	b8 0b 00 00 00       	mov    $0xb,%eax
  801fe4:	be 00 00 00 00       	mov    $0x0,%esi
  801fe9:	4c 89 c1             	mov    %r8,%rcx
  801fec:	cd 30                	int    $0x30
}
  801fee:	5b                   	pop    %rbx
  801fef:	5d                   	pop    %rbp
  801ff0:	c3                   	retq   

0000000000801ff1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  801ff1:	55                   	push   %rbp
  801ff2:	48 89 e5             	mov    %rsp,%rbp
  801ff5:	53                   	push   %rbx
  801ff6:	48 83 ec 08          	sub    $0x8,%rsp
  801ffa:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  801ffd:	be 00 00 00 00       	mov    $0x0,%esi
  802002:	b8 0c 00 00 00       	mov    $0xc,%eax
  802007:	48 89 f1             	mov    %rsi,%rcx
  80200a:	48 89 f3             	mov    %rsi,%rbx
  80200d:	48 89 f7             	mov    %rsi,%rdi
  802010:	cd 30                	int    $0x30
  if (check && ret > 0)
  802012:	48 85 c0             	test   %rax,%rax
  802015:	7f 07                	jg     80201e <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  802017:	48 83 c4 08          	add    $0x8,%rsp
  80201b:	5b                   	pop    %rbx
  80201c:	5d                   	pop    %rbp
  80201d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80201e:	49 89 c0             	mov    %rax,%r8
  802021:	b9 0c 00 00 00       	mov    $0xc,%ecx
  802026:	48 ba a0 26 80 00 00 	movabs $0x8026a0,%rdx
  80202d:	00 00 00 
  802030:	be 22 00 00 00       	mov    $0x22,%esi
  802035:	48 bf c0 26 80 00 00 	movabs $0x8026c0,%rdi
  80203c:	00 00 00 
  80203f:	b8 00 00 00 00       	mov    $0x0,%eax
  802044:	49 b9 70 0d 80 00 00 	movabs $0x800d70,%r9
  80204b:	00 00 00 
  80204e:	41 ff d1             	callq  *%r9

0000000000802051 <set_pgfault_handler>:
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf)) {
  802051:	55                   	push   %rbp
  802052:	48 89 e5             	mov    %rsp,%rbp
  802055:	41 54                	push   %r12
  802057:	53                   	push   %rbx
  802058:	49 89 fc             	mov    %rdi,%r12
  envid_t envid;

  int error;

  envid = sys_getenvid();
  80205b:	48 b8 a4 1d 80 00 00 	movabs $0x801da4,%rax
  802062:	00 00 00 
  802065:	ff d0                	callq  *%rax
  802067:	89 c3                	mov    %eax,%ebx
  if (_pgfault_handler == 0) {
  802069:	48 b8 f8 31 80 00 00 	movabs $0x8031f8,%rax
  802070:	00 00 00 
  802073:	48 83 38 00          	cmpq   $0x0,(%rax)
  802077:	74 2e                	je     8020a7 <set_pgfault_handler+0x56>
    // LAB 9 code end

  }

  // Save handler pointer for assembly to call.
  _pgfault_handler = handler;
  802079:	4c 89 e0             	mov    %r12,%rax
  80207c:	48 a3 f8 31 80 00 00 	movabs %rax,0x8031f8
  802083:	00 00 00 
  error            = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  802086:	48 be f3 20 80 00 00 	movabs $0x8020f3,%rsi
  80208d:	00 00 00 
  802090:	89 df                	mov    %ebx,%edi
  802092:	48 b8 6e 1f 80 00 00 	movabs $0x801f6e,%rax
  802099:	00 00 00 
  80209c:	ff d0                	callq  *%rax
  if (error < 0)
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	78 24                	js     8020c6 <set_pgfault_handler+0x75>
    panic("set_pgfault_handler: %i", error);
}
  8020a2:	5b                   	pop    %rbx
  8020a3:	41 5c                	pop    %r12
  8020a5:	5d                   	pop    %rbp
  8020a6:	c3                   	retq   
    sys_page_alloc(envid, (void *) UXSTACKTOP - PGSIZE, PTE_W);
  8020a7:	ba 02 00 00 00       	mov    $0x2,%edx
  8020ac:	48 be 00 f0 ff ff 7f 	movabs $0x7ffffff000,%rsi
  8020b3:	00 00 00 
  8020b6:	89 df                	mov    %ebx,%edi
  8020b8:	48 b8 e4 1d 80 00 00 	movabs $0x801de4,%rax
  8020bf:	00 00 00 
  8020c2:	ff d0                	callq  *%rax
  8020c4:	eb b3                	jmp    802079 <set_pgfault_handler+0x28>
    panic("set_pgfault_handler: %i", error);
  8020c6:	89 c1                	mov    %eax,%ecx
  8020c8:	48 ba ce 26 80 00 00 	movabs $0x8026ce,%rdx
  8020cf:	00 00 00 
  8020d2:	be 2c 00 00 00       	mov    $0x2c,%esi
  8020d7:	48 bf e6 26 80 00 00 	movabs $0x8026e6,%rdi
  8020de:	00 00 00 
  8020e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e6:	49 b8 70 0d 80 00 00 	movabs $0x800d70,%r8
  8020ed:	00 00 00 
  8020f0:	41 ff d0             	callq  *%r8

00000000008020f3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	movq  %rsp,%rdi                // passing the function argument in rdi
  8020f3:	48 89 e7             	mov    %rsp,%rdi
	movabs _pgfault_handler, %rax
  8020f6:	48 a1 f8 31 80 00 00 	movabs 0x8031f8,%rax
  8020fd:	00 00 00 
	call *%rax
  802100:	ff d0                	callq  *%rax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.

	// LAB 9 code
	popq %r15
  802102:	41 5f                	pop    %r15
	popq %r15
  802104:	41 5f                	pop    %r15
	popq %r15
  802106:	41 5f                	pop    %r15
	popq %r14
  802108:	41 5e                	pop    %r14
	popq %r13
  80210a:	41 5d                	pop    %r13
	popq %r12
  80210c:	41 5c                	pop    %r12
	popq %r11
  80210e:	41 5b                	pop    %r11
	popq %r10
  802110:	41 5a                	pop    %r10
	popq %r9
  802112:	41 59                	pop    %r9
	popq %r8
  802114:	41 58                	pop    %r8
	popq %rsi
  802116:	5e                   	pop    %rsi
	popq %rdi
  802117:	5f                   	pop    %rdi
	popq %rbp
  802118:	5d                   	pop    %rbp
	popq %rdx
  802119:	5a                   	pop    %rdx
	popq %rcx
  80211a:	59                   	pop    %rcx

	movq 32(%rsp), %rbx
  80211b:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
	movq 16(%rsp), %rax
  802120:	48 8b 44 24 10       	mov    0x10(%rsp),%rax
	subq $8, %rbx
  802125:	48 83 eb 08          	sub    $0x8,%rbx
	movq %rax, (%rbx)
  802129:	48 89 03             	mov    %rax,(%rbx)
	movq %rbx, 32(%rsp)
  80212c:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)

	popq %rbx
  802131:	5b                   	pop    %rbx
	popq %rax
  802132:	58                   	pop    %rax
	// Restore rflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies rflags.

	// LAB 9 code
	pushq 8(%rsp)
  802133:	ff 74 24 08          	pushq  0x8(%rsp)
	popfq
  802137:	9d                   	popfq  
	// LAB 9 code end

	// Switch back to the adjusted trap-time stack.

	// LAB 9 code
	movq 16(%rsp), %rsp
  802138:	48 8b 64 24 10       	mov    0x10(%rsp),%rsp
	// LAB 9 code end

	// Return to re-execute the instruction that faulted.

	// LAB 9 code
	ret
  80213d:	c3                   	retq   
  80213e:	66 90                	xchg   %ax,%ax
