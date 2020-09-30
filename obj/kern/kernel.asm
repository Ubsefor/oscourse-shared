
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
  8041600011:	e8 68 02 00 00       	callq  804160027e <i386_init>

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
  804160008c:	e8 a4 40 00 00       	callq  8041604135 <csys_yield>
  jmp .
  8041600091:	eb fe                	jmp    8041600091 <sys_yield+0xa>

0000008041600093 <sys_exit>:

# LAB 3: Your code here.
.globl sys_exit
.type  sys_exit, @function
sys_exit:
  call csys_exit
  8041600093:	e8 7e 40 00 00       	callq  8041604116 <csys_exit>
  jmp .
  8041600098:	eb fe                	jmp    8041600098 <sys_exit+0x5>

000000804160009a <alloc_pde_early_boot>:
#include <kern/trap.h>
#include <kern/sched.h>
#include <kern/cpu.h>

pde_t *
alloc_pde_early_boot(void) {
  804160009a:	55                   	push   %rbp
  804160009b:	48 89 e5             	mov    %rsp,%rbp
  //Assume pde1, pde2 is already used.
  extern uintptr_t pdefreestart, pdefreeend;
  pde_t *ret;
  static uintptr_t pdefree = (uintptr_t)&pdefreestart;

  if (pdefree >= (uintptr_t)&pdefreeend)
  804160009e:	48 b8 08 70 61 41 80 	movabs $0x8041617008,%rax
  80416000a5:	00 00 00 
  80416000a8:	48 8b 10             	mov    (%rax),%rdx
  80416000ab:	48 b8 00 c0 50 01 00 	movabs $0x150c000,%rax
  80416000b2:	00 00 00 
  80416000b5:	48 39 c2             	cmp    %rax,%rdx
  80416000b8:	73 1c                	jae    80416000d6 <alloc_pde_early_boot+0x3c>
    return NULL;

  ret = (pde_t *)pdefree;
  80416000ba:	48 89 d1             	mov    %rdx,%rcx
  pdefree += PGSIZE;
  80416000bd:	48 81 c2 00 10 00 00 	add    $0x1000,%rdx
  80416000c4:	48 89 d0             	mov    %rdx,%rax
  80416000c7:	48 a3 08 70 61 41 80 	movabs %rax,0x8041617008
  80416000ce:	00 00 00 
  return ret;
}
  80416000d1:	48 89 c8             	mov    %rcx,%rax
  80416000d4:	5d                   	pop    %rbp
  80416000d5:	c3                   	retq   
    return NULL;
  80416000d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416000db:	eb f4                	jmp    80416000d1 <alloc_pde_early_boot+0x37>

00000080416000dd <map_addr_early_boot>:

void
map_addr_early_boot(uintptr_t addr, uintptr_t addr_phys, size_t sz) {
  80416000dd:	55                   	push   %rbp
  80416000de:	48 89 e5             	mov    %rsp,%rbp
  80416000e1:	41 57                	push   %r15
  80416000e3:	41 56                	push   %r14
  80416000e5:	41 55                	push   %r13
  80416000e7:	41 54                	push   %r12
  80416000e9:	53                   	push   %rbx
  80416000ea:	48 83 ec 08          	sub    $0x8,%rsp
  pml4e_t *pml4 = &pml4phys;
  pdpe_t *pdpt;
  pde_t *pde;

  uintptr_t addr_curr, addr_curr_phys, addr_end;
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  80416000ee:	48 89 f8             	mov    %rdi,%rax
  80416000f1:	48 25 00 00 e0 ff    	and    $0xffffffffffe00000,%rax
  addr_curr_phys = ROUNDDOWN(addr_phys, PTSIZE);
  80416000f7:	48 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%rsi
  addr_end       = ROUNDUP(addr + sz, PTSIZE);
  80416000fe:	4c 8d bc 17 ff ff 1f 	lea    0x1fffff(%rdi,%rdx,1),%r15
  8041600105:	00 
  8041600106:	49 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%r15

  pdpt = (pdpe_t *)PTE_ADDR(pml4[PML4(addr_curr)]);
  804160010d:	48 c1 ef 24          	shr    $0x24,%rdi
  8041600111:	81 e7 f8 0f 00 00    	and    $0xff8,%edi
  8041600117:	48 ba 00 10 50 01 00 	movabs $0x1501000,%rdx
  804160011e:	00 00 00 
  8041600121:	48 8b 14 3a          	mov    (%rdx,%rdi,1),%rdx
  8041600125:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  804160012c:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  8041600130:	49 39 c7             	cmp    %rax,%r15
  8041600133:	76 4f                	jbe    8041600184 <map_addr_early_boot+0xa7>
  8041600135:	48 89 c3             	mov    %rax,%rbx
  8041600138:	48 29 c6             	sub    %rax,%rsi
  804160013b:	49 89 f6             	mov    %rsi,%r14
  804160013e:	4d 8d 2c 1e          	lea    (%r14,%rbx,1),%r13
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
  8041600142:	49 89 dc             	mov    %rbx,%r12
  8041600145:	49 c1 ec 1b          	shr    $0x1b,%r12
  8041600149:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
  8041600150:	4c 03 65 d0          	add    -0x30(%rbp),%r12
    if (!pde) {
  8041600154:	49 8b 04 24          	mov    (%r12),%rax
  8041600158:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160015e:	74 33                	je     8041600193 <map_addr_early_boot+0xb6>
      pde                   = alloc_pde_early_boot();
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
    }
    pde[PDX(addr_curr)] = addr_curr_phys | PTE_P | PTE_W | PTE_MBZ;
  8041600160:	48 89 da             	mov    %rbx,%rdx
  8041600163:	48 c1 ea 15          	shr    $0x15,%rdx
  8041600167:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  804160016d:	49 81 cd 83 01 00 00 	or     $0x183,%r13
  8041600174:	4c 89 2c d0          	mov    %r13,(%rax,%rdx,8)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  8041600178:	48 81 c3 00 00 20 00 	add    $0x200000,%rbx
  804160017f:	49 39 df             	cmp    %rbx,%r15
  8041600182:	77 ba                	ja     804160013e <map_addr_early_boot+0x61>
  }
}
  8041600184:	48 83 c4 08          	add    $0x8,%rsp
  8041600188:	5b                   	pop    %rbx
  8041600189:	41 5c                	pop    %r12
  804160018b:	41 5d                	pop    %r13
  804160018d:	41 5e                	pop    %r14
  804160018f:	41 5f                	pop    %r15
  8041600191:	5d                   	pop    %rbp
  8041600192:	c3                   	retq   
      pde                   = alloc_pde_early_boot();
  8041600193:	48 b8 9a 00 60 41 80 	movabs $0x804160009a,%rax
  804160019a:	00 00 00 
  804160019d:	ff d0                	callq  *%rax
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
  804160019f:	48 89 c2             	mov    %rax,%rdx
  80416001a2:	48 83 ca 03          	or     $0x3,%rdx
  80416001a6:	49 89 14 24          	mov    %rdx,(%r12)
  80416001aa:	eb b4                	jmp    8041600160 <map_addr_early_boot+0x83>

00000080416001ac <early_boot_pml4_init>:
// Additionally maps pml4 memory so that we dont get memory errors on accessing
// uefi_lp, MemMap, KASAN functions.
void
early_boot_pml4_init(void) {
  80416001ac:	55                   	push   %rbp
  80416001ad:	48 89 e5             	mov    %rsp,%rbp
  80416001b0:	41 54                	push   %r12
  80416001b2:	53                   	push   %rbx

  map_addr_early_boot((uintptr_t)uefi_lp, (uintptr_t)uefi_lp, sizeof(LOADER_PARAMS));
  80416001b3:	49 bc 00 70 61 41 80 	movabs $0x8041617000,%r12
  80416001ba:	00 00 00 
  80416001bd:	49 8b 3c 24          	mov    (%r12),%rdi
  80416001c1:	ba c8 00 00 00       	mov    $0xc8,%edx
  80416001c6:	48 89 fe             	mov    %rdi,%rsi
  80416001c9:	48 bb dd 00 60 41 80 	movabs $0x80416000dd,%rbx
  80416001d0:	00 00 00 
  80416001d3:	ff d3                	callq  *%rbx
  map_addr_early_boot((uintptr_t)uefi_lp->MemoryMap, (uintptr_t)uefi_lp->MemoryMap, uefi_lp->MemoryMapSize);
  80416001d5:	49 8b 04 24          	mov    (%r12),%rax
  80416001d9:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80416001dd:	48 8b 50 38          	mov    0x38(%rax),%rdx
  80416001e1:	48 89 fe             	mov    %rdi,%rsi
  80416001e4:	ff d3                	callq  *%rbx

#ifdef SANITIZE_SHADOW_BASE
  map_addr_early_boot(SANITIZE_SHADOW_BASE, SANITIZE_SHADOW_BASE - KERNBASE, SANITIZE_SHADOW_SIZE);
#endif

  map_addr_early_boot(FBUFFBASE, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
  80416001e6:	49 8b 04 24          	mov    (%r12),%rax
  80416001ea:	8b 50 48             	mov    0x48(%rax),%edx
  80416001ed:	48 8b 70 40          	mov    0x40(%rax),%rsi
  80416001f1:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416001f8:	00 00 00 
  80416001fb:	ff d3                	callq  *%rbx
}
  80416001fd:	5b                   	pop    %rbx
  80416001fe:	41 5c                	pop    %r12
  8041600200:	5d                   	pop    %rbp
  8041600201:	c3                   	retq   

0000008041600202 <test_backtrace>:

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x) {
  8041600202:	55                   	push   %rbp
  8041600203:	48 89 e5             	mov    %rsp,%rbp
  8041600206:	53                   	push   %rbx
  8041600207:	48 83 ec 08          	sub    $0x8,%rsp
  804160020b:	89 fb                	mov    %edi,%ebx
  cprintf("entering test_backtrace %d\n", x);
  804160020d:	89 fe                	mov    %edi,%esi
  804160020f:	48 bf c0 56 60 41 80 	movabs $0x80416056c0,%rdi
  8041600216:	00 00 00 
  8041600219:	b8 00 00 00 00       	mov    $0x0,%eax
  804160021e:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041600225:	00 00 00 
  8041600228:	ff d2                	callq  *%rdx
  if (x > 0)
  804160022a:	85 db                	test   %ebx,%ebx
  804160022c:	7e 33                	jle    8041600261 <test_backtrace+0x5f>
    test_backtrace(x - 1);
  804160022e:	8d 7b ff             	lea    -0x1(%rbx),%edi
  8041600231:	48 b8 02 02 60 41 80 	movabs $0x8041600202,%rax
  8041600238:	00 00 00 
  804160023b:	ff d0                	callq  *%rax
  else
    mon_backtrace(0, 0, 0);
  cprintf("leaving test_backtrace %d\n", x);
  804160023d:	89 de                	mov    %ebx,%esi
  804160023f:	48 bf dc 56 60 41 80 	movabs $0x80416056dc,%rdi
  8041600246:	00 00 00 
  8041600249:	b8 00 00 00 00       	mov    $0x0,%eax
  804160024e:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041600255:	00 00 00 
  8041600258:	ff d2                	callq  *%rdx
}
  804160025a:	48 83 c4 08          	add    $0x8,%rsp
  804160025e:	5b                   	pop    %rbx
  804160025f:	5d                   	pop    %rbp
  8041600260:	c3                   	retq   
    mon_backtrace(0, 0, 0);
  8041600261:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600266:	be 00 00 00 00       	mov    $0x0,%esi
  804160026b:	bf 00 00 00 00       	mov    $0x0,%edi
  8041600270:	48 b8 ce 39 60 41 80 	movabs $0x80416039ce,%rax
  8041600277:	00 00 00 
  804160027a:	ff d0                	callq  *%rax
  804160027c:	eb bf                	jmp    804160023d <test_backtrace+0x3b>

000000804160027e <i386_init>:

void
i386_init(void) {
  804160027e:	55                   	push   %rbp
  804160027f:	48 89 e5             	mov    %rsp,%rbp
  8041600282:	41 54                	push   %r12
  8041600284:	53                   	push   %rbx
  extern char end[];

  early_boot_pml4_init();
  8041600285:	48 b8 ac 01 60 41 80 	movabs $0x80416001ac,%rax
  804160028c:	00 00 00 
  804160028f:	ff d0                	callq  *%rax

  // Initialize the console.
  // Can't call cprintf until after we do this!
  cons_init();
  8041600291:	48 b8 72 0b 60 41 80 	movabs $0x8041600b72,%rax
  8041600298:	00 00 00 
  804160029b:	ff d0                	callq  *%rax

  cprintf("6828 decimal is %o octal!\n", 6828);
  804160029d:	be ac 1a 00 00       	mov    $0x1aac,%esi
  80416002a2:	48 bf f7 56 60 41 80 	movabs $0x80416056f7,%rdi
  80416002a9:	00 00 00 
  80416002ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002b1:	48 bb f3 42 60 41 80 	movabs $0x80416042f3,%rbx
  80416002b8:	00 00 00 
  80416002bb:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  80416002bd:	48 be 00 60 62 41 80 	movabs $0x8041626000,%rsi
  80416002c4:	00 00 00 
  80416002c7:	48 bf 12 57 60 41 80 	movabs $0x8041605712,%rdi
  80416002ce:	00 00 00 
  80416002d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002d6:	ff d3                	callq  *%rbx
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80416002d8:	48 b8 60 2f 62 41 80 	movabs $0x8041622f60,%rax
  80416002df:	00 00 00 
  80416002e2:	48 ba 60 2f 62 41 80 	movabs $0x8041622f60,%rdx
  80416002e9:	00 00 00 
  80416002ec:	48 39 c2             	cmp    %rax,%rdx
  80416002ef:	73 16                	jae    8041600307 <i386_init+0x89>
  80416002f1:	48 89 d3             	mov    %rdx,%rbx
  80416002f4:	49 89 c4             	mov    %rax,%r12
    (*ctor)();
  80416002f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002fc:	ff 13                	callq  *(%rbx)
    ctor++;
  80416002fe:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8041600302:	4c 39 e3             	cmp    %r12,%rbx
  8041600305:	72 f0                	jb     80416002f7 <i386_init+0x79>
  }

  // Framebuffer init should be done after memory init.
  fb_init();
  8041600307:	48 b8 63 0a 60 41 80 	movabs $0x8041600a63,%rax
  804160030e:	00 00 00 
  8041600311:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  8041600313:	48 bf 1b 57 60 41 80 	movabs $0x804160571b,%rdi
  804160031a:	00 00 00 
  804160031d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600322:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041600329:	00 00 00 
  804160032c:	ff d2                	callq  *%rdx

  // user environment initialization functions
  env_init();
  804160032e:	48 b8 78 3d 60 41 80 	movabs $0x8041603d78,%rax
  8041600335:	00 00 00 
  8041600338:	ff d0                	callq  *%rax

#ifdef CONFIG_KSPACE
  // Touch all you want.
  ENV_CREATE_KERNEL_TYPE(prog_test1);
  804160033a:	be 01 00 00 00       	mov    $0x1,%esi
  804160033f:	48 bf 90 77 61 41 80 	movabs $0x8041617790,%rdi
  8041600346:	00 00 00 
  8041600349:	48 bb 5a 3f 60 41 80 	movabs $0x8041603f5a,%rbx
  8041600350:	00 00 00 
  8041600353:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test2);
  8041600355:	be 01 00 00 00       	mov    $0x1,%esi
  804160035a:	48 bf 8a b4 61 41 80 	movabs $0x804161b48a,%rdi
  8041600361:	00 00 00 
  8041600364:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test3);
  8041600366:	be 01 00 00 00       	mov    $0x1,%esi
  804160036b:	48 bf 64 f2 61 41 80 	movabs $0x804161f264,%rdi
  8041600372:	00 00 00 
  8041600375:	ff d3                	callq  *%rbx
#endif

  // Schedule and run the first user environment!
  sched_yield();
  8041600377:	48 b8 2c 44 60 41 80 	movabs $0x804160442c,%rax
  804160037e:	00 00 00 
  8041600381:	ff d0                	callq  *%rax

0000008041600383 <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8041600383:	55                   	push   %rbp
  8041600384:	48 89 e5             	mov    %rsp,%rbp
  8041600387:	41 54                	push   %r12
  8041600389:	53                   	push   %rbx
  804160038a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600391:	49 89 d4             	mov    %rdx,%r12
  8041600394:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  804160039b:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80416003a2:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416003a9:	84 c0                	test   %al,%al
  80416003ab:	74 23                	je     80416003d0 <_panic+0x4d>
  80416003ad:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416003b4:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416003b8:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416003bc:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416003c0:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416003c4:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416003c8:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416003cc:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  if (panicstr)
  80416003d0:	48 b8 60 2f 62 41 80 	movabs $0x8041622f60,%rax
  80416003d7:	00 00 00 
  80416003da:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416003de:	74 13                	je     80416003f3 <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416003e0:	48 bb cf 3a 60 41 80 	movabs $0x8041603acf,%rbx
  80416003e7:	00 00 00 
  80416003ea:	bf 00 00 00 00       	mov    $0x0,%edi
  80416003ef:	ff d3                	callq  *%rbx
  80416003f1:	eb f7                	jmp    80416003ea <_panic+0x67>
  panicstr = fmt;
  80416003f3:	4c 89 e0             	mov    %r12,%rax
  80416003f6:	48 a3 60 2f 62 41 80 	movabs %rax,0x8041622f60
  80416003fd:	00 00 00 
  __asm __volatile("cli; cld");
  8041600400:	fa                   	cli    
  8041600401:	fc                   	cld    
  va_start(ap, fmt);
  8041600402:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  8041600409:	00 00 00 
  804160040c:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8041600413:	00 00 00 
  8041600416:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160041a:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  8041600421:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  8041600428:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel panic at %s:%d: ", file, line);
  804160042f:	89 f2                	mov    %esi,%edx
  8041600431:	48 89 fe             	mov    %rdi,%rsi
  8041600434:	48 bf 34 57 60 41 80 	movabs $0x8041605734,%rdi
  804160043b:	00 00 00 
  804160043e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600443:	48 bb f3 42 60 41 80 	movabs $0x80416042f3,%rbx
  804160044a:	00 00 00 
  804160044d:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  804160044f:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600456:	4c 89 e7             	mov    %r12,%rdi
  8041600459:	48 b8 bf 42 60 41 80 	movabs $0x80416042bf,%rax
  8041600460:	00 00 00 
  8041600463:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600465:	48 bf 09 5d 60 41 80 	movabs $0x8041605d09,%rdi
  804160046c:	00 00 00 
  804160046f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600474:	ff d3                	callq  *%rbx
  8041600476:	e9 65 ff ff ff       	jmpq   80416003e0 <_panic+0x5d>

000000804160047b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  804160047b:	55                   	push   %rbp
  804160047c:	48 89 e5             	mov    %rsp,%rbp
  804160047f:	41 54                	push   %r12
  8041600481:	53                   	push   %rbx
  8041600482:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600489:	49 89 d4             	mov    %rdx,%r12
  804160048c:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8041600493:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  804160049a:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416004a1:	84 c0                	test   %al,%al
  80416004a3:	74 23                	je     80416004c8 <_warn+0x4d>
  80416004a5:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416004ac:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416004b0:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416004b4:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416004b8:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416004bc:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416004c0:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416004c4:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416004c8:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416004cf:	00 00 00 
  80416004d2:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416004d9:	00 00 00 
  80416004dc:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416004e0:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416004e7:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416004ee:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  80416004f5:	89 f2                	mov    %esi,%edx
  80416004f7:	48 89 fe             	mov    %rdi,%rsi
  80416004fa:	48 bf 4c 57 60 41 80 	movabs $0x804160574c,%rdi
  8041600501:	00 00 00 
  8041600504:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600509:	48 bb f3 42 60 41 80 	movabs $0x80416042f3,%rbx
  8041600510:	00 00 00 
  8041600513:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600515:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160051c:	4c 89 e7             	mov    %r12,%rdi
  804160051f:	48 b8 bf 42 60 41 80 	movabs $0x80416042bf,%rax
  8041600526:	00 00 00 
  8041600529:	ff d0                	callq  *%rax
  cprintf("\n");
  804160052b:	48 bf 09 5d 60 41 80 	movabs $0x8041605d09,%rdi
  8041600532:	00 00 00 
  8041600535:	b8 00 00 00 00       	mov    $0x0,%eax
  804160053a:	ff d3                	callq  *%rbx
  va_end(ap);
}
  804160053c:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  8041600543:	5b                   	pop    %rbx
  8041600544:	41 5c                	pop    %r12
  8041600546:	5d                   	pop    %rbp
  8041600547:	c3                   	retq   

0000008041600548 <serial_proc_data>:
    }
  }
}

static int
serial_proc_data(void) {
  8041600548:	55                   	push   %rbp
  8041600549:	48 89 e5             	mov    %rsp,%rbp
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  804160054c:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600551:	ec                   	in     (%dx),%al
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  8041600552:	a8 01                	test   $0x1,%al
  8041600554:	74 0b                	je     8041600561 <serial_proc_data+0x19>
  8041600556:	ba f8 03 00 00       	mov    $0x3f8,%edx
  804160055b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  804160055c:	0f b6 c0             	movzbl %al,%eax
}
  804160055f:	5d                   	pop    %rbp
  8041600560:	c3                   	retq   
    return -1;
  8041600561:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041600566:	eb f7                	jmp    804160055f <serial_proc_data+0x17>

0000008041600568 <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  8041600568:	55                   	push   %rbp
  8041600569:	48 89 e5             	mov    %rsp,%rbp
  804160056c:	41 54                	push   %r12
  804160056e:	53                   	push   %rbx
  804160056f:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  8041600572:	48 bb a0 2f 62 41 80 	movabs $0x8041622fa0,%rbx
  8041600579:	00 00 00 
  while ((c = (*proc)()) != -1) {
  804160057c:	41 ff d4             	callq  *%r12
  804160057f:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041600582:	74 2c                	je     80416005b0 <cons_intr+0x48>
    if (c == 0)
  8041600584:	85 c0                	test   %eax,%eax
  8041600586:	74 f4                	je     804160057c <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  8041600588:	8b 93 04 02 00 00    	mov    0x204(%rbx),%edx
  804160058e:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600591:	89 8b 04 02 00 00    	mov    %ecx,0x204(%rbx)
  8041600597:	89 d2                	mov    %edx,%edx
  8041600599:	88 04 13             	mov    %al,(%rbx,%rdx,1)
    if (cons.wpos == CONSBUFSIZE)
  804160059c:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  80416005a2:	75 d8                	jne    804160057c <cons_intr+0x14>
      cons.wpos = 0;
  80416005a4:	c7 83 04 02 00 00 00 	movl   $0x0,0x204(%rbx)
  80416005ab:	00 00 00 
  80416005ae:	eb cc                	jmp    804160057c <cons_intr+0x14>
  }
}
  80416005b0:	5b                   	pop    %rbx
  80416005b1:	41 5c                	pop    %r12
  80416005b3:	5d                   	pop    %rbp
  80416005b4:	c3                   	retq   

00000080416005b5 <kbd_proc_data>:
kbd_proc_data(void) {
  80416005b5:	55                   	push   %rbp
  80416005b6:	48 89 e5             	mov    %rsp,%rbp
  80416005b9:	53                   	push   %rbx
  80416005ba:	48 83 ec 08          	sub    $0x8,%rsp
  80416005be:	ba 64 00 00 00       	mov    $0x64,%edx
  80416005c3:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416005c4:	a8 01                	test   $0x1,%al
  80416005c6:	0f 84 33 01 00 00    	je     80416006ff <kbd_proc_data+0x14a>
  80416005cc:	ba 60 00 00 00       	mov    $0x60,%edx
  80416005d1:	ec                   	in     (%dx),%al
  80416005d2:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416005d4:	3c e0                	cmp    $0xe0,%al
  80416005d6:	0f 84 99 00 00 00    	je     8041600675 <kbd_proc_data+0xc0>
  } else if (data & 0x80) {
  80416005dc:	84 c0                	test   %al,%al
  80416005de:	0f 88 a5 00 00 00    	js     8041600689 <kbd_proc_data+0xd4>
  } else if (shift & E0ESC) {
  80416005e4:	48 bf 80 2f 62 41 80 	movabs $0x8041622f80,%rdi
  80416005eb:	00 00 00 
  80416005ee:	8b 0f                	mov    (%rdi),%ecx
  80416005f0:	f6 c1 40             	test   $0x40,%cl
  80416005f3:	74 0c                	je     8041600601 <kbd_proc_data+0x4c>
    data |= 0x80;
  80416005f5:	83 c8 80             	or     $0xffffff80,%eax
  80416005f8:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416005fa:	89 c8                	mov    %ecx,%eax
  80416005fc:	83 e0 bf             	and    $0xffffffbf,%eax
  80416005ff:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  8041600601:	0f b6 f2             	movzbl %dl,%esi
  8041600604:	48 b8 c0 58 60 41 80 	movabs $0x80416058c0,%rax
  804160060b:	00 00 00 
  804160060e:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  8041600612:	48 b9 80 2f 62 41 80 	movabs $0x8041622f80,%rcx
  8041600619:	00 00 00 
  804160061c:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  804160061e:	48 bf c0 57 60 41 80 	movabs $0x80416057c0,%rdi
  8041600625:	00 00 00 
  8041600628:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  804160062c:	31 f0                	xor    %esi,%eax
  804160062e:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  8041600630:	89 c6                	mov    %eax,%esi
  8041600632:	83 e6 03             	and    $0x3,%esi
  8041600635:	0f b6 d2             	movzbl %dl,%edx
  8041600638:	48 b9 a0 57 60 41 80 	movabs $0x80416057a0,%rcx
  804160063f:	00 00 00 
  8041600642:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  8041600646:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  804160064a:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  804160064d:	a8 08                	test   $0x8,%al
  804160064f:	74 0d                	je     804160065e <kbd_proc_data+0xa9>
    if ('a' <= c && c <= 'z')
  8041600651:	89 da                	mov    %ebx,%edx
  8041600653:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  8041600656:	83 f9 19             	cmp    $0x19,%ecx
  8041600659:	77 6b                	ja     80416006c6 <kbd_proc_data+0x111>
      c += 'A' - 'a';
  804160065b:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  804160065e:	f7 d0                	not    %eax
  8041600660:	a8 06                	test   $0x6,%al
  8041600662:	75 08                	jne    804160066c <kbd_proc_data+0xb7>
  8041600664:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  804160066a:	74 68                	je     80416006d4 <kbd_proc_data+0x11f>
}
  804160066c:	89 d8                	mov    %ebx,%eax
  804160066e:	48 83 c4 08          	add    $0x8,%rsp
  8041600672:	5b                   	pop    %rbx
  8041600673:	5d                   	pop    %rbp
  8041600674:	c3                   	retq   
    shift |= E0ESC;
  8041600675:	48 b8 80 2f 62 41 80 	movabs $0x8041622f80,%rax
  804160067c:	00 00 00 
  804160067f:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  8041600682:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041600687:	eb e3                	jmp    804160066c <kbd_proc_data+0xb7>
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600689:	48 bf 80 2f 62 41 80 	movabs $0x8041622f80,%rdi
  8041600690:	00 00 00 
  8041600693:	8b 0f                	mov    (%rdi),%ecx
  8041600695:	89 ce                	mov    %ecx,%esi
  8041600697:	83 e6 40             	and    $0x40,%esi
  804160069a:	83 e0 7f             	and    $0x7f,%eax
  804160069d:	85 f6                	test   %esi,%esi
  804160069f:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  80416006a2:	0f b6 d2             	movzbl %dl,%edx
  80416006a5:	48 b8 c0 58 60 41 80 	movabs $0x80416058c0,%rax
  80416006ac:	00 00 00 
  80416006af:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  80416006b3:	83 c8 40             	or     $0x40,%eax
  80416006b6:	0f b6 c0             	movzbl %al,%eax
  80416006b9:	f7 d0                	not    %eax
  80416006bb:	21 c8                	and    %ecx,%eax
  80416006bd:	89 07                	mov    %eax,(%rdi)
    return 0;
  80416006bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416006c4:	eb a6                	jmp    804160066c <kbd_proc_data+0xb7>
    else if ('A' <= c && c <= 'Z')
  80416006c6:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416006c9:	8d 4b 20             	lea    0x20(%rbx),%ecx
  80416006cc:	83 fa 19             	cmp    $0x19,%edx
  80416006cf:	0f 46 d9             	cmovbe %ecx,%ebx
  80416006d2:	eb 8a                	jmp    804160065e <kbd_proc_data+0xa9>
    cprintf("Rebooting!\n");
  80416006d4:	48 bf 66 57 60 41 80 	movabs $0x8041605766,%rdi
  80416006db:	00 00 00 
  80416006de:	b8 00 00 00 00       	mov    $0x0,%eax
  80416006e3:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416006ea:	00 00 00 
  80416006ed:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416006ef:	ba 92 00 00 00       	mov    $0x92,%edx
  80416006f4:	b8 03 00 00 00       	mov    $0x3,%eax
  80416006f9:	ee                   	out    %al,(%dx)
  80416006fa:	e9 6d ff ff ff       	jmpq   804160066c <kbd_proc_data+0xb7>
    return -1;
  80416006ff:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8041600704:	e9 63 ff ff ff       	jmpq   804160066c <kbd_proc_data+0xb7>

0000008041600709 <draw_char>:
draw_char(uint32_t *buffer, uint32_t x, uint32_t y, uint32_t color, char charcode) {
  8041600709:	55                   	push   %rbp
  804160070a:	48 89 e5             	mov    %rsp,%rbp
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  804160070d:	4d 0f be c0          	movsbq %r8b,%r8
  8041600711:	48 b8 20 73 61 41 80 	movabs $0x8041617320,%rax
  8041600718:	00 00 00 
  804160071b:	4e 8d 0c c0          	lea    (%rax,%r8,8),%r9
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160071f:	48 b8 b4 31 62 41 80 	movabs $0x80416231b4,%rax
  8041600726:	00 00 00 
  8041600729:	44 8b 10             	mov    (%rax),%r10d
  804160072c:	41 0f af d2          	imul   %r10d,%edx
  8041600730:	44 8d 04 32          	lea    (%rdx,%rsi,1),%r8d
  8041600734:	41 c1 e0 03          	shl    $0x3,%r8d
  8041600738:	4c 89 ce             	mov    %r9,%rsi
  804160073b:	49 83 c1 08          	add    $0x8,%r9
  804160073f:	eb 25                	jmp    8041600766 <draw_char+0x5d>
    for (int w = 0; w < 8; w++) {
  8041600741:	83 c0 01             	add    $0x1,%eax
  8041600744:	83 f8 08             	cmp    $0x8,%eax
  8041600747:	74 11                	je     804160075a <draw_char+0x51>
      if ((p[h] >> (w)) & 1) {
  8041600749:	0f be 16             	movsbl (%rsi),%edx
  804160074c:	0f a3 c2             	bt     %eax,%edx
  804160074f:	73 f0                	jae    8041600741 <draw_char+0x38>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  8041600751:	42 8d 14 00          	lea    (%rax,%r8,1),%edx
  8041600755:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  8041600758:	eb e7                	jmp    8041600741 <draw_char+0x38>
  804160075a:	48 83 c6 01          	add    $0x1,%rsi
  804160075e:	45 01 d0             	add    %r10d,%r8d
  for (int h = 0; h < 8; h++) {
  8041600761:	4c 39 ce             	cmp    %r9,%rsi
  8041600764:	74 07                	je     804160076d <draw_char+0x64>
draw_char(uint32_t *buffer, uint32_t x, uint32_t y, uint32_t color, char charcode) {
  8041600766:	b8 00 00 00 00       	mov    $0x0,%eax
  804160076b:	eb dc                	jmp    8041600749 <draw_char+0x40>
}
  804160076d:	5d                   	pop    %rbp
  804160076e:	c3                   	retq   

000000804160076f <cons_putc>:
  __asm __volatile("inb %w1,%0"
  804160076f:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600774:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600775:	a8 20                	test   $0x20,%al
  8041600777:	75 29                	jne    80416007a2 <cons_putc+0x33>
  8041600779:	be 00 00 00 00       	mov    $0x0,%esi
  804160077e:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600783:	41 b9 fd 03 00 00    	mov    $0x3fd,%r9d
  8041600789:	89 ca                	mov    %ecx,%edx
  804160078b:	ec                   	in     (%dx),%al
  804160078c:	ec                   	in     (%dx),%al
  804160078d:	ec                   	in     (%dx),%al
  804160078e:	ec                   	in     (%dx),%al
       i++)
  804160078f:	83 c6 01             	add    $0x1,%esi
  8041600792:	44 89 ca             	mov    %r9d,%edx
  8041600795:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600796:	a8 20                	test   $0x20,%al
  8041600798:	75 08                	jne    80416007a2 <cons_putc+0x33>
  804160079a:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416007a0:	7e e7                	jle    8041600789 <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  80416007a2:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  80416007a5:	ba f8 03 00 00       	mov    $0x3f8,%edx
  80416007aa:	89 f8                	mov    %edi,%eax
  80416007ac:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416007ad:	ba 79 03 00 00       	mov    $0x379,%edx
  80416007b2:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  80416007b3:	84 c0                	test   %al,%al
  80416007b5:	78 29                	js     80416007e0 <cons_putc+0x71>
  80416007b7:	be 00 00 00 00       	mov    $0x0,%esi
  80416007bc:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416007c1:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  80416007c7:	89 ca                	mov    %ecx,%edx
  80416007c9:	ec                   	in     (%dx),%al
  80416007ca:	ec                   	in     (%dx),%al
  80416007cb:	ec                   	in     (%dx),%al
  80416007cc:	ec                   	in     (%dx),%al
  80416007cd:	83 c6 01             	add    $0x1,%esi
  80416007d0:	44 89 ca             	mov    %r9d,%edx
  80416007d3:	ec                   	in     (%dx),%al
  80416007d4:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416007da:	7f 04                	jg     80416007e0 <cons_putc+0x71>
  80416007dc:	84 c0                	test   %al,%al
  80416007de:	79 e7                	jns    80416007c7 <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416007e0:	ba 78 03 00 00       	mov    $0x378,%edx
  80416007e5:	44 89 c0             	mov    %r8d,%eax
  80416007e8:	ee                   	out    %al,(%dx)
  80416007e9:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416007ee:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416007f3:	ee                   	out    %al,(%dx)
  80416007f4:	b8 08 00 00 00       	mov    $0x8,%eax
  80416007f9:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416007fa:	48 b8 bc 31 62 41 80 	movabs $0x80416231bc,%rax
  8041600801:	00 00 00 
  8041600804:	80 38 00             	cmpb   $0x0,(%rax)
  8041600807:	0f 84 86 00 00 00    	je     8041600893 <cons_putc+0x124>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  804160080d:	55                   	push   %rbp
  804160080e:	48 89 e5             	mov    %rsp,%rbp
  8041600811:	41 54                	push   %r12
  8041600813:	53                   	push   %rbx
  if (!(c & ~0xFF))
  8041600814:	89 fa                	mov    %edi,%edx
  8041600816:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  804160081c:	89 f8                	mov    %edi,%eax
  804160081e:	80 cc 07             	or     $0x7,%ah
  8041600821:	85 d2                	test   %edx,%edx
  8041600823:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  8041600826:	40 0f b6 c7          	movzbl %dil,%eax
  804160082a:	83 f8 09             	cmp    $0x9,%eax
  804160082d:	0f 84 e5 00 00 00    	je     8041600918 <cons_putc+0x1a9>
  8041600833:	83 f8 09             	cmp    $0x9,%eax
  8041600836:	7e 5d                	jle    8041600895 <cons_putc+0x126>
  8041600838:	83 f8 0a             	cmp    $0xa,%eax
  804160083b:	0f 84 b9 00 00 00    	je     80416008fa <cons_putc+0x18b>
  8041600841:	83 f8 0d             	cmp    $0xd,%eax
  8041600844:	0f 85 00 01 00 00    	jne    804160094a <cons_putc+0x1db>
      crt_pos -= (crt_pos % crt_cols);
  804160084a:	48 be a8 31 62 41 80 	movabs $0x80416231a8,%rsi
  8041600851:	00 00 00 
  8041600854:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600857:	0f b7 c1             	movzwl %cx,%eax
  804160085a:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  8041600861:	00 00 00 
  8041600864:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600869:	f7 33                	divl   (%rbx)
  804160086b:	29 d1                	sub    %edx,%ecx
  804160086d:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  8041600870:	48 b8 a8 31 62 41 80 	movabs $0x80416231a8,%rax
  8041600877:	00 00 00 
  804160087a:	0f b7 10             	movzwl (%rax),%edx
  804160087d:	48 b8 ac 31 62 41 80 	movabs $0x80416231ac,%rax
  8041600884:	00 00 00 
  8041600887:	3b 10                	cmp    (%rax),%edx
  8041600889:	0f 83 10 01 00 00    	jae    804160099f <cons_putc+0x230>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  804160088f:	5b                   	pop    %rbx
  8041600890:	41 5c                	pop    %r12
  8041600892:	5d                   	pop    %rbp
  8041600893:	f3 c3                	repz retq 
  switch (c & 0xff) {
  8041600895:	83 f8 08             	cmp    $0x8,%eax
  8041600898:	0f 85 ac 00 00 00    	jne    804160094a <cons_putc+0x1db>
      if (crt_pos > 0) {
  804160089e:	66 a1 a8 31 62 41 80 	movabs 0x80416231a8,%ax
  80416008a5:	00 00 00 
  80416008a8:	66 85 c0             	test   %ax,%ax
  80416008ab:	74 c3                	je     8041600870 <cons_putc+0x101>
        crt_pos--;
  80416008ad:	83 e8 01             	sub    $0x1,%eax
  80416008b0:	66 a3 a8 31 62 41 80 	movabs %ax,0x80416231a8
  80416008b7:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  80416008ba:	0f b7 c0             	movzwl %ax,%eax
  80416008bd:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  80416008c4:	00 00 00 
  80416008c7:	8b 1b                	mov    (%rbx),%ebx
  80416008c9:	ba 00 00 00 00       	mov    $0x0,%edx
  80416008ce:	f7 f3                	div    %ebx
  80416008d0:	89 d6                	mov    %edx,%esi
  80416008d2:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416008d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416008dd:	89 c2                	mov    %eax,%edx
  80416008df:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416008e6:	00 00 00 
  80416008e9:	48 b8 09 07 60 41 80 	movabs $0x8041600709,%rax
  80416008f0:	00 00 00 
  80416008f3:	ff d0                	callq  *%rax
  80416008f5:	e9 76 ff ff ff       	jmpq   8041600870 <cons_putc+0x101>
      crt_pos += crt_cols;
  80416008fa:	48 b8 a8 31 62 41 80 	movabs $0x80416231a8,%rax
  8041600901:	00 00 00 
  8041600904:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  804160090b:	00 00 00 
  804160090e:	8b 13                	mov    (%rbx),%edx
  8041600910:	66 01 10             	add    %dx,(%rax)
  8041600913:	e9 32 ff ff ff       	jmpq   804160084a <cons_putc+0xdb>
      cons_putc(' ');
  8041600918:	bf 20 00 00 00       	mov    $0x20,%edi
  804160091d:	48 bb 6f 07 60 41 80 	movabs $0x804160076f,%rbx
  8041600924:	00 00 00 
  8041600927:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600929:	bf 20 00 00 00       	mov    $0x20,%edi
  804160092e:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600930:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600935:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600937:	bf 20 00 00 00       	mov    $0x20,%edi
  804160093c:	ff d3                	callq  *%rbx
      cons_putc(' ');
  804160093e:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600943:	ff d3                	callq  *%rbx
  8041600945:	e9 26 ff ff ff       	jmpq   8041600870 <cons_putc+0x101>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  804160094a:	49 bc a8 31 62 41 80 	movabs $0x80416231a8,%r12
  8041600951:	00 00 00 
  8041600954:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600959:	0f b7 c3             	movzwl %bx,%eax
  804160095c:	48 be b0 31 62 41 80 	movabs $0x80416231b0,%rsi
  8041600963:	00 00 00 
  8041600966:	8b 36                	mov    (%rsi),%esi
  8041600968:	ba 00 00 00 00       	mov    $0x0,%edx
  804160096d:	f7 f6                	div    %esi
  804160096f:	89 d6                	mov    %edx,%esi
  8041600971:	44 0f be c7          	movsbl %dil,%r8d
  8041600975:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  804160097a:	89 c2                	mov    %eax,%edx
  804160097c:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600983:	00 00 00 
  8041600986:	48 b8 09 07 60 41 80 	movabs $0x8041600709,%rax
  804160098d:	00 00 00 
  8041600990:	ff d0                	callq  *%rax
      crt_pos++;
  8041600992:	83 c3 01             	add    $0x1,%ebx
  8041600995:	66 41 89 1c 24       	mov    %bx,(%r12)
  804160099a:	e9 d1 fe ff ff       	jmpq   8041600870 <cons_putc+0x101>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  804160099f:	48 bb b4 31 62 41 80 	movabs $0x80416231b4,%rbx
  80416009a6:	00 00 00 
  80416009a9:	8b 03                	mov    (%rbx),%eax
  80416009ab:	49 bc b8 31 62 41 80 	movabs $0x80416231b8,%r12
  80416009b2:	00 00 00 
  80416009b5:	41 8b 3c 24          	mov    (%r12),%edi
  80416009b9:	8d 57 f8             	lea    -0x8(%rdi),%edx
  80416009bc:	0f af d0             	imul   %eax,%edx
  80416009bf:	48 c1 e2 02          	shl    $0x2,%rdx
  80416009c3:	c1 e0 03             	shl    $0x3,%eax
  80416009c6:	89 c0                	mov    %eax,%eax
  80416009c8:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416009cf:	00 00 00 
  80416009d2:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  80416009d6:	48 b8 b5 53 60 41 80 	movabs $0x80416053b5,%rax
  80416009dd:	00 00 00 
  80416009e0:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  80416009e2:	41 8b 0c 24          	mov    (%r12),%ecx
  80416009e6:	8b 33                	mov    (%rbx),%esi
  80416009e8:	89 ca                	mov    %ecx,%edx
  80416009ea:	83 e2 f8             	and    $0xfffffff8,%edx
  80416009ed:	83 ea 08             	sub    $0x8,%edx
  80416009f0:	0f af d6             	imul   %esi,%edx
  80416009f3:	89 d0                	mov    %edx,%eax
  80416009f5:	0f af ce             	imul   %esi,%ecx
  80416009f8:	39 d1                	cmp    %edx,%ecx
  80416009fa:	76 1b                	jbe    8041600a17 <cons_putc+0x2a8>
      crt_buf[i] = 0;
  80416009fc:	48 be 00 00 c0 3e 80 	movabs $0x803ec00000,%rsi
  8041600a03:	00 00 00 
  8041600a06:	48 63 d0             	movslq %eax,%rdx
  8041600a09:	c7 04 96 00 00 00 00 	movl   $0x0,(%rsi,%rdx,4)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600a10:	83 c0 01             	add    $0x1,%eax
  8041600a13:	39 c8                	cmp    %ecx,%eax
  8041600a15:	75 ef                	jne    8041600a06 <cons_putc+0x297>
    crt_pos -= crt_cols;
  8041600a17:	48 b8 a8 31 62 41 80 	movabs $0x80416231a8,%rax
  8041600a1e:	00 00 00 
  8041600a21:	48 bb b0 31 62 41 80 	movabs $0x80416231b0,%rbx
  8041600a28:	00 00 00 
  8041600a2b:	8b 13                	mov    (%rbx),%edx
  8041600a2d:	66 29 10             	sub    %dx,(%rax)
}
  8041600a30:	e9 5a fe ff ff       	jmpq   804160088f <cons_putc+0x120>

0000008041600a35 <serial_intr>:
  if (serial_exists)
  8041600a35:	48 b8 aa 31 62 41 80 	movabs $0x80416231aa,%rax
  8041600a3c:	00 00 00 
  8041600a3f:	80 38 00             	cmpb   $0x0,(%rax)
  8041600a42:	75 02                	jne    8041600a46 <serial_intr+0x11>
}
  8041600a44:	f3 c3                	repz retq 
serial_intr(void) {
  8041600a46:	55                   	push   %rbp
  8041600a47:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600a4a:	48 bf 48 05 60 41 80 	movabs $0x8041600548,%rdi
  8041600a51:	00 00 00 
  8041600a54:	48 b8 68 05 60 41 80 	movabs $0x8041600568,%rax
  8041600a5b:	00 00 00 
  8041600a5e:	ff d0                	callq  *%rax
}
  8041600a60:	5d                   	pop    %rbp
  8041600a61:	eb e1                	jmp    8041600a44 <serial_intr+0xf>

0000008041600a63 <fb_init>:
fb_init(void) {
  8041600a63:	55                   	push   %rbp
  8041600a64:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600a67:	48 b8 00 70 61 41 80 	movabs $0x8041617000,%rax
  8041600a6e:	00 00 00 
  8041600a71:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600a74:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600a77:	89 d0                	mov    %edx,%eax
  8041600a79:	a3 b8 31 62 41 80 00 	movabs %eax,0x80416231b8
  8041600a80:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600a82:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600a85:	a3 b4 31 62 41 80 00 	movabs %eax,0x80416231b4
  8041600a8c:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600a8e:	c1 e8 03             	shr    $0x3,%eax
  8041600a91:	89 c6                	mov    %eax,%esi
  8041600a93:	a3 b0 31 62 41 80 00 	movabs %eax,0x80416231b0
  8041600a9a:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600a9c:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600a9f:	0f af d0             	imul   %eax,%edx
  8041600aa2:	89 d0                	mov    %edx,%eax
  8041600aa4:	a3 ac 31 62 41 80 00 	movabs %eax,0x80416231ac
  8041600aab:	00 00 
  crt_pos           = crt_cols;
  8041600aad:	89 f0                	mov    %esi,%eax
  8041600aaf:	66 a3 a8 31 62 41 80 	movabs %ax,0x80416231a8
  8041600ab6:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600ab9:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600abc:	be 00 00 00 00       	mov    $0x0,%esi
  8041600ac1:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600ac8:	00 00 00 
  8041600acb:	48 b8 6c 53 60 41 80 	movabs $0x804160536c,%rax
  8041600ad2:	00 00 00 
  8041600ad5:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600ad7:	48 b8 bc 31 62 41 80 	movabs $0x80416231bc,%rax
  8041600ade:	00 00 00 
  8041600ae1:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600ae4:	5d                   	pop    %rbp
  8041600ae5:	c3                   	retq   

0000008041600ae6 <kbd_intr>:
kbd_intr(void) {
  8041600ae6:	55                   	push   %rbp
  8041600ae7:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600aea:	48 bf b5 05 60 41 80 	movabs $0x80416005b5,%rdi
  8041600af1:	00 00 00 
  8041600af4:	48 b8 68 05 60 41 80 	movabs $0x8041600568,%rax
  8041600afb:	00 00 00 
  8041600afe:	ff d0                	callq  *%rax
}
  8041600b00:	5d                   	pop    %rbp
  8041600b01:	c3                   	retq   

0000008041600b02 <cons_getc>:
cons_getc(void) {
  8041600b02:	55                   	push   %rbp
  8041600b03:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600b06:	48 b8 35 0a 60 41 80 	movabs $0x8041600a35,%rax
  8041600b0d:	00 00 00 
  8041600b10:	ff d0                	callq  *%rax
  kbd_intr();
  8041600b12:	48 b8 e6 0a 60 41 80 	movabs $0x8041600ae6,%rax
  8041600b19:	00 00 00 
  8041600b1c:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600b1e:	48 ba a0 2f 62 41 80 	movabs $0x8041622fa0,%rdx
  8041600b25:	00 00 00 
  8041600b28:	8b 82 00 02 00 00    	mov    0x200(%rdx),%eax
  8041600b2e:	3b 82 04 02 00 00    	cmp    0x204(%rdx),%eax
  8041600b34:	74 35                	je     8041600b6b <cons_getc+0x69>
    c = cons.buf[cons.rpos++];
  8041600b36:	8d 50 01             	lea    0x1(%rax),%edx
  8041600b39:	48 b9 a0 2f 62 41 80 	movabs $0x8041622fa0,%rcx
  8041600b40:	00 00 00 
  8041600b43:	89 91 00 02 00 00    	mov    %edx,0x200(%rcx)
  8041600b49:	89 c0                	mov    %eax,%eax
  8041600b4b:	0f b6 04 01          	movzbl (%rcx,%rax,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600b4f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
  8041600b55:	74 02                	je     8041600b59 <cons_getc+0x57>
}
  8041600b57:	5d                   	pop    %rbp
  8041600b58:	c3                   	retq   
      cons.rpos = 0;
  8041600b59:	48 be a0 31 62 41 80 	movabs $0x80416231a0,%rsi
  8041600b60:	00 00 00 
  8041600b63:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600b69:	eb ec                	jmp    8041600b57 <cons_getc+0x55>
  return 0;
  8041600b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600b70:	eb e5                	jmp    8041600b57 <cons_getc+0x55>

0000008041600b72 <cons_init>:
  8041600b72:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600b77:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600b7c:	89 fa                	mov    %edi,%edx
  8041600b7e:	ee                   	out    %al,(%dx)
  8041600b7f:	ba fb 03 00 00       	mov    $0x3fb,%edx
  8041600b84:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600b89:	ee                   	out    %al,(%dx)
  8041600b8a:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600b8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600b94:	89 f2                	mov    %esi,%edx
  8041600b96:	ee                   	out    %al,(%dx)
  8041600b97:	ba f9 03 00 00       	mov    $0x3f9,%edx
  8041600b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600ba1:	ee                   	out    %al,(%dx)
  8041600ba2:	ba fb 03 00 00       	mov    $0x3fb,%edx
  8041600ba7:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600bac:	ee                   	out    %al,(%dx)
  8041600bad:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600bb7:	ee                   	out    %al,(%dx)
  8041600bb8:	ba f9 03 00 00       	mov    $0x3f9,%edx
  8041600bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600bc2:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600bc3:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600bc8:	ec                   	in     (%dx),%al
  8041600bc9:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600bcb:	3c ff                	cmp    $0xff,%al
  8041600bcd:	0f 95 c0             	setne  %al
  8041600bd0:	a2 aa 31 62 41 80 00 	movabs %al,0x80416231aa
  8041600bd7:	00 00 
  8041600bd9:	89 fa                	mov    %edi,%edx
  8041600bdb:	ec                   	in     (%dx),%al
  8041600bdc:	89 f2                	mov    %esi,%edx
  8041600bde:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600bdf:	80 f9 ff             	cmp    $0xff,%cl
  8041600be2:	74 02                	je     8041600be6 <cons_init+0x74>
    cprintf("Serial port does not exist!\n");
}
  8041600be4:	f3 c3                	repz retq 
cons_init(void) {
  8041600be6:	55                   	push   %rbp
  8041600be7:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600bea:	48 bf 72 57 60 41 80 	movabs $0x8041605772,%rdi
  8041600bf1:	00 00 00 
  8041600bf4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600bf9:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041600c00:	00 00 00 
  8041600c03:	ff d2                	callq  *%rdx
}
  8041600c05:	5d                   	pop    %rbp
  8041600c06:	eb dc                	jmp    8041600be4 <cons_init+0x72>

0000008041600c08 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600c08:	55                   	push   %rbp
  8041600c09:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600c0c:	48 b8 6f 07 60 41 80 	movabs $0x804160076f,%rax
  8041600c13:	00 00 00 
  8041600c16:	ff d0                	callq  *%rax
}
  8041600c18:	5d                   	pop    %rbp
  8041600c19:	c3                   	retq   

0000008041600c1a <getchar>:

int
getchar(void) {
  8041600c1a:	55                   	push   %rbp
  8041600c1b:	48 89 e5             	mov    %rsp,%rbp
  8041600c1e:	53                   	push   %rbx
  8041600c1f:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600c23:	48 bb 02 0b 60 41 80 	movabs $0x8041600b02,%rbx
  8041600c2a:	00 00 00 
  8041600c2d:	ff d3                	callq  *%rbx
  8041600c2f:	85 c0                	test   %eax,%eax
  8041600c31:	74 fa                	je     8041600c2d <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600c33:	48 83 c4 08          	add    $0x8,%rsp
  8041600c37:	5b                   	pop    %rbx
  8041600c38:	5d                   	pop    %rbp
  8041600c39:	c3                   	retq   

0000008041600c3a <iscons>:

int
iscons(int fdnum) {
  8041600c3a:	55                   	push   %rbp
  8041600c3b:	48 89 e5             	mov    %rsp,%rbp
  // used by readline
  return 1;
}
  8041600c3e:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600c43:	5d                   	pop    %rbp
  8041600c44:	c3                   	retq   

0000008041600c45 <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600c45:	55                   	push   %rbp
  8041600c46:	48 89 e5             	mov    %rsp,%rbp
  8041600c49:	41 56                	push   %r14
  8041600c4b:	41 55                	push   %r13
  8041600c4d:	41 54                	push   %r12
  8041600c4f:	53                   	push   %rbx
  8041600c50:	48 83 ec 20          	sub    $0x20,%rsp
  8041600c54:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600c58:	83 fe 20             	cmp    $0x20,%esi
  8041600c5b:	0f 87 55 09 00 00    	ja     80416015b6 <dwarf_read_abbrev_entry+0x971>
  8041600c61:	44 89 c3             	mov    %r8d,%ebx
  8041600c64:	41 89 cd             	mov    %ecx,%r13d
  8041600c67:	49 89 d4             	mov    %rdx,%r12
  8041600c6a:	89 f6                	mov    %esi,%esi
  8041600c6c:	48 b8 78 5a 60 41 80 	movabs $0x8041605a78,%rax
  8041600c73:	00 00 00 
  8041600c76:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600c79:	48 85 d2             	test   %rdx,%rdx
  8041600c7c:	74 75                	je     8041600cf3 <dwarf_read_abbrev_entry+0xae>
  8041600c7e:	83 f9 07             	cmp    $0x7,%ecx
  8041600c81:	76 70                	jbe    8041600cf3 <dwarf_read_abbrev_entry+0xae>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600c83:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600c88:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600c8c:	4c 89 e7             	mov    %r12,%rdi
  8041600c8f:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600c96:	00 00 00 
  8041600c99:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600c9b:	eb 56                	jmp    8041600cf3 <dwarf_read_abbrev_entry+0xae>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB 2: Your code here:
      Dwarf_Half length = get_unaligned(entry, Dwarf_Half);
  8041600c9d:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600ca2:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ca6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600caa:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600cb1:	00 00 00 
  8041600cb4:	ff d0                	callq  *%rax
  8041600cb6:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Half);
  8041600cba:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600cbe:	48 83 c0 02          	add    $0x2,%rax
  8041600cc2:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600cc6:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600cca:	0f b7 c3             	movzwl %bx,%eax
  8041600ccd:	89 45 d8             	mov    %eax,-0x28(%rbp)
          .mem = entry,
          .len = length,
      };
      if (buf) {
  8041600cd0:	4d 85 e4             	test   %r12,%r12
  8041600cd3:	74 18                	je     8041600ced <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600cd5:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600cda:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600cde:	4c 89 e7             	mov    %r12,%rdi
  8041600ce1:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600ce8:	00 00 00 
  8041600ceb:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(Dwarf_Half) + length;
  8041600ced:	0f b7 db             	movzwl %bx,%ebx
  8041600cf0:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600cf3:	89 d8                	mov    %ebx,%eax
  8041600cf5:	48 83 c4 20          	add    $0x20,%rsp
  8041600cf9:	5b                   	pop    %rbx
  8041600cfa:	41 5c                	pop    %r12
  8041600cfc:	41 5d                	pop    %r13
  8041600cfe:	41 5e                	pop    %r14
  8041600d00:	5d                   	pop    %rbp
  8041600d01:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600d02:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600d07:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d0b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d0f:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600d16:	00 00 00 
  8041600d19:	ff d0                	callq  *%rax
  8041600d1b:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600d1e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600d22:	48 83 c0 04          	add    $0x4,%rax
  8041600d26:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600d2a:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600d2e:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600d31:	4d 85 e4             	test   %r12,%r12
  8041600d34:	74 18                	je     8041600d4e <dwarf_read_abbrev_entry+0x109>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600d36:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600d3b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d3f:	4c 89 e7             	mov    %r12,%rdi
  8041600d42:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600d49:	00 00 00 
  8041600d4c:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600d4e:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600d51:	eb a0                	jmp    8041600cf3 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600d53:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d58:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d5c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d60:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600d67:	00 00 00 
  8041600d6a:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600d6c:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600d71:	4d 85 e4             	test   %r12,%r12
  8041600d74:	74 06                	je     8041600d7c <dwarf_read_abbrev_entry+0x137>
  8041600d76:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600d7a:	77 0a                	ja     8041600d86 <dwarf_read_abbrev_entry+0x141>
      bytes = sizeof(Dwarf_Half);
  8041600d7c:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600d81:	e9 6d ff ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600d86:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d8b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d8f:	4c 89 e7             	mov    %r12,%rdi
  8041600d92:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600d99:	00 00 00 
  8041600d9c:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600d9e:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600da3:	e9 4b ff ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600da8:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600dad:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600db1:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600db5:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600dbc:	00 00 00 
  8041600dbf:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600dc1:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600dc6:	4d 85 e4             	test   %r12,%r12
  8041600dc9:	74 06                	je     8041600dd1 <dwarf_read_abbrev_entry+0x18c>
  8041600dcb:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600dcf:	77 0a                	ja     8041600ddb <dwarf_read_abbrev_entry+0x196>
      bytes = sizeof(uint32_t);
  8041600dd1:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600dd6:	e9 18 ff ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  8041600ddb:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600de0:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600de4:	4c 89 e7             	mov    %r12,%rdi
  8041600de7:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600dee:	00 00 00 
  8041600df1:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600df3:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600df8:	e9 f6 fe ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600dfd:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e02:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e06:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e0a:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600e11:	00 00 00 
  8041600e14:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600e16:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600e1b:	4d 85 e4             	test   %r12,%r12
  8041600e1e:	74 06                	je     8041600e26 <dwarf_read_abbrev_entry+0x1e1>
  8041600e20:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600e24:	77 0a                	ja     8041600e30 <dwarf_read_abbrev_entry+0x1eb>
      bytes = sizeof(uint64_t);
  8041600e26:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600e2b:	e9 c3 fe ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041600e30:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e35:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e39:	4c 89 e7             	mov    %r12,%rdi
  8041600e3c:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600e43:	00 00 00 
  8041600e46:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600e48:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600e4d:	e9 a1 fe ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      if (buf && bufsize >= sizeof(char *)) {
  8041600e52:	48 85 d2             	test   %rdx,%rdx
  8041600e55:	74 1d                	je     8041600e74 <dwarf_read_abbrev_entry+0x22f>
  8041600e57:	83 f9 07             	cmp    $0x7,%ecx
  8041600e5a:	76 18                	jbe    8041600e74 <dwarf_read_abbrev_entry+0x22f>
        memcpy(buf, &entry, sizeof(char *));
  8041600e5c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e61:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600e65:	4c 89 e7             	mov    %r12,%rdi
  8041600e68:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600e6f:	00 00 00 
  8041600e72:	ff d0                	callq  *%rax
      bytes = strlen(entry) + 1;
  8041600e74:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600e78:	48 b8 70 51 60 41 80 	movabs $0x8041605170,%rax
  8041600e7f:	00 00 00 
  8041600e82:	ff d0                	callq  *%rax
  8041600e84:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600e87:	e9 67 fe ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600e8c:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600e90:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600e93:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600e98:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600e9d:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600ea2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600ea5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600ea9:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600eac:	89 f0                	mov    %esi,%eax
  8041600eae:	83 e0 7f             	and    $0x7f,%eax
  8041600eb1:	d3 e0                	shl    %cl,%eax
  8041600eb3:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600eb5:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600eb8:	40 84 f6             	test   %sil,%sil
  8041600ebb:	78 e5                	js     8041600ea2 <dwarf_read_abbrev_entry+0x25d>
      break;
  }

  *ret = result;

  return count;
  8041600ebd:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600ec0:	4d 01 e8             	add    %r13,%r8
  8041600ec3:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600ec7:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600ecb:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600ece:	4d 85 e4             	test   %r12,%r12
  8041600ed1:	74 18                	je     8041600eeb <dwarf_read_abbrev_entry+0x2a6>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600ed3:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600ed8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600edc:	4c 89 e7             	mov    %r12,%rdi
  8041600edf:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600ee6:	00 00 00 
  8041600ee9:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600eeb:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600eee:	e9 00 fe ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600ef3:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600ef8:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600efc:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f00:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600f07:	00 00 00 
  8041600f0a:	ff d0                	callq  *%rax
  8041600f0c:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041600f10:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600f14:	48 83 c0 01          	add    $0x1,%rax
  8041600f18:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600f1c:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600f20:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600f23:	4d 85 e4             	test   %r12,%r12
  8041600f26:	74 18                	je     8041600f40 <dwarf_read_abbrev_entry+0x2fb>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600f28:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600f2d:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f31:	4c 89 e7             	mov    %r12,%rdi
  8041600f34:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600f3b:	00 00 00 
  8041600f3e:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041600f40:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041600f43:	e9 ab fd ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041600f48:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f4d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f51:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f55:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600f5c:	00 00 00 
  8041600f5f:	ff d0                	callq  *%rax
  8041600f61:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041600f65:	4d 85 e4             	test   %r12,%r12
  8041600f68:	0f 84 52 06 00 00    	je     80416015c0 <dwarf_read_abbrev_entry+0x97b>
  8041600f6e:	45 85 ed             	test   %r13d,%r13d
  8041600f71:	0f 84 49 06 00 00    	je     80416015c0 <dwarf_read_abbrev_entry+0x97b>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f77:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041600f7b:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f80:	e9 6e fd ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600f85:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f8a:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f8e:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f92:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041600f99:	00 00 00 
  8041600f9c:	ff d0                	callq  *%rax
  8041600f9e:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  8041600fa2:	4d 85 e4             	test   %r12,%r12
  8041600fa5:	0f 84 1f 06 00 00    	je     80416015ca <dwarf_read_abbrev_entry+0x985>
  8041600fab:	45 85 ed             	test   %r13d,%r13d
  8041600fae:	0f 84 16 06 00 00    	je     80416015ca <dwarf_read_abbrev_entry+0x985>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600fb4:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  8041600fb6:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  8041600fbb:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  8041600fc0:	e9 2e fd ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      int count = dwarf_read_leb128(entry, &data);
  8041600fc5:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600fc9:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600fcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041600fd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600fd6:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  8041600fdb:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600fde:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  8041600fe2:	89 f0                	mov    %esi,%eax
  8041600fe4:	83 e0 7f             	and    $0x7f,%eax
  8041600fe7:	d3 e0                	shl    %cl,%eax
  8041600fe9:	09 c7                	or     %eax,%edi
    shift += 7;
  8041600feb:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041600fee:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  8041600ff1:	40 84 f6             	test   %sil,%sil
  8041600ff4:	78 e5                	js     8041600fdb <dwarf_read_abbrev_entry+0x396>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  8041600ff6:	83 f9 1f             	cmp    $0x1f,%ecx
  8041600ff9:	7f 0f                	jg     804160100a <dwarf_read_abbrev_entry+0x3c5>
  8041600ffb:	40 f6 c6 40          	test   $0x40,%sil
  8041600fff:	74 09                	je     804160100a <dwarf_read_abbrev_entry+0x3c5>
    result |= (-1U << shift);
  8041601001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041601006:	d3 e0                	shl    %cl,%eax
  8041601008:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  804160100a:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  804160100d:	49 01 c0             	add    %rax,%r8
  8041601010:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  8041601014:	4d 85 e4             	test   %r12,%r12
  8041601017:	0f 84 d6 fc ff ff    	je     8041600cf3 <dwarf_read_abbrev_entry+0xae>
  804160101d:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601021:	0f 86 cc fc ff ff    	jbe    8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (int *)buf);
  8041601027:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160102a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160102f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601033:	4c 89 e7             	mov    %r12,%rdi
  8041601036:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  804160103d:	00 00 00 
  8041601040:	ff d0                	callq  *%rax
  8041601042:	e9 ac fc ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  8041601047:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160104b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601050:	4c 89 f6             	mov    %r14,%rsi
  8041601053:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601057:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  804160105e:	00 00 00 
  8041601061:	ff d0                	callq  *%rax
  8041601063:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601066:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601068:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160106d:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601070:	77 3b                	ja     80416010ad <dwarf_read_abbrev_entry+0x468>
      entry += count;
  8041601072:	48 63 c3             	movslq %ebx,%rax
  8041601075:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601079:	4d 85 e4             	test   %r12,%r12
  804160107c:	0f 84 71 fc ff ff    	je     8041600cf3 <dwarf_read_abbrev_entry+0xae>
  8041601082:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601086:	0f 86 67 fc ff ff    	jbe    8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  804160108c:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601090:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601095:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601099:	4c 89 e7             	mov    %r12,%rdi
  804160109c:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416010a3:	00 00 00 
  80416010a6:	ff d0                	callq  *%rax
  80416010a8:	e9 46 fc ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
    if (initial_len == DW_EXT_DWARF64) {
  80416010ad:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416010b0:	74 27                	je     80416010d9 <dwarf_read_abbrev_entry+0x494>
      cprintf("Unknown DWARF extension\n");
  80416010b2:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  80416010b9:	00 00 00 
  80416010bc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416010c1:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416010c8:	00 00 00 
  80416010cb:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416010cd:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416010d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416010d7:	eb 99                	jmp    8041601072 <dwarf_read_abbrev_entry+0x42d>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416010d9:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416010dd:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010e2:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416010e6:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416010ed:	00 00 00 
  80416010f0:	ff d0                	callq  *%rax
  80416010f2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416010f6:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416010fb:	e9 72 ff ff ff       	jmpq   8041601072 <dwarf_read_abbrev_entry+0x42d>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601100:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601104:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601107:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160110c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601111:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601116:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601119:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160111d:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601120:	89 f0                	mov    %esi,%eax
  8041601122:	83 e0 7f             	and    $0x7f,%eax
  8041601125:	d3 e0                	shl    %cl,%eax
  8041601127:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601129:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160112c:	40 84 f6             	test   %sil,%sil
  804160112f:	78 e5                	js     8041601116 <dwarf_read_abbrev_entry+0x4d1>
  return count;
  8041601131:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601134:	49 01 c0             	add    %rax,%r8
  8041601137:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160113b:	4d 85 e4             	test   %r12,%r12
  804160113e:	0f 84 af fb ff ff    	je     8041600cf3 <dwarf_read_abbrev_entry+0xae>
  8041601144:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601148:	0f 86 a5 fb ff ff    	jbe    8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  804160114e:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601151:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601156:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160115a:	4c 89 e7             	mov    %r12,%rdi
  804160115d:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601164:	00 00 00 
  8041601167:	ff d0                	callq  *%rax
  8041601169:	e9 85 fb ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  804160116e:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601172:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601177:	4c 89 f6             	mov    %r14,%rsi
  804160117a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160117e:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601185:	00 00 00 
  8041601188:	ff d0                	callq  *%rax
  804160118a:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160118d:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160118f:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601194:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601197:	77 3b                	ja     80416011d4 <dwarf_read_abbrev_entry+0x58f>
      entry += count;
  8041601199:	48 63 c3             	movslq %ebx,%rax
  804160119c:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416011a0:	4d 85 e4             	test   %r12,%r12
  80416011a3:	0f 84 4a fb ff ff    	je     8041600cf3 <dwarf_read_abbrev_entry+0xae>
  80416011a9:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011ad:	0f 86 40 fb ff ff    	jbe    8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  80416011b3:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416011b7:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011bc:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011c0:	4c 89 e7             	mov    %r12,%rdi
  80416011c3:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416011ca:	00 00 00 
  80416011cd:	ff d0                	callq  *%rax
  80416011cf:	e9 1f fb ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
    if (initial_len == DW_EXT_DWARF64) {
  80416011d4:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416011d7:	74 27                	je     8041601200 <dwarf_read_abbrev_entry+0x5bb>
      cprintf("Unknown DWARF extension\n");
  80416011d9:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  80416011e0:	00 00 00 
  80416011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416011e8:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416011ef:	00 00 00 
  80416011f2:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416011f4:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416011fe:	eb 99                	jmp    8041601199 <dwarf_read_abbrev_entry+0x554>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601200:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601204:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601209:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160120d:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601214:	00 00 00 
  8041601217:	ff d0                	callq  *%rax
  8041601219:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  804160121d:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601222:	e9 72 ff ff ff       	jmpq   8041601199 <dwarf_read_abbrev_entry+0x554>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601227:	ba 01 00 00 00       	mov    $0x1,%edx
  804160122c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601230:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601234:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  804160123b:	00 00 00 
  804160123e:	ff d0                	callq  *%rax
  8041601240:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601244:	4d 85 e4             	test   %r12,%r12
  8041601247:	0f 84 87 03 00 00    	je     80416015d4 <dwarf_read_abbrev_entry+0x98f>
  804160124d:	45 85 ed             	test   %r13d,%r13d
  8041601250:	0f 84 7e 03 00 00    	je     80416015d4 <dwarf_read_abbrev_entry+0x98f>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601256:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  804160125a:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  804160125f:	e9 8f fa ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041601264:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601269:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160126d:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601271:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601278:	00 00 00 
  804160127b:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  804160127d:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041601282:	4d 85 e4             	test   %r12,%r12
  8041601285:	74 06                	je     804160128d <dwarf_read_abbrev_entry+0x648>
  8041601287:	41 83 fd 01          	cmp    $0x1,%r13d
  804160128b:	77 0a                	ja     8041601297 <dwarf_read_abbrev_entry+0x652>
      bytes = sizeof(Dwarf_Half);
  804160128d:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041601292:	e9 5c fa ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041601297:	ba 02 00 00 00       	mov    $0x2,%edx
  804160129c:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012a0:	4c 89 e7             	mov    %r12,%rdi
  80416012a3:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416012aa:	00 00 00 
  80416012ad:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  80416012af:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  80416012b4:	e9 3a fa ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416012b9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012be:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416012c2:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012c6:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416012cd:	00 00 00 
  80416012d0:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416012d2:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416012d7:	4d 85 e4             	test   %r12,%r12
  80416012da:	74 06                	je     80416012e2 <dwarf_read_abbrev_entry+0x69d>
  80416012dc:	41 83 fd 03          	cmp    $0x3,%r13d
  80416012e0:	77 0a                	ja     80416012ec <dwarf_read_abbrev_entry+0x6a7>
      bytes = sizeof(uint32_t);
  80416012e2:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416012e7:	e9 07 fa ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  80416012ec:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012f1:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012f5:	4c 89 e7             	mov    %r12,%rdi
  80416012f8:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416012ff:	00 00 00 
  8041601302:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041601304:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041601309:	e9 e5 f9 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  804160130e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601313:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601317:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160131b:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601322:	00 00 00 
  8041601325:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601327:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  804160132c:	4d 85 e4             	test   %r12,%r12
  804160132f:	74 06                	je     8041601337 <dwarf_read_abbrev_entry+0x6f2>
  8041601331:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601335:	77 0a                	ja     8041601341 <dwarf_read_abbrev_entry+0x6fc>
      bytes = sizeof(uint64_t);
  8041601337:	bb 08 00 00 00       	mov    $0x8,%ebx
  804160133c:	e9 b2 f9 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041601341:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601346:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160134a:	4c 89 e7             	mov    %r12,%rdi
  804160134d:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601354:	00 00 00 
  8041601357:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601359:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  804160135e:	e9 90 f9 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601363:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601367:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  804160136a:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160136f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601374:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601379:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160137c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601380:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601383:	89 f0                	mov    %esi,%eax
  8041601385:	83 e0 7f             	and    $0x7f,%eax
  8041601388:	d3 e0                	shl    %cl,%eax
  804160138a:	09 c7                	or     %eax,%edi
    shift += 7;
  804160138c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160138f:	40 84 f6             	test   %sil,%sil
  8041601392:	78 e5                	js     8041601379 <dwarf_read_abbrev_entry+0x734>
  return count;
  8041601394:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601397:	49 01 c0             	add    %rax,%r8
  804160139a:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160139e:	4d 85 e4             	test   %r12,%r12
  80416013a1:	0f 84 4c f9 ff ff    	je     8041600cf3 <dwarf_read_abbrev_entry+0xae>
  80416013a7:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013ab:	0f 86 42 f9 ff ff    	jbe    8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  80416013b1:	89 7d d0             	mov    %edi,-0x30(%rbp)
  80416013b4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013b9:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013bd:	4c 89 e7             	mov    %r12,%rdi
  80416013c0:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416013c7:	00 00 00 
  80416013ca:	ff d0                	callq  *%rax
  80416013cc:	e9 22 f9 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &form);
  80416013d1:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416013d5:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416013d8:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416013de:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416013e3:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416013e8:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416013ec:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416013f0:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416013f4:	44 89 c0             	mov    %r8d,%eax
  80416013f7:	83 e0 7f             	and    $0x7f,%eax
  80416013fa:	d3 e0                	shl    %cl,%eax
  80416013fc:	09 c6                	or     %eax,%esi
    shift += 7;
  80416013fe:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601401:	45 84 c0             	test   %r8b,%r8b
  8041601404:	78 e2                	js     80416013e8 <dwarf_read_abbrev_entry+0x7a3>
  return count;
  8041601406:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  8041601409:	48 01 c7             	add    %rax,%rdi
  804160140c:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  8041601410:	41 89 d8             	mov    %ebx,%r8d
  8041601413:	44 89 e9             	mov    %r13d,%ecx
  8041601416:	4c 89 e2             	mov    %r12,%rdx
  8041601419:	48 b8 45 0c 60 41 80 	movabs $0x8041600c45,%rax
  8041601420:	00 00 00 
  8041601423:	ff d0                	callq  *%rax
      bytes    = count + read;
  8041601425:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601429:	e9 c5 f8 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  804160142e:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601432:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601437:	4c 89 f6             	mov    %r14,%rsi
  804160143a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160143e:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601445:	00 00 00 
  8041601448:	ff d0                	callq  *%rax
  804160144a:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160144d:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160144f:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601454:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601457:	77 3b                	ja     8041601494 <dwarf_read_abbrev_entry+0x84f>
      entry += count;
  8041601459:	48 63 c3             	movslq %ebx,%rax
  804160145c:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601460:	4d 85 e4             	test   %r12,%r12
  8041601463:	0f 84 8a f8 ff ff    	je     8041600cf3 <dwarf_read_abbrev_entry+0xae>
  8041601469:	41 83 fd 07          	cmp    $0x7,%r13d
  804160146d:	0f 86 80 f8 ff ff    	jbe    8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  8041601473:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601477:	ba 08 00 00 00       	mov    $0x8,%edx
  804160147c:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601480:	4c 89 e7             	mov    %r12,%rdi
  8041601483:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  804160148a:	00 00 00 
  804160148d:	ff d0                	callq  *%rax
  804160148f:	e9 5f f8 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
    if (initial_len == DW_EXT_DWARF64) {
  8041601494:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601497:	74 27                	je     80416014c0 <dwarf_read_abbrev_entry+0x87b>
      cprintf("Unknown DWARF extension\n");
  8041601499:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  80416014a0:	00 00 00 
  80416014a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416014a8:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416014af:	00 00 00 
  80416014b2:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416014b4:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416014b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416014be:	eb 99                	jmp    8041601459 <dwarf_read_abbrev_entry+0x814>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416014c0:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416014c4:	ba 08 00 00 00       	mov    $0x8,%edx
  80416014c9:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416014cd:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416014d4:	00 00 00 
  80416014d7:	ff d0                	callq  *%rax
  80416014d9:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416014dd:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416014e2:	e9 72 ff ff ff       	jmpq   8041601459 <dwarf_read_abbrev_entry+0x814>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416014e7:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416014eb:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416014ee:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416014f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416014fe:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601501:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601505:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041601509:	89 f8                	mov    %edi,%eax
  804160150b:	83 e0 7f             	and    $0x7f,%eax
  804160150e:	d3 e0                	shl    %cl,%eax
  8041601510:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041601512:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601515:	40 84 ff             	test   %dil,%dil
  8041601518:	78 e4                	js     80416014fe <dwarf_read_abbrev_entry+0x8b9>
  return count;
  804160151a:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  804160151d:	4c 01 f6             	add    %r14,%rsi
  8041601520:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  8041601524:	4d 85 e4             	test   %r12,%r12
  8041601527:	74 1a                	je     8041601543 <dwarf_read_abbrev_entry+0x8fe>
        memcpy(buf, entry, MIN(length, bufsize));
  8041601529:	41 39 dd             	cmp    %ebx,%r13d
  804160152c:	44 89 ea             	mov    %r13d,%edx
  804160152f:	0f 47 d3             	cmova  %ebx,%edx
  8041601532:	89 d2                	mov    %edx,%edx
  8041601534:	4c 89 e7             	mov    %r12,%rdi
  8041601537:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  804160153e:	00 00 00 
  8041601541:	ff d0                	callq  *%rax
      bytes = count + length;
  8041601543:	44 01 f3             	add    %r14d,%ebx
    } break;
  8041601546:	e9 a8 f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      if (buf && sizeof(buf) >= sizeof(bool)) {
  804160154b:	48 85 d2             	test   %rdx,%rdx
  804160154e:	0f 84 8a 00 00 00    	je     80416015de <dwarf_read_abbrev_entry+0x999>
        put_unaligned(true, (bool *)buf);
  8041601554:	c6 02 01             	movb   $0x1,(%rdx)
      bytes = 0;
  8041601557:	bb 00 00 00 00       	mov    $0x0,%ebx
        put_unaligned(true, (bool *)buf);
  804160155c:	e9 92 f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601561:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601566:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160156a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160156e:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601575:	00 00 00 
  8041601578:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  804160157a:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  804160157f:	4d 85 e4             	test   %r12,%r12
  8041601582:	74 06                	je     804160158a <dwarf_read_abbrev_entry+0x945>
  8041601584:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601588:	77 0a                	ja     8041601594 <dwarf_read_abbrev_entry+0x94f>
      bytes = sizeof(uint64_t);
  804160158a:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  804160158f:	e9 5f f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041601594:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601599:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160159d:	4c 89 e7             	mov    %r12,%rdi
  80416015a0:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416015a7:	00 00 00 
  80416015aa:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  80416015ac:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  80416015b1:	e9 3d f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
  int bytes = 0;
  80416015b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416015bb:	e9 33 f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015c0:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015c5:	e9 29 f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015ca:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015cf:	e9 1f f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015d4:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015d9:	e9 15 f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>
      bytes = 0;
  80416015de:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416015e3:	e9 0b f7 ff ff       	jmpq   8041600cf3 <dwarf_read_abbrev_entry+0xae>

00000080416015e8 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416015e8:	55                   	push   %rbp
  80416015e9:	48 89 e5             	mov    %rsp,%rbp
  80416015ec:	41 57                	push   %r15
  80416015ee:	41 56                	push   %r14
  80416015f0:	41 55                	push   %r13
  80416015f2:	41 54                	push   %r12
  80416015f4:	53                   	push   %rbx
  80416015f5:	48 83 ec 48          	sub    $0x48,%rsp
  80416015f9:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  80416015fd:	48 89 f3             	mov    %rsi,%rbx
  8041601600:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041601604:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  8041601608:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160160c:	49 bc 2e 54 60 41 80 	movabs $0x804160542e,%r12
  8041601613:	00 00 00 
  8041601616:	e9 65 01 00 00       	jmpq   8041601780 <info_by_address+0x198>
    if (initial_len == DW_EXT_DWARF64) {
  804160161b:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160161e:	74 3b                	je     804160165b <info_by_address+0x73>
      cprintf("Unknown DWARF extension\n");
  8041601620:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  8041601627:	00 00 00 
  804160162a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160162f:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041601636:	00 00 00 
  8041601639:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  804160163b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160163f:	48 8b 58 20          	mov    0x20(%rax),%rbx
  8041601643:	48 89 5d b8          	mov    %rbx,-0x48(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601647:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  804160164b:	0f 82 bc 04 00 00    	jb     8041601b0d <info_by_address+0x525>
  return 0;
  8041601651:	b8 00 00 00 00       	mov    $0x0,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
  8041601656:	e9 0a 01 00 00       	jmpq   8041601765 <info_by_address+0x17d>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160165b:	49 8d 76 20          	lea    0x20(%r14),%rsi
  804160165f:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601664:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601668:	41 ff d4             	callq  *%r12
  804160166b:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  804160166f:	ba 0c 00 00 00       	mov    $0xc,%edx
  8041601674:	e9 38 01 00 00       	jmpq   80416017b1 <info_by_address+0x1c9>
    assert(version == 2);
  8041601679:	48 b9 3e 5a 60 41 80 	movabs $0x8041605a3e,%rcx
  8041601680:	00 00 00 
  8041601683:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  804160168a:	00 00 00 
  804160168d:	be 20 00 00 00       	mov    $0x20,%esi
  8041601692:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601699:	00 00 00 
  804160169c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416016a1:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416016a8:	00 00 00 
  80416016ab:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416016ae:	48 b9 fb 59 60 41 80 	movabs $0x80416059fb,%rcx
  80416016b5:	00 00 00 
  80416016b8:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  80416016bf:	00 00 00 
  80416016c2:	be 24 00 00 00       	mov    $0x24,%esi
  80416016c7:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  80416016ce:	00 00 00 
  80416016d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416016d6:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416016dd:	00 00 00 
  80416016e0:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  80416016e3:	48 b9 0d 5a 60 41 80 	movabs $0x8041605a0d,%rcx
  80416016ea:	00 00 00 
  80416016ed:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  80416016f4:	00 00 00 
  80416016f7:	be 26 00 00 00       	mov    $0x26,%esi
  80416016fc:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601703:	00 00 00 
  8041601706:	b8 00 00 00 00       	mov    $0x0,%eax
  804160170b:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601712:	00 00 00 
  8041601715:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601718:	4d 39 fd             	cmp    %r15,%r13
  804160171b:	76 57                	jbe    8041601774 <info_by_address+0x18c>
      addr = (void *)get_unaligned(set, uintptr_t);
  804160171d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601722:	4c 89 fe             	mov    %r15,%rsi
  8041601725:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601729:	41 ff d4             	callq  *%r12
  804160172c:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      set += address_size;
  8041601730:	49 8d 77 08          	lea    0x8(%r15),%rsi
      size = get_unaligned(set, uint32_t);
  8041601734:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601739:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160173d:	41 ff d4             	callq  *%r12
  8041601740:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041601743:	49 83 c7 10          	add    $0x10,%r15
      if ((uintptr_t)addr <= p &&
  8041601747:	4c 39 f3             	cmp    %r14,%rbx
  804160174a:	72 cc                	jb     8041601718 <info_by_address+0x130>
      size = get_unaligned(set, uint32_t);
  804160174c:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  804160174e:	49 01 c6             	add    %rax,%r14
      if ((uintptr_t)addr <= p &&
  8041601751:	4c 39 f3             	cmp    %r14,%rbx
  8041601754:	77 c2                	ja     8041601718 <info_by_address+0x130>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601756:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160175a:	8b 5d a8             	mov    -0x58(%rbp),%ebx
  804160175d:	48 89 18             	mov    %rbx,(%rax)
        return 0;
  8041601760:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601765:	48 83 c4 48          	add    $0x48,%rsp
  8041601769:	5b                   	pop    %rbx
  804160176a:	41 5c                	pop    %r12
  804160176c:	41 5d                	pop    %r13
  804160176e:	41 5e                	pop    %r14
  8041601770:	41 5f                	pop    %r15
  8041601772:	5d                   	pop    %rbp
  8041601773:	c3                   	retq   
      set += address_size;
  8041601774:	4d 89 fe             	mov    %r15,%r14
    assert(set == set_end);
  8041601777:	4d 39 fd             	cmp    %r15,%r13
  804160177a:	0f 85 e1 00 00 00    	jne    8041601861 <info_by_address+0x279>
  while ((unsigned char *)set < addrs->aranges_end) {
  8041601780:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601784:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  8041601788:	0f 83 ad fe ff ff    	jae    804160163b <info_by_address+0x53>
  initial_len = get_unaligned(addr, uint32_t);
  804160178e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601793:	4c 89 f6             	mov    %r14,%rsi
  8041601796:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160179a:	41 ff d4             	callq  *%r12
  804160179d:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  80416017a0:	41 89 c5             	mov    %eax,%r13d
  count       = 4;
  80416017a3:	ba 04 00 00 00       	mov    $0x4,%edx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416017a8:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416017ab:	0f 87 6a fe ff ff    	ja     804160161b <info_by_address+0x33>
      set += count;
  80416017b1:	48 63 c2             	movslq %edx,%rax
  80416017b4:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416017b8:	4d 8d 3c 06          	lea    (%r14,%rax,1),%r15
    const void *set_end = set + len;
  80416017bc:	4d 01 fd             	add    %r15,%r13
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  80416017bf:	ba 02 00 00 00       	mov    $0x2,%edx
  80416017c4:	4c 89 fe             	mov    %r15,%rsi
  80416017c7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017cb:	41 ff d4             	callq  *%r12
    set += sizeof(Dwarf_Half);
  80416017ce:	49 83 c7 02          	add    $0x2,%r15
    assert(version == 2);
  80416017d2:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  80416017d7:	0f 85 9c fe ff ff    	jne    8041601679 <info_by_address+0x91>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  80416017dd:	ba 04 00 00 00       	mov    $0x4,%edx
  80416017e2:	4c 89 fe             	mov    %r15,%rsi
  80416017e5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017e9:	41 ff d4             	callq  *%r12
  80416017ec:	8b 45 c8             	mov    -0x38(%rbp),%eax
  80416017ef:	89 45 a8             	mov    %eax,-0x58(%rbp)
    set += count;
  80416017f2:	4c 03 7d b8          	add    -0x48(%rbp),%r15
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  80416017f6:	49 8d 47 01          	lea    0x1(%r15),%rax
  80416017fa:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416017fe:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601803:	4c 89 fe             	mov    %r15,%rsi
  8041601806:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160180a:	41 ff d4             	callq  *%r12
    assert(address_size == 8);
  804160180d:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601811:	0f 85 97 fe ff ff    	jne    80416016ae <info_by_address+0xc6>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  8041601817:	49 83 c7 02          	add    $0x2,%r15
  804160181b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601820:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041601824:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601828:	41 ff d4             	callq  *%r12
    assert(segment_size == 0);
  804160182b:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  804160182f:	0f 85 ae fe ff ff    	jne    80416016e3 <info_by_address+0xfb>
    uint32_t remainder  = (set - header) % entry_size;
  8041601835:	4c 89 f8             	mov    %r15,%rax
  8041601838:	4c 29 f0             	sub    %r14,%rax
  804160183b:	48 99                	cqto   
  804160183d:	48 c1 ea 3c          	shr    $0x3c,%rdx
  8041601841:	48 01 d0             	add    %rdx,%rax
  8041601844:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  8041601847:	48 29 d0             	sub    %rdx,%rax
  804160184a:	0f 84 cd fe ff ff    	je     804160171d <info_by_address+0x135>
      set += 2 * address_size - remainder;
  8041601850:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601855:	89 d7                	mov    %edx,%edi
  8041601857:	29 c7                	sub    %eax,%edi
  8041601859:	49 01 ff             	add    %rdi,%r15
  804160185c:	e9 bc fe ff ff       	jmpq   804160171d <info_by_address+0x135>
    assert(set == set_end);
  8041601861:	48 b9 1f 5a 60 41 80 	movabs $0x8041605a1f,%rcx
  8041601868:	00 00 00 
  804160186b:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601872:	00 00 00 
  8041601875:	be 3a 00 00 00       	mov    $0x3a,%esi
  804160187a:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601881:	00 00 00 
  8041601884:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601889:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601890:	00 00 00 
  8041601893:	41 ff d0             	callq  *%r8
    if (initial_len == DW_EXT_DWARF64) {
  8041601896:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601899:	74 25                	je     80416018c0 <info_by_address+0x2d8>
      cprintf("Unknown DWARF extension\n");
  804160189b:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  80416018a2:	00 00 00 
  80416018a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018aa:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416018b1:	00 00 00 
  80416018b4:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  80416018b6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416018bb:	e9 a5 fe ff ff       	jmpq   8041601765 <info_by_address+0x17d>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416018c0:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018c4:	48 8d 70 20          	lea    0x20(%rax),%rsi
  80416018c8:	ba 08 00 00 00       	mov    $0x8,%edx
  80416018cd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018d1:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416018d8:	00 00 00 
  80416018db:	ff d0                	callq  *%rax
  80416018dd:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
      count = 12;
  80416018e1:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  80416018e7:	e9 4e 02 00 00       	jmpq   8041601b3a <info_by_address+0x552>
    assert(version == 4 || version == 2);
  80416018ec:	48 b9 2e 5a 60 41 80 	movabs $0x8041605a2e,%rcx
  80416018f3:	00 00 00 
  80416018f6:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  80416018fd:	00 00 00 
  8041601900:	be 40 01 00 00       	mov    $0x140,%esi
  8041601905:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  804160190c:	00 00 00 
  804160190f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601914:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  804160191b:	00 00 00 
  804160191e:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601921:	48 b9 fb 59 60 41 80 	movabs $0x80416059fb,%rcx
  8041601928:	00 00 00 
  804160192b:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601932:	00 00 00 
  8041601935:	be 44 01 00 00       	mov    $0x144,%esi
  804160193a:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601941:	00 00 00 
  8041601944:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601949:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601950:	00 00 00 
  8041601953:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601956:	48 b9 4b 5a 60 41 80 	movabs $0x8041605a4b,%rcx
  804160195d:	00 00 00 
  8041601960:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601967:	00 00 00 
  804160196a:	be 49 01 00 00       	mov    $0x149,%esi
  804160196f:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601976:	00 00 00 
  8041601979:	b8 00 00 00 00       	mov    $0x0,%eax
  804160197e:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601985:	00 00 00 
  8041601988:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  804160198b:	48 b9 80 5b 60 41 80 	movabs $0x8041605b80,%rcx
  8041601992:	00 00 00 
  8041601995:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  804160199c:	00 00 00 
  804160199f:	be 51 01 00 00       	mov    $0x151,%esi
  80416019a4:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  80416019ab:	00 00 00 
  80416019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416019b3:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416019ba:	00 00 00 
  80416019bd:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  80416019c0:	48 b9 5c 5a 60 41 80 	movabs $0x8041605a5c,%rcx
  80416019c7:	00 00 00 
  80416019ca:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  80416019d1:	00 00 00 
  80416019d4:	be 55 01 00 00       	mov    $0x155,%esi
  80416019d9:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  80416019e0:	00 00 00 
  80416019e3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416019e8:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416019ef:	00 00 00 
  80416019f2:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  80416019f5:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416019fb:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601a00:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601a04:	44 89 ee             	mov    %r13d,%esi
  8041601a07:	4c 89 f7             	mov    %r14,%rdi
  8041601a0a:	41 ff d7             	callq  *%r15
  8041601a0d:	eb 2a                	jmp    8041601a39 <info_by_address+0x451>
        count = dwarf_read_abbrev_entry(
  8041601a0f:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601a15:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601a1a:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601a1e:	44 89 ee             	mov    %r13d,%esi
  8041601a21:	4c 89 f7             	mov    %r14,%rdi
  8041601a24:	41 ff d7             	callq  *%r15
        if (form != DW_FORM_addr) {
  8041601a27:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601a2b:	0f 84 96 02 00 00    	je     8041601cc7 <info_by_address+0x6df>
          high_pc += low_pc;
  8041601a31:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601a35:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
      entry += count;
  8041601a39:	48 98                	cltq   
  8041601a3b:	49 01 c6             	add    %rax,%r14
    } while (name != 0 || form != 0);
  8041601a3e:	45 09 ec             	or     %r13d,%r12d
  8041601a41:	0f 84 9c 00 00 00    	je     8041601ae3 <info_by_address+0x4fb>
    assert(table_abbrev_code == abbrev_code);
  8041601a47:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601a4a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601a4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a54:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601a5a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601a5d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601a61:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601a64:	89 f0                	mov    %esi,%eax
  8041601a66:	83 e0 7f             	and    $0x7f,%eax
  8041601a69:	d3 e0                	shl    %cl,%eax
  8041601a6b:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601a6e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a71:	40 84 f6             	test   %sil,%sil
  8041601a74:	78 e4                	js     8041601a5a <info_by_address+0x472>
  return count;
  8041601a76:	48 63 ff             	movslq %edi,%rdi
      abbrev_entry += count;
  8041601a79:	48 01 fb             	add    %rdi,%rbx
  8041601a7c:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601a84:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a89:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601a8f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601a92:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601a96:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601a99:	89 f0                	mov    %esi,%eax
  8041601a9b:	83 e0 7f             	and    $0x7f,%eax
  8041601a9e:	d3 e0                	shl    %cl,%eax
  8041601aa0:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601aa3:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601aa6:	40 84 f6             	test   %sil,%sil
  8041601aa9:	78 e4                	js     8041601a8f <info_by_address+0x4a7>
  return count;
  8041601aab:	48 63 ff             	movslq %edi,%rdi
      abbrev_entry += count;
  8041601aae:	48 01 fb             	add    %rdi,%rbx
      if (name == DW_AT_low_pc) {
  8041601ab1:	41 83 fc 11          	cmp    $0x11,%r12d
  8041601ab5:	0f 84 3a ff ff ff    	je     80416019f5 <info_by_address+0x40d>
      } else if (name == DW_AT_high_pc) {
  8041601abb:	41 83 fc 12          	cmp    $0x12,%r12d
  8041601abf:	0f 84 4a ff ff ff    	je     8041601a0f <info_by_address+0x427>
        count = dwarf_read_abbrev_entry(
  8041601ac5:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601acb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601ad5:	44 89 ee             	mov    %r13d,%esi
  8041601ad8:	4c 89 f7             	mov    %r14,%rdi
  8041601adb:	41 ff d7             	callq  *%r15
  8041601ade:	e9 56 ff ff ff       	jmpq   8041601a39 <info_by_address+0x451>
    if (p >= low_pc && p <= high_pc) {
  8041601ae3:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601ae7:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601aeb:	72 0a                	jb     8041601af7 <info_by_address+0x50f>
  8041601aed:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601af1:	0f 86 a9 01 00 00    	jbe    8041601ca0 <info_by_address+0x6b8>
    entry = entry_end;
  8041601af7:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601afb:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601aff:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041601b03:	48 3b 43 28          	cmp    0x28(%rbx),%rax
  8041601b07:	0f 83 b0 01 00 00    	jae    8041601cbd <info_by_address+0x6d5>
  initial_len = get_unaligned(addr, uint32_t);
  8041601b0d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601b12:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041601b16:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601b1a:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601b21:	00 00 00 
  8041601b24:	ff d0                	callq  *%rax
  8041601b26:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  8041601b29:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601b2b:	41 bd 04 00 00 00    	mov    $0x4,%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601b31:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601b34:	0f 87 5c fd ff ff    	ja     8041601896 <info_by_address+0x2ae>
      entry += count;
  8041601b3a:	4d 63 ed             	movslq %r13d,%r13
  8041601b3d:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601b41:	4a 8d 1c 28          	lea    (%rax,%r13,1),%rbx
    const void *entry_end = entry + len;
  8041601b45:	48 8d 04 13          	lea    (%rbx,%rdx,1),%rax
  8041601b49:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601b4d:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601b52:	48 89 de             	mov    %rbx,%rsi
  8041601b55:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601b59:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601b60:	00 00 00 
  8041601b63:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041601b65:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  8041601b69:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601b6d:	83 e8 02             	sub    $0x2,%eax
  8041601b70:	66 a9 fd ff          	test   $0xfffd,%ax
  8041601b74:	0f 85 72 fd ff ff    	jne    80416018ec <info_by_address+0x304>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601b7a:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601b7f:	48 89 de             	mov    %rbx,%rsi
  8041601b82:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601b86:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601b8d:	00 00 00 
  8041601b90:	ff d0                	callq  *%rax
  8041601b92:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041601b96:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041601b9a:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041601b9e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601ba3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601ba7:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601bae:	00 00 00 
  8041601bb1:	ff d0                	callq  *%rax
    assert(address_size == 8);
  8041601bb3:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601bb7:	0f 85 64 fd ff ff    	jne    8041601921 <info_by_address+0x339>
  8041601bbd:	4c 89 f2             	mov    %r14,%rdx
  8041601bc0:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601bc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601bca:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601bd0:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601bd3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601bd7:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601bda:	89 f0                	mov    %esi,%eax
  8041601bdc:	83 e0 7f             	and    $0x7f,%eax
  8041601bdf:	d3 e0                	shl    %cl,%eax
  8041601be1:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601be4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601be7:	40 84 f6             	test   %sil,%sil
  8041601bea:	78 e4                	js     8041601bd0 <info_by_address+0x5e8>
  return count;
  8041601bec:	48 63 ff             	movslq %edi,%rdi
    assert(abbrev_code != 0);
  8041601bef:	45 85 c0             	test   %r8d,%r8d
  8041601bf2:	0f 84 5e fd ff ff    	je     8041601956 <info_by_address+0x36e>
    entry += count;
  8041601bf8:	49 01 fe             	add    %rdi,%r14
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601bfb:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601bff:	4c 03 20             	add    (%rax),%r12
  8041601c02:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041601c05:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601c0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c0f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041601c15:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601c18:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c1c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601c1f:	89 f0                	mov    %esi,%eax
  8041601c21:	83 e0 7f             	and    $0x7f,%eax
  8041601c24:	d3 e0                	shl    %cl,%eax
  8041601c26:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041601c29:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c2c:	40 84 f6             	test   %sil,%sil
  8041601c2f:	78 e4                	js     8041601c15 <info_by_address+0x62d>
  return count;
  8041601c31:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601c34:	49 01 fc             	add    %rdi,%r12
    assert(table_abbrev_code == abbrev_code);
  8041601c37:	45 39 c8             	cmp    %r9d,%r8d
  8041601c3a:	0f 85 4b fd ff ff    	jne    804160198b <info_by_address+0x3a3>
  8041601c40:	4c 89 e2             	mov    %r12,%rdx
  8041601c43:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601c48:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c4d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601c53:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601c56:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c5a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601c5d:	89 f0                	mov    %esi,%eax
  8041601c5f:	83 e0 7f             	and    $0x7f,%eax
  8041601c62:	d3 e0                	shl    %cl,%eax
  8041601c64:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601c67:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c6a:	40 84 f6             	test   %sil,%sil
  8041601c6d:	78 e4                	js     8041601c53 <info_by_address+0x66b>
  return count;
  8041601c6f:	48 63 ff             	movslq %edi,%rdi
    assert(tag == DW_TAG_compile_unit);
  8041601c72:	41 83 f8 11          	cmp    $0x11,%r8d
  8041601c76:	0f 85 44 fd ff ff    	jne    80416019c0 <info_by_address+0x3d8>
    abbrev_entry++;
  8041601c7c:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601c81:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601c88:	00 
  8041601c89:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601c90:	00 
        count = dwarf_read_abbrev_entry(
  8041601c91:	49 bf 45 0c 60 41 80 	movabs $0x8041600c45,%r15
  8041601c98:	00 00 00 
  8041601c9b:	e9 a7 fd ff ff       	jmpq   8041601a47 <info_by_address+0x45f>
          (const unsigned char *)header - addrs->info_begin;
  8041601ca0:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041601ca4:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601ca8:	48 2b 43 20          	sub    0x20(%rbx),%rax
      *store =
  8041601cac:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041601cb0:	48 89 03             	mov    %rax,(%rbx)
      return 0;
  8041601cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cb8:	e9 a8 fa ff ff       	jmpq   8041601765 <info_by_address+0x17d>
  return 0;
  8041601cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cc2:	e9 9e fa ff ff       	jmpq   8041601765 <info_by_address+0x17d>
      entry += count;
  8041601cc7:	48 98                	cltq   
  8041601cc9:	49 01 c6             	add    %rax,%r14
  8041601ccc:	e9 76 fd ff ff       	jmpq   8041601a47 <info_by_address+0x45f>

0000008041601cd1 <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601cd1:	55                   	push   %rbp
  8041601cd2:	48 89 e5             	mov    %rsp,%rbp
  8041601cd5:	41 57                	push   %r15
  8041601cd7:	41 56                	push   %r14
  8041601cd9:	41 55                	push   %r13
  8041601cdb:	41 54                	push   %r12
  8041601cdd:	53                   	push   %rbx
  8041601cde:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601ce2:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601ce6:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601cea:	48 29 d8             	sub    %rbx,%rax
  8041601ced:	48 39 f0             	cmp    %rsi,%rax
  8041601cf0:	0f 82 35 04 00 00    	jb     804160212b <file_name_by_info+0x45a>
  8041601cf6:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601cfa:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601cfd:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601d01:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601d05:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601d08:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601d0d:	48 89 de             	mov    %rbx,%rsi
  8041601d10:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d14:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601d1b:	00 00 00 
  8041601d1e:	ff d0                	callq  *%rax
  8041601d20:	8b 45 c8             	mov    -0x38(%rbp),%eax
  count       = 4;
  8041601d23:	41 bc 04 00 00 00    	mov    $0x4,%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601d29:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601d2c:	0f 87 41 01 00 00    	ja     8041601e73 <file_name_by_info+0x1a2>
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    entry += count;
  8041601d32:	4d 63 e4             	movslq %r12d,%r12
  8041601d35:	4c 01 e3             	add    %r12,%rbx
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601d38:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601d3d:	48 89 de             	mov    %rbx,%rsi
  8041601d40:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d44:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601d4b:	00 00 00 
  8041601d4e:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  8041601d50:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  8041601d54:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601d58:	83 e8 02             	sub    $0x2,%eax
  8041601d5b:	66 a9 fd ff          	test   $0xfffd,%ax
  8041601d5f:	0f 85 5c 01 00 00    	jne    8041601ec1 <file_name_by_info+0x1f0>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601d65:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601d6a:	48 89 de             	mov    %rbx,%rsi
  8041601d6d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d71:	49 bf 2e 54 60 41 80 	movabs $0x804160542e,%r15
  8041601d78:	00 00 00 
  8041601d7b:	41 ff d7             	callq  *%r15
  8041601d7e:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  8041601d82:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041601d86:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041601d8a:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601d8f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d93:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  8041601d96:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601d9a:	0f 85 56 01 00 00    	jne    8041601ef6 <file_name_by_info+0x225>
  8041601da0:	4c 89 f2             	mov    %r14,%rdx
  8041601da3:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601da8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601dad:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601db3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601db6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601dba:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601dbd:	89 f0                	mov    %esi,%eax
  8041601dbf:	83 e0 7f             	and    $0x7f,%eax
  8041601dc2:	d3 e0                	shl    %cl,%eax
  8041601dc4:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601dc7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601dca:	40 84 f6             	test   %sil,%sil
  8041601dcd:	78 e4                	js     8041601db3 <file_name_by_info+0xe2>
  return count;
  8041601dcf:	48 63 ff             	movslq %edi,%rdi

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601dd2:	45 85 c0             	test   %r8d,%r8d
  8041601dd5:	0f 84 50 01 00 00    	je     8041601f2b <file_name_by_info+0x25a>
  entry += count;
  8041601ddb:	49 01 fe             	add    %rdi,%r14

  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601dde:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601de2:	4c 03 28             	add    (%rax),%r13
  8041601de5:	4c 89 ea             	mov    %r13,%rdx
  count  = 0;
  8041601de8:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601ded:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601df2:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041601df8:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601dfb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601dff:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601e02:	89 f0                	mov    %esi,%eax
  8041601e04:	83 e0 7f             	and    $0x7f,%eax
  8041601e07:	d3 e0                	shl    %cl,%eax
  8041601e09:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041601e0c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601e0f:	40 84 f6             	test   %sil,%sil
  8041601e12:	78 e4                	js     8041601df8 <file_name_by_info+0x127>
  return count;
  8041601e14:	48 63 ff             	movslq %edi,%rdi
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  8041601e17:	49 01 fd             	add    %rdi,%r13
  assert(table_abbrev_code == abbrev_code);
  8041601e1a:	45 39 c8             	cmp    %r9d,%r8d
  8041601e1d:	0f 85 3d 01 00 00    	jne    8041601f60 <file_name_by_info+0x28f>
  8041601e23:	4c 89 ea             	mov    %r13,%rdx
  8041601e26:	bf 00 00 00 00       	mov    $0x0,%edi
  8041601e2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601e30:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041601e36:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601e39:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601e3d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601e40:	89 f0                	mov    %esi,%eax
  8041601e42:	83 e0 7f             	and    $0x7f,%eax
  8041601e45:	d3 e0                	shl    %cl,%eax
  8041601e47:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041601e4a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601e4d:	40 84 f6             	test   %sil,%sil
  8041601e50:	78 e4                	js     8041601e36 <file_name_by_info+0x165>
  return count;
  8041601e52:	48 63 ff             	movslq %edi,%rdi
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601e55:	41 83 f8 11          	cmp    $0x11,%r8d
  8041601e59:	0f 85 36 01 00 00    	jne    8041601f95 <file_name_by_info+0x2c4>
  abbrev_entry++;
  8041601e5f:	49 8d 5c 3d 01       	lea    0x1(%r13,%rdi,1),%rbx
    } else if (name == DW_AT_stmt_list) {
      count = dwarf_read_abbrev_entry(entry, form, line_off,
                                      sizeof(Dwarf_Off),
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601e64:	49 bf 45 0c 60 41 80 	movabs $0x8041600c45,%r15
  8041601e6b:	00 00 00 
  8041601e6e:	e9 85 01 00 00       	jmpq   8041601ff8 <file_name_by_info+0x327>
    if (initial_len == DW_EXT_DWARF64) {
  8041601e73:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601e76:	74 25                	je     8041601e9d <file_name_by_info+0x1cc>
      cprintf("Unknown DWARF extension\n");
  8041601e78:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  8041601e7f:	00 00 00 
  8041601e82:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e87:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041601e8e:	00 00 00 
  8041601e91:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  8041601e93:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601e98:	e9 7f 02 00 00       	jmpq   804160211c <file_name_by_info+0x44b>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601e9d:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601ea1:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601ea6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601eaa:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041601eb1:	00 00 00 
  8041601eb4:	ff d0                	callq  *%rax
      count = 12;
  8041601eb6:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601ebc:	e9 71 fe ff ff       	jmpq   8041601d32 <file_name_by_info+0x61>
  assert(version == 4 || version == 2);
  8041601ec1:	48 b9 2e 5a 60 41 80 	movabs $0x8041605a2e,%rcx
  8041601ec8:	00 00 00 
  8041601ecb:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601ed2:	00 00 00 
  8041601ed5:	be 98 01 00 00       	mov    $0x198,%esi
  8041601eda:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601ee1:	00 00 00 
  8041601ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ee9:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601ef0:	00 00 00 
  8041601ef3:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  8041601ef6:	48 b9 fb 59 60 41 80 	movabs $0x80416059fb,%rcx
  8041601efd:	00 00 00 
  8041601f00:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601f07:	00 00 00 
  8041601f0a:	be 9c 01 00 00       	mov    $0x19c,%esi
  8041601f0f:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601f16:	00 00 00 
  8041601f19:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f1e:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601f25:	00 00 00 
  8041601f28:	41 ff d0             	callq  *%r8
  assert(abbrev_code != 0);
  8041601f2b:	48 b9 4b 5a 60 41 80 	movabs $0x8041605a4b,%rcx
  8041601f32:	00 00 00 
  8041601f35:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601f3c:	00 00 00 
  8041601f3f:	be a1 01 00 00       	mov    $0x1a1,%esi
  8041601f44:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601f4b:	00 00 00 
  8041601f4e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f53:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601f5a:	00 00 00 
  8041601f5d:	41 ff d0             	callq  *%r8
  assert(table_abbrev_code == abbrev_code);
  8041601f60:	48 b9 80 5b 60 41 80 	movabs $0x8041605b80,%rcx
  8041601f67:	00 00 00 
  8041601f6a:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601f71:	00 00 00 
  8041601f74:	be a9 01 00 00       	mov    $0x1a9,%esi
  8041601f79:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601f80:	00 00 00 
  8041601f83:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f88:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601f8f:	00 00 00 
  8041601f92:	41 ff d0             	callq  *%r8
  assert(tag == DW_TAG_compile_unit);
  8041601f95:	48 b9 5c 5a 60 41 80 	movabs $0x8041605a5c,%rcx
  8041601f9c:	00 00 00 
  8041601f9f:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041601fa6:	00 00 00 
  8041601fa9:	be ad 01 00 00       	mov    $0x1ad,%esi
  8041601fae:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041601fb5:	00 00 00 
  8041601fb8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601fbd:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041601fc4:	00 00 00 
  8041601fc7:	41 ff d0             	callq  *%r8
      if (form == DW_FORM_strp) {
  8041601fca:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601fce:	0f 84 c0 00 00 00    	je     8041602094 <file_name_by_info+0x3c3>
        count = dwarf_read_abbrev_entry(
  8041601fd4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601fda:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601fdd:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601fe1:	44 89 ee             	mov    %r13d,%esi
  8041601fe4:	4c 89 f7             	mov    %r14,%rdi
  8041601fe7:	41 ff d7             	callq  *%r15
                                      address_size);
    }
    entry += count;
  8041601fea:	48 98                	cltq   
  8041601fec:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601fef:	45 09 e5             	or     %r12d,%r13d
  8041601ff2:	0f 84 1f 01 00 00    	je     8041602117 <file_name_by_info+0x446>
  8041601ff8:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601ffb:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602000:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602005:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  804160200b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160200e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602012:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602015:	89 f0                	mov    %esi,%eax
  8041602017:	83 e0 7f             	and    $0x7f,%eax
  804160201a:	d3 e0                	shl    %cl,%eax
  804160201c:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160201f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602022:	40 84 f6             	test   %sil,%sil
  8041602025:	78 e4                	js     804160200b <file_name_by_info+0x33a>
  return count;
  8041602027:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  804160202a:	48 01 fb             	add    %rdi,%rbx
  804160202d:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602030:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602035:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160203a:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602040:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602043:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602047:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160204a:	89 f0                	mov    %esi,%eax
  804160204c:	83 e0 7f             	and    $0x7f,%eax
  804160204f:	d3 e0                	shl    %cl,%eax
  8041602051:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602054:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602057:	40 84 f6             	test   %sil,%sil
  804160205a:	78 e4                	js     8041602040 <file_name_by_info+0x36f>
  return count;
  804160205c:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  804160205f:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041602062:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602066:	0f 84 5e ff ff ff    	je     8041601fca <file_name_by_info+0x2f9>
    } else if (name == DW_AT_stmt_list) {
  804160206c:	41 83 fc 10          	cmp    $0x10,%r12d
  8041602070:	0f 84 84 00 00 00    	je     80416020fa <file_name_by_info+0x429>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041602076:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160207c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602081:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602086:	44 89 ee             	mov    %r13d,%esi
  8041602089:	4c 89 f7             	mov    %r14,%rdi
  804160208c:	41 ff d7             	callq  *%r15
  804160208f:	e9 56 ff ff ff       	jmpq   8041601fea <file_name_by_info+0x319>
        unsigned long offset = 0;
  8041602094:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160209b:	00 
        count                = dwarf_read_abbrev_entry(
  804160209c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416020a2:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416020a7:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  80416020ab:	be 0e 00 00 00       	mov    $0xe,%esi
  80416020b0:	4c 89 f7             	mov    %r14,%rdi
  80416020b3:	41 ff d7             	callq  *%r15
  80416020b6:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  80416020b9:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  80416020bd:	48 85 ff             	test   %rdi,%rdi
  80416020c0:	74 06                	je     80416020c8 <file_name_by_info+0x3f7>
  80416020c2:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  80416020c6:	77 0b                	ja     80416020d3 <file_name_by_info+0x402>
    entry += count;
  80416020c8:	4d 63 e4             	movslq %r12d,%r12
  80416020cb:	4d 01 e6             	add    %r12,%r14
  80416020ce:	e9 25 ff ff ff       	jmpq   8041601ff8 <file_name_by_info+0x327>
          put_unaligned(
  80416020d3:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416020d7:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  80416020db:	48 03 41 40          	add    0x40(%rcx),%rax
  80416020df:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  80416020e3:	ba 08 00 00 00       	mov    $0x8,%edx
  80416020e8:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  80416020ec:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416020f3:	00 00 00 
  80416020f6:	ff d0                	callq  *%rax
  80416020f8:	eb ce                	jmp    80416020c8 <file_name_by_info+0x3f7>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  80416020fa:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602100:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602105:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041602109:	44 89 ee             	mov    %r13d,%esi
  804160210c:	4c 89 f7             	mov    %r14,%rdi
  804160210f:	41 ff d7             	callq  *%r15
  8041602112:	e9 d3 fe ff ff       	jmpq   8041601fea <file_name_by_info+0x319>

  return 0;
  8041602117:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160211c:	48 83 c4 38          	add    $0x38,%rsp
  8041602120:	5b                   	pop    %rbx
  8041602121:	41 5c                	pop    %r12
  8041602123:	41 5d                	pop    %r13
  8041602125:	41 5e                	pop    %r14
  8041602127:	41 5f                	pop    %r15
  8041602129:	5d                   	pop    %rbp
  804160212a:	c3                   	retq   
    return -E_INVAL;
  804160212b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041602130:	eb ea                	jmp    804160211c <file_name_by_info+0x44b>

0000008041602132 <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  8041602132:	55                   	push   %rbp
  8041602133:	48 89 e5             	mov    %rsp,%rbp
  8041602136:	41 57                	push   %r15
  8041602138:	41 56                	push   %r14
  804160213a:	41 55                	push   %r13
  804160213c:	41 54                	push   %r12
  804160213e:	53                   	push   %rbx
  804160213f:	48 83 ec 68          	sub    $0x68,%rsp
  8041602143:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  8041602147:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  804160214e:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  8041602152:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  8041602156:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  804160215d:	48 89 d3             	mov    %rdx,%rbx
  8041602160:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602164:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602169:	48 89 de             	mov    %rbx,%rsi
  804160216c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602170:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041602177:	00 00 00 
  804160217a:	ff d0                	callq  *%rax
  804160217c:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  804160217f:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041602181:	41 be 04 00 00 00    	mov    $0x4,%r14d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602187:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160218a:	76 2c                	jbe    80416021b8 <function_by_info+0x86>
    if (initial_len == DW_EXT_DWARF64) {
  804160218c:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160218f:	0f 85 8f 00 00 00    	jne    8041602224 <function_by_info+0xf2>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602195:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041602199:	ba 08 00 00 00       	mov    $0x8,%edx
  804160219e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021a2:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416021a9:	00 00 00 
  80416021ac:	ff d0                	callq  *%rax
  80416021ae:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
      count = 12;
  80416021b2:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  }
  entry += count;
  80416021b8:	4d 63 f6             	movslq %r14d,%r14
  80416021bb:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  80416021be:	48 8d 04 13          	lea    (%rbx,%rdx,1),%rax
  80416021c2:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416021c6:	ba 02 00 00 00       	mov    $0x2,%edx
  80416021cb:	48 89 de             	mov    %rbx,%rsi
  80416021ce:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021d2:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416021d9:	00 00 00 
  80416021dc:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416021de:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416021e2:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416021e6:	83 e8 02             	sub    $0x2,%eax
  80416021e9:	66 a9 fd ff          	test   $0xfffd,%ax
  80416021ed:	74 64                	je     8041602253 <function_by_info+0x121>
  80416021ef:	48 b9 2e 5a 60 41 80 	movabs $0x8041605a2e,%rcx
  80416021f6:	00 00 00 
  80416021f9:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041602200:	00 00 00 
  8041602203:	be e6 01 00 00       	mov    $0x1e6,%esi
  8041602208:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  804160220f:	00 00 00 
  8041602212:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602217:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  804160221e:	00 00 00 
  8041602221:	41 ff d0             	callq  *%r8
      cprintf("Unknown DWARF extension\n");
  8041602224:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  804160222b:	00 00 00 
  804160222e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602233:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  804160223a:	00 00 00 
  804160223d:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  804160223f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602244:	48 83 c4 68          	add    $0x68,%rsp
  8041602248:	5b                   	pop    %rbx
  8041602249:	41 5c                	pop    %r12
  804160224b:	41 5d                	pop    %r13
  804160224d:	41 5e                	pop    %r14
  804160224f:	41 5f                	pop    %r15
  8041602251:	5d                   	pop    %rbp
  8041602252:	c3                   	retq   
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602253:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602258:	48 89 de             	mov    %rbx,%rsi
  804160225b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160225f:	49 bc 2e 54 60 41 80 	movabs $0x804160542e,%r12
  8041602266:	00 00 00 
  8041602269:	41 ff d4             	callq  *%r12
  804160226c:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  8041602270:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602274:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602278:	ba 01 00 00 00       	mov    $0x1,%edx
  804160227d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602281:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  8041602284:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602288:	74 35                	je     80416022bf <function_by_info+0x18d>
  804160228a:	48 b9 fb 59 60 41 80 	movabs $0x80416059fb,%rcx
  8041602291:	00 00 00 
  8041602294:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  804160229b:	00 00 00 
  804160229e:	be ea 01 00 00       	mov    $0x1ea,%esi
  80416022a3:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  80416022aa:	00 00 00 
  80416022ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80416022b2:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416022b9:	00 00 00 
  80416022bc:	41 ff d0             	callq  *%r8
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  80416022bf:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416022c3:	4c 03 28             	add    (%rax),%r13
  80416022c6:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  80416022ca:	49 bf 45 0c 60 41 80 	movabs $0x8041600c45,%r15
  80416022d1:	00 00 00 
  while (entry < entry_end) {
  80416022d4:	e9 8a 01 00 00       	jmpq   8041602463 <function_by_info+0x331>
  result = 0;
  80416022d9:	48 89 d6             	mov    %rdx,%rsi
  count  = 0;
  80416022dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416022e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416022e6:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  80416022ec:	0f b6 3e             	movzbl (%rsi),%edi
    addr++;
  80416022ef:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  80416022f3:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  80416022f6:	89 f8                	mov    %edi,%eax
  80416022f8:	83 e0 7f             	and    $0x7f,%eax
  80416022fb:	d3 e0                	shl    %cl,%eax
  80416022fd:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602300:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602303:	40 84 ff             	test   %dil,%dil
  8041602306:	78 e4                	js     80416022ec <function_by_info+0x1ba>
  return count;
  8041602308:	48 63 db             	movslq %ebx,%rbx
        curr_abbrev_entry += count;
  804160230b:	48 01 d3             	add    %rdx,%rbx
  804160230e:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602311:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602316:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160231b:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602321:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602324:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602328:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160232b:	89 f0                	mov    %esi,%eax
  804160232d:	83 e0 7f             	and    $0x7f,%eax
  8041602330:	d3 e0                	shl    %cl,%eax
  8041602332:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602335:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602338:	40 84 f6             	test   %sil,%sil
  804160233b:	78 e4                	js     8041602321 <function_by_info+0x1ef>
  return count;
  804160233d:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602340:	48 8d 14 3b          	lea    (%rbx,%rdi,1),%rdx
      } while (name != 0 || form != 0);
  8041602344:	45 09 dc             	or     %r11d,%r12d
  8041602347:	75 90                	jne    80416022d9 <function_by_info+0x1a7>
    while ((const unsigned char *)curr_abbrev_entry <
  8041602349:	4c 39 d2             	cmp    %r10,%rdx
  804160234c:	73 77                	jae    80416023c5 <function_by_info+0x293>
  804160234e:	48 89 d7             	mov    %rdx,%rdi
  8041602351:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  8041602357:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160235c:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602361:	44 0f b6 07          	movzbl (%rdi),%r8d
    addr++;
  8041602365:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041602369:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  804160236d:	44 89 c0             	mov    %r8d,%eax
  8041602370:	83 e0 7f             	and    $0x7f,%eax
  8041602373:	d3 e0                	shl    %cl,%eax
  8041602375:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602377:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160237a:	45 84 c0             	test   %r8b,%r8b
  804160237d:	78 e2                	js     8041602361 <function_by_info+0x22f>
  return count;
  804160237f:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry += count;
  8041602382:	49 01 d3             	add    %rdx,%r11
  8041602385:	4c 89 da             	mov    %r11,%rdx
  count  = 0;
  8041602388:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160238d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602392:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602398:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  804160239b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160239f:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  80416023a2:	89 f8                	mov    %edi,%eax
  80416023a4:	83 e0 7f             	and    $0x7f,%eax
  80416023a7:	d3 e0                	shl    %cl,%eax
  80416023a9:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416023ac:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023af:	40 84 ff             	test   %dil,%dil
  80416023b2:	78 e4                	js     8041602398 <function_by_info+0x266>
  return count;
  80416023b4:	48 63 db             	movslq %ebx,%rbx
      curr_abbrev_entry++;
  80416023b7:	49 8d 54 1b 01       	lea    0x1(%r11,%rbx,1),%rdx
      if (table_abbrev_code == abbrev_code) {
  80416023bc:	41 39 f1             	cmp    %esi,%r9d
  80416023bf:	0f 85 14 ff ff ff    	jne    80416022d9 <function_by_info+0x1a7>
  80416023c5:	48 89 d3             	mov    %rdx,%rbx
    if (tag == DW_TAG_subprogram) {
  80416023c8:	41 83 f8 2e          	cmp    $0x2e,%r8d
  80416023cc:	0f 84 f3 00 00 00    	je     80416024c5 <function_by_info+0x393>
            fn_name_entry = entry;
  80416023d2:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023d5:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416023da:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023df:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416023e5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416023e8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023ec:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416023ef:	89 f0                	mov    %esi,%eax
  80416023f1:	83 e0 7f             	and    $0x7f,%eax
  80416023f4:	d3 e0                	shl    %cl,%eax
  80416023f6:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416023f9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023fc:	40 84 f6             	test   %sil,%sil
  80416023ff:	78 e4                	js     80416023e5 <function_by_info+0x2b3>
  return count;
  8041602401:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602404:	48 01 fb             	add    %rdi,%rbx
  8041602407:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160240a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160240f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602414:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  804160241a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160241d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602421:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602424:	89 f0                	mov    %esi,%eax
  8041602426:	83 e0 7f             	and    $0x7f,%eax
  8041602429:	d3 e0                	shl    %cl,%eax
  804160242b:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160242e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602431:	40 84 f6             	test   %sil,%sil
  8041602434:	78 e4                	js     804160241a <function_by_info+0x2e8>
  return count;
  8041602436:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602439:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  804160243c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602442:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602447:	ba 00 00 00 00       	mov    $0x0,%edx
  804160244c:	44 89 e6             	mov    %r12d,%esi
  804160244f:	4c 89 f7             	mov    %r14,%rdi
  8041602452:	41 ff d7             	callq  *%r15
        entry += count;
  8041602455:	48 98                	cltq   
  8041602457:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160245a:	45 09 ec             	or     %r13d,%r12d
  804160245d:	0f 85 6f ff ff ff    	jne    80416023d2 <function_by_info+0x2a0>
  while (entry < entry_end) {
  8041602463:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  8041602467:	0f 86 35 02 00 00    	jbe    80416026a2 <function_by_info+0x570>
  804160246d:	4c 89 f2             	mov    %r14,%rdx
  8041602470:	bf 00 00 00 00       	mov    $0x0,%edi
  8041602475:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160247a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602480:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602483:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602487:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160248a:	89 f0                	mov    %esi,%eax
  804160248c:	83 e0 7f             	and    $0x7f,%eax
  804160248f:	d3 e0                	shl    %cl,%eax
  8041602491:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602494:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602497:	40 84 f6             	test   %sil,%sil
  804160249a:	78 e4                	js     8041602480 <function_by_info+0x34e>
  return count;
  804160249c:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  804160249f:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  80416024a2:	45 85 c9             	test   %r9d,%r9d
  80416024a5:	0f 84 01 02 00 00    	je     80416026ac <function_by_info+0x57a>
           addrs->abbrev_end) { // unsafe needs to be replaced
  80416024ab:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416024af:	4c 8b 50 08          	mov    0x8(%rax),%r10
  80416024b3:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
  80416024b7:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80416024bd:	48 89 da             	mov    %rbx,%rdx
  80416024c0:	e9 84 fe ff ff       	jmpq   8041602349 <function_by_info+0x217>
      uintptr_t low_pc = 0, high_pc = 0;
  80416024c5:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  80416024cc:	00 
  80416024cd:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  80416024d4:	00 
      unsigned name_form        = 0;
  80416024d5:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  80416024dc:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80416024e3:	00 
  80416024e4:	eb 6d                	jmp    8041602553 <function_by_info+0x421>
          count = dwarf_read_abbrev_entry(
  80416024e6:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416024ec:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416024f1:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416024f5:	44 89 ee             	mov    %r13d,%esi
  80416024f8:	4c 89 f7             	mov    %r14,%rdi
  80416024fb:	41 ff d7             	callq  *%r15
  80416024fe:	eb 45                	jmp    8041602545 <function_by_info+0x413>
          count = dwarf_read_abbrev_entry(
  8041602500:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602506:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160250b:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  804160250f:	44 89 ee             	mov    %r13d,%esi
  8041602512:	4c 89 f7             	mov    %r14,%rdi
  8041602515:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  8041602518:	41 83 fd 01          	cmp    $0x1,%r13d
  804160251c:	0f 84 a1 01 00 00    	je     80416026c3 <function_by_info+0x591>
            high_pc += low_pc;
  8041602522:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041602526:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  804160252a:	eb 19                	jmp    8041602545 <function_by_info+0x413>
          count = dwarf_read_abbrev_entry(
  804160252c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602532:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602537:	ba 00 00 00 00       	mov    $0x0,%edx
  804160253c:	44 89 ee             	mov    %r13d,%esi
  804160253f:	4c 89 f7             	mov    %r14,%rdi
  8041602542:	41 ff d7             	callq  *%r15
        entry += count;
  8041602545:	48 98                	cltq   
  8041602547:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160254a:	45 09 e5             	or     %r12d,%r13d
  804160254d:	0f 84 95 00 00 00    	je     80416025e8 <function_by_info+0x4b6>
      const void *fn_name_entry = 0;
  8041602553:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602556:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160255b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602560:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602566:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602569:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160256d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602570:	89 f0                	mov    %esi,%eax
  8041602572:	83 e0 7f             	and    $0x7f,%eax
  8041602575:	d3 e0                	shl    %cl,%eax
  8041602577:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160257a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160257d:	40 84 f6             	test   %sil,%sil
  8041602580:	78 e4                	js     8041602566 <function_by_info+0x434>
  return count;
  8041602582:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602585:	48 01 fb             	add    %rdi,%rbx
  8041602588:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160258b:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602590:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602595:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160259b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160259e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025a2:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025a5:	89 f0                	mov    %esi,%eax
  80416025a7:	83 e0 7f             	and    $0x7f,%eax
  80416025aa:	d3 e0                	shl    %cl,%eax
  80416025ac:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416025af:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025b2:	40 84 f6             	test   %sil,%sil
  80416025b5:	78 e4                	js     804160259b <function_by_info+0x469>
  return count;
  80416025b7:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025ba:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  80416025bd:	41 83 fc 11          	cmp    $0x11,%r12d
  80416025c1:	0f 84 1f ff ff ff    	je     80416024e6 <function_by_info+0x3b4>
        } else if (name == DW_AT_high_pc) {
  80416025c7:	41 83 fc 12          	cmp    $0x12,%r12d
  80416025cb:	0f 84 2f ff ff ff    	je     8041602500 <function_by_info+0x3ce>
          if (name == DW_AT_name) {
  80416025d1:	41 83 fc 03          	cmp    $0x3,%r12d
  80416025d5:	0f 85 51 ff ff ff    	jne    804160252c <function_by_info+0x3fa>
    result |= (byte & 0x7f) << shift;
  80416025db:	44 89 6d a4          	mov    %r13d,-0x5c(%rbp)
            fn_name_entry = entry;
  80416025df:	4c 89 75 a8          	mov    %r14,-0x58(%rbp)
  80416025e3:	e9 44 ff ff ff       	jmpq   804160252c <function_by_info+0x3fa>
      if (p >= low_pc && p <= high_pc) {
  80416025e8:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416025ec:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  80416025f3:	48 39 d8             	cmp    %rbx,%rax
  80416025f6:	0f 87 67 fe ff ff    	ja     8041602463 <function_by_info+0x331>
  80416025fc:	48 3b 5d b8          	cmp    -0x48(%rbp),%rbx
  8041602600:	0f 87 5d fe ff ff    	ja     8041602463 <function_by_info+0x331>
        *offset = low_pc;
  8041602606:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  804160260d:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  8041602610:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  8041602614:	75 6a                	jne    8041602680 <function_by_info+0x54e>
          unsigned long str_offset = 0;
  8041602616:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160261d:	00 
          count                    = dwarf_read_abbrev_entry(
  804160261e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602624:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602629:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160262d:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602632:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602636:	48 b8 45 0c 60 41 80 	movabs $0x8041600c45,%rax
  804160263d:	00 00 00 
  8041602640:	ff d0                	callq  *%rax
          if (buf &&
  8041602642:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  8041602646:	48 85 ff             	test   %rdi,%rdi
  8041602649:	74 2b                	je     8041602676 <function_by_info+0x544>
  804160264b:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  804160264f:	76 25                	jbe    8041602676 <function_by_info+0x544>
            put_unaligned(
  8041602651:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602655:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602659:	48 03 43 40          	add    0x40(%rbx),%rax
  804160265d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602661:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602666:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160266a:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041602671:	00 00 00 
  8041602674:	ff d0                	callq  *%rax
        return 0;
  8041602676:	b8 00 00 00 00       	mov    $0x0,%eax
  804160267b:	e9 c4 fb ff ff       	jmpq   8041602244 <function_by_info+0x112>
          count = dwarf_read_abbrev_entry(
  8041602680:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602686:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  8041602689:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  804160268d:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  8041602690:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602694:	48 b8 45 0c 60 41 80 	movabs $0x8041600c45,%rax
  804160269b:	00 00 00 
  804160269e:	ff d0                	callq  *%rax
  80416026a0:	eb d4                	jmp    8041602676 <function_by_info+0x544>
  return 0;
  80416026a2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026a7:	e9 98 fb ff ff       	jmpq   8041602244 <function_by_info+0x112>
    entry += count;
  80416026ac:	4c 89 f2             	mov    %r14,%rdx
  while (entry < entry_end) {
  80416026af:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  80416026b3:	0f 87 b7 fd ff ff    	ja     8041602470 <function_by_info+0x33e>
  return 0;
  80416026b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026be:	e9 81 fb ff ff       	jmpq   8041602244 <function_by_info+0x112>
        entry += count;
  80416026c3:	48 98                	cltq   
  80416026c5:	49 01 c6             	add    %rax,%r14
  80416026c8:	e9 86 fe ff ff       	jmpq   8041602553 <function_by_info+0x421>

00000080416026cd <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  80416026cd:	55                   	push   %rbp
  80416026ce:	48 89 e5             	mov    %rsp,%rbp
  80416026d1:	41 57                	push   %r15
  80416026d3:	41 56                	push   %r14
  80416026d5:	41 55                	push   %r13
  80416026d7:	41 54                	push   %r12
  80416026d9:	53                   	push   %rbx
  80416026da:	48 83 ec 38          	sub    $0x38,%rsp
  80416026de:	48 89 fb             	mov    %rdi,%rbx
  80416026e1:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80416026e5:	48 89 f7             	mov    %rsi,%rdi
  80416026e8:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  const int flen = strlen(fname);
  80416026ec:	48 b8 70 51 60 41 80 	movabs $0x8041605170,%rax
  80416026f3:	00 00 00 
  80416026f6:	ff d0                	callq  *%rax
  if (flen == 0)
  80416026f8:	85 c0                	test   %eax,%eax
  80416026fa:	0f 84 45 04 00 00    	je     8041602b45 <address_by_fname+0x478>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  8041602700:	4c 8b 63 50          	mov    0x50(%rbx),%r12
  initial_len = get_unaligned(addr, uint32_t);
  8041602704:	49 be 2e 54 60 41 80 	movabs $0x804160542e,%r14
  804160270b:	00 00 00 
  int count                  = 0;
  unsigned long len          = 0;
  Dwarf_Off cu_offset        = 0;
  Dwarf_Off func_offset      = 0;
  // parse pubnames section
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  804160270e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602712:	4c 3b 60 58          	cmp    0x58(%rax),%r12
  8041602716:	0f 83 1f 04 00 00    	jae    8041602b3b <address_by_fname+0x46e>
  804160271c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602721:	4c 89 e6             	mov    %r12,%rsi
  8041602724:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602728:	41 ff d6             	callq  *%r14
  804160272b:	8b 55 c8             	mov    -0x38(%rbp),%edx
    *len = initial_len;
  804160272e:	89 d1                	mov    %edx,%ecx
  count       = 4;
  8041602730:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602735:	83 fa ef             	cmp    $0xffffffef,%edx
  8041602738:	0f 87 d3 00 00 00    	ja     8041602811 <address_by_fname+0x144>
    count = dwarf_entry_len(pubnames_entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    pubnames_entry += count;
  804160273e:	48 98                	cltq   
  8041602740:	49 01 c4             	add    %rax,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  8041602743:	49 8d 04 0c          	lea    (%r12,%rcx,1),%rax
  8041602747:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  804160274b:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602750:	4c 89 e6             	mov    %r12,%rsi
  8041602753:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602757:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  804160275a:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  804160275f:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041602764:	0f 85 fc 00 00 00    	jne    8041602866 <address_by_fname+0x199>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160276a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160276f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602773:	41 ff d6             	callq  *%r14
  8041602776:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041602779:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  804160277c:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602781:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602786:	48 89 de             	mov    %rbx,%rsi
  8041602789:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160278d:	41 ff d6             	callq  *%r14
  8041602790:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  8041602793:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602798:	83 fa ef             	cmp    $0xffffffef,%edx
  804160279b:	0f 87 fa 00 00 00    	ja     804160289b <address_by_fname+0x1ce>
    count = dwarf_entry_len(pubnames_entry, &len);
    pubnames_entry += count;
  80416027a1:	48 98                	cltq   
  80416027a3:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416027a7:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416027ab:	0f 86 5d ff ff ff    	jbe    804160270e <address_by_fname+0x41>
          // Attribute value can be obtained using dwarf_read_abbrev_entry function.
          // LAB 3: Your code here:
        }
        return 0;
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
  80416027b1:	49 bf 70 51 60 41 80 	movabs $0x8041605170,%r15
  80416027b8:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416027bb:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027c0:	4c 89 e6             	mov    %r12,%rsi
  80416027c3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027c7:	41 ff d6             	callq  *%r14
  80416027ca:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416027ce:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416027d2:	4d 85 ed             	test   %r13,%r13
  80416027d5:	0f 84 29 ff ff ff    	je     8041602704 <address_by_fname+0x37>
      if (!strcmp(fname, pubnames_entry)) {
  80416027db:	4c 89 e6             	mov    %r12,%rsi
  80416027de:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416027e2:	48 b8 9a 52 60 41 80 	movabs $0x804160529a,%rax
  80416027e9:	00 00 00 
  80416027ec:	ff d0                	callq  *%rax
  80416027ee:	89 c3                	mov    %eax,%ebx
  80416027f0:	85 c0                	test   %eax,%eax
  80416027f2:	0f 84 e8 00 00 00    	je     80416028e0 <address_by_fname+0x213>
      pubnames_entry += strlen(pubnames_entry) + 1;
  80416027f8:	4c 89 e7             	mov    %r12,%rdi
  80416027fb:	41 ff d7             	callq  *%r15
  80416027fe:	83 c0 01             	add    $0x1,%eax
  8041602801:	48 98                	cltq   
  8041602803:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602806:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  804160280a:	77 af                	ja     80416027bb <address_by_fname+0xee>
  804160280c:	e9 fd fe ff ff       	jmpq   804160270e <address_by_fname+0x41>
    if (initial_len == DW_EXT_DWARF64) {
  8041602811:	83 fa ff             	cmp    $0xffffffff,%edx
  8041602814:	75 1f                	jne    8041602835 <address_by_fname+0x168>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602816:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  804160281b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602820:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602824:	41 ff d6             	callq  *%r14
  8041602827:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
      count = 12;
  804160282b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602830:	e9 09 ff ff ff       	jmpq   804160273e <address_by_fname+0x71>
      cprintf("Unknown DWARF extension\n");
  8041602835:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  804160283c:	00 00 00 
  804160283f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602844:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  804160284b:	00 00 00 
  804160284e:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602850:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
    }
  }
  return 0;
}
  8041602855:	89 d8                	mov    %ebx,%eax
  8041602857:	48 83 c4 38          	add    $0x38,%rsp
  804160285b:	5b                   	pop    %rbx
  804160285c:	41 5c                	pop    %r12
  804160285e:	41 5d                	pop    %r13
  8041602860:	41 5e                	pop    %r14
  8041602862:	41 5f                	pop    %r15
  8041602864:	5d                   	pop    %rbp
  8041602865:	c3                   	retq   
    assert(version == 2);
  8041602866:	48 b9 3e 5a 60 41 80 	movabs $0x8041605a3e,%rcx
  804160286d:	00 00 00 
  8041602870:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041602877:	00 00 00 
  804160287a:	be 73 02 00 00       	mov    $0x273,%esi
  804160287f:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041602886:	00 00 00 
  8041602889:	b8 00 00 00 00       	mov    $0x0,%eax
  804160288e:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041602895:	00 00 00 
  8041602898:	41 ff d0             	callq  *%r8
    if (initial_len == DW_EXT_DWARF64) {
  804160289b:	83 fa ff             	cmp    $0xffffffff,%edx
  804160289e:	75 1b                	jne    80416028bb <address_by_fname+0x1ee>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416028a0:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  80416028a5:	ba 08 00 00 00       	mov    $0x8,%edx
  80416028aa:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028ae:	41 ff d6             	callq  *%r14
      count = 12;
  80416028b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416028b6:	e9 e6 fe ff ff       	jmpq   80416027a1 <address_by_fname+0xd4>
      cprintf("Unknown DWARF extension\n");
  80416028bb:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  80416028c2:	00 00 00 
  80416028c5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028ca:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416028d1:	00 00 00 
  80416028d4:	ff d2                	callq  *%rdx
      count = 0;
  80416028d6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028db:	e9 c1 fe ff ff       	jmpq   80416027a1 <address_by_fname+0xd4>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028e0:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  80416028e4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416028e8:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  80416028ec:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  80416028f0:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028f5:	4c 89 e6             	mov    %r12,%rsi
  80416028f8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028fc:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041602903:	00 00 00 
  8041602906:	ff d0                	callq  *%rax
  8041602908:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  804160290b:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602910:	83 fa ef             	cmp    $0xffffffef,%edx
  8041602913:	0f 87 9e 00 00 00    	ja     80416029b7 <address_by_fname+0x2ea>
        entry += count;
  8041602919:	48 98                	cltq   
  804160291b:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160291f:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602924:	4c 89 ee             	mov    %r13,%rsi
  8041602927:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160292b:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041602932:	00 00 00 
  8041602935:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602937:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  804160293b:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  804160293f:	83 e8 02             	sub    $0x2,%eax
  8041602942:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602946:	0f 85 b9 00 00 00    	jne    8041602a05 <address_by_fname+0x338>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  804160294c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602951:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602955:	49 be 2e 54 60 41 80 	movabs $0x804160542e,%r14
  804160295c:	00 00 00 
  804160295f:	41 ff d6             	callq  *%r14
  8041602962:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602966:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160296a:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  804160296d:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602971:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602976:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160297a:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  804160297d:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602981:	0f 85 b3 00 00 00    	jne    8041602a3a <address_by_fname+0x36d>
  8041602987:	89 d9                	mov    %ebx,%ecx
  8041602989:	4d 89 fd             	mov    %r15,%r13
  804160298c:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602991:	41 0f b6 55 00       	movzbl 0x0(%r13),%edx
    addr++;
  8041602996:	49 83 c5 01          	add    $0x1,%r13
    result |= (byte & 0x7f) << shift;
  804160299a:	89 d0                	mov    %edx,%eax
  804160299c:	83 e0 7f             	and    $0x7f,%eax
  804160299f:	d3 e0                	shl    %cl,%eax
  80416029a1:	09 c7                	or     %eax,%edi
    shift += 7;
  80416029a3:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416029a6:	84 d2                	test   %dl,%dl
  80416029a8:	78 e7                	js     8041602991 <address_by_fname+0x2c4>
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  80416029aa:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416029ae:	4c 8b 40 08          	mov    0x8(%rax),%r8
  80416029b2:	e9 21 01 00 00       	jmpq   8041602ad8 <address_by_fname+0x40b>
    if (initial_len == DW_EXT_DWARF64) {
  80416029b7:	83 fa ff             	cmp    $0xffffffff,%edx
  80416029ba:	74 25                	je     80416029e1 <address_by_fname+0x314>
      cprintf("Unknown DWARF extension\n");
  80416029bc:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  80416029c3:	00 00 00 
  80416029c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029cb:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416029d2:	00 00 00 
  80416029d5:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416029d7:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416029dc:	e9 74 fe ff ff       	jmpq   8041602855 <address_by_fname+0x188>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029e1:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416029e6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029eb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029ef:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416029f6:	00 00 00 
  80416029f9:	ff d0                	callq  *%rax
      count = 12;
  80416029fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602a00:	e9 14 ff ff ff       	jmpq   8041602919 <address_by_fname+0x24c>
        assert(version == 4 || version == 2);
  8041602a05:	48 b9 2e 5a 60 41 80 	movabs $0x8041605a2e,%rcx
  8041602a0c:	00 00 00 
  8041602a0f:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041602a16:	00 00 00 
  8041602a19:	be 89 02 00 00       	mov    $0x289,%esi
  8041602a1e:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041602a25:	00 00 00 
  8041602a28:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a2d:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041602a34:	00 00 00 
  8041602a37:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a3a:	48 b9 fb 59 60 41 80 	movabs $0x80416059fb,%rcx
  8041602a41:	00 00 00 
  8041602a44:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041602a4b:	00 00 00 
  8041602a4e:	be 8e 02 00 00       	mov    $0x28e,%esi
  8041602a53:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041602a5a:	00 00 00 
  8041602a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a62:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041602a69:	00 00 00 
  8041602a6c:	41 ff d0             	callq  *%r8
  count  = 0;
  8041602a6f:	41 89 da             	mov    %ebx,%r10d
  shift  = 0;
  8041602a72:	89 d9                	mov    %ebx,%ecx
  8041602a74:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a77:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602a7c:	44 0f b6 0a          	movzbl (%rdx),%r9d
    addr++;
  8041602a80:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a84:	41 83 c2 01          	add    $0x1,%r10d
    result |= (byte & 0x7f) << shift;
  8041602a88:	44 89 c8             	mov    %r9d,%eax
  8041602a8b:	83 e0 7f             	and    $0x7f,%eax
  8041602a8e:	d3 e0                	shl    %cl,%eax
  8041602a90:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602a92:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a95:	45 84 c9             	test   %r9b,%r9b
  8041602a98:	78 e2                	js     8041602a7c <address_by_fname+0x3af>
  return count;
  8041602a9a:	4d 63 d2             	movslq %r10d,%r10
            abbrev_entry += count;
  8041602a9d:	4d 01 d4             	add    %r10,%r12
  count  = 0;
  8041602aa0:	41 89 da             	mov    %ebx,%r10d
  shift  = 0;
  8041602aa3:	89 d9                	mov    %ebx,%ecx
  8041602aa5:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602aa8:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602aae:	44 0f b6 0a          	movzbl (%rdx),%r9d
    addr++;
  8041602ab2:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ab6:	41 83 c2 01          	add    $0x1,%r10d
    result |= (byte & 0x7f) << shift;
  8041602aba:	44 89 c8             	mov    %r9d,%eax
  8041602abd:	83 e0 7f             	and    $0x7f,%eax
  8041602ac0:	d3 e0                	shl    %cl,%eax
  8041602ac2:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602ac5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ac8:	45 84 c9             	test   %r9b,%r9b
  8041602acb:	78 e1                	js     8041602aae <address_by_fname+0x3e1>
  return count;
  8041602acd:	4d 63 d2             	movslq %r10d,%r10
            abbrev_entry += count;
  8041602ad0:	4d 01 d4             	add    %r10,%r12
          } while (name != 0 || form != 0);
  8041602ad3:	41 09 f3             	or     %esi,%r11d
  8041602ad6:	75 97                	jne    8041602a6f <address_by_fname+0x3a2>
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602ad8:	4d 39 c4             	cmp    %r8,%r12
  8041602adb:	0f 83 74 fd ff ff    	jae    8041602855 <address_by_fname+0x188>
  8041602ae1:	41 89 d9             	mov    %ebx,%r9d
  8041602ae4:	89 d9                	mov    %ebx,%ecx
  8041602ae6:	4c 89 e2             	mov    %r12,%rdx
  8041602ae9:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602aef:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602af2:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602af6:	41 83 c1 01          	add    $0x1,%r9d
    result |= (byte & 0x7f) << shift;
  8041602afa:	89 f0                	mov    %esi,%eax
  8041602afc:	83 e0 7f             	and    $0x7f,%eax
  8041602aff:	d3 e0                	shl    %cl,%eax
  8041602b01:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602b04:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b07:	40 84 f6             	test   %sil,%sil
  8041602b0a:	78 e3                	js     8041602aef <address_by_fname+0x422>
  return count;
  8041602b0c:	4d 63 c9             	movslq %r9d,%r9
          abbrev_entry += count;
  8041602b0f:	4d 01 cc             	add    %r9,%r12
  count  = 0;
  8041602b12:	89 da                	mov    %ebx,%edx
  8041602b14:	4c 89 e0             	mov    %r12,%rax
    byte = *addr;
  8041602b17:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041602b1a:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041602b1e:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041602b21:	84 c9                	test   %cl,%cl
  8041602b23:	78 f2                	js     8041602b17 <address_by_fname+0x44a>
  return count;
  8041602b25:	48 63 d2             	movslq %edx,%rdx
          abbrev_entry++;
  8041602b28:	4d 8d 64 14 01       	lea    0x1(%r12,%rdx,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602b2d:	44 39 d7             	cmp    %r10d,%edi
  8041602b30:	0f 85 39 ff ff ff    	jne    8041602a6f <address_by_fname+0x3a2>
  8041602b36:	e9 1a fd ff ff       	jmpq   8041602855 <address_by_fname+0x188>
  return 0;
  8041602b3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602b40:	e9 10 fd ff ff       	jmpq   8041602855 <address_by_fname+0x188>
    return 0;
  8041602b45:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602b4a:	e9 06 fd ff ff       	jmpq   8041602855 <address_by_fname+0x188>

0000008041602b4f <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602b4f:	55                   	push   %rbp
  8041602b50:	48 89 e5             	mov    %rsp,%rbp
  8041602b53:	41 57                	push   %r15
  8041602b55:	41 56                	push   %r14
  8041602b57:	41 55                	push   %r13
  8041602b59:	41 54                	push   %r12
  8041602b5b:	53                   	push   %rbx
  8041602b5c:	48 83 ec 48          	sub    $0x48,%rsp
  8041602b60:	48 89 fb             	mov    %rdi,%rbx
  8041602b63:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602b67:	48 89 f7             	mov    %rsi,%rdi
  8041602b6a:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602b6e:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602b72:	48 b8 70 51 60 41 80 	movabs $0x8041605170,%rax
  8041602b79:	00 00 00 
  8041602b7c:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602b7e:	85 c0                	test   %eax,%eax
  8041602b80:	0f 84 26 05 00 00    	je     80416030ac <naive_address_by_fname+0x55d>
    return 0;
  const void *entry = addrs->info_begin;
  8041602b86:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602b8a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602b8e:	4c 3b 78 28          	cmp    0x28(%rax),%r15
  8041602b92:	72 0a                	jb     8041602b9e <naive_address_by_fname+0x4f>
        } while (name != 0 || form != 0);
      }
    }
  }

  return 0;
  8041602b94:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602b99:	e9 df 00 00 00       	jmpq   8041602c7d <naive_address_by_fname+0x12e>
  initial_len = get_unaligned(addr, uint32_t);
  8041602b9e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602ba3:	4c 89 fe             	mov    %r15,%rsi
  8041602ba6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602baa:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041602bb1:	00 00 00 
  8041602bb4:	ff d0                	callq  *%rax
  8041602bb6:	8b 45 c8             	mov    -0x38(%rbp),%eax
    *len = initial_len;
  8041602bb9:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041602bbb:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602bc0:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602bc3:	76 2b                	jbe    8041602bf0 <naive_address_by_fname+0xa1>
    if (initial_len == DW_EXT_DWARF64) {
  8041602bc5:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602bc8:	0f 85 8f 00 00 00    	jne    8041602c5d <naive_address_by_fname+0x10e>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602bce:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602bd2:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602bd7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bdb:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041602be2:	00 00 00 
  8041602be5:	ff d0                	callq  *%rax
  8041602be7:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
      count = 12;
  8041602beb:	bb 0c 00 00 00       	mov    $0xc,%ebx
    entry += count;
  8041602bf0:	48 63 db             	movslq %ebx,%rbx
  8041602bf3:	4d 8d 34 1f          	lea    (%r15,%rbx,1),%r14
    const void *entry_end = entry + len;
  8041602bf7:	49 8d 04 16          	lea    (%r14,%rdx,1),%rax
  8041602bfb:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602bff:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602c04:	4c 89 f6             	mov    %r14,%rsi
  8041602c07:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c0b:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041602c12:	00 00 00 
  8041602c15:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602c17:	49 83 c6 02          	add    $0x2,%r14
    assert(version == 4 || version == 2);
  8041602c1b:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602c1f:	83 e8 02             	sub    $0x2,%eax
  8041602c22:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602c26:	74 64                	je     8041602c8c <naive_address_by_fname+0x13d>
  8041602c28:	48 b9 2e 5a 60 41 80 	movabs $0x8041605a2e,%rcx
  8041602c2f:	00 00 00 
  8041602c32:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041602c39:	00 00 00 
  8041602c3c:	be d4 02 00 00       	mov    $0x2d4,%esi
  8041602c41:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041602c48:	00 00 00 
  8041602c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602c50:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041602c57:	00 00 00 
  8041602c5a:	41 ff d0             	callq  *%r8
      cprintf("Unknown DWARF extension\n");
  8041602c5d:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  8041602c64:	00 00 00 
  8041602c67:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602c6c:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041602c73:	00 00 00 
  8041602c76:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602c78:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
  8041602c7d:	48 83 c4 48          	add    $0x48,%rsp
  8041602c81:	5b                   	pop    %rbx
  8041602c82:	41 5c                	pop    %r12
  8041602c84:	41 5d                	pop    %r13
  8041602c86:	41 5e                	pop    %r14
  8041602c88:	41 5f                	pop    %r15
  8041602c8a:	5d                   	pop    %rbp
  8041602c8b:	c3                   	retq   
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602c8c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602c91:	4c 89 f6             	mov    %r14,%rsi
  8041602c94:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c98:	49 bc 2e 54 60 41 80 	movabs $0x804160542e,%r12
  8041602c9f:	00 00 00 
  8041602ca2:	41 ff d4             	callq  *%r12
  8041602ca5:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  8041602ca9:	49 8d 34 1e          	lea    (%r14,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602cad:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602cb1:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602cb6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602cba:	41 ff d4             	callq  *%r12
    assert(address_size == 8);
  8041602cbd:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602cc1:	74 35                	je     8041602cf8 <naive_address_by_fname+0x1a9>
  8041602cc3:	48 b9 fb 59 60 41 80 	movabs $0x80416059fb,%rcx
  8041602cca:	00 00 00 
  8041602ccd:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041602cd4:	00 00 00 
  8041602cd7:	be d8 02 00 00       	mov    $0x2d8,%esi
  8041602cdc:	48 bf ee 59 60 41 80 	movabs $0x80416059ee,%rdi
  8041602ce3:	00 00 00 
  8041602ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ceb:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041602cf2:	00 00 00 
  8041602cf5:	41 ff d0             	callq  *%r8
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602cf8:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602cfc:	4c 03 28             	add    (%rax),%r13
  8041602cff:	4c 89 6d 98          	mov    %r13,-0x68(%rbp)
            count = dwarf_read_abbrev_entry(
  8041602d03:	49 be 45 0c 60 41 80 	movabs $0x8041600c45,%r14
  8041602d0a:	00 00 00 
    while (entry < entry_end) {
  8041602d0d:	e9 94 01 00 00       	jmpq   8041602ea6 <naive_address_by_fname+0x357>
  result = 0;
  8041602d12:	48 89 d6             	mov    %rdx,%rsi
  count  = 0;
  8041602d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041602d1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d1f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d25:	0f b6 3e             	movzbl (%rsi),%edi
    addr++;
  8041602d28:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041602d2c:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041602d2f:	89 f8                	mov    %edi,%eax
  8041602d31:	83 e0 7f             	and    $0x7f,%eax
  8041602d34:	d3 e0                	shl    %cl,%eax
  8041602d36:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602d39:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d3c:	40 84 ff             	test   %dil,%dil
  8041602d3f:	78 e4                	js     8041602d25 <naive_address_by_fname+0x1d6>
  return count;
  8041602d41:	48 63 db             	movslq %ebx,%rbx
          curr_abbrev_entry += count;
  8041602d44:	48 01 d3             	add    %rdx,%rbx
  8041602d47:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602d4a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602d4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d54:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602d5a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d5d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d61:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602d64:	89 f0                	mov    %esi,%eax
  8041602d66:	83 e0 7f             	and    $0x7f,%eax
  8041602d69:	d3 e0                	shl    %cl,%eax
  8041602d6b:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602d6e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d71:	40 84 f6             	test   %sil,%sil
  8041602d74:	78 e4                	js     8041602d5a <naive_address_by_fname+0x20b>
  return count;
  8041602d76:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602d79:	48 8d 14 3b          	lea    (%rbx,%rdi,1),%rdx
        } while (name != 0 || form != 0);
  8041602d7d:	45 09 c4             	or     %r8d,%r12d
  8041602d80:	75 90                	jne    8041602d12 <naive_address_by_fname+0x1c3>
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602d82:	4c 39 da             	cmp    %r11,%rdx
  8041602d85:	73 77                	jae    8041602dfe <naive_address_by_fname+0x2af>
  8041602d87:	48 89 d7             	mov    %rdx,%rdi
  8041602d8a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8041602d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602d95:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602d9a:	44 0f b6 07          	movzbl (%rdi),%r8d
    addr++;
  8041602d9e:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041602da2:	41 83 c1 01          	add    $0x1,%r9d
    result |= (byte & 0x7f) << shift;
  8041602da6:	44 89 c0             	mov    %r8d,%eax
  8041602da9:	83 e0 7f             	and    $0x7f,%eax
  8041602dac:	d3 e0                	shl    %cl,%eax
  8041602dae:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602db0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602db3:	45 84 c0             	test   %r8b,%r8b
  8041602db6:	78 e2                	js     8041602d9a <naive_address_by_fname+0x24b>
  return count;
  8041602db8:	4d 63 c1             	movslq %r9d,%r8
        curr_abbrev_entry += count;
  8041602dbb:	49 01 d0             	add    %rdx,%r8
  8041602dbe:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041602dc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041602dc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602dcb:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602dd1:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602dd4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602dd8:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041602ddb:	89 f8                	mov    %edi,%eax
  8041602ddd:	83 e0 7f             	and    $0x7f,%eax
  8041602de0:	d3 e0                	shl    %cl,%eax
  8041602de2:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602de5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602de8:	40 84 ff             	test   %dil,%dil
  8041602deb:	78 e4                	js     8041602dd1 <naive_address_by_fname+0x282>
  return count;
  8041602ded:	48 63 db             	movslq %ebx,%rbx
        curr_abbrev_entry++;
  8041602df0:	49 8d 54 18 01       	lea    0x1(%r8,%rbx,1),%rdx
        if (table_abbrev_code == abbrev_code) {
  8041602df5:	41 39 f2             	cmp    %esi,%r10d
  8041602df8:	0f 85 14 ff ff ff    	jne    8041602d12 <naive_address_by_fname+0x1c3>
  8041602dfe:	48 89 d3             	mov    %rdx,%rbx
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602e01:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602e05:	0f 84 fd 00 00 00    	je     8041602f08 <naive_address_by_fname+0x3b9>
  8041602e0b:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602e0f:	0f 84 f3 00 00 00    	je     8041602f08 <naive_address_by_fname+0x3b9>
                found = 1;
  8041602e15:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602e18:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602e1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602e22:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602e28:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602e2b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602e2f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602e32:	89 f0                	mov    %esi,%eax
  8041602e34:	83 e0 7f             	and    $0x7f,%eax
  8041602e37:	d3 e0                	shl    %cl,%eax
  8041602e39:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602e3c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602e3f:	40 84 f6             	test   %sil,%sil
  8041602e42:	78 e4                	js     8041602e28 <naive_address_by_fname+0x2d9>
  return count;
  8041602e44:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602e47:	48 01 fb             	add    %rdi,%rbx
  8041602e4a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602e4d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602e57:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602e5d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602e60:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602e64:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602e67:	89 f0                	mov    %esi,%eax
  8041602e69:	83 e0 7f             	and    $0x7f,%eax
  8041602e6c:	d3 e0                	shl    %cl,%eax
  8041602e6e:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602e71:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602e74:	40 84 f6             	test   %sil,%sil
  8041602e77:	78 e4                	js     8041602e5d <naive_address_by_fname+0x30e>
  return count;
  8041602e79:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602e7c:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041602e7f:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602e85:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602e8a:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602e8f:	44 89 e6             	mov    %r12d,%esi
  8041602e92:	4c 89 ff             	mov    %r15,%rdi
  8041602e95:	41 ff d6             	callq  *%r14
          entry += count;
  8041602e98:	48 98                	cltq   
  8041602e9a:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041602e9d:	45 09 ec             	or     %r13d,%r12d
  8041602ea0:	0f 85 6f ff ff ff    	jne    8041602e15 <naive_address_by_fname+0x2c6>
    while (entry < entry_end) {
  8041602ea6:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  8041602eaa:	0f 86 da fc ff ff    	jbe    8041602b8a <naive_address_by_fname+0x3b>
  8041602eb0:	4c 89 fa             	mov    %r15,%rdx
  8041602eb3:	bf 00 00 00 00       	mov    $0x0,%edi
  8041602eb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602ebd:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602ec3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ec6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602eca:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602ecd:	89 f0                	mov    %esi,%eax
  8041602ecf:	83 e0 7f             	and    $0x7f,%eax
  8041602ed2:	d3 e0                	shl    %cl,%eax
  8041602ed4:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602ed7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602eda:	40 84 f6             	test   %sil,%sil
  8041602edd:	78 e4                	js     8041602ec3 <naive_address_by_fname+0x374>
  return count;
  8041602edf:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  8041602ee2:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  8041602ee5:	45 85 d2             	test   %r10d,%r10d
  8041602ee8:	0f 84 ac 01 00 00    	je     804160309a <naive_address_by_fname+0x54b>
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602eee:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602ef2:	4c 8b 58 08          	mov    0x8(%rax),%r11
  8041602ef6:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602efa:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8041602f00:	48 89 da             	mov    %rbx,%rdx
  8041602f03:	e9 7a fe ff ff       	jmpq   8041602d82 <naive_address_by_fname+0x233>
        uintptr_t low_pc = 0;
  8041602f08:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602f0f:	00 
        int found        = 0;
  8041602f10:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041602f17:	eb 6c                	jmp    8041602f85 <naive_address_by_fname+0x436>
            count = dwarf_read_abbrev_entry(
  8041602f19:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f1f:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602f24:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602f28:	44 89 ee             	mov    %r13d,%esi
  8041602f2b:	4c 89 ff             	mov    %r15,%rdi
  8041602f2e:	41 ff d6             	callq  *%r14
  8041602f31:	eb 44                	jmp    8041602f77 <naive_address_by_fname+0x428>
            if (form == DW_FORM_strp) {
  8041602f33:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041602f37:	0f 84 e4 00 00 00    	je     8041603021 <naive_address_by_fname+0x4d2>
              if (!strcmp(fname, entry)) {
  8041602f3d:	4c 89 fe             	mov    %r15,%rsi
  8041602f40:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041602f44:	48 b8 9a 52 60 41 80 	movabs $0x804160529a,%rax
  8041602f4b:	00 00 00 
  8041602f4e:	ff d0                	callq  *%rax
                found = 1;
  8041602f50:	85 c0                	test   %eax,%eax
  8041602f52:	b8 01 00 00 00       	mov    $0x1,%eax
  8041602f57:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041602f5b:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  8041602f5e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f64:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602f69:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602f6e:	44 89 ee             	mov    %r13d,%esi
  8041602f71:	4c 89 ff             	mov    %r15,%rdi
  8041602f74:	41 ff d6             	callq  *%r14
          entry += count;
  8041602f77:	48 98                	cltq   
  8041602f79:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041602f7c:	45 09 e5             	or     %r12d,%r13d
  8041602f7f:	0f 84 f6 00 00 00    	je     804160307b <naive_address_by_fname+0x52c>
        int found        = 0;
  8041602f85:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f88:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f92:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602f98:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f9b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f9f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602fa2:	89 f0                	mov    %esi,%eax
  8041602fa4:	83 e0 7f             	and    $0x7f,%eax
  8041602fa7:	d3 e0                	shl    %cl,%eax
  8041602fa9:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602fac:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602faf:	40 84 f6             	test   %sil,%sil
  8041602fb2:	78 e4                	js     8041602f98 <naive_address_by_fname+0x449>
  return count;
  8041602fb4:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fb7:	48 01 fb             	add    %rdi,%rbx
  8041602fba:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fbd:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fc7:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602fcd:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fd0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602fd4:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602fd7:	89 f0                	mov    %esi,%eax
  8041602fd9:	83 e0 7f             	and    $0x7f,%eax
  8041602fdc:	d3 e0                	shl    %cl,%eax
  8041602fde:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602fe1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602fe4:	40 84 f6             	test   %sil,%sil
  8041602fe7:	78 e4                	js     8041602fcd <naive_address_by_fname+0x47e>
  return count;
  8041602fe9:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fec:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  8041602fef:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602ff3:	0f 84 20 ff ff ff    	je     8041602f19 <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  8041602ff9:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602ffd:	0f 84 30 ff ff ff    	je     8041602f33 <naive_address_by_fname+0x3e4>
            count = dwarf_read_abbrev_entry(
  8041603003:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603009:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160300e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603013:	44 89 ee             	mov    %r13d,%esi
  8041603016:	4c 89 ff             	mov    %r15,%rdi
  8041603019:	41 ff d6             	callq  *%r14
  804160301c:	e9 56 ff ff ff       	jmpq   8041602f77 <naive_address_by_fname+0x428>
                  str_offset = 0;
  8041603021:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041603028:	00 
              count          = dwarf_read_abbrev_entry(
  8041603029:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160302f:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603034:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041603038:	be 0e 00 00 00       	mov    $0xe,%esi
  804160303d:	4c 89 ff             	mov    %r15,%rdi
  8041603040:	41 ff d6             	callq  *%r14
  8041603043:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  8041603046:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160304a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160304e:	48 03 70 40          	add    0x40(%rax),%rsi
  8041603052:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041603056:	48 b8 9a 52 60 41 80 	movabs $0x804160529a,%rax
  804160305d:	00 00 00 
  8041603060:	ff d0                	callq  *%rax
                found = 1;
  8041603062:	85 c0                	test   %eax,%eax
  8041603064:	b8 01 00 00 00       	mov    $0x1,%eax
  8041603069:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  804160306d:	89 45 bc             	mov    %eax,-0x44(%rbp)
          entry += count;
  8041603070:	4d 63 e4             	movslq %r12d,%r12
  8041603073:	4d 01 e7             	add    %r12,%r15
  8041603076:	e9 0a ff ff ff       	jmpq   8041602f85 <naive_address_by_fname+0x436>
        if (found) {
  804160307b:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  804160307f:	0f 84 21 fe ff ff    	je     8041602ea6 <naive_address_by_fname+0x357>
          *offset = low_pc;
  8041603085:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041603089:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  804160308d:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  8041603090:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603095:	e9 e3 fb ff ff       	jmpq   8041602c7d <naive_address_by_fname+0x12e>
      entry += count;
  804160309a:	4c 89 fa             	mov    %r15,%rdx
    while (entry < entry_end) {
  804160309d:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  80416030a1:	0f 87 0c fe ff ff    	ja     8041602eb3 <naive_address_by_fname+0x364>
  80416030a7:	e9 de fa ff ff       	jmpq   8041602b8a <naive_address_by_fname+0x3b>
    return 0;
  80416030ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416030b1:	e9 c7 fb ff ff       	jmpq   8041602c7d <naive_address_by_fname+0x12e>

00000080416030b6 <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  80416030b6:	55                   	push   %rbp
  80416030b7:	48 89 e5             	mov    %rsp,%rbp
  80416030ba:	41 57                	push   %r15
  80416030bc:	41 56                	push   %r14
  80416030be:	41 55                	push   %r13
  80416030c0:	41 54                	push   %r12
  80416030c2:	53                   	push   %rbx
  80416030c3:	48 83 ec 48          	sub    $0x48,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  80416030c7:	4c 8b 67 30          	mov    0x30(%rdi),%r12
  80416030cb:	48 8b 47 38          	mov    0x38(%rdi),%rax
  80416030cf:	4c 29 e0             	sub    %r12,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  80416030d2:	48 39 d0             	cmp    %rdx,%rax
  80416030d5:	0f 82 3b 07 00 00    	jb     8041603816 <line_for_address+0x760>
  80416030db:	48 85 c9             	test   %rcx,%rcx
  80416030de:	0f 84 32 07 00 00    	je     8041603816 <line_for_address+0x760>
  80416030e4:	48 89 4d 98          	mov    %rcx,-0x68(%rbp)
  80416030e8:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  80416030ec:	49 01 d4             	add    %rdx,%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416030ef:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030f4:	4c 89 e6             	mov    %r12,%rsi
  80416030f7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030fb:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603102:	00 00 00 
  8041603105:	ff d0                	callq  *%rax
  8041603107:	8b 55 c8             	mov    -0x38(%rbp),%edx
    *len = initial_len;
  804160310a:	41 89 d7             	mov    %edx,%r15d
  count       = 4;
  804160310d:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603112:	83 fa ef             	cmp    $0xffffffef,%edx
  8041603115:	0f 87 2c 01 00 00    	ja     8041603247 <line_for_address+0x191>
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    curr_addr += count;
  804160311b:	48 98                	cltq   
  804160311d:	49 01 c4             	add    %rax,%r12
  }
  const void *unit_end = curr_addr + unit_length;
  8041603120:	4d 01 e7             	add    %r12,%r15
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  8041603123:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603128:	4c 89 e6             	mov    %r12,%rsi
  804160312b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160312f:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603136:	00 00 00 
  8041603139:	ff d0                	callq  *%rax
  804160313b:	44 0f b7 75 c8       	movzwl -0x38(%rbp),%r14d
  curr_addr += sizeof(Dwarf_Half);
  8041603140:	4d 8d 6c 24 02       	lea    0x2(%r12),%r13
  assert(version == 4 || version == 3 || version == 2);
  8041603145:	41 8d 46 fe          	lea    -0x2(%r14),%eax
  8041603149:	66 83 f8 02          	cmp    $0x2,%ax
  804160314d:	0f 87 50 01 00 00    	ja     80416032a3 <line_for_address+0x1ed>
  initial_len = get_unaligned(addr, uint32_t);
  8041603153:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603158:	4c 89 ee             	mov    %r13,%rsi
  804160315b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160315f:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603166:	00 00 00 
  8041603169:	ff d0                	callq  *%rax
  804160316b:	8b 55 c8             	mov    -0x38(%rbp),%edx
    *len = initial_len;
  804160316e:	89 d3                	mov    %edx,%ebx
  count       = 4;
  8041603170:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603175:	83 fa ef             	cmp    $0xffffffef,%edx
  8041603178:	0f 87 5a 01 00 00    	ja     80416032d8 <line_for_address+0x222>
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    curr_addr += count;
  804160317e:	48 98                	cltq   
  8041603180:	49 01 c5             	add    %rax,%r13
  }
  const void *program_addr = curr_addr + header_length;
  8041603183:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  8041603186:	ba 01 00 00 00       	mov    $0x1,%edx
  804160318b:	4c 89 ee             	mov    %r13,%rsi
  804160318e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603192:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603199:	00 00 00 
  804160319c:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  804160319e:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416031a2:	0f 85 82 01 00 00    	jne    804160332a <line_for_address+0x274>
  curr_addr += sizeof(Dwarf_Small);
  80416031a8:	4d 8d 65 01          	lea    0x1(%r13),%r12
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  80416031ac:	66 41 83 fe 04       	cmp    $0x4,%r14w
  80416031b1:	0f 84 a8 01 00 00    	je     804160335f <line_for_address+0x2a9>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  80416031b7:	49 8d 74 24 01       	lea    0x1(%r12),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  80416031bc:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031c1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031c5:	49 be 2e 54 60 41 80 	movabs $0x804160542e,%r14
  80416031cc:	00 00 00 
  80416031cf:	41 ff d6             	callq  *%r14
  80416031d2:	44 0f b6 6d c8       	movzbl -0x38(%rbp),%r13d
  curr_addr += sizeof(signed char);
  80416031d7:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  80416031dc:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031e1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031e5:	41 ff d6             	callq  *%r14
  80416031e8:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416031ec:	88 45 be             	mov    %al,-0x42(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416031ef:	49 8d 74 24 03       	lea    0x3(%r12),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  80416031f4:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031f9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031fd:	41 ff d6             	callq  *%r14
  8041603200:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041603204:	88 45 bf             	mov    %al,-0x41(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  8041603207:	49 8d 74 24 04       	lea    0x4(%r12),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  804160320c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603211:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603215:	41 ff d6             	callq  *%r14
  while (program_addr < end_addr) {
  8041603218:	49 39 df             	cmp    %rbx,%r15
  804160321b:	0f 86 c3 05 00 00    	jbe    80416037e4 <line_for_address+0x72e>
  8041603221:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  8041603228:	41 be 00 00 00 00    	mov    $0x0,%r14d
      state->line += (info->line_base +
  804160322e:	41 0f be f5          	movsbl %r13b,%esi
  8041603232:	89 75 a4             	mov    %esi,-0x5c(%rbp)
          Dwarf_Small adjusted_opcode =
  8041603235:	0f b6 45 bf          	movzbl -0x41(%rbp),%eax
  8041603239:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  804160323b:	0f b6 c0             	movzbl %al,%eax
  804160323e:	66 89 45 bc          	mov    %ax,-0x44(%rbp)
  8041603242:	e9 4e 02 00 00       	jmpq   8041603495 <line_for_address+0x3df>
    if (initial_len == DW_EXT_DWARF64) {
  8041603247:	83 fa ff             	cmp    $0xffffffff,%edx
  804160324a:	74 2f                	je     804160327b <line_for_address+0x1c5>
      cprintf("Unknown DWARF extension\n");
  804160324c:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  8041603253:	00 00 00 
  8041603256:	b8 00 00 00 00       	mov    $0x0,%eax
  804160325b:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041603262:	00 00 00 
  8041603265:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  8041603267:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
                          p);

  *lineno_store = current_state.line;

  return 0;
}
  804160326c:	48 83 c4 48          	add    $0x48,%rsp
  8041603270:	5b                   	pop    %rbx
  8041603271:	41 5c                	pop    %r12
  8041603273:	41 5d                	pop    %r13
  8041603275:	41 5e                	pop    %r14
  8041603277:	41 5f                	pop    %r15
  8041603279:	5d                   	pop    %rbp
  804160327a:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160327b:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041603280:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603285:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603289:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603290:	00 00 00 
  8041603293:	ff d0                	callq  *%rax
  8041603295:	4c 8b 7d c8          	mov    -0x38(%rbp),%r15
      count = 12;
  8041603299:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160329e:	e9 78 fe ff ff       	jmpq   804160311b <line_for_address+0x65>
  assert(version == 4 || version == 3 || version == 2);
  80416032a3:	48 b9 e8 5b 60 41 80 	movabs $0x8041605be8,%rcx
  80416032aa:	00 00 00 
  80416032ad:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  80416032b4:	00 00 00 
  80416032b7:	be fc 00 00 00       	mov    $0xfc,%esi
  80416032bc:	48 bf a1 5b 60 41 80 	movabs $0x8041605ba1,%rdi
  80416032c3:	00 00 00 
  80416032c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032cb:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416032d2:	00 00 00 
  80416032d5:	41 ff d0             	callq  *%r8
    if (initial_len == DW_EXT_DWARF64) {
  80416032d8:	83 fa ff             	cmp    $0xffffffff,%edx
  80416032db:	74 25                	je     8041603302 <line_for_address+0x24c>
      cprintf("Unknown DWARF extension\n");
  80416032dd:	48 bf c0 59 60 41 80 	movabs $0x80416059c0,%rdi
  80416032e4:	00 00 00 
  80416032e7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032ec:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416032f3:	00 00 00 
  80416032f6:	ff d2                	callq  *%rdx
    return -E_BAD_DWARF;
  80416032f8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416032fd:	e9 6a ff ff ff       	jmpq   804160326c <line_for_address+0x1b6>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603302:	49 8d 74 24 22       	lea    0x22(%r12),%rsi
  8041603307:	ba 08 00 00 00       	mov    $0x8,%edx
  804160330c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603310:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603317:	00 00 00 
  804160331a:	ff d0                	callq  *%rax
  804160331c:	48 8b 5d c8          	mov    -0x38(%rbp),%rbx
      count = 12;
  8041603320:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041603325:	e9 54 fe ff ff       	jmpq   804160317e <line_for_address+0xc8>
  assert(minimum_instruction_length == 1);
  804160332a:	48 b9 18 5c 60 41 80 	movabs $0x8041605c18,%rcx
  8041603331:	00 00 00 
  8041603334:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  804160333b:	00 00 00 
  804160333e:	be 07 01 00 00       	mov    $0x107,%esi
  8041603343:	48 bf a1 5b 60 41 80 	movabs $0x8041605ba1,%rdi
  804160334a:	00 00 00 
  804160334d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603352:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041603359:	00 00 00 
  804160335c:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  804160335f:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603364:	4c 89 e6             	mov    %r12,%rsi
  8041603367:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160336b:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603372:	00 00 00 
  8041603375:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  8041603377:	4d 8d 65 02          	lea    0x2(%r13),%r12
  assert(maximum_operations_per_instruction == 1);
  804160337b:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160337f:	0f 84 32 fe ff ff    	je     80416031b7 <line_for_address+0x101>
  8041603385:	48 b9 38 5c 60 41 80 	movabs $0x8041605c38,%rcx
  804160338c:	00 00 00 
  804160338f:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  8041603396:	00 00 00 
  8041603399:	be 11 01 00 00       	mov    $0x111,%esi
  804160339e:	48 bf a1 5b 60 41 80 	movabs $0x8041605ba1,%rdi
  80416033a5:	00 00 00 
  80416033a8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033ad:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416033b4:	00 00 00 
  80416033b7:	41 ff d0             	callq  *%r8
      switch (opcode) {
  80416033ba:	80 f9 01             	cmp    $0x1,%cl
  80416033bd:	0f 85 98 01 00 00    	jne    804160355b <line_for_address+0x4a5>
          if (last_state.address <= destination_addr &&
  80416033c3:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416033c7:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  80416033cb:	48 39 f0             	cmp    %rsi,%rax
  80416033ce:	0f 82 b5 01 00 00    	jb     8041603589 <line_for_address+0x4d3>
  80416033d4:	4c 39 f0             	cmp    %r14,%rax
  80416033d7:	0f 82 10 04 00 00    	jb     80416037ed <line_for_address+0x737>
          last_state           = *state;
  80416033dd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416033e0:	89 45 a0             	mov    %eax,-0x60(%rbp)
  80416033e3:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
          state->line          = 1;
  80416033e7:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
          state->address       = 0;
  80416033ee:	41 be 00 00 00 00    	mov    $0x0,%r14d
  80416033f4:	e9 8a 00 00 00       	jmpq   8041603483 <line_for_address+0x3cd>
          while (*(char *)program_addr) {
  80416033f9:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  80416033fe:	74 09                	je     8041603409 <line_for_address+0x353>
            ++program_addr;
  8041603400:	48 83 c3 01          	add    $0x1,%rbx
          while (*(char *)program_addr) {
  8041603404:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603407:	75 f7                	jne    8041603400 <line_for_address+0x34a>
          ++program_addr;
  8041603409:	48 83 c3 01          	add    $0x1,%rbx
  804160340d:	48 89 d8             	mov    %rbx,%rax
  count  = 0;
  8041603410:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603415:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603418:	48 83 c0 01          	add    $0x1,%rax
    count++;
  804160341c:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  804160341f:	84 c9                	test   %cl,%cl
  8041603421:	78 f2                	js     8041603415 <line_for_address+0x35f>
  return count;
  8041603423:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  8041603426:	48 01 d3             	add    %rdx,%rbx
  8041603429:	48 89 d8             	mov    %rbx,%rax
  count  = 0;
  804160342c:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603431:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603434:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603438:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  804160343b:	84 c9                	test   %cl,%cl
  804160343d:	78 f2                	js     8041603431 <line_for_address+0x37b>
  return count;
  804160343f:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  8041603442:	48 01 d3             	add    %rdx,%rbx
  8041603445:	48 89 d8             	mov    %rbx,%rax
  count  = 0;
  8041603448:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  804160344d:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603450:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603454:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041603457:	84 c9                	test   %cl,%cl
  8041603459:	78 f2                	js     804160344d <line_for_address+0x397>
  return count;
  804160345b:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  804160345e:	48 01 d3             	add    %rdx,%rbx
  8041603461:	eb 20                	jmp    8041603483 <line_for_address+0x3cd>
              get_unaligned(program_addr, uintptr_t);
  8041603463:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603468:	48 89 de             	mov    %rbx,%rsi
  804160346b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160346f:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603476:	00 00 00 
  8041603479:	ff d0                	callq  *%rax
  804160347b:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
          program_addr += sizeof(uintptr_t);
  804160347f:	49 8d 5d 09          	lea    0x9(%r13),%rbx
      assert(program_addr == opcode_end);
  8041603483:	49 39 dc             	cmp    %rbx,%r12
  8041603486:	0f 85 19 01 00 00    	jne    80416035a5 <line_for_address+0x4ef>
  while (program_addr < end_addr) {
  804160348c:	49 39 df             	cmp    %rbx,%r15
  804160348f:	0f 86 6e 03 00 00    	jbe    8041603803 <line_for_address+0x74d>
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  8041603495:	ba 01 00 00 00       	mov    $0x1,%edx
  804160349a:	48 89 de             	mov    %rbx,%rsi
  804160349d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034a1:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416034a8:	00 00 00 
  80416034ab:	ff d0                	callq  *%rax
  80416034ad:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  80416034b1:	48 8d 73 01          	lea    0x1(%rbx),%rsi
    if (opcode == 0) {
  80416034b5:	84 c0                	test   %al,%al
  80416034b7:	0f 85 1d 01 00 00    	jne    80416035da <line_for_address+0x524>
  80416034bd:	48 89 f2             	mov    %rsi,%rdx
  80416034c0:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  80416034c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416034cb:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416034d1:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416034d4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416034d8:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  80416034dc:	89 f8                	mov    %edi,%eax
  80416034de:	83 e0 7f             	and    $0x7f,%eax
  80416034e1:	d3 e0                	shl    %cl,%eax
  80416034e3:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416034e6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416034e9:	40 84 ff             	test   %dil,%dil
  80416034ec:	78 e3                	js     80416034d1 <line_for_address+0x41b>
  return count;
  80416034ee:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  80416034f1:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  80416034f4:	45 89 e4             	mov    %r12d,%r12d
  80416034f7:	4d 01 ec             	add    %r13,%r12
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  80416034fa:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034ff:	4c 89 ee             	mov    %r13,%rsi
  8041603502:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603506:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  804160350d:	00 00 00 
  8041603510:	ff d0                	callq  *%rax
  8041603512:	0f b6 4d c8          	movzbl -0x38(%rbp),%ecx
      program_addr += sizeof(Dwarf_Small);
  8041603516:	49 8d 5d 01          	lea    0x1(%r13),%rbx
      switch (opcode) {
  804160351a:	80 f9 02             	cmp    $0x2,%cl
  804160351d:	0f 84 40 ff ff ff    	je     8041603463 <line_for_address+0x3ad>
  8041603523:	80 f9 02             	cmp    $0x2,%cl
  8041603526:	0f 86 8e fe ff ff    	jbe    80416033ba <line_for_address+0x304>
  804160352c:	80 f9 03             	cmp    $0x3,%cl
  804160352f:	0f 84 c4 fe ff ff    	je     80416033f9 <line_for_address+0x343>
  8041603535:	80 f9 04             	cmp    $0x4,%cl
  8041603538:	75 21                	jne    804160355b <line_for_address+0x4a5>
  804160353a:	48 89 d8             	mov    %rbx,%rax
  804160353d:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603542:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603545:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603549:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  804160354c:	84 c9                	test   %cl,%cl
  804160354e:	78 f2                	js     8041603542 <line_for_address+0x48c>
  return count;
  8041603550:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  8041603553:	48 01 d3             	add    %rdx,%rbx
  8041603556:	e9 28 ff ff ff       	jmpq   8041603483 <line_for_address+0x3cd>
      switch (opcode) {
  804160355b:	0f b6 c9             	movzbl %cl,%ecx
          panic("Unknown opcode: %x", opcode);
  804160355e:	48 ba b4 5b 60 41 80 	movabs $0x8041605bb4,%rdx
  8041603565:	00 00 00 
  8041603568:	be 6b 00 00 00       	mov    $0x6b,%esi
  804160356d:	48 bf a1 5b 60 41 80 	movabs $0x8041605ba1,%rdi
  8041603574:	00 00 00 
  8041603577:	b8 00 00 00 00       	mov    $0x0,%eax
  804160357c:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041603583:	00 00 00 
  8041603586:	41 ff d0             	callq  *%r8
          last_state           = *state;
  8041603589:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160358c:	89 45 a0             	mov    %eax,-0x60(%rbp)
  804160358f:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
          state->line          = 1;
  8041603593:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
          state->address       = 0;
  804160359a:	41 be 00 00 00 00    	mov    $0x0,%r14d
  80416035a0:	e9 de fe ff ff       	jmpq   8041603483 <line_for_address+0x3cd>
      assert(program_addr == opcode_end);
  80416035a5:	48 b9 c7 5b 60 41 80 	movabs $0x8041605bc7,%rcx
  80416035ac:	00 00 00 
  80416035af:	48 ba d9 59 60 41 80 	movabs $0x80416059d9,%rdx
  80416035b6:	00 00 00 
  80416035b9:	be 6e 00 00 00       	mov    $0x6e,%esi
  80416035be:	48 bf a1 5b 60 41 80 	movabs $0x8041605ba1,%rdi
  80416035c5:	00 00 00 
  80416035c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416035cd:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  80416035d4:	00 00 00 
  80416035d7:	41 ff d0             	callq  *%r8
    } else if (opcode < info->opcode_base) {
  80416035da:	38 45 bf             	cmp    %al,-0x41(%rbp)
  80416035dd:	0f 86 ab 01 00 00    	jbe    804160378e <line_for_address+0x6d8>
      switch (opcode) {
  80416035e3:	3c 0c                	cmp    $0xc,%al
  80416035e5:	0f 87 75 01 00 00    	ja     8041603760 <line_for_address+0x6aa>
  80416035eb:	0f b6 d0             	movzbl %al,%edx
  80416035ee:	48 b9 60 5c 60 41 80 	movabs $0x8041605c60,%rcx
  80416035f5:	00 00 00 
  80416035f8:	ff 24 d1             	jmpq   *(%rcx,%rdx,8)
          if (last_state.address <= destination_addr &&
  80416035fb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416035ff:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041603603:	48 39 d8             	cmp    %rbx,%rax
  8041603606:	0f 82 c6 01 00 00    	jb     80416037d2 <line_for_address+0x71c>
  804160360c:	4c 39 f0             	cmp    %r14,%rax
  804160360f:	0f 82 e0 01 00 00    	jb     80416037f5 <line_for_address+0x73f>
          last_state           = *state;
  8041603615:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041603618:	89 45 a0             	mov    %eax,-0x60(%rbp)
  804160361b:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
    program_addr += sizeof(Dwarf_Small);
  804160361f:	48 89 f3             	mov    %rsi,%rbx
  8041603622:	e9 65 fe ff ff       	jmpq   804160348c <line_for_address+0x3d6>
      switch (opcode) {
  8041603627:	48 89 f2             	mov    %rsi,%rdx
  804160362a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8041603630:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603635:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160363b:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  804160363e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603642:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041603646:	89 f8                	mov    %edi,%eax
  8041603648:	83 e0 7f             	and    $0x7f,%eax
  804160364b:	d3 e0                	shl    %cl,%eax
  804160364d:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041603650:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603653:	40 84 ff             	test   %dil,%dil
  8041603656:	78 e3                	js     804160363b <line_for_address+0x585>
              info->minimum_instruction_length *
  8041603658:	45 89 c9             	mov    %r9d,%r9d
          state->address +=
  804160365b:	4d 01 ce             	add    %r9,%r14
  return count;
  804160365e:	4d 63 c0             	movslq %r8d,%r8
          program_addr += count;
  8041603661:	4a 8d 1c 06          	lea    (%rsi,%r8,1),%rbx
  8041603665:	e9 22 fe ff ff       	jmpq   804160348c <line_for_address+0x3d6>
      switch (opcode) {
  804160366a:	48 89 f2             	mov    %rsi,%rdx
  804160366d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8041603673:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603678:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160367e:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041603681:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  8041603685:	89 f8                	mov    %edi,%eax
  8041603687:	83 e0 7f             	and    $0x7f,%eax
  804160368a:	d3 e0                	shl    %cl,%eax
  804160368c:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160368f:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041603692:	41 83 c0 01          	add    $0x1,%r8d
    if (!(byte & 0x80))
  8041603696:	40 84 ff             	test   %dil,%dil
  8041603699:	78 e3                	js     804160367e <line_for_address+0x5c8>
  if ((shift < num_bits) && (byte & 0x40))
  804160369b:	83 f9 1f             	cmp    $0x1f,%ecx
  804160369e:	7f 10                	jg     80416036b0 <line_for_address+0x5fa>
  80416036a0:	40 f6 c7 40          	test   $0x40,%dil
  80416036a4:	74 0a                	je     80416036b0 <line_for_address+0x5fa>
    result |= (-1U << shift);
  80416036a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416036ab:	d3 e0                	shl    %cl,%eax
  80416036ad:	41 09 c1             	or     %eax,%r9d
          state->line += line_incr;
  80416036b0:	44 01 4d b8          	add    %r9d,-0x48(%rbp)
  return count;
  80416036b4:	4d 63 c0             	movslq %r8d,%r8
          program_addr += count;
  80416036b7:	4a 8d 1c 06          	lea    (%rsi,%r8,1),%rbx
  80416036bb:	e9 cc fd ff ff       	jmpq   804160348c <line_for_address+0x3d6>
      switch (opcode) {
  80416036c0:	48 89 f0             	mov    %rsi,%rax
  80416036c3:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416036c8:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  80416036cb:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416036cf:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  80416036d2:	84 c9                	test   %cl,%cl
  80416036d4:	78 f2                	js     80416036c8 <line_for_address+0x612>
  return count;
  80416036d6:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  80416036d9:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
  80416036dd:	e9 aa fd ff ff       	jmpq   804160348c <line_for_address+0x3d6>
      switch (opcode) {
  80416036e2:	48 89 f0             	mov    %rsi,%rax
  80416036e5:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416036ea:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  80416036ed:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416036f1:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  80416036f4:	84 c9                	test   %cl,%cl
  80416036f6:	78 f2                	js     80416036ea <line_for_address+0x634>
  return count;
  80416036f8:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  80416036fb:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
  80416036ff:	e9 88 fd ff ff       	jmpq   804160348c <line_for_address+0x3d6>
              adjusted_opcode / info->line_range;
  8041603704:	0f b7 45 bc          	movzwl -0x44(%rbp),%eax
  8041603708:	f6 75 be             	divb   -0x42(%rbp)
              info->minimum_instruction_length *
  804160370b:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  804160370e:	49 01 c6             	add    %rax,%r14
    program_addr += sizeof(Dwarf_Small);
  8041603711:	48 89 f3             	mov    %rsi,%rbx
  8041603714:	e9 73 fd ff ff       	jmpq   804160348c <line_for_address+0x3d6>
              get_unaligned(program_addr, Dwarf_Half);
  8041603719:	ba 02 00 00 00       	mov    $0x2,%edx
  804160371e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603722:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041603729:	00 00 00 
  804160372c:	ff d0                	callq  *%rax
          state->address += pc_inc;
  804160372e:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041603732:	49 01 c6             	add    %rax,%r14
          program_addr += sizeof(Dwarf_Half);
  8041603735:	48 83 c3 03          	add    $0x3,%rbx
  8041603739:	e9 4e fd ff ff       	jmpq   804160348c <line_for_address+0x3d6>
      switch (opcode) {
  804160373e:	48 89 f0             	mov    %rsi,%rax
  8041603741:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603746:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041603749:	48 83 c0 01          	add    $0x1,%rax
    count++;
  804160374d:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041603750:	84 c9                	test   %cl,%cl
  8041603752:	78 f2                	js     8041603746 <line_for_address+0x690>
  return count;
  8041603754:	48 63 d2             	movslq %edx,%rdx
          program_addr += count;
  8041603757:	48 8d 1c 16          	lea    (%rsi,%rdx,1),%rbx
  804160375b:	e9 2c fd ff ff       	jmpq   804160348c <line_for_address+0x3d6>
      switch (opcode) {
  8041603760:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603763:	48 ba b4 5b 60 41 80 	movabs $0x8041605bb4,%rdx
  804160376a:	00 00 00 
  804160376d:	be c1 00 00 00       	mov    $0xc1,%esi
  8041603772:	48 bf a1 5b 60 41 80 	movabs $0x8041605ba1,%rdi
  8041603779:	00 00 00 
  804160377c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603781:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041603788:	00 00 00 
  804160378b:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  804160378e:	2a 45 bf             	sub    -0x41(%rbp),%al
                      (adjusted_opcode % info->line_range));
  8041603791:	0f b6 c0             	movzbl %al,%eax
  8041603794:	f6 75 be             	divb   -0x42(%rbp)
  8041603797:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  804160379a:	03 55 a4             	add    -0x5c(%rbp),%edx
  804160379d:	01 55 b8             	add    %edx,-0x48(%rbp)
          info->minimum_instruction_length *
  80416037a0:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  80416037a3:	49 01 c6             	add    %rax,%r14
      if (last_state.address <= destination_addr &&
  80416037a6:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416037aa:	4c 39 f0             	cmp    %r14,%rax
  80416037ad:	73 09                	jae    80416037b8 <line_for_address+0x702>
  80416037af:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  80416037b3:	48 39 d8             	cmp    %rbx,%rax
  80416037b6:	73 45                	jae    80416037fd <line_for_address+0x747>
      last_state = *state;
  80416037b8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416037bb:	89 45 a0             	mov    %eax,-0x60(%rbp)
  80416037be:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
    program_addr += sizeof(Dwarf_Small);
  80416037c2:	48 89 f3             	mov    %rsi,%rbx
  80416037c5:	e9 c2 fc ff ff       	jmpq   804160348c <line_for_address+0x3d6>
  80416037ca:	48 89 f3             	mov    %rsi,%rbx
  80416037cd:	e9 ba fc ff ff       	jmpq   804160348c <line_for_address+0x3d6>
          last_state           = *state;
  80416037d2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416037d5:	89 45 a0             	mov    %eax,-0x60(%rbp)
  80416037d8:	4c 89 75 b0          	mov    %r14,-0x50(%rbp)
    program_addr += sizeof(Dwarf_Small);
  80416037dc:	48 89 f3             	mov    %rsi,%rbx
  80416037df:	e9 a8 fc ff ff       	jmpq   804160348c <line_for_address+0x3d6>
  struct Line_Number_State current_state = {
  80416037e4:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%rbp)
  80416037eb:	eb 16                	jmp    8041603803 <line_for_address+0x74d>
          if (last_state.address <= destination_addr &&
  80416037ed:	8b 45 a0             	mov    -0x60(%rbp),%eax
  80416037f0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416037f3:	eb 0e                	jmp    8041603803 <line_for_address+0x74d>
          if (last_state.address <= destination_addr &&
  80416037f5:	8b 45 a0             	mov    -0x60(%rbp),%eax
  80416037f8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416037fb:	eb 06                	jmp    8041603803 <line_for_address+0x74d>
      if (last_state.address <= destination_addr &&
  80416037fd:	8b 45 a0             	mov    -0x60(%rbp),%eax
  8041603800:	89 45 b8             	mov    %eax,-0x48(%rbp)
  *lineno_store = current_state.line;
  8041603803:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041603807:	8b 75 b8             	mov    -0x48(%rbp),%esi
  804160380a:	89 30                	mov    %esi,(%rax)
  return 0;
  804160380c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603811:	e9 56 fa ff ff       	jmpq   804160326c <line_for_address+0x1b6>
    return -E_INVAL;
  8041603816:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160381b:	e9 4c fa ff ff       	jmpq   804160326c <line_for_address+0x1b6>

0000008041603820 <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  8041603820:	55                   	push   %rbp
  8041603821:	48 89 e5             	mov    %rsp,%rbp
  8041603824:	41 55                	push   %r13
  8041603826:	41 54                	push   %r12
  8041603828:	53                   	push   %rbx
  8041603829:	48 83 ec 08          	sub    $0x8,%rsp
  804160382d:	48 bb c0 5f 60 41 80 	movabs $0x8041605fc0,%rbx
  8041603834:	00 00 00 
  8041603837:	49 bd 38 60 60 41 80 	movabs $0x8041606038,%r13
  804160383e:	00 00 00 
  int i;

  for (i = 0; i < NCOMMANDS; i++)
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  8041603841:	49 bc f3 42 60 41 80 	movabs $0x80416042f3,%r12
  8041603848:	00 00 00 
  804160384b:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  804160384f:	48 8b 33             	mov    (%rbx),%rsi
  8041603852:	48 bf c8 5c 60 41 80 	movabs $0x8041605cc8,%rdi
  8041603859:	00 00 00 
  804160385c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603861:	41 ff d4             	callq  *%r12
  8041603864:	48 83 c3 18          	add    $0x18,%rbx
  for (i = 0; i < NCOMMANDS; i++)
  8041603868:	4c 39 eb             	cmp    %r13,%rbx
  804160386b:	75 de                	jne    804160384b <mon_help+0x2b>
  return 0;
}
  804160386d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603872:	48 83 c4 08          	add    $0x8,%rsp
  8041603876:	5b                   	pop    %rbx
  8041603877:	41 5c                	pop    %r12
  8041603879:	41 5d                	pop    %r13
  804160387b:	5d                   	pop    %rbp
  804160387c:	c3                   	retq   

000000804160387d <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  804160387d:	55                   	push   %rbp
  804160387e:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603881:	48 bf d1 5c 60 41 80 	movabs $0x8041605cd1,%rdi
  8041603888:	00 00 00 
  804160388b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603890:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041603897:	00 00 00 
  804160389a:	ff d2                	callq  *%rdx
  return 0;
}
  804160389c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038a1:	5d                   	pop    %rbp
  80416038a2:	c3                   	retq   

00000080416038a3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  80416038a3:	55                   	push   %rbp
  80416038a4:	48 89 e5             	mov    %rsp,%rbp
  80416038a7:	41 54                	push   %r12
  80416038a9:	53                   	push   %rbx
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  80416038aa:	48 bf d9 5c 60 41 80 	movabs $0x8041605cd9,%rdi
  80416038b1:	00 00 00 
  80416038b4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038b9:	48 bb f3 42 60 41 80 	movabs $0x80416042f3,%rbx
  80416038c0:	00 00 00 
  80416038c3:	ff d3                	callq  *%rbx
  cprintf("  _head64                  %08lx (phys)\n",
  80416038c5:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  80416038cc:	00 00 00 
  80416038cf:	48 bf 20 5e 60 41 80 	movabs $0x8041605e20,%rdi
  80416038d6:	00 00 00 
  80416038d9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038de:	ff d3                	callq  *%rbx
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  80416038e0:	49 bc 00 00 60 41 80 	movabs $0x8041600000,%r12
  80416038e7:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  80416038ea:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  80416038f1:	00 00 00 
  80416038f4:	4c 89 e6             	mov    %r12,%rsi
  80416038f7:	48 bf 50 5e 60 41 80 	movabs $0x8041605e50,%rdi
  80416038fe:	00 00 00 
  8041603901:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603906:	ff d3                	callq  *%rbx
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603908:	48 ba a8 56 60 01 00 	movabs $0x16056a8,%rdx
  804160390f:	00 00 00 
  8041603912:	48 be a8 56 60 41 80 	movabs $0x80416056a8,%rsi
  8041603919:	00 00 00 
  804160391c:	48 bf 78 5e 60 41 80 	movabs $0x8041605e78,%rdi
  8041603923:	00 00 00 
  8041603926:	b8 00 00 00 00       	mov    $0x0,%eax
  804160392b:	ff d3                	callq  *%rbx
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  804160392d:	48 ba 60 2f 62 01 00 	movabs $0x1622f60,%rdx
  8041603934:	00 00 00 
  8041603937:	48 be 60 2f 62 41 80 	movabs $0x8041622f60,%rsi
  804160393e:	00 00 00 
  8041603941:	48 bf a0 5e 60 41 80 	movabs $0x8041605ea0,%rdi
  8041603948:	00 00 00 
  804160394b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603950:	ff d3                	callq  *%rbx
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603952:	48 ba 00 60 62 01 00 	movabs $0x1626000,%rdx
  8041603959:	00 00 00 
  804160395c:	48 be 00 60 62 41 80 	movabs $0x8041626000,%rsi
  8041603963:	00 00 00 
  8041603966:	48 bf c8 5e 60 41 80 	movabs $0x8041605ec8,%rdi
  804160396d:	00 00 00 
  8041603970:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603975:	ff d3                	callq  *%rbx
          (unsigned long)end, (unsigned long)end - KERNBASE);
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603977:	48 be ff 63 62 41 80 	movabs $0x80416263ff,%rsi
  804160397e:	00 00 00 
  8041603981:	4c 29 e6             	sub    %r12,%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603984:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603988:	48 bf f0 5e 60 41 80 	movabs $0x8041605ef0,%rdi
  804160398f:	00 00 00 
  8041603992:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603997:	ff d3                	callq  *%rbx
  return 0;
}
  8041603999:	b8 00 00 00 00       	mov    $0x0,%eax
  804160399e:	5b                   	pop    %rbx
  804160399f:	41 5c                	pop    %r12
  80416039a1:	5d                   	pop    %rbp
  80416039a2:	c3                   	retq   

00000080416039a3 <mon_evenbeyond>:

int
mon_evenbeyond(int argc, char **argv, struct Trapframe *tf) {
  80416039a3:	55                   	push   %rbp
  80416039a4:	48 89 e5             	mov    %rsp,%rbp
  cprintf("My CPU load is OVER %o \n", 9000);
  80416039a7:	be 28 23 00 00       	mov    $0x2328,%esi
  80416039ac:	48 bf f2 5c 60 41 80 	movabs $0x8041605cf2,%rdi
  80416039b3:	00 00 00 
  80416039b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039bb:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416039c2:	00 00 00 
  80416039c5:	ff d2                	callq  *%rdx
  return 0;
}
  80416039c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039cc:	5d                   	pop    %rbp
  80416039cd:	c3                   	retq   

00000080416039ce <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  80416039ce:	55                   	push   %rbp
  80416039cf:	48 89 e5             	mov    %rsp,%rbp
  80416039d2:	41 57                	push   %r15
  80416039d4:	41 56                	push   %r14
  80416039d6:	41 55                	push   %r13
  80416039d8:	41 54                	push   %r12
  80416039da:	53                   	push   %rbx
  80416039db:	48 81 ec 28 02 00 00 	sub    $0x228,%rsp
  uint64_t *rbp = 0x0;
  uint64_t rip  = 0x0;

  struct Ripdebuginfo info;

  cprintf("Stack backtrace:\n");
  80416039e2:	48 bf 0b 5d 60 41 80 	movabs $0x8041605d0b,%rdi
  80416039e9:	00 00 00 
  80416039ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039f1:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416039f8:	00 00 00 
  80416039fb:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  80416039fd:	48 89 e8             	mov    %rbp,%rax
  rbp = (uint64_t *)read_rbp();
  rip = rbp[1];

  if (rbp == 0x0 || rip == 0x0) {
  8041603a00:	48 83 78 08 00       	cmpq   $0x0,0x8(%rax)
  8041603a05:	0f 84 a2 00 00 00    	je     8041603aad <mon_backtrace+0xdf>
  8041603a0b:	48 89 c3             	mov    %rax,%rbx
  8041603a0e:	48 85 c0             	test   %rax,%rax
  8041603a11:	0f 84 96 00 00 00    	je     8041603aad <mon_backtrace+0xdf>
    return -1;
  }

  do {
    rip = rbp[1];
    debuginfo_rip(rip, &info);
  8041603a17:	49 bf 7e 45 60 41 80 	movabs $0x804160457e,%r15
  8041603a1e:	00 00 00 

    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  8041603a21:	49 bd f3 42 60 41 80 	movabs $0x80416042f3,%r13
  8041603a28:	00 00 00 
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  8041603a2b:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603a32:	4c 8d b0 04 01 00 00 	lea    0x104(%rax),%r14
    rip = rbp[1];
  8041603a39:	4c 8b 63 08          	mov    0x8(%rbx),%r12
    debuginfo_rip(rip, &info);
  8041603a3d:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603a44:	4c 89 e7             	mov    %r12,%rdi
  8041603a47:	41 ff d7             	callq  *%r15
    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  8041603a4a:	4c 89 e2             	mov    %r12,%rdx
  8041603a4d:	48 89 de             	mov    %rbx,%rsi
  8041603a50:	48 bf 1d 5d 60 41 80 	movabs $0x8041605d1d,%rdi
  8041603a57:	00 00 00 
  8041603a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a5f:	41 ff d5             	callq  *%r13
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  8041603a62:	4d 89 e1             	mov    %r12,%r9
  8041603a65:	4c 2b 4d b8          	sub    -0x48(%rbp),%r9
  8041603a69:	4d 89 f0             	mov    %r14,%r8
  8041603a6c:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041603a6f:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603a75:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603a7c:	48 bf 37 5d 60 41 80 	movabs $0x8041605d37,%rdi
  8041603a83:	00 00 00 
  8041603a86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a8b:	41 ff d5             	callq  *%r13
            info.rip_fn_namelen, info.rip_fn_name, (rip - info.rip_fn_addr));
    // cprintf(" args:%d \n", info.rip_fn_narg);
    rbp = (uint64_t *)rbp[0];
  8041603a8e:	48 8b 1b             	mov    (%rbx),%rbx

  } while (rbp);
  8041603a91:	48 85 db             	test   %rbx,%rbx
  8041603a94:	75 a3                	jne    8041603a39 <mon_backtrace+0x6b>

  return 0;
  8041603a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603a9b:	48 81 c4 28 02 00 00 	add    $0x228,%rsp
  8041603aa2:	5b                   	pop    %rbx
  8041603aa3:	41 5c                	pop    %r12
  8041603aa5:	41 5d                	pop    %r13
  8041603aa7:	41 5e                	pop    %r14
  8041603aa9:	41 5f                	pop    %r15
  8041603aab:	5d                   	pop    %rbp
  8041603aac:	c3                   	retq   
    cprintf("JOS: ERR: Couldn't obtain backtrace...\n");
  8041603aad:	48 bf 20 5f 60 41 80 	movabs $0x8041605f20,%rdi
  8041603ab4:	00 00 00 
  8041603ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603abc:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041603ac3:	00 00 00 
  8041603ac6:	ff d2                	callq  *%rdx
    return -1;
  8041603ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041603acd:	eb cc                	jmp    8041603a9b <mon_backtrace+0xcd>

0000008041603acf <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603acf:	55                   	push   %rbp
  8041603ad0:	48 89 e5             	mov    %rsp,%rbp
  8041603ad3:	41 57                	push   %r15
  8041603ad5:	41 56                	push   %r14
  8041603ad7:	41 55                	push   %r13
  8041603ad9:	41 54                	push   %r12
  8041603adb:	53                   	push   %rbx
  8041603adc:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603ae3:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603aea:	48 bf 48 5f 60 41 80 	movabs $0x8041605f48,%rdi
  8041603af1:	00 00 00 
  8041603af4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603af9:	48 bb f3 42 60 41 80 	movabs $0x80416042f3,%rbx
  8041603b00:	00 00 00 
  8041603b03:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603b05:	48 bf 70 5f 60 41 80 	movabs $0x8041605f70,%rdi
  8041603b0c:	00 00 00 
  8041603b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b14:	ff d3                	callq  *%rbx

  while (1) {
    buf = readline("K> ");
  8041603b16:	49 bd 36 50 60 41 80 	movabs $0x8041605036,%r13
  8041603b1d:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603b20:	48 bb 0d 53 60 41 80 	movabs $0x804160530d,%rbx
  8041603b27:	00 00 00 
  8041603b2a:	e9 04 01 00 00       	jmpq   8041603c33 <monitor+0x164>
  8041603b2f:	40 0f be f6          	movsbl %sil,%esi
  8041603b33:	48 bf 59 5d 60 41 80 	movabs $0x8041605d59,%rdi
  8041603b3a:	00 00 00 
  8041603b3d:	ff d3                	callq  *%rbx
  8041603b3f:	48 85 c0             	test   %rax,%rax
  8041603b42:	74 0d                	je     8041603b51 <monitor+0x82>
      *buf++ = 0;
  8041603b44:	41 c6 06 00          	movb   $0x0,(%r14)
  8041603b48:	45 89 e7             	mov    %r12d,%r15d
  8041603b4b:	4d 8d 76 01          	lea    0x1(%r14),%r14
  8041603b4f:	eb 4b                	jmp    8041603b9c <monitor+0xcd>
    if (*buf == 0)
  8041603b51:	41 80 3e 00          	cmpb   $0x0,(%r14)
  8041603b55:	74 51                	je     8041603ba8 <monitor+0xd9>
    if (argc == MAXARGS - 1) {
  8041603b57:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603b5b:	0f 84 b7 00 00 00    	je     8041603c18 <monitor+0x149>
    argv[argc++] = buf;
  8041603b61:	45 8d 7c 24 01       	lea    0x1(%r12),%r15d
  8041603b66:	4d 63 e4             	movslq %r12d,%r12
  8041603b69:	4e 89 b4 e5 50 ff ff 	mov    %r14,-0xb0(%rbp,%r12,8)
  8041603b70:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603b71:	41 0f b6 36          	movzbl (%r14),%esi
  8041603b75:	40 84 f6             	test   %sil,%sil
  8041603b78:	74 22                	je     8041603b9c <monitor+0xcd>
  8041603b7a:	40 0f be f6          	movsbl %sil,%esi
  8041603b7e:	48 bf 59 5d 60 41 80 	movabs $0x8041605d59,%rdi
  8041603b85:	00 00 00 
  8041603b88:	ff d3                	callq  *%rbx
  8041603b8a:	48 85 c0             	test   %rax,%rax
  8041603b8d:	75 0d                	jne    8041603b9c <monitor+0xcd>
      buf++;
  8041603b8f:	49 83 c6 01          	add    $0x1,%r14
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603b93:	41 0f b6 36          	movzbl (%r14),%esi
  8041603b97:	40 84 f6             	test   %sil,%sil
  8041603b9a:	75 de                	jne    8041603b7a <monitor+0xab>
      *buf++ = 0;
  8041603b9c:	45 89 fc             	mov    %r15d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603b9f:	41 0f b6 36          	movzbl (%r14),%esi
  8041603ba3:	40 84 f6             	test   %sil,%sil
  8041603ba6:	75 87                	jne    8041603b2f <monitor+0x60>
  argv[argc] = 0;
  8041603ba8:	49 63 c4             	movslq %r12d,%rax
  8041603bab:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041603bb2:	ff 00 00 00 00 
  if (argc == 0)
  8041603bb7:	45 85 e4             	test   %r12d,%r12d
  8041603bba:	74 77                	je     8041603c33 <monitor+0x164>
  8041603bbc:	49 bf c0 5f 60 41 80 	movabs $0x8041605fc0,%r15
  8041603bc3:	00 00 00 
  8041603bc6:	41 be 00 00 00 00    	mov    $0x0,%r14d
    if (strcmp(argv[0], commands[i].name) == 0)
  8041603bcc:	49 8b 37             	mov    (%r15),%rsi
  8041603bcf:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041603bd6:	48 b8 9a 52 60 41 80 	movabs $0x804160529a,%rax
  8041603bdd:	00 00 00 
  8041603be0:	ff d0                	callq  *%rax
  8041603be2:	85 c0                	test   %eax,%eax
  8041603be4:	74 78                	je     8041603c5e <monitor+0x18f>
  for (i = 0; i < NCOMMANDS; i++) {
  8041603be6:	41 83 c6 01          	add    $0x1,%r14d
  8041603bea:	49 83 c7 18          	add    $0x18,%r15
  8041603bee:	41 83 fe 05          	cmp    $0x5,%r14d
  8041603bf2:	75 d8                	jne    8041603bcc <monitor+0xfd>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041603bf4:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041603bfb:	48 bf 7b 5d 60 41 80 	movabs $0x8041605d7b,%rdi
  8041603c02:	00 00 00 
  8041603c05:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c0a:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041603c11:	00 00 00 
  8041603c14:	ff d2                	callq  *%rdx
  8041603c16:	eb 1b                	jmp    8041603c33 <monitor+0x164>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041603c18:	be 10 00 00 00       	mov    $0x10,%esi
  8041603c1d:	48 bf 5e 5d 60 41 80 	movabs $0x8041605d5e,%rdi
  8041603c24:	00 00 00 
  8041603c27:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041603c2e:	00 00 00 
  8041603c31:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  8041603c33:	48 bf 55 5d 60 41 80 	movabs $0x8041605d55,%rdi
  8041603c3a:	00 00 00 
  8041603c3d:	41 ff d5             	callq  *%r13
  8041603c40:	49 89 c6             	mov    %rax,%r14
    if (buf != NULL)
  8041603c43:	48 85 c0             	test   %rax,%rax
  8041603c46:	74 eb                	je     8041603c33 <monitor+0x164>
  argv[argc] = 0;
  8041603c48:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  8041603c4f:	00 00 00 00 
  argc       = 0;
  8041603c53:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041603c59:	e9 41 ff ff ff       	jmpq   8041603b9f <monitor+0xd0>
      return commands[i].func(argc, argv, tf);
  8041603c5e:	4d 63 f6             	movslq %r14d,%r14
  8041603c61:	4b 8d 0c 76          	lea    (%r14,%r14,2),%rcx
  8041603c65:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  8041603c6c:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  8041603c73:	44 89 e7             	mov    %r12d,%edi
  8041603c76:	48 b8 c0 5f 60 41 80 	movabs $0x8041605fc0,%rax
  8041603c7d:	00 00 00 
  8041603c80:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  8041603c84:	85 c0                	test   %eax,%eax
  8041603c86:	79 ab                	jns    8041603c33 <monitor+0x164>
        break;
  }
}
  8041603c88:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041603c8f:	5b                   	pop    %rbx
  8041603c90:	41 5c                	pop    %r12
  8041603c92:	41 5d                	pop    %r13
  8041603c94:	41 5e                	pop    %r14
  8041603c96:	41 5f                	pop    %r15
  8041603c98:	5d                   	pop    %rbp
  8041603c99:	c3                   	retq   

0000008041603c9a <envid2env>:
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  8041603c9a:	55                   	push   %rbp
  8041603c9b:	48 89 e5             	mov    %rsp,%rbp
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
  8041603c9e:	85 ff                	test   %edi,%edi
  8041603ca0:	74 63                	je     8041603d05 <envid2env+0x6b>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  8041603ca2:	89 f9                	mov    %edi,%ecx
  8041603ca4:	83 e1 1f             	and    $0x1f,%ecx
  8041603ca7:	48 8d 04 cd 00 00 00 	lea    0x0(,%rcx,8),%rax
  8041603cae:	00 
  8041603caf:	48 29 c8             	sub    %rcx,%rax
  8041603cb2:	48 c1 e0 05          	shl    $0x5,%rax
  8041603cb6:	48 b9 88 77 61 41 80 	movabs $0x8041617788,%rcx
  8041603cbd:	00 00 00 
  8041603cc0:	48 8b 09             	mov    (%rcx),%rcx
  8041603cc3:	48 01 c8             	add    %rcx,%rax
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  8041603cc6:	83 b8 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rax)
  8041603ccd:	74 4a                	je     8041603d19 <envid2env+0x7f>
  8041603ccf:	3b b8 c8 00 00 00    	cmp    0xc8(%rax),%edi
  8041603cd5:	75 42                	jne    8041603d19 <envid2env+0x7f>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  8041603cd7:	84 d2                	test   %dl,%dl
  8041603cd9:	74 20                	je     8041603cfb <envid2env+0x61>
  8041603cdb:	48 ba c0 31 62 41 80 	movabs $0x80416231c0,%rdx
  8041603ce2:	00 00 00 
  8041603ce5:	48 8b 12             	mov    (%rdx),%rdx
  8041603ce8:	48 39 d0             	cmp    %rdx,%rax
  8041603ceb:	74 0e                	je     8041603cfb <envid2env+0x61>
  8041603ced:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  8041603cf3:	39 90 cc 00 00 00    	cmp    %edx,0xcc(%rax)
  8041603cf9:	75 2c                	jne    8041603d27 <envid2env+0x8d>
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  8041603cfb:	48 89 06             	mov    %rax,(%rsi)
  return 0;
  8041603cfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603d03:	5d                   	pop    %rbp
  8041603d04:	c3                   	retq   
    *env_store = curenv;
  8041603d05:	48 a1 c0 31 62 41 80 	movabs 0x80416231c0,%rax
  8041603d0c:	00 00 00 
  8041603d0f:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  8041603d12:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d17:	eb ea                	jmp    8041603d03 <envid2env+0x69>
    *env_store = 0;
  8041603d19:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603d20:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603d25:	eb dc                	jmp    8041603d03 <envid2env+0x69>
    *env_store = 0;
  8041603d27:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603d2e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603d33:	eb ce                	jmp    8041603d03 <envid2env+0x69>

0000008041603d35 <env_init_percpu>:
  env_init_percpu();
};

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  8041603d35:	55                   	push   %rbp
  8041603d36:	48 89 e5             	mov    %rsp,%rbp
  8041603d39:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  8041603d3a:	48 b8 20 77 61 41 80 	movabs $0x8041617720,%rax
  8041603d41:	00 00 00 
  8041603d44:	0f 01 10             	lgdt   (%rax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  8041603d47:	b8 33 00 00 00       	mov    $0x33,%eax
  8041603d4c:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  8041603d4e:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  8041603d50:	b8 10 00 00 00       	mov    $0x10,%eax
  8041603d55:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041603d57:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041603d59:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  8041603d5b:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041603d60:	53                   	push   %rbx
  8041603d61:	48 b8 6e 3d 60 41 80 	movabs $0x8041603d6e,%rax
  8041603d68:	00 00 00 
  8041603d6b:	50                   	push   %rax
  8041603d6c:	48 cb                	lretq  
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  8041603d6e:	66 b8 00 00          	mov    $0x0,%ax
  8041603d72:	0f 00 d0             	lldt   %ax
               :
               :
               : "cc", "memory");
}
  8041603d75:	5b                   	pop    %rbx
  8041603d76:	5d                   	pop    %rbp
  8041603d77:	c3                   	retq   

0000008041603d78 <env_init>:
env_init(void) {
  8041603d78:	55                   	push   %rbp
  8041603d79:	48 89 e5             	mov    %rsp,%rbp
  env_free_list = envs; // env_free_list = &envs[0]; ?????
  8041603d7c:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  8041603d83:	00 00 00 
  8041603d86:	48 a3 c8 31 62 41 80 	movabs %rax,0x80416231c8
  8041603d8d:	00 00 00 
  8041603d90:	be 00 00 00 00       	mov    $0x0,%esi
  for (uint32_t i = 0; i < NENV; ++i) {
  8041603d95:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    envs[i].env_status = ENV_FREE;
  8041603d9b:	49 b9 88 77 61 41 80 	movabs $0x8041617788,%r9
  8041603da2:	00 00 00 
    envs[i].env_tf = (const struct Trapframe){ 0 };
  8041603da5:	b8 00 00 00 00       	mov    $0x0,%eax
    envs[i].env_status = ENV_FREE;
  8041603daa:	49 8b 09             	mov    (%r9),%rcx
  8041603dad:	48 8d 14 31          	lea    (%rcx,%rsi,1),%rdx
  8041603db1:	c7 82 d4 00 00 00 00 	movl   $0x0,0xd4(%rdx)
  8041603db8:	00 00 00 
    if (i != NENV - 1) {
  8041603dbb:	41 83 f8 1f          	cmp    $0x1f,%r8d
  8041603dbf:	74 70                	je     8041603e31 <env_init+0xb9>
      envs[i].env_link = &envs[i + 1];
  8041603dc1:	48 8d 8c 31 e0 00 00 	lea    0xe0(%rcx,%rsi,1),%rcx
  8041603dc8:	00 
  8041603dc9:	48 89 8a c0 00 00 00 	mov    %rcx,0xc0(%rdx)
    envs[i].env_type = ENV_TYPE_KERNEL;
  8041603dd0:	c7 82 d0 00 00 00 01 	movl   $0x1,0xd0(%rdx)
  8041603dd7:	00 00 00 
    envs[i].env_id = 0;
  8041603dda:	c7 82 c8 00 00 00 00 	movl   $0x0,0xc8(%rdx)
  8041603de1:	00 00 00 
    envs[i].env_parent_id = 0;
  8041603de4:	c7 82 cc 00 00 00 00 	movl   $0x0,0xcc(%rdx)
  8041603deb:	00 00 00 
    envs[i].env_tf = (const struct Trapframe){ 0 };
  8041603dee:	b9 18 00 00 00       	mov    $0x18,%ecx
  8041603df3:	48 89 d7             	mov    %rdx,%rdi
  8041603df6:	f3 48 ab             	rep stos %rax,%es:(%rdi)
    envs[i].env_tf.tf_rflags = read_rflags();
  8041603df9:	48 89 f2             	mov    %rsi,%rdx
  8041603dfc:	49 03 11             	add    (%r9),%rdx
  __asm __volatile("pushfq; popq %0"
  8041603dff:	9c                   	pushfq 
  8041603e00:	59                   	pop    %rcx
  8041603e01:	48 89 8a a8 00 00 00 	mov    %rcx,0xa8(%rdx)
    envs[i].env_runs = 0;
  8041603e08:	c7 82 d8 00 00 00 00 	movl   $0x0,0xd8(%rdx)
  8041603e0f:	00 00 00 
  for (uint32_t i = 0; i < NENV; ++i) {
  8041603e12:	41 83 c0 01          	add    $0x1,%r8d
  8041603e16:	48 81 c6 e0 00 00 00 	add    $0xe0,%rsi
  8041603e1d:	41 83 f8 20          	cmp    $0x20,%r8d
  8041603e21:	75 87                	jne    8041603daa <env_init+0x32>
  env_init_percpu();
  8041603e23:	48 b8 35 3d 60 41 80 	movabs $0x8041603d35,%rax
  8041603e2a:	00 00 00 
  8041603e2d:	ff d0                	callq  *%rax
};
  8041603e2f:	5d                   	pop    %rbp
  8041603e30:	c3                   	retq   
      envs[i].env_link = NULL;
  8041603e31:	48 c7 82 c0 00 00 00 	movq   $0x0,0xc0(%rdx)
  8041603e38:	00 00 00 00 
  8041603e3c:	eb 92                	jmp    8041603dd0 <env_init+0x58>

0000008041603e3e <env_alloc>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  8041603e3e:	55                   	push   %rbp
  8041603e3f:	48 89 e5             	mov    %rsp,%rbp
  8041603e42:	41 54                	push   %r12
  8041603e44:	53                   	push   %rbx
  int32_t generation;
  struct Env *e;

  if (!(e = env_free_list)) {
  8041603e45:	48 b8 c8 31 62 41 80 	movabs $0x80416231c8,%rax
  8041603e4c:	00 00 00 
  8041603e4f:	48 8b 18             	mov    (%rax),%rbx
  8041603e52:	48 85 db             	test   %rbx,%rbx
  8041603e55:	0f 84 f8 00 00 00    	je     8041603f53 <env_alloc+0x115>
  8041603e5b:	49 89 fc             	mov    %rdi,%r12
    return -E_NO_FREE_ENV;
  }

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  8041603e5e:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  8041603e64:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041603e69:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  8041603e6c:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041603e71:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  8041603e74:	48 ba 88 77 61 41 80 	movabs $0x8041617788,%rdx
  8041603e7b:	00 00 00 
  8041603e7e:	48 89 d9             	mov    %rbx,%rcx
  8041603e81:	48 2b 0a             	sub    (%rdx),%rcx
  8041603e84:	48 89 ca             	mov    %rcx,%rdx
  8041603e87:	48 c1 fa 05          	sar    $0x5,%rdx
  8041603e8b:	69 d2 b7 6d db b6    	imul   $0xb6db6db7,%edx,%edx
  8041603e91:	09 d0                	or     %edx,%eax
  8041603e93:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
  8041603e99:	89 b3 cc 00 00 00    	mov    %esi,0xcc(%rbx)
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
  8041603e9f:	c7 83 d0 00 00 00 01 	movl   $0x1,0xd0(%rbx)
  8041603ea6:	00 00 00 
#else
#endif
  e->env_status = ENV_RUNNABLE;
  8041603ea9:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  8041603eb0:	00 00 00 
  e->env_runs   = 0;
  8041603eb3:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  8041603eba:	00 00 00 

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  8041603ebd:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041603ec2:	be 00 00 00 00       	mov    $0x0,%esi
  8041603ec7:	48 89 df             	mov    %rbx,%rdi
  8041603eca:	48 b8 6c 53 60 41 80 	movabs $0x804160536c,%rax
  8041603ed1:	00 00 00 
  8041603ed4:	ff d0                	callq  *%rax
  // Requestor Privilege Level (RPL); 3 means user mode, 0 - kernel mode.  When
  // we switch privilege levels, the hardware does various
  // checks involving the RPL and the Descriptor Privilege Level
  // (DPL) stored in the descriptors themselves.
#ifdef CONFIG_KSPACE
  e->env_tf.tf_ds = GD_KD | 0;
  8041603ed6:	66 c7 83 80 00 00 00 	movw   $0x10,0x80(%rbx)
  8041603edd:	10 00 
  e->env_tf.tf_es = GD_KD | 0;
  8041603edf:	66 c7 43 78 10 00    	movw   $0x10,0x78(%rbx)
  e->env_tf.tf_ss = GD_KD | 0;
  8041603ee5:	66 c7 83 b8 00 00 00 	movw   $0x10,0xb8(%rbx)
  8041603eec:	10 00 
  e->env_tf.tf_cs = GD_KT | 0;
  8041603eee:	66 c7 83 a0 00 00 00 	movw   $0x8,0xa0(%rbx)
  8041603ef5:	08 00 
#else
#endif
  // You will set e->env_tf.tf_rip later.

  // commit the allocation 
  env_free_list = e->env_link;
  8041603ef7:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  8041603efe:	48 a3 c8 31 62 41 80 	movabs %rax,0x80416231c8
  8041603f05:	00 00 00 
  *newenv_store = e;
  8041603f08:	49 89 1c 24          	mov    %rbx,(%r12)

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603f0c:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  8041603f12:	48 a1 c0 31 62 41 80 	movabs 0x80416231c0,%rax
  8041603f19:	00 00 00 
  8041603f1c:	48 85 c0             	test   %rax,%rax
  8041603f1f:	74 2b                	je     8041603f4c <env_alloc+0x10e>
  8041603f21:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041603f27:	48 bf 38 60 60 41 80 	movabs $0x8041606038,%rdi
  8041603f2e:	00 00 00 
  8041603f31:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f36:	48 b9 f3 42 60 41 80 	movabs $0x80416042f3,%rcx
  8041603f3d:	00 00 00 
  8041603f40:	ff d1                	callq  *%rcx

  return 0;
  8041603f42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603f47:	5b                   	pop    %rbx
  8041603f48:	41 5c                	pop    %r12
  8041603f4a:	5d                   	pop    %rbp
  8041603f4b:	c3                   	retq   
  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603f4c:	be 00 00 00 00       	mov    $0x0,%esi
  8041603f51:	eb d4                	jmp    8041603f27 <env_alloc+0xe9>
    return -E_NO_FREE_ENV;
  8041603f53:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  8041603f58:	eb ed                	jmp    8041603f47 <env_alloc+0x109>

0000008041603f5a <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  8041603f5a:	55                   	push   %rbp
  8041603f5b:	48 89 e5             	mov    %rsp,%rbp
  8041603f5e:	41 57                	push   %r15
  8041603f60:	41 56                	push   %r14
  8041603f62:	41 55                	push   %r13
  8041603f64:	41 54                	push   %r12
  8041603f66:	53                   	push   %rbx
  8041603f67:	48 83 ec 38          	sub    $0x38,%rsp
  8041603f6b:	49 89 fe             	mov    %rdi,%r14
  8041603f6e:	89 75 ac             	mov    %esi,-0x54(%rbp)
  // LAB 3: Your code here.
  struct Env *e;

  int status = env_alloc(&e, 0);
  8041603f71:	be 00 00 00 00       	mov    $0x0,%esi
  8041603f76:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603f7a:	48 b8 3e 3e 60 41 80 	movabs $0x8041603e3e,%rax
  8041603f81:	00 00 00 
  8041603f84:	ff d0                	callq  *%rax
  if (status == -E_NO_FREE_ENV || status == -E_NO_FREE_ENV)
  8041603f86:	83 f8 fb             	cmp    $0xfffffffb,%eax
  8041603f89:	74 37                	je     8041603fc2 <env_create+0x68>
    panic("env_alloc: %i", status);

  load_icode(e, binary);
  8041603f8b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041603f8f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  uint64_t entry = ((struct Elf*)binary)->e_entry;
  8041603f93:	49 8b 46 18          	mov    0x18(%r14),%rax
  8041603f97:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  uint16_t phnum = ((struct Elf*)binary)->e_phnum;
  8041603f9b:	45 0f b7 6e 38       	movzwl 0x38(%r14),%r13d
  uint8_t *pht_start = binary + ((struct Elf*)binary)->e_phoff;
  8041603fa0:	4d 89 f4             	mov    %r14,%r12
  8041603fa3:	4d 03 66 20          	add    0x20(%r14),%r12
  for (uint16_t i = 0; i < phnum; i++) {
  8041603fa7:	66 45 85 ed          	test   %r13w,%r13w
  8041603fab:	0f 84 8f 00 00 00    	je     8041604040 <env_create+0xe6>
  8041603fb1:	bb 00 00 00 00       	mov    $0x0,%ebx
    memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
  8041603fb6:	49 bf b5 53 60 41 80 	movabs $0x80416053b5,%r15
  8041603fbd:	00 00 00 
  8041603fc0:	eb 39                	jmp    8041603ffb <env_create+0xa1>
    panic("env_alloc: %i", status);
  8041603fc2:	b9 fb ff ff ff       	mov    $0xfffffffb,%ecx
  8041603fc7:	48 ba 4d 60 60 41 80 	movabs $0x804160604d,%rdx
  8041603fce:	00 00 00 
  8041603fd1:	be 8d 01 00 00       	mov    $0x18d,%esi
  8041603fd6:	48 bf 5b 60 60 41 80 	movabs $0x804160605b,%rdi
  8041603fdd:	00 00 00 
  8041603fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603fe5:	49 b8 83 03 60 41 80 	movabs $0x8041600383,%r8
  8041603fec:	00 00 00 
  8041603fef:	41 ff d0             	callq  *%r8
  for (uint16_t i = 0; i < phnum; i++) {
  8041603ff2:	83 c3 01             	add    $0x1,%ebx
  8041603ff5:	66 41 39 dd          	cmp    %bx,%r13w
  8041603ff9:	74 45                	je     8041604040 <env_create+0xe6>
    if (ph->p_type != ELF_PROG_LOAD)
  8041603ffb:	41 83 3c 24 01       	cmpl   $0x1,(%r12)
  8041604000:	75 f0                	jne    8041603ff2 <env_create+0x98>
    memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
  8041604002:	49 8b 54 24 20       	mov    0x20(%r12),%rdx
  8041604007:	4c 89 f6             	mov    %r14,%rsi
  804160400a:	49 03 74 24 08       	add    0x8(%r12),%rsi
  804160400f:	49 8b 7c 24 10       	mov    0x10(%r12),%rdi
  8041604014:	41 ff d7             	callq  *%r15
    memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
  8041604017:	49 8b 7c 24 20       	mov    0x20(%r12),%rdi
  804160401c:	49 8b 54 24 28       	mov    0x28(%r12),%rdx
  8041604021:	48 29 fa             	sub    %rdi,%rdx
  8041604024:	49 03 7c 24 10       	add    0x10(%r12),%rdi
  8041604029:	be 00 00 00 00       	mov    $0x0,%esi
  804160402e:	48 b8 6c 53 60 41 80 	movabs $0x804160536c,%rax
  8041604035:	00 00 00 
  8041604038:	ff d0                	callq  *%rax
    ph++;
  804160403a:	49 83 c4 38          	add    $0x38,%r12
  804160403e:	eb b2                	jmp    8041603ff2 <env_create+0x98>
  e->env_tf.tf_rip = entry;
  8041604040:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041604044:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041604048:	48 89 88 98 00 00 00 	mov    %rcx,0x98(%rax)
  e->env_type = type;
  804160404f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041604053:	8b 4d ac             	mov    -0x54(%rbp),%ecx
  8041604056:	89 88 d0 00 00 00    	mov    %ecx,0xd0(%rax)
}
  804160405c:	48 83 c4 38          	add    $0x38,%rsp
  8041604060:	5b                   	pop    %rbx
  8041604061:	41 5c                	pop    %r12
  8041604063:	41 5d                	pop    %r13
  8041604065:	41 5e                	pop    %r14
  8041604067:	41 5f                	pop    %r15
  8041604069:	5d                   	pop    %rbp
  804160406a:	c3                   	retq   

000000804160406b <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  804160406b:	55                   	push   %rbp
  804160406c:	48 89 e5             	mov    %rsp,%rbp
  804160406f:	53                   	push   %rbx
  8041604070:	48 83 ec 08          	sub    $0x8,%rsp
  8041604074:	48 89 fb             	mov    %rdi,%rbx
  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041604077:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  804160407d:	48 a1 c0 31 62 41 80 	movabs 0x80416231c0,%rax
  8041604084:	00 00 00 
  8041604087:	48 85 c0             	test   %rax,%rax
  804160408a:	74 49                	je     80416040d5 <env_free+0x6a>
  804160408c:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041604092:	48 bf 66 60 60 41 80 	movabs $0x8041606066,%rdi
  8041604099:	00 00 00 
  804160409c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416040a1:	48 b9 f3 42 60 41 80 	movabs $0x80416042f3,%rcx
  80416040a8:	00 00 00 
  80416040ab:	ff d1                	callq  *%rcx

  // return the environment to the free list
  e->env_status = ENV_FREE;
  80416040ad:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  80416040b4:	00 00 00 
  e->env_link   = env_free_list;
  80416040b7:	48 b8 c8 31 62 41 80 	movabs $0x80416231c8,%rax
  80416040be:	00 00 00 
  80416040c1:	48 8b 10             	mov    (%rax),%rdx
  80416040c4:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  80416040cb:	48 89 18             	mov    %rbx,(%rax)
}
  80416040ce:	48 83 c4 08          	add    $0x8,%rsp
  80416040d2:	5b                   	pop    %rbx
  80416040d3:	5d                   	pop    %rbp
  80416040d4:	c3                   	retq   
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  80416040d5:	be 00 00 00 00       	mov    $0x0,%esi
  80416040da:	eb b6                	jmp    8041604092 <env_free+0x27>

00000080416040dc <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) {
  80416040dc:	55                   	push   %rbp
  80416040dd:	48 89 e5             	mov    %rsp,%rbp
  80416040e0:	53                   	push   %rbx
  80416040e1:	48 83 ec 08          	sub    $0x8,%rsp
  80416040e5:	48 89 fb             	mov    %rdi,%rbx
  // LAB 3: Your code here.
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.

  env_free(e);
  80416040e8:	48 b8 6b 40 60 41 80 	movabs $0x804160406b,%rax
  80416040ef:	00 00 00 
  80416040f2:	ff d0                	callq  *%rax
  if (e == curenv)
  80416040f4:	48 b8 c0 31 62 41 80 	movabs $0x80416231c0,%rax
  80416040fb:	00 00 00 
  80416040fe:	48 3b 18             	cmp    (%rax),%rbx
  8041604101:	74 07                	je     804160410a <env_destroy+0x2e>
	  sched_yield();
	// cprintf("Destroyed the only environment - nothing more to do!\n");
	// while (1)
	// monitor(NULL);
  
}
  8041604103:	48 83 c4 08          	add    $0x8,%rsp
  8041604107:	5b                   	pop    %rbx
  8041604108:	5d                   	pop    %rbp
  8041604109:	c3                   	retq   
	  sched_yield();
  804160410a:	48 b8 2c 44 60 41 80 	movabs $0x804160442c,%rax
  8041604111:	00 00 00 
  8041604114:	ff d0                	callq  *%rax

0000008041604116 <csys_exit>:

#ifdef CONFIG_KSPACE
void
csys_exit(void) {
  8041604116:	55                   	push   %rbp
  8041604117:	48 89 e5             	mov    %rsp,%rbp

  env_destroy(curenv);
  804160411a:	48 b8 c0 31 62 41 80 	movabs $0x80416231c0,%rax
  8041604121:	00 00 00 
  8041604124:	48 8b 38             	mov    (%rax),%rdi
  8041604127:	48 b8 dc 40 60 41 80 	movabs $0x80416040dc,%rax
  804160412e:	00 00 00 
  8041604131:	ff d0                	callq  *%rax
}
  8041604133:	5d                   	pop    %rbp
  8041604134:	c3                   	retq   

0000008041604135 <csys_yield>:

void
csys_yield(struct Trapframe *tf) {
  8041604135:	55                   	push   %rbp
  8041604136:	48 89 e5             	mov    %rsp,%rbp
  8041604139:	48 89 fe             	mov    %rdi,%rsi
  memcpy(&curenv->env_tf, tf, sizeof(struct Trapframe));
  804160413c:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041604141:	48 b8 c0 31 62 41 80 	movabs $0x80416231c0,%rax
  8041604148:	00 00 00 
  804160414b:	48 8b 38             	mov    (%rax),%rdi
  804160414e:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  8041604155:	00 00 00 
  8041604158:	ff d0                	callq  *%rax
  sched_yield();
  804160415a:	48 b8 2c 44 60 41 80 	movabs $0x804160442c,%rax
  8041604161:	00 00 00 
  8041604164:	ff d0                	callq  *%rax

0000008041604166 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041604166:	55                   	push   %rbp
  8041604167:	48 89 e5             	mov    %rsp,%rbp
  804160416a:	53                   	push   %rbx
  804160416b:	48 83 ec 08          	sub    $0x8,%rsp
  804160416f:	48 89 f8             	mov    %rdi,%rax
#ifdef CONFIG_KSPACE
  static uintptr_t rip = 0;
  rip                  = tf->tf_rip;

  asm volatile(
  8041604172:	48 8b 58 68          	mov    0x68(%rax),%rbx
  8041604176:	48 8b 48 60          	mov    0x60(%rax),%rcx
  804160417a:	48 8b 50 58          	mov    0x58(%rax),%rdx
  804160417e:	48 8b 70 40          	mov    0x40(%rax),%rsi
  8041604182:	48 8b 78 48          	mov    0x48(%rax),%rdi
  8041604186:	48 8b 68 50          	mov    0x50(%rax),%rbp
  804160418a:	48 8b a0 b0 00 00 00 	mov    0xb0(%rax),%rsp
  8041604191:	4c 8b 40 38          	mov    0x38(%rax),%r8
  8041604195:	4c 8b 48 30          	mov    0x30(%rax),%r9
  8041604199:	4c 8b 50 28          	mov    0x28(%rax),%r10
  804160419d:	4c 8b 58 20          	mov    0x20(%rax),%r11
  80416041a1:	4c 8b 60 18          	mov    0x18(%rax),%r12
  80416041a5:	4c 8b 68 10          	mov    0x10(%rax),%r13
  80416041a9:	4c 8b 70 08          	mov    0x8(%rax),%r14
  80416041ad:	4c 8b 38             	mov    (%rax),%r15
  80416041b0:	ff b0 98 00 00 00    	pushq  0x98(%rax)
  80416041b6:	ff b0 a8 00 00 00    	pushq  0xa8(%rax)
  80416041bc:	48 8b 40 70          	mov    0x70(%rax),%rax
  80416041c0:	9d                   	popfq  
  80416041c1:	c3                   	retq   
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
#endif
  panic("BUG"); /* mostly to placate the compiler */
  80416041c2:	48 ba 7c 60 60 41 80 	movabs $0x804160607c,%rdx
  80416041c9:	00 00 00 
  80416041cc:	be fc 01 00 00       	mov    $0x1fc,%esi
  80416041d1:	48 bf 5b 60 60 41 80 	movabs $0x804160605b,%rdi
  80416041d8:	00 00 00 
  80416041db:	b8 00 00 00 00       	mov    $0x0,%eax
  80416041e0:	48 b9 83 03 60 41 80 	movabs $0x8041600383,%rcx
  80416041e7:	00 00 00 
  80416041ea:	ff d1                	callq  *%rcx

00000080416041ec <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
// 
// This function does not return.
//
void
env_run(struct Env *e) {
  80416041ec:	55                   	push   %rbp
  80416041ed:	48 89 e5             	mov    %rsp,%rbp
  80416041f0:	53                   	push   %rbx
  80416041f1:	48 83 ec 08          	sub    $0x8,%rsp
  80416041f5:	48 89 fb             	mov    %rdi,%rbx
#ifdef CONFIG_KSPACE
  cprintf("envrun %s: %d\n",
  80416041f8:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  80416041fe:	83 e2 1f             	and    $0x1f,%edx
          e->env_status == ENV_RUNNING ? "RUNNING" :
  8041604201:	8b 87 d4 00 00 00    	mov    0xd4(%rdi),%eax
  cprintf("envrun %s: %d\n",
  8041604207:	48 be 8a 60 60 41 80 	movabs $0x804160608a,%rsi
  804160420e:	00 00 00 
  8041604211:	83 f8 03             	cmp    $0x3,%eax
  8041604214:	74 1b                	je     8041604231 <env_run+0x45>
                                         e->env_status == ENV_RUNNABLE ? "RUNNABLE" : "(unknown)",
  8041604216:	83 f8 02             	cmp    $0x2,%eax
  8041604219:	48 b8 80 60 60 41 80 	movabs $0x8041606080,%rax
  8041604220:	00 00 00 
  8041604223:	48 be 92 60 60 41 80 	movabs $0x8041606092,%rsi
  804160422a:	00 00 00 
  804160422d:	48 0f 45 f0          	cmovne %rax,%rsi
  cprintf("envrun %s: %d\n",
  8041604231:	48 bf 9b 60 60 41 80 	movabs $0x804160609b,%rdi
  8041604238:	00 00 00 
  804160423b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604240:	48 b9 f3 42 60 41 80 	movabs $0x80416042f3,%rcx
  8041604247:	00 00 00 
  804160424a:	ff d1                	callq  *%rcx
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //
  // LAB 3: Your code here.
  
  if (curenv && curenv->env_status == ENV_RUNNING)
  804160424c:	48 a1 c0 31 62 41 80 	movabs 0x80416231c0,%rax
  8041604253:	00 00 00 
  8041604256:	48 85 c0             	test   %rax,%rax
  8041604259:	74 09                	je     8041604264 <env_run+0x78>
  804160425b:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  8041604262:	74 2d                	je     8041604291 <env_run+0xa5>
    curenv->env_status = ENV_RUNNABLE;
  curenv = e;
  8041604264:	48 89 d8             	mov    %rbx,%rax
  8041604267:	48 a3 c0 31 62 41 80 	movabs %rax,0x80416231c0
  804160426e:	00 00 00 
  e->env_status = ENV_RUNNING;
  8041604271:	c7 83 d4 00 00 00 03 	movl   $0x3,0xd4(%rbx)
  8041604278:	00 00 00 
  e->env_runs++;
  804160427b:	83 83 d8 00 00 00 01 	addl   $0x1,0xd8(%rbx)
  env_pop_tf(&e->env_tf);
  8041604282:	48 89 df             	mov    %rbx,%rdi
  8041604285:	48 b8 66 41 60 41 80 	movabs $0x8041604166,%rax
  804160428c:	00 00 00 
  804160428f:	ff d0                	callq  *%rax
    curenv->env_status = ENV_RUNNABLE;
  8041604291:	c7 80 d4 00 00 00 02 	movl   $0x2,0xd4(%rax)
  8041604298:	00 00 00 
  804160429b:	eb c7                	jmp    8041604264 <env_run+0x78>

000000804160429d <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  804160429d:	55                   	push   %rbp
  804160429e:	48 89 e5             	mov    %rsp,%rbp
  80416042a1:	53                   	push   %rbx
  80416042a2:	48 83 ec 08          	sub    $0x8,%rsp
  80416042a6:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  80416042a9:	48 b8 08 0c 60 41 80 	movabs $0x8041600c08,%rax
  80416042b0:	00 00 00 
  80416042b3:	ff d0                	callq  *%rax
  (*cnt)++;
  80416042b5:	83 03 01             	addl   $0x1,(%rbx)
}
  80416042b8:	48 83 c4 08          	add    $0x8,%rsp
  80416042bc:	5b                   	pop    %rbx
  80416042bd:	5d                   	pop    %rbp
  80416042be:	c3                   	retq   

00000080416042bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80416042bf:	55                   	push   %rbp
  80416042c0:	48 89 e5             	mov    %rsp,%rbp
  80416042c3:	48 83 ec 10          	sub    $0x10,%rsp
  80416042c7:	48 89 fa             	mov    %rdi,%rdx
  80416042ca:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  80416042cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  80416042d4:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  80416042d8:	48 bf 9d 42 60 41 80 	movabs $0x804160429d,%rdi
  80416042df:	00 00 00 
  80416042e2:	48 b8 d7 48 60 41 80 	movabs $0x80416048d7,%rax
  80416042e9:	00 00 00 
  80416042ec:	ff d0                	callq  *%rax
  return cnt;
}
  80416042ee:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80416042f1:	c9                   	leaveq 
  80416042f2:	c3                   	retq   

00000080416042f3 <cprintf>:

int
cprintf(const char *fmt, ...) {
  80416042f3:	55                   	push   %rbp
  80416042f4:	48 89 e5             	mov    %rsp,%rbp
  80416042f7:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80416042fe:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8041604305:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  804160430c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041604313:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160431a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604321:	84 c0                	test   %al,%al
  8041604323:	74 20                	je     8041604345 <cprintf+0x52>
  8041604325:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604329:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160432d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604331:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041604335:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604339:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160433d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604341:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8041604345:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  804160434c:	00 00 00 
  804160434f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041604356:	00 00 00 
  8041604359:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160435d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041604364:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160436b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8041604372:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041604379:	48 b8 bf 42 60 41 80 	movabs $0x80416042bf,%rax
  8041604380:	00 00 00 
  8041604383:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8041604385:	c9                   	leaveq 
  8041604386:	c3                   	retq   

0000008041604387 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041604387:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  804160438e:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  8041604391:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  8041604397:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160439a:	83 fa 02             	cmp    $0x2,%edx
  804160439d:	76 61                	jbe    8041604400 <sched_halt+0x79>
  804160439f:	48 8d 90 b4 01 00 00 	lea    0x1b4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  80416043a6:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  80416043ab:	8b 02                	mov    (%rdx),%eax
  80416043ad:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  80416043b0:	83 f8 02             	cmp    $0x2,%eax
  80416043b3:	76 46                	jbe    80416043fb <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  80416043b5:	83 c1 01             	add    $0x1,%ecx
  80416043b8:	48 81 c2 e0 00 00 00 	add    $0xe0,%rdx
  80416043bf:	83 f9 20             	cmp    $0x20,%ecx
  80416043c2:	75 e7                	jne    80416043ab <sched_halt+0x24>
sched_halt(void) {
  80416043c4:	55                   	push   %rbp
  80416043c5:	48 89 e5             	mov    %rsp,%rbp
  80416043c8:	53                   	push   %rbx
  80416043c9:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  80416043cd:	48 bf b0 60 60 41 80 	movabs $0x80416060b0,%rdi
  80416043d4:	00 00 00 
  80416043d7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416043dc:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416043e3:	00 00 00 
  80416043e6:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  80416043e8:	48 bb cf 3a 60 41 80 	movabs $0x8041603acf,%rbx
  80416043ef:	00 00 00 
  80416043f2:	bf 00 00 00 00       	mov    $0x0,%edi
  80416043f7:	ff d3                	callq  *%rbx
  80416043f9:	eb f7                	jmp    80416043f2 <sched_halt+0x6b>
  if (i == NENV) {
  80416043fb:	83 f9 20             	cmp    $0x20,%ecx
  80416043fe:	74 c4                	je     80416043c4 <sched_halt+0x3d>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  8041604400:	48 b8 c0 31 62 41 80 	movabs $0x80416231c0,%rax
  8041604407:	00 00 00 
  804160440a:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  8041604411:	48 a1 04 52 62 41 80 	movabs 0x8041625204,%rax
  8041604418:	00 00 00 
  804160441b:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  8041604422:	48 89 c4             	mov    %rax,%rsp
  8041604425:	6a 00                	pushq  $0x0
  8041604427:	6a 00                	pushq  $0x0
  8041604429:	fb                   	sti    
  804160442a:	f4                   	hlt    
  804160442b:	c3                   	retq   

000000804160442c <sched_yield>:
sched_yield(void) {
  804160442c:	55                   	push   %rbp
  804160442d:	48 89 e5             	mov    %rsp,%rbp
  struct Env * envs_end = envs + NENV - 1;
  8041604430:	48 b8 88 77 61 41 80 	movabs $0x8041617788,%rax
  8041604437:	00 00 00 
  804160443a:	48 8b 10             	mov    (%rax),%rdx
  804160443d:	48 8d ba 20 1b 00 00 	lea    0x1b20(%rdx),%rdi
  struct Env * e = curenv;
  8041604444:	48 b8 c0 31 62 41 80 	movabs $0x80416231c0,%rax
  804160444b:	00 00 00 
  804160444e:	48 8b 08             	mov    (%rax),%rcx
  while ((e != envs_end) && (e->env_status == ENV_RUNNABLE)) {
  8041604451:	48 39 cf             	cmp    %rcx,%rdi
  8041604454:	74 6b                	je     80416044c1 <sched_yield+0x95>
  8041604456:	83 b9 d4 00 00 00 02 	cmpl   $0x2,0xd4(%rcx)
  804160445d:	75 17                	jne    8041604476 <sched_yield+0x4a>
  804160445f:	48 89 c8             	mov    %rcx,%rax
    e++;
  8041604462:	48 05 e0 00 00 00    	add    $0xe0,%rax
  while ((e != envs_end) && (e->env_status == ENV_RUNNABLE)) {
  8041604468:	48 39 c7             	cmp    %rax,%rdi
  804160446b:	74 57                	je     80416044c4 <sched_yield+0x98>
  804160446d:	83 b8 d4 00 00 00 02 	cmpl   $0x2,0xd4(%rax)
  8041604474:	74 ec                	je     8041604462 <sched_yield+0x36>
    while ((e->env_status != ENV_RUNNABLE) &&
  8041604476:	8b 82 d4 00 00 00    	mov    0xd4(%rdx),%eax
  804160447c:	83 e8 02             	sub    $0x2,%eax
          (e->env_status != ENV_RUNNING) && (e != curenv)) {
  804160447f:	83 f8 01             	cmp    $0x1,%eax
  8041604482:	76 1f                	jbe    80416044a3 <sched_yield+0x77>
  8041604484:	48 39 ca             	cmp    %rcx,%rdx
  8041604487:	74 1a                	je     80416044a3 <sched_yield+0x77>
        e++;
  8041604489:	48 81 c2 e0 00 00 00 	add    $0xe0,%rdx
    while ((e->env_status != ENV_RUNNABLE) &&
  8041604490:	8b 82 d4 00 00 00    	mov    0xd4(%rdx),%eax
  8041604496:	83 e8 02             	sub    $0x2,%eax
          (e->env_status != ENV_RUNNING) && (e != curenv)) {
  8041604499:	83 f8 01             	cmp    $0x1,%eax
  804160449c:	76 05                	jbe    80416044a3 <sched_yield+0x77>
  804160449e:	48 39 d1             	cmp    %rdx,%rcx
  80416044a1:	75 e6                	jne    8041604489 <sched_yield+0x5d>
  if (e->env_status == ENV_RUNNABLE) {
  80416044a3:	8b 82 d4 00 00 00    	mov    0xd4(%rdx),%eax
  80416044a9:	83 f8 02             	cmp    $0x2,%eax
  80416044ac:	74 2b                	je     80416044d9 <sched_yield+0xad>
  } else if (e->env_status != ENV_RUNNING) {
  80416044ae:	83 f8 03             	cmp    $0x3,%eax
  80416044b1:	74 0c                	je     80416044bf <sched_yield+0x93>
    sched_halt();
  80416044b3:	48 b8 87 43 60 41 80 	movabs $0x8041604387,%rax
  80416044ba:	00 00 00 
  80416044bd:	ff d0                	callq  *%rax
}
  80416044bf:	5d                   	pop    %rbp
  80416044c0:	c3                   	retq   
  struct Env * e = curenv;
  80416044c1:	48 89 cf             	mov    %rcx,%rdi
  if (e->env_status != ENV_RUNNABLE) {
  80416044c4:	83 bf d4 00 00 00 02 	cmpl   $0x2,0xd4(%rdi)
  80416044cb:	75 a9                	jne    8041604476 <sched_yield+0x4a>
    env_run(e);
  80416044cd:	48 b8 ec 41 60 41 80 	movabs $0x80416041ec,%rax
  80416044d4:	00 00 00 
  80416044d7:	ff d0                	callq  *%rax
  80416044d9:	48 89 d7             	mov    %rdx,%rdi
  80416044dc:	eb ef                	jmp    80416044cd <sched_yield+0xa1>

00000080416044de <load_kernel_dwarf_info>:
#include <kern/kdebug.h>
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  80416044de:	55                   	push   %rbp
  80416044df:	48 89 e5             	mov    %rsp,%rbp
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  80416044e2:	48 ba 00 70 61 41 80 	movabs $0x8041617000,%rdx
  80416044e9:	00 00 00 
  80416044ec:	48 8b 02             	mov    (%rdx),%rax
  80416044ef:	48 8b 48 58          	mov    0x58(%rax),%rcx
  80416044f3:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  80416044f7:	48 8b 48 60          	mov    0x60(%rax),%rcx
  80416044fb:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  80416044ff:	48 8b 40 68          	mov    0x68(%rax),%rax
  8041604503:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  8041604506:	48 8b 02             	mov    (%rdx),%rax
  8041604509:	48 8b 50 70          	mov    0x70(%rax),%rdx
  804160450d:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  8041604511:	48 8b 50 78          	mov    0x78(%rax),%rdx
  8041604515:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  8041604519:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  8041604520:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  8041604524:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  804160452b:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  804160452f:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  8041604536:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  804160453a:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  8041604541:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  8041604545:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  804160454c:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  8041604550:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  8041604557:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  804160455b:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  8041604562:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  8041604566:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  804160456d:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  8041604571:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  8041604578:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  804160457c:	5d                   	pop    %rbp
  804160457d:	c3                   	retq   

000000804160457e <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  804160457e:	55                   	push   %rbp
  804160457f:	48 89 e5             	mov    %rsp,%rbp
  8041604582:	41 56                	push   %r14
  8041604584:	41 55                	push   %r13
  8041604586:	41 54                	push   %r12
  8041604588:	53                   	push   %rbx
  8041604589:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  8041604590:	49 89 fc             	mov    %rdi,%r12
  8041604593:	48 89 f3             	mov    %rsi,%rbx
  int code = 0;
  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  8041604596:	48 be d9 60 60 41 80 	movabs $0x80416060d9,%rsi
  804160459d:	00 00 00 
  80416045a0:	48 89 df             	mov    %rbx,%rdi
  80416045a3:	49 bd ca 51 60 41 80 	movabs $0x80416051ca,%r13
  80416045aa:	00 00 00 
  80416045ad:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  80416045b0:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  80416045b7:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  80416045ba:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  80416045c1:	48 be d9 60 60 41 80 	movabs $0x80416060d9,%rsi
  80416045c8:	00 00 00 
  80416045cb:	4c 89 f7             	mov    %r14,%rdi
  80416045ce:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  80416045d1:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  80416045d8:	00 00 00 
  info->rip_fn_addr    = addr;
  80416045db:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  80416045e2:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  80416045e9:	00 00 00 

  if (!addr) {
  80416045ec:	4d 85 e4             	test   %r12,%r12
  80416045ef:	0f 84 8f 01 00 00    	je     8041604784 <debuginfo_rip+0x206>
    return 0;
  }

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  80416045f5:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  80416045fc:	00 00 00 
  80416045ff:	49 39 c4             	cmp    %rax,%r12
  8041604602:	0f 86 52 01 00 00    	jbe    804160475a <debuginfo_rip+0x1dc>
    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  8041604608:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160460f:	48 b8 de 44 60 41 80 	movabs $0x80416044de,%rax
  8041604616:	00 00 00 
  8041604619:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  804160461b:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  8041604622:	00 00 00 00 
  8041604626:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  804160462d:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  8041604631:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  8041604638:	4c 89 e6             	mov    %r12,%rsi
  804160463b:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041604642:	48 b8 e8 15 60 41 80 	movabs $0x80416015e8,%rax
  8041604649:	00 00 00 
  804160464c:	ff d0                	callq  *%rax
  804160464e:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  8041604651:	85 c0                	test   %eax,%eax
  8041604653:	0f 88 31 01 00 00    	js     804160478a <debuginfo_rip+0x20c>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  8041604659:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  8041604660:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604665:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160466c:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  8041604673:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160467a:	48 b8 d1 1c 60 41 80 	movabs $0x8041601cd1,%rax
  8041604681:	00 00 00 
  8041604684:	ff d0                	callq  *%rax
  8041604686:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  8041604689:	ba 00 01 00 00       	mov    $0x100,%edx
  804160468e:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041604695:	48 89 df             	mov    %rbx,%rdi
  8041604698:	48 b8 1f 52 60 41 80 	movabs $0x804160521f,%rax
  804160469f:	00 00 00 
  80416046a2:	ff d0                	callq  *%rax
  if (code < 0) {
  80416046a4:	45 85 ed             	test   %r13d,%r13d
  80416046a7:	0f 88 dd 00 00 00    	js     804160478a <debuginfo_rip+0x20c>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
  // LAB 2: Your code here:
  buf  = &info->rip_line;
  addr = addr - 5;
  80416046ad:	49 83 ec 05          	sub    $0x5,%r12
  buf  = &info->rip_line;
  80416046b1:	48 8d 8b 00 01 00 00 	lea    0x100(%rbx),%rcx
  code = line_for_address(&addrs, addr, line_offset, buf);
  80416046b8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  80416046bf:	4c 89 e6             	mov    %r12,%rsi
  80416046c2:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416046c9:	48 b8 b6 30 60 41 80 	movabs $0x80416030b6,%rax
  80416046d0:	00 00 00 
  80416046d3:	ff d0                	callq  *%rax
  if (code < 0) {
    return 0;
  80416046d5:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  if (code < 0) {
  80416046db:	85 c0                	test   %eax,%eax
  80416046dd:	0f 88 a7 00 00 00    	js     804160478a <debuginfo_rip+0x20c>
  }
  
  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  80416046e3:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  80416046ea:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416046f0:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  80416046f7:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  80416046fe:	4c 89 e6             	mov    %r12,%rsi
  8041604701:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041604708:	48 b8 32 21 60 41 80 	movabs $0x8041602132,%rax
  804160470f:	00 00 00 
  8041604712:	ff d0                	callq  *%rax
  8041604714:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  8041604717:	ba 00 01 00 00       	mov    $0x100,%edx
  804160471c:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041604723:	4c 89 f7             	mov    %r14,%rdi
  8041604726:	48 b8 1f 52 60 41 80 	movabs $0x804160521f,%rax
  804160472d:	00 00 00 
  8041604730:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  8041604732:	be 00 01 00 00       	mov    $0x100,%esi
  8041604737:	4c 89 f7             	mov    %r14,%rdi
  804160473a:	48 b8 93 51 60 41 80 	movabs $0x8041605193,%rax
  8041604741:	00 00 00 
  8041604744:	ff d0                	callq  *%rax
  8041604746:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  804160474c:	45 85 ed             	test   %r13d,%r13d
  804160474f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604754:	44 0f 4f e8          	cmovg  %eax,%r13d
  8041604758:	eb 30                	jmp    804160478a <debuginfo_rip+0x20c>
    panic("Can't search for user-level addresses yet!");
  804160475a:	48 ba f8 60 60 41 80 	movabs $0x80416060f8,%rdx
  8041604761:	00 00 00 
  8041604764:	be 36 00 00 00       	mov    $0x36,%esi
  8041604769:	48 bf e3 60 60 41 80 	movabs $0x80416060e3,%rdi
  8041604770:	00 00 00 
  8041604773:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604778:	48 b9 83 03 60 41 80 	movabs $0x8041600383,%rcx
  804160477f:	00 00 00 
  8041604782:	ff d1                	callq  *%rcx
    return 0;
  8041604784:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  if (code < 0) {
    return code;
  }
  return 0;
}
  804160478a:	44 89 e8             	mov    %r13d,%eax
  804160478d:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  8041604794:	5b                   	pop    %rbx
  8041604795:	41 5c                	pop    %r12
  8041604797:	41 5d                	pop    %r13
  8041604799:	41 5e                	pop    %r14
  804160479b:	5d                   	pop    %rbp
  804160479c:	c3                   	retq   

000000804160479d <find_function>:

uintptr_t
find_function(const char *const fname) {
  804160479d:	55                   	push   %rbp
  804160479e:	48 89 e5             	mov    %rsp,%rbp
  // address_by_fname, which looks for function name in section .debug_pubnames
  // and naive_address_by_fname which performs full traversal of DIE tree.
  // LAB 3: Your code here

  return 0;
}
  80416047a1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416047a6:	5d                   	pop    %rbp
  80416047a7:	c3                   	retq   

00000080416047a8 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  80416047a8:	55                   	push   %rbp
  80416047a9:	48 89 e5             	mov    %rsp,%rbp
  80416047ac:	41 57                	push   %r15
  80416047ae:	41 56                	push   %r14
  80416047b0:	41 55                	push   %r13
  80416047b2:	41 54                	push   %r12
  80416047b4:	53                   	push   %rbx
  80416047b5:	48 83 ec 18          	sub    $0x18,%rsp
  80416047b9:	49 89 fc             	mov    %rdi,%r12
  80416047bc:	49 89 f5             	mov    %rsi,%r13
  80416047bf:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80416047c3:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  80416047c6:	41 89 cf             	mov    %ecx,%r15d
  80416047c9:	49 39 d7             	cmp    %rdx,%r15
  80416047cc:	76 45                	jbe    8041604813 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  80416047ce:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80416047d2:	85 db                	test   %ebx,%ebx
  80416047d4:	7e 0e                	jle    80416047e4 <printnum+0x3c>
      putch(padc, putdat);
  80416047d6:	4c 89 ee             	mov    %r13,%rsi
  80416047d9:	44 89 f7             	mov    %r14d,%edi
  80416047dc:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80416047df:	83 eb 01             	sub    $0x1,%ebx
  80416047e2:	75 f2                	jne    80416047d6 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80416047e4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80416047e8:	ba 00 00 00 00       	mov    $0x0,%edx
  80416047ed:	49 f7 f7             	div    %r15
  80416047f0:	48 b8 28 61 60 41 80 	movabs $0x8041606128,%rax
  80416047f7:	00 00 00 
  80416047fa:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80416047fe:	4c 89 ee             	mov    %r13,%rsi
  8041604801:	41 ff d4             	callq  *%r12
}
  8041604804:	48 83 c4 18          	add    $0x18,%rsp
  8041604808:	5b                   	pop    %rbx
  8041604809:	41 5c                	pop    %r12
  804160480b:	41 5d                	pop    %r13
  804160480d:	41 5e                	pop    %r14
  804160480f:	41 5f                	pop    %r15
  8041604811:	5d                   	pop    %rbp
  8041604812:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8041604813:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041604817:	ba 00 00 00 00       	mov    $0x0,%edx
  804160481c:	49 f7 f7             	div    %r15
  804160481f:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8041604823:	48 89 c2             	mov    %rax,%rdx
  8041604826:	48 b8 a8 47 60 41 80 	movabs $0x80416047a8,%rax
  804160482d:	00 00 00 
  8041604830:	ff d0                	callq  *%rax
  8041604832:	eb b0                	jmp    80416047e4 <printnum+0x3c>

0000008041604834 <sprintputch>:
  char *ebuf;
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  8041604834:	55                   	push   %rbp
  8041604835:	48 89 e5             	mov    %rsp,%rbp
  b->cnt++;
  8041604838:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  804160483c:	48 8b 06             	mov    (%rsi),%rax
  804160483f:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8041604843:	73 0a                	jae    804160484f <sprintputch+0x1b>
    *b->buf++ = ch;
  8041604845:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8041604849:	48 89 16             	mov    %rdx,(%rsi)
  804160484c:	40 88 38             	mov    %dil,(%rax)
}
  804160484f:	5d                   	pop    %rbp
  8041604850:	c3                   	retq   

0000008041604851 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8041604851:	55                   	push   %rbp
  8041604852:	48 89 e5             	mov    %rsp,%rbp
  8041604855:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160485c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041604863:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160486a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604871:	84 c0                	test   %al,%al
  8041604873:	74 20                	je     8041604895 <printfmt+0x44>
  8041604875:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604879:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160487d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604881:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041604885:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604889:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160488d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604891:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8041604895:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160489c:	00 00 00 
  804160489f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80416048a6:	00 00 00 
  80416048a9:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416048ad:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80416048b4:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80416048bb:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  80416048c2:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80416048c9:	48 b8 d7 48 60 41 80 	movabs $0x80416048d7,%rax
  80416048d0:	00 00 00 
  80416048d3:	ff d0                	callq  *%rax
}
  80416048d5:	c9                   	leaveq 
  80416048d6:	c3                   	retq   

00000080416048d7 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80416048d7:	55                   	push   %rbp
  80416048d8:	48 89 e5             	mov    %rsp,%rbp
  80416048db:	41 57                	push   %r15
  80416048dd:	41 56                	push   %r14
  80416048df:	41 55                	push   %r13
  80416048e1:	41 54                	push   %r12
  80416048e3:	53                   	push   %rbx
  80416048e4:	48 83 ec 48          	sub    $0x48,%rsp
  80416048e8:	49 89 ff             	mov    %rdi,%r15
  80416048eb:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416048ef:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80416048f2:	48 8b 01             	mov    (%rcx),%rax
  80416048f5:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416048f9:	48 8b 41 08          	mov    0x8(%rcx),%rax
  80416048fd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604901:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041604905:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041604909:	e9 18 05 00 00       	jmpq   8041604e26 <vprintfmt+0x54f>
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160490e:	4d 89 e6             	mov    %r12,%r14
  8041604911:	e9 10 05 00 00       	jmpq   8041604e26 <vprintfmt+0x54f>
        precision = va_arg(aq, int);
  8041604916:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160491a:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
  804160491e:	c7 45 9c 00 00 00 00 	movl   $0x0,-0x64(%rbp)
  8041604925:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  804160492a:	41 89 dd             	mov    %ebx,%r13d
  804160492d:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8041604932:	41 ba 01 00 00 00    	mov    $0x1,%r10d
  8041604938:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        padc = '0';
  804160493e:	41 b8 30 00 00 00    	mov    $0x30,%r8d
        padc = '-';
  8041604944:	bf 2d 00 00 00       	mov    $0x2d,%edi
    switch (ch = *(unsigned char *)fmt++) {
  8041604949:	4d 8d 74 24 01       	lea    0x1(%r12),%r14
  804160494e:	41 0f b6 14 24       	movzbl (%r12),%edx
  8041604953:	8d 42 dd             	lea    -0x23(%rdx),%eax
  8041604956:	3c 55                	cmp    $0x55,%al
  8041604958:	0f 87 9b 05 00 00    	ja     8041604ef9 <vprintfmt+0x622>
  804160495e:	0f b6 c0             	movzbl %al,%eax
  8041604961:	49 bb e0 61 60 41 80 	movabs $0x80416061e0,%r11
  8041604968:	00 00 00 
  804160496b:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  804160496f:	4d 89 f4             	mov    %r14,%r12
        padc = '-';
  8041604972:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8041604976:	eb d1                	jmp    8041604949 <vprintfmt+0x72>
    switch (ch = *(unsigned char *)fmt++) {
  8041604978:	4d 89 f4             	mov    %r14,%r12
        padc = '0';
  804160497b:	44 88 45 a0          	mov    %r8b,-0x60(%rbp)
  804160497f:	eb c8                	jmp    8041604949 <vprintfmt+0x72>
    switch (ch = *(unsigned char *)fmt++) {
  8041604981:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8041604984:	8d 5a d0             	lea    -0x30(%rdx),%ebx
          ch        = *fmt;
  8041604987:	41 0f be 44 24 01    	movsbl 0x1(%r12),%eax
          if (ch < '0' || ch > '9')
  804160498d:	8d 50 d0             	lea    -0x30(%rax),%edx
  8041604990:	83 fa 09             	cmp    $0x9,%edx
  8041604993:	77 73                	ja     8041604a08 <vprintfmt+0x131>
        for (precision = 0;; ++fmt) {
  8041604995:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  8041604999:	8d 14 9b             	lea    (%rbx,%rbx,4),%edx
  804160499c:	8d 5c 50 d0          	lea    -0x30(%rax,%rdx,2),%ebx
          ch        = *fmt;
  80416049a0:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  80416049a4:	8d 50 d0             	lea    -0x30(%rax),%edx
  80416049a7:	83 fa 09             	cmp    $0x9,%edx
  80416049aa:	76 e9                	jbe    8041604995 <vprintfmt+0xbe>
        for (precision = 0;; ++fmt) {
  80416049ac:	4d 89 f4             	mov    %r14,%r12
  80416049af:	eb 18                	jmp    80416049c9 <vprintfmt+0xf2>
        precision = va_arg(aq, int);
  80416049b1:	8b 55 b8             	mov    -0x48(%rbp),%edx
  80416049b4:	83 fa 2f             	cmp    $0x2f,%edx
  80416049b7:	77 26                	ja     80416049df <vprintfmt+0x108>
  80416049b9:	89 d0                	mov    %edx,%eax
  80416049bb:	48 01 f0             	add    %rsi,%rax
  80416049be:	83 c2 08             	add    $0x8,%edx
  80416049c1:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80416049c4:	8b 18                	mov    (%rax),%ebx
    switch (ch = *(unsigned char *)fmt++) {
  80416049c6:	4d 89 f4             	mov    %r14,%r12
        if (width < 0)
  80416049c9:	45 85 ed             	test   %r13d,%r13d
  80416049cc:	0f 89 77 ff ff ff    	jns    8041604949 <vprintfmt+0x72>
          width = precision, precision = -1;
  80416049d2:	41 89 dd             	mov    %ebx,%r13d
  80416049d5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80416049da:	e9 6a ff ff ff       	jmpq   8041604949 <vprintfmt+0x72>
        precision = va_arg(aq, int);
  80416049df:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416049e3:	48 8d 50 08          	lea    0x8(%rax),%rdx
  80416049e7:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  80416049eb:	eb d7                	jmp    80416049c4 <vprintfmt+0xed>
  80416049ed:	45 85 ed             	test   %r13d,%r13d
  80416049f0:	45 0f 48 e9          	cmovs  %r9d,%r13d
    switch (ch = *(unsigned char *)fmt++) {
  80416049f4:	4d 89 f4             	mov    %r14,%r12
  80416049f7:	e9 4d ff ff ff       	jmpq   8041604949 <vprintfmt+0x72>
  80416049fc:	4d 89 f4             	mov    %r14,%r12
        altflag = 1;
  80416049ff:	44 89 55 9c          	mov    %r10d,-0x64(%rbp)
        goto reswitch;
  8041604a03:	e9 41 ff ff ff       	jmpq   8041604949 <vprintfmt+0x72>
    switch (ch = *(unsigned char *)fmt++) {
  8041604a08:	4d 89 f4             	mov    %r14,%r12
  8041604a0b:	eb bc                	jmp    80416049c9 <vprintfmt+0xf2>
        lflag++;
  8041604a0d:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8041604a10:	4d 89 f4             	mov    %r14,%r12
        goto reswitch;
  8041604a13:	e9 31 ff ff ff       	jmpq   8041604949 <vprintfmt+0x72>
        putch(va_arg(aq, int), putdat);
  8041604a18:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604a1b:	83 fa 2f             	cmp    $0x2f,%edx
  8041604a1e:	77 19                	ja     8041604a39 <vprintfmt+0x162>
  8041604a20:	89 d0                	mov    %edx,%eax
  8041604a22:	48 01 f0             	add    %rsi,%rax
  8041604a25:	83 c2 08             	add    $0x8,%edx
  8041604a28:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604a2b:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604a2f:	8b 38                	mov    (%rax),%edi
  8041604a31:	41 ff d7             	callq  *%r15
        break;
  8041604a34:	e9 ed 03 00 00       	jmpq   8041604e26 <vprintfmt+0x54f>
        putch(va_arg(aq, int), putdat);
  8041604a39:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041604a3d:	48 8d 50 08          	lea    0x8(%rax),%rdx
  8041604a41:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041604a45:	eb e4                	jmp    8041604a2b <vprintfmt+0x154>
        err = va_arg(aq, int);
  8041604a47:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604a4a:	83 fa 2f             	cmp    $0x2f,%edx
  8041604a4d:	77 55                	ja     8041604aa4 <vprintfmt+0x1cd>
  8041604a4f:	89 d0                	mov    %edx,%eax
  8041604a51:	48 01 c6             	add    %rax,%rsi
  8041604a54:	83 c2 08             	add    $0x8,%edx
  8041604a57:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604a5a:	8b 06                	mov    (%rsi),%eax
  8041604a5c:	99                   	cltd   
  8041604a5d:	31 d0                	xor    %edx,%eax
  8041604a5f:	29 d0                	sub    %edx,%eax
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8041604a61:	83 f8 08             	cmp    $0x8,%eax
  8041604a64:	7f 4c                	jg     8041604ab2 <vprintfmt+0x1db>
  8041604a66:	48 63 d0             	movslq %eax,%rdx
  8041604a69:	48 b9 a0 64 60 41 80 	movabs $0x80416064a0,%rcx
  8041604a70:	00 00 00 
  8041604a73:	48 8b 0c d1          	mov    (%rcx,%rdx,8),%rcx
  8041604a77:	48 85 c9             	test   %rcx,%rcx
  8041604a7a:	74 36                	je     8041604ab2 <vprintfmt+0x1db>
          printfmt(putch, putdat, "%s", p);
  8041604a7c:	48 ba eb 59 60 41 80 	movabs $0x80416059eb,%rdx
  8041604a83:	00 00 00 
  8041604a86:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604a8a:	4c 89 ff             	mov    %r15,%rdi
  8041604a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604a92:	49 b8 51 48 60 41 80 	movabs $0x8041604851,%r8
  8041604a99:	00 00 00 
  8041604a9c:	41 ff d0             	callq  *%r8
  8041604a9f:	e9 82 03 00 00       	jmpq   8041604e26 <vprintfmt+0x54f>
        err = va_arg(aq, int);
  8041604aa4:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604aa8:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604aac:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604ab0:	eb a8                	jmp    8041604a5a <vprintfmt+0x183>
          printfmt(putch, putdat, "error %d", err);
  8041604ab2:	89 c1                	mov    %eax,%ecx
  8041604ab4:	48 ba 40 61 60 41 80 	movabs $0x8041606140,%rdx
  8041604abb:	00 00 00 
  8041604abe:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604ac2:	4c 89 ff             	mov    %r15,%rdi
  8041604ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604aca:	49 b8 51 48 60 41 80 	movabs $0x8041604851,%r8
  8041604ad1:	00 00 00 
  8041604ad4:	41 ff d0             	callq  *%r8
  8041604ad7:	e9 4a 03 00 00       	jmpq   8041604e26 <vprintfmt+0x54f>
        if ((p = va_arg(aq, char *)) == NULL)
  8041604adc:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604adf:	83 fa 2f             	cmp    $0x2f,%edx
  8041604ae2:	77 47                	ja     8041604b2b <vprintfmt+0x254>
  8041604ae4:	89 d0                	mov    %edx,%eax
  8041604ae6:	48 01 c6             	add    %rax,%rsi
  8041604ae9:	83 c2 08             	add    $0x8,%edx
  8041604aec:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604aef:	4c 8b 26             	mov    (%rsi),%r12
  8041604af2:	4d 85 e4             	test   %r12,%r12
  8041604af5:	0f 84 29 04 00 00    	je     8041604f24 <vprintfmt+0x64d>
        if (width > 0 && padc != '-')
  8041604afb:	45 85 ed             	test   %r13d,%r13d
  8041604afe:	7e 06                	jle    8041604b06 <vprintfmt+0x22f>
  8041604b00:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041604b04:	75 3d                	jne    8041604b43 <vprintfmt+0x26c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604b06:	49 8d 54 24 01       	lea    0x1(%r12),%rdx
  8041604b0b:	41 0f b6 04 24       	movzbl (%r12),%eax
  8041604b10:	0f be f8             	movsbl %al,%edi
  8041604b13:	85 ff                	test   %edi,%edi
  8041604b15:	0f 84 c6 00 00 00    	je     8041604be1 <vprintfmt+0x30a>
  8041604b1b:	49 89 d4             	mov    %rdx,%r12
  8041604b1e:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041604b22:	44 8b 75 9c          	mov    -0x64(%rbp),%r14d
  8041604b26:	e9 8b 00 00 00       	jmpq   8041604bb6 <vprintfmt+0x2df>
        if ((p = va_arg(aq, char *)) == NULL)
  8041604b2b:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604b2f:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604b33:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604b37:	eb b6                	jmp    8041604aef <vprintfmt+0x218>
          p = "(null)";
  8041604b39:	49 bc 39 61 60 41 80 	movabs $0x8041606139,%r12
  8041604b40:	00 00 00 
          for (width -= strnlen(p, precision); width > 0; width--)
  8041604b43:	48 63 f3             	movslq %ebx,%rsi
  8041604b46:	4c 89 e7             	mov    %r12,%rdi
  8041604b49:	48 b8 93 51 60 41 80 	movabs $0x8041605193,%rax
  8041604b50:	00 00 00 
  8041604b53:	ff d0                	callq  *%rax
  8041604b55:	41 29 c5             	sub    %eax,%r13d
  8041604b58:	45 85 ed             	test   %r13d,%r13d
  8041604b5b:	7e 28                	jle    8041604b85 <vprintfmt+0x2ae>
            putch(padc, putdat);
  8041604b5d:	0f be 45 a0          	movsbl -0x60(%rbp),%eax
  8041604b61:	89 5d a0             	mov    %ebx,-0x60(%rbp)
  8041604b64:	4c 89 65 90          	mov    %r12,-0x70(%rbp)
  8041604b68:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041604b6c:	41 89 c4             	mov    %eax,%r12d
  8041604b6f:	48 89 de             	mov    %rbx,%rsi
  8041604b72:	44 89 e7             	mov    %r12d,%edi
  8041604b75:	41 ff d7             	callq  *%r15
          for (width -= strnlen(p, precision); width > 0; width--)
  8041604b78:	41 83 ed 01          	sub    $0x1,%r13d
  8041604b7c:	75 f1                	jne    8041604b6f <vprintfmt+0x298>
  8041604b7e:	8b 5d a0             	mov    -0x60(%rbp),%ebx
  8041604b81:	4c 8b 65 90          	mov    -0x70(%rbp),%r12
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604b85:	49 8d 54 24 01       	lea    0x1(%r12),%rdx
  8041604b8a:	41 0f b6 04 24       	movzbl (%r12),%eax
  8041604b8f:	0f be f8             	movsbl %al,%edi
  8041604b92:	85 ff                	test   %edi,%edi
  8041604b94:	75 85                	jne    8041604b1b <vprintfmt+0x244>
  8041604b96:	e9 8b 02 00 00       	jmpq   8041604e26 <vprintfmt+0x54f>
            putch(ch, putdat);
  8041604b9b:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604b9f:	41 ff d7             	callq  *%r15
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604ba2:	41 83 ed 01          	sub    $0x1,%r13d
  8041604ba6:	41 0f b6 04 24       	movzbl (%r12),%eax
  8041604bab:	0f be f8             	movsbl %al,%edi
  8041604bae:	49 83 c4 01          	add    $0x1,%r12
  8041604bb2:	85 ff                	test   %edi,%edi
  8041604bb4:	74 27                	je     8041604bdd <vprintfmt+0x306>
  8041604bb6:	85 db                	test   %ebx,%ebx
  8041604bb8:	78 05                	js     8041604bbf <vprintfmt+0x2e8>
  8041604bba:	83 eb 01             	sub    $0x1,%ebx
  8041604bbd:	78 45                	js     8041604c04 <vprintfmt+0x32d>
          if (altflag && (ch < ' ' || ch > '~'))
  8041604bbf:	45 85 f6             	test   %r14d,%r14d
  8041604bc2:	74 d7                	je     8041604b9b <vprintfmt+0x2c4>
  8041604bc4:	0f be c0             	movsbl %al,%eax
  8041604bc7:	83 e8 20             	sub    $0x20,%eax
  8041604bca:	83 f8 5e             	cmp    $0x5e,%eax
  8041604bcd:	76 cc                	jbe    8041604b9b <vprintfmt+0x2c4>
            putch('?', putdat);
  8041604bcf:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604bd3:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8041604bd8:	41 ff d7             	callq  *%r15
  8041604bdb:	eb c5                	jmp    8041604ba2 <vprintfmt+0x2cb>
  8041604bdd:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8041604be1:	45 85 ed             	test   %r13d,%r13d
  8041604be4:	0f 8e 3c 02 00 00    	jle    8041604e26 <vprintfmt+0x54f>
  8041604bea:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
          putch(' ', putdat);
  8041604bee:	48 89 de             	mov    %rbx,%rsi
  8041604bf1:	bf 20 00 00 00       	mov    $0x20,%edi
  8041604bf6:	41 ff d7             	callq  *%r15
        for (; width > 0; width--)
  8041604bf9:	41 83 ed 01          	sub    $0x1,%r13d
  8041604bfd:	75 ef                	jne    8041604bee <vprintfmt+0x317>
  8041604bff:	e9 22 02 00 00       	jmpq   8041604e26 <vprintfmt+0x54f>
  8041604c04:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8041604c08:	eb d7                	jmp    8041604be1 <vprintfmt+0x30a>
  if (lflag >= 2)
  8041604c0a:	83 f9 01             	cmp    $0x1,%ecx
  8041604c0d:	7f 20                	jg     8041604c2f <vprintfmt+0x358>
  else if (lflag)
  8041604c0f:	85 c9                	test   %ecx,%ecx
  8041604c11:	75 6d                	jne    8041604c80 <vprintfmt+0x3a9>
    return va_arg(*ap, int);
  8041604c13:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604c16:	83 fa 2f             	cmp    $0x2f,%edx
  8041604c19:	0f 87 87 00 00 00    	ja     8041604ca6 <vprintfmt+0x3cf>
  8041604c1f:	89 d0                	mov    %edx,%eax
  8041604c21:	48 01 c6             	add    %rax,%rsi
  8041604c24:	83 c2 08             	add    $0x8,%edx
  8041604c27:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604c2a:	48 63 1e             	movslq (%rsi),%rbx
  8041604c2d:	eb 16                	jmp    8041604c45 <vprintfmt+0x36e>
    return va_arg(*ap, long long);
  8041604c2f:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604c32:	83 fa 2f             	cmp    $0x2f,%edx
  8041604c35:	77 3b                	ja     8041604c72 <vprintfmt+0x39b>
  8041604c37:	89 d0                	mov    %edx,%eax
  8041604c39:	48 01 c6             	add    %rax,%rsi
  8041604c3c:	83 c2 08             	add    $0x8,%edx
  8041604c3f:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604c42:	48 8b 1e             	mov    (%rsi),%rbx
        num = getint(&aq, lflag);
  8041604c45:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8041604c48:	b9 0a 00 00 00       	mov    $0xa,%ecx
        if ((long long)num < 0) {
  8041604c4d:	48 85 db             	test   %rbx,%rbx
  8041604c50:	0f 89 b5 01 00 00    	jns    8041604e0b <vprintfmt+0x534>
          putch('-', putdat);
  8041604c56:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604c5a:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8041604c5f:	41 ff d7             	callq  *%r15
          num = -(long long)num;
  8041604c62:	48 89 da             	mov    %rbx,%rdx
  8041604c65:	48 f7 da             	neg    %rdx
        base = 10;
  8041604c68:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604c6d:	e9 99 01 00 00       	jmpq   8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, long long);
  8041604c72:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604c76:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604c7a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604c7e:	eb c2                	jmp    8041604c42 <vprintfmt+0x36b>
    return va_arg(*ap, long);
  8041604c80:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604c83:	83 fa 2f             	cmp    $0x2f,%edx
  8041604c86:	77 10                	ja     8041604c98 <vprintfmt+0x3c1>
  8041604c88:	89 d0                	mov    %edx,%eax
  8041604c8a:	48 01 c6             	add    %rax,%rsi
  8041604c8d:	83 c2 08             	add    $0x8,%edx
  8041604c90:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604c93:	48 8b 1e             	mov    (%rsi),%rbx
  8041604c96:	eb ad                	jmp    8041604c45 <vprintfmt+0x36e>
  8041604c98:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604c9c:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604ca0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604ca4:	eb ed                	jmp    8041604c93 <vprintfmt+0x3bc>
    return va_arg(*ap, int);
  8041604ca6:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604caa:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604cae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604cb2:	e9 73 ff ff ff       	jmpq   8041604c2a <vprintfmt+0x353>
  if (lflag >= 2)
  8041604cb7:	83 f9 01             	cmp    $0x1,%ecx
  8041604cba:	7f 23                	jg     8041604cdf <vprintfmt+0x408>
  else if (lflag)
  8041604cbc:	85 c9                	test   %ecx,%ecx
  8041604cbe:	75 4d                	jne    8041604d0d <vprintfmt+0x436>
    return va_arg(*ap, unsigned int);
  8041604cc0:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604cc3:	83 fa 2f             	cmp    $0x2f,%edx
  8041604cc6:	77 73                	ja     8041604d3b <vprintfmt+0x464>
  8041604cc8:	89 d0                	mov    %edx,%eax
  8041604cca:	48 01 c6             	add    %rax,%rsi
  8041604ccd:	83 c2 08             	add    $0x8,%edx
  8041604cd0:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604cd3:	8b 16                	mov    (%rsi),%edx
        base = 10;
  8041604cd5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604cda:	e9 2c 01 00 00       	jmpq   8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604cdf:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604ce2:	83 fa 2f             	cmp    $0x2f,%edx
  8041604ce5:	77 18                	ja     8041604cff <vprintfmt+0x428>
  8041604ce7:	89 d0                	mov    %edx,%eax
  8041604ce9:	48 01 c6             	add    %rax,%rsi
  8041604cec:	83 c2 08             	add    $0x8,%edx
  8041604cef:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604cf2:	48 8b 16             	mov    (%rsi),%rdx
        base = 10;
  8041604cf5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604cfa:	e9 0c 01 00 00       	jmpq   8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604cff:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604d03:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604d07:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604d0b:	eb e5                	jmp    8041604cf2 <vprintfmt+0x41b>
    return va_arg(*ap, unsigned long);
  8041604d0d:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604d10:	83 fa 2f             	cmp    $0x2f,%edx
  8041604d13:	77 18                	ja     8041604d2d <vprintfmt+0x456>
  8041604d15:	89 d0                	mov    %edx,%eax
  8041604d17:	48 01 c6             	add    %rax,%rsi
  8041604d1a:	83 c2 08             	add    $0x8,%edx
  8041604d1d:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604d20:	48 8b 16             	mov    (%rsi),%rdx
        base = 10;
  8041604d23:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604d28:	e9 de 00 00 00       	jmpq   8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long);
  8041604d2d:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604d31:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604d35:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604d39:	eb e5                	jmp    8041604d20 <vprintfmt+0x449>
    return va_arg(*ap, unsigned int);
  8041604d3b:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604d3f:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604d43:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604d47:	eb 8a                	jmp    8041604cd3 <vprintfmt+0x3fc>
  if (lflag >= 2)
  8041604d49:	83 f9 01             	cmp    $0x1,%ecx
  8041604d4c:	7f 23                	jg     8041604d71 <vprintfmt+0x49a>
  else if (lflag)
  8041604d4e:	85 c9                	test   %ecx,%ecx
  8041604d50:	75 4a                	jne    8041604d9c <vprintfmt+0x4c5>
    return va_arg(*ap, unsigned int);
  8041604d52:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604d55:	83 fa 2f             	cmp    $0x2f,%edx
  8041604d58:	77 6d                	ja     8041604dc7 <vprintfmt+0x4f0>
  8041604d5a:	89 d0                	mov    %edx,%eax
  8041604d5c:	48 01 c6             	add    %rax,%rsi
  8041604d5f:	83 c2 08             	add    $0x8,%edx
  8041604d62:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604d65:	8b 16                	mov    (%rsi),%edx
        base = 8;
  8041604d67:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604d6c:	e9 9a 00 00 00       	jmpq   8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604d71:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604d74:	83 fa 2f             	cmp    $0x2f,%edx
  8041604d77:	77 15                	ja     8041604d8e <vprintfmt+0x4b7>
  8041604d79:	89 d0                	mov    %edx,%eax
  8041604d7b:	48 01 c6             	add    %rax,%rsi
  8041604d7e:	83 c2 08             	add    $0x8,%edx
  8041604d81:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604d84:	48 8b 16             	mov    (%rsi),%rdx
        base = 8;
  8041604d87:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604d8c:	eb 7d                	jmp    8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604d8e:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604d92:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604d96:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604d9a:	eb e8                	jmp    8041604d84 <vprintfmt+0x4ad>
    return va_arg(*ap, unsigned long);
  8041604d9c:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604d9f:	83 fa 2f             	cmp    $0x2f,%edx
  8041604da2:	77 15                	ja     8041604db9 <vprintfmt+0x4e2>
  8041604da4:	89 d0                	mov    %edx,%eax
  8041604da6:	48 01 c6             	add    %rax,%rsi
  8041604da9:	83 c2 08             	add    $0x8,%edx
  8041604dac:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604daf:	48 8b 16             	mov    (%rsi),%rdx
        base = 8;
  8041604db2:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604db7:	eb 52                	jmp    8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long);
  8041604db9:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604dbd:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604dc1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604dc5:	eb e8                	jmp    8041604daf <vprintfmt+0x4d8>
    return va_arg(*ap, unsigned int);
  8041604dc7:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604dcb:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604dcf:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604dd3:	eb 90                	jmp    8041604d65 <vprintfmt+0x48e>
        putch('0', putdat);
  8041604dd5:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  8041604dd9:	48 89 de             	mov    %rbx,%rsi
  8041604ddc:	bf 30 00 00 00       	mov    $0x30,%edi
  8041604de1:	41 ff d7             	callq  *%r15
        putch('x', putdat);
  8041604de4:	48 89 de             	mov    %rbx,%rsi
  8041604de7:	bf 78 00 00 00       	mov    $0x78,%edi
  8041604dec:	41 ff d7             	callq  *%r15
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041604def:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604df2:	83 f8 2f             	cmp    $0x2f,%eax
  8041604df5:	77 54                	ja     8041604e4b <vprintfmt+0x574>
  8041604df7:	89 c2                	mov    %eax,%edx
  8041604df9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604dfd:	83 c0 08             	add    $0x8,%eax
  8041604e00:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604e03:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041604e06:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8041604e0b:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8041604e10:	45 89 e8             	mov    %r13d,%r8d
  8041604e13:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604e17:	4c 89 ff             	mov    %r15,%rdi
  8041604e1a:	48 b8 a8 47 60 41 80 	movabs $0x80416047a8,%rax
  8041604e21:	00 00 00 
  8041604e24:	ff d0                	callq  *%rax
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8041604e26:	4d 8d 66 01          	lea    0x1(%r14),%r12
  8041604e2a:	41 0f b6 3e          	movzbl (%r14),%edi
  8041604e2e:	83 ff 25             	cmp    $0x25,%edi
  8041604e31:	0f 84 df fa ff ff    	je     8041604916 <vprintfmt+0x3f>
      if (ch == '\0')
  8041604e37:	85 ff                	test   %edi,%edi
  8041604e39:	0f 84 0d 01 00 00    	je     8041604f4c <vprintfmt+0x675>
      putch(ch, putdat);
  8041604e3f:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604e43:	41 ff d7             	callq  *%r15
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8041604e46:	4d 89 e6             	mov    %r12,%r14
  8041604e49:	eb db                	jmp    8041604e26 <vprintfmt+0x54f>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041604e4b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604e4f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604e53:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604e57:	eb aa                	jmp    8041604e03 <vprintfmt+0x52c>
  if (lflag >= 2)
  8041604e59:	83 f9 01             	cmp    $0x1,%ecx
  8041604e5c:	7f 20                	jg     8041604e7e <vprintfmt+0x5a7>
  else if (lflag)
  8041604e5e:	85 c9                	test   %ecx,%ecx
  8041604e60:	75 4a                	jne    8041604eac <vprintfmt+0x5d5>
    return va_arg(*ap, unsigned int);
  8041604e62:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604e65:	83 f8 2f             	cmp    $0x2f,%eax
  8041604e68:	77 70                	ja     8041604eda <vprintfmt+0x603>
  8041604e6a:	89 c2                	mov    %eax,%edx
  8041604e6c:	48 01 d6             	add    %rdx,%rsi
  8041604e6f:	83 c0 08             	add    $0x8,%eax
  8041604e72:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604e75:	8b 16                	mov    (%rsi),%edx
        base = 16;
  8041604e77:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604e7c:	eb 8d                	jmp    8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604e7e:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604e81:	83 fa 2f             	cmp    $0x2f,%edx
  8041604e84:	77 18                	ja     8041604e9e <vprintfmt+0x5c7>
  8041604e86:	89 d0                	mov    %edx,%eax
  8041604e88:	48 01 c6             	add    %rax,%rsi
  8041604e8b:	83 c2 08             	add    $0x8,%edx
  8041604e8e:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604e91:	48 8b 16             	mov    (%rsi),%rdx
        base = 16;
  8041604e94:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604e99:	e9 6d ff ff ff       	jmpq   8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long long);
  8041604e9e:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604ea2:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604ea6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604eaa:	eb e5                	jmp    8041604e91 <vprintfmt+0x5ba>
    return va_arg(*ap, unsigned long);
  8041604eac:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8041604eaf:	83 fa 2f             	cmp    $0x2f,%edx
  8041604eb2:	77 18                	ja     8041604ecc <vprintfmt+0x5f5>
  8041604eb4:	89 d0                	mov    %edx,%eax
  8041604eb6:	48 01 c6             	add    %rax,%rsi
  8041604eb9:	83 c2 08             	add    $0x8,%edx
  8041604ebc:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8041604ebf:	48 8b 16             	mov    (%rsi),%rdx
        base = 16;
  8041604ec2:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604ec7:	e9 3f ff ff ff       	jmpq   8041604e0b <vprintfmt+0x534>
    return va_arg(*ap, unsigned long);
  8041604ecc:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604ed0:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604ed4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604ed8:	eb e5                	jmp    8041604ebf <vprintfmt+0x5e8>
    return va_arg(*ap, unsigned int);
  8041604eda:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8041604ede:	48 8d 46 08          	lea    0x8(%rsi),%rax
  8041604ee2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604ee6:	eb 8d                	jmp    8041604e75 <vprintfmt+0x59e>
        putch(ch, putdat);
  8041604ee8:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604eec:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604ef1:	41 ff d7             	callq  *%r15
        break;
  8041604ef4:	e9 2d ff ff ff       	jmpq   8041604e26 <vprintfmt+0x54f>
        putch('%', putdat);
  8041604ef9:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041604efd:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604f02:	41 ff d7             	callq  *%r15
        for (fmt--; fmt[-1] != '%'; fmt--)
  8041604f05:	41 80 7c 24 ff 25    	cmpb   $0x25,-0x1(%r12)
  8041604f0b:	0f 84 fd f9 ff ff    	je     804160490e <vprintfmt+0x37>
  8041604f11:	4d 89 e6             	mov    %r12,%r14
  8041604f14:	49 83 ee 01          	sub    $0x1,%r14
  8041604f18:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8041604f1d:	75 f5                	jne    8041604f14 <vprintfmt+0x63d>
  8041604f1f:	e9 02 ff ff ff       	jmpq   8041604e26 <vprintfmt+0x54f>
        if (width > 0 && padc != '-')
  8041604f24:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041604f28:	74 09                	je     8041604f33 <vprintfmt+0x65c>
  8041604f2a:	45 85 ed             	test   %r13d,%r13d
  8041604f2d:	0f 8f 06 fc ff ff    	jg     8041604b39 <vprintfmt+0x262>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604f33:	48 ba 3a 61 60 41 80 	movabs $0x804160613a,%rdx
  8041604f3a:	00 00 00 
  8041604f3d:	bf 28 00 00 00       	mov    $0x28,%edi
  8041604f42:	b8 28 00 00 00       	mov    $0x28,%eax
  8041604f47:	e9 cf fb ff ff       	jmpq   8041604b1b <vprintfmt+0x244>
}
  8041604f4c:	48 83 c4 48          	add    $0x48,%rsp
  8041604f50:	5b                   	pop    %rbx
  8041604f51:	41 5c                	pop    %r12
  8041604f53:	41 5d                	pop    %r13
  8041604f55:	41 5e                	pop    %r14
  8041604f57:	41 5f                	pop    %r15
  8041604f59:	5d                   	pop    %rbp
  8041604f5a:	c3                   	retq   

0000008041604f5b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8041604f5b:	55                   	push   %rbp
  8041604f5c:	48 89 e5             	mov    %rsp,%rbp
  8041604f5f:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  8041604f63:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  8041604f67:	48 63 c6             	movslq %esi,%rax
  8041604f6a:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  8041604f6f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8041604f73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  8041604f7a:	48 85 ff             	test   %rdi,%rdi
  8041604f7d:	74 2a                	je     8041604fa9 <vsnprintf+0x4e>
  8041604f7f:	85 f6                	test   %esi,%esi
  8041604f81:	7e 26                	jle    8041604fa9 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  8041604f83:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  8041604f87:	48 bf 34 48 60 41 80 	movabs $0x8041604834,%rdi
  8041604f8e:	00 00 00 
  8041604f91:	48 b8 d7 48 60 41 80 	movabs $0x80416048d7,%rax
  8041604f98:	00 00 00 
  8041604f9b:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  8041604f9d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8041604fa1:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  8041604fa4:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  8041604fa7:	c9                   	leaveq 
  8041604fa8:	c3                   	retq   
    return -E_INVAL;
  8041604fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041604fae:	eb f7                	jmp    8041604fa7 <vsnprintf+0x4c>

0000008041604fb0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  8041604fb0:	55                   	push   %rbp
  8041604fb1:	48 89 e5             	mov    %rsp,%rbp
  8041604fb4:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041604fbb:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041604fc2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041604fc9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604fd0:	84 c0                	test   %al,%al
  8041604fd2:	74 20                	je     8041604ff4 <snprintf+0x44>
  8041604fd4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604fd8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604fdc:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604fe0:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041604fe4:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604fe8:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604fec:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604ff0:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  8041604ff4:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041604ffb:	00 00 00 
  8041604ffe:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041605005:	00 00 00 
  8041605008:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160500c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041605013:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160501a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  8041605021:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8041605028:	48 b8 5b 4f 60 41 80 	movabs $0x8041604f5b,%rax
  804160502f:	00 00 00 
  8041605032:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  8041605034:	c9                   	leaveq 
  8041605035:	c3                   	retq   

0000008041605036 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  8041605036:	55                   	push   %rbp
  8041605037:	48 89 e5             	mov    %rsp,%rbp
  804160503a:	41 57                	push   %r15
  804160503c:	41 56                	push   %r14
  804160503e:	41 55                	push   %r13
  8041605040:	41 54                	push   %r12
  8041605042:	53                   	push   %rbx
  8041605043:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  8041605047:	48 85 ff             	test   %rdi,%rdi
  804160504a:	74 1e                	je     804160506a <readline+0x34>
    cprintf("%s", prompt);
  804160504c:	48 89 fe             	mov    %rdi,%rsi
  804160504f:	48 bf eb 59 60 41 80 	movabs $0x80416059eb,%rdi
  8041605056:	00 00 00 
  8041605059:	b8 00 00 00 00       	mov    $0x0,%eax
  804160505e:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  8041605065:	00 00 00 
  8041605068:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  804160506a:	bf 00 00 00 00       	mov    $0x0,%edi
  804160506f:	48 b8 3a 0c 60 41 80 	movabs $0x8041600c3a,%rax
  8041605076:	00 00 00 
  8041605079:	ff d0                	callq  *%rax
  804160507b:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  804160507e:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  8041605084:	49 bd 1a 0c 60 41 80 	movabs $0x8041600c1a,%r13
  804160508b:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  804160508e:	49 bf 08 0c 60 41 80 	movabs $0x8041600c08,%r15
  8041605095:	00 00 00 
  8041605098:	eb 3f                	jmp    80416050d9 <readline+0xa3>
      cprintf("read error: %i\n", c);
  804160509a:	89 c6                	mov    %eax,%esi
  804160509c:	48 bf e8 64 60 41 80 	movabs $0x80416064e8,%rdi
  80416050a3:	00 00 00 
  80416050a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050ab:	48 ba f3 42 60 41 80 	movabs $0x80416042f3,%rdx
  80416050b2:	00 00 00 
  80416050b5:	ff d2                	callq  *%rdx
      return NULL;
  80416050b7:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  80416050bc:	48 83 c4 08          	add    $0x8,%rsp
  80416050c0:	5b                   	pop    %rbx
  80416050c1:	41 5c                	pop    %r12
  80416050c3:	41 5d                	pop    %r13
  80416050c5:	41 5e                	pop    %r14
  80416050c7:	41 5f                	pop    %r15
  80416050c9:	5d                   	pop    %rbp
  80416050ca:	c3                   	retq   
      if (i > 0) {
  80416050cb:	45 85 e4             	test   %r12d,%r12d
  80416050ce:	7e 09                	jle    80416050d9 <readline+0xa3>
        if (echoing) {
  80416050d0:	45 85 f6             	test   %r14d,%r14d
  80416050d3:	75 41                	jne    8041605116 <readline+0xe0>
        i--;
  80416050d5:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  80416050d9:	41 ff d5             	callq  *%r13
  80416050dc:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  80416050de:	85 c0                	test   %eax,%eax
  80416050e0:	78 b8                	js     804160509a <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  80416050e2:	83 f8 08             	cmp    $0x8,%eax
  80416050e5:	74 e4                	je     80416050cb <readline+0x95>
  80416050e7:	83 f8 7f             	cmp    $0x7f,%eax
  80416050ea:	74 df                	je     80416050cb <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  80416050ec:	83 f8 1f             	cmp    $0x1f,%eax
  80416050ef:	7e 46                	jle    8041605137 <readline+0x101>
  80416050f1:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  80416050f8:	7f 3d                	jg     8041605137 <readline+0x101>
      if (echoing)
  80416050fa:	45 85 f6             	test   %r14d,%r14d
  80416050fd:	75 31                	jne    8041605130 <readline+0xfa>
      buf[i++] = c;
  80416050ff:	49 63 c4             	movslq %r12d,%rax
  8041605102:	48 b9 e0 31 62 41 80 	movabs $0x80416231e0,%rcx
  8041605109:	00 00 00 
  804160510c:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  804160510f:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  8041605114:	eb c3                	jmp    80416050d9 <readline+0xa3>
          cputchar('\b');
  8041605116:	bf 08 00 00 00       	mov    $0x8,%edi
  804160511b:	41 ff d7             	callq  *%r15
          cputchar(' ');
  804160511e:	bf 20 00 00 00       	mov    $0x20,%edi
  8041605123:	41 ff d7             	callq  *%r15
          cputchar('\b');
  8041605126:	bf 08 00 00 00       	mov    $0x8,%edi
  804160512b:	41 ff d7             	callq  *%r15
  804160512e:	eb a5                	jmp    80416050d5 <readline+0x9f>
        cputchar(c);
  8041605130:	89 c7                	mov    %eax,%edi
  8041605132:	41 ff d7             	callq  *%r15
  8041605135:	eb c8                	jmp    80416050ff <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  8041605137:	83 fb 0a             	cmp    $0xa,%ebx
  804160513a:	74 05                	je     8041605141 <readline+0x10b>
  804160513c:	83 fb 0d             	cmp    $0xd,%ebx
  804160513f:	75 98                	jne    80416050d9 <readline+0xa3>
      if (echoing)
  8041605141:	45 85 f6             	test   %r14d,%r14d
  8041605144:	75 17                	jne    804160515d <readline+0x127>
      buf[i] = 0;
  8041605146:	48 b8 e0 31 62 41 80 	movabs $0x80416231e0,%rax
  804160514d:	00 00 00 
  8041605150:	4d 63 e4             	movslq %r12d,%r12
  8041605153:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  8041605158:	e9 5f ff ff ff       	jmpq   80416050bc <readline+0x86>
        cputchar('\n');
  804160515d:	bf 0a 00 00 00       	mov    $0xa,%edi
  8041605162:	48 b8 08 0c 60 41 80 	movabs $0x8041600c08,%rax
  8041605169:	00 00 00 
  804160516c:	ff d0                	callq  *%rax
  804160516e:	eb d6                	jmp    8041605146 <readline+0x110>

0000008041605170 <strlen>:
// but it makes an even bigger difference on bochs.
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s) {
  8041605170:	55                   	push   %rbp
  8041605171:	48 89 e5             	mov    %rsp,%rbp
  int n;

  for (n = 0; *s != '\0'; s++)
  8041605174:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041605177:	74 13                	je     804160518c <strlen+0x1c>
  8041605179:	b8 00 00 00 00       	mov    $0x0,%eax
    n++;
  804160517e:	83 c0 01             	add    $0x1,%eax
  for (n = 0; *s != '\0'; s++)
  8041605181:	48 83 c7 01          	add    $0x1,%rdi
  8041605185:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041605188:	75 f4                	jne    804160517e <strlen+0xe>
  return n;
}
  804160518a:	5d                   	pop    %rbp
  804160518b:	c3                   	retq   
  for (n = 0; *s != '\0'; s++)
  804160518c:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
  8041605191:	eb f7                	jmp    804160518a <strlen+0x1a>

0000008041605193 <strnlen>:

int
strnlen(const char *s, size_t size) {
  8041605193:	55                   	push   %rbp
  8041605194:	48 89 e5             	mov    %rsp,%rbp
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041605197:	48 85 f6             	test   %rsi,%rsi
  804160519a:	74 20                	je     80416051bc <strnlen+0x29>
  804160519c:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160519f:	74 22                	je     80416051c3 <strnlen+0x30>
  80416051a1:	48 01 fe             	add    %rdi,%rsi
  80416051a4:	b8 00 00 00 00       	mov    $0x0,%eax
    n++;
  80416051a9:	83 c0 01             	add    $0x1,%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80416051ac:	48 83 c7 01          	add    $0x1,%rdi
  80416051b0:	48 39 fe             	cmp    %rdi,%rsi
  80416051b3:	74 05                	je     80416051ba <strnlen+0x27>
  80416051b5:	80 3f 00             	cmpb   $0x0,(%rdi)
  80416051b8:	75 ef                	jne    80416051a9 <strnlen+0x16>
  return n;
}
  80416051ba:	5d                   	pop    %rbp
  80416051bb:	c3                   	retq   
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80416051bc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416051c1:	eb f7                	jmp    80416051ba <strnlen+0x27>
  80416051c3:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
  80416051c8:	eb f0                	jmp    80416051ba <strnlen+0x27>

00000080416051ca <strcpy>:

char *
strcpy(char *dst, const char *src) {
  80416051ca:	55                   	push   %rbp
  80416051cb:	48 89 e5             	mov    %rsp,%rbp
  80416051ce:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  80416051d1:	48 89 fa             	mov    %rdi,%rdx
  80416051d4:	48 83 c2 01          	add    $0x1,%rdx
  80416051d8:	48 83 c6 01          	add    $0x1,%rsi
  80416051dc:	0f b6 4e ff          	movzbl -0x1(%rsi),%ecx
  80416051e0:	88 4a ff             	mov    %cl,-0x1(%rdx)
  80416051e3:	84 c9                	test   %cl,%cl
  80416051e5:	75 ed                	jne    80416051d4 <strcpy+0xa>
    /* do nothing */;
  return ret;
}
  80416051e7:	5d                   	pop    %rbp
  80416051e8:	c3                   	retq   

00000080416051e9 <strcat>:

char *
strcat(char *dst, const char *src) {
  80416051e9:	55                   	push   %rbp
  80416051ea:	48 89 e5             	mov    %rsp,%rbp
  80416051ed:	41 54                	push   %r12
  80416051ef:	53                   	push   %rbx
  80416051f0:	48 89 fb             	mov    %rdi,%rbx
  80416051f3:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  80416051f6:	48 b8 70 51 60 41 80 	movabs $0x8041605170,%rax
  80416051fd:	00 00 00 
  8041605200:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  8041605202:	48 63 f8             	movslq %eax,%rdi
  8041605205:	48 01 df             	add    %rbx,%rdi
  8041605208:	4c 89 e6             	mov    %r12,%rsi
  804160520b:	48 b8 ca 51 60 41 80 	movabs $0x80416051ca,%rax
  8041605212:	00 00 00 
  8041605215:	ff d0                	callq  *%rax
  return dst;
}
  8041605217:	48 89 d8             	mov    %rbx,%rax
  804160521a:	5b                   	pop    %rbx
  804160521b:	41 5c                	pop    %r12
  804160521d:	5d                   	pop    %rbp
  804160521e:	c3                   	retq   

000000804160521f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  804160521f:	55                   	push   %rbp
  8041605220:	48 89 e5             	mov    %rsp,%rbp
  8041605223:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8041605226:	48 85 d2             	test   %rdx,%rdx
  8041605229:	74 1e                	je     8041605249 <strncpy+0x2a>
  804160522b:	48 01 fa             	add    %rdi,%rdx
  804160522e:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  8041605231:	48 83 c1 01          	add    $0x1,%rcx
  8041605235:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041605239:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  804160523d:	80 3e 01             	cmpb   $0x1,(%rsi)
  8041605240:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  8041605244:	48 39 ca             	cmp    %rcx,%rdx
  8041605247:	75 e8                	jne    8041605231 <strncpy+0x12>
  }
  return ret;
}
  8041605249:	5d                   	pop    %rbp
  804160524a:	c3                   	retq   

000000804160524b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size) {
  804160524b:	55                   	push   %rbp
  804160524c:	48 89 e5             	mov    %rsp,%rbp
  804160524f:	48 89 f8             	mov    %rdi,%rax
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8041605252:	48 85 d2             	test   %rdx,%rdx
  8041605255:	74 34                	je     804160528b <strlcpy+0x40>
    while (--size > 0 && *src != '\0')
  8041605257:	48 83 ea 01          	sub    $0x1,%rdx
  804160525b:	74 33                	je     8041605290 <strlcpy+0x45>
  804160525d:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041605261:	45 84 c0             	test   %r8b,%r8b
  8041605264:	74 2f                	je     8041605295 <strlcpy+0x4a>
  8041605266:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  804160526a:	48 01 d6             	add    %rdx,%rsi
      *dst++ = *src++;
  804160526d:	48 83 c0 01          	add    $0x1,%rax
  8041605271:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  8041605275:	48 39 ce             	cmp    %rcx,%rsi
  8041605278:	74 0e                	je     8041605288 <strlcpy+0x3d>
  804160527a:	48 83 c1 01          	add    $0x1,%rcx
  804160527e:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  8041605283:	45 84 c0             	test   %r8b,%r8b
  8041605286:	75 e5                	jne    804160526d <strlcpy+0x22>
    *dst = '\0';
  8041605288:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  804160528b:	48 29 f8             	sub    %rdi,%rax
}
  804160528e:	5d                   	pop    %rbp
  804160528f:	c3                   	retq   
    while (--size > 0 && *src != '\0')
  8041605290:	48 89 f8             	mov    %rdi,%rax
  8041605293:	eb f3                	jmp    8041605288 <strlcpy+0x3d>
  8041605295:	48 89 f8             	mov    %rdi,%rax
  8041605298:	eb ee                	jmp    8041605288 <strlcpy+0x3d>

000000804160529a <strcmp>:
  }
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  804160529a:	55                   	push   %rbp
  804160529b:	48 89 e5             	mov    %rsp,%rbp
  while (*p && *p == *q)
  804160529e:	0f b6 07             	movzbl (%rdi),%eax
  80416052a1:	84 c0                	test   %al,%al
  80416052a3:	74 17                	je     80416052bc <strcmp+0x22>
  80416052a5:	3a 06                	cmp    (%rsi),%al
  80416052a7:	75 13                	jne    80416052bc <strcmp+0x22>
    p++, q++;
  80416052a9:	48 83 c7 01          	add    $0x1,%rdi
  80416052ad:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  80416052b1:	0f b6 07             	movzbl (%rdi),%eax
  80416052b4:	84 c0                	test   %al,%al
  80416052b6:	74 04                	je     80416052bc <strcmp+0x22>
  80416052b8:	3a 06                	cmp    (%rsi),%al
  80416052ba:	74 ed                	je     80416052a9 <strcmp+0xf>
  return (int)((unsigned char)*p - (unsigned char)*q);
  80416052bc:	0f b6 c0             	movzbl %al,%eax
  80416052bf:	0f b6 16             	movzbl (%rsi),%edx
  80416052c2:	29 d0                	sub    %edx,%eax
}
  80416052c4:	5d                   	pop    %rbp
  80416052c5:	c3                   	retq   

00000080416052c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  80416052c6:	55                   	push   %rbp
  80416052c7:	48 89 e5             	mov    %rsp,%rbp
  while (n > 0 && *p && *p == *q)
  80416052ca:	48 85 d2             	test   %rdx,%rdx
  80416052cd:	74 30                	je     80416052ff <strncmp+0x39>
  80416052cf:	0f b6 07             	movzbl (%rdi),%eax
  80416052d2:	84 c0                	test   %al,%al
  80416052d4:	74 1f                	je     80416052f5 <strncmp+0x2f>
  80416052d6:	3a 06                	cmp    (%rsi),%al
  80416052d8:	75 1b                	jne    80416052f5 <strncmp+0x2f>
  80416052da:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  80416052dd:	48 83 c7 01          	add    $0x1,%rdi
  80416052e1:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  80416052e5:	48 39 d7             	cmp    %rdx,%rdi
  80416052e8:	74 1c                	je     8041605306 <strncmp+0x40>
  80416052ea:	0f b6 07             	movzbl (%rdi),%eax
  80416052ed:	84 c0                	test   %al,%al
  80416052ef:	74 04                	je     80416052f5 <strncmp+0x2f>
  80416052f1:	3a 06                	cmp    (%rsi),%al
  80416052f3:	74 e8                	je     80416052dd <strncmp+0x17>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  80416052f5:	0f b6 07             	movzbl (%rdi),%eax
  80416052f8:	0f b6 16             	movzbl (%rsi),%edx
  80416052fb:	29 d0                	sub    %edx,%eax
}
  80416052fd:	5d                   	pop    %rbp
  80416052fe:	c3                   	retq   
    return 0;
  80416052ff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605304:	eb f7                	jmp    80416052fd <strncmp+0x37>
  8041605306:	b8 00 00 00 00       	mov    $0x0,%eax
  804160530b:	eb f0                	jmp    80416052fd <strncmp+0x37>

000000804160530d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  804160530d:	55                   	push   %rbp
  804160530e:	48 89 e5             	mov    %rsp,%rbp
  for (; *s; s++)
  8041605311:	0f b6 07             	movzbl (%rdi),%eax
  8041605314:	84 c0                	test   %al,%al
  8041605316:	74 22                	je     804160533a <strchr+0x2d>
  8041605318:	89 f2                	mov    %esi,%edx
    if (*s == c)
  804160531a:	40 38 c6             	cmp    %al,%sil
  804160531d:	74 22                	je     8041605341 <strchr+0x34>
  for (; *s; s++)
  804160531f:	48 83 c7 01          	add    $0x1,%rdi
  8041605323:	0f b6 07             	movzbl (%rdi),%eax
  8041605326:	84 c0                	test   %al,%al
  8041605328:	74 09                	je     8041605333 <strchr+0x26>
    if (*s == c)
  804160532a:	38 d0                	cmp    %dl,%al
  804160532c:	75 f1                	jne    804160531f <strchr+0x12>
  for (; *s; s++)
  804160532e:	48 89 f8             	mov    %rdi,%rax
  8041605331:	eb 05                	jmp    8041605338 <strchr+0x2b>
      return (char *)s;
  return 0;
  8041605333:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041605338:	5d                   	pop    %rbp
  8041605339:	c3                   	retq   
  return 0;
  804160533a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160533f:	eb f7                	jmp    8041605338 <strchr+0x2b>
    if (*s == c)
  8041605341:	48 89 f8             	mov    %rdi,%rax
  8041605344:	eb f2                	jmp    8041605338 <strchr+0x2b>

0000008041605346 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  8041605346:	55                   	push   %rbp
  8041605347:	48 89 e5             	mov    %rsp,%rbp
  804160534a:	48 89 f8             	mov    %rdi,%rax
  for (; *s; s++)
  804160534d:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  8041605350:	40 38 f2             	cmp    %sil,%dl
  8041605353:	74 15                	je     804160536a <strfind+0x24>
  8041605355:	89 f1                	mov    %esi,%ecx
  8041605357:	84 d2                	test   %dl,%dl
  8041605359:	74 0f                	je     804160536a <strfind+0x24>
  for (; *s; s++)
  804160535b:	48 83 c0 01          	add    $0x1,%rax
  804160535f:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  8041605362:	38 ca                	cmp    %cl,%dl
  8041605364:	74 04                	je     804160536a <strfind+0x24>
  8041605366:	84 d2                	test   %dl,%dl
  8041605368:	75 f1                	jne    804160535b <strfind+0x15>
      break;
  return (char *)s;
}
  804160536a:	5d                   	pop    %rbp
  804160536b:	c3                   	retq   

000000804160536c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  804160536c:	55                   	push   %rbp
  804160536d:	48 89 e5             	mov    %rsp,%rbp
  if (n == 0)
  8041605370:	48 85 d2             	test   %rdx,%rdx
  8041605373:	74 13                	je     8041605388 <memset+0x1c>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8041605375:	40 f6 c7 03          	test   $0x3,%dil
  8041605379:	75 05                	jne    8041605380 <memset+0x14>
  804160537b:	f6 c2 03             	test   $0x3,%dl
  804160537e:	74 0d                	je     804160538d <memset+0x21>
    uint32_t k = c & 0xFFU;
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  8041605380:	89 f0                	mov    %esi,%eax
  8041605382:	48 89 d1             	mov    %rdx,%rcx
  8041605385:	fc                   	cld    
  8041605386:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  8041605388:	48 89 f8             	mov    %rdi,%rax
  804160538b:	5d                   	pop    %rbp
  804160538c:	c3                   	retq   
    uint32_t k = c & 0xFFU;
  804160538d:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  8041605391:	89 f0                	mov    %esi,%eax
  8041605393:	c1 e0 08             	shl    $0x8,%eax
  8041605396:	89 f1                	mov    %esi,%ecx
  8041605398:	c1 e1 18             	shl    $0x18,%ecx
  804160539b:	41 89 f0             	mov    %esi,%r8d
  804160539e:	41 c1 e0 10          	shl    $0x10,%r8d
  80416053a2:	44 09 c1             	or     %r8d,%ecx
  80416053a5:	09 ce                	or     %ecx,%esi
  80416053a7:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  80416053a9:	48 c1 ea 02          	shr    $0x2,%rdx
  80416053ad:	48 89 d1             	mov    %rdx,%rcx
  80416053b0:	fc                   	cld    
  80416053b1:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  80416053b3:	eb d3                	jmp    8041605388 <memset+0x1c>

00000080416053b5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  80416053b5:	55                   	push   %rbp
  80416053b6:	48 89 e5             	mov    %rsp,%rbp
  80416053b9:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  80416053bc:	48 39 fe             	cmp    %rdi,%rsi
  80416053bf:	73 43                	jae    8041605404 <memmove+0x4f>
  80416053c1:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  80416053c5:	48 39 cf             	cmp    %rcx,%rdi
  80416053c8:	73 3a                	jae    8041605404 <memmove+0x4f>
    s += n;
    d += n;
  80416053ca:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  80416053ce:	48 89 ce             	mov    %rcx,%rsi
  80416053d1:	48 09 fe             	or     %rdi,%rsi
  80416053d4:	40 f6 c6 03          	test   $0x3,%sil
  80416053d8:	75 19                	jne    80416053f3 <memmove+0x3e>
  80416053da:	f6 c2 03             	test   $0x3,%dl
  80416053dd:	75 14                	jne    80416053f3 <memmove+0x3e>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  80416053df:	48 83 ef 04          	sub    $0x4,%rdi
  80416053e3:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  80416053e7:	48 c1 ea 02          	shr    $0x2,%rdx
  80416053eb:	48 89 d1             	mov    %rdx,%rcx
  80416053ee:	fd                   	std    
  80416053ef:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80416053f1:	eb 0e                	jmp    8041605401 <memmove+0x4c>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  80416053f3:	48 83 ef 01          	sub    $0x1,%rdi
  80416053f7:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  80416053fb:	48 89 d1             	mov    %rdx,%rcx
  80416053fe:	fd                   	std    
  80416053ff:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8041605401:	fc                   	cld    
  8041605402:	eb 19                	jmp    804160541d <memmove+0x68>
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8041605404:	48 89 f1             	mov    %rsi,%rcx
  8041605407:	48 09 c1             	or     %rax,%rcx
  804160540a:	f6 c1 03             	test   $0x3,%cl
  804160540d:	75 05                	jne    8041605414 <memmove+0x5f>
  804160540f:	f6 c2 03             	test   $0x3,%dl
  8041605412:	74 0b                	je     804160541f <memmove+0x6a>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8041605414:	48 89 c7             	mov    %rax,%rdi
  8041605417:	48 89 d1             	mov    %rdx,%rcx
  804160541a:	fc                   	cld    
  804160541b:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  804160541d:	5d                   	pop    %rbp
  804160541e:	c3                   	retq   
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  804160541f:	48 c1 ea 02          	shr    $0x2,%rdx
  8041605423:	48 89 d1             	mov    %rdx,%rcx
  8041605426:	48 89 c7             	mov    %rax,%rdi
  8041605429:	fc                   	cld    
  804160542a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160542c:	eb ef                	jmp    804160541d <memmove+0x68>

000000804160542e <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  804160542e:	55                   	push   %rbp
  804160542f:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8041605432:	48 b8 b5 53 60 41 80 	movabs $0x80416053b5,%rax
  8041605439:	00 00 00 
  804160543c:	ff d0                	callq  *%rax
}
  804160543e:	5d                   	pop    %rbp
  804160543f:	c3                   	retq   

0000008041605440 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8041605440:	55                   	push   %rbp
  8041605441:	48 89 e5             	mov    %rsp,%rbp
  8041605444:	41 57                	push   %r15
  8041605446:	41 56                	push   %r14
  8041605448:	41 55                	push   %r13
  804160544a:	41 54                	push   %r12
  804160544c:	53                   	push   %rbx
  804160544d:	49 89 fe             	mov    %rdi,%r14
  8041605450:	49 89 f7             	mov    %rsi,%r15
  8041605453:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  8041605456:	48 89 f7             	mov    %rsi,%rdi
  8041605459:	48 b8 70 51 60 41 80 	movabs $0x8041605170,%rax
  8041605460:	00 00 00 
  8041605463:	ff d0                	callq  *%rax
  8041605465:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  8041605468:	4c 89 ee             	mov    %r13,%rsi
  804160546b:	4c 89 f7             	mov    %r14,%rdi
  804160546e:	48 b8 93 51 60 41 80 	movabs $0x8041605193,%rax
  8041605475:	00 00 00 
  8041605478:	ff d0                	callq  *%rax
  804160547a:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  804160547d:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  8041605481:	4d 39 e5             	cmp    %r12,%r13
  8041605484:	74 26                	je     80416054ac <strlcat+0x6c>
  if (srclen < maxlen - dstlen) {
  8041605486:	4c 89 e8             	mov    %r13,%rax
  8041605489:	4c 29 e0             	sub    %r12,%rax
  804160548c:	48 39 c3             	cmp    %rax,%rbx
  804160548f:	73 26                	jae    80416054b7 <strlcat+0x77>
    memcpy(dst + dstlen, src, srclen + 1);
  8041605491:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  8041605495:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8041605499:	4c 89 fe             	mov    %r15,%rsi
  804160549c:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416054a3:	00 00 00 
  80416054a6:	ff d0                	callq  *%rax
  return dstlen + srclen;
  80416054a8:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  80416054ac:	5b                   	pop    %rbx
  80416054ad:	41 5c                	pop    %r12
  80416054af:	41 5d                	pop    %r13
  80416054b1:	41 5e                	pop    %r14
  80416054b3:	41 5f                	pop    %r15
  80416054b5:	5d                   	pop    %rbp
  80416054b6:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  80416054b7:	49 83 ed 01          	sub    $0x1,%r13
  80416054bb:	4d 01 e6             	add    %r12,%r14
  80416054be:	4c 89 ea             	mov    %r13,%rdx
  80416054c1:	4c 89 fe             	mov    %r15,%rsi
  80416054c4:	4c 89 f7             	mov    %r14,%rdi
  80416054c7:	48 b8 2e 54 60 41 80 	movabs $0x804160542e,%rax
  80416054ce:	00 00 00 
  80416054d1:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80416054d3:	43 c6 04 2e 00       	movb   $0x0,(%r14,%r13,1)
  80416054d8:	eb ce                	jmp    80416054a8 <strlcat+0x68>

00000080416054da <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n) {
  80416054da:	55                   	push   %rbp
  80416054db:	48 89 e5             	mov    %rsp,%rbp
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80416054de:	48 85 d2             	test   %rdx,%rdx
  80416054e1:	74 3c                	je     804160551f <memcmp+0x45>
    if (*s1 != *s2)
  80416054e3:	0f b6 0f             	movzbl (%rdi),%ecx
  80416054e6:	44 0f b6 06          	movzbl (%rsi),%r8d
  80416054ea:	44 38 c1             	cmp    %r8b,%cl
  80416054ed:	75 1d                	jne    804160550c <memcmp+0x32>
  80416054ef:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80416054f4:	48 39 d0             	cmp    %rdx,%rax
  80416054f7:	74 1f                	je     8041605518 <memcmp+0x3e>
    if (*s1 != *s2)
  80416054f9:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80416054fd:	48 83 c0 01          	add    $0x1,%rax
  8041605501:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  8041605507:	44 38 c1             	cmp    %r8b,%cl
  804160550a:	74 e8                	je     80416054f4 <memcmp+0x1a>
      return (int)*s1 - (int)*s2;
  804160550c:	0f b6 c1             	movzbl %cl,%eax
  804160550f:	45 0f b6 c0          	movzbl %r8b,%r8d
  8041605513:	44 29 c0             	sub    %r8d,%eax
    s1++, s2++;
  }

  return 0;
}
  8041605516:	5d                   	pop    %rbp
  8041605517:	c3                   	retq   
  return 0;
  8041605518:	b8 00 00 00 00       	mov    $0x0,%eax
  804160551d:	eb f7                	jmp    8041605516 <memcmp+0x3c>
  804160551f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605524:	eb f0                	jmp    8041605516 <memcmp+0x3c>

0000008041605526 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  8041605526:	55                   	push   %rbp
  8041605527:	48 89 e5             	mov    %rsp,%rbp
  804160552a:	48 89 f8             	mov    %rdi,%rax
  const void *ends = (const char *)s + n;
  804160552d:	48 01 fa             	add    %rdi,%rdx
  for (; s < ends; s++)
  8041605530:	48 39 d7             	cmp    %rdx,%rdi
  8041605533:	73 14                	jae    8041605549 <memfind+0x23>
    if (*(const unsigned char *)s == (unsigned char)c)
  8041605535:	89 f1                	mov    %esi,%ecx
  8041605537:	40 38 37             	cmp    %sil,(%rdi)
  804160553a:	74 0d                	je     8041605549 <memfind+0x23>
  for (; s < ends; s++)
  804160553c:	48 83 c0 01          	add    $0x1,%rax
  8041605540:	48 39 c2             	cmp    %rax,%rdx
  8041605543:	74 04                	je     8041605549 <memfind+0x23>
    if (*(const unsigned char *)s == (unsigned char)c)
  8041605545:	38 08                	cmp    %cl,(%rax)
  8041605547:	75 f3                	jne    804160553c <memfind+0x16>
      break;
  return (void *)s;
}
  8041605549:	5d                   	pop    %rbp
  804160554a:	c3                   	retq   

000000804160554b <strtol>:

long
strtol(const char *s, char **endptr, int base) {
  804160554b:	55                   	push   %rbp
  804160554c:	48 89 e5             	mov    %rsp,%rbp
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  804160554f:	0f b6 07             	movzbl (%rdi),%eax
  8041605552:	3c 20                	cmp    $0x20,%al
  8041605554:	74 04                	je     804160555a <strtol+0xf>
  8041605556:	3c 09                	cmp    $0x9,%al
  8041605558:	75 0f                	jne    8041605569 <strtol+0x1e>
    s++;
  804160555a:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  804160555e:	0f b6 07             	movzbl (%rdi),%eax
  8041605561:	3c 20                	cmp    $0x20,%al
  8041605563:	74 f5                	je     804160555a <strtol+0xf>
  8041605565:	3c 09                	cmp    $0x9,%al
  8041605567:	74 f1                	je     804160555a <strtol+0xf>

  // plus/minus sign
  if (*s == '+')
  8041605569:	3c 2b                	cmp    $0x2b,%al
  804160556b:	74 2f                	je     804160559c <strtol+0x51>
  int neg  = 0;
  804160556d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  8041605573:	3c 2d                	cmp    $0x2d,%al
  8041605575:	74 31                	je     80416055a8 <strtol+0x5d>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8041605577:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  804160557d:	75 05                	jne    8041605584 <strtol+0x39>
  804160557f:	80 3f 30             	cmpb   $0x30,(%rdi)
  8041605582:	74 30                	je     80416055b4 <strtol+0x69>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
  8041605584:	85 d2                	test   %edx,%edx
  8041605586:	75 0a                	jne    8041605592 <strtol+0x47>
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8041605588:	ba 0a 00 00 00       	mov    $0xa,%edx
  else if (base == 0 && s[0] == '0')
  804160558d:	80 3f 30             	cmpb   $0x30,(%rdi)
  8041605590:	74 2c                	je     80416055be <strtol+0x73>
    base = 10;
  8041605592:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  8041605597:	4c 63 d2             	movslq %edx,%r10
  804160559a:	eb 5c                	jmp    80416055f8 <strtol+0xad>
    s++;
  804160559c:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  80416055a0:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80416055a6:	eb cf                	jmp    8041605577 <strtol+0x2c>
    s++, neg = 1;
  80416055a8:	48 83 c7 01          	add    $0x1,%rdi
  80416055ac:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80416055b2:	eb c3                	jmp    8041605577 <strtol+0x2c>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80416055b4:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  80416055b8:	74 0f                	je     80416055c9 <strtol+0x7e>
  else if (base == 0 && s[0] == '0')
  80416055ba:	85 d2                	test   %edx,%edx
  80416055bc:	75 d4                	jne    8041605592 <strtol+0x47>
    s++, base = 8;
  80416055be:	48 83 c7 01          	add    $0x1,%rdi
  80416055c2:	ba 08 00 00 00       	mov    $0x8,%edx
  80416055c7:	eb c9                	jmp    8041605592 <strtol+0x47>
    s += 2, base = 16;
  80416055c9:	48 83 c7 02          	add    $0x2,%rdi
  80416055cd:	ba 10 00 00 00       	mov    $0x10,%edx
  80416055d2:	eb be                	jmp    8041605592 <strtol+0x47>
    else if (*s >= 'a' && *s <= 'z')
  80416055d4:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80416055d8:	41 80 f8 19          	cmp    $0x19,%r8b
  80416055dc:	77 2f                	ja     804160560d <strtol+0xc2>
      dig = *s - 'a' + 10;
  80416055de:	44 0f be c1          	movsbl %cl,%r8d
  80416055e2:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80416055e6:	39 d1                	cmp    %edx,%ecx
  80416055e8:	7d 37                	jge    8041605621 <strtol+0xd6>
    s++, val = (val * base) + dig;
  80416055ea:	48 83 c7 01          	add    $0x1,%rdi
  80416055ee:	49 0f af c2          	imul   %r10,%rax
  80416055f2:	48 63 c9             	movslq %ecx,%rcx
  80416055f5:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80416055f8:	0f b6 0f             	movzbl (%rdi),%ecx
  80416055fb:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80416055ff:	41 80 f8 09          	cmp    $0x9,%r8b
  8041605603:	77 cf                	ja     80416055d4 <strtol+0x89>
      dig = *s - '0';
  8041605605:	0f be c9             	movsbl %cl,%ecx
  8041605608:	83 e9 30             	sub    $0x30,%ecx
  804160560b:	eb d9                	jmp    80416055e6 <strtol+0x9b>
    else if (*s >= 'A' && *s <= 'Z')
  804160560d:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  8041605611:	41 80 f8 19          	cmp    $0x19,%r8b
  8041605615:	77 0a                	ja     8041605621 <strtol+0xd6>
      dig = *s - 'A' + 10;
  8041605617:	44 0f be c1          	movsbl %cl,%r8d
  804160561b:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  804160561f:	eb c5                	jmp    80416055e6 <strtol+0x9b>
    // we don't properly detect overflow!
  }

  if (endptr)
  8041605621:	48 85 f6             	test   %rsi,%rsi
  8041605624:	74 03                	je     8041605629 <strtol+0xde>
    *endptr = (char *)s;
  8041605626:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  8041605629:	48 89 c2             	mov    %rax,%rdx
  804160562c:	48 f7 da             	neg    %rdx
  804160562f:	45 85 c9             	test   %r9d,%r9d
  8041605632:	48 0f 45 c2          	cmovne %rdx,%rax
}
  8041605636:	5d                   	pop    %rbp
  8041605637:	c3                   	retq   

0000008041605638 <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  8041605638:	55                   	push   %rbp
    movq %rsp, %rbp
  8041605639:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  804160563c:	53                   	push   %rbx
	push	%r12
  804160563d:	41 54                	push   %r12
	push	%r13
  804160563f:	41 55                	push   %r13
	push	%r14
  8041605641:	41 56                	push   %r14
	push	%r15
  8041605643:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  8041605645:	56                   	push   %rsi
	push	%rcx
  8041605646:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  8041605647:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  8041605648:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  804160564b:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

0000008041605652 <copyloop>:
  8041605652:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  8041605656:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  804160565a:	49 83 c0 08          	add    $0x8,%r8
  804160565e:	49 39 c8             	cmp    %rcx,%r8
  8041605661:	75 ef                	jne    8041605652 <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  8041605663:	e8 00 00 00 00       	callq  8041605668 <copyloop+0x16>
  8041605668:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  804160566f:	00 
  8041605670:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  8041605677:	00 
  8041605678:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  8041605679:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  804160567b:	6a 08                	pushq  $0x8
  804160567d:	e8 00 00 00 00       	callq  8041605682 <copyloop+0x30>
  8041605682:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  8041605689:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  804160568a:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  804160568e:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  8041605692:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  8041605696:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  8041605699:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  804160569a:	59                   	pop    %rcx
	pop	%rsi
  804160569b:	5e                   	pop    %rsi
	pop	%r15
  804160569c:	41 5f                	pop    %r15
	pop	%r14
  804160569e:	41 5e                	pop    %r14
	pop	%r13
  80416056a0:	41 5d                	pop    %r13
	pop	%r12
  80416056a2:	41 5c                	pop    %r12
	pop	%rbx
  80416056a4:	5b                   	pop    %rbx

	leave
  80416056a5:	c9                   	leaveq 
	ret
  80416056a6:	c3                   	retq   
  80416056a7:	90                   	nop
