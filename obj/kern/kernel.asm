
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
  8041600001:	48 89 0d f8 df 01 00 	mov    %rcx,0x1dff8(%rip)        # 804161e000 <bootstacktop>

  # Set the stack pointer.
  leaq bootstacktop(%rip),%rsp
  8041600008:	48 8d 25 f1 df 01 00 	lea    0x1dff1(%rip),%rsp        # 804161e000 <bootstacktop>

  # Clear the frame pointer register (RBP)
  # so that once we get into debugging C code,
  # stack backtraces will be terminated properly.
  xorq %rbp, %rbp      # nuke frame pointer
  804160000f:	48 31 ed             	xor    %rbp,%rbp

  # now to C code
  call i386_init
  8041600012:	e8 19 04 00 00       	callq  8041600430 <i386_init>

0000008041600017 <spin>:

  # Should never get here, but in case we do, just spin.
spin:  jmp  spin
  8041600017:	eb fe                	jmp    8041600017 <spin>

0000008041600019 <timers_init>:
#include <kern/picirq.h>
#include <kern/kclock.h>
#include <kern/kdebug.h>

void
timers_init(void) {
  8041600019:	55                   	push   %rbp
  804160001a:	48 89 e5             	mov    %rsp,%rbp
  804160001d:	41 54                	push   %r12
  804160001f:	53                   	push   %rbx
  timertab[0] = timer_rtc;
  8041600020:	48 bb a0 1c 62 41 80 	movabs $0x8041621ca0,%rbx
  8041600027:	00 00 00 
  804160002a:	48 b8 c0 e7 61 41 80 	movabs $0x804161e7c0,%rax
  8041600031:	00 00 00 
  8041600034:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  8041600038:	0f 11 03             	movups %xmm0,(%rbx)
  804160003b:	f3 0f 6f 48 10       	movdqu 0x10(%rax),%xmm1
  8041600040:	0f 11 4b 10          	movups %xmm1,0x10(%rbx)
  8041600044:	48 8b 40 20          	mov    0x20(%rax),%rax
  8041600048:	48 89 43 20          	mov    %rax,0x20(%rbx)
  timertab[1] = timer_pit;
  804160004c:	48 b8 e0 e8 61 41 80 	movabs $0x804161e8e0,%rax
  8041600053:	00 00 00 
  8041600056:	f3 0f 6f 10          	movdqu (%rax),%xmm2
  804160005a:	0f 11 53 28          	movups %xmm2,0x28(%rbx)
  804160005e:	f3 0f 6f 58 10       	movdqu 0x10(%rax),%xmm3
  8041600063:	0f 11 5b 38          	movups %xmm3,0x38(%rbx)
  8041600067:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160006b:	48 89 43 48          	mov    %rax,0x48(%rbx)
  timertab[2] = timer_acpipm;
  804160006f:	48 b8 00 e8 61 41 80 	movabs $0x804161e800,%rax
  8041600076:	00 00 00 
  8041600079:	f3 0f 6f 20          	movdqu (%rax),%xmm4
  804160007d:	0f 11 63 50          	movups %xmm4,0x50(%rbx)
  8041600081:	f3 0f 6f 68 10       	movdqu 0x10(%rax),%xmm5
  8041600086:	0f 11 6b 60          	movups %xmm5,0x60(%rbx)
  804160008a:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160008e:	48 89 43 70          	mov    %rax,0x70(%rbx)
  timertab[3] = timer_hpet0;
  8041600092:	48 b8 80 e8 61 41 80 	movabs $0x804161e880,%rax
  8041600099:	00 00 00 
  804160009c:	f3 0f 6f 30          	movdqu (%rax),%xmm6
  80416000a0:	0f 11 73 78          	movups %xmm6,0x78(%rbx)
  80416000a4:	f3 0f 6f 78 10       	movdqu 0x10(%rax),%xmm7
  80416000a9:	0f 11 bb 88 00 00 00 	movups %xmm7,0x88(%rbx)
  80416000b0:	48 8b 40 20          	mov    0x20(%rax),%rax
  80416000b4:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
  timertab[4] = timer_hpet1;
  80416000bb:	48 b8 40 e8 61 41 80 	movabs $0x804161e840,%rax
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
  804160010b:	48 b8 08 e0 61 41 80 	movabs $0x804161e008,%rax
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
  8041600134:	48 a3 08 e0 61 41 80 	movabs %rax,0x804161e008
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
  8041600222:	49 bc 00 e0 61 41 80 	movabs $0x804161e000,%r12
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
#endif

#if LAB <= 6
  map_addr_early_boot(FBUFFBASE, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
#endif
}
  8041600255:	5b                   	pop    %rbx
  8041600256:	41 5c                	pop    %r12
  8041600258:	5d                   	pop    %rbp
  8041600259:	c3                   	retq   

000000804160025a <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  804160025a:	55                   	push   %rbp
  804160025b:	48 89 e5             	mov    %rsp,%rbp
  804160025e:	41 54                	push   %r12
  8041600260:	53                   	push   %rbx
  8041600261:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600268:	49 89 d4             	mov    %rdx,%r12
  804160026b:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8041600272:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8041600279:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  8041600280:	84 c0                	test   %al,%al
  8041600282:	74 23                	je     80416002a7 <_panic+0x4d>
  8041600284:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  804160028b:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  804160028f:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  8041600293:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  8041600297:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  804160029b:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  804160029f:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416002a3:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  if (panicstr)
  80416002a7:	48 b8 20 e9 61 41 80 	movabs $0x804161e920,%rax
  80416002ae:	00 00 00 
  80416002b1:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416002b5:	74 13                	je     80416002ca <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416002b7:	48 bb 20 3f 60 41 80 	movabs $0x8041603f20,%rbx
  80416002be:	00 00 00 
  80416002c1:	bf 00 00 00 00       	mov    $0x0,%edi
  80416002c6:	ff d3                	callq  *%rbx
  while (1)
  80416002c8:	eb f7                	jmp    80416002c1 <_panic+0x67>
  panicstr = fmt;
  80416002ca:	4c 89 e0             	mov    %r12,%rax
  80416002cd:	48 a3 20 e9 61 41 80 	movabs %rax,0x804161e920
  80416002d4:	00 00 00 
  __asm __volatile("cli; cld");
  80416002d7:	fa                   	cli    
  80416002d8:	fc                   	cld    
  va_start(ap, fmt);
  80416002d9:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416002e0:	00 00 00 
  80416002e3:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416002ea:	00 00 00 
  80416002ed:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416002f1:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416002f8:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416002ff:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel panic at %s:%d: ", file, line);
  8041600306:	89 f2                	mov    %esi,%edx
  8041600308:	48 89 fe             	mov    %rdi,%rsi
  804160030b:	48 bf 40 b6 60 41 80 	movabs $0x804160b640,%rdi
  8041600312:	00 00 00 
  8041600315:	b8 00 00 00 00       	mov    $0x0,%eax
  804160031a:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  8041600321:	00 00 00 
  8041600324:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600326:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160032d:	4c 89 e7             	mov    %r12,%rdi
  8041600330:	48 b8 68 8a 60 41 80 	movabs $0x8041608a68,%rax
  8041600337:	00 00 00 
  804160033a:	ff d0                	callq  *%rax
  cprintf("\n");
  804160033c:	48 bf b7 cc 60 41 80 	movabs $0x804160ccb7,%rdi
  8041600343:	00 00 00 
  8041600346:	b8 00 00 00 00       	mov    $0x0,%eax
  804160034b:	ff d3                	callq  *%rbx
  va_end(ap);
  804160034d:	e9 65 ff ff ff       	jmpq   80416002b7 <_panic+0x5d>

0000008041600352 <timers_schedule>:
timers_schedule(const char *name) {
  8041600352:	55                   	push   %rbp
  8041600353:	48 89 e5             	mov    %rsp,%rbp
  8041600356:	41 56                	push   %r14
  8041600358:	41 55                	push   %r13
  804160035a:	41 54                	push   %r12
  804160035c:	53                   	push   %rbx
  804160035d:	49 89 fd             	mov    %rdi,%r13
  for (int i = 0; i < MAX_TIMERS; i++) {
  8041600360:	49 bc a0 1c 62 41 80 	movabs $0x8041621ca0,%r12
  8041600367:	00 00 00 
  804160036a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
  804160036f:	49 be 9e ad 60 41 80 	movabs $0x804160ad9e,%r14
  8041600376:	00 00 00 
  8041600379:	eb 3a                	jmp    80416003b5 <timers_schedule+0x63>
        panic("Timer %s does not support interrupts\n", name);
  804160037b:	4c 89 e9             	mov    %r13,%rcx
  804160037e:	48 ba e0 b6 60 41 80 	movabs $0x804160b6e0,%rdx
  8041600385:	00 00 00 
  8041600388:	be 2d 00 00 00       	mov    $0x2d,%esi
  804160038d:	48 bf 58 b6 60 41 80 	movabs $0x804160b658,%rdi
  8041600394:	00 00 00 
  8041600397:	b8 00 00 00 00       	mov    $0x0,%eax
  804160039c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416003a3:	00 00 00 
  80416003a6:	41 ff d0             	callq  *%r8
  for (int i = 0; i < MAX_TIMERS; i++) {
  80416003a9:	83 c3 01             	add    $0x1,%ebx
  80416003ac:	49 83 c4 28          	add    $0x28,%r12
  80416003b0:	83 fb 05             	cmp    $0x5,%ebx
  80416003b3:	74 4d                	je     8041600402 <timers_schedule+0xb0>
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
  80416003b5:	49 8b 3c 24          	mov    (%r12),%rdi
  80416003b9:	48 85 ff             	test   %rdi,%rdi
  80416003bc:	74 eb                	je     80416003a9 <timers_schedule+0x57>
  80416003be:	4c 89 ee             	mov    %r13,%rsi
  80416003c1:	41 ff d6             	callq  *%r14
  80416003c4:	85 c0                	test   %eax,%eax
  80416003c6:	75 e1                	jne    80416003a9 <timers_schedule+0x57>
      if (timertab[i].enable_interrupts != NULL) {
  80416003c8:	48 63 c3             	movslq %ebx,%rax
  80416003cb:	48 8d 14 80          	lea    (%rax,%rax,4),%rdx
  80416003cf:	48 b8 a0 1c 62 41 80 	movabs $0x8041621ca0,%rax
  80416003d6:	00 00 00 
  80416003d9:	48 8b 74 d0 18       	mov    0x18(%rax,%rdx,8),%rsi
  80416003de:	48 85 f6             	test   %rsi,%rsi
  80416003e1:	74 98                	je     804160037b <timers_schedule+0x29>
        timer_for_schedule = &timertab[i];
  80416003e3:	48 89 d1             	mov    %rdx,%rcx
  80416003e6:	48 8d 14 c8          	lea    (%rax,%rcx,8),%rdx
  80416003ea:	48 89 d0             	mov    %rdx,%rax
  80416003ed:	48 a3 80 1c 62 41 80 	movabs %rax,0x8041621c80
  80416003f4:	00 00 00 
        timertab[i].enable_interrupts();
  80416003f7:	ff d6                	callq  *%rsi
}
  80416003f9:	5b                   	pop    %rbx
  80416003fa:	41 5c                	pop    %r12
  80416003fc:	41 5d                	pop    %r13
  80416003fe:	41 5e                	pop    %r14
  8041600400:	5d                   	pop    %rbp
  8041600401:	c3                   	retq   
  panic("Timer %s does not exist\n", name);
  8041600402:	4c 89 e9             	mov    %r13,%rcx
  8041600405:	48 ba 64 b6 60 41 80 	movabs $0x804160b664,%rdx
  804160040c:	00 00 00 
  804160040f:	be 33 00 00 00       	mov    $0x33,%esi
  8041600414:	48 bf 58 b6 60 41 80 	movabs $0x804160b658,%rdi
  804160041b:	00 00 00 
  804160041e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600423:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160042a:	00 00 00 
  804160042d:	41 ff d0             	callq  *%r8

0000008041600430 <i386_init>:
i386_init(void) {
  8041600430:	55                   	push   %rbp
  8041600431:	48 89 e5             	mov    %rsp,%rbp
  8041600434:	41 54                	push   %r12
  8041600436:	53                   	push   %rbx
  early_boot_pml4_init();
  8041600437:	48 b8 1b 02 60 41 80 	movabs $0x804160021b,%rax
  804160043e:	00 00 00 
  8041600441:	ff d0                	callq  *%rax
  cons_init();
  8041600443:	48 b8 5f 0c 60 41 80 	movabs $0x8041600c5f,%rax
  804160044a:	00 00 00 
  804160044d:	ff d0                	callq  *%rax
  tsc_calibrate();
  804160044f:	48 b8 10 b1 60 41 80 	movabs $0x804160b110,%rax
  8041600456:	00 00 00 
  8041600459:	ff d0                	callq  *%rax
  cprintf("6828 decimal is %o octal!\n", 6828);
  804160045b:	be ac 1a 00 00       	mov    $0x1aac,%esi
  8041600460:	48 bf 7d b6 60 41 80 	movabs $0x804160b67d,%rdi
  8041600467:	00 00 00 
  804160046a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160046f:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  8041600476:	00 00 00 
  8041600479:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  804160047b:	48 be 00 20 62 41 80 	movabs $0x8041622000,%rsi
  8041600482:	00 00 00 
  8041600485:	48 bf 98 b6 60 41 80 	movabs $0x804160b698,%rdi
  804160048c:	00 00 00 
  804160048f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600494:	ff d3                	callq  *%rbx
  mem_init();
  8041600496:	48 b8 33 52 60 41 80 	movabs $0x8041605233,%rax
  804160049d:	00 00 00 
  80416004a0:	ff d0                	callq  *%rax
  while (ctor < &__ctors_end) {
  80416004a2:	48 ba 08 e9 61 41 80 	movabs $0x804161e908,%rdx
  80416004a9:	00 00 00 
  80416004ac:	48 b8 08 e9 61 41 80 	movabs $0x804161e908,%rax
  80416004b3:	00 00 00 
  80416004b6:	48 39 c2             	cmp    %rax,%rdx
  80416004b9:	73 23                	jae    80416004de <i386_init+0xae>
  80416004bb:	48 89 d3             	mov    %rdx,%rbx
  80416004be:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80416004c2:	48 29 d0             	sub    %rdx,%rax
  80416004c5:	48 c1 e8 03          	shr    $0x3,%rax
  80416004c9:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80416004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  80416004d3:	ff 13                	callq  *(%rbx)
    ctor++;
  80416004d5:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  80416004d9:	4c 39 e3             	cmp    %r12,%rbx
  80416004dc:	75 f0                	jne    80416004ce <i386_init+0x9e>
  pic_init();
  80416004de:	48 b8 7e 89 60 41 80 	movabs $0x804160897e,%rax
  80416004e5:	00 00 00 
  80416004e8:	ff d0                	callq  *%rax
  rtc_init();
  80416004ea:	48 b8 f8 87 60 41 80 	movabs $0x80416087f8,%rax
  80416004f1:	00 00 00 
  80416004f4:	ff d0                	callq  *%rax
  timers_init();
  80416004f6:	48 b8 19 00 60 41 80 	movabs $0x8041600019,%rax
  80416004fd:	00 00 00 
  8041600500:	ff d0                	callq  *%rax
  fb_init();
  8041600502:	48 b8 52 0b 60 41 80 	movabs $0x8041600b52,%rax
  8041600509:	00 00 00 
  804160050c:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  804160050e:	48 bf a1 b6 60 41 80 	movabs $0x804160b6a1,%rdi
  8041600515:	00 00 00 
  8041600518:	b8 00 00 00 00       	mov    $0x0,%eax
  804160051d:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041600524:	00 00 00 
  8041600527:	ff d2                	callq  *%rdx
  env_init();
  8041600529:	48 b8 e9 83 60 41 80 	movabs $0x80416083e9,%rax
  8041600530:	00 00 00 
  8041600533:	ff d0                	callq  *%rax
  timers_schedule("hpet0");
  8041600535:	48 bf ba b6 60 41 80 	movabs $0x804160b6ba,%rdi
  804160053c:	00 00 00 
  804160053f:	48 b8 52 03 60 41 80 	movabs $0x8041600352,%rax
  8041600546:	00 00 00 
  8041600549:	ff d0                	callq  *%rax
  clock_idt_init();
  804160054b:	48 b8 30 8b 60 41 80 	movabs $0x8041608b30,%rax
  8041600552:	00 00 00 
  8041600555:	ff d0                	callq  *%rax
  sched_yield();
  8041600557:	48 b8 9c 9e 60 41 80 	movabs $0x8041609e9c,%rax
  804160055e:	00 00 00 
  8041600561:	ff d0                	callq  *%rax

0000008041600563 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  8041600563:	55                   	push   %rbp
  8041600564:	48 89 e5             	mov    %rsp,%rbp
  8041600567:	41 54                	push   %r12
  8041600569:	53                   	push   %rbx
  804160056a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600571:	49 89 d4             	mov    %rdx,%r12
  8041600574:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  804160057b:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8041600582:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  8041600589:	84 c0                	test   %al,%al
  804160058b:	74 23                	je     80416005b0 <_warn+0x4d>
  804160058d:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  8041600594:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  8041600598:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  804160059c:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416005a0:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416005a4:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416005a8:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416005ac:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416005b0:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416005b7:	00 00 00 
  80416005ba:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416005c1:	00 00 00 
  80416005c4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416005c8:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416005cf:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416005d6:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  80416005dd:	89 f2                	mov    %esi,%edx
  80416005df:	48 89 fe             	mov    %rdi,%rsi
  80416005e2:	48 bf c0 b6 60 41 80 	movabs $0x804160b6c0,%rdi
  80416005e9:	00 00 00 
  80416005ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416005f1:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  80416005f8:	00 00 00 
  80416005fb:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  80416005fd:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600604:	4c 89 e7             	mov    %r12,%rdi
  8041600607:	48 b8 68 8a 60 41 80 	movabs $0x8041608a68,%rax
  804160060e:	00 00 00 
  8041600611:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600613:	48 bf b7 cc 60 41 80 	movabs $0x804160ccb7,%rdi
  804160061a:	00 00 00 
  804160061d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600622:	ff d3                	callq  *%rbx
  va_end(ap);
}
  8041600624:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  804160062b:	5b                   	pop    %rbx
  804160062c:	41 5c                	pop    %r12
  804160062e:	5d                   	pop    %rbp
  804160062f:	c3                   	retq   

0000008041600630 <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  8041600630:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600635:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  8041600636:	a8 01                	test   $0x1,%al
  8041600638:	74 0a                	je     8041600644 <serial_proc_data+0x14>
  804160063a:	ba f8 03 00 00       	mov    $0x3f8,%edx
  804160063f:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  8041600640:	0f b6 c0             	movzbl %al,%eax
  8041600643:	c3                   	retq   
    return -1;
  8041600644:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  8041600649:	c3                   	retq   

000000804160064a <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  804160064a:	55                   	push   %rbp
  804160064b:	48 89 e5             	mov    %rsp,%rbp
  804160064e:	41 54                	push   %r12
  8041600650:	53                   	push   %rbx
  8041600651:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  8041600654:	48 bb 60 e9 61 41 80 	movabs $0x804161e960,%rbx
  804160065b:	00 00 00 
  while ((c = (*proc)()) != -1) {
  804160065e:	41 ff d4             	callq  *%r12
  8041600661:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041600664:	74 28                	je     804160068e <cons_intr+0x44>
    if (c == 0)
  8041600666:	85 c0                	test   %eax,%eax
  8041600668:	74 f4                	je     804160065e <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  804160066a:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  8041600670:	8d 51 01             	lea    0x1(%rcx),%edx
  8041600673:	89 c9                	mov    %ecx,%ecx
  8041600675:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  8041600678:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  804160067e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600683:	0f 44 d0             	cmove  %eax,%edx
  8041600686:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  804160068c:	eb d0                	jmp    804160065e <cons_intr+0x14>
  }
}
  804160068e:	5b                   	pop    %rbx
  804160068f:	41 5c                	pop    %r12
  8041600691:	5d                   	pop    %rbp
  8041600692:	c3                   	retq   

0000008041600693 <kbd_proc_data>:
kbd_proc_data(void) {
  8041600693:	55                   	push   %rbp
  8041600694:	48 89 e5             	mov    %rsp,%rbp
  8041600697:	53                   	push   %rbx
  8041600698:	48 83 ec 08          	sub    $0x8,%rsp
  804160069c:	ba 64 00 00 00       	mov    $0x64,%edx
  80416006a1:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416006a2:	a8 01                	test   $0x1,%al
  80416006a4:	0f 84 31 01 00 00    	je     80416007db <kbd_proc_data+0x148>
  80416006aa:	ba 60 00 00 00       	mov    $0x60,%edx
  80416006af:	ec                   	in     (%dx),%al
  80416006b0:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416006b2:	3c e0                	cmp    $0xe0,%al
  80416006b4:	0f 84 84 00 00 00    	je     804160073e <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  80416006ba:	84 c0                	test   %al,%al
  80416006bc:	0f 88 97 00 00 00    	js     8041600759 <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  80416006c2:	48 bf 40 e9 61 41 80 	movabs $0x804161e940,%rdi
  80416006c9:	00 00 00 
  80416006cc:	8b 0f                	mov    (%rdi),%ecx
  80416006ce:	f6 c1 40             	test   $0x40,%cl
  80416006d1:	74 0c                	je     80416006df <kbd_proc_data+0x4c>
    data |= 0x80;
  80416006d3:	83 c8 80             	or     $0xffffff80,%eax
  80416006d6:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416006d8:	89 c8                	mov    %ecx,%eax
  80416006da:	83 e0 bf             	and    $0xffffffbf,%eax
  80416006dd:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  80416006df:	0f b6 f2             	movzbl %dl,%esi
  80416006e2:	48 b8 60 b8 60 41 80 	movabs $0x804160b860,%rax
  80416006e9:	00 00 00 
  80416006ec:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  80416006f0:	48 b9 40 e9 61 41 80 	movabs $0x804161e940,%rcx
  80416006f7:	00 00 00 
  80416006fa:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  80416006fc:	48 bf 60 b7 60 41 80 	movabs $0x804160b760,%rdi
  8041600703:	00 00 00 
  8041600706:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  804160070a:	31 f0                	xor    %esi,%eax
  804160070c:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  804160070e:	89 c6                	mov    %eax,%esi
  8041600710:	83 e6 03             	and    $0x3,%esi
  8041600713:	0f b6 d2             	movzbl %dl,%edx
  8041600716:	48 b9 40 b7 60 41 80 	movabs $0x804160b740,%rcx
  804160071d:	00 00 00 
  8041600720:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  8041600724:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  8041600728:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  804160072b:	a8 08                	test   $0x8,%al
  804160072d:	74 73                	je     80416007a2 <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  804160072f:	89 da                	mov    %ebx,%edx
  8041600731:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  8041600734:	83 f9 19             	cmp    $0x19,%ecx
  8041600737:	77 5d                	ja     8041600796 <kbd_proc_data+0x103>
      c += 'A' - 'a';
  8041600739:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  804160073c:	eb 12                	jmp    8041600750 <kbd_proc_data+0xbd>
    shift |= E0ESC;
  804160073e:	48 b8 40 e9 61 41 80 	movabs $0x804161e940,%rax
  8041600745:	00 00 00 
  8041600748:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  804160074b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8041600750:	89 d8                	mov    %ebx,%eax
  8041600752:	48 83 c4 08          	add    $0x8,%rsp
  8041600756:	5b                   	pop    %rbx
  8041600757:	5d                   	pop    %rbp
  8041600758:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600759:	48 bf 40 e9 61 41 80 	movabs $0x804161e940,%rdi
  8041600760:	00 00 00 
  8041600763:	8b 0f                	mov    (%rdi),%ecx
  8041600765:	89 ce                	mov    %ecx,%esi
  8041600767:	83 e6 40             	and    $0x40,%esi
  804160076a:	83 e0 7f             	and    $0x7f,%eax
  804160076d:	85 f6                	test   %esi,%esi
  804160076f:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  8041600772:	0f b6 d2             	movzbl %dl,%edx
  8041600775:	48 b8 60 b8 60 41 80 	movabs $0x804160b860,%rax
  804160077c:	00 00 00 
  804160077f:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  8041600783:	83 c8 40             	or     $0x40,%eax
  8041600786:	0f b6 c0             	movzbl %al,%eax
  8041600789:	f7 d0                	not    %eax
  804160078b:	21 c8                	and    %ecx,%eax
  804160078d:	89 07                	mov    %eax,(%rdi)
    return 0;
  804160078f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041600794:	eb ba                	jmp    8041600750 <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  8041600796:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  8041600799:	8d 4b 20             	lea    0x20(%rbx),%ecx
  804160079c:	83 fa 1a             	cmp    $0x1a,%edx
  804160079f:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416007a2:	f7 d0                	not    %eax
  80416007a4:	a8 06                	test   $0x6,%al
  80416007a6:	75 a8                	jne    8041600750 <kbd_proc_data+0xbd>
  80416007a8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  80416007ae:	75 a0                	jne    8041600750 <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  80416007b0:	48 bf 06 b7 60 41 80 	movabs $0x804160b706,%rdi
  80416007b7:	00 00 00 
  80416007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  80416007bf:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416007c6:	00 00 00 
  80416007c9:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416007cb:	b8 03 00 00 00       	mov    $0x3,%eax
  80416007d0:	ba 92 00 00 00       	mov    $0x92,%edx
  80416007d5:	ee                   	out    %al,(%dx)
  80416007d6:	e9 75 ff ff ff       	jmpq   8041600750 <kbd_proc_data+0xbd>
    return -1;
  80416007db:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80416007e0:	e9 6b ff ff ff       	jmpq   8041600750 <kbd_proc_data+0xbd>

00000080416007e5 <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  80416007e5:	48 b8 74 eb 61 41 80 	movabs $0x804161eb74,%rax
  80416007ec:	00 00 00 
  80416007ef:	44 8b 10             	mov    (%rax),%r10d
  80416007f2:	41 0f af d2          	imul   %r10d,%edx
  80416007f6:	01 f2                	add    %esi,%edx
  80416007f8:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  80416007ff:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  8041600800:	4d 0f be c0          	movsbq %r8b,%r8
  8041600804:	48 b8 20 e3 61 41 80 	movabs $0x804161e320,%rax
  804160080b:	00 00 00 
  804160080e:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  8041600812:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  8041600816:	eb 25                	jmp    804160083d <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  8041600818:	83 c0 01             	add    $0x1,%eax
  804160081b:	83 f8 08             	cmp    $0x8,%eax
  804160081e:	74 11                	je     8041600831 <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  8041600820:	0f be 16             	movsbl (%rsi),%edx
  8041600823:	0f a3 c2             	bt     %eax,%edx
  8041600826:	73 f0                	jae    8041600818 <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  8041600828:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  804160082c:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  804160082f:	eb e7                	jmp    8041600818 <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  8041600831:	45 01 d1             	add    %r10d,%r9d
  8041600834:	48 83 c6 01          	add    $0x1,%rsi
  8041600838:	4c 39 c6             	cmp    %r8,%rsi
  804160083b:	74 07                	je     8041600844 <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  804160083d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600842:	eb dc                	jmp    8041600820 <draw_char+0x3b>
}
  8041600844:	c3                   	retq   

0000008041600845 <cons_putc>:
  __asm __volatile("inb %w1,%0"
  8041600845:	ba fd 03 00 00       	mov    $0x3fd,%edx
  804160084a:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  804160084b:	a8 20                	test   $0x20,%al
  804160084d:	75 29                	jne    8041600878 <cons_putc+0x33>
  for (i = 0;
  804160084f:	be 00 00 00 00       	mov    $0x0,%esi
  8041600854:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600859:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  804160085f:	89 ca                	mov    %ecx,%edx
  8041600861:	ec                   	in     (%dx),%al
  8041600862:	ec                   	in     (%dx),%al
  8041600863:	ec                   	in     (%dx),%al
  8041600864:	ec                   	in     (%dx),%al
       i++)
  8041600865:	83 c6 01             	add    $0x1,%esi
  8041600868:	44 89 c2             	mov    %r8d,%edx
  804160086b:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  804160086c:	a8 20                	test   $0x20,%al
  804160086e:	75 08                	jne    8041600878 <cons_putc+0x33>
  8041600870:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  8041600876:	7e e7                	jle    804160085f <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  8041600878:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  804160087b:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600880:	89 f8                	mov    %edi,%eax
  8041600882:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600883:	ba 79 03 00 00       	mov    $0x379,%edx
  8041600888:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  8041600889:	84 c0                	test   %al,%al
  804160088b:	78 29                	js     80416008b6 <cons_putc+0x71>
  804160088d:	be 00 00 00 00       	mov    $0x0,%esi
  8041600892:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600897:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  804160089d:	89 ca                	mov    %ecx,%edx
  804160089f:	ec                   	in     (%dx),%al
  80416008a0:	ec                   	in     (%dx),%al
  80416008a1:	ec                   	in     (%dx),%al
  80416008a2:	ec                   	in     (%dx),%al
  80416008a3:	83 c6 01             	add    $0x1,%esi
  80416008a6:	44 89 ca             	mov    %r9d,%edx
  80416008a9:	ec                   	in     (%dx),%al
  80416008aa:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416008b0:	7f 04                	jg     80416008b6 <cons_putc+0x71>
  80416008b2:	84 c0                	test   %al,%al
  80416008b4:	79 e7                	jns    804160089d <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416008b6:	ba 78 03 00 00       	mov    $0x378,%edx
  80416008bb:	44 89 c0             	mov    %r8d,%eax
  80416008be:	ee                   	out    %al,(%dx)
  80416008bf:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416008c4:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416008c9:	ee                   	out    %al,(%dx)
  80416008ca:	b8 08 00 00 00       	mov    $0x8,%eax
  80416008cf:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416008d0:	48 b8 7c eb 61 41 80 	movabs $0x804161eb7c,%rax
  80416008d7:	00 00 00 
  80416008da:	80 38 00             	cmpb   $0x0,(%rax)
  80416008dd:	0f 84 42 02 00 00    	je     8041600b25 <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  80416008e3:	55                   	push   %rbp
  80416008e4:	48 89 e5             	mov    %rsp,%rbp
  80416008e7:	41 54                	push   %r12
  80416008e9:	53                   	push   %rbx
  if (!(c & ~0xFF))
  80416008ea:	89 fa                	mov    %edi,%edx
  80416008ec:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  80416008f2:	89 f8                	mov    %edi,%eax
  80416008f4:	80 cc 07             	or     $0x7,%ah
  80416008f7:	85 d2                	test   %edx,%edx
  80416008f9:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  80416008fc:	40 0f b6 c7          	movzbl %dil,%eax
  8041600900:	83 f8 09             	cmp    $0x9,%eax
  8041600903:	0f 84 e1 00 00 00    	je     80416009ea <cons_putc+0x1a5>
  8041600909:	7e 5c                	jle    8041600967 <cons_putc+0x122>
  804160090b:	83 f8 0a             	cmp    $0xa,%eax
  804160090e:	0f 84 b8 00 00 00    	je     80416009cc <cons_putc+0x187>
  8041600914:	83 f8 0d             	cmp    $0xd,%eax
  8041600917:	0f 85 ff 00 00 00    	jne    8041600a1c <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  804160091d:	48 be 68 eb 61 41 80 	movabs $0x804161eb68,%rsi
  8041600924:	00 00 00 
  8041600927:	0f b7 0e             	movzwl (%rsi),%ecx
  804160092a:	0f b7 c1             	movzwl %cx,%eax
  804160092d:	48 bb 70 eb 61 41 80 	movabs $0x804161eb70,%rbx
  8041600934:	00 00 00 
  8041600937:	ba 00 00 00 00       	mov    $0x0,%edx
  804160093c:	f7 33                	divl   (%rbx)
  804160093e:	29 d1                	sub    %edx,%ecx
  8041600940:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  8041600943:	48 b8 68 eb 61 41 80 	movabs $0x804161eb68,%rax
  804160094a:	00 00 00 
  804160094d:	0f b7 10             	movzwl (%rax),%edx
  8041600950:	48 b8 6c eb 61 41 80 	movabs $0x804161eb6c,%rax
  8041600957:	00 00 00 
  804160095a:	3b 10                	cmp    (%rax),%edx
  804160095c:	0f 83 0f 01 00 00    	jae    8041600a71 <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  8041600962:	5b                   	pop    %rbx
  8041600963:	41 5c                	pop    %r12
  8041600965:	5d                   	pop    %rbp
  8041600966:	c3                   	retq   
  switch (c & 0xff) {
  8041600967:	83 f8 08             	cmp    $0x8,%eax
  804160096a:	0f 85 ac 00 00 00    	jne    8041600a1c <cons_putc+0x1d7>
      if (crt_pos > 0) {
  8041600970:	66 a1 68 eb 61 41 80 	movabs 0x804161eb68,%ax
  8041600977:	00 00 00 
  804160097a:	66 85 c0             	test   %ax,%ax
  804160097d:	74 c4                	je     8041600943 <cons_putc+0xfe>
        crt_pos--;
  804160097f:	83 e8 01             	sub    $0x1,%eax
  8041600982:	66 a3 68 eb 61 41 80 	movabs %ax,0x804161eb68
  8041600989:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  804160098c:	0f b7 c0             	movzwl %ax,%eax
  804160098f:	48 bb 70 eb 61 41 80 	movabs $0x804161eb70,%rbx
  8041600996:	00 00 00 
  8041600999:	8b 1b                	mov    (%rbx),%ebx
  804160099b:	ba 00 00 00 00       	mov    $0x0,%edx
  80416009a0:	f7 f3                	div    %ebx
  80416009a2:	89 d6                	mov    %edx,%esi
  80416009a4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416009aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416009af:	89 c2                	mov    %eax,%edx
  80416009b1:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  80416009b8:	00 00 00 
  80416009bb:	48 b8 e5 07 60 41 80 	movabs $0x80416007e5,%rax
  80416009c2:	00 00 00 
  80416009c5:	ff d0                	callq  *%rax
  80416009c7:	e9 77 ff ff ff       	jmpq   8041600943 <cons_putc+0xfe>
      crt_pos += crt_cols;
  80416009cc:	48 b8 68 eb 61 41 80 	movabs $0x804161eb68,%rax
  80416009d3:	00 00 00 
  80416009d6:	48 bb 70 eb 61 41 80 	movabs $0x804161eb70,%rbx
  80416009dd:	00 00 00 
  80416009e0:	8b 13                	mov    (%rbx),%edx
  80416009e2:	66 01 10             	add    %dx,(%rax)
  80416009e5:	e9 33 ff ff ff       	jmpq   804160091d <cons_putc+0xd8>
      cons_putc(' ');
  80416009ea:	bf 20 00 00 00       	mov    $0x20,%edi
  80416009ef:	48 bb 45 08 60 41 80 	movabs $0x8041600845,%rbx
  80416009f6:	00 00 00 
  80416009f9:	ff d3                	callq  *%rbx
      cons_putc(' ');
  80416009fb:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a00:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a02:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a07:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a09:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a0e:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a10:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a15:	ff d3                	callq  *%rbx
      break;
  8041600a17:	e9 27 ff ff ff       	jmpq   8041600943 <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600a1c:	49 bc 68 eb 61 41 80 	movabs $0x804161eb68,%r12
  8041600a23:	00 00 00 
  8041600a26:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600a2b:	0f b7 c3             	movzwl %bx,%eax
  8041600a2e:	48 be 70 eb 61 41 80 	movabs $0x804161eb70,%rsi
  8041600a35:	00 00 00 
  8041600a38:	8b 36                	mov    (%rsi),%esi
  8041600a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600a3f:	f7 f6                	div    %esi
  8041600a41:	89 d6                	mov    %edx,%esi
  8041600a43:	44 0f be c7          	movsbl %dil,%r8d
  8041600a47:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600a4c:	89 c2                	mov    %eax,%edx
  8041600a4e:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600a55:	00 00 00 
  8041600a58:	48 b8 e5 07 60 41 80 	movabs $0x80416007e5,%rax
  8041600a5f:	00 00 00 
  8041600a62:	ff d0                	callq  *%rax
      crt_pos++;
  8041600a64:	83 c3 01             	add    $0x1,%ebx
  8041600a67:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  8041600a6c:	e9 d2 fe ff ff       	jmpq   8041600943 <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600a71:	48 bb 74 eb 61 41 80 	movabs $0x804161eb74,%rbx
  8041600a78:	00 00 00 
  8041600a7b:	8b 03                	mov    (%rbx),%eax
  8041600a7d:	49 bc 78 eb 61 41 80 	movabs $0x804161eb78,%r12
  8041600a84:	00 00 00 
  8041600a87:	41 8b 3c 24          	mov    (%r12),%edi
  8041600a8b:	8d 57 f8             	lea    -0x8(%rdi),%edx
  8041600a8e:	0f af d0             	imul   %eax,%edx
  8041600a91:	48 c1 e2 02          	shl    $0x2,%rdx
  8041600a95:	c1 e0 03             	shl    $0x3,%eax
  8041600a98:	89 c0                	mov    %eax,%eax
  8041600a9a:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600aa1:	00 00 00 
  8041600aa4:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  8041600aa8:	48 b8 9a ae 60 41 80 	movabs $0x804160ae9a,%rax
  8041600aaf:	00 00 00 
  8041600ab2:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600ab4:	41 8b 04 24          	mov    (%r12),%eax
  8041600ab8:	8b 0b                	mov    (%rbx),%ecx
  8041600aba:	89 c6                	mov    %eax,%esi
  8041600abc:	83 e6 f8             	and    $0xfffffff8,%esi
  8041600abf:	83 ee 08             	sub    $0x8,%esi
  8041600ac2:	0f af f1             	imul   %ecx,%esi
  8041600ac5:	0f af c8             	imul   %eax,%ecx
  8041600ac8:	39 f1                	cmp    %esi,%ecx
  8041600aca:	76 3b                	jbe    8041600b07 <cons_putc+0x2c2>
  8041600acc:	48 63 fe             	movslq %esi,%rdi
  8041600acf:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  8041600ad6:	00 00 00 
  8041600ad9:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  8041600add:	8d 51 ff             	lea    -0x1(%rcx),%edx
  8041600ae0:	89 d1                	mov    %edx,%ecx
  8041600ae2:	29 f1                	sub    %esi,%ecx
  8041600ae4:	48 ba 01 b8 b0 0f 20 	movabs $0x200fb0b801,%rdx
  8041600aeb:	00 00 00 
  8041600aee:	48 01 fa             	add    %rdi,%rdx
  8041600af1:	48 01 ca             	add    %rcx,%rdx
  8041600af4:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600af8:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600afe:	48 83 c0 04          	add    $0x4,%rax
  8041600b02:	48 39 c2             	cmp    %rax,%rdx
  8041600b05:	75 f1                	jne    8041600af8 <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600b07:	48 b8 68 eb 61 41 80 	movabs $0x804161eb68,%rax
  8041600b0e:	00 00 00 
  8041600b11:	48 bb 70 eb 61 41 80 	movabs $0x804161eb70,%rbx
  8041600b18:	00 00 00 
  8041600b1b:	8b 13                	mov    (%rbx),%edx
  8041600b1d:	66 29 10             	sub    %dx,(%rax)
}
  8041600b20:	e9 3d fe ff ff       	jmpq   8041600962 <cons_putc+0x11d>
  8041600b25:	c3                   	retq   

0000008041600b26 <serial_intr>:
  if (serial_exists)
  8041600b26:	48 b8 6a eb 61 41 80 	movabs $0x804161eb6a,%rax
  8041600b2d:	00 00 00 
  8041600b30:	80 38 00             	cmpb   $0x0,(%rax)
  8041600b33:	75 01                	jne    8041600b36 <serial_intr+0x10>
  8041600b35:	c3                   	retq   
serial_intr(void) {
  8041600b36:	55                   	push   %rbp
  8041600b37:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600b3a:	48 bf 30 06 60 41 80 	movabs $0x8041600630,%rdi
  8041600b41:	00 00 00 
  8041600b44:	48 b8 4a 06 60 41 80 	movabs $0x804160064a,%rax
  8041600b4b:	00 00 00 
  8041600b4e:	ff d0                	callq  *%rax
}
  8041600b50:	5d                   	pop    %rbp
  8041600b51:	c3                   	retq   

0000008041600b52 <fb_init>:
fb_init(void) {
  8041600b52:	55                   	push   %rbp
  8041600b53:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600b56:	48 b8 00 e0 61 41 80 	movabs $0x804161e000,%rax
  8041600b5d:	00 00 00 
  8041600b60:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600b63:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600b66:	89 d0                	mov    %edx,%eax
  8041600b68:	a3 78 eb 61 41 80 00 	movabs %eax,0x804161eb78
  8041600b6f:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600b71:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600b74:	a3 74 eb 61 41 80 00 	movabs %eax,0x804161eb74
  8041600b7b:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600b7d:	c1 e8 03             	shr    $0x3,%eax
  8041600b80:	89 c6                	mov    %eax,%esi
  8041600b82:	a3 70 eb 61 41 80 00 	movabs %eax,0x804161eb70
  8041600b89:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600b8b:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600b8e:	0f af d0             	imul   %eax,%edx
  8041600b91:	89 d0                	mov    %edx,%eax
  8041600b93:	a3 6c eb 61 41 80 00 	movabs %eax,0x804161eb6c
  8041600b9a:	00 00 
  crt_pos           = crt_cols;
  8041600b9c:	89 f0                	mov    %esi,%eax
  8041600b9e:	66 a3 68 eb 61 41 80 	movabs %ax,0x804161eb68
  8041600ba5:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600ba8:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600bab:	be 00 00 00 00       	mov    $0x0,%esi
  8041600bb0:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600bb7:	00 00 00 
  8041600bba:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041600bc1:	00 00 00 
  8041600bc4:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600bc6:	48 b8 7c eb 61 41 80 	movabs $0x804161eb7c,%rax
  8041600bcd:	00 00 00 
  8041600bd0:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600bd3:	5d                   	pop    %rbp
  8041600bd4:	c3                   	retq   

0000008041600bd5 <kbd_intr>:
kbd_intr(void) {
  8041600bd5:	55                   	push   %rbp
  8041600bd6:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600bd9:	48 bf 93 06 60 41 80 	movabs $0x8041600693,%rdi
  8041600be0:	00 00 00 
  8041600be3:	48 b8 4a 06 60 41 80 	movabs $0x804160064a,%rax
  8041600bea:	00 00 00 
  8041600bed:	ff d0                	callq  *%rax
}
  8041600bef:	5d                   	pop    %rbp
  8041600bf0:	c3                   	retq   

0000008041600bf1 <cons_getc>:
cons_getc(void) {
  8041600bf1:	55                   	push   %rbp
  8041600bf2:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600bf5:	48 b8 26 0b 60 41 80 	movabs $0x8041600b26,%rax
  8041600bfc:	00 00 00 
  8041600bff:	ff d0                	callq  *%rax
  kbd_intr();
  8041600c01:	48 b8 d5 0b 60 41 80 	movabs $0x8041600bd5,%rax
  8041600c08:	00 00 00 
  8041600c0b:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600c0d:	48 b9 60 e9 61 41 80 	movabs $0x804161e960,%rcx
  8041600c14:	00 00 00 
  8041600c17:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600c22:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600c28:	74 21                	je     8041600c4b <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600c2a:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600c2d:	48 b8 60 e9 61 41 80 	movabs $0x804161e960,%rax
  8041600c34:	00 00 00 
  8041600c37:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600c3d:	89 d2                	mov    %edx,%edx
  8041600c3f:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600c43:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600c49:	74 02                	je     8041600c4d <cons_getc+0x5c>
}
  8041600c4b:	5d                   	pop    %rbp
  8041600c4c:	c3                   	retq   
      cons.rpos = 0;
  8041600c4d:	48 be 60 eb 61 41 80 	movabs $0x804161eb60,%rsi
  8041600c54:	00 00 00 
  8041600c57:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600c5d:	eb ec                	jmp    8041600c4b <cons_getc+0x5a>

0000008041600c5f <cons_init>:
  8041600c5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600c64:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600c69:	89 c8                	mov    %ecx,%eax
  8041600c6b:	89 fa                	mov    %edi,%edx
  8041600c6d:	ee                   	out    %al,(%dx)
  8041600c6e:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600c74:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600c79:	44 89 ca             	mov    %r9d,%edx
  8041600c7c:	ee                   	out    %al,(%dx)
  8041600c7d:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600c82:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600c87:	89 f2                	mov    %esi,%edx
  8041600c89:	ee                   	out    %al,(%dx)
  8041600c8a:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600c90:	89 c8                	mov    %ecx,%eax
  8041600c92:	44 89 c2             	mov    %r8d,%edx
  8041600c95:	ee                   	out    %al,(%dx)
  8041600c96:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600c9b:	44 89 ca             	mov    %r9d,%edx
  8041600c9e:	ee                   	out    %al,(%dx)
  8041600c9f:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600ca4:	89 c8                	mov    %ecx,%eax
  8041600ca6:	ee                   	out    %al,(%dx)
  8041600ca7:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600cac:	44 89 c2             	mov    %r8d,%edx
  8041600caf:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600cb0:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600cb5:	ec                   	in     (%dx),%al
  8041600cb6:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600cb8:	3c ff                	cmp    $0xff,%al
  8041600cba:	0f 95 c0             	setne  %al
  8041600cbd:	a2 6a eb 61 41 80 00 	movabs %al,0x804161eb6a
  8041600cc4:	00 00 
  8041600cc6:	89 fa                	mov    %edi,%edx
  8041600cc8:	ec                   	in     (%dx),%al
  8041600cc9:	89 f2                	mov    %esi,%edx
  8041600ccb:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600ccc:	80 f9 ff             	cmp    $0xff,%cl
  8041600ccf:	74 01                	je     8041600cd2 <cons_init+0x73>
  8041600cd1:	c3                   	retq   
cons_init(void) {
  8041600cd2:	55                   	push   %rbp
  8041600cd3:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600cd6:	48 bf 12 b7 60 41 80 	movabs $0x804160b712,%rdi
  8041600cdd:	00 00 00 
  8041600ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600ce5:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041600cec:	00 00 00 
  8041600cef:	ff d2                	callq  *%rdx
}
  8041600cf1:	5d                   	pop    %rbp
  8041600cf2:	c3                   	retq   

0000008041600cf3 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600cf3:	55                   	push   %rbp
  8041600cf4:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600cf7:	48 b8 45 08 60 41 80 	movabs $0x8041600845,%rax
  8041600cfe:	00 00 00 
  8041600d01:	ff d0                	callq  *%rax
}
  8041600d03:	5d                   	pop    %rbp
  8041600d04:	c3                   	retq   

0000008041600d05 <getchar>:

int
getchar(void) {
  8041600d05:	55                   	push   %rbp
  8041600d06:	48 89 e5             	mov    %rsp,%rbp
  8041600d09:	53                   	push   %rbx
  8041600d0a:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600d0e:	48 bb f1 0b 60 41 80 	movabs $0x8041600bf1,%rbx
  8041600d15:	00 00 00 
  8041600d18:	ff d3                	callq  *%rbx
  8041600d1a:	85 c0                	test   %eax,%eax
  8041600d1c:	74 fa                	je     8041600d18 <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600d1e:	48 83 c4 08          	add    $0x8,%rsp
  8041600d22:	5b                   	pop    %rbx
  8041600d23:	5d                   	pop    %rbp
  8041600d24:	c3                   	retq   

0000008041600d25 <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600d25:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600d2a:	c3                   	retq   

0000008041600d2b <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600d2b:	55                   	push   %rbp
  8041600d2c:	48 89 e5             	mov    %rsp,%rbp
  8041600d2f:	41 56                	push   %r14
  8041600d31:	41 55                	push   %r13
  8041600d33:	41 54                	push   %r12
  8041600d35:	53                   	push   %rbx
  8041600d36:	48 83 ec 20          	sub    $0x20,%rsp
  8041600d3a:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600d3e:	83 fe 20             	cmp    $0x20,%esi
  8041600d41:	0f 87 42 09 00 00    	ja     8041601689 <dwarf_read_abbrev_entry+0x95e>
  8041600d47:	44 89 c3             	mov    %r8d,%ebx
  8041600d4a:	41 89 cd             	mov    %ecx,%r13d
  8041600d4d:	49 89 d4             	mov    %rdx,%r12
  8041600d50:	89 f6                	mov    %esi,%esi
  8041600d52:	48 b8 18 ba 60 41 80 	movabs $0x804160ba18,%rax
  8041600d59:	00 00 00 
  8041600d5c:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600d5f:	48 85 d2             	test   %rdx,%rdx
  8041600d62:	74 6f                	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  8041600d64:	83 f9 07             	cmp    $0x7,%ecx
  8041600d67:	76 6a                	jbe    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600d69:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600d6e:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d72:	4c 89 e7             	mov    %r12,%rdi
  8041600d75:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600d7c:	00 00 00 
  8041600d7f:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600d81:	eb 50                	jmp    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB2 code

      unsigned length = get_unaligned(entry, uint16_t);
  8041600d83:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d88:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d8c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d90:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600d97:	00 00 00 
  8041600d9a:	ff d0                	callq  *%rax
  8041600d9c:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(uint16_t);
  8041600da0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600da4:	48 83 c0 02          	add    $0x2,%rax
  8041600da8:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600dac:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600db0:	89 5d d8             	mov    %ebx,-0x28(%rbp)
          .mem = entry,
          .len = length,
      };
      if (buf) {
  8041600db3:	4d 85 e4             	test   %r12,%r12
  8041600db6:	74 18                	je     8041600dd0 <dwarf_read_abbrev_entry+0xa5>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600db8:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600dbd:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600dc1:	4c 89 e7             	mov    %r12,%rdi
  8041600dc4:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600dcb:	00 00 00 
  8041600dce:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(uint16_t) + length;
  8041600dd0:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600dd3:	89 d8                	mov    %ebx,%eax
  8041600dd5:	48 83 c4 20          	add    $0x20,%rsp
  8041600dd9:	5b                   	pop    %rbx
  8041600dda:	41 5c                	pop    %r12
  8041600ddc:	41 5d                	pop    %r13
  8041600dde:	41 5e                	pop    %r14
  8041600de0:	5d                   	pop    %rbp
  8041600de1:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600de2:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600de7:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600deb:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600def:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600df6:	00 00 00 
  8041600df9:	ff d0                	callq  *%rax
  8041600dfb:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600dfe:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600e02:	48 83 c0 04          	add    $0x4,%rax
  8041600e06:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600e0a:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600e0e:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600e11:	4d 85 e4             	test   %r12,%r12
  8041600e14:	74 18                	je     8041600e2e <dwarf_read_abbrev_entry+0x103>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600e16:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600e1b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e1f:	4c 89 e7             	mov    %r12,%rdi
  8041600e22:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600e29:	00 00 00 
  8041600e2c:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600e2e:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600e31:	eb a0                	jmp    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600e33:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e38:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e3c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e40:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600e47:	00 00 00 
  8041600e4a:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600e4c:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600e51:	4d 85 e4             	test   %r12,%r12
  8041600e54:	74 06                	je     8041600e5c <dwarf_read_abbrev_entry+0x131>
  8041600e56:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600e5a:	77 0a                	ja     8041600e66 <dwarf_read_abbrev_entry+0x13b>
      bytes = sizeof(Dwarf_Half);
  8041600e5c:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600e61:	e9 6d ff ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e66:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e6b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e6f:	4c 89 e7             	mov    %r12,%rdi
  8041600e72:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600e79:	00 00 00 
  8041600e7c:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600e7e:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e83:	e9 4b ff ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600e88:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600e8d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e91:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e95:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600e9c:	00 00 00 
  8041600e9f:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600ea1:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600ea6:	4d 85 e4             	test   %r12,%r12
  8041600ea9:	74 06                	je     8041600eb1 <dwarf_read_abbrev_entry+0x186>
  8041600eab:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600eaf:	77 0a                	ja     8041600ebb <dwarf_read_abbrev_entry+0x190>
      bytes = sizeof(uint32_t);
  8041600eb1:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600eb6:	e9 18 ff ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  8041600ebb:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ec0:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600ec4:	4c 89 e7             	mov    %r12,%rdi
  8041600ec7:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600ece:	00 00 00 
  8041600ed1:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600ed3:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600ed8:	e9 f6 fe ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600edd:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600ee2:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ee6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600eea:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600ef1:	00 00 00 
  8041600ef4:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600ef6:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600efb:	4d 85 e4             	test   %r12,%r12
  8041600efe:	74 06                	je     8041600f06 <dwarf_read_abbrev_entry+0x1db>
  8041600f00:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600f04:	77 0a                	ja     8041600f10 <dwarf_read_abbrev_entry+0x1e5>
      bytes = sizeof(uint64_t);
  8041600f06:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600f0b:	e9 c3 fe ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041600f10:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f15:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f19:	4c 89 e7             	mov    %r12,%rdi
  8041600f1c:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600f23:	00 00 00 
  8041600f26:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600f28:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600f2d:	e9 a1 fe ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      if (buf && bufsize >= sizeof(char *)) {
  8041600f32:	48 85 d2             	test   %rdx,%rdx
  8041600f35:	74 05                	je     8041600f3c <dwarf_read_abbrev_entry+0x211>
  8041600f37:	83 f9 07             	cmp    $0x7,%ecx
  8041600f3a:	77 18                	ja     8041600f54 <dwarf_read_abbrev_entry+0x229>
      bytes = strlen(entry) + 1;
  8041600f3c:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600f40:	48 b8 8f ac 60 41 80 	movabs $0x804160ac8f,%rax
  8041600f47:	00 00 00 
  8041600f4a:	ff d0                	callq  *%rax
  8041600f4c:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600f4f:	e9 7f fe ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &entry, sizeof(char *));
  8041600f54:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f59:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600f5d:	4c 89 e7             	mov    %r12,%rdi
  8041600f60:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600f67:	00 00 00 
  8041600f6a:	ff d0                	callq  *%rax
  8041600f6c:	eb ce                	jmp    8041600f3c <dwarf_read_abbrev_entry+0x211>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600f6e:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600f72:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600f75:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600f7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600f7f:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600f84:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600f87:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600f8b:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600f8e:	89 f0                	mov    %esi,%eax
  8041600f90:	83 e0 7f             	and    $0x7f,%eax
  8041600f93:	d3 e0                	shl    %cl,%eax
  8041600f95:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600f97:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600f9a:	40 84 f6             	test   %sil,%sil
  8041600f9d:	78 e5                	js     8041600f84 <dwarf_read_abbrev_entry+0x259>
      break;
  }

  *ret = result;

  return count;
  8041600f9f:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600fa2:	4d 01 e8             	add    %r13,%r8
  8041600fa5:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600fa9:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600fad:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600fb0:	4d 85 e4             	test   %r12,%r12
  8041600fb3:	74 18                	je     8041600fcd <dwarf_read_abbrev_entry+0x2a2>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600fb5:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600fba:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600fbe:	4c 89 e7             	mov    %r12,%rdi
  8041600fc1:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600fc8:	00 00 00 
  8041600fcb:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600fcd:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600fd0:	e9 fe fd ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600fd5:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600fda:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600fde:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600fe2:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041600fe9:	00 00 00 
  8041600fec:	ff d0                	callq  *%rax
  8041600fee:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041600ff2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600ff6:	48 83 c0 01          	add    $0x1,%rax
  8041600ffa:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600ffe:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041601002:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041601005:	4d 85 e4             	test   %r12,%r12
  8041601008:	74 18                	je     8041601022 <dwarf_read_abbrev_entry+0x2f7>
        memcpy(buf, &slice, sizeof(struct Slice));
  804160100a:	ba 10 00 00 00       	mov    $0x10,%edx
  804160100f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601013:	4c 89 e7             	mov    %r12,%rdi
  8041601016:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160101d:	00 00 00 
  8041601020:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041601022:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041601025:	e9 a9 fd ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  804160102a:	ba 01 00 00 00       	mov    $0x1,%edx
  804160102f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601033:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601037:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160103e:	00 00 00 
  8041601041:	ff d0                	callq  *%rax
  8041601043:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601047:	4d 85 e4             	test   %r12,%r12
  804160104a:	0f 84 43 06 00 00    	je     8041601693 <dwarf_read_abbrev_entry+0x968>
  8041601050:	45 85 ed             	test   %r13d,%r13d
  8041601053:	0f 84 3a 06 00 00    	je     8041601693 <dwarf_read_abbrev_entry+0x968>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601059:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  804160105d:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601062:	e9 6c fd ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041601067:	ba 01 00 00 00       	mov    $0x1,%edx
  804160106c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601070:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601074:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160107b:	00 00 00 
  804160107e:	ff d0                	callq  *%rax
  8041601080:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  8041601084:	4d 85 e4             	test   %r12,%r12
  8041601087:	0f 84 10 06 00 00    	je     804160169d <dwarf_read_abbrev_entry+0x972>
  804160108d:	45 85 ed             	test   %r13d,%r13d
  8041601090:	0f 84 07 06 00 00    	je     804160169d <dwarf_read_abbrev_entry+0x972>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041601096:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  8041601098:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  804160109d:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  80416010a2:	e9 2c fd ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      int count = dwarf_read_leb128(entry, &data);
  80416010a7:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416010ab:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  80416010ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416010b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416010b8:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  80416010bd:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416010c0:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  80416010c4:	89 f0                	mov    %esi,%eax
  80416010c6:	83 e0 7f             	and    $0x7f,%eax
  80416010c9:	d3 e0                	shl    %cl,%eax
  80416010cb:	09 c7                	or     %eax,%edi
    shift += 7;
  80416010cd:	83 c1 07             	add    $0x7,%ecx
    count++;
  80416010d0:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  80416010d3:	40 84 f6             	test   %sil,%sil
  80416010d6:	78 e5                	js     80416010bd <dwarf_read_abbrev_entry+0x392>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  80416010d8:	83 f9 1f             	cmp    $0x1f,%ecx
  80416010db:	7f 0f                	jg     80416010ec <dwarf_read_abbrev_entry+0x3c1>
  80416010dd:	40 f6 c6 40          	test   $0x40,%sil
  80416010e1:	74 09                	je     80416010ec <dwarf_read_abbrev_entry+0x3c1>
    result |= (-1U << shift);
  80416010e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416010e8:	d3 e0                	shl    %cl,%eax
  80416010ea:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  80416010ec:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  80416010ef:	49 01 c0             	add    %rax,%r8
  80416010f2:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  80416010f6:	4d 85 e4             	test   %r12,%r12
  80416010f9:	0f 84 d4 fc ff ff    	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  80416010ff:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601103:	0f 86 ca fc ff ff    	jbe    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (int *)buf);
  8041601109:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160110c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601111:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601115:	4c 89 e7             	mov    %r12,%rdi
  8041601118:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160111f:	00 00 00 
  8041601122:	ff d0                	callq  *%rax
  8041601124:	e9 aa fc ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601129:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160112d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601132:	4c 89 f6             	mov    %r14,%rsi
  8041601135:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601139:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601140:	00 00 00 
  8041601143:	ff d0                	callq  *%rax
  8041601145:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601148:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160114a:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160114f:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601152:	76 2a                	jbe    804160117e <dwarf_read_abbrev_entry+0x453>
    if (initial_len == DW_EXT_DWARF64) {
  8041601154:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601157:	74 60                	je     80416011b9 <dwarf_read_abbrev_entry+0x48e>
      cprintf("Unknown DWARF extension\n");
  8041601159:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  8041601160:	00 00 00 
  8041601163:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601168:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160116f:	00 00 00 
  8041601172:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601174:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  8041601179:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  804160117e:	48 63 c3             	movslq %ebx,%rax
  8041601181:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601185:	4d 85 e4             	test   %r12,%r12
  8041601188:	0f 84 45 fc ff ff    	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  804160118e:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601192:	0f 86 3b fc ff ff    	jbe    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  8041601198:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  804160119c:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011a1:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011a5:	4c 89 e7             	mov    %r12,%rdi
  80416011a8:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416011af:	00 00 00 
  80416011b2:	ff d0                	callq  *%rax
  80416011b4:	e9 1a fc ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416011b9:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416011bd:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011c2:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416011c6:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416011cd:	00 00 00 
  80416011d0:	ff d0                	callq  *%rax
  80416011d2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416011d6:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416011db:	eb a1                	jmp    804160117e <dwarf_read_abbrev_entry+0x453>
      int count         = dwarf_read_uleb128(entry, &data);
  80416011dd:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416011e1:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  80416011e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416011e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416011ee:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  80416011f3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416011f6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416011fa:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  80416011fd:	89 f0                	mov    %esi,%eax
  80416011ff:	83 e0 7f             	and    $0x7f,%eax
  8041601202:	d3 e0                	shl    %cl,%eax
  8041601204:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601206:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601209:	40 84 f6             	test   %sil,%sil
  804160120c:	78 e5                	js     80416011f3 <dwarf_read_abbrev_entry+0x4c8>
  return count;
  804160120e:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601211:	49 01 c0             	add    %rax,%r8
  8041601214:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  8041601218:	4d 85 e4             	test   %r12,%r12
  804160121b:	0f 84 b2 fb ff ff    	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  8041601221:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601225:	0f 86 a8 fb ff ff    	jbe    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  804160122b:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160122e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601233:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601237:	4c 89 e7             	mov    %r12,%rdi
  804160123a:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601241:	00 00 00 
  8041601244:	ff d0                	callq  *%rax
  8041601246:	e9 88 fb ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160124b:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160124f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601254:	4c 89 f6             	mov    %r14,%rsi
  8041601257:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160125b:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601262:	00 00 00 
  8041601265:	ff d0                	callq  *%rax
  8041601267:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160126a:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160126c:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601271:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601274:	76 2a                	jbe    80416012a0 <dwarf_read_abbrev_entry+0x575>
    if (initial_len == DW_EXT_DWARF64) {
  8041601276:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601279:	74 60                	je     80416012db <dwarf_read_abbrev_entry+0x5b0>
      cprintf("Unknown DWARF extension\n");
  804160127b:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  8041601282:	00 00 00 
  8041601285:	b8 00 00 00 00       	mov    $0x0,%eax
  804160128a:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041601291:	00 00 00 
  8041601294:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601296:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160129b:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416012a0:	48 63 c3             	movslq %ebx,%rax
  80416012a3:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416012a7:	4d 85 e4             	test   %r12,%r12
  80416012aa:	0f 84 23 fb ff ff    	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  80416012b0:	41 83 fd 07          	cmp    $0x7,%r13d
  80416012b4:	0f 86 19 fb ff ff    	jbe    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416012ba:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416012be:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012c3:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012c7:	4c 89 e7             	mov    %r12,%rdi
  80416012ca:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416012d1:	00 00 00 
  80416012d4:	ff d0                	callq  *%rax
  80416012d6:	e9 f8 fa ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416012db:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416012df:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012e4:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012e8:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416012ef:	00 00 00 
  80416012f2:	ff d0                	callq  *%rax
  80416012f4:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416012f8:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416012fd:	eb a1                	jmp    80416012a0 <dwarf_read_abbrev_entry+0x575>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  80416012ff:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601304:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601308:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160130c:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601313:	00 00 00 
  8041601316:	ff d0                	callq  *%rax
  8041601318:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160131c:	4d 85 e4             	test   %r12,%r12
  804160131f:	0f 84 82 03 00 00    	je     80416016a7 <dwarf_read_abbrev_entry+0x97c>
  8041601325:	45 85 ed             	test   %r13d,%r13d
  8041601328:	0f 84 79 03 00 00    	je     80416016a7 <dwarf_read_abbrev_entry+0x97c>
        put_unaligned(data, (Dwarf_Small *)buf);
  804160132e:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601332:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601337:	e9 97 fa ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  804160133c:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601341:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601345:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601349:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601350:	00 00 00 
  8041601353:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041601355:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  804160135a:	4d 85 e4             	test   %r12,%r12
  804160135d:	74 06                	je     8041601365 <dwarf_read_abbrev_entry+0x63a>
  804160135f:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601363:	77 0a                	ja     804160136f <dwarf_read_abbrev_entry+0x644>
      bytes = sizeof(Dwarf_Half);
  8041601365:	bb 02 00 00 00       	mov    $0x2,%ebx
  804160136a:	e9 64 fa ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  804160136f:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601374:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601378:	4c 89 e7             	mov    %r12,%rdi
  804160137b:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601382:	00 00 00 
  8041601385:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041601387:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  804160138c:	e9 42 fa ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041601391:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601396:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160139a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160139e:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416013a5:	00 00 00 
  80416013a8:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416013aa:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416013af:	4d 85 e4             	test   %r12,%r12
  80416013b2:	74 06                	je     80416013ba <dwarf_read_abbrev_entry+0x68f>
  80416013b4:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013b8:	77 0a                	ja     80416013c4 <dwarf_read_abbrev_entry+0x699>
      bytes = sizeof(uint32_t);
  80416013ba:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416013bf:	e9 0f fa ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  80416013c4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013c9:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013cd:	4c 89 e7             	mov    %r12,%rdi
  80416013d0:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416013d7:	00 00 00 
  80416013da:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  80416013dc:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  80416013e1:	e9 ed f9 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  80416013e6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416013eb:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013ef:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416013f3:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416013fa:	00 00 00 
  80416013fd:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  80416013ff:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601404:	4d 85 e4             	test   %r12,%r12
  8041601407:	74 06                	je     804160140f <dwarf_read_abbrev_entry+0x6e4>
  8041601409:	41 83 fd 07          	cmp    $0x7,%r13d
  804160140d:	77 0a                	ja     8041601419 <dwarf_read_abbrev_entry+0x6ee>
      bytes = sizeof(uint64_t);
  804160140f:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041601414:	e9 ba f9 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041601419:	ba 08 00 00 00       	mov    $0x8,%edx
  804160141e:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601422:	4c 89 e7             	mov    %r12,%rdi
  8041601425:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160142c:	00 00 00 
  804160142f:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601431:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041601436:	e9 98 f9 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &data);
  804160143b:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  804160143f:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601442:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601447:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160144c:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601451:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601454:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601458:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160145b:	89 f0                	mov    %esi,%eax
  804160145d:	83 e0 7f             	and    $0x7f,%eax
  8041601460:	d3 e0                	shl    %cl,%eax
  8041601462:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601464:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601467:	40 84 f6             	test   %sil,%sil
  804160146a:	78 e5                	js     8041601451 <dwarf_read_abbrev_entry+0x726>
  return count;
  804160146c:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  804160146f:	49 01 c0             	add    %rax,%r8
  8041601472:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  8041601476:	4d 85 e4             	test   %r12,%r12
  8041601479:	0f 84 54 f9 ff ff    	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  804160147f:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601483:	0f 86 4a f9 ff ff    	jbe    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  8041601489:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160148c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601491:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601495:	4c 89 e7             	mov    %r12,%rdi
  8041601498:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160149f:	00 00 00 
  80416014a2:	ff d0                	callq  *%rax
  80416014a4:	e9 2a f9 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &form);
  80416014a9:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416014ad:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416014b0:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416014b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014bb:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416014c0:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416014c4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416014c8:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416014cc:	44 89 c0             	mov    %r8d,%eax
  80416014cf:	83 e0 7f             	and    $0x7f,%eax
  80416014d2:	d3 e0                	shl    %cl,%eax
  80416014d4:	09 c6                	or     %eax,%esi
    shift += 7;
  80416014d6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416014d9:	45 84 c0             	test   %r8b,%r8b
  80416014dc:	78 e2                	js     80416014c0 <dwarf_read_abbrev_entry+0x795>
  return count;
  80416014de:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  80416014e1:	48 01 c7             	add    %rax,%rdi
  80416014e4:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  80416014e8:	41 89 d8             	mov    %ebx,%r8d
  80416014eb:	44 89 e9             	mov    %r13d,%ecx
  80416014ee:	4c 89 e2             	mov    %r12,%rdx
  80416014f1:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  80416014f8:	00 00 00 
  80416014fb:	ff d0                	callq  *%rax
      bytes    = count + read;
  80416014fd:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601501:	e9 cd f8 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601506:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160150a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160150f:	4c 89 f6             	mov    %r14,%rsi
  8041601512:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601516:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160151d:	00 00 00 
  8041601520:	ff d0                	callq  *%rax
  8041601522:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601525:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601527:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160152c:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160152f:	76 2a                	jbe    804160155b <dwarf_read_abbrev_entry+0x830>
    if (initial_len == DW_EXT_DWARF64) {
  8041601531:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601534:	74 60                	je     8041601596 <dwarf_read_abbrev_entry+0x86b>
      cprintf("Unknown DWARF extension\n");
  8041601536:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  804160153d:	00 00 00 
  8041601540:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601545:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160154c:	00 00 00 
  804160154f:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601551:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  8041601556:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  804160155b:	48 63 c3             	movslq %ebx,%rax
  804160155e:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601562:	4d 85 e4             	test   %r12,%r12
  8041601565:	0f 84 68 f8 ff ff    	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  804160156b:	41 83 fd 07          	cmp    $0x7,%r13d
  804160156f:	0f 86 5e f8 ff ff    	jbe    8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  8041601575:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601579:	ba 08 00 00 00       	mov    $0x8,%edx
  804160157e:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601582:	4c 89 e7             	mov    %r12,%rdi
  8041601585:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160158c:	00 00 00 
  804160158f:	ff d0                	callq  *%rax
  8041601591:	e9 3d f8 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601596:	49 8d 76 20          	lea    0x20(%r14),%rsi
  804160159a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160159f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416015a3:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416015aa:	00 00 00 
  80416015ad:	ff d0                	callq  *%rax
  80416015af:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416015b3:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416015b8:	eb a1                	jmp    804160155b <dwarf_read_abbrev_entry+0x830>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416015ba:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416015be:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416015c1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416015c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416015cc:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416015d1:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416015d4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416015d8:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416015dc:	89 f8                	mov    %edi,%eax
  80416015de:	83 e0 7f             	and    $0x7f,%eax
  80416015e1:	d3 e0                	shl    %cl,%eax
  80416015e3:	09 c3                	or     %eax,%ebx
    shift += 7;
  80416015e5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416015e8:	40 84 ff             	test   %dil,%dil
  80416015eb:	78 e4                	js     80416015d1 <dwarf_read_abbrev_entry+0x8a6>
  return count;
  80416015ed:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  80416015f0:	4c 01 f6             	add    %r14,%rsi
  80416015f3:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  80416015f7:	4d 85 e4             	test   %r12,%r12
  80416015fa:	74 1a                	je     8041601616 <dwarf_read_abbrev_entry+0x8eb>
        memcpy(buf, entry, MIN(length, bufsize));
  80416015fc:	41 39 dd             	cmp    %ebx,%r13d
  80416015ff:	44 89 ea             	mov    %r13d,%edx
  8041601602:	0f 47 d3             	cmova  %ebx,%edx
  8041601605:	89 d2                	mov    %edx,%edx
  8041601607:	4c 89 e7             	mov    %r12,%rdi
  804160160a:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601611:	00 00 00 
  8041601614:	ff d0                	callq  *%rax
      bytes = count + length;
  8041601616:	44 01 f3             	add    %r14d,%ebx
    } break;
  8041601619:	e9 b5 f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      bytes = 0;
  804160161e:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  8041601623:	48 85 d2             	test   %rdx,%rdx
  8041601626:	0f 84 a7 f7 ff ff    	je     8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(true, (bool *)buf);
  804160162c:	c6 02 01             	movb   $0x1,(%rdx)
  804160162f:	e9 9f f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601634:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601639:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160163d:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601641:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601648:	00 00 00 
  804160164b:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  804160164d:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601652:	4d 85 e4             	test   %r12,%r12
  8041601655:	74 06                	je     804160165d <dwarf_read_abbrev_entry+0x932>
  8041601657:	41 83 fd 07          	cmp    $0x7,%r13d
  804160165b:	77 0a                	ja     8041601667 <dwarf_read_abbrev_entry+0x93c>
      bytes = sizeof(uint64_t);
  804160165d:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  8041601662:	e9 6c f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041601667:	ba 08 00 00 00       	mov    $0x8,%edx
  804160166c:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601670:	4c 89 e7             	mov    %r12,%rdi
  8041601673:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160167a:	00 00 00 
  804160167d:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  804160167f:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041601684:	e9 4a f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
  int bytes = 0;
  8041601689:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160168e:	e9 40 f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  8041601693:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041601698:	e9 36 f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  804160169d:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016a2:	e9 2c f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016a7:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016ac:	e9 22 f7 ff ff       	jmpq   8041600dd3 <dwarf_read_abbrev_entry+0xa8>

00000080416016b1 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416016b1:	55                   	push   %rbp
  80416016b2:	48 89 e5             	mov    %rsp,%rbp
  80416016b5:	41 57                	push   %r15
  80416016b7:	41 56                	push   %r14
  80416016b9:	41 55                	push   %r13
  80416016bb:	41 54                	push   %r12
  80416016bd:	53                   	push   %rbx
  80416016be:	48 83 ec 48          	sub    $0x48,%rsp
  80416016c2:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80416016c6:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416016ca:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  80416016ce:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416016d2:	49 bd 08 af 60 41 80 	movabs $0x804160af08,%r13
  80416016d9:	00 00 00 
  80416016dc:	e9 bb 01 00 00       	jmpq   804160189c <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416016e1:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416016e5:	ba 08 00 00 00       	mov    $0x8,%edx
  80416016ea:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416016ee:	41 ff d5             	callq  *%r13
  80416016f1:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  80416016f5:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416016fa:	eb 08                	jmp    8041601704 <info_by_address+0x53>
    *len = initial_len;
  80416016fc:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  80416016ff:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  8041601704:	4c 63 fb             	movslq %ebx,%r15
  8041601707:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  804160170b:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  804160170e:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601713:	48 89 de             	mov    %rbx,%rsi
  8041601716:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160171a:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  804160171d:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  8041601721:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041601726:	75 7a                	jne    80416017a2 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601728:	ba 04 00 00 00       	mov    $0x4,%edx
  804160172d:	48 89 de             	mov    %rbx,%rsi
  8041601730:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601734:	41 ff d5             	callq  *%r13
  8041601737:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160173a:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  804160173d:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  8041601740:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  8041601744:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601749:	48 89 de             	mov    %rbx,%rsi
  804160174c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601750:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  8041601753:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601757:	75 7e                	jne    80416017d7 <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  8041601759:	48 83 c3 02          	add    $0x2,%rbx
  804160175d:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601762:	4c 89 fe             	mov    %r15,%rsi
  8041601765:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601769:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  804160176c:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  8041601770:	0f 85 96 00 00 00    	jne    804160180c <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  8041601776:	48 89 d8             	mov    %rbx,%rax
  8041601779:	4c 29 f0             	sub    %r14,%rax
  804160177c:	48 99                	cqto   
  804160177e:	48 c1 ea 3c          	shr    $0x3c,%rdx
  8041601782:	48 01 d0             	add    %rdx,%rax
  8041601785:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  8041601788:	48 29 d0             	sub    %rdx,%rax
  804160178b:	0f 84 b5 00 00 00    	je     8041601846 <info_by_address+0x195>
      set += 2 * address_size - remainder;
  8041601791:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601796:	89 d1                	mov    %edx,%ecx
  8041601798:	29 c1                	sub    %eax,%ecx
  804160179a:	48 01 cb             	add    %rcx,%rbx
  804160179d:	e9 a4 00 00 00       	jmpq   8041601846 <info_by_address+0x195>
    assert(version == 2);
  80416017a2:	48 b9 de b9 60 41 80 	movabs $0x804160b9de,%rcx
  80416017a9:	00 00 00 
  80416017ac:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416017b3:	00 00 00 
  80416017b6:	be 20 00 00 00       	mov    $0x20,%esi
  80416017bb:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  80416017c2:	00 00 00 
  80416017c5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017ca:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416017d1:	00 00 00 
  80416017d4:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416017d7:	48 b9 9b b9 60 41 80 	movabs $0x804160b99b,%rcx
  80416017de:	00 00 00 
  80416017e1:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416017e8:	00 00 00 
  80416017eb:	be 24 00 00 00       	mov    $0x24,%esi
  80416017f0:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  80416017f7:	00 00 00 
  80416017fa:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017ff:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601806:	00 00 00 
  8041601809:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  804160180c:	48 b9 ad b9 60 41 80 	movabs $0x804160b9ad,%rcx
  8041601813:	00 00 00 
  8041601816:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160181d:	00 00 00 
  8041601820:	be 26 00 00 00       	mov    $0x26,%esi
  8041601825:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  804160182c:	00 00 00 
  804160182f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601834:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160183b:	00 00 00 
  804160183e:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601841:	4c 39 e3             	cmp    %r12,%rbx
  8041601844:	73 51                	jae    8041601897 <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  8041601846:	ba 08 00 00 00       	mov    $0x8,%edx
  804160184b:	48 89 de             	mov    %rbx,%rsi
  804160184e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601852:	41 ff d5             	callq  *%r13
  8041601855:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  8041601859:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  804160185d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601862:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601866:	41 ff d5             	callq  *%r13
  8041601869:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  804160186c:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  8041601870:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8041601874:	4c 39 f1             	cmp    %r14,%rcx
  8041601877:	72 c8                	jb     8041601841 <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  8041601879:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  804160187b:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  804160187e:	48 39 c1             	cmp    %rax,%rcx
  8041601881:	77 be                	ja     8041601841 <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601883:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041601887:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  804160188a:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  804160188d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601892:	e9 5a 04 00 00       	jmpq   8041601cf1 <info_by_address+0x640>
      set += address_size;
  8041601897:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  804160189a:	75 71                	jne    804160190d <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  804160189c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018a0:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  80416018a4:	73 42                	jae    80416018e8 <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  80416018a6:	ba 04 00 00 00       	mov    $0x4,%edx
  80416018ab:	4c 89 f6             	mov    %r14,%rsi
  80416018ae:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018b2:	41 ff d5             	callq  *%r13
  80416018b5:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416018b9:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  80416018bd:	0f 86 39 fe ff ff    	jbe    80416016fc <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  80416018c3:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  80416018c7:	0f 84 14 fe ff ff    	je     80416016e1 <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  80416018cd:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  80416018d4:	00 00 00 
  80416018d7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018dc:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416018e3:	00 00 00 
  80416018e6:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  80416018e8:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018ec:	48 8b 58 20          	mov    0x20(%rax),%rbx
  80416018f0:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  80416018f4:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  80416018f8:	0f 83 5b 04 00 00    	jae    8041601d59 <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  80416018fe:	49 bf 08 af 60 41 80 	movabs $0x804160af08,%r15
  8041601905:	00 00 00 
  8041601908:	e9 9f 03 00 00       	jmpq   8041601cac <info_by_address+0x5fb>
    assert(set == set_end);
  804160190d:	48 b9 bf b9 60 41 80 	movabs $0x804160b9bf,%rcx
  8041601914:	00 00 00 
  8041601917:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160191e:	00 00 00 
  8041601921:	be 3a 00 00 00       	mov    $0x3a,%esi
  8041601926:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  804160192d:	00 00 00 
  8041601930:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601935:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160193c:	00 00 00 
  804160193f:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601942:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601946:	48 8d 70 20          	lea    0x20(%rax),%rsi
  804160194a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160194f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601953:	41 ff d7             	callq  *%r15
  8041601956:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160195a:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601960:	eb 08                	jmp    804160196a <info_by_address+0x2b9>
    *len = initial_len;
  8041601962:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041601964:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  804160196a:	4d 63 e4             	movslq %r12d,%r12
  804160196d:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041601971:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  8041601975:	48 01 d8             	add    %rbx,%rax
  8041601978:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160197c:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601981:	48 89 de             	mov    %rbx,%rsi
  8041601984:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601988:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  804160198b:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  804160198f:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601993:	83 e8 02             	sub    $0x2,%eax
  8041601996:	66 a9 fd ff          	test   $0xfffd,%ax
  804160199a:	0f 85 07 01 00 00    	jne    8041601aa7 <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416019a0:	ba 04 00 00 00       	mov    $0x4,%edx
  80416019a5:	48 89 de             	mov    %rbx,%rsi
  80416019a8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019ac:	41 ff d7             	callq  *%r15
  80416019af:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  80416019b3:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416019b7:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  80416019bb:	ba 01 00 00 00       	mov    $0x1,%edx
  80416019c0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019c4:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  80416019c7:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416019cb:	0f 85 0b 01 00 00    	jne    8041601adc <info_by_address+0x42b>
  80416019d1:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  80416019d4:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416019d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416019de:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416019e3:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  80416019e7:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  80416019eb:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416019ee:	44 89 c7             	mov    %r8d,%edi
  80416019f1:	83 e7 7f             	and    $0x7f,%edi
  80416019f4:	d3 e7                	shl    %cl,%edi
  80416019f6:	09 fa                	or     %edi,%edx
    shift += 7;
  80416019f8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416019fb:	45 84 c0             	test   %r8b,%r8b
  80416019fe:	78 e3                	js     80416019e3 <info_by_address+0x332>
  return count;
  8041601a00:	48 98                	cltq   
    assert(abbrev_code != 0);
  8041601a02:	85 d2                	test   %edx,%edx
  8041601a04:	0f 84 07 01 00 00    	je     8041601b11 <info_by_address+0x460>
    entry += count;
  8041601a0a:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601a0d:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601a11:	4c 03 28             	add    (%rax),%r13
  8041601a14:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  8041601a17:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a21:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601a26:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041601a2a:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041601a2e:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a31:	45 89 c8             	mov    %r9d,%r8d
  8041601a34:	41 83 e0 7f          	and    $0x7f,%r8d
  8041601a38:	41 d3 e0             	shl    %cl,%r8d
  8041601a3b:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  8041601a3e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a41:	45 84 c9             	test   %r9b,%r9b
  8041601a44:	78 e0                	js     8041601a26 <info_by_address+0x375>
  return count;
  8041601a46:	48 98                	cltq   
    abbrev_entry += count;
  8041601a48:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  8041601a4b:	39 f2                	cmp    %esi,%edx
  8041601a4d:	0f 85 f3 00 00 00    	jne    8041601b46 <info_by_address+0x495>
  8041601a53:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  8041601a56:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a60:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601a65:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601a69:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a6d:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a70:	44 89 c7             	mov    %r8d,%edi
  8041601a73:	83 e7 7f             	and    $0x7f,%edi
  8041601a76:	d3 e7                	shl    %cl,%edi
  8041601a78:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a7a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a7d:	45 84 c0             	test   %r8b,%r8b
  8041601a80:	78 e3                	js     8041601a65 <info_by_address+0x3b4>
  return count;
  8041601a82:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  8041601a84:	83 fa 11             	cmp    $0x11,%edx
  8041601a87:	0f 85 ee 00 00 00    	jne    8041601b7b <info_by_address+0x4ca>
    abbrev_entry++;
  8041601a8d:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601a92:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601a99:	00 
  8041601a9a:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601aa1:	00 
  8041601aa2:	e9 2f 01 00 00       	jmpq   8041601bd6 <info_by_address+0x525>
    assert(version == 4 || version == 2);
  8041601aa7:	48 b9 ce b9 60 41 80 	movabs $0x804160b9ce,%rcx
  8041601aae:	00 00 00 
  8041601ab1:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601ab8:	00 00 00 
  8041601abb:	be 43 01 00 00       	mov    $0x143,%esi
  8041601ac0:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601ac7:	00 00 00 
  8041601aca:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601acf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ad6:	00 00 00 
  8041601ad9:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601adc:	48 b9 9b b9 60 41 80 	movabs $0x804160b99b,%rcx
  8041601ae3:	00 00 00 
  8041601ae6:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601aed:	00 00 00 
  8041601af0:	be 47 01 00 00       	mov    $0x147,%esi
  8041601af5:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601afc:	00 00 00 
  8041601aff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b04:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b0b:	00 00 00 
  8041601b0e:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601b11:	48 b9 eb b9 60 41 80 	movabs $0x804160b9eb,%rcx
  8041601b18:	00 00 00 
  8041601b1b:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601b22:	00 00 00 
  8041601b25:	be 4c 01 00 00       	mov    $0x14c,%esi
  8041601b2a:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601b31:	00 00 00 
  8041601b34:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b39:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b40:	00 00 00 
  8041601b43:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601b46:	48 b9 20 bb 60 41 80 	movabs $0x804160bb20,%rcx
  8041601b4d:	00 00 00 
  8041601b50:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601b57:	00 00 00 
  8041601b5a:	be 54 01 00 00       	mov    $0x154,%esi
  8041601b5f:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601b66:	00 00 00 
  8041601b69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b6e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b75:	00 00 00 
  8041601b78:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601b7b:	48 b9 fc b9 60 41 80 	movabs $0x804160b9fc,%rcx
  8041601b82:	00 00 00 
  8041601b85:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601b8c:	00 00 00 
  8041601b8f:	be 58 01 00 00       	mov    $0x158,%esi
  8041601b94:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601b9b:	00 00 00 
  8041601b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ba3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601baa:	00 00 00 
  8041601bad:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601bb0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601bb6:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601bbb:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601bbf:	44 89 f6             	mov    %r14d,%esi
  8041601bc2:	4c 89 e7             	mov    %r12,%rdi
  8041601bc5:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  8041601bcc:	00 00 00 
  8041601bcf:	ff d0                	callq  *%rax
      entry += count;
  8041601bd1:	48 98                	cltq   
  8041601bd3:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601bd6:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601bd9:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601bde:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601be3:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601be9:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601bec:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601bf0:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601bf3:	89 fe                	mov    %edi,%esi
  8041601bf5:	83 e6 7f             	and    $0x7f,%esi
  8041601bf8:	d3 e6                	shl    %cl,%esi
  8041601bfa:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601bfd:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c00:	40 84 ff             	test   %dil,%dil
  8041601c03:	78 e4                	js     8041601be9 <info_by_address+0x538>
  return count;
  8041601c05:	48 98                	cltq   
      abbrev_entry += count;
  8041601c07:	48 01 c3             	add    %rax,%rbx
  8041601c0a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c12:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c17:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601c1d:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c20:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c24:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c27:	89 fe                	mov    %edi,%esi
  8041601c29:	83 e6 7f             	and    $0x7f,%esi
  8041601c2c:	d3 e6                	shl    %cl,%esi
  8041601c2e:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601c31:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c34:	40 84 ff             	test   %dil,%dil
  8041601c37:	78 e4                	js     8041601c1d <info_by_address+0x56c>
  return count;
  8041601c39:	48 98                	cltq   
      abbrev_entry += count;
  8041601c3b:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601c3e:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601c42:	0f 84 68 ff ff ff    	je     8041601bb0 <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601c48:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601c4c:	0f 84 ae 00 00 00    	je     8041601d00 <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601c52:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c58:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601c62:	44 89 f6             	mov    %r14d,%esi
  8041601c65:	4c 89 e7             	mov    %r12,%rdi
  8041601c68:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  8041601c6f:	00 00 00 
  8041601c72:	ff d0                	callq  *%rax
      entry += count;
  8041601c74:	48 98                	cltq   
  8041601c76:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601c79:	45 09 f5             	or     %r14d,%r13d
  8041601c7c:	0f 85 54 ff ff ff    	jne    8041601bd6 <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601c82:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601c86:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601c8a:	72 0a                	jb     8041601c96 <info_by_address+0x5e5>
  8041601c8c:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601c90:	0f 86 a2 00 00 00    	jbe    8041601d38 <info_by_address+0x687>
    entry = entry_end;
  8041601c96:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601c9a:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601c9e:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601ca2:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601ca6:	0f 83 a6 00 00 00    	jae    8041601d52 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601cac:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601cb1:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601cb5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601cb9:	41 ff d7             	callq  *%r15
  8041601cbc:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601cbf:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601cc2:	0f 86 9a fc ff ff    	jbe    8041601962 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601cc8:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601ccb:	0f 84 71 fc ff ff    	je     8041601942 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601cd1:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  8041601cd8:	00 00 00 
  8041601cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ce0:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041601ce7:	00 00 00 
  8041601cea:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601cec:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601cf1:	48 83 c4 48          	add    $0x48,%rsp
  8041601cf5:	5b                   	pop    %rbx
  8041601cf6:	41 5c                	pop    %r12
  8041601cf8:	41 5d                	pop    %r13
  8041601cfa:	41 5e                	pop    %r14
  8041601cfc:	41 5f                	pop    %r15
  8041601cfe:	5d                   	pop    %rbp
  8041601cff:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601d00:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601d06:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601d0b:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601d0f:	44 89 f6             	mov    %r14d,%esi
  8041601d12:	4c 89 e7             	mov    %r12,%rdi
  8041601d15:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  8041601d1c:	00 00 00 
  8041601d1f:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601d21:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601d25:	0f 84 a6 fe ff ff    	je     8041601bd1 <info_by_address+0x520>
          high_pc += low_pc;
  8041601d2b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601d2f:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601d33:	e9 99 fe ff ff       	jmpq   8041601bd1 <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601d38:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601d3c:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601d40:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601d44:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601d48:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d50:	eb 9f                	jmp    8041601cf1 <info_by_address+0x640>
  return 0;
  8041601d52:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d57:	eb 98                	jmp    8041601cf1 <info_by_address+0x640>
  8041601d59:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d5e:	eb 91                	jmp    8041601cf1 <info_by_address+0x640>

0000008041601d60 <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601d60:	55                   	push   %rbp
  8041601d61:	48 89 e5             	mov    %rsp,%rbp
  8041601d64:	41 57                	push   %r15
  8041601d66:	41 56                	push   %r14
  8041601d68:	41 55                	push   %r13
  8041601d6a:	41 54                	push   %r12
  8041601d6c:	53                   	push   %rbx
  8041601d6d:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601d71:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601d75:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601d79:	48 29 d8             	sub    %rbx,%rax
  8041601d7c:	48 39 f0             	cmp    %rsi,%rax
  8041601d7f:	0f 82 f5 02 00 00    	jb     804160207a <file_name_by_info+0x31a>
  8041601d85:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601d89:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601d8c:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601d90:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601d94:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601d97:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601d9c:	48 89 de             	mov    %rbx,%rsi
  8041601d9f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601da3:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601daa:	00 00 00 
  8041601dad:	ff d0                	callq  *%rax
  8041601daf:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601db2:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601db5:	0f 86 c9 02 00 00    	jbe    8041602084 <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601dbb:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601dbe:	74 25                	je     8041601de5 <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601dc0:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  8041601dc7:	00 00 00 
  8041601dca:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dcf:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041601dd6:	00 00 00 
  8041601dd9:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601ddb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601de0:	e9 00 02 00 00       	jmpq   8041601fe5 <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601de5:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601de9:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601dee:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601df2:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041601df9:	00 00 00 
  8041601dfc:	ff d0                	callq  *%rax
      count = 12;
  8041601dfe:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601e04:	e9 81 02 00 00       	jmpq   804160208a <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601e09:	48 b9 ce b9 60 41 80 	movabs $0x804160b9ce,%rcx
  8041601e10:	00 00 00 
  8041601e13:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601e1a:	00 00 00 
  8041601e1d:	be 9b 01 00 00       	mov    $0x19b,%esi
  8041601e22:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601e29:	00 00 00 
  8041601e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e31:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e38:	00 00 00 
  8041601e3b:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601e3e:	48 b9 9b b9 60 41 80 	movabs $0x804160b99b,%rcx
  8041601e45:	00 00 00 
  8041601e48:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601e4f:	00 00 00 
  8041601e52:	be 9f 01 00 00       	mov    $0x19f,%esi
  8041601e57:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601e5e:	00 00 00 
  8041601e61:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e66:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e6d:	00 00 00 
  8041601e70:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601e73:	48 b9 eb b9 60 41 80 	movabs $0x804160b9eb,%rcx
  8041601e7a:	00 00 00 
  8041601e7d:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601e84:	00 00 00 
  8041601e87:	be a4 01 00 00       	mov    $0x1a4,%esi
  8041601e8c:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601e93:	00 00 00 
  8041601e96:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e9b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ea2:	00 00 00 
  8041601ea5:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601ea8:	48 b9 20 bb 60 41 80 	movabs $0x804160bb20,%rcx
  8041601eaf:	00 00 00 
  8041601eb2:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601eb9:	00 00 00 
  8041601ebc:	be ac 01 00 00       	mov    $0x1ac,%esi
  8041601ec1:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601ec8:	00 00 00 
  8041601ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ed0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ed7:	00 00 00 
  8041601eda:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601edd:	48 b9 fc b9 60 41 80 	movabs $0x804160b9fc,%rcx
  8041601ee4:	00 00 00 
  8041601ee7:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041601eee:	00 00 00 
  8041601ef1:	be b0 01 00 00       	mov    $0x1b0,%esi
  8041601ef6:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041601efd:	00 00 00 
  8041601f00:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f05:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601f0c:	00 00 00 
  8041601f0f:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601f12:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601f16:	0f 84 d8 00 00 00    	je     8041601ff4 <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601f1c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f22:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601f25:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601f29:	44 89 ee             	mov    %r13d,%esi
  8041601f2c:	4c 89 f7             	mov    %r14,%rdi
  8041601f2f:	41 ff d7             	callq  *%r15
  8041601f32:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601f35:	49 63 c4             	movslq %r12d,%rax
  8041601f38:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601f3b:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f3e:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f43:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f48:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601f4e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f51:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f55:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f58:	89 f0                	mov    %esi,%eax
  8041601f5a:	83 e0 7f             	and    $0x7f,%eax
  8041601f5d:	d3 e0                	shl    %cl,%eax
  8041601f5f:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601f62:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601f65:	40 84 f6             	test   %sil,%sil
  8041601f68:	78 e4                	js     8041601f4e <file_name_by_info+0x1ee>
  return count;
  8041601f6a:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601f6d:	48 01 fb             	add    %rdi,%rbx
  8041601f70:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f73:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f78:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f7d:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601f83:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f86:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f8a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f8d:	89 f0                	mov    %esi,%eax
  8041601f8f:	83 e0 7f             	and    $0x7f,%eax
  8041601f92:	d3 e0                	shl    %cl,%eax
  8041601f94:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601f97:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601f9a:	40 84 f6             	test   %sil,%sil
  8041601f9d:	78 e4                	js     8041601f83 <file_name_by_info+0x223>
  return count;
  8041601f9f:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601fa2:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041601fa5:	41 83 fc 03          	cmp    $0x3,%r12d
  8041601fa9:	0f 84 63 ff ff ff    	je     8041601f12 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041601faf:	41 83 fc 10          	cmp    $0x10,%r12d
  8041601fb3:	0f 84 a1 00 00 00    	je     804160205a <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601fb9:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601fbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601fc9:	44 89 ee             	mov    %r13d,%esi
  8041601fcc:	4c 89 f7             	mov    %r14,%rdi
  8041601fcf:	41 ff d7             	callq  *%r15
    entry += count;
  8041601fd2:	48 98                	cltq   
  8041601fd4:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601fd7:	45 09 e5             	or     %r12d,%r13d
  8041601fda:	0f 85 5b ff ff ff    	jne    8041601f3b <file_name_by_info+0x1db>

  return 0;
  8041601fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601fe5:	48 83 c4 38          	add    $0x38,%rsp
  8041601fe9:	5b                   	pop    %rbx
  8041601fea:	41 5c                	pop    %r12
  8041601fec:	41 5d                	pop    %r13
  8041601fee:	41 5e                	pop    %r14
  8041601ff0:	41 5f                	pop    %r15
  8041601ff2:	5d                   	pop    %rbp
  8041601ff3:	c3                   	retq   
        unsigned long offset = 0;
  8041601ff4:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601ffb:	00 
        count                = dwarf_read_abbrev_entry(
  8041601ffc:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602002:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602007:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160200b:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602010:	4c 89 f7             	mov    %r14,%rdi
  8041602013:	41 ff d7             	callq  *%r15
  8041602016:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  8041602019:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  804160201d:	48 85 ff             	test   %rdi,%rdi
  8041602020:	0f 84 0f ff ff ff    	je     8041601f35 <file_name_by_info+0x1d5>
  8041602026:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  804160202a:	0f 86 05 ff ff ff    	jbe    8041601f35 <file_name_by_info+0x1d5>
          put_unaligned(
  8041602030:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602034:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  8041602038:	48 03 41 40          	add    0x40(%rcx),%rax
  804160203c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602040:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602045:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602049:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041602050:	00 00 00 
  8041602053:	ff d0                	callq  *%rax
  8041602055:	e9 db fe ff ff       	jmpq   8041601f35 <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  804160205a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602060:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602065:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041602069:	44 89 ee             	mov    %r13d,%esi
  804160206c:	4c 89 f7             	mov    %r14,%rdi
  804160206f:	41 ff d7             	callq  *%r15
  8041602072:	41 89 c4             	mov    %eax,%r12d
  8041602075:	e9 bb fe ff ff       	jmpq   8041601f35 <file_name_by_info+0x1d5>
    return -E_INVAL;
  804160207a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160207f:	e9 61 ff ff ff       	jmpq   8041601fe5 <file_name_by_info+0x285>
  count       = 4;
  8041602084:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  804160208a:	4d 63 ed             	movslq %r13d,%r13
  804160208d:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602090:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602095:	48 89 de             	mov    %rbx,%rsi
  8041602098:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160209c:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416020a3:	00 00 00 
  80416020a6:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416020a8:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416020ac:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416020b0:	83 e8 02             	sub    $0x2,%eax
  80416020b3:	66 a9 fd ff          	test   $0xfffd,%ax
  80416020b7:	0f 85 4c fd ff ff    	jne    8041601e09 <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416020bd:	ba 04 00 00 00       	mov    $0x4,%edx
  80416020c2:	48 89 de             	mov    %rbx,%rsi
  80416020c5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020c9:	49 bf 08 af 60 41 80 	movabs $0x804160af08,%r15
  80416020d0:	00 00 00 
  80416020d3:	41 ff d7             	callq  *%r15
  80416020d6:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  80416020da:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416020de:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416020e2:	ba 01 00 00 00       	mov    $0x1,%edx
  80416020e7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020eb:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  80416020ee:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416020f2:	0f 85 46 fd ff ff    	jne    8041601e3e <file_name_by_info+0xde>
  80416020f8:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  80416020fb:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602100:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602105:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  804160210b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160210e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602112:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602115:	89 f0                	mov    %esi,%eax
  8041602117:	83 e0 7f             	and    $0x7f,%eax
  804160211a:	d3 e0                	shl    %cl,%eax
  804160211c:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  804160211f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602122:	40 84 f6             	test   %sil,%sil
  8041602125:	78 e4                	js     804160210b <file_name_by_info+0x3ab>
  return count;
  8041602127:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  804160212a:	45 85 c0             	test   %r8d,%r8d
  804160212d:	0f 84 40 fd ff ff    	je     8041601e73 <file_name_by_info+0x113>
  entry += count;
  8041602133:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041602136:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  804160213a:	4c 03 20             	add    (%rax),%r12
  804160213d:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041602140:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602145:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160214a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602150:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602153:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602157:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160215a:	89 f0                	mov    %esi,%eax
  804160215c:	83 e0 7f             	and    $0x7f,%eax
  804160215f:	d3 e0                	shl    %cl,%eax
  8041602161:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602164:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602167:	40 84 f6             	test   %sil,%sil
  804160216a:	78 e4                	js     8041602150 <file_name_by_info+0x3f0>
  return count;
  804160216c:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  804160216f:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  8041602172:	45 39 c8             	cmp    %r9d,%r8d
  8041602175:	0f 85 2d fd ff ff    	jne    8041601ea8 <file_name_by_info+0x148>
  804160217b:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  804160217e:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602183:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602188:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  804160218e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602191:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602195:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602198:	89 f0                	mov    %esi,%eax
  804160219a:	83 e0 7f             	and    $0x7f,%eax
  804160219d:	d3 e0                	shl    %cl,%eax
  804160219f:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416021a2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416021a5:	40 84 f6             	test   %sil,%sil
  80416021a8:	78 e4                	js     804160218e <file_name_by_info+0x42e>
  return count;
  80416021aa:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  80416021ad:	41 83 f8 11          	cmp    $0x11,%r8d
  80416021b1:	0f 85 26 fd ff ff    	jne    8041601edd <file_name_by_info+0x17d>
  abbrev_entry++;
  80416021b7:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  80416021bc:	49 bf 2b 0d 60 41 80 	movabs $0x8041600d2b,%r15
  80416021c3:	00 00 00 
  80416021c6:	e9 70 fd ff ff       	jmpq   8041601f3b <file_name_by_info+0x1db>

00000080416021cb <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  80416021cb:	55                   	push   %rbp
  80416021cc:	48 89 e5             	mov    %rsp,%rbp
  80416021cf:	41 57                	push   %r15
  80416021d1:	41 56                	push   %r14
  80416021d3:	41 55                	push   %r13
  80416021d5:	41 54                	push   %r12
  80416021d7:	53                   	push   %rbx
  80416021d8:	48 83 ec 68          	sub    $0x68,%rsp
  80416021dc:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  80416021e0:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  80416021e7:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  80416021eb:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  80416021ef:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  80416021f6:	48 89 d3             	mov    %rdx,%rbx
  80416021f9:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  80416021fd:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602202:	48 89 de             	mov    %rbx,%rsi
  8041602205:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602209:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041602210:	00 00 00 
  8041602213:	ff d0                	callq  *%rax
  8041602215:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602218:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160221b:	76 59                	jbe    8041602276 <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  804160221d:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602220:	74 2f                	je     8041602251 <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602222:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  8041602229:	00 00 00 
  804160222c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602231:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041602238:	00 00 00 
  804160223b:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  804160223d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602242:	48 83 c4 68          	add    $0x68,%rsp
  8041602246:	5b                   	pop    %rbx
  8041602247:	41 5c                	pop    %r12
  8041602249:	41 5d                	pop    %r13
  804160224b:	41 5e                	pop    %r14
  804160224d:	41 5f                	pop    %r15
  804160224f:	5d                   	pop    %rbp
  8041602250:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602251:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041602255:	ba 08 00 00 00       	mov    $0x8,%edx
  804160225a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160225e:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041602265:	00 00 00 
  8041602268:	ff d0                	callq  *%rax
  804160226a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160226e:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  8041602274:	eb 08                	jmp    804160227e <function_by_info+0xb3>
    *len = initial_len;
  8041602276:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602278:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  804160227e:	4d 63 f6             	movslq %r14d,%r14
  8041602281:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  8041602284:	48 01 d8             	add    %rbx,%rax
  8041602287:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160228b:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602290:	48 89 de             	mov    %rbx,%rsi
  8041602293:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602297:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160229e:	00 00 00 
  80416022a1:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416022a3:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416022a7:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416022ab:	83 e8 02             	sub    $0x2,%eax
  80416022ae:	66 a9 fd ff          	test   $0xfffd,%ax
  80416022b2:	75 51                	jne    8041602305 <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416022b4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416022b9:	48 89 de             	mov    %rbx,%rsi
  80416022bc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022c0:	49 bc 08 af 60 41 80 	movabs $0x804160af08,%r12
  80416022c7:	00 00 00 
  80416022ca:	41 ff d4             	callq  *%r12
  80416022cd:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  80416022d1:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416022d5:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416022d9:	ba 01 00 00 00       	mov    $0x1,%edx
  80416022de:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022e2:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  80416022e5:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416022e9:	75 4f                	jne    804160233a <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  80416022eb:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416022ef:	4c 03 28             	add    (%rax),%r13
  80416022f2:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  80416022f6:	49 bf 2b 0d 60 41 80 	movabs $0x8041600d2b,%r15
  80416022fd:	00 00 00 
  while (entry < entry_end) {
  8041602300:	e9 07 02 00 00       	jmpq   804160250c <function_by_info+0x341>
  assert(version == 4 || version == 2);
  8041602305:	48 b9 ce b9 60 41 80 	movabs $0x804160b9ce,%rcx
  804160230c:	00 00 00 
  804160230f:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041602316:	00 00 00 
  8041602319:	be e9 01 00 00       	mov    $0x1e9,%esi
  804160231e:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041602325:	00 00 00 
  8041602328:	b8 00 00 00 00       	mov    $0x0,%eax
  804160232d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602334:	00 00 00 
  8041602337:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  804160233a:	48 b9 9b b9 60 41 80 	movabs $0x804160b99b,%rcx
  8041602341:	00 00 00 
  8041602344:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160234b:	00 00 00 
  804160234e:	be ed 01 00 00       	mov    $0x1ed,%esi
  8041602353:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  804160235a:	00 00 00 
  804160235d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602362:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602369:	00 00 00 
  804160236c:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  804160236f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602373:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  8041602377:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  804160237b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  8041602381:	49 39 da             	cmp    %rbx,%r10
  8041602384:	0f 86 e7 00 00 00    	jbe    8041602471 <function_by_info+0x2a6>
  804160238a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160238d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602393:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602398:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  804160239d:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023a0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023a4:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416023a8:	89 f8                	mov    %edi,%eax
  80416023aa:	83 e0 7f             	and    $0x7f,%eax
  80416023ad:	d3 e0                	shl    %cl,%eax
  80416023af:	09 c6                	or     %eax,%esi
    shift += 7;
  80416023b1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023b4:	40 84 ff             	test   %dil,%dil
  80416023b7:	78 e4                	js     804160239d <function_by_info+0x1d2>
  return count;
  80416023b9:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  80416023bc:	4c 01 c3             	add    %r8,%rbx
  80416023bf:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023c2:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  80416023c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023cd:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416023d3:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023d6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023da:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  80416023de:	89 f8                	mov    %edi,%eax
  80416023e0:	83 e0 7f             	and    $0x7f,%eax
  80416023e3:	d3 e0                	shl    %cl,%eax
  80416023e5:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416023e8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023eb:	40 84 ff             	test   %dil,%dil
  80416023ee:	78 e3                	js     80416023d3 <function_by_info+0x208>
  return count;
  80416023f0:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  80416023f3:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  80416023f8:	41 39 f1             	cmp    %esi,%r9d
  80416023fb:	74 74                	je     8041602471 <function_by_info+0x2a6>
  result = 0;
  80416023fd:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602400:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602405:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160240a:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602410:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602413:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602417:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160241a:	89 f0                	mov    %esi,%eax
  804160241c:	83 e0 7f             	and    $0x7f,%eax
  804160241f:	d3 e0                	shl    %cl,%eax
  8041602421:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602424:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602427:	40 84 f6             	test   %sil,%sil
  804160242a:	78 e4                	js     8041602410 <function_by_info+0x245>
  return count;
  804160242c:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160242f:	48 01 fb             	add    %rdi,%rbx
  8041602432:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602435:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160243a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160243f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602445:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602448:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160244c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160244f:	89 f0                	mov    %esi,%eax
  8041602451:	83 e0 7f             	and    $0x7f,%eax
  8041602454:	d3 e0                	shl    %cl,%eax
  8041602456:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602459:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160245c:	40 84 f6             	test   %sil,%sil
  804160245f:	78 e4                	js     8041602445 <function_by_info+0x27a>
  return count;
  8041602461:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602464:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  8041602467:	45 09 dc             	or     %r11d,%r12d
  804160246a:	75 91                	jne    80416023fd <function_by_info+0x232>
  804160246c:	e9 10 ff ff ff       	jmpq   8041602381 <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  8041602471:	41 83 f8 2e          	cmp    $0x2e,%r8d
  8041602475:	0f 84 e9 00 00 00    	je     8041602564 <function_by_info+0x399>
            fn_name_entry = entry;
  804160247b:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160247e:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602483:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602488:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160248e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602491:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602495:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602498:	89 f0                	mov    %esi,%eax
  804160249a:	83 e0 7f             	and    $0x7f,%eax
  804160249d:	d3 e0                	shl    %cl,%eax
  804160249f:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416024a2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024a5:	40 84 f6             	test   %sil,%sil
  80416024a8:	78 e4                	js     804160248e <function_by_info+0x2c3>
  return count;
  80416024aa:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024ad:	48 01 fb             	add    %rdi,%rbx
  80416024b0:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024b3:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024bd:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024c3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024c6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024ca:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024cd:	89 f0                	mov    %esi,%eax
  80416024cf:	83 e0 7f             	and    $0x7f,%eax
  80416024d2:	d3 e0                	shl    %cl,%eax
  80416024d4:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024d7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024da:	40 84 f6             	test   %sil,%sil
  80416024dd:	78 e4                	js     80416024c3 <function_by_info+0x2f8>
  return count;
  80416024df:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024e2:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  80416024e5:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416024eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416024f0:	ba 00 00 00 00       	mov    $0x0,%edx
  80416024f5:	44 89 e6             	mov    %r12d,%esi
  80416024f8:	4c 89 f7             	mov    %r14,%rdi
  80416024fb:	41 ff d7             	callq  *%r15
        entry += count;
  80416024fe:	48 98                	cltq   
  8041602500:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602503:	45 09 ec             	or     %r13d,%r12d
  8041602506:	0f 85 6f ff ff ff    	jne    804160247b <function_by_info+0x2b0>
  while (entry < entry_end) {
  804160250c:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  8041602510:	0f 83 37 02 00 00    	jae    804160274d <function_by_info+0x582>
                 uintptr_t *offset) {
  8041602516:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602519:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160251e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602523:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602529:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160252c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602530:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602533:	89 f0                	mov    %esi,%eax
  8041602535:	83 e0 7f             	and    $0x7f,%eax
  8041602538:	d3 e0                	shl    %cl,%eax
  804160253a:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160253d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602540:	40 84 f6             	test   %sil,%sil
  8041602543:	78 e4                	js     8041602529 <function_by_info+0x35e>
  return count;
  8041602545:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  8041602548:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  804160254b:	45 85 c9             	test   %r9d,%r9d
  804160254e:	0f 85 1b fe ff ff    	jne    804160236f <function_by_info+0x1a4>
  while (entry < entry_end) {
  8041602554:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  8041602558:	77 bc                	ja     8041602516 <function_by_info+0x34b>
  return 0;
  804160255a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160255f:	e9 de fc ff ff       	jmpq   8041602242 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  8041602564:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  804160256b:	00 
  804160256c:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8041602573:	00 
      unsigned name_form        = 0;
  8041602574:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  804160257b:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  8041602582:	00 
  8041602583:	eb 1d                	jmp    80416025a2 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  8041602585:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160258b:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602590:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  8041602594:	44 89 ee             	mov    %r13d,%esi
  8041602597:	4c 89 f7             	mov    %r14,%rdi
  804160259a:	41 ff d7             	callq  *%r15
        entry += count;
  804160259d:	48 98                	cltq   
  804160259f:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  80416025a2:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025a5:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025af:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416025b5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025b8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025bc:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025bf:	89 f0                	mov    %esi,%eax
  80416025c1:	83 e0 7f             	and    $0x7f,%eax
  80416025c4:	d3 e0                	shl    %cl,%eax
  80416025c6:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416025c9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025cc:	40 84 f6             	test   %sil,%sil
  80416025cf:	78 e4                	js     80416025b5 <function_by_info+0x3ea>
  return count;
  80416025d1:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025d4:	48 01 fb             	add    %rdi,%rbx
  80416025d7:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025da:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025df:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025e4:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416025ea:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025ed:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025f1:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025f4:	89 f0                	mov    %esi,%eax
  80416025f6:	83 e0 7f             	and    $0x7f,%eax
  80416025f9:	d3 e0                	shl    %cl,%eax
  80416025fb:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416025fe:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602601:	40 84 f6             	test   %sil,%sil
  8041602604:	78 e4                	js     80416025ea <function_by_info+0x41f>
  return count;
  8041602606:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602609:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  804160260c:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602610:	0f 84 6f ff ff ff    	je     8041602585 <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  8041602616:	41 83 fc 12          	cmp    $0x12,%r12d
  804160261a:	0f 84 99 00 00 00    	je     80416026b9 <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  8041602620:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602624:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  8041602627:	41 0f 44 c5          	cmove  %r13d,%eax
  804160262b:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  804160262e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602632:	49 0f 44 c6          	cmove  %r14,%rax
  8041602636:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  804160263a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602640:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602645:	ba 00 00 00 00       	mov    $0x0,%edx
  804160264a:	44 89 ee             	mov    %r13d,%esi
  804160264d:	4c 89 f7             	mov    %r14,%rdi
  8041602650:	41 ff d7             	callq  *%r15
        entry += count;
  8041602653:	48 98                	cltq   
  8041602655:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602658:	45 09 e5             	or     %r12d,%r13d
  804160265b:	0f 85 41 ff ff ff    	jne    80416025a2 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  8041602661:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602665:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  804160266c:	48 39 d8             	cmp    %rbx,%rax
  804160266f:	0f 87 97 fe ff ff    	ja     804160250c <function_by_info+0x341>
  8041602675:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  8041602679:	0f 82 8d fe ff ff    	jb     804160250c <function_by_info+0x341>
        *offset = low_pc;
  804160267f:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  8041602686:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  8041602689:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  804160268d:	74 59                	je     80416026e8 <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  804160268f:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602695:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  8041602698:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  804160269c:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  804160269f:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  80416026a3:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  80416026aa:	00 00 00 
  80416026ad:	ff d0                	callq  *%rax
        return 0;
  80416026af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026b4:	e9 89 fb ff ff       	jmpq   8041602242 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  80416026b9:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026bf:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416026c4:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416026c8:	44 89 ee             	mov    %r13d,%esi
  80416026cb:	4c 89 f7             	mov    %r14,%rdi
  80416026ce:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  80416026d1:	41 83 fd 01          	cmp    $0x1,%r13d
  80416026d5:	0f 84 c2 fe ff ff    	je     804160259d <function_by_info+0x3d2>
            high_pc += low_pc;
  80416026db:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80416026df:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  80416026e3:	e9 b5 fe ff ff       	jmpq   804160259d <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  80416026e8:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  80416026ef:	00 
          count                    = dwarf_read_abbrev_entry(
  80416026f0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026f6:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416026fb:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  80416026ff:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602704:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602708:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  804160270f:	00 00 00 
  8041602712:	ff d0                	callq  *%rax
          if (buf &&
  8041602714:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  8041602718:	48 85 ff             	test   %rdi,%rdi
  804160271b:	74 92                	je     80416026af <function_by_info+0x4e4>
  804160271d:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  8041602721:	76 8c                	jbe    80416026af <function_by_info+0x4e4>
            put_unaligned(
  8041602723:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602727:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  804160272b:	48 03 43 40          	add    0x40(%rbx),%rax
  804160272f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602733:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602738:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160273c:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041602743:	00 00 00 
  8041602746:	ff d0                	callq  *%rax
  8041602748:	e9 62 ff ff ff       	jmpq   80416026af <function_by_info+0x4e4>
  return 0;
  804160274d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602752:	e9 eb fa ff ff       	jmpq   8041602242 <function_by_info+0x77>

0000008041602757 <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  8041602757:	55                   	push   %rbp
  8041602758:	48 89 e5             	mov    %rsp,%rbp
  804160275b:	41 57                	push   %r15
  804160275d:	41 56                	push   %r14
  804160275f:	41 55                	push   %r13
  8041602761:	41 54                	push   %r12
  8041602763:	53                   	push   %rbx
  8041602764:	48 83 ec 48          	sub    $0x48,%rsp
  8041602768:	49 89 ff             	mov    %rdi,%r15
  804160276b:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  804160276f:	48 89 f7             	mov    %rsi,%rdi
  8041602772:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  8041602776:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const int flen = strlen(fname);
  804160277a:	48 b8 8f ac 60 41 80 	movabs $0x804160ac8f,%rax
  8041602781:	00 00 00 
  8041602784:	ff d0                	callq  *%rax
  8041602786:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  8041602788:	85 c0                	test   %eax,%eax
  804160278a:	74 62                	je     80416027ee <address_by_fname+0x97>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  804160278c:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  8041602790:	49 be 08 af 60 41 80 	movabs $0x804160af08,%r14
  8041602797:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  804160279a:	49 bf 9e ad 60 41 80 	movabs $0x804160ad9e,%r15
  80416027a1:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  80416027a4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416027a8:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  80416027ac:	0f 86 0b 04 00 00    	jbe    8041602bbd <address_by_fname+0x466>
  80416027b2:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027b7:	4c 89 e6             	mov    %r12,%rsi
  80416027ba:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027be:	41 ff d6             	callq  *%r14
  80416027c1:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416027c4:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416027c7:	76 52                	jbe    804160281b <address_by_fname+0xc4>
    if (initial_len == DW_EXT_DWARF64) {
  80416027c9:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416027cc:	74 31                	je     80416027ff <address_by_fname+0xa8>
      cprintf("Unknown DWARF extension\n");
  80416027ce:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  80416027d5:	00 00 00 
  80416027d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416027dd:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416027e4:	00 00 00 
  80416027e7:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  80416027e9:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  80416027ee:	89 d8                	mov    %ebx,%eax
  80416027f0:	48 83 c4 48          	add    $0x48,%rsp
  80416027f4:	5b                   	pop    %rbx
  80416027f5:	41 5c                	pop    %r12
  80416027f7:	41 5d                	pop    %r13
  80416027f9:	41 5e                	pop    %r14
  80416027fb:	41 5f                	pop    %r15
  80416027fd:	5d                   	pop    %rbp
  80416027fe:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416027ff:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041602804:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602809:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160280d:	41 ff d6             	callq  *%r14
  8041602810:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602814:	ba 0c 00 00 00       	mov    $0xc,%edx
  8041602819:	eb 07                	jmp    8041602822 <address_by_fname+0xcb>
    *len = initial_len;
  804160281b:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160281d:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  8041602822:	48 63 d2             	movslq %edx,%rdx
  8041602825:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  8041602828:	4c 01 e0             	add    %r12,%rax
  804160282b:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  804160282f:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602834:	4c 89 e6             	mov    %r12,%rsi
  8041602837:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160283b:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  804160283e:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  8041602843:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041602848:	0f 85 be 00 00 00    	jne    804160290c <address_by_fname+0x1b5>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160284e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602853:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602857:	41 ff d6             	callq  *%r14
  804160285a:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160285d:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  8041602860:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602865:	ba 04 00 00 00       	mov    $0x4,%edx
  804160286a:	48 89 de             	mov    %rbx,%rsi
  804160286d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602871:	41 ff d6             	callq  *%r14
  8041602874:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  8041602877:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160287c:	83 fa ef             	cmp    $0xffffffef,%edx
  804160287f:	76 29                	jbe    80416028aa <address_by_fname+0x153>
    if (initial_len == DW_EXT_DWARF64) {
  8041602881:	83 fa ff             	cmp    $0xffffffff,%edx
  8041602884:	0f 84 b7 00 00 00    	je     8041602941 <address_by_fname+0x1ea>
      cprintf("Unknown DWARF extension\n");
  804160288a:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  8041602891:	00 00 00 
  8041602894:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602899:	48 b9 9c 8a 60 41 80 	movabs $0x8041608a9c,%rcx
  80416028a0:	00 00 00 
  80416028a3:	ff d1                	callq  *%rcx
      count = 0;
  80416028a5:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  80416028aa:	48 98                	cltq   
  80416028ac:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416028b0:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416028b4:	0f 86 ea fe ff ff    	jbe    80416027a4 <address_by_fname+0x4d>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028ba:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028bf:	4c 89 e6             	mov    %r12,%rsi
  80416028c2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028c6:	41 ff d6             	callq  *%r14
  80416028c9:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416028cd:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416028d1:	4d 85 ed             	test   %r13,%r13
  80416028d4:	0f 84 ca fe ff ff    	je     80416027a4 <address_by_fname+0x4d>
      if (!strcmp(fname, pubnames_entry)) {
  80416028da:	4c 89 e6             	mov    %r12,%rsi
  80416028dd:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416028e1:	41 ff d7             	callq  *%r15
  80416028e4:	89 c3                	mov    %eax,%ebx
  80416028e6:	85 c0                	test   %eax,%eax
  80416028e8:	74 72                	je     804160295c <address_by_fname+0x205>
      pubnames_entry += strlen(pubnames_entry) + 1;
  80416028ea:	4c 89 e7             	mov    %r12,%rdi
  80416028ed:	48 b8 8f ac 60 41 80 	movabs $0x804160ac8f,%rax
  80416028f4:	00 00 00 
  80416028f7:	ff d0                	callq  *%rax
  80416028f9:	83 c0 01             	add    $0x1,%eax
  80416028fc:	48 98                	cltq   
  80416028fe:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602901:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041602905:	77 b3                	ja     80416028ba <address_by_fname+0x163>
  8041602907:	e9 98 fe ff ff       	jmpq   80416027a4 <address_by_fname+0x4d>
    assert(version == 2);
  804160290c:	48 b9 de b9 60 41 80 	movabs $0x804160b9de,%rcx
  8041602913:	00 00 00 
  8041602916:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160291d:	00 00 00 
  8041602920:	be 76 02 00 00       	mov    $0x276,%esi
  8041602925:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  804160292c:	00 00 00 
  804160292f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602934:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160293b:	00 00 00 
  804160293e:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602941:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  8041602946:	ba 08 00 00 00       	mov    $0x8,%edx
  804160294b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160294f:	41 ff d6             	callq  *%r14
      count = 12;
  8041602952:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602957:	e9 4e ff ff ff       	jmpq   80416028aa <address_by_fname+0x153>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160295c:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  8041602960:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602964:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  8041602968:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  804160296c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602971:	4c 89 e6             	mov    %r12,%rsi
  8041602974:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602978:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160297f:	00 00 00 
  8041602982:	ff d0                	callq  *%rax
  8041602984:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602987:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160298a:	0f 86 37 02 00 00    	jbe    8041602bc7 <address_by_fname+0x470>
    if (initial_len == DW_EXT_DWARF64) {
  8041602990:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602993:	74 25                	je     80416029ba <address_by_fname+0x263>
      cprintf("Unknown DWARF extension\n");
  8041602995:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  804160299c:	00 00 00 
  804160299f:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029a4:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416029ab:	00 00 00 
  80416029ae:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416029b0:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416029b5:	e9 34 fe ff ff       	jmpq   80416027ee <address_by_fname+0x97>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029ba:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416029bf:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029c4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029c8:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416029cf:	00 00 00 
  80416029d2:	ff d0                	callq  *%rax
      count = 12;
  80416029d4:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416029d9:	e9 ee 01 00 00       	jmpq   8041602bcc <address_by_fname+0x475>
        assert(version == 4 || version == 2);
  80416029de:	48 b9 ce b9 60 41 80 	movabs $0x804160b9ce,%rcx
  80416029e5:	00 00 00 
  80416029e8:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416029ef:	00 00 00 
  80416029f2:	be 8c 02 00 00       	mov    $0x28c,%esi
  80416029f7:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  80416029fe:	00 00 00 
  8041602a01:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a06:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a0d:	00 00 00 
  8041602a10:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a13:	48 b9 9b b9 60 41 80 	movabs $0x804160b99b,%rcx
  8041602a1a:	00 00 00 
  8041602a1d:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041602a24:	00 00 00 
  8041602a27:	be 91 02 00 00       	mov    $0x291,%esi
  8041602a2c:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041602a33:	00 00 00 
  8041602a36:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a3b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a42:	00 00 00 
  8041602a45:	41 ff d0             	callq  *%r8
        if (tag == DW_TAG_subprogram) {
  8041602a48:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602a4c:	0f 84 93 00 00 00    	je     8041602ae5 <address_by_fname+0x38e>
  count  = 0;
  8041602a52:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a54:	89 d9                	mov    %ebx,%ecx
  8041602a56:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a59:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602a5f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602a62:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a66:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602a69:	89 f0                	mov    %esi,%eax
  8041602a6b:	83 e0 7f             	and    $0x7f,%eax
  8041602a6e:	d3 e0                	shl    %cl,%eax
  8041602a70:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602a73:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a76:	40 84 f6             	test   %sil,%sil
  8041602a79:	78 e4                	js     8041602a5f <address_by_fname+0x308>
  return count;
  8041602a7b:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602a7e:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602a81:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a83:	89 d9                	mov    %ebx,%ecx
  8041602a85:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a88:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602a8e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602a91:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a95:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602a98:	89 f0                	mov    %esi,%eax
  8041602a9a:	83 e0 7f             	and    $0x7f,%eax
  8041602a9d:	d3 e0                	shl    %cl,%eax
  8041602a9f:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602aa2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602aa5:	40 84 f6             	test   %sil,%sil
  8041602aa8:	78 e4                	js     8041602a8e <address_by_fname+0x337>
  return count;
  8041602aaa:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602aad:	49 01 fc             	add    %rdi,%r12
            count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602ab0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602ab6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602abb:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602ac0:	44 89 ee             	mov    %r13d,%esi
  8041602ac3:	4c 89 ff             	mov    %r15,%rdi
  8041602ac6:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  8041602acd:	00 00 00 
  8041602ad0:	ff d0                	callq  *%rax
            entry += count;
  8041602ad2:	48 98                	cltq   
  8041602ad4:	49 01 c7             	add    %rax,%r15
          } while (name != 0 || form != 0);
  8041602ad7:	45 09 f5             	or     %r14d,%r13d
  8041602ada:	0f 85 72 ff ff ff    	jne    8041602a52 <address_by_fname+0x2fb>
  8041602ae0:	e9 09 fd ff ff       	jmpq   80416027ee <address_by_fname+0x97>
          uintptr_t low_pc = 0;
  8041602ae5:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602aec:	00 
  8041602aed:	eb 26                	jmp    8041602b15 <address_by_fname+0x3be>
              count = dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  8041602aef:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602af5:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602afa:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602afe:	44 89 f6             	mov    %r14d,%esi
  8041602b01:	4c 89 ff             	mov    %r15,%rdi
  8041602b04:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  8041602b0b:	00 00 00 
  8041602b0e:	ff d0                	callq  *%rax
            entry += count;
  8041602b10:	48 98                	cltq   
  8041602b12:	49 01 c7             	add    %rax,%r15
  count  = 0;
  8041602b15:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b17:	89 d9                	mov    %ebx,%ecx
  8041602b19:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b1c:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602b22:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b25:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b29:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b2c:	89 f0                	mov    %esi,%eax
  8041602b2e:	83 e0 7f             	and    $0x7f,%eax
  8041602b31:	d3 e0                	shl    %cl,%eax
  8041602b33:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602b36:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b39:	40 84 f6             	test   %sil,%sil
  8041602b3c:	78 e4                	js     8041602b22 <address_by_fname+0x3cb>
  return count;
  8041602b3e:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b41:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602b44:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b46:	89 d9                	mov    %ebx,%ecx
  8041602b48:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b4b:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602b51:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b54:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b58:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b5b:	89 f0                	mov    %esi,%eax
  8041602b5d:	83 e0 7f             	and    $0x7f,%eax
  8041602b60:	d3 e0                	shl    %cl,%eax
  8041602b62:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602b65:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b68:	40 84 f6             	test   %sil,%sil
  8041602b6b:	78 e4                	js     8041602b51 <address_by_fname+0x3fa>
  return count;
  8041602b6d:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b70:	49 01 fc             	add    %rdi,%r12
            if (name == DW_AT_low_pc) {
  8041602b73:	41 83 fd 11          	cmp    $0x11,%r13d
  8041602b77:	0f 84 72 ff ff ff    	je     8041602aef <address_by_fname+0x398>
              count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602b7d:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b83:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602b88:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602b8d:	44 89 f6             	mov    %r14d,%esi
  8041602b90:	4c 89 ff             	mov    %r15,%rdi
  8041602b93:	48 b8 2b 0d 60 41 80 	movabs $0x8041600d2b,%rax
  8041602b9a:	00 00 00 
  8041602b9d:	ff d0                	callq  *%rax
            entry += count;
  8041602b9f:	48 98                	cltq   
  8041602ba1:	49 01 c7             	add    %rax,%r15
          } while (name || form);
  8041602ba4:	45 09 ee             	or     %r13d,%r14d
  8041602ba7:	0f 85 68 ff ff ff    	jne    8041602b15 <address_by_fname+0x3be>
          *offset = low_pc;
  8041602bad:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041602bb1:	48 8b 7d 98          	mov    -0x68(%rbp),%rdi
  8041602bb5:	48 89 07             	mov    %rax,(%rdi)
  8041602bb8:	e9 31 fc ff ff       	jmpq   80416027ee <address_by_fname+0x97>
  return 0;
  8041602bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602bc2:	e9 27 fc ff ff       	jmpq   80416027ee <address_by_fname+0x97>
  count       = 4;
  8041602bc7:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  8041602bcc:	48 98                	cltq   
  8041602bce:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602bd2:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602bd7:	4c 89 ee             	mov    %r13,%rsi
  8041602bda:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bde:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041602be5:	00 00 00 
  8041602be8:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602bea:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  8041602bee:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602bf2:	83 e8 02             	sub    $0x2,%eax
  8041602bf5:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602bf9:	0f 85 df fd ff ff    	jne    80416029de <address_by_fname+0x287>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602bff:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602c04:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c08:	49 be 08 af 60 41 80 	movabs $0x804160af08,%r14
  8041602c0f:	00 00 00 
  8041602c12:	41 ff d6             	callq  *%r14
  8041602c15:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602c19:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c1d:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  8041602c20:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602c24:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602c29:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c2d:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  8041602c30:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602c34:	0f 85 d9 fd ff ff    	jne    8041602a13 <address_by_fname+0x2bc>
  count  = 0;
  8041602c3a:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602c3c:	89 d9                	mov    %ebx,%ecx
  8041602c3e:	4c 89 fa             	mov    %r15,%rdx
  result = 0;
  8041602c41:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602c47:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602c4a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c4e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602c51:	89 f0                	mov    %esi,%eax
  8041602c53:	83 e0 7f             	and    $0x7f,%eax
  8041602c56:	d3 e0                	shl    %cl,%eax
  8041602c58:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602c5b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c5e:	40 84 f6             	test   %sil,%sil
  8041602c61:	78 e4                	js     8041602c47 <address_by_fname+0x4f0>
  return count;
  8041602c63:	48 63 ff             	movslq %edi,%rdi
        entry += count;
  8041602c66:	49 01 ff             	add    %rdi,%r15
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c69:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c6d:	4c 8b 58 08          	mov    0x8(%rax),%r11
        unsigned name = 0, form = 0, tag = 0;
  8041602c71:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c77:	4d 39 e3             	cmp    %r12,%r11
  8041602c7a:	0f 86 c8 fd ff ff    	jbe    8041602a48 <address_by_fname+0x2f1>
  count  = 0;
  8041602c80:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602c83:	89 d9                	mov    %ebx,%ecx
  8041602c85:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602c88:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602c8d:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602c90:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c94:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602c98:	89 f8                	mov    %edi,%eax
  8041602c9a:	83 e0 7f             	and    $0x7f,%eax
  8041602c9d:	d3 e0                	shl    %cl,%eax
  8041602c9f:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602ca1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ca4:	40 84 ff             	test   %dil,%dil
  8041602ca7:	78 e4                	js     8041602c8d <address_by_fname+0x536>
  return count;
  8041602ca9:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry += count;
  8041602cac:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602caf:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602cb2:	89 d9                	mov    %ebx,%ecx
  8041602cb4:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602cb7:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602cbd:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602cc0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cc4:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cc8:	89 f8                	mov    %edi,%eax
  8041602cca:	83 e0 7f             	and    $0x7f,%eax
  8041602ccd:	d3 e0                	shl    %cl,%eax
  8041602ccf:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602cd2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cd5:	40 84 ff             	test   %dil,%dil
  8041602cd8:	78 e3                	js     8041602cbd <address_by_fname+0x566>
  return count;
  8041602cda:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry++;
  8041602cdd:	4f 8d 64 04 01       	lea    0x1(%r12,%r8,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602ce2:	41 39 f2             	cmp    %esi,%r10d
  8041602ce5:	0f 84 5d fd ff ff    	je     8041602a48 <address_by_fname+0x2f1>
  count  = 0;
  8041602ceb:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602cee:	89 d9                	mov    %ebx,%ecx
  8041602cf0:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602cf3:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602cf8:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602cfb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cff:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602d03:	89 f0                	mov    %esi,%eax
  8041602d05:	83 e0 7f             	and    $0x7f,%eax
  8041602d08:	d3 e0                	shl    %cl,%eax
  8041602d0a:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602d0c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d0f:	40 84 f6             	test   %sil,%sil
  8041602d12:	78 e4                	js     8041602cf8 <address_by_fname+0x5a1>
  return count;
  8041602d14:	4d 63 c0             	movslq %r8d,%r8
            abbrev_entry += count;
  8041602d17:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602d1a:	41 89 dd             	mov    %ebx,%r13d
  shift  = 0;
  8041602d1d:	89 d9                	mov    %ebx,%ecx
  8041602d1f:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d22:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d28:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d2b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d2f:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041602d33:	89 f0                	mov    %esi,%eax
  8041602d35:	83 e0 7f             	and    $0x7f,%eax
  8041602d38:	d3 e0                	shl    %cl,%eax
  8041602d3a:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602d3d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d40:	40 84 f6             	test   %sil,%sil
  8041602d43:	78 e3                	js     8041602d28 <address_by_fname+0x5d1>
  return count;
  8041602d45:	4d 63 ed             	movslq %r13d,%r13
            abbrev_entry += count;
  8041602d48:	4d 01 ec             	add    %r13,%r12
          } while (name != 0 || form != 0);
  8041602d4b:	41 09 f8             	or     %edi,%r8d
  8041602d4e:	75 9b                	jne    8041602ceb <address_by_fname+0x594>
  8041602d50:	e9 22 ff ff ff       	jmpq   8041602c77 <address_by_fname+0x520>

0000008041602d55 <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602d55:	55                   	push   %rbp
  8041602d56:	48 89 e5             	mov    %rsp,%rbp
  8041602d59:	41 57                	push   %r15
  8041602d5b:	41 56                	push   %r14
  8041602d5d:	41 55                	push   %r13
  8041602d5f:	41 54                	push   %r12
  8041602d61:	53                   	push   %rbx
  8041602d62:	48 83 ec 48          	sub    $0x48,%rsp
  8041602d66:	48 89 fb             	mov    %rdi,%rbx
  8041602d69:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602d6d:	48 89 f7             	mov    %rsi,%rdi
  8041602d70:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602d74:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602d78:	48 b8 8f ac 60 41 80 	movabs $0x804160ac8f,%rax
  8041602d7f:	00 00 00 
  8041602d82:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602d84:	85 c0                	test   %eax,%eax
  8041602d86:	0f 84 73 03 00 00    	je     80416030ff <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602d8c:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602d90:	e9 0f 03 00 00       	jmpq   80416030a4 <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602d95:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602d99:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602d9e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602da2:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041602da9:	00 00 00 
  8041602dac:	ff d0                	callq  *%rax
  8041602dae:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602db2:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602db7:	eb 07                	jmp    8041602dc0 <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602db9:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602dbb:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602dc0:	48 63 db             	movslq %ebx,%rbx
  8041602dc3:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602dc7:	4c 01 e8             	add    %r13,%rax
  8041602dca:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602dce:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602dd3:	4c 89 ee             	mov    %r13,%rsi
  8041602dd6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602dda:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041602de1:	00 00 00 
  8041602de4:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602de6:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602dea:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602dee:	83 e8 02             	sub    $0x2,%eax
  8041602df1:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602df5:	75 52                	jne    8041602e49 <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602df7:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602dfc:	4c 89 ee             	mov    %r13,%rsi
  8041602dff:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e03:	49 be 08 af 60 41 80 	movabs $0x804160af08,%r14
  8041602e0a:	00 00 00 
  8041602e0d:	41 ff d6             	callq  *%r14
  8041602e10:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602e14:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602e19:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602e1d:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602e22:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e26:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602e29:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602e2d:	75 4f                	jne    8041602e7e <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602e2f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e33:	4c 03 20             	add    (%rax),%r12
  8041602e36:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602e3a:	49 be 2b 0d 60 41 80 	movabs $0x8041600d2b,%r14
  8041602e41:	00 00 00 
    while (entry < entry_end) {
  8041602e44:	e9 11 02 00 00       	jmpq   804160305a <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602e49:	48 b9 ce b9 60 41 80 	movabs $0x804160b9ce,%rcx
  8041602e50:	00 00 00 
  8041602e53:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041602e5a:	00 00 00 
  8041602e5d:	be f0 02 00 00       	mov    $0x2f0,%esi
  8041602e62:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041602e69:	00 00 00 
  8041602e6c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e71:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602e78:	00 00 00 
  8041602e7b:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602e7e:	48 b9 9b b9 60 41 80 	movabs $0x804160b99b,%rcx
  8041602e85:	00 00 00 
  8041602e88:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041602e8f:	00 00 00 
  8041602e92:	be f4 02 00 00       	mov    $0x2f4,%esi
  8041602e97:	48 bf 8e b9 60 41 80 	movabs $0x804160b98e,%rdi
  8041602e9e:	00 00 00 
  8041602ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ea6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602ead:	00 00 00 
  8041602eb0:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602eb3:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602eb7:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602ebb:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602ebf:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602ec5:	49 39 db             	cmp    %rbx,%r11
  8041602ec8:	0f 86 e7 00 00 00    	jbe    8041602fb5 <naive_address_by_fname+0x260>
  8041602ece:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ed1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602ed7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602edc:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602ee1:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602ee4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ee8:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602eec:	89 f8                	mov    %edi,%eax
  8041602eee:	83 e0 7f             	and    $0x7f,%eax
  8041602ef1:	d3 e0                	shl    %cl,%eax
  8041602ef3:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602ef5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ef8:	40 84 ff             	test   %dil,%dil
  8041602efb:	78 e4                	js     8041602ee1 <naive_address_by_fname+0x18c>
  return count;
  8041602efd:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602f00:	4c 01 c3             	add    %r8,%rbx
  8041602f03:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f06:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602f0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f11:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602f17:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f1a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f1e:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f22:	89 f8                	mov    %edi,%eax
  8041602f24:	83 e0 7f             	and    $0x7f,%eax
  8041602f27:	d3 e0                	shl    %cl,%eax
  8041602f29:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602f2c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f2f:	40 84 ff             	test   %dil,%dil
  8041602f32:	78 e3                	js     8041602f17 <naive_address_by_fname+0x1c2>
  return count;
  8041602f34:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602f37:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602f3c:	41 39 f2             	cmp    %esi,%r10d
  8041602f3f:	74 74                	je     8041602fb5 <naive_address_by_fname+0x260>
  result = 0;
  8041602f41:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f44:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f49:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f4e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602f54:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f57:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f5b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f5e:	89 f0                	mov    %esi,%eax
  8041602f60:	83 e0 7f             	and    $0x7f,%eax
  8041602f63:	d3 e0                	shl    %cl,%eax
  8041602f65:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602f68:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f6b:	40 84 f6             	test   %sil,%sil
  8041602f6e:	78 e4                	js     8041602f54 <naive_address_by_fname+0x1ff>
  return count;
  8041602f70:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f73:	48 01 fb             	add    %rdi,%rbx
  8041602f76:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f79:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f83:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602f89:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f8c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f90:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f93:	89 f0                	mov    %esi,%eax
  8041602f95:	83 e0 7f             	and    $0x7f,%eax
  8041602f98:	d3 e0                	shl    %cl,%eax
  8041602f9a:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602f9d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602fa0:	40 84 f6             	test   %sil,%sil
  8041602fa3:	78 e4                	js     8041602f89 <naive_address_by_fname+0x234>
  return count;
  8041602fa5:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fa8:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  8041602fab:	45 09 c4             	or     %r8d,%r12d
  8041602fae:	75 91                	jne    8041602f41 <naive_address_by_fname+0x1ec>
  8041602fb0:	e9 10 ff ff ff       	jmpq   8041602ec5 <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602fb5:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602fb9:	0f 84 4f 01 00 00    	je     804160310e <naive_address_by_fname+0x3b9>
  8041602fbf:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602fc3:	0f 84 45 01 00 00    	je     804160310e <naive_address_by_fname+0x3b9>
                found = 1;
  8041602fc9:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fcc:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fd6:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602fdc:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fdf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602fe3:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602fe6:	89 f0                	mov    %esi,%eax
  8041602fe8:	83 e0 7f             	and    $0x7f,%eax
  8041602feb:	d3 e0                	shl    %cl,%eax
  8041602fed:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602ff0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ff3:	40 84 f6             	test   %sil,%sil
  8041602ff6:	78 e4                	js     8041602fdc <naive_address_by_fname+0x287>
  return count;
  8041602ff8:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  8041602ffb:	48 01 fb             	add    %rdi,%rbx
  8041602ffe:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603001:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603006:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160300b:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603011:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603014:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603018:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160301b:	89 f0                	mov    %esi,%eax
  804160301d:	83 e0 7f             	and    $0x7f,%eax
  8041603020:	d3 e0                	shl    %cl,%eax
  8041603022:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041603025:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603028:	40 84 f6             	test   %sil,%sil
  804160302b:	78 e4                	js     8041603011 <naive_address_by_fname+0x2bc>
  return count;
  804160302d:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  8041603030:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041603033:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603039:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160303e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603043:	44 89 e6             	mov    %r12d,%esi
  8041603046:	4c 89 ff             	mov    %r15,%rdi
  8041603049:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  804160304c:	48 98                	cltq   
  804160304e:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603051:	45 09 ec             	or     %r13d,%r12d
  8041603054:	0f 85 6f ff ff ff    	jne    8041602fc9 <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  804160305a:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  804160305e:	73 44                	jae    80416030a4 <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  8041603060:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  8041603063:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603068:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160306d:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041603073:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603076:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160307a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160307d:	89 f0                	mov    %esi,%eax
  804160307f:	83 e0 7f             	and    $0x7f,%eax
  8041603082:	d3 e0                	shl    %cl,%eax
  8041603084:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041603087:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160308a:	40 84 f6             	test   %sil,%sil
  804160308d:	78 e4                	js     8041603073 <naive_address_by_fname+0x31e>
  return count;
  804160308f:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  8041603092:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  8041603095:	45 85 d2             	test   %r10d,%r10d
  8041603098:	0f 85 15 fe ff ff    	jne    8041602eb3 <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  804160309e:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  80416030a2:	77 bc                	ja     8041603060 <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  80416030a4:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416030a8:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  80416030ac:	0f 86 ee 01 00 00    	jbe    80416032a0 <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  80416030b2:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030b7:	4c 89 fe             	mov    %r15,%rsi
  80416030ba:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030be:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416030c5:	00 00 00 
  80416030c8:	ff d0                	callq  *%rax
  80416030ca:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416030cd:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416030d0:	0f 86 e3 fc ff ff    	jbe    8041602db9 <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  80416030d6:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416030d9:	0f 84 b6 fc ff ff    	je     8041602d95 <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  80416030df:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  80416030e6:	00 00 00 
  80416030e9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416030ee:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416030f5:	00 00 00 
  80416030f8:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  80416030fa:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  80416030ff:	48 83 c4 48          	add    $0x48,%rsp
  8041603103:	5b                   	pop    %rbx
  8041603104:	41 5c                	pop    %r12
  8041603106:	41 5d                	pop    %r13
  8041603108:	41 5e                	pop    %r14
  804160310a:	41 5f                	pop    %r15
  804160310c:	5d                   	pop    %rbp
  804160310d:	c3                   	retq   
        uintptr_t low_pc = 0;
  804160310e:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041603115:	00 
        int found        = 0;
  8041603116:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  804160311d:	eb 21                	jmp    8041603140 <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  804160311f:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603125:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160312a:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160312e:	44 89 ee             	mov    %r13d,%esi
  8041603131:	4c 89 ff             	mov    %r15,%rdi
  8041603134:	41 ff d6             	callq  *%r14
  8041603137:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  804160313a:	49 63 c4             	movslq %r12d,%rax
  804160313d:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  8041603140:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603143:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603148:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160314d:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603153:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603156:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160315a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160315d:	89 f0                	mov    %esi,%eax
  804160315f:	83 e0 7f             	and    $0x7f,%eax
  8041603162:	d3 e0                	shl    %cl,%eax
  8041603164:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041603167:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160316a:	40 84 f6             	test   %sil,%sil
  804160316d:	78 e4                	js     8041603153 <naive_address_by_fname+0x3fe>
  return count;
  804160316f:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041603172:	48 01 fb             	add    %rdi,%rbx
  8041603175:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603178:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160317d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603182:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041603188:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160318b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160318f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603192:	89 f0                	mov    %esi,%eax
  8041603194:	83 e0 7f             	and    $0x7f,%eax
  8041603197:	d3 e0                	shl    %cl,%eax
  8041603199:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  804160319c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160319f:	40 84 f6             	test   %sil,%sil
  80416031a2:	78 e4                	js     8041603188 <naive_address_by_fname+0x433>
  return count;
  80416031a4:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  80416031a7:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  80416031aa:	41 83 fc 11          	cmp    $0x11,%r12d
  80416031ae:	0f 84 6b ff ff ff    	je     804160311f <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  80416031b4:	41 83 fc 03          	cmp    $0x3,%r12d
  80416031b8:	0f 85 9c 00 00 00    	jne    804160325a <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  80416031be:	41 83 fd 0e          	cmp    $0xe,%r13d
  80416031c2:	74 42                	je     8041603206 <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  80416031c4:	4c 89 fe             	mov    %r15,%rsi
  80416031c7:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416031cb:	48 b8 9e ad 60 41 80 	movabs $0x804160ad9e,%rax
  80416031d2:	00 00 00 
  80416031d5:	ff d0                	callq  *%rax
                found = 1;
  80416031d7:	85 c0                	test   %eax,%eax
  80416031d9:	b8 01 00 00 00       	mov    $0x1,%eax
  80416031de:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  80416031e2:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  80416031e5:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416031eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416031f0:	ba 00 00 00 00       	mov    $0x0,%edx
  80416031f5:	44 89 ee             	mov    %r13d,%esi
  80416031f8:	4c 89 ff             	mov    %r15,%rdi
  80416031fb:	41 ff d6             	callq  *%r14
  80416031fe:	41 89 c4             	mov    %eax,%r12d
  8041603201:	e9 34 ff ff ff       	jmpq   804160313a <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  8041603206:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160320d:	00 
              count          = dwarf_read_abbrev_entry(
  804160320e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603214:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603219:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160321d:	be 0e 00 00 00       	mov    $0xe,%esi
  8041603222:	4c 89 ff             	mov    %r15,%rdi
  8041603225:	41 ff d6             	callq  *%r14
  8041603228:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  804160322b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160322f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603233:	48 03 70 40          	add    0x40(%rax),%rsi
  8041603237:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  804160323b:	48 b8 9e ad 60 41 80 	movabs $0x804160ad9e,%rax
  8041603242:	00 00 00 
  8041603245:	ff d0                	callq  *%rax
                found = 1;
  8041603247:	85 c0                	test   %eax,%eax
  8041603249:	b8 01 00 00 00       	mov    $0x1,%eax
  804160324e:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603252:	89 45 bc             	mov    %eax,-0x44(%rbp)
  8041603255:	e9 e0 fe ff ff       	jmpq   804160313a <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  804160325a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603260:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603265:	ba 00 00 00 00       	mov    $0x0,%edx
  804160326a:	44 89 ee             	mov    %r13d,%esi
  804160326d:	4c 89 ff             	mov    %r15,%rdi
  8041603270:	41 ff d6             	callq  *%r14
          entry += count;
  8041603273:	48 98                	cltq   
  8041603275:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603278:	45 09 e5             	or     %r12d,%r13d
  804160327b:	0f 85 bf fe ff ff    	jne    8041603140 <naive_address_by_fname+0x3eb>
        if (found) {
  8041603281:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  8041603285:	0f 84 cf fd ff ff    	je     804160305a <naive_address_by_fname+0x305>
          *offset = low_pc;
  804160328b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160328f:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  8041603293:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  8041603296:	b8 00 00 00 00       	mov    $0x0,%eax
  804160329b:	e9 5f fe ff ff       	jmpq   80416030ff <naive_address_by_fname+0x3aa>
  return 0;
  80416032a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032a5:	e9 55 fe ff ff       	jmpq   80416030ff <naive_address_by_fname+0x3aa>

00000080416032aa <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  80416032aa:	55                   	push   %rbp
  80416032ab:	48 89 e5             	mov    %rsp,%rbp
  80416032ae:	41 57                	push   %r15
  80416032b0:	41 56                	push   %r14
  80416032b2:	41 55                	push   %r13
  80416032b4:	41 54                	push   %r12
  80416032b6:	53                   	push   %rbx
  80416032b7:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  80416032bb:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  80416032bf:	48 8b 47 38          	mov    0x38(%rdi),%rax
  80416032c3:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  80416032c6:	48 39 d0             	cmp    %rdx,%rax
  80416032c9:	0f 82 d9 06 00 00    	jb     80416039a8 <line_for_address+0x6fe>
  80416032cf:	48 85 c9             	test   %rcx,%rcx
  80416032d2:	0f 84 d0 06 00 00    	je     80416039a8 <line_for_address+0x6fe>
  80416032d8:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  80416032dc:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  80416032e0:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  80416032e3:	ba 04 00 00 00       	mov    $0x4,%edx
  80416032e8:	48 89 de             	mov    %rbx,%rsi
  80416032eb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416032ef:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416032f6:	00 00 00 
  80416032f9:	ff d0                	callq  *%rax
  80416032fb:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416032fe:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041603301:	76 4e                	jbe    8041603351 <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  8041603303:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041603306:	74 25                	je     804160332d <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  8041603308:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  804160330f:	00 00 00 
  8041603312:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603317:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160331e:	00 00 00 
  8041603321:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041603323:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041603328:	e9 6c 06 00 00       	jmpq   8041603999 <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160332d:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041603331:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603336:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160333a:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041603341:	00 00 00 
  8041603344:	ff d0                	callq  *%rax
  8041603346:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160334a:	be 0c 00 00 00       	mov    $0xc,%esi
  804160334f:	eb 07                	jmp    8041603358 <line_for_address+0xae>
    *len = initial_len;
  8041603351:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041603353:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  8041603358:	48 63 f6             	movslq %esi,%rsi
  804160335b:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  804160335e:	48 01 d8             	add    %rbx,%rax
  8041603361:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  8041603365:	ba 02 00 00 00       	mov    $0x2,%edx
  804160336a:	48 89 de             	mov    %rbx,%rsi
  804160336d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603371:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041603378:	00 00 00 
  804160337b:	ff d0                	callq  *%rax
  804160337d:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  8041603382:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  8041603386:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  804160338a:	66 83 f8 02          	cmp    $0x2,%ax
  804160338e:	77 51                	ja     80416033e1 <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  8041603390:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603395:	4c 89 e6             	mov    %r12,%rsi
  8041603398:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160339c:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416033a3:	00 00 00 
  80416033a6:	ff d0                	callq  *%rax
  80416033a8:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416033ac:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  80416033b0:	0f 86 84 00 00 00    	jbe    804160343a <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  80416033b6:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  80416033ba:	74 5a                	je     8041603416 <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  80416033bc:	48 bf 60 b9 60 41 80 	movabs $0x804160b960,%rdi
  80416033c3:	00 00 00 
  80416033c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033cb:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416033d2:	00 00 00 
  80416033d5:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416033d7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416033dc:	e9 b8 05 00 00       	jmpq   8041603999 <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  80416033e1:	48 b9 88 bb 60 41 80 	movabs $0x804160bb88,%rcx
  80416033e8:	00 00 00 
  80416033eb:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416033f2:	00 00 00 
  80416033f5:	be fc 00 00 00       	mov    $0xfc,%esi
  80416033fa:	48 bf 41 bb 60 41 80 	movabs $0x804160bb41,%rdi
  8041603401:	00 00 00 
  8041603404:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603409:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603410:	00 00 00 
  8041603413:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603416:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  804160341a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160341f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603423:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160342a:	00 00 00 
  804160342d:	ff d0                	callq  *%rax
  804160342f:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  8041603433:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041603438:	eb 08                	jmp    8041603442 <line_for_address+0x198>
    *len = initial_len;
  804160343a:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  804160343d:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  8041603442:	48 98                	cltq   
  8041603444:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  8041603447:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  804160344a:	ba 01 00 00 00       	mov    $0x1,%edx
  804160344f:	4c 89 e6             	mov    %r12,%rsi
  8041603452:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603456:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160345d:	00 00 00 
  8041603460:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  8041603462:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  8041603466:	0f 85 89 00 00 00    	jne    80416034f5 <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  804160346c:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  8041603471:	66 41 83 ff 04       	cmp    $0x4,%r15w
  8041603476:	0f 84 ae 00 00 00    	je     804160352a <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  804160347c:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  8041603480:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603485:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603489:	49 bc 08 af 60 41 80 	movabs $0x804160af08,%r12
  8041603490:	00 00 00 
  8041603493:	41 ff d4             	callq  *%r12
  8041603496:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  804160349a:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  804160349d:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  80416034a1:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034a6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034aa:	41 ff d4             	callq  *%r12
  80416034ad:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034b1:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034b4:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  80416034b8:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034bd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034c1:	41 ff d4             	callq  *%r12
  80416034c4:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034c8:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034cb:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  80416034cf:	ba 08 00 00 00       	mov    $0x8,%edx
  80416034d4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034d8:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  80416034db:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  80416034df:	0f 86 90 04 00 00    	jbe    8041603975 <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  80416034e5:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  80416034eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416034f0:	e9 32 04 00 00       	jmpq   8041603927 <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  80416034f5:	48 b9 b8 bb 60 41 80 	movabs $0x804160bbb8,%rcx
  80416034fc:	00 00 00 
  80416034ff:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041603506:	00 00 00 
  8041603509:	be 07 01 00 00       	mov    $0x107,%esi
  804160350e:	48 bf 41 bb 60 41 80 	movabs $0x804160bb41,%rdi
  8041603515:	00 00 00 
  8041603518:	b8 00 00 00 00       	mov    $0x0,%eax
  804160351d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603524:	00 00 00 
  8041603527:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  804160352a:	ba 01 00 00 00       	mov    $0x1,%edx
  804160352f:	48 89 de             	mov    %rbx,%rsi
  8041603532:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603536:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160353d:	00 00 00 
  8041603540:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  8041603542:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  8041603547:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160354b:	0f 84 2b ff ff ff    	je     804160347c <line_for_address+0x1d2>
  8041603551:	48 b9 d8 bb 60 41 80 	movabs $0x804160bbd8,%rcx
  8041603558:	00 00 00 
  804160355b:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041603562:	00 00 00 
  8041603565:	be 11 01 00 00       	mov    $0x111,%esi
  804160356a:	48 bf 41 bb 60 41 80 	movabs $0x804160bb41,%rdi
  8041603571:	00 00 00 
  8041603574:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603579:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603580:	00 00 00 
  8041603583:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  8041603586:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  8041603589:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  804160358f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603594:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  804160359a:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  804160359d:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416035a1:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  80416035a5:	89 fa                	mov    %edi,%edx
  80416035a7:	83 e2 7f             	and    $0x7f,%edx
  80416035aa:	d3 e2                	shl    %cl,%edx
  80416035ac:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  80416035af:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416035b2:	40 84 ff             	test   %dil,%dil
  80416035b5:	78 e3                	js     804160359a <line_for_address+0x2f0>
  return count;
  80416035b7:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  80416035ba:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  80416035bd:	45 89 ff             	mov    %r15d,%r15d
  80416035c0:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  80416035c3:	ba 01 00 00 00       	mov    $0x1,%edx
  80416035c8:	4c 89 ee             	mov    %r13,%rsi
  80416035cb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416035cf:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416035d6:	00 00 00 
  80416035d9:	ff d0                	callq  *%rax
  80416035db:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  80416035df:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  80416035e3:	3c 02                	cmp    $0x2,%al
  80416035e5:	0f 84 dc 00 00 00    	je     80416036c7 <line_for_address+0x41d>
  80416035eb:	76 39                	jbe    8041603626 <line_for_address+0x37c>
  80416035ed:	3c 03                	cmp    $0x3,%al
  80416035ef:	74 62                	je     8041603653 <line_for_address+0x3a9>
  80416035f1:	3c 04                	cmp    $0x4,%al
  80416035f3:	0f 85 0c 01 00 00    	jne    8041603705 <line_for_address+0x45b>
  80416035f9:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416035fc:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603601:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603604:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603608:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160360b:	84 c9                	test   %cl,%cl
  804160360d:	78 f2                	js     8041603601 <line_for_address+0x357>
  return count;
  804160360f:	48 98                	cltq   
          program_addr += count;
  8041603611:	48 01 c6             	add    %rax,%rsi
  8041603614:	44 89 e2             	mov    %r12d,%edx
  8041603617:	48 89 d8             	mov    %rbx,%rax
  804160361a:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160361e:	4c 89 f3             	mov    %r14,%rbx
  8041603621:	e9 c8 00 00 00       	jmpq   80416036ee <line_for_address+0x444>
      switch (opcode) {
  8041603626:	3c 01                	cmp    $0x1,%al
  8041603628:	0f 85 d7 00 00 00    	jne    8041603705 <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  804160362e:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603632:	49 39 c6             	cmp    %rax,%r14
  8041603635:	0f 87 f8 00 00 00    	ja     8041603733 <line_for_address+0x489>
  804160363b:	48 39 d8             	cmp    %rbx,%rax
  804160363e:	0f 82 39 03 00 00    	jb     804160397d <line_for_address+0x6d3>
          state->line          = 1;
  8041603644:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  8041603649:	b8 00 00 00 00       	mov    $0x0,%eax
  804160364e:	e9 9b 00 00 00       	jmpq   80416036ee <line_for_address+0x444>
          while (*(char *)program_addr) {
  8041603653:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  8041603658:	74 09                	je     8041603663 <line_for_address+0x3b9>
            ++program_addr;
  804160365a:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  804160365e:	80 3e 00             	cmpb   $0x0,(%rsi)
  8041603661:	75 f7                	jne    804160365a <line_for_address+0x3b0>
          ++program_addr;
  8041603663:	48 83 c6 01          	add    $0x1,%rsi
  8041603667:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160366a:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  804160366f:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603672:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603676:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603679:	84 c9                	test   %cl,%cl
  804160367b:	78 f2                	js     804160366f <line_for_address+0x3c5>
  return count;
  804160367d:	48 98                	cltq   
          program_addr += count;
  804160367f:	48 01 c6             	add    %rax,%rsi
  8041603682:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603685:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  804160368a:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160368d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603691:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603694:	84 c9                	test   %cl,%cl
  8041603696:	78 f2                	js     804160368a <line_for_address+0x3e0>
  return count;
  8041603698:	48 98                	cltq   
          program_addr += count;
  804160369a:	48 01 c6             	add    %rax,%rsi
  804160369d:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416036a0:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036a5:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036a8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036ac:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036af:	84 c9                	test   %cl,%cl
  80416036b1:	78 f2                	js     80416036a5 <line_for_address+0x3fb>
  return count;
  80416036b3:	48 98                	cltq   
          program_addr += count;
  80416036b5:	48 01 c6             	add    %rax,%rsi
  80416036b8:	44 89 e2             	mov    %r12d,%edx
  80416036bb:	48 89 d8             	mov    %rbx,%rax
  80416036be:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036c2:	4c 89 f3             	mov    %r14,%rbx
  80416036c5:	eb 27                	jmp    80416036ee <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  80416036c7:	ba 08 00 00 00       	mov    $0x8,%edx
  80416036cc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416036d0:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  80416036d7:	00 00 00 
  80416036da:	ff d0                	callq  *%rax
  80416036dc:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  80416036e0:	49 8d 75 09          	lea    0x9(%r13),%rsi
  80416036e4:	44 89 e2             	mov    %r12d,%edx
  80416036e7:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036eb:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  80416036ee:	49 39 f7             	cmp    %rsi,%r15
  80416036f1:	75 4c                	jne    804160373f <line_for_address+0x495>
  80416036f3:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416036f7:	41 89 d4             	mov    %edx,%r12d
  80416036fa:	49 89 de             	mov    %rbx,%r14
  80416036fd:	48 89 c3             	mov    %rax,%rbx
  8041603700:	e9 19 02 00 00       	jmpq   804160391e <line_for_address+0x674>
      switch (opcode) {
  8041603705:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603708:	48 ba 54 bb 60 41 80 	movabs $0x804160bb54,%rdx
  804160370f:	00 00 00 
  8041603712:	be 6b 00 00 00       	mov    $0x6b,%esi
  8041603717:	48 bf 41 bb 60 41 80 	movabs $0x804160bb41,%rdi
  804160371e:	00 00 00 
  8041603721:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603726:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160372d:	00 00 00 
  8041603730:	41 ff d0             	callq  *%r8
          state->line          = 1;
  8041603733:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  8041603738:	b8 00 00 00 00       	mov    $0x0,%eax
  804160373d:	eb af                	jmp    80416036ee <line_for_address+0x444>
      assert(program_addr == opcode_end);
  804160373f:	48 b9 67 bb 60 41 80 	movabs $0x804160bb67,%rcx
  8041603746:	00 00 00 
  8041603749:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041603750:	00 00 00 
  8041603753:	be 6e 00 00 00       	mov    $0x6e,%esi
  8041603758:	48 bf 41 bb 60 41 80 	movabs $0x804160bb41,%rdi
  804160375f:	00 00 00 
  8041603762:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603767:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160376e:	00 00 00 
  8041603771:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  8041603774:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603778:	49 39 c6             	cmp    %rax,%r14
  804160377b:	0f 87 eb 01 00 00    	ja     804160396c <line_for_address+0x6c2>
  8041603781:	48 39 d8             	cmp    %rbx,%rax
  8041603784:	0f 82 f9 01 00 00    	jb     8041603983 <line_for_address+0x6d9>
          last_state           = *state;
  804160378a:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160378e:	49 89 de             	mov    %rbx,%r14
  8041603791:	e9 88 01 00 00       	jmpq   804160391e <line_for_address+0x674>
      switch (opcode) {
  8041603796:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  8041603799:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  804160379e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037a3:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416037a8:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037ac:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  80416037b0:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416037b3:	45 89 c8             	mov    %r9d,%r8d
  80416037b6:	41 83 e0 7f          	and    $0x7f,%r8d
  80416037ba:	41 d3 e0             	shl    %cl,%r8d
  80416037bd:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  80416037c0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416037c3:	45 84 c9             	test   %r9b,%r9b
  80416037c6:	78 e0                	js     80416037a8 <line_for_address+0x4fe>
              info->minimum_instruction_length *
  80416037c8:	89 d2                	mov    %edx,%edx
          state->address +=
  80416037ca:	48 01 d3             	add    %rdx,%rbx
  return count;
  80416037cd:	48 98                	cltq   
          program_addr += count;
  80416037cf:	48 01 c6             	add    %rax,%rsi
        } break;
  80416037d2:	e9 47 01 00 00       	jmpq   804160391e <line_for_address+0x674>
      switch (opcode) {
  80416037d7:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037da:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416037df:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037e4:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416037e9:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037ed:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  80416037f1:	45 89 c8             	mov    %r9d,%r8d
  80416037f4:	41 83 e0 7f          	and    $0x7f,%r8d
  80416037f8:	41 d3 e0             	shl    %cl,%r8d
  80416037fb:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  80416037fe:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041603801:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603804:	45 84 c9             	test   %r9b,%r9b
  8041603807:	78 e0                	js     80416037e9 <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  8041603809:	83 f9 1f             	cmp    $0x1f,%ecx
  804160380c:	7f 0f                	jg     804160381d <line_for_address+0x573>
  804160380e:	41 f6 c1 40          	test   $0x40,%r9b
  8041603812:	74 09                	je     804160381d <line_for_address+0x573>
    result |= (-1U << shift);
  8041603814:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8041603819:	d3 e7                	shl    %cl,%edi
  804160381b:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  804160381d:	41 01 d4             	add    %edx,%r12d
  return count;
  8041603820:	48 98                	cltq   
          program_addr += count;
  8041603822:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603825:	e9 f4 00 00 00       	jmpq   804160391e <line_for_address+0x674>
      switch (opcode) {
  804160382a:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160382d:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603832:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603835:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603839:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160383c:	84 c9                	test   %cl,%cl
  804160383e:	78 f2                	js     8041603832 <line_for_address+0x588>
  return count;
  8041603840:	48 98                	cltq   
          program_addr += count;
  8041603842:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603845:	e9 d4 00 00 00       	jmpq   804160391e <line_for_address+0x674>
      switch (opcode) {
  804160384a:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160384d:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603852:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603855:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603859:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160385c:	84 c9                	test   %cl,%cl
  804160385e:	78 f2                	js     8041603852 <line_for_address+0x5a8>
  return count;
  8041603860:	48 98                	cltq   
          program_addr += count;
  8041603862:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603865:	e9 b4 00 00 00       	jmpq   804160391e <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  804160386a:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  804160386e:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  8041603870:	0f b6 c0             	movzbl %al,%eax
  8041603873:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  8041603876:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  8041603879:	48 01 c3             	add    %rax,%rbx
        } break;
  804160387c:	e9 9d 00 00 00       	jmpq   804160391e <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  8041603881:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603886:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160388a:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  8041603891:	00 00 00 
  8041603894:	ff d0                	callq  *%rax
          state->address += pc_inc;
  8041603896:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  804160389a:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  804160389d:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  80416038a1:	eb 7b                	jmp    804160391e <line_for_address+0x674>
      switch (opcode) {
  80416038a3:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416038a6:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416038ab:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416038ae:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416038b2:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416038b5:	84 c9                	test   %cl,%cl
  80416038b7:	78 f2                	js     80416038ab <line_for_address+0x601>
  return count;
  80416038b9:	48 98                	cltq   
          program_addr += count;
  80416038bb:	48 01 c6             	add    %rax,%rsi
        } break;
  80416038be:	eb 5e                	jmp    804160391e <line_for_address+0x674>
      switch (opcode) {
  80416038c0:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  80416038c3:	48 ba 54 bb 60 41 80 	movabs $0x804160bb54,%rdx
  80416038ca:	00 00 00 
  80416038cd:	be c1 00 00 00       	mov    $0xc1,%esi
  80416038d2:	48 bf 41 bb 60 41 80 	movabs $0x804160bb41,%rdi
  80416038d9:	00 00 00 
  80416038dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038e1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416038e8:	00 00 00 
  80416038eb:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  80416038ee:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  80416038f1:	0f b6 c0             	movzbl %al,%eax
  80416038f4:	f6 75 ba             	divb   -0x46(%rbp)
  80416038f7:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  80416038fa:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  80416038fe:	01 ca                	add    %ecx,%edx
  8041603900:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  8041603903:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  8041603906:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  8041603909:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160390d:	49 39 c6             	cmp    %rax,%r14
  8041603910:	77 05                	ja     8041603917 <line_for_address+0x66d>
  8041603912:	48 39 d8             	cmp    %rbx,%rax
  8041603915:	72 72                	jb     8041603989 <line_for_address+0x6df>
      last_state = *state;
  8041603917:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160391b:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  804160391e:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  8041603922:	76 69                	jbe    804160398d <line_for_address+0x6e3>
  8041603924:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  8041603927:	ba 01 00 00 00       	mov    $0x1,%edx
  804160392c:	4c 89 ee             	mov    %r13,%rsi
  804160392f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603933:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160393a:	00 00 00 
  804160393d:	ff d0                	callq  *%rax
  804160393f:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  8041603943:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  8041603947:	84 c0                	test   %al,%al
  8041603949:	0f 84 37 fc ff ff    	je     8041603586 <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  804160394f:	38 45 bb             	cmp    %al,-0x45(%rbp)
  8041603952:	76 9a                	jbe    80416038ee <line_for_address+0x644>
      switch (opcode) {
  8041603954:	3c 0c                	cmp    $0xc,%al
  8041603956:	0f 87 64 ff ff ff    	ja     80416038c0 <line_for_address+0x616>
  804160395c:	0f b6 d0             	movzbl %al,%edx
  804160395f:	48 bf 00 bc 60 41 80 	movabs $0x804160bc00,%rdi
  8041603966:	00 00 00 
  8041603969:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  804160396c:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603970:	49 89 de             	mov    %rbx,%r14
  8041603973:	eb a9                	jmp    804160391e <line_for_address+0x674>
  struct Line_Number_State current_state = {
  8041603975:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  804160397b:	eb 10                	jmp    804160398d <line_for_address+0x6e3>
            *state = last_state;
  804160397d:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603981:	eb 0a                	jmp    804160398d <line_for_address+0x6e3>
            *state = last_state;
  8041603983:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603987:	eb 04                	jmp    804160398d <line_for_address+0x6e3>
        *state = last_state;
  8041603989:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  804160398d:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041603991:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  8041603994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603999:	48 83 c4 38          	add    $0x38,%rsp
  804160399d:	5b                   	pop    %rbx
  804160399e:	41 5c                	pop    %r12
  80416039a0:	41 5d                	pop    %r13
  80416039a2:	41 5e                	pop    %r14
  80416039a4:	41 5f                	pop    %r15
  80416039a6:	5d                   	pop    %rbp
  80416039a7:	c3                   	retq   
    return -E_INVAL;
  80416039a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416039ad:	eb ea                	jmp    8041603999 <line_for_address+0x6ef>

00000080416039af <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  80416039af:	55                   	push   %rbp
  80416039b0:	48 89 e5             	mov    %rsp,%rbp
  80416039b3:	41 55                	push   %r13
  80416039b5:	41 54                	push   %r12
  80416039b7:	53                   	push   %rbx
  80416039b8:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  80416039bc:	48 bb e0 bf 60 41 80 	movabs $0x804160bfe0,%rbx
  80416039c3:	00 00 00 
  80416039c6:	4c 8d ab d8 00 00 00 	lea    0xd8(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  80416039cd:	49 bc 9c 8a 60 41 80 	movabs $0x8041608a9c,%r12
  80416039d4:	00 00 00 
  80416039d7:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  80416039db:	48 8b 33             	mov    (%rbx),%rsi
  80416039de:	48 bf 68 bc 60 41 80 	movabs $0x804160bc68,%rdi
  80416039e5:	00 00 00 
  80416039e8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039ed:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  80416039f0:	48 83 c3 18          	add    $0x18,%rbx
  80416039f4:	4c 39 eb             	cmp    %r13,%rbx
  80416039f7:	75 de                	jne    80416039d7 <mon_help+0x28>
  return 0;
}
  80416039f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039fe:	48 83 c4 08          	add    $0x8,%rsp
  8041603a02:	5b                   	pop    %rbx
  8041603a03:	41 5c                	pop    %r12
  8041603a05:	41 5d                	pop    %r13
  8041603a07:	5d                   	pop    %rbp
  8041603a08:	c3                   	retq   

0000008041603a09 <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  8041603a09:	55                   	push   %rbp
  8041603a0a:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603a0d:	48 bf 71 bc 60 41 80 	movabs $0x804160bc71,%rdi
  8041603a14:	00 00 00 
  8041603a17:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a1c:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041603a23:	00 00 00 
  8041603a26:	ff d2                	callq  *%rdx
  return 0;
}
  8041603a28:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a2d:	5d                   	pop    %rbp
  8041603a2e:	c3                   	retq   

0000008041603a2f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  8041603a2f:	55                   	push   %rbp
  8041603a30:	48 89 e5             	mov    %rsp,%rbp
  8041603a33:	41 55                	push   %r13
  8041603a35:	41 54                	push   %r12
  8041603a37:	53                   	push   %rbx
  8041603a38:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  8041603a3c:	48 bf 79 bc 60 41 80 	movabs $0x804160bc79,%rdi
  8041603a43:	00 00 00 
  8041603a46:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a4b:	49 bc 9c 8a 60 41 80 	movabs $0x8041608a9c,%r12
  8041603a52:	00 00 00 
  8041603a55:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  8041603a58:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  8041603a5f:	00 00 00 
  8041603a62:	48 bf 10 be 60 41 80 	movabs $0x804160be10,%rdi
  8041603a69:	00 00 00 
  8041603a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a71:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  8041603a74:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  8041603a7b:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  8041603a7e:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  8041603a85:	00 00 00 
  8041603a88:	4c 89 ee             	mov    %r13,%rsi
  8041603a8b:	48 bf 40 be 60 41 80 	movabs $0x804160be40,%rdi
  8041603a92:	00 00 00 
  8041603a95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a9a:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603a9d:	48 ba 40 b6 60 01 00 	movabs $0x160b640,%rdx
  8041603aa4:	00 00 00 
  8041603aa7:	48 be 40 b6 60 41 80 	movabs $0x804160b640,%rsi
  8041603aae:	00 00 00 
  8041603ab1:	48 bf 68 be 60 41 80 	movabs $0x804160be68,%rdi
  8041603ab8:	00 00 00 
  8041603abb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ac0:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603ac3:	48 ba 08 e9 61 01 00 	movabs $0x161e908,%rdx
  8041603aca:	00 00 00 
  8041603acd:	48 be 08 e9 61 41 80 	movabs $0x804161e908,%rsi
  8041603ad4:	00 00 00 
  8041603ad7:	48 bf 90 be 60 41 80 	movabs $0x804160be90,%rdi
  8041603ade:	00 00 00 
  8041603ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ae6:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  8041603ae9:	48 bb 00 20 62 41 80 	movabs $0x8041622000,%rbx
  8041603af0:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603af3:	48 ba 00 20 62 01 00 	movabs $0x1622000,%rdx
  8041603afa:	00 00 00 
  8041603afd:	48 89 de             	mov    %rbx,%rsi
  8041603b00:	48 bf b8 be 60 41 80 	movabs $0x804160beb8,%rdi
  8041603b07:	00 00 00 
  8041603b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b0f:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603b12:	4c 29 eb             	sub    %r13,%rbx
  8041603b15:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603b1c:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603b20:	48 bf e0 be 60 41 80 	movabs $0x804160bee0,%rdi
  8041603b27:	00 00 00 
  8041603b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b2f:	41 ff d4             	callq  *%r12
  return 0;
}
  8041603b32:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b37:	48 83 c4 08          	add    $0x8,%rsp
  8041603b3b:	5b                   	pop    %rbx
  8041603b3c:	41 5c                	pop    %r12
  8041603b3e:	41 5d                	pop    %r13
  8041603b40:	5d                   	pop    %rbp
  8041603b41:	c3                   	retq   

0000008041603b42 <mon_mycommand>:

// LAB 2 code
int
mon_mycommand(int argc, char **argv, struct Trapframe *tf) {
  8041603b42:	55                   	push   %rbp
  8041603b43:	48 89 e5             	mov    %rsp,%rbp
  cprintf("This is output for my command.\n");
  8041603b46:	48 bf 10 bf 60 41 80 	movabs $0x804160bf10,%rdi
  8041603b4d:	00 00 00 
  8041603b50:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b55:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041603b5c:	00 00 00 
  8041603b5f:	ff d2                	callq  *%rdx
  return 0;
}
  8041603b61:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b66:	5d                   	pop    %rbp
  8041603b67:	c3                   	retq   

0000008041603b68 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  8041603b68:	55                   	push   %rbp
  8041603b69:	48 89 e5             	mov    %rsp,%rbp
  8041603b6c:	41 57                	push   %r15
  8041603b6e:	41 56                	push   %r14
  8041603b70:	41 55                	push   %r13
  8041603b72:	41 54                	push   %r12
  8041603b74:	53                   	push   %rbx
  8041603b75:	48 81 ec 38 02 00 00 	sub    $0x238,%rsp
  // LAB 2 code

  cprintf("Stack backtrace:\n");
  8041603b7c:	48 bf 92 bc 60 41 80 	movabs $0x804160bc92,%rdi
  8041603b83:	00 00 00 
  8041603b86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b8b:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041603b92:	00 00 00 
  8041603b95:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603b97:	48 89 e8             	mov    %rbp,%rax
  uint64_t buf;
  int digits_16;
  int code;
  struct Ripdebuginfo info;

  while (rbp != 0) {
  8041603b9a:	48 85 c0             	test   %rax,%rax
  8041603b9d:	0f 84 c5 01 00 00    	je     8041603d68 <mon_backtrace+0x200>
  8041603ba3:	49 89 c6             	mov    %rax,%r14
  8041603ba6:	49 89 c7             	mov    %rax,%r15
    while (buf != 0) {
      digits_16++;
      buf = buf / 16;
    }

    cprintf("  rbp ");
  8041603ba9:	49 bc 9c 8a 60 41 80 	movabs $0x8041608a9c,%r12
  8041603bb0:	00 00 00 
    cprintf("%lx\n", rip);

    // get and print debug info
    code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
    if (code == 0) {
      cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603bb3:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603bba:	48 05 04 01 00 00    	add    $0x104,%rax
  8041603bc0:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  8041603bc7:	e9 37 01 00 00       	jmpq   8041603d03 <mon_backtrace+0x19b>
      buf = buf / 16;
  8041603bcc:	48 89 d0             	mov    %rdx,%rax
      digits_16++;
  8041603bcf:	83 c3 01             	add    $0x1,%ebx
      buf = buf / 16;
  8041603bd2:	48 89 c2             	mov    %rax,%rdx
  8041603bd5:	48 c1 ea 04          	shr    $0x4,%rdx
    while (buf != 0) {
  8041603bd9:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603bdd:	77 ed                	ja     8041603bcc <mon_backtrace+0x64>
    cprintf("  rbp ");
  8041603bdf:	48 bf a4 bc 60 41 80 	movabs $0x804160bca4,%rdi
  8041603be6:	00 00 00 
  8041603be9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603bee:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603bf1:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603bf7:	41 29 dd             	sub    %ebx,%r13d
  8041603bfa:	45 85 ed             	test   %r13d,%r13d
  8041603bfd:	7e 1f                	jle    8041603c1e <mon_backtrace+0xb6>
  8041603bff:	bb 01 00 00 00       	mov    $0x1,%ebx
      cprintf("0");
  8041603c04:	48 bf 87 ca 60 41 80 	movabs $0x804160ca87,%rdi
  8041603c0b:	00 00 00 
  8041603c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c13:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c16:	83 c3 01             	add    $0x1,%ebx
  8041603c19:	41 39 dd             	cmp    %ebx,%r13d
  8041603c1c:	7d e6                	jge    8041603c04 <mon_backtrace+0x9c>
    cprintf("%lx", rbp);
  8041603c1e:	4c 89 f6             	mov    %r14,%rsi
  8041603c21:	48 bf ab bc 60 41 80 	movabs $0x804160bcab,%rdi
  8041603c28:	00 00 00 
  8041603c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c30:	41 ff d4             	callq  *%r12
    rbp = *pointer;
  8041603c33:	4d 8b 37             	mov    (%r15),%r14
    rip = *pointer;
  8041603c36:	4d 8b 7f 08          	mov    0x8(%r15),%r15
    buf       = buf / 16;
  8041603c3a:	4c 89 f8             	mov    %r15,%rax
  8041603c3d:	48 c1 e8 04          	shr    $0x4,%rax
    while (buf != 0) {
  8041603c41:	49 83 ff 0f          	cmp    $0xf,%r15
  8041603c45:	0f 86 e3 00 00 00    	jbe    8041603d2e <mon_backtrace+0x1c6>
    digits_16 = 1;
  8041603c4b:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603c50:	eb 03                	jmp    8041603c55 <mon_backtrace+0xed>
      buf = buf / 16;
  8041603c52:	48 89 d0             	mov    %rdx,%rax
      digits_16++;
  8041603c55:	83 c3 01             	add    $0x1,%ebx
      buf = buf / 16;
  8041603c58:	48 89 c2             	mov    %rax,%rdx
  8041603c5b:	48 c1 ea 04          	shr    $0x4,%rdx
    while (buf != 0) {
  8041603c5f:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603c63:	77 ed                	ja     8041603c52 <mon_backtrace+0xea>
    cprintf("  rip ");
  8041603c65:	48 bf af bc 60 41 80 	movabs $0x804160bcaf,%rdi
  8041603c6c:	00 00 00 
  8041603c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c74:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c77:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603c7d:	41 29 dd             	sub    %ebx,%r13d
  8041603c80:	45 85 ed             	test   %r13d,%r13d
  8041603c83:	7e 1f                	jle    8041603ca4 <mon_backtrace+0x13c>
  8041603c85:	bb 01 00 00 00       	mov    $0x1,%ebx
      cprintf("0");
  8041603c8a:	48 bf 87 ca 60 41 80 	movabs $0x804160ca87,%rdi
  8041603c91:	00 00 00 
  8041603c94:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c99:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c9c:	83 c3 01             	add    $0x1,%ebx
  8041603c9f:	44 39 eb             	cmp    %r13d,%ebx
  8041603ca2:	7e e6                	jle    8041603c8a <mon_backtrace+0x122>
    cprintf("%lx\n", rip);
  8041603ca4:	4c 89 fe             	mov    %r15,%rsi
  8041603ca7:	48 bf e5 ca 60 41 80 	movabs $0x804160cae5,%rdi
  8041603cae:	00 00 00 
  8041603cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cb6:	41 ff d4             	callq  *%r12
    code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
  8041603cb9:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603cc0:	4c 89 ff             	mov    %r15,%rdi
  8041603cc3:	48 b8 c0 9f 60 41 80 	movabs $0x8041609fc0,%rax
  8041603cca:	00 00 00 
  8041603ccd:	ff d0                	callq  *%rax
    if (code == 0) {
  8041603ccf:	85 c0                	test   %eax,%eax
  8041603cd1:	75 47                	jne    8041603d1a <mon_backtrace+0x1b2>
      cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603cd3:	4d 89 f8             	mov    %r15,%r8
  8041603cd6:	4c 2b 45 b8          	sub    -0x48(%rbp),%r8
  8041603cda:	48 8b 8d a8 fd ff ff 	mov    -0x258(%rbp),%rcx
  8041603ce1:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603ce7:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603cee:	48 bf b6 bc 60 41 80 	movabs $0x804160bcb6,%rdi
  8041603cf5:	00 00 00 
  8041603cf8:	41 ff d4             	callq  *%r12
    } else {
      cprintf("Info not found");
    }

    pointer = (uintptr_t *)rbp;
  8041603cfb:	4d 89 f7             	mov    %r14,%r15
  while (rbp != 0) {
  8041603cfe:	4d 85 f6             	test   %r14,%r14
  8041603d01:	74 65                	je     8041603d68 <mon_backtrace+0x200>
    buf       = buf / 16;
  8041603d03:	4c 89 f0             	mov    %r14,%rax
  8041603d06:	48 c1 e8 04          	shr    $0x4,%rax
    while (buf != 0) {
  8041603d0a:	49 83 fe 0f          	cmp    $0xf,%r14
  8041603d0e:	76 3b                	jbe    8041603d4b <mon_backtrace+0x1e3>
    digits_16 = 1;
  8041603d10:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603d15:	e9 b5 fe ff ff       	jmpq   8041603bcf <mon_backtrace+0x67>
      cprintf("Info not found");
  8041603d1a:	48 bf ce bc 60 41 80 	movabs $0x804160bcce,%rdi
  8041603d21:	00 00 00 
  8041603d24:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d29:	41 ff d4             	callq  *%r12
  8041603d2c:	eb cd                	jmp    8041603cfb <mon_backtrace+0x193>
    cprintf("  rip ");
  8041603d2e:	48 bf af bc 60 41 80 	movabs $0x804160bcaf,%rdi
  8041603d35:	00 00 00 
  8041603d38:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d3d:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d40:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d46:	e9 3a ff ff ff       	jmpq   8041603c85 <mon_backtrace+0x11d>
    cprintf("  rbp ");
  8041603d4b:	48 bf a4 bc 60 41 80 	movabs $0x804160bca4,%rdi
  8041603d52:	00 00 00 
  8041603d55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d5a:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d5d:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d63:	e9 97 fe ff ff       	jmpq   8041603bff <mon_backtrace+0x97>
  }

  return 0;
}
  8041603d68:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d6d:	48 81 c4 38 02 00 00 	add    $0x238,%rsp
  8041603d74:	5b                   	pop    %rbx
  8041603d75:	41 5c                	pop    %r12
  8041603d77:	41 5d                	pop    %r13
  8041603d79:	41 5e                	pop    %r14
  8041603d7b:	41 5f                	pop    %r15
  8041603d7d:	5d                   	pop    %rbp
  8041603d7e:	c3                   	retq   

0000008041603d7f <mon_start>:
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
int
mon_start(int argc, char **argv, struct Trapframe *tf) {

  if (argc != 2) {
    return 1;
  8041603d7f:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603d84:	83 ff 02             	cmp    $0x2,%edi
  8041603d87:	74 01                	je     8041603d8a <mon_start+0xb>
  }
  timer_start(argv[1]);

  return 0;
}
  8041603d89:	c3                   	retq   
mon_start(int argc, char **argv, struct Trapframe *tf) {
  8041603d8a:	55                   	push   %rbp
  8041603d8b:	48 89 e5             	mov    %rsp,%rbp
  timer_start(argv[1]);
  8041603d8e:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603d92:	48 b8 52 b3 60 41 80 	movabs $0x804160b352,%rax
  8041603d99:	00 00 00 
  8041603d9c:	ff d0                	callq  *%rax
  return 0;
  8041603d9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603da3:	5d                   	pop    %rbp
  8041603da4:	c3                   	retq   

0000008041603da5 <mon_stop>:

int
mon_stop(int argc, char **argv, struct Trapframe *tf) {
  8041603da5:	55                   	push   %rbp
  8041603da6:	48 89 e5             	mov    %rsp,%rbp

  timer_stop();
  8041603da9:	48 b8 0c b4 60 41 80 	movabs $0x804160b40c,%rax
  8041603db0:	00 00 00 
  8041603db3:	ff d0                	callq  *%rax

  return 0;
}
  8041603db5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603dba:	5d                   	pop    %rbp
  8041603dbb:	c3                   	retq   

0000008041603dbc <mon_frequency>:

int
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603dbc:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603dc1:	83 ff 02             	cmp    $0x2,%edi
  8041603dc4:	74 01                	je     8041603dc7 <mon_frequency+0xb>
  }
  timer_cpu_frequency(argv[1]);

  return 0;
}
  8041603dc6:	c3                   	retq   
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  8041603dc7:	55                   	push   %rbp
  8041603dc8:	48 89 e5             	mov    %rsp,%rbp
  timer_cpu_frequency(argv[1]);
  8041603dcb:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603dcf:	48 b8 96 b4 60 41 80 	movabs $0x804160b496,%rax
  8041603dd6:	00 00 00 
  8041603dd9:	ff d0                	callq  *%rax
  return 0;
  8041603ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603de0:	5d                   	pop    %rbp
  8041603de1:	c3                   	retq   

0000008041603de2 <mon_memory>:
int
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  size_t i;
  int is_cur_free;

  for (i = 1; i <= npages; i++) {
  8041603de2:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  8041603de9:	00 00 00 
  8041603dec:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041603df0:	0f 84 24 01 00 00    	je     8041603f1a <mon_memory+0x138>
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  8041603df6:	55                   	push   %rbp
  8041603df7:	48 89 e5             	mov    %rsp,%rbp
  8041603dfa:	41 57                	push   %r15
  8041603dfc:	41 56                	push   %r14
  8041603dfe:	41 55                	push   %r13
  8041603e00:	41 54                	push   %r12
  8041603e02:	53                   	push   %rbx
  8041603e03:	48 83 ec 18          	sub    $0x18,%rsp
  for (i = 1; i <= npages; i++) {
  8041603e07:	bb 01 00 00 00       	mov    $0x1,%ebx
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e0c:	49 be 78 00 62 41 80 	movabs $0x8041620078,%r14
  8041603e13:	00 00 00 
    cprintf("%lu", i);
  8041603e16:	49 bf 9c 8a 60 41 80 	movabs $0x8041608a9c,%r15
  8041603e1d:	00 00 00 
    if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e20:	49 89 c4             	mov    %rax,%r12
  8041603e23:	eb 47                	jmp    8041603e6c <mon_memory+0x8a>
      while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
        i++;
      }
      cprintf("..%lu", i);
  8041603e25:	48 89 de             	mov    %rbx,%rsi
  8041603e28:	48 bf f0 bc 60 41 80 	movabs $0x804160bcf0,%rdi
  8041603e2f:	00 00 00 
  8041603e32:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e37:	41 ff d7             	callq  *%r15
    }
    cprintf(is_cur_free ? " FREE\n" : " ALLOCATED\n");
  8041603e3a:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603e3e:	48 bf dd bc 60 41 80 	movabs $0x804160bcdd,%rdi
  8041603e45:	00 00 00 
  8041603e48:	48 b8 e4 bc 60 41 80 	movabs $0x804160bce4,%rax
  8041603e4f:	00 00 00 
  8041603e52:	48 0f 45 f8          	cmovne %rax,%rdi
  8041603e56:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e5b:	41 ff d7             	callq  *%r15
  for (i = 1; i <= npages; i++) {
  8041603e5e:	48 83 c3 01          	add    $0x1,%rbx
  8041603e62:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603e66:	0f 82 9a 00 00 00    	jb     8041603f06 <mon_memory+0x124>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e6c:	49 89 dd             	mov    %rbx,%r13
  8041603e6f:	49 c1 e5 04          	shl    $0x4,%r13
  8041603e73:	49 8b 06             	mov    (%r14),%rax
  8041603e76:	4a 8d 7c 28 f0       	lea    -0x10(%rax,%r13,1),%rdi
  8041603e7b:	48 b8 e5 4a 60 41 80 	movabs $0x8041604ae5,%rax
  8041603e82:	00 00 00 
  8041603e85:	ff d0                	callq  *%rax
  8041603e87:	89 45 cc             	mov    %eax,-0x34(%rbp)
    cprintf("%lu", i);
  8041603e8a:	48 89 de             	mov    %rbx,%rsi
  8041603e8d:	48 bf f2 bc 60 41 80 	movabs $0x804160bcf2,%rdi
  8041603e94:	00 00 00 
  8041603e97:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e9c:	41 ff d7             	callq  *%r15
    if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e9f:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603ea3:	76 95                	jbe    8041603e3a <mon_memory+0x58>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603ea5:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603ea9:	0f 94 c0             	sete   %al
  8041603eac:	0f b6 c0             	movzbl %al,%eax
  8041603eaf:	89 45 c8             	mov    %eax,-0x38(%rbp)
    if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603eb2:	4c 89 ef             	mov    %r13,%rdi
  8041603eb5:	49 03 3e             	add    (%r14),%rdi
  8041603eb8:	48 b8 e5 4a 60 41 80 	movabs $0x8041604ae5,%rax
  8041603ebf:	00 00 00 
  8041603ec2:	ff d0                	callq  *%rax
  8041603ec4:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603ec7:	0f 84 6d ff ff ff    	je     8041603e3a <mon_memory+0x58>
      while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603ecd:	49 bd e5 4a 60 41 80 	movabs $0x8041604ae5,%r13
  8041603ed4:	00 00 00 
  8041603ed7:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603edb:	0f 86 44 ff ff ff    	jbe    8041603e25 <mon_memory+0x43>
  8041603ee1:	48 89 df             	mov    %rbx,%rdi
  8041603ee4:	48 c1 e7 04          	shl    $0x4,%rdi
  8041603ee8:	49 03 3e             	add    (%r14),%rdi
  8041603eeb:	41 ff d5             	callq  *%r13
  8041603eee:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603ef1:	0f 84 2e ff ff ff    	je     8041603e25 <mon_memory+0x43>
        i++;
  8041603ef7:	48 83 c3 01          	add    $0x1,%rbx
      while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603efb:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603eff:	77 e0                	ja     8041603ee1 <mon_memory+0xff>
  8041603f01:	e9 1f ff ff ff       	jmpq   8041603e25 <mon_memory+0x43>
  }

  return 0;
}
  8041603f06:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f0b:	48 83 c4 18          	add    $0x18,%rsp
  8041603f0f:	5b                   	pop    %rbx
  8041603f10:	41 5c                	pop    %r12
  8041603f12:	41 5d                	pop    %r13
  8041603f14:	41 5e                	pop    %r14
  8041603f16:	41 5f                	pop    %r15
  8041603f18:	5d                   	pop    %rbp
  8041603f19:	c3                   	retq   
  8041603f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f1f:	c3                   	retq   

0000008041603f20 <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603f20:	55                   	push   %rbp
  8041603f21:	48 89 e5             	mov    %rsp,%rbp
  8041603f24:	41 57                	push   %r15
  8041603f26:	41 56                	push   %r14
  8041603f28:	41 55                	push   %r13
  8041603f2a:	41 54                	push   %r12
  8041603f2c:	53                   	push   %rbx
  8041603f2d:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603f34:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603f3b:	48 bf 30 bf 60 41 80 	movabs $0x804160bf30,%rdi
  8041603f42:	00 00 00 
  8041603f45:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f4a:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  8041603f51:	00 00 00 
  8041603f54:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603f56:	48 bf 58 bf 60 41 80 	movabs $0x804160bf58,%rdi
  8041603f5d:	00 00 00 
  8041603f60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f65:	ff d3                	callq  *%rbx

  while (1) {
    buf = readline("K> ");
  8041603f67:	49 bf 55 ab 60 41 80 	movabs $0x804160ab55,%r15
  8041603f6e:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603f71:	49 be 05 ae 60 41 80 	movabs $0x804160ae05,%r14
  8041603f78:	00 00 00 
  8041603f7b:	e9 ff 00 00 00       	jmpq   804160407f <monitor+0x15f>
  8041603f80:	40 0f be f6          	movsbl %sil,%esi
  8041603f84:	48 bf fa bc 60 41 80 	movabs $0x804160bcfa,%rdi
  8041603f8b:	00 00 00 
  8041603f8e:	41 ff d6             	callq  *%r14
  8041603f91:	48 85 c0             	test   %rax,%rax
  8041603f94:	74 0c                	je     8041603fa2 <monitor+0x82>
      *buf++ = 0;
  8041603f96:	c6 03 00             	movb   $0x0,(%rbx)
  8041603f99:	45 89 e5             	mov    %r12d,%r13d
  8041603f9c:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603fa0:	eb 49                	jmp    8041603feb <monitor+0xcb>
    if (*buf == 0)
  8041603fa2:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603fa5:	74 4f                	je     8041603ff6 <monitor+0xd6>
    if (argc == MAXARGS - 1) {
  8041603fa7:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603fab:	0f 84 b3 00 00 00    	je     8041604064 <monitor+0x144>
    argv[argc++] = buf;
  8041603fb1:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  8041603fb6:	4d 63 e4             	movslq %r12d,%r12
  8041603fb9:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041603fc0:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603fc1:	0f b6 33             	movzbl (%rbx),%esi
  8041603fc4:	40 84 f6             	test   %sil,%sil
  8041603fc7:	74 22                	je     8041603feb <monitor+0xcb>
  8041603fc9:	40 0f be f6          	movsbl %sil,%esi
  8041603fcd:	48 bf fa bc 60 41 80 	movabs $0x804160bcfa,%rdi
  8041603fd4:	00 00 00 
  8041603fd7:	41 ff d6             	callq  *%r14
  8041603fda:	48 85 c0             	test   %rax,%rax
  8041603fdd:	75 0c                	jne    8041603feb <monitor+0xcb>
      buf++;
  8041603fdf:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603fe3:	0f b6 33             	movzbl (%rbx),%esi
  8041603fe6:	40 84 f6             	test   %sil,%sil
  8041603fe9:	75 de                	jne    8041603fc9 <monitor+0xa9>
      *buf++ = 0;
  8041603feb:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603fee:	0f b6 33             	movzbl (%rbx),%esi
  8041603ff1:	40 84 f6             	test   %sil,%sil
  8041603ff4:	75 8a                	jne    8041603f80 <monitor+0x60>
  argv[argc] = 0;
  8041603ff6:	49 63 c4             	movslq %r12d,%rax
  8041603ff9:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041604000:	ff 00 00 00 00 
  if (argc == 0)
  8041604005:	45 85 e4             	test   %r12d,%r12d
  8041604008:	74 75                	je     804160407f <monitor+0x15f>
  804160400a:	49 bd e0 bf 60 41 80 	movabs $0x804160bfe0,%r13
  8041604011:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041604014:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  8041604019:	49 8b 75 00          	mov    0x0(%r13),%rsi
  804160401d:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041604024:	48 b8 9e ad 60 41 80 	movabs $0x804160ad9e,%rax
  804160402b:	00 00 00 
  804160402e:	ff d0                	callq  *%rax
  8041604030:	85 c0                	test   %eax,%eax
  8041604032:	74 76                	je     80416040aa <monitor+0x18a>
  for (i = 0; i < NCOMMANDS; i++) {
  8041604034:	83 c3 01             	add    $0x1,%ebx
  8041604037:	49 83 c5 18          	add    $0x18,%r13
  804160403b:	83 fb 09             	cmp    $0x9,%ebx
  804160403e:	75 d9                	jne    8041604019 <monitor+0xf9>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041604040:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041604047:	48 bf 1c bd 60 41 80 	movabs $0x804160bd1c,%rdi
  804160404e:	00 00 00 
  8041604051:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604056:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160405d:	00 00 00 
  8041604060:	ff d2                	callq  *%rdx
  return 0;
  8041604062:	eb 1b                	jmp    804160407f <monitor+0x15f>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041604064:	be 10 00 00 00       	mov    $0x10,%esi
  8041604069:	48 bf ff bc 60 41 80 	movabs $0x804160bcff,%rdi
  8041604070:	00 00 00 
  8041604073:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160407a:	00 00 00 
  804160407d:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  804160407f:	48 bf f6 bc 60 41 80 	movabs $0x804160bcf6,%rdi
  8041604086:	00 00 00 
  8041604089:	41 ff d7             	callq  *%r15
  804160408c:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  804160408f:	48 85 c0             	test   %rax,%rax
  8041604092:	74 eb                	je     804160407f <monitor+0x15f>
  argv[argc] = 0;
  8041604094:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  804160409b:	00 00 00 00 
  argc       = 0;
  804160409f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  80416040a5:	e9 44 ff ff ff       	jmpq   8041603fee <monitor+0xce>
      return commands[i].func(argc, argv, tf);
  80416040aa:	48 63 db             	movslq %ebx,%rbx
  80416040ad:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  80416040b1:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  80416040b8:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  80416040bf:	44 89 e7             	mov    %r12d,%edi
  80416040c2:	48 b8 e0 bf 60 41 80 	movabs $0x804160bfe0,%rax
  80416040c9:	00 00 00 
  80416040cc:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  80416040d0:	85 c0                	test   %eax,%eax
  80416040d2:	79 ab                	jns    804160407f <monitor+0x15f>
        break;
  }
}
  80416040d4:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  80416040db:	5b                   	pop    %rbx
  80416040dc:	41 5c                	pop    %r12
  80416040de:	41 5d                	pop    %r13
  80416040e0:	41 5e                	pop    %r14
  80416040e2:	41 5f                	pop    %r15
  80416040e4:	5d                   	pop    %rbp
  80416040e5:	c3                   	retq   

00000080416040e6 <check_va2pa>:
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  pte_t *pte;
  pdpe_t *pdpe;
  pde_t *pde;
  //cprintf("1: Virtual addr: %ld\n", va);
  pml4e = &pml4e[PML4(va)];
  80416040e6:	48 89 f0             	mov    %rsi,%rax
  80416040e9:	48 c1 e8 27          	shr    $0x27,%rax
  80416040ed:	25 ff 01 00 00       	and    $0x1ff,%eax
  //cprintf("2: PML4(va): %ld PML4E: %ld\n" , PML4(va), *pml4e);
  if (!(*pml4e & PTE_P))
  80416040f2:	48 8b 0c c7          	mov    (%rdi,%rax,8),%rcx
  80416040f6:	f6 c1 01             	test   $0x1,%cl
  80416040f9:	0f 84 5a 01 00 00    	je     8041604259 <check_va2pa+0x173>
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  80416040ff:	55                   	push   %rbp
  8041604100:	48 89 e5             	mov    %rsp,%rbp
    return ~0;
  pdpe = (pdpe_t *)KADDR(PTE_ADDR(*pml4e));
  8041604103:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
//CAUTION: use only before page detection!
#define _KADDR_NOCHECK(pa) (void *)((physaddr_t)pa + KERNBASE)

static inline void *
_kaddr(const char *file, int line, physaddr_t pa) {
  if (PGNUM(pa) >= npages)
  804160410a:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  8041604111:	00 00 00 
  8041604114:	48 8b 10             	mov    (%rax),%rdx
  8041604117:	48 89 c8             	mov    %rcx,%rax
  804160411a:	48 c1 e8 0c          	shr    $0xc,%rax
  804160411e:	48 39 c2             	cmp    %rax,%rdx
  8041604121:	0f 86 b1 00 00 00    	jbe    80416041d8 <check_va2pa+0xf2>
  //cprintf("3: PDPE: %ln  PDPE Addr: %ld\n" , pdpe, *pdpe);
  if (!(pdpe[PDPE(va)] & PTE_P))
  8041604127:	48 89 f0             	mov    %rsi,%rax
  804160412a:	48 c1 e8 1b          	shr    $0x1b,%rax
  804160412e:	25 f8 0f 00 00       	and    $0xff8,%eax
  8041604133:	48 01 c1             	add    %rax,%rcx
  8041604136:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160413d:	00 00 00 
  8041604140:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  8041604144:	f6 c1 01             	test   $0x1,%cl
  8041604147:	0f 84 14 01 00 00    	je     8041604261 <check_va2pa+0x17b>
    return ~0;
  pde = (pde_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  804160414d:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041604154:	48 89 c8             	mov    %rcx,%rax
  8041604157:	48 c1 e8 0c          	shr    $0xc,%rax
  804160415b:	48 39 c2             	cmp    %rax,%rdx
  804160415e:	0f 86 9f 00 00 00    	jbe    8041604203 <check_va2pa+0x11d>
  //cprintf("4: PDE: %ln PDE Addr: %ld\n" , pde, *pde);
  pde = &pde[PDX(va)];
  8041604164:	48 89 f0             	mov    %rsi,%rax
  8041604167:	48 c1 e8 12          	shr    $0x12,%rax
  if (!(*pde & PTE_P))
  804160416b:	25 f8 0f 00 00       	and    $0xff8,%eax
  8041604170:	48 01 c1             	add    %rax,%rcx
  8041604173:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160417a:	00 00 00 
  804160417d:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  8041604181:	f6 c1 01             	test   $0x1,%cl
  8041604184:	0f 84 e3 00 00 00    	je     804160426d <check_va2pa+0x187>
    return ~0;
  pte = (pte_t *)KADDR(PTE_ADDR(*pde));
  804160418a:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041604191:	48 89 c8             	mov    %rcx,%rax
  8041604194:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604198:	48 39 c2             	cmp    %rax,%rdx
  804160419b:	0f 86 8d 00 00 00    	jbe    804160422e <check_va2pa+0x148>
  //cprintf("5: PTE: %ln PTE Addr: %ld\n" , pte, *pte);
  if (!(pte[PTX(va)] & PTE_P))
  80416041a1:	48 c1 ee 09          	shr    $0x9,%rsi
  80416041a5:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
  80416041ab:	48 01 ce             	add    %rcx,%rsi
  80416041ae:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416041b5:	00 00 00 
  80416041b8:	48 8b 04 06          	mov    (%rsi,%rax,1),%rax
  80416041bc:	48 89 c2             	mov    %rax,%rdx
  80416041bf:	83 e2 01             	and    $0x1,%edx
    return ~0;
  //cprintf("6: PTX(va): %ld PTE Addr: %ld\n" , PTX(va),  PTE_ADDR(pte[PTX(va)]));
  return PTE_ADDR(pte[PTX(va)]);
  80416041c2:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416041c8:	48 85 d2             	test   %rdx,%rdx
  80416041cb:	48 c7 c2 ff ff ff ff 	mov    $0xffffffffffffffff,%rdx
  80416041d2:	48 0f 44 c2          	cmove  %rdx,%rax
}
  80416041d6:	5d                   	pop    %rbp
  80416041d7:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416041d8:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416041df:	00 00 00 
  80416041e2:	be 20 04 00 00       	mov    $0x420,%esi
  80416041e7:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416041ee:	00 00 00 
  80416041f1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416041f6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416041fd:	00 00 00 
  8041604200:	41 ff d0             	callq  *%r8
  8041604203:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  804160420a:	00 00 00 
  804160420d:	be 24 04 00 00       	mov    $0x424,%esi
  8041604212:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604219:	00 00 00 
  804160421c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604221:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604228:	00 00 00 
  804160422b:	41 ff d0             	callq  *%r8
  804160422e:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604235:	00 00 00 
  8041604238:	be 29 04 00 00       	mov    $0x429,%esi
  804160423d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604244:	00 00 00 
  8041604247:	b8 00 00 00 00       	mov    $0x0,%eax
  804160424c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604253:	00 00 00 
  8041604256:	41 ff d0             	callq  *%r8
    return ~0;
  8041604259:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
}
  8041604260:	c3                   	retq   
    return ~0;
  8041604261:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  8041604268:	e9 69 ff ff ff       	jmpq   80416041d6 <check_va2pa+0xf0>
    return ~0;
  804160426d:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  8041604274:	e9 5d ff ff ff       	jmpq   80416041d6 <check_va2pa+0xf0>

0000008041604279 <boot_alloc>:
boot_alloc(uint32_t n) {
  8041604279:	55                   	push   %rbp
  804160427a:	48 89 e5             	mov    %rsp,%rbp
  if (!nextfree) {
  804160427d:	48 b8 98 eb 61 41 80 	movabs $0x804161eb98,%rax
  8041604284:	00 00 00 
  8041604287:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160428b:	74 54                	je     80416042e1 <boot_alloc+0x68>
  result = nextfree;
  804160428d:	48 b9 98 eb 61 41 80 	movabs $0x804161eb98,%rcx
  8041604294:	00 00 00 
  8041604297:	48 8b 01             	mov    (%rcx),%rax
  nextfree += ROUNDUP(n, PGSIZE);
  804160429a:	48 8d 97 ff 0f 00 00 	lea    0xfff(%rdi),%rdx
  80416042a1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  80416042a7:	48 01 c2             	add    %rax,%rdx
  80416042aa:	48 89 11             	mov    %rdx,(%rcx)
  if ((uint64_t)kva < KERNBASE)
  80416042ad:	48 b9 ff ff ff 3f 80 	movabs $0x803fffffff,%rcx
  80416042b4:	00 00 00 
  80416042b7:	48 39 ca             	cmp    %rcx,%rdx
  80416042ba:	76 41                	jbe    80416042fd <boot_alloc+0x84>
  if (PADDR(nextfree) > PGSIZE * npages) {
  80416042bc:	48 bf 70 00 62 41 80 	movabs $0x8041620070,%rdi
  80416042c3:	00 00 00 
  80416042c6:	48 8b 37             	mov    (%rdi),%rsi
  80416042c9:	48 c1 e6 0c          	shl    $0xc,%rsi
  return (physaddr_t)kva - KERNBASE;
  80416042cd:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  80416042d4:	ff ff ff 
  80416042d7:	48 01 ca             	add    %rcx,%rdx
  80416042da:	48 39 d6             	cmp    %rdx,%rsi
  80416042dd:	72 4c                	jb     804160432b <boot_alloc+0xb2>
}
  80416042df:	5d                   	pop    %rbp
  80416042e0:	c3                   	retq   
    nextfree = ROUNDUP((char *)end, PGSIZE);
  80416042e1:	48 b8 ff 2f 62 41 80 	movabs $0x8041622fff,%rax
  80416042e8:	00 00 00 
  80416042eb:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416042f1:	48 a3 98 eb 61 41 80 	movabs %rax,0x804161eb98
  80416042f8:	00 00 00 
  80416042fb:	eb 90                	jmp    804160428d <boot_alloc+0x14>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416042fd:	48 89 d1             	mov    %rdx,%rcx
  8041604300:	48 ba d8 c0 60 41 80 	movabs $0x804160c0d8,%rdx
  8041604307:	00 00 00 
  804160430a:	be b6 00 00 00       	mov    $0xb6,%esi
  804160430f:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604316:	00 00 00 
  8041604319:	b8 00 00 00 00       	mov    $0x0,%eax
  804160431e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604325:	00 00 00 
  8041604328:	41 ff d0             	callq  *%r8
    panic("Out of memory on boot, what? how?!");
  804160432b:	48 ba 00 c1 60 41 80 	movabs $0x804160c100,%rdx
  8041604332:	00 00 00 
  8041604335:	be b7 00 00 00       	mov    $0xb7,%esi
  804160433a:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604341:	00 00 00 
  8041604344:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604349:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604350:	00 00 00 
  8041604353:	ff d1                	callq  *%rcx

0000008041604355 <check_page_free_list>:
check_page_free_list(bool only_low_memory) {
  8041604355:	55                   	push   %rbp
  8041604356:	48 89 e5             	mov    %rsp,%rbp
  8041604359:	53                   	push   %rbx
  804160435a:	48 83 ec 28          	sub    $0x28,%rsp
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  804160435e:	40 84 ff             	test   %dil,%dil
  8041604361:	0f 85 7f 03 00 00    	jne    80416046e6 <check_page_free_list+0x391>
  if (!page_free_list)
  8041604367:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  804160436e:	00 00 00 
  8041604371:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604375:	0f 84 9f 00 00 00    	je     804160441a <check_page_free_list+0xc5>
  first_free_page = (char *)boot_alloc(0);
  804160437b:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604380:	48 b8 79 42 60 41 80 	movabs $0x8041604279,%rax
  8041604387:	00 00 00 
  804160438a:	ff d0                	callq  *%rax
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  804160438c:	48 bb a8 eb 61 41 80 	movabs $0x804161eba8,%rbx
  8041604393:	00 00 00 
  8041604396:	48 8b 13             	mov    (%rbx),%rdx
  8041604399:	48 85 d2             	test   %rdx,%rdx
  804160439c:	0f 84 0f 03 00 00    	je     80416046b1 <check_page_free_list+0x35c>
    assert(pp >= pages);
  80416043a2:	48 bb 78 00 62 41 80 	movabs $0x8041620078,%rbx
  80416043a9:	00 00 00 
  80416043ac:	48 8b 3b             	mov    (%rbx),%rdi
  80416043af:	48 39 fa             	cmp    %rdi,%rdx
  80416043b2:	0f 82 8c 00 00 00    	jb     8041604444 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  80416043b8:	48 bb 70 00 62 41 80 	movabs $0x8041620070,%rbx
  80416043bf:	00 00 00 
  80416043c2:	4c 8b 1b             	mov    (%rbx),%r11
  80416043c5:	4d 89 d8             	mov    %r11,%r8
  80416043c8:	49 c1 e0 04          	shl    $0x4,%r8
  80416043cc:	49 01 f8             	add    %rdi,%r8
  80416043cf:	4c 39 c2             	cmp    %r8,%rdx
  80416043d2:	0f 83 a1 00 00 00    	jae    8041604479 <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416043d8:	48 89 d1             	mov    %rdx,%rcx
  80416043db:	48 29 f9             	sub    %rdi,%rcx
  80416043de:	f6 c1 0f             	test   $0xf,%cl
  80416043e1:	0f 85 c7 00 00 00    	jne    80416044ae <check_page_free_list+0x159>

static void check_page_free_list(bool only_low_memory);

static inline physaddr_t
page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
  80416043e7:	48 c1 f9 04          	sar    $0x4,%rcx
  80416043eb:	48 c1 e1 0c          	shl    $0xc,%rcx
  80416043ef:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  80416043f2:	0f 84 eb 00 00 00    	je     80416044e3 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  80416043f8:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  80416043ff:	0f 84 13 01 00 00    	je     8041604518 <check_page_free_list+0x1c3>
  int nfree_basemem = 0, nfree_extmem = 0;
  8041604405:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  return (void *)(pa + KERNBASE);
  804160440b:	48 bb 00 00 00 40 80 	movabs $0x8040000000,%rbx
  8041604412:	00 00 00 
  8041604415:	e9 17 02 00 00       	jmpq   8041604631 <check_page_free_list+0x2dc>
    panic("'page_free_list' is a null pointer!");
  804160441a:	48 ba 28 c1 60 41 80 	movabs $0x804160c128,%rdx
  8041604421:	00 00 00 
  8041604424:	be 56 03 00 00       	mov    $0x356,%esi
  8041604429:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604430:	00 00 00 
  8041604433:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604438:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160443f:	00 00 00 
  8041604442:	ff d1                	callq  *%rcx
    assert(pp >= pages);
  8041604444:	48 b9 58 ca 60 41 80 	movabs $0x804160ca58,%rcx
  804160444b:	00 00 00 
  804160444e:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041604455:	00 00 00 
  8041604458:	be 77 03 00 00       	mov    $0x377,%esi
  804160445d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604464:	00 00 00 
  8041604467:	b8 00 00 00 00       	mov    $0x0,%eax
  804160446c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604473:	00 00 00 
  8041604476:	41 ff d0             	callq  *%r8
    assert(pp < pages + npages);
  8041604479:	48 b9 64 ca 60 41 80 	movabs $0x804160ca64,%rcx
  8041604480:	00 00 00 
  8041604483:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160448a:	00 00 00 
  804160448d:	be 78 03 00 00       	mov    $0x378,%esi
  8041604492:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604499:	00 00 00 
  804160449c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044a1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044a8:	00 00 00 
  80416044ab:	41 ff d0             	callq  *%r8
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416044ae:	48 b9 50 c1 60 41 80 	movabs $0x804160c150,%rcx
  80416044b5:	00 00 00 
  80416044b8:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416044bf:	00 00 00 
  80416044c2:	be 79 03 00 00       	mov    $0x379,%esi
  80416044c7:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416044ce:	00 00 00 
  80416044d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044d6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044dd:	00 00 00 
  80416044e0:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != 0);
  80416044e3:	48 b9 78 ca 60 41 80 	movabs $0x804160ca78,%rcx
  80416044ea:	00 00 00 
  80416044ed:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416044f4:	00 00 00 
  80416044f7:	be 7c 03 00 00       	mov    $0x37c,%esi
  80416044fc:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604503:	00 00 00 
  8041604506:	b8 00 00 00 00       	mov    $0x0,%eax
  804160450b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604512:	00 00 00 
  8041604515:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != IOPHYSMEM);
  8041604518:	48 b9 89 ca 60 41 80 	movabs $0x804160ca89,%rcx
  804160451f:	00 00 00 
  8041604522:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041604529:	00 00 00 
  804160452c:	be 7d 03 00 00       	mov    $0x37d,%esi
  8041604531:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604538:	00 00 00 
  804160453b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604540:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604547:	00 00 00 
  804160454a:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  804160454d:	48 b9 80 c1 60 41 80 	movabs $0x804160c180,%rcx
  8041604554:	00 00 00 
  8041604557:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160455e:	00 00 00 
  8041604561:	be 7e 03 00 00       	mov    $0x37e,%esi
  8041604566:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160456d:	00 00 00 
  8041604570:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604575:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160457c:	00 00 00 
  804160457f:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM);
  8041604582:	48 b9 a2 ca 60 41 80 	movabs $0x804160caa2,%rcx
  8041604589:	00 00 00 
  804160458c:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041604593:	00 00 00 
  8041604596:	be 7f 03 00 00       	mov    $0x37f,%esi
  804160459b:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416045a2:	00 00 00 
  80416045a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045aa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045b1:	00 00 00 
  80416045b4:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416045b7:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416045be:	00 00 00 
  80416045c1:	be 60 00 00 00       	mov    $0x60,%esi
  80416045c6:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  80416045cd:	00 00 00 
  80416045d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045d5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045dc:	00 00 00 
  80416045df:	41 ff d0             	callq  *%r8
      ++nfree_extmem;
  80416045e2:	41 83 c1 01          	add    $0x1,%r9d
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  80416045e6:	48 8b 12             	mov    (%rdx),%rdx
  80416045e9:	48 85 d2             	test   %rdx,%rdx
  80416045ec:	0f 84 b3 00 00 00    	je     80416046a5 <check_page_free_list+0x350>
    assert(pp >= pages);
  80416045f2:	48 39 fa             	cmp    %rdi,%rdx
  80416045f5:	0f 82 49 fe ff ff    	jb     8041604444 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  80416045fb:	4c 39 c2             	cmp    %r8,%rdx
  80416045fe:	0f 83 75 fe ff ff    	jae    8041604479 <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  8041604604:	48 89 d1             	mov    %rdx,%rcx
  8041604607:	48 29 f9             	sub    %rdi,%rcx
  804160460a:	f6 c1 0f             	test   $0xf,%cl
  804160460d:	0f 85 9b fe ff ff    	jne    80416044ae <check_page_free_list+0x159>
  return (pp - pages) << PGSHIFT;
  8041604613:	48 c1 f9 04          	sar    $0x4,%rcx
  8041604617:	48 c1 e1 0c          	shl    $0xc,%rcx
  804160461b:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  804160461e:	0f 84 bf fe ff ff    	je     80416044e3 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604624:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  804160462b:	0f 84 e7 fe ff ff    	je     8041604518 <check_page_free_list+0x1c3>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  8041604631:	48 81 fe 00 f0 0f 00 	cmp    $0xff000,%rsi
  8041604638:	0f 84 0f ff ff ff    	je     804160454d <check_page_free_list+0x1f8>
    assert(page2pa(pp) != EXTPHYSMEM);
  804160463e:	48 81 fe 00 00 10 00 	cmp    $0x100000,%rsi
  8041604645:	0f 84 37 ff ff ff    	je     8041604582 <check_page_free_list+0x22d>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
  804160464b:	48 81 fe ff ff 0f 00 	cmp    $0xfffff,%rsi
  8041604652:	76 92                	jbe    80416045e6 <check_page_free_list+0x291>
  if (PGNUM(pa) >= npages)
  8041604654:	49 89 f2             	mov    %rsi,%r10
  8041604657:	49 c1 ea 0c          	shr    $0xc,%r10
  804160465b:	4d 39 d3             	cmp    %r10,%r11
  804160465e:	0f 86 53 ff ff ff    	jbe    80416045b7 <check_page_free_list+0x262>
  return (void *)(pa + KERNBASE);
  8041604664:	48 01 de             	add    %rbx,%rsi
  8041604667:	48 39 f0             	cmp    %rsi,%rax
  804160466a:	0f 86 72 ff ff ff    	jbe    80416045e2 <check_page_free_list+0x28d>
  8041604670:	48 b9 a8 c1 60 41 80 	movabs $0x804160c1a8,%rcx
  8041604677:	00 00 00 
  804160467a:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041604681:	00 00 00 
  8041604684:	be 80 03 00 00       	mov    $0x380,%esi
  8041604689:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604690:	00 00 00 
  8041604693:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604698:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160469f:	00 00 00 
  80416046a2:	41 ff d0             	callq  *%r8
  assert(nfree_extmem > 0);
  80416046a5:	45 85 c9             	test   %r9d,%r9d
  80416046a8:	7e 07                	jle    80416046b1 <check_page_free_list+0x35c>
}
  80416046aa:	48 83 c4 28          	add    $0x28,%rsp
  80416046ae:	5b                   	pop    %rbx
  80416046af:	5d                   	pop    %rbp
  80416046b0:	c3                   	retq   
  assert(nfree_extmem > 0);
  80416046b1:	48 b9 ca ca 60 41 80 	movabs $0x804160caca,%rcx
  80416046b8:	00 00 00 
  80416046bb:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416046c2:	00 00 00 
  80416046c5:	be 89 03 00 00       	mov    $0x389,%esi
  80416046ca:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416046d1:	00 00 00 
  80416046d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046d9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416046e0:	00 00 00 
  80416046e3:	41 ff d0             	callq  *%r8
  if (!page_free_list)
  80416046e6:	48 a1 a8 eb 61 41 80 	movabs 0x804161eba8,%rax
  80416046ed:	00 00 00 
  80416046f0:	48 85 c0             	test   %rax,%rax
  80416046f3:	0f 84 21 fd ff ff    	je     804160441a <check_page_free_list+0xc5>
    struct PageInfo **tp[2] = {&pp1, &pp2};
  80416046f9:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  80416046fd:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  8041604701:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  8041604705:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  return (pp - pages) << PGSHIFT;
  8041604709:	48 be 78 00 62 41 80 	movabs $0x8041620078,%rsi
  8041604710:	00 00 00 
  8041604713:	48 89 c2             	mov    %rax,%rdx
  8041604716:	48 2b 16             	sub    (%rsi),%rdx
  8041604719:	48 c1 e2 08          	shl    $0x8,%rdx
      int pagetype  = VPN(page2pa(pp)) >= pdx_limit;
  804160471d:	48 c1 ea 0c          	shr    $0xc,%rdx
      *tp[pagetype] = pp;
  8041604721:	0f 95 c2             	setne  %dl
  8041604724:	0f b6 d2             	movzbl %dl,%edx
  8041604727:	48 8b 4c d5 e0       	mov    -0x20(%rbp,%rdx,8),%rcx
  804160472c:	48 89 01             	mov    %rax,(%rcx)
      tp[pagetype]  = &pp->pp_link;
  804160472f:	48 89 44 d5 e0       	mov    %rax,-0x20(%rbp,%rdx,8)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604734:	48 8b 00             	mov    (%rax),%rax
  8041604737:	48 85 c0             	test   %rax,%rax
  804160473a:	75 d7                	jne    8041604713 <check_page_free_list+0x3be>
    *tp[1]         = 0;
  804160473c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8041604740:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    *tp[0]         = pp2;
  8041604747:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  804160474b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160474f:	48 89 10             	mov    %rdx,(%rax)
    page_free_list = pp1;
  8041604752:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8041604756:	48 a3 a8 eb 61 41 80 	movabs %rax,0x804161eba8
  804160475d:	00 00 00 
  8041604760:	e9 16 fc ff ff       	jmpq   804160437b <check_page_free_list+0x26>

0000008041604765 <is_page_allocatable>:
  if (!mmap_base || !mmap_end)
  8041604765:	48 b8 90 eb 61 41 80 	movabs $0x804161eb90,%rax
  804160476c:	00 00 00 
  804160476f:	48 8b 10             	mov    (%rax),%rdx
  8041604772:	48 85 d2             	test   %rdx,%rdx
  8041604775:	0f 84 93 00 00 00    	je     804160480e <is_page_allocatable+0xa9>
  804160477b:	48 b8 88 eb 61 41 80 	movabs $0x804161eb88,%rax
  8041604782:	00 00 00 
  8041604785:	48 8b 30             	mov    (%rax),%rsi
  8041604788:	48 85 f6             	test   %rsi,%rsi
  804160478b:	0f 84 83 00 00 00    	je     8041604814 <is_page_allocatable+0xaf>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041604791:	48 39 f2             	cmp    %rsi,%rdx
  8041604794:	0f 83 80 00 00 00    	jae    804160481a <is_page_allocatable+0xb5>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  804160479a:	48 8b 42 08          	mov    0x8(%rdx),%rax
  804160479e:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  80416047a2:	48 89 c1             	mov    %rax,%rcx
  80416047a5:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  80416047a9:	48 39 cf             	cmp    %rcx,%rdi
  80416047ac:	73 05                	jae    80416047b3 <is_page_allocatable+0x4e>
  80416047ae:	48 39 c7             	cmp    %rax,%rdi
  80416047b1:	73 34                	jae    80416047e7 <is_page_allocatable+0x82>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047b3:	48 b8 80 eb 61 41 80 	movabs $0x804161eb80,%rax
  80416047ba:	00 00 00 
  80416047bd:	4c 8b 00             	mov    (%rax),%r8
  80416047c0:	4c 01 c2             	add    %r8,%rdx
  80416047c3:	48 39 d6             	cmp    %rdx,%rsi
  80416047c6:	76 40                	jbe    8041604808 <is_page_allocatable+0xa3>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  80416047c8:	48 8b 42 08          	mov    0x8(%rdx),%rax
  80416047cc:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  80416047d0:	48 89 c1             	mov    %rax,%rcx
  80416047d3:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  80416047d7:	48 39 f9             	cmp    %rdi,%rcx
  80416047da:	0f 97 c1             	seta   %cl
  80416047dd:	48 39 f8             	cmp    %rdi,%rax
  80416047e0:	0f 96 c0             	setbe  %al
  80416047e3:	84 c1                	test   %al,%cl
  80416047e5:	74 d9                	je     80416047c0 <is_page_allocatable+0x5b>
      switch (mmap_curr->Type) {
  80416047e7:	8b 0a                	mov    (%rdx),%ecx
  80416047e9:	85 c9                	test   %ecx,%ecx
  80416047eb:	74 33                	je     8041604820 <is_page_allocatable+0xbb>
  80416047ed:	83 f9 04             	cmp    $0x4,%ecx
  80416047f0:	76 0a                	jbe    80416047fc <is_page_allocatable+0x97>
          return false;
  80416047f2:	b8 00 00 00 00       	mov    $0x0,%eax
      switch (mmap_curr->Type) {
  80416047f7:	83 f9 07             	cmp    $0x7,%ecx
  80416047fa:	75 29                	jne    8041604825 <is_page_allocatable+0xc0>
          if (mmap_curr->Attribute & EFI_MEMORY_WB)
  80416047fc:	48 8b 42 20          	mov    0x20(%rdx),%rax
  8041604800:	48 c1 e8 03          	shr    $0x3,%rax
  8041604804:	83 e0 01             	and    $0x1,%eax
  8041604807:	c3                   	retq   
  return true;
  8041604808:	b8 01 00 00 00       	mov    $0x1,%eax
  804160480d:	c3                   	retq   
    return true; //Assume page is allocabale if no loading parameters were passed.
  804160480e:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604813:	c3                   	retq   
  8041604814:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604819:	c3                   	retq   
  return true;
  804160481a:	b8 01 00 00 00       	mov    $0x1,%eax
  804160481f:	c3                   	retq   
          return false;
  8041604820:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041604825:	c3                   	retq   

0000008041604826 <page_init>:
page_init(void) {
  8041604826:	55                   	push   %rbp
  8041604827:	48 89 e5             	mov    %rsp,%rbp
  804160482a:	41 57                	push   %r15
  804160482c:	41 56                	push   %r14
  804160482e:	41 55                	push   %r13
  8041604830:	41 54                	push   %r12
  8041604832:	53                   	push   %rbx
  8041604833:	48 83 ec 08          	sub    $0x8,%rsp
  pages[0].pp_ref  = 1;
  8041604837:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  804160483e:	00 00 00 
  8041604841:	48 8b 10             	mov    (%rax),%rdx
  8041604844:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
  pages[0].pp_link = NULL;
  804160484a:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  pages[1].pp_ref = 0;
  8041604851:	4c 8b 20             	mov    (%rax),%r12
  8041604854:	66 41 c7 44 24 18 00 	movw   $0x0,0x18(%r12)
  804160485b:	00 
  page_free_list  = &pages[1];
  804160485c:	49 83 c4 10          	add    $0x10,%r12
  8041604860:	4c 89 e0             	mov    %r12,%rax
  8041604863:	48 a3 a8 eb 61 41 80 	movabs %rax,0x804161eba8
  804160486a:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  804160486d:	48 b8 b0 eb 61 41 80 	movabs $0x804161ebb0,%rax
  8041604874:	00 00 00 
  8041604877:	48 83 38 01          	cmpq   $0x1,(%rax)
  804160487b:	76 6a                	jbe    80416048e7 <page_init+0xc1>
  804160487d:	bb 01 00 00 00       	mov    $0x1,%ebx
    if (is_page_allocatable(i)) {
  8041604882:	49 bf 65 47 60 41 80 	movabs $0x8041604765,%r15
  8041604889:	00 00 00 
      pages[i].pp_ref  = 1;
  804160488c:	49 bd 78 00 62 41 80 	movabs $0x8041620078,%r13
  8041604893:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  8041604896:	49 89 c6             	mov    %rax,%r14
  8041604899:	eb 21                	jmp    80416048bc <page_init+0x96>
      pages[i].pp_ref  = 1;
  804160489b:	48 89 d8             	mov    %rbx,%rax
  804160489e:	48 c1 e0 04          	shl    $0x4,%rax
  80416048a2:	49 03 45 00          	add    0x0(%r13),%rax
  80416048a6:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  80416048ac:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = 1; i < npages_basemem; i++) {
  80416048b3:	48 83 c3 01          	add    $0x1,%rbx
  80416048b7:	49 39 1e             	cmp    %rbx,(%r14)
  80416048ba:	76 2b                	jbe    80416048e7 <page_init+0xc1>
    if (is_page_allocatable(i)) {
  80416048bc:	48 89 df             	mov    %rbx,%rdi
  80416048bf:	41 ff d7             	callq  *%r15
  80416048c2:	84 c0                	test   %al,%al
  80416048c4:	74 d5                	je     804160489b <page_init+0x75>
      pages[i].pp_ref = 0;
  80416048c6:	48 89 d8             	mov    %rbx,%rax
  80416048c9:	48 c1 e0 04          	shl    $0x4,%rax
  80416048cd:	48 89 c2             	mov    %rax,%rdx
  80416048d0:	49 03 55 00          	add    0x0(%r13),%rdx
  80416048d4:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  80416048da:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  80416048de:	49 03 45 00          	add    0x0(%r13),%rax
  80416048e2:	49 89 c4             	mov    %rax,%r12
  80416048e5:	eb cc                	jmp    80416048b3 <page_init+0x8d>
  first_free_page = PADDR(boot_alloc(0)) / PGSIZE;
  80416048e7:	bf 00 00 00 00       	mov    $0x0,%edi
  80416048ec:	48 b8 79 42 60 41 80 	movabs $0x8041604279,%rax
  80416048f3:	00 00 00 
  80416048f6:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  80416048f8:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  80416048ff:	00 00 00 
  8041604902:	48 39 d0             	cmp    %rdx,%rax
  8041604905:	76 7d                	jbe    8041604984 <page_init+0x15e>
  return (physaddr_t)kva - KERNBASE;
  8041604907:	48 bb 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rbx
  804160490e:	ff ff ff 
  8041604911:	48 01 c3             	add    %rax,%rbx
  8041604914:	48 c1 eb 0c          	shr    $0xc,%rbx
  for (i = npages_basemem; i < first_free_page; i++) {
  8041604918:	48 a1 b0 eb 61 41 80 	movabs 0x804161ebb0,%rax
  804160491f:	00 00 00 
  8041604922:	48 39 c3             	cmp    %rax,%rbx
  8041604925:	76 31                	jbe    8041604958 <page_init+0x132>
  8041604927:	48 c1 e0 04          	shl    $0x4,%rax
  804160492b:	48 89 de             	mov    %rbx,%rsi
  804160492e:	48 c1 e6 04          	shl    $0x4,%rsi
    pages[i].pp_ref  = 1;
  8041604932:	48 b9 78 00 62 41 80 	movabs $0x8041620078,%rcx
  8041604939:	00 00 00 
  804160493c:	48 89 c2             	mov    %rax,%rdx
  804160493f:	48 03 11             	add    (%rcx),%rdx
  8041604942:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
    pages[i].pp_link = NULL;
  8041604948:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  for (i = npages_basemem; i < first_free_page; i++) {
  804160494f:	48 83 c0 10          	add    $0x10,%rax
  8041604953:	48 39 f0             	cmp    %rsi,%rax
  8041604956:	75 e4                	jne    804160493c <page_init+0x116>
  for (i = first_free_page; i < npages; i++) {
  8041604958:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  804160495f:	00 00 00 
  8041604962:	48 3b 18             	cmp    (%rax),%rbx
  8041604965:	0f 83 93 00 00 00    	jae    80416049fe <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  804160496b:	49 bf 65 47 60 41 80 	movabs $0x8041604765,%r15
  8041604972:	00 00 00 
      pages[i].pp_ref  = 1;
  8041604975:	49 bd 78 00 62 41 80 	movabs $0x8041620078,%r13
  804160497c:	00 00 00 
  for (i = first_free_page; i < npages; i++) {
  804160497f:	49 89 c6             	mov    %rax,%r14
  8041604982:	eb 4f                	jmp    80416049d3 <page_init+0x1ad>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041604984:	48 89 c1             	mov    %rax,%rcx
  8041604987:	48 ba d8 c0 60 41 80 	movabs $0x804160c0d8,%rdx
  804160498e:	00 00 00 
  8041604991:	be ca 01 00 00       	mov    $0x1ca,%esi
  8041604996:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160499d:	00 00 00 
  80416049a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416049a5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416049ac:	00 00 00 
  80416049af:	41 ff d0             	callq  *%r8
      pages[i].pp_ref  = 1;
  80416049b2:	48 89 d8             	mov    %rbx,%rax
  80416049b5:	48 c1 e0 04          	shl    $0x4,%rax
  80416049b9:	49 03 45 00          	add    0x0(%r13),%rax
  80416049bd:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  80416049c3:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = first_free_page; i < npages; i++) {
  80416049ca:	48 83 c3 01          	add    $0x1,%rbx
  80416049ce:	49 39 1e             	cmp    %rbx,(%r14)
  80416049d1:	76 2b                	jbe    80416049fe <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  80416049d3:	48 89 df             	mov    %rbx,%rdi
  80416049d6:	41 ff d7             	callq  *%r15
  80416049d9:	84 c0                	test   %al,%al
  80416049db:	74 d5                	je     80416049b2 <page_init+0x18c>
      pages[i].pp_ref = 0;
  80416049dd:	48 89 d8             	mov    %rbx,%rax
  80416049e0:	48 c1 e0 04          	shl    $0x4,%rax
  80416049e4:	48 89 c2             	mov    %rax,%rdx
  80416049e7:	49 03 55 00          	add    0x0(%r13),%rdx
  80416049eb:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  80416049f1:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  80416049f5:	49 03 45 00          	add    0x0(%r13),%rax
  80416049f9:	49 89 c4             	mov    %rax,%r12
  80416049fc:	eb cc                	jmp    80416049ca <page_init+0x1a4>
}
  80416049fe:	48 83 c4 08          	add    $0x8,%rsp
  8041604a02:	5b                   	pop    %rbx
  8041604a03:	41 5c                	pop    %r12
  8041604a05:	41 5d                	pop    %r13
  8041604a07:	41 5e                	pop    %r14
  8041604a09:	41 5f                	pop    %r15
  8041604a0b:	5d                   	pop    %rbp
  8041604a0c:	c3                   	retq   

0000008041604a0d <page_alloc>:
page_alloc(int alloc_flags) {
  8041604a0d:	55                   	push   %rbp
  8041604a0e:	48 89 e5             	mov    %rsp,%rbp
  8041604a11:	53                   	push   %rbx
  8041604a12:	48 83 ec 08          	sub    $0x8,%rsp
  if (!page_free_list) {
  8041604a16:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  8041604a1d:	00 00 00 
  8041604a20:	48 8b 18             	mov    (%rax),%rbx
  8041604a23:	48 85 db             	test   %rbx,%rbx
  8041604a26:	74 1f                	je     8041604a47 <page_alloc+0x3a>
  page_free_list               = page_free_list->pp_link;
  8041604a28:	48 8b 03             	mov    (%rbx),%rax
  8041604a2b:	48 a3 a8 eb 61 41 80 	movabs %rax,0x804161eba8
  8041604a32:	00 00 00 
  return_page->pp_link         = NULL;
  8041604a35:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  if (!page_free_list) {
  8041604a3c:	48 85 c0             	test   %rax,%rax
  8041604a3f:	74 10                	je     8041604a51 <page_alloc+0x44>
  if (alloc_flags & ALLOC_ZERO) {
  8041604a41:	40 f6 c7 01          	test   $0x1,%dil
  8041604a45:	75 1d                	jne    8041604a64 <page_alloc+0x57>
}
  8041604a47:	48 89 d8             	mov    %rbx,%rax
  8041604a4a:	48 83 c4 08          	add    $0x8,%rsp
  8041604a4e:	5b                   	pop    %rbx
  8041604a4f:	5d                   	pop    %rbp
  8041604a50:	c3                   	retq   
    page_free_list_top = NULL;
  8041604a51:	48 b8 a0 eb 61 41 80 	movabs $0x804161eba0,%rax
  8041604a58:	00 00 00 
  8041604a5b:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  8041604a62:	eb dd                	jmp    8041604a41 <page_alloc+0x34>
  return (pp - pages) << PGSHIFT;
  8041604a64:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041604a6b:	00 00 00 
  8041604a6e:	48 89 df             	mov    %rbx,%rdi
  8041604a71:	48 2b 38             	sub    (%rax),%rdi
  8041604a74:	48 c1 ff 04          	sar    $0x4,%rdi
  8041604a78:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041604a7c:	48 89 fa             	mov    %rdi,%rdx
  8041604a7f:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041604a83:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  8041604a8a:	00 00 00 
  8041604a8d:	48 3b 10             	cmp    (%rax),%rdx
  8041604a90:	73 25                	jae    8041604ab7 <page_alloc+0xaa>
  return (void *)(pa + KERNBASE);
  8041604a92:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604a99:	00 00 00 
  8041604a9c:	48 01 cf             	add    %rcx,%rdi
    memset(page2kva(return_page), 0, PGSIZE);
  8041604a9f:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041604aa4:	be 00 00 00 00       	mov    $0x0,%esi
  8041604aa9:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041604ab0:	00 00 00 
  8041604ab3:	ff d0                	callq  *%rax
  8041604ab5:	eb 90                	jmp    8041604a47 <page_alloc+0x3a>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604ab7:	48 89 f9             	mov    %rdi,%rcx
  8041604aba:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604ac1:	00 00 00 
  8041604ac4:	be 60 00 00 00       	mov    $0x60,%esi
  8041604ac9:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  8041604ad0:	00 00 00 
  8041604ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ad8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604adf:	00 00 00 
  8041604ae2:	41 ff d0             	callq  *%r8

0000008041604ae5 <page_is_allocated>:
  return !pp->pp_link && pp != page_free_list_top;
  8041604ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604aea:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604aee:	74 01                	je     8041604af1 <page_is_allocated+0xc>
}
  8041604af0:	c3                   	retq   
  return !pp->pp_link && pp != page_free_list_top;
  8041604af1:	48 b8 a0 eb 61 41 80 	movabs $0x804161eba0,%rax
  8041604af8:	00 00 00 
  8041604afb:	48 39 38             	cmp    %rdi,(%rax)
  8041604afe:	0f 95 c0             	setne  %al
  8041604b01:	0f b6 c0             	movzbl %al,%eax
  8041604b04:	eb ea                	jmp    8041604af0 <page_is_allocated+0xb>

0000008041604b06 <page_free>:
page_free(struct PageInfo *pp) {
  8041604b06:	55                   	push   %rbp
  8041604b07:	48 89 e5             	mov    %rsp,%rbp
  if (pp->pp_ref) {
  8041604b0a:	66 83 7f 08 00       	cmpw   $0x0,0x8(%rdi)
  8041604b0f:	75 2b                	jne    8041604b3c <page_free+0x36>
  if (pp->pp_link) {
  8041604b11:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604b15:	75 4f                	jne    8041604b66 <page_free+0x60>
  pp->pp_link    = page_free_list;
  8041604b17:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  8041604b1e:	00 00 00 
  8041604b21:	48 8b 10             	mov    (%rax),%rdx
  8041604b24:	48 89 17             	mov    %rdx,(%rdi)
  page_free_list = pp;
  8041604b27:	48 89 38             	mov    %rdi,(%rax)
  if (!page_free_list_top) {
  8041604b2a:	48 b8 a0 eb 61 41 80 	movabs $0x804161eba0,%rax
  8041604b31:	00 00 00 
  8041604b34:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604b38:	74 56                	je     8041604b90 <page_free+0x8a>
}
  8041604b3a:	5d                   	pop    %rbp
  8041604b3b:	c3                   	retq   
    panic("page_free: Page is still referenced!\n");
  8041604b3c:	48 ba f0 c1 60 41 80 	movabs $0x804160c1f0,%rdx
  8041604b43:	00 00 00 
  8041604b46:	be 1e 02 00 00       	mov    $0x21e,%esi
  8041604b4b:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604b52:	00 00 00 
  8041604b55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b5a:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604b61:	00 00 00 
  8041604b64:	ff d1                	callq  *%rcx
    panic("page_free: Page is already freed!\n");
  8041604b66:	48 ba 18 c2 60 41 80 	movabs $0x804160c218,%rdx
  8041604b6d:	00 00 00 
  8041604b70:	be 22 02 00 00       	mov    $0x222,%esi
  8041604b75:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604b7c:	00 00 00 
  8041604b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b84:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604b8b:	00 00 00 
  8041604b8e:	ff d1                	callq  *%rcx
    page_free_list_top = pp;
  8041604b90:	48 89 f8             	mov    %rdi,%rax
  8041604b93:	48 a3 a0 eb 61 41 80 	movabs %rax,0x804161eba0
  8041604b9a:	00 00 00 
}
  8041604b9d:	eb 9b                	jmp    8041604b3a <page_free+0x34>

0000008041604b9f <page_decref>:
  if (--pp->pp_ref == 0)
  8041604b9f:	0f b7 47 08          	movzwl 0x8(%rdi),%eax
  8041604ba3:	83 e8 01             	sub    $0x1,%eax
  8041604ba6:	66 89 47 08          	mov    %ax,0x8(%rdi)
  8041604baa:	66 85 c0             	test   %ax,%ax
  8041604bad:	74 01                	je     8041604bb0 <page_decref+0x11>
  8041604baf:	c3                   	retq   
page_decref(struct PageInfo *pp) {
  8041604bb0:	55                   	push   %rbp
  8041604bb1:	48 89 e5             	mov    %rsp,%rbp
    page_free(pp);
  8041604bb4:	48 b8 06 4b 60 41 80 	movabs $0x8041604b06,%rax
  8041604bbb:	00 00 00 
  8041604bbe:	ff d0                	callq  *%rax
}
  8041604bc0:	5d                   	pop    %rbp
  8041604bc1:	c3                   	retq   

0000008041604bc2 <pgdir_walk>:
pgdir_walk(pde_t *pgdir, const void *va, int create) {
  8041604bc2:	55                   	push   %rbp
  8041604bc3:	48 89 e5             	mov    %rsp,%rbp
  8041604bc6:	41 54                	push   %r12
  8041604bc8:	53                   	push   %rbx
  8041604bc9:	48 89 f3             	mov    %rsi,%rbx
  if (pgdir[PDX(va)] & PTE_P) {
  8041604bcc:	49 89 f4             	mov    %rsi,%r12
  8041604bcf:	49 c1 ec 12          	shr    $0x12,%r12
  8041604bd3:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
  8041604bda:	49 01 fc             	add    %rdi,%r12
  8041604bdd:	49 8b 0c 24          	mov    (%r12),%rcx
  8041604be1:	f6 c1 01             	test   $0x1,%cl
  8041604be4:	74 68                	je     8041604c4e <pgdir_walk+0x8c>
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
  8041604be6:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604bed:	48 89 c8             	mov    %rcx,%rax
  8041604bf0:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604bf4:	48 ba 70 00 62 41 80 	movabs $0x8041620070,%rdx
  8041604bfb:	00 00 00 
  8041604bfe:	48 39 02             	cmp    %rax,(%rdx)
  8041604c01:	76 20                	jbe    8041604c23 <pgdir_walk+0x61>
  return (void *)(pa + KERNBASE);
  8041604c03:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041604c0a:	00 00 00 
  8041604c0d:	48 01 c1             	add    %rax,%rcx
  8041604c10:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604c14:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604c1a:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
}
  8041604c1e:	5b                   	pop    %rbx
  8041604c1f:	41 5c                	pop    %r12
  8041604c21:	5d                   	pop    %rbp
  8041604c22:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604c23:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604c2a:	00 00 00 
  8041604c2d:	be 7b 02 00 00       	mov    $0x27b,%esi
  8041604c32:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604c39:	00 00 00 
  8041604c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604c41:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604c48:	00 00 00 
  8041604c4b:	41 ff d0             	callq  *%r8
  if (create) {
  8041604c4e:	85 d2                	test   %edx,%edx
  8041604c50:	0f 84 aa 00 00 00    	je     8041604d00 <pgdir_walk+0x13e>
    np = page_alloc(ALLOC_ZERO);
  8041604c56:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604c5b:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041604c62:	00 00 00 
  8041604c65:	ff d0                	callq  *%rax
    if (np) {
  8041604c67:	48 85 c0             	test   %rax,%rax
  8041604c6a:	74 b2                	je     8041604c1e <pgdir_walk+0x5c>
      np->pp_ref++;
  8041604c6c:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604c71:	48 b9 78 00 62 41 80 	movabs $0x8041620078,%rcx
  8041604c78:	00 00 00 
  8041604c7b:	48 89 c2             	mov    %rax,%rdx
  8041604c7e:	48 2b 11             	sub    (%rcx),%rdx
  8041604c81:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604c85:	48 c1 e2 0c          	shl    $0xc,%rdx
      pgdir[PDX(va)] = page2pa(np) | PTE_P | PTE_U | PTE_W;
  8041604c89:	48 83 ca 07          	or     $0x7,%rdx
  8041604c8d:	49 89 14 24          	mov    %rdx,(%r12)
  8041604c91:	48 2b 01             	sub    (%rcx),%rax
  8041604c94:	48 c1 f8 04          	sar    $0x4,%rax
  8041604c98:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  8041604c9c:	48 89 c1             	mov    %rax,%rcx
  8041604c9f:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604ca3:	48 ba 70 00 62 41 80 	movabs $0x8041620070,%rdx
  8041604caa:	00 00 00 
  8041604cad:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604cb0:	73 20                	jae    8041604cd2 <pgdir_walk+0x110>
  return (void *)(pa + KERNBASE);
  8041604cb2:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604cb9:	00 00 00 
  8041604cbc:	48 01 c1             	add    %rax,%rcx
      return (pte_t *)page2kva(np) + PTX(va);
  8041604cbf:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604cc3:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604cc9:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
  8041604ccd:	e9 4c ff ff ff       	jmpq   8041604c1e <pgdir_walk+0x5c>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604cd2:	48 89 c1             	mov    %rax,%rcx
  8041604cd5:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604cdc:	00 00 00 
  8041604cdf:	be 60 00 00 00       	mov    $0x60,%esi
  8041604ce4:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  8041604ceb:	00 00 00 
  8041604cee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604cf3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604cfa:	00 00 00 
  8041604cfd:	41 ff d0             	callq  *%r8
  return NULL;
  8041604d00:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d05:	e9 14 ff ff ff       	jmpq   8041604c1e <pgdir_walk+0x5c>

0000008041604d0a <pdpe_walk>:
pdpe_walk(pdpe_t *pdpe, const void *va, int create) {
  8041604d0a:	55                   	push   %rbp
  8041604d0b:	48 89 e5             	mov    %rsp,%rbp
  8041604d0e:	41 55                	push   %r13
  8041604d10:	41 54                	push   %r12
  8041604d12:	53                   	push   %rbx
  8041604d13:	48 83 ec 08          	sub    $0x8,%rsp
  8041604d17:	48 89 f3             	mov    %rsi,%rbx
  8041604d1a:	41 89 d4             	mov    %edx,%r12d
  if (pdpe[PDPE(va)] & PTE_P) {
  8041604d1d:	49 89 f5             	mov    %rsi,%r13
  8041604d20:	49 c1 ed 1b          	shr    $0x1b,%r13
  8041604d24:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604d2b:	49 01 fd             	add    %rdi,%r13
  8041604d2e:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604d32:	f6 c1 01             	test   $0x1,%cl
  8041604d35:	74 6f                	je     8041604da6 <pdpe_walk+0x9c>
    return pgdir_walk((pte_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604d37:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604d3e:	48 89 c8             	mov    %rcx,%rax
  8041604d41:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604d45:	48 ba 70 00 62 41 80 	movabs $0x8041620070,%rdx
  8041604d4c:	00 00 00 
  8041604d4f:	48 39 02             	cmp    %rax,(%rdx)
  8041604d52:	76 27                	jbe    8041604d7b <pdpe_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604d54:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604d5b:	00 00 00 
  8041604d5e:	48 01 cf             	add    %rcx,%rdi
  8041604d61:	44 89 e2             	mov    %r12d,%edx
  8041604d64:	48 b8 c2 4b 60 41 80 	movabs $0x8041604bc2,%rax
  8041604d6b:	00 00 00 
  8041604d6e:	ff d0                	callq  *%rax
}
  8041604d70:	48 83 c4 08          	add    $0x8,%rsp
  8041604d74:	5b                   	pop    %rbx
  8041604d75:	41 5c                	pop    %r12
  8041604d77:	41 5d                	pop    %r13
  8041604d79:	5d                   	pop    %rbp
  8041604d7a:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604d7b:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604d82:	00 00 00 
  8041604d85:	be 68 02 00 00       	mov    $0x268,%esi
  8041604d8a:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604d91:	00 00 00 
  8041604d94:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d99:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604da0:	00 00 00 
  8041604da3:	41 ff d0             	callq  *%r8
  if (create) {
  8041604da6:	85 d2                	test   %edx,%edx
  8041604da8:	0f 84 a3 00 00 00    	je     8041604e51 <pdpe_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604dae:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604db3:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041604dba:	00 00 00 
  8041604dbd:	ff d0                	callq  *%rax
    if (np) {
  8041604dbf:	48 85 c0             	test   %rax,%rax
  8041604dc2:	74 ac                	je     8041604d70 <pdpe_walk+0x66>
      np->pp_ref++;
  8041604dc4:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604dc9:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  8041604dd0:	00 00 00 
  8041604dd3:	48 2b 02             	sub    (%rdx),%rax
  8041604dd6:	48 c1 f8 04          	sar    $0x4,%rax
  8041604dda:	48 c1 e0 0c          	shl    $0xc,%rax
      pdpe[PDPE(va)] = page2pa(np) | PTE_P | PTE_U | PTE_W;
  8041604dde:	48 89 c2             	mov    %rax,%rdx
  8041604de1:	48 83 ca 07          	or     $0x7,%rdx
  8041604de5:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604de9:	48 89 c1             	mov    %rax,%rcx
  8041604dec:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604df0:	48 ba 70 00 62 41 80 	movabs $0x8041620070,%rdx
  8041604df7:	00 00 00 
  8041604dfa:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604dfd:	73 24                	jae    8041604e23 <pdpe_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604dff:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604e06:	00 00 00 
  8041604e09:	48 01 c7             	add    %rax,%rdi
      return pgdir_walk((pte_t *) KADDR (PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604e0c:	44 89 e2             	mov    %r12d,%edx
  8041604e0f:	48 89 de             	mov    %rbx,%rsi
  8041604e12:	48 b8 c2 4b 60 41 80 	movabs $0x8041604bc2,%rax
  8041604e19:	00 00 00 
  8041604e1c:	ff d0                	callq  *%rax
  8041604e1e:	e9 4d ff ff ff       	jmpq   8041604d70 <pdpe_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604e23:	48 89 c1             	mov    %rax,%rcx
  8041604e26:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604e2d:	00 00 00 
  8041604e30:	be 71 02 00 00       	mov    $0x271,%esi
  8041604e35:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604e3c:	00 00 00 
  8041604e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e44:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604e4b:	00 00 00 
  8041604e4e:	41 ff d0             	callq  *%r8
  return NULL;
  8041604e51:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e56:	e9 15 ff ff ff       	jmpq   8041604d70 <pdpe_walk+0x66>

0000008041604e5b <pml4e_walk>:
pml4e_walk(pml4e_t *pml4e, const void *va, int create) {
  8041604e5b:	55                   	push   %rbp
  8041604e5c:	48 89 e5             	mov    %rsp,%rbp
  8041604e5f:	41 55                	push   %r13
  8041604e61:	41 54                	push   %r12
  8041604e63:	53                   	push   %rbx
  8041604e64:	48 83 ec 08          	sub    $0x8,%rsp
  8041604e68:	48 89 f3             	mov    %rsi,%rbx
  8041604e6b:	41 89 d4             	mov    %edx,%r12d
  if (pml4e[PML4(va)] & PTE_P) {
  8041604e6e:	49 89 f5             	mov    %rsi,%r13
  8041604e71:	49 c1 ed 24          	shr    $0x24,%r13
  8041604e75:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604e7c:	49 01 fd             	add    %rdi,%r13
  8041604e7f:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604e83:	f6 c1 01             	test   $0x1,%cl
  8041604e86:	74 6f                	je     8041604ef7 <pml4e_walk+0x9c>
    return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604e88:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604e8f:	48 89 c8             	mov    %rcx,%rax
  8041604e92:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604e96:	48 ba 70 00 62 41 80 	movabs $0x8041620070,%rdx
  8041604e9d:	00 00 00 
  8041604ea0:	48 39 02             	cmp    %rax,(%rdx)
  8041604ea3:	76 27                	jbe    8041604ecc <pml4e_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604ea5:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604eac:	00 00 00 
  8041604eaf:	48 01 cf             	add    %rcx,%rdi
  8041604eb2:	44 89 e2             	mov    %r12d,%edx
  8041604eb5:	48 b8 0a 4d 60 41 80 	movabs $0x8041604d0a,%rax
  8041604ebc:	00 00 00 
  8041604ebf:	ff d0                	callq  *%rax
}
  8041604ec1:	48 83 c4 08          	add    $0x8,%rsp
  8041604ec5:	5b                   	pop    %rbx
  8041604ec6:	41 5c                	pop    %r12
  8041604ec8:	41 5d                	pop    %r13
  8041604eca:	5d                   	pop    %rbp
  8041604ecb:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604ecc:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604ed3:	00 00 00 
  8041604ed6:	be 54 02 00 00       	mov    $0x254,%esi
  8041604edb:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604ee2:	00 00 00 
  8041604ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604eea:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604ef1:	00 00 00 
  8041604ef4:	41 ff d0             	callq  *%r8
  if (create) {
  8041604ef7:	85 d2                	test   %edx,%edx
  8041604ef9:	0f 84 a3 00 00 00    	je     8041604fa2 <pml4e_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604eff:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604f04:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041604f0b:	00 00 00 
  8041604f0e:	ff d0                	callq  *%rax
    if (np) {
  8041604f10:	48 85 c0             	test   %rax,%rax
  8041604f13:	74 ac                	je     8041604ec1 <pml4e_walk+0x66>
      np->pp_ref++;
  8041604f15:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604f1a:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  8041604f21:	00 00 00 
  8041604f24:	48 2b 02             	sub    (%rdx),%rax
  8041604f27:	48 c1 f8 04          	sar    $0x4,%rax
  8041604f2b:	48 c1 e0 0c          	shl    $0xc,%rax
      pml4e[PML4(va)] = page2pa(np) | PTE_P | PTE_U | PTE_W;
  8041604f2f:	48 89 c2             	mov    %rax,%rdx
  8041604f32:	48 83 ca 07          	or     $0x7,%rdx
  8041604f36:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604f3a:	48 89 c1             	mov    %rax,%rcx
  8041604f3d:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604f41:	48 ba 70 00 62 41 80 	movabs $0x8041620070,%rdx
  8041604f48:	00 00 00 
  8041604f4b:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604f4e:	73 24                	jae    8041604f74 <pml4e_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604f50:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604f57:	00 00 00 
  8041604f5a:	48 01 c7             	add    %rax,%rdi
      return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604f5d:	44 89 e2             	mov    %r12d,%edx
  8041604f60:	48 89 de             	mov    %rbx,%rsi
  8041604f63:	48 b8 0a 4d 60 41 80 	movabs $0x8041604d0a,%rax
  8041604f6a:	00 00 00 
  8041604f6d:	ff d0                	callq  *%rax
  8041604f6f:	e9 4d ff ff ff       	jmpq   8041604ec1 <pml4e_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604f74:	48 89 c1             	mov    %rax,%rcx
  8041604f77:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041604f7e:	00 00 00 
  8041604f81:	be 5d 02 00 00       	mov    $0x25d,%esi
  8041604f86:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041604f8d:	00 00 00 
  8041604f90:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f95:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604f9c:	00 00 00 
  8041604f9f:	41 ff d0             	callq  *%r8
  return NULL;
  8041604fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fa7:	e9 15 ff ff ff       	jmpq   8041604ec1 <pml4e_walk+0x66>

0000008041604fac <boot_map_region>:
  for (i = 0; i < size; i += PGSIZE) {
  8041604fac:	48 85 d2             	test   %rdx,%rdx
  8041604faf:	74 72                	je     8041605023 <boot_map_region+0x77>
boot_map_region(pml4e_t *pml4e, uintptr_t va, size_t size, physaddr_t pa, int perm) {
  8041604fb1:	55                   	push   %rbp
  8041604fb2:	48 89 e5             	mov    %rsp,%rbp
  8041604fb5:	41 57                	push   %r15
  8041604fb7:	41 56                	push   %r14
  8041604fb9:	41 55                	push   %r13
  8041604fbb:	41 54                	push   %r12
  8041604fbd:	53                   	push   %rbx
  8041604fbe:	48 83 ec 28          	sub    $0x28,%rsp
  8041604fc2:	44 89 45 bc          	mov    %r8d,-0x44(%rbp)
  8041604fc6:	49 89 ce             	mov    %rcx,%r14
  8041604fc9:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041604fcd:	49 89 f5             	mov    %rsi,%r13
  8041604fd0:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  for (i = 0; i < size; i += PGSIZE) {
  8041604fd4:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    *pml4e_walk(pml4e, (void *)(va + i), 1) = (pa + i) | perm | PTE_P;
  8041604fda:	49 bf 5b 4e 60 41 80 	movabs $0x8041604e5b,%r15
  8041604fe1:	00 00 00 
  8041604fe4:	4b 8d 1c 26          	lea    (%r14,%r12,1),%rbx
  8041604fe8:	48 63 45 bc          	movslq -0x44(%rbp),%rax
  8041604fec:	48 09 c3             	or     %rax,%rbx
  8041604fef:	4b 8d 74 25 00       	lea    0x0(%r13,%r12,1),%rsi
  8041604ff4:	ba 01 00 00 00       	mov    $0x1,%edx
  8041604ff9:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041604ffd:	41 ff d7             	callq  *%r15
  8041605000:	48 83 cb 01          	or     $0x1,%rbx
  8041605004:	48 89 18             	mov    %rbx,(%rax)
  for (i = 0; i < size; i += PGSIZE) {
  8041605007:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  804160500e:	4c 39 65 c0          	cmp    %r12,-0x40(%rbp)
  8041605012:	77 d0                	ja     8041604fe4 <boot_map_region+0x38>
}
  8041605014:	48 83 c4 28          	add    $0x28,%rsp
  8041605018:	5b                   	pop    %rbx
  8041605019:	41 5c                	pop    %r12
  804160501b:	41 5d                	pop    %r13
  804160501d:	41 5e                	pop    %r14
  804160501f:	41 5f                	pop    %r15
  8041605021:	5d                   	pop    %rbp
  8041605022:	c3                   	retq   
  8041605023:	c3                   	retq   

0000008041605024 <page_lookup>:
page_lookup(pml4e_t *pml4e, void *va, pte_t **pte_store) {
  8041605024:	55                   	push   %rbp
  8041605025:	48 89 e5             	mov    %rsp,%rbp
  8041605028:	53                   	push   %rbx
  8041605029:	48 83 ec 08          	sub    $0x8,%rsp
  804160502d:	48 89 d3             	mov    %rdx,%rbx
  ptep = pml4e_walk(pml4e, va, 0);
  8041605030:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605035:	48 b8 5b 4e 60 41 80 	movabs $0x8041604e5b,%rax
  804160503c:	00 00 00 
  804160503f:	ff d0                	callq  *%rax
  if (!ptep) {
  8041605041:	48 85 c0             	test   %rax,%rax
  8041605044:	74 3c                	je     8041605082 <page_lookup+0x5e>
  if (pte_store) {
  8041605046:	48 85 db             	test   %rbx,%rbx
  8041605049:	74 03                	je     804160504e <page_lookup+0x2a>
    *pte_store = ptep;
  804160504b:	48 89 03             	mov    %rax,(%rbx)
  return pa2page(PTE_ADDR(*ptep));
  804160504e:	48 8b 30             	mov    (%rax),%rsi
  8041605051:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
}

static inline struct PageInfo *
pa2page(physaddr_t pa) {
  if (PPN(pa) >= npages) {
  8041605058:	48 89 f0             	mov    %rsi,%rax
  804160505b:	48 c1 e8 0c          	shr    $0xc,%rax
  804160505f:	48 ba 70 00 62 41 80 	movabs $0x8041620070,%rdx
  8041605066:	00 00 00 
  8041605069:	48 3b 02             	cmp    (%rdx),%rax
  804160506c:	73 1b                	jae    8041605089 <page_lookup+0x65>
    cprintf("accessing %lx\n", (unsigned long)pa);
    panic("pa2page called with invalid pa");
  }
  return &pages[PPN(pa)];
  804160506e:	48 c1 e0 04          	shl    $0x4,%rax
  8041605072:	48 b9 78 00 62 41 80 	movabs $0x8041620078,%rcx
  8041605079:	00 00 00 
  804160507c:	48 8b 11             	mov    (%rcx),%rdx
  804160507f:	48 01 d0             	add    %rdx,%rax
}
  8041605082:	48 83 c4 08          	add    $0x8,%rsp
  8041605086:	5b                   	pop    %rbx
  8041605087:	5d                   	pop    %rbp
  8041605088:	c3                   	retq   
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041605089:	48 bf db ca 60 41 80 	movabs $0x804160cadb,%rdi
  8041605090:	00 00 00 
  8041605093:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605098:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160509f:	00 00 00 
  80416050a2:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  80416050a4:	48 ba 40 c2 60 41 80 	movabs $0x804160c240,%rdx
  80416050ab:	00 00 00 
  80416050ae:	be 59 00 00 00       	mov    $0x59,%esi
  80416050b3:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  80416050ba:	00 00 00 
  80416050bd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050c2:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416050c9:	00 00 00 
  80416050cc:	ff d1                	callq  *%rcx

00000080416050ce <page_remove>:
page_remove(pml4e_t *pml4e, void *va) {
  80416050ce:	55                   	push   %rbp
  80416050cf:	48 89 e5             	mov    %rsp,%rbp
  80416050d2:	53                   	push   %rbx
  80416050d3:	48 83 ec 18          	sub    $0x18,%rsp
  80416050d7:	48 89 f3             	mov    %rsi,%rbx
  pp = page_lookup(pml4e, va, &ptep);
  80416050da:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80416050de:	48 b8 24 50 60 41 80 	movabs $0x8041605024,%rax
  80416050e5:	00 00 00 
  80416050e8:	ff d0                	callq  *%rax
  if (pp) {
  80416050ea:	48 85 c0             	test   %rax,%rax
  80416050ed:	74 1d                	je     804160510c <page_remove+0x3e>
    page_decref(pp);
  80416050ef:	48 89 c7             	mov    %rax,%rdi
  80416050f2:	48 b8 9f 4b 60 41 80 	movabs $0x8041604b9f,%rax
  80416050f9:	00 00 00 
  80416050fc:	ff d0                	callq  *%rax
    *ptep = 0;
  80416050fe:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8041605102:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  __asm __volatile("invlpg (%0)"
  8041605109:	0f 01 3b             	invlpg (%rbx)
}
  804160510c:	48 83 c4 18          	add    $0x18,%rsp
  8041605110:	5b                   	pop    %rbx
  8041605111:	5d                   	pop    %rbp
  8041605112:	c3                   	retq   

0000008041605113 <page_insert>:
page_insert(pml4e_t *pml4e, struct PageInfo *pp, void *va, int perm) {
  8041605113:	55                   	push   %rbp
  8041605114:	48 89 e5             	mov    %rsp,%rbp
  8041605117:	41 57                	push   %r15
  8041605119:	41 56                	push   %r14
  804160511b:	41 55                	push   %r13
  804160511d:	41 54                	push   %r12
  804160511f:	53                   	push   %rbx
  8041605120:	48 83 ec 08          	sub    $0x8,%rsp
  8041605124:	49 89 ff             	mov    %rdi,%r15
  8041605127:	49 89 f4             	mov    %rsi,%r12
  804160512a:	49 89 d6             	mov    %rdx,%r14
  804160512d:	41 89 cd             	mov    %ecx,%r13d
  ptep = pml4e_walk(pml4e, va, 1);
  8041605130:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605135:	4c 89 f6             	mov    %r14,%rsi
  8041605138:	48 b8 5b 4e 60 41 80 	movabs $0x8041604e5b,%rax
  804160513f:	00 00 00 
  8041605142:	ff d0                	callq  *%rax
  if (ptep == 0) {
  8041605144:	48 85 c0             	test   %rax,%rax
  8041605147:	0f 84 df 00 00 00    	je     804160522c <page_insert+0x119>
  804160514d:	48 89 c3             	mov    %rax,%rbx
  if (*ptep & PTE_P) {
  8041605150:	48 8b 08             	mov    (%rax),%rcx
  8041605153:	f6 c1 01             	test   $0x1,%cl
  8041605156:	0f 84 90 00 00 00    	je     80416051ec <page_insert+0xd9>
    if (PTE_ADDR(*ptep) == page2pa(pp)) {
  804160515c:	48 89 ca             	mov    %rcx,%rdx
  804160515f:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041605166:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  804160516d:	00 00 00 
  8041605170:	4c 89 e6             	mov    %r12,%rsi
  8041605173:	48 2b 30             	sub    (%rax),%rsi
  8041605176:	48 89 f0             	mov    %rsi,%rax
  8041605179:	48 c1 f8 04          	sar    $0x4,%rax
  804160517d:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605181:	48 39 c2             	cmp    %rax,%rdx
  8041605184:	75 1a                	jne    80416051a0 <page_insert+0x8d>
      *ptep = (*ptep & 0xfffff000) | perm | PTE_P;
  8041605186:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  804160518c:	4d 63 ed             	movslq %r13d,%r13
  804160518f:	4c 09 e9             	or     %r13,%rcx
  8041605192:	48 83 c9 01          	or     $0x1,%rcx
  8041605196:	48 89 0b             	mov    %rcx,(%rbx)
  return 0;
  8041605199:	b8 00 00 00 00       	mov    $0x0,%eax
  804160519e:	eb 7d                	jmp    804160521d <page_insert+0x10a>
      page_remove(pml4e, va);
  80416051a0:	4c 89 f6             	mov    %r14,%rsi
  80416051a3:	4c 89 ff             	mov    %r15,%rdi
  80416051a6:	48 b8 ce 50 60 41 80 	movabs $0x80416050ce,%rax
  80416051ad:	00 00 00 
  80416051b0:	ff d0                	callq  *%rax
  80416051b2:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  80416051b9:	00 00 00 
  80416051bc:	4c 89 e7             	mov    %r12,%rdi
  80416051bf:	48 2b 38             	sub    (%rax),%rdi
  80416051c2:	48 89 f8             	mov    %rdi,%rax
  80416051c5:	48 c1 f8 04          	sar    $0x4,%rax
  80416051c9:	48 c1 e0 0c          	shl    $0xc,%rax
      *ptep = page2pa(pp) | perm | PTE_P;
  80416051cd:	4d 63 ed             	movslq %r13d,%r13
  80416051d0:	49 09 c5             	or     %rax,%r13
  80416051d3:	49 83 cd 01          	or     $0x1,%r13
  80416051d7:	4c 89 2b             	mov    %r13,(%rbx)
      pp->pp_ref++;
  80416051da:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
  80416051e1:	41 0f 01 3e          	invlpg (%r14)
  return 0;
  80416051e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416051ea:	eb 31                	jmp    804160521d <page_insert+0x10a>
  80416051ec:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  80416051f3:	00 00 00 
  80416051f6:	4c 89 e1             	mov    %r12,%rcx
  80416051f9:	48 2b 08             	sub    (%rax),%rcx
  80416051fc:	48 c1 f9 04          	sar    $0x4,%rcx
  8041605200:	48 c1 e1 0c          	shl    $0xc,%rcx
    *ptep = page2pa(pp) | perm | PTE_P;
  8041605204:	4d 63 ed             	movslq %r13d,%r13
  8041605207:	4c 09 e9             	or     %r13,%rcx
  804160520a:	48 83 c9 01          	or     $0x1,%rcx
  804160520e:	48 89 0b             	mov    %rcx,(%rbx)
    pp->pp_ref++;
  8041605211:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
  return 0;
  8041605218:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160521d:	48 83 c4 08          	add    $0x8,%rsp
  8041605221:	5b                   	pop    %rbx
  8041605222:	41 5c                	pop    %r12
  8041605224:	41 5d                	pop    %r13
  8041605226:	41 5e                	pop    %r14
  8041605228:	41 5f                	pop    %r15
  804160522a:	5d                   	pop    %rbp
  804160522b:	c3                   	retq   
    return -E_NO_MEM;
  804160522c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8041605231:	eb ea                	jmp    804160521d <page_insert+0x10a>

0000008041605233 <mem_init>:
mem_init(void) {
  8041605233:	55                   	push   %rbp
  8041605234:	48 89 e5             	mov    %rsp,%rbp
  8041605237:	41 57                	push   %r15
  8041605239:	41 56                	push   %r14
  804160523b:	41 55                	push   %r13
  804160523d:	41 54                	push   %r12
  804160523f:	53                   	push   %rbx
  8041605240:	48 83 ec 38          	sub    $0x38,%rsp
  if (uefi_lp && uefi_lp->MemoryMap) {
  8041605244:	48 a1 00 e0 61 41 80 	movabs 0x804161e000,%rax
  804160524b:	00 00 00 
  804160524e:	48 85 c0             	test   %rax,%rax
  8041605251:	74 0d                	je     8041605260 <mem_init+0x2d>
  8041605253:	48 8b 78 28          	mov    0x28(%rax),%rdi
  8041605257:	48 85 ff             	test   %rdi,%rdi
  804160525a:	0f 85 c4 11 00 00    	jne    8041606424 <mem_init+0x11f1>
    npages_basemem = (mc146818_read16(NVRAM_BASELO) * 1024) / PGSIZE;
  8041605260:	bf 15 00 00 00       	mov    $0x15,%edi
  8041605265:	49 bc 97 88 60 41 80 	movabs $0x8041608897,%r12
  804160526c:	00 00 00 
  804160526f:	41 ff d4             	callq  *%r12
  8041605272:	c1 e0 0a             	shl    $0xa,%eax
  8041605275:	c1 e8 0c             	shr    $0xc,%eax
  8041605278:	48 ba b0 eb 61 41 80 	movabs $0x804161ebb0,%rdx
  804160527f:	00 00 00 
  8041605282:	89 c0                	mov    %eax,%eax
  8041605284:	48 89 02             	mov    %rax,(%rdx)
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  8041605287:	bf 17 00 00 00       	mov    $0x17,%edi
  804160528c:	41 ff d4             	callq  *%r12
  804160528f:	89 c3                	mov    %eax,%ebx
    pextmem        = ((size_t)mc146818_read16(NVRAM_PEXTLO) * 1024 * 64);
  8041605291:	bf 34 00 00 00       	mov    $0x34,%edi
  8041605296:	41 ff d4             	callq  *%r12
  8041605299:	89 c0                	mov    %eax,%eax
    if (pextmem)
  804160529b:	48 c1 e0 10          	shl    $0x10,%rax
  804160529f:	0f 84 f9 11 00 00    	je     804160649e <mem_init+0x126b>
      npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  80416052a5:	48 05 00 00 f0 00    	add    $0xf00000,%rax
  80416052ab:	48 c1 e8 0c          	shr    $0xc,%rax
  80416052af:	48 89 c1             	mov    %rax,%rcx
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  80416052b2:	48 8d b1 00 01 00 00 	lea    0x100(%rcx),%rsi
  80416052b9:	48 89 f0             	mov    %rsi,%rax
  80416052bc:	48 a3 70 00 62 41 80 	movabs %rax,0x8041620070
  80416052c3:	00 00 00 
          (unsigned long)(npages_extmem * PGSIZE / 1024));
  80416052c6:	48 89 c8             	mov    %rcx,%rax
  80416052c9:	48 c1 e0 0c          	shl    $0xc,%rax
  80416052cd:	48 c1 e8 0a          	shr    $0xa,%rax
  80416052d1:	48 89 c1             	mov    %rax,%rcx
          (unsigned long)(npages_basemem * PGSIZE / 1024),
  80416052d4:	48 b8 b0 eb 61 41 80 	movabs $0x804161ebb0,%rax
  80416052db:	00 00 00 
  80416052de:	48 8b 10             	mov    (%rax),%rdx
  80416052e1:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416052e5:	48 c1 ea 0a          	shr    $0xa,%rdx
          (unsigned long)(npages * PGSIZE / 1024 / 1024),
  80416052e9:	48 c1 e6 0c          	shl    $0xc,%rsi
  80416052ed:	48 c1 ee 14          	shr    $0x14,%rsi
  cprintf("Physical memory: %luM available, base = %luK, extended = %luK\n",
  80416052f1:	48 bf 60 c2 60 41 80 	movabs $0x804160c260,%rdi
  80416052f8:	00 00 00 
  80416052fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605300:	49 b8 9c 8a 60 41 80 	movabs $0x8041608a9c,%r8
  8041605307:	00 00 00 
  804160530a:	41 ff d0             	callq  *%r8
  pml4e = boot_alloc(PGSIZE);
  804160530d:	bf 00 10 00 00       	mov    $0x1000,%edi
  8041605312:	48 b8 79 42 60 41 80 	movabs $0x8041604279,%rax
  8041605319:	00 00 00 
  804160531c:	ff d0                	callq  *%rax
  804160531e:	48 89 c3             	mov    %rax,%rbx
  memset(pml4e, 0, PGSIZE);
  8041605321:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605326:	be 00 00 00 00       	mov    $0x0,%esi
  804160532b:	48 89 c7             	mov    %rax,%rdi
  804160532e:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041605335:	00 00 00 
  8041605338:	ff d0                	callq  *%rax
  kern_pml4e = pml4e;
  804160533a:	48 89 d8             	mov    %rbx,%rax
  804160533d:	48 a3 60 00 62 41 80 	movabs %rax,0x8041620060
  8041605344:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  8041605347:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  804160534e:	00 00 00 
  8041605351:	48 39 c3             	cmp    %rax,%rbx
  8041605354:	0f 86 67 11 00 00    	jbe    80416064c1 <mem_init+0x128e>
  return (physaddr_t)kva - KERNBASE;
  804160535a:	48 b8 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rax
  8041605361:	ff ff ff 
  8041605364:	48 01 d8             	add    %rbx,%rax
  kern_cr3   = PADDR(pml4e);
  8041605367:	48 a3 68 00 62 41 80 	movabs %rax,0x8041620068
  804160536e:	00 00 00 
  kern_pml4e[PML4(UVPT)] = kern_cr3 | PTE_P | PTE_U;
  8041605371:	48 83 c8 05          	or     $0x5,%rax
  8041605375:	48 89 43 10          	mov    %rax,0x10(%rbx)
  pages = (struct PageInfo *)boot_alloc(sizeof(*pages) * npages);
  8041605379:	48 bb 70 00 62 41 80 	movabs $0x8041620070,%rbx
  8041605380:	00 00 00 
  8041605383:	8b 3b                	mov    (%rbx),%edi
  8041605385:	c1 e7 04             	shl    $0x4,%edi
  8041605388:	48 b8 79 42 60 41 80 	movabs $0x8041604279,%rax
  804160538f:	00 00 00 
  8041605392:	ff d0                	callq  *%rax
  8041605394:	48 a3 78 00 62 41 80 	movabs %rax,0x8041620078
  804160539b:	00 00 00 
  memset(pages, 0, sizeof(*pages) * npages);
  804160539e:	48 8b 13             	mov    (%rbx),%rdx
  80416053a1:	48 c1 e2 04          	shl    $0x4,%rdx
  80416053a5:	be 00 00 00 00       	mov    $0x0,%esi
  80416053aa:	48 89 c7             	mov    %rax,%rdi
  80416053ad:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  80416053b4:	00 00 00 
  80416053b7:	ff d0                	callq  *%rax
  page_init();
  80416053b9:	48 b8 26 48 60 41 80 	movabs $0x8041604826,%rax
  80416053c0:	00 00 00 
  80416053c3:	ff d0                	callq  *%rax
  check_page_free_list(1);
  80416053c5:	bf 01 00 00 00       	mov    $0x1,%edi
  80416053ca:	48 b8 55 43 60 41 80 	movabs $0x8041604355,%rax
  80416053d1:	00 00 00 
  80416053d4:	ff d0                	callq  *%rax
  void *va;
  int i;
  pp0 = pp1 = pp2 = pp3 = pp4 = pp5 = 0;

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  80416053d6:	48 a1 60 00 62 41 80 	movabs 0x8041620060,%rax
  80416053dd:	00 00 00 
  80416053e0:	48 8b 08             	mov    (%rax),%rcx
  80416053e3:	48 89 4d a8          	mov    %rcx,-0x58(%rbp)
  kern_pml4e[0] = 0;
  80416053e7:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  assert(pp0 = page_alloc(0));
  80416053ee:	bf 00 00 00 00       	mov    $0x0,%edi
  80416053f3:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  80416053fa:	00 00 00 
  80416053fd:	ff d0                	callq  *%rax
  80416053ff:	49 89 c6             	mov    %rax,%r14
  8041605402:	48 85 c0             	test   %rax,%rax
  8041605405:	0f 84 e4 10 00 00    	je     80416064ef <mem_init+0x12bc>
  assert(pp1 = page_alloc(0));
  804160540b:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605410:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605417:	00 00 00 
  804160541a:	ff d0                	callq  *%rax
  804160541c:	49 89 c4             	mov    %rax,%r12
  804160541f:	48 85 c0             	test   %rax,%rax
  8041605422:	0f 84 fc 10 00 00    	je     8041606524 <mem_init+0x12f1>
  assert(pp2 = page_alloc(0));
  8041605428:	bf 00 00 00 00       	mov    $0x0,%edi
  804160542d:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605434:	00 00 00 
  8041605437:	ff d0                	callq  *%rax
  8041605439:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160543d:	48 85 c0             	test   %rax,%rax
  8041605440:	0f 84 13 11 00 00    	je     8041606559 <mem_init+0x1326>
  assert(pp3 = page_alloc(0));
  8041605446:	bf 00 00 00 00       	mov    $0x0,%edi
  804160544b:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605452:	00 00 00 
  8041605455:	ff d0                	callq  *%rax
  8041605457:	49 89 c5             	mov    %rax,%r13
  804160545a:	48 85 c0             	test   %rax,%rax
  804160545d:	0f 84 26 11 00 00    	je     8041606589 <mem_init+0x1356>
  assert(pp4 = page_alloc(0));
  8041605463:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605468:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  804160546f:	00 00 00 
  8041605472:	ff d0                	callq  *%rax
  8041605474:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8041605478:	48 85 c0             	test   %rax,%rax
  804160547b:	0f 84 3d 11 00 00    	je     80416065be <mem_init+0x138b>
  assert(pp5 = page_alloc(0));
  8041605481:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605486:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  804160548d:	00 00 00 
  8041605490:	ff d0                	callq  *%rax
  8041605492:	48 85 c0             	test   %rax,%rax
  8041605495:	0f 84 53 11 00 00    	je     80416065ee <mem_init+0x13bb>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  804160549b:	4d 39 e6             	cmp    %r12,%r14
  804160549e:	0f 84 7a 11 00 00    	je     804160661e <mem_init+0x13eb>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416054a4:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  80416054a8:	49 39 cc             	cmp    %rcx,%r12
  80416054ab:	0f 84 a2 11 00 00    	je     8041606653 <mem_init+0x1420>
  80416054b1:	49 39 ce             	cmp    %rcx,%r14
  80416054b4:	0f 84 99 11 00 00    	je     8041606653 <mem_init+0x1420>
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  80416054ba:	4c 39 6d b8          	cmp    %r13,-0x48(%rbp)
  80416054be:	0f 84 c4 11 00 00    	je     8041606688 <mem_init+0x1455>
  80416054c4:	4d 39 ec             	cmp    %r13,%r12
  80416054c7:	0f 84 bb 11 00 00    	je     8041606688 <mem_init+0x1455>
  80416054cd:	4d 39 ee             	cmp    %r13,%r14
  80416054d0:	0f 84 b2 11 00 00    	je     8041606688 <mem_init+0x1455>
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  80416054d6:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416054da:	49 39 fd             	cmp    %rdi,%r13
  80416054dd:	0f 84 da 11 00 00    	je     80416066bd <mem_init+0x148a>
  80416054e3:	48 39 7d b8          	cmp    %rdi,-0x48(%rbp)
  80416054e7:	0f 94 c1             	sete   %cl
  80416054ea:	49 39 fc             	cmp    %rdi,%r12
  80416054ed:	0f 94 c2             	sete   %dl
  80416054f0:	08 d1                	or     %dl,%cl
  80416054f2:	0f 85 c5 11 00 00    	jne    80416066bd <mem_init+0x148a>
  80416054f8:	49 39 fe             	cmp    %rdi,%r14
  80416054fb:	0f 84 bc 11 00 00    	je     80416066bd <mem_init+0x148a>
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  8041605501:	48 39 45 b0          	cmp    %rax,-0x50(%rbp)
  8041605505:	0f 84 e7 11 00 00    	je     80416066f2 <mem_init+0x14bf>
  804160550b:	49 39 c5             	cmp    %rax,%r13
  804160550e:	0f 84 de 11 00 00    	je     80416066f2 <mem_init+0x14bf>
  8041605514:	48 39 45 b8          	cmp    %rax,-0x48(%rbp)
  8041605518:	0f 84 d4 11 00 00    	je     80416066f2 <mem_init+0x14bf>
  804160551e:	49 39 c4             	cmp    %rax,%r12
  8041605521:	0f 84 cb 11 00 00    	je     80416066f2 <mem_init+0x14bf>
  8041605527:	49 39 c6             	cmp    %rax,%r14
  804160552a:	0f 84 c2 11 00 00    	je     80416066f2 <mem_init+0x14bf>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
  8041605530:	48 a1 a8 eb 61 41 80 	movabs 0x804161eba8,%rax
  8041605537:	00 00 00 
  804160553a:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  assert(fl != NULL);
  804160553e:	48 85 c0             	test   %rax,%rax
  8041605541:	0f 84 e0 11 00 00    	je     8041606727 <mem_init+0x14f4>
  page_free_list = NULL;
  8041605547:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  804160554e:	00 00 00 
  8041605551:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // should be no free memory
  assert(!page_alloc(0));
  8041605558:	bf 00 00 00 00       	mov    $0x0,%edi
  804160555d:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605564:	00 00 00 
  8041605567:	ff d0                	callq  *%rax
  8041605569:	48 85 c0             	test   %rax,%rax
  804160556c:	0f 85 e5 11 00 00    	jne    8041606757 <mem_init+0x1524>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  8041605572:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041605576:	be 00 00 00 00       	mov    $0x0,%esi
  804160557b:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041605582:	00 00 00 
  8041605585:	48 8b 38             	mov    (%rax),%rdi
  8041605588:	48 b8 24 50 60 41 80 	movabs $0x8041605024,%rax
  804160558f:	00 00 00 
  8041605592:	ff d0                	callq  *%rax
  8041605594:	48 85 c0             	test   %rax,%rax
  8041605597:	0f 85 ef 11 00 00    	jne    804160678c <mem_init+0x1559>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  804160559d:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416055a2:	ba 00 00 00 00       	mov    $0x0,%edx
  80416055a7:	4c 89 e6             	mov    %r12,%rsi
  80416055aa:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  80416055b1:	00 00 00 
  80416055b4:	48 8b 38             	mov    (%rax),%rdi
  80416055b7:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  80416055be:	00 00 00 
  80416055c1:	ff d0                	callq  *%rax
  80416055c3:	85 c0                	test   %eax,%eax
  80416055c5:	0f 89 f6 11 00 00    	jns    80416067c1 <mem_init+0x158e>

  cprintf("pp0 ref count before free = %d\n", pp0->pp_ref);
  80416055cb:	41 0f b7 76 08       	movzwl 0x8(%r14),%esi
  80416055d0:	48 bf e8 c3 60 41 80 	movabs $0x804160c3e8,%rdi
  80416055d7:	00 00 00 
  80416055da:	b8 00 00 00 00       	mov    $0x0,%eax
  80416055df:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  80416055e6:	00 00 00 
  80416055e9:	ff d3                	callq  *%rbx
  cprintf("pp1 ref count before free = %d\n", pp1->pp_ref);
  80416055eb:	41 0f b7 74 24 08    	movzwl 0x8(%r12),%esi
  80416055f1:	48 bf 08 c4 60 41 80 	movabs $0x804160c408,%rdi
  80416055f8:	00 00 00 
  80416055fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605600:	ff d3                	callq  *%rbx
  cprintf("pp2 ref count before free = %d\n", pp2->pp_ref);
  8041605602:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605606:	0f b7 70 08          	movzwl 0x8(%rax),%esi
  804160560a:	48 bf 28 c4 60 41 80 	movabs $0x804160c428,%rdi
  8041605611:	00 00 00 
  8041605614:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605619:	ff d3                	callq  *%rbx

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
  804160561b:	4c 89 f7             	mov    %r14,%rdi
  804160561e:	48 b8 06 4b 60 41 80 	movabs $0x8041604b06,%rax
  8041605625:	00 00 00 
  8041605628:	ff d0                	callq  *%rax
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  804160562a:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160562f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605634:	4c 89 e6             	mov    %r12,%rsi
  8041605637:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  804160563e:	00 00 00 
  8041605641:	48 8b 38             	mov    (%rax),%rdi
  8041605644:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  804160564b:	00 00 00 
  804160564e:	ff d0                	callq  *%rax
  8041605650:	85 c0                	test   %eax,%eax
  8041605652:	0f 89 9e 11 00 00    	jns    80416067f6 <mem_init+0x15c3>
  page_free(pp2);
  8041605658:	4c 8b 7d b8          	mov    -0x48(%rbp),%r15
  804160565c:	4c 89 ff             	mov    %r15,%rdi
  804160565f:	48 bb 06 4b 60 41 80 	movabs $0x8041604b06,%rbx
  8041605666:	00 00 00 
  8041605669:	ff d3                	callq  *%rbx
  page_free(pp3);
  804160566b:	4c 89 ef             	mov    %r13,%rdi
  804160566e:	ff d3                	callq  *%rbx

  cprintf("pp0 ref count = %d\n", pp0->pp_ref);
  8041605670:	41 0f b7 76 08       	movzwl 0x8(%r14),%esi
  8041605675:	48 bf 8e cb 60 41 80 	movabs $0x804160cb8e,%rdi
  804160567c:	00 00 00 
  804160567f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605684:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  804160568b:	00 00 00 
  804160568e:	ff d3                	callq  *%rbx
  cprintf("pp1 ref count = %d\n", pp1->pp_ref);
  8041605690:	41 0f b7 74 24 08    	movzwl 0x8(%r12),%esi
  8041605696:	48 bf a2 cb 60 41 80 	movabs $0x804160cba2,%rdi
  804160569d:	00 00 00 
  80416056a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416056a5:	ff d3                	callq  *%rbx
  cprintf("pp2 ref count = %d\n", pp2->pp_ref);
  80416056a7:	41 0f b7 77 08       	movzwl 0x8(%r15),%esi
  80416056ac:	48 bf b6 cb 60 41 80 	movabs $0x804160cbb6,%rdi
  80416056b3:	00 00 00 
  80416056b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416056bb:	ff d3                	callq  *%rbx

  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  80416056bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416056c2:	ba 00 00 00 00       	mov    $0x0,%edx
  80416056c7:	4c 89 e6             	mov    %r12,%rsi
  80416056ca:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  80416056d1:	00 00 00 
  80416056d4:	48 8b 38             	mov    (%rax),%rdi
  80416056d7:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  80416056de:	00 00 00 
  80416056e1:	ff d0                	callq  *%rax
  80416056e3:	85 c0                	test   %eax,%eax
  80416056e5:	0f 85 40 11 00 00    	jne    804160682b <mem_init+0x15f8>
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  80416056eb:	48 a1 60 00 62 41 80 	movabs 0x8041620060,%rax
  80416056f2:	00 00 00 
  80416056f5:	48 8b 10             	mov    (%rax),%rdx
  80416056f8:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  80416056ff:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041605706:	00 00 00 
  8041605709:	48 8b 08             	mov    (%rax),%rcx
  804160570c:	4c 89 f0             	mov    %r14,%rax
  804160570f:	48 29 c8             	sub    %rcx,%rax
  8041605712:	48 c1 f8 04          	sar    $0x4,%rax
  8041605716:	48 c1 e0 0c          	shl    $0xc,%rax
  804160571a:	48 39 c2             	cmp    %rax,%rdx
  804160571d:	74 2b                	je     804160574a <mem_init+0x517>
  804160571f:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605723:	48 29 c8             	sub    %rcx,%rax
  8041605726:	48 c1 f8 04          	sar    $0x4,%rax
  804160572a:	48 c1 e0 0c          	shl    $0xc,%rax
  804160572e:	48 39 c2             	cmp    %rax,%rdx
  8041605731:	74 17                	je     804160574a <mem_init+0x517>
  8041605733:	4c 89 e8             	mov    %r13,%rax
  8041605736:	48 29 c8             	sub    %rcx,%rax
  8041605739:	48 c1 f8 04          	sar    $0x4,%rax
  804160573d:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605741:	48 39 c2             	cmp    %rax,%rdx
  8041605744:	0f 85 16 11 00 00    	jne    8041606860 <mem_init+0x162d>
  804160574a:	4c 89 e6             	mov    %r12,%rsi
  804160574d:	48 29 ce             	sub    %rcx,%rsi
  8041605750:	48 c1 fe 04          	sar    $0x4,%rsi
  8041605754:	48 c1 e6 0c          	shl    $0xc,%rsi

  cprintf("Physical address pp1: %ld\n", page2pa(pp1));
  8041605758:	48 bf ca cb 60 41 80 	movabs $0x804160cbca,%rdi
  804160575f:	00 00 00 
  8041605762:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605767:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160576e:	00 00 00 
  8041605771:	ff d2                	callq  *%rdx

  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  8041605773:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  804160577a:	00 00 00 
  804160577d:	48 8b 18             	mov    (%rax),%rbx
  8041605780:	be 00 00 00 00       	mov    $0x0,%esi
  8041605785:	48 89 df             	mov    %rbx,%rdi
  8041605788:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  804160578f:	00 00 00 
  8041605792:	ff d0                	callq  *%rax
  8041605794:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  804160579b:	00 00 00 
  804160579e:	4c 89 e1             	mov    %r12,%rcx
  80416057a1:	48 2b 0a             	sub    (%rdx),%rcx
  80416057a4:	48 89 ca             	mov    %rcx,%rdx
  80416057a7:	48 c1 fa 04          	sar    $0x4,%rdx
  80416057ab:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416057af:	48 39 d0             	cmp    %rdx,%rax
  80416057b2:	0f 85 dd 10 00 00    	jne    8041606895 <mem_init+0x1662>
  assert(pp1->pp_ref == 1);
  80416057b8:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  80416057bf:	0f 85 05 11 00 00    	jne    80416068ca <mem_init+0x1697>

  //should be able to map pp3 at PGSIZE because pp0 is already allocated for page table
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  80416057c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416057ca:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416057cf:	4c 89 ee             	mov    %r13,%rsi
  80416057d2:	48 89 df             	mov    %rbx,%rdi
  80416057d5:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  80416057dc:	00 00 00 
  80416057df:	ff d0                	callq  *%rax
  80416057e1:	85 c0                	test   %eax,%eax
  80416057e3:	0f 85 16 11 00 00    	jne    80416068ff <mem_init+0x16cc>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416057e9:	be 00 10 00 00       	mov    $0x1000,%esi
  80416057ee:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  80416057f5:	00 00 00 
  80416057f8:	48 8b 38             	mov    (%rax),%rdi
  80416057fb:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605802:	00 00 00 
  8041605805:	ff d0                	callq  *%rax
  8041605807:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  804160580e:	00 00 00 
  8041605811:	4c 89 e9             	mov    %r13,%rcx
  8041605814:	48 2b 0a             	sub    (%rdx),%rcx
  8041605817:	48 89 ca             	mov    %rcx,%rdx
  804160581a:	48 c1 fa 04          	sar    $0x4,%rdx
  804160581e:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605822:	48 39 d0             	cmp    %rdx,%rax
  8041605825:	0f 85 09 11 00 00    	jne    8041606934 <mem_init+0x1701>
  assert(pp3->pp_ref == 2);
  804160582b:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  8041605831:	0f 85 32 11 00 00    	jne    8041606969 <mem_init+0x1736>

  // should be no free memory
  assert(!page_alloc(0));
  8041605837:	bf 00 00 00 00       	mov    $0x0,%edi
  804160583c:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605843:	00 00 00 
  8041605846:	ff d0                	callq  *%rax
  8041605848:	48 85 c0             	test   %rax,%rax
  804160584b:	0f 85 4d 11 00 00    	jne    804160699e <mem_init+0x176b>

  // should be able to map pp3 at PGSIZE because it's already there
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041605851:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605856:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160585b:	4c 89 ee             	mov    %r13,%rsi
  804160585e:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041605865:	00 00 00 
  8041605868:	48 8b 38             	mov    (%rax),%rdi
  804160586b:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  8041605872:	00 00 00 
  8041605875:	ff d0                	callq  *%rax
  8041605877:	85 c0                	test   %eax,%eax
  8041605879:	0f 85 54 11 00 00    	jne    80416069d3 <mem_init+0x17a0>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  804160587f:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605884:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  804160588b:	00 00 00 
  804160588e:	48 8b 38             	mov    (%rax),%rdi
  8041605891:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605898:	00 00 00 
  804160589b:	ff d0                	callq  *%rax
  804160589d:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  80416058a4:	00 00 00 
  80416058a7:	4c 89 e9             	mov    %r13,%rcx
  80416058aa:	48 2b 0a             	sub    (%rdx),%rcx
  80416058ad:	48 89 ca             	mov    %rcx,%rdx
  80416058b0:	48 c1 fa 04          	sar    $0x4,%rdx
  80416058b4:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416058b8:	48 39 d0             	cmp    %rdx,%rax
  80416058bb:	0f 85 47 11 00 00    	jne    8041606a08 <mem_init+0x17d5>
  assert(pp3->pp_ref == 2);
  80416058c1:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  80416058c7:	0f 85 70 11 00 00    	jne    8041606a3d <mem_init+0x180a>

  // pp3 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
  80416058cd:	bf 00 00 00 00       	mov    $0x0,%edi
  80416058d2:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  80416058d9:	00 00 00 
  80416058dc:	ff d0                	callq  *%rax
  80416058de:	48 85 c0             	test   %rax,%rax
  80416058e1:	0f 85 8b 11 00 00    	jne    8041606a72 <mem_init+0x183f>
  // check that pgdir_walk returns a pointer to the pte
  pdpe = KADDR(PTE_ADDR(kern_pml4e[PML4(PGSIZE)]));
  80416058e7:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  80416058ee:	00 00 00 
  80416058f1:	48 8b 38             	mov    (%rax),%rdi
  80416058f4:	48 8b 0f             	mov    (%rdi),%rcx
  80416058f7:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  80416058fe:	48 a1 70 00 62 41 80 	movabs 0x8041620070,%rax
  8041605905:	00 00 00 
  8041605908:	48 89 ca             	mov    %rcx,%rdx
  804160590b:	48 c1 ea 0c          	shr    $0xc,%rdx
  804160590f:	48 39 c2             	cmp    %rax,%rdx
  8041605912:	0f 83 8f 11 00 00    	jae    8041606aa7 <mem_init+0x1874>
  pde  = KADDR(PTE_ADDR(pdpe[PDPE(PGSIZE)]));
  8041605918:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  804160591f:	00 00 00 
  8041605922:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  8041605926:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  804160592d:	48 89 ca             	mov    %rcx,%rdx
  8041605930:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605934:	48 39 d0             	cmp    %rdx,%rax
  8041605937:	0f 86 95 11 00 00    	jbe    8041606ad2 <mem_init+0x189f>
  ptep = KADDR(PTE_ADDR(pde[PDX(PGSIZE)]));
  804160593d:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605944:	00 00 00 
  8041605947:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  804160594b:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605952:	48 89 ca             	mov    %rcx,%rdx
  8041605955:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605959:	48 39 d0             	cmp    %rdx,%rax
  804160595c:	0f 86 9b 11 00 00    	jbe    8041606afd <mem_init+0x18ca>
  return (void *)(pa + KERNBASE);
  8041605962:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041605969:	00 00 00 
  804160596c:	48 01 c1             	add    %rax,%rcx
  804160596f:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  8041605973:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605978:	be 00 10 00 00       	mov    $0x1000,%esi
  804160597d:	48 b8 5b 4e 60 41 80 	movabs $0x8041604e5b,%rax
  8041605984:	00 00 00 
  8041605987:	ff d0                	callq  *%rax
  8041605989:	48 8b 5d c8          	mov    -0x38(%rbp),%rbx
  804160598d:	48 8d 53 08          	lea    0x8(%rbx),%rdx
  8041605991:	48 39 d0             	cmp    %rdx,%rax
  8041605994:	0f 85 8e 11 00 00    	jne    8041606b28 <mem_init+0x18f5>

  // should be able to change permissions too.
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  804160599a:	b9 04 00 00 00       	mov    $0x4,%ecx
  804160599f:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416059a4:	4c 89 ee             	mov    %r13,%rsi
  80416059a7:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  80416059ae:	00 00 00 
  80416059b1:	48 8b 38             	mov    (%rax),%rdi
  80416059b4:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  80416059bb:	00 00 00 
  80416059be:	ff d0                	callq  *%rax
  80416059c0:	85 c0                	test   %eax,%eax
  80416059c2:	0f 85 95 11 00 00    	jne    8041606b5d <mem_init+0x192a>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416059c8:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  80416059cf:	00 00 00 
  80416059d2:	48 8b 18             	mov    (%rax),%rbx
  80416059d5:	be 00 10 00 00       	mov    $0x1000,%esi
  80416059da:	48 89 df             	mov    %rbx,%rdi
  80416059dd:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  80416059e4:	00 00 00 
  80416059e7:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  80416059e9:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  80416059f0:	00 00 00 
  80416059f3:	4c 89 ee             	mov    %r13,%rsi
  80416059f6:	48 2b 32             	sub    (%rdx),%rsi
  80416059f9:	48 89 f2             	mov    %rsi,%rdx
  80416059fc:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605a00:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605a04:	48 39 d0             	cmp    %rdx,%rax
  8041605a07:	0f 85 85 11 00 00    	jne    8041606b92 <mem_init+0x195f>
  assert(pp3->pp_ref == 2);
  8041605a0d:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  8041605a13:	0f 85 ae 11 00 00    	jne    8041606bc7 <mem_init+0x1994>
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041605a19:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605a1e:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605a23:	48 89 df             	mov    %rbx,%rdi
  8041605a26:	48 b8 5b 4e 60 41 80 	movabs $0x8041604e5b,%rax
  8041605a2d:	00 00 00 
  8041605a30:	ff d0                	callq  *%rax
  8041605a32:	f6 00 04             	testb  $0x4,(%rax)
  8041605a35:	0f 84 c1 11 00 00    	je     8041606bfc <mem_init+0x19c9>
  assert(kern_pml4e[0] & PTE_U);
  8041605a3b:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041605a42:	00 00 00 
  8041605a45:	48 8b 38             	mov    (%rax),%rdi
  8041605a48:	f6 07 04             	testb  $0x4,(%rdi)
  8041605a4b:	0f 84 e0 11 00 00    	je     8041606c31 <mem_init+0x19fe>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041605a51:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605a56:	ba 00 00 20 00       	mov    $0x200000,%edx
  8041605a5b:	4c 89 f6             	mov    %r14,%rsi
  8041605a5e:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  8041605a65:	00 00 00 
  8041605a68:	ff d0                	callq  *%rax
  8041605a6a:	85 c0                	test   %eax,%eax
  8041605a6c:	0f 89 f4 11 00 00    	jns    8041606c66 <mem_init+0x1a33>

  // insert pp1 at PGSIZE (replacing pp3)
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605a72:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605a77:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605a7c:	4c 89 e6             	mov    %r12,%rsi
  8041605a7f:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041605a86:	00 00 00 
  8041605a89:	48 8b 38             	mov    (%rax),%rdi
  8041605a8c:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  8041605a93:	00 00 00 
  8041605a96:	ff d0                	callq  *%rax
  8041605a98:	85 c0                	test   %eax,%eax
  8041605a9a:	0f 85 fb 11 00 00    	jne    8041606c9b <mem_init+0x1a68>
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041605aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605aa5:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605aaa:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041605ab1:	00 00 00 
  8041605ab4:	48 8b 38             	mov    (%rax),%rdi
  8041605ab7:	48 b8 5b 4e 60 41 80 	movabs $0x8041604e5b,%rax
  8041605abe:	00 00 00 
  8041605ac1:	ff d0                	callq  *%rax
  8041605ac3:	f6 00 04             	testb  $0x4,(%rax)
  8041605ac6:	0f 85 04 12 00 00    	jne    8041606cd0 <mem_init+0x1a9d>

  // should have pp1 at both 0 and PGSIZE
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041605acc:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041605ad3:	00 00 00 
  8041605ad6:	48 8b 18             	mov    (%rax),%rbx
  8041605ad9:	be 00 00 00 00       	mov    $0x0,%esi
  8041605ade:	48 89 df             	mov    %rbx,%rdi
  8041605ae1:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605ae8:	00 00 00 
  8041605aeb:	ff d0                	callq  *%rax
  8041605aed:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  8041605af4:	00 00 00 
  8041605af7:	4d 89 e7             	mov    %r12,%r15
  8041605afa:	4c 2b 3a             	sub    (%rdx),%r15
  8041605afd:	49 c1 ff 04          	sar    $0x4,%r15
  8041605b01:	49 c1 e7 0c          	shl    $0xc,%r15
  8041605b05:	4c 39 f8             	cmp    %r15,%rax
  8041605b08:	0f 85 f7 11 00 00    	jne    8041606d05 <mem_init+0x1ad2>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605b0e:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b13:	48 89 df             	mov    %rbx,%rdi
  8041605b16:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605b1d:	00 00 00 
  8041605b20:	ff d0                	callq  *%rax
  8041605b22:	49 39 c7             	cmp    %rax,%r15
  8041605b25:	0f 85 0f 12 00 00    	jne    8041606d3a <mem_init+0x1b07>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
  8041605b2b:	66 41 83 7c 24 08 02 	cmpw   $0x2,0x8(%r12)
  8041605b32:	0f 85 37 12 00 00    	jne    8041606d6f <mem_init+0x1b3c>
  assert(pp3->pp_ref == 1);
  8041605b38:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605b3e:	0f 85 60 12 00 00    	jne    8041606da4 <mem_init+0x1b71>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pml4e, 0x0);
  8041605b44:	be 00 00 00 00       	mov    $0x0,%esi
  8041605b49:	48 89 df             	mov    %rbx,%rdi
  8041605b4c:	48 b8 ce 50 60 41 80 	movabs $0x80416050ce,%rax
  8041605b53:	00 00 00 
  8041605b56:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605b58:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041605b5f:	00 00 00 
  8041605b62:	48 8b 18             	mov    (%rax),%rbx
  8041605b65:	be 00 00 00 00       	mov    $0x0,%esi
  8041605b6a:	48 89 df             	mov    %rbx,%rdi
  8041605b6d:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605b74:	00 00 00 
  8041605b77:	ff d0                	callq  *%rax
  8041605b79:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605b7d:	0f 85 56 12 00 00    	jne    8041606dd9 <mem_init+0x1ba6>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605b83:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b88:	48 89 df             	mov    %rbx,%rdi
  8041605b8b:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605b92:	00 00 00 
  8041605b95:	ff d0                	callq  *%rax
  8041605b97:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  8041605b9e:	00 00 00 
  8041605ba1:	4c 89 e6             	mov    %r12,%rsi
  8041605ba4:	48 2b 32             	sub    (%rdx),%rsi
  8041605ba7:	48 89 f2             	mov    %rsi,%rdx
  8041605baa:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605bae:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605bb2:	48 39 d0             	cmp    %rdx,%rax
  8041605bb5:	0f 85 53 12 00 00    	jne    8041606e0e <mem_init+0x1bdb>
  assert(pp1->pp_ref == 1);
  8041605bbb:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041605bc2:	0f 85 7b 12 00 00    	jne    8041606e43 <mem_init+0x1c10>
  assert(pp3->pp_ref == 1);
  8041605bc8:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605bce:	0f 85 a4 12 00 00    	jne    8041606e78 <mem_init+0x1c45>

  // Test re-inserting pp1 at PGSIZE.
  // Thanks to Varun Agrawal for suggesting this test case.
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605bd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605bd9:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605bde:	4c 89 e6             	mov    %r12,%rsi
  8041605be1:	48 89 df             	mov    %rbx,%rdi
  8041605be4:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  8041605beb:	00 00 00 
  8041605bee:	ff d0                	callq  *%rax
  8041605bf0:	89 c3                	mov    %eax,%ebx
  8041605bf2:	85 c0                	test   %eax,%eax
  8041605bf4:	0f 85 b3 12 00 00    	jne    8041606ead <mem_init+0x1c7a>
  assert(pp1->pp_ref);
  8041605bfa:	66 41 83 7c 24 08 00 	cmpw   $0x0,0x8(%r12)
  8041605c01:	0f 84 db 12 00 00    	je     8041606ee2 <mem_init+0x1caf>
  assert(pp1->pp_link == NULL);
  8041605c07:	49 83 3c 24 00       	cmpq   $0x0,(%r12)
  8041605c0c:	0f 85 05 13 00 00    	jne    8041606f17 <mem_init+0x1ce4>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041605c12:	49 bf 60 00 62 41 80 	movabs $0x8041620060,%r15
  8041605c19:	00 00 00 
  8041605c1c:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605c21:	49 8b 3f             	mov    (%r15),%rdi
  8041605c24:	48 b8 ce 50 60 41 80 	movabs $0x80416050ce,%rax
  8041605c2b:	00 00 00 
  8041605c2e:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605c30:	4d 8b 3f             	mov    (%r15),%r15
  8041605c33:	be 00 00 00 00       	mov    $0x0,%esi
  8041605c38:	4c 89 ff             	mov    %r15,%rdi
  8041605c3b:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605c42:	00 00 00 
  8041605c45:	ff d0                	callq  *%rax
  8041605c47:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605c4b:	0f 85 fb 12 00 00    	jne    8041606f4c <mem_init+0x1d19>
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041605c51:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605c56:	4c 89 ff             	mov    %r15,%rdi
  8041605c59:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605c60:	00 00 00 
  8041605c63:	ff d0                	callq  *%rax
  8041605c65:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605c69:	0f 85 12 13 00 00    	jne    8041606f81 <mem_init+0x1d4e>
  assert(pp1->pp_ref == 0);
  8041605c6f:	66 41 83 7c 24 08 00 	cmpw   $0x0,0x8(%r12)
  8041605c76:	0f 85 3a 13 00 00    	jne    8041606fb6 <mem_init+0x1d83>
  assert(pp3->pp_ref == 1);
  8041605c7c:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605c82:	0f 85 63 13 00 00    	jne    8041606feb <mem_init+0x1db8>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

  // forcibly take pp3 back
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041605c88:	49 8b 17             	mov    (%r15),%rdx
  8041605c8b:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  8041605c92:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041605c99:	00 00 00 
  8041605c9c:	48 8b 08             	mov    (%rax),%rcx
  8041605c9f:	4c 89 f0             	mov    %r14,%rax
  8041605ca2:	48 29 c8             	sub    %rcx,%rax
  8041605ca5:	48 c1 f8 04          	sar    $0x4,%rax
  8041605ca9:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605cad:	48 39 c2             	cmp    %rax,%rdx
  8041605cb0:	74 2b                	je     8041605cdd <mem_init+0xaaa>
  8041605cb2:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605cb6:	48 29 c8             	sub    %rcx,%rax
  8041605cb9:	48 c1 f8 04          	sar    $0x4,%rax
  8041605cbd:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605cc1:	48 39 c2             	cmp    %rax,%rdx
  8041605cc4:	74 17                	je     8041605cdd <mem_init+0xaaa>
  8041605cc6:	4c 89 e8             	mov    %r13,%rax
  8041605cc9:	48 29 c8             	sub    %rcx,%rax
  8041605ccc:	48 c1 f8 04          	sar    $0x4,%rax
  8041605cd0:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605cd4:	48 39 c2             	cmp    %rax,%rdx
  8041605cd7:	0f 85 43 13 00 00    	jne    8041607020 <mem_init+0x1ded>
  kern_pml4e[0] = 0;
  8041605cdd:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
  assert(pp3->pp_ref == 1);
  8041605ce4:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605cea:	0f 85 65 13 00 00    	jne    8041607055 <mem_init+0x1e22>
  page_decref(pp3);
  8041605cf0:	4c 89 ef             	mov    %r13,%rdi
  8041605cf3:	49 bd 9f 4b 60 41 80 	movabs $0x8041604b9f,%r13
  8041605cfa:	00 00 00 
  8041605cfd:	41 ff d5             	callq  *%r13
  // check pointer arithmetic in pml4e_walk
  page_decref(pp0);
  8041605d00:	4c 89 f7             	mov    %r14,%rdi
  8041605d03:	41 ff d5             	callq  *%r13
  page_decref(pp2);
  8041605d06:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605d0a:	41 ff d5             	callq  *%r13
  va    = (void *)(PGSIZE * 100);
  ptep  = pml4e_walk(kern_pml4e, va, 1);
  8041605d0d:	49 bd 60 00 62 41 80 	movabs $0x8041620060,%r13
  8041605d14:	00 00 00 
  8041605d17:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605d1c:	be 00 40 06 00       	mov    $0x64000,%esi
  8041605d21:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041605d25:	48 b8 5b 4e 60 41 80 	movabs $0x8041604e5b,%rax
  8041605d2c:	00 00 00 
  8041605d2f:	ff d0                	callq  *%rax
  8041605d31:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  pdpe  = KADDR(PTE_ADDR(kern_pml4e[PML4(va)]));
  8041605d35:	49 8b 55 00          	mov    0x0(%r13),%rdx
  8041605d39:	48 8b 0a             	mov    (%rdx),%rcx
  8041605d3c:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605d43:	48 bf 70 00 62 41 80 	movabs $0x8041620070,%rdi
  8041605d4a:	00 00 00 
  8041605d4d:	48 8b 17             	mov    (%rdi),%rdx
  8041605d50:	48 89 ce             	mov    %rcx,%rsi
  8041605d53:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605d57:	48 39 d6             	cmp    %rdx,%rsi
  8041605d5a:	0f 83 2a 13 00 00    	jae    804160708a <mem_init+0x1e57>
  pde   = KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8041605d60:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605d67:	00 00 00 
  8041605d6a:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605d6e:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605d75:	48 89 ce             	mov    %rcx,%rsi
  8041605d78:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605d7c:	48 39 f2             	cmp    %rsi,%rdx
  8041605d7f:	0f 86 30 13 00 00    	jbe    80416070b5 <mem_init+0x1e82>
  ptep1 = KADDR(PTE_ADDR(pde[PDX(va)]));
  8041605d85:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605d8c:	00 00 00 
  8041605d8f:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605d93:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605d9a:	48 89 ce             	mov    %rcx,%rsi
  8041605d9d:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605da1:	48 39 f2             	cmp    %rsi,%rdx
  8041605da4:	0f 86 36 13 00 00    	jbe    80416070e0 <mem_init+0x1ead>
  assert(ptep == ptep1 + PTX(va));
  8041605daa:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605db1:	00 00 00 
  8041605db4:	48 8d 94 11 20 03 00 	lea    0x320(%rcx,%rdx,1),%rdx
  8041605dbb:	00 
  8041605dbc:	48 39 d0             	cmp    %rdx,%rax
  8041605dbf:	0f 85 46 13 00 00    	jne    804160710b <mem_init+0x1ed8>

  // check that new page tables get cleared
  page_decref(pp4);
  8041605dc5:	4c 8b 7d b0          	mov    -0x50(%rbp),%r15
  8041605dc9:	4c 89 ff             	mov    %r15,%rdi
  8041605dcc:	48 b8 9f 4b 60 41 80 	movabs $0x8041604b9f,%rax
  8041605dd3:	00 00 00 
  8041605dd6:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041605dd8:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041605ddf:	00 00 00 
  8041605de2:	4c 89 ff             	mov    %r15,%rdi
  8041605de5:	48 2b 38             	sub    (%rax),%rdi
  8041605de8:	48 c1 ff 04          	sar    $0x4,%rdi
  8041605dec:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041605df0:	48 89 fa             	mov    %rdi,%rdx
  8041605df3:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605df7:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  8041605dfe:	00 00 00 
  8041605e01:	48 3b 10             	cmp    (%rax),%rdx
  8041605e04:	0f 83 36 13 00 00    	jae    8041607140 <mem_init+0x1f0d>
  return (void *)(pa + KERNBASE);
  8041605e0a:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041605e11:	00 00 00 
  8041605e14:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp4), 0xFF, PGSIZE);
  8041605e17:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605e1c:	be ff 00 00 00       	mov    $0xff,%esi
  8041605e21:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041605e28:	00 00 00 
  8041605e2b:	ff d0                	callq  *%rax
  pml4e_walk(kern_pml4e, 0x0, 1);
  8041605e2d:	49 bd 60 00 62 41 80 	movabs $0x8041620060,%r13
  8041605e34:	00 00 00 
  8041605e37:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605e3c:	be 00 00 00 00       	mov    $0x0,%esi
  8041605e41:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041605e45:	48 b8 5b 4e 60 41 80 	movabs $0x8041604e5b,%rax
  8041605e4c:	00 00 00 
  8041605e4f:	ff d0                	callq  *%rax
  pdpe = KADDR(PTE_ADDR(kern_pml4e[0]));
  8041605e51:	49 8b 55 00          	mov    0x0(%r13),%rdx
  8041605e55:	48 8b 0a             	mov    (%rdx),%rcx
  8041605e58:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605e5f:	48 a1 70 00 62 41 80 	movabs 0x8041620070,%rax
  8041605e66:	00 00 00 
  8041605e69:	48 89 ce             	mov    %rcx,%rsi
  8041605e6c:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605e70:	48 39 c6             	cmp    %rax,%rsi
  8041605e73:	0f 83 f5 12 00 00    	jae    804160716e <mem_init+0x1f3b>
  pde  = KADDR(PTE_ADDR(pdpe[0]));
  8041605e79:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605e80:	00 00 00 
  8041605e83:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605e87:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605e8e:	48 89 ce             	mov    %rcx,%rsi
  8041605e91:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605e95:	48 39 f0             	cmp    %rsi,%rax
  8041605e98:	0f 86 fb 12 00 00    	jbe    8041607199 <mem_init+0x1f66>
  ptep = KADDR(PTE_ADDR(pde[0]));
  8041605e9e:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605ea5:	00 00 00 
  8041605ea8:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605eac:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605eb3:	48 89 ce             	mov    %rcx,%rsi
  8041605eb6:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605eba:	48 39 f0             	cmp    %rsi,%rax
  8041605ebd:	0f 86 01 13 00 00    	jbe    80416071c4 <mem_init+0x1f91>
  return (void *)(pa + KERNBASE);
  8041605ec3:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041605eca:	00 00 00 
  8041605ecd:	48 01 c8             	add    %rcx,%rax
  8041605ed0:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
  8041605ed4:	f6 00 01             	testb  $0x1,(%rax)
  8041605ed7:	0f 85 12 13 00 00    	jne    80416071ef <mem_init+0x1fbc>
  8041605edd:	48 b8 08 00 00 40 80 	movabs $0x8040000008,%rax
  8041605ee4:	00 00 00 
  8041605ee7:	48 01 c8             	add    %rcx,%rax
  8041605eea:	48 be 00 10 00 40 80 	movabs $0x8040001000,%rsi
  8041605ef1:	00 00 00 
  8041605ef4:	48 01 f1             	add    %rsi,%rcx
  8041605ef7:	4c 8b 28             	mov    (%rax),%r13
  8041605efa:	41 83 e5 01          	and    $0x1,%r13d
  8041605efe:	0f 85 eb 12 00 00    	jne    80416071ef <mem_init+0x1fbc>
  for (i = 0; i < NPTENTRIES; i++)
  8041605f04:	48 83 c0 08          	add    $0x8,%rax
  8041605f08:	48 39 c8             	cmp    %rcx,%rax
  8041605f0b:	75 ea                	jne    8041605ef7 <mem_init+0xcc4>
  kern_pml4e[0] = 0;
  8041605f0d:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)

  // give free list back
  page_free_list = fl;
  8041605f14:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041605f18:	48 a3 a8 eb 61 41 80 	movabs %rax,0x804161eba8
  8041605f1f:	00 00 00 

  // free the pages we took
  page_decref(pp0);
  8041605f22:	4c 89 f7             	mov    %r14,%rdi
  8041605f25:	49 be 9f 4b 60 41 80 	movabs $0x8041604b9f,%r14
  8041605f2c:	00 00 00 
  8041605f2f:	41 ff d6             	callq  *%r14
  page_decref(pp1);
  8041605f32:	4c 89 e7             	mov    %r12,%rdi
  8041605f35:	41 ff d6             	callq  *%r14
  page_decref(pp2);
  8041605f38:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605f3c:	41 ff d6             	callq  *%r14

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041605f3f:	48 a1 60 00 62 41 80 	movabs 0x8041620060,%rax
  8041605f46:	00 00 00 
  8041605f49:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8041605f4d:	48 89 08             	mov    %rcx,(%rax)

  cprintf("check_page() succeeded!\n");
  8041605f50:	48 bf a0 cc 60 41 80 	movabs $0x804160cca0,%rdi
  8041605f57:	00 00 00 
  8041605f5a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605f5f:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041605f66:	00 00 00 
  8041605f69:	ff d2                	callq  *%rdx
  if (!pages)
  8041605f6b:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041605f72:	00 00 00 
  8041605f75:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041605f79:	0f 84 a5 12 00 00    	je     8041607224 <mem_init+0x1ff1>
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605f7f:	48 a1 a8 eb 61 41 80 	movabs 0x804161eba8,%rax
  8041605f86:	00 00 00 
  8041605f89:	48 85 c0             	test   %rax,%rax
  8041605f8c:	74 0b                	je     8041605f99 <mem_init+0xd66>
    ++nfree;
  8041605f8e:	83 c3 01             	add    $0x1,%ebx
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605f91:	48 8b 00             	mov    (%rax),%rax
  8041605f94:	48 85 c0             	test   %rax,%rax
  8041605f97:	75 f5                	jne    8041605f8e <mem_init+0xd5b>
  assert((pp0 = page_alloc(0)));
  8041605f99:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605f9e:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605fa5:	00 00 00 
  8041605fa8:	ff d0                	callq  *%rax
  8041605faa:	49 89 c7             	mov    %rax,%r15
  8041605fad:	48 85 c0             	test   %rax,%rax
  8041605fb0:	0f 84 98 12 00 00    	je     804160724e <mem_init+0x201b>
  assert((pp1 = page_alloc(0)));
  8041605fb6:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605fbb:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605fc2:	00 00 00 
  8041605fc5:	ff d0                	callq  *%rax
  8041605fc7:	49 89 c6             	mov    %rax,%r14
  8041605fca:	48 85 c0             	test   %rax,%rax
  8041605fcd:	0f 84 b0 12 00 00    	je     8041607283 <mem_init+0x2050>
  assert((pp2 = page_alloc(0)));
  8041605fd3:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605fd8:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041605fdf:	00 00 00 
  8041605fe2:	ff d0                	callq  *%rax
  8041605fe4:	49 89 c4             	mov    %rax,%r12
  8041605fe7:	48 85 c0             	test   %rax,%rax
  8041605fea:	0f 84 c8 12 00 00    	je     80416072b8 <mem_init+0x2085>
  assert(pp1 && pp1 != pp0);
  8041605ff0:	4d 39 f7             	cmp    %r14,%r15
  8041605ff3:	0f 84 f4 12 00 00    	je     80416072ed <mem_init+0x20ba>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041605ff9:	49 39 c7             	cmp    %rax,%r15
  8041605ffc:	0f 84 20 13 00 00    	je     8041607322 <mem_init+0x20ef>
  8041606002:	49 39 c6             	cmp    %rax,%r14
  8041606005:	0f 84 17 13 00 00    	je     8041607322 <mem_init+0x20ef>
  return (pp - pages) << PGSHIFT;
  804160600b:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041606012:	00 00 00 
  8041606015:	48 8b 08             	mov    (%rax),%rcx
  assert(page2pa(pp0) < npages * PGSIZE);
  8041606018:	48 a1 70 00 62 41 80 	movabs 0x8041620070,%rax
  804160601f:	00 00 00 
  8041606022:	48 c1 e0 0c          	shl    $0xc,%rax
  8041606026:	4c 89 fa             	mov    %r15,%rdx
  8041606029:	48 29 ca             	sub    %rcx,%rdx
  804160602c:	48 c1 fa 04          	sar    $0x4,%rdx
  8041606030:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041606034:	48 39 c2             	cmp    %rax,%rdx
  8041606037:	0f 83 1a 13 00 00    	jae    8041607357 <mem_init+0x2124>
  804160603d:	4c 89 f2             	mov    %r14,%rdx
  8041606040:	48 29 ca             	sub    %rcx,%rdx
  8041606043:	48 c1 fa 04          	sar    $0x4,%rdx
  8041606047:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp1) < npages * PGSIZE);
  804160604b:	48 39 d0             	cmp    %rdx,%rax
  804160604e:	0f 86 38 13 00 00    	jbe    804160738c <mem_init+0x2159>
  8041606054:	4c 89 e2             	mov    %r12,%rdx
  8041606057:	48 29 ca             	sub    %rcx,%rdx
  804160605a:	48 c1 fa 04          	sar    $0x4,%rdx
  804160605e:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp2) < npages * PGSIZE);
  8041606062:	48 39 d0             	cmp    %rdx,%rax
  8041606065:	0f 86 56 13 00 00    	jbe    80416073c1 <mem_init+0x218e>
  fl             = page_free_list;
  804160606b:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  8041606072:	00 00 00 
  8041606075:	48 8b 08             	mov    (%rax),%rcx
  8041606078:	48 89 4d b8          	mov    %rcx,-0x48(%rbp)
  page_free_list = 0;
  804160607c:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  assert(!page_alloc(0));
  8041606083:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606088:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  804160608f:	00 00 00 
  8041606092:	ff d0                	callq  *%rax
  8041606094:	48 85 c0             	test   %rax,%rax
  8041606097:	0f 85 59 13 00 00    	jne    80416073f6 <mem_init+0x21c3>
  page_free(pp0);
  804160609d:	4c 89 ff             	mov    %r15,%rdi
  80416060a0:	49 bf 06 4b 60 41 80 	movabs $0x8041604b06,%r15
  80416060a7:	00 00 00 
  80416060aa:	41 ff d7             	callq  *%r15
  page_free(pp1);
  80416060ad:	4c 89 f7             	mov    %r14,%rdi
  80416060b0:	41 ff d7             	callq  *%r15
  page_free(pp2);
  80416060b3:	4c 89 e7             	mov    %r12,%rdi
  80416060b6:	41 ff d7             	callq  *%r15
  assert((pp0 = page_alloc(0)));
  80416060b9:	bf 00 00 00 00       	mov    $0x0,%edi
  80416060be:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  80416060c5:	00 00 00 
  80416060c8:	ff d0                	callq  *%rax
  80416060ca:	49 89 c4             	mov    %rax,%r12
  80416060cd:	48 85 c0             	test   %rax,%rax
  80416060d0:	0f 84 55 13 00 00    	je     804160742b <mem_init+0x21f8>
  assert((pp1 = page_alloc(0)));
  80416060d6:	bf 00 00 00 00       	mov    $0x0,%edi
  80416060db:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  80416060e2:	00 00 00 
  80416060e5:	ff d0                	callq  *%rax
  80416060e7:	49 89 c7             	mov    %rax,%r15
  80416060ea:	48 85 c0             	test   %rax,%rax
  80416060ed:	0f 84 6d 13 00 00    	je     8041607460 <mem_init+0x222d>
  assert((pp2 = page_alloc(0)));
  80416060f3:	bf 00 00 00 00       	mov    $0x0,%edi
  80416060f8:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  80416060ff:	00 00 00 
  8041606102:	ff d0                	callq  *%rax
  8041606104:	49 89 c6             	mov    %rax,%r14
  8041606107:	48 85 c0             	test   %rax,%rax
  804160610a:	0f 84 85 13 00 00    	je     8041607495 <mem_init+0x2262>
  assert(pp1 && pp1 != pp0);
  8041606110:	4d 39 fc             	cmp    %r15,%r12
  8041606113:	0f 84 b1 13 00 00    	je     80416074ca <mem_init+0x2297>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041606119:	49 39 c7             	cmp    %rax,%r15
  804160611c:	0f 84 dd 13 00 00    	je     80416074ff <mem_init+0x22cc>
  8041606122:	49 39 c4             	cmp    %rax,%r12
  8041606125:	0f 84 d4 13 00 00    	je     80416074ff <mem_init+0x22cc>
  assert(!page_alloc(0));
  804160612b:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606130:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041606137:	00 00 00 
  804160613a:	ff d0                	callq  *%rax
  804160613c:	48 85 c0             	test   %rax,%rax
  804160613f:	0f 85 ef 13 00 00    	jne    8041607534 <mem_init+0x2301>
  8041606145:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  804160614c:	00 00 00 
  804160614f:	4c 89 e7             	mov    %r12,%rdi
  8041606152:	48 2b 38             	sub    (%rax),%rdi
  8041606155:	48 c1 ff 04          	sar    $0x4,%rdi
  8041606159:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  804160615d:	48 89 fa             	mov    %rdi,%rdx
  8041606160:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041606164:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  804160616b:	00 00 00 
  804160616e:	48 3b 10             	cmp    (%rax),%rdx
  8041606171:	0f 83 f2 13 00 00    	jae    8041607569 <mem_init+0x2336>
  return (void *)(pa + KERNBASE);
  8041606177:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  804160617e:	00 00 00 
  8041606181:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp0), 1, PGSIZE);
  8041606184:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041606189:	be 01 00 00 00       	mov    $0x1,%esi
  804160618e:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041606195:	00 00 00 
  8041606198:	ff d0                	callq  *%rax
  page_free(pp0);
  804160619a:	4c 89 e7             	mov    %r12,%rdi
  804160619d:	48 b8 06 4b 60 41 80 	movabs $0x8041604b06,%rax
  80416061a4:	00 00 00 
  80416061a7:	ff d0                	callq  *%rax
  assert((pp = page_alloc(ALLOC_ZERO)));
  80416061a9:	bf 01 00 00 00       	mov    $0x1,%edi
  80416061ae:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  80416061b5:	00 00 00 
  80416061b8:	ff d0                	callq  *%rax
  80416061ba:	48 85 c0             	test   %rax,%rax
  80416061bd:	0f 84 d4 13 00 00    	je     8041607597 <mem_init+0x2364>
  assert(pp && pp0 == pp);
  80416061c3:	49 39 c4             	cmp    %rax,%r12
  80416061c6:	0f 85 fb 13 00 00    	jne    80416075c7 <mem_init+0x2394>
  return (pp - pages) << PGSHIFT;
  80416061cc:	48 ba 78 00 62 41 80 	movabs $0x8041620078,%rdx
  80416061d3:	00 00 00 
  80416061d6:	48 2b 02             	sub    (%rdx),%rax
  80416061d9:	48 89 c1             	mov    %rax,%rcx
  80416061dc:	48 c1 f9 04          	sar    $0x4,%rcx
  80416061e0:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  80416061e4:	48 89 ca             	mov    %rcx,%rdx
  80416061e7:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416061eb:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  80416061f2:	00 00 00 
  80416061f5:	48 3b 10             	cmp    (%rax),%rdx
  80416061f8:	0f 83 fe 13 00 00    	jae    80416075fc <mem_init+0x23c9>
    assert(c[i] == 0);
  80416061fe:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041606205:	00 00 00 
  8041606208:	80 3c 01 00          	cmpb   $0x0,(%rcx,%rax,1)
  804160620c:	0f 85 15 14 00 00    	jne    8041607627 <mem_init+0x23f4>
  8041606212:	48 8d 40 01          	lea    0x1(%rax),%rax
  8041606216:	48 01 c8             	add    %rcx,%rax
  8041606219:	48 ba 00 10 00 40 80 	movabs $0x8040001000,%rdx
  8041606220:	00 00 00 
  8041606223:	48 01 d1             	add    %rdx,%rcx
  8041606226:	80 38 00             	cmpb   $0x0,(%rax)
  8041606229:	0f 85 f8 13 00 00    	jne    8041607627 <mem_init+0x23f4>
  for (i = 0; i < PGSIZE; i++)
  804160622f:	48 83 c0 01          	add    $0x1,%rax
  8041606233:	48 39 c8             	cmp    %rcx,%rax
  8041606236:	75 ee                	jne    8041606226 <mem_init+0xff3>
  page_free_list = fl;
  8041606238:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  804160623f:	00 00 00 
  8041606242:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041606246:	48 89 38             	mov    %rdi,(%rax)
  page_free(pp0);
  8041606249:	4c 89 e7             	mov    %r12,%rdi
  804160624c:	49 bc 06 4b 60 41 80 	movabs $0x8041604b06,%r12
  8041606253:	00 00 00 
  8041606256:	41 ff d4             	callq  *%r12
  page_free(pp1);
  8041606259:	4c 89 ff             	mov    %r15,%rdi
  804160625c:	41 ff d4             	callq  *%r12
  page_free(pp2);
  804160625f:	4c 89 f7             	mov    %r14,%rdi
  8041606262:	41 ff d4             	callq  *%r12
  for (pp = page_free_list; pp; pp = pp->pp_link)
  8041606265:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  804160626c:	00 00 00 
  804160626f:	48 8b 00             	mov    (%rax),%rax
  8041606272:	48 85 c0             	test   %rax,%rax
  8041606275:	74 0b                	je     8041606282 <mem_init+0x104f>
    --nfree;
  8041606277:	83 eb 01             	sub    $0x1,%ebx
  for (pp = page_free_list; pp; pp = pp->pp_link)
  804160627a:	48 8b 00             	mov    (%rax),%rax
  804160627d:	48 85 c0             	test   %rax,%rax
  8041606280:	75 f5                	jne    8041606277 <mem_init+0x1044>
  assert(nfree == 0);
  8041606282:	85 db                	test   %ebx,%ebx
  8041606284:	0f 85 d2 13 00 00    	jne    804160765c <mem_init+0x2429>
  cprintf("check_page_alloc() succeeded!\n");
  804160628a:	48 bf 00 c8 60 41 80 	movabs $0x804160c800,%rdi
  8041606291:	00 00 00 
  8041606294:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606299:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416062a0:	00 00 00 
  80416062a3:	ff d2                	callq  *%rdx
  boot_map_region(kern_pml4e, UPAGES, ROUNDUP(npages * sizeof(*pages), PGSIZE), PADDR(pages), PTE_U | PTE_P);
  80416062a5:	48 a1 78 00 62 41 80 	movabs 0x8041620078,%rax
  80416062ac:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  80416062af:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  80416062b6:	00 00 00 
  80416062b9:	48 39 d0             	cmp    %rdx,%rax
  80416062bc:	0f 86 cf 13 00 00    	jbe    8041607691 <mem_init+0x245e>
  return (physaddr_t)kva - KERNBASE;
  80416062c2:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  80416062c9:	ff ff ff 
  80416062cc:	48 01 c1             	add    %rax,%rcx
  80416062cf:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  80416062d6:	00 00 00 
  80416062d9:	48 8b 10             	mov    (%rax),%rdx
  80416062dc:	48 c1 e2 04          	shl    $0x4,%rdx
  80416062e0:	48 81 c2 ff 0f 00 00 	add    $0xfff,%rdx
  80416062e7:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  80416062ee:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  80416062f4:	48 be 00 e0 42 3c 80 	movabs $0x803c42e000,%rsi
  80416062fb:	00 00 00 
  80416062fe:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041606305:	00 00 00 
  8041606308:	48 8b 38             	mov    (%rax),%rdi
  804160630b:	48 b8 ac 4f 60 41 80 	movabs $0x8041604fac,%rax
  8041606312:	00 00 00 
  8041606315:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041606317:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  804160631e:	00 00 00 
  8041606321:	48 bb 00 e0 60 41 80 	movabs $0x804160e000,%rbx
  8041606328:	00 00 00 
  804160632b:	48 39 c3             	cmp    %rax,%rbx
  804160632e:	0f 86 8b 13 00 00    	jbe    80416076bf <mem_init+0x248c>
  return (physaddr_t)kva - KERNBASE;
  8041606334:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  804160633b:	ff ff ff 
  804160633e:	48 b8 00 e0 60 41 80 	movabs $0x804160e000,%rax
  8041606345:	00 00 00 
  8041606348:	49 01 c6             	add    %rax,%r14
  boot_map_region(kern_pml4e, KSTACKTOP - KSTKSIZE, KSTACKTOP - (KSTACKTOP - KSTKSIZE), PADDR(bootstack), PTE_W | PTE_P);
  804160634b:	49 bc 60 00 62 41 80 	movabs $0x8041620060,%r12
  8041606352:	00 00 00 
  8041606355:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  804160635b:	4c 89 f1             	mov    %r14,%rcx
  804160635e:	ba 00 00 01 00       	mov    $0x10000,%edx
  8041606363:	48 be 00 00 ff 3f 80 	movabs $0x803fff0000,%rsi
  804160636a:	00 00 00 
  804160636d:	49 8b 3c 24          	mov    (%r12),%rdi
  8041606371:	48 bb ac 4f 60 41 80 	movabs $0x8041604fac,%rbx
  8041606378:	00 00 00 
  804160637b:	ff d3                	callq  *%rbx
  boot_map_region(kern_pml4e, X86ADDR(KSTACKTOP - KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
  804160637d:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606383:	4c 89 f1             	mov    %r14,%rcx
  8041606386:	ba 00 00 01 00       	mov    $0x10000,%edx
  804160638b:	be 00 00 ff 3f       	mov    $0x3fff0000,%esi
  8041606390:	49 8b 3c 24          	mov    (%r12),%rdi
  8041606394:	ff d3                	callq  *%rbx
  boot_map_region(kern_pml4e, KERNBASE, npages * PGSIZE, 0, PTE_P | PTE_W);
  8041606396:	49 be 70 00 62 41 80 	movabs $0x8041620070,%r14
  804160639d:	00 00 00 
  80416063a0:	49 8b 16             	mov    (%r14),%rdx
  80416063a3:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416063a7:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416063ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416063b2:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  80416063b9:	00 00 00 
  80416063bc:	49 8b 3c 24          	mov    (%r12),%rdi
  80416063c0:	ff d3                	callq  *%rbx
  size_to_alloc = MIN(0x3200000, npages * PGSIZE);
  80416063c2:	49 8b 16             	mov    (%r14),%rdx
  80416063c5:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416063c9:	48 81 fa 00 00 20 03 	cmp    $0x3200000,%rdx
  80416063d0:	b8 00 00 20 03       	mov    $0x3200000,%eax
  80416063d5:	48 0f 47 d0          	cmova  %rax,%rdx
  boot_map_region(kern_pml4e, X86ADDR(KERNBASE), size_to_alloc, 0, PTE_P | PTE_W);
  80416063d9:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416063df:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416063e4:	be 00 00 00 40       	mov    $0x40000000,%esi
  80416063e9:	49 8b 3c 24          	mov    (%r12),%rdi
  80416063ed:	ff d3                	callq  *%rbx
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416063ef:	48 b8 90 eb 61 41 80 	movabs $0x804161eb90,%rax
  80416063f6:	00 00 00 
  80416063f9:	48 8b 18             	mov    (%rax),%rbx
  80416063fc:	48 b8 88 eb 61 41 80 	movabs $0x804161eb88,%rax
  8041606403:	00 00 00 
  8041606406:	48 3b 18             	cmp    (%rax),%rbx
  8041606409:	0f 83 1b 13 00 00    	jae    804160772a <mem_init+0x24f7>
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  804160640f:	4d 89 e7             	mov    %r12,%r15
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606412:	49 be 80 eb 61 41 80 	movabs $0x804161eb80,%r14
  8041606419:	00 00 00 
  804160641c:	49 89 c4             	mov    %rax,%r12
  804160641f:	e9 d8 12 00 00       	jmpq   80416076fc <mem_init+0x24c9>
  mem_map_size     = desc->MemoryMapDescriptorSize;
  8041606424:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8041606428:	48 89 c3             	mov    %rax,%rbx
  804160642b:	48 89 f0             	mov    %rsi,%rax
  804160642e:	48 a3 80 eb 61 41 80 	movabs %rax,0x804161eb80
  8041606435:	00 00 00 
  mmap_base        = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)desc->MemoryMap;
  8041606438:	48 89 fa             	mov    %rdi,%rdx
  804160643b:	48 89 f8             	mov    %rdi,%rax
  804160643e:	48 a3 90 eb 61 41 80 	movabs %rax,0x804161eb90
  8041606445:	00 00 00 
  mmap_end         = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)desc->MemoryMap + desc->MemoryMapSize);
  8041606448:	48 89 f9             	mov    %rdi,%rcx
  804160644b:	48 03 4b 38          	add    0x38(%rbx),%rcx
  804160644f:	48 89 c8             	mov    %rcx,%rax
  8041606452:	48 a3 88 eb 61 41 80 	movabs %rax,0x804161eb88
  8041606459:	00 00 00 
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  804160645c:	48 39 cf             	cmp    %rcx,%rdi
  804160645f:	73 36                	jae    8041606497 <mem_init+0x1264>
  size_t num_pages = 0;
  8041606461:	bf 00 00 00 00       	mov    $0x0,%edi
    num_pages += mmap_curr->NumberOfPages;
  8041606466:	48 03 7a 18          	add    0x18(%rdx),%rdi
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  804160646a:	48 01 f2             	add    %rsi,%rdx
  804160646d:	48 39 d1             	cmp    %rdx,%rcx
  8041606470:	77 f4                	ja     8041606466 <mem_init+0x1233>
  *npages_basemem = num_pages > (IOPHYSMEM / PGSIZE) ? IOPHYSMEM / PGSIZE : num_pages;
  8041606472:	48 81 ff a0 00 00 00 	cmp    $0xa0,%rdi
  8041606479:	ba a0 00 00 00       	mov    $0xa0,%edx
  804160647e:	48 0f 46 d7          	cmovbe %rdi,%rdx
  8041606482:	48 89 d0             	mov    %rdx,%rax
  8041606485:	48 a3 b0 eb 61 41 80 	movabs %rax,0x804161ebb0
  804160648c:	00 00 00 
  *npages_extmem  = num_pages - *npages_basemem;
  804160648f:	48 29 d7             	sub    %rdx,%rdi
  8041606492:	48 89 f9             	mov    %rdi,%rcx
  8041606495:	eb 0f                	jmp    80416064a6 <mem_init+0x1273>
  size_t num_pages = 0;
  8041606497:	bf 00 00 00 00       	mov    $0x0,%edi
  804160649c:	eb d4                	jmp    8041606472 <mem_init+0x123f>
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  804160649e:	c1 e3 0a             	shl    $0xa,%ebx
  80416064a1:	c1 eb 0c             	shr    $0xc,%ebx
  80416064a4:	89 d9                	mov    %ebx,%ecx
    npages = npages_basemem;
  80416064a6:	48 b8 b0 eb 61 41 80 	movabs $0x804161ebb0,%rax
  80416064ad:	00 00 00 
  80416064b0:	48 8b 30             	mov    (%rax),%rsi
  if (npages_extmem)
  80416064b3:	48 85 c9             	test   %rcx,%rcx
  80416064b6:	0f 84 fd ed ff ff    	je     80416052b9 <mem_init+0x86>
  80416064bc:	e9 f1 ed ff ff       	jmpq   80416052b2 <mem_init+0x7f>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416064c1:	48 89 d9             	mov    %rbx,%rcx
  80416064c4:	48 ba d8 c0 60 41 80 	movabs $0x804160c0d8,%rdx
  80416064cb:	00 00 00 
  80416064ce:	be e4 00 00 00       	mov    $0xe4,%esi
  80416064d3:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416064da:	00 00 00 
  80416064dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416064e2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416064e9:	00 00 00 
  80416064ec:	41 ff d0             	callq  *%r8
  assert(pp0 = page_alloc(0));
  80416064ef:	48 b9 ea ca 60 41 80 	movabs $0x804160caea,%rcx
  80416064f6:	00 00 00 
  80416064f9:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606500:	00 00 00 
  8041606503:	be 42 04 00 00       	mov    $0x442,%esi
  8041606508:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160650f:	00 00 00 
  8041606512:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606517:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160651e:	00 00 00 
  8041606521:	41 ff d0             	callq  *%r8
  assert(pp1 = page_alloc(0));
  8041606524:	48 b9 fe ca 60 41 80 	movabs $0x804160cafe,%rcx
  804160652b:	00 00 00 
  804160652e:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606535:	00 00 00 
  8041606538:	be 43 04 00 00       	mov    $0x443,%esi
  804160653d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606544:	00 00 00 
  8041606547:	b8 00 00 00 00       	mov    $0x0,%eax
  804160654c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606553:	00 00 00 
  8041606556:	41 ff d0             	callq  *%r8
  assert(pp2 = page_alloc(0));
  8041606559:	48 b9 12 cb 60 41 80 	movabs $0x804160cb12,%rcx
  8041606560:	00 00 00 
  8041606563:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160656a:	00 00 00 
  804160656d:	be 44 04 00 00       	mov    $0x444,%esi
  8041606572:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606579:	00 00 00 
  804160657c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606583:	00 00 00 
  8041606586:	41 ff d0             	callq  *%r8
  assert(pp3 = page_alloc(0));
  8041606589:	48 b9 26 cb 60 41 80 	movabs $0x804160cb26,%rcx
  8041606590:	00 00 00 
  8041606593:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160659a:	00 00 00 
  804160659d:	be 45 04 00 00       	mov    $0x445,%esi
  80416065a2:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416065a9:	00 00 00 
  80416065ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416065b1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065b8:	00 00 00 
  80416065bb:	41 ff d0             	callq  *%r8
  assert(pp4 = page_alloc(0));
  80416065be:	48 b9 3a cb 60 41 80 	movabs $0x804160cb3a,%rcx
  80416065c5:	00 00 00 
  80416065c8:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416065cf:	00 00 00 
  80416065d2:	be 46 04 00 00       	mov    $0x446,%esi
  80416065d7:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416065de:	00 00 00 
  80416065e1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065e8:	00 00 00 
  80416065eb:	41 ff d0             	callq  *%r8
  assert(pp5 = page_alloc(0));
  80416065ee:	48 b9 4e cb 60 41 80 	movabs $0x804160cb4e,%rcx
  80416065f5:	00 00 00 
  80416065f8:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416065ff:	00 00 00 
  8041606602:	be 47 04 00 00       	mov    $0x447,%esi
  8041606607:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160660e:	00 00 00 
  8041606611:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606618:	00 00 00 
  804160661b:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  804160661e:	48 b9 62 cb 60 41 80 	movabs $0x804160cb62,%rcx
  8041606625:	00 00 00 
  8041606628:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160662f:	00 00 00 
  8041606632:	be 4a 04 00 00       	mov    $0x44a,%esi
  8041606637:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160663e:	00 00 00 
  8041606641:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606646:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160664d:	00 00 00 
  8041606650:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041606653:	48 b9 a0 c2 60 41 80 	movabs $0x804160c2a0,%rcx
  804160665a:	00 00 00 
  804160665d:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606664:	00 00 00 
  8041606667:	be 4b 04 00 00       	mov    $0x44b,%esi
  804160666c:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606673:	00 00 00 
  8041606676:	b8 00 00 00 00       	mov    $0x0,%eax
  804160667b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606682:	00 00 00 
  8041606685:	41 ff d0             	callq  *%r8
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  8041606688:	48 b9 c0 c2 60 41 80 	movabs $0x804160c2c0,%rcx
  804160668f:	00 00 00 
  8041606692:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606699:	00 00 00 
  804160669c:	be 4c 04 00 00       	mov    $0x44c,%esi
  80416066a1:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416066a8:	00 00 00 
  80416066ab:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066b0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066b7:	00 00 00 
  80416066ba:	41 ff d0             	callq  *%r8
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  80416066bd:	48 b9 f0 c2 60 41 80 	movabs $0x804160c2f0,%rcx
  80416066c4:	00 00 00 
  80416066c7:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416066ce:	00 00 00 
  80416066d1:	be 4d 04 00 00       	mov    $0x44d,%esi
  80416066d6:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416066dd:	00 00 00 
  80416066e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066e5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066ec:	00 00 00 
  80416066ef:	41 ff d0             	callq  *%r8
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  80416066f2:	48 b9 30 c3 60 41 80 	movabs $0x804160c330,%rcx
  80416066f9:	00 00 00 
  80416066fc:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606703:	00 00 00 
  8041606706:	be 4e 04 00 00       	mov    $0x44e,%esi
  804160670b:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606712:	00 00 00 
  8041606715:	b8 00 00 00 00       	mov    $0x0,%eax
  804160671a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606721:	00 00 00 
  8041606724:	41 ff d0             	callq  *%r8
  assert(fl != NULL);
  8041606727:	48 b9 74 cb 60 41 80 	movabs $0x804160cb74,%rcx
  804160672e:	00 00 00 
  8041606731:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606738:	00 00 00 
  804160673b:	be 52 04 00 00       	mov    $0x452,%esi
  8041606740:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606747:	00 00 00 
  804160674a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606751:	00 00 00 
  8041606754:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606757:	48 b9 7f cb 60 41 80 	movabs $0x804160cb7f,%rcx
  804160675e:	00 00 00 
  8041606761:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606768:	00 00 00 
  804160676b:	be 56 04 00 00       	mov    $0x456,%esi
  8041606770:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606777:	00 00 00 
  804160677a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160677f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606786:	00 00 00 
  8041606789:	41 ff d0             	callq  *%r8
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  804160678c:	48 b9 80 c3 60 41 80 	movabs $0x804160c380,%rcx
  8041606793:	00 00 00 
  8041606796:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160679d:	00 00 00 
  80416067a0:	be 59 04 00 00       	mov    $0x459,%esi
  80416067a5:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416067ac:	00 00 00 
  80416067af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067b4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067bb:	00 00 00 
  80416067be:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  80416067c1:	48 b9 b8 c3 60 41 80 	movabs $0x804160c3b8,%rcx
  80416067c8:	00 00 00 
  80416067cb:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416067d2:	00 00 00 
  80416067d5:	be 5c 04 00 00       	mov    $0x45c,%esi
  80416067da:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416067e1:	00 00 00 
  80416067e4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067e9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067f0:	00 00 00 
  80416067f3:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  80416067f6:	48 b9 b8 c3 60 41 80 	movabs $0x804160c3b8,%rcx
  80416067fd:	00 00 00 
  8041606800:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606807:	00 00 00 
  804160680a:	be 64 04 00 00       	mov    $0x464,%esi
  804160680f:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606816:	00 00 00 
  8041606819:	b8 00 00 00 00       	mov    $0x0,%eax
  804160681e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606825:	00 00 00 
  8041606828:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  804160682b:	48 b9 48 c4 60 41 80 	movabs $0x804160c448,%rcx
  8041606832:	00 00 00 
  8041606835:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160683c:	00 00 00 
  804160683f:	be 6c 04 00 00       	mov    $0x46c,%esi
  8041606844:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160684b:	00 00 00 
  804160684e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606853:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160685a:	00 00 00 
  804160685d:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041606860:	48 b9 78 c4 60 41 80 	movabs $0x804160c478,%rcx
  8041606867:	00 00 00 
  804160686a:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606871:	00 00 00 
  8041606874:	be 6d 04 00 00       	mov    $0x46d,%esi
  8041606879:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606880:	00 00 00 
  8041606883:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606888:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160688f:	00 00 00 
  8041606892:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  8041606895:	48 b9 f8 c4 60 41 80 	movabs $0x804160c4f8,%rcx
  804160689c:	00 00 00 
  804160689f:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416068a6:	00 00 00 
  80416068a9:	be 71 04 00 00       	mov    $0x471,%esi
  80416068ae:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416068b5:	00 00 00 
  80416068b8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068bd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068c4:	00 00 00 
  80416068c7:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  80416068ca:	48 b9 e5 cb 60 41 80 	movabs $0x804160cbe5,%rcx
  80416068d1:	00 00 00 
  80416068d4:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416068db:	00 00 00 
  80416068de:	be 72 04 00 00       	mov    $0x472,%esi
  80416068e3:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416068ea:	00 00 00 
  80416068ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068f2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068f9:	00 00 00 
  80416068fc:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  80416068ff:	48 b9 28 c5 60 41 80 	movabs $0x804160c528,%rcx
  8041606906:	00 00 00 
  8041606909:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606910:	00 00 00 
  8041606913:	be 75 04 00 00       	mov    $0x475,%esi
  8041606918:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160691f:	00 00 00 
  8041606922:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606927:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160692e:	00 00 00 
  8041606931:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606934:	48 b9 60 c5 60 41 80 	movabs $0x804160c560,%rcx
  804160693b:	00 00 00 
  804160693e:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606945:	00 00 00 
  8041606948:	be 76 04 00 00       	mov    $0x476,%esi
  804160694d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606954:	00 00 00 
  8041606957:	b8 00 00 00 00       	mov    $0x0,%eax
  804160695c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606963:	00 00 00 
  8041606966:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606969:	48 b9 f6 cb 60 41 80 	movabs $0x804160cbf6,%rcx
  8041606970:	00 00 00 
  8041606973:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160697a:	00 00 00 
  804160697d:	be 77 04 00 00       	mov    $0x477,%esi
  8041606982:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606989:	00 00 00 
  804160698c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606991:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606998:	00 00 00 
  804160699b:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  804160699e:	48 b9 7f cb 60 41 80 	movabs $0x804160cb7f,%rcx
  80416069a5:	00 00 00 
  80416069a8:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416069af:	00 00 00 
  80416069b2:	be 7a 04 00 00       	mov    $0x47a,%esi
  80416069b7:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416069be:	00 00 00 
  80416069c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069c6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069cd:	00 00 00 
  80416069d0:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  80416069d3:	48 b9 28 c5 60 41 80 	movabs $0x804160c528,%rcx
  80416069da:	00 00 00 
  80416069dd:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416069e4:	00 00 00 
  80416069e7:	be 7d 04 00 00       	mov    $0x47d,%esi
  80416069ec:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416069f3:	00 00 00 
  80416069f6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069fb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a02:	00 00 00 
  8041606a05:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606a08:	48 b9 60 c5 60 41 80 	movabs $0x804160c560,%rcx
  8041606a0f:	00 00 00 
  8041606a12:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606a19:	00 00 00 
  8041606a1c:	be 7e 04 00 00       	mov    $0x47e,%esi
  8041606a21:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606a28:	00 00 00 
  8041606a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a30:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a37:	00 00 00 
  8041606a3a:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606a3d:	48 b9 f6 cb 60 41 80 	movabs $0x804160cbf6,%rcx
  8041606a44:	00 00 00 
  8041606a47:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606a4e:	00 00 00 
  8041606a51:	be 7f 04 00 00       	mov    $0x47f,%esi
  8041606a56:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606a5d:	00 00 00 
  8041606a60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a65:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a6c:	00 00 00 
  8041606a6f:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606a72:	48 b9 7f cb 60 41 80 	movabs $0x804160cb7f,%rcx
  8041606a79:	00 00 00 
  8041606a7c:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606a83:	00 00 00 
  8041606a86:	be 83 04 00 00       	mov    $0x483,%esi
  8041606a8b:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606a92:	00 00 00 
  8041606a95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a9a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606aa1:	00 00 00 
  8041606aa4:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041606aa7:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041606aae:	00 00 00 
  8041606ab1:	be 85 04 00 00       	mov    $0x485,%esi
  8041606ab6:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606abd:	00 00 00 
  8041606ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ac5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606acc:	00 00 00 
  8041606acf:	41 ff d0             	callq  *%r8
  8041606ad2:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041606ad9:	00 00 00 
  8041606adc:	be 86 04 00 00       	mov    $0x486,%esi
  8041606ae1:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606ae8:	00 00 00 
  8041606aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606af0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606af7:	00 00 00 
  8041606afa:	41 ff d0             	callq  *%r8
  8041606afd:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041606b04:	00 00 00 
  8041606b07:	be 87 04 00 00       	mov    $0x487,%esi
  8041606b0c:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606b13:	00 00 00 
  8041606b16:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b1b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b22:	00 00 00 
  8041606b25:	41 ff d0             	callq  *%r8
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  8041606b28:	48 b9 90 c5 60 41 80 	movabs $0x804160c590,%rcx
  8041606b2f:	00 00 00 
  8041606b32:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606b39:	00 00 00 
  8041606b3c:	be 88 04 00 00       	mov    $0x488,%esi
  8041606b41:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606b48:	00 00 00 
  8041606b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b50:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b57:	00 00 00 
  8041606b5a:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  8041606b5d:	48 b9 d0 c5 60 41 80 	movabs $0x804160c5d0,%rcx
  8041606b64:	00 00 00 
  8041606b67:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606b6e:	00 00 00 
  8041606b71:	be 8b 04 00 00       	mov    $0x48b,%esi
  8041606b76:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606b7d:	00 00 00 
  8041606b80:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b85:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b8c:	00 00 00 
  8041606b8f:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606b92:	48 b9 60 c5 60 41 80 	movabs $0x804160c560,%rcx
  8041606b99:	00 00 00 
  8041606b9c:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606ba3:	00 00 00 
  8041606ba6:	be 8c 04 00 00       	mov    $0x48c,%esi
  8041606bab:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606bb2:	00 00 00 
  8041606bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bba:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606bc1:	00 00 00 
  8041606bc4:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606bc7:	48 b9 f6 cb 60 41 80 	movabs $0x804160cbf6,%rcx
  8041606bce:	00 00 00 
  8041606bd1:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606bd8:	00 00 00 
  8041606bdb:	be 8d 04 00 00       	mov    $0x48d,%esi
  8041606be0:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606be7:	00 00 00 
  8041606bea:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bef:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606bf6:	00 00 00 
  8041606bf9:	41 ff d0             	callq  *%r8
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041606bfc:	48 b9 10 c6 60 41 80 	movabs $0x804160c610,%rcx
  8041606c03:	00 00 00 
  8041606c06:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606c0d:	00 00 00 
  8041606c10:	be 8e 04 00 00       	mov    $0x48e,%esi
  8041606c15:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606c1c:	00 00 00 
  8041606c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c24:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c2b:	00 00 00 
  8041606c2e:	41 ff d0             	callq  *%r8
  assert(kern_pml4e[0] & PTE_U);
  8041606c31:	48 b9 07 cc 60 41 80 	movabs $0x804160cc07,%rcx
  8041606c38:	00 00 00 
  8041606c3b:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606c42:	00 00 00 
  8041606c45:	be 8f 04 00 00       	mov    $0x48f,%esi
  8041606c4a:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606c51:	00 00 00 
  8041606c54:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c59:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c60:	00 00 00 
  8041606c63:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041606c66:	48 b9 48 c6 60 41 80 	movabs $0x804160c648,%rcx
  8041606c6d:	00 00 00 
  8041606c70:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606c77:	00 00 00 
  8041606c7a:	be 92 04 00 00       	mov    $0x492,%esi
  8041606c7f:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606c86:	00 00 00 
  8041606c89:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c8e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c95:	00 00 00 
  8041606c98:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606c9b:	48 b9 80 c6 60 41 80 	movabs $0x804160c680,%rcx
  8041606ca2:	00 00 00 
  8041606ca5:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606cac:	00 00 00 
  8041606caf:	be 95 04 00 00       	mov    $0x495,%esi
  8041606cb4:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606cbb:	00 00 00 
  8041606cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606cc3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606cca:	00 00 00 
  8041606ccd:	41 ff d0             	callq  *%r8
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041606cd0:	48 b9 b8 c6 60 41 80 	movabs $0x804160c6b8,%rcx
  8041606cd7:	00 00 00 
  8041606cda:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606ce1:	00 00 00 
  8041606ce4:	be 96 04 00 00       	mov    $0x496,%esi
  8041606ce9:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606cf0:	00 00 00 
  8041606cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606cf8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606cff:	00 00 00 
  8041606d02:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041606d05:	48 b9 f0 c6 60 41 80 	movabs $0x804160c6f0,%rcx
  8041606d0c:	00 00 00 
  8041606d0f:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606d16:	00 00 00 
  8041606d19:	be 99 04 00 00       	mov    $0x499,%esi
  8041606d1e:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606d25:	00 00 00 
  8041606d28:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d2d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d34:	00 00 00 
  8041606d37:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606d3a:	48 b9 20 c7 60 41 80 	movabs $0x804160c720,%rcx
  8041606d41:	00 00 00 
  8041606d44:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606d4b:	00 00 00 
  8041606d4e:	be 9a 04 00 00       	mov    $0x49a,%esi
  8041606d53:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606d5a:	00 00 00 
  8041606d5d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d62:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d69:	00 00 00 
  8041606d6c:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 2);
  8041606d6f:	48 b9 1d cc 60 41 80 	movabs $0x804160cc1d,%rcx
  8041606d76:	00 00 00 
  8041606d79:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606d80:	00 00 00 
  8041606d83:	be 9c 04 00 00       	mov    $0x49c,%esi
  8041606d88:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606d8f:	00 00 00 
  8041606d92:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d97:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d9e:	00 00 00 
  8041606da1:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606da4:	48 b9 2e cc 60 41 80 	movabs $0x804160cc2e,%rcx
  8041606dab:	00 00 00 
  8041606dae:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606db5:	00 00 00 
  8041606db8:	be 9d 04 00 00       	mov    $0x49d,%esi
  8041606dbd:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606dc4:	00 00 00 
  8041606dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606dcc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606dd3:	00 00 00 
  8041606dd6:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606dd9:	48 b9 50 c7 60 41 80 	movabs $0x804160c750,%rcx
  8041606de0:	00 00 00 
  8041606de3:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606dea:	00 00 00 
  8041606ded:	be a1 04 00 00       	mov    $0x4a1,%esi
  8041606df2:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606df9:	00 00 00 
  8041606dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e01:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e08:	00 00 00 
  8041606e0b:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606e0e:	48 b9 20 c7 60 41 80 	movabs $0x804160c720,%rcx
  8041606e15:	00 00 00 
  8041606e18:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606e1f:	00 00 00 
  8041606e22:	be a2 04 00 00       	mov    $0x4a2,%esi
  8041606e27:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606e2e:	00 00 00 
  8041606e31:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e36:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e3d:	00 00 00 
  8041606e40:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041606e43:	48 b9 e5 cb 60 41 80 	movabs $0x804160cbe5,%rcx
  8041606e4a:	00 00 00 
  8041606e4d:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606e54:	00 00 00 
  8041606e57:	be a3 04 00 00       	mov    $0x4a3,%esi
  8041606e5c:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606e63:	00 00 00 
  8041606e66:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e6b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e72:	00 00 00 
  8041606e75:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606e78:	48 b9 2e cc 60 41 80 	movabs $0x804160cc2e,%rcx
  8041606e7f:	00 00 00 
  8041606e82:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606e89:	00 00 00 
  8041606e8c:	be a4 04 00 00       	mov    $0x4a4,%esi
  8041606e91:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606e98:	00 00 00 
  8041606e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ea0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ea7:	00 00 00 
  8041606eaa:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606ead:	48 b9 80 c6 60 41 80 	movabs $0x804160c680,%rcx
  8041606eb4:	00 00 00 
  8041606eb7:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606ebe:	00 00 00 
  8041606ec1:	be a8 04 00 00       	mov    $0x4a8,%esi
  8041606ec6:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606ecd:	00 00 00 
  8041606ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ed5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606edc:	00 00 00 
  8041606edf:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref);
  8041606ee2:	48 b9 3f cc 60 41 80 	movabs $0x804160cc3f,%rcx
  8041606ee9:	00 00 00 
  8041606eec:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606ef3:	00 00 00 
  8041606ef6:	be a9 04 00 00       	mov    $0x4a9,%esi
  8041606efb:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606f02:	00 00 00 
  8041606f05:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f0a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f11:	00 00 00 
  8041606f14:	41 ff d0             	callq  *%r8
  assert(pp1->pp_link == NULL);
  8041606f17:	48 b9 4b cc 60 41 80 	movabs $0x804160cc4b,%rcx
  8041606f1e:	00 00 00 
  8041606f21:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606f28:	00 00 00 
  8041606f2b:	be aa 04 00 00       	mov    $0x4aa,%esi
  8041606f30:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606f37:	00 00 00 
  8041606f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f3f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f46:	00 00 00 
  8041606f49:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606f4c:	48 b9 50 c7 60 41 80 	movabs $0x804160c750,%rcx
  8041606f53:	00 00 00 
  8041606f56:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606f5d:	00 00 00 
  8041606f60:	be ae 04 00 00       	mov    $0x4ae,%esi
  8041606f65:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606f6c:	00 00 00 
  8041606f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f74:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f7b:	00 00 00 
  8041606f7e:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041606f81:	48 b9 78 c7 60 41 80 	movabs $0x804160c778,%rcx
  8041606f88:	00 00 00 
  8041606f8b:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606f92:	00 00 00 
  8041606f95:	be af 04 00 00       	mov    $0x4af,%esi
  8041606f9a:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606fa1:	00 00 00 
  8041606fa4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606fa9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606fb0:	00 00 00 
  8041606fb3:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041606fb6:	48 b9 60 cc 60 41 80 	movabs $0x804160cc60,%rcx
  8041606fbd:	00 00 00 
  8041606fc0:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606fc7:	00 00 00 
  8041606fca:	be b0 04 00 00       	mov    $0x4b0,%esi
  8041606fcf:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041606fd6:	00 00 00 
  8041606fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606fde:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606fe5:	00 00 00 
  8041606fe8:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606feb:	48 b9 2e cc 60 41 80 	movabs $0x804160cc2e,%rcx
  8041606ff2:	00 00 00 
  8041606ff5:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041606ffc:	00 00 00 
  8041606fff:	be b1 04 00 00       	mov    $0x4b1,%esi
  8041607004:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160700b:	00 00 00 
  804160700e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607013:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160701a:	00 00 00 
  804160701d:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041607020:	48 b9 78 c4 60 41 80 	movabs $0x804160c478,%rcx
  8041607027:	00 00 00 
  804160702a:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607031:	00 00 00 
  8041607034:	be c4 04 00 00       	mov    $0x4c4,%esi
  8041607039:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607040:	00 00 00 
  8041607043:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607048:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160704f:	00 00 00 
  8041607052:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041607055:	48 b9 2e cc 60 41 80 	movabs $0x804160cc2e,%rcx
  804160705c:	00 00 00 
  804160705f:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607066:	00 00 00 
  8041607069:	be c6 04 00 00       	mov    $0x4c6,%esi
  804160706e:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607075:	00 00 00 
  8041607078:	b8 00 00 00 00       	mov    $0x0,%eax
  804160707d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607084:	00 00 00 
  8041607087:	41 ff d0             	callq  *%r8
  804160708a:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041607091:	00 00 00 
  8041607094:	be cd 04 00 00       	mov    $0x4cd,%esi
  8041607099:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416070a0:	00 00 00 
  80416070a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070a8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070af:	00 00 00 
  80416070b2:	41 ff d0             	callq  *%r8
  80416070b5:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416070bc:	00 00 00 
  80416070bf:	be ce 04 00 00       	mov    $0x4ce,%esi
  80416070c4:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416070cb:	00 00 00 
  80416070ce:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070d3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070da:	00 00 00 
  80416070dd:	41 ff d0             	callq  *%r8
  80416070e0:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416070e7:	00 00 00 
  80416070ea:	be cf 04 00 00       	mov    $0x4cf,%esi
  80416070ef:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416070f6:	00 00 00 
  80416070f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070fe:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607105:	00 00 00 
  8041607108:	41 ff d0             	callq  *%r8
  assert(ptep == ptep1 + PTX(va));
  804160710b:	48 b9 71 cc 60 41 80 	movabs $0x804160cc71,%rcx
  8041607112:	00 00 00 
  8041607115:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160711c:	00 00 00 
  804160711f:	be d0 04 00 00       	mov    $0x4d0,%esi
  8041607124:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160712b:	00 00 00 
  804160712e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607133:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160713a:	00 00 00 
  804160713d:	41 ff d0             	callq  *%r8
  8041607140:	48 89 f9             	mov    %rdi,%rcx
  8041607143:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  804160714a:	00 00 00 
  804160714d:	be 60 00 00 00       	mov    $0x60,%esi
  8041607152:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  8041607159:	00 00 00 
  804160715c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607161:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607168:	00 00 00 
  804160716b:	41 ff d0             	callq  *%r8
  804160716e:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041607175:	00 00 00 
  8041607178:	be d6 04 00 00       	mov    $0x4d6,%esi
  804160717d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607184:	00 00 00 
  8041607187:	b8 00 00 00 00       	mov    $0x0,%eax
  804160718c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607193:	00 00 00 
  8041607196:	41 ff d0             	callq  *%r8
  8041607199:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416071a0:	00 00 00 
  80416071a3:	be d7 04 00 00       	mov    $0x4d7,%esi
  80416071a8:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416071af:	00 00 00 
  80416071b2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071b7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071be:	00 00 00 
  80416071c1:	41 ff d0             	callq  *%r8
  80416071c4:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416071cb:	00 00 00 
  80416071ce:	be d8 04 00 00       	mov    $0x4d8,%esi
  80416071d3:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416071da:	00 00 00 
  80416071dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071e2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071e9:	00 00 00 
  80416071ec:	41 ff d0             	callq  *%r8
    assert((ptep[i] & PTE_P) == 0);
  80416071ef:	48 b9 89 cc 60 41 80 	movabs $0x804160cc89,%rcx
  80416071f6:	00 00 00 
  80416071f9:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607200:	00 00 00 
  8041607203:	be da 04 00 00       	mov    $0x4da,%esi
  8041607208:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160720f:	00 00 00 
  8041607212:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607217:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160721e:	00 00 00 
  8041607221:	41 ff d0             	callq  *%r8
    panic("'pages' is a null pointer!");
  8041607224:	48 ba b9 cc 60 41 80 	movabs $0x804160ccb9,%rdx
  804160722b:	00 00 00 
  804160722e:	be 99 03 00 00       	mov    $0x399,%esi
  8041607233:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160723a:	00 00 00 
  804160723d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607242:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041607249:	00 00 00 
  804160724c:	ff d1                	callq  *%rcx
  assert((pp0 = page_alloc(0)));
  804160724e:	48 b9 d4 cc 60 41 80 	movabs $0x804160ccd4,%rcx
  8041607255:	00 00 00 
  8041607258:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160725f:	00 00 00 
  8041607262:	be a1 03 00 00       	mov    $0x3a1,%esi
  8041607267:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160726e:	00 00 00 
  8041607271:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607276:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160727d:	00 00 00 
  8041607280:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607283:	48 b9 ea cc 60 41 80 	movabs $0x804160ccea,%rcx
  804160728a:	00 00 00 
  804160728d:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607294:	00 00 00 
  8041607297:	be a2 03 00 00       	mov    $0x3a2,%esi
  804160729c:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416072a3:	00 00 00 
  80416072a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072ab:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072b2:	00 00 00 
  80416072b5:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  80416072b8:	48 b9 00 cd 60 41 80 	movabs $0x804160cd00,%rcx
  80416072bf:	00 00 00 
  80416072c2:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416072c9:	00 00 00 
  80416072cc:	be a3 03 00 00       	mov    $0x3a3,%esi
  80416072d1:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416072d8:	00 00 00 
  80416072db:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072e0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072e7:	00 00 00 
  80416072ea:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  80416072ed:	48 b9 62 cb 60 41 80 	movabs $0x804160cb62,%rcx
  80416072f4:	00 00 00 
  80416072f7:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416072fe:	00 00 00 
  8041607301:	be a6 03 00 00       	mov    $0x3a6,%esi
  8041607306:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160730d:	00 00 00 
  8041607310:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607315:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160731c:	00 00 00 
  804160731f:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041607322:	48 b9 a0 c2 60 41 80 	movabs $0x804160c2a0,%rcx
  8041607329:	00 00 00 
  804160732c:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607333:	00 00 00 
  8041607336:	be a7 03 00 00       	mov    $0x3a7,%esi
  804160733b:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607342:	00 00 00 
  8041607345:	b8 00 00 00 00       	mov    $0x0,%eax
  804160734a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607351:	00 00 00 
  8041607354:	41 ff d0             	callq  *%r8
  assert(page2pa(pp0) < npages * PGSIZE);
  8041607357:	48 b9 a0 c7 60 41 80 	movabs $0x804160c7a0,%rcx
  804160735e:	00 00 00 
  8041607361:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607368:	00 00 00 
  804160736b:	be a8 03 00 00       	mov    $0x3a8,%esi
  8041607370:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607377:	00 00 00 
  804160737a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160737f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607386:	00 00 00 
  8041607389:	41 ff d0             	callq  *%r8
  assert(page2pa(pp1) < npages * PGSIZE);
  804160738c:	48 b9 c0 c7 60 41 80 	movabs $0x804160c7c0,%rcx
  8041607393:	00 00 00 
  8041607396:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160739d:	00 00 00 
  80416073a0:	be a9 03 00 00       	mov    $0x3a9,%esi
  80416073a5:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416073ac:	00 00 00 
  80416073af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073b4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073bb:	00 00 00 
  80416073be:	41 ff d0             	callq  *%r8
  assert(page2pa(pp2) < npages * PGSIZE);
  80416073c1:	48 b9 e0 c7 60 41 80 	movabs $0x804160c7e0,%rcx
  80416073c8:	00 00 00 
  80416073cb:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416073d2:	00 00 00 
  80416073d5:	be aa 03 00 00       	mov    $0x3aa,%esi
  80416073da:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416073e1:	00 00 00 
  80416073e4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073e9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073f0:	00 00 00 
  80416073f3:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416073f6:	48 b9 7f cb 60 41 80 	movabs $0x804160cb7f,%rcx
  80416073fd:	00 00 00 
  8041607400:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607407:	00 00 00 
  804160740a:	be b1 03 00 00       	mov    $0x3b1,%esi
  804160740f:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607416:	00 00 00 
  8041607419:	b8 00 00 00 00       	mov    $0x0,%eax
  804160741e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607425:	00 00 00 
  8041607428:	41 ff d0             	callq  *%r8
  assert((pp0 = page_alloc(0)));
  804160742b:	48 b9 d4 cc 60 41 80 	movabs $0x804160ccd4,%rcx
  8041607432:	00 00 00 
  8041607435:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160743c:	00 00 00 
  804160743f:	be b8 03 00 00       	mov    $0x3b8,%esi
  8041607444:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160744b:	00 00 00 
  804160744e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607453:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160745a:	00 00 00 
  804160745d:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607460:	48 b9 ea cc 60 41 80 	movabs $0x804160ccea,%rcx
  8041607467:	00 00 00 
  804160746a:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607471:	00 00 00 
  8041607474:	be b9 03 00 00       	mov    $0x3b9,%esi
  8041607479:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607480:	00 00 00 
  8041607483:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607488:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160748f:	00 00 00 
  8041607492:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041607495:	48 b9 00 cd 60 41 80 	movabs $0x804160cd00,%rcx
  804160749c:	00 00 00 
  804160749f:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416074a6:	00 00 00 
  80416074a9:	be ba 03 00 00       	mov    $0x3ba,%esi
  80416074ae:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416074b5:	00 00 00 
  80416074b8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074bd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074c4:	00 00 00 
  80416074c7:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  80416074ca:	48 b9 62 cb 60 41 80 	movabs $0x804160cb62,%rcx
  80416074d1:	00 00 00 
  80416074d4:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416074db:	00 00 00 
  80416074de:	be bc 03 00 00       	mov    $0x3bc,%esi
  80416074e3:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416074ea:	00 00 00 
  80416074ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074f2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074f9:	00 00 00 
  80416074fc:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416074ff:	48 b9 a0 c2 60 41 80 	movabs $0x804160c2a0,%rcx
  8041607506:	00 00 00 
  8041607509:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607510:	00 00 00 
  8041607513:	be bd 03 00 00       	mov    $0x3bd,%esi
  8041607518:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160751f:	00 00 00 
  8041607522:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607527:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160752e:	00 00 00 
  8041607531:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041607534:	48 b9 7f cb 60 41 80 	movabs $0x804160cb7f,%rcx
  804160753b:	00 00 00 
  804160753e:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607545:	00 00 00 
  8041607548:	be be 03 00 00       	mov    $0x3be,%esi
  804160754d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607554:	00 00 00 
  8041607557:	b8 00 00 00 00       	mov    $0x0,%eax
  804160755c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607563:	00 00 00 
  8041607566:	41 ff d0             	callq  *%r8
  8041607569:	48 89 f9             	mov    %rdi,%rcx
  804160756c:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041607573:	00 00 00 
  8041607576:	be 60 00 00 00       	mov    $0x60,%esi
  804160757b:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  8041607582:	00 00 00 
  8041607585:	b8 00 00 00 00       	mov    $0x0,%eax
  804160758a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607591:	00 00 00 
  8041607594:	41 ff d0             	callq  *%r8
  assert((pp = page_alloc(ALLOC_ZERO)));
  8041607597:	48 b9 16 cd 60 41 80 	movabs $0x804160cd16,%rcx
  804160759e:	00 00 00 
  80416075a1:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416075a8:	00 00 00 
  80416075ab:	be c3 03 00 00       	mov    $0x3c3,%esi
  80416075b0:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416075b7:	00 00 00 
  80416075ba:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075c1:	00 00 00 
  80416075c4:	41 ff d0             	callq  *%r8
  assert(pp && pp0 == pp);
  80416075c7:	48 b9 34 cd 60 41 80 	movabs $0x804160cd34,%rcx
  80416075ce:	00 00 00 
  80416075d1:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416075d8:	00 00 00 
  80416075db:	be c4 03 00 00       	mov    $0x3c4,%esi
  80416075e0:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416075e7:	00 00 00 
  80416075ea:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075ef:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075f6:	00 00 00 
  80416075f9:	41 ff d0             	callq  *%r8
  80416075fc:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041607603:	00 00 00 
  8041607606:	be 60 00 00 00       	mov    $0x60,%esi
  804160760b:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  8041607612:	00 00 00 
  8041607615:	b8 00 00 00 00       	mov    $0x0,%eax
  804160761a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607621:	00 00 00 
  8041607624:	41 ff d0             	callq  *%r8
    assert(c[i] == 0);
  8041607627:	48 b9 44 cd 60 41 80 	movabs $0x804160cd44,%rcx
  804160762e:	00 00 00 
  8041607631:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607638:	00 00 00 
  804160763b:	be c7 03 00 00       	mov    $0x3c7,%esi
  8041607640:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607647:	00 00 00 
  804160764a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160764f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607656:	00 00 00 
  8041607659:	41 ff d0             	callq  *%r8
  assert(nfree == 0);
  804160765c:	48 b9 4e cd 60 41 80 	movabs $0x804160cd4e,%rcx
  8041607663:	00 00 00 
  8041607666:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160766d:	00 00 00 
  8041607670:	be d4 03 00 00       	mov    $0x3d4,%esi
  8041607675:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160767c:	00 00 00 
  804160767f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607684:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160768b:	00 00 00 
  804160768e:	41 ff d0             	callq  *%r8
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041607691:	48 89 c1             	mov    %rax,%rcx
  8041607694:	48 ba d8 c0 60 41 80 	movabs $0x804160c0d8,%rdx
  804160769b:	00 00 00 
  804160769e:	be 11 01 00 00       	mov    $0x111,%esi
  80416076a3:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416076aa:	00 00 00 
  80416076ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076b2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076b9:	00 00 00 
  80416076bc:	41 ff d0             	callq  *%r8
  80416076bf:	48 89 d9             	mov    %rbx,%rcx
  80416076c2:	48 ba d8 c0 60 41 80 	movabs $0x804160c0d8,%rdx
  80416076c9:	00 00 00 
  80416076cc:	be 1f 01 00 00       	mov    $0x11f,%esi
  80416076d1:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416076d8:	00 00 00 
  80416076db:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076e0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076e7:	00 00 00 
  80416076ea:	41 ff d0             	callq  *%r8
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416076ed:	48 89 d8             	mov    %rbx,%rax
  80416076f0:	49 03 06             	add    (%r14),%rax
  80416076f3:	48 89 c3             	mov    %rax,%rbx
  80416076f6:	49 39 04 24          	cmp    %rax,(%r12)
  80416076fa:	76 2e                	jbe    804160772a <mem_init+0x24f7>
    if (mmap_curr->Attribute & EFI_MEMORY_RUNTIME) {
  80416076fc:	48 83 7b 20 00       	cmpq   $0x0,0x20(%rbx)
  8041607701:	79 ea                	jns    80416076ed <mem_init+0x24ba>
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  8041607703:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
    size_to_alloc = mmap_curr->NumberOfPages * PGSIZE;
  8041607707:	48 8b 53 18          	mov    0x18(%rbx),%rdx
  804160770b:	48 c1 e2 0c          	shl    $0xc,%rdx
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  804160770f:	48 8b 73 10          	mov    0x10(%rbx),%rsi
  8041607713:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041607719:	49 8b 3f             	mov    (%r15),%rdi
  804160771c:	48 b8 ac 4f 60 41 80 	movabs $0x8041604fac,%rax
  8041607723:	00 00 00 
  8041607726:	ff d0                	callq  *%rax
  8041607728:	eb c3                	jmp    80416076ed <mem_init+0x24ba>
  pml4e = kern_pml4e;
  804160772a:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041607731:	00 00 00 
  8041607734:	4c 8b 20             	mov    (%rax),%r12
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
  8041607737:	48 a1 70 00 62 41 80 	movabs 0x8041620070,%rax
  804160773e:	00 00 00 
  8041607741:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  8041607745:	48 c1 e0 04          	shl    $0x4,%rax
  8041607749:	48 05 ff 0f 00 00    	add    $0xfff,%rax
  for (i = 0; i < n; i += PGSIZE) {
  804160774f:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041607755:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041607759:	74 6d                	je     80416077c8 <mem_init+0x2595>
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  804160775b:	48 a1 78 00 62 41 80 	movabs 0x8041620078,%rax
  8041607762:	00 00 00 
  8041607765:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  if ((uint64_t)kva < KERNBASE)
  8041607769:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  return (physaddr_t)kva - KERNBASE;
  804160776d:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  8041607774:	ff ff ff 
  8041607777:	49 01 c6             	add    %rax,%r14
  for (i = 0; i < n; i += PGSIZE) {
  804160777a:	4c 89 eb             	mov    %r13,%rbx
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  804160777d:	49 bf 00 e0 42 3c 80 	movabs $0x803c42e000,%r15
  8041607784:	00 00 00 
  8041607787:	4a 8d 34 3b          	lea    (%rbx,%r15,1),%rsi
  804160778b:	4c 89 e7             	mov    %r12,%rdi
  804160778e:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041607795:	00 00 00 
  8041607798:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  804160779a:	48 be ff ff ff 3f 80 	movabs $0x803fffffff,%rsi
  80416077a1:	00 00 00 
  80416077a4:	48 39 75 b0          	cmp    %rsi,-0x50(%rbp)
  80416077a8:	0f 86 32 01 00 00    	jbe    80416078e0 <mem_init+0x26ad>
  80416077ae:	49 8d 14 1e          	lea    (%r14,%rbx,1),%rdx
  80416077b2:	48 39 c2             	cmp    %rax,%rdx
  80416077b5:	0f 85 54 01 00 00    	jne    804160790f <mem_init+0x26dc>
  for (i = 0; i < n; i += PGSIZE) {
  80416077bb:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  80416077c2:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  80416077c6:	77 bf                	ja     8041607787 <mem_init+0x2554>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  80416077c8:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416077cc:	48 c1 e0 0c          	shl    $0xc,%rax
  80416077d0:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416077d4:	0f 84 9f 01 00 00    	je     8041607979 <mem_init+0x2746>
  80416077da:	4c 89 eb             	mov    %r13,%rbx
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  80416077dd:	49 bf 00 00 00 40 80 	movabs $0x8040000000,%r15
  80416077e4:	00 00 00 
  80416077e7:	49 be e6 40 60 41 80 	movabs $0x80416040e6,%r14
  80416077ee:	00 00 00 
  80416077f1:	4a 8d 34 3b          	lea    (%rbx,%r15,1),%rsi
  80416077f5:	4c 89 e7             	mov    %r12,%rdi
  80416077f8:	41 ff d6             	callq  *%r14
  80416077fb:	48 39 d8             	cmp    %rbx,%rax
  80416077fe:	0f 85 40 01 00 00    	jne    8041607944 <mem_init+0x2711>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607804:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  804160780b:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  804160780f:	77 e0                	ja     80416077f1 <mem_init+0x25be>
  8041607811:	48 bb 00 00 ff 3f 80 	movabs $0x803fff0000,%rbx
  8041607818:	00 00 00 
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  804160781b:	49 bf e6 40 60 41 80 	movabs $0x80416040e6,%r15
  8041607822:	00 00 00 
  8041607825:	49 be 00 00 01 80 ff 	movabs $0xfffffeff80010000,%r14
  804160782c:	fe ff ff 
  804160782f:	48 b8 00 e0 60 41 80 	movabs $0x804160e000,%rax
  8041607836:	00 00 00 
  8041607839:	49 01 c6             	add    %rax,%r14
  804160783c:	48 89 de             	mov    %rbx,%rsi
  804160783f:	4c 89 e7             	mov    %r12,%rdi
  8041607842:	41 ff d7             	callq  *%r15
  8041607845:	49 8d 14 1e          	lea    (%r14,%rbx,1),%rdx
  8041607849:	48 39 c2             	cmp    %rax,%rdx
  804160784c:	0f 85 36 01 00 00    	jne    8041607988 <mem_init+0x2755>
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
  8041607852:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  8041607859:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607860:	00 00 00 
  8041607863:	48 39 c3             	cmp    %rax,%rbx
  8041607866:	75 d4                	jne    804160783c <mem_init+0x2609>
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  8041607868:	48 be 00 00 e0 3f 80 	movabs $0x803fe00000,%rsi
  804160786f:	00 00 00 
  8041607872:	4c 89 e7             	mov    %r12,%rdi
  8041607875:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  804160787c:	00 00 00 
  804160787f:	ff d0                	callq  *%rax
  8041607881:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041607885:	0f 85 32 01 00 00    	jne    80416079bd <mem_init+0x278a>
  pdpe_t *pdpe = KADDR(PTE_ADDR(kern_pml4e[1]));
  804160788b:	49 8b 4c 24 08       	mov    0x8(%r12),%rcx
  8041607890:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041607897:	48 89 c8             	mov    %rcx,%rax
  804160789a:	48 c1 e8 0c          	shr    $0xc,%rax
  804160789e:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  80416078a2:	0f 86 4a 01 00 00    	jbe    80416079f2 <mem_init+0x27bf>
  pde_t *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  80416078a8:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416078af:	00 00 00 
  80416078b2:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  80416078b6:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416078bd:	48 89 c8             	mov    %rcx,%rax
  80416078c0:	48 c1 e8 0c          	shr    $0xc,%rax
  80416078c4:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  80416078c8:	0f 86 4f 01 00 00    	jbe    8041607a1d <mem_init+0x27ea>
  return (void *)(pa + KERNBASE);
  80416078ce:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416078d5:	00 00 00 
  80416078d8:	48 01 c1             	add    %rax,%rcx
  for (i = 0; i < NPDENTRIES; i++) {
  80416078db:	e9 8b 01 00 00       	jmpq   8041607a6b <mem_init+0x2838>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416078e0:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  80416078e4:	48 ba d8 c0 60 41 80 	movabs $0x804160c0d8,%rdx
  80416078eb:	00 00 00 
  80416078ee:	be ec 03 00 00       	mov    $0x3ec,%esi
  80416078f3:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416078fa:	00 00 00 
  80416078fd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607902:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607909:	00 00 00 
  804160790c:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  804160790f:	48 b9 20 c8 60 41 80 	movabs $0x804160c820,%rcx
  8041607916:	00 00 00 
  8041607919:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607920:	00 00 00 
  8041607923:	be ec 03 00 00       	mov    $0x3ec,%esi
  8041607928:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160792f:	00 00 00 
  8041607932:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607937:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160793e:	00 00 00 
  8041607941:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  8041607944:	48 b9 58 c8 60 41 80 	movabs $0x804160c858,%rcx
  804160794b:	00 00 00 
  804160794e:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607955:	00 00 00 
  8041607958:	be f1 03 00 00       	mov    $0x3f1,%esi
  804160795d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607964:	00 00 00 
  8041607967:	b8 00 00 00 00       	mov    $0x0,%eax
  804160796c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607973:	00 00 00 
  8041607976:	41 ff d0             	callq  *%r8
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607979:	48 bb 00 00 ff 3f 80 	movabs $0x803fff0000,%rbx
  8041607980:	00 00 00 
  8041607983:	e9 93 fe ff ff       	jmpq   804160781b <mem_init+0x25e8>
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8041607988:	48 b9 80 c8 60 41 80 	movabs $0x804160c880,%rcx
  804160798f:	00 00 00 
  8041607992:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607999:	00 00 00 
  804160799c:	be f5 03 00 00       	mov    $0x3f5,%esi
  80416079a1:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416079a8:	00 00 00 
  80416079ab:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079b0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079b7:	00 00 00 
  80416079ba:	41 ff d0             	callq  *%r8
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  80416079bd:	48 b9 c8 c8 60 41 80 	movabs $0x804160c8c8,%rcx
  80416079c4:	00 00 00 
  80416079c7:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416079ce:	00 00 00 
  80416079d1:	be f7 03 00 00       	mov    $0x3f7,%esi
  80416079d6:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416079dd:	00 00 00 
  80416079e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079e5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079ec:	00 00 00 
  80416079ef:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416079f2:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416079f9:	00 00 00 
  80416079fc:	be f9 03 00 00       	mov    $0x3f9,%esi
  8041607a01:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607a08:	00 00 00 
  8041607a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a10:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a17:	00 00 00 
  8041607a1a:	41 ff d0             	callq  *%r8
  8041607a1d:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041607a24:	00 00 00 
  8041607a27:	be fa 03 00 00       	mov    $0x3fa,%esi
  8041607a2c:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607a33:	00 00 00 
  8041607a36:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a3b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a42:	00 00 00 
  8041607a45:	41 ff d0             	callq  *%r8
    switch (i) {
  8041607a48:	49 81 fd 00 00 08 00 	cmp    $0x80000,%r13
  8041607a4f:	75 32                	jne    8041607a83 <mem_init+0x2850>
        assert(pgdir[i] & PTE_P);
  8041607a51:	f6 01 01             	testb  $0x1,(%rcx)
  8041607a54:	74 7a                	je     8041607ad0 <mem_init+0x289d>
  for (i = 0; i < NPDENTRIES; i++) {
  8041607a56:	49 83 c5 01          	add    $0x1,%r13
  8041607a5a:	48 83 c1 08          	add    $0x8,%rcx
  8041607a5e:	49 81 fd 00 02 00 00 	cmp    $0x200,%r13
  8041607a65:	0f 84 d8 00 00 00    	je     8041607b43 <mem_init+0x2910>
    switch (i) {
  8041607a6b:	49 81 fd ff 01 04 00 	cmp    $0x401ff,%r13
  8041607a72:	74 dd                	je     8041607a51 <mem_init+0x281e>
  8041607a74:	77 d2                	ja     8041607a48 <mem_init+0x2815>
  8041607a76:	49 8d 85 1f fe fb ff 	lea    -0x401e1(%r13),%rax
  8041607a7d:	48 83 f8 01          	cmp    $0x1,%rax
  8041607a81:	76 ce                	jbe    8041607a51 <mem_init+0x281e>
        if (i >= VPD(KERNBASE)) {
  8041607a83:	49 81 fd ff 01 04 00 	cmp    $0x401ff,%r13
  8041607a8a:	76 ca                	jbe    8041607a56 <mem_init+0x2823>
          if (pgdir[i] & PTE_P)
  8041607a8c:	48 8b 01             	mov    (%rcx),%rax
  8041607a8f:	a8 01                	test   $0x1,%al
  8041607a91:	74 72                	je     8041607b05 <mem_init+0x28d2>
            assert(pgdir[i] & PTE_W);
  8041607a93:	a8 02                	test   $0x2,%al
  8041607a95:	0f 85 4a 07 00 00    	jne    80416081e5 <mem_init+0x2fb2>
  8041607a9b:	48 b9 6a cd 60 41 80 	movabs $0x804160cd6a,%rcx
  8041607aa2:	00 00 00 
  8041607aa5:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607aac:	00 00 00 
  8041607aaf:	be 07 04 00 00       	mov    $0x407,%esi
  8041607ab4:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607abb:	00 00 00 
  8041607abe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ac3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607aca:	00 00 00 
  8041607acd:	41 ff d0             	callq  *%r8
        assert(pgdir[i] & PTE_P);
  8041607ad0:	48 b9 59 cd 60 41 80 	movabs $0x804160cd59,%rcx
  8041607ad7:	00 00 00 
  8041607ada:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607ae1:	00 00 00 
  8041607ae4:	be 02 04 00 00       	mov    $0x402,%esi
  8041607ae9:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607af0:	00 00 00 
  8041607af3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607af8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607aff:	00 00 00 
  8041607b02:	41 ff d0             	callq  *%r8
            assert(pgdir[i] == 0);
  8041607b05:	48 85 c0             	test   %rax,%rax
  8041607b08:	0f 84 d7 06 00 00    	je     80416081e5 <mem_init+0x2fb2>
  8041607b0e:	48 b9 7b cd 60 41 80 	movabs $0x804160cd7b,%rcx
  8041607b15:	00 00 00 
  8041607b18:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607b1f:	00 00 00 
  8041607b22:	be 09 04 00 00       	mov    $0x409,%esi
  8041607b27:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607b2e:	00 00 00 
  8041607b31:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b36:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b3d:	00 00 00 
  8041607b40:	41 ff d0             	callq  *%r8
  cprintf("check_kern_pml4e() succeeded!\n");
  8041607b43:	48 bf f8 c8 60 41 80 	movabs $0x804160c8f8,%rdi
  8041607b4a:	00 00 00 
  8041607b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b52:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041607b59:	00 00 00 
  8041607b5c:	ff d2                	callq  *%rdx
  mmap_base = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)uefi_lp->MemoryMapVirt;
  8041607b5e:	48 b9 00 e0 61 41 80 	movabs $0x804161e000,%rcx
  8041607b65:	00 00 00 
  8041607b68:	48 8b 11             	mov    (%rcx),%rdx
  8041607b6b:	48 8b 42 30          	mov    0x30(%rdx),%rax
  8041607b6f:	48 a3 90 eb 61 41 80 	movabs %rax,0x804161eb90
  8041607b76:	00 00 00 
  mmap_end  = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)uefi_lp->MemoryMapVirt + uefi_lp->MemoryMapSize);
  8041607b79:	48 03 42 38          	add    0x38(%rdx),%rax
  8041607b7d:	48 a3 88 eb 61 41 80 	movabs %rax,0x804161eb88
  8041607b84:	00 00 00 
  uefi_lp   = (LOADER_PARAMS *)uefi_lp->SelfVirtual;
  8041607b87:	48 8b 12             	mov    (%rdx),%rdx
  8041607b8a:	48 89 11             	mov    %rdx,(%rcx)
  __asm __volatile("movq %0,%%cr3"
  8041607b8d:	48 a1 68 00 62 41 80 	movabs 0x8041620068,%rax
  8041607b94:	00 00 00 
  8041607b97:	0f 22 d8             	mov    %rax,%cr3
  __asm __volatile("movq %%cr0,%0"
  8041607b9a:	0f 20 c0             	mov    %cr0,%rax
    cr0 &= ~(CR0_TS | CR0_EM);
  8041607b9d:	48 83 e0 f3          	and    $0xfffffffffffffff3,%rax
  8041607ba1:	b9 23 00 05 80       	mov    $0x80050023,%ecx
  8041607ba6:	48 09 c8             	or     %rcx,%rax
  __asm __volatile("movq %0,%%cr0"
  8041607ba9:	0f 22 c0             	mov    %rax,%cr0
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607bac:	48 8b 4a 40          	mov    0x40(%rdx),%rcx
  uintptr_t size     = lp->FrameBufferSize;
  8041607bb0:	8b 52 48             	mov    0x48(%rdx),%edx
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607bb3:	48 bb 60 00 62 41 80 	movabs $0x8041620060,%rbx
  8041607bba:	00 00 00 
  8041607bbd:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041607bc3:	48 be 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rsi
  8041607bca:	00 00 00 
  8041607bcd:	48 8b 3b             	mov    (%rbx),%rdi
  8041607bd0:	48 b8 ac 4f 60 41 80 	movabs $0x8041604fac,%rax
  8041607bd7:	00 00 00 
  8041607bda:	ff d0                	callq  *%rax
check_page_installed_pml4(void) {
  struct PageInfo *pp0, *pp1, *pp2;
  pml4e_t pml4e_old; //used to store value instead of pointer

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041607bdc:	48 8b 03             	mov    (%rbx),%rax
  8041607bdf:	4c 8b 30             	mov    (%rax),%r14
  kern_pml4e[0] = 0;
  8041607be2:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  8041607be9:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607bee:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041607bf5:	00 00 00 
  8041607bf8:	ff d0                	callq  *%rax
  8041607bfa:	49 89 c4             	mov    %rax,%r12
  8041607bfd:	48 85 c0             	test   %rax,%rax
  8041607c00:	0f 84 aa 02 00 00    	je     8041607eb0 <mem_init+0x2c7d>
  assert((pp1 = page_alloc(0)));
  8041607c06:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607c0b:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041607c12:	00 00 00 
  8041607c15:	ff d0                	callq  *%rax
  8041607c17:	49 89 c5             	mov    %rax,%r13
  8041607c1a:	48 85 c0             	test   %rax,%rax
  8041607c1d:	0f 84 c2 02 00 00    	je     8041607ee5 <mem_init+0x2cb2>
  assert((pp2 = page_alloc(0)));
  8041607c23:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607c28:	48 b8 0d 4a 60 41 80 	movabs $0x8041604a0d,%rax
  8041607c2f:	00 00 00 
  8041607c32:	ff d0                	callq  *%rax
  8041607c34:	48 89 c3             	mov    %rax,%rbx
  8041607c37:	48 85 c0             	test   %rax,%rax
  8041607c3a:	0f 84 da 02 00 00    	je     8041607f1a <mem_init+0x2ce7>
  page_free(pp0);
  8041607c40:	4c 89 e7             	mov    %r12,%rdi
  8041607c43:	48 b8 06 4b 60 41 80 	movabs $0x8041604b06,%rax
  8041607c4a:	00 00 00 
  8041607c4d:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607c4f:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041607c56:	00 00 00 
  8041607c59:	4c 89 e9             	mov    %r13,%rcx
  8041607c5c:	48 2b 08             	sub    (%rax),%rcx
  8041607c5f:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607c63:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607c67:	48 89 ca             	mov    %rcx,%rdx
  8041607c6a:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607c6e:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  8041607c75:	00 00 00 
  8041607c78:	48 3b 10             	cmp    (%rax),%rdx
  8041607c7b:	0f 83 ce 02 00 00    	jae    8041607f4f <mem_init+0x2d1c>
  return (void *)(pa + KERNBASE);
  8041607c81:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607c88:	00 00 00 
  8041607c8b:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp1), 1, PGSIZE);
  8041607c8e:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607c93:	be 01 00 00 00       	mov    $0x1,%esi
  8041607c98:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041607c9f:	00 00 00 
  8041607ca2:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607ca4:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041607cab:	00 00 00 
  8041607cae:	48 89 d9             	mov    %rbx,%rcx
  8041607cb1:	48 2b 08             	sub    (%rax),%rcx
  8041607cb4:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607cb8:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607cbc:	48 89 ca             	mov    %rcx,%rdx
  8041607cbf:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607cc3:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  8041607cca:	00 00 00 
  8041607ccd:	48 3b 10             	cmp    (%rax),%rdx
  8041607cd0:	0f 83 a4 02 00 00    	jae    8041607f7a <mem_init+0x2d47>
  return (void *)(pa + KERNBASE);
  8041607cd6:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607cdd:	00 00 00 
  8041607ce0:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp2), 2, PGSIZE);
  8041607ce3:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607ce8:	be 02 00 00 00       	mov    $0x2,%esi
  8041607ced:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041607cf4:	00 00 00 
  8041607cf7:	ff d0                	callq  *%rax
  page_insert(kern_pml4e, pp1, (void *)PGSIZE, PTE_W);
  8041607cf9:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607cfe:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607d03:	4c 89 ee             	mov    %r13,%rsi
  8041607d06:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041607d0d:	00 00 00 
  8041607d10:	48 8b 38             	mov    (%rax),%rdi
  8041607d13:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  8041607d1a:	00 00 00 
  8041607d1d:	ff d0                	callq  *%rax
  assert(pp1->pp_ref == 1);
  8041607d1f:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041607d25:	0f 85 7a 02 00 00    	jne    8041607fa5 <mem_init+0x2d72>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041607d2b:	81 3c 25 00 10 00 00 	cmpl   $0x1010101,0x1000
  8041607d32:	01 01 01 01 
  8041607d36:	0f 85 9e 02 00 00    	jne    8041607fda <mem_init+0x2da7>
  page_insert(kern_pml4e, pp2, (void *)PGSIZE, PTE_W);
  8041607d3c:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607d41:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607d46:	48 89 de             	mov    %rbx,%rsi
  8041607d49:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041607d50:	00 00 00 
  8041607d53:	48 8b 38             	mov    (%rax),%rdi
  8041607d56:	48 b8 13 51 60 41 80 	movabs $0x8041605113,%rax
  8041607d5d:	00 00 00 
  8041607d60:	ff d0                	callq  *%rax
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  8041607d62:	81 3c 25 00 10 00 00 	cmpl   $0x2020202,0x1000
  8041607d69:	02 02 02 02 
  8041607d6d:	0f 85 9c 02 00 00    	jne    804160800f <mem_init+0x2ddc>
  assert(pp2->pp_ref == 1);
  8041607d73:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041607d78:	0f 85 c6 02 00 00    	jne    8041608044 <mem_init+0x2e11>
  assert(pp1->pp_ref == 0);
  8041607d7e:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041607d84:	0f 85 ef 02 00 00    	jne    8041608079 <mem_init+0x2e46>
  *(uint32_t *)PGSIZE = 0x03030303U;
  8041607d8a:	c7 04 25 00 10 00 00 	movl   $0x3030303,0x1000
  8041607d91:	03 03 03 03 
  return (pp - pages) << PGSHIFT;
  8041607d95:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041607d9c:	00 00 00 
  8041607d9f:	48 89 d9             	mov    %rbx,%rcx
  8041607da2:	48 2b 08             	sub    (%rax),%rcx
  8041607da5:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607da9:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607dad:	48 89 ca             	mov    %rcx,%rdx
  8041607db0:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607db4:	48 b8 70 00 62 41 80 	movabs $0x8041620070,%rax
  8041607dbb:	00 00 00 
  8041607dbe:	48 3b 10             	cmp    (%rax),%rdx
  8041607dc1:	0f 83 e7 02 00 00    	jae    80416080ae <mem_init+0x2e7b>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  8041607dc7:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607dce:	00 00 00 
  8041607dd1:	81 3c 01 03 03 03 03 	cmpl   $0x3030303,(%rcx,%rax,1)
  8041607dd8:	0f 85 fb 02 00 00    	jne    80416080d9 <mem_init+0x2ea6>
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041607dde:	be 00 10 00 00       	mov    $0x1000,%esi
  8041607de3:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041607dea:	00 00 00 
  8041607ded:	48 8b 38             	mov    (%rax),%rdi
  8041607df0:	48 b8 ce 50 60 41 80 	movabs $0x80416050ce,%rax
  8041607df7:	00 00 00 
  8041607dfa:	ff d0                	callq  *%rax
  assert(pp2->pp_ref == 0);
  8041607dfc:	66 83 7b 08 00       	cmpw   $0x0,0x8(%rbx)
  8041607e01:	0f 85 07 03 00 00    	jne    804160810e <mem_init+0x2edb>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  8041607e07:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  8041607e0e:	00 00 00 
  8041607e11:	48 8b 08             	mov    (%rax),%rcx
  8041607e14:	48 8b 11             	mov    (%rcx),%rdx
  8041607e17:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041607e1e:	48 b8 78 00 62 41 80 	movabs $0x8041620078,%rax
  8041607e25:	00 00 00 
  8041607e28:	4c 89 e7             	mov    %r12,%rdi
  8041607e2b:	48 2b 38             	sub    (%rax),%rdi
  8041607e2e:	48 89 f8             	mov    %rdi,%rax
  8041607e31:	48 c1 f8 04          	sar    $0x4,%rax
  8041607e35:	48 c1 e0 0c          	shl    $0xc,%rax
  8041607e39:	48 39 c2             	cmp    %rax,%rdx
  8041607e3c:	0f 85 01 03 00 00    	jne    8041608143 <mem_init+0x2f10>
  kern_pml4e[0] = 0;
  8041607e42:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  assert(pp0->pp_ref == 1);
  8041607e49:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041607e50:	0f 85 22 03 00 00    	jne    8041608178 <mem_init+0x2f45>
  pp0->pp_ref = 0;
  8041607e56:	66 41 c7 44 24 08 00 	movw   $0x0,0x8(%r12)
  8041607e5d:	00 

  // free the pages we took
  page_free(pp0);
  8041607e5e:	4c 89 e7             	mov    %r12,%rdi
  8041607e61:	48 b8 06 4b 60 41 80 	movabs $0x8041604b06,%rax
  8041607e68:	00 00 00 
  8041607e6b:	ff d0                	callq  *%rax

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041607e6d:	48 a1 60 00 62 41 80 	movabs 0x8041620060,%rax
  8041607e74:	00 00 00 
  8041607e77:	4c 89 30             	mov    %r14,(%rax)

  cprintf("check_page_installed_pml4() succeeded!\n");
  8041607e7a:	48 bf c0 c9 60 41 80 	movabs $0x804160c9c0,%rdi
  8041607e81:	00 00 00 
  8041607e84:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607e89:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041607e90:	00 00 00 
  8041607e93:	ff d2                	callq  *%rdx
  struct PageInfo *pp = page_free_list, *pt = NULL;
  8041607e95:	48 b8 a8 eb 61 41 80 	movabs $0x804161eba8,%rax
  8041607e9c:	00 00 00 
  8041607e9f:	48 8b 10             	mov    (%rax),%rdx
  while (pp) {
  8041607ea2:	48 85 d2             	test   %rdx,%rdx
  8041607ea5:	0f 85 05 03 00 00    	jne    80416081b0 <mem_init+0x2f7d>
  8041607eab:	e9 08 03 00 00       	jmpq   80416081b8 <mem_init+0x2f85>
  assert((pp0 = page_alloc(0)));
  8041607eb0:	48 b9 d4 cc 60 41 80 	movabs $0x804160ccd4,%rcx
  8041607eb7:	00 00 00 
  8041607eba:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607ec1:	00 00 00 
  8041607ec4:	be f7 04 00 00       	mov    $0x4f7,%esi
  8041607ec9:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607ed0:	00 00 00 
  8041607ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ed8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607edf:	00 00 00 
  8041607ee2:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607ee5:	48 b9 ea cc 60 41 80 	movabs $0x804160ccea,%rcx
  8041607eec:	00 00 00 
  8041607eef:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607ef6:	00 00 00 
  8041607ef9:	be f8 04 00 00       	mov    $0x4f8,%esi
  8041607efe:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607f05:	00 00 00 
  8041607f08:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f0d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607f14:	00 00 00 
  8041607f17:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041607f1a:	48 b9 00 cd 60 41 80 	movabs $0x804160cd00,%rcx
  8041607f21:	00 00 00 
  8041607f24:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607f2b:	00 00 00 
  8041607f2e:	be f9 04 00 00       	mov    $0x4f9,%esi
  8041607f33:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607f3a:	00 00 00 
  8041607f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f42:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607f49:	00 00 00 
  8041607f4c:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041607f4f:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041607f56:	00 00 00 
  8041607f59:	be 60 00 00 00       	mov    $0x60,%esi
  8041607f5e:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  8041607f65:	00 00 00 
  8041607f68:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f6d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607f74:	00 00 00 
  8041607f77:	41 ff d0             	callq  *%r8
  8041607f7a:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  8041607f81:	00 00 00 
  8041607f84:	be 60 00 00 00       	mov    $0x60,%esi
  8041607f89:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  8041607f90:	00 00 00 
  8041607f93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f98:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607f9f:	00 00 00 
  8041607fa2:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041607fa5:	48 b9 e5 cb 60 41 80 	movabs $0x804160cbe5,%rcx
  8041607fac:	00 00 00 
  8041607faf:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607fb6:	00 00 00 
  8041607fb9:	be fe 04 00 00       	mov    $0x4fe,%esi
  8041607fbe:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607fc5:	00 00 00 
  8041607fc8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fcd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607fd4:	00 00 00 
  8041607fd7:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041607fda:	48 b9 18 c9 60 41 80 	movabs $0x804160c918,%rcx
  8041607fe1:	00 00 00 
  8041607fe4:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041607feb:	00 00 00 
  8041607fee:	be ff 04 00 00       	mov    $0x4ff,%esi
  8041607ff3:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041607ffa:	00 00 00 
  8041607ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608002:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608009:	00 00 00 
  804160800c:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  804160800f:	48 b9 40 c9 60 41 80 	movabs $0x804160c940,%rcx
  8041608016:	00 00 00 
  8041608019:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041608020:	00 00 00 
  8041608023:	be 01 05 00 00       	mov    $0x501,%esi
  8041608028:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160802f:	00 00 00 
  8041608032:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608037:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160803e:	00 00 00 
  8041608041:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 1);
  8041608044:	48 b9 89 cd 60 41 80 	movabs $0x804160cd89,%rcx
  804160804b:	00 00 00 
  804160804e:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041608055:	00 00 00 
  8041608058:	be 02 05 00 00       	mov    $0x502,%esi
  804160805d:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041608064:	00 00 00 
  8041608067:	b8 00 00 00 00       	mov    $0x0,%eax
  804160806c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608073:	00 00 00 
  8041608076:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041608079:	48 b9 60 cc 60 41 80 	movabs $0x804160cc60,%rcx
  8041608080:	00 00 00 
  8041608083:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160808a:	00 00 00 
  804160808d:	be 03 05 00 00       	mov    $0x503,%esi
  8041608092:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041608099:	00 00 00 
  804160809c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080a1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080a8:	00 00 00 
  80416080ab:	41 ff d0             	callq  *%r8
  80416080ae:	48 ba b8 c0 60 41 80 	movabs $0x804160c0b8,%rdx
  80416080b5:	00 00 00 
  80416080b8:	be 60 00 00 00       	mov    $0x60,%esi
  80416080bd:	48 bf bc ca 60 41 80 	movabs $0x804160cabc,%rdi
  80416080c4:	00 00 00 
  80416080c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080cc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080d3:	00 00 00 
  80416080d6:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  80416080d9:	48 b9 68 c9 60 41 80 	movabs $0x804160c968,%rcx
  80416080e0:	00 00 00 
  80416080e3:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416080ea:	00 00 00 
  80416080ed:	be 05 05 00 00       	mov    $0x505,%esi
  80416080f2:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  80416080f9:	00 00 00 
  80416080fc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608101:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608108:	00 00 00 
  804160810b:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 0);
  804160810e:	48 b9 9a cd 60 41 80 	movabs $0x804160cd9a,%rcx
  8041608115:	00 00 00 
  8041608118:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160811f:	00 00 00 
  8041608122:	be 07 05 00 00       	mov    $0x507,%esi
  8041608127:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  804160812e:	00 00 00 
  8041608131:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608136:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160813d:	00 00 00 
  8041608140:	41 ff d0             	callq  *%r8
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  8041608143:	48 b9 98 c9 60 41 80 	movabs $0x804160c998,%rcx
  804160814a:	00 00 00 
  804160814d:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041608154:	00 00 00 
  8041608157:	be 0a 05 00 00       	mov    $0x50a,%esi
  804160815c:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041608163:	00 00 00 
  8041608166:	b8 00 00 00 00       	mov    $0x0,%eax
  804160816b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608172:	00 00 00 
  8041608175:	41 ff d0             	callq  *%r8
  assert(pp0->pp_ref == 1);
  8041608178:	48 b9 ab cd 60 41 80 	movabs $0x804160cdab,%rcx
  804160817f:	00 00 00 
  8041608182:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  8041608189:	00 00 00 
  804160818c:	be 0c 05 00 00       	mov    $0x50c,%esi
  8041608191:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041608198:	00 00 00 
  804160819b:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081a0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081a7:	00 00 00 
  80416081aa:	41 ff d0             	callq  *%r8
    pp = pp->pp_link;
  80416081ad:	48 89 c2             	mov    %rax,%rdx
  80416081b0:	48 8b 02             	mov    (%rdx),%rax
  while (pp) {
  80416081b3:	48 85 c0             	test   %rax,%rax
  80416081b6:	75 f5                	jne    80416081ad <mem_init+0x2f7a>
  page_free_list_top = evaluate_page_free_list_top();
  80416081b8:	48 89 d0             	mov    %rdx,%rax
  80416081bb:	48 a3 a0 eb 61 41 80 	movabs %rax,0x804161eba0
  80416081c2:	00 00 00 
  check_page_free_list(0);
  80416081c5:	bf 00 00 00 00       	mov    $0x0,%edi
  80416081ca:	48 b8 55 43 60 41 80 	movabs $0x8041604355,%rax
  80416081d1:	00 00 00 
  80416081d4:	ff d0                	callq  *%rax
}
  80416081d6:	48 83 c4 38          	add    $0x38,%rsp
  80416081da:	5b                   	pop    %rbx
  80416081db:	41 5c                	pop    %r12
  80416081dd:	41 5d                	pop    %r13
  80416081df:	41 5e                	pop    %r14
  80416081e1:	41 5f                	pop    %r15
  80416081e3:	5d                   	pop    %rbp
  80416081e4:	c3                   	retq   
  for (i = 0; i < NPDENTRIES; i++) {
  80416081e5:	49 83 c5 01          	add    $0x1,%r13
  80416081e9:	48 83 c1 08          	add    $0x8,%rcx
  80416081ed:	e9 79 f8 ff ff       	jmpq   8041607a6b <mem_init+0x2838>

00000080416081f2 <tlb_invalidate>:
  __asm __volatile("invlpg (%0)"
  80416081f2:	0f 01 3e             	invlpg (%rsi)
}
  80416081f5:	c3                   	retq   

00000080416081f6 <mmio_map_region>:
mmio_map_region(physaddr_t pa, size_t size) {
  80416081f6:	55                   	push   %rbp
  80416081f7:	48 89 e5             	mov    %rsp,%rbp
  80416081fa:	53                   	push   %rbx
  80416081fb:	48 83 ec 08          	sub    $0x8,%rsp
  uintptr_t pa2 = ROUNDDOWN(pa, PGSIZE);
  80416081ff:	48 89 f9             	mov    %rdi,%rcx
  8041608202:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (base + size >= MMIOLIM)
  8041608209:	48 a1 20 e7 61 41 80 	movabs 0x804161e720,%rax
  8041608210:	00 00 00 
  8041608213:	4c 8d 04 30          	lea    (%rax,%rsi,1),%r8
  8041608217:	48 ba ff ff df 3f 80 	movabs $0x803fdfffff,%rdx
  804160821e:	00 00 00 
  8041608221:	49 39 d0             	cmp    %rdx,%r8
  8041608224:	77 54                	ja     804160827a <mmio_map_region+0x84>
  size = ROUNDUP(size + (pa - pa2), PGSIZE);
  8041608226:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
  804160822c:	48 8d 9c 3e ff 0f 00 	lea    0xfff(%rsi,%rdi,1),%rbx
  8041608233:	00 
  8041608234:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  boot_map_region(kern_pml4e, base, size, pa2, PTE_PCD | PTE_PWT | PTE_W);
  804160823b:	41 b8 1a 00 00 00    	mov    $0x1a,%r8d
  8041608241:	48 89 da             	mov    %rbx,%rdx
  8041608244:	48 89 c6             	mov    %rax,%rsi
  8041608247:	48 b8 60 00 62 41 80 	movabs $0x8041620060,%rax
  804160824e:	00 00 00 
  8041608251:	48 8b 38             	mov    (%rax),%rdi
  8041608254:	48 b8 ac 4f 60 41 80 	movabs $0x8041604fac,%rax
  804160825b:	00 00 00 
  804160825e:	ff d0                	callq  *%rax
  void *new = (void *)base;
  8041608260:	48 ba 20 e7 61 41 80 	movabs $0x804161e720,%rdx
  8041608267:	00 00 00 
  804160826a:	48 8b 02             	mov    (%rdx),%rax
  base += size;
  804160826d:	48 01 c3             	add    %rax,%rbx
  8041608270:	48 89 1a             	mov    %rbx,(%rdx)
}
  8041608273:	48 83 c4 08          	add    $0x8,%rsp
  8041608277:	5b                   	pop    %rbx
  8041608278:	5d                   	pop    %rbp
  8041608279:	c3                   	retq   
    panic("Allocated MMIO addr is too damn high! [0x%016lu;0x%016lu]", pa, pa + size);
  804160827a:	4c 8d 04 37          	lea    (%rdi,%rsi,1),%r8
  804160827e:	48 89 f9             	mov    %rdi,%rcx
  8041608281:	48 ba e8 c9 60 41 80 	movabs $0x804160c9e8,%rdx
  8041608288:	00 00 00 
  804160828b:	be 33 03 00 00       	mov    $0x333,%esi
  8041608290:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041608297:	00 00 00 
  804160829a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160829f:	49 b9 5a 02 60 41 80 	movabs $0x804160025a,%r9
  80416082a6:	00 00 00 
  80416082a9:	41 ff d1             	callq  *%r9

00000080416082ac <mmio_remap_last_region>:
mmio_remap_last_region(physaddr_t pa, void *addr, size_t oldsize, size_t newsize) {
  80416082ac:	55                   	push   %rbp
  80416082ad:	48 89 e5             	mov    %rsp,%rbp
  if (base - oldsize != (uintptr_t)addr)
  80416082b0:	48 a1 20 e7 61 41 80 	movabs 0x804161e720,%rax
  80416082b7:	00 00 00 
  80416082ba:	4c 8d 04 06          	lea    (%rsi,%rax,1),%r8
  oldsize               = ROUNDUP((uintptr_t)addr + oldsize, PGSIZE) - (uintptr_t)addr;
  80416082be:	48 8d 84 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%rax
  80416082c5:	00 
  if (base - oldsize != (uintptr_t)addr)
  80416082c6:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416082cc:	49 29 c0             	sub    %rax,%r8
  80416082cf:	4c 39 c6             	cmp    %r8,%rsi
  80416082d2:	75 1e                	jne    80416082f2 <mmio_remap_last_region+0x46>
  base = (uintptr_t)addr;
  80416082d4:	48 89 f0             	mov    %rsi,%rax
  80416082d7:	48 a3 20 e7 61 41 80 	movabs %rax,0x804161e720
  80416082de:	00 00 00 
  return mmio_map_region(pa, newsize);
  80416082e1:	48 89 ce             	mov    %rcx,%rsi
  80416082e4:	48 b8 f6 81 60 41 80 	movabs $0x80416081f6,%rax
  80416082eb:	00 00 00 
  80416082ee:	ff d0                	callq  *%rax
}
  80416082f0:	5d                   	pop    %rbp
  80416082f1:	c3                   	retq   
    panic("You dare to remap non-last region?!");
  80416082f2:	48 ba 28 ca 60 41 80 	movabs $0x804160ca28,%rdx
  80416082f9:	00 00 00 
  80416082fc:	be 42 03 00 00       	mov    $0x342,%esi
  8041608301:	48 bf 4c ca 60 41 80 	movabs $0x804160ca4c,%rdi
  8041608308:	00 00 00 
  804160830b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608310:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608317:	00 00 00 
  804160831a:	ff d1                	callq  *%rcx

000000804160831c <envid2env>:
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
  804160831c:	85 ff                	test   %edi,%edi
  804160831e:	74 5c                	je     804160837c <envid2env+0x60>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  8041608320:	89 f8                	mov    %edi,%eax
  8041608322:	83 e0 1f             	and    $0x1f,%eax
  8041608325:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
  804160832c:	00 
  804160832d:	48 29 c1             	sub    %rax,%rcx
  8041608330:	48 c1 e1 05          	shl    $0x5,%rcx
  8041608334:	48 a1 a8 e7 61 41 80 	movabs 0x804161e7a8,%rax
  804160833b:	00 00 00 
  804160833e:	48 01 c1             	add    %rax,%rcx
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  8041608341:	83 b9 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rcx)
  8041608348:	74 42                	je     804160838c <envid2env+0x70>
  804160834a:	39 b9 c8 00 00 00    	cmp    %edi,0xc8(%rcx)
  8041608350:	75 3a                	jne    804160838c <envid2env+0x70>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  8041608352:	84 d2                	test   %dl,%dl
  8041608354:	74 1d                	je     8041608373 <envid2env+0x57>
  8041608356:	48 a1 b8 eb 61 41 80 	movabs 0x804161ebb8,%rax
  804160835d:	00 00 00 
  8041608360:	48 39 c8             	cmp    %rcx,%rax
  8041608363:	74 0e                	je     8041608373 <envid2env+0x57>
  8041608365:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  804160836b:	39 81 cc 00 00 00    	cmp    %eax,0xcc(%rcx)
  8041608371:	75 26                	jne    8041608399 <envid2env+0x7d>
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  8041608373:	48 89 0e             	mov    %rcx,(%rsi)
  return 0;
  8041608376:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160837b:	c3                   	retq   
    *env_store = curenv;
  804160837c:	48 a1 b8 eb 61 41 80 	movabs 0x804161ebb8,%rax
  8041608383:	00 00 00 
  8041608386:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  8041608389:	89 f8                	mov    %edi,%eax
  804160838b:	c3                   	retq   
    *env_store = 0;
  804160838c:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041608393:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041608398:	c3                   	retq   
    *env_store = 0;
  8041608399:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416083a0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  80416083a5:	c3                   	retq   

00000080416083a6 <env_init_percpu>:
  env_init_percpu();
}

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  80416083a6:	55                   	push   %rbp
  80416083a7:	48 89 e5             	mov    %rsp,%rbp
  80416083aa:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  80416083ab:	48 b8 40 e7 61 41 80 	movabs $0x804161e740,%rax
  80416083b2:	00 00 00 
  80416083b5:	0f 01 10             	lgdt   (%rax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  80416083b8:	b8 33 00 00 00       	mov    $0x33,%eax
  80416083bd:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  80416083bf:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  80416083c1:	b8 10 00 00 00       	mov    $0x10,%eax
  80416083c6:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  80416083c8:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  80416083ca:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  80416083cc:	bb 08 00 00 00       	mov    $0x8,%ebx
  80416083d1:	53                   	push   %rbx
  80416083d2:	48 b8 df 83 60 41 80 	movabs $0x80416083df,%rax
  80416083d9:	00 00 00 
  80416083dc:	50                   	push   %rax
  80416083dd:	48 cb                	lretq  
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  80416083df:	66 b8 00 00          	mov    $0x0,%ax
  80416083e3:	0f 00 d0             	lldt   %ax
               :
               :
               : "cc", "memory");
}
  80416083e6:	5b                   	pop    %rbx
  80416083e7:	5d                   	pop    %rbp
  80416083e8:	c3                   	retq   

00000080416083e9 <env_init>:
env_init(void) {
  80416083e9:	55                   	push   %rbp
  80416083ea:	48 89 e5             	mov    %rsp,%rbp
    envs[i].env_link = env_free_list;
  80416083ed:	48 b8 a8 e7 61 41 80 	movabs $0x804161e7a8,%rax
  80416083f4:	00 00 00 
  80416083f7:	48 8b 38             	mov    (%rax),%rdi
  80416083fa:	48 8d 87 20 1b 00 00 	lea    0x1b20(%rdi),%rax
  8041608401:	48 89 fe             	mov    %rdi,%rsi
  8041608404:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608409:	eb 03                	jmp    804160840e <env_init+0x25>
  804160840b:	48 89 c8             	mov    %rcx,%rax
  804160840e:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    envs[i].env_id   = 0;
  8041608415:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%rax)
  804160841c:	00 00 00 
  for (int i = NENV - 1; i >= 0; i--) {
  804160841f:	48 8d 88 20 ff ff ff 	lea    -0xe0(%rax),%rcx
    env_free_list    = &envs[i];
  8041608426:	48 89 c2             	mov    %rax,%rdx
  for (int i = NENV - 1; i >= 0; i--) {
  8041608429:	48 39 f0             	cmp    %rsi,%rax
  804160842c:	75 dd                	jne    804160840b <env_init+0x22>
  804160842e:	48 89 f8             	mov    %rdi,%rax
  8041608431:	48 a3 c0 eb 61 41 80 	movabs %rax,0x804161ebc0
  8041608438:	00 00 00 
  env_init_percpu();
  804160843b:	48 b8 a6 83 60 41 80 	movabs $0x80416083a6,%rax
  8041608442:	00 00 00 
  8041608445:	ff d0                	callq  *%rax
}
  8041608447:	5d                   	pop    %rbp
  8041608448:	c3                   	retq   

0000008041608449 <env_alloc>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  8041608449:	55                   	push   %rbp
  804160844a:	48 89 e5             	mov    %rsp,%rbp
  804160844d:	41 54                	push   %r12
  804160844f:	53                   	push   %rbx
  int32_t generation;
  struct Env *e;

  if (!(e = env_free_list)) {
  8041608450:	48 b8 c0 eb 61 41 80 	movabs $0x804161ebc0,%rax
  8041608457:	00 00 00 
  804160845a:	48 8b 18             	mov    (%rax),%rbx
  804160845d:	48 85 db             	test   %rbx,%rbx
  8041608460:	0f 84 d6 00 00 00    	je     804160853c <env_alloc+0xf3>
  8041608466:	49 89 fc             	mov    %rdi,%r12
    return -E_NO_FREE_ENV;
  }

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  8041608469:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  804160846f:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041608474:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  8041608477:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160847c:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  804160847f:	48 ba a8 e7 61 41 80 	movabs $0x804161e7a8,%rdx
  8041608486:	00 00 00 
  8041608489:	48 89 d9             	mov    %rbx,%rcx
  804160848c:	48 2b 0a             	sub    (%rdx),%rcx
  804160848f:	48 89 ca             	mov    %rcx,%rdx
  8041608492:	48 c1 fa 05          	sar    $0x5,%rdx
  8041608496:	69 d2 b7 6d db b6    	imul   $0xb6db6db7,%edx,%edx
  804160849c:	09 d0                	or     %edx,%eax
  804160849e:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
  80416084a4:	89 b3 cc 00 00 00    	mov    %esi,0xcc(%rbx)
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
#else
#endif
  e->env_status = ENV_RUNNABLE;
  80416084aa:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  80416084b1:	00 00 00 
  e->env_runs   = 0;
  80416084b4:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  80416084bb:	00 00 00 

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  80416084be:	ba c0 00 00 00       	mov    $0xc0,%edx
  80416084c3:	be 00 00 00 00       	mov    $0x0,%esi
  80416084c8:	48 89 df             	mov    %rbx,%rdi
  80416084cb:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  80416084d2:	00 00 00 
  80416084d5:	ff d0                	callq  *%rax
  e->env_tf.tf_rsp     = STACK_TOP - (e - envs) * 2 * PGSIZE;

#else
#endif

  e->env_tf.tf_rflags |= FL_IF;
  80416084d7:	48 81 8b a8 00 00 00 	orq    $0x200,0xa8(%rbx)
  80416084de:	00 02 00 00 

  // You will set e->env_tf.tf_rip later.

  // commit the allocation
  env_free_list = e->env_link;
  80416084e2:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  80416084e9:	48 a3 c0 eb 61 41 80 	movabs %rax,0x804161ebc0
  80416084f0:	00 00 00 
  *newenv_store = e;
  80416084f3:	49 89 1c 24          	mov    %rbx,(%r12)

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  80416084f7:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  80416084fd:	48 a1 b8 eb 61 41 80 	movabs 0x804161ebb8,%rax
  8041608504:	00 00 00 
  8041608507:	be 00 00 00 00       	mov    $0x0,%esi
  804160850c:	48 85 c0             	test   %rax,%rax
  804160850f:	74 06                	je     8041608517 <env_alloc+0xce>
  8041608511:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041608517:	48 bf bc cd 60 41 80 	movabs $0x804160cdbc,%rdi
  804160851e:	00 00 00 
  8041608521:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608526:	48 b9 9c 8a 60 41 80 	movabs $0x8041608a9c,%rcx
  804160852d:	00 00 00 
  8041608530:	ff d1                	callq  *%rcx

  return 0;
  8041608532:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041608537:	5b                   	pop    %rbx
  8041608538:	41 5c                	pop    %r12
  804160853a:	5d                   	pop    %rbp
  804160853b:	c3                   	retq   
    return -E_NO_FREE_ENV;
  804160853c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  8041608541:	eb f4                	jmp    8041608537 <env_alloc+0xee>

0000008041608543 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  8041608543:	55                   	push   %rbp
  8041608544:	48 89 e5             	mov    %rsp,%rbp
  8041608547:	41 57                	push   %r15
  8041608549:	41 56                	push   %r14
  804160854b:	41 55                	push   %r13
  804160854d:	41 54                	push   %r12
  804160854f:	53                   	push   %rbx
  8041608550:	48 83 ec 28          	sub    $0x28,%rsp
  8041608554:	49 89 fc             	mov    %rdi,%r12
  8041608557:	89 f3                	mov    %esi,%ebx

  // LAB 3 code
  struct Env *newenv;
  if (env_alloc(&newenv, 0) < 0) {
  8041608559:	be 00 00 00 00       	mov    $0x0,%esi
  804160855e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041608562:	48 b8 49 84 60 41 80 	movabs $0x8041608449,%rax
  8041608569:	00 00 00 
  804160856c:	ff d0                	callq  *%rax
  804160856e:	85 c0                	test   %eax,%eax
  8041608570:	78 33                	js     80416085a5 <env_create+0x62>
    panic("Can't allocate new environment"); // попытка выделить среду – если нет – вылет по панике ядра
  }

  newenv->env_type = type;
  8041608572:	4c 8b 7d c8          	mov    -0x38(%rbp),%r15
  8041608576:	41 89 9f d0 00 00 00 	mov    %ebx,0xd0(%r15)
  if (elf->e_magic != ELF_MAGIC) {
  804160857d:	41 81 3c 24 7f 45 4c 	cmpl   $0x464c457f,(%r12)
  8041608584:	46 
  8041608585:	75 48                	jne    80416085cf <env_create+0x8c>
  struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff); // Proghdr = prog header. Он лежит со смещением elf->e_phoff относительно начала фаила
  8041608587:	49 8b 5c 24 20       	mov    0x20(%r12),%rbx
  for (size_t i = 0; i < elf->e_phnum; i++) { //elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  804160858c:	66 41 83 7c 24 38 00 	cmpw   $0x0,0x38(%r12)
  8041608593:	74 55                	je     80416085ea <env_create+0xa7>
  8041608595:	4c 01 e3             	add    %r12,%rbx
  8041608598:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  804160859f:	00 
  80416085a0:	e9 cc 00 00 00       	jmpq   8041608671 <env_create+0x12e>
    panic("Can't allocate new environment"); // попытка выделить среду – если нет – вылет по панике ядра
  80416085a5:	48 ba 10 ce 60 41 80 	movabs $0x804160ce10,%rdx
  80416085ac:	00 00 00 
  80416085af:	be 6c 01 00 00       	mov    $0x16c,%esi
  80416085b4:	48 bf d1 cd 60 41 80 	movabs $0x804160cdd1,%rdi
  80416085bb:	00 00 00 
  80416085be:	b8 00 00 00 00       	mov    $0x0,%eax
  80416085c3:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416085ca:	00 00 00 
  80416085cd:	ff d1                	callq  *%rcx
    cprintf("Unexpected ELF format\n");
  80416085cf:	48 bf dc cd 60 41 80 	movabs $0x804160cddc,%rdi
  80416085d6:	00 00 00 
  80416085d9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416085de:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  80416085e5:	00 00 00 
  80416085e8:	ff d2                	callq  *%rdx

  load_icode(newenv, binary); // load instruction code
}
  80416085ea:	48 83 c4 28          	add    $0x28,%rsp
  80416085ee:	5b                   	pop    %rbx
  80416085ef:	41 5c                	pop    %r12
  80416085f1:	41 5d                	pop    %r13
  80416085f3:	41 5e                	pop    %r14
  80416085f5:	41 5f                	pop    %r15
  80416085f7:	5d                   	pop    %rbp
  80416085f8:	c3                   	retq   
      void *dst = (void *)ph[i].p_va;
  80416085f9:	48 8b 43 10          	mov    0x10(%rbx),%rax
      size_t memsz  = ph[i].p_memsz;
  80416085fd:	4c 8b 6b 28          	mov    0x28(%rbx),%r13
      size_t filesz = MIN(ph[i].p_filesz, memsz);
  8041608601:	4c 39 6b 20          	cmp    %r13,0x20(%rbx)
  8041608605:	4d 89 ee             	mov    %r13,%r14
  8041608608:	4c 0f 46 73 20       	cmovbe 0x20(%rbx),%r14
      void *src = binary + ph[i].p_offset;
  804160860d:	4c 89 e6             	mov    %r12,%rsi
  8041608610:	48 03 73 08          	add    0x8(%rbx),%rsi
      memcpy(dst, src, filesz);                // копируем в dst (дистинейшн) src (код) размера filesz
  8041608614:	4c 89 f2             	mov    %r14,%rdx
  8041608617:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  804160861b:	48 89 c7             	mov    %rax,%rdi
  804160861e:	48 b9 08 af 60 41 80 	movabs $0x804160af08,%rcx
  8041608625:	00 00 00 
  8041608628:	ff d1                	callq  *%rcx
      memset(dst + filesz, 0, memsz - filesz); // обнуление памяти по адресу dst + filesz, где количество нулей = memsz - filesz. Т.е. зануляем всю выделенную память сегмента кода, оставшуюяся после копирования src. Возможно, эта строка не нужна
  804160862a:	4c 89 ea             	mov    %r13,%rdx
  804160862d:	4c 29 f2             	sub    %r14,%rdx
  8041608630:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041608634:	4a 8d 3c 30          	lea    (%rax,%r14,1),%rdi
  8041608638:	be 00 00 00 00       	mov    $0x0,%esi
  804160863d:	48 b8 57 ae 60 41 80 	movabs $0x804160ae57,%rax
  8041608644:	00 00 00 
  8041608647:	ff d0                	callq  *%rax
    e->env_tf.tf_rip = elf->e_entry; //Виртуальный адрес точки входа, которому система передает управление при запуске процесса. в регистр rip записываем адрес точки входа для выполнения процесса
  8041608649:	49 8b 44 24 18       	mov    0x18(%r12),%rax
  804160864e:	49 89 87 98 00 00 00 	mov    %rax,0x98(%r15)
  for (size_t i = 0; i < elf->e_phnum; i++) { //elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041608655:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  804160865a:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  804160865e:	48 83 c3 38          	add    $0x38,%rbx
  8041608662:	41 0f b7 44 24 38    	movzwl 0x38(%r12),%eax
  8041608668:	48 39 c1             	cmp    %rax,%rcx
  804160866b:	0f 83 79 ff ff ff    	jae    80416085ea <env_create+0xa7>
    if (ph[i].p_type == ELF_PROG_LOAD) {
  8041608671:	83 3b 01             	cmpl   $0x1,(%rbx)
  8041608674:	75 d3                	jne    8041608649 <env_create+0x106>
  8041608676:	eb 81                	jmp    80416085f9 <env_create+0xb6>

0000008041608678 <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041608678:	55                   	push   %rbp
  8041608679:	48 89 e5             	mov    %rsp,%rbp
  804160867c:	53                   	push   %rbx
  804160867d:	48 83 ec 08          	sub    $0x8,%rsp
  8041608681:	48 89 fb             	mov    %rdi,%rbx
  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608684:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  804160868a:	48 a1 b8 eb 61 41 80 	movabs 0x804161ebb8,%rax
  8041608691:	00 00 00 
  8041608694:	be 00 00 00 00       	mov    $0x0,%esi
  8041608699:	48 85 c0             	test   %rax,%rax
  804160869c:	74 06                	je     80416086a4 <env_free+0x2c>
  804160869e:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80416086a4:	48 bf f3 cd 60 41 80 	movabs $0x804160cdf3,%rdi
  80416086ab:	00 00 00 
  80416086ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416086b3:	48 b9 9c 8a 60 41 80 	movabs $0x8041608a9c,%rcx
  80416086ba:	00 00 00 
  80416086bd:	ff d1                	callq  *%rcx

  // return the environment to the free list
  e->env_status = ENV_FREE;
  80416086bf:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  80416086c6:	00 00 00 
  e->env_link   = env_free_list;
  80416086c9:	48 b8 c0 eb 61 41 80 	movabs $0x804161ebc0,%rax
  80416086d0:	00 00 00 
  80416086d3:	48 8b 10             	mov    (%rax),%rdx
  80416086d6:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  80416086dd:	48 89 18             	mov    %rbx,(%rax)
}
  80416086e0:	48 83 c4 08          	add    $0x8,%rsp
  80416086e4:	5b                   	pop    %rbx
  80416086e5:	5d                   	pop    %rbp
  80416086e6:	c3                   	retq   

00000080416086e7 <env_destroy>:
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.

  // LAB 3 code
  e->env_status = ENV_DYING;
  80416086e7:	c7 87 d4 00 00 00 01 	movl   $0x1,0xd4(%rdi)
  80416086ee:	00 00 00 
  if (e == curenv) {
  80416086f1:	48 b8 b8 eb 61 41 80 	movabs $0x804161ebb8,%rax
  80416086f8:	00 00 00 
  80416086fb:	48 39 38             	cmp    %rdi,(%rax)
  80416086fe:	74 01                	je     8041608701 <env_destroy+0x1a>
  8041608700:	c3                   	retq   
env_destroy(struct Env *e) {
  8041608701:	55                   	push   %rbp
  8041608702:	48 89 e5             	mov    %rsp,%rbp
    env_free(e);
  8041608705:	48 b8 78 86 60 41 80 	movabs $0x8041608678,%rax
  804160870c:	00 00 00 
  804160870f:	ff d0                	callq  *%rax
    sched_yield();
  8041608711:	48 b8 9c 9e 60 41 80 	movabs $0x8041609e9c,%rax
  8041608718:	00 00 00 
  804160871b:	ff d0                	callq  *%rax

000000804160871d <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  804160871d:	55                   	push   %rbp
  804160871e:	48 89 e5             	mov    %rsp,%rbp
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041608721:	48 ba 09 ce 60 41 80 	movabs $0x804160ce09,%rdx
  8041608728:	00 00 00 
  804160872b:	be dc 01 00 00       	mov    $0x1dc,%esi
  8041608730:	48 bf d1 cd 60 41 80 	movabs $0x804160cdd1,%rdi
  8041608737:	00 00 00 
  804160873a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160873f:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608746:	00 00 00 
  8041608749:	ff d1                	callq  *%rcx

000000804160874b <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  804160874b:	55                   	push   %rbp
  804160874c:	48 89 e5             	mov    %rsp,%rbp
  804160874f:	41 54                	push   %r12
  8041608751:	53                   	push   %rbx
  8041608752:	48 89 fb             	mov    %rdi,%rbx
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //

  // LAB 3 code
  if (curenv) {                            // if curenv == False, значит, какого-нибудь исполняемого процесса нет
  8041608755:	48 b8 b8 eb 61 41 80 	movabs $0x804161ebb8,%rax
  804160875c:	00 00 00 
  804160875f:	4c 8b 20             	mov    (%rax),%r12
  8041608762:	4d 85 e4             	test   %r12,%r12
  8041608765:	74 12                	je     8041608779 <env_run+0x2e>
    if (curenv->env_status == ENV_DYING) { // если процесс стал зомби
  8041608767:	41 8b 84 24 d4 00 00 	mov    0xd4(%r12),%eax
  804160876e:	00 
  804160876f:	83 f8 01             	cmp    $0x1,%eax
  8041608772:	74 32                	je     80416087a6 <env_run+0x5b>
      struct Env *old = curenv;            // ставим старый адрес
      env_free(curenv);                    // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
      if (old == e) {                      // e - аргумент функции, который к нам пришел
        sched_yield();                     // переключение системными вызовами
      }
    } else if (curenv->env_status == ENV_RUNNING) { // если процесс можем запустить
  8041608774:	83 f8 03             	cmp    $0x3,%eax
  8041608777:	74 4d                	je     80416087c6 <env_run+0x7b>
      curenv->env_status = ENV_RUNNABLE;            // запускаем процесс
    }
  }

  curenv             = e;           // текущая среда – е
  8041608779:	48 89 d8             	mov    %rbx,%rax
  804160877c:	48 a3 b8 eb 61 41 80 	movabs %rax,0x804161ebb8
  8041608783:	00 00 00 
  curenv->env_status = ENV_RUNNING; // устанавливаем статус среды на "выполняется"
  8041608786:	c7 83 d4 00 00 00 03 	movl   $0x3,0xd4(%rbx)
  804160878d:	00 00 00 
  curenv->env_runs++;               // обновляем количество работающих контекстов
  8041608790:	83 83 d8 00 00 00 01 	addl   $0x1,0xd8(%rbx)

  env_pop_tf(&curenv->env_tf);
  8041608797:	48 89 df             	mov    %rbx,%rdi
  804160879a:	48 b8 1d 87 60 41 80 	movabs $0x804160871d,%rax
  80416087a1:	00 00 00 
  80416087a4:	ff d0                	callq  *%rax
      env_free(curenv);                    // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
  80416087a6:	4c 89 e7             	mov    %r12,%rdi
  80416087a9:	48 b8 78 86 60 41 80 	movabs $0x8041608678,%rax
  80416087b0:	00 00 00 
  80416087b3:	ff d0                	callq  *%rax
      if (old == e) {                      // e - аргумент функции, который к нам пришел
  80416087b5:	49 39 dc             	cmp    %rbx,%r12
  80416087b8:	75 bf                	jne    8041608779 <env_run+0x2e>
        sched_yield();                     // переключение системными вызовами
  80416087ba:	48 b8 9c 9e 60 41 80 	movabs $0x8041609e9c,%rax
  80416087c1:	00 00 00 
  80416087c4:	ff d0                	callq  *%rax
      curenv->env_status = ENV_RUNNABLE;            // запускаем процесс
  80416087c6:	41 c7 84 24 d4 00 00 	movl   $0x2,0xd4(%r12)
  80416087cd:	00 02 00 00 00 
  80416087d2:	eb a5                	jmp    8041608779 <env_run+0x2e>

00000080416087d4 <rtc_timer_pic_interrupt>:
  // DELETED in LAB 5 end
  rtc_init();
}

static void
rtc_timer_pic_interrupt(void) {
  80416087d4:	55                   	push   %rbp
  80416087d5:	48 89 e5             	mov    %rsp,%rbp
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  80416087d8:	66 a1 e8 e7 61 41 80 	movabs 0x804161e7e8,%ax
  80416087df:	00 00 00 
  80416087e2:	89 c7                	mov    %eax,%edi
  80416087e4:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  80416087ea:	48 b8 c4 88 60 41 80 	movabs $0x80416088c4,%rax
  80416087f1:	00 00 00 
  80416087f4:	ff d0                	callq  *%rax
}
  80416087f6:	5d                   	pop    %rbp
  80416087f7:	c3                   	retq   

00000080416087f8 <rtc_init>:
  __asm __volatile("inb %w1,%0"
  80416087f8:	b9 70 00 00 00       	mov    $0x70,%ecx
  80416087fd:	89 ca                	mov    %ecx,%edx
  80416087ff:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) & ~NMI_LOCK);
}

static inline void
nmi_disable(void) {
  outb(0x70, inb(0x70) | NMI_LOCK);
  8041608800:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  8041608803:	ee                   	out    %al,(%dx)
  8041608804:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041608809:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160880a:	be 71 00 00 00       	mov    $0x71,%esi
  804160880f:	89 f2                	mov    %esi,%edx
  8041608811:	ec                   	in     (%dx),%al

  // меняем делитель частоты регистра часов А,
  // чтобы прерывания приходили раз в полсекунды
  outb(IO_RTC_CMND, RTC_AREG);
  reg_a = inb(IO_RTC_DATA);
  reg_a = reg_a | 0x0F; // биты 0-3 = 1 => 500 мс (2 Гц)
  8041608812:	83 c8 0f             	or     $0xf,%eax
  __asm __volatile("outb %0,%w1"
  8041608815:	ee                   	out    %al,(%dx)
  8041608816:	b8 0b 00 00 00       	mov    $0xb,%eax
  804160881b:	89 ca                	mov    %ecx,%edx
  804160881d:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160881e:	89 f2                	mov    %esi,%edx
  8041608820:	ec                   	in     (%dx),%al
  outb(IO_RTC_DATA, reg_a);

  // устанавливаем бит RTC_PIE в регистре часов В
  outb(IO_RTC_CMND, RTC_BREG);
  reg_b = inb(IO_RTC_DATA);
  reg_b = reg_b | RTC_PIE;
  8041608821:	83 c8 40             	or     $0x40,%eax
  __asm __volatile("outb %0,%w1"
  8041608824:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608825:	89 ca                	mov    %ecx,%edx
  8041608827:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  8041608828:	83 e0 7f             	and    $0x7f,%eax
  804160882b:	ee                   	out    %al,(%dx)
  outb(IO_RTC_DATA, reg_b);

  // разрешить прерывания
  nmi_enable();
  // LAB 4 code end
}
  804160882c:	c3                   	retq   

000000804160882d <rtc_timer_init>:
rtc_timer_init(void) {
  804160882d:	55                   	push   %rbp
  804160882e:	48 89 e5             	mov    %rsp,%rbp
  rtc_init();
  8041608831:	48 b8 f8 87 60 41 80 	movabs $0x80416087f8,%rax
  8041608838:	00 00 00 
  804160883b:	ff d0                	callq  *%rax
}
  804160883d:	5d                   	pop    %rbp
  804160883e:	c3                   	retq   

000000804160883f <rtc_check_status>:
  804160883f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041608844:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608849:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160884a:	ba 71 00 00 00       	mov    $0x71,%edx
  804160884f:	ec                   	in     (%dx),%al
  outb(IO_RTC_CMND, RTC_CREG);
  status = inb(IO_RTC_DATA);
  // LAB 4 code end

  return status;
}
  8041608850:	c3                   	retq   

0000008041608851 <rtc_timer_pic_handle>:
rtc_timer_pic_handle(void) {
  8041608851:	55                   	push   %rbp
  8041608852:	48 89 e5             	mov    %rsp,%rbp
  rtc_check_status();
  8041608855:	48 b8 3f 88 60 41 80 	movabs $0x804160883f,%rax
  804160885c:	00 00 00 
  804160885f:	ff d0                	callq  *%rax
  pic_send_eoi(IRQ_CLOCK);
  8041608861:	bf 08 00 00 00       	mov    $0x8,%edi
  8041608866:	48 b8 29 8a 60 41 80 	movabs $0x8041608a29,%rax
  804160886d:	00 00 00 
  8041608870:	ff d0                	callq  *%rax
}
  8041608872:	5d                   	pop    %rbp
  8041608873:	c3                   	retq   

0000008041608874 <mc146818_read>:
  __asm __volatile("outb %0,%w1"
  8041608874:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608879:	89 f8                	mov    %edi,%eax
  804160887b:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160887c:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608881:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg) {
  outb(IO_RTC_CMND, reg);
  return inb(IO_RTC_DATA);
  8041608882:	0f b6 c0             	movzbl %al,%eax
}
  8041608885:	c3                   	retq   

0000008041608886 <mc146818_write>:
  __asm __volatile("outb %0,%w1"
  8041608886:	ba 70 00 00 00       	mov    $0x70,%edx
  804160888b:	89 f8                	mov    %edi,%eax
  804160888d:	ee                   	out    %al,(%dx)
  804160888e:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608893:	89 f0                	mov    %esi,%eax
  8041608895:	ee                   	out    %al,(%dx)

void
mc146818_write(unsigned reg, unsigned datum) {
  outb(IO_RTC_CMND, reg);
  outb(IO_RTC_DATA, datum);
}
  8041608896:	c3                   	retq   

0000008041608897 <mc146818_read16>:
  8041608897:	41 b8 70 00 00 00    	mov    $0x70,%r8d
  804160889d:	89 f8                	mov    %edi,%eax
  804160889f:	44 89 c2             	mov    %r8d,%edx
  80416088a2:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416088a3:	b9 71 00 00 00       	mov    $0x71,%ecx
  80416088a8:	89 ca                	mov    %ecx,%edx
  80416088aa:	ec                   	in     (%dx),%al
  80416088ab:	89 c6                	mov    %eax,%esi

unsigned
mc146818_read16(unsigned reg) {
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  80416088ad:	8d 47 01             	lea    0x1(%rdi),%eax
  __asm __volatile("outb %0,%w1"
  80416088b0:	44 89 c2             	mov    %r8d,%edx
  80416088b3:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416088b4:	89 ca                	mov    %ecx,%edx
  80416088b6:	ec                   	in     (%dx),%al
  return inb(IO_RTC_DATA);
  80416088b7:	0f b6 c0             	movzbl %al,%eax
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  80416088ba:	c1 e0 08             	shl    $0x8,%eax
  return inb(IO_RTC_DATA);
  80416088bd:	40 0f b6 f6          	movzbl %sil,%esi
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  80416088c1:	09 f0                	or     %esi,%eax
  80416088c3:	c3                   	retq   

00000080416088c4 <irq_setmask_8259A>:
}

void
irq_setmask_8259A(uint16_t mask) {
  int i;
  irq_mask_8259A = mask;
  80416088c4:	89 f8                	mov    %edi,%eax
  80416088c6:	66 a3 e8 e7 61 41 80 	movabs %ax,0x804161e7e8
  80416088cd:	00 00 00 
  if (!didinit)
  80416088d0:	48 b8 c8 eb 61 41 80 	movabs $0x804161ebc8,%rax
  80416088d7:	00 00 00 
  80416088da:	80 38 00             	cmpb   $0x0,(%rax)
  80416088dd:	75 01                	jne    80416088e0 <irq_setmask_8259A+0x1c>
  80416088df:	c3                   	retq   
irq_setmask_8259A(uint16_t mask) {
  80416088e0:	55                   	push   %rbp
  80416088e1:	48 89 e5             	mov    %rsp,%rbp
  80416088e4:	41 56                	push   %r14
  80416088e6:	41 55                	push   %r13
  80416088e8:	41 54                	push   %r12
  80416088ea:	53                   	push   %rbx
  80416088eb:	41 89 fc             	mov    %edi,%r12d
  80416088ee:	89 f8                	mov    %edi,%eax
  __asm __volatile("outb %0,%w1"
  80416088f0:	ba 21 00 00 00       	mov    $0x21,%edx
  80416088f5:	ee                   	out    %al,(%dx)
    return;
  outb(IO_PIC1_DATA, (char)mask);
  outb(IO_PIC2_DATA, (char)(mask >> 8));
  80416088f6:	66 c1 e8 08          	shr    $0x8,%ax
  80416088fa:	ba a1 00 00 00       	mov    $0xa1,%edx
  80416088ff:	ee                   	out    %al,(%dx)
  cprintf("enabled interrupts:");
  8041608900:	48 bf 33 ce 60 41 80 	movabs $0x804160ce33,%rdi
  8041608907:	00 00 00 
  804160890a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160890f:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041608916:	00 00 00 
  8041608919:	ff d2                	callq  *%rdx
  for (i = 0; i < 16; i++)
  804160891b:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (~mask & (1 << i))
  8041608920:	45 0f b7 e4          	movzwl %r12w,%r12d
  8041608924:	41 f7 d4             	not    %r12d
      cprintf(" %d", i);
  8041608927:	49 be 48 d6 60 41 80 	movabs $0x804160d648,%r14
  804160892e:	00 00 00 
  8041608931:	49 bd 9c 8a 60 41 80 	movabs $0x8041608a9c,%r13
  8041608938:	00 00 00 
  804160893b:	eb 15                	jmp    8041608952 <irq_setmask_8259A+0x8e>
  804160893d:	89 de                	mov    %ebx,%esi
  804160893f:	4c 89 f7             	mov    %r14,%rdi
  8041608942:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608947:	41 ff d5             	callq  *%r13
  for (i = 0; i < 16; i++)
  804160894a:	83 c3 01             	add    $0x1,%ebx
  804160894d:	83 fb 10             	cmp    $0x10,%ebx
  8041608950:	74 08                	je     804160895a <irq_setmask_8259A+0x96>
    if (~mask & (1 << i))
  8041608952:	41 0f a3 dc          	bt     %ebx,%r12d
  8041608956:	73 f2                	jae    804160894a <irq_setmask_8259A+0x86>
  8041608958:	eb e3                	jmp    804160893d <irq_setmask_8259A+0x79>
  cprintf("\n");
  804160895a:	48 bf b7 cc 60 41 80 	movabs $0x804160ccb7,%rdi
  8041608961:	00 00 00 
  8041608964:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608969:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041608970:	00 00 00 
  8041608973:	ff d2                	callq  *%rdx
}
  8041608975:	5b                   	pop    %rbx
  8041608976:	41 5c                	pop    %r12
  8041608978:	41 5d                	pop    %r13
  804160897a:	41 5e                	pop    %r14
  804160897c:	5d                   	pop    %rbp
  804160897d:	c3                   	retq   

000000804160897e <pic_init>:
  didinit = 1;
  804160897e:	48 b8 c8 eb 61 41 80 	movabs $0x804161ebc8,%rax
  8041608985:	00 00 00 
  8041608988:	c6 00 01             	movb   $0x1,(%rax)
  804160898b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041608990:	be 21 00 00 00       	mov    $0x21,%esi
  8041608995:	89 f2                	mov    %esi,%edx
  8041608997:	ee                   	out    %al,(%dx)
  8041608998:	b9 a1 00 00 00       	mov    $0xa1,%ecx
  804160899d:	89 ca                	mov    %ecx,%edx
  804160899f:	ee                   	out    %al,(%dx)
  80416089a0:	41 b9 11 00 00 00    	mov    $0x11,%r9d
  80416089a6:	bf 20 00 00 00       	mov    $0x20,%edi
  80416089ab:	44 89 c8             	mov    %r9d,%eax
  80416089ae:	89 fa                	mov    %edi,%edx
  80416089b0:	ee                   	out    %al,(%dx)
  80416089b1:	b8 20 00 00 00       	mov    $0x20,%eax
  80416089b6:	89 f2                	mov    %esi,%edx
  80416089b8:	ee                   	out    %al,(%dx)
  80416089b9:	b8 04 00 00 00       	mov    $0x4,%eax
  80416089be:	ee                   	out    %al,(%dx)
  80416089bf:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  80416089c5:	44 89 c0             	mov    %r8d,%eax
  80416089c8:	ee                   	out    %al,(%dx)
  80416089c9:	be a0 00 00 00       	mov    $0xa0,%esi
  80416089ce:	44 89 c8             	mov    %r9d,%eax
  80416089d1:	89 f2                	mov    %esi,%edx
  80416089d3:	ee                   	out    %al,(%dx)
  80416089d4:	b8 28 00 00 00       	mov    $0x28,%eax
  80416089d9:	89 ca                	mov    %ecx,%edx
  80416089db:	ee                   	out    %al,(%dx)
  80416089dc:	b8 02 00 00 00       	mov    $0x2,%eax
  80416089e1:	ee                   	out    %al,(%dx)
  80416089e2:	44 89 c0             	mov    %r8d,%eax
  80416089e5:	ee                   	out    %al,(%dx)
  80416089e6:	41 b8 68 00 00 00    	mov    $0x68,%r8d
  80416089ec:	44 89 c0             	mov    %r8d,%eax
  80416089ef:	89 fa                	mov    %edi,%edx
  80416089f1:	ee                   	out    %al,(%dx)
  80416089f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416089f7:	89 c8                	mov    %ecx,%eax
  80416089f9:	ee                   	out    %al,(%dx)
  80416089fa:	44 89 c0             	mov    %r8d,%eax
  80416089fd:	89 f2                	mov    %esi,%edx
  80416089ff:	ee                   	out    %al,(%dx)
  8041608a00:	89 c8                	mov    %ecx,%eax
  8041608a02:	ee                   	out    %al,(%dx)
  if (irq_mask_8259A != 0xFFFF)
  8041608a03:	66 a1 e8 e7 61 41 80 	movabs 0x804161e7e8,%ax
  8041608a0a:	00 00 00 
  8041608a0d:	66 83 f8 ff          	cmp    $0xffff,%ax
  8041608a11:	75 01                	jne    8041608a14 <pic_init+0x96>
  8041608a13:	c3                   	retq   
pic_init(void) {
  8041608a14:	55                   	push   %rbp
  8041608a15:	48 89 e5             	mov    %rsp,%rbp
    irq_setmask_8259A(irq_mask_8259A);
  8041608a18:	0f b7 f8             	movzwl %ax,%edi
  8041608a1b:	48 b8 c4 88 60 41 80 	movabs $0x80416088c4,%rax
  8041608a22:	00 00 00 
  8041608a25:	ff d0                	callq  *%rax
}
  8041608a27:	5d                   	pop    %rbp
  8041608a28:	c3                   	retq   

0000008041608a29 <pic_send_eoi>:

void
pic_send_eoi(uint8_t irq) {
  if (irq >= 8)
  8041608a29:	40 80 ff 07          	cmp    $0x7,%dil
  8041608a2d:	76 0b                	jbe    8041608a3a <pic_send_eoi+0x11>
  8041608a2f:	b8 20 00 00 00       	mov    $0x20,%eax
  8041608a34:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041608a39:	ee                   	out    %al,(%dx)
  8041608a3a:	b8 20 00 00 00       	mov    $0x20,%eax
  8041608a3f:	ba 20 00 00 00       	mov    $0x20,%edx
  8041608a44:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_CMND, PIC_EOI);
  outb(IO_PIC1_CMND, PIC_EOI);
}
  8041608a45:	c3                   	retq   

0000008041608a46 <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  8041608a46:	55                   	push   %rbp
  8041608a47:	48 89 e5             	mov    %rsp,%rbp
  8041608a4a:	53                   	push   %rbx
  8041608a4b:	48 83 ec 08          	sub    $0x8,%rsp
  8041608a4f:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  8041608a52:	48 b8 f3 0c 60 41 80 	movabs $0x8041600cf3,%rax
  8041608a59:	00 00 00 
  8041608a5c:	ff d0                	callq  *%rax
  (*cnt)++;
  8041608a5e:	83 03 01             	addl   $0x1,(%rbx)
}
  8041608a61:	48 83 c4 08          	add    $0x8,%rsp
  8041608a65:	5b                   	pop    %rbx
  8041608a66:	5d                   	pop    %rbp
  8041608a67:	c3                   	retq   

0000008041608a68 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8041608a68:	55                   	push   %rbp
  8041608a69:	48 89 e5             	mov    %rsp,%rbp
  8041608a6c:	48 83 ec 10          	sub    $0x10,%rsp
  8041608a70:	48 89 fa             	mov    %rdi,%rdx
  8041608a73:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  8041608a76:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  8041608a7d:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  8041608a81:	48 bf 46 8a 60 41 80 	movabs $0x8041608a46,%rdi
  8041608a88:	00 00 00 
  8041608a8b:	48 b8 a0 a3 60 41 80 	movabs $0x804160a3a0,%rax
  8041608a92:	00 00 00 
  8041608a95:	ff d0                	callq  *%rax
  return cnt;
}
  8041608a97:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041608a9a:	c9                   	leaveq 
  8041608a9b:	c3                   	retq   

0000008041608a9c <cprintf>:

int
cprintf(const char *fmt, ...) {
  8041608a9c:	55                   	push   %rbp
  8041608a9d:	48 89 e5             	mov    %rsp,%rbp
  8041608aa0:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041608aa7:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8041608aae:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041608ab5:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041608abc:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041608ac3:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041608aca:	84 c0                	test   %al,%al
  8041608acc:	74 20                	je     8041608aee <cprintf+0x52>
  8041608ace:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041608ad2:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041608ad6:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041608ada:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041608ade:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041608ae2:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041608ae6:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041608aea:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8041608aee:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8041608af5:	00 00 00 
  8041608af8:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041608aff:	00 00 00 
  8041608b02:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041608b06:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041608b0d:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041608b14:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8041608b1b:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041608b22:	48 b8 68 8a 60 41 80 	movabs $0x8041608a68,%rax
  8041608b29:	00 00 00 
  8041608b2c:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8041608b2e:	c9                   	leaveq 
  8041608b2f:	c3                   	retq   

0000008041608b30 <clock_idt_init>:

void
clock_idt_init(void) {
  extern void (*clock_thdlr)(void);
  // init idt structure
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041608b30:	48 ba a0 91 60 41 80 	movabs $0x80416091a0,%rdx
  8041608b37:	00 00 00 
  8041608b3a:	48 b8 e0 eb 61 41 80 	movabs $0x804161ebe0,%rax
  8041608b41:	00 00 00 
  8041608b44:	66 89 90 00 02 00 00 	mov    %dx,0x200(%rax)
  8041608b4b:	66 c7 80 02 02 00 00 	movw   $0x8,0x202(%rax)
  8041608b52:	08 00 
  8041608b54:	c6 80 04 02 00 00 00 	movb   $0x0,0x204(%rax)
  8041608b5b:	c6 80 05 02 00 00 8e 	movb   $0x8e,0x205(%rax)
  8041608b62:	48 89 d6             	mov    %rdx,%rsi
  8041608b65:	48 c1 ee 10          	shr    $0x10,%rsi
  8041608b69:	66 89 b0 06 02 00 00 	mov    %si,0x206(%rax)
  8041608b70:	48 89 d1             	mov    %rdx,%rcx
  8041608b73:	48 c1 e9 20          	shr    $0x20,%rcx
  8041608b77:	89 88 08 02 00 00    	mov    %ecx,0x208(%rax)
  8041608b7d:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%rax)
  8041608b84:	00 00 00 
  SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041608b87:	66 89 90 80 02 00 00 	mov    %dx,0x280(%rax)
  8041608b8e:	66 c7 80 82 02 00 00 	movw   $0x8,0x282(%rax)
  8041608b95:	08 00 
  8041608b97:	c6 80 84 02 00 00 00 	movb   $0x0,0x284(%rax)
  8041608b9e:	c6 80 85 02 00 00 8e 	movb   $0x8e,0x285(%rax)
  8041608ba5:	66 89 b0 86 02 00 00 	mov    %si,0x286(%rax)
  8041608bac:	89 88 88 02 00 00    	mov    %ecx,0x288(%rax)
  8041608bb2:	c7 80 8c 02 00 00 00 	movl   $0x0,0x28c(%rax)
  8041608bb9:	00 00 00 
  __asm __volatile("lidt (%0)"
  8041608bbc:	48 b8 f0 e7 61 41 80 	movabs $0x804161e7f0,%rax
  8041608bc3:	00 00 00 
  8041608bc6:	0f 01 18             	lidt   (%rax)
  lidt(&idt_pd);
}
  8041608bc9:	c3                   	retq   

0000008041608bca <print_regs>:
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  }
}

void
print_regs(struct PushRegs *regs) {
  8041608bca:	55                   	push   %rbp
  8041608bcb:	48 89 e5             	mov    %rsp,%rbp
  8041608bce:	41 54                	push   %r12
  8041608bd0:	53                   	push   %rbx
  8041608bd1:	49 89 fc             	mov    %rdi,%r12
  cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  8041608bd4:	48 8b 37             	mov    (%rdi),%rsi
  8041608bd7:	48 bf 47 ce 60 41 80 	movabs $0x804160ce47,%rdi
  8041608bde:	00 00 00 
  8041608be1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608be6:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  8041608bed:	00 00 00 
  8041608bf0:	ff d3                	callq  *%rbx
  cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  8041608bf2:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
  8041608bf7:	48 bf 57 ce 60 41 80 	movabs $0x804160ce57,%rdi
  8041608bfe:	00 00 00 
  8041608c01:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c06:	ff d3                	callq  *%rbx
  cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  8041608c08:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  8041608c0d:	48 bf 67 ce 60 41 80 	movabs $0x804160ce67,%rdi
  8041608c14:	00 00 00 
  8041608c17:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c1c:	ff d3                	callq  *%rbx
  cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  8041608c1e:	49 8b 74 24 18       	mov    0x18(%r12),%rsi
  8041608c23:	48 bf 77 ce 60 41 80 	movabs $0x804160ce77,%rdi
  8041608c2a:	00 00 00 
  8041608c2d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c32:	ff d3                	callq  *%rbx
  cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  8041608c34:	49 8b 74 24 20       	mov    0x20(%r12),%rsi
  8041608c39:	48 bf 87 ce 60 41 80 	movabs $0x804160ce87,%rdi
  8041608c40:	00 00 00 
  8041608c43:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c48:	ff d3                	callq  *%rbx
  cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  8041608c4a:	49 8b 74 24 28       	mov    0x28(%r12),%rsi
  8041608c4f:	48 bf 97 ce 60 41 80 	movabs $0x804160ce97,%rdi
  8041608c56:	00 00 00 
  8041608c59:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c5e:	ff d3                	callq  *%rbx
  cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  8041608c60:	49 8b 74 24 30       	mov    0x30(%r12),%rsi
  8041608c65:	48 bf a7 ce 60 41 80 	movabs $0x804160cea7,%rdi
  8041608c6c:	00 00 00 
  8041608c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c74:	ff d3                	callq  *%rbx
  cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  8041608c76:	49 8b 74 24 38       	mov    0x38(%r12),%rsi
  8041608c7b:	48 bf b7 ce 60 41 80 	movabs $0x804160ceb7,%rdi
  8041608c82:	00 00 00 
  8041608c85:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c8a:	ff d3                	callq  *%rbx
  cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  8041608c8c:	49 8b 74 24 48       	mov    0x48(%r12),%rsi
  8041608c91:	48 bf c7 ce 60 41 80 	movabs $0x804160cec7,%rdi
  8041608c98:	00 00 00 
  8041608c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ca0:	ff d3                	callq  *%rbx
  cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  8041608ca2:	49 8b 74 24 40       	mov    0x40(%r12),%rsi
  8041608ca7:	48 bf d7 ce 60 41 80 	movabs $0x804160ced7,%rdi
  8041608cae:	00 00 00 
  8041608cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608cb6:	ff d3                	callq  *%rbx
  cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  8041608cb8:	49 8b 74 24 50       	mov    0x50(%r12),%rsi
  8041608cbd:	48 bf e7 ce 60 41 80 	movabs $0x804160cee7,%rdi
  8041608cc4:	00 00 00 
  8041608cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ccc:	ff d3                	callq  *%rbx
  cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  8041608cce:	49 8b 74 24 68       	mov    0x68(%r12),%rsi
  8041608cd3:	48 bf f7 ce 60 41 80 	movabs $0x804160cef7,%rdi
  8041608cda:	00 00 00 
  8041608cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ce2:	ff d3                	callq  *%rbx
  cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  8041608ce4:	49 8b 74 24 58       	mov    0x58(%r12),%rsi
  8041608ce9:	48 bf 07 cf 60 41 80 	movabs $0x804160cf07,%rdi
  8041608cf0:	00 00 00 
  8041608cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608cf8:	ff d3                	callq  *%rbx
  cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  8041608cfa:	49 8b 74 24 60       	mov    0x60(%r12),%rsi
  8041608cff:	48 bf 17 cf 60 41 80 	movabs $0x804160cf17,%rdi
  8041608d06:	00 00 00 
  8041608d09:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d0e:	ff d3                	callq  *%rbx
  cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
  8041608d10:	49 8b 74 24 70       	mov    0x70(%r12),%rsi
  8041608d15:	48 bf 27 cf 60 41 80 	movabs $0x804160cf27,%rdi
  8041608d1c:	00 00 00 
  8041608d1f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d24:	ff d3                	callq  *%rbx
}
  8041608d26:	5b                   	pop    %rbx
  8041608d27:	41 5c                	pop    %r12
  8041608d29:	5d                   	pop    %rbp
  8041608d2a:	c3                   	retq   

0000008041608d2b <print_trapframe>:
print_trapframe(struct Trapframe *tf) {
  8041608d2b:	55                   	push   %rbp
  8041608d2c:	48 89 e5             	mov    %rsp,%rbp
  8041608d2f:	41 54                	push   %r12
  8041608d31:	53                   	push   %rbx
  8041608d32:	48 89 fb             	mov    %rdi,%rbx
  cprintf("TRAP frame at %p\n", tf);
  8041608d35:	48 89 fe             	mov    %rdi,%rsi
  8041608d38:	48 bf 8c cf 60 41 80 	movabs $0x804160cf8c,%rdi
  8041608d3f:	00 00 00 
  8041608d42:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d47:	49 bc 9c 8a 60 41 80 	movabs $0x8041608a9c,%r12
  8041608d4e:	00 00 00 
  8041608d51:	41 ff d4             	callq  *%r12
  print_regs(&tf->tf_regs);
  8041608d54:	48 89 df             	mov    %rbx,%rdi
  8041608d57:	48 b8 ca 8b 60 41 80 	movabs $0x8041608bca,%rax
  8041608d5e:	00 00 00 
  8041608d61:	ff d0                	callq  *%rax
  cprintf("  es   0x----%04x\n", tf->tf_es);
  8041608d63:	0f b7 73 78          	movzwl 0x78(%rbx),%esi
  8041608d67:	48 bf 9e cf 60 41 80 	movabs $0x804160cf9e,%rdi
  8041608d6e:	00 00 00 
  8041608d71:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d76:	41 ff d4             	callq  *%r12
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  8041608d79:	0f b7 b3 80 00 00 00 	movzwl 0x80(%rbx),%esi
  8041608d80:	48 bf b1 cf 60 41 80 	movabs $0x804160cfb1,%rdi
  8041608d87:	00 00 00 
  8041608d8a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d8f:	41 ff d4             	callq  *%r12
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041608d92:	48 8b b3 88 00 00 00 	mov    0x88(%rbx),%rsi
  if (trapno < sizeof(excnames) / sizeof(excnames[0]))
  8041608d99:	83 fe 13             	cmp    $0x13,%esi
  8041608d9c:	0f 86 68 01 00 00    	jbe    8041608f0a <print_trapframe+0x1df>
    return "System call";
  8041608da2:	48 ba 37 cf 60 41 80 	movabs $0x804160cf37,%rdx
  8041608da9:	00 00 00 
  if (trapno == T_SYSCALL)
  8041608dac:	83 fe 30             	cmp    $0x30,%esi
  8041608daf:	74 1e                	je     8041608dcf <print_trapframe+0xa4>
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  8041608db1:	8d 46 e0             	lea    -0x20(%rsi),%eax
    return "Hardware Interrupt";
  8041608db4:	83 f8 0f             	cmp    $0xf,%eax
  8041608db7:	48 ba 43 cf 60 41 80 	movabs $0x804160cf43,%rdx
  8041608dbe:	00 00 00 
  8041608dc1:	48 b8 52 cf 60 41 80 	movabs $0x804160cf52,%rax
  8041608dc8:	00 00 00 
  8041608dcb:	48 0f 46 d0          	cmovbe %rax,%rdx
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041608dcf:	48 bf c4 cf 60 41 80 	movabs $0x804160cfc4,%rdi
  8041608dd6:	00 00 00 
  8041608dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608dde:	48 b9 9c 8a 60 41 80 	movabs $0x8041608a9c,%rcx
  8041608de5:	00 00 00 
  8041608de8:	ff d1                	callq  *%rcx
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041608dea:	48 b8 e0 fb 61 41 80 	movabs $0x804161fbe0,%rax
  8041608df1:	00 00 00 
  8041608df4:	48 39 18             	cmp    %rbx,(%rax)
  8041608df7:	0f 84 23 01 00 00    	je     8041608f20 <print_trapframe+0x1f5>
  cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  8041608dfd:	48 8b b3 90 00 00 00 	mov    0x90(%rbx),%rsi
  8041608e04:	48 bf e7 cf 60 41 80 	movabs $0x804160cfe7,%rdi
  8041608e0b:	00 00 00 
  8041608e0e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e13:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041608e1a:	00 00 00 
  8041608e1d:	ff d2                	callq  *%rdx
  if (tf->tf_trapno == T_PGFLT)
  8041608e1f:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041608e26:	0e 
  8041608e27:	0f 85 24 01 00 00    	jne    8041608f51 <print_trapframe+0x226>
            tf->tf_err & 1 ? "protection" : "not-present");
  8041608e2d:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
    cprintf(" [%s, %s, %s]\n",
  8041608e34:	48 89 c2             	mov    %rax,%rdx
  8041608e37:	83 e2 01             	and    $0x1,%edx
  8041608e3a:	48 b9 65 cf 60 41 80 	movabs $0x804160cf65,%rcx
  8041608e41:	00 00 00 
  8041608e44:	48 ba 70 cf 60 41 80 	movabs $0x804160cf70,%rdx
  8041608e4b:	00 00 00 
  8041608e4e:	48 0f 44 ca          	cmove  %rdx,%rcx
  8041608e52:	48 89 c2             	mov    %rax,%rdx
  8041608e55:	83 e2 02             	and    $0x2,%edx
  8041608e58:	48 ba 7c cf 60 41 80 	movabs $0x804160cf7c,%rdx
  8041608e5f:	00 00 00 
  8041608e62:	48 be 82 cf 60 41 80 	movabs $0x804160cf82,%rsi
  8041608e69:	00 00 00 
  8041608e6c:	48 0f 44 d6          	cmove  %rsi,%rdx
  8041608e70:	83 e0 04             	and    $0x4,%eax
  8041608e73:	48 be 87 cf 60 41 80 	movabs $0x804160cf87,%rsi
  8041608e7a:	00 00 00 
  8041608e7d:	48 b8 b6 d0 60 41 80 	movabs $0x804160d0b6,%rax
  8041608e84:	00 00 00 
  8041608e87:	48 0f 44 f0          	cmove  %rax,%rsi
  8041608e8b:	48 bf f6 cf 60 41 80 	movabs $0x804160cff6,%rdi
  8041608e92:	00 00 00 
  8041608e95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e9a:	49 b8 9c 8a 60 41 80 	movabs $0x8041608a9c,%r8
  8041608ea1:	00 00 00 
  8041608ea4:	41 ff d0             	callq  *%r8
  cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  8041608ea7:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
  8041608eae:	48 bf 05 d0 60 41 80 	movabs $0x804160d005,%rdi
  8041608eb5:	00 00 00 
  8041608eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ebd:	49 bc 9c 8a 60 41 80 	movabs $0x8041608a9c,%r12
  8041608ec4:	00 00 00 
  8041608ec7:	41 ff d4             	callq  *%r12
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8041608eca:	0f b7 b3 a0 00 00 00 	movzwl 0xa0(%rbx),%esi
  8041608ed1:	48 bf 15 d0 60 41 80 	movabs $0x804160d015,%rdi
  8041608ed8:	00 00 00 
  8041608edb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ee0:	41 ff d4             	callq  *%r12
  cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  8041608ee3:	48 8b b3 a8 00 00 00 	mov    0xa8(%rbx),%rsi
  8041608eea:	48 bf 28 d0 60 41 80 	movabs $0x804160d028,%rdi
  8041608ef1:	00 00 00 
  8041608ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ef9:	41 ff d4             	callq  *%r12
  if ((tf->tf_cs & 3) != 0) {
  8041608efc:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041608f03:	75 6c                	jne    8041608f71 <print_trapframe+0x246>
}
  8041608f05:	5b                   	pop    %rbx
  8041608f06:	41 5c                	pop    %r12
  8041608f08:	5d                   	pop    %rbp
  8041608f09:	c3                   	retq   
    return excnames[trapno];
  8041608f0a:	48 63 c6             	movslq %esi,%rax
  8041608f0d:	48 ba 00 d2 60 41 80 	movabs $0x804160d200,%rdx
  8041608f14:	00 00 00 
  8041608f17:	48 8b 14 c2          	mov    (%rdx,%rax,8),%rdx
  8041608f1b:	e9 af fe ff ff       	jmpq   8041608dcf <print_trapframe+0xa4>
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041608f20:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041608f27:	0e 
  8041608f28:	0f 85 cf fe ff ff    	jne    8041608dfd <print_trapframe+0xd2>
  __asm __volatile("movq %%cr2,%0"
  8041608f2e:	0f 20 d6             	mov    %cr2,%rsi
    cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  8041608f31:	48 bf d7 cf 60 41 80 	movabs $0x804160cfd7,%rdi
  8041608f38:	00 00 00 
  8041608f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608f40:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041608f47:	00 00 00 
  8041608f4a:	ff d2                	callq  *%rdx
  8041608f4c:	e9 ac fe ff ff       	jmpq   8041608dfd <print_trapframe+0xd2>
    cprintf("\n");
  8041608f51:	48 bf b7 cc 60 41 80 	movabs $0x804160ccb7,%rdi
  8041608f58:	00 00 00 
  8041608f5b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608f60:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041608f67:	00 00 00 
  8041608f6a:	ff d2                	callq  *%rdx
  8041608f6c:	e9 36 ff ff ff       	jmpq   8041608ea7 <print_trapframe+0x17c>
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
  8041608f71:	48 8b b3 b0 00 00 00 	mov    0xb0(%rbx),%rsi
  8041608f78:	48 bf 38 d0 60 41 80 	movabs $0x804160d038,%rdi
  8041608f7f:	00 00 00 
  8041608f82:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608f87:	41 ff d4             	callq  *%r12
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  8041608f8a:	0f b7 b3 b8 00 00 00 	movzwl 0xb8(%rbx),%esi
  8041608f91:	48 bf 48 d0 60 41 80 	movabs $0x804160d048,%rdi
  8041608f98:	00 00 00 
  8041608f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608fa0:	41 ff d4             	callq  *%r12
}
  8041608fa3:	e9 5d ff ff ff       	jmpq   8041608f05 <print_trapframe+0x1da>

0000008041608fa8 <trap>:
    env_destroy(curenv);
  }
}

void
trap(struct Trapframe *tf) {
  8041608fa8:	55                   	push   %rbp
  8041608fa9:	48 89 e5             	mov    %rsp,%rbp
  8041608fac:	53                   	push   %rbx
  8041608fad:	48 83 ec 08          	sub    $0x8,%rsp
  8041608fb1:	48 89 fe             	mov    %rdi,%rsi
  // The environment may have set DF and some versions
  // of GCC rely on DF being clear
  asm volatile("cld" ::
  8041608fb4:	fc                   	cld    
                   : "cc");

  // Halt the CPU if some other CPU has called panic()
  extern char *panicstr;
  if (panicstr)
  8041608fb5:	48 b8 20 e9 61 41 80 	movabs $0x804161e920,%rax
  8041608fbc:	00 00 00 
  8041608fbf:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041608fc3:	74 01                	je     8041608fc6 <trap+0x1e>
    asm volatile("hlt");
  8041608fc5:	f4                   	hlt    
  __asm __volatile("pushfq; popq %0"
  8041608fc6:	9c                   	pushfq 
  8041608fc7:	58                   	pop    %rax

  // Check that interrupts are disabled.  If this assertion
  // fails, DO NOT be tempted to fix it by inserting a "cli" in
  // the interrupt path.
  assert(!(read_rflags() & FL_IF));
  8041608fc8:	f6 c4 02             	test   $0x2,%ah
  8041608fcb:	0f 85 bc 00 00 00    	jne    804160908d <trap+0xe5>

  if (debug) {
    cprintf("Incoming TRAP frame at %p\n", tf);
  }

  assert(curenv);
  8041608fd1:	48 a1 b8 eb 61 41 80 	movabs 0x804161ebb8,%rax
  8041608fd8:	00 00 00 
  8041608fdb:	48 85 c0             	test   %rax,%rax
  8041608fde:	0f 84 de 00 00 00    	je     80416090c2 <trap+0x11a>

  // Garbage collect if current enviroment is a zombie
  if (curenv->env_status == ENV_DYING) {
  8041608fe4:	83 b8 d4 00 00 00 01 	cmpl   $0x1,0xd4(%rax)
  8041608feb:	0f 84 01 01 00 00    	je     80416090f2 <trap+0x14a>
  }

  // Copy trap frame (which is currently on the stack)
  // into 'curenv->env_tf', so that running the environment
  // will restart at the trap point.
  curenv->env_tf = *tf;
  8041608ff1:	b9 30 00 00 00       	mov    $0x30,%ecx
  8041608ff6:	48 89 c7             	mov    %rax,%rdi
  8041608ff9:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  // The trapframe on the stack should be ignored from here on.
  tf = &curenv->env_tf;
  8041608ffb:	48 b8 b8 eb 61 41 80 	movabs $0x804161ebb8,%rax
  8041609002:	00 00 00 
  8041609005:	48 8b 18             	mov    (%rax),%rbx

  // Record that tf is the last real trapframe so
  // print_trapframe can print some additional information.
  last_tf = tf;
  8041609008:	48 89 d8             	mov    %rbx,%rax
  804160900b:	48 a3 e0 fb 61 41 80 	movabs %rax,0x804161fbe0
  8041609012:	00 00 00 
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
  8041609015:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  804160901c:	48 83 f8 27          	cmp    $0x27,%rax
  8041609020:	0f 84 f8 00 00 00    	je     804160911e <trap+0x176>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {
  8041609026:	48 83 f8 28          	cmp    $0x28,%rax
  804160902a:	0f 84 1d 01 00 00    	je     804160914d <trap+0x1a5>
  print_trapframe(tf);
  8041609030:	48 89 df             	mov    %rbx,%rdi
  8041609033:	48 b8 2b 8d 60 41 80 	movabs $0x8041608d2b,%rax
  804160903a:	00 00 00 
  804160903d:	ff d0                	callq  *%rax
  if (!(tf->tf_cs & 0x3)) {
  804160903f:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041609046:	0f 84 1a 01 00 00    	je     8041609166 <trap+0x1be>
    env_destroy(curenv);
  804160904c:	48 b8 b8 eb 61 41 80 	movabs $0x804161ebb8,%rax
  8041609053:	00 00 00 
  8041609056:	48 8b 38             	mov    (%rax),%rdi
  8041609059:	48 b8 e7 86 60 41 80 	movabs $0x80416086e7,%rax
  8041609060:	00 00 00 
  8041609063:	ff d0                	callq  *%rax
  trap_dispatch(tf);

  // If we made it to this point, then no other environment was
  // scheduled, so we should return to the current environment
  // if doing so makes sense.
  if (curenv && curenv->env_status == ENV_RUNNING)
  8041609065:	48 a1 b8 eb 61 41 80 	movabs 0x804161ebb8,%rax
  804160906c:	00 00 00 
  804160906f:	48 85 c0             	test   %rax,%rax
  8041609072:	74 0d                	je     8041609081 <trap+0xd9>
  8041609074:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  804160907b:	0f 84 0f 01 00 00    	je     8041609190 <trap+0x1e8>
    env_run(curenv);
  else
    sched_yield();
  8041609081:	48 b8 9c 9e 60 41 80 	movabs $0x8041609e9c,%rax
  8041609088:	00 00 00 
  804160908b:	ff d0                	callq  *%rax
  assert(!(read_rflags() & FL_IF));
  804160908d:	48 b9 5b d0 60 41 80 	movabs $0x804160d05b,%rcx
  8041609094:	00 00 00 
  8041609097:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  804160909e:	00 00 00 
  80416090a1:	be b4 00 00 00       	mov    $0xb4,%esi
  80416090a6:	48 bf 74 d0 60 41 80 	movabs $0x804160d074,%rdi
  80416090ad:	00 00 00 
  80416090b0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416090b5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416090bc:	00 00 00 
  80416090bf:	41 ff d0             	callq  *%r8
  assert(curenv);
  80416090c2:	48 b9 80 d0 60 41 80 	movabs $0x804160d080,%rcx
  80416090c9:	00 00 00 
  80416090cc:	48 ba 79 b9 60 41 80 	movabs $0x804160b979,%rdx
  80416090d3:	00 00 00 
  80416090d6:	be ba 00 00 00       	mov    $0xba,%esi
  80416090db:	48 bf 74 d0 60 41 80 	movabs $0x804160d074,%rdi
  80416090e2:	00 00 00 
  80416090e5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416090ec:	00 00 00 
  80416090ef:	41 ff d0             	callq  *%r8
    env_free(curenv);
  80416090f2:	48 89 c7             	mov    %rax,%rdi
  80416090f5:	48 b8 78 86 60 41 80 	movabs $0x8041608678,%rax
  80416090fc:	00 00 00 
  80416090ff:	ff d0                	callq  *%rax
    curenv = NULL;
  8041609101:	48 b8 b8 eb 61 41 80 	movabs $0x804161ebb8,%rax
  8041609108:	00 00 00 
  804160910b:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    sched_yield();
  8041609112:	48 b8 9c 9e 60 41 80 	movabs $0x8041609e9c,%rax
  8041609119:	00 00 00 
  804160911c:	ff d0                	callq  *%rax
    cprintf("Spurious interrupt on irq 7\n");
  804160911e:	48 bf 87 d0 60 41 80 	movabs $0x804160d087,%rdi
  8041609125:	00 00 00 
  8041609128:	b8 00 00 00 00       	mov    $0x0,%eax
  804160912d:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041609134:	00 00 00 
  8041609137:	ff d2                	callq  *%rdx
    print_trapframe(tf);
  8041609139:	48 89 df             	mov    %rbx,%rdi
  804160913c:	48 b8 2b 8d 60 41 80 	movabs $0x8041608d2b,%rax
  8041609143:	00 00 00 
  8041609146:	ff d0                	callq  *%rax
    return;
  8041609148:	e9 18 ff ff ff       	jmpq   8041609065 <trap+0xbd>
    timer_for_schedule->handle_interrupts();
  804160914d:	48 a1 80 1c 62 41 80 	movabs 0x8041621c80,%rax
  8041609154:	00 00 00 
  8041609157:	ff 50 20             	callq  *0x20(%rax)
    sched_yield();
  804160915a:	48 b8 9c 9e 60 41 80 	movabs $0x8041609e9c,%rax
  8041609161:	00 00 00 
  8041609164:	ff d0                	callq  *%rax
    panic("unhandled trap in kernel");
  8041609166:	48 ba a4 d0 60 41 80 	movabs $0x804160d0a4,%rdx
  804160916d:	00 00 00 
  8041609170:	be 9f 00 00 00       	mov    $0x9f,%esi
  8041609175:	48 bf 74 d0 60 41 80 	movabs $0x804160d074,%rdi
  804160917c:	00 00 00 
  804160917f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609184:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160918b:	00 00 00 
  804160918e:	ff d1                	callq  *%rcx
    env_run(curenv);
  8041609190:	48 89 c7             	mov    %rax,%rdi
  8041609193:	48 b8 4b 87 60 41 80 	movabs $0x804160874b,%rax
  804160919a:	00 00 00 
  804160919d:	ff d0                	callq  *%rax
  804160919f:	90                   	nop

00000080416091a0 <clock_thdlr>:
  movq %rsp,%rdi
  call trap
  jmp .
#else
clock_thdlr:
  jmp .
  80416091a0:	eb fe                	jmp    80416091a0 <clock_thdlr>

00000080416091a2 <acpi_find_table>:
  return krsdp;
}

// LAB 5 code
static void *
acpi_find_table(const char *sign) {
  80416091a2:	55                   	push   %rbp
  80416091a3:	48 89 e5             	mov    %rsp,%rbp
  80416091a6:	41 57                	push   %r15
  80416091a8:	41 56                	push   %r14
  80416091aa:	41 55                	push   %r13
  80416091ac:	41 54                	push   %r12
  80416091ae:	53                   	push   %rbx
  80416091af:	48 83 ec 28          	sub    $0x28,%rsp
  80416091b3:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  static size_t krsdt_len;
  static size_t krsdt_entsz;

  uint8_t cksm = 0;

  if (!krsdt) {
  80416091b7:	48 b8 00 fc 61 41 80 	movabs $0x804161fc00,%rax
  80416091be:	00 00 00 
  80416091c1:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416091c5:	74 3d                	je     8041609204 <acpi_find_table+0x62>
    }
  }

  ACPISDTHeader *hd = NULL;

  for (size_t i = 0; i < krsdt_len; i++) {
  80416091c7:	48 b8 f0 fb 61 41 80 	movabs $0x804161fbf0,%rax
  80416091ce:	00 00 00 
  80416091d1:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416091d5:	0f 84 f2 03 00 00    	je     80416095cd <acpi_find_table+0x42b>
  80416091db:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    /* Assume little endian */
    uint64_t fadt_pa = 0;
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  80416091e1:	49 bf f8 fb 61 41 80 	movabs $0x804161fbf8,%r15
  80416091e8:	00 00 00 
  80416091eb:	49 bd 00 fc 61 41 80 	movabs $0x804161fc00,%r13
  80416091f2:	00 00 00 
  80416091f5:	49 be 08 af 60 41 80 	movabs $0x804160af08,%r14
  80416091fc:	00 00 00 
  80416091ff:	e9 04 03 00 00       	jmpq   8041609508 <acpi_find_table+0x366>
    if (!uefi_lp->ACPIRoot) {
  8041609204:	48 a1 00 e0 61 41 80 	movabs 0x804161e000,%rax
  804160920b:	00 00 00 
  804160920e:	48 8b 78 10          	mov    0x10(%rax),%rdi
  8041609212:	48 85 ff             	test   %rdi,%rdi
  8041609215:	74 7c                	je     8041609293 <acpi_find_table+0xf1>
    RSDP *krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  8041609217:	be 24 00 00 00       	mov    $0x24,%esi
  804160921c:	48 b8 f6 81 60 41 80 	movabs $0x80416081f6,%rax
  8041609223:	00 00 00 
  8041609226:	ff d0                	callq  *%rax
  8041609228:	49 89 c4             	mov    %rax,%r12
    if (strncmp(krsdp->Signature, "RSD PTR", 8))
  804160922b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041609230:	48 be bb d2 60 41 80 	movabs $0x804160d2bb,%rsi
  8041609237:	00 00 00 
  804160923a:	48 89 c7             	mov    %rax,%rdi
  804160923d:	48 b8 c5 ad 60 41 80 	movabs $0x804160adc5,%rax
  8041609244:	00 00 00 
  8041609247:	ff d0                	callq  *%rax
  8041609249:	85 c0                	test   %eax,%eax
  804160924b:	74 70                	je     80416092bd <acpi_find_table+0x11b>
  804160924d:	4c 89 e0             	mov    %r12,%rax
  8041609250:	49 8d 54 24 14       	lea    0x14(%r12),%rdx
  uint8_t cksm = 0;
  8041609255:	bb 00 00 00 00       	mov    $0x0,%ebx
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160925a:	02 18                	add    (%rax),%bl
    for (size_t i = 0; i < offsetof(RSDP, Length); i++)
  804160925c:	48 83 c0 01          	add    $0x1,%rax
  8041609260:	48 39 d0             	cmp    %rdx,%rax
  8041609263:	75 f5                	jne    804160925a <acpi_find_table+0xb8>
    if (cksm)
  8041609265:	84 db                	test   %bl,%bl
  8041609267:	74 59                	je     80416092c2 <acpi_find_table+0x120>
      panic("Invalid RSDP");
  8041609269:	48 ba c3 d2 60 41 80 	movabs $0x804160d2c3,%rdx
  8041609270:	00 00 00 
  8041609273:	be 7e 00 00 00       	mov    $0x7e,%esi
  8041609278:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  804160927f:	00 00 00 
  8041609282:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609287:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160928e:	00 00 00 
  8041609291:	ff d1                	callq  *%rcx
      panic("No rsdp\n");
  8041609293:	48 ba a5 d2 60 41 80 	movabs $0x804160d2a5,%rdx
  804160929a:	00 00 00 
  804160929d:	be 74 00 00 00       	mov    $0x74,%esi
  80416092a2:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  80416092a9:	00 00 00 
  80416092ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416092b1:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416092b8:	00 00 00 
  80416092bb:	ff d1                	callq  *%rcx
  uint8_t cksm = 0;
  80416092bd:	bb 00 00 00 00       	mov    $0x0,%ebx
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  80416092c2:	45 8b 74 24 10       	mov    0x10(%r12),%r14d
    krsdt_entsz      = 4;
  80416092c7:	48 b8 f8 fb 61 41 80 	movabs $0x804161fbf8,%rax
  80416092ce:	00 00 00 
  80416092d1:	48 c7 00 04 00 00 00 	movq   $0x4,(%rax)
    if (krsdp->Revision) {
  80416092d8:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  80416092de:	0f 84 1b 01 00 00    	je     80416093ff <acpi_find_table+0x25d>
      for (size_t i = 0; i < krsdp->Length; i++)
  80416092e4:	41 8b 54 24 14       	mov    0x14(%r12),%edx
  80416092e9:	48 85 d2             	test   %rdx,%rdx
  80416092ec:	74 11                	je     80416092ff <acpi_find_table+0x15d>
  80416092ee:	4c 89 e0             	mov    %r12,%rax
  80416092f1:	4c 01 e2             	add    %r12,%rdx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  80416092f4:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < krsdp->Length; i++)
  80416092f6:	48 83 c0 01          	add    $0x1,%rax
  80416092fa:	48 39 c2             	cmp    %rax,%rdx
  80416092fd:	75 f5                	jne    80416092f4 <acpi_find_table+0x152>
      if (cksm)
  80416092ff:	84 db                	test   %bl,%bl
  8041609301:	0f 85 4c 01 00 00    	jne    8041609453 <acpi_find_table+0x2b1>
      rsdt_pa     = krsdp->XsdtAddress;
  8041609307:	4d 8b 74 24 18       	mov    0x18(%r12),%r14
      krsdt_entsz = 8;
  804160930c:	48 b8 f8 fb 61 41 80 	movabs $0x804161fbf8,%rax
  8041609313:	00 00 00 
  8041609316:	48 c7 00 08 00 00 00 	movq   $0x8,(%rax)
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  804160931d:	be 24 00 00 00       	mov    $0x24,%esi
  8041609322:	4c 89 f7             	mov    %r14,%rdi
  8041609325:	48 b8 f6 81 60 41 80 	movabs $0x80416081f6,%rax
  804160932c:	00 00 00 
  804160932f:	ff d0                	callq  *%rax
  8041609331:	49 bd 00 fc 61 41 80 	movabs $0x804161fc00,%r13
  8041609338:	00 00 00 
  804160933b:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  804160933f:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609342:	ba 24 00 00 00       	mov    $0x24,%edx
  8041609347:	48 89 c6             	mov    %rax,%rsi
  804160934a:	4c 89 f7             	mov    %r14,%rdi
  804160934d:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  8041609354:	00 00 00 
  8041609357:	ff d0                	callq  *%rax
  8041609359:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160935d:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609360:	48 85 c9             	test   %rcx,%rcx
  8041609363:	74 19                	je     804160937e <acpi_find_table+0x1dc>
  8041609365:	48 89 c2             	mov    %rax,%rdx
  8041609368:	48 01 c1             	add    %rax,%rcx
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdt)[i]);
  804160936b:	02 1a                	add    (%rdx),%bl
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160936d:	48 83 c2 01          	add    $0x1,%rdx
  8041609371:	48 39 d1             	cmp    %rdx,%rcx
  8041609374:	75 f5                	jne    804160936b <acpi_find_table+0x1c9>
    if (cksm)
  8041609376:	84 db                	test   %bl,%bl
  8041609378:	0f 85 ff 00 00 00    	jne    804160947d <acpi_find_table+0x2db>
    if (strncmp(krsdt->h.Signature, krsdp->Revision ? "XSDT" : "RSDT", 4))
  804160937e:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  8041609384:	48 be a0 d2 60 41 80 	movabs $0x804160d2a0,%rsi
  804160938b:	00 00 00 
  804160938e:	48 ba d8 d2 60 41 80 	movabs $0x804160d2d8,%rdx
  8041609395:	00 00 00 
  8041609398:	48 0f 44 f2          	cmove  %rdx,%rsi
  804160939c:	ba 04 00 00 00       	mov    $0x4,%edx
  80416093a1:	48 89 c7             	mov    %rax,%rdi
  80416093a4:	48 b8 c5 ad 60 41 80 	movabs $0x804160adc5,%rax
  80416093ab:	00 00 00 
  80416093ae:	ff d0                	callq  *%rax
  80416093b0:	85 c0                	test   %eax,%eax
  80416093b2:	0f 85 ef 00 00 00    	jne    80416094a7 <acpi_find_table+0x305>
    krsdt_len = (krsdt->h.Length - sizeof(RSDT)) / 4;
  80416093b8:	48 a1 00 fc 61 41 80 	movabs 0x804161fc00,%rax
  80416093bf:	00 00 00 
  80416093c2:	8b 40 04             	mov    0x4(%rax),%eax
  80416093c5:	48 8d 58 dc          	lea    -0x24(%rax),%rbx
  80416093c9:	48 89 da             	mov    %rbx,%rdx
  80416093cc:	48 c1 ea 02          	shr    $0x2,%rdx
  80416093d0:	48 89 d0             	mov    %rdx,%rax
  80416093d3:	48 a3 f0 fb 61 41 80 	movabs %rax,0x804161fbf0
  80416093da:	00 00 00 
    if (krsdp->Revision) {
  80416093dd:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  80416093e3:	0f 84 de fd ff ff    	je     80416091c7 <acpi_find_table+0x25>
      krsdt_len = krsdt_len / 2;
  80416093e9:	48 89 d8             	mov    %rbx,%rax
  80416093ec:	48 c1 e8 03          	shr    $0x3,%rax
  80416093f0:	48 a3 f0 fb 61 41 80 	movabs %rax,0x804161fbf0
  80416093f7:	00 00 00 
  80416093fa:	e9 c8 fd ff ff       	jmpq   80416091c7 <acpi_find_table+0x25>
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  80416093ff:	45 89 f6             	mov    %r14d,%r14d
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  8041609402:	be 24 00 00 00       	mov    $0x24,%esi
  8041609407:	4c 89 f7             	mov    %r14,%rdi
  804160940a:	48 b8 f6 81 60 41 80 	movabs $0x80416081f6,%rax
  8041609411:	00 00 00 
  8041609414:	ff d0                	callq  *%rax
  8041609416:	49 bd 00 fc 61 41 80 	movabs $0x804161fc00,%r13
  804160941d:	00 00 00 
  8041609420:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  8041609424:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609427:	ba 24 00 00 00       	mov    $0x24,%edx
  804160942c:	48 89 c6             	mov    %rax,%rsi
  804160942f:	4c 89 f7             	mov    %r14,%rdi
  8041609432:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  8041609439:	00 00 00 
  804160943c:	ff d0                	callq  *%rax
  804160943e:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  8041609442:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609445:	48 85 c9             	test   %rcx,%rcx
  8041609448:	0f 85 17 ff ff ff    	jne    8041609365 <acpi_find_table+0x1c3>
  804160944e:	e9 23 ff ff ff       	jmpq   8041609376 <acpi_find_table+0x1d4>
        panic("Invalid RSDP");
  8041609453:	48 ba c3 d2 60 41 80 	movabs $0x804160d2c3,%rdx
  804160945a:	00 00 00 
  804160945d:	be 88 00 00 00       	mov    $0x88,%esi
  8041609462:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  8041609469:	00 00 00 
  804160946c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609471:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609478:	00 00 00 
  804160947b:	ff d1                	callq  *%rcx
      panic("Invalid RSDP");
  804160947d:	48 ba c3 d2 60 41 80 	movabs $0x804160d2c3,%rdx
  8041609484:	00 00 00 
  8041609487:	be 96 00 00 00       	mov    $0x96,%esi
  804160948c:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  8041609493:	00 00 00 
  8041609496:	b8 00 00 00 00       	mov    $0x0,%eax
  804160949b:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416094a2:	00 00 00 
  80416094a5:	ff d1                	callq  *%rcx
      panic("Invalid RSDT");
  80416094a7:	48 ba d0 d2 60 41 80 	movabs $0x804160d2d0,%rdx
  80416094ae:	00 00 00 
  80416094b1:	be 99 00 00 00       	mov    $0x99,%esi
  80416094b6:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  80416094bd:	00 00 00 
  80416094c0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416094c5:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416094cc:	00 00 00 
  80416094cf:	ff d1                	callq  *%rcx

    for (size_t i = 0; i < hd->Length; i++)
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
    if (cksm)
      panic("ACPI table '%.4s' invalid", hd->Signature);
    if (!strncmp(hd->Signature, sign, 4))
  80416094d1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416094d6:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  80416094da:	48 89 df             	mov    %rbx,%rdi
  80416094dd:	48 b8 c5 ad 60 41 80 	movabs $0x804160adc5,%rax
  80416094e4:	00 00 00 
  80416094e7:	ff d0                	callq  *%rax
  80416094e9:	85 c0                	test   %eax,%eax
  80416094eb:	0f 84 ca 00 00 00    	je     80416095bb <acpi_find_table+0x419>
  for (size_t i = 0; i < krsdt_len; i++) {
  80416094f1:	49 83 c4 01          	add    $0x1,%r12
  80416094f5:	48 b8 f0 fb 61 41 80 	movabs $0x804161fbf0,%rax
  80416094fc:	00 00 00 
  80416094ff:	4c 39 20             	cmp    %r12,(%rax)
  8041609502:	0f 86 ae 00 00 00    	jbe    80416095b6 <acpi_find_table+0x414>
    uint64_t fadt_pa = 0;
  8041609508:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160950f:	00 
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  8041609510:	49 8b 17             	mov    (%r15),%rdx
  8041609513:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041609517:	48 89 d0             	mov    %rdx,%rax
  804160951a:	49 0f af c4          	imul   %r12,%rax
  804160951e:	48 8d 74 01 24       	lea    0x24(%rcx,%rax,1),%rsi
  8041609523:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041609527:	41 ff d6             	callq  *%r14
    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
  804160952a:	be 24 00 00 00       	mov    $0x24,%esi
  804160952f:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041609533:	48 b8 f6 81 60 41 80 	movabs $0x80416081f6,%rax
  804160953a:	00 00 00 
  804160953d:	ff d0                	callq  *%rax
    hd = mmio_remap_last_region(fadt_pa, hd, sizeof(ACPISDTHeader), krsdt->h.Length);
  804160953f:	49 8b 55 00          	mov    0x0(%r13),%rdx
  8041609543:	8b 4a 04             	mov    0x4(%rdx),%ecx
  8041609546:	ba 24 00 00 00       	mov    $0x24,%edx
  804160954b:	48 89 c6             	mov    %rax,%rsi
  804160954e:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041609552:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  8041609559:	00 00 00 
  804160955c:	ff d0                	callq  *%rax
  804160955e:	48 89 c3             	mov    %rax,%rbx
    for (size_t i = 0; i < hd->Length; i++)
  8041609561:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609564:	48 85 c9             	test   %rcx,%rcx
  8041609567:	0f 84 64 ff ff ff    	je     80416094d1 <acpi_find_table+0x32f>
  804160956d:	48 01 c1             	add    %rax,%rcx
  8041609570:	ba 00 00 00 00       	mov    $0x0,%edx
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
  8041609575:	02 10                	add    (%rax),%dl
    for (size_t i = 0; i < hd->Length; i++)
  8041609577:	48 83 c0 01          	add    $0x1,%rax
  804160957b:	48 39 c1             	cmp    %rax,%rcx
  804160957e:	75 f5                	jne    8041609575 <acpi_find_table+0x3d3>
    if (cksm)
  8041609580:	84 d2                	test   %dl,%dl
  8041609582:	0f 84 49 ff ff ff    	je     80416094d1 <acpi_find_table+0x32f>
      panic("ACPI table '%.4s' invalid", hd->Signature);
  8041609588:	48 89 d9             	mov    %rbx,%rcx
  804160958b:	48 ba dd d2 60 41 80 	movabs $0x804160d2dd,%rdx
  8041609592:	00 00 00 
  8041609595:	be af 00 00 00       	mov    $0xaf,%esi
  804160959a:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  80416095a1:	00 00 00 
  80416095a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416095a9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416095b0:	00 00 00 
  80416095b3:	41 ff d0             	callq  *%r8
      return hd;
  }

  return NULL;
  80416095b6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80416095bb:	48 89 d8             	mov    %rbx,%rax
  80416095be:	48 83 c4 28          	add    $0x28,%rsp
  80416095c2:	5b                   	pop    %rbx
  80416095c3:	41 5c                	pop    %r12
  80416095c5:	41 5d                	pop    %r13
  80416095c7:	41 5e                	pop    %r14
  80416095c9:	41 5f                	pop    %r15
  80416095cb:	5d                   	pop    %rbp
  80416095cc:	c3                   	retq   
  return NULL;
  80416095cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416095d2:	eb e7                	jmp    80416095bb <acpi_find_table+0x419>

00000080416095d4 <hpet_handle_interrupts_tim0>:
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
}

void
hpet_handle_interrupts_tim0(void) {
  80416095d4:	55                   	push   %rbp
  80416095d5:	48 89 e5             	mov    %rsp,%rbp
  pic_send_eoi(IRQ_TIMER);
  80416095d8:	bf 00 00 00 00       	mov    $0x0,%edi
  80416095dd:	48 b8 29 8a 60 41 80 	movabs $0x8041608a29,%rax
  80416095e4:	00 00 00 
  80416095e7:	ff d0                	callq  *%rax
}
  80416095e9:	5d                   	pop    %rbp
  80416095ea:	c3                   	retq   

00000080416095eb <hpet_handle_interrupts_tim1>:

void
hpet_handle_interrupts_tim1(void) {
  80416095eb:	55                   	push   %rbp
  80416095ec:	48 89 e5             	mov    %rsp,%rbp
  pic_send_eoi(IRQ_CLOCK);
  80416095ef:	bf 08 00 00 00       	mov    $0x8,%edi
  80416095f4:	48 b8 29 8a 60 41 80 	movabs $0x8041608a29,%rax
  80416095fb:	00 00 00 
  80416095fe:	ff d0                	callq  *%rax
}
  8041609600:	5d                   	pop    %rbp
  8041609601:	c3                   	retq   

0000008041609602 <hpet_cpu_frequency>:
// about pause instruction.
uint64_t
hpet_cpu_frequency(void) {
  // LAB 5 Your code here.
  uint64_t time_res = 100;
  uint64_t delta = 0, target = hpetFreq / time_res;
  8041609602:	48 a1 18 fc 61 41 80 	movabs 0x804161fc18,%rax
  8041609609:	00 00 00 
  804160960c:	48 c1 e8 02          	shr    $0x2,%rax
  8041609610:	48 ba c3 f5 28 5c 8f 	movabs $0x28f5c28f5c28f5c3,%rdx
  8041609617:	c2 f5 28 
  804160961a:	48 f7 e2             	mul    %rdx
  804160961d:	48 89 d1             	mov    %rdx,%rcx
  8041609620:	48 c1 e9 02          	shr    $0x2,%rcx
  return hpetReg->MAIN_CNT;
  8041609624:	48 a1 28 fc 61 41 80 	movabs 0x804161fc28,%rax
  804160962b:	00 00 00 
  804160962e:	48 8b b8 f0 00 00 00 	mov    0xf0(%rax),%rdi
  __asm __volatile("rdtsc"
  8041609635:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041609637:	48 c1 e2 20          	shl    $0x20,%rdx
  804160963b:	41 89 c0             	mov    %eax,%r8d
  804160963e:	49 09 d0             	or     %rdx,%r8
  8041609641:	48 be 28 fc 61 41 80 	movabs $0x804161fc28,%rsi
  8041609648:	00 00 00 

  uint64_t tick0 = hpet_get_main_cnt();
  uint64_t tsc0  = read_tsc();
  do {
    asm("pause");
  804160964b:	f3 90                	pause  
  return hpetReg->MAIN_CNT;
  804160964d:	48 8b 06             	mov    (%rsi),%rax
  8041609650:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
    delta = hpet_get_main_cnt() - tick0;
  8041609657:	48 29 f8             	sub    %rdi,%rax
  } while (delta < target);
  804160965a:	48 39 c1             	cmp    %rax,%rcx
  804160965d:	77 ec                	ja     804160964b <hpet_cpu_frequency+0x49>
  __asm __volatile("rdtsc"
  804160965f:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041609661:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609665:	89 c0                	mov    %eax,%eax
  8041609667:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * time_res;
  804160966a:	48 89 d0             	mov    %rdx,%rax
  804160966d:	4c 29 c0             	sub    %r8,%rax
  8041609670:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  8041609674:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  8041609678:	48 c1 e0 02          	shl    $0x2,%rax
}
  804160967c:	c3                   	retq   

000000804160967d <hpet_enable_interrupts_tim1>:
hpet_enable_interrupts_tim1(void) {
  804160967d:	55                   	push   %rbp
  804160967e:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  8041609681:	48 b8 28 fc 61 41 80 	movabs $0x804161fc28,%rax
  8041609688:	00 00 00 
  804160968b:	48 8b 08             	mov    (%rax),%rcx
  804160968e:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041609692:	48 83 c8 02          	or     $0x2,%rax
  8041609696:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM1_CONF = (IRQ_CLOCK << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  804160969a:	48 c7 81 20 01 00 00 	movq   $0x104c,0x120(%rcx)
  80416096a1:	4c 10 00 00 
  return hpetReg->MAIN_CNT;
  80416096a5:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM1_COMP = hpet_get_main_cnt() + 3 * Peta / 2 / hpetFemto;
  80416096ac:	48 bf 20 fc 61 41 80 	movabs $0x804161fc20,%rdi
  80416096b3:	00 00 00 
  80416096b6:	48 b8 00 c0 29 f7 3d 	movabs $0x5543df729c000,%rax
  80416096bd:	54 05 00 
  80416096c0:	ba 00 00 00 00       	mov    $0x0,%edx
  80416096c5:	48 f7 37             	divq   (%rdi)
  80416096c8:	48 01 c6             	add    %rax,%rsi
  80416096cb:	48 89 b1 28 01 00 00 	mov    %rsi,0x128(%rcx)
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  80416096d2:	48 89 81 28 01 00 00 	mov    %rax,0x128(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  80416096d9:	66 a1 e8 e7 61 41 80 	movabs 0x804161e7e8,%ax
  80416096e0:	00 00 00 
  80416096e3:	89 c7                	mov    %eax,%edi
  80416096e5:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  80416096eb:	48 b8 c4 88 60 41 80 	movabs $0x80416088c4,%rax
  80416096f2:	00 00 00 
  80416096f5:	ff d0                	callq  *%rax
}
  80416096f7:	5d                   	pop    %rbp
  80416096f8:	c3                   	retq   

00000080416096f9 <hpet_enable_interrupts_tim0>:
hpet_enable_interrupts_tim0(void) {
  80416096f9:	55                   	push   %rbp
  80416096fa:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  80416096fd:	48 b8 28 fc 61 41 80 	movabs $0x804161fc28,%rax
  8041609704:	00 00 00 
  8041609707:	48 8b 08             	mov    (%rax),%rcx
  804160970a:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160970e:	48 83 c8 02          	or     $0x2,%rax
  8041609712:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM0_CONF = (IRQ_TIMER << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  8041609716:	48 c7 81 00 01 00 00 	movq   $0x4c,0x100(%rcx)
  804160971d:	4c 00 00 00 
  return hpetReg->MAIN_CNT;
  8041609721:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM0_COMP = hpet_get_main_cnt() + Peta / 2 / hpetFemto;
  8041609728:	48 bf 20 fc 61 41 80 	movabs $0x804161fc20,%rdi
  804160972f:	00 00 00 
  8041609732:	48 b8 00 40 63 52 bf 	movabs $0x1c6bf52634000,%rax
  8041609739:	c6 01 00 
  804160973c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041609741:	48 f7 37             	divq   (%rdi)
  8041609744:	48 01 c6             	add    %rax,%rsi
  8041609747:	48 89 b1 08 01 00 00 	mov    %rsi,0x108(%rcx)
  hpetReg->TIM0_COMP = Peta / 2 / hpetFemto;
  804160974e:	48 89 81 08 01 00 00 	mov    %rax,0x108(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_TIMER));
  8041609755:	66 a1 e8 e7 61 41 80 	movabs 0x804161e7e8,%ax
  804160975c:	00 00 00 
  804160975f:	89 c7                	mov    %eax,%edi
  8041609761:	81 e7 fe ff 00 00    	and    $0xfffe,%edi
  8041609767:	48 b8 c4 88 60 41 80 	movabs $0x80416088c4,%rax
  804160976e:	00 00 00 
  8041609771:	ff d0                	callq  *%rax
}
  8041609773:	5d                   	pop    %rbp
  8041609774:	c3                   	retq   

0000008041609775 <check_sum>:
  switch (type) {
  8041609775:	85 f6                	test   %esi,%esi
  8041609777:	74 0f                	je     8041609788 <check_sum+0x13>
  uint32_t len = 0;
  8041609779:	ba 00 00 00 00       	mov    $0x0,%edx
  switch (type) {
  804160977e:	83 fe 01             	cmp    $0x1,%esi
  8041609781:	75 08                	jne    804160978b <check_sum+0x16>
      len = ((ACPISDTHeader *)Table)->Length;
  8041609783:	8b 57 04             	mov    0x4(%rdi),%edx
      break;
  8041609786:	eb 03                	jmp    804160978b <check_sum+0x16>
      len = ((RSDP *)Table)->Length;
  8041609788:	8b 57 14             	mov    0x14(%rdi),%edx
  for (int i = 0; i < len; i++)
  804160978b:	85 d2                	test   %edx,%edx
  804160978d:	74 24                	je     80416097b3 <check_sum+0x3e>
  804160978f:	48 89 f8             	mov    %rdi,%rax
  8041609792:	8d 52 ff             	lea    -0x1(%rdx),%edx
  8041609795:	48 8d 74 17 01       	lea    0x1(%rdi,%rdx,1),%rsi
  int sum      = 0;
  804160979a:	ba 00 00 00 00       	mov    $0x0,%edx
    sum += ((uint8_t *)Table)[i];
  804160979f:	0f b6 08             	movzbl (%rax),%ecx
  80416097a2:	01 ca                	add    %ecx,%edx
  for (int i = 0; i < len; i++)
  80416097a4:	48 83 c0 01          	add    $0x1,%rax
  80416097a8:	48 39 f0             	cmp    %rsi,%rax
  80416097ab:	75 f2                	jne    804160979f <check_sum+0x2a>
  if (sum % 0x100 == 0)
  80416097ad:	84 d2                	test   %dl,%dl
  80416097af:	0f 94 c0             	sete   %al
}
  80416097b2:	c3                   	retq   
  int sum      = 0;
  80416097b3:	ba 00 00 00 00       	mov    $0x0,%edx
  80416097b8:	eb f3                	jmp    80416097ad <check_sum+0x38>

00000080416097ba <get_rsdp>:
  if (krsdp != NULL)
  80416097ba:	48 a1 10 fc 61 41 80 	movabs 0x804161fc10,%rax
  80416097c1:	00 00 00 
  80416097c4:	48 85 c0             	test   %rax,%rax
  80416097c7:	74 01                	je     80416097ca <get_rsdp+0x10>
}
  80416097c9:	c3                   	retq   
get_rsdp(void) {
  80416097ca:	55                   	push   %rbp
  80416097cb:	48 89 e5             	mov    %rsp,%rbp
  if (uefi_lp->ACPIRoot == 0)
  80416097ce:	48 a1 00 e0 61 41 80 	movabs 0x804161e000,%rax
  80416097d5:	00 00 00 
  80416097d8:	48 8b 78 10          	mov    0x10(%rax),%rdi
  80416097dc:	48 85 ff             	test   %rdi,%rdi
  80416097df:	74 1d                	je     80416097fe <get_rsdp+0x44>
  krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  80416097e1:	be 24 00 00 00       	mov    $0x24,%esi
  80416097e6:	48 b8 f6 81 60 41 80 	movabs $0x80416081f6,%rax
  80416097ed:	00 00 00 
  80416097f0:	ff d0                	callq  *%rax
  80416097f2:	48 a3 10 fc 61 41 80 	movabs %rax,0x804161fc10
  80416097f9:	00 00 00 
}
  80416097fc:	5d                   	pop    %rbp
  80416097fd:	c3                   	retq   
    panic("No rsdp\n");
  80416097fe:	48 ba a5 d2 60 41 80 	movabs $0x804160d2a5,%rdx
  8041609805:	00 00 00 
  8041609808:	be 64 00 00 00       	mov    $0x64,%esi
  804160980d:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  8041609814:	00 00 00 
  8041609817:	b8 00 00 00 00       	mov    $0x0,%eax
  804160981c:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609823:	00 00 00 
  8041609826:	ff d1                	callq  *%rcx

0000008041609828 <get_fadt>:
  if (!kfadt) {
  8041609828:	48 b8 08 fc 61 41 80 	movabs $0x804161fc08,%rax
  804160982f:	00 00 00 
  8041609832:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609836:	74 0b                	je     8041609843 <get_fadt+0x1b>
}
  8041609838:	48 a1 08 fc 61 41 80 	movabs 0x804161fc08,%rax
  804160983f:	00 00 00 
  8041609842:	c3                   	retq   
get_fadt(void) {
  8041609843:	55                   	push   %rbp
  8041609844:	48 89 e5             	mov    %rsp,%rbp
    kfadt = acpi_find_table("FACP");
  8041609847:	48 bf f7 d2 60 41 80 	movabs $0x804160d2f7,%rdi
  804160984e:	00 00 00 
  8041609851:	48 b8 a2 91 60 41 80 	movabs $0x80416091a2,%rax
  8041609858:	00 00 00 
  804160985b:	ff d0                	callq  *%rax
  804160985d:	48 a3 08 fc 61 41 80 	movabs %rax,0x804161fc08
  8041609864:	00 00 00 
}
  8041609867:	48 a1 08 fc 61 41 80 	movabs 0x804161fc08,%rax
  804160986e:	00 00 00 
  8041609871:	5d                   	pop    %rbp
  8041609872:	c3                   	retq   

0000008041609873 <acpi_enable>:
acpi_enable(void) {
  8041609873:	55                   	push   %rbp
  8041609874:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  8041609877:	48 b8 28 98 60 41 80 	movabs $0x8041609828,%rax
  804160987e:	00 00 00 
  8041609881:	ff d0                	callq  *%rax
  8041609883:	48 89 c1             	mov    %rax,%rcx
  __asm __volatile("outb %0,%w1"
  8041609886:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  804160988a:	8b 51 30             	mov    0x30(%rcx),%edx
  804160988d:	ee                   	out    %al,(%dx)
  while ((inw(fadt->PM1aControlBlock) & 1) == 0) {
  804160988e:	8b 51 40             	mov    0x40(%rcx),%edx
  __asm __volatile("inw %w1,%0"
  8041609891:	66 ed                	in     (%dx),%ax
  8041609893:	a8 01                	test   $0x1,%al
  8041609895:	74 fa                	je     8041609891 <acpi_enable+0x1e>
}
  8041609897:	5d                   	pop    %rbp
  8041609898:	c3                   	retq   

0000008041609899 <get_hpet>:
  if (!khpet) {
  8041609899:	48 b8 e8 fb 61 41 80 	movabs $0x804161fbe8,%rax
  80416098a0:	00 00 00 
  80416098a3:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416098a7:	74 0b                	je     80416098b4 <get_hpet+0x1b>
}
  80416098a9:	48 a1 e8 fb 61 41 80 	movabs 0x804161fbe8,%rax
  80416098b0:	00 00 00 
  80416098b3:	c3                   	retq   
get_hpet(void) {
  80416098b4:	55                   	push   %rbp
  80416098b5:	48 89 e5             	mov    %rsp,%rbp
    khpet = acpi_find_table("HPET");
  80416098b8:	48 bf fc d2 60 41 80 	movabs $0x804160d2fc,%rdi
  80416098bf:	00 00 00 
  80416098c2:	48 b8 a2 91 60 41 80 	movabs $0x80416091a2,%rax
  80416098c9:	00 00 00 
  80416098cc:	ff d0                	callq  *%rax
  80416098ce:	48 a3 e8 fb 61 41 80 	movabs %rax,0x804161fbe8
  80416098d5:	00 00 00 
}
  80416098d8:	48 a1 e8 fb 61 41 80 	movabs 0x804161fbe8,%rax
  80416098df:	00 00 00 
  80416098e2:	5d                   	pop    %rbp
  80416098e3:	c3                   	retq   

00000080416098e4 <hpet_register>:
hpet_register(void) {
  80416098e4:	55                   	push   %rbp
  80416098e5:	48 89 e5             	mov    %rsp,%rbp
  HPET *hpet_timer = get_hpet();
  80416098e8:	48 b8 99 98 60 41 80 	movabs $0x8041609899,%rax
  80416098ef:	00 00 00 
  80416098f2:	ff d0                	callq  *%rax
  if (hpet_timer->address.address == 0)
  80416098f4:	48 8b 78 2c          	mov    0x2c(%rax),%rdi
  80416098f8:	48 85 ff             	test   %rdi,%rdi
  80416098fb:	74 13                	je     8041609910 <hpet_register+0x2c>
  return mmio_map_region(paddr, sizeof(HPETRegister));
  80416098fd:	be 00 04 00 00       	mov    $0x400,%esi
  8041609902:	48 b8 f6 81 60 41 80 	movabs $0x80416081f6,%rax
  8041609909:	00 00 00 
  804160990c:	ff d0                	callq  *%rax
}
  804160990e:	5d                   	pop    %rbp
  804160990f:	c3                   	retq   
    panic("hpet is unavailable\n");
  8041609910:	48 ba 01 d3 60 41 80 	movabs $0x804160d301,%rdx
  8041609917:	00 00 00 
  804160991a:	be db 00 00 00       	mov    $0xdb,%esi
  804160991f:	48 bf ae d2 60 41 80 	movabs $0x804160d2ae,%rdi
  8041609926:	00 00 00 
  8041609929:	b8 00 00 00 00       	mov    $0x0,%eax
  804160992e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609935:	00 00 00 
  8041609938:	ff d1                	callq  *%rcx

000000804160993a <hpet_init>:
  if (hpetReg == NULL) {
  804160993a:	48 b8 28 fc 61 41 80 	movabs $0x804161fc28,%rax
  8041609941:	00 00 00 
  8041609944:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609948:	74 01                	je     804160994b <hpet_init+0x11>
  804160994a:	c3                   	retq   
hpet_init() {
  804160994b:	55                   	push   %rbp
  804160994c:	48 89 e5             	mov    %rsp,%rbp
  804160994f:	53                   	push   %rbx
  8041609950:	48 83 ec 08          	sub    $0x8,%rsp
  __asm __volatile("inb %w1,%0"
  8041609954:	bb 70 00 00 00       	mov    $0x70,%ebx
  8041609959:	89 da                	mov    %ebx,%edx
  804160995b:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) | NMI_LOCK);
  804160995c:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  804160995f:	ee                   	out    %al,(%dx)
    hpetReg   = hpet_register();
  8041609960:	48 b8 e4 98 60 41 80 	movabs $0x80416098e4,%rax
  8041609967:	00 00 00 
  804160996a:	ff d0                	callq  *%rax
  804160996c:	48 89 c6             	mov    %rax,%rsi
  804160996f:	48 a3 28 fc 61 41 80 	movabs %rax,0x804161fc28
  8041609976:	00 00 00 
    hpetFemto = (uintptr_t)(hpetReg->GCAP_ID >> 32);
  8041609979:	48 8b 08             	mov    (%rax),%rcx
  804160997c:	48 c1 e9 20          	shr    $0x20,%rcx
  8041609980:	48 89 c8             	mov    %rcx,%rax
  8041609983:	48 a3 20 fc 61 41 80 	movabs %rax,0x804161fc20
  804160998a:	00 00 00 
    hpetFreq = (1 * Peta) / hpetFemto;
  804160998d:	48 b8 00 80 c6 a4 7e 	movabs $0x38d7ea4c68000,%rax
  8041609994:	8d 03 00 
  8041609997:	ba 00 00 00 00       	mov    $0x0,%edx
  804160999c:	48 f7 f1             	div    %rcx
  804160999f:	48 a3 18 fc 61 41 80 	movabs %rax,0x804161fc18
  80416099a6:	00 00 00 
    hpetReg->GEN_CONF |= 1;
  80416099a9:	48 8b 46 10          	mov    0x10(%rsi),%rax
  80416099ad:	48 83 c8 01          	or     $0x1,%rax
  80416099b1:	48 89 46 10          	mov    %rax,0x10(%rsi)
  __asm __volatile("inb %w1,%0"
  80416099b5:	89 da                	mov    %ebx,%edx
  80416099b7:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  80416099b8:	83 e0 7f             	and    $0x7f,%eax
  80416099bb:	ee                   	out    %al,(%dx)
}
  80416099bc:	48 83 c4 08          	add    $0x8,%rsp
  80416099c0:	5b                   	pop    %rbx
  80416099c1:	5d                   	pop    %rbp
  80416099c2:	c3                   	retq   

00000080416099c3 <hpet_print_struct>:
hpet_print_struct(void) {
  80416099c3:	55                   	push   %rbp
  80416099c4:	48 89 e5             	mov    %rsp,%rbp
  80416099c7:	41 54                	push   %r12
  80416099c9:	53                   	push   %rbx
  HPET *hpet = get_hpet();
  80416099ca:	48 b8 99 98 60 41 80 	movabs $0x8041609899,%rax
  80416099d1:	00 00 00 
  80416099d4:	ff d0                	callq  *%rax
  80416099d6:	49 89 c4             	mov    %rax,%r12
  cprintf("signature = %s\n", (hpet->h).Signature);
  80416099d9:	48 89 c6             	mov    %rax,%rsi
  80416099dc:	48 bf 16 d3 60 41 80 	movabs $0x804160d316,%rdi
  80416099e3:	00 00 00 
  80416099e6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416099eb:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  80416099f2:	00 00 00 
  80416099f5:	ff d3                	callq  *%rbx
  cprintf("length = %08x\n", (hpet->h).Length);
  80416099f7:	41 8b 74 24 04       	mov    0x4(%r12),%esi
  80416099fc:	48 bf 26 d3 60 41 80 	movabs $0x804160d326,%rdi
  8041609a03:	00 00 00 
  8041609a06:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a0b:	ff d3                	callq  *%rbx
  cprintf("revision = %08x\n", (hpet->h).Revision);
  8041609a0d:	41 0f b6 74 24 08    	movzbl 0x8(%r12),%esi
  8041609a13:	48 bf 4a d3 60 41 80 	movabs $0x804160d34a,%rdi
  8041609a1a:	00 00 00 
  8041609a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a22:	ff d3                	callq  *%rbx
  cprintf("checksum = %08x\n", (hpet->h).Checksum);
  8041609a24:	41 0f b6 74 24 09    	movzbl 0x9(%r12),%esi
  8041609a2a:	48 bf 35 d3 60 41 80 	movabs $0x804160d335,%rdi
  8041609a31:	00 00 00 
  8041609a34:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a39:	ff d3                	callq  *%rbx
  cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  8041609a3b:	41 8b 74 24 18       	mov    0x18(%r12),%esi
  8041609a40:	48 bf 46 d3 60 41 80 	movabs $0x804160d346,%rdi
  8041609a47:	00 00 00 
  8041609a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a4f:	ff d3                	callq  *%rbx
  cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  8041609a51:	41 8b 74 24 1c       	mov    0x1c(%r12),%esi
  8041609a56:	48 bf 5b d3 60 41 80 	movabs $0x804160d35b,%rdi
  8041609a5d:	00 00 00 
  8041609a60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a65:	ff d3                	callq  *%rbx
  cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);
  8041609a67:	41 8b 74 24 20       	mov    0x20(%r12),%esi
  8041609a6c:	48 bf 6e d3 60 41 80 	movabs $0x804160d36e,%rdi
  8041609a73:	00 00 00 
  8041609a76:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a7b:	ff d3                	callq  *%rbx
  cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  8041609a7d:	41 0f b6 74 24 24    	movzbl 0x24(%r12),%esi
  8041609a83:	48 bf 87 d3 60 41 80 	movabs $0x804160d387,%rdi
  8041609a8a:	00 00 00 
  8041609a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a92:	ff d3                	callq  *%rbx
  cprintf("comparator_count = %08x\n", hpet->comparator_count);
  8041609a94:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  8041609a9a:	83 e6 1f             	and    $0x1f,%esi
  8041609a9d:	48 bf 9f d3 60 41 80 	movabs $0x804160d39f,%rdi
  8041609aa4:	00 00 00 
  8041609aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609aac:	ff d3                	callq  *%rbx
  cprintf("counter_size = %08x\n", hpet->counter_size);
  8041609aae:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  8041609ab4:	40 c0 ee 05          	shr    $0x5,%sil
  8041609ab8:	83 e6 01             	and    $0x1,%esi
  8041609abb:	48 bf b8 d3 60 41 80 	movabs $0x804160d3b8,%rdi
  8041609ac2:	00 00 00 
  8041609ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609aca:	ff d3                	callq  *%rbx
  cprintf("reserved = %08x\n", hpet->reserved);
  8041609acc:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  8041609ad2:	40 c0 ee 06          	shr    $0x6,%sil
  8041609ad6:	83 e6 01             	and    $0x1,%esi
  8041609ad9:	48 bf cd d3 60 41 80 	movabs $0x804160d3cd,%rdi
  8041609ae0:	00 00 00 
  8041609ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ae8:	ff d3                	callq  *%rbx
  cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  8041609aea:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  8041609af0:	40 c0 ee 07          	shr    $0x7,%sil
  8041609af4:	40 0f b6 f6          	movzbl %sil,%esi
  8041609af8:	48 bf de d3 60 41 80 	movabs $0x804160d3de,%rdi
  8041609aff:	00 00 00 
  8041609b02:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b07:	ff d3                	callq  *%rbx
  cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  8041609b09:	41 0f b7 74 24 26    	movzwl 0x26(%r12),%esi
  8041609b0f:	48 bf f9 d3 60 41 80 	movabs $0x804160d3f9,%rdi
  8041609b16:	00 00 00 
  8041609b19:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b1e:	ff d3                	callq  *%rbx
  cprintf("hpet_number = %08x\n", hpet->hpet_number);
  8041609b20:	41 0f b6 74 24 34    	movzbl 0x34(%r12),%esi
  8041609b26:	48 bf 0f d4 60 41 80 	movabs $0x804160d40f,%rdi
  8041609b2d:	00 00 00 
  8041609b30:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b35:	ff d3                	callq  *%rbx
  cprintf("minimum_tick = %08x\n", hpet->minimum_tick);
  8041609b37:	41 0f b7 74 24 35    	movzwl 0x35(%r12),%esi
  8041609b3d:	48 bf 23 d4 60 41 80 	movabs $0x804160d423,%rdi
  8041609b44:	00 00 00 
  8041609b47:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b4c:	ff d3                	callq  *%rbx
  cprintf("address_structure:\n");
  8041609b4e:	48 bf 38 d4 60 41 80 	movabs $0x804160d438,%rdi
  8041609b55:	00 00 00 
  8041609b58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b5d:	ff d3                	callq  *%rbx
  cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  8041609b5f:	41 0f b6 74 24 28    	movzbl 0x28(%r12),%esi
  8041609b65:	48 bf 4c d4 60 41 80 	movabs $0x804160d44c,%rdi
  8041609b6c:	00 00 00 
  8041609b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b74:	ff d3                	callq  *%rbx
  cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  8041609b76:	41 0f b6 74 24 29    	movzbl 0x29(%r12),%esi
  8041609b7c:	48 bf 65 d4 60 41 80 	movabs $0x804160d465,%rdi
  8041609b83:	00 00 00 
  8041609b86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b8b:	ff d3                	callq  *%rbx
  cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  8041609b8d:	41 0f b6 74 24 2a    	movzbl 0x2a(%r12),%esi
  8041609b93:	48 bf 80 d4 60 41 80 	movabs $0x804160d480,%rdi
  8041609b9a:	00 00 00 
  8041609b9d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ba2:	ff d3                	callq  *%rbx
  cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
  8041609ba4:	49 8b 74 24 2c       	mov    0x2c(%r12),%rsi
  8041609ba9:	48 bf 9c d4 60 41 80 	movabs $0x804160d49c,%rdi
  8041609bb0:	00 00 00 
  8041609bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609bb8:	ff d3                	callq  *%rbx
}
  8041609bba:	5b                   	pop    %rbx
  8041609bbb:	41 5c                	pop    %r12
  8041609bbd:	5d                   	pop    %rbp
  8041609bbe:	c3                   	retq   

0000008041609bbf <hpet_print_reg>:
hpet_print_reg(void) {
  8041609bbf:	55                   	push   %rbp
  8041609bc0:	48 89 e5             	mov    %rsp,%rbp
  8041609bc3:	41 54                	push   %r12
  8041609bc5:	53                   	push   %rbx
  cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  8041609bc6:	49 bc 28 fc 61 41 80 	movabs $0x804161fc28,%r12
  8041609bcd:	00 00 00 
  8041609bd0:	49 8b 04 24          	mov    (%r12),%rax
  8041609bd4:	48 8b 30             	mov    (%rax),%rsi
  8041609bd7:	48 bf ad d4 60 41 80 	movabs $0x804160d4ad,%rdi
  8041609bde:	00 00 00 
  8041609be1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609be6:	48 bb 9c 8a 60 41 80 	movabs $0x8041608a9c,%rbx
  8041609bed:	00 00 00 
  8041609bf0:	ff d3                	callq  *%rbx
  cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  8041609bf2:	49 8b 04 24          	mov    (%r12),%rax
  8041609bf6:	48 8b 70 10          	mov    0x10(%rax),%rsi
  8041609bfa:	48 bf bf d4 60 41 80 	movabs $0x804160d4bf,%rdi
  8041609c01:	00 00 00 
  8041609c04:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c09:	ff d3                	callq  *%rbx
  cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  8041609c0b:	49 8b 04 24          	mov    (%r12),%rax
  8041609c0f:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8041609c13:	48 bf d2 d4 60 41 80 	movabs $0x804160d4d2,%rdi
  8041609c1a:	00 00 00 
  8041609c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c22:	ff d3                	callq  *%rbx
  cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  8041609c24:	49 8b 04 24          	mov    (%r12),%rax
  8041609c28:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
  8041609c2f:	48 bf e6 d4 60 41 80 	movabs $0x804160d4e6,%rdi
  8041609c36:	00 00 00 
  8041609c39:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c3e:	ff d3                	callq  *%rbx
  cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  8041609c40:	49 8b 04 24          	mov    (%r12),%rax
  8041609c44:	48 8b b0 00 01 00 00 	mov    0x100(%rax),%rsi
  8041609c4b:	48 bf f9 d4 60 41 80 	movabs $0x804160d4f9,%rdi
  8041609c52:	00 00 00 
  8041609c55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c5a:	ff d3                	callq  *%rbx
  cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  8041609c5c:	49 8b 04 24          	mov    (%r12),%rax
  8041609c60:	48 8b b0 08 01 00 00 	mov    0x108(%rax),%rsi
  8041609c67:	48 bf 0d d5 60 41 80 	movabs $0x804160d50d,%rdi
  8041609c6e:	00 00 00 
  8041609c71:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c76:	ff d3                	callq  *%rbx
  cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  8041609c78:	49 8b 04 24          	mov    (%r12),%rax
  8041609c7c:	48 8b b0 10 01 00 00 	mov    0x110(%rax),%rsi
  8041609c83:	48 bf 21 d5 60 41 80 	movabs $0x804160d521,%rdi
  8041609c8a:	00 00 00 
  8041609c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c92:	ff d3                	callq  *%rbx
  cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  8041609c94:	49 8b 04 24          	mov    (%r12),%rax
  8041609c98:	48 8b b0 20 01 00 00 	mov    0x120(%rax),%rsi
  8041609c9f:	48 bf 34 d5 60 41 80 	movabs $0x804160d534,%rdi
  8041609ca6:	00 00 00 
  8041609ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609cae:	ff d3                	callq  *%rbx
  cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  8041609cb0:	49 8b 04 24          	mov    (%r12),%rax
  8041609cb4:	48 8b b0 28 01 00 00 	mov    0x128(%rax),%rsi
  8041609cbb:	48 bf 48 d5 60 41 80 	movabs $0x804160d548,%rdi
  8041609cc2:	00 00 00 
  8041609cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609cca:	ff d3                	callq  *%rbx
  cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  8041609ccc:	49 8b 04 24          	mov    (%r12),%rax
  8041609cd0:	48 8b b0 30 01 00 00 	mov    0x130(%rax),%rsi
  8041609cd7:	48 bf 5c d5 60 41 80 	movabs $0x804160d55c,%rdi
  8041609cde:	00 00 00 
  8041609ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ce6:	ff d3                	callq  *%rbx
  cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  8041609ce8:	49 8b 04 24          	mov    (%r12),%rax
  8041609cec:	48 8b b0 40 01 00 00 	mov    0x140(%rax),%rsi
  8041609cf3:	48 bf 6f d5 60 41 80 	movabs $0x804160d56f,%rdi
  8041609cfa:	00 00 00 
  8041609cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609d02:	ff d3                	callq  *%rbx
  cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  8041609d04:	49 8b 04 24          	mov    (%r12),%rax
  8041609d08:	48 8b b0 48 01 00 00 	mov    0x148(%rax),%rsi
  8041609d0f:	48 bf 83 d5 60 41 80 	movabs $0x804160d583,%rdi
  8041609d16:	00 00 00 
  8041609d19:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609d1e:	ff d3                	callq  *%rbx
  cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
  8041609d20:	49 8b 04 24          	mov    (%r12),%rax
  8041609d24:	48 8b b0 50 01 00 00 	mov    0x150(%rax),%rsi
  8041609d2b:	48 bf 97 d5 60 41 80 	movabs $0x804160d597,%rdi
  8041609d32:	00 00 00 
  8041609d35:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609d3a:	ff d3                	callq  *%rbx
}
  8041609d3c:	5b                   	pop    %rbx
  8041609d3d:	41 5c                	pop    %r12
  8041609d3f:	5d                   	pop    %rbp
  8041609d40:	c3                   	retq   

0000008041609d41 <hpet_get_main_cnt>:
  return hpetReg->MAIN_CNT;
  8041609d41:	48 a1 28 fc 61 41 80 	movabs 0x804161fc28,%rax
  8041609d48:	00 00 00 
  8041609d4b:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
}
  8041609d52:	c3                   	retq   

0000008041609d53 <pmtimer_get_timeval>:

uint32_t
pmtimer_get_timeval(void) {
  8041609d53:	55                   	push   %rbp
  8041609d54:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  8041609d57:	48 b8 28 98 60 41 80 	movabs $0x8041609828,%rax
  8041609d5e:	00 00 00 
  8041609d61:	ff d0                	callq  *%rax
  __asm __volatile("inl %w1,%0"
  8041609d63:	8b 50 4c             	mov    0x4c(%rax),%edx
  8041609d66:	ed                   	in     (%dx),%eax
  return inl(fadt->PMTimerBlock);
}
  8041609d67:	5d                   	pop    %rbp
  8041609d68:	c3                   	retq   

0000008041609d69 <pmtimer_cpu_frequency>:
// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
// Hint: use pmtimer_get_timeval function and do not forget that ACPI PM timer
// can be 24-bit or 32-bit.
uint64_t
pmtimer_cpu_frequency(void) {
  8041609d69:	55                   	push   %rbp
  8041609d6a:	48 89 e5             	mov    %rsp,%rbp
  8041609d6d:	41 55                	push   %r13
  8041609d6f:	41 54                	push   %r12
  8041609d71:	53                   	push   %rbx
  8041609d72:	48 83 ec 08          	sub    $0x8,%rsp

  uint32_t time_res = 100;
  uint32_t tick0    = pmtimer_get_timeval();
  8041609d76:	48 b8 53 9d 60 41 80 	movabs $0x8041609d53,%rax
  8041609d7d:	00 00 00 
  8041609d80:	ff d0                	callq  *%rax
  8041609d82:	89 c3                	mov    %eax,%ebx
  __asm __volatile("rdtsc"
  8041609d84:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041609d86:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609d8a:	89 c0                	mov    %eax,%eax
  8041609d8c:	48 09 c2             	or     %rax,%rdx
  8041609d8f:	49 89 d5             	mov    %rdx,%r13

  uint64_t tsc0 = read_tsc();

  do {
    asm("pause");
    uint32_t tick1 = pmtimer_get_timeval();
  8041609d92:	49 bc 53 9d 60 41 80 	movabs $0x8041609d53,%r12
  8041609d99:	00 00 00 
  8041609d9c:	eb 17                	jmp    8041609db5 <pmtimer_cpu_frequency+0x4c>
    delta          = tick1 - tick0;
    if (-delta <= 0xFFFFFF) {
      delta += 0xFFFFFF;
    } else if (tick0 > tick1) {
  8041609d9e:	39 c3                	cmp    %eax,%ebx
  8041609da0:	76 0a                	jbe    8041609dac <pmtimer_cpu_frequency+0x43>
      delta += 0xFFFFFFFF;
  8041609da2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041609da7:	48 01 c1             	add    %rax,%rcx
  8041609daa:	eb 28                	jmp    8041609dd4 <pmtimer_cpu_frequency+0x6b>
    }
  } while (delta < target);
  8041609dac:	48 81 f9 d2 8b 00 00 	cmp    $0x8bd2,%rcx
  8041609db3:	77 1f                	ja     8041609dd4 <pmtimer_cpu_frequency+0x6b>
    asm("pause");
  8041609db5:	f3 90                	pause  
    uint32_t tick1 = pmtimer_get_timeval();
  8041609db7:	41 ff d4             	callq  *%r12
    delta          = tick1 - tick0;
  8041609dba:	89 c1                	mov    %eax,%ecx
  8041609dbc:	29 d9                	sub    %ebx,%ecx
    if (-delta <= 0xFFFFFF) {
  8041609dbe:	48 89 ca             	mov    %rcx,%rdx
  8041609dc1:	48 f7 da             	neg    %rdx
  8041609dc4:	48 81 fa ff ff ff 00 	cmp    $0xffffff,%rdx
  8041609dcb:	77 d1                	ja     8041609d9e <pmtimer_cpu_frequency+0x35>
      delta += 0xFFFFFF;
  8041609dcd:	48 81 c1 ff ff ff 00 	add    $0xffffff,%rcx
  __asm __volatile("rdtsc"
  8041609dd4:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041609dd6:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609dda:	89 c0                	mov    %eax,%eax
  8041609ddc:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * PM_FREQ / delta;
  8041609ddf:	4c 29 ea             	sub    %r13,%rdx
  8041609de2:	48 69 c2 99 9e 36 00 	imul   $0x369e99,%rdx,%rax
  8041609de9:	ba 00 00 00 00       	mov    $0x0,%edx
  8041609dee:	48 f7 f1             	div    %rcx
}
  8041609df1:	48 83 c4 08          	add    $0x8,%rsp
  8041609df5:	5b                   	pop    %rbx
  8041609df6:	41 5c                	pop    %r12
  8041609df8:	41 5d                	pop    %r13
  8041609dfa:	5d                   	pop    %rbp
  8041609dfb:	c3                   	retq   

0000008041609dfc <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041609dfc:	48 a1 a8 e7 61 41 80 	movabs 0x804161e7a8,%rax
  8041609e03:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  8041609e06:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  8041609e0c:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041609e0f:	83 fa 02             	cmp    $0x2,%edx
  8041609e12:	76 5c                	jbe    8041609e70 <sched_halt+0x74>
  8041609e14:	48 8d 90 b4 01 00 00 	lea    0x1b4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  8041609e1b:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  8041609e20:	8b 02                	mov    (%rdx),%eax
  8041609e22:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041609e25:	83 f8 02             	cmp    $0x2,%eax
  8041609e28:	76 46                	jbe    8041609e70 <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  8041609e2a:	83 c1 01             	add    $0x1,%ecx
  8041609e2d:	48 81 c2 e0 00 00 00 	add    $0xe0,%rdx
  8041609e34:	83 f9 20             	cmp    $0x20,%ecx
  8041609e37:	75 e7                	jne    8041609e20 <sched_halt+0x24>
sched_halt(void) {
  8041609e39:	55                   	push   %rbp
  8041609e3a:	48 89 e5             	mov    %rsp,%rbp
  8041609e3d:	53                   	push   %rbx
  8041609e3e:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  8041609e42:	48 bf b8 d5 60 41 80 	movabs $0x804160d5b8,%rdi
  8041609e49:	00 00 00 
  8041609e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609e51:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  8041609e58:	00 00 00 
  8041609e5b:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  8041609e5d:	48 bb 20 3f 60 41 80 	movabs $0x8041603f20,%rbx
  8041609e64:	00 00 00 
  8041609e67:	bf 00 00 00 00       	mov    $0x0,%edi
  8041609e6c:	ff d3                	callq  *%rbx
    while (1)
  8041609e6e:	eb f7                	jmp    8041609e67 <sched_halt+0x6b>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  8041609e70:	48 b8 b8 eb 61 41 80 	movabs $0x804161ebb8,%rax
  8041609e77:	00 00 00 
  8041609e7a:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  8041609e81:	48 a1 84 1d 62 41 80 	movabs 0x8041621d84,%rax
  8041609e88:	00 00 00 
  8041609e8b:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  8041609e92:	48 89 c4             	mov    %rax,%rsp
  8041609e95:	6a 00                	pushq  $0x0
  8041609e97:	6a 00                	pushq  $0x0
  8041609e99:	fb                   	sti    
  8041609e9a:	f4                   	hlt    
  8041609e9b:	c3                   	retq   

0000008041609e9c <sched_yield>:
sched_yield(void) {
  8041609e9c:	55                   	push   %rbp
  8041609e9d:	48 89 e5             	mov    %rsp,%rbp
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  8041609ea0:	48 a1 b8 eb 61 41 80 	movabs 0x804161ebb8,%rax
  8041609ea7:	00 00 00 
  8041609eaa:	be 00 00 00 00       	mov    $0x0,%esi
  8041609eaf:	48 85 c0             	test   %rax,%rax
  8041609eb2:	74 09                	je     8041609ebd <sched_yield+0x21>
  8041609eb4:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041609eba:	83 e6 1f             	and    $0x1f,%esi
    if (envs[id].env_status == ENV_RUNNABLE ||
  8041609ebd:	48 b8 a8 e7 61 41 80 	movabs $0x804161e7a8,%rax
  8041609ec4:	00 00 00 
  8041609ec7:	4c 8b 00             	mov    (%rax),%r8
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  8041609eca:	89 f2                	mov    %esi,%edx
  8041609ecc:	eb 04                	jmp    8041609ed2 <sched_yield+0x36>
  } while (id != orig);
  8041609ece:	39 c6                	cmp    %eax,%esi
  8041609ed0:	74 45                	je     8041609f17 <sched_yield+0x7b>
    id = (id + 1) % NENV;
  8041609ed2:	8d 42 01             	lea    0x1(%rdx),%eax
  8041609ed5:	99                   	cltd   
  8041609ed6:	c1 ea 1b             	shr    $0x1b,%edx
  8041609ed9:	01 d0                	add    %edx,%eax
  8041609edb:	83 e0 1f             	and    $0x1f,%eax
  8041609ede:	29 d0                	sub    %edx,%eax
  8041609ee0:	89 c2                	mov    %eax,%edx
    if (envs[id].env_status == ENV_RUNNABLE ||
  8041609ee2:	48 63 c8             	movslq %eax,%rcx
  8041609ee5:	48 8d 3c cd 00 00 00 	lea    0x0(,%rcx,8),%rdi
  8041609eec:	00 
  8041609eed:	48 29 cf             	sub    %rcx,%rdi
  8041609ef0:	48 c1 e7 05          	shl    $0x5,%rdi
  8041609ef4:	4c 01 c7             	add    %r8,%rdi
  8041609ef7:	8b 8f d4 00 00 00    	mov    0xd4(%rdi),%ecx
  8041609efd:	83 f9 02             	cmp    $0x2,%ecx
  8041609f00:	74 09                	je     8041609f0b <sched_yield+0x6f>
        (id == orig && envs[id].env_status == ENV_RUNNING)) {
  8041609f02:	83 f9 03             	cmp    $0x3,%ecx
  8041609f05:	75 c7                	jne    8041609ece <sched_yield+0x32>
  8041609f07:	39 c6                	cmp    %eax,%esi
  8041609f09:	75 c3                	jne    8041609ece <sched_yield+0x32>
      env_run(envs + id);
  8041609f0b:	48 b8 4b 87 60 41 80 	movabs $0x804160874b,%rax
  8041609f12:	00 00 00 
  8041609f15:	ff d0                	callq  *%rax
  sched_halt();
  8041609f17:	48 b8 fc 9d 60 41 80 	movabs $0x8041609dfc,%rax
  8041609f1e:	00 00 00 
  8041609f21:	ff d0                	callq  *%rax
}
  8041609f23:	5d                   	pop    %rbp
  8041609f24:	c3                   	retq   

0000008041609f25 <load_kernel_dwarf_info>:
#include <kern/kdebug.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  8041609f25:	48 ba 00 e0 61 41 80 	movabs $0x804161e000,%rdx
  8041609f2c:	00 00 00 
  8041609f2f:	48 8b 02             	mov    (%rdx),%rax
  8041609f32:	48 8b 48 58          	mov    0x58(%rax),%rcx
  8041609f36:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  8041609f3a:	48 8b 48 60          	mov    0x60(%rax),%rcx
  8041609f3e:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  8041609f42:	48 8b 40 68          	mov    0x68(%rax),%rax
  8041609f46:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  8041609f49:	48 8b 02             	mov    (%rdx),%rax
  8041609f4c:	48 8b 50 70          	mov    0x70(%rax),%rdx
  8041609f50:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  8041609f54:	48 8b 50 78          	mov    0x78(%rax),%rdx
  8041609f58:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  8041609f5c:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  8041609f63:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  8041609f67:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  8041609f6e:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  8041609f72:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  8041609f79:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  8041609f7d:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  8041609f84:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  8041609f88:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  8041609f8f:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  8041609f93:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  8041609f9a:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  8041609f9e:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  8041609fa5:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  8041609fa9:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  8041609fb0:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  8041609fb4:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  8041609fbb:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  8041609fbf:	c3                   	retq   

0000008041609fc0 <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  8041609fc0:	55                   	push   %rbp
  8041609fc1:	48 89 e5             	mov    %rsp,%rbp
  8041609fc4:	41 56                	push   %r14
  8041609fc6:	41 55                	push   %r13
  8041609fc8:	41 54                	push   %r12
  8041609fca:	53                   	push   %rbx
  8041609fcb:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  8041609fd2:	49 89 fc             	mov    %rdi,%r12
  8041609fd5:	48 89 f3             	mov    %rsi,%rbx
  int code = 0;
  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  8041609fd8:	48 be e1 d5 60 41 80 	movabs $0x804160d5e1,%rsi
  8041609fdf:	00 00 00 
  8041609fe2:	48 89 df             	mov    %rbx,%rdi
  8041609fe5:	49 bd e6 ac 60 41 80 	movabs $0x804160ace6,%r13
  8041609fec:	00 00 00 
  8041609fef:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  8041609ff2:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  8041609ff9:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  8041609ffc:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  804160a003:	48 be e1 d5 60 41 80 	movabs $0x804160d5e1,%rsi
  804160a00a:	00 00 00 
  804160a00d:	4c 89 f7             	mov    %r14,%rdi
  804160a010:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  804160a013:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  804160a01a:	00 00 00 
  info->rip_fn_addr    = addr;
  804160a01d:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  804160a024:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  804160a02b:	00 00 00 

  if (!addr) {
  804160a02e:	4d 85 e4             	test   %r12,%r12
  804160a031:	0f 84 99 01 00 00    	je     804160a1d0 <debuginfo_rip+0x210>
    return 0;
  }

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  804160a037:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  804160a03e:	00 00 00 
  804160a041:	49 39 c4             	cmp    %rax,%r12
  804160a044:	0f 86 5c 01 00 00    	jbe    804160a1a6 <debuginfo_rip+0x1e6>
    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  804160a04a:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a051:	48 b8 25 9f 60 41 80 	movabs $0x8041609f25,%rax
  804160a058:	00 00 00 
  804160a05b:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  804160a05d:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  804160a064:	00 00 00 00 
  804160a068:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  804160a06f:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  804160a073:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  804160a07a:	4c 89 e6             	mov    %r12,%rsi
  804160a07d:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a084:	48 b8 b1 16 60 41 80 	movabs $0x80416016b1,%rax
  804160a08b:	00 00 00 
  804160a08e:	ff d0                	callq  *%rax
  804160a090:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  804160a093:	85 c0                	test   %eax,%eax
  804160a095:	0f 88 3b 01 00 00    	js     804160a1d6 <debuginfo_rip+0x216>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  804160a09b:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  804160a0a2:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160a0a7:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160a0ae:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  804160a0b5:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a0bc:	48 b8 60 1d 60 41 80 	movabs $0x8041601d60,%rax
  804160a0c3:	00 00 00 
  804160a0c6:	ff d0                	callq  *%rax
  804160a0c8:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  804160a0cb:	ba 00 01 00 00       	mov    $0x100,%edx
  804160a0d0:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160a0d7:	48 89 df             	mov    %rbx,%rdi
  804160a0da:	48 b8 34 ad 60 41 80 	movabs $0x804160ad34,%rax
  804160a0e1:	00 00 00 
  804160a0e4:	ff d0                	callq  *%rax
  if (code < 0) {
  804160a0e6:	45 85 ed             	test   %r13d,%r13d
  804160a0e9:	0f 88 e7 00 00 00    	js     804160a1d6 <debuginfo_rip+0x216>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c

  int lineno_store;
  addr           = addr - 5;
  804160a0ef:	49 83 ec 05          	sub    $0x5,%r12
  code           = line_for_address(&addrs, addr, line_offset, &lineno_store);
  804160a0f3:	48 8d 8d 54 ff ff ff 	lea    -0xac(%rbp),%rcx
  804160a0fa:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  804160a101:	4c 89 e6             	mov    %r12,%rsi
  804160a104:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a10b:	48 b8 aa 32 60 41 80 	movabs $0x80416032aa,%rax
  804160a112:	00 00 00 
  804160a115:	ff d0                	callq  *%rax
  804160a117:	41 89 c5             	mov    %eax,%r13d
  info->rip_line = lineno_store;
  804160a11a:	8b 85 54 ff ff ff    	mov    -0xac(%rbp),%eax
  804160a120:	89 83 00 01 00 00    	mov    %eax,0x100(%rbx)
  if (code < 0) {
  804160a126:	45 85 ed             	test   %r13d,%r13d
  804160a129:	0f 88 a7 00 00 00    	js     804160a1d6 <debuginfo_rip+0x216>
    return code;
  }

  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  804160a12f:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  804160a136:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160a13c:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  804160a143:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  804160a14a:	4c 89 e6             	mov    %r12,%rsi
  804160a14d:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a154:	48 b8 cb 21 60 41 80 	movabs $0x80416021cb,%rax
  804160a15b:	00 00 00 
  804160a15e:	ff d0                	callq  *%rax
  804160a160:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  804160a163:	ba 00 01 00 00       	mov    $0x100,%edx
  804160a168:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160a16f:	4c 89 f7             	mov    %r14,%rdi
  804160a172:	48 b8 34 ad 60 41 80 	movabs $0x804160ad34,%rax
  804160a179:	00 00 00 
  804160a17c:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  804160a17e:	be 00 01 00 00       	mov    $0x100,%esi
  804160a183:	4c 89 f7             	mov    %r14,%rdi
  804160a186:	48 b8 b1 ac 60 41 80 	movabs $0x804160acb1,%rax
  804160a18d:	00 00 00 
  804160a190:	ff d0                	callq  *%rax
  804160a192:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  804160a198:	45 85 ed             	test   %r13d,%r13d
  804160a19b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a1a0:	44 0f 4f e8          	cmovg  %eax,%r13d
  804160a1a4:	eb 30                	jmp    804160a1d6 <debuginfo_rip+0x216>
    panic("Can't search for user-level addresses yet!");
  804160a1a6:	48 ba 00 d6 60 41 80 	movabs $0x804160d600,%rdx
  804160a1ad:	00 00 00 
  804160a1b0:	be 38 00 00 00       	mov    $0x38,%esi
  804160a1b5:	48 bf eb d5 60 41 80 	movabs $0x804160d5eb,%rdi
  804160a1bc:	00 00 00 
  804160a1bf:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a1c4:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a1cb:	00 00 00 
  804160a1ce:	ff d1                	callq  *%rcx
    return 0;
  804160a1d0:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    return code;
  }
  return 0;
}
  804160a1d6:	44 89 e8             	mov    %r13d,%eax
  804160a1d9:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  804160a1e0:	5b                   	pop    %rbx
  804160a1e1:	41 5c                	pop    %r12
  804160a1e3:	41 5d                	pop    %r13
  804160a1e5:	41 5e                	pop    %r14
  804160a1e7:	5d                   	pop    %rbp
  804160a1e8:	c3                   	retq   

000000804160a1e9 <find_function>:

uintptr_t
find_function(const char *const fname) {
  804160a1e9:	55                   	push   %rbp
  804160a1ea:	48 89 e5             	mov    %rsp,%rbp
  804160a1ed:	53                   	push   %rbx
  804160a1ee:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  804160a1f5:	48 89 fb             	mov    %rdi,%rbx
    }
  }
#endif

  struct Dwarf_Addrs addrs;
  load_kernel_dwarf_info(&addrs);
  804160a1f8:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160a1fc:	48 b8 25 9f 60 41 80 	movabs $0x8041609f25,%rax
  804160a203:	00 00 00 
  804160a206:	ff d0                	callq  *%rax
  uintptr_t offset = 0;
  804160a208:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  804160a20f:	00 00 00 00 

  if (!address_by_fname(&addrs, fname, &offset) && offset) {
  804160a213:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160a21a:	48 89 de             	mov    %rbx,%rsi
  804160a21d:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160a221:	48 b8 57 27 60 41 80 	movabs $0x8041602757,%rax
  804160a228:	00 00 00 
  804160a22b:	ff d0                	callq  *%rax
  804160a22d:	85 c0                	test   %eax,%eax
  804160a22f:	75 0c                	jne    804160a23d <find_function+0x54>
  804160a231:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160a238:	48 85 d2             	test   %rdx,%rdx
  804160a23b:	75 23                	jne    804160a260 <find_function+0x77>
    return offset;
  }

  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160a23d:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160a244:	48 89 de             	mov    %rbx,%rsi
  804160a247:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160a24b:	48 b8 55 2d 60 41 80 	movabs $0x8041602d55,%rax
  804160a252:	00 00 00 
  804160a255:	ff d0                	callq  *%rax
    return offset;
  }

  return 0;
  804160a257:	ba 00 00 00 00       	mov    $0x0,%edx
  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160a25c:	85 c0                	test   %eax,%eax
  804160a25e:	74 0d                	je     804160a26d <find_function+0x84>
}
  804160a260:	48 89 d0             	mov    %rdx,%rax
  804160a263:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  804160a26a:	5b                   	pop    %rbx
  804160a26b:	5d                   	pop    %rbp
  804160a26c:	c3                   	retq   
    return offset;
  804160a26d:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160a274:	eb ea                	jmp    804160a260 <find_function+0x77>

000000804160a276 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  804160a276:	55                   	push   %rbp
  804160a277:	48 89 e5             	mov    %rsp,%rbp
  804160a27a:	41 57                	push   %r15
  804160a27c:	41 56                	push   %r14
  804160a27e:	41 55                	push   %r13
  804160a280:	41 54                	push   %r12
  804160a282:	53                   	push   %rbx
  804160a283:	48 83 ec 18          	sub    $0x18,%rsp
  804160a287:	49 89 fc             	mov    %rdi,%r12
  804160a28a:	49 89 f5             	mov    %rsi,%r13
  804160a28d:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160a291:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  804160a294:	41 89 cf             	mov    %ecx,%r15d
  804160a297:	49 39 d7             	cmp    %rdx,%r15
  804160a29a:	76 45                	jbe    804160a2e1 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  804160a29c:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160a2a0:	85 db                	test   %ebx,%ebx
  804160a2a2:	7e 0e                	jle    804160a2b2 <printnum+0x3c>
      putch(padc, putdat);
  804160a2a4:	4c 89 ee             	mov    %r13,%rsi
  804160a2a7:	44 89 f7             	mov    %r14d,%edi
  804160a2aa:	41 ff d4             	callq  *%r12
    while (--width > 0)
  804160a2ad:	83 eb 01             	sub    $0x1,%ebx
  804160a2b0:	75 f2                	jne    804160a2a4 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  804160a2b2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160a2b6:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a2bb:	49 f7 f7             	div    %r15
  804160a2be:	48 b8 2b d6 60 41 80 	movabs $0x804160d62b,%rax
  804160a2c5:	00 00 00 
  804160a2c8:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  804160a2cc:	4c 89 ee             	mov    %r13,%rsi
  804160a2cf:	41 ff d4             	callq  *%r12
}
  804160a2d2:	48 83 c4 18          	add    $0x18,%rsp
  804160a2d6:	5b                   	pop    %rbx
  804160a2d7:	41 5c                	pop    %r12
  804160a2d9:	41 5d                	pop    %r13
  804160a2db:	41 5e                	pop    %r14
  804160a2dd:	41 5f                	pop    %r15
  804160a2df:	5d                   	pop    %rbp
  804160a2e0:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  804160a2e1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160a2e5:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a2ea:	49 f7 f7             	div    %r15
  804160a2ed:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  804160a2f1:	48 89 c2             	mov    %rax,%rdx
  804160a2f4:	48 b8 76 a2 60 41 80 	movabs $0x804160a276,%rax
  804160a2fb:	00 00 00 
  804160a2fe:	ff d0                	callq  *%rax
  804160a300:	eb b0                	jmp    804160a2b2 <printnum+0x3c>

000000804160a302 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  804160a302:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  804160a306:	48 8b 06             	mov    (%rsi),%rax
  804160a309:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  804160a30d:	73 0a                	jae    804160a319 <sprintputch+0x17>
    *b->buf++ = ch;
  804160a30f:	48 8d 50 01          	lea    0x1(%rax),%rdx
  804160a313:	48 89 16             	mov    %rdx,(%rsi)
  804160a316:	40 88 38             	mov    %dil,(%rax)
}
  804160a319:	c3                   	retq   

000000804160a31a <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  804160a31a:	55                   	push   %rbp
  804160a31b:	48 89 e5             	mov    %rsp,%rbp
  804160a31e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160a325:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160a32c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160a333:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160a33a:	84 c0                	test   %al,%al
  804160a33c:	74 20                	je     804160a35e <printfmt+0x44>
  804160a33e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160a342:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160a346:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160a34a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160a34e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160a352:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160a356:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160a35a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  804160a35e:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160a365:	00 00 00 
  804160a368:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160a36f:	00 00 00 
  804160a372:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160a376:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160a37d:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160a384:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  804160a38b:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160a392:	48 b8 a0 a3 60 41 80 	movabs $0x804160a3a0,%rax
  804160a399:	00 00 00 
  804160a39c:	ff d0                	callq  *%rax
}
  804160a39e:	c9                   	leaveq 
  804160a39f:	c3                   	retq   

000000804160a3a0 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  804160a3a0:	55                   	push   %rbp
  804160a3a1:	48 89 e5             	mov    %rsp,%rbp
  804160a3a4:	41 57                	push   %r15
  804160a3a6:	41 56                	push   %r14
  804160a3a8:	41 55                	push   %r13
  804160a3aa:	41 54                	push   %r12
  804160a3ac:	53                   	push   %rbx
  804160a3ad:	48 83 ec 48          	sub    $0x48,%rsp
  804160a3b1:	49 89 fd             	mov    %rdi,%r13
  804160a3b4:	49 89 f7             	mov    %rsi,%r15
  804160a3b7:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  804160a3ba:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  804160a3be:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  804160a3c2:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160a3c6:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160a3ca:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  804160a3ce:	41 0f b6 3e          	movzbl (%r14),%edi
  804160a3d2:	83 ff 25             	cmp    $0x25,%edi
  804160a3d5:	74 18                	je     804160a3ef <vprintfmt+0x4f>
      if (ch == '\0')
  804160a3d7:	85 ff                	test   %edi,%edi
  804160a3d9:	0f 84 8c 06 00 00    	je     804160aa6b <vprintfmt+0x6cb>
      putch(ch, putdat);
  804160a3df:	4c 89 fe             	mov    %r15,%rsi
  804160a3e2:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160a3e5:	49 89 de             	mov    %rbx,%r14
  804160a3e8:	eb e0                	jmp    804160a3ca <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160a3ea:	49 89 de             	mov    %rbx,%r14
  804160a3ed:	eb db                	jmp    804160a3ca <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  804160a3ef:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  804160a3f3:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  804160a3f7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  804160a3fe:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  804160a404:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  804160a408:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  804160a40d:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160a413:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  804160a419:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  804160a41e:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  804160a423:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  804160a427:	0f b6 13             	movzbl (%rbx),%edx
  804160a42a:	8d 42 dd             	lea    -0x23(%rdx),%eax
  804160a42d:	3c 55                	cmp    $0x55,%al
  804160a42f:	0f 87 8b 05 00 00    	ja     804160a9c0 <vprintfmt+0x620>
  804160a435:	0f b6 c0             	movzbl %al,%eax
  804160a438:	49 bb e0 d6 60 41 80 	movabs $0x804160d6e0,%r11
  804160a43f:	00 00 00 
  804160a442:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  804160a446:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  804160a449:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  804160a44d:	eb d4                	jmp    804160a423 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160a44f:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  804160a452:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  804160a456:	eb cb                	jmp    804160a423 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160a458:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  804160a45b:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  804160a45f:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  804160a463:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160a466:	83 fa 09             	cmp    $0x9,%edx
  804160a469:	77 7e                	ja     804160a4e9 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  804160a46b:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  804160a46f:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  804160a473:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  804160a478:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  804160a47c:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160a47f:	83 fa 09             	cmp    $0x9,%edx
  804160a482:	76 e7                	jbe    804160a46b <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  804160a484:	4c 89 f3             	mov    %r14,%rbx
  804160a487:	eb 19                	jmp    804160a4a2 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  804160a489:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a48c:	83 f8 2f             	cmp    $0x2f,%eax
  804160a48f:	77 2a                	ja     804160a4bb <vprintfmt+0x11b>
  804160a491:	89 c2                	mov    %eax,%edx
  804160a493:	4c 01 d2             	add    %r10,%rdx
  804160a496:	83 c0 08             	add    $0x8,%eax
  804160a499:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a49c:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  804160a49f:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  804160a4a2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160a4a6:	0f 89 77 ff ff ff    	jns    804160a423 <vprintfmt+0x83>
          width = precision, precision = -1;
  804160a4ac:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160a4b0:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  804160a4b6:	e9 68 ff ff ff       	jmpq   804160a423 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  804160a4bb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a4bf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a4c3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a4c7:	eb d3                	jmp    804160a49c <vprintfmt+0xfc>
        if (width < 0)
  804160a4c9:	8b 45 ac             	mov    -0x54(%rbp),%eax
  804160a4cc:	85 c0                	test   %eax,%eax
  804160a4ce:	41 0f 48 c0          	cmovs  %r8d,%eax
  804160a4d2:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  804160a4d5:	4c 89 f3             	mov    %r14,%rbx
  804160a4d8:	e9 46 ff ff ff       	jmpq   804160a423 <vprintfmt+0x83>
  804160a4dd:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  804160a4e0:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  804160a4e4:	e9 3a ff ff ff       	jmpq   804160a423 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160a4e9:	4c 89 f3             	mov    %r14,%rbx
  804160a4ec:	eb b4                	jmp    804160a4a2 <vprintfmt+0x102>
        lflag++;
  804160a4ee:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  804160a4f1:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  804160a4f4:	e9 2a ff ff ff       	jmpq   804160a423 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  804160a4f9:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a4fc:	83 f8 2f             	cmp    $0x2f,%eax
  804160a4ff:	77 19                	ja     804160a51a <vprintfmt+0x17a>
  804160a501:	89 c2                	mov    %eax,%edx
  804160a503:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a507:	83 c0 08             	add    $0x8,%eax
  804160a50a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a50d:	4c 89 fe             	mov    %r15,%rsi
  804160a510:	8b 3a                	mov    (%rdx),%edi
  804160a512:	41 ff d5             	callq  *%r13
        break;
  804160a515:	e9 b0 fe ff ff       	jmpq   804160a3ca <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  804160a51a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a51e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a522:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a526:	eb e5                	jmp    804160a50d <vprintfmt+0x16d>
        err = va_arg(aq, int);
  804160a528:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a52b:	83 f8 2f             	cmp    $0x2f,%eax
  804160a52e:	77 5b                	ja     804160a58b <vprintfmt+0x1eb>
  804160a530:	89 c2                	mov    %eax,%edx
  804160a532:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a536:	83 c0 08             	add    $0x8,%eax
  804160a539:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a53c:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  804160a53e:	89 c8                	mov    %ecx,%eax
  804160a540:	c1 f8 1f             	sar    $0x1f,%eax
  804160a543:	31 c1                	xor    %eax,%ecx
  804160a545:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  804160a547:	83 f9 08             	cmp    $0x8,%ecx
  804160a54a:	7f 4d                	jg     804160a599 <vprintfmt+0x1f9>
  804160a54c:	48 63 c1             	movslq %ecx,%rax
  804160a54f:	48 ba a0 d9 60 41 80 	movabs $0x804160d9a0,%rdx
  804160a556:	00 00 00 
  804160a559:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  804160a55d:	48 85 c0             	test   %rax,%rax
  804160a560:	74 37                	je     804160a599 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  804160a562:	48 89 c1             	mov    %rax,%rcx
  804160a565:	48 ba 8b b9 60 41 80 	movabs $0x804160b98b,%rdx
  804160a56c:	00 00 00 
  804160a56f:	4c 89 fe             	mov    %r15,%rsi
  804160a572:	4c 89 ef             	mov    %r13,%rdi
  804160a575:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a57a:	48 bb 1a a3 60 41 80 	movabs $0x804160a31a,%rbx
  804160a581:	00 00 00 
  804160a584:	ff d3                	callq  *%rbx
  804160a586:	e9 3f fe ff ff       	jmpq   804160a3ca <vprintfmt+0x2a>
        err = va_arg(aq, int);
  804160a58b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a58f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a593:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a597:	eb a3                	jmp    804160a53c <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  804160a599:	48 ba 43 d6 60 41 80 	movabs $0x804160d643,%rdx
  804160a5a0:	00 00 00 
  804160a5a3:	4c 89 fe             	mov    %r15,%rsi
  804160a5a6:	4c 89 ef             	mov    %r13,%rdi
  804160a5a9:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a5ae:	48 bb 1a a3 60 41 80 	movabs $0x804160a31a,%rbx
  804160a5b5:	00 00 00 
  804160a5b8:	ff d3                	callq  *%rbx
  804160a5ba:	e9 0b fe ff ff       	jmpq   804160a3ca <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  804160a5bf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a5c2:	83 f8 2f             	cmp    $0x2f,%eax
  804160a5c5:	77 4b                	ja     804160a612 <vprintfmt+0x272>
  804160a5c7:	89 c2                	mov    %eax,%edx
  804160a5c9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a5cd:	83 c0 08             	add    $0x8,%eax
  804160a5d0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a5d3:	48 8b 02             	mov    (%rdx),%rax
  804160a5d6:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  804160a5da:	48 85 c0             	test   %rax,%rax
  804160a5dd:	0f 84 05 04 00 00    	je     804160a9e8 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  804160a5e3:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160a5e7:	7e 06                	jle    804160a5ef <vprintfmt+0x24f>
  804160a5e9:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160a5ed:	75 31                	jne    804160a620 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160a5ef:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160a5f3:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160a5f7:	0f b6 00             	movzbl (%rax),%eax
  804160a5fa:	0f be f8             	movsbl %al,%edi
  804160a5fd:	85 ff                	test   %edi,%edi
  804160a5ff:	0f 84 c3 00 00 00    	je     804160a6c8 <vprintfmt+0x328>
  804160a605:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160a609:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160a60d:	e9 85 00 00 00       	jmpq   804160a697 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  804160a612:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a616:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a61a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a61e:	eb b3                	jmp    804160a5d3 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160a620:	49 63 f4             	movslq %r12d,%rsi
  804160a623:	48 89 c7             	mov    %rax,%rdi
  804160a626:	48 b8 b1 ac 60 41 80 	movabs $0x804160acb1,%rax
  804160a62d:	00 00 00 
  804160a630:	ff d0                	callq  *%rax
  804160a632:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160a635:	8b 75 ac             	mov    -0x54(%rbp),%esi
  804160a638:	85 f6                	test   %esi,%esi
  804160a63a:	7e 22                	jle    804160a65e <vprintfmt+0x2be>
            putch(padc, putdat);
  804160a63c:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  804160a640:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  804160a644:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  804160a648:	4c 89 fe             	mov    %r15,%rsi
  804160a64b:	89 df                	mov    %ebx,%edi
  804160a64d:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  804160a650:	41 83 ec 01          	sub    $0x1,%r12d
  804160a654:	75 f2                	jne    804160a648 <vprintfmt+0x2a8>
  804160a656:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160a65a:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160a65e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160a662:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160a666:	0f b6 00             	movzbl (%rax),%eax
  804160a669:	0f be f8             	movsbl %al,%edi
  804160a66c:	85 ff                	test   %edi,%edi
  804160a66e:	0f 84 56 fd ff ff    	je     804160a3ca <vprintfmt+0x2a>
  804160a674:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160a678:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160a67c:	eb 19                	jmp    804160a697 <vprintfmt+0x2f7>
            putch(ch, putdat);
  804160a67e:	4c 89 fe             	mov    %r15,%rsi
  804160a681:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160a684:	41 83 ee 01          	sub    $0x1,%r14d
  804160a688:	48 83 c3 01          	add    $0x1,%rbx
  804160a68c:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  804160a690:	0f be f8             	movsbl %al,%edi
  804160a693:	85 ff                	test   %edi,%edi
  804160a695:	74 29                	je     804160a6c0 <vprintfmt+0x320>
  804160a697:	45 85 e4             	test   %r12d,%r12d
  804160a69a:	78 06                	js     804160a6a2 <vprintfmt+0x302>
  804160a69c:	41 83 ec 01          	sub    $0x1,%r12d
  804160a6a0:	78 48                	js     804160a6ea <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  804160a6a2:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  804160a6a6:	74 d6                	je     804160a67e <vprintfmt+0x2de>
  804160a6a8:	0f be c0             	movsbl %al,%eax
  804160a6ab:	83 e8 20             	sub    $0x20,%eax
  804160a6ae:	83 f8 5e             	cmp    $0x5e,%eax
  804160a6b1:	76 cb                	jbe    804160a67e <vprintfmt+0x2de>
            putch('?', putdat);
  804160a6b3:	4c 89 fe             	mov    %r15,%rsi
  804160a6b6:	bf 3f 00 00 00       	mov    $0x3f,%edi
  804160a6bb:	41 ff d5             	callq  *%r13
  804160a6be:	eb c4                	jmp    804160a684 <vprintfmt+0x2e4>
  804160a6c0:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160a6c4:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  804160a6c8:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  804160a6cb:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160a6cf:	0f 8e f5 fc ff ff    	jle    804160a3ca <vprintfmt+0x2a>
          putch(' ', putdat);
  804160a6d5:	4c 89 fe             	mov    %r15,%rsi
  804160a6d8:	bf 20 00 00 00       	mov    $0x20,%edi
  804160a6dd:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  804160a6e0:	83 eb 01             	sub    $0x1,%ebx
  804160a6e3:	75 f0                	jne    804160a6d5 <vprintfmt+0x335>
  804160a6e5:	e9 e0 fc ff ff       	jmpq   804160a3ca <vprintfmt+0x2a>
  804160a6ea:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160a6ee:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  804160a6f2:	eb d4                	jmp    804160a6c8 <vprintfmt+0x328>
  if (lflag >= 2)
  804160a6f4:	83 f9 01             	cmp    $0x1,%ecx
  804160a6f7:	7f 1d                	jg     804160a716 <vprintfmt+0x376>
  else if (lflag)
  804160a6f9:	85 c9                	test   %ecx,%ecx
  804160a6fb:	74 5e                	je     804160a75b <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  804160a6fd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a700:	83 f8 2f             	cmp    $0x2f,%eax
  804160a703:	77 48                	ja     804160a74d <vprintfmt+0x3ad>
  804160a705:	89 c2                	mov    %eax,%edx
  804160a707:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a70b:	83 c0 08             	add    $0x8,%eax
  804160a70e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a711:	48 8b 1a             	mov    (%rdx),%rbx
  804160a714:	eb 17                	jmp    804160a72d <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  804160a716:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a719:	83 f8 2f             	cmp    $0x2f,%eax
  804160a71c:	77 21                	ja     804160a73f <vprintfmt+0x39f>
  804160a71e:	89 c2                	mov    %eax,%edx
  804160a720:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a724:	83 c0 08             	add    $0x8,%eax
  804160a727:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a72a:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  804160a72d:	48 85 db             	test   %rbx,%rbx
  804160a730:	78 50                	js     804160a782 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  804160a732:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  804160a735:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160a73a:	e9 b4 01 00 00       	jmpq   804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  804160a73f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a743:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a747:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a74b:	eb dd                	jmp    804160a72a <vprintfmt+0x38a>
    return va_arg(*ap, long);
  804160a74d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a751:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a755:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a759:	eb b6                	jmp    804160a711 <vprintfmt+0x371>
    return va_arg(*ap, int);
  804160a75b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a75e:	83 f8 2f             	cmp    $0x2f,%eax
  804160a761:	77 11                	ja     804160a774 <vprintfmt+0x3d4>
  804160a763:	89 c2                	mov    %eax,%edx
  804160a765:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a769:	83 c0 08             	add    $0x8,%eax
  804160a76c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a76f:	48 63 1a             	movslq (%rdx),%rbx
  804160a772:	eb b9                	jmp    804160a72d <vprintfmt+0x38d>
  804160a774:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a778:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a77c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a780:	eb ed                	jmp    804160a76f <vprintfmt+0x3cf>
          putch('-', putdat);
  804160a782:	4c 89 fe             	mov    %r15,%rsi
  804160a785:	bf 2d 00 00 00       	mov    $0x2d,%edi
  804160a78a:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  804160a78d:	48 89 da             	mov    %rbx,%rdx
  804160a790:	48 f7 da             	neg    %rdx
        base = 10;
  804160a793:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160a798:	e9 56 01 00 00       	jmpq   804160a8f3 <vprintfmt+0x553>
  if (lflag >= 2)
  804160a79d:	83 f9 01             	cmp    $0x1,%ecx
  804160a7a0:	7f 25                	jg     804160a7c7 <vprintfmt+0x427>
  else if (lflag)
  804160a7a2:	85 c9                	test   %ecx,%ecx
  804160a7a4:	74 5e                	je     804160a804 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  804160a7a6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a7a9:	83 f8 2f             	cmp    $0x2f,%eax
  804160a7ac:	77 48                	ja     804160a7f6 <vprintfmt+0x456>
  804160a7ae:	89 c2                	mov    %eax,%edx
  804160a7b0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a7b4:	83 c0 08             	add    $0x8,%eax
  804160a7b7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a7ba:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160a7bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160a7c2:	e9 2c 01 00 00       	jmpq   804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160a7c7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a7ca:	83 f8 2f             	cmp    $0x2f,%eax
  804160a7cd:	77 19                	ja     804160a7e8 <vprintfmt+0x448>
  804160a7cf:	89 c2                	mov    %eax,%edx
  804160a7d1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a7d5:	83 c0 08             	add    $0x8,%eax
  804160a7d8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a7db:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160a7de:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160a7e3:	e9 0b 01 00 00       	jmpq   804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160a7e8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a7ec:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a7f0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a7f4:	eb e5                	jmp    804160a7db <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  804160a7f6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a7fa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a7fe:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a802:	eb b6                	jmp    804160a7ba <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  804160a804:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a807:	83 f8 2f             	cmp    $0x2f,%eax
  804160a80a:	77 18                	ja     804160a824 <vprintfmt+0x484>
  804160a80c:	89 c2                	mov    %eax,%edx
  804160a80e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a812:	83 c0 08             	add    $0x8,%eax
  804160a815:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a818:	8b 12                	mov    (%rdx),%edx
        base = 10;
  804160a81a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160a81f:	e9 cf 00 00 00       	jmpq   804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160a824:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a828:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a82c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a830:	eb e6                	jmp    804160a818 <vprintfmt+0x478>
  if (lflag >= 2)
  804160a832:	83 f9 01             	cmp    $0x1,%ecx
  804160a835:	7f 25                	jg     804160a85c <vprintfmt+0x4bc>
  else if (lflag)
  804160a837:	85 c9                	test   %ecx,%ecx
  804160a839:	74 5b                	je     804160a896 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  804160a83b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a83e:	83 f8 2f             	cmp    $0x2f,%eax
  804160a841:	77 45                	ja     804160a888 <vprintfmt+0x4e8>
  804160a843:	89 c2                	mov    %eax,%edx
  804160a845:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a849:	83 c0 08             	add    $0x8,%eax
  804160a84c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a84f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160a852:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160a857:	e9 97 00 00 00       	jmpq   804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160a85c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a85f:	83 f8 2f             	cmp    $0x2f,%eax
  804160a862:	77 16                	ja     804160a87a <vprintfmt+0x4da>
  804160a864:	89 c2                	mov    %eax,%edx
  804160a866:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a86a:	83 c0 08             	add    $0x8,%eax
  804160a86d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a870:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160a873:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160a878:	eb 79                	jmp    804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160a87a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a87e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a882:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a886:	eb e8                	jmp    804160a870 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  804160a888:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a88c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a890:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a894:	eb b9                	jmp    804160a84f <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  804160a896:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a899:	83 f8 2f             	cmp    $0x2f,%eax
  804160a89c:	77 15                	ja     804160a8b3 <vprintfmt+0x513>
  804160a89e:	89 c2                	mov    %eax,%edx
  804160a8a0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a8a4:	83 c0 08             	add    $0x8,%eax
  804160a8a7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a8aa:	8b 12                	mov    (%rdx),%edx
        base = 8;
  804160a8ac:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160a8b1:	eb 40                	jmp    804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160a8b3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a8b7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a8bb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a8bf:	eb e9                	jmp    804160a8aa <vprintfmt+0x50a>
        putch('0', putdat);
  804160a8c1:	4c 89 fe             	mov    %r15,%rsi
  804160a8c4:	bf 30 00 00 00       	mov    $0x30,%edi
  804160a8c9:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  804160a8cc:	4c 89 fe             	mov    %r15,%rsi
  804160a8cf:	bf 78 00 00 00       	mov    $0x78,%edi
  804160a8d4:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160a8d7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a8da:	83 f8 2f             	cmp    $0x2f,%eax
  804160a8dd:	77 34                	ja     804160a913 <vprintfmt+0x573>
  804160a8df:	89 c2                	mov    %eax,%edx
  804160a8e1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a8e5:	83 c0 08             	add    $0x8,%eax
  804160a8e8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a8eb:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160a8ee:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  804160a8f3:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  804160a8f8:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  804160a8fc:	4c 89 fe             	mov    %r15,%rsi
  804160a8ff:	4c 89 ef             	mov    %r13,%rdi
  804160a902:	48 b8 76 a2 60 41 80 	movabs $0x804160a276,%rax
  804160a909:	00 00 00 
  804160a90c:	ff d0                	callq  *%rax
        break;
  804160a90e:	e9 b7 fa ff ff       	jmpq   804160a3ca <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160a913:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a917:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a91b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a91f:	eb ca                	jmp    804160a8eb <vprintfmt+0x54b>
  if (lflag >= 2)
  804160a921:	83 f9 01             	cmp    $0x1,%ecx
  804160a924:	7f 22                	jg     804160a948 <vprintfmt+0x5a8>
  else if (lflag)
  804160a926:	85 c9                	test   %ecx,%ecx
  804160a928:	74 58                	je     804160a982 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  804160a92a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a92d:	83 f8 2f             	cmp    $0x2f,%eax
  804160a930:	77 42                	ja     804160a974 <vprintfmt+0x5d4>
  804160a932:	89 c2                	mov    %eax,%edx
  804160a934:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a938:	83 c0 08             	add    $0x8,%eax
  804160a93b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a93e:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160a941:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160a946:	eb ab                	jmp    804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160a948:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a94b:	83 f8 2f             	cmp    $0x2f,%eax
  804160a94e:	77 16                	ja     804160a966 <vprintfmt+0x5c6>
  804160a950:	89 c2                	mov    %eax,%edx
  804160a952:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a956:	83 c0 08             	add    $0x8,%eax
  804160a959:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a95c:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160a95f:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160a964:	eb 8d                	jmp    804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160a966:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a96a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a96e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a972:	eb e8                	jmp    804160a95c <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  804160a974:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a978:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a97c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a980:	eb bc                	jmp    804160a93e <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  804160a982:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160a985:	83 f8 2f             	cmp    $0x2f,%eax
  804160a988:	77 18                	ja     804160a9a2 <vprintfmt+0x602>
  804160a98a:	89 c2                	mov    %eax,%edx
  804160a98c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160a990:	83 c0 08             	add    $0x8,%eax
  804160a993:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160a996:	8b 12                	mov    (%rdx),%edx
        base = 16;
  804160a998:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160a99d:	e9 51 ff ff ff       	jmpq   804160a8f3 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160a9a2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160a9a6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160a9aa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160a9ae:	eb e6                	jmp    804160a996 <vprintfmt+0x5f6>
        putch(ch, putdat);
  804160a9b0:	4c 89 fe             	mov    %r15,%rsi
  804160a9b3:	bf 25 00 00 00       	mov    $0x25,%edi
  804160a9b8:	41 ff d5             	callq  *%r13
        break;
  804160a9bb:	e9 0a fa ff ff       	jmpq   804160a3ca <vprintfmt+0x2a>
        putch('%', putdat);
  804160a9c0:	4c 89 fe             	mov    %r15,%rsi
  804160a9c3:	bf 25 00 00 00       	mov    $0x25,%edi
  804160a9c8:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160a9cb:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  804160a9cf:	0f 84 15 fa ff ff    	je     804160a3ea <vprintfmt+0x4a>
  804160a9d5:	49 89 de             	mov    %rbx,%r14
  804160a9d8:	49 83 ee 01          	sub    $0x1,%r14
  804160a9dc:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  804160a9e1:	75 f5                	jne    804160a9d8 <vprintfmt+0x638>
  804160a9e3:	e9 e2 f9 ff ff       	jmpq   804160a3ca <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  804160a9e8:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160a9ec:	74 06                	je     804160a9f4 <vprintfmt+0x654>
  804160a9ee:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160a9f2:	7f 21                	jg     804160aa15 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160a9f4:	bf 28 00 00 00       	mov    $0x28,%edi
  804160a9f9:	48 bb 3d d6 60 41 80 	movabs $0x804160d63d,%rbx
  804160aa00:	00 00 00 
  804160aa03:	b8 28 00 00 00       	mov    $0x28,%eax
  804160aa08:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160aa0c:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160aa10:	e9 82 fc ff ff       	jmpq   804160a697 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160aa15:	49 63 f4             	movslq %r12d,%rsi
  804160aa18:	48 bf 3c d6 60 41 80 	movabs $0x804160d63c,%rdi
  804160aa1f:	00 00 00 
  804160aa22:	48 b8 b1 ac 60 41 80 	movabs $0x804160acb1,%rax
  804160aa29:	00 00 00 
  804160aa2c:	ff d0                	callq  *%rax
  804160aa2e:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160aa31:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  804160aa34:	48 be 3c d6 60 41 80 	movabs $0x804160d63c,%rsi
  804160aa3b:	00 00 00 
  804160aa3e:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  804160aa42:	85 c0                	test   %eax,%eax
  804160aa44:	0f 8f f2 fb ff ff    	jg     804160a63c <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160aa4a:	48 bb 3d d6 60 41 80 	movabs $0x804160d63d,%rbx
  804160aa51:	00 00 00 
  804160aa54:	b8 28 00 00 00       	mov    $0x28,%eax
  804160aa59:	bf 28 00 00 00       	mov    $0x28,%edi
  804160aa5e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160aa62:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160aa66:	e9 2c fc ff ff       	jmpq   804160a697 <vprintfmt+0x2f7>
}
  804160aa6b:	48 83 c4 48          	add    $0x48,%rsp
  804160aa6f:	5b                   	pop    %rbx
  804160aa70:	41 5c                	pop    %r12
  804160aa72:	41 5d                	pop    %r13
  804160aa74:	41 5e                	pop    %r14
  804160aa76:	41 5f                	pop    %r15
  804160aa78:	5d                   	pop    %rbp
  804160aa79:	c3                   	retq   

000000804160aa7a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  804160aa7a:	55                   	push   %rbp
  804160aa7b:	48 89 e5             	mov    %rsp,%rbp
  804160aa7e:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  804160aa82:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  804160aa86:	48 63 c6             	movslq %esi,%rax
  804160aa89:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  804160aa8e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  804160aa92:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  804160aa99:	48 85 ff             	test   %rdi,%rdi
  804160aa9c:	74 2a                	je     804160aac8 <vsnprintf+0x4e>
  804160aa9e:	85 f6                	test   %esi,%esi
  804160aaa0:	7e 26                	jle    804160aac8 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  804160aaa2:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  804160aaa6:	48 bf 02 a3 60 41 80 	movabs $0x804160a302,%rdi
  804160aaad:	00 00 00 
  804160aab0:	48 b8 a0 a3 60 41 80 	movabs $0x804160a3a0,%rax
  804160aab7:	00 00 00 
  804160aaba:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  804160aabc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160aac0:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  804160aac3:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  804160aac6:	c9                   	leaveq 
  804160aac7:	c3                   	retq   
    return -E_INVAL;
  804160aac8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160aacd:	eb f7                	jmp    804160aac6 <vsnprintf+0x4c>

000000804160aacf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  804160aacf:	55                   	push   %rbp
  804160aad0:	48 89 e5             	mov    %rsp,%rbp
  804160aad3:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160aada:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160aae1:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160aae8:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160aaef:	84 c0                	test   %al,%al
  804160aaf1:	74 20                	je     804160ab13 <snprintf+0x44>
  804160aaf3:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160aaf7:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160aafb:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160aaff:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160ab03:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160ab07:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160ab0b:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160ab0f:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  804160ab13:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160ab1a:	00 00 00 
  804160ab1d:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160ab24:	00 00 00 
  804160ab27:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160ab2b:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160ab32:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160ab39:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  804160ab40:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160ab47:	48 b8 7a aa 60 41 80 	movabs $0x804160aa7a,%rax
  804160ab4e:	00 00 00 
  804160ab51:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  804160ab53:	c9                   	leaveq 
  804160ab54:	c3                   	retq   

000000804160ab55 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  804160ab55:	55                   	push   %rbp
  804160ab56:	48 89 e5             	mov    %rsp,%rbp
  804160ab59:	41 57                	push   %r15
  804160ab5b:	41 56                	push   %r14
  804160ab5d:	41 55                	push   %r13
  804160ab5f:	41 54                	push   %r12
  804160ab61:	53                   	push   %rbx
  804160ab62:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  804160ab66:	48 85 ff             	test   %rdi,%rdi
  804160ab69:	74 1e                	je     804160ab89 <readline+0x34>
    cprintf("%s", prompt);
  804160ab6b:	48 89 fe             	mov    %rdi,%rsi
  804160ab6e:	48 bf 8b b9 60 41 80 	movabs $0x804160b98b,%rdi
  804160ab75:	00 00 00 
  804160ab78:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab7d:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160ab84:	00 00 00 
  804160ab87:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  804160ab89:	bf 00 00 00 00       	mov    $0x0,%edi
  804160ab8e:	48 b8 25 0d 60 41 80 	movabs $0x8041600d25,%rax
  804160ab95:	00 00 00 
  804160ab98:	ff d0                	callq  *%rax
  804160ab9a:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  804160ab9d:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  804160aba3:	49 bd 05 0d 60 41 80 	movabs $0x8041600d05,%r13
  804160abaa:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  804160abad:	49 bf f3 0c 60 41 80 	movabs $0x8041600cf3,%r15
  804160abb4:	00 00 00 
  804160abb7:	eb 3f                	jmp    804160abf8 <readline+0xa3>
      cprintf("read error: %i\n", c);
  804160abb9:	89 c6                	mov    %eax,%esi
  804160abbb:	48 bf e8 d9 60 41 80 	movabs $0x804160d9e8,%rdi
  804160abc2:	00 00 00 
  804160abc5:	b8 00 00 00 00       	mov    $0x0,%eax
  804160abca:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160abd1:	00 00 00 
  804160abd4:	ff d2                	callq  *%rdx
      return NULL;
  804160abd6:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  804160abdb:	48 83 c4 08          	add    $0x8,%rsp
  804160abdf:	5b                   	pop    %rbx
  804160abe0:	41 5c                	pop    %r12
  804160abe2:	41 5d                	pop    %r13
  804160abe4:	41 5e                	pop    %r14
  804160abe6:	41 5f                	pop    %r15
  804160abe8:	5d                   	pop    %rbp
  804160abe9:	c3                   	retq   
      if (i > 0) {
  804160abea:	45 85 e4             	test   %r12d,%r12d
  804160abed:	7e 09                	jle    804160abf8 <readline+0xa3>
        if (echoing) {
  804160abef:	45 85 f6             	test   %r14d,%r14d
  804160abf2:	75 41                	jne    804160ac35 <readline+0xe0>
        i--;
  804160abf4:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  804160abf8:	41 ff d5             	callq  *%r13
  804160abfb:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  804160abfd:	85 c0                	test   %eax,%eax
  804160abff:	78 b8                	js     804160abb9 <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  804160ac01:	83 f8 08             	cmp    $0x8,%eax
  804160ac04:	74 e4                	je     804160abea <readline+0x95>
  804160ac06:	83 f8 7f             	cmp    $0x7f,%eax
  804160ac09:	74 df                	je     804160abea <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  804160ac0b:	83 f8 1f             	cmp    $0x1f,%eax
  804160ac0e:	7e 46                	jle    804160ac56 <readline+0x101>
  804160ac10:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  804160ac17:	7f 3d                	jg     804160ac56 <readline+0x101>
      if (echoing)
  804160ac19:	45 85 f6             	test   %r14d,%r14d
  804160ac1c:	75 31                	jne    804160ac4f <readline+0xfa>
      buf[i++] = c;
  804160ac1e:	49 63 c4             	movslq %r12d,%rax
  804160ac21:	48 b9 40 fc 61 41 80 	movabs $0x804161fc40,%rcx
  804160ac28:	00 00 00 
  804160ac2b:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  804160ac2e:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  804160ac33:	eb c3                	jmp    804160abf8 <readline+0xa3>
          cputchar('\b');
  804160ac35:	bf 08 00 00 00       	mov    $0x8,%edi
  804160ac3a:	41 ff d7             	callq  *%r15
          cputchar(' ');
  804160ac3d:	bf 20 00 00 00       	mov    $0x20,%edi
  804160ac42:	41 ff d7             	callq  *%r15
          cputchar('\b');
  804160ac45:	bf 08 00 00 00       	mov    $0x8,%edi
  804160ac4a:	41 ff d7             	callq  *%r15
  804160ac4d:	eb a5                	jmp    804160abf4 <readline+0x9f>
        cputchar(c);
  804160ac4f:	89 c7                	mov    %eax,%edi
  804160ac51:	41 ff d7             	callq  *%r15
  804160ac54:	eb c8                	jmp    804160ac1e <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  804160ac56:	83 fb 0a             	cmp    $0xa,%ebx
  804160ac59:	74 05                	je     804160ac60 <readline+0x10b>
  804160ac5b:	83 fb 0d             	cmp    $0xd,%ebx
  804160ac5e:	75 98                	jne    804160abf8 <readline+0xa3>
      if (echoing)
  804160ac60:	45 85 f6             	test   %r14d,%r14d
  804160ac63:	75 17                	jne    804160ac7c <readline+0x127>
      buf[i] = 0;
  804160ac65:	48 b8 40 fc 61 41 80 	movabs $0x804161fc40,%rax
  804160ac6c:	00 00 00 
  804160ac6f:	4d 63 e4             	movslq %r12d,%r12
  804160ac72:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  804160ac77:	e9 5f ff ff ff       	jmpq   804160abdb <readline+0x86>
        cputchar('\n');
  804160ac7c:	bf 0a 00 00 00       	mov    $0xa,%edi
  804160ac81:	48 b8 f3 0c 60 41 80 	movabs $0x8041600cf3,%rax
  804160ac88:	00 00 00 
  804160ac8b:	ff d0                	callq  *%rax
  804160ac8d:	eb d6                	jmp    804160ac65 <readline+0x110>

000000804160ac8f <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  804160ac8f:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160ac92:	74 17                	je     804160acab <strlen+0x1c>
  804160ac94:	48 89 fa             	mov    %rdi,%rdx
  804160ac97:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160ac9c:	29 f9                	sub    %edi,%ecx
    n++;
  804160ac9e:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  804160aca1:	48 83 c2 01          	add    $0x1,%rdx
  804160aca5:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160aca8:	75 f4                	jne    804160ac9e <strlen+0xf>
  804160acaa:	c3                   	retq   
  804160acab:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160acb0:	c3                   	retq   

000000804160acb1 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160acb1:	48 85 f6             	test   %rsi,%rsi
  804160acb4:	74 24                	je     804160acda <strnlen+0x29>
  804160acb6:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160acb9:	74 25                	je     804160ace0 <strnlen+0x2f>
  804160acbb:	48 01 fe             	add    %rdi,%rsi
  804160acbe:	48 89 fa             	mov    %rdi,%rdx
  804160acc1:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160acc6:	29 f9                	sub    %edi,%ecx
    n++;
  804160acc8:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160accb:	48 83 c2 01          	add    $0x1,%rdx
  804160accf:	48 39 f2             	cmp    %rsi,%rdx
  804160acd2:	74 11                	je     804160ace5 <strnlen+0x34>
  804160acd4:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160acd7:	75 ef                	jne    804160acc8 <strnlen+0x17>
  804160acd9:	c3                   	retq   
  804160acda:	b8 00 00 00 00       	mov    $0x0,%eax
  804160acdf:	c3                   	retq   
  804160ace0:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160ace5:	c3                   	retq   

000000804160ace6 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  804160ace6:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  804160ace9:	ba 00 00 00 00       	mov    $0x0,%edx
  804160acee:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  804160acf2:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  804160acf5:	48 83 c2 01          	add    $0x1,%rdx
  804160acf9:	84 c9                	test   %cl,%cl
  804160acfb:	75 f1                	jne    804160acee <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  804160acfd:	c3                   	retq   

000000804160acfe <strcat>:

char *
strcat(char *dst, const char *src) {
  804160acfe:	55                   	push   %rbp
  804160acff:	48 89 e5             	mov    %rsp,%rbp
  804160ad02:	41 54                	push   %r12
  804160ad04:	53                   	push   %rbx
  804160ad05:	48 89 fb             	mov    %rdi,%rbx
  804160ad08:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  804160ad0b:	48 b8 8f ac 60 41 80 	movabs $0x804160ac8f,%rax
  804160ad12:	00 00 00 
  804160ad15:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  804160ad17:	48 63 f8             	movslq %eax,%rdi
  804160ad1a:	48 01 df             	add    %rbx,%rdi
  804160ad1d:	4c 89 e6             	mov    %r12,%rsi
  804160ad20:	48 b8 e6 ac 60 41 80 	movabs $0x804160ace6,%rax
  804160ad27:	00 00 00 
  804160ad2a:	ff d0                	callq  *%rax
  return dst;
}
  804160ad2c:	48 89 d8             	mov    %rbx,%rax
  804160ad2f:	5b                   	pop    %rbx
  804160ad30:	41 5c                	pop    %r12
  804160ad32:	5d                   	pop    %rbp
  804160ad33:	c3                   	retq   

000000804160ad34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  804160ad34:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  804160ad37:	48 85 d2             	test   %rdx,%rdx
  804160ad3a:	74 1f                	je     804160ad5b <strncpy+0x27>
  804160ad3c:	48 01 fa             	add    %rdi,%rdx
  804160ad3f:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  804160ad42:	48 83 c1 01          	add    $0x1,%rcx
  804160ad46:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160ad4a:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  804160ad4e:	41 80 f8 01          	cmp    $0x1,%r8b
  804160ad52:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  804160ad56:	48 39 ca             	cmp    %rcx,%rdx
  804160ad59:	75 e7                	jne    804160ad42 <strncpy+0xe>
  }
  return ret;
}
  804160ad5b:	c3                   	retq   

000000804160ad5c <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  804160ad5c:	48 89 f8             	mov    %rdi,%rax
  804160ad5f:	48 85 d2             	test   %rdx,%rdx
  804160ad62:	74 36                	je     804160ad9a <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  804160ad64:	48 83 fa 01          	cmp    $0x1,%rdx
  804160ad68:	74 2d                	je     804160ad97 <strlcpy+0x3b>
  804160ad6a:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160ad6e:	45 84 c0             	test   %r8b,%r8b
  804160ad71:	74 24                	je     804160ad97 <strlcpy+0x3b>
  804160ad73:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  804160ad77:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  804160ad7c:	48 83 c0 01          	add    $0x1,%rax
  804160ad80:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  804160ad84:	48 39 d1             	cmp    %rdx,%rcx
  804160ad87:	74 0e                	je     804160ad97 <strlcpy+0x3b>
  804160ad89:	48 83 c1 01          	add    $0x1,%rcx
  804160ad8d:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  804160ad92:	45 84 c0             	test   %r8b,%r8b
  804160ad95:	75 e5                	jne    804160ad7c <strlcpy+0x20>
    *dst = '\0';
  804160ad97:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  804160ad9a:	48 29 f8             	sub    %rdi,%rax
}
  804160ad9d:	c3                   	retq   

000000804160ad9e <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  804160ad9e:	0f b6 07             	movzbl (%rdi),%eax
  804160ada1:	84 c0                	test   %al,%al
  804160ada3:	74 17                	je     804160adbc <strcmp+0x1e>
  804160ada5:	3a 06                	cmp    (%rsi),%al
  804160ada7:	75 13                	jne    804160adbc <strcmp+0x1e>
    p++, q++;
  804160ada9:	48 83 c7 01          	add    $0x1,%rdi
  804160adad:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  804160adb1:	0f b6 07             	movzbl (%rdi),%eax
  804160adb4:	84 c0                	test   %al,%al
  804160adb6:	74 04                	je     804160adbc <strcmp+0x1e>
  804160adb8:	3a 06                	cmp    (%rsi),%al
  804160adba:	74 ed                	je     804160ada9 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  804160adbc:	0f b6 c0             	movzbl %al,%eax
  804160adbf:	0f b6 16             	movzbl (%rsi),%edx
  804160adc2:	29 d0                	sub    %edx,%eax
}
  804160adc4:	c3                   	retq   

000000804160adc5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  804160adc5:	48 85 d2             	test   %rdx,%rdx
  804160adc8:	74 2f                	je     804160adf9 <strncmp+0x34>
  804160adca:	0f b6 07             	movzbl (%rdi),%eax
  804160adcd:	84 c0                	test   %al,%al
  804160adcf:	74 1f                	je     804160adf0 <strncmp+0x2b>
  804160add1:	3a 06                	cmp    (%rsi),%al
  804160add3:	75 1b                	jne    804160adf0 <strncmp+0x2b>
  804160add5:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  804160add8:	48 83 c7 01          	add    $0x1,%rdi
  804160addc:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  804160ade0:	48 39 d7             	cmp    %rdx,%rdi
  804160ade3:	74 1a                	je     804160adff <strncmp+0x3a>
  804160ade5:	0f b6 07             	movzbl (%rdi),%eax
  804160ade8:	84 c0                	test   %al,%al
  804160adea:	74 04                	je     804160adf0 <strncmp+0x2b>
  804160adec:	3a 06                	cmp    (%rsi),%al
  804160adee:	74 e8                	je     804160add8 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  804160adf0:	0f b6 07             	movzbl (%rdi),%eax
  804160adf3:	0f b6 16             	movzbl (%rsi),%edx
  804160adf6:	29 d0                	sub    %edx,%eax
}
  804160adf8:	c3                   	retq   
    return 0;
  804160adf9:	b8 00 00 00 00       	mov    $0x0,%eax
  804160adfe:	c3                   	retq   
  804160adff:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ae04:	c3                   	retq   

000000804160ae05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  804160ae05:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  804160ae07:	0f b6 07             	movzbl (%rdi),%eax
  804160ae0a:	84 c0                	test   %al,%al
  804160ae0c:	74 1e                	je     804160ae2c <strchr+0x27>
    if (*s == c)
  804160ae0e:	40 38 c6             	cmp    %al,%sil
  804160ae11:	74 1f                	je     804160ae32 <strchr+0x2d>
  for (; *s; s++)
  804160ae13:	48 83 c7 01          	add    $0x1,%rdi
  804160ae17:	0f b6 07             	movzbl (%rdi),%eax
  804160ae1a:	84 c0                	test   %al,%al
  804160ae1c:	74 08                	je     804160ae26 <strchr+0x21>
    if (*s == c)
  804160ae1e:	38 d0                	cmp    %dl,%al
  804160ae20:	75 f1                	jne    804160ae13 <strchr+0xe>
  for (; *s; s++)
  804160ae22:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  804160ae25:	c3                   	retq   
  return 0;
  804160ae26:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ae2b:	c3                   	retq   
  804160ae2c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ae31:	c3                   	retq   
    if (*s == c)
  804160ae32:	48 89 f8             	mov    %rdi,%rax
  804160ae35:	c3                   	retq   

000000804160ae36 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  804160ae36:	48 89 f8             	mov    %rdi,%rax
  804160ae39:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  804160ae3b:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  804160ae3e:	40 38 f2             	cmp    %sil,%dl
  804160ae41:	74 13                	je     804160ae56 <strfind+0x20>
  804160ae43:	84 d2                	test   %dl,%dl
  804160ae45:	74 0f                	je     804160ae56 <strfind+0x20>
  for (; *s; s++)
  804160ae47:	48 83 c0 01          	add    $0x1,%rax
  804160ae4b:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  804160ae4e:	38 ca                	cmp    %cl,%dl
  804160ae50:	74 04                	je     804160ae56 <strfind+0x20>
  804160ae52:	84 d2                	test   %dl,%dl
  804160ae54:	75 f1                	jne    804160ae47 <strfind+0x11>
      break;
  return (char *)s;
}
  804160ae56:	c3                   	retq   

000000804160ae57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  804160ae57:	48 85 d2             	test   %rdx,%rdx
  804160ae5a:	74 3a                	je     804160ae96 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160ae5c:	48 89 f8             	mov    %rdi,%rax
  804160ae5f:	48 09 d0             	or     %rdx,%rax
  804160ae62:	a8 03                	test   $0x3,%al
  804160ae64:	75 28                	jne    804160ae8e <memset+0x37>
    uint32_t k = c & 0xFFU;
  804160ae66:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  804160ae6a:	89 f0                	mov    %esi,%eax
  804160ae6c:	c1 e0 08             	shl    $0x8,%eax
  804160ae6f:	89 f1                	mov    %esi,%ecx
  804160ae71:	c1 e1 18             	shl    $0x18,%ecx
  804160ae74:	41 89 f0             	mov    %esi,%r8d
  804160ae77:	41 c1 e0 10          	shl    $0x10,%r8d
  804160ae7b:	44 09 c1             	or     %r8d,%ecx
  804160ae7e:	09 ce                	or     %ecx,%esi
  804160ae80:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  804160ae82:	48 c1 ea 02          	shr    $0x2,%rdx
  804160ae86:	48 89 d1             	mov    %rdx,%rcx
  804160ae89:	fc                   	cld    
  804160ae8a:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160ae8c:	eb 08                	jmp    804160ae96 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  804160ae8e:	89 f0                	mov    %esi,%eax
  804160ae90:	48 89 d1             	mov    %rdx,%rcx
  804160ae93:	fc                   	cld    
  804160ae94:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  804160ae96:	48 89 f8             	mov    %rdi,%rax
  804160ae99:	c3                   	retq   

000000804160ae9a <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  804160ae9a:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  804160ae9d:	48 39 fe             	cmp    %rdi,%rsi
  804160aea0:	73 40                	jae    804160aee2 <memmove+0x48>
  804160aea2:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  804160aea6:	48 39 f9             	cmp    %rdi,%rcx
  804160aea9:	76 37                	jbe    804160aee2 <memmove+0x48>
    s += n;
    d += n;
  804160aeab:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160aeaf:	48 89 fe             	mov    %rdi,%rsi
  804160aeb2:	48 09 d6             	or     %rdx,%rsi
  804160aeb5:	48 09 ce             	or     %rcx,%rsi
  804160aeb8:	40 f6 c6 03          	test   $0x3,%sil
  804160aebc:	75 14                	jne    804160aed2 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  804160aebe:	48 83 ef 04          	sub    $0x4,%rdi
  804160aec2:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  804160aec6:	48 c1 ea 02          	shr    $0x2,%rdx
  804160aeca:	48 89 d1             	mov    %rdx,%rcx
  804160aecd:	fd                   	std    
  804160aece:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160aed0:	eb 0e                	jmp    804160aee0 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  804160aed2:	48 83 ef 01          	sub    $0x1,%rdi
  804160aed6:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  804160aeda:	48 89 d1             	mov    %rdx,%rcx
  804160aedd:	fd                   	std    
  804160aede:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  804160aee0:	fc                   	cld    
  804160aee1:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160aee2:	48 89 c1             	mov    %rax,%rcx
  804160aee5:	48 09 d1             	or     %rdx,%rcx
  804160aee8:	48 09 f1             	or     %rsi,%rcx
  804160aeeb:	f6 c1 03             	test   $0x3,%cl
  804160aeee:	75 0e                	jne    804160aefe <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  804160aef0:	48 c1 ea 02          	shr    $0x2,%rdx
  804160aef4:	48 89 d1             	mov    %rdx,%rcx
  804160aef7:	48 89 c7             	mov    %rax,%rdi
  804160aefa:	fc                   	cld    
  804160aefb:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160aefd:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  804160aefe:	48 89 c7             	mov    %rax,%rdi
  804160af01:	48 89 d1             	mov    %rdx,%rcx
  804160af04:	fc                   	cld    
  804160af05:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  804160af07:	c3                   	retq   

000000804160af08 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  804160af08:	55                   	push   %rbp
  804160af09:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  804160af0c:	48 b8 9a ae 60 41 80 	movabs $0x804160ae9a,%rax
  804160af13:	00 00 00 
  804160af16:	ff d0                	callq  *%rax
}
  804160af18:	5d                   	pop    %rbp
  804160af19:	c3                   	retq   

000000804160af1a <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  804160af1a:	55                   	push   %rbp
  804160af1b:	48 89 e5             	mov    %rsp,%rbp
  804160af1e:	41 57                	push   %r15
  804160af20:	41 56                	push   %r14
  804160af22:	41 55                	push   %r13
  804160af24:	41 54                	push   %r12
  804160af26:	53                   	push   %rbx
  804160af27:	48 83 ec 08          	sub    $0x8,%rsp
  804160af2b:	49 89 fe             	mov    %rdi,%r14
  804160af2e:	49 89 f7             	mov    %rsi,%r15
  804160af31:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  804160af34:	48 89 f7             	mov    %rsi,%rdi
  804160af37:	48 b8 8f ac 60 41 80 	movabs $0x804160ac8f,%rax
  804160af3e:	00 00 00 
  804160af41:	ff d0                	callq  *%rax
  804160af43:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  804160af46:	4c 89 ee             	mov    %r13,%rsi
  804160af49:	4c 89 f7             	mov    %r14,%rdi
  804160af4c:	48 b8 b1 ac 60 41 80 	movabs $0x804160acb1,%rax
  804160af53:	00 00 00 
  804160af56:	ff d0                	callq  *%rax
  804160af58:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  804160af5b:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  804160af5f:	4d 39 e5             	cmp    %r12,%r13
  804160af62:	74 26                	je     804160af8a <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  804160af64:	4c 89 e8             	mov    %r13,%rax
  804160af67:	4c 29 e0             	sub    %r12,%rax
  804160af6a:	48 39 d8             	cmp    %rbx,%rax
  804160af6d:	76 2a                	jbe    804160af99 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  804160af6f:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  804160af73:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160af77:	4c 89 fe             	mov    %r15,%rsi
  804160af7a:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160af81:	00 00 00 
  804160af84:	ff d0                	callq  *%rax
  return dstlen + srclen;
  804160af86:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  804160af8a:	48 83 c4 08          	add    $0x8,%rsp
  804160af8e:	5b                   	pop    %rbx
  804160af8f:	41 5c                	pop    %r12
  804160af91:	41 5d                	pop    %r13
  804160af93:	41 5e                	pop    %r14
  804160af95:	41 5f                	pop    %r15
  804160af97:	5d                   	pop    %rbp
  804160af98:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  804160af99:	49 83 ed 01          	sub    $0x1,%r13
  804160af9d:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160afa1:	4c 89 ea             	mov    %r13,%rdx
  804160afa4:	4c 89 fe             	mov    %r15,%rsi
  804160afa7:	48 b8 08 af 60 41 80 	movabs $0x804160af08,%rax
  804160afae:	00 00 00 
  804160afb1:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  804160afb3:	4d 01 ee             	add    %r13,%r14
  804160afb6:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  804160afbb:	eb c9                	jmp    804160af86 <strlcat+0x6c>

000000804160afbd <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  804160afbd:	48 85 d2             	test   %rdx,%rdx
  804160afc0:	74 3a                	je     804160affc <memcmp+0x3f>
    if (*s1 != *s2)
  804160afc2:	0f b6 0f             	movzbl (%rdi),%ecx
  804160afc5:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160afc9:	44 38 c1             	cmp    %r8b,%cl
  804160afcc:	75 1d                	jne    804160afeb <memcmp+0x2e>
  804160afce:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  804160afd3:	48 39 d0             	cmp    %rdx,%rax
  804160afd6:	74 1e                	je     804160aff6 <memcmp+0x39>
    if (*s1 != *s2)
  804160afd8:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  804160afdc:	48 83 c0 01          	add    $0x1,%rax
  804160afe0:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  804160afe6:	44 38 c1             	cmp    %r8b,%cl
  804160afe9:	74 e8                	je     804160afd3 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  804160afeb:	0f b6 c1             	movzbl %cl,%eax
  804160afee:	45 0f b6 c0          	movzbl %r8b,%r8d
  804160aff2:	44 29 c0             	sub    %r8d,%eax
  804160aff5:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  804160aff6:	b8 00 00 00 00       	mov    $0x0,%eax
  804160affb:	c3                   	retq   
  804160affc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160b001:	c3                   	retq   

000000804160b002 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  804160b002:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  804160b006:	48 39 c7             	cmp    %rax,%rdi
  804160b009:	73 19                	jae    804160b024 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160b00b:	89 f2                	mov    %esi,%edx
  804160b00d:	40 38 37             	cmp    %sil,(%rdi)
  804160b010:	74 16                	je     804160b028 <memfind+0x26>
  for (; s < ends; s++)
  804160b012:	48 83 c7 01          	add    $0x1,%rdi
  804160b016:	48 39 f8             	cmp    %rdi,%rax
  804160b019:	74 08                	je     804160b023 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160b01b:	38 17                	cmp    %dl,(%rdi)
  804160b01d:	75 f3                	jne    804160b012 <memfind+0x10>
  for (; s < ends; s++)
  804160b01f:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  804160b022:	c3                   	retq   
  804160b023:	c3                   	retq   
  for (; s < ends; s++)
  804160b024:	48 89 f8             	mov    %rdi,%rax
  804160b027:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  804160b028:	48 89 f8             	mov    %rdi,%rax
  804160b02b:	c3                   	retq   

000000804160b02c <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  804160b02c:	0f b6 07             	movzbl (%rdi),%eax
  804160b02f:	3c 20                	cmp    $0x20,%al
  804160b031:	74 04                	je     804160b037 <strtol+0xb>
  804160b033:	3c 09                	cmp    $0x9,%al
  804160b035:	75 0f                	jne    804160b046 <strtol+0x1a>
    s++;
  804160b037:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  804160b03b:	0f b6 07             	movzbl (%rdi),%eax
  804160b03e:	3c 20                	cmp    $0x20,%al
  804160b040:	74 f5                	je     804160b037 <strtol+0xb>
  804160b042:	3c 09                	cmp    $0x9,%al
  804160b044:	74 f1                	je     804160b037 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  804160b046:	3c 2b                	cmp    $0x2b,%al
  804160b048:	74 2b                	je     804160b075 <strtol+0x49>
  int neg  = 0;
  804160b04a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  804160b050:	3c 2d                	cmp    $0x2d,%al
  804160b052:	74 2d                	je     804160b081 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160b054:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  804160b05a:	75 0f                	jne    804160b06b <strtol+0x3f>
  804160b05c:	80 3f 30             	cmpb   $0x30,(%rdi)
  804160b05f:	74 2c                	je     804160b08d <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  804160b061:	85 d2                	test   %edx,%edx
  804160b063:	b8 0a 00 00 00       	mov    $0xa,%eax
  804160b068:	0f 44 d0             	cmove  %eax,%edx
  804160b06b:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  804160b070:	4c 63 d2             	movslq %edx,%r10
  804160b073:	eb 5c                	jmp    804160b0d1 <strtol+0xa5>
    s++;
  804160b075:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  804160b079:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160b07f:	eb d3                	jmp    804160b054 <strtol+0x28>
    s++, neg = 1;
  804160b081:	48 83 c7 01          	add    $0x1,%rdi
  804160b085:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160b08b:	eb c7                	jmp    804160b054 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160b08d:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  804160b091:	74 0f                	je     804160b0a2 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  804160b093:	85 d2                	test   %edx,%edx
  804160b095:	75 d4                	jne    804160b06b <strtol+0x3f>
    s++, base = 8;
  804160b097:	48 83 c7 01          	add    $0x1,%rdi
  804160b09b:	ba 08 00 00 00       	mov    $0x8,%edx
  804160b0a0:	eb c9                	jmp    804160b06b <strtol+0x3f>
    s += 2, base = 16;
  804160b0a2:	48 83 c7 02          	add    $0x2,%rdi
  804160b0a6:	ba 10 00 00 00       	mov    $0x10,%edx
  804160b0ab:	eb be                	jmp    804160b06b <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  804160b0ad:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  804160b0b1:	41 80 f8 19          	cmp    $0x19,%r8b
  804160b0b5:	77 2f                	ja     804160b0e6 <strtol+0xba>
      dig = *s - 'a' + 10;
  804160b0b7:	44 0f be c1          	movsbl %cl,%r8d
  804160b0bb:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  804160b0bf:	39 d1                	cmp    %edx,%ecx
  804160b0c1:	7d 37                	jge    804160b0fa <strtol+0xce>
    s++, val = (val * base) + dig;
  804160b0c3:	48 83 c7 01          	add    $0x1,%rdi
  804160b0c7:	49 0f af c2          	imul   %r10,%rax
  804160b0cb:	48 63 c9             	movslq %ecx,%rcx
  804160b0ce:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  804160b0d1:	0f b6 0f             	movzbl (%rdi),%ecx
  804160b0d4:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  804160b0d8:	41 80 f8 09          	cmp    $0x9,%r8b
  804160b0dc:	77 cf                	ja     804160b0ad <strtol+0x81>
      dig = *s - '0';
  804160b0de:	0f be c9             	movsbl %cl,%ecx
  804160b0e1:	83 e9 30             	sub    $0x30,%ecx
  804160b0e4:	eb d9                	jmp    804160b0bf <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  804160b0e6:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  804160b0ea:	41 80 f8 19          	cmp    $0x19,%r8b
  804160b0ee:	77 0a                	ja     804160b0fa <strtol+0xce>
      dig = *s - 'A' + 10;
  804160b0f0:	44 0f be c1          	movsbl %cl,%r8d
  804160b0f4:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  804160b0f8:	eb c5                	jmp    804160b0bf <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  804160b0fa:	48 85 f6             	test   %rsi,%rsi
  804160b0fd:	74 03                	je     804160b102 <strtol+0xd6>
    *endptr = (char *)s;
  804160b0ff:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  804160b102:	48 89 c2             	mov    %rax,%rdx
  804160b105:	48 f7 da             	neg    %rdx
  804160b108:	45 85 c9             	test   %r9d,%r9d
  804160b10b:	48 0f 45 c2          	cmovne %rdx,%rax
}
  804160b10f:	c3                   	retq   

000000804160b110 <tsc_calibrate>:
  delta /= i * 256 * 1000;
  return delta;
}

uint64_t
tsc_calibrate(void) {
  804160b110:	55                   	push   %rbp
  804160b111:	48 89 e5             	mov    %rsp,%rbp
  804160b114:	41 57                	push   %r15
  804160b116:	41 56                	push   %r14
  804160b118:	41 55                	push   %r13
  804160b11a:	41 54                	push   %r12
  804160b11c:	53                   	push   %rbx
  804160b11d:	48 83 ec 28          	sub    $0x28,%rsp
  static uint64_t cpu_freq;

  if (cpu_freq == 0) {
  804160b121:	48 a1 40 00 62 41 80 	movabs 0x8041620040,%rax
  804160b128:	00 00 00 
  804160b12b:	48 85 c0             	test   %rax,%rax
  804160b12e:	0f 85 8c 01 00 00    	jne    804160b2c0 <tsc_calibrate+0x1b0>
    int i;
    for (i = 0; i < TIMES; i++) {
  804160b134:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  __asm __volatile("inb %w1,%0"
  804160b13a:	41 bd 61 00 00 00    	mov    $0x61,%r13d
  __asm __volatile("outb %0,%w1"
  804160b140:	41 bf ff ff ff ff    	mov    $0xffffffff,%r15d
  804160b146:	b9 42 00 00 00       	mov    $0x42,%ecx
  uint64_t tsc = 0;
  804160b14b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b14f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160b153:	eb 35                	jmp    804160b18a <tsc_calibrate+0x7a>
  804160b155:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  for (count = 0; count < 50000; count++) {
  804160b159:	be 00 00 00 00       	mov    $0x0,%esi
  804160b15e:	eb 72                	jmp    804160b1d2 <tsc_calibrate+0xc2>
  uint64_t tsc = 0;
  804160b160:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  for (count = 0; count < 50000; count++) {
  804160b164:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160b16a:	e9 c0 00 00 00       	jmpq   804160b22f <tsc_calibrate+0x11f>
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160b16f:	41 83 c4 01          	add    $0x1,%r12d
  804160b173:	83 eb 01             	sub    $0x1,%ebx
  804160b176:	41 83 fc 75          	cmp    $0x75,%r12d
  804160b17a:	75 7a                	jne    804160b1f6 <tsc_calibrate+0xe6>
    for (i = 0; i < TIMES; i++) {
  804160b17c:	41 83 c3 01          	add    $0x1,%r11d
  804160b180:	41 83 fb 64          	cmp    $0x64,%r11d
  804160b184:	0f 84 56 01 00 00    	je     804160b2e0 <tsc_calibrate+0x1d0>
  __asm __volatile("inb %w1,%0"
  804160b18a:	44 89 ea             	mov    %r13d,%edx
  804160b18d:	ec                   	in     (%dx),%al
  outb(0x61, (inb(0x61) & ~0x02) | 0x01);
  804160b18e:	83 e0 fc             	and    $0xfffffffc,%eax
  804160b191:	83 c8 01             	or     $0x1,%eax
  __asm __volatile("outb %0,%w1"
  804160b194:	ee                   	out    %al,(%dx)
  804160b195:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
  804160b19a:	ba 43 00 00 00       	mov    $0x43,%edx
  804160b19f:	ee                   	out    %al,(%dx)
  804160b1a0:	44 89 f8             	mov    %r15d,%eax
  804160b1a3:	89 ca                	mov    %ecx,%edx
  804160b1a5:	ee                   	out    %al,(%dx)
  804160b1a6:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160b1a7:	ec                   	in     (%dx),%al
  804160b1a8:	ec                   	in     (%dx),%al
  804160b1a9:	ec                   	in     (%dx),%al
  804160b1aa:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b1ab:	3c ff                	cmp    $0xff,%al
  804160b1ad:	75 a6                	jne    804160b155 <tsc_calibrate+0x45>
  for (count = 0; count < 50000; count++) {
  804160b1af:	be 00 00 00 00       	mov    $0x0,%esi
  __asm __volatile("rdtsc"
  804160b1b4:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b1b6:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b1ba:	89 c7                	mov    %eax,%edi
  804160b1bc:	48 09 d7             	or     %rdx,%rdi
  804160b1bf:	83 c6 01             	add    $0x1,%esi
  804160b1c2:	81 fe 50 c3 00 00    	cmp    $0xc350,%esi
  804160b1c8:	74 08                	je     804160b1d2 <tsc_calibrate+0xc2>
  __asm __volatile("inb %w1,%0"
  804160b1ca:	89 ca                	mov    %ecx,%edx
  804160b1cc:	ec                   	in     (%dx),%al
  804160b1cd:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b1ce:	3c ff                	cmp    $0xff,%al
  804160b1d0:	74 e2                	je     804160b1b4 <tsc_calibrate+0xa4>
  __asm __volatile("rdtsc"
  804160b1d2:	0f 31                	rdtsc  
  if (pit_expect_msb(0xff, &tsc, &d1)) {
  804160b1d4:	83 fe 05             	cmp    $0x5,%esi
  804160b1d7:	7e a3                	jle    804160b17c <tsc_calibrate+0x6c>
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b1d9:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b1dd:	89 c0                	mov    %eax,%eax
  804160b1df:	48 09 c2             	or     %rax,%rdx
  804160b1e2:	49 89 d2             	mov    %rdx,%r10
  *deltap = read_tsc() - tsc;
  804160b1e5:	49 89 d6             	mov    %rdx,%r14
  804160b1e8:	49 29 fe             	sub    %rdi,%r14
  804160b1eb:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160b1f0:	41 bc 01 00 00 00    	mov    $0x1,%r12d
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160b1f6:	44 88 65 cf          	mov    %r12b,-0x31(%rbp)
  __asm __volatile("inb %w1,%0"
  804160b1fa:	89 ca                	mov    %ecx,%edx
  804160b1fc:	ec                   	in     (%dx),%al
  804160b1fd:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b1fe:	38 c3                	cmp    %al,%bl
  804160b200:	0f 85 5a ff ff ff    	jne    804160b160 <tsc_calibrate+0x50>
  for (count = 0; count < 50000; count++) {
  804160b206:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  __asm __volatile("rdtsc"
  804160b20c:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b20e:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b212:	89 c0                	mov    %eax,%eax
  804160b214:	48 89 d6             	mov    %rdx,%rsi
  804160b217:	48 09 c6             	or     %rax,%rsi
  804160b21a:	41 83 c1 01          	add    $0x1,%r9d
  804160b21e:	41 81 f9 50 c3 00 00 	cmp    $0xc350,%r9d
  804160b225:	74 08                	je     804160b22f <tsc_calibrate+0x11f>
  __asm __volatile("inb %w1,%0"
  804160b227:	89 ca                	mov    %ecx,%edx
  804160b229:	ec                   	in     (%dx),%al
  804160b22a:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b22b:	38 d8                	cmp    %bl,%al
  804160b22d:	74 dd                	je     804160b20c <tsc_calibrate+0xfc>
  __asm __volatile("rdtsc"
  804160b22f:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b231:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b235:	89 c0                	mov    %eax,%eax
  804160b237:	48 09 c2             	or     %rax,%rdx
  *deltap = read_tsc() - tsc;
  804160b23a:	48 29 f2             	sub    %rsi,%rdx
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160b23d:	41 83 f9 05          	cmp    $0x5,%r9d
  804160b241:	0f 8e 35 ff ff ff    	jle    804160b17c <tsc_calibrate+0x6c>
      delta -= tsc;
  804160b247:	48 29 fe             	sub    %rdi,%rsi
      if (d1 + d2 >= delta >> 11)
  804160b24a:	4d 8d 04 16          	lea    (%r14,%rdx,1),%r8
  804160b24e:	48 89 f0             	mov    %rsi,%rax
  804160b251:	48 c1 e8 0b          	shr    $0xb,%rax
  804160b255:	49 39 c0             	cmp    %rax,%r8
  804160b258:	0f 83 11 ff ff ff    	jae    804160b16f <tsc_calibrate+0x5f>
  804160b25e:	49 89 d0             	mov    %rdx,%r8
  __asm __volatile("inb %w1,%0"
  804160b261:	89 ca                	mov    %ecx,%edx
  804160b263:	ec                   	in     (%dx),%al
  804160b264:	ec                   	in     (%dx),%al
      if (!pit_verify_msb(0xfe - i))
  804160b265:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  804160b26a:	2a 55 cf             	sub    -0x31(%rbp),%dl
  804160b26d:	38 c2                	cmp    %al,%dl
  804160b26f:	0f 85 07 ff ff ff    	jne    804160b17c <tsc_calibrate+0x6c>
  delta += (long)(d2 - d1) / 2;
  804160b275:	4c 29 d7             	sub    %r10,%rdi
  804160b278:	49 01 f8             	add    %rdi,%r8
  804160b27b:	4c 89 c7             	mov    %r8,%rdi
  804160b27e:	48 c1 ef 3f          	shr    $0x3f,%rdi
  804160b282:	49 01 f8             	add    %rdi,%r8
  804160b285:	49 d1 f8             	sar    %r8
  804160b288:	4c 01 c6             	add    %r8,%rsi
  delta *= PIT_TICK_RATE;
  804160b28b:	48 69 f6 de 34 12 00 	imul   $0x1234de,%rsi,%rsi
  delta /= i * 256 * 1000;
  804160b292:	45 69 e4 00 e8 03 00 	imul   $0x3e800,%r12d,%r12d
  804160b299:	4d 63 e4             	movslq %r12d,%r12
  804160b29c:	48 89 f0             	mov    %rsi,%rax
  804160b29f:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b2a4:	49 f7 f4             	div    %r12
      if ((cpu_freq = quick_pit_calibrate()))
  804160b2a7:	4c 39 e6             	cmp    %r12,%rsi
  804160b2aa:	0f 82 cc fe ff ff    	jb     804160b17c <tsc_calibrate+0x6c>
  804160b2b0:	48 a3 40 00 62 41 80 	movabs %rax,0x8041620040
  804160b2b7:	00 00 00 
        break;
    }
    if (i == TIMES) {
  804160b2ba:	41 83 fb 64          	cmp    $0x64,%r11d
  804160b2be:	74 20                	je     804160b2e0 <tsc_calibrate+0x1d0>
      cpu_freq = DEFAULT_FREQ;
      cprintf("Can't calibrate pit timer. Using default frequency\n");
    }
  }

  return cpu_freq * 1000;
  804160b2c0:	48 a1 40 00 62 41 80 	movabs 0x8041620040,%rax
  804160b2c7:	00 00 00 
  804160b2ca:	48 69 c0 e8 03 00 00 	imul   $0x3e8,%rax,%rax
}
  804160b2d1:	48 83 c4 28          	add    $0x28,%rsp
  804160b2d5:	5b                   	pop    %rbx
  804160b2d6:	41 5c                	pop    %r12
  804160b2d8:	41 5d                	pop    %r13
  804160b2da:	41 5e                	pop    %r14
  804160b2dc:	41 5f                	pop    %r15
  804160b2de:	5d                   	pop    %rbp
  804160b2df:	c3                   	retq   
      cpu_freq = DEFAULT_FREQ;
  804160b2e0:	48 b8 40 00 62 41 80 	movabs $0x8041620040,%rax
  804160b2e7:	00 00 00 
  804160b2ea:	48 c7 00 a0 25 26 00 	movq   $0x2625a0,(%rax)
      cprintf("Can't calibrate pit timer. Using default frequency\n");
  804160b2f1:	48 bf f8 d9 60 41 80 	movabs $0x804160d9f8,%rdi
  804160b2f8:	00 00 00 
  804160b2fb:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b300:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160b307:	00 00 00 
  804160b30a:	ff d2                	callq  *%rdx
  804160b30c:	eb b2                	jmp    804160b2c0 <tsc_calibrate+0x1b0>

000000804160b30e <print_time>:

void
print_time(unsigned seconds) {
  804160b30e:	55                   	push   %rbp
  804160b30f:	48 89 e5             	mov    %rsp,%rbp
  804160b312:	89 fe                	mov    %edi,%esi
  cprintf("%u\n", seconds);
  804160b314:	48 bf 30 da 60 41 80 	movabs $0x804160da30,%rdi
  804160b31b:	00 00 00 
  804160b31e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b323:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160b32a:	00 00 00 
  804160b32d:	ff d2                	callq  *%rdx
}
  804160b32f:	5d                   	pop    %rbp
  804160b330:	c3                   	retq   

000000804160b331 <print_timer_error>:

void
print_timer_error(void) {
  804160b331:	55                   	push   %rbp
  804160b332:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Timer Error\n");
  804160b335:	48 bf 34 da 60 41 80 	movabs $0x804160da34,%rdi
  804160b33c:	00 00 00 
  804160b33f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b344:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160b34b:	00 00 00 
  804160b34e:	ff d2                	callq  *%rdx
}
  804160b350:	5d                   	pop    %rbp
  804160b351:	c3                   	retq   

000000804160b352 <timer_start>:
static int timer_id       = -1;
static uint64_t timer     = 0;
static uint64_t freq      = 0;

void
timer_start(const char *name) {
  804160b352:	55                   	push   %rbp
  804160b353:	48 89 e5             	mov    %rsp,%rbp
  804160b356:	41 56                	push   %r14
  804160b358:	41 55                	push   %r13
  804160b35a:	41 54                	push   %r12
  804160b35c:	53                   	push   %rbx
  804160b35d:	49 89 fe             	mov    %rdi,%r14
  (void)timer_id;
  (void)timer;
  // DELETED in LAB 5 end

  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160b360:	49 bc a0 1c 62 41 80 	movabs $0x8041621ca0,%r12
  804160b367:	00 00 00 
  804160b36a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160b36f:	49 bd 9e ad 60 41 80 	movabs $0x804160ad9e,%r13
  804160b376:	00 00 00 
  804160b379:	eb 0c                	jmp    804160b387 <timer_start+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160b37b:	83 c3 01             	add    $0x1,%ebx
  804160b37e:	49 83 c4 28          	add    $0x28,%r12
  804160b382:	83 fb 05             	cmp    $0x5,%ebx
  804160b385:	74 61                	je     804160b3e8 <timer_start+0x96>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160b387:	49 8b 3c 24          	mov    (%r12),%rdi
  804160b38b:	48 85 ff             	test   %rdi,%rdi
  804160b38e:	74 eb                	je     804160b37b <timer_start+0x29>
  804160b390:	4c 89 f6             	mov    %r14,%rsi
  804160b393:	41 ff d5             	callq  *%r13
  804160b396:	85 c0                	test   %eax,%eax
  804160b398:	75 e1                	jne    804160b37b <timer_start+0x29>
      timer_id      = i;
  804160b39a:	89 d8                	mov    %ebx,%eax
  804160b39c:	a3 c0 e8 61 41 80 00 	movabs %eax,0x804161e8c0
  804160b3a3:	00 00 
      timer_started = 1;
  804160b3a5:	48 b8 58 00 62 41 80 	movabs $0x8041620058,%rax
  804160b3ac:	00 00 00 
  804160b3af:	c6 00 01             	movb   $0x1,(%rax)
  __asm __volatile("rdtsc"
  804160b3b2:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b3b4:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b3b8:	89 c0                	mov    %eax,%eax
  804160b3ba:	48 09 d0             	or     %rdx,%rax
  804160b3bd:	48 a3 50 00 62 41 80 	movabs %rax,0x8041620050
  804160b3c4:	00 00 00 
      timer         = read_tsc();
      freq          = timertab[timer_id].get_cpu_freq();
  804160b3c7:	48 63 db             	movslq %ebx,%rbx
  804160b3ca:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160b3ce:	48 b8 a0 1c 62 41 80 	movabs $0x8041621ca0,%rax
  804160b3d5:	00 00 00 
  804160b3d8:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160b3dc:	48 a3 48 00 62 41 80 	movabs %rax,0x8041620048
  804160b3e3:	00 00 00 
      return;
  804160b3e6:	eb 1b                	jmp    804160b403 <timer_start+0xb1>
    }
  }

  cprintf("Timer Error\n");
  804160b3e8:	48 bf 34 da 60 41 80 	movabs $0x804160da34,%rdi
  804160b3ef:	00 00 00 
  804160b3f2:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b3f7:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160b3fe:	00 00 00 
  804160b401:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160b403:	5b                   	pop    %rbx
  804160b404:	41 5c                	pop    %r12
  804160b406:	41 5d                	pop    %r13
  804160b408:	41 5e                	pop    %r14
  804160b40a:	5d                   	pop    %rbp
  804160b40b:	c3                   	retq   

000000804160b40c <timer_stop>:

void
timer_stop(void) {
  804160b40c:	55                   	push   %rbp
  804160b40d:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  if (!timer_started || timer_id < 0) {
  804160b410:	48 b8 58 00 62 41 80 	movabs $0x8041620058,%rax
  804160b417:	00 00 00 
  804160b41a:	80 38 00             	cmpb   $0x0,(%rax)
  804160b41d:	74 69                	je     804160b488 <timer_stop+0x7c>
  804160b41f:	48 b8 c0 e8 61 41 80 	movabs $0x804161e8c0,%rax
  804160b426:	00 00 00 
  804160b429:	83 38 00             	cmpl   $0x0,(%rax)
  804160b42c:	78 5a                	js     804160b488 <timer_stop+0x7c>
  __asm __volatile("rdtsc"
  804160b42e:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b430:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b434:	89 c0                	mov    %eax,%eax
  804160b436:	48 09 c2             	or     %rax,%rdx
    print_timer_error();
    return;
  }

  print_time((read_tsc() - timer) / freq);
  804160b439:	48 b8 50 00 62 41 80 	movabs $0x8041620050,%rax
  804160b440:	00 00 00 
  804160b443:	48 2b 10             	sub    (%rax),%rdx
  804160b446:	48 89 d0             	mov    %rdx,%rax
  804160b449:	48 b9 48 00 62 41 80 	movabs $0x8041620048,%rcx
  804160b450:	00 00 00 
  804160b453:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b458:	48 f7 31             	divq   (%rcx)
  804160b45b:	89 c7                	mov    %eax,%edi
  804160b45d:	48 b8 0e b3 60 41 80 	movabs $0x804160b30e,%rax
  804160b464:	00 00 00 
  804160b467:	ff d0                	callq  *%rax

  timer_id      = -1;
  804160b469:	48 b8 c0 e8 61 41 80 	movabs $0x804161e8c0,%rax
  804160b470:	00 00 00 
  804160b473:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%rax)
  timer_started = 0;
  804160b479:	48 b8 58 00 62 41 80 	movabs $0x8041620058,%rax
  804160b480:	00 00 00 
  804160b483:	c6 00 00             	movb   $0x0,(%rax)
  804160b486:	eb 0c                	jmp    804160b494 <timer_stop+0x88>
    print_timer_error();
  804160b488:	48 b8 31 b3 60 41 80 	movabs $0x804160b331,%rax
  804160b48f:	00 00 00 
  804160b492:	ff d0                	callq  *%rax
  // LAB 5 code end
}
  804160b494:	5d                   	pop    %rbp
  804160b495:	c3                   	retq   

000000804160b496 <timer_cpu_frequency>:

void
timer_cpu_frequency(const char *name) {
  804160b496:	55                   	push   %rbp
  804160b497:	48 89 e5             	mov    %rsp,%rbp
  804160b49a:	41 56                	push   %r14
  804160b49c:	41 55                	push   %r13
  804160b49e:	41 54                	push   %r12
  804160b4a0:	53                   	push   %rbx
  804160b4a1:	49 89 fe             	mov    %rdi,%r14
  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160b4a4:	49 bc a0 1c 62 41 80 	movabs $0x8041621ca0,%r12
  804160b4ab:	00 00 00 
  804160b4ae:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160b4b3:	49 bd 9e ad 60 41 80 	movabs $0x804160ad9e,%r13
  804160b4ba:	00 00 00 
  804160b4bd:	eb 0c                	jmp    804160b4cb <timer_cpu_frequency+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160b4bf:	83 c3 01             	add    $0x1,%ebx
  804160b4c2:	49 83 c4 28          	add    $0x28,%r12
  804160b4c6:	83 fb 05             	cmp    $0x5,%ebx
  804160b4c9:	74 48                	je     804160b513 <timer_cpu_frequency+0x7d>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160b4cb:	49 8b 3c 24          	mov    (%r12),%rdi
  804160b4cf:	48 85 ff             	test   %rdi,%rdi
  804160b4d2:	74 eb                	je     804160b4bf <timer_cpu_frequency+0x29>
  804160b4d4:	4c 89 f6             	mov    %r14,%rsi
  804160b4d7:	41 ff d5             	callq  *%r13
  804160b4da:	85 c0                	test   %eax,%eax
  804160b4dc:	75 e1                	jne    804160b4bf <timer_cpu_frequency+0x29>
      cprintf("%lu\n", timertab[i].get_cpu_freq());
  804160b4de:	48 63 db             	movslq %ebx,%rbx
  804160b4e1:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160b4e5:	48 b8 a0 1c 62 41 80 	movabs $0x8041621ca0,%rax
  804160b4ec:	00 00 00 
  804160b4ef:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160b4f3:	48 89 c6             	mov    %rax,%rsi
  804160b4f6:	48 bf c9 bc 60 41 80 	movabs $0x804160bcc9,%rdi
  804160b4fd:	00 00 00 
  804160b500:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b505:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160b50c:	00 00 00 
  804160b50f:	ff d2                	callq  *%rdx
      return;
  804160b511:	eb 1b                	jmp    804160b52e <timer_cpu_frequency+0x98>
    }
  }
  cprintf("Timer Error\n");
  804160b513:	48 bf 34 da 60 41 80 	movabs $0x804160da34,%rdi
  804160b51a:	00 00 00 
  804160b51d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b522:	48 ba 9c 8a 60 41 80 	movabs $0x8041608a9c,%rdx
  804160b529:	00 00 00 
  804160b52c:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160b52e:	5b                   	pop    %rbx
  804160b52f:	41 5c                	pop    %r12
  804160b531:	41 5d                	pop    %r13
  804160b533:	41 5e                	pop    %r14
  804160b535:	5d                   	pop    %rbp
  804160b536:	c3                   	retq   

000000804160b537 <efi_call_in_32bit_mode>:
efi_call_in_32bit_mode(uint32_t func,
                       efi_registers *efi_reg,
                       void *stack_contents,
                       size_t stack_contents_size, /* 16-byte multiple */
                       uint32_t *efi_status) {
  if (func == 0) {
  804160b537:	85 ff                	test   %edi,%edi
  804160b539:	74 50                	je     804160b58b <efi_call_in_32bit_mode+0x54>
    return -E_INVAL;
  }

  if ((efi_reg == NULL) || (stack_contents == NULL) || (stack_contents_size % 16 != 0)) {
  804160b53b:	48 85 f6             	test   %rsi,%rsi
  804160b53e:	74 51                	je     804160b591 <efi_call_in_32bit_mode+0x5a>
  804160b540:	48 85 d2             	test   %rdx,%rdx
  804160b543:	74 4c                	je     804160b591 <efi_call_in_32bit_mode+0x5a>
  804160b545:	f6 c1 0f             	test   $0xf,%cl
  804160b548:	75 4d                	jne    804160b597 <efi_call_in_32bit_mode+0x60>
                       uint32_t *efi_status) {
  804160b54a:	55                   	push   %rbp
  804160b54b:	48 89 e5             	mov    %rsp,%rbp
  804160b54e:	41 54                	push   %r12
  804160b550:	53                   	push   %rbx
  804160b551:	4d 89 c4             	mov    %r8,%r12
  804160b554:	48 89 f3             	mov    %rsi,%rbx
    return -E_INVAL;
  }

  //We need to set up kernel data segments for 32 bit mode
  //before calling asm.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD32));
  804160b557:	b8 20 00 00 00       	mov    $0x20,%eax
  804160b55c:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD32));
  804160b55e:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD32));
  804160b560:	8e d0                	mov    %eax,%ss
  _efi_call_in_32bit_mode_asm(func,
  804160b562:	48 b8 9e b5 60 41 80 	movabs $0x804160b59e,%rax
  804160b569:	00 00 00 
  804160b56c:	ff d0                	callq  *%rax
                              efi_reg,
                              stack_contents,
                              stack_contents_size);
  //Restore 64 bit kernel data segments.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  804160b56e:	b8 10 00 00 00       	mov    $0x10,%eax
  804160b573:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  804160b575:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  804160b577:	8e d0                	mov    %eax,%ss

  *efi_status = (uint32_t)efi_reg->rax;
  804160b579:	48 8b 43 20          	mov    0x20(%rbx),%rax
  804160b57d:	41 89 04 24          	mov    %eax,(%r12)

  return 0;
  804160b581:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160b586:	5b                   	pop    %rbx
  804160b587:	41 5c                	pop    %r12
  804160b589:	5d                   	pop    %rbp
  804160b58a:	c3                   	retq   
    return -E_INVAL;
  804160b58b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b590:	c3                   	retq   
    return -E_INVAL;
  804160b591:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b596:	c3                   	retq   
  804160b597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  804160b59c:	c3                   	retq   
  804160b59d:	90                   	nop

000000804160b59e <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  804160b59e:	55                   	push   %rbp
    movq %rsp, %rbp
  804160b59f:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  804160b5a2:	53                   	push   %rbx
	push	%r12
  804160b5a3:	41 54                	push   %r12
	push	%r13
  804160b5a5:	41 55                	push   %r13
	push	%r14
  804160b5a7:	41 56                	push   %r14
	push	%r15
  804160b5a9:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  804160b5ab:	56                   	push   %rsi
	push	%rcx
  804160b5ac:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  804160b5ad:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  804160b5ae:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  804160b5b1:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

000000804160b5b8 <copyloop>:
  804160b5b8:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  804160b5bc:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  804160b5c0:	49 83 c0 08          	add    $0x8,%r8
  804160b5c4:	49 39 c8             	cmp    %rcx,%r8
  804160b5c7:	75 ef                	jne    804160b5b8 <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  804160b5c9:	e8 00 00 00 00       	callq  804160b5ce <copyloop+0x16>
  804160b5ce:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  804160b5d5:	00 
  804160b5d6:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  804160b5dd:	00 
  804160b5de:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  804160b5df:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  804160b5e1:	6a 08                	pushq  $0x8
  804160b5e3:	e8 00 00 00 00       	callq  804160b5e8 <copyloop+0x30>
  804160b5e8:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  804160b5ef:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  804160b5f0:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  804160b5f4:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  804160b5f8:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  804160b5fc:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  804160b5ff:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  804160b600:	59                   	pop    %rcx
	pop	%rsi
  804160b601:	5e                   	pop    %rsi
	pop	%r15
  804160b602:	41 5f                	pop    %r15
	pop	%r14
  804160b604:	41 5e                	pop    %r14
	pop	%r13
  804160b606:	41 5d                	pop    %r13
	pop	%r12
  804160b608:	41 5c                	pop    %r12
	pop	%rbx
  804160b60a:	5b                   	pop    %rbx

	leave
  804160b60b:	c9                   	leaveq 
	ret
  804160b60c:	c3                   	retq   

000000804160b60d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name) {
  lk->locked = 0;
  804160b60d:	c7 07 00 00 00 00    	movl   $0x0,(%rdi)
#ifdef DEBUG_SPINLOCK
  lk->name = name;
#endif
}
  804160b613:	c3                   	retq   

000000804160b614 <spin_lock>:
  asm volatile("lock; xchgl %0, %1"
  804160b614:	b8 01 00 00 00       	mov    $0x1,%eax
  804160b619:	f0 87 07             	lock xchg %eax,(%rdi)
#endif

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
  804160b61c:	85 c0                	test   %eax,%eax
  804160b61e:	74 10                	je     804160b630 <spin_lock+0x1c>
  804160b620:	ba 01 00 00 00       	mov    $0x1,%edx
    asm volatile("pause");
  804160b625:	f3 90                	pause  
  804160b627:	89 d0                	mov    %edx,%eax
  804160b629:	f0 87 07             	lock xchg %eax,(%rdi)
  while (xchg(&lk->locked, 1) != 0)
  804160b62c:	85 c0                	test   %eax,%eax
  804160b62e:	75 f5                	jne    804160b625 <spin_lock+0x11>

    // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  get_caller_pcs(lk->pcs);
#endif
}
  804160b630:	c3                   	retq   

000000804160b631 <spin_unlock>:
  804160b631:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b636:	f0 87 07             	lock xchg %eax,(%rdi)
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
}
  804160b639:	c3                   	retq   
  804160b63a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
