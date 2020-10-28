
obj/kern/kernel:     file format elf64-x86-64


Disassembly of section .bootstrap:

0000000001500000 <_head64>:

.text
.globl _head64
_head64:
  # Disable interrupts.
  cli
 1500000:	fa                   	cli    

  # Save Loader_block pointer from Bootloader.c in r12.
  movq %rcx,%r12
 1500001:	49 89 cc             	mov    %rcx,%r12

  # Build an early boot pml4 at pml4phys (physical = virtual for it).

  # Initialize the page tables.
  movl $pml4,%edi
 1500004:	bf 00 10 50 01       	mov    $0x1501000,%edi
  xorl %eax,%eax
 1500009:	31 c0                	xor    %eax,%eax
  movl $PML_SIZE,%ecx  # moving these many words to the 11 pages
 150000b:	b9 00 2c 00 00       	mov    $0x2c00,%ecx
  rep stosl
 1500010:	f3 ab                	rep stos %eax,%es:(%rdi)

  # Creating a 4G boot page table...
  # Setting the 4-level page table with only the second entry needed (PML4).
  movl $pml4,%eax
 1500012:	b8 00 10 50 01       	mov    $0x1501000,%eax
  movl $pdpt1, %ebx
 1500017:	bb 00 20 50 01       	mov    $0x1502000,%ebx
  orl $PTE_P,%ebx
 150001c:	83 cb 01             	or     $0x1,%ebx
  orl $PTE_W,%ebx
 150001f:	83 cb 02             	or     $0x2,%ebx
  movl %ebx,(%eax)
 1500022:	67 89 18             	mov    %ebx,(%eax)

  movl $pdpt2, %ebx
 1500025:	bb 00 30 50 01       	mov    $0x1503000,%ebx
  orl $PTE_P,%ebx
 150002a:	83 cb 01             	or     $0x1,%ebx
  orl $PTE_W,%ebx
 150002d:	83 cb 02             	or     $0x2,%ebx
  movl %ebx,0x8(%eax)
 1500030:	67 89 58 08          	mov    %ebx,0x8(%eax)

  # Setting the 3rd level page table (PDPE).
  # 4 entries (counter in ecx), point to the next four physical pages (pgdirs).
  # pgdirs in 0xa0000--0xd000.
  movl $pdpt1,%edi
 1500034:	bf 00 20 50 01       	mov    $0x1502000,%edi
  movl $pde1,%ebx
 1500039:	bb 00 40 50 01       	mov    $0x1504000,%ebx
  orl $PTE_P,%ebx
 150003e:	83 cb 01             	or     $0x1,%ebx
  orl $PTE_W,%ebx
 1500041:	83 cb 02             	or     $0x2,%ebx
  movl %ebx,(%edi)
 1500044:	67 89 1f             	mov    %ebx,(%edi)

  movl $pdpt2,%edi
 1500047:	bf 00 30 50 01       	mov    $0x1503000,%edi
  movl $pde2,%ebx
 150004c:	bb 00 50 50 01       	mov    $0x1505000,%ebx
  orl $PTE_P,%ebx
 1500051:	83 cb 01             	or     $0x1,%ebx
  orl $PTE_W,%ebx
 1500054:	83 cb 02             	or     $0x2,%ebx
  # 2nd entry - 0x8040000000
  movl %ebx,0x8(%edi)
 1500057:	67 89 5f 08          	mov    %ebx,0x8(%edi)

  # Setting the pgdir so that the LA=PA.
  # Mapping first 1024mb of mem at KERNBASE.
  movl $512,%ecx
 150005b:	b9 00 02 00 00       	mov    $0x200,%ecx
  # Start at the end and work backwards
  movl $pde1,%edi
 1500060:	bf 00 40 50 01       	mov    $0x1504000,%edi
  movl $pde2,%ebx
 1500065:	bb 00 50 50 01       	mov    $0x1505000,%ebx
  # 1st entry - 0x8040000000

  # PTE_P|PTE_W|PTE_MBZ
  movl $0x00000183,%eax
 150006a:	b8 83 01 00 00       	mov    $0x183,%eax
1:
  movl %eax,(%edi)
 150006f:	67 89 07             	mov    %eax,(%edi)
  movl %eax,(%ebx)
 1500072:	67 89 03             	mov    %eax,(%ebx)
  addl $0x8,%edi
 1500075:	83 c7 08             	add    $0x8,%edi
  addl $0x8,%ebx
 1500078:	83 c3 08             	add    $0x8,%ebx
  addl $0x00200000,%eax
 150007b:	05 00 00 20 00       	add    $0x200000,%eax
  subl $1,%ecx
 1500080:	83 e9 01             	sub    $0x1,%ecx
  cmp $0x0,%ecx
 1500083:	83 f9 00             	cmp    $0x0,%ecx
  jne 1b
 1500086:	75 e7                	jne    150006f <_head64+0x6f>

  # Update CR3 register.
  movq $pml4,%rax
 1500088:	48 c7 c0 00 10 50 01 	mov    $0x1501000,%rax
  movq %rax, %cr3
 150008f:	0f 22 d8             	mov    %rax,%cr3

  # Transition to high mem entry code and pass LoadParams address.
  movabs $entry,%rax
 1500092:	48 b8 00 00 60 41 80 	movabs $0x8041600000,%rax
 1500099:	00 00 00 
  movq %r12, %rcx
 150009c:	4c 89 e1             	mov    %r12,%rcx
  jmpq *%rax
 150009f:	ff e0                	jmpq   *%rax
 15000a1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000a8:	00 00 00 
 15000ab:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000b2:	00 00 00 
 15000b5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000bc:	00 00 00 
 15000bf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000c6:	00 00 00 
 15000c9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000d0:	00 00 00 
 15000d3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000da:	00 00 00 
 15000dd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000e4:	00 00 00 
 15000e7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000ee:	00 00 00 
 15000f1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15000f8:	00 00 00 
 15000fb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500102:	00 00 00 
 1500105:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150010c:	00 00 00 
 150010f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500116:	00 00 00 
 1500119:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500120:	00 00 00 
 1500123:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150012a:	00 00 00 
 150012d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500134:	00 00 00 
 1500137:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150013e:	00 00 00 
 1500141:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500148:	00 00 00 
 150014b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500152:	00 00 00 
 1500155:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150015c:	00 00 00 
 150015f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500166:	00 00 00 
 1500169:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500170:	00 00 00 
 1500173:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150017a:	00 00 00 
 150017d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500184:	00 00 00 
 1500187:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150018e:	00 00 00 
 1500191:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500198:	00 00 00 
 150019b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001a2:	00 00 00 
 15001a5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001ac:	00 00 00 
 15001af:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001b6:	00 00 00 
 15001b9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001c0:	00 00 00 
 15001c3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001ca:	00 00 00 
 15001cd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001d4:	00 00 00 
 15001d7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001de:	00 00 00 
 15001e1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001e8:	00 00 00 
 15001eb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001f2:	00 00 00 
 15001f5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15001fc:	00 00 00 
 15001ff:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500206:	00 00 00 
 1500209:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500210:	00 00 00 
 1500213:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150021a:	00 00 00 
 150021d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500224:	00 00 00 
 1500227:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150022e:	00 00 00 
 1500231:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500238:	00 00 00 
 150023b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500242:	00 00 00 
 1500245:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150024c:	00 00 00 
 150024f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500256:	00 00 00 
 1500259:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500260:	00 00 00 
 1500263:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150026a:	00 00 00 
 150026d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500274:	00 00 00 
 1500277:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150027e:	00 00 00 
 1500281:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500288:	00 00 00 
 150028b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500292:	00 00 00 
 1500295:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150029c:	00 00 00 
 150029f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002a6:	00 00 00 
 15002a9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002b0:	00 00 00 
 15002b3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002ba:	00 00 00 
 15002bd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002c4:	00 00 00 
 15002c7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002ce:	00 00 00 
 15002d1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002d8:	00 00 00 
 15002db:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002e2:	00 00 00 
 15002e5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002ec:	00 00 00 
 15002ef:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15002f6:	00 00 00 
 15002f9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500300:	00 00 00 
 1500303:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150030a:	00 00 00 
 150030d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500314:	00 00 00 
 1500317:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150031e:	00 00 00 
 1500321:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500328:	00 00 00 
 150032b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500332:	00 00 00 
 1500335:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150033c:	00 00 00 
 150033f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500346:	00 00 00 
 1500349:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500350:	00 00 00 
 1500353:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150035a:	00 00 00 
 150035d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500364:	00 00 00 
 1500367:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150036e:	00 00 00 
 1500371:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500378:	00 00 00 
 150037b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500382:	00 00 00 
 1500385:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150038c:	00 00 00 
 150038f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500396:	00 00 00 
 1500399:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003a0:	00 00 00 
 15003a3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003aa:	00 00 00 
 15003ad:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003b4:	00 00 00 
 15003b7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003be:	00 00 00 
 15003c1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003c8:	00 00 00 
 15003cb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003d2:	00 00 00 
 15003d5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003dc:	00 00 00 
 15003df:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003e6:	00 00 00 
 15003e9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003f0:	00 00 00 
 15003f3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15003fa:	00 00 00 
 15003fd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500404:	00 00 00 
 1500407:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150040e:	00 00 00 
 1500411:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500418:	00 00 00 
 150041b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500422:	00 00 00 
 1500425:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150042c:	00 00 00 
 150042f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500436:	00 00 00 
 1500439:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500440:	00 00 00 
 1500443:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150044a:	00 00 00 
 150044d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500454:	00 00 00 
 1500457:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150045e:	00 00 00 
 1500461:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500468:	00 00 00 
 150046b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500472:	00 00 00 
 1500475:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150047c:	00 00 00 
 150047f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500486:	00 00 00 
 1500489:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500490:	00 00 00 
 1500493:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150049a:	00 00 00 
 150049d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004a4:	00 00 00 
 15004a7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004ae:	00 00 00 
 15004b1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004b8:	00 00 00 
 15004bb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004c2:	00 00 00 
 15004c5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004cc:	00 00 00 
 15004cf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004d6:	00 00 00 
 15004d9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004e0:	00 00 00 
 15004e3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004ea:	00 00 00 
 15004ed:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004f4:	00 00 00 
 15004f7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15004fe:	00 00 00 
 1500501:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500508:	00 00 00 
 150050b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500512:	00 00 00 
 1500515:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150051c:	00 00 00 
 150051f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500526:	00 00 00 
 1500529:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500530:	00 00 00 
 1500533:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150053a:	00 00 00 
 150053d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500544:	00 00 00 
 1500547:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150054e:	00 00 00 
 1500551:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500558:	00 00 00 
 150055b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500562:	00 00 00 
 1500565:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150056c:	00 00 00 
 150056f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500576:	00 00 00 
 1500579:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500580:	00 00 00 
 1500583:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150058a:	00 00 00 
 150058d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500594:	00 00 00 
 1500597:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150059e:	00 00 00 
 15005a1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005a8:	00 00 00 
 15005ab:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005b2:	00 00 00 
 15005b5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005bc:	00 00 00 
 15005bf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005c6:	00 00 00 
 15005c9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005d0:	00 00 00 
 15005d3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005da:	00 00 00 
 15005dd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005e4:	00 00 00 
 15005e7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005ee:	00 00 00 
 15005f1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15005f8:	00 00 00 
 15005fb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500602:	00 00 00 
 1500605:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150060c:	00 00 00 
 150060f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500616:	00 00 00 
 1500619:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500620:	00 00 00 
 1500623:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150062a:	00 00 00 
 150062d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500634:	00 00 00 
 1500637:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150063e:	00 00 00 
 1500641:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500648:	00 00 00 
 150064b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500652:	00 00 00 
 1500655:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150065c:	00 00 00 
 150065f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500666:	00 00 00 
 1500669:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500670:	00 00 00 
 1500673:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150067a:	00 00 00 
 150067d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500684:	00 00 00 
 1500687:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150068e:	00 00 00 
 1500691:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500698:	00 00 00 
 150069b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006a2:	00 00 00 
 15006a5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006ac:	00 00 00 
 15006af:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006b6:	00 00 00 
 15006b9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006c0:	00 00 00 
 15006c3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006ca:	00 00 00 
 15006cd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006d4:	00 00 00 
 15006d7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006de:	00 00 00 
 15006e1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006e8:	00 00 00 
 15006eb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006f2:	00 00 00 
 15006f5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15006fc:	00 00 00 
 15006ff:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500706:	00 00 00 
 1500709:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500710:	00 00 00 
 1500713:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150071a:	00 00 00 
 150071d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500724:	00 00 00 
 1500727:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150072e:	00 00 00 
 1500731:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500738:	00 00 00 
 150073b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500742:	00 00 00 
 1500745:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150074c:	00 00 00 
 150074f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500756:	00 00 00 
 1500759:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500760:	00 00 00 
 1500763:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150076a:	00 00 00 
 150076d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500774:	00 00 00 
 1500777:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150077e:	00 00 00 
 1500781:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500788:	00 00 00 
 150078b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500792:	00 00 00 
 1500795:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150079c:	00 00 00 
 150079f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007a6:	00 00 00 
 15007a9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007b0:	00 00 00 
 15007b3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007ba:	00 00 00 
 15007bd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007c4:	00 00 00 
 15007c7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007ce:	00 00 00 
 15007d1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007d8:	00 00 00 
 15007db:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007e2:	00 00 00 
 15007e5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007ec:	00 00 00 
 15007ef:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15007f6:	00 00 00 
 15007f9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500800:	00 00 00 
 1500803:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150080a:	00 00 00 
 150080d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500814:	00 00 00 
 1500817:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150081e:	00 00 00 
 1500821:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500828:	00 00 00 
 150082b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500832:	00 00 00 
 1500835:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150083c:	00 00 00 
 150083f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500846:	00 00 00 
 1500849:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500850:	00 00 00 
 1500853:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150085a:	00 00 00 
 150085d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500864:	00 00 00 
 1500867:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150086e:	00 00 00 
 1500871:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500878:	00 00 00 
 150087b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500882:	00 00 00 
 1500885:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150088c:	00 00 00 
 150088f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500896:	00 00 00 
 1500899:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008a0:	00 00 00 
 15008a3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008aa:	00 00 00 
 15008ad:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008b4:	00 00 00 
 15008b7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008be:	00 00 00 
 15008c1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008c8:	00 00 00 
 15008cb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008d2:	00 00 00 
 15008d5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008dc:	00 00 00 
 15008df:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008e6:	00 00 00 
 15008e9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008f0:	00 00 00 
 15008f3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15008fa:	00 00 00 
 15008fd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500904:	00 00 00 
 1500907:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150090e:	00 00 00 
 1500911:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500918:	00 00 00 
 150091b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500922:	00 00 00 
 1500925:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150092c:	00 00 00 
 150092f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500936:	00 00 00 
 1500939:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500940:	00 00 00 
 1500943:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150094a:	00 00 00 
 150094d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500954:	00 00 00 
 1500957:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150095e:	00 00 00 
 1500961:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500968:	00 00 00 
 150096b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500972:	00 00 00 
 1500975:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150097c:	00 00 00 
 150097f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500986:	00 00 00 
 1500989:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500990:	00 00 00 
 1500993:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 150099a:	00 00 00 
 150099d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009a4:	00 00 00 
 15009a7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009ae:	00 00 00 
 15009b1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009b8:	00 00 00 
 15009bb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009c2:	00 00 00 
 15009c5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009cc:	00 00 00 
 15009cf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009d6:	00 00 00 
 15009d9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009e0:	00 00 00 
 15009e3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009ea:	00 00 00 
 15009ed:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009f4:	00 00 00 
 15009f7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 15009fe:	00 00 00 
 1500a01:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a08:	00 00 00 
 1500a0b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a12:	00 00 00 
 1500a15:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a1c:	00 00 00 
 1500a1f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a26:	00 00 00 
 1500a29:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a30:	00 00 00 
 1500a33:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a3a:	00 00 00 
 1500a3d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a44:	00 00 00 
 1500a47:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a4e:	00 00 00 
 1500a51:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a58:	00 00 00 
 1500a5b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a62:	00 00 00 
 1500a65:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a6c:	00 00 00 
 1500a6f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a76:	00 00 00 
 1500a79:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a80:	00 00 00 
 1500a83:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a8a:	00 00 00 
 1500a8d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a94:	00 00 00 
 1500a97:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500a9e:	00 00 00 
 1500aa1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500aa8:	00 00 00 
 1500aab:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ab2:	00 00 00 
 1500ab5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500abc:	00 00 00 
 1500abf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ac6:	00 00 00 
 1500ac9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ad0:	00 00 00 
 1500ad3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ada:	00 00 00 
 1500add:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ae4:	00 00 00 
 1500ae7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500aee:	00 00 00 
 1500af1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500af8:	00 00 00 
 1500afb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b02:	00 00 00 
 1500b05:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b0c:	00 00 00 
 1500b0f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b16:	00 00 00 
 1500b19:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b20:	00 00 00 
 1500b23:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b2a:	00 00 00 
 1500b2d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b34:	00 00 00 
 1500b37:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b3e:	00 00 00 
 1500b41:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b48:	00 00 00 
 1500b4b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b52:	00 00 00 
 1500b55:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b5c:	00 00 00 
 1500b5f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b66:	00 00 00 
 1500b69:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b70:	00 00 00 
 1500b73:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b7a:	00 00 00 
 1500b7d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b84:	00 00 00 
 1500b87:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b8e:	00 00 00 
 1500b91:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500b98:	00 00 00 
 1500b9b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ba2:	00 00 00 
 1500ba5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bac:	00 00 00 
 1500baf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bb6:	00 00 00 
 1500bb9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bc0:	00 00 00 
 1500bc3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bca:	00 00 00 
 1500bcd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bd4:	00 00 00 
 1500bd7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bde:	00 00 00 
 1500be1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500be8:	00 00 00 
 1500beb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bf2:	00 00 00 
 1500bf5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500bfc:	00 00 00 
 1500bff:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c06:	00 00 00 
 1500c09:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c10:	00 00 00 
 1500c13:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c1a:	00 00 00 
 1500c1d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c24:	00 00 00 
 1500c27:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c2e:	00 00 00 
 1500c31:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c38:	00 00 00 
 1500c3b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c42:	00 00 00 
 1500c45:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c4c:	00 00 00 
 1500c4f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c56:	00 00 00 
 1500c59:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c60:	00 00 00 
 1500c63:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c6a:	00 00 00 
 1500c6d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c74:	00 00 00 
 1500c77:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c7e:	00 00 00 
 1500c81:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c88:	00 00 00 
 1500c8b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c92:	00 00 00 
 1500c95:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500c9c:	00 00 00 
 1500c9f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ca6:	00 00 00 
 1500ca9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500cb0:	00 00 00 
 1500cb3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500cba:	00 00 00 
 1500cbd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500cc4:	00 00 00 
 1500cc7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500cce:	00 00 00 
 1500cd1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500cd8:	00 00 00 
 1500cdb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ce2:	00 00 00 
 1500ce5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500cec:	00 00 00 
 1500cef:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500cf6:	00 00 00 
 1500cf9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d00:	00 00 00 
 1500d03:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d0a:	00 00 00 
 1500d0d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d14:	00 00 00 
 1500d17:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d1e:	00 00 00 
 1500d21:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d28:	00 00 00 
 1500d2b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d32:	00 00 00 
 1500d35:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d3c:	00 00 00 
 1500d3f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d46:	00 00 00 
 1500d49:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d50:	00 00 00 
 1500d53:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d5a:	00 00 00 
 1500d5d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d64:	00 00 00 
 1500d67:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d6e:	00 00 00 
 1500d71:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d78:	00 00 00 
 1500d7b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d82:	00 00 00 
 1500d85:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d8c:	00 00 00 
 1500d8f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500d96:	00 00 00 
 1500d99:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500da0:	00 00 00 
 1500da3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500daa:	00 00 00 
 1500dad:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500db4:	00 00 00 
 1500db7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500dbe:	00 00 00 
 1500dc1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500dc8:	00 00 00 
 1500dcb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500dd2:	00 00 00 
 1500dd5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ddc:	00 00 00 
 1500ddf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500de6:	00 00 00 
 1500de9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500df0:	00 00 00 
 1500df3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500dfa:	00 00 00 
 1500dfd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e04:	00 00 00 
 1500e07:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e0e:	00 00 00 
 1500e11:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e18:	00 00 00 
 1500e1b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e22:	00 00 00 
 1500e25:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e2c:	00 00 00 
 1500e2f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e36:	00 00 00 
 1500e39:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e40:	00 00 00 
 1500e43:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e4a:	00 00 00 
 1500e4d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e54:	00 00 00 
 1500e57:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e5e:	00 00 00 
 1500e61:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e68:	00 00 00 
 1500e6b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e72:	00 00 00 
 1500e75:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e7c:	00 00 00 
 1500e7f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e86:	00 00 00 
 1500e89:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e90:	00 00 00 
 1500e93:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500e9a:	00 00 00 
 1500e9d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ea4:	00 00 00 
 1500ea7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500eae:	00 00 00 
 1500eb1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500eb8:	00 00 00 
 1500ebb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ec2:	00 00 00 
 1500ec5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ecc:	00 00 00 
 1500ecf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ed6:	00 00 00 
 1500ed9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ee0:	00 00 00 
 1500ee3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500eea:	00 00 00 
 1500eed:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ef4:	00 00 00 
 1500ef7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500efe:	00 00 00 
 1500f01:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f08:	00 00 00 
 1500f0b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f12:	00 00 00 
 1500f15:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f1c:	00 00 00 
 1500f1f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f26:	00 00 00 
 1500f29:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f30:	00 00 00 
 1500f33:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f3a:	00 00 00 
 1500f3d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f44:	00 00 00 
 1500f47:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f4e:	00 00 00 
 1500f51:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f58:	00 00 00 
 1500f5b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f62:	00 00 00 
 1500f65:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f6c:	00 00 00 
 1500f6f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f76:	00 00 00 
 1500f79:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f80:	00 00 00 
 1500f83:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f8a:	00 00 00 
 1500f8d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f94:	00 00 00 
 1500f97:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500f9e:	00 00 00 
 1500fa1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fa8:	00 00 00 
 1500fab:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fb2:	00 00 00 
 1500fb5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fbc:	00 00 00 
 1500fbf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fc6:	00 00 00 
 1500fc9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fd0:	00 00 00 
 1500fd3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fda:	00 00 00 
 1500fdd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fe4:	00 00 00 
 1500fe7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500fee:	00 00 00 
 1500ff1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
 1500ff8:	00 00 00 
 1500ffb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000001501000 <pml4phys>:
	...

0000000001502000 <pdpt1>:
	...

0000000001503000 <pdpt2>:
	...

0000000001504000 <pde1>:
	...

0000000001505000 <pde2>:
	...

0000000001506000 <pdefreestart>:
	...

Disassembly of section .text:

0000008041600000 <__text_start>:
.text

.globl entry
entry:
  # маскирование прерываний
  cli
  8041600000:	fa                   	cli    
  # Save LoadParams in uefi_lp.
  movq %rcx, uefi_lp(%rip)
  8041600001:	48 89 0d f8 9f 01 00 	mov    %rcx,0x19ff8(%rip)        # 804161a000 <bootstacktop>

  # Set the stack pointer.
  leaq bootstacktop(%rip),%rsp
  8041600008:	48 8d 25 f1 9f 01 00 	lea    0x19ff1(%rip),%rsp        # 804161a000 <bootstacktop>

  # Clear the frame pointer register (RBP)
  # so that once we get into debugging C code,
  # stack backtraces will be terminated properly.
  xorq %rbp, %rbp      # nuke frame pointer
  804160000f:	48 31 ed             	xor    %rbp,%rbp

  # now to C code
  call i386_init
  8041600012:	e8 30 04 00 00       	callq  8041600447 <i386_init>

0000008041600017 <spin>:

  # Should never get here, but in case we do, just spin.
spin:  jmp  spin
  8041600017:	eb fe                	jmp    8041600017 <spin>

0000008041600019 <timers_init>:
#include <kern/cpu.h>
#include <kern/picirq.h>
#include <kern/kclock.h>

void
timers_init(void) {
  8041600019:	55                   	push   %rbp
  804160001a:	48 89 e5             	mov    %rsp,%rbp
  804160001d:	41 54                	push   %r12
  804160001f:	53                   	push   %rbx
  timertab[0] = timer_rtc;
  8041600020:	48 bb 80 dc 61 41 80 	movabs $0x804161dc80,%rbx
  8041600027:	00 00 00 
  804160002a:	48 b8 a0 a7 61 41 80 	movabs $0x804161a7a0,%rax
  8041600031:	00 00 00 
  8041600034:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  8041600038:	0f 11 03             	movups %xmm0,(%rbx)
  804160003b:	f3 0f 6f 48 10       	movdqu 0x10(%rax),%xmm1
  8041600040:	0f 11 4b 10          	movups %xmm1,0x10(%rbx)
  8041600044:	48 8b 40 20          	mov    0x20(%rax),%rax
  8041600048:	48 89 43 20          	mov    %rax,0x20(%rbx)
  timertab[1] = timer_pit;
  804160004c:	48 b8 c0 a8 61 41 80 	movabs $0x804161a8c0,%rax
  8041600053:	00 00 00 
  8041600056:	f3 0f 6f 10          	movdqu (%rax),%xmm2
  804160005a:	0f 11 53 28          	movups %xmm2,0x28(%rbx)
  804160005e:	f3 0f 6f 58 10       	movdqu 0x10(%rax),%xmm3
  8041600063:	0f 11 5b 38          	movups %xmm3,0x38(%rbx)
  8041600067:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160006b:	48 89 43 48          	mov    %rax,0x48(%rbx)
  timertab[2] = timer_acpipm;
  804160006f:	48 b8 e0 a7 61 41 80 	movabs $0x804161a7e0,%rax
  8041600076:	00 00 00 
  8041600079:	f3 0f 6f 20          	movdqu (%rax),%xmm4
  804160007d:	0f 11 63 50          	movups %xmm4,0x50(%rbx)
  8041600081:	f3 0f 6f 68 10       	movdqu 0x10(%rax),%xmm5
  8041600086:	0f 11 6b 60          	movups %xmm5,0x60(%rbx)
  804160008a:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160008e:	48 89 43 70          	mov    %rax,0x70(%rbx)
  timertab[3] = timer_hpet0;
  8041600092:	48 b8 60 a8 61 41 80 	movabs $0x804161a860,%rax
  8041600099:	00 00 00 
  804160009c:	f3 0f 6f 30          	movdqu (%rax),%xmm6
  80416000a0:	0f 11 73 78          	movups %xmm6,0x78(%rbx)
  80416000a4:	f3 0f 6f 78 10       	movdqu 0x10(%rax),%xmm7
  80416000a9:	0f 11 bb 88 00 00 00 	movups %xmm7,0x88(%rbx)
  80416000b0:	48 8b 40 20          	mov    0x20(%rax),%rax
  80416000b4:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
  timertab[4] = timer_hpet1;
  80416000bb:	48 b8 20 a8 61 41 80 	movabs $0x804161a820,%rax
  80416000c2:	00 00 00 
  80416000c5:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  80416000c9:	0f 11 83 a0 00 00 00 	movups %xmm0,0xa0(%rbx)
  80416000d0:	f3 0f 6f 48 10       	movdqu 0x10(%rax),%xmm1
  80416000d5:	0f 11 8b b0 00 00 00 	movups %xmm1,0xb0(%rbx)
  80416000dc:	48 8b 40 20          	mov    0x20(%rax),%rax
  80416000e0:	48 89 83 c0 00 00 00 	mov    %rax,0xc0(%rbx)

  for (int i = 0; i < MAX_TIMERS; i++) {
  80416000e7:	4c 8d a3 c8 00 00 00 	lea    0xc8(%rbx),%r12
  80416000ee:	eb 09                	jmp    80416000f9 <timers_init+0xe0>
  80416000f0:	48 83 c3 28          	add    $0x28,%rbx
  80416000f4:	4c 39 e3             	cmp    %r12,%rbx
  80416000f7:	74 0d                	je     8041600106 <timers_init+0xed>
    if (timertab[i].timer_init != NULL) {
  80416000f9:	48 8b 43 08          	mov    0x8(%rbx),%rax
  80416000fd:	48 85 c0             	test   %rax,%rax
  8041600100:	74 ee                	je     80416000f0 <timers_init+0xd7>
      timertab[i].timer_init();
  8041600102:	ff d0                	callq  *%rax
  8041600104:	eb ea                	jmp    80416000f0 <timers_init+0xd7>
    }
  }
}
  8041600106:	5b                   	pop    %rbx
  8041600107:	41 5c                	pop    %r12
  8041600109:	5d                   	pop    %rbp
  804160010a:	c3                   	retq   

000000804160010b <alloc_pde_early_boot>:
  //Assume pde1, pde2 is already used.
  extern uintptr_t pdefreestart, pdefreeend;
  pde_t *ret;
  static uintptr_t pdefree = (uintptr_t)&pdefreestart;

  if (pdefree >= (uintptr_t)&pdefreeend)
  804160010b:	48 b8 08 a0 61 41 80 	movabs $0x804161a008,%rax
  8041600112:	00 00 00 
  8041600115:	48 8b 10             	mov    (%rax),%rdx
  8041600118:	48 b8 00 c0 50 01 00 	movabs $0x150c000,%rax
  804160011f:	00 00 00 
  8041600122:	48 39 c2             	cmp    %rax,%rdx
  8041600125:	73 1b                	jae    8041600142 <alloc_pde_early_boot+0x37>
    return NULL;

  ret = (pde_t *)pdefree;
  8041600127:	48 89 d1             	mov    %rdx,%rcx
  pdefree += PGSIZE;
  804160012a:	48 81 c2 00 10 00 00 	add    $0x1000,%rdx
  8041600131:	48 89 d0             	mov    %rdx,%rax
  8041600134:	48 a3 08 a0 61 41 80 	movabs %rax,0x804161a008
  804160013b:	00 00 00 
  return ret;
}
  804160013e:	48 89 c8             	mov    %rcx,%rax
  8041600141:	c3                   	retq   
    return NULL;
  8041600142:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600147:	eb f5                	jmp    804160013e <alloc_pde_early_boot+0x33>

0000008041600149 <map_addr_early_boot>:

void
map_addr_early_boot(uintptr_t addr, uintptr_t addr_phys, size_t sz) {
  8041600149:	55                   	push   %rbp
  804160014a:	48 89 e5             	mov    %rsp,%rbp
  804160014d:	41 57                	push   %r15
  804160014f:	41 56                	push   %r14
  8041600151:	41 55                	push   %r13
  8041600153:	41 54                	push   %r12
  8041600155:	53                   	push   %rbx
  8041600156:	48 83 ec 18          	sub    $0x18,%rsp
  pml4e_t *pml4 = &pml4phys;
  pdpe_t *pdpt;
  pde_t *pde;

  uintptr_t addr_curr, addr_curr_phys, addr_end;
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  804160015a:	49 89 ff             	mov    %rdi,%r15
  804160015d:	49 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%r15
  addr_curr_phys = ROUNDDOWN(addr_phys, PTSIZE);
  8041600164:	48 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%rsi
  804160016b:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  addr_end       = ROUNDUP(addr + sz, PTSIZE);
  804160016f:	4c 8d b4 17 ff ff 1f 	lea    0x1fffff(%rdi,%rdx,1),%r14
  8041600176:	00 
  8041600177:	49 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%r14

  pdpt = (pdpe_t *)PTE_ADDR(pml4[PML4(addr_curr)]);
  804160017e:	48 c1 ef 24          	shr    $0x24,%rdi
  8041600182:	81 e7 f8 0f 00 00    	and    $0xff8,%edi
  8041600188:	48 b8 00 10 50 01 00 	movabs $0x1501000,%rax
  804160018f:	00 00 00 
  8041600192:	48 8b 04 38          	mov    (%rax,%rdi,1),%rax
  8041600196:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160019c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  80416001a0:	4d 39 fe             	cmp    %r15,%r14
  80416001a3:	76 67                	jbe    804160020c <map_addr_early_boot+0xc3>
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  80416001a5:	4d 89 fc             	mov    %r15,%r12
  80416001a8:	eb 3a                	jmp    80416001e4 <map_addr_early_boot+0x9b>
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
    if (!pde) {
      pde                   = alloc_pde_early_boot();
  80416001aa:	48 b8 0b 01 60 41 80 	movabs $0x804160010b,%rax
  80416001b1:	00 00 00 
  80416001b4:	ff d0                	callq  *%rax
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
  80416001b6:	48 89 c2             	mov    %rax,%rdx
  80416001b9:	48 83 ca 03          	or     $0x3,%rdx
  80416001bd:	48 89 13             	mov    %rdx,(%rbx)
    }
    pde[PDX(addr_curr)] = addr_curr_phys | PTE_P | PTE_W | PTE_MBZ;
  80416001c0:	4c 89 e2             	mov    %r12,%rdx
  80416001c3:	48 c1 ea 15          	shr    $0x15,%rdx
  80416001c7:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  80416001cd:	49 81 cd 83 01 00 00 	or     $0x183,%r13
  80416001d4:	4c 89 2c d0          	mov    %r13,(%rax,%rdx,8)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  80416001d8:	49 81 c4 00 00 20 00 	add    $0x200000,%r12
  80416001df:	4d 39 e6             	cmp    %r12,%r14
  80416001e2:	76 28                	jbe    804160020c <map_addr_early_boot+0xc3>
  80416001e4:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
  80416001e8:	4d 29 fd             	sub    %r15,%r13
  80416001eb:	4d 01 e5             	add    %r12,%r13
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
  80416001ee:	4c 89 e3             	mov    %r12,%rbx
  80416001f1:	48 c1 eb 1b          	shr    $0x1b,%rbx
  80416001f5:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  80416001fb:	48 03 5d c0          	add    -0x40(%rbp),%rbx
    if (!pde) {
  80416001ff:	48 8b 03             	mov    (%rbx),%rax
  8041600202:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041600208:	75 b6                	jne    80416001c0 <map_addr_early_boot+0x77>
  804160020a:	eb 9e                	jmp    80416001aa <map_addr_early_boot+0x61>
  }
}
  804160020c:	48 83 c4 18          	add    $0x18,%rsp
  8041600210:	5b                   	pop    %rbx
  8041600211:	41 5c                	pop    %r12
  8041600213:	41 5d                	pop    %r13
  8041600215:	41 5e                	pop    %r14
  8041600217:	41 5f                	pop    %r15
  8041600219:	5d                   	pop    %rbp
  804160021a:	c3                   	retq   

000000804160021b <early_boot_pml4_init>:
// Additionally maps pml4 memory so that we dont get memory errors on accessing
// uefi_lp, MemMap, KASAN functions.
void
early_boot_pml4_init(void) {
  804160021b:	55                   	push   %rbp
  804160021c:	48 89 e5             	mov    %rsp,%rbp
  804160021f:	41 54                	push   %r12
  8041600221:	53                   	push   %rbx

  map_addr_early_boot((uintptr_t)uefi_lp, (uintptr_t)uefi_lp, sizeof(LOADER_PARAMS));
  8041600222:	49 bc 00 a0 61 41 80 	movabs $0x804161a000,%r12
  8041600229:	00 00 00 
  804160022c:	49 8b 3c 24          	mov    (%r12),%rdi
  8041600230:	ba c8 00 00 00       	mov    $0xc8,%edx
  8041600235:	48 89 fe             	mov    %rdi,%rsi
  8041600238:	48 bb 49 01 60 41 80 	movabs $0x8041600149,%rbx
  804160023f:	00 00 00 
  8041600242:	ff d3                	callq  *%rbx
  map_addr_early_boot((uintptr_t)uefi_lp->MemoryMap, (uintptr_t)uefi_lp->MemoryMap, uefi_lp->MemoryMapSize);
  8041600244:	49 8b 04 24          	mov    (%r12),%rax
  8041600248:	48 8b 78 28          	mov    0x28(%rax),%rdi
  804160024c:	48 8b 50 38          	mov    0x38(%rax),%rdx
  8041600250:	48 89 fe             	mov    %rdi,%rsi
  8041600253:	ff d3                	callq  *%rbx

#ifdef SANITIZE_SHADOW_BASE
  map_addr_early_boot(SANITIZE_SHADOW_BASE, SANITIZE_SHADOW_BASE - KERNBASE, SANITIZE_SHADOW_SIZE);
#endif

  map_addr_early_boot(FBUFFBASE, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
  8041600255:	49 8b 04 24          	mov    (%r12),%rax
  8041600259:	8b 50 48             	mov    0x48(%rax),%edx
  804160025c:	48 8b 70 40          	mov    0x40(%rax),%rsi
  8041600260:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600267:	00 00 00 
  804160026a:	ff d3                	callq  *%rbx
}
  804160026c:	5b                   	pop    %rbx
  804160026d:	41 5c                	pop    %r12
  804160026f:	5d                   	pop    %rbp
  8041600270:	c3                   	retq   

0000008041600271 <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8041600271:	55                   	push   %rbp
  8041600272:	48 89 e5             	mov    %rsp,%rbp
  8041600275:	41 54                	push   %r12
  8041600277:	53                   	push   %rbx
  8041600278:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160027f:	49 89 d4             	mov    %rdx,%r12
  8041600282:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8041600289:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8041600290:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  8041600297:	84 c0                	test   %al,%al
  8041600299:	74 23                	je     80416002be <_panic+0x4d>
  804160029b:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416002a2:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416002a6:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416002aa:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416002ae:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416002b2:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416002b6:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416002ba:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  if (panicstr)
  80416002be:	48 b8 00 a9 61 41 80 	movabs $0x804161a900,%rax
  80416002c5:	00 00 00 
  80416002c8:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416002cc:	74 13                	je     80416002e1 <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416002ce:	48 bb f9 3d 60 41 80 	movabs $0x8041603df9,%rbx
  80416002d5:	00 00 00 
  80416002d8:	bf 00 00 00 00       	mov    $0x0,%edi
  80416002dd:	ff d3                	callq  *%rbx
  while (1)
  80416002df:	eb f7                	jmp    80416002d8 <_panic+0x67>
  panicstr = fmt;
  80416002e1:	4c 89 e0             	mov    %r12,%rax
  80416002e4:	48 a3 00 a9 61 41 80 	movabs %rax,0x804161a900
  80416002eb:	00 00 00 
  __asm __volatile("cli; cld");
  80416002ee:	fa                   	cli    
  80416002ef:	fc                   	cld    
  va_start(ap, fmt);
  80416002f0:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416002f7:	00 00 00 
  80416002fa:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8041600301:	00 00 00 
  8041600304:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041600308:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  804160030f:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  8041600316:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel panic at %s:%d: ", file, line);
  804160031d:	89 f2                	mov    %esi,%edx
  804160031f:	48 89 fe             	mov    %rdi,%rsi
  8041600322:	48 bf a0 83 60 41 80 	movabs $0x80416083a0,%rdi
  8041600329:	00 00 00 
  804160032c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600331:	48 bb 6a 5a 60 41 80 	movabs $0x8041605a6a,%rbx
  8041600338:	00 00 00 
  804160033b:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  804160033d:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600344:	4c 89 e7             	mov    %r12,%rdi
  8041600347:	48 b8 36 5a 60 41 80 	movabs $0x8041605a36,%rax
  804160034e:	00 00 00 
  8041600351:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600353:	48 bf 70 84 60 41 80 	movabs $0x8041608470,%rdi
  804160035a:	00 00 00 
  804160035d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600362:	ff d3                	callq  *%rbx
  va_end(ap);
  8041600364:	e9 65 ff ff ff       	jmpq   80416002ce <_panic+0x5d>

0000008041600369 <timers_schedule>:
timers_schedule(const char *name) {
  8041600369:	55                   	push   %rbp
  804160036a:	48 89 e5             	mov    %rsp,%rbp
  804160036d:	41 56                	push   %r14
  804160036f:	41 55                	push   %r13
  8041600371:	41 54                	push   %r12
  8041600373:	53                   	push   %rbx
  8041600374:	49 89 fd             	mov    %rdi,%r13
  for (int i = 0; i < MAX_TIMERS; i++) {
  8041600377:	49 bc 80 dc 61 41 80 	movabs $0x804161dc80,%r12
  804160037e:	00 00 00 
  8041600381:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
  8041600386:	49 be f7 7a 60 41 80 	movabs $0x8041607af7,%r14
  804160038d:	00 00 00 
  8041600390:	eb 3a                	jmp    80416003cc <timers_schedule+0x63>
        panic("Timer %s does not support interrupts\n", name);
  8041600392:	4c 89 e9             	mov    %r13,%rcx
  8041600395:	48 ba 40 84 60 41 80 	movabs $0x8041608440,%rdx
  804160039c:	00 00 00 
  804160039f:	be 2c 00 00 00       	mov    $0x2c,%esi
  80416003a4:	48 bf b8 83 60 41 80 	movabs $0x80416083b8,%rdi
  80416003ab:	00 00 00 
  80416003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416003b3:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416003ba:	00 00 00 
  80416003bd:	41 ff d0             	callq  *%r8
  for (int i = 0; i < MAX_TIMERS; i++) {
  80416003c0:	83 c3 01             	add    $0x1,%ebx
  80416003c3:	49 83 c4 28          	add    $0x28,%r12
  80416003c7:	83 fb 05             	cmp    $0x5,%ebx
  80416003ca:	74 4d                	je     8041600419 <timers_schedule+0xb0>
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
  80416003cc:	49 8b 3c 24          	mov    (%r12),%rdi
  80416003d0:	48 85 ff             	test   %rdi,%rdi
  80416003d3:	74 eb                	je     80416003c0 <timers_schedule+0x57>
  80416003d5:	4c 89 ee             	mov    %r13,%rsi
  80416003d8:	41 ff d6             	callq  *%r14
  80416003db:	85 c0                	test   %eax,%eax
  80416003dd:	75 e1                	jne    80416003c0 <timers_schedule+0x57>
      if (timertab[i].enable_interrupts != NULL) {
  80416003df:	48 63 c3             	movslq %ebx,%rax
  80416003e2:	48 8d 14 80          	lea    (%rax,%rax,4),%rdx
  80416003e6:	48 b8 80 dc 61 41 80 	movabs $0x804161dc80,%rax
  80416003ed:	00 00 00 
  80416003f0:	48 8b 74 d0 18       	mov    0x18(%rax,%rdx,8),%rsi
  80416003f5:	48 85 f6             	test   %rsi,%rsi
  80416003f8:	74 98                	je     8041600392 <timers_schedule+0x29>
        timer_for_schedule = &timertab[i];
  80416003fa:	48 89 d1             	mov    %rdx,%rcx
  80416003fd:	48 8d 14 c8          	lea    (%rax,%rcx,8),%rdx
  8041600401:	48 89 d0             	mov    %rdx,%rax
  8041600404:	48 a3 60 dc 61 41 80 	movabs %rax,0x804161dc60
  804160040b:	00 00 00 
        timertab[i].enable_interrupts();
  804160040e:	ff d6                	callq  *%rsi
}
  8041600410:	5b                   	pop    %rbx
  8041600411:	41 5c                	pop    %r12
  8041600413:	41 5d                	pop    %r13
  8041600415:	41 5e                	pop    %r14
  8041600417:	5d                   	pop    %rbp
  8041600418:	c3                   	retq   
  panic("Timer %s does not exist\n", name);
  8041600419:	4c 89 e9             	mov    %r13,%rcx
  804160041c:	48 ba c4 83 60 41 80 	movabs $0x80416083c4,%rdx
  8041600423:	00 00 00 
  8041600426:	be 32 00 00 00       	mov    $0x32,%esi
  804160042b:	48 bf b8 83 60 41 80 	movabs $0x80416083b8,%rdi
  8041600432:	00 00 00 
  8041600435:	b8 00 00 00 00       	mov    $0x0,%eax
  804160043a:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041600441:	00 00 00 
  8041600444:	41 ff d0             	callq  *%r8

0000008041600447 <i386_init>:
i386_init(void) {
  8041600447:	55                   	push   %rbp
  8041600448:	48 89 e5             	mov    %rsp,%rbp
  804160044b:	41 54                	push   %r12
  804160044d:	53                   	push   %rbx
  early_boot_pml4_init();
  804160044e:	48 b8 1b 02 60 41 80 	movabs $0x804160021b,%rax
  8041600455:	00 00 00 
  8041600458:	ff d0                	callq  *%rax
  cons_init();
  804160045a:	48 b8 76 0c 60 41 80 	movabs $0x8041600c76,%rax
  8041600461:	00 00 00 
  8041600464:	ff d0                	callq  *%rax
  tsc_calibrate();
  8041600466:	48 b8 69 7e 60 41 80 	movabs $0x8041607e69,%rax
  804160046d:	00 00 00 
  8041600470:	ff d0                	callq  *%rax
  cprintf("6828 decimal is %o octal!\n", 6828);
  8041600472:	be ac 1a 00 00       	mov    $0x1aac,%esi
  8041600477:	48 bf dd 83 60 41 80 	movabs $0x80416083dd,%rdi
  804160047e:	00 00 00 
  8041600481:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600486:	48 bb 6a 5a 60 41 80 	movabs $0x8041605a6a,%rbx
  804160048d:	00 00 00 
  8041600490:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  8041600492:	48 be 00 e0 61 41 80 	movabs $0x804161e000,%rsi
  8041600499:	00 00 00 
  804160049c:	48 bf f8 83 60 41 80 	movabs $0x80416083f8,%rdi
  80416004a3:	00 00 00 
  80416004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416004ab:	ff d3                	callq  *%rbx
  mem_init();
  80416004ad:	48 b8 e1 44 60 41 80 	movabs $0x80416044e1,%rax
  80416004b4:	00 00 00 
  80416004b7:	ff d0                	callq  *%rax
  while (ctor < &__ctors_end) {
  80416004b9:	48 ba e8 a8 61 41 80 	movabs $0x804161a8e8,%rdx
  80416004c0:	00 00 00 
  80416004c3:	48 b8 e8 a8 61 41 80 	movabs $0x804161a8e8,%rax
  80416004ca:	00 00 00 
  80416004cd:	48 39 c2             	cmp    %rax,%rdx
  80416004d0:	73 23                	jae    80416004f5 <i386_init+0xae>
  80416004d2:	48 89 d3             	mov    %rdx,%rbx
  80416004d5:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80416004d9:	48 29 d0             	sub    %rdx,%rax
  80416004dc:	48 c1 e8 03          	shr    $0x3,%rax
  80416004e0:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80416004e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416004ea:	ff 13                	callq  *(%rbx)
    ctor++;
  80416004ec:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80416004f0:	4c 39 e3             	cmp    %r12,%rbx
  80416004f3:	75 f0                	jne    80416004e5 <i386_init+0x9e>
  pic_init();
  80416004f5:	48 b8 4c 59 60 41 80 	movabs $0x804160594c,%rax
  80416004fc:	00 00 00 
  80416004ff:	ff d0                	callq  *%rax
  rtc_init();
  8041600501:	48 b8 c6 57 60 41 80 	movabs $0x80416057c6,%rax
  8041600508:	00 00 00 
  804160050b:	ff d0                	callq  *%rax
  timers_init();
  804160050d:	48 b8 19 00 60 41 80 	movabs $0x8041600019,%rax
  8041600514:	00 00 00 
  8041600517:	ff d0                	callq  *%rax
  fb_init();
  8041600519:	48 b8 69 0b 60 41 80 	movabs $0x8041600b69,%rax
  8041600520:	00 00 00 
  8041600523:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  8041600525:	48 bf 01 84 60 41 80 	movabs $0x8041608401,%rdi
  804160052c:	00 00 00 
  804160052f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600534:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  804160053b:	00 00 00 
  804160053e:	ff d2                	callq  *%rdx
  env_init();
  8041600540:	48 b8 b7 53 60 41 80 	movabs $0x80416053b7,%rax
  8041600547:	00 00 00 
  804160054a:	ff d0                	callq  *%rax
  timers_schedule("hpet0");
  804160054c:	48 bf 1a 84 60 41 80 	movabs $0x804160841a,%rdi
  8041600553:	00 00 00 
  8041600556:	48 b8 69 03 60 41 80 	movabs $0x8041600369,%rax
  804160055d:	00 00 00 
  8041600560:	ff d0                	callq  *%rax
  clock_idt_init();
  8041600562:	48 b8 fe 5a 60 41 80 	movabs $0x8041605afe,%rax
  8041600569:	00 00 00 
  804160056c:	ff d0                	callq  *%rax
  sched_yield();
  804160056e:	48 b8 f5 6b 60 41 80 	movabs $0x8041606bf5,%rax
  8041600575:	00 00 00 
  8041600578:	ff d0                	callq  *%rax

000000804160057a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  804160057a:	55                   	push   %rbp
  804160057b:	48 89 e5             	mov    %rsp,%rbp
  804160057e:	41 54                	push   %r12
  8041600580:	53                   	push   %rbx
  8041600581:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600588:	49 89 d4             	mov    %rdx,%r12
  804160058b:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8041600592:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8041600599:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416005a0:	84 c0                	test   %al,%al
  80416005a2:	74 23                	je     80416005c7 <_warn+0x4d>
  80416005a4:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416005ab:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416005af:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416005b3:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416005b7:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416005bb:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416005bf:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416005c3:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416005c7:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416005ce:	00 00 00 
  80416005d1:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416005d8:	00 00 00 
  80416005db:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416005df:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416005e6:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416005ed:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  80416005f4:	89 f2                	mov    %esi,%edx
  80416005f6:	48 89 fe             	mov    %rdi,%rsi
  80416005f9:	48 bf 20 84 60 41 80 	movabs $0x8041608420,%rdi
  8041600600:	00 00 00 
  8041600603:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600608:	48 bb 6a 5a 60 41 80 	movabs $0x8041605a6a,%rbx
  804160060f:	00 00 00 
  8041600612:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600614:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160061b:	4c 89 e7             	mov    %r12,%rdi
  804160061e:	48 b8 36 5a 60 41 80 	movabs $0x8041605a36,%rax
  8041600625:	00 00 00 
  8041600628:	ff d0                	callq  *%rax
  cprintf("\n");
  804160062a:	48 bf 70 84 60 41 80 	movabs $0x8041608470,%rdi
  8041600631:	00 00 00 
  8041600634:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600639:	ff d3                	callq  *%rbx
  va_end(ap);
}
  804160063b:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  8041600642:	5b                   	pop    %rbx
  8041600643:	41 5c                	pop    %r12
  8041600645:	5d                   	pop    %rbp
  8041600646:	c3                   	retq   

0000008041600647 <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  8041600647:	ba fd 03 00 00       	mov    $0x3fd,%edx
  804160064c:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  804160064d:	a8 01                	test   $0x1,%al
  804160064f:	74 0a                	je     804160065b <serial_proc_data+0x14>
  8041600651:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600656:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  8041600657:	0f b6 c0             	movzbl %al,%eax
  804160065a:	c3                   	retq   
    return -1;
  804160065b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  8041600660:	c3                   	retq   

0000008041600661 <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  8041600661:	55                   	push   %rbp
  8041600662:	48 89 e5             	mov    %rsp,%rbp
  8041600665:	41 54                	push   %r12
  8041600667:	53                   	push   %rbx
  8041600668:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  804160066b:	48 bb 40 a9 61 41 80 	movabs $0x804161a940,%rbx
  8041600672:	00 00 00 
  while ((c = (*proc)()) != -1) {
  8041600675:	41 ff d4             	callq  *%r12
  8041600678:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160067b:	74 28                	je     80416006a5 <cons_intr+0x44>
    if (c == 0)
  804160067d:	85 c0                	test   %eax,%eax
  804160067f:	74 f4                	je     8041600675 <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  8041600681:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  8041600687:	8d 51 01             	lea    0x1(%rcx),%edx
  804160068a:	89 c9                	mov    %ecx,%ecx
  804160068c:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  804160068f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  8041600695:	b8 00 00 00 00       	mov    $0x0,%eax
  804160069a:	0f 44 d0             	cmove  %eax,%edx
  804160069d:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  80416006a3:	eb d0                	jmp    8041600675 <cons_intr+0x14>
  }
}
  80416006a5:	5b                   	pop    %rbx
  80416006a6:	41 5c                	pop    %r12
  80416006a8:	5d                   	pop    %rbp
  80416006a9:	c3                   	retq   

00000080416006aa <kbd_proc_data>:
kbd_proc_data(void) {
  80416006aa:	55                   	push   %rbp
  80416006ab:	48 89 e5             	mov    %rsp,%rbp
  80416006ae:	53                   	push   %rbx
  80416006af:	48 83 ec 08          	sub    $0x8,%rsp
  80416006b3:	ba 64 00 00 00       	mov    $0x64,%edx
  80416006b8:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416006b9:	a8 01                	test   $0x1,%al
  80416006bb:	0f 84 31 01 00 00    	je     80416007f2 <kbd_proc_data+0x148>
  80416006c1:	ba 60 00 00 00       	mov    $0x60,%edx
  80416006c6:	ec                   	in     (%dx),%al
  80416006c7:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416006c9:	3c e0                	cmp    $0xe0,%al
  80416006cb:	0f 84 84 00 00 00    	je     8041600755 <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  80416006d1:	84 c0                	test   %al,%al
  80416006d3:	0f 88 97 00 00 00    	js     8041600770 <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  80416006d9:	48 bf 20 a9 61 41 80 	movabs $0x804161a920,%rdi
  80416006e0:	00 00 00 
  80416006e3:	8b 0f                	mov    (%rdi),%ecx
  80416006e5:	f6 c1 40             	test   $0x40,%cl
  80416006e8:	74 0c                	je     80416006f6 <kbd_proc_data+0x4c>
    data |= 0x80;
  80416006ea:	83 c8 80             	or     $0xffffff80,%eax
  80416006ed:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416006ef:	89 c8                	mov    %ecx,%eax
  80416006f1:	83 e0 bf             	and    $0xffffffbf,%eax
  80416006f4:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  80416006f6:	0f b6 f2             	movzbl %dl,%esi
  80416006f9:	48 b8 c0 85 60 41 80 	movabs $0x80416085c0,%rax
  8041600700:	00 00 00 
  8041600703:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  8041600707:	48 b9 20 a9 61 41 80 	movabs $0x804161a920,%rcx
  804160070e:	00 00 00 
  8041600711:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  8041600713:	48 bf c0 84 60 41 80 	movabs $0x80416084c0,%rdi
  804160071a:	00 00 00 
  804160071d:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  8041600721:	31 f0                	xor    %esi,%eax
  8041600723:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  8041600725:	89 c6                	mov    %eax,%esi
  8041600727:	83 e6 03             	and    $0x3,%esi
  804160072a:	0f b6 d2             	movzbl %dl,%edx
  804160072d:	48 b9 a0 84 60 41 80 	movabs $0x80416084a0,%rcx
  8041600734:	00 00 00 
  8041600737:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  804160073b:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  804160073f:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  8041600742:	a8 08                	test   $0x8,%al
  8041600744:	74 73                	je     80416007b9 <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  8041600746:	89 da                	mov    %ebx,%edx
  8041600748:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  804160074b:	83 f9 19             	cmp    $0x19,%ecx
  804160074e:	77 5d                	ja     80416007ad <kbd_proc_data+0x103>
      c += 'A' - 'a';
  8041600750:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8041600753:	eb 12                	jmp    8041600767 <kbd_proc_data+0xbd>
    shift |= E0ESC;
  8041600755:	48 b8 20 a9 61 41 80 	movabs $0x804161a920,%rax
  804160075c:	00 00 00 
  804160075f:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  8041600762:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8041600767:	89 d8                	mov    %ebx,%eax
  8041600769:	48 83 c4 08          	add    $0x8,%rsp
  804160076d:	5b                   	pop    %rbx
  804160076e:	5d                   	pop    %rbp
  804160076f:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600770:	48 bf 20 a9 61 41 80 	movabs $0x804161a920,%rdi
  8041600777:	00 00 00 
  804160077a:	8b 0f                	mov    (%rdi),%ecx
  804160077c:	89 ce                	mov    %ecx,%esi
  804160077e:	83 e6 40             	and    $0x40,%esi
  8041600781:	83 e0 7f             	and    $0x7f,%eax
  8041600784:	85 f6                	test   %esi,%esi
  8041600786:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  8041600789:	0f b6 d2             	movzbl %dl,%edx
  804160078c:	48 b8 c0 85 60 41 80 	movabs $0x80416085c0,%rax
  8041600793:	00 00 00 
  8041600796:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  804160079a:	83 c8 40             	or     $0x40,%eax
  804160079d:	0f b6 c0             	movzbl %al,%eax
  80416007a0:	f7 d0                	not    %eax
  80416007a2:	21 c8                	and    %ecx,%eax
  80416007a4:	89 07                	mov    %eax,(%rdi)
    return 0;
  80416007a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416007ab:	eb ba                	jmp    8041600767 <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  80416007ad:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416007b0:	8d 4b 20             	lea    0x20(%rbx),%ecx
  80416007b3:	83 fa 1a             	cmp    $0x1a,%edx
  80416007b6:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416007b9:	f7 d0                	not    %eax
  80416007bb:	a8 06                	test   $0x6,%al
  80416007bd:	75 a8                	jne    8041600767 <kbd_proc_data+0xbd>
  80416007bf:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  80416007c5:	75 a0                	jne    8041600767 <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  80416007c7:	48 bf 66 84 60 41 80 	movabs $0x8041608466,%rdi
  80416007ce:	00 00 00 
  80416007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416007d6:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416007dd:	00 00 00 
  80416007e0:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416007e2:	b8 03 00 00 00       	mov    $0x3,%eax
  80416007e7:	ba 92 00 00 00       	mov    $0x92,%edx
  80416007ec:	ee                   	out    %al,(%dx)
  80416007ed:	e9 75 ff ff ff       	jmpq   8041600767 <kbd_proc_data+0xbd>
    return -1;
  80416007f2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80416007f7:	e9 6b ff ff ff       	jmpq   8041600767 <kbd_proc_data+0xbd>

00000080416007fc <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  80416007fc:	48 b8 54 ab 61 41 80 	movabs $0x804161ab54,%rax
  8041600803:	00 00 00 
  8041600806:	44 8b 10             	mov    (%rax),%r10d
  8041600809:	41 0f af d2          	imul   %r10d,%edx
  804160080d:	01 f2                	add    %esi,%edx
  804160080f:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  8041600816:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  8041600817:	4d 0f be c0          	movsbq %r8b,%r8
  804160081b:	48 b8 20 a3 61 41 80 	movabs $0x804161a320,%rax
  8041600822:	00 00 00 
  8041600825:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  8041600829:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  804160082d:	eb 25                	jmp    8041600854 <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  804160082f:	83 c0 01             	add    $0x1,%eax
  8041600832:	83 f8 08             	cmp    $0x8,%eax
  8041600835:	74 11                	je     8041600848 <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  8041600837:	0f be 16             	movsbl (%rsi),%edx
  804160083a:	0f a3 c2             	bt     %eax,%edx
  804160083d:	73 f0                	jae    804160082f <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160083f:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  8041600843:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  8041600846:	eb e7                	jmp    804160082f <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  8041600848:	45 01 d1             	add    %r10d,%r9d
  804160084b:	48 83 c6 01          	add    $0x1,%rsi
  804160084f:	4c 39 c6             	cmp    %r8,%rsi
  8041600852:	74 07                	je     804160085b <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  8041600854:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600859:	eb dc                	jmp    8041600837 <draw_char+0x3b>
}
  804160085b:	c3                   	retq   

000000804160085c <cons_putc>:
  __asm __volatile("inb %w1,%0"
  804160085c:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600861:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600862:	a8 20                	test   $0x20,%al
  8041600864:	75 29                	jne    804160088f <cons_putc+0x33>
  for (i = 0;
  8041600866:	be 00 00 00 00       	mov    $0x0,%esi
  804160086b:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600870:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  8041600876:	89 ca                	mov    %ecx,%edx
  8041600878:	ec                   	in     (%dx),%al
  8041600879:	ec                   	in     (%dx),%al
  804160087a:	ec                   	in     (%dx),%al
  804160087b:	ec                   	in     (%dx),%al
       i++)
  804160087c:	83 c6 01             	add    $0x1,%esi
  804160087f:	44 89 c2             	mov    %r8d,%edx
  8041600882:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600883:	a8 20                	test   $0x20,%al
  8041600885:	75 08                	jne    804160088f <cons_putc+0x33>
  8041600887:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  804160088d:	7e e7                	jle    8041600876 <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  804160088f:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  8041600892:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600897:	89 f8                	mov    %edi,%eax
  8041600899:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160089a:	ba 79 03 00 00       	mov    $0x379,%edx
  804160089f:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  80416008a0:	84 c0                	test   %al,%al
  80416008a2:	78 29                	js     80416008cd <cons_putc+0x71>
  80416008a4:	be 00 00 00 00       	mov    $0x0,%esi
  80416008a9:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416008ae:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  80416008b4:	89 ca                	mov    %ecx,%edx
  80416008b6:	ec                   	in     (%dx),%al
  80416008b7:	ec                   	in     (%dx),%al
  80416008b8:	ec                   	in     (%dx),%al
  80416008b9:	ec                   	in     (%dx),%al
  80416008ba:	83 c6 01             	add    $0x1,%esi
  80416008bd:	44 89 ca             	mov    %r9d,%edx
  80416008c0:	ec                   	in     (%dx),%al
  80416008c1:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416008c7:	7f 04                	jg     80416008cd <cons_putc+0x71>
  80416008c9:	84 c0                	test   %al,%al
  80416008cb:	79 e7                	jns    80416008b4 <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416008cd:	ba 78 03 00 00       	mov    $0x378,%edx
  80416008d2:	44 89 c0             	mov    %r8d,%eax
  80416008d5:	ee                   	out    %al,(%dx)
  80416008d6:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416008db:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416008e0:	ee                   	out    %al,(%dx)
  80416008e1:	b8 08 00 00 00       	mov    $0x8,%eax
  80416008e6:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416008e7:	48 b8 5c ab 61 41 80 	movabs $0x804161ab5c,%rax
  80416008ee:	00 00 00 
  80416008f1:	80 38 00             	cmpb   $0x0,(%rax)
  80416008f4:	0f 84 42 02 00 00    	je     8041600b3c <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  80416008fa:	55                   	push   %rbp
  80416008fb:	48 89 e5             	mov    %rsp,%rbp
  80416008fe:	41 54                	push   %r12
  8041600900:	53                   	push   %rbx
  if (!(c & ~0xFF))
  8041600901:	89 fa                	mov    %edi,%edx
  8041600903:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  8041600909:	89 f8                	mov    %edi,%eax
  804160090b:	80 cc 07             	or     $0x7,%ah
  804160090e:	85 d2                	test   %edx,%edx
  8041600910:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  8041600913:	40 0f b6 c7          	movzbl %dil,%eax
  8041600917:	83 f8 09             	cmp    $0x9,%eax
  804160091a:	0f 84 e1 00 00 00    	je     8041600a01 <cons_putc+0x1a5>
  8041600920:	7e 5c                	jle    804160097e <cons_putc+0x122>
  8041600922:	83 f8 0a             	cmp    $0xa,%eax
  8041600925:	0f 84 b8 00 00 00    	je     80416009e3 <cons_putc+0x187>
  804160092b:	83 f8 0d             	cmp    $0xd,%eax
  804160092e:	0f 85 ff 00 00 00    	jne    8041600a33 <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  8041600934:	48 be 48 ab 61 41 80 	movabs $0x804161ab48,%rsi
  804160093b:	00 00 00 
  804160093e:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600941:	0f b7 c1             	movzwl %cx,%eax
  8041600944:	48 bb 50 ab 61 41 80 	movabs $0x804161ab50,%rbx
  804160094b:	00 00 00 
  804160094e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600953:	f7 33                	divl   (%rbx)
  8041600955:	29 d1                	sub    %edx,%ecx
  8041600957:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  804160095a:	48 b8 48 ab 61 41 80 	movabs $0x804161ab48,%rax
  8041600961:	00 00 00 
  8041600964:	0f b7 10             	movzwl (%rax),%edx
  8041600967:	48 b8 4c ab 61 41 80 	movabs $0x804161ab4c,%rax
  804160096e:	00 00 00 
  8041600971:	3b 10                	cmp    (%rax),%edx
  8041600973:	0f 83 0f 01 00 00    	jae    8041600a88 <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  8041600979:	5b                   	pop    %rbx
  804160097a:	41 5c                	pop    %r12
  804160097c:	5d                   	pop    %rbp
  804160097d:	c3                   	retq   
  switch (c & 0xff) {
  804160097e:	83 f8 08             	cmp    $0x8,%eax
  8041600981:	0f 85 ac 00 00 00    	jne    8041600a33 <cons_putc+0x1d7>
      if (crt_pos > 0) {
  8041600987:	66 a1 48 ab 61 41 80 	movabs 0x804161ab48,%ax
  804160098e:	00 00 00 
  8041600991:	66 85 c0             	test   %ax,%ax
  8041600994:	74 c4                	je     804160095a <cons_putc+0xfe>
        crt_pos--;
  8041600996:	83 e8 01             	sub    $0x1,%eax
  8041600999:	66 a3 48 ab 61 41 80 	movabs %ax,0x804161ab48
  80416009a0:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  80416009a3:	0f b7 c0             	movzwl %ax,%eax
  80416009a6:	48 bb 50 ab 61 41 80 	movabs $0x804161ab50,%rbx
  80416009ad:	00 00 00 
  80416009b0:	8b 1b                	mov    (%rbx),%ebx
  80416009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  80416009b7:	f7 f3                	div    %ebx
  80416009b9:	89 d6                	mov    %edx,%esi
  80416009bb:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416009c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416009c6:	89 c2                	mov    %eax,%edx
  80416009c8:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416009cf:	00 00 00 
  80416009d2:	48 b8 fc 07 60 41 80 	movabs $0x80416007fc,%rax
  80416009d9:	00 00 00 
  80416009dc:	ff d0                	callq  *%rax
  80416009de:	e9 77 ff ff ff       	jmpq   804160095a <cons_putc+0xfe>
      crt_pos += crt_cols;
  80416009e3:	48 b8 48 ab 61 41 80 	movabs $0x804161ab48,%rax
  80416009ea:	00 00 00 
  80416009ed:	48 bb 50 ab 61 41 80 	movabs $0x804161ab50,%rbx
  80416009f4:	00 00 00 
  80416009f7:	8b 13                	mov    (%rbx),%edx
  80416009f9:	66 01 10             	add    %dx,(%rax)
  80416009fc:	e9 33 ff ff ff       	jmpq   8041600934 <cons_putc+0xd8>
      cons_putc(' ');
  8041600a01:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a06:	48 bb 5c 08 60 41 80 	movabs $0x804160085c,%rbx
  8041600a0d:	00 00 00 
  8041600a10:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a12:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a17:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a19:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a1e:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a20:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a25:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a27:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a2c:	ff d3                	callq  *%rbx
      break;
  8041600a2e:	e9 27 ff ff ff       	jmpq   804160095a <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600a33:	49 bc 48 ab 61 41 80 	movabs $0x804161ab48,%r12
  8041600a3a:	00 00 00 
  8041600a3d:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600a42:	0f b7 c3             	movzwl %bx,%eax
  8041600a45:	48 be 50 ab 61 41 80 	movabs $0x804161ab50,%rsi
  8041600a4c:	00 00 00 
  8041600a4f:	8b 36                	mov    (%rsi),%esi
  8041600a51:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600a56:	f7 f6                	div    %esi
  8041600a58:	89 d6                	mov    %edx,%esi
  8041600a5a:	44 0f be c7          	movsbl %dil,%r8d
  8041600a5e:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600a63:	89 c2                	mov    %eax,%edx
  8041600a65:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600a6c:	00 00 00 
  8041600a6f:	48 b8 fc 07 60 41 80 	movabs $0x80416007fc,%rax
  8041600a76:	00 00 00 
  8041600a79:	ff d0                	callq  *%rax
      crt_pos++;
  8041600a7b:	83 c3 01             	add    $0x1,%ebx
  8041600a7e:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  8041600a83:	e9 d2 fe ff ff       	jmpq   804160095a <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600a88:	48 bb 54 ab 61 41 80 	movabs $0x804161ab54,%rbx
  8041600a8f:	00 00 00 
  8041600a92:	8b 03                	mov    (%rbx),%eax
  8041600a94:	49 bc 58 ab 61 41 80 	movabs $0x804161ab58,%r12
  8041600a9b:	00 00 00 
  8041600a9e:	41 8b 3c 24          	mov    (%r12),%edi
  8041600aa2:	8d 57 f8             	lea    -0x8(%rdi),%edx
  8041600aa5:	0f af d0             	imul   %eax,%edx
  8041600aa8:	48 c1 e2 02          	shl    $0x2,%rdx
  8041600aac:	c1 e0 03             	shl    $0x3,%eax
  8041600aaf:	89 c0                	mov    %eax,%eax
  8041600ab1:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600ab8:	00 00 00 
  8041600abb:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  8041600abf:	48 b8 f3 7b 60 41 80 	movabs $0x8041607bf3,%rax
  8041600ac6:	00 00 00 
  8041600ac9:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600acb:	41 8b 04 24          	mov    (%r12),%eax
  8041600acf:	8b 0b                	mov    (%rbx),%ecx
  8041600ad1:	89 c6                	mov    %eax,%esi
  8041600ad3:	83 e6 f8             	and    $0xfffffff8,%esi
  8041600ad6:	83 ee 08             	sub    $0x8,%esi
  8041600ad9:	0f af f1             	imul   %ecx,%esi
  8041600adc:	0f af c8             	imul   %eax,%ecx
  8041600adf:	39 f1                	cmp    %esi,%ecx
  8041600ae1:	76 3b                	jbe    8041600b1e <cons_putc+0x2c2>
  8041600ae3:	48 63 fe             	movslq %esi,%rdi
  8041600ae6:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  8041600aed:	00 00 00 
  8041600af0:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  8041600af4:	8d 51 ff             	lea    -0x1(%rcx),%edx
  8041600af7:	89 d1                	mov    %edx,%ecx
  8041600af9:	29 f1                	sub    %esi,%ecx
  8041600afb:	48 ba 01 00 b0 0f 20 	movabs $0x200fb00001,%rdx
  8041600b02:	00 00 00 
  8041600b05:	48 01 fa             	add    %rdi,%rdx
  8041600b08:	48 01 ca             	add    %rcx,%rdx
  8041600b0b:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600b0f:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600b15:	48 83 c0 04          	add    $0x4,%rax
  8041600b19:	48 39 c2             	cmp    %rax,%rdx
  8041600b1c:	75 f1                	jne    8041600b0f <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600b1e:	48 b8 48 ab 61 41 80 	movabs $0x804161ab48,%rax
  8041600b25:	00 00 00 
  8041600b28:	48 bb 50 ab 61 41 80 	movabs $0x804161ab50,%rbx
  8041600b2f:	00 00 00 
  8041600b32:	8b 13                	mov    (%rbx),%edx
  8041600b34:	66 29 10             	sub    %dx,(%rax)
}
  8041600b37:	e9 3d fe ff ff       	jmpq   8041600979 <cons_putc+0x11d>
  8041600b3c:	c3                   	retq   

0000008041600b3d <serial_intr>:
  if (serial_exists)
  8041600b3d:	48 b8 4a ab 61 41 80 	movabs $0x804161ab4a,%rax
  8041600b44:	00 00 00 
  8041600b47:	80 38 00             	cmpb   $0x0,(%rax)
  8041600b4a:	75 01                	jne    8041600b4d <serial_intr+0x10>
  8041600b4c:	c3                   	retq   
serial_intr(void) {
  8041600b4d:	55                   	push   %rbp
  8041600b4e:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600b51:	48 bf 47 06 60 41 80 	movabs $0x8041600647,%rdi
  8041600b58:	00 00 00 
  8041600b5b:	48 b8 61 06 60 41 80 	movabs $0x8041600661,%rax
  8041600b62:	00 00 00 
  8041600b65:	ff d0                	callq  *%rax
}
  8041600b67:	5d                   	pop    %rbp
  8041600b68:	c3                   	retq   

0000008041600b69 <fb_init>:
fb_init(void) {
  8041600b69:	55                   	push   %rbp
  8041600b6a:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600b6d:	48 b8 00 a0 61 41 80 	movabs $0x804161a000,%rax
  8041600b74:	00 00 00 
  8041600b77:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600b7a:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600b7d:	89 d0                	mov    %edx,%eax
  8041600b7f:	a3 58 ab 61 41 80 00 	movabs %eax,0x804161ab58
  8041600b86:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600b88:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600b8b:	a3 54 ab 61 41 80 00 	movabs %eax,0x804161ab54
  8041600b92:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600b94:	c1 e8 03             	shr    $0x3,%eax
  8041600b97:	89 c6                	mov    %eax,%esi
  8041600b99:	a3 50 ab 61 41 80 00 	movabs %eax,0x804161ab50
  8041600ba0:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600ba2:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600ba5:	0f af d0             	imul   %eax,%edx
  8041600ba8:	89 d0                	mov    %edx,%eax
  8041600baa:	a3 4c ab 61 41 80 00 	movabs %eax,0x804161ab4c
  8041600bb1:	00 00 
  crt_pos           = crt_cols;
  8041600bb3:	89 f0                	mov    %esi,%eax
  8041600bb5:	66 a3 48 ab 61 41 80 	movabs %ax,0x804161ab48
  8041600bbc:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600bbf:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600bc2:	be 00 00 00 00       	mov    $0x0,%esi
  8041600bc7:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600bce:	00 00 00 
  8041600bd1:	48 b8 b0 7b 60 41 80 	movabs $0x8041607bb0,%rax
  8041600bd8:	00 00 00 
  8041600bdb:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600bdd:	48 b8 5c ab 61 41 80 	movabs $0x804161ab5c,%rax
  8041600be4:	00 00 00 
  8041600be7:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600bea:	5d                   	pop    %rbp
  8041600beb:	c3                   	retq   

0000008041600bec <kbd_intr>:
kbd_intr(void) {
  8041600bec:	55                   	push   %rbp
  8041600bed:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600bf0:	48 bf aa 06 60 41 80 	movabs $0x80416006aa,%rdi
  8041600bf7:	00 00 00 
  8041600bfa:	48 b8 61 06 60 41 80 	movabs $0x8041600661,%rax
  8041600c01:	00 00 00 
  8041600c04:	ff d0                	callq  *%rax
}
  8041600c06:	5d                   	pop    %rbp
  8041600c07:	c3                   	retq   

0000008041600c08 <cons_getc>:
cons_getc(void) {
  8041600c08:	55                   	push   %rbp
  8041600c09:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600c0c:	48 b8 3d 0b 60 41 80 	movabs $0x8041600b3d,%rax
  8041600c13:	00 00 00 
  8041600c16:	ff d0                	callq  *%rax
  kbd_intr();
  8041600c18:	48 b8 ec 0b 60 41 80 	movabs $0x8041600bec,%rax
  8041600c1f:	00 00 00 
  8041600c22:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600c24:	48 b9 40 a9 61 41 80 	movabs $0x804161a940,%rcx
  8041600c2b:	00 00 00 
  8041600c2e:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600c34:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600c39:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600c3f:	74 21                	je     8041600c62 <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600c41:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600c44:	48 b8 40 a9 61 41 80 	movabs $0x804161a940,%rax
  8041600c4b:	00 00 00 
  8041600c4e:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600c54:	89 d2                	mov    %edx,%edx
  8041600c56:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600c5a:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600c60:	74 02                	je     8041600c64 <cons_getc+0x5c>
}
  8041600c62:	5d                   	pop    %rbp
  8041600c63:	c3                   	retq   
      cons.rpos = 0;
  8041600c64:	48 be 40 ab 61 41 80 	movabs $0x804161ab40,%rsi
  8041600c6b:	00 00 00 
  8041600c6e:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600c74:	eb ec                	jmp    8041600c62 <cons_getc+0x5a>

0000008041600c76 <cons_init>:
  8041600c76:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600c7b:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600c80:	89 c8                	mov    %ecx,%eax
  8041600c82:	89 fa                	mov    %edi,%edx
  8041600c84:	ee                   	out    %al,(%dx)
  8041600c85:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600c8b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600c90:	44 89 ca             	mov    %r9d,%edx
  8041600c93:	ee                   	out    %al,(%dx)
  8041600c94:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600c99:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600c9e:	89 f2                	mov    %esi,%edx
  8041600ca0:	ee                   	out    %al,(%dx)
  8041600ca1:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600ca7:	89 c8                	mov    %ecx,%eax
  8041600ca9:	44 89 c2             	mov    %r8d,%edx
  8041600cac:	ee                   	out    %al,(%dx)
  8041600cad:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600cb2:	44 89 ca             	mov    %r9d,%edx
  8041600cb5:	ee                   	out    %al,(%dx)
  8041600cb6:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600cbb:	89 c8                	mov    %ecx,%eax
  8041600cbd:	ee                   	out    %al,(%dx)
  8041600cbe:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600cc3:	44 89 c2             	mov    %r8d,%edx
  8041600cc6:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600cc7:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600ccc:	ec                   	in     (%dx),%al
  8041600ccd:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600ccf:	3c ff                	cmp    $0xff,%al
  8041600cd1:	0f 95 c0             	setne  %al
  8041600cd4:	a2 4a ab 61 41 80 00 	movabs %al,0x804161ab4a
  8041600cdb:	00 00 
  8041600cdd:	89 fa                	mov    %edi,%edx
  8041600cdf:	ec                   	in     (%dx),%al
  8041600ce0:	89 f2                	mov    %esi,%edx
  8041600ce2:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600ce3:	80 f9 ff             	cmp    $0xff,%cl
  8041600ce6:	74 01                	je     8041600ce9 <cons_init+0x73>
  8041600ce8:	c3                   	retq   
cons_init(void) {
  8041600ce9:	55                   	push   %rbp
  8041600cea:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600ced:	48 bf 72 84 60 41 80 	movabs $0x8041608472,%rdi
  8041600cf4:	00 00 00 
  8041600cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600cfc:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041600d03:	00 00 00 
  8041600d06:	ff d2                	callq  *%rdx
}
  8041600d08:	5d                   	pop    %rbp
  8041600d09:	c3                   	retq   

0000008041600d0a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600d0a:	55                   	push   %rbp
  8041600d0b:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600d0e:	48 b8 5c 08 60 41 80 	movabs $0x804160085c,%rax
  8041600d15:	00 00 00 
  8041600d18:	ff d0                	callq  *%rax
}
  8041600d1a:	5d                   	pop    %rbp
  8041600d1b:	c3                   	retq   

0000008041600d1c <getchar>:

int
getchar(void) {
  8041600d1c:	55                   	push   %rbp
  8041600d1d:	48 89 e5             	mov    %rsp,%rbp
  8041600d20:	53                   	push   %rbx
  8041600d21:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600d25:	48 bb 08 0c 60 41 80 	movabs $0x8041600c08,%rbx
  8041600d2c:	00 00 00 
  8041600d2f:	ff d3                	callq  *%rbx
  8041600d31:	85 c0                	test   %eax,%eax
  8041600d33:	74 fa                	je     8041600d2f <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600d35:	48 83 c4 08          	add    $0x8,%rsp
  8041600d39:	5b                   	pop    %rbx
  8041600d3a:	5d                   	pop    %rbp
  8041600d3b:	c3                   	retq   

0000008041600d3c <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600d41:	c3                   	retq   

0000008041600d42 <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600d42:	55                   	push   %rbp
  8041600d43:	48 89 e5             	mov    %rsp,%rbp
  8041600d46:	41 56                	push   %r14
  8041600d48:	41 55                	push   %r13
  8041600d4a:	41 54                	push   %r12
  8041600d4c:	53                   	push   %rbx
  8041600d4d:	48 83 ec 20          	sub    $0x20,%rsp
  8041600d51:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600d55:	83 fe 20             	cmp    $0x20,%esi
  8041600d58:	0f 87 42 09 00 00    	ja     80416016a0 <dwarf_read_abbrev_entry+0x95e>
  8041600d5e:	44 89 c3             	mov    %r8d,%ebx
  8041600d61:	41 89 cd             	mov    %ecx,%r13d
  8041600d64:	49 89 d4             	mov    %rdx,%r12
  8041600d67:	89 f6                	mov    %esi,%esi
  8041600d69:	48 b8 78 87 60 41 80 	movabs $0x8041608778,%rax
  8041600d70:	00 00 00 
  8041600d73:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600d76:	48 85 d2             	test   %rdx,%rdx
  8041600d79:	74 6f                	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
  8041600d7b:	83 f9 07             	cmp    $0x7,%ecx
  8041600d7e:	76 6a                	jbe    8041600dea <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600d80:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600d85:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d89:	4c 89 e7             	mov    %r12,%rdi
  8041600d8c:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600d93:	00 00 00 
  8041600d96:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600d98:	eb 50                	jmp    8041600dea <dwarf_read_abbrev_entry+0xa8>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB2 code
        
      unsigned length = get_unaligned(entry, uint16_t);
  8041600d9a:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d9f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600da3:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600da7:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600dae:	00 00 00 
  8041600db1:	ff d0                	callq  *%rax
  8041600db3:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(uint16_t);
  8041600db7:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600dbb:	48 83 c0 02          	add    $0x2,%rax
  8041600dbf:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600dc3:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600dc7:	89 5d d8             	mov    %ebx,-0x28(%rbp)
        .mem = entry,
        .len = length,
      };
      if (buf) {
  8041600dca:	4d 85 e4             	test   %r12,%r12
  8041600dcd:	74 18                	je     8041600de7 <dwarf_read_abbrev_entry+0xa5>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600dcf:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600dd4:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600dd8:	4c 89 e7             	mov    %r12,%rdi
  8041600ddb:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600de2:	00 00 00 
  8041600de5:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(uint16_t) + length;
  8041600de7:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600dea:	89 d8                	mov    %ebx,%eax
  8041600dec:	48 83 c4 20          	add    $0x20,%rsp
  8041600df0:	5b                   	pop    %rbx
  8041600df1:	41 5c                	pop    %r12
  8041600df3:	41 5d                	pop    %r13
  8041600df5:	41 5e                	pop    %r14
  8041600df7:	5d                   	pop    %rbp
  8041600df8:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600df9:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600dfe:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e02:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e06:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600e0d:	00 00 00 
  8041600e10:	ff d0                	callq  *%rax
  8041600e12:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600e15:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600e19:	48 83 c0 04          	add    $0x4,%rax
  8041600e1d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600e21:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600e25:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600e28:	4d 85 e4             	test   %r12,%r12
  8041600e2b:	74 18                	je     8041600e45 <dwarf_read_abbrev_entry+0x103>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600e2d:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600e32:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e36:	4c 89 e7             	mov    %r12,%rdi
  8041600e39:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600e40:	00 00 00 
  8041600e43:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600e45:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600e48:	eb a0                	jmp    8041600dea <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600e4a:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e4f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e53:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e57:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600e5e:	00 00 00 
  8041600e61:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600e63:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600e68:	4d 85 e4             	test   %r12,%r12
  8041600e6b:	74 06                	je     8041600e73 <dwarf_read_abbrev_entry+0x131>
  8041600e6d:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600e71:	77 0a                	ja     8041600e7d <dwarf_read_abbrev_entry+0x13b>
      bytes = sizeof(Dwarf_Half);
  8041600e73:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600e78:	e9 6d ff ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e7d:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e82:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e86:	4c 89 e7             	mov    %r12,%rdi
  8041600e89:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600e90:	00 00 00 
  8041600e93:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600e95:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e9a:	e9 4b ff ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600e9f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ea4:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ea8:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600eac:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600eb3:	00 00 00 
  8041600eb6:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600eb8:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600ebd:	4d 85 e4             	test   %r12,%r12
  8041600ec0:	74 06                	je     8041600ec8 <dwarf_read_abbrev_entry+0x186>
  8041600ec2:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600ec6:	77 0a                	ja     8041600ed2 <dwarf_read_abbrev_entry+0x190>
      bytes = sizeof(uint32_t);
  8041600ec8:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600ecd:	e9 18 ff ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  8041600ed2:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ed7:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600edb:	4c 89 e7             	mov    %r12,%rdi
  8041600ede:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600ee5:	00 00 00 
  8041600ee8:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600eea:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600eef:	e9 f6 fe ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600ef4:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600ef9:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600efd:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f01:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600f08:	00 00 00 
  8041600f0b:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600f0d:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600f12:	4d 85 e4             	test   %r12,%r12
  8041600f15:	74 06                	je     8041600f1d <dwarf_read_abbrev_entry+0x1db>
  8041600f17:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600f1b:	77 0a                	ja     8041600f27 <dwarf_read_abbrev_entry+0x1e5>
      bytes = sizeof(uint64_t);
  8041600f1d:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600f22:	e9 c3 fe ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041600f27:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f2c:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f30:	4c 89 e7             	mov    %r12,%rdi
  8041600f33:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600f3a:	00 00 00 
  8041600f3d:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600f3f:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600f44:	e9 a1 fe ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      if (buf && bufsize >= sizeof(char *)) {
  8041600f49:	48 85 d2             	test   %rdx,%rdx
  8041600f4c:	74 05                	je     8041600f53 <dwarf_read_abbrev_entry+0x211>
  8041600f4e:	83 f9 07             	cmp    $0x7,%ecx
  8041600f51:	77 18                	ja     8041600f6b <dwarf_read_abbrev_entry+0x229>
      bytes = strlen(entry) + 1;
  8041600f53:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600f57:	48 b8 e8 79 60 41 80 	movabs $0x80416079e8,%rax
  8041600f5e:	00 00 00 
  8041600f61:	ff d0                	callq  *%rax
  8041600f63:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600f66:	e9 7f fe ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &entry, sizeof(char *));
  8041600f6b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f70:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600f74:	4c 89 e7             	mov    %r12,%rdi
  8041600f77:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600f7e:	00 00 00 
  8041600f81:	ff d0                	callq  *%rax
  8041600f83:	eb ce                	jmp    8041600f53 <dwarf_read_abbrev_entry+0x211>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600f85:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600f89:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600f8c:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600f91:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600f96:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600f9b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600f9e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600fa2:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600fa5:	89 f0                	mov    %esi,%eax
  8041600fa7:	83 e0 7f             	and    $0x7f,%eax
  8041600faa:	d3 e0                	shl    %cl,%eax
  8041600fac:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600fae:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600fb1:	40 84 f6             	test   %sil,%sil
  8041600fb4:	78 e5                	js     8041600f9b <dwarf_read_abbrev_entry+0x259>
      break;
  }

  *ret = result;

  return count;
  8041600fb6:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600fb9:	4d 01 e8             	add    %r13,%r8
  8041600fbc:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600fc0:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600fc4:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600fc7:	4d 85 e4             	test   %r12,%r12
  8041600fca:	74 18                	je     8041600fe4 <dwarf_read_abbrev_entry+0x2a2>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600fcc:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600fd1:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600fd5:	4c 89 e7             	mov    %r12,%rdi
  8041600fd8:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041600fdf:	00 00 00 
  8041600fe2:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600fe4:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600fe7:	e9 fe fd ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600fec:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600ff1:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ff5:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ff9:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601000:	00 00 00 
  8041601003:	ff d0                	callq  *%rax
  8041601005:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041601009:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160100d:	48 83 c0 01          	add    $0x1,%rax
  8041601011:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041601015:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041601019:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  804160101c:	4d 85 e4             	test   %r12,%r12
  804160101f:	74 18                	je     8041601039 <dwarf_read_abbrev_entry+0x2f7>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041601021:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601026:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160102a:	4c 89 e7             	mov    %r12,%rdi
  804160102d:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601034:	00 00 00 
  8041601037:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041601039:	83 c3 01             	add    $0x1,%ebx
    } break;
  804160103c:	e9 a9 fd ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601041:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601046:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160104a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160104e:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601055:	00 00 00 
  8041601058:	ff d0                	callq  *%rax
  804160105a:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160105e:	4d 85 e4             	test   %r12,%r12
  8041601061:	0f 84 43 06 00 00    	je     80416016aa <dwarf_read_abbrev_entry+0x968>
  8041601067:	45 85 ed             	test   %r13d,%r13d
  804160106a:	0f 84 3a 06 00 00    	je     80416016aa <dwarf_read_abbrev_entry+0x968>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601070:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601074:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601079:	e9 6c fd ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      bool data = get_unaligned(entry, Dwarf_Small);
  804160107e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601083:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601087:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160108b:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601092:	00 00 00 
  8041601095:	ff d0                	callq  *%rax
  8041601097:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  804160109b:	4d 85 e4             	test   %r12,%r12
  804160109e:	0f 84 10 06 00 00    	je     80416016b4 <dwarf_read_abbrev_entry+0x972>
  80416010a4:	45 85 ed             	test   %r13d,%r13d
  80416010a7:	0f 84 07 06 00 00    	je     80416016b4 <dwarf_read_abbrev_entry+0x972>
      bool data = get_unaligned(entry, Dwarf_Small);
  80416010ad:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  80416010af:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  80416010b4:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  80416010b9:	e9 2c fd ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      int count = dwarf_read_leb128(entry, &data);
  80416010be:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416010c2:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  80416010c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416010ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416010cf:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  80416010d4:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416010d7:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  80416010db:	89 f0                	mov    %esi,%eax
  80416010dd:	83 e0 7f             	and    $0x7f,%eax
  80416010e0:	d3 e0                	shl    %cl,%eax
  80416010e2:	09 c7                	or     %eax,%edi
    shift += 7;
  80416010e4:	83 c1 07             	add    $0x7,%ecx
    count++;
  80416010e7:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  80416010ea:	40 84 f6             	test   %sil,%sil
  80416010ed:	78 e5                	js     80416010d4 <dwarf_read_abbrev_entry+0x392>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  80416010ef:	83 f9 1f             	cmp    $0x1f,%ecx
  80416010f2:	7f 0f                	jg     8041601103 <dwarf_read_abbrev_entry+0x3c1>
  80416010f4:	40 f6 c6 40          	test   $0x40,%sil
  80416010f8:	74 09                	je     8041601103 <dwarf_read_abbrev_entry+0x3c1>
    result |= (-1U << shift);
  80416010fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416010ff:	d3 e0                	shl    %cl,%eax
  8041601101:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  8041601103:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601106:	49 01 c0             	add    %rax,%r8
  8041601109:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  804160110d:	4d 85 e4             	test   %r12,%r12
  8041601110:	0f 84 d4 fc ff ff    	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
  8041601116:	41 83 fd 03          	cmp    $0x3,%r13d
  804160111a:	0f 86 ca fc ff ff    	jbe    8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (int *)buf);
  8041601120:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601123:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601128:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160112c:	4c 89 e7             	mov    %r12,%rdi
  804160112f:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601136:	00 00 00 
  8041601139:	ff d0                	callq  *%rax
  804160113b:	e9 aa fc ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601140:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601144:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601149:	4c 89 f6             	mov    %r14,%rsi
  804160114c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601150:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601157:	00 00 00 
  804160115a:	ff d0                	callq  *%rax
  804160115c:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160115f:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601161:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601166:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601169:	76 2a                	jbe    8041601195 <dwarf_read_abbrev_entry+0x453>
    if (initial_len == DW_EXT_DWARF64) {
  804160116b:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160116e:	74 60                	je     80416011d0 <dwarf_read_abbrev_entry+0x48e>
      cprintf("Unknown DWARF extension\n");
  8041601170:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  8041601177:	00 00 00 
  804160117a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160117f:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041601186:	00 00 00 
  8041601189:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  804160118b:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  8041601190:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  8041601195:	48 63 c3             	movslq %ebx,%rax
  8041601198:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  804160119c:	4d 85 e4             	test   %r12,%r12
  804160119f:	0f 84 45 fc ff ff    	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
  80416011a5:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011a9:	0f 86 3b fc ff ff    	jbe    8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416011af:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416011b3:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011b8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011bc:	4c 89 e7             	mov    %r12,%rdi
  80416011bf:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416011c6:	00 00 00 
  80416011c9:	ff d0                	callq  *%rax
  80416011cb:	e9 1a fc ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416011d0:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416011d4:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011d9:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416011dd:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416011e4:	00 00 00 
  80416011e7:	ff d0                	callq  *%rax
  80416011e9:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416011ed:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416011f2:	eb a1                	jmp    8041601195 <dwarf_read_abbrev_entry+0x453>
      int count         = dwarf_read_uleb128(entry, &data);
  80416011f4:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416011f8:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  80416011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601200:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601205:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  804160120a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160120d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601211:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601214:	89 f0                	mov    %esi,%eax
  8041601216:	83 e0 7f             	and    $0x7f,%eax
  8041601219:	d3 e0                	shl    %cl,%eax
  804160121b:	09 c7                	or     %eax,%edi
    shift += 7;
  804160121d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601220:	40 84 f6             	test   %sil,%sil
  8041601223:	78 e5                	js     804160120a <dwarf_read_abbrev_entry+0x4c8>
  return count;
  8041601225:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601228:	49 01 c0             	add    %rax,%r8
  804160122b:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160122f:	4d 85 e4             	test   %r12,%r12
  8041601232:	0f 84 b2 fb ff ff    	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
  8041601238:	41 83 fd 03          	cmp    $0x3,%r13d
  804160123c:	0f 86 a8 fb ff ff    	jbe    8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  8041601242:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601245:	ba 04 00 00 00       	mov    $0x4,%edx
  804160124a:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160124e:	4c 89 e7             	mov    %r12,%rdi
  8041601251:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601258:	00 00 00 
  804160125b:	ff d0                	callq  *%rax
  804160125d:	e9 88 fb ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601262:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601266:	ba 04 00 00 00       	mov    $0x4,%edx
  804160126b:	4c 89 f6             	mov    %r14,%rsi
  804160126e:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601272:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601279:	00 00 00 
  804160127c:	ff d0                	callq  *%rax
  804160127e:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601281:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601283:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601288:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160128b:	76 2a                	jbe    80416012b7 <dwarf_read_abbrev_entry+0x575>
    if (initial_len == DW_EXT_DWARF64) {
  804160128d:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601290:	74 60                	je     80416012f2 <dwarf_read_abbrev_entry+0x5b0>
      cprintf("Unknown DWARF extension\n");
  8041601292:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  8041601299:	00 00 00 
  804160129c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416012a1:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416012a8:	00 00 00 
  80416012ab:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416012ad:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416012b2:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416012b7:	48 63 c3             	movslq %ebx,%rax
  80416012ba:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416012be:	4d 85 e4             	test   %r12,%r12
  80416012c1:	0f 84 23 fb ff ff    	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
  80416012c7:	41 83 fd 07          	cmp    $0x7,%r13d
  80416012cb:	0f 86 19 fb ff ff    	jbe    8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416012d1:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416012d5:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012da:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012de:	4c 89 e7             	mov    %r12,%rdi
  80416012e1:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416012e8:	00 00 00 
  80416012eb:	ff d0                	callq  *%rax
  80416012ed:	e9 f8 fa ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416012f2:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416012f6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012fb:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012ff:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601306:	00 00 00 
  8041601309:	ff d0                	callq  *%rax
  804160130b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  804160130f:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601314:	eb a1                	jmp    80416012b7 <dwarf_read_abbrev_entry+0x575>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601316:	ba 01 00 00 00       	mov    $0x1,%edx
  804160131b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160131f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601323:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  804160132a:	00 00 00 
  804160132d:	ff d0                	callq  *%rax
  804160132f:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601333:	4d 85 e4             	test   %r12,%r12
  8041601336:	0f 84 82 03 00 00    	je     80416016be <dwarf_read_abbrev_entry+0x97c>
  804160133c:	45 85 ed             	test   %r13d,%r13d
  804160133f:	0f 84 79 03 00 00    	je     80416016be <dwarf_read_abbrev_entry+0x97c>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601345:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601349:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  804160134e:	e9 97 fa ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041601353:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601358:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160135c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601360:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601367:	00 00 00 
  804160136a:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  804160136c:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041601371:	4d 85 e4             	test   %r12,%r12
  8041601374:	74 06                	je     804160137c <dwarf_read_abbrev_entry+0x63a>
  8041601376:	41 83 fd 01          	cmp    $0x1,%r13d
  804160137a:	77 0a                	ja     8041601386 <dwarf_read_abbrev_entry+0x644>
      bytes = sizeof(Dwarf_Half);
  804160137c:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041601381:	e9 64 fa ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041601386:	ba 02 00 00 00       	mov    $0x2,%edx
  804160138b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160138f:	4c 89 e7             	mov    %r12,%rdi
  8041601392:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601399:	00 00 00 
  804160139c:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  804160139e:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  80416013a3:	e9 42 fa ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416013a8:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013ad:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013b1:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416013b5:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416013bc:	00 00 00 
  80416013bf:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416013c1:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416013c6:	4d 85 e4             	test   %r12,%r12
  80416013c9:	74 06                	je     80416013d1 <dwarf_read_abbrev_entry+0x68f>
  80416013cb:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013cf:	77 0a                	ja     80416013db <dwarf_read_abbrev_entry+0x699>
      bytes = sizeof(uint32_t);
  80416013d1:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416013d6:	e9 0f fa ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  80416013db:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013e0:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013e4:	4c 89 e7             	mov    %r12,%rdi
  80416013e7:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416013ee:	00 00 00 
  80416013f1:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  80416013f3:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  80416013f8:	e9 ed f9 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  80416013fd:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601402:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601406:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160140a:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601411:	00 00 00 
  8041601414:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601416:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  804160141b:	4d 85 e4             	test   %r12,%r12
  804160141e:	74 06                	je     8041601426 <dwarf_read_abbrev_entry+0x6e4>
  8041601420:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601424:	77 0a                	ja     8041601430 <dwarf_read_abbrev_entry+0x6ee>
      bytes = sizeof(uint64_t);
  8041601426:	bb 08 00 00 00       	mov    $0x8,%ebx
  804160142b:	e9 ba f9 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041601430:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601435:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601439:	4c 89 e7             	mov    %r12,%rdi
  804160143c:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601443:	00 00 00 
  8041601446:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601448:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  804160144d:	e9 98 f9 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601452:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601456:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601459:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160145e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601463:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601468:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160146b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160146f:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601472:	89 f0                	mov    %esi,%eax
  8041601474:	83 e0 7f             	and    $0x7f,%eax
  8041601477:	d3 e0                	shl    %cl,%eax
  8041601479:	09 c7                	or     %eax,%edi
    shift += 7;
  804160147b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160147e:	40 84 f6             	test   %sil,%sil
  8041601481:	78 e5                	js     8041601468 <dwarf_read_abbrev_entry+0x726>
  return count;
  8041601483:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601486:	49 01 c0             	add    %rax,%r8
  8041601489:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160148d:	4d 85 e4             	test   %r12,%r12
  8041601490:	0f 84 54 f9 ff ff    	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
  8041601496:	41 83 fd 03          	cmp    $0x3,%r13d
  804160149a:	0f 86 4a f9 ff ff    	jbe    8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  80416014a0:	89 7d d0             	mov    %edi,-0x30(%rbp)
  80416014a3:	ba 04 00 00 00       	mov    $0x4,%edx
  80416014a8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416014ac:	4c 89 e7             	mov    %r12,%rdi
  80416014af:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416014b6:	00 00 00 
  80416014b9:	ff d0                	callq  *%rax
  80416014bb:	e9 2a f9 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &form);
  80416014c0:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416014c4:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416014c7:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416014cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014d2:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416014d7:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416014db:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416014df:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416014e3:	44 89 c0             	mov    %r8d,%eax
  80416014e6:	83 e0 7f             	and    $0x7f,%eax
  80416014e9:	d3 e0                	shl    %cl,%eax
  80416014eb:	09 c6                	or     %eax,%esi
    shift += 7;
  80416014ed:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416014f0:	45 84 c0             	test   %r8b,%r8b
  80416014f3:	78 e2                	js     80416014d7 <dwarf_read_abbrev_entry+0x795>
  return count;
  80416014f5:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  80416014f8:	48 01 c7             	add    %rax,%rdi
  80416014fb:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  80416014ff:	41 89 d8             	mov    %ebx,%r8d
  8041601502:	44 89 e9             	mov    %r13d,%ecx
  8041601505:	4c 89 e2             	mov    %r12,%rdx
  8041601508:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  804160150f:	00 00 00 
  8041601512:	ff d0                	callq  *%rax
      bytes    = count + read;
  8041601514:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601518:	e9 cd f8 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160151d:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601521:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601526:	4c 89 f6             	mov    %r14,%rsi
  8041601529:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160152d:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601534:	00 00 00 
  8041601537:	ff d0                	callq  *%rax
  8041601539:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160153c:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160153e:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601543:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601546:	76 2a                	jbe    8041601572 <dwarf_read_abbrev_entry+0x830>
    if (initial_len == DW_EXT_DWARF64) {
  8041601548:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160154b:	74 60                	je     80416015ad <dwarf_read_abbrev_entry+0x86b>
      cprintf("Unknown DWARF extension\n");
  804160154d:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  8041601554:	00 00 00 
  8041601557:	b8 00 00 00 00       	mov    $0x0,%eax
  804160155c:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041601563:	00 00 00 
  8041601566:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601568:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160156d:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  8041601572:	48 63 c3             	movslq %ebx,%rax
  8041601575:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601579:	4d 85 e4             	test   %r12,%r12
  804160157c:	0f 84 68 f8 ff ff    	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
  8041601582:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601586:	0f 86 5e f8 ff ff    	jbe    8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  804160158c:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601590:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601595:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601599:	4c 89 e7             	mov    %r12,%rdi
  804160159c:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416015a3:	00 00 00 
  80416015a6:	ff d0                	callq  *%rax
  80416015a8:	e9 3d f8 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416015ad:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416015b1:	ba 08 00 00 00       	mov    $0x8,%edx
  80416015b6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416015ba:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416015c1:	00 00 00 
  80416015c4:	ff d0                	callq  *%rax
  80416015c6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416015ca:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416015cf:	eb a1                	jmp    8041601572 <dwarf_read_abbrev_entry+0x830>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416015d1:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416015d5:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416015d8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416015de:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416015e3:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416015e8:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416015eb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416015ef:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416015f3:	89 f8                	mov    %edi,%eax
  80416015f5:	83 e0 7f             	and    $0x7f,%eax
  80416015f8:	d3 e0                	shl    %cl,%eax
  80416015fa:	09 c3                	or     %eax,%ebx
    shift += 7;
  80416015fc:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416015ff:	40 84 ff             	test   %dil,%dil
  8041601602:	78 e4                	js     80416015e8 <dwarf_read_abbrev_entry+0x8a6>
  return count;
  8041601604:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  8041601607:	4c 01 f6             	add    %r14,%rsi
  804160160a:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  804160160e:	4d 85 e4             	test   %r12,%r12
  8041601611:	74 1a                	je     804160162d <dwarf_read_abbrev_entry+0x8eb>
        memcpy(buf, entry, MIN(length, bufsize));
  8041601613:	41 39 dd             	cmp    %ebx,%r13d
  8041601616:	44 89 ea             	mov    %r13d,%edx
  8041601619:	0f 47 d3             	cmova  %ebx,%edx
  804160161c:	89 d2                	mov    %edx,%edx
  804160161e:	4c 89 e7             	mov    %r12,%rdi
  8041601621:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601628:	00 00 00 
  804160162b:	ff d0                	callq  *%rax
      bytes = count + length;
  804160162d:	44 01 f3             	add    %r14d,%ebx
    } break;
  8041601630:	e9 b5 f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      bytes = 0;
  8041601635:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  804160163a:	48 85 d2             	test   %rdx,%rdx
  804160163d:	0f 84 a7 f7 ff ff    	je     8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(true, (bool *)buf);
  8041601643:	c6 02 01             	movb   $0x1,(%rdx)
  8041601646:	e9 9f f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  804160164b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601650:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601654:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601658:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  804160165f:	00 00 00 
  8041601662:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601664:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601669:	4d 85 e4             	test   %r12,%r12
  804160166c:	74 06                	je     8041601674 <dwarf_read_abbrev_entry+0x932>
  804160166e:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601672:	77 0a                	ja     804160167e <dwarf_read_abbrev_entry+0x93c>
      bytes = sizeof(uint64_t);
  8041601674:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  8041601679:	e9 6c f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  804160167e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601683:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601687:	4c 89 e7             	mov    %r12,%rdi
  804160168a:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601691:	00 00 00 
  8041601694:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601696:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  804160169b:	e9 4a f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
  int bytes = 0;
  80416016a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416016a5:	e9 40 f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016aa:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016af:	e9 36 f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016b4:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016b9:	e9 2c f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016be:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016c3:	e9 22 f7 ff ff       	jmpq   8041600dea <dwarf_read_abbrev_entry+0xa8>

00000080416016c8 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416016c8:	55                   	push   %rbp
  80416016c9:	48 89 e5             	mov    %rsp,%rbp
  80416016cc:	41 57                	push   %r15
  80416016ce:	41 56                	push   %r14
  80416016d0:	41 55                	push   %r13
  80416016d2:	41 54                	push   %r12
  80416016d4:	53                   	push   %rbx
  80416016d5:	48 83 ec 48          	sub    $0x48,%rsp
  80416016d9:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80416016dd:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416016e1:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  80416016e5:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416016e9:	49 bd 61 7c 60 41 80 	movabs $0x8041607c61,%r13
  80416016f0:	00 00 00 
  80416016f3:	e9 bb 01 00 00       	jmpq   80416018b3 <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416016f8:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416016fc:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601701:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601705:	41 ff d5             	callq  *%r13
  8041601708:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  804160170c:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601711:	eb 08                	jmp    804160171b <info_by_address+0x53>
    *len = initial_len;
  8041601713:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  8041601716:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  804160171b:	4c 63 fb             	movslq %ebx,%r15
  804160171e:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  8041601722:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  8041601725:	ba 02 00 00 00       	mov    $0x2,%edx
  804160172a:	48 89 de             	mov    %rbx,%rsi
  804160172d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601731:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  8041601734:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  8041601738:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160173d:	75 7a                	jne    80416017b9 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  804160173f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601744:	48 89 de             	mov    %rbx,%rsi
  8041601747:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160174b:	41 ff d5             	callq  *%r13
  804160174e:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041601751:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  8041601754:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  8041601757:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  804160175b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601760:	48 89 de             	mov    %rbx,%rsi
  8041601763:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601767:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  804160176a:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160176e:	75 7e                	jne    80416017ee <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  8041601770:	48 83 c3 02          	add    $0x2,%rbx
  8041601774:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601779:	4c 89 fe             	mov    %r15,%rsi
  804160177c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601780:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  8041601783:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  8041601787:	0f 85 96 00 00 00    	jne    8041601823 <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  804160178d:	48 89 d8             	mov    %rbx,%rax
  8041601790:	4c 29 f0             	sub    %r14,%rax
  8041601793:	48 99                	cqto   
  8041601795:	48 c1 ea 3c          	shr    $0x3c,%rdx
  8041601799:	48 01 d0             	add    %rdx,%rax
  804160179c:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  804160179f:	48 29 d0             	sub    %rdx,%rax
  80416017a2:	0f 84 b5 00 00 00    	je     804160185d <info_by_address+0x195>
      set += 2 * address_size - remainder;
  80416017a8:	ba 10 00 00 00       	mov    $0x10,%edx
  80416017ad:	89 d1                	mov    %edx,%ecx
  80416017af:	29 c1                	sub    %eax,%ecx
  80416017b1:	48 01 cb             	add    %rcx,%rbx
  80416017b4:	e9 a4 00 00 00       	jmpq   804160185d <info_by_address+0x195>
    assert(version == 2);
  80416017b9:	48 b9 3e 87 60 41 80 	movabs $0x804160873e,%rcx
  80416017c0:	00 00 00 
  80416017c3:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416017ca:	00 00 00 
  80416017cd:	be 20 00 00 00       	mov    $0x20,%esi
  80416017d2:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  80416017d9:	00 00 00 
  80416017dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017e1:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416017e8:	00 00 00 
  80416017eb:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416017ee:	48 b9 fb 86 60 41 80 	movabs $0x80416086fb,%rcx
  80416017f5:	00 00 00 
  80416017f8:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416017ff:	00 00 00 
  8041601802:	be 24 00 00 00       	mov    $0x24,%esi
  8041601807:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  804160180e:	00 00 00 
  8041601811:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601816:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160181d:	00 00 00 
  8041601820:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  8041601823:	48 b9 0d 87 60 41 80 	movabs $0x804160870d,%rcx
  804160182a:	00 00 00 
  804160182d:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601834:	00 00 00 
  8041601837:	be 26 00 00 00       	mov    $0x26,%esi
  804160183c:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601843:	00 00 00 
  8041601846:	b8 00 00 00 00       	mov    $0x0,%eax
  804160184b:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601852:	00 00 00 
  8041601855:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601858:	4c 39 e3             	cmp    %r12,%rbx
  804160185b:	73 51                	jae    80416018ae <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  804160185d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601862:	48 89 de             	mov    %rbx,%rsi
  8041601865:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601869:	41 ff d5             	callq  *%r13
  804160186c:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  8041601870:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  8041601874:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601879:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160187d:	41 ff d5             	callq  *%r13
  8041601880:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  8041601883:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  8041601887:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  804160188b:	4c 39 f1             	cmp    %r14,%rcx
  804160188e:	72 c8                	jb     8041601858 <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  8041601890:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  8041601892:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  8041601895:	48 39 c1             	cmp    %rax,%rcx
  8041601898:	77 be                	ja     8041601858 <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  804160189a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160189e:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  80416018a1:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  80416018a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018a9:	e9 5a 04 00 00       	jmpq   8041601d08 <info_by_address+0x640>
      set += address_size;
  80416018ae:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  80416018b1:	75 71                	jne    8041601924 <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  80416018b3:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018b7:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  80416018bb:	73 42                	jae    80416018ff <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  80416018bd:	ba 04 00 00 00       	mov    $0x4,%edx
  80416018c2:	4c 89 f6             	mov    %r14,%rsi
  80416018c5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018c9:	41 ff d5             	callq  *%r13
  80416018cc:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416018d0:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  80416018d4:	0f 86 39 fe ff ff    	jbe    8041601713 <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  80416018da:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  80416018de:	0f 84 14 fe ff ff    	je     80416016f8 <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  80416018e4:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  80416018eb:	00 00 00 
  80416018ee:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018f3:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416018fa:	00 00 00 
  80416018fd:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  80416018ff:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601903:	48 8b 58 20          	mov    0x20(%rax),%rbx
  8041601907:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  804160190b:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  804160190f:	0f 83 5b 04 00 00    	jae    8041601d70 <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  8041601915:	49 bf 61 7c 60 41 80 	movabs $0x8041607c61,%r15
  804160191c:	00 00 00 
  804160191f:	e9 9f 03 00 00       	jmpq   8041601cc3 <info_by_address+0x5fb>
    assert(set == set_end);
  8041601924:	48 b9 1f 87 60 41 80 	movabs $0x804160871f,%rcx
  804160192b:	00 00 00 
  804160192e:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601935:	00 00 00 
  8041601938:	be 3a 00 00 00       	mov    $0x3a,%esi
  804160193d:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601944:	00 00 00 
  8041601947:	b8 00 00 00 00       	mov    $0x0,%eax
  804160194c:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601953:	00 00 00 
  8041601956:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601959:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160195d:	48 8d 70 20          	lea    0x20(%rax),%rsi
  8041601961:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601966:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160196a:	41 ff d7             	callq  *%r15
  804160196d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041601971:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601977:	eb 08                	jmp    8041601981 <info_by_address+0x2b9>
    *len = initial_len;
  8041601979:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160197b:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  8041601981:	4d 63 e4             	movslq %r12d,%r12
  8041601984:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041601988:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  804160198c:	48 01 d8             	add    %rbx,%rax
  804160198f:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601993:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601998:	48 89 de             	mov    %rbx,%rsi
  804160199b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160199f:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  80416019a2:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  80416019a6:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416019aa:	83 e8 02             	sub    $0x2,%eax
  80416019ad:	66 a9 fd ff          	test   $0xfffd,%ax
  80416019b1:	0f 85 07 01 00 00    	jne    8041601abe <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416019b7:	ba 04 00 00 00       	mov    $0x4,%edx
  80416019bc:	48 89 de             	mov    %rbx,%rsi
  80416019bf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019c3:	41 ff d7             	callq  *%r15
  80416019c6:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  80416019ca:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416019ce:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  80416019d2:	ba 01 00 00 00       	mov    $0x1,%edx
  80416019d7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019db:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  80416019de:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416019e2:	0f 85 0b 01 00 00    	jne    8041601af3 <info_by_address+0x42b>
  80416019e8:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  80416019eb:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416019f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416019f5:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416019fa:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  80416019fe:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a02:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a05:	44 89 c7             	mov    %r8d,%edi
  8041601a08:	83 e7 7f             	and    $0x7f,%edi
  8041601a0b:	d3 e7                	shl    %cl,%edi
  8041601a0d:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a0f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a12:	45 84 c0             	test   %r8b,%r8b
  8041601a15:	78 e3                	js     80416019fa <info_by_address+0x332>
  return count;
  8041601a17:	48 98                	cltq   
    assert(abbrev_code != 0);
  8041601a19:	85 d2                	test   %edx,%edx
  8041601a1b:	0f 84 07 01 00 00    	je     8041601b28 <info_by_address+0x460>
    entry += count;
  8041601a21:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601a24:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601a28:	4c 03 28             	add    (%rax),%r13
  8041601a2b:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  8041601a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a33:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a38:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601a3d:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041601a41:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041601a45:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a48:	45 89 c8             	mov    %r9d,%r8d
  8041601a4b:	41 83 e0 7f          	and    $0x7f,%r8d
  8041601a4f:	41 d3 e0             	shl    %cl,%r8d
  8041601a52:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  8041601a55:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a58:	45 84 c9             	test   %r9b,%r9b
  8041601a5b:	78 e0                	js     8041601a3d <info_by_address+0x375>
  return count;
  8041601a5d:	48 98                	cltq   
    abbrev_entry += count;
  8041601a5f:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  8041601a62:	39 f2                	cmp    %esi,%edx
  8041601a64:	0f 85 f3 00 00 00    	jne    8041601b5d <info_by_address+0x495>
  8041601a6a:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  8041601a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a72:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a77:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601a7c:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601a80:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a84:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a87:	44 89 c7             	mov    %r8d,%edi
  8041601a8a:	83 e7 7f             	and    $0x7f,%edi
  8041601a8d:	d3 e7                	shl    %cl,%edi
  8041601a8f:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a91:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a94:	45 84 c0             	test   %r8b,%r8b
  8041601a97:	78 e3                	js     8041601a7c <info_by_address+0x3b4>
  return count;
  8041601a99:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  8041601a9b:	83 fa 11             	cmp    $0x11,%edx
  8041601a9e:	0f 85 ee 00 00 00    	jne    8041601b92 <info_by_address+0x4ca>
    abbrev_entry++;
  8041601aa4:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601aa9:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601ab0:	00 
  8041601ab1:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601ab8:	00 
  8041601ab9:	e9 2f 01 00 00       	jmpq   8041601bed <info_by_address+0x525>
    assert(version == 4 || version == 2);
  8041601abe:	48 b9 2e 87 60 41 80 	movabs $0x804160872e,%rcx
  8041601ac5:	00 00 00 
  8041601ac8:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601acf:	00 00 00 
  8041601ad2:	be 43 01 00 00       	mov    $0x143,%esi
  8041601ad7:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601ade:	00 00 00 
  8041601ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ae6:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601aed:	00 00 00 
  8041601af0:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601af3:	48 b9 fb 86 60 41 80 	movabs $0x80416086fb,%rcx
  8041601afa:	00 00 00 
  8041601afd:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601b04:	00 00 00 
  8041601b07:	be 47 01 00 00       	mov    $0x147,%esi
  8041601b0c:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601b13:	00 00 00 
  8041601b16:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b1b:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601b22:	00 00 00 
  8041601b25:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601b28:	48 b9 4b 87 60 41 80 	movabs $0x804160874b,%rcx
  8041601b2f:	00 00 00 
  8041601b32:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601b39:	00 00 00 
  8041601b3c:	be 4c 01 00 00       	mov    $0x14c,%esi
  8041601b41:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601b48:	00 00 00 
  8041601b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b50:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601b57:	00 00 00 
  8041601b5a:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601b5d:	48 b9 80 88 60 41 80 	movabs $0x8041608880,%rcx
  8041601b64:	00 00 00 
  8041601b67:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601b6e:	00 00 00 
  8041601b71:	be 54 01 00 00       	mov    $0x154,%esi
  8041601b76:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601b7d:	00 00 00 
  8041601b80:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b85:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601b8c:	00 00 00 
  8041601b8f:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601b92:	48 b9 5c 87 60 41 80 	movabs $0x804160875c,%rcx
  8041601b99:	00 00 00 
  8041601b9c:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601ba3:	00 00 00 
  8041601ba6:	be 58 01 00 00       	mov    $0x158,%esi
  8041601bab:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601bb2:	00 00 00 
  8041601bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601bba:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601bc1:	00 00 00 
  8041601bc4:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601bc7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601bcd:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601bd2:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601bd6:	44 89 f6             	mov    %r14d,%esi
  8041601bd9:	4c 89 e7             	mov    %r12,%rdi
  8041601bdc:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  8041601be3:	00 00 00 
  8041601be6:	ff d0                	callq  *%rax
      entry += count;
  8041601be8:	48 98                	cltq   
  8041601bea:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601bed:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601bf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601bfa:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601c00:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c03:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c07:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c0a:	89 fe                	mov    %edi,%esi
  8041601c0c:	83 e6 7f             	and    $0x7f,%esi
  8041601c0f:	d3 e6                	shl    %cl,%esi
  8041601c11:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601c14:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c17:	40 84 ff             	test   %dil,%dil
  8041601c1a:	78 e4                	js     8041601c00 <info_by_address+0x538>
  return count;
  8041601c1c:	48 98                	cltq   
      abbrev_entry += count;
  8041601c1e:	48 01 c3             	add    %rax,%rbx
  8041601c21:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c24:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c29:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c2e:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601c34:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c37:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c3b:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c3e:	89 fe                	mov    %edi,%esi
  8041601c40:	83 e6 7f             	and    $0x7f,%esi
  8041601c43:	d3 e6                	shl    %cl,%esi
  8041601c45:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601c48:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c4b:	40 84 ff             	test   %dil,%dil
  8041601c4e:	78 e4                	js     8041601c34 <info_by_address+0x56c>
  return count;
  8041601c50:	48 98                	cltq   
      abbrev_entry += count;
  8041601c52:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601c55:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601c59:	0f 84 68 ff ff ff    	je     8041601bc7 <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601c5f:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601c63:	0f 84 ae 00 00 00    	je     8041601d17 <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601c69:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c74:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601c79:	44 89 f6             	mov    %r14d,%esi
  8041601c7c:	4c 89 e7             	mov    %r12,%rdi
  8041601c7f:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  8041601c86:	00 00 00 
  8041601c89:	ff d0                	callq  *%rax
      entry += count;
  8041601c8b:	48 98                	cltq   
  8041601c8d:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601c90:	45 09 f5             	or     %r14d,%r13d
  8041601c93:	0f 85 54 ff ff ff    	jne    8041601bed <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601c99:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601c9d:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601ca1:	72 0a                	jb     8041601cad <info_by_address+0x5e5>
  8041601ca3:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601ca7:	0f 86 a2 00 00 00    	jbe    8041601d4f <info_by_address+0x687>
    entry = entry_end;
  8041601cad:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601cb1:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601cb5:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601cb9:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601cbd:	0f 83 a6 00 00 00    	jae    8041601d69 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601cc3:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601cc8:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601ccc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601cd0:	41 ff d7             	callq  *%r15
  8041601cd3:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601cd6:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601cd9:	0f 86 9a fc ff ff    	jbe    8041601979 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601cdf:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601ce2:	0f 84 71 fc ff ff    	je     8041601959 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601ce8:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  8041601cef:	00 00 00 
  8041601cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cf7:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041601cfe:	00 00 00 
  8041601d01:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601d03:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601d08:	48 83 c4 48          	add    $0x48,%rsp
  8041601d0c:	5b                   	pop    %rbx
  8041601d0d:	41 5c                	pop    %r12
  8041601d0f:	41 5d                	pop    %r13
  8041601d11:	41 5e                	pop    %r14
  8041601d13:	41 5f                	pop    %r15
  8041601d15:	5d                   	pop    %rbp
  8041601d16:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601d17:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601d1d:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601d22:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601d26:	44 89 f6             	mov    %r14d,%esi
  8041601d29:	4c 89 e7             	mov    %r12,%rdi
  8041601d2c:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  8041601d33:	00 00 00 
  8041601d36:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601d38:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601d3c:	0f 84 a6 fe ff ff    	je     8041601be8 <info_by_address+0x520>
          high_pc += low_pc;
  8041601d42:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601d46:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601d4a:	e9 99 fe ff ff       	jmpq   8041601be8 <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601d4f:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601d53:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601d57:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601d5b:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601d5f:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601d62:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d67:	eb 9f                	jmp    8041601d08 <info_by_address+0x640>
  return 0;
  8041601d69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d6e:	eb 98                	jmp    8041601d08 <info_by_address+0x640>
  8041601d70:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d75:	eb 91                	jmp    8041601d08 <info_by_address+0x640>

0000008041601d77 <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601d77:	55                   	push   %rbp
  8041601d78:	48 89 e5             	mov    %rsp,%rbp
  8041601d7b:	41 57                	push   %r15
  8041601d7d:	41 56                	push   %r14
  8041601d7f:	41 55                	push   %r13
  8041601d81:	41 54                	push   %r12
  8041601d83:	53                   	push   %rbx
  8041601d84:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601d88:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601d8c:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601d90:	48 29 d8             	sub    %rbx,%rax
  8041601d93:	48 39 f0             	cmp    %rsi,%rax
  8041601d96:	0f 82 f5 02 00 00    	jb     8041602091 <file_name_by_info+0x31a>
  8041601d9c:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601da0:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601da3:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601da7:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601dab:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601dae:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601db3:	48 89 de             	mov    %rbx,%rsi
  8041601db6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601dba:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601dc1:	00 00 00 
  8041601dc4:	ff d0                	callq  *%rax
  8041601dc6:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601dc9:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601dcc:	0f 86 c9 02 00 00    	jbe    804160209b <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601dd2:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601dd5:	74 25                	je     8041601dfc <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601dd7:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  8041601dde:	00 00 00 
  8041601de1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601de6:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041601ded:	00 00 00 
  8041601df0:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601df2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601df7:	e9 00 02 00 00       	jmpq   8041601ffc <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601dfc:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601e00:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601e05:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601e09:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041601e10:	00 00 00 
  8041601e13:	ff d0                	callq  *%rax
      count = 12;
  8041601e15:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601e1b:	e9 81 02 00 00       	jmpq   80416020a1 <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601e20:	48 b9 2e 87 60 41 80 	movabs $0x804160872e,%rcx
  8041601e27:	00 00 00 
  8041601e2a:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601e31:	00 00 00 
  8041601e34:	be 9b 01 00 00       	mov    $0x19b,%esi
  8041601e39:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601e40:	00 00 00 
  8041601e43:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e48:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601e4f:	00 00 00 
  8041601e52:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601e55:	48 b9 fb 86 60 41 80 	movabs $0x80416086fb,%rcx
  8041601e5c:	00 00 00 
  8041601e5f:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601e66:	00 00 00 
  8041601e69:	be 9f 01 00 00       	mov    $0x19f,%esi
  8041601e6e:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601e75:	00 00 00 
  8041601e78:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e7d:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601e84:	00 00 00 
  8041601e87:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601e8a:	48 b9 4b 87 60 41 80 	movabs $0x804160874b,%rcx
  8041601e91:	00 00 00 
  8041601e94:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601e9b:	00 00 00 
  8041601e9e:	be a4 01 00 00       	mov    $0x1a4,%esi
  8041601ea3:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601eaa:	00 00 00 
  8041601ead:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601eb2:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601eb9:	00 00 00 
  8041601ebc:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601ebf:	48 b9 80 88 60 41 80 	movabs $0x8041608880,%rcx
  8041601ec6:	00 00 00 
  8041601ec9:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601ed0:	00 00 00 
  8041601ed3:	be ac 01 00 00       	mov    $0x1ac,%esi
  8041601ed8:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601edf:	00 00 00 
  8041601ee2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ee7:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601eee:	00 00 00 
  8041601ef1:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601ef4:	48 b9 5c 87 60 41 80 	movabs $0x804160875c,%rcx
  8041601efb:	00 00 00 
  8041601efe:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041601f05:	00 00 00 
  8041601f08:	be b0 01 00 00       	mov    $0x1b0,%esi
  8041601f0d:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041601f14:	00 00 00 
  8041601f17:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f1c:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041601f23:	00 00 00 
  8041601f26:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601f29:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601f2d:	0f 84 d8 00 00 00    	je     804160200b <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601f33:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f39:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601f3c:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601f40:	44 89 ee             	mov    %r13d,%esi
  8041601f43:	4c 89 f7             	mov    %r14,%rdi
  8041601f46:	41 ff d7             	callq  *%r15
  8041601f49:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601f4c:	49 63 c4             	movslq %r12d,%rax
  8041601f4f:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601f52:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f55:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f5f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601f65:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f68:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f6c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f6f:	89 f0                	mov    %esi,%eax
  8041601f71:	83 e0 7f             	and    $0x7f,%eax
  8041601f74:	d3 e0                	shl    %cl,%eax
  8041601f76:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601f79:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601f7c:	40 84 f6             	test   %sil,%sil
  8041601f7f:	78 e4                	js     8041601f65 <file_name_by_info+0x1ee>
  return count;
  8041601f81:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601f84:	48 01 fb             	add    %rdi,%rbx
  8041601f87:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f8a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f94:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601f9a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f9d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601fa1:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601fa4:	89 f0                	mov    %esi,%eax
  8041601fa6:	83 e0 7f             	and    $0x7f,%eax
  8041601fa9:	d3 e0                	shl    %cl,%eax
  8041601fab:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601fae:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601fb1:	40 84 f6             	test   %sil,%sil
  8041601fb4:	78 e4                	js     8041601f9a <file_name_by_info+0x223>
  return count;
  8041601fb6:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601fb9:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041601fbc:	41 83 fc 03          	cmp    $0x3,%r12d
  8041601fc0:	0f 84 63 ff ff ff    	je     8041601f29 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041601fc6:	41 83 fc 10          	cmp    $0x10,%r12d
  8041601fca:	0f 84 a1 00 00 00    	je     8041602071 <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601fd0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601fd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601fe0:	44 89 ee             	mov    %r13d,%esi
  8041601fe3:	4c 89 f7             	mov    %r14,%rdi
  8041601fe6:	41 ff d7             	callq  *%r15
    entry += count;
  8041601fe9:	48 98                	cltq   
  8041601feb:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601fee:	45 09 e5             	or     %r12d,%r13d
  8041601ff1:	0f 85 5b ff ff ff    	jne    8041601f52 <file_name_by_info+0x1db>

  return 0;
  8041601ff7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601ffc:	48 83 c4 38          	add    $0x38,%rsp
  8041602000:	5b                   	pop    %rbx
  8041602001:	41 5c                	pop    %r12
  8041602003:	41 5d                	pop    %r13
  8041602005:	41 5e                	pop    %r14
  8041602007:	41 5f                	pop    %r15
  8041602009:	5d                   	pop    %rbp
  804160200a:	c3                   	retq   
        unsigned long offset = 0;
  804160200b:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602012:	00 
        count                = dwarf_read_abbrev_entry(
  8041602013:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602019:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160201e:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602022:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602027:	4c 89 f7             	mov    %r14,%rdi
  804160202a:	41 ff d7             	callq  *%r15
  804160202d:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  8041602030:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041602034:	48 85 ff             	test   %rdi,%rdi
  8041602037:	0f 84 0f ff ff ff    	je     8041601f4c <file_name_by_info+0x1d5>
  804160203d:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  8041602041:	0f 86 05 ff ff ff    	jbe    8041601f4c <file_name_by_info+0x1d5>
          put_unaligned(
  8041602047:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160204b:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  804160204f:	48 03 41 40          	add    0x40(%rcx),%rax
  8041602053:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602057:	ba 08 00 00 00       	mov    $0x8,%edx
  804160205c:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602060:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041602067:	00 00 00 
  804160206a:	ff d0                	callq  *%rax
  804160206c:	e9 db fe ff ff       	jmpq   8041601f4c <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  8041602071:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602077:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160207c:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041602080:	44 89 ee             	mov    %r13d,%esi
  8041602083:	4c 89 f7             	mov    %r14,%rdi
  8041602086:	41 ff d7             	callq  *%r15
  8041602089:	41 89 c4             	mov    %eax,%r12d
  804160208c:	e9 bb fe ff ff       	jmpq   8041601f4c <file_name_by_info+0x1d5>
    return -E_INVAL;
  8041602091:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041602096:	e9 61 ff ff ff       	jmpq   8041601ffc <file_name_by_info+0x285>
  count       = 4;
  804160209b:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  80416020a1:	4d 63 ed             	movslq %r13d,%r13
  80416020a4:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416020a7:	ba 02 00 00 00       	mov    $0x2,%edx
  80416020ac:	48 89 de             	mov    %rbx,%rsi
  80416020af:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020b3:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416020ba:	00 00 00 
  80416020bd:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416020bf:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416020c3:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416020c7:	83 e8 02             	sub    $0x2,%eax
  80416020ca:	66 a9 fd ff          	test   $0xfffd,%ax
  80416020ce:	0f 85 4c fd ff ff    	jne    8041601e20 <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416020d4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416020d9:	48 89 de             	mov    %rbx,%rsi
  80416020dc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020e0:	49 bf 61 7c 60 41 80 	movabs $0x8041607c61,%r15
  80416020e7:	00 00 00 
  80416020ea:	41 ff d7             	callq  *%r15
  80416020ed:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  80416020f1:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416020f5:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416020f9:	ba 01 00 00 00       	mov    $0x1,%edx
  80416020fe:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602102:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  8041602105:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602109:	0f 85 46 fd ff ff    	jne    8041601e55 <file_name_by_info+0xde>
  804160210f:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602112:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602117:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160211c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602122:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602125:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602129:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160212c:	89 f0                	mov    %esi,%eax
  804160212e:	83 e0 7f             	and    $0x7f,%eax
  8041602131:	d3 e0                	shl    %cl,%eax
  8041602133:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602136:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602139:	40 84 f6             	test   %sil,%sil
  804160213c:	78 e4                	js     8041602122 <file_name_by_info+0x3ab>
  return count;
  804160213e:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  8041602141:	45 85 c0             	test   %r8d,%r8d
  8041602144:	0f 84 40 fd ff ff    	je     8041601e8a <file_name_by_info+0x113>
  entry += count;
  804160214a:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  804160214d:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041602151:	4c 03 20             	add    (%rax),%r12
  8041602154:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041602157:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160215c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602161:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602167:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160216a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160216e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602171:	89 f0                	mov    %esi,%eax
  8041602173:	83 e0 7f             	and    $0x7f,%eax
  8041602176:	d3 e0                	shl    %cl,%eax
  8041602178:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160217b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160217e:	40 84 f6             	test   %sil,%sil
  8041602181:	78 e4                	js     8041602167 <file_name_by_info+0x3f0>
  return count;
  8041602183:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  8041602186:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  8041602189:	45 39 c8             	cmp    %r9d,%r8d
  804160218c:	0f 85 2d fd ff ff    	jne    8041601ebf <file_name_by_info+0x148>
  8041602192:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041602195:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160219a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160219f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416021a5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416021a8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416021ac:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416021af:	89 f0                	mov    %esi,%eax
  80416021b1:	83 e0 7f             	and    $0x7f,%eax
  80416021b4:	d3 e0                	shl    %cl,%eax
  80416021b6:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416021b9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416021bc:	40 84 f6             	test   %sil,%sil
  80416021bf:	78 e4                	js     80416021a5 <file_name_by_info+0x42e>
  return count;
  80416021c1:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  80416021c4:	41 83 f8 11          	cmp    $0x11,%r8d
  80416021c8:	0f 85 26 fd ff ff    	jne    8041601ef4 <file_name_by_info+0x17d>
  abbrev_entry++;
  80416021ce:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  80416021d3:	49 bf 42 0d 60 41 80 	movabs $0x8041600d42,%r15
  80416021da:	00 00 00 
  80416021dd:	e9 70 fd ff ff       	jmpq   8041601f52 <file_name_by_info+0x1db>

00000080416021e2 <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  80416021e2:	55                   	push   %rbp
  80416021e3:	48 89 e5             	mov    %rsp,%rbp
  80416021e6:	41 57                	push   %r15
  80416021e8:	41 56                	push   %r14
  80416021ea:	41 55                	push   %r13
  80416021ec:	41 54                	push   %r12
  80416021ee:	53                   	push   %rbx
  80416021ef:	48 83 ec 68          	sub    $0x68,%rsp
  80416021f3:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  80416021f7:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  80416021fe:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  8041602202:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  8041602206:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  804160220d:	48 89 d3             	mov    %rdx,%rbx
  8041602210:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602214:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602219:	48 89 de             	mov    %rbx,%rsi
  804160221c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602220:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041602227:	00 00 00 
  804160222a:	ff d0                	callq  *%rax
  804160222c:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160222f:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602232:	76 59                	jbe    804160228d <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  8041602234:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602237:	74 2f                	je     8041602268 <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602239:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  8041602240:	00 00 00 
  8041602243:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602248:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  804160224f:	00 00 00 
  8041602252:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041602254:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602259:	48 83 c4 68          	add    $0x68,%rsp
  804160225d:	5b                   	pop    %rbx
  804160225e:	41 5c                	pop    %r12
  8041602260:	41 5d                	pop    %r13
  8041602262:	41 5e                	pop    %r14
  8041602264:	41 5f                	pop    %r15
  8041602266:	5d                   	pop    %rbp
  8041602267:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602268:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  804160226c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602271:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602275:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  804160227c:	00 00 00 
  804160227f:	ff d0                	callq  *%rax
  8041602281:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602285:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  804160228b:	eb 08                	jmp    8041602295 <function_by_info+0xb3>
    *len = initial_len;
  804160228d:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160228f:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  8041602295:	4d 63 f6             	movslq %r14d,%r14
  8041602298:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  804160229b:	48 01 d8             	add    %rbx,%rax
  804160229e:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416022a2:	ba 02 00 00 00       	mov    $0x2,%edx
  80416022a7:	48 89 de             	mov    %rbx,%rsi
  80416022aa:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022ae:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416022b5:	00 00 00 
  80416022b8:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416022ba:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416022be:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416022c2:	83 e8 02             	sub    $0x2,%eax
  80416022c5:	66 a9 fd ff          	test   $0xfffd,%ax
  80416022c9:	75 51                	jne    804160231c <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416022cb:	ba 04 00 00 00       	mov    $0x4,%edx
  80416022d0:	48 89 de             	mov    %rbx,%rsi
  80416022d3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022d7:	49 bc 61 7c 60 41 80 	movabs $0x8041607c61,%r12
  80416022de:	00 00 00 
  80416022e1:	41 ff d4             	callq  *%r12
  80416022e4:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  80416022e8:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416022ec:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416022f0:	ba 01 00 00 00       	mov    $0x1,%edx
  80416022f5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022f9:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  80416022fc:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602300:	75 4f                	jne    8041602351 <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602302:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602306:	4c 03 28             	add    (%rax),%r13
  8041602309:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  804160230d:	49 bf 42 0d 60 41 80 	movabs $0x8041600d42,%r15
  8041602314:	00 00 00 
  while (entry < entry_end) {
  8041602317:	e9 07 02 00 00       	jmpq   8041602523 <function_by_info+0x341>
  assert(version == 4 || version == 2);
  804160231c:	48 b9 2e 87 60 41 80 	movabs $0x804160872e,%rcx
  8041602323:	00 00 00 
  8041602326:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160232d:	00 00 00 
  8041602330:	be e9 01 00 00       	mov    $0x1e9,%esi
  8041602335:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  804160233c:	00 00 00 
  804160233f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602344:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160234b:	00 00 00 
  804160234e:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  8041602351:	48 b9 fb 86 60 41 80 	movabs $0x80416086fb,%rcx
  8041602358:	00 00 00 
  804160235b:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041602362:	00 00 00 
  8041602365:	be ed 01 00 00       	mov    $0x1ed,%esi
  804160236a:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041602371:	00 00 00 
  8041602374:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602379:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041602380:	00 00 00 
  8041602383:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  8041602386:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160238a:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  804160238e:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  8041602392:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  8041602398:	49 39 da             	cmp    %rbx,%r10
  804160239b:	0f 86 e7 00 00 00    	jbe    8041602488 <function_by_info+0x2a6>
  80416023a1:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023a4:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416023aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023af:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416023b4:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023b7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023bb:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416023bf:	89 f8                	mov    %edi,%eax
  80416023c1:	83 e0 7f             	and    $0x7f,%eax
  80416023c4:	d3 e0                	shl    %cl,%eax
  80416023c6:	09 c6                	or     %eax,%esi
    shift += 7;
  80416023c8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023cb:	40 84 ff             	test   %dil,%dil
  80416023ce:	78 e4                	js     80416023b4 <function_by_info+0x1d2>
  return count;
  80416023d0:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  80416023d3:	4c 01 c3             	add    %r8,%rbx
  80416023d6:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023d9:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  80416023df:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023e4:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416023ea:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023ed:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023f1:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  80416023f5:	89 f8                	mov    %edi,%eax
  80416023f7:	83 e0 7f             	and    $0x7f,%eax
  80416023fa:	d3 e0                	shl    %cl,%eax
  80416023fc:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416023ff:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602402:	40 84 ff             	test   %dil,%dil
  8041602405:	78 e3                	js     80416023ea <function_by_info+0x208>
  return count;
  8041602407:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  804160240a:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  804160240f:	41 39 f1             	cmp    %esi,%r9d
  8041602412:	74 74                	je     8041602488 <function_by_info+0x2a6>
  result = 0;
  8041602414:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602417:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160241c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602421:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602427:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160242a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160242e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602431:	89 f0                	mov    %esi,%eax
  8041602433:	83 e0 7f             	and    $0x7f,%eax
  8041602436:	d3 e0                	shl    %cl,%eax
  8041602438:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  804160243b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160243e:	40 84 f6             	test   %sil,%sil
  8041602441:	78 e4                	js     8041602427 <function_by_info+0x245>
  return count;
  8041602443:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602446:	48 01 fb             	add    %rdi,%rbx
  8041602449:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160244c:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602451:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602456:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  804160245c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160245f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602463:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602466:	89 f0                	mov    %esi,%eax
  8041602468:	83 e0 7f             	and    $0x7f,%eax
  804160246b:	d3 e0                	shl    %cl,%eax
  804160246d:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602470:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602473:	40 84 f6             	test   %sil,%sil
  8041602476:	78 e4                	js     804160245c <function_by_info+0x27a>
  return count;
  8041602478:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160247b:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  804160247e:	45 09 dc             	or     %r11d,%r12d
  8041602481:	75 91                	jne    8041602414 <function_by_info+0x232>
  8041602483:	e9 10 ff ff ff       	jmpq   8041602398 <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  8041602488:	41 83 f8 2e          	cmp    $0x2e,%r8d
  804160248c:	0f 84 e9 00 00 00    	je     804160257b <function_by_info+0x399>
            fn_name_entry = entry;
  8041602492:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602495:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160249a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160249f:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416024a5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024a8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024ac:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024af:	89 f0                	mov    %esi,%eax
  80416024b1:	83 e0 7f             	and    $0x7f,%eax
  80416024b4:	d3 e0                	shl    %cl,%eax
  80416024b6:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416024b9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024bc:	40 84 f6             	test   %sil,%sil
  80416024bf:	78 e4                	js     80416024a5 <function_by_info+0x2c3>
  return count;
  80416024c1:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024c4:	48 01 fb             	add    %rdi,%rbx
  80416024c7:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024ca:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024d4:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024da:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024dd:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024e1:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024e4:	89 f0                	mov    %esi,%eax
  80416024e6:	83 e0 7f             	and    $0x7f,%eax
  80416024e9:	d3 e0                	shl    %cl,%eax
  80416024eb:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024ee:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024f1:	40 84 f6             	test   %sil,%sil
  80416024f4:	78 e4                	js     80416024da <function_by_info+0x2f8>
  return count;
  80416024f6:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024f9:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  80416024fc:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602502:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602507:	ba 00 00 00 00       	mov    $0x0,%edx
  804160250c:	44 89 e6             	mov    %r12d,%esi
  804160250f:	4c 89 f7             	mov    %r14,%rdi
  8041602512:	41 ff d7             	callq  *%r15
        entry += count;
  8041602515:	48 98                	cltq   
  8041602517:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160251a:	45 09 ec             	or     %r13d,%r12d
  804160251d:	0f 85 6f ff ff ff    	jne    8041602492 <function_by_info+0x2b0>
  while (entry < entry_end) {
  8041602523:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  8041602527:	0f 83 37 02 00 00    	jae    8041602764 <function_by_info+0x582>
                 uintptr_t *offset) {
  804160252d:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602530:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602535:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160253a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602540:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602543:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602547:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160254a:	89 f0                	mov    %esi,%eax
  804160254c:	83 e0 7f             	and    $0x7f,%eax
  804160254f:	d3 e0                	shl    %cl,%eax
  8041602551:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602554:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602557:	40 84 f6             	test   %sil,%sil
  804160255a:	78 e4                	js     8041602540 <function_by_info+0x35e>
  return count;
  804160255c:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  804160255f:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  8041602562:	45 85 c9             	test   %r9d,%r9d
  8041602565:	0f 85 1b fe ff ff    	jne    8041602386 <function_by_info+0x1a4>
  while (entry < entry_end) {
  804160256b:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  804160256f:	77 bc                	ja     804160252d <function_by_info+0x34b>
  return 0;
  8041602571:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602576:	e9 de fc ff ff       	jmpq   8041602259 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  804160257b:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  8041602582:	00 
  8041602583:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  804160258a:	00 
      unsigned name_form        = 0;
  804160258b:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  8041602592:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  8041602599:	00 
  804160259a:	eb 1d                	jmp    80416025b9 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  804160259c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416025a2:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416025a7:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416025ab:	44 89 ee             	mov    %r13d,%esi
  80416025ae:	4c 89 f7             	mov    %r14,%rdi
  80416025b1:	41 ff d7             	callq  *%r15
        entry += count;
  80416025b4:	48 98                	cltq   
  80416025b6:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  80416025b9:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025bc:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025c6:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416025cc:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025cf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025d3:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025d6:	89 f0                	mov    %esi,%eax
  80416025d8:	83 e0 7f             	and    $0x7f,%eax
  80416025db:	d3 e0                	shl    %cl,%eax
  80416025dd:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416025e0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025e3:	40 84 f6             	test   %sil,%sil
  80416025e6:	78 e4                	js     80416025cc <function_by_info+0x3ea>
  return count;
  80416025e8:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025eb:	48 01 fb             	add    %rdi,%rbx
  80416025ee:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025f1:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025fb:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602601:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602604:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602608:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160260b:	89 f0                	mov    %esi,%eax
  804160260d:	83 e0 7f             	and    $0x7f,%eax
  8041602610:	d3 e0                	shl    %cl,%eax
  8041602612:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602615:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602618:	40 84 f6             	test   %sil,%sil
  804160261b:	78 e4                	js     8041602601 <function_by_info+0x41f>
  return count;
  804160261d:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602620:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  8041602623:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602627:	0f 84 6f ff ff ff    	je     804160259c <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  804160262d:	41 83 fc 12          	cmp    $0x12,%r12d
  8041602631:	0f 84 99 00 00 00    	je     80416026d0 <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  8041602637:	41 83 fc 03          	cmp    $0x3,%r12d
  804160263b:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  804160263e:	41 0f 44 c5          	cmove  %r13d,%eax
  8041602642:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  8041602645:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602649:	49 0f 44 c6          	cmove  %r14,%rax
  804160264d:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  8041602651:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602657:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160265c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602661:	44 89 ee             	mov    %r13d,%esi
  8041602664:	4c 89 f7             	mov    %r14,%rdi
  8041602667:	41 ff d7             	callq  *%r15
        entry += count;
  804160266a:	48 98                	cltq   
  804160266c:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160266f:	45 09 e5             	or     %r12d,%r13d
  8041602672:	0f 85 41 ff ff ff    	jne    80416025b9 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  8041602678:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160267c:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  8041602683:	48 39 d8             	cmp    %rbx,%rax
  8041602686:	0f 87 97 fe ff ff    	ja     8041602523 <function_by_info+0x341>
  804160268c:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  8041602690:	0f 82 8d fe ff ff    	jb     8041602523 <function_by_info+0x341>
        *offset = low_pc;
  8041602696:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  804160269d:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  80416026a0:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  80416026a4:	74 59                	je     80416026ff <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  80416026a6:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026ac:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  80416026af:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  80416026b3:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  80416026b6:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  80416026ba:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  80416026c1:	00 00 00 
  80416026c4:	ff d0                	callq  *%rax
        return 0;
  80416026c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026cb:	e9 89 fb ff ff       	jmpq   8041602259 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  80416026d0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026d6:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416026db:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416026df:	44 89 ee             	mov    %r13d,%esi
  80416026e2:	4c 89 f7             	mov    %r14,%rdi
  80416026e5:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  80416026e8:	41 83 fd 01          	cmp    $0x1,%r13d
  80416026ec:	0f 84 c2 fe ff ff    	je     80416025b4 <function_by_info+0x3d2>
            high_pc += low_pc;
  80416026f2:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80416026f6:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  80416026fa:	e9 b5 fe ff ff       	jmpq   80416025b4 <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  80416026ff:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602706:	00 
          count                    = dwarf_read_abbrev_entry(
  8041602707:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160270d:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602712:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602716:	be 0e 00 00 00       	mov    $0xe,%esi
  804160271b:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  804160271f:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  8041602726:	00 00 00 
  8041602729:	ff d0                	callq  *%rax
          if (buf &&
  804160272b:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  804160272f:	48 85 ff             	test   %rdi,%rdi
  8041602732:	74 92                	je     80416026c6 <function_by_info+0x4e4>
  8041602734:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  8041602738:	76 8c                	jbe    80416026c6 <function_by_info+0x4e4>
            put_unaligned(
  804160273a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160273e:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602742:	48 03 43 40          	add    0x40(%rbx),%rax
  8041602746:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  804160274a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160274f:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602753:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  804160275a:	00 00 00 
  804160275d:	ff d0                	callq  *%rax
  804160275f:	e9 62 ff ff ff       	jmpq   80416026c6 <function_by_info+0x4e4>
  return 0;
  8041602764:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602769:	e9 eb fa ff ff       	jmpq   8041602259 <function_by_info+0x77>

000000804160276e <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  804160276e:	55                   	push   %rbp
  804160276f:	48 89 e5             	mov    %rsp,%rbp
  8041602772:	41 57                	push   %r15
  8041602774:	41 56                	push   %r14
  8041602776:	41 55                	push   %r13
  8041602778:	41 54                	push   %r12
  804160277a:	53                   	push   %rbx
  804160277b:	48 83 ec 48          	sub    $0x48,%rsp
  804160277f:	49 89 ff             	mov    %rdi,%r15
  8041602782:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  8041602786:	48 89 f7             	mov    %rsi,%rdi
  8041602789:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  804160278d:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const int flen = strlen(fname);
  8041602791:	48 b8 e8 79 60 41 80 	movabs $0x80416079e8,%rax
  8041602798:	00 00 00 
  804160279b:	ff d0                	callq  *%rax
  804160279d:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  804160279f:	85 c0                	test   %eax,%eax
  80416027a1:	74 62                	je     8041602805 <address_by_fname+0x97>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  80416027a3:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416027a7:	49 be 61 7c 60 41 80 	movabs $0x8041607c61,%r14
  80416027ae:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  80416027b1:	49 bf f7 7a 60 41 80 	movabs $0x8041607af7,%r15
  80416027b8:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  80416027bb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416027bf:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  80416027c3:	0f 86 0b 04 00 00    	jbe    8041602bd4 <address_by_fname+0x466>
  80416027c9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027ce:	4c 89 e6             	mov    %r12,%rsi
  80416027d1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027d5:	41 ff d6             	callq  *%r14
  80416027d8:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416027db:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416027de:	76 52                	jbe    8041602832 <address_by_fname+0xc4>
    if (initial_len == DW_EXT_DWARF64) {
  80416027e0:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416027e3:	74 31                	je     8041602816 <address_by_fname+0xa8>
      cprintf("Unknown DWARF extension\n");
  80416027e5:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  80416027ec:	00 00 00 
  80416027ef:	b8 00 00 00 00       	mov    $0x0,%eax
  80416027f4:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416027fb:	00 00 00 
  80416027fe:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602800:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  8041602805:	89 d8                	mov    %ebx,%eax
  8041602807:	48 83 c4 48          	add    $0x48,%rsp
  804160280b:	5b                   	pop    %rbx
  804160280c:	41 5c                	pop    %r12
  804160280e:	41 5d                	pop    %r13
  8041602810:	41 5e                	pop    %r14
  8041602812:	41 5f                	pop    %r15
  8041602814:	5d                   	pop    %rbp
  8041602815:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602816:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  804160281b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602820:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602824:	41 ff d6             	callq  *%r14
  8041602827:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160282b:	ba 0c 00 00 00       	mov    $0xc,%edx
  8041602830:	eb 07                	jmp    8041602839 <address_by_fname+0xcb>
    *len = initial_len;
  8041602832:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602834:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  8041602839:	48 63 d2             	movslq %edx,%rdx
  804160283c:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  804160283f:	4c 01 e0             	add    %r12,%rax
  8041602842:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  8041602846:	ba 02 00 00 00       	mov    $0x2,%edx
  804160284b:	4c 89 e6             	mov    %r12,%rsi
  804160284e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602852:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  8041602855:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  804160285a:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160285f:	0f 85 be 00 00 00    	jne    8041602923 <address_by_fname+0x1b5>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602865:	ba 04 00 00 00       	mov    $0x4,%edx
  804160286a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160286e:	41 ff d6             	callq  *%r14
  8041602871:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041602874:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  8041602877:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160287c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602881:	48 89 de             	mov    %rbx,%rsi
  8041602884:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602888:	41 ff d6             	callq  *%r14
  804160288b:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  804160288e:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602893:	83 fa ef             	cmp    $0xffffffef,%edx
  8041602896:	76 29                	jbe    80416028c1 <address_by_fname+0x153>
    if (initial_len == DW_EXT_DWARF64) {
  8041602898:	83 fa ff             	cmp    $0xffffffff,%edx
  804160289b:	0f 84 b7 00 00 00    	je     8041602958 <address_by_fname+0x1ea>
      cprintf("Unknown DWARF extension\n");
  80416028a1:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  80416028a8:	00 00 00 
  80416028ab:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028b0:	48 b9 6a 5a 60 41 80 	movabs $0x8041605a6a,%rcx
  80416028b7:	00 00 00 
  80416028ba:	ff d1                	callq  *%rcx
      count = 0;
  80416028bc:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  80416028c1:	48 98                	cltq   
  80416028c3:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416028c7:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416028cb:	0f 86 ea fe ff ff    	jbe    80416027bb <address_by_fname+0x4d>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028d1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028d6:	4c 89 e6             	mov    %r12,%rsi
  80416028d9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028dd:	41 ff d6             	callq  *%r14
  80416028e0:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416028e4:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416028e8:	4d 85 ed             	test   %r13,%r13
  80416028eb:	0f 84 ca fe ff ff    	je     80416027bb <address_by_fname+0x4d>
      if (!strcmp(fname, pubnames_entry)) {
  80416028f1:	4c 89 e6             	mov    %r12,%rsi
  80416028f4:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416028f8:	41 ff d7             	callq  *%r15
  80416028fb:	89 c3                	mov    %eax,%ebx
  80416028fd:	85 c0                	test   %eax,%eax
  80416028ff:	74 72                	je     8041602973 <address_by_fname+0x205>
      pubnames_entry += strlen(pubnames_entry) + 1;
  8041602901:	4c 89 e7             	mov    %r12,%rdi
  8041602904:	48 b8 e8 79 60 41 80 	movabs $0x80416079e8,%rax
  804160290b:	00 00 00 
  804160290e:	ff d0                	callq  *%rax
  8041602910:	83 c0 01             	add    $0x1,%eax
  8041602913:	48 98                	cltq   
  8041602915:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602918:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  804160291c:	77 b3                	ja     80416028d1 <address_by_fname+0x163>
  804160291e:	e9 98 fe ff ff       	jmpq   80416027bb <address_by_fname+0x4d>
    assert(version == 2);
  8041602923:	48 b9 3e 87 60 41 80 	movabs $0x804160873e,%rcx
  804160292a:	00 00 00 
  804160292d:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041602934:	00 00 00 
  8041602937:	be 76 02 00 00       	mov    $0x276,%esi
  804160293c:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041602943:	00 00 00 
  8041602946:	b8 00 00 00 00       	mov    $0x0,%eax
  804160294b:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041602952:	00 00 00 
  8041602955:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602958:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  804160295d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602962:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602966:	41 ff d6             	callq  *%r14
      count = 12;
  8041602969:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160296e:	e9 4e ff ff ff       	jmpq   80416028c1 <address_by_fname+0x153>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602973:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  8041602977:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160297b:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  804160297f:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  8041602983:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602988:	4c 89 e6             	mov    %r12,%rsi
  804160298b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160298f:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041602996:	00 00 00 
  8041602999:	ff d0                	callq  *%rax
  804160299b:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160299e:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416029a1:	0f 86 37 02 00 00    	jbe    8041602bde <address_by_fname+0x470>
    if (initial_len == DW_EXT_DWARF64) {
  80416029a7:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416029aa:	74 25                	je     80416029d1 <address_by_fname+0x263>
      cprintf("Unknown DWARF extension\n");
  80416029ac:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  80416029b3:	00 00 00 
  80416029b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029bb:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416029c2:	00 00 00 
  80416029c5:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416029c7:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416029cc:	e9 34 fe ff ff       	jmpq   8041602805 <address_by_fname+0x97>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029d1:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416029d6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029db:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029df:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416029e6:	00 00 00 
  80416029e9:	ff d0                	callq  *%rax
      count = 12;
  80416029eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416029f0:	e9 ee 01 00 00       	jmpq   8041602be3 <address_by_fname+0x475>
        assert(version == 4 || version == 2);
  80416029f5:	48 b9 2e 87 60 41 80 	movabs $0x804160872e,%rcx
  80416029fc:	00 00 00 
  80416029ff:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041602a06:	00 00 00 
  8041602a09:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041602a0e:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041602a15:	00 00 00 
  8041602a18:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a1d:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041602a24:	00 00 00 
  8041602a27:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a2a:	48 b9 fb 86 60 41 80 	movabs $0x80416086fb,%rcx
  8041602a31:	00 00 00 
  8041602a34:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041602a3b:	00 00 00 
  8041602a3e:	be 91 02 00 00       	mov    $0x291,%esi
  8041602a43:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041602a4a:	00 00 00 
  8041602a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a52:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041602a59:	00 00 00 
  8041602a5c:	41 ff d0             	callq  *%r8
        if (tag == DW_TAG_subprogram) {
  8041602a5f:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602a63:	0f 84 93 00 00 00    	je     8041602afc <address_by_fname+0x38e>
  count  = 0;
  8041602a69:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a6b:	89 d9                	mov    %ebx,%ecx
  8041602a6d:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a70:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602a76:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602a79:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a7d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602a80:	89 f0                	mov    %esi,%eax
  8041602a82:	83 e0 7f             	and    $0x7f,%eax
  8041602a85:	d3 e0                	shl    %cl,%eax
  8041602a87:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602a8a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a8d:	40 84 f6             	test   %sil,%sil
  8041602a90:	78 e4                	js     8041602a76 <address_by_fname+0x308>
  return count;
  8041602a92:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602a95:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602a98:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a9a:	89 d9                	mov    %ebx,%ecx
  8041602a9c:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a9f:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602aa5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602aa8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602aac:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602aaf:	89 f0                	mov    %esi,%eax
  8041602ab1:	83 e0 7f             	and    $0x7f,%eax
  8041602ab4:	d3 e0                	shl    %cl,%eax
  8041602ab6:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602ab9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602abc:	40 84 f6             	test   %sil,%sil
  8041602abf:	78 e4                	js     8041602aa5 <address_by_fname+0x337>
  return count;
  8041602ac1:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602ac4:	49 01 fc             	add    %rdi,%r12
            count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602ac7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602acd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602ad7:	44 89 ee             	mov    %r13d,%esi
  8041602ada:	4c 89 ff             	mov    %r15,%rdi
  8041602add:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  8041602ae4:	00 00 00 
  8041602ae7:	ff d0                	callq  *%rax
            entry += count;
  8041602ae9:	48 98                	cltq   
  8041602aeb:	49 01 c7             	add    %rax,%r15
          } while (name != 0 || form != 0);
  8041602aee:	45 09 f5             	or     %r14d,%r13d
  8041602af1:	0f 85 72 ff ff ff    	jne    8041602a69 <address_by_fname+0x2fb>
  8041602af7:	e9 09 fd ff ff       	jmpq   8041602805 <address_by_fname+0x97>
          uintptr_t low_pc = 0;
  8041602afc:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602b03:	00 
  8041602b04:	eb 26                	jmp    8041602b2c <address_by_fname+0x3be>
              count = dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  8041602b06:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b0c:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602b11:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602b15:	44 89 f6             	mov    %r14d,%esi
  8041602b18:	4c 89 ff             	mov    %r15,%rdi
  8041602b1b:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  8041602b22:	00 00 00 
  8041602b25:	ff d0                	callq  *%rax
            entry += count;
  8041602b27:	48 98                	cltq   
  8041602b29:	49 01 c7             	add    %rax,%r15
  count  = 0;
  8041602b2c:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b2e:	89 d9                	mov    %ebx,%ecx
  8041602b30:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b33:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602b39:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b3c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b40:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b43:	89 f0                	mov    %esi,%eax
  8041602b45:	83 e0 7f             	and    $0x7f,%eax
  8041602b48:	d3 e0                	shl    %cl,%eax
  8041602b4a:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602b4d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b50:	40 84 f6             	test   %sil,%sil
  8041602b53:	78 e4                	js     8041602b39 <address_by_fname+0x3cb>
  return count;
  8041602b55:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b58:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602b5b:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b5d:	89 d9                	mov    %ebx,%ecx
  8041602b5f:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b62:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602b68:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b6b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b6f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b72:	89 f0                	mov    %esi,%eax
  8041602b74:	83 e0 7f             	and    $0x7f,%eax
  8041602b77:	d3 e0                	shl    %cl,%eax
  8041602b79:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602b7c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b7f:	40 84 f6             	test   %sil,%sil
  8041602b82:	78 e4                	js     8041602b68 <address_by_fname+0x3fa>
  return count;
  8041602b84:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b87:	49 01 fc             	add    %rdi,%r12
            if (name == DW_AT_low_pc) {
  8041602b8a:	41 83 fd 11          	cmp    $0x11,%r13d
  8041602b8e:	0f 84 72 ff ff ff    	je     8041602b06 <address_by_fname+0x398>
              count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602b94:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602ba4:	44 89 f6             	mov    %r14d,%esi
  8041602ba7:	4c 89 ff             	mov    %r15,%rdi
  8041602baa:	48 b8 42 0d 60 41 80 	movabs $0x8041600d42,%rax
  8041602bb1:	00 00 00 
  8041602bb4:	ff d0                	callq  *%rax
            entry += count;
  8041602bb6:	48 98                	cltq   
  8041602bb8:	49 01 c7             	add    %rax,%r15
          } while (name || form);
  8041602bbb:	45 09 ee             	or     %r13d,%r14d
  8041602bbe:	0f 85 68 ff ff ff    	jne    8041602b2c <address_by_fname+0x3be>
          *offset = low_pc;
  8041602bc4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041602bc8:	48 8b 7d 98          	mov    -0x68(%rbp),%rdi
  8041602bcc:	48 89 07             	mov    %rax,(%rdi)
  8041602bcf:	e9 31 fc ff ff       	jmpq   8041602805 <address_by_fname+0x97>
  return 0;
  8041602bd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602bd9:	e9 27 fc ff ff       	jmpq   8041602805 <address_by_fname+0x97>
  count       = 4;
  8041602bde:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  8041602be3:	48 98                	cltq   
  8041602be5:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602be9:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602bee:	4c 89 ee             	mov    %r13,%rsi
  8041602bf1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bf5:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041602bfc:	00 00 00 
  8041602bff:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602c01:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  8041602c05:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602c09:	83 e8 02             	sub    $0x2,%eax
  8041602c0c:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602c10:	0f 85 df fd ff ff    	jne    80416029f5 <address_by_fname+0x287>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602c16:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602c1b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c1f:	49 be 61 7c 60 41 80 	movabs $0x8041607c61,%r14
  8041602c26:	00 00 00 
  8041602c29:	41 ff d6             	callq  *%r14
  8041602c2c:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602c30:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c34:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  8041602c37:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602c3b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602c40:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c44:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  8041602c47:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602c4b:	0f 85 d9 fd ff ff    	jne    8041602a2a <address_by_fname+0x2bc>
  count  = 0;
  8041602c51:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602c53:	89 d9                	mov    %ebx,%ecx
  8041602c55:	4c 89 fa             	mov    %r15,%rdx
  result = 0;
  8041602c58:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602c5e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602c61:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c65:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602c68:	89 f0                	mov    %esi,%eax
  8041602c6a:	83 e0 7f             	and    $0x7f,%eax
  8041602c6d:	d3 e0                	shl    %cl,%eax
  8041602c6f:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602c72:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c75:	40 84 f6             	test   %sil,%sil
  8041602c78:	78 e4                	js     8041602c5e <address_by_fname+0x4f0>
  return count;
  8041602c7a:	48 63 ff             	movslq %edi,%rdi
        entry += count;
  8041602c7d:	49 01 ff             	add    %rdi,%r15
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c80:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c84:	4c 8b 58 08          	mov    0x8(%rax),%r11
        unsigned name = 0, form = 0, tag = 0;
  8041602c88:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c8e:	4d 39 e3             	cmp    %r12,%r11
  8041602c91:	0f 86 c8 fd ff ff    	jbe    8041602a5f <address_by_fname+0x2f1>
  count  = 0;
  8041602c97:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602c9a:	89 d9                	mov    %ebx,%ecx
  8041602c9c:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602c9f:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602ca4:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602ca7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cab:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602caf:	89 f8                	mov    %edi,%eax
  8041602cb1:	83 e0 7f             	and    $0x7f,%eax
  8041602cb4:	d3 e0                	shl    %cl,%eax
  8041602cb6:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602cb8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cbb:	40 84 ff             	test   %dil,%dil
  8041602cbe:	78 e4                	js     8041602ca4 <address_by_fname+0x536>
  return count;
  8041602cc0:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry += count;
  8041602cc3:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602cc6:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602cc9:	89 d9                	mov    %ebx,%ecx
  8041602ccb:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602cce:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602cd4:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602cd7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cdb:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cdf:	89 f8                	mov    %edi,%eax
  8041602ce1:	83 e0 7f             	and    $0x7f,%eax
  8041602ce4:	d3 e0                	shl    %cl,%eax
  8041602ce6:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602ce9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cec:	40 84 ff             	test   %dil,%dil
  8041602cef:	78 e3                	js     8041602cd4 <address_by_fname+0x566>
  return count;
  8041602cf1:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry++;
  8041602cf4:	4f 8d 64 04 01       	lea    0x1(%r12,%r8,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602cf9:	41 39 f2             	cmp    %esi,%r10d
  8041602cfc:	0f 84 5d fd ff ff    	je     8041602a5f <address_by_fname+0x2f1>
  count  = 0;
  8041602d02:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602d05:	89 d9                	mov    %ebx,%ecx
  8041602d07:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d0a:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602d0f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d12:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d16:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602d1a:	89 f0                	mov    %esi,%eax
  8041602d1c:	83 e0 7f             	and    $0x7f,%eax
  8041602d1f:	d3 e0                	shl    %cl,%eax
  8041602d21:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602d23:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d26:	40 84 f6             	test   %sil,%sil
  8041602d29:	78 e4                	js     8041602d0f <address_by_fname+0x5a1>
  return count;
  8041602d2b:	4d 63 c0             	movslq %r8d,%r8
            abbrev_entry += count;
  8041602d2e:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602d31:	41 89 dd             	mov    %ebx,%r13d
  shift  = 0;
  8041602d34:	89 d9                	mov    %ebx,%ecx
  8041602d36:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d39:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d3f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d42:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d46:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041602d4a:	89 f0                	mov    %esi,%eax
  8041602d4c:	83 e0 7f             	and    $0x7f,%eax
  8041602d4f:	d3 e0                	shl    %cl,%eax
  8041602d51:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602d54:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d57:	40 84 f6             	test   %sil,%sil
  8041602d5a:	78 e3                	js     8041602d3f <address_by_fname+0x5d1>
  return count;
  8041602d5c:	4d 63 ed             	movslq %r13d,%r13
            abbrev_entry += count;
  8041602d5f:	4d 01 ec             	add    %r13,%r12
          } while (name != 0 || form != 0);
  8041602d62:	41 09 f8             	or     %edi,%r8d
  8041602d65:	75 9b                	jne    8041602d02 <address_by_fname+0x594>
  8041602d67:	e9 22 ff ff ff       	jmpq   8041602c8e <address_by_fname+0x520>

0000008041602d6c <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602d6c:	55                   	push   %rbp
  8041602d6d:	48 89 e5             	mov    %rsp,%rbp
  8041602d70:	41 57                	push   %r15
  8041602d72:	41 56                	push   %r14
  8041602d74:	41 55                	push   %r13
  8041602d76:	41 54                	push   %r12
  8041602d78:	53                   	push   %rbx
  8041602d79:	48 83 ec 48          	sub    $0x48,%rsp
  8041602d7d:	48 89 fb             	mov    %rdi,%rbx
  8041602d80:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602d84:	48 89 f7             	mov    %rsi,%rdi
  8041602d87:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602d8b:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602d8f:	48 b8 e8 79 60 41 80 	movabs $0x80416079e8,%rax
  8041602d96:	00 00 00 
  8041602d99:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602d9b:	85 c0                	test   %eax,%eax
  8041602d9d:	0f 84 73 03 00 00    	je     8041603116 <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602da3:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602da7:	e9 0f 03 00 00       	jmpq   80416030bb <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602dac:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602db0:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602db5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602db9:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041602dc0:	00 00 00 
  8041602dc3:	ff d0                	callq  *%rax
  8041602dc5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602dc9:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602dce:	eb 07                	jmp    8041602dd7 <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602dd0:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602dd2:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602dd7:	48 63 db             	movslq %ebx,%rbx
  8041602dda:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602dde:	4c 01 e8             	add    %r13,%rax
  8041602de1:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602de5:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602dea:	4c 89 ee             	mov    %r13,%rsi
  8041602ded:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602df1:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041602df8:	00 00 00 
  8041602dfb:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602dfd:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602e01:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602e05:	83 e8 02             	sub    $0x2,%eax
  8041602e08:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602e0c:	75 52                	jne    8041602e60 <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602e0e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602e13:	4c 89 ee             	mov    %r13,%rsi
  8041602e16:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e1a:	49 be 61 7c 60 41 80 	movabs $0x8041607c61,%r14
  8041602e21:	00 00 00 
  8041602e24:	41 ff d6             	callq  *%r14
  8041602e27:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602e2b:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602e30:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602e34:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602e39:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e3d:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602e40:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602e44:	75 4f                	jne    8041602e95 <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602e46:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e4a:	4c 03 20             	add    (%rax),%r12
  8041602e4d:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602e51:	49 be 42 0d 60 41 80 	movabs $0x8041600d42,%r14
  8041602e58:	00 00 00 
    while (entry < entry_end) {
  8041602e5b:	e9 11 02 00 00       	jmpq   8041603071 <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602e60:	48 b9 2e 87 60 41 80 	movabs $0x804160872e,%rcx
  8041602e67:	00 00 00 
  8041602e6a:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041602e71:	00 00 00 
  8041602e74:	be f0 02 00 00       	mov    $0x2f0,%esi
  8041602e79:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041602e80:	00 00 00 
  8041602e83:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e88:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041602e8f:	00 00 00 
  8041602e92:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602e95:	48 b9 fb 86 60 41 80 	movabs $0x80416086fb,%rcx
  8041602e9c:	00 00 00 
  8041602e9f:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041602ea6:	00 00 00 
  8041602ea9:	be f4 02 00 00       	mov    $0x2f4,%esi
  8041602eae:	48 bf ee 86 60 41 80 	movabs $0x80416086ee,%rdi
  8041602eb5:	00 00 00 
  8041602eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ebd:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041602ec4:	00 00 00 
  8041602ec7:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602eca:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602ece:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602ed2:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602ed6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602edc:	49 39 db             	cmp    %rbx,%r11
  8041602edf:	0f 86 e7 00 00 00    	jbe    8041602fcc <naive_address_by_fname+0x260>
  8041602ee5:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ee8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602eee:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602ef3:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602ef8:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602efb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602eff:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f03:	89 f8                	mov    %edi,%eax
  8041602f05:	83 e0 7f             	and    $0x7f,%eax
  8041602f08:	d3 e0                	shl    %cl,%eax
  8041602f0a:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602f0c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f0f:	40 84 ff             	test   %dil,%dil
  8041602f12:	78 e4                	js     8041602ef8 <naive_address_by_fname+0x18c>
  return count;
  8041602f14:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602f17:	4c 01 c3             	add    %r8,%rbx
  8041602f1a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f1d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602f23:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f28:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602f2e:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f31:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f35:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f39:	89 f8                	mov    %edi,%eax
  8041602f3b:	83 e0 7f             	and    $0x7f,%eax
  8041602f3e:	d3 e0                	shl    %cl,%eax
  8041602f40:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602f43:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f46:	40 84 ff             	test   %dil,%dil
  8041602f49:	78 e3                	js     8041602f2e <naive_address_by_fname+0x1c2>
  return count;
  8041602f4b:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602f4e:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602f53:	41 39 f2             	cmp    %esi,%r10d
  8041602f56:	74 74                	je     8041602fcc <naive_address_by_fname+0x260>
  result = 0;
  8041602f58:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f5b:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f60:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f65:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602f6b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f6e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f72:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f75:	89 f0                	mov    %esi,%eax
  8041602f77:	83 e0 7f             	and    $0x7f,%eax
  8041602f7a:	d3 e0                	shl    %cl,%eax
  8041602f7c:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602f7f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f82:	40 84 f6             	test   %sil,%sil
  8041602f85:	78 e4                	js     8041602f6b <naive_address_by_fname+0x1ff>
  return count;
  8041602f87:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f8a:	48 01 fb             	add    %rdi,%rbx
  8041602f8d:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f90:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f95:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f9a:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602fa0:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fa3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602fa7:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602faa:	89 f0                	mov    %esi,%eax
  8041602fac:	83 e0 7f             	and    $0x7f,%eax
  8041602faf:	d3 e0                	shl    %cl,%eax
  8041602fb1:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602fb4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602fb7:	40 84 f6             	test   %sil,%sil
  8041602fba:	78 e4                	js     8041602fa0 <naive_address_by_fname+0x234>
  return count;
  8041602fbc:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fbf:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  8041602fc2:	45 09 c4             	or     %r8d,%r12d
  8041602fc5:	75 91                	jne    8041602f58 <naive_address_by_fname+0x1ec>
  8041602fc7:	e9 10 ff ff ff       	jmpq   8041602edc <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602fcc:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602fd0:	0f 84 4f 01 00 00    	je     8041603125 <naive_address_by_fname+0x3b9>
  8041602fd6:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602fda:	0f 84 45 01 00 00    	je     8041603125 <naive_address_by_fname+0x3b9>
                found = 1;
  8041602fe0:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fe3:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fe8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fed:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602ff3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ff6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ffa:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602ffd:	89 f0                	mov    %esi,%eax
  8041602fff:	83 e0 7f             	and    $0x7f,%eax
  8041603002:	d3 e0                	shl    %cl,%eax
  8041603004:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041603007:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160300a:	40 84 f6             	test   %sil,%sil
  804160300d:	78 e4                	js     8041602ff3 <naive_address_by_fname+0x287>
  return count;
  804160300f:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  8041603012:	48 01 fb             	add    %rdi,%rbx
  8041603015:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603018:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160301d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603022:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603028:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160302b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160302f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603032:	89 f0                	mov    %esi,%eax
  8041603034:	83 e0 7f             	and    $0x7f,%eax
  8041603037:	d3 e0                	shl    %cl,%eax
  8041603039:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160303c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160303f:	40 84 f6             	test   %sil,%sil
  8041603042:	78 e4                	js     8041603028 <naive_address_by_fname+0x2bc>
  return count;
  8041603044:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  8041603047:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  804160304a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603050:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603055:	ba 00 00 00 00       	mov    $0x0,%edx
  804160305a:	44 89 e6             	mov    %r12d,%esi
  804160305d:	4c 89 ff             	mov    %r15,%rdi
  8041603060:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  8041603063:	48 98                	cltq   
  8041603065:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603068:	45 09 ec             	or     %r13d,%r12d
  804160306b:	0f 85 6f ff ff ff    	jne    8041602fe0 <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  8041603071:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  8041603075:	73 44                	jae    80416030bb <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  8041603077:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  804160307a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160307f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603084:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  804160308a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160308d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603091:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603094:	89 f0                	mov    %esi,%eax
  8041603096:	83 e0 7f             	and    $0x7f,%eax
  8041603099:	d3 e0                	shl    %cl,%eax
  804160309b:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  804160309e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416030a1:	40 84 f6             	test   %sil,%sil
  80416030a4:	78 e4                	js     804160308a <naive_address_by_fname+0x31e>
  return count;
  80416030a6:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  80416030a9:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  80416030ac:	45 85 d2             	test   %r10d,%r10d
  80416030af:	0f 85 15 fe ff ff    	jne    8041602eca <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  80416030b5:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  80416030b9:	77 bc                	ja     8041603077 <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  80416030bb:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416030bf:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  80416030c3:	0f 86 ee 01 00 00    	jbe    80416032b7 <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  80416030c9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030ce:	4c 89 fe             	mov    %r15,%rsi
  80416030d1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030d5:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416030dc:	00 00 00 
  80416030df:	ff d0                	callq  *%rax
  80416030e1:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416030e4:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416030e7:	0f 86 e3 fc ff ff    	jbe    8041602dd0 <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  80416030ed:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416030f0:	0f 84 b6 fc ff ff    	je     8041602dac <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  80416030f6:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  80416030fd:	00 00 00 
  8041603100:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603105:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  804160310c:	00 00 00 
  804160310f:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041603111:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  8041603116:	48 83 c4 48          	add    $0x48,%rsp
  804160311a:	5b                   	pop    %rbx
  804160311b:	41 5c                	pop    %r12
  804160311d:	41 5d                	pop    %r13
  804160311f:	41 5e                	pop    %r14
  8041603121:	41 5f                	pop    %r15
  8041603123:	5d                   	pop    %rbp
  8041603124:	c3                   	retq   
        uintptr_t low_pc = 0;
  8041603125:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160312c:	00 
        int found        = 0;
  804160312d:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041603134:	eb 21                	jmp    8041603157 <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  8041603136:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160313c:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603141:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041603145:	44 89 ee             	mov    %r13d,%esi
  8041603148:	4c 89 ff             	mov    %r15,%rdi
  804160314b:	41 ff d6             	callq  *%r14
  804160314e:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  8041603151:	49 63 c4             	movslq %r12d,%rax
  8041603154:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  8041603157:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160315a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160315f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603164:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  804160316a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160316d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603171:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603174:	89 f0                	mov    %esi,%eax
  8041603176:	83 e0 7f             	and    $0x7f,%eax
  8041603179:	d3 e0                	shl    %cl,%eax
  804160317b:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160317e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603181:	40 84 f6             	test   %sil,%sil
  8041603184:	78 e4                	js     804160316a <naive_address_by_fname+0x3fe>
  return count;
  8041603186:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041603189:	48 01 fb             	add    %rdi,%rbx
  804160318c:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160318f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603194:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603199:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160319f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416031a2:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416031a6:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416031a9:	89 f0                	mov    %esi,%eax
  80416031ab:	83 e0 7f             	and    $0x7f,%eax
  80416031ae:	d3 e0                	shl    %cl,%eax
  80416031b0:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416031b3:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416031b6:	40 84 f6             	test   %sil,%sil
  80416031b9:	78 e4                	js     804160319f <naive_address_by_fname+0x433>
  return count;
  80416031bb:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  80416031be:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  80416031c1:	41 83 fc 11          	cmp    $0x11,%r12d
  80416031c5:	0f 84 6b ff ff ff    	je     8041603136 <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  80416031cb:	41 83 fc 03          	cmp    $0x3,%r12d
  80416031cf:	0f 85 9c 00 00 00    	jne    8041603271 <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  80416031d5:	41 83 fd 0e          	cmp    $0xe,%r13d
  80416031d9:	74 42                	je     804160321d <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  80416031db:	4c 89 fe             	mov    %r15,%rsi
  80416031de:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416031e2:	48 b8 f7 7a 60 41 80 	movabs $0x8041607af7,%rax
  80416031e9:	00 00 00 
  80416031ec:	ff d0                	callq  *%rax
                found = 1;
  80416031ee:	85 c0                	test   %eax,%eax
  80416031f0:	b8 01 00 00 00       	mov    $0x1,%eax
  80416031f5:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  80416031f9:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  80416031fc:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603202:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603207:	ba 00 00 00 00       	mov    $0x0,%edx
  804160320c:	44 89 ee             	mov    %r13d,%esi
  804160320f:	4c 89 ff             	mov    %r15,%rdi
  8041603212:	41 ff d6             	callq  *%r14
  8041603215:	41 89 c4             	mov    %eax,%r12d
  8041603218:	e9 34 ff ff ff       	jmpq   8041603151 <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  804160321d:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041603224:	00 
              count          = dwarf_read_abbrev_entry(
  8041603225:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160322b:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603230:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041603234:	be 0e 00 00 00       	mov    $0xe,%esi
  8041603239:	4c 89 ff             	mov    %r15,%rdi
  804160323c:	41 ff d6             	callq  *%r14
  804160323f:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  8041603242:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041603246:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160324a:	48 03 70 40          	add    0x40(%rax),%rsi
  804160324e:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041603252:	48 b8 f7 7a 60 41 80 	movabs $0x8041607af7,%rax
  8041603259:	00 00 00 
  804160325c:	ff d0                	callq  *%rax
                found = 1;
  804160325e:	85 c0                	test   %eax,%eax
  8041603260:	b8 01 00 00 00       	mov    $0x1,%eax
  8041603265:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603269:	89 45 bc             	mov    %eax,-0x44(%rbp)
  804160326c:	e9 e0 fe ff ff       	jmpq   8041603151 <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  8041603271:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603277:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160327c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603281:	44 89 ee             	mov    %r13d,%esi
  8041603284:	4c 89 ff             	mov    %r15,%rdi
  8041603287:	41 ff d6             	callq  *%r14
          entry += count;
  804160328a:	48 98                	cltq   
  804160328c:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  804160328f:	45 09 e5             	or     %r12d,%r13d
  8041603292:	0f 85 bf fe ff ff    	jne    8041603157 <naive_address_by_fname+0x3eb>
        if (found) {
  8041603298:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  804160329c:	0f 84 cf fd ff ff    	je     8041603071 <naive_address_by_fname+0x305>
          *offset = low_pc;
  80416032a2:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416032a6:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  80416032aa:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  80416032ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032b2:	e9 5f fe ff ff       	jmpq   8041603116 <naive_address_by_fname+0x3aa>
  return 0;
  80416032b7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032bc:	e9 55 fe ff ff       	jmpq   8041603116 <naive_address_by_fname+0x3aa>

00000080416032c1 <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  80416032c1:	55                   	push   %rbp
  80416032c2:	48 89 e5             	mov    %rsp,%rbp
  80416032c5:	41 57                	push   %r15
  80416032c7:	41 56                	push   %r14
  80416032c9:	41 55                	push   %r13
  80416032cb:	41 54                	push   %r12
  80416032cd:	53                   	push   %rbx
  80416032ce:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  80416032d2:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  80416032d6:	48 8b 47 38          	mov    0x38(%rdi),%rax
  80416032da:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  80416032dd:	48 39 d0             	cmp    %rdx,%rax
  80416032e0:	0f 82 d9 06 00 00    	jb     80416039bf <line_for_address+0x6fe>
  80416032e6:	48 85 c9             	test   %rcx,%rcx
  80416032e9:	0f 84 d0 06 00 00    	je     80416039bf <line_for_address+0x6fe>
  80416032ef:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  80416032f3:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  80416032f7:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  80416032fa:	ba 04 00 00 00       	mov    $0x4,%edx
  80416032ff:	48 89 de             	mov    %rbx,%rsi
  8041603302:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603306:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  804160330d:	00 00 00 
  8041603310:	ff d0                	callq  *%rax
  8041603312:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603315:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041603318:	76 4e                	jbe    8041603368 <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  804160331a:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160331d:	74 25                	je     8041603344 <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  804160331f:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  8041603326:	00 00 00 
  8041603329:	b8 00 00 00 00       	mov    $0x0,%eax
  804160332e:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041603335:	00 00 00 
  8041603338:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  804160333a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  804160333f:	e9 6c 06 00 00       	jmpq   80416039b0 <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603344:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041603348:	ba 08 00 00 00       	mov    $0x8,%edx
  804160334d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603351:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041603358:	00 00 00 
  804160335b:	ff d0                	callq  *%rax
  804160335d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041603361:	be 0c 00 00 00       	mov    $0xc,%esi
  8041603366:	eb 07                	jmp    804160336f <line_for_address+0xae>
    *len = initial_len;
  8041603368:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160336a:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  804160336f:	48 63 f6             	movslq %esi,%rsi
  8041603372:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  8041603375:	48 01 d8             	add    %rbx,%rax
  8041603378:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  804160337c:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603381:	48 89 de             	mov    %rbx,%rsi
  8041603384:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603388:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  804160338f:	00 00 00 
  8041603392:	ff d0                	callq  *%rax
  8041603394:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  8041603399:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  804160339d:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  80416033a1:	66 83 f8 02          	cmp    $0x2,%ax
  80416033a5:	77 51                	ja     80416033f8 <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  80416033a7:	ba 04 00 00 00       	mov    $0x4,%edx
  80416033ac:	4c 89 e6             	mov    %r12,%rsi
  80416033af:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416033b3:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416033ba:	00 00 00 
  80416033bd:	ff d0                	callq  *%rax
  80416033bf:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416033c3:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  80416033c7:	0f 86 84 00 00 00    	jbe    8041603451 <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  80416033cd:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  80416033d1:	74 5a                	je     804160342d <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  80416033d3:	48 bf c0 86 60 41 80 	movabs $0x80416086c0,%rdi
  80416033da:	00 00 00 
  80416033dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033e2:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416033e9:	00 00 00 
  80416033ec:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416033ee:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416033f3:	e9 b8 05 00 00       	jmpq   80416039b0 <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  80416033f8:	48 b9 e8 88 60 41 80 	movabs $0x80416088e8,%rcx
  80416033ff:	00 00 00 
  8041603402:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041603409:	00 00 00 
  804160340c:	be fc 00 00 00       	mov    $0xfc,%esi
  8041603411:	48 bf a1 88 60 41 80 	movabs $0x80416088a1,%rdi
  8041603418:	00 00 00 
  804160341b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603420:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041603427:	00 00 00 
  804160342a:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160342d:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  8041603431:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603436:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160343a:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041603441:	00 00 00 
  8041603444:	ff d0                	callq  *%rax
  8041603446:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  804160344a:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160344f:	eb 08                	jmp    8041603459 <line_for_address+0x198>
    *len = initial_len;
  8041603451:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  8041603454:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  8041603459:	48 98                	cltq   
  804160345b:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  804160345e:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  8041603461:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603466:	4c 89 e6             	mov    %r12,%rsi
  8041603469:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160346d:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041603474:	00 00 00 
  8041603477:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  8041603479:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160347d:	0f 85 89 00 00 00    	jne    804160350c <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  8041603483:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  8041603488:	66 41 83 ff 04       	cmp    $0x4,%r15w
  804160348d:	0f 84 ae 00 00 00    	je     8041603541 <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  8041603493:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  8041603497:	ba 01 00 00 00       	mov    $0x1,%edx
  804160349c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034a0:	49 bc 61 7c 60 41 80 	movabs $0x8041607c61,%r12
  80416034a7:	00 00 00 
  80416034aa:	41 ff d4             	callq  *%r12
  80416034ad:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034b1:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  80416034b4:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  80416034b8:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034bd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034c1:	41 ff d4             	callq  *%r12
  80416034c4:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034c8:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034cb:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  80416034cf:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034d4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034d8:	41 ff d4             	callq  *%r12
  80416034db:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034df:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034e2:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  80416034e6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416034eb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034ef:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  80416034f2:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  80416034f6:	0f 86 90 04 00 00    	jbe    804160398c <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  80416034fc:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  8041603502:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041603507:	e9 32 04 00 00       	jmpq   804160393e <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  804160350c:	48 b9 18 89 60 41 80 	movabs $0x8041608918,%rcx
  8041603513:	00 00 00 
  8041603516:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160351d:	00 00 00 
  8041603520:	be 07 01 00 00       	mov    $0x107,%esi
  8041603525:	48 bf a1 88 60 41 80 	movabs $0x80416088a1,%rdi
  804160352c:	00 00 00 
  804160352f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603534:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160353b:	00 00 00 
  804160353e:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  8041603541:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603546:	48 89 de             	mov    %rbx,%rsi
  8041603549:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160354d:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041603554:	00 00 00 
  8041603557:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  8041603559:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  804160355e:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  8041603562:	0f 84 2b ff ff ff    	je     8041603493 <line_for_address+0x1d2>
  8041603568:	48 b9 38 89 60 41 80 	movabs $0x8041608938,%rcx
  804160356f:	00 00 00 
  8041603572:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041603579:	00 00 00 
  804160357c:	be 11 01 00 00       	mov    $0x111,%esi
  8041603581:	48 bf a1 88 60 41 80 	movabs $0x80416088a1,%rdi
  8041603588:	00 00 00 
  804160358b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603590:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041603597:	00 00 00 
  804160359a:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  804160359d:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  80416035a0:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  80416035a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416035ab:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  80416035b1:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  80416035b4:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416035b8:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  80416035bc:	89 fa                	mov    %edi,%edx
  80416035be:	83 e2 7f             	and    $0x7f,%edx
  80416035c1:	d3 e2                	shl    %cl,%edx
  80416035c3:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  80416035c6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416035c9:	40 84 ff             	test   %dil,%dil
  80416035cc:	78 e3                	js     80416035b1 <line_for_address+0x2f0>
  return count;
  80416035ce:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  80416035d1:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  80416035d4:	45 89 ff             	mov    %r15d,%r15d
  80416035d7:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  80416035da:	ba 01 00 00 00       	mov    $0x1,%edx
  80416035df:	4c 89 ee             	mov    %r13,%rsi
  80416035e2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416035e6:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416035ed:	00 00 00 
  80416035f0:	ff d0                	callq  *%rax
  80416035f2:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  80416035f6:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  80416035fa:	3c 02                	cmp    $0x2,%al
  80416035fc:	0f 84 dc 00 00 00    	je     80416036de <line_for_address+0x41d>
  8041603602:	76 39                	jbe    804160363d <line_for_address+0x37c>
  8041603604:	3c 03                	cmp    $0x3,%al
  8041603606:	74 62                	je     804160366a <line_for_address+0x3a9>
  8041603608:	3c 04                	cmp    $0x4,%al
  804160360a:	0f 85 0c 01 00 00    	jne    804160371c <line_for_address+0x45b>
  8041603610:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603613:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603618:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160361b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160361f:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603622:	84 c9                	test   %cl,%cl
  8041603624:	78 f2                	js     8041603618 <line_for_address+0x357>
  return count;
  8041603626:	48 98                	cltq   
          program_addr += count;
  8041603628:	48 01 c6             	add    %rax,%rsi
  804160362b:	44 89 e2             	mov    %r12d,%edx
  804160362e:	48 89 d8             	mov    %rbx,%rax
  8041603631:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603635:	4c 89 f3             	mov    %r14,%rbx
  8041603638:	e9 c8 00 00 00       	jmpq   8041603705 <line_for_address+0x444>
      switch (opcode) {
  804160363d:	3c 01                	cmp    $0x1,%al
  804160363f:	0f 85 d7 00 00 00    	jne    804160371c <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  8041603645:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603649:	49 39 c6             	cmp    %rax,%r14
  804160364c:	0f 87 f8 00 00 00    	ja     804160374a <line_for_address+0x489>
  8041603652:	48 39 d8             	cmp    %rbx,%rax
  8041603655:	0f 82 39 03 00 00    	jb     8041603994 <line_for_address+0x6d3>
          state->line          = 1;
  804160365b:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  8041603660:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603665:	e9 9b 00 00 00       	jmpq   8041603705 <line_for_address+0x444>
          while (*(char *)program_addr) {
  804160366a:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  804160366f:	74 09                	je     804160367a <line_for_address+0x3b9>
            ++program_addr;
  8041603671:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  8041603675:	80 3e 00             	cmpb   $0x0,(%rsi)
  8041603678:	75 f7                	jne    8041603671 <line_for_address+0x3b0>
          ++program_addr;
  804160367a:	48 83 c6 01          	add    $0x1,%rsi
  804160367e:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603681:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603686:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603689:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160368d:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603690:	84 c9                	test   %cl,%cl
  8041603692:	78 f2                	js     8041603686 <line_for_address+0x3c5>
  return count;
  8041603694:	48 98                	cltq   
          program_addr += count;
  8041603696:	48 01 c6             	add    %rax,%rsi
  8041603699:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160369c:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036a1:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036a4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036a8:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036ab:	84 c9                	test   %cl,%cl
  80416036ad:	78 f2                	js     80416036a1 <line_for_address+0x3e0>
  return count;
  80416036af:	48 98                	cltq   
          program_addr += count;
  80416036b1:	48 01 c6             	add    %rax,%rsi
  80416036b4:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416036b7:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036bc:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036bf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036c3:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036c6:	84 c9                	test   %cl,%cl
  80416036c8:	78 f2                	js     80416036bc <line_for_address+0x3fb>
  return count;
  80416036ca:	48 98                	cltq   
          program_addr += count;
  80416036cc:	48 01 c6             	add    %rax,%rsi
  80416036cf:	44 89 e2             	mov    %r12d,%edx
  80416036d2:	48 89 d8             	mov    %rbx,%rax
  80416036d5:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036d9:	4c 89 f3             	mov    %r14,%rbx
  80416036dc:	eb 27                	jmp    8041603705 <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  80416036de:	ba 08 00 00 00       	mov    $0x8,%edx
  80416036e3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416036e7:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416036ee:	00 00 00 
  80416036f1:	ff d0                	callq  *%rax
  80416036f3:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  80416036f7:	49 8d 75 09          	lea    0x9(%r13),%rsi
  80416036fb:	44 89 e2             	mov    %r12d,%edx
  80416036fe:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603702:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  8041603705:	49 39 f7             	cmp    %rsi,%r15
  8041603708:	75 4c                	jne    8041603756 <line_for_address+0x495>
  804160370a:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160370e:	41 89 d4             	mov    %edx,%r12d
  8041603711:	49 89 de             	mov    %rbx,%r14
  8041603714:	48 89 c3             	mov    %rax,%rbx
  8041603717:	e9 19 02 00 00       	jmpq   8041603935 <line_for_address+0x674>
      switch (opcode) {
  804160371c:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  804160371f:	48 ba b4 88 60 41 80 	movabs $0x80416088b4,%rdx
  8041603726:	00 00 00 
  8041603729:	be 6b 00 00 00       	mov    $0x6b,%esi
  804160372e:	48 bf a1 88 60 41 80 	movabs $0x80416088a1,%rdi
  8041603735:	00 00 00 
  8041603738:	b8 00 00 00 00       	mov    $0x0,%eax
  804160373d:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041603744:	00 00 00 
  8041603747:	41 ff d0             	callq  *%r8
          state->line          = 1;
  804160374a:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  804160374f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603754:	eb af                	jmp    8041603705 <line_for_address+0x444>
      assert(program_addr == opcode_end);
  8041603756:	48 b9 c7 88 60 41 80 	movabs $0x80416088c7,%rcx
  804160375d:	00 00 00 
  8041603760:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041603767:	00 00 00 
  804160376a:	be 6e 00 00 00       	mov    $0x6e,%esi
  804160376f:	48 bf a1 88 60 41 80 	movabs $0x80416088a1,%rdi
  8041603776:	00 00 00 
  8041603779:	b8 00 00 00 00       	mov    $0x0,%eax
  804160377e:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041603785:	00 00 00 
  8041603788:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  804160378b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160378f:	49 39 c6             	cmp    %rax,%r14
  8041603792:	0f 87 eb 01 00 00    	ja     8041603983 <line_for_address+0x6c2>
  8041603798:	48 39 d8             	cmp    %rbx,%rax
  804160379b:	0f 82 f9 01 00 00    	jb     804160399a <line_for_address+0x6d9>
          last_state           = *state;
  80416037a1:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416037a5:	49 89 de             	mov    %rbx,%r14
  80416037a8:	e9 88 01 00 00       	jmpq   8041603935 <line_for_address+0x674>
      switch (opcode) {
  80416037ad:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037b0:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416037b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037ba:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416037bf:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037c3:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  80416037c7:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416037ca:	45 89 c8             	mov    %r9d,%r8d
  80416037cd:	41 83 e0 7f          	and    $0x7f,%r8d
  80416037d1:	41 d3 e0             	shl    %cl,%r8d
  80416037d4:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  80416037d7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416037da:	45 84 c9             	test   %r9b,%r9b
  80416037dd:	78 e0                	js     80416037bf <line_for_address+0x4fe>
              info->minimum_instruction_length *
  80416037df:	89 d2                	mov    %edx,%edx
          state->address +=
  80416037e1:	48 01 d3             	add    %rdx,%rbx
  return count;
  80416037e4:	48 98                	cltq   
          program_addr += count;
  80416037e6:	48 01 c6             	add    %rax,%rsi
        } break;
  80416037e9:	e9 47 01 00 00       	jmpq   8041603935 <line_for_address+0x674>
      switch (opcode) {
  80416037ee:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037f1:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416037f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037fb:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603800:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041603804:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  8041603808:	45 89 c8             	mov    %r9d,%r8d
  804160380b:	41 83 e0 7f          	and    $0x7f,%r8d
  804160380f:	41 d3 e0             	shl    %cl,%r8d
  8041603812:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  8041603815:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041603818:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160381b:	45 84 c9             	test   %r9b,%r9b
  804160381e:	78 e0                	js     8041603800 <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  8041603820:	83 f9 1f             	cmp    $0x1f,%ecx
  8041603823:	7f 0f                	jg     8041603834 <line_for_address+0x573>
  8041603825:	41 f6 c1 40          	test   $0x40,%r9b
  8041603829:	74 09                	je     8041603834 <line_for_address+0x573>
    result |= (-1U << shift);
  804160382b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8041603830:	d3 e7                	shl    %cl,%edi
  8041603832:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  8041603834:	41 01 d4             	add    %edx,%r12d
  return count;
  8041603837:	48 98                	cltq   
          program_addr += count;
  8041603839:	48 01 c6             	add    %rax,%rsi
        } break;
  804160383c:	e9 f4 00 00 00       	jmpq   8041603935 <line_for_address+0x674>
      switch (opcode) {
  8041603841:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603844:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603849:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160384c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603850:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603853:	84 c9                	test   %cl,%cl
  8041603855:	78 f2                	js     8041603849 <line_for_address+0x588>
  return count;
  8041603857:	48 98                	cltq   
          program_addr += count;
  8041603859:	48 01 c6             	add    %rax,%rsi
        } break;
  804160385c:	e9 d4 00 00 00       	jmpq   8041603935 <line_for_address+0x674>
      switch (opcode) {
  8041603861:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603864:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603869:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160386c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603870:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603873:	84 c9                	test   %cl,%cl
  8041603875:	78 f2                	js     8041603869 <line_for_address+0x5a8>
  return count;
  8041603877:	48 98                	cltq   
          program_addr += count;
  8041603879:	48 01 c6             	add    %rax,%rsi
        } break;
  804160387c:	e9 b4 00 00 00       	jmpq   8041603935 <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  8041603881:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  8041603885:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  8041603887:	0f b6 c0             	movzbl %al,%eax
  804160388a:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  804160388d:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  8041603890:	48 01 c3             	add    %rax,%rbx
        } break;
  8041603893:	e9 9d 00 00 00       	jmpq   8041603935 <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  8041603898:	ba 02 00 00 00       	mov    $0x2,%edx
  804160389d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416038a1:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  80416038a8:	00 00 00 
  80416038ab:	ff d0                	callq  *%rax
          state->address += pc_inc;
  80416038ad:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416038b1:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  80416038b4:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  80416038b8:	eb 7b                	jmp    8041603935 <line_for_address+0x674>
      switch (opcode) {
  80416038ba:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416038bd:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416038c2:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416038c5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416038c9:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416038cc:	84 c9                	test   %cl,%cl
  80416038ce:	78 f2                	js     80416038c2 <line_for_address+0x601>
  return count;
  80416038d0:	48 98                	cltq   
          program_addr += count;
  80416038d2:	48 01 c6             	add    %rax,%rsi
        } break;
  80416038d5:	eb 5e                	jmp    8041603935 <line_for_address+0x674>
      switch (opcode) {
  80416038d7:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  80416038da:	48 ba b4 88 60 41 80 	movabs $0x80416088b4,%rdx
  80416038e1:	00 00 00 
  80416038e4:	be c1 00 00 00       	mov    $0xc1,%esi
  80416038e9:	48 bf a1 88 60 41 80 	movabs $0x80416088a1,%rdi
  80416038f0:	00 00 00 
  80416038f3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038f8:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416038ff:	00 00 00 
  8041603902:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  8041603905:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  8041603908:	0f b6 c0             	movzbl %al,%eax
  804160390b:	f6 75 ba             	divb   -0x46(%rbp)
  804160390e:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  8041603911:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  8041603915:	01 ca                	add    %ecx,%edx
  8041603917:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  804160391a:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  804160391d:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  8041603920:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603924:	49 39 c6             	cmp    %rax,%r14
  8041603927:	77 05                	ja     804160392e <line_for_address+0x66d>
  8041603929:	48 39 d8             	cmp    %rbx,%rax
  804160392c:	72 72                	jb     80416039a0 <line_for_address+0x6df>
      last_state = *state;
  804160392e:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603932:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  8041603935:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  8041603939:	76 69                	jbe    80416039a4 <line_for_address+0x6e3>
  804160393b:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  804160393e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603943:	4c 89 ee             	mov    %r13,%rsi
  8041603946:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160394a:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041603951:	00 00 00 
  8041603954:	ff d0                	callq  *%rax
  8041603956:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  804160395a:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  804160395e:	84 c0                	test   %al,%al
  8041603960:	0f 84 37 fc ff ff    	je     804160359d <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  8041603966:	38 45 bb             	cmp    %al,-0x45(%rbp)
  8041603969:	76 9a                	jbe    8041603905 <line_for_address+0x644>
      switch (opcode) {
  804160396b:	3c 0c                	cmp    $0xc,%al
  804160396d:	0f 87 64 ff ff ff    	ja     80416038d7 <line_for_address+0x616>
  8041603973:	0f b6 d0             	movzbl %al,%edx
  8041603976:	48 bf 60 89 60 41 80 	movabs $0x8041608960,%rdi
  804160397d:	00 00 00 
  8041603980:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  8041603983:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603987:	49 89 de             	mov    %rbx,%r14
  804160398a:	eb a9                	jmp    8041603935 <line_for_address+0x674>
  struct Line_Number_State current_state = {
  804160398c:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  8041603992:	eb 10                	jmp    80416039a4 <line_for_address+0x6e3>
            *state = last_state;
  8041603994:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603998:	eb 0a                	jmp    80416039a4 <line_for_address+0x6e3>
            *state = last_state;
  804160399a:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160399e:	eb 04                	jmp    80416039a4 <line_for_address+0x6e3>
        *state = last_state;
  80416039a0:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  80416039a4:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80416039a8:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  80416039ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416039b0:	48 83 c4 38          	add    $0x38,%rsp
  80416039b4:	5b                   	pop    %rbx
  80416039b5:	41 5c                	pop    %r12
  80416039b7:	41 5d                	pop    %r13
  80416039b9:	41 5e                	pop    %r14
  80416039bb:	41 5f                	pop    %r15
  80416039bd:	5d                   	pop    %rbp
  80416039be:	c3                   	retq   
    return -E_INVAL;
  80416039bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416039c4:	eb ea                	jmp    80416039b0 <line_for_address+0x6ef>

00000080416039c6 <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  80416039c6:	55                   	push   %rbp
  80416039c7:	48 89 e5             	mov    %rsp,%rbp
  80416039ca:	41 55                	push   %r13
  80416039cc:	41 54                	push   %r12
  80416039ce:	53                   	push   %rbx
  80416039cf:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  80416039d3:	48 bb 00 8d 60 41 80 	movabs $0x8041608d00,%rbx
  80416039da:	00 00 00 
  80416039dd:	4c 8d ab c0 00 00 00 	lea    0xc0(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  80416039e4:	49 bc 6a 5a 60 41 80 	movabs $0x8041605a6a,%r12
  80416039eb:	00 00 00 
  80416039ee:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  80416039f2:	48 8b 33             	mov    (%rbx),%rsi
  80416039f5:	48 bf c8 89 60 41 80 	movabs $0x80416089c8,%rdi
  80416039fc:	00 00 00 
  80416039ff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a04:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  8041603a07:	48 83 c3 18          	add    $0x18,%rbx
  8041603a0b:	4c 39 eb             	cmp    %r13,%rbx
  8041603a0e:	75 de                	jne    80416039ee <mon_help+0x28>
  return 0;
}
  8041603a10:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a15:	48 83 c4 08          	add    $0x8,%rsp
  8041603a19:	5b                   	pop    %rbx
  8041603a1a:	41 5c                	pop    %r12
  8041603a1c:	41 5d                	pop    %r13
  8041603a1e:	5d                   	pop    %rbp
  8041603a1f:	c3                   	retq   

0000008041603a20 <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  8041603a20:	55                   	push   %rbp
  8041603a21:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603a24:	48 bf d1 89 60 41 80 	movabs $0x80416089d1,%rdi
  8041603a2b:	00 00 00 
  8041603a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a33:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041603a3a:	00 00 00 
  8041603a3d:	ff d2                	callq  *%rdx
  return 0;
}
  8041603a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a44:	5d                   	pop    %rbp
  8041603a45:	c3                   	retq   

0000008041603a46 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  8041603a46:	55                   	push   %rbp
  8041603a47:	48 89 e5             	mov    %rsp,%rbp
  8041603a4a:	41 55                	push   %r13
  8041603a4c:	41 54                	push   %r12
  8041603a4e:	53                   	push   %rbx
  8041603a4f:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  8041603a53:	48 bf d9 89 60 41 80 	movabs $0x80416089d9,%rdi
  8041603a5a:	00 00 00 
  8041603a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a62:	49 bc 6a 5a 60 41 80 	movabs $0x8041605a6a,%r12
  8041603a69:	00 00 00 
  8041603a6c:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  8041603a6f:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  8041603a76:	00 00 00 
  8041603a79:	48 bf 60 8b 60 41 80 	movabs $0x8041608b60,%rdi
  8041603a80:	00 00 00 
  8041603a83:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a88:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  8041603a8b:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  8041603a92:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  8041603a95:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  8041603a9c:	00 00 00 
  8041603a9f:	4c 89 ee             	mov    %r13,%rsi
  8041603aa2:	48 bf 90 8b 60 41 80 	movabs $0x8041608b90,%rdi
  8041603aa9:	00 00 00 
  8041603aac:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ab1:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603ab4:	48 ba 98 83 60 01 00 	movabs $0x1608398,%rdx
  8041603abb:	00 00 00 
  8041603abe:	48 be 98 83 60 41 80 	movabs $0x8041608398,%rsi
  8041603ac5:	00 00 00 
  8041603ac8:	48 bf b8 8b 60 41 80 	movabs $0x8041608bb8,%rdi
  8041603acf:	00 00 00 
  8041603ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ad7:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603ada:	48 ba e8 a8 61 01 00 	movabs $0x161a8e8,%rdx
  8041603ae1:	00 00 00 
  8041603ae4:	48 be e8 a8 61 41 80 	movabs $0x804161a8e8,%rsi
  8041603aeb:	00 00 00 
  8041603aee:	48 bf e0 8b 60 41 80 	movabs $0x8041608be0,%rdi
  8041603af5:	00 00 00 
  8041603af8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603afd:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  8041603b00:	48 bb 00 e0 61 41 80 	movabs $0x804161e000,%rbx
  8041603b07:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603b0a:	48 ba 00 e0 61 01 00 	movabs $0x161e000,%rdx
  8041603b11:	00 00 00 
  8041603b14:	48 89 de             	mov    %rbx,%rsi
  8041603b17:	48 bf 08 8c 60 41 80 	movabs $0x8041608c08,%rdi
  8041603b1e:	00 00 00 
  8041603b21:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b26:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603b29:	4c 29 eb             	sub    %r13,%rbx
  8041603b2c:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603b33:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603b37:	48 bf 30 8c 60 41 80 	movabs $0x8041608c30,%rdi
  8041603b3e:	00 00 00 
  8041603b41:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b46:	41 ff d4             	callq  *%r12
  return 0;
}
  8041603b49:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b4e:	48 83 c4 08          	add    $0x8,%rsp
  8041603b52:	5b                   	pop    %rbx
  8041603b53:	41 5c                	pop    %r12
  8041603b55:	41 5d                	pop    %r13
  8041603b57:	5d                   	pop    %rbp
  8041603b58:	c3                   	retq   

0000008041603b59 <mon_mycommand>:


// LAB 2 code
int
mon_mycommand(int argc, char **argv, struct Trapframe *tf) {
  8041603b59:	55                   	push   %rbp
  8041603b5a:	48 89 e5             	mov    %rsp,%rbp
  cprintf("This is output for my command.\n");
  8041603b5d:	48 bf 60 8c 60 41 80 	movabs $0x8041608c60,%rdi
  8041603b64:	00 00 00 
  8041603b67:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b6c:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041603b73:	00 00 00 
  8041603b76:	ff d2                	callq  *%rdx
  return 0;
}
  8041603b78:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b7d:	5d                   	pop    %rbp
  8041603b7e:	c3                   	retq   

0000008041603b7f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  8041603b7f:	55                   	push   %rbp
  8041603b80:	48 89 e5             	mov    %rsp,%rbp
  8041603b83:	41 57                	push   %r15
  8041603b85:	41 56                	push   %r14
  8041603b87:	41 55                	push   %r13
  8041603b89:	41 54                	push   %r12
  8041603b8b:	53                   	push   %rbx
  8041603b8c:	48 81 ec 38 02 00 00 	sub    $0x238,%rsp
  // LAB 2 code
  
  cprintf("Stack backtrace:\n");
  8041603b93:	48 bf f2 89 60 41 80 	movabs $0x80416089f2,%rdi
  8041603b9a:	00 00 00 
  8041603b9d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ba2:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041603ba9:	00 00 00 
  8041603bac:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603bae:	48 89 e8             	mov    %rbp,%rax
  uint64_t buf;
  int digits_16;
  int code;
  struct Ripdebuginfo info;
    
  while (rbp != 0) {
  8041603bb1:	48 85 c0             	test   %rax,%rax
  8041603bb4:	0f 84 c5 01 00 00    	je     8041603d7f <mon_backtrace+0x200>
  8041603bba:	49 89 c6             	mov    %rax,%r14
  8041603bbd:	49 89 c7             	mov    %rax,%r15
      while (buf != 0) {
        digits_16++;
        buf = buf / 16;
      }
      
      cprintf("  rbp ");
  8041603bc0:	49 bc 6a 5a 60 41 80 	movabs $0x8041605a6a,%r12
  8041603bc7:	00 00 00 
      cprintf("%lx\n", rip);
      
      // get and print debug info
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
      if (code == 0) {
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603bca:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603bd1:	48 05 04 01 00 00    	add    $0x104,%rax
  8041603bd7:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  8041603bde:	e9 37 01 00 00       	jmpq   8041603d1a <mon_backtrace+0x19b>
        buf = buf / 16;
  8041603be3:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603be6:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603be9:	48 89 c2             	mov    %rax,%rdx
  8041603bec:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603bf0:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603bf4:	77 ed                	ja     8041603be3 <mon_backtrace+0x64>
      cprintf("  rbp ");
  8041603bf6:	48 bf 04 8a 60 41 80 	movabs $0x8041608a04,%rdi
  8041603bfd:	00 00 00 
  8041603c00:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c05:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c08:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603c0e:	41 29 dd             	sub    %ebx,%r13d
  8041603c11:	45 85 ed             	test   %r13d,%r13d
  8041603c14:	7e 1f                	jle    8041603c35 <mon_backtrace+0xb6>
  8041603c16:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603c1b:	48 bf 70 90 60 41 80 	movabs $0x8041609070,%rdi
  8041603c22:	00 00 00 
  8041603c25:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c2a:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c2d:	83 c3 01             	add    $0x1,%ebx
  8041603c30:	41 39 dd             	cmp    %ebx,%r13d
  8041603c33:	7d e6                	jge    8041603c1b <mon_backtrace+0x9c>
      cprintf("%lx", rbp);
  8041603c35:	4c 89 f6             	mov    %r14,%rsi
  8041603c38:	48 bf 0b 8a 60 41 80 	movabs $0x8041608a0b,%rdi
  8041603c3f:	00 00 00 
  8041603c42:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c47:	41 ff d4             	callq  *%r12
      rbp = *pointer;
  8041603c4a:	4d 8b 37             	mov    (%r15),%r14
      rip = *pointer;
  8041603c4d:	4d 8b 7f 08          	mov    0x8(%r15),%r15
      buf = buf / 16;
  8041603c51:	4c 89 f8             	mov    %r15,%rax
  8041603c54:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603c58:	49 83 ff 0f          	cmp    $0xf,%r15
  8041603c5c:	0f 86 e3 00 00 00    	jbe    8041603d45 <mon_backtrace+0x1c6>
      digits_16 = 1;
  8041603c62:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603c67:	eb 03                	jmp    8041603c6c <mon_backtrace+0xed>
        buf = buf / 16;
  8041603c69:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603c6c:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603c6f:	48 89 c2             	mov    %rax,%rdx
  8041603c72:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603c76:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603c7a:	77 ed                	ja     8041603c69 <mon_backtrace+0xea>
      cprintf("  rip ");
  8041603c7c:	48 bf 0f 8a 60 41 80 	movabs $0x8041608a0f,%rdi
  8041603c83:	00 00 00 
  8041603c86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c8b:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c8e:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603c94:	41 29 dd             	sub    %ebx,%r13d
  8041603c97:	45 85 ed             	test   %r13d,%r13d
  8041603c9a:	7e 1f                	jle    8041603cbb <mon_backtrace+0x13c>
  8041603c9c:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603ca1:	48 bf 70 90 60 41 80 	movabs $0x8041609070,%rdi
  8041603ca8:	00 00 00 
  8041603cab:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cb0:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603cb3:	83 c3 01             	add    $0x1,%ebx
  8041603cb6:	44 39 eb             	cmp    %r13d,%ebx
  8041603cb9:	7e e6                	jle    8041603ca1 <mon_backtrace+0x122>
      cprintf("%lx\n", rip);
  8041603cbb:	4c 89 fe             	mov    %r15,%rsi
  8041603cbe:	48 bf 16 8a 60 41 80 	movabs $0x8041608a16,%rdi
  8041603cc5:	00 00 00 
  8041603cc8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ccd:	41 ff d4             	callq  *%r12
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
  8041603cd0:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603cd7:	4c 89 ff             	mov    %r15,%rdi
  8041603cda:	48 b8 19 6d 60 41 80 	movabs $0x8041606d19,%rax
  8041603ce1:	00 00 00 
  8041603ce4:	ff d0                	callq  *%rax
      if (code == 0) {
  8041603ce6:	85 c0                	test   %eax,%eax
  8041603ce8:	75 47                	jne    8041603d31 <mon_backtrace+0x1b2>
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603cea:	4d 89 f8             	mov    %r15,%r8
  8041603ced:	4c 2b 45 b8          	sub    -0x48(%rbp),%r8
  8041603cf1:	48 8b 8d a8 fd ff ff 	mov    -0x258(%rbp),%rcx
  8041603cf8:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603cfe:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603d05:	48 bf 1b 8a 60 41 80 	movabs $0x8041608a1b,%rdi
  8041603d0c:	00 00 00 
  8041603d0f:	41 ff d4             	callq  *%r12
      } else {
          cprintf("Info not found");
      }
      
      pointer = (uintptr_t *)rbp;
  8041603d12:	4d 89 f7             	mov    %r14,%r15
  while (rbp != 0) {
  8041603d15:	4d 85 f6             	test   %r14,%r14
  8041603d18:	74 65                	je     8041603d7f <mon_backtrace+0x200>
      buf = buf / 16;
  8041603d1a:	4c 89 f0             	mov    %r14,%rax
  8041603d1d:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603d21:	49 83 fe 0f          	cmp    $0xf,%r14
  8041603d25:	76 3b                	jbe    8041603d62 <mon_backtrace+0x1e3>
      digits_16 = 1;
  8041603d27:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603d2c:	e9 b5 fe ff ff       	jmpq   8041603be6 <mon_backtrace+0x67>
          cprintf("Info not found");
  8041603d31:	48 bf 33 8a 60 41 80 	movabs $0x8041608a33,%rdi
  8041603d38:	00 00 00 
  8041603d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d40:	41 ff d4             	callq  *%r12
  8041603d43:	eb cd                	jmp    8041603d12 <mon_backtrace+0x193>
      cprintf("  rip ");
  8041603d45:	48 bf 0f 8a 60 41 80 	movabs $0x8041608a0f,%rdi
  8041603d4c:	00 00 00 
  8041603d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d54:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d57:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d5d:	e9 3a ff ff ff       	jmpq   8041603c9c <mon_backtrace+0x11d>
      cprintf("  rbp ");
  8041603d62:	48 bf 04 8a 60 41 80 	movabs $0x8041608a04,%rdi
  8041603d69:	00 00 00 
  8041603d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d71:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d74:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d7a:	e9 97 fe ff ff       	jmpq   8041603c16 <mon_backtrace+0x97>
    }
    
  return 0;
}
  8041603d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d84:	48 81 c4 38 02 00 00 	add    $0x238,%rsp
  8041603d8b:	5b                   	pop    %rbx
  8041603d8c:	41 5c                	pop    %r12
  8041603d8e:	41 5d                	pop    %r13
  8041603d90:	41 5e                	pop    %r14
  8041603d92:	41 5f                	pop    %r15
  8041603d94:	5d                   	pop    %rbp
  8041603d95:	c3                   	retq   

0000008041603d96 <mon_start>:
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
int
mon_start(int argc, char **argv, struct Trapframe *tf) {

  if (argc != 2) {
    return 1;
  8041603d96:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603d9b:	83 ff 02             	cmp    $0x2,%edi
  8041603d9e:	74 01                	je     8041603da1 <mon_start+0xb>
  }
  timer_start(argv[1]);

  return 0;
}
  8041603da0:	c3                   	retq   
mon_start(int argc, char **argv, struct Trapframe *tf) {
  8041603da1:	55                   	push   %rbp
  8041603da2:	48 89 e5             	mov    %rsp,%rbp
  timer_start(argv[1]);
  8041603da5:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603da9:	48 b8 ab 80 60 41 80 	movabs $0x80416080ab,%rax
  8041603db0:	00 00 00 
  8041603db3:	ff d0                	callq  *%rax
  return 0;
  8041603db5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603dba:	5d                   	pop    %rbp
  8041603dbb:	c3                   	retq   

0000008041603dbc <mon_stop>:

int
mon_stop(int argc, char **argv, struct Trapframe *tf) {
  8041603dbc:	55                   	push   %rbp
  8041603dbd:	48 89 e5             	mov    %rsp,%rbp

  timer_stop();
  8041603dc0:	48 b8 65 81 60 41 80 	movabs $0x8041608165,%rax
  8041603dc7:	00 00 00 
  8041603dca:	ff d0                	callq  *%rax

  return 0;
}
  8041603dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603dd1:	5d                   	pop    %rbp
  8041603dd2:	c3                   	retq   

0000008041603dd3 <mon_frequency>:

int
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603dd3:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603dd8:	83 ff 02             	cmp    $0x2,%edi
  8041603ddb:	74 01                	je     8041603dde <mon_frequency+0xb>
  }
  timer_cpu_frequency(argv[1]);

  return 0;
}
  8041603ddd:	c3                   	retq   
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  8041603dde:	55                   	push   %rbp
  8041603ddf:	48 89 e5             	mov    %rsp,%rbp
  timer_cpu_frequency(argv[1]);
  8041603de2:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603de6:	48 b8 ef 81 60 41 80 	movabs $0x80416081ef,%rax
  8041603ded:	00 00 00 
  8041603df0:	ff d0                	callq  *%rax
  return 0;
  8041603df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603df7:	5d                   	pop    %rbp
  8041603df8:	c3                   	retq   

0000008041603df9 <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603df9:	55                   	push   %rbp
  8041603dfa:	48 89 e5             	mov    %rsp,%rbp
  8041603dfd:	41 57                	push   %r15
  8041603dff:	41 56                	push   %r14
  8041603e01:	41 55                	push   %r13
  8041603e03:	41 54                	push   %r12
  8041603e05:	53                   	push   %rbx
  8041603e06:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603e0d:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603e14:	48 bf 80 8c 60 41 80 	movabs $0x8041608c80,%rdi
  8041603e1b:	00 00 00 
  8041603e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e23:	48 bb 6a 5a 60 41 80 	movabs $0x8041605a6a,%rbx
  8041603e2a:	00 00 00 
  8041603e2d:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603e2f:	48 bf a8 8c 60 41 80 	movabs $0x8041608ca8,%rdi
  8041603e36:	00 00 00 
  8041603e39:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e3e:	ff d3                	callq  *%rbx

  while (1) {
    buf = readline("K> ");
  8041603e40:	49 bf ae 78 60 41 80 	movabs $0x80416078ae,%r15
  8041603e47:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603e4a:	49 be 5e 7b 60 41 80 	movabs $0x8041607b5e,%r14
  8041603e51:	00 00 00 
  8041603e54:	e9 ff 00 00 00       	jmpq   8041603f58 <monitor+0x15f>
  8041603e59:	40 0f be f6          	movsbl %sil,%esi
  8041603e5d:	48 bf 46 8a 60 41 80 	movabs $0x8041608a46,%rdi
  8041603e64:	00 00 00 
  8041603e67:	41 ff d6             	callq  *%r14
  8041603e6a:	48 85 c0             	test   %rax,%rax
  8041603e6d:	74 0c                	je     8041603e7b <monitor+0x82>
      *buf++ = 0;
  8041603e6f:	c6 03 00             	movb   $0x0,(%rbx)
  8041603e72:	45 89 e5             	mov    %r12d,%r13d
  8041603e75:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603e79:	eb 49                	jmp    8041603ec4 <monitor+0xcb>
    if (*buf == 0)
  8041603e7b:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603e7e:	74 4f                	je     8041603ecf <monitor+0xd6>
    if (argc == MAXARGS - 1) {
  8041603e80:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603e84:	0f 84 b3 00 00 00    	je     8041603f3d <monitor+0x144>
    argv[argc++] = buf;
  8041603e8a:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  8041603e8f:	4d 63 e4             	movslq %r12d,%r12
  8041603e92:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041603e99:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603e9a:	0f b6 33             	movzbl (%rbx),%esi
  8041603e9d:	40 84 f6             	test   %sil,%sil
  8041603ea0:	74 22                	je     8041603ec4 <monitor+0xcb>
  8041603ea2:	40 0f be f6          	movsbl %sil,%esi
  8041603ea6:	48 bf 46 8a 60 41 80 	movabs $0x8041608a46,%rdi
  8041603ead:	00 00 00 
  8041603eb0:	41 ff d6             	callq  *%r14
  8041603eb3:	48 85 c0             	test   %rax,%rax
  8041603eb6:	75 0c                	jne    8041603ec4 <monitor+0xcb>
      buf++;
  8041603eb8:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603ebc:	0f b6 33             	movzbl (%rbx),%esi
  8041603ebf:	40 84 f6             	test   %sil,%sil
  8041603ec2:	75 de                	jne    8041603ea2 <monitor+0xa9>
      *buf++ = 0;
  8041603ec4:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603ec7:	0f b6 33             	movzbl (%rbx),%esi
  8041603eca:	40 84 f6             	test   %sil,%sil
  8041603ecd:	75 8a                	jne    8041603e59 <monitor+0x60>
  argv[argc] = 0;
  8041603ecf:	49 63 c4             	movslq %r12d,%rax
  8041603ed2:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041603ed9:	ff 00 00 00 00 
  if (argc == 0)
  8041603ede:	45 85 e4             	test   %r12d,%r12d
  8041603ee1:	74 75                	je     8041603f58 <monitor+0x15f>
  8041603ee3:	49 bd 00 8d 60 41 80 	movabs $0x8041608d00,%r13
  8041603eea:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041603eed:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  8041603ef2:	49 8b 75 00          	mov    0x0(%r13),%rsi
  8041603ef6:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041603efd:	48 b8 f7 7a 60 41 80 	movabs $0x8041607af7,%rax
  8041603f04:	00 00 00 
  8041603f07:	ff d0                	callq  *%rax
  8041603f09:	85 c0                	test   %eax,%eax
  8041603f0b:	74 76                	je     8041603f83 <monitor+0x18a>
  for (i = 0; i < NCOMMANDS; i++) {
  8041603f0d:	83 c3 01             	add    $0x1,%ebx
  8041603f10:	49 83 c5 18          	add    $0x18,%r13
  8041603f14:	83 fb 08             	cmp    $0x8,%ebx
  8041603f17:	75 d9                	jne    8041603ef2 <monitor+0xf9>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041603f19:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041603f20:	48 bf 68 8a 60 41 80 	movabs $0x8041608a68,%rdi
  8041603f27:	00 00 00 
  8041603f2a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f2f:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041603f36:	00 00 00 
  8041603f39:	ff d2                	callq  *%rdx
  return 0;
  8041603f3b:	eb 1b                	jmp    8041603f58 <monitor+0x15f>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041603f3d:	be 10 00 00 00       	mov    $0x10,%esi
  8041603f42:	48 bf 4b 8a 60 41 80 	movabs $0x8041608a4b,%rdi
  8041603f49:	00 00 00 
  8041603f4c:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041603f53:	00 00 00 
  8041603f56:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  8041603f58:	48 bf 42 8a 60 41 80 	movabs $0x8041608a42,%rdi
  8041603f5f:	00 00 00 
  8041603f62:	41 ff d7             	callq  *%r15
  8041603f65:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  8041603f68:	48 85 c0             	test   %rax,%rax
  8041603f6b:	74 eb                	je     8041603f58 <monitor+0x15f>
  argv[argc] = 0;
  8041603f6d:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  8041603f74:	00 00 00 00 
  argc       = 0;
  8041603f78:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041603f7e:	e9 44 ff ff ff       	jmpq   8041603ec7 <monitor+0xce>
      return commands[i].func(argc, argv, tf);
  8041603f83:	48 63 db             	movslq %ebx,%rbx
  8041603f86:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  8041603f8a:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  8041603f91:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  8041603f98:	44 89 e7             	mov    %r12d,%edi
  8041603f9b:	48 b8 00 8d 60 41 80 	movabs $0x8041608d00,%rax
  8041603fa2:	00 00 00 
  8041603fa5:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  8041603fa9:	85 c0                	test   %eax,%eax
  8041603fab:	79 ab                	jns    8041603f58 <monitor+0x15f>
        break;
  }
}
  8041603fad:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041603fb4:	5b                   	pop    %rbx
  8041603fb5:	41 5c                	pop    %r12
  8041603fb7:	41 5d                	pop    %r13
  8041603fb9:	41 5e                	pop    %r14
  8041603fbb:	41 5f                	pop    %r15
  8041603fbd:	5d                   	pop    %rbp
  8041603fbe:	c3                   	retq   

0000008041603fbf <boot_alloc>:
  // 'end' is a magic symbol automatically generated by the linker,
  // which points to the end of the kernel's bss segment:
  // the first virtual address that the linker did *not* assign
  // to any kernel code or global variables.

  if (!nextfree) {
  8041603fbf:	48 b8 78 ab 61 41 80 	movabs $0x804161ab78,%rax
  8041603fc6:	00 00 00 
  8041603fc9:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041603fcd:	74 5c                	je     804160402b <boot_alloc+0x6c>
  // nextfree.  Make sure nextfree is kept aligned
  // to a multiple of PGSIZE.
  //
  // LAB 6: Your code here.

  if (!n) {
  8041603fcf:	85 ff                	test   %edi,%edi
  8041603fd1:	74 74                	je     8041604047 <boot_alloc+0x88>
boot_alloc(uint32_t n) {
  8041603fd3:	55                   	push   %rbp
  8041603fd4:	48 89 e5             	mov    %rsp,%rbp
	    return nextfree;
	}
	result = nextfree;
  8041603fd7:	48 ba 78 ab 61 41 80 	movabs $0x804161ab78,%rdx
  8041603fde:	00 00 00 
  8041603fe1:	48 8b 02             	mov    (%rdx),%rax
	nextfree += ROUNDUP(n, PGSIZE);
  8041603fe4:	48 8d 8f ff 0f 00 00 	lea    0xfff(%rdi),%rcx
  8041603feb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  8041603ff1:	48 01 c1             	add    %rax,%rcx
  8041603ff4:	48 89 0a             	mov    %rcx,(%rdx)
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva) {
  if ((uint64_t)kva < KERNBASE)
  8041603ff7:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041603ffe:	00 00 00 
  8041604001:	48 39 d1             	cmp    %rdx,%rcx
  8041604004:	76 4c                	jbe    8041604052 <boot_alloc+0x93>
	if (PADDR(nextfree) > PGSIZE * npages) {
  8041604006:	48 be 50 c0 61 41 80 	movabs $0x804161c050,%rsi
  804160400d:	00 00 00 
  8041604010:	48 8b 16             	mov    (%rsi),%rdx
  8041604013:	48 c1 e2 0c          	shl    $0xc,%rdx
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  return (physaddr_t)kva - KERNBASE;
  8041604017:	48 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rsi
  804160401e:	ff ff ff 
  8041604021:	48 01 f1             	add    %rsi,%rcx
  8041604024:	48 39 ca             	cmp    %rcx,%rdx
  8041604027:	72 54                	jb     804160407d <boot_alloc+0xbe>
	platform_asan_unpoison(result, n);
  #endif

	return result;

}
  8041604029:	5d                   	pop    %rbp
  804160402a:	c3                   	retq   
		nextfree = ROUNDUP((char *) end, PGSIZE);
  804160402b:	48 b8 ff ef 61 41 80 	movabs $0x804161efff,%rax
  8041604032:	00 00 00 
  8041604035:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160403b:	48 a3 78 ab 61 41 80 	movabs %rax,0x804161ab78
  8041604042:	00 00 00 
  8041604045:	eb 88                	jmp    8041603fcf <boot_alloc+0x10>
	    return nextfree;
  8041604047:	48 a1 78 ab 61 41 80 	movabs 0x804161ab78,%rax
  804160404e:	00 00 00 
}
  8041604051:	c3                   	retq   
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041604052:	48 ba c0 8d 60 41 80 	movabs $0x8041608dc0,%rdx
  8041604059:	00 00 00 
  804160405c:	be b9 00 00 00       	mov    $0xb9,%esi
  8041604061:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604068:	00 00 00 
  804160406b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604070:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604077:	00 00 00 
  804160407a:	41 ff d0             	callq  *%r8
	    panic("Out of memory on boot, what? how?!");
  804160407d:	48 ba e8 8d 60 41 80 	movabs $0x8041608de8,%rdx
  8041604084:	00 00 00 
  8041604087:	be ba 00 00 00       	mov    $0xba,%esi
  804160408c:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604093:	00 00 00 
  8041604096:	b8 00 00 00 00       	mov    $0x0,%eax
  804160409b:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  80416040a2:	00 00 00 
  80416040a5:	ff d1                	callq  *%rcx

00000080416040a7 <is_page_allocatable>:
  if (!mmap_base || !mmap_end)
  80416040a7:	48 b8 70 ab 61 41 80 	movabs $0x804161ab70,%rax
  80416040ae:	00 00 00 
  80416040b1:	48 8b 10             	mov    (%rax),%rdx
  80416040b4:	48 85 d2             	test   %rdx,%rdx
  80416040b7:	0f 84 93 00 00 00    	je     8041604150 <is_page_allocatable+0xa9>
  80416040bd:	48 b8 68 ab 61 41 80 	movabs $0x804161ab68,%rax
  80416040c4:	00 00 00 
  80416040c7:	48 8b 30             	mov    (%rax),%rsi
  80416040ca:	48 85 f6             	test   %rsi,%rsi
  80416040cd:	0f 84 83 00 00 00    	je     8041604156 <is_page_allocatable+0xaf>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416040d3:	48 39 f2             	cmp    %rsi,%rdx
  80416040d6:	0f 83 80 00 00 00    	jae    804160415c <is_page_allocatable+0xb5>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  80416040dc:	48 8b 42 08          	mov    0x8(%rdx),%rax
  80416040e0:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  80416040e4:	48 89 c1             	mov    %rax,%rcx
  80416040e7:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  80416040eb:	48 39 cf             	cmp    %rcx,%rdi
  80416040ee:	73 05                	jae    80416040f5 <is_page_allocatable+0x4e>
  80416040f0:	48 39 c7             	cmp    %rax,%rdi
  80416040f3:	73 34                	jae    8041604129 <is_page_allocatable+0x82>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416040f5:	48 b8 60 ab 61 41 80 	movabs $0x804161ab60,%rax
  80416040fc:	00 00 00 
  80416040ff:	4c 8b 00             	mov    (%rax),%r8
  8041604102:	4c 01 c2             	add    %r8,%rdx
  8041604105:	48 39 d6             	cmp    %rdx,%rsi
  8041604108:	76 40                	jbe    804160414a <is_page_allocatable+0xa3>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  804160410a:	48 8b 42 08          	mov    0x8(%rdx),%rax
  804160410e:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  8041604112:	48 89 c1             	mov    %rax,%rcx
  8041604115:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  8041604119:	48 39 f9             	cmp    %rdi,%rcx
  804160411c:	0f 97 c1             	seta   %cl
  804160411f:	48 39 f8             	cmp    %rdi,%rax
  8041604122:	0f 96 c0             	setbe  %al
  8041604125:	84 c1                	test   %al,%cl
  8041604127:	74 d9                	je     8041604102 <is_page_allocatable+0x5b>
      switch (mmap_curr->Type) {
  8041604129:	8b 0a                	mov    (%rdx),%ecx
  804160412b:	85 c9                	test   %ecx,%ecx
  804160412d:	74 33                	je     8041604162 <is_page_allocatable+0xbb>
  804160412f:	83 f9 04             	cmp    $0x4,%ecx
  8041604132:	76 0a                	jbe    804160413e <is_page_allocatable+0x97>
          return false;
  8041604134:	b8 00 00 00 00       	mov    $0x0,%eax
      switch (mmap_curr->Type) {
  8041604139:	83 f9 07             	cmp    $0x7,%ecx
  804160413c:	75 29                	jne    8041604167 <is_page_allocatable+0xc0>
          if (mmap_curr->Attribute & EFI_MEMORY_WB)
  804160413e:	48 8b 42 20          	mov    0x20(%rdx),%rax
  8041604142:	48 c1 e8 03          	shr    $0x3,%rax
  8041604146:	83 e0 01             	and    $0x1,%eax
  8041604149:	c3                   	retq   
  return true;
  804160414a:	b8 01 00 00 00       	mov    $0x1,%eax
  804160414f:	c3                   	retq   
    return true; //Assume page is allocabale if no loading parameters were passed.
  8041604150:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604155:	c3                   	retq   
  8041604156:	b8 01 00 00 00       	mov    $0x1,%eax
  804160415b:	c3                   	retq   
  return true;
  804160415c:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604161:	c3                   	retq   
          return false;
  8041604162:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041604167:	c3                   	retq   

0000008041604168 <page_init>:
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void) {
  8041604168:	55                   	push   %rbp
  8041604169:	48 89 e5             	mov    %rsp,%rbp
  804160416c:	41 57                	push   %r15
  804160416e:	41 56                	push   %r14
  8041604170:	41 55                	push   %r13
  8041604172:	41 54                	push   %r12
  8041604174:	53                   	push   %rbx
  8041604175:	48 83 ec 08          	sub    $0x8,%rsp
  size_t i;
  uintptr_t first_free_page;
  struct PageInfo *last = NULL;

  //Mark physical page 0 as in use.
  pages[0].pp_ref  = 1;
  8041604179:	48 b8 58 c0 61 41 80 	movabs $0x804161c058,%rax
  8041604180:	00 00 00 
  8041604183:	48 8b 10             	mov    (%rax),%rdx
  8041604186:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
  pages[0].pp_link = NULL;
  804160418c:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)

  //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
  //     is free.
  pages[2].pp_ref = 0;
  8041604193:	4c 8b 20             	mov    (%rax),%r12
  8041604196:	66 41 c7 44 24 28 00 	movw   $0x0,0x28(%r12)
  804160419d:	00 
  page_free_list  = &pages[2];
  804160419e:	49 83 c4 20          	add    $0x20,%r12
  80416041a2:	4c 89 e0             	mov    %r12,%rax
  80416041a5:	48 a3 88 ab 61 41 80 	movabs %rax,0x804161ab88
  80416041ac:	00 00 00 
  last            = &pages[2];
  for (i = 2; i < npages_basemem; i++) {
  80416041af:	48 b8 90 ab 61 41 80 	movabs $0x804161ab90,%rax
  80416041b6:	00 00 00 
  80416041b9:	48 83 38 02          	cmpq   $0x2,(%rax)
  80416041bd:	76 6a                	jbe    8041604229 <page_init+0xc1>
  80416041bf:	bb 02 00 00 00       	mov    $0x2,%ebx
    if (is_page_allocatable(i)) {
  80416041c4:	49 bf a7 40 60 41 80 	movabs $0x80416040a7,%r15
  80416041cb:	00 00 00 
      pages[i].pp_ref = 0;
      last->pp_link   = &pages[i];
      last            = &pages[i];
    } else {
      pages[i].pp_ref  = 1;
  80416041ce:	49 bd 58 c0 61 41 80 	movabs $0x804161c058,%r13
  80416041d5:	00 00 00 
  for (i = 2; i < npages_basemem; i++) {
  80416041d8:	49 89 c6             	mov    %rax,%r14
  80416041db:	eb 21                	jmp    80416041fe <page_init+0x96>
      pages[i].pp_ref  = 1;
  80416041dd:	48 89 d8             	mov    %rbx,%rax
  80416041e0:	48 c1 e0 04          	shl    $0x4,%rax
  80416041e4:	49 03 45 00          	add    0x0(%r13),%rax
  80416041e8:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  80416041ee:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = 2; i < npages_basemem; i++) {
  80416041f5:	48 83 c3 01          	add    $0x1,%rbx
  80416041f9:	49 39 1e             	cmp    %rbx,(%r14)
  80416041fc:	76 2b                	jbe    8041604229 <page_init+0xc1>
    if (is_page_allocatable(i)) {
  80416041fe:	48 89 df             	mov    %rbx,%rdi
  8041604201:	41 ff d7             	callq  *%r15
  8041604204:	84 c0                	test   %al,%al
  8041604206:	74 d5                	je     80416041dd <page_init+0x75>
      pages[i].pp_ref = 0;
  8041604208:	48 89 d8             	mov    %rbx,%rax
  804160420b:	48 c1 e0 04          	shl    $0x4,%rax
  804160420f:	48 89 c2             	mov    %rax,%rdx
  8041604212:	49 03 55 00          	add    0x0(%r13),%rdx
  8041604216:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  804160421c:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  8041604220:	49 03 45 00          	add    0x0(%r13),%rax
  8041604224:	49 89 c4             	mov    %rax,%r12
  8041604227:	eb cc                	jmp    80416041f5 <page_init+0x8d>
    }
  }

  //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
  //     never be allocated.
  first_free_page = PADDR(boot_alloc(0)) / PGSIZE;
  8041604229:	bf 00 00 00 00       	mov    $0x0,%edi
  804160422e:	48 b8 bf 3f 60 41 80 	movabs $0x8041603fbf,%rax
  8041604235:	00 00 00 
  8041604238:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  804160423a:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041604241:	00 00 00 
  8041604244:	48 39 d0             	cmp    %rdx,%rax
  8041604247:	76 7d                	jbe    80416042c6 <page_init+0x15e>
  return (physaddr_t)kva - KERNBASE;
  8041604249:	48 bb 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rbx
  8041604250:	ff ff ff 
  8041604253:	48 01 c3             	add    %rax,%rbx
  8041604256:	48 c1 eb 0c          	shr    $0xc,%rbx
  for (i = npages_basemem; i < first_free_page; i++) {
  804160425a:	48 a1 90 ab 61 41 80 	movabs 0x804161ab90,%rax
  8041604261:	00 00 00 
  8041604264:	48 39 c3             	cmp    %rax,%rbx
  8041604267:	76 31                	jbe    804160429a <page_init+0x132>
  8041604269:	48 c1 e0 04          	shl    $0x4,%rax
  804160426d:	48 89 de             	mov    %rbx,%rsi
  8041604270:	48 c1 e6 04          	shl    $0x4,%rsi
    pages[i].pp_ref  = 1;
  8041604274:	48 b9 58 c0 61 41 80 	movabs $0x804161c058,%rcx
  804160427b:	00 00 00 
  804160427e:	48 89 c2             	mov    %rax,%rdx
  8041604281:	48 03 11             	add    (%rcx),%rdx
  8041604284:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
    pages[i].pp_link = NULL;
  804160428a:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  for (i = npages_basemem; i < first_free_page; i++) {
  8041604291:	48 83 c0 10          	add    $0x10,%rax
  8041604295:	48 39 f0             	cmp    %rsi,%rax
  8041604298:	75 e4                	jne    804160427e <page_init+0x116>
  }

  //     Some of it is in use, some is free. Where is the kernel
  //     in physical memory?  Which pages are already in use for
  //     page tables and other data structures?
  for (i = first_free_page; i < npages; i++) {
  804160429a:	48 b8 50 c0 61 41 80 	movabs $0x804161c050,%rax
  80416042a1:	00 00 00 
  80416042a4:	48 3b 18             	cmp    (%rax),%rbx
  80416042a7:	0f 83 93 00 00 00    	jae    8041604340 <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  80416042ad:	49 bf a7 40 60 41 80 	movabs $0x80416040a7,%r15
  80416042b4:	00 00 00 
      pages[i].pp_ref = 0;
      last->pp_link   = &pages[i];
      last            = &pages[i];
    } else {
      pages[i].pp_ref  = 1;
  80416042b7:	49 bd 58 c0 61 41 80 	movabs $0x804161c058,%r13
  80416042be:	00 00 00 
  for (i = first_free_page; i < npages; i++) {
  80416042c1:	49 89 c6             	mov    %rax,%r14
  80416042c4:	eb 4f                	jmp    8041604315 <page_init+0x1ad>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416042c6:	48 89 c1             	mov    %rax,%rcx
  80416042c9:	48 ba c0 8d 60 41 80 	movabs $0x8041608dc0,%rdx
  80416042d0:	00 00 00 
  80416042d3:	be 5f 01 00 00       	mov    $0x15f,%esi
  80416042d8:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416042df:	00 00 00 
  80416042e2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416042e7:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416042ee:	00 00 00 
  80416042f1:	41 ff d0             	callq  *%r8
      pages[i].pp_ref  = 1;
  80416042f4:	48 89 d8             	mov    %rbx,%rax
  80416042f7:	48 c1 e0 04          	shl    $0x4,%rax
  80416042fb:	49 03 45 00          	add    0x0(%r13),%rax
  80416042ff:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  8041604305:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = first_free_page; i < npages; i++) {
  804160430c:	48 83 c3 01          	add    $0x1,%rbx
  8041604310:	49 39 1e             	cmp    %rbx,(%r14)
  8041604313:	76 2b                	jbe    8041604340 <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  8041604315:	48 89 df             	mov    %rbx,%rdi
  8041604318:	41 ff d7             	callq  *%r15
  804160431b:	84 c0                	test   %al,%al
  804160431d:	74 d5                	je     80416042f4 <page_init+0x18c>
      pages[i].pp_ref = 0;
  804160431f:	48 89 d8             	mov    %rbx,%rax
  8041604322:	48 c1 e0 04          	shl    $0x4,%rax
  8041604326:	48 89 c2             	mov    %rax,%rdx
  8041604329:	49 03 55 00          	add    0x0(%r13),%rdx
  804160432d:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  8041604333:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  8041604337:	49 03 45 00          	add    0x0(%r13),%rax
  804160433b:	49 89 c4             	mov    %rax,%r12
  804160433e:	eb cc                	jmp    804160430c <page_init+0x1a4>
    }
  }
}
  8041604340:	48 83 c4 08          	add    $0x8,%rsp
  8041604344:	5b                   	pop    %rbx
  8041604345:	41 5c                	pop    %r12
  8041604347:	41 5d                	pop    %r13
  8041604349:	41 5e                	pop    %r14
  804160434b:	41 5f                	pop    %r15
  804160434d:	5d                   	pop    %rbp
  804160434e:	c3                   	retq   

000000804160434f <page_alloc>:
//
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags) {
  804160434f:	55                   	push   %rbp
  8041604350:	48 89 e5             	mov    %rsp,%rbp
  8041604353:	53                   	push   %rbx
  8041604354:	48 83 ec 08          	sub    $0x8,%rsp

  // ne memory check
  if (!page_free_list) {
  8041604358:	48 b8 88 ab 61 41 80 	movabs $0x804161ab88,%rax
  804160435f:	00 00 00 
  8041604362:	48 8b 18             	mov    (%rax),%rbx
  8041604365:	48 85 db             	test   %rbx,%rbx
  8041604368:	74 1f                	je     8041604389 <page_alloc+0x3a>
    return NULL;
  }

  struct PageInfo *return_page = page_free_list;
  page_free_list               = page_free_list->pp_link;
  804160436a:	48 8b 03             	mov    (%rbx),%rax
  804160436d:	48 a3 88 ab 61 41 80 	movabs %rax,0x804161ab88
  8041604374:	00 00 00 
  return_page->pp_link         = NULL;
  8041604377:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)

  if (!page_free_list) {
  804160437e:	48 85 c0             	test   %rax,%rax
  8041604381:	74 10                	je     8041604393 <page_alloc+0x44>
  // Unpoison allocated memory before accessing it!
  platform_asan_unpoison(page2kva(return_page), PGSIZE);

#endif

  if (alloc_flags & ALLOC_ZERO) {
  8041604383:	40 f6 c7 01          	test   $0x1,%dil
  8041604387:	75 1d                	jne    80416043a6 <page_alloc+0x57>
    memset(page2kva(return_page), 0, PGSIZE);
  }

  return return_page;
}
  8041604389:	48 89 d8             	mov    %rbx,%rax
  804160438c:	48 83 c4 08          	add    $0x8,%rsp
  8041604390:	5b                   	pop    %rbx
  8041604391:	5d                   	pop    %rbp
  8041604392:	c3                   	retq   
    page_free_list_top = NULL;
  8041604393:	48 b8 80 ab 61 41 80 	movabs $0x804161ab80,%rax
  804160439a:	00 00 00 
  804160439d:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  80416043a4:	eb dd                	jmp    8041604383 <page_alloc+0x34>

static void check_page_free_list(bool only_low_memory);

static inline physaddr_t
page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
  80416043a6:	48 b8 58 c0 61 41 80 	movabs $0x804161c058,%rax
  80416043ad:	00 00 00 
  80416043b0:	48 89 df             	mov    %rbx,%rdi
  80416043b3:	48 2b 38             	sub    (%rax),%rdi
  80416043b6:	48 c1 ff 04          	sar    $0x4,%rdi
  80416043ba:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  80416043be:	48 89 fa             	mov    %rdi,%rdx
  80416043c1:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416043c5:	48 b8 50 c0 61 41 80 	movabs $0x804161c050,%rax
  80416043cc:	00 00 00 
  80416043cf:	48 3b 10             	cmp    (%rax),%rdx
  80416043d2:	73 25                	jae    80416043f9 <page_alloc+0xaa>
  return (void *)(pa + KERNBASE);
  80416043d4:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  80416043db:	00 00 00 
  80416043de:	48 01 cf             	add    %rcx,%rdi
    memset(page2kva(return_page), 0, PGSIZE);
  80416043e1:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416043e6:	be 00 00 00 00       	mov    $0x0,%esi
  80416043eb:	48 b8 b0 7b 60 41 80 	movabs $0x8041607bb0,%rax
  80416043f2:	00 00 00 
  80416043f5:	ff d0                	callq  *%rax
  80416043f7:	eb 90                	jmp    8041604389 <page_alloc+0x3a>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416043f9:	48 89 f9             	mov    %rdi,%rcx
  80416043fc:	48 ba 10 8e 60 41 80 	movabs $0x8041608e10,%rdx
  8041604403:	00 00 00 
  8041604406:	be 5e 00 00 00       	mov    $0x5e,%esi
  804160440b:	48 bf 33 90 60 41 80 	movabs $0x8041609033,%rdi
  8041604412:	00 00 00 
  8041604415:	b8 00 00 00 00       	mov    $0x0,%eax
  804160441a:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604421:	00 00 00 
  8041604424:	41 ff d0             	callq  *%r8

0000008041604427 <page_is_allocated>:

int
page_is_allocated(const struct PageInfo *pp) {
  return !pp->pp_link && pp != page_free_list_top;
  8041604427:	b8 00 00 00 00       	mov    $0x0,%eax
  804160442c:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604430:	74 01                	je     8041604433 <page_is_allocated+0xc>
}
  8041604432:	c3                   	retq   
  return !pp->pp_link && pp != page_free_list_top;
  8041604433:	48 b8 80 ab 61 41 80 	movabs $0x804161ab80,%rax
  804160443a:	00 00 00 
  804160443d:	48 39 38             	cmp    %rdi,(%rax)
  8041604440:	0f 95 c0             	setne  %al
  8041604443:	0f b6 c0             	movzbl %al,%eax
  8041604446:	eb ea                	jmp    8041604432 <page_is_allocated+0xb>

0000008041604448 <page_free>:
//
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp) {
  8041604448:	55                   	push   %rbp
  8041604449:	48 89 e5             	mov    %rsp,%rbp
  // LAB 6: Fill this function in
  // Hint: You may want to panic if pp->pp_ref is nonzero or
  // pp->pp_link is not NULL.

  if (pp->pp_ref) {
  804160444c:	66 83 7f 08 00       	cmpw   $0x0,0x8(%rdi)
  8041604451:	75 2b                	jne    804160447e <page_free+0x36>
		panic("page_free: Page is still referenced!\n");
  }

  if (pp->pp_link) {
  8041604453:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604457:	75 4f                	jne    80416044a8 <page_free+0x60>
	}

  if (pp->pp_ref != 0 || pp->pp_link != NULL)
    panic("page_free: Page cannot be freed!\n");

  pp->pp_link    = page_free_list;
  8041604459:	48 b8 88 ab 61 41 80 	movabs $0x804161ab88,%rax
  8041604460:	00 00 00 
  8041604463:	48 8b 10             	mov    (%rax),%rdx
  8041604466:	48 89 17             	mov    %rdx,(%rdi)
  page_free_list = pp;
  8041604469:	48 89 38             	mov    %rdi,(%rax)
  
  if (!page_free_list_top) {
  804160446c:	48 b8 80 ab 61 41 80 	movabs $0x804161ab80,%rax
  8041604473:	00 00 00 
  8041604476:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160447a:	74 56                	je     80416044d2 <page_free+0x8a>
    page_free_list_top = pp;
  }

}
  804160447c:	5d                   	pop    %rbp
  804160447d:	c3                   	retq   
		panic("page_free: Page is still referenced!\n");
  804160447e:	48 ba 30 8e 60 41 80 	movabs $0x8041608e30,%rdx
  8041604485:	00 00 00 
  8041604488:	be b3 01 00 00       	mov    $0x1b3,%esi
  804160448d:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604494:	00 00 00 
  8041604497:	b8 00 00 00 00       	mov    $0x0,%eax
  804160449c:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  80416044a3:	00 00 00 
  80416044a6:	ff d1                	callq  *%rcx
	    panic("page_free: Page is already freed!\n");
  80416044a8:	48 ba 58 8e 60 41 80 	movabs $0x8041608e58,%rdx
  80416044af:	00 00 00 
  80416044b2:	be b7 01 00 00       	mov    $0x1b7,%esi
  80416044b7:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416044be:	00 00 00 
  80416044c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044c6:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  80416044cd:	00 00 00 
  80416044d0:	ff d1                	callq  *%rcx
    page_free_list_top = pp;
  80416044d2:	48 89 f8             	mov    %rdi,%rax
  80416044d5:	48 a3 80 ab 61 41 80 	movabs %rax,0x804161ab80
  80416044dc:	00 00 00 
}
  80416044df:	eb 9b                	jmp    804160447c <page_free+0x34>

00000080416044e1 <mem_init>:
mem_init(void) {
  80416044e1:	55                   	push   %rbp
  80416044e2:	48 89 e5             	mov    %rsp,%rbp
  80416044e5:	41 57                	push   %r15
  80416044e7:	41 56                	push   %r14
  80416044e9:	41 55                	push   %r13
  80416044eb:	41 54                	push   %r12
  80416044ed:	53                   	push   %rbx
  80416044ee:	48 83 ec 38          	sub    $0x38,%rsp
  if (uefi_lp && uefi_lp->MemoryMap) {
  80416044f2:	48 b8 00 a0 61 41 80 	movabs $0x804161a000,%rax
  80416044f9:	00 00 00 
  80416044fc:	48 8b 10             	mov    (%rax),%rdx
  80416044ff:	48 85 d2             	test   %rdx,%rdx
  8041604502:	74 0d                	je     8041604511 <mem_init+0x30>
  8041604504:	48 8b 4a 28          	mov    0x28(%rdx),%rcx
  8041604508:	48 85 c9             	test   %rcx,%rcx
  804160450b:	0f 85 6f 02 00 00    	jne    8041604780 <mem_init+0x29f>
    npages_basemem = (mc146818_read16(NVRAM_BASELO) * 1024) / PGSIZE;
  8041604511:	bf 15 00 00 00       	mov    $0x15,%edi
  8041604516:	49 bc 65 58 60 41 80 	movabs $0x8041605865,%r12
  804160451d:	00 00 00 
  8041604520:	41 ff d4             	callq  *%r12
  8041604523:	c1 e0 0a             	shl    $0xa,%eax
  8041604526:	c1 e8 0c             	shr    $0xc,%eax
  8041604529:	48 ba 90 ab 61 41 80 	movabs $0x804161ab90,%rdx
  8041604530:	00 00 00 
  8041604533:	89 c0                	mov    %eax,%eax
  8041604535:	48 89 02             	mov    %rax,(%rdx)
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  8041604538:	bf 17 00 00 00       	mov    $0x17,%edi
  804160453d:	41 ff d4             	callq  *%r12
  8041604540:	89 c3                	mov    %eax,%ebx
    pextmem        = ((size_t)mc146818_read16(NVRAM_PEXTLO) * 1024 * 64);
  8041604542:	bf 34 00 00 00       	mov    $0x34,%edi
  8041604547:	41 ff d4             	callq  *%r12
  804160454a:	89 c1                	mov    %eax,%ecx
    if (pextmem)
  804160454c:	48 c1 e1 10          	shl    $0x10,%rcx
  8041604550:	0f 84 a1 02 00 00    	je     80416047f7 <mem_init+0x316>
      npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  8041604556:	48 81 c1 00 00 f0 00 	add    $0xf00000,%rcx
  804160455d:	48 c1 e9 0c          	shr    $0xc,%rcx
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  8041604561:	48 8d 81 00 01 00 00 	lea    0x100(%rcx),%rax
  8041604568:	48 a3 50 c0 61 41 80 	movabs %rax,0x804161c050
  804160456f:	00 00 00 
          (unsigned long)(npages_extmem * PGSIZE / 1024));
  8041604572:	48 c1 e1 0c          	shl    $0xc,%rcx
  8041604576:	48 c1 e9 0a          	shr    $0xa,%rcx
          (unsigned long)(npages_basemem * PGSIZE / 1024),
  804160457a:	48 be 90 ab 61 41 80 	movabs $0x804161ab90,%rsi
  8041604581:	00 00 00 
  8041604584:	48 8b 16             	mov    (%rsi),%rdx
  8041604587:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160458b:	48 c1 ea 0a          	shr    $0xa,%rdx
          (unsigned long)(npages * PGSIZE / 1024 / 1024),
  804160458f:	48 c1 e0 0c          	shl    $0xc,%rax
  8041604593:	48 c1 e8 14          	shr    $0x14,%rax
  8041604597:	48 89 c6             	mov    %rax,%rsi
  cprintf("Physical memory: %luM available, base = %luK, extended = %luK\n",
  804160459a:	48 bf 80 8e 60 41 80 	movabs $0x8041608e80,%rdi
  80416045a1:	00 00 00 
  80416045a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045a9:	49 b8 6a 5a 60 41 80 	movabs $0x8041605a6a,%r8
  80416045b0:	00 00 00 
  80416045b3:	41 ff d0             	callq  *%r8
  pml4e = boot_alloc(PGSIZE);
  80416045b6:	bf 00 10 00 00       	mov    $0x1000,%edi
  80416045bb:	48 b8 bf 3f 60 41 80 	movabs $0x8041603fbf,%rax
  80416045c2:	00 00 00 
  80416045c5:	ff d0                	callq  *%rax
  80416045c7:	48 89 c3             	mov    %rax,%rbx
  memset(pml4e, 0, PGSIZE);
  80416045ca:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416045cf:	be 00 00 00 00       	mov    $0x0,%esi
  80416045d4:	48 89 c7             	mov    %rax,%rdi
  80416045d7:	48 b8 b0 7b 60 41 80 	movabs $0x8041607bb0,%rax
  80416045de:	00 00 00 
  80416045e1:	ff d0                	callq  *%rax
  kern_pml4e = pml4e;
  80416045e3:	48 89 d8             	mov    %rbx,%rax
  80416045e6:	48 a3 40 c0 61 41 80 	movabs %rax,0x804161c040
  80416045ed:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  80416045f0:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  80416045f7:	00 00 00 
  80416045fa:	48 39 c3             	cmp    %rax,%rbx
  80416045fd:	0f 86 14 02 00 00    	jbe    8041604817 <mem_init+0x336>
  return (physaddr_t)kva - KERNBASE;
  8041604603:	48 b8 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rax
  804160460a:	ff ff ff 
  804160460d:	48 01 d8             	add    %rbx,%rax
  kern_cr3   = PADDR(pml4e);
  8041604610:	48 a3 48 c0 61 41 80 	movabs %rax,0x804161c048
  8041604617:	00 00 00 
  kern_pml4e[PML4(UVPT)] = kern_cr3 | PTE_P | PTE_U;
  804160461a:	48 83 c8 05          	or     $0x5,%rax
  804160461e:	48 89 43 10          	mov    %rax,0x10(%rbx)
  pages = (struct PageInfo *) boot_alloc(sizeof(*pages) * npages);
  8041604622:	48 bb 50 c0 61 41 80 	movabs $0x804161c050,%rbx
  8041604629:	00 00 00 
  804160462c:	8b 3b                	mov    (%rbx),%edi
  804160462e:	c1 e7 04             	shl    $0x4,%edi
  8041604631:	48 b8 bf 3f 60 41 80 	movabs $0x8041603fbf,%rax
  8041604638:	00 00 00 
  804160463b:	ff d0                	callq  *%rax
  804160463d:	48 a3 58 c0 61 41 80 	movabs %rax,0x804161c058
  8041604644:	00 00 00 
	memset(pages, 0, sizeof(*pages) * npages);
  8041604647:	48 8b 13             	mov    (%rbx),%rdx
  804160464a:	48 c1 e2 04          	shl    $0x4,%rdx
  804160464e:	be 00 00 00 00       	mov    $0x0,%esi
  8041604653:	48 89 c7             	mov    %rax,%rdi
  8041604656:	48 b8 b0 7b 60 41 80 	movabs $0x8041607bb0,%rax
  804160465d:	00 00 00 
  8041604660:	ff d0                	callq  *%rax
  page_init();
  8041604662:	48 b8 68 41 60 41 80 	movabs $0x8041604168,%rax
  8041604669:	00 00 00 
  804160466c:	ff d0                	callq  *%rax
  struct PageInfo *pp;
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  int nfree_basemem = 0, nfree_extmem = 0;
  char *first_free_page;

  if (!page_free_list)
  804160466e:	48 a1 88 ab 61 41 80 	movabs 0x804161ab88,%rax
  8041604675:	00 00 00 
  8041604678:	48 85 c0             	test   %rax,%rax
  804160467b:	0f 84 c4 01 00 00    	je     8041604845 <mem_init+0x364>

  if (only_low_memory) {
    // Move pages with lower addresses first in the free
    // list, since entry_pgdir does not map all pages.
    struct PageInfo *pp1, *pp2;
    struct PageInfo **tp[2] = {&pp1, &pp2};
  8041604681:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  8041604685:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041604689:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  804160468d:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  return (pp - pages) << PGSHIFT;
  8041604691:	48 be 58 c0 61 41 80 	movabs $0x804161c058,%rsi
  8041604698:	00 00 00 
  804160469b:	48 89 c2             	mov    %rax,%rdx
  804160469e:	48 2b 16             	sub    (%rsi),%rdx
  80416046a1:	48 c1 e2 08          	shl    $0x8,%rdx
    for (pp = page_free_list; pp; pp = pp->pp_link) {
      int pagetype  = VPN(page2pa(pp)) >= pdx_limit;
  80416046a5:	48 c1 ea 0c          	shr    $0xc,%rdx
      *tp[pagetype] = pp;
  80416046a9:	0f 95 c2             	setne  %dl
  80416046ac:	0f b6 d2             	movzbl %dl,%edx
  80416046af:	48 8b 4c d5 c0       	mov    -0x40(%rbp,%rdx,8),%rcx
  80416046b4:	48 89 01             	mov    %rax,(%rcx)
      tp[pagetype]  = &pp->pp_link;
  80416046b7:	48 89 44 d5 c0       	mov    %rax,-0x40(%rbp,%rdx,8)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  80416046bc:	48 8b 00             	mov    (%rax),%rax
  80416046bf:	48 85 c0             	test   %rax,%rax
  80416046c2:	75 d7                	jne    804160469b <mem_init+0x1ba>
    }
    *tp[1]         = 0;
  80416046c4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80416046c8:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    *tp[0]         = pp2;
  80416046cf:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80416046d3:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416046d7:	48 89 10             	mov    %rdx,(%rax)
    page_free_list = pp1;
  80416046da:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  80416046de:	48 89 d8             	mov    %rbx,%rax
  80416046e1:	48 a3 88 ab 61 41 80 	movabs %rax,0x804161ab88
  80416046e8:	00 00 00 
			memset(page2kva(pp), 0x97, 128);
#endif
		}
	}*/

  first_free_page = (char *)boot_alloc(0);
  80416046eb:	bf 00 00 00 00       	mov    $0x0,%edi
  80416046f0:	48 b8 bf 3f 60 41 80 	movabs $0x8041603fbf,%rax
  80416046f7:	00 00 00 
  80416046fa:	ff d0                	callq  *%rax
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  80416046fc:	48 85 db             	test   %rbx,%rbx
  80416046ff:	0f 84 f4 06 00 00    	je     8041604df9 <mem_init+0x918>
    // check that we didn't corrupt the free list itself
    assert(pp >= pages);
  8041604705:	48 be 58 c0 61 41 80 	movabs $0x804161c058,%rsi
  804160470c:	00 00 00 
  804160470f:	48 8b 3e             	mov    (%rsi),%rdi
  8041604712:	48 39 fb             	cmp    %rdi,%rbx
  8041604715:	0f 82 4f 01 00 00    	jb     804160486a <mem_init+0x389>
    assert(pp < pages + npages);
  804160471b:	48 be 50 c0 61 41 80 	movabs $0x804161c050,%rsi
  8041604722:	00 00 00 
  8041604725:	4c 8b 16             	mov    (%rsi),%r10
  8041604728:	4d 89 d0             	mov    %r10,%r8
  804160472b:	49 c1 e0 04          	shl    $0x4,%r8
  804160472f:	49 01 f8             	add    %rdi,%r8
  8041604732:	49 39 d8             	cmp    %rbx,%r8
  8041604735:	0f 86 64 01 00 00    	jbe    804160489f <mem_init+0x3be>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  804160473b:	48 89 d9             	mov    %rbx,%rcx
  804160473e:	48 29 f9             	sub    %rdi,%rcx
  8041604741:	f6 c1 0f             	test   $0xf,%cl
  8041604744:	0f 85 8a 01 00 00    	jne    80416048d4 <mem_init+0x3f3>
  804160474a:	48 c1 f9 04          	sar    $0x4,%rcx
  804160474e:	48 c1 e1 0c          	shl    $0xc,%rcx
  8041604752:	48 89 ca             	mov    %rcx,%rdx

    // check a few pages that shouldn't be on the free list
    assert(page2pa(pp) != 0);
  8041604755:	0f 84 ae 01 00 00    	je     8041604909 <mem_init+0x428>
    assert(page2pa(pp) != IOPHYSMEM);
  804160475b:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  8041604762:	0f 84 d6 01 00 00    	je     804160493e <mem_init+0x45d>
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604768:	48 89 de             	mov    %rbx,%rsi
  int nfree_basemem = 0, nfree_extmem = 0;
  804160476b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  return (void *)(pa + KERNBASE);
  8041604771:	49 bc 00 00 00 40 80 	movabs $0x8040000000,%r12
  8041604778:	00 00 00 
  804160477b:	e9 d7 02 00 00       	jmpq   8041604a57 <mem_init+0x576>
  mem_map_size     = desc->MemoryMapDescriptorSize;
  8041604780:	48 8b 72 20          	mov    0x20(%rdx),%rsi
  8041604784:	48 89 f0             	mov    %rsi,%rax
  8041604787:	48 a3 60 ab 61 41 80 	movabs %rax,0x804161ab60
  804160478e:	00 00 00 
  mmap_base        = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)desc->MemoryMap;
  8041604791:	48 89 c8             	mov    %rcx,%rax
  8041604794:	48 89 cf             	mov    %rcx,%rdi
  8041604797:	48 a3 70 ab 61 41 80 	movabs %rax,0x804161ab70
  804160479e:	00 00 00 
  mmap_end         = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)desc->MemoryMap + desc->MemoryMapSize);
  80416047a1:	48 89 cb             	mov    %rcx,%rbx
  80416047a4:	48 03 5a 38          	add    0x38(%rdx),%rbx
  80416047a8:	48 89 da             	mov    %rbx,%rdx
  80416047ab:	48 89 d8             	mov    %rbx,%rax
  80416047ae:	48 a3 68 ab 61 41 80 	movabs %rax,0x804161ab68
  80416047b5:	00 00 00 
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047b8:	48 39 d9             	cmp    %rbx,%rcx
  80416047bb:	73 33                	jae    80416047f0 <mem_init+0x30f>
  size_t num_pages = 0;
  80416047bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416047c2:	48 89 f8             	mov    %rdi,%rax
    num_pages += mmap_curr->NumberOfPages;
  80416047c5:	48 03 48 18          	add    0x18(%rax),%rcx
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047c9:	48 01 f0             	add    %rsi,%rax
  80416047cc:	48 39 c2             	cmp    %rax,%rdx
  80416047cf:	77 f4                	ja     80416047c5 <mem_init+0x2e4>
  *npages_basemem = num_pages > (IOPHYSMEM / PGSIZE) ? IOPHYSMEM / PGSIZE : num_pages;
  80416047d1:	48 81 f9 a0 00 00 00 	cmp    $0xa0,%rcx
  80416047d8:	b8 a0 00 00 00       	mov    $0xa0,%eax
  80416047dd:	48 0f 46 c1          	cmovbe %rcx,%rax
  80416047e1:	48 a3 90 ab 61 41 80 	movabs %rax,0x804161ab90
  80416047e8:	00 00 00 
  *npages_extmem  = num_pages - *npages_basemem;
  80416047eb:	48 29 c1             	sub    %rax,%rcx
  80416047ee:	eb 0f                	jmp    80416047ff <mem_init+0x31e>
  size_t num_pages = 0;
  80416047f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416047f5:	eb da                	jmp    80416047d1 <mem_init+0x2f0>
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  80416047f7:	c1 e3 0a             	shl    $0xa,%ebx
  80416047fa:	c1 eb 0c             	shr    $0xc,%ebx
  80416047fd:	89 d9                	mov    %ebx,%ecx
    npages = npages_basemem;
  80416047ff:	48 a1 90 ab 61 41 80 	movabs 0x804161ab90,%rax
  8041604806:	00 00 00 
  if (npages_extmem)
  8041604809:	48 85 c9             	test   %rcx,%rcx
  804160480c:	0f 84 56 fd ff ff    	je     8041604568 <mem_init+0x87>
  8041604812:	e9 4a fd ff ff       	jmpq   8041604561 <mem_init+0x80>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041604817:	48 89 d9             	mov    %rbx,%rcx
  804160481a:	48 ba c0 8d 60 41 80 	movabs $0x8041608dc0,%rdx
  8041604821:	00 00 00 
  8041604824:	be de 00 00 00       	mov    $0xde,%esi
  8041604829:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604830:	00 00 00 
  8041604833:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604838:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160483f:	00 00 00 
  8041604842:	41 ff d0             	callq  *%r8
    panic("'page_free_list' is a null pointer!");
  8041604845:	48 ba c0 8e 60 41 80 	movabs $0x8041608ec0,%rdx
  804160484c:	00 00 00 
  804160484f:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041604854:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  804160485b:	00 00 00 
  804160485e:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  8041604865:	00 00 00 
  8041604868:	ff d1                	callq  *%rcx
    assert(pp >= pages);
  804160486a:	48 b9 41 90 60 41 80 	movabs $0x8041609041,%rcx
  8041604871:	00 00 00 
  8041604874:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160487b:	00 00 00 
  804160487e:	be ad 02 00 00       	mov    $0x2ad,%esi
  8041604883:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  804160488a:	00 00 00 
  804160488d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604892:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604899:	00 00 00 
  804160489c:	41 ff d0             	callq  *%r8
    assert(pp < pages + npages);
  804160489f:	48 b9 4d 90 60 41 80 	movabs $0x804160904d,%rcx
  80416048a6:	00 00 00 
  80416048a9:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416048b0:	00 00 00 
  80416048b3:	be ae 02 00 00       	mov    $0x2ae,%esi
  80416048b8:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416048bf:	00 00 00 
  80416048c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416048c7:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416048ce:	00 00 00 
  80416048d1:	41 ff d0             	callq  *%r8
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416048d4:	48 b9 e8 8e 60 41 80 	movabs $0x8041608ee8,%rcx
  80416048db:	00 00 00 
  80416048de:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416048e5:	00 00 00 
  80416048e8:	be af 02 00 00       	mov    $0x2af,%esi
  80416048ed:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416048f4:	00 00 00 
  80416048f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416048fc:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604903:	00 00 00 
  8041604906:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != 0);
  8041604909:	48 b9 61 90 60 41 80 	movabs $0x8041609061,%rcx
  8041604910:	00 00 00 
  8041604913:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160491a:	00 00 00 
  804160491d:	be b2 02 00 00       	mov    $0x2b2,%esi
  8041604922:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604929:	00 00 00 
  804160492c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604931:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604938:	00 00 00 
  804160493b:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != IOPHYSMEM);
  804160493e:	48 b9 72 90 60 41 80 	movabs $0x8041609072,%rcx
  8041604945:	00 00 00 
  8041604948:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160494f:	00 00 00 
  8041604952:	be b3 02 00 00       	mov    $0x2b3,%esi
  8041604957:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  804160495e:	00 00 00 
  8041604961:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604966:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160496d:	00 00 00 
  8041604970:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  8041604973:	48 b9 18 8f 60 41 80 	movabs $0x8041608f18,%rcx
  804160497a:	00 00 00 
  804160497d:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604984:	00 00 00 
  8041604987:	be b4 02 00 00       	mov    $0x2b4,%esi
  804160498c:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604993:	00 00 00 
  8041604996:	b8 00 00 00 00       	mov    $0x0,%eax
  804160499b:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416049a2:	00 00 00 
  80416049a5:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM);
  80416049a8:	48 b9 8b 90 60 41 80 	movabs $0x804160908b,%rcx
  80416049af:	00 00 00 
  80416049b2:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416049b9:	00 00 00 
  80416049bc:	be b5 02 00 00       	mov    $0x2b5,%esi
  80416049c1:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416049c8:	00 00 00 
  80416049cb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416049d0:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416049d7:	00 00 00 
  80416049da:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416049dd:	48 ba 10 8e 60 41 80 	movabs $0x8041608e10,%rdx
  80416049e4:	00 00 00 
  80416049e7:	be 5e 00 00 00       	mov    $0x5e,%esi
  80416049ec:	48 bf 33 90 60 41 80 	movabs $0x8041609033,%rdi
  80416049f3:	00 00 00 
  80416049f6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416049fb:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604a02:	00 00 00 
  8041604a05:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);

    if (page2pa(pp) < EXTPHYSMEM)
      ++nfree_basemem;
    else
      ++nfree_extmem;
  8041604a08:	41 83 c1 01          	add    $0x1,%r9d
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604a0c:	48 8b 36             	mov    (%rsi),%rsi
  8041604a0f:	48 85 f6             	test   %rsi,%rsi
  8041604a12:	0f 84 b3 00 00 00    	je     8041604acb <mem_init+0x5ea>
    assert(pp >= pages);
  8041604a18:	48 39 f7             	cmp    %rsi,%rdi
  8041604a1b:	0f 87 49 fe ff ff    	ja     804160486a <mem_init+0x389>
    assert(pp < pages + npages);
  8041604a21:	49 39 f0             	cmp    %rsi,%r8
  8041604a24:	0f 86 75 fe ff ff    	jbe    804160489f <mem_init+0x3be>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  8041604a2a:	48 89 f1             	mov    %rsi,%rcx
  8041604a2d:	48 29 f9             	sub    %rdi,%rcx
  8041604a30:	f6 c1 0f             	test   $0xf,%cl
  8041604a33:	0f 85 9b fe ff ff    	jne    80416048d4 <mem_init+0x3f3>
  return (pp - pages) << PGSHIFT;
  8041604a39:	48 c1 f9 04          	sar    $0x4,%rcx
  8041604a3d:	48 c1 e1 0c          	shl    $0xc,%rcx
  8041604a41:	48 89 ca             	mov    %rcx,%rdx
    assert(page2pa(pp) != 0);
  8041604a44:	0f 84 bf fe ff ff    	je     8041604909 <mem_init+0x428>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604a4a:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  8041604a51:	0f 84 e7 fe ff ff    	je     804160493e <mem_init+0x45d>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  8041604a57:	48 81 fa 00 f0 0f 00 	cmp    $0xff000,%rdx
  8041604a5e:	0f 84 0f ff ff ff    	je     8041604973 <mem_init+0x492>
    assert(page2pa(pp) != EXTPHYSMEM);
  8041604a64:	48 81 fa 00 00 10 00 	cmp    $0x100000,%rdx
  8041604a6b:	0f 84 37 ff ff ff    	je     80416049a8 <mem_init+0x4c7>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
  8041604a71:	48 81 fa ff ff 0f 00 	cmp    $0xfffff,%rdx
  8041604a78:	76 92                	jbe    8041604a0c <mem_init+0x52b>
  if (PGNUM(pa) >= npages)
  8041604a7a:	49 89 d3             	mov    %rdx,%r11
  8041604a7d:	49 c1 eb 0c          	shr    $0xc,%r11
  8041604a81:	4d 39 da             	cmp    %r11,%r10
  8041604a84:	0f 86 53 ff ff ff    	jbe    80416049dd <mem_init+0x4fc>
  return (void *)(pa + KERNBASE);
  8041604a8a:	4c 01 e2             	add    %r12,%rdx
  8041604a8d:	48 39 d0             	cmp    %rdx,%rax
  8041604a90:	0f 86 72 ff ff ff    	jbe    8041604a08 <mem_init+0x527>
  8041604a96:	48 b9 40 8f 60 41 80 	movabs $0x8041608f40,%rcx
  8041604a9d:	00 00 00 
  8041604aa0:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604aa7:	00 00 00 
  8041604aaa:	be b6 02 00 00       	mov    $0x2b6,%esi
  8041604aaf:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604ab6:	00 00 00 
  8041604ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604abe:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604ac5:	00 00 00 
  8041604ac8:	41 ff d0             	callq  *%r8
  }

  //assert(nfree_basemem > 0);
  assert(nfree_extmem > 0);
  8041604acb:	45 85 c9             	test   %r9d,%r9d
  8041604ace:	0f 8e 25 03 00 00    	jle    8041604df9 <mem_init+0x918>
  int nfree;
  struct PageInfo *fl;
  char *c;
  int i;

  if (!pages)
  8041604ad4:	48 85 ff             	test   %rdi,%rdi
  8041604ad7:	0f 84 51 03 00 00    	je     8041604e2e <mem_init+0x94d>
    panic("'pages' is a null pointer!");

  // check number of free pages
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041604add:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    ++nfree;
  8041604ae3:	41 83 c4 01          	add    $0x1,%r12d
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041604ae7:	48 8b 1b             	mov    (%rbx),%rbx
  8041604aea:	48 85 db             	test   %rbx,%rbx
  8041604aed:	75 f4                	jne    8041604ae3 <mem_init+0x602>

  // should be able to allocate three pages
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  8041604aef:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604af4:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604afb:	00 00 00 
  8041604afe:	ff d0                	callq  *%rax
  8041604b00:	48 89 c3             	mov    %rax,%rbx
  8041604b03:	48 85 c0             	test   %rax,%rax
  8041604b06:	0f 84 4c 03 00 00    	je     8041604e58 <mem_init+0x977>
  assert((pp1 = page_alloc(0)));
  8041604b0c:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604b11:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604b18:	00 00 00 
  8041604b1b:	ff d0                	callq  *%rax
  8041604b1d:	49 89 c5             	mov    %rax,%r13
  8041604b20:	48 85 c0             	test   %rax,%rax
  8041604b23:	0f 84 64 03 00 00    	je     8041604e8d <mem_init+0x9ac>
  assert((pp2 = page_alloc(0)));
  8041604b29:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604b2e:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604b35:	00 00 00 
  8041604b38:	ff d0                	callq  *%rax
  8041604b3a:	49 89 c6             	mov    %rax,%r14
  8041604b3d:	48 85 c0             	test   %rax,%rax
  8041604b40:	0f 84 7c 03 00 00    	je     8041604ec2 <mem_init+0x9e1>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  8041604b46:	4c 39 eb             	cmp    %r13,%rbx
  8041604b49:	0f 84 a8 03 00 00    	je     8041604ef7 <mem_init+0xa16>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041604b4f:	49 39 c5             	cmp    %rax,%r13
  8041604b52:	0f 84 d4 03 00 00    	je     8041604f2c <mem_init+0xa4b>
  8041604b58:	48 39 c3             	cmp    %rax,%rbx
  8041604b5b:	0f 84 cb 03 00 00    	je     8041604f2c <mem_init+0xa4b>
  return (pp - pages) << PGSHIFT;
  8041604b61:	48 b8 58 c0 61 41 80 	movabs $0x804161c058,%rax
  8041604b68:	00 00 00 
  8041604b6b:	48 8b 08             	mov    (%rax),%rcx
  assert(page2pa(pp0) < npages * PGSIZE);
  8041604b6e:	48 a1 50 c0 61 41 80 	movabs 0x804161c050,%rax
  8041604b75:	00 00 00 
  8041604b78:	48 c1 e0 0c          	shl    $0xc,%rax
  8041604b7c:	48 89 da             	mov    %rbx,%rdx
  8041604b7f:	48 29 ca             	sub    %rcx,%rdx
  8041604b82:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604b86:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041604b8a:	48 39 c2             	cmp    %rax,%rdx
  8041604b8d:	0f 83 ce 03 00 00    	jae    8041604f61 <mem_init+0xa80>
  8041604b93:	4c 89 ea             	mov    %r13,%rdx
  8041604b96:	48 29 ca             	sub    %rcx,%rdx
  8041604b99:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604b9d:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp1) < npages * PGSIZE);
  8041604ba1:	48 39 d0             	cmp    %rdx,%rax
  8041604ba4:	0f 86 ec 03 00 00    	jbe    8041604f96 <mem_init+0xab5>
  8041604baa:	4c 89 f2             	mov    %r14,%rdx
  8041604bad:	48 29 ca             	sub    %rcx,%rdx
  8041604bb0:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604bb4:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp2) < npages * PGSIZE);
  8041604bb8:	48 39 d0             	cmp    %rdx,%rax
  8041604bbb:	0f 86 0a 04 00 00    	jbe    8041604fcb <mem_init+0xaea>

  // temporarily steal the rest of the free pages
  fl             = page_free_list;
  8041604bc1:	48 b8 88 ab 61 41 80 	movabs $0x804161ab88,%rax
  8041604bc8:	00 00 00 
  8041604bcb:	48 8b 30             	mov    (%rax),%rsi
  8041604bce:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  page_free_list = 0;
  8041604bd2:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // should be no free memory
  assert(!page_alloc(0));
  8041604bd9:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604bde:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604be5:	00 00 00 
  8041604be8:	ff d0                	callq  *%rax
  8041604bea:	48 85 c0             	test   %rax,%rax
  8041604bed:	0f 85 0d 04 00 00    	jne    8041605000 <mem_init+0xb1f>

  // free and re-allocate?
  page_free(pp0);
  8041604bf3:	48 89 df             	mov    %rbx,%rdi
  8041604bf6:	48 bb 48 44 60 41 80 	movabs $0x8041604448,%rbx
  8041604bfd:	00 00 00 
  8041604c00:	ff d3                	callq  *%rbx
  page_free(pp1);
  8041604c02:	4c 89 ef             	mov    %r13,%rdi
  8041604c05:	ff d3                	callq  *%rbx
  page_free(pp2);
  8041604c07:	4c 89 f7             	mov    %r14,%rdi
  8041604c0a:	ff d3                	callq  *%rbx
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  8041604c0c:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604c11:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604c18:	00 00 00 
  8041604c1b:	ff d0                	callq  *%rax
  8041604c1d:	48 89 c3             	mov    %rax,%rbx
  8041604c20:	48 85 c0             	test   %rax,%rax
  8041604c23:	0f 84 0c 04 00 00    	je     8041605035 <mem_init+0xb54>
  assert((pp1 = page_alloc(0)));
  8041604c29:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604c2e:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604c35:	00 00 00 
  8041604c38:	ff d0                	callq  *%rax
  8041604c3a:	49 89 c6             	mov    %rax,%r14
  8041604c3d:	48 85 c0             	test   %rax,%rax
  8041604c40:	0f 84 24 04 00 00    	je     804160506a <mem_init+0xb89>
  assert((pp2 = page_alloc(0)));
  8041604c46:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604c4b:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604c52:	00 00 00 
  8041604c55:	ff d0                	callq  *%rax
  8041604c57:	49 89 c5             	mov    %rax,%r13
  8041604c5a:	48 85 c0             	test   %rax,%rax
  8041604c5d:	0f 84 3c 04 00 00    	je     804160509f <mem_init+0xbbe>
  assert(pp0);
  assert(pp1 && pp1 != pp0);
  8041604c63:	4c 39 f3             	cmp    %r14,%rbx
  8041604c66:	0f 84 68 04 00 00    	je     80416050d4 <mem_init+0xbf3>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041604c6c:	49 39 c6             	cmp    %rax,%r14
  8041604c6f:	0f 84 94 04 00 00    	je     8041605109 <mem_init+0xc28>
  8041604c75:	48 39 c3             	cmp    %rax,%rbx
  8041604c78:	0f 84 8b 04 00 00    	je     8041605109 <mem_init+0xc28>
  assert(!page_alloc(0));
  8041604c7e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604c83:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604c8a:	00 00 00 
  8041604c8d:	ff d0                	callq  *%rax
  8041604c8f:	48 85 c0             	test   %rax,%rax
  8041604c92:	0f 85 a6 04 00 00    	jne    804160513e <mem_init+0xc5d>
  8041604c98:	48 b8 58 c0 61 41 80 	movabs $0x804161c058,%rax
  8041604c9f:	00 00 00 
  8041604ca2:	48 89 df             	mov    %rbx,%rdi
  8041604ca5:	48 2b 38             	sub    (%rax),%rdi
  8041604ca8:	48 c1 ff 04          	sar    $0x4,%rdi
  8041604cac:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041604cb0:	48 89 fa             	mov    %rdi,%rdx
  8041604cb3:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041604cb7:	48 b8 50 c0 61 41 80 	movabs $0x804161c050,%rax
  8041604cbe:	00 00 00 
  8041604cc1:	48 3b 10             	cmp    (%rax),%rdx
  8041604cc4:	0f 83 a9 04 00 00    	jae    8041605173 <mem_init+0xc92>
  return (void *)(pa + KERNBASE);
  8041604cca:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604cd1:	00 00 00 
  8041604cd4:	48 01 cf             	add    %rcx,%rdi

  // test flags
  memset(page2kva(pp0), 1, PGSIZE);
  8041604cd7:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041604cdc:	be 01 00 00 00       	mov    $0x1,%esi
  8041604ce1:	48 b8 b0 7b 60 41 80 	movabs $0x8041607bb0,%rax
  8041604ce8:	00 00 00 
  8041604ceb:	ff d0                	callq  *%rax
  page_free(pp0);
  8041604ced:	48 89 df             	mov    %rbx,%rdi
  8041604cf0:	48 b8 48 44 60 41 80 	movabs $0x8041604448,%rax
  8041604cf7:	00 00 00 
  8041604cfa:	ff d0                	callq  *%rax
  assert((pp = page_alloc(ALLOC_ZERO)));
  8041604cfc:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604d01:	48 b8 4f 43 60 41 80 	movabs $0x804160434f,%rax
  8041604d08:	00 00 00 
  8041604d0b:	ff d0                	callq  *%rax
  8041604d0d:	48 85 c0             	test   %rax,%rax
  8041604d10:	0f 84 8b 04 00 00    	je     80416051a1 <mem_init+0xcc0>
  assert(pp && pp0 == pp);
  8041604d16:	48 39 c3             	cmp    %rax,%rbx
  8041604d19:	0f 85 b2 04 00 00    	jne    80416051d1 <mem_init+0xcf0>
  return (pp - pages) << PGSHIFT;
  8041604d1f:	48 ba 58 c0 61 41 80 	movabs $0x804161c058,%rdx
  8041604d26:	00 00 00 
  8041604d29:	48 2b 02             	sub    (%rdx),%rax
  8041604d2c:	48 c1 f8 04          	sar    $0x4,%rax
  8041604d30:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  8041604d34:	48 89 c1             	mov    %rax,%rcx
  8041604d37:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604d3b:	48 ba 50 c0 61 41 80 	movabs $0x804161c050,%rdx
  8041604d42:	00 00 00 
  8041604d45:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604d48:	0f 83 b8 04 00 00    	jae    8041605206 <mem_init+0xd25>
  c = page2kva(pp);
  for (i = 0; i < PGSIZE; i++)
    assert(c[i] == 0);
  8041604d4e:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041604d55:	00 00 00 
  8041604d58:	80 3c 10 00          	cmpb   $0x0,(%rax,%rdx,1)
  8041604d5c:	0f 85 d2 04 00 00    	jne    8041605234 <mem_init+0xd53>
  8041604d62:	48 8d 52 01          	lea    0x1(%rdx),%rdx
  8041604d66:	48 01 c2             	add    %rax,%rdx
  8041604d69:	48 b9 00 10 00 40 80 	movabs $0x8040001000,%rcx
  8041604d70:	00 00 00 
  8041604d73:	48 01 c8             	add    %rcx,%rax
  8041604d76:	80 3a 00             	cmpb   $0x0,(%rdx)
  8041604d79:	0f 85 b5 04 00 00    	jne    8041605234 <mem_init+0xd53>
  for (i = 0; i < PGSIZE; i++)
  8041604d7f:	48 83 c2 01          	add    $0x1,%rdx
  8041604d83:	48 39 c2             	cmp    %rax,%rdx
  8041604d86:	75 ee                	jne    8041604d76 <mem_init+0x895>

  // give free list back
  page_free_list = fl;
  8041604d88:	49 bf 88 ab 61 41 80 	movabs $0x804161ab88,%r15
  8041604d8f:	00 00 00 
  8041604d92:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041604d96:	49 89 07             	mov    %rax,(%r15)

  // free the pages we took
  page_free(pp0);
  8041604d99:	48 89 df             	mov    %rbx,%rdi
  8041604d9c:	48 bb 48 44 60 41 80 	movabs $0x8041604448,%rbx
  8041604da3:	00 00 00 
  8041604da6:	ff d3                	callq  *%rbx
  page_free(pp1);
  8041604da8:	4c 89 f7             	mov    %r14,%rdi
  8041604dab:	ff d3                	callq  *%rbx
  page_free(pp2);
  8041604dad:	4c 89 ef             	mov    %r13,%rdi
  8041604db0:	ff d3                	callq  *%rbx

  // number of free pages should be the same
  for (pp = page_free_list; pp; pp = pp->pp_link)
  8041604db2:	49 8b 07             	mov    (%r15),%rax
  8041604db5:	48 85 c0             	test   %rax,%rax
  8041604db8:	74 0c                	je     8041604dc6 <mem_init+0x8e5>
    --nfree;
  8041604dba:	41 83 ec 01          	sub    $0x1,%r12d
  for (pp = page_free_list; pp; pp = pp->pp_link)
  8041604dbe:	48 8b 00             	mov    (%rax),%rax
  8041604dc1:	48 85 c0             	test   %rax,%rax
  8041604dc4:	75 f4                	jne    8041604dba <mem_init+0x8d9>
  assert(nfree == 0);
  8041604dc6:	45 85 e4             	test   %r12d,%r12d
  8041604dc9:	0f 85 9a 04 00 00    	jne    8041605269 <mem_init+0xd88>

  cprintf("check_page_alloc() succeeded!\n");
  8041604dcf:	48 bf 08 90 60 41 80 	movabs $0x8041609008,%rdi
  8041604dd6:	00 00 00 
  8041604dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604dde:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041604de5:	00 00 00 
  8041604de8:	ff d2                	callq  *%rdx
}
  8041604dea:	48 83 c4 38          	add    $0x38,%rsp
  8041604dee:	5b                   	pop    %rbx
  8041604def:	41 5c                	pop    %r12
  8041604df1:	41 5d                	pop    %r13
  8041604df3:	41 5e                	pop    %r14
  8041604df5:	41 5f                	pop    %r15
  8041604df7:	5d                   	pop    %rbp
  8041604df8:	c3                   	retq   
  assert(nfree_extmem > 0);
  8041604df9:	48 b9 a5 90 60 41 80 	movabs $0x80416090a5,%rcx
  8041604e00:	00 00 00 
  8041604e03:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604e0a:	00 00 00 
  8041604e0d:	be bf 02 00 00       	mov    $0x2bf,%esi
  8041604e12:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604e19:	00 00 00 
  8041604e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e21:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604e28:	00 00 00 
  8041604e2b:	41 ff d0             	callq  *%r8
    panic("'pages' is a null pointer!");
  8041604e2e:	48 ba b6 90 60 41 80 	movabs $0x80416090b6,%rdx
  8041604e35:	00 00 00 
  8041604e38:	be cf 02 00 00       	mov    $0x2cf,%esi
  8041604e3d:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604e44:	00 00 00 
  8041604e47:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e4c:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  8041604e53:	00 00 00 
  8041604e56:	ff d1                	callq  *%rcx
  assert((pp0 = page_alloc(0)));
  8041604e58:	48 b9 d1 90 60 41 80 	movabs $0x80416090d1,%rcx
  8041604e5f:	00 00 00 
  8041604e62:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604e69:	00 00 00 
  8041604e6c:	be d7 02 00 00       	mov    $0x2d7,%esi
  8041604e71:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604e78:	00 00 00 
  8041604e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e80:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604e87:	00 00 00 
  8041604e8a:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041604e8d:	48 b9 e7 90 60 41 80 	movabs $0x80416090e7,%rcx
  8041604e94:	00 00 00 
  8041604e97:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604e9e:	00 00 00 
  8041604ea1:	be d8 02 00 00       	mov    $0x2d8,%esi
  8041604ea6:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604ead:	00 00 00 
  8041604eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604eb5:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604ebc:	00 00 00 
  8041604ebf:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041604ec2:	48 b9 fd 90 60 41 80 	movabs $0x80416090fd,%rcx
  8041604ec9:	00 00 00 
  8041604ecc:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604ed3:	00 00 00 
  8041604ed6:	be d9 02 00 00       	mov    $0x2d9,%esi
  8041604edb:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604ee2:	00 00 00 
  8041604ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604eea:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604ef1:	00 00 00 
  8041604ef4:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  8041604ef7:	48 b9 13 91 60 41 80 	movabs $0x8041609113,%rcx
  8041604efe:	00 00 00 
  8041604f01:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604f08:	00 00 00 
  8041604f0b:	be dc 02 00 00       	mov    $0x2dc,%esi
  8041604f10:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604f17:	00 00 00 
  8041604f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f1f:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604f26:	00 00 00 
  8041604f29:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041604f2c:	48 b9 88 8f 60 41 80 	movabs $0x8041608f88,%rcx
  8041604f33:	00 00 00 
  8041604f36:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604f3d:	00 00 00 
  8041604f40:	be dd 02 00 00       	mov    $0x2dd,%esi
  8041604f45:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604f4c:	00 00 00 
  8041604f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f54:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604f5b:	00 00 00 
  8041604f5e:	41 ff d0             	callq  *%r8
  assert(page2pa(pp0) < npages * PGSIZE);
  8041604f61:	48 b9 a8 8f 60 41 80 	movabs $0x8041608fa8,%rcx
  8041604f68:	00 00 00 
  8041604f6b:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604f72:	00 00 00 
  8041604f75:	be de 02 00 00       	mov    $0x2de,%esi
  8041604f7a:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604f81:	00 00 00 
  8041604f84:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f89:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604f90:	00 00 00 
  8041604f93:	41 ff d0             	callq  *%r8
  assert(page2pa(pp1) < npages * PGSIZE);
  8041604f96:	48 b9 c8 8f 60 41 80 	movabs $0x8041608fc8,%rcx
  8041604f9d:	00 00 00 
  8041604fa0:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604fa7:	00 00 00 
  8041604faa:	be df 02 00 00       	mov    $0x2df,%esi
  8041604faf:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604fb6:	00 00 00 
  8041604fb9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fbe:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604fc5:	00 00 00 
  8041604fc8:	41 ff d0             	callq  *%r8
  assert(page2pa(pp2) < npages * PGSIZE);
  8041604fcb:	48 b9 e8 8f 60 41 80 	movabs $0x8041608fe8,%rcx
  8041604fd2:	00 00 00 
  8041604fd5:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041604fdc:	00 00 00 
  8041604fdf:	be e0 02 00 00       	mov    $0x2e0,%esi
  8041604fe4:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041604feb:	00 00 00 
  8041604fee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ff3:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041604ffa:	00 00 00 
  8041604ffd:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041605000:	48 b9 25 91 60 41 80 	movabs $0x8041609125,%rcx
  8041605007:	00 00 00 
  804160500a:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041605011:	00 00 00 
  8041605014:	be e7 02 00 00       	mov    $0x2e7,%esi
  8041605019:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041605020:	00 00 00 
  8041605023:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605028:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160502f:	00 00 00 
  8041605032:	41 ff d0             	callq  *%r8
  assert((pp0 = page_alloc(0)));
  8041605035:	48 b9 d1 90 60 41 80 	movabs $0x80416090d1,%rcx
  804160503c:	00 00 00 
  804160503f:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041605046:	00 00 00 
  8041605049:	be ee 02 00 00       	mov    $0x2ee,%esi
  804160504e:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041605055:	00 00 00 
  8041605058:	b8 00 00 00 00       	mov    $0x0,%eax
  804160505d:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041605064:	00 00 00 
  8041605067:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  804160506a:	48 b9 e7 90 60 41 80 	movabs $0x80416090e7,%rcx
  8041605071:	00 00 00 
  8041605074:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160507b:	00 00 00 
  804160507e:	be ef 02 00 00       	mov    $0x2ef,%esi
  8041605083:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  804160508a:	00 00 00 
  804160508d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605092:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041605099:	00 00 00 
  804160509c:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  804160509f:	48 b9 fd 90 60 41 80 	movabs $0x80416090fd,%rcx
  80416050a6:	00 00 00 
  80416050a9:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416050b0:	00 00 00 
  80416050b3:	be f0 02 00 00       	mov    $0x2f0,%esi
  80416050b8:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416050bf:	00 00 00 
  80416050c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050c7:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416050ce:	00 00 00 
  80416050d1:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  80416050d4:	48 b9 13 91 60 41 80 	movabs $0x8041609113,%rcx
  80416050db:	00 00 00 
  80416050de:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416050e5:	00 00 00 
  80416050e8:	be f2 02 00 00       	mov    $0x2f2,%esi
  80416050ed:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416050f4:	00 00 00 
  80416050f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050fc:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041605103:	00 00 00 
  8041605106:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041605109:	48 b9 88 8f 60 41 80 	movabs $0x8041608f88,%rcx
  8041605110:	00 00 00 
  8041605113:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160511a:	00 00 00 
  804160511d:	be f3 02 00 00       	mov    $0x2f3,%esi
  8041605122:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041605129:	00 00 00 
  804160512c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605131:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041605138:	00 00 00 
  804160513b:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  804160513e:	48 b9 25 91 60 41 80 	movabs $0x8041609125,%rcx
  8041605145:	00 00 00 
  8041605148:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160514f:	00 00 00 
  8041605152:	be f4 02 00 00       	mov    $0x2f4,%esi
  8041605157:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  804160515e:	00 00 00 
  8041605161:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605166:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160516d:	00 00 00 
  8041605170:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041605173:	48 89 f9             	mov    %rdi,%rcx
  8041605176:	48 ba 10 8e 60 41 80 	movabs $0x8041608e10,%rdx
  804160517d:	00 00 00 
  8041605180:	be 5e 00 00 00       	mov    $0x5e,%esi
  8041605185:	48 bf 33 90 60 41 80 	movabs $0x8041609033,%rdi
  804160518c:	00 00 00 
  804160518f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605194:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160519b:	00 00 00 
  804160519e:	41 ff d0             	callq  *%r8
  assert((pp = page_alloc(ALLOC_ZERO)));
  80416051a1:	48 b9 34 91 60 41 80 	movabs $0x8041609134,%rcx
  80416051a8:	00 00 00 
  80416051ab:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416051b2:	00 00 00 
  80416051b5:	be f9 02 00 00       	mov    $0x2f9,%esi
  80416051ba:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416051c1:	00 00 00 
  80416051c4:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416051cb:	00 00 00 
  80416051ce:	41 ff d0             	callq  *%r8
  assert(pp && pp0 == pp);
  80416051d1:	48 b9 52 91 60 41 80 	movabs $0x8041609152,%rcx
  80416051d8:	00 00 00 
  80416051db:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416051e2:	00 00 00 
  80416051e5:	be fa 02 00 00       	mov    $0x2fa,%esi
  80416051ea:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  80416051f1:	00 00 00 
  80416051f4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416051f9:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041605200:	00 00 00 
  8041605203:	41 ff d0             	callq  *%r8
  8041605206:	48 89 c1             	mov    %rax,%rcx
  8041605209:	48 ba 10 8e 60 41 80 	movabs $0x8041608e10,%rdx
  8041605210:	00 00 00 
  8041605213:	be 5e 00 00 00       	mov    $0x5e,%esi
  8041605218:	48 bf 33 90 60 41 80 	movabs $0x8041609033,%rdi
  804160521f:	00 00 00 
  8041605222:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605227:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160522e:	00 00 00 
  8041605231:	41 ff d0             	callq  *%r8
    assert(c[i] == 0);
  8041605234:	48 b9 62 91 60 41 80 	movabs $0x8041609162,%rcx
  804160523b:	00 00 00 
  804160523e:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  8041605245:	00 00 00 
  8041605248:	be fd 02 00 00       	mov    $0x2fd,%esi
  804160524d:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041605254:	00 00 00 
  8041605257:	b8 00 00 00 00       	mov    $0x0,%eax
  804160525c:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041605263:	00 00 00 
  8041605266:	41 ff d0             	callq  *%r8
  assert(nfree == 0);
  8041605269:	48 b9 6c 91 60 41 80 	movabs $0x804160916c,%rcx
  8041605270:	00 00 00 
  8041605273:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160527a:	00 00 00 
  804160527d:	be 0a 03 00 00       	mov    $0x30a,%esi
  8041605282:	48 bf 27 90 60 41 80 	movabs $0x8041609027,%rdi
  8041605289:	00 00 00 
  804160528c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605291:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  8041605298:	00 00 00 
  804160529b:	41 ff d0             	callq  *%r8

000000804160529e <page_decref>:
  if (--pp->pp_ref == 0)
  804160529e:	0f b7 47 08          	movzwl 0x8(%rdi),%eax
  80416052a2:	83 e8 01             	sub    $0x1,%eax
  80416052a5:	66 89 47 08          	mov    %ax,0x8(%rdi)
  80416052a9:	66 85 c0             	test   %ax,%ax
  80416052ac:	74 01                	je     80416052af <page_decref+0x11>
  80416052ae:	c3                   	retq   
page_decref(struct PageInfo *pp) {
  80416052af:	55                   	push   %rbp
  80416052b0:	48 89 e5             	mov    %rsp,%rbp
    page_free(pp);
  80416052b3:	48 b8 48 44 60 41 80 	movabs $0x8041604448,%rax
  80416052ba:	00 00 00 
  80416052bd:	ff d0                	callq  *%rax
}
  80416052bf:	5d                   	pop    %rbp
  80416052c0:	c3                   	retq   

00000080416052c1 <pml4e_walk>:
}
  80416052c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416052c6:	c3                   	retq   

00000080416052c7 <pdpe_walk>:
}
  80416052c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416052cc:	c3                   	retq   

00000080416052cd <pgdir_walk>:
}
  80416052cd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416052d2:	c3                   	retq   

00000080416052d3 <page_insert>:
}
  80416052d3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416052d8:	c3                   	retq   

00000080416052d9 <page_lookup>:
}
  80416052d9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416052de:	c3                   	retq   

00000080416052df <page_remove>:
}
  80416052df:	c3                   	retq   

00000080416052e0 <tlb_invalidate>:
  __asm __volatile("invlpg (%0)"
  80416052e0:	0f 01 3e             	invlpg (%rsi)
}
  80416052e3:	c3                   	retq   

00000080416052e4 <mmio_map_region>:
}
  80416052e4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416052e9:	c3                   	retq   

00000080416052ea <envid2env>:
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
  80416052ea:	85 ff                	test   %edi,%edi
  80416052ec:	74 5c                	je     804160534a <envid2env+0x60>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  80416052ee:	89 f8                	mov    %edi,%eax
  80416052f0:	83 e0 1f             	and    $0x1f,%eax
  80416052f3:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
  80416052fa:	00 
  80416052fb:	48 29 c1             	sub    %rax,%rcx
  80416052fe:	48 c1 e1 05          	shl    $0x5,%rcx
  8041605302:	48 a1 88 a7 61 41 80 	movabs 0x804161a788,%rax
  8041605309:	00 00 00 
  804160530c:	48 01 c1             	add    %rax,%rcx
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  804160530f:	83 b9 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rcx)
  8041605316:	74 42                	je     804160535a <envid2env+0x70>
  8041605318:	39 b9 c8 00 00 00    	cmp    %edi,0xc8(%rcx)
  804160531e:	75 3a                	jne    804160535a <envid2env+0x70>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  8041605320:	84 d2                	test   %dl,%dl
  8041605322:	74 1d                	je     8041605341 <envid2env+0x57>
  8041605324:	48 a1 98 ab 61 41 80 	movabs 0x804161ab98,%rax
  804160532b:	00 00 00 
  804160532e:	48 39 c8             	cmp    %rcx,%rax
  8041605331:	74 0e                	je     8041605341 <envid2env+0x57>
  8041605333:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8041605339:	39 81 cc 00 00 00    	cmp    %eax,0xcc(%rcx)
  804160533f:	75 26                	jne    8041605367 <envid2env+0x7d>
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  8041605341:	48 89 0e             	mov    %rcx,(%rsi)
  return 0;
  8041605344:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041605349:	c3                   	retq   
    *env_store = curenv;
  804160534a:	48 a1 98 ab 61 41 80 	movabs 0x804161ab98,%rax
  8041605351:	00 00 00 
  8041605354:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  8041605357:	89 f8                	mov    %edi,%eax
  8041605359:	c3                   	retq   
    *env_store = 0;
  804160535a:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041605361:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041605366:	c3                   	retq   
    *env_store = 0;
  8041605367:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  804160536e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041605373:	c3                   	retq   

0000008041605374 <env_init_percpu>:
  env_init_percpu();
}

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  8041605374:	55                   	push   %rbp
  8041605375:	48 89 e5             	mov    %rsp,%rbp
  8041605378:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  8041605379:	48 b8 20 a7 61 41 80 	movabs $0x804161a720,%rax
  8041605380:	00 00 00 
  8041605383:	0f 01 10             	lgdt   (%rax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  8041605386:	b8 33 00 00 00       	mov    $0x33,%eax
  804160538b:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  804160538d:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  804160538f:	b8 10 00 00 00       	mov    $0x10,%eax
  8041605394:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041605396:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041605398:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  804160539a:	bb 08 00 00 00       	mov    $0x8,%ebx
  804160539f:	53                   	push   %rbx
  80416053a0:	48 b8 ad 53 60 41 80 	movabs $0x80416053ad,%rax
  80416053a7:	00 00 00 
  80416053aa:	50                   	push   %rax
  80416053ab:	48 cb                	lretq  
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  80416053ad:	66 b8 00 00          	mov    $0x0,%ax
  80416053b1:	0f 00 d0             	lldt   %ax
               :
               :
               : "cc", "memory");
}
  80416053b4:	5b                   	pop    %rbx
  80416053b5:	5d                   	pop    %rbp
  80416053b6:	c3                   	retq   

00000080416053b7 <env_init>:
env_init(void) {
  80416053b7:	55                   	push   %rbp
  80416053b8:	48 89 e5             	mov    %rsp,%rbp
    envs[i].env_link = env_free_list;
  80416053bb:	48 b8 88 a7 61 41 80 	movabs $0x804161a788,%rax
  80416053c2:	00 00 00 
  80416053c5:	48 8b 38             	mov    (%rax),%rdi
  80416053c8:	48 8d 87 20 1b 00 00 	lea    0x1b20(%rdi),%rax
  80416053cf:	48 89 fe             	mov    %rdi,%rsi
  80416053d2:	ba 00 00 00 00       	mov    $0x0,%edx
  80416053d7:	eb 03                	jmp    80416053dc <env_init+0x25>
  80416053d9:	48 89 c8             	mov    %rcx,%rax
  80416053dc:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    envs[i].env_id   = 0;
  80416053e3:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%rax)
  80416053ea:	00 00 00 
  for (int i = NENV - 1; i >= 0; i--) {
  80416053ed:	48 8d 88 20 ff ff ff 	lea    -0xe0(%rax),%rcx
    env_free_list    = &envs[i];
  80416053f4:	48 89 c2             	mov    %rax,%rdx
  for (int i = NENV - 1; i >= 0; i--) {
  80416053f7:	48 39 f0             	cmp    %rsi,%rax
  80416053fa:	75 dd                	jne    80416053d9 <env_init+0x22>
  80416053fc:	48 89 f8             	mov    %rdi,%rax
  80416053ff:	48 a3 a0 ab 61 41 80 	movabs %rax,0x804161aba0
  8041605406:	00 00 00 
  env_init_percpu();
  8041605409:	48 b8 74 53 60 41 80 	movabs $0x8041605374,%rax
  8041605410:	00 00 00 
  8041605413:	ff d0                	callq  *%rax
}
  8041605415:	5d                   	pop    %rbp
  8041605416:	c3                   	retq   

0000008041605417 <env_alloc>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  8041605417:	55                   	push   %rbp
  8041605418:	48 89 e5             	mov    %rsp,%rbp
  804160541b:	41 54                	push   %r12
  804160541d:	53                   	push   %rbx
  int32_t generation;
  struct Env *e;

  if (!(e = env_free_list)) {
  804160541e:	48 b8 a0 ab 61 41 80 	movabs $0x804161aba0,%rax
  8041605425:	00 00 00 
  8041605428:	48 8b 18             	mov    (%rax),%rbx
  804160542b:	48 85 db             	test   %rbx,%rbx
  804160542e:	0f 84 d6 00 00 00    	je     804160550a <env_alloc+0xf3>
  8041605434:	49 89 fc             	mov    %rdi,%r12
    return -E_NO_FREE_ENV;
  }

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  8041605437:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  804160543d:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041605442:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  8041605445:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160544a:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  804160544d:	48 ba 88 a7 61 41 80 	movabs $0x804161a788,%rdx
  8041605454:	00 00 00 
  8041605457:	48 89 d9             	mov    %rbx,%rcx
  804160545a:	48 2b 0a             	sub    (%rdx),%rcx
  804160545d:	48 89 ca             	mov    %rcx,%rdx
  8041605460:	48 c1 fa 05          	sar    $0x5,%rdx
  8041605464:	69 d2 b7 6d db b6    	imul   $0xb6db6db7,%edx,%edx
  804160546a:	09 d0                	or     %edx,%eax
  804160546c:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
  8041605472:	89 b3 cc 00 00 00    	mov    %esi,0xcc(%rbx)
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
#else
#endif
  e->env_status = ENV_RUNNABLE;
  8041605478:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  804160547f:	00 00 00 
  e->env_runs   = 0;
  8041605482:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  8041605489:	00 00 00 

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  804160548c:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041605491:	be 00 00 00 00       	mov    $0x0,%esi
  8041605496:	48 89 df             	mov    %rbx,%rdi
  8041605499:	48 b8 b0 7b 60 41 80 	movabs $0x8041607bb0,%rax
  80416054a0:	00 00 00 
  80416054a3:	ff d0                	callq  *%rax
  e->env_tf.tf_rsp = STACK_TOP - (e - envs) * 2 * PGSIZE;
    
#else
#endif

  e->env_tf.tf_rflags |= FL_IF;
  80416054a5:	48 81 8b a8 00 00 00 	orq    $0x200,0xa8(%rbx)
  80416054ac:	00 02 00 00 

  // You will set e->env_tf.tf_rip later.

  // commit the allocation
  env_free_list = e->env_link;
  80416054b0:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  80416054b7:	48 a3 a0 ab 61 41 80 	movabs %rax,0x804161aba0
  80416054be:	00 00 00 
  *newenv_store = e;
  80416054c1:	49 89 1c 24          	mov    %rbx,(%r12)

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  80416054c5:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  80416054cb:	48 a1 98 ab 61 41 80 	movabs 0x804161ab98,%rax
  80416054d2:	00 00 00 
  80416054d5:	be 00 00 00 00       	mov    $0x0,%esi
  80416054da:	48 85 c0             	test   %rax,%rax
  80416054dd:	74 06                	je     80416054e5 <env_alloc+0xce>
  80416054df:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80416054e5:	48 bf 77 91 60 41 80 	movabs $0x8041609177,%rdi
  80416054ec:	00 00 00 
  80416054ef:	b8 00 00 00 00       	mov    $0x0,%eax
  80416054f4:	48 b9 6a 5a 60 41 80 	movabs $0x8041605a6a,%rcx
  80416054fb:	00 00 00 
  80416054fe:	ff d1                	callq  *%rcx

  return 0;
  8041605500:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041605505:	5b                   	pop    %rbx
  8041605506:	41 5c                	pop    %r12
  8041605508:	5d                   	pop    %rbp
  8041605509:	c3                   	retq   
    return -E_NO_FREE_ENV;
  804160550a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  804160550f:	eb f4                	jmp    8041605505 <env_alloc+0xee>

0000008041605511 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  8041605511:	55                   	push   %rbp
  8041605512:	48 89 e5             	mov    %rsp,%rbp
  8041605515:	41 57                	push   %r15
  8041605517:	41 56                	push   %r14
  8041605519:	41 55                	push   %r13
  804160551b:	41 54                	push   %r12
  804160551d:	53                   	push   %rbx
  804160551e:	48 83 ec 28          	sub    $0x28,%rsp
  8041605522:	49 89 fc             	mov    %rdi,%r12
  8041605525:	89 f3                	mov    %esi,%ebx
    
  // LAB 3 code
  struct Env *newenv;
  if (env_alloc(&newenv, 0) < 0) {
  8041605527:	be 00 00 00 00       	mov    $0x0,%esi
  804160552c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041605530:	48 b8 17 54 60 41 80 	movabs $0x8041605417,%rax
  8041605537:	00 00 00 
  804160553a:	ff d0                	callq  *%rax
  804160553c:	85 c0                	test   %eax,%eax
  804160553e:	78 33                	js     8041605573 <env_create+0x62>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  }
      
  newenv->env_type = type;
  8041605540:	4c 8b 7d c8          	mov    -0x38(%rbp),%r15
  8041605544:	41 89 9f d0 00 00 00 	mov    %ebx,0xd0(%r15)
  if (elf->e_magic != ELF_MAGIC) {
  804160554b:	41 81 3c 24 7f 45 4c 	cmpl   $0x464c457f,(%r12)
  8041605552:	46 
  8041605553:	75 48                	jne    804160559d <env_create+0x8c>
  struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff); // Proghdr = prog header. Он лежит со смещением elf->e_phoff относительно начала фаила
  8041605555:	49 8b 5c 24 20       	mov    0x20(%r12),%rbx
  for (size_t i = 0; i < elf->e_phnum; i++) { //elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  804160555a:	66 41 83 7c 24 38 00 	cmpw   $0x0,0x38(%r12)
  8041605561:	74 55                	je     80416055b8 <env_create+0xa7>
  8041605563:	4c 01 e3             	add    %r12,%rbx
  8041605566:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  804160556d:	00 
  804160556e:	e9 cc 00 00 00       	jmpq   804160563f <env_create+0x12e>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  8041605573:	48 ba c8 91 60 41 80 	movabs $0x80416091c8,%rdx
  804160557a:	00 00 00 
  804160557d:	be 6c 01 00 00       	mov    $0x16c,%esi
  8041605582:	48 bf 8c 91 60 41 80 	movabs $0x804160918c,%rdi
  8041605589:	00 00 00 
  804160558c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605591:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  8041605598:	00 00 00 
  804160559b:	ff d1                	callq  *%rcx
    cprintf("Unexpected ELF format\n");
  804160559d:	48 bf 97 91 60 41 80 	movabs $0x8041609197,%rdi
  80416055a4:	00 00 00 
  80416055a7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416055ac:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416055b3:	00 00 00 
  80416055b6:	ff d2                	callq  *%rdx

  load_icode(newenv, binary); // load instruction code
    
}
  80416055b8:	48 83 c4 28          	add    $0x28,%rsp
  80416055bc:	5b                   	pop    %rbx
  80416055bd:	41 5c                	pop    %r12
  80416055bf:	41 5d                	pop    %r13
  80416055c1:	41 5e                	pop    %r14
  80416055c3:	41 5f                	pop    %r15
  80416055c5:	5d                   	pop    %rbp
  80416055c6:	c3                   	retq   
    void *dst = (void *)ph[i].p_va;
  80416055c7:	48 8b 43 10          	mov    0x10(%rbx),%rax
    size_t memsz  = ph[i].p_memsz;
  80416055cb:	4c 8b 6b 28          	mov    0x28(%rbx),%r13
    size_t filesz = MIN(ph[i].p_filesz, memsz);
  80416055cf:	4c 39 6b 20          	cmp    %r13,0x20(%rbx)
  80416055d3:	4d 89 ee             	mov    %r13,%r14
  80416055d6:	4c 0f 46 73 20       	cmovbe 0x20(%rbx),%r14
    void *src = binary + ph[i].p_offset;
  80416055db:	4c 89 e6             	mov    %r12,%rsi
  80416055de:	48 03 73 08          	add    0x8(%rbx),%rsi
    memcpy(dst, src, filesz);                // копируем в dst (дистинейшн) src (код) размера filesz
  80416055e2:	4c 89 f2             	mov    %r14,%rdx
  80416055e5:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  80416055e9:	48 89 c7             	mov    %rax,%rdi
  80416055ec:	48 b9 61 7c 60 41 80 	movabs $0x8041607c61,%rcx
  80416055f3:	00 00 00 
  80416055f6:	ff d1                	callq  *%rcx
    memset(dst + filesz, 0, memsz - filesz); // обнуление памяти по адресу dst + filesz, где количество нулей = memsz - filesz. Т.е. зануляем всю выделенную память сегмента кода, оставшуюяся после копирования src. Возможно, эта строка не нужна
  80416055f8:	4c 89 ea             	mov    %r13,%rdx
  80416055fb:	4c 29 f2             	sub    %r14,%rdx
  80416055fe:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041605602:	4a 8d 3c 30          	lea    (%rax,%r14,1),%rdi
  8041605606:	be 00 00 00 00       	mov    $0x0,%esi
  804160560b:	48 b8 b0 7b 60 41 80 	movabs $0x8041607bb0,%rax
  8041605612:	00 00 00 
  8041605615:	ff d0                	callq  *%rax
    e->env_tf.tf_rip = elf->e_entry; //Виртуальный адрес точки входа, которому система передает управление при запуске процесса. в регистр rip записываем адрес точки входа для выполнения процесса
  8041605617:	49 8b 44 24 18       	mov    0x18(%r12),%rax
  804160561c:	49 89 87 98 00 00 00 	mov    %rax,0x98(%r15)
  for (size_t i = 0; i < elf->e_phnum; i++) { //elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041605623:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  8041605628:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  804160562c:	48 83 c3 38          	add    $0x38,%rbx
  8041605630:	41 0f b7 44 24 38    	movzwl 0x38(%r12),%eax
  8041605636:	48 39 c1             	cmp    %rax,%rcx
  8041605639:	0f 83 79 ff ff ff    	jae    80416055b8 <env_create+0xa7>
    if (ph[i].p_type == ELF_PROG_LOAD) {
  804160563f:	83 3b 01             	cmpl   $0x1,(%rbx)
  8041605642:	75 d3                	jne    8041605617 <env_create+0x106>
  8041605644:	eb 81                	jmp    80416055c7 <env_create+0xb6>

0000008041605646 <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041605646:	55                   	push   %rbp
  8041605647:	48 89 e5             	mov    %rsp,%rbp
  804160564a:	53                   	push   %rbx
  804160564b:	48 83 ec 08          	sub    $0x8,%rsp
  804160564f:	48 89 fb             	mov    %rdi,%rbx
  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041605652:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041605658:	48 a1 98 ab 61 41 80 	movabs 0x804161ab98,%rax
  804160565f:	00 00 00 
  8041605662:	be 00 00 00 00       	mov    $0x0,%esi
  8041605667:	48 85 c0             	test   %rax,%rax
  804160566a:	74 06                	je     8041605672 <env_free+0x2c>
  804160566c:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041605672:	48 bf ae 91 60 41 80 	movabs $0x80416091ae,%rdi
  8041605679:	00 00 00 
  804160567c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605681:	48 b9 6a 5a 60 41 80 	movabs $0x8041605a6a,%rcx
  8041605688:	00 00 00 
  804160568b:	ff d1                	callq  *%rcx

  // return the environment to the free list
  e->env_status = ENV_FREE;
  804160568d:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  8041605694:	00 00 00 
  e->env_link   = env_free_list;
  8041605697:	48 b8 a0 ab 61 41 80 	movabs $0x804161aba0,%rax
  804160569e:	00 00 00 
  80416056a1:	48 8b 10             	mov    (%rax),%rdx
  80416056a4:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  80416056ab:	48 89 18             	mov    %rbx,(%rax)
}
  80416056ae:	48 83 c4 08          	add    $0x8,%rsp
  80416056b2:	5b                   	pop    %rbx
  80416056b3:	5d                   	pop    %rbp
  80416056b4:	c3                   	retq   

00000080416056b5 <env_destroy>:
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
    
  // LAB 3 code
  e->env_status = ENV_DYING;
  80416056b5:	c7 87 d4 00 00 00 01 	movl   $0x1,0xd4(%rdi)
  80416056bc:	00 00 00 
  if (e == curenv) {
  80416056bf:	48 b8 98 ab 61 41 80 	movabs $0x804161ab98,%rax
  80416056c6:	00 00 00 
  80416056c9:	48 39 38             	cmp    %rdi,(%rax)
  80416056cc:	74 01                	je     80416056cf <env_destroy+0x1a>
  80416056ce:	c3                   	retq   
env_destroy(struct Env *e) {
  80416056cf:	55                   	push   %rbp
  80416056d0:	48 89 e5             	mov    %rsp,%rbp
    env_free(e);
  80416056d3:	48 b8 46 56 60 41 80 	movabs $0x8041605646,%rax
  80416056da:	00 00 00 
  80416056dd:	ff d0                	callq  *%rax
    sched_yield();
  80416056df:	48 b8 f5 6b 60 41 80 	movabs $0x8041606bf5,%rax
  80416056e6:	00 00 00 
  80416056e9:	ff d0                	callq  *%rax

00000080416056eb <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  80416056eb:	55                   	push   %rbp
  80416056ec:	48 89 e5             	mov    %rsp,%rbp
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
#endif
  panic("BUG"); /* mostly to placate the compiler */
  80416056ef:	48 ba c4 91 60 41 80 	movabs $0x80416091c4,%rdx
  80416056f6:	00 00 00 
  80416056f9:	be dd 01 00 00       	mov    $0x1dd,%esi
  80416056fe:	48 bf 8c 91 60 41 80 	movabs $0x804160918c,%rdi
  8041605705:	00 00 00 
  8041605708:	b8 00 00 00 00       	mov    $0x0,%eax
  804160570d:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  8041605714:	00 00 00 
  8041605717:	ff d1                	callq  *%rcx

0000008041605719 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  8041605719:	55                   	push   %rbp
  804160571a:	48 89 e5             	mov    %rsp,%rbp
  804160571d:	41 54                	push   %r12
  804160571f:	53                   	push   %rbx
  8041605720:	48 89 fb             	mov    %rdi,%rbx
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //
    
  // LAB 3 code
  if (curenv) {  // if curenv == False, значит, какого-нибудь исполняемого процесса нет
  8041605723:	48 b8 98 ab 61 41 80 	movabs $0x804161ab98,%rax
  804160572a:	00 00 00 
  804160572d:	4c 8b 20             	mov    (%rax),%r12
  8041605730:	4d 85 e4             	test   %r12,%r12
  8041605733:	74 12                	je     8041605747 <env_run+0x2e>
    if (curenv->env_status == ENV_DYING) { // если процесс стал зомби
  8041605735:	41 8b 84 24 d4 00 00 	mov    0xd4(%r12),%eax
  804160573c:	00 
  804160573d:	83 f8 01             	cmp    $0x1,%eax
  8041605740:	74 32                	je     8041605774 <env_run+0x5b>
      struct Env *old = curenv;  // ставим старый адрес
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
      if (old == e) { // e - аргумент функции, который к нам пришел
        sched_yield();  // переключение системными вызовами
      }
    } else if (curenv->env_status == ENV_RUNNING) { // если процесс можем запустить
  8041605742:	83 f8 03             	cmp    $0x3,%eax
  8041605745:	74 4d                	je     8041605794 <env_run+0x7b>
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
    }
  }
      
  curenv = e;  // текущая среда – е
  8041605747:	48 89 d8             	mov    %rbx,%rax
  804160574a:	48 a3 98 ab 61 41 80 	movabs %rax,0x804161ab98
  8041605751:	00 00 00 
  curenv->env_status = ENV_RUNNING; // устанавливаем статус среды на "выполняется"
  8041605754:	c7 83 d4 00 00 00 03 	movl   $0x3,0xd4(%rbx)
  804160575b:	00 00 00 
  curenv->env_runs++; // обновляем количество работающих контекстов
  804160575e:	83 83 d8 00 00 00 01 	addl   $0x1,0xd8(%rbx)

  env_pop_tf(&curenv->env_tf);
  8041605765:	48 89 df             	mov    %rbx,%rdi
  8041605768:	48 b8 eb 56 60 41 80 	movabs $0x80416056eb,%rax
  804160576f:	00 00 00 
  8041605772:	ff d0                	callq  *%rax
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
  8041605774:	4c 89 e7             	mov    %r12,%rdi
  8041605777:	48 b8 46 56 60 41 80 	movabs $0x8041605646,%rax
  804160577e:	00 00 00 
  8041605781:	ff d0                	callq  *%rax
      if (old == e) { // e - аргумент функции, который к нам пришел
  8041605783:	49 39 dc             	cmp    %rbx,%r12
  8041605786:	75 bf                	jne    8041605747 <env_run+0x2e>
        sched_yield();  // переключение системными вызовами
  8041605788:	48 b8 f5 6b 60 41 80 	movabs $0x8041606bf5,%rax
  804160578f:	00 00 00 
  8041605792:	ff d0                	callq  *%rax
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
  8041605794:	41 c7 84 24 d4 00 00 	movl   $0x2,0xd4(%r12)
  804160579b:	00 02 00 00 00 
  80416057a0:	eb a5                	jmp    8041605747 <env_run+0x2e>

00000080416057a2 <rtc_timer_pic_interrupt>:
  // DELETED in LAB 5 end
  rtc_init();
}

static void
rtc_timer_pic_interrupt(void) {
  80416057a2:	55                   	push   %rbp
  80416057a3:	48 89 e5             	mov    %rsp,%rbp
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  80416057a6:	66 a1 c8 a7 61 41 80 	movabs 0x804161a7c8,%ax
  80416057ad:	00 00 00 
  80416057b0:	89 c7                	mov    %eax,%edi
  80416057b2:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  80416057b8:	48 b8 92 58 60 41 80 	movabs $0x8041605892,%rax
  80416057bf:	00 00 00 
  80416057c2:	ff d0                	callq  *%rax
}
  80416057c4:	5d                   	pop    %rbp
  80416057c5:	c3                   	retq   

00000080416057c6 <rtc_init>:
  __asm __volatile("inb %w1,%0"
  80416057c6:	b9 70 00 00 00       	mov    $0x70,%ecx
  80416057cb:	89 ca                	mov    %ecx,%edx
  80416057cd:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) & ~NMI_LOCK);
}

static inline void
nmi_disable(void) {
  outb(0x70, inb(0x70) | NMI_LOCK);
  80416057ce:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  80416057d1:	ee                   	out    %al,(%dx)
  80416057d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  80416057d7:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416057d8:	be 71 00 00 00       	mov    $0x71,%esi
  80416057dd:	89 f2                	mov    %esi,%edx
  80416057df:	ec                   	in     (%dx),%al
  
  // меняем делитель частоты регистра часов А,
  // чтобы прерывания приходили раз в полсекунды
  outb(IO_RTC_CMND, RTC_AREG);
  reg_a = inb(IO_RTC_DATA);
  reg_a = reg_a | 0x0F; // биты 0-3 = 1 => 500 мс (2 Гц) 
  80416057e0:	83 c8 0f             	or     $0xf,%eax
  __asm __volatile("outb %0,%w1"
  80416057e3:	ee                   	out    %al,(%dx)
  80416057e4:	b8 0b 00 00 00       	mov    $0xb,%eax
  80416057e9:	89 ca                	mov    %ecx,%edx
  80416057eb:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416057ec:	89 f2                	mov    %esi,%edx
  80416057ee:	ec                   	in     (%dx),%al
  outb(IO_RTC_DATA, reg_a);

  // устанавливаем бит RTC_PIE в регистре часов В
  outb(IO_RTC_CMND, RTC_BREG);
  reg_b = inb(IO_RTC_DATA);
  reg_b = reg_b | RTC_PIE; 
  80416057ef:	83 c8 40             	or     $0x40,%eax
  __asm __volatile("outb %0,%w1"
  80416057f2:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416057f3:	89 ca                	mov    %ecx,%edx
  80416057f5:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  80416057f6:	83 e0 7f             	and    $0x7f,%eax
  80416057f9:	ee                   	out    %al,(%dx)
  outb(IO_RTC_DATA, reg_b);

  // разрешить прерывания
  nmi_enable();
  // LAB 4 code end
}
  80416057fa:	c3                   	retq   

00000080416057fb <rtc_timer_init>:
rtc_timer_init(void) {
  80416057fb:	55                   	push   %rbp
  80416057fc:	48 89 e5             	mov    %rsp,%rbp
  rtc_init();
  80416057ff:	48 b8 c6 57 60 41 80 	movabs $0x80416057c6,%rax
  8041605806:	00 00 00 
  8041605809:	ff d0                	callq  *%rax
}
  804160580b:	5d                   	pop    %rbp
  804160580c:	c3                   	retq   

000000804160580d <rtc_check_status>:
  804160580d:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041605812:	ba 70 00 00 00       	mov    $0x70,%edx
  8041605817:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041605818:	ba 71 00 00 00       	mov    $0x71,%edx
  804160581d:	ec                   	in     (%dx),%al
  outb(IO_RTC_CMND, RTC_CREG);
  status = inb(IO_RTC_DATA);
  // LAB 4 code end

  return status;
}
  804160581e:	c3                   	retq   

000000804160581f <rtc_timer_pic_handle>:
rtc_timer_pic_handle(void) {
  804160581f:	55                   	push   %rbp
  8041605820:	48 89 e5             	mov    %rsp,%rbp
  rtc_check_status();
  8041605823:	48 b8 0d 58 60 41 80 	movabs $0x804160580d,%rax
  804160582a:	00 00 00 
  804160582d:	ff d0                	callq  *%rax
  pic_send_eoi(IRQ_CLOCK);
  804160582f:	bf 08 00 00 00       	mov    $0x8,%edi
  8041605834:	48 b8 f7 59 60 41 80 	movabs $0x80416059f7,%rax
  804160583b:	00 00 00 
  804160583e:	ff d0                	callq  *%rax
}
  8041605840:	5d                   	pop    %rbp
  8041605841:	c3                   	retq   

0000008041605842 <mc146818_read>:
  __asm __volatile("outb %0,%w1"
  8041605842:	ba 70 00 00 00       	mov    $0x70,%edx
  8041605847:	89 f8                	mov    %edi,%eax
  8041605849:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160584a:	ba 71 00 00 00       	mov    $0x71,%edx
  804160584f:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg) {
  outb(IO_RTC_CMND, reg);
  return inb(IO_RTC_DATA);
  8041605850:	0f b6 c0             	movzbl %al,%eax
}
  8041605853:	c3                   	retq   

0000008041605854 <mc146818_write>:
  __asm __volatile("outb %0,%w1"
  8041605854:	ba 70 00 00 00       	mov    $0x70,%edx
  8041605859:	89 f8                	mov    %edi,%eax
  804160585b:	ee                   	out    %al,(%dx)
  804160585c:	ba 71 00 00 00       	mov    $0x71,%edx
  8041605861:	89 f0                	mov    %esi,%eax
  8041605863:	ee                   	out    %al,(%dx)

void
mc146818_write(unsigned reg, unsigned datum) {
  outb(IO_RTC_CMND, reg);
  outb(IO_RTC_DATA, datum);
}
  8041605864:	c3                   	retq   

0000008041605865 <mc146818_read16>:
  8041605865:	41 b8 70 00 00 00    	mov    $0x70,%r8d
  804160586b:	89 f8                	mov    %edi,%eax
  804160586d:	44 89 c2             	mov    %r8d,%edx
  8041605870:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041605871:	b9 71 00 00 00       	mov    $0x71,%ecx
  8041605876:	89 ca                	mov    %ecx,%edx
  8041605878:	ec                   	in     (%dx),%al
  8041605879:	89 c6                	mov    %eax,%esi

unsigned
mc146818_read16(unsigned reg) {
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  804160587b:	8d 47 01             	lea    0x1(%rdi),%eax
  __asm __volatile("outb %0,%w1"
  804160587e:	44 89 c2             	mov    %r8d,%edx
  8041605881:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041605882:	89 ca                	mov    %ecx,%edx
  8041605884:	ec                   	in     (%dx),%al
  return inb(IO_RTC_DATA);
  8041605885:	0f b6 c0             	movzbl %al,%eax
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041605888:	c1 e0 08             	shl    $0x8,%eax
  return inb(IO_RTC_DATA);
  804160588b:	40 0f b6 f6          	movzbl %sil,%esi
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  804160588f:	09 f0                	or     %esi,%eax
  8041605891:	c3                   	retq   

0000008041605892 <irq_setmask_8259A>:
}

void
irq_setmask_8259A(uint16_t mask) {
  int i;
  irq_mask_8259A = mask;
  8041605892:	89 f8                	mov    %edi,%eax
  8041605894:	66 a3 c8 a7 61 41 80 	movabs %ax,0x804161a7c8
  804160589b:	00 00 00 
  if (!didinit)
  804160589e:	48 b8 a8 ab 61 41 80 	movabs $0x804161aba8,%rax
  80416058a5:	00 00 00 
  80416058a8:	80 38 00             	cmpb   $0x0,(%rax)
  80416058ab:	75 01                	jne    80416058ae <irq_setmask_8259A+0x1c>
  80416058ad:	c3                   	retq   
irq_setmask_8259A(uint16_t mask) {
  80416058ae:	55                   	push   %rbp
  80416058af:	48 89 e5             	mov    %rsp,%rbp
  80416058b2:	41 56                	push   %r14
  80416058b4:	41 55                	push   %r13
  80416058b6:	41 54                	push   %r12
  80416058b8:	53                   	push   %rbx
  80416058b9:	41 89 fc             	mov    %edi,%r12d
  80416058bc:	89 f8                	mov    %edi,%eax
  __asm __volatile("outb %0,%w1"
  80416058be:	ba 21 00 00 00       	mov    $0x21,%edx
  80416058c3:	ee                   	out    %al,(%dx)
    return;
  outb(IO_PIC1_DATA, (char)mask);
  outb(IO_PIC2_DATA, (char)(mask >> 8));
  80416058c4:	66 c1 e8 08          	shr    $0x8,%ax
  80416058c8:	ba a1 00 00 00       	mov    $0xa1,%edx
  80416058cd:	ee                   	out    %al,(%dx)
  cprintf("enabled interrupts:");
  80416058ce:	48 bf eb 91 60 41 80 	movabs $0x80416091eb,%rdi
  80416058d5:	00 00 00 
  80416058d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416058dd:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416058e4:	00 00 00 
  80416058e7:	ff d2                	callq  *%rdx
  for (i = 0; i < 16; i++)
  80416058e9:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (~mask & (1 << i))
  80416058ee:	45 0f b7 e4          	movzwl %r12w,%r12d
  80416058f2:	41 f7 d4             	not    %r12d
      cprintf(" %d", i);
  80416058f5:	49 be c8 99 60 41 80 	movabs $0x80416099c8,%r14
  80416058fc:	00 00 00 
  80416058ff:	49 bd 6a 5a 60 41 80 	movabs $0x8041605a6a,%r13
  8041605906:	00 00 00 
  8041605909:	eb 15                	jmp    8041605920 <irq_setmask_8259A+0x8e>
  804160590b:	89 de                	mov    %ebx,%esi
  804160590d:	4c 89 f7             	mov    %r14,%rdi
  8041605910:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605915:	41 ff d5             	callq  *%r13
  for (i = 0; i < 16; i++)
  8041605918:	83 c3 01             	add    $0x1,%ebx
  804160591b:	83 fb 10             	cmp    $0x10,%ebx
  804160591e:	74 08                	je     8041605928 <irq_setmask_8259A+0x96>
    if (~mask & (1 << i))
  8041605920:	41 0f a3 dc          	bt     %ebx,%r12d
  8041605924:	73 f2                	jae    8041605918 <irq_setmask_8259A+0x86>
  8041605926:	eb e3                	jmp    804160590b <irq_setmask_8259A+0x79>
  cprintf("\n");
  8041605928:	48 bf 70 84 60 41 80 	movabs $0x8041608470,%rdi
  804160592f:	00 00 00 
  8041605932:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605937:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  804160593e:	00 00 00 
  8041605941:	ff d2                	callq  *%rdx
}
  8041605943:	5b                   	pop    %rbx
  8041605944:	41 5c                	pop    %r12
  8041605946:	41 5d                	pop    %r13
  8041605948:	41 5e                	pop    %r14
  804160594a:	5d                   	pop    %rbp
  804160594b:	c3                   	retq   

000000804160594c <pic_init>:
  didinit = 1;
  804160594c:	48 b8 a8 ab 61 41 80 	movabs $0x804161aba8,%rax
  8041605953:	00 00 00 
  8041605956:	c6 00 01             	movb   $0x1,(%rax)
  8041605959:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160595e:	be 21 00 00 00       	mov    $0x21,%esi
  8041605963:	89 f2                	mov    %esi,%edx
  8041605965:	ee                   	out    %al,(%dx)
  8041605966:	b9 a1 00 00 00       	mov    $0xa1,%ecx
  804160596b:	89 ca                	mov    %ecx,%edx
  804160596d:	ee                   	out    %al,(%dx)
  804160596e:	41 b9 11 00 00 00    	mov    $0x11,%r9d
  8041605974:	bf 20 00 00 00       	mov    $0x20,%edi
  8041605979:	44 89 c8             	mov    %r9d,%eax
  804160597c:	89 fa                	mov    %edi,%edx
  804160597e:	ee                   	out    %al,(%dx)
  804160597f:	b8 20 00 00 00       	mov    $0x20,%eax
  8041605984:	89 f2                	mov    %esi,%edx
  8041605986:	ee                   	out    %al,(%dx)
  8041605987:	b8 04 00 00 00       	mov    $0x4,%eax
  804160598c:	ee                   	out    %al,(%dx)
  804160598d:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  8041605993:	44 89 c0             	mov    %r8d,%eax
  8041605996:	ee                   	out    %al,(%dx)
  8041605997:	be a0 00 00 00       	mov    $0xa0,%esi
  804160599c:	44 89 c8             	mov    %r9d,%eax
  804160599f:	89 f2                	mov    %esi,%edx
  80416059a1:	ee                   	out    %al,(%dx)
  80416059a2:	b8 28 00 00 00       	mov    $0x28,%eax
  80416059a7:	89 ca                	mov    %ecx,%edx
  80416059a9:	ee                   	out    %al,(%dx)
  80416059aa:	b8 02 00 00 00       	mov    $0x2,%eax
  80416059af:	ee                   	out    %al,(%dx)
  80416059b0:	44 89 c0             	mov    %r8d,%eax
  80416059b3:	ee                   	out    %al,(%dx)
  80416059b4:	41 b8 68 00 00 00    	mov    $0x68,%r8d
  80416059ba:	44 89 c0             	mov    %r8d,%eax
  80416059bd:	89 fa                	mov    %edi,%edx
  80416059bf:	ee                   	out    %al,(%dx)
  80416059c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416059c5:	89 c8                	mov    %ecx,%eax
  80416059c7:	ee                   	out    %al,(%dx)
  80416059c8:	44 89 c0             	mov    %r8d,%eax
  80416059cb:	89 f2                	mov    %esi,%edx
  80416059cd:	ee                   	out    %al,(%dx)
  80416059ce:	89 c8                	mov    %ecx,%eax
  80416059d0:	ee                   	out    %al,(%dx)
  if (irq_mask_8259A != 0xFFFF)
  80416059d1:	66 a1 c8 a7 61 41 80 	movabs 0x804161a7c8,%ax
  80416059d8:	00 00 00 
  80416059db:	66 83 f8 ff          	cmp    $0xffff,%ax
  80416059df:	75 01                	jne    80416059e2 <pic_init+0x96>
  80416059e1:	c3                   	retq   
pic_init(void) {
  80416059e2:	55                   	push   %rbp
  80416059e3:	48 89 e5             	mov    %rsp,%rbp
    irq_setmask_8259A(irq_mask_8259A);
  80416059e6:	0f b7 f8             	movzwl %ax,%edi
  80416059e9:	48 b8 92 58 60 41 80 	movabs $0x8041605892,%rax
  80416059f0:	00 00 00 
  80416059f3:	ff d0                	callq  *%rax
}
  80416059f5:	5d                   	pop    %rbp
  80416059f6:	c3                   	retq   

00000080416059f7 <pic_send_eoi>:

void
pic_send_eoi(uint8_t irq) {
  if (irq >= 8)
  80416059f7:	40 80 ff 07          	cmp    $0x7,%dil
  80416059fb:	76 0b                	jbe    8041605a08 <pic_send_eoi+0x11>
  80416059fd:	b8 20 00 00 00       	mov    $0x20,%eax
  8041605a02:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041605a07:	ee                   	out    %al,(%dx)
  8041605a08:	b8 20 00 00 00       	mov    $0x20,%eax
  8041605a0d:	ba 20 00 00 00       	mov    $0x20,%edx
  8041605a12:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_CMND, PIC_EOI);
  outb(IO_PIC1_CMND, PIC_EOI);
}
  8041605a13:	c3                   	retq   

0000008041605a14 <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  8041605a14:	55                   	push   %rbp
  8041605a15:	48 89 e5             	mov    %rsp,%rbp
  8041605a18:	53                   	push   %rbx
  8041605a19:	48 83 ec 08          	sub    $0x8,%rsp
  8041605a1d:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  8041605a20:	48 b8 0a 0d 60 41 80 	movabs $0x8041600d0a,%rax
  8041605a27:	00 00 00 
  8041605a2a:	ff d0                	callq  *%rax
  (*cnt)++;
  8041605a2c:	83 03 01             	addl   $0x1,(%rbx)
}
  8041605a2f:	48 83 c4 08          	add    $0x8,%rsp
  8041605a33:	5b                   	pop    %rbx
  8041605a34:	5d                   	pop    %rbp
  8041605a35:	c3                   	retq   

0000008041605a36 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8041605a36:	55                   	push   %rbp
  8041605a37:	48 89 e5             	mov    %rsp,%rbp
  8041605a3a:	48 83 ec 10          	sub    $0x10,%rsp
  8041605a3e:	48 89 fa             	mov    %rdi,%rdx
  8041605a41:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  8041605a44:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  8041605a4b:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  8041605a4f:	48 bf 14 5a 60 41 80 	movabs $0x8041605a14,%rdi
  8041605a56:	00 00 00 
  8041605a59:	48 b8 f9 70 60 41 80 	movabs $0x80416070f9,%rax
  8041605a60:	00 00 00 
  8041605a63:	ff d0                	callq  *%rax
  return cnt;
}
  8041605a65:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041605a68:	c9                   	leaveq 
  8041605a69:	c3                   	retq   

0000008041605a6a <cprintf>:

int
cprintf(const char *fmt, ...) {
  8041605a6a:	55                   	push   %rbp
  8041605a6b:	48 89 e5             	mov    %rsp,%rbp
  8041605a6e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041605a75:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8041605a7c:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041605a83:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041605a8a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041605a91:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041605a98:	84 c0                	test   %al,%al
  8041605a9a:	74 20                	je     8041605abc <cprintf+0x52>
  8041605a9c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041605aa0:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041605aa4:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041605aa8:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041605aac:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041605ab0:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041605ab4:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041605ab8:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8041605abc:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8041605ac3:	00 00 00 
  8041605ac6:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041605acd:	00 00 00 
  8041605ad0:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041605ad4:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041605adb:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041605ae2:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8041605ae9:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041605af0:	48 b8 36 5a 60 41 80 	movabs $0x8041605a36,%rax
  8041605af7:	00 00 00 
  8041605afa:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8041605afc:	c9                   	leaveq 
  8041605afd:	c3                   	retq   

0000008041605afe <clock_idt_init>:

void
clock_idt_init(void) {
  extern void (*clock_thdlr)(void);
  // init idt structure
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041605afe:	48 ba 6e 61 60 41 80 	movabs $0x804160616e,%rdx
  8041605b05:	00 00 00 
  8041605b08:	48 b8 c0 ab 61 41 80 	movabs $0x804161abc0,%rax
  8041605b0f:	00 00 00 
  8041605b12:	66 89 90 00 02 00 00 	mov    %dx,0x200(%rax)
  8041605b19:	66 c7 80 02 02 00 00 	movw   $0x8,0x202(%rax)
  8041605b20:	08 00 
  8041605b22:	c6 80 04 02 00 00 00 	movb   $0x0,0x204(%rax)
  8041605b29:	c6 80 05 02 00 00 8e 	movb   $0x8e,0x205(%rax)
  8041605b30:	48 89 d6             	mov    %rdx,%rsi
  8041605b33:	48 c1 ee 10          	shr    $0x10,%rsi
  8041605b37:	66 89 b0 06 02 00 00 	mov    %si,0x206(%rax)
  8041605b3e:	48 89 d1             	mov    %rdx,%rcx
  8041605b41:	48 c1 e9 20          	shr    $0x20,%rcx
  8041605b45:	89 88 08 02 00 00    	mov    %ecx,0x208(%rax)
  8041605b4b:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%rax)
  8041605b52:	00 00 00 
  SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041605b55:	66 89 90 80 02 00 00 	mov    %dx,0x280(%rax)
  8041605b5c:	66 c7 80 82 02 00 00 	movw   $0x8,0x282(%rax)
  8041605b63:	08 00 
  8041605b65:	c6 80 84 02 00 00 00 	movb   $0x0,0x284(%rax)
  8041605b6c:	c6 80 85 02 00 00 8e 	movb   $0x8e,0x285(%rax)
  8041605b73:	66 89 b0 86 02 00 00 	mov    %si,0x286(%rax)
  8041605b7a:	89 88 88 02 00 00    	mov    %ecx,0x288(%rax)
  8041605b80:	c7 80 8c 02 00 00 00 	movl   $0x0,0x28c(%rax)
  8041605b87:	00 00 00 
  __asm __volatile("lidt (%0)"
  8041605b8a:	48 b8 d0 a7 61 41 80 	movabs $0x804161a7d0,%rax
  8041605b91:	00 00 00 
  8041605b94:	0f 01 18             	lidt   (%rax)
  lidt(&idt_pd);
}
  8041605b97:	c3                   	retq   

0000008041605b98 <print_regs>:
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  }
}

void
print_regs(struct PushRegs *regs) {
  8041605b98:	55                   	push   %rbp
  8041605b99:	48 89 e5             	mov    %rsp,%rbp
  8041605b9c:	41 54                	push   %r12
  8041605b9e:	53                   	push   %rbx
  8041605b9f:	49 89 fc             	mov    %rdi,%r12
  cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  8041605ba2:	48 8b 37             	mov    (%rdi),%rsi
  8041605ba5:	48 bf ff 91 60 41 80 	movabs $0x80416091ff,%rdi
  8041605bac:	00 00 00 
  8041605baf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605bb4:	48 bb 6a 5a 60 41 80 	movabs $0x8041605a6a,%rbx
  8041605bbb:	00 00 00 
  8041605bbe:	ff d3                	callq  *%rbx
  cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  8041605bc0:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
  8041605bc5:	48 bf 0f 92 60 41 80 	movabs $0x804160920f,%rdi
  8041605bcc:	00 00 00 
  8041605bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605bd4:	ff d3                	callq  *%rbx
  cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  8041605bd6:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  8041605bdb:	48 bf 1f 92 60 41 80 	movabs $0x804160921f,%rdi
  8041605be2:	00 00 00 
  8041605be5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605bea:	ff d3                	callq  *%rbx
  cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  8041605bec:	49 8b 74 24 18       	mov    0x18(%r12),%rsi
  8041605bf1:	48 bf 2f 92 60 41 80 	movabs $0x804160922f,%rdi
  8041605bf8:	00 00 00 
  8041605bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c00:	ff d3                	callq  *%rbx
  cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  8041605c02:	49 8b 74 24 20       	mov    0x20(%r12),%rsi
  8041605c07:	48 bf 3f 92 60 41 80 	movabs $0x804160923f,%rdi
  8041605c0e:	00 00 00 
  8041605c11:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c16:	ff d3                	callq  *%rbx
  cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  8041605c18:	49 8b 74 24 28       	mov    0x28(%r12),%rsi
  8041605c1d:	48 bf 4f 92 60 41 80 	movabs $0x804160924f,%rdi
  8041605c24:	00 00 00 
  8041605c27:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c2c:	ff d3                	callq  *%rbx
  cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  8041605c2e:	49 8b 74 24 30       	mov    0x30(%r12),%rsi
  8041605c33:	48 bf 5f 92 60 41 80 	movabs $0x804160925f,%rdi
  8041605c3a:	00 00 00 
  8041605c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c42:	ff d3                	callq  *%rbx
  cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  8041605c44:	49 8b 74 24 38       	mov    0x38(%r12),%rsi
  8041605c49:	48 bf 6f 92 60 41 80 	movabs $0x804160926f,%rdi
  8041605c50:	00 00 00 
  8041605c53:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c58:	ff d3                	callq  *%rbx
  cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  8041605c5a:	49 8b 74 24 48       	mov    0x48(%r12),%rsi
  8041605c5f:	48 bf 7f 92 60 41 80 	movabs $0x804160927f,%rdi
  8041605c66:	00 00 00 
  8041605c69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c6e:	ff d3                	callq  *%rbx
  cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  8041605c70:	49 8b 74 24 40       	mov    0x40(%r12),%rsi
  8041605c75:	48 bf 8f 92 60 41 80 	movabs $0x804160928f,%rdi
  8041605c7c:	00 00 00 
  8041605c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c84:	ff d3                	callq  *%rbx
  cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  8041605c86:	49 8b 74 24 50       	mov    0x50(%r12),%rsi
  8041605c8b:	48 bf 9f 92 60 41 80 	movabs $0x804160929f,%rdi
  8041605c92:	00 00 00 
  8041605c95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605c9a:	ff d3                	callq  *%rbx
  cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  8041605c9c:	49 8b 74 24 68       	mov    0x68(%r12),%rsi
  8041605ca1:	48 bf af 92 60 41 80 	movabs $0x80416092af,%rdi
  8041605ca8:	00 00 00 
  8041605cab:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605cb0:	ff d3                	callq  *%rbx
  cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  8041605cb2:	49 8b 74 24 58       	mov    0x58(%r12),%rsi
  8041605cb7:	48 bf bf 92 60 41 80 	movabs $0x80416092bf,%rdi
  8041605cbe:	00 00 00 
  8041605cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605cc6:	ff d3                	callq  *%rbx
  cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  8041605cc8:	49 8b 74 24 60       	mov    0x60(%r12),%rsi
  8041605ccd:	48 bf cf 92 60 41 80 	movabs $0x80416092cf,%rdi
  8041605cd4:	00 00 00 
  8041605cd7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605cdc:	ff d3                	callq  *%rbx
  cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
  8041605cde:	49 8b 74 24 70       	mov    0x70(%r12),%rsi
  8041605ce3:	48 bf df 92 60 41 80 	movabs $0x80416092df,%rdi
  8041605cea:	00 00 00 
  8041605ced:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605cf2:	ff d3                	callq  *%rbx
}
  8041605cf4:	5b                   	pop    %rbx
  8041605cf5:	41 5c                	pop    %r12
  8041605cf7:	5d                   	pop    %rbp
  8041605cf8:	c3                   	retq   

0000008041605cf9 <print_trapframe>:
print_trapframe(struct Trapframe *tf) {
  8041605cf9:	55                   	push   %rbp
  8041605cfa:	48 89 e5             	mov    %rsp,%rbp
  8041605cfd:	41 54                	push   %r12
  8041605cff:	53                   	push   %rbx
  8041605d00:	48 89 fb             	mov    %rdi,%rbx
  cprintf("TRAP frame at %p\n", tf);
  8041605d03:	48 89 fe             	mov    %rdi,%rsi
  8041605d06:	48 bf 44 93 60 41 80 	movabs $0x8041609344,%rdi
  8041605d0d:	00 00 00 
  8041605d10:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605d15:	49 bc 6a 5a 60 41 80 	movabs $0x8041605a6a,%r12
  8041605d1c:	00 00 00 
  8041605d1f:	41 ff d4             	callq  *%r12
  print_regs(&tf->tf_regs);
  8041605d22:	48 89 df             	mov    %rbx,%rdi
  8041605d25:	48 b8 98 5b 60 41 80 	movabs $0x8041605b98,%rax
  8041605d2c:	00 00 00 
  8041605d2f:	ff d0                	callq  *%rax
  cprintf("  es   0x----%04x\n", tf->tf_es);
  8041605d31:	0f b7 73 78          	movzwl 0x78(%rbx),%esi
  8041605d35:	48 bf 56 93 60 41 80 	movabs $0x8041609356,%rdi
  8041605d3c:	00 00 00 
  8041605d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605d44:	41 ff d4             	callq  *%r12
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  8041605d47:	0f b7 b3 80 00 00 00 	movzwl 0x80(%rbx),%esi
  8041605d4e:	48 bf 69 93 60 41 80 	movabs $0x8041609369,%rdi
  8041605d55:	00 00 00 
  8041605d58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605d5d:	41 ff d4             	callq  *%r12
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041605d60:	48 8b b3 88 00 00 00 	mov    0x88(%rbx),%rsi
  if (trapno < sizeof(excnames) / sizeof(excnames[0]))
  8041605d67:	83 fe 13             	cmp    $0x13,%esi
  8041605d6a:	0f 86 68 01 00 00    	jbe    8041605ed8 <print_trapframe+0x1df>
    return "System call";
  8041605d70:	48 ba ef 92 60 41 80 	movabs $0x80416092ef,%rdx
  8041605d77:	00 00 00 
  if (trapno == T_SYSCALL)
  8041605d7a:	83 fe 30             	cmp    $0x30,%esi
  8041605d7d:	74 1e                	je     8041605d9d <print_trapframe+0xa4>
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  8041605d7f:	8d 46 e0             	lea    -0x20(%rsi),%eax
    return "Hardware Interrupt";
  8041605d82:	83 f8 0f             	cmp    $0xf,%eax
  8041605d85:	48 ba fb 92 60 41 80 	movabs $0x80416092fb,%rdx
  8041605d8c:	00 00 00 
  8041605d8f:	48 b8 0a 93 60 41 80 	movabs $0x804160930a,%rax
  8041605d96:	00 00 00 
  8041605d99:	48 0f 46 d0          	cmovbe %rax,%rdx
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041605d9d:	48 bf 7c 93 60 41 80 	movabs $0x804160937c,%rdi
  8041605da4:	00 00 00 
  8041605da7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605dac:	48 b9 6a 5a 60 41 80 	movabs $0x8041605a6a,%rcx
  8041605db3:	00 00 00 
  8041605db6:	ff d1                	callq  *%rcx
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041605db8:	48 b8 c0 bb 61 41 80 	movabs $0x804161bbc0,%rax
  8041605dbf:	00 00 00 
  8041605dc2:	48 39 18             	cmp    %rbx,(%rax)
  8041605dc5:	0f 84 23 01 00 00    	je     8041605eee <print_trapframe+0x1f5>
  cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  8041605dcb:	48 8b b3 90 00 00 00 	mov    0x90(%rbx),%rsi
  8041605dd2:	48 bf 9f 93 60 41 80 	movabs $0x804160939f,%rdi
  8041605dd9:	00 00 00 
  8041605ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605de1:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041605de8:	00 00 00 
  8041605deb:	ff d2                	callq  *%rdx
  if (tf->tf_trapno == T_PGFLT)
  8041605ded:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041605df4:	0e 
  8041605df5:	0f 85 24 01 00 00    	jne    8041605f1f <print_trapframe+0x226>
            tf->tf_err & 1 ? "protection" : "not-present");
  8041605dfb:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
    cprintf(" [%s, %s, %s]\n",
  8041605e02:	48 89 c2             	mov    %rax,%rdx
  8041605e05:	83 e2 01             	and    $0x1,%edx
  8041605e08:	48 b9 1d 93 60 41 80 	movabs $0x804160931d,%rcx
  8041605e0f:	00 00 00 
  8041605e12:	48 ba 28 93 60 41 80 	movabs $0x8041609328,%rdx
  8041605e19:	00 00 00 
  8041605e1c:	48 0f 44 ca          	cmove  %rdx,%rcx
  8041605e20:	48 89 c2             	mov    %rax,%rdx
  8041605e23:	83 e2 02             	and    $0x2,%edx
  8041605e26:	48 ba 34 93 60 41 80 	movabs $0x8041609334,%rdx
  8041605e2d:	00 00 00 
  8041605e30:	48 be 3a 93 60 41 80 	movabs $0x804160933a,%rsi
  8041605e37:	00 00 00 
  8041605e3a:	48 0f 44 d6          	cmove  %rsi,%rdx
  8041605e3e:	83 e0 04             	and    $0x4,%eax
  8041605e41:	48 be 3f 93 60 41 80 	movabs $0x804160933f,%rsi
  8041605e48:	00 00 00 
  8041605e4b:	48 b8 6e 94 60 41 80 	movabs $0x804160946e,%rax
  8041605e52:	00 00 00 
  8041605e55:	48 0f 44 f0          	cmove  %rax,%rsi
  8041605e59:	48 bf ae 93 60 41 80 	movabs $0x80416093ae,%rdi
  8041605e60:	00 00 00 
  8041605e63:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605e68:	49 b8 6a 5a 60 41 80 	movabs $0x8041605a6a,%r8
  8041605e6f:	00 00 00 
  8041605e72:	41 ff d0             	callq  *%r8
  cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  8041605e75:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
  8041605e7c:	48 bf bd 93 60 41 80 	movabs $0x80416093bd,%rdi
  8041605e83:	00 00 00 
  8041605e86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605e8b:	49 bc 6a 5a 60 41 80 	movabs $0x8041605a6a,%r12
  8041605e92:	00 00 00 
  8041605e95:	41 ff d4             	callq  *%r12
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8041605e98:	0f b7 b3 a0 00 00 00 	movzwl 0xa0(%rbx),%esi
  8041605e9f:	48 bf cd 93 60 41 80 	movabs $0x80416093cd,%rdi
  8041605ea6:	00 00 00 
  8041605ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605eae:	41 ff d4             	callq  *%r12
  cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  8041605eb1:	48 8b b3 a8 00 00 00 	mov    0xa8(%rbx),%rsi
  8041605eb8:	48 bf e0 93 60 41 80 	movabs $0x80416093e0,%rdi
  8041605ebf:	00 00 00 
  8041605ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605ec7:	41 ff d4             	callq  *%r12
  if ((tf->tf_cs & 3) != 0) {
  8041605eca:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041605ed1:	75 6c                	jne    8041605f3f <print_trapframe+0x246>
}
  8041605ed3:	5b                   	pop    %rbx
  8041605ed4:	41 5c                	pop    %r12
  8041605ed6:	5d                   	pop    %rbp
  8041605ed7:	c3                   	retq   
    return excnames[trapno];
  8041605ed8:	48 63 c6             	movslq %esi,%rax
  8041605edb:	48 ba c0 95 60 41 80 	movabs $0x80416095c0,%rdx
  8041605ee2:	00 00 00 
  8041605ee5:	48 8b 14 c2          	mov    (%rdx,%rax,8),%rdx
  8041605ee9:	e9 af fe ff ff       	jmpq   8041605d9d <print_trapframe+0xa4>
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041605eee:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041605ef5:	0e 
  8041605ef6:	0f 85 cf fe ff ff    	jne    8041605dcb <print_trapframe+0xd2>
  __asm __volatile("movq %%cr2,%0"
  8041605efc:	0f 20 d6             	mov    %cr2,%rsi
    cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  8041605eff:	48 bf 8f 93 60 41 80 	movabs $0x804160938f,%rdi
  8041605f06:	00 00 00 
  8041605f09:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605f0e:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041605f15:	00 00 00 
  8041605f18:	ff d2                	callq  *%rdx
  8041605f1a:	e9 ac fe ff ff       	jmpq   8041605dcb <print_trapframe+0xd2>
    cprintf("\n");
  8041605f1f:	48 bf 70 84 60 41 80 	movabs $0x8041608470,%rdi
  8041605f26:	00 00 00 
  8041605f29:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605f2e:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041605f35:	00 00 00 
  8041605f38:	ff d2                	callq  *%rdx
  8041605f3a:	e9 36 ff ff ff       	jmpq   8041605e75 <print_trapframe+0x17c>
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
  8041605f3f:	48 8b b3 b0 00 00 00 	mov    0xb0(%rbx),%rsi
  8041605f46:	48 bf f0 93 60 41 80 	movabs $0x80416093f0,%rdi
  8041605f4d:	00 00 00 
  8041605f50:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605f55:	41 ff d4             	callq  *%r12
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  8041605f58:	0f b7 b3 b8 00 00 00 	movzwl 0xb8(%rbx),%esi
  8041605f5f:	48 bf 00 94 60 41 80 	movabs $0x8041609400,%rdi
  8041605f66:	00 00 00 
  8041605f69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605f6e:	41 ff d4             	callq  *%r12
}
  8041605f71:	e9 5d ff ff ff       	jmpq   8041605ed3 <print_trapframe+0x1da>

0000008041605f76 <trap>:
    env_destroy(curenv);
  }
}

void
trap(struct Trapframe *tf) {
  8041605f76:	55                   	push   %rbp
  8041605f77:	48 89 e5             	mov    %rsp,%rbp
  8041605f7a:	53                   	push   %rbx
  8041605f7b:	48 83 ec 08          	sub    $0x8,%rsp
  8041605f7f:	48 89 fe             	mov    %rdi,%rsi
  // The environment may have set DF and some versions
  // of GCC rely on DF being clear
  asm volatile("cld" ::
  8041605f82:	fc                   	cld    
                   : "cc");

  // Halt the CPU if some other CPU has called panic()
  extern char *panicstr;
  if (panicstr)
  8041605f83:	48 b8 00 a9 61 41 80 	movabs $0x804161a900,%rax
  8041605f8a:	00 00 00 
  8041605f8d:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041605f91:	74 01                	je     8041605f94 <trap+0x1e>
    asm volatile("hlt");
  8041605f93:	f4                   	hlt    
  __asm __volatile("pushfq; popq %0"
  8041605f94:	9c                   	pushfq 
  8041605f95:	58                   	pop    %rax

  // Check that interrupts are disabled.  If this assertion
  // fails, DO NOT be tempted to fix it by inserting a "cli" in
  // the interrupt path.
  assert(!(read_rflags() & FL_IF));
  8041605f96:	f6 c4 02             	test   $0x2,%ah
  8041605f99:	0f 85 bc 00 00 00    	jne    804160605b <trap+0xe5>

  if (debug) {
    cprintf("Incoming TRAP frame at %p\n", tf);
  }

  assert(curenv);
  8041605f9f:	48 a1 98 ab 61 41 80 	movabs 0x804161ab98,%rax
  8041605fa6:	00 00 00 
  8041605fa9:	48 85 c0             	test   %rax,%rax
  8041605fac:	0f 84 de 00 00 00    	je     8041606090 <trap+0x11a>

  // Garbage collect if current enviroment is a zombie
  if (curenv->env_status == ENV_DYING) {
  8041605fb2:	83 b8 d4 00 00 00 01 	cmpl   $0x1,0xd4(%rax)
  8041605fb9:	0f 84 01 01 00 00    	je     80416060c0 <trap+0x14a>
  }

  // Copy trap frame (which is currently on the stack)
  // into 'curenv->env_tf', so that running the environment
  // will restart at the trap point.
  curenv->env_tf = *tf;
  8041605fbf:	b9 30 00 00 00       	mov    $0x30,%ecx
  8041605fc4:	48 89 c7             	mov    %rax,%rdi
  8041605fc7:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  // The trapframe on the stack should be ignored from here on.
  tf = &curenv->env_tf;
  8041605fc9:	48 b8 98 ab 61 41 80 	movabs $0x804161ab98,%rax
  8041605fd0:	00 00 00 
  8041605fd3:	48 8b 18             	mov    (%rax),%rbx

  // Record that tf is the last real trapframe so
  // print_trapframe can print some additional information.
  last_tf = tf;
  8041605fd6:	48 89 d8             	mov    %rbx,%rax
  8041605fd9:	48 a3 c0 bb 61 41 80 	movabs %rax,0x804161bbc0
  8041605fe0:	00 00 00 
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
  8041605fe3:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  8041605fea:	48 83 f8 27          	cmp    $0x27,%rax
  8041605fee:	0f 84 f8 00 00 00    	je     80416060ec <trap+0x176>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {
  8041605ff4:	48 83 f8 28          	cmp    $0x28,%rax
  8041605ff8:	0f 84 1d 01 00 00    	je     804160611b <trap+0x1a5>
  print_trapframe(tf);
  8041605ffe:	48 89 df             	mov    %rbx,%rdi
  8041606001:	48 b8 f9 5c 60 41 80 	movabs $0x8041605cf9,%rax
  8041606008:	00 00 00 
  804160600b:	ff d0                	callq  *%rax
  if (!(tf->tf_cs & 0x3)) {
  804160600d:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041606014:	0f 84 1a 01 00 00    	je     8041606134 <trap+0x1be>
    env_destroy(curenv);
  804160601a:	48 b8 98 ab 61 41 80 	movabs $0x804161ab98,%rax
  8041606021:	00 00 00 
  8041606024:	48 8b 38             	mov    (%rax),%rdi
  8041606027:	48 b8 b5 56 60 41 80 	movabs $0x80416056b5,%rax
  804160602e:	00 00 00 
  8041606031:	ff d0                	callq  *%rax
  trap_dispatch(tf);

  // If we made it to this point, then no other environment was
  // scheduled, so we should return to the current environment
  // if doing so makes sense.
  if (curenv && curenv->env_status == ENV_RUNNING)
  8041606033:	48 a1 98 ab 61 41 80 	movabs 0x804161ab98,%rax
  804160603a:	00 00 00 
  804160603d:	48 85 c0             	test   %rax,%rax
  8041606040:	74 0d                	je     804160604f <trap+0xd9>
  8041606042:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  8041606049:	0f 84 0f 01 00 00    	je     804160615e <trap+0x1e8>
    env_run(curenv);
  else
    sched_yield();
  804160604f:	48 b8 f5 6b 60 41 80 	movabs $0x8041606bf5,%rax
  8041606056:	00 00 00 
  8041606059:	ff d0                	callq  *%rax
  assert(!(read_rflags() & FL_IF));
  804160605b:	48 b9 13 94 60 41 80 	movabs $0x8041609413,%rcx
  8041606062:	00 00 00 
  8041606065:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  804160606c:	00 00 00 
  804160606f:	be b4 00 00 00       	mov    $0xb4,%esi
  8041606074:	48 bf 2c 94 60 41 80 	movabs $0x804160942c,%rdi
  804160607b:	00 00 00 
  804160607e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606083:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  804160608a:	00 00 00 
  804160608d:	41 ff d0             	callq  *%r8
  assert(curenv);
  8041606090:	48 b9 38 94 60 41 80 	movabs $0x8041609438,%rcx
  8041606097:	00 00 00 
  804160609a:	48 ba d9 86 60 41 80 	movabs $0x80416086d9,%rdx
  80416060a1:	00 00 00 
  80416060a4:	be ba 00 00 00       	mov    $0xba,%esi
  80416060a9:	48 bf 2c 94 60 41 80 	movabs $0x804160942c,%rdi
  80416060b0:	00 00 00 
  80416060b3:	49 b8 71 02 60 41 80 	movabs $0x8041600271,%r8
  80416060ba:	00 00 00 
  80416060bd:	41 ff d0             	callq  *%r8
    env_free(curenv);
  80416060c0:	48 89 c7             	mov    %rax,%rdi
  80416060c3:	48 b8 46 56 60 41 80 	movabs $0x8041605646,%rax
  80416060ca:	00 00 00 
  80416060cd:	ff d0                	callq  *%rax
    curenv = NULL;
  80416060cf:	48 b8 98 ab 61 41 80 	movabs $0x804161ab98,%rax
  80416060d6:	00 00 00 
  80416060d9:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    sched_yield();
  80416060e0:	48 b8 f5 6b 60 41 80 	movabs $0x8041606bf5,%rax
  80416060e7:	00 00 00 
  80416060ea:	ff d0                	callq  *%rax
    cprintf("Spurious interrupt on irq 7\n");
  80416060ec:	48 bf 3f 94 60 41 80 	movabs $0x804160943f,%rdi
  80416060f3:	00 00 00 
  80416060f6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416060fb:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041606102:	00 00 00 
  8041606105:	ff d2                	callq  *%rdx
    print_trapframe(tf);
  8041606107:	48 89 df             	mov    %rbx,%rdi
  804160610a:	48 b8 f9 5c 60 41 80 	movabs $0x8041605cf9,%rax
  8041606111:	00 00 00 
  8041606114:	ff d0                	callq  *%rax
    return;
  8041606116:	e9 18 ff ff ff       	jmpq   8041606033 <trap+0xbd>
    timer_for_schedule->handle_interrupts();
  804160611b:	48 a1 60 dc 61 41 80 	movabs 0x804161dc60,%rax
  8041606122:	00 00 00 
  8041606125:	ff 50 20             	callq  *0x20(%rax)
    sched_yield();
  8041606128:	48 b8 f5 6b 60 41 80 	movabs $0x8041606bf5,%rax
  804160612f:	00 00 00 
  8041606132:	ff d0                	callq  *%rax
    panic("unhandled trap in kernel");
  8041606134:	48 ba 5c 94 60 41 80 	movabs $0x804160945c,%rdx
  804160613b:	00 00 00 
  804160613e:	be 9f 00 00 00       	mov    $0x9f,%esi
  8041606143:	48 bf 2c 94 60 41 80 	movabs $0x804160942c,%rdi
  804160614a:	00 00 00 
  804160614d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606152:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  8041606159:	00 00 00 
  804160615c:	ff d1                	callq  *%rcx
    env_run(curenv);
  804160615e:	48 89 c7             	mov    %rax,%rdi
  8041606161:	48 b8 19 57 60 41 80 	movabs $0x8041605719,%rax
  8041606168:	00 00 00 
  804160616b:	ff d0                	callq  *%rax
  804160616d:	90                   	nop

000000804160616e <clock_thdlr>:
  movq %rsp,%rdi
  call trap
  jmp .
#else
clock_thdlr:
  jmp .
  804160616e:	eb fe                	jmp    804160616e <clock_thdlr>

0000008041606170 <mmio_map_region>:
#if LAB <= 6
// Early variant of memory mapping that does 1:1 aligned area mapping
// in 2MB pages. You will need to reimplement this code with proper
// virtual memory mapping in the future.
static void *
mmio_map_region(physaddr_t pa, size_t size) {
  8041606170:	55                   	push   %rbp
  8041606171:	48 89 e5             	mov    %rsp,%rbp
  8041606174:	53                   	push   %rbx
  8041606175:	48 83 ec 08          	sub    $0x8,%rsp
  8041606179:	48 89 fb             	mov    %rdi,%rbx
  void map_addr_early_boot(uintptr_t addr, uintptr_t addr_phys, size_t sz);
  const physaddr_t base_2mb = 0x200000;
  uintptr_t org             = pa;
  size += pa & (base_2mb - 1);
  804160617c:	48 89 f8             	mov    %rdi,%rax
  804160617f:	25 ff ff 1f 00       	and    $0x1fffff,%eax
  size += (base_2mb - 1);
  8041606184:	48 8d 94 06 ff ff 1f 	lea    0x1fffff(%rsi,%rax,1),%rdx
  804160618b:	00 
  pa &= ~(base_2mb - 1);
  804160618c:	48 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%rdi
  size &= ~(base_2mb - 1);
  8041606193:	48 81 e2 00 00 e0 ff 	and    $0xffffffffffe00000,%rdx
  map_addr_early_boot(pa, pa, size);
  804160619a:	48 89 fe             	mov    %rdi,%rsi
  804160619d:	48 b8 49 01 60 41 80 	movabs $0x8041600149,%rax
  80416061a4:	00 00 00 
  80416061a7:	ff d0                	callq  *%rax
  return (void *)org;
}
  80416061a9:	48 89 d8             	mov    %rbx,%rax
  80416061ac:	48 83 c4 08          	add    $0x8,%rsp
  80416061b0:	5b                   	pop    %rbx
  80416061b1:	5d                   	pop    %rbp
  80416061b2:	c3                   	retq   

00000080416061b3 <acpi_find_table>:
//   return krsdp;
// }
// DELETED in LAB 5 end

// LAB 5 code
static void * acpi_find_table(const char * sign) {
  80416061b3:	55                   	push   %rbp
  80416061b4:	48 89 e5             	mov    %rsp,%rbp
  80416061b7:	41 57                	push   %r15
  80416061b9:	41 56                	push   %r14
  80416061bb:	41 55                	push   %r13
  80416061bd:	41 54                	push   %r12
  80416061bf:	53                   	push   %rbx
  80416061c0:	48 83 ec 28          	sub    $0x28,%rsp
  80416061c4:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  static size_t krsdt_len;
  static size_t krsdt_entsz;
 
  // uint8_t cksm = 0;

  if (!krsdt) {
  80416061c8:	48 b8 e0 bb 61 41 80 	movabs $0x804161bbe0,%rax
  80416061cf:	00 00 00 
  80416061d2:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416061d6:	0f 84 c1 00 00 00    	je     804160629d <acpi_find_table+0xea>
    }
  }

  ACPISDTHeader * hd = NULL;

  for (size_t i = 0; i < krsdt_len; i++) {
  80416061dc:	48 b8 d0 bb 61 41 80 	movabs $0x804161bbd0,%rax
  80416061e3:	00 00 00 
  80416061e6:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416061ea:	0f 84 a0 01 00 00    	je     8041606390 <acpi_find_table+0x1dd>
  80416061f0:	bb 00 00 00 00       	mov    $0x0,%ebx
    /* Assume little endian */
    uint64_t fadt_pa = 0;
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  80416061f5:	49 bf d8 bb 61 41 80 	movabs $0x804161bbd8,%r15
  80416061fc:	00 00 00 
  80416061ff:	49 be e0 bb 61 41 80 	movabs $0x804161bbe0,%r14
  8041606206:	00 00 00 

    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
  8041606209:	49 bd 70 61 60 41 80 	movabs $0x8041606170,%r13
  8041606210:	00 00 00 
    uint64_t fadt_pa = 0;
  8041606213:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160621a:	00 
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  804160621b:	49 8b 17             	mov    (%r15),%rdx
  804160621e:	49 8b 0e             	mov    (%r14),%rcx
  8041606221:	48 89 d0             	mov    %rdx,%rax
  8041606224:	48 0f af c3          	imul   %rbx,%rax
  8041606228:	48 8d 74 01 24       	lea    0x24(%rcx,%rax,1),%rsi
  804160622d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041606231:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041606238:	00 00 00 
  804160623b:	ff d0                	callq  *%rax
    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
  804160623d:	be 24 00 00 00       	mov    $0x24,%esi
  8041606242:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041606246:	41 ff d5             	callq  *%r13
    /* Remap since we can obtain table length only after mapping */
    hd = mmio_map_region(fadt_pa, hd->Length);
  8041606249:	8b 70 04             	mov    0x4(%rax),%esi
  804160624c:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041606250:	41 ff d5             	callq  *%r13
  8041606253:	49 89 c4             	mov    %rax,%r12

    if (!strncmp(hd->Signature, sign, 4)) return hd;
  8041606256:	ba 04 00 00 00       	mov    $0x4,%edx
  804160625b:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160625f:	48 89 c7             	mov    %rax,%rdi
  8041606262:	48 b8 1e 7b 60 41 80 	movabs $0x8041607b1e,%rax
  8041606269:	00 00 00 
  804160626c:	ff d0                	callq  *%rax
  804160626e:	85 c0                	test   %eax,%eax
  8041606270:	74 19                	je     804160628b <acpi_find_table+0xd8>
  for (size_t i = 0; i < krsdt_len; i++) {
  8041606272:	48 83 c3 01          	add    $0x1,%rbx
  8041606276:	48 b8 d0 bb 61 41 80 	movabs $0x804161bbd0,%rax
  804160627d:	00 00 00 
  8041606280:	48 39 18             	cmp    %rbx,(%rax)
  8041606283:	77 8e                	ja     8041606213 <acpi_find_table+0x60>
  }

  return NULL;
  8041606285:	41 bc 00 00 00 00    	mov    $0x0,%r12d
}
  804160628b:	4c 89 e0             	mov    %r12,%rax
  804160628e:	48 83 c4 28          	add    $0x28,%rsp
  8041606292:	5b                   	pop    %rbx
  8041606293:	41 5c                	pop    %r12
  8041606295:	41 5d                	pop    %r13
  8041606297:	41 5e                	pop    %r14
  8041606299:	41 5f                	pop    %r15
  804160629b:	5d                   	pop    %rbp
  804160629c:	c3                   	retq   
    if (!uefi_lp->ACPIRoot) {
  804160629d:	48 a1 00 a0 61 41 80 	movabs 0x804161a000,%rax
  80416062a4:	00 00 00 
  80416062a7:	48 8b 78 10          	mov    0x10(%rax),%rdi
  80416062ab:	48 85 ff             	test   %rdi,%rdi
  80416062ae:	0f 84 b2 00 00 00    	je     8041606366 <acpi_find_table+0x1b3>
    RSDP * krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  80416062b4:	be 24 00 00 00       	mov    $0x24,%esi
  80416062b9:	48 b8 70 61 60 41 80 	movabs $0x8041606170,%rax
  80416062c0:	00 00 00 
  80416062c3:	ff d0                	callq  *%rax
  80416062c5:	48 89 c3             	mov    %rax,%rbx
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  80416062c8:	44 8b 60 10          	mov    0x10(%rax),%r12d
    krsdt_entsz = 4;
  80416062cc:	48 b8 d8 bb 61 41 80 	movabs $0x804161bbd8,%rax
  80416062d3:	00 00 00 
  80416062d6:	48 c7 00 04 00 00 00 	movq   $0x4,(%rax)
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  80416062dd:	45 89 e4             	mov    %r12d,%r12d
    if (krsdp->Revision) {
  80416062e0:	80 7b 0f 00          	cmpb   $0x0,0xf(%rbx)
  80416062e4:	74 15                	je     80416062fb <acpi_find_table+0x148>
      rsdt_pa = krsdp->XsdtAddress;
  80416062e6:	4c 8b 63 18          	mov    0x18(%rbx),%r12
      krsdt_entsz = 8;
  80416062ea:	48 b8 d8 bb 61 41 80 	movabs $0x804161bbd8,%rax
  80416062f1:	00 00 00 
  80416062f4:	48 c7 00 08 00 00 00 	movq   $0x8,(%rax)
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  80416062fb:	be 24 00 00 00       	mov    $0x24,%esi
  8041606300:	4c 89 e7             	mov    %r12,%rdi
  8041606303:	49 be 70 61 60 41 80 	movabs $0x8041606170,%r14
  804160630a:	00 00 00 
  804160630d:	41 ff d6             	callq  *%r14
  8041606310:	49 bd e0 bb 61 41 80 	movabs $0x804161bbe0,%r13
  8041606317:	00 00 00 
  804160631a:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_map_region(rsdt_pa, krsdt->h.Length);
  804160631e:	8b 70 04             	mov    0x4(%rax),%esi
  8041606321:	4c 89 e7             	mov    %r12,%rdi
  8041606324:	41 ff d6             	callq  *%r14
  8041606327:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt_len = (krsdt->h.Length - sizeof(RSDT)) / 4;
  804160632b:	8b 40 04             	mov    0x4(%rax),%eax
  804160632e:	48 8d 48 dc          	lea    -0x24(%rax),%rcx
  8041606332:	48 89 ca             	mov    %rcx,%rdx
  8041606335:	48 c1 ea 02          	shr    $0x2,%rdx
  8041606339:	48 89 d0             	mov    %rdx,%rax
  804160633c:	48 a3 d0 bb 61 41 80 	movabs %rax,0x804161bbd0
  8041606343:	00 00 00 
    if (krsdp->Revision) {
  8041606346:	80 7b 0f 00          	cmpb   $0x0,0xf(%rbx)
  804160634a:	0f 84 8c fe ff ff    	je     80416061dc <acpi_find_table+0x29>
      krsdt_len = krsdt_len / 2;
  8041606350:	48 89 c8             	mov    %rcx,%rax
  8041606353:	48 c1 e8 03          	shr    $0x3,%rax
  8041606357:	48 a3 d0 bb 61 41 80 	movabs %rax,0x804161bbd0
  804160635e:	00 00 00 
  8041606361:	e9 76 fe ff ff       	jmpq   80416061dc <acpi_find_table+0x29>
      panic("No rsdp\n");
  8041606366:	48 ba 60 96 60 41 80 	movabs $0x8041609660,%rdx
  804160636d:	00 00 00 
  8041606370:	be 77 00 00 00       	mov    $0x77,%esi
  8041606375:	48 bf 69 96 60 41 80 	movabs $0x8041609669,%rdi
  804160637c:	00 00 00 
  804160637f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606384:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  804160638b:	00 00 00 
  804160638e:	ff d1                	callq  *%rcx
  return NULL;
  8041606390:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041606396:	e9 f0 fe ff ff       	jmpq   804160628b <acpi_find_table+0xd8>

000000804160639b <hpet_handle_interrupts_tim0>:
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
}

void
hpet_handle_interrupts_tim0(void) {
  804160639b:	55                   	push   %rbp
  804160639c:	48 89 e5             	mov    %rsp,%rbp
  pic_send_eoi(IRQ_TIMER);
  804160639f:	bf 00 00 00 00       	mov    $0x0,%edi
  80416063a4:	48 b8 f7 59 60 41 80 	movabs $0x80416059f7,%rax
  80416063ab:	00 00 00 
  80416063ae:	ff d0                	callq  *%rax
}
  80416063b0:	5d                   	pop    %rbp
  80416063b1:	c3                   	retq   

00000080416063b2 <hpet_handle_interrupts_tim1>:

void
hpet_handle_interrupts_tim1(void) {
  80416063b2:	55                   	push   %rbp
  80416063b3:	48 89 e5             	mov    %rsp,%rbp
  pic_send_eoi(IRQ_CLOCK);
  80416063b6:	bf 08 00 00 00       	mov    $0x8,%edi
  80416063bb:	48 b8 f7 59 60 41 80 	movabs $0x80416059f7,%rax
  80416063c2:	00 00 00 
  80416063c5:	ff d0                	callq  *%rax
}
  80416063c7:	5d                   	pop    %rbp
  80416063c8:	c3                   	retq   

00000080416063c9 <hpet_cpu_frequency>:
// about pause instruction.
uint64_t
hpet_cpu_frequency(void) {
  // LAB 5 Your code here.
  uint64_t time_res = 100;
  uint64_t delta = 0, target = hpetFreq / time_res;
  80416063c9:	48 a1 f0 bb 61 41 80 	movabs 0x804161bbf0,%rax
  80416063d0:	00 00 00 
  80416063d3:	48 c1 e8 02          	shr    $0x2,%rax
  80416063d7:	48 ba c3 f5 28 5c 8f 	movabs $0x28f5c28f5c28f5c3,%rdx
  80416063de:	c2 f5 28 
  80416063e1:	48 f7 e2             	mul    %rdx
  80416063e4:	48 89 d1             	mov    %rdx,%rcx
  80416063e7:	48 c1 e9 02          	shr    $0x2,%rcx
  return hpetReg->MAIN_CNT;
  80416063eb:	48 a1 00 bc 61 41 80 	movabs 0x804161bc00,%rax
  80416063f2:	00 00 00 
  80416063f5:	48 8b b8 f0 00 00 00 	mov    0xf0(%rax),%rdi
  __asm __volatile("rdtsc"
  80416063fc:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  80416063fe:	48 c1 e2 20          	shl    $0x20,%rdx
  8041606402:	41 89 c0             	mov    %eax,%r8d
  8041606405:	49 09 d0             	or     %rdx,%r8
  8041606408:	48 be 00 bc 61 41 80 	movabs $0x804161bc00,%rsi
  804160640f:	00 00 00 

  uint64_t tick0 = hpet_get_main_cnt();
  uint64_t tsc0 = read_tsc();
  do {
    asm("pause");
  8041606412:	f3 90                	pause  
  return hpetReg->MAIN_CNT;
  8041606414:	48 8b 06             	mov    (%rsi),%rax
  8041606417:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
    delta = hpet_get_main_cnt() - tick0;
  804160641e:	48 29 f8             	sub    %rdi,%rax
  } while (delta < target);
  8041606421:	48 39 c1             	cmp    %rax,%rcx
  8041606424:	77 ec                	ja     8041606412 <hpet_cpu_frequency+0x49>
  __asm __volatile("rdtsc"
  8041606426:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041606428:	48 c1 e2 20          	shl    $0x20,%rdx
  804160642c:	89 c0                	mov    %eax,%eax
  804160642e:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * time_res; 
  8041606431:	48 89 d0             	mov    %rdx,%rax
  8041606434:	4c 29 c0             	sub    %r8,%rax
  8041606437:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160643b:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160643f:	48 c1 e0 02          	shl    $0x2,%rax
}
  8041606443:	c3                   	retq   

0000008041606444 <hpet_enable_interrupts_tim1>:
hpet_enable_interrupts_tim1(void) {
  8041606444:	55                   	push   %rbp
  8041606445:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF; 
  8041606448:	48 b8 00 bc 61 41 80 	movabs $0x804161bc00,%rax
  804160644f:	00 00 00 
  8041606452:	48 8b 08             	mov    (%rax),%rcx
  8041606455:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041606459:	48 83 c8 02          	or     $0x2,%rax
  804160645d:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM1_CONF = (IRQ_CLOCK << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  8041606461:	48 c7 81 20 01 00 00 	movq   $0x104c,0x120(%rcx)
  8041606468:	4c 10 00 00 
  return hpetReg->MAIN_CNT;
  804160646c:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM1_COMP = hpet_get_main_cnt() + 3 * Peta / 2 / hpetFemto;
  8041606473:	48 bf f8 bb 61 41 80 	movabs $0x804161bbf8,%rdi
  804160647a:	00 00 00 
  804160647d:	48 b8 00 c0 29 f7 3d 	movabs $0x5543df729c000,%rax
  8041606484:	54 05 00 
  8041606487:	ba 00 00 00 00       	mov    $0x0,%edx
  804160648c:	48 f7 37             	divq   (%rdi)
  804160648f:	48 01 c6             	add    %rax,%rsi
  8041606492:	48 89 b1 28 01 00 00 	mov    %rsi,0x128(%rcx)
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  8041606499:	48 89 81 28 01 00 00 	mov    %rax,0x128(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  80416064a0:	66 a1 c8 a7 61 41 80 	movabs 0x804161a7c8,%ax
  80416064a7:	00 00 00 
  80416064aa:	89 c7                	mov    %eax,%edi
  80416064ac:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  80416064b2:	48 b8 92 58 60 41 80 	movabs $0x8041605892,%rax
  80416064b9:	00 00 00 
  80416064bc:	ff d0                	callq  *%rax
}
  80416064be:	5d                   	pop    %rbp
  80416064bf:	c3                   	retq   

00000080416064c0 <hpet_enable_interrupts_tim0>:
hpet_enable_interrupts_tim0(void) {
  80416064c0:	55                   	push   %rbp
  80416064c1:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  80416064c4:	48 b8 00 bc 61 41 80 	movabs $0x804161bc00,%rax
  80416064cb:	00 00 00 
  80416064ce:	48 8b 08             	mov    (%rax),%rcx
  80416064d1:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80416064d5:	48 83 c8 02          	or     $0x2,%rax
  80416064d9:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM0_CONF = (IRQ_TIMER << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  80416064dd:	48 c7 81 00 01 00 00 	movq   $0x4c,0x100(%rcx)
  80416064e4:	4c 00 00 00 
  return hpetReg->MAIN_CNT;
  80416064e8:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM0_COMP = hpet_get_main_cnt() + Peta / 2 / hpetFemto;
  80416064ef:	48 bf f8 bb 61 41 80 	movabs $0x804161bbf8,%rdi
  80416064f6:	00 00 00 
  80416064f9:	48 b8 00 40 63 52 bf 	movabs $0x1c6bf52634000,%rax
  8041606500:	c6 01 00 
  8041606503:	ba 00 00 00 00       	mov    $0x0,%edx
  8041606508:	48 f7 37             	divq   (%rdi)
  804160650b:	48 01 c6             	add    %rax,%rsi
  804160650e:	48 89 b1 08 01 00 00 	mov    %rsi,0x108(%rcx)
  hpetReg->TIM0_COMP = Peta / 2 / hpetFemto;
  8041606515:	48 89 81 08 01 00 00 	mov    %rax,0x108(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_TIMER));
  804160651c:	66 a1 c8 a7 61 41 80 	movabs 0x804161a7c8,%ax
  8041606523:	00 00 00 
  8041606526:	89 c7                	mov    %eax,%edi
  8041606528:	81 e7 fe ff 00 00    	and    $0xfffe,%edi
  804160652e:	48 b8 92 58 60 41 80 	movabs $0x8041605892,%rax
  8041606535:	00 00 00 
  8041606538:	ff d0                	callq  *%rax
}
  804160653a:	5d                   	pop    %rbp
  804160653b:	c3                   	retq   

000000804160653c <check_sum>:
  switch (type) {
  804160653c:	85 f6                	test   %esi,%esi
  804160653e:	74 0f                	je     804160654f <check_sum+0x13>
  uint32_t len = 0;
  8041606540:	ba 00 00 00 00       	mov    $0x0,%edx
  switch (type) {
  8041606545:	83 fe 01             	cmp    $0x1,%esi
  8041606548:	75 08                	jne    8041606552 <check_sum+0x16>
      len = ((ACPISDTHeader *)Table)->Length;
  804160654a:	8b 57 04             	mov    0x4(%rdi),%edx
      break;
  804160654d:	eb 03                	jmp    8041606552 <check_sum+0x16>
      len = ((RSDP *)Table)->Length;
  804160654f:	8b 57 14             	mov    0x14(%rdi),%edx
  for (int i = 0; i < len; i++)
  8041606552:	85 d2                	test   %edx,%edx
  8041606554:	74 24                	je     804160657a <check_sum+0x3e>
  8041606556:	48 89 f8             	mov    %rdi,%rax
  8041606559:	8d 52 ff             	lea    -0x1(%rdx),%edx
  804160655c:	48 8d 74 17 01       	lea    0x1(%rdi,%rdx,1),%rsi
  int sum      = 0;
  8041606561:	ba 00 00 00 00       	mov    $0x0,%edx
    sum += ((uint8_t *)Table)[i];
  8041606566:	0f b6 08             	movzbl (%rax),%ecx
  8041606569:	01 ca                	add    %ecx,%edx
  for (int i = 0; i < len; i++)
  804160656b:	48 83 c0 01          	add    $0x1,%rax
  804160656f:	48 39 f0             	cmp    %rsi,%rax
  8041606572:	75 f2                	jne    8041606566 <check_sum+0x2a>
  if (sum % 0x100 == 0)
  8041606574:	84 d2                	test   %dl,%dl
  8041606576:	0f 94 c0             	sete   %al
}
  8041606579:	c3                   	retq   
  int sum      = 0;
  804160657a:	ba 00 00 00 00       	mov    $0x0,%edx
  804160657f:	eb f3                	jmp    8041606574 <check_sum+0x38>

0000008041606581 <get_fadt>:
  if (!kfadt) {
  8041606581:	48 b8 e8 bb 61 41 80 	movabs $0x804161bbe8,%rax
  8041606588:	00 00 00 
  804160658b:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160658f:	74 0b                	je     804160659c <get_fadt+0x1b>
}
  8041606591:	48 a1 e8 bb 61 41 80 	movabs 0x804161bbe8,%rax
  8041606598:	00 00 00 
  804160659b:	c3                   	retq   
get_fadt(void) {
  804160659c:	55                   	push   %rbp
  804160659d:	48 89 e5             	mov    %rsp,%rbp
    kfadt = acpi_find_table("FACP");
  80416065a0:	48 bf 76 96 60 41 80 	movabs $0x8041609676,%rdi
  80416065a7:	00 00 00 
  80416065aa:	48 b8 b3 61 60 41 80 	movabs $0x80416061b3,%rax
  80416065b1:	00 00 00 
  80416065b4:	ff d0                	callq  *%rax
  80416065b6:	48 a3 e8 bb 61 41 80 	movabs %rax,0x804161bbe8
  80416065bd:	00 00 00 
}
  80416065c0:	48 a1 e8 bb 61 41 80 	movabs 0x804161bbe8,%rax
  80416065c7:	00 00 00 
  80416065ca:	5d                   	pop    %rbp
  80416065cb:	c3                   	retq   

00000080416065cc <acpi_enable>:
acpi_enable(void) {
  80416065cc:	55                   	push   %rbp
  80416065cd:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  80416065d0:	48 b8 81 65 60 41 80 	movabs $0x8041606581,%rax
  80416065d7:	00 00 00 
  80416065da:	ff d0                	callq  *%rax
  80416065dc:	48 89 c1             	mov    %rax,%rcx
  __asm __volatile("outb %0,%w1"
  80416065df:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  80416065e3:	8b 51 30             	mov    0x30(%rcx),%edx
  80416065e6:	ee                   	out    %al,(%dx)
  while ((inw(fadt->PM1aControlBlock) & 1) == 0) {
  80416065e7:	8b 51 40             	mov    0x40(%rcx),%edx
  __asm __volatile("inw %w1,%0"
  80416065ea:	66 ed                	in     (%dx),%ax
  80416065ec:	a8 01                	test   $0x1,%al
  80416065ee:	74 fa                	je     80416065ea <acpi_enable+0x1e>
}
  80416065f0:	5d                   	pop    %rbp
  80416065f1:	c3                   	retq   

00000080416065f2 <get_hpet>:
  if (!khpet) {
  80416065f2:	48 b8 c8 bb 61 41 80 	movabs $0x804161bbc8,%rax
  80416065f9:	00 00 00 
  80416065fc:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041606600:	74 0b                	je     804160660d <get_hpet+0x1b>
}
  8041606602:	48 a1 c8 bb 61 41 80 	movabs 0x804161bbc8,%rax
  8041606609:	00 00 00 
  804160660c:	c3                   	retq   
get_hpet(void) {
  804160660d:	55                   	push   %rbp
  804160660e:	48 89 e5             	mov    %rsp,%rbp
    khpet = acpi_find_table("HPET");
  8041606611:	48 bf 7b 96 60 41 80 	movabs $0x804160967b,%rdi
  8041606618:	00 00 00 
  804160661b:	48 b8 b3 61 60 41 80 	movabs $0x80416061b3,%rax
  8041606622:	00 00 00 
  8041606625:	ff d0                	callq  *%rax
  8041606627:	48 a3 c8 bb 61 41 80 	movabs %rax,0x804161bbc8
  804160662e:	00 00 00 
}
  8041606631:	48 a1 c8 bb 61 41 80 	movabs 0x804161bbc8,%rax
  8041606638:	00 00 00 
  804160663b:	5d                   	pop    %rbp
  804160663c:	c3                   	retq   

000000804160663d <hpet_register>:
hpet_register(void) {
  804160663d:	55                   	push   %rbp
  804160663e:	48 89 e5             	mov    %rsp,%rbp
  HPET *hpet_timer = get_hpet();
  8041606641:	48 b8 f2 65 60 41 80 	movabs $0x80416065f2,%rax
  8041606648:	00 00 00 
  804160664b:	ff d0                	callq  *%rax
  if (hpet_timer->address.address == 0)
  804160664d:	48 8b 78 2c          	mov    0x2c(%rax),%rdi
  8041606651:	48 85 ff             	test   %rdi,%rdi
  8041606654:	74 13                	je     8041606669 <hpet_register+0x2c>
  return mmio_map_region(paddr, sizeof(HPETRegister));
  8041606656:	be 00 04 00 00       	mov    $0x400,%esi
  804160665b:	48 b8 70 61 60 41 80 	movabs $0x8041606170,%rax
  8041606662:	00 00 00 
  8041606665:	ff d0                	callq  *%rax
}
  8041606667:	5d                   	pop    %rbp
  8041606668:	c3                   	retq   
    panic("hpet is unavailable\n");
  8041606669:	48 ba 80 96 60 41 80 	movabs $0x8041609680,%rdx
  8041606670:	00 00 00 
  8041606673:	be c3 00 00 00       	mov    $0xc3,%esi
  8041606678:	48 bf 69 96 60 41 80 	movabs $0x8041609669,%rdi
  804160667f:	00 00 00 
  8041606682:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606687:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  804160668e:	00 00 00 
  8041606691:	ff d1                	callq  *%rcx

0000008041606693 <hpet_init>:
  if (hpetReg == NULL) {
  8041606693:	48 b8 00 bc 61 41 80 	movabs $0x804161bc00,%rax
  804160669a:	00 00 00 
  804160669d:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416066a1:	74 01                	je     80416066a4 <hpet_init+0x11>
  80416066a3:	c3                   	retq   
hpet_init() {
  80416066a4:	55                   	push   %rbp
  80416066a5:	48 89 e5             	mov    %rsp,%rbp
  80416066a8:	53                   	push   %rbx
  80416066a9:	48 83 ec 08          	sub    $0x8,%rsp
  __asm __volatile("inb %w1,%0"
  80416066ad:	bb 70 00 00 00       	mov    $0x70,%ebx
  80416066b2:	89 da                	mov    %ebx,%edx
  80416066b4:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) | NMI_LOCK);
  80416066b5:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  80416066b8:	ee                   	out    %al,(%dx)
    hpetReg   = hpet_register();
  80416066b9:	48 b8 3d 66 60 41 80 	movabs $0x804160663d,%rax
  80416066c0:	00 00 00 
  80416066c3:	ff d0                	callq  *%rax
  80416066c5:	48 89 c6             	mov    %rax,%rsi
  80416066c8:	48 a3 00 bc 61 41 80 	movabs %rax,0x804161bc00
  80416066cf:	00 00 00 
    hpetFemto = (uintptr_t)(hpetReg->GCAP_ID >> 32);
  80416066d2:	48 8b 08             	mov    (%rax),%rcx
  80416066d5:	48 c1 e9 20          	shr    $0x20,%rcx
  80416066d9:	48 89 c8             	mov    %rcx,%rax
  80416066dc:	48 a3 f8 bb 61 41 80 	movabs %rax,0x804161bbf8
  80416066e3:	00 00 00 
    hpetFreq = (1 * Peta) / hpetFemto;
  80416066e6:	48 b8 00 80 c6 a4 7e 	movabs $0x38d7ea4c68000,%rax
  80416066ed:	8d 03 00 
  80416066f0:	ba 00 00 00 00       	mov    $0x0,%edx
  80416066f5:	48 f7 f1             	div    %rcx
  80416066f8:	48 a3 f0 bb 61 41 80 	movabs %rax,0x804161bbf0
  80416066ff:	00 00 00 
    hpetReg->GEN_CONF |= 1;
  8041606702:	48 8b 46 10          	mov    0x10(%rsi),%rax
  8041606706:	48 83 c8 01          	or     $0x1,%rax
  804160670a:	48 89 46 10          	mov    %rax,0x10(%rsi)
  __asm __volatile("inb %w1,%0"
  804160670e:	89 da                	mov    %ebx,%edx
  8041606710:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  8041606711:	83 e0 7f             	and    $0x7f,%eax
  8041606714:	ee                   	out    %al,(%dx)
}
  8041606715:	48 83 c4 08          	add    $0x8,%rsp
  8041606719:	5b                   	pop    %rbx
  804160671a:	5d                   	pop    %rbp
  804160671b:	c3                   	retq   

000000804160671c <hpet_print_struct>:
hpet_print_struct(void) {
  804160671c:	55                   	push   %rbp
  804160671d:	48 89 e5             	mov    %rsp,%rbp
  8041606720:	41 54                	push   %r12
  8041606722:	53                   	push   %rbx
  HPET *hpet = get_hpet();
  8041606723:	48 b8 f2 65 60 41 80 	movabs $0x80416065f2,%rax
  804160672a:	00 00 00 
  804160672d:	ff d0                	callq  *%rax
  804160672f:	49 89 c4             	mov    %rax,%r12
  cprintf("signature = %s\n", (hpet->h).Signature);
  8041606732:	48 89 c6             	mov    %rax,%rsi
  8041606735:	48 bf 95 96 60 41 80 	movabs $0x8041609695,%rdi
  804160673c:	00 00 00 
  804160673f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606744:	48 bb 6a 5a 60 41 80 	movabs $0x8041605a6a,%rbx
  804160674b:	00 00 00 
  804160674e:	ff d3                	callq  *%rbx
  cprintf("length = %08x\n", (hpet->h).Length);
  8041606750:	41 8b 74 24 04       	mov    0x4(%r12),%esi
  8041606755:	48 bf a5 96 60 41 80 	movabs $0x80416096a5,%rdi
  804160675c:	00 00 00 
  804160675f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606764:	ff d3                	callq  *%rbx
  cprintf("revision = %08x\n", (hpet->h).Revision);
  8041606766:	41 0f b6 74 24 08    	movzbl 0x8(%r12),%esi
  804160676c:	48 bf c9 96 60 41 80 	movabs $0x80416096c9,%rdi
  8041606773:	00 00 00 
  8041606776:	b8 00 00 00 00       	mov    $0x0,%eax
  804160677b:	ff d3                	callq  *%rbx
  cprintf("checksum = %08x\n", (hpet->h).Checksum);
  804160677d:	41 0f b6 74 24 09    	movzbl 0x9(%r12),%esi
  8041606783:	48 bf b4 96 60 41 80 	movabs $0x80416096b4,%rdi
  804160678a:	00 00 00 
  804160678d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606792:	ff d3                	callq  *%rbx
  cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  8041606794:	41 8b 74 24 18       	mov    0x18(%r12),%esi
  8041606799:	48 bf c5 96 60 41 80 	movabs $0x80416096c5,%rdi
  80416067a0:	00 00 00 
  80416067a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067a8:	ff d3                	callq  *%rbx
  cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  80416067aa:	41 8b 74 24 1c       	mov    0x1c(%r12),%esi
  80416067af:	48 bf da 96 60 41 80 	movabs $0x80416096da,%rdi
  80416067b6:	00 00 00 
  80416067b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067be:	ff d3                	callq  *%rbx
  cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);
  80416067c0:	41 8b 74 24 20       	mov    0x20(%r12),%esi
  80416067c5:	48 bf ed 96 60 41 80 	movabs $0x80416096ed,%rdi
  80416067cc:	00 00 00 
  80416067cf:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067d4:	ff d3                	callq  *%rbx
  cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  80416067d6:	41 0f b6 74 24 24    	movzbl 0x24(%r12),%esi
  80416067dc:	48 bf 06 97 60 41 80 	movabs $0x8041609706,%rdi
  80416067e3:	00 00 00 
  80416067e6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067eb:	ff d3                	callq  *%rbx
  cprintf("comparator_count = %08x\n", hpet->comparator_count);
  80416067ed:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  80416067f3:	83 e6 1f             	and    $0x1f,%esi
  80416067f6:	48 bf 1e 97 60 41 80 	movabs $0x804160971e,%rdi
  80416067fd:	00 00 00 
  8041606800:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606805:	ff d3                	callq  *%rbx
  cprintf("counter_size = %08x\n", hpet->counter_size);
  8041606807:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160680d:	40 c0 ee 05          	shr    $0x5,%sil
  8041606811:	83 e6 01             	and    $0x1,%esi
  8041606814:	48 bf 37 97 60 41 80 	movabs $0x8041609737,%rdi
  804160681b:	00 00 00 
  804160681e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606823:	ff d3                	callq  *%rbx
  cprintf("reserved = %08x\n", hpet->reserved);
  8041606825:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160682b:	40 c0 ee 06          	shr    $0x6,%sil
  804160682f:	83 e6 01             	and    $0x1,%esi
  8041606832:	48 bf 4c 97 60 41 80 	movabs $0x804160974c,%rdi
  8041606839:	00 00 00 
  804160683c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606841:	ff d3                	callq  *%rbx
  cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  8041606843:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  8041606849:	40 c0 ee 07          	shr    $0x7,%sil
  804160684d:	40 0f b6 f6          	movzbl %sil,%esi
  8041606851:	48 bf 5d 97 60 41 80 	movabs $0x804160975d,%rdi
  8041606858:	00 00 00 
  804160685b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606860:	ff d3                	callq  *%rbx
  cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  8041606862:	41 0f b7 74 24 26    	movzwl 0x26(%r12),%esi
  8041606868:	48 bf 78 97 60 41 80 	movabs $0x8041609778,%rdi
  804160686f:	00 00 00 
  8041606872:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606877:	ff d3                	callq  *%rbx
  cprintf("hpet_number = %08x\n", hpet->hpet_number);
  8041606879:	41 0f b6 74 24 34    	movzbl 0x34(%r12),%esi
  804160687f:	48 bf 8e 97 60 41 80 	movabs $0x804160978e,%rdi
  8041606886:	00 00 00 
  8041606889:	b8 00 00 00 00       	mov    $0x0,%eax
  804160688e:	ff d3                	callq  *%rbx
  cprintf("minimum_tick = %08x\n", hpet->minimum_tick);
  8041606890:	41 0f b7 74 24 35    	movzwl 0x35(%r12),%esi
  8041606896:	48 bf a2 97 60 41 80 	movabs $0x80416097a2,%rdi
  804160689d:	00 00 00 
  80416068a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068a5:	ff d3                	callq  *%rbx
  cprintf("address_structure:\n");
  80416068a7:	48 bf b7 97 60 41 80 	movabs $0x80416097b7,%rdi
  80416068ae:	00 00 00 
  80416068b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068b6:	ff d3                	callq  *%rbx
  cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  80416068b8:	41 0f b6 74 24 28    	movzbl 0x28(%r12),%esi
  80416068be:	48 bf cb 97 60 41 80 	movabs $0x80416097cb,%rdi
  80416068c5:	00 00 00 
  80416068c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068cd:	ff d3                	callq  *%rbx
  cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  80416068cf:	41 0f b6 74 24 29    	movzbl 0x29(%r12),%esi
  80416068d5:	48 bf e4 97 60 41 80 	movabs $0x80416097e4,%rdi
  80416068dc:	00 00 00 
  80416068df:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068e4:	ff d3                	callq  *%rbx
  cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  80416068e6:	41 0f b6 74 24 2a    	movzbl 0x2a(%r12),%esi
  80416068ec:	48 bf ff 97 60 41 80 	movabs $0x80416097ff,%rdi
  80416068f3:	00 00 00 
  80416068f6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068fb:	ff d3                	callq  *%rbx
  cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
  80416068fd:	49 8b 74 24 2c       	mov    0x2c(%r12),%rsi
  8041606902:	48 bf 1b 98 60 41 80 	movabs $0x804160981b,%rdi
  8041606909:	00 00 00 
  804160690c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606911:	ff d3                	callq  *%rbx
}
  8041606913:	5b                   	pop    %rbx
  8041606914:	41 5c                	pop    %r12
  8041606916:	5d                   	pop    %rbp
  8041606917:	c3                   	retq   

0000008041606918 <hpet_print_reg>:
hpet_print_reg(void) {
  8041606918:	55                   	push   %rbp
  8041606919:	48 89 e5             	mov    %rsp,%rbp
  804160691c:	41 54                	push   %r12
  804160691e:	53                   	push   %rbx
  cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  804160691f:	49 bc 00 bc 61 41 80 	movabs $0x804161bc00,%r12
  8041606926:	00 00 00 
  8041606929:	49 8b 04 24          	mov    (%r12),%rax
  804160692d:	48 8b 30             	mov    (%rax),%rsi
  8041606930:	48 bf 2c 98 60 41 80 	movabs $0x804160982c,%rdi
  8041606937:	00 00 00 
  804160693a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160693f:	48 bb 6a 5a 60 41 80 	movabs $0x8041605a6a,%rbx
  8041606946:	00 00 00 
  8041606949:	ff d3                	callq  *%rbx
  cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  804160694b:	49 8b 04 24          	mov    (%r12),%rax
  804160694f:	48 8b 70 10          	mov    0x10(%rax),%rsi
  8041606953:	48 bf 3e 98 60 41 80 	movabs $0x804160983e,%rdi
  804160695a:	00 00 00 
  804160695d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606962:	ff d3                	callq  *%rbx
  cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  8041606964:	49 8b 04 24          	mov    (%r12),%rax
  8041606968:	48 8b 70 20          	mov    0x20(%rax),%rsi
  804160696c:	48 bf 51 98 60 41 80 	movabs $0x8041609851,%rdi
  8041606973:	00 00 00 
  8041606976:	b8 00 00 00 00       	mov    $0x0,%eax
  804160697b:	ff d3                	callq  *%rbx
  cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  804160697d:	49 8b 04 24          	mov    (%r12),%rax
  8041606981:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
  8041606988:	48 bf 65 98 60 41 80 	movabs $0x8041609865,%rdi
  804160698f:	00 00 00 
  8041606992:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606997:	ff d3                	callq  *%rbx
  cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  8041606999:	49 8b 04 24          	mov    (%r12),%rax
  804160699d:	48 8b b0 00 01 00 00 	mov    0x100(%rax),%rsi
  80416069a4:	48 bf 78 98 60 41 80 	movabs $0x8041609878,%rdi
  80416069ab:	00 00 00 
  80416069ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069b3:	ff d3                	callq  *%rbx
  cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  80416069b5:	49 8b 04 24          	mov    (%r12),%rax
  80416069b9:	48 8b b0 08 01 00 00 	mov    0x108(%rax),%rsi
  80416069c0:	48 bf 8c 98 60 41 80 	movabs $0x804160988c,%rdi
  80416069c7:	00 00 00 
  80416069ca:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069cf:	ff d3                	callq  *%rbx
  cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  80416069d1:	49 8b 04 24          	mov    (%r12),%rax
  80416069d5:	48 8b b0 10 01 00 00 	mov    0x110(%rax),%rsi
  80416069dc:	48 bf a0 98 60 41 80 	movabs $0x80416098a0,%rdi
  80416069e3:	00 00 00 
  80416069e6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069eb:	ff d3                	callq  *%rbx
  cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  80416069ed:	49 8b 04 24          	mov    (%r12),%rax
  80416069f1:	48 8b b0 20 01 00 00 	mov    0x120(%rax),%rsi
  80416069f8:	48 bf b3 98 60 41 80 	movabs $0x80416098b3,%rdi
  80416069ff:	00 00 00 
  8041606a02:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a07:	ff d3                	callq  *%rbx
  cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  8041606a09:	49 8b 04 24          	mov    (%r12),%rax
  8041606a0d:	48 8b b0 28 01 00 00 	mov    0x128(%rax),%rsi
  8041606a14:	48 bf c7 98 60 41 80 	movabs $0x80416098c7,%rdi
  8041606a1b:	00 00 00 
  8041606a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a23:	ff d3                	callq  *%rbx
  cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  8041606a25:	49 8b 04 24          	mov    (%r12),%rax
  8041606a29:	48 8b b0 30 01 00 00 	mov    0x130(%rax),%rsi
  8041606a30:	48 bf db 98 60 41 80 	movabs $0x80416098db,%rdi
  8041606a37:	00 00 00 
  8041606a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a3f:	ff d3                	callq  *%rbx
  cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  8041606a41:	49 8b 04 24          	mov    (%r12),%rax
  8041606a45:	48 8b b0 40 01 00 00 	mov    0x140(%rax),%rsi
  8041606a4c:	48 bf ee 98 60 41 80 	movabs $0x80416098ee,%rdi
  8041606a53:	00 00 00 
  8041606a56:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a5b:	ff d3                	callq  *%rbx
  cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  8041606a5d:	49 8b 04 24          	mov    (%r12),%rax
  8041606a61:	48 8b b0 48 01 00 00 	mov    0x148(%rax),%rsi
  8041606a68:	48 bf 02 99 60 41 80 	movabs $0x8041609902,%rdi
  8041606a6f:	00 00 00 
  8041606a72:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a77:	ff d3                	callq  *%rbx
  cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
  8041606a79:	49 8b 04 24          	mov    (%r12),%rax
  8041606a7d:	48 8b b0 50 01 00 00 	mov    0x150(%rax),%rsi
  8041606a84:	48 bf 16 99 60 41 80 	movabs $0x8041609916,%rdi
  8041606a8b:	00 00 00 
  8041606a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a93:	ff d3                	callq  *%rbx
}
  8041606a95:	5b                   	pop    %rbx
  8041606a96:	41 5c                	pop    %r12
  8041606a98:	5d                   	pop    %rbp
  8041606a99:	c3                   	retq   

0000008041606a9a <hpet_get_main_cnt>:
  return hpetReg->MAIN_CNT;
  8041606a9a:	48 a1 00 bc 61 41 80 	movabs 0x804161bc00,%rax
  8041606aa1:	00 00 00 
  8041606aa4:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
}
  8041606aab:	c3                   	retq   

0000008041606aac <pmtimer_get_timeval>:

uint32_t
pmtimer_get_timeval(void) {
  8041606aac:	55                   	push   %rbp
  8041606aad:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  8041606ab0:	48 b8 81 65 60 41 80 	movabs $0x8041606581,%rax
  8041606ab7:	00 00 00 
  8041606aba:	ff d0                	callq  *%rax
  __asm __volatile("inl %w1,%0"
  8041606abc:	8b 50 4c             	mov    0x4c(%rax),%edx
  8041606abf:	ed                   	in     (%dx),%eax
  return inl(fadt->PMTimerBlock);
}
  8041606ac0:	5d                   	pop    %rbp
  8041606ac1:	c3                   	retq   

0000008041606ac2 <pmtimer_cpu_frequency>:
// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
// Hint: use pmtimer_get_timeval function and do not forget that ACPI PM timer
// can be 24-bit or 32-bit.
uint64_t
pmtimer_cpu_frequency(void) {
  8041606ac2:	55                   	push   %rbp
  8041606ac3:	48 89 e5             	mov    %rsp,%rbp
  8041606ac6:	41 55                	push   %r13
  8041606ac8:	41 54                	push   %r12
  8041606aca:	53                   	push   %rbx
  8041606acb:	48 83 ec 08          	sub    $0x8,%rsp

  uint32_t time_res = 100;
  uint32_t tick0 = pmtimer_get_timeval();
  8041606acf:	48 b8 ac 6a 60 41 80 	movabs $0x8041606aac,%rax
  8041606ad6:	00 00 00 
  8041606ad9:	ff d0                	callq  *%rax
  8041606adb:	89 c3                	mov    %eax,%ebx
  __asm __volatile("rdtsc"
  8041606add:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041606adf:	48 c1 e2 20          	shl    $0x20,%rdx
  8041606ae3:	89 c0                	mov    %eax,%eax
  8041606ae5:	48 09 c2             	or     %rax,%rdx
  8041606ae8:	49 89 d5             	mov    %rdx,%r13

  uint64_t tsc0 = read_tsc();

  do {
    asm("pause");
    uint32_t tick1 = pmtimer_get_timeval();
  8041606aeb:	49 bc ac 6a 60 41 80 	movabs $0x8041606aac,%r12
  8041606af2:	00 00 00 
  8041606af5:	eb 17                	jmp    8041606b0e <pmtimer_cpu_frequency+0x4c>
    delta = tick1 - tick0;
    if (-delta <= 0xFFFFFF) {
      delta += 0xFFFFFF;
    } else if (tick0 > tick1) {
  8041606af7:	39 c3                	cmp    %eax,%ebx
  8041606af9:	76 0a                	jbe    8041606b05 <pmtimer_cpu_frequency+0x43>
      delta += 0xFFFFFFFF;
  8041606afb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041606b00:	48 01 c1             	add    %rax,%rcx
  8041606b03:	eb 28                	jmp    8041606b2d <pmtimer_cpu_frequency+0x6b>
    }
  } while (delta < target);
  8041606b05:	48 81 f9 d2 8b 00 00 	cmp    $0x8bd2,%rcx
  8041606b0c:	77 1f                	ja     8041606b2d <pmtimer_cpu_frequency+0x6b>
    asm("pause");
  8041606b0e:	f3 90                	pause  
    uint32_t tick1 = pmtimer_get_timeval();
  8041606b10:	41 ff d4             	callq  *%r12
    delta = tick1 - tick0;
  8041606b13:	89 c1                	mov    %eax,%ecx
  8041606b15:	29 d9                	sub    %ebx,%ecx
    if (-delta <= 0xFFFFFF) {
  8041606b17:	48 89 ca             	mov    %rcx,%rdx
  8041606b1a:	48 f7 da             	neg    %rdx
  8041606b1d:	48 81 fa ff ff ff 00 	cmp    $0xffffff,%rdx
  8041606b24:	77 d1                	ja     8041606af7 <pmtimer_cpu_frequency+0x35>
      delta += 0xFFFFFF;
  8041606b26:	48 81 c1 ff ff ff 00 	add    $0xffffff,%rcx
  __asm __volatile("rdtsc"
  8041606b2d:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041606b2f:	48 c1 e2 20          	shl    $0x20,%rdx
  8041606b33:	89 c0                	mov    %eax,%eax
  8041606b35:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * PM_FREQ / delta;
  8041606b38:	4c 29 ea             	sub    %r13,%rdx
  8041606b3b:	48 69 c2 99 9e 36 00 	imul   $0x369e99,%rdx,%rax
  8041606b42:	ba 00 00 00 00       	mov    $0x0,%edx
  8041606b47:	48 f7 f1             	div    %rcx
}
  8041606b4a:	48 83 c4 08          	add    $0x8,%rsp
  8041606b4e:	5b                   	pop    %rbx
  8041606b4f:	41 5c                	pop    %r12
  8041606b51:	41 5d                	pop    %r13
  8041606b53:	5d                   	pop    %rbp
  8041606b54:	c3                   	retq   

0000008041606b55 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041606b55:	48 a1 88 a7 61 41 80 	movabs 0x804161a788,%rax
  8041606b5c:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  8041606b5f:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  8041606b65:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041606b68:	83 fa 02             	cmp    $0x2,%edx
  8041606b6b:	76 5c                	jbe    8041606bc9 <sched_halt+0x74>
  8041606b6d:	48 8d 90 b4 01 00 00 	lea    0x1b4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  8041606b74:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  8041606b79:	8b 02                	mov    (%rdx),%eax
  8041606b7b:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041606b7e:	83 f8 02             	cmp    $0x2,%eax
  8041606b81:	76 46                	jbe    8041606bc9 <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  8041606b83:	83 c1 01             	add    $0x1,%ecx
  8041606b86:	48 81 c2 e0 00 00 00 	add    $0xe0,%rdx
  8041606b8d:	83 f9 20             	cmp    $0x20,%ecx
  8041606b90:	75 e7                	jne    8041606b79 <sched_halt+0x24>
sched_halt(void) {
  8041606b92:	55                   	push   %rbp
  8041606b93:	48 89 e5             	mov    %rsp,%rbp
  8041606b96:	53                   	push   %rbx
  8041606b97:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  8041606b9b:	48 bf 38 99 60 41 80 	movabs $0x8041609938,%rdi
  8041606ba2:	00 00 00 
  8041606ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606baa:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041606bb1:	00 00 00 
  8041606bb4:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  8041606bb6:	48 bb f9 3d 60 41 80 	movabs $0x8041603df9,%rbx
  8041606bbd:	00 00 00 
  8041606bc0:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606bc5:	ff d3                	callq  *%rbx
    while (1)
  8041606bc7:	eb f7                	jmp    8041606bc0 <sched_halt+0x6b>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  8041606bc9:	48 b8 98 ab 61 41 80 	movabs $0x804161ab98,%rax
  8041606bd0:	00 00 00 
  8041606bd3:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  8041606bda:	48 a1 64 dd 61 41 80 	movabs 0x804161dd64,%rax
  8041606be1:	00 00 00 
  8041606be4:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  8041606beb:	48 89 c4             	mov    %rax,%rsp
  8041606bee:	6a 00                	pushq  $0x0
  8041606bf0:	6a 00                	pushq  $0x0
  8041606bf2:	fb                   	sti    
  8041606bf3:	f4                   	hlt    
  8041606bf4:	c3                   	retq   

0000008041606bf5 <sched_yield>:
sched_yield(void) {
  8041606bf5:	55                   	push   %rbp
  8041606bf6:	48 89 e5             	mov    %rsp,%rbp
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  8041606bf9:	48 a1 98 ab 61 41 80 	movabs 0x804161ab98,%rax
  8041606c00:	00 00 00 
  8041606c03:	be 00 00 00 00       	mov    $0x0,%esi
  8041606c08:	48 85 c0             	test   %rax,%rax
  8041606c0b:	74 09                	je     8041606c16 <sched_yield+0x21>
  8041606c0d:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041606c13:	83 e6 1f             	and    $0x1f,%esi
    if (envs[id].env_status == ENV_RUNNABLE ||
  8041606c16:	48 b8 88 a7 61 41 80 	movabs $0x804161a788,%rax
  8041606c1d:	00 00 00 
  8041606c20:	4c 8b 00             	mov    (%rax),%r8
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  8041606c23:	89 f2                	mov    %esi,%edx
  8041606c25:	eb 04                	jmp    8041606c2b <sched_yield+0x36>
  } while (id != orig);
  8041606c27:	39 c6                	cmp    %eax,%esi
  8041606c29:	74 45                	je     8041606c70 <sched_yield+0x7b>
    id = (id + 1) % NENV;
  8041606c2b:	8d 42 01             	lea    0x1(%rdx),%eax
  8041606c2e:	99                   	cltd   
  8041606c2f:	c1 ea 1b             	shr    $0x1b,%edx
  8041606c32:	01 d0                	add    %edx,%eax
  8041606c34:	83 e0 1f             	and    $0x1f,%eax
  8041606c37:	29 d0                	sub    %edx,%eax
  8041606c39:	89 c2                	mov    %eax,%edx
    if (envs[id].env_status == ENV_RUNNABLE ||
  8041606c3b:	48 63 c8             	movslq %eax,%rcx
  8041606c3e:	48 8d 3c cd 00 00 00 	lea    0x0(,%rcx,8),%rdi
  8041606c45:	00 
  8041606c46:	48 29 cf             	sub    %rcx,%rdi
  8041606c49:	48 c1 e7 05          	shl    $0x5,%rdi
  8041606c4d:	4c 01 c7             	add    %r8,%rdi
  8041606c50:	8b 8f d4 00 00 00    	mov    0xd4(%rdi),%ecx
  8041606c56:	83 f9 02             	cmp    $0x2,%ecx
  8041606c59:	74 09                	je     8041606c64 <sched_yield+0x6f>
       (id == orig && envs[id].env_status == ENV_RUNNING)) {
  8041606c5b:	83 f9 03             	cmp    $0x3,%ecx
  8041606c5e:	75 c7                	jne    8041606c27 <sched_yield+0x32>
  8041606c60:	39 c6                	cmp    %eax,%esi
  8041606c62:	75 c3                	jne    8041606c27 <sched_yield+0x32>
      env_run(envs + id);
  8041606c64:	48 b8 19 57 60 41 80 	movabs $0x8041605719,%rax
  8041606c6b:	00 00 00 
  8041606c6e:	ff d0                	callq  *%rax
  sched_halt();
  8041606c70:	48 b8 55 6b 60 41 80 	movabs $0x8041606b55,%rax
  8041606c77:	00 00 00 
  8041606c7a:	ff d0                	callq  *%rax
}
  8041606c7c:	5d                   	pop    %rbp
  8041606c7d:	c3                   	retq   

0000008041606c7e <load_kernel_dwarf_info>:
#include <kern/kdebug.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  8041606c7e:	48 ba 00 a0 61 41 80 	movabs $0x804161a000,%rdx
  8041606c85:	00 00 00 
  8041606c88:	48 8b 02             	mov    (%rdx),%rax
  8041606c8b:	48 8b 48 58          	mov    0x58(%rax),%rcx
  8041606c8f:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  8041606c93:	48 8b 48 60          	mov    0x60(%rax),%rcx
  8041606c97:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  8041606c9b:	48 8b 40 68          	mov    0x68(%rax),%rax
  8041606c9f:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  8041606ca2:	48 8b 02             	mov    (%rdx),%rax
  8041606ca5:	48 8b 50 70          	mov    0x70(%rax),%rdx
  8041606ca9:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  8041606cad:	48 8b 50 78          	mov    0x78(%rax),%rdx
  8041606cb1:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  8041606cb5:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  8041606cbc:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  8041606cc0:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  8041606cc7:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  8041606ccb:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  8041606cd2:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  8041606cd6:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  8041606cdd:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  8041606ce1:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  8041606ce8:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  8041606cec:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  8041606cf3:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  8041606cf7:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  8041606cfe:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  8041606d02:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  8041606d09:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  8041606d0d:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  8041606d14:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  8041606d18:	c3                   	retq   

0000008041606d19 <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  8041606d19:	55                   	push   %rbp
  8041606d1a:	48 89 e5             	mov    %rsp,%rbp
  8041606d1d:	41 56                	push   %r14
  8041606d1f:	41 55                	push   %r13
  8041606d21:	41 54                	push   %r12
  8041606d23:	53                   	push   %rbx
  8041606d24:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  8041606d2b:	49 89 fc             	mov    %rdi,%r12
  8041606d2e:	48 89 f3             	mov    %rsi,%rbx
  int code = 0;
  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  8041606d31:	48 be 61 99 60 41 80 	movabs $0x8041609961,%rsi
  8041606d38:	00 00 00 
  8041606d3b:	48 89 df             	mov    %rbx,%rdi
  8041606d3e:	49 bd 3f 7a 60 41 80 	movabs $0x8041607a3f,%r13
  8041606d45:	00 00 00 
  8041606d48:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  8041606d4b:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  8041606d52:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  8041606d55:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  8041606d5c:	48 be 61 99 60 41 80 	movabs $0x8041609961,%rsi
  8041606d63:	00 00 00 
  8041606d66:	4c 89 f7             	mov    %r14,%rdi
  8041606d69:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  8041606d6c:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  8041606d73:	00 00 00 
  info->rip_fn_addr    = addr;
  8041606d76:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  8041606d7d:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  8041606d84:	00 00 00 

  if (!addr) {
  8041606d87:	4d 85 e4             	test   %r12,%r12
  8041606d8a:	0f 84 99 01 00 00    	je     8041606f29 <debuginfo_rip+0x210>
    return 0;
  }

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  8041606d90:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  8041606d97:	00 00 00 
  8041606d9a:	49 39 c4             	cmp    %rax,%r12
  8041606d9d:	0f 86 5c 01 00 00    	jbe    8041606eff <debuginfo_rip+0x1e6>
    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  8041606da3:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041606daa:	48 b8 7e 6c 60 41 80 	movabs $0x8041606c7e,%rax
  8041606db1:	00 00 00 
  8041606db4:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  8041606db6:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  8041606dbd:	00 00 00 00 
  8041606dc1:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  8041606dc8:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  8041606dcc:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  8041606dd3:	4c 89 e6             	mov    %r12,%rsi
  8041606dd6:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041606ddd:	48 b8 c8 16 60 41 80 	movabs $0x80416016c8,%rax
  8041606de4:	00 00 00 
  8041606de7:	ff d0                	callq  *%rax
  8041606de9:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  8041606dec:	85 c0                	test   %eax,%eax
  8041606dee:	0f 88 3b 01 00 00    	js     8041606f2f <debuginfo_rip+0x216>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  8041606df4:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  8041606dfb:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041606e00:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  8041606e07:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  8041606e0e:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041606e15:	48 b8 77 1d 60 41 80 	movabs $0x8041601d77,%rax
  8041606e1c:	00 00 00 
  8041606e1f:	ff d0                	callq  *%rax
  8041606e21:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  8041606e24:	ba 00 01 00 00       	mov    $0x100,%edx
  8041606e29:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041606e30:	48 89 df             	mov    %rbx,%rdi
  8041606e33:	48 b8 8d 7a 60 41 80 	movabs $0x8041607a8d,%rax
  8041606e3a:	00 00 00 
  8041606e3d:	ff d0                	callq  *%rax
  if (code < 0) {
  8041606e3f:	45 85 ed             	test   %r13d,%r13d
  8041606e42:	0f 88 e7 00 00 00    	js     8041606f2f <debuginfo_rip+0x216>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
    
  int lineno_store;
  addr = addr - 5;
  8041606e48:	49 83 ec 05          	sub    $0x5,%r12
  code = line_for_address(&addrs, addr, line_offset, &lineno_store);
  8041606e4c:	48 8d 8d 54 ff ff ff 	lea    -0xac(%rbp),%rcx
  8041606e53:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8041606e5a:	4c 89 e6             	mov    %r12,%rsi
  8041606e5d:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041606e64:	48 b8 c1 32 60 41 80 	movabs $0x80416032c1,%rax
  8041606e6b:	00 00 00 
  8041606e6e:	ff d0                	callq  *%rax
  8041606e70:	41 89 c5             	mov    %eax,%r13d
  info->rip_line = lineno_store;
  8041606e73:	8b 85 54 ff ff ff    	mov    -0xac(%rbp),%eax
  8041606e79:	89 83 00 01 00 00    	mov    %eax,0x100(%rbx)
  if (code < 0) {
  8041606e7f:	45 85 ed             	test   %r13d,%r13d
  8041606e82:	0f 88 a7 00 00 00    	js     8041606f2f <debuginfo_rip+0x216>
    return code;
  }

  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  8041606e88:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  8041606e8f:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041606e95:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  8041606e9c:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  8041606ea3:	4c 89 e6             	mov    %r12,%rsi
  8041606ea6:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041606ead:	48 b8 e2 21 60 41 80 	movabs $0x80416021e2,%rax
  8041606eb4:	00 00 00 
  8041606eb7:	ff d0                	callq  *%rax
  8041606eb9:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  8041606ebc:	ba 00 01 00 00       	mov    $0x100,%edx
  8041606ec1:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041606ec8:	4c 89 f7             	mov    %r14,%rdi
  8041606ecb:	48 b8 8d 7a 60 41 80 	movabs $0x8041607a8d,%rax
  8041606ed2:	00 00 00 
  8041606ed5:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  8041606ed7:	be 00 01 00 00       	mov    $0x100,%esi
  8041606edc:	4c 89 f7             	mov    %r14,%rdi
  8041606edf:	48 b8 0a 7a 60 41 80 	movabs $0x8041607a0a,%rax
  8041606ee6:	00 00 00 
  8041606ee9:	ff d0                	callq  *%rax
  8041606eeb:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  8041606ef1:	45 85 ed             	test   %r13d,%r13d
  8041606ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ef9:	44 0f 4f e8          	cmovg  %eax,%r13d
  8041606efd:	eb 30                	jmp    8041606f2f <debuginfo_rip+0x216>
    panic("Can't search for user-level addresses yet!");
  8041606eff:	48 ba 80 99 60 41 80 	movabs $0x8041609980,%rdx
  8041606f06:	00 00 00 
  8041606f09:	be 38 00 00 00       	mov    $0x38,%esi
  8041606f0e:	48 bf 6b 99 60 41 80 	movabs $0x804160996b,%rdi
  8041606f15:	00 00 00 
  8041606f18:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f1d:	48 b9 71 02 60 41 80 	movabs $0x8041600271,%rcx
  8041606f24:	00 00 00 
  8041606f27:	ff d1                	callq  *%rcx
    return 0;
  8041606f29:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    return code;
  }
  return 0;
}
  8041606f2f:	44 89 e8             	mov    %r13d,%eax
  8041606f32:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  8041606f39:	5b                   	pop    %rbx
  8041606f3a:	41 5c                	pop    %r12
  8041606f3c:	41 5d                	pop    %r13
  8041606f3e:	41 5e                	pop    %r14
  8041606f40:	5d                   	pop    %rbp
  8041606f41:	c3                   	retq   

0000008041606f42 <find_function>:

uintptr_t
find_function(const char *const fname) {
  8041606f42:	55                   	push   %rbp
  8041606f43:	48 89 e5             	mov    %rsp,%rbp
  8041606f46:	53                   	push   %rbx
  8041606f47:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  8041606f4e:	48 89 fb             	mov    %rdi,%rbx
    }
  }
  #endif

  struct Dwarf_Addrs addrs;
  load_kernel_dwarf_info(&addrs);
  8041606f51:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  8041606f55:	48 b8 7e 6c 60 41 80 	movabs $0x8041606c7e,%rax
  8041606f5c:	00 00 00 
  8041606f5f:	ff d0                	callq  *%rax
  uintptr_t offset = 0;
  8041606f61:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  8041606f68:	00 00 00 00 

  if (!address_by_fname(&addrs, fname, &offset) && offset) {
  8041606f6c:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  8041606f73:	48 89 de             	mov    %rbx,%rsi
  8041606f76:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  8041606f7a:	48 b8 6e 27 60 41 80 	movabs $0x804160276e,%rax
  8041606f81:	00 00 00 
  8041606f84:	ff d0                	callq  *%rax
  8041606f86:	85 c0                	test   %eax,%eax
  8041606f88:	75 0c                	jne    8041606f96 <find_function+0x54>
  8041606f8a:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  8041606f91:	48 85 d2             	test   %rdx,%rdx
  8041606f94:	75 23                	jne    8041606fb9 <find_function+0x77>
    return offset;
  }

  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  8041606f96:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  8041606f9d:	48 89 de             	mov    %rbx,%rsi
  8041606fa0:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  8041606fa4:	48 b8 6c 2d 60 41 80 	movabs $0x8041602d6c,%rax
  8041606fab:	00 00 00 
  8041606fae:	ff d0                	callq  *%rax
    return offset;
  }

  return 0;
  8041606fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  8041606fb5:	85 c0                	test   %eax,%eax
  8041606fb7:	74 0d                	je     8041606fc6 <find_function+0x84>
}
  8041606fb9:	48 89 d0             	mov    %rdx,%rax
  8041606fbc:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  8041606fc3:	5b                   	pop    %rbx
  8041606fc4:	5d                   	pop    %rbp
  8041606fc5:	c3                   	retq   
    return offset;
  8041606fc6:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  8041606fcd:	eb ea                	jmp    8041606fb9 <find_function+0x77>

0000008041606fcf <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8041606fcf:	55                   	push   %rbp
  8041606fd0:	48 89 e5             	mov    %rsp,%rbp
  8041606fd3:	41 57                	push   %r15
  8041606fd5:	41 56                	push   %r14
  8041606fd7:	41 55                	push   %r13
  8041606fd9:	41 54                	push   %r12
  8041606fdb:	53                   	push   %rbx
  8041606fdc:	48 83 ec 18          	sub    $0x18,%rsp
  8041606fe0:	49 89 fc             	mov    %rdi,%r12
  8041606fe3:	49 89 f5             	mov    %rsi,%r13
  8041606fe6:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8041606fea:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8041606fed:	41 89 cf             	mov    %ecx,%r15d
  8041606ff0:	49 39 d7             	cmp    %rdx,%r15
  8041606ff3:	76 45                	jbe    804160703a <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8041606ff5:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  8041606ff9:	85 db                	test   %ebx,%ebx
  8041606ffb:	7e 0e                	jle    804160700b <printnum+0x3c>
      putch(padc, putdat);
  8041606ffd:	4c 89 ee             	mov    %r13,%rsi
  8041607000:	44 89 f7             	mov    %r14d,%edi
  8041607003:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8041607006:	83 eb 01             	sub    $0x1,%ebx
  8041607009:	75 f2                	jne    8041606ffd <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  804160700b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160700f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041607014:	49 f7 f7             	div    %r15
  8041607017:	48 b8 ab 99 60 41 80 	movabs $0x80416099ab,%rax
  804160701e:	00 00 00 
  8041607021:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8041607025:	4c 89 ee             	mov    %r13,%rsi
  8041607028:	41 ff d4             	callq  *%r12
}
  804160702b:	48 83 c4 18          	add    $0x18,%rsp
  804160702f:	5b                   	pop    %rbx
  8041607030:	41 5c                	pop    %r12
  8041607032:	41 5d                	pop    %r13
  8041607034:	41 5e                	pop    %r14
  8041607036:	41 5f                	pop    %r15
  8041607038:	5d                   	pop    %rbp
  8041607039:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  804160703a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160703e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041607043:	49 f7 f7             	div    %r15
  8041607046:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  804160704a:	48 89 c2             	mov    %rax,%rdx
  804160704d:	48 b8 cf 6f 60 41 80 	movabs $0x8041606fcf,%rax
  8041607054:	00 00 00 
  8041607057:	ff d0                	callq  *%rax
  8041607059:	eb b0                	jmp    804160700b <printnum+0x3c>

000000804160705b <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  804160705b:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  804160705f:	48 8b 06             	mov    (%rsi),%rax
  8041607062:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8041607066:	73 0a                	jae    8041607072 <sprintputch+0x17>
    *b->buf++ = ch;
  8041607068:	48 8d 50 01          	lea    0x1(%rax),%rdx
  804160706c:	48 89 16             	mov    %rdx,(%rsi)
  804160706f:	40 88 38             	mov    %dil,(%rax)
}
  8041607072:	c3                   	retq   

0000008041607073 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8041607073:	55                   	push   %rbp
  8041607074:	48 89 e5             	mov    %rsp,%rbp
  8041607077:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160707e:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041607085:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160708c:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041607093:	84 c0                	test   %al,%al
  8041607095:	74 20                	je     80416070b7 <printfmt+0x44>
  8041607097:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160709b:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160709f:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80416070a3:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80416070a7:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80416070ab:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80416070af:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80416070b3:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80416070b7:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80416070be:	00 00 00 
  80416070c1:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80416070c8:	00 00 00 
  80416070cb:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416070cf:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80416070d6:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80416070dd:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80416070e4:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80416070eb:	48 b8 f9 70 60 41 80 	movabs $0x80416070f9,%rax
  80416070f2:	00 00 00 
  80416070f5:	ff d0                	callq  *%rax
}
  80416070f7:	c9                   	leaveq 
  80416070f8:	c3                   	retq   

00000080416070f9 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80416070f9:	55                   	push   %rbp
  80416070fa:	48 89 e5             	mov    %rsp,%rbp
  80416070fd:	41 57                	push   %r15
  80416070ff:	41 56                	push   %r14
  8041607101:	41 55                	push   %r13
  8041607103:	41 54                	push   %r12
  8041607105:	53                   	push   %rbx
  8041607106:	48 83 ec 48          	sub    $0x48,%rsp
  804160710a:	49 89 fd             	mov    %rdi,%r13
  804160710d:	49 89 f7             	mov    %rsi,%r15
  8041607110:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8041607113:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8041607117:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  804160711b:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160711f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8041607123:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8041607127:	41 0f b6 3e          	movzbl (%r14),%edi
  804160712b:	83 ff 25             	cmp    $0x25,%edi
  804160712e:	74 18                	je     8041607148 <vprintfmt+0x4f>
      if (ch == '\0')
  8041607130:	85 ff                	test   %edi,%edi
  8041607132:	0f 84 8c 06 00 00    	je     80416077c4 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8041607138:	4c 89 fe             	mov    %r15,%rsi
  804160713b:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160713e:	49 89 de             	mov    %rbx,%r14
  8041607141:	eb e0                	jmp    8041607123 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8041607143:	49 89 de             	mov    %rbx,%r14
  8041607146:	eb db                	jmp    8041607123 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8041607148:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  804160714c:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8041607150:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8041607157:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  804160715d:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8041607161:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8041607166:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160716c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8041607172:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  8041607177:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  804160717c:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8041607180:	0f b6 13             	movzbl (%rbx),%edx
  8041607183:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8041607186:	3c 55                	cmp    $0x55,%al
  8041607188:	0f 87 8b 05 00 00    	ja     8041607719 <vprintfmt+0x620>
  804160718e:	0f b6 c0             	movzbl %al,%eax
  8041607191:	49 bb 60 9a 60 41 80 	movabs $0x8041609a60,%r11
  8041607198:	00 00 00 
  804160719b:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  804160719f:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  80416071a2:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80416071a6:	eb d4                	jmp    804160717c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80416071a8:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80416071ab:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80416071af:	eb cb                	jmp    804160717c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80416071b1:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80416071b4:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80416071b8:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  80416071bc:	8d 50 d0             	lea    -0x30(%rax),%edx
  80416071bf:	83 fa 09             	cmp    $0x9,%edx
  80416071c2:	77 7e                	ja     8041607242 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  80416071c4:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80416071c8:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  80416071cc:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  80416071d1:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80416071d5:	8d 50 d0             	lea    -0x30(%rax),%edx
  80416071d8:	83 fa 09             	cmp    $0x9,%edx
  80416071db:	76 e7                	jbe    80416071c4 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  80416071dd:	4c 89 f3             	mov    %r14,%rbx
  80416071e0:	eb 19                	jmp    80416071fb <vprintfmt+0x102>
        precision = va_arg(aq, int);
  80416071e2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416071e5:	83 f8 2f             	cmp    $0x2f,%eax
  80416071e8:	77 2a                	ja     8041607214 <vprintfmt+0x11b>
  80416071ea:	89 c2                	mov    %eax,%edx
  80416071ec:	4c 01 d2             	add    %r10,%rdx
  80416071ef:	83 c0 08             	add    $0x8,%eax
  80416071f2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416071f5:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80416071f8:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80416071fb:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80416071ff:	0f 89 77 ff ff ff    	jns    804160717c <vprintfmt+0x83>
          width = precision, precision = -1;
  8041607205:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8041607209:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  804160720f:	e9 68 ff ff ff       	jmpq   804160717c <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8041607214:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041607218:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160721c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041607220:	eb d3                	jmp    80416071f5 <vprintfmt+0xfc>
        if (width < 0)
  8041607222:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8041607225:	85 c0                	test   %eax,%eax
  8041607227:	41 0f 48 c0          	cmovs  %r8d,%eax
  804160722b:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  804160722e:	4c 89 f3             	mov    %r14,%rbx
  8041607231:	e9 46 ff ff ff       	jmpq   804160717c <vprintfmt+0x83>
  8041607236:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8041607239:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  804160723d:	e9 3a ff ff ff       	jmpq   804160717c <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8041607242:	4c 89 f3             	mov    %r14,%rbx
  8041607245:	eb b4                	jmp    80416071fb <vprintfmt+0x102>
        lflag++;
  8041607247:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  804160724a:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  804160724d:	e9 2a ff ff ff       	jmpq   804160717c <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8041607252:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607255:	83 f8 2f             	cmp    $0x2f,%eax
  8041607258:	77 19                	ja     8041607273 <vprintfmt+0x17a>
  804160725a:	89 c2                	mov    %eax,%edx
  804160725c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041607260:	83 c0 08             	add    $0x8,%eax
  8041607263:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607266:	4c 89 fe             	mov    %r15,%rsi
  8041607269:	8b 3a                	mov    (%rdx),%edi
  804160726b:	41 ff d5             	callq  *%r13
        break;
  804160726e:	e9 b0 fe ff ff       	jmpq   8041607123 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8041607273:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041607277:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160727b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160727f:	eb e5                	jmp    8041607266 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8041607281:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607284:	83 f8 2f             	cmp    $0x2f,%eax
  8041607287:	77 5b                	ja     80416072e4 <vprintfmt+0x1eb>
  8041607289:	89 c2                	mov    %eax,%edx
  804160728b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160728f:	83 c0 08             	add    $0x8,%eax
  8041607292:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607295:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8041607297:	89 c8                	mov    %ecx,%eax
  8041607299:	c1 f8 1f             	sar    $0x1f,%eax
  804160729c:	31 c1                	xor    %eax,%ecx
  804160729e:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80416072a0:	83 f9 08             	cmp    $0x8,%ecx
  80416072a3:	7f 4d                	jg     80416072f2 <vprintfmt+0x1f9>
  80416072a5:	48 63 c1             	movslq %ecx,%rax
  80416072a8:	48 ba 20 9d 60 41 80 	movabs $0x8041609d20,%rdx
  80416072af:	00 00 00 
  80416072b2:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80416072b6:	48 85 c0             	test   %rax,%rax
  80416072b9:	74 37                	je     80416072f2 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80416072bb:	48 89 c1             	mov    %rax,%rcx
  80416072be:	48 ba eb 86 60 41 80 	movabs $0x80416086eb,%rdx
  80416072c5:	00 00 00 
  80416072c8:	4c 89 fe             	mov    %r15,%rsi
  80416072cb:	4c 89 ef             	mov    %r13,%rdi
  80416072ce:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072d3:	48 bb 73 70 60 41 80 	movabs $0x8041607073,%rbx
  80416072da:	00 00 00 
  80416072dd:	ff d3                	callq  *%rbx
  80416072df:	e9 3f fe ff ff       	jmpq   8041607123 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  80416072e4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416072e8:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416072ec:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416072f0:	eb a3                	jmp    8041607295 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  80416072f2:	48 ba c3 99 60 41 80 	movabs $0x80416099c3,%rdx
  80416072f9:	00 00 00 
  80416072fc:	4c 89 fe             	mov    %r15,%rsi
  80416072ff:	4c 89 ef             	mov    %r13,%rdi
  8041607302:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607307:	48 bb 73 70 60 41 80 	movabs $0x8041607073,%rbx
  804160730e:	00 00 00 
  8041607311:	ff d3                	callq  *%rbx
  8041607313:	e9 0b fe ff ff       	jmpq   8041607123 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8041607318:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160731b:	83 f8 2f             	cmp    $0x2f,%eax
  804160731e:	77 4b                	ja     804160736b <vprintfmt+0x272>
  8041607320:	89 c2                	mov    %eax,%edx
  8041607322:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041607326:	83 c0 08             	add    $0x8,%eax
  8041607329:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160732c:	48 8b 02             	mov    (%rdx),%rax
  804160732f:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8041607333:	48 85 c0             	test   %rax,%rax
  8041607336:	0f 84 05 04 00 00    	je     8041607741 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  804160733c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041607340:	7e 06                	jle    8041607348 <vprintfmt+0x24f>
  8041607342:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041607346:	75 31                	jne    8041607379 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041607348:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160734c:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8041607350:	0f b6 00             	movzbl (%rax),%eax
  8041607353:	0f be f8             	movsbl %al,%edi
  8041607356:	85 ff                	test   %edi,%edi
  8041607358:	0f 84 c3 00 00 00    	je     8041607421 <vprintfmt+0x328>
  804160735e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041607362:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8041607366:	e9 85 00 00 00       	jmpq   80416073f0 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  804160736b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160736f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041607373:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041607377:	eb b3                	jmp    804160732c <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  8041607379:	49 63 f4             	movslq %r12d,%rsi
  804160737c:	48 89 c7             	mov    %rax,%rdi
  804160737f:	48 b8 0a 7a 60 41 80 	movabs $0x8041607a0a,%rax
  8041607386:	00 00 00 
  8041607389:	ff d0                	callq  *%rax
  804160738b:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160738e:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8041607391:	85 f6                	test   %esi,%esi
  8041607393:	7e 22                	jle    80416073b7 <vprintfmt+0x2be>
            putch(padc, putdat);
  8041607395:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  8041607399:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  804160739d:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  80416073a1:	4c 89 fe             	mov    %r15,%rsi
  80416073a4:	89 df                	mov    %ebx,%edi
  80416073a6:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80416073a9:	41 83 ec 01          	sub    $0x1,%r12d
  80416073ad:	75 f2                	jne    80416073a1 <vprintfmt+0x2a8>
  80416073af:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80416073b3:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80416073b7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416073bb:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80416073bf:	0f b6 00             	movzbl (%rax),%eax
  80416073c2:	0f be f8             	movsbl %al,%edi
  80416073c5:	85 ff                	test   %edi,%edi
  80416073c7:	0f 84 56 fd ff ff    	je     8041607123 <vprintfmt+0x2a>
  80416073cd:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80416073d1:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80416073d5:	eb 19                	jmp    80416073f0 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80416073d7:	4c 89 fe             	mov    %r15,%rsi
  80416073da:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80416073dd:	41 83 ee 01          	sub    $0x1,%r14d
  80416073e1:	48 83 c3 01          	add    $0x1,%rbx
  80416073e5:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80416073e9:	0f be f8             	movsbl %al,%edi
  80416073ec:	85 ff                	test   %edi,%edi
  80416073ee:	74 29                	je     8041607419 <vprintfmt+0x320>
  80416073f0:	45 85 e4             	test   %r12d,%r12d
  80416073f3:	78 06                	js     80416073fb <vprintfmt+0x302>
  80416073f5:	41 83 ec 01          	sub    $0x1,%r12d
  80416073f9:	78 48                	js     8041607443 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80416073fb:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  80416073ff:	74 d6                	je     80416073d7 <vprintfmt+0x2de>
  8041607401:	0f be c0             	movsbl %al,%eax
  8041607404:	83 e8 20             	sub    $0x20,%eax
  8041607407:	83 f8 5e             	cmp    $0x5e,%eax
  804160740a:	76 cb                	jbe    80416073d7 <vprintfmt+0x2de>
            putch('?', putdat);
  804160740c:	4c 89 fe             	mov    %r15,%rsi
  804160740f:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8041607414:	41 ff d5             	callq  *%r13
  8041607417:	eb c4                	jmp    80416073dd <vprintfmt+0x2e4>
  8041607419:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160741d:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8041607421:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8041607424:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041607428:	0f 8e f5 fc ff ff    	jle    8041607123 <vprintfmt+0x2a>
          putch(' ', putdat);
  804160742e:	4c 89 fe             	mov    %r15,%rsi
  8041607431:	bf 20 00 00 00       	mov    $0x20,%edi
  8041607436:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8041607439:	83 eb 01             	sub    $0x1,%ebx
  804160743c:	75 f0                	jne    804160742e <vprintfmt+0x335>
  804160743e:	e9 e0 fc ff ff       	jmpq   8041607123 <vprintfmt+0x2a>
  8041607443:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8041607447:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  804160744b:	eb d4                	jmp    8041607421 <vprintfmt+0x328>
  if (lflag >= 2)
  804160744d:	83 f9 01             	cmp    $0x1,%ecx
  8041607450:	7f 1d                	jg     804160746f <vprintfmt+0x376>
  else if (lflag)
  8041607452:	85 c9                	test   %ecx,%ecx
  8041607454:	74 5e                	je     80416074b4 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8041607456:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607459:	83 f8 2f             	cmp    $0x2f,%eax
  804160745c:	77 48                	ja     80416074a6 <vprintfmt+0x3ad>
  804160745e:	89 c2                	mov    %eax,%edx
  8041607460:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041607464:	83 c0 08             	add    $0x8,%eax
  8041607467:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160746a:	48 8b 1a             	mov    (%rdx),%rbx
  804160746d:	eb 17                	jmp    8041607486 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  804160746f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607472:	83 f8 2f             	cmp    $0x2f,%eax
  8041607475:	77 21                	ja     8041607498 <vprintfmt+0x39f>
  8041607477:	89 c2                	mov    %eax,%edx
  8041607479:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160747d:	83 c0 08             	add    $0x8,%eax
  8041607480:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607483:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  8041607486:	48 85 db             	test   %rbx,%rbx
  8041607489:	78 50                	js     80416074db <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  804160748b:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  804160748e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041607493:	e9 b4 01 00 00       	jmpq   804160764c <vprintfmt+0x553>
    return va_arg(*ap, long long);
  8041607498:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160749c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416074a0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416074a4:	eb dd                	jmp    8041607483 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80416074a6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416074aa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416074ae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416074b2:	eb b6                	jmp    804160746a <vprintfmt+0x371>
    return va_arg(*ap, int);
  80416074b4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416074b7:	83 f8 2f             	cmp    $0x2f,%eax
  80416074ba:	77 11                	ja     80416074cd <vprintfmt+0x3d4>
  80416074bc:	89 c2                	mov    %eax,%edx
  80416074be:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416074c2:	83 c0 08             	add    $0x8,%eax
  80416074c5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416074c8:	48 63 1a             	movslq (%rdx),%rbx
  80416074cb:	eb b9                	jmp    8041607486 <vprintfmt+0x38d>
  80416074cd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416074d1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416074d5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416074d9:	eb ed                	jmp    80416074c8 <vprintfmt+0x3cf>
          putch('-', putdat);
  80416074db:	4c 89 fe             	mov    %r15,%rsi
  80416074de:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80416074e3:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80416074e6:	48 89 da             	mov    %rbx,%rdx
  80416074e9:	48 f7 da             	neg    %rdx
        base = 10;
  80416074ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416074f1:	e9 56 01 00 00       	jmpq   804160764c <vprintfmt+0x553>
  if (lflag >= 2)
  80416074f6:	83 f9 01             	cmp    $0x1,%ecx
  80416074f9:	7f 25                	jg     8041607520 <vprintfmt+0x427>
  else if (lflag)
  80416074fb:	85 c9                	test   %ecx,%ecx
  80416074fd:	74 5e                	je     804160755d <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  80416074ff:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607502:	83 f8 2f             	cmp    $0x2f,%eax
  8041607505:	77 48                	ja     804160754f <vprintfmt+0x456>
  8041607507:	89 c2                	mov    %eax,%edx
  8041607509:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160750d:	83 c0 08             	add    $0x8,%eax
  8041607510:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607513:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8041607516:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160751b:	e9 2c 01 00 00       	jmpq   804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041607520:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607523:	83 f8 2f             	cmp    $0x2f,%eax
  8041607526:	77 19                	ja     8041607541 <vprintfmt+0x448>
  8041607528:	89 c2                	mov    %eax,%edx
  804160752a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160752e:	83 c0 08             	add    $0x8,%eax
  8041607531:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607534:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8041607537:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160753c:	e9 0b 01 00 00       	jmpq   804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041607541:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041607545:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041607549:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160754d:	eb e5                	jmp    8041607534 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  804160754f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041607553:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041607557:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160755b:	eb b6                	jmp    8041607513 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  804160755d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607560:	83 f8 2f             	cmp    $0x2f,%eax
  8041607563:	77 18                	ja     804160757d <vprintfmt+0x484>
  8041607565:	89 c2                	mov    %eax,%edx
  8041607567:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160756b:	83 c0 08             	add    $0x8,%eax
  804160756e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607571:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8041607573:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041607578:	e9 cf 00 00 00       	jmpq   804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160757d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041607581:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041607585:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041607589:	eb e6                	jmp    8041607571 <vprintfmt+0x478>
  if (lflag >= 2)
  804160758b:	83 f9 01             	cmp    $0x1,%ecx
  804160758e:	7f 25                	jg     80416075b5 <vprintfmt+0x4bc>
  else if (lflag)
  8041607590:	85 c9                	test   %ecx,%ecx
  8041607592:	74 5b                	je     80416075ef <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8041607594:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607597:	83 f8 2f             	cmp    $0x2f,%eax
  804160759a:	77 45                	ja     80416075e1 <vprintfmt+0x4e8>
  804160759c:	89 c2                	mov    %eax,%edx
  804160759e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416075a2:	83 c0 08             	add    $0x8,%eax
  80416075a5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416075a8:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80416075ab:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416075b0:	e9 97 00 00 00       	jmpq   804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80416075b5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416075b8:	83 f8 2f             	cmp    $0x2f,%eax
  80416075bb:	77 16                	ja     80416075d3 <vprintfmt+0x4da>
  80416075bd:	89 c2                	mov    %eax,%edx
  80416075bf:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416075c3:	83 c0 08             	add    $0x8,%eax
  80416075c6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416075c9:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80416075cc:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416075d1:	eb 79                	jmp    804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80416075d3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416075d7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416075db:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416075df:	eb e8                	jmp    80416075c9 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  80416075e1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416075e5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416075e9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416075ed:	eb b9                	jmp    80416075a8 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  80416075ef:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416075f2:	83 f8 2f             	cmp    $0x2f,%eax
  80416075f5:	77 15                	ja     804160760c <vprintfmt+0x513>
  80416075f7:	89 c2                	mov    %eax,%edx
  80416075f9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416075fd:	83 c0 08             	add    $0x8,%eax
  8041607600:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607603:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8041607605:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160760a:	eb 40                	jmp    804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160760c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041607610:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041607614:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041607618:	eb e9                	jmp    8041607603 <vprintfmt+0x50a>
        putch('0', putdat);
  804160761a:	4c 89 fe             	mov    %r15,%rsi
  804160761d:	bf 30 00 00 00       	mov    $0x30,%edi
  8041607622:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8041607625:	4c 89 fe             	mov    %r15,%rsi
  8041607628:	bf 78 00 00 00       	mov    $0x78,%edi
  804160762d:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041607630:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607633:	83 f8 2f             	cmp    $0x2f,%eax
  8041607636:	77 34                	ja     804160766c <vprintfmt+0x573>
  8041607638:	89 c2                	mov    %eax,%edx
  804160763a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160763e:	83 c0 08             	add    $0x8,%eax
  8041607641:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607644:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041607647:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  804160764c:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8041607651:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8041607655:	4c 89 fe             	mov    %r15,%rsi
  8041607658:	4c 89 ef             	mov    %r13,%rdi
  804160765b:	48 b8 cf 6f 60 41 80 	movabs $0x8041606fcf,%rax
  8041607662:	00 00 00 
  8041607665:	ff d0                	callq  *%rax
        break;
  8041607667:	e9 b7 fa ff ff       	jmpq   8041607123 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160766c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041607670:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041607674:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041607678:	eb ca                	jmp    8041607644 <vprintfmt+0x54b>
  if (lflag >= 2)
  804160767a:	83 f9 01             	cmp    $0x1,%ecx
  804160767d:	7f 22                	jg     80416076a1 <vprintfmt+0x5a8>
  else if (lflag)
  804160767f:	85 c9                	test   %ecx,%ecx
  8041607681:	74 58                	je     80416076db <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8041607683:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041607686:	83 f8 2f             	cmp    $0x2f,%eax
  8041607689:	77 42                	ja     80416076cd <vprintfmt+0x5d4>
  804160768b:	89 c2                	mov    %eax,%edx
  804160768d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041607691:	83 c0 08             	add    $0x8,%eax
  8041607694:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041607697:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160769a:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160769f:	eb ab                	jmp    804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80416076a1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416076a4:	83 f8 2f             	cmp    $0x2f,%eax
  80416076a7:	77 16                	ja     80416076bf <vprintfmt+0x5c6>
  80416076a9:	89 c2                	mov    %eax,%edx
  80416076ab:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416076af:	83 c0 08             	add    $0x8,%eax
  80416076b2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416076b5:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80416076b8:	b9 10 00 00 00       	mov    $0x10,%ecx
  80416076bd:	eb 8d                	jmp    804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80416076bf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416076c3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416076c7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416076cb:	eb e8                	jmp    80416076b5 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  80416076cd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416076d1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416076d5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416076d9:	eb bc                	jmp    8041607697 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  80416076db:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416076de:	83 f8 2f             	cmp    $0x2f,%eax
  80416076e1:	77 18                	ja     80416076fb <vprintfmt+0x602>
  80416076e3:	89 c2                	mov    %eax,%edx
  80416076e5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416076e9:	83 c0 08             	add    $0x8,%eax
  80416076ec:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416076ef:	8b 12                	mov    (%rdx),%edx
        base = 16;
  80416076f1:	b9 10 00 00 00       	mov    $0x10,%ecx
  80416076f6:	e9 51 ff ff ff       	jmpq   804160764c <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80416076fb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416076ff:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041607703:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041607707:	eb e6                	jmp    80416076ef <vprintfmt+0x5f6>
        putch(ch, putdat);
  8041607709:	4c 89 fe             	mov    %r15,%rsi
  804160770c:	bf 25 00 00 00       	mov    $0x25,%edi
  8041607711:	41 ff d5             	callq  *%r13
        break;
  8041607714:	e9 0a fa ff ff       	jmpq   8041607123 <vprintfmt+0x2a>
        putch('%', putdat);
  8041607719:	4c 89 fe             	mov    %r15,%rsi
  804160771c:	bf 25 00 00 00       	mov    $0x25,%edi
  8041607721:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8041607724:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8041607728:	0f 84 15 fa ff ff    	je     8041607143 <vprintfmt+0x4a>
  804160772e:	49 89 de             	mov    %rbx,%r14
  8041607731:	49 83 ee 01          	sub    $0x1,%r14
  8041607735:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  804160773a:	75 f5                	jne    8041607731 <vprintfmt+0x638>
  804160773c:	e9 e2 f9 ff ff       	jmpq   8041607123 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8041607741:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041607745:	74 06                	je     804160774d <vprintfmt+0x654>
  8041607747:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160774b:	7f 21                	jg     804160776e <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160774d:	bf 28 00 00 00       	mov    $0x28,%edi
  8041607752:	48 bb bd 99 60 41 80 	movabs $0x80416099bd,%rbx
  8041607759:	00 00 00 
  804160775c:	b8 28 00 00 00       	mov    $0x28,%eax
  8041607761:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041607765:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8041607769:	e9 82 fc ff ff       	jmpq   80416073f0 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160776e:	49 63 f4             	movslq %r12d,%rsi
  8041607771:	48 bf bc 99 60 41 80 	movabs $0x80416099bc,%rdi
  8041607778:	00 00 00 
  804160777b:	48 b8 0a 7a 60 41 80 	movabs $0x8041607a0a,%rax
  8041607782:	00 00 00 
  8041607785:	ff d0                	callq  *%rax
  8041607787:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160778a:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  804160778d:	48 be bc 99 60 41 80 	movabs $0x80416099bc,%rsi
  8041607794:	00 00 00 
  8041607797:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  804160779b:	85 c0                	test   %eax,%eax
  804160779d:	0f 8f f2 fb ff ff    	jg     8041607395 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80416077a3:	48 bb bd 99 60 41 80 	movabs $0x80416099bd,%rbx
  80416077aa:	00 00 00 
  80416077ad:	b8 28 00 00 00       	mov    $0x28,%eax
  80416077b2:	bf 28 00 00 00       	mov    $0x28,%edi
  80416077b7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80416077bb:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80416077bf:	e9 2c fc ff ff       	jmpq   80416073f0 <vprintfmt+0x2f7>
}
  80416077c4:	48 83 c4 48          	add    $0x48,%rsp
  80416077c8:	5b                   	pop    %rbx
  80416077c9:	41 5c                	pop    %r12
  80416077cb:	41 5d                	pop    %r13
  80416077cd:	41 5e                	pop    %r14
  80416077cf:	41 5f                	pop    %r15
  80416077d1:	5d                   	pop    %rbp
  80416077d2:	c3                   	retq   

00000080416077d3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  80416077d3:	55                   	push   %rbp
  80416077d4:	48 89 e5             	mov    %rsp,%rbp
  80416077d7:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  80416077db:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  80416077df:	48 63 c6             	movslq %esi,%rax
  80416077e2:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  80416077e7:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  80416077eb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  80416077f2:	48 85 ff             	test   %rdi,%rdi
  80416077f5:	74 2a                	je     8041607821 <vsnprintf+0x4e>
  80416077f7:	85 f6                	test   %esi,%esi
  80416077f9:	7e 26                	jle    8041607821 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  80416077fb:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  80416077ff:	48 bf 5b 70 60 41 80 	movabs $0x804160705b,%rdi
  8041607806:	00 00 00 
  8041607809:	48 b8 f9 70 60 41 80 	movabs $0x80416070f9,%rax
  8041607810:	00 00 00 
  8041607813:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  8041607815:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8041607819:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  804160781c:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  804160781f:	c9                   	leaveq 
  8041607820:	c3                   	retq   
    return -E_INVAL;
  8041607821:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041607826:	eb f7                	jmp    804160781f <vsnprintf+0x4c>

0000008041607828 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  8041607828:	55                   	push   %rbp
  8041607829:	48 89 e5             	mov    %rsp,%rbp
  804160782c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041607833:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160783a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041607841:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041607848:	84 c0                	test   %al,%al
  804160784a:	74 20                	je     804160786c <snprintf+0x44>
  804160784c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041607850:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041607854:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041607858:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160785c:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041607860:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041607864:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041607868:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  804160786c:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041607873:	00 00 00 
  8041607876:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160787d:	00 00 00 
  8041607880:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041607884:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160788b:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041607892:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  8041607899:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80416078a0:	48 b8 d3 77 60 41 80 	movabs $0x80416077d3,%rax
  80416078a7:	00 00 00 
  80416078aa:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  80416078ac:	c9                   	leaveq 
  80416078ad:	c3                   	retq   

00000080416078ae <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  80416078ae:	55                   	push   %rbp
  80416078af:	48 89 e5             	mov    %rsp,%rbp
  80416078b2:	41 57                	push   %r15
  80416078b4:	41 56                	push   %r14
  80416078b6:	41 55                	push   %r13
  80416078b8:	41 54                	push   %r12
  80416078ba:	53                   	push   %rbx
  80416078bb:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  80416078bf:	48 85 ff             	test   %rdi,%rdi
  80416078c2:	74 1e                	je     80416078e2 <readline+0x34>
    cprintf("%s", prompt);
  80416078c4:	48 89 fe             	mov    %rdi,%rsi
  80416078c7:	48 bf eb 86 60 41 80 	movabs $0x80416086eb,%rdi
  80416078ce:	00 00 00 
  80416078d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416078d6:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416078dd:	00 00 00 
  80416078e0:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  80416078e2:	bf 00 00 00 00       	mov    $0x0,%edi
  80416078e7:	48 b8 3c 0d 60 41 80 	movabs $0x8041600d3c,%rax
  80416078ee:	00 00 00 
  80416078f1:	ff d0                	callq  *%rax
  80416078f3:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  80416078f6:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  80416078fc:	49 bd 1c 0d 60 41 80 	movabs $0x8041600d1c,%r13
  8041607903:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  8041607906:	49 bf 0a 0d 60 41 80 	movabs $0x8041600d0a,%r15
  804160790d:	00 00 00 
  8041607910:	eb 3f                	jmp    8041607951 <readline+0xa3>
      cprintf("read error: %i\n", c);
  8041607912:	89 c6                	mov    %eax,%esi
  8041607914:	48 bf 68 9d 60 41 80 	movabs $0x8041609d68,%rdi
  804160791b:	00 00 00 
  804160791e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607923:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  804160792a:	00 00 00 
  804160792d:	ff d2                	callq  *%rdx
      return NULL;
  804160792f:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  8041607934:	48 83 c4 08          	add    $0x8,%rsp
  8041607938:	5b                   	pop    %rbx
  8041607939:	41 5c                	pop    %r12
  804160793b:	41 5d                	pop    %r13
  804160793d:	41 5e                	pop    %r14
  804160793f:	41 5f                	pop    %r15
  8041607941:	5d                   	pop    %rbp
  8041607942:	c3                   	retq   
      if (i > 0) {
  8041607943:	45 85 e4             	test   %r12d,%r12d
  8041607946:	7e 09                	jle    8041607951 <readline+0xa3>
        if (echoing) {
  8041607948:	45 85 f6             	test   %r14d,%r14d
  804160794b:	75 41                	jne    804160798e <readline+0xe0>
        i--;
  804160794d:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  8041607951:	41 ff d5             	callq  *%r13
  8041607954:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  8041607956:	85 c0                	test   %eax,%eax
  8041607958:	78 b8                	js     8041607912 <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  804160795a:	83 f8 08             	cmp    $0x8,%eax
  804160795d:	74 e4                	je     8041607943 <readline+0x95>
  804160795f:	83 f8 7f             	cmp    $0x7f,%eax
  8041607962:	74 df                	je     8041607943 <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  8041607964:	83 f8 1f             	cmp    $0x1f,%eax
  8041607967:	7e 46                	jle    80416079af <readline+0x101>
  8041607969:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  8041607970:	7f 3d                	jg     80416079af <readline+0x101>
      if (echoing)
  8041607972:	45 85 f6             	test   %r14d,%r14d
  8041607975:	75 31                	jne    80416079a8 <readline+0xfa>
      buf[i++] = c;
  8041607977:	49 63 c4             	movslq %r12d,%rax
  804160797a:	48 b9 20 bc 61 41 80 	movabs $0x804161bc20,%rcx
  8041607981:	00 00 00 
  8041607984:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  8041607987:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  804160798c:	eb c3                	jmp    8041607951 <readline+0xa3>
          cputchar('\b');
  804160798e:	bf 08 00 00 00       	mov    $0x8,%edi
  8041607993:	41 ff d7             	callq  *%r15
          cputchar(' ');
  8041607996:	bf 20 00 00 00       	mov    $0x20,%edi
  804160799b:	41 ff d7             	callq  *%r15
          cputchar('\b');
  804160799e:	bf 08 00 00 00       	mov    $0x8,%edi
  80416079a3:	41 ff d7             	callq  *%r15
  80416079a6:	eb a5                	jmp    804160794d <readline+0x9f>
        cputchar(c);
  80416079a8:	89 c7                	mov    %eax,%edi
  80416079aa:	41 ff d7             	callq  *%r15
  80416079ad:	eb c8                	jmp    8041607977 <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  80416079af:	83 fb 0a             	cmp    $0xa,%ebx
  80416079b2:	74 05                	je     80416079b9 <readline+0x10b>
  80416079b4:	83 fb 0d             	cmp    $0xd,%ebx
  80416079b7:	75 98                	jne    8041607951 <readline+0xa3>
      if (echoing)
  80416079b9:	45 85 f6             	test   %r14d,%r14d
  80416079bc:	75 17                	jne    80416079d5 <readline+0x127>
      buf[i] = 0;
  80416079be:	48 b8 20 bc 61 41 80 	movabs $0x804161bc20,%rax
  80416079c5:	00 00 00 
  80416079c8:	4d 63 e4             	movslq %r12d,%r12
  80416079cb:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  80416079d0:	e9 5f ff ff ff       	jmpq   8041607934 <readline+0x86>
        cputchar('\n');
  80416079d5:	bf 0a 00 00 00       	mov    $0xa,%edi
  80416079da:	48 b8 0a 0d 60 41 80 	movabs $0x8041600d0a,%rax
  80416079e1:	00 00 00 
  80416079e4:	ff d0                	callq  *%rax
  80416079e6:	eb d6                	jmp    80416079be <readline+0x110>

00000080416079e8 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  80416079e8:	80 3f 00             	cmpb   $0x0,(%rdi)
  80416079eb:	74 17                	je     8041607a04 <strlen+0x1c>
  80416079ed:	48 89 fa             	mov    %rdi,%rdx
  80416079f0:	b9 01 00 00 00       	mov    $0x1,%ecx
  80416079f5:	29 f9                	sub    %edi,%ecx
    n++;
  80416079f7:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  80416079fa:	48 83 c2 01          	add    $0x1,%rdx
  80416079fe:	80 3a 00             	cmpb   $0x0,(%rdx)
  8041607a01:	75 f4                	jne    80416079f7 <strlen+0xf>
  8041607a03:	c3                   	retq   
  8041607a04:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8041607a09:	c3                   	retq   

0000008041607a0a <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041607a0a:	48 85 f6             	test   %rsi,%rsi
  8041607a0d:	74 24                	je     8041607a33 <strnlen+0x29>
  8041607a0f:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041607a12:	74 25                	je     8041607a39 <strnlen+0x2f>
  8041607a14:	48 01 fe             	add    %rdi,%rsi
  8041607a17:	48 89 fa             	mov    %rdi,%rdx
  8041607a1a:	b9 01 00 00 00       	mov    $0x1,%ecx
  8041607a1f:	29 f9                	sub    %edi,%ecx
    n++;
  8041607a21:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041607a24:	48 83 c2 01          	add    $0x1,%rdx
  8041607a28:	48 39 f2             	cmp    %rsi,%rdx
  8041607a2b:	74 11                	je     8041607a3e <strnlen+0x34>
  8041607a2d:	80 3a 00             	cmpb   $0x0,(%rdx)
  8041607a30:	75 ef                	jne    8041607a21 <strnlen+0x17>
  8041607a32:	c3                   	retq   
  8041607a33:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a38:	c3                   	retq   
  8041607a39:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8041607a3e:	c3                   	retq   

0000008041607a3f <strcpy>:

char *
strcpy(char *dst, const char *src) {
  8041607a3f:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8041607a42:	ba 00 00 00 00       	mov    $0x0,%edx
  8041607a47:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  8041607a4b:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  8041607a4e:	48 83 c2 01          	add    $0x1,%rdx
  8041607a52:	84 c9                	test   %cl,%cl
  8041607a54:	75 f1                	jne    8041607a47 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  8041607a56:	c3                   	retq   

0000008041607a57 <strcat>:

char *
strcat(char *dst, const char *src) {
  8041607a57:	55                   	push   %rbp
  8041607a58:	48 89 e5             	mov    %rsp,%rbp
  8041607a5b:	41 54                	push   %r12
  8041607a5d:	53                   	push   %rbx
  8041607a5e:	48 89 fb             	mov    %rdi,%rbx
  8041607a61:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  8041607a64:	48 b8 e8 79 60 41 80 	movabs $0x80416079e8,%rax
  8041607a6b:	00 00 00 
  8041607a6e:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  8041607a70:	48 63 f8             	movslq %eax,%rdi
  8041607a73:	48 01 df             	add    %rbx,%rdi
  8041607a76:	4c 89 e6             	mov    %r12,%rsi
  8041607a79:	48 b8 3f 7a 60 41 80 	movabs $0x8041607a3f,%rax
  8041607a80:	00 00 00 
  8041607a83:	ff d0                	callq  *%rax
  return dst;
}
  8041607a85:	48 89 d8             	mov    %rbx,%rax
  8041607a88:	5b                   	pop    %rbx
  8041607a89:	41 5c                	pop    %r12
  8041607a8b:	5d                   	pop    %rbp
  8041607a8c:	c3                   	retq   

0000008041607a8d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8041607a8d:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8041607a90:	48 85 d2             	test   %rdx,%rdx
  8041607a93:	74 1f                	je     8041607ab4 <strncpy+0x27>
  8041607a95:	48 01 fa             	add    %rdi,%rdx
  8041607a98:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  8041607a9b:	48 83 c1 01          	add    $0x1,%rcx
  8041607a9f:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041607aa3:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8041607aa7:	41 80 f8 01          	cmp    $0x1,%r8b
  8041607aab:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  8041607aaf:	48 39 ca             	cmp    %rcx,%rdx
  8041607ab2:	75 e7                	jne    8041607a9b <strncpy+0xe>
  }
  return ret;
}
  8041607ab4:	c3                   	retq   

0000008041607ab5 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8041607ab5:	48 89 f8             	mov    %rdi,%rax
  8041607ab8:	48 85 d2             	test   %rdx,%rdx
  8041607abb:	74 36                	je     8041607af3 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  8041607abd:	48 83 fa 01          	cmp    $0x1,%rdx
  8041607ac1:	74 2d                	je     8041607af0 <strlcpy+0x3b>
  8041607ac3:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041607ac7:	45 84 c0             	test   %r8b,%r8b
  8041607aca:	74 24                	je     8041607af0 <strlcpy+0x3b>
  8041607acc:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  8041607ad0:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  8041607ad5:	48 83 c0 01          	add    $0x1,%rax
  8041607ad9:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  8041607add:	48 39 d1             	cmp    %rdx,%rcx
  8041607ae0:	74 0e                	je     8041607af0 <strlcpy+0x3b>
  8041607ae2:	48 83 c1 01          	add    $0x1,%rcx
  8041607ae6:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  8041607aeb:	45 84 c0             	test   %r8b,%r8b
  8041607aee:	75 e5                	jne    8041607ad5 <strlcpy+0x20>
    *dst = '\0';
  8041607af0:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  8041607af3:	48 29 f8             	sub    %rdi,%rax
}
  8041607af6:	c3                   	retq   

0000008041607af7 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  8041607af7:	0f b6 07             	movzbl (%rdi),%eax
  8041607afa:	84 c0                	test   %al,%al
  8041607afc:	74 17                	je     8041607b15 <strcmp+0x1e>
  8041607afe:	3a 06                	cmp    (%rsi),%al
  8041607b00:	75 13                	jne    8041607b15 <strcmp+0x1e>
    p++, q++;
  8041607b02:	48 83 c7 01          	add    $0x1,%rdi
  8041607b06:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  8041607b0a:	0f b6 07             	movzbl (%rdi),%eax
  8041607b0d:	84 c0                	test   %al,%al
  8041607b0f:	74 04                	je     8041607b15 <strcmp+0x1e>
  8041607b11:	3a 06                	cmp    (%rsi),%al
  8041607b13:	74 ed                	je     8041607b02 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8041607b15:	0f b6 c0             	movzbl %al,%eax
  8041607b18:	0f b6 16             	movzbl (%rsi),%edx
  8041607b1b:	29 d0                	sub    %edx,%eax
}
  8041607b1d:	c3                   	retq   

0000008041607b1e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8041607b1e:	48 85 d2             	test   %rdx,%rdx
  8041607b21:	74 2f                	je     8041607b52 <strncmp+0x34>
  8041607b23:	0f b6 07             	movzbl (%rdi),%eax
  8041607b26:	84 c0                	test   %al,%al
  8041607b28:	74 1f                	je     8041607b49 <strncmp+0x2b>
  8041607b2a:	3a 06                	cmp    (%rsi),%al
  8041607b2c:	75 1b                	jne    8041607b49 <strncmp+0x2b>
  8041607b2e:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8041607b31:	48 83 c7 01          	add    $0x1,%rdi
  8041607b35:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8041607b39:	48 39 d7             	cmp    %rdx,%rdi
  8041607b3c:	74 1a                	je     8041607b58 <strncmp+0x3a>
  8041607b3e:	0f b6 07             	movzbl (%rdi),%eax
  8041607b41:	84 c0                	test   %al,%al
  8041607b43:	74 04                	je     8041607b49 <strncmp+0x2b>
  8041607b45:	3a 06                	cmp    (%rsi),%al
  8041607b47:	74 e8                	je     8041607b31 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8041607b49:	0f b6 07             	movzbl (%rdi),%eax
  8041607b4c:	0f b6 16             	movzbl (%rsi),%edx
  8041607b4f:	29 d0                	sub    %edx,%eax
}
  8041607b51:	c3                   	retq   
    return 0;
  8041607b52:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b57:	c3                   	retq   
  8041607b58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b5d:	c3                   	retq   

0000008041607b5e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8041607b5e:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8041607b60:	0f b6 07             	movzbl (%rdi),%eax
  8041607b63:	84 c0                	test   %al,%al
  8041607b65:	74 1e                	je     8041607b85 <strchr+0x27>
    if (*s == c)
  8041607b67:	40 38 c6             	cmp    %al,%sil
  8041607b6a:	74 1f                	je     8041607b8b <strchr+0x2d>
  for (; *s; s++)
  8041607b6c:	48 83 c7 01          	add    $0x1,%rdi
  8041607b70:	0f b6 07             	movzbl (%rdi),%eax
  8041607b73:	84 c0                	test   %al,%al
  8041607b75:	74 08                	je     8041607b7f <strchr+0x21>
    if (*s == c)
  8041607b77:	38 d0                	cmp    %dl,%al
  8041607b79:	75 f1                	jne    8041607b6c <strchr+0xe>
  for (; *s; s++)
  8041607b7b:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8041607b7e:	c3                   	retq   
  return 0;
  8041607b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b84:	c3                   	retq   
  8041607b85:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b8a:	c3                   	retq   
    if (*s == c)
  8041607b8b:	48 89 f8             	mov    %rdi,%rax
  8041607b8e:	c3                   	retq   

0000008041607b8f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  8041607b8f:	48 89 f8             	mov    %rdi,%rax
  8041607b92:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  8041607b94:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  8041607b97:	40 38 f2             	cmp    %sil,%dl
  8041607b9a:	74 13                	je     8041607baf <strfind+0x20>
  8041607b9c:	84 d2                	test   %dl,%dl
  8041607b9e:	74 0f                	je     8041607baf <strfind+0x20>
  for (; *s; s++)
  8041607ba0:	48 83 c0 01          	add    $0x1,%rax
  8041607ba4:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  8041607ba7:	38 ca                	cmp    %cl,%dl
  8041607ba9:	74 04                	je     8041607baf <strfind+0x20>
  8041607bab:	84 d2                	test   %dl,%dl
  8041607bad:	75 f1                	jne    8041607ba0 <strfind+0x11>
      break;
  return (char *)s;
}
  8041607baf:	c3                   	retq   

0000008041607bb0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  8041607bb0:	48 85 d2             	test   %rdx,%rdx
  8041607bb3:	74 3a                	je     8041607bef <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8041607bb5:	48 89 f8             	mov    %rdi,%rax
  8041607bb8:	48 09 d0             	or     %rdx,%rax
  8041607bbb:	a8 03                	test   $0x3,%al
  8041607bbd:	75 28                	jne    8041607be7 <memset+0x37>
    uint32_t k = c & 0xFFU;
  8041607bbf:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  8041607bc3:	89 f0                	mov    %esi,%eax
  8041607bc5:	c1 e0 08             	shl    $0x8,%eax
  8041607bc8:	89 f1                	mov    %esi,%ecx
  8041607bca:	c1 e1 18             	shl    $0x18,%ecx
  8041607bcd:	41 89 f0             	mov    %esi,%r8d
  8041607bd0:	41 c1 e0 10          	shl    $0x10,%r8d
  8041607bd4:	44 09 c1             	or     %r8d,%ecx
  8041607bd7:	09 ce                	or     %ecx,%esi
  8041607bd9:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  8041607bdb:	48 c1 ea 02          	shr    $0x2,%rdx
  8041607bdf:	48 89 d1             	mov    %rdx,%rcx
  8041607be2:	fc                   	cld    
  8041607be3:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8041607be5:	eb 08                	jmp    8041607bef <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  8041607be7:	89 f0                	mov    %esi,%eax
  8041607be9:	48 89 d1             	mov    %rdx,%rcx
  8041607bec:	fc                   	cld    
  8041607bed:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  8041607bef:	48 89 f8             	mov    %rdi,%rax
  8041607bf2:	c3                   	retq   

0000008041607bf3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  8041607bf3:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8041607bf6:	48 39 fe             	cmp    %rdi,%rsi
  8041607bf9:	73 40                	jae    8041607c3b <memmove+0x48>
  8041607bfb:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  8041607bff:	48 39 f9             	cmp    %rdi,%rcx
  8041607c02:	76 37                	jbe    8041607c3b <memmove+0x48>
    s += n;
    d += n;
  8041607c04:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8041607c08:	48 89 fe             	mov    %rdi,%rsi
  8041607c0b:	48 09 d6             	or     %rdx,%rsi
  8041607c0e:	48 09 ce             	or     %rcx,%rsi
  8041607c11:	40 f6 c6 03          	test   $0x3,%sil
  8041607c15:	75 14                	jne    8041607c2b <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8041607c17:	48 83 ef 04          	sub    $0x4,%rdi
  8041607c1b:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8041607c1f:	48 c1 ea 02          	shr    $0x2,%rdx
  8041607c23:	48 89 d1             	mov    %rdx,%rcx
  8041607c26:	fd                   	std    
  8041607c27:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8041607c29:	eb 0e                	jmp    8041607c39 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8041607c2b:	48 83 ef 01          	sub    $0x1,%rdi
  8041607c2f:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8041607c33:	48 89 d1             	mov    %rdx,%rcx
  8041607c36:	fd                   	std    
  8041607c37:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8041607c39:	fc                   	cld    
  8041607c3a:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8041607c3b:	48 89 c1             	mov    %rax,%rcx
  8041607c3e:	48 09 d1             	or     %rdx,%rcx
  8041607c41:	48 09 f1             	or     %rsi,%rcx
  8041607c44:	f6 c1 03             	test   $0x3,%cl
  8041607c47:	75 0e                	jne    8041607c57 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8041607c49:	48 c1 ea 02          	shr    $0x2,%rdx
  8041607c4d:	48 89 d1             	mov    %rdx,%rcx
  8041607c50:	48 89 c7             	mov    %rax,%rdi
  8041607c53:	fc                   	cld    
  8041607c54:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8041607c56:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8041607c57:	48 89 c7             	mov    %rax,%rdi
  8041607c5a:	48 89 d1             	mov    %rdx,%rcx
  8041607c5d:	fc                   	cld    
  8041607c5e:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8041607c60:	c3                   	retq   

0000008041607c61 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8041607c61:	55                   	push   %rbp
  8041607c62:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8041607c65:	48 b8 f3 7b 60 41 80 	movabs $0x8041607bf3,%rax
  8041607c6c:	00 00 00 
  8041607c6f:	ff d0                	callq  *%rax
}
  8041607c71:	5d                   	pop    %rbp
  8041607c72:	c3                   	retq   

0000008041607c73 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8041607c73:	55                   	push   %rbp
  8041607c74:	48 89 e5             	mov    %rsp,%rbp
  8041607c77:	41 57                	push   %r15
  8041607c79:	41 56                	push   %r14
  8041607c7b:	41 55                	push   %r13
  8041607c7d:	41 54                	push   %r12
  8041607c7f:	53                   	push   %rbx
  8041607c80:	48 83 ec 08          	sub    $0x8,%rsp
  8041607c84:	49 89 fe             	mov    %rdi,%r14
  8041607c87:	49 89 f7             	mov    %rsi,%r15
  8041607c8a:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  8041607c8d:	48 89 f7             	mov    %rsi,%rdi
  8041607c90:	48 b8 e8 79 60 41 80 	movabs $0x80416079e8,%rax
  8041607c97:	00 00 00 
  8041607c9a:	ff d0                	callq  *%rax
  8041607c9c:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  8041607c9f:	4c 89 ee             	mov    %r13,%rsi
  8041607ca2:	4c 89 f7             	mov    %r14,%rdi
  8041607ca5:	48 b8 0a 7a 60 41 80 	movabs $0x8041607a0a,%rax
  8041607cac:	00 00 00 
  8041607caf:	ff d0                	callq  *%rax
  8041607cb1:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  8041607cb4:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  8041607cb8:	4d 39 e5             	cmp    %r12,%r13
  8041607cbb:	74 26                	je     8041607ce3 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  8041607cbd:	4c 89 e8             	mov    %r13,%rax
  8041607cc0:	4c 29 e0             	sub    %r12,%rax
  8041607cc3:	48 39 d8             	cmp    %rbx,%rax
  8041607cc6:	76 2a                	jbe    8041607cf2 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  8041607cc8:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  8041607ccc:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8041607cd0:	4c 89 fe             	mov    %r15,%rsi
  8041607cd3:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041607cda:	00 00 00 
  8041607cdd:	ff d0                	callq  *%rax
  return dstlen + srclen;
  8041607cdf:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  8041607ce3:	48 83 c4 08          	add    $0x8,%rsp
  8041607ce7:	5b                   	pop    %rbx
  8041607ce8:	41 5c                	pop    %r12
  8041607cea:	41 5d                	pop    %r13
  8041607cec:	41 5e                	pop    %r14
  8041607cee:	41 5f                	pop    %r15
  8041607cf0:	5d                   	pop    %rbp
  8041607cf1:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  8041607cf2:	49 83 ed 01          	sub    $0x1,%r13
  8041607cf6:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8041607cfa:	4c 89 ea             	mov    %r13,%rdx
  8041607cfd:	4c 89 fe             	mov    %r15,%rsi
  8041607d00:	48 b8 61 7c 60 41 80 	movabs $0x8041607c61,%rax
  8041607d07:	00 00 00 
  8041607d0a:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  8041607d0c:	4d 01 ee             	add    %r13,%r14
  8041607d0f:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8041607d14:	eb c9                	jmp    8041607cdf <strlcat+0x6c>

0000008041607d16 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8041607d16:	48 85 d2             	test   %rdx,%rdx
  8041607d19:	74 3a                	je     8041607d55 <memcmp+0x3f>
    if (*s1 != *s2)
  8041607d1b:	0f b6 0f             	movzbl (%rdi),%ecx
  8041607d1e:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041607d22:	44 38 c1             	cmp    %r8b,%cl
  8041607d25:	75 1d                	jne    8041607d44 <memcmp+0x2e>
  8041607d27:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8041607d2c:	48 39 d0             	cmp    %rdx,%rax
  8041607d2f:	74 1e                	je     8041607d4f <memcmp+0x39>
    if (*s1 != *s2)
  8041607d31:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8041607d35:	48 83 c0 01          	add    $0x1,%rax
  8041607d39:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8041607d3f:	44 38 c1             	cmp    %r8b,%cl
  8041607d42:	74 e8                	je     8041607d2c <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  8041607d44:	0f b6 c1             	movzbl %cl,%eax
  8041607d47:	45 0f b6 c0          	movzbl %r8b,%r8d
  8041607d4b:	44 29 c0             	sub    %r8d,%eax
  8041607d4e:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  8041607d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607d54:	c3                   	retq   
  8041607d55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041607d5a:	c3                   	retq   

0000008041607d5b <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  8041607d5b:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  8041607d5f:	48 39 c7             	cmp    %rax,%rdi
  8041607d62:	73 19                	jae    8041607d7d <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  8041607d64:	89 f2                	mov    %esi,%edx
  8041607d66:	40 38 37             	cmp    %sil,(%rdi)
  8041607d69:	74 16                	je     8041607d81 <memfind+0x26>
  for (; s < ends; s++)
  8041607d6b:	48 83 c7 01          	add    $0x1,%rdi
  8041607d6f:	48 39 f8             	cmp    %rdi,%rax
  8041607d72:	74 08                	je     8041607d7c <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  8041607d74:	38 17                	cmp    %dl,(%rdi)
  8041607d76:	75 f3                	jne    8041607d6b <memfind+0x10>
  for (; s < ends; s++)
  8041607d78:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8041607d7b:	c3                   	retq   
  8041607d7c:	c3                   	retq   
  for (; s < ends; s++)
  8041607d7d:	48 89 f8             	mov    %rdi,%rax
  8041607d80:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8041607d81:	48 89 f8             	mov    %rdi,%rax
  8041607d84:	c3                   	retq   

0000008041607d85 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  8041607d85:	0f b6 07             	movzbl (%rdi),%eax
  8041607d88:	3c 20                	cmp    $0x20,%al
  8041607d8a:	74 04                	je     8041607d90 <strtol+0xb>
  8041607d8c:	3c 09                	cmp    $0x9,%al
  8041607d8e:	75 0f                	jne    8041607d9f <strtol+0x1a>
    s++;
  8041607d90:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  8041607d94:	0f b6 07             	movzbl (%rdi),%eax
  8041607d97:	3c 20                	cmp    $0x20,%al
  8041607d99:	74 f5                	je     8041607d90 <strtol+0xb>
  8041607d9b:	3c 09                	cmp    $0x9,%al
  8041607d9d:	74 f1                	je     8041607d90 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8041607d9f:	3c 2b                	cmp    $0x2b,%al
  8041607da1:	74 2b                	je     8041607dce <strtol+0x49>
  int neg  = 0;
  8041607da3:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8041607da9:	3c 2d                	cmp    $0x2d,%al
  8041607dab:	74 2d                	je     8041607dda <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8041607dad:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8041607db3:	75 0f                	jne    8041607dc4 <strtol+0x3f>
  8041607db5:	80 3f 30             	cmpb   $0x30,(%rdi)
  8041607db8:	74 2c                	je     8041607de6 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8041607dba:	85 d2                	test   %edx,%edx
  8041607dbc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041607dc1:	0f 44 d0             	cmove  %eax,%edx
  8041607dc4:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8041607dc9:	4c 63 d2             	movslq %edx,%r10
  8041607dcc:	eb 5c                	jmp    8041607e2a <strtol+0xa5>
    s++;
  8041607dce:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8041607dd2:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8041607dd8:	eb d3                	jmp    8041607dad <strtol+0x28>
    s++, neg = 1;
  8041607dda:	48 83 c7 01          	add    $0x1,%rdi
  8041607dde:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8041607de4:	eb c7                	jmp    8041607dad <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8041607de6:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8041607dea:	74 0f                	je     8041607dfb <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8041607dec:	85 d2                	test   %edx,%edx
  8041607dee:	75 d4                	jne    8041607dc4 <strtol+0x3f>
    s++, base = 8;
  8041607df0:	48 83 c7 01          	add    $0x1,%rdi
  8041607df4:	ba 08 00 00 00       	mov    $0x8,%edx
  8041607df9:	eb c9                	jmp    8041607dc4 <strtol+0x3f>
    s += 2, base = 16;
  8041607dfb:	48 83 c7 02          	add    $0x2,%rdi
  8041607dff:	ba 10 00 00 00       	mov    $0x10,%edx
  8041607e04:	eb be                	jmp    8041607dc4 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8041607e06:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8041607e0a:	41 80 f8 19          	cmp    $0x19,%r8b
  8041607e0e:	77 2f                	ja     8041607e3f <strtol+0xba>
      dig = *s - 'a' + 10;
  8041607e10:	44 0f be c1          	movsbl %cl,%r8d
  8041607e14:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8041607e18:	39 d1                	cmp    %edx,%ecx
  8041607e1a:	7d 37                	jge    8041607e53 <strtol+0xce>
    s++, val = (val * base) + dig;
  8041607e1c:	48 83 c7 01          	add    $0x1,%rdi
  8041607e20:	49 0f af c2          	imul   %r10,%rax
  8041607e24:	48 63 c9             	movslq %ecx,%rcx
  8041607e27:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8041607e2a:	0f b6 0f             	movzbl (%rdi),%ecx
  8041607e2d:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  8041607e31:	41 80 f8 09          	cmp    $0x9,%r8b
  8041607e35:	77 cf                	ja     8041607e06 <strtol+0x81>
      dig = *s - '0';
  8041607e37:	0f be c9             	movsbl %cl,%ecx
  8041607e3a:	83 e9 30             	sub    $0x30,%ecx
  8041607e3d:	eb d9                	jmp    8041607e18 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  8041607e3f:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8041607e43:	41 80 f8 19          	cmp    $0x19,%r8b
  8041607e47:	77 0a                	ja     8041607e53 <strtol+0xce>
      dig = *s - 'A' + 10;
  8041607e49:	44 0f be c1          	movsbl %cl,%r8d
  8041607e4d:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  8041607e51:	eb c5                	jmp    8041607e18 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  8041607e53:	48 85 f6             	test   %rsi,%rsi
  8041607e56:	74 03                	je     8041607e5b <strtol+0xd6>
    *endptr = (char *)s;
  8041607e58:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8041607e5b:	48 89 c2             	mov    %rax,%rdx
  8041607e5e:	48 f7 da             	neg    %rdx
  8041607e61:	45 85 c9             	test   %r9d,%r9d
  8041607e64:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8041607e68:	c3                   	retq   

0000008041607e69 <tsc_calibrate>:
  delta /= i * 256 * 1000;
  return delta;
}

uint64_t
tsc_calibrate(void) {
  8041607e69:	55                   	push   %rbp
  8041607e6a:	48 89 e5             	mov    %rsp,%rbp
  8041607e6d:	41 57                	push   %r15
  8041607e6f:	41 56                	push   %r14
  8041607e71:	41 55                	push   %r13
  8041607e73:	41 54                	push   %r12
  8041607e75:	53                   	push   %rbx
  8041607e76:	48 83 ec 28          	sub    $0x28,%rsp
  static uint64_t cpu_freq;

  if (cpu_freq == 0) {
  8041607e7a:	48 a1 20 c0 61 41 80 	movabs 0x804161c020,%rax
  8041607e81:	00 00 00 
  8041607e84:	48 85 c0             	test   %rax,%rax
  8041607e87:	0f 85 8c 01 00 00    	jne    8041608019 <tsc_calibrate+0x1b0>
    int i;
    for (i = 0; i < TIMES; i++) {
  8041607e8d:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  __asm __volatile("inb %w1,%0"
  8041607e93:	41 bd 61 00 00 00    	mov    $0x61,%r13d
  __asm __volatile("outb %0,%w1"
  8041607e99:	41 bf ff ff ff ff    	mov    $0xffffffff,%r15d
  8041607e9f:	b9 42 00 00 00       	mov    $0x42,%ecx
  uint64_t tsc = 0;
  8041607ea4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041607ea8:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041607eac:	eb 35                	jmp    8041607ee3 <tsc_calibrate+0x7a>
  8041607eae:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  for (count = 0; count < 50000; count++) {
  8041607eb2:	be 00 00 00 00       	mov    $0x0,%esi
  8041607eb7:	eb 72                	jmp    8041607f2b <tsc_calibrate+0xc2>
  uint64_t tsc = 0;
  8041607eb9:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  for (count = 0; count < 50000; count++) {
  8041607ebd:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8041607ec3:	e9 c0 00 00 00       	jmpq   8041607f88 <tsc_calibrate+0x11f>
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  8041607ec8:	41 83 c4 01          	add    $0x1,%r12d
  8041607ecc:	83 eb 01             	sub    $0x1,%ebx
  8041607ecf:	41 83 fc 75          	cmp    $0x75,%r12d
  8041607ed3:	75 7a                	jne    8041607f4f <tsc_calibrate+0xe6>
    for (i = 0; i < TIMES; i++) {
  8041607ed5:	41 83 c3 01          	add    $0x1,%r11d
  8041607ed9:	41 83 fb 64          	cmp    $0x64,%r11d
  8041607edd:	0f 84 56 01 00 00    	je     8041608039 <tsc_calibrate+0x1d0>
  __asm __volatile("inb %w1,%0"
  8041607ee3:	44 89 ea             	mov    %r13d,%edx
  8041607ee6:	ec                   	in     (%dx),%al
  outb(0x61, (inb(0x61) & ~0x02) | 0x01);
  8041607ee7:	83 e0 fc             	and    $0xfffffffc,%eax
  8041607eea:	83 c8 01             	or     $0x1,%eax
  __asm __volatile("outb %0,%w1"
  8041607eed:	ee                   	out    %al,(%dx)
  8041607eee:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
  8041607ef3:	ba 43 00 00 00       	mov    $0x43,%edx
  8041607ef8:	ee                   	out    %al,(%dx)
  8041607ef9:	44 89 f8             	mov    %r15d,%eax
  8041607efc:	89 ca                	mov    %ecx,%edx
  8041607efe:	ee                   	out    %al,(%dx)
  8041607eff:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041607f00:	ec                   	in     (%dx),%al
  8041607f01:	ec                   	in     (%dx),%al
  8041607f02:	ec                   	in     (%dx),%al
  8041607f03:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  8041607f04:	3c ff                	cmp    $0xff,%al
  8041607f06:	75 a6                	jne    8041607eae <tsc_calibrate+0x45>
  for (count = 0; count < 50000; count++) {
  8041607f08:	be 00 00 00 00       	mov    $0x0,%esi
  __asm __volatile("rdtsc"
  8041607f0d:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041607f0f:	48 c1 e2 20          	shl    $0x20,%rdx
  8041607f13:	89 c7                	mov    %eax,%edi
  8041607f15:	48 09 d7             	or     %rdx,%rdi
  8041607f18:	83 c6 01             	add    $0x1,%esi
  8041607f1b:	81 fe 50 c3 00 00    	cmp    $0xc350,%esi
  8041607f21:	74 08                	je     8041607f2b <tsc_calibrate+0xc2>
  __asm __volatile("inb %w1,%0"
  8041607f23:	89 ca                	mov    %ecx,%edx
  8041607f25:	ec                   	in     (%dx),%al
  8041607f26:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  8041607f27:	3c ff                	cmp    $0xff,%al
  8041607f29:	74 e2                	je     8041607f0d <tsc_calibrate+0xa4>
  __asm __volatile("rdtsc"
  8041607f2b:	0f 31                	rdtsc  
  if (pit_expect_msb(0xff, &tsc, &d1)) {
  8041607f2d:	83 fe 05             	cmp    $0x5,%esi
  8041607f30:	7e a3                	jle    8041607ed5 <tsc_calibrate+0x6c>
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041607f32:	48 c1 e2 20          	shl    $0x20,%rdx
  8041607f36:	89 c0                	mov    %eax,%eax
  8041607f38:	48 09 c2             	or     %rax,%rdx
  8041607f3b:	49 89 d2             	mov    %rdx,%r10
  *deltap = read_tsc() - tsc;
  8041607f3e:	49 89 d6             	mov    %rdx,%r14
  8041607f41:	49 29 fe             	sub    %rdi,%r14
  8041607f44:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  8041607f49:	41 bc 01 00 00 00    	mov    $0x1,%r12d
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  8041607f4f:	44 88 65 cf          	mov    %r12b,-0x31(%rbp)
  __asm __volatile("inb %w1,%0"
  8041607f53:	89 ca                	mov    %ecx,%edx
  8041607f55:	ec                   	in     (%dx),%al
  8041607f56:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  8041607f57:	38 c3                	cmp    %al,%bl
  8041607f59:	0f 85 5a ff ff ff    	jne    8041607eb9 <tsc_calibrate+0x50>
  for (count = 0; count < 50000; count++) {
  8041607f5f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  __asm __volatile("rdtsc"
  8041607f65:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041607f67:	48 c1 e2 20          	shl    $0x20,%rdx
  8041607f6b:	89 c0                	mov    %eax,%eax
  8041607f6d:	48 89 d6             	mov    %rdx,%rsi
  8041607f70:	48 09 c6             	or     %rax,%rsi
  8041607f73:	41 83 c1 01          	add    $0x1,%r9d
  8041607f77:	41 81 f9 50 c3 00 00 	cmp    $0xc350,%r9d
  8041607f7e:	74 08                	je     8041607f88 <tsc_calibrate+0x11f>
  __asm __volatile("inb %w1,%0"
  8041607f80:	89 ca                	mov    %ecx,%edx
  8041607f82:	ec                   	in     (%dx),%al
  8041607f83:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  8041607f84:	38 d8                	cmp    %bl,%al
  8041607f86:	74 dd                	je     8041607f65 <tsc_calibrate+0xfc>
  __asm __volatile("rdtsc"
  8041607f88:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041607f8a:	48 c1 e2 20          	shl    $0x20,%rdx
  8041607f8e:	89 c0                	mov    %eax,%eax
  8041607f90:	48 09 c2             	or     %rax,%rdx
  *deltap = read_tsc() - tsc;
  8041607f93:	48 29 f2             	sub    %rsi,%rdx
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  8041607f96:	41 83 f9 05          	cmp    $0x5,%r9d
  8041607f9a:	0f 8e 35 ff ff ff    	jle    8041607ed5 <tsc_calibrate+0x6c>
      delta -= tsc;
  8041607fa0:	48 29 fe             	sub    %rdi,%rsi
      if (d1 + d2 >= delta >> 11)
  8041607fa3:	4d 8d 04 16          	lea    (%r14,%rdx,1),%r8
  8041607fa7:	48 89 f0             	mov    %rsi,%rax
  8041607faa:	48 c1 e8 0b          	shr    $0xb,%rax
  8041607fae:	49 39 c0             	cmp    %rax,%r8
  8041607fb1:	0f 83 11 ff ff ff    	jae    8041607ec8 <tsc_calibrate+0x5f>
  8041607fb7:	49 89 d0             	mov    %rdx,%r8
  __asm __volatile("inb %w1,%0"
  8041607fba:	89 ca                	mov    %ecx,%edx
  8041607fbc:	ec                   	in     (%dx),%al
  8041607fbd:	ec                   	in     (%dx),%al
      if (!pit_verify_msb(0xfe - i))
  8041607fbe:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  8041607fc3:	2a 55 cf             	sub    -0x31(%rbp),%dl
  8041607fc6:	38 c2                	cmp    %al,%dl
  8041607fc8:	0f 85 07 ff ff ff    	jne    8041607ed5 <tsc_calibrate+0x6c>
  delta += (long)(d2 - d1) / 2;
  8041607fce:	4c 29 d7             	sub    %r10,%rdi
  8041607fd1:	49 01 f8             	add    %rdi,%r8
  8041607fd4:	4c 89 c7             	mov    %r8,%rdi
  8041607fd7:	48 c1 ef 3f          	shr    $0x3f,%rdi
  8041607fdb:	49 01 f8             	add    %rdi,%r8
  8041607fde:	49 d1 f8             	sar    %r8
  8041607fe1:	4c 01 c6             	add    %r8,%rsi
  delta *= PIT_TICK_RATE;
  8041607fe4:	48 69 f6 de 34 12 00 	imul   $0x1234de,%rsi,%rsi
  delta /= i * 256 * 1000;
  8041607feb:	45 69 e4 00 e8 03 00 	imul   $0x3e800,%r12d,%r12d
  8041607ff2:	4d 63 e4             	movslq %r12d,%r12
  8041607ff5:	48 89 f0             	mov    %rsi,%rax
  8041607ff8:	ba 00 00 00 00       	mov    $0x0,%edx
  8041607ffd:	49 f7 f4             	div    %r12
      if ((cpu_freq = quick_pit_calibrate()))
  8041608000:	4c 39 e6             	cmp    %r12,%rsi
  8041608003:	0f 82 cc fe ff ff    	jb     8041607ed5 <tsc_calibrate+0x6c>
  8041608009:	48 a3 20 c0 61 41 80 	movabs %rax,0x804161c020
  8041608010:	00 00 00 
        break;
    }
    if (i == TIMES) {
  8041608013:	41 83 fb 64          	cmp    $0x64,%r11d
  8041608017:	74 20                	je     8041608039 <tsc_calibrate+0x1d0>
      cpu_freq = DEFAULT_FREQ;
      cprintf("Can't calibrate pit timer. Using default frequency\n");
    }
  }

  return cpu_freq * 1000;
  8041608019:	48 a1 20 c0 61 41 80 	movabs 0x804161c020,%rax
  8041608020:	00 00 00 
  8041608023:	48 69 c0 e8 03 00 00 	imul   $0x3e8,%rax,%rax
}
  804160802a:	48 83 c4 28          	add    $0x28,%rsp
  804160802e:	5b                   	pop    %rbx
  804160802f:	41 5c                	pop    %r12
  8041608031:	41 5d                	pop    %r13
  8041608033:	41 5e                	pop    %r14
  8041608035:	41 5f                	pop    %r15
  8041608037:	5d                   	pop    %rbp
  8041608038:	c3                   	retq   
      cpu_freq = DEFAULT_FREQ;
  8041608039:	48 b8 20 c0 61 41 80 	movabs $0x804161c020,%rax
  8041608040:	00 00 00 
  8041608043:	48 c7 00 a0 25 26 00 	movq   $0x2625a0,(%rax)
      cprintf("Can't calibrate pit timer. Using default frequency\n");
  804160804a:	48 bf 78 9d 60 41 80 	movabs $0x8041609d78,%rdi
  8041608051:	00 00 00 
  8041608054:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608059:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041608060:	00 00 00 
  8041608063:	ff d2                	callq  *%rdx
  8041608065:	eb b2                	jmp    8041608019 <tsc_calibrate+0x1b0>

0000008041608067 <print_time>:

void
print_time(unsigned seconds) {
  8041608067:	55                   	push   %rbp
  8041608068:	48 89 e5             	mov    %rsp,%rbp
  804160806b:	89 fe                	mov    %edi,%esi
  cprintf("%u\n", seconds);
  804160806d:	48 bf b0 9d 60 41 80 	movabs $0x8041609db0,%rdi
  8041608074:	00 00 00 
  8041608077:	b8 00 00 00 00       	mov    $0x0,%eax
  804160807c:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041608083:	00 00 00 
  8041608086:	ff d2                	callq  *%rdx
}
  8041608088:	5d                   	pop    %rbp
  8041608089:	c3                   	retq   

000000804160808a <print_timer_error>:

void
print_timer_error(void) {
  804160808a:	55                   	push   %rbp
  804160808b:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Timer Error\n");
  804160808e:	48 bf b4 9d 60 41 80 	movabs $0x8041609db4,%rdi
  8041608095:	00 00 00 
  8041608098:	b8 00 00 00 00       	mov    $0x0,%eax
  804160809d:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  80416080a4:	00 00 00 
  80416080a7:	ff d2                	callq  *%rdx
}
  80416080a9:	5d                   	pop    %rbp
  80416080aa:	c3                   	retq   

00000080416080ab <timer_start>:
static int timer_id       = -1;
static uint64_t timer     = 0;
static uint64_t freq      = 0;

void
timer_start(const char *name) {
  80416080ab:	55                   	push   %rbp
  80416080ac:	48 89 e5             	mov    %rsp,%rbp
  80416080af:	41 56                	push   %r14
  80416080b1:	41 55                	push   %r13
  80416080b3:	41 54                	push   %r12
  80416080b5:	53                   	push   %rbx
  80416080b6:	49 89 fe             	mov    %rdi,%r14
  (void) timer_id;
  (void) timer;
  // DELETED in LAB 5 end

  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  80416080b9:	49 bc 80 dc 61 41 80 	movabs $0x804161dc80,%r12
  80416080c0:	00 00 00 
  80416080c3:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  80416080c8:	49 bd f7 7a 60 41 80 	movabs $0x8041607af7,%r13
  80416080cf:	00 00 00 
  80416080d2:	eb 0c                	jmp    80416080e0 <timer_start+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  80416080d4:	83 c3 01             	add    $0x1,%ebx
  80416080d7:	49 83 c4 28          	add    $0x28,%r12
  80416080db:	83 fb 05             	cmp    $0x5,%ebx
  80416080de:	74 61                	je     8041608141 <timer_start+0x96>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  80416080e0:	49 8b 3c 24          	mov    (%r12),%rdi
  80416080e4:	48 85 ff             	test   %rdi,%rdi
  80416080e7:	74 eb                	je     80416080d4 <timer_start+0x29>
  80416080e9:	4c 89 f6             	mov    %r14,%rsi
  80416080ec:	41 ff d5             	callq  *%r13
  80416080ef:	85 c0                	test   %eax,%eax
  80416080f1:	75 e1                	jne    80416080d4 <timer_start+0x29>
      timer_id = i;
  80416080f3:	89 d8                	mov    %ebx,%eax
  80416080f5:	a3 a0 a8 61 41 80 00 	movabs %eax,0x804161a8a0
  80416080fc:	00 00 
      timer_started = 1;
  80416080fe:	48 b8 38 c0 61 41 80 	movabs $0x804161c038,%rax
  8041608105:	00 00 00 
  8041608108:	c6 00 01             	movb   $0x1,(%rax)
  __asm __volatile("rdtsc"
  804160810b:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160810d:	48 c1 e2 20          	shl    $0x20,%rdx
  8041608111:	89 c0                	mov    %eax,%eax
  8041608113:	48 09 d0             	or     %rdx,%rax
  8041608116:	48 a3 30 c0 61 41 80 	movabs %rax,0x804161c030
  804160811d:	00 00 00 
      timer = read_tsc();
      freq = timertab[timer_id].get_cpu_freq();
  8041608120:	48 63 db             	movslq %ebx,%rbx
  8041608123:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  8041608127:	48 b8 80 dc 61 41 80 	movabs $0x804161dc80,%rax
  804160812e:	00 00 00 
  8041608131:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  8041608135:	48 a3 28 c0 61 41 80 	movabs %rax,0x804161c028
  804160813c:	00 00 00 
      return;
  804160813f:	eb 1b                	jmp    804160815c <timer_start+0xb1>
    }
  }

  cprintf("Timer Error\n");
  8041608141:	48 bf b4 9d 60 41 80 	movabs $0x8041609db4,%rdi
  8041608148:	00 00 00 
  804160814b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608150:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041608157:	00 00 00 
  804160815a:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160815c:	5b                   	pop    %rbx
  804160815d:	41 5c                	pop    %r12
  804160815f:	41 5d                	pop    %r13
  8041608161:	41 5e                	pop    %r14
  8041608163:	5d                   	pop    %rbp
  8041608164:	c3                   	retq   

0000008041608165 <timer_stop>:

void
timer_stop(void) {
  8041608165:	55                   	push   %rbp
  8041608166:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  if (!timer_started || timer_id < 0) {
  8041608169:	48 b8 38 c0 61 41 80 	movabs $0x804161c038,%rax
  8041608170:	00 00 00 
  8041608173:	80 38 00             	cmpb   $0x0,(%rax)
  8041608176:	74 69                	je     80416081e1 <timer_stop+0x7c>
  8041608178:	48 b8 a0 a8 61 41 80 	movabs $0x804161a8a0,%rax
  804160817f:	00 00 00 
  8041608182:	83 38 00             	cmpl   $0x0,(%rax)
  8041608185:	78 5a                	js     80416081e1 <timer_stop+0x7c>
  __asm __volatile("rdtsc"
  8041608187:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041608189:	48 c1 e2 20          	shl    $0x20,%rdx
  804160818d:	89 c0                	mov    %eax,%eax
  804160818f:	48 09 c2             	or     %rax,%rdx
    print_timer_error();
    return;
  }

  print_time((read_tsc() - timer) / freq);
  8041608192:	48 b8 30 c0 61 41 80 	movabs $0x804161c030,%rax
  8041608199:	00 00 00 
  804160819c:	48 2b 10             	sub    (%rax),%rdx
  804160819f:	48 89 d0             	mov    %rdx,%rax
  80416081a2:	48 b9 28 c0 61 41 80 	movabs $0x804161c028,%rcx
  80416081a9:	00 00 00 
  80416081ac:	ba 00 00 00 00       	mov    $0x0,%edx
  80416081b1:	48 f7 31             	divq   (%rcx)
  80416081b4:	89 c7                	mov    %eax,%edi
  80416081b6:	48 b8 67 80 60 41 80 	movabs $0x8041608067,%rax
  80416081bd:	00 00 00 
  80416081c0:	ff d0                	callq  *%rax

  timer_id = -1;
  80416081c2:	48 b8 a0 a8 61 41 80 	movabs $0x804161a8a0,%rax
  80416081c9:	00 00 00 
  80416081cc:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%rax)
  timer_started = 0;
  80416081d2:	48 b8 38 c0 61 41 80 	movabs $0x804161c038,%rax
  80416081d9:	00 00 00 
  80416081dc:	c6 00 00             	movb   $0x0,(%rax)
  80416081df:	eb 0c                	jmp    80416081ed <timer_stop+0x88>
    print_timer_error();
  80416081e1:	48 b8 8a 80 60 41 80 	movabs $0x804160808a,%rax
  80416081e8:	00 00 00 
  80416081eb:	ff d0                	callq  *%rax
  // LAB 5 code end
}
  80416081ed:	5d                   	pop    %rbp
  80416081ee:	c3                   	retq   

00000080416081ef <timer_cpu_frequency>:

void
timer_cpu_frequency(const char *name) {
  80416081ef:	55                   	push   %rbp
  80416081f0:	48 89 e5             	mov    %rsp,%rbp
  80416081f3:	41 56                	push   %r14
  80416081f5:	41 55                	push   %r13
  80416081f7:	41 54                	push   %r12
  80416081f9:	53                   	push   %rbx
  80416081fa:	49 89 fe             	mov    %rdi,%r14
  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  80416081fd:	49 bc 80 dc 61 41 80 	movabs $0x804161dc80,%r12
  8041608204:	00 00 00 
  8041608207:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160820c:	49 bd f7 7a 60 41 80 	movabs $0x8041607af7,%r13
  8041608213:	00 00 00 
  8041608216:	eb 0c                	jmp    8041608224 <timer_cpu_frequency+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  8041608218:	83 c3 01             	add    $0x1,%ebx
  804160821b:	49 83 c4 28          	add    $0x28,%r12
  804160821f:	83 fb 05             	cmp    $0x5,%ebx
  8041608222:	74 48                	je     804160826c <timer_cpu_frequency+0x7d>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  8041608224:	49 8b 3c 24          	mov    (%r12),%rdi
  8041608228:	48 85 ff             	test   %rdi,%rdi
  804160822b:	74 eb                	je     8041608218 <timer_cpu_frequency+0x29>
  804160822d:	4c 89 f6             	mov    %r14,%rsi
  8041608230:	41 ff d5             	callq  *%r13
  8041608233:	85 c0                	test   %eax,%eax
  8041608235:	75 e1                	jne    8041608218 <timer_cpu_frequency+0x29>
      cprintf("%lu\n", timertab[i].get_cpu_freq());
  8041608237:	48 63 db             	movslq %ebx,%rbx
  804160823a:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160823e:	48 b8 80 dc 61 41 80 	movabs $0x804161dc80,%rax
  8041608245:	00 00 00 
  8041608248:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160824c:	48 89 c6             	mov    %rax,%rsi
  804160824f:	48 bf 2e 8a 60 41 80 	movabs $0x8041608a2e,%rdi
  8041608256:	00 00 00 
  8041608259:	b8 00 00 00 00       	mov    $0x0,%eax
  804160825e:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041608265:	00 00 00 
  8041608268:	ff d2                	callq  *%rdx
      return;
  804160826a:	eb 1b                	jmp    8041608287 <timer_cpu_frequency+0x98>
    }
  }
  cprintf("Timer Error\n");
  804160826c:	48 bf b4 9d 60 41 80 	movabs $0x8041609db4,%rdi
  8041608273:	00 00 00 
  8041608276:	b8 00 00 00 00       	mov    $0x0,%eax
  804160827b:	48 ba 6a 5a 60 41 80 	movabs $0x8041605a6a,%rdx
  8041608282:	00 00 00 
  8041608285:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  8041608287:	5b                   	pop    %rbx
  8041608288:	41 5c                	pop    %r12
  804160828a:	41 5d                	pop    %r13
  804160828c:	41 5e                	pop    %r14
  804160828e:	5d                   	pop    %rbp
  804160828f:	c3                   	retq   

0000008041608290 <efi_call_in_32bit_mode>:
efi_call_in_32bit_mode(uint32_t func,
                       efi_registers *efi_reg,
                       void *stack_contents,
                       size_t stack_contents_size, /* 16-byte multiple */
                       uint32_t *efi_status) {
  if (func == 0) {
  8041608290:	85 ff                	test   %edi,%edi
  8041608292:	74 50                	je     80416082e4 <efi_call_in_32bit_mode+0x54>
    return -E_INVAL;
  }

  if ((efi_reg == NULL) || (stack_contents == NULL) || (stack_contents_size % 16 != 0)) {
  8041608294:	48 85 f6             	test   %rsi,%rsi
  8041608297:	74 51                	je     80416082ea <efi_call_in_32bit_mode+0x5a>
  8041608299:	48 85 d2             	test   %rdx,%rdx
  804160829c:	74 4c                	je     80416082ea <efi_call_in_32bit_mode+0x5a>
  804160829e:	f6 c1 0f             	test   $0xf,%cl
  80416082a1:	75 4d                	jne    80416082f0 <efi_call_in_32bit_mode+0x60>
                       uint32_t *efi_status) {
  80416082a3:	55                   	push   %rbp
  80416082a4:	48 89 e5             	mov    %rsp,%rbp
  80416082a7:	41 54                	push   %r12
  80416082a9:	53                   	push   %rbx
  80416082aa:	4d 89 c4             	mov    %r8,%r12
  80416082ad:	48 89 f3             	mov    %rsi,%rbx
    return -E_INVAL;
  }

  //We need to set up kernel data segments for 32 bit mode
  //before calling asm.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD32));
  80416082b0:	b8 20 00 00 00       	mov    $0x20,%eax
  80416082b5:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD32));
  80416082b7:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD32));
  80416082b9:	8e d0                	mov    %eax,%ss
  _efi_call_in_32bit_mode_asm(func,
  80416082bb:	48 b8 f6 82 60 41 80 	movabs $0x80416082f6,%rax
  80416082c2:	00 00 00 
  80416082c5:	ff d0                	callq  *%rax
                              efi_reg,
                              stack_contents,
                              stack_contents_size);
  //Restore 64 bit kernel data segments.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  80416082c7:	b8 10 00 00 00       	mov    $0x10,%eax
  80416082cc:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  80416082ce:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  80416082d0:	8e d0                	mov    %eax,%ss

  *efi_status = (uint32_t)efi_reg->rax;
  80416082d2:	48 8b 43 20          	mov    0x20(%rbx),%rax
  80416082d6:	41 89 04 24          	mov    %eax,(%r12)

  return 0;
  80416082da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416082df:	5b                   	pop    %rbx
  80416082e0:	41 5c                	pop    %r12
  80416082e2:	5d                   	pop    %rbp
  80416082e3:	c3                   	retq   
    return -E_INVAL;
  80416082e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416082e9:	c3                   	retq   
    return -E_INVAL;
  80416082ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416082ef:	c3                   	retq   
  80416082f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80416082f5:	c3                   	retq   

00000080416082f6 <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  80416082f6:	55                   	push   %rbp
    movq %rsp, %rbp
  80416082f7:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  80416082fa:	53                   	push   %rbx
	push	%r12
  80416082fb:	41 54                	push   %r12
	push	%r13
  80416082fd:	41 55                	push   %r13
	push	%r14
  80416082ff:	41 56                	push   %r14
	push	%r15
  8041608301:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  8041608303:	56                   	push   %rsi
	push	%rcx
  8041608304:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  8041608305:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  8041608306:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  8041608309:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

0000008041608310 <copyloop>:
  8041608310:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  8041608314:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  8041608318:	49 83 c0 08          	add    $0x8,%r8
  804160831c:	49 39 c8             	cmp    %rcx,%r8
  804160831f:	75 ef                	jne    8041608310 <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  8041608321:	e8 00 00 00 00       	callq  8041608326 <copyloop+0x16>
  8041608326:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  804160832d:	00 
  804160832e:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  8041608335:	00 
  8041608336:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  8041608337:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  8041608339:	6a 08                	pushq  $0x8
  804160833b:	e8 00 00 00 00       	callq  8041608340 <copyloop+0x30>
  8041608340:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  8041608347:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  8041608348:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  804160834c:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  8041608350:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  8041608354:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  8041608357:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  8041608358:	59                   	pop    %rcx
	pop	%rsi
  8041608359:	5e                   	pop    %rsi
	pop	%r15
  804160835a:	41 5f                	pop    %r15
	pop	%r14
  804160835c:	41 5e                	pop    %r14
	pop	%r13
  804160835e:	41 5d                	pop    %r13
	pop	%r12
  8041608360:	41 5c                	pop    %r12
	pop	%rbx
  8041608362:	5b                   	pop    %rbx

	leave
  8041608363:	c9                   	leaveq 
	ret
  8041608364:	c3                   	retq   

0000008041608365 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name) {
  lk->locked = 0;
  8041608365:	c7 07 00 00 00 00    	movl   $0x0,(%rdi)
#ifdef DEBUG_SPINLOCK
  lk->name = name;
#endif
}
  804160836b:	c3                   	retq   

000000804160836c <spin_lock>:
  asm volatile("lock; xchgl %0, %1"
  804160836c:	b8 01 00 00 00       	mov    $0x1,%eax
  8041608371:	f0 87 07             	lock xchg %eax,(%rdi)
#endif

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
  8041608374:	85 c0                	test   %eax,%eax
  8041608376:	74 10                	je     8041608388 <spin_lock+0x1c>
  8041608378:	ba 01 00 00 00       	mov    $0x1,%edx
    asm volatile("pause");
  804160837d:	f3 90                	pause  
  804160837f:	89 d0                	mov    %edx,%eax
  8041608381:	f0 87 07             	lock xchg %eax,(%rdi)
  while (xchg(&lk->locked, 1) != 0)
  8041608384:	85 c0                	test   %eax,%eax
  8041608386:	75 f5                	jne    804160837d <spin_lock+0x11>

    // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  get_caller_pcs(lk->pcs);
#endif
}
  8041608388:	c3                   	retq   

0000008041608389 <spin_unlock>:
  8041608389:	b8 00 00 00 00       	mov    $0x0,%eax
  804160838e:	f0 87 07             	lock xchg %eax,(%rdi)
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
}
  8041608391:	c3                   	retq   
  8041608392:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
