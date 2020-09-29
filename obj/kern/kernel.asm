
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
  # Save LoadParams in uefi_lp.
  movq %rcx, uefi_lp(%rip)
  8041600000:	48 89 0d f9 6f 01 00 	mov    %rcx,0x16ff9(%rip)        # 8041617000 <bootstacktop>

  # Set the stack pointer.
  leaq bootstacktop(%rip),%rsp
  8041600007:	48 8d 25 f2 6f 01 00 	lea    0x16ff2(%rip),%rsp        # 8041617000 <bootstacktop>

  # Clear the frame pointer register (RBP)
  # so that once we get into debugging C code,
  # stack backtraces will be terminated properly.
  xorq %rbp, %rbp      # nuke frame pointer
  804160000e:	48 31 ed             	xor    %rbp,%rbp

  # now to C code
  call i386_init
  8041600011:	e8 63 02 00 00       	callq  8041600279 <i386_init>

0000008041600016 <spin>:

  # Should never get here, but in case we do, just spin.
spin:  jmp  spin
  8041600016:	eb fe                	jmp    8041600016 <spin>

0000008041600018 <_generall_syscall>:
.comm rbp_reg, 8
.comm rsp_reg, 8
.comm _g_ret,  8

_generall_syscall:
  cli
  8041600018:	fa                   	cli    
  popq _g_ret(%rip)
  8041600019:	8f 05 c1 35 02 00    	popq   0x235c1(%rip)        # 80416235e0 <_g_ret>
  popq ret_rip(%rip)
  804160001f:	8f 05 cb 35 02 00    	popq   0x235cb(%rip)        # 80416235f0 <ret_rip>
  movq %rbp, rbp_reg(%rip)
  8041600025:	48 89 2d bc 35 02 00 	mov    %rbp,0x235bc(%rip)        # 80416235e8 <rbp_reg>
  movq %rsp, rsp_reg(%rip)
  804160002c:	48 89 25 c5 35 02 00 	mov    %rsp,0x235c5(%rip)        # 80416235f8 <rsp_reg>
  movq $0x0,%rbp
  8041600033:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  leaq bootstacktop(%rip),%rsp
  804160003a:	48 8d 25 bf 6f 01 00 	lea    0x16fbf(%rip),%rsp        # 8041617000 <bootstacktop>
  pushq $GD_KD
  8041600041:	6a 10                	pushq  $0x10
  pushq rsp_reg(%rip)
  8041600043:	ff 35 af 35 02 00    	pushq  0x235af(%rip)        # 80416235f8 <rsp_reg>
  pushfq
  8041600049:	9c                   	pushfq 
  # Guard to avoid hard to debug errors due to cli misusage.
  orl $FL_IF, (%rsp)
  804160004a:	81 0c 24 00 02 00 00 	orl    $0x200,(%rsp)
  pushq $GD_KT
  8041600051:	6a 08                	pushq  $0x8
  pushq ret_rip(%rip)
  8041600053:	ff 35 97 35 02 00    	pushq  0x23597(%rip)        # 80416235f0 <ret_rip>
  pushq $0x0
  8041600059:	6a 00                	pushq  $0x0
  pushq $0x0
  804160005b:	6a 00                	pushq  $0x0
  pushq $0x0 // %ds
  804160005d:	6a 00                	pushq  $0x0
  pushq $0x0 // %es
  804160005f:	6a 00                	pushq  $0x0
  pushq %rax
  8041600061:	50                   	push   %rax
  pushq %rbx
  8041600062:	53                   	push   %rbx
  pushq %rcx
  8041600063:	51                   	push   %rcx
  pushq %rdx
  8041600064:	52                   	push   %rdx
  pushq rbp_reg(%rip)
  8041600065:	ff 35 7d 35 02 00    	pushq  0x2357d(%rip)        # 80416235e8 <rbp_reg>
  pushq %rdi
  804160006b:	57                   	push   %rdi
  pushq %rsi
  804160006c:	56                   	push   %rsi
  pushq %r8
  804160006d:	41 50                	push   %r8
  pushq %r9
  804160006f:	41 51                	push   %r9
  pushq %r10
  8041600071:	41 52                	push   %r10
  pushq %r11
  8041600073:	41 53                	push   %r11
  pushq %r12
  8041600075:	41 54                	push   %r12
  pushq %r13
  8041600077:	41 55                	push   %r13
  pushq %r14
  8041600079:	41 56                	push   %r14
  pushq %r15
  804160007b:	41 57                	push   %r15
  movq  %rsp, %rdi
  804160007d:	48 89 e7             	mov    %rsp,%rdi
  pushq _g_ret(%rip)
  8041600080:	ff 35 5a 35 02 00    	pushq  0x2355a(%rip)        # 80416235e0 <_g_ret>
  ret
  8041600086:	c3                   	retq   

0000008041600087 <sys_yield>:

.globl sys_yield
.type  sys_yield, @function
sys_yield:
  call _generall_syscall
  8041600087:	e8 8c ff ff ff       	callq  8041600018 <_generall_syscall>
  call csys_yield
  804160008c:	e8 13 3f 00 00       	callq  8041603fa4 <csys_yield>
  jmp .
  8041600091:	eb fe                	jmp    8041600091 <sys_yield+0xa>

0000008041600093 <sys_exit>:

# LAB 3: Your code here.
.globl sys_exit
.type  sys_exit, @function
sys_exit:
  jmp .
  8041600093:	eb fe                	jmp    8041600093 <sys_exit>

0000008041600095 <alloc_pde_early_boot>:
#include <kern/trap.h>
#include <kern/sched.h>
#include <kern/cpu.h>

pde_t *
alloc_pde_early_boot(void) {
  8041600095:	55                   	push   %rbp
  8041600096:	48 89 e5             	mov    %rsp,%rbp
  //Assume pde1, pde2 is already used.
  extern uintptr_t pdefreestart, pdefreeend;
  pde_t *ret;
  static uintptr_t pdefree = (uintptr_t)&pdefreestart;

  if (pdefree >= (uintptr_t)&pdefreeend)
  8041600099:	48 b8 08 70 61 41 80 	movabs $0x8041617008,%rax
  80416000a0:	00 00 00 
  80416000a3:	48 8b 10             	mov    (%rax),%rdx
  80416000a6:	48 b8 00 c0 50 01 00 	movabs $0x150c000,%rax
  80416000ad:	00 00 00 
  80416000b0:	48 39 c2             	cmp    %rax,%rdx
  80416000b3:	73 1c                	jae    80416000d1 <alloc_pde_early_boot+0x3c>
    return NULL;

  ret = (pde_t *)pdefree;
  80416000b5:	48 89 d1             	mov    %rdx,%rcx
  pdefree += PGSIZE;
  80416000b8:	48 81 c2 00 10 00 00 	add    $0x1000,%rdx
  80416000bf:	48 89 d0             	mov    %rdx,%rax
  80416000c2:	48 a3 08 70 61 41 80 	movabs %rax,0x8041617008
  80416000c9:	00 00 00 
  return ret;
}
  80416000cc:	48 89 c8             	mov    %rcx,%rax
  80416000cf:	5d                   	pop    %rbp
  80416000d0:	c3                   	retq   
    return NULL;
  80416000d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416000d6:	eb f4                	jmp    80416000cc <alloc_pde_early_boot+0x37>

00000080416000d8 <map_addr_early_boot>:

void
map_addr_early_boot(uintptr_t addr, uintptr_t addr_phys, size_t sz) {
  80416000d8:	55                   	push   %rbp
  80416000d9:	48 89 e5             	mov    %rsp,%rbp
  80416000dc:	41 57                	push   %r15
  80416000de:	41 56                	push   %r14
  80416000e0:	41 55                	push   %r13
  80416000e2:	41 54                	push   %r12
  80416000e4:	53                   	push   %rbx
  80416000e5:	48 83 ec 08          	sub    $0x8,%rsp
  pml4e_t *pml4 = &pml4phys;
  pdpe_t *pdpt;
  pde_t *pde;

  uintptr_t addr_curr, addr_curr_phys, addr_end;
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  80416000e9:	48 89 f8             	mov    %rdi,%rax
  80416000ec:	48 25 00 00 e0 ff    	and    $0xffffffffffe00000,%rax
  addr_curr_phys = ROUNDDOWN(addr_phys, PTSIZE);
  80416000f2:	48 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%rsi
  addr_end       = ROUNDUP(addr + sz, PTSIZE);
  80416000f9:	4c 8d bc 17 ff ff 1f 	lea    0x1fffff(%rdi,%rdx,1),%r15
  8041600100:	00 
  8041600101:	49 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%r15

  pdpt = (pdpe_t *)PTE_ADDR(pml4[PML4(addr_curr)]);
  8041600108:	48 c1 ef 24          	shr    $0x24,%rdi
  804160010c:	81 e7 f8 0f 00 00    	and    $0xff8,%edi
  8041600112:	48 ba 00 10 50 01 00 	movabs $0x1501000,%rdx
  8041600119:	00 00 00 
  804160011c:	48 8b 14 3a          	mov    (%rdx,%rdi,1),%rdx
  8041600120:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  8041600127:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  804160012b:	49 39 c7             	cmp    %rax,%r15
  804160012e:	76 4f                	jbe    804160017f <map_addr_early_boot+0xa7>
  8041600130:	48 89 c3             	mov    %rax,%rbx
  8041600133:	48 29 c6             	sub    %rax,%rsi
  8041600136:	49 89 f6             	mov    %rsi,%r14
  8041600139:	4d 8d 2c 1e          	lea    (%r14,%rbx,1),%r13
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
  804160013d:	49 89 dc             	mov    %rbx,%r12
  8041600140:	49 c1 ec 1b          	shr    $0x1b,%r12
  8041600144:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
  804160014b:	4c 03 65 d0          	add    -0x30(%rbp),%r12
    if (!pde) {
  804160014f:	49 8b 04 24          	mov    (%r12),%rax
  8041600153:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041600159:	74 33                	je     804160018e <map_addr_early_boot+0xb6>
      pde                   = alloc_pde_early_boot();
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
    }
    pde[PDX(addr_curr)] = addr_curr_phys | PTE_P | PTE_W | PTE_MBZ;
  804160015b:	48 89 da             	mov    %rbx,%rdx
  804160015e:	48 c1 ea 15          	shr    $0x15,%rdx
  8041600162:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  8041600168:	49 81 cd 83 01 00 00 	or     $0x183,%r13
  804160016f:	4c 89 2c d0          	mov    %r13,(%rax,%rdx,8)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  8041600173:	48 81 c3 00 00 20 00 	add    $0x200000,%rbx
  804160017a:	49 39 df             	cmp    %rbx,%r15
  804160017d:	77 ba                	ja     8041600139 <map_addr_early_boot+0x61>
  }
}
  804160017f:	48 83 c4 08          	add    $0x8,%rsp
  8041600183:	5b                   	pop    %rbx
  8041600184:	41 5c                	pop    %r12
  8041600186:	41 5d                	pop    %r13
  8041600188:	41 5e                	pop    %r14
  804160018a:	41 5f                	pop    %r15
  804160018c:	5d                   	pop    %rbp
  804160018d:	c3                   	retq   
      pde                   = alloc_pde_early_boot();
  804160018e:	48 b8 95 00 60 41 80 	movabs $0x8041600095,%rax
  8041600195:	00 00 00 
  8041600198:	ff d0                	callq  *%rax
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
  804160019a:	48 89 c2             	mov    %rax,%rdx
  804160019d:	48 83 ca 03          	or     $0x3,%rdx
  80416001a1:	49 89 14 24          	mov    %rdx,(%r12)
  80416001a5:	eb b4                	jmp    804160015b <map_addr_early_boot+0x83>

00000080416001a7 <early_boot_pml4_init>:
// Additionally maps pml4 memory so that we dont get memory errors on accessing
// uefi_lp, MemMap, KASAN functions.
void
early_boot_pml4_init(void) {
  80416001a7:	55                   	push   %rbp
  80416001a8:	48 89 e5             	mov    %rsp,%rbp
  80416001ab:	41 54                	push   %r12
  80416001ad:	53                   	push   %rbx

  map_addr_early_boot((uintptr_t)uefi_lp, (uintptr_t)uefi_lp, sizeof(LOADER_PARAMS));
  80416001ae:	49 bc 00 70 61 41 80 	movabs $0x8041617000,%r12
  80416001b5:	00 00 00 
  80416001b8:	49 8b 3c 24          	mov    (%r12),%rdi
  80416001bc:	ba c8 00 00 00       	mov    $0xc8,%edx
  80416001c1:	48 89 fe             	mov    %rdi,%rsi
  80416001c4:	48 bb d8 00 60 41 80 	movabs $0x80416000d8,%rbx
  80416001cb:	00 00 00 
  80416001ce:	ff d3                	callq  *%rbx
  map_addr_early_boot((uintptr_t)uefi_lp->MemoryMap, (uintptr_t)uefi_lp->MemoryMap, uefi_lp->MemoryMapSize);
  80416001d0:	49 8b 04 24          	mov    (%r12),%rax
  80416001d4:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80416001d8:	48 8b 50 38          	mov    0x38(%rax),%rdx
  80416001dc:	48 89 fe             	mov    %rdi,%rsi
  80416001df:	ff d3                	callq  *%rbx

#ifdef SANITIZE_SHADOW_BASE
  map_addr_early_boot(SANITIZE_SHADOW_BASE, SANITIZE_SHADOW_BASE - KERNBASE, SANITIZE_SHADOW_SIZE);
#endif

  map_addr_early_boot(FBUFFBASE, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
  80416001e1:	49 8b 04 24          	mov    (%r12),%rax
  80416001e5:	8b 50 48             	mov    0x48(%rax),%edx
  80416001e8:	48 8b 70 40          	mov    0x40(%rax),%rsi
  80416001ec:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416001f3:	00 00 00 
  80416001f6:	ff d3                	callq  *%rbx
}
  80416001f8:	5b                   	pop    %rbx
  80416001f9:	41 5c                	pop    %r12
  80416001fb:	5d                   	pop    %rbp
  80416001fc:	c3                   	retq   

00000080416001fd <test_backtrace>:

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x) {
  80416001fd:	55                   	push   %rbp
  80416001fe:	48 89 e5             	mov    %rsp,%rbp
  8041600201:	53                   	push   %rbx
  8041600202:	48 83 ec 08          	sub    $0x8,%rsp
  8041600206:	89 fb                	mov    %edi,%ebx
  cprintf("entering test_backtrace %d\n", x);
  8041600208:	89 fe                	mov    %edi,%esi
  804160020a:	48 bf 20 54 60 41 80 	movabs $0x8041605420,%rdi
  8041600211:	00 00 00 
  8041600214:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600219:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041600220:	00 00 00 
  8041600223:	ff d2                	callq  *%rdx
  if (x > 0)
  8041600225:	85 db                	test   %ebx,%ebx
  8041600227:	7e 33                	jle    804160025c <test_backtrace+0x5f>
    test_backtrace(x - 1);
  8041600229:	8d 7b ff             	lea    -0x1(%rbx),%edi
  804160022c:	48 b8 fd 01 60 41 80 	movabs $0x80416001fd,%rax
  8041600233:	00 00 00 
  8041600236:	ff d0                	callq  *%rax
  else
    mon_backtrace(0, 0, 0);
  cprintf("leaving test_backtrace %d\n", x);
  8041600238:	89 de                	mov    %ebx,%esi
  804160023a:	48 bf 3c 54 60 41 80 	movabs $0x804160543c,%rdi
  8041600241:	00 00 00 
  8041600244:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600249:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041600250:	00 00 00 
  8041600253:	ff d2                	callq  *%rdx
}
  8041600255:	48 83 c4 08          	add    $0x8,%rsp
  8041600259:	5b                   	pop    %rbx
  804160025a:	5d                   	pop    %rbp
  804160025b:	c3                   	retq   
    mon_backtrace(0, 0, 0);
  804160025c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600261:	be 00 00 00 00       	mov    $0x0,%esi
  8041600266:	bf 00 00 00 00       	mov    $0x0,%edi
  804160026b:	48 b8 c9 39 60 41 80 	movabs $0x80416039c9,%rax
  8041600272:	00 00 00 
  8041600275:	ff d0                	callq  *%rax
  8041600277:	eb bf                	jmp    8041600238 <test_backtrace+0x3b>

0000008041600279 <i386_init>:

void
i386_init(void) {
  8041600279:	55                   	push   %rbp
  804160027a:	48 89 e5             	mov    %rsp,%rbp
  804160027d:	41 54                	push   %r12
  804160027f:	53                   	push   %rbx
  extern char end[];

  early_boot_pml4_init();
  8041600280:	48 b8 a7 01 60 41 80 	movabs $0x80416001a7,%rax
  8041600287:	00 00 00 
  804160028a:	ff d0                	callq  *%rax

  // Initialize the console.
  // Can't call cprintf until after we do this!
  cons_init();
  804160028c:	48 b8 6d 0b 60 41 80 	movabs $0x8041600b6d,%rax
  8041600293:	00 00 00 
  8041600296:	ff d0                	callq  *%rax

  cprintf("6828 decimal is %o octal!\n", 6828);
  8041600298:	be ac 1a 00 00       	mov    $0x1aac,%esi
  804160029d:	48 bf 57 54 60 41 80 	movabs $0x8041605457,%rdi
  80416002a4:	00 00 00 
  80416002a7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002ac:	48 bb 0b 41 60 41 80 	movabs $0x804160410b,%rbx
  80416002b3:	00 00 00 
  80416002b6:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  80416002b8:	48 be 00 60 62 41 80 	movabs $0x8041626000,%rsi
  80416002bf:	00 00 00 
  80416002c2:	48 bf 72 54 60 41 80 	movabs $0x8041605472,%rdi
  80416002c9:	00 00 00 
  80416002cc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002d1:	ff d3                	callq  *%rbx
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80416002d3:	48 b8 60 2f 62 41 80 	movabs $0x8041622f60,%rax
  80416002da:	00 00 00 
  80416002dd:	48 ba 60 2f 62 41 80 	movabs $0x8041622f60,%rdx
  80416002e4:	00 00 00 
  80416002e7:	48 39 c2             	cmp    %rax,%rdx
  80416002ea:	73 16                	jae    8041600302 <i386_init+0x89>
  80416002ec:	48 89 d3             	mov    %rdx,%rbx
  80416002ef:	49 89 c4             	mov    %rax,%r12
    (*ctor)();
  80416002f2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002f7:	ff 13                	callq  *(%rbx)
    ctor++;
  80416002f9:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80416002fd:	4c 39 e3             	cmp    %r12,%rbx
  8041600300:	72 f0                	jb     80416002f2 <i386_init+0x79>
  }

  // Framebuffer init should be done after memory init.
  fb_init();
  8041600302:	48 b8 5e 0a 60 41 80 	movabs $0x8041600a5e,%rax
  8041600309:	00 00 00 
  804160030c:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  804160030e:	48 bf 7b 54 60 41 80 	movabs $0x804160547b,%rdi
  8041600315:	00 00 00 
  8041600318:	b8 00 00 00 00       	mov    $0x0,%eax
  804160031d:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041600324:	00 00 00 
  8041600327:	ff d2                	callq  *%rdx

  // user environment initialization functions
  env_init();
  8041600329:	48 b8 30 3d 60 41 80 	movabs $0x8041603d30,%rax
  8041600330:	00 00 00 
  8041600333:	ff d0                	callq  *%rax

#ifdef CONFIG_KSPACE
  // Touch all you want.
  ENV_CREATE_KERNEL_TYPE(prog_test1);
  8041600335:	be 01 00 00 00       	mov    $0x1,%esi
  804160033a:	48 bf 90 77 61 41 80 	movabs $0x8041617790,%rdi
  8041600341:	00 00 00 
  8041600344:	48 bb 21 3f 60 41 80 	movabs $0x8041603f21,%rbx
  804160034b:	00 00 00 
  804160034e:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test2);
  8041600350:	be 01 00 00 00       	mov    $0x1,%esi
  8041600355:	48 bf 8a b4 61 41 80 	movabs $0x804161b48a,%rdi
  804160035c:	00 00 00 
  804160035f:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test3);
  8041600361:	be 01 00 00 00       	mov    $0x1,%esi
  8041600366:	48 bf 64 f2 61 41 80 	movabs $0x804161f264,%rdi
  804160036d:	00 00 00 
  8041600370:	ff d3                	callq  *%rbx
#endif

  // Schedule and run the first user environment!
  sched_yield();
  8041600372:	48 b8 9f 41 60 41 80 	movabs $0x804160419f,%rax
  8041600379:	00 00 00 
  804160037c:	ff d0                	callq  *%rax

000000804160037e <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  804160037e:	55                   	push   %rbp
  804160037f:	48 89 e5             	mov    %rsp,%rbp
  8041600382:	41 54                	push   %r12
  8041600384:	53                   	push   %rbx
  8041600385:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160038c:	49 89 d4             	mov    %rdx,%r12
  804160038f:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8041600396:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  804160039d:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416003a4:	84 c0                	test   %al,%al
  80416003a6:	74 23                	je     80416003cb <_panic+0x4d>
  80416003a8:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416003af:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416003b3:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416003b7:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416003bb:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416003bf:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416003c3:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416003c7:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  if (panicstr)
  80416003cb:	48 b8 60 2f 62 41 80 	movabs $0x8041622f60,%rax
  80416003d2:	00 00 00 
  80416003d5:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416003d9:	74 13                	je     80416003ee <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416003db:	48 bb ca 3a 60 41 80 	movabs $0x8041603aca,%rbx
  80416003e2:	00 00 00 
  80416003e5:	bf 00 00 00 00       	mov    $0x0,%edi
  80416003ea:	ff d3                	callq  *%rbx
  80416003ec:	eb f7                	jmp    80416003e5 <_panic+0x67>
  panicstr = fmt;
  80416003ee:	4c 89 e0             	mov    %r12,%rax
  80416003f1:	48 a3 60 2f 62 41 80 	movabs %rax,0x8041622f60
  80416003f8:	00 00 00 
  __asm __volatile("cli; cld");
  80416003fb:	fa                   	cli    
  80416003fc:	fc                   	cld    
  va_start(ap, fmt);
  80416003fd:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  8041600404:	00 00 00 
  8041600407:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  804160040e:	00 00 00 
  8041600411:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041600415:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  804160041c:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  8041600423:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel panic at %s:%d: ", file, line);
  804160042a:	89 f2                	mov    %esi,%edx
  804160042c:	48 89 fe             	mov    %rdi,%rsi
  804160042f:	48 bf 94 54 60 41 80 	movabs $0x8041605494,%rdi
  8041600436:	00 00 00 
  8041600439:	b8 00 00 00 00       	mov    $0x0,%eax
  804160043e:	48 bb 0b 41 60 41 80 	movabs $0x804160410b,%rbx
  8041600445:	00 00 00 
  8041600448:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  804160044a:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600451:	4c 89 e7             	mov    %r12,%rdi
  8041600454:	48 b8 d7 40 60 41 80 	movabs $0x80416040d7,%rax
  804160045b:	00 00 00 
  804160045e:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600460:	48 bf 69 5a 60 41 80 	movabs $0x8041605a69,%rdi
  8041600467:	00 00 00 
  804160046a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160046f:	ff d3                	callq  *%rbx
  8041600471:	e9 65 ff ff ff       	jmpq   80416003db <_panic+0x5d>

0000008041600476 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  8041600476:	55                   	push   %rbp
  8041600477:	48 89 e5             	mov    %rsp,%rbp
  804160047a:	41 54                	push   %r12
  804160047c:	53                   	push   %rbx
  804160047d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600484:	49 89 d4             	mov    %rdx,%r12
  8041600487:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  804160048e:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8041600495:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  804160049c:	84 c0                	test   %al,%al
  804160049e:	74 23                	je     80416004c3 <_warn+0x4d>
  80416004a0:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416004a7:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416004ab:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416004af:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416004b3:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416004b7:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416004bb:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416004bf:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416004c3:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416004ca:	00 00 00 
  80416004cd:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416004d4:	00 00 00 
  80416004d7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416004db:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416004e2:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416004e9:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  80416004f0:	89 f2                	mov    %esi,%edx
  80416004f2:	48 89 fe             	mov    %rdi,%rsi
  80416004f5:	48 bf ac 54 60 41 80 	movabs $0x80416054ac,%rdi
  80416004fc:	00 00 00 
  80416004ff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600504:	48 bb 0b 41 60 41 80 	movabs $0x804160410b,%rbx
  804160050b:	00 00 00 
  804160050e:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600510:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600517:	4c 89 e7             	mov    %r12,%rdi
  804160051a:	48 b8 d7 40 60 41 80 	movabs $0x80416040d7,%rax
  8041600521:	00 00 00 
  8041600524:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600526:	48 bf 69 5a 60 41 80 	movabs $0x8041605a69,%rdi
  804160052d:	00 00 00 
  8041600530:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600535:	ff d3                	callq  *%rbx
  va_end(ap);
}
  8041600537:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  804160053e:	5b                   	pop    %rbx
  804160053f:	41 5c                	pop    %r12
  8041600541:	5d                   	pop    %rbp
  8041600542:	c3                   	retq   

0000008041600543 <serial_proc_data>:
    }
  }
}

static int
serial_proc_data(void) {
  8041600543:	55                   	push   %rbp
  8041600544:	48 89 e5             	mov    %rsp,%rbp
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  8041600547:	ba fd 03 00 00       	mov    $0x3fd,%edx
  804160054c:	ec                   	in     (%dx),%al
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  804160054d:	a8 01                	test   $0x1,%al
  804160054f:	74 0b                	je     804160055c <serial_proc_data+0x19>
  8041600551:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600556:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  8041600557:	0f b6 c0             	movzbl %al,%eax
}
  804160055a:	5d                   	pop    %rbp
  804160055b:	c3                   	retq   
    return -1;
  804160055c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041600561:	eb f7                	jmp    804160055a <serial_proc_data+0x17>

0000008041600563 <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  8041600563:	55                   	push   %rbp
  8041600564:	48 89 e5             	mov    %rsp,%rbp
  8041600567:	41 54                	push   %r12
  8041600569:	53                   	push   %rbx
  804160056a:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  804160056d:	48 bb a0 2f 62 41 80 	movabs $0x8041622fa0,%rbx
  8041600574:	00 00 00 
  while ((c = (*proc)()) != -1) {
  8041600577:	41 ff d4             	callq  *%r12
  804160057a:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160057d:	74 2c                	je     80416005ab <cons_intr+0x48>
    if (c == 0)
  804160057f:	85 c0                	test   %eax,%eax
  8041600581:	74 f4                	je     8041600577 <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  8041600583:	8b 93 04 02 00 00    	mov    0x204(%rbx),%edx
  8041600589:	8d 4a 01             	lea    0x1(%rdx),%ecx
  804160058c:	89 8b 04 02 00 00    	mov    %ecx,0x204(%rbx)
  8041600592:	89 d2                	mov    %edx,%edx
  8041600594:	88 04 13             	mov    %al,(%rbx,%rdx,1)
    if (cons.wpos == CONSBUFSIZE)
  8041600597:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  804160059d:	75 d8                	jne    8041600577 <cons_intr+0x14>
      cons.wpos = 0;
  804160059f:	c7 83 04 02 00 00 00 	movl   $0x0,0x204(%rbx)
  80416005a6:	00 00 00 
  80416005a9:	eb cc                	jmp    8041600577 <cons_intr+0x14>
  }
}
  80416005ab:	5b                   	pop    %rbx
  80416005ac:	41 5c                	pop    %r12
  80416005ae:	5d                   	pop    %rbp
  80416005af:	c3                   	retq   

00000080416005b0 <kbd_proc_data>:
kbd_proc_data(void) {
  80416005b0:	55                   	push   %rbp
  80416005b1:	48 89 e5             	mov    %rsp,%rbp
  80416005b4:	53                   	push   %rbx
  80416005b5:	48 83 ec 08          	sub    $0x8,%rsp
  80416005b9:	ba 64 00 00 00       	mov    $0x64,%edx
  80416005be:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416005bf:	a8 01                	test   $0x1,%al
  80416005c1:	0f 84 33 01 00 00    	je     80416006fa <kbd_proc_data+0x14a>
  80416005c7:	ba 60 00 00 00       	mov    $0x60,%edx
  80416005cc:	ec                   	in     (%dx),%al
  80416005cd:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416005cf:	3c e0                	cmp    $0xe0,%al
  80416005d1:	0f 84 99 00 00 00    	je     8041600670 <kbd_proc_data+0xc0>
  } else if (data & 0x80) {
  80416005d7:	84 c0                	test   %al,%al
  80416005d9:	0f 88 a5 00 00 00    	js     8041600684 <kbd_proc_data+0xd4>
  } else if (shift & E0ESC) {
  80416005df:	48 bf 80 2f 62 41 80 	movabs $0x8041622f80,%rdi
  80416005e6:	00 00 00 
  80416005e9:	8b 0f                	mov    (%rdi),%ecx
  80416005eb:	f6 c1 40             	test   $0x40,%cl
  80416005ee:	74 0c                	je     80416005fc <kbd_proc_data+0x4c>
    data |= 0x80;
  80416005f0:	83 c8 80             	or     $0xffffff80,%eax
  80416005f3:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416005f5:	89 c8                	mov    %ecx,%eax
  80416005f7:	83 e0 bf             	and    $0xffffffbf,%eax
  80416005fa:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  80416005fc:	0f b6 f2             	movzbl %dl,%esi
  80416005ff:	48 b8 20 56 60 41 80 	movabs $0x8041605620,%rax
  8041600606:	00 00 00 
  8041600609:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  804160060d:	48 b9 80 2f 62 41 80 	movabs $0x8041622f80,%rcx
  8041600614:	00 00 00 
  8041600617:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  8041600619:	48 bf 20 55 60 41 80 	movabs $0x8041605520,%rdi
  8041600620:	00 00 00 
  8041600623:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  8041600627:	31 f0                	xor    %esi,%eax
  8041600629:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  804160062b:	89 c6                	mov    %eax,%esi
  804160062d:	83 e6 03             	and    $0x3,%esi
  8041600630:	0f b6 d2             	movzbl %dl,%edx
  8041600633:	48 b9 00 55 60 41 80 	movabs $0x8041605500,%rcx
  804160063a:	00 00 00 
  804160063d:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  8041600641:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  8041600645:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  8041600648:	a8 08                	test   $0x8,%al
  804160064a:	74 0d                	je     8041600659 <kbd_proc_data+0xa9>
    if ('a' <= c && c <= 'z')
  804160064c:	89 da                	mov    %ebx,%edx
  804160064e:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  8041600651:	83 f9 19             	cmp    $0x19,%ecx
  8041600654:	77 6b                	ja     80416006c1 <kbd_proc_data+0x111>
      c += 'A' - 'a';
  8041600656:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8041600659:	f7 d0                	not    %eax
  804160065b:	a8 06                	test   $0x6,%al
  804160065d:	75 08                	jne    8041600667 <kbd_proc_data+0xb7>
  804160065f:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  8041600665:	74 68                	je     80416006cf <kbd_proc_data+0x11f>
}
  8041600667:	89 d8                	mov    %ebx,%eax
  8041600669:	48 83 c4 08          	add    $0x8,%rsp
  804160066d:	5b                   	pop    %rbx
  804160066e:	5d                   	pop    %rbp
  804160066f:	c3                   	retq   
    shift |= E0ESC;
  8041600670:	48 b8 80 2f 62 41 80 	movabs $0x8041622f80,%rax
  8041600677:	00 00 00 
  804160067a:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  804160067d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041600682:	eb e3                	jmp    8041600667 <kbd_proc_data+0xb7>
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600684:	48 bf 80 2f 62 41 80 	movabs $0x8041622f80,%rdi
  804160068b:	00 00 00 
  804160068e:	8b 0f                	mov    (%rdi),%ecx
  8041600690:	89 ce                	mov    %ecx,%esi
  8041600692:	83 e6 40             	and    $0x40,%esi
  8041600695:	83 e0 7f             	and    $0x7f,%eax
  8041600698:	85 f6                	test   %esi,%esi
  804160069a:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  804160069d:	0f b6 d2             	movzbl %dl,%edx
  80416006a0:	48 b8 20 56 60 41 80 	movabs $0x8041605620,%rax
  80416006a7:	00 00 00 
  80416006aa:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  80416006ae:	83 c8 40             	or     $0x40,%eax
  80416006b1:	0f b6 c0             	movzbl %al,%eax
  80416006b4:	f7 d0                	not    %eax
  80416006b6:	21 c8                	and    %ecx,%eax
  80416006b8:	89 07                	mov    %eax,(%rdi)
    return 0;
  80416006ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416006bf:	eb a6                	jmp    8041600667 <kbd_proc_data+0xb7>
    else if ('A' <= c && c <= 'Z')
  80416006c1:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416006c4:	8d 4b 20             	lea    0x20(%rbx),%ecx
  80416006c7:	83 fa 19             	cmp    $0x19,%edx
  80416006ca:	0f 46 d9             	cmovbe %ecx,%ebx
  80416006cd:	eb 8a                	jmp    8041600659 <kbd_proc_data+0xa9>
    cprintf("Rebooting!\n");
  80416006cf:	48 bf c6 54 60 41 80 	movabs $0x80416054c6,%rdi
  80416006d6:	00 00 00 
  80416006d9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416006de:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416006e5:	00 00 00 
  80416006e8:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416006ea:	ba 92 00 00 00       	mov    $0x92,%edx
  80416006ef:	b8 03 00 00 00       	mov    $0x3,%eax
  80416006f4:	ee                   	out    %al,(%dx)
  80416006f5:	e9 6d ff ff ff       	jmpq   8041600667 <kbd_proc_data+0xb7>
    return -1;
  80416006fa:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80416006ff:	e9 63 ff ff ff       	jmpq   8041600667 <kbd_proc_data+0xb7>

0000008041600704 <draw_char>:
draw_char(uint32_t *buffer, uint32_t x, uint32_t y, uint32_t color, char charcode) {
  8041600704:	55                   	push   %rbp
  8041600705:	48 89 e5             	mov    %rsp,%rbp
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  8041600708:	4d 0f be c0          	movsbq %r8b,%r8
  804160070c:	48 b8 20 73 61 41 80 	movabs $0x8041617320,%rax
  8041600713:	00 00 00 
  8041600716:	4e 8d 0c c0          	lea    (%rax,%r8,8),%r9
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160071a:	48 b8 b4 31 62 41 80 	movabs $0x80416231b4,%rax
  8041600721:	00 00 00 
  8041600724:	44 8b 10             	mov    (%rax),%r10d
  8041600727:	41 0f af d2          	imul   %r10d,%edx
  804160072b:	44 8d 04 32          	lea    (%rdx,%rsi,1),%r8d
  804160072f:	41 c1 e0 03          	shl    $0x3,%r8d
  8041600733:	4c 89 ce             	mov    %r9,%rsi
  8041600736:	49 83 c1 08          	add    $0x8,%r9
  804160073a:	eb 25                	jmp    8041600761 <draw_char+0x5d>
    for (int w = 0; w < 8; w++) {
  804160073c:	83 c0 01             	add    $0x1,%eax
  804160073f:	83 f8 08             	cmp    $0x8,%eax
  8041600742:	74 11                	je     8041600755 <draw_char+0x51>
      if ((p[h] >> (w)) & 1) {
  8041600744:	0f be 16             	movsbl (%rsi),%edx
  8041600747:	0f a3 c2             	bt     %eax,%edx
  804160074a:	73 f0                	jae    804160073c <draw_char+0x38>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160074c:	42 8d 14 00          	lea    (%rax,%r8,1),%edx
  8041600750:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  8041600753:	eb e7                	jmp    804160073c <draw_char+0x38>
  8041600755:	48 83 c6 01          	add    $0x1,%rsi
  8041600759:	45 01 d0             	add    %r10d,%r8d
  for (int h = 0; h < 8; h++) {
  804160075c:	4c 39 ce             	cmp    %r9,%rsi
  804160075f:	74 07                	je     8041600768 <draw_char+0x64>
draw_char(uint32_t *buffer, uint32_t x, uint32_t y, uint32_t color, char charcode) {
  8041600761:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600766:	eb dc                	jmp    8041600744 <draw_char+0x40>
}
  8041600768:	5d                   	pop    %rbp
  8041600769:	c3                   	retq   

000000804160076a <cons_putc>:
  __asm __volatile("inb %w1,%0"
  804160076a:	ba fd 03 00 00       	mov    $0x3fd,%edx
  804160076f:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600770:	a8 20                	test   $0x20,%al
  8041600772:	75 29                	jne    804160079d <cons_putc+0x33>
  8041600774:	be 00 00 00 00       	mov    $0x0,%esi
  8041600779:	b9 84 00 00 00       	mov    $0x84,%ecx
  804160077e:	41 b9 fd 03 00 00    	mov    $0x3fd,%r9d
  8041600784:	89 ca                	mov    %ecx,%edx
  8041600786:	ec                   	in     (%dx),%al
  8041600787:	ec                   	in     (%dx),%al
  8041600788:	ec                   	in     (%dx),%al
  8041600789:	ec                   	in     (%dx),%al
       i++)
  804160078a:	83 c6 01             	add    $0x1,%esi
  804160078d:	44 89 ca             	mov    %r9d,%edx
  8041600790:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600791:	a8 20                	test   $0x20,%al
  8041600793:	75 08                	jne    804160079d <cons_putc+0x33>
  8041600795:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  804160079b:	7e e7                	jle    8041600784 <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  804160079d:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  80416007a0:	ba f8 03 00 00       	mov    $0x3f8,%edx
  80416007a5:	89 f8                	mov    %edi,%eax
  80416007a7:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416007a8:	ba 79 03 00 00       	mov    $0x379,%edx
  80416007ad:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  80416007ae:	84 c0                	test   %al,%al
  80416007b0:	78 29                	js     80416007db <cons_putc+0x71>
  80416007b2:	be 00 00 00 00       	mov    $0x0,%esi
  80416007b7:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416007bc:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  80416007c2:	89 ca                	mov    %ecx,%edx
  80416007c4:	ec                   	in     (%dx),%al
  80416007c5:	ec                   	in     (%dx),%al
  80416007c6:	ec                   	in     (%dx),%al
  80416007c7:	ec                   	in     (%dx),%al
  80416007c8:	83 c6 01             	add    $0x1,%esi
  80416007cb:	44 89 ca             	mov    %r9d,%edx
  80416007ce:	ec                   	in     (%dx),%al
  80416007cf:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416007d5:	7f 04                	jg     80416007db <cons_putc+0x71>
  80416007d7:	84 c0                	test   %al,%al
  80416007d9:	79 e7                	jns    80416007c2 <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416007db:	ba 78 03 00 00       	mov    $0x378,%edx
  80416007e0:	44 89 c0             	mov    %r8d,%eax
  80416007e3:	ee                   	out    %al,(%dx)
  80416007e4:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416007e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416007ee:	ee                   	out    %al,(%dx)
  80416007ef:	b8 08 00 00 00       	mov    $0x8,%eax
  80416007f4:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416007f5:	48 b8 bc 31 62 41 80 	movabs $0x80416231bc,%rax
  80416007fc:	00 00 00 
  80416007ff:	80 38 00             	cmpb   $0x0,(%rax)
  8041600802:	0f 84 86 00 00 00    	je     804160088e <cons_putc+0x124>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  8041600808:	55                   	push   %rbp
  8041600809:	48 89 e5             	mov    %rsp,%rbp
  804160080c:	41 54                	push   %r12
  804160080e:	53                   	push   %rbx
  if (!(c & ~0xFF))
  804160080f:	89 fa                	mov    %edi,%edx
  8041600811:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  8041600817:	89 f8                	mov    %edi,%eax
  8041600819:	80 cc 07             	or     $0x7,%ah
  804160081c:	85 d2                	test   %edx,%edx
  804160081e:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  8041600821:	40 0f b6 c7          	movzbl %dil,%eax
  8041600825:	83 f8 09             	cmp    $0x9,%eax
  8041600828:	0f 84 e5 00 00 00    	je     8041600913 <cons_putc+0x1a9>
  804160082e:	83 f8 09             	cmp    $0x9,%eax
  8041600831:	7e 5d                	jle    8041600890 <cons_putc+0x126>
  8041600833:	83 f8 0a             	cmp    $0xa,%eax
  8041600836:	0f 84 b9 00 00 00    	je     80416008f5 <cons_putc+0x18b>
  804160083c:	83 f8 0d             	cmp    $0xd,%eax
  804160083f:	0f 85 00 01 00 00    	jne    8041600945 <cons_putc+0x1db>
      crt_pos -= (crt_pos % crt_cols);
  8041600845:	48 be a8 31 62 41 80 	movabs $0x80416231a8,%rsi
  804160084c:	00 00 00 
  804160084f:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600852:	0f b7 c1             	movzwl %cx,%eax
  8041600855:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  804160085c:	00 00 00 
  804160085f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600864:	f7 33                	divl   (%rbx)
  8041600866:	29 d1                	sub    %edx,%ecx
  8041600868:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  804160086b:	48 b8 a8 31 62 41 80 	movabs $0x80416231a8,%rax
  8041600872:	00 00 00 
  8041600875:	0f b7 10             	movzwl (%rax),%edx
  8041600878:	48 b8 ac 31 62 41 80 	movabs $0x80416231ac,%rax
  804160087f:	00 00 00 
  8041600882:	3b 10                	cmp    (%rax),%edx
  8041600884:	0f 83 10 01 00 00    	jae    804160099a <cons_putc+0x230>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  804160088a:	5b                   	pop    %rbx
  804160088b:	41 5c                	pop    %r12
  804160088d:	5d                   	pop    %rbp
  804160088e:	f3 c3                	repz retq 
  switch (c & 0xff) {
  8041600890:	83 f8 08             	cmp    $0x8,%eax
  8041600893:	0f 85 ac 00 00 00    	jne    8041600945 <cons_putc+0x1db>
      if (crt_pos > 0) {
  8041600899:	66 a1 a8 31 62 41 80 	movabs 0x80416231a8,%ax
  80416008a0:	00 00 00 
  80416008a3:	66 85 c0             	test   %ax,%ax
  80416008a6:	74 c3                	je     804160086b <cons_putc+0x101>
        crt_pos--;
  80416008a8:	83 e8 01             	sub    $0x1,%eax
  80416008ab:	66 a3 a8 31 62 41 80 	movabs %ax,0x80416231a8
  80416008b2:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  80416008b5:	0f b7 c0             	movzwl %ax,%eax
  80416008b8:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  80416008bf:	00 00 00 
  80416008c2:	8b 1b                	mov    (%rbx),%ebx
  80416008c4:	ba 00 00 00 00       	mov    $0x0,%edx
  80416008c9:	f7 f3                	div    %ebx
  80416008cb:	89 d6                	mov    %edx,%esi
  80416008cd:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416008d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416008d8:	89 c2                	mov    %eax,%edx
  80416008da:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416008e1:	00 00 00 
  80416008e4:	48 b8 04 07 60 41 80 	movabs $0x8041600704,%rax
  80416008eb:	00 00 00 
  80416008ee:	ff d0                	callq  *%rax
  80416008f0:	e9 76 ff ff ff       	jmpq   804160086b <cons_putc+0x101>
      crt_pos += crt_cols;
  80416008f5:	48 b8 a8 31 62 41 80 	movabs $0x80416231a8,%rax
  80416008fc:	00 00 00 
  80416008ff:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  8041600906:	00 00 00 
  8041600909:	8b 13                	mov    (%rbx),%edx
  804160090b:	66 01 10             	add    %dx,(%rax)
  804160090e:	e9 32 ff ff ff       	jmpq   8041600845 <cons_putc+0xdb>
      cons_putc(' ');
  8041600913:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600918:	48 bb 6a 07 60 41 80 	movabs $0x804160076a,%rbx
  804160091f:	00 00 00 
  8041600922:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600924:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600929:	ff d3                	callq  *%rbx
      cons_putc(' ');
  804160092b:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600930:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600932:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600937:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600939:	bf 20 00 00 00       	mov    $0x20,%edi
  804160093e:	ff d3                	callq  *%rbx
  8041600940:	e9 26 ff ff ff       	jmpq   804160086b <cons_putc+0x101>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600945:	49 bc a8 31 62 41 80 	movabs $0x80416231a8,%r12
  804160094c:	00 00 00 
  804160094f:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600954:	0f b7 c3             	movzwl %bx,%eax
  8041600957:	48 be b0 31 62 41 80 	movabs $0x80416231b0,%rsi
  804160095e:	00 00 00 
  8041600961:	8b 36                	mov    (%rsi),%esi
  8041600963:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600968:	f7 f6                	div    %esi
  804160096a:	89 d6                	mov    %edx,%esi
  804160096c:	44 0f be c7          	movsbl %dil,%r8d
  8041600970:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600975:	89 c2                	mov    %eax,%edx
  8041600977:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  804160097e:	00 00 00 
  8041600981:	48 b8 04 07 60 41 80 	movabs $0x8041600704,%rax
  8041600988:	00 00 00 
  804160098b:	ff d0                	callq  *%rax
      crt_pos++;
  804160098d:	83 c3 01             	add    $0x1,%ebx
  8041600990:	66 41 89 1c 24       	mov    %bx,(%r12)
  8041600995:	e9 d1 fe ff ff       	jmpq   804160086b <cons_putc+0x101>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  804160099a:	48 bb b4 31 62 41 80 	movabs $0x80416231b4,%rbx
  80416009a1:	00 00 00 
  80416009a4:	8b 03                	mov    (%rbx),%eax
  80416009a6:	49 bc b8 31 62 41 80 	movabs $0x80416231b8,%r12
  80416009ad:	00 00 00 
  80416009b0:	41 8b 3c 24          	mov    (%r12),%edi
  80416009b4:	8d 57 f8             	lea    -0x8(%rdi),%edx
  80416009b7:	0f af d0             	imul   %eax,%edx
  80416009ba:	48 c1 e2 02          	shl    $0x2,%rdx
  80416009be:	c1 e0 03             	shl    $0x3,%eax
  80416009c1:	89 c0                	mov    %eax,%eax
  80416009c3:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416009ca:	00 00 00 
  80416009cd:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  80416009d1:	48 b8 21 51 60 41 80 	movabs $0x8041605121,%rax
  80416009d8:	00 00 00 
  80416009db:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  80416009dd:	41 8b 0c 24          	mov    (%r12),%ecx
  80416009e1:	8b 33                	mov    (%rbx),%esi
  80416009e3:	89 ca                	mov    %ecx,%edx
  80416009e5:	83 e2 f8             	and    $0xfffffff8,%edx
  80416009e8:	83 ea 08             	sub    $0x8,%edx
  80416009eb:	0f af d6             	imul   %esi,%edx
  80416009ee:	89 d0                	mov    %edx,%eax
  80416009f0:	0f af ce             	imul   %esi,%ecx
  80416009f3:	39 d1                	cmp    %edx,%ecx
  80416009f5:	76 1b                	jbe    8041600a12 <cons_putc+0x2a8>
      crt_buf[i] = 0;
  80416009f7:	48 be 00 00 c0 3e 80 	movabs $0x803ec00000,%rsi
  80416009fe:	00 00 00 
  8041600a01:	48 63 d0             	movslq %eax,%rdx
  8041600a04:	c7 04 96 00 00 00 00 	movl   $0x0,(%rsi,%rdx,4)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600a0b:	83 c0 01             	add    $0x1,%eax
  8041600a0e:	39 c8                	cmp    %ecx,%eax
  8041600a10:	75 ef                	jne    8041600a01 <cons_putc+0x297>
    crt_pos -= crt_cols;
  8041600a12:	48 b8 a8 31 62 41 80 	movabs $0x80416231a8,%rax
  8041600a19:	00 00 00 
  8041600a1c:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  8041600a23:	00 00 00 
  8041600a26:	8b 13                	mov    (%rbx),%edx
  8041600a28:	66 29 10             	sub    %dx,(%rax)
}
  8041600a2b:	e9 5a fe ff ff       	jmpq   804160088a <cons_putc+0x120>

0000008041600a30 <serial_intr>:
  if (serial_exists)
  8041600a30:	48 b8 aa 31 62 41 80 	movabs $0x80416231aa,%rax
  8041600a37:	00 00 00 
  8041600a3a:	80 38 00             	cmpb   $0x0,(%rax)
  8041600a3d:	75 02                	jne    8041600a41 <serial_intr+0x11>
}
  8041600a3f:	f3 c3                	repz retq 
serial_intr(void) {
  8041600a41:	55                   	push   %rbp
  8041600a42:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600a45:	48 bf 43 05 60 41 80 	movabs $0x8041600543,%rdi
  8041600a4c:	00 00 00 
  8041600a4f:	48 b8 63 05 60 41 80 	movabs $0x8041600563,%rax
  8041600a56:	00 00 00 
  8041600a59:	ff d0                	callq  *%rax
}
  8041600a5b:	5d                   	pop    %rbp
  8041600a5c:	eb e1                	jmp    8041600a3f <serial_intr+0xf>

0000008041600a5e <fb_init>:
fb_init(void) {
  8041600a5e:	55                   	push   %rbp
  8041600a5f:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600a62:	48 b8 00 70 61 41 80 	movabs $0x8041617000,%rax
  8041600a69:	00 00 00 
  8041600a6c:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600a6f:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600a72:	89 d0                	mov    %edx,%eax
  8041600a74:	a3 b8 31 62 41 80 00 	movabs %eax,0x80416231b8
  8041600a7b:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600a7d:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600a80:	a3 b4 31 62 41 80 00 	movabs %eax,0x80416231b4
  8041600a87:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600a89:	c1 e8 03             	shr    $0x3,%eax
  8041600a8c:	89 c6                	mov    %eax,%esi
  8041600a8e:	a3 b0 31 62 41 80 00 	movabs %eax,0x80416231b0
  8041600a95:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600a97:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600a9a:	0f af d0             	imul   %eax,%edx
  8041600a9d:	89 d0                	mov    %edx,%eax
  8041600a9f:	a3 ac 31 62 41 80 00 	movabs %eax,0x80416231ac
  8041600aa6:	00 00 
  crt_pos           = crt_cols;
  8041600aa8:	89 f0                	mov    %esi,%eax
  8041600aaa:	66 a3 a8 31 62 41 80 	movabs %ax,0x80416231a8
  8041600ab1:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600ab4:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600ab7:	be 00 00 00 00       	mov    $0x0,%esi
  8041600abc:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600ac3:	00 00 00 
  8041600ac6:	48 b8 d8 50 60 41 80 	movabs $0x80416050d8,%rax
  8041600acd:	00 00 00 
  8041600ad0:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600ad2:	48 b8 bc 31 62 41 80 	movabs $0x80416231bc,%rax
  8041600ad9:	00 00 00 
  8041600adc:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600adf:	5d                   	pop    %rbp
  8041600ae0:	c3                   	retq   

0000008041600ae1 <kbd_intr>:
kbd_intr(void) {
  8041600ae1:	55                   	push   %rbp
  8041600ae2:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600ae5:	48 bf b0 05 60 41 80 	movabs $0x80416005b0,%rdi
  8041600aec:	00 00 00 
  8041600aef:	48 b8 63 05 60 41 80 	movabs $0x8041600563,%rax
  8041600af6:	00 00 00 
  8041600af9:	ff d0                	callq  *%rax
}
  8041600afb:	5d                   	pop    %rbp
  8041600afc:	c3                   	retq   

0000008041600afd <cons_getc>:
cons_getc(void) {
  8041600afd:	55                   	push   %rbp
  8041600afe:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600b01:	48 b8 30 0a 60 41 80 	movabs $0x8041600a30,%rax
  8041600b08:	00 00 00 
  8041600b0b:	ff d0                	callq  *%rax
  kbd_intr();
  8041600b0d:	48 b8 e1 0a 60 41 80 	movabs $0x8041600ae1,%rax
  8041600b14:	00 00 00 
  8041600b17:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600b19:	48 ba a0 2f 62 41 80 	movabs $0x8041622fa0,%rdx
  8041600b20:	00 00 00 
  8041600b23:	8b 82 00 02 00 00    	mov    0x200(%rdx),%eax
  8041600b29:	3b 82 04 02 00 00    	cmp    0x204(%rdx),%eax
  8041600b2f:	74 35                	je     8041600b66 <cons_getc+0x69>
    c = cons.buf[cons.rpos++];
  8041600b31:	8d 50 01             	lea    0x1(%rax),%edx
  8041600b34:	48 b9 a0 2f 62 41 80 	movabs $0x8041622fa0,%rcx
  8041600b3b:	00 00 00 
  8041600b3e:	89 91 00 02 00 00    	mov    %edx,0x200(%rcx)
  8041600b44:	89 c0                	mov    %eax,%eax
  8041600b46:	0f b6 04 01          	movzbl (%rcx,%rax,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600b4a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
  8041600b50:	74 02                	je     8041600b54 <cons_getc+0x57>
}
  8041600b52:	5d                   	pop    %rbp
  8041600b53:	c3                   	retq   
      cons.rpos = 0;
  8041600b54:	48 be a0 31 62 41 80 	movabs $0x80416231a0,%rsi
  8041600b5b:	00 00 00 
  8041600b5e:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600b64:	eb ec                	jmp    8041600b52 <cons_getc+0x55>
  return 0;
  8041600b66:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600b6b:	eb e5                	jmp    8041600b52 <cons_getc+0x55>

0000008041600b6d <cons_init>:
  8041600b6d:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600b72:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600b77:	89 fa                	mov    %edi,%edx
  8041600b79:	ee                   	out    %al,(%dx)
  8041600b7a:	ba fb 03 00 00       	mov    $0x3fb,%edx
  8041600b7f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600b84:	ee                   	out    %al,(%dx)
  8041600b85:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600b8a:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600b8f:	89 f2                	mov    %esi,%edx
  8041600b91:	ee                   	out    %al,(%dx)
  8041600b92:	ba f9 03 00 00       	mov    $0x3f9,%edx
  8041600b97:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600b9c:	ee                   	out    %al,(%dx)
  8041600b9d:	ba fb 03 00 00       	mov    $0x3fb,%edx
  8041600ba2:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600ba7:	ee                   	out    %al,(%dx)
  8041600ba8:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600bad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600bb2:	ee                   	out    %al,(%dx)
  8041600bb3:	ba f9 03 00 00       	mov    $0x3f9,%edx
  8041600bb8:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600bbd:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600bbe:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600bc3:	ec                   	in     (%dx),%al
  8041600bc4:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600bc6:	3c ff                	cmp    $0xff,%al
  8041600bc8:	0f 95 c0             	setne  %al
  8041600bcb:	a2 aa 31 62 41 80 00 	movabs %al,0x80416231aa
  8041600bd2:	00 00 
  8041600bd4:	89 fa                	mov    %edi,%edx
  8041600bd6:	ec                   	in     (%dx),%al
  8041600bd7:	89 f2                	mov    %esi,%edx
  8041600bd9:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600bda:	80 f9 ff             	cmp    $0xff,%cl
  8041600bdd:	74 02                	je     8041600be1 <cons_init+0x74>
    cprintf("Serial port does not exist!\n");
}
  8041600bdf:	f3 c3                	repz retq 
cons_init(void) {
  8041600be1:	55                   	push   %rbp
  8041600be2:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600be5:	48 bf d2 54 60 41 80 	movabs $0x80416054d2,%rdi
  8041600bec:	00 00 00 
  8041600bef:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600bf4:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041600bfb:	00 00 00 
  8041600bfe:	ff d2                	callq  *%rdx
}
  8041600c00:	5d                   	pop    %rbp
  8041600c01:	eb dc                	jmp    8041600bdf <cons_init+0x72>

0000008041600c03 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600c03:	55                   	push   %rbp
  8041600c04:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600c07:	48 b8 6a 07 60 41 80 	movabs $0x804160076a,%rax
  8041600c0e:	00 00 00 
  8041600c11:	ff d0                	callq  *%rax
}
  8041600c13:	5d                   	pop    %rbp
  8041600c14:	c3                   	retq   

0000008041600c15 <getchar>:

int
getchar(void) {
  8041600c15:	55                   	push   %rbp
  8041600c16:	48 89 e5             	mov    %rsp,%rbp
  8041600c19:	53                   	push   %rbx
  8041600c1a:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600c1e:	48 bb fd 0a 60 41 80 	movabs $0x8041600afd,%rbx
  8041600c25:	00 00 00 
  8041600c28:	ff d3                	callq  *%rbx
  8041600c2a:	85 c0                	test   %eax,%eax
  8041600c2c:	74 fa                	je     8041600c28 <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600c2e:	48 83 c4 08          	add    $0x8,%rsp
  8041600c32:	5b                   	pop    %rbx
  8041600c33:	5d                   	pop    %rbp
  8041600c34:	c3                   	retq   

0000008041600c35 <iscons>:

int
iscons(int fdnum) {
  8041600c35:	55                   	push   %rbp
  8041600c36:	48 89 e5             	mov    %rsp,%rbp
  // used by readline
  return 1;
}
  8041600c39:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600c3e:	5d                   	pop    %rbp
  8041600c3f:	c3                   	retq   

0000008041600c40 <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600c40:	55                   	push   %rbp
  8041600c41:	48 89 e5             	mov    %rsp,%rbp
  8041600c44:	41 56                	push   %r14
  8041600c46:	41 55                	push   %r13
  8041600c48:	41 54                	push   %r12
  8041600c4a:	53                   	push   %rbx
  8041600c4b:	48 83 ec 20          	sub    $0x20,%rsp
  8041600c4f:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600c53:	83 fe 20             	cmp    $0x20,%esi
  8041600c56:	0f 87 55 09 00 00    	ja     80416015b1 <dwarf_read_abbrev_entry+0x971>
  8041600c5c:	44 89 c3             	mov    %r8d,%ebx
  8041600c5f:	41 89 cd             	mov    %ecx,%r13d
  8041600c62:	49 89 d4             	mov    %rdx,%r12
  8041600c65:	89 f6                	mov    %esi,%esi
  8041600c67:	48 b8 d8 57 60 41 80 	movabs $0x80416057d8,%rax
  8041600c6e:	00 00 00 
  8041600c71:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600c74:	48 85 d2             	test   %rdx,%rdx
  8041600c77:	74 75                	je     8041600cee <dwarf_read_abbrev_entry+0xae>
  8041600c79:	83 f9 07             	cmp    $0x7,%ecx
  8041600c7c:	76 70                	jbe    8041600cee <dwarf_read_abbrev_entry+0xae>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600c7e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600c83:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600c87:	4c 89 e7             	mov    %r12,%rdi
  8041600c8a:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600c91:	00 00 00 
  8041600c94:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600c96:	eb 56                	jmp    8041600cee <dwarf_read_abbrev_entry+0xae>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB 2: Your code here:
      Dwarf_Half length = get_unaligned(entry, Dwarf_Half);
  8041600c98:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600c9d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ca1:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ca5:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600cac:	00 00 00 
  8041600caf:	ff d0                	callq  *%rax
  8041600cb1:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Half);
  8041600cb5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600cb9:	48 83 c0 02          	add    $0x2,%rax
  8041600cbd:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600cc1:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600cc5:	0f b7 c3             	movzwl %bx,%eax
  8041600cc8:	89 45 d8             	mov    %eax,-0x28(%rbp)
          .mem = entry,
          .len = length,
      };
      if (buf) {
  8041600ccb:	4d 85 e4             	test   %r12,%r12
  8041600cce:	74 18                	je     8041600ce8 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600cd0:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600cd5:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600cd9:	4c 89 e7             	mov    %r12,%rdi
  8041600cdc:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600ce3:	00 00 00 
  8041600ce6:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(Dwarf_Half) + length;
  8041600ce8:	0f b7 db             	movzwl %bx,%ebx
  8041600ceb:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600cee:	89 d8                	mov    %ebx,%eax
  8041600cf0:	48 83 c4 20          	add    $0x20,%rsp
  8041600cf4:	5b                   	pop    %rbx
  8041600cf5:	41 5c                	pop    %r12
  8041600cf7:	41 5d                	pop    %r13
  8041600cf9:	41 5e                	pop    %r14
  8041600cfb:	5d                   	pop    %rbp
  8041600cfc:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600cfd:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600d02:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d06:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d0a:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600d11:	00 00 00 
  8041600d14:	ff d0                	callq  *%rax
  8041600d16:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600d19:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600d1d:	48 83 c0 04          	add    $0x4,%rax
  8041600d21:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600d25:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600d29:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600d2c:	4d 85 e4             	test   %r12,%r12
  8041600d2f:	74 18                	je     8041600d49 <dwarf_read_abbrev_entry+0x109>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600d31:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600d36:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d3a:	4c 89 e7             	mov    %r12,%rdi
  8041600d3d:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600d44:	00 00 00 
  8041600d47:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600d49:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600d4c:	eb a0                	jmp    8041600cee <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600d4e:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d53:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d57:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d5b:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600d62:	00 00 00 
  8041600d65:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600d67:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600d6c:	4d 85 e4             	test   %r12,%r12
  8041600d6f:	74 06                	je     8041600d77 <dwarf_read_abbrev_entry+0x137>
  8041600d71:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600d75:	77 0a                	ja     8041600d81 <dwarf_read_abbrev_entry+0x141>
      bytes = sizeof(Dwarf_Half);
  8041600d77:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600d7c:	e9 6d ff ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600d81:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d86:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d8a:	4c 89 e7             	mov    %r12,%rdi
  8041600d8d:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600d94:	00 00 00 
  8041600d97:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600d99:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600d9e:	e9 4b ff ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600da3:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600da8:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600dac:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600db0:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600db7:	00 00 00 
  8041600dba:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600dbc:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600dc1:	4d 85 e4             	test   %r12,%r12
  8041600dc4:	74 06                	je     8041600dcc <dwarf_read_abbrev_entry+0x18c>
  8041600dc6:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600dca:	77 0a                	ja     8041600dd6 <dwarf_read_abbrev_entry+0x196>
      bytes = sizeof(uint32_t);
  8041600dcc:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600dd1:	e9 18 ff ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  8041600dd6:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ddb:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600ddf:	4c 89 e7             	mov    %r12,%rdi
  8041600de2:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600de9:	00 00 00 
  8041600dec:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600dee:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600df3:	e9 f6 fe ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600df8:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600dfd:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e01:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e05:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600e0c:	00 00 00 
  8041600e0f:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600e11:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600e16:	4d 85 e4             	test   %r12,%r12
  8041600e19:	74 06                	je     8041600e21 <dwarf_read_abbrev_entry+0x1e1>
  8041600e1b:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600e1f:	77 0a                	ja     8041600e2b <dwarf_read_abbrev_entry+0x1eb>
      bytes = sizeof(uint64_t);
  8041600e21:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600e26:	e9 c3 fe ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041600e2b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e30:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e34:	4c 89 e7             	mov    %r12,%rdi
  8041600e37:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600e3e:	00 00 00 
  8041600e41:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600e43:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600e48:	e9 a1 fe ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      if (buf && bufsize >= sizeof(char *)) {
  8041600e4d:	48 85 d2             	test   %rdx,%rdx
  8041600e50:	74 1d                	je     8041600e6f <dwarf_read_abbrev_entry+0x22f>
  8041600e52:	83 f9 07             	cmp    $0x7,%ecx
  8041600e55:	76 18                	jbe    8041600e6f <dwarf_read_abbrev_entry+0x22f>
        memcpy(buf, &entry, sizeof(char *));
  8041600e57:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e5c:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600e60:	4c 89 e7             	mov    %r12,%rdi
  8041600e63:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600e6a:	00 00 00 
  8041600e6d:	ff d0                	callq  *%rax
      bytes = strlen(entry) + 1;
  8041600e6f:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600e73:	48 b8 dc 4e 60 41 80 	movabs $0x8041604edc,%rax
  8041600e7a:	00 00 00 
  8041600e7d:	ff d0                	callq  *%rax
  8041600e7f:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600e82:	e9 67 fe ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600e87:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600e8b:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600e8e:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600e93:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600e98:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600e9d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600ea0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600ea4:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600ea7:	89 f0                	mov    %esi,%eax
  8041600ea9:	83 e0 7f             	and    $0x7f,%eax
  8041600eac:	d3 e0                	shl    %cl,%eax
  8041600eae:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600eb0:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600eb3:	40 84 f6             	test   %sil,%sil
  8041600eb6:	78 e5                	js     8041600e9d <dwarf_read_abbrev_entry+0x25d>
      break;
  }

  *ret = result;

  return count;
  8041600eb8:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600ebb:	4d 01 e8             	add    %r13,%r8
  8041600ebe:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600ec2:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600ec6:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600ec9:	4d 85 e4             	test   %r12,%r12
  8041600ecc:	74 18                	je     8041600ee6 <dwarf_read_abbrev_entry+0x2a6>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600ece:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600ed3:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600ed7:	4c 89 e7             	mov    %r12,%rdi
  8041600eda:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600ee1:	00 00 00 
  8041600ee4:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600ee6:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600ee9:	e9 00 fe ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600eee:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600ef3:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ef7:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600efb:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600f02:	00 00 00 
  8041600f05:	ff d0                	callq  *%rax
  8041600f07:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041600f0b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600f0f:	48 83 c0 01          	add    $0x1,%rax
  8041600f13:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600f17:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600f1b:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600f1e:	4d 85 e4             	test   %r12,%r12
  8041600f21:	74 18                	je     8041600f3b <dwarf_read_abbrev_entry+0x2fb>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600f23:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600f28:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f2c:	4c 89 e7             	mov    %r12,%rdi
  8041600f2f:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600f36:	00 00 00 
  8041600f39:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041600f3b:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041600f3e:	e9 ab fd ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041600f43:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f48:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f4c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f50:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600f57:	00 00 00 
  8041600f5a:	ff d0                	callq  *%rax
  8041600f5c:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041600f60:	4d 85 e4             	test   %r12,%r12
  8041600f63:	0f 84 52 06 00 00    	je     80416015bb <dwarf_read_abbrev_entry+0x97b>
  8041600f69:	45 85 ed             	test   %r13d,%r13d
  8041600f6c:	0f 84 49 06 00 00    	je     80416015bb <dwarf_read_abbrev_entry+0x97b>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f72:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041600f76:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f7b:	e9 6e fd ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600f80:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f85:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f89:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f8d:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041600f94:	00 00 00 
  8041600f97:	ff d0                	callq  *%rax
  8041600f99:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  8041600f9d:	4d 85 e4             	test   %r12,%r12
  8041600fa0:	0f 84 1f 06 00 00    	je     80416015c5 <dwarf_read_abbrev_entry+0x985>
  8041600fa6:	45 85 ed             	test   %r13d,%r13d
  8041600fa9:	0f 84 16 06 00 00    	je     80416015c5 <dwarf_read_abbrev_entry+0x985>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600faf:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  8041600fb1:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  8041600fb6:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  8041600fbb:	e9 2e fd ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      int count = dwarf_read_leb128(entry, &data);
  8041600fc0:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600fc4:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600fc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041600fcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600fd1:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  8041600fd6:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600fd9:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  8041600fdd:	89 f0                	mov    %esi,%eax
  8041600fdf:	83 e0 7f             	and    $0x7f,%eax
  8041600fe2:	d3 e0                	shl    %cl,%eax
  8041600fe4:	09 c7                	or     %eax,%edi
    shift += 7;
  8041600fe6:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041600fe9:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  8041600fec:	40 84 f6             	test   %sil,%sil
  8041600fef:	78 e5                	js     8041600fd6 <dwarf_read_abbrev_entry+0x396>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  8041600ff1:	83 f9 1f             	cmp    $0x1f,%ecx
  8041600ff4:	7f 0f                	jg     8041601005 <dwarf_read_abbrev_entry+0x3c5>
  8041600ff6:	40 f6 c6 40          	test   $0x40,%sil
  8041600ffa:	74 09                	je     8041601005 <dwarf_read_abbrev_entry+0x3c5>
    result |= (-1U << shift);
  8041600ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041601001:	d3 e0                	shl    %cl,%eax
  8041601003:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  8041601005:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601008:	49 01 c0             	add    %rax,%r8
  804160100b:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  804160100f:	4d 85 e4             	test   %r12,%r12
  8041601012:	0f 84 d6 fc ff ff    	je     8041600cee <dwarf_read_abbrev_entry+0xae>
  8041601018:	41 83 fd 03          	cmp    $0x3,%r13d
  804160101c:	0f 86 cc fc ff ff    	jbe    8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (int *)buf);
  8041601022:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601025:	ba 04 00 00 00       	mov    $0x4,%edx
  804160102a:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160102e:	4c 89 e7             	mov    %r12,%rdi
  8041601031:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601038:	00 00 00 
  804160103b:	ff d0                	callq  *%rax
  804160103d:	e9 ac fc ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  8041601042:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601046:	ba 04 00 00 00       	mov    $0x4,%edx
  804160104b:	4c 89 f6             	mov    %r14,%rsi
  804160104e:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601052:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601059:	00 00 00 
  804160105c:	ff d0                	callq  *%rax
  804160105e:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601061:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601063:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601068:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160106b:	77 3b                	ja     80416010a8 <dwarf_read_abbrev_entry+0x468>
      entry += count;
  804160106d:	48 63 c3             	movslq %ebx,%rax
  8041601070:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601074:	4d 85 e4             	test   %r12,%r12
  8041601077:	0f 84 71 fc ff ff    	je     8041600cee <dwarf_read_abbrev_entry+0xae>
  804160107d:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601081:	0f 86 67 fc ff ff    	jbe    8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  8041601087:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  804160108b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601090:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601094:	4c 89 e7             	mov    %r12,%rdi
  8041601097:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160109e:	00 00 00 
  80416010a1:	ff d0                	callq  *%rax
  80416010a3:	e9 46 fc ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
    if (initial_len == DW_EXT_DWARF64) {
  80416010a8:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416010ab:	74 27                	je     80416010d4 <dwarf_read_abbrev_entry+0x494>
      cprintf("Unknown DWARF extension\n");
  80416010ad:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  80416010b4:	00 00 00 
  80416010b7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416010bc:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416010c3:	00 00 00 
  80416010c6:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416010c8:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416010cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416010d2:	eb 99                	jmp    804160106d <dwarf_read_abbrev_entry+0x42d>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416010d4:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416010d8:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010dd:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416010e1:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416010e8:	00 00 00 
  80416010eb:	ff d0                	callq  *%rax
  80416010ed:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416010f1:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416010f6:	e9 72 ff ff ff       	jmpq   804160106d <dwarf_read_abbrev_entry+0x42d>
      int count         = dwarf_read_uleb128(entry, &data);
  80416010fb:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416010ff:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601102:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601107:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160110c:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601111:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601114:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601118:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160111b:	89 f0                	mov    %esi,%eax
  804160111d:	83 e0 7f             	and    $0x7f,%eax
  8041601120:	d3 e0                	shl    %cl,%eax
  8041601122:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601124:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601127:	40 84 f6             	test   %sil,%sil
  804160112a:	78 e5                	js     8041601111 <dwarf_read_abbrev_entry+0x4d1>
  return count;
  804160112c:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  804160112f:	49 01 c0             	add    %rax,%r8
  8041601132:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  8041601136:	4d 85 e4             	test   %r12,%r12
  8041601139:	0f 84 af fb ff ff    	je     8041600cee <dwarf_read_abbrev_entry+0xae>
  804160113f:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601143:	0f 86 a5 fb ff ff    	jbe    8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  8041601149:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160114c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601151:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601155:	4c 89 e7             	mov    %r12,%rdi
  8041601158:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160115f:	00 00 00 
  8041601162:	ff d0                	callq  *%rax
  8041601164:	e9 85 fb ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  8041601169:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160116d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601172:	4c 89 f6             	mov    %r14,%rsi
  8041601175:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601179:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601180:	00 00 00 
  8041601183:	ff d0                	callq  *%rax
  8041601185:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601188:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160118a:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160118f:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601192:	77 3b                	ja     80416011cf <dwarf_read_abbrev_entry+0x58f>
      entry += count;
  8041601194:	48 63 c3             	movslq %ebx,%rax
  8041601197:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  804160119b:	4d 85 e4             	test   %r12,%r12
  804160119e:	0f 84 4a fb ff ff    	je     8041600cee <dwarf_read_abbrev_entry+0xae>
  80416011a4:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011a8:	0f 86 40 fb ff ff    	jbe    8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  80416011ae:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416011b2:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011b7:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011bb:	4c 89 e7             	mov    %r12,%rdi
  80416011be:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416011c5:	00 00 00 
  80416011c8:	ff d0                	callq  *%rax
  80416011ca:	e9 1f fb ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
    if (initial_len == DW_EXT_DWARF64) {
  80416011cf:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416011d2:	74 27                	je     80416011fb <dwarf_read_abbrev_entry+0x5bb>
      cprintf("Unknown DWARF extension\n");
  80416011d4:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  80416011db:	00 00 00 
  80416011de:	b8 00 00 00 00       	mov    $0x0,%eax
  80416011e3:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416011ea:	00 00 00 
  80416011ed:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416011ef:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416011f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416011f9:	eb 99                	jmp    8041601194 <dwarf_read_abbrev_entry+0x554>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416011fb:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416011ff:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601204:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601208:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160120f:	00 00 00 
  8041601212:	ff d0                	callq  *%rax
  8041601214:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  8041601218:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160121d:	e9 72 ff ff ff       	jmpq   8041601194 <dwarf_read_abbrev_entry+0x554>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601222:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601227:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160122b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160122f:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601236:	00 00 00 
  8041601239:	ff d0                	callq  *%rax
  804160123b:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160123f:	4d 85 e4             	test   %r12,%r12
  8041601242:	0f 84 87 03 00 00    	je     80416015cf <dwarf_read_abbrev_entry+0x98f>
  8041601248:	45 85 ed             	test   %r13d,%r13d
  804160124b:	0f 84 7e 03 00 00    	je     80416015cf <dwarf_read_abbrev_entry+0x98f>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601251:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601255:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  804160125a:	e9 8f fa ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  804160125f:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601264:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601268:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160126c:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601273:	00 00 00 
  8041601276:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041601278:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  804160127d:	4d 85 e4             	test   %r12,%r12
  8041601280:	74 06                	je     8041601288 <dwarf_read_abbrev_entry+0x648>
  8041601282:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601286:	77 0a                	ja     8041601292 <dwarf_read_abbrev_entry+0x652>
      bytes = sizeof(Dwarf_Half);
  8041601288:	bb 02 00 00 00       	mov    $0x2,%ebx
  804160128d:	e9 5c fa ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041601292:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601297:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160129b:	4c 89 e7             	mov    %r12,%rdi
  804160129e:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416012a5:	00 00 00 
  80416012a8:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  80416012aa:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  80416012af:	e9 3a fa ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416012b4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012b9:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416012bd:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012c1:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416012c8:	00 00 00 
  80416012cb:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416012cd:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416012d2:	4d 85 e4             	test   %r12,%r12
  80416012d5:	74 06                	je     80416012dd <dwarf_read_abbrev_entry+0x69d>
  80416012d7:	41 83 fd 03          	cmp    $0x3,%r13d
  80416012db:	77 0a                	ja     80416012e7 <dwarf_read_abbrev_entry+0x6a7>
      bytes = sizeof(uint32_t);
  80416012dd:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416012e2:	e9 07 fa ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  80416012e7:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012ec:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012f0:	4c 89 e7             	mov    %r12,%rdi
  80416012f3:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416012fa:	00 00 00 
  80416012fd:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  80416012ff:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041601304:	e9 e5 f9 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601309:	ba 08 00 00 00       	mov    $0x8,%edx
  804160130e:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601312:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601316:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160131d:	00 00 00 
  8041601320:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601322:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601327:	4d 85 e4             	test   %r12,%r12
  804160132a:	74 06                	je     8041601332 <dwarf_read_abbrev_entry+0x6f2>
  804160132c:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601330:	77 0a                	ja     804160133c <dwarf_read_abbrev_entry+0x6fc>
      bytes = sizeof(uint64_t);
  8041601332:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041601337:	e9 b2 f9 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  804160133c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601341:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601345:	4c 89 e7             	mov    %r12,%rdi
  8041601348:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160134f:	00 00 00 
  8041601352:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601354:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041601359:	e9 90 f9 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &data);
  804160135e:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601362:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601365:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160136a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160136f:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601374:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601377:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160137b:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160137e:	89 f0                	mov    %esi,%eax
  8041601380:	83 e0 7f             	and    $0x7f,%eax
  8041601383:	d3 e0                	shl    %cl,%eax
  8041601385:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601387:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160138a:	40 84 f6             	test   %sil,%sil
  804160138d:	78 e5                	js     8041601374 <dwarf_read_abbrev_entry+0x734>
  return count;
  804160138f:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601392:	49 01 c0             	add    %rax,%r8
  8041601395:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  8041601399:	4d 85 e4             	test   %r12,%r12
  804160139c:	0f 84 4c f9 ff ff    	je     8041600cee <dwarf_read_abbrev_entry+0xae>
  80416013a2:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013a6:	0f 86 42 f9 ff ff    	jbe    8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  80416013ac:	89 7d d0             	mov    %edi,-0x30(%rbp)
  80416013af:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013b4:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013b8:	4c 89 e7             	mov    %r12,%rdi
  80416013bb:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416013c2:	00 00 00 
  80416013c5:	ff d0                	callq  *%rax
  80416013c7:	e9 22 f9 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &form);
  80416013cc:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416013d0:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416013d3:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416013d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416013de:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416013e3:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416013e7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416013eb:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416013ef:	44 89 c0             	mov    %r8d,%eax
  80416013f2:	83 e0 7f             	and    $0x7f,%eax
  80416013f5:	d3 e0                	shl    %cl,%eax
  80416013f7:	09 c6                	or     %eax,%esi
    shift += 7;
  80416013f9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416013fc:	45 84 c0             	test   %r8b,%r8b
  80416013ff:	78 e2                	js     80416013e3 <dwarf_read_abbrev_entry+0x7a3>
  return count;
  8041601401:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  8041601404:	48 01 c7             	add    %rax,%rdi
  8041601407:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  804160140b:	41 89 d8             	mov    %ebx,%r8d
  804160140e:	44 89 e9             	mov    %r13d,%ecx
  8041601411:	4c 89 e2             	mov    %r12,%rdx
  8041601414:	48 b8 40 0c 60 41 80 	movabs $0x8041600c40,%rax
  804160141b:	00 00 00 
  804160141e:	ff d0                	callq  *%rax
      bytes    = count + read;
  8041601420:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601424:	e9 c5 f8 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  8041601429:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160142d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601432:	4c 89 f6             	mov    %r14,%rsi
  8041601435:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601439:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601440:	00 00 00 
  8041601443:	ff d0                	callq  *%rax
  8041601445:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601448:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160144a:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160144f:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601452:	77 3b                	ja     804160148f <dwarf_read_abbrev_entry+0x84f>
      entry += count;
  8041601454:	48 63 c3             	movslq %ebx,%rax
  8041601457:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  804160145b:	4d 85 e4             	test   %r12,%r12
  804160145e:	0f 84 8a f8 ff ff    	je     8041600cee <dwarf_read_abbrev_entry+0xae>
  8041601464:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601468:	0f 86 80 f8 ff ff    	jbe    8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  804160146e:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601472:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601477:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160147b:	4c 89 e7             	mov    %r12,%rdi
  804160147e:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601485:	00 00 00 
  8041601488:	ff d0                	callq  *%rax
  804160148a:	e9 5f f8 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
    if (initial_len == DW_EXT_DWARF64) {
  804160148f:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601492:	74 27                	je     80416014bb <dwarf_read_abbrev_entry+0x87b>
      cprintf("Unknown DWARF extension\n");
  8041601494:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  804160149b:	00 00 00 
  804160149e:	b8 00 00 00 00       	mov    $0x0,%eax
  80416014a3:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416014aa:	00 00 00 
  80416014ad:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416014af:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416014b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416014b9:	eb 99                	jmp    8041601454 <dwarf_read_abbrev_entry+0x814>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416014bb:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416014bf:	ba 08 00 00 00       	mov    $0x8,%edx
  80416014c4:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416014c8:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416014cf:	00 00 00 
  80416014d2:	ff d0                	callq  *%rax
  80416014d4:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416014d8:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416014dd:	e9 72 ff ff ff       	jmpq   8041601454 <dwarf_read_abbrev_entry+0x814>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416014e2:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416014e6:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416014e9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416014ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014f4:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416014f9:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416014fc:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601500:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041601504:	89 f8                	mov    %edi,%eax
  8041601506:	83 e0 7f             	and    $0x7f,%eax
  8041601509:	d3 e0                	shl    %cl,%eax
  804160150b:	09 c3                	or     %eax,%ebx
    shift += 7;
  804160150d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601510:	40 84 ff             	test   %dil,%dil
  8041601513:	78 e4                	js     80416014f9 <dwarf_read_abbrev_entry+0x8b9>
  return count;
  8041601515:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  8041601518:	4c 01 f6             	add    %r14,%rsi
  804160151b:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  804160151f:	4d 85 e4             	test   %r12,%r12
  8041601522:	74 1a                	je     804160153e <dwarf_read_abbrev_entry+0x8fe>
        memcpy(buf, entry, MIN(length, bufsize));
  8041601524:	41 39 dd             	cmp    %ebx,%r13d
  8041601527:	44 89 ea             	mov    %r13d,%edx
  804160152a:	0f 47 d3             	cmova  %ebx,%edx
  804160152d:	89 d2                	mov    %edx,%edx
  804160152f:	4c 89 e7             	mov    %r12,%rdi
  8041601532:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601539:	00 00 00 
  804160153c:	ff d0                	callq  *%rax
      bytes = count + length;
  804160153e:	44 01 f3             	add    %r14d,%ebx
    } break;
  8041601541:	e9 a8 f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      if (buf && sizeof(buf) >= sizeof(bool)) {
  8041601546:	48 85 d2             	test   %rdx,%rdx
  8041601549:	0f 84 8a 00 00 00    	je     80416015d9 <dwarf_read_abbrev_entry+0x999>
        put_unaligned(true, (bool *)buf);
  804160154f:	c6 02 01             	movb   $0x1,(%rdx)
      bytes = 0;
  8041601552:	bb 00 00 00 00       	mov    $0x0,%ebx
        put_unaligned(true, (bool *)buf);
  8041601557:	e9 92 f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  804160155c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601561:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601565:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601569:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601570:	00 00 00 
  8041601573:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601575:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  804160157a:	4d 85 e4             	test   %r12,%r12
  804160157d:	74 06                	je     8041601585 <dwarf_read_abbrev_entry+0x945>
  804160157f:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601583:	77 0a                	ja     804160158f <dwarf_read_abbrev_entry+0x94f>
      bytes = sizeof(uint64_t);
  8041601585:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  804160158a:	e9 5f f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  804160158f:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601594:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601598:	4c 89 e7             	mov    %r12,%rdi
  804160159b:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416015a2:	00 00 00 
  80416015a5:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  80416015a7:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  80416015ac:	e9 3d f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
  int bytes = 0;
  80416015b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416015b6:	e9 33 f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015bb:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015c0:	e9 29 f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015c5:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015ca:	e9 1f f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015cf:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015d4:	e9 15 f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>
      bytes = 0;
  80416015d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416015de:	e9 0b f7 ff ff       	jmpq   8041600cee <dwarf_read_abbrev_entry+0xae>

00000080416015e3 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416015e3:	55                   	push   %rbp
  80416015e4:	48 89 e5             	mov    %rsp,%rbp
  80416015e7:	41 57                	push   %r15
  80416015e9:	41 56                	push   %r14
  80416015eb:	41 55                	push   %r13
  80416015ed:	41 54                	push   %r12
  80416015ef:	53                   	push   %rbx
  80416015f0:	48 83 ec 48          	sub    $0x48,%rsp
  80416015f4:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  80416015f8:	48 89 f3             	mov    %rsi,%rbx
  80416015fb:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  80416015ff:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  8041601603:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601607:	49 bc 9a 51 60 41 80 	movabs $0x804160519a,%r12
  804160160e:	00 00 00 
  8041601611:	e9 65 01 00 00       	jmpq   804160177b <info_by_address+0x198>
    if (initial_len == DW_EXT_DWARF64) {
  8041601616:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601619:	74 3b                	je     8041601656 <info_by_address+0x73>
      cprintf("Unknown DWARF extension\n");
  804160161b:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  8041601622:	00 00 00 
  8041601625:	b8 00 00 00 00       	mov    $0x0,%eax
  804160162a:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041601631:	00 00 00 
  8041601634:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  8041601636:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160163a:	48 8b 58 20          	mov    0x20(%rax),%rbx
  804160163e:	48 89 5d b8          	mov    %rbx,-0x48(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601642:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  8041601646:	0f 82 bc 04 00 00    	jb     8041601b08 <info_by_address+0x525>
  return 0;
  804160164c:	b8 00 00 00 00       	mov    $0x0,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
  8041601651:	e9 0a 01 00 00       	jmpq   8041601760 <info_by_address+0x17d>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601656:	49 8d 76 20          	lea    0x20(%r14),%rsi
  804160165a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160165f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601663:	41 ff d4             	callq  *%r12
  8041601666:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  804160166a:	ba 0c 00 00 00       	mov    $0xc,%edx
  804160166f:	e9 38 01 00 00       	jmpq   80416017ac <info_by_address+0x1c9>
    assert(version == 2);
  8041601674:	48 b9 9e 57 60 41 80 	movabs $0x804160579e,%rcx
  804160167b:	00 00 00 
  804160167e:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601685:	00 00 00 
  8041601688:	be 20 00 00 00       	mov    $0x20,%esi
  804160168d:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601694:	00 00 00 
  8041601697:	b8 00 00 00 00       	mov    $0x0,%eax
  804160169c:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416016a3:	00 00 00 
  80416016a6:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416016a9:	48 b9 5b 57 60 41 80 	movabs $0x804160575b,%rcx
  80416016b0:	00 00 00 
  80416016b3:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  80416016ba:	00 00 00 
  80416016bd:	be 24 00 00 00       	mov    $0x24,%esi
  80416016c2:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  80416016c9:	00 00 00 
  80416016cc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416016d1:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416016d8:	00 00 00 
  80416016db:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  80416016de:	48 b9 6d 57 60 41 80 	movabs $0x804160576d,%rcx
  80416016e5:	00 00 00 
  80416016e8:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  80416016ef:	00 00 00 
  80416016f2:	be 26 00 00 00       	mov    $0x26,%esi
  80416016f7:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  80416016fe:	00 00 00 
  8041601701:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601706:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  804160170d:	00 00 00 
  8041601710:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601713:	4d 39 fd             	cmp    %r15,%r13
  8041601716:	76 57                	jbe    804160176f <info_by_address+0x18c>
      addr = (void *)get_unaligned(set, uintptr_t);
  8041601718:	ba 08 00 00 00       	mov    $0x8,%edx
  804160171d:	4c 89 fe             	mov    %r15,%rsi
  8041601720:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601724:	41 ff d4             	callq  *%r12
  8041601727:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      set += address_size;
  804160172b:	49 8d 77 08          	lea    0x8(%r15),%rsi
      size = get_unaligned(set, uint32_t);
  804160172f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601734:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601738:	41 ff d4             	callq  *%r12
  804160173b:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160173e:	49 83 c7 10          	add    $0x10,%r15
      if ((uintptr_t)addr <= p &&
  8041601742:	4c 39 f3             	cmp    %r14,%rbx
  8041601745:	72 cc                	jb     8041601713 <info_by_address+0x130>
      size = get_unaligned(set, uint32_t);
  8041601747:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  8041601749:	49 01 c6             	add    %rax,%r14
      if ((uintptr_t)addr <= p &&
  804160174c:	4c 39 f3             	cmp    %r14,%rbx
  804160174f:	77 c2                	ja     8041601713 <info_by_address+0x130>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601751:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041601755:	8b 5d a8             	mov    -0x58(%rbp),%ebx
  8041601758:	48 89 18             	mov    %rbx,(%rax)
        return 0;
  804160175b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601760:	48 83 c4 48          	add    $0x48,%rsp
  8041601764:	5b                   	pop    %rbx
  8041601765:	41 5c                	pop    %r12
  8041601767:	41 5d                	pop    %r13
  8041601769:	41 5e                	pop    %r14
  804160176b:	41 5f                	pop    %r15
  804160176d:	5d                   	pop    %rbp
  804160176e:	c3                   	retq   
      set += address_size;
  804160176f:	4d 89 fe             	mov    %r15,%r14
    assert(set == set_end);
  8041601772:	4d 39 fd             	cmp    %r15,%r13
  8041601775:	0f 85 e1 00 00 00    	jne    804160185c <info_by_address+0x279>
  while ((unsigned char *)set < addrs->aranges_end) {
  804160177b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160177f:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  8041601783:	0f 83 ad fe ff ff    	jae    8041601636 <info_by_address+0x53>
  initial_len = get_unaligned(addr, uint32_t);
  8041601789:	ba 04 00 00 00       	mov    $0x4,%edx
  804160178e:	4c 89 f6             	mov    %r14,%rsi
  8041601791:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601795:	41 ff d4             	callq  *%r12
  8041601798:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  804160179b:	41 89 c5             	mov    %eax,%r13d
  count       = 4;
  804160179e:	ba 04 00 00 00       	mov    $0x4,%edx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416017a3:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416017a6:	0f 87 6a fe ff ff    	ja     8041601616 <info_by_address+0x33>
      set += count;
  80416017ac:	48 63 c2             	movslq %edx,%rax
  80416017af:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416017b3:	4d 8d 3c 06          	lea    (%r14,%rax,1),%r15
    const void *set_end = set + len;
  80416017b7:	4d 01 fd             	add    %r15,%r13
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  80416017ba:	ba 02 00 00 00       	mov    $0x2,%edx
  80416017bf:	4c 89 fe             	mov    %r15,%rsi
  80416017c2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017c6:	41 ff d4             	callq  *%r12
    set += sizeof(Dwarf_Half);
  80416017c9:	49 83 c7 02          	add    $0x2,%r15
    assert(version == 2);
  80416017cd:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  80416017d2:	0f 85 9c fe ff ff    	jne    8041601674 <info_by_address+0x91>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  80416017d8:	ba 04 00 00 00       	mov    $0x4,%edx
  80416017dd:	4c 89 fe             	mov    %r15,%rsi
  80416017e0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017e4:	41 ff d4             	callq  *%r12
  80416017e7:	8b 45 c8             	mov    -0x38(%rbp),%eax
  80416017ea:	89 45 a8             	mov    %eax,-0x58(%rbp)
    set += count;
  80416017ed:	4c 03 7d b8          	add    -0x48(%rbp),%r15
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  80416017f1:	49 8d 47 01          	lea    0x1(%r15),%rax
  80416017f5:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416017f9:	ba 01 00 00 00       	mov    $0x1,%edx
  80416017fe:	4c 89 fe             	mov    %r15,%rsi
  8041601801:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601805:	41 ff d4             	callq  *%r12
    assert(address_size == 8);
  8041601808:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160180c:	0f 85 97 fe ff ff    	jne    80416016a9 <info_by_address+0xc6>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  8041601812:	49 83 c7 02          	add    $0x2,%r15
  8041601816:	ba 01 00 00 00       	mov    $0x1,%edx
  804160181b:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160181f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601823:	41 ff d4             	callq  *%r12
    assert(segment_size == 0);
  8041601826:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  804160182a:	0f 85 ae fe ff ff    	jne    80416016de <info_by_address+0xfb>
    uint32_t remainder  = (set - header) % entry_size;
  8041601830:	4c 89 f8             	mov    %r15,%rax
  8041601833:	4c 29 f0             	sub    %r14,%rax
  8041601836:	48 99                	cqto   
  8041601838:	48 c1 ea 3c          	shr    $0x3c,%rdx
  804160183c:	48 01 d0             	add    %rdx,%rax
  804160183f:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  8041601842:	48 29 d0             	sub    %rdx,%rax
  8041601845:	0f 84 cd fe ff ff    	je     8041601718 <info_by_address+0x135>
      set += 2 * address_size - remainder;
  804160184b:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601850:	89 d7                	mov    %edx,%edi
  8041601852:	29 c7                	sub    %eax,%edi
  8041601854:	49 01 ff             	add    %rdi,%r15
  8041601857:	e9 bc fe ff ff       	jmpq   8041601718 <info_by_address+0x135>
    assert(set == set_end);
  804160185c:	48 b9 7f 57 60 41 80 	movabs $0x804160577f,%rcx
  8041601863:	00 00 00 
  8041601866:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  804160186d:	00 00 00 
  8041601870:	be 3a 00 00 00       	mov    $0x3a,%esi
  8041601875:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  804160187c:	00 00 00 
  804160187f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601884:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  804160188b:	00 00 00 
  804160188e:	41 ff d0             	callq  *%r8
    if (initial_len == DW_EXT_DWARF64) {
  8041601891:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601894:	74 25                	je     80416018bb <info_by_address+0x2d8>
      cprintf("Unknown DWARF extension\n");
  8041601896:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  804160189d:	00 00 00 
  80416018a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018a5:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416018ac:	00 00 00 
  80416018af:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  80416018b1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416018b6:	e9 a5 fe ff ff       	jmpq   8041601760 <info_by_address+0x17d>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416018bb:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018bf:	48 8d 70 20          	lea    0x20(%rax),%rsi
  80416018c3:	ba 08 00 00 00       	mov    $0x8,%edx
  80416018c8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018cc:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416018d3:	00 00 00 
  80416018d6:	ff d0                	callq  *%rax
  80416018d8:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
      count = 12;
  80416018dc:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  80416018e2:	e9 4e 02 00 00       	jmpq   8041601b35 <info_by_address+0x552>
    assert(version == 4 || version == 2);
  80416018e7:	48 b9 8e 57 60 41 80 	movabs $0x804160578e,%rcx
  80416018ee:	00 00 00 
  80416018f1:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  80416018f8:	00 00 00 
  80416018fb:	be 40 01 00 00       	mov    $0x140,%esi
  8041601900:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601907:	00 00 00 
  804160190a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160190f:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041601916:	00 00 00 
  8041601919:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  804160191c:	48 b9 5b 57 60 41 80 	movabs $0x804160575b,%rcx
  8041601923:	00 00 00 
  8041601926:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  804160192d:	00 00 00 
  8041601930:	be 44 01 00 00       	mov    $0x144,%esi
  8041601935:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  804160193c:	00 00 00 
  804160193f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601944:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  804160194b:	00 00 00 
  804160194e:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601951:	48 b9 ab 57 60 41 80 	movabs $0x80416057ab,%rcx
  8041601958:	00 00 00 
  804160195b:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601962:	00 00 00 
  8041601965:	be 49 01 00 00       	mov    $0x149,%esi
  804160196a:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601971:	00 00 00 
  8041601974:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601979:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041601980:	00 00 00 
  8041601983:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601986:	48 b9 e0 58 60 41 80 	movabs $0x80416058e0,%rcx
  804160198d:	00 00 00 
  8041601990:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601997:	00 00 00 
  804160199a:	be 51 01 00 00       	mov    $0x151,%esi
  804160199f:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  80416019a6:	00 00 00 
  80416019a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416019ae:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416019b5:	00 00 00 
  80416019b8:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  80416019bb:	48 b9 bc 57 60 41 80 	movabs $0x80416057bc,%rcx
  80416019c2:	00 00 00 
  80416019c5:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  80416019cc:	00 00 00 
  80416019cf:	be 55 01 00 00       	mov    $0x155,%esi
  80416019d4:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  80416019db:	00 00 00 
  80416019de:	b8 00 00 00 00       	mov    $0x0,%eax
  80416019e3:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416019ea:	00 00 00 
  80416019ed:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  80416019f0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416019f6:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416019fb:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  80416019ff:	44 89 ee             	mov    %r13d,%esi
  8041601a02:	4c 89 f7             	mov    %r14,%rdi
  8041601a05:	41 ff d7             	callq  *%r15
  8041601a08:	eb 2a                	jmp    8041601a34 <info_by_address+0x451>
        count = dwarf_read_abbrev_entry(
  8041601a0a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601a10:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601a15:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601a19:	44 89 ee             	mov    %r13d,%esi
  8041601a1c:	4c 89 f7             	mov    %r14,%rdi
  8041601a1f:	41 ff d7             	callq  *%r15
        if (form != DW_FORM_addr) {
  8041601a22:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601a26:	0f 84 96 02 00 00    	je     8041601cc2 <info_by_address+0x6df>
          high_pc += low_pc;
  8041601a2c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601a30:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
      entry += count;
  8041601a34:	48 98                	cltq   
  8041601a36:	49 01 c6             	add    %rax,%r14
    } while (name != 0 || form != 0);
  8041601a39:	45 09 ec             	or     %r13d,%r12d
  8041601a3c:	0f 84 9c 00 00 00    	je     8041601ade <info_by_address+0x4fb>
    assert(table_abbrev_code == abbrev_code);
  8041601a42:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601a45:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601a4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a4f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601a55:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601a58:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601a5c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601a5f:	89 f0                	mov    %esi,%eax
  8041601a61:	83 e0 7f             	and    $0x7f,%eax
  8041601a64:	d3 e0                	shl    %cl,%eax
  8041601a66:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601a69:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a6c:	40 84 f6             	test   %sil,%sil
  8041601a6f:	78 e4                	js     8041601a55 <info_by_address+0x472>
  return count;
  8041601a71:	48 63 ff             	movslq %edi,%rdi
      abbrev_entry += count;
  8041601a74:	48 01 fb             	add    %rdi,%rbx
  8041601a77:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601a7a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601a7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a84:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601a8a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601a8d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601a91:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601a94:	89 f0                	mov    %esi,%eax
  8041601a96:	83 e0 7f             	and    $0x7f,%eax
  8041601a99:	d3 e0                	shl    %cl,%eax
  8041601a9b:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601a9e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601aa1:	40 84 f6             	test   %sil,%sil
  8041601aa4:	78 e4                	js     8041601a8a <info_by_address+0x4a7>
  return count;
  8041601aa6:	48 63 ff             	movslq %edi,%rdi
      abbrev_entry += count;
  8041601aa9:	48 01 fb             	add    %rdi,%rbx
      if (name == DW_AT_low_pc) {
  8041601aac:	41 83 fc 11          	cmp    $0x11,%r12d
  8041601ab0:	0f 84 3a ff ff ff    	je     80416019f0 <info_by_address+0x40d>
      } else if (name == DW_AT_high_pc) {
  8041601ab6:	41 83 fc 12          	cmp    $0x12,%r12d
  8041601aba:	0f 84 4a ff ff ff    	je     8041601a0a <info_by_address+0x427>
        count = dwarf_read_abbrev_entry(
  8041601ac0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601acb:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601ad0:	44 89 ee             	mov    %r13d,%esi
  8041601ad3:	4c 89 f7             	mov    %r14,%rdi
  8041601ad6:	41 ff d7             	callq  *%r15
  8041601ad9:	e9 56 ff ff ff       	jmpq   8041601a34 <info_by_address+0x451>
    if (p >= low_pc && p <= high_pc) {
  8041601ade:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601ae2:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601ae6:	72 0a                	jb     8041601af2 <info_by_address+0x50f>
  8041601ae8:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601aec:	0f 86 a9 01 00 00    	jbe    8041601c9b <info_by_address+0x6b8>
    entry = entry_end;
  8041601af2:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601af6:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601afa:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041601afe:	48 3b 43 28          	cmp    0x28(%rbx),%rax
  8041601b02:	0f 83 b0 01 00 00    	jae    8041601cb8 <info_by_address+0x6d5>
  initial_len = get_unaligned(addr, uint32_t);
  8041601b08:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601b0d:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041601b11:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601b15:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601b1c:	00 00 00 
  8041601b1f:	ff d0                	callq  *%rax
  8041601b21:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  8041601b24:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601b26:	41 bd 04 00 00 00    	mov    $0x4,%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601b2c:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601b2f:	0f 87 5c fd ff ff    	ja     8041601891 <info_by_address+0x2ae>
      entry += count;
  8041601b35:	4d 63 ed             	movslq %r13d,%r13
  8041601b38:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601b3c:	4a 8d 1c 28          	lea    (%rax,%r13,1),%rbx
    const void *entry_end = entry + len;
  8041601b40:	48 8d 04 13          	lea    (%rbx,%rdx,1),%rax
  8041601b44:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601b48:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601b4d:	48 89 de             	mov    %rbx,%rsi
  8041601b50:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601b54:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601b5b:	00 00 00 
  8041601b5e:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041601b60:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  8041601b64:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601b68:	83 e8 02             	sub    $0x2,%eax
  8041601b6b:	66 a9 fd ff          	test   $0xfffd,%ax
  8041601b6f:	0f 85 72 fd ff ff    	jne    80416018e7 <info_by_address+0x304>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601b75:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601b7a:	48 89 de             	mov    %rbx,%rsi
  8041601b7d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601b81:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601b88:	00 00 00 
  8041601b8b:	ff d0                	callq  *%rax
  8041601b8d:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041601b91:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041601b95:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041601b99:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601b9e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601ba2:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601ba9:	00 00 00 
  8041601bac:	ff d0                	callq  *%rax
    assert(address_size == 8);
  8041601bae:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601bb2:	0f 85 64 fd ff ff    	jne    804160191c <info_by_address+0x339>
  8041601bb8:	4c 89 f2             	mov    %r14,%rdx
  8041601bbb:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601bc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601bc5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601bcb:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601bce:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601bd2:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601bd5:	89 f0                	mov    %esi,%eax
  8041601bd7:	83 e0 7f             	and    $0x7f,%eax
  8041601bda:	d3 e0                	shl    %cl,%eax
  8041601bdc:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601bdf:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601be2:	40 84 f6             	test   %sil,%sil
  8041601be5:	78 e4                	js     8041601bcb <info_by_address+0x5e8>
  return count;
  8041601be7:	48 63 ff             	movslq %edi,%rdi
    assert(abbrev_code != 0);
  8041601bea:	45 85 c0             	test   %r8d,%r8d
  8041601bed:	0f 84 5e fd ff ff    	je     8041601951 <info_by_address+0x36e>
    entry += count;
  8041601bf3:	49 01 fe             	add    %rdi,%r14
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601bf6:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601bfa:	4c 03 20             	add    (%rax),%r12
  8041601bfd:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041601c00:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601c05:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c0a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041601c10:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601c13:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c17:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601c1a:	89 f0                	mov    %esi,%eax
  8041601c1c:	83 e0 7f             	and    $0x7f,%eax
  8041601c1f:	d3 e0                	shl    %cl,%eax
  8041601c21:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041601c24:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c27:	40 84 f6             	test   %sil,%sil
  8041601c2a:	78 e4                	js     8041601c10 <info_by_address+0x62d>
  return count;
  8041601c2c:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601c2f:	49 01 fc             	add    %rdi,%r12
    assert(table_abbrev_code == abbrev_code);
  8041601c32:	45 39 c8             	cmp    %r9d,%r8d
  8041601c35:	0f 85 4b fd ff ff    	jne    8041601986 <info_by_address+0x3a3>
  8041601c3b:	4c 89 e2             	mov    %r12,%rdx
  8041601c3e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601c43:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c48:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601c4e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601c51:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c55:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601c58:	89 f0                	mov    %esi,%eax
  8041601c5a:	83 e0 7f             	and    $0x7f,%eax
  8041601c5d:	d3 e0                	shl    %cl,%eax
  8041601c5f:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601c62:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c65:	40 84 f6             	test   %sil,%sil
  8041601c68:	78 e4                	js     8041601c4e <info_by_address+0x66b>
  return count;
  8041601c6a:	48 63 ff             	movslq %edi,%rdi
    assert(tag == DW_TAG_compile_unit);
  8041601c6d:	41 83 f8 11          	cmp    $0x11,%r8d
  8041601c71:	0f 85 44 fd ff ff    	jne    80416019bb <info_by_address+0x3d8>
    abbrev_entry++;
  8041601c77:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601c7c:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601c83:	00 
  8041601c84:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601c8b:	00 
        count = dwarf_read_abbrev_entry(
  8041601c8c:	49 bf 40 0c 60 41 80 	movabs $0x8041600c40,%r15
  8041601c93:	00 00 00 
  8041601c96:	e9 a7 fd ff ff       	jmpq   8041601a42 <info_by_address+0x45f>
          (const unsigned char *)header - addrs->info_begin;
  8041601c9b:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041601c9f:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601ca3:	48 2b 43 20          	sub    0x20(%rbx),%rax
      *store =
  8041601ca7:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041601cab:	48 89 03             	mov    %rax,(%rbx)
      return 0;
  8041601cae:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cb3:	e9 a8 fa ff ff       	jmpq   8041601760 <info_by_address+0x17d>
  return 0;
  8041601cb8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cbd:	e9 9e fa ff ff       	jmpq   8041601760 <info_by_address+0x17d>
      entry += count;
  8041601cc2:	48 98                	cltq   
  8041601cc4:	49 01 c6             	add    %rax,%r14
  8041601cc7:	e9 76 fd ff ff       	jmpq   8041601a42 <info_by_address+0x45f>

0000008041601ccc <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601ccc:	55                   	push   %rbp
  8041601ccd:	48 89 e5             	mov    %rsp,%rbp
  8041601cd0:	41 57                	push   %r15
  8041601cd2:	41 56                	push   %r14
  8041601cd4:	41 55                	push   %r13
  8041601cd6:	41 54                	push   %r12
  8041601cd8:	53                   	push   %rbx
  8041601cd9:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601cdd:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601ce1:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601ce5:	48 29 d8             	sub    %rbx,%rax
  8041601ce8:	48 39 f0             	cmp    %rsi,%rax
  8041601ceb:	0f 82 35 04 00 00    	jb     8041602126 <file_name_by_info+0x45a>
  8041601cf1:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601cf5:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601cf8:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601cfc:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601d00:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601d03:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601d08:	48 89 de             	mov    %rbx,%rsi
  8041601d0b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d0f:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601d16:	00 00 00 
  8041601d19:	ff d0                	callq  *%rax
  8041601d1b:	8b 45 c8             	mov    -0x38(%rbp),%eax
  count       = 4;
  8041601d1e:	41 bc 04 00 00 00    	mov    $0x4,%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601d24:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601d27:	0f 87 41 01 00 00    	ja     8041601e6e <file_name_by_info+0x1a2>
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    entry += count;
  8041601d2d:	4d 63 e4             	movslq %r12d,%r12
  8041601d30:	4c 01 e3             	add    %r12,%rbx
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601d33:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601d38:	48 89 de             	mov    %rbx,%rsi
  8041601d3b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d3f:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601d46:	00 00 00 
  8041601d49:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  8041601d4b:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  8041601d4f:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601d53:	83 e8 02             	sub    $0x2,%eax
  8041601d56:	66 a9 fd ff          	test   $0xfffd,%ax
  8041601d5a:	0f 85 5c 01 00 00    	jne    8041601ebc <file_name_by_info+0x1f0>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601d60:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601d65:	48 89 de             	mov    %rbx,%rsi
  8041601d68:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d6c:	49 bf 9a 51 60 41 80 	movabs $0x804160519a,%r15
  8041601d73:	00 00 00 
  8041601d76:	41 ff d7             	callq  *%r15
  8041601d79:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  8041601d7d:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041601d81:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041601d85:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601d8a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d8e:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  8041601d91:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601d95:	0f 85 56 01 00 00    	jne    8041601ef1 <file_name_by_info+0x225>
  8041601d9b:	4c 89 f2             	mov    %r14,%rdx
  8041601d9e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601da3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601da8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601dae:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601db1:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601db5:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601db8:	89 f0                	mov    %esi,%eax
  8041601dba:	83 e0 7f             	and    $0x7f,%eax
  8041601dbd:	d3 e0                	shl    %cl,%eax
  8041601dbf:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601dc2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601dc5:	40 84 f6             	test   %sil,%sil
  8041601dc8:	78 e4                	js     8041601dae <file_name_by_info+0xe2>
  return count;
  8041601dca:	48 63 ff             	movslq %edi,%rdi

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601dcd:	45 85 c0             	test   %r8d,%r8d
  8041601dd0:	0f 84 50 01 00 00    	je     8041601f26 <file_name_by_info+0x25a>
  entry += count;
  8041601dd6:	49 01 fe             	add    %rdi,%r14

  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601dd9:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601ddd:	4c 03 28             	add    (%rax),%r13
  8041601de0:	4c 89 ea             	mov    %r13,%rdx
  count  = 0;
  8041601de3:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601de8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601ded:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041601df3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601df6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601dfa:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601dfd:	89 f0                	mov    %esi,%eax
  8041601dff:	83 e0 7f             	and    $0x7f,%eax
  8041601e02:	d3 e0                	shl    %cl,%eax
  8041601e04:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041601e07:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601e0a:	40 84 f6             	test   %sil,%sil
  8041601e0d:	78 e4                	js     8041601df3 <file_name_by_info+0x127>
  return count;
  8041601e0f:	48 63 ff             	movslq %edi,%rdi
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  8041601e12:	49 01 fd             	add    %rdi,%r13
  assert(table_abbrev_code == abbrev_code);
  8041601e15:	45 39 c8             	cmp    %r9d,%r8d
  8041601e18:	0f 85 3d 01 00 00    	jne    8041601f5b <file_name_by_info+0x28f>
  8041601e1e:	4c 89 ea             	mov    %r13,%rdx
  8041601e21:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601e26:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601e2b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601e31:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601e34:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601e38:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601e3b:	89 f0                	mov    %esi,%eax
  8041601e3d:	83 e0 7f             	and    $0x7f,%eax
  8041601e40:	d3 e0                	shl    %cl,%eax
  8041601e42:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601e45:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601e48:	40 84 f6             	test   %sil,%sil
  8041601e4b:	78 e4                	js     8041601e31 <file_name_by_info+0x165>
  return count;
  8041601e4d:	48 63 ff             	movslq %edi,%rdi
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601e50:	41 83 f8 11          	cmp    $0x11,%r8d
  8041601e54:	0f 85 36 01 00 00    	jne    8041601f90 <file_name_by_info+0x2c4>
  abbrev_entry++;
  8041601e5a:	49 8d 5c 3d 01       	lea    0x1(%r13,%rdi,1),%rbx
    } else if (name == DW_AT_stmt_list) {
      count = dwarf_read_abbrev_entry(entry, form, line_off,
                                      sizeof(Dwarf_Off),
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601e5f:	49 bf 40 0c 60 41 80 	movabs $0x8041600c40,%r15
  8041601e66:	00 00 00 
  8041601e69:	e9 85 01 00 00       	jmpq   8041601ff3 <file_name_by_info+0x327>
    if (initial_len == DW_EXT_DWARF64) {
  8041601e6e:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601e71:	74 25                	je     8041601e98 <file_name_by_info+0x1cc>
      cprintf("Unknown DWARF extension\n");
  8041601e73:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  8041601e7a:	00 00 00 
  8041601e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e82:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041601e89:	00 00 00 
  8041601e8c:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  8041601e8e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601e93:	e9 7f 02 00 00       	jmpq   8041602117 <file_name_by_info+0x44b>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601e98:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601e9c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601ea1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601ea5:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041601eac:	00 00 00 
  8041601eaf:	ff d0                	callq  *%rax
      count = 12;
  8041601eb1:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601eb7:	e9 71 fe ff ff       	jmpq   8041601d2d <file_name_by_info+0x61>
  assert(version == 4 || version == 2);
  8041601ebc:	48 b9 8e 57 60 41 80 	movabs $0x804160578e,%rcx
  8041601ec3:	00 00 00 
  8041601ec6:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601ecd:	00 00 00 
  8041601ed0:	be 98 01 00 00       	mov    $0x198,%esi
  8041601ed5:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601edc:	00 00 00 
  8041601edf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ee4:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041601eeb:	00 00 00 
  8041601eee:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  8041601ef1:	48 b9 5b 57 60 41 80 	movabs $0x804160575b,%rcx
  8041601ef8:	00 00 00 
  8041601efb:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601f02:	00 00 00 
  8041601f05:	be 9c 01 00 00       	mov    $0x19c,%esi
  8041601f0a:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601f11:	00 00 00 
  8041601f14:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f19:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041601f20:	00 00 00 
  8041601f23:	41 ff d0             	callq  *%r8
  assert(abbrev_code != 0);
  8041601f26:	48 b9 ab 57 60 41 80 	movabs $0x80416057ab,%rcx
  8041601f2d:	00 00 00 
  8041601f30:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601f37:	00 00 00 
  8041601f3a:	be a1 01 00 00       	mov    $0x1a1,%esi
  8041601f3f:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601f46:	00 00 00 
  8041601f49:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f4e:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041601f55:	00 00 00 
  8041601f58:	41 ff d0             	callq  *%r8
  assert(table_abbrev_code == abbrev_code);
  8041601f5b:	48 b9 e0 58 60 41 80 	movabs $0x80416058e0,%rcx
  8041601f62:	00 00 00 
  8041601f65:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601f6c:	00 00 00 
  8041601f6f:	be a9 01 00 00       	mov    $0x1a9,%esi
  8041601f74:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601f7b:	00 00 00 
  8041601f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f83:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041601f8a:	00 00 00 
  8041601f8d:	41 ff d0             	callq  *%r8
  assert(tag == DW_TAG_compile_unit);
  8041601f90:	48 b9 bc 57 60 41 80 	movabs $0x80416057bc,%rcx
  8041601f97:	00 00 00 
  8041601f9a:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041601fa1:	00 00 00 
  8041601fa4:	be ad 01 00 00       	mov    $0x1ad,%esi
  8041601fa9:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041601fb0:	00 00 00 
  8041601fb3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601fb8:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041601fbf:	00 00 00 
  8041601fc2:	41 ff d0             	callq  *%r8
      if (form == DW_FORM_strp) {
  8041601fc5:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601fc9:	0f 84 c0 00 00 00    	je     804160208f <file_name_by_info+0x3c3>
        count = dwarf_read_abbrev_entry(
  8041601fcf:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601fd5:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601fd8:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601fdc:	44 89 ee             	mov    %r13d,%esi
  8041601fdf:	4c 89 f7             	mov    %r14,%rdi
  8041601fe2:	41 ff d7             	callq  *%r15
                                      address_size);
    }
    entry += count;
  8041601fe5:	48 98                	cltq   
  8041601fe7:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601fea:	45 09 e5             	or     %r12d,%r13d
  8041601fed:	0f 84 1f 01 00 00    	je     8041602112 <file_name_by_info+0x446>
  8041601ff3:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601ff6:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601ffb:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602000:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602006:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602009:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160200d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602010:	89 f0                	mov    %esi,%eax
  8041602012:	83 e0 7f             	and    $0x7f,%eax
  8041602015:	d3 e0                	shl    %cl,%eax
  8041602017:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160201a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160201d:	40 84 f6             	test   %sil,%sil
  8041602020:	78 e4                	js     8041602006 <file_name_by_info+0x33a>
  return count;
  8041602022:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041602025:	48 01 fb             	add    %rdi,%rbx
  8041602028:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160202b:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602030:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602035:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160203b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160203e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602042:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602045:	89 f0                	mov    %esi,%eax
  8041602047:	83 e0 7f             	and    $0x7f,%eax
  804160204a:	d3 e0                	shl    %cl,%eax
  804160204c:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  804160204f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602052:	40 84 f6             	test   %sil,%sil
  8041602055:	78 e4                	js     804160203b <file_name_by_info+0x36f>
  return count;
  8041602057:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  804160205a:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  804160205d:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602061:	0f 84 5e ff ff ff    	je     8041601fc5 <file_name_by_info+0x2f9>
    } else if (name == DW_AT_stmt_list) {
  8041602067:	41 83 fc 10          	cmp    $0x10,%r12d
  804160206b:	0f 84 84 00 00 00    	je     80416020f5 <file_name_by_info+0x429>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041602071:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602077:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160207c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602081:	44 89 ee             	mov    %r13d,%esi
  8041602084:	4c 89 f7             	mov    %r14,%rdi
  8041602087:	41 ff d7             	callq  *%r15
  804160208a:	e9 56 ff ff ff       	jmpq   8041601fe5 <file_name_by_info+0x319>
        unsigned long offset = 0;
  804160208f:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602096:	00 
        count                = dwarf_read_abbrev_entry(
  8041602097:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160209d:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416020a2:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  80416020a6:	be 0e 00 00 00       	mov    $0xe,%esi
  80416020ab:	4c 89 f7             	mov    %r14,%rdi
  80416020ae:	41 ff d7             	callq  *%r15
  80416020b1:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  80416020b4:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  80416020b8:	48 85 ff             	test   %rdi,%rdi
  80416020bb:	74 06                	je     80416020c3 <file_name_by_info+0x3f7>
  80416020bd:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  80416020c1:	77 0b                	ja     80416020ce <file_name_by_info+0x402>
    entry += count;
  80416020c3:	4d 63 e4             	movslq %r12d,%r12
  80416020c6:	4d 01 e6             	add    %r12,%r14
  80416020c9:	e9 25 ff ff ff       	jmpq   8041601ff3 <file_name_by_info+0x327>
          put_unaligned(
  80416020ce:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416020d2:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  80416020d6:	48 03 41 40          	add    0x40(%rcx),%rax
  80416020da:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  80416020de:	ba 08 00 00 00       	mov    $0x8,%edx
  80416020e3:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  80416020e7:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416020ee:	00 00 00 
  80416020f1:	ff d0                	callq  *%rax
  80416020f3:	eb ce                	jmp    80416020c3 <file_name_by_info+0x3f7>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  80416020f5:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416020fb:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602100:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041602104:	44 89 ee             	mov    %r13d,%esi
  8041602107:	4c 89 f7             	mov    %r14,%rdi
  804160210a:	41 ff d7             	callq  *%r15
  804160210d:	e9 d3 fe ff ff       	jmpq   8041601fe5 <file_name_by_info+0x319>

  return 0;
  8041602112:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041602117:	48 83 c4 38          	add    $0x38,%rsp
  804160211b:	5b                   	pop    %rbx
  804160211c:	41 5c                	pop    %r12
  804160211e:	41 5d                	pop    %r13
  8041602120:	41 5e                	pop    %r14
  8041602122:	41 5f                	pop    %r15
  8041602124:	5d                   	pop    %rbp
  8041602125:	c3                   	retq   
    return -E_INVAL;
  8041602126:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160212b:	eb ea                	jmp    8041602117 <file_name_by_info+0x44b>

000000804160212d <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  804160212d:	55                   	push   %rbp
  804160212e:	48 89 e5             	mov    %rsp,%rbp
  8041602131:	41 57                	push   %r15
  8041602133:	41 56                	push   %r14
  8041602135:	41 55                	push   %r13
  8041602137:	41 54                	push   %r12
  8041602139:	53                   	push   %rbx
  804160213a:	48 83 ec 68          	sub    $0x68,%rsp
  804160213e:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  8041602142:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  8041602149:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  804160214d:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  8041602151:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  8041602158:	48 89 d3             	mov    %rdx,%rbx
  804160215b:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160215f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602164:	48 89 de             	mov    %rbx,%rsi
  8041602167:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160216b:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041602172:	00 00 00 
  8041602175:	ff d0                	callq  *%rax
  8041602177:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  804160217a:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160217c:	41 be 04 00 00 00    	mov    $0x4,%r14d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602182:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602185:	76 2c                	jbe    80416021b3 <function_by_info+0x86>
    if (initial_len == DW_EXT_DWARF64) {
  8041602187:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160218a:	0f 85 8f 00 00 00    	jne    804160221f <function_by_info+0xf2>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602190:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041602194:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602199:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160219d:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416021a4:	00 00 00 
  80416021a7:	ff d0                	callq  *%rax
  80416021a9:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
      count = 12;
  80416021ad:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  }
  entry += count;
  80416021b3:	4d 63 f6             	movslq %r14d,%r14
  80416021b6:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  80416021b9:	48 8d 04 13          	lea    (%rbx,%rdx,1),%rax
  80416021bd:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416021c1:	ba 02 00 00 00       	mov    $0x2,%edx
  80416021c6:	48 89 de             	mov    %rbx,%rsi
  80416021c9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021cd:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416021d4:	00 00 00 
  80416021d7:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416021d9:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416021dd:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416021e1:	83 e8 02             	sub    $0x2,%eax
  80416021e4:	66 a9 fd ff          	test   $0xfffd,%ax
  80416021e8:	74 64                	je     804160224e <function_by_info+0x121>
  80416021ea:	48 b9 8e 57 60 41 80 	movabs $0x804160578e,%rcx
  80416021f1:	00 00 00 
  80416021f4:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  80416021fb:	00 00 00 
  80416021fe:	be e6 01 00 00       	mov    $0x1e6,%esi
  8041602203:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  804160220a:	00 00 00 
  804160220d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602212:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041602219:	00 00 00 
  804160221c:	41 ff d0             	callq  *%r8
      cprintf("Unknown DWARF extension\n");
  804160221f:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  8041602226:	00 00 00 
  8041602229:	b8 00 00 00 00       	mov    $0x0,%eax
  804160222e:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041602235:	00 00 00 
  8041602238:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  804160223a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  804160223f:	48 83 c4 68          	add    $0x68,%rsp
  8041602243:	5b                   	pop    %rbx
  8041602244:	41 5c                	pop    %r12
  8041602246:	41 5d                	pop    %r13
  8041602248:	41 5e                	pop    %r14
  804160224a:	41 5f                	pop    %r15
  804160224c:	5d                   	pop    %rbp
  804160224d:	c3                   	retq   
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  804160224e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602253:	48 89 de             	mov    %rbx,%rsi
  8041602256:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160225a:	49 bc 9a 51 60 41 80 	movabs $0x804160519a,%r12
  8041602261:	00 00 00 
  8041602264:	41 ff d4             	callq  *%r12
  8041602267:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  804160226b:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  804160226f:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602273:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602278:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160227c:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  804160227f:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602283:	74 35                	je     80416022ba <function_by_info+0x18d>
  8041602285:	48 b9 5b 57 60 41 80 	movabs $0x804160575b,%rcx
  804160228c:	00 00 00 
  804160228f:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041602296:	00 00 00 
  8041602299:	be ea 01 00 00       	mov    $0x1ea,%esi
  804160229e:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  80416022a5:	00 00 00 
  80416022a8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416022ad:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416022b4:	00 00 00 
  80416022b7:	41 ff d0             	callq  *%r8
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  80416022ba:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416022be:	4c 03 28             	add    (%rax),%r13
  80416022c1:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  80416022c5:	49 bf 40 0c 60 41 80 	movabs $0x8041600c40,%r15
  80416022cc:	00 00 00 
  while (entry < entry_end) {
  80416022cf:	e9 8a 01 00 00       	jmpq   804160245e <function_by_info+0x331>
  result = 0;
  80416022d4:	48 89 d6             	mov    %rdx,%rsi
  count  = 0;
  80416022d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416022dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416022e1:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  80416022e7:	0f b6 3e             	movzbl (%rsi),%edi
    addr++;
  80416022ea:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  80416022ee:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  80416022f1:	89 f8                	mov    %edi,%eax
  80416022f3:	83 e0 7f             	and    $0x7f,%eax
  80416022f6:	d3 e0                	shl    %cl,%eax
  80416022f8:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  80416022fb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416022fe:	40 84 ff             	test   %dil,%dil
  8041602301:	78 e4                	js     80416022e7 <function_by_info+0x1ba>
  return count;
  8041602303:	48 63 db             	movslq %ebx,%rbx
        curr_abbrev_entry += count;
  8041602306:	48 01 d3             	add    %rdx,%rbx
  8041602309:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160230c:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602311:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602316:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  804160231c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160231f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602323:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602326:	89 f0                	mov    %esi,%eax
  8041602328:	83 e0 7f             	and    $0x7f,%eax
  804160232b:	d3 e0                	shl    %cl,%eax
  804160232d:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602330:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602333:	40 84 f6             	test   %sil,%sil
  8041602336:	78 e4                	js     804160231c <function_by_info+0x1ef>
  return count;
  8041602338:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160233b:	48 8d 14 3b          	lea    (%rbx,%rdi,1),%rdx
      } while (name != 0 || form != 0);
  804160233f:	45 09 dc             	or     %r11d,%r12d
  8041602342:	75 90                	jne    80416022d4 <function_by_info+0x1a7>
    while ((const unsigned char *)curr_abbrev_entry <
  8041602344:	4c 39 d2             	cmp    %r10,%rdx
  8041602347:	73 77                	jae    80416023c0 <function_by_info+0x293>
  8041602349:	48 89 d7             	mov    %rdx,%rdi
  804160234c:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  8041602352:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602357:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  804160235c:	44 0f b6 07          	movzbl (%rdi),%r8d
    addr++;
  8041602360:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041602364:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  8041602368:	44 89 c0             	mov    %r8d,%eax
  804160236b:	83 e0 7f             	and    $0x7f,%eax
  804160236e:	d3 e0                	shl    %cl,%eax
  8041602370:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602372:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602375:	45 84 c0             	test   %r8b,%r8b
  8041602378:	78 e2                	js     804160235c <function_by_info+0x22f>
  return count;
  804160237a:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry += count;
  804160237d:	49 01 d3             	add    %rdx,%r11
  8041602380:	4c 89 da             	mov    %r11,%rdx
  count  = 0;
  8041602383:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041602388:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160238d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602393:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602396:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160239a:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160239d:	89 f8                	mov    %edi,%eax
  804160239f:	83 e0 7f             	and    $0x7f,%eax
  80416023a2:	d3 e0                	shl    %cl,%eax
  80416023a4:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416023a7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023aa:	40 84 ff             	test   %dil,%dil
  80416023ad:	78 e4                	js     8041602393 <function_by_info+0x266>
  return count;
  80416023af:	48 63 db             	movslq %ebx,%rbx
      curr_abbrev_entry++;
  80416023b2:	49 8d 54 1b 01       	lea    0x1(%r11,%rbx,1),%rdx
      if (table_abbrev_code == abbrev_code) {
  80416023b7:	41 39 f1             	cmp    %esi,%r9d
  80416023ba:	0f 85 14 ff ff ff    	jne    80416022d4 <function_by_info+0x1a7>
  80416023c0:	48 89 d3             	mov    %rdx,%rbx
    if (tag == DW_TAG_subprogram) {
  80416023c3:	41 83 f8 2e          	cmp    $0x2e,%r8d
  80416023c7:	0f 84 f3 00 00 00    	je     80416024c0 <function_by_info+0x393>
            fn_name_entry = entry;
  80416023cd:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023d0:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416023d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023da:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416023e0:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416023e3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023e7:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416023ea:	89 f0                	mov    %esi,%eax
  80416023ec:	83 e0 7f             	and    $0x7f,%eax
  80416023ef:	d3 e0                	shl    %cl,%eax
  80416023f1:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416023f4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023f7:	40 84 f6             	test   %sil,%sil
  80416023fa:	78 e4                	js     80416023e0 <function_by_info+0x2b3>
  return count;
  80416023fc:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416023ff:	48 01 fb             	add    %rdi,%rbx
  8041602402:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602405:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160240a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160240f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602415:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602418:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160241c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160241f:	89 f0                	mov    %esi,%eax
  8041602421:	83 e0 7f             	and    $0x7f,%eax
  8041602424:	d3 e0                	shl    %cl,%eax
  8041602426:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602429:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160242c:	40 84 f6             	test   %sil,%sil
  804160242f:	78 e4                	js     8041602415 <function_by_info+0x2e8>
  return count;
  8041602431:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602434:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  8041602437:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160243d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602442:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602447:	44 89 e6             	mov    %r12d,%esi
  804160244a:	4c 89 f7             	mov    %r14,%rdi
  804160244d:	41 ff d7             	callq  *%r15
        entry += count;
  8041602450:	48 98                	cltq   
  8041602452:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602455:	45 09 ec             	or     %r13d,%r12d
  8041602458:	0f 85 6f ff ff ff    	jne    80416023cd <function_by_info+0x2a0>
  while (entry < entry_end) {
  804160245e:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  8041602462:	0f 86 35 02 00 00    	jbe    804160269d <function_by_info+0x570>
  8041602468:	4c 89 f2             	mov    %r14,%rdx
  804160246b:	bf 00 00 00 00       	mov    $0x0,%edi
  8041602470:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602475:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160247b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160247e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602482:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602485:	89 f0                	mov    %esi,%eax
  8041602487:	83 e0 7f             	and    $0x7f,%eax
  804160248a:	d3 e0                	shl    %cl,%eax
  804160248c:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160248f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602492:	40 84 f6             	test   %sil,%sil
  8041602495:	78 e4                	js     804160247b <function_by_info+0x34e>
  return count;
  8041602497:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  804160249a:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  804160249d:	45 85 c9             	test   %r9d,%r9d
  80416024a0:	0f 84 01 02 00 00    	je     80416026a7 <function_by_info+0x57a>
           addrs->abbrev_end) { // unsafe needs to be replaced
  80416024a6:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416024aa:	4c 8b 50 08          	mov    0x8(%rax),%r10
  80416024ae:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
  80416024b2:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80416024b8:	48 89 da             	mov    %rbx,%rdx
  80416024bb:	e9 84 fe ff ff       	jmpq   8041602344 <function_by_info+0x217>
      uintptr_t low_pc = 0, high_pc = 0;
  80416024c0:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  80416024c7:	00 
  80416024c8:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  80416024cf:	00 
      unsigned name_form        = 0;
  80416024d0:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  80416024d7:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80416024de:	00 
  80416024df:	eb 6d                	jmp    804160254e <function_by_info+0x421>
          count = dwarf_read_abbrev_entry(
  80416024e1:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416024e7:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416024ec:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416024f0:	44 89 ee             	mov    %r13d,%esi
  80416024f3:	4c 89 f7             	mov    %r14,%rdi
  80416024f6:	41 ff d7             	callq  *%r15
  80416024f9:	eb 45                	jmp    8041602540 <function_by_info+0x413>
          count = dwarf_read_abbrev_entry(
  80416024fb:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602501:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602506:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  804160250a:	44 89 ee             	mov    %r13d,%esi
  804160250d:	4c 89 f7             	mov    %r14,%rdi
  8041602510:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  8041602513:	41 83 fd 01          	cmp    $0x1,%r13d
  8041602517:	0f 84 a1 01 00 00    	je     80416026be <function_by_info+0x591>
            high_pc += low_pc;
  804160251d:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041602521:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  8041602525:	eb 19                	jmp    8041602540 <function_by_info+0x413>
          count = dwarf_read_abbrev_entry(
  8041602527:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160252d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602532:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602537:	44 89 ee             	mov    %r13d,%esi
  804160253a:	4c 89 f7             	mov    %r14,%rdi
  804160253d:	41 ff d7             	callq  *%r15
        entry += count;
  8041602540:	48 98                	cltq   
  8041602542:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602545:	45 09 e5             	or     %r12d,%r13d
  8041602548:	0f 84 95 00 00 00    	je     80416025e3 <function_by_info+0x4b6>
      const void *fn_name_entry = 0;
  804160254e:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602551:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602556:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160255b:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602561:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602564:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602568:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160256b:	89 f0                	mov    %esi,%eax
  804160256d:	83 e0 7f             	and    $0x7f,%eax
  8041602570:	d3 e0                	shl    %cl,%eax
  8041602572:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602575:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602578:	40 84 f6             	test   %sil,%sil
  804160257b:	78 e4                	js     8041602561 <function_by_info+0x434>
  return count;
  804160257d:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602580:	48 01 fb             	add    %rdi,%rbx
  8041602583:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602586:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160258b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602590:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602596:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602599:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160259d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025a0:	89 f0                	mov    %esi,%eax
  80416025a2:	83 e0 7f             	and    $0x7f,%eax
  80416025a5:	d3 e0                	shl    %cl,%eax
  80416025a7:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416025aa:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025ad:	40 84 f6             	test   %sil,%sil
  80416025b0:	78 e4                	js     8041602596 <function_by_info+0x469>
  return count;
  80416025b2:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025b5:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  80416025b8:	41 83 fc 11          	cmp    $0x11,%r12d
  80416025bc:	0f 84 1f ff ff ff    	je     80416024e1 <function_by_info+0x3b4>
        } else if (name == DW_AT_high_pc) {
  80416025c2:	41 83 fc 12          	cmp    $0x12,%r12d
  80416025c6:	0f 84 2f ff ff ff    	je     80416024fb <function_by_info+0x3ce>
          if (name == DW_AT_name) {
  80416025cc:	41 83 fc 03          	cmp    $0x3,%r12d
  80416025d0:	0f 85 51 ff ff ff    	jne    8041602527 <function_by_info+0x3fa>
    result |= (byte & 0x7f) << shift;
  80416025d6:	44 89 6d a4          	mov    %r13d,-0x5c(%rbp)
            fn_name_entry = entry;
  80416025da:	4c 89 75 a8          	mov    %r14,-0x58(%rbp)
  80416025de:	e9 44 ff ff ff       	jmpq   8041602527 <function_by_info+0x3fa>
      if (p >= low_pc && p <= high_pc) {
  80416025e3:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416025e7:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  80416025ee:	48 39 d8             	cmp    %rbx,%rax
  80416025f1:	0f 87 67 fe ff ff    	ja     804160245e <function_by_info+0x331>
  80416025f7:	48 3b 5d b8          	cmp    -0x48(%rbp),%rbx
  80416025fb:	0f 87 5d fe ff ff    	ja     804160245e <function_by_info+0x331>
        *offset = low_pc;
  8041602601:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  8041602608:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  804160260b:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  804160260f:	75 6a                	jne    804160267b <function_by_info+0x54e>
          unsigned long str_offset = 0;
  8041602611:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602618:	00 
          count                    = dwarf_read_abbrev_entry(
  8041602619:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160261f:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602624:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602628:	be 0e 00 00 00       	mov    $0xe,%esi
  804160262d:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602631:	48 b8 40 0c 60 41 80 	movabs $0x8041600c40,%rax
  8041602638:	00 00 00 
  804160263b:	ff d0                	callq  *%rax
          if (buf &&
  804160263d:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  8041602641:	48 85 ff             	test   %rdi,%rdi
  8041602644:	74 2b                	je     8041602671 <function_by_info+0x544>
  8041602646:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  804160264a:	76 25                	jbe    8041602671 <function_by_info+0x544>
            put_unaligned(
  804160264c:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602650:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602654:	48 03 43 40          	add    0x40(%rbx),%rax
  8041602658:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  804160265c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602661:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602665:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160266c:	00 00 00 
  804160266f:	ff d0                	callq  *%rax
        return 0;
  8041602671:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602676:	e9 c4 fb ff ff       	jmpq   804160223f <function_by_info+0x112>
          count = dwarf_read_abbrev_entry(
  804160267b:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602681:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  8041602684:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  8041602688:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  804160268b:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  804160268f:	48 b8 40 0c 60 41 80 	movabs $0x8041600c40,%rax
  8041602696:	00 00 00 
  8041602699:	ff d0                	callq  *%rax
  804160269b:	eb d4                	jmp    8041602671 <function_by_info+0x544>
  return 0;
  804160269d:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026a2:	e9 98 fb ff ff       	jmpq   804160223f <function_by_info+0x112>
    entry += count;
  80416026a7:	4c 89 f2             	mov    %r14,%rdx
  while (entry < entry_end) {
  80416026aa:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  80416026ae:	0f 87 b7 fd ff ff    	ja     804160246b <function_by_info+0x33e>
  return 0;
  80416026b4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026b9:	e9 81 fb ff ff       	jmpq   804160223f <function_by_info+0x112>
        entry += count;
  80416026be:	48 98                	cltq   
  80416026c0:	49 01 c6             	add    %rax,%r14
  80416026c3:	e9 86 fe ff ff       	jmpq   804160254e <function_by_info+0x421>

00000080416026c8 <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  80416026c8:	55                   	push   %rbp
  80416026c9:	48 89 e5             	mov    %rsp,%rbp
  80416026cc:	41 57                	push   %r15
  80416026ce:	41 56                	push   %r14
  80416026d0:	41 55                	push   %r13
  80416026d2:	41 54                	push   %r12
  80416026d4:	53                   	push   %rbx
  80416026d5:	48 83 ec 38          	sub    $0x38,%rsp
  80416026d9:	48 89 fb             	mov    %rdi,%rbx
  80416026dc:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80416026e0:	48 89 f7             	mov    %rsi,%rdi
  80416026e3:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  const int flen = strlen(fname);
  80416026e7:	48 b8 dc 4e 60 41 80 	movabs $0x8041604edc,%rax
  80416026ee:	00 00 00 
  80416026f1:	ff d0                	callq  *%rax
  if (flen == 0)
  80416026f3:	85 c0                	test   %eax,%eax
  80416026f5:	0f 84 45 04 00 00    	je     8041602b40 <address_by_fname+0x478>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  80416026fb:	4c 8b 63 50          	mov    0x50(%rbx),%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416026ff:	49 be 9a 51 60 41 80 	movabs $0x804160519a,%r14
  8041602706:	00 00 00 
  int count                  = 0;
  unsigned long len          = 0;
  Dwarf_Off cu_offset        = 0;
  Dwarf_Off func_offset      = 0;
  // parse pubnames section
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  8041602709:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160270d:	4c 3b 60 58          	cmp    0x58(%rax),%r12
  8041602711:	0f 83 1f 04 00 00    	jae    8041602b36 <address_by_fname+0x46e>
  8041602717:	ba 04 00 00 00       	mov    $0x4,%edx
  804160271c:	4c 89 e6             	mov    %r12,%rsi
  804160271f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602723:	41 ff d6             	callq  *%r14
  8041602726:	8b 55 c8             	mov    -0x38(%rbp),%edx
    *len = initial_len;
  8041602729:	89 d1                	mov    %edx,%ecx
  count       = 4;
  804160272b:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602730:	83 fa ef             	cmp    $0xffffffef,%edx
  8041602733:	0f 87 d3 00 00 00    	ja     804160280c <address_by_fname+0x144>
    count = dwarf_entry_len(pubnames_entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    pubnames_entry += count;
  8041602739:	48 98                	cltq   
  804160273b:	49 01 c4             	add    %rax,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  804160273e:	49 8d 04 0c          	lea    (%r12,%rcx,1),%rax
  8041602742:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  8041602746:	ba 02 00 00 00       	mov    $0x2,%edx
  804160274b:	4c 89 e6             	mov    %r12,%rsi
  804160274e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602752:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  8041602755:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  804160275a:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160275f:	0f 85 fc 00 00 00    	jne    8041602861 <address_by_fname+0x199>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602765:	ba 04 00 00 00       	mov    $0x4,%edx
  804160276a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160276e:	41 ff d6             	callq  *%r14
  8041602771:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041602774:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  8041602777:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160277c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602781:	48 89 de             	mov    %rbx,%rsi
  8041602784:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602788:	41 ff d6             	callq  *%r14
  804160278b:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  804160278e:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602793:	83 fa ef             	cmp    $0xffffffef,%edx
  8041602796:	0f 87 fa 00 00 00    	ja     8041602896 <address_by_fname+0x1ce>
    count = dwarf_entry_len(pubnames_entry, &len);
    pubnames_entry += count;
  804160279c:	48 98                	cltq   
  804160279e:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416027a2:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416027a6:	0f 86 5d ff ff ff    	jbe    8041602709 <address_by_fname+0x41>
          // Attribute value can be obtained using dwarf_read_abbrev_entry function.
          // LAB 3: Your code here:
        }
        return 0;
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
  80416027ac:	49 bf dc 4e 60 41 80 	movabs $0x8041604edc,%r15
  80416027b3:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416027b6:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027bb:	4c 89 e6             	mov    %r12,%rsi
  80416027be:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027c2:	41 ff d6             	callq  *%r14
  80416027c5:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416027c9:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416027cd:	4d 85 ed             	test   %r13,%r13
  80416027d0:	0f 84 29 ff ff ff    	je     80416026ff <address_by_fname+0x37>
      if (!strcmp(fname, pubnames_entry)) {
  80416027d6:	4c 89 e6             	mov    %r12,%rsi
  80416027d9:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416027dd:	48 b8 06 50 60 41 80 	movabs $0x8041605006,%rax
  80416027e4:	00 00 00 
  80416027e7:	ff d0                	callq  *%rax
  80416027e9:	89 c3                	mov    %eax,%ebx
  80416027eb:	85 c0                	test   %eax,%eax
  80416027ed:	0f 84 e8 00 00 00    	je     80416028db <address_by_fname+0x213>
      pubnames_entry += strlen(pubnames_entry) + 1;
  80416027f3:	4c 89 e7             	mov    %r12,%rdi
  80416027f6:	41 ff d7             	callq  *%r15
  80416027f9:	83 c0 01             	add    $0x1,%eax
  80416027fc:	48 98                	cltq   
  80416027fe:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602801:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041602805:	77 af                	ja     80416027b6 <address_by_fname+0xee>
  8041602807:	e9 fd fe ff ff       	jmpq   8041602709 <address_by_fname+0x41>
    if (initial_len == DW_EXT_DWARF64) {
  804160280c:	83 fa ff             	cmp    $0xffffffff,%edx
  804160280f:	75 1f                	jne    8041602830 <address_by_fname+0x168>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602811:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041602816:	ba 08 00 00 00       	mov    $0x8,%edx
  804160281b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160281f:	41 ff d6             	callq  *%r14
  8041602822:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
      count = 12;
  8041602826:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160282b:	e9 09 ff ff ff       	jmpq   8041602739 <address_by_fname+0x71>
      cprintf("Unknown DWARF extension\n");
  8041602830:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  8041602837:	00 00 00 
  804160283a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160283f:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041602846:	00 00 00 
  8041602849:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  804160284b:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
    }
  }
  return 0;
}
  8041602850:	89 d8                	mov    %ebx,%eax
  8041602852:	48 83 c4 38          	add    $0x38,%rsp
  8041602856:	5b                   	pop    %rbx
  8041602857:	41 5c                	pop    %r12
  8041602859:	41 5d                	pop    %r13
  804160285b:	41 5e                	pop    %r14
  804160285d:	41 5f                	pop    %r15
  804160285f:	5d                   	pop    %rbp
  8041602860:	c3                   	retq   
    assert(version == 2);
  8041602861:	48 b9 9e 57 60 41 80 	movabs $0x804160579e,%rcx
  8041602868:	00 00 00 
  804160286b:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041602872:	00 00 00 
  8041602875:	be 73 02 00 00       	mov    $0x273,%esi
  804160287a:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041602881:	00 00 00 
  8041602884:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602889:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041602890:	00 00 00 
  8041602893:	41 ff d0             	callq  *%r8
    if (initial_len == DW_EXT_DWARF64) {
  8041602896:	83 fa ff             	cmp    $0xffffffff,%edx
  8041602899:	75 1b                	jne    80416028b6 <address_by_fname+0x1ee>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160289b:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  80416028a0:	ba 08 00 00 00       	mov    $0x8,%edx
  80416028a5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028a9:	41 ff d6             	callq  *%r14
      count = 12;
  80416028ac:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416028b1:	e9 e6 fe ff ff       	jmpq   804160279c <address_by_fname+0xd4>
      cprintf("Unknown DWARF extension\n");
  80416028b6:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  80416028bd:	00 00 00 
  80416028c0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028c5:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416028cc:	00 00 00 
  80416028cf:	ff d2                	callq  *%rdx
      count = 0;
  80416028d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028d6:	e9 c1 fe ff ff       	jmpq   804160279c <address_by_fname+0xd4>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028db:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  80416028df:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416028e3:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  80416028e7:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  80416028eb:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028f0:	4c 89 e6             	mov    %r12,%rsi
  80416028f3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028f7:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416028fe:	00 00 00 
  8041602901:	ff d0                	callq  *%rax
  8041602903:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  8041602906:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160290b:	83 fa ef             	cmp    $0xffffffef,%edx
  804160290e:	0f 87 9e 00 00 00    	ja     80416029b2 <address_by_fname+0x2ea>
        entry += count;
  8041602914:	48 98                	cltq   
  8041602916:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160291a:	ba 02 00 00 00       	mov    $0x2,%edx
  804160291f:	4c 89 ee             	mov    %r13,%rsi
  8041602922:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602926:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160292d:	00 00 00 
  8041602930:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602932:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  8041602936:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  804160293a:	83 e8 02             	sub    $0x2,%eax
  804160293d:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602941:	0f 85 b9 00 00 00    	jne    8041602a00 <address_by_fname+0x338>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602947:	ba 04 00 00 00       	mov    $0x4,%edx
  804160294c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602950:	49 be 9a 51 60 41 80 	movabs $0x804160519a,%r14
  8041602957:	00 00 00 
  804160295a:	41 ff d6             	callq  *%r14
  804160295d:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602961:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602965:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  8041602968:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  804160296c:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602971:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602975:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  8041602978:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160297c:	0f 85 b3 00 00 00    	jne    8041602a35 <address_by_fname+0x36d>
  8041602982:	89 d9                	mov    %ebx,%ecx
  8041602984:	4d 89 fd             	mov    %r15,%r13
  8041602987:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  804160298c:	41 0f b6 55 00       	movzbl 0x0(%r13),%edx
    addr++;
  8041602991:	49 83 c5 01          	add    $0x1,%r13
    result |= (byte & 0x7f) << shift;
  8041602995:	89 d0                	mov    %edx,%eax
  8041602997:	83 e0 7f             	and    $0x7f,%eax
  804160299a:	d3 e0                	shl    %cl,%eax
  804160299c:	09 c7                	or     %eax,%edi
    shift += 7;
  804160299e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416029a1:	84 d2                	test   %dl,%dl
  80416029a3:	78 e7                	js     804160298c <address_by_fname+0x2c4>
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  80416029a5:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416029a9:	4c 8b 40 08          	mov    0x8(%rax),%r8
  80416029ad:	e9 21 01 00 00       	jmpq   8041602ad3 <address_by_fname+0x40b>
    if (initial_len == DW_EXT_DWARF64) {
  80416029b2:	83 fa ff             	cmp    $0xffffffff,%edx
  80416029b5:	74 25                	je     80416029dc <address_by_fname+0x314>
      cprintf("Unknown DWARF extension\n");
  80416029b7:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  80416029be:	00 00 00 
  80416029c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029c6:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416029cd:	00 00 00 
  80416029d0:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416029d2:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416029d7:	e9 74 fe ff ff       	jmpq   8041602850 <address_by_fname+0x188>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029dc:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416029e1:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029e6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029ea:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416029f1:	00 00 00 
  80416029f4:	ff d0                	callq  *%rax
      count = 12;
  80416029f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416029fb:	e9 14 ff ff ff       	jmpq   8041602914 <address_by_fname+0x24c>
        assert(version == 4 || version == 2);
  8041602a00:	48 b9 8e 57 60 41 80 	movabs $0x804160578e,%rcx
  8041602a07:	00 00 00 
  8041602a0a:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041602a11:	00 00 00 
  8041602a14:	be 89 02 00 00       	mov    $0x289,%esi
  8041602a19:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041602a20:	00 00 00 
  8041602a23:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a28:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041602a2f:	00 00 00 
  8041602a32:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a35:	48 b9 5b 57 60 41 80 	movabs $0x804160575b,%rcx
  8041602a3c:	00 00 00 
  8041602a3f:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041602a46:	00 00 00 
  8041602a49:	be 8e 02 00 00       	mov    $0x28e,%esi
  8041602a4e:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041602a55:	00 00 00 
  8041602a58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a5d:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041602a64:	00 00 00 
  8041602a67:	41 ff d0             	callq  *%r8
  count  = 0;
  8041602a6a:	41 89 da             	mov    %ebx,%r10d
  shift  = 0;
  8041602a6d:	89 d9                	mov    %ebx,%ecx
  8041602a6f:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a72:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602a77:	44 0f b6 0a          	movzbl (%rdx),%r9d
    addr++;
  8041602a7b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a7f:	41 83 c2 01          	add    $0x1,%r10d
    result |= (byte & 0x7f) << shift;
  8041602a83:	44 89 c8             	mov    %r9d,%eax
  8041602a86:	83 e0 7f             	and    $0x7f,%eax
  8041602a89:	d3 e0                	shl    %cl,%eax
  8041602a8b:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602a8d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a90:	45 84 c9             	test   %r9b,%r9b
  8041602a93:	78 e2                	js     8041602a77 <address_by_fname+0x3af>
  return count;
  8041602a95:	4d 63 d2             	movslq %r10d,%r10
            abbrev_entry += count;
  8041602a98:	4d 01 d4             	add    %r10,%r12
  count  = 0;
  8041602a9b:	41 89 da             	mov    %ebx,%r10d
  shift  = 0;
  8041602a9e:	89 d9                	mov    %ebx,%ecx
  8041602aa0:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602aa3:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602aa9:	44 0f b6 0a          	movzbl (%rdx),%r9d
    addr++;
  8041602aad:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ab1:	41 83 c2 01          	add    $0x1,%r10d
    result |= (byte & 0x7f) << shift;
  8041602ab5:	44 89 c8             	mov    %r9d,%eax
  8041602ab8:	83 e0 7f             	and    $0x7f,%eax
  8041602abb:	d3 e0                	shl    %cl,%eax
  8041602abd:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602ac0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ac3:	45 84 c9             	test   %r9b,%r9b
  8041602ac6:	78 e1                	js     8041602aa9 <address_by_fname+0x3e1>
  return count;
  8041602ac8:	4d 63 d2             	movslq %r10d,%r10
            abbrev_entry += count;
  8041602acb:	4d 01 d4             	add    %r10,%r12
          } while (name != 0 || form != 0);
  8041602ace:	41 09 f3             	or     %esi,%r11d
  8041602ad1:	75 97                	jne    8041602a6a <address_by_fname+0x3a2>
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602ad3:	4d 39 c4             	cmp    %r8,%r12
  8041602ad6:	0f 83 74 fd ff ff    	jae    8041602850 <address_by_fname+0x188>
  8041602adc:	41 89 d9             	mov    %ebx,%r9d
  8041602adf:	89 d9                	mov    %ebx,%ecx
  8041602ae1:	4c 89 e2             	mov    %r12,%rdx
  8041602ae4:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602aea:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602aed:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602af1:	41 83 c1 01          	add    $0x1,%r9d
    result |= (byte & 0x7f) << shift;
  8041602af5:	89 f0                	mov    %esi,%eax
  8041602af7:	83 e0 7f             	and    $0x7f,%eax
  8041602afa:	d3 e0                	shl    %cl,%eax
  8041602afc:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602aff:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b02:	40 84 f6             	test   %sil,%sil
  8041602b05:	78 e3                	js     8041602aea <address_by_fname+0x422>
  return count;
  8041602b07:	4d 63 c9             	movslq %r9d,%r9
          abbrev_entry += count;
  8041602b0a:	4d 01 cc             	add    %r9,%r12
  count  = 0;
  8041602b0d:	89 da                	mov    %ebx,%edx
  8041602b0f:	4c 89 e0             	mov    %r12,%rax
    byte = *addr;
  8041602b12:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041602b15:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041602b19:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041602b1c:	84 c9                	test   %cl,%cl
  8041602b1e:	78 f2                	js     8041602b12 <address_by_fname+0x44a>
  return count;
  8041602b20:	48 63 d2             	movslq %edx,%rdx
          abbrev_entry++;
  8041602b23:	4d 8d 64 14 01       	lea    0x1(%r12,%rdx,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602b28:	44 39 d7             	cmp    %r10d,%edi
  8041602b2b:	0f 85 39 ff ff ff    	jne    8041602a6a <address_by_fname+0x3a2>
  8041602b31:	e9 1a fd ff ff       	jmpq   8041602850 <address_by_fname+0x188>
  return 0;
  8041602b36:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602b3b:	e9 10 fd ff ff       	jmpq   8041602850 <address_by_fname+0x188>
    return 0;
  8041602b40:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602b45:	e9 06 fd ff ff       	jmpq   8041602850 <address_by_fname+0x188>

0000008041602b4a <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602b4a:	55                   	push   %rbp
  8041602b4b:	48 89 e5             	mov    %rsp,%rbp
  8041602b4e:	41 57                	push   %r15
  8041602b50:	41 56                	push   %r14
  8041602b52:	41 55                	push   %r13
  8041602b54:	41 54                	push   %r12
  8041602b56:	53                   	push   %rbx
  8041602b57:	48 83 ec 48          	sub    $0x48,%rsp
  8041602b5b:	48 89 fb             	mov    %rdi,%rbx
  8041602b5e:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602b62:	48 89 f7             	mov    %rsi,%rdi
  8041602b65:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602b69:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602b6d:	48 b8 dc 4e 60 41 80 	movabs $0x8041604edc,%rax
  8041602b74:	00 00 00 
  8041602b77:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602b79:	85 c0                	test   %eax,%eax
  8041602b7b:	0f 84 26 05 00 00    	je     80416030a7 <naive_address_by_fname+0x55d>
    return 0;
  const void *entry = addrs->info_begin;
  8041602b81:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602b85:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602b89:	4c 3b 78 28          	cmp    0x28(%rax),%r15
  8041602b8d:	72 0a                	jb     8041602b99 <naive_address_by_fname+0x4f>
        } while (name != 0 || form != 0);
      }
    }
  }

  return 0;
  8041602b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602b94:	e9 df 00 00 00       	jmpq   8041602c78 <naive_address_by_fname+0x12e>
  initial_len = get_unaligned(addr, uint32_t);
  8041602b99:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602b9e:	4c 89 fe             	mov    %r15,%rsi
  8041602ba1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602ba5:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041602bac:	00 00 00 
  8041602baf:	ff d0                	callq  *%rax
  8041602bb1:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  8041602bb4:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041602bb6:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602bbb:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602bbe:	76 2b                	jbe    8041602beb <naive_address_by_fname+0xa1>
    if (initial_len == DW_EXT_DWARF64) {
  8041602bc0:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602bc3:	0f 85 8f 00 00 00    	jne    8041602c58 <naive_address_by_fname+0x10e>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602bc9:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602bcd:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602bd2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bd6:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041602bdd:	00 00 00 
  8041602be0:	ff d0                	callq  *%rax
  8041602be2:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
      count = 12;
  8041602be6:	bb 0c 00 00 00       	mov    $0xc,%ebx
    entry += count;
  8041602beb:	48 63 db             	movslq %ebx,%rbx
  8041602bee:	4d 8d 34 1f          	lea    (%r15,%rbx,1),%r14
    const void *entry_end = entry + len;
  8041602bf2:	49 8d 04 16          	lea    (%r14,%rdx,1),%rax
  8041602bf6:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602bfa:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602bff:	4c 89 f6             	mov    %r14,%rsi
  8041602c02:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c06:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041602c0d:	00 00 00 
  8041602c10:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602c12:	49 83 c6 02          	add    $0x2,%r14
    assert(version == 4 || version == 2);
  8041602c16:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602c1a:	83 e8 02             	sub    $0x2,%eax
  8041602c1d:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602c21:	74 64                	je     8041602c87 <naive_address_by_fname+0x13d>
  8041602c23:	48 b9 8e 57 60 41 80 	movabs $0x804160578e,%rcx
  8041602c2a:	00 00 00 
  8041602c2d:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041602c34:	00 00 00 
  8041602c37:	be d4 02 00 00       	mov    $0x2d4,%esi
  8041602c3c:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041602c43:	00 00 00 
  8041602c46:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602c4b:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041602c52:	00 00 00 
  8041602c55:	41 ff d0             	callq  *%r8
      cprintf("Unknown DWARF extension\n");
  8041602c58:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  8041602c5f:	00 00 00 
  8041602c62:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602c67:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041602c6e:	00 00 00 
  8041602c71:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602c73:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
  8041602c78:	48 83 c4 48          	add    $0x48,%rsp
  8041602c7c:	5b                   	pop    %rbx
  8041602c7d:	41 5c                	pop    %r12
  8041602c7f:	41 5d                	pop    %r13
  8041602c81:	41 5e                	pop    %r14
  8041602c83:	41 5f                	pop    %r15
  8041602c85:	5d                   	pop    %rbp
  8041602c86:	c3                   	retq   
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602c87:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602c8c:	4c 89 f6             	mov    %r14,%rsi
  8041602c8f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c93:	49 bc 9a 51 60 41 80 	movabs $0x804160519a,%r12
  8041602c9a:	00 00 00 
  8041602c9d:	41 ff d4             	callq  *%r12
  8041602ca0:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  8041602ca4:	49 8d 34 1e          	lea    (%r14,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602ca8:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602cac:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602cb1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602cb5:	41 ff d4             	callq  *%r12
    assert(address_size == 8);
  8041602cb8:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602cbc:	74 35                	je     8041602cf3 <naive_address_by_fname+0x1a9>
  8041602cbe:	48 b9 5b 57 60 41 80 	movabs $0x804160575b,%rcx
  8041602cc5:	00 00 00 
  8041602cc8:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041602ccf:	00 00 00 
  8041602cd2:	be d8 02 00 00       	mov    $0x2d8,%esi
  8041602cd7:	48 bf 4e 57 60 41 80 	movabs $0x804160574e,%rdi
  8041602cde:	00 00 00 
  8041602ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ce6:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041602ced:	00 00 00 
  8041602cf0:	41 ff d0             	callq  *%r8
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602cf3:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602cf7:	4c 03 28             	add    (%rax),%r13
  8041602cfa:	4c 89 6d 98          	mov    %r13,-0x68(%rbp)
            count = dwarf_read_abbrev_entry(
  8041602cfe:	49 be 40 0c 60 41 80 	movabs $0x8041600c40,%r14
  8041602d05:	00 00 00 
    while (entry < entry_end) {
  8041602d08:	e9 94 01 00 00       	jmpq   8041602ea1 <naive_address_by_fname+0x357>
  result = 0;
  8041602d0d:	48 89 d6             	mov    %rdx,%rsi
  count  = 0;
  8041602d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041602d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d1a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d20:	0f b6 3e             	movzbl (%rsi),%edi
    addr++;
  8041602d23:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041602d27:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041602d2a:	89 f8                	mov    %edi,%eax
  8041602d2c:	83 e0 7f             	and    $0x7f,%eax
  8041602d2f:	d3 e0                	shl    %cl,%eax
  8041602d31:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602d34:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d37:	40 84 ff             	test   %dil,%dil
  8041602d3a:	78 e4                	js     8041602d20 <naive_address_by_fname+0x1d6>
  return count;
  8041602d3c:	48 63 db             	movslq %ebx,%rbx
          curr_abbrev_entry += count;
  8041602d3f:	48 01 d3             	add    %rdx,%rbx
  8041602d42:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602d45:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602d4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d4f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602d55:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d58:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d5c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602d5f:	89 f0                	mov    %esi,%eax
  8041602d61:	83 e0 7f             	and    $0x7f,%eax
  8041602d64:	d3 e0                	shl    %cl,%eax
  8041602d66:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602d69:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d6c:	40 84 f6             	test   %sil,%sil
  8041602d6f:	78 e4                	js     8041602d55 <naive_address_by_fname+0x20b>
  return count;
  8041602d71:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602d74:	48 8d 14 3b          	lea    (%rbx,%rdi,1),%rdx
        } while (name != 0 || form != 0);
  8041602d78:	45 09 c4             	or     %r8d,%r12d
  8041602d7b:	75 90                	jne    8041602d0d <naive_address_by_fname+0x1c3>
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602d7d:	4c 39 da             	cmp    %r11,%rdx
  8041602d80:	73 77                	jae    8041602df9 <naive_address_by_fname+0x2af>
  8041602d82:	48 89 d7             	mov    %rdx,%rdi
  8041602d85:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8041602d8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602d90:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602d95:	44 0f b6 07          	movzbl (%rdi),%r8d
    addr++;
  8041602d99:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041602d9d:	41 83 c1 01          	add    $0x1,%r9d
    result |= (byte & 0x7f) << shift;
  8041602da1:	44 89 c0             	mov    %r8d,%eax
  8041602da4:	83 e0 7f             	and    $0x7f,%eax
  8041602da7:	d3 e0                	shl    %cl,%eax
  8041602da9:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602dab:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602dae:	45 84 c0             	test   %r8b,%r8b
  8041602db1:	78 e2                	js     8041602d95 <naive_address_by_fname+0x24b>
  return count;
  8041602db3:	4d 63 c1             	movslq %r9d,%r8
        curr_abbrev_entry += count;
  8041602db6:	49 01 d0             	add    %rdx,%r8
  8041602db9:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041602dbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041602dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602dc6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602dcc:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602dcf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602dd3:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041602dd6:	89 f8                	mov    %edi,%eax
  8041602dd8:	83 e0 7f             	and    $0x7f,%eax
  8041602ddb:	d3 e0                	shl    %cl,%eax
  8041602ddd:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602de0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602de3:	40 84 ff             	test   %dil,%dil
  8041602de6:	78 e4                	js     8041602dcc <naive_address_by_fname+0x282>
  return count;
  8041602de8:	48 63 db             	movslq %ebx,%rbx
        curr_abbrev_entry++;
  8041602deb:	49 8d 54 18 01       	lea    0x1(%r8,%rbx,1),%rdx
        if (table_abbrev_code == abbrev_code) {
  8041602df0:	41 39 f2             	cmp    %esi,%r10d
  8041602df3:	0f 85 14 ff ff ff    	jne    8041602d0d <naive_address_by_fname+0x1c3>
  8041602df9:	48 89 d3             	mov    %rdx,%rbx
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602dfc:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602e00:	0f 84 fd 00 00 00    	je     8041602f03 <naive_address_by_fname+0x3b9>
  8041602e06:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602e0a:	0f 84 f3 00 00 00    	je     8041602f03 <naive_address_by_fname+0x3b9>
                found = 1;
  8041602e10:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602e13:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602e18:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602e1d:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602e23:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602e26:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602e2a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602e2d:	89 f0                	mov    %esi,%eax
  8041602e2f:	83 e0 7f             	and    $0x7f,%eax
  8041602e32:	d3 e0                	shl    %cl,%eax
  8041602e34:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602e37:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602e3a:	40 84 f6             	test   %sil,%sil
  8041602e3d:	78 e4                	js     8041602e23 <naive_address_by_fname+0x2d9>
  return count;
  8041602e3f:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602e42:	48 01 fb             	add    %rdi,%rbx
  8041602e45:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602e48:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602e4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602e52:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602e58:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602e5b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602e5f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602e62:	89 f0                	mov    %esi,%eax
  8041602e64:	83 e0 7f             	and    $0x7f,%eax
  8041602e67:	d3 e0                	shl    %cl,%eax
  8041602e69:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602e6c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602e6f:	40 84 f6             	test   %sil,%sil
  8041602e72:	78 e4                	js     8041602e58 <naive_address_by_fname+0x30e>
  return count;
  8041602e74:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602e77:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041602e7a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602e80:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602e85:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602e8a:	44 89 e6             	mov    %r12d,%esi
  8041602e8d:	4c 89 ff             	mov    %r15,%rdi
  8041602e90:	41 ff d6             	callq  *%r14
          entry += count;
  8041602e93:	48 98                	cltq   
  8041602e95:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041602e98:	45 09 ec             	or     %r13d,%r12d
  8041602e9b:	0f 85 6f ff ff ff    	jne    8041602e10 <naive_address_by_fname+0x2c6>
    while (entry < entry_end) {
  8041602ea1:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  8041602ea5:	0f 86 da fc ff ff    	jbe    8041602b85 <naive_address_by_fname+0x3b>
  8041602eab:	4c 89 fa             	mov    %r15,%rdx
  8041602eae:	bf 00 00 00 00       	mov    $0x0,%edi
  8041602eb3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602eb8:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602ebe:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ec1:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ec5:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602ec8:	89 f0                	mov    %esi,%eax
  8041602eca:	83 e0 7f             	and    $0x7f,%eax
  8041602ecd:	d3 e0                	shl    %cl,%eax
  8041602ecf:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602ed2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ed5:	40 84 f6             	test   %sil,%sil
  8041602ed8:	78 e4                	js     8041602ebe <naive_address_by_fname+0x374>
  return count;
  8041602eda:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  8041602edd:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  8041602ee0:	45 85 d2             	test   %r10d,%r10d
  8041602ee3:	0f 84 ac 01 00 00    	je     8041603095 <naive_address_by_fname+0x54b>
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602ee9:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602eed:	4c 8b 58 08          	mov    0x8(%rax),%r11
  8041602ef1:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602ef5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8041602efb:	48 89 da             	mov    %rbx,%rdx
  8041602efe:	e9 7a fe ff ff       	jmpq   8041602d7d <naive_address_by_fname+0x233>
        uintptr_t low_pc = 0;
  8041602f03:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602f0a:	00 
        int found        = 0;
  8041602f0b:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041602f12:	eb 6c                	jmp    8041602f80 <naive_address_by_fname+0x436>
            count = dwarf_read_abbrev_entry(
  8041602f14:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f1a:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602f1f:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602f23:	44 89 ee             	mov    %r13d,%esi
  8041602f26:	4c 89 ff             	mov    %r15,%rdi
  8041602f29:	41 ff d6             	callq  *%r14
  8041602f2c:	eb 44                	jmp    8041602f72 <naive_address_by_fname+0x428>
            if (form == DW_FORM_strp) {
  8041602f2e:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041602f32:	0f 84 e4 00 00 00    	je     804160301c <naive_address_by_fname+0x4d2>
              if (!strcmp(fname, entry)) {
  8041602f38:	4c 89 fe             	mov    %r15,%rsi
  8041602f3b:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041602f3f:	48 b8 06 50 60 41 80 	movabs $0x8041605006,%rax
  8041602f46:	00 00 00 
  8041602f49:	ff d0                	callq  *%rax
                found = 1;
  8041602f4b:	85 c0                	test   %eax,%eax
  8041602f4d:	b8 01 00 00 00       	mov    $0x1,%eax
  8041602f52:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041602f56:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  8041602f59:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602f64:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602f69:	44 89 ee             	mov    %r13d,%esi
  8041602f6c:	4c 89 ff             	mov    %r15,%rdi
  8041602f6f:	41 ff d6             	callq  *%r14
          entry += count;
  8041602f72:	48 98                	cltq   
  8041602f74:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041602f77:	45 09 e5             	or     %r12d,%r13d
  8041602f7a:	0f 84 f6 00 00 00    	je     8041603076 <naive_address_by_fname+0x52c>
        int found        = 0;
  8041602f80:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f83:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f88:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f8d:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602f93:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f96:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f9a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f9d:	89 f0                	mov    %esi,%eax
  8041602f9f:	83 e0 7f             	and    $0x7f,%eax
  8041602fa2:	d3 e0                	shl    %cl,%eax
  8041602fa4:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602fa7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602faa:	40 84 f6             	test   %sil,%sil
  8041602fad:	78 e4                	js     8041602f93 <naive_address_by_fname+0x449>
  return count;
  8041602faf:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fb2:	48 01 fb             	add    %rdi,%rbx
  8041602fb5:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fb8:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fc2:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602fc8:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fcb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602fcf:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602fd2:	89 f0                	mov    %esi,%eax
  8041602fd4:	83 e0 7f             	and    $0x7f,%eax
  8041602fd7:	d3 e0                	shl    %cl,%eax
  8041602fd9:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602fdc:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602fdf:	40 84 f6             	test   %sil,%sil
  8041602fe2:	78 e4                	js     8041602fc8 <naive_address_by_fname+0x47e>
  return count;
  8041602fe4:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fe7:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  8041602fea:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602fee:	0f 84 20 ff ff ff    	je     8041602f14 <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  8041602ff4:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602ff8:	0f 84 30 ff ff ff    	je     8041602f2e <naive_address_by_fname+0x3e4>
            count = dwarf_read_abbrev_entry(
  8041602ffe:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603004:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603009:	ba 00 00 00 00       	mov    $0x0,%edx
  804160300e:	44 89 ee             	mov    %r13d,%esi
  8041603011:	4c 89 ff             	mov    %r15,%rdi
  8041603014:	41 ff d6             	callq  *%r14
  8041603017:	e9 56 ff ff ff       	jmpq   8041602f72 <naive_address_by_fname+0x428>
                  str_offset = 0;
  804160301c:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041603023:	00 
              count          = dwarf_read_abbrev_entry(
  8041603024:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160302a:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160302f:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041603033:	be 0e 00 00 00       	mov    $0xe,%esi
  8041603038:	4c 89 ff             	mov    %r15,%rdi
  804160303b:	41 ff d6             	callq  *%r14
  804160303e:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  8041603041:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041603045:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603049:	48 03 70 40          	add    0x40(%rax),%rsi
  804160304d:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041603051:	48 b8 06 50 60 41 80 	movabs $0x8041605006,%rax
  8041603058:	00 00 00 
  804160305b:	ff d0                	callq  *%rax
                found = 1;
  804160305d:	85 c0                	test   %eax,%eax
  804160305f:	b8 01 00 00 00       	mov    $0x1,%eax
  8041603064:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603068:	89 45 bc             	mov    %eax,-0x44(%rbp)
          entry += count;
  804160306b:	4d 63 e4             	movslq %r12d,%r12
  804160306e:	4d 01 e7             	add    %r12,%r15
  8041603071:	e9 0a ff ff ff       	jmpq   8041602f80 <naive_address_by_fname+0x436>
        if (found) {
  8041603076:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  804160307a:	0f 84 21 fe ff ff    	je     8041602ea1 <naive_address_by_fname+0x357>
          *offset = low_pc;
  8041603080:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041603084:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  8041603088:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  804160308b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603090:	e9 e3 fb ff ff       	jmpq   8041602c78 <naive_address_by_fname+0x12e>
      entry += count;
  8041603095:	4c 89 fa             	mov    %r15,%rdx
    while (entry < entry_end) {
  8041603098:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  804160309c:	0f 87 0c fe ff ff    	ja     8041602eae <naive_address_by_fname+0x364>
  80416030a2:	e9 de fa ff ff       	jmpq   8041602b85 <naive_address_by_fname+0x3b>
    return 0;
  80416030a7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416030ac:	e9 c7 fb ff ff       	jmpq   8041602c78 <naive_address_by_fname+0x12e>

00000080416030b1 <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  80416030b1:	55                   	push   %rbp
  80416030b2:	48 89 e5             	mov    %rsp,%rbp
  80416030b5:	41 57                	push   %r15
  80416030b7:	41 56                	push   %r14
  80416030b9:	41 55                	push   %r13
  80416030bb:	41 54                	push   %r12
  80416030bd:	53                   	push   %rbx
  80416030be:	48 83 ec 48          	sub    $0x48,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  80416030c2:	4c 8b 67 30          	mov    0x30(%rdi),%r12
  80416030c6:	48 8b 47 38          	mov    0x38(%rdi),%rax
  80416030ca:	4c 29 e0             	sub    %r12,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  80416030cd:	48 39 d0             	cmp    %rdx,%rax
  80416030d0:	0f 82 3b 07 00 00    	jb     8041603811 <line_for_address+0x760>
  80416030d6:	48 85 c9             	test   %rcx,%rcx
  80416030d9:	0f 84 32 07 00 00    	je     8041603811 <line_for_address+0x760>
  80416030df:	48 89 4d 98          	mov    %rcx,-0x68(%rbp)
  80416030e3:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  80416030e7:	49 01 d4             	add    %rdx,%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416030ea:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030ef:	4c 89 e6             	mov    %r12,%rsi
  80416030f2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030f6:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416030fd:	00 00 00 
  8041603100:	ff d0                	callq  *%rax
  8041603102:	8b 55 c8             	mov    -0x38(%rbp),%edx
    *len = initial_len;
  8041603105:	41 89 d7             	mov    %edx,%r15d
  count       = 4;
  8041603108:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160310d:	83 fa ef             	cmp    $0xffffffef,%edx
  8041603110:	0f 87 2c 01 00 00    	ja     8041603242 <line_for_address+0x191>
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    curr_addr += count;
  8041603116:	48 98                	cltq   
  8041603118:	49 01 c4             	add    %rax,%r12
  }
  const void *unit_end = curr_addr + unit_length;
  804160311b:	4d 01 e7             	add    %r12,%r15
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  804160311e:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603123:	4c 89 e6             	mov    %r12,%rsi
  8041603126:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160312a:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603131:	00 00 00 
  8041603134:	ff d0                	callq  *%rax
  8041603136:	44 0f b7 75 c8       	movzwl -0x38(%rbp),%r14d
  curr_addr += sizeof(Dwarf_Half);
  804160313b:	4d 8d 6c 24 02       	lea    0x2(%r12),%r13
  assert(version == 4 || version == 3 || version == 2);
  8041603140:	41 8d 46 fe          	lea    -0x2(%r14),%eax
  8041603144:	66 83 f8 02          	cmp    $0x2,%ax
  8041603148:	0f 87 50 01 00 00    	ja     804160329e <line_for_address+0x1ed>
  initial_len = get_unaligned(addr, uint32_t);
  804160314e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603153:	4c 89 ee             	mov    %r13,%rsi
  8041603156:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160315a:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603161:	00 00 00 
  8041603164:	ff d0                	callq  *%rax
  8041603166:	8b 55 c8             	mov    -0x38(%rbp),%edx
    *len = initial_len;
  8041603169:	89 d3                	mov    %edx,%ebx
  count       = 4;
  804160316b:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603170:	83 fa ef             	cmp    $0xffffffef,%edx
  8041603173:	0f 87 5a 01 00 00    	ja     80416032d3 <line_for_address+0x222>
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    curr_addr += count;
  8041603179:	48 98                	cltq   
  804160317b:	49 01 c5             	add    %rax,%r13
  }
  const void *program_addr = curr_addr + header_length;
  804160317e:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  8041603181:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603186:	4c 89 ee             	mov    %r13,%rsi
  8041603189:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160318d:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603194:	00 00 00 
  8041603197:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  8041603199:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160319d:	0f 85 82 01 00 00    	jne    8041603325 <line_for_address+0x274>
  curr_addr += sizeof(Dwarf_Small);
  80416031a3:	4d 8d 65 01          	lea    0x1(%r13),%r12
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  80416031a7:	66 41 83 fe 04       	cmp    $0x4,%r14w
  80416031ac:	0f 84 a8 01 00 00    	je     804160335a <line_for_address+0x2a9>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  80416031b2:	49 8d 74 24 01       	lea    0x1(%r12),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  80416031b7:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031bc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031c0:	49 be 9a 51 60 41 80 	movabs $0x804160519a,%r14
  80416031c7:	00 00 00 
  80416031ca:	41 ff d6             	callq  *%r14
  80416031cd:	44 0f b6 6d c8       	movzbl -0x38(%rbp),%r13d
  curr_addr += sizeof(signed char);
  80416031d2:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  80416031d7:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031dc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031e0:	41 ff d6             	callq  *%r14
  80416031e3:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416031e7:	88 45 be             	mov    %al,-0x42(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416031ea:	49 8d 74 24 03       	lea    0x3(%r12),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  80416031ef:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031f4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031f8:	41 ff d6             	callq  *%r14
  80416031fb:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416031ff:	88 45 bf             	mov    %al,-0x41(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  8041603202:	49 8d 74 24 04       	lea    0x4(%r12),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  8041603207:	ba 08 00 00 00       	mov    $0x8,%edx
  804160320c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603210:	41 ff d6             	callq  *%r14
  while (program_addr < end_addr) {
  8041603213:	49 39 df             	cmp    %rbx,%r15
  8041603216:	0f 86 c3 05 00 00    	jbe    80416037df <line_for_address+0x72e>
  804160321c:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  8041603223:	41 be 00 00 00 00    	mov    $0x0,%r14d
      state->line += (info->line_base +
  8041603229:	41 0f be f5          	movsbl %r13b,%esi
  804160322d:	89 75 a4             	mov    %esi,-0x5c(%rbp)
          Dwarf_Small adjusted_opcode =
  8041603230:	0f b6 45 bf          	movzbl -0x41(%rbp),%eax
  8041603234:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  8041603236:	0f b6 c0             	movzbl %al,%eax
  8041603239:	66 89 45 bc          	mov    %ax,-0x44(%rbp)
  804160323d:	e9 4e 02 00 00       	jmpq   8041603490 <line_for_address+0x3df>
    if (initial_len == DW_EXT_DWARF64) {
  8041603242:	83 fa ff             	cmp    $0xffffffff,%edx
  8041603245:	74 2f                	je     8041603276 <line_for_address+0x1c5>
      cprintf("Unknown DWARF extension\n");
  8041603247:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  804160324e:	00 00 00 
  8041603251:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603256:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  804160325d:	00 00 00 
  8041603260:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  8041603262:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                          p);

  *lineno_store = current_state.line;

  return 0;
}
  8041603267:	48 83 c4 48          	add    $0x48,%rsp
  804160326b:	5b                   	pop    %rbx
  804160326c:	41 5c                	pop    %r12
  804160326e:	41 5d                	pop    %r13
  8041603270:	41 5e                	pop    %r14
  8041603272:	41 5f                	pop    %r15
  8041603274:	5d                   	pop    %rbp
  8041603275:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603276:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  804160327b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603280:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603284:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160328b:	00 00 00 
  804160328e:	ff d0                	callq  *%rax
  8041603290:	4c 8b 7d c8          	mov    -0x38(%rbp),%r15
      count = 12;
  8041603294:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041603299:	e9 78 fe ff ff       	jmpq   8041603116 <line_for_address+0x65>
  assert(version == 4 || version == 3 || version == 2);
  804160329e:	48 b9 48 59 60 41 80 	movabs $0x8041605948,%rcx
  80416032a5:	00 00 00 
  80416032a8:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  80416032af:	00 00 00 
  80416032b2:	be fc 00 00 00       	mov    $0xfc,%esi
  80416032b7:	48 bf 01 59 60 41 80 	movabs $0x8041605901,%rdi
  80416032be:	00 00 00 
  80416032c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032c6:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416032cd:	00 00 00 
  80416032d0:	41 ff d0             	callq  *%r8
    if (initial_len == DW_EXT_DWARF64) {
  80416032d3:	83 fa ff             	cmp    $0xffffffff,%edx
  80416032d6:	74 25                	je     80416032fd <line_for_address+0x24c>
      cprintf("Unknown DWARF extension\n");
  80416032d8:	48 bf 20 57 60 41 80 	movabs $0x8041605720,%rdi
  80416032df:	00 00 00 
  80416032e2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032e7:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416032ee:	00 00 00 
  80416032f1:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  80416032f3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416032f8:	e9 6a ff ff ff       	jmpq   8041603267 <line_for_address+0x1b6>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416032fd:	49 8d 74 24 22       	lea    0x22(%r12),%rsi
  8041603302:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603307:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160330b:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603312:	00 00 00 
  8041603315:	ff d0                	callq  *%rax
  8041603317:	48 8b 5d c8          	mov    -0x38(%rbp),%rbx
      count = 12;
  804160331b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041603320:	e9 54 fe ff ff       	jmpq   8041603179 <line_for_address+0xc8>
  assert(minimum_instruction_length == 1);
  8041603325:	48 b9 78 59 60 41 80 	movabs $0x8041605978,%rcx
  804160332c:	00 00 00 
  804160332f:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041603336:	00 00 00 
  8041603339:	be 07 01 00 00       	mov    $0x107,%esi
  804160333e:	48 bf 01 59 60 41 80 	movabs $0x8041605901,%rdi
  8041603345:	00 00 00 
  8041603348:	b8 00 00 00 00       	mov    $0x0,%eax
  804160334d:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041603354:	00 00 00 
  8041603357:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  804160335a:	ba 01 00 00 00       	mov    $0x1,%edx
  804160335f:	4c 89 e6             	mov    %r12,%rsi
  8041603362:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603366:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160336d:	00 00 00 
  8041603370:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  8041603372:	4d 8d 65 02          	lea    0x2(%r13),%r12
  assert(maximum_operations_per_instruction == 1);
  8041603376:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160337a:	0f 84 32 fe ff ff    	je     80416031b2 <line_for_address+0x101>
  8041603380:	48 b9 98 59 60 41 80 	movabs $0x8041605998,%rcx
  8041603387:	00 00 00 
  804160338a:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  8041603391:	00 00 00 
  8041603394:	be 11 01 00 00       	mov    $0x111,%esi
  8041603399:	48 bf 01 59 60 41 80 	movabs $0x8041605901,%rdi
  80416033a0:	00 00 00 
  80416033a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033a8:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416033af:	00 00 00 
  80416033b2:	41 ff d0             	callq  *%r8
      switch (opcode) {
  80416033b5:	80 f9 01             	cmp    $0x1,%cl
  80416033b8:	0f 85 98 01 00 00    	jne    8041603556 <line_for_address+0x4a5>
          if (last_state.address <= destination_addr &&
  80416033be:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416033c2:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  80416033c6:	48 39 f0             	cmp    %rsi,%rax
  80416033c9:	0f 82 b5 01 00 00    	jb     8041603584 <line_for_address+0x4d3>
  80416033cf:	4c 39 f0             	cmp    %r14,%rax
  80416033d2:	0f 82 10 04 00 00    	jb     80416037e8 <line_for_address+0x737>
          last_state           = *state;
  80416033d8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416033db:	89 45 a0             	mov    %eax,-0x60(%rbp)
  80416033de:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
          state->line          = 1;
  80416033e2:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
          state->address       = 0;
  80416033e9:	41 be 00 00 00 00    	mov    $0x0,%r14d
  80416033ef:	e9 8a 00 00 00       	jmpq   804160347e <line_for_address+0x3cd>
          while (*(char *)program_addr) {
  80416033f4:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  80416033f9:	74 09                	je     8041603404 <line_for_address+0x353>
            ++program_addr;
  80416033fb:	48 83 c3 01          	add    $0x1,%rbx
          while (*(char *)program_addr) {
  80416033ff:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603402:	75 f7                	jne    80416033fb <line_for_address+0x34a>
          ++program_addr;
  8041603404:	48 83 c3 01          	add    $0x1,%rbx
  8041603408:	48 89 d8             	mov    %rbx,%rax
  count  = 0;
  804160340b:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603410:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603413:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603417:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  804160341a:	84 c9                	test   %cl,%cl
  804160341c:	78 f2                	js     8041603410 <line_for_address+0x35f>
  return count;
  804160341e:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  8041603421:	48 01 d3             	add    %rdx,%rbx
  8041603424:	48 89 d8             	mov    %rbx,%rax
  count  = 0;
  8041603427:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  804160342c:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  804160342f:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603433:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041603436:	84 c9                	test   %cl,%cl
  8041603438:	78 f2                	js     804160342c <line_for_address+0x37b>
  return count;
  804160343a:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  804160343d:	48 01 d3             	add    %rdx,%rbx
  8041603440:	48 89 d8             	mov    %rbx,%rax
  count  = 0;
  8041603443:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603448:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  804160344b:	48 83 c0 01          	add    $0x1,%rax
    count++;
  804160344f:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041603452:	84 c9                	test   %cl,%cl
  8041603454:	78 f2                	js     8041603448 <line_for_address+0x397>
  return count;
  8041603456:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  8041603459:	48 01 d3             	add    %rdx,%rbx
  804160345c:	eb 20                	jmp    804160347e <line_for_address+0x3cd>
              get_unaligned(program_addr, uintptr_t);
  804160345e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603463:	48 89 de             	mov    %rbx,%rsi
  8041603466:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160346a:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603471:	00 00 00 
  8041603474:	ff d0                	callq  *%rax
  8041603476:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
          program_addr += sizeof(uintptr_t);
  804160347a:	49 8d 5d 09          	lea    0x9(%r13),%rbx
      assert(program_addr == opcode_end);
  804160347e:	49 39 dc             	cmp    %rbx,%r12
  8041603481:	0f 85 19 01 00 00    	jne    80416035a0 <line_for_address+0x4ef>
  while (program_addr < end_addr) {
  8041603487:	49 39 df             	cmp    %rbx,%r15
  804160348a:	0f 86 6e 03 00 00    	jbe    80416037fe <line_for_address+0x74d>
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  8041603490:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603495:	48 89 de             	mov    %rbx,%rsi
  8041603498:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160349c:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  80416034a3:	00 00 00 
  80416034a6:	ff d0                	callq  *%rax
  80416034a8:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  80416034ac:	48 8d 73 01          	lea    0x1(%rbx),%rsi
    if (opcode == 0) {
  80416034b0:	84 c0                	test   %al,%al
  80416034b2:	0f 85 1d 01 00 00    	jne    80416035d5 <line_for_address+0x524>
  80416034b8:	48 89 f2             	mov    %rsi,%rdx
  80416034bb:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  80416034c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416034c6:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416034cc:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416034cf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416034d3:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  80416034d7:	89 f8                	mov    %edi,%eax
  80416034d9:	83 e0 7f             	and    $0x7f,%eax
  80416034dc:	d3 e0                	shl    %cl,%eax
  80416034de:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416034e1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416034e4:	40 84 ff             	test   %dil,%dil
  80416034e7:	78 e3                	js     80416034cc <line_for_address+0x41b>
  return count;
  80416034e9:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  80416034ec:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  80416034ef:	45 89 e4             	mov    %r12d,%r12d
  80416034f2:	4d 01 ec             	add    %r13,%r12
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  80416034f5:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034fa:	4c 89 ee             	mov    %r13,%rsi
  80416034fd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603501:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603508:	00 00 00 
  804160350b:	ff d0                	callq  *%rax
  804160350d:	0f b6 4d c8          	movzbl -0x38(%rbp),%ecx
      program_addr += sizeof(Dwarf_Small);
  8041603511:	49 8d 5d 01          	lea    0x1(%r13),%rbx
      switch (opcode) {
  8041603515:	80 f9 02             	cmp    $0x2,%cl
  8041603518:	0f 84 40 ff ff ff    	je     804160345e <line_for_address+0x3ad>
  804160351e:	80 f9 02             	cmp    $0x2,%cl
  8041603521:	0f 86 8e fe ff ff    	jbe    80416033b5 <line_for_address+0x304>
  8041603527:	80 f9 03             	cmp    $0x3,%cl
  804160352a:	0f 84 c4 fe ff ff    	je     80416033f4 <line_for_address+0x343>
  8041603530:	80 f9 04             	cmp    $0x4,%cl
  8041603533:	75 21                	jne    8041603556 <line_for_address+0x4a5>
  8041603535:	48 89 d8             	mov    %rbx,%rax
  8041603538:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  804160353d:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603540:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603544:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041603547:	84 c9                	test   %cl,%cl
  8041603549:	78 f2                	js     804160353d <line_for_address+0x48c>
  return count;
  804160354b:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  804160354e:	48 01 d3             	add    %rdx,%rbx
  8041603551:	e9 28 ff ff ff       	jmpq   804160347e <line_for_address+0x3cd>
      switch (opcode) {
  8041603556:	0f b6 c9             	movzbl %cl,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603559:	48 ba 14 59 60 41 80 	movabs $0x8041605914,%rdx
  8041603560:	00 00 00 
  8041603563:	be 6b 00 00 00       	mov    $0x6b,%esi
  8041603568:	48 bf 01 59 60 41 80 	movabs $0x8041605901,%rdi
  804160356f:	00 00 00 
  8041603572:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603577:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  804160357e:	00 00 00 
  8041603581:	41 ff d0             	callq  *%r8
          last_state           = *state;
  8041603584:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041603587:	89 45 a0             	mov    %eax,-0x60(%rbp)
  804160358a:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
          state->line          = 1;
  804160358e:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
          state->address       = 0;
  8041603595:	41 be 00 00 00 00    	mov    $0x0,%r14d
  804160359b:	e9 de fe ff ff       	jmpq   804160347e <line_for_address+0x3cd>
      assert(program_addr == opcode_end);
  80416035a0:	48 b9 27 59 60 41 80 	movabs $0x8041605927,%rcx
  80416035a7:	00 00 00 
  80416035aa:	48 ba 39 57 60 41 80 	movabs $0x8041605739,%rdx
  80416035b1:	00 00 00 
  80416035b4:	be 6e 00 00 00       	mov    $0x6e,%esi
  80416035b9:	48 bf 01 59 60 41 80 	movabs $0x8041605901,%rdi
  80416035c0:	00 00 00 
  80416035c3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416035c8:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  80416035cf:	00 00 00 
  80416035d2:	41 ff d0             	callq  *%r8
    } else if (opcode < info->opcode_base) {
  80416035d5:	38 45 bf             	cmp    %al,-0x41(%rbp)
  80416035d8:	0f 86 ab 01 00 00    	jbe    8041603789 <line_for_address+0x6d8>
      switch (opcode) {
  80416035de:	3c 0c                	cmp    $0xc,%al
  80416035e0:	0f 87 75 01 00 00    	ja     804160375b <line_for_address+0x6aa>
  80416035e6:	0f b6 d0             	movzbl %al,%edx
  80416035e9:	48 b9 c0 59 60 41 80 	movabs $0x80416059c0,%rcx
  80416035f0:	00 00 00 
  80416035f3:	ff 24 d1             	jmpq   *(%rcx,%rdx,8)
          if (last_state.address <= destination_addr &&
  80416035f6:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416035fa:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  80416035fe:	48 39 d8             	cmp    %rbx,%rax
  8041603601:	0f 82 c6 01 00 00    	jb     80416037cd <line_for_address+0x71c>
  8041603607:	4c 39 f0             	cmp    %r14,%rax
  804160360a:	0f 82 e0 01 00 00    	jb     80416037f0 <line_for_address+0x73f>
          last_state           = *state;
  8041603610:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041603613:	89 45 a0             	mov    %eax,-0x60(%rbp)
  8041603616:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
    program_addr += sizeof(Dwarf_Small);
  804160361a:	48 89 f3             	mov    %rsi,%rbx
  804160361d:	e9 65 fe ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
      switch (opcode) {
  8041603622:	48 89 f2             	mov    %rsi,%rdx
  8041603625:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  804160362b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603630:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041603636:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041603639:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160363d:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041603641:	89 f8                	mov    %edi,%eax
  8041603643:	83 e0 7f             	and    $0x7f,%eax
  8041603646:	d3 e0                	shl    %cl,%eax
  8041603648:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160364b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160364e:	40 84 ff             	test   %dil,%dil
  8041603651:	78 e3                	js     8041603636 <line_for_address+0x585>
              info->minimum_instruction_length *
  8041603653:	45 89 c9             	mov    %r9d,%r9d
          state->address +=
  8041603656:	4d 01 ce             	add    %r9,%r14
  return count;
  8041603659:	4d 63 c0             	movslq %r8d,%r8
          program_addr += count;
  804160365c:	4a 8d 1c 06          	lea    (%rsi,%r8,1),%rbx
  8041603660:	e9 22 fe ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
      switch (opcode) {
  8041603665:	48 89 f2             	mov    %rsi,%rdx
  8041603668:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  804160366e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603673:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041603679:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  804160367c:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  8041603680:	89 f8                	mov    %edi,%eax
  8041603682:	83 e0 7f             	and    $0x7f,%eax
  8041603685:	d3 e0                	shl    %cl,%eax
  8041603687:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160368a:	83 c1 07             	add    $0x7,%ecx
    count++;
  804160368d:	41 83 c0 01          	add    $0x1,%r8d
    if (!(byte & 0x80))
  8041603691:	40 84 ff             	test   %dil,%dil
  8041603694:	78 e3                	js     8041603679 <line_for_address+0x5c8>
  if ((shift < num_bits) && (byte & 0x40))
  8041603696:	83 f9 1f             	cmp    $0x1f,%ecx
  8041603699:	7f 10                	jg     80416036ab <line_for_address+0x5fa>
  804160369b:	40 f6 c7 40          	test   $0x40,%dil
  804160369f:	74 0a                	je     80416036ab <line_for_address+0x5fa>
    result |= (-1U << shift);
  80416036a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416036a6:	d3 e0                	shl    %cl,%eax
  80416036a8:	41 09 c1             	or     %eax,%r9d
          state->line += line_incr;
  80416036ab:	44 01 4d b8          	add    %r9d,-0x48(%rbp)
  return count;
  80416036af:	4d 63 c0             	movslq %r8d,%r8
          program_addr += count;
  80416036b2:	4a 8d 1c 06          	lea    (%rsi,%r8,1),%rbx
  80416036b6:	e9 cc fd ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
      switch (opcode) {
  80416036bb:	48 89 f0             	mov    %rsi,%rax
  80416036be:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416036c3:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  80416036c6:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416036ca:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  80416036cd:	84 c9                	test   %cl,%cl
  80416036cf:	78 f2                	js     80416036c3 <line_for_address+0x612>
  return count;
  80416036d1:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  80416036d4:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
  80416036d8:	e9 aa fd ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
      switch (opcode) {
  80416036dd:	48 89 f0             	mov    %rsi,%rax
  80416036e0:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416036e5:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  80416036e8:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416036ec:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  80416036ef:	84 c9                	test   %cl,%cl
  80416036f1:	78 f2                	js     80416036e5 <line_for_address+0x634>
  return count;
  80416036f3:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  80416036f6:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
  80416036fa:	e9 88 fd ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
              adjusted_opcode / info->line_range;
  80416036ff:	0f b7 45 bc          	movzwl -0x44(%rbp),%eax
  8041603703:	f6 75 be             	divb   -0x42(%rbp)
              info->minimum_instruction_length *
  8041603706:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  8041603709:	49 01 c6             	add    %rax,%r14
    program_addr += sizeof(Dwarf_Small);
  804160370c:	48 89 f3             	mov    %rsi,%rbx
  804160370f:	e9 73 fd ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
              get_unaligned(program_addr, Dwarf_Half);
  8041603714:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603719:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160371d:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603724:	00 00 00 
  8041603727:	ff d0                	callq  *%rax
          state->address += pc_inc;
  8041603729:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  804160372d:	49 01 c6             	add    %rax,%r14
          program_addr += sizeof(Dwarf_Half);
  8041603730:	48 83 c3 03          	add    $0x3,%rbx
  8041603734:	e9 4e fd ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
      switch (opcode) {
  8041603739:	48 89 f0             	mov    %rsi,%rax
  804160373c:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603741:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603744:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603748:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  804160374b:	84 c9                	test   %cl,%cl
  804160374d:	78 f2                	js     8041603741 <line_for_address+0x690>
  return count;
  804160374f:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  8041603752:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
  8041603756:	e9 2c fd ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
      switch (opcode) {
  804160375b:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  804160375e:	48 ba 14 59 60 41 80 	movabs $0x8041605914,%rdx
  8041603765:	00 00 00 
  8041603768:	be c1 00 00 00       	mov    $0xc1,%esi
  804160376d:	48 bf 01 59 60 41 80 	movabs $0x8041605901,%rdi
  8041603774:	00 00 00 
  8041603777:	b8 00 00 00 00       	mov    $0x0,%eax
  804160377c:	49 b8 7e 03 60 41 80 	movabs $0x804160037e,%r8
  8041603783:	00 00 00 
  8041603786:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  8041603789:	2a 45 bf             	sub    -0x41(%rbp),%al
                      (adjusted_opcode % info->line_range));
  804160378c:	0f b6 c0             	movzbl %al,%eax
  804160378f:	f6 75 be             	divb   -0x42(%rbp)
  8041603792:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  8041603795:	03 55 a4             	add    -0x5c(%rbp),%edx
  8041603798:	01 55 b8             	add    %edx,-0x48(%rbp)
          info->minimum_instruction_length *
  804160379b:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  804160379e:	49 01 c6             	add    %rax,%r14
      if (last_state.address <= destination_addr &&
  80416037a1:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416037a5:	4c 39 f0             	cmp    %r14,%rax
  80416037a8:	73 09                	jae    80416037b3 <line_for_address+0x702>
  80416037aa:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  80416037ae:	48 39 d8             	cmp    %rbx,%rax
  80416037b1:	73 45                	jae    80416037f8 <line_for_address+0x747>
      last_state = *state;
  80416037b3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416037b6:	89 45 a0             	mov    %eax,-0x60(%rbp)
  80416037b9:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
    program_addr += sizeof(Dwarf_Small);
  80416037bd:	48 89 f3             	mov    %rsi,%rbx
  80416037c0:	e9 c2 fc ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
  80416037c5:	48 89 f3             	mov    %rsi,%rbx
  80416037c8:	e9 ba fc ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
          last_state           = *state;
  80416037cd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416037d0:	89 45 a0             	mov    %eax,-0x60(%rbp)
  80416037d3:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
    program_addr += sizeof(Dwarf_Small);
  80416037d7:	48 89 f3             	mov    %rsi,%rbx
  80416037da:	e9 a8 fc ff ff       	jmpq   8041603487 <line_for_address+0x3d6>
  struct Line_Number_State current_state = {
  80416037df:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  80416037e6:	eb 16                	jmp    80416037fe <line_for_address+0x74d>
          if (last_state.address <= destination_addr &&
  80416037e8:	8b 45 a0             	mov    -0x60(%rbp),%eax
  80416037eb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416037ee:	eb 0e                	jmp    80416037fe <line_for_address+0x74d>
          if (last_state.address <= destination_addr &&
  80416037f0:	8b 45 a0             	mov    -0x60(%rbp),%eax
  80416037f3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416037f6:	eb 06                	jmp    80416037fe <line_for_address+0x74d>
      if (last_state.address <= destination_addr &&
  80416037f8:	8b 45 a0             	mov    -0x60(%rbp),%eax
  80416037fb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  *lineno_store = current_state.line;
  80416037fe:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041603802:	8b 75 b8             	mov    -0x48(%rbp),%esi
  8041603805:	89 30                	mov    %esi,(%rax)
  return 0;
  8041603807:	b8 00 00 00 00       	mov    $0x0,%eax
  804160380c:	e9 56 fa ff ff       	jmpq   8041603267 <line_for_address+0x1b6>
    return -E_INVAL;
  8041603811:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041603816:	e9 4c fa ff ff       	jmpq   8041603267 <line_for_address+0x1b6>

000000804160381b <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  804160381b:	55                   	push   %rbp
  804160381c:	48 89 e5             	mov    %rsp,%rbp
  804160381f:	41 55                	push   %r13
  8041603821:	41 54                	push   %r12
  8041603823:	53                   	push   %rbx
  8041603824:	48 83 ec 08          	sub    $0x8,%rsp
  8041603828:	48 bb 20 5d 60 41 80 	movabs $0x8041605d20,%rbx
  804160382f:	00 00 00 
  8041603832:	49 bd 98 5d 60 41 80 	movabs $0x8041605d98,%r13
  8041603839:	00 00 00 
  int i;

  for (i = 0; i < NCOMMANDS; i++)
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  804160383c:	49 bc 0b 41 60 41 80 	movabs $0x804160410b,%r12
  8041603843:	00 00 00 
  8041603846:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  804160384a:	48 8b 33             	mov    (%rbx),%rsi
  804160384d:	48 bf 28 5a 60 41 80 	movabs $0x8041605a28,%rdi
  8041603854:	00 00 00 
  8041603857:	b8 00 00 00 00       	mov    $0x0,%eax
  804160385c:	41 ff d4             	callq  *%r12
  804160385f:	48 83 c3 18          	add    $0x18,%rbx
  for (i = 0; i < NCOMMANDS; i++)
  8041603863:	4c 39 eb             	cmp    %r13,%rbx
  8041603866:	75 de                	jne    8041603846 <mon_help+0x2b>
  return 0;
}
  8041603868:	b8 00 00 00 00       	mov    $0x0,%eax
  804160386d:	48 83 c4 08          	add    $0x8,%rsp
  8041603871:	5b                   	pop    %rbx
  8041603872:	41 5c                	pop    %r12
  8041603874:	41 5d                	pop    %r13
  8041603876:	5d                   	pop    %rbp
  8041603877:	c3                   	retq   

0000008041603878 <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  8041603878:	55                   	push   %rbp
  8041603879:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  804160387c:	48 bf 31 5a 60 41 80 	movabs $0x8041605a31,%rdi
  8041603883:	00 00 00 
  8041603886:	b8 00 00 00 00       	mov    $0x0,%eax
  804160388b:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041603892:	00 00 00 
  8041603895:	ff d2                	callq  *%rdx
  return 0;
}
  8041603897:	b8 00 00 00 00       	mov    $0x0,%eax
  804160389c:	5d                   	pop    %rbp
  804160389d:	c3                   	retq   

000000804160389e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  804160389e:	55                   	push   %rbp
  804160389f:	48 89 e5             	mov    %rsp,%rbp
  80416038a2:	41 54                	push   %r12
  80416038a4:	53                   	push   %rbx
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  80416038a5:	48 bf 39 5a 60 41 80 	movabs $0x8041605a39,%rdi
  80416038ac:	00 00 00 
  80416038af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038b4:	48 bb 0b 41 60 41 80 	movabs $0x804160410b,%rbx
  80416038bb:	00 00 00 
  80416038be:	ff d3                	callq  *%rbx
  cprintf("  _head64                  %08lx (phys)\n",
  80416038c0:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  80416038c7:	00 00 00 
  80416038ca:	48 bf 80 5b 60 41 80 	movabs $0x8041605b80,%rdi
  80416038d1:	00 00 00 
  80416038d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038d9:	ff d3                	callq  *%rbx
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  80416038db:	49 bc 00 00 60 41 80 	movabs $0x8041600000,%r12
  80416038e2:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  80416038e5:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  80416038ec:	00 00 00 
  80416038ef:	4c 89 e6             	mov    %r12,%rsi
  80416038f2:	48 bf b0 5b 60 41 80 	movabs $0x8041605bb0,%rdi
  80416038f9:	00 00 00 
  80416038fc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603901:	ff d3                	callq  *%rbx
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603903:	48 ba 18 54 60 01 00 	movabs $0x1605418,%rdx
  804160390a:	00 00 00 
  804160390d:	48 be 18 54 60 41 80 	movabs $0x8041605418,%rsi
  8041603914:	00 00 00 
  8041603917:	48 bf d8 5b 60 41 80 	movabs $0x8041605bd8,%rdi
  804160391e:	00 00 00 
  8041603921:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603926:	ff d3                	callq  *%rbx
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603928:	48 ba 60 2f 62 01 00 	movabs $0x1622f60,%rdx
  804160392f:	00 00 00 
  8041603932:	48 be 60 2f 62 41 80 	movabs $0x8041622f60,%rsi
  8041603939:	00 00 00 
  804160393c:	48 bf 00 5c 60 41 80 	movabs $0x8041605c00,%rdi
  8041603943:	00 00 00 
  8041603946:	b8 00 00 00 00       	mov    $0x0,%eax
  804160394b:	ff d3                	callq  *%rbx
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  804160394d:	48 ba 00 60 62 01 00 	movabs $0x1626000,%rdx
  8041603954:	00 00 00 
  8041603957:	48 be 00 60 62 41 80 	movabs $0x8041626000,%rsi
  804160395e:	00 00 00 
  8041603961:	48 bf 28 5c 60 41 80 	movabs $0x8041605c28,%rdi
  8041603968:	00 00 00 
  804160396b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603970:	ff d3                	callq  *%rbx
          (unsigned long)end, (unsigned long)end - KERNBASE);
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603972:	48 be ff 63 62 41 80 	movabs $0x80416263ff,%rsi
  8041603979:	00 00 00 
  804160397c:	4c 29 e6             	sub    %r12,%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  804160397f:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603983:	48 bf 50 5c 60 41 80 	movabs $0x8041605c50,%rdi
  804160398a:	00 00 00 
  804160398d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603992:	ff d3                	callq  *%rbx
  return 0;
}
  8041603994:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603999:	5b                   	pop    %rbx
  804160399a:	41 5c                	pop    %r12
  804160399c:	5d                   	pop    %rbp
  804160399d:	c3                   	retq   

000000804160399e <mon_evenbeyond>:

int
mon_evenbeyond(int argc, char **argv, struct Trapframe *tf) {
  804160399e:	55                   	push   %rbp
  804160399f:	48 89 e5             	mov    %rsp,%rbp
  cprintf("My CPU load is OVER %o \n", 9000);
  80416039a2:	be 28 23 00 00       	mov    $0x2328,%esi
  80416039a7:	48 bf 52 5a 60 41 80 	movabs $0x8041605a52,%rdi
  80416039ae:	00 00 00 
  80416039b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039b6:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416039bd:	00 00 00 
  80416039c0:	ff d2                	callq  *%rdx
  return 0;
}
  80416039c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039c7:	5d                   	pop    %rbp
  80416039c8:	c3                   	retq   

00000080416039c9 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  80416039c9:	55                   	push   %rbp
  80416039ca:	48 89 e5             	mov    %rsp,%rbp
  80416039cd:	41 57                	push   %r15
  80416039cf:	41 56                	push   %r14
  80416039d1:	41 55                	push   %r13
  80416039d3:	41 54                	push   %r12
  80416039d5:	53                   	push   %rbx
  80416039d6:	48 81 ec 28 02 00 00 	sub    $0x228,%rsp
  uint64_t *rbp = 0x0;
  uint64_t rip  = 0x0;

  struct Ripdebuginfo info;

  cprintf("Stack backtrace:\n");
  80416039dd:	48 bf 6b 5a 60 41 80 	movabs $0x8041605a6b,%rdi
  80416039e4:	00 00 00 
  80416039e7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039ec:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  80416039f3:	00 00 00 
  80416039f6:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  80416039f8:	48 89 e8             	mov    %rbp,%rax
  rbp = (uint64_t *)read_rbp();
  rip = rbp[1];

  if (rbp == 0x0 || rip == 0x0) {
  80416039fb:	48 83 78 08 00       	cmpq   $0x0,0x8(%rax)
  8041603a00:	0f 84 a2 00 00 00    	je     8041603aa8 <mon_backtrace+0xdf>
  8041603a06:	48 89 c3             	mov    %rax,%rbx
  8041603a09:	48 85 c0             	test   %rax,%rax
  8041603a0c:	0f 84 96 00 00 00    	je     8041603aa8 <mon_backtrace+0xdf>
    return -1;
  }

  do {
    rip = rbp[1];
    debuginfo_rip(rip, &info);
  8041603a12:	49 bf ea 42 60 41 80 	movabs $0x80416042ea,%r15
  8041603a19:	00 00 00 

    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  8041603a1c:	49 bd 0b 41 60 41 80 	movabs $0x804160410b,%r13
  8041603a23:	00 00 00 
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  8041603a26:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603a2d:	4c 8d b0 04 01 00 00 	lea    0x104(%rax),%r14
    rip = rbp[1];
  8041603a34:	4c 8b 63 08          	mov    0x8(%rbx),%r12
    debuginfo_rip(rip, &info);
  8041603a38:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603a3f:	4c 89 e7             	mov    %r12,%rdi
  8041603a42:	41 ff d7             	callq  *%r15
    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  8041603a45:	4c 89 e2             	mov    %r12,%rdx
  8041603a48:	48 89 de             	mov    %rbx,%rsi
  8041603a4b:	48 bf 7d 5a 60 41 80 	movabs $0x8041605a7d,%rdi
  8041603a52:	00 00 00 
  8041603a55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a5a:	41 ff d5             	callq  *%r13
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  8041603a5d:	4d 89 e1             	mov    %r12,%r9
  8041603a60:	4c 2b 4d b8          	sub    -0x48(%rbp),%r9
  8041603a64:	4d 89 f0             	mov    %r14,%r8
  8041603a67:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041603a6a:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603a70:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603a77:	48 bf 97 5a 60 41 80 	movabs $0x8041605a97,%rdi
  8041603a7e:	00 00 00 
  8041603a81:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a86:	41 ff d5             	callq  *%r13
            info.rip_fn_namelen, info.rip_fn_name, (rip - info.rip_fn_addr));
    // cprintf(" args:%d \n", info.rip_fn_narg);
    rbp = (uint64_t *)rbp[0];
  8041603a89:	48 8b 1b             	mov    (%rbx),%rbx

  } while (rbp);
  8041603a8c:	48 85 db             	test   %rbx,%rbx
  8041603a8f:	75 a3                	jne    8041603a34 <mon_backtrace+0x6b>

  return 0;
  8041603a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603a96:	48 81 c4 28 02 00 00 	add    $0x228,%rsp
  8041603a9d:	5b                   	pop    %rbx
  8041603a9e:	41 5c                	pop    %r12
  8041603aa0:	41 5d                	pop    %r13
  8041603aa2:	41 5e                	pop    %r14
  8041603aa4:	41 5f                	pop    %r15
  8041603aa6:	5d                   	pop    %rbp
  8041603aa7:	c3                   	retq   
    cprintf("JOS: ERR: Couldn't obtain backtrace...\n");
  8041603aa8:	48 bf 80 5c 60 41 80 	movabs $0x8041605c80,%rdi
  8041603aaf:	00 00 00 
  8041603ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ab7:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041603abe:	00 00 00 
  8041603ac1:	ff d2                	callq  *%rdx
    return -1;
  8041603ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041603ac8:	eb cc                	jmp    8041603a96 <mon_backtrace+0xcd>

0000008041603aca <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603aca:	55                   	push   %rbp
  8041603acb:	48 89 e5             	mov    %rsp,%rbp
  8041603ace:	41 57                	push   %r15
  8041603ad0:	41 56                	push   %r14
  8041603ad2:	41 55                	push   %r13
  8041603ad4:	41 54                	push   %r12
  8041603ad6:	53                   	push   %rbx
  8041603ad7:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603ade:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603ae5:	48 bf a8 5c 60 41 80 	movabs $0x8041605ca8,%rdi
  8041603aec:	00 00 00 
  8041603aef:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603af4:	48 bb 0b 41 60 41 80 	movabs $0x804160410b,%rbx
  8041603afb:	00 00 00 
  8041603afe:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603b00:	48 bf d0 5c 60 41 80 	movabs $0x8041605cd0,%rdi
  8041603b07:	00 00 00 
  8041603b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b0f:	ff d3                	callq  *%rbx

  while (1) {
    buf = readline("K> ");
  8041603b11:	49 bd a2 4d 60 41 80 	movabs $0x8041604da2,%r13
  8041603b18:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603b1b:	48 bb 79 50 60 41 80 	movabs $0x8041605079,%rbx
  8041603b22:	00 00 00 
  8041603b25:	e9 04 01 00 00       	jmpq   8041603c2e <monitor+0x164>
  8041603b2a:	40 0f be f6          	movsbl %sil,%esi
  8041603b2e:	48 bf b9 5a 60 41 80 	movabs $0x8041605ab9,%rdi
  8041603b35:	00 00 00 
  8041603b38:	ff d3                	callq  *%rbx
  8041603b3a:	48 85 c0             	test   %rax,%rax
  8041603b3d:	74 0d                	je     8041603b4c <monitor+0x82>
      *buf++ = 0;
  8041603b3f:	41 c6 06 00          	movb   $0x0,(%r14)
  8041603b43:	45 89 e7             	mov    %r12d,%r15d
  8041603b46:	4d 8d 76 01          	lea    0x1(%r14),%r14
  8041603b4a:	eb 4b                	jmp    8041603b97 <monitor+0xcd>
    if (*buf == 0)
  8041603b4c:	41 80 3e 00          	cmpb   $0x0,(%r14)
  8041603b50:	74 51                	je     8041603ba3 <monitor+0xd9>
    if (argc == MAXARGS - 1) {
  8041603b52:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603b56:	0f 84 b7 00 00 00    	je     8041603c13 <monitor+0x149>
    argv[argc++] = buf;
  8041603b5c:	45 8d 7c 24 01       	lea    0x1(%r12),%r15d
  8041603b61:	4d 63 e4             	movslq %r12d,%r12
  8041603b64:	4e 89 b4 e5 50 ff ff 	mov    %r14,-0xb0(%rbp,%r12,8)
  8041603b6b:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603b6c:	41 0f b6 36          	movzbl (%r14),%esi
  8041603b70:	40 84 f6             	test   %sil,%sil
  8041603b73:	74 22                	je     8041603b97 <monitor+0xcd>
  8041603b75:	40 0f be f6          	movsbl %sil,%esi
  8041603b79:	48 bf b9 5a 60 41 80 	movabs $0x8041605ab9,%rdi
  8041603b80:	00 00 00 
  8041603b83:	ff d3                	callq  *%rbx
  8041603b85:	48 85 c0             	test   %rax,%rax
  8041603b88:	75 0d                	jne    8041603b97 <monitor+0xcd>
      buf++;
  8041603b8a:	49 83 c6 01          	add    $0x1,%r14
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603b8e:	41 0f b6 36          	movzbl (%r14),%esi
  8041603b92:	40 84 f6             	test   %sil,%sil
  8041603b95:	75 de                	jne    8041603b75 <monitor+0xab>
      *buf++ = 0;
  8041603b97:	45 89 fc             	mov    %r15d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603b9a:	41 0f b6 36          	movzbl (%r14),%esi
  8041603b9e:	40 84 f6             	test   %sil,%sil
  8041603ba1:	75 87                	jne    8041603b2a <monitor+0x60>
  argv[argc] = 0;
  8041603ba3:	49 63 c4             	movslq %r12d,%rax
  8041603ba6:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041603bad:	ff 00 00 00 00 
  if (argc == 0)
  8041603bb2:	45 85 e4             	test   %r12d,%r12d
  8041603bb5:	74 77                	je     8041603c2e <monitor+0x164>
  8041603bb7:	49 bf 20 5d 60 41 80 	movabs $0x8041605d20,%r15
  8041603bbe:	00 00 00 
  8041603bc1:	41 be 00 00 00 00    	mov    $0x0,%r14d
    if (strcmp(argv[0], commands[i].name) == 0)
  8041603bc7:	49 8b 37             	mov    (%r15),%rsi
  8041603bca:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041603bd1:	48 b8 06 50 60 41 80 	movabs $0x8041605006,%rax
  8041603bd8:	00 00 00 
  8041603bdb:	ff d0                	callq  *%rax
  8041603bdd:	85 c0                	test   %eax,%eax
  8041603bdf:	74 78                	je     8041603c59 <monitor+0x18f>
  for (i = 0; i < NCOMMANDS; i++) {
  8041603be1:	41 83 c6 01          	add    $0x1,%r14d
  8041603be5:	49 83 c7 18          	add    $0x18,%r15
  8041603be9:	41 83 fe 05          	cmp    $0x5,%r14d
  8041603bed:	75 d8                	jne    8041603bc7 <monitor+0xfd>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041603bef:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041603bf6:	48 bf db 5a 60 41 80 	movabs $0x8041605adb,%rdi
  8041603bfd:	00 00 00 
  8041603c00:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c05:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041603c0c:	00 00 00 
  8041603c0f:	ff d2                	callq  *%rdx
  8041603c11:	eb 1b                	jmp    8041603c2e <monitor+0x164>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041603c13:	be 10 00 00 00       	mov    $0x10,%esi
  8041603c18:	48 bf be 5a 60 41 80 	movabs $0x8041605abe,%rdi
  8041603c1f:	00 00 00 
  8041603c22:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041603c29:	00 00 00 
  8041603c2c:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  8041603c2e:	48 bf b5 5a 60 41 80 	movabs $0x8041605ab5,%rdi
  8041603c35:	00 00 00 
  8041603c38:	41 ff d5             	callq  *%r13
  8041603c3b:	49 89 c6             	mov    %rax,%r14
    if (buf != NULL)
  8041603c3e:	48 85 c0             	test   %rax,%rax
  8041603c41:	74 eb                	je     8041603c2e <monitor+0x164>
  argv[argc] = 0;
  8041603c43:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  8041603c4a:	00 00 00 00 
  argc       = 0;
  8041603c4e:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041603c54:	e9 41 ff ff ff       	jmpq   8041603b9a <monitor+0xd0>
      return commands[i].func(argc, argv, tf);
  8041603c59:	4d 63 f6             	movslq %r14d,%r14
  8041603c5c:	4b 8d 0c 76          	lea    (%r14,%r14,2),%rcx
  8041603c60:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  8041603c67:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  8041603c6e:	44 89 e7             	mov    %r12d,%edi
  8041603c71:	48 b8 20 5d 60 41 80 	movabs $0x8041605d20,%rax
  8041603c78:	00 00 00 
  8041603c7b:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  8041603c7f:	85 c0                	test   %eax,%eax
  8041603c81:	79 ab                	jns    8041603c2e <monitor+0x164>
        break;
  }
}
  8041603c83:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041603c8a:	5b                   	pop    %rbx
  8041603c8b:	41 5c                	pop    %r12
  8041603c8d:	41 5d                	pop    %r13
  8041603c8f:	41 5e                	pop    %r14
  8041603c91:	41 5f                	pop    %r15
  8041603c93:	5d                   	pop    %rbp
  8041603c94:	c3                   	retq   

0000008041603c95 <envid2env>:
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  8041603c95:	55                   	push   %rbp
  8041603c96:	48 89 e5             	mov    %rsp,%rbp
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
  8041603c99:	85 ff                	test   %edi,%edi
  8041603c9b:	74 63                	je     8041603d00 <envid2env+0x6b>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  8041603c9d:	89 f9                	mov    %edi,%ecx
  8041603c9f:	83 e1 1f             	and    $0x1f,%ecx
  8041603ca2:	48 8d 04 cd 00 00 00 	lea    0x0(,%rcx,8),%rax
  8041603ca9:	00 
  8041603caa:	48 29 c8             	sub    %rcx,%rax
  8041603cad:	48 c1 e0 05          	shl    $0x5,%rax
  8041603cb1:	48 b9 88 77 61 41 80 	movabs $0x8041617788,%rcx
  8041603cb8:	00 00 00 
  8041603cbb:	48 8b 09             	mov    (%rcx),%rcx
  8041603cbe:	48 01 c8             	add    %rcx,%rax
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  8041603cc1:	83 b8 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rax)
  8041603cc8:	74 4a                	je     8041603d14 <envid2env+0x7f>
  8041603cca:	3b b8 c8 00 00 00    	cmp    0xc8(%rax),%edi
  8041603cd0:	75 42                	jne    8041603d14 <envid2env+0x7f>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  8041603cd2:	84 d2                	test   %dl,%dl
  8041603cd4:	74 20                	je     8041603cf6 <envid2env+0x61>
  8041603cd6:	48 ba c0 31 62 41 80 	movabs $0x80416231c0,%rdx
  8041603cdd:	00 00 00 
  8041603ce0:	48 8b 12             	mov    (%rdx),%rdx
  8041603ce3:	48 39 d0             	cmp    %rdx,%rax
  8041603ce6:	74 0e                	je     8041603cf6 <envid2env+0x61>
  8041603ce8:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  8041603cee:	39 90 cc 00 00 00    	cmp    %edx,0xcc(%rax)
  8041603cf4:	75 2c                	jne    8041603d22 <envid2env+0x8d>
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  8041603cf6:	48 89 06             	mov    %rax,(%rsi)
  return 0;
  8041603cf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603cfe:	5d                   	pop    %rbp
  8041603cff:	c3                   	retq   
    *env_store = curenv;
  8041603d00:	48 a1 c0 31 62 41 80 	movabs 0x80416231c0,%rax
  8041603d07:	00 00 00 
  8041603d0a:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  8041603d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d12:	eb ea                	jmp    8041603cfe <envid2env+0x69>
    *env_store = 0;
  8041603d14:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603d1b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603d20:	eb dc                	jmp    8041603cfe <envid2env+0x69>
    *env_store = 0;
  8041603d22:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603d29:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603d2e:	eb ce                	jmp    8041603cfe <envid2env+0x69>

0000008041603d30 <env_init>:
  uint32_t env_runs;       // Number of times environment has run
};
*/

void
env_init(void) {
  8041603d30:	55                   	push   %rbp
  8041603d31:	48 89 e5             	mov    %rsp,%rbp
// Set up envs array
// LAB 3: Your code here.
env_free_list = envs; // env_free_list = &envs[0]; ?????
  8041603d34:	48 b8 88 77 61 41 80 	movabs $0x8041617788,%rax
  8041603d3b:	00 00 00 
  8041603d3e:	48 8b 10             	mov    (%rax),%rdx
  8041603d41:	48 89 d0             	mov    %rdx,%rax
  8041603d44:	48 a3 c8 31 62 41 80 	movabs %rax,0x80416231c8
  8041603d4b:	00 00 00 
for (uint32_t i = 0; i < NENV; ++i) {
  // envs[i].env_tf = {0};
  envs[i].env_status = ENV_FREE;
  8041603d4e:	c7 82 d4 00 00 00 00 	movl   $0x0,0xd4(%rdx)
  8041603d55:	00 00 00 
  8041603d58:	48 8d 82 e0 00 00 00 	lea    0xe0(%rdx),%rax
  8041603d5f:	48 81 c2 00 1c 00 00 	add    $0x1c00,%rdx
  if (i != NENV - 1) {
    envs[i].env_link = &envs[i + 1];
  8041603d66:	48 89 c1             	mov    %rax,%rcx
  8041603d69:	48 89 40 e0          	mov    %rax,-0x20(%rax)
  } else {
    envs[i].env_link = NULL;
  };
  envs[i].env_type = ENV_TYPE_KERNEL;
  8041603d6d:	c7 40 f0 01 00 00 00 	movl   $0x1,-0x10(%rax)
  envs[i].env_id = 0;
  8041603d74:	c7 40 e8 00 00 00 00 	movl   $0x0,-0x18(%rax)
  envs[i].env_parent_id = 0;
  8041603d7b:	c7 40 ec 00 00 00 00 	movl   $0x0,-0x14(%rax)
  envs[i].env_status = ENV_FREE;
  8041603d82:	c7 80 d4 00 00 00 00 	movl   $0x0,0xd4(%rax)
  8041603d89:	00 00 00 
  8041603d8c:	48 05 e0 00 00 00    	add    $0xe0,%rax
  if (i != NENV - 1) {
  8041603d92:	48 39 d0             	cmp    %rdx,%rax
  8041603d95:	75 cf                	jne    8041603d66 <env_init+0x36>
    envs[i].env_link = NULL;
  8041603d97:	48 c7 81 c0 00 00 00 	movq   $0x0,0xc0(%rcx)
  8041603d9e:	00 00 00 00 
  envs[i].env_type = ENV_TYPE_KERNEL;
  8041603da2:	c7 81 d0 00 00 00 01 	movl   $0x1,0xd0(%rcx)
  8041603da9:	00 00 00 
  envs[i].env_id = 0;
  8041603dac:	c7 81 c8 00 00 00 00 	movl   $0x0,0xc8(%rcx)
  8041603db3:	00 00 00 
  envs[i].env_parent_id = 0;
  8041603db6:	c7 81 cc 00 00 00 00 	movl   $0x0,0xcc(%rcx)
  8041603dbd:	00 00 00 



  
  
}
  8041603dc0:	5d                   	pop    %rbp
  8041603dc1:	c3                   	retq   

0000008041603dc2 <env_init_percpu>:

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  8041603dc2:	55                   	push   %rbp
  8041603dc3:	48 89 e5             	mov    %rsp,%rbp
  8041603dc6:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  8041603dc7:	48 b8 20 77 61 41 80 	movabs $0x8041617720,%rax
  8041603dce:	00 00 00 
  8041603dd1:	0f 01 10             	lgdt   (%rax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  8041603dd4:	b8 33 00 00 00       	mov    $0x33,%eax
  8041603dd9:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  8041603ddb:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  8041603ddd:	b8 10 00 00 00       	mov    $0x10,%eax
  8041603de2:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041603de4:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041603de6:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  8041603de8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041603ded:	53                   	push   %rbx
  8041603dee:	48 b8 fb 3d 60 41 80 	movabs $0x8041603dfb,%rax
  8041603df5:	00 00 00 
  8041603df8:	50                   	push   %rax
  8041603df9:	48 cb                	lretq  
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  8041603dfb:	66 b8 00 00          	mov    $0x0,%ax
  8041603dff:	0f 00 d0             	lldt   %ax
               :
               :
               : "cc", "memory");
}
  8041603e02:	5b                   	pop    %rbx
  8041603e03:	5d                   	pop    %rbp
  8041603e04:	c3                   	retq   

0000008041603e05 <env_alloc>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  8041603e05:	55                   	push   %rbp
  8041603e06:	48 89 e5             	mov    %rsp,%rbp
  8041603e09:	41 54                	push   %r12
  8041603e0b:	53                   	push   %rbx
  int32_t generation;
  struct Env *e;

  if (!(e = env_free_list)) {
  8041603e0c:	48 b8 c8 31 62 41 80 	movabs $0x80416231c8,%rax
  8041603e13:	00 00 00 
  8041603e16:	48 8b 18             	mov    (%rax),%rbx
  8041603e19:	48 85 db             	test   %rbx,%rbx
  8041603e1c:	0f 84 f8 00 00 00    	je     8041603f1a <env_alloc+0x115>
  8041603e22:	49 89 fc             	mov    %rdi,%r12
    return -E_NO_FREE_ENV;
  }

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  8041603e25:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  8041603e2b:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041603e30:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  8041603e33:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041603e38:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  8041603e3b:	48 ba 88 77 61 41 80 	movabs $0x8041617788,%rdx
  8041603e42:	00 00 00 
  8041603e45:	48 89 d9             	mov    %rbx,%rcx
  8041603e48:	48 2b 0a             	sub    (%rdx),%rcx
  8041603e4b:	48 89 ca             	mov    %rcx,%rdx
  8041603e4e:	48 c1 fa 05          	sar    $0x5,%rdx
  8041603e52:	69 d2 b7 6d db b6    	imul   $0xb6db6db7,%edx,%edx
  8041603e58:	09 d0                	or     %edx,%eax
  8041603e5a:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
  8041603e60:	89 b3 cc 00 00 00    	mov    %esi,0xcc(%rbx)
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
  8041603e66:	c7 83 d0 00 00 00 01 	movl   $0x1,0xd0(%rbx)
  8041603e6d:	00 00 00 
#else
#endif
  e->env_status = ENV_RUNNABLE;
  8041603e70:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  8041603e77:	00 00 00 
  e->env_runs   = 0;
  8041603e7a:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  8041603e81:	00 00 00 

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  8041603e84:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041603e89:	be 00 00 00 00       	mov    $0x0,%esi
  8041603e8e:	48 89 df             	mov    %rbx,%rdi
  8041603e91:	48 b8 d8 50 60 41 80 	movabs $0x80416050d8,%rax
  8041603e98:	00 00 00 
  8041603e9b:	ff d0                	callq  *%rax
  // Requestor Privilege Level (RPL); 3 means user mode, 0 - kernel mode.  When
  // we switch privilege levels, the hardware does various
  // checks involving the RPL and the Descriptor Privilege Level
  // (DPL) stored in the descriptors themselves.
#ifdef CONFIG_KSPACE
  e->env_tf.tf_ds = GD_KD | 0;
  8041603e9d:	66 c7 83 80 00 00 00 	movw   $0x10,0x80(%rbx)
  8041603ea4:	10 00 
  e->env_tf.tf_es = GD_KD | 0;
  8041603ea6:	66 c7 43 78 10 00    	movw   $0x10,0x78(%rbx)
  e->env_tf.tf_ss = GD_KD | 0;
  8041603eac:	66 c7 83 b8 00 00 00 	movw   $0x10,0xb8(%rbx)
  8041603eb3:	10 00 
  e->env_tf.tf_cs = GD_KT | 0;
  8041603eb5:	66 c7 83 a0 00 00 00 	movw   $0x8,0xa0(%rbx)
  8041603ebc:	08 00 
#else
#endif
  // You will set e->env_tf.tf_rip later.

  // commit the allocation
  env_free_list = e->env_link;
  8041603ebe:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  8041603ec5:	48 a3 c8 31 62 41 80 	movabs %rax,0x80416231c8
  8041603ecc:	00 00 00 
  *newenv_store = e;
  8041603ecf:	49 89 1c 24          	mov    %rbx,(%r12)

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603ed3:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  8041603ed9:	48 a1 c0 31 62 41 80 	movabs 0x80416231c0,%rax
  8041603ee0:	00 00 00 
  8041603ee3:	48 85 c0             	test   %rax,%rax
  8041603ee6:	74 2b                	je     8041603f13 <env_alloc+0x10e>
  8041603ee8:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041603eee:	48 bf 98 5d 60 41 80 	movabs $0x8041605d98,%rdi
  8041603ef5:	00 00 00 
  8041603ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603efd:	48 b9 0b 41 60 41 80 	movabs $0x804160410b,%rcx
  8041603f04:	00 00 00 
  8041603f07:	ff d1                	callq  *%rcx

  return 0;
  8041603f09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603f0e:	5b                   	pop    %rbx
  8041603f0f:	41 5c                	pop    %r12
  8041603f11:	5d                   	pop    %rbp
  8041603f12:	c3                   	retq   
  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603f13:	be 00 00 00 00       	mov    $0x0,%esi
  8041603f18:	eb d4                	jmp    8041603eee <env_alloc+0xe9>
    return -E_NO_FREE_ENV;
  8041603f1a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  8041603f1f:	eb ed                	jmp    8041603f0e <env_alloc+0x109>

0000008041603f21 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  8041603f21:	55                   	push   %rbp
  8041603f22:	48 89 e5             	mov    %rsp,%rbp
  // LAB 3: Your code here.
}
  8041603f25:	5d                   	pop    %rbp
  8041603f26:	c3                   	retq   

0000008041603f27 <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041603f27:	55                   	push   %rbp
  8041603f28:	48 89 e5             	mov    %rsp,%rbp
  8041603f2b:	53                   	push   %rbx
  8041603f2c:	48 83 ec 08          	sub    $0x8,%rsp
  8041603f30:	48 89 fb             	mov    %rdi,%rbx
  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603f33:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041603f39:	48 a1 c0 31 62 41 80 	movabs 0x80416231c0,%rax
  8041603f40:	00 00 00 
  8041603f43:	48 85 c0             	test   %rax,%rax
  8041603f46:	74 49                	je     8041603f91 <env_free+0x6a>
  8041603f48:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041603f4e:	48 bf ad 5d 60 41 80 	movabs $0x8041605dad,%rdi
  8041603f55:	00 00 00 
  8041603f58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f5d:	48 b9 0b 41 60 41 80 	movabs $0x804160410b,%rcx
  8041603f64:	00 00 00 
  8041603f67:	ff d1                	callq  *%rcx

  // return the environment to the free list
  e->env_status = ENV_FREE;
  8041603f69:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  8041603f70:	00 00 00 
  e->env_link   = env_free_list;
  8041603f73:	48 b8 c8 31 62 41 80 	movabs $0x80416231c8,%rax
  8041603f7a:	00 00 00 
  8041603f7d:	48 8b 10             	mov    (%rax),%rdx
  8041603f80:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  8041603f87:	48 89 18             	mov    %rbx,(%rax)
}
  8041603f8a:	48 83 c4 08          	add    $0x8,%rsp
  8041603f8e:	5b                   	pop    %rbx
  8041603f8f:	5d                   	pop    %rbp
  8041603f90:	c3                   	retq   
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603f91:	be 00 00 00 00       	mov    $0x0,%esi
  8041603f96:	eb b6                	jmp    8041603f4e <env_free+0x27>

0000008041603f98 <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) {
  8041603f98:	55                   	push   %rbp
  8041603f99:	48 89 e5             	mov    %rsp,%rbp
  // LAB 3: Your code here.
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
}
  8041603f9c:	5d                   	pop    %rbp
  8041603f9d:	c3                   	retq   

0000008041603f9e <csys_exit>:

#ifdef CONFIG_KSPACE
void
csys_exit(void) {
  8041603f9e:	55                   	push   %rbp
  8041603f9f:	48 89 e5             	mov    %rsp,%rbp
  env_destroy(curenv);
}
  8041603fa2:	5d                   	pop    %rbp
  8041603fa3:	c3                   	retq   

0000008041603fa4 <csys_yield>:

void
csys_yield(struct Trapframe *tf) {
  8041603fa4:	55                   	push   %rbp
  8041603fa5:	48 89 e5             	mov    %rsp,%rbp
  8041603fa8:	48 89 fe             	mov    %rdi,%rsi
  memcpy(&curenv->env_tf, tf, sizeof(struct Trapframe));
  8041603fab:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041603fb0:	48 b8 c0 31 62 41 80 	movabs $0x80416231c0,%rax
  8041603fb7:	00 00 00 
  8041603fba:	48 8b 38             	mov    (%rax),%rdi
  8041603fbd:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  8041603fc4:	00 00 00 
  8041603fc7:	ff d0                	callq  *%rax
  sched_yield();
  8041603fc9:	48 b8 9f 41 60 41 80 	movabs $0x804160419f,%rax
  8041603fd0:	00 00 00 
  8041603fd3:	ff d0                	callq  *%rax

0000008041603fd5 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041603fd5:	55                   	push   %rbp
  8041603fd6:	48 89 e5             	mov    %rsp,%rbp
  8041603fd9:	53                   	push   %rbx
  8041603fda:	48 83 ec 08          	sub    $0x8,%rsp
  8041603fde:	48 89 f8             	mov    %rdi,%rax
#ifdef CONFIG_KSPACE
  static uintptr_t rip = 0;
  rip                  = tf->tf_rip;

  asm volatile(
  8041603fe1:	48 8b 58 68          	mov    0x68(%rax),%rbx
  8041603fe5:	48 8b 48 60          	mov    0x60(%rax),%rcx
  8041603fe9:	48 8b 50 58          	mov    0x58(%rax),%rdx
  8041603fed:	48 8b 70 40          	mov    0x40(%rax),%rsi
  8041603ff1:	48 8b 78 48          	mov    0x48(%rax),%rdi
  8041603ff5:	48 8b 68 50          	mov    0x50(%rax),%rbp
  8041603ff9:	48 8b a0 b0 00 00 00 	mov    0xb0(%rax),%rsp
  8041604000:	4c 8b 40 38          	mov    0x38(%rax),%r8
  8041604004:	4c 8b 48 30          	mov    0x30(%rax),%r9
  8041604008:	4c 8b 50 28          	mov    0x28(%rax),%r10
  804160400c:	4c 8b 58 20          	mov    0x20(%rax),%r11
  8041604010:	4c 8b 60 18          	mov    0x18(%rax),%r12
  8041604014:	4c 8b 68 10          	mov    0x10(%rax),%r13
  8041604018:	4c 8b 70 08          	mov    0x8(%rax),%r14
  804160401c:	4c 8b 38             	mov    (%rax),%r15
  804160401f:	ff b0 98 00 00 00    	pushq  0x98(%rax)
  8041604025:	ff b0 a8 00 00 00    	pushq  0xa8(%rax)
  804160402b:	48 8b 40 70          	mov    0x70(%rax),%rax
  804160402f:	9d                   	popfq  
  8041604030:	c3                   	retq   
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041604031:	48 ba c3 5d 60 41 80 	movabs $0x8041605dc3,%rdx
  8041604038:	00 00 00 
  804160403b:	be a1 01 00 00       	mov    $0x1a1,%esi
  8041604040:	48 bf c7 5d 60 41 80 	movabs $0x8041605dc7,%rdi
  8041604047:	00 00 00 
  804160404a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160404f:	48 b9 7e 03 60 41 80 	movabs $0x804160037e,%rcx
  8041604056:	00 00 00 
  8041604059:	ff d1                	callq  *%rcx

000000804160405b <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  804160405b:	55                   	push   %rbp
  804160405c:	48 89 e5             	mov    %rsp,%rbp
#ifdef CONFIG_KSPACE
  cprintf("envrun %s: %d\n",
  804160405f:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041604065:	83 e2 1f             	and    $0x1f,%edx
          e->env_status == ENV_RUNNING ? "RUNNING" :
  8041604068:	8b 87 d4 00 00 00    	mov    0xd4(%rdi),%eax
  cprintf("envrun %s: %d\n",
  804160406e:	48 be dc 5d 60 41 80 	movabs $0x8041605ddc,%rsi
  8041604075:	00 00 00 
  8041604078:	83 f8 03             	cmp    $0x3,%eax
  804160407b:	74 1b                	je     8041604098 <env_run+0x3d>
                                         e->env_status == ENV_RUNNABLE ? "RUNNABLE" : "(unknown)",
  804160407d:	83 f8 02             	cmp    $0x2,%eax
  8041604080:	48 b8 d2 5d 60 41 80 	movabs $0x8041605dd2,%rax
  8041604087:	00 00 00 
  804160408a:	48 be e4 5d 60 41 80 	movabs $0x8041605de4,%rsi
  8041604091:	00 00 00 
  8041604094:	48 0f 45 f0          	cmovne %rax,%rsi
  cprintf("envrun %s: %d\n",
  8041604098:	48 bf ed 5d 60 41 80 	movabs $0x8041605ded,%rdi
  804160409f:	00 00 00 
  80416040a2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416040a7:	48 b9 0b 41 60 41 80 	movabs $0x804160410b,%rcx
  80416040ae:	00 00 00 
  80416040b1:	ff d1                	callq  *%rcx
  80416040b3:	eb fe                	jmp    80416040b3 <env_run+0x58>

00000080416040b5 <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  80416040b5:	55                   	push   %rbp
  80416040b6:	48 89 e5             	mov    %rsp,%rbp
  80416040b9:	53                   	push   %rbx
  80416040ba:	48 83 ec 08          	sub    $0x8,%rsp
  80416040be:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  80416040c1:	48 b8 03 0c 60 41 80 	movabs $0x8041600c03,%rax
  80416040c8:	00 00 00 
  80416040cb:	ff d0                	callq  *%rax
  (*cnt)++;
  80416040cd:	83 03 01             	addl   $0x1,(%rbx)
}
  80416040d0:	48 83 c4 08          	add    $0x8,%rsp
  80416040d4:	5b                   	pop    %rbx
  80416040d5:	5d                   	pop    %rbp
  80416040d6:	c3                   	retq   

00000080416040d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80416040d7:	55                   	push   %rbp
  80416040d8:	48 89 e5             	mov    %rsp,%rbp
  80416040db:	48 83 ec 10          	sub    $0x10,%rsp
  80416040df:	48 89 fa             	mov    %rdi,%rdx
  80416040e2:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  80416040e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  80416040ec:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  80416040f0:	48 bf b5 40 60 41 80 	movabs $0x80416040b5,%rdi
  80416040f7:	00 00 00 
  80416040fa:	48 b8 43 46 60 41 80 	movabs $0x8041604643,%rax
  8041604101:	00 00 00 
  8041604104:	ff d0                	callq  *%rax
  return cnt;
}
  8041604106:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041604109:	c9                   	leaveq 
  804160410a:	c3                   	retq   

000000804160410b <cprintf>:

int
cprintf(const char *fmt, ...) {
  804160410b:	55                   	push   %rbp
  804160410c:	48 89 e5             	mov    %rsp,%rbp
  804160410f:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041604116:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  804160411d:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041604124:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160412b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041604132:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604139:	84 c0                	test   %al,%al
  804160413b:	74 20                	je     804160415d <cprintf+0x52>
  804160413d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604141:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604145:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604149:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160414d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604151:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604155:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604159:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  804160415d:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8041604164:	00 00 00 
  8041604167:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160416e:	00 00 00 
  8041604171:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041604175:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160417c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041604183:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  804160418a:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041604191:	48 b8 d7 40 60 41 80 	movabs $0x80416040d7,%rax
  8041604198:	00 00 00 
  804160419b:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  804160419d:	c9                   	leaveq 
  804160419e:	c3                   	retq   

000000804160419f <sched_yield>:
struct Taskstate cpu_ts;
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void) {
  804160419f:	55                   	push   %rbp
  80416041a0:	48 89 e5             	mov    %rsp,%rbp
  // If there are no runnable environments,
  // simply drop through to the code
  // below to halt the cpu.

  // LAB 3: Your code here.
}
  80416041a3:	5d                   	pop    %rbp
  80416041a4:	c3                   	retq   

00000080416041a5 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  80416041a5:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  80416041ac:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  80416041af:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  80416041b5:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  80416041b8:	83 fa 02             	cmp    $0x2,%edx
  80416041bb:	76 61                	jbe    804160421e <sched_halt+0x79>
  80416041bd:	48 8d 90 b4 01 00 00 	lea    0x1b4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  80416041c4:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  80416041c9:	8b 02                	mov    (%rdx),%eax
  80416041cb:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  80416041ce:	83 f8 02             	cmp    $0x2,%eax
  80416041d1:	76 46                	jbe    8041604219 <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  80416041d3:	83 c1 01             	add    $0x1,%ecx
  80416041d6:	48 81 c2 e0 00 00 00 	add    $0xe0,%rdx
  80416041dd:	83 f9 20             	cmp    $0x20,%ecx
  80416041e0:	75 e7                	jne    80416041c9 <sched_halt+0x24>
sched_halt(void) {
  80416041e2:	55                   	push   %rbp
  80416041e3:	48 89 e5             	mov    %rsp,%rbp
  80416041e6:	53                   	push   %rbx
  80416041e7:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  80416041eb:	48 bf 00 5e 60 41 80 	movabs $0x8041605e00,%rdi
  80416041f2:	00 00 00 
  80416041f5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416041fa:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041604201:	00 00 00 
  8041604204:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  8041604206:	48 bb ca 3a 60 41 80 	movabs $0x8041603aca,%rbx
  804160420d:	00 00 00 
  8041604210:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604215:	ff d3                	callq  *%rbx
  8041604217:	eb f7                	jmp    8041604210 <sched_halt+0x6b>
  if (i == NENV) {
  8041604219:	83 f9 20             	cmp    $0x20,%ecx
  804160421c:	74 c4                	je     80416041e2 <sched_halt+0x3d>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  804160421e:	48 b8 c0 31 62 41 80 	movabs $0x80416231c0,%rax
  8041604225:	00 00 00 
  8041604228:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  804160422f:	48 a1 04 52 62 41 80 	movabs 0x8041625204,%rax
  8041604236:	00 00 00 
  8041604239:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  8041604240:	48 89 c4             	mov    %rax,%rsp
  8041604243:	6a 00                	pushq  $0x0
  8041604245:	6a 00                	pushq  $0x0
  8041604247:	fb                   	sti    
  8041604248:	f4                   	hlt    
  8041604249:	c3                   	retq   

000000804160424a <load_kernel_dwarf_info>:
#include <kern/kdebug.h>
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  804160424a:	55                   	push   %rbp
  804160424b:	48 89 e5             	mov    %rsp,%rbp
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  804160424e:	48 ba 00 70 61 41 80 	movabs $0x8041617000,%rdx
  8041604255:	00 00 00 
  8041604258:	48 8b 02             	mov    (%rdx),%rax
  804160425b:	48 8b 48 58          	mov    0x58(%rax),%rcx
  804160425f:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  8041604263:	48 8b 48 60          	mov    0x60(%rax),%rcx
  8041604267:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  804160426b:	48 8b 40 68          	mov    0x68(%rax),%rax
  804160426f:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  8041604272:	48 8b 02             	mov    (%rdx),%rax
  8041604275:	48 8b 50 70          	mov    0x70(%rax),%rdx
  8041604279:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  804160427d:	48 8b 50 78          	mov    0x78(%rax),%rdx
  8041604281:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  8041604285:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  804160428c:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  8041604290:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  8041604297:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  804160429b:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  80416042a2:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  80416042a6:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  80416042ad:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  80416042b1:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  80416042b8:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  80416042bc:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  80416042c3:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  80416042c7:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  80416042ce:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  80416042d2:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  80416042d9:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  80416042dd:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  80416042e4:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  80416042e8:	5d                   	pop    %rbp
  80416042e9:	c3                   	retq   

00000080416042ea <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  80416042ea:	55                   	push   %rbp
  80416042eb:	48 89 e5             	mov    %rsp,%rbp
  80416042ee:	41 56                	push   %r14
  80416042f0:	41 55                	push   %r13
  80416042f2:	41 54                	push   %r12
  80416042f4:	53                   	push   %rbx
  80416042f5:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  80416042fc:	49 89 fc             	mov    %rdi,%r12
  80416042ff:	48 89 f3             	mov    %rsi,%rbx
  int code = 0;
  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  8041604302:	48 be 29 5e 60 41 80 	movabs $0x8041605e29,%rsi
  8041604309:	00 00 00 
  804160430c:	48 89 df             	mov    %rbx,%rdi
  804160430f:	49 bd 36 4f 60 41 80 	movabs $0x8041604f36,%r13
  8041604316:	00 00 00 
  8041604319:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  804160431c:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  8041604323:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  8041604326:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  804160432d:	48 be 29 5e 60 41 80 	movabs $0x8041605e29,%rsi
  8041604334:	00 00 00 
  8041604337:	4c 89 f7             	mov    %r14,%rdi
  804160433a:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  804160433d:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  8041604344:	00 00 00 
  info->rip_fn_addr    = addr;
  8041604347:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  804160434e:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  8041604355:	00 00 00 

  if (!addr) {
  8041604358:	4d 85 e4             	test   %r12,%r12
  804160435b:	0f 84 8f 01 00 00    	je     80416044f0 <debuginfo_rip+0x206>
    return 0;
  }

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  8041604361:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  8041604368:	00 00 00 
  804160436b:	49 39 c4             	cmp    %rax,%r12
  804160436e:	0f 86 52 01 00 00    	jbe    80416044c6 <debuginfo_rip+0x1dc>
    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  8041604374:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160437b:	48 b8 4a 42 60 41 80 	movabs $0x804160424a,%rax
  8041604382:	00 00 00 
  8041604385:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  8041604387:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  804160438e:	00 00 00 00 
  8041604392:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  8041604399:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  804160439d:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  80416043a4:	4c 89 e6             	mov    %r12,%rsi
  80416043a7:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416043ae:	48 b8 e3 15 60 41 80 	movabs $0x80416015e3,%rax
  80416043b5:	00 00 00 
  80416043b8:	ff d0                	callq  *%rax
  80416043ba:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  80416043bd:	85 c0                	test   %eax,%eax
  80416043bf:	0f 88 31 01 00 00    	js     80416044f6 <debuginfo_rip+0x20c>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  80416043c5:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  80416043cc:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416043d1:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  80416043d8:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  80416043df:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416043e6:	48 b8 cc 1c 60 41 80 	movabs $0x8041601ccc,%rax
  80416043ed:	00 00 00 
  80416043f0:	ff d0                	callq  *%rax
  80416043f2:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  80416043f5:	ba 00 01 00 00       	mov    $0x100,%edx
  80416043fa:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041604401:	48 89 df             	mov    %rbx,%rdi
  8041604404:	48 b8 8b 4f 60 41 80 	movabs $0x8041604f8b,%rax
  804160440b:	00 00 00 
  804160440e:	ff d0                	callq  *%rax
  if (code < 0) {
  8041604410:	45 85 ed             	test   %r13d,%r13d
  8041604413:	0f 88 dd 00 00 00    	js     80416044f6 <debuginfo_rip+0x20c>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
  // LAB 2: Your code here:
  buf  = &info->rip_line;
  addr = addr - 5;
  8041604419:	49 83 ec 05          	sub    $0x5,%r12
  buf  = &info->rip_line;
  804160441d:	48 8d 8b 00 01 00 00 	lea    0x100(%rbx),%rcx
  code = line_for_address(&addrs, addr, line_offset, buf);
  8041604424:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  804160442b:	4c 89 e6             	mov    %r12,%rsi
  804160442e:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041604435:	48 b8 b1 30 60 41 80 	movabs $0x80416030b1,%rax
  804160443c:	00 00 00 
  804160443f:	ff d0                	callq  *%rax
  if (code < 0) {
    return 0;
  8041604441:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  if (code < 0) {
  8041604447:	85 c0                	test   %eax,%eax
  8041604449:	0f 88 a7 00 00 00    	js     80416044f6 <debuginfo_rip+0x20c>
  }
  
  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  804160444f:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  8041604456:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160445c:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  8041604463:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  804160446a:	4c 89 e6             	mov    %r12,%rsi
  804160446d:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041604474:	48 b8 2d 21 60 41 80 	movabs $0x804160212d,%rax
  804160447b:	00 00 00 
  804160447e:	ff d0                	callq  *%rax
  8041604480:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  8041604483:	ba 00 01 00 00       	mov    $0x100,%edx
  8041604488:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160448f:	4c 89 f7             	mov    %r14,%rdi
  8041604492:	48 b8 8b 4f 60 41 80 	movabs $0x8041604f8b,%rax
  8041604499:	00 00 00 
  804160449c:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  804160449e:	be 00 01 00 00       	mov    $0x100,%esi
  80416044a3:	4c 89 f7             	mov    %r14,%rdi
  80416044a6:	48 b8 ff 4e 60 41 80 	movabs $0x8041604eff,%rax
  80416044ad:	00 00 00 
  80416044b0:	ff d0                	callq  *%rax
  80416044b2:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  80416044b8:	45 85 ed             	test   %r13d,%r13d
  80416044bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044c0:	44 0f 4f e8          	cmovg  %eax,%r13d
  80416044c4:	eb 30                	jmp    80416044f6 <debuginfo_rip+0x20c>
    panic("Can't search for user-level addresses yet!");
  80416044c6:	48 ba 48 5e 60 41 80 	movabs $0x8041605e48,%rdx
  80416044cd:	00 00 00 
  80416044d0:	be 36 00 00 00       	mov    $0x36,%esi
  80416044d5:	48 bf 33 5e 60 41 80 	movabs $0x8041605e33,%rdi
  80416044dc:	00 00 00 
  80416044df:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044e4:	48 b9 7e 03 60 41 80 	movabs $0x804160037e,%rcx
  80416044eb:	00 00 00 
  80416044ee:	ff d1                	callq  *%rcx
    return 0;
  80416044f0:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  if (code < 0) {
    return code;
  }
  return 0;
}
  80416044f6:	44 89 e8             	mov    %r13d,%eax
  80416044f9:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  8041604500:	5b                   	pop    %rbx
  8041604501:	41 5c                	pop    %r12
  8041604503:	41 5d                	pop    %r13
  8041604505:	41 5e                	pop    %r14
  8041604507:	5d                   	pop    %rbp
  8041604508:	c3                   	retq   

0000008041604509 <find_function>:

uintptr_t
find_function(const char *const fname) {
  8041604509:	55                   	push   %rbp
  804160450a:	48 89 e5             	mov    %rsp,%rbp
  // address_by_fname, which looks for function name in section .debug_pubnames
  // and naive_address_by_fname which performs full traversal of DIE tree.
  // LAB 3: Your code here

  return 0;
}
  804160450d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604512:	5d                   	pop    %rbp
  8041604513:	c3                   	retq   

0000008041604514 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8041604514:	55                   	push   %rbp
  8041604515:	48 89 e5             	mov    %rsp,%rbp
  8041604518:	41 57                	push   %r15
  804160451a:	41 56                	push   %r14
  804160451c:	41 55                	push   %r13
  804160451e:	41 54                	push   %r12
  8041604520:	53                   	push   %rbx
  8041604521:	48 83 ec 18          	sub    $0x18,%rsp
  8041604525:	49 89 fc             	mov    %rdi,%r12
  8041604528:	49 89 f5             	mov    %rsi,%r13
  804160452b:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160452f:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8041604532:	41 89 cf             	mov    %ecx,%r15d
  8041604535:	49 39 d7             	cmp    %rdx,%r15
  8041604538:	76 45                	jbe    804160457f <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  804160453a:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160453e:	85 db                	test   %ebx,%ebx
  8041604540:	7e 0e                	jle    8041604550 <printnum+0x3c>
      putch(padc, putdat);
  8041604542:	4c 89 ee             	mov    %r13,%rsi
  8041604545:	44 89 f7             	mov    %r14d,%edi
  8041604548:	41 ff d4             	callq  *%r12
    while (--width > 0)
  804160454b:	83 eb 01             	sub    $0x1,%ebx
  804160454e:	75 f2                	jne    8041604542 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  8041604550:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041604554:	ba 00 00 00 00       	mov    $0x0,%edx
  8041604559:	49 f7 f7             	div    %r15
  804160455c:	48 b8 78 5e 60 41 80 	movabs $0x8041605e78,%rax
  8041604563:	00 00 00 
  8041604566:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  804160456a:	4c 89 ee             	mov    %r13,%rsi
  804160456d:	41 ff d4             	callq  *%r12
}
  8041604570:	48 83 c4 18          	add    $0x18,%rsp
  8041604574:	5b                   	pop    %rbx
  8041604575:	41 5c                	pop    %r12
  8041604577:	41 5d                	pop    %r13
  8041604579:	41 5e                	pop    %r14
  804160457b:	41 5f                	pop    %r15
  804160457d:	5d                   	pop    %rbp
  804160457e:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  804160457f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041604583:	ba 00 00 00 00       	mov    $0x0,%edx
  8041604588:	49 f7 f7             	div    %r15
  804160458b:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  804160458f:	48 89 c2             	mov    %rax,%rdx
  8041604592:	48 b8 14 45 60 41 80 	movabs $0x8041604514,%rax
  8041604599:	00 00 00 
  804160459c:	ff d0                	callq  *%rax
  804160459e:	eb b0                	jmp    8041604550 <printnum+0x3c>

00000080416045a0 <sprintputch>:
  char *ebuf;
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  80416045a0:	55                   	push   %rbp
  80416045a1:	48 89 e5             	mov    %rsp,%rbp
  b->cnt++;
  80416045a4:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80416045a8:	48 8b 06             	mov    (%rsi),%rax
  80416045ab:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80416045af:	73 0a                	jae    80416045bb <sprintputch+0x1b>
    *b->buf++ = ch;
  80416045b1:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80416045b5:	48 89 16             	mov    %rdx,(%rsi)
  80416045b8:	40 88 38             	mov    %dil,(%rax)
}
  80416045bb:	5d                   	pop    %rbp
  80416045bc:	c3                   	retq   

00000080416045bd <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80416045bd:	55                   	push   %rbp
  80416045be:	48 89 e5             	mov    %rsp,%rbp
  80416045c1:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80416045c8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80416045cf:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80416045d6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80416045dd:	84 c0                	test   %al,%al
  80416045df:	74 20                	je     8041604601 <printfmt+0x44>
  80416045e1:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80416045e5:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80416045e9:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80416045ed:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80416045f1:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80416045f5:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80416045f9:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80416045fd:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8041604601:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041604608:	00 00 00 
  804160460b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041604612:	00 00 00 
  8041604615:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041604619:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041604620:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041604627:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  804160462e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8041604635:	48 b8 43 46 60 41 80 	movabs $0x8041604643,%rax
  804160463c:	00 00 00 
  804160463f:	ff d0                	callq  *%rax
}
  8041604641:	c9                   	leaveq 
  8041604642:	c3                   	retq   

0000008041604643 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  8041604643:	55                   	push   %rbp
  8041604644:	48 89 e5             	mov    %rsp,%rbp
  8041604647:	41 57                	push   %r15
  8041604649:	41 56                	push   %r14
  804160464b:	41 55                	push   %r13
  804160464d:	41 54                	push   %r12
  804160464f:	53                   	push   %rbx
  8041604650:	48 83 ec 48          	sub    $0x48,%rsp
  8041604654:	49 89 ff             	mov    %rdi,%r15
  8041604657:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  804160465b:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  804160465e:	48 8b 01             	mov    (%rcx),%rax
  8041604661:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041604665:	48 8b 41 08          	mov    0x8(%rcx),%rax
  8041604669:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160466d:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041604671:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041604675:	e9 18 05 00 00       	jmpq   8041604b92 <vprintfmt+0x54f>
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160467a:	4d 89 e6             	mov    %r12,%r14
  804160467d:	e9 10 05 00 00       	jmpq   8041604b92 <vprintfmt+0x54f>
        precision = va_arg(aq, int);
  8041604682:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041604686:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
  804160468a:	c7 45 9c 00 00 00 00 	movl   $0x0,-0x64(%rbp)
  8041604691:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8041604696:	41 89 dd             	mov    %ebx,%r13d
  8041604699:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  804160469e:	41 ba 01 00 00 00    	mov    $0x1,%r10d
  80416046a4:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        padc = '0';
  80416046aa:	41 b8 30 00 00 00    	mov    $0x30,%r8d
        padc = '-';
  80416046b0:	bf 2d 00 00 00       	mov    $0x2d,%edi
    switch (ch = *(unsigned char *)fmt++) {
  80416046b5:	4d 8d 74 24 01       	lea    0x1(%r12),%r14
  80416046ba:	41 0f b6 14 24       	movzbl (%r12),%edx
  80416046bf:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80416046c2:	3c 55                	cmp    $0x55,%al
  80416046c4:	0f 87 9b 05 00 00    	ja     8041604c65 <vprintfmt+0x622>
  80416046ca:	0f b6 c0             	movzbl %al,%eax
  80416046cd:	49 bb 20 5f 60 41 80 	movabs $0x8041605f20,%r11
  80416046d4:	00 00 00 
  80416046d7:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  80416046db:	4d 89 f4             	mov    %r14,%r12
        padc = '-';
  80416046de:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  80416046e2:	eb d1                	jmp    80416046b5 <vprintfmt+0x72>
    switch (ch = *(unsigned char *)fmt++) {
  80416046e4:	4d 89 f4             	mov    %r14,%r12
        padc = '0';
  80416046e7:	44 88 45 a0          	mov    %r8b,-0x60(%rbp)
  80416046eb:	eb c8                	jmp    80416046b5 <vprintfmt+0x72>
    switch (ch = *(unsigned char *)fmt++) {
  80416046ed:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  80416046f0:	8d 5a d0             	lea    -0x30(%rdx),%ebx
          ch        = *fmt;
  80416046f3:	41 0f be 44 24 01    	movsbl 0x1(%r12),%eax
          if (ch < '0' || ch > '9')
  80416046f9:	8d 50 d0             	lea    -0x30(%rax),%edx
  80416046fc:	83 fa 09             	cmp    $0x9,%edx
  80416046ff:	77 73                	ja     8041604774 <vprintfmt+0x131>
        for (precision = 0;; ++fmt) {
  8041604701:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8041604705:	8d 14 9b             	lea    (%rbx,%rbx,4),%edx
  8041604708:	8d 5c 50 d0          	lea    -0x30(%rax,%rdx,2),%ebx
          ch        = *fmt;
  804160470c:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8041604710:	8d 50 d0             	lea    -0x30(%rax),%edx
  8041604713:	83 fa 09             	cmp    $0x9,%edx
  8041604716:	76 e9                	jbe    8041604701 <vprintfmt+0xbe>
        for (precision = 0;; ++fmt) {
  8041604718:	4d 89 f4             	mov    %r14,%r12
  804160471b:	eb 18                	jmp    8041604735 <vprintfmt+0xf2>
        precision = va_arg(aq, int);
  804160471d:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604720:	83 fa 2f             	cmp    $0x2f,%edx
  8041604723:	77 26                	ja     804160474b <vprintfmt+0x108>
  8041604725:	89 d0                	mov    %edx,%eax
  8041604727:	48 01 f0             	add    %rsi,%rax
  804160472a:	83 c2 08             	add    $0x8,%edx
  804160472d:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604730:	8b 18                	mov    (%rax),%ebx
    switch (ch = *(unsigned char *)fmt++) {
  8041604732:	4d 89 f4             	mov    %r14,%r12
        if (width < 0)
  8041604735:	45 85 ed             	test   %r13d,%r13d
  8041604738:	0f 89 77 ff ff ff    	jns    80416046b5 <vprintfmt+0x72>
          width = precision, precision = -1;
  804160473e:	41 89 dd             	mov    %ebx,%r13d
  8041604741:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8041604746:	e9 6a ff ff ff       	jmpq   80416046b5 <vprintfmt+0x72>
        precision = va_arg(aq, int);
  804160474b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160474f:	48 8d 50 08          	lea    0x8(%rax),%rdx
  8041604753:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041604757:	eb d7                	jmp    8041604730 <vprintfmt+0xed>
  8041604759:	45 85 ed             	test   %r13d,%r13d
  804160475c:	45 0f 48 e9          	cmovs  %r9d,%r13d
    switch (ch = *(unsigned char *)fmt++) {
  8041604760:	4d 89 f4             	mov    %r14,%r12
  8041604763:	e9 4d ff ff ff       	jmpq   80416046b5 <vprintfmt+0x72>
  8041604768:	4d 89 f4             	mov    %r14,%r12
        altflag = 1;
  804160476b:	44 89 55 9c          	mov    %r10d,-0x64(%rbp)
        goto reswitch;
  804160476f:	e9 41 ff ff ff       	jmpq   80416046b5 <vprintfmt+0x72>
    switch (ch = *(unsigned char *)fmt++) {
  8041604774:	4d 89 f4             	mov    %r14,%r12
  8041604777:	eb bc                	jmp    8041604735 <vprintfmt+0xf2>
        lflag++;
  8041604779:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  804160477c:	4d 89 f4             	mov    %r14,%r12
        goto reswitch;
  804160477f:	e9 31 ff ff ff       	jmpq   80416046b5 <vprintfmt+0x72>
        putch(va_arg(aq, int), putdat);
  8041604784:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604787:	83 fa 2f             	cmp    $0x2f,%edx
  804160478a:	77 19                	ja     80416047a5 <vprintfmt+0x162>
  804160478c:	89 d0                	mov    %edx,%eax
  804160478e:	48 01 f0             	add    %rsi,%rax
  8041604791:	83 c2 08             	add    $0x8,%edx
  8041604794:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604797:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  804160479b:	8b 38                	mov    (%rax),%edi
  804160479d:	41 ff d7             	callq  *%r15
        break;
  80416047a0:	e9 ed 03 00 00       	jmpq   8041604b92 <vprintfmt+0x54f>
        putch(va_arg(aq, int), putdat);
  80416047a5:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416047a9:	48 8d 50 08          	lea    0x8(%rax),%rdx
  80416047ad:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  80416047b1:	eb e4                	jmp    8041604797 <vprintfmt+0x154>
        err = va_arg(aq, int);
  80416047b3:	8b 55 b8             	mov    -0x48(%rbp),%edx
  80416047b6:	83 fa 2f             	cmp    $0x2f,%edx
  80416047b9:	77 55                	ja     8041604810 <vprintfmt+0x1cd>
  80416047bb:	89 d0                	mov    %edx,%eax
  80416047bd:	48 01 c6             	add    %rax,%rsi
  80416047c0:	83 c2 08             	add    $0x8,%edx
  80416047c3:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80416047c6:	8b 06                	mov    (%rsi),%eax
  80416047c8:	99                   	cltd   
  80416047c9:	31 d0                	xor    %edx,%eax
  80416047cb:	29 d0                	sub    %edx,%eax
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80416047cd:	83 f8 08             	cmp    $0x8,%eax
  80416047d0:	7f 4c                	jg     804160481e <vprintfmt+0x1db>
  80416047d2:	48 63 d0             	movslq %eax,%rdx
  80416047d5:	48 b9 e0 61 60 41 80 	movabs $0x80416061e0,%rcx
  80416047dc:	00 00 00 
  80416047df:	48 8b 0c d1          	mov    (%rcx,%rdx,8),%rcx
  80416047e3:	48 85 c9             	test   %rcx,%rcx
  80416047e6:	74 36                	je     804160481e <vprintfmt+0x1db>
          printfmt(putch, putdat, "%s", p);
  80416047e8:	48 ba 4b 57 60 41 80 	movabs $0x804160574b,%rdx
  80416047ef:	00 00 00 
  80416047f2:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  80416047f6:	4c 89 ff             	mov    %r15,%rdi
  80416047f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416047fe:	49 b8 bd 45 60 41 80 	movabs $0x80416045bd,%r8
  8041604805:	00 00 00 
  8041604808:	41 ff d0             	callq  *%r8
  804160480b:	e9 82 03 00 00       	jmpq   8041604b92 <vprintfmt+0x54f>
        err = va_arg(aq, int);
  8041604810:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604814:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604818:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160481c:	eb a8                	jmp    80416047c6 <vprintfmt+0x183>
          printfmt(putch, putdat, "error %d", err);
  804160481e:	89 c1                	mov    %eax,%ecx
  8041604820:	48 ba 90 5e 60 41 80 	movabs $0x8041605e90,%rdx
  8041604827:	00 00 00 
  804160482a:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  804160482e:	4c 89 ff             	mov    %r15,%rdi
  8041604831:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604836:	49 b8 bd 45 60 41 80 	movabs $0x80416045bd,%r8
  804160483d:	00 00 00 
  8041604840:	41 ff d0             	callq  *%r8
  8041604843:	e9 4a 03 00 00       	jmpq   8041604b92 <vprintfmt+0x54f>
        if ((p = va_arg(aq, char *)) == NULL)
  8041604848:	8b 55 b8             	mov    -0x48(%rbp),%edx
  804160484b:	83 fa 2f             	cmp    $0x2f,%edx
  804160484e:	77 47                	ja     8041604897 <vprintfmt+0x254>
  8041604850:	89 d0                	mov    %edx,%eax
  8041604852:	48 01 c6             	add    %rax,%rsi
  8041604855:	83 c2 08             	add    $0x8,%edx
  8041604858:	89 55 b8             	mov    %edx,-0x48(%rbp)
  804160485b:	4c 8b 26             	mov    (%rsi),%r12
  804160485e:	4d 85 e4             	test   %r12,%r12
  8041604861:	0f 84 29 04 00 00    	je     8041604c90 <vprintfmt+0x64d>
        if (width > 0 && padc != '-')
  8041604867:	45 85 ed             	test   %r13d,%r13d
  804160486a:	7e 06                	jle    8041604872 <vprintfmt+0x22f>
  804160486c:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041604870:	75 3d                	jne    80416048af <vprintfmt+0x26c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604872:	49 8d 54 24 01       	lea    0x1(%r12),%rdx
  8041604877:	41 0f b6 04 24       	movzbl (%r12),%eax
  804160487c:	0f be f8             	movsbl %al,%edi
  804160487f:	85 ff                	test   %edi,%edi
  8041604881:	0f 84 c6 00 00 00    	je     804160494d <vprintfmt+0x30a>
  8041604887:	49 89 d4             	mov    %rdx,%r12
  804160488a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160488e:	44 8b 75 9c          	mov    -0x64(%rbp),%r14d
  8041604892:	e9 8b 00 00 00       	jmpq   8041604922 <vprintfmt+0x2df>
        if ((p = va_arg(aq, char *)) == NULL)
  8041604897:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  804160489b:	48 8d 46 08          	lea    0x8(%rsi),%rax
  804160489f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416048a3:	eb b6                	jmp    804160485b <vprintfmt+0x218>
          p = "(null)";
  80416048a5:	49 bc 89 5e 60 41 80 	movabs $0x8041605e89,%r12
  80416048ac:	00 00 00 
          for (width -= strnlen(p, precision); width > 0; width--)
  80416048af:	48 63 f3             	movslq %ebx,%rsi
  80416048b2:	4c 89 e7             	mov    %r12,%rdi
  80416048b5:	48 b8 ff 4e 60 41 80 	movabs $0x8041604eff,%rax
  80416048bc:	00 00 00 
  80416048bf:	ff d0                	callq  *%rax
  80416048c1:	41 29 c5             	sub    %eax,%r13d
  80416048c4:	45 85 ed             	test   %r13d,%r13d
  80416048c7:	7e 28                	jle    80416048f1 <vprintfmt+0x2ae>
            putch(padc, putdat);
  80416048c9:	0f be 45 a0          	movsbl -0x60(%rbp),%eax
  80416048cd:	89 5d a0             	mov    %ebx,-0x60(%rbp)
  80416048d0:	4c 89 65 90          	mov    %r12,-0x70(%rbp)
  80416048d4:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  80416048d8:	41 89 c4             	mov    %eax,%r12d
  80416048db:	48 89 de             	mov    %rbx,%rsi
  80416048de:	44 89 e7             	mov    %r12d,%edi
  80416048e1:	41 ff d7             	callq  *%r15
          for (width -= strnlen(p, precision); width > 0; width--)
  80416048e4:	41 83 ed 01          	sub    $0x1,%r13d
  80416048e8:	75 f1                	jne    80416048db <vprintfmt+0x298>
  80416048ea:	8b 5d a0             	mov    -0x60(%rbp),%ebx
  80416048ed:	4c 8b 65 90          	mov    -0x70(%rbp),%r12
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80416048f1:	49 8d 54 24 01       	lea    0x1(%r12),%rdx
  80416048f6:	41 0f b6 04 24       	movzbl (%r12),%eax
  80416048fb:	0f be f8             	movsbl %al,%edi
  80416048fe:	85 ff                	test   %edi,%edi
  8041604900:	75 85                	jne    8041604887 <vprintfmt+0x244>
  8041604902:	e9 8b 02 00 00       	jmpq   8041604b92 <vprintfmt+0x54f>
            putch(ch, putdat);
  8041604907:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  804160490b:	41 ff d7             	callq  *%r15
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160490e:	41 83 ed 01          	sub    $0x1,%r13d
  8041604912:	41 0f b6 04 24       	movzbl (%r12),%eax
  8041604917:	0f be f8             	movsbl %al,%edi
  804160491a:	49 83 c4 01          	add    $0x1,%r12
  804160491e:	85 ff                	test   %edi,%edi
  8041604920:	74 27                	je     8041604949 <vprintfmt+0x306>
  8041604922:	85 db                	test   %ebx,%ebx
  8041604924:	78 05                	js     804160492b <vprintfmt+0x2e8>
  8041604926:	83 eb 01             	sub    $0x1,%ebx
  8041604929:	78 45                	js     8041604970 <vprintfmt+0x32d>
          if (altflag && (ch < ' ' || ch > '~'))
  804160492b:	45 85 f6             	test   %r14d,%r14d
  804160492e:	74 d7                	je     8041604907 <vprintfmt+0x2c4>
  8041604930:	0f be c0             	movsbl %al,%eax
  8041604933:	83 e8 20             	sub    $0x20,%eax
  8041604936:	83 f8 5e             	cmp    $0x5e,%eax
  8041604939:	76 cc                	jbe    8041604907 <vprintfmt+0x2c4>
            putch('?', putdat);
  804160493b:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  804160493f:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8041604944:	41 ff d7             	callq  *%r15
  8041604947:	eb c5                	jmp    804160490e <vprintfmt+0x2cb>
  8041604949:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  804160494d:	45 85 ed             	test   %r13d,%r13d
  8041604950:	0f 8e 3c 02 00 00    	jle    8041604b92 <vprintfmt+0x54f>
  8041604956:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
          putch(' ', putdat);
  804160495a:	48 89 de             	mov    %rbx,%rsi
  804160495d:	bf 20 00 00 00       	mov    $0x20,%edi
  8041604962:	41 ff d7             	callq  *%r15
        for (; width > 0; width--)
  8041604965:	41 83 ed 01          	sub    $0x1,%r13d
  8041604969:	75 ef                	jne    804160495a <vprintfmt+0x317>
  804160496b:	e9 22 02 00 00       	jmpq   8041604b92 <vprintfmt+0x54f>
  8041604970:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8041604974:	eb d7                	jmp    804160494d <vprintfmt+0x30a>
  if (lflag >= 2)
  8041604976:	83 f9 01             	cmp    $0x1,%ecx
  8041604979:	7f 20                	jg     804160499b <vprintfmt+0x358>
  else if (lflag)
  804160497b:	85 c9                	test   %ecx,%ecx
  804160497d:	75 6d                	jne    80416049ec <vprintfmt+0x3a9>
    return va_arg(*ap, int);
  804160497f:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604982:	83 fa 2f             	cmp    $0x2f,%edx
  8041604985:	0f 87 87 00 00 00    	ja     8041604a12 <vprintfmt+0x3cf>
  804160498b:	89 d0                	mov    %edx,%eax
  804160498d:	48 01 c6             	add    %rax,%rsi
  8041604990:	83 c2 08             	add    $0x8,%edx
  8041604993:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604996:	48 63 1e             	movslq (%rsi),%rbx
  8041604999:	eb 16                	jmp    80416049b1 <vprintfmt+0x36e>
    return va_arg(*ap, long long);
  804160499b:	8b 55 b8             	mov    -0x48(%rbp),%edx
  804160499e:	83 fa 2f             	cmp    $0x2f,%edx
  80416049a1:	77 3b                	ja     80416049de <vprintfmt+0x39b>
  80416049a3:	89 d0                	mov    %edx,%eax
  80416049a5:	48 01 c6             	add    %rax,%rsi
  80416049a8:	83 c2 08             	add    $0x8,%edx
  80416049ab:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80416049ae:	48 8b 1e             	mov    (%rsi),%rbx
        num = getint(&aq, lflag);
  80416049b1:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  80416049b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
        if ((long long)num < 0) {
  80416049b9:	48 85 db             	test   %rbx,%rbx
  80416049bc:	0f 89 b5 01 00 00    	jns    8041604b77 <vprintfmt+0x534>
          putch('-', putdat);
  80416049c2:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  80416049c6:	bf 2d 00 00 00       	mov    $0x2d,%edi
  80416049cb:	41 ff d7             	callq  *%r15
          num = -(long long)num;
  80416049ce:	48 89 da             	mov    %rbx,%rdx
  80416049d1:	48 f7 da             	neg    %rdx
        base = 10;
  80416049d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416049d9:	e9 99 01 00 00       	jmpq   8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, long long);
  80416049de:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  80416049e2:	48 8d 46 08          	lea    0x8(%rsi),%rax
  80416049e6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416049ea:	eb c2                	jmp    80416049ae <vprintfmt+0x36b>
    return va_arg(*ap, long);
  80416049ec:	8b 55 b8             	mov    -0x48(%rbp),%edx
  80416049ef:	83 fa 2f             	cmp    $0x2f,%edx
  80416049f2:	77 10                	ja     8041604a04 <vprintfmt+0x3c1>
  80416049f4:	89 d0                	mov    %edx,%eax
  80416049f6:	48 01 c6             	add    %rax,%rsi
  80416049f9:	83 c2 08             	add    $0x8,%edx
  80416049fc:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80416049ff:	48 8b 1e             	mov    (%rsi),%rbx
  8041604a02:	eb ad                	jmp    80416049b1 <vprintfmt+0x36e>
  8041604a04:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604a08:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604a0c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a10:	eb ed                	jmp    80416049ff <vprintfmt+0x3bc>
    return va_arg(*ap, int);
  8041604a12:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604a16:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604a1a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a1e:	e9 73 ff ff ff       	jmpq   8041604996 <vprintfmt+0x353>
  if (lflag >= 2)
  8041604a23:	83 f9 01             	cmp    $0x1,%ecx
  8041604a26:	7f 23                	jg     8041604a4b <vprintfmt+0x408>
  else if (lflag)
  8041604a28:	85 c9                	test   %ecx,%ecx
  8041604a2a:	75 4d                	jne    8041604a79 <vprintfmt+0x436>
    return va_arg(*ap, unsigned int);
  8041604a2c:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604a2f:	83 fa 2f             	cmp    $0x2f,%edx
  8041604a32:	77 73                	ja     8041604aa7 <vprintfmt+0x464>
  8041604a34:	89 d0                	mov    %edx,%eax
  8041604a36:	48 01 c6             	add    %rax,%rsi
  8041604a39:	83 c2 08             	add    $0x8,%edx
  8041604a3c:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604a3f:	8b 16                	mov    (%rsi),%edx
        base = 10;
  8041604a41:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604a46:	e9 2c 01 00 00       	jmpq   8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604a4b:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604a4e:	83 fa 2f             	cmp    $0x2f,%edx
  8041604a51:	77 18                	ja     8041604a6b <vprintfmt+0x428>
  8041604a53:	89 d0                	mov    %edx,%eax
  8041604a55:	48 01 c6             	add    %rax,%rsi
  8041604a58:	83 c2 08             	add    $0x8,%edx
  8041604a5b:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604a5e:	48 8b 16             	mov    (%rsi),%rdx
        base = 10;
  8041604a61:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604a66:	e9 0c 01 00 00       	jmpq   8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604a6b:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604a6f:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604a73:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a77:	eb e5                	jmp    8041604a5e <vprintfmt+0x41b>
    return va_arg(*ap, unsigned long);
  8041604a79:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604a7c:	83 fa 2f             	cmp    $0x2f,%edx
  8041604a7f:	77 18                	ja     8041604a99 <vprintfmt+0x456>
  8041604a81:	89 d0                	mov    %edx,%eax
  8041604a83:	48 01 c6             	add    %rax,%rsi
  8041604a86:	83 c2 08             	add    $0x8,%edx
  8041604a89:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604a8c:	48 8b 16             	mov    (%rsi),%rdx
        base = 10;
  8041604a8f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604a94:	e9 de 00 00 00       	jmpq   8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long);
  8041604a99:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604a9d:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604aa1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604aa5:	eb e5                	jmp    8041604a8c <vprintfmt+0x449>
    return va_arg(*ap, unsigned int);
  8041604aa7:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604aab:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604aaf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604ab3:	eb 8a                	jmp    8041604a3f <vprintfmt+0x3fc>
  if (lflag >= 2)
  8041604ab5:	83 f9 01             	cmp    $0x1,%ecx
  8041604ab8:	7f 23                	jg     8041604add <vprintfmt+0x49a>
  else if (lflag)
  8041604aba:	85 c9                	test   %ecx,%ecx
  8041604abc:	75 4a                	jne    8041604b08 <vprintfmt+0x4c5>
    return va_arg(*ap, unsigned int);
  8041604abe:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604ac1:	83 fa 2f             	cmp    $0x2f,%edx
  8041604ac4:	77 6d                	ja     8041604b33 <vprintfmt+0x4f0>
  8041604ac6:	89 d0                	mov    %edx,%eax
  8041604ac8:	48 01 c6             	add    %rax,%rsi
  8041604acb:	83 c2 08             	add    $0x8,%edx
  8041604ace:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604ad1:	8b 16                	mov    (%rsi),%edx
        base = 8;
  8041604ad3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604ad8:	e9 9a 00 00 00       	jmpq   8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604add:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604ae0:	83 fa 2f             	cmp    $0x2f,%edx
  8041604ae3:	77 15                	ja     8041604afa <vprintfmt+0x4b7>
  8041604ae5:	89 d0                	mov    %edx,%eax
  8041604ae7:	48 01 c6             	add    %rax,%rsi
  8041604aea:	83 c2 08             	add    $0x8,%edx
  8041604aed:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604af0:	48 8b 16             	mov    (%rsi),%rdx
        base = 8;
  8041604af3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604af8:	eb 7d                	jmp    8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604afa:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604afe:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604b02:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604b06:	eb e8                	jmp    8041604af0 <vprintfmt+0x4ad>
    return va_arg(*ap, unsigned long);
  8041604b08:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604b0b:	83 fa 2f             	cmp    $0x2f,%edx
  8041604b0e:	77 15                	ja     8041604b25 <vprintfmt+0x4e2>
  8041604b10:	89 d0                	mov    %edx,%eax
  8041604b12:	48 01 c6             	add    %rax,%rsi
  8041604b15:	83 c2 08             	add    $0x8,%edx
  8041604b18:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604b1b:	48 8b 16             	mov    (%rsi),%rdx
        base = 8;
  8041604b1e:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604b23:	eb 52                	jmp    8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long);
  8041604b25:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604b29:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604b2d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604b31:	eb e8                	jmp    8041604b1b <vprintfmt+0x4d8>
    return va_arg(*ap, unsigned int);
  8041604b33:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604b37:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604b3b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604b3f:	eb 90                	jmp    8041604ad1 <vprintfmt+0x48e>
        putch('0', putdat);
  8041604b41:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041604b45:	48 89 de             	mov    %rbx,%rsi
  8041604b48:	bf 30 00 00 00       	mov    $0x30,%edi
  8041604b4d:	41 ff d7             	callq  *%r15
        putch('x', putdat);
  8041604b50:	48 89 de             	mov    %rbx,%rsi
  8041604b53:	bf 78 00 00 00       	mov    $0x78,%edi
  8041604b58:	41 ff d7             	callq  *%r15
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041604b5b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604b5e:	83 f8 2f             	cmp    $0x2f,%eax
  8041604b61:	77 54                	ja     8041604bb7 <vprintfmt+0x574>
  8041604b63:	89 c2                	mov    %eax,%edx
  8041604b65:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604b69:	83 c0 08             	add    $0x8,%eax
  8041604b6c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604b6f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041604b72:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8041604b77:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8041604b7c:	45 89 e8             	mov    %r13d,%r8d
  8041604b7f:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604b83:	4c 89 ff             	mov    %r15,%rdi
  8041604b86:	48 b8 14 45 60 41 80 	movabs $0x8041604514,%rax
  8041604b8d:	00 00 00 
  8041604b90:	ff d0                	callq  *%rax
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8041604b92:	4d 8d 66 01          	lea    0x1(%r14),%r12
  8041604b96:	41 0f b6 3e          	movzbl (%r14),%edi
  8041604b9a:	83 ff 25             	cmp    $0x25,%edi
  8041604b9d:	0f 84 df fa ff ff    	je     8041604682 <vprintfmt+0x3f>
      if (ch == '\0')
  8041604ba3:	85 ff                	test   %edi,%edi
  8041604ba5:	0f 84 0d 01 00 00    	je     8041604cb8 <vprintfmt+0x675>
      putch(ch, putdat);
  8041604bab:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604baf:	41 ff d7             	callq  *%r15
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8041604bb2:	4d 89 e6             	mov    %r12,%r14
  8041604bb5:	eb db                	jmp    8041604b92 <vprintfmt+0x54f>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041604bb7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604bbb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604bbf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604bc3:	eb aa                	jmp    8041604b6f <vprintfmt+0x52c>
  if (lflag >= 2)
  8041604bc5:	83 f9 01             	cmp    $0x1,%ecx
  8041604bc8:	7f 20                	jg     8041604bea <vprintfmt+0x5a7>
  else if (lflag)
  8041604bca:	85 c9                	test   %ecx,%ecx
  8041604bcc:	75 4a                	jne    8041604c18 <vprintfmt+0x5d5>
    return va_arg(*ap, unsigned int);
  8041604bce:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604bd1:	83 f8 2f             	cmp    $0x2f,%eax
  8041604bd4:	77 70                	ja     8041604c46 <vprintfmt+0x603>
  8041604bd6:	89 c2                	mov    %eax,%edx
  8041604bd8:	48 01 d6             	add    %rdx,%rsi
  8041604bdb:	83 c0 08             	add    $0x8,%eax
  8041604bde:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604be1:	8b 16                	mov    (%rsi),%edx
        base = 16;
  8041604be3:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604be8:	eb 8d                	jmp    8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604bea:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604bed:	83 fa 2f             	cmp    $0x2f,%edx
  8041604bf0:	77 18                	ja     8041604c0a <vprintfmt+0x5c7>
  8041604bf2:	89 d0                	mov    %edx,%eax
  8041604bf4:	48 01 c6             	add    %rax,%rsi
  8041604bf7:	83 c2 08             	add    $0x8,%edx
  8041604bfa:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604bfd:	48 8b 16             	mov    (%rsi),%rdx
        base = 16;
  8041604c00:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604c05:	e9 6d ff ff ff       	jmpq   8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604c0a:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604c0e:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604c12:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604c16:	eb e5                	jmp    8041604bfd <vprintfmt+0x5ba>
    return va_arg(*ap, unsigned long);
  8041604c18:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604c1b:	83 fa 2f             	cmp    $0x2f,%edx
  8041604c1e:	77 18                	ja     8041604c38 <vprintfmt+0x5f5>
  8041604c20:	89 d0                	mov    %edx,%eax
  8041604c22:	48 01 c6             	add    %rax,%rsi
  8041604c25:	83 c2 08             	add    $0x8,%edx
  8041604c28:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604c2b:	48 8b 16             	mov    (%rsi),%rdx
        base = 16;
  8041604c2e:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604c33:	e9 3f ff ff ff       	jmpq   8041604b77 <vprintfmt+0x534>
    return va_arg(*ap, unsigned long);
  8041604c38:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604c3c:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604c40:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604c44:	eb e5                	jmp    8041604c2b <vprintfmt+0x5e8>
    return va_arg(*ap, unsigned int);
  8041604c46:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604c4a:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604c4e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604c52:	eb 8d                	jmp    8041604be1 <vprintfmt+0x59e>
        putch(ch, putdat);
  8041604c54:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604c58:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604c5d:	41 ff d7             	callq  *%r15
        break;
  8041604c60:	e9 2d ff ff ff       	jmpq   8041604b92 <vprintfmt+0x54f>
        putch('%', putdat);
  8041604c65:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604c69:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604c6e:	41 ff d7             	callq  *%r15
        for (fmt--; fmt[-1] != '%'; fmt--)
  8041604c71:	41 80 7c 24 ff 25    	cmpb   $0x25,-0x1(%r12)
  8041604c77:	0f 84 fd f9 ff ff    	je     804160467a <vprintfmt+0x37>
  8041604c7d:	4d 89 e6             	mov    %r12,%r14
  8041604c80:	49 83 ee 01          	sub    $0x1,%r14
  8041604c84:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8041604c89:	75 f5                	jne    8041604c80 <vprintfmt+0x63d>
  8041604c8b:	e9 02 ff ff ff       	jmpq   8041604b92 <vprintfmt+0x54f>
        if (width > 0 && padc != '-')
  8041604c90:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041604c94:	74 09                	je     8041604c9f <vprintfmt+0x65c>
  8041604c96:	45 85 ed             	test   %r13d,%r13d
  8041604c99:	0f 8f 06 fc ff ff    	jg     80416048a5 <vprintfmt+0x262>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604c9f:	48 ba 8a 5e 60 41 80 	movabs $0x8041605e8a,%rdx
  8041604ca6:	00 00 00 
  8041604ca9:	bf 28 00 00 00       	mov    $0x28,%edi
  8041604cae:	b8 28 00 00 00       	mov    $0x28,%eax
  8041604cb3:	e9 cf fb ff ff       	jmpq   8041604887 <vprintfmt+0x244>
}
  8041604cb8:	48 83 c4 48          	add    $0x48,%rsp
  8041604cbc:	5b                   	pop    %rbx
  8041604cbd:	41 5c                	pop    %r12
  8041604cbf:	41 5d                	pop    %r13
  8041604cc1:	41 5e                	pop    %r14
  8041604cc3:	41 5f                	pop    %r15
  8041604cc5:	5d                   	pop    %rbp
  8041604cc6:	c3                   	retq   

0000008041604cc7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8041604cc7:	55                   	push   %rbp
  8041604cc8:	48 89 e5             	mov    %rsp,%rbp
  8041604ccb:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  8041604ccf:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  8041604cd3:	48 63 c6             	movslq %esi,%rax
  8041604cd6:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  8041604cdb:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8041604cdf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  8041604ce6:	48 85 ff             	test   %rdi,%rdi
  8041604ce9:	74 2a                	je     8041604d15 <vsnprintf+0x4e>
  8041604ceb:	85 f6                	test   %esi,%esi
  8041604ced:	7e 26                	jle    8041604d15 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  8041604cef:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  8041604cf3:	48 bf a0 45 60 41 80 	movabs $0x80416045a0,%rdi
  8041604cfa:	00 00 00 
  8041604cfd:	48 b8 43 46 60 41 80 	movabs $0x8041604643,%rax
  8041604d04:	00 00 00 
  8041604d07:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  8041604d09:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8041604d0d:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  8041604d10:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  8041604d13:	c9                   	leaveq 
  8041604d14:	c3                   	retq   
    return -E_INVAL;
  8041604d15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041604d1a:	eb f7                	jmp    8041604d13 <vsnprintf+0x4c>

0000008041604d1c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  8041604d1c:	55                   	push   %rbp
  8041604d1d:	48 89 e5             	mov    %rsp,%rbp
  8041604d20:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041604d27:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041604d2e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041604d35:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604d3c:	84 c0                	test   %al,%al
  8041604d3e:	74 20                	je     8041604d60 <snprintf+0x44>
  8041604d40:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604d44:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604d48:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604d4c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041604d50:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604d54:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604d58:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604d5c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  8041604d60:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041604d67:	00 00 00 
  8041604d6a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041604d71:	00 00 00 
  8041604d74:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041604d78:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041604d7f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041604d86:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  8041604d8d:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8041604d94:	48 b8 c7 4c 60 41 80 	movabs $0x8041604cc7,%rax
  8041604d9b:	00 00 00 
  8041604d9e:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  8041604da0:	c9                   	leaveq 
  8041604da1:	c3                   	retq   

0000008041604da2 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  8041604da2:	55                   	push   %rbp
  8041604da3:	48 89 e5             	mov    %rsp,%rbp
  8041604da6:	41 57                	push   %r15
  8041604da8:	41 56                	push   %r14
  8041604daa:	41 55                	push   %r13
  8041604dac:	41 54                	push   %r12
  8041604dae:	53                   	push   %rbx
  8041604daf:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  8041604db3:	48 85 ff             	test   %rdi,%rdi
  8041604db6:	74 1e                	je     8041604dd6 <readline+0x34>
    cprintf("%s", prompt);
  8041604db8:	48 89 fe             	mov    %rdi,%rsi
  8041604dbb:	48 bf 4b 57 60 41 80 	movabs $0x804160574b,%rdi
  8041604dc2:	00 00 00 
  8041604dc5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604dca:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041604dd1:	00 00 00 
  8041604dd4:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  8041604dd6:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604ddb:	48 b8 35 0c 60 41 80 	movabs $0x8041600c35,%rax
  8041604de2:	00 00 00 
  8041604de5:	ff d0                	callq  *%rax
  8041604de7:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  8041604dea:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  8041604df0:	49 bd 15 0c 60 41 80 	movabs $0x8041600c15,%r13
  8041604df7:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  8041604dfa:	49 bf 03 0c 60 41 80 	movabs $0x8041600c03,%r15
  8041604e01:	00 00 00 
  8041604e04:	eb 3f                	jmp    8041604e45 <readline+0xa3>
      cprintf("read error: %i\n", c);
  8041604e06:	89 c6                	mov    %eax,%esi
  8041604e08:	48 bf 28 62 60 41 80 	movabs $0x8041606228,%rdi
  8041604e0f:	00 00 00 
  8041604e12:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e17:	48 ba 0b 41 60 41 80 	movabs $0x804160410b,%rdx
  8041604e1e:	00 00 00 
  8041604e21:	ff d2                	callq  *%rdx
      return NULL;
  8041604e23:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  8041604e28:	48 83 c4 08          	add    $0x8,%rsp
  8041604e2c:	5b                   	pop    %rbx
  8041604e2d:	41 5c                	pop    %r12
  8041604e2f:	41 5d                	pop    %r13
  8041604e31:	41 5e                	pop    %r14
  8041604e33:	41 5f                	pop    %r15
  8041604e35:	5d                   	pop    %rbp
  8041604e36:	c3                   	retq   
      if (i > 0) {
  8041604e37:	45 85 e4             	test   %r12d,%r12d
  8041604e3a:	7e 09                	jle    8041604e45 <readline+0xa3>
        if (echoing) {
  8041604e3c:	45 85 f6             	test   %r14d,%r14d
  8041604e3f:	75 41                	jne    8041604e82 <readline+0xe0>
        i--;
  8041604e41:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  8041604e45:	41 ff d5             	callq  *%r13
  8041604e48:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  8041604e4a:	85 c0                	test   %eax,%eax
  8041604e4c:	78 b8                	js     8041604e06 <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  8041604e4e:	83 f8 08             	cmp    $0x8,%eax
  8041604e51:	74 e4                	je     8041604e37 <readline+0x95>
  8041604e53:	83 f8 7f             	cmp    $0x7f,%eax
  8041604e56:	74 df                	je     8041604e37 <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  8041604e58:	83 f8 1f             	cmp    $0x1f,%eax
  8041604e5b:	7e 46                	jle    8041604ea3 <readline+0x101>
  8041604e5d:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  8041604e64:	7f 3d                	jg     8041604ea3 <readline+0x101>
      if (echoing)
  8041604e66:	45 85 f6             	test   %r14d,%r14d
  8041604e69:	75 31                	jne    8041604e9c <readline+0xfa>
      buf[i++] = c;
  8041604e6b:	49 63 c4             	movslq %r12d,%rax
  8041604e6e:	48 b9 e0 31 62 41 80 	movabs $0x80416231e0,%rcx
  8041604e75:	00 00 00 
  8041604e78:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  8041604e7b:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  8041604e80:	eb c3                	jmp    8041604e45 <readline+0xa3>
          cputchar('\b');
  8041604e82:	bf 08 00 00 00       	mov    $0x8,%edi
  8041604e87:	41 ff d7             	callq  *%r15
          cputchar(' ');
  8041604e8a:	bf 20 00 00 00       	mov    $0x20,%edi
  8041604e8f:	41 ff d7             	callq  *%r15
          cputchar('\b');
  8041604e92:	bf 08 00 00 00       	mov    $0x8,%edi
  8041604e97:	41 ff d7             	callq  *%r15
  8041604e9a:	eb a5                	jmp    8041604e41 <readline+0x9f>
        cputchar(c);
  8041604e9c:	89 c7                	mov    %eax,%edi
  8041604e9e:	41 ff d7             	callq  *%r15
  8041604ea1:	eb c8                	jmp    8041604e6b <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  8041604ea3:	83 fb 0a             	cmp    $0xa,%ebx
  8041604ea6:	74 05                	je     8041604ead <readline+0x10b>
  8041604ea8:	83 fb 0d             	cmp    $0xd,%ebx
  8041604eab:	75 98                	jne    8041604e45 <readline+0xa3>
      if (echoing)
  8041604ead:	45 85 f6             	test   %r14d,%r14d
  8041604eb0:	75 17                	jne    8041604ec9 <readline+0x127>
      buf[i] = 0;
  8041604eb2:	48 b8 e0 31 62 41 80 	movabs $0x80416231e0,%rax
  8041604eb9:	00 00 00 
  8041604ebc:	4d 63 e4             	movslq %r12d,%r12
  8041604ebf:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  8041604ec4:	e9 5f ff ff ff       	jmpq   8041604e28 <readline+0x86>
        cputchar('\n');
  8041604ec9:	bf 0a 00 00 00       	mov    $0xa,%edi
  8041604ece:	48 b8 03 0c 60 41 80 	movabs $0x8041600c03,%rax
  8041604ed5:	00 00 00 
  8041604ed8:	ff d0                	callq  *%rax
  8041604eda:	eb d6                	jmp    8041604eb2 <readline+0x110>

0000008041604edc <strlen>:
// but it makes an even bigger difference on bochs.
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s) {
  8041604edc:	55                   	push   %rbp
  8041604edd:	48 89 e5             	mov    %rsp,%rbp
  int n;

  for (n = 0; *s != '\0'; s++)
  8041604ee0:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604ee3:	74 13                	je     8041604ef8 <strlen+0x1c>
  8041604ee5:	b8 00 00 00 00       	mov    $0x0,%eax
    n++;
  8041604eea:	83 c0 01             	add    $0x1,%eax
  for (n = 0; *s != '\0'; s++)
  8041604eed:	48 83 c7 01          	add    $0x1,%rdi
  8041604ef1:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604ef4:	75 f4                	jne    8041604eea <strlen+0xe>
  return n;
}
  8041604ef6:	5d                   	pop    %rbp
  8041604ef7:	c3                   	retq   
  for (n = 0; *s != '\0'; s++)
  8041604ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
  8041604efd:	eb f7                	jmp    8041604ef6 <strlen+0x1a>

0000008041604eff <strnlen>:

int
strnlen(const char *s, size_t size) {
  8041604eff:	55                   	push   %rbp
  8041604f00:	48 89 e5             	mov    %rsp,%rbp
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041604f03:	48 85 f6             	test   %rsi,%rsi
  8041604f06:	74 20                	je     8041604f28 <strnlen+0x29>
  8041604f08:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604f0b:	74 22                	je     8041604f2f <strnlen+0x30>
  8041604f0d:	48 01 fe             	add    %rdi,%rsi
  8041604f10:	b8 00 00 00 00       	mov    $0x0,%eax
    n++;
  8041604f15:	83 c0 01             	add    $0x1,%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041604f18:	48 83 c7 01          	add    $0x1,%rdi
  8041604f1c:	48 39 fe             	cmp    %rdi,%rsi
  8041604f1f:	74 05                	je     8041604f26 <strnlen+0x27>
  8041604f21:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604f24:	75 ef                	jne    8041604f15 <strnlen+0x16>
  return n;
}
  8041604f26:	5d                   	pop    %rbp
  8041604f27:	c3                   	retq   
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041604f28:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f2d:	eb f7                	jmp    8041604f26 <strnlen+0x27>
  8041604f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
  8041604f34:	eb f0                	jmp    8041604f26 <strnlen+0x27>

0000008041604f36 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  8041604f36:	55                   	push   %rbp
  8041604f37:	48 89 e5             	mov    %rsp,%rbp
  8041604f3a:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8041604f3d:	48 89 fa             	mov    %rdi,%rdx
  8041604f40:	48 83 c2 01          	add    $0x1,%rdx
  8041604f44:	48 83 c6 01          	add    $0x1,%rsi
  8041604f48:	0f b6 4e ff          	movzbl -0x1(%rsi),%ecx
  8041604f4c:	88 4a ff             	mov    %cl,-0x1(%rdx)
  8041604f4f:	84 c9                	test   %cl,%cl
  8041604f51:	75 ed                	jne    8041604f40 <strcpy+0xa>
    /* do nothing */;
  return ret;
}
  8041604f53:	5d                   	pop    %rbp
  8041604f54:	c3                   	retq   

0000008041604f55 <strcat>:

char *
strcat(char *dst, const char *src) {
  8041604f55:	55                   	push   %rbp
  8041604f56:	48 89 e5             	mov    %rsp,%rbp
  8041604f59:	41 54                	push   %r12
  8041604f5b:	53                   	push   %rbx
  8041604f5c:	48 89 fb             	mov    %rdi,%rbx
  8041604f5f:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  8041604f62:	48 b8 dc 4e 60 41 80 	movabs $0x8041604edc,%rax
  8041604f69:	00 00 00 
  8041604f6c:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  8041604f6e:	48 63 f8             	movslq %eax,%rdi
  8041604f71:	48 01 df             	add    %rbx,%rdi
  8041604f74:	4c 89 e6             	mov    %r12,%rsi
  8041604f77:	48 b8 36 4f 60 41 80 	movabs $0x8041604f36,%rax
  8041604f7e:	00 00 00 
  8041604f81:	ff d0                	callq  *%rax
  return dst;
}
  8041604f83:	48 89 d8             	mov    %rbx,%rax
  8041604f86:	5b                   	pop    %rbx
  8041604f87:	41 5c                	pop    %r12
  8041604f89:	5d                   	pop    %rbp
  8041604f8a:	c3                   	retq   

0000008041604f8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8041604f8b:	55                   	push   %rbp
  8041604f8c:	48 89 e5             	mov    %rsp,%rbp
  8041604f8f:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8041604f92:	48 85 d2             	test   %rdx,%rdx
  8041604f95:	74 1e                	je     8041604fb5 <strncpy+0x2a>
  8041604f97:	48 01 fa             	add    %rdi,%rdx
  8041604f9a:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  8041604f9d:	48 83 c1 01          	add    $0x1,%rcx
  8041604fa1:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041604fa5:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8041604fa9:	80 3e 01             	cmpb   $0x1,(%rsi)
  8041604fac:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  8041604fb0:	48 39 ca             	cmp    %rcx,%rdx
  8041604fb3:	75 e8                	jne    8041604f9d <strncpy+0x12>
  }
  return ret;
}
  8041604fb5:	5d                   	pop    %rbp
  8041604fb6:	c3                   	retq   

0000008041604fb7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size) {
  8041604fb7:	55                   	push   %rbp
  8041604fb8:	48 89 e5             	mov    %rsp,%rbp
  8041604fbb:	48 89 f8             	mov    %rdi,%rax
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8041604fbe:	48 85 d2             	test   %rdx,%rdx
  8041604fc1:	74 34                	je     8041604ff7 <strlcpy+0x40>
    while (--size > 0 && *src != '\0')
  8041604fc3:	48 83 ea 01          	sub    $0x1,%rdx
  8041604fc7:	74 33                	je     8041604ffc <strlcpy+0x45>
  8041604fc9:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041604fcd:	45 84 c0             	test   %r8b,%r8b
  8041604fd0:	74 2f                	je     8041605001 <strlcpy+0x4a>
  8041604fd2:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  8041604fd6:	48 01 d6             	add    %rdx,%rsi
      *dst++ = *src++;
  8041604fd9:	48 83 c0 01          	add    $0x1,%rax
  8041604fdd:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  8041604fe1:	48 39 ce             	cmp    %rcx,%rsi
  8041604fe4:	74 0e                	je     8041604ff4 <strlcpy+0x3d>
  8041604fe6:	48 83 c1 01          	add    $0x1,%rcx
  8041604fea:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  8041604fef:	45 84 c0             	test   %r8b,%r8b
  8041604ff2:	75 e5                	jne    8041604fd9 <strlcpy+0x22>
    *dst = '\0';
  8041604ff4:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  8041604ff7:	48 29 f8             	sub    %rdi,%rax
}
  8041604ffa:	5d                   	pop    %rbp
  8041604ffb:	c3                   	retq   
    while (--size > 0 && *src != '\0')
  8041604ffc:	48 89 f8             	mov    %rdi,%rax
  8041604fff:	eb f3                	jmp    8041604ff4 <strlcpy+0x3d>
  8041605001:	48 89 f8             	mov    %rdi,%rax
  8041605004:	eb ee                	jmp    8041604ff4 <strlcpy+0x3d>

0000008041605006 <strcmp>:
  }
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  8041605006:	55                   	push   %rbp
  8041605007:	48 89 e5             	mov    %rsp,%rbp
  while (*p && *p == *q)
  804160500a:	0f b6 07             	movzbl (%rdi),%eax
  804160500d:	84 c0                	test   %al,%al
  804160500f:	74 17                	je     8041605028 <strcmp+0x22>
  8041605011:	3a 06                	cmp    (%rsi),%al
  8041605013:	75 13                	jne    8041605028 <strcmp+0x22>
    p++, q++;
  8041605015:	48 83 c7 01          	add    $0x1,%rdi
  8041605019:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  804160501d:	0f b6 07             	movzbl (%rdi),%eax
  8041605020:	84 c0                	test   %al,%al
  8041605022:	74 04                	je     8041605028 <strcmp+0x22>
  8041605024:	3a 06                	cmp    (%rsi),%al
  8041605026:	74 ed                	je     8041605015 <strcmp+0xf>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8041605028:	0f b6 c0             	movzbl %al,%eax
  804160502b:	0f b6 16             	movzbl (%rsi),%edx
  804160502e:	29 d0                	sub    %edx,%eax
}
  8041605030:	5d                   	pop    %rbp
  8041605031:	c3                   	retq   

0000008041605032 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  8041605032:	55                   	push   %rbp
  8041605033:	48 89 e5             	mov    %rsp,%rbp
  while (n > 0 && *p && *p == *q)
  8041605036:	48 85 d2             	test   %rdx,%rdx
  8041605039:	74 30                	je     804160506b <strncmp+0x39>
  804160503b:	0f b6 07             	movzbl (%rdi),%eax
  804160503e:	84 c0                	test   %al,%al
  8041605040:	74 1f                	je     8041605061 <strncmp+0x2f>
  8041605042:	3a 06                	cmp    (%rsi),%al
  8041605044:	75 1b                	jne    8041605061 <strncmp+0x2f>
  8041605046:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8041605049:	48 83 c7 01          	add    $0x1,%rdi
  804160504d:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8041605051:	48 39 d7             	cmp    %rdx,%rdi
  8041605054:	74 1c                	je     8041605072 <strncmp+0x40>
  8041605056:	0f b6 07             	movzbl (%rdi),%eax
  8041605059:	84 c0                	test   %al,%al
  804160505b:	74 04                	je     8041605061 <strncmp+0x2f>
  804160505d:	3a 06                	cmp    (%rsi),%al
  804160505f:	74 e8                	je     8041605049 <strncmp+0x17>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8041605061:	0f b6 07             	movzbl (%rdi),%eax
  8041605064:	0f b6 16             	movzbl (%rsi),%edx
  8041605067:	29 d0                	sub    %edx,%eax
}
  8041605069:	5d                   	pop    %rbp
  804160506a:	c3                   	retq   
    return 0;
  804160506b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605070:	eb f7                	jmp    8041605069 <strncmp+0x37>
  8041605072:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605077:	eb f0                	jmp    8041605069 <strncmp+0x37>

0000008041605079 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8041605079:	55                   	push   %rbp
  804160507a:	48 89 e5             	mov    %rsp,%rbp
  for (; *s; s++)
  804160507d:	0f b6 07             	movzbl (%rdi),%eax
  8041605080:	84 c0                	test   %al,%al
  8041605082:	74 22                	je     80416050a6 <strchr+0x2d>
  8041605084:	89 f2                	mov    %esi,%edx
    if (*s == c)
  8041605086:	40 38 c6             	cmp    %al,%sil
  8041605089:	74 22                	je     80416050ad <strchr+0x34>
  for (; *s; s++)
  804160508b:	48 83 c7 01          	add    $0x1,%rdi
  804160508f:	0f b6 07             	movzbl (%rdi),%eax
  8041605092:	84 c0                	test   %al,%al
  8041605094:	74 09                	je     804160509f <strchr+0x26>
    if (*s == c)
  8041605096:	38 d0                	cmp    %dl,%al
  8041605098:	75 f1                	jne    804160508b <strchr+0x12>
  for (; *s; s++)
  804160509a:	48 89 f8             	mov    %rdi,%rax
  804160509d:	eb 05                	jmp    80416050a4 <strchr+0x2b>
      return (char *)s;
  return 0;
  804160509f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416050a4:	5d                   	pop    %rbp
  80416050a5:	c3                   	retq   
  return 0;
  80416050a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050ab:	eb f7                	jmp    80416050a4 <strchr+0x2b>
    if (*s == c)
  80416050ad:	48 89 f8             	mov    %rdi,%rax
  80416050b0:	eb f2                	jmp    80416050a4 <strchr+0x2b>

00000080416050b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  80416050b2:	55                   	push   %rbp
  80416050b3:	48 89 e5             	mov    %rsp,%rbp
  80416050b6:	48 89 f8             	mov    %rdi,%rax
  for (; *s; s++)
  80416050b9:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  80416050bc:	40 38 f2             	cmp    %sil,%dl
  80416050bf:	74 15                	je     80416050d6 <strfind+0x24>
  80416050c1:	89 f1                	mov    %esi,%ecx
  80416050c3:	84 d2                	test   %dl,%dl
  80416050c5:	74 0f                	je     80416050d6 <strfind+0x24>
  for (; *s; s++)
  80416050c7:	48 83 c0 01          	add    $0x1,%rax
  80416050cb:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  80416050ce:	38 ca                	cmp    %cl,%dl
  80416050d0:	74 04                	je     80416050d6 <strfind+0x24>
  80416050d2:	84 d2                	test   %dl,%dl
  80416050d4:	75 f1                	jne    80416050c7 <strfind+0x15>
      break;
  return (char *)s;
}
  80416050d6:	5d                   	pop    %rbp
  80416050d7:	c3                   	retq   

00000080416050d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  80416050d8:	55                   	push   %rbp
  80416050d9:	48 89 e5             	mov    %rsp,%rbp
  if (n == 0)
  80416050dc:	48 85 d2             	test   %rdx,%rdx
  80416050df:	74 13                	je     80416050f4 <memset+0x1c>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80416050e1:	40 f6 c7 03          	test   $0x3,%dil
  80416050e5:	75 05                	jne    80416050ec <memset+0x14>
  80416050e7:	f6 c2 03             	test   $0x3,%dl
  80416050ea:	74 0d                	je     80416050f9 <memset+0x21>
    uint32_t k = c & 0xFFU;
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  80416050ec:	89 f0                	mov    %esi,%eax
  80416050ee:	48 89 d1             	mov    %rdx,%rcx
  80416050f1:	fc                   	cld    
  80416050f2:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  80416050f4:	48 89 f8             	mov    %rdi,%rax
  80416050f7:	5d                   	pop    %rbp
  80416050f8:	c3                   	retq   
    uint32_t k = c & 0xFFU;
  80416050f9:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  80416050fd:	89 f0                	mov    %esi,%eax
  80416050ff:	c1 e0 08             	shl    $0x8,%eax
  8041605102:	89 f1                	mov    %esi,%ecx
  8041605104:	c1 e1 18             	shl    $0x18,%ecx
  8041605107:	41 89 f0             	mov    %esi,%r8d
  804160510a:	41 c1 e0 10          	shl    $0x10,%r8d
  804160510e:	44 09 c1             	or     %r8d,%ecx
  8041605111:	09 ce                	or     %ecx,%esi
  8041605113:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  8041605115:	48 c1 ea 02          	shr    $0x2,%rdx
  8041605119:	48 89 d1             	mov    %rdx,%rcx
  804160511c:	fc                   	cld    
  804160511d:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160511f:	eb d3                	jmp    80416050f4 <memset+0x1c>

0000008041605121 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  8041605121:	55                   	push   %rbp
  8041605122:	48 89 e5             	mov    %rsp,%rbp
  8041605125:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8041605128:	48 39 fe             	cmp    %rdi,%rsi
  804160512b:	73 43                	jae    8041605170 <memmove+0x4f>
  804160512d:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  8041605131:	48 39 cf             	cmp    %rcx,%rdi
  8041605134:	73 3a                	jae    8041605170 <memmove+0x4f>
    s += n;
    d += n;
  8041605136:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160513a:	48 89 ce             	mov    %rcx,%rsi
  804160513d:	48 09 fe             	or     %rdi,%rsi
  8041605140:	40 f6 c6 03          	test   $0x3,%sil
  8041605144:	75 19                	jne    804160515f <memmove+0x3e>
  8041605146:	f6 c2 03             	test   $0x3,%dl
  8041605149:	75 14                	jne    804160515f <memmove+0x3e>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  804160514b:	48 83 ef 04          	sub    $0x4,%rdi
  804160514f:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8041605153:	48 c1 ea 02          	shr    $0x2,%rdx
  8041605157:	48 89 d1             	mov    %rdx,%rcx
  804160515a:	fd                   	std    
  804160515b:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160515d:	eb 0e                	jmp    804160516d <memmove+0x4c>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  804160515f:	48 83 ef 01          	sub    $0x1,%rdi
  8041605163:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8041605167:	48 89 d1             	mov    %rdx,%rcx
  804160516a:	fd                   	std    
  804160516b:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  804160516d:	fc                   	cld    
  804160516e:	eb 19                	jmp    8041605189 <memmove+0x68>
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8041605170:	48 89 f1             	mov    %rsi,%rcx
  8041605173:	48 09 c1             	or     %rax,%rcx
  8041605176:	f6 c1 03             	test   $0x3,%cl
  8041605179:	75 05                	jne    8041605180 <memmove+0x5f>
  804160517b:	f6 c2 03             	test   $0x3,%dl
  804160517e:	74 0b                	je     804160518b <memmove+0x6a>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8041605180:	48 89 c7             	mov    %rax,%rdi
  8041605183:	48 89 d1             	mov    %rdx,%rcx
  8041605186:	fc                   	cld    
  8041605187:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8041605189:	5d                   	pop    %rbp
  804160518a:	c3                   	retq   
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  804160518b:	48 c1 ea 02          	shr    $0x2,%rdx
  804160518f:	48 89 d1             	mov    %rdx,%rcx
  8041605192:	48 89 c7             	mov    %rax,%rdi
  8041605195:	fc                   	cld    
  8041605196:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8041605198:	eb ef                	jmp    8041605189 <memmove+0x68>

000000804160519a <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  804160519a:	55                   	push   %rbp
  804160519b:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  804160519e:	48 b8 21 51 60 41 80 	movabs $0x8041605121,%rax
  80416051a5:	00 00 00 
  80416051a8:	ff d0                	callq  *%rax
}
  80416051aa:	5d                   	pop    %rbp
  80416051ab:	c3                   	retq   

00000080416051ac <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  80416051ac:	55                   	push   %rbp
  80416051ad:	48 89 e5             	mov    %rsp,%rbp
  80416051b0:	41 57                	push   %r15
  80416051b2:	41 56                	push   %r14
  80416051b4:	41 55                	push   %r13
  80416051b6:	41 54                	push   %r12
  80416051b8:	53                   	push   %rbx
  80416051b9:	49 89 fe             	mov    %rdi,%r14
  80416051bc:	49 89 f7             	mov    %rsi,%r15
  80416051bf:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  80416051c2:	48 89 f7             	mov    %rsi,%rdi
  80416051c5:	48 b8 dc 4e 60 41 80 	movabs $0x8041604edc,%rax
  80416051cc:	00 00 00 
  80416051cf:	ff d0                	callq  *%rax
  80416051d1:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  80416051d4:	4c 89 ee             	mov    %r13,%rsi
  80416051d7:	4c 89 f7             	mov    %r14,%rdi
  80416051da:	48 b8 ff 4e 60 41 80 	movabs $0x8041604eff,%rax
  80416051e1:	00 00 00 
  80416051e4:	ff d0                	callq  *%rax
  80416051e6:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  80416051e9:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  80416051ed:	4d 39 e5             	cmp    %r12,%r13
  80416051f0:	74 26                	je     8041605218 <strlcat+0x6c>
  if (srclen < maxlen - dstlen) {
  80416051f2:	4c 89 e8             	mov    %r13,%rax
  80416051f5:	4c 29 e0             	sub    %r12,%rax
  80416051f8:	48 39 c3             	cmp    %rax,%rbx
  80416051fb:	73 26                	jae    8041605223 <strlcat+0x77>
    memcpy(dst + dstlen, src, srclen + 1);
  80416051fd:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  8041605201:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8041605205:	4c 89 fe             	mov    %r15,%rsi
  8041605208:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160520f:	00 00 00 
  8041605212:	ff d0                	callq  *%rax
  return dstlen + srclen;
  8041605214:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  8041605218:	5b                   	pop    %rbx
  8041605219:	41 5c                	pop    %r12
  804160521b:	41 5d                	pop    %r13
  804160521d:	41 5e                	pop    %r14
  804160521f:	41 5f                	pop    %r15
  8041605221:	5d                   	pop    %rbp
  8041605222:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  8041605223:	49 83 ed 01          	sub    $0x1,%r13
  8041605227:	4d 01 e6             	add    %r12,%r14
  804160522a:	4c 89 ea             	mov    %r13,%rdx
  804160522d:	4c 89 fe             	mov    %r15,%rsi
  8041605230:	4c 89 f7             	mov    %r14,%rdi
  8041605233:	48 b8 9a 51 60 41 80 	movabs $0x804160519a,%rax
  804160523a:	00 00 00 
  804160523d:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  804160523f:	43 c6 04 2e 00       	movb   $0x0,(%r14,%r13,1)
  8041605244:	eb ce                	jmp    8041605214 <strlcat+0x68>

0000008041605246 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n) {
  8041605246:	55                   	push   %rbp
  8041605247:	48 89 e5             	mov    %rsp,%rbp
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  804160524a:	48 85 d2             	test   %rdx,%rdx
  804160524d:	74 3c                	je     804160528b <memcmp+0x45>
    if (*s1 != *s2)
  804160524f:	0f b6 0f             	movzbl (%rdi),%ecx
  8041605252:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041605256:	44 38 c1             	cmp    %r8b,%cl
  8041605259:	75 1d                	jne    8041605278 <memcmp+0x32>
  804160525b:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  8041605260:	48 39 d0             	cmp    %rdx,%rax
  8041605263:	74 1f                	je     8041605284 <memcmp+0x3e>
    if (*s1 != *s2)
  8041605265:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  8041605269:	48 83 c0 01          	add    $0x1,%rax
  804160526d:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8041605273:	44 38 c1             	cmp    %r8b,%cl
  8041605276:	74 e8                	je     8041605260 <memcmp+0x1a>
      return (int)*s1 - (int)*s2;
  8041605278:	0f b6 c1             	movzbl %cl,%eax
  804160527b:	45 0f b6 c0          	movzbl %r8b,%r8d
  804160527f:	44 29 c0             	sub    %r8d,%eax
    s1++, s2++;
  }

  return 0;
}
  8041605282:	5d                   	pop    %rbp
  8041605283:	c3                   	retq   
  return 0;
  8041605284:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605289:	eb f7                	jmp    8041605282 <memcmp+0x3c>
  804160528b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605290:	eb f0                	jmp    8041605282 <memcmp+0x3c>

0000008041605292 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  8041605292:	55                   	push   %rbp
  8041605293:	48 89 e5             	mov    %rsp,%rbp
  8041605296:	48 89 f8             	mov    %rdi,%rax
  const void *ends = (const char *)s + n;
  8041605299:	48 01 fa             	add    %rdi,%rdx
  for (; s < ends; s++)
  804160529c:	48 39 d7             	cmp    %rdx,%rdi
  804160529f:	73 14                	jae    80416052b5 <memfind+0x23>
    if (*(const unsigned char *)s == (unsigned char)c)
  80416052a1:	89 f1                	mov    %esi,%ecx
  80416052a3:	40 38 37             	cmp    %sil,(%rdi)
  80416052a6:	74 0d                	je     80416052b5 <memfind+0x23>
  for (; s < ends; s++)
  80416052a8:	48 83 c0 01          	add    $0x1,%rax
  80416052ac:	48 39 c2             	cmp    %rax,%rdx
  80416052af:	74 04                	je     80416052b5 <memfind+0x23>
    if (*(const unsigned char *)s == (unsigned char)c)
  80416052b1:	38 08                	cmp    %cl,(%rax)
  80416052b3:	75 f3                	jne    80416052a8 <memfind+0x16>
      break;
  return (void *)s;
}
  80416052b5:	5d                   	pop    %rbp
  80416052b6:	c3                   	retq   

00000080416052b7 <strtol>:

long
strtol(const char *s, char **endptr, int base) {
  80416052b7:	55                   	push   %rbp
  80416052b8:	48 89 e5             	mov    %rsp,%rbp
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80416052bb:	0f b6 07             	movzbl (%rdi),%eax
  80416052be:	3c 20                	cmp    $0x20,%al
  80416052c0:	74 04                	je     80416052c6 <strtol+0xf>
  80416052c2:	3c 09                	cmp    $0x9,%al
  80416052c4:	75 0f                	jne    80416052d5 <strtol+0x1e>
    s++;
  80416052c6:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  80416052ca:	0f b6 07             	movzbl (%rdi),%eax
  80416052cd:	3c 20                	cmp    $0x20,%al
  80416052cf:	74 f5                	je     80416052c6 <strtol+0xf>
  80416052d1:	3c 09                	cmp    $0x9,%al
  80416052d3:	74 f1                	je     80416052c6 <strtol+0xf>

  // plus/minus sign
  if (*s == '+')
  80416052d5:	3c 2b                	cmp    $0x2b,%al
  80416052d7:	74 2f                	je     8041605308 <strtol+0x51>
  int neg  = 0;
  80416052d9:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  80416052df:	3c 2d                	cmp    $0x2d,%al
  80416052e1:	74 31                	je     8041605314 <strtol+0x5d>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80416052e3:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  80416052e9:	75 05                	jne    80416052f0 <strtol+0x39>
  80416052eb:	80 3f 30             	cmpb   $0x30,(%rdi)
  80416052ee:	74 30                	je     8041605320 <strtol+0x69>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  80416052f0:	85 d2                	test   %edx,%edx
  80416052f2:	75 0a                	jne    80416052fe <strtol+0x47>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  80416052f4:	ba 0a 00 00 00       	mov    $0xa,%edx
  else if (base == 0 && s[0] == '0')
  80416052f9:	80 3f 30             	cmpb   $0x30,(%rdi)
  80416052fc:	74 2c                	je     804160532a <strtol+0x73>
    base = 10;
  80416052fe:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8041605303:	4c 63 d2             	movslq %edx,%r10
  8041605306:	eb 5c                	jmp    8041605364 <strtol+0xad>
    s++;
  8041605308:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  804160530c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8041605312:	eb cf                	jmp    80416052e3 <strtol+0x2c>
    s++, neg = 1;
  8041605314:	48 83 c7 01          	add    $0x1,%rdi
  8041605318:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160531e:	eb c3                	jmp    80416052e3 <strtol+0x2c>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8041605320:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8041605324:	74 0f                	je     8041605335 <strtol+0x7e>
  else if (base == 0 && s[0] == '0')
  8041605326:	85 d2                	test   %edx,%edx
  8041605328:	75 d4                	jne    80416052fe <strtol+0x47>
    s++, base = 8;
  804160532a:	48 83 c7 01          	add    $0x1,%rdi
  804160532e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041605333:	eb c9                	jmp    80416052fe <strtol+0x47>
    s += 2, base = 16;
  8041605335:	48 83 c7 02          	add    $0x2,%rdi
  8041605339:	ba 10 00 00 00       	mov    $0x10,%edx
  804160533e:	eb be                	jmp    80416052fe <strtol+0x47>
    else if (*s >= 'a' && *s <= 'z')
  8041605340:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  8041605344:	41 80 f8 19          	cmp    $0x19,%r8b
  8041605348:	77 2f                	ja     8041605379 <strtol+0xc2>
      dig = *s - 'a' + 10;
  804160534a:	44 0f be c1          	movsbl %cl,%r8d
  804160534e:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  8041605352:	39 d1                	cmp    %edx,%ecx
  8041605354:	7d 37                	jge    804160538d <strtol+0xd6>
    s++, val = (val * base) + dig;
  8041605356:	48 83 c7 01          	add    $0x1,%rdi
  804160535a:	49 0f af c2          	imul   %r10,%rax
  804160535e:	48 63 c9             	movslq %ecx,%rcx
  8041605361:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  8041605364:	0f b6 0f             	movzbl (%rdi),%ecx
  8041605367:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  804160536b:	41 80 f8 09          	cmp    $0x9,%r8b
  804160536f:	77 cf                	ja     8041605340 <strtol+0x89>
      dig = *s - '0';
  8041605371:	0f be c9             	movsbl %cl,%ecx
  8041605374:	83 e9 30             	sub    $0x30,%ecx
  8041605377:	eb d9                	jmp    8041605352 <strtol+0x9b>
    else if (*s >= 'A' && *s <= 'Z')
  8041605379:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  804160537d:	41 80 f8 19          	cmp    $0x19,%r8b
  8041605381:	77 0a                	ja     804160538d <strtol+0xd6>
      dig = *s - 'A' + 10;
  8041605383:	44 0f be c1          	movsbl %cl,%r8d
  8041605387:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  804160538b:	eb c5                	jmp    8041605352 <strtol+0x9b>
    // we don't properly detect overflow!
  }

  if (endptr)
  804160538d:	48 85 f6             	test   %rsi,%rsi
  8041605390:	74 03                	je     8041605395 <strtol+0xde>
    *endptr = (char *)s;
  8041605392:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8041605395:	48 89 c2             	mov    %rax,%rdx
  8041605398:	48 f7 da             	neg    %rdx
  804160539b:	45 85 c9             	test   %r9d,%r9d
  804160539e:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80416053a2:	5d                   	pop    %rbp
  80416053a3:	c3                   	retq   

00000080416053a4 <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  80416053a4:	55                   	push   %rbp
    movq %rsp, %rbp
  80416053a5:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  80416053a8:	53                   	push   %rbx
	push	%r12
  80416053a9:	41 54                	push   %r12
	push	%r13
  80416053ab:	41 55                	push   %r13
	push	%r14
  80416053ad:	41 56                	push   %r14
	push	%r15
  80416053af:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  80416053b1:	56                   	push   %rsi
	push	%rcx
  80416053b2:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  80416053b3:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  80416053b4:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  80416053b7:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

00000080416053be <copyloop>:
  80416053be:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  80416053c2:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  80416053c6:	49 83 c0 08          	add    $0x8,%r8
  80416053ca:	49 39 c8             	cmp    %rcx,%r8
  80416053cd:	75 ef                	jne    80416053be <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  80416053cf:	e8 00 00 00 00       	callq  80416053d4 <copyloop+0x16>
  80416053d4:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  80416053db:	00 
  80416053dc:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  80416053e3:	00 
  80416053e4:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  80416053e5:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  80416053e7:	6a 08                	pushq  $0x8
  80416053e9:	e8 00 00 00 00       	callq  80416053ee <copyloop+0x30>
  80416053ee:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  80416053f5:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  80416053f6:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  80416053fa:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  80416053fe:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  8041605402:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  8041605405:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  8041605406:	59                   	pop    %rcx
	pop	%rsi
  8041605407:	5e                   	pop    %rsi
	pop	%r15
  8041605408:	41 5f                	pop    %r15
	pop	%r14
  804160540a:	41 5e                	pop    %r14
	pop	%r13
  804160540c:	41 5d                	pop    %r13
	pop	%r12
  804160540e:	41 5c                	pop    %r12
	pop	%rbx
  8041605410:	5b                   	pop    %rbx

	leave
  8041605411:	c9                   	leaveq 
	ret
  8041605412:	c3                   	retq   
  8041605413:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
