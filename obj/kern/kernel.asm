
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

.globl entry
entry:
  # LAB 4 code
  # маскирование прерываний
  cli
  8041600000:	fa                   	cli    
  # LAB 4 code end

  # Save LoadParams in uefi_lp.
  movq %rcx, uefi_lp(%rip)
  8041600001:	48 89 0d f8 ff 01 00 	mov    %rcx,0x1fff8(%rip)        # 8041620000 <bootstacktop>

  # Set the stack pointer.
  leaq bootstacktop(%rip),%rsp
  8041600008:	48 8d 25 f1 ff 01 00 	lea    0x1fff1(%rip),%rsp        # 8041620000 <bootstacktop>

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
  8041600020:	48 bb 80 5a 88 41 80 	movabs $0x8041885a80,%rbx
  8041600027:	00 00 00 
  804160002a:	48 b8 c0 07 62 41 80 	movabs $0x80416207c0,%rax
  8041600031:	00 00 00 
  8041600034:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  8041600038:	0f 11 03             	movups %xmm0,(%rbx)
  804160003b:	f3 0f 6f 48 10       	movdqu 0x10(%rax),%xmm1
  8041600040:	0f 11 4b 10          	movups %xmm1,0x10(%rbx)
  8041600044:	48 8b 40 20          	mov    0x20(%rax),%rax
  8041600048:	48 89 43 20          	mov    %rax,0x20(%rbx)
  timertab[1] = timer_pit;
  804160004c:	48 b8 e0 08 62 41 80 	movabs $0x80416208e0,%rax
  8041600053:	00 00 00 
  8041600056:	f3 0f 6f 10          	movdqu (%rax),%xmm2
  804160005a:	0f 11 53 28          	movups %xmm2,0x28(%rbx)
  804160005e:	f3 0f 6f 58 10       	movdqu 0x10(%rax),%xmm3
  8041600063:	0f 11 5b 38          	movups %xmm3,0x38(%rbx)
  8041600067:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160006b:	48 89 43 48          	mov    %rax,0x48(%rbx)
  timertab[2] = timer_acpipm;
  804160006f:	48 b8 00 08 62 41 80 	movabs $0x8041620800,%rax
  8041600076:	00 00 00 
  8041600079:	f3 0f 6f 20          	movdqu (%rax),%xmm4
  804160007d:	0f 11 63 50          	movups %xmm4,0x50(%rbx)
  8041600081:	f3 0f 6f 68 10       	movdqu 0x10(%rax),%xmm5
  8041600086:	0f 11 6b 60          	movups %xmm5,0x60(%rbx)
  804160008a:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160008e:	48 89 43 70          	mov    %rax,0x70(%rbx)
  timertab[3] = timer_hpet0;
  8041600092:	48 b8 80 08 62 41 80 	movabs $0x8041620880,%rax
  8041600099:	00 00 00 
  804160009c:	f3 0f 6f 30          	movdqu (%rax),%xmm6
  80416000a0:	0f 11 73 78          	movups %xmm6,0x78(%rbx)
  80416000a4:	f3 0f 6f 78 10       	movdqu 0x10(%rax),%xmm7
  80416000a9:	0f 11 bb 88 00 00 00 	movups %xmm7,0x88(%rbx)
  80416000b0:	48 8b 40 20          	mov    0x20(%rax),%rax
  80416000b4:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
  timertab[4] = timer_hpet1;
  80416000bb:	48 b8 40 08 62 41 80 	movabs $0x8041620840,%rax
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
  804160010b:	48 b8 08 00 62 41 80 	movabs $0x8041620008,%rax
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
  8041600134:	48 a3 08 00 62 41 80 	movabs %rax,0x8041620008
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
  8041600222:	49 bc 00 00 62 41 80 	movabs $0x8041620000,%r12
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
  80416002a7:	48 b8 80 42 88 41 80 	movabs $0x8041884280,%rax
  80416002ae:	00 00 00 
  80416002b1:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416002b5:	74 13                	je     80416002ca <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416002b7:	48 bb ee 3e 60 41 80 	movabs $0x8041603eee,%rbx
  80416002be:	00 00 00 
  80416002c1:	bf 00 00 00 00       	mov    $0x0,%edi
  80416002c6:	ff d3                	callq  *%rbx
  while (1)
  80416002c8:	eb f7                	jmp    80416002c1 <_panic+0x67>
  panicstr = fmt;
  80416002ca:	4c 89 e0             	mov    %r12,%rax
  80416002cd:	48 a3 80 42 88 41 80 	movabs %rax,0x8041884280
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
  804160030b:	48 bf 80 cc 60 41 80 	movabs $0x804160cc80,%rdi
  8041600312:	00 00 00 
  8041600315:	b8 00 00 00 00       	mov    $0x0,%eax
  804160031a:	48 bb f2 91 60 41 80 	movabs $0x80416091f2,%rbx
  8041600321:	00 00 00 
  8041600324:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600326:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160032d:	4c 89 e7             	mov    %r12,%rdi
  8041600330:	48 b8 be 91 60 41 80 	movabs $0x80416091be,%rax
  8041600337:	00 00 00 
  804160033a:	ff d0                	callq  *%rax
  cprintf("\n");
  804160033c:	48 bf 1f e2 60 41 80 	movabs $0x804160e21f,%rdi
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
  8041600360:	49 bc 80 5a 88 41 80 	movabs $0x8041885a80,%r12
  8041600367:	00 00 00 
  804160036a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
  804160036f:	49 be e0 c3 60 41 80 	movabs $0x804160c3e0,%r14
  8041600376:	00 00 00 
  8041600379:	eb 3a                	jmp    80416003b5 <timers_schedule+0x63>
        panic("Timer %s does not support interrupts\n", name);
  804160037b:	4c 89 e9             	mov    %r13,%rcx
  804160037e:	48 ba 20 cd 60 41 80 	movabs $0x804160cd20,%rdx
  8041600385:	00 00 00 
  8041600388:	be 2d 00 00 00       	mov    $0x2d,%esi
  804160038d:	48 bf 98 cc 60 41 80 	movabs $0x804160cc98,%rdi
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
  80416003cf:	48 b8 80 5a 88 41 80 	movabs $0x8041885a80,%rax
  80416003d6:	00 00 00 
  80416003d9:	48 8b 74 d0 18       	mov    0x18(%rax,%rdx,8),%rsi
  80416003de:	48 85 f6             	test   %rsi,%rsi
  80416003e1:	74 98                	je     804160037b <timers_schedule+0x29>
        timer_for_schedule = &timertab[i];
  80416003e3:	48 89 d1             	mov    %rdx,%rcx
  80416003e6:	48 8d 14 c8          	lea    (%rax,%rcx,8),%rdx
  80416003ea:	48 89 d0             	mov    %rdx,%rax
  80416003ed:	48 a3 60 5a 88 41 80 	movabs %rax,0x8041885a60
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
  8041600405:	48 ba a4 cc 60 41 80 	movabs $0x804160cca4,%rdx
  804160040c:	00 00 00 
  804160040f:	be 33 00 00 00       	mov    $0x33,%esi
  8041600414:	48 bf 98 cc 60 41 80 	movabs $0x804160cc98,%rdi
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
  8041600443:	48 b8 53 0c 60 41 80 	movabs $0x8041600c53,%rax
  804160044a:	00 00 00 
  804160044d:	ff d0                	callq  *%rax
  tsc_calibrate();
  804160044f:	48 b8 52 c7 60 41 80 	movabs $0x804160c752,%rax
  8041600456:	00 00 00 
  8041600459:	ff d0                	callq  *%rax
  cprintf("6828 decimal is %o octal!\n", 6828);
  804160045b:	be ac 1a 00 00       	mov    $0x1aac,%esi
  8041600460:	48 bf bd cc 60 41 80 	movabs $0x804160ccbd,%rdi
  8041600467:	00 00 00 
  804160046a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160046f:	48 bb f2 91 60 41 80 	movabs $0x80416091f2,%rbx
  8041600476:	00 00 00 
  8041600479:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  804160047b:	48 be 00 60 88 41 80 	movabs $0x8041886000,%rsi
  8041600482:	00 00 00 
  8041600485:	48 bf d8 cc 60 41 80 	movabs $0x804160ccd8,%rdi
  804160048c:	00 00 00 
  804160048f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600494:	ff d3                	callq  *%rbx
  mem_init();
  8041600496:	48 b8 3c 52 60 41 80 	movabs $0x804160523c,%rax
  804160049d:	00 00 00 
  80416004a0:	ff d0                	callq  *%rax
  while (ctor < &__ctors_end) {
  80416004a2:	48 ba 78 42 88 41 80 	movabs $0x8041884278,%rdx
  80416004a9:	00 00 00 
  80416004ac:	48 b8 78 42 88 41 80 	movabs $0x8041884278,%rax
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
  timers_init();
  80416004de:	48 b8 19 00 60 41 80 	movabs $0x8041600019,%rax
  80416004e5:	00 00 00 
  80416004e8:	ff d0                	callq  *%rax
  fb_init();
  80416004ea:	48 b8 46 0b 60 41 80 	movabs $0x8041600b46,%rax
  80416004f1:	00 00 00 
  80416004f4:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  80416004f6:	48 bf e1 cc 60 41 80 	movabs $0x804160cce1,%rdi
  80416004fd:	00 00 00 
  8041600500:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600505:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160050c:	00 00 00 
  804160050f:	ff d2                	callq  *%rdx
  env_init();
  8041600511:	48 b8 29 86 60 41 80 	movabs $0x8041608629,%rax
  8041600518:	00 00 00 
  804160051b:	ff d0                	callq  *%rax
  trap_init();
  804160051d:	48 b8 f9 92 60 41 80 	movabs $0x80416092f9,%rax
  8041600524:	00 00 00 
  8041600527:	ff d0                	callq  *%rax
  timers_schedule("hpet0");
  8041600529:	48 bf fa cc 60 41 80 	movabs $0x804160ccfa,%rdi
  8041600530:	00 00 00 
  8041600533:	48 b8 52 03 60 41 80 	movabs $0x8041600352,%rax
  804160053a:	00 00 00 
  804160053d:	ff d0                	callq  *%rax
  clock_idt_init();
  804160053f:	48 b8 c2 96 60 41 80 	movabs $0x80416096c2,%rax
  8041600546:	00 00 00 
  8041600549:	ff d0                	callq  *%rax
  sched_yield();
  804160054b:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  8041600552:	00 00 00 
  8041600555:	ff d0                	callq  *%rax

0000008041600557 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  8041600557:	55                   	push   %rbp
  8041600558:	48 89 e5             	mov    %rsp,%rbp
  804160055b:	41 54                	push   %r12
  804160055d:	53                   	push   %rbx
  804160055e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600565:	49 89 d4             	mov    %rdx,%r12
  8041600568:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  804160056f:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8041600576:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  804160057d:	84 c0                	test   %al,%al
  804160057f:	74 23                	je     80416005a4 <_warn+0x4d>
  8041600581:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  8041600588:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  804160058c:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  8041600590:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  8041600594:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  8041600598:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  804160059c:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416005a0:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416005a4:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416005ab:	00 00 00 
  80416005ae:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416005b5:	00 00 00 
  80416005b8:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416005bc:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416005c3:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416005ca:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  80416005d1:	89 f2                	mov    %esi,%edx
  80416005d3:	48 89 fe             	mov    %rdi,%rsi
  80416005d6:	48 bf 00 cd 60 41 80 	movabs $0x804160cd00,%rdi
  80416005dd:	00 00 00 
  80416005e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416005e5:	48 bb f2 91 60 41 80 	movabs $0x80416091f2,%rbx
  80416005ec:	00 00 00 
  80416005ef:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  80416005f1:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  80416005f8:	4c 89 e7             	mov    %r12,%rdi
  80416005fb:	48 b8 be 91 60 41 80 	movabs $0x80416091be,%rax
  8041600602:	00 00 00 
  8041600605:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600607:	48 bf 1f e2 60 41 80 	movabs $0x804160e21f,%rdi
  804160060e:	00 00 00 
  8041600611:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600616:	ff d3                	callq  *%rbx
  va_end(ap);
}
  8041600618:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  804160061f:	5b                   	pop    %rbx
  8041600620:	41 5c                	pop    %r12
  8041600622:	5d                   	pop    %rbp
  8041600623:	c3                   	retq   

0000008041600624 <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  8041600624:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600629:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  804160062a:	a8 01                	test   $0x1,%al
  804160062c:	74 0a                	je     8041600638 <serial_proc_data+0x14>
  804160062e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600633:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  8041600634:	0f b6 c0             	movzbl %al,%eax
  8041600637:	c3                   	retq   
    return -1;
  8041600638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  804160063d:	c3                   	retq   

000000804160063e <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  804160063e:	55                   	push   %rbp
  804160063f:	48 89 e5             	mov    %rsp,%rbp
  8041600642:	41 54                	push   %r12
  8041600644:	53                   	push   %rbx
  8041600645:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  8041600648:	48 bb c0 42 88 41 80 	movabs $0x80418842c0,%rbx
  804160064f:	00 00 00 
  while ((c = (*proc)()) != -1) {
  8041600652:	41 ff d4             	callq  *%r12
  8041600655:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041600658:	74 28                	je     8041600682 <cons_intr+0x44>
    if (c == 0)
  804160065a:	85 c0                	test   %eax,%eax
  804160065c:	74 f4                	je     8041600652 <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  804160065e:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  8041600664:	8d 51 01             	lea    0x1(%rcx),%edx
  8041600667:	89 c9                	mov    %ecx,%ecx
  8041600669:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  804160066c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  8041600672:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600677:	0f 44 d0             	cmove  %eax,%edx
  804160067a:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  8041600680:	eb d0                	jmp    8041600652 <cons_intr+0x14>
  }
}
  8041600682:	5b                   	pop    %rbx
  8041600683:	41 5c                	pop    %r12
  8041600685:	5d                   	pop    %rbp
  8041600686:	c3                   	retq   

0000008041600687 <kbd_proc_data>:
kbd_proc_data(void) {
  8041600687:	55                   	push   %rbp
  8041600688:	48 89 e5             	mov    %rsp,%rbp
  804160068b:	53                   	push   %rbx
  804160068c:	48 83 ec 08          	sub    $0x8,%rsp
  8041600690:	ba 64 00 00 00       	mov    $0x64,%edx
  8041600695:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  8041600696:	a8 01                	test   $0x1,%al
  8041600698:	0f 84 31 01 00 00    	je     80416007cf <kbd_proc_data+0x148>
  804160069e:	ba 60 00 00 00       	mov    $0x60,%edx
  80416006a3:	ec                   	in     (%dx),%al
  80416006a4:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416006a6:	3c e0                	cmp    $0xe0,%al
  80416006a8:	0f 84 84 00 00 00    	je     8041600732 <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  80416006ae:	84 c0                	test   %al,%al
  80416006b0:	0f 88 97 00 00 00    	js     804160074d <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  80416006b6:	48 bf a0 42 88 41 80 	movabs $0x80418842a0,%rdi
  80416006bd:	00 00 00 
  80416006c0:	8b 0f                	mov    (%rdi),%ecx
  80416006c2:	f6 c1 40             	test   $0x40,%cl
  80416006c5:	74 0c                	je     80416006d3 <kbd_proc_data+0x4c>
    data |= 0x80;
  80416006c7:	83 c8 80             	or     $0xffffff80,%eax
  80416006ca:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416006cc:	89 c8                	mov    %ecx,%eax
  80416006ce:	83 e0 bf             	and    $0xffffffbf,%eax
  80416006d1:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  80416006d3:	0f b6 f2             	movzbl %dl,%esi
  80416006d6:	48 b8 a0 ce 60 41 80 	movabs $0x804160cea0,%rax
  80416006dd:	00 00 00 
  80416006e0:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  80416006e4:	48 b9 a0 42 88 41 80 	movabs $0x80418842a0,%rcx
  80416006eb:	00 00 00 
  80416006ee:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  80416006f0:	48 bf a0 cd 60 41 80 	movabs $0x804160cda0,%rdi
  80416006f7:	00 00 00 
  80416006fa:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  80416006fe:	31 f0                	xor    %esi,%eax
  8041600700:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  8041600702:	89 c6                	mov    %eax,%esi
  8041600704:	83 e6 03             	and    $0x3,%esi
  8041600707:	0f b6 d2             	movzbl %dl,%edx
  804160070a:	48 b9 80 cd 60 41 80 	movabs $0x804160cd80,%rcx
  8041600711:	00 00 00 
  8041600714:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  8041600718:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  804160071c:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  804160071f:	a8 08                	test   $0x8,%al
  8041600721:	74 73                	je     8041600796 <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  8041600723:	89 da                	mov    %ebx,%edx
  8041600725:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  8041600728:	83 f9 19             	cmp    $0x19,%ecx
  804160072b:	77 5d                	ja     804160078a <kbd_proc_data+0x103>
      c += 'A' - 'a';
  804160072d:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8041600730:	eb 12                	jmp    8041600744 <kbd_proc_data+0xbd>
    shift |= E0ESC;
  8041600732:	48 b8 a0 42 88 41 80 	movabs $0x80418842a0,%rax
  8041600739:	00 00 00 
  804160073c:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  804160073f:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8041600744:	89 d8                	mov    %ebx,%eax
  8041600746:	48 83 c4 08          	add    $0x8,%rsp
  804160074a:	5b                   	pop    %rbx
  804160074b:	5d                   	pop    %rbp
  804160074c:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  804160074d:	48 bf a0 42 88 41 80 	movabs $0x80418842a0,%rdi
  8041600754:	00 00 00 
  8041600757:	8b 0f                	mov    (%rdi),%ecx
  8041600759:	89 ce                	mov    %ecx,%esi
  804160075b:	83 e6 40             	and    $0x40,%esi
  804160075e:	83 e0 7f             	and    $0x7f,%eax
  8041600761:	85 f6                	test   %esi,%esi
  8041600763:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  8041600766:	0f b6 d2             	movzbl %dl,%edx
  8041600769:	48 b8 a0 ce 60 41 80 	movabs $0x804160cea0,%rax
  8041600770:	00 00 00 
  8041600773:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  8041600777:	83 c8 40             	or     $0x40,%eax
  804160077a:	0f b6 c0             	movzbl %al,%eax
  804160077d:	f7 d0                	not    %eax
  804160077f:	21 c8                	and    %ecx,%eax
  8041600781:	89 07                	mov    %eax,(%rdi)
    return 0;
  8041600783:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041600788:	eb ba                	jmp    8041600744 <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  804160078a:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  804160078d:	8d 4b 20             	lea    0x20(%rbx),%ecx
  8041600790:	83 fa 1a             	cmp    $0x1a,%edx
  8041600793:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8041600796:	f7 d0                	not    %eax
  8041600798:	a8 06                	test   $0x6,%al
  804160079a:	75 a8                	jne    8041600744 <kbd_proc_data+0xbd>
  804160079c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  80416007a2:	75 a0                	jne    8041600744 <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  80416007a4:	48 bf 46 cd 60 41 80 	movabs $0x804160cd46,%rdi
  80416007ab:	00 00 00 
  80416007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416007b3:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416007ba:	00 00 00 
  80416007bd:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416007bf:	b8 03 00 00 00       	mov    $0x3,%eax
  80416007c4:	ba 92 00 00 00       	mov    $0x92,%edx
  80416007c9:	ee                   	out    %al,(%dx)
  80416007ca:	e9 75 ff ff ff       	jmpq   8041600744 <kbd_proc_data+0xbd>
    return -1;
  80416007cf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80416007d4:	e9 6b ff ff ff       	jmpq   8041600744 <kbd_proc_data+0xbd>

00000080416007d9 <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  80416007d9:	48 b8 d4 44 88 41 80 	movabs $0x80418844d4,%rax
  80416007e0:	00 00 00 
  80416007e3:	44 8b 10             	mov    (%rax),%r10d
  80416007e6:	41 0f af d2          	imul   %r10d,%edx
  80416007ea:	01 f2                	add    %esi,%edx
  80416007ec:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  80416007f3:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  80416007f4:	4d 0f be c0          	movsbq %r8b,%r8
  80416007f8:	48 b8 20 03 62 41 80 	movabs $0x8041620320,%rax
  80416007ff:	00 00 00 
  8041600802:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  8041600806:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  804160080a:	eb 25                	jmp    8041600831 <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  804160080c:	83 c0 01             	add    $0x1,%eax
  804160080f:	83 f8 08             	cmp    $0x8,%eax
  8041600812:	74 11                	je     8041600825 <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  8041600814:	0f be 16             	movsbl (%rsi),%edx
  8041600817:	0f a3 c2             	bt     %eax,%edx
  804160081a:	73 f0                	jae    804160080c <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160081c:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  8041600820:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  8041600823:	eb e7                	jmp    804160080c <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  8041600825:	45 01 d1             	add    %r10d,%r9d
  8041600828:	48 83 c6 01          	add    $0x1,%rsi
  804160082c:	4c 39 c6             	cmp    %r8,%rsi
  804160082f:	74 07                	je     8041600838 <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  8041600831:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600836:	eb dc                	jmp    8041600814 <draw_char+0x3b>
}
  8041600838:	c3                   	retq   

0000008041600839 <cons_putc>:
  __asm __volatile("inb %w1,%0"
  8041600839:	ba fd 03 00 00       	mov    $0x3fd,%edx
  804160083e:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  804160083f:	a8 20                	test   $0x20,%al
  8041600841:	75 29                	jne    804160086c <cons_putc+0x33>
  for (i = 0;
  8041600843:	be 00 00 00 00       	mov    $0x0,%esi
  8041600848:	b9 84 00 00 00       	mov    $0x84,%ecx
  804160084d:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  8041600853:	89 ca                	mov    %ecx,%edx
  8041600855:	ec                   	in     (%dx),%al
  8041600856:	ec                   	in     (%dx),%al
  8041600857:	ec                   	in     (%dx),%al
  8041600858:	ec                   	in     (%dx),%al
       i++)
  8041600859:	83 c6 01             	add    $0x1,%esi
  804160085c:	44 89 c2             	mov    %r8d,%edx
  804160085f:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600860:	a8 20                	test   $0x20,%al
  8041600862:	75 08                	jne    804160086c <cons_putc+0x33>
  8041600864:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  804160086a:	7e e7                	jle    8041600853 <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  804160086c:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  804160086f:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600874:	89 f8                	mov    %edi,%eax
  8041600876:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600877:	ba 79 03 00 00       	mov    $0x379,%edx
  804160087c:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  804160087d:	84 c0                	test   %al,%al
  804160087f:	78 29                	js     80416008aa <cons_putc+0x71>
  8041600881:	be 00 00 00 00       	mov    $0x0,%esi
  8041600886:	b9 84 00 00 00       	mov    $0x84,%ecx
  804160088b:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  8041600891:	89 ca                	mov    %ecx,%edx
  8041600893:	ec                   	in     (%dx),%al
  8041600894:	ec                   	in     (%dx),%al
  8041600895:	ec                   	in     (%dx),%al
  8041600896:	ec                   	in     (%dx),%al
  8041600897:	83 c6 01             	add    $0x1,%esi
  804160089a:	44 89 ca             	mov    %r9d,%edx
  804160089d:	ec                   	in     (%dx),%al
  804160089e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416008a4:	7f 04                	jg     80416008aa <cons_putc+0x71>
  80416008a6:	84 c0                	test   %al,%al
  80416008a8:	79 e7                	jns    8041600891 <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416008aa:	ba 78 03 00 00       	mov    $0x378,%edx
  80416008af:	44 89 c0             	mov    %r8d,%eax
  80416008b2:	ee                   	out    %al,(%dx)
  80416008b3:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416008b8:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416008bd:	ee                   	out    %al,(%dx)
  80416008be:	b8 08 00 00 00       	mov    $0x8,%eax
  80416008c3:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416008c4:	48 b8 dc 44 88 41 80 	movabs $0x80418844dc,%rax
  80416008cb:	00 00 00 
  80416008ce:	80 38 00             	cmpb   $0x0,(%rax)
  80416008d1:	0f 84 42 02 00 00    	je     8041600b19 <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  80416008d7:	55                   	push   %rbp
  80416008d8:	48 89 e5             	mov    %rsp,%rbp
  80416008db:	41 54                	push   %r12
  80416008dd:	53                   	push   %rbx
  if (!(c & ~0xFF))
  80416008de:	89 fa                	mov    %edi,%edx
  80416008e0:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  80416008e6:	89 f8                	mov    %edi,%eax
  80416008e8:	80 cc 07             	or     $0x7,%ah
  80416008eb:	85 d2                	test   %edx,%edx
  80416008ed:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  80416008f0:	40 0f b6 c7          	movzbl %dil,%eax
  80416008f4:	83 f8 09             	cmp    $0x9,%eax
  80416008f7:	0f 84 e1 00 00 00    	je     80416009de <cons_putc+0x1a5>
  80416008fd:	7e 5c                	jle    804160095b <cons_putc+0x122>
  80416008ff:	83 f8 0a             	cmp    $0xa,%eax
  8041600902:	0f 84 b8 00 00 00    	je     80416009c0 <cons_putc+0x187>
  8041600908:	83 f8 0d             	cmp    $0xd,%eax
  804160090b:	0f 85 ff 00 00 00    	jne    8041600a10 <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  8041600911:	48 be c8 44 88 41 80 	movabs $0x80418844c8,%rsi
  8041600918:	00 00 00 
  804160091b:	0f b7 0e             	movzwl (%rsi),%ecx
  804160091e:	0f b7 c1             	movzwl %cx,%eax
  8041600921:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  8041600928:	00 00 00 
  804160092b:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600930:	f7 33                	divl   (%rbx)
  8041600932:	29 d1                	sub    %edx,%ecx
  8041600934:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  8041600937:	48 b8 c8 44 88 41 80 	movabs $0x80418844c8,%rax
  804160093e:	00 00 00 
  8041600941:	0f b7 10             	movzwl (%rax),%edx
  8041600944:	48 b8 cc 44 88 41 80 	movabs $0x80418844cc,%rax
  804160094b:	00 00 00 
  804160094e:	3b 10                	cmp    (%rax),%edx
  8041600950:	0f 83 0f 01 00 00    	jae    8041600a65 <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  8041600956:	5b                   	pop    %rbx
  8041600957:	41 5c                	pop    %r12
  8041600959:	5d                   	pop    %rbp
  804160095a:	c3                   	retq   
  switch (c & 0xff) {
  804160095b:	83 f8 08             	cmp    $0x8,%eax
  804160095e:	0f 85 ac 00 00 00    	jne    8041600a10 <cons_putc+0x1d7>
      if (crt_pos > 0) {
  8041600964:	66 a1 c8 44 88 41 80 	movabs 0x80418844c8,%ax
  804160096b:	00 00 00 
  804160096e:	66 85 c0             	test   %ax,%ax
  8041600971:	74 c4                	je     8041600937 <cons_putc+0xfe>
        crt_pos--;
  8041600973:	83 e8 01             	sub    $0x1,%eax
  8041600976:	66 a3 c8 44 88 41 80 	movabs %ax,0x80418844c8
  804160097d:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  8041600980:	0f b7 c0             	movzwl %ax,%eax
  8041600983:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  804160098a:	00 00 00 
  804160098d:	8b 1b                	mov    (%rbx),%ebx
  804160098f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600994:	f7 f3                	div    %ebx
  8041600996:	89 d6                	mov    %edx,%esi
  8041600998:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160099e:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416009a3:	89 c2                	mov    %eax,%edx
  80416009a5:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  80416009ac:	00 00 00 
  80416009af:	48 b8 d9 07 60 41 80 	movabs $0x80416007d9,%rax
  80416009b6:	00 00 00 
  80416009b9:	ff d0                	callq  *%rax
  80416009bb:	e9 77 ff ff ff       	jmpq   8041600937 <cons_putc+0xfe>
      crt_pos += crt_cols;
  80416009c0:	48 b8 c8 44 88 41 80 	movabs $0x80418844c8,%rax
  80416009c7:	00 00 00 
  80416009ca:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  80416009d1:	00 00 00 
  80416009d4:	8b 13                	mov    (%rbx),%edx
  80416009d6:	66 01 10             	add    %dx,(%rax)
  80416009d9:	e9 33 ff ff ff       	jmpq   8041600911 <cons_putc+0xd8>
      cons_putc(' ');
  80416009de:	bf 20 00 00 00       	mov    $0x20,%edi
  80416009e3:	48 bb 39 08 60 41 80 	movabs $0x8041600839,%rbx
  80416009ea:	00 00 00 
  80416009ed:	ff d3                	callq  *%rbx
      cons_putc(' ');
  80416009ef:	bf 20 00 00 00       	mov    $0x20,%edi
  80416009f4:	ff d3                	callq  *%rbx
      cons_putc(' ');
  80416009f6:	bf 20 00 00 00       	mov    $0x20,%edi
  80416009fb:	ff d3                	callq  *%rbx
      cons_putc(' ');
  80416009fd:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a02:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a04:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a09:	ff d3                	callq  *%rbx
      break;
  8041600a0b:	e9 27 ff ff ff       	jmpq   8041600937 <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600a10:	49 bc c8 44 88 41 80 	movabs $0x80418844c8,%r12
  8041600a17:	00 00 00 
  8041600a1a:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600a1f:	0f b7 c3             	movzwl %bx,%eax
  8041600a22:	48 be d0 44 88 41 80 	movabs $0x80418844d0,%rsi
  8041600a29:	00 00 00 
  8041600a2c:	8b 36                	mov    (%rsi),%esi
  8041600a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600a33:	f7 f6                	div    %esi
  8041600a35:	89 d6                	mov    %edx,%esi
  8041600a37:	44 0f be c7          	movsbl %dil,%r8d
  8041600a3b:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600a40:	89 c2                	mov    %eax,%edx
  8041600a42:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600a49:	00 00 00 
  8041600a4c:	48 b8 d9 07 60 41 80 	movabs $0x80416007d9,%rax
  8041600a53:	00 00 00 
  8041600a56:	ff d0                	callq  *%rax
      crt_pos++;
  8041600a58:	83 c3 01             	add    $0x1,%ebx
  8041600a5b:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  8041600a60:	e9 d2 fe ff ff       	jmpq   8041600937 <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600a65:	48 bb d4 44 88 41 80 	movabs $0x80418844d4,%rbx
  8041600a6c:	00 00 00 
  8041600a6f:	8b 03                	mov    (%rbx),%eax
  8041600a71:	49 bc d8 44 88 41 80 	movabs $0x80418844d8,%r12
  8041600a78:	00 00 00 
  8041600a7b:	41 8b 3c 24          	mov    (%r12),%edi
  8041600a7f:	8d 57 f8             	lea    -0x8(%rdi),%edx
  8041600a82:	0f af d0             	imul   %eax,%edx
  8041600a85:	48 c1 e2 02          	shl    $0x2,%rdx
  8041600a89:	c1 e0 03             	shl    $0x3,%eax
  8041600a8c:	89 c0                	mov    %eax,%eax
  8041600a8e:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600a95:	00 00 00 
  8041600a98:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  8041600a9c:	48 b8 dc c4 60 41 80 	movabs $0x804160c4dc,%rax
  8041600aa3:	00 00 00 
  8041600aa6:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600aa8:	41 8b 04 24          	mov    (%r12),%eax
  8041600aac:	8b 0b                	mov    (%rbx),%ecx
  8041600aae:	89 c6                	mov    %eax,%esi
  8041600ab0:	83 e6 f8             	and    $0xfffffff8,%esi
  8041600ab3:	83 ee 08             	sub    $0x8,%esi
  8041600ab6:	0f af f1             	imul   %ecx,%esi
  8041600ab9:	0f af c8             	imul   %eax,%ecx
  8041600abc:	39 f1                	cmp    %esi,%ecx
  8041600abe:	76 3b                	jbe    8041600afb <cons_putc+0x2c2>
  8041600ac0:	48 63 fe             	movslq %esi,%rdi
  8041600ac3:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  8041600aca:	00 00 00 
  8041600acd:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  8041600ad1:	8d 51 ff             	lea    -0x1(%rcx),%edx
  8041600ad4:	89 d1                	mov    %edx,%ecx
  8041600ad6:	29 f1                	sub    %esi,%ecx
  8041600ad8:	48 ba 01 b8 b0 0f 20 	movabs $0x200fb0b801,%rdx
  8041600adf:	00 00 00 
  8041600ae2:	48 01 fa             	add    %rdi,%rdx
  8041600ae5:	48 01 ca             	add    %rcx,%rdx
  8041600ae8:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600aec:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600af2:	48 83 c0 04          	add    $0x4,%rax
  8041600af6:	48 39 c2             	cmp    %rax,%rdx
  8041600af9:	75 f1                	jne    8041600aec <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600afb:	48 b8 c8 44 88 41 80 	movabs $0x80418844c8,%rax
  8041600b02:	00 00 00 
  8041600b05:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  8041600b0c:	00 00 00 
  8041600b0f:	8b 13                	mov    (%rbx),%edx
  8041600b11:	66 29 10             	sub    %dx,(%rax)
}
  8041600b14:	e9 3d fe ff ff       	jmpq   8041600956 <cons_putc+0x11d>
  8041600b19:	c3                   	retq   

0000008041600b1a <serial_intr>:
  if (serial_exists)
  8041600b1a:	48 b8 ca 44 88 41 80 	movabs $0x80418844ca,%rax
  8041600b21:	00 00 00 
  8041600b24:	80 38 00             	cmpb   $0x0,(%rax)
  8041600b27:	75 01                	jne    8041600b2a <serial_intr+0x10>
  8041600b29:	c3                   	retq   
serial_intr(void) {
  8041600b2a:	55                   	push   %rbp
  8041600b2b:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600b2e:	48 bf 24 06 60 41 80 	movabs $0x8041600624,%rdi
  8041600b35:	00 00 00 
  8041600b38:	48 b8 3e 06 60 41 80 	movabs $0x804160063e,%rax
  8041600b3f:	00 00 00 
  8041600b42:	ff d0                	callq  *%rax
}
  8041600b44:	5d                   	pop    %rbp
  8041600b45:	c3                   	retq   

0000008041600b46 <fb_init>:
fb_init(void) {
  8041600b46:	55                   	push   %rbp
  8041600b47:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600b4a:	48 b8 00 00 62 41 80 	movabs $0x8041620000,%rax
  8041600b51:	00 00 00 
  8041600b54:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600b57:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600b5a:	89 d0                	mov    %edx,%eax
  8041600b5c:	a3 d8 44 88 41 80 00 	movabs %eax,0x80418844d8
  8041600b63:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600b65:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600b68:	a3 d4 44 88 41 80 00 	movabs %eax,0x80418844d4
  8041600b6f:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600b71:	c1 e8 03             	shr    $0x3,%eax
  8041600b74:	89 c6                	mov    %eax,%esi
  8041600b76:	a3 d0 44 88 41 80 00 	movabs %eax,0x80418844d0
  8041600b7d:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600b7f:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600b82:	0f af d0             	imul   %eax,%edx
  8041600b85:	89 d0                	mov    %edx,%eax
  8041600b87:	a3 cc 44 88 41 80 00 	movabs %eax,0x80418844cc
  8041600b8e:	00 00 
  crt_pos           = crt_cols;
  8041600b90:	89 f0                	mov    %esi,%eax
  8041600b92:	66 a3 c8 44 88 41 80 	movabs %ax,0x80418844c8
  8041600b99:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600b9c:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600b9f:	be 00 00 00 00       	mov    $0x0,%esi
  8041600ba4:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600bab:	00 00 00 
  8041600bae:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  8041600bb5:	00 00 00 
  8041600bb8:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600bba:	48 b8 dc 44 88 41 80 	movabs $0x80418844dc,%rax
  8041600bc1:	00 00 00 
  8041600bc4:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600bc7:	5d                   	pop    %rbp
  8041600bc8:	c3                   	retq   

0000008041600bc9 <kbd_intr>:
kbd_intr(void) {
  8041600bc9:	55                   	push   %rbp
  8041600bca:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600bcd:	48 bf 87 06 60 41 80 	movabs $0x8041600687,%rdi
  8041600bd4:	00 00 00 
  8041600bd7:	48 b8 3e 06 60 41 80 	movabs $0x804160063e,%rax
  8041600bde:	00 00 00 
  8041600be1:	ff d0                	callq  *%rax
}
  8041600be3:	5d                   	pop    %rbp
  8041600be4:	c3                   	retq   

0000008041600be5 <cons_getc>:
cons_getc(void) {
  8041600be5:	55                   	push   %rbp
  8041600be6:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600be9:	48 b8 1a 0b 60 41 80 	movabs $0x8041600b1a,%rax
  8041600bf0:	00 00 00 
  8041600bf3:	ff d0                	callq  *%rax
  kbd_intr();
  8041600bf5:	48 b8 c9 0b 60 41 80 	movabs $0x8041600bc9,%rax
  8041600bfc:	00 00 00 
  8041600bff:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600c01:	48 b9 c0 42 88 41 80 	movabs $0x80418842c0,%rcx
  8041600c08:	00 00 00 
  8041600c0b:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600c11:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600c16:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600c1c:	74 21                	je     8041600c3f <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600c1e:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600c21:	48 b8 c0 42 88 41 80 	movabs $0x80418842c0,%rax
  8041600c28:	00 00 00 
  8041600c2b:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600c31:	89 d2                	mov    %edx,%edx
  8041600c33:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600c37:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600c3d:	74 02                	je     8041600c41 <cons_getc+0x5c>
}
  8041600c3f:	5d                   	pop    %rbp
  8041600c40:	c3                   	retq   
      cons.rpos = 0;
  8041600c41:	48 be c0 44 88 41 80 	movabs $0x80418844c0,%rsi
  8041600c48:	00 00 00 
  8041600c4b:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600c51:	eb ec                	jmp    8041600c3f <cons_getc+0x5a>

0000008041600c53 <cons_init>:
  8041600c53:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600c58:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600c5d:	89 c8                	mov    %ecx,%eax
  8041600c5f:	89 fa                	mov    %edi,%edx
  8041600c61:	ee                   	out    %al,(%dx)
  8041600c62:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600c68:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600c6d:	44 89 ca             	mov    %r9d,%edx
  8041600c70:	ee                   	out    %al,(%dx)
  8041600c71:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600c76:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600c7b:	89 f2                	mov    %esi,%edx
  8041600c7d:	ee                   	out    %al,(%dx)
  8041600c7e:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600c84:	89 c8                	mov    %ecx,%eax
  8041600c86:	44 89 c2             	mov    %r8d,%edx
  8041600c89:	ee                   	out    %al,(%dx)
  8041600c8a:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600c8f:	44 89 ca             	mov    %r9d,%edx
  8041600c92:	ee                   	out    %al,(%dx)
  8041600c93:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600c98:	89 c8                	mov    %ecx,%eax
  8041600c9a:	ee                   	out    %al,(%dx)
  8041600c9b:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600ca0:	44 89 c2             	mov    %r8d,%edx
  8041600ca3:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600ca4:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600ca9:	ec                   	in     (%dx),%al
  8041600caa:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600cac:	3c ff                	cmp    $0xff,%al
  8041600cae:	0f 95 c0             	setne  %al
  8041600cb1:	a2 ca 44 88 41 80 00 	movabs %al,0x80418844ca
  8041600cb8:	00 00 
  8041600cba:	89 fa                	mov    %edi,%edx
  8041600cbc:	ec                   	in     (%dx),%al
  8041600cbd:	89 f2                	mov    %esi,%edx
  8041600cbf:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600cc0:	80 f9 ff             	cmp    $0xff,%cl
  8041600cc3:	74 01                	je     8041600cc6 <cons_init+0x73>
  8041600cc5:	c3                   	retq   
cons_init(void) {
  8041600cc6:	55                   	push   %rbp
  8041600cc7:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600cca:	48 bf 52 cd 60 41 80 	movabs $0x804160cd52,%rdi
  8041600cd1:	00 00 00 
  8041600cd4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600cd9:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041600ce0:	00 00 00 
  8041600ce3:	ff d2                	callq  *%rdx
}
  8041600ce5:	5d                   	pop    %rbp
  8041600ce6:	c3                   	retq   

0000008041600ce7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600ce7:	55                   	push   %rbp
  8041600ce8:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600ceb:	48 b8 39 08 60 41 80 	movabs $0x8041600839,%rax
  8041600cf2:	00 00 00 
  8041600cf5:	ff d0                	callq  *%rax
}
  8041600cf7:	5d                   	pop    %rbp
  8041600cf8:	c3                   	retq   

0000008041600cf9 <getchar>:

int
getchar(void) {
  8041600cf9:	55                   	push   %rbp
  8041600cfa:	48 89 e5             	mov    %rsp,%rbp
  8041600cfd:	53                   	push   %rbx
  8041600cfe:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600d02:	48 bb e5 0b 60 41 80 	movabs $0x8041600be5,%rbx
  8041600d09:	00 00 00 
  8041600d0c:	ff d3                	callq  *%rbx
  8041600d0e:	85 c0                	test   %eax,%eax
  8041600d10:	74 fa                	je     8041600d0c <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600d12:	48 83 c4 08          	add    $0x8,%rsp
  8041600d16:	5b                   	pop    %rbx
  8041600d17:	5d                   	pop    %rbp
  8041600d18:	c3                   	retq   

0000008041600d19 <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600d19:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600d1e:	c3                   	retq   

0000008041600d1f <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600d1f:	55                   	push   %rbp
  8041600d20:	48 89 e5             	mov    %rsp,%rbp
  8041600d23:	41 56                	push   %r14
  8041600d25:	41 55                	push   %r13
  8041600d27:	41 54                	push   %r12
  8041600d29:	53                   	push   %rbx
  8041600d2a:	48 83 ec 20          	sub    $0x20,%rsp
  8041600d2e:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600d32:	83 fe 20             	cmp    $0x20,%esi
  8041600d35:	0f 87 42 09 00 00    	ja     804160167d <dwarf_read_abbrev_entry+0x95e>
  8041600d3b:	44 89 c3             	mov    %r8d,%ebx
  8041600d3e:	41 89 cd             	mov    %ecx,%r13d
  8041600d41:	49 89 d4             	mov    %rdx,%r12
  8041600d44:	89 f6                	mov    %esi,%esi
  8041600d46:	48 b8 58 d0 60 41 80 	movabs $0x804160d058,%rax
  8041600d4d:	00 00 00 
  8041600d50:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600d53:	48 85 d2             	test   %rdx,%rdx
  8041600d56:	74 6f                	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  8041600d58:	83 f9 07             	cmp    $0x7,%ecx
  8041600d5b:	76 6a                	jbe    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600d5d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600d62:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d66:	4c 89 e7             	mov    %r12,%rdi
  8041600d69:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600d70:	00 00 00 
  8041600d73:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600d75:	eb 50                	jmp    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB2 code
        
      unsigned length = get_unaligned(entry, uint16_t);
  8041600d77:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d7c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d80:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d84:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600d8b:	00 00 00 
  8041600d8e:	ff d0                	callq  *%rax
  8041600d90:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(uint16_t);
  8041600d94:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600d98:	48 83 c0 02          	add    $0x2,%rax
  8041600d9c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600da0:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600da4:	89 5d d8             	mov    %ebx,-0x28(%rbp)
        .mem = entry,
        .len = length,
      };
      if (buf) {
  8041600da7:	4d 85 e4             	test   %r12,%r12
  8041600daa:	74 18                	je     8041600dc4 <dwarf_read_abbrev_entry+0xa5>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600dac:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600db1:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600db5:	4c 89 e7             	mov    %r12,%rdi
  8041600db8:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600dbf:	00 00 00 
  8041600dc2:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(uint16_t) + length;
  8041600dc4:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600dc7:	89 d8                	mov    %ebx,%eax
  8041600dc9:	48 83 c4 20          	add    $0x20,%rsp
  8041600dcd:	5b                   	pop    %rbx
  8041600dce:	41 5c                	pop    %r12
  8041600dd0:	41 5d                	pop    %r13
  8041600dd2:	41 5e                	pop    %r14
  8041600dd4:	5d                   	pop    %rbp
  8041600dd5:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600dd6:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ddb:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ddf:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600de3:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600dea:	00 00 00 
  8041600ded:	ff d0                	callq  *%rax
  8041600def:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600df2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600df6:	48 83 c0 04          	add    $0x4,%rax
  8041600dfa:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600dfe:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600e02:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600e05:	4d 85 e4             	test   %r12,%r12
  8041600e08:	74 18                	je     8041600e22 <dwarf_read_abbrev_entry+0x103>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600e0a:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600e0f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e13:	4c 89 e7             	mov    %r12,%rdi
  8041600e16:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600e1d:	00 00 00 
  8041600e20:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600e22:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600e25:	eb a0                	jmp    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600e27:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e2c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e30:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e34:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600e3b:	00 00 00 
  8041600e3e:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600e40:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600e45:	4d 85 e4             	test   %r12,%r12
  8041600e48:	74 06                	je     8041600e50 <dwarf_read_abbrev_entry+0x131>
  8041600e4a:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600e4e:	77 0a                	ja     8041600e5a <dwarf_read_abbrev_entry+0x13b>
      bytes = sizeof(Dwarf_Half);
  8041600e50:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600e55:	e9 6d ff ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e5a:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e5f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e63:	4c 89 e7             	mov    %r12,%rdi
  8041600e66:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600e6d:	00 00 00 
  8041600e70:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600e72:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e77:	e9 4b ff ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600e7c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600e81:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e85:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e89:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600e90:	00 00 00 
  8041600e93:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600e95:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600e9a:	4d 85 e4             	test   %r12,%r12
  8041600e9d:	74 06                	je     8041600ea5 <dwarf_read_abbrev_entry+0x186>
  8041600e9f:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600ea3:	77 0a                	ja     8041600eaf <dwarf_read_abbrev_entry+0x190>
      bytes = sizeof(uint32_t);
  8041600ea5:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600eaa:	e9 18 ff ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  8041600eaf:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600eb4:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600eb8:	4c 89 e7             	mov    %r12,%rdi
  8041600ebb:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600ec2:	00 00 00 
  8041600ec5:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600ec7:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600ecc:	e9 f6 fe ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600ed1:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600ed6:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600eda:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ede:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600ee5:	00 00 00 
  8041600ee8:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600eea:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600eef:	4d 85 e4             	test   %r12,%r12
  8041600ef2:	74 06                	je     8041600efa <dwarf_read_abbrev_entry+0x1db>
  8041600ef4:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600ef8:	77 0a                	ja     8041600f04 <dwarf_read_abbrev_entry+0x1e5>
      bytes = sizeof(uint64_t);
  8041600efa:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600eff:	e9 c3 fe ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041600f04:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f09:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f0d:	4c 89 e7             	mov    %r12,%rdi
  8041600f10:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600f17:	00 00 00 
  8041600f1a:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600f1c:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600f21:	e9 a1 fe ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      if (buf && bufsize >= sizeof(char *)) {
  8041600f26:	48 85 d2             	test   %rdx,%rdx
  8041600f29:	74 05                	je     8041600f30 <dwarf_read_abbrev_entry+0x211>
  8041600f2b:	83 f9 07             	cmp    $0x7,%ecx
  8041600f2e:	77 18                	ja     8041600f48 <dwarf_read_abbrev_entry+0x229>
      bytes = strlen(entry) + 1;
  8041600f30:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600f34:	48 b8 d1 c2 60 41 80 	movabs $0x804160c2d1,%rax
  8041600f3b:	00 00 00 
  8041600f3e:	ff d0                	callq  *%rax
  8041600f40:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600f43:	e9 7f fe ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &entry, sizeof(char *));
  8041600f48:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f4d:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600f51:	4c 89 e7             	mov    %r12,%rdi
  8041600f54:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600f5b:	00 00 00 
  8041600f5e:	ff d0                	callq  *%rax
  8041600f60:	eb ce                	jmp    8041600f30 <dwarf_read_abbrev_entry+0x211>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600f62:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600f66:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600f69:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600f6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600f73:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600f78:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600f7b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600f7f:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600f82:	89 f0                	mov    %esi,%eax
  8041600f84:	83 e0 7f             	and    $0x7f,%eax
  8041600f87:	d3 e0                	shl    %cl,%eax
  8041600f89:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600f8b:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600f8e:	40 84 f6             	test   %sil,%sil
  8041600f91:	78 e5                	js     8041600f78 <dwarf_read_abbrev_entry+0x259>
      break;
  }

  *ret = result;

  return count;
  8041600f93:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600f96:	4d 01 e8             	add    %r13,%r8
  8041600f99:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600f9d:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600fa1:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600fa4:	4d 85 e4             	test   %r12,%r12
  8041600fa7:	74 18                	je     8041600fc1 <dwarf_read_abbrev_entry+0x2a2>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600fa9:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600fae:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600fb2:	4c 89 e7             	mov    %r12,%rdi
  8041600fb5:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600fbc:	00 00 00 
  8041600fbf:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600fc1:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600fc4:	e9 fe fd ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600fc9:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600fce:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600fd2:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600fd6:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041600fdd:	00 00 00 
  8041600fe0:	ff d0                	callq  *%rax
  8041600fe2:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041600fe6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600fea:	48 83 c0 01          	add    $0x1,%rax
  8041600fee:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600ff2:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600ff6:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600ff9:	4d 85 e4             	test   %r12,%r12
  8041600ffc:	74 18                	je     8041601016 <dwarf_read_abbrev_entry+0x2f7>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600ffe:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601003:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601007:	4c 89 e7             	mov    %r12,%rdi
  804160100a:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601011:	00 00 00 
  8041601014:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041601016:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041601019:	e9 a9 fd ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  804160101e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601023:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601027:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160102b:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601032:	00 00 00 
  8041601035:	ff d0                	callq  *%rax
  8041601037:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160103b:	4d 85 e4             	test   %r12,%r12
  804160103e:	0f 84 43 06 00 00    	je     8041601687 <dwarf_read_abbrev_entry+0x968>
  8041601044:	45 85 ed             	test   %r13d,%r13d
  8041601047:	0f 84 3a 06 00 00    	je     8041601687 <dwarf_read_abbrev_entry+0x968>
        put_unaligned(data, (Dwarf_Small *)buf);
  804160104d:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601051:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601056:	e9 6c fd ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      bool data = get_unaligned(entry, Dwarf_Small);
  804160105b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601060:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601064:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601068:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160106f:	00 00 00 
  8041601072:	ff d0                	callq  *%rax
  8041601074:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  8041601078:	4d 85 e4             	test   %r12,%r12
  804160107b:	0f 84 10 06 00 00    	je     8041601691 <dwarf_read_abbrev_entry+0x972>
  8041601081:	45 85 ed             	test   %r13d,%r13d
  8041601084:	0f 84 07 06 00 00    	je     8041601691 <dwarf_read_abbrev_entry+0x972>
      bool data = get_unaligned(entry, Dwarf_Small);
  804160108a:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  804160108c:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  8041601091:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  8041601096:	e9 2c fd ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      int count = dwarf_read_leb128(entry, &data);
  804160109b:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  804160109f:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  80416010a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416010a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416010ac:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  80416010b1:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416010b4:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  80416010b8:	89 f0                	mov    %esi,%eax
  80416010ba:	83 e0 7f             	and    $0x7f,%eax
  80416010bd:	d3 e0                	shl    %cl,%eax
  80416010bf:	09 c7                	or     %eax,%edi
    shift += 7;
  80416010c1:	83 c1 07             	add    $0x7,%ecx
    count++;
  80416010c4:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  80416010c7:	40 84 f6             	test   %sil,%sil
  80416010ca:	78 e5                	js     80416010b1 <dwarf_read_abbrev_entry+0x392>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  80416010cc:	83 f9 1f             	cmp    $0x1f,%ecx
  80416010cf:	7f 0f                	jg     80416010e0 <dwarf_read_abbrev_entry+0x3c1>
  80416010d1:	40 f6 c6 40          	test   $0x40,%sil
  80416010d5:	74 09                	je     80416010e0 <dwarf_read_abbrev_entry+0x3c1>
    result |= (-1U << shift);
  80416010d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416010dc:	d3 e0                	shl    %cl,%eax
  80416010de:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  80416010e0:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  80416010e3:	49 01 c0             	add    %rax,%r8
  80416010e6:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  80416010ea:	4d 85 e4             	test   %r12,%r12
  80416010ed:	0f 84 d4 fc ff ff    	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  80416010f3:	41 83 fd 03          	cmp    $0x3,%r13d
  80416010f7:	0f 86 ca fc ff ff    	jbe    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (int *)buf);
  80416010fd:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601100:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601105:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601109:	4c 89 e7             	mov    %r12,%rdi
  804160110c:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601113:	00 00 00 
  8041601116:	ff d0                	callq  *%rax
  8041601118:	e9 aa fc ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160111d:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601121:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601126:	4c 89 f6             	mov    %r14,%rsi
  8041601129:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160112d:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601134:	00 00 00 
  8041601137:	ff d0                	callq  *%rax
  8041601139:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160113c:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160113e:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601143:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601146:	76 2a                	jbe    8041601172 <dwarf_read_abbrev_entry+0x453>
    if (initial_len == DW_EXT_DWARF64) {
  8041601148:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160114b:	74 60                	je     80416011ad <dwarf_read_abbrev_entry+0x48e>
      cprintf("Unknown DWARF extension\n");
  804160114d:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041601154:	00 00 00 
  8041601157:	b8 00 00 00 00       	mov    $0x0,%eax
  804160115c:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041601163:	00 00 00 
  8041601166:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601168:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160116d:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  8041601172:	48 63 c3             	movslq %ebx,%rax
  8041601175:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601179:	4d 85 e4             	test   %r12,%r12
  804160117c:	0f 84 45 fc ff ff    	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  8041601182:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601186:	0f 86 3b fc ff ff    	jbe    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  804160118c:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601190:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601195:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601199:	4c 89 e7             	mov    %r12,%rdi
  804160119c:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416011a3:	00 00 00 
  80416011a6:	ff d0                	callq  *%rax
  80416011a8:	e9 1a fc ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416011ad:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416011b1:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011b6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416011ba:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416011c1:	00 00 00 
  80416011c4:	ff d0                	callq  *%rax
  80416011c6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416011ca:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416011cf:	eb a1                	jmp    8041601172 <dwarf_read_abbrev_entry+0x453>
      int count         = dwarf_read_uleb128(entry, &data);
  80416011d1:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416011d5:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  80416011d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416011dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416011e2:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  80416011e7:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416011ea:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416011ee:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  80416011f1:	89 f0                	mov    %esi,%eax
  80416011f3:	83 e0 7f             	and    $0x7f,%eax
  80416011f6:	d3 e0                	shl    %cl,%eax
  80416011f8:	09 c7                	or     %eax,%edi
    shift += 7;
  80416011fa:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416011fd:	40 84 f6             	test   %sil,%sil
  8041601200:	78 e5                	js     80416011e7 <dwarf_read_abbrev_entry+0x4c8>
  return count;
  8041601202:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601205:	49 01 c0             	add    %rax,%r8
  8041601208:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160120c:	4d 85 e4             	test   %r12,%r12
  804160120f:	0f 84 b2 fb ff ff    	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  8041601215:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601219:	0f 86 a8 fb ff ff    	jbe    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  804160121f:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601222:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601227:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160122b:	4c 89 e7             	mov    %r12,%rdi
  804160122e:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601235:	00 00 00 
  8041601238:	ff d0                	callq  *%rax
  804160123a:	e9 88 fb ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160123f:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601243:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601248:	4c 89 f6             	mov    %r14,%rsi
  804160124b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160124f:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601256:	00 00 00 
  8041601259:	ff d0                	callq  *%rax
  804160125b:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160125e:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601260:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601265:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601268:	76 2a                	jbe    8041601294 <dwarf_read_abbrev_entry+0x575>
    if (initial_len == DW_EXT_DWARF64) {
  804160126a:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160126d:	74 60                	je     80416012cf <dwarf_read_abbrev_entry+0x5b0>
      cprintf("Unknown DWARF extension\n");
  804160126f:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041601276:	00 00 00 
  8041601279:	b8 00 00 00 00       	mov    $0x0,%eax
  804160127e:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041601285:	00 00 00 
  8041601288:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  804160128a:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160128f:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  8041601294:	48 63 c3             	movslq %ebx,%rax
  8041601297:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  804160129b:	4d 85 e4             	test   %r12,%r12
  804160129e:	0f 84 23 fb ff ff    	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  80416012a4:	41 83 fd 07          	cmp    $0x7,%r13d
  80416012a8:	0f 86 19 fb ff ff    	jbe    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416012ae:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416012b2:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012b7:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012bb:	4c 89 e7             	mov    %r12,%rdi
  80416012be:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416012c5:	00 00 00 
  80416012c8:	ff d0                	callq  *%rax
  80416012ca:	e9 f8 fa ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416012cf:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416012d3:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012d8:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012dc:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416012e3:	00 00 00 
  80416012e6:	ff d0                	callq  *%rax
  80416012e8:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416012ec:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416012f1:	eb a1                	jmp    8041601294 <dwarf_read_abbrev_entry+0x575>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  80416012f3:	ba 01 00 00 00       	mov    $0x1,%edx
  80416012f8:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416012fc:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601300:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601307:	00 00 00 
  804160130a:	ff d0                	callq  *%rax
  804160130c:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601310:	4d 85 e4             	test   %r12,%r12
  8041601313:	0f 84 82 03 00 00    	je     804160169b <dwarf_read_abbrev_entry+0x97c>
  8041601319:	45 85 ed             	test   %r13d,%r13d
  804160131c:	0f 84 79 03 00 00    	je     804160169b <dwarf_read_abbrev_entry+0x97c>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601322:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601326:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  804160132b:	e9 97 fa ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041601330:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601335:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601339:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160133d:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601344:	00 00 00 
  8041601347:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041601349:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  804160134e:	4d 85 e4             	test   %r12,%r12
  8041601351:	74 06                	je     8041601359 <dwarf_read_abbrev_entry+0x63a>
  8041601353:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601357:	77 0a                	ja     8041601363 <dwarf_read_abbrev_entry+0x644>
      bytes = sizeof(Dwarf_Half);
  8041601359:	bb 02 00 00 00       	mov    $0x2,%ebx
  804160135e:	e9 64 fa ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041601363:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601368:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160136c:	4c 89 e7             	mov    %r12,%rdi
  804160136f:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601376:	00 00 00 
  8041601379:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  804160137b:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041601380:	e9 42 fa ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041601385:	ba 04 00 00 00       	mov    $0x4,%edx
  804160138a:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160138e:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601392:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601399:	00 00 00 
  804160139c:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  804160139e:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416013a3:	4d 85 e4             	test   %r12,%r12
  80416013a6:	74 06                	je     80416013ae <dwarf_read_abbrev_entry+0x68f>
  80416013a8:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013ac:	77 0a                	ja     80416013b8 <dwarf_read_abbrev_entry+0x699>
      bytes = sizeof(uint32_t);
  80416013ae:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416013b3:	e9 0f fa ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  80416013b8:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013bd:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013c1:	4c 89 e7             	mov    %r12,%rdi
  80416013c4:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416013cb:	00 00 00 
  80416013ce:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  80416013d0:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  80416013d5:	e9 ed f9 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  80416013da:	ba 08 00 00 00       	mov    $0x8,%edx
  80416013df:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013e3:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416013e7:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416013ee:	00 00 00 
  80416013f1:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  80416013f3:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  80416013f8:	4d 85 e4             	test   %r12,%r12
  80416013fb:	74 06                	je     8041601403 <dwarf_read_abbrev_entry+0x6e4>
  80416013fd:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601401:	77 0a                	ja     804160140d <dwarf_read_abbrev_entry+0x6ee>
      bytes = sizeof(uint64_t);
  8041601403:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041601408:	e9 ba f9 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  804160140d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601412:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601416:	4c 89 e7             	mov    %r12,%rdi
  8041601419:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601420:	00 00 00 
  8041601423:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601425:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  804160142a:	e9 98 f9 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &data);
  804160142f:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601433:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601436:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160143b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601440:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601445:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601448:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160144c:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160144f:	89 f0                	mov    %esi,%eax
  8041601451:	83 e0 7f             	and    $0x7f,%eax
  8041601454:	d3 e0                	shl    %cl,%eax
  8041601456:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601458:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160145b:	40 84 f6             	test   %sil,%sil
  804160145e:	78 e5                	js     8041601445 <dwarf_read_abbrev_entry+0x726>
  return count;
  8041601460:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601463:	49 01 c0             	add    %rax,%r8
  8041601466:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160146a:	4d 85 e4             	test   %r12,%r12
  804160146d:	0f 84 54 f9 ff ff    	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  8041601473:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601477:	0f 86 4a f9 ff ff    	jbe    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  804160147d:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601480:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601485:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601489:	4c 89 e7             	mov    %r12,%rdi
  804160148c:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601493:	00 00 00 
  8041601496:	ff d0                	callq  *%rax
  8041601498:	e9 2a f9 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &form);
  804160149d:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416014a1:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416014a4:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416014aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014af:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416014b4:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416014b8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416014bc:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416014c0:	44 89 c0             	mov    %r8d,%eax
  80416014c3:	83 e0 7f             	and    $0x7f,%eax
  80416014c6:	d3 e0                	shl    %cl,%eax
  80416014c8:	09 c6                	or     %eax,%esi
    shift += 7;
  80416014ca:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416014cd:	45 84 c0             	test   %r8b,%r8b
  80416014d0:	78 e2                	js     80416014b4 <dwarf_read_abbrev_entry+0x795>
  return count;
  80416014d2:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  80416014d5:	48 01 c7             	add    %rax,%rdi
  80416014d8:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  80416014dc:	41 89 d8             	mov    %ebx,%r8d
  80416014df:	44 89 e9             	mov    %r13d,%ecx
  80416014e2:	4c 89 e2             	mov    %r12,%rdx
  80416014e5:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  80416014ec:	00 00 00 
  80416014ef:	ff d0                	callq  *%rax
      bytes    = count + read;
  80416014f1:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  80416014f5:	e9 cd f8 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  80416014fa:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416014fe:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601503:	4c 89 f6             	mov    %r14,%rsi
  8041601506:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160150a:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601511:	00 00 00 
  8041601514:	ff d0                	callq  *%rax
  8041601516:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601519:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160151b:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601520:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601523:	76 2a                	jbe    804160154f <dwarf_read_abbrev_entry+0x830>
    if (initial_len == DW_EXT_DWARF64) {
  8041601525:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601528:	74 60                	je     804160158a <dwarf_read_abbrev_entry+0x86b>
      cprintf("Unknown DWARF extension\n");
  804160152a:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041601531:	00 00 00 
  8041601534:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601539:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041601540:	00 00 00 
  8041601543:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601545:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160154a:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  804160154f:	48 63 c3             	movslq %ebx,%rax
  8041601552:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601556:	4d 85 e4             	test   %r12,%r12
  8041601559:	0f 84 68 f8 ff ff    	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  804160155f:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601563:	0f 86 5e f8 ff ff    	jbe    8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  8041601569:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  804160156d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601572:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601576:	4c 89 e7             	mov    %r12,%rdi
  8041601579:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601580:	00 00 00 
  8041601583:	ff d0                	callq  *%rax
  8041601585:	e9 3d f8 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160158a:	49 8d 76 20          	lea    0x20(%r14),%rsi
  804160158e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601593:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601597:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160159e:	00 00 00 
  80416015a1:	ff d0                	callq  *%rax
  80416015a3:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416015a7:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416015ac:	eb a1                	jmp    804160154f <dwarf_read_abbrev_entry+0x830>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416015ae:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416015b2:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416015b5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416015bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416015c0:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416015c5:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416015c8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416015cc:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416015d0:	89 f8                	mov    %edi,%eax
  80416015d2:	83 e0 7f             	and    $0x7f,%eax
  80416015d5:	d3 e0                	shl    %cl,%eax
  80416015d7:	09 c3                	or     %eax,%ebx
    shift += 7;
  80416015d9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416015dc:	40 84 ff             	test   %dil,%dil
  80416015df:	78 e4                	js     80416015c5 <dwarf_read_abbrev_entry+0x8a6>
  return count;
  80416015e1:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  80416015e4:	4c 01 f6             	add    %r14,%rsi
  80416015e7:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  80416015eb:	4d 85 e4             	test   %r12,%r12
  80416015ee:	74 1a                	je     804160160a <dwarf_read_abbrev_entry+0x8eb>
        memcpy(buf, entry, MIN(length, bufsize));
  80416015f0:	41 39 dd             	cmp    %ebx,%r13d
  80416015f3:	44 89 ea             	mov    %r13d,%edx
  80416015f6:	0f 47 d3             	cmova  %ebx,%edx
  80416015f9:	89 d2                	mov    %edx,%edx
  80416015fb:	4c 89 e7             	mov    %r12,%rdi
  80416015fe:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601605:	00 00 00 
  8041601608:	ff d0                	callq  *%rax
      bytes = count + length;
  804160160a:	44 01 f3             	add    %r14d,%ebx
    } break;
  804160160d:	e9 b5 f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      bytes = 0;
  8041601612:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  8041601617:	48 85 d2             	test   %rdx,%rdx
  804160161a:	0f 84 a7 f7 ff ff    	je     8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(true, (bool *)buf);
  8041601620:	c6 02 01             	movb   $0x1,(%rdx)
  8041601623:	e9 9f f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601628:	ba 08 00 00 00       	mov    $0x8,%edx
  804160162d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601631:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601635:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160163c:	00 00 00 
  804160163f:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601641:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601646:	4d 85 e4             	test   %r12,%r12
  8041601649:	74 06                	je     8041601651 <dwarf_read_abbrev_entry+0x932>
  804160164b:	41 83 fd 07          	cmp    $0x7,%r13d
  804160164f:	77 0a                	ja     804160165b <dwarf_read_abbrev_entry+0x93c>
      bytes = sizeof(uint64_t);
  8041601651:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  8041601656:	e9 6c f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  804160165b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601660:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601664:	4c 89 e7             	mov    %r12,%rdi
  8041601667:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160166e:	00 00 00 
  8041601671:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601673:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041601678:	e9 4a f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
  int bytes = 0;
  804160167d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041601682:	e9 40 f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  8041601687:	bb 01 00 00 00       	mov    $0x1,%ebx
  804160168c:	e9 36 f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  8041601691:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041601696:	e9 2c f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  804160169b:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016a0:	e9 22 f7 ff ff       	jmpq   8041600dc7 <dwarf_read_abbrev_entry+0xa8>

00000080416016a5 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416016a5:	55                   	push   %rbp
  80416016a6:	48 89 e5             	mov    %rsp,%rbp
  80416016a9:	41 57                	push   %r15
  80416016ab:	41 56                	push   %r14
  80416016ad:	41 55                	push   %r13
  80416016af:	41 54                	push   %r12
  80416016b1:	53                   	push   %rbx
  80416016b2:	48 83 ec 48          	sub    $0x48,%rsp
  80416016b6:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80416016ba:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416016be:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  80416016c2:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416016c6:	49 bd 4a c5 60 41 80 	movabs $0x804160c54a,%r13
  80416016cd:	00 00 00 
  80416016d0:	e9 bb 01 00 00       	jmpq   8041601890 <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416016d5:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416016d9:	ba 08 00 00 00       	mov    $0x8,%edx
  80416016de:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416016e2:	41 ff d5             	callq  *%r13
  80416016e5:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  80416016e9:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416016ee:	eb 08                	jmp    80416016f8 <info_by_address+0x53>
    *len = initial_len;
  80416016f0:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  80416016f3:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  80416016f8:	4c 63 fb             	movslq %ebx,%r15
  80416016fb:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  80416016ff:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  8041601702:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601707:	48 89 de             	mov    %rbx,%rsi
  804160170a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160170e:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  8041601711:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  8041601715:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160171a:	75 7a                	jne    8041601796 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  804160171c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601721:	48 89 de             	mov    %rbx,%rsi
  8041601724:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601728:	41 ff d5             	callq  *%r13
  804160172b:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160172e:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  8041601731:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  8041601734:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  8041601738:	ba 01 00 00 00       	mov    $0x1,%edx
  804160173d:	48 89 de             	mov    %rbx,%rsi
  8041601740:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601744:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  8041601747:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160174b:	75 7e                	jne    80416017cb <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  804160174d:	48 83 c3 02          	add    $0x2,%rbx
  8041601751:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601756:	4c 89 fe             	mov    %r15,%rsi
  8041601759:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160175d:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  8041601760:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  8041601764:	0f 85 96 00 00 00    	jne    8041601800 <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  804160176a:	48 89 d8             	mov    %rbx,%rax
  804160176d:	4c 29 f0             	sub    %r14,%rax
  8041601770:	48 99                	cqto   
  8041601772:	48 c1 ea 3c          	shr    $0x3c,%rdx
  8041601776:	48 01 d0             	add    %rdx,%rax
  8041601779:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  804160177c:	48 29 d0             	sub    %rdx,%rax
  804160177f:	0f 84 b5 00 00 00    	je     804160183a <info_by_address+0x195>
      set += 2 * address_size - remainder;
  8041601785:	ba 10 00 00 00       	mov    $0x10,%edx
  804160178a:	89 d1                	mov    %edx,%ecx
  804160178c:	29 c1                	sub    %eax,%ecx
  804160178e:	48 01 cb             	add    %rcx,%rbx
  8041601791:	e9 a4 00 00 00       	jmpq   804160183a <info_by_address+0x195>
    assert(version == 2);
  8041601796:	48 b9 1e d0 60 41 80 	movabs $0x804160d01e,%rcx
  804160179d:	00 00 00 
  80416017a0:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416017a7:	00 00 00 
  80416017aa:	be 20 00 00 00       	mov    $0x20,%esi
  80416017af:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  80416017b6:	00 00 00 
  80416017b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017be:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416017c5:	00 00 00 
  80416017c8:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416017cb:	48 b9 db cf 60 41 80 	movabs $0x804160cfdb,%rcx
  80416017d2:	00 00 00 
  80416017d5:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416017dc:	00 00 00 
  80416017df:	be 24 00 00 00       	mov    $0x24,%esi
  80416017e4:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  80416017eb:	00 00 00 
  80416017ee:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017f3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416017fa:	00 00 00 
  80416017fd:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  8041601800:	48 b9 ed cf 60 41 80 	movabs $0x804160cfed,%rcx
  8041601807:	00 00 00 
  804160180a:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601811:	00 00 00 
  8041601814:	be 26 00 00 00       	mov    $0x26,%esi
  8041601819:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601820:	00 00 00 
  8041601823:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601828:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160182f:	00 00 00 
  8041601832:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601835:	4c 39 e3             	cmp    %r12,%rbx
  8041601838:	73 51                	jae    804160188b <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  804160183a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160183f:	48 89 de             	mov    %rbx,%rsi
  8041601842:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601846:	41 ff d5             	callq  *%r13
  8041601849:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  804160184d:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  8041601851:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601856:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160185a:	41 ff d5             	callq  *%r13
  804160185d:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  8041601860:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  8041601864:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8041601868:	4c 39 f1             	cmp    %r14,%rcx
  804160186b:	72 c8                	jb     8041601835 <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  804160186d:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  804160186f:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  8041601872:	48 39 c1             	cmp    %rax,%rcx
  8041601875:	77 be                	ja     8041601835 <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601877:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160187b:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  804160187e:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  8041601881:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601886:	e9 5a 04 00 00       	jmpq   8041601ce5 <info_by_address+0x640>
      set += address_size;
  804160188b:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  804160188e:	75 71                	jne    8041601901 <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  8041601890:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601894:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  8041601898:	73 42                	jae    80416018dc <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  804160189a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160189f:	4c 89 f6             	mov    %r14,%rsi
  80416018a2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018a6:	41 ff d5             	callq  *%r13
  80416018a9:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416018ad:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  80416018b1:	0f 86 39 fe ff ff    	jbe    80416016f0 <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  80416018b7:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  80416018bb:	0f 84 14 fe ff ff    	je     80416016d5 <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  80416018c1:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  80416018c8:	00 00 00 
  80416018cb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018d0:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416018d7:	00 00 00 
  80416018da:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  80416018dc:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018e0:	48 8b 58 20          	mov    0x20(%rax),%rbx
  80416018e4:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  80416018e8:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  80416018ec:	0f 83 5b 04 00 00    	jae    8041601d4d <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  80416018f2:	49 bf 4a c5 60 41 80 	movabs $0x804160c54a,%r15
  80416018f9:	00 00 00 
  80416018fc:	e9 9f 03 00 00       	jmpq   8041601ca0 <info_by_address+0x5fb>
    assert(set == set_end);
  8041601901:	48 b9 ff cf 60 41 80 	movabs $0x804160cfff,%rcx
  8041601908:	00 00 00 
  804160190b:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601912:	00 00 00 
  8041601915:	be 3a 00 00 00       	mov    $0x3a,%esi
  804160191a:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601921:	00 00 00 
  8041601924:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601929:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601930:	00 00 00 
  8041601933:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601936:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160193a:	48 8d 70 20          	lea    0x20(%rax),%rsi
  804160193e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601943:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601947:	41 ff d7             	callq  *%r15
  804160194a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160194e:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601954:	eb 08                	jmp    804160195e <info_by_address+0x2b9>
    *len = initial_len;
  8041601956:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041601958:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  804160195e:	4d 63 e4             	movslq %r12d,%r12
  8041601961:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041601965:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  8041601969:	48 01 d8             	add    %rbx,%rax
  804160196c:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601970:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601975:	48 89 de             	mov    %rbx,%rsi
  8041601978:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160197c:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  804160197f:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  8041601983:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601987:	83 e8 02             	sub    $0x2,%eax
  804160198a:	66 a9 fd ff          	test   $0xfffd,%ax
  804160198e:	0f 85 07 01 00 00    	jne    8041601a9b <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601994:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601999:	48 89 de             	mov    %rbx,%rsi
  804160199c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019a0:	41 ff d7             	callq  *%r15
  80416019a3:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  80416019a7:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416019ab:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  80416019af:	ba 01 00 00 00       	mov    $0x1,%edx
  80416019b4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019b8:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  80416019bb:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416019bf:	0f 85 0b 01 00 00    	jne    8041601ad0 <info_by_address+0x42b>
  80416019c5:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  80416019c8:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416019cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416019d2:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416019d7:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  80416019db:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  80416019df:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416019e2:	44 89 c7             	mov    %r8d,%edi
  80416019e5:	83 e7 7f             	and    $0x7f,%edi
  80416019e8:	d3 e7                	shl    %cl,%edi
  80416019ea:	09 fa                	or     %edi,%edx
    shift += 7;
  80416019ec:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416019ef:	45 84 c0             	test   %r8b,%r8b
  80416019f2:	78 e3                	js     80416019d7 <info_by_address+0x332>
  return count;
  80416019f4:	48 98                	cltq   
    assert(abbrev_code != 0);
  80416019f6:	85 d2                	test   %edx,%edx
  80416019f8:	0f 84 07 01 00 00    	je     8041601b05 <info_by_address+0x460>
    entry += count;
  80416019fe:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601a01:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601a05:	4c 03 28             	add    (%rax),%r13
  8041601a08:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  8041601a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a10:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a15:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601a1a:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041601a1e:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041601a22:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a25:	45 89 c8             	mov    %r9d,%r8d
  8041601a28:	41 83 e0 7f          	and    $0x7f,%r8d
  8041601a2c:	41 d3 e0             	shl    %cl,%r8d
  8041601a2f:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  8041601a32:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a35:	45 84 c9             	test   %r9b,%r9b
  8041601a38:	78 e0                	js     8041601a1a <info_by_address+0x375>
  return count;
  8041601a3a:	48 98                	cltq   
    abbrev_entry += count;
  8041601a3c:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  8041601a3f:	39 f2                	cmp    %esi,%edx
  8041601a41:	0f 85 f3 00 00 00    	jne    8041601b3a <info_by_address+0x495>
  8041601a47:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  8041601a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a54:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601a59:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601a5d:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a61:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a64:	44 89 c7             	mov    %r8d,%edi
  8041601a67:	83 e7 7f             	and    $0x7f,%edi
  8041601a6a:	d3 e7                	shl    %cl,%edi
  8041601a6c:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a6e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a71:	45 84 c0             	test   %r8b,%r8b
  8041601a74:	78 e3                	js     8041601a59 <info_by_address+0x3b4>
  return count;
  8041601a76:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  8041601a78:	83 fa 11             	cmp    $0x11,%edx
  8041601a7b:	0f 85 ee 00 00 00    	jne    8041601b6f <info_by_address+0x4ca>
    abbrev_entry++;
  8041601a81:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601a86:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601a8d:	00 
  8041601a8e:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601a95:	00 
  8041601a96:	e9 2f 01 00 00       	jmpq   8041601bca <info_by_address+0x525>
    assert(version == 4 || version == 2);
  8041601a9b:	48 b9 0e d0 60 41 80 	movabs $0x804160d00e,%rcx
  8041601aa2:	00 00 00 
  8041601aa5:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601aac:	00 00 00 
  8041601aaf:	be 43 01 00 00       	mov    $0x143,%esi
  8041601ab4:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601abb:	00 00 00 
  8041601abe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ac3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601aca:	00 00 00 
  8041601acd:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601ad0:	48 b9 db cf 60 41 80 	movabs $0x804160cfdb,%rcx
  8041601ad7:	00 00 00 
  8041601ada:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601ae1:	00 00 00 
  8041601ae4:	be 47 01 00 00       	mov    $0x147,%esi
  8041601ae9:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601af0:	00 00 00 
  8041601af3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601af8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601aff:	00 00 00 
  8041601b02:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601b05:	48 b9 2b d0 60 41 80 	movabs $0x804160d02b,%rcx
  8041601b0c:	00 00 00 
  8041601b0f:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601b16:	00 00 00 
  8041601b19:	be 4c 01 00 00       	mov    $0x14c,%esi
  8041601b1e:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601b25:	00 00 00 
  8041601b28:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b2d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b34:	00 00 00 
  8041601b37:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601b3a:	48 b9 60 d1 60 41 80 	movabs $0x804160d160,%rcx
  8041601b41:	00 00 00 
  8041601b44:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601b4b:	00 00 00 
  8041601b4e:	be 54 01 00 00       	mov    $0x154,%esi
  8041601b53:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601b5a:	00 00 00 
  8041601b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b62:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b69:	00 00 00 
  8041601b6c:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601b6f:	48 b9 3c d0 60 41 80 	movabs $0x804160d03c,%rcx
  8041601b76:	00 00 00 
  8041601b79:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601b80:	00 00 00 
  8041601b83:	be 58 01 00 00       	mov    $0x158,%esi
  8041601b88:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601b8f:	00 00 00 
  8041601b92:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b97:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b9e:	00 00 00 
  8041601ba1:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601ba4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601baa:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601baf:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601bb3:	44 89 f6             	mov    %r14d,%esi
  8041601bb6:	4c 89 e7             	mov    %r12,%rdi
  8041601bb9:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  8041601bc0:	00 00 00 
  8041601bc3:	ff d0                	callq  *%rax
      entry += count;
  8041601bc5:	48 98                	cltq   
  8041601bc7:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601bca:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601bd7:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601bdd:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601be0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601be4:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601be7:	89 fe                	mov    %edi,%esi
  8041601be9:	83 e6 7f             	and    $0x7f,%esi
  8041601bec:	d3 e6                	shl    %cl,%esi
  8041601bee:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601bf1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601bf4:	40 84 ff             	test   %dil,%dil
  8041601bf7:	78 e4                	js     8041601bdd <info_by_address+0x538>
  return count;
  8041601bf9:	48 98                	cltq   
      abbrev_entry += count;
  8041601bfb:	48 01 c3             	add    %rax,%rbx
  8041601bfe:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c01:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c06:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c0b:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601c11:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c14:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c18:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c1b:	89 fe                	mov    %edi,%esi
  8041601c1d:	83 e6 7f             	and    $0x7f,%esi
  8041601c20:	d3 e6                	shl    %cl,%esi
  8041601c22:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601c25:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c28:	40 84 ff             	test   %dil,%dil
  8041601c2b:	78 e4                	js     8041601c11 <info_by_address+0x56c>
  return count;
  8041601c2d:	48 98                	cltq   
      abbrev_entry += count;
  8041601c2f:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601c32:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601c36:	0f 84 68 ff ff ff    	je     8041601ba4 <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601c3c:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601c40:	0f 84 ae 00 00 00    	je     8041601cf4 <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601c46:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c51:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601c56:	44 89 f6             	mov    %r14d,%esi
  8041601c59:	4c 89 e7             	mov    %r12,%rdi
  8041601c5c:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  8041601c63:	00 00 00 
  8041601c66:	ff d0                	callq  *%rax
      entry += count;
  8041601c68:	48 98                	cltq   
  8041601c6a:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601c6d:	45 09 f5             	or     %r14d,%r13d
  8041601c70:	0f 85 54 ff ff ff    	jne    8041601bca <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601c76:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601c7a:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601c7e:	72 0a                	jb     8041601c8a <info_by_address+0x5e5>
  8041601c80:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601c84:	0f 86 a2 00 00 00    	jbe    8041601d2c <info_by_address+0x687>
    entry = entry_end;
  8041601c8a:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601c8e:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601c92:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601c96:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601c9a:	0f 83 a6 00 00 00    	jae    8041601d46 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601ca0:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601ca5:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601ca9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601cad:	41 ff d7             	callq  *%r15
  8041601cb0:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601cb3:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601cb6:	0f 86 9a fc ff ff    	jbe    8041601956 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601cbc:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601cbf:	0f 84 71 fc ff ff    	je     8041601936 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601cc5:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041601ccc:	00 00 00 
  8041601ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cd4:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041601cdb:	00 00 00 
  8041601cde:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601ce0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601ce5:	48 83 c4 48          	add    $0x48,%rsp
  8041601ce9:	5b                   	pop    %rbx
  8041601cea:	41 5c                	pop    %r12
  8041601cec:	41 5d                	pop    %r13
  8041601cee:	41 5e                	pop    %r14
  8041601cf0:	41 5f                	pop    %r15
  8041601cf2:	5d                   	pop    %rbp
  8041601cf3:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601cf4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601cfa:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601cff:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601d03:	44 89 f6             	mov    %r14d,%esi
  8041601d06:	4c 89 e7             	mov    %r12,%rdi
  8041601d09:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  8041601d10:	00 00 00 
  8041601d13:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601d15:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601d19:	0f 84 a6 fe ff ff    	je     8041601bc5 <info_by_address+0x520>
          high_pc += low_pc;
  8041601d1f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601d23:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601d27:	e9 99 fe ff ff       	jmpq   8041601bc5 <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601d2c:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601d30:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601d34:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601d38:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601d3c:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d44:	eb 9f                	jmp    8041601ce5 <info_by_address+0x640>
  return 0;
  8041601d46:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d4b:	eb 98                	jmp    8041601ce5 <info_by_address+0x640>
  8041601d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d52:	eb 91                	jmp    8041601ce5 <info_by_address+0x640>

0000008041601d54 <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601d54:	55                   	push   %rbp
  8041601d55:	48 89 e5             	mov    %rsp,%rbp
  8041601d58:	41 57                	push   %r15
  8041601d5a:	41 56                	push   %r14
  8041601d5c:	41 55                	push   %r13
  8041601d5e:	41 54                	push   %r12
  8041601d60:	53                   	push   %rbx
  8041601d61:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601d65:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601d69:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601d6d:	48 29 d8             	sub    %rbx,%rax
  8041601d70:	48 39 f0             	cmp    %rsi,%rax
  8041601d73:	0f 82 f5 02 00 00    	jb     804160206e <file_name_by_info+0x31a>
  8041601d79:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601d7d:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601d80:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601d84:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601d88:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601d8b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601d90:	48 89 de             	mov    %rbx,%rsi
  8041601d93:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d97:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601d9e:	00 00 00 
  8041601da1:	ff d0                	callq  *%rax
  8041601da3:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601da6:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601da9:	0f 86 c9 02 00 00    	jbe    8041602078 <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601daf:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601db2:	74 25                	je     8041601dd9 <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601db4:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041601dbb:	00 00 00 
  8041601dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dc3:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041601dca:	00 00 00 
  8041601dcd:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601dcf:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601dd4:	e9 00 02 00 00       	jmpq   8041601fd9 <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601dd9:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601ddd:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601de2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601de6:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041601ded:	00 00 00 
  8041601df0:	ff d0                	callq  *%rax
      count = 12;
  8041601df2:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601df8:	e9 81 02 00 00       	jmpq   804160207e <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601dfd:	48 b9 0e d0 60 41 80 	movabs $0x804160d00e,%rcx
  8041601e04:	00 00 00 
  8041601e07:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601e0e:	00 00 00 
  8041601e11:	be 9b 01 00 00       	mov    $0x19b,%esi
  8041601e16:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601e1d:	00 00 00 
  8041601e20:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e25:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e2c:	00 00 00 
  8041601e2f:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601e32:	48 b9 db cf 60 41 80 	movabs $0x804160cfdb,%rcx
  8041601e39:	00 00 00 
  8041601e3c:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601e43:	00 00 00 
  8041601e46:	be 9f 01 00 00       	mov    $0x19f,%esi
  8041601e4b:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601e52:	00 00 00 
  8041601e55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e5a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e61:	00 00 00 
  8041601e64:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601e67:	48 b9 2b d0 60 41 80 	movabs $0x804160d02b,%rcx
  8041601e6e:	00 00 00 
  8041601e71:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601e78:	00 00 00 
  8041601e7b:	be a4 01 00 00       	mov    $0x1a4,%esi
  8041601e80:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601e87:	00 00 00 
  8041601e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e8f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e96:	00 00 00 
  8041601e99:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601e9c:	48 b9 60 d1 60 41 80 	movabs $0x804160d160,%rcx
  8041601ea3:	00 00 00 
  8041601ea6:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601ead:	00 00 00 
  8041601eb0:	be ac 01 00 00       	mov    $0x1ac,%esi
  8041601eb5:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601ebc:	00 00 00 
  8041601ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ec4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ecb:	00 00 00 
  8041601ece:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601ed1:	48 b9 3c d0 60 41 80 	movabs $0x804160d03c,%rcx
  8041601ed8:	00 00 00 
  8041601edb:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041601ee2:	00 00 00 
  8041601ee5:	be b0 01 00 00       	mov    $0x1b0,%esi
  8041601eea:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041601ef1:	00 00 00 
  8041601ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ef9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601f00:	00 00 00 
  8041601f03:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601f06:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601f0a:	0f 84 d8 00 00 00    	je     8041601fe8 <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601f10:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f16:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601f19:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601f1d:	44 89 ee             	mov    %r13d,%esi
  8041601f20:	4c 89 f7             	mov    %r14,%rdi
  8041601f23:	41 ff d7             	callq  *%r15
  8041601f26:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601f29:	49 63 c4             	movslq %r12d,%rax
  8041601f2c:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601f2f:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f32:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f37:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f3c:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601f42:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f45:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f49:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f4c:	89 f0                	mov    %esi,%eax
  8041601f4e:	83 e0 7f             	and    $0x7f,%eax
  8041601f51:	d3 e0                	shl    %cl,%eax
  8041601f53:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601f56:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601f59:	40 84 f6             	test   %sil,%sil
  8041601f5c:	78 e4                	js     8041601f42 <file_name_by_info+0x1ee>
  return count;
  8041601f5e:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601f61:	48 01 fb             	add    %rdi,%rbx
  8041601f64:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f67:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f71:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601f77:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f7a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f7e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f81:	89 f0                	mov    %esi,%eax
  8041601f83:	83 e0 7f             	and    $0x7f,%eax
  8041601f86:	d3 e0                	shl    %cl,%eax
  8041601f88:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601f8b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601f8e:	40 84 f6             	test   %sil,%sil
  8041601f91:	78 e4                	js     8041601f77 <file_name_by_info+0x223>
  return count;
  8041601f93:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601f96:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041601f99:	41 83 fc 03          	cmp    $0x3,%r12d
  8041601f9d:	0f 84 63 ff ff ff    	je     8041601f06 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041601fa3:	41 83 fc 10          	cmp    $0x10,%r12d
  8041601fa7:	0f 84 a1 00 00 00    	je     804160204e <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601fad:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601fb3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601fb8:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601fbd:	44 89 ee             	mov    %r13d,%esi
  8041601fc0:	4c 89 f7             	mov    %r14,%rdi
  8041601fc3:	41 ff d7             	callq  *%r15
    entry += count;
  8041601fc6:	48 98                	cltq   
  8041601fc8:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601fcb:	45 09 e5             	or     %r12d,%r13d
  8041601fce:	0f 85 5b ff ff ff    	jne    8041601f2f <file_name_by_info+0x1db>

  return 0;
  8041601fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601fd9:	48 83 c4 38          	add    $0x38,%rsp
  8041601fdd:	5b                   	pop    %rbx
  8041601fde:	41 5c                	pop    %r12
  8041601fe0:	41 5d                	pop    %r13
  8041601fe2:	41 5e                	pop    %r14
  8041601fe4:	41 5f                	pop    %r15
  8041601fe6:	5d                   	pop    %rbp
  8041601fe7:	c3                   	retq   
        unsigned long offset = 0;
  8041601fe8:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601fef:	00 
        count                = dwarf_read_abbrev_entry(
  8041601ff0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601ff6:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601ffb:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601fff:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602004:	4c 89 f7             	mov    %r14,%rdi
  8041602007:	41 ff d7             	callq  *%r15
  804160200a:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  804160200d:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041602011:	48 85 ff             	test   %rdi,%rdi
  8041602014:	0f 84 0f ff ff ff    	je     8041601f29 <file_name_by_info+0x1d5>
  804160201a:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  804160201e:	0f 86 05 ff ff ff    	jbe    8041601f29 <file_name_by_info+0x1d5>
          put_unaligned(
  8041602024:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602028:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  804160202c:	48 03 41 40          	add    0x40(%rcx),%rax
  8041602030:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602034:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602039:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160203d:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602044:	00 00 00 
  8041602047:	ff d0                	callq  *%rax
  8041602049:	e9 db fe ff ff       	jmpq   8041601f29 <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  804160204e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602054:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602059:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  804160205d:	44 89 ee             	mov    %r13d,%esi
  8041602060:	4c 89 f7             	mov    %r14,%rdi
  8041602063:	41 ff d7             	callq  *%r15
  8041602066:	41 89 c4             	mov    %eax,%r12d
  8041602069:	e9 bb fe ff ff       	jmpq   8041601f29 <file_name_by_info+0x1d5>
    return -E_INVAL;
  804160206e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041602073:	e9 61 ff ff ff       	jmpq   8041601fd9 <file_name_by_info+0x285>
  count       = 4;
  8041602078:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  804160207e:	4d 63 ed             	movslq %r13d,%r13
  8041602081:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602084:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602089:	48 89 de             	mov    %rbx,%rsi
  804160208c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602090:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602097:	00 00 00 
  804160209a:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  804160209c:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416020a0:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416020a4:	83 e8 02             	sub    $0x2,%eax
  80416020a7:	66 a9 fd ff          	test   $0xfffd,%ax
  80416020ab:	0f 85 4c fd ff ff    	jne    8041601dfd <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416020b1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416020b6:	48 89 de             	mov    %rbx,%rsi
  80416020b9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020bd:	49 bf 4a c5 60 41 80 	movabs $0x804160c54a,%r15
  80416020c4:	00 00 00 
  80416020c7:	41 ff d7             	callq  *%r15
  80416020ca:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  80416020ce:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416020d2:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416020d6:	ba 01 00 00 00       	mov    $0x1,%edx
  80416020db:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020df:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  80416020e2:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416020e6:	0f 85 46 fd ff ff    	jne    8041601e32 <file_name_by_info+0xde>
  80416020ec:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  80416020ef:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416020f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416020f9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416020ff:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602102:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602106:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602109:	89 f0                	mov    %esi,%eax
  804160210b:	83 e0 7f             	and    $0x7f,%eax
  804160210e:	d3 e0                	shl    %cl,%eax
  8041602110:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602113:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602116:	40 84 f6             	test   %sil,%sil
  8041602119:	78 e4                	js     80416020ff <file_name_by_info+0x3ab>
  return count;
  804160211b:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  804160211e:	45 85 c0             	test   %r8d,%r8d
  8041602121:	0f 84 40 fd ff ff    	je     8041601e67 <file_name_by_info+0x113>
  entry += count;
  8041602127:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  804160212a:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  804160212e:	4c 03 20             	add    (%rax),%r12
  8041602131:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041602134:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602139:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160213e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602144:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602147:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160214b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160214e:	89 f0                	mov    %esi,%eax
  8041602150:	83 e0 7f             	and    $0x7f,%eax
  8041602153:	d3 e0                	shl    %cl,%eax
  8041602155:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602158:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160215b:	40 84 f6             	test   %sil,%sil
  804160215e:	78 e4                	js     8041602144 <file_name_by_info+0x3f0>
  return count;
  8041602160:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  8041602163:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  8041602166:	45 39 c8             	cmp    %r9d,%r8d
  8041602169:	0f 85 2d fd ff ff    	jne    8041601e9c <file_name_by_info+0x148>
  804160216f:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041602172:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602177:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160217c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602182:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602185:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602189:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160218c:	89 f0                	mov    %esi,%eax
  804160218e:	83 e0 7f             	and    $0x7f,%eax
  8041602191:	d3 e0                	shl    %cl,%eax
  8041602193:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602196:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602199:	40 84 f6             	test   %sil,%sil
  804160219c:	78 e4                	js     8041602182 <file_name_by_info+0x42e>
  return count;
  804160219e:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  80416021a1:	41 83 f8 11          	cmp    $0x11,%r8d
  80416021a5:	0f 85 26 fd ff ff    	jne    8041601ed1 <file_name_by_info+0x17d>
  abbrev_entry++;
  80416021ab:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  80416021b0:	49 bf 1f 0d 60 41 80 	movabs $0x8041600d1f,%r15
  80416021b7:	00 00 00 
  80416021ba:	e9 70 fd ff ff       	jmpq   8041601f2f <file_name_by_info+0x1db>

00000080416021bf <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  80416021bf:	55                   	push   %rbp
  80416021c0:	48 89 e5             	mov    %rsp,%rbp
  80416021c3:	41 57                	push   %r15
  80416021c5:	41 56                	push   %r14
  80416021c7:	41 55                	push   %r13
  80416021c9:	41 54                	push   %r12
  80416021cb:	53                   	push   %rbx
  80416021cc:	48 83 ec 68          	sub    $0x68,%rsp
  80416021d0:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  80416021d4:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  80416021db:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  80416021df:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  80416021e3:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  80416021ea:	48 89 d3             	mov    %rdx,%rbx
  80416021ed:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  80416021f1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416021f6:	48 89 de             	mov    %rbx,%rsi
  80416021f9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021fd:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602204:	00 00 00 
  8041602207:	ff d0                	callq  *%rax
  8041602209:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160220c:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160220f:	76 59                	jbe    804160226a <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  8041602211:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602214:	74 2f                	je     8041602245 <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602216:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  804160221d:	00 00 00 
  8041602220:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602225:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160222c:	00 00 00 
  804160222f:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041602231:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602236:	48 83 c4 68          	add    $0x68,%rsp
  804160223a:	5b                   	pop    %rbx
  804160223b:	41 5c                	pop    %r12
  804160223d:	41 5d                	pop    %r13
  804160223f:	41 5e                	pop    %r14
  8041602241:	41 5f                	pop    %r15
  8041602243:	5d                   	pop    %rbp
  8041602244:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602245:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041602249:	ba 08 00 00 00       	mov    $0x8,%edx
  804160224e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602252:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602259:	00 00 00 
  804160225c:	ff d0                	callq  *%rax
  804160225e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602262:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  8041602268:	eb 08                	jmp    8041602272 <function_by_info+0xb3>
    *len = initial_len;
  804160226a:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160226c:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  8041602272:	4d 63 f6             	movslq %r14d,%r14
  8041602275:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  8041602278:	48 01 d8             	add    %rbx,%rax
  804160227b:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160227f:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602284:	48 89 de             	mov    %rbx,%rsi
  8041602287:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160228b:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602292:	00 00 00 
  8041602295:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  8041602297:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  804160229b:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  804160229f:	83 e8 02             	sub    $0x2,%eax
  80416022a2:	66 a9 fd ff          	test   $0xfffd,%ax
  80416022a6:	75 51                	jne    80416022f9 <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416022a8:	ba 04 00 00 00       	mov    $0x4,%edx
  80416022ad:	48 89 de             	mov    %rbx,%rsi
  80416022b0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022b4:	49 bc 4a c5 60 41 80 	movabs $0x804160c54a,%r12
  80416022bb:	00 00 00 
  80416022be:	41 ff d4             	callq  *%r12
  80416022c1:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  80416022c5:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416022c9:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416022cd:	ba 01 00 00 00       	mov    $0x1,%edx
  80416022d2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022d6:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  80416022d9:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416022dd:	75 4f                	jne    804160232e <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  80416022df:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416022e3:	4c 03 28             	add    (%rax),%r13
  80416022e6:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  80416022ea:	49 bf 1f 0d 60 41 80 	movabs $0x8041600d1f,%r15
  80416022f1:	00 00 00 
  while (entry < entry_end) {
  80416022f4:	e9 07 02 00 00       	jmpq   8041602500 <function_by_info+0x341>
  assert(version == 4 || version == 2);
  80416022f9:	48 b9 0e d0 60 41 80 	movabs $0x804160d00e,%rcx
  8041602300:	00 00 00 
  8041602303:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160230a:	00 00 00 
  804160230d:	be e9 01 00 00       	mov    $0x1e9,%esi
  8041602312:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041602319:	00 00 00 
  804160231c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602321:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602328:	00 00 00 
  804160232b:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  804160232e:	48 b9 db cf 60 41 80 	movabs $0x804160cfdb,%rcx
  8041602335:	00 00 00 
  8041602338:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160233f:	00 00 00 
  8041602342:	be ed 01 00 00       	mov    $0x1ed,%esi
  8041602347:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  804160234e:	00 00 00 
  8041602351:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602356:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160235d:	00 00 00 
  8041602360:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  8041602363:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602367:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  804160236b:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  804160236f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  8041602375:	49 39 da             	cmp    %rbx,%r10
  8041602378:	0f 86 e7 00 00 00    	jbe    8041602465 <function_by_info+0x2a6>
  804160237e:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602381:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602387:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160238c:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602391:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602394:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602398:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  804160239c:	89 f8                	mov    %edi,%eax
  804160239e:	83 e0 7f             	and    $0x7f,%eax
  80416023a1:	d3 e0                	shl    %cl,%eax
  80416023a3:	09 c6                	or     %eax,%esi
    shift += 7;
  80416023a5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023a8:	40 84 ff             	test   %dil,%dil
  80416023ab:	78 e4                	js     8041602391 <function_by_info+0x1d2>
  return count;
  80416023ad:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  80416023b0:	4c 01 c3             	add    %r8,%rbx
  80416023b3:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023b6:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  80416023bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023c1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416023c7:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023ca:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023ce:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  80416023d2:	89 f8                	mov    %edi,%eax
  80416023d4:	83 e0 7f             	and    $0x7f,%eax
  80416023d7:	d3 e0                	shl    %cl,%eax
  80416023d9:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416023dc:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023df:	40 84 ff             	test   %dil,%dil
  80416023e2:	78 e3                	js     80416023c7 <function_by_info+0x208>
  return count;
  80416023e4:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  80416023e7:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  80416023ec:	41 39 f1             	cmp    %esi,%r9d
  80416023ef:	74 74                	je     8041602465 <function_by_info+0x2a6>
  result = 0;
  80416023f1:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023f4:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416023f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023fe:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602404:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602407:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160240b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160240e:	89 f0                	mov    %esi,%eax
  8041602410:	83 e0 7f             	and    $0x7f,%eax
  8041602413:	d3 e0                	shl    %cl,%eax
  8041602415:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602418:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160241b:	40 84 f6             	test   %sil,%sil
  804160241e:	78 e4                	js     8041602404 <function_by_info+0x245>
  return count;
  8041602420:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602423:	48 01 fb             	add    %rdi,%rbx
  8041602426:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602429:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160242e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602433:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602439:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160243c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602440:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602443:	89 f0                	mov    %esi,%eax
  8041602445:	83 e0 7f             	and    $0x7f,%eax
  8041602448:	d3 e0                	shl    %cl,%eax
  804160244a:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160244d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602450:	40 84 f6             	test   %sil,%sil
  8041602453:	78 e4                	js     8041602439 <function_by_info+0x27a>
  return count;
  8041602455:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602458:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  804160245b:	45 09 dc             	or     %r11d,%r12d
  804160245e:	75 91                	jne    80416023f1 <function_by_info+0x232>
  8041602460:	e9 10 ff ff ff       	jmpq   8041602375 <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  8041602465:	41 83 f8 2e          	cmp    $0x2e,%r8d
  8041602469:	0f 84 e9 00 00 00    	je     8041602558 <function_by_info+0x399>
            fn_name_entry = entry;
  804160246f:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602472:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602477:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160247c:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602482:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602485:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602489:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160248c:	89 f0                	mov    %esi,%eax
  804160248e:	83 e0 7f             	and    $0x7f,%eax
  8041602491:	d3 e0                	shl    %cl,%eax
  8041602493:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602496:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602499:	40 84 f6             	test   %sil,%sil
  804160249c:	78 e4                	js     8041602482 <function_by_info+0x2c3>
  return count;
  804160249e:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024a1:	48 01 fb             	add    %rdi,%rbx
  80416024a4:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024a7:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024b1:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024b7:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024ba:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024be:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024c1:	89 f0                	mov    %esi,%eax
  80416024c3:	83 e0 7f             	and    $0x7f,%eax
  80416024c6:	d3 e0                	shl    %cl,%eax
  80416024c8:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024cb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024ce:	40 84 f6             	test   %sil,%sil
  80416024d1:	78 e4                	js     80416024b7 <function_by_info+0x2f8>
  return count;
  80416024d3:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024d6:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  80416024d9:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416024df:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416024e4:	ba 00 00 00 00       	mov    $0x0,%edx
  80416024e9:	44 89 e6             	mov    %r12d,%esi
  80416024ec:	4c 89 f7             	mov    %r14,%rdi
  80416024ef:	41 ff d7             	callq  *%r15
        entry += count;
  80416024f2:	48 98                	cltq   
  80416024f4:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  80416024f7:	45 09 ec             	or     %r13d,%r12d
  80416024fa:	0f 85 6f ff ff ff    	jne    804160246f <function_by_info+0x2b0>
  while (entry < entry_end) {
  8041602500:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  8041602504:	0f 83 37 02 00 00    	jae    8041602741 <function_by_info+0x582>
                 uintptr_t *offset) {
  804160250a:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  804160250d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602512:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602517:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160251d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602520:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602524:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602527:	89 f0                	mov    %esi,%eax
  8041602529:	83 e0 7f             	and    $0x7f,%eax
  804160252c:	d3 e0                	shl    %cl,%eax
  804160252e:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602531:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602534:	40 84 f6             	test   %sil,%sil
  8041602537:	78 e4                	js     804160251d <function_by_info+0x35e>
  return count;
  8041602539:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  804160253c:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  804160253f:	45 85 c9             	test   %r9d,%r9d
  8041602542:	0f 85 1b fe ff ff    	jne    8041602363 <function_by_info+0x1a4>
  while (entry < entry_end) {
  8041602548:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  804160254c:	77 bc                	ja     804160250a <function_by_info+0x34b>
  return 0;
  804160254e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602553:	e9 de fc ff ff       	jmpq   8041602236 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  8041602558:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  804160255f:	00 
  8041602560:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8041602567:	00 
      unsigned name_form        = 0;
  8041602568:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  804160256f:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  8041602576:	00 
  8041602577:	eb 1d                	jmp    8041602596 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  8041602579:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160257f:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602584:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  8041602588:	44 89 ee             	mov    %r13d,%esi
  804160258b:	4c 89 f7             	mov    %r14,%rdi
  804160258e:	41 ff d7             	callq  *%r15
        entry += count;
  8041602591:	48 98                	cltq   
  8041602593:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  8041602596:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602599:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160259e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025a3:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416025a9:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025ac:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025b0:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025b3:	89 f0                	mov    %esi,%eax
  80416025b5:	83 e0 7f             	and    $0x7f,%eax
  80416025b8:	d3 e0                	shl    %cl,%eax
  80416025ba:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416025bd:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025c0:	40 84 f6             	test   %sil,%sil
  80416025c3:	78 e4                	js     80416025a9 <function_by_info+0x3ea>
  return count;
  80416025c5:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025c8:	48 01 fb             	add    %rdi,%rbx
  80416025cb:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025ce:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025d8:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416025de:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025e1:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025e5:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025e8:	89 f0                	mov    %esi,%eax
  80416025ea:	83 e0 7f             	and    $0x7f,%eax
  80416025ed:	d3 e0                	shl    %cl,%eax
  80416025ef:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416025f2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025f5:	40 84 f6             	test   %sil,%sil
  80416025f8:	78 e4                	js     80416025de <function_by_info+0x41f>
  return count;
  80416025fa:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025fd:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  8041602600:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602604:	0f 84 6f ff ff ff    	je     8041602579 <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  804160260a:	41 83 fc 12          	cmp    $0x12,%r12d
  804160260e:	0f 84 99 00 00 00    	je     80416026ad <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  8041602614:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602618:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  804160261b:	41 0f 44 c5          	cmove  %r13d,%eax
  804160261f:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  8041602622:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602626:	49 0f 44 c6          	cmove  %r14,%rax
  804160262a:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  804160262e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602634:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602639:	ba 00 00 00 00       	mov    $0x0,%edx
  804160263e:	44 89 ee             	mov    %r13d,%esi
  8041602641:	4c 89 f7             	mov    %r14,%rdi
  8041602644:	41 ff d7             	callq  *%r15
        entry += count;
  8041602647:	48 98                	cltq   
  8041602649:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160264c:	45 09 e5             	or     %r12d,%r13d
  804160264f:	0f 85 41 ff ff ff    	jne    8041602596 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  8041602655:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602659:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  8041602660:	48 39 d8             	cmp    %rbx,%rax
  8041602663:	0f 87 97 fe ff ff    	ja     8041602500 <function_by_info+0x341>
  8041602669:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  804160266d:	0f 82 8d fe ff ff    	jb     8041602500 <function_by_info+0x341>
        *offset = low_pc;
  8041602673:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  804160267a:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  804160267d:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  8041602681:	74 59                	je     80416026dc <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  8041602683:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602689:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  804160268c:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  8041602690:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  8041602693:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602697:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  804160269e:	00 00 00 
  80416026a1:	ff d0                	callq  *%rax
        return 0;
  80416026a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026a8:	e9 89 fb ff ff       	jmpq   8041602236 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  80416026ad:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026b3:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416026b8:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416026bc:	44 89 ee             	mov    %r13d,%esi
  80416026bf:	4c 89 f7             	mov    %r14,%rdi
  80416026c2:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  80416026c5:	41 83 fd 01          	cmp    $0x1,%r13d
  80416026c9:	0f 84 c2 fe ff ff    	je     8041602591 <function_by_info+0x3d2>
            high_pc += low_pc;
  80416026cf:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80416026d3:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  80416026d7:	e9 b5 fe ff ff       	jmpq   8041602591 <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  80416026dc:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  80416026e3:	00 
          count                    = dwarf_read_abbrev_entry(
  80416026e4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026ea:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416026ef:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  80416026f3:	be 0e 00 00 00       	mov    $0xe,%esi
  80416026f8:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  80416026fc:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  8041602703:	00 00 00 
  8041602706:	ff d0                	callq  *%rax
          if (buf &&
  8041602708:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  804160270c:	48 85 ff             	test   %rdi,%rdi
  804160270f:	74 92                	je     80416026a3 <function_by_info+0x4e4>
  8041602711:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  8041602715:	76 8c                	jbe    80416026a3 <function_by_info+0x4e4>
            put_unaligned(
  8041602717:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160271b:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  804160271f:	48 03 43 40          	add    0x40(%rbx),%rax
  8041602723:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602727:	ba 08 00 00 00       	mov    $0x8,%edx
  804160272c:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602730:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602737:	00 00 00 
  804160273a:	ff d0                	callq  *%rax
  804160273c:	e9 62 ff ff ff       	jmpq   80416026a3 <function_by_info+0x4e4>
  return 0;
  8041602741:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602746:	e9 eb fa ff ff       	jmpq   8041602236 <function_by_info+0x77>

000000804160274b <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  804160274b:	55                   	push   %rbp
  804160274c:	48 89 e5             	mov    %rsp,%rbp
  804160274f:	41 57                	push   %r15
  8041602751:	41 56                	push   %r14
  8041602753:	41 55                	push   %r13
  8041602755:	41 54                	push   %r12
  8041602757:	53                   	push   %rbx
  8041602758:	48 83 ec 48          	sub    $0x48,%rsp
  804160275c:	49 89 ff             	mov    %rdi,%r15
  804160275f:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  8041602763:	48 89 f7             	mov    %rsi,%rdi
  8041602766:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  804160276a:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const int flen = strlen(fname);
  804160276e:	48 b8 d1 c2 60 41 80 	movabs $0x804160c2d1,%rax
  8041602775:	00 00 00 
  8041602778:	ff d0                	callq  *%rax
  804160277a:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  804160277c:	85 c0                	test   %eax,%eax
  804160277e:	74 62                	je     80416027e2 <address_by_fname+0x97>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  8041602780:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  8041602784:	49 be 4a c5 60 41 80 	movabs $0x804160c54a,%r14
  804160278b:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  804160278e:	49 bf e0 c3 60 41 80 	movabs $0x804160c3e0,%r15
  8041602795:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  8041602798:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160279c:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  80416027a0:	0f 86 0b 04 00 00    	jbe    8041602bb1 <address_by_fname+0x466>
  80416027a6:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027ab:	4c 89 e6             	mov    %r12,%rsi
  80416027ae:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027b2:	41 ff d6             	callq  *%r14
  80416027b5:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416027b8:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416027bb:	76 52                	jbe    804160280f <address_by_fname+0xc4>
    if (initial_len == DW_EXT_DWARF64) {
  80416027bd:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416027c0:	74 31                	je     80416027f3 <address_by_fname+0xa8>
      cprintf("Unknown DWARF extension\n");
  80416027c2:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  80416027c9:	00 00 00 
  80416027cc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416027d1:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416027d8:	00 00 00 
  80416027db:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  80416027dd:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  80416027e2:	89 d8                	mov    %ebx,%eax
  80416027e4:	48 83 c4 48          	add    $0x48,%rsp
  80416027e8:	5b                   	pop    %rbx
  80416027e9:	41 5c                	pop    %r12
  80416027eb:	41 5d                	pop    %r13
  80416027ed:	41 5e                	pop    %r14
  80416027ef:	41 5f                	pop    %r15
  80416027f1:	5d                   	pop    %rbp
  80416027f2:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416027f3:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416027f8:	ba 08 00 00 00       	mov    $0x8,%edx
  80416027fd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602801:	41 ff d6             	callq  *%r14
  8041602804:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602808:	ba 0c 00 00 00       	mov    $0xc,%edx
  804160280d:	eb 07                	jmp    8041602816 <address_by_fname+0xcb>
    *len = initial_len;
  804160280f:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602811:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  8041602816:	48 63 d2             	movslq %edx,%rdx
  8041602819:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  804160281c:	4c 01 e0             	add    %r12,%rax
  804160281f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  8041602823:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602828:	4c 89 e6             	mov    %r12,%rsi
  804160282b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160282f:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  8041602832:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  8041602837:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160283c:	0f 85 be 00 00 00    	jne    8041602900 <address_by_fname+0x1b5>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602842:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602847:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160284b:	41 ff d6             	callq  *%r14
  804160284e:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041602851:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  8041602854:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602859:	ba 04 00 00 00       	mov    $0x4,%edx
  804160285e:	48 89 de             	mov    %rbx,%rsi
  8041602861:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602865:	41 ff d6             	callq  *%r14
  8041602868:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  804160286b:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602870:	83 fa ef             	cmp    $0xffffffef,%edx
  8041602873:	76 29                	jbe    804160289e <address_by_fname+0x153>
    if (initial_len == DW_EXT_DWARF64) {
  8041602875:	83 fa ff             	cmp    $0xffffffff,%edx
  8041602878:	0f 84 b7 00 00 00    	je     8041602935 <address_by_fname+0x1ea>
      cprintf("Unknown DWARF extension\n");
  804160287e:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041602885:	00 00 00 
  8041602888:	b8 00 00 00 00       	mov    $0x0,%eax
  804160288d:	48 b9 f2 91 60 41 80 	movabs $0x80416091f2,%rcx
  8041602894:	00 00 00 
  8041602897:	ff d1                	callq  *%rcx
      count = 0;
  8041602899:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  804160289e:	48 98                	cltq   
  80416028a0:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416028a4:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416028a8:	0f 86 ea fe ff ff    	jbe    8041602798 <address_by_fname+0x4d>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028ae:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028b3:	4c 89 e6             	mov    %r12,%rsi
  80416028b6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028ba:	41 ff d6             	callq  *%r14
  80416028bd:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416028c1:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416028c5:	4d 85 ed             	test   %r13,%r13
  80416028c8:	0f 84 ca fe ff ff    	je     8041602798 <address_by_fname+0x4d>
      if (!strcmp(fname, pubnames_entry)) {
  80416028ce:	4c 89 e6             	mov    %r12,%rsi
  80416028d1:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416028d5:	41 ff d7             	callq  *%r15
  80416028d8:	89 c3                	mov    %eax,%ebx
  80416028da:	85 c0                	test   %eax,%eax
  80416028dc:	74 72                	je     8041602950 <address_by_fname+0x205>
      pubnames_entry += strlen(pubnames_entry) + 1;
  80416028de:	4c 89 e7             	mov    %r12,%rdi
  80416028e1:	48 b8 d1 c2 60 41 80 	movabs $0x804160c2d1,%rax
  80416028e8:	00 00 00 
  80416028eb:	ff d0                	callq  *%rax
  80416028ed:	83 c0 01             	add    $0x1,%eax
  80416028f0:	48 98                	cltq   
  80416028f2:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416028f5:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416028f9:	77 b3                	ja     80416028ae <address_by_fname+0x163>
  80416028fb:	e9 98 fe ff ff       	jmpq   8041602798 <address_by_fname+0x4d>
    assert(version == 2);
  8041602900:	48 b9 1e d0 60 41 80 	movabs $0x804160d01e,%rcx
  8041602907:	00 00 00 
  804160290a:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041602911:	00 00 00 
  8041602914:	be 76 02 00 00       	mov    $0x276,%esi
  8041602919:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041602920:	00 00 00 
  8041602923:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602928:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160292f:	00 00 00 
  8041602932:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602935:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  804160293a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160293f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602943:	41 ff d6             	callq  *%r14
      count = 12;
  8041602946:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160294b:	e9 4e ff ff ff       	jmpq   804160289e <address_by_fname+0x153>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602950:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  8041602954:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602958:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  804160295c:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  8041602960:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602965:	4c 89 e6             	mov    %r12,%rsi
  8041602968:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160296c:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602973:	00 00 00 
  8041602976:	ff d0                	callq  *%rax
  8041602978:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160297b:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160297e:	0f 86 37 02 00 00    	jbe    8041602bbb <address_by_fname+0x470>
    if (initial_len == DW_EXT_DWARF64) {
  8041602984:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602987:	74 25                	je     80416029ae <address_by_fname+0x263>
      cprintf("Unknown DWARF extension\n");
  8041602989:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041602990:	00 00 00 
  8041602993:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602998:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160299f:	00 00 00 
  80416029a2:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416029a4:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416029a9:	e9 34 fe ff ff       	jmpq   80416027e2 <address_by_fname+0x97>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029ae:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416029b3:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029b8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029bc:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416029c3:	00 00 00 
  80416029c6:	ff d0                	callq  *%rax
      count = 12;
  80416029c8:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416029cd:	e9 ee 01 00 00       	jmpq   8041602bc0 <address_by_fname+0x475>
        assert(version == 4 || version == 2);
  80416029d2:	48 b9 0e d0 60 41 80 	movabs $0x804160d00e,%rcx
  80416029d9:	00 00 00 
  80416029dc:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416029e3:	00 00 00 
  80416029e6:	be 8c 02 00 00       	mov    $0x28c,%esi
  80416029eb:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  80416029f2:	00 00 00 
  80416029f5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029fa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a01:	00 00 00 
  8041602a04:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a07:	48 b9 db cf 60 41 80 	movabs $0x804160cfdb,%rcx
  8041602a0e:	00 00 00 
  8041602a11:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041602a18:	00 00 00 
  8041602a1b:	be 91 02 00 00       	mov    $0x291,%esi
  8041602a20:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041602a27:	00 00 00 
  8041602a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a2f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a36:	00 00 00 
  8041602a39:	41 ff d0             	callq  *%r8
        if (tag == DW_TAG_subprogram) {
  8041602a3c:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602a40:	0f 84 93 00 00 00    	je     8041602ad9 <address_by_fname+0x38e>
  count  = 0;
  8041602a46:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a48:	89 d9                	mov    %ebx,%ecx
  8041602a4a:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a4d:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602a53:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602a56:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a5a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602a5d:	89 f0                	mov    %esi,%eax
  8041602a5f:	83 e0 7f             	and    $0x7f,%eax
  8041602a62:	d3 e0                	shl    %cl,%eax
  8041602a64:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602a67:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a6a:	40 84 f6             	test   %sil,%sil
  8041602a6d:	78 e4                	js     8041602a53 <address_by_fname+0x308>
  return count;
  8041602a6f:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602a72:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602a75:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a77:	89 d9                	mov    %ebx,%ecx
  8041602a79:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a7c:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602a82:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602a85:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a89:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602a8c:	89 f0                	mov    %esi,%eax
  8041602a8e:	83 e0 7f             	and    $0x7f,%eax
  8041602a91:	d3 e0                	shl    %cl,%eax
  8041602a93:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602a96:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a99:	40 84 f6             	test   %sil,%sil
  8041602a9c:	78 e4                	js     8041602a82 <address_by_fname+0x337>
  return count;
  8041602a9e:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602aa1:	49 01 fc             	add    %rdi,%r12
            count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602aa4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602ab4:	44 89 ee             	mov    %r13d,%esi
  8041602ab7:	4c 89 ff             	mov    %r15,%rdi
  8041602aba:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  8041602ac1:	00 00 00 
  8041602ac4:	ff d0                	callq  *%rax
            entry += count;
  8041602ac6:	48 98                	cltq   
  8041602ac8:	49 01 c7             	add    %rax,%r15
          } while (name != 0 || form != 0);
  8041602acb:	45 09 f5             	or     %r14d,%r13d
  8041602ace:	0f 85 72 ff ff ff    	jne    8041602a46 <address_by_fname+0x2fb>
  8041602ad4:	e9 09 fd ff ff       	jmpq   80416027e2 <address_by_fname+0x97>
          uintptr_t low_pc = 0;
  8041602ad9:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602ae0:	00 
  8041602ae1:	eb 26                	jmp    8041602b09 <address_by_fname+0x3be>
              count = dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  8041602ae3:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602ae9:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602aee:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602af2:	44 89 f6             	mov    %r14d,%esi
  8041602af5:	4c 89 ff             	mov    %r15,%rdi
  8041602af8:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  8041602aff:	00 00 00 
  8041602b02:	ff d0                	callq  *%rax
            entry += count;
  8041602b04:	48 98                	cltq   
  8041602b06:	49 01 c7             	add    %rax,%r15
  count  = 0;
  8041602b09:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b0b:	89 d9                	mov    %ebx,%ecx
  8041602b0d:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b10:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602b16:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b19:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b1d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b20:	89 f0                	mov    %esi,%eax
  8041602b22:	83 e0 7f             	and    $0x7f,%eax
  8041602b25:	d3 e0                	shl    %cl,%eax
  8041602b27:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602b2a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b2d:	40 84 f6             	test   %sil,%sil
  8041602b30:	78 e4                	js     8041602b16 <address_by_fname+0x3cb>
  return count;
  8041602b32:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b35:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602b38:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b3a:	89 d9                	mov    %ebx,%ecx
  8041602b3c:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b3f:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602b45:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b48:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b4c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b4f:	89 f0                	mov    %esi,%eax
  8041602b51:	83 e0 7f             	and    $0x7f,%eax
  8041602b54:	d3 e0                	shl    %cl,%eax
  8041602b56:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602b59:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b5c:	40 84 f6             	test   %sil,%sil
  8041602b5f:	78 e4                	js     8041602b45 <address_by_fname+0x3fa>
  return count;
  8041602b61:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b64:	49 01 fc             	add    %rdi,%r12
            if (name == DW_AT_low_pc) {
  8041602b67:	41 83 fd 11          	cmp    $0x11,%r13d
  8041602b6b:	0f 84 72 ff ff ff    	je     8041602ae3 <address_by_fname+0x398>
              count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602b71:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b77:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602b81:	44 89 f6             	mov    %r14d,%esi
  8041602b84:	4c 89 ff             	mov    %r15,%rdi
  8041602b87:	48 b8 1f 0d 60 41 80 	movabs $0x8041600d1f,%rax
  8041602b8e:	00 00 00 
  8041602b91:	ff d0                	callq  *%rax
            entry += count;
  8041602b93:	48 98                	cltq   
  8041602b95:	49 01 c7             	add    %rax,%r15
          } while (name || form);
  8041602b98:	45 09 ee             	or     %r13d,%r14d
  8041602b9b:	0f 85 68 ff ff ff    	jne    8041602b09 <address_by_fname+0x3be>
          *offset = low_pc;
  8041602ba1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041602ba5:	48 8b 7d 98          	mov    -0x68(%rbp),%rdi
  8041602ba9:	48 89 07             	mov    %rax,(%rdi)
  8041602bac:	e9 31 fc ff ff       	jmpq   80416027e2 <address_by_fname+0x97>
  return 0;
  8041602bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602bb6:	e9 27 fc ff ff       	jmpq   80416027e2 <address_by_fname+0x97>
  count       = 4;
  8041602bbb:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  8041602bc0:	48 98                	cltq   
  8041602bc2:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602bc6:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602bcb:	4c 89 ee             	mov    %r13,%rsi
  8041602bce:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bd2:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602bd9:	00 00 00 
  8041602bdc:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602bde:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  8041602be2:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602be6:	83 e8 02             	sub    $0x2,%eax
  8041602be9:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602bed:	0f 85 df fd ff ff    	jne    80416029d2 <address_by_fname+0x287>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602bf3:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602bf8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bfc:	49 be 4a c5 60 41 80 	movabs $0x804160c54a,%r14
  8041602c03:	00 00 00 
  8041602c06:	41 ff d6             	callq  *%r14
  8041602c09:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602c0d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c11:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  8041602c14:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602c18:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602c1d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c21:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  8041602c24:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602c28:	0f 85 d9 fd ff ff    	jne    8041602a07 <address_by_fname+0x2bc>
  count  = 0;
  8041602c2e:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602c30:	89 d9                	mov    %ebx,%ecx
  8041602c32:	4c 89 fa             	mov    %r15,%rdx
  result = 0;
  8041602c35:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602c3b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602c3e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c42:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602c45:	89 f0                	mov    %esi,%eax
  8041602c47:	83 e0 7f             	and    $0x7f,%eax
  8041602c4a:	d3 e0                	shl    %cl,%eax
  8041602c4c:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602c4f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c52:	40 84 f6             	test   %sil,%sil
  8041602c55:	78 e4                	js     8041602c3b <address_by_fname+0x4f0>
  return count;
  8041602c57:	48 63 ff             	movslq %edi,%rdi
        entry += count;
  8041602c5a:	49 01 ff             	add    %rdi,%r15
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c5d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c61:	4c 8b 58 08          	mov    0x8(%rax),%r11
        unsigned name = 0, form = 0, tag = 0;
  8041602c65:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c6b:	4d 39 e3             	cmp    %r12,%r11
  8041602c6e:	0f 86 c8 fd ff ff    	jbe    8041602a3c <address_by_fname+0x2f1>
  count  = 0;
  8041602c74:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602c77:	89 d9                	mov    %ebx,%ecx
  8041602c79:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602c7c:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602c81:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602c84:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c88:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602c8c:	89 f8                	mov    %edi,%eax
  8041602c8e:	83 e0 7f             	and    $0x7f,%eax
  8041602c91:	d3 e0                	shl    %cl,%eax
  8041602c93:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602c95:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c98:	40 84 ff             	test   %dil,%dil
  8041602c9b:	78 e4                	js     8041602c81 <address_by_fname+0x536>
  return count;
  8041602c9d:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry += count;
  8041602ca0:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602ca3:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602ca6:	89 d9                	mov    %ebx,%ecx
  8041602ca8:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602cab:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602cb1:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602cb4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cb8:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cbc:	89 f8                	mov    %edi,%eax
  8041602cbe:	83 e0 7f             	and    $0x7f,%eax
  8041602cc1:	d3 e0                	shl    %cl,%eax
  8041602cc3:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602cc6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cc9:	40 84 ff             	test   %dil,%dil
  8041602ccc:	78 e3                	js     8041602cb1 <address_by_fname+0x566>
  return count;
  8041602cce:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry++;
  8041602cd1:	4f 8d 64 04 01       	lea    0x1(%r12,%r8,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602cd6:	41 39 f2             	cmp    %esi,%r10d
  8041602cd9:	0f 84 5d fd ff ff    	je     8041602a3c <address_by_fname+0x2f1>
  count  = 0;
  8041602cdf:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602ce2:	89 d9                	mov    %ebx,%ecx
  8041602ce4:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602ce7:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602cec:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602cef:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cf3:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cf7:	89 f0                	mov    %esi,%eax
  8041602cf9:	83 e0 7f             	and    $0x7f,%eax
  8041602cfc:	d3 e0                	shl    %cl,%eax
  8041602cfe:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602d00:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d03:	40 84 f6             	test   %sil,%sil
  8041602d06:	78 e4                	js     8041602cec <address_by_fname+0x5a1>
  return count;
  8041602d08:	4d 63 c0             	movslq %r8d,%r8
            abbrev_entry += count;
  8041602d0b:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602d0e:	41 89 dd             	mov    %ebx,%r13d
  shift  = 0;
  8041602d11:	89 d9                	mov    %ebx,%ecx
  8041602d13:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d16:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d1c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d1f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d23:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041602d27:	89 f0                	mov    %esi,%eax
  8041602d29:	83 e0 7f             	and    $0x7f,%eax
  8041602d2c:	d3 e0                	shl    %cl,%eax
  8041602d2e:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602d31:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d34:	40 84 f6             	test   %sil,%sil
  8041602d37:	78 e3                	js     8041602d1c <address_by_fname+0x5d1>
  return count;
  8041602d39:	4d 63 ed             	movslq %r13d,%r13
            abbrev_entry += count;
  8041602d3c:	4d 01 ec             	add    %r13,%r12
          } while (name != 0 || form != 0);
  8041602d3f:	41 09 f8             	or     %edi,%r8d
  8041602d42:	75 9b                	jne    8041602cdf <address_by_fname+0x594>
  8041602d44:	e9 22 ff ff ff       	jmpq   8041602c6b <address_by_fname+0x520>

0000008041602d49 <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602d49:	55                   	push   %rbp
  8041602d4a:	48 89 e5             	mov    %rsp,%rbp
  8041602d4d:	41 57                	push   %r15
  8041602d4f:	41 56                	push   %r14
  8041602d51:	41 55                	push   %r13
  8041602d53:	41 54                	push   %r12
  8041602d55:	53                   	push   %rbx
  8041602d56:	48 83 ec 48          	sub    $0x48,%rsp
  8041602d5a:	48 89 fb             	mov    %rdi,%rbx
  8041602d5d:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602d61:	48 89 f7             	mov    %rsi,%rdi
  8041602d64:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602d68:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602d6c:	48 b8 d1 c2 60 41 80 	movabs $0x804160c2d1,%rax
  8041602d73:	00 00 00 
  8041602d76:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602d78:	85 c0                	test   %eax,%eax
  8041602d7a:	0f 84 73 03 00 00    	je     80416030f3 <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602d80:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602d84:	e9 0f 03 00 00       	jmpq   8041603098 <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602d89:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602d8d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602d92:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602d96:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602d9d:	00 00 00 
  8041602da0:	ff d0                	callq  *%rax
  8041602da2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602da6:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602dab:	eb 07                	jmp    8041602db4 <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602dad:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602daf:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602db4:	48 63 db             	movslq %ebx,%rbx
  8041602db7:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602dbb:	4c 01 e8             	add    %r13,%rax
  8041602dbe:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602dc2:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602dc7:	4c 89 ee             	mov    %r13,%rsi
  8041602dca:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602dce:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041602dd5:	00 00 00 
  8041602dd8:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602dda:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602dde:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602de2:	83 e8 02             	sub    $0x2,%eax
  8041602de5:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602de9:	75 52                	jne    8041602e3d <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602deb:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602df0:	4c 89 ee             	mov    %r13,%rsi
  8041602df3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602df7:	49 be 4a c5 60 41 80 	movabs $0x804160c54a,%r14
  8041602dfe:	00 00 00 
  8041602e01:	41 ff d6             	callq  *%r14
  8041602e04:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602e08:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602e0d:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602e11:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602e16:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e1a:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602e1d:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602e21:	75 4f                	jne    8041602e72 <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602e23:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e27:	4c 03 20             	add    (%rax),%r12
  8041602e2a:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602e2e:	49 be 1f 0d 60 41 80 	movabs $0x8041600d1f,%r14
  8041602e35:	00 00 00 
    while (entry < entry_end) {
  8041602e38:	e9 11 02 00 00       	jmpq   804160304e <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602e3d:	48 b9 0e d0 60 41 80 	movabs $0x804160d00e,%rcx
  8041602e44:	00 00 00 
  8041602e47:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041602e4e:	00 00 00 
  8041602e51:	be f1 02 00 00       	mov    $0x2f1,%esi
  8041602e56:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041602e5d:	00 00 00 
  8041602e60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e65:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602e6c:	00 00 00 
  8041602e6f:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602e72:	48 b9 db cf 60 41 80 	movabs $0x804160cfdb,%rcx
  8041602e79:	00 00 00 
  8041602e7c:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041602e83:	00 00 00 
  8041602e86:	be f5 02 00 00       	mov    $0x2f5,%esi
  8041602e8b:	48 bf ce cf 60 41 80 	movabs $0x804160cfce,%rdi
  8041602e92:	00 00 00 
  8041602e95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e9a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602ea1:	00 00 00 
  8041602ea4:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602ea7:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602eab:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602eaf:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602eb3:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602eb9:	49 39 db             	cmp    %rbx,%r11
  8041602ebc:	0f 86 e7 00 00 00    	jbe    8041602fa9 <naive_address_by_fname+0x260>
  8041602ec2:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ec5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602ecb:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602ed0:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602ed5:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602ed8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602edc:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602ee0:	89 f8                	mov    %edi,%eax
  8041602ee2:	83 e0 7f             	and    $0x7f,%eax
  8041602ee5:	d3 e0                	shl    %cl,%eax
  8041602ee7:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602ee9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602eec:	40 84 ff             	test   %dil,%dil
  8041602eef:	78 e4                	js     8041602ed5 <naive_address_by_fname+0x18c>
  return count;
  8041602ef1:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602ef4:	4c 01 c3             	add    %r8,%rbx
  8041602ef7:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602efa:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602f00:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f05:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602f0b:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f0e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f12:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f16:	89 f8                	mov    %edi,%eax
  8041602f18:	83 e0 7f             	and    $0x7f,%eax
  8041602f1b:	d3 e0                	shl    %cl,%eax
  8041602f1d:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602f20:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f23:	40 84 ff             	test   %dil,%dil
  8041602f26:	78 e3                	js     8041602f0b <naive_address_by_fname+0x1c2>
  return count;
  8041602f28:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602f2b:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602f30:	41 39 f2             	cmp    %esi,%r10d
  8041602f33:	74 74                	je     8041602fa9 <naive_address_by_fname+0x260>
  result = 0;
  8041602f35:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f38:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f42:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602f48:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f4b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f4f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f52:	89 f0                	mov    %esi,%eax
  8041602f54:	83 e0 7f             	and    $0x7f,%eax
  8041602f57:	d3 e0                	shl    %cl,%eax
  8041602f59:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602f5c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f5f:	40 84 f6             	test   %sil,%sil
  8041602f62:	78 e4                	js     8041602f48 <naive_address_by_fname+0x1ff>
  return count;
  8041602f64:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f67:	48 01 fb             	add    %rdi,%rbx
  8041602f6a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f6d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f72:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f77:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602f7d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f80:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f84:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f87:	89 f0                	mov    %esi,%eax
  8041602f89:	83 e0 7f             	and    $0x7f,%eax
  8041602f8c:	d3 e0                	shl    %cl,%eax
  8041602f8e:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602f91:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f94:	40 84 f6             	test   %sil,%sil
  8041602f97:	78 e4                	js     8041602f7d <naive_address_by_fname+0x234>
  return count;
  8041602f99:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f9c:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  8041602f9f:	45 09 c4             	or     %r8d,%r12d
  8041602fa2:	75 91                	jne    8041602f35 <naive_address_by_fname+0x1ec>
  8041602fa4:	e9 10 ff ff ff       	jmpq   8041602eb9 <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602fa9:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602fad:	0f 84 4f 01 00 00    	je     8041603102 <naive_address_by_fname+0x3b9>
  8041602fb3:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602fb7:	0f 84 45 01 00 00    	je     8041603102 <naive_address_by_fname+0x3b9>
                found = 1;
  8041602fbd:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fc0:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fca:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602fd0:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fd3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602fd7:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602fda:	89 f0                	mov    %esi,%eax
  8041602fdc:	83 e0 7f             	and    $0x7f,%eax
  8041602fdf:	d3 e0                	shl    %cl,%eax
  8041602fe1:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602fe4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602fe7:	40 84 f6             	test   %sil,%sil
  8041602fea:	78 e4                	js     8041602fd0 <naive_address_by_fname+0x287>
  return count;
  8041602fec:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  8041602fef:	48 01 fb             	add    %rdi,%rbx
  8041602ff2:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ff5:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602ffa:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fff:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603005:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603008:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160300c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160300f:	89 f0                	mov    %esi,%eax
  8041603011:	83 e0 7f             	and    $0x7f,%eax
  8041603014:	d3 e0                	shl    %cl,%eax
  8041603016:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041603019:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160301c:	40 84 f6             	test   %sil,%sil
  804160301f:	78 e4                	js     8041603005 <naive_address_by_fname+0x2bc>
  return count;
  8041603021:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  8041603024:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041603027:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160302d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603032:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603037:	44 89 e6             	mov    %r12d,%esi
  804160303a:	4c 89 ff             	mov    %r15,%rdi
  804160303d:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  8041603040:	48 98                	cltq   
  8041603042:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603045:	45 09 ec             	or     %r13d,%r12d
  8041603048:	0f 85 6f ff ff ff    	jne    8041602fbd <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  804160304e:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  8041603052:	73 44                	jae    8041603098 <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  8041603054:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  8041603057:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160305c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603061:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041603067:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160306a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160306e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603071:	89 f0                	mov    %esi,%eax
  8041603073:	83 e0 7f             	and    $0x7f,%eax
  8041603076:	d3 e0                	shl    %cl,%eax
  8041603078:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  804160307b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160307e:	40 84 f6             	test   %sil,%sil
  8041603081:	78 e4                	js     8041603067 <naive_address_by_fname+0x31e>
  return count;
  8041603083:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  8041603086:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  8041603089:	45 85 d2             	test   %r10d,%r10d
  804160308c:	0f 85 15 fe ff ff    	jne    8041602ea7 <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  8041603092:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  8041603096:	77 bc                	ja     8041603054 <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  8041603098:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160309c:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  80416030a0:	0f 86 ee 01 00 00    	jbe    8041603294 <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  80416030a6:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030ab:	4c 89 fe             	mov    %r15,%rsi
  80416030ae:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030b2:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416030b9:	00 00 00 
  80416030bc:	ff d0                	callq  *%rax
  80416030be:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416030c1:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416030c4:	0f 86 e3 fc ff ff    	jbe    8041602dad <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  80416030ca:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416030cd:	0f 84 b6 fc ff ff    	je     8041602d89 <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  80416030d3:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  80416030da:	00 00 00 
  80416030dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416030e2:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416030e9:	00 00 00 
  80416030ec:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  80416030ee:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  80416030f3:	48 83 c4 48          	add    $0x48,%rsp
  80416030f7:	5b                   	pop    %rbx
  80416030f8:	41 5c                	pop    %r12
  80416030fa:	41 5d                	pop    %r13
  80416030fc:	41 5e                	pop    %r14
  80416030fe:	41 5f                	pop    %r15
  8041603100:	5d                   	pop    %rbp
  8041603101:	c3                   	retq   
        uintptr_t low_pc = 0;
  8041603102:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041603109:	00 
        int found        = 0;
  804160310a:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041603111:	eb 21                	jmp    8041603134 <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  8041603113:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603119:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160311e:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041603122:	44 89 ee             	mov    %r13d,%esi
  8041603125:	4c 89 ff             	mov    %r15,%rdi
  8041603128:	41 ff d6             	callq  *%r14
  804160312b:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  804160312e:	49 63 c4             	movslq %r12d,%rax
  8041603131:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  8041603134:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603137:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160313c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603141:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603147:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160314a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160314e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603151:	89 f0                	mov    %esi,%eax
  8041603153:	83 e0 7f             	and    $0x7f,%eax
  8041603156:	d3 e0                	shl    %cl,%eax
  8041603158:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160315b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160315e:	40 84 f6             	test   %sil,%sil
  8041603161:	78 e4                	js     8041603147 <naive_address_by_fname+0x3fe>
  return count;
  8041603163:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041603166:	48 01 fb             	add    %rdi,%rbx
  8041603169:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160316c:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603171:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603176:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160317c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160317f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603183:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603186:	89 f0                	mov    %esi,%eax
  8041603188:	83 e0 7f             	and    $0x7f,%eax
  804160318b:	d3 e0                	shl    %cl,%eax
  804160318d:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041603190:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603193:	40 84 f6             	test   %sil,%sil
  8041603196:	78 e4                	js     804160317c <naive_address_by_fname+0x433>
  return count;
  8041603198:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  804160319b:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  804160319e:	41 83 fc 11          	cmp    $0x11,%r12d
  80416031a2:	0f 84 6b ff ff ff    	je     8041603113 <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  80416031a8:	41 83 fc 03          	cmp    $0x3,%r12d
  80416031ac:	0f 85 9c 00 00 00    	jne    804160324e <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  80416031b2:	41 83 fd 0e          	cmp    $0xe,%r13d
  80416031b6:	74 42                	je     80416031fa <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  80416031b8:	4c 89 fe             	mov    %r15,%rsi
  80416031bb:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416031bf:	48 b8 e0 c3 60 41 80 	movabs $0x804160c3e0,%rax
  80416031c6:	00 00 00 
  80416031c9:	ff d0                	callq  *%rax
                found = 1;
  80416031cb:	85 c0                	test   %eax,%eax
  80416031cd:	b8 01 00 00 00       	mov    $0x1,%eax
  80416031d2:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  80416031d6:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  80416031d9:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416031df:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416031e4:	ba 00 00 00 00       	mov    $0x0,%edx
  80416031e9:	44 89 ee             	mov    %r13d,%esi
  80416031ec:	4c 89 ff             	mov    %r15,%rdi
  80416031ef:	41 ff d6             	callq  *%r14
  80416031f2:	41 89 c4             	mov    %eax,%r12d
  80416031f5:	e9 34 ff ff ff       	jmpq   804160312e <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  80416031fa:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041603201:	00 
              count          = dwarf_read_abbrev_entry(
  8041603202:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603208:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160320d:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041603211:	be 0e 00 00 00       	mov    $0xe,%esi
  8041603216:	4c 89 ff             	mov    %r15,%rdi
  8041603219:	41 ff d6             	callq  *%r14
  804160321c:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  804160321f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041603223:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603227:	48 03 70 40          	add    0x40(%rax),%rsi
  804160322b:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  804160322f:	48 b8 e0 c3 60 41 80 	movabs $0x804160c3e0,%rax
  8041603236:	00 00 00 
  8041603239:	ff d0                	callq  *%rax
                found = 1;
  804160323b:	85 c0                	test   %eax,%eax
  804160323d:	b8 01 00 00 00       	mov    $0x1,%eax
  8041603242:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603246:	89 45 bc             	mov    %eax,-0x44(%rbp)
  8041603249:	e9 e0 fe ff ff       	jmpq   804160312e <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  804160324e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603254:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603259:	ba 00 00 00 00       	mov    $0x0,%edx
  804160325e:	44 89 ee             	mov    %r13d,%esi
  8041603261:	4c 89 ff             	mov    %r15,%rdi
  8041603264:	41 ff d6             	callq  *%r14
          entry += count;
  8041603267:	48 98                	cltq   
  8041603269:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  804160326c:	45 09 e5             	or     %r12d,%r13d
  804160326f:	0f 85 bf fe ff ff    	jne    8041603134 <naive_address_by_fname+0x3eb>
        if (found) {
  8041603275:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  8041603279:	0f 84 cf fd ff ff    	je     804160304e <naive_address_by_fname+0x305>
          *offset = low_pc;
  804160327f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041603283:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  8041603287:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  804160328a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160328f:	e9 5f fe ff ff       	jmpq   80416030f3 <naive_address_by_fname+0x3aa>
  return 0;
  8041603294:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603299:	e9 55 fe ff ff       	jmpq   80416030f3 <naive_address_by_fname+0x3aa>

000000804160329e <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  804160329e:	55                   	push   %rbp
  804160329f:	48 89 e5             	mov    %rsp,%rbp
  80416032a2:	41 57                	push   %r15
  80416032a4:	41 56                	push   %r14
  80416032a6:	41 55                	push   %r13
  80416032a8:	41 54                	push   %r12
  80416032aa:	53                   	push   %rbx
  80416032ab:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  80416032af:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  80416032b3:	48 8b 47 38          	mov    0x38(%rdi),%rax
  80416032b7:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  80416032ba:	48 39 d0             	cmp    %rdx,%rax
  80416032bd:	0f 82 d9 06 00 00    	jb     804160399c <line_for_address+0x6fe>
  80416032c3:	48 85 c9             	test   %rcx,%rcx
  80416032c6:	0f 84 d0 06 00 00    	je     804160399c <line_for_address+0x6fe>
  80416032cc:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  80416032d0:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  80416032d4:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  80416032d7:	ba 04 00 00 00       	mov    $0x4,%edx
  80416032dc:	48 89 de             	mov    %rbx,%rsi
  80416032df:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416032e3:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416032ea:	00 00 00 
  80416032ed:	ff d0                	callq  *%rax
  80416032ef:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416032f2:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416032f5:	76 4e                	jbe    8041603345 <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  80416032f7:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416032fa:	74 25                	je     8041603321 <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  80416032fc:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  8041603303:	00 00 00 
  8041603306:	b8 00 00 00 00       	mov    $0x0,%eax
  804160330b:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041603312:	00 00 00 
  8041603315:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041603317:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  804160331c:	e9 6c 06 00 00       	jmpq   804160398d <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603321:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041603325:	ba 08 00 00 00       	mov    $0x8,%edx
  804160332a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160332e:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041603335:	00 00 00 
  8041603338:	ff d0                	callq  *%rax
  804160333a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160333e:	be 0c 00 00 00       	mov    $0xc,%esi
  8041603343:	eb 07                	jmp    804160334c <line_for_address+0xae>
    *len = initial_len;
  8041603345:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041603347:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  804160334c:	48 63 f6             	movslq %esi,%rsi
  804160334f:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  8041603352:	48 01 d8             	add    %rbx,%rax
  8041603355:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  8041603359:	ba 02 00 00 00       	mov    $0x2,%edx
  804160335e:	48 89 de             	mov    %rbx,%rsi
  8041603361:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603365:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160336c:	00 00 00 
  804160336f:	ff d0                	callq  *%rax
  8041603371:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  8041603376:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  804160337a:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  804160337e:	66 83 f8 02          	cmp    $0x2,%ax
  8041603382:	77 51                	ja     80416033d5 <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  8041603384:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603389:	4c 89 e6             	mov    %r12,%rsi
  804160338c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603390:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041603397:	00 00 00 
  804160339a:	ff d0                	callq  *%rax
  804160339c:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416033a0:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  80416033a4:	0f 86 84 00 00 00    	jbe    804160342e <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  80416033aa:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  80416033ae:	74 5a                	je     804160340a <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  80416033b0:	48 bf a0 cf 60 41 80 	movabs $0x804160cfa0,%rdi
  80416033b7:	00 00 00 
  80416033ba:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033bf:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416033c6:	00 00 00 
  80416033c9:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416033cb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416033d0:	e9 b8 05 00 00       	jmpq   804160398d <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  80416033d5:	48 b9 c8 d1 60 41 80 	movabs $0x804160d1c8,%rcx
  80416033dc:	00 00 00 
  80416033df:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416033e6:	00 00 00 
  80416033e9:	be fc 00 00 00       	mov    $0xfc,%esi
  80416033ee:	48 bf 81 d1 60 41 80 	movabs $0x804160d181,%rdi
  80416033f5:	00 00 00 
  80416033f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033fd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603404:	00 00 00 
  8041603407:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160340a:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  804160340e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603413:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603417:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160341e:	00 00 00 
  8041603421:	ff d0                	callq  *%rax
  8041603423:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  8041603427:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160342c:	eb 08                	jmp    8041603436 <line_for_address+0x198>
    *len = initial_len;
  804160342e:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  8041603431:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  8041603436:	48 98                	cltq   
  8041603438:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  804160343b:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  804160343e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603443:	4c 89 e6             	mov    %r12,%rsi
  8041603446:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160344a:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041603451:	00 00 00 
  8041603454:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  8041603456:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160345a:	0f 85 89 00 00 00    	jne    80416034e9 <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  8041603460:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  8041603465:	66 41 83 ff 04       	cmp    $0x4,%r15w
  804160346a:	0f 84 ae 00 00 00    	je     804160351e <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  8041603470:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  8041603474:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603479:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160347d:	49 bc 4a c5 60 41 80 	movabs $0x804160c54a,%r12
  8041603484:	00 00 00 
  8041603487:	41 ff d4             	callq  *%r12
  804160348a:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  804160348e:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  8041603491:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  8041603495:	ba 01 00 00 00       	mov    $0x1,%edx
  804160349a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160349e:	41 ff d4             	callq  *%r12
  80416034a1:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034a5:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034a8:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  80416034ac:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034b1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034b5:	41 ff d4             	callq  *%r12
  80416034b8:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034bc:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034bf:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  80416034c3:	ba 08 00 00 00       	mov    $0x8,%edx
  80416034c8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034cc:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  80416034cf:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  80416034d3:	0f 86 90 04 00 00    	jbe    8041603969 <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  80416034d9:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  80416034df:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416034e4:	e9 32 04 00 00       	jmpq   804160391b <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  80416034e9:	48 b9 f8 d1 60 41 80 	movabs $0x804160d1f8,%rcx
  80416034f0:	00 00 00 
  80416034f3:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416034fa:	00 00 00 
  80416034fd:	be 07 01 00 00       	mov    $0x107,%esi
  8041603502:	48 bf 81 d1 60 41 80 	movabs $0x804160d181,%rdi
  8041603509:	00 00 00 
  804160350c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603511:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603518:	00 00 00 
  804160351b:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  804160351e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603523:	48 89 de             	mov    %rbx,%rsi
  8041603526:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160352a:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041603531:	00 00 00 
  8041603534:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  8041603536:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  804160353b:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160353f:	0f 84 2b ff ff ff    	je     8041603470 <line_for_address+0x1d2>
  8041603545:	48 b9 18 d2 60 41 80 	movabs $0x804160d218,%rcx
  804160354c:	00 00 00 
  804160354f:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041603556:	00 00 00 
  8041603559:	be 11 01 00 00       	mov    $0x111,%esi
  804160355e:	48 bf 81 d1 60 41 80 	movabs $0x804160d181,%rdi
  8041603565:	00 00 00 
  8041603568:	b8 00 00 00 00       	mov    $0x0,%eax
  804160356d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603574:	00 00 00 
  8041603577:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  804160357a:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  804160357d:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  8041603583:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603588:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  804160358e:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  8041603591:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603595:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041603599:	89 fa                	mov    %edi,%edx
  804160359b:	83 e2 7f             	and    $0x7f,%edx
  804160359e:	d3 e2                	shl    %cl,%edx
  80416035a0:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  80416035a3:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416035a6:	40 84 ff             	test   %dil,%dil
  80416035a9:	78 e3                	js     804160358e <line_for_address+0x2f0>
  return count;
  80416035ab:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  80416035ae:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  80416035b1:	45 89 ff             	mov    %r15d,%r15d
  80416035b4:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  80416035b7:	ba 01 00 00 00       	mov    $0x1,%edx
  80416035bc:	4c 89 ee             	mov    %r13,%rsi
  80416035bf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416035c3:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416035ca:	00 00 00 
  80416035cd:	ff d0                	callq  *%rax
  80416035cf:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  80416035d3:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  80416035d7:	3c 02                	cmp    $0x2,%al
  80416035d9:	0f 84 dc 00 00 00    	je     80416036bb <line_for_address+0x41d>
  80416035df:	76 39                	jbe    804160361a <line_for_address+0x37c>
  80416035e1:	3c 03                	cmp    $0x3,%al
  80416035e3:	74 62                	je     8041603647 <line_for_address+0x3a9>
  80416035e5:	3c 04                	cmp    $0x4,%al
  80416035e7:	0f 85 0c 01 00 00    	jne    80416036f9 <line_for_address+0x45b>
  80416035ed:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416035f0:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416035f5:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416035f8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416035fc:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416035ff:	84 c9                	test   %cl,%cl
  8041603601:	78 f2                	js     80416035f5 <line_for_address+0x357>
  return count;
  8041603603:	48 98                	cltq   
          program_addr += count;
  8041603605:	48 01 c6             	add    %rax,%rsi
  8041603608:	44 89 e2             	mov    %r12d,%edx
  804160360b:	48 89 d8             	mov    %rbx,%rax
  804160360e:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603612:	4c 89 f3             	mov    %r14,%rbx
  8041603615:	e9 c8 00 00 00       	jmpq   80416036e2 <line_for_address+0x444>
      switch (opcode) {
  804160361a:	3c 01                	cmp    $0x1,%al
  804160361c:	0f 85 d7 00 00 00    	jne    80416036f9 <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  8041603622:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603626:	49 39 c6             	cmp    %rax,%r14
  8041603629:	0f 87 f8 00 00 00    	ja     8041603727 <line_for_address+0x489>
  804160362f:	48 39 d8             	cmp    %rbx,%rax
  8041603632:	0f 82 39 03 00 00    	jb     8041603971 <line_for_address+0x6d3>
          state->line          = 1;
  8041603638:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  804160363d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603642:	e9 9b 00 00 00       	jmpq   80416036e2 <line_for_address+0x444>
          while (*(char *)program_addr) {
  8041603647:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  804160364c:	74 09                	je     8041603657 <line_for_address+0x3b9>
            ++program_addr;
  804160364e:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  8041603652:	80 3e 00             	cmpb   $0x0,(%rsi)
  8041603655:	75 f7                	jne    804160364e <line_for_address+0x3b0>
          ++program_addr;
  8041603657:	48 83 c6 01          	add    $0x1,%rsi
  804160365b:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160365e:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603663:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603666:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160366a:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160366d:	84 c9                	test   %cl,%cl
  804160366f:	78 f2                	js     8041603663 <line_for_address+0x3c5>
  return count;
  8041603671:	48 98                	cltq   
          program_addr += count;
  8041603673:	48 01 c6             	add    %rax,%rsi
  8041603676:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603679:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  804160367e:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603681:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603685:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603688:	84 c9                	test   %cl,%cl
  804160368a:	78 f2                	js     804160367e <line_for_address+0x3e0>
  return count;
  804160368c:	48 98                	cltq   
          program_addr += count;
  804160368e:	48 01 c6             	add    %rax,%rsi
  8041603691:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603694:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603699:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160369c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036a0:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036a3:	84 c9                	test   %cl,%cl
  80416036a5:	78 f2                	js     8041603699 <line_for_address+0x3fb>
  return count;
  80416036a7:	48 98                	cltq   
          program_addr += count;
  80416036a9:	48 01 c6             	add    %rax,%rsi
  80416036ac:	44 89 e2             	mov    %r12d,%edx
  80416036af:	48 89 d8             	mov    %rbx,%rax
  80416036b2:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036b6:	4c 89 f3             	mov    %r14,%rbx
  80416036b9:	eb 27                	jmp    80416036e2 <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  80416036bb:	ba 08 00 00 00       	mov    $0x8,%edx
  80416036c0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416036c4:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  80416036cb:	00 00 00 
  80416036ce:	ff d0                	callq  *%rax
  80416036d0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  80416036d4:	49 8d 75 09          	lea    0x9(%r13),%rsi
  80416036d8:	44 89 e2             	mov    %r12d,%edx
  80416036db:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036df:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  80416036e2:	49 39 f7             	cmp    %rsi,%r15
  80416036e5:	75 4c                	jne    8041603733 <line_for_address+0x495>
  80416036e7:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416036eb:	41 89 d4             	mov    %edx,%r12d
  80416036ee:	49 89 de             	mov    %rbx,%r14
  80416036f1:	48 89 c3             	mov    %rax,%rbx
  80416036f4:	e9 19 02 00 00       	jmpq   8041603912 <line_for_address+0x674>
      switch (opcode) {
  80416036f9:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  80416036fc:	48 ba 94 d1 60 41 80 	movabs $0x804160d194,%rdx
  8041603703:	00 00 00 
  8041603706:	be 6b 00 00 00       	mov    $0x6b,%esi
  804160370b:	48 bf 81 d1 60 41 80 	movabs $0x804160d181,%rdi
  8041603712:	00 00 00 
  8041603715:	b8 00 00 00 00       	mov    $0x0,%eax
  804160371a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603721:	00 00 00 
  8041603724:	41 ff d0             	callq  *%r8
          state->line          = 1;
  8041603727:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  804160372c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603731:	eb af                	jmp    80416036e2 <line_for_address+0x444>
      assert(program_addr == opcode_end);
  8041603733:	48 b9 a7 d1 60 41 80 	movabs $0x804160d1a7,%rcx
  804160373a:	00 00 00 
  804160373d:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041603744:	00 00 00 
  8041603747:	be 6e 00 00 00       	mov    $0x6e,%esi
  804160374c:	48 bf 81 d1 60 41 80 	movabs $0x804160d181,%rdi
  8041603753:	00 00 00 
  8041603756:	b8 00 00 00 00       	mov    $0x0,%eax
  804160375b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603762:	00 00 00 
  8041603765:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  8041603768:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160376c:	49 39 c6             	cmp    %rax,%r14
  804160376f:	0f 87 eb 01 00 00    	ja     8041603960 <line_for_address+0x6c2>
  8041603775:	48 39 d8             	cmp    %rbx,%rax
  8041603778:	0f 82 f9 01 00 00    	jb     8041603977 <line_for_address+0x6d9>
          last_state           = *state;
  804160377e:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603782:	49 89 de             	mov    %rbx,%r14
  8041603785:	e9 88 01 00 00       	jmpq   8041603912 <line_for_address+0x674>
      switch (opcode) {
  804160378a:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  804160378d:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041603792:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603797:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  804160379c:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037a0:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  80416037a4:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416037a7:	45 89 c8             	mov    %r9d,%r8d
  80416037aa:	41 83 e0 7f          	and    $0x7f,%r8d
  80416037ae:	41 d3 e0             	shl    %cl,%r8d
  80416037b1:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  80416037b4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416037b7:	45 84 c9             	test   %r9b,%r9b
  80416037ba:	78 e0                	js     804160379c <line_for_address+0x4fe>
              info->minimum_instruction_length *
  80416037bc:	89 d2                	mov    %edx,%edx
          state->address +=
  80416037be:	48 01 d3             	add    %rdx,%rbx
  return count;
  80416037c1:	48 98                	cltq   
          program_addr += count;
  80416037c3:	48 01 c6             	add    %rax,%rsi
        } break;
  80416037c6:	e9 47 01 00 00       	jmpq   8041603912 <line_for_address+0x674>
      switch (opcode) {
  80416037cb:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037ce:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416037d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037d8:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416037dd:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037e1:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  80416037e5:	45 89 c8             	mov    %r9d,%r8d
  80416037e8:	41 83 e0 7f          	and    $0x7f,%r8d
  80416037ec:	41 d3 e0             	shl    %cl,%r8d
  80416037ef:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  80416037f2:	83 c1 07             	add    $0x7,%ecx
    count++;
  80416037f5:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416037f8:	45 84 c9             	test   %r9b,%r9b
  80416037fb:	78 e0                	js     80416037dd <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  80416037fd:	83 f9 1f             	cmp    $0x1f,%ecx
  8041603800:	7f 0f                	jg     8041603811 <line_for_address+0x573>
  8041603802:	41 f6 c1 40          	test   $0x40,%r9b
  8041603806:	74 09                	je     8041603811 <line_for_address+0x573>
    result |= (-1U << shift);
  8041603808:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  804160380d:	d3 e7                	shl    %cl,%edi
  804160380f:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  8041603811:	41 01 d4             	add    %edx,%r12d
  return count;
  8041603814:	48 98                	cltq   
          program_addr += count;
  8041603816:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603819:	e9 f4 00 00 00       	jmpq   8041603912 <line_for_address+0x674>
      switch (opcode) {
  804160381e:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603821:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603826:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603829:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160382d:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603830:	84 c9                	test   %cl,%cl
  8041603832:	78 f2                	js     8041603826 <line_for_address+0x588>
  return count;
  8041603834:	48 98                	cltq   
          program_addr += count;
  8041603836:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603839:	e9 d4 00 00 00       	jmpq   8041603912 <line_for_address+0x674>
      switch (opcode) {
  804160383e:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603841:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603846:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603849:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160384d:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603850:	84 c9                	test   %cl,%cl
  8041603852:	78 f2                	js     8041603846 <line_for_address+0x5a8>
  return count;
  8041603854:	48 98                	cltq   
          program_addr += count;
  8041603856:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603859:	e9 b4 00 00 00       	jmpq   8041603912 <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  804160385e:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  8041603862:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  8041603864:	0f b6 c0             	movzbl %al,%eax
  8041603867:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  804160386a:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  804160386d:	48 01 c3             	add    %rax,%rbx
        } break;
  8041603870:	e9 9d 00 00 00       	jmpq   8041603912 <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  8041603875:	ba 02 00 00 00       	mov    $0x2,%edx
  804160387a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160387e:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  8041603885:	00 00 00 
  8041603888:	ff d0                	callq  *%rax
          state->address += pc_inc;
  804160388a:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  804160388e:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  8041603891:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  8041603895:	eb 7b                	jmp    8041603912 <line_for_address+0x674>
      switch (opcode) {
  8041603897:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160389a:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  804160389f:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416038a2:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416038a6:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416038a9:	84 c9                	test   %cl,%cl
  80416038ab:	78 f2                	js     804160389f <line_for_address+0x601>
  return count;
  80416038ad:	48 98                	cltq   
          program_addr += count;
  80416038af:	48 01 c6             	add    %rax,%rsi
        } break;
  80416038b2:	eb 5e                	jmp    8041603912 <line_for_address+0x674>
      switch (opcode) {
  80416038b4:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  80416038b7:	48 ba 94 d1 60 41 80 	movabs $0x804160d194,%rdx
  80416038be:	00 00 00 
  80416038c1:	be c1 00 00 00       	mov    $0xc1,%esi
  80416038c6:	48 bf 81 d1 60 41 80 	movabs $0x804160d181,%rdi
  80416038cd:	00 00 00 
  80416038d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038d5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416038dc:	00 00 00 
  80416038df:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  80416038e2:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  80416038e5:	0f b6 c0             	movzbl %al,%eax
  80416038e8:	f6 75 ba             	divb   -0x46(%rbp)
  80416038eb:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  80416038ee:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  80416038f2:	01 ca                	add    %ecx,%edx
  80416038f4:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  80416038f7:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  80416038fa:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  80416038fd:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603901:	49 39 c6             	cmp    %rax,%r14
  8041603904:	77 05                	ja     804160390b <line_for_address+0x66d>
  8041603906:	48 39 d8             	cmp    %rbx,%rax
  8041603909:	72 72                	jb     804160397d <line_for_address+0x6df>
      last_state = *state;
  804160390b:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160390f:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  8041603912:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  8041603916:	76 69                	jbe    8041603981 <line_for_address+0x6e3>
  8041603918:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  804160391b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603920:	4c 89 ee             	mov    %r13,%rsi
  8041603923:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603927:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160392e:	00 00 00 
  8041603931:	ff d0                	callq  *%rax
  8041603933:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  8041603937:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  804160393b:	84 c0                	test   %al,%al
  804160393d:	0f 84 37 fc ff ff    	je     804160357a <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  8041603943:	38 45 bb             	cmp    %al,-0x45(%rbp)
  8041603946:	76 9a                	jbe    80416038e2 <line_for_address+0x644>
      switch (opcode) {
  8041603948:	3c 0c                	cmp    $0xc,%al
  804160394a:	0f 87 64 ff ff ff    	ja     80416038b4 <line_for_address+0x616>
  8041603950:	0f b6 d0             	movzbl %al,%edx
  8041603953:	48 bf 40 d2 60 41 80 	movabs $0x804160d240,%rdi
  804160395a:	00 00 00 
  804160395d:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  8041603960:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603964:	49 89 de             	mov    %rbx,%r14
  8041603967:	eb a9                	jmp    8041603912 <line_for_address+0x674>
  struct Line_Number_State current_state = {
  8041603969:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  804160396f:	eb 10                	jmp    8041603981 <line_for_address+0x6e3>
            *state = last_state;
  8041603971:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603975:	eb 0a                	jmp    8041603981 <line_for_address+0x6e3>
            *state = last_state;
  8041603977:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160397b:	eb 04                	jmp    8041603981 <line_for_address+0x6e3>
        *state = last_state;
  804160397d:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  8041603981:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041603985:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  8041603988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160398d:	48 83 c4 38          	add    $0x38,%rsp
  8041603991:	5b                   	pop    %rbx
  8041603992:	41 5c                	pop    %r12
  8041603994:	41 5d                	pop    %r13
  8041603996:	41 5e                	pop    %r14
  8041603998:	41 5f                	pop    %r15
  804160399a:	5d                   	pop    %rbp
  804160399b:	c3                   	retq   
    return -E_INVAL;
  804160399c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416039a1:	eb ea                	jmp    804160398d <line_for_address+0x6ef>

00000080416039a3 <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  80416039a3:	55                   	push   %rbp
  80416039a4:	48 89 e5             	mov    %rsp,%rbp
  80416039a7:	41 55                	push   %r13
  80416039a9:	41 54                	push   %r12
  80416039ab:	53                   	push   %rbx
  80416039ac:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  80416039b0:	48 bb e0 d5 60 41 80 	movabs $0x804160d5e0,%rbx
  80416039b7:	00 00 00 
  80416039ba:	4c 8d ab c0 00 00 00 	lea    0xc0(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  80416039c1:	49 bc f2 91 60 41 80 	movabs $0x80416091f2,%r12
  80416039c8:	00 00 00 
  80416039cb:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  80416039cf:	48 8b 33             	mov    (%rbx),%rsi
  80416039d2:	48 bf a8 d2 60 41 80 	movabs $0x804160d2a8,%rdi
  80416039d9:	00 00 00 
  80416039dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039e1:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  80416039e4:	48 83 c3 18          	add    $0x18,%rbx
  80416039e8:	4c 39 eb             	cmp    %r13,%rbx
  80416039eb:	75 de                	jne    80416039cb <mon_help+0x28>
  return 0;
}
  80416039ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039f2:	48 83 c4 08          	add    $0x8,%rsp
  80416039f6:	5b                   	pop    %rbx
  80416039f7:	41 5c                	pop    %r12
  80416039f9:	41 5d                	pop    %r13
  80416039fb:	5d                   	pop    %rbp
  80416039fc:	c3                   	retq   

00000080416039fd <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  80416039fd:	55                   	push   %rbp
  80416039fe:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603a01:	48 bf b1 d2 60 41 80 	movabs $0x804160d2b1,%rdi
  8041603a08:	00 00 00 
  8041603a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a10:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041603a17:	00 00 00 
  8041603a1a:	ff d2                	callq  *%rdx
  return 0;
}
  8041603a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a21:	5d                   	pop    %rbp
  8041603a22:	c3                   	retq   

0000008041603a23 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  8041603a23:	55                   	push   %rbp
  8041603a24:	48 89 e5             	mov    %rsp,%rbp
  8041603a27:	41 55                	push   %r13
  8041603a29:	41 54                	push   %r12
  8041603a2b:	53                   	push   %rbx
  8041603a2c:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  8041603a30:	48 bf b9 d2 60 41 80 	movabs $0x804160d2b9,%rdi
  8041603a37:	00 00 00 
  8041603a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a3f:	49 bc f2 91 60 41 80 	movabs $0x80416091f2,%r12
  8041603a46:	00 00 00 
  8041603a49:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  8041603a4c:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  8041603a53:	00 00 00 
  8041603a56:	48 bf 28 d4 60 41 80 	movabs $0x804160d428,%rdi
  8041603a5d:	00 00 00 
  8041603a60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a65:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  8041603a68:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  8041603a6f:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  8041603a72:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  8041603a79:	00 00 00 
  8041603a7c:	4c 89 ee             	mov    %r13,%rsi
  8041603a7f:	48 bf 58 d4 60 41 80 	movabs $0x804160d458,%rdi
  8041603a86:	00 00 00 
  8041603a89:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a8e:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603a91:	48 ba 80 cc 60 01 00 	movabs $0x160cc80,%rdx
  8041603a98:	00 00 00 
  8041603a9b:	48 be 80 cc 60 41 80 	movabs $0x804160cc80,%rsi
  8041603aa2:	00 00 00 
  8041603aa5:	48 bf 80 d4 60 41 80 	movabs $0x804160d480,%rdi
  8041603aac:	00 00 00 
  8041603aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ab4:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603ab7:	48 ba 78 42 88 01 00 	movabs $0x1884278,%rdx
  8041603abe:	00 00 00 
  8041603ac1:	48 be 78 42 88 41 80 	movabs $0x8041884278,%rsi
  8041603ac8:	00 00 00 
  8041603acb:	48 bf a8 d4 60 41 80 	movabs $0x804160d4a8,%rdi
  8041603ad2:	00 00 00 
  8041603ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ada:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  8041603add:	48 bb 00 60 88 41 80 	movabs $0x8041886000,%rbx
  8041603ae4:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603ae7:	48 ba 00 60 88 01 00 	movabs $0x1886000,%rdx
  8041603aee:	00 00 00 
  8041603af1:	48 89 de             	mov    %rbx,%rsi
  8041603af4:	48 bf d0 d4 60 41 80 	movabs $0x804160d4d0,%rdi
  8041603afb:	00 00 00 
  8041603afe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b03:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603b06:	4c 29 eb             	sub    %r13,%rbx
  8041603b09:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603b10:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603b14:	48 bf f8 d4 60 41 80 	movabs $0x804160d4f8,%rdi
  8041603b1b:	00 00 00 
  8041603b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b23:	41 ff d4             	callq  *%r12
  return 0;
}
  8041603b26:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b2b:	48 83 c4 08          	add    $0x8,%rsp
  8041603b2f:	5b                   	pop    %rbx
  8041603b30:	41 5c                	pop    %r12
  8041603b32:	41 5d                	pop    %r13
  8041603b34:	5d                   	pop    %rbp
  8041603b35:	c3                   	retq   

0000008041603b36 <mon_backtrace>:
// }
// LAB 2 code end
// DELETED in LAB 5 end

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  8041603b36:	55                   	push   %rbp
  8041603b37:	48 89 e5             	mov    %rsp,%rbp
  8041603b3a:	41 57                	push   %r15
  8041603b3c:	41 56                	push   %r14
  8041603b3e:	41 55                	push   %r13
  8041603b40:	41 54                	push   %r12
  8041603b42:	53                   	push   %rbx
  8041603b43:	48 81 ec 38 02 00 00 	sub    $0x238,%rsp
  // LAB 2 code
  
  cprintf("Stack backtrace:\n");
  8041603b4a:	48 bf d2 d2 60 41 80 	movabs $0x804160d2d2,%rdi
  8041603b51:	00 00 00 
  8041603b54:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b59:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041603b60:	00 00 00 
  8041603b63:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603b65:	48 89 e8             	mov    %rbp,%rax
  uint64_t buf;
  int digits_16;
  int code;
  struct Ripdebuginfo info;
    
  while (rbp != 0) {
  8041603b68:	48 85 c0             	test   %rax,%rax
  8041603b6b:	0f 84 c5 01 00 00    	je     8041603d36 <mon_backtrace+0x200>
  8041603b71:	49 89 c6             	mov    %rax,%r14
  8041603b74:	49 89 c7             	mov    %rax,%r15
      while (buf != 0) {
        digits_16++;
        buf = buf / 16;
      }
      
      cprintf("  rbp ");
  8041603b77:	49 bc f2 91 60 41 80 	movabs $0x80416091f2,%r12
  8041603b7e:	00 00 00 
      cprintf("%lx\n", rip);
      
      // get and print debug info
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
      if (code == 0) {
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603b81:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603b88:	48 05 04 01 00 00    	add    $0x104,%rax
  8041603b8e:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  8041603b95:	e9 37 01 00 00       	jmpq   8041603cd1 <mon_backtrace+0x19b>
        buf = buf / 16;
  8041603b9a:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603b9d:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603ba0:	48 89 c2             	mov    %rax,%rdx
  8041603ba3:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603ba7:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603bab:	77 ed                	ja     8041603b9a <mon_backtrace+0x64>
      cprintf("  rbp ");
  8041603bad:	48 bf e4 d2 60 41 80 	movabs $0x804160d2e4,%rdi
  8041603bb4:	00 00 00 
  8041603bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603bbc:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603bbf:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603bc5:	41 29 dd             	sub    %ebx,%r13d
  8041603bc8:	45 85 ed             	test   %r13d,%r13d
  8041603bcb:	7e 1f                	jle    8041603bec <mon_backtrace+0xb6>
  8041603bcd:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603bd2:	48 bf 46 e0 60 41 80 	movabs $0x804160e046,%rdi
  8041603bd9:	00 00 00 
  8041603bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603be1:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603be4:	83 c3 01             	add    $0x1,%ebx
  8041603be7:	41 39 dd             	cmp    %ebx,%r13d
  8041603bea:	7d e6                	jge    8041603bd2 <mon_backtrace+0x9c>
      cprintf("%lx", rbp);
  8041603bec:	4c 89 f6             	mov    %r14,%rsi
  8041603bef:	48 bf eb d2 60 41 80 	movabs $0x804160d2eb,%rdi
  8041603bf6:	00 00 00 
  8041603bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603bfe:	41 ff d4             	callq  *%r12
      rbp = *pointer;
  8041603c01:	4d 8b 37             	mov    (%r15),%r14
      rip = *pointer;
  8041603c04:	4d 8b 7f 08          	mov    0x8(%r15),%r15
      buf = buf / 16;
  8041603c08:	4c 89 f8             	mov    %r15,%rax
  8041603c0b:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603c0f:	49 83 ff 0f          	cmp    $0xf,%r15
  8041603c13:	0f 86 e3 00 00 00    	jbe    8041603cfc <mon_backtrace+0x1c6>
      digits_16 = 1;
  8041603c19:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603c1e:	eb 03                	jmp    8041603c23 <mon_backtrace+0xed>
        buf = buf / 16;
  8041603c20:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603c23:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603c26:	48 89 c2             	mov    %rax,%rdx
  8041603c29:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603c2d:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603c31:	77 ed                	ja     8041603c20 <mon_backtrace+0xea>
      cprintf("  rip ");
  8041603c33:	48 bf ef d2 60 41 80 	movabs $0x804160d2ef,%rdi
  8041603c3a:	00 00 00 
  8041603c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c42:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c45:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603c4b:	41 29 dd             	sub    %ebx,%r13d
  8041603c4e:	45 85 ed             	test   %r13d,%r13d
  8041603c51:	7e 1f                	jle    8041603c72 <mon_backtrace+0x13c>
  8041603c53:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603c58:	48 bf 46 e0 60 41 80 	movabs $0x804160e046,%rdi
  8041603c5f:	00 00 00 
  8041603c62:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c67:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c6a:	83 c3 01             	add    $0x1,%ebx
  8041603c6d:	44 39 eb             	cmp    %r13d,%ebx
  8041603c70:	7e e6                	jle    8041603c58 <mon_backtrace+0x122>
      cprintf("%lx\n", rip);
  8041603c72:	4c 89 fe             	mov    %r15,%rsi
  8041603c75:	48 bf a4 e0 60 41 80 	movabs $0x804160e0a4,%rdi
  8041603c7c:	00 00 00 
  8041603c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c84:	41 ff d4             	callq  *%r12
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
  8041603c87:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603c8e:	4c 89 ff             	mov    %r15,%rdi
  8041603c91:	48 b8 7d b5 60 41 80 	movabs $0x804160b57d,%rax
  8041603c98:	00 00 00 
  8041603c9b:	ff d0                	callq  *%rax
      if (code == 0) {
  8041603c9d:	85 c0                	test   %eax,%eax
  8041603c9f:	75 47                	jne    8041603ce8 <mon_backtrace+0x1b2>
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603ca1:	4d 89 f8             	mov    %r15,%r8
  8041603ca4:	4c 2b 45 b8          	sub    -0x48(%rbp),%r8
  8041603ca8:	48 8b 8d a8 fd ff ff 	mov    -0x258(%rbp),%rcx
  8041603caf:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603cb5:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603cbc:	48 bf f6 d2 60 41 80 	movabs $0x804160d2f6,%rdi
  8041603cc3:	00 00 00 
  8041603cc6:	41 ff d4             	callq  *%r12
      } else {
          cprintf("Info not found");
      }
      
      pointer = (uintptr_t *)rbp;
  8041603cc9:	4d 89 f7             	mov    %r14,%r15
  while (rbp != 0) {
  8041603ccc:	4d 85 f6             	test   %r14,%r14
  8041603ccf:	74 65                	je     8041603d36 <mon_backtrace+0x200>
      buf = buf / 16;
  8041603cd1:	4c 89 f0             	mov    %r14,%rax
  8041603cd4:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603cd8:	49 83 fe 0f          	cmp    $0xf,%r14
  8041603cdc:	76 3b                	jbe    8041603d19 <mon_backtrace+0x1e3>
      digits_16 = 1;
  8041603cde:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603ce3:	e9 b5 fe ff ff       	jmpq   8041603b9d <mon_backtrace+0x67>
          cprintf("Info not found");
  8041603ce8:	48 bf 0e d3 60 41 80 	movabs $0x804160d30e,%rdi
  8041603cef:	00 00 00 
  8041603cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cf7:	41 ff d4             	callq  *%r12
  8041603cfa:	eb cd                	jmp    8041603cc9 <mon_backtrace+0x193>
      cprintf("  rip ");
  8041603cfc:	48 bf ef d2 60 41 80 	movabs $0x804160d2ef,%rdi
  8041603d03:	00 00 00 
  8041603d06:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d0b:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d0e:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d14:	e9 3a ff ff ff       	jmpq   8041603c53 <mon_backtrace+0x11d>
      cprintf("  rbp ");
  8041603d19:	48 bf e4 d2 60 41 80 	movabs $0x804160d2e4,%rdi
  8041603d20:	00 00 00 
  8041603d23:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d28:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d2b:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d31:	e9 97 fe ff ff       	jmpq   8041603bcd <mon_backtrace+0x97>
    }
    
  // LAB 2 code end
  return 0;
}
  8041603d36:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d3b:	48 81 c4 38 02 00 00 	add    $0x238,%rsp
  8041603d42:	5b                   	pop    %rbx
  8041603d43:	41 5c                	pop    %r12
  8041603d45:	41 5d                	pop    %r13
  8041603d47:	41 5e                	pop    %r14
  8041603d49:	41 5f                	pop    %r15
  8041603d4b:	5d                   	pop    %rbp
  8041603d4c:	c3                   	retq   

0000008041603d4d <mon_start>:
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
int
mon_start(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603d4d:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603d52:	83 ff 02             	cmp    $0x2,%edi
  8041603d55:	74 01                	je     8041603d58 <mon_start+0xb>
  }
  timer_start(argv[1]);
  // LAB 5 code end

  return 0;
}
  8041603d57:	c3                   	retq   
mon_start(int argc, char **argv, struct Trapframe *tf) {
  8041603d58:	55                   	push   %rbp
  8041603d59:	48 89 e5             	mov    %rsp,%rbp
  timer_start(argv[1]);
  8041603d5c:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603d60:	48 b8 94 c9 60 41 80 	movabs $0x804160c994,%rax
  8041603d67:	00 00 00 
  8041603d6a:	ff d0                	callq  *%rax
  return 0;
  8041603d6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603d71:	5d                   	pop    %rbp
  8041603d72:	c3                   	retq   

0000008041603d73 <mon_stop>:

int
mon_stop(int argc, char **argv, struct Trapframe *tf) {
  8041603d73:	55                   	push   %rbp
  8041603d74:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  timer_stop();
  8041603d77:	48 b8 4e ca 60 41 80 	movabs $0x804160ca4e,%rax
  8041603d7e:	00 00 00 
  8041603d81:	ff d0                	callq  *%rax
  // LAB 5 code end

  return 0;
}
  8041603d83:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d88:	5d                   	pop    %rbp
  8041603d89:	c3                   	retq   

0000008041603d8a <mon_frequency>:

int
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603d8a:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603d8f:	83 ff 02             	cmp    $0x2,%edi
  8041603d92:	74 01                	je     8041603d95 <mon_frequency+0xb>
  }
  timer_cpu_frequency(argv[1]);
  // LAB 5 code end

  return 0;
}
  8041603d94:	c3                   	retq   
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  8041603d95:	55                   	push   %rbp
  8041603d96:	48 89 e5             	mov    %rsp,%rbp
  timer_cpu_frequency(argv[1]);
  8041603d99:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603d9d:	48 b8 d8 ca 60 41 80 	movabs $0x804160cad8,%rax
  8041603da4:	00 00 00 
  8041603da7:	ff d0                	callq  *%rax
  return 0;
  8041603da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603dae:	5d                   	pop    %rbp
  8041603daf:	c3                   	retq   

0000008041603db0 <mon_memory>:
int 
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  size_t i;
	int is_cur_free;

	for (i = 1; i <= npages; i++) {
  8041603db0:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041603db7:	00 00 00 
  8041603dba:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041603dbe:	0f 84 24 01 00 00    	je     8041603ee8 <mon_memory+0x138>
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  8041603dc4:	55                   	push   %rbp
  8041603dc5:	48 89 e5             	mov    %rsp,%rbp
  8041603dc8:	41 57                	push   %r15
  8041603dca:	41 56                	push   %r14
  8041603dcc:	41 55                	push   %r13
  8041603dce:	41 54                	push   %r12
  8041603dd0:	53                   	push   %rbx
  8041603dd1:	48 83 ec 18          	sub    $0x18,%rsp
	for (i = 1; i <= npages; i++) {
  8041603dd5:	bb 01 00 00 00       	mov    $0x1,%ebx
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603dda:	49 be 58 5a 88 41 80 	movabs $0x8041885a58,%r14
  8041603de1:	00 00 00 
		cprintf("%lu", i);
  8041603de4:	49 bf f2 91 60 41 80 	movabs $0x80416091f2,%r15
  8041603deb:	00 00 00 
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603dee:	49 89 c4             	mov    %rax,%r12
  8041603df1:	eb 47                	jmp    8041603e3a <mon_memory+0x8a>
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
        i++;
      }
			cprintf("..%lu", i);
  8041603df3:	48 89 de             	mov    %rbx,%rsi
  8041603df6:	48 bf 30 d3 60 41 80 	movabs $0x804160d330,%rdi
  8041603dfd:	00 00 00 
  8041603e00:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e05:	41 ff d7             	callq  *%r15
		}
		cprintf(is_cur_free ? " FREE\n" : " ALLOCATED\n");
  8041603e08:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603e0c:	48 bf 1d d3 60 41 80 	movabs $0x804160d31d,%rdi
  8041603e13:	00 00 00 
  8041603e16:	48 b8 24 d3 60 41 80 	movabs $0x804160d324,%rax
  8041603e1d:	00 00 00 
  8041603e20:	48 0f 45 f8          	cmovne %rax,%rdi
  8041603e24:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e29:	41 ff d7             	callq  *%r15
	for (i = 1; i <= npages; i++) {
  8041603e2c:	48 83 c3 01          	add    $0x1,%rbx
  8041603e30:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603e34:	0f 82 9a 00 00 00    	jb     8041603ed4 <mon_memory+0x124>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e3a:	49 89 dd             	mov    %rbx,%r13
  8041603e3d:	49 c1 e5 04          	shl    $0x4,%r13
  8041603e41:	49 8b 06             	mov    (%r14),%rax
  8041603e44:	4a 8d 7c 28 f0       	lea    -0x10(%rax,%r13,1),%rdi
  8041603e49:	48 b8 d6 4a 60 41 80 	movabs $0x8041604ad6,%rax
  8041603e50:	00 00 00 
  8041603e53:	ff d0                	callq  *%rax
  8041603e55:	89 45 cc             	mov    %eax,-0x34(%rbp)
		cprintf("%lu", i);
  8041603e58:	48 89 de             	mov    %rbx,%rsi
  8041603e5b:	48 bf 32 d3 60 41 80 	movabs $0x804160d332,%rdi
  8041603e62:	00 00 00 
  8041603e65:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e6a:	41 ff d7             	callq  *%r15
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e6d:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603e71:	76 95                	jbe    8041603e08 <mon_memory+0x58>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e73:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603e77:	0f 94 c0             	sete   %al
  8041603e7a:	0f b6 c0             	movzbl %al,%eax
  8041603e7d:	89 45 c8             	mov    %eax,-0x38(%rbp)
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e80:	4c 89 ef             	mov    %r13,%rdi
  8041603e83:	49 03 3e             	add    (%r14),%rdi
  8041603e86:	48 b8 d6 4a 60 41 80 	movabs $0x8041604ad6,%rax
  8041603e8d:	00 00 00 
  8041603e90:	ff d0                	callq  *%rax
  8041603e92:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603e95:	0f 84 6d ff ff ff    	je     8041603e08 <mon_memory+0x58>
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e9b:	49 bd d6 4a 60 41 80 	movabs $0x8041604ad6,%r13
  8041603ea2:	00 00 00 
  8041603ea5:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603ea9:	0f 86 44 ff ff ff    	jbe    8041603df3 <mon_memory+0x43>
  8041603eaf:	48 89 df             	mov    %rbx,%rdi
  8041603eb2:	48 c1 e7 04          	shl    $0x4,%rdi
  8041603eb6:	49 03 3e             	add    (%r14),%rdi
  8041603eb9:	41 ff d5             	callq  *%r13
  8041603ebc:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603ebf:	0f 84 2e ff ff ff    	je     8041603df3 <mon_memory+0x43>
        i++;
  8041603ec5:	48 83 c3 01          	add    $0x1,%rbx
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603ec9:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603ecd:	77 e0                	ja     8041603eaf <mon_memory+0xff>
  8041603ecf:	e9 1f ff ff ff       	jmpq   8041603df3 <mon_memory+0x43>
	}
	
  return 0;
}
  8041603ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ed9:	48 83 c4 18          	add    $0x18,%rsp
  8041603edd:	5b                   	pop    %rbx
  8041603ede:	41 5c                	pop    %r12
  8041603ee0:	41 5d                	pop    %r13
  8041603ee2:	41 5e                	pop    %r14
  8041603ee4:	41 5f                	pop    %r15
  8041603ee6:	5d                   	pop    %rbp
  8041603ee7:	c3                   	retq   
  8041603ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603eed:	c3                   	retq   

0000008041603eee <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603eee:	55                   	push   %rbp
  8041603eef:	48 89 e5             	mov    %rsp,%rbp
  8041603ef2:	41 57                	push   %r15
  8041603ef4:	41 56                	push   %r14
  8041603ef6:	41 55                	push   %r13
  8041603ef8:	41 54                	push   %r12
  8041603efa:	53                   	push   %rbx
  8041603efb:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603f02:	49 89 ff             	mov    %rdi,%r15
  8041603f05:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603f0c:	48 bf 28 d5 60 41 80 	movabs $0x804160d528,%rdi
  8041603f13:	00 00 00 
  8041603f16:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f1b:	48 bb f2 91 60 41 80 	movabs $0x80416091f2,%rbx
  8041603f22:	00 00 00 
  8041603f25:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603f27:	48 bf 50 d5 60 41 80 	movabs $0x804160d550,%rdi
  8041603f2e:	00 00 00 
  8041603f31:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f36:	ff d3                	callq  *%rbx

  if (tf != NULL)
  8041603f38:	4d 85 ff             	test   %r15,%r15
  8041603f3b:	74 0f                	je     8041603f4c <monitor+0x5e>
    print_trapframe(tf);
  8041603f3d:	4c 89 ff             	mov    %r15,%rdi
  8041603f40:	48 b8 bd 98 60 41 80 	movabs $0x80416098bd,%rax
  8041603f47:	00 00 00 
  8041603f4a:	ff d0                	callq  *%rax

  while (1) {
    buf = readline("K> ");
  8041603f4c:	49 bf 90 c1 60 41 80 	movabs $0x804160c190,%r15
  8041603f53:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603f56:	49 be 47 c4 60 41 80 	movabs $0x804160c447,%r14
  8041603f5d:	00 00 00 
  8041603f60:	e9 ff 00 00 00       	jmpq   8041604064 <monitor+0x176>
  8041603f65:	40 0f be f6          	movsbl %sil,%esi
  8041603f69:	48 bf 3a d3 60 41 80 	movabs $0x804160d33a,%rdi
  8041603f70:	00 00 00 
  8041603f73:	41 ff d6             	callq  *%r14
  8041603f76:	48 85 c0             	test   %rax,%rax
  8041603f79:	74 0c                	je     8041603f87 <monitor+0x99>
      *buf++ = 0;
  8041603f7b:	c6 03 00             	movb   $0x0,(%rbx)
  8041603f7e:	45 89 e5             	mov    %r12d,%r13d
  8041603f81:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603f85:	eb 49                	jmp    8041603fd0 <monitor+0xe2>
    if (*buf == 0)
  8041603f87:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603f8a:	74 4f                	je     8041603fdb <monitor+0xed>
    if (argc == MAXARGS - 1) {
  8041603f8c:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603f90:	0f 84 b3 00 00 00    	je     8041604049 <monitor+0x15b>
    argv[argc++] = buf;
  8041603f96:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  8041603f9b:	4d 63 e4             	movslq %r12d,%r12
  8041603f9e:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041603fa5:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603fa6:	0f b6 33             	movzbl (%rbx),%esi
  8041603fa9:	40 84 f6             	test   %sil,%sil
  8041603fac:	74 22                	je     8041603fd0 <monitor+0xe2>
  8041603fae:	40 0f be f6          	movsbl %sil,%esi
  8041603fb2:	48 bf 3a d3 60 41 80 	movabs $0x804160d33a,%rdi
  8041603fb9:	00 00 00 
  8041603fbc:	41 ff d6             	callq  *%r14
  8041603fbf:	48 85 c0             	test   %rax,%rax
  8041603fc2:	75 0c                	jne    8041603fd0 <monitor+0xe2>
      buf++;
  8041603fc4:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603fc8:	0f b6 33             	movzbl (%rbx),%esi
  8041603fcb:	40 84 f6             	test   %sil,%sil
  8041603fce:	75 de                	jne    8041603fae <monitor+0xc0>
      *buf++ = 0;
  8041603fd0:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603fd3:	0f b6 33             	movzbl (%rbx),%esi
  8041603fd6:	40 84 f6             	test   %sil,%sil
  8041603fd9:	75 8a                	jne    8041603f65 <monitor+0x77>
  argv[argc] = 0;
  8041603fdb:	49 63 c4             	movslq %r12d,%rax
  8041603fde:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041603fe5:	ff 00 00 00 00 
  if (argc == 0)
  8041603fea:	45 85 e4             	test   %r12d,%r12d
  8041603fed:	74 75                	je     8041604064 <monitor+0x176>
  8041603fef:	49 bd e0 d5 60 41 80 	movabs $0x804160d5e0,%r13
  8041603ff6:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041603ff9:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  8041603ffe:	49 8b 75 00          	mov    0x0(%r13),%rsi
  8041604002:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041604009:	48 b8 e0 c3 60 41 80 	movabs $0x804160c3e0,%rax
  8041604010:	00 00 00 
  8041604013:	ff d0                	callq  *%rax
  8041604015:	85 c0                	test   %eax,%eax
  8041604017:	74 76                	je     804160408f <monitor+0x1a1>
  for (i = 0; i < NCOMMANDS; i++) {
  8041604019:	83 c3 01             	add    $0x1,%ebx
  804160401c:	49 83 c5 18          	add    $0x18,%r13
  8041604020:	83 fb 08             	cmp    $0x8,%ebx
  8041604023:	75 d9                	jne    8041603ffe <monitor+0x110>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041604025:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  804160402c:	48 bf 5c d3 60 41 80 	movabs $0x804160d35c,%rdi
  8041604033:	00 00 00 
  8041604036:	b8 00 00 00 00       	mov    $0x0,%eax
  804160403b:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041604042:	00 00 00 
  8041604045:	ff d2                	callq  *%rdx
  return 0;
  8041604047:	eb 1b                	jmp    8041604064 <monitor+0x176>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041604049:	be 10 00 00 00       	mov    $0x10,%esi
  804160404e:	48 bf 3f d3 60 41 80 	movabs $0x804160d33f,%rdi
  8041604055:	00 00 00 
  8041604058:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160405f:	00 00 00 
  8041604062:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  8041604064:	48 bf 36 d3 60 41 80 	movabs $0x804160d336,%rdi
  804160406b:	00 00 00 
  804160406e:	41 ff d7             	callq  *%r15
  8041604071:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  8041604074:	48 85 c0             	test   %rax,%rax
  8041604077:	74 eb                	je     8041604064 <monitor+0x176>
  argv[argc] = 0;
  8041604079:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  8041604080:	00 00 00 00 
  argc       = 0;
  8041604084:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  804160408a:	e9 44 ff ff ff       	jmpq   8041603fd3 <monitor+0xe5>
      return commands[i].func(argc, argv, tf);
  804160408f:	48 63 db             	movslq %ebx,%rbx
  8041604092:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  8041604096:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  804160409d:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  80416040a4:	44 89 e7             	mov    %r12d,%edi
  80416040a7:	48 b8 e0 d5 60 41 80 	movabs $0x804160d5e0,%rax
  80416040ae:	00 00 00 
  80416040b1:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  80416040b5:	85 c0                	test   %eax,%eax
  80416040b7:	79 ab                	jns    8041604064 <monitor+0x176>
        break;
  }
}
  80416040b9:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  80416040c0:	5b                   	pop    %rbx
  80416040c1:	41 5c                	pop    %r12
  80416040c3:	41 5d                	pop    %r13
  80416040c5:	41 5e                	pop    %r14
  80416040c7:	41 5f                	pop    %r15
  80416040c9:	5d                   	pop    %rbp
  80416040ca:	c3                   	retq   

00000080416040cb <check_va2pa>:
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  pte_t *pte;
  pdpe_t *pdpe;
  pde_t *pde;
  // cprintf("%x", va);
  pml4e = &pml4e[PML4(va)];
  80416040cb:	48 89 f0             	mov    %rsi,%rax
  80416040ce:	48 c1 e8 27          	shr    $0x27,%rax
  80416040d2:	25 ff 01 00 00       	and    $0x1ff,%eax
  // cprintf(" %x %x " , PML4(va), *pml4e);
  if (!(*pml4e & PTE_P))
  80416040d7:	48 8b 0c c7          	mov    (%rdi,%rax,8),%rcx
  80416040db:	f6 c1 01             	test   $0x1,%cl
  80416040de:	0f 84 5a 01 00 00    	je     804160423e <check_va2pa+0x173>
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  80416040e4:	55                   	push   %rbp
  80416040e5:	48 89 e5             	mov    %rsp,%rbp
    return ~0;
  pdpe = (pdpe_t *)KADDR(PTE_ADDR(*pml4e));
  80416040e8:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
//CAUTION: use only before page detection!
#define _KADDR_NOCHECK(pa) (void *)((physaddr_t)pa + KERNBASE)

static inline void *
_kaddr(const char *file, int line, physaddr_t pa) {
  if (PGNUM(pa) >= npages)
  80416040ef:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  80416040f6:	00 00 00 
  80416040f9:	48 8b 10             	mov    (%rax),%rdx
  80416040fc:	48 89 c8             	mov    %rcx,%rax
  80416040ff:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604103:	48 39 c2             	cmp    %rax,%rdx
  8041604106:	0f 86 b1 00 00 00    	jbe    80416041bd <check_va2pa+0xf2>
  // cprintf(" %x %x " , pdpe, *pdpe);
  if (!(pdpe[PDPE(va)] & PTE_P))
  804160410c:	48 89 f0             	mov    %rsi,%rax
  804160410f:	48 c1 e8 1b          	shr    $0x1b,%rax
  8041604113:	25 f8 0f 00 00       	and    $0xff8,%eax
  8041604118:	48 01 c1             	add    %rax,%rcx
  804160411b:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041604122:	00 00 00 
  8041604125:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  8041604129:	f6 c1 01             	test   $0x1,%cl
  804160412c:	0f 84 14 01 00 00    	je     8041604246 <check_va2pa+0x17b>
    return ~0;
  pde = (pde_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8041604132:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041604139:	48 89 c8             	mov    %rcx,%rax
  804160413c:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604140:	48 39 c2             	cmp    %rax,%rdx
  8041604143:	0f 86 9f 00 00 00    	jbe    80416041e8 <check_va2pa+0x11d>
  // cprintf(" %x %x " , pde, *pde);
  pde = &pde[PDX(va)];
  8041604149:	48 89 f0             	mov    %rsi,%rax
  804160414c:	48 c1 e8 12          	shr    $0x12,%rax
  if (!(*pde & PTE_P))
  8041604150:	25 f8 0f 00 00       	and    $0xff8,%eax
  8041604155:	48 01 c1             	add    %rax,%rcx
  8041604158:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160415f:	00 00 00 
  8041604162:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  8041604166:	f6 c1 01             	test   $0x1,%cl
  8041604169:	0f 84 e3 00 00 00    	je     8041604252 <check_va2pa+0x187>
    return ~0;
  pte = (pte_t *)KADDR(PTE_ADDR(*pde));
  804160416f:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041604176:	48 89 c8             	mov    %rcx,%rax
  8041604179:	48 c1 e8 0c          	shr    $0xc,%rax
  804160417d:	48 39 c2             	cmp    %rax,%rdx
  8041604180:	0f 86 8d 00 00 00    	jbe    8041604213 <check_va2pa+0x148>
  // cprintf(" %x %x " , pte, *pte);
  if (!(pte[PTX(va)] & PTE_P))
  8041604186:	48 c1 ee 09          	shr    $0x9,%rsi
  804160418a:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
  8041604190:	48 01 ce             	add    %rcx,%rsi
  8041604193:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160419a:	00 00 00 
  804160419d:	48 8b 04 06          	mov    (%rsi,%rax,1),%rax
  80416041a1:	48 89 c2             	mov    %rax,%rdx
  80416041a4:	83 e2 01             	and    $0x1,%edx
    return ~0;
  // cprintf(" %x %x\n" , PTX(va),  PTE_ADDR(pte[PTX(va)]));
  return PTE_ADDR(pte[PTX(va)]);
  80416041a7:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416041ad:	48 85 d2             	test   %rdx,%rdx
  80416041b0:	48 c7 c2 ff ff ff ff 	mov    $0xffffffffffffffff,%rdx
  80416041b7:	48 0f 44 c2          	cmove  %rdx,%rax
}
  80416041bb:	5d                   	pop    %rbp
  80416041bc:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416041bd:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  80416041c4:	00 00 00 
  80416041c7:	be 7e 04 00 00       	mov    $0x47e,%esi
  80416041cc:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416041d3:	00 00 00 
  80416041d6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416041db:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416041e2:	00 00 00 
  80416041e5:	41 ff d0             	callq  *%r8
  80416041e8:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  80416041ef:	00 00 00 
  80416041f2:	be 82 04 00 00       	mov    $0x482,%esi
  80416041f7:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416041fe:	00 00 00 
  8041604201:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604206:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160420d:	00 00 00 
  8041604210:	41 ff d0             	callq  *%r8
  8041604213:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  804160421a:	00 00 00 
  804160421d:	be 87 04 00 00       	mov    $0x487,%esi
  8041604222:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604229:	00 00 00 
  804160422c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604231:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604238:	00 00 00 
  804160423b:	41 ff d0             	callq  *%r8
    return ~0;
  804160423e:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
}
  8041604245:	c3                   	retq   
    return ~0;
  8041604246:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  804160424d:	e9 69 ff ff ff       	jmpq   80416041bb <check_va2pa+0xf0>
    return ~0;
  8041604252:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  8041604259:	e9 5d ff ff ff       	jmpq   80416041bb <check_va2pa+0xf0>

000000804160425e <boot_alloc>:
  if (!nextfree) {
  804160425e:	48 b8 f8 44 88 41 80 	movabs $0x80418844f8,%rax
  8041604265:	00 00 00 
  8041604268:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160426c:	74 5c                	je     80416042ca <boot_alloc+0x6c>
  if (!n) {
  804160426e:	85 ff                	test   %edi,%edi
  8041604270:	74 74                	je     80416042e6 <boot_alloc+0x88>
boot_alloc(uint32_t n) {
  8041604272:	55                   	push   %rbp
  8041604273:	48 89 e5             	mov    %rsp,%rbp
	result = nextfree;
  8041604276:	48 ba f8 44 88 41 80 	movabs $0x80418844f8,%rdx
  804160427d:	00 00 00 
  8041604280:	48 8b 02             	mov    (%rdx),%rax
	nextfree += ROUNDUP(n, PGSIZE);
  8041604283:	48 8d 8f ff 0f 00 00 	lea    0xfff(%rdi),%rcx
  804160428a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  8041604290:	48 01 c1             	add    %rax,%rcx
  8041604293:	48 89 0a             	mov    %rcx,(%rdx)
  if ((uint64_t)kva < KERNBASE)
  8041604296:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160429d:	00 00 00 
  80416042a0:	48 39 d1             	cmp    %rdx,%rcx
  80416042a3:	76 4c                	jbe    80416042f1 <boot_alloc+0x93>
	if (PADDR(nextfree) > PGSIZE * npages) {
  80416042a5:	48 be 50 5a 88 41 80 	movabs $0x8041885a50,%rsi
  80416042ac:	00 00 00 
  80416042af:	48 8b 16             	mov    (%rsi),%rdx
  80416042b2:	48 c1 e2 0c          	shl    $0xc,%rdx
  return (physaddr_t)kva - KERNBASE;
  80416042b6:	48 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rsi
  80416042bd:	ff ff ff 
  80416042c0:	48 01 f1             	add    %rsi,%rcx
  80416042c3:	48 39 ca             	cmp    %rcx,%rdx
  80416042c6:	72 54                	jb     804160431c <boot_alloc+0xbe>
}
  80416042c8:	5d                   	pop    %rbp
  80416042c9:	c3                   	retq   
		nextfree = ROUNDUP((char *)end, PGSIZE);
  80416042ca:	48 b8 ff 6f 88 41 80 	movabs $0x8041886fff,%rax
  80416042d1:	00 00 00 
  80416042d4:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416042da:	48 a3 f8 44 88 41 80 	movabs %rax,0x80418844f8
  80416042e1:	00 00 00 
  80416042e4:	eb 88                	jmp    804160426e <boot_alloc+0x10>
	    return nextfree;
  80416042e6:	48 a1 f8 44 88 41 80 	movabs 0x80418844f8,%rax
  80416042ed:	00 00 00 
}
  80416042f0:	c3                   	retq   
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416042f1:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  80416042f8:	00 00 00 
  80416042fb:	be bd 00 00 00       	mov    $0xbd,%esi
  8041604300:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604307:	00 00 00 
  804160430a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160430f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604316:	00 00 00 
  8041604319:	41 ff d0             	callq  *%r8
	    panic("Not enough memory for boot!");
  804160431c:	48 ba fb df 60 41 80 	movabs $0x804160dffb,%rdx
  8041604323:	00 00 00 
  8041604326:	be be 00 00 00       	mov    $0xbe,%esi
  804160432b:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604332:	00 00 00 
  8041604335:	b8 00 00 00 00       	mov    $0x0,%eax
  804160433a:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604341:	00 00 00 
  8041604344:	ff d1                	callq  *%rcx

0000008041604346 <check_page_free_list>:
check_page_free_list(bool only_low_memory) {
  8041604346:	55                   	push   %rbp
  8041604347:	48 89 e5             	mov    %rsp,%rbp
  804160434a:	53                   	push   %rbx
  804160434b:	48 83 ec 28          	sub    $0x28,%rsp
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  804160434f:	40 84 ff             	test   %dil,%dil
  8041604352:	0f 85 7f 03 00 00    	jne    80416046d7 <check_page_free_list+0x391>
  if (!page_free_list)
  8041604358:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  804160435f:	00 00 00 
  8041604362:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604366:	0f 84 9f 00 00 00    	je     804160440b <check_page_free_list+0xc5>
  first_free_page = (char *)boot_alloc(0);
  804160436c:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604371:	48 b8 5e 42 60 41 80 	movabs $0x804160425e,%rax
  8041604378:	00 00 00 
  804160437b:	ff d0                	callq  *%rax
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  804160437d:	48 bb 10 45 88 41 80 	movabs $0x8041884510,%rbx
  8041604384:	00 00 00 
  8041604387:	48 8b 13             	mov    (%rbx),%rdx
  804160438a:	48 85 d2             	test   %rdx,%rdx
  804160438d:	0f 84 0f 03 00 00    	je     80416046a2 <check_page_free_list+0x35c>
    assert(pp >= pages);
  8041604393:	48 bb 58 5a 88 41 80 	movabs $0x8041885a58,%rbx
  804160439a:	00 00 00 
  804160439d:	48 8b 3b             	mov    (%rbx),%rdi
  80416043a0:	48 39 fa             	cmp    %rdi,%rdx
  80416043a3:	0f 82 8c 00 00 00    	jb     8041604435 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  80416043a9:	48 bb 50 5a 88 41 80 	movabs $0x8041885a50,%rbx
  80416043b0:	00 00 00 
  80416043b3:	4c 8b 1b             	mov    (%rbx),%r11
  80416043b6:	4d 89 d8             	mov    %r11,%r8
  80416043b9:	49 c1 e0 04          	shl    $0x4,%r8
  80416043bd:	49 01 f8             	add    %rdi,%r8
  80416043c0:	4c 39 c2             	cmp    %r8,%rdx
  80416043c3:	0f 83 a1 00 00 00    	jae    804160446a <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416043c9:	48 89 d1             	mov    %rdx,%rcx
  80416043cc:	48 29 f9             	sub    %rdi,%rcx
  80416043cf:	f6 c1 0f             	test   $0xf,%cl
  80416043d2:	0f 85 c7 00 00 00    	jne    804160449f <check_page_free_list+0x159>
int user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
  80416043d8:	48 c1 f9 04          	sar    $0x4,%rcx
  80416043dc:	48 c1 e1 0c          	shl    $0xc,%rcx
  80416043e0:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  80416043e3:	0f 84 eb 00 00 00    	je     80416044d4 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  80416043e9:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  80416043f0:	0f 84 13 01 00 00    	je     8041604509 <check_page_free_list+0x1c3>
  int nfree_basemem = 0, nfree_extmem = 0;
  80416043f6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  return (void *)(pa + KERNBASE);
  80416043fc:	48 bb 00 00 00 40 80 	movabs $0x8040000000,%rbx
  8041604403:	00 00 00 
  8041604406:	e9 17 02 00 00       	jmpq   8041604622 <check_page_free_list+0x2dc>
    panic("'page_free_list' is a null pointer!");
  804160440b:	48 ba e8 d6 60 41 80 	movabs $0x804160d6e8,%rdx
  8041604412:	00 00 00 
  8041604415:	be b2 03 00 00       	mov    $0x3b2,%esi
  804160441a:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604421:	00 00 00 
  8041604424:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604429:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604430:	00 00 00 
  8041604433:	ff d1                	callq  *%rcx
    assert(pp >= pages);
  8041604435:	48 b9 17 e0 60 41 80 	movabs $0x804160e017,%rcx
  804160443c:	00 00 00 
  804160443f:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041604446:	00 00 00 
  8041604449:	be d3 03 00 00       	mov    $0x3d3,%esi
  804160444e:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604455:	00 00 00 
  8041604458:	b8 00 00 00 00       	mov    $0x0,%eax
  804160445d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604464:	00 00 00 
  8041604467:	41 ff d0             	callq  *%r8
    assert(pp < pages + npages);
  804160446a:	48 b9 23 e0 60 41 80 	movabs $0x804160e023,%rcx
  8041604471:	00 00 00 
  8041604474:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160447b:	00 00 00 
  804160447e:	be d4 03 00 00       	mov    $0x3d4,%esi
  8041604483:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160448a:	00 00 00 
  804160448d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604492:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604499:	00 00 00 
  804160449c:	41 ff d0             	callq  *%r8
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  804160449f:	48 b9 10 d7 60 41 80 	movabs $0x804160d710,%rcx
  80416044a6:	00 00 00 
  80416044a9:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416044b0:	00 00 00 
  80416044b3:	be d5 03 00 00       	mov    $0x3d5,%esi
  80416044b8:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416044bf:	00 00 00 
  80416044c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044c7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044ce:	00 00 00 
  80416044d1:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != 0);
  80416044d4:	48 b9 37 e0 60 41 80 	movabs $0x804160e037,%rcx
  80416044db:	00 00 00 
  80416044de:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416044e5:	00 00 00 
  80416044e8:	be d8 03 00 00       	mov    $0x3d8,%esi
  80416044ed:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416044f4:	00 00 00 
  80416044f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044fc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604503:	00 00 00 
  8041604506:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != IOPHYSMEM);
  8041604509:	48 b9 48 e0 60 41 80 	movabs $0x804160e048,%rcx
  8041604510:	00 00 00 
  8041604513:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160451a:	00 00 00 
  804160451d:	be d9 03 00 00       	mov    $0x3d9,%esi
  8041604522:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604529:	00 00 00 
  804160452c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604531:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604538:	00 00 00 
  804160453b:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  804160453e:	48 b9 40 d7 60 41 80 	movabs $0x804160d740,%rcx
  8041604545:	00 00 00 
  8041604548:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160454f:	00 00 00 
  8041604552:	be da 03 00 00       	mov    $0x3da,%esi
  8041604557:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160455e:	00 00 00 
  8041604561:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604566:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160456d:	00 00 00 
  8041604570:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM);
  8041604573:	48 b9 61 e0 60 41 80 	movabs $0x804160e061,%rcx
  804160457a:	00 00 00 
  804160457d:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041604584:	00 00 00 
  8041604587:	be db 03 00 00       	mov    $0x3db,%esi
  804160458c:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604593:	00 00 00 
  8041604596:	b8 00 00 00 00       	mov    $0x0,%eax
  804160459b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045a2:	00 00 00 
  80416045a5:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416045a8:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  80416045af:	00 00 00 
  80416045b2:	be 61 00 00 00       	mov    $0x61,%esi
  80416045b7:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  80416045be:	00 00 00 
  80416045c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045c6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045cd:	00 00 00 
  80416045d0:	41 ff d0             	callq  *%r8
      ++nfree_extmem;
  80416045d3:	41 83 c1 01          	add    $0x1,%r9d
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  80416045d7:	48 8b 12             	mov    (%rdx),%rdx
  80416045da:	48 85 d2             	test   %rdx,%rdx
  80416045dd:	0f 84 b3 00 00 00    	je     8041604696 <check_page_free_list+0x350>
    assert(pp >= pages);
  80416045e3:	48 39 fa             	cmp    %rdi,%rdx
  80416045e6:	0f 82 49 fe ff ff    	jb     8041604435 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  80416045ec:	4c 39 c2             	cmp    %r8,%rdx
  80416045ef:	0f 83 75 fe ff ff    	jae    804160446a <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416045f5:	48 89 d1             	mov    %rdx,%rcx
  80416045f8:	48 29 f9             	sub    %rdi,%rcx
  80416045fb:	f6 c1 0f             	test   $0xf,%cl
  80416045fe:	0f 85 9b fe ff ff    	jne    804160449f <check_page_free_list+0x159>
  return (pp - pages) << PGSHIFT;
  8041604604:	48 c1 f9 04          	sar    $0x4,%rcx
  8041604608:	48 c1 e1 0c          	shl    $0xc,%rcx
  804160460c:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  804160460f:	0f 84 bf fe ff ff    	je     80416044d4 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604615:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  804160461c:	0f 84 e7 fe ff ff    	je     8041604509 <check_page_free_list+0x1c3>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  8041604622:	48 81 fe 00 f0 0f 00 	cmp    $0xff000,%rsi
  8041604629:	0f 84 0f ff ff ff    	je     804160453e <check_page_free_list+0x1f8>
    assert(page2pa(pp) != EXTPHYSMEM);
  804160462f:	48 81 fe 00 00 10 00 	cmp    $0x100000,%rsi
  8041604636:	0f 84 37 ff ff ff    	je     8041604573 <check_page_free_list+0x22d>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
  804160463c:	48 81 fe ff ff 0f 00 	cmp    $0xfffff,%rsi
  8041604643:	76 92                	jbe    80416045d7 <check_page_free_list+0x291>
  if (PGNUM(pa) >= npages)
  8041604645:	49 89 f2             	mov    %rsi,%r10
  8041604648:	49 c1 ea 0c          	shr    $0xc,%r10
  804160464c:	4d 39 d3             	cmp    %r10,%r11
  804160464f:	0f 86 53 ff ff ff    	jbe    80416045a8 <check_page_free_list+0x262>
  return (void *)(pa + KERNBASE);
  8041604655:	48 01 de             	add    %rbx,%rsi
  8041604658:	48 39 f0             	cmp    %rsi,%rax
  804160465b:	0f 86 72 ff ff ff    	jbe    80416045d3 <check_page_free_list+0x28d>
  8041604661:	48 b9 68 d7 60 41 80 	movabs $0x804160d768,%rcx
  8041604668:	00 00 00 
  804160466b:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041604672:	00 00 00 
  8041604675:	be dc 03 00 00       	mov    $0x3dc,%esi
  804160467a:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604681:	00 00 00 
  8041604684:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604689:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604690:	00 00 00 
  8041604693:	41 ff d0             	callq  *%r8
  assert(nfree_extmem > 0);
  8041604696:	45 85 c9             	test   %r9d,%r9d
  8041604699:	7e 07                	jle    80416046a2 <check_page_free_list+0x35c>
}
  804160469b:	48 83 c4 28          	add    $0x28,%rsp
  804160469f:	5b                   	pop    %rbx
  80416046a0:	5d                   	pop    %rbp
  80416046a1:	c3                   	retq   
  assert(nfree_extmem > 0);
  80416046a2:	48 b9 89 e0 60 41 80 	movabs $0x804160e089,%rcx
  80416046a9:	00 00 00 
  80416046ac:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416046b3:	00 00 00 
  80416046b6:	be e5 03 00 00       	mov    $0x3e5,%esi
  80416046bb:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416046c2:	00 00 00 
  80416046c5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046ca:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416046d1:	00 00 00 
  80416046d4:	41 ff d0             	callq  *%r8
  if (!page_free_list)
  80416046d7:	48 a1 10 45 88 41 80 	movabs 0x8041884510,%rax
  80416046de:	00 00 00 
  80416046e1:	48 85 c0             	test   %rax,%rax
  80416046e4:	0f 84 21 fd ff ff    	je     804160440b <check_page_free_list+0xc5>
    struct PageInfo **tp[2] = {&pp1, &pp2};
  80416046ea:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  80416046ee:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  80416046f2:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  80416046f6:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  return (pp - pages) << PGSHIFT;
  80416046fa:	48 be 58 5a 88 41 80 	movabs $0x8041885a58,%rsi
  8041604701:	00 00 00 
  8041604704:	48 89 c2             	mov    %rax,%rdx
  8041604707:	48 2b 16             	sub    (%rsi),%rdx
  804160470a:	48 c1 e2 08          	shl    $0x8,%rdx
      int pagetype  = VPN(page2pa(pp)) >= pdx_limit;
  804160470e:	48 c1 ea 0c          	shr    $0xc,%rdx
      *tp[pagetype] = pp;
  8041604712:	0f 95 c2             	setne  %dl
  8041604715:	0f b6 d2             	movzbl %dl,%edx
  8041604718:	48 8b 4c d5 e0       	mov    -0x20(%rbp,%rdx,8),%rcx
  804160471d:	48 89 01             	mov    %rax,(%rcx)
      tp[pagetype]  = &pp->pp_link;
  8041604720:	48 89 44 d5 e0       	mov    %rax,-0x20(%rbp,%rdx,8)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604725:	48 8b 00             	mov    (%rax),%rax
  8041604728:	48 85 c0             	test   %rax,%rax
  804160472b:	75 d7                	jne    8041604704 <check_page_free_list+0x3be>
    *tp[1]         = 0;
  804160472d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8041604731:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    *tp[0]         = pp2;
  8041604738:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  804160473c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8041604740:	48 89 10             	mov    %rdx,(%rax)
    page_free_list = pp1;
  8041604743:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8041604747:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  804160474e:	00 00 00 
  8041604751:	e9 16 fc ff ff       	jmpq   804160436c <check_page_free_list+0x26>

0000008041604756 <is_page_allocatable>:
  if (!mmap_base || !mmap_end)
  8041604756:	48 b8 f0 44 88 41 80 	movabs $0x80418844f0,%rax
  804160475d:	00 00 00 
  8041604760:	48 8b 10             	mov    (%rax),%rdx
  8041604763:	48 85 d2             	test   %rdx,%rdx
  8041604766:	0f 84 93 00 00 00    	je     80416047ff <is_page_allocatable+0xa9>
  804160476c:	48 b8 e8 44 88 41 80 	movabs $0x80418844e8,%rax
  8041604773:	00 00 00 
  8041604776:	48 8b 30             	mov    (%rax),%rsi
  8041604779:	48 85 f6             	test   %rsi,%rsi
  804160477c:	0f 84 83 00 00 00    	je     8041604805 <is_page_allocatable+0xaf>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041604782:	48 39 f2             	cmp    %rsi,%rdx
  8041604785:	0f 83 80 00 00 00    	jae    804160480b <is_page_allocatable+0xb5>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  804160478b:	48 8b 42 08          	mov    0x8(%rdx),%rax
  804160478f:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  8041604793:	48 89 c1             	mov    %rax,%rcx
  8041604796:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  804160479a:	48 39 cf             	cmp    %rcx,%rdi
  804160479d:	73 05                	jae    80416047a4 <is_page_allocatable+0x4e>
  804160479f:	48 39 c7             	cmp    %rax,%rdi
  80416047a2:	73 34                	jae    80416047d8 <is_page_allocatable+0x82>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047a4:	48 b8 e0 44 88 41 80 	movabs $0x80418844e0,%rax
  80416047ab:	00 00 00 
  80416047ae:	4c 8b 00             	mov    (%rax),%r8
  80416047b1:	4c 01 c2             	add    %r8,%rdx
  80416047b4:	48 39 d6             	cmp    %rdx,%rsi
  80416047b7:	76 40                	jbe    80416047f9 <is_page_allocatable+0xa3>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  80416047b9:	48 8b 42 08          	mov    0x8(%rdx),%rax
  80416047bd:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  80416047c1:	48 89 c1             	mov    %rax,%rcx
  80416047c4:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  80416047c8:	48 39 f9             	cmp    %rdi,%rcx
  80416047cb:	0f 97 c1             	seta   %cl
  80416047ce:	48 39 f8             	cmp    %rdi,%rax
  80416047d1:	0f 96 c0             	setbe  %al
  80416047d4:	84 c1                	test   %al,%cl
  80416047d6:	74 d9                	je     80416047b1 <is_page_allocatable+0x5b>
      switch (mmap_curr->Type) {
  80416047d8:	8b 0a                	mov    (%rdx),%ecx
  80416047da:	85 c9                	test   %ecx,%ecx
  80416047dc:	74 33                	je     8041604811 <is_page_allocatable+0xbb>
  80416047de:	83 f9 04             	cmp    $0x4,%ecx
  80416047e1:	76 0a                	jbe    80416047ed <is_page_allocatable+0x97>
          return false;
  80416047e3:	b8 00 00 00 00       	mov    $0x0,%eax
      switch (mmap_curr->Type) {
  80416047e8:	83 f9 07             	cmp    $0x7,%ecx
  80416047eb:	75 29                	jne    8041604816 <is_page_allocatable+0xc0>
          if (mmap_curr->Attribute & EFI_MEMORY_WB)
  80416047ed:	48 8b 42 20          	mov    0x20(%rdx),%rax
  80416047f1:	48 c1 e8 03          	shr    $0x3,%rax
  80416047f5:	83 e0 01             	and    $0x1,%eax
  80416047f8:	c3                   	retq   
  return true;
  80416047f9:	b8 01 00 00 00       	mov    $0x1,%eax
  80416047fe:	c3                   	retq   
    return true; //Assume page is allocabale if no loading parameters were passed.
  80416047ff:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604804:	c3                   	retq   
  8041604805:	b8 01 00 00 00       	mov    $0x1,%eax
  804160480a:	c3                   	retq   
  return true;
  804160480b:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604810:	c3                   	retq   
          return false;
  8041604811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041604816:	c3                   	retq   

0000008041604817 <page_init>:
page_init(void) {
  8041604817:	55                   	push   %rbp
  8041604818:	48 89 e5             	mov    %rsp,%rbp
  804160481b:	41 57                	push   %r15
  804160481d:	41 56                	push   %r14
  804160481f:	41 55                	push   %r13
  8041604821:	41 54                	push   %r12
  8041604823:	53                   	push   %rbx
  8041604824:	48 83 ec 08          	sub    $0x8,%rsp
  pages[0].pp_ref  = 1;
  8041604828:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  804160482f:	00 00 00 
  8041604832:	48 8b 10             	mov    (%rax),%rdx
  8041604835:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
  pages[0].pp_link = NULL;
  804160483b:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  pages[1].pp_ref = 0;
  8041604842:	4c 8b 20             	mov    (%rax),%r12
  8041604845:	66 41 c7 44 24 18 00 	movw   $0x0,0x18(%r12)
  804160484c:	00 
  page_free_list  = &pages[1];
  804160484d:	49 83 c4 10          	add    $0x10,%r12
  8041604851:	4c 89 e0             	mov    %r12,%rax
  8041604854:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  804160485b:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  804160485e:	48 b8 18 45 88 41 80 	movabs $0x8041884518,%rax
  8041604865:	00 00 00 
  8041604868:	48 83 38 01          	cmpq   $0x1,(%rax)
  804160486c:	76 6a                	jbe    80416048d8 <page_init+0xc1>
  804160486e:	bb 01 00 00 00       	mov    $0x1,%ebx
    if (is_page_allocatable(i)) {
  8041604873:	49 bf 56 47 60 41 80 	movabs $0x8041604756,%r15
  804160487a:	00 00 00 
      pages[i].pp_ref  = 1;
  804160487d:	49 bd 58 5a 88 41 80 	movabs $0x8041885a58,%r13
  8041604884:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  8041604887:	49 89 c6             	mov    %rax,%r14
  804160488a:	eb 21                	jmp    80416048ad <page_init+0x96>
      pages[i].pp_ref  = 1;
  804160488c:	48 89 d8             	mov    %rbx,%rax
  804160488f:	48 c1 e0 04          	shl    $0x4,%rax
  8041604893:	49 03 45 00          	add    0x0(%r13),%rax
  8041604897:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  804160489d:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = 1; i < npages_basemem; i++) {
  80416048a4:	48 83 c3 01          	add    $0x1,%rbx
  80416048a8:	49 39 1e             	cmp    %rbx,(%r14)
  80416048ab:	76 2b                	jbe    80416048d8 <page_init+0xc1>
    if (is_page_allocatable(i)) {
  80416048ad:	48 89 df             	mov    %rbx,%rdi
  80416048b0:	41 ff d7             	callq  *%r15
  80416048b3:	84 c0                	test   %al,%al
  80416048b5:	74 d5                	je     804160488c <page_init+0x75>
      pages[i].pp_ref = 0;
  80416048b7:	48 89 d8             	mov    %rbx,%rax
  80416048ba:	48 c1 e0 04          	shl    $0x4,%rax
  80416048be:	48 89 c2             	mov    %rax,%rdx
  80416048c1:	49 03 55 00          	add    0x0(%r13),%rdx
  80416048c5:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  80416048cb:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  80416048cf:	49 03 45 00          	add    0x0(%r13),%rax
  80416048d3:	49 89 c4             	mov    %rax,%r12
  80416048d6:	eb cc                	jmp    80416048a4 <page_init+0x8d>
  first_free_page = PADDR(boot_alloc(0)) / PGSIZE;
  80416048d8:	bf 00 00 00 00       	mov    $0x0,%edi
  80416048dd:	48 b8 5e 42 60 41 80 	movabs $0x804160425e,%rax
  80416048e4:	00 00 00 
  80416048e7:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  80416048e9:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  80416048f0:	00 00 00 
  80416048f3:	48 39 d0             	cmp    %rdx,%rax
  80416048f6:	76 7d                	jbe    8041604975 <page_init+0x15e>
  return (physaddr_t)kva - KERNBASE;
  80416048f8:	48 bb 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rbx
  80416048ff:	ff ff ff 
  8041604902:	48 01 c3             	add    %rax,%rbx
  8041604905:	48 c1 eb 0c          	shr    $0xc,%rbx
  for (i = npages_basemem; i < first_free_page; i++) {
  8041604909:	48 a1 18 45 88 41 80 	movabs 0x8041884518,%rax
  8041604910:	00 00 00 
  8041604913:	48 39 c3             	cmp    %rax,%rbx
  8041604916:	76 31                	jbe    8041604949 <page_init+0x132>
  8041604918:	48 c1 e0 04          	shl    $0x4,%rax
  804160491c:	48 89 de             	mov    %rbx,%rsi
  804160491f:	48 c1 e6 04          	shl    $0x4,%rsi
    pages[i].pp_ref  = 1;
  8041604923:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  804160492a:	00 00 00 
  804160492d:	48 89 c2             	mov    %rax,%rdx
  8041604930:	48 03 11             	add    (%rcx),%rdx
  8041604933:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
    pages[i].pp_link = NULL;
  8041604939:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  for (i = npages_basemem; i < first_free_page; i++) {
  8041604940:	48 83 c0 10          	add    $0x10,%rax
  8041604944:	48 39 f0             	cmp    %rsi,%rax
  8041604947:	75 e4                	jne    804160492d <page_init+0x116>
  for (i = first_free_page; i < npages; i++) {
  8041604949:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041604950:	00 00 00 
  8041604953:	48 3b 18             	cmp    (%rax),%rbx
  8041604956:	0f 83 93 00 00 00    	jae    80416049ef <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  804160495c:	49 bf 56 47 60 41 80 	movabs $0x8041604756,%r15
  8041604963:	00 00 00 
      pages[i].pp_ref  = 1;
  8041604966:	49 bd 58 5a 88 41 80 	movabs $0x8041885a58,%r13
  804160496d:	00 00 00 
  for (i = first_free_page; i < npages; i++) {
  8041604970:	49 89 c6             	mov    %rax,%r14
  8041604973:	eb 4f                	jmp    80416049c4 <page_init+0x1ad>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041604975:	48 89 c1             	mov    %rax,%rcx
  8041604978:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160497f:	00 00 00 
  8041604982:	be e9 01 00 00       	mov    $0x1e9,%esi
  8041604987:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160498e:	00 00 00 
  8041604991:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604996:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160499d:	00 00 00 
  80416049a0:	41 ff d0             	callq  *%r8
      pages[i].pp_ref  = 1;
  80416049a3:	48 89 d8             	mov    %rbx,%rax
  80416049a6:	48 c1 e0 04          	shl    $0x4,%rax
  80416049aa:	49 03 45 00          	add    0x0(%r13),%rax
  80416049ae:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  80416049b4:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = first_free_page; i < npages; i++) {
  80416049bb:	48 83 c3 01          	add    $0x1,%rbx
  80416049bf:	49 39 1e             	cmp    %rbx,(%r14)
  80416049c2:	76 2b                	jbe    80416049ef <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  80416049c4:	48 89 df             	mov    %rbx,%rdi
  80416049c7:	41 ff d7             	callq  *%r15
  80416049ca:	84 c0                	test   %al,%al
  80416049cc:	74 d5                	je     80416049a3 <page_init+0x18c>
      pages[i].pp_ref = 0;
  80416049ce:	48 89 d8             	mov    %rbx,%rax
  80416049d1:	48 c1 e0 04          	shl    $0x4,%rax
  80416049d5:	48 89 c2             	mov    %rax,%rdx
  80416049d8:	49 03 55 00          	add    0x0(%r13),%rdx
  80416049dc:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  80416049e2:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  80416049e6:	49 03 45 00          	add    0x0(%r13),%rax
  80416049ea:	49 89 c4             	mov    %rax,%r12
  80416049ed:	eb cc                	jmp    80416049bb <page_init+0x1a4>
}
  80416049ef:	48 83 c4 08          	add    $0x8,%rsp
  80416049f3:	5b                   	pop    %rbx
  80416049f4:	41 5c                	pop    %r12
  80416049f6:	41 5d                	pop    %r13
  80416049f8:	41 5e                	pop    %r14
  80416049fa:	41 5f                	pop    %r15
  80416049fc:	5d                   	pop    %rbp
  80416049fd:	c3                   	retq   

00000080416049fe <page_alloc>:
page_alloc(int alloc_flags) {
  80416049fe:	55                   	push   %rbp
  80416049ff:	48 89 e5             	mov    %rsp,%rbp
  8041604a02:	53                   	push   %rbx
  8041604a03:	48 83 ec 08          	sub    $0x8,%rsp
  if (!page_free_list) {
  8041604a07:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041604a0e:	00 00 00 
  8041604a11:	48 8b 18             	mov    (%rax),%rbx
  8041604a14:	48 85 db             	test   %rbx,%rbx
  8041604a17:	74 1f                	je     8041604a38 <page_alloc+0x3a>
  page_free_list               = page_free_list->pp_link;
  8041604a19:	48 8b 03             	mov    (%rbx),%rax
  8041604a1c:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  8041604a23:	00 00 00 
  return_page->pp_link         = NULL;
  8041604a26:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  if (!page_free_list) {
  8041604a2d:	48 85 c0             	test   %rax,%rax
  8041604a30:	74 10                	je     8041604a42 <page_alloc+0x44>
  if (alloc_flags & ALLOC_ZERO) {
  8041604a32:	40 f6 c7 01          	test   $0x1,%dil
  8041604a36:	75 1d                	jne    8041604a55 <page_alloc+0x57>
}
  8041604a38:	48 89 d8             	mov    %rbx,%rax
  8041604a3b:	48 83 c4 08          	add    $0x8,%rsp
  8041604a3f:	5b                   	pop    %rbx
  8041604a40:	5d                   	pop    %rbp
  8041604a41:	c3                   	retq   
    page_free_list_top = NULL;
  8041604a42:	48 b8 08 45 88 41 80 	movabs $0x8041884508,%rax
  8041604a49:	00 00 00 
  8041604a4c:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  8041604a53:	eb dd                	jmp    8041604a32 <page_alloc+0x34>
  return (pp - pages) << PGSHIFT;
  8041604a55:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041604a5c:	00 00 00 
  8041604a5f:	48 89 df             	mov    %rbx,%rdi
  8041604a62:	48 2b 38             	sub    (%rax),%rdi
  8041604a65:	48 c1 ff 04          	sar    $0x4,%rdi
  8041604a69:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041604a6d:	48 89 fa             	mov    %rdi,%rdx
  8041604a70:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041604a74:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041604a7b:	00 00 00 
  8041604a7e:	48 3b 10             	cmp    (%rax),%rdx
  8041604a81:	73 25                	jae    8041604aa8 <page_alloc+0xaa>
  return (void *)(pa + KERNBASE);
  8041604a83:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604a8a:	00 00 00 
  8041604a8d:	48 01 cf             	add    %rcx,%rdi
    memset(page2kva(return_page), 0, PGSIZE);
  8041604a90:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041604a95:	be 00 00 00 00       	mov    $0x0,%esi
  8041604a9a:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  8041604aa1:	00 00 00 
  8041604aa4:	ff d0                	callq  *%rax
  8041604aa6:	eb 90                	jmp    8041604a38 <page_alloc+0x3a>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604aa8:	48 89 f9             	mov    %rdi,%rcx
  8041604aab:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041604ab2:	00 00 00 
  8041604ab5:	be 61 00 00 00       	mov    $0x61,%esi
  8041604aba:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041604ac1:	00 00 00 
  8041604ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ac9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604ad0:	00 00 00 
  8041604ad3:	41 ff d0             	callq  *%r8

0000008041604ad6 <page_is_allocated>:
  return !pp->pp_link && pp != page_free_list_top;
  8041604ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604adb:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604adf:	74 01                	je     8041604ae2 <page_is_allocated+0xc>
}
  8041604ae1:	c3                   	retq   
  return !pp->pp_link && pp != page_free_list_top;
  8041604ae2:	48 b8 08 45 88 41 80 	movabs $0x8041884508,%rax
  8041604ae9:	00 00 00 
  8041604aec:	48 39 38             	cmp    %rdi,(%rax)
  8041604aef:	0f 95 c0             	setne  %al
  8041604af2:	0f b6 c0             	movzbl %al,%eax
  8041604af5:	eb ea                	jmp    8041604ae1 <page_is_allocated+0xb>

0000008041604af7 <page_free>:
  if ((pp->pp_ref != 0) || (pp->pp_link != NULL)) {
  8041604af7:	66 83 7f 08 00       	cmpw   $0x0,0x8(%rdi)
  8041604afc:	75 2a                	jne    8041604b28 <page_free+0x31>
  8041604afe:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604b02:	75 24                	jne    8041604b28 <page_free+0x31>
  pp->pp_link    = page_free_list;
  8041604b04:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041604b0b:	00 00 00 
  8041604b0e:	48 8b 10             	mov    (%rax),%rdx
  8041604b11:	48 89 17             	mov    %rdx,(%rdi)
  page_free_list = pp;
  8041604b14:	48 89 38             	mov    %rdi,(%rax)
  if (!page_free_list_top) {
  8041604b17:	48 b8 08 45 88 41 80 	movabs $0x8041884508,%rax
  8041604b1e:	00 00 00 
  8041604b21:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604b25:	74 2f                	je     8041604b56 <page_free+0x5f>
  8041604b27:	c3                   	retq   
page_free(struct PageInfo *pp) {
  8041604b28:	55                   	push   %rbp
  8041604b29:	48 89 e5             	mov    %rsp,%rbp
    panic("page_free: Page cannot be freed!\n");
  8041604b2c:	48 ba b0 d7 60 41 80 	movabs $0x804160d7b0,%rdx
  8041604b33:	00 00 00 
  8041604b36:	be 35 02 00 00       	mov    $0x235,%esi
  8041604b3b:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604b42:	00 00 00 
  8041604b45:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b4a:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604b51:	00 00 00 
  8041604b54:	ff d1                	callq  *%rcx
    page_free_list_top = pp;
  8041604b56:	48 89 f8             	mov    %rdi,%rax
  8041604b59:	48 a3 08 45 88 41 80 	movabs %rax,0x8041884508
  8041604b60:	00 00 00 
}
  8041604b63:	eb c2                	jmp    8041604b27 <page_free+0x30>

0000008041604b65 <page_decref>:
  if (--pp->pp_ref == 0)
  8041604b65:	0f b7 47 08          	movzwl 0x8(%rdi),%eax
  8041604b69:	83 e8 01             	sub    $0x1,%eax
  8041604b6c:	66 89 47 08          	mov    %ax,0x8(%rdi)
  8041604b70:	66 85 c0             	test   %ax,%ax
  8041604b73:	74 01                	je     8041604b76 <page_decref+0x11>
  8041604b75:	c3                   	retq   
page_decref(struct PageInfo *pp) {
  8041604b76:	55                   	push   %rbp
  8041604b77:	48 89 e5             	mov    %rsp,%rbp
    page_free(pp);
  8041604b7a:	48 b8 f7 4a 60 41 80 	movabs $0x8041604af7,%rax
  8041604b81:	00 00 00 
  8041604b84:	ff d0                	callq  *%rax
}
  8041604b86:	5d                   	pop    %rbp
  8041604b87:	c3                   	retq   

0000008041604b88 <pgdir_walk>:
pgdir_walk(pde_t *pgdir, const void *va, int create) {
  8041604b88:	55                   	push   %rbp
  8041604b89:	48 89 e5             	mov    %rsp,%rbp
  8041604b8c:	41 54                	push   %r12
  8041604b8e:	53                   	push   %rbx
  8041604b8f:	48 89 f3             	mov    %rsi,%rbx
  if (pgdir[PDX(va)] & PTE_P) {
  8041604b92:	49 89 f4             	mov    %rsi,%r12
  8041604b95:	49 c1 ec 12          	shr    $0x12,%r12
  8041604b99:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
  8041604ba0:	49 01 fc             	add    %rdi,%r12
  8041604ba3:	49 8b 0c 24          	mov    (%r12),%rcx
  8041604ba7:	f6 c1 01             	test   $0x1,%cl
  8041604baa:	74 68                	je     8041604c14 <pgdir_walk+0x8c>
		return (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
  8041604bac:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604bb3:	48 89 c8             	mov    %rcx,%rax
  8041604bb6:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604bba:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604bc1:	00 00 00 
  8041604bc4:	48 39 02             	cmp    %rax,(%rdx)
  8041604bc7:	76 20                	jbe    8041604be9 <pgdir_walk+0x61>
  return (void *)(pa + KERNBASE);
  8041604bc9:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041604bd0:	00 00 00 
  8041604bd3:	48 01 c1             	add    %rax,%rcx
  8041604bd6:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604bda:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604be0:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
}
  8041604be4:	5b                   	pop    %rbx
  8041604be5:	41 5c                	pop    %r12
  8041604be7:	5d                   	pop    %rbp
  8041604be8:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604be9:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041604bf0:	00 00 00 
  8041604bf3:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041604bf8:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604bff:	00 00 00 
  8041604c02:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604c07:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604c0e:	00 00 00 
  8041604c11:	41 ff d0             	callq  *%r8
	if (create) {
  8041604c14:	85 d2                	test   %edx,%edx
  8041604c16:	0f 84 aa 00 00 00    	je     8041604cc6 <pgdir_walk+0x13e>
    np = page_alloc(ALLOC_ZERO);
  8041604c1c:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604c21:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041604c28:	00 00 00 
  8041604c2b:	ff d0                	callq  *%rax
    if (np) {
  8041604c2d:	48 85 c0             	test   %rax,%rax
  8041604c30:	74 b2                	je     8041604be4 <pgdir_walk+0x5c>
        np->pp_ref++;
  8041604c32:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604c37:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  8041604c3e:	00 00 00 
  8041604c41:	48 89 c2             	mov    %rax,%rdx
  8041604c44:	48 2b 11             	sub    (%rcx),%rdx
  8041604c47:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604c4b:	48 c1 e2 0c          	shl    $0xc,%rdx
        pgdir[PDX(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604c4f:	48 83 ca 07          	or     $0x7,%rdx
  8041604c53:	49 89 14 24          	mov    %rdx,(%r12)
  8041604c57:	48 2b 01             	sub    (%rcx),%rax
  8041604c5a:	48 c1 f8 04          	sar    $0x4,%rax
  8041604c5e:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  8041604c62:	48 89 c1             	mov    %rax,%rcx
  8041604c65:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604c69:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604c70:	00 00 00 
  8041604c73:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604c76:	73 20                	jae    8041604c98 <pgdir_walk+0x110>
  return (void *)(pa + KERNBASE);
  8041604c78:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604c7f:	00 00 00 
  8041604c82:	48 01 c1             	add    %rax,%rcx
        return (pte_t *) page2kva(np) + PTX(va);
  8041604c85:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604c89:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604c8f:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
  8041604c93:	e9 4c ff ff ff       	jmpq   8041604be4 <pgdir_walk+0x5c>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604c98:	48 89 c1             	mov    %rax,%rcx
  8041604c9b:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041604ca2:	00 00 00 
  8041604ca5:	be 61 00 00 00       	mov    $0x61,%esi
  8041604caa:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041604cb1:	00 00 00 
  8041604cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604cb9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604cc0:	00 00 00 
  8041604cc3:	41 ff d0             	callq  *%r8
	return NULL;
  8041604cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ccb:	e9 14 ff ff ff       	jmpq   8041604be4 <pgdir_walk+0x5c>

0000008041604cd0 <pdpe_walk>:
pdpe_walk(pdpe_t *pdpe, const void *va, int create) {
  8041604cd0:	55                   	push   %rbp
  8041604cd1:	48 89 e5             	mov    %rsp,%rbp
  8041604cd4:	41 55                	push   %r13
  8041604cd6:	41 54                	push   %r12
  8041604cd8:	53                   	push   %rbx
  8041604cd9:	48 83 ec 08          	sub    $0x8,%rsp
  8041604cdd:	48 89 f3             	mov    %rsi,%rbx
  8041604ce0:	41 89 d4             	mov    %edx,%r12d
  if (pdpe[PDPE(va)] & PTE_P) {
  8041604ce3:	49 89 f5             	mov    %rsi,%r13
  8041604ce6:	49 c1 ed 1b          	shr    $0x1b,%r13
  8041604cea:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604cf1:	49 01 fd             	add    %rdi,%r13
  8041604cf4:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604cf8:	f6 c1 01             	test   $0x1,%cl
  8041604cfb:	74 6f                	je     8041604d6c <pdpe_walk+0x9c>
		return pgdir_walk((pte_t *) KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604cfd:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604d04:	48 89 c8             	mov    %rcx,%rax
  8041604d07:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604d0b:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604d12:	00 00 00 
  8041604d15:	48 39 02             	cmp    %rax,(%rdx)
  8041604d18:	76 27                	jbe    8041604d41 <pdpe_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604d1a:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604d21:	00 00 00 
  8041604d24:	48 01 cf             	add    %rcx,%rdi
  8041604d27:	44 89 e2             	mov    %r12d,%edx
  8041604d2a:	48 b8 88 4b 60 41 80 	movabs $0x8041604b88,%rax
  8041604d31:	00 00 00 
  8041604d34:	ff d0                	callq  *%rax
}
  8041604d36:	48 83 c4 08          	add    $0x8,%rsp
  8041604d3a:	5b                   	pop    %rbx
  8041604d3b:	41 5c                	pop    %r12
  8041604d3d:	41 5d                	pop    %r13
  8041604d3f:	5d                   	pop    %rbp
  8041604d40:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604d41:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041604d48:	00 00 00 
  8041604d4b:	be 77 02 00 00       	mov    $0x277,%esi
  8041604d50:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604d57:	00 00 00 
  8041604d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d5f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604d66:	00 00 00 
  8041604d69:	41 ff d0             	callq  *%r8
	if (create) {
  8041604d6c:	85 d2                	test   %edx,%edx
  8041604d6e:	0f 84 a3 00 00 00    	je     8041604e17 <pdpe_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604d74:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604d79:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041604d80:	00 00 00 
  8041604d83:	ff d0                	callq  *%rax
    if (np) {
  8041604d85:	48 85 c0             	test   %rax,%rax
  8041604d88:	74 ac                	je     8041604d36 <pdpe_walk+0x66>
      np->pp_ref++;
  8041604d8a:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604d8f:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041604d96:	00 00 00 
  8041604d99:	48 2b 02             	sub    (%rdx),%rax
  8041604d9c:	48 c1 f8 04          	sar    $0x4,%rax
  8041604da0:	48 c1 e0 0c          	shl    $0xc,%rax
      pdpe[PDPE(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604da4:	48 89 c2             	mov    %rax,%rdx
  8041604da7:	48 83 ca 07          	or     $0x7,%rdx
  8041604dab:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604daf:	48 89 c1             	mov    %rax,%rcx
  8041604db2:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604db6:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604dbd:	00 00 00 
  8041604dc0:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604dc3:	73 24                	jae    8041604de9 <pdpe_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604dc5:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604dcc:	00 00 00 
  8041604dcf:	48 01 c7             	add    %rax,%rdi
      return pgdir_walk((pte_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604dd2:	44 89 e2             	mov    %r12d,%edx
  8041604dd5:	48 89 de             	mov    %rbx,%rsi
  8041604dd8:	48 b8 88 4b 60 41 80 	movabs $0x8041604b88,%rax
  8041604ddf:	00 00 00 
  8041604de2:	ff d0                	callq  *%rax
  8041604de4:	e9 4d ff ff ff       	jmpq   8041604d36 <pdpe_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604de9:	48 89 c1             	mov    %rax,%rcx
  8041604dec:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041604df3:	00 00 00 
  8041604df6:	be 7f 02 00 00       	mov    $0x27f,%esi
  8041604dfb:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604e02:	00 00 00 
  8041604e05:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e0a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604e11:	00 00 00 
  8041604e14:	41 ff d0             	callq  *%r8
	return NULL;
  8041604e17:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e1c:	e9 15 ff ff ff       	jmpq   8041604d36 <pdpe_walk+0x66>

0000008041604e21 <pml4e_walk>:
pml4e_walk(pml4e_t *pml4e, const void *va, int create) {
  8041604e21:	55                   	push   %rbp
  8041604e22:	48 89 e5             	mov    %rsp,%rbp
  8041604e25:	41 55                	push   %r13
  8041604e27:	41 54                	push   %r12
  8041604e29:	53                   	push   %rbx
  8041604e2a:	48 83 ec 08          	sub    $0x8,%rsp
  8041604e2e:	48 89 f3             	mov    %rsi,%rbx
  8041604e31:	41 89 d4             	mov    %edx,%r12d
  if (pml4e[PML4(va)] & PTE_P) {
  8041604e34:	49 89 f5             	mov    %rsi,%r13
  8041604e37:	49 c1 ed 24          	shr    $0x24,%r13
  8041604e3b:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604e42:	49 01 fd             	add    %rdi,%r13
  8041604e45:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604e49:	f6 c1 01             	test   $0x1,%cl
  8041604e4c:	74 6f                	je     8041604ebd <pml4e_walk+0x9c>
		return pdpe_walk((pdpe_t *) KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604e4e:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604e55:	48 89 c8             	mov    %rcx,%rax
  8041604e58:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604e5c:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604e63:	00 00 00 
  8041604e66:	48 39 02             	cmp    %rax,(%rdx)
  8041604e69:	76 27                	jbe    8041604e92 <pml4e_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604e6b:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604e72:	00 00 00 
  8041604e75:	48 01 cf             	add    %rcx,%rdi
  8041604e78:	44 89 e2             	mov    %r12d,%edx
  8041604e7b:	48 b8 d0 4c 60 41 80 	movabs $0x8041604cd0,%rax
  8041604e82:	00 00 00 
  8041604e85:	ff d0                	callq  *%rax
}
  8041604e87:	48 83 c4 08          	add    $0x8,%rsp
  8041604e8b:	5b                   	pop    %rbx
  8041604e8c:	41 5c                	pop    %r12
  8041604e8e:	41 5d                	pop    %r13
  8041604e90:	5d                   	pop    %rbp
  8041604e91:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604e92:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041604e99:	00 00 00 
  8041604e9c:	be 62 02 00 00       	mov    $0x262,%esi
  8041604ea1:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604ea8:	00 00 00 
  8041604eab:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604eb0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604eb7:	00 00 00 
  8041604eba:	41 ff d0             	callq  *%r8
	if (create) {
  8041604ebd:	85 d2                	test   %edx,%edx
  8041604ebf:	0f 84 a3 00 00 00    	je     8041604f68 <pml4e_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604ec5:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604eca:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041604ed1:	00 00 00 
  8041604ed4:	ff d0                	callq  *%rax
    if (np) {
  8041604ed6:	48 85 c0             	test   %rax,%rax
  8041604ed9:	74 ac                	je     8041604e87 <pml4e_walk+0x66>
      np->pp_ref++;
  8041604edb:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604ee0:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041604ee7:	00 00 00 
  8041604eea:	48 2b 02             	sub    (%rdx),%rax
  8041604eed:	48 c1 f8 04          	sar    $0x4,%rax
  8041604ef1:	48 c1 e0 0c          	shl    $0xc,%rax
      pml4e[PML4(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604ef5:	48 89 c2             	mov    %rax,%rdx
  8041604ef8:	48 83 ca 07          	or     $0x7,%rdx
  8041604efc:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604f00:	48 89 c1             	mov    %rax,%rcx
  8041604f03:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604f07:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604f0e:	00 00 00 
  8041604f11:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604f14:	73 24                	jae    8041604f3a <pml4e_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604f16:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604f1d:	00 00 00 
  8041604f20:	48 01 c7             	add    %rax,%rdi
      return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604f23:	44 89 e2             	mov    %r12d,%edx
  8041604f26:	48 89 de             	mov    %rbx,%rsi
  8041604f29:	48 b8 d0 4c 60 41 80 	movabs $0x8041604cd0,%rax
  8041604f30:	00 00 00 
  8041604f33:	ff d0                	callq  *%rax
  8041604f35:	e9 4d ff ff ff       	jmpq   8041604e87 <pml4e_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604f3a:	48 89 c1             	mov    %rax,%rcx
  8041604f3d:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041604f44:	00 00 00 
  8041604f47:	be 6a 02 00 00       	mov    $0x26a,%esi
  8041604f4c:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041604f53:	00 00 00 
  8041604f56:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f5b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604f62:	00 00 00 
  8041604f65:	41 ff d0             	callq  *%r8
	return NULL;
  8041604f68:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f6d:	e9 15 ff ff ff       	jmpq   8041604e87 <pml4e_walk+0x66>

0000008041604f72 <boot_map_region>:
  for (i = 0; i < size; i += PGSIZE) {
  8041604f72:	48 85 d2             	test   %rdx,%rdx
  8041604f75:	74 72                	je     8041604fe9 <boot_map_region+0x77>
boot_map_region(pml4e_t *pml4e, uintptr_t va, size_t size, physaddr_t pa, int perm) {
  8041604f77:	55                   	push   %rbp
  8041604f78:	48 89 e5             	mov    %rsp,%rbp
  8041604f7b:	41 57                	push   %r15
  8041604f7d:	41 56                	push   %r14
  8041604f7f:	41 55                	push   %r13
  8041604f81:	41 54                	push   %r12
  8041604f83:	53                   	push   %rbx
  8041604f84:	48 83 ec 28          	sub    $0x28,%rsp
  8041604f88:	44 89 45 bc          	mov    %r8d,-0x44(%rbp)
  8041604f8c:	49 89 ce             	mov    %rcx,%r14
  8041604f8f:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041604f93:	49 89 f5             	mov    %rsi,%r13
  8041604f96:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  for (i = 0; i < size; i += PGSIZE) {
  8041604f9a:	41 bc 00 00 00 00    	mov    $0x0,%r12d
		*pml4e_walk(pml4e, (void *)(va + i), 1) = (pa + i) | perm | PTE_P;
  8041604fa0:	49 bf 21 4e 60 41 80 	movabs $0x8041604e21,%r15
  8041604fa7:	00 00 00 
  8041604faa:	4b 8d 1c 26          	lea    (%r14,%r12,1),%rbx
  8041604fae:	48 63 45 bc          	movslq -0x44(%rbp),%rax
  8041604fb2:	48 09 c3             	or     %rax,%rbx
  8041604fb5:	4b 8d 74 25 00       	lea    0x0(%r13,%r12,1),%rsi
  8041604fba:	ba 01 00 00 00       	mov    $0x1,%edx
  8041604fbf:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041604fc3:	41 ff d7             	callq  *%r15
  8041604fc6:	48 83 cb 01          	or     $0x1,%rbx
  8041604fca:	48 89 18             	mov    %rbx,(%rax)
  for (i = 0; i < size; i += PGSIZE) {
  8041604fcd:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041604fd4:	4c 39 65 c0          	cmp    %r12,-0x40(%rbp)
  8041604fd8:	77 d0                	ja     8041604faa <boot_map_region+0x38>
}
  8041604fda:	48 83 c4 28          	add    $0x28,%rsp
  8041604fde:	5b                   	pop    %rbx
  8041604fdf:	41 5c                	pop    %r12
  8041604fe1:	41 5d                	pop    %r13
  8041604fe3:	41 5e                	pop    %r14
  8041604fe5:	41 5f                	pop    %r15
  8041604fe7:	5d                   	pop    %rbp
  8041604fe8:	c3                   	retq   
  8041604fe9:	c3                   	retq   

0000008041604fea <page_lookup>:
page_lookup(pml4e_t *pml4e, void *va, pte_t **pte_store) {
  8041604fea:	55                   	push   %rbp
  8041604feb:	48 89 e5             	mov    %rsp,%rbp
  8041604fee:	53                   	push   %rbx
  8041604fef:	48 83 ec 08          	sub    $0x8,%rsp
  8041604ff3:	48 89 d3             	mov    %rdx,%rbx
	ptep = pml4e_walk(pml4e, va, 0);
  8041604ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  8041604ffb:	48 b8 21 4e 60 41 80 	movabs $0x8041604e21,%rax
  8041605002:	00 00 00 
  8041605005:	ff d0                	callq  *%rax
	if (!ptep) {
  8041605007:	48 85 c0             	test   %rax,%rax
  804160500a:	74 3c                	je     8041605048 <page_lookup+0x5e>
	if (pte_store) {
  804160500c:	48 85 db             	test   %rbx,%rbx
  804160500f:	74 03                	je     8041605014 <page_lookup+0x2a>
		*pte_store = ptep;
  8041605011:	48 89 03             	mov    %rax,(%rbx)
	return pa2page(PTE_ADDR(*ptep));
  8041605014:	48 8b 30             	mov    (%rax),%rsi
  8041605017:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
}

static inline struct PageInfo *
pa2page(physaddr_t pa) {
  if (PPN(pa) >= npages) {
  804160501e:	48 89 f0             	mov    %rsi,%rax
  8041605021:	48 c1 e8 0c          	shr    $0xc,%rax
  8041605025:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  804160502c:	00 00 00 
  804160502f:	48 3b 02             	cmp    (%rdx),%rax
  8041605032:	73 1b                	jae    804160504f <page_lookup+0x65>
    cprintf("accessing %lx\n", (unsigned long)pa);
    panic("pa2page called with invalid pa");
  }
  return &pages[PPN(pa)];
  8041605034:	48 c1 e0 04          	shl    $0x4,%rax
  8041605038:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  804160503f:	00 00 00 
  8041605042:	48 8b 11             	mov    (%rcx),%rdx
  8041605045:	48 01 d0             	add    %rdx,%rax
}
  8041605048:	48 83 c4 08          	add    $0x8,%rsp
  804160504c:	5b                   	pop    %rbx
  804160504d:	5d                   	pop    %rbp
  804160504e:	c3                   	retq   
    cprintf("accessing %lx\n", (unsigned long)pa);
  804160504f:	48 bf 9a e0 60 41 80 	movabs $0x804160e09a,%rdi
  8041605056:	00 00 00 
  8041605059:	b8 00 00 00 00       	mov    $0x0,%eax
  804160505e:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041605065:	00 00 00 
  8041605068:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  804160506a:	48 ba d8 d7 60 41 80 	movabs $0x804160d7d8,%rdx
  8041605071:	00 00 00 
  8041605074:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041605079:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041605080:	00 00 00 
  8041605083:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605088:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160508f:	00 00 00 
  8041605092:	ff d1                	callq  *%rcx

0000008041605094 <tlb_invalidate>:
  if (!curenv || curenv->env_pml4e == pml4e)
  8041605094:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160509b:	00 00 00 
  804160509e:	48 85 c0             	test   %rax,%rax
  80416050a1:	74 09                	je     80416050ac <tlb_invalidate+0x18>
  80416050a3:	48 39 b8 e8 00 00 00 	cmp    %rdi,0xe8(%rax)
  80416050aa:	75 03                	jne    80416050af <tlb_invalidate+0x1b>
  __asm __volatile("invlpg (%0)"
  80416050ac:	0f 01 3e             	invlpg (%rsi)
}
  80416050af:	c3                   	retq   

00000080416050b0 <page_remove>:
page_remove(pml4e_t *pml4e, void *va) {
  80416050b0:	55                   	push   %rbp
  80416050b1:	48 89 e5             	mov    %rsp,%rbp
  80416050b4:	41 54                	push   %r12
  80416050b6:	53                   	push   %rbx
  80416050b7:	48 83 ec 10          	sub    $0x10,%rsp
  80416050bb:	48 89 fb             	mov    %rdi,%rbx
  80416050be:	49 89 f4             	mov    %rsi,%r12
	pp = page_lookup(pml4e, va, &ptep);
  80416050c1:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80416050c5:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  80416050cc:	00 00 00 
  80416050cf:	ff d0                	callq  *%rax
	if (pp) {
  80416050d1:	48 85 c0             	test   %rax,%rax
  80416050d4:	74 2c                	je     8041605102 <page_remove+0x52>
    page_decref(pp);
  80416050d6:	48 89 c7             	mov    %rax,%rdi
  80416050d9:	48 b8 65 4b 60 41 80 	movabs $0x8041604b65,%rax
  80416050e0:	00 00 00 
  80416050e3:	ff d0                	callq  *%rax
    *ptep = 0;
  80416050e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80416050e9:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    tlb_invalidate(pml4e, va);
  80416050f0:	4c 89 e6             	mov    %r12,%rsi
  80416050f3:	48 89 df             	mov    %rbx,%rdi
  80416050f6:	48 b8 94 50 60 41 80 	movabs $0x8041605094,%rax
  80416050fd:	00 00 00 
  8041605100:	ff d0                	callq  *%rax
}
  8041605102:	48 83 c4 10          	add    $0x10,%rsp
  8041605106:	5b                   	pop    %rbx
  8041605107:	41 5c                	pop    %r12
  8041605109:	5d                   	pop    %rbp
  804160510a:	c3                   	retq   

000000804160510b <page_insert>:
page_insert(pml4e_t *pml4e, struct PageInfo *pp, void *va, int perm) {
  804160510b:	55                   	push   %rbp
  804160510c:	48 89 e5             	mov    %rsp,%rbp
  804160510f:	41 57                	push   %r15
  8041605111:	41 56                	push   %r14
  8041605113:	41 55                	push   %r13
  8041605115:	41 54                	push   %r12
  8041605117:	53                   	push   %rbx
  8041605118:	48 83 ec 08          	sub    $0x8,%rsp
  804160511c:	49 89 fe             	mov    %rdi,%r14
  804160511f:	49 89 f4             	mov    %rsi,%r12
  8041605122:	49 89 d7             	mov    %rdx,%r15
  8041605125:	41 89 cd             	mov    %ecx,%r13d
	ptep = pml4e_walk(pml4e, va, 1);
  8041605128:	ba 01 00 00 00       	mov    $0x1,%edx
  804160512d:	4c 89 fe             	mov    %r15,%rsi
  8041605130:	48 b8 21 4e 60 41 80 	movabs $0x8041604e21,%rax
  8041605137:	00 00 00 
  804160513a:	ff d0                	callq  *%rax
	if (ptep == 0) {
  804160513c:	48 85 c0             	test   %rax,%rax
  804160513f:	0f 84 f0 00 00 00    	je     8041605235 <page_insert+0x12a>
  8041605145:	48 89 c3             	mov    %rax,%rbx
	if (*ptep & PTE_P) {
  8041605148:	48 8b 08             	mov    (%rax),%rcx
  804160514b:	f6 c1 01             	test   $0x1,%cl
  804160514e:	0f 84 a1 00 00 00    	je     80416051f5 <page_insert+0xea>
		if (PTE_ADDR(*ptep) == page2pa(pp)) {
  8041605154:	48 89 ca             	mov    %rcx,%rdx
  8041605157:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  804160515e:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605165:	00 00 00 
  8041605168:	4c 89 e6             	mov    %r12,%rsi
  804160516b:	48 2b 30             	sub    (%rax),%rsi
  804160516e:	48 89 f0             	mov    %rsi,%rax
  8041605171:	48 c1 f8 04          	sar    $0x4,%rax
  8041605175:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605179:	48 39 c2             	cmp    %rax,%rdx
  804160517c:	75 1d                	jne    804160519b <page_insert+0x90>
      *ptep = (*ptep & 0xfffff000) | perm | PTE_P;
  804160517e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  8041605184:	4d 63 ed             	movslq %r13d,%r13
  8041605187:	4c 09 e9             	or     %r13,%rcx
  804160518a:	48 83 c9 01          	or     $0x1,%rcx
  804160518e:	48 89 0b             	mov    %rcx,(%rbx)
  return 0;
  8041605191:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605196:	e9 8b 00 00 00       	jmpq   8041605226 <page_insert+0x11b>
			page_remove(pml4e, va);
  804160519b:	4c 89 fe             	mov    %r15,%rsi
  804160519e:	4c 89 f7             	mov    %r14,%rdi
  80416051a1:	48 b8 b0 50 60 41 80 	movabs $0x80416050b0,%rax
  80416051a8:	00 00 00 
  80416051ab:	ff d0                	callq  *%rax
  80416051ad:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  80416051b4:	00 00 00 
  80416051b7:	4c 89 e7             	mov    %r12,%rdi
  80416051ba:	48 2b 38             	sub    (%rax),%rdi
  80416051bd:	48 89 f8             	mov    %rdi,%rax
  80416051c0:	48 c1 f8 04          	sar    $0x4,%rax
  80416051c4:	48 c1 e0 0c          	shl    $0xc,%rax
			*ptep = page2pa(pp) | perm | PTE_P;
  80416051c8:	4d 63 ed             	movslq %r13d,%r13
  80416051cb:	49 09 c5             	or     %rax,%r13
  80416051ce:	49 83 cd 01          	or     $0x1,%r13
  80416051d2:	4c 89 2b             	mov    %r13,(%rbx)
			pp->pp_ref++;
  80416051d5:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
			tlb_invalidate(pml4e, va);
  80416051dc:	4c 89 fe             	mov    %r15,%rsi
  80416051df:	4c 89 f7             	mov    %r14,%rdi
  80416051e2:	48 b8 94 50 60 41 80 	movabs $0x8041605094,%rax
  80416051e9:	00 00 00 
  80416051ec:	ff d0                	callq  *%rax
  return 0;
  80416051ee:	b8 00 00 00 00       	mov    $0x0,%eax
  80416051f3:	eb 31                	jmp    8041605226 <page_insert+0x11b>
  80416051f5:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  80416051fc:	00 00 00 
  80416051ff:	4c 89 e1             	mov    %r12,%rcx
  8041605202:	48 2b 08             	sub    (%rax),%rcx
  8041605205:	48 c1 f9 04          	sar    $0x4,%rcx
  8041605209:	48 c1 e1 0c          	shl    $0xc,%rcx
		*ptep = page2pa(pp) | perm | PTE_P;
  804160520d:	4d 63 ed             	movslq %r13d,%r13
  8041605210:	4c 09 e9             	or     %r13,%rcx
  8041605213:	48 83 c9 01          	or     $0x1,%rcx
  8041605217:	48 89 0b             	mov    %rcx,(%rbx)
		pp->pp_ref++;
  804160521a:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
  return 0;
  8041605221:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041605226:	48 83 c4 08          	add    $0x8,%rsp
  804160522a:	5b                   	pop    %rbx
  804160522b:	41 5c                	pop    %r12
  804160522d:	41 5d                	pop    %r13
  804160522f:	41 5e                	pop    %r14
  8041605231:	41 5f                	pop    %r15
  8041605233:	5d                   	pop    %rbp
  8041605234:	c3                   	retq   
		return -E_NO_MEM;
  8041605235:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  804160523a:	eb ea                	jmp    8041605226 <page_insert+0x11b>

000000804160523c <mem_init>:
mem_init(void) {
  804160523c:	55                   	push   %rbp
  804160523d:	48 89 e5             	mov    %rsp,%rbp
  8041605240:	41 57                	push   %r15
  8041605242:	41 56                	push   %r14
  8041605244:	41 55                	push   %r13
  8041605246:	41 54                	push   %r12
  8041605248:	53                   	push   %rbx
  8041605249:	48 83 ec 38          	sub    $0x38,%rsp
  if (uefi_lp && uefi_lp->MemoryMap) {
  804160524d:	48 a1 00 00 62 41 80 	movabs 0x8041620000,%rax
  8041605254:	00 00 00 
  8041605257:	48 85 c0             	test   %rax,%rax
  804160525a:	74 0d                	je     8041605269 <mem_init+0x2d>
  804160525c:	48 8b 78 28          	mov    0x28(%rax),%rdi
  8041605260:	48 85 ff             	test   %rdi,%rdi
  8041605263:	0f 85 55 11 00 00    	jne    80416063be <mem_init+0x1182>
    npages_basemem = (mc146818_read16(NVRAM_BASELO) * 1024) / PGSIZE;
  8041605269:	bf 15 00 00 00       	mov    $0x15,%edi
  804160526e:	49 bc ed 8f 60 41 80 	movabs $0x8041608fed,%r12
  8041605275:	00 00 00 
  8041605278:	41 ff d4             	callq  *%r12
  804160527b:	c1 e0 0a             	shl    $0xa,%eax
  804160527e:	c1 e8 0c             	shr    $0xc,%eax
  8041605281:	48 ba 18 45 88 41 80 	movabs $0x8041884518,%rdx
  8041605288:	00 00 00 
  804160528b:	89 c0                	mov    %eax,%eax
  804160528d:	48 89 02             	mov    %rax,(%rdx)
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  8041605290:	bf 17 00 00 00       	mov    $0x17,%edi
  8041605295:	41 ff d4             	callq  *%r12
  8041605298:	89 c3                	mov    %eax,%ebx
    pextmem        = ((size_t)mc146818_read16(NVRAM_PEXTLO) * 1024 * 64);
  804160529a:	bf 34 00 00 00       	mov    $0x34,%edi
  804160529f:	41 ff d4             	callq  *%r12
  80416052a2:	89 c0                	mov    %eax,%eax
    if (pextmem)
  80416052a4:	48 c1 e0 10          	shl    $0x10,%rax
  80416052a8:	0f 84 87 11 00 00    	je     8041606435 <mem_init+0x11f9>
      npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  80416052ae:	48 05 00 00 f0 00    	add    $0xf00000,%rax
  80416052b4:	48 c1 e8 0c          	shr    $0xc,%rax
  80416052b8:	48 89 c3             	mov    %rax,%rbx
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  80416052bb:	48 8d b3 00 01 00 00 	lea    0x100(%rbx),%rsi
  80416052c2:	48 89 f0             	mov    %rsi,%rax
  80416052c5:	48 a3 50 5a 88 41 80 	movabs %rax,0x8041885a50
  80416052cc:	00 00 00 
          (unsigned long)(npages_extmem * PGSIZE / 1024));
  80416052cf:	48 89 d8             	mov    %rbx,%rax
  80416052d2:	48 c1 e0 0c          	shl    $0xc,%rax
  80416052d6:	48 c1 e8 0a          	shr    $0xa,%rax
  80416052da:	48 89 c1             	mov    %rax,%rcx
          (unsigned long)(npages_basemem * PGSIZE / 1024),
  80416052dd:	48 b8 18 45 88 41 80 	movabs $0x8041884518,%rax
  80416052e4:	00 00 00 
  80416052e7:	48 8b 10             	mov    (%rax),%rdx
  80416052ea:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416052ee:	48 c1 ea 0a          	shr    $0xa,%rdx
          (unsigned long)(npages * PGSIZE / 1024 / 1024),
  80416052f2:	48 c1 e6 0c          	shl    $0xc,%rsi
  80416052f6:	48 c1 ee 14          	shr    $0x14,%rsi
  cprintf("Physical memory: %luM available, base = %luK, extended = %luK\n",
  80416052fa:	48 bf f8 d7 60 41 80 	movabs $0x804160d7f8,%rdi
  8041605301:	00 00 00 
  8041605304:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605309:	49 b8 f2 91 60 41 80 	movabs $0x80416091f2,%r8
  8041605310:	00 00 00 
  8041605313:	41 ff d0             	callq  *%r8
  pml4e = boot_alloc(PGSIZE);
  8041605316:	bf 00 10 00 00       	mov    $0x1000,%edi
  804160531b:	48 b8 5e 42 60 41 80 	movabs $0x804160425e,%rax
  8041605322:	00 00 00 
  8041605325:	ff d0                	callq  *%rax
  8041605327:	48 89 c3             	mov    %rax,%rbx
  memset(pml4e, 0, PGSIZE);
  804160532a:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160532f:	be 00 00 00 00       	mov    $0x0,%esi
  8041605334:	48 89 c7             	mov    %rax,%rdi
  8041605337:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  804160533e:	00 00 00 
  8041605341:	ff d0                	callq  *%rax
  kern_pml4e = pml4e;
  8041605343:	48 89 d8             	mov    %rbx,%rax
  8041605346:	48 a3 40 5a 88 41 80 	movabs %rax,0x8041885a40
  804160534d:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  8041605350:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  8041605357:	00 00 00 
  804160535a:	48 39 c3             	cmp    %rax,%rbx
  804160535d:	0f 86 f5 10 00 00    	jbe    8041606458 <mem_init+0x121c>
  return (physaddr_t)kva - KERNBASE;
  8041605363:	48 b8 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rax
  804160536a:	ff ff ff 
  804160536d:	48 01 d8             	add    %rbx,%rax
  kern_cr3   = PADDR(pml4e);
  8041605370:	48 a3 48 5a 88 41 80 	movabs %rax,0x8041885a48
  8041605377:	00 00 00 
  kern_pml4e[PML4(UVPT)] = kern_cr3 | PTE_P | PTE_U;
  804160537a:	48 83 c8 05          	or     $0x5,%rax
  804160537e:	48 89 43 10          	mov    %rax,0x10(%rbx)
  pages = (struct PageInfo *)boot_alloc(sizeof(* pages) * npages);
  8041605382:	48 bb 50 5a 88 41 80 	movabs $0x8041885a50,%rbx
  8041605389:	00 00 00 
  804160538c:	8b 3b                	mov    (%rbx),%edi
  804160538e:	c1 e7 04             	shl    $0x4,%edi
  8041605391:	49 bc 5e 42 60 41 80 	movabs $0x804160425e,%r12
  8041605398:	00 00 00 
  804160539b:	41 ff d4             	callq  *%r12
  804160539e:	48 a3 58 5a 88 41 80 	movabs %rax,0x8041885a58
  80416053a5:	00 00 00 
	memset(pages, 0, sizeof(*pages) * npages);
  80416053a8:	48 8b 13             	mov    (%rbx),%rdx
  80416053ab:	48 c1 e2 04          	shl    $0x4,%rdx
  80416053af:	be 00 00 00 00       	mov    $0x0,%esi
  80416053b4:	48 89 c7             	mov    %rax,%rdi
  80416053b7:	48 bb 99 c4 60 41 80 	movabs $0x804160c499,%rbx
  80416053be:	00 00 00 
  80416053c1:	ff d3                	callq  *%rbx
  envs = (struct Env *)boot_alloc(sizeof(* envs) * NENV);
  80416053c3:	bf 00 80 04 00       	mov    $0x48000,%edi
  80416053c8:	41 ff d4             	callq  *%r12
  80416053cb:	48 a3 28 45 88 41 80 	movabs %rax,0x8041884528
  80416053d2:	00 00 00 
	memset(envs, 0, sizeof(*envs) * NENV);
  80416053d5:	ba 00 80 04 00       	mov    $0x48000,%edx
  80416053da:	be 00 00 00 00       	mov    $0x0,%esi
  80416053df:	48 89 c7             	mov    %rax,%rdi
  80416053e2:	ff d3                	callq  *%rbx
  page_init();
  80416053e4:	48 b8 17 48 60 41 80 	movabs $0x8041604817,%rax
  80416053eb:	00 00 00 
  80416053ee:	ff d0                	callq  *%rax
  check_page_free_list(1);
  80416053f0:	bf 01 00 00 00       	mov    $0x1,%edi
  80416053f5:	48 b8 46 43 60 41 80 	movabs $0x8041604346,%rax
  80416053fc:	00 00 00 
  80416053ff:	ff d0                	callq  *%rax
  void *va;
  int i;
  pp0 = pp1 = pp2 = pp3 = pp4 = pp5 = 0;

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041605401:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  8041605408:	00 00 00 
  804160540b:	48 8b 18             	mov    (%rax),%rbx
  804160540e:	48 89 5d a8          	mov    %rbx,-0x58(%rbp)
  kern_pml4e[0] = 0;
  8041605412:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  assert(pp0 = page_alloc(0));
  8041605419:	bf 00 00 00 00       	mov    $0x0,%edi
  804160541e:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041605425:	00 00 00 
  8041605428:	ff d0                	callq  *%rax
  804160542a:	49 89 c6             	mov    %rax,%r14
  804160542d:	48 85 c0             	test   %rax,%rax
  8041605430:	0f 84 50 10 00 00    	je     8041606486 <mem_init+0x124a>
  assert(pp1 = page_alloc(0));
  8041605436:	bf 00 00 00 00       	mov    $0x0,%edi
  804160543b:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041605442:	00 00 00 
  8041605445:	ff d0                	callq  *%rax
  8041605447:	49 89 c5             	mov    %rax,%r13
  804160544a:	48 85 c0             	test   %rax,%rax
  804160544d:	0f 84 68 10 00 00    	je     80416064bb <mem_init+0x127f>
  assert(pp2 = page_alloc(0));
  8041605453:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605458:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160545f:	00 00 00 
  8041605462:	ff d0                	callq  *%rax
  8041605464:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041605468:	48 85 c0             	test   %rax,%rax
  804160546b:	0f 84 7f 10 00 00    	je     80416064f0 <mem_init+0x12b4>
  assert(pp3 = page_alloc(0));
  8041605471:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605476:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160547d:	00 00 00 
  8041605480:	ff d0                	callq  *%rax
  8041605482:	48 89 c3             	mov    %rax,%rbx
  8041605485:	48 85 c0             	test   %rax,%rax
  8041605488:	0f 84 92 10 00 00    	je     8041606520 <mem_init+0x12e4>
  assert(pp4 = page_alloc(0));
  804160548e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605493:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160549a:	00 00 00 
  804160549d:	ff d0                	callq  *%rax
  804160549f:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  80416054a3:	48 85 c0             	test   %rax,%rax
  80416054a6:	0f 84 a9 10 00 00    	je     8041606555 <mem_init+0x1319>
  assert(pp5 = page_alloc(0));
  80416054ac:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054b1:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  80416054b8:	00 00 00 
  80416054bb:	ff d0                	callq  *%rax
  80416054bd:	48 85 c0             	test   %rax,%rax
  80416054c0:	0f 84 bf 10 00 00    	je     8041606585 <mem_init+0x1349>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  80416054c6:	4d 39 ee             	cmp    %r13,%r14
  80416054c9:	0f 84 e6 10 00 00    	je     80416065b5 <mem_init+0x1379>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416054cf:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  80416054d3:	49 39 f5             	cmp    %rsi,%r13
  80416054d6:	0f 84 0e 11 00 00    	je     80416065ea <mem_init+0x13ae>
  80416054dc:	49 39 f6             	cmp    %rsi,%r14
  80416054df:	0f 84 05 11 00 00    	je     80416065ea <mem_init+0x13ae>
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  80416054e5:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  80416054e9:	0f 84 30 11 00 00    	je     804160661f <mem_init+0x13e3>
  80416054ef:	49 39 dd             	cmp    %rbx,%r13
  80416054f2:	0f 84 27 11 00 00    	je     804160661f <mem_init+0x13e3>
  80416054f8:	49 39 de             	cmp    %rbx,%r14
  80416054fb:	0f 84 1e 11 00 00    	je     804160661f <mem_init+0x13e3>
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  8041605501:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  8041605505:	48 39 fb             	cmp    %rdi,%rbx
  8041605508:	0f 84 46 11 00 00    	je     8041606654 <mem_init+0x1418>
  804160550e:	48 39 7d b8          	cmp    %rdi,-0x48(%rbp)
  8041605512:	0f 94 c1             	sete   %cl
  8041605515:	49 39 fd             	cmp    %rdi,%r13
  8041605518:	0f 94 c2             	sete   %dl
  804160551b:	08 d1                	or     %dl,%cl
  804160551d:	0f 85 31 11 00 00    	jne    8041606654 <mem_init+0x1418>
  8041605523:	49 39 fe             	cmp    %rdi,%r14
  8041605526:	0f 84 28 11 00 00    	je     8041606654 <mem_init+0x1418>
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  804160552c:	48 39 45 b0          	cmp    %rax,-0x50(%rbp)
  8041605530:	0f 84 53 11 00 00    	je     8041606689 <mem_init+0x144d>
  8041605536:	48 39 c3             	cmp    %rax,%rbx
  8041605539:	0f 84 4a 11 00 00    	je     8041606689 <mem_init+0x144d>
  804160553f:	48 39 45 b8          	cmp    %rax,-0x48(%rbp)
  8041605543:	0f 84 40 11 00 00    	je     8041606689 <mem_init+0x144d>
  8041605549:	49 39 c5             	cmp    %rax,%r13
  804160554c:	0f 84 37 11 00 00    	je     8041606689 <mem_init+0x144d>
  8041605552:	49 39 c6             	cmp    %rax,%r14
  8041605555:	0f 84 2e 11 00 00    	je     8041606689 <mem_init+0x144d>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
  804160555b:	48 a1 10 45 88 41 80 	movabs 0x8041884510,%rax
  8041605562:	00 00 00 
  8041605565:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  assert(fl != NULL);
  8041605569:	48 85 c0             	test   %rax,%rax
  804160556c:	0f 84 4c 11 00 00    	je     80416066be <mem_init+0x1482>
  page_free_list = NULL;
  8041605572:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041605579:	00 00 00 
  804160557c:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // should be no free memory
  assert(!page_alloc(0));
  8041605583:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605588:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160558f:	00 00 00 
  8041605592:	ff d0                	callq  *%rax
  8041605594:	48 85 c0             	test   %rax,%rax
  8041605597:	0f 85 51 11 00 00    	jne    80416066ee <mem_init+0x14b2>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  804160559d:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  80416055a1:	be 00 00 00 00       	mov    $0x0,%esi
  80416055a6:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416055ad:	00 00 00 
  80416055b0:	48 8b 38             	mov    (%rax),%rdi
  80416055b3:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  80416055ba:	00 00 00 
  80416055bd:	ff d0                	callq  *%rax
  80416055bf:	48 85 c0             	test   %rax,%rax
  80416055c2:	0f 85 5b 11 00 00    	jne    8041606723 <mem_init+0x14e7>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  80416055c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416055cd:	ba 00 00 00 00       	mov    $0x0,%edx
  80416055d2:	4c 89 ee             	mov    %r13,%rsi
  80416055d5:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416055dc:	00 00 00 
  80416055df:	48 8b 38             	mov    (%rax),%rdi
  80416055e2:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  80416055e9:	00 00 00 
  80416055ec:	ff d0                	callq  *%rax
  80416055ee:	85 c0                	test   %eax,%eax
  80416055f0:	0f 89 62 11 00 00    	jns    8041606758 <mem_init+0x151c>

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
  80416055f6:	4c 89 f7             	mov    %r14,%rdi
  80416055f9:	48 b8 f7 4a 60 41 80 	movabs $0x8041604af7,%rax
  8041605600:	00 00 00 
  8041605603:	ff d0                	callq  *%rax
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  8041605605:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160560a:	ba 00 00 00 00       	mov    $0x0,%edx
  804160560f:	4c 89 ee             	mov    %r13,%rsi
  8041605612:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605619:	00 00 00 
  804160561c:	48 8b 38             	mov    (%rax),%rdi
  804160561f:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  8041605626:	00 00 00 
  8041605629:	ff d0                	callq  *%rax
  804160562b:	85 c0                	test   %eax,%eax
  804160562d:	0f 89 5a 11 00 00    	jns    804160678d <mem_init+0x1551>
  page_free(pp2);
  8041605633:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605637:	49 bc f7 4a 60 41 80 	movabs $0x8041604af7,%r12
  804160563e:	00 00 00 
  8041605641:	41 ff d4             	callq  *%r12
  page_free(pp3);
  8041605644:	48 89 df             	mov    %rbx,%rdi
  8041605647:	41 ff d4             	callq  *%r12

  //cprintf("pp0 ref count = %d\n",pp0->pp_ref);
  //cprintf("pp2 ref count = %d\n",pp2->pp_ref);
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  804160564a:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160564f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605654:	4c 89 ee             	mov    %r13,%rsi
  8041605657:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160565e:	00 00 00 
  8041605661:	48 8b 38             	mov    (%rax),%rdi
  8041605664:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  804160566b:	00 00 00 
  804160566e:	ff d0                	callq  *%rax
  8041605670:	85 c0                	test   %eax,%eax
  8041605672:	0f 85 4a 11 00 00    	jne    80416067c2 <mem_init+0x1586>
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041605678:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160567f:	00 00 00 
  8041605682:	4c 8b 20             	mov    (%rax),%r12
  8041605685:	49 8b 14 24          	mov    (%r12),%rdx
  8041605689:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041605690:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605697:	00 00 00 
  804160569a:	4c 8b 38             	mov    (%rax),%r15
  804160569d:	4c 89 f0             	mov    %r14,%rax
  80416056a0:	4c 29 f8             	sub    %r15,%rax
  80416056a3:	48 c1 f8 04          	sar    $0x4,%rax
  80416056a7:	48 c1 e0 0c          	shl    $0xc,%rax
  80416056ab:	48 39 c2             	cmp    %rax,%rdx
  80416056ae:	74 2b                	je     80416056db <mem_init+0x49f>
  80416056b0:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416056b4:	4c 29 f8             	sub    %r15,%rax
  80416056b7:	48 c1 f8 04          	sar    $0x4,%rax
  80416056bb:	48 c1 e0 0c          	shl    $0xc,%rax
  80416056bf:	48 39 c2             	cmp    %rax,%rdx
  80416056c2:	74 17                	je     80416056db <mem_init+0x49f>
  80416056c4:	48 89 d8             	mov    %rbx,%rax
  80416056c7:	4c 29 f8             	sub    %r15,%rax
  80416056ca:	48 c1 f8 04          	sar    $0x4,%rax
  80416056ce:	48 c1 e0 0c          	shl    $0xc,%rax
  80416056d2:	48 39 c2             	cmp    %rax,%rdx
  80416056d5:	0f 85 1c 11 00 00    	jne    80416067f7 <mem_init+0x15bb>
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  80416056db:	be 00 00 00 00       	mov    $0x0,%esi
  80416056e0:	4c 89 e7             	mov    %r12,%rdi
  80416056e3:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  80416056ea:	00 00 00 
  80416056ed:	ff d0                	callq  *%rax
  80416056ef:	4c 89 ea             	mov    %r13,%rdx
  80416056f2:	4c 29 fa             	sub    %r15,%rdx
  80416056f5:	48 c1 fa 04          	sar    $0x4,%rdx
  80416056f9:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416056fd:	48 39 d0             	cmp    %rdx,%rax
  8041605700:	0f 85 26 11 00 00    	jne    804160682c <mem_init+0x15f0>
  assert(pp1->pp_ref == 1);
  8041605706:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  804160570c:	0f 85 4f 11 00 00    	jne    8041606861 <mem_init+0x1625>
  //should be able to map pp3 at PGSIZE because pp0 is already allocated for page table
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041605712:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605717:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160571c:	48 89 de             	mov    %rbx,%rsi
  804160571f:	4c 89 e7             	mov    %r12,%rdi
  8041605722:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  8041605729:	00 00 00 
  804160572c:	ff d0                	callq  *%rax
  804160572e:	85 c0                	test   %eax,%eax
  8041605730:	0f 85 60 11 00 00    	jne    8041606896 <mem_init+0x165a>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041605736:	be 00 10 00 00       	mov    $0x1000,%esi
  804160573b:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605742:	00 00 00 
  8041605745:	48 8b 38             	mov    (%rax),%rdi
  8041605748:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  804160574f:	00 00 00 
  8041605752:	ff d0                	callq  *%rax
  8041605754:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  804160575b:	00 00 00 
  804160575e:	48 89 d9             	mov    %rbx,%rcx
  8041605761:	48 2b 0a             	sub    (%rdx),%rcx
  8041605764:	48 89 ca             	mov    %rcx,%rdx
  8041605767:	48 c1 fa 04          	sar    $0x4,%rdx
  804160576b:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160576f:	48 39 d0             	cmp    %rdx,%rax
  8041605772:	0f 85 53 11 00 00    	jne    80416068cb <mem_init+0x168f>
  assert(pp3->pp_ref == 2);
  8041605778:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  804160577d:	0f 85 7d 11 00 00    	jne    8041606900 <mem_init+0x16c4>

  // should be no free memory
  assert(!page_alloc(0));
  8041605783:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605788:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160578f:	00 00 00 
  8041605792:	ff d0                	callq  *%rax
  8041605794:	48 85 c0             	test   %rax,%rax
  8041605797:	0f 85 98 11 00 00    	jne    8041606935 <mem_init+0x16f9>

  // should be able to map pp3 at PGSIZE because it's already there
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  804160579d:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416057a2:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416057a7:	48 89 de             	mov    %rbx,%rsi
  80416057aa:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416057b1:	00 00 00 
  80416057b4:	48 8b 38             	mov    (%rax),%rdi
  80416057b7:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  80416057be:	00 00 00 
  80416057c1:	ff d0                	callq  *%rax
  80416057c3:	85 c0                	test   %eax,%eax
  80416057c5:	0f 85 9f 11 00 00    	jne    804160696a <mem_init+0x172e>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416057cb:	be 00 10 00 00       	mov    $0x1000,%esi
  80416057d0:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416057d7:	00 00 00 
  80416057da:	48 8b 38             	mov    (%rax),%rdi
  80416057dd:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  80416057e4:	00 00 00 
  80416057e7:	ff d0                	callq  *%rax
  80416057e9:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  80416057f0:	00 00 00 
  80416057f3:	48 89 d9             	mov    %rbx,%rcx
  80416057f6:	48 2b 0a             	sub    (%rdx),%rcx
  80416057f9:	48 89 ca             	mov    %rcx,%rdx
  80416057fc:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605800:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605804:	48 39 d0             	cmp    %rdx,%rax
  8041605807:	0f 85 92 11 00 00    	jne    804160699f <mem_init+0x1763>
  assert(pp3->pp_ref == 2);
  804160580d:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  8041605812:	0f 85 bc 11 00 00    	jne    80416069d4 <mem_init+0x1798>

  // pp3 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
  8041605818:	bf 00 00 00 00       	mov    $0x0,%edi
  804160581d:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041605824:	00 00 00 
  8041605827:	ff d0                	callq  *%rax
  8041605829:	48 85 c0             	test   %rax,%rax
  804160582c:	0f 85 d7 11 00 00    	jne    8041606a09 <mem_init+0x17cd>
  // check that pgdir_walk returns a pointer to the pte
  pdpe = KADDR(PTE_ADDR(kern_pml4e[PML4(PGSIZE)]));
  8041605832:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605839:	00 00 00 
  804160583c:	48 8b 38             	mov    (%rax),%rdi
  804160583f:	48 8b 0f             	mov    (%rdi),%rcx
  8041605842:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605849:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041605850:	00 00 00 
  8041605853:	48 89 ca             	mov    %rcx,%rdx
  8041605856:	48 c1 ea 0c          	shr    $0xc,%rdx
  804160585a:	48 39 c2             	cmp    %rax,%rdx
  804160585d:	0f 83 db 11 00 00    	jae    8041606a3e <mem_init+0x1802>
  pde  = KADDR(PTE_ADDR(pdpe[PDPE(PGSIZE)]));
  8041605863:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  804160586a:	00 00 00 
  804160586d:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  8041605871:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605878:	48 89 ca             	mov    %rcx,%rdx
  804160587b:	48 c1 ea 0c          	shr    $0xc,%rdx
  804160587f:	48 39 d0             	cmp    %rdx,%rax
  8041605882:	0f 86 e1 11 00 00    	jbe    8041606a69 <mem_init+0x182d>
  ptep = KADDR(PTE_ADDR(pde[PDX(PGSIZE)]));
  8041605888:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  804160588f:	00 00 00 
  8041605892:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  8041605896:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  804160589d:	48 89 ca             	mov    %rcx,%rdx
  80416058a0:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416058a4:	48 39 d0             	cmp    %rdx,%rax
  80416058a7:	0f 86 e7 11 00 00    	jbe    8041606a94 <mem_init+0x1858>
  return (void *)(pa + KERNBASE);
  80416058ad:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416058b4:	00 00 00 
  80416058b7:	48 01 c1             	add    %rax,%rcx
  80416058ba:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  80416058be:	ba 00 00 00 00       	mov    $0x0,%edx
  80416058c3:	be 00 10 00 00       	mov    $0x1000,%esi
  80416058c8:	48 b8 21 4e 60 41 80 	movabs $0x8041604e21,%rax
  80416058cf:	00 00 00 
  80416058d2:	ff d0                	callq  *%rax
  80416058d4:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416058d8:	48 8d 57 08          	lea    0x8(%rdi),%rdx
  80416058dc:	48 39 d0             	cmp    %rdx,%rax
  80416058df:	0f 85 da 11 00 00    	jne    8041606abf <mem_init+0x1883>

  // should be able to change permissions too.
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  80416058e5:	b9 04 00 00 00       	mov    $0x4,%ecx
  80416058ea:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416058ef:	48 89 de             	mov    %rbx,%rsi
  80416058f2:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416058f9:	00 00 00 
  80416058fc:	48 8b 38             	mov    (%rax),%rdi
  80416058ff:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  8041605906:	00 00 00 
  8041605909:	ff d0                	callq  *%rax
  804160590b:	85 c0                	test   %eax,%eax
  804160590d:	0f 85 e1 11 00 00    	jne    8041606af4 <mem_init+0x18b8>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041605913:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160591a:	00 00 00 
  804160591d:	4c 8b 20             	mov    (%rax),%r12
  8041605920:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605925:	4c 89 e7             	mov    %r12,%rdi
  8041605928:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  804160592f:	00 00 00 
  8041605932:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041605934:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  804160593b:	00 00 00 
  804160593e:	48 89 de             	mov    %rbx,%rsi
  8041605941:	48 2b 32             	sub    (%rdx),%rsi
  8041605944:	48 89 f2             	mov    %rsi,%rdx
  8041605947:	48 c1 fa 04          	sar    $0x4,%rdx
  804160594b:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160594f:	48 39 d0             	cmp    %rdx,%rax
  8041605952:	0f 85 d1 11 00 00    	jne    8041606b29 <mem_init+0x18ed>
  assert(pp3->pp_ref == 2);
  8041605958:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  804160595d:	0f 85 fb 11 00 00    	jne    8041606b5e <mem_init+0x1922>
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041605963:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605968:	be 00 10 00 00       	mov    $0x1000,%esi
  804160596d:	4c 89 e7             	mov    %r12,%rdi
  8041605970:	48 b8 21 4e 60 41 80 	movabs $0x8041604e21,%rax
  8041605977:	00 00 00 
  804160597a:	ff d0                	callq  *%rax
  804160597c:	f6 00 04             	testb  $0x4,(%rax)
  804160597f:	0f 84 0e 12 00 00    	je     8041606b93 <mem_init+0x1957>
  assert(kern_pml4e[0] & PTE_U);
  8041605985:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160598c:	00 00 00 
  804160598f:	48 8b 38             	mov    (%rax),%rdi
  8041605992:	f6 07 04             	testb  $0x4,(%rdi)
  8041605995:	0f 84 2d 12 00 00    	je     8041606bc8 <mem_init+0x198c>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  804160599b:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416059a0:	ba 00 00 20 00       	mov    $0x200000,%edx
  80416059a5:	4c 89 f6             	mov    %r14,%rsi
  80416059a8:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  80416059af:	00 00 00 
  80416059b2:	ff d0                	callq  *%rax
  80416059b4:	85 c0                	test   %eax,%eax
  80416059b6:	0f 89 41 12 00 00    	jns    8041606bfd <mem_init+0x19c1>

  // insert pp1 at PGSIZE (replacing pp3)
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  80416059bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416059c1:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416059c6:	4c 89 ee             	mov    %r13,%rsi
  80416059c9:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416059d0:	00 00 00 
  80416059d3:	48 8b 38             	mov    (%rax),%rdi
  80416059d6:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  80416059dd:	00 00 00 
  80416059e0:	ff d0                	callq  *%rax
  80416059e2:	85 c0                	test   %eax,%eax
  80416059e4:	0f 85 48 12 00 00    	jne    8041606c32 <mem_init+0x19f6>
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  80416059ea:	ba 00 00 00 00       	mov    $0x0,%edx
  80416059ef:	be 00 10 00 00       	mov    $0x1000,%esi
  80416059f4:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416059fb:	00 00 00 
  80416059fe:	48 8b 38             	mov    (%rax),%rdi
  8041605a01:	48 b8 21 4e 60 41 80 	movabs $0x8041604e21,%rax
  8041605a08:	00 00 00 
  8041605a0b:	ff d0                	callq  *%rax
  8041605a0d:	f6 00 04             	testb  $0x4,(%rax)
  8041605a10:	0f 85 51 12 00 00    	jne    8041606c67 <mem_init+0x1a2b>

  // should have pp1 at both 0 and PGSIZE
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041605a16:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605a1d:	00 00 00 
  8041605a20:	4c 8b 20             	mov    (%rax),%r12
  8041605a23:	be 00 00 00 00       	mov    $0x0,%esi
  8041605a28:	4c 89 e7             	mov    %r12,%rdi
  8041605a2b:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  8041605a32:	00 00 00 
  8041605a35:	ff d0                	callq  *%rax
  8041605a37:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041605a3e:	00 00 00 
  8041605a41:	4d 89 ef             	mov    %r13,%r15
  8041605a44:	4c 2b 3a             	sub    (%rdx),%r15
  8041605a47:	49 c1 ff 04          	sar    $0x4,%r15
  8041605a4b:	49 c1 e7 0c          	shl    $0xc,%r15
  8041605a4f:	4c 39 f8             	cmp    %r15,%rax
  8041605a52:	0f 85 44 12 00 00    	jne    8041606c9c <mem_init+0x1a60>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605a58:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605a5d:	4c 89 e7             	mov    %r12,%rdi
  8041605a60:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  8041605a67:	00 00 00 
  8041605a6a:	ff d0                	callq  *%rax
  8041605a6c:	49 39 c7             	cmp    %rax,%r15
  8041605a6f:	0f 85 5c 12 00 00    	jne    8041606cd1 <mem_init+0x1a95>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
  8041605a75:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  8041605a7b:	0f 85 85 12 00 00    	jne    8041606d06 <mem_init+0x1aca>
  assert(pp3->pp_ref == 1);
  8041605a81:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605a86:	0f 85 af 12 00 00    	jne    8041606d3b <mem_init+0x1aff>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pml4e, 0x0);
  8041605a8c:	be 00 00 00 00       	mov    $0x0,%esi
  8041605a91:	4c 89 e7             	mov    %r12,%rdi
  8041605a94:	48 b8 b0 50 60 41 80 	movabs $0x80416050b0,%rax
  8041605a9b:	00 00 00 
  8041605a9e:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605aa0:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605aa7:	00 00 00 
  8041605aaa:	4c 8b 20             	mov    (%rax),%r12
  8041605aad:	be 00 00 00 00       	mov    $0x0,%esi
  8041605ab2:	4c 89 e7             	mov    %r12,%rdi
  8041605ab5:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  8041605abc:	00 00 00 
  8041605abf:	ff d0                	callq  *%rax
  8041605ac1:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605ac5:	0f 85 a5 12 00 00    	jne    8041606d70 <mem_init+0x1b34>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605acb:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605ad0:	4c 89 e7             	mov    %r12,%rdi
  8041605ad3:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  8041605ada:	00 00 00 
  8041605add:	ff d0                	callq  *%rax
  8041605adf:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041605ae6:	00 00 00 
  8041605ae9:	4c 89 e9             	mov    %r13,%rcx
  8041605aec:	48 2b 0a             	sub    (%rdx),%rcx
  8041605aef:	48 89 ca             	mov    %rcx,%rdx
  8041605af2:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605af6:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605afa:	48 39 d0             	cmp    %rdx,%rax
  8041605afd:	0f 85 a2 12 00 00    	jne    8041606da5 <mem_init+0x1b69>
  assert(pp1->pp_ref == 1);
  8041605b03:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605b09:	0f 85 cb 12 00 00    	jne    8041606dda <mem_init+0x1b9e>
  assert(pp3->pp_ref == 1);
  8041605b0f:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605b14:	0f 85 f5 12 00 00    	jne    8041606e0f <mem_init+0x1bd3>

  // Test re-inserting pp1 at PGSIZE.
  // Thanks to Varun Agrawal for suggesting this test case.
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605b1f:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605b24:	4c 89 ee             	mov    %r13,%rsi
  8041605b27:	4c 89 e7             	mov    %r12,%rdi
  8041605b2a:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  8041605b31:	00 00 00 
  8041605b34:	ff d0                	callq  *%rax
  8041605b36:	41 89 c4             	mov    %eax,%r12d
  8041605b39:	85 c0                	test   %eax,%eax
  8041605b3b:	0f 85 03 13 00 00    	jne    8041606e44 <mem_init+0x1c08>
  assert(pp1->pp_ref);
  8041605b41:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041605b47:	0f 84 2c 13 00 00    	je     8041606e79 <mem_init+0x1c3d>
  assert(pp1->pp_link == NULL);
  8041605b4d:	49 83 7d 00 00       	cmpq   $0x0,0x0(%r13)
  8041605b52:	0f 85 56 13 00 00    	jne    8041606eae <mem_init+0x1c72>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041605b58:	49 bf 40 5a 88 41 80 	movabs $0x8041885a40,%r15
  8041605b5f:	00 00 00 
  8041605b62:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b67:	49 8b 3f             	mov    (%r15),%rdi
  8041605b6a:	48 b8 b0 50 60 41 80 	movabs $0x80416050b0,%rax
  8041605b71:	00 00 00 
  8041605b74:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605b76:	4d 8b 3f             	mov    (%r15),%r15
  8041605b79:	be 00 00 00 00       	mov    $0x0,%esi
  8041605b7e:	4c 89 ff             	mov    %r15,%rdi
  8041605b81:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  8041605b88:	00 00 00 
  8041605b8b:	ff d0                	callq  *%rax
  8041605b8d:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605b91:	0f 85 4c 13 00 00    	jne    8041606ee3 <mem_init+0x1ca7>
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041605b97:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b9c:	4c 89 ff             	mov    %r15,%rdi
  8041605b9f:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  8041605ba6:	00 00 00 
  8041605ba9:	ff d0                	callq  *%rax
  8041605bab:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605baf:	0f 85 63 13 00 00    	jne    8041606f18 <mem_init+0x1cdc>
  assert(pp1->pp_ref == 0);
  8041605bb5:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041605bbb:	0f 85 8c 13 00 00    	jne    8041606f4d <mem_init+0x1d11>
  assert(pp3->pp_ref == 1);
  8041605bc1:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605bc6:	0f 85 b6 13 00 00    	jne    8041606f82 <mem_init+0x1d46>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

  // forcibly take pp3 back
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041605bcc:	49 8b 17             	mov    (%r15),%rdx
  8041605bcf:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  8041605bd6:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605bdd:	00 00 00 
  8041605be0:	48 8b 08             	mov    (%rax),%rcx
  8041605be3:	4c 89 f0             	mov    %r14,%rax
  8041605be6:	48 29 c8             	sub    %rcx,%rax
  8041605be9:	48 c1 f8 04          	sar    $0x4,%rax
  8041605bed:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605bf1:	48 39 c2             	cmp    %rax,%rdx
  8041605bf4:	74 2b                	je     8041605c21 <mem_init+0x9e5>
  8041605bf6:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605bfa:	48 29 c8             	sub    %rcx,%rax
  8041605bfd:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c01:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c05:	48 39 c2             	cmp    %rax,%rdx
  8041605c08:	74 17                	je     8041605c21 <mem_init+0x9e5>
  8041605c0a:	48 89 d8             	mov    %rbx,%rax
  8041605c0d:	48 29 c8             	sub    %rcx,%rax
  8041605c10:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c14:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c18:	48 39 c2             	cmp    %rax,%rdx
  8041605c1b:	0f 85 96 13 00 00    	jne    8041606fb7 <mem_init+0x1d7b>
  kern_pml4e[0] = 0;
  8041605c21:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
  assert(pp3->pp_ref == 1);
  8041605c28:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605c2d:	0f 85 b9 13 00 00    	jne    8041606fec <mem_init+0x1db0>
  page_decref(pp3);
  8041605c33:	48 89 df             	mov    %rbx,%rdi
  8041605c36:	48 bb 65 4b 60 41 80 	movabs $0x8041604b65,%rbx
  8041605c3d:	00 00 00 
  8041605c40:	ff d3                	callq  *%rbx
  // check pointer arithmetic in pml4e_walk
  page_decref(pp0);
  8041605c42:	4c 89 f7             	mov    %r14,%rdi
  8041605c45:	ff d3                	callq  *%rbx
  page_decref(pp2);
  8041605c47:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605c4b:	ff d3                	callq  *%rbx
  va    = (void *)(PGSIZE * 100);
  ptep  = pml4e_walk(kern_pml4e, va, 1);
  8041605c4d:	48 bb 40 5a 88 41 80 	movabs $0x8041885a40,%rbx
  8041605c54:	00 00 00 
  8041605c57:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605c5c:	be 00 40 06 00       	mov    $0x64000,%esi
  8041605c61:	48 8b 3b             	mov    (%rbx),%rdi
  8041605c64:	48 b8 21 4e 60 41 80 	movabs $0x8041604e21,%rax
  8041605c6b:	00 00 00 
  8041605c6e:	ff d0                	callq  *%rax
  8041605c70:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  pdpe  = KADDR(PTE_ADDR(kern_pml4e[PML4(va)]));
  8041605c74:	48 8b 13             	mov    (%rbx),%rdx
  8041605c77:	48 8b 0a             	mov    (%rdx),%rcx
  8041605c7a:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605c81:	48 bb 50 5a 88 41 80 	movabs $0x8041885a50,%rbx
  8041605c88:	00 00 00 
  8041605c8b:	48 8b 13             	mov    (%rbx),%rdx
  8041605c8e:	48 89 ce             	mov    %rcx,%rsi
  8041605c91:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605c95:	48 39 d6             	cmp    %rdx,%rsi
  8041605c98:	0f 83 83 13 00 00    	jae    8041607021 <mem_init+0x1de5>
  pde   = KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8041605c9e:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605ca5:	00 00 00 
  8041605ca8:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605cac:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605cb3:	48 89 ce             	mov    %rcx,%rsi
  8041605cb6:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605cba:	48 39 f2             	cmp    %rsi,%rdx
  8041605cbd:	0f 86 89 13 00 00    	jbe    804160704c <mem_init+0x1e10>
  ptep1 = KADDR(PTE_ADDR(pde[PDX(va)]));
  8041605cc3:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605cca:	00 00 00 
  8041605ccd:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605cd1:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605cd8:	48 89 ce             	mov    %rcx,%rsi
  8041605cdb:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605cdf:	48 39 f2             	cmp    %rsi,%rdx
  8041605ce2:	0f 86 8f 13 00 00    	jbe    8041607077 <mem_init+0x1e3b>
  assert(ptep == ptep1 + PTX(va));
  8041605ce8:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605cef:	00 00 00 
  8041605cf2:	48 8d 94 11 20 03 00 	lea    0x320(%rcx,%rdx,1),%rdx
  8041605cf9:	00 
  8041605cfa:	48 39 d0             	cmp    %rdx,%rax
  8041605cfd:	0f 85 9f 13 00 00    	jne    80416070a2 <mem_init+0x1e66>

  // check that new page tables get cleared
  page_decref(pp4);
  8041605d03:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041605d07:	48 89 df             	mov    %rbx,%rdi
  8041605d0a:	48 b8 65 4b 60 41 80 	movabs $0x8041604b65,%rax
  8041605d11:	00 00 00 
  8041605d14:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041605d16:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605d1d:	00 00 00 
  8041605d20:	48 2b 18             	sub    (%rax),%rbx
  8041605d23:	48 89 df             	mov    %rbx,%rdi
  8041605d26:	48 c1 ff 04          	sar    $0x4,%rdi
  8041605d2a:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041605d2e:	48 89 fa             	mov    %rdi,%rdx
  8041605d31:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605d35:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041605d3c:	00 00 00 
  8041605d3f:	48 3b 10             	cmp    (%rax),%rdx
  8041605d42:	0f 83 8f 13 00 00    	jae    80416070d7 <mem_init+0x1e9b>
  return (void *)(pa + KERNBASE);
  8041605d48:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041605d4f:	00 00 00 
  8041605d52:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp4), 0xFF, PGSIZE);
  8041605d55:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605d5a:	be ff 00 00 00       	mov    $0xff,%esi
  8041605d5f:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  8041605d66:	00 00 00 
  8041605d69:	ff d0                	callq  *%rax
  pml4e_walk(kern_pml4e, 0x0, 1);
  8041605d6b:	48 bb 40 5a 88 41 80 	movabs $0x8041885a40,%rbx
  8041605d72:	00 00 00 
  8041605d75:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605d7a:	be 00 00 00 00       	mov    $0x0,%esi
  8041605d7f:	48 8b 3b             	mov    (%rbx),%rdi
  8041605d82:	48 b8 21 4e 60 41 80 	movabs $0x8041604e21,%rax
  8041605d89:	00 00 00 
  8041605d8c:	ff d0                	callq  *%rax
  pdpe = KADDR(PTE_ADDR(kern_pml4e[0]));
  8041605d8e:	48 8b 13             	mov    (%rbx),%rdx
  8041605d91:	48 8b 0a             	mov    (%rdx),%rcx
  8041605d94:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605d9b:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041605da2:	00 00 00 
  8041605da5:	48 89 ce             	mov    %rcx,%rsi
  8041605da8:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605dac:	48 39 c6             	cmp    %rax,%rsi
  8041605daf:	0f 83 50 13 00 00    	jae    8041607105 <mem_init+0x1ec9>
  pde  = KADDR(PTE_ADDR(pdpe[0]));
  8041605db5:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605dbc:	00 00 00 
  8041605dbf:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605dc3:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605dca:	48 89 ce             	mov    %rcx,%rsi
  8041605dcd:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605dd1:	48 39 f0             	cmp    %rsi,%rax
  8041605dd4:	0f 86 56 13 00 00    	jbe    8041607130 <mem_init+0x1ef4>
  ptep = KADDR(PTE_ADDR(pde[0]));
  8041605dda:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605de1:	00 00 00 
  8041605de4:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605de8:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605def:	48 89 ce             	mov    %rcx,%rsi
  8041605df2:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605df6:	48 39 f0             	cmp    %rsi,%rax
  8041605df9:	0f 86 5c 13 00 00    	jbe    804160715b <mem_init+0x1f1f>
  return (void *)(pa + KERNBASE);
  8041605dff:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041605e06:	00 00 00 
  8041605e09:	48 01 c8             	add    %rcx,%rax
  8041605e0c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
  8041605e10:	f6 00 01             	testb  $0x1,(%rax)
  8041605e13:	0f 85 6d 13 00 00    	jne    8041607186 <mem_init+0x1f4a>
  8041605e19:	48 b8 08 00 00 40 80 	movabs $0x8040000008,%rax
  8041605e20:	00 00 00 
  8041605e23:	48 01 c8             	add    %rcx,%rax
  8041605e26:	48 be 00 10 00 40 80 	movabs $0x8040001000,%rsi
  8041605e2d:	00 00 00 
  8041605e30:	48 01 f1             	add    %rsi,%rcx
  8041605e33:	48 8b 18             	mov    (%rax),%rbx
  8041605e36:	83 e3 01             	and    $0x1,%ebx
  8041605e39:	0f 85 47 13 00 00    	jne    8041607186 <mem_init+0x1f4a>
  for (i = 0; i < NPTENTRIES; i++)
  8041605e3f:	48 83 c0 08          	add    $0x8,%rax
  8041605e43:	48 39 c8             	cmp    %rcx,%rax
  8041605e46:	75 eb                	jne    8041605e33 <mem_init+0xbf7>
  kern_pml4e[0] = 0;
  8041605e48:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)

  // give free list back
  page_free_list = fl;
  8041605e4f:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041605e53:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  8041605e5a:	00 00 00 

  // free the pages we took
  page_decref(pp0);
  8041605e5d:	4c 89 f7             	mov    %r14,%rdi
  8041605e60:	49 be 65 4b 60 41 80 	movabs $0x8041604b65,%r14
  8041605e67:	00 00 00 
  8041605e6a:	41 ff d6             	callq  *%r14
  page_decref(pp1);
  8041605e6d:	4c 89 ef             	mov    %r13,%rdi
  8041605e70:	41 ff d6             	callq  *%r14
  page_decref(pp2);
  8041605e73:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605e77:	41 ff d6             	callq  *%r14

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041605e7a:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  8041605e81:	00 00 00 
  8041605e84:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041605e88:	48 89 38             	mov    %rdi,(%rax)

  cprintf("check_page() succeeded!\n");
  8041605e8b:	48 bf 08 e2 60 41 80 	movabs $0x804160e208,%rdi
  8041605e92:	00 00 00 
  8041605e95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605e9a:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041605ea1:	00 00 00 
  8041605ea4:	ff d2                	callq  *%rdx
  if (!pages)
  8041605ea6:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605ead:	00 00 00 
  8041605eb0:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041605eb4:	0f 84 01 13 00 00    	je     80416071bb <mem_init+0x1f7f>
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605eba:	48 a1 10 45 88 41 80 	movabs 0x8041884510,%rax
  8041605ec1:	00 00 00 
  8041605ec4:	48 85 c0             	test   %rax,%rax
  8041605ec7:	74 0c                	je     8041605ed5 <mem_init+0xc99>
    ++nfree;
  8041605ec9:	41 83 c4 01          	add    $0x1,%r12d
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605ecd:	48 8b 00             	mov    (%rax),%rax
  8041605ed0:	48 85 c0             	test   %rax,%rax
  8041605ed3:	75 f4                	jne    8041605ec9 <mem_init+0xc8d>
  assert((pp0 = page_alloc(0)));
  8041605ed5:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605eda:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041605ee1:	00 00 00 
  8041605ee4:	ff d0                	callq  *%rax
  8041605ee6:	49 89 c5             	mov    %rax,%r13
  8041605ee9:	48 85 c0             	test   %rax,%rax
  8041605eec:	0f 84 f3 12 00 00    	je     80416071e5 <mem_init+0x1fa9>
  assert((pp1 = page_alloc(0)));
  8041605ef2:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605ef7:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041605efe:	00 00 00 
  8041605f01:	ff d0                	callq  *%rax
  8041605f03:	49 89 c7             	mov    %rax,%r15
  8041605f06:	48 85 c0             	test   %rax,%rax
  8041605f09:	0f 84 0b 13 00 00    	je     804160721a <mem_init+0x1fde>
  assert((pp2 = page_alloc(0)));
  8041605f0f:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605f14:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041605f1b:	00 00 00 
  8041605f1e:	ff d0                	callq  *%rax
  8041605f20:	49 89 c6             	mov    %rax,%r14
  8041605f23:	48 85 c0             	test   %rax,%rax
  8041605f26:	0f 84 23 13 00 00    	je     804160724f <mem_init+0x2013>
  assert(pp1 && pp1 != pp0);
  8041605f2c:	4d 39 fd             	cmp    %r15,%r13
  8041605f2f:	0f 84 4f 13 00 00    	je     8041607284 <mem_init+0x2048>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041605f35:	49 39 c5             	cmp    %rax,%r13
  8041605f38:	0f 84 7b 13 00 00    	je     80416072b9 <mem_init+0x207d>
  8041605f3e:	49 39 c7             	cmp    %rax,%r15
  8041605f41:	0f 84 72 13 00 00    	je     80416072b9 <mem_init+0x207d>
  return (pp - pages) << PGSHIFT;
  8041605f47:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605f4e:	00 00 00 
  8041605f51:	48 8b 08             	mov    (%rax),%rcx
  assert(page2pa(pp0) < npages * PGSIZE);
  8041605f54:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041605f5b:	00 00 00 
  8041605f5e:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605f62:	4c 89 ea             	mov    %r13,%rdx
  8041605f65:	48 29 ca             	sub    %rcx,%rdx
  8041605f68:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605f6c:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605f70:	48 39 c2             	cmp    %rax,%rdx
  8041605f73:	0f 83 75 13 00 00    	jae    80416072ee <mem_init+0x20b2>
  8041605f79:	4c 89 fa             	mov    %r15,%rdx
  8041605f7c:	48 29 ca             	sub    %rcx,%rdx
  8041605f7f:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605f83:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp1) < npages * PGSIZE);
  8041605f87:	48 39 d0             	cmp    %rdx,%rax
  8041605f8a:	0f 86 93 13 00 00    	jbe    8041607323 <mem_init+0x20e7>
  8041605f90:	4c 89 f2             	mov    %r14,%rdx
  8041605f93:	48 29 ca             	sub    %rcx,%rdx
  8041605f96:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605f9a:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp2) < npages * PGSIZE);
  8041605f9e:	48 39 d0             	cmp    %rdx,%rax
  8041605fa1:	0f 86 b1 13 00 00    	jbe    8041607358 <mem_init+0x211c>
  fl             = page_free_list;
  8041605fa7:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041605fae:	00 00 00 
  8041605fb1:	48 8b 38             	mov    (%rax),%rdi
  8041605fb4:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  page_free_list = 0;
  8041605fb8:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  assert(!page_alloc(0));
  8041605fbf:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605fc4:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041605fcb:	00 00 00 
  8041605fce:	ff d0                	callq  *%rax
  8041605fd0:	48 85 c0             	test   %rax,%rax
  8041605fd3:	0f 85 b4 13 00 00    	jne    804160738d <mem_init+0x2151>
  page_free(pp0);
  8041605fd9:	4c 89 ef             	mov    %r13,%rdi
  8041605fdc:	49 bd f7 4a 60 41 80 	movabs $0x8041604af7,%r13
  8041605fe3:	00 00 00 
  8041605fe6:	41 ff d5             	callq  *%r13
  page_free(pp1);
  8041605fe9:	4c 89 ff             	mov    %r15,%rdi
  8041605fec:	41 ff d5             	callq  *%r13
  page_free(pp2);
  8041605fef:	4c 89 f7             	mov    %r14,%rdi
  8041605ff2:	41 ff d5             	callq  *%r13
  assert((pp0 = page_alloc(0)));
  8041605ff5:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605ffa:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041606001:	00 00 00 
  8041606004:	ff d0                	callq  *%rax
  8041606006:	49 89 c5             	mov    %rax,%r13
  8041606009:	48 85 c0             	test   %rax,%rax
  804160600c:	0f 84 b0 13 00 00    	je     80416073c2 <mem_init+0x2186>
  assert((pp1 = page_alloc(0)));
  8041606012:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606017:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160601e:	00 00 00 
  8041606021:	ff d0                	callq  *%rax
  8041606023:	49 89 c7             	mov    %rax,%r15
  8041606026:	48 85 c0             	test   %rax,%rax
  8041606029:	0f 84 c8 13 00 00    	je     80416073f7 <mem_init+0x21bb>
  assert((pp2 = page_alloc(0)));
  804160602f:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606034:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160603b:	00 00 00 
  804160603e:	ff d0                	callq  *%rax
  8041606040:	49 89 c6             	mov    %rax,%r14
  8041606043:	48 85 c0             	test   %rax,%rax
  8041606046:	0f 84 e0 13 00 00    	je     804160742c <mem_init+0x21f0>
  assert(pp1 && pp1 != pp0);
  804160604c:	4d 39 fd             	cmp    %r15,%r13
  804160604f:	0f 84 0c 14 00 00    	je     8041607461 <mem_init+0x2225>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041606055:	49 39 c7             	cmp    %rax,%r15
  8041606058:	0f 84 38 14 00 00    	je     8041607496 <mem_init+0x225a>
  804160605e:	49 39 c5             	cmp    %rax,%r13
  8041606061:	0f 84 2f 14 00 00    	je     8041607496 <mem_init+0x225a>
  assert(!page_alloc(0));
  8041606067:	bf 00 00 00 00       	mov    $0x0,%edi
  804160606c:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041606073:	00 00 00 
  8041606076:	ff d0                	callq  *%rax
  8041606078:	48 85 c0             	test   %rax,%rax
  804160607b:	0f 85 4a 14 00 00    	jne    80416074cb <mem_init+0x228f>
  8041606081:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041606088:	00 00 00 
  804160608b:	4c 89 ef             	mov    %r13,%rdi
  804160608e:	48 2b 38             	sub    (%rax),%rdi
  8041606091:	48 c1 ff 04          	sar    $0x4,%rdi
  8041606095:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041606099:	48 89 fa             	mov    %rdi,%rdx
  804160609c:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416060a0:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  80416060a7:	00 00 00 
  80416060aa:	48 3b 10             	cmp    (%rax),%rdx
  80416060ad:	0f 83 4d 14 00 00    	jae    8041607500 <mem_init+0x22c4>
  return (void *)(pa + KERNBASE);
  80416060b3:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  80416060ba:	00 00 00 
  80416060bd:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp0), 1, PGSIZE);
  80416060c0:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416060c5:	be 01 00 00 00       	mov    $0x1,%esi
  80416060ca:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  80416060d1:	00 00 00 
  80416060d4:	ff d0                	callq  *%rax
  page_free(pp0);
  80416060d6:	4c 89 ef             	mov    %r13,%rdi
  80416060d9:	48 b8 f7 4a 60 41 80 	movabs $0x8041604af7,%rax
  80416060e0:	00 00 00 
  80416060e3:	ff d0                	callq  *%rax
  assert((pp = page_alloc(ALLOC_ZERO)));
  80416060e5:	bf 01 00 00 00       	mov    $0x1,%edi
  80416060ea:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  80416060f1:	00 00 00 
  80416060f4:	ff d0                	callq  *%rax
  80416060f6:	48 85 c0             	test   %rax,%rax
  80416060f9:	0f 84 2f 14 00 00    	je     804160752e <mem_init+0x22f2>
  assert(pp && pp0 == pp);
  80416060ff:	49 39 c5             	cmp    %rax,%r13
  8041606102:	0f 85 56 14 00 00    	jne    804160755e <mem_init+0x2322>
  return (pp - pages) << PGSHIFT;
  8041606108:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  804160610f:	00 00 00 
  8041606112:	48 2b 02             	sub    (%rdx),%rax
  8041606115:	48 89 c1             	mov    %rax,%rcx
  8041606118:	48 c1 f9 04          	sar    $0x4,%rcx
  804160611c:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041606120:	48 89 ca             	mov    %rcx,%rdx
  8041606123:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041606127:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  804160612e:	00 00 00 
  8041606131:	48 3b 10             	cmp    (%rax),%rdx
  8041606134:	0f 83 59 14 00 00    	jae    8041607593 <mem_init+0x2357>
    assert(c[i] == 0);
  804160613a:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041606141:	00 00 00 
  8041606144:	80 3c 01 00          	cmpb   $0x0,(%rcx,%rax,1)
  8041606148:	0f 85 70 14 00 00    	jne    80416075be <mem_init+0x2382>
  804160614e:	48 8d 40 01          	lea    0x1(%rax),%rax
  8041606152:	48 01 c8             	add    %rcx,%rax
  8041606155:	48 ba 00 10 00 40 80 	movabs $0x8040001000,%rdx
  804160615c:	00 00 00 
  804160615f:	48 01 d1             	add    %rdx,%rcx
  8041606162:	80 38 00             	cmpb   $0x0,(%rax)
  8041606165:	0f 85 53 14 00 00    	jne    80416075be <mem_init+0x2382>
  for (i = 0; i < PGSIZE; i++)
  804160616b:	48 83 c0 01          	add    $0x1,%rax
  804160616f:	48 39 c8             	cmp    %rcx,%rax
  8041606172:	75 ee                	jne    8041606162 <mem_init+0xf26>
  page_free_list = fl;
  8041606174:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  804160617b:	00 00 00 
  804160617e:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041606182:	48 89 08             	mov    %rcx,(%rax)
  page_free(pp0);
  8041606185:	4c 89 ef             	mov    %r13,%rdi
  8041606188:	49 bd f7 4a 60 41 80 	movabs $0x8041604af7,%r13
  804160618f:	00 00 00 
  8041606192:	41 ff d5             	callq  *%r13
  page_free(pp1);
  8041606195:	4c 89 ff             	mov    %r15,%rdi
  8041606198:	41 ff d5             	callq  *%r13
  page_free(pp2);
  804160619b:	4c 89 f7             	mov    %r14,%rdi
  804160619e:	41 ff d5             	callq  *%r13
  for (pp = page_free_list; pp; pp = pp->pp_link)
  80416061a1:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  80416061a8:	00 00 00 
  80416061ab:	48 8b 00             	mov    (%rax),%rax
  80416061ae:	48 85 c0             	test   %rax,%rax
  80416061b1:	74 0c                	je     80416061bf <mem_init+0xf83>
    --nfree;
  80416061b3:	41 83 ec 01          	sub    $0x1,%r12d
  for (pp = page_free_list; pp; pp = pp->pp_link)
  80416061b7:	48 8b 00             	mov    (%rax),%rax
  80416061ba:	48 85 c0             	test   %rax,%rax
  80416061bd:	75 f4                	jne    80416061b3 <mem_init+0xf77>
  assert(nfree == 0);
  80416061bf:	45 85 e4             	test   %r12d,%r12d
  80416061c2:	0f 85 2b 14 00 00    	jne    80416075f3 <mem_init+0x23b7>
  cprintf("check_page_alloc() succeeded!\n");
  80416061c8:	48 bf 38 dd 60 41 80 	movabs $0x804160dd38,%rdi
  80416061cf:	00 00 00 
  80416061d2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416061d7:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416061de:	00 00 00 
  80416061e1:	ff d2                	callq  *%rdx
  boot_map_region(kern_pml4e, UPAGES, ROUNDUP(npages * sizeof(*pages), PGSIZE), PADDR(pages), PTE_U | PTE_P);
  80416061e3:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  80416061ea:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  80416061ed:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  80416061f4:	00 00 00 
  80416061f7:	48 39 d0             	cmp    %rdx,%rax
  80416061fa:	0f 86 28 14 00 00    	jbe    8041607628 <mem_init+0x23ec>
  return (physaddr_t)kva - KERNBASE;
  8041606200:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  8041606207:	ff ff ff 
  804160620a:	48 01 c1             	add    %rax,%rcx
  804160620d:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041606214:	00 00 00 
  8041606217:	48 8b 10             	mov    (%rax),%rdx
  804160621a:	48 c1 e2 04          	shl    $0x4,%rdx
  804160621e:	48 81 c2 ff 0f 00 00 	add    $0xfff,%rdx
  8041606225:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  804160622c:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  8041606232:	48 be 00 e0 42 3c 80 	movabs $0x803c42e000,%rsi
  8041606239:	00 00 00 
  804160623c:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041606243:	00 00 00 
  8041606246:	48 8b 38             	mov    (%rax),%rdi
  8041606249:	48 b8 72 4f 60 41 80 	movabs $0x8041604f72,%rax
  8041606250:	00 00 00 
  8041606253:	ff d0                	callq  *%rax
  boot_map_region(kern_pml4e, UENVS, ROUNDUP(NENV * sizeof(*envs), PGSIZE), PADDR(envs), PTE_U | PTE_P);
  8041606255:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  804160625c:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  804160625f:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041606266:	00 00 00 
  8041606269:	48 39 d0             	cmp    %rdx,%rax
  804160626c:	0f 86 e4 13 00 00    	jbe    8041607656 <mem_init+0x241a>
  return (physaddr_t)kva - KERNBASE;
  8041606272:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  8041606279:	ff ff ff 
  804160627c:	48 01 c1             	add    %rax,%rcx
  804160627f:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  8041606285:	ba 00 80 04 00       	mov    $0x48000,%edx
  804160628a:	48 be 00 e0 22 3c 80 	movabs $0x803c22e000,%rsi
  8041606291:	00 00 00 
  8041606294:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160629b:	00 00 00 
  804160629e:	48 8b 38             	mov    (%rax),%rdi
  80416062a1:	48 b8 72 4f 60 41 80 	movabs $0x8041604f72,%rax
  80416062a8:	00 00 00 
  80416062ab:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  80416062ad:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  80416062b4:	00 00 00 
  80416062b7:	48 bf 00 00 61 41 80 	movabs $0x8041610000,%rdi
  80416062be:	00 00 00 
  80416062c1:	48 39 c7             	cmp    %rax,%rdi
  80416062c4:	0f 86 ba 13 00 00    	jbe    8041607684 <mem_init+0x2448>
  return (physaddr_t)kva - KERNBASE;
  80416062ca:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  80416062d1:	ff ff ff 
  80416062d4:	48 b8 00 00 61 41 80 	movabs $0x8041610000,%rax
  80416062db:	00 00 00 
  80416062de:	49 01 c6             	add    %rax,%r14
  boot_map_region(kern_pml4e, KSTACKTOP - KSTKSIZE, KSTACKTOP - (KSTACKTOP - KSTKSIZE), PADDR(bootstack), PTE_W | PTE_P);
  80416062e1:	49 bd 40 5a 88 41 80 	movabs $0x8041885a40,%r13
  80416062e8:	00 00 00 
  80416062eb:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416062f1:	4c 89 f1             	mov    %r14,%rcx
  80416062f4:	ba 00 00 01 00       	mov    $0x10000,%edx
  80416062f9:	48 be 00 00 ff 3f 80 	movabs $0x803fff0000,%rsi
  8041606300:	00 00 00 
  8041606303:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041606307:	49 bc 72 4f 60 41 80 	movabs $0x8041604f72,%r12
  804160630e:	00 00 00 
  8041606311:	41 ff d4             	callq  *%r12
  boot_map_region(kern_pml4e, X86ADDR(KSTACKTOP - KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
  8041606314:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  804160631a:	4c 89 f1             	mov    %r14,%rcx
  804160631d:	ba 00 00 01 00       	mov    $0x10000,%edx
  8041606322:	be 00 00 ff 3f       	mov    $0x3fff0000,%esi
  8041606327:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  804160632b:	41 ff d4             	callq  *%r12
  boot_map_region(kern_pml4e, KERNBASE, npages * PGSIZE, 0, PTE_W | PTE_P);
  804160632e:	49 be 50 5a 88 41 80 	movabs $0x8041885a50,%r14
  8041606335:	00 00 00 
  8041606338:	49 8b 16             	mov    (%r14),%rdx
  804160633b:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160633f:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606345:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160634a:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041606351:	00 00 00 
  8041606354:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041606358:	41 ff d4             	callq  *%r12
  size_to_alloc = MIN(0x3200000, npages * PGSIZE);
  804160635b:	49 8b 16             	mov    (%r14),%rdx
  804160635e:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041606362:	48 81 fa 00 00 20 03 	cmp    $0x3200000,%rdx
  8041606369:	b8 00 00 20 03       	mov    $0x3200000,%eax
  804160636e:	48 0f 47 d0          	cmova  %rax,%rdx
  boot_map_region(kern_pml4e, X86ADDR(KERNBASE), size_to_alloc, 0, PTE_P | PTE_W);
  8041606372:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606378:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160637d:	be 00 00 00 40       	mov    $0x40000000,%esi
  8041606382:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041606386:	41 ff d4             	callq  *%r12
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606389:	48 b8 f0 44 88 41 80 	movabs $0x80418844f0,%rax
  8041606390:	00 00 00 
  8041606393:	4c 8b 20             	mov    (%rax),%r12
  8041606396:	48 b8 e8 44 88 41 80 	movabs $0x80418844e8,%rax
  804160639d:	00 00 00 
  80416063a0:	4c 3b 20             	cmp    (%rax),%r12
  80416063a3:	0f 83 4a 13 00 00    	jae    80416076f3 <mem_init+0x24b7>
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  80416063a9:	4d 89 ef             	mov    %r13,%r15
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416063ac:	49 be e0 44 88 41 80 	movabs $0x80418844e0,%r14
  80416063b3:	00 00 00 
  80416063b6:	49 89 c5             	mov    %rax,%r13
  80416063b9:	e9 2b 13 00 00       	jmpq   80416076e9 <mem_init+0x24ad>
  mem_map_size     = desc->MemoryMapDescriptorSize;
  80416063be:	48 8b 70 20          	mov    0x20(%rax),%rsi
  80416063c2:	48 89 c3             	mov    %rax,%rbx
  80416063c5:	48 89 f0             	mov    %rsi,%rax
  80416063c8:	48 a3 e0 44 88 41 80 	movabs %rax,0x80418844e0
  80416063cf:	00 00 00 
  mmap_base        = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)desc->MemoryMap;
  80416063d2:	48 89 fa             	mov    %rdi,%rdx
  80416063d5:	48 89 f8             	mov    %rdi,%rax
  80416063d8:	48 a3 f0 44 88 41 80 	movabs %rax,0x80418844f0
  80416063df:	00 00 00 
  mmap_end         = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)desc->MemoryMap + desc->MemoryMapSize);
  80416063e2:	48 89 f9             	mov    %rdi,%rcx
  80416063e5:	48 03 4b 38          	add    0x38(%rbx),%rcx
  80416063e9:	48 89 c8             	mov    %rcx,%rax
  80416063ec:	48 a3 e8 44 88 41 80 	movabs %rax,0x80418844e8
  80416063f3:	00 00 00 
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416063f6:	48 39 cf             	cmp    %rcx,%rdi
  80416063f9:	73 33                	jae    804160642e <mem_init+0x11f2>
  size_t num_pages = 0;
  80416063fb:	bb 00 00 00 00       	mov    $0x0,%ebx
    num_pages += mmap_curr->NumberOfPages;
  8041606400:	48 03 5a 18          	add    0x18(%rdx),%rbx
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606404:	48 01 f2             	add    %rsi,%rdx
  8041606407:	48 39 d1             	cmp    %rdx,%rcx
  804160640a:	77 f4                	ja     8041606400 <mem_init+0x11c4>
  *npages_basemem = num_pages > (IOPHYSMEM / PGSIZE) ? IOPHYSMEM / PGSIZE : num_pages;
  804160640c:	48 81 fb a0 00 00 00 	cmp    $0xa0,%rbx
  8041606413:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041606418:	48 0f 46 d3          	cmovbe %rbx,%rdx
  804160641c:	48 89 d0             	mov    %rdx,%rax
  804160641f:	48 a3 18 45 88 41 80 	movabs %rax,0x8041884518
  8041606426:	00 00 00 
  *npages_extmem  = num_pages - *npages_basemem;
  8041606429:	48 29 d3             	sub    %rdx,%rbx
  804160642c:	eb 0f                	jmp    804160643d <mem_init+0x1201>
  size_t num_pages = 0;
  804160642e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041606433:	eb d7                	jmp    804160640c <mem_init+0x11d0>
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  8041606435:	c1 e3 0a             	shl    $0xa,%ebx
  8041606438:	c1 eb 0c             	shr    $0xc,%ebx
  804160643b:	89 db                	mov    %ebx,%ebx
    npages = npages_basemem;
  804160643d:	48 b8 18 45 88 41 80 	movabs $0x8041884518,%rax
  8041606444:	00 00 00 
  8041606447:	48 8b 30             	mov    (%rax),%rsi
  if (npages_extmem)
  804160644a:	48 85 db             	test   %rbx,%rbx
  804160644d:	0f 84 6f ee ff ff    	je     80416052c2 <mem_init+0x86>
  8041606453:	e9 63 ee ff ff       	jmpq   80416052bb <mem_init+0x7f>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041606458:	48 89 d9             	mov    %rbx,%rcx
  804160645b:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041606462:	00 00 00 
  8041606465:	be ea 00 00 00       	mov    $0xea,%esi
  804160646a:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606471:	00 00 00 
  8041606474:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606479:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606480:	00 00 00 
  8041606483:	41 ff d0             	callq  *%r8
  assert(pp0 = page_alloc(0));
  8041606486:	48 b9 a9 e0 60 41 80 	movabs $0x804160e0a9,%rcx
  804160648d:	00 00 00 
  8041606490:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606497:	00 00 00 
  804160649a:	be a0 04 00 00       	mov    $0x4a0,%esi
  804160649f:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416064a6:	00 00 00 
  80416064a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416064ae:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416064b5:	00 00 00 
  80416064b8:	41 ff d0             	callq  *%r8
  assert(pp1 = page_alloc(0));
  80416064bb:	48 b9 bd e0 60 41 80 	movabs $0x804160e0bd,%rcx
  80416064c2:	00 00 00 
  80416064c5:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416064cc:	00 00 00 
  80416064cf:	be a1 04 00 00       	mov    $0x4a1,%esi
  80416064d4:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416064db:	00 00 00 
  80416064de:	b8 00 00 00 00       	mov    $0x0,%eax
  80416064e3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416064ea:	00 00 00 
  80416064ed:	41 ff d0             	callq  *%r8
  assert(pp2 = page_alloc(0));
  80416064f0:	48 b9 d1 e0 60 41 80 	movabs $0x804160e0d1,%rcx
  80416064f7:	00 00 00 
  80416064fa:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606501:	00 00 00 
  8041606504:	be a2 04 00 00       	mov    $0x4a2,%esi
  8041606509:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606510:	00 00 00 
  8041606513:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160651a:	00 00 00 
  804160651d:	41 ff d0             	callq  *%r8
  assert(pp3 = page_alloc(0));
  8041606520:	48 b9 e5 e0 60 41 80 	movabs $0x804160e0e5,%rcx
  8041606527:	00 00 00 
  804160652a:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606531:	00 00 00 
  8041606534:	be a3 04 00 00       	mov    $0x4a3,%esi
  8041606539:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606540:	00 00 00 
  8041606543:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606548:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160654f:	00 00 00 
  8041606552:	41 ff d0             	callq  *%r8
  assert(pp4 = page_alloc(0));
  8041606555:	48 b9 f9 e0 60 41 80 	movabs $0x804160e0f9,%rcx
  804160655c:	00 00 00 
  804160655f:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606566:	00 00 00 
  8041606569:	be a4 04 00 00       	mov    $0x4a4,%esi
  804160656e:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606575:	00 00 00 
  8041606578:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160657f:	00 00 00 
  8041606582:	41 ff d0             	callq  *%r8
  assert(pp5 = page_alloc(0));
  8041606585:	48 b9 0d e1 60 41 80 	movabs $0x804160e10d,%rcx
  804160658c:	00 00 00 
  804160658f:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606596:	00 00 00 
  8041606599:	be a5 04 00 00       	mov    $0x4a5,%esi
  804160659e:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416065a5:	00 00 00 
  80416065a8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065af:	00 00 00 
  80416065b2:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  80416065b5:	48 b9 21 e1 60 41 80 	movabs $0x804160e121,%rcx
  80416065bc:	00 00 00 
  80416065bf:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416065c6:	00 00 00 
  80416065c9:	be a8 04 00 00       	mov    $0x4a8,%esi
  80416065ce:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416065d5:	00 00 00 
  80416065d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416065dd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065e4:	00 00 00 
  80416065e7:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416065ea:	48 b9 38 d8 60 41 80 	movabs $0x804160d838,%rcx
  80416065f1:	00 00 00 
  80416065f4:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416065fb:	00 00 00 
  80416065fe:	be a9 04 00 00       	mov    $0x4a9,%esi
  8041606603:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160660a:	00 00 00 
  804160660d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606612:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606619:	00 00 00 
  804160661c:	41 ff d0             	callq  *%r8
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  804160661f:	48 b9 58 d8 60 41 80 	movabs $0x804160d858,%rcx
  8041606626:	00 00 00 
  8041606629:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606630:	00 00 00 
  8041606633:	be aa 04 00 00       	mov    $0x4aa,%esi
  8041606638:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160663f:	00 00 00 
  8041606642:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606647:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160664e:	00 00 00 
  8041606651:	41 ff d0             	callq  *%r8
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  8041606654:	48 b9 88 d8 60 41 80 	movabs $0x804160d888,%rcx
  804160665b:	00 00 00 
  804160665e:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606665:	00 00 00 
  8041606668:	be ab 04 00 00       	mov    $0x4ab,%esi
  804160666d:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606674:	00 00 00 
  8041606677:	b8 00 00 00 00       	mov    $0x0,%eax
  804160667c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606683:	00 00 00 
  8041606686:	41 ff d0             	callq  *%r8
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  8041606689:	48 b9 c8 d8 60 41 80 	movabs $0x804160d8c8,%rcx
  8041606690:	00 00 00 
  8041606693:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160669a:	00 00 00 
  804160669d:	be ac 04 00 00       	mov    $0x4ac,%esi
  80416066a2:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416066a9:	00 00 00 
  80416066ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066b1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066b8:	00 00 00 
  80416066bb:	41 ff d0             	callq  *%r8
  assert(fl != NULL);
  80416066be:	48 b9 33 e1 60 41 80 	movabs $0x804160e133,%rcx
  80416066c5:	00 00 00 
  80416066c8:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416066cf:	00 00 00 
  80416066d2:	be b0 04 00 00       	mov    $0x4b0,%esi
  80416066d7:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416066de:	00 00 00 
  80416066e1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066e8:	00 00 00 
  80416066eb:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416066ee:	48 b9 3e e1 60 41 80 	movabs $0x804160e13e,%rcx
  80416066f5:	00 00 00 
  80416066f8:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416066ff:	00 00 00 
  8041606702:	be b4 04 00 00       	mov    $0x4b4,%esi
  8041606707:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160670e:	00 00 00 
  8041606711:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606716:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160671d:	00 00 00 
  8041606720:	41 ff d0             	callq  *%r8
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  8041606723:	48 b9 18 d9 60 41 80 	movabs $0x804160d918,%rcx
  804160672a:	00 00 00 
  804160672d:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606734:	00 00 00 
  8041606737:	be b7 04 00 00       	mov    $0x4b7,%esi
  804160673c:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606743:	00 00 00 
  8041606746:	b8 00 00 00 00       	mov    $0x0,%eax
  804160674b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606752:	00 00 00 
  8041606755:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  8041606758:	48 b9 50 d9 60 41 80 	movabs $0x804160d950,%rcx
  804160675f:	00 00 00 
  8041606762:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606769:	00 00 00 
  804160676c:	be ba 04 00 00       	mov    $0x4ba,%esi
  8041606771:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606778:	00 00 00 
  804160677b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606780:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606787:	00 00 00 
  804160678a:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  804160678d:	48 b9 50 d9 60 41 80 	movabs $0x804160d950,%rcx
  8041606794:	00 00 00 
  8041606797:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160679e:	00 00 00 
  80416067a1:	be be 04 00 00       	mov    $0x4be,%esi
  80416067a6:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416067ad:	00 00 00 
  80416067b0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067b5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067bc:	00 00 00 
  80416067bf:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  80416067c2:	48 b9 80 d9 60 41 80 	movabs $0x804160d980,%rcx
  80416067c9:	00 00 00 
  80416067cc:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416067d3:	00 00 00 
  80416067d6:	be c4 04 00 00       	mov    $0x4c4,%esi
  80416067db:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416067e2:	00 00 00 
  80416067e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067ea:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067f1:	00 00 00 
  80416067f4:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  80416067f7:	48 b9 b0 d9 60 41 80 	movabs $0x804160d9b0,%rcx
  80416067fe:	00 00 00 
  8041606801:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606808:	00 00 00 
  804160680b:	be c5 04 00 00       	mov    $0x4c5,%esi
  8041606810:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606817:	00 00 00 
  804160681a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160681f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606826:	00 00 00 
  8041606829:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  804160682c:	48 b9 30 da 60 41 80 	movabs $0x804160da30,%rcx
  8041606833:	00 00 00 
  8041606836:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160683d:	00 00 00 
  8041606840:	be c6 04 00 00       	mov    $0x4c6,%esi
  8041606845:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160684c:	00 00 00 
  804160684f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606854:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160685b:	00 00 00 
  804160685e:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041606861:	48 b9 4d e1 60 41 80 	movabs $0x804160e14d,%rcx
  8041606868:	00 00 00 
  804160686b:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606872:	00 00 00 
  8041606875:	be c7 04 00 00       	mov    $0x4c7,%esi
  804160687a:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606881:	00 00 00 
  8041606884:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606889:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606890:	00 00 00 
  8041606893:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041606896:	48 b9 60 da 60 41 80 	movabs $0x804160da60,%rcx
  804160689d:	00 00 00 
  80416068a0:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416068a7:	00 00 00 
  80416068aa:	be c9 04 00 00       	mov    $0x4c9,%esi
  80416068af:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416068b6:	00 00 00 
  80416068b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068be:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068c5:	00 00 00 
  80416068c8:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416068cb:	48 b9 98 da 60 41 80 	movabs $0x804160da98,%rcx
  80416068d2:	00 00 00 
  80416068d5:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416068dc:	00 00 00 
  80416068df:	be ca 04 00 00       	mov    $0x4ca,%esi
  80416068e4:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416068eb:	00 00 00 
  80416068ee:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068f3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068fa:	00 00 00 
  80416068fd:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606900:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  8041606907:	00 00 00 
  804160690a:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606911:	00 00 00 
  8041606914:	be cb 04 00 00       	mov    $0x4cb,%esi
  8041606919:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606920:	00 00 00 
  8041606923:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606928:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160692f:	00 00 00 
  8041606932:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606935:	48 b9 3e e1 60 41 80 	movabs $0x804160e13e,%rcx
  804160693c:	00 00 00 
  804160693f:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606946:	00 00 00 
  8041606949:	be ce 04 00 00       	mov    $0x4ce,%esi
  804160694e:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606955:	00 00 00 
  8041606958:	b8 00 00 00 00       	mov    $0x0,%eax
  804160695d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606964:	00 00 00 
  8041606967:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  804160696a:	48 b9 60 da 60 41 80 	movabs $0x804160da60,%rcx
  8041606971:	00 00 00 
  8041606974:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160697b:	00 00 00 
  804160697e:	be d1 04 00 00       	mov    $0x4d1,%esi
  8041606983:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160698a:	00 00 00 
  804160698d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606992:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606999:	00 00 00 
  804160699c:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  804160699f:	48 b9 98 da 60 41 80 	movabs $0x804160da98,%rcx
  80416069a6:	00 00 00 
  80416069a9:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416069b0:	00 00 00 
  80416069b3:	be d2 04 00 00       	mov    $0x4d2,%esi
  80416069b8:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416069bf:	00 00 00 
  80416069c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069c7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069ce:	00 00 00 
  80416069d1:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  80416069d4:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  80416069db:	00 00 00 
  80416069de:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416069e5:	00 00 00 
  80416069e8:	be d3 04 00 00       	mov    $0x4d3,%esi
  80416069ed:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416069f4:	00 00 00 
  80416069f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069fc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a03:	00 00 00 
  8041606a06:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606a09:	48 b9 3e e1 60 41 80 	movabs $0x804160e13e,%rcx
  8041606a10:	00 00 00 
  8041606a13:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606a1a:	00 00 00 
  8041606a1d:	be d7 04 00 00       	mov    $0x4d7,%esi
  8041606a22:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606a29:	00 00 00 
  8041606a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a31:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a38:	00 00 00 
  8041606a3b:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041606a3e:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041606a45:	00 00 00 
  8041606a48:	be d9 04 00 00       	mov    $0x4d9,%esi
  8041606a4d:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606a54:	00 00 00 
  8041606a57:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a5c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a63:	00 00 00 
  8041606a66:	41 ff d0             	callq  *%r8
  8041606a69:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041606a70:	00 00 00 
  8041606a73:	be da 04 00 00       	mov    $0x4da,%esi
  8041606a78:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606a7f:	00 00 00 
  8041606a82:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a87:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a8e:	00 00 00 
  8041606a91:	41 ff d0             	callq  *%r8
  8041606a94:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041606a9b:	00 00 00 
  8041606a9e:	be db 04 00 00       	mov    $0x4db,%esi
  8041606aa3:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606aaa:	00 00 00 
  8041606aad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ab2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ab9:	00 00 00 
  8041606abc:	41 ff d0             	callq  *%r8
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  8041606abf:	48 b9 c8 da 60 41 80 	movabs $0x804160dac8,%rcx
  8041606ac6:	00 00 00 
  8041606ac9:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606ad0:	00 00 00 
  8041606ad3:	be dc 04 00 00       	mov    $0x4dc,%esi
  8041606ad8:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606adf:	00 00 00 
  8041606ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ae7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606aee:	00 00 00 
  8041606af1:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  8041606af4:	48 b9 08 db 60 41 80 	movabs $0x804160db08,%rcx
  8041606afb:	00 00 00 
  8041606afe:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606b05:	00 00 00 
  8041606b08:	be df 04 00 00       	mov    $0x4df,%esi
  8041606b0d:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606b14:	00 00 00 
  8041606b17:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b1c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b23:	00 00 00 
  8041606b26:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606b29:	48 b9 98 da 60 41 80 	movabs $0x804160da98,%rcx
  8041606b30:	00 00 00 
  8041606b33:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606b3a:	00 00 00 
  8041606b3d:	be e0 04 00 00       	mov    $0x4e0,%esi
  8041606b42:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606b49:	00 00 00 
  8041606b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b51:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b58:	00 00 00 
  8041606b5b:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606b5e:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  8041606b65:	00 00 00 
  8041606b68:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606b6f:	00 00 00 
  8041606b72:	be e1 04 00 00       	mov    $0x4e1,%esi
  8041606b77:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606b7e:	00 00 00 
  8041606b81:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b86:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b8d:	00 00 00 
  8041606b90:	41 ff d0             	callq  *%r8
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041606b93:	48 b9 48 db 60 41 80 	movabs $0x804160db48,%rcx
  8041606b9a:	00 00 00 
  8041606b9d:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606ba4:	00 00 00 
  8041606ba7:	be e2 04 00 00       	mov    $0x4e2,%esi
  8041606bac:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606bb3:	00 00 00 
  8041606bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bbb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606bc2:	00 00 00 
  8041606bc5:	41 ff d0             	callq  *%r8
  assert(kern_pml4e[0] & PTE_U);
  8041606bc8:	48 b9 6f e1 60 41 80 	movabs $0x804160e16f,%rcx
  8041606bcf:	00 00 00 
  8041606bd2:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606bd9:	00 00 00 
  8041606bdc:	be e3 04 00 00       	mov    $0x4e3,%esi
  8041606be1:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606be8:	00 00 00 
  8041606beb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bf0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606bf7:	00 00 00 
  8041606bfa:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041606bfd:	48 b9 80 db 60 41 80 	movabs $0x804160db80,%rcx
  8041606c04:	00 00 00 
  8041606c07:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606c0e:	00 00 00 
  8041606c11:	be e6 04 00 00       	mov    $0x4e6,%esi
  8041606c16:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606c1d:	00 00 00 
  8041606c20:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c25:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c2c:	00 00 00 
  8041606c2f:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606c32:	48 b9 b8 db 60 41 80 	movabs $0x804160dbb8,%rcx
  8041606c39:	00 00 00 
  8041606c3c:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606c43:	00 00 00 
  8041606c46:	be e9 04 00 00       	mov    $0x4e9,%esi
  8041606c4b:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606c52:	00 00 00 
  8041606c55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c5a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c61:	00 00 00 
  8041606c64:	41 ff d0             	callq  *%r8
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041606c67:	48 b9 f0 db 60 41 80 	movabs $0x804160dbf0,%rcx
  8041606c6e:	00 00 00 
  8041606c71:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606c78:	00 00 00 
  8041606c7b:	be ea 04 00 00       	mov    $0x4ea,%esi
  8041606c80:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606c87:	00 00 00 
  8041606c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c8f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c96:	00 00 00 
  8041606c99:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041606c9c:	48 b9 28 dc 60 41 80 	movabs $0x804160dc28,%rcx
  8041606ca3:	00 00 00 
  8041606ca6:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606cad:	00 00 00 
  8041606cb0:	be ed 04 00 00       	mov    $0x4ed,%esi
  8041606cb5:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606cbc:	00 00 00 
  8041606cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606cc4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ccb:	00 00 00 
  8041606cce:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606cd1:	48 b9 58 dc 60 41 80 	movabs $0x804160dc58,%rcx
  8041606cd8:	00 00 00 
  8041606cdb:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606ce2:	00 00 00 
  8041606ce5:	be ee 04 00 00       	mov    $0x4ee,%esi
  8041606cea:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606cf1:	00 00 00 
  8041606cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606cf9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d00:	00 00 00 
  8041606d03:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 2);
  8041606d06:	48 b9 85 e1 60 41 80 	movabs $0x804160e185,%rcx
  8041606d0d:	00 00 00 
  8041606d10:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606d17:	00 00 00 
  8041606d1a:	be f0 04 00 00       	mov    $0x4f0,%esi
  8041606d1f:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606d26:	00 00 00 
  8041606d29:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d2e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d35:	00 00 00 
  8041606d38:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606d3b:	48 b9 96 e1 60 41 80 	movabs $0x804160e196,%rcx
  8041606d42:	00 00 00 
  8041606d45:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606d4c:	00 00 00 
  8041606d4f:	be f1 04 00 00       	mov    $0x4f1,%esi
  8041606d54:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606d5b:	00 00 00 
  8041606d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d63:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d6a:	00 00 00 
  8041606d6d:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606d70:	48 b9 88 dc 60 41 80 	movabs $0x804160dc88,%rcx
  8041606d77:	00 00 00 
  8041606d7a:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606d81:	00 00 00 
  8041606d84:	be f5 04 00 00       	mov    $0x4f5,%esi
  8041606d89:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606d90:	00 00 00 
  8041606d93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d98:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d9f:	00 00 00 
  8041606da2:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606da5:	48 b9 58 dc 60 41 80 	movabs $0x804160dc58,%rcx
  8041606dac:	00 00 00 
  8041606daf:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606db6:	00 00 00 
  8041606db9:	be f6 04 00 00       	mov    $0x4f6,%esi
  8041606dbe:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606dc5:	00 00 00 
  8041606dc8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606dcd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606dd4:	00 00 00 
  8041606dd7:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041606dda:	48 b9 4d e1 60 41 80 	movabs $0x804160e14d,%rcx
  8041606de1:	00 00 00 
  8041606de4:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606deb:	00 00 00 
  8041606dee:	be f7 04 00 00       	mov    $0x4f7,%esi
  8041606df3:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606dfa:	00 00 00 
  8041606dfd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e02:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e09:	00 00 00 
  8041606e0c:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606e0f:	48 b9 96 e1 60 41 80 	movabs $0x804160e196,%rcx
  8041606e16:	00 00 00 
  8041606e19:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606e20:	00 00 00 
  8041606e23:	be f8 04 00 00       	mov    $0x4f8,%esi
  8041606e28:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606e2f:	00 00 00 
  8041606e32:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e37:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e3e:	00 00 00 
  8041606e41:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606e44:	48 b9 b8 db 60 41 80 	movabs $0x804160dbb8,%rcx
  8041606e4b:	00 00 00 
  8041606e4e:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606e55:	00 00 00 
  8041606e58:	be fc 04 00 00       	mov    $0x4fc,%esi
  8041606e5d:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606e64:	00 00 00 
  8041606e67:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e6c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e73:	00 00 00 
  8041606e76:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref);
  8041606e79:	48 b9 a7 e1 60 41 80 	movabs $0x804160e1a7,%rcx
  8041606e80:	00 00 00 
  8041606e83:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606e8a:	00 00 00 
  8041606e8d:	be fd 04 00 00       	mov    $0x4fd,%esi
  8041606e92:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606e99:	00 00 00 
  8041606e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ea1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ea8:	00 00 00 
  8041606eab:	41 ff d0             	callq  *%r8
  assert(pp1->pp_link == NULL);
  8041606eae:	48 b9 b3 e1 60 41 80 	movabs $0x804160e1b3,%rcx
  8041606eb5:	00 00 00 
  8041606eb8:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606ebf:	00 00 00 
  8041606ec2:	be fe 04 00 00       	mov    $0x4fe,%esi
  8041606ec7:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606ece:	00 00 00 
  8041606ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ed6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606edd:	00 00 00 
  8041606ee0:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606ee3:	48 b9 88 dc 60 41 80 	movabs $0x804160dc88,%rcx
  8041606eea:	00 00 00 
  8041606eed:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606ef4:	00 00 00 
  8041606ef7:	be 02 05 00 00       	mov    $0x502,%esi
  8041606efc:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606f03:	00 00 00 
  8041606f06:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f0b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f12:	00 00 00 
  8041606f15:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041606f18:	48 b9 b0 dc 60 41 80 	movabs $0x804160dcb0,%rcx
  8041606f1f:	00 00 00 
  8041606f22:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606f29:	00 00 00 
  8041606f2c:	be 03 05 00 00       	mov    $0x503,%esi
  8041606f31:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606f38:	00 00 00 
  8041606f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f40:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f47:	00 00 00 
  8041606f4a:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041606f4d:	48 b9 c8 e1 60 41 80 	movabs $0x804160e1c8,%rcx
  8041606f54:	00 00 00 
  8041606f57:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606f5e:	00 00 00 
  8041606f61:	be 04 05 00 00       	mov    $0x504,%esi
  8041606f66:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606f6d:	00 00 00 
  8041606f70:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f75:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f7c:	00 00 00 
  8041606f7f:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606f82:	48 b9 96 e1 60 41 80 	movabs $0x804160e196,%rcx
  8041606f89:	00 00 00 
  8041606f8c:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606f93:	00 00 00 
  8041606f96:	be 05 05 00 00       	mov    $0x505,%esi
  8041606f9b:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606fa2:	00 00 00 
  8041606fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606faa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606fb1:	00 00 00 
  8041606fb4:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041606fb7:	48 b9 b0 d9 60 41 80 	movabs $0x804160d9b0,%rcx
  8041606fbe:	00 00 00 
  8041606fc1:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606fc8:	00 00 00 
  8041606fcb:	be 18 05 00 00       	mov    $0x518,%esi
  8041606fd0:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041606fd7:	00 00 00 
  8041606fda:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606fdf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606fe6:	00 00 00 
  8041606fe9:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606fec:	48 b9 96 e1 60 41 80 	movabs $0x804160e196,%rcx
  8041606ff3:	00 00 00 
  8041606ff6:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041606ffd:	00 00 00 
  8041607000:	be 1a 05 00 00       	mov    $0x51a,%esi
  8041607005:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160700c:	00 00 00 
  804160700f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607014:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160701b:	00 00 00 
  804160701e:	41 ff d0             	callq  *%r8
  8041607021:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041607028:	00 00 00 
  804160702b:	be 21 05 00 00       	mov    $0x521,%esi
  8041607030:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607037:	00 00 00 
  804160703a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160703f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607046:	00 00 00 
  8041607049:	41 ff d0             	callq  *%r8
  804160704c:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041607053:	00 00 00 
  8041607056:	be 22 05 00 00       	mov    $0x522,%esi
  804160705b:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607062:	00 00 00 
  8041607065:	b8 00 00 00 00       	mov    $0x0,%eax
  804160706a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607071:	00 00 00 
  8041607074:	41 ff d0             	callq  *%r8
  8041607077:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  804160707e:	00 00 00 
  8041607081:	be 23 05 00 00       	mov    $0x523,%esi
  8041607086:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160708d:	00 00 00 
  8041607090:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607095:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160709c:	00 00 00 
  804160709f:	41 ff d0             	callq  *%r8
  assert(ptep == ptep1 + PTX(va));
  80416070a2:	48 b9 d9 e1 60 41 80 	movabs $0x804160e1d9,%rcx
  80416070a9:	00 00 00 
  80416070ac:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416070b3:	00 00 00 
  80416070b6:	be 24 05 00 00       	mov    $0x524,%esi
  80416070bb:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416070c2:	00 00 00 
  80416070c5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070ca:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070d1:	00 00 00 
  80416070d4:	41 ff d0             	callq  *%r8
  80416070d7:	48 89 f9             	mov    %rdi,%rcx
  80416070da:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  80416070e1:	00 00 00 
  80416070e4:	be 61 00 00 00       	mov    $0x61,%esi
  80416070e9:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  80416070f0:	00 00 00 
  80416070f3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070f8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070ff:	00 00 00 
  8041607102:	41 ff d0             	callq  *%r8
  8041607105:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  804160710c:	00 00 00 
  804160710f:	be 2a 05 00 00       	mov    $0x52a,%esi
  8041607114:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160711b:	00 00 00 
  804160711e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607123:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160712a:	00 00 00 
  804160712d:	41 ff d0             	callq  *%r8
  8041607130:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041607137:	00 00 00 
  804160713a:	be 2b 05 00 00       	mov    $0x52b,%esi
  804160713f:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607146:	00 00 00 
  8041607149:	b8 00 00 00 00       	mov    $0x0,%eax
  804160714e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607155:	00 00 00 
  8041607158:	41 ff d0             	callq  *%r8
  804160715b:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041607162:	00 00 00 
  8041607165:	be 2c 05 00 00       	mov    $0x52c,%esi
  804160716a:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607171:	00 00 00 
  8041607174:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607179:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607180:	00 00 00 
  8041607183:	41 ff d0             	callq  *%r8
    assert((ptep[i] & PTE_P) == 0);
  8041607186:	48 b9 f1 e1 60 41 80 	movabs $0x804160e1f1,%rcx
  804160718d:	00 00 00 
  8041607190:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607197:	00 00 00 
  804160719a:	be 2e 05 00 00       	mov    $0x52e,%esi
  804160719f:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416071a6:	00 00 00 
  80416071a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071ae:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071b5:	00 00 00 
  80416071b8:	41 ff d0             	callq  *%r8
    panic("'pages' is a null pointer!");
  80416071bb:	48 ba 21 e2 60 41 80 	movabs $0x804160e221,%rdx
  80416071c2:	00 00 00 
  80416071c5:	be f5 03 00 00       	mov    $0x3f5,%esi
  80416071ca:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416071d1:	00 00 00 
  80416071d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071d9:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416071e0:	00 00 00 
  80416071e3:	ff d1                	callq  *%rcx
  assert((pp0 = page_alloc(0)));
  80416071e5:	48 b9 3c e2 60 41 80 	movabs $0x804160e23c,%rcx
  80416071ec:	00 00 00 
  80416071ef:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416071f6:	00 00 00 
  80416071f9:	be fd 03 00 00       	mov    $0x3fd,%esi
  80416071fe:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607205:	00 00 00 
  8041607208:	b8 00 00 00 00       	mov    $0x0,%eax
  804160720d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607214:	00 00 00 
  8041607217:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  804160721a:	48 b9 52 e2 60 41 80 	movabs $0x804160e252,%rcx
  8041607221:	00 00 00 
  8041607224:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160722b:	00 00 00 
  804160722e:	be fe 03 00 00       	mov    $0x3fe,%esi
  8041607233:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160723a:	00 00 00 
  804160723d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607242:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607249:	00 00 00 
  804160724c:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  804160724f:	48 b9 68 e2 60 41 80 	movabs $0x804160e268,%rcx
  8041607256:	00 00 00 
  8041607259:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607260:	00 00 00 
  8041607263:	be ff 03 00 00       	mov    $0x3ff,%esi
  8041607268:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160726f:	00 00 00 
  8041607272:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607277:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160727e:	00 00 00 
  8041607281:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  8041607284:	48 b9 21 e1 60 41 80 	movabs $0x804160e121,%rcx
  804160728b:	00 00 00 
  804160728e:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607295:	00 00 00 
  8041607298:	be 02 04 00 00       	mov    $0x402,%esi
  804160729d:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416072a4:	00 00 00 
  80416072a7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072ac:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072b3:	00 00 00 
  80416072b6:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416072b9:	48 b9 38 d8 60 41 80 	movabs $0x804160d838,%rcx
  80416072c0:	00 00 00 
  80416072c3:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416072ca:	00 00 00 
  80416072cd:	be 03 04 00 00       	mov    $0x403,%esi
  80416072d2:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416072d9:	00 00 00 
  80416072dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072e1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072e8:	00 00 00 
  80416072eb:	41 ff d0             	callq  *%r8
  assert(page2pa(pp0) < npages * PGSIZE);
  80416072ee:	48 b9 d8 dc 60 41 80 	movabs $0x804160dcd8,%rcx
  80416072f5:	00 00 00 
  80416072f8:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416072ff:	00 00 00 
  8041607302:	be 04 04 00 00       	mov    $0x404,%esi
  8041607307:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160730e:	00 00 00 
  8041607311:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607316:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160731d:	00 00 00 
  8041607320:	41 ff d0             	callq  *%r8
  assert(page2pa(pp1) < npages * PGSIZE);
  8041607323:	48 b9 f8 dc 60 41 80 	movabs $0x804160dcf8,%rcx
  804160732a:	00 00 00 
  804160732d:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607334:	00 00 00 
  8041607337:	be 05 04 00 00       	mov    $0x405,%esi
  804160733c:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607343:	00 00 00 
  8041607346:	b8 00 00 00 00       	mov    $0x0,%eax
  804160734b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607352:	00 00 00 
  8041607355:	41 ff d0             	callq  *%r8
  assert(page2pa(pp2) < npages * PGSIZE);
  8041607358:	48 b9 18 dd 60 41 80 	movabs $0x804160dd18,%rcx
  804160735f:	00 00 00 
  8041607362:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607369:	00 00 00 
  804160736c:	be 06 04 00 00       	mov    $0x406,%esi
  8041607371:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607378:	00 00 00 
  804160737b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607380:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607387:	00 00 00 
  804160738a:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  804160738d:	48 b9 3e e1 60 41 80 	movabs $0x804160e13e,%rcx
  8041607394:	00 00 00 
  8041607397:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160739e:	00 00 00 
  80416073a1:	be 0d 04 00 00       	mov    $0x40d,%esi
  80416073a6:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416073ad:	00 00 00 
  80416073b0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073b5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073bc:	00 00 00 
  80416073bf:	41 ff d0             	callq  *%r8
  assert((pp0 = page_alloc(0)));
  80416073c2:	48 b9 3c e2 60 41 80 	movabs $0x804160e23c,%rcx
  80416073c9:	00 00 00 
  80416073cc:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416073d3:	00 00 00 
  80416073d6:	be 14 04 00 00       	mov    $0x414,%esi
  80416073db:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416073e2:	00 00 00 
  80416073e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073ea:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073f1:	00 00 00 
  80416073f4:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  80416073f7:	48 b9 52 e2 60 41 80 	movabs $0x804160e252,%rcx
  80416073fe:	00 00 00 
  8041607401:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607408:	00 00 00 
  804160740b:	be 15 04 00 00       	mov    $0x415,%esi
  8041607410:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607417:	00 00 00 
  804160741a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160741f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607426:	00 00 00 
  8041607429:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  804160742c:	48 b9 68 e2 60 41 80 	movabs $0x804160e268,%rcx
  8041607433:	00 00 00 
  8041607436:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160743d:	00 00 00 
  8041607440:	be 16 04 00 00       	mov    $0x416,%esi
  8041607445:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160744c:	00 00 00 
  804160744f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607454:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160745b:	00 00 00 
  804160745e:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  8041607461:	48 b9 21 e1 60 41 80 	movabs $0x804160e121,%rcx
  8041607468:	00 00 00 
  804160746b:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607472:	00 00 00 
  8041607475:	be 18 04 00 00       	mov    $0x418,%esi
  804160747a:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607481:	00 00 00 
  8041607484:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607489:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607490:	00 00 00 
  8041607493:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041607496:	48 b9 38 d8 60 41 80 	movabs $0x804160d838,%rcx
  804160749d:	00 00 00 
  80416074a0:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416074a7:	00 00 00 
  80416074aa:	be 19 04 00 00       	mov    $0x419,%esi
  80416074af:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416074b6:	00 00 00 
  80416074b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074be:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074c5:	00 00 00 
  80416074c8:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416074cb:	48 b9 3e e1 60 41 80 	movabs $0x804160e13e,%rcx
  80416074d2:	00 00 00 
  80416074d5:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416074dc:	00 00 00 
  80416074df:	be 1a 04 00 00       	mov    $0x41a,%esi
  80416074e4:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416074eb:	00 00 00 
  80416074ee:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074f3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074fa:	00 00 00 
  80416074fd:	41 ff d0             	callq  *%r8
  8041607500:	48 89 f9             	mov    %rdi,%rcx
  8041607503:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  804160750a:	00 00 00 
  804160750d:	be 61 00 00 00       	mov    $0x61,%esi
  8041607512:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041607519:	00 00 00 
  804160751c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607521:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607528:	00 00 00 
  804160752b:	41 ff d0             	callq  *%r8
  assert((pp = page_alloc(ALLOC_ZERO)));
  804160752e:	48 b9 7e e2 60 41 80 	movabs $0x804160e27e,%rcx
  8041607535:	00 00 00 
  8041607538:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160753f:	00 00 00 
  8041607542:	be 1f 04 00 00       	mov    $0x41f,%esi
  8041607547:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160754e:	00 00 00 
  8041607551:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607558:	00 00 00 
  804160755b:	41 ff d0             	callq  *%r8
  assert(pp && pp0 == pp);
  804160755e:	48 b9 9c e2 60 41 80 	movabs $0x804160e29c,%rcx
  8041607565:	00 00 00 
  8041607568:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160756f:	00 00 00 
  8041607572:	be 20 04 00 00       	mov    $0x420,%esi
  8041607577:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160757e:	00 00 00 
  8041607581:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607586:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160758d:	00 00 00 
  8041607590:	41 ff d0             	callq  *%r8
  8041607593:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  804160759a:	00 00 00 
  804160759d:	be 61 00 00 00       	mov    $0x61,%esi
  80416075a2:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  80416075a9:	00 00 00 
  80416075ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075b1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075b8:	00 00 00 
  80416075bb:	41 ff d0             	callq  *%r8
    assert(c[i] == 0);
  80416075be:	48 b9 ac e2 60 41 80 	movabs $0x804160e2ac,%rcx
  80416075c5:	00 00 00 
  80416075c8:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416075cf:	00 00 00 
  80416075d2:	be 23 04 00 00       	mov    $0x423,%esi
  80416075d7:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416075de:	00 00 00 
  80416075e1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075e6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075ed:	00 00 00 
  80416075f0:	41 ff d0             	callq  *%r8
  assert(nfree == 0);
  80416075f3:	48 b9 b6 e2 60 41 80 	movabs $0x804160e2b6,%rcx
  80416075fa:	00 00 00 
  80416075fd:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607604:	00 00 00 
  8041607607:	be 30 04 00 00       	mov    $0x430,%esi
  804160760c:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607613:	00 00 00 
  8041607616:	b8 00 00 00 00       	mov    $0x0,%eax
  804160761b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607622:	00 00 00 
  8041607625:	41 ff d0             	callq  *%r8
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041607628:	48 89 c1             	mov    %rax,%rcx
  804160762b:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607632:	00 00 00 
  8041607635:	be 20 01 00 00       	mov    $0x120,%esi
  804160763a:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607641:	00 00 00 
  8041607644:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607649:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607650:	00 00 00 
  8041607653:	41 ff d0             	callq  *%r8
  8041607656:	48 89 c1             	mov    %rax,%rcx
  8041607659:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607660:	00 00 00 
  8041607663:	be 2b 01 00 00       	mov    $0x12b,%esi
  8041607668:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160766f:	00 00 00 
  8041607672:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607677:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160767e:	00 00 00 
  8041607681:	41 ff d0             	callq  *%r8
  8041607684:	48 89 f9             	mov    %rdi,%rcx
  8041607687:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160768e:	00 00 00 
  8041607691:	be 3a 01 00 00       	mov    $0x13a,%esi
  8041607696:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160769d:	00 00 00 
  80416076a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076a5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076ac:	00 00 00 
  80416076af:	41 ff d0             	callq  *%r8
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  80416076b2:	49 8b 4c 24 08       	mov    0x8(%r12),%rcx
    size_to_alloc = mmap_curr->NumberOfPages * PGSIZE;
  80416076b7:	49 8b 54 24 18       	mov    0x18(%r12),%rdx
  80416076bc:	48 c1 e2 0c          	shl    $0xc,%rdx
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  80416076c0:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  80416076c5:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416076cb:	49 8b 3f             	mov    (%r15),%rdi
  80416076ce:	48 b8 72 4f 60 41 80 	movabs $0x8041604f72,%rax
  80416076d5:	00 00 00 
  80416076d8:	ff d0                	callq  *%rax
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416076da:	4c 89 e0             	mov    %r12,%rax
  80416076dd:	49 03 06             	add    (%r14),%rax
  80416076e0:	49 89 c4             	mov    %rax,%r12
  80416076e3:	49 39 45 00          	cmp    %rax,0x0(%r13)
  80416076e7:	76 0a                	jbe    80416076f3 <mem_init+0x24b7>
    if (mmap_curr->Attribute & EFI_MEMORY_RUNTIME) {
  80416076e9:	49 83 7c 24 20 00    	cmpq   $0x0,0x20(%r12)
  80416076ef:	79 e9                	jns    80416076da <mem_init+0x249e>
  80416076f1:	eb bf                	jmp    80416076b2 <mem_init+0x2476>
  pml4e = kern_pml4e;
  80416076f3:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416076fa:	00 00 00 
  80416076fd:	4c 8b 28             	mov    (%rax),%r13
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
  8041607700:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041607707:	00 00 00 
  804160770a:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  804160770e:	48 c1 e0 04          	shl    $0x4,%rax
  8041607712:	48 05 ff 0f 00 00    	add    $0xfff,%rax
  for (i = 0; i < n; i += PGSIZE)
  8041607718:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160771e:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041607722:	74 6d                	je     8041607791 <mem_init+0x2555>
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  8041607724:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  804160772b:	00 00 00 
  804160772e:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  if ((uint64_t)kva < KERNBASE)
  8041607732:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  return (physaddr_t)kva - KERNBASE;
  8041607736:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  804160773d:	ff ff ff 
  8041607740:	49 01 c6             	add    %rax,%r14
  for (i = 0; i < n; i += PGSIZE)
  8041607743:	49 89 dc             	mov    %rbx,%r12
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  8041607746:	49 bf 00 e0 42 3c 80 	movabs $0x803c42e000,%r15
  804160774d:	00 00 00 
  8041607750:	4b 8d 34 3c          	lea    (%r12,%r15,1),%rsi
  8041607754:	4c 89 ef             	mov    %r13,%rdi
  8041607757:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  804160775e:	00 00 00 
  8041607761:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041607763:	48 bf ff ff ff 3f 80 	movabs $0x803fffffff,%rdi
  804160776a:	00 00 00 
  804160776d:	48 39 7d b0          	cmp    %rdi,-0x50(%rbp)
  8041607771:	0f 86 a4 01 00 00    	jbe    804160791b <mem_init+0x26df>
  8041607777:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  804160777b:	48 39 c2             	cmp    %rax,%rdx
  804160777e:	0f 85 c6 01 00 00    	jne    804160794a <mem_init+0x270e>
  for (i = 0; i < n; i += PGSIZE)
  8041607784:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  804160778b:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  804160778f:	77 bf                	ja     8041607750 <mem_init+0x2514>
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  8041607791:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  8041607798:	00 00 00 
  804160779b:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  804160779f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416077a3:	49 bc 00 e0 22 3c 80 	movabs $0x803c22e000,%r12
  80416077aa:	00 00 00 
  80416077ad:	49 bf cb 40 60 41 80 	movabs $0x80416040cb,%r15
  80416077b4:	00 00 00 
  80416077b7:	49 be 00 20 dd 83 ff 	movabs $0xfffffeff83dd2000,%r14
  80416077be:	fe ff ff 
  80416077c1:	49 01 c6             	add    %rax,%r14
  80416077c4:	4c 89 e6             	mov    %r12,%rsi
  80416077c7:	4c 89 ef             	mov    %r13,%rdi
  80416077ca:	41 ff d7             	callq  *%r15
  80416077cd:	48 b9 ff ff ff 3f 80 	movabs $0x803fffffff,%rcx
  80416077d4:	00 00 00 
  80416077d7:	48 39 4d b8          	cmp    %rcx,-0x48(%rbp)
  80416077db:	0f 86 9e 01 00 00    	jbe    804160797f <mem_init+0x2743>
  80416077e1:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  80416077e5:	48 39 c2             	cmp    %rax,%rdx
  80416077e8:	0f 85 c0 01 00 00    	jne    80416079ae <mem_init+0x2772>
  for (i = 0; i < n; i += PGSIZE)
  80416077ee:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  80416077f5:	48 b8 00 60 27 3c 80 	movabs $0x803c276000,%rax
  80416077fc:	00 00 00 
  80416077ff:	49 39 c4             	cmp    %rax,%r12
  8041607802:	75 c0                	jne    80416077c4 <mem_init+0x2588>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607804:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041607808:	48 c1 e0 0c          	shl    $0xc,%rax
  804160780c:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041607810:	0f 84 02 02 00 00    	je     8041607a18 <mem_init+0x27dc>
  8041607816:	49 89 dc             	mov    %rbx,%r12
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  8041607819:	49 bf 00 00 00 40 80 	movabs $0x8040000000,%r15
  8041607820:	00 00 00 
  8041607823:	49 be cb 40 60 41 80 	movabs $0x80416040cb,%r14
  804160782a:	00 00 00 
  804160782d:	4b 8d 34 3c          	lea    (%r12,%r15,1),%rsi
  8041607831:	4c 89 ef             	mov    %r13,%rdi
  8041607834:	41 ff d6             	callq  *%r14
  8041607837:	4c 39 e0             	cmp    %r12,%rax
  804160783a:	0f 85 a3 01 00 00    	jne    80416079e3 <mem_init+0x27a7>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607840:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041607847:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  804160784b:	77 e0                	ja     804160782d <mem_init+0x25f1>
  804160784d:	49 bc 00 00 ff 3f 80 	movabs $0x803fff0000,%r12
  8041607854:	00 00 00 
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8041607857:	49 bf cb 40 60 41 80 	movabs $0x80416040cb,%r15
  804160785e:	00 00 00 
  8041607861:	49 be 00 00 01 80 ff 	movabs $0xfffffeff80010000,%r14
  8041607868:	fe ff ff 
  804160786b:	48 b8 00 00 61 41 80 	movabs $0x8041610000,%rax
  8041607872:	00 00 00 
  8041607875:	49 01 c6             	add    %rax,%r14
  8041607878:	4c 89 e6             	mov    %r12,%rsi
  804160787b:	4c 89 ef             	mov    %r13,%rdi
  804160787e:	41 ff d7             	callq  *%r15
  8041607881:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  8041607885:	48 39 d0             	cmp    %rdx,%rax
  8041607888:	0f 85 99 01 00 00    	jne    8041607a27 <mem_init+0x27eb>
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
  804160788e:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041607895:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160789c:	00 00 00 
  804160789f:	49 39 c4             	cmp    %rax,%r12
  80416078a2:	75 d4                	jne    8041607878 <mem_init+0x263c>
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  80416078a4:	48 be 00 00 e0 3f 80 	movabs $0x803fe00000,%rsi
  80416078ab:	00 00 00 
  80416078ae:	4c 89 ef             	mov    %r13,%rdi
  80416078b1:	48 b8 cb 40 60 41 80 	movabs $0x80416040cb,%rax
  80416078b8:	00 00 00 
  80416078bb:	ff d0                	callq  *%rax
  80416078bd:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  80416078c1:	0f 85 95 01 00 00    	jne    8041607a5c <mem_init+0x2820>
  pdpe_t *pdpe = KADDR(PTE_ADDR(kern_pml4e[1]));
  80416078c7:	49 8b 4d 08          	mov    0x8(%r13),%rcx
  80416078cb:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  80416078d2:	48 89 c8             	mov    %rcx,%rax
  80416078d5:	48 c1 e8 0c          	shr    $0xc,%rax
  80416078d9:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  80416078dd:	0f 86 ae 01 00 00    	jbe    8041607a91 <mem_init+0x2855>
  pde_t *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  80416078e3:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416078ea:	00 00 00 
  80416078ed:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  80416078f1:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416078f8:	48 89 c8             	mov    %rcx,%rax
  80416078fb:	48 c1 e8 0c          	shr    $0xc,%rax
  80416078ff:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  8041607903:	0f 86 b3 01 00 00    	jbe    8041607abc <mem_init+0x2880>
  return (void *)(pa + KERNBASE);
  8041607909:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607910:	00 00 00 
  8041607913:	48 01 c1             	add    %rax,%rcx
  for (i = 0; i < NPDENTRIES; i++) {
  8041607916:	e9 ef 01 00 00       	jmpq   8041607b0a <mem_init+0x28ce>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160791b:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  804160791f:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607926:	00 00 00 
  8041607929:	be 47 04 00 00       	mov    $0x447,%esi
  804160792e:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607935:	00 00 00 
  8041607938:	b8 00 00 00 00       	mov    $0x0,%eax
  804160793d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607944:	00 00 00 
  8041607947:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  804160794a:	48 b9 58 dd 60 41 80 	movabs $0x804160dd58,%rcx
  8041607951:	00 00 00 
  8041607954:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160795b:	00 00 00 
  804160795e:	be 47 04 00 00       	mov    $0x447,%esi
  8041607963:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  804160796a:	00 00 00 
  804160796d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607972:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607979:	00 00 00 
  804160797c:	41 ff d0             	callq  *%r8
  804160797f:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041607983:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160798a:	00 00 00 
  804160798d:	be 4c 04 00 00       	mov    $0x44c,%esi
  8041607992:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607999:	00 00 00 
  804160799c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079a1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079a8:	00 00 00 
  80416079ab:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  80416079ae:	48 b9 90 dd 60 41 80 	movabs $0x804160dd90,%rcx
  80416079b5:	00 00 00 
  80416079b8:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416079bf:	00 00 00 
  80416079c2:	be 4c 04 00 00       	mov    $0x44c,%esi
  80416079c7:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416079ce:	00 00 00 
  80416079d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079d6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079dd:	00 00 00 
  80416079e0:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  80416079e3:	48 b9 c8 dd 60 41 80 	movabs $0x804160ddc8,%rcx
  80416079ea:	00 00 00 
  80416079ed:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416079f4:	00 00 00 
  80416079f7:	be 50 04 00 00       	mov    $0x450,%esi
  80416079fc:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607a03:	00 00 00 
  8041607a06:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a0b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a12:	00 00 00 
  8041607a15:	41 ff d0             	callq  *%r8
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607a18:	49 bc 00 00 ff 3f 80 	movabs $0x803fff0000,%r12
  8041607a1f:	00 00 00 
  8041607a22:	e9 30 fe ff ff       	jmpq   8041607857 <mem_init+0x261b>
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8041607a27:	48 b9 f0 dd 60 41 80 	movabs $0x804160ddf0,%rcx
  8041607a2e:	00 00 00 
  8041607a31:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607a38:	00 00 00 
  8041607a3b:	be 54 04 00 00       	mov    $0x454,%esi
  8041607a40:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607a47:	00 00 00 
  8041607a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a4f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a56:	00 00 00 
  8041607a59:	41 ff d0             	callq  *%r8
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  8041607a5c:	48 b9 38 de 60 41 80 	movabs $0x804160de38,%rcx
  8041607a63:	00 00 00 
  8041607a66:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607a6d:	00 00 00 
  8041607a70:	be 55 04 00 00       	mov    $0x455,%esi
  8041607a75:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607a7c:	00 00 00 
  8041607a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a84:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a8b:	00 00 00 
  8041607a8e:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041607a91:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041607a98:	00 00 00 
  8041607a9b:	be 57 04 00 00       	mov    $0x457,%esi
  8041607aa0:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607aa7:	00 00 00 
  8041607aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607aaf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607ab6:	00 00 00 
  8041607ab9:	41 ff d0             	callq  *%r8
  8041607abc:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041607ac3:	00 00 00 
  8041607ac6:	be 58 04 00 00       	mov    $0x458,%esi
  8041607acb:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607ad2:	00 00 00 
  8041607ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ada:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607ae1:	00 00 00 
  8041607ae4:	41 ff d0             	callq  *%r8
    switch (i) {
  8041607ae7:	48 81 fb 00 00 08 00 	cmp    $0x80000,%rbx
  8041607aee:	75 32                	jne    8041607b22 <mem_init+0x28e6>
        assert(pgdir[i] & PTE_P);
  8041607af0:	f6 01 01             	testb  $0x1,(%rcx)
  8041607af3:	74 7a                	je     8041607b6f <mem_init+0x2933>
  for (i = 0; i < NPDENTRIES; i++) {
  8041607af5:	48 83 c3 01          	add    $0x1,%rbx
  8041607af9:	48 83 c1 08          	add    $0x8,%rcx
  8041607afd:	48 81 fb 00 02 00 00 	cmp    $0x200,%rbx
  8041607b04:	0f 84 d8 00 00 00    	je     8041607be2 <mem_init+0x29a6>
    switch (i) {
  8041607b0a:	48 81 fb ff 01 04 00 	cmp    $0x401ff,%rbx
  8041607b11:	74 dd                	je     8041607af0 <mem_init+0x28b4>
  8041607b13:	77 d2                	ja     8041607ae7 <mem_init+0x28ab>
  8041607b15:	48 8d 83 1f fe fb ff 	lea    -0x401e1(%rbx),%rax
  8041607b1c:	48 83 f8 01          	cmp    $0x1,%rax
  8041607b20:	76 ce                	jbe    8041607af0 <mem_init+0x28b4>
        if (i >= VPD(KERNBASE)) {
  8041607b22:	48 81 fb ff 01 04 00 	cmp    $0x401ff,%rbx
  8041607b29:	76 ca                	jbe    8041607af5 <mem_init+0x28b9>
          if (pgdir[i] & PTE_P)
  8041607b2b:	48 8b 01             	mov    (%rcx),%rax
  8041607b2e:	a8 01                	test   $0x1,%al
  8041607b30:	74 72                	je     8041607ba4 <mem_init+0x2968>
            assert(pgdir[i] & PTE_W);
  8041607b32:	a8 02                	test   $0x2,%al
  8041607b34:	0f 85 4a 07 00 00    	jne    8041608284 <mem_init+0x3048>
  8041607b3a:	48 b9 d2 e2 60 41 80 	movabs $0x804160e2d2,%rcx
  8041607b41:	00 00 00 
  8041607b44:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607b4b:	00 00 00 
  8041607b4e:	be 65 04 00 00       	mov    $0x465,%esi
  8041607b53:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607b5a:	00 00 00 
  8041607b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b62:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b69:	00 00 00 
  8041607b6c:	41 ff d0             	callq  *%r8
        assert(pgdir[i] & PTE_P);
  8041607b6f:	48 b9 c1 e2 60 41 80 	movabs $0x804160e2c1,%rcx
  8041607b76:	00 00 00 
  8041607b79:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607b80:	00 00 00 
  8041607b83:	be 60 04 00 00       	mov    $0x460,%esi
  8041607b88:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607b8f:	00 00 00 
  8041607b92:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b97:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b9e:	00 00 00 
  8041607ba1:	41 ff d0             	callq  *%r8
            assert(pgdir[i] == 0);
  8041607ba4:	48 85 c0             	test   %rax,%rax
  8041607ba7:	0f 84 d7 06 00 00    	je     8041608284 <mem_init+0x3048>
  8041607bad:	48 b9 e3 e2 60 41 80 	movabs $0x804160e2e3,%rcx
  8041607bb4:	00 00 00 
  8041607bb7:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607bbe:	00 00 00 
  8041607bc1:	be 67 04 00 00       	mov    $0x467,%esi
  8041607bc6:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607bcd:	00 00 00 
  8041607bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607bd5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607bdc:	00 00 00 
  8041607bdf:	41 ff d0             	callq  *%r8
  cprintf("check_kern_pml4e() succeeded!\n");
  8041607be2:	48 bf 68 de 60 41 80 	movabs $0x804160de68,%rdi
  8041607be9:	00 00 00 
  8041607bec:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607bf1:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041607bf8:	00 00 00 
  8041607bfb:	ff d2                	callq  *%rdx
  mmap_base = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)uefi_lp->MemoryMapVirt;
  8041607bfd:	48 b9 00 00 62 41 80 	movabs $0x8041620000,%rcx
  8041607c04:	00 00 00 
  8041607c07:	48 8b 11             	mov    (%rcx),%rdx
  8041607c0a:	48 8b 42 30          	mov    0x30(%rdx),%rax
  8041607c0e:	48 a3 f0 44 88 41 80 	movabs %rax,0x80418844f0
  8041607c15:	00 00 00 
  mmap_end  = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)uefi_lp->MemoryMapVirt + uefi_lp->MemoryMapSize);
  8041607c18:	48 03 42 38          	add    0x38(%rdx),%rax
  8041607c1c:	48 a3 e8 44 88 41 80 	movabs %rax,0x80418844e8
  8041607c23:	00 00 00 
  uefi_lp   = (LOADER_PARAMS *)uefi_lp->SelfVirtual;
  8041607c26:	48 8b 12             	mov    (%rdx),%rdx
  8041607c29:	48 89 11             	mov    %rdx,(%rcx)
  __asm __volatile("movq %0,%%cr3"
  8041607c2c:	48 a1 48 5a 88 41 80 	movabs 0x8041885a48,%rax
  8041607c33:	00 00 00 
  8041607c36:	0f 22 d8             	mov    %rax,%cr3
  __asm __volatile("movq %%cr0,%0"
  8041607c39:	0f 20 c0             	mov    %cr0,%rax
    cr0 &= ~(CR0_TS | CR0_EM);
  8041607c3c:	48 83 e0 f3          	and    $0xfffffffffffffff3,%rax
  8041607c40:	b9 23 00 05 80       	mov    $0x80050023,%ecx
  8041607c45:	48 09 c8             	or     %rcx,%rax
  __asm __volatile("movq %0,%%cr0"
  8041607c48:	0f 22 c0             	mov    %rax,%cr0
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607c4b:	48 8b 4a 40          	mov    0x40(%rdx),%rcx
  uintptr_t size     = lp->FrameBufferSize;
  8041607c4f:	8b 52 48             	mov    0x48(%rdx),%edx
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607c52:	48 bb 40 5a 88 41 80 	movabs $0x8041885a40,%rbx
  8041607c59:	00 00 00 
  8041607c5c:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041607c62:	48 be 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rsi
  8041607c69:	00 00 00 
  8041607c6c:	48 8b 3b             	mov    (%rbx),%rdi
  8041607c6f:	48 b8 72 4f 60 41 80 	movabs $0x8041604f72,%rax
  8041607c76:	00 00 00 
  8041607c79:	ff d0                	callq  *%rax
check_page_installed_pml4(void) {
  struct PageInfo *pp0, *pp1, *pp2;
  pml4e_t pml4e_old; //used to store value instead of pointer

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041607c7b:	48 8b 03             	mov    (%rbx),%rax
  8041607c7e:	4c 8b 30             	mov    (%rax),%r14
  kern_pml4e[0] = 0;
  8041607c81:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  8041607c88:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607c8d:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041607c94:	00 00 00 
  8041607c97:	ff d0                	callq  *%rax
  8041607c99:	49 89 c4             	mov    %rax,%r12
  8041607c9c:	48 85 c0             	test   %rax,%rax
  8041607c9f:	0f 84 aa 02 00 00    	je     8041607f4f <mem_init+0x2d13>
  assert((pp1 = page_alloc(0)));
  8041607ca5:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607caa:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041607cb1:	00 00 00 
  8041607cb4:	ff d0                	callq  *%rax
  8041607cb6:	49 89 c5             	mov    %rax,%r13
  8041607cb9:	48 85 c0             	test   %rax,%rax
  8041607cbc:	0f 84 c2 02 00 00    	je     8041607f84 <mem_init+0x2d48>
  assert((pp2 = page_alloc(0)));
  8041607cc2:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607cc7:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  8041607cce:	00 00 00 
  8041607cd1:	ff d0                	callq  *%rax
  8041607cd3:	48 89 c3             	mov    %rax,%rbx
  8041607cd6:	48 85 c0             	test   %rax,%rax
  8041607cd9:	0f 84 da 02 00 00    	je     8041607fb9 <mem_init+0x2d7d>
  page_free(pp0);
  8041607cdf:	4c 89 e7             	mov    %r12,%rdi
  8041607ce2:	48 b8 f7 4a 60 41 80 	movabs $0x8041604af7,%rax
  8041607ce9:	00 00 00 
  8041607cec:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607cee:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607cf5:	00 00 00 
  8041607cf8:	4c 89 e9             	mov    %r13,%rcx
  8041607cfb:	48 2b 08             	sub    (%rax),%rcx
  8041607cfe:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607d02:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607d06:	48 89 ca             	mov    %rcx,%rdx
  8041607d09:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607d0d:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041607d14:	00 00 00 
  8041607d17:	48 3b 10             	cmp    (%rax),%rdx
  8041607d1a:	0f 83 ce 02 00 00    	jae    8041607fee <mem_init+0x2db2>
  return (void *)(pa + KERNBASE);
  8041607d20:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607d27:	00 00 00 
  8041607d2a:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp1), 1, PGSIZE);
  8041607d2d:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607d32:	be 01 00 00 00       	mov    $0x1,%esi
  8041607d37:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  8041607d3e:	00 00 00 
  8041607d41:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607d43:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607d4a:	00 00 00 
  8041607d4d:	48 89 d9             	mov    %rbx,%rcx
  8041607d50:	48 2b 08             	sub    (%rax),%rcx
  8041607d53:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607d57:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607d5b:	48 89 ca             	mov    %rcx,%rdx
  8041607d5e:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607d62:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041607d69:	00 00 00 
  8041607d6c:	48 3b 10             	cmp    (%rax),%rdx
  8041607d6f:	0f 83 a4 02 00 00    	jae    8041608019 <mem_init+0x2ddd>
  return (void *)(pa + KERNBASE);
  8041607d75:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607d7c:	00 00 00 
  8041607d7f:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp2), 2, PGSIZE);
  8041607d82:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607d87:	be 02 00 00 00       	mov    $0x2,%esi
  8041607d8c:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  8041607d93:	00 00 00 
  8041607d96:	ff d0                	callq  *%rax
  page_insert(kern_pml4e, pp1, (void *)PGSIZE, PTE_W);
  8041607d98:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607d9d:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607da2:	4c 89 ee             	mov    %r13,%rsi
  8041607da5:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607dac:	00 00 00 
  8041607daf:	48 8b 38             	mov    (%rax),%rdi
  8041607db2:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  8041607db9:	00 00 00 
  8041607dbc:	ff d0                	callq  *%rax
  assert(pp1->pp_ref == 1);
  8041607dbe:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041607dc4:	0f 85 7a 02 00 00    	jne    8041608044 <mem_init+0x2e08>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041607dca:	81 3c 25 00 10 00 00 	cmpl   $0x1010101,0x1000
  8041607dd1:	01 01 01 01 
  8041607dd5:	0f 85 9e 02 00 00    	jne    8041608079 <mem_init+0x2e3d>
  page_insert(kern_pml4e, pp2, (void *)PGSIZE, PTE_W);
  8041607ddb:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607de0:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607de5:	48 89 de             	mov    %rbx,%rsi
  8041607de8:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607def:	00 00 00 
  8041607df2:	48 8b 38             	mov    (%rax),%rdi
  8041607df5:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  8041607dfc:	00 00 00 
  8041607dff:	ff d0                	callq  *%rax
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  8041607e01:	81 3c 25 00 10 00 00 	cmpl   $0x2020202,0x1000
  8041607e08:	02 02 02 02 
  8041607e0c:	0f 85 9c 02 00 00    	jne    80416080ae <mem_init+0x2e72>
  assert(pp2->pp_ref == 1);
  8041607e12:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041607e17:	0f 85 c6 02 00 00    	jne    80416080e3 <mem_init+0x2ea7>
  assert(pp1->pp_ref == 0);
  8041607e1d:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041607e23:	0f 85 ef 02 00 00    	jne    8041608118 <mem_init+0x2edc>
  *(uint32_t *)PGSIZE = 0x03030303U;
  8041607e29:	c7 04 25 00 10 00 00 	movl   $0x3030303,0x1000
  8041607e30:	03 03 03 03 
  return (pp - pages) << PGSHIFT;
  8041607e34:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607e3b:	00 00 00 
  8041607e3e:	48 89 d9             	mov    %rbx,%rcx
  8041607e41:	48 2b 08             	sub    (%rax),%rcx
  8041607e44:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607e48:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607e4c:	48 89 ca             	mov    %rcx,%rdx
  8041607e4f:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607e53:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041607e5a:	00 00 00 
  8041607e5d:	48 3b 10             	cmp    (%rax),%rdx
  8041607e60:	0f 83 e7 02 00 00    	jae    804160814d <mem_init+0x2f11>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  8041607e66:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607e6d:	00 00 00 
  8041607e70:	81 3c 01 03 03 03 03 	cmpl   $0x3030303,(%rcx,%rax,1)
  8041607e77:	0f 85 fb 02 00 00    	jne    8041608178 <mem_init+0x2f3c>
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041607e7d:	be 00 10 00 00       	mov    $0x1000,%esi
  8041607e82:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607e89:	00 00 00 
  8041607e8c:	48 8b 38             	mov    (%rax),%rdi
  8041607e8f:	48 b8 b0 50 60 41 80 	movabs $0x80416050b0,%rax
  8041607e96:	00 00 00 
  8041607e99:	ff d0                	callq  *%rax
  assert(pp2->pp_ref == 0);
  8041607e9b:	66 83 7b 08 00       	cmpw   $0x0,0x8(%rbx)
  8041607ea0:	0f 85 07 03 00 00    	jne    80416081ad <mem_init+0x2f71>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  8041607ea6:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607ead:	00 00 00 
  8041607eb0:	48 8b 08             	mov    (%rax),%rcx
  8041607eb3:	48 8b 11             	mov    (%rcx),%rdx
  8041607eb6:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041607ebd:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607ec4:	00 00 00 
  8041607ec7:	4c 89 e3             	mov    %r12,%rbx
  8041607eca:	48 2b 18             	sub    (%rax),%rbx
  8041607ecd:	48 89 d8             	mov    %rbx,%rax
  8041607ed0:	48 c1 f8 04          	sar    $0x4,%rax
  8041607ed4:	48 c1 e0 0c          	shl    $0xc,%rax
  8041607ed8:	48 39 c2             	cmp    %rax,%rdx
  8041607edb:	0f 85 01 03 00 00    	jne    80416081e2 <mem_init+0x2fa6>
  kern_pml4e[0] = 0;
  8041607ee1:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  assert(pp0->pp_ref == 1);
  8041607ee8:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041607eef:	0f 85 22 03 00 00    	jne    8041608217 <mem_init+0x2fdb>
  pp0->pp_ref = 0;
  8041607ef5:	66 41 c7 44 24 08 00 	movw   $0x0,0x8(%r12)
  8041607efc:	00 

  // free the pages we took
  page_free(pp0);
  8041607efd:	4c 89 e7             	mov    %r12,%rdi
  8041607f00:	48 b8 f7 4a 60 41 80 	movabs $0x8041604af7,%rax
  8041607f07:	00 00 00 
  8041607f0a:	ff d0                	callq  *%rax

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041607f0c:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  8041607f13:	00 00 00 
  8041607f16:	4c 89 30             	mov    %r14,(%rax)

  cprintf("check_page_installed_pml4() succeeded!\n");
  8041607f19:	48 bf 30 df 60 41 80 	movabs $0x804160df30,%rdi
  8041607f20:	00 00 00 
  8041607f23:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f28:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041607f2f:	00 00 00 
  8041607f32:	ff d2                	callq  *%rdx
  struct PageInfo *pp = page_free_list, *pt = NULL;
  8041607f34:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041607f3b:	00 00 00 
  8041607f3e:	48 8b 10             	mov    (%rax),%rdx
  while (pp) {
  8041607f41:	48 85 d2             	test   %rdx,%rdx
  8041607f44:	0f 85 05 03 00 00    	jne    804160824f <mem_init+0x3013>
  8041607f4a:	e9 08 03 00 00       	jmpq   8041608257 <mem_init+0x301b>
  assert((pp0 = page_alloc(0)));
  8041607f4f:	48 b9 3c e2 60 41 80 	movabs $0x804160e23c,%rcx
  8041607f56:	00 00 00 
  8041607f59:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607f60:	00 00 00 
  8041607f63:	be 4b 05 00 00       	mov    $0x54b,%esi
  8041607f68:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607f6f:	00 00 00 
  8041607f72:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f77:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607f7e:	00 00 00 
  8041607f81:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607f84:	48 b9 52 e2 60 41 80 	movabs $0x804160e252,%rcx
  8041607f8b:	00 00 00 
  8041607f8e:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607f95:	00 00 00 
  8041607f98:	be 4c 05 00 00       	mov    $0x54c,%esi
  8041607f9d:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607fa4:	00 00 00 
  8041607fa7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fac:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607fb3:	00 00 00 
  8041607fb6:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041607fb9:	48 b9 68 e2 60 41 80 	movabs $0x804160e268,%rcx
  8041607fc0:	00 00 00 
  8041607fc3:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041607fca:	00 00 00 
  8041607fcd:	be 4d 05 00 00       	mov    $0x54d,%esi
  8041607fd2:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041607fd9:	00 00 00 
  8041607fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fe1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607fe8:	00 00 00 
  8041607feb:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041607fee:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041607ff5:	00 00 00 
  8041607ff8:	be 61 00 00 00       	mov    $0x61,%esi
  8041607ffd:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041608004:	00 00 00 
  8041608007:	b8 00 00 00 00       	mov    $0x0,%eax
  804160800c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608013:	00 00 00 
  8041608016:	41 ff d0             	callq  *%r8
  8041608019:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041608020:	00 00 00 
  8041608023:	be 61 00 00 00       	mov    $0x61,%esi
  8041608028:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  804160802f:	00 00 00 
  8041608032:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608037:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160803e:	00 00 00 
  8041608041:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041608044:	48 b9 4d e1 60 41 80 	movabs $0x804160e14d,%rcx
  804160804b:	00 00 00 
  804160804e:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041608055:	00 00 00 
  8041608058:	be 52 05 00 00       	mov    $0x552,%esi
  804160805d:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608064:	00 00 00 
  8041608067:	b8 00 00 00 00       	mov    $0x0,%eax
  804160806c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608073:	00 00 00 
  8041608076:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041608079:	48 b9 88 de 60 41 80 	movabs $0x804160de88,%rcx
  8041608080:	00 00 00 
  8041608083:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  804160808a:	00 00 00 
  804160808d:	be 53 05 00 00       	mov    $0x553,%esi
  8041608092:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608099:	00 00 00 
  804160809c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080a1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080a8:	00 00 00 
  80416080ab:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  80416080ae:	48 b9 b0 de 60 41 80 	movabs $0x804160deb0,%rcx
  80416080b5:	00 00 00 
  80416080b8:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416080bf:	00 00 00 
  80416080c2:	be 55 05 00 00       	mov    $0x555,%esi
  80416080c7:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416080ce:	00 00 00 
  80416080d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080d6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080dd:	00 00 00 
  80416080e0:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 1);
  80416080e3:	48 b9 f1 e2 60 41 80 	movabs $0x804160e2f1,%rcx
  80416080ea:	00 00 00 
  80416080ed:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416080f4:	00 00 00 
  80416080f7:	be 56 05 00 00       	mov    $0x556,%esi
  80416080fc:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608103:	00 00 00 
  8041608106:	b8 00 00 00 00       	mov    $0x0,%eax
  804160810b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608112:	00 00 00 
  8041608115:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041608118:	48 b9 c8 e1 60 41 80 	movabs $0x804160e1c8,%rcx
  804160811f:	00 00 00 
  8041608122:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041608129:	00 00 00 
  804160812c:	be 57 05 00 00       	mov    $0x557,%esi
  8041608131:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608138:	00 00 00 
  804160813b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608140:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608147:	00 00 00 
  804160814a:	41 ff d0             	callq  *%r8
  804160814d:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041608154:	00 00 00 
  8041608157:	be 61 00 00 00       	mov    $0x61,%esi
  804160815c:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041608163:	00 00 00 
  8041608166:	b8 00 00 00 00       	mov    $0x0,%eax
  804160816b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608172:	00 00 00 
  8041608175:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  8041608178:	48 b9 d8 de 60 41 80 	movabs $0x804160ded8,%rcx
  804160817f:	00 00 00 
  8041608182:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041608189:	00 00 00 
  804160818c:	be 59 05 00 00       	mov    $0x559,%esi
  8041608191:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608198:	00 00 00 
  804160819b:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081a0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081a7:	00 00 00 
  80416081aa:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 0);
  80416081ad:	48 b9 02 e3 60 41 80 	movabs $0x804160e302,%rcx
  80416081b4:	00 00 00 
  80416081b7:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416081be:	00 00 00 
  80416081c1:	be 5b 05 00 00       	mov    $0x55b,%esi
  80416081c6:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416081cd:	00 00 00 
  80416081d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081d5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081dc:	00 00 00 
  80416081df:	41 ff d0             	callq  *%r8
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  80416081e2:	48 b9 08 df 60 41 80 	movabs $0x804160df08,%rcx
  80416081e9:	00 00 00 
  80416081ec:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  80416081f3:	00 00 00 
  80416081f6:	be 5e 05 00 00       	mov    $0x55e,%esi
  80416081fb:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608202:	00 00 00 
  8041608205:	b8 00 00 00 00       	mov    $0x0,%eax
  804160820a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608211:	00 00 00 
  8041608214:	41 ff d0             	callq  *%r8
  assert(pp0->pp_ref == 1);
  8041608217:	48 b9 13 e3 60 41 80 	movabs $0x804160e313,%rcx
  804160821e:	00 00 00 
  8041608221:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041608228:	00 00 00 
  804160822b:	be 60 05 00 00       	mov    $0x560,%esi
  8041608230:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608237:	00 00 00 
  804160823a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160823f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608246:	00 00 00 
  8041608249:	41 ff d0             	callq  *%r8
    pp = pp->pp_link;
  804160824c:	48 89 c2             	mov    %rax,%rdx
  804160824f:	48 8b 02             	mov    (%rdx),%rax
  while (pp) {
  8041608252:	48 85 c0             	test   %rax,%rax
  8041608255:	75 f5                	jne    804160824c <mem_init+0x3010>
  page_free_list_top = evaluate_page_free_list_top();
  8041608257:	48 89 d0             	mov    %rdx,%rax
  804160825a:	48 a3 08 45 88 41 80 	movabs %rax,0x8041884508
  8041608261:	00 00 00 
  check_page_free_list(0);
  8041608264:	bf 00 00 00 00       	mov    $0x0,%edi
  8041608269:	48 b8 46 43 60 41 80 	movabs $0x8041604346,%rax
  8041608270:	00 00 00 
  8041608273:	ff d0                	callq  *%rax
}
  8041608275:	48 83 c4 38          	add    $0x38,%rsp
  8041608279:	5b                   	pop    %rbx
  804160827a:	41 5c                	pop    %r12
  804160827c:	41 5d                	pop    %r13
  804160827e:	41 5e                	pop    %r14
  8041608280:	41 5f                	pop    %r15
  8041608282:	5d                   	pop    %rbp
  8041608283:	c3                   	retq   
  for (i = 0; i < NPDENTRIES; i++) {
  8041608284:	48 83 c3 01          	add    $0x1,%rbx
  8041608288:	48 83 c1 08          	add    $0x8,%rcx
  804160828c:	e9 79 f8 ff ff       	jmpq   8041607b0a <mem_init+0x28ce>

0000008041608291 <mmio_map_region>:
mmio_map_region(physaddr_t pa, size_t size) {
  8041608291:	55                   	push   %rbp
  8041608292:	48 89 e5             	mov    %rsp,%rbp
  8041608295:	53                   	push   %rbx
  8041608296:	48 83 ec 08          	sub    $0x8,%rsp
  uintptr_t pa2 = ROUNDDOWN(pa, PGSIZE);
  804160829a:	48 89 f9             	mov    %rdi,%rcx
  804160829d:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (base + size >= MMIOLIM) {
  80416082a4:	48 a1 20 07 62 41 80 	movabs 0x8041620720,%rax
  80416082ab:	00 00 00 
  80416082ae:	4c 8d 04 30          	lea    (%rax,%rsi,1),%r8
  80416082b2:	48 ba ff ff df 3f 80 	movabs $0x803fdfffff,%rdx
  80416082b9:	00 00 00 
  80416082bc:	49 39 d0             	cmp    %rdx,%r8
  80416082bf:	77 54                	ja     8041608315 <mmio_map_region+0x84>
  size = ROUNDUP(size + (pa - pa2 ), PGSIZE);
  80416082c1:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
  80416082c7:	48 8d 9c 3e ff 0f 00 	lea    0xfff(%rsi,%rdi,1),%rbx
  80416082ce:	00 
  80416082cf:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  boot_map_region(kern_pml4e, base, size, pa2, PTE_PCD | PTE_PWT | PTE_W);
  80416082d6:	41 b8 1a 00 00 00    	mov    $0x1a,%r8d
  80416082dc:	48 89 da             	mov    %rbx,%rdx
  80416082df:	48 89 c6             	mov    %rax,%rsi
  80416082e2:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416082e9:	00 00 00 
  80416082ec:	48 8b 38             	mov    (%rax),%rdi
  80416082ef:	48 b8 72 4f 60 41 80 	movabs $0x8041604f72,%rax
  80416082f6:	00 00 00 
  80416082f9:	ff d0                	callq  *%rax
  void * new = (void *) base;
  80416082fb:	48 ba 20 07 62 41 80 	movabs $0x8041620720,%rdx
  8041608302:	00 00 00 
  8041608305:	48 8b 02             	mov    (%rdx),%rax
  base += size;
  8041608308:	48 01 c3             	add    %rax,%rbx
  804160830b:	48 89 1a             	mov    %rbx,(%rdx)
}
  804160830e:	48 83 c4 08          	add    $0x8,%rsp
  8041608312:	5b                   	pop    %rbx
  8041608313:	5d                   	pop    %rbp
  8041608314:	c3                   	retq   
    panic("Allocated MMIO addr is too high! [0x%016lu;0x%016lu]",pa, pa+size);
  8041608315:	4c 8d 04 37          	lea    (%rdi,%rsi,1),%r8
  8041608319:	48 89 f9             	mov    %rdi,%rcx
  804160831c:	48 ba 58 df 60 41 80 	movabs $0x804160df58,%rdx
  8041608323:	00 00 00 
  8041608326:	be 4f 03 00 00       	mov    $0x34f,%esi
  804160832b:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  8041608332:	00 00 00 
  8041608335:	b8 00 00 00 00       	mov    $0x0,%eax
  804160833a:	49 b9 5a 02 60 41 80 	movabs $0x804160025a,%r9
  8041608341:	00 00 00 
  8041608344:	41 ff d1             	callq  *%r9

0000008041608347 <mmio_remap_last_region>:
mmio_remap_last_region(physaddr_t pa, void *addr, size_t oldsize, size_t newsize) {
  8041608347:	55                   	push   %rbp
  8041608348:	48 89 e5             	mov    %rsp,%rbp
  if (base - oldsize != (uintptr_t)addr)
  804160834b:	48 a1 20 07 62 41 80 	movabs 0x8041620720,%rax
  8041608352:	00 00 00 
  8041608355:	4c 8d 04 06          	lea    (%rsi,%rax,1),%r8
  oldsize = ROUNDUP((uintptr_t)addr + oldsize, PGSIZE) - (uintptr_t)addr;
  8041608359:	48 8d 84 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%rax
  8041608360:	00 
  if (base - oldsize != (uintptr_t)addr)
  8041608361:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041608367:	49 29 c0             	sub    %rax,%r8
  804160836a:	4c 39 c6             	cmp    %r8,%rsi
  804160836d:	75 1e                	jne    804160838d <mmio_remap_last_region+0x46>
  base = (uintptr_t)addr;
  804160836f:	48 89 f0             	mov    %rsi,%rax
  8041608372:	48 a3 20 07 62 41 80 	movabs %rax,0x8041620720
  8041608379:	00 00 00 
  return mmio_map_region(pa, newsize);
  804160837c:	48 89 ce             	mov    %rcx,%rsi
  804160837f:	48 b8 91 82 60 41 80 	movabs $0x8041608291,%rax
  8041608386:	00 00 00 
  8041608389:	ff d0                	callq  *%rax
}
  804160838b:	5d                   	pop    %rbp
  804160838c:	c3                   	retq   
    panic("You dare to remap non-last region?!");
  804160838d:	48 ba 90 df 60 41 80 	movabs $0x804160df90,%rdx
  8041608394:	00 00 00 
  8041608397:	be 60 03 00 00       	mov    $0x360,%esi
  804160839c:	48 bf ef df 60 41 80 	movabs $0x804160dfef,%rdi
  80416083a3:	00 00 00 
  80416083a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416083ab:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416083b2:	00 00 00 
  80416083b5:	ff d1                	callq  *%rcx

00000080416083b7 <user_mem_check>:
user_mem_check(struct Env *env, const void *va, size_t len, int perm) {
  80416083b7:	55                   	push   %rbp
  80416083b8:	48 89 e5             	mov    %rsp,%rbp
  80416083bb:	41 57                	push   %r15
  80416083bd:	41 56                	push   %r14
  80416083bf:	41 55                	push   %r13
  80416083c1:	41 54                	push   %r12
  80416083c3:	53                   	push   %rbx
  80416083c4:	48 83 ec 18          	sub    $0x18,%rsp
  80416083c8:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  perm |= PTE_P;
  80416083cc:	83 c9 01             	or     $0x1,%ecx
  const void * end = va + len;
  80416083cf:	4c 8d 24 16          	lea    (%rsi,%rdx,1),%r12
  va = (void *)ROUNDDOWN(va, PGSIZE);
  80416083d3:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  while (va < end) {
  80416083da:	49 39 f4             	cmp    %rsi,%r12
  80416083dd:	76 44                	jbe    8041608423 <user_mem_check+0x6c>
  80416083df:	49 89 fe             	mov    %rdi,%r14
  80416083e2:	41 89 cd             	mov    %ecx,%r13d
  80416083e5:	48 89 f3             	mov    %rsi,%rbx
    pte_t * pte = pml4e_walk(env->env_pml4e, va, 0);
  80416083e8:	49 bf 21 4e 60 41 80 	movabs $0x8041604e21,%r15
  80416083ef:	00 00 00 
  80416083f2:	49 8b be e8 00 00 00 	mov    0xe8(%r14),%rdi
  80416083f9:	ba 00 00 00 00       	mov    $0x0,%edx
  80416083fe:	48 89 de             	mov    %rbx,%rsi
  8041608401:	41 ff d7             	callq  *%r15
    if (!pte || (*pte & perm) != perm) {
  8041608404:	48 85 c0             	test   %rax,%rax
  8041608407:	74 30                	je     8041608439 <user_mem_check+0x82>
  8041608409:	49 63 d5             	movslq %r13d,%rdx
  804160840c:	48 89 d1             	mov    %rdx,%rcx
  804160840f:	48 23 08             	and    (%rax),%rcx
  8041608412:	48 39 ca             	cmp    %rcx,%rdx
  8041608415:	75 22                	jne    8041608439 <user_mem_check+0x82>
    va += PGSIZE;
  8041608417:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  while (va < end) {
  804160841e:	49 39 dc             	cmp    %rbx,%r12
  8041608421:	77 cf                	ja     80416083f2 <user_mem_check+0x3b>
  if ((uintptr_t)end > ULIM) {
  8041608423:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  804160842a:	00 00 00 
  804160842d:	49 39 c4             	cmp    %rax,%r12
  8041608430:	77 30                	ja     8041608462 <user_mem_check+0xab>
  return 0;
  8041608432:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608437:	eb 1a                	jmp    8041608453 <user_mem_check+0x9c>
      user_mem_check_addr = (uintptr_t)MAX(va, va2);
  8041608439:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160843d:	48 39 d8             	cmp    %rbx,%rax
  8041608440:	48 0f 42 c3          	cmovb  %rbx,%rax
  8041608444:	48 a3 00 45 88 41 80 	movabs %rax,0x8041884500
  804160844b:	00 00 00 
      return -E_FAULT;
  804160844e:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
}
  8041608453:	48 83 c4 18          	add    $0x18,%rsp
  8041608457:	5b                   	pop    %rbx
  8041608458:	41 5c                	pop    %r12
  804160845a:	41 5d                	pop    %r13
  804160845c:	41 5e                	pop    %r14
  804160845e:	41 5f                	pop    %r15
  8041608460:	5d                   	pop    %rbp
  8041608461:	c3                   	retq   
    user_mem_check_addr = MAX(ULIM, (uintptr_t)va2);
  8041608462:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041608466:	48 39 c6             	cmp    %rax,%rsi
  8041608469:	48 0f 43 c6          	cmovae %rsi,%rax
  804160846d:	48 a3 00 45 88 41 80 	movabs %rax,0x8041884500
  8041608474:	00 00 00 
    return -E_FAULT;
  8041608477:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
  804160847c:	eb d5                	jmp    8041608453 <user_mem_check+0x9c>

000000804160847e <user_mem_assert>:
user_mem_assert(struct Env *env, const void *va, size_t len, int perm) {
  804160847e:	55                   	push   %rbp
  804160847f:	48 89 e5             	mov    %rsp,%rbp
  8041608482:	53                   	push   %rbx
  8041608483:	48 83 ec 08          	sub    $0x8,%rsp
  8041608487:	48 89 fb             	mov    %rdi,%rbx
  if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
  804160848a:	83 c9 04             	or     $0x4,%ecx
  804160848d:	48 b8 b7 83 60 41 80 	movabs $0x80416083b7,%rax
  8041608494:	00 00 00 
  8041608497:	ff d0                	callq  *%rax
  8041608499:	85 c0                	test   %eax,%eax
  804160849b:	78 07                	js     80416084a4 <user_mem_assert+0x26>
}
  804160849d:	48 83 c4 08          	add    $0x8,%rsp
  80416084a1:	5b                   	pop    %rbx
  80416084a2:	5d                   	pop    %rbp
  80416084a3:	c3                   	retq   
    cprintf("[%08x] user_mem_check assertion failure for va %016lx\n",
  80416084a4:	8b b3 c8 00 00 00    	mov    0xc8(%rbx),%esi
  80416084aa:	48 b8 00 45 88 41 80 	movabs $0x8041884500,%rax
  80416084b1:	00 00 00 
  80416084b4:	48 8b 10             	mov    (%rax),%rdx
  80416084b7:	48 bf b8 df 60 41 80 	movabs $0x804160dfb8,%rdi
  80416084be:	00 00 00 
  80416084c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416084c6:	48 b9 f2 91 60 41 80 	movabs $0x80416091f2,%rcx
  80416084cd:	00 00 00 
  80416084d0:	ff d1                	callq  *%rcx
    env_destroy(env); // may not return
  80416084d2:	48 89 df             	mov    %rbx,%rdi
  80416084d5:	48 b8 b7 8d 60 41 80 	movabs $0x8041608db7,%rax
  80416084dc:	00 00 00 
  80416084df:	ff d0                	callq  *%rax
}
  80416084e1:	eb ba                	jmp    804160849d <user_mem_assert+0x1f>

00000080416084e3 <region_alloc>:
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len) {
  80416084e3:	55                   	push   %rbp
  80416084e4:	48 89 e5             	mov    %rsp,%rbp
  80416084e7:	41 57                	push   %r15
  80416084e9:	41 56                	push   %r14
  80416084eb:	41 55                	push   %r13
  80416084ed:	41 54                	push   %r12
  80416084ef:	53                   	push   %rbx
  80416084f0:	48 83 ec 08          	sub    $0x8,%rsp
  //   'va' and 'len' values that are not page-aligned.
  //   You should round va down, and round (va + len) up.
  //   (Watch out for corner-cases!)

  // LAB 8 code
  void *end = ROUNDUP(va + len, PGSIZE);
  80416084f4:	4c 8d a4 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%r12
  80416084fb:	00 
  80416084fc:	49 81 e4 00 f0 ff ff 	and    $0xfffffffffffff000,%r12
  va = ROUNDDOWN(va, PGSIZE);
  8041608503:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
	struct PageInfo *pi;

	while (va < end) {
  804160850a:	49 39 f4             	cmp    %rsi,%r12
  804160850d:	76 43                	jbe    8041608552 <region_alloc+0x6f>
  804160850f:	48 89 f3             	mov    %rsi,%rbx
  8041608512:	49 89 fd             	mov    %rdi,%r13
    pi = page_alloc(ALLOC_ZERO);
  8041608515:	49 bf fe 49 60 41 80 	movabs $0x80416049fe,%r15
  804160851c:	00 00 00 
    page_insert(e->env_pml4e, pi, va, PTE_U | PTE_W);
  804160851f:	49 be 0b 51 60 41 80 	movabs $0x804160510b,%r14
  8041608526:	00 00 00 
    pi = page_alloc(ALLOC_ZERO);
  8041608529:	bf 01 00 00 00       	mov    $0x1,%edi
  804160852e:	41 ff d7             	callq  *%r15
    page_insert(e->env_pml4e, pi, va, PTE_U | PTE_W);
  8041608531:	49 8b bd e8 00 00 00 	mov    0xe8(%r13),%rdi
  8041608538:	b9 06 00 00 00       	mov    $0x6,%ecx
  804160853d:	48 89 da             	mov    %rbx,%rdx
  8041608540:	48 89 c6             	mov    %rax,%rsi
  8041608543:	41 ff d6             	callq  *%r14
    va += PGSIZE;
  8041608546:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
	while (va < end) {
  804160854d:	49 39 dc             	cmp    %rbx,%r12
  8041608550:	77 d7                	ja     8041608529 <region_alloc+0x46>
  }
  // LAB 8 code end
}
  8041608552:	48 83 c4 08          	add    $0x8,%rsp
  8041608556:	5b                   	pop    %rbx
  8041608557:	41 5c                	pop    %r12
  8041608559:	41 5d                	pop    %r13
  804160855b:	41 5e                	pop    %r14
  804160855d:	41 5f                	pop    %r15
  804160855f:	5d                   	pop    %rbp
  8041608560:	c3                   	retq   

0000008041608561 <envid2env>:
  if (envid == 0) {
  8041608561:	85 ff                	test   %edi,%edi
  8041608563:	74 57                	je     80416085bc <envid2env+0x5b>
  e = &envs[ENVX(envid)];
  8041608565:	89 f8                	mov    %edi,%eax
  8041608567:	25 ff 03 00 00       	and    $0x3ff,%eax
  804160856c:	48 8d 0c c0          	lea    (%rax,%rax,8),%rcx
  8041608570:	48 c1 e1 05          	shl    $0x5,%rcx
  8041608574:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  804160857b:	00 00 00 
  804160857e:	48 01 c1             	add    %rax,%rcx
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  8041608581:	83 b9 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rcx)
  8041608588:	74 42                	je     80416085cc <envid2env+0x6b>
  804160858a:	39 b9 c8 00 00 00    	cmp    %edi,0xc8(%rcx)
  8041608590:	75 3a                	jne    80416085cc <envid2env+0x6b>
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  8041608592:	84 d2                	test   %dl,%dl
  8041608594:	74 1d                	je     80416085b3 <envid2env+0x52>
  8041608596:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160859d:	00 00 00 
  80416085a0:	48 39 c8             	cmp    %rcx,%rax
  80416085a3:	74 0e                	je     80416085b3 <envid2env+0x52>
  80416085a5:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  80416085ab:	39 81 cc 00 00 00    	cmp    %eax,0xcc(%rcx)
  80416085b1:	75 26                	jne    80416085d9 <envid2env+0x78>
  *env_store = e;
  80416085b3:	48 89 0e             	mov    %rcx,(%rsi)
  return 0;
  80416085b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416085bb:	c3                   	retq   
    *env_store = curenv;
  80416085bc:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  80416085c3:	00 00 00 
  80416085c6:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  80416085c9:	89 f8                	mov    %edi,%eax
  80416085cb:	c3                   	retq   
    *env_store = 0;
  80416085cc:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416085d3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  80416085d8:	c3                   	retq   
    *env_store = 0;
  80416085d9:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416085e0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  80416085e5:	c3                   	retq   

00000080416085e6 <env_init_percpu>:
env_init_percpu(void) {
  80416085e6:	55                   	push   %rbp
  80416085e7:	48 89 e5             	mov    %rsp,%rbp
  80416085ea:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  80416085eb:	48 b8 40 07 62 41 80 	movabs $0x8041620740,%rax
  80416085f2:	00 00 00 
  80416085f5:	0f 01 10             	lgdt   (%rax)
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  80416085f8:	b8 33 00 00 00       	mov    $0x33,%eax
  80416085fd:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  80416085ff:	8e e0                	mov    %eax,%fs
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  8041608601:	b8 10 00 00 00       	mov    $0x10,%eax
  8041608606:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041608608:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  804160860a:	8e d0                	mov    %eax,%ss
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  804160860c:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041608611:	53                   	push   %rbx
  8041608612:	48 b8 1f 86 60 41 80 	movabs $0x804160861f,%rax
  8041608619:	00 00 00 
  804160861c:	50                   	push   %rax
  804160861d:	48 cb                	lretq  
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  804160861f:	66 b8 00 00          	mov    $0x0,%ax
  8041608623:	0f 00 d0             	lldt   %ax
}
  8041608626:	5b                   	pop    %rbx
  8041608627:	5d                   	pop    %rbp
  8041608628:	c3                   	retq   

0000008041608629 <env_init>:
env_init(void) {
  8041608629:	55                   	push   %rbp
  804160862a:	48 89 e5             	mov    %rsp,%rbp
    envs[i].env_status = ENV_FREE;
  804160862d:	48 b8 28 45 88 41 80 	movabs $0x8041884528,%rax
  8041608634:	00 00 00 
  8041608637:	48 8b 38             	mov    (%rax),%rdi
  804160863a:	48 8d 87 e0 7e 04 00 	lea    0x47ee0(%rdi),%rax
  8041608641:	48 89 fe             	mov    %rdi,%rsi
  8041608644:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608649:	eb 03                	jmp    804160864e <env_init+0x25>
  804160864b:	48 89 c8             	mov    %rcx,%rax
  804160864e:	c7 80 d4 00 00 00 00 	movl   $0x0,0xd4(%rax)
  8041608655:	00 00 00 
    envs[i].env_link = env_free_list;
  8041608658:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    envs[i].env_id   = 0;
  804160865f:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%rax)
  8041608666:	00 00 00 
  for (int i = NENV - 1; i >= 0; i--) {
  8041608669:	48 8d 88 e0 fe ff ff 	lea    -0x120(%rax),%rcx
    env_free_list    = &envs[i];
  8041608670:	48 89 c2             	mov    %rax,%rdx
  for (int i = NENV - 1; i >= 0; i--) {
  8041608673:	48 39 f0             	cmp    %rsi,%rax
  8041608676:	75 d3                	jne    804160864b <env_init+0x22>
  8041608678:	48 89 f8             	mov    %rdi,%rax
  804160867b:	48 a3 30 45 88 41 80 	movabs %rax,0x8041884530
  8041608682:	00 00 00 
  env_init_percpu();
  8041608685:	48 b8 e6 85 60 41 80 	movabs $0x80416085e6,%rax
  804160868c:	00 00 00 
  804160868f:	ff d0                	callq  *%rax
}
  8041608691:	5d                   	pop    %rbp
  8041608692:	c3                   	retq   

0000008041608693 <env_alloc>:
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  8041608693:	55                   	push   %rbp
  8041608694:	48 89 e5             	mov    %rsp,%rbp
  8041608697:	41 55                	push   %r13
  8041608699:	41 54                	push   %r12
  804160869b:	53                   	push   %rbx
  804160869c:	48 83 ec 08          	sub    $0x8,%rsp
  if (!(e = env_free_list)) {
  80416086a0:	48 b8 30 45 88 41 80 	movabs $0x8041884530,%rax
  80416086a7:	00 00 00 
  80416086aa:	48 8b 18             	mov    (%rax),%rbx
  80416086ad:	48 85 db             	test   %rbx,%rbx
  80416086b0:	0f 84 56 02 00 00    	je     804160890c <env_alloc+0x279>
  80416086b6:	41 89 f5             	mov    %esi,%r13d
  80416086b9:	49 89 fc             	mov    %rdi,%r12
  if (!(p = page_alloc(ALLOC_ZERO)))
  80416086bc:	bf 01 00 00 00       	mov    $0x1,%edi
  80416086c1:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  80416086c8:	00 00 00 
  80416086cb:	ff d0                	callq  *%rax
  80416086cd:	48 85 c0             	test   %rax,%rax
  80416086d0:	0f 84 40 02 00 00    	je     8041608916 <env_alloc+0x283>
  return (pp - pages) << PGSHIFT;
  80416086d6:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  80416086dd:	00 00 00 
  80416086e0:	48 8b 09             	mov    (%rcx),%rcx
  80416086e3:	48 29 c8             	sub    %rcx,%rax
  80416086e6:	48 c1 f8 04          	sar    $0x4,%rax
  80416086ea:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  80416086ee:	48 bf 50 5a 88 41 80 	movabs $0x8041885a50,%rdi
  80416086f5:	00 00 00 
  80416086f8:	48 8b 3f             	mov    (%rdi),%rdi
  80416086fb:	48 89 c2             	mov    %rax,%rdx
  80416086fe:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041608702:	48 39 fa             	cmp    %rdi,%rdx
  8041608705:	0f 83 8e 01 00 00    	jae    8041608899 <env_alloc+0x206>
  return (void *)(pa + KERNBASE);
  804160870b:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041608712:	00 00 00 
  8041608715:	48 01 c2             	add    %rax,%rdx
	e->env_pml4e = page2kva(p);
  8041608718:	48 89 93 e8 00 00 00 	mov    %rdx,0xe8(%rbx)
  e->env_cr3 = page2pa(p);
  804160871f:	48 89 83 f0 00 00 00 	mov    %rax,0xf0(%rbx)
  e->env_pml4e[1] = kern_pml4e[1];
  8041608726:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  804160872d:	00 00 00 
  8041608730:	48 8b 70 08          	mov    0x8(%rax),%rsi
  8041608734:	48 89 72 08          	mov    %rsi,0x8(%rdx)
  pa2page(PTE_ADDR(kern_pml4e[1]))->pp_ref++;
  8041608738:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PPN(pa) >= npages) {
  804160873f:	48 89 f0             	mov    %rsi,%rax
  8041608742:	48 c1 e8 0c          	shr    $0xc,%rax
  8041608746:	48 39 f8             	cmp    %rdi,%rax
  8041608749:	0f 83 78 01 00 00    	jae    80416088c7 <env_alloc+0x234>
  return &pages[PPN(pa)];
  804160874f:	48 c1 e0 04          	shl    $0x4,%rax
  8041608753:	66 83 44 01 08 01    	addw   $0x1,0x8(%rcx,%rax,1)
  e->env_pml4e[2] = e->env_cr3 | PTE_P | PTE_U;
  8041608759:	48 8b 93 e8 00 00 00 	mov    0xe8(%rbx),%rdx
  8041608760:	48 8b 83 f0 00 00 00 	mov    0xf0(%rbx),%rax
  8041608767:	48 83 c8 05          	or     $0x5,%rax
  804160876b:	48 89 42 10          	mov    %rax,0x10(%rdx)
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  804160876f:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  8041608775:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  804160877a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
    generation = 1 << ENVGENSHIFT;
  804160877f:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041608784:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  8041608787:	48 ba 28 45 88 41 80 	movabs $0x8041884528,%rdx
  804160878e:	00 00 00 
  8041608791:	48 89 d9             	mov    %rbx,%rcx
  8041608794:	48 2b 0a             	sub    (%rdx),%rcx
  8041608797:	48 89 ca             	mov    %rcx,%rdx
  804160879a:	48 c1 fa 05          	sar    $0x5,%rdx
  804160879e:	69 d2 39 8e e3 38    	imul   $0x38e38e39,%edx,%edx
  80416087a4:	09 d0                	or     %edx,%eax
  80416087a6:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)
  e->env_parent_id = parent_id;
  80416087ac:	44 89 ab cc 00 00 00 	mov    %r13d,0xcc(%rbx)
  e->env_type      = ENV_TYPE_USER;
  80416087b3:	c7 83 d0 00 00 00 02 	movl   $0x2,0xd0(%rbx)
  80416087ba:	00 00 00 
  e->env_status = ENV_RUNNABLE;
  80416087bd:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  80416087c4:	00 00 00 
  e->env_runs   = 0;
  80416087c7:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  80416087ce:	00 00 00 
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  80416087d1:	ba c0 00 00 00       	mov    $0xc0,%edx
  80416087d6:	be 00 00 00 00       	mov    $0x0,%esi
  80416087db:	48 89 df             	mov    %rbx,%rdi
  80416087de:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  80416087e5:	00 00 00 
  80416087e8:	ff d0                	callq  *%rax
  e->env_tf.tf_ds  = GD_UD | 3;
  80416087ea:	66 c7 83 80 00 00 00 	movw   $0x33,0x80(%rbx)
  80416087f1:	33 00 
  e->env_tf.tf_es  = GD_UD | 3;
  80416087f3:	66 c7 43 78 33 00    	movw   $0x33,0x78(%rbx)
  e->env_tf.tf_ss  = GD_UD | 3;
  80416087f9:	66 c7 83 b8 00 00 00 	movw   $0x33,0xb8(%rbx)
  8041608800:	33 00 
  e->env_tf.tf_rsp = USTACKTOP;
  8041608802:	48 b8 00 b0 ff ff 7f 	movabs $0x7fffffb000,%rax
  8041608809:	00 00 00 
  804160880c:	48 89 83 b0 00 00 00 	mov    %rax,0xb0(%rbx)
  e->env_tf.tf_cs  = GD_UT | 3;
  8041608813:	66 c7 83 a0 00 00 00 	movw   $0x2b,0xa0(%rbx)
  804160881a:	2b 00 
  e->env_tf.tf_rflags |= FL_IF;
  804160881c:	48 81 8b a8 00 00 00 	orq    $0x200,0xa8(%rbx)
  8041608823:	00 02 00 00 
  e->env_pgfault_upcall = 0;
  8041608827:	48 c7 83 f8 00 00 00 	movq   $0x0,0xf8(%rbx)
  804160882e:	00 00 00 00 
  e->env_ipc_recving = 0;
  8041608832:	c6 83 00 01 00 00 00 	movb   $0x0,0x100(%rbx)
  env_free_list = e->env_link;
  8041608839:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  8041608840:	48 a3 30 45 88 41 80 	movabs %rax,0x8041884530
  8041608847:	00 00 00 
  *newenv_store = e;
  804160884a:	49 89 1c 24          	mov    %rbx,(%r12)
  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  804160884e:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  8041608854:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160885b:	00 00 00 
  804160885e:	be 00 00 00 00       	mov    $0x0,%esi
  8041608863:	48 85 c0             	test   %rax,%rax
  8041608866:	74 06                	je     804160886e <env_alloc+0x1db>
  8041608868:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160886e:	48 bf 47 e3 60 41 80 	movabs $0x804160e347,%rdi
  8041608875:	00 00 00 
  8041608878:	b8 00 00 00 00       	mov    $0x0,%eax
  804160887d:	48 b9 f2 91 60 41 80 	movabs $0x80416091f2,%rcx
  8041608884:	00 00 00 
  8041608887:	ff d1                	callq  *%rcx
  return 0;
  8041608889:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160888e:	48 83 c4 08          	add    $0x8,%rsp
  8041608892:	5b                   	pop    %rbx
  8041608893:	41 5c                	pop    %r12
  8041608895:	41 5d                	pop    %r13
  8041608897:	5d                   	pop    %rbp
  8041608898:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041608899:	48 89 c1             	mov    %rax,%rcx
  804160889c:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  80416088a3:	00 00 00 
  80416088a6:	be 61 00 00 00       	mov    $0x61,%esi
  80416088ab:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  80416088b2:	00 00 00 
  80416088b5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416088ba:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416088c1:	00 00 00 
  80416088c4:	41 ff d0             	callq  *%r8
    cprintf("accessing %lx\n", (unsigned long)pa);
  80416088c7:	48 bf 9a e0 60 41 80 	movabs $0x804160e09a,%rdi
  80416088ce:	00 00 00 
  80416088d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416088d6:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416088dd:	00 00 00 
  80416088e0:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  80416088e2:	48 ba d8 d7 60 41 80 	movabs $0x804160d7d8,%rdx
  80416088e9:	00 00 00 
  80416088ec:	be 5a 00 00 00       	mov    $0x5a,%esi
  80416088f1:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  80416088f8:	00 00 00 
  80416088fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608900:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608907:	00 00 00 
  804160890a:	ff d1                	callq  *%rcx
    return -E_NO_FREE_ENV;
  804160890c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  8041608911:	e9 78 ff ff ff       	jmpq   804160888e <env_alloc+0x1fb>
    return -E_NO_MEM;
  8041608916:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  804160891b:	e9 6e ff ff ff       	jmpq   804160888e <env_alloc+0x1fb>

0000008041608920 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  8041608920:	55                   	push   %rbp
  8041608921:	48 89 e5             	mov    %rsp,%rbp
  8041608924:	41 57                	push   %r15
  8041608926:	41 56                	push   %r14
  8041608928:	41 55                	push   %r13
  804160892a:	41 54                	push   %r12
  804160892c:	53                   	push   %rbx
  804160892d:	48 83 ec 38          	sub    $0x38,%rsp
  8041608931:	49 89 fd             	mov    %rdi,%r13
  8041608934:	89 f3                	mov    %esi,%ebx
    
  // LAB 3 code
  struct Env *newenv;
  if (env_alloc(&newenv, 0) < 0) {
  8041608936:	be 00 00 00 00       	mov    $0x0,%esi
  804160893b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160893f:	48 b8 93 86 60 41 80 	movabs $0x8041608693,%rax
  8041608946:	00 00 00 
  8041608949:	ff d0                	callq  *%rax
  804160894b:	85 c0                	test   %eax,%eax
  804160894d:	78 3f                	js     804160898e <env_create+0x6e>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  }
      
  newenv->env_type = type;
  804160894f:	4c 8b 7d c8          	mov    -0x38(%rbp),%r15
  8041608953:	41 89 9f d0 00 00 00 	mov    %ebx,0xd0(%r15)
  if (elf->e_magic != ELF_MAGIC) {
  804160895a:	41 81 7d 00 7f 45 4c 	cmpl   $0x464c457f,0x0(%r13)
  8041608961:	46 
  8041608962:	75 54                	jne    80416089b8 <env_create+0x98>
  struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff); // Proghdr = prog header. Он лежит со смещением elf->e_phoff относительно начала фаила
  8041608964:	49 8b 5d 20          	mov    0x20(%r13),%rbx
  __asm __volatile("movq %0,%%cr3"
  8041608968:	49 8b 87 f0 00 00 00 	mov    0xf0(%r15),%rax
  804160896f:	0f 22 d8             	mov    %rax,%cr3
  for (size_t i = 0; i < elf->e_phnum; i++) { // elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041608972:	66 41 83 7d 38 00    	cmpw   $0x0,0x38(%r13)
  8041608978:	0f 84 e9 00 00 00    	je     8041608a67 <env_create+0x147>
  804160897e:	4c 01 eb             	add    %r13,%rbx
  8041608981:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8041608988:	00 
  8041608989:	e9 cf 00 00 00       	jmpq   8041608a5d <env_create+0x13d>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  804160898e:	48 ba 28 e3 60 41 80 	movabs $0x804160e328,%rdx
  8041608995:	00 00 00 
  8041608998:	be 17 02 00 00       	mov    $0x217,%esi
  804160899d:	48 bf 5c e3 60 41 80 	movabs $0x804160e35c,%rdi
  80416089a4:	00 00 00 
  80416089a7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416089ac:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416089b3:	00 00 00 
  80416089b6:	ff d1                	callq  *%rcx
    cprintf("Unexpected ELF format\n");
  80416089b8:	48 bf 67 e3 60 41 80 	movabs $0x804160e367,%rdi
  80416089bf:	00 00 00 
  80416089c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416089c7:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416089ce:	00 00 00 
  80416089d1:	ff d2                	callq  *%rdx
    return;
  80416089d3:	e9 c5 00 00 00       	jmpq   8041608a9d <env_create+0x17d>
      void *src = (void *)(binary + ph[i].p_offset);
  80416089d8:	4c 89 e8             	mov    %r13,%rax
  80416089db:	48 03 43 08          	add    0x8(%rbx),%rax
  80416089df:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
      void *dst = (void *)ph[i].p_va;
  80416089e3:	4c 8b 73 10          	mov    0x10(%rbx),%r14
      size_t memsz  = ph[i].p_memsz;
  80416089e7:	4c 8b 63 28          	mov    0x28(%rbx),%r12
      size_t filesz = MIN(ph[i].p_filesz, memsz);
  80416089eb:	4c 39 63 20          	cmp    %r12,0x20(%rbx)
  80416089ef:	4c 89 e0             	mov    %r12,%rax
  80416089f2:	48 0f 46 43 20       	cmovbe 0x20(%rbx),%rax
  80416089f7:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
      region_alloc(e, (void *)dst, memsz);
  80416089fb:	4c 89 e2             	mov    %r12,%rdx
  80416089fe:	4c 89 f6             	mov    %r14,%rsi
  8041608a01:	4c 89 ff             	mov    %r15,%rdi
  8041608a04:	48 b9 e3 84 60 41 80 	movabs $0x80416084e3,%rcx
  8041608a0b:	00 00 00 
  8041608a0e:	ff d1                	callq  *%rcx
      memcpy(dst, src, filesz);
  8041608a10:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041608a14:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041608a18:	4c 89 f7             	mov    %r14,%rdi
  8041608a1b:	48 b9 4a c5 60 41 80 	movabs $0x804160c54a,%rcx
  8041608a22:	00 00 00 
  8041608a25:	ff d1                	callq  *%rcx
      memset(dst + filesz, 0, memsz - filesz); // обнуление памяти по адресу dst + filesz, где количество нулей = memsz - filesz. Т.е. зануляем всю выделенную память сегмента кода, оставшуюяся после копирования src. Возможно, эта строка не нужна
  8041608a27:	4c 89 e2             	mov    %r12,%rdx
  8041608a2a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041608a2e:	48 29 c2             	sub    %rax,%rdx
  8041608a31:	49 8d 3c 06          	lea    (%r14,%rax,1),%rdi
  8041608a35:	be 00 00 00 00       	mov    $0x0,%esi
  8041608a3a:	48 b8 99 c4 60 41 80 	movabs $0x804160c499,%rax
  8041608a41:	00 00 00 
  8041608a44:	ff d0                	callq  *%rax
  for (size_t i = 0; i < elf->e_phnum; i++) { // elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041608a46:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  8041608a4b:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041608a4f:	48 83 c3 38          	add    $0x38,%rbx
  8041608a53:	41 0f b7 45 38       	movzwl 0x38(%r13),%eax
  8041608a58:	48 39 c1             	cmp    %rax,%rcx
  8041608a5b:	73 0a                	jae    8041608a67 <env_create+0x147>
    if (ph[i].p_type == ELF_PROG_LOAD) {
  8041608a5d:	83 3b 01             	cmpl   $0x1,(%rbx)
  8041608a60:	75 e4                	jne    8041608a46 <env_create+0x126>
  8041608a62:	e9 71 ff ff ff       	jmpq   80416089d8 <env_create+0xb8>
  8041608a67:	48 a1 48 5a 88 41 80 	movabs 0x8041885a48,%rax
  8041608a6e:	00 00 00 
  8041608a71:	0f 22 d8             	mov    %rax,%cr3
  e->env_tf.tf_rip = elf->e_entry; //Виртуальный адрес точки входа, которому система передает управление при запуске процесса. в регистр rip записываем адрес точки входа для выполнения процесса
  8041608a74:	49 8b 45 18          	mov    0x18(%r13),%rax
  8041608a78:	49 89 87 98 00 00 00 	mov    %rax,0x98(%r15)
  region_alloc(e, (void *) (USTACKTOP - USTACKSIZE), USTACKSIZE);
  8041608a7f:	ba 00 40 00 00       	mov    $0x4000,%edx
  8041608a84:	48 be 00 70 ff ff 7f 	movabs $0x7fffff7000,%rsi
  8041608a8b:	00 00 00 
  8041608a8e:	4c 89 ff             	mov    %r15,%rdi
  8041608a91:	48 b8 e3 84 60 41 80 	movabs $0x80416084e3,%rax
  8041608a98:	00 00 00 
  8041608a9b:	ff d0                	callq  *%rax

  load_icode(newenv, binary); // load instruction code
  // LAB 3 code end
    
}
  8041608a9d:	48 83 c4 38          	add    $0x38,%rsp
  8041608aa1:	5b                   	pop    %rbx
  8041608aa2:	41 5c                	pop    %r12
  8041608aa4:	41 5d                	pop    %r13
  8041608aa6:	41 5e                	pop    %r14
  8041608aa8:	41 5f                	pop    %r15
  8041608aaa:	5d                   	pop    %rbp
  8041608aab:	c3                   	retq   

0000008041608aac <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041608aac:	55                   	push   %rbp
  8041608aad:	48 89 e5             	mov    %rsp,%rbp
  8041608ab0:	53                   	push   %rbx
  8041608ab1:	48 83 ec 08          	sub    $0x8,%rsp
  8041608ab5:	48 89 fb             	mov    %rdi,%rbx
  physaddr_t pa;

  // If freeing the current environment, switch to kern_pgdir
  // before freeing the page directory, just in case the page
  // gets reused.
  if (e == curenv)
  8041608ab8:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041608abf:	00 00 00 
  8041608ac2:	48 39 f8             	cmp    %rdi,%rax
  8041608ac5:	0f 84 96 01 00 00    	je     8041608c61 <env_free+0x1b5>
    lcr3(kern_cr3);
#endif

  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608acb:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608ad1:	be 00 00 00 00       	mov    $0x0,%esi
  8041608ad6:	48 85 c0             	test   %rax,%rax
  8041608ad9:	74 06                	je     8041608ae1 <env_free+0x35>
  8041608adb:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041608ae1:	48 bf 7e e3 60 41 80 	movabs $0x804160e37e,%rdi
  8041608ae8:	00 00 00 
  8041608aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608af0:	48 b9 f2 91 60 41 80 	movabs $0x80416091f2,%rcx
  8041608af7:	00 00 00 
  8041608afa:	ff d1                	callq  *%rcx
#ifndef CONFIG_KSPACE
  // Flush all mapped pages in the user portion of the address space
  static_assert(UTOP % PTSIZE == 0, "Misaligned UTOP");

  //UTOP < PDPE[1] start, so all mapped memory should be in first PDPE
  pdpe = KADDR(PTE_ADDR(e->env_pml4e[0]));
  8041608afc:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608b03:	48 8b 08             	mov    (%rax),%rcx
  8041608b06:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041608b0d:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041608b14:	00 00 00 
  8041608b17:	48 89 ca             	mov    %rcx,%rdx
  8041608b1a:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041608b1e:	48 39 d0             	cmp    %rdx,%rax
  8041608b21:	0f 86 55 01 00 00    	jbe    8041608c7c <env_free+0x1d0>
  return (void *)(pa + KERNBASE);
  8041608b27:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041608b2e:	00 00 00 
  8041608b31:	48 01 d1             	add    %rdx,%rcx
  for (pdpeno = 0; pdpeno <= PDPE(UTOP); pdpeno++) {
    // only look at mapped page directory pointer index
    if (!(pdpe[pdpeno] & PTE_P))
  8041608b34:	48 8b 31             	mov    (%rcx),%rsi
  8041608b37:	40 f6 c6 01          	test   $0x1,%sil
  8041608b3b:	0f 84 63 02 00 00    	je     8041608da4 <env_free+0x2f8>
      continue;

    pgdir       = KADDR(PTE_ADDR(pdpe[pdpeno]));
  8041608b41:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PGNUM(pa) >= npages)
  8041608b48:	48 89 f7             	mov    %rsi,%rdi
  8041608b4b:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608b4f:	48 39 f8             	cmp    %rdi,%rax
  8041608b52:	0f 86 4f 01 00 00    	jbe    8041608ca7 <env_free+0x1fb>
      page_decref(pa2page(pa));
    }

    // free the page directory
    pa           = PTE_ADDR(pdpe[pdpeno]);
    pdpe[pdpeno] = 0;
  8041608b58:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  if (PPN(pa) >= npages) {
  8041608b5f:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041608b66:	00 00 00 
  8041608b69:	48 3b 38             	cmp    (%rax),%rdi
  8041608b6c:	0f 83 63 01 00 00    	jae    8041608cd5 <env_free+0x229>
  return &pages[PPN(pa)];
  8041608b72:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608b76:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041608b7d:	00 00 00 
  8041608b80:	48 01 c7             	add    %rax,%rdi
    page_decref(pa2page(pa));
  8041608b83:	48 b8 65 4b 60 41 80 	movabs $0x8041604b65,%rax
  8041608b8a:	00 00 00 
  8041608b8d:	ff d0                	callq  *%rax
  }
  // free the page directory pointer
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  8041608b8f:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608b96:	48 8b 30             	mov    (%rax),%rsi
  8041608b99:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PPN(pa) >= npages) {
  8041608ba0:	48 89 f7             	mov    %rsi,%rdi
  8041608ba3:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608ba7:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041608bae:	00 00 00 
  8041608bb1:	48 3b 38             	cmp    (%rax),%rdi
  8041608bb4:	0f 83 60 01 00 00    	jae    8041608d1a <env_free+0x26e>
  return &pages[PPN(pa)];
  8041608bba:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608bbe:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041608bc5:	00 00 00 
  8041608bc8:	48 01 c7             	add    %rax,%rdi
  8041608bcb:	48 b8 65 4b 60 41 80 	movabs $0x8041604b65,%rax
  8041608bd2:	00 00 00 
  8041608bd5:	ff d0                	callq  *%rax
  // free the page map level 4 (PML4)
  e->env_pml4e[0] = 0;
  8041608bd7:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608bde:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  pa              = e->env_cr3;
  8041608be5:	48 8b b3 f0 00 00 00 	mov    0xf0(%rbx),%rsi
  e->env_pml4e    = 0;
  8041608bec:	48 c7 83 e8 00 00 00 	movq   $0x0,0xe8(%rbx)
  8041608bf3:	00 00 00 00 
  e->env_cr3      = 0;
  8041608bf7:	48 c7 83 f0 00 00 00 	movq   $0x0,0xf0(%rbx)
  8041608bfe:	00 00 00 00 
  if (PPN(pa) >= npages) {
  8041608c02:	48 89 f7             	mov    %rsi,%rdi
  8041608c05:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608c09:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041608c10:	00 00 00 
  8041608c13:	48 3b 38             	cmp    (%rax),%rdi
  8041608c16:	0f 83 43 01 00 00    	jae    8041608d5f <env_free+0x2b3>
  return &pages[PPN(pa)];
  8041608c1c:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608c20:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041608c27:	00 00 00 
  8041608c2a:	48 01 c7             	add    %rax,%rdi
  page_decref(pa2page(pa));
  8041608c2d:	48 b8 65 4b 60 41 80 	movabs $0x8041604b65,%rax
  8041608c34:	00 00 00 
  8041608c37:	ff d0                	callq  *%rax
#endif
  // return the environment to the free list
  e->env_status = ENV_FREE;
  8041608c39:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  8041608c40:	00 00 00 
  e->env_link   = env_free_list;
  8041608c43:	48 b8 30 45 88 41 80 	movabs $0x8041884530,%rax
  8041608c4a:	00 00 00 
  8041608c4d:	48 8b 10             	mov    (%rax),%rdx
  8041608c50:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  8041608c57:	48 89 18             	mov    %rbx,(%rax)
}
  8041608c5a:	48 83 c4 08          	add    $0x8,%rsp
  8041608c5e:	5b                   	pop    %rbx
  8041608c5f:	5d                   	pop    %rbp
  8041608c60:	c3                   	retq   
  8041608c61:	48 b9 48 5a 88 41 80 	movabs $0x8041885a48,%rcx
  8041608c68:	00 00 00 
  8041608c6b:	48 8b 11             	mov    (%rcx),%rdx
  8041608c6e:	0f 22 da             	mov    %rdx,%cr3
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608c71:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608c77:	e9 5f fe ff ff       	jmpq   8041608adb <env_free+0x2f>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041608c7c:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041608c83:	00 00 00 
  8041608c86:	be 3d 02 00 00       	mov    $0x23d,%esi
  8041608c8b:	48 bf 5c e3 60 41 80 	movabs $0x804160e35c,%rdi
  8041608c92:	00 00 00 
  8041608c95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c9a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608ca1:	00 00 00 
  8041608ca4:	41 ff d0             	callq  *%r8
  8041608ca7:	48 89 f1             	mov    %rsi,%rcx
  8041608caa:	48 ba a0 d6 60 41 80 	movabs $0x804160d6a0,%rdx
  8041608cb1:	00 00 00 
  8041608cb4:	be 43 02 00 00       	mov    $0x243,%esi
  8041608cb9:	48 bf 5c e3 60 41 80 	movabs $0x804160e35c,%rdi
  8041608cc0:	00 00 00 
  8041608cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608cc8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608ccf:	00 00 00 
  8041608cd2:	41 ff d0             	callq  *%r8
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608cd5:	48 bf 9a e0 60 41 80 	movabs $0x804160e09a,%rdi
  8041608cdc:	00 00 00 
  8041608cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ce4:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041608ceb:	00 00 00 
  8041608cee:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608cf0:	48 ba d8 d7 60 41 80 	movabs $0x804160d7d8,%rdx
  8041608cf7:	00 00 00 
  8041608cfa:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608cff:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041608d06:	00 00 00 
  8041608d09:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d0e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608d15:	00 00 00 
  8041608d18:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608d1a:	48 bf 9a e0 60 41 80 	movabs $0x804160e09a,%rdi
  8041608d21:	00 00 00 
  8041608d24:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d29:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041608d30:	00 00 00 
  8041608d33:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608d35:	48 ba d8 d7 60 41 80 	movabs $0x804160d7d8,%rdx
  8041608d3c:	00 00 00 
  8041608d3f:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608d44:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041608d4b:	00 00 00 
  8041608d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d53:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608d5a:	00 00 00 
  8041608d5d:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608d5f:	48 bf 9a e0 60 41 80 	movabs $0x804160e09a,%rdi
  8041608d66:	00 00 00 
  8041608d69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d6e:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041608d75:	00 00 00 
  8041608d78:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608d7a:	48 ba d8 d7 60 41 80 	movabs $0x804160d7d8,%rdx
  8041608d81:	00 00 00 
  8041608d84:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608d89:	48 bf 7b e0 60 41 80 	movabs $0x804160e07b,%rdi
  8041608d90:	00 00 00 
  8041608d93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d98:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608d9f:	00 00 00 
  8041608da2:	ff d1                	callq  *%rcx
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  8041608da4:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608dab:	48 8b 38             	mov    (%rax),%rdi
  8041608dae:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608db2:	e9 03 fe ff ff       	jmpq   8041608bba <env_free+0x10e>

0000008041608db7 <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) {
  8041608db7:	55                   	push   %rbp
  8041608db8:	48 89 e5             	mov    %rsp,%rbp
  8041608dbb:	53                   	push   %rbx
  8041608dbc:	48 83 ec 08          	sub    $0x8,%rsp
  8041608dc0:	48 89 fb             	mov    %rdi,%rbx
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
    
  // LAB 3 code
  e->env_status = ENV_DYING;
  8041608dc3:	c7 87 d4 00 00 00 01 	movl   $0x1,0xd4(%rdi)
  8041608dca:	00 00 00 
  env_free(e);
  8041608dcd:	48 b8 ac 8a 60 41 80 	movabs $0x8041608aac,%rax
  8041608dd4:	00 00 00 
  8041608dd7:	ff d0                	callq  *%rax
  if (e == curenv) {
  8041608dd9:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041608de0:	00 00 00 
  8041608de3:	48 39 18             	cmp    %rbx,(%rax)
  8041608de6:	74 07                	je     8041608def <env_destroy+0x38>
    sched_yield();
  }
  // LAB 3 code end
}
  8041608de8:	48 83 c4 08          	add    $0x8,%rsp
  8041608dec:	5b                   	pop    %rbx
  8041608ded:	5d                   	pop    %rbp
  8041608dee:	c3                   	retq   
    sched_yield();
  8041608def:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  8041608df6:	00 00 00 
  8041608df9:	ff d0                	callq  *%rax

0000008041608dfb <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041608dfb:	55                   	push   %rbp
  8041608dfc:	48 89 e5             	mov    %rsp,%rbp
        [ rd15 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r15)),
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
  __asm __volatile("movq %0,%%rsp\n" POPA
  8041608dff:	48 89 fc             	mov    %rdi,%rsp
  8041608e02:	4c 8b 3c 24          	mov    (%rsp),%r15
  8041608e06:	4c 8b 74 24 08       	mov    0x8(%rsp),%r14
  8041608e0b:	4c 8b 6c 24 10       	mov    0x10(%rsp),%r13
  8041608e10:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
  8041608e15:	4c 8b 5c 24 20       	mov    0x20(%rsp),%r11
  8041608e1a:	4c 8b 54 24 28       	mov    0x28(%rsp),%r10
  8041608e1f:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
  8041608e24:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
  8041608e29:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
  8041608e2e:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
  8041608e33:	48 8b 6c 24 50       	mov    0x50(%rsp),%rbp
  8041608e38:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
  8041608e3d:	48 8b 4c 24 60       	mov    0x60(%rsp),%rcx
  8041608e42:	48 8b 5c 24 68       	mov    0x68(%rsp),%rbx
  8041608e47:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
  8041608e4c:	48 83 c4 78          	add    $0x78,%rsp
  8041608e50:	8e 04 24             	mov    (%rsp),%es
  8041608e53:	8e 5c 24 08          	mov    0x8(%rsp),%ds
  8041608e57:	48 83 c4 10          	add    $0x10,%rsp
  8041608e5b:	48 83 c4 10          	add    $0x10,%rsp
  8041608e5f:	48 cf                	iretq  
                   "\tiretq"
                   :
                   : "g"(tf)
                   : "memory");
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041608e61:	48 ba 94 e3 60 41 80 	movabs $0x804160e394,%rdx
  8041608e68:	00 00 00 
  8041608e6b:	be d3 02 00 00       	mov    $0x2d3,%esi
  8041608e70:	48 bf 5c e3 60 41 80 	movabs $0x804160e35c,%rdi
  8041608e77:	00 00 00 
  8041608e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e7f:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608e86:	00 00 00 
  8041608e89:	ff d1                	callq  *%rcx

0000008041608e8b <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  8041608e8b:	55                   	push   %rbp
  8041608e8c:	48 89 e5             	mov    %rsp,%rbp
  8041608e8f:	41 54                	push   %r12
  8041608e91:	53                   	push   %rbx
  8041608e92:	48 89 fb             	mov    %rdi,%rbx
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //
    
  // LAB 3 code
  if (curenv) {  // if curenv == False, значит, какого-нибудь исполняемого процесса нет
  8041608e95:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041608e9c:	00 00 00 
  8041608e9f:	4c 8b 20             	mov    (%rax),%r12
  8041608ea2:	4d 85 e4             	test   %r12,%r12
  8041608ea5:	74 12                	je     8041608eb9 <env_run+0x2e>
    if (curenv->env_status == ENV_DYING) { // если процесс стал зомби
  8041608ea7:	41 8b 84 24 d4 00 00 	mov    0xd4(%r12),%eax
  8041608eae:	00 
  8041608eaf:	83 f8 01             	cmp    $0x1,%eax
  8041608eb2:	74 3c                	je     8041608ef0 <env_run+0x65>
      struct Env *old = curenv;  // ставим старый адрес
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
      if (old == e) { // e - аргумент функции, который к нам пришел
        sched_yield();  // переключение системными вызовами
      }
    } else if (curenv->env_status == ENV_RUNNING) { // если процесс можем запустить
  8041608eb4:	83 f8 03             	cmp    $0x3,%eax
  8041608eb7:	74 57                	je     8041608f10 <env_run+0x85>
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
    }
  }
      
  curenv = e;  // текущая среда – е
  8041608eb9:	48 89 d8             	mov    %rbx,%rax
  8041608ebc:	48 a3 20 45 88 41 80 	movabs %rax,0x8041884520
  8041608ec3:	00 00 00 
  curenv->env_status = ENV_RUNNING; // устанавливаем статус среды на "выполняется"
  8041608ec6:	c7 83 d4 00 00 00 03 	movl   $0x3,0xd4(%rbx)
  8041608ecd:	00 00 00 
  curenv->env_runs++; // обновляем количество работающих контекстов
  8041608ed0:	83 83 d8 00 00 00 01 	addl   $0x1,0xd8(%rbx)
  8041608ed7:	48 8b 83 f0 00 00 00 	mov    0xf0(%rbx),%rax
  8041608ede:	0f 22 d8             	mov    %rax,%cr3
  // LAB 8 code
  lcr3(curenv->env_cr3);
  // LAB 8 code end

  // LAB 3 code
  env_pop_tf(&curenv->env_tf);
  8041608ee1:	48 89 df             	mov    %rbx,%rdi
  8041608ee4:	48 b8 fb 8d 60 41 80 	movabs $0x8041608dfb,%rax
  8041608eeb:	00 00 00 
  8041608eee:	ff d0                	callq  *%rax
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
  8041608ef0:	4c 89 e7             	mov    %r12,%rdi
  8041608ef3:	48 b8 ac 8a 60 41 80 	movabs $0x8041608aac,%rax
  8041608efa:	00 00 00 
  8041608efd:	ff d0                	callq  *%rax
      if (old == e) { // e - аргумент функции, который к нам пришел
  8041608eff:	49 39 dc             	cmp    %rbx,%r12
  8041608f02:	75 b5                	jne    8041608eb9 <env_run+0x2e>
        sched_yield();  // переключение системными вызовами
  8041608f04:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  8041608f0b:	00 00 00 
  8041608f0e:	ff d0                	callq  *%rax
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
  8041608f10:	41 c7 84 24 d4 00 00 	movl   $0x2,0xd4(%r12)
  8041608f17:	00 02 00 00 00 
  8041608f1c:	eb 9b                	jmp    8041608eb9 <env_run+0x2e>

0000008041608f1e <rtc_timer_pic_interrupt>:
  pic_init();
  rtc_init();
}

static void
rtc_timer_pic_interrupt(void) {
  8041608f1e:	55                   	push   %rbp
  8041608f1f:	48 89 e5             	mov    %rsp,%rbp
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  8041608f22:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  8041608f29:	00 00 00 
  8041608f2c:	89 c7                	mov    %eax,%edi
  8041608f2e:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  8041608f34:	48 b8 1a 90 60 41 80 	movabs $0x804160901a,%rax
  8041608f3b:	00 00 00 
  8041608f3e:	ff d0                	callq  *%rax
}
  8041608f40:	5d                   	pop    %rbp
  8041608f41:	c3                   	retq   

0000008041608f42 <rtc_init>:
  __asm __volatile("inb %w1,%0"
  8041608f42:	b9 70 00 00 00       	mov    $0x70,%ecx
  8041608f47:	89 ca                	mov    %ecx,%edx
  8041608f49:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) & ~NMI_LOCK);
}

static inline void
nmi_disable(void) {
  outb(0x70, inb(0x70) | NMI_LOCK);
  8041608f4a:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  8041608f4d:	ee                   	out    %al,(%dx)
  8041608f4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041608f53:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608f54:	be 71 00 00 00       	mov    $0x71,%esi
  8041608f59:	89 f2                	mov    %esi,%edx
  8041608f5b:	ec                   	in     (%dx),%al
  
  // меняем делитель частоты регистра часов А,
  // чтобы прерывания приходили раз в полсекунды
  outb(IO_RTC_CMND, RTC_AREG);
  reg_a = inb(IO_RTC_DATA);
  reg_a = reg_a | 0x0F; // биты 0-3 = 1 => 500 мс (2 Гц) 
  8041608f5c:	83 c8 0f             	or     $0xf,%eax
  __asm __volatile("outb %0,%w1"
  8041608f5f:	ee                   	out    %al,(%dx)
  8041608f60:	b8 0b 00 00 00       	mov    $0xb,%eax
  8041608f65:	89 ca                	mov    %ecx,%edx
  8041608f67:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608f68:	89 f2                	mov    %esi,%edx
  8041608f6a:	ec                   	in     (%dx),%al
  outb(IO_RTC_DATA, reg_a);

  // устанавливаем бит RTC_PIE в регистре часов В
  outb(IO_RTC_CMND, RTC_BREG);
  reg_b = inb(IO_RTC_DATA);
  reg_b = reg_b | RTC_PIE; 
  8041608f6b:	83 c8 40             	or     $0x40,%eax
  __asm __volatile("outb %0,%w1"
  8041608f6e:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608f6f:	89 ca                	mov    %ecx,%edx
  8041608f71:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  8041608f72:	83 e0 7f             	and    $0x7f,%eax
  8041608f75:	ee                   	out    %al,(%dx)
  outb(IO_RTC_DATA, reg_b);

  // разрешить прерывания
  nmi_enable();
  // LAB 4 code end
}
  8041608f76:	c3                   	retq   

0000008041608f77 <rtc_timer_init>:
rtc_timer_init(void) {
  8041608f77:	55                   	push   %rbp
  8041608f78:	48 89 e5             	mov    %rsp,%rbp
  pic_init();
  8041608f7b:	48 b8 d4 90 60 41 80 	movabs $0x80416090d4,%rax
  8041608f82:	00 00 00 
  8041608f85:	ff d0                	callq  *%rax
  rtc_init();
  8041608f87:	48 b8 42 8f 60 41 80 	movabs $0x8041608f42,%rax
  8041608f8e:	00 00 00 
  8041608f91:	ff d0                	callq  *%rax
}
  8041608f93:	5d                   	pop    %rbp
  8041608f94:	c3                   	retq   

0000008041608f95 <rtc_check_status>:
  8041608f95:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041608f9a:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608f9f:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608fa0:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608fa5:	ec                   	in     (%dx),%al
  outb(IO_RTC_CMND, RTC_CREG);
  status = inb(IO_RTC_DATA);
  // LAB 4 code end

  return status;
}
  8041608fa6:	c3                   	retq   

0000008041608fa7 <rtc_timer_pic_handle>:
rtc_timer_pic_handle(void) {
  8041608fa7:	55                   	push   %rbp
  8041608fa8:	48 89 e5             	mov    %rsp,%rbp
  rtc_check_status();
  8041608fab:	48 b8 95 8f 60 41 80 	movabs $0x8041608f95,%rax
  8041608fb2:	00 00 00 
  8041608fb5:	ff d0                	callq  *%rax
  pic_send_eoi(IRQ_CLOCK);
  8041608fb7:	bf 08 00 00 00       	mov    $0x8,%edi
  8041608fbc:	48 b8 7f 91 60 41 80 	movabs $0x804160917f,%rax
  8041608fc3:	00 00 00 
  8041608fc6:	ff d0                	callq  *%rax
}
  8041608fc8:	5d                   	pop    %rbp
  8041608fc9:	c3                   	retq   

0000008041608fca <mc146818_read>:
  __asm __volatile("outb %0,%w1"
  8041608fca:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608fcf:	89 f8                	mov    %edi,%eax
  8041608fd1:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608fd2:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608fd7:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg) {
  outb(IO_RTC_CMND, reg);
  return inb(IO_RTC_DATA);
  8041608fd8:	0f b6 c0             	movzbl %al,%eax
}
  8041608fdb:	c3                   	retq   

0000008041608fdc <mc146818_write>:
  __asm __volatile("outb %0,%w1"
  8041608fdc:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608fe1:	89 f8                	mov    %edi,%eax
  8041608fe3:	ee                   	out    %al,(%dx)
  8041608fe4:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608fe9:	89 f0                	mov    %esi,%eax
  8041608feb:	ee                   	out    %al,(%dx)

void
mc146818_write(unsigned reg, unsigned datum) {
  outb(IO_RTC_CMND, reg);
  outb(IO_RTC_DATA, datum);
}
  8041608fec:	c3                   	retq   

0000008041608fed <mc146818_read16>:
  8041608fed:	41 b8 70 00 00 00    	mov    $0x70,%r8d
  8041608ff3:	89 f8                	mov    %edi,%eax
  8041608ff5:	44 89 c2             	mov    %r8d,%edx
  8041608ff8:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608ff9:	b9 71 00 00 00       	mov    $0x71,%ecx
  8041608ffe:	89 ca                	mov    %ecx,%edx
  8041609000:	ec                   	in     (%dx),%al
  8041609001:	89 c6                	mov    %eax,%esi

unsigned
mc146818_read16(unsigned reg) {
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041609003:	8d 47 01             	lea    0x1(%rdi),%eax
  __asm __volatile("outb %0,%w1"
  8041609006:	44 89 c2             	mov    %r8d,%edx
  8041609009:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160900a:	89 ca                	mov    %ecx,%edx
  804160900c:	ec                   	in     (%dx),%al
  return inb(IO_RTC_DATA);
  804160900d:	0f b6 c0             	movzbl %al,%eax
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041609010:	c1 e0 08             	shl    $0x8,%eax
  return inb(IO_RTC_DATA);
  8041609013:	40 0f b6 f6          	movzbl %sil,%esi
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041609017:	09 f0                	or     %esi,%eax
  8041609019:	c3                   	retq   

000000804160901a <irq_setmask_8259A>:
}

void
irq_setmask_8259A(uint16_t mask) {
  int i;
  irq_mask_8259A = mask;
  804160901a:	89 f8                	mov    %edi,%eax
  804160901c:	66 a3 e8 07 62 41 80 	movabs %ax,0x80416207e8
  8041609023:	00 00 00 
  if (!didinit)
  8041609026:	48 b8 38 45 88 41 80 	movabs $0x8041884538,%rax
  804160902d:	00 00 00 
  8041609030:	80 38 00             	cmpb   $0x0,(%rax)
  8041609033:	75 01                	jne    8041609036 <irq_setmask_8259A+0x1c>
  8041609035:	c3                   	retq   
irq_setmask_8259A(uint16_t mask) {
  8041609036:	55                   	push   %rbp
  8041609037:	48 89 e5             	mov    %rsp,%rbp
  804160903a:	41 56                	push   %r14
  804160903c:	41 55                	push   %r13
  804160903e:	41 54                	push   %r12
  8041609040:	53                   	push   %rbx
  8041609041:	41 89 fc             	mov    %edi,%r12d
  8041609044:	89 f8                	mov    %edi,%eax
  __asm __volatile("outb %0,%w1"
  8041609046:	ba 21 00 00 00       	mov    $0x21,%edx
  804160904b:	ee                   	out    %al,(%dx)
    return;
  outb(IO_PIC1_DATA, (char)mask);
  outb(IO_PIC2_DATA, (char)(mask >> 8));
  804160904c:	66 c1 e8 08          	shr    $0x8,%ax
  8041609050:	ba a1 00 00 00       	mov    $0xa1,%edx
  8041609055:	ee                   	out    %al,(%dx)
  cprintf("enabled interrupts:");
  8041609056:	48 bf 9c e3 60 41 80 	movabs $0x804160e39c,%rdi
  804160905d:	00 00 00 
  8041609060:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609065:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160906c:	00 00 00 
  804160906f:	ff d2                	callq  *%rdx
  for (i = 0; i < 16; i++)
  8041609071:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (~mask & (1 << i))
  8041609076:	45 0f b7 e4          	movzwl %r12w,%r12d
  804160907a:	41 f7 d4             	not    %r12d
      cprintf(" %d", i);
  804160907d:	49 be 40 ec 60 41 80 	movabs $0x804160ec40,%r14
  8041609084:	00 00 00 
  8041609087:	49 bd f2 91 60 41 80 	movabs $0x80416091f2,%r13
  804160908e:	00 00 00 
  8041609091:	eb 15                	jmp    80416090a8 <irq_setmask_8259A+0x8e>
  8041609093:	89 de                	mov    %ebx,%esi
  8041609095:	4c 89 f7             	mov    %r14,%rdi
  8041609098:	b8 00 00 00 00       	mov    $0x0,%eax
  804160909d:	41 ff d5             	callq  *%r13
  for (i = 0; i < 16; i++)
  80416090a0:	83 c3 01             	add    $0x1,%ebx
  80416090a3:	83 fb 10             	cmp    $0x10,%ebx
  80416090a6:	74 08                	je     80416090b0 <irq_setmask_8259A+0x96>
    if (~mask & (1 << i))
  80416090a8:	41 0f a3 dc          	bt     %ebx,%r12d
  80416090ac:	73 f2                	jae    80416090a0 <irq_setmask_8259A+0x86>
  80416090ae:	eb e3                	jmp    8041609093 <irq_setmask_8259A+0x79>
  cprintf("\n");
  80416090b0:	48 bf 1f e2 60 41 80 	movabs $0x804160e21f,%rdi
  80416090b7:	00 00 00 
  80416090ba:	b8 00 00 00 00       	mov    $0x0,%eax
  80416090bf:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416090c6:	00 00 00 
  80416090c9:	ff d2                	callq  *%rdx
}
  80416090cb:	5b                   	pop    %rbx
  80416090cc:	41 5c                	pop    %r12
  80416090ce:	41 5d                	pop    %r13
  80416090d0:	41 5e                	pop    %r14
  80416090d2:	5d                   	pop    %rbp
  80416090d3:	c3                   	retq   

00000080416090d4 <pic_init>:
  didinit = 1;
  80416090d4:	48 b8 38 45 88 41 80 	movabs $0x8041884538,%rax
  80416090db:	00 00 00 
  80416090de:	c6 00 01             	movb   $0x1,(%rax)
  80416090e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416090e6:	be 21 00 00 00       	mov    $0x21,%esi
  80416090eb:	89 f2                	mov    %esi,%edx
  80416090ed:	ee                   	out    %al,(%dx)
  80416090ee:	b9 a1 00 00 00       	mov    $0xa1,%ecx
  80416090f3:	89 ca                	mov    %ecx,%edx
  80416090f5:	ee                   	out    %al,(%dx)
  80416090f6:	41 b9 11 00 00 00    	mov    $0x11,%r9d
  80416090fc:	bf 20 00 00 00       	mov    $0x20,%edi
  8041609101:	44 89 c8             	mov    %r9d,%eax
  8041609104:	89 fa                	mov    %edi,%edx
  8041609106:	ee                   	out    %al,(%dx)
  8041609107:	b8 20 00 00 00       	mov    $0x20,%eax
  804160910c:	89 f2                	mov    %esi,%edx
  804160910e:	ee                   	out    %al,(%dx)
  804160910f:	b8 04 00 00 00       	mov    $0x4,%eax
  8041609114:	ee                   	out    %al,(%dx)
  8041609115:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  804160911b:	44 89 c0             	mov    %r8d,%eax
  804160911e:	ee                   	out    %al,(%dx)
  804160911f:	be a0 00 00 00       	mov    $0xa0,%esi
  8041609124:	44 89 c8             	mov    %r9d,%eax
  8041609127:	89 f2                	mov    %esi,%edx
  8041609129:	ee                   	out    %al,(%dx)
  804160912a:	b8 28 00 00 00       	mov    $0x28,%eax
  804160912f:	89 ca                	mov    %ecx,%edx
  8041609131:	ee                   	out    %al,(%dx)
  8041609132:	b8 02 00 00 00       	mov    $0x2,%eax
  8041609137:	ee                   	out    %al,(%dx)
  8041609138:	44 89 c0             	mov    %r8d,%eax
  804160913b:	ee                   	out    %al,(%dx)
  804160913c:	41 b8 68 00 00 00    	mov    $0x68,%r8d
  8041609142:	44 89 c0             	mov    %r8d,%eax
  8041609145:	89 fa                	mov    %edi,%edx
  8041609147:	ee                   	out    %al,(%dx)
  8041609148:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160914d:	89 c8                	mov    %ecx,%eax
  804160914f:	ee                   	out    %al,(%dx)
  8041609150:	44 89 c0             	mov    %r8d,%eax
  8041609153:	89 f2                	mov    %esi,%edx
  8041609155:	ee                   	out    %al,(%dx)
  8041609156:	89 c8                	mov    %ecx,%eax
  8041609158:	ee                   	out    %al,(%dx)
  if (irq_mask_8259A != 0xFFFF)
  8041609159:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  8041609160:	00 00 00 
  8041609163:	66 83 f8 ff          	cmp    $0xffff,%ax
  8041609167:	75 01                	jne    804160916a <pic_init+0x96>
  8041609169:	c3                   	retq   
pic_init(void) {
  804160916a:	55                   	push   %rbp
  804160916b:	48 89 e5             	mov    %rsp,%rbp
    irq_setmask_8259A(irq_mask_8259A);
  804160916e:	0f b7 f8             	movzwl %ax,%edi
  8041609171:	48 b8 1a 90 60 41 80 	movabs $0x804160901a,%rax
  8041609178:	00 00 00 
  804160917b:	ff d0                	callq  *%rax
}
  804160917d:	5d                   	pop    %rbp
  804160917e:	c3                   	retq   

000000804160917f <pic_send_eoi>:

void
pic_send_eoi(uint8_t irq) {
  if (irq >= 8)
  804160917f:	40 80 ff 07          	cmp    $0x7,%dil
  8041609183:	76 0b                	jbe    8041609190 <pic_send_eoi+0x11>
  8041609185:	b8 20 00 00 00       	mov    $0x20,%eax
  804160918a:	ba a0 00 00 00       	mov    $0xa0,%edx
  804160918f:	ee                   	out    %al,(%dx)
  8041609190:	b8 20 00 00 00       	mov    $0x20,%eax
  8041609195:	ba 20 00 00 00       	mov    $0x20,%edx
  804160919a:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_CMND, PIC_EOI);
  outb(IO_PIC1_CMND, PIC_EOI);
}
  804160919b:	c3                   	retq   

000000804160919c <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  804160919c:	55                   	push   %rbp
  804160919d:	48 89 e5             	mov    %rsp,%rbp
  80416091a0:	53                   	push   %rbx
  80416091a1:	48 83 ec 08          	sub    $0x8,%rsp
  80416091a5:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  80416091a8:	48 b8 e7 0c 60 41 80 	movabs $0x8041600ce7,%rax
  80416091af:	00 00 00 
  80416091b2:	ff d0                	callq  *%rax
  (*cnt)++;
  80416091b4:	83 03 01             	addl   $0x1,(%rbx)
}
  80416091b7:	48 83 c4 08          	add    $0x8,%rsp
  80416091bb:	5b                   	pop    %rbx
  80416091bc:	5d                   	pop    %rbp
  80416091bd:	c3                   	retq   

00000080416091be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80416091be:	55                   	push   %rbp
  80416091bf:	48 89 e5             	mov    %rsp,%rbp
  80416091c2:	48 83 ec 10          	sub    $0x10,%rsp
  80416091c6:	48 89 fa             	mov    %rdi,%rdx
  80416091c9:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  80416091cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  80416091d3:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  80416091d7:	48 bf 9c 91 60 41 80 	movabs $0x804160919c,%rdi
  80416091de:	00 00 00 
  80416091e1:	48 b8 db b9 60 41 80 	movabs $0x804160b9db,%rax
  80416091e8:	00 00 00 
  80416091eb:	ff d0                	callq  *%rax
  return cnt;
}
  80416091ed:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80416091f0:	c9                   	leaveq 
  80416091f1:	c3                   	retq   

00000080416091f2 <cprintf>:

int
cprintf(const char *fmt, ...) {
  80416091f2:	55                   	push   %rbp
  80416091f3:	48 89 e5             	mov    %rsp,%rbp
  80416091f6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80416091fd:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8041609204:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  804160920b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041609212:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041609219:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041609220:	84 c0                	test   %al,%al
  8041609222:	74 20                	je     8041609244 <cprintf+0x52>
  8041609224:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041609228:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160922c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041609230:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041609234:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041609238:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160923c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041609240:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8041609244:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  804160924b:	00 00 00 
  804160924e:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041609255:	00 00 00 
  8041609258:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160925c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041609263:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160926a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8041609271:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041609278:	48 b8 be 91 60 41 80 	movabs $0x80416091be,%rax
  804160927f:	00 00 00 
  8041609282:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8041609284:	c9                   	leaveq 
  8041609285:	c3                   	retq   

0000008041609286 <trap_init_percpu>:
// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void) {
  // Setup a TSS so that we get the right stack
  // when we trap to the kernel.
  ts.ts_esp0 = KSTACKTOP;
  8041609286:	48 ba 60 55 88 41 80 	movabs $0x8041885560,%rdx
  804160928d:	00 00 00 
  8041609290:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041609297:	00 00 00 
  804160929a:	48 89 42 04          	mov    %rax,0x4(%rdx)

  // Initialize the TSS slot of the gdt.
  SETTSS((struct SystemSegdesc64 *)(&gdt[(GD_TSS0 >> 3)]), STS_T64A,
  804160929e:	48 b8 60 07 62 41 80 	movabs $0x8041620760,%rax
  80416092a5:	00 00 00 
  80416092a8:	66 c7 40 38 68 00    	movw   $0x68,0x38(%rax)
  80416092ae:	66 89 50 3a          	mov    %dx,0x3a(%rax)
  80416092b2:	48 89 d1             	mov    %rdx,%rcx
  80416092b5:	48 c1 e9 10          	shr    $0x10,%rcx
  80416092b9:	88 48 3c             	mov    %cl,0x3c(%rax)
  80416092bc:	c6 40 3d 89          	movb   $0x89,0x3d(%rax)
  80416092c0:	c6 40 3e 00          	movb   $0x0,0x3e(%rax)
  80416092c4:	48 89 d1             	mov    %rdx,%rcx
  80416092c7:	48 c1 e9 18          	shr    $0x18,%rcx
  80416092cb:	88 48 3f             	mov    %cl,0x3f(%rax)
  80416092ce:	48 c1 ea 20          	shr    $0x20,%rdx
  80416092d2:	89 50 40             	mov    %edx,0x40(%rax)
  80416092d5:	c6 40 44 00          	movb   $0x0,0x44(%rax)
  80416092d9:	c6 40 45 00          	movb   $0x0,0x45(%rax)
  80416092dd:	66 c7 40 46 00 00    	movw   $0x0,0x46(%rax)
  __asm __volatile("ltr %0"
  80416092e3:	b8 38 00 00 00       	mov    $0x38,%eax
  80416092e8:	0f 00 d8             	ltr    %ax
  __asm __volatile("lidt (%0)"
  80416092eb:	48 b8 f0 07 62 41 80 	movabs $0x80416207f0,%rax
  80416092f2:	00 00 00 
  80416092f5:	0f 01 18             	lidt   (%rax)
  // bottom three bits are special; we leave them 0)
  ltr(GD_TSS0);

  // Load the IDT
  lidt(&idt_pd);
}
  80416092f8:	c3                   	retq   

00000080416092f9 <trap_init>:
trap_init(void) {
  80416092f9:	55                   	push   %rbp
  80416092fa:	48 89 e5             	mov    %rsp,%rbp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, (uint64_t) &divide_thdlr, 0);
  80416092fd:	48 b8 40 45 88 41 80 	movabs $0x8041884540,%rax
  8041609304:	00 00 00 
  8041609307:	48 ba 8a 9f 60 41 80 	movabs $0x8041609f8a,%rdx
  804160930e:	00 00 00 
  8041609311:	66 89 10             	mov    %dx,(%rax)
  8041609314:	66 c7 40 02 08 00    	movw   $0x8,0x2(%rax)
  804160931a:	c6 40 04 00          	movb   $0x0,0x4(%rax)
  804160931e:	c6 40 05 8e          	movb   $0x8e,0x5(%rax)
  8041609322:	48 89 d1             	mov    %rdx,%rcx
  8041609325:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609329:	66 89 48 06          	mov    %cx,0x6(%rax)
  804160932d:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609331:	89 50 08             	mov    %edx,0x8(%rax)
  8041609334:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%rax)
	SETGATE(idt[T_DEBUG], 0, GD_KT, (uint64_t) &debug_thdlr, 0);
  804160933b:	48 ba 90 9f 60 41 80 	movabs $0x8041609f90,%rdx
  8041609342:	00 00 00 
  8041609345:	66 89 50 10          	mov    %dx,0x10(%rax)
  8041609349:	66 c7 40 12 08 00    	movw   $0x8,0x12(%rax)
  804160934f:	c6 40 14 00          	movb   $0x0,0x14(%rax)
  8041609353:	c6 40 15 8e          	movb   $0x8e,0x15(%rax)
  8041609357:	48 89 d1             	mov    %rdx,%rcx
  804160935a:	48 c1 e9 10          	shr    $0x10,%rcx
  804160935e:	66 89 48 16          	mov    %cx,0x16(%rax)
  8041609362:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609366:	89 50 18             	mov    %edx,0x18(%rax)
  8041609369:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%rax)
	SETGATE(idt[T_NMI], 0, GD_KT, (uint64_t) &nmi_thdlr, 0);
  8041609370:	48 ba 9a 9f 60 41 80 	movabs $0x8041609f9a,%rdx
  8041609377:	00 00 00 
  804160937a:	66 89 50 20          	mov    %dx,0x20(%rax)
  804160937e:	66 c7 40 22 08 00    	movw   $0x8,0x22(%rax)
  8041609384:	c6 40 24 00          	movb   $0x0,0x24(%rax)
  8041609388:	c6 40 25 8e          	movb   $0x8e,0x25(%rax)
  804160938c:	48 89 d1             	mov    %rdx,%rcx
  804160938f:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609393:	66 89 48 26          	mov    %cx,0x26(%rax)
  8041609397:	48 c1 ea 20          	shr    $0x20,%rdx
  804160939b:	89 50 28             	mov    %edx,0x28(%rax)
  804160939e:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%rax)
	SETGATE(idt[T_BRKPT], 0, GD_KT, (uint64_t) &brkpt_thdlr, 3);
  80416093a5:	48 ba a4 9f 60 41 80 	movabs $0x8041609fa4,%rdx
  80416093ac:	00 00 00 
  80416093af:	66 89 50 30          	mov    %dx,0x30(%rax)
  80416093b3:	66 c7 40 32 08 00    	movw   $0x8,0x32(%rax)
  80416093b9:	c6 40 34 00          	movb   $0x0,0x34(%rax)
  80416093bd:	c6 40 35 ee          	movb   $0xee,0x35(%rax)
  80416093c1:	48 89 d1             	mov    %rdx,%rcx
  80416093c4:	48 c1 e9 10          	shr    $0x10,%rcx
  80416093c8:	66 89 48 36          	mov    %cx,0x36(%rax)
  80416093cc:	48 c1 ea 20          	shr    $0x20,%rdx
  80416093d0:	89 50 38             	mov    %edx,0x38(%rax)
  80416093d3:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%rax)
	SETGATE(idt[T_OFLOW], 0, GD_KT, (uint64_t) &oflow_thdlr, 0);
  80416093da:	48 ba ae 9f 60 41 80 	movabs $0x8041609fae,%rdx
  80416093e1:	00 00 00 
  80416093e4:	66 89 50 40          	mov    %dx,0x40(%rax)
  80416093e8:	66 c7 40 42 08 00    	movw   $0x8,0x42(%rax)
  80416093ee:	c6 40 44 00          	movb   $0x0,0x44(%rax)
  80416093f2:	c6 40 45 8e          	movb   $0x8e,0x45(%rax)
  80416093f6:	48 89 d1             	mov    %rdx,%rcx
  80416093f9:	48 c1 e9 10          	shr    $0x10,%rcx
  80416093fd:	66 89 48 46          	mov    %cx,0x46(%rax)
  8041609401:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609405:	89 50 48             	mov    %edx,0x48(%rax)
  8041609408:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%rax)
	SETGATE(idt[T_BOUND], 0, GD_KT, (uint64_t) &bound_thdlr, 0);
  804160940f:	48 ba b8 9f 60 41 80 	movabs $0x8041609fb8,%rdx
  8041609416:	00 00 00 
  8041609419:	66 89 50 50          	mov    %dx,0x50(%rax)
  804160941d:	66 c7 40 52 08 00    	movw   $0x8,0x52(%rax)
  8041609423:	c6 40 54 00          	movb   $0x0,0x54(%rax)
  8041609427:	c6 40 55 8e          	movb   $0x8e,0x55(%rax)
  804160942b:	48 89 d1             	mov    %rdx,%rcx
  804160942e:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609432:	66 89 48 56          	mov    %cx,0x56(%rax)
  8041609436:	48 c1 ea 20          	shr    $0x20,%rdx
  804160943a:	89 50 58             	mov    %edx,0x58(%rax)
  804160943d:	c7 40 5c 00 00 00 00 	movl   $0x0,0x5c(%rax)
	SETGATE(idt[T_ILLOP], 0, GD_KT, (uint64_t) &illop_thdlr, 0);
  8041609444:	48 ba c2 9f 60 41 80 	movabs $0x8041609fc2,%rdx
  804160944b:	00 00 00 
  804160944e:	66 89 50 60          	mov    %dx,0x60(%rax)
  8041609452:	66 c7 40 62 08 00    	movw   $0x8,0x62(%rax)
  8041609458:	c6 40 64 00          	movb   $0x0,0x64(%rax)
  804160945c:	c6 40 65 8e          	movb   $0x8e,0x65(%rax)
  8041609460:	48 89 d1             	mov    %rdx,%rcx
  8041609463:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609467:	66 89 48 66          	mov    %cx,0x66(%rax)
  804160946b:	48 c1 ea 20          	shr    $0x20,%rdx
  804160946f:	89 50 68             	mov    %edx,0x68(%rax)
  8041609472:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%rax)
	SETGATE(idt[T_DEVICE], 0, GD_KT, (uint64_t) &device_thdlr, 0);
  8041609479:	48 ba cc 9f 60 41 80 	movabs $0x8041609fcc,%rdx
  8041609480:	00 00 00 
  8041609483:	66 89 50 70          	mov    %dx,0x70(%rax)
  8041609487:	66 c7 40 72 08 00    	movw   $0x8,0x72(%rax)
  804160948d:	c6 40 74 00          	movb   $0x0,0x74(%rax)
  8041609491:	c6 40 75 8e          	movb   $0x8e,0x75(%rax)
  8041609495:	48 89 d1             	mov    %rdx,%rcx
  8041609498:	48 c1 e9 10          	shr    $0x10,%rcx
  804160949c:	66 89 48 76          	mov    %cx,0x76(%rax)
  80416094a0:	48 c1 ea 20          	shr    $0x20,%rdx
  80416094a4:	89 50 78             	mov    %edx,0x78(%rax)
  80416094a7:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%rax)
	SETGATE(idt[T_TSS], 0, GD_KT, (uint64_t) &tss_thdlr, 0);
  80416094ae:	48 ba de 9f 60 41 80 	movabs $0x8041609fde,%rdx
  80416094b5:	00 00 00 
  80416094b8:	66 89 90 a0 00 00 00 	mov    %dx,0xa0(%rax)
  80416094bf:	66 c7 80 a2 00 00 00 	movw   $0x8,0xa2(%rax)
  80416094c6:	08 00 
  80416094c8:	c6 80 a4 00 00 00 00 	movb   $0x0,0xa4(%rax)
  80416094cf:	c6 80 a5 00 00 00 8e 	movb   $0x8e,0xa5(%rax)
  80416094d6:	48 89 d1             	mov    %rdx,%rcx
  80416094d9:	48 c1 e9 10          	shr    $0x10,%rcx
  80416094dd:	66 89 88 a6 00 00 00 	mov    %cx,0xa6(%rax)
  80416094e4:	48 c1 ea 20          	shr    $0x20,%rdx
  80416094e8:	89 90 a8 00 00 00    	mov    %edx,0xa8(%rax)
  80416094ee:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%rax)
  80416094f5:	00 00 00 
	SETGATE(idt[T_SEGNP], 0, GD_KT, (uint64_t) &segnp_thdlr, 0);
  80416094f8:	48 ba e6 9f 60 41 80 	movabs $0x8041609fe6,%rdx
  80416094ff:	00 00 00 
  8041609502:	66 89 90 b0 00 00 00 	mov    %dx,0xb0(%rax)
  8041609509:	66 c7 80 b2 00 00 00 	movw   $0x8,0xb2(%rax)
  8041609510:	08 00 
  8041609512:	c6 80 b4 00 00 00 00 	movb   $0x0,0xb4(%rax)
  8041609519:	c6 80 b5 00 00 00 8e 	movb   $0x8e,0xb5(%rax)
  8041609520:	48 89 d1             	mov    %rdx,%rcx
  8041609523:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609527:	66 89 88 b6 00 00 00 	mov    %cx,0xb6(%rax)
  804160952e:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609532:	89 90 b8 00 00 00    	mov    %edx,0xb8(%rax)
  8041609538:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%rax)
  804160953f:	00 00 00 
	SETGATE(idt[T_STACK], 0, GD_KT, (uint64_t) &stack_thdlr, 0);
  8041609542:	48 ba ee 9f 60 41 80 	movabs $0x8041609fee,%rdx
  8041609549:	00 00 00 
  804160954c:	66 89 90 c0 00 00 00 	mov    %dx,0xc0(%rax)
  8041609553:	66 c7 80 c2 00 00 00 	movw   $0x8,0xc2(%rax)
  804160955a:	08 00 
  804160955c:	c6 80 c4 00 00 00 00 	movb   $0x0,0xc4(%rax)
  8041609563:	c6 80 c5 00 00 00 8e 	movb   $0x8e,0xc5(%rax)
  804160956a:	48 89 d1             	mov    %rdx,%rcx
  804160956d:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609571:	66 89 88 c6 00 00 00 	mov    %cx,0xc6(%rax)
  8041609578:	48 c1 ea 20          	shr    $0x20,%rdx
  804160957c:	89 90 c8 00 00 00    	mov    %edx,0xc8(%rax)
  8041609582:	c7 80 cc 00 00 00 00 	movl   $0x0,0xcc(%rax)
  8041609589:	00 00 00 
	SETGATE(idt[T_GPFLT], 0, GD_KT, (uint64_t) &gpflt_thdlr, 0);
  804160958c:	48 ba f6 9f 60 41 80 	movabs $0x8041609ff6,%rdx
  8041609593:	00 00 00 
  8041609596:	66 89 90 d0 00 00 00 	mov    %dx,0xd0(%rax)
  804160959d:	66 c7 80 d2 00 00 00 	movw   $0x8,0xd2(%rax)
  80416095a4:	08 00 
  80416095a6:	c6 80 d4 00 00 00 00 	movb   $0x0,0xd4(%rax)
  80416095ad:	c6 80 d5 00 00 00 8e 	movb   $0x8e,0xd5(%rax)
  80416095b4:	48 89 d1             	mov    %rdx,%rcx
  80416095b7:	48 c1 e9 10          	shr    $0x10,%rcx
  80416095bb:	66 89 88 d6 00 00 00 	mov    %cx,0xd6(%rax)
  80416095c2:	48 c1 ea 20          	shr    $0x20,%rdx
  80416095c6:	89 90 d8 00 00 00    	mov    %edx,0xd8(%rax)
  80416095cc:	c7 80 dc 00 00 00 00 	movl   $0x0,0xdc(%rax)
  80416095d3:	00 00 00 
	SETGATE(idt[T_PGFLT], 0, GD_KT, (uint64_t) &pgflt_thdlr, 0);
  80416095d6:	48 ba fe 9f 60 41 80 	movabs $0x8041609ffe,%rdx
  80416095dd:	00 00 00 
  80416095e0:	66 89 90 e0 00 00 00 	mov    %dx,0xe0(%rax)
  80416095e7:	66 c7 80 e2 00 00 00 	movw   $0x8,0xe2(%rax)
  80416095ee:	08 00 
  80416095f0:	c6 80 e4 00 00 00 00 	movb   $0x0,0xe4(%rax)
  80416095f7:	c6 80 e5 00 00 00 8e 	movb   $0x8e,0xe5(%rax)
  80416095fe:	48 89 d1             	mov    %rdx,%rcx
  8041609601:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609605:	66 89 88 e6 00 00 00 	mov    %cx,0xe6(%rax)
  804160960c:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609610:	89 90 e8 00 00 00    	mov    %edx,0xe8(%rax)
  8041609616:	c7 80 ec 00 00 00 00 	movl   $0x0,0xec(%rax)
  804160961d:	00 00 00 
	SETGATE(idt[T_FPERR], 0, GD_KT, (uint64_t) &fperr_thdlr, 0);
  8041609620:	48 ba 06 a0 60 41 80 	movabs $0x804160a006,%rdx
  8041609627:	00 00 00 
  804160962a:	66 89 90 00 01 00 00 	mov    %dx,0x100(%rax)
  8041609631:	66 c7 80 02 01 00 00 	movw   $0x8,0x102(%rax)
  8041609638:	08 00 
  804160963a:	c6 80 04 01 00 00 00 	movb   $0x0,0x104(%rax)
  8041609641:	c6 80 05 01 00 00 8e 	movb   $0x8e,0x105(%rax)
  8041609648:	48 89 d1             	mov    %rdx,%rcx
  804160964b:	48 c1 e9 10          	shr    $0x10,%rcx
  804160964f:	66 89 88 06 01 00 00 	mov    %cx,0x106(%rax)
  8041609656:	48 c1 ea 20          	shr    $0x20,%rdx
  804160965a:	89 90 08 01 00 00    	mov    %edx,0x108(%rax)
  8041609660:	c7 80 0c 01 00 00 00 	movl   $0x0,0x10c(%rax)
  8041609667:	00 00 00 
  SETGATE(idt[T_SYSCALL], 0, GD_KT, (uint64_t) &syscall_thdlr, 3);
  804160966a:	48 ba 2c a0 60 41 80 	movabs $0x804160a02c,%rdx
  8041609671:	00 00 00 
  8041609674:	66 89 90 00 03 00 00 	mov    %dx,0x300(%rax)
  804160967b:	66 c7 80 02 03 00 00 	movw   $0x8,0x302(%rax)
  8041609682:	08 00 
  8041609684:	c6 80 04 03 00 00 00 	movb   $0x0,0x304(%rax)
  804160968b:	c6 80 05 03 00 00 ee 	movb   $0xee,0x305(%rax)
  8041609692:	48 89 d1             	mov    %rdx,%rcx
  8041609695:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609699:	66 89 88 06 03 00 00 	mov    %cx,0x306(%rax)
  80416096a0:	48 c1 ea 20          	shr    $0x20,%rdx
  80416096a4:	89 90 08 03 00 00    	mov    %edx,0x308(%rax)
  80416096aa:	c7 80 0c 03 00 00 00 	movl   $0x0,0x30c(%rax)
  80416096b1:	00 00 00 
  trap_init_percpu();
  80416096b4:	48 b8 86 92 60 41 80 	movabs $0x8041609286,%rax
  80416096bb:	00 00 00 
  80416096be:	ff d0                	callq  *%rax
}
  80416096c0:	5d                   	pop    %rbp
  80416096c1:	c3                   	retq   

00000080416096c2 <clock_idt_init>:

void
clock_idt_init(void) {
  extern void (*clock_thdlr)(void);
  // init idt structure
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  80416096c2:	48 ba 84 9f 60 41 80 	movabs $0x8041609f84,%rdx
  80416096c9:	00 00 00 
  80416096cc:	48 b8 40 45 88 41 80 	movabs $0x8041884540,%rax
  80416096d3:	00 00 00 
  80416096d6:	66 89 90 00 02 00 00 	mov    %dx,0x200(%rax)
  80416096dd:	66 c7 80 02 02 00 00 	movw   $0x8,0x202(%rax)
  80416096e4:	08 00 
  80416096e6:	c6 80 04 02 00 00 00 	movb   $0x0,0x204(%rax)
  80416096ed:	c6 80 05 02 00 00 8e 	movb   $0x8e,0x205(%rax)
  80416096f4:	48 89 d6             	mov    %rdx,%rsi
  80416096f7:	48 c1 ee 10          	shr    $0x10,%rsi
  80416096fb:	66 89 b0 06 02 00 00 	mov    %si,0x206(%rax)
  8041609702:	48 89 d1             	mov    %rdx,%rcx
  8041609705:	48 c1 e9 20          	shr    $0x20,%rcx
  8041609709:	89 88 08 02 00 00    	mov    %ecx,0x208(%rax)
  804160970f:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%rax)
  8041609716:	00 00 00 
  SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041609719:	66 89 90 80 02 00 00 	mov    %dx,0x280(%rax)
  8041609720:	66 c7 80 82 02 00 00 	movw   $0x8,0x282(%rax)
  8041609727:	08 00 
  8041609729:	c6 80 84 02 00 00 00 	movb   $0x0,0x284(%rax)
  8041609730:	c6 80 85 02 00 00 8e 	movb   $0x8e,0x285(%rax)
  8041609737:	66 89 b0 86 02 00 00 	mov    %si,0x286(%rax)
  804160973e:	89 88 88 02 00 00    	mov    %ecx,0x288(%rax)
  8041609744:	c7 80 8c 02 00 00 00 	movl   $0x0,0x28c(%rax)
  804160974b:	00 00 00 
  804160974e:	48 b8 f0 07 62 41 80 	movabs $0x80416207f0,%rax
  8041609755:	00 00 00 
  8041609758:	0f 01 18             	lidt   (%rax)
  lidt(&idt_pd);
}
  804160975b:	c3                   	retq   

000000804160975c <print_regs>:
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  }
}

void
print_regs(struct PushRegs *regs) {
  804160975c:	55                   	push   %rbp
  804160975d:	48 89 e5             	mov    %rsp,%rbp
  8041609760:	41 54                	push   %r12
  8041609762:	53                   	push   %rbx
  8041609763:	49 89 fc             	mov    %rdi,%r12
  cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  8041609766:	48 8b 37             	mov    (%rdi),%rsi
  8041609769:	48 bf b0 e3 60 41 80 	movabs $0x804160e3b0,%rdi
  8041609770:	00 00 00 
  8041609773:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609778:	48 bb f2 91 60 41 80 	movabs $0x80416091f2,%rbx
  804160977f:	00 00 00 
  8041609782:	ff d3                	callq  *%rbx
  cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  8041609784:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
  8041609789:	48 bf c0 e3 60 41 80 	movabs $0x804160e3c0,%rdi
  8041609790:	00 00 00 
  8041609793:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609798:	ff d3                	callq  *%rbx
  cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  804160979a:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  804160979f:	48 bf d0 e3 60 41 80 	movabs $0x804160e3d0,%rdi
  80416097a6:	00 00 00 
  80416097a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097ae:	ff d3                	callq  *%rbx
  cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  80416097b0:	49 8b 74 24 18       	mov    0x18(%r12),%rsi
  80416097b5:	48 bf e0 e3 60 41 80 	movabs $0x804160e3e0,%rdi
  80416097bc:	00 00 00 
  80416097bf:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097c4:	ff d3                	callq  *%rbx
  cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  80416097c6:	49 8b 74 24 20       	mov    0x20(%r12),%rsi
  80416097cb:	48 bf f0 e3 60 41 80 	movabs $0x804160e3f0,%rdi
  80416097d2:	00 00 00 
  80416097d5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097da:	ff d3                	callq  *%rbx
  cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  80416097dc:	49 8b 74 24 28       	mov    0x28(%r12),%rsi
  80416097e1:	48 bf 00 e4 60 41 80 	movabs $0x804160e400,%rdi
  80416097e8:	00 00 00 
  80416097eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097f0:	ff d3                	callq  *%rbx
  cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  80416097f2:	49 8b 74 24 30       	mov    0x30(%r12),%rsi
  80416097f7:	48 bf 10 e4 60 41 80 	movabs $0x804160e410,%rdi
  80416097fe:	00 00 00 
  8041609801:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609806:	ff d3                	callq  *%rbx
  cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  8041609808:	49 8b 74 24 38       	mov    0x38(%r12),%rsi
  804160980d:	48 bf 20 e4 60 41 80 	movabs $0x804160e420,%rdi
  8041609814:	00 00 00 
  8041609817:	b8 00 00 00 00       	mov    $0x0,%eax
  804160981c:	ff d3                	callq  *%rbx
  cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  804160981e:	49 8b 74 24 48       	mov    0x48(%r12),%rsi
  8041609823:	48 bf 30 e4 60 41 80 	movabs $0x804160e430,%rdi
  804160982a:	00 00 00 
  804160982d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609832:	ff d3                	callq  *%rbx
  cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  8041609834:	49 8b 74 24 40       	mov    0x40(%r12),%rsi
  8041609839:	48 bf 40 e4 60 41 80 	movabs $0x804160e440,%rdi
  8041609840:	00 00 00 
  8041609843:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609848:	ff d3                	callq  *%rbx
  cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  804160984a:	49 8b 74 24 50       	mov    0x50(%r12),%rsi
  804160984f:	48 bf 50 e4 60 41 80 	movabs $0x804160e450,%rdi
  8041609856:	00 00 00 
  8041609859:	b8 00 00 00 00       	mov    $0x0,%eax
  804160985e:	ff d3                	callq  *%rbx
  cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  8041609860:	49 8b 74 24 68       	mov    0x68(%r12),%rsi
  8041609865:	48 bf 60 e4 60 41 80 	movabs $0x804160e460,%rdi
  804160986c:	00 00 00 
  804160986f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609874:	ff d3                	callq  *%rbx
  cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  8041609876:	49 8b 74 24 58       	mov    0x58(%r12),%rsi
  804160987b:	48 bf 70 e4 60 41 80 	movabs $0x804160e470,%rdi
  8041609882:	00 00 00 
  8041609885:	b8 00 00 00 00       	mov    $0x0,%eax
  804160988a:	ff d3                	callq  *%rbx
  cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  804160988c:	49 8b 74 24 60       	mov    0x60(%r12),%rsi
  8041609891:	48 bf 80 e4 60 41 80 	movabs $0x804160e480,%rdi
  8041609898:	00 00 00 
  804160989b:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098a0:	ff d3                	callq  *%rbx
  cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
  80416098a2:	49 8b 74 24 70       	mov    0x70(%r12),%rsi
  80416098a7:	48 bf 90 e4 60 41 80 	movabs $0x804160e490,%rdi
  80416098ae:	00 00 00 
  80416098b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098b6:	ff d3                	callq  *%rbx
}
  80416098b8:	5b                   	pop    %rbx
  80416098b9:	41 5c                	pop    %r12
  80416098bb:	5d                   	pop    %rbp
  80416098bc:	c3                   	retq   

00000080416098bd <print_trapframe>:
print_trapframe(struct Trapframe *tf) {
  80416098bd:	55                   	push   %rbp
  80416098be:	48 89 e5             	mov    %rsp,%rbp
  80416098c1:	41 54                	push   %r12
  80416098c3:	53                   	push   %rbx
  80416098c4:	48 89 fb             	mov    %rdi,%rbx
  cprintf("TRAP frame at %p\n", tf);
  80416098c7:	48 89 fe             	mov    %rdi,%rsi
  80416098ca:	48 bf f5 e4 60 41 80 	movabs $0x804160e4f5,%rdi
  80416098d1:	00 00 00 
  80416098d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098d9:	49 bc f2 91 60 41 80 	movabs $0x80416091f2,%r12
  80416098e0:	00 00 00 
  80416098e3:	41 ff d4             	callq  *%r12
  print_regs(&tf->tf_regs);
  80416098e6:	48 89 df             	mov    %rbx,%rdi
  80416098e9:	48 b8 5c 97 60 41 80 	movabs $0x804160975c,%rax
  80416098f0:	00 00 00 
  80416098f3:	ff d0                	callq  *%rax
  cprintf("  es   0x----%04x\n", tf->tf_es);
  80416098f5:	0f b7 73 78          	movzwl 0x78(%rbx),%esi
  80416098f9:	48 bf 07 e5 60 41 80 	movabs $0x804160e507,%rdi
  8041609900:	00 00 00 
  8041609903:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609908:	41 ff d4             	callq  *%r12
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  804160990b:	0f b7 b3 80 00 00 00 	movzwl 0x80(%rbx),%esi
  8041609912:	48 bf 1a e5 60 41 80 	movabs $0x804160e51a,%rdi
  8041609919:	00 00 00 
  804160991c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609921:	41 ff d4             	callq  *%r12
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041609924:	48 8b b3 88 00 00 00 	mov    0x88(%rbx),%rsi
  if (trapno < sizeof(excnames) / sizeof(excnames[0]))
  804160992b:	83 fe 13             	cmp    $0x13,%esi
  804160992e:	0f 86 68 01 00 00    	jbe    8041609a9c <print_trapframe+0x1df>
    return "System call";
  8041609934:	48 ba a0 e4 60 41 80 	movabs $0x804160e4a0,%rdx
  804160993b:	00 00 00 
  if (trapno == T_SYSCALL)
  804160993e:	83 fe 30             	cmp    $0x30,%esi
  8041609941:	74 1e                	je     8041609961 <print_trapframe+0xa4>
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  8041609943:	8d 46 e0             	lea    -0x20(%rsi),%eax
    return "Hardware Interrupt";
  8041609946:	83 f8 0f             	cmp    $0xf,%eax
  8041609949:	48 ba ac e4 60 41 80 	movabs $0x804160e4ac,%rdx
  8041609950:	00 00 00 
  8041609953:	48 b8 bb e4 60 41 80 	movabs $0x804160e4bb,%rax
  804160995a:	00 00 00 
  804160995d:	48 0f 46 d0          	cmovbe %rax,%rdx
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041609961:	48 bf 2d e5 60 41 80 	movabs $0x804160e52d,%rdi
  8041609968:	00 00 00 
  804160996b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609970:	48 b9 f2 91 60 41 80 	movabs $0x80416091f2,%rcx
  8041609977:	00 00 00 
  804160997a:	ff d1                	callq  *%rcx
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  804160997c:	48 b8 40 55 88 41 80 	movabs $0x8041885540,%rax
  8041609983:	00 00 00 
  8041609986:	48 39 18             	cmp    %rbx,(%rax)
  8041609989:	0f 84 23 01 00 00    	je     8041609ab2 <print_trapframe+0x1f5>
  cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  804160998f:	48 8b b3 90 00 00 00 	mov    0x90(%rbx),%rsi
  8041609996:	48 bf 50 e5 60 41 80 	movabs $0x804160e550,%rdi
  804160999d:	00 00 00 
  80416099a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416099a5:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  80416099ac:	00 00 00 
  80416099af:	ff d2                	callq  *%rdx
  if (tf->tf_trapno == T_PGFLT)
  80416099b1:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  80416099b8:	0e 
  80416099b9:	0f 85 24 01 00 00    	jne    8041609ae3 <print_trapframe+0x226>
            tf->tf_err & 1 ? "protection" : "not-present");
  80416099bf:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
    cprintf(" [%s, %s, %s]\n",
  80416099c6:	48 89 c2             	mov    %rax,%rdx
  80416099c9:	83 e2 01             	and    $0x1,%edx
  80416099cc:	48 b9 ce e4 60 41 80 	movabs $0x804160e4ce,%rcx
  80416099d3:	00 00 00 
  80416099d6:	48 ba d9 e4 60 41 80 	movabs $0x804160e4d9,%rdx
  80416099dd:	00 00 00 
  80416099e0:	48 0f 44 ca          	cmove  %rdx,%rcx
  80416099e4:	48 89 c2             	mov    %rax,%rdx
  80416099e7:	83 e2 02             	and    $0x2,%edx
  80416099ea:	48 ba e5 e4 60 41 80 	movabs $0x804160e4e5,%rdx
  80416099f1:	00 00 00 
  80416099f4:	48 be eb e4 60 41 80 	movabs $0x804160e4eb,%rsi
  80416099fb:	00 00 00 
  80416099fe:	48 0f 44 d6          	cmove  %rsi,%rdx
  8041609a02:	83 e0 04             	and    $0x4,%eax
  8041609a05:	48 be f0 e4 60 41 80 	movabs $0x804160e4f0,%rsi
  8041609a0c:	00 00 00 
  8041609a0f:	48 b8 35 e6 60 41 80 	movabs $0x804160e635,%rax
  8041609a16:	00 00 00 
  8041609a19:	48 0f 44 f0          	cmove  %rax,%rsi
  8041609a1d:	48 bf 5f e5 60 41 80 	movabs $0x804160e55f,%rdi
  8041609a24:	00 00 00 
  8041609a27:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a2c:	49 b8 f2 91 60 41 80 	movabs $0x80416091f2,%r8
  8041609a33:	00 00 00 
  8041609a36:	41 ff d0             	callq  *%r8
  cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  8041609a39:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
  8041609a40:	48 bf 6e e5 60 41 80 	movabs $0x804160e56e,%rdi
  8041609a47:	00 00 00 
  8041609a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a4f:	49 bc f2 91 60 41 80 	movabs $0x80416091f2,%r12
  8041609a56:	00 00 00 
  8041609a59:	41 ff d4             	callq  *%r12
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8041609a5c:	0f b7 b3 a0 00 00 00 	movzwl 0xa0(%rbx),%esi
  8041609a63:	48 bf 7e e5 60 41 80 	movabs $0x804160e57e,%rdi
  8041609a6a:	00 00 00 
  8041609a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a72:	41 ff d4             	callq  *%r12
  cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  8041609a75:	48 8b b3 a8 00 00 00 	mov    0xa8(%rbx),%rsi
  8041609a7c:	48 bf 91 e5 60 41 80 	movabs $0x804160e591,%rdi
  8041609a83:	00 00 00 
  8041609a86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a8b:	41 ff d4             	callq  *%r12
  if ((tf->tf_cs & 3) != 0) {
  8041609a8e:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041609a95:	75 6c                	jne    8041609b03 <print_trapframe+0x246>
}
  8041609a97:	5b                   	pop    %rbx
  8041609a98:	41 5c                	pop    %r12
  8041609a9a:	5d                   	pop    %rbp
  8041609a9b:	c3                   	retq   
    return excnames[trapno];
  8041609a9c:	48 63 c6             	movslq %esi,%rax
  8041609a9f:	48 ba c0 e7 60 41 80 	movabs $0x804160e7c0,%rdx
  8041609aa6:	00 00 00 
  8041609aa9:	48 8b 14 c2          	mov    (%rdx,%rax,8),%rdx
  8041609aad:	e9 af fe ff ff       	jmpq   8041609961 <print_trapframe+0xa4>
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041609ab2:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041609ab9:	0e 
  8041609aba:	0f 85 cf fe ff ff    	jne    804160998f <print_trapframe+0xd2>
  __asm __volatile("movq %%cr2,%0"
  8041609ac0:	0f 20 d6             	mov    %cr2,%rsi
    cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  8041609ac3:	48 bf 40 e5 60 41 80 	movabs $0x804160e540,%rdi
  8041609aca:	00 00 00 
  8041609acd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ad2:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041609ad9:	00 00 00 
  8041609adc:	ff d2                	callq  *%rdx
  8041609ade:	e9 ac fe ff ff       	jmpq   804160998f <print_trapframe+0xd2>
    cprintf("\n");
  8041609ae3:	48 bf 1f e2 60 41 80 	movabs $0x804160e21f,%rdi
  8041609aea:	00 00 00 
  8041609aed:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609af2:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041609af9:	00 00 00 
  8041609afc:	ff d2                	callq  *%rdx
  8041609afe:	e9 36 ff ff ff       	jmpq   8041609a39 <print_trapframe+0x17c>
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
  8041609b03:	48 8b b3 b0 00 00 00 	mov    0xb0(%rbx),%rsi
  8041609b0a:	48 bf a1 e5 60 41 80 	movabs $0x804160e5a1,%rdi
  8041609b11:	00 00 00 
  8041609b14:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b19:	41 ff d4             	callq  *%r12
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  8041609b1c:	0f b7 b3 b8 00 00 00 	movzwl 0xb8(%rbx),%esi
  8041609b23:	48 bf b1 e5 60 41 80 	movabs $0x804160e5b1,%rdi
  8041609b2a:	00 00 00 
  8041609b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b32:	41 ff d4             	callq  *%r12
}
  8041609b35:	e9 5d ff ff ff       	jmpq   8041609a97 <print_trapframe+0x1da>

0000008041609b3a <page_fault_handler>:
  else
    sched_yield();
}

void
page_fault_handler(struct Trapframe *tf) {
  8041609b3a:	55                   	push   %rbp
  8041609b3b:	48 89 e5             	mov    %rsp,%rbp
  8041609b3e:	41 56                	push   %r14
  8041609b40:	41 55                	push   %r13
  8041609b42:	41 54                	push   %r12
  8041609b44:	53                   	push   %rbx
  8041609b45:	41 0f 20 d4          	mov    %cr2,%r12
  fault_va = rcr2();

  // Handle kernel-mode page faults.

  // LAB 8 code
  if (!(tf->tf_cs & 3)) {
  8041609b49:	f6 87 a0 00 00 00 03 	testb  $0x3,0xa0(%rdi)
  8041609b50:	74 78                	je     8041609bca <page_fault_handler+0x90>
  8041609b52:	48 89 fb             	mov    %rdi,%rbx

  // LAB 9 code
  struct UTrapframe *utf;
	uintptr_t uxrsp;

  if (curenv->env_pgfault_upcall) {
  8041609b55:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041609b5c:	00 00 00 
  8041609b5f:	48 83 b8 f8 00 00 00 	cmpq   $0x0,0xf8(%rax)
  8041609b66:	00 
  8041609b67:	0f 85 87 00 00 00    	jne    8041609bf4 <page_fault_handler+0xba>
  // LAB 9 code end

	// Destroy the environment that caused the fault.

  // LAB 8 code
	cprintf("[%08x] user fault va %08lx ip %08lx\n",
  8041609b6d:	48 8b 8f 98 00 00 00 	mov    0x98(%rdi),%rcx
  8041609b74:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041609b7a:	4c 89 e2             	mov    %r12,%rdx
  8041609b7d:	48 bf 80 e7 60 41 80 	movabs $0x804160e780,%rdi
  8041609b84:	00 00 00 
  8041609b87:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b8c:	49 b8 f2 91 60 41 80 	movabs $0x80416091f2,%r8
  8041609b93:	00 00 00 
  8041609b96:	41 ff d0             	callq  *%r8
		curenv->env_id, fault_va, tf->tf_rip);
	print_trapframe(tf);
  8041609b99:	48 89 df             	mov    %rbx,%rdi
  8041609b9c:	48 b8 bd 98 60 41 80 	movabs $0x80416098bd,%rax
  8041609ba3:	00 00 00 
  8041609ba6:	ff d0                	callq  *%rax
	env_destroy(curenv);
  8041609ba8:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609baf:	00 00 00 
  8041609bb2:	48 8b 38             	mov    (%rax),%rdi
  8041609bb5:	48 b8 b7 8d 60 41 80 	movabs $0x8041608db7,%rax
  8041609bbc:	00 00 00 
  8041609bbf:	ff d0                	callq  *%rax
  // LAB 8 code end
}
  8041609bc1:	5b                   	pop    %rbx
  8041609bc2:	41 5c                	pop    %r12
  8041609bc4:	41 5d                	pop    %r13
  8041609bc6:	41 5e                	pop    %r14
  8041609bc8:	5d                   	pop    %rbp
  8041609bc9:	c3                   	retq   
		panic("page fault in kernel!");
  8041609bca:	48 ba c4 e5 60 41 80 	movabs $0x804160e5c4,%rdx
  8041609bd1:	00 00 00 
  8041609bd4:	be 44 01 00 00       	mov    $0x144,%esi
  8041609bd9:	48 bf da e5 60 41 80 	movabs $0x804160e5da,%rdi
  8041609be0:	00 00 00 
  8041609be3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609be8:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609bef:	00 00 00 
  8041609bf2:	ff d1                	callq  *%rcx
		if (tf->tf_rsp < UXSTACKTOP && tf->tf_rsp >= UXSTACKTOP - PGSIZE) {
  8041609bf4:	48 8b 8f b0 00 00 00 	mov    0xb0(%rdi),%rcx
  8041609bfb:	48 ba 00 10 00 00 80 	movabs $0xffffff8000001000,%rdx
  8041609c02:	ff ff ff 
  8041609c05:	48 01 ca             	add    %rcx,%rdx
		uxrsp = UXSTACKTOP;
  8041609c08:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  8041609c0f:	00 00 00 
		if (tf->tf_rsp < UXSTACKTOP && tf->tf_rsp >= UXSTACKTOP - PGSIZE) {
  8041609c12:	48 81 fa ff 0f 00 00 	cmp    $0xfff,%rdx
  8041609c19:	77 04                	ja     8041609c1f <page_fault_handler+0xe5>
			uxrsp = tf->tf_rsp - sizeof(uintptr_t);
  8041609c1b:	4c 8d 69 f8          	lea    -0x8(%rcx),%r13
		uxrsp -= sizeof(struct UTrapframe);
  8041609c1f:	4d 8d b5 60 ff ff ff 	lea    -0xa0(%r13),%r14
		user_mem_assert(curenv, utf, sizeof (struct UTrapframe), PTE_W);
  8041609c26:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041609c2b:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041609c30:	4c 89 f6             	mov    %r14,%rsi
  8041609c33:	48 89 c7             	mov    %rax,%rdi
  8041609c36:	48 b8 7e 84 60 41 80 	movabs $0x804160847e,%rax
  8041609c3d:	00 00 00 
  8041609c40:	ff d0                	callq  *%rax
		utf->utf_fault_va = fault_va;
  8041609c42:	4d 89 a5 60 ff ff ff 	mov    %r12,-0xa0(%r13)
		utf->utf_err = tf->tf_err;
  8041609c49:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
  8041609c50:	49 89 85 68 ff ff ff 	mov    %rax,-0x98(%r13)
		utf->utf_regs = tf->tf_regs;
  8041609c57:	49 8d 7e 10          	lea    0x10(%r14),%rdi
  8041609c5b:	b9 1e 00 00 00       	mov    $0x1e,%ecx
  8041609c60:	48 89 de             	mov    %rbx,%rsi
  8041609c63:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
		utf->utf_rip = tf->tf_rip;
  8041609c65:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
  8041609c6c:	49 89 45 e8          	mov    %rax,-0x18(%r13)
		utf->utf_rflags = tf->tf_rflags;
  8041609c70:	48 8b 83 a8 00 00 00 	mov    0xa8(%rbx),%rax
  8041609c77:	49 89 45 f0          	mov    %rax,-0x10(%r13)
		utf->utf_rsp = tf->tf_rsp;
  8041609c7b:	48 8b 83 b0 00 00 00 	mov    0xb0(%rbx),%rax
  8041609c82:	49 89 45 f8          	mov    %rax,-0x8(%r13)
		tf->tf_rsp = uxrsp;
  8041609c86:	4c 89 b3 b0 00 00 00 	mov    %r14,0xb0(%rbx)
		tf->tf_rip = (uintptr_t)curenv->env_pgfault_upcall;
  8041609c8d:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609c94:	00 00 00 
  8041609c97:	48 8b 38             	mov    (%rax),%rdi
  8041609c9a:	48 8b 87 f8 00 00 00 	mov    0xf8(%rdi),%rax
  8041609ca1:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
		env_run(curenv);
  8041609ca8:	48 b8 8b 8e 60 41 80 	movabs $0x8041608e8b,%rax
  8041609caf:	00 00 00 
  8041609cb2:	ff d0                	callq  *%rax

0000008041609cb4 <trap>:
trap(struct Trapframe *tf) {
  8041609cb4:	55                   	push   %rbp
  8041609cb5:	48 89 e5             	mov    %rsp,%rbp
  8041609cb8:	53                   	push   %rbx
  8041609cb9:	48 83 ec 08          	sub    $0x8,%rsp
  8041609cbd:	48 89 fe             	mov    %rdi,%rsi
  asm volatile("cld" ::
  8041609cc0:	fc                   	cld    
  if (panicstr)
  8041609cc1:	48 b8 80 42 88 41 80 	movabs $0x8041884280,%rax
  8041609cc8:	00 00 00 
  8041609ccb:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609ccf:	74 01                	je     8041609cd2 <trap+0x1e>
    asm volatile("hlt");
  8041609cd1:	f4                   	hlt    
  __asm __volatile("pushfq; popq %0"
  8041609cd2:	9c                   	pushfq 
  8041609cd3:	58                   	pop    %rax
  assert(!(read_rflags() & FL_IF));
  8041609cd4:	f6 c4 02             	test   $0x2,%ah
  8041609cd7:	0f 85 da 00 00 00    	jne    8041609db7 <trap+0x103>
  assert(curenv);
  8041609cdd:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041609ce4:	00 00 00 
  8041609ce7:	48 85 c0             	test   %rax,%rax
  8041609cea:	0f 84 fc 00 00 00    	je     8041609dec <trap+0x138>
  if (curenv->env_status == ENV_DYING) {
  8041609cf0:	83 b8 d4 00 00 00 01 	cmpl   $0x1,0xd4(%rax)
  8041609cf7:	0f 84 1f 01 00 00    	je     8041609e1c <trap+0x168>
  curenv->env_tf = *tf;
  8041609cfd:	b9 30 00 00 00       	mov    $0x30,%ecx
  8041609d02:	48 89 c7             	mov    %rax,%rdi
  8041609d05:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  tf = &curenv->env_tf;
  8041609d07:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609d0e:	00 00 00 
  8041609d11:	48 8b 18             	mov    (%rax),%rbx
  last_tf = tf;
  8041609d14:	48 89 d8             	mov    %rbx,%rax
  8041609d17:	48 a3 40 55 88 41 80 	movabs %rax,0x8041885540
  8041609d1e:	00 00 00 
  if (tf->tf_trapno == T_SYSCALL) {
  8041609d21:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  8041609d28:	48 83 f8 30          	cmp    $0x30,%rax
  8041609d2c:	0f 84 16 01 00 00    	je     8041609e48 <trap+0x194>
  if (tf->tf_trapno == T_PGFLT) {
  8041609d32:	48 83 f8 0e          	cmp    $0xe,%rax
  8041609d36:	0f 84 39 01 00 00    	je     8041609e75 <trap+0x1c1>
  if (tf->tf_trapno == T_BRKPT) {
  8041609d3c:	48 83 f8 03          	cmp    $0x3,%rax
  8041609d40:	0f 84 43 01 00 00    	je     8041609e89 <trap+0x1d5>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
  8041609d46:	48 83 f8 27          	cmp    $0x27,%rax
  8041609d4a:	0f 84 4d 01 00 00    	je     8041609e9d <trap+0x1e9>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {
  8041609d50:	48 83 f8 28          	cmp    $0x28,%rax
  8041609d54:	0f 84 63 01 00 00    	je     8041609ebd <trap+0x209>
  print_trapframe(tf);
  8041609d5a:	48 89 df             	mov    %rbx,%rdi
  8041609d5d:	48 b8 bd 98 60 41 80 	movabs $0x80416098bd,%rax
  8041609d64:	00 00 00 
  8041609d67:	ff d0                	callq  *%rax
  if (!(tf->tf_cs & 0x3)) {
  8041609d69:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041609d70:	0f 84 60 01 00 00    	je     8041609ed6 <trap+0x222>
    env_destroy(curenv);
  8041609d76:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609d7d:	00 00 00 
  8041609d80:	48 8b 38             	mov    (%rax),%rdi
  8041609d83:	48 b8 b7 8d 60 41 80 	movabs $0x8041608db7,%rax
  8041609d8a:	00 00 00 
  8041609d8d:	ff d0                	callq  *%rax
  if (curenv && curenv->env_status == ENV_RUNNING)
  8041609d8f:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041609d96:	00 00 00 
  8041609d99:	48 85 c0             	test   %rax,%rax
  8041609d9c:	74 0d                	je     8041609dab <trap+0xf7>
  8041609d9e:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  8041609da5:	0f 84 55 01 00 00    	je     8041609f00 <trap+0x24c>
    sched_yield();
  8041609dab:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  8041609db2:	00 00 00 
  8041609db5:	ff d0                	callq  *%rax
  assert(!(read_rflags() & FL_IF));
  8041609db7:	48 b9 e6 e5 60 41 80 	movabs $0x804160e5e6,%rcx
  8041609dbe:	00 00 00 
  8041609dc1:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041609dc8:	00 00 00 
  8041609dcb:	be 11 01 00 00       	mov    $0x111,%esi
  8041609dd0:	48 bf da e5 60 41 80 	movabs $0x804160e5da,%rdi
  8041609dd7:	00 00 00 
  8041609dda:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ddf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609de6:	00 00 00 
  8041609de9:	41 ff d0             	callq  *%r8
  assert(curenv);
  8041609dec:	48 b9 ff e5 60 41 80 	movabs $0x804160e5ff,%rcx
  8041609df3:	00 00 00 
  8041609df6:	48 ba b9 cf 60 41 80 	movabs $0x804160cfb9,%rdx
  8041609dfd:	00 00 00 
  8041609e00:	be 19 01 00 00       	mov    $0x119,%esi
  8041609e05:	48 bf da e5 60 41 80 	movabs $0x804160e5da,%rdi
  8041609e0c:	00 00 00 
  8041609e0f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609e16:	00 00 00 
  8041609e19:	41 ff d0             	callq  *%r8
    env_free(curenv);
  8041609e1c:	48 89 c7             	mov    %rax,%rdi
  8041609e1f:	48 b8 ac 8a 60 41 80 	movabs $0x8041608aac,%rax
  8041609e26:	00 00 00 
  8041609e29:	ff d0                	callq  *%rax
    curenv = NULL;
  8041609e2b:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609e32:	00 00 00 
  8041609e35:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    sched_yield();
  8041609e3c:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  8041609e43:	00 00 00 
  8041609e46:	ff d0                	callq  *%rax
    ret                 = syscall(syscallno, a1, a2, a3, a4, a5);
  8041609e48:	48 8b 4b 68          	mov    0x68(%rbx),%rcx
  8041609e4c:	48 8b 53 60          	mov    0x60(%rbx),%rdx
  8041609e50:	48 8b 73 58          	mov    0x58(%rbx),%rsi
  8041609e54:	48 8b 7b 70          	mov    0x70(%rbx),%rdi
  8041609e58:	4c 8b 4b 40          	mov    0x40(%rbx),%r9
  8041609e5c:	4c 8b 43 48          	mov    0x48(%rbx),%r8
  8041609e60:	48 b8 b9 ad 60 41 80 	movabs $0x804160adb9,%rax
  8041609e67:	00 00 00 
  8041609e6a:	ff d0                	callq  *%rax
    tf->tf_regs.reg_rax = ret;
  8041609e6c:	48 89 43 70          	mov    %rax,0x70(%rbx)
    return;
  8041609e70:	e9 1a ff ff ff       	jmpq   8041609d8f <trap+0xdb>
    page_fault_handler(tf);
  8041609e75:	48 89 df             	mov    %rbx,%rdi
  8041609e78:	48 b8 3a 9b 60 41 80 	movabs $0x8041609b3a,%rax
  8041609e7f:	00 00 00 
  8041609e82:	ff d0                	callq  *%rax
    return;
  8041609e84:	e9 06 ff ff ff       	jmpq   8041609d8f <trap+0xdb>
    monitor(tf);
  8041609e89:	48 89 df             	mov    %rbx,%rdi
  8041609e8c:	48 b8 ee 3e 60 41 80 	movabs $0x8041603eee,%rax
  8041609e93:	00 00 00 
  8041609e96:	ff d0                	callq  *%rax
    return;
  8041609e98:	e9 f2 fe ff ff       	jmpq   8041609d8f <trap+0xdb>
    cprintf("Spurious interrupt on irq 7\n");
  8041609e9d:	48 bf 06 e6 60 41 80 	movabs $0x804160e606,%rdi
  8041609ea4:	00 00 00 
  8041609ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609eac:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  8041609eb3:	00 00 00 
  8041609eb6:	ff d2                	callq  *%rdx
    return;
  8041609eb8:	e9 d2 fe ff ff       	jmpq   8041609d8f <trap+0xdb>
    timer_for_schedule->handle_interrupts();
  8041609ebd:	48 a1 60 5a 88 41 80 	movabs 0x8041885a60,%rax
  8041609ec4:	00 00 00 
  8041609ec7:	ff 50 20             	callq  *0x20(%rax)
    sched_yield();
  8041609eca:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  8041609ed1:	00 00 00 
  8041609ed4:	ff d0                	callq  *%rax
    panic("unhandled trap in kernel");
  8041609ed6:	48 ba 23 e6 60 41 80 	movabs $0x804160e623,%rdx
  8041609edd:	00 00 00 
  8041609ee0:	be fc 00 00 00       	mov    $0xfc,%esi
  8041609ee5:	48 bf da e5 60 41 80 	movabs $0x804160e5da,%rdi
  8041609eec:	00 00 00 
  8041609eef:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ef4:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609efb:	00 00 00 
  8041609efe:	ff d1                	callq  *%rcx
    env_run(curenv);
  8041609f00:	48 89 c7             	mov    %rax,%rdi
  8041609f03:	48 b8 8b 8e 60 41 80 	movabs $0x8041608e8b,%rax
  8041609f0a:	00 00 00 
  8041609f0d:	ff d0                	callq  *%rax
  8041609f0f:	90                   	nop

0000008041609f10 <_alltraps>:

.globl _alltraps
.type _alltraps, @function;
.align 2
_alltraps:
  subq $8,%rsp
  8041609f10:	48 83 ec 08          	sub    $0x8,%rsp
  movw %ds,(%rsp)
  8041609f14:	8c 1c 24             	mov    %ds,(%rsp)
  subq $8,%rsp
  8041609f17:	48 83 ec 08          	sub    $0x8,%rsp
  movw %es,(%rsp)
  8041609f1b:	8c 04 24             	mov    %es,(%rsp)
  PUSHA
  8041609f1e:	48 83 ec 78          	sub    $0x78,%rsp
  8041609f22:	48 89 44 24 70       	mov    %rax,0x70(%rsp)
  8041609f27:	48 89 5c 24 68       	mov    %rbx,0x68(%rsp)
  8041609f2c:	48 89 4c 24 60       	mov    %rcx,0x60(%rsp)
  8041609f31:	48 89 54 24 58       	mov    %rdx,0x58(%rsp)
  8041609f36:	48 89 6c 24 50       	mov    %rbp,0x50(%rsp)
  8041609f3b:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
  8041609f40:	48 89 74 24 40       	mov    %rsi,0x40(%rsp)
  8041609f45:	4c 89 44 24 38       	mov    %r8,0x38(%rsp)
  8041609f4a:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
  8041609f4f:	4c 89 54 24 28       	mov    %r10,0x28(%rsp)
  8041609f54:	4c 89 5c 24 20       	mov    %r11,0x20(%rsp)
  8041609f59:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
  8041609f5e:	4c 89 6c 24 10       	mov    %r13,0x10(%rsp)
  8041609f63:	4c 89 74 24 08       	mov    %r14,0x8(%rsp)
  8041609f68:	4c 89 3c 24          	mov    %r15,(%rsp)
  movq $GD_KD,%rax
  8041609f6c:	48 c7 c0 10 00 00 00 	mov    $0x10,%rax
  movq %rax,%ds
  8041609f73:	48 8e d8             	mov    %rax,%ds
  movq %rax,%es
  8041609f76:	48 8e c0             	mov    %rax,%es
  movq %rsp,%rdi
  8041609f79:	48 89 e7             	mov    %rsp,%rdi
  call trap
  8041609f7c:	e8 33 fd ff ff       	callq  8041609cb4 <trap>
  jmp .
  8041609f81:	eb fe                	jmp    8041609f81 <_alltraps+0x71>
  8041609f83:	90                   	nop

0000008041609f84 <clock_thdlr>:
  xorl %ebp, %ebp
  movq %rsp,%rdi
  call trap
  jmp .
#else
TRAPHANDLER_NOEC(clock_thdlr, IRQ_OFFSET + IRQ_CLOCK)
  8041609f84:	6a 00                	pushq  $0x0
  8041609f86:	6a 28                	pushq  $0x28
  8041609f88:	eb 86                	jmp    8041609f10 <_alltraps>

0000008041609f8a <divide_thdlr>:
// LAB 8 code
TRAPHANDLER_NOEC(divide_thdlr, T_DIVIDE)
  8041609f8a:	6a 00                	pushq  $0x0
  8041609f8c:	6a 00                	pushq  $0x0
  8041609f8e:	eb 80                	jmp    8041609f10 <_alltraps>

0000008041609f90 <debug_thdlr>:
TRAPHANDLER_NOEC(debug_thdlr, T_DEBUG)
  8041609f90:	6a 00                	pushq  $0x0
  8041609f92:	6a 01                	pushq  $0x1
  8041609f94:	e9 77 ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609f99:	90                   	nop

0000008041609f9a <nmi_thdlr>:
TRAPHANDLER_NOEC(nmi_thdlr, T_NMI)
  8041609f9a:	6a 00                	pushq  $0x0
  8041609f9c:	6a 02                	pushq  $0x2
  8041609f9e:	e9 6d ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fa3:	90                   	nop

0000008041609fa4 <brkpt_thdlr>:
TRAPHANDLER_NOEC(brkpt_thdlr, T_BRKPT)
  8041609fa4:	6a 00                	pushq  $0x0
  8041609fa6:	6a 03                	pushq  $0x3
  8041609fa8:	e9 63 ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fad:	90                   	nop

0000008041609fae <oflow_thdlr>:
TRAPHANDLER_NOEC(oflow_thdlr, T_OFLOW)
  8041609fae:	6a 00                	pushq  $0x0
  8041609fb0:	6a 04                	pushq  $0x4
  8041609fb2:	e9 59 ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fb7:	90                   	nop

0000008041609fb8 <bound_thdlr>:
TRAPHANDLER_NOEC(bound_thdlr, T_BOUND)
  8041609fb8:	6a 00                	pushq  $0x0
  8041609fba:	6a 05                	pushq  $0x5
  8041609fbc:	e9 4f ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fc1:	90                   	nop

0000008041609fc2 <illop_thdlr>:
TRAPHANDLER_NOEC(illop_thdlr, T_ILLOP)
  8041609fc2:	6a 00                	pushq  $0x0
  8041609fc4:	6a 06                	pushq  $0x6
  8041609fc6:	e9 45 ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fcb:	90                   	nop

0000008041609fcc <device_thdlr>:
TRAPHANDLER_NOEC(device_thdlr, T_DEVICE)
  8041609fcc:	6a 00                	pushq  $0x0
  8041609fce:	6a 07                	pushq  $0x7
  8041609fd0:	e9 3b ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fd5:	90                   	nop

0000008041609fd6 <dblflt_thdlr>:
TRAPHANDLER(dblflt_thdlr, T_DBLFLT)
  8041609fd6:	6a 08                	pushq  $0x8
  8041609fd8:	e9 33 ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fdd:	90                   	nop

0000008041609fde <tss_thdlr>:
TRAPHANDLER(tss_thdlr, T_TSS)
  8041609fde:	6a 0a                	pushq  $0xa
  8041609fe0:	e9 2b ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fe5:	90                   	nop

0000008041609fe6 <segnp_thdlr>:
TRAPHANDLER(segnp_thdlr, T_SEGNP)
  8041609fe6:	6a 0b                	pushq  $0xb
  8041609fe8:	e9 23 ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609fed:	90                   	nop

0000008041609fee <stack_thdlr>:
TRAPHANDLER(stack_thdlr, T_STACK)
  8041609fee:	6a 0c                	pushq  $0xc
  8041609ff0:	e9 1b ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609ff5:	90                   	nop

0000008041609ff6 <gpflt_thdlr>:
TRAPHANDLER(gpflt_thdlr, T_GPFLT)
  8041609ff6:	6a 0d                	pushq  $0xd
  8041609ff8:	e9 13 ff ff ff       	jmpq   8041609f10 <_alltraps>
  8041609ffd:	90                   	nop

0000008041609ffe <pgflt_thdlr>:
TRAPHANDLER(pgflt_thdlr, T_PGFLT)
  8041609ffe:	6a 0e                	pushq  $0xe
  804160a000:	e9 0b ff ff ff       	jmpq   8041609f10 <_alltraps>
  804160a005:	90                   	nop

000000804160a006 <fperr_thdlr>:
TRAPHANDLER_NOEC(fperr_thdlr, T_FPERR)
  804160a006:	6a 00                	pushq  $0x0
  804160a008:	6a 10                	pushq  $0x10
  804160a00a:	e9 01 ff ff ff       	jmpq   8041609f10 <_alltraps>
  804160a00f:	90                   	nop

000000804160a010 <align_thdlr>:
TRAPHANDLER(align_thdlr, T_ALIGN)
  804160a010:	6a 11                	pushq  $0x11
  804160a012:	e9 f9 fe ff ff       	jmpq   8041609f10 <_alltraps>
  804160a017:	90                   	nop

000000804160a018 <mchk_thdlr>:
TRAPHANDLER_NOEC(mchk_thdlr, T_MCHK)
  804160a018:	6a 00                	pushq  $0x0
  804160a01a:	6a 12                	pushq  $0x12
  804160a01c:	e9 ef fe ff ff       	jmpq   8041609f10 <_alltraps>
  804160a021:	90                   	nop

000000804160a022 <simderr_thdlr>:
TRAPHANDLER_NOEC(simderr_thdlr, T_SIMDERR)
  804160a022:	6a 00                	pushq  $0x0
  804160a024:	6a 13                	pushq  $0x13
  804160a026:	e9 e5 fe ff ff       	jmpq   8041609f10 <_alltraps>
  804160a02b:	90                   	nop

000000804160a02c <syscall_thdlr>:
TRAPHANDLER_NOEC(syscall_thdlr, T_SYSCALL)
  804160a02c:	6a 00                	pushq  $0x0
  804160a02e:	6a 30                	pushq  $0x30
  804160a030:	e9 db fe ff ff       	jmpq   8041609f10 <_alltraps>

000000804160a035 <acpi_find_table>:
  return krsdp;
}

// LAB 5 code
static void *
acpi_find_table(const char *sign) {
  804160a035:	55                   	push   %rbp
  804160a036:	48 89 e5             	mov    %rsp,%rbp
  804160a039:	41 57                	push   %r15
  804160a03b:	41 56                	push   %r14
  804160a03d:	41 55                	push   %r13
  804160a03f:	41 54                	push   %r12
  804160a041:	53                   	push   %rbx
  804160a042:	48 83 ec 28          	sub    $0x28,%rsp
  804160a046:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  static size_t krsdt_len;
  static size_t krsdt_entsz;

  uint8_t cksm = 0;

  if (!krsdt) {
  804160a04a:	48 b8 e0 55 88 41 80 	movabs $0x80418855e0,%rax
  804160a051:	00 00 00 
  804160a054:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a058:	74 3d                	je     804160a097 <acpi_find_table+0x62>
    }
  }

  ACPISDTHeader *hd = NULL;

  for (size_t i = 0; i < krsdt_len; i++) {
  804160a05a:	48 b8 d0 55 88 41 80 	movabs $0x80418855d0,%rax
  804160a061:	00 00 00 
  804160a064:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a068:	0f 84 f2 03 00 00    	je     804160a460 <acpi_find_table+0x42b>
  804160a06e:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    /* Assume little endian */
    uint64_t fadt_pa = 0;
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  804160a074:	49 bf d8 55 88 41 80 	movabs $0x80418855d8,%r15
  804160a07b:	00 00 00 
  804160a07e:	49 bd e0 55 88 41 80 	movabs $0x80418855e0,%r13
  804160a085:	00 00 00 
  804160a088:	49 be 4a c5 60 41 80 	movabs $0x804160c54a,%r14
  804160a08f:	00 00 00 
  804160a092:	e9 04 03 00 00       	jmpq   804160a39b <acpi_find_table+0x366>
    if (!uefi_lp->ACPIRoot) {
  804160a097:	48 a1 00 00 62 41 80 	movabs 0x8041620000,%rax
  804160a09e:	00 00 00 
  804160a0a1:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160a0a5:	48 85 ff             	test   %rdi,%rdi
  804160a0a8:	74 7c                	je     804160a126 <acpi_find_table+0xf1>
    RSDP *krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  804160a0aa:	be 24 00 00 00       	mov    $0x24,%esi
  804160a0af:	48 b8 91 82 60 41 80 	movabs $0x8041608291,%rax
  804160a0b6:	00 00 00 
  804160a0b9:	ff d0                	callq  *%rax
  804160a0bb:	49 89 c4             	mov    %rax,%r12
    if (strncmp(krsdp->Signature, "RSD PTR", 8))
  804160a0be:	ba 08 00 00 00       	mov    $0x8,%edx
  804160a0c3:	48 be 7b e8 60 41 80 	movabs $0x804160e87b,%rsi
  804160a0ca:	00 00 00 
  804160a0cd:	48 89 c7             	mov    %rax,%rdi
  804160a0d0:	48 b8 07 c4 60 41 80 	movabs $0x804160c407,%rax
  804160a0d7:	00 00 00 
  804160a0da:	ff d0                	callq  *%rax
  804160a0dc:	85 c0                	test   %eax,%eax
  804160a0de:	74 70                	je     804160a150 <acpi_find_table+0x11b>
  804160a0e0:	4c 89 e0             	mov    %r12,%rax
  804160a0e3:	49 8d 54 24 14       	lea    0x14(%r12),%rdx
  uint8_t cksm = 0;
  804160a0e8:	bb 00 00 00 00       	mov    $0x0,%ebx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160a0ed:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < offsetof(RSDP, Length); i++)
  804160a0ef:	48 83 c0 01          	add    $0x1,%rax
  804160a0f3:	48 39 d0             	cmp    %rdx,%rax
  804160a0f6:	75 f5                	jne    804160a0ed <acpi_find_table+0xb8>
    if (cksm)
  804160a0f8:	84 db                	test   %bl,%bl
  804160a0fa:	74 59                	je     804160a155 <acpi_find_table+0x120>
      panic("Invalid RSDP");
  804160a0fc:	48 ba 83 e8 60 41 80 	movabs $0x804160e883,%rdx
  804160a103:	00 00 00 
  804160a106:	be 7f 00 00 00       	mov    $0x7f,%esi
  804160a10b:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a112:	00 00 00 
  804160a115:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a11a:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a121:	00 00 00 
  804160a124:	ff d1                	callq  *%rcx
      panic("No rsdp\n");
  804160a126:	48 ba 65 e8 60 41 80 	movabs $0x804160e865,%rdx
  804160a12d:	00 00 00 
  804160a130:	be 75 00 00 00       	mov    $0x75,%esi
  804160a135:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a13c:	00 00 00 
  804160a13f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a144:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a14b:	00 00 00 
  804160a14e:	ff d1                	callq  *%rcx
  uint8_t cksm = 0;
  804160a150:	bb 00 00 00 00       	mov    $0x0,%ebx
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  804160a155:	45 8b 74 24 10       	mov    0x10(%r12),%r14d
    krsdt_entsz      = 4;
  804160a15a:	48 b8 d8 55 88 41 80 	movabs $0x80418855d8,%rax
  804160a161:	00 00 00 
  804160a164:	48 c7 00 04 00 00 00 	movq   $0x4,(%rax)
    if (krsdp->Revision) {
  804160a16b:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a171:	0f 84 1b 01 00 00    	je     804160a292 <acpi_find_table+0x25d>
      for (size_t i = 0; i < krsdp->Length; i++)
  804160a177:	41 8b 54 24 14       	mov    0x14(%r12),%edx
  804160a17c:	48 85 d2             	test   %rdx,%rdx
  804160a17f:	74 11                	je     804160a192 <acpi_find_table+0x15d>
  804160a181:	4c 89 e0             	mov    %r12,%rax
  804160a184:	4c 01 e2             	add    %r12,%rdx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160a187:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < krsdp->Length; i++)
  804160a189:	48 83 c0 01          	add    $0x1,%rax
  804160a18d:	48 39 c2             	cmp    %rax,%rdx
  804160a190:	75 f5                	jne    804160a187 <acpi_find_table+0x152>
      if (cksm)
  804160a192:	84 db                	test   %bl,%bl
  804160a194:	0f 85 4c 01 00 00    	jne    804160a2e6 <acpi_find_table+0x2b1>
      rsdt_pa     = krsdp->XsdtAddress;
  804160a19a:	4d 8b 74 24 18       	mov    0x18(%r12),%r14
      krsdt_entsz = 8;
  804160a19f:	48 b8 d8 55 88 41 80 	movabs $0x80418855d8,%rax
  804160a1a6:	00 00 00 
  804160a1a9:	48 c7 00 08 00 00 00 	movq   $0x8,(%rax)
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  804160a1b0:	be 24 00 00 00       	mov    $0x24,%esi
  804160a1b5:	4c 89 f7             	mov    %r14,%rdi
  804160a1b8:	48 b8 91 82 60 41 80 	movabs $0x8041608291,%rax
  804160a1bf:	00 00 00 
  804160a1c2:	ff d0                	callq  *%rax
  804160a1c4:	49 bd e0 55 88 41 80 	movabs $0x80418855e0,%r13
  804160a1cb:	00 00 00 
  804160a1ce:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  804160a1d2:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a1d5:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a1da:	48 89 c6             	mov    %rax,%rsi
  804160a1dd:	4c 89 f7             	mov    %r14,%rdi
  804160a1e0:	48 b8 47 83 60 41 80 	movabs $0x8041608347,%rax
  804160a1e7:	00 00 00 
  804160a1ea:	ff d0                	callq  *%rax
  804160a1ec:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a1f0:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a1f3:	48 85 c9             	test   %rcx,%rcx
  804160a1f6:	74 19                	je     804160a211 <acpi_find_table+0x1dc>
  804160a1f8:	48 89 c2             	mov    %rax,%rdx
  804160a1fb:	48 01 c1             	add    %rax,%rcx
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdt)[i]);
  804160a1fe:	02 1a                	add    (%rdx),%bl
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a200:	48 83 c2 01          	add    $0x1,%rdx
  804160a204:	48 39 d1             	cmp    %rdx,%rcx
  804160a207:	75 f5                	jne    804160a1fe <acpi_find_table+0x1c9>
    if (cksm)
  804160a209:	84 db                	test   %bl,%bl
  804160a20b:	0f 85 ff 00 00 00    	jne    804160a310 <acpi_find_table+0x2db>
    if (strncmp(krsdt->h.Signature, krsdp->Revision ? "XSDT" : "RSDT", 4))
  804160a211:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a217:	48 be 60 e8 60 41 80 	movabs $0x804160e860,%rsi
  804160a21e:	00 00 00 
  804160a221:	48 ba 98 e8 60 41 80 	movabs $0x804160e898,%rdx
  804160a228:	00 00 00 
  804160a22b:	48 0f 44 f2          	cmove  %rdx,%rsi
  804160a22f:	ba 04 00 00 00       	mov    $0x4,%edx
  804160a234:	48 89 c7             	mov    %rax,%rdi
  804160a237:	48 b8 07 c4 60 41 80 	movabs $0x804160c407,%rax
  804160a23e:	00 00 00 
  804160a241:	ff d0                	callq  *%rax
  804160a243:	85 c0                	test   %eax,%eax
  804160a245:	0f 85 ef 00 00 00    	jne    804160a33a <acpi_find_table+0x305>
    krsdt_len = (krsdt->h.Length - sizeof(RSDT)) / 4;
  804160a24b:	48 a1 e0 55 88 41 80 	movabs 0x80418855e0,%rax
  804160a252:	00 00 00 
  804160a255:	8b 40 04             	mov    0x4(%rax),%eax
  804160a258:	48 8d 58 dc          	lea    -0x24(%rax),%rbx
  804160a25c:	48 89 da             	mov    %rbx,%rdx
  804160a25f:	48 c1 ea 02          	shr    $0x2,%rdx
  804160a263:	48 89 d0             	mov    %rdx,%rax
  804160a266:	48 a3 d0 55 88 41 80 	movabs %rax,0x80418855d0
  804160a26d:	00 00 00 
    if (krsdp->Revision) {
  804160a270:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a276:	0f 84 de fd ff ff    	je     804160a05a <acpi_find_table+0x25>
      krsdt_len = krsdt_len / 2;
  804160a27c:	48 89 d8             	mov    %rbx,%rax
  804160a27f:	48 c1 e8 03          	shr    $0x3,%rax
  804160a283:	48 a3 d0 55 88 41 80 	movabs %rax,0x80418855d0
  804160a28a:	00 00 00 
  804160a28d:	e9 c8 fd ff ff       	jmpq   804160a05a <acpi_find_table+0x25>
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  804160a292:	45 89 f6             	mov    %r14d,%r14d
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  804160a295:	be 24 00 00 00       	mov    $0x24,%esi
  804160a29a:	4c 89 f7             	mov    %r14,%rdi
  804160a29d:	48 b8 91 82 60 41 80 	movabs $0x8041608291,%rax
  804160a2a4:	00 00 00 
  804160a2a7:	ff d0                	callq  *%rax
  804160a2a9:	49 bd e0 55 88 41 80 	movabs $0x80418855e0,%r13
  804160a2b0:	00 00 00 
  804160a2b3:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  804160a2b7:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a2ba:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a2bf:	48 89 c6             	mov    %rax,%rsi
  804160a2c2:	4c 89 f7             	mov    %r14,%rdi
  804160a2c5:	48 b8 47 83 60 41 80 	movabs $0x8041608347,%rax
  804160a2cc:	00 00 00 
  804160a2cf:	ff d0                	callq  *%rax
  804160a2d1:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a2d5:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a2d8:	48 85 c9             	test   %rcx,%rcx
  804160a2db:	0f 85 17 ff ff ff    	jne    804160a1f8 <acpi_find_table+0x1c3>
  804160a2e1:	e9 23 ff ff ff       	jmpq   804160a209 <acpi_find_table+0x1d4>
        panic("Invalid RSDP");
  804160a2e6:	48 ba 83 e8 60 41 80 	movabs $0x804160e883,%rdx
  804160a2ed:	00 00 00 
  804160a2f0:	be 89 00 00 00       	mov    $0x89,%esi
  804160a2f5:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a2fc:	00 00 00 
  804160a2ff:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a304:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a30b:	00 00 00 
  804160a30e:	ff d1                	callq  *%rcx
      panic("Invalid RSDP");
  804160a310:	48 ba 83 e8 60 41 80 	movabs $0x804160e883,%rdx
  804160a317:	00 00 00 
  804160a31a:	be 97 00 00 00       	mov    $0x97,%esi
  804160a31f:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a326:	00 00 00 
  804160a329:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a32e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a335:	00 00 00 
  804160a338:	ff d1                	callq  *%rcx
      panic("Invalid RSDT");
  804160a33a:	48 ba 90 e8 60 41 80 	movabs $0x804160e890,%rdx
  804160a341:	00 00 00 
  804160a344:	be 9a 00 00 00       	mov    $0x9a,%esi
  804160a349:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a350:	00 00 00 
  804160a353:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a358:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a35f:	00 00 00 
  804160a362:	ff d1                	callq  *%rcx

    for (size_t i = 0; i < hd->Length; i++)
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
    if (cksm)
      panic("ACPI table '%.4s' invalid", hd->Signature);
    if (!strncmp(hd->Signature, sign, 4))
  804160a364:	ba 04 00 00 00       	mov    $0x4,%edx
  804160a369:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160a36d:	48 89 df             	mov    %rbx,%rdi
  804160a370:	48 b8 07 c4 60 41 80 	movabs $0x804160c407,%rax
  804160a377:	00 00 00 
  804160a37a:	ff d0                	callq  *%rax
  804160a37c:	85 c0                	test   %eax,%eax
  804160a37e:	0f 84 ca 00 00 00    	je     804160a44e <acpi_find_table+0x419>
  for (size_t i = 0; i < krsdt_len; i++) {
  804160a384:	49 83 c4 01          	add    $0x1,%r12
  804160a388:	48 b8 d0 55 88 41 80 	movabs $0x80418855d0,%rax
  804160a38f:	00 00 00 
  804160a392:	4c 39 20             	cmp    %r12,(%rax)
  804160a395:	0f 86 ae 00 00 00    	jbe    804160a449 <acpi_find_table+0x414>
    uint64_t fadt_pa = 0;
  804160a39b:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160a3a2:	00 
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  804160a3a3:	49 8b 17             	mov    (%r15),%rdx
  804160a3a6:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  804160a3aa:	48 89 d0             	mov    %rdx,%rax
  804160a3ad:	49 0f af c4          	imul   %r12,%rax
  804160a3b1:	48 8d 74 01 24       	lea    0x24(%rcx,%rax,1),%rsi
  804160a3b6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160a3ba:	41 ff d6             	callq  *%r14
    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
  804160a3bd:	be 24 00 00 00       	mov    $0x24,%esi
  804160a3c2:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160a3c6:	48 b8 91 82 60 41 80 	movabs $0x8041608291,%rax
  804160a3cd:	00 00 00 
  804160a3d0:	ff d0                	callq  *%rax
    hd = mmio_remap_last_region(fadt_pa, hd, sizeof(ACPISDTHeader), krsdt->h.Length);
  804160a3d2:	49 8b 55 00          	mov    0x0(%r13),%rdx
  804160a3d6:	8b 4a 04             	mov    0x4(%rdx),%ecx
  804160a3d9:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a3de:	48 89 c6             	mov    %rax,%rsi
  804160a3e1:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160a3e5:	48 b8 47 83 60 41 80 	movabs $0x8041608347,%rax
  804160a3ec:	00 00 00 
  804160a3ef:	ff d0                	callq  *%rax
  804160a3f1:	48 89 c3             	mov    %rax,%rbx
    for (size_t i = 0; i < hd->Length; i++)
  804160a3f4:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a3f7:	48 85 c9             	test   %rcx,%rcx
  804160a3fa:	0f 84 64 ff ff ff    	je     804160a364 <acpi_find_table+0x32f>
  804160a400:	48 01 c1             	add    %rax,%rcx
  804160a403:	ba 00 00 00 00       	mov    $0x0,%edx
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
  804160a408:	02 10                	add    (%rax),%dl
    for (size_t i = 0; i < hd->Length; i++)
  804160a40a:	48 83 c0 01          	add    $0x1,%rax
  804160a40e:	48 39 c1             	cmp    %rax,%rcx
  804160a411:	75 f5                	jne    804160a408 <acpi_find_table+0x3d3>
    if (cksm)
  804160a413:	84 d2                	test   %dl,%dl
  804160a415:	0f 84 49 ff ff ff    	je     804160a364 <acpi_find_table+0x32f>
      panic("ACPI table '%.4s' invalid", hd->Signature);
  804160a41b:	48 89 d9             	mov    %rbx,%rcx
  804160a41e:	48 ba 9d e8 60 41 80 	movabs $0x804160e89d,%rdx
  804160a425:	00 00 00 
  804160a428:	be b0 00 00 00       	mov    $0xb0,%esi
  804160a42d:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a434:	00 00 00 
  804160a437:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a43c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160a443:	00 00 00 
  804160a446:	41 ff d0             	callq  *%r8
      return hd;
  }

  return NULL;
  804160a449:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  804160a44e:	48 89 d8             	mov    %rbx,%rax
  804160a451:	48 83 c4 28          	add    $0x28,%rsp
  804160a455:	5b                   	pop    %rbx
  804160a456:	41 5c                	pop    %r12
  804160a458:	41 5d                	pop    %r13
  804160a45a:	41 5e                	pop    %r14
  804160a45c:	41 5f                	pop    %r15
  804160a45e:	5d                   	pop    %rbp
  804160a45f:	c3                   	retq   
  return NULL;
  804160a460:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160a465:	eb e7                	jmp    804160a44e <acpi_find_table+0x419>

000000804160a467 <hpet_handle_interrupts_tim0>:
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  // LAB 5 code end
}

void
hpet_handle_interrupts_tim0(void) {
  804160a467:	55                   	push   %rbp
  804160a468:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_TIMER);
  804160a46b:	bf 00 00 00 00       	mov    $0x0,%edi
  804160a470:	48 b8 7f 91 60 41 80 	movabs $0x804160917f,%rax
  804160a477:	00 00 00 
  804160a47a:	ff d0                	callq  *%rax
}
  804160a47c:	5d                   	pop    %rbp
  804160a47d:	c3                   	retq   

000000804160a47e <hpet_handle_interrupts_tim1>:

void
hpet_handle_interrupts_tim1(void) {
  804160a47e:	55                   	push   %rbp
  804160a47f:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_CLOCK);
  804160a482:	bf 08 00 00 00       	mov    $0x8,%edi
  804160a487:	48 b8 7f 91 60 41 80 	movabs $0x804160917f,%rax
  804160a48e:	00 00 00 
  804160a491:	ff d0                	callq  *%rax
}
  804160a493:	5d                   	pop    %rbp
  804160a494:	c3                   	retq   

000000804160a495 <hpet_cpu_frequency>:
// about pause instruction.
uint64_t
hpet_cpu_frequency(void) {
  // LAB 5 code
  uint64_t time_res = 100;
  uint64_t delta = 0, target = hpetFreq / time_res;
  804160a495:	48 a1 f8 55 88 41 80 	movabs 0x80418855f8,%rax
  804160a49c:	00 00 00 
  804160a49f:	48 c1 e8 02          	shr    $0x2,%rax
  804160a4a3:	48 ba c3 f5 28 5c 8f 	movabs $0x28f5c28f5c28f5c3,%rdx
  804160a4aa:	c2 f5 28 
  804160a4ad:	48 f7 e2             	mul    %rdx
  804160a4b0:	48 89 d1             	mov    %rdx,%rcx
  804160a4b3:	48 c1 e9 02          	shr    $0x2,%rcx
  return hpetReg->MAIN_CNT;
  804160a4b7:	48 a1 08 56 88 41 80 	movabs 0x8041885608,%rax
  804160a4be:	00 00 00 
  804160a4c1:	48 8b b8 f0 00 00 00 	mov    0xf0(%rax),%rdi
  __asm __volatile("rdtsc"
  804160a4c8:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a4ca:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a4ce:	41 89 c0             	mov    %eax,%r8d
  804160a4d1:	49 09 d0             	or     %rdx,%r8
  804160a4d4:	48 be 08 56 88 41 80 	movabs $0x8041885608,%rsi
  804160a4db:	00 00 00 

  uint64_t tick0 = hpet_get_main_cnt();
  uint64_t tsc0 = read_tsc();
  do {
    asm("pause");
  804160a4de:	f3 90                	pause  
  return hpetReg->MAIN_CNT;
  804160a4e0:	48 8b 06             	mov    (%rsi),%rax
  804160a4e3:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
    delta = hpet_get_main_cnt() - tick0;
  804160a4ea:	48 29 f8             	sub    %rdi,%rax
  } while (delta < target);
  804160a4ed:	48 39 c1             	cmp    %rax,%rcx
  804160a4f0:	77 ec                	ja     804160a4de <hpet_cpu_frequency+0x49>
  __asm __volatile("rdtsc"
  804160a4f2:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a4f4:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a4f8:	89 c0                	mov    %eax,%eax
  804160a4fa:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * time_res; 
  804160a4fd:	48 89 d0             	mov    %rdx,%rax
  804160a500:	4c 29 c0             	sub    %r8,%rax
  804160a503:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160a507:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160a50b:	48 c1 e0 02          	shl    $0x2,%rax
  // LAB 5 code end
  // return 0;
}
  804160a50f:	c3                   	retq   

000000804160a510 <hpet_enable_interrupts_tim1>:
hpet_enable_interrupts_tim1(void) {
  804160a510:	55                   	push   %rbp
  804160a511:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  804160a514:	48 b8 08 56 88 41 80 	movabs $0x8041885608,%rax
  804160a51b:	00 00 00 
  804160a51e:	48 8b 08             	mov    (%rax),%rcx
  804160a521:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160a525:	48 83 c8 02          	or     $0x2,%rax
  804160a529:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM1_CONF = (IRQ_CLOCK << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  804160a52d:	48 c7 81 20 01 00 00 	movq   $0x104c,0x120(%rcx)
  804160a534:	4c 10 00 00 
  return hpetReg->MAIN_CNT;
  804160a538:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM1_COMP = hpet_get_main_cnt() + 3 * Peta / 2 / hpetFemto;
  804160a53f:	48 bf 00 56 88 41 80 	movabs $0x8041885600,%rdi
  804160a546:	00 00 00 
  804160a549:	48 b8 00 c0 29 f7 3d 	movabs $0x5543df729c000,%rax
  804160a550:	54 05 00 
  804160a553:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a558:	48 f7 37             	divq   (%rdi)
  804160a55b:	48 01 c6             	add    %rax,%rsi
  804160a55e:	48 89 b1 28 01 00 00 	mov    %rsi,0x128(%rcx)
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  804160a565:	48 89 81 28 01 00 00 	mov    %rax,0x128(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  804160a56c:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  804160a573:	00 00 00 
  804160a576:	89 c7                	mov    %eax,%edi
  804160a578:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  804160a57e:	48 b8 1a 90 60 41 80 	movabs $0x804160901a,%rax
  804160a585:	00 00 00 
  804160a588:	ff d0                	callq  *%rax
}
  804160a58a:	5d                   	pop    %rbp
  804160a58b:	c3                   	retq   

000000804160a58c <hpet_enable_interrupts_tim0>:
hpet_enable_interrupts_tim0(void) {
  804160a58c:	55                   	push   %rbp
  804160a58d:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  804160a590:	48 b8 08 56 88 41 80 	movabs $0x8041885608,%rax
  804160a597:	00 00 00 
  804160a59a:	48 8b 08             	mov    (%rax),%rcx
  804160a59d:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160a5a1:	48 83 c8 02          	or     $0x2,%rax
  804160a5a5:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM0_CONF = (IRQ_TIMER << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  804160a5a9:	48 c7 81 00 01 00 00 	movq   $0x4c,0x100(%rcx)
  804160a5b0:	4c 00 00 00 
  return hpetReg->MAIN_CNT;
  804160a5b4:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM0_COMP = hpet_get_main_cnt() + Peta / 2 / hpetFemto;
  804160a5bb:	48 bf 00 56 88 41 80 	movabs $0x8041885600,%rdi
  804160a5c2:	00 00 00 
  804160a5c5:	48 b8 00 40 63 52 bf 	movabs $0x1c6bf52634000,%rax
  804160a5cc:	c6 01 00 
  804160a5cf:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a5d4:	48 f7 37             	divq   (%rdi)
  804160a5d7:	48 01 c6             	add    %rax,%rsi
  804160a5da:	48 89 b1 08 01 00 00 	mov    %rsi,0x108(%rcx)
  hpetReg->TIM0_COMP = Peta / 2 / hpetFemto;
  804160a5e1:	48 89 81 08 01 00 00 	mov    %rax,0x108(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_TIMER));
  804160a5e8:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  804160a5ef:	00 00 00 
  804160a5f2:	89 c7                	mov    %eax,%edi
  804160a5f4:	81 e7 fe ff 00 00    	and    $0xfffe,%edi
  804160a5fa:	48 b8 1a 90 60 41 80 	movabs $0x804160901a,%rax
  804160a601:	00 00 00 
  804160a604:	ff d0                	callq  *%rax
}
  804160a606:	5d                   	pop    %rbp
  804160a607:	c3                   	retq   

000000804160a608 <check_sum>:
  switch (type) {
  804160a608:	85 f6                	test   %esi,%esi
  804160a60a:	74 0f                	je     804160a61b <check_sum+0x13>
  uint32_t len = 0;
  804160a60c:	ba 00 00 00 00       	mov    $0x0,%edx
  switch (type) {
  804160a611:	83 fe 01             	cmp    $0x1,%esi
  804160a614:	75 08                	jne    804160a61e <check_sum+0x16>
      len = ((ACPISDTHeader *)Table)->Length;
  804160a616:	8b 57 04             	mov    0x4(%rdi),%edx
      break;
  804160a619:	eb 03                	jmp    804160a61e <check_sum+0x16>
      len = ((RSDP *)Table)->Length;
  804160a61b:	8b 57 14             	mov    0x14(%rdi),%edx
  for (int i = 0; i < len; i++)
  804160a61e:	85 d2                	test   %edx,%edx
  804160a620:	74 24                	je     804160a646 <check_sum+0x3e>
  804160a622:	48 89 f8             	mov    %rdi,%rax
  804160a625:	8d 52 ff             	lea    -0x1(%rdx),%edx
  804160a628:	48 8d 74 17 01       	lea    0x1(%rdi,%rdx,1),%rsi
  int sum      = 0;
  804160a62d:	ba 00 00 00 00       	mov    $0x0,%edx
    sum += ((uint8_t *)Table)[i];
  804160a632:	0f b6 08             	movzbl (%rax),%ecx
  804160a635:	01 ca                	add    %ecx,%edx
  for (int i = 0; i < len; i++)
  804160a637:	48 83 c0 01          	add    $0x1,%rax
  804160a63b:	48 39 f0             	cmp    %rsi,%rax
  804160a63e:	75 f2                	jne    804160a632 <check_sum+0x2a>
  if (sum % 0x100 == 0)
  804160a640:	84 d2                	test   %dl,%dl
  804160a642:	0f 94 c0             	sete   %al
}
  804160a645:	c3                   	retq   
  int sum      = 0;
  804160a646:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a64b:	eb f3                	jmp    804160a640 <check_sum+0x38>

000000804160a64d <get_rsdp>:
  if (krsdp != NULL)
  804160a64d:	48 a1 f0 55 88 41 80 	movabs 0x80418855f0,%rax
  804160a654:	00 00 00 
  804160a657:	48 85 c0             	test   %rax,%rax
  804160a65a:	74 01                	je     804160a65d <get_rsdp+0x10>
}
  804160a65c:	c3                   	retq   
get_rsdp(void) {
  804160a65d:	55                   	push   %rbp
  804160a65e:	48 89 e5             	mov    %rsp,%rbp
  if (uefi_lp->ACPIRoot == 0)
  804160a661:	48 a1 00 00 62 41 80 	movabs 0x8041620000,%rax
  804160a668:	00 00 00 
  804160a66b:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160a66f:	48 85 ff             	test   %rdi,%rdi
  804160a672:	74 1d                	je     804160a691 <get_rsdp+0x44>
  krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  804160a674:	be 24 00 00 00       	mov    $0x24,%esi
  804160a679:	48 b8 91 82 60 41 80 	movabs $0x8041608291,%rax
  804160a680:	00 00 00 
  804160a683:	ff d0                	callq  *%rax
  804160a685:	48 a3 f0 55 88 41 80 	movabs %rax,0x80418855f0
  804160a68c:	00 00 00 
}
  804160a68f:	5d                   	pop    %rbp
  804160a690:	c3                   	retq   
    panic("No rsdp\n");
  804160a691:	48 ba 65 e8 60 41 80 	movabs $0x804160e865,%rdx
  804160a698:	00 00 00 
  804160a69b:	be 65 00 00 00       	mov    $0x65,%esi
  804160a6a0:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a6a7:	00 00 00 
  804160a6aa:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a6af:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a6b6:	00 00 00 
  804160a6b9:	ff d1                	callq  *%rcx

000000804160a6bb <get_fadt>:
  if (!kfadt) {
  804160a6bb:	48 b8 e8 55 88 41 80 	movabs $0x80418855e8,%rax
  804160a6c2:	00 00 00 
  804160a6c5:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a6c9:	74 0b                	je     804160a6d6 <get_fadt+0x1b>
}
  804160a6cb:	48 a1 e8 55 88 41 80 	movabs 0x80418855e8,%rax
  804160a6d2:	00 00 00 
  804160a6d5:	c3                   	retq   
get_fadt(void) {
  804160a6d6:	55                   	push   %rbp
  804160a6d7:	48 89 e5             	mov    %rsp,%rbp
    kfadt = acpi_find_table("FACP");
  804160a6da:	48 bf b7 e8 60 41 80 	movabs $0x804160e8b7,%rdi
  804160a6e1:	00 00 00 
  804160a6e4:	48 b8 35 a0 60 41 80 	movabs $0x804160a035,%rax
  804160a6eb:	00 00 00 
  804160a6ee:	ff d0                	callq  *%rax
  804160a6f0:	48 a3 e8 55 88 41 80 	movabs %rax,0x80418855e8
  804160a6f7:	00 00 00 
}
  804160a6fa:	48 a1 e8 55 88 41 80 	movabs 0x80418855e8,%rax
  804160a701:	00 00 00 
  804160a704:	5d                   	pop    %rbp
  804160a705:	c3                   	retq   

000000804160a706 <acpi_enable>:
acpi_enable(void) {
  804160a706:	55                   	push   %rbp
  804160a707:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  804160a70a:	48 b8 bb a6 60 41 80 	movabs $0x804160a6bb,%rax
  804160a711:	00 00 00 
  804160a714:	ff d0                	callq  *%rax
  804160a716:	48 89 c1             	mov    %rax,%rcx
  __asm __volatile("outb %0,%w1"
  804160a719:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  804160a71d:	8b 51 30             	mov    0x30(%rcx),%edx
  804160a720:	ee                   	out    %al,(%dx)
  while ((inw(fadt->PM1aControlBlock) & 1) == 0) {
  804160a721:	8b 51 40             	mov    0x40(%rcx),%edx
  __asm __volatile("inw %w1,%0"
  804160a724:	66 ed                	in     (%dx),%ax
  804160a726:	a8 01                	test   $0x1,%al
  804160a728:	74 fa                	je     804160a724 <acpi_enable+0x1e>
}
  804160a72a:	5d                   	pop    %rbp
  804160a72b:	c3                   	retq   

000000804160a72c <get_hpet>:
  if (!khpet) {
  804160a72c:	48 b8 c8 55 88 41 80 	movabs $0x80418855c8,%rax
  804160a733:	00 00 00 
  804160a736:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a73a:	74 0b                	je     804160a747 <get_hpet+0x1b>
}
  804160a73c:	48 a1 c8 55 88 41 80 	movabs 0x80418855c8,%rax
  804160a743:	00 00 00 
  804160a746:	c3                   	retq   
get_hpet(void) {
  804160a747:	55                   	push   %rbp
  804160a748:	48 89 e5             	mov    %rsp,%rbp
    khpet = acpi_find_table("HPET");
  804160a74b:	48 bf bc e8 60 41 80 	movabs $0x804160e8bc,%rdi
  804160a752:	00 00 00 
  804160a755:	48 b8 35 a0 60 41 80 	movabs $0x804160a035,%rax
  804160a75c:	00 00 00 
  804160a75f:	ff d0                	callq  *%rax
  804160a761:	48 a3 c8 55 88 41 80 	movabs %rax,0x80418855c8
  804160a768:	00 00 00 
}
  804160a76b:	48 a1 c8 55 88 41 80 	movabs 0x80418855c8,%rax
  804160a772:	00 00 00 
  804160a775:	5d                   	pop    %rbp
  804160a776:	c3                   	retq   

000000804160a777 <hpet_register>:
hpet_register(void) {
  804160a777:	55                   	push   %rbp
  804160a778:	48 89 e5             	mov    %rsp,%rbp
  HPET *hpet_timer = get_hpet();
  804160a77b:	48 b8 2c a7 60 41 80 	movabs $0x804160a72c,%rax
  804160a782:	00 00 00 
  804160a785:	ff d0                	callq  *%rax
  if (hpet_timer->address.address == 0)
  804160a787:	48 8b 78 2c          	mov    0x2c(%rax),%rdi
  804160a78b:	48 85 ff             	test   %rdi,%rdi
  804160a78e:	74 13                	je     804160a7a3 <hpet_register+0x2c>
  return mmio_map_region(paddr, sizeof(HPETRegister));
  804160a790:	be 00 04 00 00       	mov    $0x400,%esi
  804160a795:	48 b8 91 82 60 41 80 	movabs $0x8041608291,%rax
  804160a79c:	00 00 00 
  804160a79f:	ff d0                	callq  *%rax
}
  804160a7a1:	5d                   	pop    %rbp
  804160a7a2:	c3                   	retq   
    panic("hpet is unavailable\n");
  804160a7a3:	48 ba c1 e8 60 41 80 	movabs $0x804160e8c1,%rdx
  804160a7aa:	00 00 00 
  804160a7ad:	be de 00 00 00       	mov    $0xde,%esi
  804160a7b2:	48 bf 6e e8 60 41 80 	movabs $0x804160e86e,%rdi
  804160a7b9:	00 00 00 
  804160a7bc:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a7c1:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a7c8:	00 00 00 
  804160a7cb:	ff d1                	callq  *%rcx

000000804160a7cd <hpet_init>:
  if (hpetReg == NULL) {
  804160a7cd:	48 b8 08 56 88 41 80 	movabs $0x8041885608,%rax
  804160a7d4:	00 00 00 
  804160a7d7:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a7db:	74 01                	je     804160a7de <hpet_init+0x11>
  804160a7dd:	c3                   	retq   
hpet_init() {
  804160a7de:	55                   	push   %rbp
  804160a7df:	48 89 e5             	mov    %rsp,%rbp
  804160a7e2:	53                   	push   %rbx
  804160a7e3:	48 83 ec 08          	sub    $0x8,%rsp
  __asm __volatile("inb %w1,%0"
  804160a7e7:	bb 70 00 00 00       	mov    $0x70,%ebx
  804160a7ec:	89 da                	mov    %ebx,%edx
  804160a7ee:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) | NMI_LOCK);
  804160a7ef:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  804160a7f2:	ee                   	out    %al,(%dx)
    hpetReg   = hpet_register();
  804160a7f3:	48 b8 77 a7 60 41 80 	movabs $0x804160a777,%rax
  804160a7fa:	00 00 00 
  804160a7fd:	ff d0                	callq  *%rax
  804160a7ff:	48 89 c6             	mov    %rax,%rsi
  804160a802:	48 a3 08 56 88 41 80 	movabs %rax,0x8041885608
  804160a809:	00 00 00 
    hpetFemto = (uintptr_t)(hpetReg->GCAP_ID >> 32);
  804160a80c:	48 8b 08             	mov    (%rax),%rcx
  804160a80f:	48 c1 e9 20          	shr    $0x20,%rcx
  804160a813:	48 89 c8             	mov    %rcx,%rax
  804160a816:	48 a3 00 56 88 41 80 	movabs %rax,0x8041885600
  804160a81d:	00 00 00 
    hpetFreq = (1 * Peta) / hpetFemto;
  804160a820:	48 b8 00 80 c6 a4 7e 	movabs $0x38d7ea4c68000,%rax
  804160a827:	8d 03 00 
  804160a82a:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a82f:	48 f7 f1             	div    %rcx
  804160a832:	48 a3 f8 55 88 41 80 	movabs %rax,0x80418855f8
  804160a839:	00 00 00 
    hpetReg->GEN_CONF |= 1;
  804160a83c:	48 8b 46 10          	mov    0x10(%rsi),%rax
  804160a840:	48 83 c8 01          	or     $0x1,%rax
  804160a844:	48 89 46 10          	mov    %rax,0x10(%rsi)
  __asm __volatile("inb %w1,%0"
  804160a848:	89 da                	mov    %ebx,%edx
  804160a84a:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  804160a84b:	83 e0 7f             	and    $0x7f,%eax
  804160a84e:	ee                   	out    %al,(%dx)
}
  804160a84f:	48 83 c4 08          	add    $0x8,%rsp
  804160a853:	5b                   	pop    %rbx
  804160a854:	5d                   	pop    %rbp
  804160a855:	c3                   	retq   

000000804160a856 <hpet_print_struct>:
hpet_print_struct(void) {
  804160a856:	55                   	push   %rbp
  804160a857:	48 89 e5             	mov    %rsp,%rbp
  804160a85a:	41 54                	push   %r12
  804160a85c:	53                   	push   %rbx
  HPET *hpet = get_hpet();
  804160a85d:	48 b8 2c a7 60 41 80 	movabs $0x804160a72c,%rax
  804160a864:	00 00 00 
  804160a867:	ff d0                	callq  *%rax
  804160a869:	49 89 c4             	mov    %rax,%r12
  cprintf("signature = %s\n", (hpet->h).Signature);
  804160a86c:	48 89 c6             	mov    %rax,%rsi
  804160a86f:	48 bf d6 e8 60 41 80 	movabs $0x804160e8d6,%rdi
  804160a876:	00 00 00 
  804160a879:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a87e:	48 bb f2 91 60 41 80 	movabs $0x80416091f2,%rbx
  804160a885:	00 00 00 
  804160a888:	ff d3                	callq  *%rbx
  cprintf("length = %08x\n", (hpet->h).Length);
  804160a88a:	41 8b 74 24 04       	mov    0x4(%r12),%esi
  804160a88f:	48 bf e6 e8 60 41 80 	movabs $0x804160e8e6,%rdi
  804160a896:	00 00 00 
  804160a899:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a89e:	ff d3                	callq  *%rbx
  cprintf("revision = %08x\n", (hpet->h).Revision);
  804160a8a0:	41 0f b6 74 24 08    	movzbl 0x8(%r12),%esi
  804160a8a6:	48 bf 0a e9 60 41 80 	movabs $0x804160e90a,%rdi
  804160a8ad:	00 00 00 
  804160a8b0:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8b5:	ff d3                	callq  *%rbx
  cprintf("checksum = %08x\n", (hpet->h).Checksum);
  804160a8b7:	41 0f b6 74 24 09    	movzbl 0x9(%r12),%esi
  804160a8bd:	48 bf f5 e8 60 41 80 	movabs $0x804160e8f5,%rdi
  804160a8c4:	00 00 00 
  804160a8c7:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8cc:	ff d3                	callq  *%rbx
  cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  804160a8ce:	41 8b 74 24 18       	mov    0x18(%r12),%esi
  804160a8d3:	48 bf 06 e9 60 41 80 	movabs $0x804160e906,%rdi
  804160a8da:	00 00 00 
  804160a8dd:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8e2:	ff d3                	callq  *%rbx
  cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  804160a8e4:	41 8b 74 24 1c       	mov    0x1c(%r12),%esi
  804160a8e9:	48 bf 1b e9 60 41 80 	movabs $0x804160e91b,%rdi
  804160a8f0:	00 00 00 
  804160a8f3:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8f8:	ff d3                	callq  *%rbx
  cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);
  804160a8fa:	41 8b 74 24 20       	mov    0x20(%r12),%esi
  804160a8ff:	48 bf 2e e9 60 41 80 	movabs $0x804160e92e,%rdi
  804160a906:	00 00 00 
  804160a909:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a90e:	ff d3                	callq  *%rbx
  cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  804160a910:	41 0f b6 74 24 24    	movzbl 0x24(%r12),%esi
  804160a916:	48 bf 47 e9 60 41 80 	movabs $0x804160e947,%rdi
  804160a91d:	00 00 00 
  804160a920:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a925:	ff d3                	callq  *%rbx
  cprintf("comparator_count = %08x\n", hpet->comparator_count);
  804160a927:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a92d:	83 e6 1f             	and    $0x1f,%esi
  804160a930:	48 bf 5f e9 60 41 80 	movabs $0x804160e95f,%rdi
  804160a937:	00 00 00 
  804160a93a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a93f:	ff d3                	callq  *%rbx
  cprintf("counter_size = %08x\n", hpet->counter_size);
  804160a941:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a947:	40 c0 ee 05          	shr    $0x5,%sil
  804160a94b:	83 e6 01             	and    $0x1,%esi
  804160a94e:	48 bf 78 e9 60 41 80 	movabs $0x804160e978,%rdi
  804160a955:	00 00 00 
  804160a958:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a95d:	ff d3                	callq  *%rbx
  cprintf("reserved = %08x\n", hpet->reserved);
  804160a95f:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a965:	40 c0 ee 06          	shr    $0x6,%sil
  804160a969:	83 e6 01             	and    $0x1,%esi
  804160a96c:	48 bf 8d e9 60 41 80 	movabs $0x804160e98d,%rdi
  804160a973:	00 00 00 
  804160a976:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a97b:	ff d3                	callq  *%rbx
  cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  804160a97d:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a983:	40 c0 ee 07          	shr    $0x7,%sil
  804160a987:	40 0f b6 f6          	movzbl %sil,%esi
  804160a98b:	48 bf 9e e9 60 41 80 	movabs $0x804160e99e,%rdi
  804160a992:	00 00 00 
  804160a995:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a99a:	ff d3                	callq  *%rbx
  cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  804160a99c:	41 0f b7 74 24 26    	movzwl 0x26(%r12),%esi
  804160a9a2:	48 bf b9 e9 60 41 80 	movabs $0x804160e9b9,%rdi
  804160a9a9:	00 00 00 
  804160a9ac:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9b1:	ff d3                	callq  *%rbx
  cprintf("hpet_number = %08x\n", hpet->hpet_number);
  804160a9b3:	41 0f b6 74 24 34    	movzbl 0x34(%r12),%esi
  804160a9b9:	48 bf cf e9 60 41 80 	movabs $0x804160e9cf,%rdi
  804160a9c0:	00 00 00 
  804160a9c3:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9c8:	ff d3                	callq  *%rbx
  cprintf("minimum_tick = %08x\n", hpet->minimum_tick);
  804160a9ca:	41 0f b7 74 24 35    	movzwl 0x35(%r12),%esi
  804160a9d0:	48 bf e3 e9 60 41 80 	movabs $0x804160e9e3,%rdi
  804160a9d7:	00 00 00 
  804160a9da:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9df:	ff d3                	callq  *%rbx
  cprintf("address_structure:\n");
  804160a9e1:	48 bf f8 e9 60 41 80 	movabs $0x804160e9f8,%rdi
  804160a9e8:	00 00 00 
  804160a9eb:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9f0:	ff d3                	callq  *%rbx
  cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  804160a9f2:	41 0f b6 74 24 28    	movzbl 0x28(%r12),%esi
  804160a9f8:	48 bf 0c ea 60 41 80 	movabs $0x804160ea0c,%rdi
  804160a9ff:	00 00 00 
  804160aa02:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa07:	ff d3                	callq  *%rbx
  cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  804160aa09:	41 0f b6 74 24 29    	movzbl 0x29(%r12),%esi
  804160aa0f:	48 bf 25 ea 60 41 80 	movabs $0x804160ea25,%rdi
  804160aa16:	00 00 00 
  804160aa19:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa1e:	ff d3                	callq  *%rbx
  cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  804160aa20:	41 0f b6 74 24 2a    	movzbl 0x2a(%r12),%esi
  804160aa26:	48 bf 40 ea 60 41 80 	movabs $0x804160ea40,%rdi
  804160aa2d:	00 00 00 
  804160aa30:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa35:	ff d3                	callq  *%rbx
  cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
  804160aa37:	49 8b 74 24 2c       	mov    0x2c(%r12),%rsi
  804160aa3c:	48 bf 5c ea 60 41 80 	movabs $0x804160ea5c,%rdi
  804160aa43:	00 00 00 
  804160aa46:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa4b:	ff d3                	callq  *%rbx
}
  804160aa4d:	5b                   	pop    %rbx
  804160aa4e:	41 5c                	pop    %r12
  804160aa50:	5d                   	pop    %rbp
  804160aa51:	c3                   	retq   

000000804160aa52 <hpet_print_reg>:
hpet_print_reg(void) {
  804160aa52:	55                   	push   %rbp
  804160aa53:	48 89 e5             	mov    %rsp,%rbp
  804160aa56:	41 54                	push   %r12
  804160aa58:	53                   	push   %rbx
  cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  804160aa59:	49 bc 08 56 88 41 80 	movabs $0x8041885608,%r12
  804160aa60:	00 00 00 
  804160aa63:	49 8b 04 24          	mov    (%r12),%rax
  804160aa67:	48 8b 30             	mov    (%rax),%rsi
  804160aa6a:	48 bf 6d ea 60 41 80 	movabs $0x804160ea6d,%rdi
  804160aa71:	00 00 00 
  804160aa74:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa79:	48 bb f2 91 60 41 80 	movabs $0x80416091f2,%rbx
  804160aa80:	00 00 00 
  804160aa83:	ff d3                	callq  *%rbx
  cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  804160aa85:	49 8b 04 24          	mov    (%r12),%rax
  804160aa89:	48 8b 70 10          	mov    0x10(%rax),%rsi
  804160aa8d:	48 bf 7f ea 60 41 80 	movabs $0x804160ea7f,%rdi
  804160aa94:	00 00 00 
  804160aa97:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa9c:	ff d3                	callq  *%rbx
  cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  804160aa9e:	49 8b 04 24          	mov    (%r12),%rax
  804160aaa2:	48 8b 70 20          	mov    0x20(%rax),%rsi
  804160aaa6:	48 bf 92 ea 60 41 80 	movabs $0x804160ea92,%rdi
  804160aaad:	00 00 00 
  804160aab0:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aab5:	ff d3                	callq  *%rbx
  cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  804160aab7:	49 8b 04 24          	mov    (%r12),%rax
  804160aabb:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
  804160aac2:	48 bf a6 ea 60 41 80 	movabs $0x804160eaa6,%rdi
  804160aac9:	00 00 00 
  804160aacc:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aad1:	ff d3                	callq  *%rbx
  cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  804160aad3:	49 8b 04 24          	mov    (%r12),%rax
  804160aad7:	48 8b b0 00 01 00 00 	mov    0x100(%rax),%rsi
  804160aade:	48 bf b9 ea 60 41 80 	movabs $0x804160eab9,%rdi
  804160aae5:	00 00 00 
  804160aae8:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aaed:	ff d3                	callq  *%rbx
  cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  804160aaef:	49 8b 04 24          	mov    (%r12),%rax
  804160aaf3:	48 8b b0 08 01 00 00 	mov    0x108(%rax),%rsi
  804160aafa:	48 bf cd ea 60 41 80 	movabs $0x804160eacd,%rdi
  804160ab01:	00 00 00 
  804160ab04:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab09:	ff d3                	callq  *%rbx
  cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  804160ab0b:	49 8b 04 24          	mov    (%r12),%rax
  804160ab0f:	48 8b b0 10 01 00 00 	mov    0x110(%rax),%rsi
  804160ab16:	48 bf e1 ea 60 41 80 	movabs $0x804160eae1,%rdi
  804160ab1d:	00 00 00 
  804160ab20:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab25:	ff d3                	callq  *%rbx
  cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  804160ab27:	49 8b 04 24          	mov    (%r12),%rax
  804160ab2b:	48 8b b0 20 01 00 00 	mov    0x120(%rax),%rsi
  804160ab32:	48 bf f4 ea 60 41 80 	movabs $0x804160eaf4,%rdi
  804160ab39:	00 00 00 
  804160ab3c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab41:	ff d3                	callq  *%rbx
  cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  804160ab43:	49 8b 04 24          	mov    (%r12),%rax
  804160ab47:	48 8b b0 28 01 00 00 	mov    0x128(%rax),%rsi
  804160ab4e:	48 bf 08 eb 60 41 80 	movabs $0x804160eb08,%rdi
  804160ab55:	00 00 00 
  804160ab58:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab5d:	ff d3                	callq  *%rbx
  cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  804160ab5f:	49 8b 04 24          	mov    (%r12),%rax
  804160ab63:	48 8b b0 30 01 00 00 	mov    0x130(%rax),%rsi
  804160ab6a:	48 bf 1c eb 60 41 80 	movabs $0x804160eb1c,%rdi
  804160ab71:	00 00 00 
  804160ab74:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab79:	ff d3                	callq  *%rbx
  cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  804160ab7b:	49 8b 04 24          	mov    (%r12),%rax
  804160ab7f:	48 8b b0 40 01 00 00 	mov    0x140(%rax),%rsi
  804160ab86:	48 bf 2f eb 60 41 80 	movabs $0x804160eb2f,%rdi
  804160ab8d:	00 00 00 
  804160ab90:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab95:	ff d3                	callq  *%rbx
  cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  804160ab97:	49 8b 04 24          	mov    (%r12),%rax
  804160ab9b:	48 8b b0 48 01 00 00 	mov    0x148(%rax),%rsi
  804160aba2:	48 bf 43 eb 60 41 80 	movabs $0x804160eb43,%rdi
  804160aba9:	00 00 00 
  804160abac:	b8 00 00 00 00       	mov    $0x0,%eax
  804160abb1:	ff d3                	callq  *%rbx
  cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
  804160abb3:	49 8b 04 24          	mov    (%r12),%rax
  804160abb7:	48 8b b0 50 01 00 00 	mov    0x150(%rax),%rsi
  804160abbe:	48 bf 57 eb 60 41 80 	movabs $0x804160eb57,%rdi
  804160abc5:	00 00 00 
  804160abc8:	b8 00 00 00 00       	mov    $0x0,%eax
  804160abcd:	ff d3                	callq  *%rbx
}
  804160abcf:	5b                   	pop    %rbx
  804160abd0:	41 5c                	pop    %r12
  804160abd2:	5d                   	pop    %rbp
  804160abd3:	c3                   	retq   

000000804160abd4 <hpet_get_main_cnt>:
  return hpetReg->MAIN_CNT;
  804160abd4:	48 a1 08 56 88 41 80 	movabs 0x8041885608,%rax
  804160abdb:	00 00 00 
  804160abde:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
}
  804160abe5:	c3                   	retq   

000000804160abe6 <pmtimer_get_timeval>:

uint32_t
pmtimer_get_timeval(void) {
  804160abe6:	55                   	push   %rbp
  804160abe7:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  804160abea:	48 b8 bb a6 60 41 80 	movabs $0x804160a6bb,%rax
  804160abf1:	00 00 00 
  804160abf4:	ff d0                	callq  *%rax
  __asm __volatile("inl %w1,%0"
  804160abf6:	8b 50 4c             	mov    0x4c(%rax),%edx
  804160abf9:	ed                   	in     (%dx),%eax
  return inl(fadt->PMTimerBlock);
}
  804160abfa:	5d                   	pop    %rbp
  804160abfb:	c3                   	retq   

000000804160abfc <pmtimer_cpu_frequency>:
// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
// Hint: use pmtimer_get_timeval function and do not forget that ACPI PM timer
// can be 24-bit or 32-bit.
uint64_t
pmtimer_cpu_frequency(void) {
  804160abfc:	55                   	push   %rbp
  804160abfd:	48 89 e5             	mov    %rsp,%rbp
  804160ac00:	41 55                	push   %r13
  804160ac02:	41 54                	push   %r12
  804160ac04:	53                   	push   %rbx
  804160ac05:	48 83 ec 08          	sub    $0x8,%rsp
  // LAB 5 code
  uint32_t time_res = 100;
  uint32_t tick0 = pmtimer_get_timeval();
  804160ac09:	48 b8 e6 ab 60 41 80 	movabs $0x804160abe6,%rax
  804160ac10:	00 00 00 
  804160ac13:	ff d0                	callq  *%rax
  804160ac15:	89 c3                	mov    %eax,%ebx
  __asm __volatile("rdtsc"
  804160ac17:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ac19:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ac1d:	89 c0                	mov    %eax,%eax
  804160ac1f:	48 09 c2             	or     %rax,%rdx
  804160ac22:	49 89 d5             	mov    %rdx,%r13

  uint64_t tsc0 = read_tsc();

  do {
    asm("pause");
    uint32_t tick1 = pmtimer_get_timeval();
  804160ac25:	49 bc e6 ab 60 41 80 	movabs $0x804160abe6,%r12
  804160ac2c:	00 00 00 
  804160ac2f:	eb 17                	jmp    804160ac48 <pmtimer_cpu_frequency+0x4c>
    delta = tick1 - tick0;
    if (-delta <= 0xFFFFFF) {
      delta += 0xFFFFFF;
    } else if (tick0 > tick1) {
  804160ac31:	39 c3                	cmp    %eax,%ebx
  804160ac33:	76 0a                	jbe    804160ac3f <pmtimer_cpu_frequency+0x43>
      delta += 0xFFFFFFFF;
  804160ac35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160ac3a:	48 01 c1             	add    %rax,%rcx
  804160ac3d:	eb 28                	jmp    804160ac67 <pmtimer_cpu_frequency+0x6b>
    }
  } while (delta < target);
  804160ac3f:	48 81 f9 d2 8b 00 00 	cmp    $0x8bd2,%rcx
  804160ac46:	77 1f                	ja     804160ac67 <pmtimer_cpu_frequency+0x6b>
    asm("pause");
  804160ac48:	f3 90                	pause  
    uint32_t tick1 = pmtimer_get_timeval();
  804160ac4a:	41 ff d4             	callq  *%r12
    delta = tick1 - tick0;
  804160ac4d:	89 c1                	mov    %eax,%ecx
  804160ac4f:	29 d9                	sub    %ebx,%ecx
    if (-delta <= 0xFFFFFF) {
  804160ac51:	48 89 ca             	mov    %rcx,%rdx
  804160ac54:	48 f7 da             	neg    %rdx
  804160ac57:	48 81 fa ff ff ff 00 	cmp    $0xffffff,%rdx
  804160ac5e:	77 d1                	ja     804160ac31 <pmtimer_cpu_frequency+0x35>
      delta += 0xFFFFFF;
  804160ac60:	48 81 c1 ff ff ff 00 	add    $0xffffff,%rcx
  __asm __volatile("rdtsc"
  804160ac67:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ac69:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ac6d:	89 c0                	mov    %eax,%eax
  804160ac6f:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * PM_FREQ / delta;
  804160ac72:	4c 29 ea             	sub    %r13,%rdx
  804160ac75:	48 69 c2 99 9e 36 00 	imul   $0x369e99,%rdx,%rax
  804160ac7c:	ba 00 00 00 00       	mov    $0x0,%edx
  804160ac81:	48 f7 f1             	div    %rcx
  // LAB 5 code end
  // return 0;
}
  804160ac84:	48 83 c4 08          	add    $0x8,%rsp
  804160ac88:	5b                   	pop    %rbx
  804160ac89:	41 5c                	pop    %r12
  804160ac8b:	41 5d                	pop    %r13
  804160ac8d:	5d                   	pop    %rbp
  804160ac8e:	c3                   	retq   

000000804160ac8f <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160ac8f:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  804160ac96:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  804160ac99:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  804160ac9f:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160aca2:	83 fa 02             	cmp    $0x2,%edx
  804160aca5:	76 5f                	jbe    804160ad06 <sched_halt+0x77>
  804160aca7:	48 8d 90 f4 01 00 00 	lea    0x1f4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  804160acae:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  804160acb3:	8b 02                	mov    (%rdx),%eax
  804160acb5:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160acb8:	83 f8 02             	cmp    $0x2,%eax
  804160acbb:	76 49                	jbe    804160ad06 <sched_halt+0x77>
  for (i = 0; i < NENV; i++) {
  804160acbd:	83 c1 01             	add    $0x1,%ecx
  804160acc0:	48 81 c2 20 01 00 00 	add    $0x120,%rdx
  804160acc7:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  804160accd:	75 e4                	jne    804160acb3 <sched_halt+0x24>
sched_halt(void) {
  804160accf:	55                   	push   %rbp
  804160acd0:	48 89 e5             	mov    %rsp,%rbp
  804160acd3:	53                   	push   %rbx
  804160acd4:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  804160acd8:	48 bf 78 eb 60 41 80 	movabs $0x804160eb78,%rdi
  804160acdf:	00 00 00 
  804160ace2:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ace7:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160acee:	00 00 00 
  804160acf1:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  804160acf3:	48 bb ee 3e 60 41 80 	movabs $0x8041603eee,%rbx
  804160acfa:	00 00 00 
  804160acfd:	bf 00 00 00 00       	mov    $0x0,%edi
  804160ad02:	ff d3                	callq  *%rbx
    while (1)
  804160ad04:	eb f7                	jmp    804160acfd <sched_halt+0x6e>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  804160ad06:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  804160ad0d:	00 00 00 
  804160ad10:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  804160ad17:	48 a1 64 5b 88 41 80 	movabs 0x8041885b64,%rax
  804160ad1e:	00 00 00 
  804160ad21:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  804160ad28:	48 89 c4             	mov    %rax,%rsp
  804160ad2b:	6a 00                	pushq  $0x0
  804160ad2d:	6a 00                	pushq  $0x0
  804160ad2f:	fb                   	sti    
  804160ad30:	f4                   	hlt    
  804160ad31:	c3                   	retq   

000000804160ad32 <sched_yield>:
sched_yield(void) {
  804160ad32:	55                   	push   %rbp
  804160ad33:	48 89 e5             	mov    %rsp,%rbp
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160ad36:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160ad3d:	00 00 00 
  804160ad40:	be 00 00 00 00       	mov    $0x0,%esi
  804160ad45:	48 85 c0             	test   %rax,%rax
  804160ad48:	74 0c                	je     804160ad56 <sched_yield+0x24>
  804160ad4a:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160ad50:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160ad56:	48 b8 28 45 88 41 80 	movabs $0x8041884528,%rax
  804160ad5d:	00 00 00 
  804160ad60:	4c 8b 00             	mov    (%rax),%r8
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160ad63:	89 f2                	mov    %esi,%edx
  804160ad65:	eb 04                	jmp    804160ad6b <sched_yield+0x39>
  } while (id != orig);
  804160ad67:	39 c6                	cmp    %eax,%esi
  804160ad69:	74 40                	je     804160adab <sched_yield+0x79>
    id = (id + 1) % NENV;
  804160ad6b:	8d 42 01             	lea    0x1(%rdx),%eax
  804160ad6e:	99                   	cltd   
  804160ad6f:	c1 ea 16             	shr    $0x16,%edx
  804160ad72:	01 d0                	add    %edx,%eax
  804160ad74:	25 ff 03 00 00       	and    $0x3ff,%eax
  804160ad79:	29 d0                	sub    %edx,%eax
  804160ad7b:	89 c2                	mov    %eax,%edx
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160ad7d:	48 63 c8             	movslq %eax,%rcx
  804160ad80:	48 8d 3c c9          	lea    (%rcx,%rcx,8),%rdi
  804160ad84:	48 c1 e7 05          	shl    $0x5,%rdi
  804160ad88:	4c 01 c7             	add    %r8,%rdi
  804160ad8b:	8b 8f d4 00 00 00    	mov    0xd4(%rdi),%ecx
  804160ad91:	83 f9 02             	cmp    $0x2,%ecx
  804160ad94:	74 09                	je     804160ad9f <sched_yield+0x6d>
       (id == orig && envs[id].env_status == ENV_RUNNING)) {
  804160ad96:	83 f9 03             	cmp    $0x3,%ecx
  804160ad99:	75 cc                	jne    804160ad67 <sched_yield+0x35>
  804160ad9b:	39 c6                	cmp    %eax,%esi
  804160ad9d:	75 c8                	jne    804160ad67 <sched_yield+0x35>
      env_run(envs + id);
  804160ad9f:	48 b8 8b 8e 60 41 80 	movabs $0x8041608e8b,%rax
  804160ada6:	00 00 00 
  804160ada9:	ff d0                	callq  *%rax
  sched_halt();
  804160adab:	48 b8 8f ac 60 41 80 	movabs $0x804160ac8f,%rax
  804160adb2:	00 00 00 
  804160adb5:	ff d0                	callq  *%rax
}
  804160adb7:	5d                   	pop    %rbp
  804160adb8:	c3                   	retq   

000000804160adb9 <syscall>:
  // return -1;
}

// Dispatches to the correct kernel function, passing the arguments.
uintptr_t
syscall(uintptr_t syscallno, uintptr_t a1, uintptr_t a2, uintptr_t a3, uintptr_t a4, uintptr_t a5) {
  804160adb9:	55                   	push   %rbp
  804160adba:	48 89 e5             	mov    %rsp,%rbp
  804160adbd:	41 57                	push   %r15
  804160adbf:	41 56                	push   %r14
  804160adc1:	41 55                	push   %r13
  804160adc3:	41 54                	push   %r12
  804160adc5:	53                   	push   %rbx
  804160adc6:	48 83 ec 38          	sub    $0x38,%rsp
  804160adca:	48 89 fb             	mov    %rdi,%rbx
  804160adcd:	49 89 f5             	mov    %rsi,%r13
  804160add0:	49 89 d4             	mov    %rdx,%r12
  804160add3:	4c 89 4d a8          	mov    %r9,-0x58(%rbp)
  // Call the function corresponding to the 'syscallno' parameter.
  // Return any appropriate return value.

  // LAB 8 code
  if (syscallno == SYS_cputs) {
  804160add7:	48 85 ff             	test   %rdi,%rdi
  804160adda:	0f 84 a9 00 00 00    	je     804160ae89 <syscall+0xd0>
  804160ade0:	49 89 ce             	mov    %rcx,%r14
  804160ade3:	4d 89 c7             	mov    %r8,%r15
    sys_cputs((const char *) a1, (size_t) a2);
    return 0;
  } else if (syscallno == SYS_cgetc) {
  804160ade6:	48 83 ff 01          	cmp    $0x1,%rdi
  804160adea:	0f 84 ea 00 00 00    	je     804160aeda <syscall+0x121>
    return sys_cgetc();
  } else if (syscallno == SYS_getenvid) {
  804160adf0:	48 83 ff 02          	cmp    $0x2,%rdi
  804160adf4:	0f 84 f0 00 00 00    	je     804160aeea <syscall+0x131>
    return sys_getenvid();
  } else if (syscallno == SYS_env_destroy) {
  804160adfa:	48 83 ff 03          	cmp    $0x3,%rdi
  804160adfe:	0f 84 f9 00 00 00    	je     804160aefd <syscall+0x144>
    return sys_env_destroy((envid_t) a1);
  // LAB 8 code end
  // LAB 9 code
  } else if (syscallno == SYS_exofork) {
  804160ae04:	48 83 ff 07          	cmp    $0x7,%rdi
  804160ae08:	0f 84 84 01 00 00    	je     804160af92 <syscall+0x1d9>
    return sys_exofork();
  } else if (syscallno == SYS_env_set_status) {
  804160ae0e:	48 83 ff 08          	cmp    $0x8,%rdi
  804160ae12:	0f 84 71 02 00 00    	je     804160b089 <syscall+0x2d0>
    return sys_env_set_status((envid_t) a1, (int) a2);
  } else if (syscallno == SYS_page_alloc) {
  804160ae18:	48 83 ff 04          	cmp    $0x4,%rdi
  804160ae1c:	0f 84 b4 02 00 00    	je     804160b0d6 <syscall+0x31d>
    return sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
  } else if (syscallno == SYS_page_map) {
  804160ae22:	48 83 ff 05          	cmp    $0x5,%rdi
  804160ae26:	0f 84 6e 03 00 00    	je     804160b19a <syscall+0x3e1>
    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
  } else if (syscallno == SYS_page_unmap) {
  804160ae2c:	48 83 ff 06          	cmp    $0x6,%rdi
  804160ae30:	0f 84 7f 04 00 00    	je     804160b2b5 <syscall+0x4fc>
    return sys_page_unmap((envid_t) a1, (void *) a2);
  } else if (syscallno == SYS_env_set_pgfault_upcall) {
  804160ae36:	48 83 ff 09          	cmp    $0x9,%rdi
  804160ae3a:	0f 84 e4 04 00 00    	je     804160b324 <syscall+0x56b>
    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
  } else if (syscallno == SYS_yield) {
  804160ae40:	48 83 ff 0a          	cmp    $0xa,%rdi
  804160ae44:	0f 84 14 05 00 00    	je     804160b35e <syscall+0x5a5>
    sys_yield();
    return 0;
  } else if (syscallno == SYS_ipc_try_send) {
  804160ae4a:	48 83 ff 0b          	cmp    $0xb,%rdi
  804160ae4e:	0f 84 16 05 00 00    	je     804160b36a <syscall+0x5b1>
    return sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
  } else if (syscallno == SYS_ipc_recv) {
    return sys_ipc_recv((void *) a1);
  // LAB 9 code end
  } else {
    return -E_INVAL;
  804160ae54:	48 c7 c0 fd ff ff ff 	mov    $0xfffffffffffffffd,%rax
  } else if (syscallno == SYS_ipc_recv) {
  804160ae5b:	48 83 ff 0c          	cmp    $0xc,%rdi
  804160ae5f:	75 6a                	jne    804160aecb <syscall+0x112>
  if ((uintptr_t)dstva < UTOP && PGOFF(dstva)) {
  804160ae61:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160ae68:	00 00 00 
  804160ae6b:	48 39 c6             	cmp    %rax,%rsi
  804160ae6e:	0f 87 38 06 00 00    	ja     804160b4ac <syscall+0x6f3>
  804160ae74:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
  804160ae7a:	0f 84 2c 06 00 00    	je     804160b4ac <syscall+0x6f3>
    return sys_ipc_recv((void *) a1);
  804160ae80:	48 c7 c0 fd ff ff ff 	mov    $0xfffffffffffffffd,%rax
  804160ae87:	eb 42                	jmp    804160aecb <syscall+0x112>
  user_mem_assert(curenv, s, len, PTE_U);
  804160ae89:	b9 04 00 00 00       	mov    $0x4,%ecx
  804160ae8e:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  804160ae95:	00 00 00 
  804160ae98:	48 8b 38             	mov    (%rax),%rdi
  804160ae9b:	48 b8 7e 84 60 41 80 	movabs $0x804160847e,%rax
  804160aea2:	00 00 00 
  804160aea5:	ff d0                	callq  *%rax
	cprintf("%.*s", (int)len, s);
  804160aea7:	4c 89 ea             	mov    %r13,%rdx
  804160aeaa:	44 89 e6             	mov    %r12d,%esi
  804160aead:	48 bf a1 eb 60 41 80 	movabs $0x804160eba1,%rdi
  804160aeb4:	00 00 00 
  804160aeb7:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aebc:	48 b9 f2 91 60 41 80 	movabs $0x80416091f2,%rcx
  804160aec3:	00 00 00 
  804160aec6:	ff d1                	callq  *%rcx
    return 0;
  804160aec8:	48 89 d8             	mov    %rbx,%rax
  }
  
  // return -E_INVAL;
}
  804160aecb:	48 83 c4 38          	add    $0x38,%rsp
  804160aecf:	5b                   	pop    %rbx
  804160aed0:	41 5c                	pop    %r12
  804160aed2:	41 5d                	pop    %r13
  804160aed4:	41 5e                	pop    %r14
  804160aed6:	41 5f                	pop    %r15
  804160aed8:	5d                   	pop    %rbp
  804160aed9:	c3                   	retq   
  return cons_getc();
  804160aeda:	48 b8 e5 0b 60 41 80 	movabs $0x8041600be5,%rax
  804160aee1:	00 00 00 
  804160aee4:	ff d0                	callq  *%rax
    return sys_cgetc();
  804160aee6:	48 98                	cltq   
  804160aee8:	eb e1                	jmp    804160aecb <syscall+0x112>
    return sys_getenvid();
  804160aeea:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160aef1:	00 00 00 
  804160aef4:	48 63 80 c8 00 00 00 	movslq 0xc8(%rax),%rax
  804160aefb:	eb ce                	jmp    804160aecb <syscall+0x112>
	if ((r = envid2env(envid, &e, 1)) < 0)
  804160aefd:	ba 01 00 00 00       	mov    $0x1,%edx
  804160af02:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160af06:	44 89 ef             	mov    %r13d,%edi
  804160af09:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160af10:	00 00 00 
  804160af13:	ff d0                	callq  *%rax
  804160af15:	85 c0                	test   %eax,%eax
  804160af17:	78 4f                	js     804160af68 <syscall+0x1af>
	if (e == curenv)
  804160af19:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  804160af1d:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160af24:	00 00 00 
  804160af27:	48 39 c2             	cmp    %rax,%rdx
  804160af2a:	74 43                	je     804160af6f <syscall+0x1b6>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
  804160af2c:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  804160af32:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160af38:	48 bf c1 eb 60 41 80 	movabs $0x804160ebc1,%rdi
  804160af3f:	00 00 00 
  804160af42:	b8 00 00 00 00       	mov    $0x0,%eax
  804160af47:	48 b9 f2 91 60 41 80 	movabs $0x80416091f2,%rcx
  804160af4e:	00 00 00 
  804160af51:	ff d1                	callq  *%rcx
	env_destroy(e);
  804160af53:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160af57:	48 b8 b7 8d 60 41 80 	movabs $0x8041608db7,%rax
  804160af5e:	00 00 00 
  804160af61:	ff d0                	callq  *%rax
	return 0;
  804160af63:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_env_destroy((envid_t) a1);
  804160af68:	48 98                	cltq   
  804160af6a:	e9 5c ff ff ff       	jmpq   804160aecb <syscall+0x112>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
  804160af6f:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160af75:	48 bf a6 eb 60 41 80 	movabs $0x804160eba6,%rdi
  804160af7c:	00 00 00 
  804160af7f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160af84:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160af8b:	00 00 00 
  804160af8e:	ff d2                	callq  *%rdx
  804160af90:	eb c1                	jmp    804160af53 <syscall+0x19a>
  struct Env *e = NULL;
  804160af92:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160af99:	00 
  if ((res = env_alloc(&e, curenv->env_id)) < 0) {
  804160af9a:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160afa1:	00 00 00 
  804160afa4:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160afaa:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160afae:	48 b8 93 86 60 41 80 	movabs $0x8041608693,%rax
  804160afb5:	00 00 00 
  804160afb8:	ff d0                	callq  *%rax
  804160afba:	85 c0                	test   %eax,%eax
  804160afbc:	0f 88 c0 00 00 00    	js     804160b082 <syscall+0x2c9>
  e->env_status = ENV_NOT_RUNNABLE;
  804160afc2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160afc6:	c7 80 d4 00 00 00 04 	movl   $0x4,0xd4(%rax)
  804160afcd:	00 00 00 
  e->env_tf = curenv->env_tf;
  804160afd0:	48 b9 20 45 88 41 80 	movabs $0x8041884520,%rcx
  804160afd7:	00 00 00 
  804160afda:	48 8b 11             	mov    (%rcx),%rdx
  804160afdd:	f3 0f 6f 02          	movdqu (%rdx),%xmm0
  804160afe1:	0f 11 00             	movups %xmm0,(%rax)
  804160afe4:	f3 0f 6f 4a 10       	movdqu 0x10(%rdx),%xmm1
  804160afe9:	0f 11 48 10          	movups %xmm1,0x10(%rax)
  804160afed:	f3 0f 6f 52 20       	movdqu 0x20(%rdx),%xmm2
  804160aff2:	0f 11 50 20          	movups %xmm2,0x20(%rax)
  804160aff6:	f3 0f 6f 5a 30       	movdqu 0x30(%rdx),%xmm3
  804160affb:	0f 11 58 30          	movups %xmm3,0x30(%rax)
  804160afff:	f3 0f 6f 62 40       	movdqu 0x40(%rdx),%xmm4
  804160b004:	0f 11 60 40          	movups %xmm4,0x40(%rax)
  804160b008:	f3 0f 6f 6a 50       	movdqu 0x50(%rdx),%xmm5
  804160b00d:	0f 11 68 50          	movups %xmm5,0x50(%rax)
  804160b011:	f3 0f 6f 72 60       	movdqu 0x60(%rdx),%xmm6
  804160b016:	0f 11 70 60          	movups %xmm6,0x60(%rax)
  804160b01a:	f3 0f 6f 7a 70       	movdqu 0x70(%rdx),%xmm7
  804160b01f:	0f 11 78 70          	movups %xmm7,0x70(%rax)
  804160b023:	f3 0f 6f 82 80 00 00 	movdqu 0x80(%rdx),%xmm0
  804160b02a:	00 
  804160b02b:	0f 11 80 80 00 00 00 	movups %xmm0,0x80(%rax)
  804160b032:	f3 0f 6f 8a 90 00 00 	movdqu 0x90(%rdx),%xmm1
  804160b039:	00 
  804160b03a:	0f 11 88 90 00 00 00 	movups %xmm1,0x90(%rax)
  804160b041:	f3 0f 6f 92 a0 00 00 	movdqu 0xa0(%rdx),%xmm2
  804160b048:	00 
  804160b049:	0f 11 90 a0 00 00 00 	movups %xmm2,0xa0(%rax)
  804160b050:	f3 0f 6f 9a b0 00 00 	movdqu 0xb0(%rdx),%xmm3
  804160b057:	00 
  804160b058:	0f 11 98 b0 00 00 00 	movups %xmm3,0xb0(%rax)
  e->env_pgfault_upcall = curenv->env_pgfault_upcall;
  804160b05f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b063:	48 8b 11             	mov    (%rcx),%rdx
  804160b066:	48 8b 92 f8 00 00 00 	mov    0xf8(%rdx),%rdx
  804160b06d:	48 89 90 f8 00 00 00 	mov    %rdx,0xf8(%rax)
	e->env_tf.tf_regs.reg_rax = 0;
  804160b074:	48 c7 40 70 00 00 00 	movq   $0x0,0x70(%rax)
  804160b07b:	00 
	return e->env_id; 
  804160b07c:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
    return sys_exofork();
  804160b082:	48 98                	cltq   
  804160b084:	e9 42 fe ff ff       	jmpq   804160aecb <syscall+0x112>
  if (envid2env(envid, &e, 1) < 0) {
  804160b089:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b08e:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b092:	44 89 ef             	mov    %r13d,%edi
  804160b095:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160b09c:	00 00 00 
  804160b09f:	ff d0                	callq  *%rax
  804160b0a1:	85 c0                	test   %eax,%eax
  804160b0a3:	78 23                	js     804160b0c8 <syscall+0x30f>
  if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE)) {
  804160b0a5:	41 8d 44 24 fe       	lea    -0x2(%r12),%eax
  804160b0aa:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
  804160b0af:	75 1e                	jne    804160b0cf <syscall+0x316>
  e->env_status = status;
  804160b0b1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b0b5:	44 89 a0 d4 00 00 00 	mov    %r12d,0xd4(%rax)
  return 0;
  804160b0bc:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_env_set_status((envid_t) a1, (int) a2);
  804160b0c1:	48 98                	cltq   
  804160b0c3:	e9 03 fe ff ff       	jmpq   804160aecb <syscall+0x112>
      return -E_BAD_ENV;
  804160b0c8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b0cd:	eb f2                	jmp    804160b0c1 <syscall+0x308>
      return -E_INVAL;
  804160b0cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b0d4:	eb eb                	jmp    804160b0c1 <syscall+0x308>
	if (envid2env(envid, &e, 1) < 0) {
  804160b0d6:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b0db:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b0df:	44 89 ef             	mov    %r13d,%edi
  804160b0e2:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160b0e9:	00 00 00 
  804160b0ec:	ff d0                	callq  *%rax
  804160b0ee:	85 c0                	test   %eax,%eax
  804160b0f0:	0f 88 81 00 00 00    	js     804160b177 <syscall+0x3be>
  if ((uintptr_t) va >= UTOP || PGOFF(va)) {
  804160b0f6:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160b0fd:	00 00 00 
  804160b100:	49 39 c4             	cmp    %rax,%r12
  804160b103:	77 79                	ja     804160b17e <syscall+0x3c5>
  804160b105:	41 f7 c4 ff 0f 00 00 	test   $0xfff,%r12d
  804160b10c:	75 77                	jne    804160b185 <syscall+0x3cc>
  if (perm & ~PTE_SYSCALL) {
  804160b10e:	44 89 f3             	mov    %r14d,%ebx
  804160b111:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
  804160b117:	75 73                	jne    804160b18c <syscall+0x3d3>
  if (!(pp = page_alloc(ALLOC_ZERO))) {
  804160b119:	bf 01 00 00 00       	mov    $0x1,%edi
  804160b11e:	48 b8 fe 49 60 41 80 	movabs $0x80416049fe,%rax
  804160b125:	00 00 00 
  804160b128:	ff d0                	callq  *%rax
  804160b12a:	49 89 c5             	mov    %rax,%r13
  804160b12d:	48 85 c0             	test   %rax,%rax
  804160b130:	74 61                	je     804160b193 <syscall+0x3da>
  if (page_insert(e->env_pml4e, pp, va, perm | PTE_U) < 0) {
  804160b132:	44 89 f1             	mov    %r14d,%ecx
  804160b135:	83 c9 04             	or     $0x4,%ecx
  804160b138:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b13c:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b143:	4c 89 e2             	mov    %r12,%rdx
  804160b146:	4c 89 ee             	mov    %r13,%rsi
  804160b149:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  804160b150:	00 00 00 
  804160b153:	ff d0                	callq  *%rax
  804160b155:	85 c0                	test   %eax,%eax
  804160b157:	78 08                	js     804160b161 <syscall+0x3a8>
    return sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
  804160b159:	48 63 c3             	movslq %ebx,%rax
  804160b15c:	e9 6a fd ff ff       	jmpq   804160aecb <syscall+0x112>
    page_free(pp);
  804160b161:	4c 89 ef             	mov    %r13,%rdi
  804160b164:	48 b8 f7 4a 60 41 80 	movabs $0x8041604af7,%rax
  804160b16b:	00 00 00 
  804160b16e:	ff d0                	callq  *%rax
    return -E_NO_MEM;
  804160b170:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  804160b175:	eb e2                	jmp    804160b159 <syscall+0x3a0>
		return -E_BAD_ENV;
  804160b177:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
  804160b17c:	eb db                	jmp    804160b159 <syscall+0x3a0>
    return -E_INVAL;
  804160b17e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  804160b183:	eb d4                	jmp    804160b159 <syscall+0x3a0>
  804160b185:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  804160b18a:	eb cd                	jmp    804160b159 <syscall+0x3a0>
    return -E_INVAL;
  804160b18c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  804160b191:	eb c6                	jmp    804160b159 <syscall+0x3a0>
    return -E_NO_MEM;
  804160b193:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  804160b198:	eb bf                	jmp    804160b159 <syscall+0x3a0>
  if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0) {
  804160b19a:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b19f:	48 8d 75 b8          	lea    -0x48(%rbp),%rsi
  804160b1a3:	44 89 ef             	mov    %r13d,%edi
  804160b1a6:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160b1ad:	00 00 00 
  804160b1b0:	ff d0                	callq  *%rax
  804160b1b2:	85 c0                	test   %eax,%eax
  804160b1b4:	0f 88 c3 00 00 00    	js     804160b27d <syscall+0x4c4>
  804160b1ba:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b1bf:	48 8d 75 c0          	lea    -0x40(%rbp),%rsi
  804160b1c3:	44 89 f7             	mov    %r14d,%edi
  804160b1c6:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160b1cd:	00 00 00 
  804160b1d0:	ff d0                	callq  *%rax
  804160b1d2:	85 c0                	test   %eax,%eax
  804160b1d4:	0f 88 aa 00 00 00    	js     804160b284 <syscall+0x4cb>
  if ((uintptr_t) srcva >= UTOP || PGOFF(srcva) || 
  804160b1da:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160b1e1:	00 00 00 
  804160b1e4:	49 39 c4             	cmp    %rax,%r12
  804160b1e7:	0f 87 9e 00 00 00    	ja     804160b28b <syscall+0x4d2>
  804160b1ed:	49 39 c7             	cmp    %rax,%r15
  804160b1f0:	0f 87 9c 00 00 00    	ja     804160b292 <syscall+0x4d9>
      (uintptr_t) dstva >= UTOP || PGOFF(dstva)) {
  804160b1f6:	4c 89 e0             	mov    %r12,%rax
  804160b1f9:	4c 09 f8             	or     %r15,%rax
  804160b1fc:	a9 ff 0f 00 00       	test   $0xfff,%eax
  804160b201:	0f 85 92 00 00 00    	jne    804160b299 <syscall+0x4e0>
  if (perm & ~PTE_SYSCALL) {
  804160b207:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  804160b20b:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
  804160b211:	0f 85 89 00 00 00    	jne    804160b2a0 <syscall+0x4e7>
  if (!(pp = page_lookup(srcenv->env_pml4e, srcva, &ptep))) { 
  804160b217:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  804160b21b:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b222:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160b226:	4c 89 e6             	mov    %r12,%rsi
  804160b229:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  804160b230:	00 00 00 
  804160b233:	ff d0                	callq  *%rax
  804160b235:	48 85 c0             	test   %rax,%rax
  804160b238:	74 6d                	je     804160b2a7 <syscall+0x4ee>
	if (!(*ptep & PTE_W) && (perm & PTE_W)) {
  804160b23a:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  804160b23e:	f6 02 02             	testb  $0x2,(%rdx)
  804160b241:	75 05                	jne    804160b248 <syscall+0x48f>
  804160b243:	f6 c3 02             	test   $0x2,%bl
  804160b246:	75 66                	jne    804160b2ae <syscall+0x4f5>
	if (page_insert(dstenv->env_pml4e, pp, dstva, perm | PTE_U)) {
  804160b248:	8b 4d a8             	mov    -0x58(%rbp),%ecx
  804160b24b:	83 c9 04             	or     $0x4,%ecx
  804160b24e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b252:	48 8b ba e8 00 00 00 	mov    0xe8(%rdx),%rdi
  804160b259:	4c 89 fa             	mov    %r15,%rdx
  804160b25c:	48 89 c6             	mov    %rax,%rsi
  804160b25f:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  804160b266:	00 00 00 
  804160b269:	ff d0                	callq  *%rax
  804160b26b:	85 c0                	test   %eax,%eax
  804160b26d:	75 07                	jne    804160b276 <syscall+0x4bd>
    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
  804160b26f:	48 98                	cltq   
  804160b271:	e9 55 fc ff ff       	jmpq   804160aecb <syscall+0x112>
		return -E_NO_MEM;
  804160b276:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  804160b27b:	eb f2                	jmp    804160b26f <syscall+0x4b6>
    return -E_BAD_ENV;
  804160b27d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b282:	eb eb                	jmp    804160b26f <syscall+0x4b6>
  804160b284:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b289:	eb e4                	jmp    804160b26f <syscall+0x4b6>
    return -E_INVAL;
  804160b28b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b290:	eb dd                	jmp    804160b26f <syscall+0x4b6>
  804160b292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b297:	eb d6                	jmp    804160b26f <syscall+0x4b6>
  804160b299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b29e:	eb cf                	jmp    804160b26f <syscall+0x4b6>
    return -E_INVAL;
  804160b2a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2a5:	eb c8                	jmp    804160b26f <syscall+0x4b6>
    return -E_INVAL;
  804160b2a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2ac:	eb c1                	jmp    804160b26f <syscall+0x4b6>
	  return -E_INVAL;
  804160b2ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2b3:	eb ba                	jmp    804160b26f <syscall+0x4b6>
  if (envid2env(envid, &e, 1) < 0) {
  804160b2b5:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b2ba:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b2be:	44 89 ef             	mov    %r13d,%edi
  804160b2c1:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160b2c8:	00 00 00 
  804160b2cb:	ff d0                	callq  *%rax
  804160b2cd:	85 c0                	test   %eax,%eax
  804160b2cf:	78 3e                	js     804160b30f <syscall+0x556>
	if ((uintptr_t)va >= UTOP || PGOFF(va)) {
  804160b2d1:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160b2d8:	00 00 00 
  804160b2db:	49 39 c4             	cmp    %rax,%r12
  804160b2de:	77 36                	ja     804160b316 <syscall+0x55d>
  804160b2e0:	41 f7 c4 ff 0f 00 00 	test   $0xfff,%r12d
  804160b2e7:	75 34                	jne    804160b31d <syscall+0x564>
	page_remove(e->env_pml4e, va);
  804160b2e9:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b2ed:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b2f4:	4c 89 e6             	mov    %r12,%rsi
  804160b2f7:	48 b8 b0 50 60 41 80 	movabs $0x80416050b0,%rax
  804160b2fe:	00 00 00 
  804160b301:	ff d0                	callq  *%rax
	return 0;
  804160b303:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_page_unmap((envid_t) a1, (void *) a2);
  804160b308:	48 98                	cltq   
  804160b30a:	e9 bc fb ff ff       	jmpq   804160aecb <syscall+0x112>
    return -E_BAD_ENV;
  804160b30f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b314:	eb f2                	jmp    804160b308 <syscall+0x54f>
    return -E_INVAL;
  804160b316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b31b:	eb eb                	jmp    804160b308 <syscall+0x54f>
  804160b31d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b322:	eb e4                	jmp    804160b308 <syscall+0x54f>
  if (envid2env(envid, &e, 1) < 0) {
  804160b324:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b329:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b32d:	44 89 ef             	mov    %r13d,%edi
  804160b330:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160b337:	00 00 00 
  804160b33a:	ff d0                	callq  *%rax
  804160b33c:	85 c0                	test   %eax,%eax
  804160b33e:	78 17                	js     804160b357 <syscall+0x59e>
  e->env_pgfault_upcall = func;
  804160b340:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b344:	4c 89 a0 f8 00 00 00 	mov    %r12,0xf8(%rax)
  return 0;
  804160b34b:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
  804160b350:	48 98                	cltq   
  804160b352:	e9 74 fb ff ff       	jmpq   804160aecb <syscall+0x112>
    return -E_BAD_ENV;
  804160b357:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b35c:	eb f2                	jmp    804160b350 <syscall+0x597>
  sched_yield();
  804160b35e:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  804160b365:	00 00 00 
  804160b368:	ff d0                	callq  *%rax
	if (envid2env(envid, &e, 0) < 0) {
  804160b36a:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b36f:	48 8d 75 c0          	lea    -0x40(%rbp),%rsi
  804160b373:	44 89 ef             	mov    %r13d,%edi
  804160b376:	48 b8 61 85 60 41 80 	movabs $0x8041608561,%rax
  804160b37d:	00 00 00 
  804160b380:	ff d0                	callq  *%rax
  804160b382:	85 c0                	test   %eax,%eax
  804160b384:	0f 88 f8 00 00 00    	js     804160b482 <syscall+0x6c9>
	if (!e->env_ipc_recving) {
  804160b38a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160b38e:	80 b8 00 01 00 00 00 	cmpb   $0x0,0x100(%rax)
  804160b395:	0f 84 ee 00 00 00    	je     804160b489 <syscall+0x6d0>
	if ((uintptr_t) srcva < UTOP) {
  804160b39b:	48 ba ff ff ff ff 7f 	movabs $0x7fffffffff,%rdx
  804160b3a2:	00 00 00 
  804160b3a5:	49 39 d6             	cmp    %rdx,%r14
  804160b3a8:	0f 87 89 00 00 00    	ja     804160b437 <syscall+0x67e>
		if (PGOFF(srcva)) {
  804160b3ae:	41 f7 c6 ff 0f 00 00 	test   $0xfff,%r14d
  804160b3b5:	0f 85 d5 00 00 00    	jne    804160b490 <syscall+0x6d7>
		if ((perm & ~(PTE_U | PTE_P)) || (perm & ~PTE_SYSCALL)) {
  804160b3bb:	41 f7 c7 fa ff ff ff 	test   $0xfffffffa,%r15d
  804160b3c2:	0f 85 cf 00 00 00    	jne    804160b497 <syscall+0x6de>
		if (!(p = page_lookup(curenv->env_pml4e, srcva, &ptep))) {
  804160b3c8:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160b3cf:	00 00 00 
  804160b3d2:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b3d9:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160b3dd:	4c 89 f6             	mov    %r14,%rsi
  804160b3e0:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  804160b3e7:	00 00 00 
  804160b3ea:	ff d0                	callq  *%rax
  804160b3ec:	48 85 c0             	test   %rax,%rax
  804160b3ef:	0f 84 a9 00 00 00    	je     804160b49e <syscall+0x6e5>
		if (!(*ptep & PTE_W) && (perm & PTE_W)) {
  804160b3f5:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  804160b3f9:	f6 02 02             	testb  $0x2,(%rdx)
  804160b3fc:	75 0a                	jne    804160b408 <syscall+0x64f>
  804160b3fe:	41 f6 c7 02          	test   $0x2,%r15b
  804160b402:	0f 85 9d 00 00 00    	jne    804160b4a5 <syscall+0x6ec>
		if (page_insert(e->env_pml4e, p, e->env_ipc_dstva, perm)) {
  804160b408:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  804160b40c:	48 8b 91 08 01 00 00 	mov    0x108(%rcx),%rdx
  804160b413:	48 8b b9 e8 00 00 00 	mov    0xe8(%rcx),%rdi
  804160b41a:	44 89 f9             	mov    %r15d,%ecx
  804160b41d:	48 89 c6             	mov    %rax,%rsi
  804160b420:	48 b8 0b 51 60 41 80 	movabs $0x804160510b,%rax
  804160b427:	00 00 00 
  804160b42a:	ff d0                	callq  *%rax
  804160b42c:	85 c0                	test   %eax,%eax
  804160b42e:	74 11                	je     804160b441 <syscall+0x688>
			return -E_NO_MEM;
  804160b430:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  804160b435:	eb 44                	jmp    804160b47b <syscall+0x6c2>
		e->env_ipc_perm = 0;
  804160b437:	c7 80 18 01 00 00 00 	movl   $0x0,0x118(%rax)
  804160b43e:	00 00 00 
	e->env_ipc_recving = 0;
  804160b441:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160b445:	c6 80 00 01 00 00 00 	movb   $0x0,0x100(%rax)
	e->env_ipc_from = curenv->env_id;
  804160b44c:	48 b9 20 45 88 41 80 	movabs $0x8041884520,%rcx
  804160b453:	00 00 00 
  804160b456:	48 8b 11             	mov    (%rcx),%rdx
  804160b459:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  804160b45f:	89 90 14 01 00 00    	mov    %edx,0x114(%rax)
	e->env_ipc_value = value;
  804160b465:	44 89 a0 10 01 00 00 	mov    %r12d,0x110(%rax)
	e->env_status = ENV_RUNNABLE;
  804160b46c:	c7 80 d4 00 00 00 02 	movl   $0x2,0xd4(%rax)
  804160b473:	00 00 00 
	return 0;
  804160b476:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
  804160b47b:	48 98                	cltq   
  804160b47d:	e9 49 fa ff ff       	jmpq   804160aecb <syscall+0x112>
		return -E_BAD_ENV;
  804160b482:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b487:	eb f2                	jmp    804160b47b <syscall+0x6c2>
		return -E_IPC_NOT_RECV;
  804160b489:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  804160b48e:	eb eb                	jmp    804160b47b <syscall+0x6c2>
			return -E_INVAL;
  804160b490:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b495:	eb e4                	jmp    804160b47b <syscall+0x6c2>
			return -E_INVAL;
  804160b497:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b49c:	eb dd                	jmp    804160b47b <syscall+0x6c2>
			return -E_INVAL;
  804160b49e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b4a3:	eb d6                	jmp    804160b47b <syscall+0x6c2>
			return -E_INVAL;
  804160b4a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b4aa:	eb cf                	jmp    804160b47b <syscall+0x6c2>
	curenv->env_ipc_recving = 1;
  804160b4ac:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160b4b3:	00 00 00 
  804160b4b6:	c6 80 00 01 00 00 01 	movb   $0x1,0x100(%rax)
	curenv->env_ipc_dstva = dstva;
  804160b4bd:	4c 89 a8 08 01 00 00 	mov    %r13,0x108(%rax)
	curenv->env_status = ENV_NOT_RUNNABLE;
  804160b4c4:	c7 80 d4 00 00 00 04 	movl   $0x4,0xd4(%rax)
  804160b4cb:	00 00 00 
  curenv->env_tf.tf_regs.reg_rax = 0;
  804160b4ce:	48 c7 40 70 00 00 00 	movq   $0x0,0x70(%rax)
  804160b4d5:	00 
	sched_yield();
  804160b4d6:	48 b8 32 ad 60 41 80 	movabs $0x804160ad32,%rax
  804160b4dd:	00 00 00 
  804160b4e0:	ff d0                	callq  *%rax

000000804160b4e2 <load_kernel_dwarf_info>:
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  804160b4e2:	48 ba 00 00 62 41 80 	movabs $0x8041620000,%rdx
  804160b4e9:	00 00 00 
  804160b4ec:	48 8b 02             	mov    (%rdx),%rax
  804160b4ef:	48 8b 48 58          	mov    0x58(%rax),%rcx
  804160b4f3:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  804160b4f7:	48 8b 48 60          	mov    0x60(%rax),%rcx
  804160b4fb:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  804160b4ff:	48 8b 40 68          	mov    0x68(%rax),%rax
  804160b503:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  804160b506:	48 8b 02             	mov    (%rdx),%rax
  804160b509:	48 8b 50 70          	mov    0x70(%rax),%rdx
  804160b50d:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  804160b511:	48 8b 50 78          	mov    0x78(%rax),%rdx
  804160b515:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  804160b519:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  804160b520:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  804160b524:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  804160b52b:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  804160b52f:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  804160b536:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  804160b53a:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  804160b541:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  804160b545:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  804160b54c:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  804160b550:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  804160b557:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  804160b55b:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  804160b562:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  804160b566:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  804160b56d:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  804160b571:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  804160b578:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  804160b57c:	c3                   	retq   

000000804160b57d <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  804160b57d:	55                   	push   %rbp
  804160b57e:	48 89 e5             	mov    %rsp,%rbp
  804160b581:	41 57                	push   %r15
  804160b583:	41 56                	push   %r14
  804160b585:	41 55                	push   %r13
  804160b587:	41 54                	push   %r12
  804160b589:	53                   	push   %rbx
  804160b58a:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  804160b591:	49 89 fc             	mov    %rdi,%r12
  804160b594:	48 89 f3             	mov    %rsi,%rbx
  // const struct Stab *stabs, *stab_end;
	// const char *stabstr, *stabstr_end;
  // LAB 8 code end

  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  804160b597:	48 be d9 eb 60 41 80 	movabs $0x804160ebd9,%rsi
  804160b59e:	00 00 00 
  804160b5a1:	48 89 df             	mov    %rbx,%rdi
  804160b5a4:	49 bd 28 c3 60 41 80 	movabs $0x804160c328,%r13
  804160b5ab:	00 00 00 
  804160b5ae:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  804160b5b1:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  804160b5b8:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  804160b5bb:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  804160b5c2:	48 be d9 eb 60 41 80 	movabs $0x804160ebd9,%rsi
  804160b5c9:	00 00 00 
  804160b5cc:	4c 89 f7             	mov    %r14,%rdi
  804160b5cf:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  804160b5d2:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  804160b5d9:	00 00 00 
  info->rip_fn_addr    = addr;
  804160b5dc:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  804160b5e3:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  804160b5ea:	00 00 00 

  if (!addr) {
  804160b5ed:	4d 85 e4             	test   %r12,%r12
  804160b5f0:	0f 84 13 02 00 00    	je     804160b809 <debuginfo_rip+0x28c>
  __asm __volatile("movq %%cr3,%0"
  804160b5f6:	41 0f 20 df          	mov    %cr3,%r15
  // LAB 8: Your code here.

  struct Dwarf_Addrs addrs;
  // LAB 8 code
  uint64_t tmp_cr3 = rcr3();
  lcr3(PADDR(kern_pml4e));
  804160b5fa:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  804160b601:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  804160b604:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160b60b:	00 00 00 
  804160b60e:	48 39 d0             	cmp    %rdx,%rax
  804160b611:	0f 86 82 01 00 00    	jbe    804160b799 <debuginfo_rip+0x21c>
  return (physaddr_t)kva - KERNBASE;
  804160b617:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  804160b61e:	ff ff ff 
  804160b621:	48 01 c8             	add    %rcx,%rax
  __asm __volatile("movq %0,%%cr3"
  804160b624:	0f 22 d8             	mov    %rax,%cr3
  // LAB 8 code end
  if (addr <= ULIM) {
  804160b627:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  804160b62e:	00 00 00 
  804160b631:	49 39 c4             	cmp    %rax,%r12
  804160b634:	0f 86 8d 01 00 00    	jbe    804160b7c7 <debuginfo_rip+0x24a>
    // lcr3(tmp_cr3);
    // LAB 8 code end

    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  804160b63a:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b641:	48 b8 e2 b4 60 41 80 	movabs $0x804160b4e2,%rax
  804160b648:	00 00 00 
  804160b64b:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  804160b64d:	48 c7 85 58 ff ff ff 	movq   $0x0,-0xa8(%rbp)
  804160b654:	00 00 00 00 
  804160b658:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  804160b65f:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  804160b663:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160b66a:	4c 89 e6             	mov    %r12,%rsi
  804160b66d:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b674:	48 b8 a5 16 60 41 80 	movabs $0x80416016a5,%rax
  804160b67b:	00 00 00 
  804160b67e:	ff d0                	callq  *%rax
  804160b680:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  804160b683:	85 c0                	test   %eax,%eax
  804160b685:	0f 88 66 01 00 00    	js     804160b7f1 <debuginfo_rip+0x274>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  804160b68b:	4c 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%r8
  804160b692:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160b697:	48 8d 95 48 ff ff ff 	lea    -0xb8(%rbp),%rdx
  804160b69e:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160b6a5:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b6ac:	48 b8 54 1d 60 41 80 	movabs $0x8041601d54,%rax
  804160b6b3:	00 00 00 
  804160b6b6:	ff d0                	callq  *%rax
  804160b6b8:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  804160b6bb:	ba 00 01 00 00       	mov    $0x100,%edx
  804160b6c0:	48 8b b5 48 ff ff ff 	mov    -0xb8(%rbp),%rsi
  804160b6c7:	48 89 df             	mov    %rbx,%rdi
  804160b6ca:	48 b8 76 c3 60 41 80 	movabs $0x804160c376,%rax
  804160b6d1:	00 00 00 
  804160b6d4:	ff d0                	callq  *%rax
  if (code < 0) {
  804160b6d6:	45 85 ed             	test   %r13d,%r13d
  804160b6d9:	0f 88 18 01 00 00    	js     804160b7f7 <debuginfo_rip+0x27a>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
    
  int lineno_store;
  addr = addr - 5;
  804160b6df:	49 83 ec 05          	sub    $0x5,%r12
  code = line_for_address(&addrs, addr, line_offset, &lineno_store);
  804160b6e3:	48 8d 8d 44 ff ff ff 	lea    -0xbc(%rbp),%rcx
  804160b6ea:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  804160b6f1:	4c 89 e6             	mov    %r12,%rsi
  804160b6f4:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b6fb:	48 b8 9e 32 60 41 80 	movabs $0x804160329e,%rax
  804160b702:	00 00 00 
  804160b705:	ff d0                	callq  *%rax
  804160b707:	41 89 c5             	mov    %eax,%r13d
  info->rip_line = lineno_store;
  804160b70a:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
  804160b710:	89 83 00 01 00 00    	mov    %eax,0x100(%rbx)
  if (code < 0) {
  804160b716:	45 85 ed             	test   %r13d,%r13d
  804160b719:	0f 88 de 00 00 00    	js     804160b7fd <debuginfo_rip+0x280>
  }
    
  //LAB 2 code end

  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  804160b71f:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  804160b726:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160b72c:	48 8d 8d 48 ff ff ff 	lea    -0xb8(%rbp),%rcx
  804160b733:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  804160b73a:	4c 89 e6             	mov    %r12,%rsi
  804160b73d:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b744:	48 b8 bf 21 60 41 80 	movabs $0x80416021bf,%rax
  804160b74b:	00 00 00 
  804160b74e:	ff d0                	callq  *%rax
  804160b750:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  804160b753:	ba 00 01 00 00       	mov    $0x100,%edx
  804160b758:	48 8b b5 48 ff ff ff 	mov    -0xb8(%rbp),%rsi
  804160b75f:	4c 89 f7             	mov    %r14,%rdi
  804160b762:	48 b8 76 c3 60 41 80 	movabs $0x804160c376,%rax
  804160b769:	00 00 00 
  804160b76c:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  804160b76e:	be 00 01 00 00       	mov    $0x100,%esi
  804160b773:	4c 89 f7             	mov    %r14,%rdi
  804160b776:	48 b8 f3 c2 60 41 80 	movabs $0x804160c2f3,%rax
  804160b77d:	00 00 00 
  804160b780:	ff d0                	callq  *%rax
  804160b782:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  804160b788:	45 85 ed             	test   %r13d,%r13d
  804160b78b:	78 76                	js     804160b803 <debuginfo_rip+0x286>
  804160b78d:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  }
  // LAB 8 code
  lcr3(tmp_cr3);
  // LAB 8 code end
  return 0;
  804160b791:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  804160b797:	eb 76                	jmp    804160b80f <debuginfo_rip+0x292>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160b799:	48 89 c1             	mov    %rax,%rcx
  804160b79c:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160b7a3:	00 00 00 
  804160b7a6:	be 42 00 00 00       	mov    $0x42,%esi
  804160b7ab:	48 bf e3 eb 60 41 80 	movabs $0x804160ebe3,%rdi
  804160b7b2:	00 00 00 
  804160b7b5:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b7ba:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160b7c1:	00 00 00 
  804160b7c4:	41 ff d0             	callq  *%r8
    panic("Can't search for user-level addresses yet!");
  804160b7c7:	48 ba f8 eb 60 41 80 	movabs $0x804160ebf8,%rdx
  804160b7ce:	00 00 00 
  804160b7d1:	be 4d 00 00 00       	mov    $0x4d,%esi
  804160b7d6:	48 bf e3 eb 60 41 80 	movabs $0x804160ebe3,%rdi
  804160b7dd:	00 00 00 
  804160b7e0:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b7e5:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160b7ec:	00 00 00 
  804160b7ef:	ff d1                	callq  *%rcx
  804160b7f1:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b7f5:	eb 18                	jmp    804160b80f <debuginfo_rip+0x292>
  804160b7f7:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b7fb:	eb 12                	jmp    804160b80f <debuginfo_rip+0x292>
  804160b7fd:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b801:	eb 0c                	jmp    804160b80f <debuginfo_rip+0x292>
  804160b803:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b807:	eb 06                	jmp    804160b80f <debuginfo_rip+0x292>
    return 0;
  804160b809:	41 bd 00 00 00 00    	mov    $0x0,%r13d
}
  804160b80f:	44 89 e8             	mov    %r13d,%eax
  804160b812:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  804160b819:	5b                   	pop    %rbx
  804160b81a:	41 5c                	pop    %r12
  804160b81c:	41 5d                	pop    %r13
  804160b81e:	41 5e                	pop    %r14
  804160b820:	41 5f                	pop    %r15
  804160b822:	5d                   	pop    %rbp
  804160b823:	c3                   	retq   

000000804160b824 <find_function>:

uintptr_t
find_function(const char *const fname) {
  804160b824:	55                   	push   %rbp
  804160b825:	48 89 e5             	mov    %rsp,%rbp
  804160b828:	53                   	push   %rbx
  804160b829:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  804160b830:	48 89 fb             	mov    %rdi,%rbx
  // LAB 6 code
  #endif
  // LAB 6 code end
    
  struct Dwarf_Addrs addrs;
  load_kernel_dwarf_info(&addrs);
  804160b833:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b837:	48 b8 e2 b4 60 41 80 	movabs $0x804160b4e2,%rax
  804160b83e:	00 00 00 
  804160b841:	ff d0                	callq  *%rax
  uintptr_t offset = 0;
  804160b843:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  804160b84a:	00 00 00 00 

  if (!address_by_fname(&addrs, fname, &offset) && offset) {
  804160b84e:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160b855:	48 89 de             	mov    %rbx,%rsi
  804160b858:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b85c:	48 b8 4b 27 60 41 80 	movabs $0x804160274b,%rax
  804160b863:	00 00 00 
  804160b866:	ff d0                	callq  *%rax
  804160b868:	85 c0                	test   %eax,%eax
  804160b86a:	75 0c                	jne    804160b878 <find_function+0x54>
  804160b86c:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160b873:	48 85 d2             	test   %rdx,%rdx
  804160b876:	75 23                	jne    804160b89b <find_function+0x77>
    return offset;
  }

  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160b878:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160b87f:	48 89 de             	mov    %rbx,%rsi
  804160b882:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b886:	48 b8 49 2d 60 41 80 	movabs $0x8041602d49,%rax
  804160b88d:	00 00 00 
  804160b890:	ff d0                	callq  *%rax
    return offset;
  }
  // LAB 3 code end

  return 0;
  804160b892:	ba 00 00 00 00       	mov    $0x0,%edx
  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160b897:	85 c0                	test   %eax,%eax
  804160b899:	74 0d                	je     804160b8a8 <find_function+0x84>
}
  804160b89b:	48 89 d0             	mov    %rdx,%rax
  804160b89e:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  804160b8a5:	5b                   	pop    %rbx
  804160b8a6:	5d                   	pop    %rbp
  804160b8a7:	c3                   	retq   
    return offset;
  804160b8a8:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160b8af:	eb ea                	jmp    804160b89b <find_function+0x77>

000000804160b8b1 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  804160b8b1:	55                   	push   %rbp
  804160b8b2:	48 89 e5             	mov    %rsp,%rbp
  804160b8b5:	41 57                	push   %r15
  804160b8b7:	41 56                	push   %r14
  804160b8b9:	41 55                	push   %r13
  804160b8bb:	41 54                	push   %r12
  804160b8bd:	53                   	push   %rbx
  804160b8be:	48 83 ec 18          	sub    $0x18,%rsp
  804160b8c2:	49 89 fc             	mov    %rdi,%r12
  804160b8c5:	49 89 f5             	mov    %rsi,%r13
  804160b8c8:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160b8cc:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  804160b8cf:	41 89 cf             	mov    %ecx,%r15d
  804160b8d2:	49 39 d7             	cmp    %rdx,%r15
  804160b8d5:	76 45                	jbe    804160b91c <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  804160b8d7:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160b8db:	85 db                	test   %ebx,%ebx
  804160b8dd:	7e 0e                	jle    804160b8ed <printnum+0x3c>
      putch(padc, putdat);
  804160b8df:	4c 89 ee             	mov    %r13,%rsi
  804160b8e2:	44 89 f7             	mov    %r14d,%edi
  804160b8e5:	41 ff d4             	callq  *%r12
    while (--width > 0)
  804160b8e8:	83 eb 01             	sub    $0x1,%ebx
  804160b8eb:	75 f2                	jne    804160b8df <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  804160b8ed:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b8f1:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b8f6:	49 f7 f7             	div    %r15
  804160b8f9:	48 b8 23 ec 60 41 80 	movabs $0x804160ec23,%rax
  804160b900:	00 00 00 
  804160b903:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  804160b907:	4c 89 ee             	mov    %r13,%rsi
  804160b90a:	41 ff d4             	callq  *%r12
}
  804160b90d:	48 83 c4 18          	add    $0x18,%rsp
  804160b911:	5b                   	pop    %rbx
  804160b912:	41 5c                	pop    %r12
  804160b914:	41 5d                	pop    %r13
  804160b916:	41 5e                	pop    %r14
  804160b918:	41 5f                	pop    %r15
  804160b91a:	5d                   	pop    %rbp
  804160b91b:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  804160b91c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b920:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b925:	49 f7 f7             	div    %r15
  804160b928:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  804160b92c:	48 89 c2             	mov    %rax,%rdx
  804160b92f:	48 b8 b1 b8 60 41 80 	movabs $0x804160b8b1,%rax
  804160b936:	00 00 00 
  804160b939:	ff d0                	callq  *%rax
  804160b93b:	eb b0                	jmp    804160b8ed <printnum+0x3c>

000000804160b93d <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  804160b93d:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  804160b941:	48 8b 06             	mov    (%rsi),%rax
  804160b944:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  804160b948:	73 0a                	jae    804160b954 <sprintputch+0x17>
    *b->buf++ = ch;
  804160b94a:	48 8d 50 01          	lea    0x1(%rax),%rdx
  804160b94e:	48 89 16             	mov    %rdx,(%rsi)
  804160b951:	40 88 38             	mov    %dil,(%rax)
}
  804160b954:	c3                   	retq   

000000804160b955 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  804160b955:	55                   	push   %rbp
  804160b956:	48 89 e5             	mov    %rsp,%rbp
  804160b959:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160b960:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160b967:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160b96e:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160b975:	84 c0                	test   %al,%al
  804160b977:	74 20                	je     804160b999 <printfmt+0x44>
  804160b979:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160b97d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160b981:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160b985:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160b989:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160b98d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160b991:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160b995:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  804160b999:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160b9a0:	00 00 00 
  804160b9a3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160b9aa:	00 00 00 
  804160b9ad:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160b9b1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160b9b8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160b9bf:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  804160b9c6:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160b9cd:	48 b8 db b9 60 41 80 	movabs $0x804160b9db,%rax
  804160b9d4:	00 00 00 
  804160b9d7:	ff d0                	callq  *%rax
}
  804160b9d9:	c9                   	leaveq 
  804160b9da:	c3                   	retq   

000000804160b9db <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  804160b9db:	55                   	push   %rbp
  804160b9dc:	48 89 e5             	mov    %rsp,%rbp
  804160b9df:	41 57                	push   %r15
  804160b9e1:	41 56                	push   %r14
  804160b9e3:	41 55                	push   %r13
  804160b9e5:	41 54                	push   %r12
  804160b9e7:	53                   	push   %rbx
  804160b9e8:	48 83 ec 48          	sub    $0x48,%rsp
  804160b9ec:	49 89 fd             	mov    %rdi,%r13
  804160b9ef:	49 89 f7             	mov    %rsi,%r15
  804160b9f2:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  804160b9f5:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  804160b9f9:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  804160b9fd:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160ba01:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160ba05:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  804160ba09:	41 0f b6 3e          	movzbl (%r14),%edi
  804160ba0d:	83 ff 25             	cmp    $0x25,%edi
  804160ba10:	74 18                	je     804160ba2a <vprintfmt+0x4f>
      if (ch == '\0')
  804160ba12:	85 ff                	test   %edi,%edi
  804160ba14:	0f 84 8c 06 00 00    	je     804160c0a6 <vprintfmt+0x6cb>
      putch(ch, putdat);
  804160ba1a:	4c 89 fe             	mov    %r15,%rsi
  804160ba1d:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160ba20:	49 89 de             	mov    %rbx,%r14
  804160ba23:	eb e0                	jmp    804160ba05 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160ba25:	49 89 de             	mov    %rbx,%r14
  804160ba28:	eb db                	jmp    804160ba05 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  804160ba2a:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  804160ba2e:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  804160ba32:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  804160ba39:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  804160ba3f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  804160ba43:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  804160ba48:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160ba4e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  804160ba54:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  804160ba59:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  804160ba5e:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  804160ba62:	0f b6 13             	movzbl (%rbx),%edx
  804160ba65:	8d 42 dd             	lea    -0x23(%rdx),%eax
  804160ba68:	3c 55                	cmp    $0x55,%al
  804160ba6a:	0f 87 8b 05 00 00    	ja     804160bffb <vprintfmt+0x620>
  804160ba70:	0f b6 c0             	movzbl %al,%eax
  804160ba73:	49 bb 00 ed 60 41 80 	movabs $0x804160ed00,%r11
  804160ba7a:	00 00 00 
  804160ba7d:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  804160ba81:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  804160ba84:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  804160ba88:	eb d4                	jmp    804160ba5e <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160ba8a:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  804160ba8d:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  804160ba91:	eb cb                	jmp    804160ba5e <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160ba93:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  804160ba96:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  804160ba9a:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  804160ba9e:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160baa1:	83 fa 09             	cmp    $0x9,%edx
  804160baa4:	77 7e                	ja     804160bb24 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  804160baa6:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  804160baaa:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  804160baae:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  804160bab3:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  804160bab7:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160baba:	83 fa 09             	cmp    $0x9,%edx
  804160babd:	76 e7                	jbe    804160baa6 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  804160babf:	4c 89 f3             	mov    %r14,%rbx
  804160bac2:	eb 19                	jmp    804160badd <vprintfmt+0x102>
        precision = va_arg(aq, int);
  804160bac4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bac7:	83 f8 2f             	cmp    $0x2f,%eax
  804160baca:	77 2a                	ja     804160baf6 <vprintfmt+0x11b>
  804160bacc:	89 c2                	mov    %eax,%edx
  804160bace:	4c 01 d2             	add    %r10,%rdx
  804160bad1:	83 c0 08             	add    $0x8,%eax
  804160bad4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bad7:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  804160bada:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  804160badd:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160bae1:	0f 89 77 ff ff ff    	jns    804160ba5e <vprintfmt+0x83>
          width = precision, precision = -1;
  804160bae7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160baeb:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  804160baf1:	e9 68 ff ff ff       	jmpq   804160ba5e <vprintfmt+0x83>
        precision = va_arg(aq, int);
  804160baf6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bafa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bafe:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bb02:	eb d3                	jmp    804160bad7 <vprintfmt+0xfc>
        if (width < 0)
  804160bb04:	8b 45 ac             	mov    -0x54(%rbp),%eax
  804160bb07:	85 c0                	test   %eax,%eax
  804160bb09:	41 0f 48 c0          	cmovs  %r8d,%eax
  804160bb0d:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  804160bb10:	4c 89 f3             	mov    %r14,%rbx
  804160bb13:	e9 46 ff ff ff       	jmpq   804160ba5e <vprintfmt+0x83>
  804160bb18:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  804160bb1b:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  804160bb1f:	e9 3a ff ff ff       	jmpq   804160ba5e <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160bb24:	4c 89 f3             	mov    %r14,%rbx
  804160bb27:	eb b4                	jmp    804160badd <vprintfmt+0x102>
        lflag++;
  804160bb29:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  804160bb2c:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  804160bb2f:	e9 2a ff ff ff       	jmpq   804160ba5e <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  804160bb34:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bb37:	83 f8 2f             	cmp    $0x2f,%eax
  804160bb3a:	77 19                	ja     804160bb55 <vprintfmt+0x17a>
  804160bb3c:	89 c2                	mov    %eax,%edx
  804160bb3e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bb42:	83 c0 08             	add    $0x8,%eax
  804160bb45:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bb48:	4c 89 fe             	mov    %r15,%rsi
  804160bb4b:	8b 3a                	mov    (%rdx),%edi
  804160bb4d:	41 ff d5             	callq  *%r13
        break;
  804160bb50:	e9 b0 fe ff ff       	jmpq   804160ba05 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  804160bb55:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bb59:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bb5d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bb61:	eb e5                	jmp    804160bb48 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  804160bb63:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bb66:	83 f8 2f             	cmp    $0x2f,%eax
  804160bb69:	77 5b                	ja     804160bbc6 <vprintfmt+0x1eb>
  804160bb6b:	89 c2                	mov    %eax,%edx
  804160bb6d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bb71:	83 c0 08             	add    $0x8,%eax
  804160bb74:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bb77:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  804160bb79:	89 c8                	mov    %ecx,%eax
  804160bb7b:	c1 f8 1f             	sar    $0x1f,%eax
  804160bb7e:	31 c1                	xor    %eax,%ecx
  804160bb80:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  804160bb82:	83 f9 0b             	cmp    $0xb,%ecx
  804160bb85:	7f 4d                	jg     804160bbd4 <vprintfmt+0x1f9>
  804160bb87:	48 63 c1             	movslq %ecx,%rax
  804160bb8a:	48 ba c0 ef 60 41 80 	movabs $0x804160efc0,%rdx
  804160bb91:	00 00 00 
  804160bb94:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  804160bb98:	48 85 c0             	test   %rax,%rax
  804160bb9b:	74 37                	je     804160bbd4 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  804160bb9d:	48 89 c1             	mov    %rax,%rcx
  804160bba0:	48 ba cb cf 60 41 80 	movabs $0x804160cfcb,%rdx
  804160bba7:	00 00 00 
  804160bbaa:	4c 89 fe             	mov    %r15,%rsi
  804160bbad:	4c 89 ef             	mov    %r13,%rdi
  804160bbb0:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bbb5:	48 bb 55 b9 60 41 80 	movabs $0x804160b955,%rbx
  804160bbbc:	00 00 00 
  804160bbbf:	ff d3                	callq  *%rbx
  804160bbc1:	e9 3f fe ff ff       	jmpq   804160ba05 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  804160bbc6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bbca:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bbce:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bbd2:	eb a3                	jmp    804160bb77 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  804160bbd4:	48 ba 3b ec 60 41 80 	movabs $0x804160ec3b,%rdx
  804160bbdb:	00 00 00 
  804160bbde:	4c 89 fe             	mov    %r15,%rsi
  804160bbe1:	4c 89 ef             	mov    %r13,%rdi
  804160bbe4:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bbe9:	48 bb 55 b9 60 41 80 	movabs $0x804160b955,%rbx
  804160bbf0:	00 00 00 
  804160bbf3:	ff d3                	callq  *%rbx
  804160bbf5:	e9 0b fe ff ff       	jmpq   804160ba05 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  804160bbfa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bbfd:	83 f8 2f             	cmp    $0x2f,%eax
  804160bc00:	77 4b                	ja     804160bc4d <vprintfmt+0x272>
  804160bc02:	89 c2                	mov    %eax,%edx
  804160bc04:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bc08:	83 c0 08             	add    $0x8,%eax
  804160bc0b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bc0e:	48 8b 02             	mov    (%rdx),%rax
  804160bc11:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  804160bc15:	48 85 c0             	test   %rax,%rax
  804160bc18:	0f 84 05 04 00 00    	je     804160c023 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  804160bc1e:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160bc22:	7e 06                	jle    804160bc2a <vprintfmt+0x24f>
  804160bc24:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160bc28:	75 31                	jne    804160bc5b <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160bc2a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160bc2e:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160bc32:	0f b6 00             	movzbl (%rax),%eax
  804160bc35:	0f be f8             	movsbl %al,%edi
  804160bc38:	85 ff                	test   %edi,%edi
  804160bc3a:	0f 84 c3 00 00 00    	je     804160bd03 <vprintfmt+0x328>
  804160bc40:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160bc44:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160bc48:	e9 85 00 00 00       	jmpq   804160bcd2 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  804160bc4d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bc51:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bc55:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bc59:	eb b3                	jmp    804160bc0e <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160bc5b:	49 63 f4             	movslq %r12d,%rsi
  804160bc5e:	48 89 c7             	mov    %rax,%rdi
  804160bc61:	48 b8 f3 c2 60 41 80 	movabs $0x804160c2f3,%rax
  804160bc68:	00 00 00 
  804160bc6b:	ff d0                	callq  *%rax
  804160bc6d:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160bc70:	8b 75 ac             	mov    -0x54(%rbp),%esi
  804160bc73:	85 f6                	test   %esi,%esi
  804160bc75:	7e 22                	jle    804160bc99 <vprintfmt+0x2be>
            putch(padc, putdat);
  804160bc77:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  804160bc7b:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  804160bc7f:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  804160bc83:	4c 89 fe             	mov    %r15,%rsi
  804160bc86:	89 df                	mov    %ebx,%edi
  804160bc88:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  804160bc8b:	41 83 ec 01          	sub    $0x1,%r12d
  804160bc8f:	75 f2                	jne    804160bc83 <vprintfmt+0x2a8>
  804160bc91:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160bc95:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160bc99:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160bc9d:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160bca1:	0f b6 00             	movzbl (%rax),%eax
  804160bca4:	0f be f8             	movsbl %al,%edi
  804160bca7:	85 ff                	test   %edi,%edi
  804160bca9:	0f 84 56 fd ff ff    	je     804160ba05 <vprintfmt+0x2a>
  804160bcaf:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160bcb3:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160bcb7:	eb 19                	jmp    804160bcd2 <vprintfmt+0x2f7>
            putch(ch, putdat);
  804160bcb9:	4c 89 fe             	mov    %r15,%rsi
  804160bcbc:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160bcbf:	41 83 ee 01          	sub    $0x1,%r14d
  804160bcc3:	48 83 c3 01          	add    $0x1,%rbx
  804160bcc7:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  804160bccb:	0f be f8             	movsbl %al,%edi
  804160bcce:	85 ff                	test   %edi,%edi
  804160bcd0:	74 29                	je     804160bcfb <vprintfmt+0x320>
  804160bcd2:	45 85 e4             	test   %r12d,%r12d
  804160bcd5:	78 06                	js     804160bcdd <vprintfmt+0x302>
  804160bcd7:	41 83 ec 01          	sub    $0x1,%r12d
  804160bcdb:	78 48                	js     804160bd25 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  804160bcdd:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  804160bce1:	74 d6                	je     804160bcb9 <vprintfmt+0x2de>
  804160bce3:	0f be c0             	movsbl %al,%eax
  804160bce6:	83 e8 20             	sub    $0x20,%eax
  804160bce9:	83 f8 5e             	cmp    $0x5e,%eax
  804160bcec:	76 cb                	jbe    804160bcb9 <vprintfmt+0x2de>
            putch('?', putdat);
  804160bcee:	4c 89 fe             	mov    %r15,%rsi
  804160bcf1:	bf 3f 00 00 00       	mov    $0x3f,%edi
  804160bcf6:	41 ff d5             	callq  *%r13
  804160bcf9:	eb c4                	jmp    804160bcbf <vprintfmt+0x2e4>
  804160bcfb:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160bcff:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  804160bd03:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  804160bd06:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160bd0a:	0f 8e f5 fc ff ff    	jle    804160ba05 <vprintfmt+0x2a>
          putch(' ', putdat);
  804160bd10:	4c 89 fe             	mov    %r15,%rsi
  804160bd13:	bf 20 00 00 00       	mov    $0x20,%edi
  804160bd18:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  804160bd1b:	83 eb 01             	sub    $0x1,%ebx
  804160bd1e:	75 f0                	jne    804160bd10 <vprintfmt+0x335>
  804160bd20:	e9 e0 fc ff ff       	jmpq   804160ba05 <vprintfmt+0x2a>
  804160bd25:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160bd29:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  804160bd2d:	eb d4                	jmp    804160bd03 <vprintfmt+0x328>
  if (lflag >= 2)
  804160bd2f:	83 f9 01             	cmp    $0x1,%ecx
  804160bd32:	7f 1d                	jg     804160bd51 <vprintfmt+0x376>
  else if (lflag)
  804160bd34:	85 c9                	test   %ecx,%ecx
  804160bd36:	74 5e                	je     804160bd96 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  804160bd38:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bd3b:	83 f8 2f             	cmp    $0x2f,%eax
  804160bd3e:	77 48                	ja     804160bd88 <vprintfmt+0x3ad>
  804160bd40:	89 c2                	mov    %eax,%edx
  804160bd42:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bd46:	83 c0 08             	add    $0x8,%eax
  804160bd49:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bd4c:	48 8b 1a             	mov    (%rdx),%rbx
  804160bd4f:	eb 17                	jmp    804160bd68 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  804160bd51:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bd54:	83 f8 2f             	cmp    $0x2f,%eax
  804160bd57:	77 21                	ja     804160bd7a <vprintfmt+0x39f>
  804160bd59:	89 c2                	mov    %eax,%edx
  804160bd5b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bd5f:	83 c0 08             	add    $0x8,%eax
  804160bd62:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bd65:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  804160bd68:	48 85 db             	test   %rbx,%rbx
  804160bd6b:	78 50                	js     804160bdbd <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  804160bd6d:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  804160bd70:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160bd75:	e9 b4 01 00 00       	jmpq   804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, long long);
  804160bd7a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bd7e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bd82:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bd86:	eb dd                	jmp    804160bd65 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  804160bd88:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bd8c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bd90:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bd94:	eb b6                	jmp    804160bd4c <vprintfmt+0x371>
    return va_arg(*ap, int);
  804160bd96:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bd99:	83 f8 2f             	cmp    $0x2f,%eax
  804160bd9c:	77 11                	ja     804160bdaf <vprintfmt+0x3d4>
  804160bd9e:	89 c2                	mov    %eax,%edx
  804160bda0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bda4:	83 c0 08             	add    $0x8,%eax
  804160bda7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bdaa:	48 63 1a             	movslq (%rdx),%rbx
  804160bdad:	eb b9                	jmp    804160bd68 <vprintfmt+0x38d>
  804160bdaf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bdb3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bdb7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bdbb:	eb ed                	jmp    804160bdaa <vprintfmt+0x3cf>
          putch('-', putdat);
  804160bdbd:	4c 89 fe             	mov    %r15,%rsi
  804160bdc0:	bf 2d 00 00 00       	mov    $0x2d,%edi
  804160bdc5:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  804160bdc8:	48 89 da             	mov    %rbx,%rdx
  804160bdcb:	48 f7 da             	neg    %rdx
        base = 10;
  804160bdce:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160bdd3:	e9 56 01 00 00       	jmpq   804160bf2e <vprintfmt+0x553>
  if (lflag >= 2)
  804160bdd8:	83 f9 01             	cmp    $0x1,%ecx
  804160bddb:	7f 25                	jg     804160be02 <vprintfmt+0x427>
  else if (lflag)
  804160bddd:	85 c9                	test   %ecx,%ecx
  804160bddf:	74 5e                	je     804160be3f <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  804160bde1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bde4:	83 f8 2f             	cmp    $0x2f,%eax
  804160bde7:	77 48                	ja     804160be31 <vprintfmt+0x456>
  804160bde9:	89 c2                	mov    %eax,%edx
  804160bdeb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bdef:	83 c0 08             	add    $0x8,%eax
  804160bdf2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bdf5:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160bdf8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160bdfd:	e9 2c 01 00 00       	jmpq   804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160be02:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160be05:	83 f8 2f             	cmp    $0x2f,%eax
  804160be08:	77 19                	ja     804160be23 <vprintfmt+0x448>
  804160be0a:	89 c2                	mov    %eax,%edx
  804160be0c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160be10:	83 c0 08             	add    $0x8,%eax
  804160be13:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160be16:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160be19:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160be1e:	e9 0b 01 00 00       	jmpq   804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160be23:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160be27:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160be2b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160be2f:	eb e5                	jmp    804160be16 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  804160be31:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160be35:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160be39:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160be3d:	eb b6                	jmp    804160bdf5 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  804160be3f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160be42:	83 f8 2f             	cmp    $0x2f,%eax
  804160be45:	77 18                	ja     804160be5f <vprintfmt+0x484>
  804160be47:	89 c2                	mov    %eax,%edx
  804160be49:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160be4d:	83 c0 08             	add    $0x8,%eax
  804160be50:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160be53:	8b 12                	mov    (%rdx),%edx
        base = 10;
  804160be55:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160be5a:	e9 cf 00 00 00       	jmpq   804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160be5f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160be63:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160be67:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160be6b:	eb e6                	jmp    804160be53 <vprintfmt+0x478>
  if (lflag >= 2)
  804160be6d:	83 f9 01             	cmp    $0x1,%ecx
  804160be70:	7f 25                	jg     804160be97 <vprintfmt+0x4bc>
  else if (lflag)
  804160be72:	85 c9                	test   %ecx,%ecx
  804160be74:	74 5b                	je     804160bed1 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  804160be76:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160be79:	83 f8 2f             	cmp    $0x2f,%eax
  804160be7c:	77 45                	ja     804160bec3 <vprintfmt+0x4e8>
  804160be7e:	89 c2                	mov    %eax,%edx
  804160be80:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160be84:	83 c0 08             	add    $0x8,%eax
  804160be87:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160be8a:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160be8d:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160be92:	e9 97 00 00 00       	jmpq   804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160be97:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160be9a:	83 f8 2f             	cmp    $0x2f,%eax
  804160be9d:	77 16                	ja     804160beb5 <vprintfmt+0x4da>
  804160be9f:	89 c2                	mov    %eax,%edx
  804160bea1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bea5:	83 c0 08             	add    $0x8,%eax
  804160bea8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160beab:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160beae:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160beb3:	eb 79                	jmp    804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160beb5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160beb9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bebd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bec1:	eb e8                	jmp    804160beab <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  804160bec3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bec7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160becb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160becf:	eb b9                	jmp    804160be8a <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  804160bed1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bed4:	83 f8 2f             	cmp    $0x2f,%eax
  804160bed7:	77 15                	ja     804160beee <vprintfmt+0x513>
  804160bed9:	89 c2                	mov    %eax,%edx
  804160bedb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bedf:	83 c0 08             	add    $0x8,%eax
  804160bee2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bee5:	8b 12                	mov    (%rdx),%edx
        base = 8;
  804160bee7:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160beec:	eb 40                	jmp    804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160beee:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bef2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bef6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160befa:	eb e9                	jmp    804160bee5 <vprintfmt+0x50a>
        putch('0', putdat);
  804160befc:	4c 89 fe             	mov    %r15,%rsi
  804160beff:	bf 30 00 00 00       	mov    $0x30,%edi
  804160bf04:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  804160bf07:	4c 89 fe             	mov    %r15,%rsi
  804160bf0a:	bf 78 00 00 00       	mov    $0x78,%edi
  804160bf0f:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160bf12:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bf15:	83 f8 2f             	cmp    $0x2f,%eax
  804160bf18:	77 34                	ja     804160bf4e <vprintfmt+0x573>
  804160bf1a:	89 c2                	mov    %eax,%edx
  804160bf1c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bf20:	83 c0 08             	add    $0x8,%eax
  804160bf23:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bf26:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160bf29:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  804160bf2e:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  804160bf33:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  804160bf37:	4c 89 fe             	mov    %r15,%rsi
  804160bf3a:	4c 89 ef             	mov    %r13,%rdi
  804160bf3d:	48 b8 b1 b8 60 41 80 	movabs $0x804160b8b1,%rax
  804160bf44:	00 00 00 
  804160bf47:	ff d0                	callq  *%rax
        break;
  804160bf49:	e9 b7 fa ff ff       	jmpq   804160ba05 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160bf4e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bf52:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bf56:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bf5a:	eb ca                	jmp    804160bf26 <vprintfmt+0x54b>
  if (lflag >= 2)
  804160bf5c:	83 f9 01             	cmp    $0x1,%ecx
  804160bf5f:	7f 22                	jg     804160bf83 <vprintfmt+0x5a8>
  else if (lflag)
  804160bf61:	85 c9                	test   %ecx,%ecx
  804160bf63:	74 58                	je     804160bfbd <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  804160bf65:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bf68:	83 f8 2f             	cmp    $0x2f,%eax
  804160bf6b:	77 42                	ja     804160bfaf <vprintfmt+0x5d4>
  804160bf6d:	89 c2                	mov    %eax,%edx
  804160bf6f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bf73:	83 c0 08             	add    $0x8,%eax
  804160bf76:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bf79:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160bf7c:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160bf81:	eb ab                	jmp    804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160bf83:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bf86:	83 f8 2f             	cmp    $0x2f,%eax
  804160bf89:	77 16                	ja     804160bfa1 <vprintfmt+0x5c6>
  804160bf8b:	89 c2                	mov    %eax,%edx
  804160bf8d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bf91:	83 c0 08             	add    $0x8,%eax
  804160bf94:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bf97:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160bf9a:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160bf9f:	eb 8d                	jmp    804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160bfa1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bfa5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bfa9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bfad:	eb e8                	jmp    804160bf97 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  804160bfaf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bfb3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bfb7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bfbb:	eb bc                	jmp    804160bf79 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  804160bfbd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bfc0:	83 f8 2f             	cmp    $0x2f,%eax
  804160bfc3:	77 18                	ja     804160bfdd <vprintfmt+0x602>
  804160bfc5:	89 c2                	mov    %eax,%edx
  804160bfc7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bfcb:	83 c0 08             	add    $0x8,%eax
  804160bfce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bfd1:	8b 12                	mov    (%rdx),%edx
        base = 16;
  804160bfd3:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160bfd8:	e9 51 ff ff ff       	jmpq   804160bf2e <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160bfdd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bfe1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bfe5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bfe9:	eb e6                	jmp    804160bfd1 <vprintfmt+0x5f6>
        putch(ch, putdat);
  804160bfeb:	4c 89 fe             	mov    %r15,%rsi
  804160bfee:	bf 25 00 00 00       	mov    $0x25,%edi
  804160bff3:	41 ff d5             	callq  *%r13
        break;
  804160bff6:	e9 0a fa ff ff       	jmpq   804160ba05 <vprintfmt+0x2a>
        putch('%', putdat);
  804160bffb:	4c 89 fe             	mov    %r15,%rsi
  804160bffe:	bf 25 00 00 00       	mov    $0x25,%edi
  804160c003:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160c006:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  804160c00a:	0f 84 15 fa ff ff    	je     804160ba25 <vprintfmt+0x4a>
  804160c010:	49 89 de             	mov    %rbx,%r14
  804160c013:	49 83 ee 01          	sub    $0x1,%r14
  804160c017:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  804160c01c:	75 f5                	jne    804160c013 <vprintfmt+0x638>
  804160c01e:	e9 e2 f9 ff ff       	jmpq   804160ba05 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  804160c023:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160c027:	74 06                	je     804160c02f <vprintfmt+0x654>
  804160c029:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160c02d:	7f 21                	jg     804160c050 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160c02f:	bf 28 00 00 00       	mov    $0x28,%edi
  804160c034:	48 bb 35 ec 60 41 80 	movabs $0x804160ec35,%rbx
  804160c03b:	00 00 00 
  804160c03e:	b8 28 00 00 00       	mov    $0x28,%eax
  804160c043:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160c047:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160c04b:	e9 82 fc ff ff       	jmpq   804160bcd2 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160c050:	49 63 f4             	movslq %r12d,%rsi
  804160c053:	48 bf 34 ec 60 41 80 	movabs $0x804160ec34,%rdi
  804160c05a:	00 00 00 
  804160c05d:	48 b8 f3 c2 60 41 80 	movabs $0x804160c2f3,%rax
  804160c064:	00 00 00 
  804160c067:	ff d0                	callq  *%rax
  804160c069:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160c06c:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  804160c06f:	48 be 34 ec 60 41 80 	movabs $0x804160ec34,%rsi
  804160c076:	00 00 00 
  804160c079:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  804160c07d:	85 c0                	test   %eax,%eax
  804160c07f:	0f 8f f2 fb ff ff    	jg     804160bc77 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160c085:	48 bb 35 ec 60 41 80 	movabs $0x804160ec35,%rbx
  804160c08c:	00 00 00 
  804160c08f:	b8 28 00 00 00       	mov    $0x28,%eax
  804160c094:	bf 28 00 00 00       	mov    $0x28,%edi
  804160c099:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160c09d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160c0a1:	e9 2c fc ff ff       	jmpq   804160bcd2 <vprintfmt+0x2f7>
}
  804160c0a6:	48 83 c4 48          	add    $0x48,%rsp
  804160c0aa:	5b                   	pop    %rbx
  804160c0ab:	41 5c                	pop    %r12
  804160c0ad:	41 5d                	pop    %r13
  804160c0af:	41 5e                	pop    %r14
  804160c0b1:	41 5f                	pop    %r15
  804160c0b3:	5d                   	pop    %rbp
  804160c0b4:	c3                   	retq   

000000804160c0b5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  804160c0b5:	55                   	push   %rbp
  804160c0b6:	48 89 e5             	mov    %rsp,%rbp
  804160c0b9:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  804160c0bd:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  804160c0c1:	48 63 c6             	movslq %esi,%rax
  804160c0c4:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  804160c0c9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  804160c0cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  804160c0d4:	48 85 ff             	test   %rdi,%rdi
  804160c0d7:	74 2a                	je     804160c103 <vsnprintf+0x4e>
  804160c0d9:	85 f6                	test   %esi,%esi
  804160c0db:	7e 26                	jle    804160c103 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  804160c0dd:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  804160c0e1:	48 bf 3d b9 60 41 80 	movabs $0x804160b93d,%rdi
  804160c0e8:	00 00 00 
  804160c0eb:	48 b8 db b9 60 41 80 	movabs $0x804160b9db,%rax
  804160c0f2:	00 00 00 
  804160c0f5:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  804160c0f7:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160c0fb:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  804160c0fe:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  804160c101:	c9                   	leaveq 
  804160c102:	c3                   	retq   
    return -E_INVAL;
  804160c103:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160c108:	eb f7                	jmp    804160c101 <vsnprintf+0x4c>

000000804160c10a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  804160c10a:	55                   	push   %rbp
  804160c10b:	48 89 e5             	mov    %rsp,%rbp
  804160c10e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160c115:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160c11c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160c123:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160c12a:	84 c0                	test   %al,%al
  804160c12c:	74 20                	je     804160c14e <snprintf+0x44>
  804160c12e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160c132:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160c136:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160c13a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160c13e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160c142:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160c146:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160c14a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  804160c14e:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160c155:	00 00 00 
  804160c158:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160c15f:	00 00 00 
  804160c162:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160c166:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160c16d:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160c174:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  804160c17b:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160c182:	48 b8 b5 c0 60 41 80 	movabs $0x804160c0b5,%rax
  804160c189:	00 00 00 
  804160c18c:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  804160c18e:	c9                   	leaveq 
  804160c18f:	c3                   	retq   

000000804160c190 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  804160c190:	55                   	push   %rbp
  804160c191:	48 89 e5             	mov    %rsp,%rbp
  804160c194:	41 57                	push   %r15
  804160c196:	41 56                	push   %r14
  804160c198:	41 55                	push   %r13
  804160c19a:	41 54                	push   %r12
  804160c19c:	53                   	push   %rbx
  804160c19d:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  804160c1a1:	48 85 ff             	test   %rdi,%rdi
  804160c1a4:	74 1e                	je     804160c1c4 <readline+0x34>
    cprintf("%s", prompt);
  804160c1a6:	48 89 fe             	mov    %rdi,%rsi
  804160c1a9:	48 bf cb cf 60 41 80 	movabs $0x804160cfcb,%rdi
  804160c1b0:	00 00 00 
  804160c1b3:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c1b8:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160c1bf:	00 00 00 
  804160c1c2:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  804160c1c4:	bf 00 00 00 00       	mov    $0x0,%edi
  804160c1c9:	48 b8 19 0d 60 41 80 	movabs $0x8041600d19,%rax
  804160c1d0:	00 00 00 
  804160c1d3:	ff d0                	callq  *%rax
  804160c1d5:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  804160c1d8:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  804160c1de:	49 bd f9 0c 60 41 80 	movabs $0x8041600cf9,%r13
  804160c1e5:	00 00 00 
        cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  804160c1e8:	49 bf e7 0c 60 41 80 	movabs $0x8041600ce7,%r15
  804160c1ef:	00 00 00 
  804160c1f2:	eb 46                	jmp    804160c23a <readline+0xaa>
      return NULL;
  804160c1f4:	b8 00 00 00 00       	mov    $0x0,%eax
      if (c != -E_EOF)
  804160c1f9:	83 fb f5             	cmp    $0xfffffff5,%ebx
  804160c1fc:	75 0f                	jne    804160c20d <readline+0x7d>
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  804160c1fe:	48 83 c4 08          	add    $0x8,%rsp
  804160c202:	5b                   	pop    %rbx
  804160c203:	41 5c                	pop    %r12
  804160c205:	41 5d                	pop    %r13
  804160c207:	41 5e                	pop    %r14
  804160c209:	41 5f                	pop    %r15
  804160c20b:	5d                   	pop    %rbp
  804160c20c:	c3                   	retq   
        cprintf("read error: %i\n", c);
  804160c20d:	89 de                	mov    %ebx,%esi
  804160c20f:	48 bf 20 f0 60 41 80 	movabs $0x804160f020,%rdi
  804160c216:	00 00 00 
  804160c219:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160c220:	00 00 00 
  804160c223:	ff d2                	callq  *%rdx
      return NULL;
  804160c225:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c22a:	eb d2                	jmp    804160c1fe <readline+0x6e>
      if (i > 0) {
  804160c22c:	45 85 e4             	test   %r12d,%r12d
  804160c22f:	7e 09                	jle    804160c23a <readline+0xaa>
        if (echoing) {
  804160c231:	45 85 f6             	test   %r14d,%r14d
  804160c234:	75 41                	jne    804160c277 <readline+0xe7>
        i--;
  804160c236:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  804160c23a:	41 ff d5             	callq  *%r13
  804160c23d:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  804160c23f:	85 c0                	test   %eax,%eax
  804160c241:	78 b1                	js     804160c1f4 <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  804160c243:	83 f8 08             	cmp    $0x8,%eax
  804160c246:	74 e4                	je     804160c22c <readline+0x9c>
  804160c248:	83 f8 7f             	cmp    $0x7f,%eax
  804160c24b:	74 df                	je     804160c22c <readline+0x9c>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  804160c24d:	83 f8 1f             	cmp    $0x1f,%eax
  804160c250:	7e 46                	jle    804160c298 <readline+0x108>
  804160c252:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  804160c259:	7f 3d                	jg     804160c298 <readline+0x108>
      if (echoing)
  804160c25b:	45 85 f6             	test   %r14d,%r14d
  804160c25e:	75 31                	jne    804160c291 <readline+0x101>
      buf[i++] = c;
  804160c260:	49 63 c4             	movslq %r12d,%rax
  804160c263:	48 b9 20 56 88 41 80 	movabs $0x8041885620,%rcx
  804160c26a:	00 00 00 
  804160c26d:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  804160c270:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  804160c275:	eb c3                	jmp    804160c23a <readline+0xaa>
          cputchar('\b');
  804160c277:	bf 08 00 00 00       	mov    $0x8,%edi
  804160c27c:	41 ff d7             	callq  *%r15
          cputchar(' ');
  804160c27f:	bf 20 00 00 00       	mov    $0x20,%edi
  804160c284:	41 ff d7             	callq  *%r15
          cputchar('\b');
  804160c287:	bf 08 00 00 00       	mov    $0x8,%edi
  804160c28c:	41 ff d7             	callq  *%r15
  804160c28f:	eb a5                	jmp    804160c236 <readline+0xa6>
        cputchar(c);
  804160c291:	89 c7                	mov    %eax,%edi
  804160c293:	41 ff d7             	callq  *%r15
  804160c296:	eb c8                	jmp    804160c260 <readline+0xd0>
    } else if (c == '\n' || c == '\r') {
  804160c298:	83 fb 0a             	cmp    $0xa,%ebx
  804160c29b:	74 05                	je     804160c2a2 <readline+0x112>
  804160c29d:	83 fb 0d             	cmp    $0xd,%ebx
  804160c2a0:	75 98                	jne    804160c23a <readline+0xaa>
      if (echoing)
  804160c2a2:	45 85 f6             	test   %r14d,%r14d
  804160c2a5:	75 17                	jne    804160c2be <readline+0x12e>
      buf[i] = 0;
  804160c2a7:	48 b8 20 56 88 41 80 	movabs $0x8041885620,%rax
  804160c2ae:	00 00 00 
  804160c2b1:	4d 63 e4             	movslq %r12d,%r12
  804160c2b4:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  804160c2b9:	e9 40 ff ff ff       	jmpq   804160c1fe <readline+0x6e>
        cputchar('\n');
  804160c2be:	bf 0a 00 00 00       	mov    $0xa,%edi
  804160c2c3:	48 b8 e7 0c 60 41 80 	movabs $0x8041600ce7,%rax
  804160c2ca:	00 00 00 
  804160c2cd:	ff d0                	callq  *%rax
  804160c2cf:	eb d6                	jmp    804160c2a7 <readline+0x117>

000000804160c2d1 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  804160c2d1:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160c2d4:	74 17                	je     804160c2ed <strlen+0x1c>
  804160c2d6:	48 89 fa             	mov    %rdi,%rdx
  804160c2d9:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160c2de:	29 f9                	sub    %edi,%ecx
    n++;
  804160c2e0:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  804160c2e3:	48 83 c2 01          	add    $0x1,%rdx
  804160c2e7:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160c2ea:	75 f4                	jne    804160c2e0 <strlen+0xf>
  804160c2ec:	c3                   	retq   
  804160c2ed:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160c2f2:	c3                   	retq   

000000804160c2f3 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160c2f3:	48 85 f6             	test   %rsi,%rsi
  804160c2f6:	74 24                	je     804160c31c <strnlen+0x29>
  804160c2f8:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160c2fb:	74 25                	je     804160c322 <strnlen+0x2f>
  804160c2fd:	48 01 fe             	add    %rdi,%rsi
  804160c300:	48 89 fa             	mov    %rdi,%rdx
  804160c303:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160c308:	29 f9                	sub    %edi,%ecx
    n++;
  804160c30a:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160c30d:	48 83 c2 01          	add    $0x1,%rdx
  804160c311:	48 39 f2             	cmp    %rsi,%rdx
  804160c314:	74 11                	je     804160c327 <strnlen+0x34>
  804160c316:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160c319:	75 ef                	jne    804160c30a <strnlen+0x17>
  804160c31b:	c3                   	retq   
  804160c31c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c321:	c3                   	retq   
  804160c322:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160c327:	c3                   	retq   

000000804160c328 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  804160c328:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  804160c32b:	ba 00 00 00 00       	mov    $0x0,%edx
  804160c330:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  804160c334:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  804160c337:	48 83 c2 01          	add    $0x1,%rdx
  804160c33b:	84 c9                	test   %cl,%cl
  804160c33d:	75 f1                	jne    804160c330 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  804160c33f:	c3                   	retq   

000000804160c340 <strcat>:

char *
strcat(char *dst, const char *src) {
  804160c340:	55                   	push   %rbp
  804160c341:	48 89 e5             	mov    %rsp,%rbp
  804160c344:	41 54                	push   %r12
  804160c346:	53                   	push   %rbx
  804160c347:	48 89 fb             	mov    %rdi,%rbx
  804160c34a:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  804160c34d:	48 b8 d1 c2 60 41 80 	movabs $0x804160c2d1,%rax
  804160c354:	00 00 00 
  804160c357:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  804160c359:	48 63 f8             	movslq %eax,%rdi
  804160c35c:	48 01 df             	add    %rbx,%rdi
  804160c35f:	4c 89 e6             	mov    %r12,%rsi
  804160c362:	48 b8 28 c3 60 41 80 	movabs $0x804160c328,%rax
  804160c369:	00 00 00 
  804160c36c:	ff d0                	callq  *%rax
  return dst;
}
  804160c36e:	48 89 d8             	mov    %rbx,%rax
  804160c371:	5b                   	pop    %rbx
  804160c372:	41 5c                	pop    %r12
  804160c374:	5d                   	pop    %rbp
  804160c375:	c3                   	retq   

000000804160c376 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  804160c376:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  804160c379:	48 85 d2             	test   %rdx,%rdx
  804160c37c:	74 1f                	je     804160c39d <strncpy+0x27>
  804160c37e:	48 01 fa             	add    %rdi,%rdx
  804160c381:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  804160c384:	48 83 c1 01          	add    $0x1,%rcx
  804160c388:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160c38c:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  804160c390:	41 80 f8 01          	cmp    $0x1,%r8b
  804160c394:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  804160c398:	48 39 ca             	cmp    %rcx,%rdx
  804160c39b:	75 e7                	jne    804160c384 <strncpy+0xe>
  }
  return ret;
}
  804160c39d:	c3                   	retq   

000000804160c39e <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  804160c39e:	48 89 f8             	mov    %rdi,%rax
  804160c3a1:	48 85 d2             	test   %rdx,%rdx
  804160c3a4:	74 36                	je     804160c3dc <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  804160c3a6:	48 83 fa 01          	cmp    $0x1,%rdx
  804160c3aa:	74 2d                	je     804160c3d9 <strlcpy+0x3b>
  804160c3ac:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160c3b0:	45 84 c0             	test   %r8b,%r8b
  804160c3b3:	74 24                	je     804160c3d9 <strlcpy+0x3b>
  804160c3b5:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  804160c3b9:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  804160c3be:	48 83 c0 01          	add    $0x1,%rax
  804160c3c2:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  804160c3c6:	48 39 d1             	cmp    %rdx,%rcx
  804160c3c9:	74 0e                	je     804160c3d9 <strlcpy+0x3b>
  804160c3cb:	48 83 c1 01          	add    $0x1,%rcx
  804160c3cf:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  804160c3d4:	45 84 c0             	test   %r8b,%r8b
  804160c3d7:	75 e5                	jne    804160c3be <strlcpy+0x20>
    *dst = '\0';
  804160c3d9:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  804160c3dc:	48 29 f8             	sub    %rdi,%rax
}
  804160c3df:	c3                   	retq   

000000804160c3e0 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  804160c3e0:	0f b6 07             	movzbl (%rdi),%eax
  804160c3e3:	84 c0                	test   %al,%al
  804160c3e5:	74 17                	je     804160c3fe <strcmp+0x1e>
  804160c3e7:	3a 06                	cmp    (%rsi),%al
  804160c3e9:	75 13                	jne    804160c3fe <strcmp+0x1e>
    p++, q++;
  804160c3eb:	48 83 c7 01          	add    $0x1,%rdi
  804160c3ef:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  804160c3f3:	0f b6 07             	movzbl (%rdi),%eax
  804160c3f6:	84 c0                	test   %al,%al
  804160c3f8:	74 04                	je     804160c3fe <strcmp+0x1e>
  804160c3fa:	3a 06                	cmp    (%rsi),%al
  804160c3fc:	74 ed                	je     804160c3eb <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  804160c3fe:	0f b6 c0             	movzbl %al,%eax
  804160c401:	0f b6 16             	movzbl (%rsi),%edx
  804160c404:	29 d0                	sub    %edx,%eax
}
  804160c406:	c3                   	retq   

000000804160c407 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  804160c407:	48 85 d2             	test   %rdx,%rdx
  804160c40a:	74 2f                	je     804160c43b <strncmp+0x34>
  804160c40c:	0f b6 07             	movzbl (%rdi),%eax
  804160c40f:	84 c0                	test   %al,%al
  804160c411:	74 1f                	je     804160c432 <strncmp+0x2b>
  804160c413:	3a 06                	cmp    (%rsi),%al
  804160c415:	75 1b                	jne    804160c432 <strncmp+0x2b>
  804160c417:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  804160c41a:	48 83 c7 01          	add    $0x1,%rdi
  804160c41e:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  804160c422:	48 39 d7             	cmp    %rdx,%rdi
  804160c425:	74 1a                	je     804160c441 <strncmp+0x3a>
  804160c427:	0f b6 07             	movzbl (%rdi),%eax
  804160c42a:	84 c0                	test   %al,%al
  804160c42c:	74 04                	je     804160c432 <strncmp+0x2b>
  804160c42e:	3a 06                	cmp    (%rsi),%al
  804160c430:	74 e8                	je     804160c41a <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  804160c432:	0f b6 07             	movzbl (%rdi),%eax
  804160c435:	0f b6 16             	movzbl (%rsi),%edx
  804160c438:	29 d0                	sub    %edx,%eax
}
  804160c43a:	c3                   	retq   
    return 0;
  804160c43b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c440:	c3                   	retq   
  804160c441:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c446:	c3                   	retq   

000000804160c447 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  804160c447:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  804160c449:	0f b6 07             	movzbl (%rdi),%eax
  804160c44c:	84 c0                	test   %al,%al
  804160c44e:	74 1e                	je     804160c46e <strchr+0x27>
    if (*s == c)
  804160c450:	40 38 c6             	cmp    %al,%sil
  804160c453:	74 1f                	je     804160c474 <strchr+0x2d>
  for (; *s; s++)
  804160c455:	48 83 c7 01          	add    $0x1,%rdi
  804160c459:	0f b6 07             	movzbl (%rdi),%eax
  804160c45c:	84 c0                	test   %al,%al
  804160c45e:	74 08                	je     804160c468 <strchr+0x21>
    if (*s == c)
  804160c460:	38 d0                	cmp    %dl,%al
  804160c462:	75 f1                	jne    804160c455 <strchr+0xe>
  for (; *s; s++)
  804160c464:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  804160c467:	c3                   	retq   
  return 0;
  804160c468:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c46d:	c3                   	retq   
  804160c46e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c473:	c3                   	retq   
    if (*s == c)
  804160c474:	48 89 f8             	mov    %rdi,%rax
  804160c477:	c3                   	retq   

000000804160c478 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  804160c478:	48 89 f8             	mov    %rdi,%rax
  804160c47b:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  804160c47d:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  804160c480:	40 38 f2             	cmp    %sil,%dl
  804160c483:	74 13                	je     804160c498 <strfind+0x20>
  804160c485:	84 d2                	test   %dl,%dl
  804160c487:	74 0f                	je     804160c498 <strfind+0x20>
  for (; *s; s++)
  804160c489:	48 83 c0 01          	add    $0x1,%rax
  804160c48d:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  804160c490:	38 ca                	cmp    %cl,%dl
  804160c492:	74 04                	je     804160c498 <strfind+0x20>
  804160c494:	84 d2                	test   %dl,%dl
  804160c496:	75 f1                	jne    804160c489 <strfind+0x11>
      break;
  return (char *)s;
}
  804160c498:	c3                   	retq   

000000804160c499 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  804160c499:	48 85 d2             	test   %rdx,%rdx
  804160c49c:	74 3a                	je     804160c4d8 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160c49e:	48 89 f8             	mov    %rdi,%rax
  804160c4a1:	48 09 d0             	or     %rdx,%rax
  804160c4a4:	a8 03                	test   $0x3,%al
  804160c4a6:	75 28                	jne    804160c4d0 <memset+0x37>
    uint32_t k = c & 0xFFU;
  804160c4a8:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  804160c4ac:	89 f0                	mov    %esi,%eax
  804160c4ae:	c1 e0 08             	shl    $0x8,%eax
  804160c4b1:	89 f1                	mov    %esi,%ecx
  804160c4b3:	c1 e1 18             	shl    $0x18,%ecx
  804160c4b6:	41 89 f0             	mov    %esi,%r8d
  804160c4b9:	41 c1 e0 10          	shl    $0x10,%r8d
  804160c4bd:	44 09 c1             	or     %r8d,%ecx
  804160c4c0:	09 ce                	or     %ecx,%esi
  804160c4c2:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  804160c4c4:	48 c1 ea 02          	shr    $0x2,%rdx
  804160c4c8:	48 89 d1             	mov    %rdx,%rcx
  804160c4cb:	fc                   	cld    
  804160c4cc:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160c4ce:	eb 08                	jmp    804160c4d8 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  804160c4d0:	89 f0                	mov    %esi,%eax
  804160c4d2:	48 89 d1             	mov    %rdx,%rcx
  804160c4d5:	fc                   	cld    
  804160c4d6:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  804160c4d8:	48 89 f8             	mov    %rdi,%rax
  804160c4db:	c3                   	retq   

000000804160c4dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  804160c4dc:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  804160c4df:	48 39 fe             	cmp    %rdi,%rsi
  804160c4e2:	73 40                	jae    804160c524 <memmove+0x48>
  804160c4e4:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  804160c4e8:	48 39 f9             	cmp    %rdi,%rcx
  804160c4eb:	76 37                	jbe    804160c524 <memmove+0x48>
    s += n;
    d += n;
  804160c4ed:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160c4f1:	48 89 fe             	mov    %rdi,%rsi
  804160c4f4:	48 09 d6             	or     %rdx,%rsi
  804160c4f7:	48 09 ce             	or     %rcx,%rsi
  804160c4fa:	40 f6 c6 03          	test   $0x3,%sil
  804160c4fe:	75 14                	jne    804160c514 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  804160c500:	48 83 ef 04          	sub    $0x4,%rdi
  804160c504:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  804160c508:	48 c1 ea 02          	shr    $0x2,%rdx
  804160c50c:	48 89 d1             	mov    %rdx,%rcx
  804160c50f:	fd                   	std    
  804160c510:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160c512:	eb 0e                	jmp    804160c522 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  804160c514:	48 83 ef 01          	sub    $0x1,%rdi
  804160c518:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  804160c51c:	48 89 d1             	mov    %rdx,%rcx
  804160c51f:	fd                   	std    
  804160c520:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  804160c522:	fc                   	cld    
  804160c523:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160c524:	48 89 c1             	mov    %rax,%rcx
  804160c527:	48 09 d1             	or     %rdx,%rcx
  804160c52a:	48 09 f1             	or     %rsi,%rcx
  804160c52d:	f6 c1 03             	test   $0x3,%cl
  804160c530:	75 0e                	jne    804160c540 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  804160c532:	48 c1 ea 02          	shr    $0x2,%rdx
  804160c536:	48 89 d1             	mov    %rdx,%rcx
  804160c539:	48 89 c7             	mov    %rax,%rdi
  804160c53c:	fc                   	cld    
  804160c53d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160c53f:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  804160c540:	48 89 c7             	mov    %rax,%rdi
  804160c543:	48 89 d1             	mov    %rdx,%rcx
  804160c546:	fc                   	cld    
  804160c547:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  804160c549:	c3                   	retq   

000000804160c54a <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  804160c54a:	55                   	push   %rbp
  804160c54b:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  804160c54e:	48 b8 dc c4 60 41 80 	movabs $0x804160c4dc,%rax
  804160c555:	00 00 00 
  804160c558:	ff d0                	callq  *%rax
}
  804160c55a:	5d                   	pop    %rbp
  804160c55b:	c3                   	retq   

000000804160c55c <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  804160c55c:	55                   	push   %rbp
  804160c55d:	48 89 e5             	mov    %rsp,%rbp
  804160c560:	41 57                	push   %r15
  804160c562:	41 56                	push   %r14
  804160c564:	41 55                	push   %r13
  804160c566:	41 54                	push   %r12
  804160c568:	53                   	push   %rbx
  804160c569:	48 83 ec 08          	sub    $0x8,%rsp
  804160c56d:	49 89 fe             	mov    %rdi,%r14
  804160c570:	49 89 f7             	mov    %rsi,%r15
  804160c573:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  804160c576:	48 89 f7             	mov    %rsi,%rdi
  804160c579:	48 b8 d1 c2 60 41 80 	movabs $0x804160c2d1,%rax
  804160c580:	00 00 00 
  804160c583:	ff d0                	callq  *%rax
  804160c585:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  804160c588:	4c 89 ee             	mov    %r13,%rsi
  804160c58b:	4c 89 f7             	mov    %r14,%rdi
  804160c58e:	48 b8 f3 c2 60 41 80 	movabs $0x804160c2f3,%rax
  804160c595:	00 00 00 
  804160c598:	ff d0                	callq  *%rax
  804160c59a:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  804160c59d:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  804160c5a1:	4d 39 e5             	cmp    %r12,%r13
  804160c5a4:	74 26                	je     804160c5cc <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  804160c5a6:	4c 89 e8             	mov    %r13,%rax
  804160c5a9:	4c 29 e0             	sub    %r12,%rax
  804160c5ac:	48 39 d8             	cmp    %rbx,%rax
  804160c5af:	76 2a                	jbe    804160c5db <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  804160c5b1:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  804160c5b5:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160c5b9:	4c 89 fe             	mov    %r15,%rsi
  804160c5bc:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160c5c3:	00 00 00 
  804160c5c6:	ff d0                	callq  *%rax
  return dstlen + srclen;
  804160c5c8:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  804160c5cc:	48 83 c4 08          	add    $0x8,%rsp
  804160c5d0:	5b                   	pop    %rbx
  804160c5d1:	41 5c                	pop    %r12
  804160c5d3:	41 5d                	pop    %r13
  804160c5d5:	41 5e                	pop    %r14
  804160c5d7:	41 5f                	pop    %r15
  804160c5d9:	5d                   	pop    %rbp
  804160c5da:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  804160c5db:	49 83 ed 01          	sub    $0x1,%r13
  804160c5df:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160c5e3:	4c 89 ea             	mov    %r13,%rdx
  804160c5e6:	4c 89 fe             	mov    %r15,%rsi
  804160c5e9:	48 b8 4a c5 60 41 80 	movabs $0x804160c54a,%rax
  804160c5f0:	00 00 00 
  804160c5f3:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  804160c5f5:	4d 01 ee             	add    %r13,%r14
  804160c5f8:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  804160c5fd:	eb c9                	jmp    804160c5c8 <strlcat+0x6c>

000000804160c5ff <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  804160c5ff:	48 85 d2             	test   %rdx,%rdx
  804160c602:	74 3a                	je     804160c63e <memcmp+0x3f>
    if (*s1 != *s2)
  804160c604:	0f b6 0f             	movzbl (%rdi),%ecx
  804160c607:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160c60b:	44 38 c1             	cmp    %r8b,%cl
  804160c60e:	75 1d                	jne    804160c62d <memcmp+0x2e>
  804160c610:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  804160c615:	48 39 d0             	cmp    %rdx,%rax
  804160c618:	74 1e                	je     804160c638 <memcmp+0x39>
    if (*s1 != *s2)
  804160c61a:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  804160c61e:	48 83 c0 01          	add    $0x1,%rax
  804160c622:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  804160c628:	44 38 c1             	cmp    %r8b,%cl
  804160c62b:	74 e8                	je     804160c615 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  804160c62d:	0f b6 c1             	movzbl %cl,%eax
  804160c630:	45 0f b6 c0          	movzbl %r8b,%r8d
  804160c634:	44 29 c0             	sub    %r8d,%eax
  804160c637:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  804160c638:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c63d:	c3                   	retq   
  804160c63e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160c643:	c3                   	retq   

000000804160c644 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  804160c644:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  804160c648:	48 39 c7             	cmp    %rax,%rdi
  804160c64b:	73 19                	jae    804160c666 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c64d:	89 f2                	mov    %esi,%edx
  804160c64f:	40 38 37             	cmp    %sil,(%rdi)
  804160c652:	74 16                	je     804160c66a <memfind+0x26>
  for (; s < ends; s++)
  804160c654:	48 83 c7 01          	add    $0x1,%rdi
  804160c658:	48 39 f8             	cmp    %rdi,%rax
  804160c65b:	74 08                	je     804160c665 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c65d:	38 17                	cmp    %dl,(%rdi)
  804160c65f:	75 f3                	jne    804160c654 <memfind+0x10>
  for (; s < ends; s++)
  804160c661:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  804160c664:	c3                   	retq   
  804160c665:	c3                   	retq   
  for (; s < ends; s++)
  804160c666:	48 89 f8             	mov    %rdi,%rax
  804160c669:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c66a:	48 89 f8             	mov    %rdi,%rax
  804160c66d:	c3                   	retq   

000000804160c66e <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  804160c66e:	0f b6 07             	movzbl (%rdi),%eax
  804160c671:	3c 20                	cmp    $0x20,%al
  804160c673:	74 04                	je     804160c679 <strtol+0xb>
  804160c675:	3c 09                	cmp    $0x9,%al
  804160c677:	75 0f                	jne    804160c688 <strtol+0x1a>
    s++;
  804160c679:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  804160c67d:	0f b6 07             	movzbl (%rdi),%eax
  804160c680:	3c 20                	cmp    $0x20,%al
  804160c682:	74 f5                	je     804160c679 <strtol+0xb>
  804160c684:	3c 09                	cmp    $0x9,%al
  804160c686:	74 f1                	je     804160c679 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  804160c688:	3c 2b                	cmp    $0x2b,%al
  804160c68a:	74 2b                	je     804160c6b7 <strtol+0x49>
  int neg  = 0;
  804160c68c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  804160c692:	3c 2d                	cmp    $0x2d,%al
  804160c694:	74 2d                	je     804160c6c3 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160c696:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  804160c69c:	75 0f                	jne    804160c6ad <strtol+0x3f>
  804160c69e:	80 3f 30             	cmpb   $0x30,(%rdi)
  804160c6a1:	74 2c                	je     804160c6cf <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  804160c6a3:	85 d2                	test   %edx,%edx
  804160c6a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  804160c6aa:	0f 44 d0             	cmove  %eax,%edx
  804160c6ad:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  804160c6b2:	4c 63 d2             	movslq %edx,%r10
  804160c6b5:	eb 5c                	jmp    804160c713 <strtol+0xa5>
    s++;
  804160c6b7:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  804160c6bb:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160c6c1:	eb d3                	jmp    804160c696 <strtol+0x28>
    s++, neg = 1;
  804160c6c3:	48 83 c7 01          	add    $0x1,%rdi
  804160c6c7:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160c6cd:	eb c7                	jmp    804160c696 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160c6cf:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  804160c6d3:	74 0f                	je     804160c6e4 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  804160c6d5:	85 d2                	test   %edx,%edx
  804160c6d7:	75 d4                	jne    804160c6ad <strtol+0x3f>
    s++, base = 8;
  804160c6d9:	48 83 c7 01          	add    $0x1,%rdi
  804160c6dd:	ba 08 00 00 00       	mov    $0x8,%edx
  804160c6e2:	eb c9                	jmp    804160c6ad <strtol+0x3f>
    s += 2, base = 16;
  804160c6e4:	48 83 c7 02          	add    $0x2,%rdi
  804160c6e8:	ba 10 00 00 00       	mov    $0x10,%edx
  804160c6ed:	eb be                	jmp    804160c6ad <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  804160c6ef:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  804160c6f3:	41 80 f8 19          	cmp    $0x19,%r8b
  804160c6f7:	77 2f                	ja     804160c728 <strtol+0xba>
      dig = *s - 'a' + 10;
  804160c6f9:	44 0f be c1          	movsbl %cl,%r8d
  804160c6fd:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  804160c701:	39 d1                	cmp    %edx,%ecx
  804160c703:	7d 37                	jge    804160c73c <strtol+0xce>
    s++, val = (val * base) + dig;
  804160c705:	48 83 c7 01          	add    $0x1,%rdi
  804160c709:	49 0f af c2          	imul   %r10,%rax
  804160c70d:	48 63 c9             	movslq %ecx,%rcx
  804160c710:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  804160c713:	0f b6 0f             	movzbl (%rdi),%ecx
  804160c716:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  804160c71a:	41 80 f8 09          	cmp    $0x9,%r8b
  804160c71e:	77 cf                	ja     804160c6ef <strtol+0x81>
      dig = *s - '0';
  804160c720:	0f be c9             	movsbl %cl,%ecx
  804160c723:	83 e9 30             	sub    $0x30,%ecx
  804160c726:	eb d9                	jmp    804160c701 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  804160c728:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  804160c72c:	41 80 f8 19          	cmp    $0x19,%r8b
  804160c730:	77 0a                	ja     804160c73c <strtol+0xce>
      dig = *s - 'A' + 10;
  804160c732:	44 0f be c1          	movsbl %cl,%r8d
  804160c736:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  804160c73a:	eb c5                	jmp    804160c701 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  804160c73c:	48 85 f6             	test   %rsi,%rsi
  804160c73f:	74 03                	je     804160c744 <strtol+0xd6>
    *endptr = (char *)s;
  804160c741:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  804160c744:	48 89 c2             	mov    %rax,%rdx
  804160c747:	48 f7 da             	neg    %rdx
  804160c74a:	45 85 c9             	test   %r9d,%r9d
  804160c74d:	48 0f 45 c2          	cmovne %rdx,%rax
}
  804160c751:	c3                   	retq   

000000804160c752 <tsc_calibrate>:
  delta /= i * 256 * 1000;
  return delta;
}

uint64_t
tsc_calibrate(void) {
  804160c752:	55                   	push   %rbp
  804160c753:	48 89 e5             	mov    %rsp,%rbp
  804160c756:	41 57                	push   %r15
  804160c758:	41 56                	push   %r14
  804160c75a:	41 55                	push   %r13
  804160c75c:	41 54                	push   %r12
  804160c75e:	53                   	push   %rbx
  804160c75f:	48 83 ec 28          	sub    $0x28,%rsp
  static uint64_t cpu_freq;

  if (cpu_freq == 0) {
  804160c763:	48 a1 20 5a 88 41 80 	movabs 0x8041885a20,%rax
  804160c76a:	00 00 00 
  804160c76d:	48 85 c0             	test   %rax,%rax
  804160c770:	0f 85 8c 01 00 00    	jne    804160c902 <tsc_calibrate+0x1b0>
    int i;
    for (i = 0; i < TIMES; i++) {
  804160c776:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  __asm __volatile("inb %w1,%0"
  804160c77c:	41 bd 61 00 00 00    	mov    $0x61,%r13d
  __asm __volatile("outb %0,%w1"
  804160c782:	41 bf ff ff ff ff    	mov    $0xffffffff,%r15d
  804160c788:	b9 42 00 00 00       	mov    $0x42,%ecx
  uint64_t tsc = 0;
  804160c78d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160c791:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160c795:	eb 35                	jmp    804160c7cc <tsc_calibrate+0x7a>
  804160c797:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  for (count = 0; count < 50000; count++) {
  804160c79b:	be 00 00 00 00       	mov    $0x0,%esi
  804160c7a0:	eb 72                	jmp    804160c814 <tsc_calibrate+0xc2>
  uint64_t tsc = 0;
  804160c7a2:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  for (count = 0; count < 50000; count++) {
  804160c7a6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160c7ac:	e9 c0 00 00 00       	jmpq   804160c871 <tsc_calibrate+0x11f>
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160c7b1:	41 83 c4 01          	add    $0x1,%r12d
  804160c7b5:	83 eb 01             	sub    $0x1,%ebx
  804160c7b8:	41 83 fc 75          	cmp    $0x75,%r12d
  804160c7bc:	75 7a                	jne    804160c838 <tsc_calibrate+0xe6>
    for (i = 0; i < TIMES; i++) {
  804160c7be:	41 83 c3 01          	add    $0x1,%r11d
  804160c7c2:	41 83 fb 64          	cmp    $0x64,%r11d
  804160c7c6:	0f 84 56 01 00 00    	je     804160c922 <tsc_calibrate+0x1d0>
  __asm __volatile("inb %w1,%0"
  804160c7cc:	44 89 ea             	mov    %r13d,%edx
  804160c7cf:	ec                   	in     (%dx),%al
  outb(0x61, (inb(0x61) & ~0x02) | 0x01);
  804160c7d0:	83 e0 fc             	and    $0xfffffffc,%eax
  804160c7d3:	83 c8 01             	or     $0x1,%eax
  __asm __volatile("outb %0,%w1"
  804160c7d6:	ee                   	out    %al,(%dx)
  804160c7d7:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
  804160c7dc:	ba 43 00 00 00       	mov    $0x43,%edx
  804160c7e1:	ee                   	out    %al,(%dx)
  804160c7e2:	44 89 f8             	mov    %r15d,%eax
  804160c7e5:	89 ca                	mov    %ecx,%edx
  804160c7e7:	ee                   	out    %al,(%dx)
  804160c7e8:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160c7e9:	ec                   	in     (%dx),%al
  804160c7ea:	ec                   	in     (%dx),%al
  804160c7eb:	ec                   	in     (%dx),%al
  804160c7ec:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c7ed:	3c ff                	cmp    $0xff,%al
  804160c7ef:	75 a6                	jne    804160c797 <tsc_calibrate+0x45>
  for (count = 0; count < 50000; count++) {
  804160c7f1:	be 00 00 00 00       	mov    $0x0,%esi
  __asm __volatile("rdtsc"
  804160c7f6:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c7f8:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c7fc:	89 c7                	mov    %eax,%edi
  804160c7fe:	48 09 d7             	or     %rdx,%rdi
  804160c801:	83 c6 01             	add    $0x1,%esi
  804160c804:	81 fe 50 c3 00 00    	cmp    $0xc350,%esi
  804160c80a:	74 08                	je     804160c814 <tsc_calibrate+0xc2>
  __asm __volatile("inb %w1,%0"
  804160c80c:	89 ca                	mov    %ecx,%edx
  804160c80e:	ec                   	in     (%dx),%al
  804160c80f:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c810:	3c ff                	cmp    $0xff,%al
  804160c812:	74 e2                	je     804160c7f6 <tsc_calibrate+0xa4>
  __asm __volatile("rdtsc"
  804160c814:	0f 31                	rdtsc  
  if (pit_expect_msb(0xff, &tsc, &d1)) {
  804160c816:	83 fe 05             	cmp    $0x5,%esi
  804160c819:	7e a3                	jle    804160c7be <tsc_calibrate+0x6c>
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c81b:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c81f:	89 c0                	mov    %eax,%eax
  804160c821:	48 09 c2             	or     %rax,%rdx
  804160c824:	49 89 d2             	mov    %rdx,%r10
  *deltap = read_tsc() - tsc;
  804160c827:	49 89 d6             	mov    %rdx,%r14
  804160c82a:	49 29 fe             	sub    %rdi,%r14
  804160c82d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160c832:	41 bc 01 00 00 00    	mov    $0x1,%r12d
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160c838:	44 88 65 cf          	mov    %r12b,-0x31(%rbp)
  __asm __volatile("inb %w1,%0"
  804160c83c:	89 ca                	mov    %ecx,%edx
  804160c83e:	ec                   	in     (%dx),%al
  804160c83f:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c840:	38 c3                	cmp    %al,%bl
  804160c842:	0f 85 5a ff ff ff    	jne    804160c7a2 <tsc_calibrate+0x50>
  for (count = 0; count < 50000; count++) {
  804160c848:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  __asm __volatile("rdtsc"
  804160c84e:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c850:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c854:	89 c0                	mov    %eax,%eax
  804160c856:	48 89 d6             	mov    %rdx,%rsi
  804160c859:	48 09 c6             	or     %rax,%rsi
  804160c85c:	41 83 c1 01          	add    $0x1,%r9d
  804160c860:	41 81 f9 50 c3 00 00 	cmp    $0xc350,%r9d
  804160c867:	74 08                	je     804160c871 <tsc_calibrate+0x11f>
  __asm __volatile("inb %w1,%0"
  804160c869:	89 ca                	mov    %ecx,%edx
  804160c86b:	ec                   	in     (%dx),%al
  804160c86c:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c86d:	38 d8                	cmp    %bl,%al
  804160c86f:	74 dd                	je     804160c84e <tsc_calibrate+0xfc>
  __asm __volatile("rdtsc"
  804160c871:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c873:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c877:	89 c0                	mov    %eax,%eax
  804160c879:	48 09 c2             	or     %rax,%rdx
  *deltap = read_tsc() - tsc;
  804160c87c:	48 29 f2             	sub    %rsi,%rdx
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160c87f:	41 83 f9 05          	cmp    $0x5,%r9d
  804160c883:	0f 8e 35 ff ff ff    	jle    804160c7be <tsc_calibrate+0x6c>
      delta -= tsc;
  804160c889:	48 29 fe             	sub    %rdi,%rsi
      if (d1 + d2 >= delta >> 11)
  804160c88c:	4d 8d 04 16          	lea    (%r14,%rdx,1),%r8
  804160c890:	48 89 f0             	mov    %rsi,%rax
  804160c893:	48 c1 e8 0b          	shr    $0xb,%rax
  804160c897:	49 39 c0             	cmp    %rax,%r8
  804160c89a:	0f 83 11 ff ff ff    	jae    804160c7b1 <tsc_calibrate+0x5f>
  804160c8a0:	49 89 d0             	mov    %rdx,%r8
  __asm __volatile("inb %w1,%0"
  804160c8a3:	89 ca                	mov    %ecx,%edx
  804160c8a5:	ec                   	in     (%dx),%al
  804160c8a6:	ec                   	in     (%dx),%al
      if (!pit_verify_msb(0xfe - i))
  804160c8a7:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  804160c8ac:	2a 55 cf             	sub    -0x31(%rbp),%dl
  804160c8af:	38 c2                	cmp    %al,%dl
  804160c8b1:	0f 85 07 ff ff ff    	jne    804160c7be <tsc_calibrate+0x6c>
  delta += (long)(d2 - d1) / 2;
  804160c8b7:	4c 29 d7             	sub    %r10,%rdi
  804160c8ba:	49 01 f8             	add    %rdi,%r8
  804160c8bd:	4c 89 c7             	mov    %r8,%rdi
  804160c8c0:	48 c1 ef 3f          	shr    $0x3f,%rdi
  804160c8c4:	49 01 f8             	add    %rdi,%r8
  804160c8c7:	49 d1 f8             	sar    %r8
  804160c8ca:	4c 01 c6             	add    %r8,%rsi
  delta *= PIT_TICK_RATE;
  804160c8cd:	48 69 f6 de 34 12 00 	imul   $0x1234de,%rsi,%rsi
  delta /= i * 256 * 1000;
  804160c8d4:	45 69 e4 00 e8 03 00 	imul   $0x3e800,%r12d,%r12d
  804160c8db:	4d 63 e4             	movslq %r12d,%r12
  804160c8de:	48 89 f0             	mov    %rsi,%rax
  804160c8e1:	ba 00 00 00 00       	mov    $0x0,%edx
  804160c8e6:	49 f7 f4             	div    %r12
      if ((cpu_freq = quick_pit_calibrate()))
  804160c8e9:	4c 39 e6             	cmp    %r12,%rsi
  804160c8ec:	0f 82 cc fe ff ff    	jb     804160c7be <tsc_calibrate+0x6c>
  804160c8f2:	48 a3 20 5a 88 41 80 	movabs %rax,0x8041885a20
  804160c8f9:	00 00 00 
        break;
    }
    if (i == TIMES) {
  804160c8fc:	41 83 fb 64          	cmp    $0x64,%r11d
  804160c900:	74 20                	je     804160c922 <tsc_calibrate+0x1d0>
      cpu_freq = DEFAULT_FREQ;
      cprintf("Can't calibrate pit timer. Using default frequency\n");
    }
  }

  return cpu_freq * 1000;
  804160c902:	48 a1 20 5a 88 41 80 	movabs 0x8041885a20,%rax
  804160c909:	00 00 00 
  804160c90c:	48 69 c0 e8 03 00 00 	imul   $0x3e8,%rax,%rax
}
  804160c913:	48 83 c4 28          	add    $0x28,%rsp
  804160c917:	5b                   	pop    %rbx
  804160c918:	41 5c                	pop    %r12
  804160c91a:	41 5d                	pop    %r13
  804160c91c:	41 5e                	pop    %r14
  804160c91e:	41 5f                	pop    %r15
  804160c920:	5d                   	pop    %rbp
  804160c921:	c3                   	retq   
      cpu_freq = DEFAULT_FREQ;
  804160c922:	48 b8 20 5a 88 41 80 	movabs $0x8041885a20,%rax
  804160c929:	00 00 00 
  804160c92c:	48 c7 00 a0 25 26 00 	movq   $0x2625a0,(%rax)
      cprintf("Can't calibrate pit timer. Using default frequency\n");
  804160c933:	48 bf 30 f0 60 41 80 	movabs $0x804160f030,%rdi
  804160c93a:	00 00 00 
  804160c93d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c942:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160c949:	00 00 00 
  804160c94c:	ff d2                	callq  *%rdx
  804160c94e:	eb b2                	jmp    804160c902 <tsc_calibrate+0x1b0>

000000804160c950 <print_time>:

void
print_time(unsigned seconds) {
  804160c950:	55                   	push   %rbp
  804160c951:	48 89 e5             	mov    %rsp,%rbp
  804160c954:	89 fe                	mov    %edi,%esi
  cprintf("%u\n", seconds);
  804160c956:	48 bf 68 f0 60 41 80 	movabs $0x804160f068,%rdi
  804160c95d:	00 00 00 
  804160c960:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c965:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160c96c:	00 00 00 
  804160c96f:	ff d2                	callq  *%rdx
}
  804160c971:	5d                   	pop    %rbp
  804160c972:	c3                   	retq   

000000804160c973 <print_timer_error>:

void
print_timer_error(void) {
  804160c973:	55                   	push   %rbp
  804160c974:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Timer Error\n");
  804160c977:	48 bf 6c f0 60 41 80 	movabs $0x804160f06c,%rdi
  804160c97e:	00 00 00 
  804160c981:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c986:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160c98d:	00 00 00 
  804160c990:	ff d2                	callq  *%rdx
}
  804160c992:	5d                   	pop    %rbp
  804160c993:	c3                   	retq   

000000804160c994 <timer_start>:
static int timer_id       = -1;
static uint64_t timer     = 0;
static uint64_t freq      = 0;

void
timer_start(const char *name) {
  804160c994:	55                   	push   %rbp
  804160c995:	48 89 e5             	mov    %rsp,%rbp
  804160c998:	41 56                	push   %r14
  804160c99a:	41 55                	push   %r13
  804160c99c:	41 54                	push   %r12
  804160c99e:	53                   	push   %rbx
  804160c99f:	49 89 fe             	mov    %rdi,%r14
  (void) timer_id;
  (void) timer;
  // DELETED in LAB 5 end

  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c9a2:	49 bc 80 5a 88 41 80 	movabs $0x8041885a80,%r12
  804160c9a9:	00 00 00 
  804160c9ac:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c9b1:	49 bd e0 c3 60 41 80 	movabs $0x804160c3e0,%r13
  804160c9b8:	00 00 00 
  804160c9bb:	eb 0c                	jmp    804160c9c9 <timer_start+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c9bd:	83 c3 01             	add    $0x1,%ebx
  804160c9c0:	49 83 c4 28          	add    $0x28,%r12
  804160c9c4:	83 fb 05             	cmp    $0x5,%ebx
  804160c9c7:	74 61                	je     804160ca2a <timer_start+0x96>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c9c9:	49 8b 3c 24          	mov    (%r12),%rdi
  804160c9cd:	48 85 ff             	test   %rdi,%rdi
  804160c9d0:	74 eb                	je     804160c9bd <timer_start+0x29>
  804160c9d2:	4c 89 f6             	mov    %r14,%rsi
  804160c9d5:	41 ff d5             	callq  *%r13
  804160c9d8:	85 c0                	test   %eax,%eax
  804160c9da:	75 e1                	jne    804160c9bd <timer_start+0x29>
      timer_id = i;
  804160c9dc:	89 d8                	mov    %ebx,%eax
  804160c9de:	a3 c0 08 62 41 80 00 	movabs %eax,0x80416208c0
  804160c9e5:	00 00 
      timer_started = 1;
  804160c9e7:	48 b8 38 5a 88 41 80 	movabs $0x8041885a38,%rax
  804160c9ee:	00 00 00 
  804160c9f1:	c6 00 01             	movb   $0x1,(%rax)
  __asm __volatile("rdtsc"
  804160c9f4:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c9f6:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c9fa:	89 c0                	mov    %eax,%eax
  804160c9fc:	48 09 d0             	or     %rdx,%rax
  804160c9ff:	48 a3 30 5a 88 41 80 	movabs %rax,0x8041885a30
  804160ca06:	00 00 00 
      timer = read_tsc();
      freq = timertab[timer_id].get_cpu_freq();
  804160ca09:	48 63 db             	movslq %ebx,%rbx
  804160ca0c:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160ca10:	48 b8 80 5a 88 41 80 	movabs $0x8041885a80,%rax
  804160ca17:	00 00 00 
  804160ca1a:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160ca1e:	48 a3 28 5a 88 41 80 	movabs %rax,0x8041885a28
  804160ca25:	00 00 00 
      return;
  804160ca28:	eb 1b                	jmp    804160ca45 <timer_start+0xb1>
    }
  }

  cprintf("Timer Error\n");
  804160ca2a:	48 bf 6c f0 60 41 80 	movabs $0x804160f06c,%rdi
  804160ca31:	00 00 00 
  804160ca34:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ca39:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160ca40:	00 00 00 
  804160ca43:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160ca45:	5b                   	pop    %rbx
  804160ca46:	41 5c                	pop    %r12
  804160ca48:	41 5d                	pop    %r13
  804160ca4a:	41 5e                	pop    %r14
  804160ca4c:	5d                   	pop    %rbp
  804160ca4d:	c3                   	retq   

000000804160ca4e <timer_stop>:

void
timer_stop(void) {
  804160ca4e:	55                   	push   %rbp
  804160ca4f:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  if (!timer_started || timer_id < 0) {
  804160ca52:	48 b8 38 5a 88 41 80 	movabs $0x8041885a38,%rax
  804160ca59:	00 00 00 
  804160ca5c:	80 38 00             	cmpb   $0x0,(%rax)
  804160ca5f:	74 69                	je     804160caca <timer_stop+0x7c>
  804160ca61:	48 b8 c0 08 62 41 80 	movabs $0x80416208c0,%rax
  804160ca68:	00 00 00 
  804160ca6b:	83 38 00             	cmpl   $0x0,(%rax)
  804160ca6e:	78 5a                	js     804160caca <timer_stop+0x7c>
  __asm __volatile("rdtsc"
  804160ca70:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ca72:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ca76:	89 c0                	mov    %eax,%eax
  804160ca78:	48 09 c2             	or     %rax,%rdx
    print_timer_error();
    return;
  }

  print_time((read_tsc() - timer) / freq);
  804160ca7b:	48 b8 30 5a 88 41 80 	movabs $0x8041885a30,%rax
  804160ca82:	00 00 00 
  804160ca85:	48 2b 10             	sub    (%rax),%rdx
  804160ca88:	48 89 d0             	mov    %rdx,%rax
  804160ca8b:	48 b9 28 5a 88 41 80 	movabs $0x8041885a28,%rcx
  804160ca92:	00 00 00 
  804160ca95:	ba 00 00 00 00       	mov    $0x0,%edx
  804160ca9a:	48 f7 31             	divq   (%rcx)
  804160ca9d:	89 c7                	mov    %eax,%edi
  804160ca9f:	48 b8 50 c9 60 41 80 	movabs $0x804160c950,%rax
  804160caa6:	00 00 00 
  804160caa9:	ff d0                	callq  *%rax

  timer_id = -1;
  804160caab:	48 b8 c0 08 62 41 80 	movabs $0x80416208c0,%rax
  804160cab2:	00 00 00 
  804160cab5:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%rax)
  timer_started = 0;
  804160cabb:	48 b8 38 5a 88 41 80 	movabs $0x8041885a38,%rax
  804160cac2:	00 00 00 
  804160cac5:	c6 00 00             	movb   $0x0,(%rax)
  804160cac8:	eb 0c                	jmp    804160cad6 <timer_stop+0x88>
    print_timer_error();
  804160caca:	48 b8 73 c9 60 41 80 	movabs $0x804160c973,%rax
  804160cad1:	00 00 00 
  804160cad4:	ff d0                	callq  *%rax
  // LAB 5 code end
}
  804160cad6:	5d                   	pop    %rbp
  804160cad7:	c3                   	retq   

000000804160cad8 <timer_cpu_frequency>:

void
timer_cpu_frequency(const char *name) {
  804160cad8:	55                   	push   %rbp
  804160cad9:	48 89 e5             	mov    %rsp,%rbp
  804160cadc:	41 56                	push   %r14
  804160cade:	41 55                	push   %r13
  804160cae0:	41 54                	push   %r12
  804160cae2:	53                   	push   %rbx
  804160cae3:	49 89 fe             	mov    %rdi,%r14
  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160cae6:	49 bc 80 5a 88 41 80 	movabs $0x8041885a80,%r12
  804160caed:	00 00 00 
  804160caf0:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160caf5:	49 bd e0 c3 60 41 80 	movabs $0x804160c3e0,%r13
  804160cafc:	00 00 00 
  804160caff:	eb 0c                	jmp    804160cb0d <timer_cpu_frequency+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160cb01:	83 c3 01             	add    $0x1,%ebx
  804160cb04:	49 83 c4 28          	add    $0x28,%r12
  804160cb08:	83 fb 05             	cmp    $0x5,%ebx
  804160cb0b:	74 48                	je     804160cb55 <timer_cpu_frequency+0x7d>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160cb0d:	49 8b 3c 24          	mov    (%r12),%rdi
  804160cb11:	48 85 ff             	test   %rdi,%rdi
  804160cb14:	74 eb                	je     804160cb01 <timer_cpu_frequency+0x29>
  804160cb16:	4c 89 f6             	mov    %r14,%rsi
  804160cb19:	41 ff d5             	callq  *%r13
  804160cb1c:	85 c0                	test   %eax,%eax
  804160cb1e:	75 e1                	jne    804160cb01 <timer_cpu_frequency+0x29>
      cprintf("%lu\n", timertab[i].get_cpu_freq());
  804160cb20:	48 63 db             	movslq %ebx,%rbx
  804160cb23:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160cb27:	48 b8 80 5a 88 41 80 	movabs $0x8041885a80,%rax
  804160cb2e:	00 00 00 
  804160cb31:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160cb35:	48 89 c6             	mov    %rax,%rsi
  804160cb38:	48 bf 09 d3 60 41 80 	movabs $0x804160d309,%rdi
  804160cb3f:	00 00 00 
  804160cb42:	b8 00 00 00 00       	mov    $0x0,%eax
  804160cb47:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160cb4e:	00 00 00 
  804160cb51:	ff d2                	callq  *%rdx
      return;
  804160cb53:	eb 1b                	jmp    804160cb70 <timer_cpu_frequency+0x98>
    }
  }
  cprintf("Timer Error\n");
  804160cb55:	48 bf 6c f0 60 41 80 	movabs $0x804160f06c,%rdi
  804160cb5c:	00 00 00 
  804160cb5f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160cb64:	48 ba f2 91 60 41 80 	movabs $0x80416091f2,%rdx
  804160cb6b:	00 00 00 
  804160cb6e:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160cb70:	5b                   	pop    %rbx
  804160cb71:	41 5c                	pop    %r12
  804160cb73:	41 5d                	pop    %r13
  804160cb75:	41 5e                	pop    %r14
  804160cb77:	5d                   	pop    %rbp
  804160cb78:	c3                   	retq   

000000804160cb79 <efi_call_in_32bit_mode>:
efi_call_in_32bit_mode(uint32_t func,
                       efi_registers *efi_reg,
                       void *stack_contents,
                       size_t stack_contents_size, /* 16-byte multiple */
                       uint32_t *efi_status) {
  if (func == 0) {
  804160cb79:	85 ff                	test   %edi,%edi
  804160cb7b:	74 50                	je     804160cbcd <efi_call_in_32bit_mode+0x54>
    return -E_INVAL;
  }

  if ((efi_reg == NULL) || (stack_contents == NULL) || (stack_contents_size % 16 != 0)) {
  804160cb7d:	48 85 f6             	test   %rsi,%rsi
  804160cb80:	74 51                	je     804160cbd3 <efi_call_in_32bit_mode+0x5a>
  804160cb82:	48 85 d2             	test   %rdx,%rdx
  804160cb85:	74 4c                	je     804160cbd3 <efi_call_in_32bit_mode+0x5a>
  804160cb87:	f6 c1 0f             	test   $0xf,%cl
  804160cb8a:	75 4d                	jne    804160cbd9 <efi_call_in_32bit_mode+0x60>
                       uint32_t *efi_status) {
  804160cb8c:	55                   	push   %rbp
  804160cb8d:	48 89 e5             	mov    %rsp,%rbp
  804160cb90:	41 54                	push   %r12
  804160cb92:	53                   	push   %rbx
  804160cb93:	4d 89 c4             	mov    %r8,%r12
  804160cb96:	48 89 f3             	mov    %rsi,%rbx
    return -E_INVAL;
  }

  //We need to set up kernel data segments for 32 bit mode
  //before calling asm.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD32));
  804160cb99:	b8 20 00 00 00       	mov    $0x20,%eax
  804160cb9e:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD32));
  804160cba0:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD32));
  804160cba2:	8e d0                	mov    %eax,%ss
  _efi_call_in_32bit_mode_asm(func,
  804160cba4:	48 b8 e0 cb 60 41 80 	movabs $0x804160cbe0,%rax
  804160cbab:	00 00 00 
  804160cbae:	ff d0                	callq  *%rax
                              efi_reg,
                              stack_contents,
                              stack_contents_size);
  //Restore 64 bit kernel data segments.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  804160cbb0:	b8 10 00 00 00       	mov    $0x10,%eax
  804160cbb5:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  804160cbb7:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  804160cbb9:	8e d0                	mov    %eax,%ss

  *efi_status = (uint32_t)efi_reg->rax;
  804160cbbb:	48 8b 43 20          	mov    0x20(%rbx),%rax
  804160cbbf:	41 89 04 24          	mov    %eax,(%r12)

  return 0;
  804160cbc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160cbc8:	5b                   	pop    %rbx
  804160cbc9:	41 5c                	pop    %r12
  804160cbcb:	5d                   	pop    %rbp
  804160cbcc:	c3                   	retq   
    return -E_INVAL;
  804160cbcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160cbd2:	c3                   	retq   
    return -E_INVAL;
  804160cbd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160cbd8:	c3                   	retq   
  804160cbd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  804160cbde:	c3                   	retq   
  804160cbdf:	90                   	nop

000000804160cbe0 <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  804160cbe0:	55                   	push   %rbp
    movq %rsp, %rbp
  804160cbe1:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  804160cbe4:	53                   	push   %rbx
	push	%r12
  804160cbe5:	41 54                	push   %r12
	push	%r13
  804160cbe7:	41 55                	push   %r13
	push	%r14
  804160cbe9:	41 56                	push   %r14
	push	%r15
  804160cbeb:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  804160cbed:	56                   	push   %rsi
	push	%rcx
  804160cbee:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  804160cbef:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  804160cbf0:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  804160cbf3:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

000000804160cbfa <copyloop>:
  804160cbfa:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  804160cbfe:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  804160cc02:	49 83 c0 08          	add    $0x8,%r8
  804160cc06:	49 39 c8             	cmp    %rcx,%r8
  804160cc09:	75 ef                	jne    804160cbfa <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  804160cc0b:	e8 00 00 00 00       	callq  804160cc10 <copyloop+0x16>
  804160cc10:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  804160cc17:	00 
  804160cc18:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  804160cc1f:	00 
  804160cc20:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  804160cc21:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  804160cc23:	6a 08                	pushq  $0x8
  804160cc25:	e8 00 00 00 00       	callq  804160cc2a <copyloop+0x30>
  804160cc2a:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  804160cc31:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  804160cc32:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  804160cc36:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  804160cc3a:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  804160cc3e:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  804160cc41:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  804160cc42:	59                   	pop    %rcx
	pop	%rsi
  804160cc43:	5e                   	pop    %rsi
	pop	%r15
  804160cc44:	41 5f                	pop    %r15
	pop	%r14
  804160cc46:	41 5e                	pop    %r14
	pop	%r13
  804160cc48:	41 5d                	pop    %r13
	pop	%r12
  804160cc4a:	41 5c                	pop    %r12
	pop	%rbx
  804160cc4c:	5b                   	pop    %rbx

	leave
  804160cc4d:	c9                   	leaveq 
	ret
  804160cc4e:	c3                   	retq   

000000804160cc4f <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name) {
  lk->locked = 0;
  804160cc4f:	c7 07 00 00 00 00    	movl   $0x0,(%rdi)
#ifdef DEBUG_SPINLOCK
  lk->name = name;
#endif
}
  804160cc55:	c3                   	retq   

000000804160cc56 <spin_lock>:
  asm volatile("lock; xchgl %0, %1"
  804160cc56:	b8 01 00 00 00       	mov    $0x1,%eax
  804160cc5b:	f0 87 07             	lock xchg %eax,(%rdi)
#endif

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
  804160cc5e:	85 c0                	test   %eax,%eax
  804160cc60:	74 10                	je     804160cc72 <spin_lock+0x1c>
  804160cc62:	ba 01 00 00 00       	mov    $0x1,%edx
    asm volatile("pause");
  804160cc67:	f3 90                	pause  
  804160cc69:	89 d0                	mov    %edx,%eax
  804160cc6b:	f0 87 07             	lock xchg %eax,(%rdi)
  while (xchg(&lk->locked, 1) != 0)
  804160cc6e:	85 c0                	test   %eax,%eax
  804160cc70:	75 f5                	jne    804160cc67 <spin_lock+0x11>

    // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  get_caller_pcs(lk->pcs);
#endif
}
  804160cc72:	c3                   	retq   

000000804160cc73 <spin_unlock>:
  804160cc73:	b8 00 00 00 00       	mov    $0x0,%eax
  804160cc78:	f0 87 07             	lock xchg %eax,(%rdi)
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
}
  804160cc7b:	c3                   	retq   
  804160cc7c:	0f 1f 40 00          	nopl   0x0(%rax)
