
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
  80416002b7:	48 bb 09 3f 60 41 80 	movabs $0x8041603f09,%rbx
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
  804160030b:	48 bf a0 cc 60 41 80 	movabs $0x804160cca0,%rdi
  8041600312:	00 00 00 
  8041600315:	b8 00 00 00 00       	mov    $0x0,%eax
  804160031a:	48 bb 0d 92 60 41 80 	movabs $0x804160920d,%rbx
  8041600321:	00 00 00 
  8041600324:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600326:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160032d:	4c 89 e7             	mov    %r12,%rdi
  8041600330:	48 b8 d9 91 60 41 80 	movabs $0x80416091d9,%rax
  8041600337:	00 00 00 
  804160033a:	ff d0                	callq  *%rax
  cprintf("\n");
  804160033c:	48 bf 3f e2 60 41 80 	movabs $0x804160e23f,%rdi
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
  804160036f:	49 be fa c3 60 41 80 	movabs $0x804160c3fa,%r14
  8041600376:	00 00 00 
  8041600379:	eb 3a                	jmp    80416003b5 <timers_schedule+0x63>
        panic("Timer %s does not support interrupts\n", name);
  804160037b:	4c 89 e9             	mov    %r13,%rcx
  804160037e:	48 ba 40 cd 60 41 80 	movabs $0x804160cd40,%rdx
  8041600385:	00 00 00 
  8041600388:	be 2d 00 00 00       	mov    $0x2d,%esi
  804160038d:	48 bf b8 cc 60 41 80 	movabs $0x804160ccb8,%rdi
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
  8041600405:	48 ba c4 cc 60 41 80 	movabs $0x804160ccc4,%rdx
  804160040c:	00 00 00 
  804160040f:	be 33 00 00 00       	mov    $0x33,%esi
  8041600414:	48 bf b8 cc 60 41 80 	movabs $0x804160ccb8,%rdi
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
  8041600443:	48 b8 6e 0c 60 41 80 	movabs $0x8041600c6e,%rax
  804160044a:	00 00 00 
  804160044d:	ff d0                	callq  *%rax
  tsc_calibrate();
  804160044f:	48 b8 6c c7 60 41 80 	movabs $0x804160c76c,%rax
  8041600456:	00 00 00 
  8041600459:	ff d0                	callq  *%rax
  cprintf("6828 decimal is %o octal!\n", 6828);
  804160045b:	be ac 1a 00 00       	mov    $0x1aac,%esi
  8041600460:	48 bf dd cc 60 41 80 	movabs $0x804160ccdd,%rdi
  8041600467:	00 00 00 
  804160046a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160046f:	48 bb 0d 92 60 41 80 	movabs $0x804160920d,%rbx
  8041600476:	00 00 00 
  8041600479:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  804160047b:	48 be 00 60 88 41 80 	movabs $0x8041886000,%rsi
  8041600482:	00 00 00 
  8041600485:	48 bf f8 cc 60 41 80 	movabs $0x804160ccf8,%rdi
  804160048c:	00 00 00 
  804160048f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600494:	ff d3                	callq  *%rbx
  mem_init();
  8041600496:	48 b8 57 52 60 41 80 	movabs $0x8041605257,%rax
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
  80416004ea:	48 b8 61 0b 60 41 80 	movabs $0x8041600b61,%rax
  80416004f1:	00 00 00 
  80416004f4:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  80416004f6:	48 bf 01 cd 60 41 80 	movabs $0x804160cd01,%rdi
  80416004fd:	00 00 00 
  8041600500:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600505:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160050c:	00 00 00 
  804160050f:	ff d2                	callq  *%rdx
  env_init();
  8041600511:	48 b8 44 86 60 41 80 	movabs $0x8041608644,%rax
  8041600518:	00 00 00 
  804160051b:	ff d0                	callq  *%rax
  trap_init();
  804160051d:	48 b8 14 93 60 41 80 	movabs $0x8041609314,%rax
  8041600524:	00 00 00 
  8041600527:	ff d0                	callq  *%rax
  timers_schedule("hpet0");
  8041600529:	48 bf 1a cd 60 41 80 	movabs $0x804160cd1a,%rdi
  8041600530:	00 00 00 
  8041600533:	48 b8 52 03 60 41 80 	movabs $0x8041600352,%rax
  804160053a:	00 00 00 
  804160053d:	ff d0                	callq  *%rax
  clock_idt_init();
  804160053f:	48 b8 dd 96 60 41 80 	movabs $0x80416096dd,%rax
  8041600546:	00 00 00 
  8041600549:	ff d0                	callq  *%rax
  ENV_CREATE(TEST, ENV_TYPE_USER);
  804160054b:	be 02 00 00 00       	mov    $0x2,%esi
  8041600550:	48 bf 18 fb 7b 41 80 	movabs $0x80417bfb18,%rdi
  8041600557:	00 00 00 
  804160055a:	48 b8 3b 89 60 41 80 	movabs $0x804160893b,%rax
  8041600561:	00 00 00 
  8041600564:	ff d0                	callq  *%rax
  sched_yield();
  8041600566:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  804160056d:	00 00 00 
  8041600570:	ff d0                	callq  *%rax

0000008041600572 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  8041600572:	55                   	push   %rbp
  8041600573:	48 89 e5             	mov    %rsp,%rbp
  8041600576:	41 54                	push   %r12
  8041600578:	53                   	push   %rbx
  8041600579:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600580:	49 89 d4             	mov    %rdx,%r12
  8041600583:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  804160058a:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  8041600591:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  8041600598:	84 c0                	test   %al,%al
  804160059a:	74 23                	je     80416005bf <_warn+0x4d>
  804160059c:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416005a3:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416005a7:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416005ab:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416005af:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416005b3:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416005b7:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416005bb:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416005bf:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416005c6:	00 00 00 
  80416005c9:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416005d0:	00 00 00 
  80416005d3:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416005d7:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416005de:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416005e5:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  80416005ec:	89 f2                	mov    %esi,%edx
  80416005ee:	48 89 fe             	mov    %rdi,%rsi
  80416005f1:	48 bf 20 cd 60 41 80 	movabs $0x804160cd20,%rdi
  80416005f8:	00 00 00 
  80416005fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600600:	48 bb 0d 92 60 41 80 	movabs $0x804160920d,%rbx
  8041600607:	00 00 00 
  804160060a:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  804160060c:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600613:	4c 89 e7             	mov    %r12,%rdi
  8041600616:	48 b8 d9 91 60 41 80 	movabs $0x80416091d9,%rax
  804160061d:	00 00 00 
  8041600620:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600622:	48 bf 3f e2 60 41 80 	movabs $0x804160e23f,%rdi
  8041600629:	00 00 00 
  804160062c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600631:	ff d3                	callq  *%rbx
  va_end(ap);
}
  8041600633:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  804160063a:	5b                   	pop    %rbx
  804160063b:	41 5c                	pop    %r12
  804160063d:	5d                   	pop    %rbp
  804160063e:	c3                   	retq   

000000804160063f <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  804160063f:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600644:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  8041600645:	a8 01                	test   $0x1,%al
  8041600647:	74 0a                	je     8041600653 <serial_proc_data+0x14>
  8041600649:	ba f8 03 00 00       	mov    $0x3f8,%edx
  804160064e:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  804160064f:	0f b6 c0             	movzbl %al,%eax
  8041600652:	c3                   	retq   
    return -1;
  8041600653:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  8041600658:	c3                   	retq   

0000008041600659 <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  8041600659:	55                   	push   %rbp
  804160065a:	48 89 e5             	mov    %rsp,%rbp
  804160065d:	41 54                	push   %r12
  804160065f:	53                   	push   %rbx
  8041600660:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  8041600663:	48 bb c0 42 88 41 80 	movabs $0x80418842c0,%rbx
  804160066a:	00 00 00 
  while ((c = (*proc)()) != -1) {
  804160066d:	41 ff d4             	callq  *%r12
  8041600670:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041600673:	74 28                	je     804160069d <cons_intr+0x44>
    if (c == 0)
  8041600675:	85 c0                	test   %eax,%eax
  8041600677:	74 f4                	je     804160066d <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  8041600679:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  804160067f:	8d 51 01             	lea    0x1(%rcx),%edx
  8041600682:	89 c9                	mov    %ecx,%ecx
  8041600684:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  8041600687:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  804160068d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600692:	0f 44 d0             	cmove  %eax,%edx
  8041600695:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  804160069b:	eb d0                	jmp    804160066d <cons_intr+0x14>
  }
}
  804160069d:	5b                   	pop    %rbx
  804160069e:	41 5c                	pop    %r12
  80416006a0:	5d                   	pop    %rbp
  80416006a1:	c3                   	retq   

00000080416006a2 <kbd_proc_data>:
kbd_proc_data(void) {
  80416006a2:	55                   	push   %rbp
  80416006a3:	48 89 e5             	mov    %rsp,%rbp
  80416006a6:	53                   	push   %rbx
  80416006a7:	48 83 ec 08          	sub    $0x8,%rsp
  80416006ab:	ba 64 00 00 00       	mov    $0x64,%edx
  80416006b0:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416006b1:	a8 01                	test   $0x1,%al
  80416006b3:	0f 84 31 01 00 00    	je     80416007ea <kbd_proc_data+0x148>
  80416006b9:	ba 60 00 00 00       	mov    $0x60,%edx
  80416006be:	ec                   	in     (%dx),%al
  80416006bf:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416006c1:	3c e0                	cmp    $0xe0,%al
  80416006c3:	0f 84 84 00 00 00    	je     804160074d <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  80416006c9:	84 c0                	test   %al,%al
  80416006cb:	0f 88 97 00 00 00    	js     8041600768 <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  80416006d1:	48 bf a0 42 88 41 80 	movabs $0x80418842a0,%rdi
  80416006d8:	00 00 00 
  80416006db:	8b 0f                	mov    (%rdi),%ecx
  80416006dd:	f6 c1 40             	test   $0x40,%cl
  80416006e0:	74 0c                	je     80416006ee <kbd_proc_data+0x4c>
    data |= 0x80;
  80416006e2:	83 c8 80             	or     $0xffffff80,%eax
  80416006e5:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416006e7:	89 c8                	mov    %ecx,%eax
  80416006e9:	83 e0 bf             	and    $0xffffffbf,%eax
  80416006ec:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  80416006ee:	0f b6 f2             	movzbl %dl,%esi
  80416006f1:	48 b8 c0 ce 60 41 80 	movabs $0x804160cec0,%rax
  80416006f8:	00 00 00 
  80416006fb:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  80416006ff:	48 b9 a0 42 88 41 80 	movabs $0x80418842a0,%rcx
  8041600706:	00 00 00 
  8041600709:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  804160070b:	48 bf c0 cd 60 41 80 	movabs $0x804160cdc0,%rdi
  8041600712:	00 00 00 
  8041600715:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  8041600719:	31 f0                	xor    %esi,%eax
  804160071b:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  804160071d:	89 c6                	mov    %eax,%esi
  804160071f:	83 e6 03             	and    $0x3,%esi
  8041600722:	0f b6 d2             	movzbl %dl,%edx
  8041600725:	48 b9 a0 cd 60 41 80 	movabs $0x804160cda0,%rcx
  804160072c:	00 00 00 
  804160072f:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  8041600733:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  8041600737:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  804160073a:	a8 08                	test   $0x8,%al
  804160073c:	74 73                	je     80416007b1 <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  804160073e:	89 da                	mov    %ebx,%edx
  8041600740:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  8041600743:	83 f9 19             	cmp    $0x19,%ecx
  8041600746:	77 5d                	ja     80416007a5 <kbd_proc_data+0x103>
      c += 'A' - 'a';
  8041600748:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  804160074b:	eb 12                	jmp    804160075f <kbd_proc_data+0xbd>
    shift |= E0ESC;
  804160074d:	48 b8 a0 42 88 41 80 	movabs $0x80418842a0,%rax
  8041600754:	00 00 00 
  8041600757:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  804160075a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  804160075f:	89 d8                	mov    %ebx,%eax
  8041600761:	48 83 c4 08          	add    $0x8,%rsp
  8041600765:	5b                   	pop    %rbx
  8041600766:	5d                   	pop    %rbp
  8041600767:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600768:	48 bf a0 42 88 41 80 	movabs $0x80418842a0,%rdi
  804160076f:	00 00 00 
  8041600772:	8b 0f                	mov    (%rdi),%ecx
  8041600774:	89 ce                	mov    %ecx,%esi
  8041600776:	83 e6 40             	and    $0x40,%esi
  8041600779:	83 e0 7f             	and    $0x7f,%eax
  804160077c:	85 f6                	test   %esi,%esi
  804160077e:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  8041600781:	0f b6 d2             	movzbl %dl,%edx
  8041600784:	48 b8 c0 ce 60 41 80 	movabs $0x804160cec0,%rax
  804160078b:	00 00 00 
  804160078e:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  8041600792:	83 c8 40             	or     $0x40,%eax
  8041600795:	0f b6 c0             	movzbl %al,%eax
  8041600798:	f7 d0                	not    %eax
  804160079a:	21 c8                	and    %ecx,%eax
  804160079c:	89 07                	mov    %eax,(%rdi)
    return 0;
  804160079e:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416007a3:	eb ba                	jmp    804160075f <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  80416007a5:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416007a8:	8d 4b 20             	lea    0x20(%rbx),%ecx
  80416007ab:	83 fa 1a             	cmp    $0x1a,%edx
  80416007ae:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416007b1:	f7 d0                	not    %eax
  80416007b3:	a8 06                	test   $0x6,%al
  80416007b5:	75 a8                	jne    804160075f <kbd_proc_data+0xbd>
  80416007b7:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  80416007bd:	75 a0                	jne    804160075f <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  80416007bf:	48 bf 66 cd 60 41 80 	movabs $0x804160cd66,%rdi
  80416007c6:	00 00 00 
  80416007c9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416007ce:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416007d5:	00 00 00 
  80416007d8:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416007da:	b8 03 00 00 00       	mov    $0x3,%eax
  80416007df:	ba 92 00 00 00       	mov    $0x92,%edx
  80416007e4:	ee                   	out    %al,(%dx)
  80416007e5:	e9 75 ff ff ff       	jmpq   804160075f <kbd_proc_data+0xbd>
    return -1;
  80416007ea:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80416007ef:	e9 6b ff ff ff       	jmpq   804160075f <kbd_proc_data+0xbd>

00000080416007f4 <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  80416007f4:	48 b8 d4 44 88 41 80 	movabs $0x80418844d4,%rax
  80416007fb:	00 00 00 
  80416007fe:	44 8b 10             	mov    (%rax),%r10d
  8041600801:	41 0f af d2          	imul   %r10d,%edx
  8041600805:	01 f2                	add    %esi,%edx
  8041600807:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  804160080e:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  804160080f:	4d 0f be c0          	movsbq %r8b,%r8
  8041600813:	48 b8 20 03 62 41 80 	movabs $0x8041620320,%rax
  804160081a:	00 00 00 
  804160081d:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  8041600821:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  8041600825:	eb 25                	jmp    804160084c <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  8041600827:	83 c0 01             	add    $0x1,%eax
  804160082a:	83 f8 08             	cmp    $0x8,%eax
  804160082d:	74 11                	je     8041600840 <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  804160082f:	0f be 16             	movsbl (%rsi),%edx
  8041600832:	0f a3 c2             	bt     %eax,%edx
  8041600835:	73 f0                	jae    8041600827 <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  8041600837:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  804160083b:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  804160083e:	eb e7                	jmp    8041600827 <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  8041600840:	45 01 d1             	add    %r10d,%r9d
  8041600843:	48 83 c6 01          	add    $0x1,%rsi
  8041600847:	4c 39 c6             	cmp    %r8,%rsi
  804160084a:	74 07                	je     8041600853 <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  804160084c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600851:	eb dc                	jmp    804160082f <draw_char+0x3b>
}
  8041600853:	c3                   	retq   

0000008041600854 <cons_putc>:
  __asm __volatile("inb %w1,%0"
  8041600854:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600859:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  804160085a:	a8 20                	test   $0x20,%al
  804160085c:	75 29                	jne    8041600887 <cons_putc+0x33>
  for (i = 0;
  804160085e:	be 00 00 00 00       	mov    $0x0,%esi
  8041600863:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600868:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  804160086e:	89 ca                	mov    %ecx,%edx
  8041600870:	ec                   	in     (%dx),%al
  8041600871:	ec                   	in     (%dx),%al
  8041600872:	ec                   	in     (%dx),%al
  8041600873:	ec                   	in     (%dx),%al
       i++)
  8041600874:	83 c6 01             	add    $0x1,%esi
  8041600877:	44 89 c2             	mov    %r8d,%edx
  804160087a:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  804160087b:	a8 20                	test   $0x20,%al
  804160087d:	75 08                	jne    8041600887 <cons_putc+0x33>
  804160087f:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  8041600885:	7e e7                	jle    804160086e <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  8041600887:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  804160088a:	ba f8 03 00 00       	mov    $0x3f8,%edx
  804160088f:	89 f8                	mov    %edi,%eax
  8041600891:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600892:	ba 79 03 00 00       	mov    $0x379,%edx
  8041600897:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  8041600898:	84 c0                	test   %al,%al
  804160089a:	78 29                	js     80416008c5 <cons_putc+0x71>
  804160089c:	be 00 00 00 00       	mov    $0x0,%esi
  80416008a1:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416008a6:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  80416008ac:	89 ca                	mov    %ecx,%edx
  80416008ae:	ec                   	in     (%dx),%al
  80416008af:	ec                   	in     (%dx),%al
  80416008b0:	ec                   	in     (%dx),%al
  80416008b1:	ec                   	in     (%dx),%al
  80416008b2:	83 c6 01             	add    $0x1,%esi
  80416008b5:	44 89 ca             	mov    %r9d,%edx
  80416008b8:	ec                   	in     (%dx),%al
  80416008b9:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416008bf:	7f 04                	jg     80416008c5 <cons_putc+0x71>
  80416008c1:	84 c0                	test   %al,%al
  80416008c3:	79 e7                	jns    80416008ac <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416008c5:	ba 78 03 00 00       	mov    $0x378,%edx
  80416008ca:	44 89 c0             	mov    %r8d,%eax
  80416008cd:	ee                   	out    %al,(%dx)
  80416008ce:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416008d3:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416008d8:	ee                   	out    %al,(%dx)
  80416008d9:	b8 08 00 00 00       	mov    $0x8,%eax
  80416008de:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416008df:	48 b8 dc 44 88 41 80 	movabs $0x80418844dc,%rax
  80416008e6:	00 00 00 
  80416008e9:	80 38 00             	cmpb   $0x0,(%rax)
  80416008ec:	0f 84 42 02 00 00    	je     8041600b34 <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  80416008f2:	55                   	push   %rbp
  80416008f3:	48 89 e5             	mov    %rsp,%rbp
  80416008f6:	41 54                	push   %r12
  80416008f8:	53                   	push   %rbx
  if (!(c & ~0xFF))
  80416008f9:	89 fa                	mov    %edi,%edx
  80416008fb:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  8041600901:	89 f8                	mov    %edi,%eax
  8041600903:	80 cc 07             	or     $0x7,%ah
  8041600906:	85 d2                	test   %edx,%edx
  8041600908:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  804160090b:	40 0f b6 c7          	movzbl %dil,%eax
  804160090f:	83 f8 09             	cmp    $0x9,%eax
  8041600912:	0f 84 e1 00 00 00    	je     80416009f9 <cons_putc+0x1a5>
  8041600918:	7e 5c                	jle    8041600976 <cons_putc+0x122>
  804160091a:	83 f8 0a             	cmp    $0xa,%eax
  804160091d:	0f 84 b8 00 00 00    	je     80416009db <cons_putc+0x187>
  8041600923:	83 f8 0d             	cmp    $0xd,%eax
  8041600926:	0f 85 ff 00 00 00    	jne    8041600a2b <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  804160092c:	48 be c8 44 88 41 80 	movabs $0x80418844c8,%rsi
  8041600933:	00 00 00 
  8041600936:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600939:	0f b7 c1             	movzwl %cx,%eax
  804160093c:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  8041600943:	00 00 00 
  8041600946:	ba 00 00 00 00       	mov    $0x0,%edx
  804160094b:	f7 33                	divl   (%rbx)
  804160094d:	29 d1                	sub    %edx,%ecx
  804160094f:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  8041600952:	48 b8 c8 44 88 41 80 	movabs $0x80418844c8,%rax
  8041600959:	00 00 00 
  804160095c:	0f b7 10             	movzwl (%rax),%edx
  804160095f:	48 b8 cc 44 88 41 80 	movabs $0x80418844cc,%rax
  8041600966:	00 00 00 
  8041600969:	3b 10                	cmp    (%rax),%edx
  804160096b:	0f 83 0f 01 00 00    	jae    8041600a80 <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  8041600971:	5b                   	pop    %rbx
  8041600972:	41 5c                	pop    %r12
  8041600974:	5d                   	pop    %rbp
  8041600975:	c3                   	retq   
  switch (c & 0xff) {
  8041600976:	83 f8 08             	cmp    $0x8,%eax
  8041600979:	0f 85 ac 00 00 00    	jne    8041600a2b <cons_putc+0x1d7>
      if (crt_pos > 0) {
  804160097f:	66 a1 c8 44 88 41 80 	movabs 0x80418844c8,%ax
  8041600986:	00 00 00 
  8041600989:	66 85 c0             	test   %ax,%ax
  804160098c:	74 c4                	je     8041600952 <cons_putc+0xfe>
        crt_pos--;
  804160098e:	83 e8 01             	sub    $0x1,%eax
  8041600991:	66 a3 c8 44 88 41 80 	movabs %ax,0x80418844c8
  8041600998:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  804160099b:	0f b7 c0             	movzwl %ax,%eax
  804160099e:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  80416009a5:	00 00 00 
  80416009a8:	8b 1b                	mov    (%rbx),%ebx
  80416009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  80416009af:	f7 f3                	div    %ebx
  80416009b1:	89 d6                	mov    %edx,%esi
  80416009b3:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416009b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416009be:	89 c2                	mov    %eax,%edx
  80416009c0:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  80416009c7:	00 00 00 
  80416009ca:	48 b8 f4 07 60 41 80 	movabs $0x80416007f4,%rax
  80416009d1:	00 00 00 
  80416009d4:	ff d0                	callq  *%rax
  80416009d6:	e9 77 ff ff ff       	jmpq   8041600952 <cons_putc+0xfe>
      crt_pos += crt_cols;
  80416009db:	48 b8 c8 44 88 41 80 	movabs $0x80418844c8,%rax
  80416009e2:	00 00 00 
  80416009e5:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  80416009ec:	00 00 00 
  80416009ef:	8b 13                	mov    (%rbx),%edx
  80416009f1:	66 01 10             	add    %dx,(%rax)
  80416009f4:	e9 33 ff ff ff       	jmpq   804160092c <cons_putc+0xd8>
      cons_putc(' ');
  80416009f9:	bf 20 00 00 00       	mov    $0x20,%edi
  80416009fe:	48 bb 54 08 60 41 80 	movabs $0x8041600854,%rbx
  8041600a05:	00 00 00 
  8041600a08:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a0a:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a0f:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a11:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a16:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a18:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a1d:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a1f:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a24:	ff d3                	callq  *%rbx
      break;
  8041600a26:	e9 27 ff ff ff       	jmpq   8041600952 <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600a2b:	49 bc c8 44 88 41 80 	movabs $0x80418844c8,%r12
  8041600a32:	00 00 00 
  8041600a35:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600a3a:	0f b7 c3             	movzwl %bx,%eax
  8041600a3d:	48 be d0 44 88 41 80 	movabs $0x80418844d0,%rsi
  8041600a44:	00 00 00 
  8041600a47:	8b 36                	mov    (%rsi),%esi
  8041600a49:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600a4e:	f7 f6                	div    %esi
  8041600a50:	89 d6                	mov    %edx,%esi
  8041600a52:	44 0f be c7          	movsbl %dil,%r8d
  8041600a56:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600a5b:	89 c2                	mov    %eax,%edx
  8041600a5d:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600a64:	00 00 00 
  8041600a67:	48 b8 f4 07 60 41 80 	movabs $0x80416007f4,%rax
  8041600a6e:	00 00 00 
  8041600a71:	ff d0                	callq  *%rax
      crt_pos++;
  8041600a73:	83 c3 01             	add    $0x1,%ebx
  8041600a76:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  8041600a7b:	e9 d2 fe ff ff       	jmpq   8041600952 <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600a80:	48 bb d4 44 88 41 80 	movabs $0x80418844d4,%rbx
  8041600a87:	00 00 00 
  8041600a8a:	8b 03                	mov    (%rbx),%eax
  8041600a8c:	49 bc d8 44 88 41 80 	movabs $0x80418844d8,%r12
  8041600a93:	00 00 00 
  8041600a96:	41 8b 3c 24          	mov    (%r12),%edi
  8041600a9a:	8d 57 f8             	lea    -0x8(%rdi),%edx
  8041600a9d:	0f af d0             	imul   %eax,%edx
  8041600aa0:	48 c1 e2 02          	shl    $0x2,%rdx
  8041600aa4:	c1 e0 03             	shl    $0x3,%eax
  8041600aa7:	89 c0                	mov    %eax,%eax
  8041600aa9:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600ab0:	00 00 00 
  8041600ab3:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  8041600ab7:	48 b8 f6 c4 60 41 80 	movabs $0x804160c4f6,%rax
  8041600abe:	00 00 00 
  8041600ac1:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600ac3:	41 8b 04 24          	mov    (%r12),%eax
  8041600ac7:	8b 0b                	mov    (%rbx),%ecx
  8041600ac9:	89 c6                	mov    %eax,%esi
  8041600acb:	83 e6 f8             	and    $0xfffffff8,%esi
  8041600ace:	83 ee 08             	sub    $0x8,%esi
  8041600ad1:	0f af f1             	imul   %ecx,%esi
  8041600ad4:	0f af c8             	imul   %eax,%ecx
  8041600ad7:	39 f1                	cmp    %esi,%ecx
  8041600ad9:	76 3b                	jbe    8041600b16 <cons_putc+0x2c2>
  8041600adb:	48 63 fe             	movslq %esi,%rdi
  8041600ade:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  8041600ae5:	00 00 00 
  8041600ae8:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  8041600aec:	8d 51 ff             	lea    -0x1(%rcx),%edx
  8041600aef:	89 d1                	mov    %edx,%ecx
  8041600af1:	29 f1                	sub    %esi,%ecx
  8041600af3:	48 ba 01 b8 b0 0f 20 	movabs $0x200fb0b801,%rdx
  8041600afa:	00 00 00 
  8041600afd:	48 01 fa             	add    %rdi,%rdx
  8041600b00:	48 01 ca             	add    %rcx,%rdx
  8041600b03:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600b07:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600b0d:	48 83 c0 04          	add    $0x4,%rax
  8041600b11:	48 39 c2             	cmp    %rax,%rdx
  8041600b14:	75 f1                	jne    8041600b07 <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600b16:	48 b8 c8 44 88 41 80 	movabs $0x80418844c8,%rax
  8041600b1d:	00 00 00 
  8041600b20:	48 bb d0 44 88 41 80 	movabs $0x80418844d0,%rbx
  8041600b27:	00 00 00 
  8041600b2a:	8b 13                	mov    (%rbx),%edx
  8041600b2c:	66 29 10             	sub    %dx,(%rax)
}
  8041600b2f:	e9 3d fe ff ff       	jmpq   8041600971 <cons_putc+0x11d>
  8041600b34:	c3                   	retq   

0000008041600b35 <serial_intr>:
  if (serial_exists)
  8041600b35:	48 b8 ca 44 88 41 80 	movabs $0x80418844ca,%rax
  8041600b3c:	00 00 00 
  8041600b3f:	80 38 00             	cmpb   $0x0,(%rax)
  8041600b42:	75 01                	jne    8041600b45 <serial_intr+0x10>
  8041600b44:	c3                   	retq   
serial_intr(void) {
  8041600b45:	55                   	push   %rbp
  8041600b46:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600b49:	48 bf 3f 06 60 41 80 	movabs $0x804160063f,%rdi
  8041600b50:	00 00 00 
  8041600b53:	48 b8 59 06 60 41 80 	movabs $0x8041600659,%rax
  8041600b5a:	00 00 00 
  8041600b5d:	ff d0                	callq  *%rax
}
  8041600b5f:	5d                   	pop    %rbp
  8041600b60:	c3                   	retq   

0000008041600b61 <fb_init>:
fb_init(void) {
  8041600b61:	55                   	push   %rbp
  8041600b62:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600b65:	48 b8 00 00 62 41 80 	movabs $0x8041620000,%rax
  8041600b6c:	00 00 00 
  8041600b6f:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600b72:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600b75:	89 d0                	mov    %edx,%eax
  8041600b77:	a3 d8 44 88 41 80 00 	movabs %eax,0x80418844d8
  8041600b7e:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600b80:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600b83:	a3 d4 44 88 41 80 00 	movabs %eax,0x80418844d4
  8041600b8a:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600b8c:	c1 e8 03             	shr    $0x3,%eax
  8041600b8f:	89 c6                	mov    %eax,%esi
  8041600b91:	a3 d0 44 88 41 80 00 	movabs %eax,0x80418844d0
  8041600b98:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600b9a:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600b9d:	0f af d0             	imul   %eax,%edx
  8041600ba0:	89 d0                	mov    %edx,%eax
  8041600ba2:	a3 cc 44 88 41 80 00 	movabs %eax,0x80418844cc
  8041600ba9:	00 00 
  crt_pos           = crt_cols;
  8041600bab:	89 f0                	mov    %esi,%eax
  8041600bad:	66 a3 c8 44 88 41 80 	movabs %ax,0x80418844c8
  8041600bb4:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600bb7:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600bba:	be 00 00 00 00       	mov    $0x0,%esi
  8041600bbf:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600bc6:	00 00 00 
  8041600bc9:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041600bd0:	00 00 00 
  8041600bd3:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600bd5:	48 b8 dc 44 88 41 80 	movabs $0x80418844dc,%rax
  8041600bdc:	00 00 00 
  8041600bdf:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600be2:	5d                   	pop    %rbp
  8041600be3:	c3                   	retq   

0000008041600be4 <kbd_intr>:
kbd_intr(void) {
  8041600be4:	55                   	push   %rbp
  8041600be5:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600be8:	48 bf a2 06 60 41 80 	movabs $0x80416006a2,%rdi
  8041600bef:	00 00 00 
  8041600bf2:	48 b8 59 06 60 41 80 	movabs $0x8041600659,%rax
  8041600bf9:	00 00 00 
  8041600bfc:	ff d0                	callq  *%rax
}
  8041600bfe:	5d                   	pop    %rbp
  8041600bff:	c3                   	retq   

0000008041600c00 <cons_getc>:
cons_getc(void) {
  8041600c00:	55                   	push   %rbp
  8041600c01:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600c04:	48 b8 35 0b 60 41 80 	movabs $0x8041600b35,%rax
  8041600c0b:	00 00 00 
  8041600c0e:	ff d0                	callq  *%rax
  kbd_intr();
  8041600c10:	48 b8 e4 0b 60 41 80 	movabs $0x8041600be4,%rax
  8041600c17:	00 00 00 
  8041600c1a:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600c1c:	48 b9 c0 42 88 41 80 	movabs $0x80418842c0,%rcx
  8041600c23:	00 00 00 
  8041600c26:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600c31:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600c37:	74 21                	je     8041600c5a <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600c39:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600c3c:	48 b8 c0 42 88 41 80 	movabs $0x80418842c0,%rax
  8041600c43:	00 00 00 
  8041600c46:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600c4c:	89 d2                	mov    %edx,%edx
  8041600c4e:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600c52:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600c58:	74 02                	je     8041600c5c <cons_getc+0x5c>
}
  8041600c5a:	5d                   	pop    %rbp
  8041600c5b:	c3                   	retq   
      cons.rpos = 0;
  8041600c5c:	48 be c0 44 88 41 80 	movabs $0x80418844c0,%rsi
  8041600c63:	00 00 00 
  8041600c66:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600c6c:	eb ec                	jmp    8041600c5a <cons_getc+0x5a>

0000008041600c6e <cons_init>:
  8041600c6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600c73:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600c78:	89 c8                	mov    %ecx,%eax
  8041600c7a:	89 fa                	mov    %edi,%edx
  8041600c7c:	ee                   	out    %al,(%dx)
  8041600c7d:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600c83:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600c88:	44 89 ca             	mov    %r9d,%edx
  8041600c8b:	ee                   	out    %al,(%dx)
  8041600c8c:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600c91:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600c96:	89 f2                	mov    %esi,%edx
  8041600c98:	ee                   	out    %al,(%dx)
  8041600c99:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600c9f:	89 c8                	mov    %ecx,%eax
  8041600ca1:	44 89 c2             	mov    %r8d,%edx
  8041600ca4:	ee                   	out    %al,(%dx)
  8041600ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600caa:	44 89 ca             	mov    %r9d,%edx
  8041600cad:	ee                   	out    %al,(%dx)
  8041600cae:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600cb3:	89 c8                	mov    %ecx,%eax
  8041600cb5:	ee                   	out    %al,(%dx)
  8041600cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600cbb:	44 89 c2             	mov    %r8d,%edx
  8041600cbe:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600cbf:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600cc4:	ec                   	in     (%dx),%al
  8041600cc5:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600cc7:	3c ff                	cmp    $0xff,%al
  8041600cc9:	0f 95 c0             	setne  %al
  8041600ccc:	a2 ca 44 88 41 80 00 	movabs %al,0x80418844ca
  8041600cd3:	00 00 
  8041600cd5:	89 fa                	mov    %edi,%edx
  8041600cd7:	ec                   	in     (%dx),%al
  8041600cd8:	89 f2                	mov    %esi,%edx
  8041600cda:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600cdb:	80 f9 ff             	cmp    $0xff,%cl
  8041600cde:	74 01                	je     8041600ce1 <cons_init+0x73>
  8041600ce0:	c3                   	retq   
cons_init(void) {
  8041600ce1:	55                   	push   %rbp
  8041600ce2:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600ce5:	48 bf 72 cd 60 41 80 	movabs $0x804160cd72,%rdi
  8041600cec:	00 00 00 
  8041600cef:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600cf4:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041600cfb:	00 00 00 
  8041600cfe:	ff d2                	callq  *%rdx
}
  8041600d00:	5d                   	pop    %rbp
  8041600d01:	c3                   	retq   

0000008041600d02 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600d02:	55                   	push   %rbp
  8041600d03:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600d06:	48 b8 54 08 60 41 80 	movabs $0x8041600854,%rax
  8041600d0d:	00 00 00 
  8041600d10:	ff d0                	callq  *%rax
}
  8041600d12:	5d                   	pop    %rbp
  8041600d13:	c3                   	retq   

0000008041600d14 <getchar>:

int
getchar(void) {
  8041600d14:	55                   	push   %rbp
  8041600d15:	48 89 e5             	mov    %rsp,%rbp
  8041600d18:	53                   	push   %rbx
  8041600d19:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600d1d:	48 bb 00 0c 60 41 80 	movabs $0x8041600c00,%rbx
  8041600d24:	00 00 00 
  8041600d27:	ff d3                	callq  *%rbx
  8041600d29:	85 c0                	test   %eax,%eax
  8041600d2b:	74 fa                	je     8041600d27 <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600d2d:	48 83 c4 08          	add    $0x8,%rsp
  8041600d31:	5b                   	pop    %rbx
  8041600d32:	5d                   	pop    %rbp
  8041600d33:	c3                   	retq   

0000008041600d34 <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600d34:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600d39:	c3                   	retq   

0000008041600d3a <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600d3a:	55                   	push   %rbp
  8041600d3b:	48 89 e5             	mov    %rsp,%rbp
  8041600d3e:	41 56                	push   %r14
  8041600d40:	41 55                	push   %r13
  8041600d42:	41 54                	push   %r12
  8041600d44:	53                   	push   %rbx
  8041600d45:	48 83 ec 20          	sub    $0x20,%rsp
  8041600d49:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600d4d:	83 fe 20             	cmp    $0x20,%esi
  8041600d50:	0f 87 42 09 00 00    	ja     8041601698 <dwarf_read_abbrev_entry+0x95e>
  8041600d56:	44 89 c3             	mov    %r8d,%ebx
  8041600d59:	41 89 cd             	mov    %ecx,%r13d
  8041600d5c:	49 89 d4             	mov    %rdx,%r12
  8041600d5f:	89 f6                	mov    %esi,%esi
  8041600d61:	48 b8 78 d0 60 41 80 	movabs $0x804160d078,%rax
  8041600d68:	00 00 00 
  8041600d6b:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600d6e:	48 85 d2             	test   %rdx,%rdx
  8041600d71:	74 6f                	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
  8041600d73:	83 f9 07             	cmp    $0x7,%ecx
  8041600d76:	76 6a                	jbe    8041600de2 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600d78:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600d7d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d81:	4c 89 e7             	mov    %r12,%rdi
  8041600d84:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600d8b:	00 00 00 
  8041600d8e:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600d90:	eb 50                	jmp    8041600de2 <dwarf_read_abbrev_entry+0xa8>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB2 code
        
      unsigned length = get_unaligned(entry, uint16_t);
  8041600d92:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d97:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d9b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d9f:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600da6:	00 00 00 
  8041600da9:	ff d0                	callq  *%rax
  8041600dab:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(uint16_t);
  8041600daf:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600db3:	48 83 c0 02          	add    $0x2,%rax
  8041600db7:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600dbb:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600dbf:	89 5d d8             	mov    %ebx,-0x28(%rbp)
        .mem = entry,
        .len = length,
      };
      if (buf) {
  8041600dc2:	4d 85 e4             	test   %r12,%r12
  8041600dc5:	74 18                	je     8041600ddf <dwarf_read_abbrev_entry+0xa5>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600dc7:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600dcc:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600dd0:	4c 89 e7             	mov    %r12,%rdi
  8041600dd3:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600dda:	00 00 00 
  8041600ddd:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(uint16_t) + length;
  8041600ddf:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600de2:	89 d8                	mov    %ebx,%eax
  8041600de4:	48 83 c4 20          	add    $0x20,%rsp
  8041600de8:	5b                   	pop    %rbx
  8041600de9:	41 5c                	pop    %r12
  8041600deb:	41 5d                	pop    %r13
  8041600ded:	41 5e                	pop    %r14
  8041600def:	5d                   	pop    %rbp
  8041600df0:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600df1:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600df6:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600dfa:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600dfe:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600e05:	00 00 00 
  8041600e08:	ff d0                	callq  *%rax
  8041600e0a:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600e0d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600e11:	48 83 c0 04          	add    $0x4,%rax
  8041600e15:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600e19:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600e1d:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600e20:	4d 85 e4             	test   %r12,%r12
  8041600e23:	74 18                	je     8041600e3d <dwarf_read_abbrev_entry+0x103>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600e25:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600e2a:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e2e:	4c 89 e7             	mov    %r12,%rdi
  8041600e31:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600e38:	00 00 00 
  8041600e3b:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600e3d:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600e40:	eb a0                	jmp    8041600de2 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600e42:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e47:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e4b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e4f:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600e56:	00 00 00 
  8041600e59:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600e5b:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600e60:	4d 85 e4             	test   %r12,%r12
  8041600e63:	74 06                	je     8041600e6b <dwarf_read_abbrev_entry+0x131>
  8041600e65:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600e69:	77 0a                	ja     8041600e75 <dwarf_read_abbrev_entry+0x13b>
      bytes = sizeof(Dwarf_Half);
  8041600e6b:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600e70:	e9 6d ff ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e75:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e7a:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e7e:	4c 89 e7             	mov    %r12,%rdi
  8041600e81:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600e88:	00 00 00 
  8041600e8b:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600e8d:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e92:	e9 4b ff ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600e97:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600e9c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ea0:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ea4:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600eab:	00 00 00 
  8041600eae:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600eb0:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600eb5:	4d 85 e4             	test   %r12,%r12
  8041600eb8:	74 06                	je     8041600ec0 <dwarf_read_abbrev_entry+0x186>
  8041600eba:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600ebe:	77 0a                	ja     8041600eca <dwarf_read_abbrev_entry+0x190>
      bytes = sizeof(uint32_t);
  8041600ec0:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600ec5:	e9 18 ff ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  8041600eca:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ecf:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600ed3:	4c 89 e7             	mov    %r12,%rdi
  8041600ed6:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600edd:	00 00 00 
  8041600ee0:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600ee2:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600ee7:	e9 f6 fe ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600eec:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600ef1:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ef5:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ef9:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600f00:	00 00 00 
  8041600f03:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600f05:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600f0a:	4d 85 e4             	test   %r12,%r12
  8041600f0d:	74 06                	je     8041600f15 <dwarf_read_abbrev_entry+0x1db>
  8041600f0f:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600f13:	77 0a                	ja     8041600f1f <dwarf_read_abbrev_entry+0x1e5>
      bytes = sizeof(uint64_t);
  8041600f15:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600f1a:	e9 c3 fe ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041600f1f:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f24:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f28:	4c 89 e7             	mov    %r12,%rdi
  8041600f2b:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600f32:	00 00 00 
  8041600f35:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600f37:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600f3c:	e9 a1 fe ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      if (buf && bufsize >= sizeof(char *)) {
  8041600f41:	48 85 d2             	test   %rdx,%rdx
  8041600f44:	74 05                	je     8041600f4b <dwarf_read_abbrev_entry+0x211>
  8041600f46:	83 f9 07             	cmp    $0x7,%ecx
  8041600f49:	77 18                	ja     8041600f63 <dwarf_read_abbrev_entry+0x229>
      bytes = strlen(entry) + 1;
  8041600f4b:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600f4f:	48 b8 eb c2 60 41 80 	movabs $0x804160c2eb,%rax
  8041600f56:	00 00 00 
  8041600f59:	ff d0                	callq  *%rax
  8041600f5b:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600f5e:	e9 7f fe ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &entry, sizeof(char *));
  8041600f63:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f68:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600f6c:	4c 89 e7             	mov    %r12,%rdi
  8041600f6f:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600f76:	00 00 00 
  8041600f79:	ff d0                	callq  *%rax
  8041600f7b:	eb ce                	jmp    8041600f4b <dwarf_read_abbrev_entry+0x211>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600f7d:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600f81:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600f84:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600f89:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600f8e:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600f93:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600f96:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600f9a:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600f9d:	89 f0                	mov    %esi,%eax
  8041600f9f:	83 e0 7f             	and    $0x7f,%eax
  8041600fa2:	d3 e0                	shl    %cl,%eax
  8041600fa4:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600fa6:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600fa9:	40 84 f6             	test   %sil,%sil
  8041600fac:	78 e5                	js     8041600f93 <dwarf_read_abbrev_entry+0x259>
      break;
  }

  *ret = result;

  return count;
  8041600fae:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600fb1:	4d 01 e8             	add    %r13,%r8
  8041600fb4:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600fb8:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600fbc:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600fbf:	4d 85 e4             	test   %r12,%r12
  8041600fc2:	74 18                	je     8041600fdc <dwarf_read_abbrev_entry+0x2a2>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600fc4:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600fc9:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600fcd:	4c 89 e7             	mov    %r12,%rdi
  8041600fd0:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600fd7:	00 00 00 
  8041600fda:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600fdc:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600fdf:	e9 fe fd ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600fe4:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600fe9:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600fed:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ff1:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041600ff8:	00 00 00 
  8041600ffb:	ff d0                	callq  *%rax
  8041600ffd:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041601001:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041601005:	48 83 c0 01          	add    $0x1,%rax
  8041601009:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  804160100d:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041601011:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041601014:	4d 85 e4             	test   %r12,%r12
  8041601017:	74 18                	je     8041601031 <dwarf_read_abbrev_entry+0x2f7>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041601019:	ba 10 00 00 00       	mov    $0x10,%edx
  804160101e:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601022:	4c 89 e7             	mov    %r12,%rdi
  8041601025:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160102c:	00 00 00 
  804160102f:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041601031:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041601034:	e9 a9 fd ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601039:	ba 01 00 00 00       	mov    $0x1,%edx
  804160103e:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601042:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601046:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160104d:	00 00 00 
  8041601050:	ff d0                	callq  *%rax
  8041601052:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601056:	4d 85 e4             	test   %r12,%r12
  8041601059:	0f 84 43 06 00 00    	je     80416016a2 <dwarf_read_abbrev_entry+0x968>
  804160105f:	45 85 ed             	test   %r13d,%r13d
  8041601062:	0f 84 3a 06 00 00    	je     80416016a2 <dwarf_read_abbrev_entry+0x968>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601068:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  804160106c:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601071:	e9 6c fd ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041601076:	ba 01 00 00 00       	mov    $0x1,%edx
  804160107b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160107f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601083:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160108a:	00 00 00 
  804160108d:	ff d0                	callq  *%rax
  804160108f:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  8041601093:	4d 85 e4             	test   %r12,%r12
  8041601096:	0f 84 10 06 00 00    	je     80416016ac <dwarf_read_abbrev_entry+0x972>
  804160109c:	45 85 ed             	test   %r13d,%r13d
  804160109f:	0f 84 07 06 00 00    	je     80416016ac <dwarf_read_abbrev_entry+0x972>
      bool data = get_unaligned(entry, Dwarf_Small);
  80416010a5:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  80416010a7:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  80416010ac:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  80416010b1:	e9 2c fd ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      int count = dwarf_read_leb128(entry, &data);
  80416010b6:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416010ba:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  80416010bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416010c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416010c7:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  80416010cc:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416010cf:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  80416010d3:	89 f0                	mov    %esi,%eax
  80416010d5:	83 e0 7f             	and    $0x7f,%eax
  80416010d8:	d3 e0                	shl    %cl,%eax
  80416010da:	09 c7                	or     %eax,%edi
    shift += 7;
  80416010dc:	83 c1 07             	add    $0x7,%ecx
    count++;
  80416010df:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  80416010e2:	40 84 f6             	test   %sil,%sil
  80416010e5:	78 e5                	js     80416010cc <dwarf_read_abbrev_entry+0x392>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  80416010e7:	83 f9 1f             	cmp    $0x1f,%ecx
  80416010ea:	7f 0f                	jg     80416010fb <dwarf_read_abbrev_entry+0x3c1>
  80416010ec:	40 f6 c6 40          	test   $0x40,%sil
  80416010f0:	74 09                	je     80416010fb <dwarf_read_abbrev_entry+0x3c1>
    result |= (-1U << shift);
  80416010f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416010f7:	d3 e0                	shl    %cl,%eax
  80416010f9:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  80416010fb:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  80416010fe:	49 01 c0             	add    %rax,%r8
  8041601101:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  8041601105:	4d 85 e4             	test   %r12,%r12
  8041601108:	0f 84 d4 fc ff ff    	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
  804160110e:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601112:	0f 86 ca fc ff ff    	jbe    8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (int *)buf);
  8041601118:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160111b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601120:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601124:	4c 89 e7             	mov    %r12,%rdi
  8041601127:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160112e:	00 00 00 
  8041601131:	ff d0                	callq  *%rax
  8041601133:	e9 aa fc ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601138:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160113c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601141:	4c 89 f6             	mov    %r14,%rsi
  8041601144:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601148:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160114f:	00 00 00 
  8041601152:	ff d0                	callq  *%rax
  8041601154:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601157:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601159:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160115e:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601161:	76 2a                	jbe    804160118d <dwarf_read_abbrev_entry+0x453>
    if (initial_len == DW_EXT_DWARF64) {
  8041601163:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601166:	74 60                	je     80416011c8 <dwarf_read_abbrev_entry+0x48e>
      cprintf("Unknown DWARF extension\n");
  8041601168:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  804160116f:	00 00 00 
  8041601172:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601177:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160117e:	00 00 00 
  8041601181:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601183:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  8041601188:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  804160118d:	48 63 c3             	movslq %ebx,%rax
  8041601190:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601194:	4d 85 e4             	test   %r12,%r12
  8041601197:	0f 84 45 fc ff ff    	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
  804160119d:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011a1:	0f 86 3b fc ff ff    	jbe    8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416011a7:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416011ab:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011b0:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011b4:	4c 89 e7             	mov    %r12,%rdi
  80416011b7:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416011be:	00 00 00 
  80416011c1:	ff d0                	callq  *%rax
  80416011c3:	e9 1a fc ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416011c8:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416011cc:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011d1:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416011d5:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416011dc:	00 00 00 
  80416011df:	ff d0                	callq  *%rax
  80416011e1:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416011e5:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416011ea:	eb a1                	jmp    804160118d <dwarf_read_abbrev_entry+0x453>
      int count         = dwarf_read_uleb128(entry, &data);
  80416011ec:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416011f0:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  80416011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416011f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416011fd:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601202:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601205:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601209:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160120c:	89 f0                	mov    %esi,%eax
  804160120e:	83 e0 7f             	and    $0x7f,%eax
  8041601211:	d3 e0                	shl    %cl,%eax
  8041601213:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601215:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601218:	40 84 f6             	test   %sil,%sil
  804160121b:	78 e5                	js     8041601202 <dwarf_read_abbrev_entry+0x4c8>
  return count;
  804160121d:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601220:	49 01 c0             	add    %rax,%r8
  8041601223:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  8041601227:	4d 85 e4             	test   %r12,%r12
  804160122a:	0f 84 b2 fb ff ff    	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
  8041601230:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601234:	0f 86 a8 fb ff ff    	jbe    8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  804160123a:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160123d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601242:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601246:	4c 89 e7             	mov    %r12,%rdi
  8041601249:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601250:	00 00 00 
  8041601253:	ff d0                	callq  *%rax
  8041601255:	e9 88 fb ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160125a:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160125e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601263:	4c 89 f6             	mov    %r14,%rsi
  8041601266:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160126a:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601271:	00 00 00 
  8041601274:	ff d0                	callq  *%rax
  8041601276:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601279:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160127b:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601280:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601283:	76 2a                	jbe    80416012af <dwarf_read_abbrev_entry+0x575>
    if (initial_len == DW_EXT_DWARF64) {
  8041601285:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601288:	74 60                	je     80416012ea <dwarf_read_abbrev_entry+0x5b0>
      cprintf("Unknown DWARF extension\n");
  804160128a:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  8041601291:	00 00 00 
  8041601294:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601299:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416012a0:	00 00 00 
  80416012a3:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416012a5:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416012af:	48 63 c3             	movslq %ebx,%rax
  80416012b2:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416012b6:	4d 85 e4             	test   %r12,%r12
  80416012b9:	0f 84 23 fb ff ff    	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
  80416012bf:	41 83 fd 07          	cmp    $0x7,%r13d
  80416012c3:	0f 86 19 fb ff ff    	jbe    8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416012c9:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416012cd:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012d2:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012d6:	4c 89 e7             	mov    %r12,%rdi
  80416012d9:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416012e0:	00 00 00 
  80416012e3:	ff d0                	callq  *%rax
  80416012e5:	e9 f8 fa ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416012ea:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416012ee:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012f3:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012f7:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416012fe:	00 00 00 
  8041601301:	ff d0                	callq  *%rax
  8041601303:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  8041601307:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160130c:	eb a1                	jmp    80416012af <dwarf_read_abbrev_entry+0x575>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  804160130e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601313:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601317:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160131b:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601322:	00 00 00 
  8041601325:	ff d0                	callq  *%rax
  8041601327:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160132b:	4d 85 e4             	test   %r12,%r12
  804160132e:	0f 84 82 03 00 00    	je     80416016b6 <dwarf_read_abbrev_entry+0x97c>
  8041601334:	45 85 ed             	test   %r13d,%r13d
  8041601337:	0f 84 79 03 00 00    	je     80416016b6 <dwarf_read_abbrev_entry+0x97c>
        put_unaligned(data, (Dwarf_Small *)buf);
  804160133d:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601341:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601346:	e9 97 fa ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  804160134b:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601350:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601354:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601358:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160135f:	00 00 00 
  8041601362:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041601364:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041601369:	4d 85 e4             	test   %r12,%r12
  804160136c:	74 06                	je     8041601374 <dwarf_read_abbrev_entry+0x63a>
  804160136e:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601372:	77 0a                	ja     804160137e <dwarf_read_abbrev_entry+0x644>
      bytes = sizeof(Dwarf_Half);
  8041601374:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041601379:	e9 64 fa ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  804160137e:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601383:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601387:	4c 89 e7             	mov    %r12,%rdi
  804160138a:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601391:	00 00 00 
  8041601394:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041601396:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  804160139b:	e9 42 fa ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416013a0:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013a5:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013a9:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416013ad:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416013b4:	00 00 00 
  80416013b7:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416013b9:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416013be:	4d 85 e4             	test   %r12,%r12
  80416013c1:	74 06                	je     80416013c9 <dwarf_read_abbrev_entry+0x68f>
  80416013c3:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013c7:	77 0a                	ja     80416013d3 <dwarf_read_abbrev_entry+0x699>
      bytes = sizeof(uint32_t);
  80416013c9:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416013ce:	e9 0f fa ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  80416013d3:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013d8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013dc:	4c 89 e7             	mov    %r12,%rdi
  80416013df:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416013e6:	00 00 00 
  80416013e9:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  80416013eb:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  80416013f0:	e9 ed f9 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  80416013f5:	ba 08 00 00 00       	mov    $0x8,%edx
  80416013fa:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013fe:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601402:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601409:	00 00 00 
  804160140c:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  804160140e:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601413:	4d 85 e4             	test   %r12,%r12
  8041601416:	74 06                	je     804160141e <dwarf_read_abbrev_entry+0x6e4>
  8041601418:	41 83 fd 07          	cmp    $0x7,%r13d
  804160141c:	77 0a                	ja     8041601428 <dwarf_read_abbrev_entry+0x6ee>
      bytes = sizeof(uint64_t);
  804160141e:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041601423:	e9 ba f9 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041601428:	ba 08 00 00 00       	mov    $0x8,%edx
  804160142d:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601431:	4c 89 e7             	mov    %r12,%rdi
  8041601434:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160143b:	00 00 00 
  804160143e:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601440:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041601445:	e9 98 f9 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &data);
  804160144a:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  804160144e:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601451:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601456:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160145b:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601460:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601463:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601467:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160146a:	89 f0                	mov    %esi,%eax
  804160146c:	83 e0 7f             	and    $0x7f,%eax
  804160146f:	d3 e0                	shl    %cl,%eax
  8041601471:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601473:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601476:	40 84 f6             	test   %sil,%sil
  8041601479:	78 e5                	js     8041601460 <dwarf_read_abbrev_entry+0x726>
  return count;
  804160147b:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  804160147e:	49 01 c0             	add    %rax,%r8
  8041601481:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  8041601485:	4d 85 e4             	test   %r12,%r12
  8041601488:	0f 84 54 f9 ff ff    	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
  804160148e:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601492:	0f 86 4a f9 ff ff    	jbe    8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  8041601498:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160149b:	ba 04 00 00 00       	mov    $0x4,%edx
  80416014a0:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416014a4:	4c 89 e7             	mov    %r12,%rdi
  80416014a7:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416014ae:	00 00 00 
  80416014b1:	ff d0                	callq  *%rax
  80416014b3:	e9 2a f9 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &form);
  80416014b8:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416014bc:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416014bf:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416014c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014ca:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416014cf:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416014d3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416014d7:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416014db:	44 89 c0             	mov    %r8d,%eax
  80416014de:	83 e0 7f             	and    $0x7f,%eax
  80416014e1:	d3 e0                	shl    %cl,%eax
  80416014e3:	09 c6                	or     %eax,%esi
    shift += 7;
  80416014e5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416014e8:	45 84 c0             	test   %r8b,%r8b
  80416014eb:	78 e2                	js     80416014cf <dwarf_read_abbrev_entry+0x795>
  return count;
  80416014ed:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  80416014f0:	48 01 c7             	add    %rax,%rdi
  80416014f3:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  80416014f7:	41 89 d8             	mov    %ebx,%r8d
  80416014fa:	44 89 e9             	mov    %r13d,%ecx
  80416014fd:	4c 89 e2             	mov    %r12,%rdx
  8041601500:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  8041601507:	00 00 00 
  804160150a:	ff d0                	callq  *%rax
      bytes    = count + read;
  804160150c:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601510:	e9 cd f8 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601515:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601519:	ba 04 00 00 00       	mov    $0x4,%edx
  804160151e:	4c 89 f6             	mov    %r14,%rsi
  8041601521:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601525:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160152c:	00 00 00 
  804160152f:	ff d0                	callq  *%rax
  8041601531:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601534:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601536:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160153b:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160153e:	76 2a                	jbe    804160156a <dwarf_read_abbrev_entry+0x830>
    if (initial_len == DW_EXT_DWARF64) {
  8041601540:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601543:	74 60                	je     80416015a5 <dwarf_read_abbrev_entry+0x86b>
      cprintf("Unknown DWARF extension\n");
  8041601545:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  804160154c:	00 00 00 
  804160154f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601554:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160155b:	00 00 00 
  804160155e:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601560:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  8041601565:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  804160156a:	48 63 c3             	movslq %ebx,%rax
  804160156d:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601571:	4d 85 e4             	test   %r12,%r12
  8041601574:	0f 84 68 f8 ff ff    	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
  804160157a:	41 83 fd 07          	cmp    $0x7,%r13d
  804160157e:	0f 86 5e f8 ff ff    	jbe    8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  8041601584:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601588:	ba 08 00 00 00       	mov    $0x8,%edx
  804160158d:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601591:	4c 89 e7             	mov    %r12,%rdi
  8041601594:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160159b:	00 00 00 
  804160159e:	ff d0                	callq  *%rax
  80416015a0:	e9 3d f8 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416015a5:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416015a9:	ba 08 00 00 00       	mov    $0x8,%edx
  80416015ae:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416015b2:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416015b9:	00 00 00 
  80416015bc:	ff d0                	callq  *%rax
  80416015be:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416015c2:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416015c7:	eb a1                	jmp    804160156a <dwarf_read_abbrev_entry+0x830>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416015c9:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416015cd:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416015d0:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416015d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416015db:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416015e0:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416015e3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416015e7:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416015eb:	89 f8                	mov    %edi,%eax
  80416015ed:	83 e0 7f             	and    $0x7f,%eax
  80416015f0:	d3 e0                	shl    %cl,%eax
  80416015f2:	09 c3                	or     %eax,%ebx
    shift += 7;
  80416015f4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416015f7:	40 84 ff             	test   %dil,%dil
  80416015fa:	78 e4                	js     80416015e0 <dwarf_read_abbrev_entry+0x8a6>
  return count;
  80416015fc:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  80416015ff:	4c 01 f6             	add    %r14,%rsi
  8041601602:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  8041601606:	4d 85 e4             	test   %r12,%r12
  8041601609:	74 1a                	je     8041601625 <dwarf_read_abbrev_entry+0x8eb>
        memcpy(buf, entry, MIN(length, bufsize));
  804160160b:	41 39 dd             	cmp    %ebx,%r13d
  804160160e:	44 89 ea             	mov    %r13d,%edx
  8041601611:	0f 47 d3             	cmova  %ebx,%edx
  8041601614:	89 d2                	mov    %edx,%edx
  8041601616:	4c 89 e7             	mov    %r12,%rdi
  8041601619:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601620:	00 00 00 
  8041601623:	ff d0                	callq  *%rax
      bytes = count + length;
  8041601625:	44 01 f3             	add    %r14d,%ebx
    } break;
  8041601628:	e9 b5 f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      bytes = 0;
  804160162d:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  8041601632:	48 85 d2             	test   %rdx,%rdx
  8041601635:	0f 84 a7 f7 ff ff    	je     8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(true, (bool *)buf);
  804160163b:	c6 02 01             	movb   $0x1,(%rdx)
  804160163e:	e9 9f f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601643:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601648:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160164c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601650:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601657:	00 00 00 
  804160165a:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  804160165c:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601661:	4d 85 e4             	test   %r12,%r12
  8041601664:	74 06                	je     804160166c <dwarf_read_abbrev_entry+0x932>
  8041601666:	41 83 fd 07          	cmp    $0x7,%r13d
  804160166a:	77 0a                	ja     8041601676 <dwarf_read_abbrev_entry+0x93c>
      bytes = sizeof(uint64_t);
  804160166c:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  8041601671:	e9 6c f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041601676:	ba 08 00 00 00       	mov    $0x8,%edx
  804160167b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160167f:	4c 89 e7             	mov    %r12,%rdi
  8041601682:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601689:	00 00 00 
  804160168c:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  804160168e:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041601693:	e9 4a f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
  int bytes = 0;
  8041601698:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160169d:	e9 40 f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016a2:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016a7:	e9 36 f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016ac:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016b1:	e9 2c f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016b6:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016bb:	e9 22 f7 ff ff       	jmpq   8041600de2 <dwarf_read_abbrev_entry+0xa8>

00000080416016c0 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416016c0:	55                   	push   %rbp
  80416016c1:	48 89 e5             	mov    %rsp,%rbp
  80416016c4:	41 57                	push   %r15
  80416016c6:	41 56                	push   %r14
  80416016c8:	41 55                	push   %r13
  80416016ca:	41 54                	push   %r12
  80416016cc:	53                   	push   %rbx
  80416016cd:	48 83 ec 48          	sub    $0x48,%rsp
  80416016d1:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80416016d5:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416016d9:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  80416016dd:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416016e1:	49 bd 64 c5 60 41 80 	movabs $0x804160c564,%r13
  80416016e8:	00 00 00 
  80416016eb:	e9 bb 01 00 00       	jmpq   80416018ab <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416016f0:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416016f4:	ba 08 00 00 00       	mov    $0x8,%edx
  80416016f9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416016fd:	41 ff d5             	callq  *%r13
  8041601700:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  8041601704:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601709:	eb 08                	jmp    8041601713 <info_by_address+0x53>
    *len = initial_len;
  804160170b:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  804160170e:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  8041601713:	4c 63 fb             	movslq %ebx,%r15
  8041601716:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  804160171a:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  804160171d:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601722:	48 89 de             	mov    %rbx,%rsi
  8041601725:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601729:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  804160172c:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  8041601730:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041601735:	75 7a                	jne    80416017b1 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601737:	ba 04 00 00 00       	mov    $0x4,%edx
  804160173c:	48 89 de             	mov    %rbx,%rsi
  804160173f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601743:	41 ff d5             	callq  *%r13
  8041601746:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041601749:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  804160174c:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  804160174f:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  8041601753:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601758:	48 89 de             	mov    %rbx,%rsi
  804160175b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160175f:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  8041601762:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601766:	75 7e                	jne    80416017e6 <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  8041601768:	48 83 c3 02          	add    $0x2,%rbx
  804160176c:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601771:	4c 89 fe             	mov    %r15,%rsi
  8041601774:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601778:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  804160177b:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  804160177f:	0f 85 96 00 00 00    	jne    804160181b <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  8041601785:	48 89 d8             	mov    %rbx,%rax
  8041601788:	4c 29 f0             	sub    %r14,%rax
  804160178b:	48 99                	cqto   
  804160178d:	48 c1 ea 3c          	shr    $0x3c,%rdx
  8041601791:	48 01 d0             	add    %rdx,%rax
  8041601794:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  8041601797:	48 29 d0             	sub    %rdx,%rax
  804160179a:	0f 84 b5 00 00 00    	je     8041601855 <info_by_address+0x195>
      set += 2 * address_size - remainder;
  80416017a0:	ba 10 00 00 00       	mov    $0x10,%edx
  80416017a5:	89 d1                	mov    %edx,%ecx
  80416017a7:	29 c1                	sub    %eax,%ecx
  80416017a9:	48 01 cb             	add    %rcx,%rbx
  80416017ac:	e9 a4 00 00 00       	jmpq   8041601855 <info_by_address+0x195>
    assert(version == 2);
  80416017b1:	48 b9 3e d0 60 41 80 	movabs $0x804160d03e,%rcx
  80416017b8:	00 00 00 
  80416017bb:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416017c2:	00 00 00 
  80416017c5:	be 20 00 00 00       	mov    $0x20,%esi
  80416017ca:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  80416017d1:	00 00 00 
  80416017d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017d9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416017e0:	00 00 00 
  80416017e3:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416017e6:	48 b9 fb cf 60 41 80 	movabs $0x804160cffb,%rcx
  80416017ed:	00 00 00 
  80416017f0:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416017f7:	00 00 00 
  80416017fa:	be 24 00 00 00       	mov    $0x24,%esi
  80416017ff:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601806:	00 00 00 
  8041601809:	b8 00 00 00 00       	mov    $0x0,%eax
  804160180e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601815:	00 00 00 
  8041601818:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  804160181b:	48 b9 0d d0 60 41 80 	movabs $0x804160d00d,%rcx
  8041601822:	00 00 00 
  8041601825:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160182c:	00 00 00 
  804160182f:	be 26 00 00 00       	mov    $0x26,%esi
  8041601834:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  804160183b:	00 00 00 
  804160183e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601843:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160184a:	00 00 00 
  804160184d:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601850:	4c 39 e3             	cmp    %r12,%rbx
  8041601853:	73 51                	jae    80416018a6 <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  8041601855:	ba 08 00 00 00       	mov    $0x8,%edx
  804160185a:	48 89 de             	mov    %rbx,%rsi
  804160185d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601861:	41 ff d5             	callq  *%r13
  8041601864:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  8041601868:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  804160186c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601871:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601875:	41 ff d5             	callq  *%r13
  8041601878:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  804160187b:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  804160187f:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8041601883:	4c 39 f1             	cmp    %r14,%rcx
  8041601886:	72 c8                	jb     8041601850 <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  8041601888:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  804160188a:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  804160188d:	48 39 c1             	cmp    %rax,%rcx
  8041601890:	77 be                	ja     8041601850 <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601892:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041601896:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  8041601899:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  804160189c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018a1:	e9 5a 04 00 00       	jmpq   8041601d00 <info_by_address+0x640>
      set += address_size;
  80416018a6:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  80416018a9:	75 71                	jne    804160191c <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  80416018ab:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018af:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  80416018b3:	73 42                	jae    80416018f7 <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  80416018b5:	ba 04 00 00 00       	mov    $0x4,%edx
  80416018ba:	4c 89 f6             	mov    %r14,%rsi
  80416018bd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018c1:	41 ff d5             	callq  *%r13
  80416018c4:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416018c8:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  80416018cc:	0f 86 39 fe ff ff    	jbe    804160170b <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  80416018d2:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  80416018d6:	0f 84 14 fe ff ff    	je     80416016f0 <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  80416018dc:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  80416018e3:	00 00 00 
  80416018e6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018eb:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416018f2:	00 00 00 
  80416018f5:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  80416018f7:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018fb:	48 8b 58 20          	mov    0x20(%rax),%rbx
  80416018ff:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601903:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  8041601907:	0f 83 5b 04 00 00    	jae    8041601d68 <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  804160190d:	49 bf 64 c5 60 41 80 	movabs $0x804160c564,%r15
  8041601914:	00 00 00 
  8041601917:	e9 9f 03 00 00       	jmpq   8041601cbb <info_by_address+0x5fb>
    assert(set == set_end);
  804160191c:	48 b9 1f d0 60 41 80 	movabs $0x804160d01f,%rcx
  8041601923:	00 00 00 
  8041601926:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160192d:	00 00 00 
  8041601930:	be 3a 00 00 00       	mov    $0x3a,%esi
  8041601935:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  804160193c:	00 00 00 
  804160193f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601944:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160194b:	00 00 00 
  804160194e:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601951:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601955:	48 8d 70 20          	lea    0x20(%rax),%rsi
  8041601959:	ba 08 00 00 00       	mov    $0x8,%edx
  804160195e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601962:	41 ff d7             	callq  *%r15
  8041601965:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041601969:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  804160196f:	eb 08                	jmp    8041601979 <info_by_address+0x2b9>
    *len = initial_len;
  8041601971:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041601973:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  8041601979:	4d 63 e4             	movslq %r12d,%r12
  804160197c:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041601980:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  8041601984:	48 01 d8             	add    %rbx,%rax
  8041601987:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160198b:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601990:	48 89 de             	mov    %rbx,%rsi
  8041601993:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601997:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  804160199a:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  804160199e:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416019a2:	83 e8 02             	sub    $0x2,%eax
  80416019a5:	66 a9 fd ff          	test   $0xfffd,%ax
  80416019a9:	0f 85 07 01 00 00    	jne    8041601ab6 <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416019af:	ba 04 00 00 00       	mov    $0x4,%edx
  80416019b4:	48 89 de             	mov    %rbx,%rsi
  80416019b7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019bb:	41 ff d7             	callq  *%r15
  80416019be:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  80416019c2:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416019c6:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  80416019ca:	ba 01 00 00 00       	mov    $0x1,%edx
  80416019cf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019d3:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  80416019d6:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416019da:	0f 85 0b 01 00 00    	jne    8041601aeb <info_by_address+0x42b>
  80416019e0:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  80416019e3:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416019e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416019ed:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416019f2:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  80416019f6:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  80416019fa:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416019fd:	44 89 c7             	mov    %r8d,%edi
  8041601a00:	83 e7 7f             	and    $0x7f,%edi
  8041601a03:	d3 e7                	shl    %cl,%edi
  8041601a05:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a07:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a0a:	45 84 c0             	test   %r8b,%r8b
  8041601a0d:	78 e3                	js     80416019f2 <info_by_address+0x332>
  return count;
  8041601a0f:	48 98                	cltq   
    assert(abbrev_code != 0);
  8041601a11:	85 d2                	test   %edx,%edx
  8041601a13:	0f 84 07 01 00 00    	je     8041601b20 <info_by_address+0x460>
    entry += count;
  8041601a19:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601a1c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601a20:	4c 03 28             	add    (%rax),%r13
  8041601a23:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  8041601a26:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a30:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601a35:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041601a39:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041601a3d:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a40:	45 89 c8             	mov    %r9d,%r8d
  8041601a43:	41 83 e0 7f          	and    $0x7f,%r8d
  8041601a47:	41 d3 e0             	shl    %cl,%r8d
  8041601a4a:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  8041601a4d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a50:	45 84 c9             	test   %r9b,%r9b
  8041601a53:	78 e0                	js     8041601a35 <info_by_address+0x375>
  return count;
  8041601a55:	48 98                	cltq   
    abbrev_entry += count;
  8041601a57:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  8041601a5a:	39 f2                	cmp    %esi,%edx
  8041601a5c:	0f 85 f3 00 00 00    	jne    8041601b55 <info_by_address+0x495>
  8041601a62:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  8041601a65:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a6f:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601a74:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601a78:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a7c:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a7f:	44 89 c7             	mov    %r8d,%edi
  8041601a82:	83 e7 7f             	and    $0x7f,%edi
  8041601a85:	d3 e7                	shl    %cl,%edi
  8041601a87:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a89:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a8c:	45 84 c0             	test   %r8b,%r8b
  8041601a8f:	78 e3                	js     8041601a74 <info_by_address+0x3b4>
  return count;
  8041601a91:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  8041601a93:	83 fa 11             	cmp    $0x11,%edx
  8041601a96:	0f 85 ee 00 00 00    	jne    8041601b8a <info_by_address+0x4ca>
    abbrev_entry++;
  8041601a9c:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601aa1:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601aa8:	00 
  8041601aa9:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601ab0:	00 
  8041601ab1:	e9 2f 01 00 00       	jmpq   8041601be5 <info_by_address+0x525>
    assert(version == 4 || version == 2);
  8041601ab6:	48 b9 2e d0 60 41 80 	movabs $0x804160d02e,%rcx
  8041601abd:	00 00 00 
  8041601ac0:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601ac7:	00 00 00 
  8041601aca:	be 43 01 00 00       	mov    $0x143,%esi
  8041601acf:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601ad6:	00 00 00 
  8041601ad9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ade:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ae5:	00 00 00 
  8041601ae8:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601aeb:	48 b9 fb cf 60 41 80 	movabs $0x804160cffb,%rcx
  8041601af2:	00 00 00 
  8041601af5:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601afc:	00 00 00 
  8041601aff:	be 47 01 00 00       	mov    $0x147,%esi
  8041601b04:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601b0b:	00 00 00 
  8041601b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b13:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b1a:	00 00 00 
  8041601b1d:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601b20:	48 b9 4b d0 60 41 80 	movabs $0x804160d04b,%rcx
  8041601b27:	00 00 00 
  8041601b2a:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601b31:	00 00 00 
  8041601b34:	be 4c 01 00 00       	mov    $0x14c,%esi
  8041601b39:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601b40:	00 00 00 
  8041601b43:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b48:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b4f:	00 00 00 
  8041601b52:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601b55:	48 b9 80 d1 60 41 80 	movabs $0x804160d180,%rcx
  8041601b5c:	00 00 00 
  8041601b5f:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601b66:	00 00 00 
  8041601b69:	be 54 01 00 00       	mov    $0x154,%esi
  8041601b6e:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601b75:	00 00 00 
  8041601b78:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b7d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b84:	00 00 00 
  8041601b87:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601b8a:	48 b9 5c d0 60 41 80 	movabs $0x804160d05c,%rcx
  8041601b91:	00 00 00 
  8041601b94:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601b9b:	00 00 00 
  8041601b9e:	be 58 01 00 00       	mov    $0x158,%esi
  8041601ba3:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601baa:	00 00 00 
  8041601bad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601bb2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601bb9:	00 00 00 
  8041601bbc:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601bbf:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601bc5:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601bca:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601bce:	44 89 f6             	mov    %r14d,%esi
  8041601bd1:	4c 89 e7             	mov    %r12,%rdi
  8041601bd4:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  8041601bdb:	00 00 00 
  8041601bde:	ff d0                	callq  *%rax
      entry += count;
  8041601be0:	48 98                	cltq   
  8041601be2:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601be5:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601be8:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601bed:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601bf2:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601bf8:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601bfb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601bff:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c02:	89 fe                	mov    %edi,%esi
  8041601c04:	83 e6 7f             	and    $0x7f,%esi
  8041601c07:	d3 e6                	shl    %cl,%esi
  8041601c09:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601c0c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c0f:	40 84 ff             	test   %dil,%dil
  8041601c12:	78 e4                	js     8041601bf8 <info_by_address+0x538>
  return count;
  8041601c14:	48 98                	cltq   
      abbrev_entry += count;
  8041601c16:	48 01 c3             	add    %rax,%rbx
  8041601c19:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c26:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601c2c:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c2f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c33:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c36:	89 fe                	mov    %edi,%esi
  8041601c38:	83 e6 7f             	and    $0x7f,%esi
  8041601c3b:	d3 e6                	shl    %cl,%esi
  8041601c3d:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601c40:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c43:	40 84 ff             	test   %dil,%dil
  8041601c46:	78 e4                	js     8041601c2c <info_by_address+0x56c>
  return count;
  8041601c48:	48 98                	cltq   
      abbrev_entry += count;
  8041601c4a:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601c4d:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601c51:	0f 84 68 ff ff ff    	je     8041601bbf <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601c57:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601c5b:	0f 84 ae 00 00 00    	je     8041601d0f <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601c61:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c67:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601c71:	44 89 f6             	mov    %r14d,%esi
  8041601c74:	4c 89 e7             	mov    %r12,%rdi
  8041601c77:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  8041601c7e:	00 00 00 
  8041601c81:	ff d0                	callq  *%rax
      entry += count;
  8041601c83:	48 98                	cltq   
  8041601c85:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601c88:	45 09 f5             	or     %r14d,%r13d
  8041601c8b:	0f 85 54 ff ff ff    	jne    8041601be5 <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601c91:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601c95:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601c99:	72 0a                	jb     8041601ca5 <info_by_address+0x5e5>
  8041601c9b:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601c9f:	0f 86 a2 00 00 00    	jbe    8041601d47 <info_by_address+0x687>
    entry = entry_end;
  8041601ca5:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601ca9:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601cad:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601cb1:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601cb5:	0f 83 a6 00 00 00    	jae    8041601d61 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601cbb:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601cc0:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601cc4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601cc8:	41 ff d7             	callq  *%r15
  8041601ccb:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601cce:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601cd1:	0f 86 9a fc ff ff    	jbe    8041601971 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601cd7:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601cda:	0f 84 71 fc ff ff    	je     8041601951 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601ce0:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  8041601ce7:	00 00 00 
  8041601cea:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cef:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041601cf6:	00 00 00 
  8041601cf9:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601cfb:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601d00:	48 83 c4 48          	add    $0x48,%rsp
  8041601d04:	5b                   	pop    %rbx
  8041601d05:	41 5c                	pop    %r12
  8041601d07:	41 5d                	pop    %r13
  8041601d09:	41 5e                	pop    %r14
  8041601d0b:	41 5f                	pop    %r15
  8041601d0d:	5d                   	pop    %rbp
  8041601d0e:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601d0f:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601d15:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601d1a:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601d1e:	44 89 f6             	mov    %r14d,%esi
  8041601d21:	4c 89 e7             	mov    %r12,%rdi
  8041601d24:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  8041601d2b:	00 00 00 
  8041601d2e:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601d30:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601d34:	0f 84 a6 fe ff ff    	je     8041601be0 <info_by_address+0x520>
          high_pc += low_pc;
  8041601d3a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601d3e:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601d42:	e9 99 fe ff ff       	jmpq   8041601be0 <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601d47:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601d4b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601d4f:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601d53:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601d57:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d5f:	eb 9f                	jmp    8041601d00 <info_by_address+0x640>
  return 0;
  8041601d61:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d66:	eb 98                	jmp    8041601d00 <info_by_address+0x640>
  8041601d68:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d6d:	eb 91                	jmp    8041601d00 <info_by_address+0x640>

0000008041601d6f <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601d6f:	55                   	push   %rbp
  8041601d70:	48 89 e5             	mov    %rsp,%rbp
  8041601d73:	41 57                	push   %r15
  8041601d75:	41 56                	push   %r14
  8041601d77:	41 55                	push   %r13
  8041601d79:	41 54                	push   %r12
  8041601d7b:	53                   	push   %rbx
  8041601d7c:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601d80:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601d84:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601d88:	48 29 d8             	sub    %rbx,%rax
  8041601d8b:	48 39 f0             	cmp    %rsi,%rax
  8041601d8e:	0f 82 f5 02 00 00    	jb     8041602089 <file_name_by_info+0x31a>
  8041601d94:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601d98:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601d9b:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601d9f:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601da3:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601da6:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601dab:	48 89 de             	mov    %rbx,%rsi
  8041601dae:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601db2:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601db9:	00 00 00 
  8041601dbc:	ff d0                	callq  *%rax
  8041601dbe:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601dc1:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601dc4:	0f 86 c9 02 00 00    	jbe    8041602093 <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601dca:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601dcd:	74 25                	je     8041601df4 <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601dcf:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  8041601dd6:	00 00 00 
  8041601dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dde:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041601de5:	00 00 00 
  8041601de8:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601dea:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601def:	e9 00 02 00 00       	jmpq   8041601ff4 <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601df4:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601df8:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601dfd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601e01:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041601e08:	00 00 00 
  8041601e0b:	ff d0                	callq  *%rax
      count = 12;
  8041601e0d:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601e13:	e9 81 02 00 00       	jmpq   8041602099 <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601e18:	48 b9 2e d0 60 41 80 	movabs $0x804160d02e,%rcx
  8041601e1f:	00 00 00 
  8041601e22:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601e29:	00 00 00 
  8041601e2c:	be 9b 01 00 00       	mov    $0x19b,%esi
  8041601e31:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601e38:	00 00 00 
  8041601e3b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e40:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e47:	00 00 00 
  8041601e4a:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601e4d:	48 b9 fb cf 60 41 80 	movabs $0x804160cffb,%rcx
  8041601e54:	00 00 00 
  8041601e57:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601e5e:	00 00 00 
  8041601e61:	be 9f 01 00 00       	mov    $0x19f,%esi
  8041601e66:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601e6d:	00 00 00 
  8041601e70:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e75:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e7c:	00 00 00 
  8041601e7f:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601e82:	48 b9 4b d0 60 41 80 	movabs $0x804160d04b,%rcx
  8041601e89:	00 00 00 
  8041601e8c:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601e93:	00 00 00 
  8041601e96:	be a4 01 00 00       	mov    $0x1a4,%esi
  8041601e9b:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601ea2:	00 00 00 
  8041601ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601eaa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601eb1:	00 00 00 
  8041601eb4:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601eb7:	48 b9 80 d1 60 41 80 	movabs $0x804160d180,%rcx
  8041601ebe:	00 00 00 
  8041601ec1:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601ec8:	00 00 00 
  8041601ecb:	be ac 01 00 00       	mov    $0x1ac,%esi
  8041601ed0:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601ed7:	00 00 00 
  8041601eda:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601edf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ee6:	00 00 00 
  8041601ee9:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601eec:	48 b9 5c d0 60 41 80 	movabs $0x804160d05c,%rcx
  8041601ef3:	00 00 00 
  8041601ef6:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041601efd:	00 00 00 
  8041601f00:	be b0 01 00 00       	mov    $0x1b0,%esi
  8041601f05:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041601f0c:	00 00 00 
  8041601f0f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f14:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601f1b:	00 00 00 
  8041601f1e:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601f21:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601f25:	0f 84 d8 00 00 00    	je     8041602003 <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601f2b:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f31:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601f34:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601f38:	44 89 ee             	mov    %r13d,%esi
  8041601f3b:	4c 89 f7             	mov    %r14,%rdi
  8041601f3e:	41 ff d7             	callq  *%r15
  8041601f41:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601f44:	49 63 c4             	movslq %r12d,%rax
  8041601f47:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601f4a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f4d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f52:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f57:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601f5d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f60:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f64:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f67:	89 f0                	mov    %esi,%eax
  8041601f69:	83 e0 7f             	and    $0x7f,%eax
  8041601f6c:	d3 e0                	shl    %cl,%eax
  8041601f6e:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601f71:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601f74:	40 84 f6             	test   %sil,%sil
  8041601f77:	78 e4                	js     8041601f5d <file_name_by_info+0x1ee>
  return count;
  8041601f79:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601f7c:	48 01 fb             	add    %rdi,%rbx
  8041601f7f:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f82:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f87:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f8c:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601f92:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f95:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f99:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f9c:	89 f0                	mov    %esi,%eax
  8041601f9e:	83 e0 7f             	and    $0x7f,%eax
  8041601fa1:	d3 e0                	shl    %cl,%eax
  8041601fa3:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601fa6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601fa9:	40 84 f6             	test   %sil,%sil
  8041601fac:	78 e4                	js     8041601f92 <file_name_by_info+0x223>
  return count;
  8041601fae:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601fb1:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041601fb4:	41 83 fc 03          	cmp    $0x3,%r12d
  8041601fb8:	0f 84 63 ff ff ff    	je     8041601f21 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041601fbe:	41 83 fc 10          	cmp    $0x10,%r12d
  8041601fc2:	0f 84 a1 00 00 00    	je     8041602069 <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601fc8:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601fce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601fd3:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601fd8:	44 89 ee             	mov    %r13d,%esi
  8041601fdb:	4c 89 f7             	mov    %r14,%rdi
  8041601fde:	41 ff d7             	callq  *%r15
    entry += count;
  8041601fe1:	48 98                	cltq   
  8041601fe3:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601fe6:	45 09 e5             	or     %r12d,%r13d
  8041601fe9:	0f 85 5b ff ff ff    	jne    8041601f4a <file_name_by_info+0x1db>

  return 0;
  8041601fef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601ff4:	48 83 c4 38          	add    $0x38,%rsp
  8041601ff8:	5b                   	pop    %rbx
  8041601ff9:	41 5c                	pop    %r12
  8041601ffb:	41 5d                	pop    %r13
  8041601ffd:	41 5e                	pop    %r14
  8041601fff:	41 5f                	pop    %r15
  8041602001:	5d                   	pop    %rbp
  8041602002:	c3                   	retq   
        unsigned long offset = 0;
  8041602003:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160200a:	00 
        count                = dwarf_read_abbrev_entry(
  804160200b:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602011:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602016:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160201a:	be 0e 00 00 00       	mov    $0xe,%esi
  804160201f:	4c 89 f7             	mov    %r14,%rdi
  8041602022:	41 ff d7             	callq  *%r15
  8041602025:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  8041602028:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  804160202c:	48 85 ff             	test   %rdi,%rdi
  804160202f:	0f 84 0f ff ff ff    	je     8041601f44 <file_name_by_info+0x1d5>
  8041602035:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  8041602039:	0f 86 05 ff ff ff    	jbe    8041601f44 <file_name_by_info+0x1d5>
          put_unaligned(
  804160203f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602043:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  8041602047:	48 03 41 40          	add    0x40(%rcx),%rax
  804160204b:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  804160204f:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602054:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602058:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160205f:	00 00 00 
  8041602062:	ff d0                	callq  *%rax
  8041602064:	e9 db fe ff ff       	jmpq   8041601f44 <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  8041602069:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160206f:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602074:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041602078:	44 89 ee             	mov    %r13d,%esi
  804160207b:	4c 89 f7             	mov    %r14,%rdi
  804160207e:	41 ff d7             	callq  *%r15
  8041602081:	41 89 c4             	mov    %eax,%r12d
  8041602084:	e9 bb fe ff ff       	jmpq   8041601f44 <file_name_by_info+0x1d5>
    return -E_INVAL;
  8041602089:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160208e:	e9 61 ff ff ff       	jmpq   8041601ff4 <file_name_by_info+0x285>
  count       = 4;
  8041602093:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  8041602099:	4d 63 ed             	movslq %r13d,%r13
  804160209c:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160209f:	ba 02 00 00 00       	mov    $0x2,%edx
  80416020a4:	48 89 de             	mov    %rbx,%rsi
  80416020a7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020ab:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416020b2:	00 00 00 
  80416020b5:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416020b7:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416020bb:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416020bf:	83 e8 02             	sub    $0x2,%eax
  80416020c2:	66 a9 fd ff          	test   $0xfffd,%ax
  80416020c6:	0f 85 4c fd ff ff    	jne    8041601e18 <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416020cc:	ba 04 00 00 00       	mov    $0x4,%edx
  80416020d1:	48 89 de             	mov    %rbx,%rsi
  80416020d4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020d8:	49 bf 64 c5 60 41 80 	movabs $0x804160c564,%r15
  80416020df:	00 00 00 
  80416020e2:	41 ff d7             	callq  *%r15
  80416020e5:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  80416020e9:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416020ed:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416020f1:	ba 01 00 00 00       	mov    $0x1,%edx
  80416020f6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020fa:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  80416020fd:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602101:	0f 85 46 fd ff ff    	jne    8041601e4d <file_name_by_info+0xde>
  8041602107:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  804160210a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160210f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602114:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  804160211a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160211d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602121:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602124:	89 f0                	mov    %esi,%eax
  8041602126:	83 e0 7f             	and    $0x7f,%eax
  8041602129:	d3 e0                	shl    %cl,%eax
  804160212b:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  804160212e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602131:	40 84 f6             	test   %sil,%sil
  8041602134:	78 e4                	js     804160211a <file_name_by_info+0x3ab>
  return count;
  8041602136:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  8041602139:	45 85 c0             	test   %r8d,%r8d
  804160213c:	0f 84 40 fd ff ff    	je     8041601e82 <file_name_by_info+0x113>
  entry += count;
  8041602142:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041602145:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041602149:	4c 03 20             	add    (%rax),%r12
  804160214c:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  804160214f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602154:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602159:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160215f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602162:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602166:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602169:	89 f0                	mov    %esi,%eax
  804160216b:	83 e0 7f             	and    $0x7f,%eax
  804160216e:	d3 e0                	shl    %cl,%eax
  8041602170:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602173:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602176:	40 84 f6             	test   %sil,%sil
  8041602179:	78 e4                	js     804160215f <file_name_by_info+0x3f0>
  return count;
  804160217b:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  804160217e:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  8041602181:	45 39 c8             	cmp    %r9d,%r8d
  8041602184:	0f 85 2d fd ff ff    	jne    8041601eb7 <file_name_by_info+0x148>
  804160218a:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  804160218d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602192:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602197:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  804160219d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416021a0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416021a4:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416021a7:	89 f0                	mov    %esi,%eax
  80416021a9:	83 e0 7f             	and    $0x7f,%eax
  80416021ac:	d3 e0                	shl    %cl,%eax
  80416021ae:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416021b1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416021b4:	40 84 f6             	test   %sil,%sil
  80416021b7:	78 e4                	js     804160219d <file_name_by_info+0x42e>
  return count;
  80416021b9:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  80416021bc:	41 83 f8 11          	cmp    $0x11,%r8d
  80416021c0:	0f 85 26 fd ff ff    	jne    8041601eec <file_name_by_info+0x17d>
  abbrev_entry++;
  80416021c6:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  80416021cb:	49 bf 3a 0d 60 41 80 	movabs $0x8041600d3a,%r15
  80416021d2:	00 00 00 
  80416021d5:	e9 70 fd ff ff       	jmpq   8041601f4a <file_name_by_info+0x1db>

00000080416021da <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  80416021da:	55                   	push   %rbp
  80416021db:	48 89 e5             	mov    %rsp,%rbp
  80416021de:	41 57                	push   %r15
  80416021e0:	41 56                	push   %r14
  80416021e2:	41 55                	push   %r13
  80416021e4:	41 54                	push   %r12
  80416021e6:	53                   	push   %rbx
  80416021e7:	48 83 ec 68          	sub    $0x68,%rsp
  80416021eb:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  80416021ef:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  80416021f6:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  80416021fa:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  80416021fe:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  8041602205:	48 89 d3             	mov    %rdx,%rbx
  8041602208:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160220c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602211:	48 89 de             	mov    %rbx,%rsi
  8041602214:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602218:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160221f:	00 00 00 
  8041602222:	ff d0                	callq  *%rax
  8041602224:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602227:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160222a:	76 59                	jbe    8041602285 <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  804160222c:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160222f:	74 2f                	je     8041602260 <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602231:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  8041602238:	00 00 00 
  804160223b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602240:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041602247:	00 00 00 
  804160224a:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  804160224c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602251:	48 83 c4 68          	add    $0x68,%rsp
  8041602255:	5b                   	pop    %rbx
  8041602256:	41 5c                	pop    %r12
  8041602258:	41 5d                	pop    %r13
  804160225a:	41 5e                	pop    %r14
  804160225c:	41 5f                	pop    %r15
  804160225e:	5d                   	pop    %rbp
  804160225f:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602260:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041602264:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602269:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160226d:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041602274:	00 00 00 
  8041602277:	ff d0                	callq  *%rax
  8041602279:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160227d:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  8041602283:	eb 08                	jmp    804160228d <function_by_info+0xb3>
    *len = initial_len;
  8041602285:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602287:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  804160228d:	4d 63 f6             	movslq %r14d,%r14
  8041602290:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  8041602293:	48 01 d8             	add    %rbx,%rax
  8041602296:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  804160229a:	ba 02 00 00 00       	mov    $0x2,%edx
  804160229f:	48 89 de             	mov    %rbx,%rsi
  80416022a2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022a6:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416022ad:	00 00 00 
  80416022b0:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416022b2:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416022b6:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416022ba:	83 e8 02             	sub    $0x2,%eax
  80416022bd:	66 a9 fd ff          	test   $0xfffd,%ax
  80416022c1:	75 51                	jne    8041602314 <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416022c3:	ba 04 00 00 00       	mov    $0x4,%edx
  80416022c8:	48 89 de             	mov    %rbx,%rsi
  80416022cb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022cf:	49 bc 64 c5 60 41 80 	movabs $0x804160c564,%r12
  80416022d6:	00 00 00 
  80416022d9:	41 ff d4             	callq  *%r12
  80416022dc:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  80416022e0:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416022e4:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416022e8:	ba 01 00 00 00       	mov    $0x1,%edx
  80416022ed:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022f1:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  80416022f4:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416022f8:	75 4f                	jne    8041602349 <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  80416022fa:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416022fe:	4c 03 28             	add    (%rax),%r13
  8041602301:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  8041602305:	49 bf 3a 0d 60 41 80 	movabs $0x8041600d3a,%r15
  804160230c:	00 00 00 
  while (entry < entry_end) {
  804160230f:	e9 07 02 00 00       	jmpq   804160251b <function_by_info+0x341>
  assert(version == 4 || version == 2);
  8041602314:	48 b9 2e d0 60 41 80 	movabs $0x804160d02e,%rcx
  804160231b:	00 00 00 
  804160231e:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041602325:	00 00 00 
  8041602328:	be e9 01 00 00       	mov    $0x1e9,%esi
  804160232d:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041602334:	00 00 00 
  8041602337:	b8 00 00 00 00       	mov    $0x0,%eax
  804160233c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602343:	00 00 00 
  8041602346:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  8041602349:	48 b9 fb cf 60 41 80 	movabs $0x804160cffb,%rcx
  8041602350:	00 00 00 
  8041602353:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160235a:	00 00 00 
  804160235d:	be ed 01 00 00       	mov    $0x1ed,%esi
  8041602362:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041602369:	00 00 00 
  804160236c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602371:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602378:	00 00 00 
  804160237b:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  804160237e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602382:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  8041602386:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  804160238a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  8041602390:	49 39 da             	cmp    %rbx,%r10
  8041602393:	0f 86 e7 00 00 00    	jbe    8041602480 <function_by_info+0x2a6>
  8041602399:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160239c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416023a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023a7:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416023ac:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023af:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023b3:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416023b7:	89 f8                	mov    %edi,%eax
  80416023b9:	83 e0 7f             	and    $0x7f,%eax
  80416023bc:	d3 e0                	shl    %cl,%eax
  80416023be:	09 c6                	or     %eax,%esi
    shift += 7;
  80416023c0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023c3:	40 84 ff             	test   %dil,%dil
  80416023c6:	78 e4                	js     80416023ac <function_by_info+0x1d2>
  return count;
  80416023c8:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  80416023cb:	4c 01 c3             	add    %r8,%rbx
  80416023ce:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023d1:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  80416023d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023dc:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416023e2:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023e5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023e9:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  80416023ed:	89 f8                	mov    %edi,%eax
  80416023ef:	83 e0 7f             	and    $0x7f,%eax
  80416023f2:	d3 e0                	shl    %cl,%eax
  80416023f4:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416023f7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023fa:	40 84 ff             	test   %dil,%dil
  80416023fd:	78 e3                	js     80416023e2 <function_by_info+0x208>
  return count;
  80416023ff:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  8041602402:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  8041602407:	41 39 f1             	cmp    %esi,%r9d
  804160240a:	74 74                	je     8041602480 <function_by_info+0x2a6>
  result = 0;
  804160240c:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160240f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602414:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602419:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  804160241f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602422:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602426:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602429:	89 f0                	mov    %esi,%eax
  804160242b:	83 e0 7f             	and    $0x7f,%eax
  804160242e:	d3 e0                	shl    %cl,%eax
  8041602430:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602433:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602436:	40 84 f6             	test   %sil,%sil
  8041602439:	78 e4                	js     804160241f <function_by_info+0x245>
  return count;
  804160243b:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160243e:	48 01 fb             	add    %rdi,%rbx
  8041602441:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602444:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602449:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160244e:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602454:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602457:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160245b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160245e:	89 f0                	mov    %esi,%eax
  8041602460:	83 e0 7f             	and    $0x7f,%eax
  8041602463:	d3 e0                	shl    %cl,%eax
  8041602465:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602468:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160246b:	40 84 f6             	test   %sil,%sil
  804160246e:	78 e4                	js     8041602454 <function_by_info+0x27a>
  return count;
  8041602470:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602473:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  8041602476:	45 09 dc             	or     %r11d,%r12d
  8041602479:	75 91                	jne    804160240c <function_by_info+0x232>
  804160247b:	e9 10 ff ff ff       	jmpq   8041602390 <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  8041602480:	41 83 f8 2e          	cmp    $0x2e,%r8d
  8041602484:	0f 84 e9 00 00 00    	je     8041602573 <function_by_info+0x399>
            fn_name_entry = entry;
  804160248a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160248d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602492:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602497:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160249d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024a0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024a4:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024a7:	89 f0                	mov    %esi,%eax
  80416024a9:	83 e0 7f             	and    $0x7f,%eax
  80416024ac:	d3 e0                	shl    %cl,%eax
  80416024ae:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416024b1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024b4:	40 84 f6             	test   %sil,%sil
  80416024b7:	78 e4                	js     804160249d <function_by_info+0x2c3>
  return count;
  80416024b9:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024bc:	48 01 fb             	add    %rdi,%rbx
  80416024bf:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024c2:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024cc:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024d2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024d5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024d9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024dc:	89 f0                	mov    %esi,%eax
  80416024de:	83 e0 7f             	and    $0x7f,%eax
  80416024e1:	d3 e0                	shl    %cl,%eax
  80416024e3:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024e6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024e9:	40 84 f6             	test   %sil,%sil
  80416024ec:	78 e4                	js     80416024d2 <function_by_info+0x2f8>
  return count;
  80416024ee:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024f1:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  80416024f4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416024fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416024ff:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602504:	44 89 e6             	mov    %r12d,%esi
  8041602507:	4c 89 f7             	mov    %r14,%rdi
  804160250a:	41 ff d7             	callq  *%r15
        entry += count;
  804160250d:	48 98                	cltq   
  804160250f:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602512:	45 09 ec             	or     %r13d,%r12d
  8041602515:	0f 85 6f ff ff ff    	jne    804160248a <function_by_info+0x2b0>
  while (entry < entry_end) {
  804160251b:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  804160251f:	0f 83 37 02 00 00    	jae    804160275c <function_by_info+0x582>
                 uintptr_t *offset) {
  8041602525:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602528:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160252d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602532:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602538:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160253b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160253f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602542:	89 f0                	mov    %esi,%eax
  8041602544:	83 e0 7f             	and    $0x7f,%eax
  8041602547:	d3 e0                	shl    %cl,%eax
  8041602549:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160254c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160254f:	40 84 f6             	test   %sil,%sil
  8041602552:	78 e4                	js     8041602538 <function_by_info+0x35e>
  return count;
  8041602554:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  8041602557:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  804160255a:	45 85 c9             	test   %r9d,%r9d
  804160255d:	0f 85 1b fe ff ff    	jne    804160237e <function_by_info+0x1a4>
  while (entry < entry_end) {
  8041602563:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  8041602567:	77 bc                	ja     8041602525 <function_by_info+0x34b>
  return 0;
  8041602569:	b8 00 00 00 00       	mov    $0x0,%eax
  804160256e:	e9 de fc ff ff       	jmpq   8041602251 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  8041602573:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  804160257a:	00 
  804160257b:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8041602582:	00 
      unsigned name_form        = 0;
  8041602583:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  804160258a:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  8041602591:	00 
  8041602592:	eb 1d                	jmp    80416025b1 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  8041602594:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160259a:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160259f:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416025a3:	44 89 ee             	mov    %r13d,%esi
  80416025a6:	4c 89 f7             	mov    %r14,%rdi
  80416025a9:	41 ff d7             	callq  *%r15
        entry += count;
  80416025ac:	48 98                	cltq   
  80416025ae:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  80416025b1:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025b4:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025be:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416025c4:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025c7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025cb:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025ce:	89 f0                	mov    %esi,%eax
  80416025d0:	83 e0 7f             	and    $0x7f,%eax
  80416025d3:	d3 e0                	shl    %cl,%eax
  80416025d5:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416025d8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025db:	40 84 f6             	test   %sil,%sil
  80416025de:	78 e4                	js     80416025c4 <function_by_info+0x3ea>
  return count;
  80416025e0:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025e3:	48 01 fb             	add    %rdi,%rbx
  80416025e6:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025e9:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025f3:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416025f9:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025fc:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602600:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602603:	89 f0                	mov    %esi,%eax
  8041602605:	83 e0 7f             	and    $0x7f,%eax
  8041602608:	d3 e0                	shl    %cl,%eax
  804160260a:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  804160260d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602610:	40 84 f6             	test   %sil,%sil
  8041602613:	78 e4                	js     80416025f9 <function_by_info+0x41f>
  return count;
  8041602615:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602618:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  804160261b:	41 83 fc 11          	cmp    $0x11,%r12d
  804160261f:	0f 84 6f ff ff ff    	je     8041602594 <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  8041602625:	41 83 fc 12          	cmp    $0x12,%r12d
  8041602629:	0f 84 99 00 00 00    	je     80416026c8 <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  804160262f:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602633:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  8041602636:	41 0f 44 c5          	cmove  %r13d,%eax
  804160263a:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  804160263d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602641:	49 0f 44 c6          	cmove  %r14,%rax
  8041602645:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  8041602649:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160264f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602654:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602659:	44 89 ee             	mov    %r13d,%esi
  804160265c:	4c 89 f7             	mov    %r14,%rdi
  804160265f:	41 ff d7             	callq  *%r15
        entry += count;
  8041602662:	48 98                	cltq   
  8041602664:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602667:	45 09 e5             	or     %r12d,%r13d
  804160266a:	0f 85 41 ff ff ff    	jne    80416025b1 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  8041602670:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602674:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  804160267b:	48 39 d8             	cmp    %rbx,%rax
  804160267e:	0f 87 97 fe ff ff    	ja     804160251b <function_by_info+0x341>
  8041602684:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  8041602688:	0f 82 8d fe ff ff    	jb     804160251b <function_by_info+0x341>
        *offset = low_pc;
  804160268e:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  8041602695:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  8041602698:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  804160269c:	74 59                	je     80416026f7 <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  804160269e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026a4:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  80416026a7:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  80416026ab:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  80416026ae:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  80416026b2:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  80416026b9:	00 00 00 
  80416026bc:	ff d0                	callq  *%rax
        return 0;
  80416026be:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026c3:	e9 89 fb ff ff       	jmpq   8041602251 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  80416026c8:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026ce:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416026d3:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416026d7:	44 89 ee             	mov    %r13d,%esi
  80416026da:	4c 89 f7             	mov    %r14,%rdi
  80416026dd:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  80416026e0:	41 83 fd 01          	cmp    $0x1,%r13d
  80416026e4:	0f 84 c2 fe ff ff    	je     80416025ac <function_by_info+0x3d2>
            high_pc += low_pc;
  80416026ea:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80416026ee:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  80416026f2:	e9 b5 fe ff ff       	jmpq   80416025ac <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  80416026f7:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  80416026fe:	00 
          count                    = dwarf_read_abbrev_entry(
  80416026ff:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602705:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160270a:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160270e:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602713:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602717:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  804160271e:	00 00 00 
  8041602721:	ff d0                	callq  *%rax
          if (buf &&
  8041602723:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  8041602727:	48 85 ff             	test   %rdi,%rdi
  804160272a:	74 92                	je     80416026be <function_by_info+0x4e4>
  804160272c:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  8041602730:	76 8c                	jbe    80416026be <function_by_info+0x4e4>
            put_unaligned(
  8041602732:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602736:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  804160273a:	48 03 43 40          	add    0x40(%rbx),%rax
  804160273e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602742:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602747:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160274b:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041602752:	00 00 00 
  8041602755:	ff d0                	callq  *%rax
  8041602757:	e9 62 ff ff ff       	jmpq   80416026be <function_by_info+0x4e4>
  return 0;
  804160275c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602761:	e9 eb fa ff ff       	jmpq   8041602251 <function_by_info+0x77>

0000008041602766 <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  8041602766:	55                   	push   %rbp
  8041602767:	48 89 e5             	mov    %rsp,%rbp
  804160276a:	41 57                	push   %r15
  804160276c:	41 56                	push   %r14
  804160276e:	41 55                	push   %r13
  8041602770:	41 54                	push   %r12
  8041602772:	53                   	push   %rbx
  8041602773:	48 83 ec 48          	sub    $0x48,%rsp
  8041602777:	49 89 ff             	mov    %rdi,%r15
  804160277a:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  804160277e:	48 89 f7             	mov    %rsi,%rdi
  8041602781:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  8041602785:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const int flen = strlen(fname);
  8041602789:	48 b8 eb c2 60 41 80 	movabs $0x804160c2eb,%rax
  8041602790:	00 00 00 
  8041602793:	ff d0                	callq  *%rax
  8041602795:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  8041602797:	85 c0                	test   %eax,%eax
  8041602799:	74 62                	je     80416027fd <address_by_fname+0x97>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  804160279b:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  804160279f:	49 be 64 c5 60 41 80 	movabs $0x804160c564,%r14
  80416027a6:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  80416027a9:	49 bf fa c3 60 41 80 	movabs $0x804160c3fa,%r15
  80416027b0:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  80416027b3:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416027b7:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  80416027bb:	0f 86 0b 04 00 00    	jbe    8041602bcc <address_by_fname+0x466>
  80416027c1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027c6:	4c 89 e6             	mov    %r12,%rsi
  80416027c9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027cd:	41 ff d6             	callq  *%r14
  80416027d0:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416027d3:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416027d6:	76 52                	jbe    804160282a <address_by_fname+0xc4>
    if (initial_len == DW_EXT_DWARF64) {
  80416027d8:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416027db:	74 31                	je     804160280e <address_by_fname+0xa8>
      cprintf("Unknown DWARF extension\n");
  80416027dd:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  80416027e4:	00 00 00 
  80416027e7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416027ec:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416027f3:	00 00 00 
  80416027f6:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  80416027f8:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  80416027fd:	89 d8                	mov    %ebx,%eax
  80416027ff:	48 83 c4 48          	add    $0x48,%rsp
  8041602803:	5b                   	pop    %rbx
  8041602804:	41 5c                	pop    %r12
  8041602806:	41 5d                	pop    %r13
  8041602808:	41 5e                	pop    %r14
  804160280a:	41 5f                	pop    %r15
  804160280c:	5d                   	pop    %rbp
  804160280d:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160280e:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041602813:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602818:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160281c:	41 ff d6             	callq  *%r14
  804160281f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602823:	ba 0c 00 00 00       	mov    $0xc,%edx
  8041602828:	eb 07                	jmp    8041602831 <address_by_fname+0xcb>
    *len = initial_len;
  804160282a:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160282c:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  8041602831:	48 63 d2             	movslq %edx,%rdx
  8041602834:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  8041602837:	4c 01 e0             	add    %r12,%rax
  804160283a:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  804160283e:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602843:	4c 89 e6             	mov    %r12,%rsi
  8041602846:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160284a:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  804160284d:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  8041602852:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041602857:	0f 85 be 00 00 00    	jne    804160291b <address_by_fname+0x1b5>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160285d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602862:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602866:	41 ff d6             	callq  *%r14
  8041602869:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160286c:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  804160286f:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602874:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602879:	48 89 de             	mov    %rbx,%rsi
  804160287c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602880:	41 ff d6             	callq  *%r14
  8041602883:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  8041602886:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160288b:	83 fa ef             	cmp    $0xffffffef,%edx
  804160288e:	76 29                	jbe    80416028b9 <address_by_fname+0x153>
    if (initial_len == DW_EXT_DWARF64) {
  8041602890:	83 fa ff             	cmp    $0xffffffff,%edx
  8041602893:	0f 84 b7 00 00 00    	je     8041602950 <address_by_fname+0x1ea>
      cprintf("Unknown DWARF extension\n");
  8041602899:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  80416028a0:	00 00 00 
  80416028a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028a8:	48 b9 0d 92 60 41 80 	movabs $0x804160920d,%rcx
  80416028af:	00 00 00 
  80416028b2:	ff d1                	callq  *%rcx
      count = 0;
  80416028b4:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  80416028b9:	48 98                	cltq   
  80416028bb:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416028bf:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416028c3:	0f 86 ea fe ff ff    	jbe    80416027b3 <address_by_fname+0x4d>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028c9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028ce:	4c 89 e6             	mov    %r12,%rsi
  80416028d1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028d5:	41 ff d6             	callq  *%r14
  80416028d8:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416028dc:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416028e0:	4d 85 ed             	test   %r13,%r13
  80416028e3:	0f 84 ca fe ff ff    	je     80416027b3 <address_by_fname+0x4d>
      if (!strcmp(fname, pubnames_entry)) {
  80416028e9:	4c 89 e6             	mov    %r12,%rsi
  80416028ec:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  80416028f0:	41 ff d7             	callq  *%r15
  80416028f3:	89 c3                	mov    %eax,%ebx
  80416028f5:	85 c0                	test   %eax,%eax
  80416028f7:	74 72                	je     804160296b <address_by_fname+0x205>
      pubnames_entry += strlen(pubnames_entry) + 1;
  80416028f9:	4c 89 e7             	mov    %r12,%rdi
  80416028fc:	48 b8 eb c2 60 41 80 	movabs $0x804160c2eb,%rax
  8041602903:	00 00 00 
  8041602906:	ff d0                	callq  *%rax
  8041602908:	83 c0 01             	add    $0x1,%eax
  804160290b:	48 98                	cltq   
  804160290d:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602910:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041602914:	77 b3                	ja     80416028c9 <address_by_fname+0x163>
  8041602916:	e9 98 fe ff ff       	jmpq   80416027b3 <address_by_fname+0x4d>
    assert(version == 2);
  804160291b:	48 b9 3e d0 60 41 80 	movabs $0x804160d03e,%rcx
  8041602922:	00 00 00 
  8041602925:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160292c:	00 00 00 
  804160292f:	be 76 02 00 00       	mov    $0x276,%esi
  8041602934:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  804160293b:	00 00 00 
  804160293e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602943:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160294a:	00 00 00 
  804160294d:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602950:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  8041602955:	ba 08 00 00 00       	mov    $0x8,%edx
  804160295a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160295e:	41 ff d6             	callq  *%r14
      count = 12;
  8041602961:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602966:	e9 4e ff ff ff       	jmpq   80416028b9 <address_by_fname+0x153>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160296b:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  804160296f:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602973:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  8041602977:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  804160297b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602980:	4c 89 e6             	mov    %r12,%rsi
  8041602983:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602987:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160298e:	00 00 00 
  8041602991:	ff d0                	callq  *%rax
  8041602993:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602996:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602999:	0f 86 37 02 00 00    	jbe    8041602bd6 <address_by_fname+0x470>
    if (initial_len == DW_EXT_DWARF64) {
  804160299f:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416029a2:	74 25                	je     80416029c9 <address_by_fname+0x263>
      cprintf("Unknown DWARF extension\n");
  80416029a4:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  80416029ab:	00 00 00 
  80416029ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029b3:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416029ba:	00 00 00 
  80416029bd:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416029bf:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416029c4:	e9 34 fe ff ff       	jmpq   80416027fd <address_by_fname+0x97>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029c9:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416029ce:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029d3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029d7:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416029de:	00 00 00 
  80416029e1:	ff d0                	callq  *%rax
      count = 12;
  80416029e3:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416029e8:	e9 ee 01 00 00       	jmpq   8041602bdb <address_by_fname+0x475>
        assert(version == 4 || version == 2);
  80416029ed:	48 b9 2e d0 60 41 80 	movabs $0x804160d02e,%rcx
  80416029f4:	00 00 00 
  80416029f7:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416029fe:	00 00 00 
  8041602a01:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041602a06:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041602a0d:	00 00 00 
  8041602a10:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a15:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a1c:	00 00 00 
  8041602a1f:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a22:	48 b9 fb cf 60 41 80 	movabs $0x804160cffb,%rcx
  8041602a29:	00 00 00 
  8041602a2c:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041602a33:	00 00 00 
  8041602a36:	be 91 02 00 00       	mov    $0x291,%esi
  8041602a3b:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041602a42:	00 00 00 
  8041602a45:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a4a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a51:	00 00 00 
  8041602a54:	41 ff d0             	callq  *%r8
        if (tag == DW_TAG_subprogram) {
  8041602a57:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602a5b:	0f 84 93 00 00 00    	je     8041602af4 <address_by_fname+0x38e>
  count  = 0;
  8041602a61:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a63:	89 d9                	mov    %ebx,%ecx
  8041602a65:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a68:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602a6e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602a71:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a75:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602a78:	89 f0                	mov    %esi,%eax
  8041602a7a:	83 e0 7f             	and    $0x7f,%eax
  8041602a7d:	d3 e0                	shl    %cl,%eax
  8041602a7f:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602a82:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a85:	40 84 f6             	test   %sil,%sil
  8041602a88:	78 e4                	js     8041602a6e <address_by_fname+0x308>
  return count;
  8041602a8a:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602a8d:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602a90:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a92:	89 d9                	mov    %ebx,%ecx
  8041602a94:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a97:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602a9d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602aa0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602aa4:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602aa7:	89 f0                	mov    %esi,%eax
  8041602aa9:	83 e0 7f             	and    $0x7f,%eax
  8041602aac:	d3 e0                	shl    %cl,%eax
  8041602aae:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602ab1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ab4:	40 84 f6             	test   %sil,%sil
  8041602ab7:	78 e4                	js     8041602a9d <address_by_fname+0x337>
  return count;
  8041602ab9:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602abc:	49 01 fc             	add    %rdi,%r12
            count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602abf:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602ac5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602aca:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602acf:	44 89 ee             	mov    %r13d,%esi
  8041602ad2:	4c 89 ff             	mov    %r15,%rdi
  8041602ad5:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  8041602adc:	00 00 00 
  8041602adf:	ff d0                	callq  *%rax
            entry += count;
  8041602ae1:	48 98                	cltq   
  8041602ae3:	49 01 c7             	add    %rax,%r15
          } while (name != 0 || form != 0);
  8041602ae6:	45 09 f5             	or     %r14d,%r13d
  8041602ae9:	0f 85 72 ff ff ff    	jne    8041602a61 <address_by_fname+0x2fb>
  8041602aef:	e9 09 fd ff ff       	jmpq   80416027fd <address_by_fname+0x97>
          uintptr_t low_pc = 0;
  8041602af4:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602afb:	00 
  8041602afc:	eb 26                	jmp    8041602b24 <address_by_fname+0x3be>
              count = dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  8041602afe:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b04:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602b09:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602b0d:	44 89 f6             	mov    %r14d,%esi
  8041602b10:	4c 89 ff             	mov    %r15,%rdi
  8041602b13:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  8041602b1a:	00 00 00 
  8041602b1d:	ff d0                	callq  *%rax
            entry += count;
  8041602b1f:	48 98                	cltq   
  8041602b21:	49 01 c7             	add    %rax,%r15
  count  = 0;
  8041602b24:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b26:	89 d9                	mov    %ebx,%ecx
  8041602b28:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b2b:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602b31:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b34:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b38:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b3b:	89 f0                	mov    %esi,%eax
  8041602b3d:	83 e0 7f             	and    $0x7f,%eax
  8041602b40:	d3 e0                	shl    %cl,%eax
  8041602b42:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602b45:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b48:	40 84 f6             	test   %sil,%sil
  8041602b4b:	78 e4                	js     8041602b31 <address_by_fname+0x3cb>
  return count;
  8041602b4d:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b50:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602b53:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b55:	89 d9                	mov    %ebx,%ecx
  8041602b57:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b5a:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602b60:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b63:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b67:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b6a:	89 f0                	mov    %esi,%eax
  8041602b6c:	83 e0 7f             	and    $0x7f,%eax
  8041602b6f:	d3 e0                	shl    %cl,%eax
  8041602b71:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602b74:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b77:	40 84 f6             	test   %sil,%sil
  8041602b7a:	78 e4                	js     8041602b60 <address_by_fname+0x3fa>
  return count;
  8041602b7c:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b7f:	49 01 fc             	add    %rdi,%r12
            if (name == DW_AT_low_pc) {
  8041602b82:	41 83 fd 11          	cmp    $0x11,%r13d
  8041602b86:	0f 84 72 ff ff ff    	je     8041602afe <address_by_fname+0x398>
              count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602b8c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602b97:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602b9c:	44 89 f6             	mov    %r14d,%esi
  8041602b9f:	4c 89 ff             	mov    %r15,%rdi
  8041602ba2:	48 b8 3a 0d 60 41 80 	movabs $0x8041600d3a,%rax
  8041602ba9:	00 00 00 
  8041602bac:	ff d0                	callq  *%rax
            entry += count;
  8041602bae:	48 98                	cltq   
  8041602bb0:	49 01 c7             	add    %rax,%r15
          } while (name || form);
  8041602bb3:	45 09 ee             	or     %r13d,%r14d
  8041602bb6:	0f 85 68 ff ff ff    	jne    8041602b24 <address_by_fname+0x3be>
          *offset = low_pc;
  8041602bbc:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041602bc0:	48 8b 7d 98          	mov    -0x68(%rbp),%rdi
  8041602bc4:	48 89 07             	mov    %rax,(%rdi)
  8041602bc7:	e9 31 fc ff ff       	jmpq   80416027fd <address_by_fname+0x97>
  return 0;
  8041602bcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602bd1:	e9 27 fc ff ff       	jmpq   80416027fd <address_by_fname+0x97>
  count       = 4;
  8041602bd6:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  8041602bdb:	48 98                	cltq   
  8041602bdd:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602be1:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602be6:	4c 89 ee             	mov    %r13,%rsi
  8041602be9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bed:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041602bf4:	00 00 00 
  8041602bf7:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602bf9:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  8041602bfd:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602c01:	83 e8 02             	sub    $0x2,%eax
  8041602c04:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602c08:	0f 85 df fd ff ff    	jne    80416029ed <address_by_fname+0x287>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602c0e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602c13:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c17:	49 be 64 c5 60 41 80 	movabs $0x804160c564,%r14
  8041602c1e:	00 00 00 
  8041602c21:	41 ff d6             	callq  *%r14
  8041602c24:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602c28:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c2c:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  8041602c2f:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602c33:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602c38:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c3c:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  8041602c3f:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602c43:	0f 85 d9 fd ff ff    	jne    8041602a22 <address_by_fname+0x2bc>
  count  = 0;
  8041602c49:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602c4b:	89 d9                	mov    %ebx,%ecx
  8041602c4d:	4c 89 fa             	mov    %r15,%rdx
  result = 0;
  8041602c50:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602c56:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602c59:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c5d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602c60:	89 f0                	mov    %esi,%eax
  8041602c62:	83 e0 7f             	and    $0x7f,%eax
  8041602c65:	d3 e0                	shl    %cl,%eax
  8041602c67:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602c6a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c6d:	40 84 f6             	test   %sil,%sil
  8041602c70:	78 e4                	js     8041602c56 <address_by_fname+0x4f0>
  return count;
  8041602c72:	48 63 ff             	movslq %edi,%rdi
        entry += count;
  8041602c75:	49 01 ff             	add    %rdi,%r15
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c78:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c7c:	4c 8b 58 08          	mov    0x8(%rax),%r11
        unsigned name = 0, form = 0, tag = 0;
  8041602c80:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c86:	4d 39 e3             	cmp    %r12,%r11
  8041602c89:	0f 86 c8 fd ff ff    	jbe    8041602a57 <address_by_fname+0x2f1>
  count  = 0;
  8041602c8f:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602c92:	89 d9                	mov    %ebx,%ecx
  8041602c94:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602c97:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602c9c:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602c9f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ca3:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602ca7:	89 f8                	mov    %edi,%eax
  8041602ca9:	83 e0 7f             	and    $0x7f,%eax
  8041602cac:	d3 e0                	shl    %cl,%eax
  8041602cae:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602cb0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cb3:	40 84 ff             	test   %dil,%dil
  8041602cb6:	78 e4                	js     8041602c9c <address_by_fname+0x536>
  return count;
  8041602cb8:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry += count;
  8041602cbb:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602cbe:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602cc1:	89 d9                	mov    %ebx,%ecx
  8041602cc3:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602cc6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602ccc:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602ccf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cd3:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cd7:	89 f8                	mov    %edi,%eax
  8041602cd9:	83 e0 7f             	and    $0x7f,%eax
  8041602cdc:	d3 e0                	shl    %cl,%eax
  8041602cde:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602ce1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ce4:	40 84 ff             	test   %dil,%dil
  8041602ce7:	78 e3                	js     8041602ccc <address_by_fname+0x566>
  return count;
  8041602ce9:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry++;
  8041602cec:	4f 8d 64 04 01       	lea    0x1(%r12,%r8,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602cf1:	41 39 f2             	cmp    %esi,%r10d
  8041602cf4:	0f 84 5d fd ff ff    	je     8041602a57 <address_by_fname+0x2f1>
  count  = 0;
  8041602cfa:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602cfd:	89 d9                	mov    %ebx,%ecx
  8041602cff:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d02:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602d07:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d0a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d0e:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602d12:	89 f0                	mov    %esi,%eax
  8041602d14:	83 e0 7f             	and    $0x7f,%eax
  8041602d17:	d3 e0                	shl    %cl,%eax
  8041602d19:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602d1b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d1e:	40 84 f6             	test   %sil,%sil
  8041602d21:	78 e4                	js     8041602d07 <address_by_fname+0x5a1>
  return count;
  8041602d23:	4d 63 c0             	movslq %r8d,%r8
            abbrev_entry += count;
  8041602d26:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602d29:	41 89 dd             	mov    %ebx,%r13d
  shift  = 0;
  8041602d2c:	89 d9                	mov    %ebx,%ecx
  8041602d2e:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d31:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d37:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d3a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d3e:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041602d42:	89 f0                	mov    %esi,%eax
  8041602d44:	83 e0 7f             	and    $0x7f,%eax
  8041602d47:	d3 e0                	shl    %cl,%eax
  8041602d49:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602d4c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d4f:	40 84 f6             	test   %sil,%sil
  8041602d52:	78 e3                	js     8041602d37 <address_by_fname+0x5d1>
  return count;
  8041602d54:	4d 63 ed             	movslq %r13d,%r13
            abbrev_entry += count;
  8041602d57:	4d 01 ec             	add    %r13,%r12
          } while (name != 0 || form != 0);
  8041602d5a:	41 09 f8             	or     %edi,%r8d
  8041602d5d:	75 9b                	jne    8041602cfa <address_by_fname+0x594>
  8041602d5f:	e9 22 ff ff ff       	jmpq   8041602c86 <address_by_fname+0x520>

0000008041602d64 <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602d64:	55                   	push   %rbp
  8041602d65:	48 89 e5             	mov    %rsp,%rbp
  8041602d68:	41 57                	push   %r15
  8041602d6a:	41 56                	push   %r14
  8041602d6c:	41 55                	push   %r13
  8041602d6e:	41 54                	push   %r12
  8041602d70:	53                   	push   %rbx
  8041602d71:	48 83 ec 48          	sub    $0x48,%rsp
  8041602d75:	48 89 fb             	mov    %rdi,%rbx
  8041602d78:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602d7c:	48 89 f7             	mov    %rsi,%rdi
  8041602d7f:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602d83:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602d87:	48 b8 eb c2 60 41 80 	movabs $0x804160c2eb,%rax
  8041602d8e:	00 00 00 
  8041602d91:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602d93:	85 c0                	test   %eax,%eax
  8041602d95:	0f 84 73 03 00 00    	je     804160310e <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602d9b:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602d9f:	e9 0f 03 00 00       	jmpq   80416030b3 <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602da4:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602da8:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602dad:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602db1:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041602db8:	00 00 00 
  8041602dbb:	ff d0                	callq  *%rax
  8041602dbd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602dc1:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602dc6:	eb 07                	jmp    8041602dcf <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602dc8:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602dca:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602dcf:	48 63 db             	movslq %ebx,%rbx
  8041602dd2:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602dd6:	4c 01 e8             	add    %r13,%rax
  8041602dd9:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602ddd:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602de2:	4c 89 ee             	mov    %r13,%rsi
  8041602de5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602de9:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041602df0:	00 00 00 
  8041602df3:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602df5:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602df9:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602dfd:	83 e8 02             	sub    $0x2,%eax
  8041602e00:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602e04:	75 52                	jne    8041602e58 <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602e06:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602e0b:	4c 89 ee             	mov    %r13,%rsi
  8041602e0e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e12:	49 be 64 c5 60 41 80 	movabs $0x804160c564,%r14
  8041602e19:	00 00 00 
  8041602e1c:	41 ff d6             	callq  *%r14
  8041602e1f:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602e23:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602e28:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602e2c:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602e31:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e35:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602e38:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602e3c:	75 4f                	jne    8041602e8d <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602e3e:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e42:	4c 03 20             	add    (%rax),%r12
  8041602e45:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602e49:	49 be 3a 0d 60 41 80 	movabs $0x8041600d3a,%r14
  8041602e50:	00 00 00 
    while (entry < entry_end) {
  8041602e53:	e9 11 02 00 00       	jmpq   8041603069 <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602e58:	48 b9 2e d0 60 41 80 	movabs $0x804160d02e,%rcx
  8041602e5f:	00 00 00 
  8041602e62:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041602e69:	00 00 00 
  8041602e6c:	be f1 02 00 00       	mov    $0x2f1,%esi
  8041602e71:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041602e78:	00 00 00 
  8041602e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e80:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602e87:	00 00 00 
  8041602e8a:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602e8d:	48 b9 fb cf 60 41 80 	movabs $0x804160cffb,%rcx
  8041602e94:	00 00 00 
  8041602e97:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041602e9e:	00 00 00 
  8041602ea1:	be f5 02 00 00       	mov    $0x2f5,%esi
  8041602ea6:	48 bf ee cf 60 41 80 	movabs $0x804160cfee,%rdi
  8041602ead:	00 00 00 
  8041602eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602eb5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602ebc:	00 00 00 
  8041602ebf:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602ec2:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602ec6:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602eca:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602ece:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602ed4:	49 39 db             	cmp    %rbx,%r11
  8041602ed7:	0f 86 e7 00 00 00    	jbe    8041602fc4 <naive_address_by_fname+0x260>
  8041602edd:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ee0:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602ee6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602eeb:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602ef0:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602ef3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ef7:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602efb:	89 f8                	mov    %edi,%eax
  8041602efd:	83 e0 7f             	and    $0x7f,%eax
  8041602f00:	d3 e0                	shl    %cl,%eax
  8041602f02:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602f04:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f07:	40 84 ff             	test   %dil,%dil
  8041602f0a:	78 e4                	js     8041602ef0 <naive_address_by_fname+0x18c>
  return count;
  8041602f0c:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602f0f:	4c 01 c3             	add    %r8,%rbx
  8041602f12:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f15:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602f1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f20:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602f26:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f29:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f2d:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f31:	89 f8                	mov    %edi,%eax
  8041602f33:	83 e0 7f             	and    $0x7f,%eax
  8041602f36:	d3 e0                	shl    %cl,%eax
  8041602f38:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602f3b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f3e:	40 84 ff             	test   %dil,%dil
  8041602f41:	78 e3                	js     8041602f26 <naive_address_by_fname+0x1c2>
  return count;
  8041602f43:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602f46:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602f4b:	41 39 f2             	cmp    %esi,%r10d
  8041602f4e:	74 74                	je     8041602fc4 <naive_address_by_fname+0x260>
  result = 0;
  8041602f50:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f53:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f58:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f5d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602f63:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f66:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f6a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f6d:	89 f0                	mov    %esi,%eax
  8041602f6f:	83 e0 7f             	and    $0x7f,%eax
  8041602f72:	d3 e0                	shl    %cl,%eax
  8041602f74:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602f77:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f7a:	40 84 f6             	test   %sil,%sil
  8041602f7d:	78 e4                	js     8041602f63 <naive_address_by_fname+0x1ff>
  return count;
  8041602f7f:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f82:	48 01 fb             	add    %rdi,%rbx
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
  8041602fb2:	78 e4                	js     8041602f98 <naive_address_by_fname+0x234>
  return count;
  8041602fb4:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fb7:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  8041602fba:	45 09 c4             	or     %r8d,%r12d
  8041602fbd:	75 91                	jne    8041602f50 <naive_address_by_fname+0x1ec>
  8041602fbf:	e9 10 ff ff ff       	jmpq   8041602ed4 <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602fc4:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602fc8:	0f 84 4f 01 00 00    	je     804160311d <naive_address_by_fname+0x3b9>
  8041602fce:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602fd2:	0f 84 45 01 00 00    	je     804160311d <naive_address_by_fname+0x3b9>
                found = 1;
  8041602fd8:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fdb:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fe0:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fe5:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602feb:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fee:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ff2:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602ff5:	89 f0                	mov    %esi,%eax
  8041602ff7:	83 e0 7f             	and    $0x7f,%eax
  8041602ffa:	d3 e0                	shl    %cl,%eax
  8041602ffc:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602fff:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603002:	40 84 f6             	test   %sil,%sil
  8041603005:	78 e4                	js     8041602feb <naive_address_by_fname+0x287>
  return count;
  8041603007:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  804160300a:	48 01 fb             	add    %rdi,%rbx
  804160300d:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603010:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603015:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160301a:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603020:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603023:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603027:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160302a:	89 f0                	mov    %esi,%eax
  804160302c:	83 e0 7f             	and    $0x7f,%eax
  804160302f:	d3 e0                	shl    %cl,%eax
  8041603031:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041603034:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603037:	40 84 f6             	test   %sil,%sil
  804160303a:	78 e4                	js     8041603020 <naive_address_by_fname+0x2bc>
  return count;
  804160303c:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  804160303f:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041603042:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603048:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160304d:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603052:	44 89 e6             	mov    %r12d,%esi
  8041603055:	4c 89 ff             	mov    %r15,%rdi
  8041603058:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  804160305b:	48 98                	cltq   
  804160305d:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603060:	45 09 ec             	or     %r13d,%r12d
  8041603063:	0f 85 6f ff ff ff    	jne    8041602fd8 <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  8041603069:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  804160306d:	73 44                	jae    80416030b3 <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  804160306f:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  8041603072:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603077:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160307c:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041603082:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603085:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603089:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160308c:	89 f0                	mov    %esi,%eax
  804160308e:	83 e0 7f             	and    $0x7f,%eax
  8041603091:	d3 e0                	shl    %cl,%eax
  8041603093:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041603096:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603099:	40 84 f6             	test   %sil,%sil
  804160309c:	78 e4                	js     8041603082 <naive_address_by_fname+0x31e>
  return count;
  804160309e:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  80416030a1:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  80416030a4:	45 85 d2             	test   %r10d,%r10d
  80416030a7:	0f 85 15 fe ff ff    	jne    8041602ec2 <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  80416030ad:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  80416030b1:	77 bc                	ja     804160306f <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  80416030b3:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416030b7:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  80416030bb:	0f 86 ee 01 00 00    	jbe    80416032af <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  80416030c1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030c6:	4c 89 fe             	mov    %r15,%rsi
  80416030c9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030cd:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416030d4:	00 00 00 
  80416030d7:	ff d0                	callq  *%rax
  80416030d9:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416030dc:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416030df:	0f 86 e3 fc ff ff    	jbe    8041602dc8 <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  80416030e5:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416030e8:	0f 84 b6 fc ff ff    	je     8041602da4 <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  80416030ee:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  80416030f5:	00 00 00 
  80416030f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416030fd:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041603104:	00 00 00 
  8041603107:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041603109:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  804160310e:	48 83 c4 48          	add    $0x48,%rsp
  8041603112:	5b                   	pop    %rbx
  8041603113:	41 5c                	pop    %r12
  8041603115:	41 5d                	pop    %r13
  8041603117:	41 5e                	pop    %r14
  8041603119:	41 5f                	pop    %r15
  804160311b:	5d                   	pop    %rbp
  804160311c:	c3                   	retq   
        uintptr_t low_pc = 0;
  804160311d:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041603124:	00 
        int found        = 0;
  8041603125:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  804160312c:	eb 21                	jmp    804160314f <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  804160312e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603134:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603139:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160313d:	44 89 ee             	mov    %r13d,%esi
  8041603140:	4c 89 ff             	mov    %r15,%rdi
  8041603143:	41 ff d6             	callq  *%r14
  8041603146:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  8041603149:	49 63 c4             	movslq %r12d,%rax
  804160314c:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  804160314f:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603152:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603157:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160315c:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603162:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603165:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603169:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160316c:	89 f0                	mov    %esi,%eax
  804160316e:	83 e0 7f             	and    $0x7f,%eax
  8041603171:	d3 e0                	shl    %cl,%eax
  8041603173:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041603176:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603179:	40 84 f6             	test   %sil,%sil
  804160317c:	78 e4                	js     8041603162 <naive_address_by_fname+0x3fe>
  return count;
  804160317e:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041603181:	48 01 fb             	add    %rdi,%rbx
  8041603184:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603187:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160318c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603191:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041603197:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160319a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160319e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416031a1:	89 f0                	mov    %esi,%eax
  80416031a3:	83 e0 7f             	and    $0x7f,%eax
  80416031a6:	d3 e0                	shl    %cl,%eax
  80416031a8:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416031ab:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416031ae:	40 84 f6             	test   %sil,%sil
  80416031b1:	78 e4                	js     8041603197 <naive_address_by_fname+0x433>
  return count;
  80416031b3:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  80416031b6:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  80416031b9:	41 83 fc 11          	cmp    $0x11,%r12d
  80416031bd:	0f 84 6b ff ff ff    	je     804160312e <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  80416031c3:	41 83 fc 03          	cmp    $0x3,%r12d
  80416031c7:	0f 85 9c 00 00 00    	jne    8041603269 <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  80416031cd:	41 83 fd 0e          	cmp    $0xe,%r13d
  80416031d1:	74 42                	je     8041603215 <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  80416031d3:	4c 89 fe             	mov    %r15,%rsi
  80416031d6:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416031da:	48 b8 fa c3 60 41 80 	movabs $0x804160c3fa,%rax
  80416031e1:	00 00 00 
  80416031e4:	ff d0                	callq  *%rax
                found = 1;
  80416031e6:	85 c0                	test   %eax,%eax
  80416031e8:	b8 01 00 00 00       	mov    $0x1,%eax
  80416031ed:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  80416031f1:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  80416031f4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416031fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416031ff:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603204:	44 89 ee             	mov    %r13d,%esi
  8041603207:	4c 89 ff             	mov    %r15,%rdi
  804160320a:	41 ff d6             	callq  *%r14
  804160320d:	41 89 c4             	mov    %eax,%r12d
  8041603210:	e9 34 ff ff ff       	jmpq   8041603149 <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  8041603215:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160321c:	00 
              count          = dwarf_read_abbrev_entry(
  804160321d:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603223:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603228:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160322c:	be 0e 00 00 00       	mov    $0xe,%esi
  8041603231:	4c 89 ff             	mov    %r15,%rdi
  8041603234:	41 ff d6             	callq  *%r14
  8041603237:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  804160323a:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160323e:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603242:	48 03 70 40          	add    0x40(%rax),%rsi
  8041603246:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  804160324a:	48 b8 fa c3 60 41 80 	movabs $0x804160c3fa,%rax
  8041603251:	00 00 00 
  8041603254:	ff d0                	callq  *%rax
                found = 1;
  8041603256:	85 c0                	test   %eax,%eax
  8041603258:	b8 01 00 00 00       	mov    $0x1,%eax
  804160325d:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603261:	89 45 bc             	mov    %eax,-0x44(%rbp)
  8041603264:	e9 e0 fe ff ff       	jmpq   8041603149 <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  8041603269:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160326f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603274:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603279:	44 89 ee             	mov    %r13d,%esi
  804160327c:	4c 89 ff             	mov    %r15,%rdi
  804160327f:	41 ff d6             	callq  *%r14
          entry += count;
  8041603282:	48 98                	cltq   
  8041603284:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603287:	45 09 e5             	or     %r12d,%r13d
  804160328a:	0f 85 bf fe ff ff    	jne    804160314f <naive_address_by_fname+0x3eb>
        if (found) {
  8041603290:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  8041603294:	0f 84 cf fd ff ff    	je     8041603069 <naive_address_by_fname+0x305>
          *offset = low_pc;
  804160329a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160329e:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  80416032a2:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  80416032a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032aa:	e9 5f fe ff ff       	jmpq   804160310e <naive_address_by_fname+0x3aa>
  return 0;
  80416032af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032b4:	e9 55 fe ff ff       	jmpq   804160310e <naive_address_by_fname+0x3aa>

00000080416032b9 <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  80416032b9:	55                   	push   %rbp
  80416032ba:	48 89 e5             	mov    %rsp,%rbp
  80416032bd:	41 57                	push   %r15
  80416032bf:	41 56                	push   %r14
  80416032c1:	41 55                	push   %r13
  80416032c3:	41 54                	push   %r12
  80416032c5:	53                   	push   %rbx
  80416032c6:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  80416032ca:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  80416032ce:	48 8b 47 38          	mov    0x38(%rdi),%rax
  80416032d2:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  80416032d5:	48 39 d0             	cmp    %rdx,%rax
  80416032d8:	0f 82 d9 06 00 00    	jb     80416039b7 <line_for_address+0x6fe>
  80416032de:	48 85 c9             	test   %rcx,%rcx
  80416032e1:	0f 84 d0 06 00 00    	je     80416039b7 <line_for_address+0x6fe>
  80416032e7:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  80416032eb:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  80416032ef:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  80416032f2:	ba 04 00 00 00       	mov    $0x4,%edx
  80416032f7:	48 89 de             	mov    %rbx,%rsi
  80416032fa:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416032fe:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041603305:	00 00 00 
  8041603308:	ff d0                	callq  *%rax
  804160330a:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160330d:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041603310:	76 4e                	jbe    8041603360 <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  8041603312:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041603315:	74 25                	je     804160333c <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  8041603317:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  804160331e:	00 00 00 
  8041603321:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603326:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160332d:	00 00 00 
  8041603330:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041603332:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041603337:	e9 6c 06 00 00       	jmpq   80416039a8 <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160333c:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041603340:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603345:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603349:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041603350:	00 00 00 
  8041603353:	ff d0                	callq  *%rax
  8041603355:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041603359:	be 0c 00 00 00       	mov    $0xc,%esi
  804160335e:	eb 07                	jmp    8041603367 <line_for_address+0xae>
    *len = initial_len;
  8041603360:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041603362:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  8041603367:	48 63 f6             	movslq %esi,%rsi
  804160336a:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  804160336d:	48 01 d8             	add    %rbx,%rax
  8041603370:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  8041603374:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603379:	48 89 de             	mov    %rbx,%rsi
  804160337c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603380:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041603387:	00 00 00 
  804160338a:	ff d0                	callq  *%rax
  804160338c:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  8041603391:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  8041603395:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  8041603399:	66 83 f8 02          	cmp    $0x2,%ax
  804160339d:	77 51                	ja     80416033f0 <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  804160339f:	ba 04 00 00 00       	mov    $0x4,%edx
  80416033a4:	4c 89 e6             	mov    %r12,%rsi
  80416033a7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416033ab:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416033b2:	00 00 00 
  80416033b5:	ff d0                	callq  *%rax
  80416033b7:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416033bb:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  80416033bf:	0f 86 84 00 00 00    	jbe    8041603449 <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  80416033c5:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  80416033c9:	74 5a                	je     8041603425 <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  80416033cb:	48 bf c0 cf 60 41 80 	movabs $0x804160cfc0,%rdi
  80416033d2:	00 00 00 
  80416033d5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033da:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416033e1:	00 00 00 
  80416033e4:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416033e6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416033eb:	e9 b8 05 00 00       	jmpq   80416039a8 <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  80416033f0:	48 b9 e8 d1 60 41 80 	movabs $0x804160d1e8,%rcx
  80416033f7:	00 00 00 
  80416033fa:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041603401:	00 00 00 
  8041603404:	be fc 00 00 00       	mov    $0xfc,%esi
  8041603409:	48 bf a1 d1 60 41 80 	movabs $0x804160d1a1,%rdi
  8041603410:	00 00 00 
  8041603413:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603418:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160341f:	00 00 00 
  8041603422:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603425:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  8041603429:	ba 08 00 00 00       	mov    $0x8,%edx
  804160342e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603432:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041603439:	00 00 00 
  804160343c:	ff d0                	callq  *%rax
  804160343e:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  8041603442:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041603447:	eb 08                	jmp    8041603451 <line_for_address+0x198>
    *len = initial_len;
  8041603449:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  804160344c:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  8041603451:	48 98                	cltq   
  8041603453:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  8041603456:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  8041603459:	ba 01 00 00 00       	mov    $0x1,%edx
  804160345e:	4c 89 e6             	mov    %r12,%rsi
  8041603461:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603465:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160346c:	00 00 00 
  804160346f:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  8041603471:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  8041603475:	0f 85 89 00 00 00    	jne    8041603504 <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  804160347b:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  8041603480:	66 41 83 ff 04       	cmp    $0x4,%r15w
  8041603485:	0f 84 ae 00 00 00    	je     8041603539 <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  804160348b:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  804160348f:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603494:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603498:	49 bc 64 c5 60 41 80 	movabs $0x804160c564,%r12
  804160349f:	00 00 00 
  80416034a2:	41 ff d4             	callq  *%r12
  80416034a5:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034a9:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  80416034ac:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  80416034b0:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034b5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034b9:	41 ff d4             	callq  *%r12
  80416034bc:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034c0:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034c3:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  80416034c7:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034cc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034d0:	41 ff d4             	callq  *%r12
  80416034d3:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034d7:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034da:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  80416034de:	ba 08 00 00 00       	mov    $0x8,%edx
  80416034e3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034e7:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  80416034ea:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  80416034ee:	0f 86 90 04 00 00    	jbe    8041603984 <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  80416034f4:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  80416034fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416034ff:	e9 32 04 00 00       	jmpq   8041603936 <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  8041603504:	48 b9 18 d2 60 41 80 	movabs $0x804160d218,%rcx
  804160350b:	00 00 00 
  804160350e:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041603515:	00 00 00 
  8041603518:	be 07 01 00 00       	mov    $0x107,%esi
  804160351d:	48 bf a1 d1 60 41 80 	movabs $0x804160d1a1,%rdi
  8041603524:	00 00 00 
  8041603527:	b8 00 00 00 00       	mov    $0x0,%eax
  804160352c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603533:	00 00 00 
  8041603536:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  8041603539:	ba 01 00 00 00       	mov    $0x1,%edx
  804160353e:	48 89 de             	mov    %rbx,%rsi
  8041603541:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603545:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160354c:	00 00 00 
  804160354f:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  8041603551:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  8041603556:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160355a:	0f 84 2b ff ff ff    	je     804160348b <line_for_address+0x1d2>
  8041603560:	48 b9 38 d2 60 41 80 	movabs $0x804160d238,%rcx
  8041603567:	00 00 00 
  804160356a:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041603571:	00 00 00 
  8041603574:	be 11 01 00 00       	mov    $0x111,%esi
  8041603579:	48 bf a1 d1 60 41 80 	movabs $0x804160d1a1,%rdi
  8041603580:	00 00 00 
  8041603583:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603588:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160358f:	00 00 00 
  8041603592:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  8041603595:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  8041603598:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  804160359e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416035a3:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  80416035a9:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  80416035ac:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416035b0:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  80416035b4:	89 fa                	mov    %edi,%edx
  80416035b6:	83 e2 7f             	and    $0x7f,%edx
  80416035b9:	d3 e2                	shl    %cl,%edx
  80416035bb:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  80416035be:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416035c1:	40 84 ff             	test   %dil,%dil
  80416035c4:	78 e3                	js     80416035a9 <line_for_address+0x2f0>
  return count;
  80416035c6:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  80416035c9:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  80416035cc:	45 89 ff             	mov    %r15d,%r15d
  80416035cf:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  80416035d2:	ba 01 00 00 00       	mov    $0x1,%edx
  80416035d7:	4c 89 ee             	mov    %r13,%rsi
  80416035da:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416035de:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416035e5:	00 00 00 
  80416035e8:	ff d0                	callq  *%rax
  80416035ea:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  80416035ee:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  80416035f2:	3c 02                	cmp    $0x2,%al
  80416035f4:	0f 84 dc 00 00 00    	je     80416036d6 <line_for_address+0x41d>
  80416035fa:	76 39                	jbe    8041603635 <line_for_address+0x37c>
  80416035fc:	3c 03                	cmp    $0x3,%al
  80416035fe:	74 62                	je     8041603662 <line_for_address+0x3a9>
  8041603600:	3c 04                	cmp    $0x4,%al
  8041603602:	0f 85 0c 01 00 00    	jne    8041603714 <line_for_address+0x45b>
  8041603608:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160360b:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603610:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603613:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603617:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160361a:	84 c9                	test   %cl,%cl
  804160361c:	78 f2                	js     8041603610 <line_for_address+0x357>
  return count;
  804160361e:	48 98                	cltq   
          program_addr += count;
  8041603620:	48 01 c6             	add    %rax,%rsi
  8041603623:	44 89 e2             	mov    %r12d,%edx
  8041603626:	48 89 d8             	mov    %rbx,%rax
  8041603629:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160362d:	4c 89 f3             	mov    %r14,%rbx
  8041603630:	e9 c8 00 00 00       	jmpq   80416036fd <line_for_address+0x444>
      switch (opcode) {
  8041603635:	3c 01                	cmp    $0x1,%al
  8041603637:	0f 85 d7 00 00 00    	jne    8041603714 <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  804160363d:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603641:	49 39 c6             	cmp    %rax,%r14
  8041603644:	0f 87 f8 00 00 00    	ja     8041603742 <line_for_address+0x489>
  804160364a:	48 39 d8             	cmp    %rbx,%rax
  804160364d:	0f 82 39 03 00 00    	jb     804160398c <line_for_address+0x6d3>
          state->line          = 1;
  8041603653:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  8041603658:	b8 00 00 00 00       	mov    $0x0,%eax
  804160365d:	e9 9b 00 00 00       	jmpq   80416036fd <line_for_address+0x444>
          while (*(char *)program_addr) {
  8041603662:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  8041603667:	74 09                	je     8041603672 <line_for_address+0x3b9>
            ++program_addr;
  8041603669:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  804160366d:	80 3e 00             	cmpb   $0x0,(%rsi)
  8041603670:	75 f7                	jne    8041603669 <line_for_address+0x3b0>
          ++program_addr;
  8041603672:	48 83 c6 01          	add    $0x1,%rsi
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
  804160368a:	78 f2                	js     804160367e <line_for_address+0x3c5>
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
  80416036a5:	78 f2                	js     8041603699 <line_for_address+0x3e0>
  return count;
  80416036a7:	48 98                	cltq   
          program_addr += count;
  80416036a9:	48 01 c6             	add    %rax,%rsi
  80416036ac:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416036af:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036b4:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036b7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036bb:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036be:	84 c9                	test   %cl,%cl
  80416036c0:	78 f2                	js     80416036b4 <line_for_address+0x3fb>
  return count;
  80416036c2:	48 98                	cltq   
          program_addr += count;
  80416036c4:	48 01 c6             	add    %rax,%rsi
  80416036c7:	44 89 e2             	mov    %r12d,%edx
  80416036ca:	48 89 d8             	mov    %rbx,%rax
  80416036cd:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036d1:	4c 89 f3             	mov    %r14,%rbx
  80416036d4:	eb 27                	jmp    80416036fd <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  80416036d6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416036db:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416036df:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416036e6:	00 00 00 
  80416036e9:	ff d0                	callq  *%rax
  80416036eb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  80416036ef:	49 8d 75 09          	lea    0x9(%r13),%rsi
  80416036f3:	44 89 e2             	mov    %r12d,%edx
  80416036f6:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036fa:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  80416036fd:	49 39 f7             	cmp    %rsi,%r15
  8041603700:	75 4c                	jne    804160374e <line_for_address+0x495>
  8041603702:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603706:	41 89 d4             	mov    %edx,%r12d
  8041603709:	49 89 de             	mov    %rbx,%r14
  804160370c:	48 89 c3             	mov    %rax,%rbx
  804160370f:	e9 19 02 00 00       	jmpq   804160392d <line_for_address+0x674>
      switch (opcode) {
  8041603714:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603717:	48 ba b4 d1 60 41 80 	movabs $0x804160d1b4,%rdx
  804160371e:	00 00 00 
  8041603721:	be 6b 00 00 00       	mov    $0x6b,%esi
  8041603726:	48 bf a1 d1 60 41 80 	movabs $0x804160d1a1,%rdi
  804160372d:	00 00 00 
  8041603730:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603735:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160373c:	00 00 00 
  804160373f:	41 ff d0             	callq  *%r8
          state->line          = 1;
  8041603742:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  8041603747:	b8 00 00 00 00       	mov    $0x0,%eax
  804160374c:	eb af                	jmp    80416036fd <line_for_address+0x444>
      assert(program_addr == opcode_end);
  804160374e:	48 b9 c7 d1 60 41 80 	movabs $0x804160d1c7,%rcx
  8041603755:	00 00 00 
  8041603758:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160375f:	00 00 00 
  8041603762:	be 6e 00 00 00       	mov    $0x6e,%esi
  8041603767:	48 bf a1 d1 60 41 80 	movabs $0x804160d1a1,%rdi
  804160376e:	00 00 00 
  8041603771:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603776:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160377d:	00 00 00 
  8041603780:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  8041603783:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603787:	49 39 c6             	cmp    %rax,%r14
  804160378a:	0f 87 eb 01 00 00    	ja     804160397b <line_for_address+0x6c2>
  8041603790:	48 39 d8             	cmp    %rbx,%rax
  8041603793:	0f 82 f9 01 00 00    	jb     8041603992 <line_for_address+0x6d9>
          last_state           = *state;
  8041603799:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160379d:	49 89 de             	mov    %rbx,%r14
  80416037a0:	e9 88 01 00 00       	jmpq   804160392d <line_for_address+0x674>
      switch (opcode) {
  80416037a5:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037a8:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416037ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037b2:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416037b7:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037bb:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  80416037bf:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416037c2:	45 89 c8             	mov    %r9d,%r8d
  80416037c5:	41 83 e0 7f          	and    $0x7f,%r8d
  80416037c9:	41 d3 e0             	shl    %cl,%r8d
  80416037cc:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  80416037cf:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416037d2:	45 84 c9             	test   %r9b,%r9b
  80416037d5:	78 e0                	js     80416037b7 <line_for_address+0x4fe>
              info->minimum_instruction_length *
  80416037d7:	89 d2                	mov    %edx,%edx
          state->address +=
  80416037d9:	48 01 d3             	add    %rdx,%rbx
  return count;
  80416037dc:	48 98                	cltq   
          program_addr += count;
  80416037de:	48 01 c6             	add    %rax,%rsi
        } break;
  80416037e1:	e9 47 01 00 00       	jmpq   804160392d <line_for_address+0x674>
      switch (opcode) {
  80416037e6:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037e9:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416037ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037f3:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416037f8:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037fc:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  8041603800:	45 89 c8             	mov    %r9d,%r8d
  8041603803:	41 83 e0 7f          	and    $0x7f,%r8d
  8041603807:	41 d3 e0             	shl    %cl,%r8d
  804160380a:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  804160380d:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041603810:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603813:	45 84 c9             	test   %r9b,%r9b
  8041603816:	78 e0                	js     80416037f8 <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  8041603818:	83 f9 1f             	cmp    $0x1f,%ecx
  804160381b:	7f 0f                	jg     804160382c <line_for_address+0x573>
  804160381d:	41 f6 c1 40          	test   $0x40,%r9b
  8041603821:	74 09                	je     804160382c <line_for_address+0x573>
    result |= (-1U << shift);
  8041603823:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8041603828:	d3 e7                	shl    %cl,%edi
  804160382a:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  804160382c:	41 01 d4             	add    %edx,%r12d
  return count;
  804160382f:	48 98                	cltq   
          program_addr += count;
  8041603831:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603834:	e9 f4 00 00 00       	jmpq   804160392d <line_for_address+0x674>
      switch (opcode) {
  8041603839:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160383c:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603841:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603844:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603848:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160384b:	84 c9                	test   %cl,%cl
  804160384d:	78 f2                	js     8041603841 <line_for_address+0x588>
  return count;
  804160384f:	48 98                	cltq   
          program_addr += count;
  8041603851:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603854:	e9 d4 00 00 00       	jmpq   804160392d <line_for_address+0x674>
      switch (opcode) {
  8041603859:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160385c:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603861:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603864:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603868:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160386b:	84 c9                	test   %cl,%cl
  804160386d:	78 f2                	js     8041603861 <line_for_address+0x5a8>
  return count;
  804160386f:	48 98                	cltq   
          program_addr += count;
  8041603871:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603874:	e9 b4 00 00 00       	jmpq   804160392d <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  8041603879:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  804160387d:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  804160387f:	0f b6 c0             	movzbl %al,%eax
  8041603882:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  8041603885:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  8041603888:	48 01 c3             	add    %rax,%rbx
        } break;
  804160388b:	e9 9d 00 00 00       	jmpq   804160392d <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  8041603890:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603895:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603899:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  80416038a0:	00 00 00 
  80416038a3:	ff d0                	callq  *%rax
          state->address += pc_inc;
  80416038a5:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416038a9:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  80416038ac:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  80416038b0:	eb 7b                	jmp    804160392d <line_for_address+0x674>
      switch (opcode) {
  80416038b2:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416038b5:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416038ba:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416038bd:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416038c1:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416038c4:	84 c9                	test   %cl,%cl
  80416038c6:	78 f2                	js     80416038ba <line_for_address+0x601>
  return count;
  80416038c8:	48 98                	cltq   
          program_addr += count;
  80416038ca:	48 01 c6             	add    %rax,%rsi
        } break;
  80416038cd:	eb 5e                	jmp    804160392d <line_for_address+0x674>
      switch (opcode) {
  80416038cf:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  80416038d2:	48 ba b4 d1 60 41 80 	movabs $0x804160d1b4,%rdx
  80416038d9:	00 00 00 
  80416038dc:	be c1 00 00 00       	mov    $0xc1,%esi
  80416038e1:	48 bf a1 d1 60 41 80 	movabs $0x804160d1a1,%rdi
  80416038e8:	00 00 00 
  80416038eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038f0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416038f7:	00 00 00 
  80416038fa:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  80416038fd:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  8041603900:	0f b6 c0             	movzbl %al,%eax
  8041603903:	f6 75 ba             	divb   -0x46(%rbp)
  8041603906:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  8041603909:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  804160390d:	01 ca                	add    %ecx,%edx
  804160390f:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  8041603912:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  8041603915:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  8041603918:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160391c:	49 39 c6             	cmp    %rax,%r14
  804160391f:	77 05                	ja     8041603926 <line_for_address+0x66d>
  8041603921:	48 39 d8             	cmp    %rbx,%rax
  8041603924:	72 72                	jb     8041603998 <line_for_address+0x6df>
      last_state = *state;
  8041603926:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160392a:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  804160392d:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  8041603931:	76 69                	jbe    804160399c <line_for_address+0x6e3>
  8041603933:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  8041603936:	ba 01 00 00 00       	mov    $0x1,%edx
  804160393b:	4c 89 ee             	mov    %r13,%rsi
  804160393e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603942:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  8041603949:	00 00 00 
  804160394c:	ff d0                	callq  *%rax
  804160394e:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  8041603952:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  8041603956:	84 c0                	test   %al,%al
  8041603958:	0f 84 37 fc ff ff    	je     8041603595 <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  804160395e:	38 45 bb             	cmp    %al,-0x45(%rbp)
  8041603961:	76 9a                	jbe    80416038fd <line_for_address+0x644>
      switch (opcode) {
  8041603963:	3c 0c                	cmp    $0xc,%al
  8041603965:	0f 87 64 ff ff ff    	ja     80416038cf <line_for_address+0x616>
  804160396b:	0f b6 d0             	movzbl %al,%edx
  804160396e:	48 bf 60 d2 60 41 80 	movabs $0x804160d260,%rdi
  8041603975:	00 00 00 
  8041603978:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  804160397b:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160397f:	49 89 de             	mov    %rbx,%r14
  8041603982:	eb a9                	jmp    804160392d <line_for_address+0x674>
  struct Line_Number_State current_state = {
  8041603984:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  804160398a:	eb 10                	jmp    804160399c <line_for_address+0x6e3>
            *state = last_state;
  804160398c:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603990:	eb 0a                	jmp    804160399c <line_for_address+0x6e3>
            *state = last_state;
  8041603992:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603996:	eb 04                	jmp    804160399c <line_for_address+0x6e3>
        *state = last_state;
  8041603998:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  804160399c:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80416039a0:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  80416039a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416039a8:	48 83 c4 38          	add    $0x38,%rsp
  80416039ac:	5b                   	pop    %rbx
  80416039ad:	41 5c                	pop    %r12
  80416039af:	41 5d                	pop    %r13
  80416039b1:	41 5e                	pop    %r14
  80416039b3:	41 5f                	pop    %r15
  80416039b5:	5d                   	pop    %rbp
  80416039b6:	c3                   	retq   
    return -E_INVAL;
  80416039b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416039bc:	eb ea                	jmp    80416039a8 <line_for_address+0x6ef>

00000080416039be <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  80416039be:	55                   	push   %rbp
  80416039bf:	48 89 e5             	mov    %rsp,%rbp
  80416039c2:	41 55                	push   %r13
  80416039c4:	41 54                	push   %r12
  80416039c6:	53                   	push   %rbx
  80416039c7:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  80416039cb:	48 bb 00 d6 60 41 80 	movabs $0x804160d600,%rbx
  80416039d2:	00 00 00 
  80416039d5:	4c 8d ab c0 00 00 00 	lea    0xc0(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  80416039dc:	49 bc 0d 92 60 41 80 	movabs $0x804160920d,%r12
  80416039e3:	00 00 00 
  80416039e6:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  80416039ea:	48 8b 33             	mov    (%rbx),%rsi
  80416039ed:	48 bf c8 d2 60 41 80 	movabs $0x804160d2c8,%rdi
  80416039f4:	00 00 00 
  80416039f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039fc:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  80416039ff:	48 83 c3 18          	add    $0x18,%rbx
  8041603a03:	4c 39 eb             	cmp    %r13,%rbx
  8041603a06:	75 de                	jne    80416039e6 <mon_help+0x28>
  return 0;
}
  8041603a08:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a0d:	48 83 c4 08          	add    $0x8,%rsp
  8041603a11:	5b                   	pop    %rbx
  8041603a12:	41 5c                	pop    %r12
  8041603a14:	41 5d                	pop    %r13
  8041603a16:	5d                   	pop    %rbp
  8041603a17:	c3                   	retq   

0000008041603a18 <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  8041603a18:	55                   	push   %rbp
  8041603a19:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603a1c:	48 bf d1 d2 60 41 80 	movabs $0x804160d2d1,%rdi
  8041603a23:	00 00 00 
  8041603a26:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a2b:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041603a32:	00 00 00 
  8041603a35:	ff d2                	callq  *%rdx
  return 0;
}
  8041603a37:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a3c:	5d                   	pop    %rbp
  8041603a3d:	c3                   	retq   

0000008041603a3e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  8041603a3e:	55                   	push   %rbp
  8041603a3f:	48 89 e5             	mov    %rsp,%rbp
  8041603a42:	41 55                	push   %r13
  8041603a44:	41 54                	push   %r12
  8041603a46:	53                   	push   %rbx
  8041603a47:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  8041603a4b:	48 bf d9 d2 60 41 80 	movabs $0x804160d2d9,%rdi
  8041603a52:	00 00 00 
  8041603a55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a5a:	49 bc 0d 92 60 41 80 	movabs $0x804160920d,%r12
  8041603a61:	00 00 00 
  8041603a64:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  8041603a67:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  8041603a6e:	00 00 00 
  8041603a71:	48 bf 48 d4 60 41 80 	movabs $0x804160d448,%rdi
  8041603a78:	00 00 00 
  8041603a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a80:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  8041603a83:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  8041603a8a:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  8041603a8d:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  8041603a94:	00 00 00 
  8041603a97:	4c 89 ee             	mov    %r13,%rsi
  8041603a9a:	48 bf 78 d4 60 41 80 	movabs $0x804160d478,%rdi
  8041603aa1:	00 00 00 
  8041603aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603aa9:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603aac:	48 ba 98 cc 60 01 00 	movabs $0x160cc98,%rdx
  8041603ab3:	00 00 00 
  8041603ab6:	48 be 98 cc 60 41 80 	movabs $0x804160cc98,%rsi
  8041603abd:	00 00 00 
  8041603ac0:	48 bf a0 d4 60 41 80 	movabs $0x804160d4a0,%rdi
  8041603ac7:	00 00 00 
  8041603aca:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603acf:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603ad2:	48 ba 78 42 88 01 00 	movabs $0x1884278,%rdx
  8041603ad9:	00 00 00 
  8041603adc:	48 be 78 42 88 41 80 	movabs $0x8041884278,%rsi
  8041603ae3:	00 00 00 
  8041603ae6:	48 bf c8 d4 60 41 80 	movabs $0x804160d4c8,%rdi
  8041603aed:	00 00 00 
  8041603af0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603af5:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  8041603af8:	48 bb 00 60 88 41 80 	movabs $0x8041886000,%rbx
  8041603aff:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603b02:	48 ba 00 60 88 01 00 	movabs $0x1886000,%rdx
  8041603b09:	00 00 00 
  8041603b0c:	48 89 de             	mov    %rbx,%rsi
  8041603b0f:	48 bf f0 d4 60 41 80 	movabs $0x804160d4f0,%rdi
  8041603b16:	00 00 00 
  8041603b19:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b1e:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603b21:	4c 29 eb             	sub    %r13,%rbx
  8041603b24:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603b2b:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603b2f:	48 bf 18 d5 60 41 80 	movabs $0x804160d518,%rdi
  8041603b36:	00 00 00 
  8041603b39:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b3e:	41 ff d4             	callq  *%r12
  return 0;
}
  8041603b41:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b46:	48 83 c4 08          	add    $0x8,%rsp
  8041603b4a:	5b                   	pop    %rbx
  8041603b4b:	41 5c                	pop    %r12
  8041603b4d:	41 5d                	pop    %r13
  8041603b4f:	5d                   	pop    %rbp
  8041603b50:	c3                   	retq   

0000008041603b51 <mon_backtrace>:
// }
// LAB 2 code end
// DELETED in LAB 5 end

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  8041603b51:	55                   	push   %rbp
  8041603b52:	48 89 e5             	mov    %rsp,%rbp
  8041603b55:	41 57                	push   %r15
  8041603b57:	41 56                	push   %r14
  8041603b59:	41 55                	push   %r13
  8041603b5b:	41 54                	push   %r12
  8041603b5d:	53                   	push   %rbx
  8041603b5e:	48 81 ec 38 02 00 00 	sub    $0x238,%rsp
  // LAB 2 code
  
  cprintf("Stack backtrace:\n");
  8041603b65:	48 bf f2 d2 60 41 80 	movabs $0x804160d2f2,%rdi
  8041603b6c:	00 00 00 
  8041603b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b74:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041603b7b:	00 00 00 
  8041603b7e:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603b80:	48 89 e8             	mov    %rbp,%rax
  uint64_t buf;
  int digits_16;
  int code;
  struct Ripdebuginfo info;
    
  while (rbp != 0) {
  8041603b83:	48 85 c0             	test   %rax,%rax
  8041603b86:	0f 84 c5 01 00 00    	je     8041603d51 <mon_backtrace+0x200>
  8041603b8c:	49 89 c6             	mov    %rax,%r14
  8041603b8f:	49 89 c7             	mov    %rax,%r15
      while (buf != 0) {
        digits_16++;
        buf = buf / 16;
      }
      
      cprintf("  rbp ");
  8041603b92:	49 bc 0d 92 60 41 80 	movabs $0x804160920d,%r12
  8041603b99:	00 00 00 
      cprintf("%lx\n", rip);
      
      // get and print debug info
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
      if (code == 0) {
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603b9c:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603ba3:	48 05 04 01 00 00    	add    $0x104,%rax
  8041603ba9:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  8041603bb0:	e9 37 01 00 00       	jmpq   8041603cec <mon_backtrace+0x19b>
        buf = buf / 16;
  8041603bb5:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603bb8:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603bbb:	48 89 c2             	mov    %rax,%rdx
  8041603bbe:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603bc2:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603bc6:	77 ed                	ja     8041603bb5 <mon_backtrace+0x64>
      cprintf("  rbp ");
  8041603bc8:	48 bf 04 d3 60 41 80 	movabs $0x804160d304,%rdi
  8041603bcf:	00 00 00 
  8041603bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603bd7:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603bda:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603be0:	41 29 dd             	sub    %ebx,%r13d
  8041603be3:	45 85 ed             	test   %r13d,%r13d
  8041603be6:	7e 1f                	jle    8041603c07 <mon_backtrace+0xb6>
  8041603be8:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603bed:	48 bf 66 e0 60 41 80 	movabs $0x804160e066,%rdi
  8041603bf4:	00 00 00 
  8041603bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603bfc:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603bff:	83 c3 01             	add    $0x1,%ebx
  8041603c02:	41 39 dd             	cmp    %ebx,%r13d
  8041603c05:	7d e6                	jge    8041603bed <mon_backtrace+0x9c>
      cprintf("%lx", rbp);
  8041603c07:	4c 89 f6             	mov    %r14,%rsi
  8041603c0a:	48 bf 0b d3 60 41 80 	movabs $0x804160d30b,%rdi
  8041603c11:	00 00 00 
  8041603c14:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c19:	41 ff d4             	callq  *%r12
      rbp = *pointer;
  8041603c1c:	4d 8b 37             	mov    (%r15),%r14
      rip = *pointer;
  8041603c1f:	4d 8b 7f 08          	mov    0x8(%r15),%r15
      buf = buf / 16;
  8041603c23:	4c 89 f8             	mov    %r15,%rax
  8041603c26:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603c2a:	49 83 ff 0f          	cmp    $0xf,%r15
  8041603c2e:	0f 86 e3 00 00 00    	jbe    8041603d17 <mon_backtrace+0x1c6>
      digits_16 = 1;
  8041603c34:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603c39:	eb 03                	jmp    8041603c3e <mon_backtrace+0xed>
        buf = buf / 16;
  8041603c3b:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603c3e:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603c41:	48 89 c2             	mov    %rax,%rdx
  8041603c44:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603c48:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603c4c:	77 ed                	ja     8041603c3b <mon_backtrace+0xea>
      cprintf("  rip ");
  8041603c4e:	48 bf 0f d3 60 41 80 	movabs $0x804160d30f,%rdi
  8041603c55:	00 00 00 
  8041603c58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c5d:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c60:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603c66:	41 29 dd             	sub    %ebx,%r13d
  8041603c69:	45 85 ed             	test   %r13d,%r13d
  8041603c6c:	7e 1f                	jle    8041603c8d <mon_backtrace+0x13c>
  8041603c6e:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603c73:	48 bf 66 e0 60 41 80 	movabs $0x804160e066,%rdi
  8041603c7a:	00 00 00 
  8041603c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c82:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c85:	83 c3 01             	add    $0x1,%ebx
  8041603c88:	44 39 eb             	cmp    %r13d,%ebx
  8041603c8b:	7e e6                	jle    8041603c73 <mon_backtrace+0x122>
      cprintf("%lx\n", rip);
  8041603c8d:	4c 89 fe             	mov    %r15,%rsi
  8041603c90:	48 bf c4 e0 60 41 80 	movabs $0x804160e0c4,%rdi
  8041603c97:	00 00 00 
  8041603c9a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c9f:	41 ff d4             	callq  *%r12
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
  8041603ca2:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603ca9:	4c 89 ff             	mov    %r15,%rdi
  8041603cac:	48 b8 97 b5 60 41 80 	movabs $0x804160b597,%rax
  8041603cb3:	00 00 00 
  8041603cb6:	ff d0                	callq  *%rax
      if (code == 0) {
  8041603cb8:	85 c0                	test   %eax,%eax
  8041603cba:	75 47                	jne    8041603d03 <mon_backtrace+0x1b2>
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603cbc:	4d 89 f8             	mov    %r15,%r8
  8041603cbf:	4c 2b 45 b8          	sub    -0x48(%rbp),%r8
  8041603cc3:	48 8b 8d a8 fd ff ff 	mov    -0x258(%rbp),%rcx
  8041603cca:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603cd0:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603cd7:	48 bf 16 d3 60 41 80 	movabs $0x804160d316,%rdi
  8041603cde:	00 00 00 
  8041603ce1:	41 ff d4             	callq  *%r12
      } else {
          cprintf("Info not found");
      }
      
      pointer = (uintptr_t *)rbp;
  8041603ce4:	4d 89 f7             	mov    %r14,%r15
  while (rbp != 0) {
  8041603ce7:	4d 85 f6             	test   %r14,%r14
  8041603cea:	74 65                	je     8041603d51 <mon_backtrace+0x200>
      buf = buf / 16;
  8041603cec:	4c 89 f0             	mov    %r14,%rax
  8041603cef:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603cf3:	49 83 fe 0f          	cmp    $0xf,%r14
  8041603cf7:	76 3b                	jbe    8041603d34 <mon_backtrace+0x1e3>
      digits_16 = 1;
  8041603cf9:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603cfe:	e9 b5 fe ff ff       	jmpq   8041603bb8 <mon_backtrace+0x67>
          cprintf("Info not found");
  8041603d03:	48 bf 2e d3 60 41 80 	movabs $0x804160d32e,%rdi
  8041603d0a:	00 00 00 
  8041603d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d12:	41 ff d4             	callq  *%r12
  8041603d15:	eb cd                	jmp    8041603ce4 <mon_backtrace+0x193>
      cprintf("  rip ");
  8041603d17:	48 bf 0f d3 60 41 80 	movabs $0x804160d30f,%rdi
  8041603d1e:	00 00 00 
  8041603d21:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d26:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d29:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d2f:	e9 3a ff ff ff       	jmpq   8041603c6e <mon_backtrace+0x11d>
      cprintf("  rbp ");
  8041603d34:	48 bf 04 d3 60 41 80 	movabs $0x804160d304,%rdi
  8041603d3b:	00 00 00 
  8041603d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d43:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d46:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d4c:	e9 97 fe ff ff       	jmpq   8041603be8 <mon_backtrace+0x97>
    }
    
  // LAB 2 code end
  return 0;
}
  8041603d51:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d56:	48 81 c4 38 02 00 00 	add    $0x238,%rsp
  8041603d5d:	5b                   	pop    %rbx
  8041603d5e:	41 5c                	pop    %r12
  8041603d60:	41 5d                	pop    %r13
  8041603d62:	41 5e                	pop    %r14
  8041603d64:	41 5f                	pop    %r15
  8041603d66:	5d                   	pop    %rbp
  8041603d67:	c3                   	retq   

0000008041603d68 <mon_start>:
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
int
mon_start(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603d68:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603d6d:	83 ff 02             	cmp    $0x2,%edi
  8041603d70:	74 01                	je     8041603d73 <mon_start+0xb>
  }
  timer_start(argv[1]);
  // LAB 5 code end

  return 0;
}
  8041603d72:	c3                   	retq   
mon_start(int argc, char **argv, struct Trapframe *tf) {
  8041603d73:	55                   	push   %rbp
  8041603d74:	48 89 e5             	mov    %rsp,%rbp
  timer_start(argv[1]);
  8041603d77:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603d7b:	48 b8 ae c9 60 41 80 	movabs $0x804160c9ae,%rax
  8041603d82:	00 00 00 
  8041603d85:	ff d0                	callq  *%rax
  return 0;
  8041603d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603d8c:	5d                   	pop    %rbp
  8041603d8d:	c3                   	retq   

0000008041603d8e <mon_stop>:

int
mon_stop(int argc, char **argv, struct Trapframe *tf) {
  8041603d8e:	55                   	push   %rbp
  8041603d8f:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  timer_stop();
  8041603d92:	48 b8 68 ca 60 41 80 	movabs $0x804160ca68,%rax
  8041603d99:	00 00 00 
  8041603d9c:	ff d0                	callq  *%rax
  // LAB 5 code end

  return 0;
}
  8041603d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603da3:	5d                   	pop    %rbp
  8041603da4:	c3                   	retq   

0000008041603da5 <mon_frequency>:

int
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603da5:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603daa:	83 ff 02             	cmp    $0x2,%edi
  8041603dad:	74 01                	je     8041603db0 <mon_frequency+0xb>
  }
  timer_cpu_frequency(argv[1]);
  // LAB 5 code end

  return 0;
}
  8041603daf:	c3                   	retq   
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  8041603db0:	55                   	push   %rbp
  8041603db1:	48 89 e5             	mov    %rsp,%rbp
  timer_cpu_frequency(argv[1]);
  8041603db4:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603db8:	48 b8 f2 ca 60 41 80 	movabs $0x804160caf2,%rax
  8041603dbf:	00 00 00 
  8041603dc2:	ff d0                	callq  *%rax
  return 0;
  8041603dc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603dc9:	5d                   	pop    %rbp
  8041603dca:	c3                   	retq   

0000008041603dcb <mon_memory>:
int 
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  size_t i;
	int is_cur_free;

	for (i = 1; i <= npages; i++) {
  8041603dcb:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041603dd2:	00 00 00 
  8041603dd5:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041603dd9:	0f 84 24 01 00 00    	je     8041603f03 <mon_memory+0x138>
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  8041603ddf:	55                   	push   %rbp
  8041603de0:	48 89 e5             	mov    %rsp,%rbp
  8041603de3:	41 57                	push   %r15
  8041603de5:	41 56                	push   %r14
  8041603de7:	41 55                	push   %r13
  8041603de9:	41 54                	push   %r12
  8041603deb:	53                   	push   %rbx
  8041603dec:	48 83 ec 18          	sub    $0x18,%rsp
	for (i = 1; i <= npages; i++) {
  8041603df0:	bb 01 00 00 00       	mov    $0x1,%ebx
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603df5:	49 be 58 5a 88 41 80 	movabs $0x8041885a58,%r14
  8041603dfc:	00 00 00 
		cprintf("%lu", i);
  8041603dff:	49 bf 0d 92 60 41 80 	movabs $0x804160920d,%r15
  8041603e06:	00 00 00 
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e09:	49 89 c4             	mov    %rax,%r12
  8041603e0c:	eb 47                	jmp    8041603e55 <mon_memory+0x8a>
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
        i++;
      }
			cprintf("..%lu", i);
  8041603e0e:	48 89 de             	mov    %rbx,%rsi
  8041603e11:	48 bf 50 d3 60 41 80 	movabs $0x804160d350,%rdi
  8041603e18:	00 00 00 
  8041603e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e20:	41 ff d7             	callq  *%r15
		}
		cprintf(is_cur_free ? " FREE\n" : " ALLOCATED\n");
  8041603e23:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603e27:	48 bf 3d d3 60 41 80 	movabs $0x804160d33d,%rdi
  8041603e2e:	00 00 00 
  8041603e31:	48 b8 44 d3 60 41 80 	movabs $0x804160d344,%rax
  8041603e38:	00 00 00 
  8041603e3b:	48 0f 45 f8          	cmovne %rax,%rdi
  8041603e3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e44:	41 ff d7             	callq  *%r15
	for (i = 1; i <= npages; i++) {
  8041603e47:	48 83 c3 01          	add    $0x1,%rbx
  8041603e4b:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603e4f:	0f 82 9a 00 00 00    	jb     8041603eef <mon_memory+0x124>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e55:	49 89 dd             	mov    %rbx,%r13
  8041603e58:	49 c1 e5 04          	shl    $0x4,%r13
  8041603e5c:	49 8b 06             	mov    (%r14),%rax
  8041603e5f:	4a 8d 7c 28 f0       	lea    -0x10(%rax,%r13,1),%rdi
  8041603e64:	48 b8 f1 4a 60 41 80 	movabs $0x8041604af1,%rax
  8041603e6b:	00 00 00 
  8041603e6e:	ff d0                	callq  *%rax
  8041603e70:	89 45 cc             	mov    %eax,-0x34(%rbp)
		cprintf("%lu", i);
  8041603e73:	48 89 de             	mov    %rbx,%rsi
  8041603e76:	48 bf 52 d3 60 41 80 	movabs $0x804160d352,%rdi
  8041603e7d:	00 00 00 
  8041603e80:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e85:	41 ff d7             	callq  *%r15
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e88:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603e8c:	76 95                	jbe    8041603e23 <mon_memory+0x58>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e8e:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603e92:	0f 94 c0             	sete   %al
  8041603e95:	0f b6 c0             	movzbl %al,%eax
  8041603e98:	89 45 c8             	mov    %eax,-0x38(%rbp)
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e9b:	4c 89 ef             	mov    %r13,%rdi
  8041603e9e:	49 03 3e             	add    (%r14),%rdi
  8041603ea1:	48 b8 f1 4a 60 41 80 	movabs $0x8041604af1,%rax
  8041603ea8:	00 00 00 
  8041603eab:	ff d0                	callq  *%rax
  8041603ead:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603eb0:	0f 84 6d ff ff ff    	je     8041603e23 <mon_memory+0x58>
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603eb6:	49 bd f1 4a 60 41 80 	movabs $0x8041604af1,%r13
  8041603ebd:	00 00 00 
  8041603ec0:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603ec4:	0f 86 44 ff ff ff    	jbe    8041603e0e <mon_memory+0x43>
  8041603eca:	48 89 df             	mov    %rbx,%rdi
  8041603ecd:	48 c1 e7 04          	shl    $0x4,%rdi
  8041603ed1:	49 03 3e             	add    (%r14),%rdi
  8041603ed4:	41 ff d5             	callq  *%r13
  8041603ed7:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603eda:	0f 84 2e ff ff ff    	je     8041603e0e <mon_memory+0x43>
        i++;
  8041603ee0:	48 83 c3 01          	add    $0x1,%rbx
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603ee4:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603ee8:	77 e0                	ja     8041603eca <mon_memory+0xff>
  8041603eea:	e9 1f ff ff ff       	jmpq   8041603e0e <mon_memory+0x43>
	}
	
  return 0;
}
  8041603eef:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ef4:	48 83 c4 18          	add    $0x18,%rsp
  8041603ef8:	5b                   	pop    %rbx
  8041603ef9:	41 5c                	pop    %r12
  8041603efb:	41 5d                	pop    %r13
  8041603efd:	41 5e                	pop    %r14
  8041603eff:	41 5f                	pop    %r15
  8041603f01:	5d                   	pop    %rbp
  8041603f02:	c3                   	retq   
  8041603f03:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f08:	c3                   	retq   

0000008041603f09 <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603f09:	55                   	push   %rbp
  8041603f0a:	48 89 e5             	mov    %rsp,%rbp
  8041603f0d:	41 57                	push   %r15
  8041603f0f:	41 56                	push   %r14
  8041603f11:	41 55                	push   %r13
  8041603f13:	41 54                	push   %r12
  8041603f15:	53                   	push   %rbx
  8041603f16:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603f1d:	49 89 ff             	mov    %rdi,%r15
  8041603f20:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603f27:	48 bf 48 d5 60 41 80 	movabs $0x804160d548,%rdi
  8041603f2e:	00 00 00 
  8041603f31:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f36:	48 bb 0d 92 60 41 80 	movabs $0x804160920d,%rbx
  8041603f3d:	00 00 00 
  8041603f40:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603f42:	48 bf 70 d5 60 41 80 	movabs $0x804160d570,%rdi
  8041603f49:	00 00 00 
  8041603f4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f51:	ff d3                	callq  *%rbx

  if (tf != NULL)
  8041603f53:	4d 85 ff             	test   %r15,%r15
  8041603f56:	74 0f                	je     8041603f67 <monitor+0x5e>
    print_trapframe(tf);
  8041603f58:	4c 89 ff             	mov    %r15,%rdi
  8041603f5b:	48 b8 d8 98 60 41 80 	movabs $0x80416098d8,%rax
  8041603f62:	00 00 00 
  8041603f65:	ff d0                	callq  *%rax

  while (1) {
    buf = readline("K> ");
  8041603f67:	49 bf aa c1 60 41 80 	movabs $0x804160c1aa,%r15
  8041603f6e:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603f71:	49 be 61 c4 60 41 80 	movabs $0x804160c461,%r14
  8041603f78:	00 00 00 
  8041603f7b:	e9 ff 00 00 00       	jmpq   804160407f <monitor+0x176>
  8041603f80:	40 0f be f6          	movsbl %sil,%esi
  8041603f84:	48 bf 5a d3 60 41 80 	movabs $0x804160d35a,%rdi
  8041603f8b:	00 00 00 
  8041603f8e:	41 ff d6             	callq  *%r14
  8041603f91:	48 85 c0             	test   %rax,%rax
  8041603f94:	74 0c                	je     8041603fa2 <monitor+0x99>
      *buf++ = 0;
  8041603f96:	c6 03 00             	movb   $0x0,(%rbx)
  8041603f99:	45 89 e5             	mov    %r12d,%r13d
  8041603f9c:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603fa0:	eb 49                	jmp    8041603feb <monitor+0xe2>
    if (*buf == 0)
  8041603fa2:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603fa5:	74 4f                	je     8041603ff6 <monitor+0xed>
    if (argc == MAXARGS - 1) {
  8041603fa7:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603fab:	0f 84 b3 00 00 00    	je     8041604064 <monitor+0x15b>
    argv[argc++] = buf;
  8041603fb1:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  8041603fb6:	4d 63 e4             	movslq %r12d,%r12
  8041603fb9:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041603fc0:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603fc1:	0f b6 33             	movzbl (%rbx),%esi
  8041603fc4:	40 84 f6             	test   %sil,%sil
  8041603fc7:	74 22                	je     8041603feb <monitor+0xe2>
  8041603fc9:	40 0f be f6          	movsbl %sil,%esi
  8041603fcd:	48 bf 5a d3 60 41 80 	movabs $0x804160d35a,%rdi
  8041603fd4:	00 00 00 
  8041603fd7:	41 ff d6             	callq  *%r14
  8041603fda:	48 85 c0             	test   %rax,%rax
  8041603fdd:	75 0c                	jne    8041603feb <monitor+0xe2>
      buf++;
  8041603fdf:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603fe3:	0f b6 33             	movzbl (%rbx),%esi
  8041603fe6:	40 84 f6             	test   %sil,%sil
  8041603fe9:	75 de                	jne    8041603fc9 <monitor+0xc0>
      *buf++ = 0;
  8041603feb:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603fee:	0f b6 33             	movzbl (%rbx),%esi
  8041603ff1:	40 84 f6             	test   %sil,%sil
  8041603ff4:	75 8a                	jne    8041603f80 <monitor+0x77>
  argv[argc] = 0;
  8041603ff6:	49 63 c4             	movslq %r12d,%rax
  8041603ff9:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041604000:	ff 00 00 00 00 
  if (argc == 0)
  8041604005:	45 85 e4             	test   %r12d,%r12d
  8041604008:	74 75                	je     804160407f <monitor+0x176>
  804160400a:	49 bd 00 d6 60 41 80 	movabs $0x804160d600,%r13
  8041604011:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041604014:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  8041604019:	49 8b 75 00          	mov    0x0(%r13),%rsi
  804160401d:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041604024:	48 b8 fa c3 60 41 80 	movabs $0x804160c3fa,%rax
  804160402b:	00 00 00 
  804160402e:	ff d0                	callq  *%rax
  8041604030:	85 c0                	test   %eax,%eax
  8041604032:	74 76                	je     80416040aa <monitor+0x1a1>
  for (i = 0; i < NCOMMANDS; i++) {
  8041604034:	83 c3 01             	add    $0x1,%ebx
  8041604037:	49 83 c5 18          	add    $0x18,%r13
  804160403b:	83 fb 08             	cmp    $0x8,%ebx
  804160403e:	75 d9                	jne    8041604019 <monitor+0x110>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041604040:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041604047:	48 bf 7c d3 60 41 80 	movabs $0x804160d37c,%rdi
  804160404e:	00 00 00 
  8041604051:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604056:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160405d:	00 00 00 
  8041604060:	ff d2                	callq  *%rdx
  return 0;
  8041604062:	eb 1b                	jmp    804160407f <monitor+0x176>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041604064:	be 10 00 00 00       	mov    $0x10,%esi
  8041604069:	48 bf 5f d3 60 41 80 	movabs $0x804160d35f,%rdi
  8041604070:	00 00 00 
  8041604073:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160407a:	00 00 00 
  804160407d:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  804160407f:	48 bf 56 d3 60 41 80 	movabs $0x804160d356,%rdi
  8041604086:	00 00 00 
  8041604089:	41 ff d7             	callq  *%r15
  804160408c:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  804160408f:	48 85 c0             	test   %rax,%rax
  8041604092:	74 eb                	je     804160407f <monitor+0x176>
  argv[argc] = 0;
  8041604094:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  804160409b:	00 00 00 00 
  argc       = 0;
  804160409f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  80416040a5:	e9 44 ff ff ff       	jmpq   8041603fee <monitor+0xe5>
      return commands[i].func(argc, argv, tf);
  80416040aa:	48 63 db             	movslq %ebx,%rbx
  80416040ad:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  80416040b1:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  80416040b8:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  80416040bf:	44 89 e7             	mov    %r12d,%edi
  80416040c2:	48 b8 00 d6 60 41 80 	movabs $0x804160d600,%rax
  80416040c9:	00 00 00 
  80416040cc:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  80416040d0:	85 c0                	test   %eax,%eax
  80416040d2:	79 ab                	jns    804160407f <monitor+0x176>
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
  // cprintf("%x", va);
  pml4e = &pml4e[PML4(va)];
  80416040e6:	48 89 f0             	mov    %rsi,%rax
  80416040e9:	48 c1 e8 27          	shr    $0x27,%rax
  80416040ed:	25 ff 01 00 00       	and    $0x1ff,%eax
  // cprintf(" %x %x " , PML4(va), *pml4e);
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
  804160410a:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041604111:	00 00 00 
  8041604114:	48 8b 10             	mov    (%rax),%rdx
  8041604117:	48 89 c8             	mov    %rcx,%rax
  804160411a:	48 c1 e8 0c          	shr    $0xc,%rax
  804160411e:	48 39 c2             	cmp    %rax,%rdx
  8041604121:	0f 86 b1 00 00 00    	jbe    80416041d8 <check_va2pa+0xf2>
  // cprintf(" %x %x " , pdpe, *pdpe);
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
  // cprintf(" %x %x " , pde, *pde);
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
  // cprintf(" %x %x " , pte, *pte);
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
  // cprintf(" %x %x\n" , PTX(va),  PTE_ADDR(pte[PTX(va)]));
  return PTE_ADDR(pte[PTX(va)]);
  80416041c2:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416041c8:	48 85 d2             	test   %rdx,%rdx
  80416041cb:	48 c7 c2 ff ff ff ff 	mov    $0xffffffffffffffff,%rdx
  80416041d2:	48 0f 44 c2          	cmove  %rdx,%rax
}
  80416041d6:	5d                   	pop    %rbp
  80416041d7:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416041d8:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  80416041df:	00 00 00 
  80416041e2:	be 7e 04 00 00       	mov    $0x47e,%esi
  80416041e7:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416041ee:	00 00 00 
  80416041f1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416041f6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416041fd:	00 00 00 
  8041604200:	41 ff d0             	callq  *%r8
  8041604203:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160420a:	00 00 00 
  804160420d:	be 82 04 00 00       	mov    $0x482,%esi
  8041604212:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604219:	00 00 00 
  804160421c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604221:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604228:	00 00 00 
  804160422b:	41 ff d0             	callq  *%r8
  804160422e:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604235:	00 00 00 
  8041604238:	be 87 04 00 00       	mov    $0x487,%esi
  804160423d:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
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
  if (!nextfree) {
  8041604279:	48 b8 f8 44 88 41 80 	movabs $0x80418844f8,%rax
  8041604280:	00 00 00 
  8041604283:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604287:	74 5c                	je     80416042e5 <boot_alloc+0x6c>
  if (!n) {
  8041604289:	85 ff                	test   %edi,%edi
  804160428b:	74 74                	je     8041604301 <boot_alloc+0x88>
boot_alloc(uint32_t n) {
  804160428d:	55                   	push   %rbp
  804160428e:	48 89 e5             	mov    %rsp,%rbp
	result = nextfree;
  8041604291:	48 ba f8 44 88 41 80 	movabs $0x80418844f8,%rdx
  8041604298:	00 00 00 
  804160429b:	48 8b 02             	mov    (%rdx),%rax
	nextfree += ROUNDUP(n, PGSIZE);
  804160429e:	48 8d 8f ff 0f 00 00 	lea    0xfff(%rdi),%rcx
  80416042a5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  80416042ab:	48 01 c1             	add    %rax,%rcx
  80416042ae:	48 89 0a             	mov    %rcx,(%rdx)
  if ((uint64_t)kva < KERNBASE)
  80416042b1:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  80416042b8:	00 00 00 
  80416042bb:	48 39 d1             	cmp    %rdx,%rcx
  80416042be:	76 4c                	jbe    804160430c <boot_alloc+0x93>
	if (PADDR(nextfree) > PGSIZE * npages) {
  80416042c0:	48 be 50 5a 88 41 80 	movabs $0x8041885a50,%rsi
  80416042c7:	00 00 00 
  80416042ca:	48 8b 16             	mov    (%rsi),%rdx
  80416042cd:	48 c1 e2 0c          	shl    $0xc,%rdx
  return (physaddr_t)kva - KERNBASE;
  80416042d1:	48 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rsi
  80416042d8:	ff ff ff 
  80416042db:	48 01 f1             	add    %rsi,%rcx
  80416042de:	48 39 ca             	cmp    %rcx,%rdx
  80416042e1:	72 54                	jb     8041604337 <boot_alloc+0xbe>
}
  80416042e3:	5d                   	pop    %rbp
  80416042e4:	c3                   	retq   
		nextfree = ROUNDUP((char *)end, PGSIZE);
  80416042e5:	48 b8 ff 6f 88 41 80 	movabs $0x8041886fff,%rax
  80416042ec:	00 00 00 
  80416042ef:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416042f5:	48 a3 f8 44 88 41 80 	movabs %rax,0x80418844f8
  80416042fc:	00 00 00 
  80416042ff:	eb 88                	jmp    8041604289 <boot_alloc+0x10>
	    return nextfree;
  8041604301:	48 a1 f8 44 88 41 80 	movabs 0x80418844f8,%rax
  8041604308:	00 00 00 
}
  804160430b:	c3                   	retq   
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160430c:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  8041604313:	00 00 00 
  8041604316:	be bd 00 00 00       	mov    $0xbd,%esi
  804160431b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604322:	00 00 00 
  8041604325:	b8 00 00 00 00       	mov    $0x0,%eax
  804160432a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604331:	00 00 00 
  8041604334:	41 ff d0             	callq  *%r8
	    panic("Not enough memory for boot!");
  8041604337:	48 ba 1b e0 60 41 80 	movabs $0x804160e01b,%rdx
  804160433e:	00 00 00 
  8041604341:	be be 00 00 00       	mov    $0xbe,%esi
  8041604346:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160434d:	00 00 00 
  8041604350:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604355:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160435c:	00 00 00 
  804160435f:	ff d1                	callq  *%rcx

0000008041604361 <check_page_free_list>:
check_page_free_list(bool only_low_memory) {
  8041604361:	55                   	push   %rbp
  8041604362:	48 89 e5             	mov    %rsp,%rbp
  8041604365:	53                   	push   %rbx
  8041604366:	48 83 ec 28          	sub    $0x28,%rsp
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  804160436a:	40 84 ff             	test   %dil,%dil
  804160436d:	0f 85 7f 03 00 00    	jne    80416046f2 <check_page_free_list+0x391>
  if (!page_free_list)
  8041604373:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  804160437a:	00 00 00 
  804160437d:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604381:	0f 84 9f 00 00 00    	je     8041604426 <check_page_free_list+0xc5>
  first_free_page = (char *)boot_alloc(0);
  8041604387:	bf 00 00 00 00       	mov    $0x0,%edi
  804160438c:	48 b8 79 42 60 41 80 	movabs $0x8041604279,%rax
  8041604393:	00 00 00 
  8041604396:	ff d0                	callq  *%rax
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604398:	48 bb 10 45 88 41 80 	movabs $0x8041884510,%rbx
  804160439f:	00 00 00 
  80416043a2:	48 8b 13             	mov    (%rbx),%rdx
  80416043a5:	48 85 d2             	test   %rdx,%rdx
  80416043a8:	0f 84 0f 03 00 00    	je     80416046bd <check_page_free_list+0x35c>
    assert(pp >= pages);
  80416043ae:	48 bb 58 5a 88 41 80 	movabs $0x8041885a58,%rbx
  80416043b5:	00 00 00 
  80416043b8:	48 8b 3b             	mov    (%rbx),%rdi
  80416043bb:	48 39 fa             	cmp    %rdi,%rdx
  80416043be:	0f 82 8c 00 00 00    	jb     8041604450 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  80416043c4:	48 bb 50 5a 88 41 80 	movabs $0x8041885a50,%rbx
  80416043cb:	00 00 00 
  80416043ce:	4c 8b 1b             	mov    (%rbx),%r11
  80416043d1:	4d 89 d8             	mov    %r11,%r8
  80416043d4:	49 c1 e0 04          	shl    $0x4,%r8
  80416043d8:	49 01 f8             	add    %rdi,%r8
  80416043db:	4c 39 c2             	cmp    %r8,%rdx
  80416043de:	0f 83 a1 00 00 00    	jae    8041604485 <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416043e4:	48 89 d1             	mov    %rdx,%rcx
  80416043e7:	48 29 f9             	sub    %rdi,%rcx
  80416043ea:	f6 c1 0f             	test   $0xf,%cl
  80416043ed:	0f 85 c7 00 00 00    	jne    80416044ba <check_page_free_list+0x159>
int user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
  80416043f3:	48 c1 f9 04          	sar    $0x4,%rcx
  80416043f7:	48 c1 e1 0c          	shl    $0xc,%rcx
  80416043fb:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  80416043fe:	0f 84 eb 00 00 00    	je     80416044ef <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604404:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  804160440b:	0f 84 13 01 00 00    	je     8041604524 <check_page_free_list+0x1c3>
  int nfree_basemem = 0, nfree_extmem = 0;
  8041604411:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  return (void *)(pa + KERNBASE);
  8041604417:	48 bb 00 00 00 40 80 	movabs $0x8040000000,%rbx
  804160441e:	00 00 00 
  8041604421:	e9 17 02 00 00       	jmpq   804160463d <check_page_free_list+0x2dc>
    panic("'page_free_list' is a null pointer!");
  8041604426:	48 ba 08 d7 60 41 80 	movabs $0x804160d708,%rdx
  804160442d:	00 00 00 
  8041604430:	be b2 03 00 00       	mov    $0x3b2,%esi
  8041604435:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160443c:	00 00 00 
  804160443f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604444:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160444b:	00 00 00 
  804160444e:	ff d1                	callq  *%rcx
    assert(pp >= pages);
  8041604450:	48 b9 37 e0 60 41 80 	movabs $0x804160e037,%rcx
  8041604457:	00 00 00 
  804160445a:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041604461:	00 00 00 
  8041604464:	be d3 03 00 00       	mov    $0x3d3,%esi
  8041604469:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604470:	00 00 00 
  8041604473:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604478:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160447f:	00 00 00 
  8041604482:	41 ff d0             	callq  *%r8
    assert(pp < pages + npages);
  8041604485:	48 b9 43 e0 60 41 80 	movabs $0x804160e043,%rcx
  804160448c:	00 00 00 
  804160448f:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041604496:	00 00 00 
  8041604499:	be d4 03 00 00       	mov    $0x3d4,%esi
  804160449e:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416044a5:	00 00 00 
  80416044a8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044ad:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044b4:	00 00 00 
  80416044b7:	41 ff d0             	callq  *%r8
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416044ba:	48 b9 30 d7 60 41 80 	movabs $0x804160d730,%rcx
  80416044c1:	00 00 00 
  80416044c4:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416044cb:	00 00 00 
  80416044ce:	be d5 03 00 00       	mov    $0x3d5,%esi
  80416044d3:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416044da:	00 00 00 
  80416044dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044e2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044e9:	00 00 00 
  80416044ec:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != 0);
  80416044ef:	48 b9 57 e0 60 41 80 	movabs $0x804160e057,%rcx
  80416044f6:	00 00 00 
  80416044f9:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041604500:	00 00 00 
  8041604503:	be d8 03 00 00       	mov    $0x3d8,%esi
  8041604508:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160450f:	00 00 00 
  8041604512:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604517:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160451e:	00 00 00 
  8041604521:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != IOPHYSMEM);
  8041604524:	48 b9 68 e0 60 41 80 	movabs $0x804160e068,%rcx
  804160452b:	00 00 00 
  804160452e:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041604535:	00 00 00 
  8041604538:	be d9 03 00 00       	mov    $0x3d9,%esi
  804160453d:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604544:	00 00 00 
  8041604547:	b8 00 00 00 00       	mov    $0x0,%eax
  804160454c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604553:	00 00 00 
  8041604556:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  8041604559:	48 b9 60 d7 60 41 80 	movabs $0x804160d760,%rcx
  8041604560:	00 00 00 
  8041604563:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160456a:	00 00 00 
  804160456d:	be da 03 00 00       	mov    $0x3da,%esi
  8041604572:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604579:	00 00 00 
  804160457c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604581:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604588:	00 00 00 
  804160458b:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM);
  804160458e:	48 b9 81 e0 60 41 80 	movabs $0x804160e081,%rcx
  8041604595:	00 00 00 
  8041604598:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160459f:	00 00 00 
  80416045a2:	be db 03 00 00       	mov    $0x3db,%esi
  80416045a7:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416045ae:	00 00 00 
  80416045b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045b6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045bd:	00 00 00 
  80416045c0:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416045c3:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  80416045ca:	00 00 00 
  80416045cd:	be 61 00 00 00       	mov    $0x61,%esi
  80416045d2:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  80416045d9:	00 00 00 
  80416045dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045e1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045e8:	00 00 00 
  80416045eb:	41 ff d0             	callq  *%r8
      ++nfree_extmem;
  80416045ee:	41 83 c1 01          	add    $0x1,%r9d
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  80416045f2:	48 8b 12             	mov    (%rdx),%rdx
  80416045f5:	48 85 d2             	test   %rdx,%rdx
  80416045f8:	0f 84 b3 00 00 00    	je     80416046b1 <check_page_free_list+0x350>
    assert(pp >= pages);
  80416045fe:	48 39 fa             	cmp    %rdi,%rdx
  8041604601:	0f 82 49 fe ff ff    	jb     8041604450 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  8041604607:	4c 39 c2             	cmp    %r8,%rdx
  804160460a:	0f 83 75 fe ff ff    	jae    8041604485 <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  8041604610:	48 89 d1             	mov    %rdx,%rcx
  8041604613:	48 29 f9             	sub    %rdi,%rcx
  8041604616:	f6 c1 0f             	test   $0xf,%cl
  8041604619:	0f 85 9b fe ff ff    	jne    80416044ba <check_page_free_list+0x159>
  return (pp - pages) << PGSHIFT;
  804160461f:	48 c1 f9 04          	sar    $0x4,%rcx
  8041604623:	48 c1 e1 0c          	shl    $0xc,%rcx
  8041604627:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  804160462a:	0f 84 bf fe ff ff    	je     80416044ef <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604630:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  8041604637:	0f 84 e7 fe ff ff    	je     8041604524 <check_page_free_list+0x1c3>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  804160463d:	48 81 fe 00 f0 0f 00 	cmp    $0xff000,%rsi
  8041604644:	0f 84 0f ff ff ff    	je     8041604559 <check_page_free_list+0x1f8>
    assert(page2pa(pp) != EXTPHYSMEM);
  804160464a:	48 81 fe 00 00 10 00 	cmp    $0x100000,%rsi
  8041604651:	0f 84 37 ff ff ff    	je     804160458e <check_page_free_list+0x22d>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
  8041604657:	48 81 fe ff ff 0f 00 	cmp    $0xfffff,%rsi
  804160465e:	76 92                	jbe    80416045f2 <check_page_free_list+0x291>
  if (PGNUM(pa) >= npages)
  8041604660:	49 89 f2             	mov    %rsi,%r10
  8041604663:	49 c1 ea 0c          	shr    $0xc,%r10
  8041604667:	4d 39 d3             	cmp    %r10,%r11
  804160466a:	0f 86 53 ff ff ff    	jbe    80416045c3 <check_page_free_list+0x262>
  return (void *)(pa + KERNBASE);
  8041604670:	48 01 de             	add    %rbx,%rsi
  8041604673:	48 39 f0             	cmp    %rsi,%rax
  8041604676:	0f 86 72 ff ff ff    	jbe    80416045ee <check_page_free_list+0x28d>
  804160467c:	48 b9 88 d7 60 41 80 	movabs $0x804160d788,%rcx
  8041604683:	00 00 00 
  8041604686:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160468d:	00 00 00 
  8041604690:	be dc 03 00 00       	mov    $0x3dc,%esi
  8041604695:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160469c:	00 00 00 
  804160469f:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046a4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416046ab:	00 00 00 
  80416046ae:	41 ff d0             	callq  *%r8
  assert(nfree_extmem > 0);
  80416046b1:	45 85 c9             	test   %r9d,%r9d
  80416046b4:	7e 07                	jle    80416046bd <check_page_free_list+0x35c>
}
  80416046b6:	48 83 c4 28          	add    $0x28,%rsp
  80416046ba:	5b                   	pop    %rbx
  80416046bb:	5d                   	pop    %rbp
  80416046bc:	c3                   	retq   
  assert(nfree_extmem > 0);
  80416046bd:	48 b9 a9 e0 60 41 80 	movabs $0x804160e0a9,%rcx
  80416046c4:	00 00 00 
  80416046c7:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416046ce:	00 00 00 
  80416046d1:	be e5 03 00 00       	mov    $0x3e5,%esi
  80416046d6:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416046dd:	00 00 00 
  80416046e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046e5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416046ec:	00 00 00 
  80416046ef:	41 ff d0             	callq  *%r8
  if (!page_free_list)
  80416046f2:	48 a1 10 45 88 41 80 	movabs 0x8041884510,%rax
  80416046f9:	00 00 00 
  80416046fc:	48 85 c0             	test   %rax,%rax
  80416046ff:	0f 84 21 fd ff ff    	je     8041604426 <check_page_free_list+0xc5>
    struct PageInfo **tp[2] = {&pp1, &pp2};
  8041604705:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  8041604709:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  804160470d:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  8041604711:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  return (pp - pages) << PGSHIFT;
  8041604715:	48 be 58 5a 88 41 80 	movabs $0x8041885a58,%rsi
  804160471c:	00 00 00 
  804160471f:	48 89 c2             	mov    %rax,%rdx
  8041604722:	48 2b 16             	sub    (%rsi),%rdx
  8041604725:	48 c1 e2 08          	shl    $0x8,%rdx
      int pagetype  = VPN(page2pa(pp)) >= pdx_limit;
  8041604729:	48 c1 ea 0c          	shr    $0xc,%rdx
      *tp[pagetype] = pp;
  804160472d:	0f 95 c2             	setne  %dl
  8041604730:	0f b6 d2             	movzbl %dl,%edx
  8041604733:	48 8b 4c d5 e0       	mov    -0x20(%rbp,%rdx,8),%rcx
  8041604738:	48 89 01             	mov    %rax,(%rcx)
      tp[pagetype]  = &pp->pp_link;
  804160473b:	48 89 44 d5 e0       	mov    %rax,-0x20(%rbp,%rdx,8)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604740:	48 8b 00             	mov    (%rax),%rax
  8041604743:	48 85 c0             	test   %rax,%rax
  8041604746:	75 d7                	jne    804160471f <check_page_free_list+0x3be>
    *tp[1]         = 0;
  8041604748:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804160474c:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    *tp[0]         = pp2;
  8041604753:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8041604757:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160475b:	48 89 10             	mov    %rdx,(%rax)
    page_free_list = pp1;
  804160475e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8041604762:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  8041604769:	00 00 00 
  804160476c:	e9 16 fc ff ff       	jmpq   8041604387 <check_page_free_list+0x26>

0000008041604771 <is_page_allocatable>:
  if (!mmap_base || !mmap_end)
  8041604771:	48 b8 f0 44 88 41 80 	movabs $0x80418844f0,%rax
  8041604778:	00 00 00 
  804160477b:	48 8b 10             	mov    (%rax),%rdx
  804160477e:	48 85 d2             	test   %rdx,%rdx
  8041604781:	0f 84 93 00 00 00    	je     804160481a <is_page_allocatable+0xa9>
  8041604787:	48 b8 e8 44 88 41 80 	movabs $0x80418844e8,%rax
  804160478e:	00 00 00 
  8041604791:	48 8b 30             	mov    (%rax),%rsi
  8041604794:	48 85 f6             	test   %rsi,%rsi
  8041604797:	0f 84 83 00 00 00    	je     8041604820 <is_page_allocatable+0xaf>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  804160479d:	48 39 f2             	cmp    %rsi,%rdx
  80416047a0:	0f 83 80 00 00 00    	jae    8041604826 <is_page_allocatable+0xb5>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  80416047a6:	48 8b 42 08          	mov    0x8(%rdx),%rax
  80416047aa:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  80416047ae:	48 89 c1             	mov    %rax,%rcx
  80416047b1:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  80416047b5:	48 39 cf             	cmp    %rcx,%rdi
  80416047b8:	73 05                	jae    80416047bf <is_page_allocatable+0x4e>
  80416047ba:	48 39 c7             	cmp    %rax,%rdi
  80416047bd:	73 34                	jae    80416047f3 <is_page_allocatable+0x82>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047bf:	48 b8 e0 44 88 41 80 	movabs $0x80418844e0,%rax
  80416047c6:	00 00 00 
  80416047c9:	4c 8b 00             	mov    (%rax),%r8
  80416047cc:	4c 01 c2             	add    %r8,%rdx
  80416047cf:	48 39 d6             	cmp    %rdx,%rsi
  80416047d2:	76 40                	jbe    8041604814 <is_page_allocatable+0xa3>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  80416047d4:	48 8b 42 08          	mov    0x8(%rdx),%rax
  80416047d8:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  80416047dc:	48 89 c1             	mov    %rax,%rcx
  80416047df:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  80416047e3:	48 39 f9             	cmp    %rdi,%rcx
  80416047e6:	0f 97 c1             	seta   %cl
  80416047e9:	48 39 f8             	cmp    %rdi,%rax
  80416047ec:	0f 96 c0             	setbe  %al
  80416047ef:	84 c1                	test   %al,%cl
  80416047f1:	74 d9                	je     80416047cc <is_page_allocatable+0x5b>
      switch (mmap_curr->Type) {
  80416047f3:	8b 0a                	mov    (%rdx),%ecx
  80416047f5:	85 c9                	test   %ecx,%ecx
  80416047f7:	74 33                	je     804160482c <is_page_allocatable+0xbb>
  80416047f9:	83 f9 04             	cmp    $0x4,%ecx
  80416047fc:	76 0a                	jbe    8041604808 <is_page_allocatable+0x97>
          return false;
  80416047fe:	b8 00 00 00 00       	mov    $0x0,%eax
      switch (mmap_curr->Type) {
  8041604803:	83 f9 07             	cmp    $0x7,%ecx
  8041604806:	75 29                	jne    8041604831 <is_page_allocatable+0xc0>
          if (mmap_curr->Attribute & EFI_MEMORY_WB)
  8041604808:	48 8b 42 20          	mov    0x20(%rdx),%rax
  804160480c:	48 c1 e8 03          	shr    $0x3,%rax
  8041604810:	83 e0 01             	and    $0x1,%eax
  8041604813:	c3                   	retq   
  return true;
  8041604814:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604819:	c3                   	retq   
    return true; //Assume page is allocabale if no loading parameters were passed.
  804160481a:	b8 01 00 00 00       	mov    $0x1,%eax
  804160481f:	c3                   	retq   
  8041604820:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604825:	c3                   	retq   
  return true;
  8041604826:	b8 01 00 00 00       	mov    $0x1,%eax
  804160482b:	c3                   	retq   
          return false;
  804160482c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041604831:	c3                   	retq   

0000008041604832 <page_init>:
page_init(void) {
  8041604832:	55                   	push   %rbp
  8041604833:	48 89 e5             	mov    %rsp,%rbp
  8041604836:	41 57                	push   %r15
  8041604838:	41 56                	push   %r14
  804160483a:	41 55                	push   %r13
  804160483c:	41 54                	push   %r12
  804160483e:	53                   	push   %rbx
  804160483f:	48 83 ec 08          	sub    $0x8,%rsp
  pages[0].pp_ref  = 1;
  8041604843:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  804160484a:	00 00 00 
  804160484d:	48 8b 10             	mov    (%rax),%rdx
  8041604850:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
  pages[0].pp_link = NULL;
  8041604856:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  pages[1].pp_ref = 0;
  804160485d:	4c 8b 20             	mov    (%rax),%r12
  8041604860:	66 41 c7 44 24 18 00 	movw   $0x0,0x18(%r12)
  8041604867:	00 
  page_free_list  = &pages[1];
  8041604868:	49 83 c4 10          	add    $0x10,%r12
  804160486c:	4c 89 e0             	mov    %r12,%rax
  804160486f:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  8041604876:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  8041604879:	48 b8 18 45 88 41 80 	movabs $0x8041884518,%rax
  8041604880:	00 00 00 
  8041604883:	48 83 38 01          	cmpq   $0x1,(%rax)
  8041604887:	76 6a                	jbe    80416048f3 <page_init+0xc1>
  8041604889:	bb 01 00 00 00       	mov    $0x1,%ebx
    if (is_page_allocatable(i)) {
  804160488e:	49 bf 71 47 60 41 80 	movabs $0x8041604771,%r15
  8041604895:	00 00 00 
      pages[i].pp_ref  = 1;
  8041604898:	49 bd 58 5a 88 41 80 	movabs $0x8041885a58,%r13
  804160489f:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  80416048a2:	49 89 c6             	mov    %rax,%r14
  80416048a5:	eb 21                	jmp    80416048c8 <page_init+0x96>
      pages[i].pp_ref  = 1;
  80416048a7:	48 89 d8             	mov    %rbx,%rax
  80416048aa:	48 c1 e0 04          	shl    $0x4,%rax
  80416048ae:	49 03 45 00          	add    0x0(%r13),%rax
  80416048b2:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  80416048b8:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = 1; i < npages_basemem; i++) {
  80416048bf:	48 83 c3 01          	add    $0x1,%rbx
  80416048c3:	49 39 1e             	cmp    %rbx,(%r14)
  80416048c6:	76 2b                	jbe    80416048f3 <page_init+0xc1>
    if (is_page_allocatable(i)) {
  80416048c8:	48 89 df             	mov    %rbx,%rdi
  80416048cb:	41 ff d7             	callq  *%r15
  80416048ce:	84 c0                	test   %al,%al
  80416048d0:	74 d5                	je     80416048a7 <page_init+0x75>
      pages[i].pp_ref = 0;
  80416048d2:	48 89 d8             	mov    %rbx,%rax
  80416048d5:	48 c1 e0 04          	shl    $0x4,%rax
  80416048d9:	48 89 c2             	mov    %rax,%rdx
  80416048dc:	49 03 55 00          	add    0x0(%r13),%rdx
  80416048e0:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  80416048e6:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  80416048ea:	49 03 45 00          	add    0x0(%r13),%rax
  80416048ee:	49 89 c4             	mov    %rax,%r12
  80416048f1:	eb cc                	jmp    80416048bf <page_init+0x8d>
  first_free_page = PADDR(boot_alloc(0)) / PGSIZE;
  80416048f3:	bf 00 00 00 00       	mov    $0x0,%edi
  80416048f8:	48 b8 79 42 60 41 80 	movabs $0x8041604279,%rax
  80416048ff:	00 00 00 
  8041604902:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041604904:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160490b:	00 00 00 
  804160490e:	48 39 d0             	cmp    %rdx,%rax
  8041604911:	76 7d                	jbe    8041604990 <page_init+0x15e>
  return (physaddr_t)kva - KERNBASE;
  8041604913:	48 bb 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rbx
  804160491a:	ff ff ff 
  804160491d:	48 01 c3             	add    %rax,%rbx
  8041604920:	48 c1 eb 0c          	shr    $0xc,%rbx
  for (i = npages_basemem; i < first_free_page; i++) {
  8041604924:	48 a1 18 45 88 41 80 	movabs 0x8041884518,%rax
  804160492b:	00 00 00 
  804160492e:	48 39 c3             	cmp    %rax,%rbx
  8041604931:	76 31                	jbe    8041604964 <page_init+0x132>
  8041604933:	48 c1 e0 04          	shl    $0x4,%rax
  8041604937:	48 89 de             	mov    %rbx,%rsi
  804160493a:	48 c1 e6 04          	shl    $0x4,%rsi
    pages[i].pp_ref  = 1;
  804160493e:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  8041604945:	00 00 00 
  8041604948:	48 89 c2             	mov    %rax,%rdx
  804160494b:	48 03 11             	add    (%rcx),%rdx
  804160494e:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
    pages[i].pp_link = NULL;
  8041604954:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  for (i = npages_basemem; i < first_free_page; i++) {
  804160495b:	48 83 c0 10          	add    $0x10,%rax
  804160495f:	48 39 f0             	cmp    %rsi,%rax
  8041604962:	75 e4                	jne    8041604948 <page_init+0x116>
  for (i = first_free_page; i < npages; i++) {
  8041604964:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  804160496b:	00 00 00 
  804160496e:	48 3b 18             	cmp    (%rax),%rbx
  8041604971:	0f 83 93 00 00 00    	jae    8041604a0a <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  8041604977:	49 bf 71 47 60 41 80 	movabs $0x8041604771,%r15
  804160497e:	00 00 00 
      pages[i].pp_ref  = 1;
  8041604981:	49 bd 58 5a 88 41 80 	movabs $0x8041885a58,%r13
  8041604988:	00 00 00 
  for (i = first_free_page; i < npages; i++) {
  804160498b:	49 89 c6             	mov    %rax,%r14
  804160498e:	eb 4f                	jmp    80416049df <page_init+0x1ad>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041604990:	48 89 c1             	mov    %rax,%rcx
  8041604993:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  804160499a:	00 00 00 
  804160499d:	be e9 01 00 00       	mov    $0x1e9,%esi
  80416049a2:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416049a9:	00 00 00 
  80416049ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416049b1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416049b8:	00 00 00 
  80416049bb:	41 ff d0             	callq  *%r8
      pages[i].pp_ref  = 1;
  80416049be:	48 89 d8             	mov    %rbx,%rax
  80416049c1:	48 c1 e0 04          	shl    $0x4,%rax
  80416049c5:	49 03 45 00          	add    0x0(%r13),%rax
  80416049c9:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  80416049cf:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = first_free_page; i < npages; i++) {
  80416049d6:	48 83 c3 01          	add    $0x1,%rbx
  80416049da:	49 39 1e             	cmp    %rbx,(%r14)
  80416049dd:	76 2b                	jbe    8041604a0a <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  80416049df:	48 89 df             	mov    %rbx,%rdi
  80416049e2:	41 ff d7             	callq  *%r15
  80416049e5:	84 c0                	test   %al,%al
  80416049e7:	74 d5                	je     80416049be <page_init+0x18c>
      pages[i].pp_ref = 0;
  80416049e9:	48 89 d8             	mov    %rbx,%rax
  80416049ec:	48 c1 e0 04          	shl    $0x4,%rax
  80416049f0:	48 89 c2             	mov    %rax,%rdx
  80416049f3:	49 03 55 00          	add    0x0(%r13),%rdx
  80416049f7:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  80416049fd:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  8041604a01:	49 03 45 00          	add    0x0(%r13),%rax
  8041604a05:	49 89 c4             	mov    %rax,%r12
  8041604a08:	eb cc                	jmp    80416049d6 <page_init+0x1a4>
}
  8041604a0a:	48 83 c4 08          	add    $0x8,%rsp
  8041604a0e:	5b                   	pop    %rbx
  8041604a0f:	41 5c                	pop    %r12
  8041604a11:	41 5d                	pop    %r13
  8041604a13:	41 5e                	pop    %r14
  8041604a15:	41 5f                	pop    %r15
  8041604a17:	5d                   	pop    %rbp
  8041604a18:	c3                   	retq   

0000008041604a19 <page_alloc>:
page_alloc(int alloc_flags) {
  8041604a19:	55                   	push   %rbp
  8041604a1a:	48 89 e5             	mov    %rsp,%rbp
  8041604a1d:	53                   	push   %rbx
  8041604a1e:	48 83 ec 08          	sub    $0x8,%rsp
  if (!page_free_list) {
  8041604a22:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041604a29:	00 00 00 
  8041604a2c:	48 8b 18             	mov    (%rax),%rbx
  8041604a2f:	48 85 db             	test   %rbx,%rbx
  8041604a32:	74 1f                	je     8041604a53 <page_alloc+0x3a>
  page_free_list               = page_free_list->pp_link;
  8041604a34:	48 8b 03             	mov    (%rbx),%rax
  8041604a37:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  8041604a3e:	00 00 00 
  return_page->pp_link         = NULL;
  8041604a41:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  if (!page_free_list) {
  8041604a48:	48 85 c0             	test   %rax,%rax
  8041604a4b:	74 10                	je     8041604a5d <page_alloc+0x44>
  if (alloc_flags & ALLOC_ZERO) {
  8041604a4d:	40 f6 c7 01          	test   $0x1,%dil
  8041604a51:	75 1d                	jne    8041604a70 <page_alloc+0x57>
}
  8041604a53:	48 89 d8             	mov    %rbx,%rax
  8041604a56:	48 83 c4 08          	add    $0x8,%rsp
  8041604a5a:	5b                   	pop    %rbx
  8041604a5b:	5d                   	pop    %rbp
  8041604a5c:	c3                   	retq   
    page_free_list_top = NULL;
  8041604a5d:	48 b8 08 45 88 41 80 	movabs $0x8041884508,%rax
  8041604a64:	00 00 00 
  8041604a67:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  8041604a6e:	eb dd                	jmp    8041604a4d <page_alloc+0x34>
  return (pp - pages) << PGSHIFT;
  8041604a70:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041604a77:	00 00 00 
  8041604a7a:	48 89 df             	mov    %rbx,%rdi
  8041604a7d:	48 2b 38             	sub    (%rax),%rdi
  8041604a80:	48 c1 ff 04          	sar    $0x4,%rdi
  8041604a84:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041604a88:	48 89 fa             	mov    %rdi,%rdx
  8041604a8b:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041604a8f:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041604a96:	00 00 00 
  8041604a99:	48 3b 10             	cmp    (%rax),%rdx
  8041604a9c:	73 25                	jae    8041604ac3 <page_alloc+0xaa>
  return (void *)(pa + KERNBASE);
  8041604a9e:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604aa5:	00 00 00 
  8041604aa8:	48 01 cf             	add    %rcx,%rdi
    memset(page2kva(return_page), 0, PGSIZE);
  8041604aab:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041604ab0:	be 00 00 00 00       	mov    $0x0,%esi
  8041604ab5:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041604abc:	00 00 00 
  8041604abf:	ff d0                	callq  *%rax
  8041604ac1:	eb 90                	jmp    8041604a53 <page_alloc+0x3a>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604ac3:	48 89 f9             	mov    %rdi,%rcx
  8041604ac6:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604acd:	00 00 00 
  8041604ad0:	be 61 00 00 00       	mov    $0x61,%esi
  8041604ad5:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  8041604adc:	00 00 00 
  8041604adf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ae4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604aeb:	00 00 00 
  8041604aee:	41 ff d0             	callq  *%r8

0000008041604af1 <page_is_allocated>:
  return !pp->pp_link && pp != page_free_list_top;
  8041604af1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604af6:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604afa:	74 01                	je     8041604afd <page_is_allocated+0xc>
}
  8041604afc:	c3                   	retq   
  return !pp->pp_link && pp != page_free_list_top;
  8041604afd:	48 b8 08 45 88 41 80 	movabs $0x8041884508,%rax
  8041604b04:	00 00 00 
  8041604b07:	48 39 38             	cmp    %rdi,(%rax)
  8041604b0a:	0f 95 c0             	setne  %al
  8041604b0d:	0f b6 c0             	movzbl %al,%eax
  8041604b10:	eb ea                	jmp    8041604afc <page_is_allocated+0xb>

0000008041604b12 <page_free>:
  if ((pp->pp_ref != 0) || (pp->pp_link != NULL)) {
  8041604b12:	66 83 7f 08 00       	cmpw   $0x0,0x8(%rdi)
  8041604b17:	75 2a                	jne    8041604b43 <page_free+0x31>
  8041604b19:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604b1d:	75 24                	jne    8041604b43 <page_free+0x31>
  pp->pp_link    = page_free_list;
  8041604b1f:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041604b26:	00 00 00 
  8041604b29:	48 8b 10             	mov    (%rax),%rdx
  8041604b2c:	48 89 17             	mov    %rdx,(%rdi)
  page_free_list = pp;
  8041604b2f:	48 89 38             	mov    %rdi,(%rax)
  if (!page_free_list_top) {
  8041604b32:	48 b8 08 45 88 41 80 	movabs $0x8041884508,%rax
  8041604b39:	00 00 00 
  8041604b3c:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604b40:	74 2f                	je     8041604b71 <page_free+0x5f>
  8041604b42:	c3                   	retq   
page_free(struct PageInfo *pp) {
  8041604b43:	55                   	push   %rbp
  8041604b44:	48 89 e5             	mov    %rsp,%rbp
    panic("page_free: Page cannot be freed!\n");
  8041604b47:	48 ba d0 d7 60 41 80 	movabs $0x804160d7d0,%rdx
  8041604b4e:	00 00 00 
  8041604b51:	be 35 02 00 00       	mov    $0x235,%esi
  8041604b56:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604b5d:	00 00 00 
  8041604b60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b65:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604b6c:	00 00 00 
  8041604b6f:	ff d1                	callq  *%rcx
    page_free_list_top = pp;
  8041604b71:	48 89 f8             	mov    %rdi,%rax
  8041604b74:	48 a3 08 45 88 41 80 	movabs %rax,0x8041884508
  8041604b7b:	00 00 00 
}
  8041604b7e:	eb c2                	jmp    8041604b42 <page_free+0x30>

0000008041604b80 <page_decref>:
  if (--pp->pp_ref == 0)
  8041604b80:	0f b7 47 08          	movzwl 0x8(%rdi),%eax
  8041604b84:	83 e8 01             	sub    $0x1,%eax
  8041604b87:	66 89 47 08          	mov    %ax,0x8(%rdi)
  8041604b8b:	66 85 c0             	test   %ax,%ax
  8041604b8e:	74 01                	je     8041604b91 <page_decref+0x11>
  8041604b90:	c3                   	retq   
page_decref(struct PageInfo *pp) {
  8041604b91:	55                   	push   %rbp
  8041604b92:	48 89 e5             	mov    %rsp,%rbp
    page_free(pp);
  8041604b95:	48 b8 12 4b 60 41 80 	movabs $0x8041604b12,%rax
  8041604b9c:	00 00 00 
  8041604b9f:	ff d0                	callq  *%rax
}
  8041604ba1:	5d                   	pop    %rbp
  8041604ba2:	c3                   	retq   

0000008041604ba3 <pgdir_walk>:
pgdir_walk(pde_t *pgdir, const void *va, int create) {
  8041604ba3:	55                   	push   %rbp
  8041604ba4:	48 89 e5             	mov    %rsp,%rbp
  8041604ba7:	41 54                	push   %r12
  8041604ba9:	53                   	push   %rbx
  8041604baa:	48 89 f3             	mov    %rsi,%rbx
  if (pgdir[PDX(va)] & PTE_P) {
  8041604bad:	49 89 f4             	mov    %rsi,%r12
  8041604bb0:	49 c1 ec 12          	shr    $0x12,%r12
  8041604bb4:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
  8041604bbb:	49 01 fc             	add    %rdi,%r12
  8041604bbe:	49 8b 0c 24          	mov    (%r12),%rcx
  8041604bc2:	f6 c1 01             	test   $0x1,%cl
  8041604bc5:	74 68                	je     8041604c2f <pgdir_walk+0x8c>
		return (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
  8041604bc7:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604bce:	48 89 c8             	mov    %rcx,%rax
  8041604bd1:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604bd5:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604bdc:	00 00 00 
  8041604bdf:	48 39 02             	cmp    %rax,(%rdx)
  8041604be2:	76 20                	jbe    8041604c04 <pgdir_walk+0x61>
  return (void *)(pa + KERNBASE);
  8041604be4:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041604beb:	00 00 00 
  8041604bee:	48 01 c1             	add    %rax,%rcx
  8041604bf1:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604bf5:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604bfb:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
}
  8041604bff:	5b                   	pop    %rbx
  8041604c00:	41 5c                	pop    %r12
  8041604c02:	5d                   	pop    %rbp
  8041604c03:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604c04:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604c0b:	00 00 00 
  8041604c0e:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041604c13:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604c1a:	00 00 00 
  8041604c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604c22:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604c29:	00 00 00 
  8041604c2c:	41 ff d0             	callq  *%r8
	if (create) {
  8041604c2f:	85 d2                	test   %edx,%edx
  8041604c31:	0f 84 aa 00 00 00    	je     8041604ce1 <pgdir_walk+0x13e>
    np = page_alloc(ALLOC_ZERO);
  8041604c37:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604c3c:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041604c43:	00 00 00 
  8041604c46:	ff d0                	callq  *%rax
    if (np) {
  8041604c48:	48 85 c0             	test   %rax,%rax
  8041604c4b:	74 b2                	je     8041604bff <pgdir_walk+0x5c>
        np->pp_ref++;
  8041604c4d:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604c52:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  8041604c59:	00 00 00 
  8041604c5c:	48 89 c2             	mov    %rax,%rdx
  8041604c5f:	48 2b 11             	sub    (%rcx),%rdx
  8041604c62:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604c66:	48 c1 e2 0c          	shl    $0xc,%rdx
        pgdir[PDX(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604c6a:	48 83 ca 07          	or     $0x7,%rdx
  8041604c6e:	49 89 14 24          	mov    %rdx,(%r12)
  8041604c72:	48 2b 01             	sub    (%rcx),%rax
  8041604c75:	48 c1 f8 04          	sar    $0x4,%rax
  8041604c79:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  8041604c7d:	48 89 c1             	mov    %rax,%rcx
  8041604c80:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604c84:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604c8b:	00 00 00 
  8041604c8e:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604c91:	73 20                	jae    8041604cb3 <pgdir_walk+0x110>
  return (void *)(pa + KERNBASE);
  8041604c93:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604c9a:	00 00 00 
  8041604c9d:	48 01 c1             	add    %rax,%rcx
        return (pte_t *) page2kva(np) + PTX(va);
  8041604ca0:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604ca4:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604caa:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
  8041604cae:	e9 4c ff ff ff       	jmpq   8041604bff <pgdir_walk+0x5c>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604cb3:	48 89 c1             	mov    %rax,%rcx
  8041604cb6:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604cbd:	00 00 00 
  8041604cc0:	be 61 00 00 00       	mov    $0x61,%esi
  8041604cc5:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  8041604ccc:	00 00 00 
  8041604ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604cd4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604cdb:	00 00 00 
  8041604cde:	41 ff d0             	callq  *%r8
	return NULL;
  8041604ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ce6:	e9 14 ff ff ff       	jmpq   8041604bff <pgdir_walk+0x5c>

0000008041604ceb <pdpe_walk>:
pdpe_walk(pdpe_t *pdpe, const void *va, int create) {
  8041604ceb:	55                   	push   %rbp
  8041604cec:	48 89 e5             	mov    %rsp,%rbp
  8041604cef:	41 55                	push   %r13
  8041604cf1:	41 54                	push   %r12
  8041604cf3:	53                   	push   %rbx
  8041604cf4:	48 83 ec 08          	sub    $0x8,%rsp
  8041604cf8:	48 89 f3             	mov    %rsi,%rbx
  8041604cfb:	41 89 d4             	mov    %edx,%r12d
  if (pdpe[PDPE(va)] & PTE_P) {
  8041604cfe:	49 89 f5             	mov    %rsi,%r13
  8041604d01:	49 c1 ed 1b          	shr    $0x1b,%r13
  8041604d05:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604d0c:	49 01 fd             	add    %rdi,%r13
  8041604d0f:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604d13:	f6 c1 01             	test   $0x1,%cl
  8041604d16:	74 6f                	je     8041604d87 <pdpe_walk+0x9c>
		return pgdir_walk((pte_t *) KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604d18:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604d1f:	48 89 c8             	mov    %rcx,%rax
  8041604d22:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604d26:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604d2d:	00 00 00 
  8041604d30:	48 39 02             	cmp    %rax,(%rdx)
  8041604d33:	76 27                	jbe    8041604d5c <pdpe_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604d35:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604d3c:	00 00 00 
  8041604d3f:	48 01 cf             	add    %rcx,%rdi
  8041604d42:	44 89 e2             	mov    %r12d,%edx
  8041604d45:	48 b8 a3 4b 60 41 80 	movabs $0x8041604ba3,%rax
  8041604d4c:	00 00 00 
  8041604d4f:	ff d0                	callq  *%rax
}
  8041604d51:	48 83 c4 08          	add    $0x8,%rsp
  8041604d55:	5b                   	pop    %rbx
  8041604d56:	41 5c                	pop    %r12
  8041604d58:	41 5d                	pop    %r13
  8041604d5a:	5d                   	pop    %rbp
  8041604d5b:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604d5c:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604d63:	00 00 00 
  8041604d66:	be 77 02 00 00       	mov    $0x277,%esi
  8041604d6b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604d72:	00 00 00 
  8041604d75:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d7a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604d81:	00 00 00 
  8041604d84:	41 ff d0             	callq  *%r8
	if (create) {
  8041604d87:	85 d2                	test   %edx,%edx
  8041604d89:	0f 84 a3 00 00 00    	je     8041604e32 <pdpe_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604d8f:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604d94:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041604d9b:	00 00 00 
  8041604d9e:	ff d0                	callq  *%rax
    if (np) {
  8041604da0:	48 85 c0             	test   %rax,%rax
  8041604da3:	74 ac                	je     8041604d51 <pdpe_walk+0x66>
      np->pp_ref++;
  8041604da5:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604daa:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041604db1:	00 00 00 
  8041604db4:	48 2b 02             	sub    (%rdx),%rax
  8041604db7:	48 c1 f8 04          	sar    $0x4,%rax
  8041604dbb:	48 c1 e0 0c          	shl    $0xc,%rax
      pdpe[PDPE(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604dbf:	48 89 c2             	mov    %rax,%rdx
  8041604dc2:	48 83 ca 07          	or     $0x7,%rdx
  8041604dc6:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604dca:	48 89 c1             	mov    %rax,%rcx
  8041604dcd:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604dd1:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604dd8:	00 00 00 
  8041604ddb:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604dde:	73 24                	jae    8041604e04 <pdpe_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604de0:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604de7:	00 00 00 
  8041604dea:	48 01 c7             	add    %rax,%rdi
      return pgdir_walk((pte_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604ded:	44 89 e2             	mov    %r12d,%edx
  8041604df0:	48 89 de             	mov    %rbx,%rsi
  8041604df3:	48 b8 a3 4b 60 41 80 	movabs $0x8041604ba3,%rax
  8041604dfa:	00 00 00 
  8041604dfd:	ff d0                	callq  *%rax
  8041604dff:	e9 4d ff ff ff       	jmpq   8041604d51 <pdpe_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604e04:	48 89 c1             	mov    %rax,%rcx
  8041604e07:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604e0e:	00 00 00 
  8041604e11:	be 7f 02 00 00       	mov    $0x27f,%esi
  8041604e16:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604e1d:	00 00 00 
  8041604e20:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e25:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604e2c:	00 00 00 
  8041604e2f:	41 ff d0             	callq  *%r8
	return NULL;
  8041604e32:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e37:	e9 15 ff ff ff       	jmpq   8041604d51 <pdpe_walk+0x66>

0000008041604e3c <pml4e_walk>:
pml4e_walk(pml4e_t *pml4e, const void *va, int create) {
  8041604e3c:	55                   	push   %rbp
  8041604e3d:	48 89 e5             	mov    %rsp,%rbp
  8041604e40:	41 55                	push   %r13
  8041604e42:	41 54                	push   %r12
  8041604e44:	53                   	push   %rbx
  8041604e45:	48 83 ec 08          	sub    $0x8,%rsp
  8041604e49:	48 89 f3             	mov    %rsi,%rbx
  8041604e4c:	41 89 d4             	mov    %edx,%r12d
  if (pml4e[PML4(va)] & PTE_P) {
  8041604e4f:	49 89 f5             	mov    %rsi,%r13
  8041604e52:	49 c1 ed 24          	shr    $0x24,%r13
  8041604e56:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604e5d:	49 01 fd             	add    %rdi,%r13
  8041604e60:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604e64:	f6 c1 01             	test   $0x1,%cl
  8041604e67:	74 6f                	je     8041604ed8 <pml4e_walk+0x9c>
		return pdpe_walk((pdpe_t *) KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604e69:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604e70:	48 89 c8             	mov    %rcx,%rax
  8041604e73:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604e77:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604e7e:	00 00 00 
  8041604e81:	48 39 02             	cmp    %rax,(%rdx)
  8041604e84:	76 27                	jbe    8041604ead <pml4e_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604e86:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604e8d:	00 00 00 
  8041604e90:	48 01 cf             	add    %rcx,%rdi
  8041604e93:	44 89 e2             	mov    %r12d,%edx
  8041604e96:	48 b8 eb 4c 60 41 80 	movabs $0x8041604ceb,%rax
  8041604e9d:	00 00 00 
  8041604ea0:	ff d0                	callq  *%rax
}
  8041604ea2:	48 83 c4 08          	add    $0x8,%rsp
  8041604ea6:	5b                   	pop    %rbx
  8041604ea7:	41 5c                	pop    %r12
  8041604ea9:	41 5d                	pop    %r13
  8041604eab:	5d                   	pop    %rbp
  8041604eac:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604ead:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604eb4:	00 00 00 
  8041604eb7:	be 62 02 00 00       	mov    $0x262,%esi
  8041604ebc:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604ec3:	00 00 00 
  8041604ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ecb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604ed2:	00 00 00 
  8041604ed5:	41 ff d0             	callq  *%r8
	if (create) {
  8041604ed8:	85 d2                	test   %edx,%edx
  8041604eda:	0f 84 a3 00 00 00    	je     8041604f83 <pml4e_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604ee0:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604ee5:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041604eec:	00 00 00 
  8041604eef:	ff d0                	callq  *%rax
    if (np) {
  8041604ef1:	48 85 c0             	test   %rax,%rax
  8041604ef4:	74 ac                	je     8041604ea2 <pml4e_walk+0x66>
      np->pp_ref++;
  8041604ef6:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604efb:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041604f02:	00 00 00 
  8041604f05:	48 2b 02             	sub    (%rdx),%rax
  8041604f08:	48 c1 f8 04          	sar    $0x4,%rax
  8041604f0c:	48 c1 e0 0c          	shl    $0xc,%rax
      pml4e[PML4(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604f10:	48 89 c2             	mov    %rax,%rdx
  8041604f13:	48 83 ca 07          	or     $0x7,%rdx
  8041604f17:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604f1b:	48 89 c1             	mov    %rax,%rcx
  8041604f1e:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604f22:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041604f29:	00 00 00 
  8041604f2c:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604f2f:	73 24                	jae    8041604f55 <pml4e_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604f31:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604f38:	00 00 00 
  8041604f3b:	48 01 c7             	add    %rax,%rdi
      return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604f3e:	44 89 e2             	mov    %r12d,%edx
  8041604f41:	48 89 de             	mov    %rbx,%rsi
  8041604f44:	48 b8 eb 4c 60 41 80 	movabs $0x8041604ceb,%rax
  8041604f4b:	00 00 00 
  8041604f4e:	ff d0                	callq  *%rax
  8041604f50:	e9 4d ff ff ff       	jmpq   8041604ea2 <pml4e_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604f55:	48 89 c1             	mov    %rax,%rcx
  8041604f58:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041604f5f:	00 00 00 
  8041604f62:	be 6a 02 00 00       	mov    $0x26a,%esi
  8041604f67:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041604f6e:	00 00 00 
  8041604f71:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f76:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604f7d:	00 00 00 
  8041604f80:	41 ff d0             	callq  *%r8
	return NULL;
  8041604f83:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f88:	e9 15 ff ff ff       	jmpq   8041604ea2 <pml4e_walk+0x66>

0000008041604f8d <boot_map_region>:
  for (i = 0; i < size; i += PGSIZE) {
  8041604f8d:	48 85 d2             	test   %rdx,%rdx
  8041604f90:	74 72                	je     8041605004 <boot_map_region+0x77>
boot_map_region(pml4e_t *pml4e, uintptr_t va, size_t size, physaddr_t pa, int perm) {
  8041604f92:	55                   	push   %rbp
  8041604f93:	48 89 e5             	mov    %rsp,%rbp
  8041604f96:	41 57                	push   %r15
  8041604f98:	41 56                	push   %r14
  8041604f9a:	41 55                	push   %r13
  8041604f9c:	41 54                	push   %r12
  8041604f9e:	53                   	push   %rbx
  8041604f9f:	48 83 ec 28          	sub    $0x28,%rsp
  8041604fa3:	44 89 45 bc          	mov    %r8d,-0x44(%rbp)
  8041604fa7:	49 89 ce             	mov    %rcx,%r14
  8041604faa:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041604fae:	49 89 f5             	mov    %rsi,%r13
  8041604fb1:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  for (i = 0; i < size; i += PGSIZE) {
  8041604fb5:	41 bc 00 00 00 00    	mov    $0x0,%r12d
		*pml4e_walk(pml4e, (void *)(va + i), 1) = (pa + i) | perm | PTE_P;
  8041604fbb:	49 bf 3c 4e 60 41 80 	movabs $0x8041604e3c,%r15
  8041604fc2:	00 00 00 
  8041604fc5:	4b 8d 1c 26          	lea    (%r14,%r12,1),%rbx
  8041604fc9:	48 63 45 bc          	movslq -0x44(%rbp),%rax
  8041604fcd:	48 09 c3             	or     %rax,%rbx
  8041604fd0:	4b 8d 74 25 00       	lea    0x0(%r13,%r12,1),%rsi
  8041604fd5:	ba 01 00 00 00       	mov    $0x1,%edx
  8041604fda:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041604fde:	41 ff d7             	callq  *%r15
  8041604fe1:	48 83 cb 01          	or     $0x1,%rbx
  8041604fe5:	48 89 18             	mov    %rbx,(%rax)
  for (i = 0; i < size; i += PGSIZE) {
  8041604fe8:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041604fef:	4c 39 65 c0          	cmp    %r12,-0x40(%rbp)
  8041604ff3:	77 d0                	ja     8041604fc5 <boot_map_region+0x38>
}
  8041604ff5:	48 83 c4 28          	add    $0x28,%rsp
  8041604ff9:	5b                   	pop    %rbx
  8041604ffa:	41 5c                	pop    %r12
  8041604ffc:	41 5d                	pop    %r13
  8041604ffe:	41 5e                	pop    %r14
  8041605000:	41 5f                	pop    %r15
  8041605002:	5d                   	pop    %rbp
  8041605003:	c3                   	retq   
  8041605004:	c3                   	retq   

0000008041605005 <page_lookup>:
page_lookup(pml4e_t *pml4e, void *va, pte_t **pte_store) {
  8041605005:	55                   	push   %rbp
  8041605006:	48 89 e5             	mov    %rsp,%rbp
  8041605009:	53                   	push   %rbx
  804160500a:	48 83 ec 08          	sub    $0x8,%rsp
  804160500e:	48 89 d3             	mov    %rdx,%rbx
	ptep = pml4e_walk(pml4e, va, 0);
  8041605011:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605016:	48 b8 3c 4e 60 41 80 	movabs $0x8041604e3c,%rax
  804160501d:	00 00 00 
  8041605020:	ff d0                	callq  *%rax
	if (!ptep) {
  8041605022:	48 85 c0             	test   %rax,%rax
  8041605025:	74 3c                	je     8041605063 <page_lookup+0x5e>
	if (pte_store) {
  8041605027:	48 85 db             	test   %rbx,%rbx
  804160502a:	74 03                	je     804160502f <page_lookup+0x2a>
		*pte_store = ptep;
  804160502c:	48 89 03             	mov    %rax,(%rbx)
	return pa2page(PTE_ADDR(*ptep));
  804160502f:	48 8b 30             	mov    (%rax),%rsi
  8041605032:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
}

static inline struct PageInfo *
pa2page(physaddr_t pa) {
  if (PPN(pa) >= npages) {
  8041605039:	48 89 f0             	mov    %rsi,%rax
  804160503c:	48 c1 e8 0c          	shr    $0xc,%rax
  8041605040:	48 ba 50 5a 88 41 80 	movabs $0x8041885a50,%rdx
  8041605047:	00 00 00 
  804160504a:	48 3b 02             	cmp    (%rdx),%rax
  804160504d:	73 1b                	jae    804160506a <page_lookup+0x65>
    cprintf("accessing %lx\n", (unsigned long)pa);
    panic("pa2page called with invalid pa");
  }
  return &pages[PPN(pa)];
  804160504f:	48 c1 e0 04          	shl    $0x4,%rax
  8041605053:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  804160505a:	00 00 00 
  804160505d:	48 8b 11             	mov    (%rcx),%rdx
  8041605060:	48 01 d0             	add    %rdx,%rax
}
  8041605063:	48 83 c4 08          	add    $0x8,%rsp
  8041605067:	5b                   	pop    %rbx
  8041605068:	5d                   	pop    %rbp
  8041605069:	c3                   	retq   
    cprintf("accessing %lx\n", (unsigned long)pa);
  804160506a:	48 bf ba e0 60 41 80 	movabs $0x804160e0ba,%rdi
  8041605071:	00 00 00 
  8041605074:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605079:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041605080:	00 00 00 
  8041605083:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041605085:	48 ba f8 d7 60 41 80 	movabs $0x804160d7f8,%rdx
  804160508c:	00 00 00 
  804160508f:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041605094:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  804160509b:	00 00 00 
  804160509e:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050a3:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416050aa:	00 00 00 
  80416050ad:	ff d1                	callq  *%rcx

00000080416050af <tlb_invalidate>:
  if (!curenv || curenv->env_pml4e == pml4e)
  80416050af:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  80416050b6:	00 00 00 
  80416050b9:	48 85 c0             	test   %rax,%rax
  80416050bc:	74 09                	je     80416050c7 <tlb_invalidate+0x18>
  80416050be:	48 39 b8 e8 00 00 00 	cmp    %rdi,0xe8(%rax)
  80416050c5:	75 03                	jne    80416050ca <tlb_invalidate+0x1b>
  __asm __volatile("invlpg (%0)"
  80416050c7:	0f 01 3e             	invlpg (%rsi)
}
  80416050ca:	c3                   	retq   

00000080416050cb <page_remove>:
page_remove(pml4e_t *pml4e, void *va) {
  80416050cb:	55                   	push   %rbp
  80416050cc:	48 89 e5             	mov    %rsp,%rbp
  80416050cf:	41 54                	push   %r12
  80416050d1:	53                   	push   %rbx
  80416050d2:	48 83 ec 10          	sub    $0x10,%rsp
  80416050d6:	48 89 fb             	mov    %rdi,%rbx
  80416050d9:	49 89 f4             	mov    %rsi,%r12
	pp = page_lookup(pml4e, va, &ptep);
  80416050dc:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  80416050e0:	48 b8 05 50 60 41 80 	movabs $0x8041605005,%rax
  80416050e7:	00 00 00 
  80416050ea:	ff d0                	callq  *%rax
	if (pp) {
  80416050ec:	48 85 c0             	test   %rax,%rax
  80416050ef:	74 2c                	je     804160511d <page_remove+0x52>
    page_decref(pp);
  80416050f1:	48 89 c7             	mov    %rax,%rdi
  80416050f4:	48 b8 80 4b 60 41 80 	movabs $0x8041604b80,%rax
  80416050fb:	00 00 00 
  80416050fe:	ff d0                	callq  *%rax
    *ptep = 0;
  8041605100:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8041605104:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    tlb_invalidate(pml4e, va);
  804160510b:	4c 89 e6             	mov    %r12,%rsi
  804160510e:	48 89 df             	mov    %rbx,%rdi
  8041605111:	48 b8 af 50 60 41 80 	movabs $0x80416050af,%rax
  8041605118:	00 00 00 
  804160511b:	ff d0                	callq  *%rax
}
  804160511d:	48 83 c4 10          	add    $0x10,%rsp
  8041605121:	5b                   	pop    %rbx
  8041605122:	41 5c                	pop    %r12
  8041605124:	5d                   	pop    %rbp
  8041605125:	c3                   	retq   

0000008041605126 <page_insert>:
page_insert(pml4e_t *pml4e, struct PageInfo *pp, void *va, int perm) {
  8041605126:	55                   	push   %rbp
  8041605127:	48 89 e5             	mov    %rsp,%rbp
  804160512a:	41 57                	push   %r15
  804160512c:	41 56                	push   %r14
  804160512e:	41 55                	push   %r13
  8041605130:	41 54                	push   %r12
  8041605132:	53                   	push   %rbx
  8041605133:	48 83 ec 08          	sub    $0x8,%rsp
  8041605137:	49 89 fe             	mov    %rdi,%r14
  804160513a:	49 89 f4             	mov    %rsi,%r12
  804160513d:	49 89 d7             	mov    %rdx,%r15
  8041605140:	41 89 cd             	mov    %ecx,%r13d
	ptep = pml4e_walk(pml4e, va, 1);
  8041605143:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605148:	4c 89 fe             	mov    %r15,%rsi
  804160514b:	48 b8 3c 4e 60 41 80 	movabs $0x8041604e3c,%rax
  8041605152:	00 00 00 
  8041605155:	ff d0                	callq  *%rax
	if (ptep == 0) {
  8041605157:	48 85 c0             	test   %rax,%rax
  804160515a:	0f 84 f0 00 00 00    	je     8041605250 <page_insert+0x12a>
  8041605160:	48 89 c3             	mov    %rax,%rbx
	if (*ptep & PTE_P) {
  8041605163:	48 8b 08             	mov    (%rax),%rcx
  8041605166:	f6 c1 01             	test   $0x1,%cl
  8041605169:	0f 84 a1 00 00 00    	je     8041605210 <page_insert+0xea>
		if (PTE_ADDR(*ptep) == page2pa(pp)) {
  804160516f:	48 89 ca             	mov    %rcx,%rdx
  8041605172:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041605179:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605180:	00 00 00 
  8041605183:	4c 89 e6             	mov    %r12,%rsi
  8041605186:	48 2b 30             	sub    (%rax),%rsi
  8041605189:	48 89 f0             	mov    %rsi,%rax
  804160518c:	48 c1 f8 04          	sar    $0x4,%rax
  8041605190:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605194:	48 39 c2             	cmp    %rax,%rdx
  8041605197:	75 1d                	jne    80416051b6 <page_insert+0x90>
      *ptep = (*ptep & 0xfffff000) | perm | PTE_P;
  8041605199:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  804160519f:	4d 63 ed             	movslq %r13d,%r13
  80416051a2:	4c 09 e9             	or     %r13,%rcx
  80416051a5:	48 83 c9 01          	or     $0x1,%rcx
  80416051a9:	48 89 0b             	mov    %rcx,(%rbx)
  return 0;
  80416051ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416051b1:	e9 8b 00 00 00       	jmpq   8041605241 <page_insert+0x11b>
			page_remove(pml4e, va);
  80416051b6:	4c 89 fe             	mov    %r15,%rsi
  80416051b9:	4c 89 f7             	mov    %r14,%rdi
  80416051bc:	48 b8 cb 50 60 41 80 	movabs $0x80416050cb,%rax
  80416051c3:	00 00 00 
  80416051c6:	ff d0                	callq  *%rax
  80416051c8:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  80416051cf:	00 00 00 
  80416051d2:	4c 89 e7             	mov    %r12,%rdi
  80416051d5:	48 2b 38             	sub    (%rax),%rdi
  80416051d8:	48 89 f8             	mov    %rdi,%rax
  80416051db:	48 c1 f8 04          	sar    $0x4,%rax
  80416051df:	48 c1 e0 0c          	shl    $0xc,%rax
			*ptep = page2pa(pp) | perm | PTE_P;
  80416051e3:	4d 63 ed             	movslq %r13d,%r13
  80416051e6:	49 09 c5             	or     %rax,%r13
  80416051e9:	49 83 cd 01          	or     $0x1,%r13
  80416051ed:	4c 89 2b             	mov    %r13,(%rbx)
			pp->pp_ref++;
  80416051f0:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
			tlb_invalidate(pml4e, va);
  80416051f7:	4c 89 fe             	mov    %r15,%rsi
  80416051fa:	4c 89 f7             	mov    %r14,%rdi
  80416051fd:	48 b8 af 50 60 41 80 	movabs $0x80416050af,%rax
  8041605204:	00 00 00 
  8041605207:	ff d0                	callq  *%rax
  return 0;
  8041605209:	b8 00 00 00 00       	mov    $0x0,%eax
  804160520e:	eb 31                	jmp    8041605241 <page_insert+0x11b>
  8041605210:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605217:	00 00 00 
  804160521a:	4c 89 e1             	mov    %r12,%rcx
  804160521d:	48 2b 08             	sub    (%rax),%rcx
  8041605220:	48 c1 f9 04          	sar    $0x4,%rcx
  8041605224:	48 c1 e1 0c          	shl    $0xc,%rcx
		*ptep = page2pa(pp) | perm | PTE_P;
  8041605228:	4d 63 ed             	movslq %r13d,%r13
  804160522b:	4c 09 e9             	or     %r13,%rcx
  804160522e:	48 83 c9 01          	or     $0x1,%rcx
  8041605232:	48 89 0b             	mov    %rcx,(%rbx)
		pp->pp_ref++;
  8041605235:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
  return 0;
  804160523c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041605241:	48 83 c4 08          	add    $0x8,%rsp
  8041605245:	5b                   	pop    %rbx
  8041605246:	41 5c                	pop    %r12
  8041605248:	41 5d                	pop    %r13
  804160524a:	41 5e                	pop    %r14
  804160524c:	41 5f                	pop    %r15
  804160524e:	5d                   	pop    %rbp
  804160524f:	c3                   	retq   
		return -E_NO_MEM;
  8041605250:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8041605255:	eb ea                	jmp    8041605241 <page_insert+0x11b>

0000008041605257 <mem_init>:
mem_init(void) {
  8041605257:	55                   	push   %rbp
  8041605258:	48 89 e5             	mov    %rsp,%rbp
  804160525b:	41 57                	push   %r15
  804160525d:	41 56                	push   %r14
  804160525f:	41 55                	push   %r13
  8041605261:	41 54                	push   %r12
  8041605263:	53                   	push   %rbx
  8041605264:	48 83 ec 38          	sub    $0x38,%rsp
  if (uefi_lp && uefi_lp->MemoryMap) {
  8041605268:	48 a1 00 00 62 41 80 	movabs 0x8041620000,%rax
  804160526f:	00 00 00 
  8041605272:	48 85 c0             	test   %rax,%rax
  8041605275:	74 0d                	je     8041605284 <mem_init+0x2d>
  8041605277:	48 8b 78 28          	mov    0x28(%rax),%rdi
  804160527b:	48 85 ff             	test   %rdi,%rdi
  804160527e:	0f 85 55 11 00 00    	jne    80416063d9 <mem_init+0x1182>
    npages_basemem = (mc146818_read16(NVRAM_BASELO) * 1024) / PGSIZE;
  8041605284:	bf 15 00 00 00       	mov    $0x15,%edi
  8041605289:	49 bc 08 90 60 41 80 	movabs $0x8041609008,%r12
  8041605290:	00 00 00 
  8041605293:	41 ff d4             	callq  *%r12
  8041605296:	c1 e0 0a             	shl    $0xa,%eax
  8041605299:	c1 e8 0c             	shr    $0xc,%eax
  804160529c:	48 ba 18 45 88 41 80 	movabs $0x8041884518,%rdx
  80416052a3:	00 00 00 
  80416052a6:	89 c0                	mov    %eax,%eax
  80416052a8:	48 89 02             	mov    %rax,(%rdx)
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  80416052ab:	bf 17 00 00 00       	mov    $0x17,%edi
  80416052b0:	41 ff d4             	callq  *%r12
  80416052b3:	89 c3                	mov    %eax,%ebx
    pextmem        = ((size_t)mc146818_read16(NVRAM_PEXTLO) * 1024 * 64);
  80416052b5:	bf 34 00 00 00       	mov    $0x34,%edi
  80416052ba:	41 ff d4             	callq  *%r12
  80416052bd:	89 c0                	mov    %eax,%eax
    if (pextmem)
  80416052bf:	48 c1 e0 10          	shl    $0x10,%rax
  80416052c3:	0f 84 87 11 00 00    	je     8041606450 <mem_init+0x11f9>
      npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  80416052c9:	48 05 00 00 f0 00    	add    $0xf00000,%rax
  80416052cf:	48 c1 e8 0c          	shr    $0xc,%rax
  80416052d3:	48 89 c3             	mov    %rax,%rbx
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  80416052d6:	48 8d b3 00 01 00 00 	lea    0x100(%rbx),%rsi
  80416052dd:	48 89 f0             	mov    %rsi,%rax
  80416052e0:	48 a3 50 5a 88 41 80 	movabs %rax,0x8041885a50
  80416052e7:	00 00 00 
          (unsigned long)(npages_extmem * PGSIZE / 1024));
  80416052ea:	48 89 d8             	mov    %rbx,%rax
  80416052ed:	48 c1 e0 0c          	shl    $0xc,%rax
  80416052f1:	48 c1 e8 0a          	shr    $0xa,%rax
  80416052f5:	48 89 c1             	mov    %rax,%rcx
          (unsigned long)(npages_basemem * PGSIZE / 1024),
  80416052f8:	48 b8 18 45 88 41 80 	movabs $0x8041884518,%rax
  80416052ff:	00 00 00 
  8041605302:	48 8b 10             	mov    (%rax),%rdx
  8041605305:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605309:	48 c1 ea 0a          	shr    $0xa,%rdx
          (unsigned long)(npages * PGSIZE / 1024 / 1024),
  804160530d:	48 c1 e6 0c          	shl    $0xc,%rsi
  8041605311:	48 c1 ee 14          	shr    $0x14,%rsi
  cprintf("Physical memory: %luM available, base = %luK, extended = %luK\n",
  8041605315:	48 bf 18 d8 60 41 80 	movabs $0x804160d818,%rdi
  804160531c:	00 00 00 
  804160531f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605324:	49 b8 0d 92 60 41 80 	movabs $0x804160920d,%r8
  804160532b:	00 00 00 
  804160532e:	41 ff d0             	callq  *%r8
  pml4e = boot_alloc(PGSIZE);
  8041605331:	bf 00 10 00 00       	mov    $0x1000,%edi
  8041605336:	48 b8 79 42 60 41 80 	movabs $0x8041604279,%rax
  804160533d:	00 00 00 
  8041605340:	ff d0                	callq  *%rax
  8041605342:	48 89 c3             	mov    %rax,%rbx
  memset(pml4e, 0, PGSIZE);
  8041605345:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160534a:	be 00 00 00 00       	mov    $0x0,%esi
  804160534f:	48 89 c7             	mov    %rax,%rdi
  8041605352:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041605359:	00 00 00 
  804160535c:	ff d0                	callq  *%rax
  kern_pml4e = pml4e;
  804160535e:	48 89 d8             	mov    %rbx,%rax
  8041605361:	48 a3 40 5a 88 41 80 	movabs %rax,0x8041885a40
  8041605368:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  804160536b:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  8041605372:	00 00 00 
  8041605375:	48 39 c3             	cmp    %rax,%rbx
  8041605378:	0f 86 f5 10 00 00    	jbe    8041606473 <mem_init+0x121c>
  return (physaddr_t)kva - KERNBASE;
  804160537e:	48 b8 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rax
  8041605385:	ff ff ff 
  8041605388:	48 01 d8             	add    %rbx,%rax
  kern_cr3   = PADDR(pml4e);
  804160538b:	48 a3 48 5a 88 41 80 	movabs %rax,0x8041885a48
  8041605392:	00 00 00 
  kern_pml4e[PML4(UVPT)] = kern_cr3 | PTE_P | PTE_U;
  8041605395:	48 83 c8 05          	or     $0x5,%rax
  8041605399:	48 89 43 10          	mov    %rax,0x10(%rbx)
  pages = (struct PageInfo *)boot_alloc(sizeof(* pages) * npages);
  804160539d:	48 bb 50 5a 88 41 80 	movabs $0x8041885a50,%rbx
  80416053a4:	00 00 00 
  80416053a7:	8b 3b                	mov    (%rbx),%edi
  80416053a9:	c1 e7 04             	shl    $0x4,%edi
  80416053ac:	49 bc 79 42 60 41 80 	movabs $0x8041604279,%r12
  80416053b3:	00 00 00 
  80416053b6:	41 ff d4             	callq  *%r12
  80416053b9:	48 a3 58 5a 88 41 80 	movabs %rax,0x8041885a58
  80416053c0:	00 00 00 
	memset(pages, 0, sizeof(*pages) * npages);
  80416053c3:	48 8b 13             	mov    (%rbx),%rdx
  80416053c6:	48 c1 e2 04          	shl    $0x4,%rdx
  80416053ca:	be 00 00 00 00       	mov    $0x0,%esi
  80416053cf:	48 89 c7             	mov    %rax,%rdi
  80416053d2:	48 bb b3 c4 60 41 80 	movabs $0x804160c4b3,%rbx
  80416053d9:	00 00 00 
  80416053dc:	ff d3                	callq  *%rbx
  envs = (struct Env *)boot_alloc(sizeof(* envs) * NENV);
  80416053de:	bf 00 80 04 00       	mov    $0x48000,%edi
  80416053e3:	41 ff d4             	callq  *%r12
  80416053e6:	48 a3 28 45 88 41 80 	movabs %rax,0x8041884528
  80416053ed:	00 00 00 
	memset(envs, 0, sizeof(*envs) * NENV);
  80416053f0:	ba 00 80 04 00       	mov    $0x48000,%edx
  80416053f5:	be 00 00 00 00       	mov    $0x0,%esi
  80416053fa:	48 89 c7             	mov    %rax,%rdi
  80416053fd:	ff d3                	callq  *%rbx
  page_init();
  80416053ff:	48 b8 32 48 60 41 80 	movabs $0x8041604832,%rax
  8041605406:	00 00 00 
  8041605409:	ff d0                	callq  *%rax
  check_page_free_list(1);
  804160540b:	bf 01 00 00 00       	mov    $0x1,%edi
  8041605410:	48 b8 61 43 60 41 80 	movabs $0x8041604361,%rax
  8041605417:	00 00 00 
  804160541a:	ff d0                	callq  *%rax
  void *va;
  int i;
  pp0 = pp1 = pp2 = pp3 = pp4 = pp5 = 0;

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  804160541c:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  8041605423:	00 00 00 
  8041605426:	48 8b 18             	mov    (%rax),%rbx
  8041605429:	48 89 5d a8          	mov    %rbx,-0x58(%rbp)
  kern_pml4e[0] = 0;
  804160542d:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  assert(pp0 = page_alloc(0));
  8041605434:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605439:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041605440:	00 00 00 
  8041605443:	ff d0                	callq  *%rax
  8041605445:	49 89 c6             	mov    %rax,%r14
  8041605448:	48 85 c0             	test   %rax,%rax
  804160544b:	0f 84 50 10 00 00    	je     80416064a1 <mem_init+0x124a>
  assert(pp1 = page_alloc(0));
  8041605451:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605456:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  804160545d:	00 00 00 
  8041605460:	ff d0                	callq  *%rax
  8041605462:	49 89 c5             	mov    %rax,%r13
  8041605465:	48 85 c0             	test   %rax,%rax
  8041605468:	0f 84 68 10 00 00    	je     80416064d6 <mem_init+0x127f>
  assert(pp2 = page_alloc(0));
  804160546e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605473:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  804160547a:	00 00 00 
  804160547d:	ff d0                	callq  *%rax
  804160547f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041605483:	48 85 c0             	test   %rax,%rax
  8041605486:	0f 84 7f 10 00 00    	je     804160650b <mem_init+0x12b4>
  assert(pp3 = page_alloc(0));
  804160548c:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605491:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041605498:	00 00 00 
  804160549b:	ff d0                	callq  *%rax
  804160549d:	48 89 c3             	mov    %rax,%rbx
  80416054a0:	48 85 c0             	test   %rax,%rax
  80416054a3:	0f 84 92 10 00 00    	je     804160653b <mem_init+0x12e4>
  assert(pp4 = page_alloc(0));
  80416054a9:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054ae:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  80416054b5:	00 00 00 
  80416054b8:	ff d0                	callq  *%rax
  80416054ba:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  80416054be:	48 85 c0             	test   %rax,%rax
  80416054c1:	0f 84 a9 10 00 00    	je     8041606570 <mem_init+0x1319>
  assert(pp5 = page_alloc(0));
  80416054c7:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054cc:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  80416054d3:	00 00 00 
  80416054d6:	ff d0                	callq  *%rax
  80416054d8:	48 85 c0             	test   %rax,%rax
  80416054db:	0f 84 bf 10 00 00    	je     80416065a0 <mem_init+0x1349>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  80416054e1:	4d 39 ee             	cmp    %r13,%r14
  80416054e4:	0f 84 e6 10 00 00    	je     80416065d0 <mem_init+0x1379>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416054ea:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  80416054ee:	49 39 f5             	cmp    %rsi,%r13
  80416054f1:	0f 84 0e 11 00 00    	je     8041606605 <mem_init+0x13ae>
  80416054f7:	49 39 f6             	cmp    %rsi,%r14
  80416054fa:	0f 84 05 11 00 00    	je     8041606605 <mem_init+0x13ae>
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  8041605500:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  8041605504:	0f 84 30 11 00 00    	je     804160663a <mem_init+0x13e3>
  804160550a:	49 39 dd             	cmp    %rbx,%r13
  804160550d:	0f 84 27 11 00 00    	je     804160663a <mem_init+0x13e3>
  8041605513:	49 39 de             	cmp    %rbx,%r14
  8041605516:	0f 84 1e 11 00 00    	je     804160663a <mem_init+0x13e3>
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  804160551c:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  8041605520:	48 39 fb             	cmp    %rdi,%rbx
  8041605523:	0f 84 46 11 00 00    	je     804160666f <mem_init+0x1418>
  8041605529:	48 39 7d b8          	cmp    %rdi,-0x48(%rbp)
  804160552d:	0f 94 c1             	sete   %cl
  8041605530:	49 39 fd             	cmp    %rdi,%r13
  8041605533:	0f 94 c2             	sete   %dl
  8041605536:	08 d1                	or     %dl,%cl
  8041605538:	0f 85 31 11 00 00    	jne    804160666f <mem_init+0x1418>
  804160553e:	49 39 fe             	cmp    %rdi,%r14
  8041605541:	0f 84 28 11 00 00    	je     804160666f <mem_init+0x1418>
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  8041605547:	48 39 45 b0          	cmp    %rax,-0x50(%rbp)
  804160554b:	0f 84 53 11 00 00    	je     80416066a4 <mem_init+0x144d>
  8041605551:	48 39 c3             	cmp    %rax,%rbx
  8041605554:	0f 84 4a 11 00 00    	je     80416066a4 <mem_init+0x144d>
  804160555a:	48 39 45 b8          	cmp    %rax,-0x48(%rbp)
  804160555e:	0f 84 40 11 00 00    	je     80416066a4 <mem_init+0x144d>
  8041605564:	49 39 c5             	cmp    %rax,%r13
  8041605567:	0f 84 37 11 00 00    	je     80416066a4 <mem_init+0x144d>
  804160556d:	49 39 c6             	cmp    %rax,%r14
  8041605570:	0f 84 2e 11 00 00    	je     80416066a4 <mem_init+0x144d>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
  8041605576:	48 a1 10 45 88 41 80 	movabs 0x8041884510,%rax
  804160557d:	00 00 00 
  8041605580:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  assert(fl != NULL);
  8041605584:	48 85 c0             	test   %rax,%rax
  8041605587:	0f 84 4c 11 00 00    	je     80416066d9 <mem_init+0x1482>
  page_free_list = NULL;
  804160558d:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041605594:	00 00 00 
  8041605597:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // should be no free memory
  assert(!page_alloc(0));
  804160559e:	bf 00 00 00 00       	mov    $0x0,%edi
  80416055a3:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  80416055aa:	00 00 00 
  80416055ad:	ff d0                	callq  *%rax
  80416055af:	48 85 c0             	test   %rax,%rax
  80416055b2:	0f 85 51 11 00 00    	jne    8041606709 <mem_init+0x14b2>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  80416055b8:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  80416055bc:	be 00 00 00 00       	mov    $0x0,%esi
  80416055c1:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416055c8:	00 00 00 
  80416055cb:	48 8b 38             	mov    (%rax),%rdi
  80416055ce:	48 b8 05 50 60 41 80 	movabs $0x8041605005,%rax
  80416055d5:	00 00 00 
  80416055d8:	ff d0                	callq  *%rax
  80416055da:	48 85 c0             	test   %rax,%rax
  80416055dd:	0f 85 5b 11 00 00    	jne    804160673e <mem_init+0x14e7>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  80416055e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416055e8:	ba 00 00 00 00       	mov    $0x0,%edx
  80416055ed:	4c 89 ee             	mov    %r13,%rsi
  80416055f0:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416055f7:	00 00 00 
  80416055fa:	48 8b 38             	mov    (%rax),%rdi
  80416055fd:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041605604:	00 00 00 
  8041605607:	ff d0                	callq  *%rax
  8041605609:	85 c0                	test   %eax,%eax
  804160560b:	0f 89 62 11 00 00    	jns    8041606773 <mem_init+0x151c>

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
  8041605611:	4c 89 f7             	mov    %r14,%rdi
  8041605614:	48 b8 12 4b 60 41 80 	movabs $0x8041604b12,%rax
  804160561b:	00 00 00 
  804160561e:	ff d0                	callq  *%rax
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  8041605620:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605625:	ba 00 00 00 00       	mov    $0x0,%edx
  804160562a:	4c 89 ee             	mov    %r13,%rsi
  804160562d:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605634:	00 00 00 
  8041605637:	48 8b 38             	mov    (%rax),%rdi
  804160563a:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041605641:	00 00 00 
  8041605644:	ff d0                	callq  *%rax
  8041605646:	85 c0                	test   %eax,%eax
  8041605648:	0f 89 5a 11 00 00    	jns    80416067a8 <mem_init+0x1551>
  page_free(pp2);
  804160564e:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605652:	49 bc 12 4b 60 41 80 	movabs $0x8041604b12,%r12
  8041605659:	00 00 00 
  804160565c:	41 ff d4             	callq  *%r12
  page_free(pp3);
  804160565f:	48 89 df             	mov    %rbx,%rdi
  8041605662:	41 ff d4             	callq  *%r12

  //cprintf("pp0 ref count = %d\n",pp0->pp_ref);
  //cprintf("pp2 ref count = %d\n",pp2->pp_ref);
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  8041605665:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160566a:	ba 00 00 00 00       	mov    $0x0,%edx
  804160566f:	4c 89 ee             	mov    %r13,%rsi
  8041605672:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605679:	00 00 00 
  804160567c:	48 8b 38             	mov    (%rax),%rdi
  804160567f:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041605686:	00 00 00 
  8041605689:	ff d0                	callq  *%rax
  804160568b:	85 c0                	test   %eax,%eax
  804160568d:	0f 85 4a 11 00 00    	jne    80416067dd <mem_init+0x1586>
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041605693:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160569a:	00 00 00 
  804160569d:	4c 8b 20             	mov    (%rax),%r12
  80416056a0:	49 8b 14 24          	mov    (%r12),%rdx
  80416056a4:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  80416056ab:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  80416056b2:	00 00 00 
  80416056b5:	4c 8b 38             	mov    (%rax),%r15
  80416056b8:	4c 89 f0             	mov    %r14,%rax
  80416056bb:	4c 29 f8             	sub    %r15,%rax
  80416056be:	48 c1 f8 04          	sar    $0x4,%rax
  80416056c2:	48 c1 e0 0c          	shl    $0xc,%rax
  80416056c6:	48 39 c2             	cmp    %rax,%rdx
  80416056c9:	74 2b                	je     80416056f6 <mem_init+0x49f>
  80416056cb:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416056cf:	4c 29 f8             	sub    %r15,%rax
  80416056d2:	48 c1 f8 04          	sar    $0x4,%rax
  80416056d6:	48 c1 e0 0c          	shl    $0xc,%rax
  80416056da:	48 39 c2             	cmp    %rax,%rdx
  80416056dd:	74 17                	je     80416056f6 <mem_init+0x49f>
  80416056df:	48 89 d8             	mov    %rbx,%rax
  80416056e2:	4c 29 f8             	sub    %r15,%rax
  80416056e5:	48 c1 f8 04          	sar    $0x4,%rax
  80416056e9:	48 c1 e0 0c          	shl    $0xc,%rax
  80416056ed:	48 39 c2             	cmp    %rax,%rdx
  80416056f0:	0f 85 1c 11 00 00    	jne    8041606812 <mem_init+0x15bb>
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  80416056f6:	be 00 00 00 00       	mov    $0x0,%esi
  80416056fb:	4c 89 e7             	mov    %r12,%rdi
  80416056fe:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605705:	00 00 00 
  8041605708:	ff d0                	callq  *%rax
  804160570a:	4c 89 ea             	mov    %r13,%rdx
  804160570d:	4c 29 fa             	sub    %r15,%rdx
  8041605710:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605714:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605718:	48 39 d0             	cmp    %rdx,%rax
  804160571b:	0f 85 26 11 00 00    	jne    8041606847 <mem_init+0x15f0>
  assert(pp1->pp_ref == 1);
  8041605721:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605727:	0f 85 4f 11 00 00    	jne    804160687c <mem_init+0x1625>
  //should be able to map pp3 at PGSIZE because pp0 is already allocated for page table
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  804160572d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605732:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605737:	48 89 de             	mov    %rbx,%rsi
  804160573a:	4c 89 e7             	mov    %r12,%rdi
  804160573d:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041605744:	00 00 00 
  8041605747:	ff d0                	callq  *%rax
  8041605749:	85 c0                	test   %eax,%eax
  804160574b:	0f 85 60 11 00 00    	jne    80416068b1 <mem_init+0x165a>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041605751:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605756:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160575d:	00 00 00 
  8041605760:	48 8b 38             	mov    (%rax),%rdi
  8041605763:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  804160576a:	00 00 00 
  804160576d:	ff d0                	callq  *%rax
  804160576f:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041605776:	00 00 00 
  8041605779:	48 89 d9             	mov    %rbx,%rcx
  804160577c:	48 2b 0a             	sub    (%rdx),%rcx
  804160577f:	48 89 ca             	mov    %rcx,%rdx
  8041605782:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605786:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160578a:	48 39 d0             	cmp    %rdx,%rax
  804160578d:	0f 85 53 11 00 00    	jne    80416068e6 <mem_init+0x168f>
  assert(pp3->pp_ref == 2);
  8041605793:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  8041605798:	0f 85 7d 11 00 00    	jne    804160691b <mem_init+0x16c4>

  // should be no free memory
  assert(!page_alloc(0));
  804160579e:	bf 00 00 00 00       	mov    $0x0,%edi
  80416057a3:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  80416057aa:	00 00 00 
  80416057ad:	ff d0                	callq  *%rax
  80416057af:	48 85 c0             	test   %rax,%rax
  80416057b2:	0f 85 98 11 00 00    	jne    8041606950 <mem_init+0x16f9>

  // should be able to map pp3 at PGSIZE because it's already there
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  80416057b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416057bd:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416057c2:	48 89 de             	mov    %rbx,%rsi
  80416057c5:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416057cc:	00 00 00 
  80416057cf:	48 8b 38             	mov    (%rax),%rdi
  80416057d2:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  80416057d9:	00 00 00 
  80416057dc:	ff d0                	callq  *%rax
  80416057de:	85 c0                	test   %eax,%eax
  80416057e0:	0f 85 9f 11 00 00    	jne    8041606985 <mem_init+0x172e>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416057e6:	be 00 10 00 00       	mov    $0x1000,%esi
  80416057eb:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416057f2:	00 00 00 
  80416057f5:	48 8b 38             	mov    (%rax),%rdi
  80416057f8:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  80416057ff:	00 00 00 
  8041605802:	ff d0                	callq  *%rax
  8041605804:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  804160580b:	00 00 00 
  804160580e:	48 89 d9             	mov    %rbx,%rcx
  8041605811:	48 2b 0a             	sub    (%rdx),%rcx
  8041605814:	48 89 ca             	mov    %rcx,%rdx
  8041605817:	48 c1 fa 04          	sar    $0x4,%rdx
  804160581b:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160581f:	48 39 d0             	cmp    %rdx,%rax
  8041605822:	0f 85 92 11 00 00    	jne    80416069ba <mem_init+0x1763>
  assert(pp3->pp_ref == 2);
  8041605828:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  804160582d:	0f 85 bc 11 00 00    	jne    80416069ef <mem_init+0x1798>

  // pp3 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
  8041605833:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605838:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  804160583f:	00 00 00 
  8041605842:	ff d0                	callq  *%rax
  8041605844:	48 85 c0             	test   %rax,%rax
  8041605847:	0f 85 d7 11 00 00    	jne    8041606a24 <mem_init+0x17cd>
  // check that pgdir_walk returns a pointer to the pte
  pdpe = KADDR(PTE_ADDR(kern_pml4e[PML4(PGSIZE)]));
  804160584d:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605854:	00 00 00 
  8041605857:	48 8b 38             	mov    (%rax),%rdi
  804160585a:	48 8b 0f             	mov    (%rdi),%rcx
  804160585d:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605864:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  804160586b:	00 00 00 
  804160586e:	48 89 ca             	mov    %rcx,%rdx
  8041605871:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605875:	48 39 c2             	cmp    %rax,%rdx
  8041605878:	0f 83 db 11 00 00    	jae    8041606a59 <mem_init+0x1802>
  pde  = KADDR(PTE_ADDR(pdpe[PDPE(PGSIZE)]));
  804160587e:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605885:	00 00 00 
  8041605888:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  804160588c:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605893:	48 89 ca             	mov    %rcx,%rdx
  8041605896:	48 c1 ea 0c          	shr    $0xc,%rdx
  804160589a:	48 39 d0             	cmp    %rdx,%rax
  804160589d:	0f 86 e1 11 00 00    	jbe    8041606a84 <mem_init+0x182d>
  ptep = KADDR(PTE_ADDR(pde[PDX(PGSIZE)]));
  80416058a3:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  80416058aa:	00 00 00 
  80416058ad:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  80416058b1:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416058b8:	48 89 ca             	mov    %rcx,%rdx
  80416058bb:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416058bf:	48 39 d0             	cmp    %rdx,%rax
  80416058c2:	0f 86 e7 11 00 00    	jbe    8041606aaf <mem_init+0x1858>
  return (void *)(pa + KERNBASE);
  80416058c8:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416058cf:	00 00 00 
  80416058d2:	48 01 c1             	add    %rax,%rcx
  80416058d5:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  80416058d9:	ba 00 00 00 00       	mov    $0x0,%edx
  80416058de:	be 00 10 00 00       	mov    $0x1000,%esi
  80416058e3:	48 b8 3c 4e 60 41 80 	movabs $0x8041604e3c,%rax
  80416058ea:	00 00 00 
  80416058ed:	ff d0                	callq  *%rax
  80416058ef:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416058f3:	48 8d 57 08          	lea    0x8(%rdi),%rdx
  80416058f7:	48 39 d0             	cmp    %rdx,%rax
  80416058fa:	0f 85 da 11 00 00    	jne    8041606ada <mem_init+0x1883>

  // should be able to change permissions too.
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  8041605900:	b9 04 00 00 00       	mov    $0x4,%ecx
  8041605905:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160590a:	48 89 de             	mov    %rbx,%rsi
  804160590d:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605914:	00 00 00 
  8041605917:	48 8b 38             	mov    (%rax),%rdi
  804160591a:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041605921:	00 00 00 
  8041605924:	ff d0                	callq  *%rax
  8041605926:	85 c0                	test   %eax,%eax
  8041605928:	0f 85 e1 11 00 00    	jne    8041606b0f <mem_init+0x18b8>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  804160592e:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605935:	00 00 00 
  8041605938:	4c 8b 20             	mov    (%rax),%r12
  804160593b:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605940:	4c 89 e7             	mov    %r12,%rdi
  8041605943:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  804160594a:	00 00 00 
  804160594d:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  804160594f:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041605956:	00 00 00 
  8041605959:	48 89 de             	mov    %rbx,%rsi
  804160595c:	48 2b 32             	sub    (%rdx),%rsi
  804160595f:	48 89 f2             	mov    %rsi,%rdx
  8041605962:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605966:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160596a:	48 39 d0             	cmp    %rdx,%rax
  804160596d:	0f 85 d1 11 00 00    	jne    8041606b44 <mem_init+0x18ed>
  assert(pp3->pp_ref == 2);
  8041605973:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  8041605978:	0f 85 fb 11 00 00    	jne    8041606b79 <mem_init+0x1922>
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  804160597e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605983:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605988:	4c 89 e7             	mov    %r12,%rdi
  804160598b:	48 b8 3c 4e 60 41 80 	movabs $0x8041604e3c,%rax
  8041605992:	00 00 00 
  8041605995:	ff d0                	callq  *%rax
  8041605997:	f6 00 04             	testb  $0x4,(%rax)
  804160599a:	0f 84 0e 12 00 00    	je     8041606bae <mem_init+0x1957>
  assert(kern_pml4e[0] & PTE_U);
  80416059a0:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416059a7:	00 00 00 
  80416059aa:	48 8b 38             	mov    (%rax),%rdi
  80416059ad:	f6 07 04             	testb  $0x4,(%rdi)
  80416059b0:	0f 84 2d 12 00 00    	je     8041606be3 <mem_init+0x198c>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  80416059b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416059bb:	ba 00 00 20 00       	mov    $0x200000,%edx
  80416059c0:	4c 89 f6             	mov    %r14,%rsi
  80416059c3:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  80416059ca:	00 00 00 
  80416059cd:	ff d0                	callq  *%rax
  80416059cf:	85 c0                	test   %eax,%eax
  80416059d1:	0f 89 41 12 00 00    	jns    8041606c18 <mem_init+0x19c1>

  // insert pp1 at PGSIZE (replacing pp3)
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  80416059d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416059dc:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416059e1:	4c 89 ee             	mov    %r13,%rsi
  80416059e4:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416059eb:	00 00 00 
  80416059ee:	48 8b 38             	mov    (%rax),%rdi
  80416059f1:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  80416059f8:	00 00 00 
  80416059fb:	ff d0                	callq  *%rax
  80416059fd:	85 c0                	test   %eax,%eax
  80416059ff:	0f 85 48 12 00 00    	jne    8041606c4d <mem_init+0x19f6>
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041605a05:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605a0a:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605a0f:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605a16:	00 00 00 
  8041605a19:	48 8b 38             	mov    (%rax),%rdi
  8041605a1c:	48 b8 3c 4e 60 41 80 	movabs $0x8041604e3c,%rax
  8041605a23:	00 00 00 
  8041605a26:	ff d0                	callq  *%rax
  8041605a28:	f6 00 04             	testb  $0x4,(%rax)
  8041605a2b:	0f 85 51 12 00 00    	jne    8041606c82 <mem_init+0x1a2b>

  // should have pp1 at both 0 and PGSIZE
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041605a31:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605a38:	00 00 00 
  8041605a3b:	4c 8b 20             	mov    (%rax),%r12
  8041605a3e:	be 00 00 00 00       	mov    $0x0,%esi
  8041605a43:	4c 89 e7             	mov    %r12,%rdi
  8041605a46:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605a4d:	00 00 00 
  8041605a50:	ff d0                	callq  *%rax
  8041605a52:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041605a59:	00 00 00 
  8041605a5c:	4d 89 ef             	mov    %r13,%r15
  8041605a5f:	4c 2b 3a             	sub    (%rdx),%r15
  8041605a62:	49 c1 ff 04          	sar    $0x4,%r15
  8041605a66:	49 c1 e7 0c          	shl    $0xc,%r15
  8041605a6a:	4c 39 f8             	cmp    %r15,%rax
  8041605a6d:	0f 85 44 12 00 00    	jne    8041606cb7 <mem_init+0x1a60>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605a73:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605a78:	4c 89 e7             	mov    %r12,%rdi
  8041605a7b:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605a82:	00 00 00 
  8041605a85:	ff d0                	callq  *%rax
  8041605a87:	49 39 c7             	cmp    %rax,%r15
  8041605a8a:	0f 85 5c 12 00 00    	jne    8041606cec <mem_init+0x1a95>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
  8041605a90:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  8041605a96:	0f 85 85 12 00 00    	jne    8041606d21 <mem_init+0x1aca>
  assert(pp3->pp_ref == 1);
  8041605a9c:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605aa1:	0f 85 af 12 00 00    	jne    8041606d56 <mem_init+0x1aff>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pml4e, 0x0);
  8041605aa7:	be 00 00 00 00       	mov    $0x0,%esi
  8041605aac:	4c 89 e7             	mov    %r12,%rdi
  8041605aaf:	48 b8 cb 50 60 41 80 	movabs $0x80416050cb,%rax
  8041605ab6:	00 00 00 
  8041605ab9:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605abb:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041605ac2:	00 00 00 
  8041605ac5:	4c 8b 20             	mov    (%rax),%r12
  8041605ac8:	be 00 00 00 00       	mov    $0x0,%esi
  8041605acd:	4c 89 e7             	mov    %r12,%rdi
  8041605ad0:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605ad7:	00 00 00 
  8041605ada:	ff d0                	callq  *%rax
  8041605adc:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605ae0:	0f 85 a5 12 00 00    	jne    8041606d8b <mem_init+0x1b34>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605ae6:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605aeb:	4c 89 e7             	mov    %r12,%rdi
  8041605aee:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605af5:	00 00 00 
  8041605af8:	ff d0                	callq  *%rax
  8041605afa:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  8041605b01:	00 00 00 
  8041605b04:	4c 89 e9             	mov    %r13,%rcx
  8041605b07:	48 2b 0a             	sub    (%rdx),%rcx
  8041605b0a:	48 89 ca             	mov    %rcx,%rdx
  8041605b0d:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605b11:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605b15:	48 39 d0             	cmp    %rdx,%rax
  8041605b18:	0f 85 a2 12 00 00    	jne    8041606dc0 <mem_init+0x1b69>
  assert(pp1->pp_ref == 1);
  8041605b1e:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605b24:	0f 85 cb 12 00 00    	jne    8041606df5 <mem_init+0x1b9e>
  assert(pp3->pp_ref == 1);
  8041605b2a:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605b2f:	0f 85 f5 12 00 00    	jne    8041606e2a <mem_init+0x1bd3>

  // Test re-inserting pp1 at PGSIZE.
  // Thanks to Varun Agrawal for suggesting this test case.
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605b35:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605b3a:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605b3f:	4c 89 ee             	mov    %r13,%rsi
  8041605b42:	4c 89 e7             	mov    %r12,%rdi
  8041605b45:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041605b4c:	00 00 00 
  8041605b4f:	ff d0                	callq  *%rax
  8041605b51:	41 89 c4             	mov    %eax,%r12d
  8041605b54:	85 c0                	test   %eax,%eax
  8041605b56:	0f 85 03 13 00 00    	jne    8041606e5f <mem_init+0x1c08>
  assert(pp1->pp_ref);
  8041605b5c:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041605b62:	0f 84 2c 13 00 00    	je     8041606e94 <mem_init+0x1c3d>
  assert(pp1->pp_link == NULL);
  8041605b68:	49 83 7d 00 00       	cmpq   $0x0,0x0(%r13)
  8041605b6d:	0f 85 56 13 00 00    	jne    8041606ec9 <mem_init+0x1c72>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041605b73:	49 bf 40 5a 88 41 80 	movabs $0x8041885a40,%r15
  8041605b7a:	00 00 00 
  8041605b7d:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b82:	49 8b 3f             	mov    (%r15),%rdi
  8041605b85:	48 b8 cb 50 60 41 80 	movabs $0x80416050cb,%rax
  8041605b8c:	00 00 00 
  8041605b8f:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605b91:	4d 8b 3f             	mov    (%r15),%r15
  8041605b94:	be 00 00 00 00       	mov    $0x0,%esi
  8041605b99:	4c 89 ff             	mov    %r15,%rdi
  8041605b9c:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605ba3:	00 00 00 
  8041605ba6:	ff d0                	callq  *%rax
  8041605ba8:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605bac:	0f 85 4c 13 00 00    	jne    8041606efe <mem_init+0x1ca7>
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041605bb2:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605bb7:	4c 89 ff             	mov    %r15,%rdi
  8041605bba:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041605bc1:	00 00 00 
  8041605bc4:	ff d0                	callq  *%rax
  8041605bc6:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605bca:	0f 85 63 13 00 00    	jne    8041606f33 <mem_init+0x1cdc>
  assert(pp1->pp_ref == 0);
  8041605bd0:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041605bd6:	0f 85 8c 13 00 00    	jne    8041606f68 <mem_init+0x1d11>
  assert(pp3->pp_ref == 1);
  8041605bdc:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605be1:	0f 85 b6 13 00 00    	jne    8041606f9d <mem_init+0x1d46>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

  // forcibly take pp3 back
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041605be7:	49 8b 17             	mov    (%r15),%rdx
  8041605bea:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  8041605bf1:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605bf8:	00 00 00 
  8041605bfb:	48 8b 08             	mov    (%rax),%rcx
  8041605bfe:	4c 89 f0             	mov    %r14,%rax
  8041605c01:	48 29 c8             	sub    %rcx,%rax
  8041605c04:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c08:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c0c:	48 39 c2             	cmp    %rax,%rdx
  8041605c0f:	74 2b                	je     8041605c3c <mem_init+0x9e5>
  8041605c11:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605c15:	48 29 c8             	sub    %rcx,%rax
  8041605c18:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c1c:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c20:	48 39 c2             	cmp    %rax,%rdx
  8041605c23:	74 17                	je     8041605c3c <mem_init+0x9e5>
  8041605c25:	48 89 d8             	mov    %rbx,%rax
  8041605c28:	48 29 c8             	sub    %rcx,%rax
  8041605c2b:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c2f:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c33:	48 39 c2             	cmp    %rax,%rdx
  8041605c36:	0f 85 96 13 00 00    	jne    8041606fd2 <mem_init+0x1d7b>
  kern_pml4e[0] = 0;
  8041605c3c:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
  assert(pp3->pp_ref == 1);
  8041605c43:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605c48:	0f 85 b9 13 00 00    	jne    8041607007 <mem_init+0x1db0>
  page_decref(pp3);
  8041605c4e:	48 89 df             	mov    %rbx,%rdi
  8041605c51:	48 bb 80 4b 60 41 80 	movabs $0x8041604b80,%rbx
  8041605c58:	00 00 00 
  8041605c5b:	ff d3                	callq  *%rbx
  // check pointer arithmetic in pml4e_walk
  page_decref(pp0);
  8041605c5d:	4c 89 f7             	mov    %r14,%rdi
  8041605c60:	ff d3                	callq  *%rbx
  page_decref(pp2);
  8041605c62:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605c66:	ff d3                	callq  *%rbx
  va    = (void *)(PGSIZE * 100);
  ptep  = pml4e_walk(kern_pml4e, va, 1);
  8041605c68:	48 bb 40 5a 88 41 80 	movabs $0x8041885a40,%rbx
  8041605c6f:	00 00 00 
  8041605c72:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605c77:	be 00 40 06 00       	mov    $0x64000,%esi
  8041605c7c:	48 8b 3b             	mov    (%rbx),%rdi
  8041605c7f:	48 b8 3c 4e 60 41 80 	movabs $0x8041604e3c,%rax
  8041605c86:	00 00 00 
  8041605c89:	ff d0                	callq  *%rax
  8041605c8b:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  pdpe  = KADDR(PTE_ADDR(kern_pml4e[PML4(va)]));
  8041605c8f:	48 8b 13             	mov    (%rbx),%rdx
  8041605c92:	48 8b 0a             	mov    (%rdx),%rcx
  8041605c95:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605c9c:	48 bb 50 5a 88 41 80 	movabs $0x8041885a50,%rbx
  8041605ca3:	00 00 00 
  8041605ca6:	48 8b 13             	mov    (%rbx),%rdx
  8041605ca9:	48 89 ce             	mov    %rcx,%rsi
  8041605cac:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605cb0:	48 39 d6             	cmp    %rdx,%rsi
  8041605cb3:	0f 83 83 13 00 00    	jae    804160703c <mem_init+0x1de5>
  pde   = KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8041605cb9:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605cc0:	00 00 00 
  8041605cc3:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605cc7:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605cce:	48 89 ce             	mov    %rcx,%rsi
  8041605cd1:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605cd5:	48 39 f2             	cmp    %rsi,%rdx
  8041605cd8:	0f 86 89 13 00 00    	jbe    8041607067 <mem_init+0x1e10>
  ptep1 = KADDR(PTE_ADDR(pde[PDX(va)]));
  8041605cde:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605ce5:	00 00 00 
  8041605ce8:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605cec:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605cf3:	48 89 ce             	mov    %rcx,%rsi
  8041605cf6:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605cfa:	48 39 f2             	cmp    %rsi,%rdx
  8041605cfd:	0f 86 8f 13 00 00    	jbe    8041607092 <mem_init+0x1e3b>
  assert(ptep == ptep1 + PTX(va));
  8041605d03:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605d0a:	00 00 00 
  8041605d0d:	48 8d 94 11 20 03 00 	lea    0x320(%rcx,%rdx,1),%rdx
  8041605d14:	00 
  8041605d15:	48 39 d0             	cmp    %rdx,%rax
  8041605d18:	0f 85 9f 13 00 00    	jne    80416070bd <mem_init+0x1e66>

  // check that new page tables get cleared
  page_decref(pp4);
  8041605d1e:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041605d22:	48 89 df             	mov    %rbx,%rdi
  8041605d25:	48 b8 80 4b 60 41 80 	movabs $0x8041604b80,%rax
  8041605d2c:	00 00 00 
  8041605d2f:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041605d31:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605d38:	00 00 00 
  8041605d3b:	48 2b 18             	sub    (%rax),%rbx
  8041605d3e:	48 89 df             	mov    %rbx,%rdi
  8041605d41:	48 c1 ff 04          	sar    $0x4,%rdi
  8041605d45:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041605d49:	48 89 fa             	mov    %rdi,%rdx
  8041605d4c:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605d50:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041605d57:	00 00 00 
  8041605d5a:	48 3b 10             	cmp    (%rax),%rdx
  8041605d5d:	0f 83 8f 13 00 00    	jae    80416070f2 <mem_init+0x1e9b>
  return (void *)(pa + KERNBASE);
  8041605d63:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041605d6a:	00 00 00 
  8041605d6d:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp4), 0xFF, PGSIZE);
  8041605d70:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605d75:	be ff 00 00 00       	mov    $0xff,%esi
  8041605d7a:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041605d81:	00 00 00 
  8041605d84:	ff d0                	callq  *%rax
  pml4e_walk(kern_pml4e, 0x0, 1);
  8041605d86:	48 bb 40 5a 88 41 80 	movabs $0x8041885a40,%rbx
  8041605d8d:	00 00 00 
  8041605d90:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605d95:	be 00 00 00 00       	mov    $0x0,%esi
  8041605d9a:	48 8b 3b             	mov    (%rbx),%rdi
  8041605d9d:	48 b8 3c 4e 60 41 80 	movabs $0x8041604e3c,%rax
  8041605da4:	00 00 00 
  8041605da7:	ff d0                	callq  *%rax
  pdpe = KADDR(PTE_ADDR(kern_pml4e[0]));
  8041605da9:	48 8b 13             	mov    (%rbx),%rdx
  8041605dac:	48 8b 0a             	mov    (%rdx),%rcx
  8041605daf:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605db6:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041605dbd:	00 00 00 
  8041605dc0:	48 89 ce             	mov    %rcx,%rsi
  8041605dc3:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605dc7:	48 39 c6             	cmp    %rax,%rsi
  8041605dca:	0f 83 50 13 00 00    	jae    8041607120 <mem_init+0x1ec9>
  pde  = KADDR(PTE_ADDR(pdpe[0]));
  8041605dd0:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605dd7:	00 00 00 
  8041605dda:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605dde:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605de5:	48 89 ce             	mov    %rcx,%rsi
  8041605de8:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605dec:	48 39 f0             	cmp    %rsi,%rax
  8041605def:	0f 86 56 13 00 00    	jbe    804160714b <mem_init+0x1ef4>
  ptep = KADDR(PTE_ADDR(pde[0]));
  8041605df5:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605dfc:	00 00 00 
  8041605dff:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605e03:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605e0a:	48 89 ce             	mov    %rcx,%rsi
  8041605e0d:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605e11:	48 39 f0             	cmp    %rsi,%rax
  8041605e14:	0f 86 5c 13 00 00    	jbe    8041607176 <mem_init+0x1f1f>
  return (void *)(pa + KERNBASE);
  8041605e1a:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041605e21:	00 00 00 
  8041605e24:	48 01 c8             	add    %rcx,%rax
  8041605e27:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
  8041605e2b:	f6 00 01             	testb  $0x1,(%rax)
  8041605e2e:	0f 85 6d 13 00 00    	jne    80416071a1 <mem_init+0x1f4a>
  8041605e34:	48 b8 08 00 00 40 80 	movabs $0x8040000008,%rax
  8041605e3b:	00 00 00 
  8041605e3e:	48 01 c8             	add    %rcx,%rax
  8041605e41:	48 be 00 10 00 40 80 	movabs $0x8040001000,%rsi
  8041605e48:	00 00 00 
  8041605e4b:	48 01 f1             	add    %rsi,%rcx
  8041605e4e:	48 8b 18             	mov    (%rax),%rbx
  8041605e51:	83 e3 01             	and    $0x1,%ebx
  8041605e54:	0f 85 47 13 00 00    	jne    80416071a1 <mem_init+0x1f4a>
  for (i = 0; i < NPTENTRIES; i++)
  8041605e5a:	48 83 c0 08          	add    $0x8,%rax
  8041605e5e:	48 39 c8             	cmp    %rcx,%rax
  8041605e61:	75 eb                	jne    8041605e4e <mem_init+0xbf7>
  kern_pml4e[0] = 0;
  8041605e63:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)

  // give free list back
  page_free_list = fl;
  8041605e6a:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041605e6e:	48 a3 10 45 88 41 80 	movabs %rax,0x8041884510
  8041605e75:	00 00 00 

  // free the pages we took
  page_decref(pp0);
  8041605e78:	4c 89 f7             	mov    %r14,%rdi
  8041605e7b:	49 be 80 4b 60 41 80 	movabs $0x8041604b80,%r14
  8041605e82:	00 00 00 
  8041605e85:	41 ff d6             	callq  *%r14
  page_decref(pp1);
  8041605e88:	4c 89 ef             	mov    %r13,%rdi
  8041605e8b:	41 ff d6             	callq  *%r14
  page_decref(pp2);
  8041605e8e:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605e92:	41 ff d6             	callq  *%r14

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041605e95:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  8041605e9c:	00 00 00 
  8041605e9f:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041605ea3:	48 89 38             	mov    %rdi,(%rax)

  cprintf("check_page() succeeded!\n");
  8041605ea6:	48 bf 28 e2 60 41 80 	movabs $0x804160e228,%rdi
  8041605ead:	00 00 00 
  8041605eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605eb5:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041605ebc:	00 00 00 
  8041605ebf:	ff d2                	callq  *%rdx
  if (!pages)
  8041605ec1:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605ec8:	00 00 00 
  8041605ecb:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041605ecf:	0f 84 01 13 00 00    	je     80416071d6 <mem_init+0x1f7f>
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605ed5:	48 a1 10 45 88 41 80 	movabs 0x8041884510,%rax
  8041605edc:	00 00 00 
  8041605edf:	48 85 c0             	test   %rax,%rax
  8041605ee2:	74 0c                	je     8041605ef0 <mem_init+0xc99>
    ++nfree;
  8041605ee4:	41 83 c4 01          	add    $0x1,%r12d
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605ee8:	48 8b 00             	mov    (%rax),%rax
  8041605eeb:	48 85 c0             	test   %rax,%rax
  8041605eee:	75 f4                	jne    8041605ee4 <mem_init+0xc8d>
  assert((pp0 = page_alloc(0)));
  8041605ef0:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605ef5:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041605efc:	00 00 00 
  8041605eff:	ff d0                	callq  *%rax
  8041605f01:	49 89 c5             	mov    %rax,%r13
  8041605f04:	48 85 c0             	test   %rax,%rax
  8041605f07:	0f 84 f3 12 00 00    	je     8041607200 <mem_init+0x1fa9>
  assert((pp1 = page_alloc(0)));
  8041605f0d:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605f12:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041605f19:	00 00 00 
  8041605f1c:	ff d0                	callq  *%rax
  8041605f1e:	49 89 c7             	mov    %rax,%r15
  8041605f21:	48 85 c0             	test   %rax,%rax
  8041605f24:	0f 84 0b 13 00 00    	je     8041607235 <mem_init+0x1fde>
  assert((pp2 = page_alloc(0)));
  8041605f2a:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605f2f:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041605f36:	00 00 00 
  8041605f39:	ff d0                	callq  *%rax
  8041605f3b:	49 89 c6             	mov    %rax,%r14
  8041605f3e:	48 85 c0             	test   %rax,%rax
  8041605f41:	0f 84 23 13 00 00    	je     804160726a <mem_init+0x2013>
  assert(pp1 && pp1 != pp0);
  8041605f47:	4d 39 fd             	cmp    %r15,%r13
  8041605f4a:	0f 84 4f 13 00 00    	je     804160729f <mem_init+0x2048>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041605f50:	49 39 c5             	cmp    %rax,%r13
  8041605f53:	0f 84 7b 13 00 00    	je     80416072d4 <mem_init+0x207d>
  8041605f59:	49 39 c7             	cmp    %rax,%r15
  8041605f5c:	0f 84 72 13 00 00    	je     80416072d4 <mem_init+0x207d>
  return (pp - pages) << PGSHIFT;
  8041605f62:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041605f69:	00 00 00 
  8041605f6c:	48 8b 08             	mov    (%rax),%rcx
  assert(page2pa(pp0) < npages * PGSIZE);
  8041605f6f:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041605f76:	00 00 00 
  8041605f79:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605f7d:	4c 89 ea             	mov    %r13,%rdx
  8041605f80:	48 29 ca             	sub    %rcx,%rdx
  8041605f83:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605f87:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605f8b:	48 39 c2             	cmp    %rax,%rdx
  8041605f8e:	0f 83 75 13 00 00    	jae    8041607309 <mem_init+0x20b2>
  8041605f94:	4c 89 fa             	mov    %r15,%rdx
  8041605f97:	48 29 ca             	sub    %rcx,%rdx
  8041605f9a:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605f9e:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp1) < npages * PGSIZE);
  8041605fa2:	48 39 d0             	cmp    %rdx,%rax
  8041605fa5:	0f 86 93 13 00 00    	jbe    804160733e <mem_init+0x20e7>
  8041605fab:	4c 89 f2             	mov    %r14,%rdx
  8041605fae:	48 29 ca             	sub    %rcx,%rdx
  8041605fb1:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605fb5:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp2) < npages * PGSIZE);
  8041605fb9:	48 39 d0             	cmp    %rdx,%rax
  8041605fbc:	0f 86 b1 13 00 00    	jbe    8041607373 <mem_init+0x211c>
  fl             = page_free_list;
  8041605fc2:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041605fc9:	00 00 00 
  8041605fcc:	48 8b 38             	mov    (%rax),%rdi
  8041605fcf:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  page_free_list = 0;
  8041605fd3:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  assert(!page_alloc(0));
  8041605fda:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605fdf:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041605fe6:	00 00 00 
  8041605fe9:	ff d0                	callq  *%rax
  8041605feb:	48 85 c0             	test   %rax,%rax
  8041605fee:	0f 85 b4 13 00 00    	jne    80416073a8 <mem_init+0x2151>
  page_free(pp0);
  8041605ff4:	4c 89 ef             	mov    %r13,%rdi
  8041605ff7:	49 bd 12 4b 60 41 80 	movabs $0x8041604b12,%r13
  8041605ffe:	00 00 00 
  8041606001:	41 ff d5             	callq  *%r13
  page_free(pp1);
  8041606004:	4c 89 ff             	mov    %r15,%rdi
  8041606007:	41 ff d5             	callq  *%r13
  page_free(pp2);
  804160600a:	4c 89 f7             	mov    %r14,%rdi
  804160600d:	41 ff d5             	callq  *%r13
  assert((pp0 = page_alloc(0)));
  8041606010:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606015:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  804160601c:	00 00 00 
  804160601f:	ff d0                	callq  *%rax
  8041606021:	49 89 c5             	mov    %rax,%r13
  8041606024:	48 85 c0             	test   %rax,%rax
  8041606027:	0f 84 b0 13 00 00    	je     80416073dd <mem_init+0x2186>
  assert((pp1 = page_alloc(0)));
  804160602d:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606032:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041606039:	00 00 00 
  804160603c:	ff d0                	callq  *%rax
  804160603e:	49 89 c7             	mov    %rax,%r15
  8041606041:	48 85 c0             	test   %rax,%rax
  8041606044:	0f 84 c8 13 00 00    	je     8041607412 <mem_init+0x21bb>
  assert((pp2 = page_alloc(0)));
  804160604a:	bf 00 00 00 00       	mov    $0x0,%edi
  804160604f:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041606056:	00 00 00 
  8041606059:	ff d0                	callq  *%rax
  804160605b:	49 89 c6             	mov    %rax,%r14
  804160605e:	48 85 c0             	test   %rax,%rax
  8041606061:	0f 84 e0 13 00 00    	je     8041607447 <mem_init+0x21f0>
  assert(pp1 && pp1 != pp0);
  8041606067:	4d 39 fd             	cmp    %r15,%r13
  804160606a:	0f 84 0c 14 00 00    	je     804160747c <mem_init+0x2225>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041606070:	49 39 c7             	cmp    %rax,%r15
  8041606073:	0f 84 38 14 00 00    	je     80416074b1 <mem_init+0x225a>
  8041606079:	49 39 c5             	cmp    %rax,%r13
  804160607c:	0f 84 2f 14 00 00    	je     80416074b1 <mem_init+0x225a>
  assert(!page_alloc(0));
  8041606082:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606087:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  804160608e:	00 00 00 
  8041606091:	ff d0                	callq  *%rax
  8041606093:	48 85 c0             	test   %rax,%rax
  8041606096:	0f 85 4a 14 00 00    	jne    80416074e6 <mem_init+0x228f>
  804160609c:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  80416060a3:	00 00 00 
  80416060a6:	4c 89 ef             	mov    %r13,%rdi
  80416060a9:	48 2b 38             	sub    (%rax),%rdi
  80416060ac:	48 c1 ff 04          	sar    $0x4,%rdi
  80416060b0:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  80416060b4:	48 89 fa             	mov    %rdi,%rdx
  80416060b7:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416060bb:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  80416060c2:	00 00 00 
  80416060c5:	48 3b 10             	cmp    (%rax),%rdx
  80416060c8:	0f 83 4d 14 00 00    	jae    804160751b <mem_init+0x22c4>
  return (void *)(pa + KERNBASE);
  80416060ce:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  80416060d5:	00 00 00 
  80416060d8:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp0), 1, PGSIZE);
  80416060db:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416060e0:	be 01 00 00 00       	mov    $0x1,%esi
  80416060e5:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  80416060ec:	00 00 00 
  80416060ef:	ff d0                	callq  *%rax
  page_free(pp0);
  80416060f1:	4c 89 ef             	mov    %r13,%rdi
  80416060f4:	48 b8 12 4b 60 41 80 	movabs $0x8041604b12,%rax
  80416060fb:	00 00 00 
  80416060fe:	ff d0                	callq  *%rax
  assert((pp = page_alloc(ALLOC_ZERO)));
  8041606100:	bf 01 00 00 00       	mov    $0x1,%edi
  8041606105:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  804160610c:	00 00 00 
  804160610f:	ff d0                	callq  *%rax
  8041606111:	48 85 c0             	test   %rax,%rax
  8041606114:	0f 84 2f 14 00 00    	je     8041607549 <mem_init+0x22f2>
  assert(pp && pp0 == pp);
  804160611a:	49 39 c5             	cmp    %rax,%r13
  804160611d:	0f 85 56 14 00 00    	jne    8041607579 <mem_init+0x2322>
  return (pp - pages) << PGSHIFT;
  8041606123:	48 ba 58 5a 88 41 80 	movabs $0x8041885a58,%rdx
  804160612a:	00 00 00 
  804160612d:	48 2b 02             	sub    (%rdx),%rax
  8041606130:	48 89 c1             	mov    %rax,%rcx
  8041606133:	48 c1 f9 04          	sar    $0x4,%rcx
  8041606137:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  804160613b:	48 89 ca             	mov    %rcx,%rdx
  804160613e:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041606142:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041606149:	00 00 00 
  804160614c:	48 3b 10             	cmp    (%rax),%rdx
  804160614f:	0f 83 59 14 00 00    	jae    80416075ae <mem_init+0x2357>
    assert(c[i] == 0);
  8041606155:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160615c:	00 00 00 
  804160615f:	80 3c 01 00          	cmpb   $0x0,(%rcx,%rax,1)
  8041606163:	0f 85 70 14 00 00    	jne    80416075d9 <mem_init+0x2382>
  8041606169:	48 8d 40 01          	lea    0x1(%rax),%rax
  804160616d:	48 01 c8             	add    %rcx,%rax
  8041606170:	48 ba 00 10 00 40 80 	movabs $0x8040001000,%rdx
  8041606177:	00 00 00 
  804160617a:	48 01 d1             	add    %rdx,%rcx
  804160617d:	80 38 00             	cmpb   $0x0,(%rax)
  8041606180:	0f 85 53 14 00 00    	jne    80416075d9 <mem_init+0x2382>
  for (i = 0; i < PGSIZE; i++)
  8041606186:	48 83 c0 01          	add    $0x1,%rax
  804160618a:	48 39 c8             	cmp    %rcx,%rax
  804160618d:	75 ee                	jne    804160617d <mem_init+0xf26>
  page_free_list = fl;
  804160618f:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041606196:	00 00 00 
  8041606199:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  804160619d:	48 89 08             	mov    %rcx,(%rax)
  page_free(pp0);
  80416061a0:	4c 89 ef             	mov    %r13,%rdi
  80416061a3:	49 bd 12 4b 60 41 80 	movabs $0x8041604b12,%r13
  80416061aa:	00 00 00 
  80416061ad:	41 ff d5             	callq  *%r13
  page_free(pp1);
  80416061b0:	4c 89 ff             	mov    %r15,%rdi
  80416061b3:	41 ff d5             	callq  *%r13
  page_free(pp2);
  80416061b6:	4c 89 f7             	mov    %r14,%rdi
  80416061b9:	41 ff d5             	callq  *%r13
  for (pp = page_free_list; pp; pp = pp->pp_link)
  80416061bc:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  80416061c3:	00 00 00 
  80416061c6:	48 8b 00             	mov    (%rax),%rax
  80416061c9:	48 85 c0             	test   %rax,%rax
  80416061cc:	74 0c                	je     80416061da <mem_init+0xf83>
    --nfree;
  80416061ce:	41 83 ec 01          	sub    $0x1,%r12d
  for (pp = page_free_list; pp; pp = pp->pp_link)
  80416061d2:	48 8b 00             	mov    (%rax),%rax
  80416061d5:	48 85 c0             	test   %rax,%rax
  80416061d8:	75 f4                	jne    80416061ce <mem_init+0xf77>
  assert(nfree == 0);
  80416061da:	45 85 e4             	test   %r12d,%r12d
  80416061dd:	0f 85 2b 14 00 00    	jne    804160760e <mem_init+0x23b7>
  cprintf("check_page_alloc() succeeded!\n");
  80416061e3:	48 bf 58 dd 60 41 80 	movabs $0x804160dd58,%rdi
  80416061ea:	00 00 00 
  80416061ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416061f2:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416061f9:	00 00 00 
  80416061fc:	ff d2                	callq  *%rdx
  boot_map_region(kern_pml4e, UPAGES, ROUNDUP(npages * sizeof(*pages), PGSIZE), PADDR(pages), PTE_U | PTE_P);
  80416061fe:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041606205:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  8041606208:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160620f:	00 00 00 
  8041606212:	48 39 d0             	cmp    %rdx,%rax
  8041606215:	0f 86 28 14 00 00    	jbe    8041607643 <mem_init+0x23ec>
  return (physaddr_t)kva - KERNBASE;
  804160621b:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  8041606222:	ff ff ff 
  8041606225:	48 01 c1             	add    %rax,%rcx
  8041606228:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  804160622f:	00 00 00 
  8041606232:	48 8b 10             	mov    (%rax),%rdx
  8041606235:	48 c1 e2 04          	shl    $0x4,%rdx
  8041606239:	48 81 c2 ff 0f 00 00 	add    $0xfff,%rdx
  8041606240:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  8041606247:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  804160624d:	48 be 00 e0 42 3c 80 	movabs $0x803c42e000,%rsi
  8041606254:	00 00 00 
  8041606257:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  804160625e:	00 00 00 
  8041606261:	48 8b 38             	mov    (%rax),%rdi
  8041606264:	48 b8 8d 4f 60 41 80 	movabs $0x8041604f8d,%rax
  804160626b:	00 00 00 
  804160626e:	ff d0                	callq  *%rax
  boot_map_region(kern_pml4e, UENVS, ROUNDUP(NENV * sizeof(*envs), PGSIZE), PADDR(envs), PTE_U | PTE_P);
  8041606270:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  8041606277:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  804160627a:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041606281:	00 00 00 
  8041606284:	48 39 d0             	cmp    %rdx,%rax
  8041606287:	0f 86 e4 13 00 00    	jbe    8041607671 <mem_init+0x241a>
  return (physaddr_t)kva - KERNBASE;
  804160628d:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  8041606294:	ff ff ff 
  8041606297:	48 01 c1             	add    %rax,%rcx
  804160629a:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  80416062a0:	ba 00 80 04 00       	mov    $0x48000,%edx
  80416062a5:	48 be 00 e0 22 3c 80 	movabs $0x803c22e000,%rsi
  80416062ac:	00 00 00 
  80416062af:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  80416062b6:	00 00 00 
  80416062b9:	48 8b 38             	mov    (%rax),%rdi
  80416062bc:	48 b8 8d 4f 60 41 80 	movabs $0x8041604f8d,%rax
  80416062c3:	00 00 00 
  80416062c6:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  80416062c8:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  80416062cf:	00 00 00 
  80416062d2:	48 bf 00 00 61 41 80 	movabs $0x8041610000,%rdi
  80416062d9:	00 00 00 
  80416062dc:	48 39 c7             	cmp    %rax,%rdi
  80416062df:	0f 86 ba 13 00 00    	jbe    804160769f <mem_init+0x2448>
  return (physaddr_t)kva - KERNBASE;
  80416062e5:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  80416062ec:	ff ff ff 
  80416062ef:	48 b8 00 00 61 41 80 	movabs $0x8041610000,%rax
  80416062f6:	00 00 00 
  80416062f9:	49 01 c6             	add    %rax,%r14
  boot_map_region(kern_pml4e, KSTACKTOP - KSTKSIZE, KSTACKTOP - (KSTACKTOP - KSTKSIZE), PADDR(bootstack), PTE_W | PTE_P);
  80416062fc:	49 bd 40 5a 88 41 80 	movabs $0x8041885a40,%r13
  8041606303:	00 00 00 
  8041606306:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  804160630c:	4c 89 f1             	mov    %r14,%rcx
  804160630f:	ba 00 00 01 00       	mov    $0x10000,%edx
  8041606314:	48 be 00 00 ff 3f 80 	movabs $0x803fff0000,%rsi
  804160631b:	00 00 00 
  804160631e:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041606322:	49 bc 8d 4f 60 41 80 	movabs $0x8041604f8d,%r12
  8041606329:	00 00 00 
  804160632c:	41 ff d4             	callq  *%r12
  boot_map_region(kern_pml4e, X86ADDR(KSTACKTOP - KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
  804160632f:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606335:	4c 89 f1             	mov    %r14,%rcx
  8041606338:	ba 00 00 01 00       	mov    $0x10000,%edx
  804160633d:	be 00 00 ff 3f       	mov    $0x3fff0000,%esi
  8041606342:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041606346:	41 ff d4             	callq  *%r12
  boot_map_region(kern_pml4e, KERNBASE, npages * PGSIZE, 0, PTE_W | PTE_P);
  8041606349:	49 be 50 5a 88 41 80 	movabs $0x8041885a50,%r14
  8041606350:	00 00 00 
  8041606353:	49 8b 16             	mov    (%r14),%rdx
  8041606356:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160635a:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606360:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041606365:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  804160636c:	00 00 00 
  804160636f:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041606373:	41 ff d4             	callq  *%r12
  size_to_alloc = MIN(0x3200000, npages * PGSIZE);
  8041606376:	49 8b 16             	mov    (%r14),%rdx
  8041606379:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160637d:	48 81 fa 00 00 20 03 	cmp    $0x3200000,%rdx
  8041606384:	b8 00 00 20 03       	mov    $0x3200000,%eax
  8041606389:	48 0f 47 d0          	cmova  %rax,%rdx
  boot_map_region(kern_pml4e, X86ADDR(KERNBASE), size_to_alloc, 0, PTE_P | PTE_W);
  804160638d:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606393:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041606398:	be 00 00 00 40       	mov    $0x40000000,%esi
  804160639d:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  80416063a1:	41 ff d4             	callq  *%r12
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416063a4:	48 b8 f0 44 88 41 80 	movabs $0x80418844f0,%rax
  80416063ab:	00 00 00 
  80416063ae:	4c 8b 20             	mov    (%rax),%r12
  80416063b1:	48 b8 e8 44 88 41 80 	movabs $0x80418844e8,%rax
  80416063b8:	00 00 00 
  80416063bb:	4c 3b 20             	cmp    (%rax),%r12
  80416063be:	0f 83 4a 13 00 00    	jae    804160770e <mem_init+0x24b7>
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  80416063c4:	4d 89 ef             	mov    %r13,%r15
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416063c7:	49 be e0 44 88 41 80 	movabs $0x80418844e0,%r14
  80416063ce:	00 00 00 
  80416063d1:	49 89 c5             	mov    %rax,%r13
  80416063d4:	e9 2b 13 00 00       	jmpq   8041607704 <mem_init+0x24ad>
  mem_map_size     = desc->MemoryMapDescriptorSize;
  80416063d9:	48 8b 70 20          	mov    0x20(%rax),%rsi
  80416063dd:	48 89 c3             	mov    %rax,%rbx
  80416063e0:	48 89 f0             	mov    %rsi,%rax
  80416063e3:	48 a3 e0 44 88 41 80 	movabs %rax,0x80418844e0
  80416063ea:	00 00 00 
  mmap_base        = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)desc->MemoryMap;
  80416063ed:	48 89 fa             	mov    %rdi,%rdx
  80416063f0:	48 89 f8             	mov    %rdi,%rax
  80416063f3:	48 a3 f0 44 88 41 80 	movabs %rax,0x80418844f0
  80416063fa:	00 00 00 
  mmap_end         = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)desc->MemoryMap + desc->MemoryMapSize);
  80416063fd:	48 89 f9             	mov    %rdi,%rcx
  8041606400:	48 03 4b 38          	add    0x38(%rbx),%rcx
  8041606404:	48 89 c8             	mov    %rcx,%rax
  8041606407:	48 a3 e8 44 88 41 80 	movabs %rax,0x80418844e8
  804160640e:	00 00 00 
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606411:	48 39 cf             	cmp    %rcx,%rdi
  8041606414:	73 33                	jae    8041606449 <mem_init+0x11f2>
  size_t num_pages = 0;
  8041606416:	bb 00 00 00 00       	mov    $0x0,%ebx
    num_pages += mmap_curr->NumberOfPages;
  804160641b:	48 03 5a 18          	add    0x18(%rdx),%rbx
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  804160641f:	48 01 f2             	add    %rsi,%rdx
  8041606422:	48 39 d1             	cmp    %rdx,%rcx
  8041606425:	77 f4                	ja     804160641b <mem_init+0x11c4>
  *npages_basemem = num_pages > (IOPHYSMEM / PGSIZE) ? IOPHYSMEM / PGSIZE : num_pages;
  8041606427:	48 81 fb a0 00 00 00 	cmp    $0xa0,%rbx
  804160642e:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041606433:	48 0f 46 d3          	cmovbe %rbx,%rdx
  8041606437:	48 89 d0             	mov    %rdx,%rax
  804160643a:	48 a3 18 45 88 41 80 	movabs %rax,0x8041884518
  8041606441:	00 00 00 
  *npages_extmem  = num_pages - *npages_basemem;
  8041606444:	48 29 d3             	sub    %rdx,%rbx
  8041606447:	eb 0f                	jmp    8041606458 <mem_init+0x1201>
  size_t num_pages = 0;
  8041606449:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160644e:	eb d7                	jmp    8041606427 <mem_init+0x11d0>
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  8041606450:	c1 e3 0a             	shl    $0xa,%ebx
  8041606453:	c1 eb 0c             	shr    $0xc,%ebx
  8041606456:	89 db                	mov    %ebx,%ebx
    npages = npages_basemem;
  8041606458:	48 b8 18 45 88 41 80 	movabs $0x8041884518,%rax
  804160645f:	00 00 00 
  8041606462:	48 8b 30             	mov    (%rax),%rsi
  if (npages_extmem)
  8041606465:	48 85 db             	test   %rbx,%rbx
  8041606468:	0f 84 6f ee ff ff    	je     80416052dd <mem_init+0x86>
  804160646e:	e9 63 ee ff ff       	jmpq   80416052d6 <mem_init+0x7f>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041606473:	48 89 d9             	mov    %rbx,%rcx
  8041606476:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  804160647d:	00 00 00 
  8041606480:	be ea 00 00 00       	mov    $0xea,%esi
  8041606485:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160648c:	00 00 00 
  804160648f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606494:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160649b:	00 00 00 
  804160649e:	41 ff d0             	callq  *%r8
  assert(pp0 = page_alloc(0));
  80416064a1:	48 b9 c9 e0 60 41 80 	movabs $0x804160e0c9,%rcx
  80416064a8:	00 00 00 
  80416064ab:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416064b2:	00 00 00 
  80416064b5:	be a0 04 00 00       	mov    $0x4a0,%esi
  80416064ba:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416064c1:	00 00 00 
  80416064c4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416064c9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416064d0:	00 00 00 
  80416064d3:	41 ff d0             	callq  *%r8
  assert(pp1 = page_alloc(0));
  80416064d6:	48 b9 dd e0 60 41 80 	movabs $0x804160e0dd,%rcx
  80416064dd:	00 00 00 
  80416064e0:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416064e7:	00 00 00 
  80416064ea:	be a1 04 00 00       	mov    $0x4a1,%esi
  80416064ef:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416064f6:	00 00 00 
  80416064f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416064fe:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606505:	00 00 00 
  8041606508:	41 ff d0             	callq  *%r8
  assert(pp2 = page_alloc(0));
  804160650b:	48 b9 f1 e0 60 41 80 	movabs $0x804160e0f1,%rcx
  8041606512:	00 00 00 
  8041606515:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160651c:	00 00 00 
  804160651f:	be a2 04 00 00       	mov    $0x4a2,%esi
  8041606524:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160652b:	00 00 00 
  804160652e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606535:	00 00 00 
  8041606538:	41 ff d0             	callq  *%r8
  assert(pp3 = page_alloc(0));
  804160653b:	48 b9 05 e1 60 41 80 	movabs $0x804160e105,%rcx
  8041606542:	00 00 00 
  8041606545:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160654c:	00 00 00 
  804160654f:	be a3 04 00 00       	mov    $0x4a3,%esi
  8041606554:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160655b:	00 00 00 
  804160655e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606563:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160656a:	00 00 00 
  804160656d:	41 ff d0             	callq  *%r8
  assert(pp4 = page_alloc(0));
  8041606570:	48 b9 19 e1 60 41 80 	movabs $0x804160e119,%rcx
  8041606577:	00 00 00 
  804160657a:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606581:	00 00 00 
  8041606584:	be a4 04 00 00       	mov    $0x4a4,%esi
  8041606589:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606590:	00 00 00 
  8041606593:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160659a:	00 00 00 
  804160659d:	41 ff d0             	callq  *%r8
  assert(pp5 = page_alloc(0));
  80416065a0:	48 b9 2d e1 60 41 80 	movabs $0x804160e12d,%rcx
  80416065a7:	00 00 00 
  80416065aa:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416065b1:	00 00 00 
  80416065b4:	be a5 04 00 00       	mov    $0x4a5,%esi
  80416065b9:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416065c0:	00 00 00 
  80416065c3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065ca:	00 00 00 
  80416065cd:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  80416065d0:	48 b9 41 e1 60 41 80 	movabs $0x804160e141,%rcx
  80416065d7:	00 00 00 
  80416065da:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416065e1:	00 00 00 
  80416065e4:	be a8 04 00 00       	mov    $0x4a8,%esi
  80416065e9:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416065f0:	00 00 00 
  80416065f3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416065f8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065ff:	00 00 00 
  8041606602:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041606605:	48 b9 58 d8 60 41 80 	movabs $0x804160d858,%rcx
  804160660c:	00 00 00 
  804160660f:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606616:	00 00 00 
  8041606619:	be a9 04 00 00       	mov    $0x4a9,%esi
  804160661e:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606625:	00 00 00 
  8041606628:	b8 00 00 00 00       	mov    $0x0,%eax
  804160662d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606634:	00 00 00 
  8041606637:	41 ff d0             	callq  *%r8
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  804160663a:	48 b9 78 d8 60 41 80 	movabs $0x804160d878,%rcx
  8041606641:	00 00 00 
  8041606644:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160664b:	00 00 00 
  804160664e:	be aa 04 00 00       	mov    $0x4aa,%esi
  8041606653:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160665a:	00 00 00 
  804160665d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606662:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606669:	00 00 00 
  804160666c:	41 ff d0             	callq  *%r8
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  804160666f:	48 b9 a8 d8 60 41 80 	movabs $0x804160d8a8,%rcx
  8041606676:	00 00 00 
  8041606679:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606680:	00 00 00 
  8041606683:	be ab 04 00 00       	mov    $0x4ab,%esi
  8041606688:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160668f:	00 00 00 
  8041606692:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606697:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160669e:	00 00 00 
  80416066a1:	41 ff d0             	callq  *%r8
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  80416066a4:	48 b9 e8 d8 60 41 80 	movabs $0x804160d8e8,%rcx
  80416066ab:	00 00 00 
  80416066ae:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416066b5:	00 00 00 
  80416066b8:	be ac 04 00 00       	mov    $0x4ac,%esi
  80416066bd:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416066c4:	00 00 00 
  80416066c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066cc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066d3:	00 00 00 
  80416066d6:	41 ff d0             	callq  *%r8
  assert(fl != NULL);
  80416066d9:	48 b9 53 e1 60 41 80 	movabs $0x804160e153,%rcx
  80416066e0:	00 00 00 
  80416066e3:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416066ea:	00 00 00 
  80416066ed:	be b0 04 00 00       	mov    $0x4b0,%esi
  80416066f2:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416066f9:	00 00 00 
  80416066fc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606703:	00 00 00 
  8041606706:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606709:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  8041606710:	00 00 00 
  8041606713:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160671a:	00 00 00 
  804160671d:	be b4 04 00 00       	mov    $0x4b4,%esi
  8041606722:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606729:	00 00 00 
  804160672c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606731:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606738:	00 00 00 
  804160673b:	41 ff d0             	callq  *%r8
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  804160673e:	48 b9 38 d9 60 41 80 	movabs $0x804160d938,%rcx
  8041606745:	00 00 00 
  8041606748:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160674f:	00 00 00 
  8041606752:	be b7 04 00 00       	mov    $0x4b7,%esi
  8041606757:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160675e:	00 00 00 
  8041606761:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606766:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160676d:	00 00 00 
  8041606770:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  8041606773:	48 b9 70 d9 60 41 80 	movabs $0x804160d970,%rcx
  804160677a:	00 00 00 
  804160677d:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606784:	00 00 00 
  8041606787:	be ba 04 00 00       	mov    $0x4ba,%esi
  804160678c:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606793:	00 00 00 
  8041606796:	b8 00 00 00 00       	mov    $0x0,%eax
  804160679b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067a2:	00 00 00 
  80416067a5:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  80416067a8:	48 b9 70 d9 60 41 80 	movabs $0x804160d970,%rcx
  80416067af:	00 00 00 
  80416067b2:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416067b9:	00 00 00 
  80416067bc:	be be 04 00 00       	mov    $0x4be,%esi
  80416067c1:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416067c8:	00 00 00 
  80416067cb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067d0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067d7:	00 00 00 
  80416067da:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  80416067dd:	48 b9 a0 d9 60 41 80 	movabs $0x804160d9a0,%rcx
  80416067e4:	00 00 00 
  80416067e7:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416067ee:	00 00 00 
  80416067f1:	be c4 04 00 00       	mov    $0x4c4,%esi
  80416067f6:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416067fd:	00 00 00 
  8041606800:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606805:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160680c:	00 00 00 
  804160680f:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041606812:	48 b9 d0 d9 60 41 80 	movabs $0x804160d9d0,%rcx
  8041606819:	00 00 00 
  804160681c:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606823:	00 00 00 
  8041606826:	be c5 04 00 00       	mov    $0x4c5,%esi
  804160682b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606832:	00 00 00 
  8041606835:	b8 00 00 00 00       	mov    $0x0,%eax
  804160683a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606841:	00 00 00 
  8041606844:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  8041606847:	48 b9 50 da 60 41 80 	movabs $0x804160da50,%rcx
  804160684e:	00 00 00 
  8041606851:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606858:	00 00 00 
  804160685b:	be c6 04 00 00       	mov    $0x4c6,%esi
  8041606860:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606867:	00 00 00 
  804160686a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160686f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606876:	00 00 00 
  8041606879:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  804160687c:	48 b9 6d e1 60 41 80 	movabs $0x804160e16d,%rcx
  8041606883:	00 00 00 
  8041606886:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160688d:	00 00 00 
  8041606890:	be c7 04 00 00       	mov    $0x4c7,%esi
  8041606895:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160689c:	00 00 00 
  804160689f:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068a4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068ab:	00 00 00 
  80416068ae:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  80416068b1:	48 b9 80 da 60 41 80 	movabs $0x804160da80,%rcx
  80416068b8:	00 00 00 
  80416068bb:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416068c2:	00 00 00 
  80416068c5:	be c9 04 00 00       	mov    $0x4c9,%esi
  80416068ca:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416068d1:	00 00 00 
  80416068d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068d9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068e0:	00 00 00 
  80416068e3:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416068e6:	48 b9 b8 da 60 41 80 	movabs $0x804160dab8,%rcx
  80416068ed:	00 00 00 
  80416068f0:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416068f7:	00 00 00 
  80416068fa:	be ca 04 00 00       	mov    $0x4ca,%esi
  80416068ff:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606906:	00 00 00 
  8041606909:	b8 00 00 00 00       	mov    $0x0,%eax
  804160690e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606915:	00 00 00 
  8041606918:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  804160691b:	48 b9 7e e1 60 41 80 	movabs $0x804160e17e,%rcx
  8041606922:	00 00 00 
  8041606925:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160692c:	00 00 00 
  804160692f:	be cb 04 00 00       	mov    $0x4cb,%esi
  8041606934:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160693b:	00 00 00 
  804160693e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606943:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160694a:	00 00 00 
  804160694d:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606950:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  8041606957:	00 00 00 
  804160695a:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606961:	00 00 00 
  8041606964:	be ce 04 00 00       	mov    $0x4ce,%esi
  8041606969:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606970:	00 00 00 
  8041606973:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606978:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160697f:	00 00 00 
  8041606982:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041606985:	48 b9 80 da 60 41 80 	movabs $0x804160da80,%rcx
  804160698c:	00 00 00 
  804160698f:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606996:	00 00 00 
  8041606999:	be d1 04 00 00       	mov    $0x4d1,%esi
  804160699e:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416069a5:	00 00 00 
  80416069a8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069ad:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069b4:	00 00 00 
  80416069b7:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416069ba:	48 b9 b8 da 60 41 80 	movabs $0x804160dab8,%rcx
  80416069c1:	00 00 00 
  80416069c4:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416069cb:	00 00 00 
  80416069ce:	be d2 04 00 00       	mov    $0x4d2,%esi
  80416069d3:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416069da:	00 00 00 
  80416069dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069e2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069e9:	00 00 00 
  80416069ec:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  80416069ef:	48 b9 7e e1 60 41 80 	movabs $0x804160e17e,%rcx
  80416069f6:	00 00 00 
  80416069f9:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606a00:	00 00 00 
  8041606a03:	be d3 04 00 00       	mov    $0x4d3,%esi
  8041606a08:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606a0f:	00 00 00 
  8041606a12:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a17:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a1e:	00 00 00 
  8041606a21:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606a24:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  8041606a2b:	00 00 00 
  8041606a2e:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606a35:	00 00 00 
  8041606a38:	be d7 04 00 00       	mov    $0x4d7,%esi
  8041606a3d:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606a44:	00 00 00 
  8041606a47:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a4c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a53:	00 00 00 
  8041606a56:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041606a59:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041606a60:	00 00 00 
  8041606a63:	be d9 04 00 00       	mov    $0x4d9,%esi
  8041606a68:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606a6f:	00 00 00 
  8041606a72:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a77:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a7e:	00 00 00 
  8041606a81:	41 ff d0             	callq  *%r8
  8041606a84:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041606a8b:	00 00 00 
  8041606a8e:	be da 04 00 00       	mov    $0x4da,%esi
  8041606a93:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606a9a:	00 00 00 
  8041606a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606aa2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606aa9:	00 00 00 
  8041606aac:	41 ff d0             	callq  *%r8
  8041606aaf:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041606ab6:	00 00 00 
  8041606ab9:	be db 04 00 00       	mov    $0x4db,%esi
  8041606abe:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606ac5:	00 00 00 
  8041606ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606acd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ad4:	00 00 00 
  8041606ad7:	41 ff d0             	callq  *%r8
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  8041606ada:	48 b9 e8 da 60 41 80 	movabs $0x804160dae8,%rcx
  8041606ae1:	00 00 00 
  8041606ae4:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606aeb:	00 00 00 
  8041606aee:	be dc 04 00 00       	mov    $0x4dc,%esi
  8041606af3:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606afa:	00 00 00 
  8041606afd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b02:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b09:	00 00 00 
  8041606b0c:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  8041606b0f:	48 b9 28 db 60 41 80 	movabs $0x804160db28,%rcx
  8041606b16:	00 00 00 
  8041606b19:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606b20:	00 00 00 
  8041606b23:	be df 04 00 00       	mov    $0x4df,%esi
  8041606b28:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606b2f:	00 00 00 
  8041606b32:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b37:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b3e:	00 00 00 
  8041606b41:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606b44:	48 b9 b8 da 60 41 80 	movabs $0x804160dab8,%rcx
  8041606b4b:	00 00 00 
  8041606b4e:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606b55:	00 00 00 
  8041606b58:	be e0 04 00 00       	mov    $0x4e0,%esi
  8041606b5d:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606b64:	00 00 00 
  8041606b67:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b6c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b73:	00 00 00 
  8041606b76:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606b79:	48 b9 7e e1 60 41 80 	movabs $0x804160e17e,%rcx
  8041606b80:	00 00 00 
  8041606b83:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606b8a:	00 00 00 
  8041606b8d:	be e1 04 00 00       	mov    $0x4e1,%esi
  8041606b92:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606b99:	00 00 00 
  8041606b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ba1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ba8:	00 00 00 
  8041606bab:	41 ff d0             	callq  *%r8
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041606bae:	48 b9 68 db 60 41 80 	movabs $0x804160db68,%rcx
  8041606bb5:	00 00 00 
  8041606bb8:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606bbf:	00 00 00 
  8041606bc2:	be e2 04 00 00       	mov    $0x4e2,%esi
  8041606bc7:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606bce:	00 00 00 
  8041606bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bd6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606bdd:	00 00 00 
  8041606be0:	41 ff d0             	callq  *%r8
  assert(kern_pml4e[0] & PTE_U);
  8041606be3:	48 b9 8f e1 60 41 80 	movabs $0x804160e18f,%rcx
  8041606bea:	00 00 00 
  8041606bed:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606bf4:	00 00 00 
  8041606bf7:	be e3 04 00 00       	mov    $0x4e3,%esi
  8041606bfc:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606c03:	00 00 00 
  8041606c06:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c0b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c12:	00 00 00 
  8041606c15:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041606c18:	48 b9 a0 db 60 41 80 	movabs $0x804160dba0,%rcx
  8041606c1f:	00 00 00 
  8041606c22:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606c29:	00 00 00 
  8041606c2c:	be e6 04 00 00       	mov    $0x4e6,%esi
  8041606c31:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606c38:	00 00 00 
  8041606c3b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c40:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c47:	00 00 00 
  8041606c4a:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606c4d:	48 b9 d8 db 60 41 80 	movabs $0x804160dbd8,%rcx
  8041606c54:	00 00 00 
  8041606c57:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606c5e:	00 00 00 
  8041606c61:	be e9 04 00 00       	mov    $0x4e9,%esi
  8041606c66:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606c6d:	00 00 00 
  8041606c70:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c75:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c7c:	00 00 00 
  8041606c7f:	41 ff d0             	callq  *%r8
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041606c82:	48 b9 10 dc 60 41 80 	movabs $0x804160dc10,%rcx
  8041606c89:	00 00 00 
  8041606c8c:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606c93:	00 00 00 
  8041606c96:	be ea 04 00 00       	mov    $0x4ea,%esi
  8041606c9b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606ca2:	00 00 00 
  8041606ca5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606caa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606cb1:	00 00 00 
  8041606cb4:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041606cb7:	48 b9 48 dc 60 41 80 	movabs $0x804160dc48,%rcx
  8041606cbe:	00 00 00 
  8041606cc1:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606cc8:	00 00 00 
  8041606ccb:	be ed 04 00 00       	mov    $0x4ed,%esi
  8041606cd0:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606cd7:	00 00 00 
  8041606cda:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606cdf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ce6:	00 00 00 
  8041606ce9:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606cec:	48 b9 78 dc 60 41 80 	movabs $0x804160dc78,%rcx
  8041606cf3:	00 00 00 
  8041606cf6:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606cfd:	00 00 00 
  8041606d00:	be ee 04 00 00       	mov    $0x4ee,%esi
  8041606d05:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606d0c:	00 00 00 
  8041606d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d14:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d1b:	00 00 00 
  8041606d1e:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 2);
  8041606d21:	48 b9 a5 e1 60 41 80 	movabs $0x804160e1a5,%rcx
  8041606d28:	00 00 00 
  8041606d2b:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606d32:	00 00 00 
  8041606d35:	be f0 04 00 00       	mov    $0x4f0,%esi
  8041606d3a:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606d41:	00 00 00 
  8041606d44:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d49:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d50:	00 00 00 
  8041606d53:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606d56:	48 b9 b6 e1 60 41 80 	movabs $0x804160e1b6,%rcx
  8041606d5d:	00 00 00 
  8041606d60:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606d67:	00 00 00 
  8041606d6a:	be f1 04 00 00       	mov    $0x4f1,%esi
  8041606d6f:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606d76:	00 00 00 
  8041606d79:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d7e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d85:	00 00 00 
  8041606d88:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606d8b:	48 b9 a8 dc 60 41 80 	movabs $0x804160dca8,%rcx
  8041606d92:	00 00 00 
  8041606d95:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606d9c:	00 00 00 
  8041606d9f:	be f5 04 00 00       	mov    $0x4f5,%esi
  8041606da4:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606dab:	00 00 00 
  8041606dae:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606db3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606dba:	00 00 00 
  8041606dbd:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606dc0:	48 b9 78 dc 60 41 80 	movabs $0x804160dc78,%rcx
  8041606dc7:	00 00 00 
  8041606dca:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606dd1:	00 00 00 
  8041606dd4:	be f6 04 00 00       	mov    $0x4f6,%esi
  8041606dd9:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606de0:	00 00 00 
  8041606de3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606de8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606def:	00 00 00 
  8041606df2:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041606df5:	48 b9 6d e1 60 41 80 	movabs $0x804160e16d,%rcx
  8041606dfc:	00 00 00 
  8041606dff:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606e06:	00 00 00 
  8041606e09:	be f7 04 00 00       	mov    $0x4f7,%esi
  8041606e0e:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606e15:	00 00 00 
  8041606e18:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e1d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e24:	00 00 00 
  8041606e27:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606e2a:	48 b9 b6 e1 60 41 80 	movabs $0x804160e1b6,%rcx
  8041606e31:	00 00 00 
  8041606e34:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606e3b:	00 00 00 
  8041606e3e:	be f8 04 00 00       	mov    $0x4f8,%esi
  8041606e43:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606e4a:	00 00 00 
  8041606e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e52:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e59:	00 00 00 
  8041606e5c:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606e5f:	48 b9 d8 db 60 41 80 	movabs $0x804160dbd8,%rcx
  8041606e66:	00 00 00 
  8041606e69:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606e70:	00 00 00 
  8041606e73:	be fc 04 00 00       	mov    $0x4fc,%esi
  8041606e78:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606e7f:	00 00 00 
  8041606e82:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e87:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e8e:	00 00 00 
  8041606e91:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref);
  8041606e94:	48 b9 c7 e1 60 41 80 	movabs $0x804160e1c7,%rcx
  8041606e9b:	00 00 00 
  8041606e9e:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606ea5:	00 00 00 
  8041606ea8:	be fd 04 00 00       	mov    $0x4fd,%esi
  8041606ead:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606eb4:	00 00 00 
  8041606eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ebc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ec3:	00 00 00 
  8041606ec6:	41 ff d0             	callq  *%r8
  assert(pp1->pp_link == NULL);
  8041606ec9:	48 b9 d3 e1 60 41 80 	movabs $0x804160e1d3,%rcx
  8041606ed0:	00 00 00 
  8041606ed3:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606eda:	00 00 00 
  8041606edd:	be fe 04 00 00       	mov    $0x4fe,%esi
  8041606ee2:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606ee9:	00 00 00 
  8041606eec:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ef1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ef8:	00 00 00 
  8041606efb:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606efe:	48 b9 a8 dc 60 41 80 	movabs $0x804160dca8,%rcx
  8041606f05:	00 00 00 
  8041606f08:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606f0f:	00 00 00 
  8041606f12:	be 02 05 00 00       	mov    $0x502,%esi
  8041606f17:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606f1e:	00 00 00 
  8041606f21:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f26:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f2d:	00 00 00 
  8041606f30:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041606f33:	48 b9 d0 dc 60 41 80 	movabs $0x804160dcd0,%rcx
  8041606f3a:	00 00 00 
  8041606f3d:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606f44:	00 00 00 
  8041606f47:	be 03 05 00 00       	mov    $0x503,%esi
  8041606f4c:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606f53:	00 00 00 
  8041606f56:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f5b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f62:	00 00 00 
  8041606f65:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041606f68:	48 b9 e8 e1 60 41 80 	movabs $0x804160e1e8,%rcx
  8041606f6f:	00 00 00 
  8041606f72:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606f79:	00 00 00 
  8041606f7c:	be 04 05 00 00       	mov    $0x504,%esi
  8041606f81:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606f88:	00 00 00 
  8041606f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f90:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f97:	00 00 00 
  8041606f9a:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606f9d:	48 b9 b6 e1 60 41 80 	movabs $0x804160e1b6,%rcx
  8041606fa4:	00 00 00 
  8041606fa7:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606fae:	00 00 00 
  8041606fb1:	be 05 05 00 00       	mov    $0x505,%esi
  8041606fb6:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606fbd:	00 00 00 
  8041606fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606fc5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606fcc:	00 00 00 
  8041606fcf:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041606fd2:	48 b9 d0 d9 60 41 80 	movabs $0x804160d9d0,%rcx
  8041606fd9:	00 00 00 
  8041606fdc:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041606fe3:	00 00 00 
  8041606fe6:	be 18 05 00 00       	mov    $0x518,%esi
  8041606feb:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041606ff2:	00 00 00 
  8041606ff5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ffa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607001:	00 00 00 
  8041607004:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041607007:	48 b9 b6 e1 60 41 80 	movabs $0x804160e1b6,%rcx
  804160700e:	00 00 00 
  8041607011:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607018:	00 00 00 
  804160701b:	be 1a 05 00 00       	mov    $0x51a,%esi
  8041607020:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607027:	00 00 00 
  804160702a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160702f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607036:	00 00 00 
  8041607039:	41 ff d0             	callq  *%r8
  804160703c:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607043:	00 00 00 
  8041607046:	be 21 05 00 00       	mov    $0x521,%esi
  804160704b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607052:	00 00 00 
  8041607055:	b8 00 00 00 00       	mov    $0x0,%eax
  804160705a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607061:	00 00 00 
  8041607064:	41 ff d0             	callq  *%r8
  8041607067:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160706e:	00 00 00 
  8041607071:	be 22 05 00 00       	mov    $0x522,%esi
  8041607076:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160707d:	00 00 00 
  8041607080:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607085:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160708c:	00 00 00 
  804160708f:	41 ff d0             	callq  *%r8
  8041607092:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607099:	00 00 00 
  804160709c:	be 23 05 00 00       	mov    $0x523,%esi
  80416070a1:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416070a8:	00 00 00 
  80416070ab:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070b0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070b7:	00 00 00 
  80416070ba:	41 ff d0             	callq  *%r8
  assert(ptep == ptep1 + PTX(va));
  80416070bd:	48 b9 f9 e1 60 41 80 	movabs $0x804160e1f9,%rcx
  80416070c4:	00 00 00 
  80416070c7:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416070ce:	00 00 00 
  80416070d1:	be 24 05 00 00       	mov    $0x524,%esi
  80416070d6:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416070dd:	00 00 00 
  80416070e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070e5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070ec:	00 00 00 
  80416070ef:	41 ff d0             	callq  *%r8
  80416070f2:	48 89 f9             	mov    %rdi,%rcx
  80416070f5:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  80416070fc:	00 00 00 
  80416070ff:	be 61 00 00 00       	mov    $0x61,%esi
  8041607104:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  804160710b:	00 00 00 
  804160710e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607113:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160711a:	00 00 00 
  804160711d:	41 ff d0             	callq  *%r8
  8041607120:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607127:	00 00 00 
  804160712a:	be 2a 05 00 00       	mov    $0x52a,%esi
  804160712f:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607136:	00 00 00 
  8041607139:	b8 00 00 00 00       	mov    $0x0,%eax
  804160713e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607145:	00 00 00 
  8041607148:	41 ff d0             	callq  *%r8
  804160714b:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607152:	00 00 00 
  8041607155:	be 2b 05 00 00       	mov    $0x52b,%esi
  804160715a:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607161:	00 00 00 
  8041607164:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607169:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607170:	00 00 00 
  8041607173:	41 ff d0             	callq  *%r8
  8041607176:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160717d:	00 00 00 
  8041607180:	be 2c 05 00 00       	mov    $0x52c,%esi
  8041607185:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160718c:	00 00 00 
  804160718f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607194:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160719b:	00 00 00 
  804160719e:	41 ff d0             	callq  *%r8
    assert((ptep[i] & PTE_P) == 0);
  80416071a1:	48 b9 11 e2 60 41 80 	movabs $0x804160e211,%rcx
  80416071a8:	00 00 00 
  80416071ab:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416071b2:	00 00 00 
  80416071b5:	be 2e 05 00 00       	mov    $0x52e,%esi
  80416071ba:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416071c1:	00 00 00 
  80416071c4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071c9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071d0:	00 00 00 
  80416071d3:	41 ff d0             	callq  *%r8
    panic("'pages' is a null pointer!");
  80416071d6:	48 ba 41 e2 60 41 80 	movabs $0x804160e241,%rdx
  80416071dd:	00 00 00 
  80416071e0:	be f5 03 00 00       	mov    $0x3f5,%esi
  80416071e5:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416071ec:	00 00 00 
  80416071ef:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071f4:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416071fb:	00 00 00 
  80416071fe:	ff d1                	callq  *%rcx
  assert((pp0 = page_alloc(0)));
  8041607200:	48 b9 5c e2 60 41 80 	movabs $0x804160e25c,%rcx
  8041607207:	00 00 00 
  804160720a:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607211:	00 00 00 
  8041607214:	be fd 03 00 00       	mov    $0x3fd,%esi
  8041607219:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607220:	00 00 00 
  8041607223:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607228:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160722f:	00 00 00 
  8041607232:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607235:	48 b9 72 e2 60 41 80 	movabs $0x804160e272,%rcx
  804160723c:	00 00 00 
  804160723f:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607246:	00 00 00 
  8041607249:	be fe 03 00 00       	mov    $0x3fe,%esi
  804160724e:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607255:	00 00 00 
  8041607258:	b8 00 00 00 00       	mov    $0x0,%eax
  804160725d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607264:	00 00 00 
  8041607267:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  804160726a:	48 b9 88 e2 60 41 80 	movabs $0x804160e288,%rcx
  8041607271:	00 00 00 
  8041607274:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160727b:	00 00 00 
  804160727e:	be ff 03 00 00       	mov    $0x3ff,%esi
  8041607283:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160728a:	00 00 00 
  804160728d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607292:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607299:	00 00 00 
  804160729c:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  804160729f:	48 b9 41 e1 60 41 80 	movabs $0x804160e141,%rcx
  80416072a6:	00 00 00 
  80416072a9:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416072b0:	00 00 00 
  80416072b3:	be 02 04 00 00       	mov    $0x402,%esi
  80416072b8:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416072bf:	00 00 00 
  80416072c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072c7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072ce:	00 00 00 
  80416072d1:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416072d4:	48 b9 58 d8 60 41 80 	movabs $0x804160d858,%rcx
  80416072db:	00 00 00 
  80416072de:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416072e5:	00 00 00 
  80416072e8:	be 03 04 00 00       	mov    $0x403,%esi
  80416072ed:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416072f4:	00 00 00 
  80416072f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072fc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607303:	00 00 00 
  8041607306:	41 ff d0             	callq  *%r8
  assert(page2pa(pp0) < npages * PGSIZE);
  8041607309:	48 b9 f8 dc 60 41 80 	movabs $0x804160dcf8,%rcx
  8041607310:	00 00 00 
  8041607313:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160731a:	00 00 00 
  804160731d:	be 04 04 00 00       	mov    $0x404,%esi
  8041607322:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607329:	00 00 00 
  804160732c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607331:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607338:	00 00 00 
  804160733b:	41 ff d0             	callq  *%r8
  assert(page2pa(pp1) < npages * PGSIZE);
  804160733e:	48 b9 18 dd 60 41 80 	movabs $0x804160dd18,%rcx
  8041607345:	00 00 00 
  8041607348:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160734f:	00 00 00 
  8041607352:	be 05 04 00 00       	mov    $0x405,%esi
  8041607357:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160735e:	00 00 00 
  8041607361:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607366:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160736d:	00 00 00 
  8041607370:	41 ff d0             	callq  *%r8
  assert(page2pa(pp2) < npages * PGSIZE);
  8041607373:	48 b9 38 dd 60 41 80 	movabs $0x804160dd38,%rcx
  804160737a:	00 00 00 
  804160737d:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607384:	00 00 00 
  8041607387:	be 06 04 00 00       	mov    $0x406,%esi
  804160738c:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607393:	00 00 00 
  8041607396:	b8 00 00 00 00       	mov    $0x0,%eax
  804160739b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073a2:	00 00 00 
  80416073a5:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416073a8:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  80416073af:	00 00 00 
  80416073b2:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416073b9:	00 00 00 
  80416073bc:	be 0d 04 00 00       	mov    $0x40d,%esi
  80416073c1:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416073c8:	00 00 00 
  80416073cb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073d0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073d7:	00 00 00 
  80416073da:	41 ff d0             	callq  *%r8
  assert((pp0 = page_alloc(0)));
  80416073dd:	48 b9 5c e2 60 41 80 	movabs $0x804160e25c,%rcx
  80416073e4:	00 00 00 
  80416073e7:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416073ee:	00 00 00 
  80416073f1:	be 14 04 00 00       	mov    $0x414,%esi
  80416073f6:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416073fd:	00 00 00 
  8041607400:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607405:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160740c:	00 00 00 
  804160740f:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607412:	48 b9 72 e2 60 41 80 	movabs $0x804160e272,%rcx
  8041607419:	00 00 00 
  804160741c:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607423:	00 00 00 
  8041607426:	be 15 04 00 00       	mov    $0x415,%esi
  804160742b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607432:	00 00 00 
  8041607435:	b8 00 00 00 00       	mov    $0x0,%eax
  804160743a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607441:	00 00 00 
  8041607444:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041607447:	48 b9 88 e2 60 41 80 	movabs $0x804160e288,%rcx
  804160744e:	00 00 00 
  8041607451:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607458:	00 00 00 
  804160745b:	be 16 04 00 00       	mov    $0x416,%esi
  8041607460:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607467:	00 00 00 
  804160746a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160746f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607476:	00 00 00 
  8041607479:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  804160747c:	48 b9 41 e1 60 41 80 	movabs $0x804160e141,%rcx
  8041607483:	00 00 00 
  8041607486:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160748d:	00 00 00 
  8041607490:	be 18 04 00 00       	mov    $0x418,%esi
  8041607495:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160749c:	00 00 00 
  804160749f:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074a4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074ab:	00 00 00 
  80416074ae:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416074b1:	48 b9 58 d8 60 41 80 	movabs $0x804160d858,%rcx
  80416074b8:	00 00 00 
  80416074bb:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416074c2:	00 00 00 
  80416074c5:	be 19 04 00 00       	mov    $0x419,%esi
  80416074ca:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416074d1:	00 00 00 
  80416074d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074d9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074e0:	00 00 00 
  80416074e3:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416074e6:	48 b9 5e e1 60 41 80 	movabs $0x804160e15e,%rcx
  80416074ed:	00 00 00 
  80416074f0:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416074f7:	00 00 00 
  80416074fa:	be 1a 04 00 00       	mov    $0x41a,%esi
  80416074ff:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607506:	00 00 00 
  8041607509:	b8 00 00 00 00       	mov    $0x0,%eax
  804160750e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607515:	00 00 00 
  8041607518:	41 ff d0             	callq  *%r8
  804160751b:	48 89 f9             	mov    %rdi,%rcx
  804160751e:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607525:	00 00 00 
  8041607528:	be 61 00 00 00       	mov    $0x61,%esi
  804160752d:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  8041607534:	00 00 00 
  8041607537:	b8 00 00 00 00       	mov    $0x0,%eax
  804160753c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607543:	00 00 00 
  8041607546:	41 ff d0             	callq  *%r8
  assert((pp = page_alloc(ALLOC_ZERO)));
  8041607549:	48 b9 9e e2 60 41 80 	movabs $0x804160e29e,%rcx
  8041607550:	00 00 00 
  8041607553:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160755a:	00 00 00 
  804160755d:	be 1f 04 00 00       	mov    $0x41f,%esi
  8041607562:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607569:	00 00 00 
  804160756c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607573:	00 00 00 
  8041607576:	41 ff d0             	callq  *%r8
  assert(pp && pp0 == pp);
  8041607579:	48 b9 bc e2 60 41 80 	movabs $0x804160e2bc,%rcx
  8041607580:	00 00 00 
  8041607583:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160758a:	00 00 00 
  804160758d:	be 20 04 00 00       	mov    $0x420,%esi
  8041607592:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607599:	00 00 00 
  804160759c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075a1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075a8:	00 00 00 
  80416075ab:	41 ff d0             	callq  *%r8
  80416075ae:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  80416075b5:	00 00 00 
  80416075b8:	be 61 00 00 00       	mov    $0x61,%esi
  80416075bd:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  80416075c4:	00 00 00 
  80416075c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075cc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075d3:	00 00 00 
  80416075d6:	41 ff d0             	callq  *%r8
    assert(c[i] == 0);
  80416075d9:	48 b9 cc e2 60 41 80 	movabs $0x804160e2cc,%rcx
  80416075e0:	00 00 00 
  80416075e3:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416075ea:	00 00 00 
  80416075ed:	be 23 04 00 00       	mov    $0x423,%esi
  80416075f2:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416075f9:	00 00 00 
  80416075fc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607601:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607608:	00 00 00 
  804160760b:	41 ff d0             	callq  *%r8
  assert(nfree == 0);
  804160760e:	48 b9 d6 e2 60 41 80 	movabs $0x804160e2d6,%rcx
  8041607615:	00 00 00 
  8041607618:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160761f:	00 00 00 
  8041607622:	be 30 04 00 00       	mov    $0x430,%esi
  8041607627:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160762e:	00 00 00 
  8041607631:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607636:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160763d:	00 00 00 
  8041607640:	41 ff d0             	callq  *%r8
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041607643:	48 89 c1             	mov    %rax,%rcx
  8041607646:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  804160764d:	00 00 00 
  8041607650:	be 20 01 00 00       	mov    $0x120,%esi
  8041607655:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160765c:	00 00 00 
  804160765f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607664:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160766b:	00 00 00 
  804160766e:	41 ff d0             	callq  *%r8
  8041607671:	48 89 c1             	mov    %rax,%rcx
  8041607674:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  804160767b:	00 00 00 
  804160767e:	be 2b 01 00 00       	mov    $0x12b,%esi
  8041607683:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160768a:	00 00 00 
  804160768d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607692:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607699:	00 00 00 
  804160769c:	41 ff d0             	callq  *%r8
  804160769f:	48 89 f9             	mov    %rdi,%rcx
  80416076a2:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  80416076a9:	00 00 00 
  80416076ac:	be 3a 01 00 00       	mov    $0x13a,%esi
  80416076b1:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416076b8:	00 00 00 
  80416076bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076c0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076c7:	00 00 00 
  80416076ca:	41 ff d0             	callq  *%r8
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  80416076cd:	49 8b 4c 24 08       	mov    0x8(%r12),%rcx
    size_to_alloc = mmap_curr->NumberOfPages * PGSIZE;
  80416076d2:	49 8b 54 24 18       	mov    0x18(%r12),%rdx
  80416076d7:	48 c1 e2 0c          	shl    $0xc,%rdx
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  80416076db:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  80416076e0:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416076e6:	49 8b 3f             	mov    (%r15),%rdi
  80416076e9:	48 b8 8d 4f 60 41 80 	movabs $0x8041604f8d,%rax
  80416076f0:	00 00 00 
  80416076f3:	ff d0                	callq  *%rax
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416076f5:	4c 89 e0             	mov    %r12,%rax
  80416076f8:	49 03 06             	add    (%r14),%rax
  80416076fb:	49 89 c4             	mov    %rax,%r12
  80416076fe:	49 39 45 00          	cmp    %rax,0x0(%r13)
  8041607702:	76 0a                	jbe    804160770e <mem_init+0x24b7>
    if (mmap_curr->Attribute & EFI_MEMORY_RUNTIME) {
  8041607704:	49 83 7c 24 20 00    	cmpq   $0x0,0x20(%r12)
  804160770a:	79 e9                	jns    80416076f5 <mem_init+0x249e>
  804160770c:	eb bf                	jmp    80416076cd <mem_init+0x2476>
  pml4e = kern_pml4e;
  804160770e:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607715:	00 00 00 
  8041607718:	4c 8b 28             	mov    (%rax),%r13
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
  804160771b:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041607722:	00 00 00 
  8041607725:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  8041607729:	48 c1 e0 04          	shl    $0x4,%rax
  804160772d:	48 05 ff 0f 00 00    	add    $0xfff,%rax
  for (i = 0; i < n; i += PGSIZE)
  8041607733:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041607739:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160773d:	74 6d                	je     80416077ac <mem_init+0x2555>
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  804160773f:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041607746:	00 00 00 
  8041607749:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  if ((uint64_t)kva < KERNBASE)
  804160774d:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  return (physaddr_t)kva - KERNBASE;
  8041607751:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  8041607758:	ff ff ff 
  804160775b:	49 01 c6             	add    %rax,%r14
  for (i = 0; i < n; i += PGSIZE)
  804160775e:	49 89 dc             	mov    %rbx,%r12
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  8041607761:	49 bf 00 e0 42 3c 80 	movabs $0x803c42e000,%r15
  8041607768:	00 00 00 
  804160776b:	4b 8d 34 3c          	lea    (%r12,%r15,1),%rsi
  804160776f:	4c 89 ef             	mov    %r13,%rdi
  8041607772:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  8041607779:	00 00 00 
  804160777c:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  804160777e:	48 bf ff ff ff 3f 80 	movabs $0x803fffffff,%rdi
  8041607785:	00 00 00 
  8041607788:	48 39 7d b0          	cmp    %rdi,-0x50(%rbp)
  804160778c:	0f 86 a4 01 00 00    	jbe    8041607936 <mem_init+0x26df>
  8041607792:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  8041607796:	48 39 c2             	cmp    %rax,%rdx
  8041607799:	0f 85 c6 01 00 00    	jne    8041607965 <mem_init+0x270e>
  for (i = 0; i < n; i += PGSIZE)
  804160779f:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  80416077a6:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416077aa:	77 bf                	ja     804160776b <mem_init+0x2514>
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  80416077ac:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  80416077b3:	00 00 00 
  80416077b6:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  80416077ba:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416077be:	49 bc 00 e0 22 3c 80 	movabs $0x803c22e000,%r12
  80416077c5:	00 00 00 
  80416077c8:	49 bf e6 40 60 41 80 	movabs $0x80416040e6,%r15
  80416077cf:	00 00 00 
  80416077d2:	49 be 00 20 dd 83 ff 	movabs $0xfffffeff83dd2000,%r14
  80416077d9:	fe ff ff 
  80416077dc:	49 01 c6             	add    %rax,%r14
  80416077df:	4c 89 e6             	mov    %r12,%rsi
  80416077e2:	4c 89 ef             	mov    %r13,%rdi
  80416077e5:	41 ff d7             	callq  *%r15
  80416077e8:	48 b9 ff ff ff 3f 80 	movabs $0x803fffffff,%rcx
  80416077ef:	00 00 00 
  80416077f2:	48 39 4d b8          	cmp    %rcx,-0x48(%rbp)
  80416077f6:	0f 86 9e 01 00 00    	jbe    804160799a <mem_init+0x2743>
  80416077fc:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  8041607800:	48 39 c2             	cmp    %rax,%rdx
  8041607803:	0f 85 c0 01 00 00    	jne    80416079c9 <mem_init+0x2772>
  for (i = 0; i < n; i += PGSIZE)
  8041607809:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041607810:	48 b8 00 60 27 3c 80 	movabs $0x803c276000,%rax
  8041607817:	00 00 00 
  804160781a:	49 39 c4             	cmp    %rax,%r12
  804160781d:	75 c0                	jne    80416077df <mem_init+0x2588>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  804160781f:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041607823:	48 c1 e0 0c          	shl    $0xc,%rax
  8041607827:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160782b:	0f 84 02 02 00 00    	je     8041607a33 <mem_init+0x27dc>
  8041607831:	49 89 dc             	mov    %rbx,%r12
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  8041607834:	49 bf 00 00 00 40 80 	movabs $0x8040000000,%r15
  804160783b:	00 00 00 
  804160783e:	49 be e6 40 60 41 80 	movabs $0x80416040e6,%r14
  8041607845:	00 00 00 
  8041607848:	4b 8d 34 3c          	lea    (%r12,%r15,1),%rsi
  804160784c:	4c 89 ef             	mov    %r13,%rdi
  804160784f:	41 ff d6             	callq  *%r14
  8041607852:	4c 39 e0             	cmp    %r12,%rax
  8041607855:	0f 85 a3 01 00 00    	jne    80416079fe <mem_init+0x27a7>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  804160785b:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041607862:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041607866:	77 e0                	ja     8041607848 <mem_init+0x25f1>
  8041607868:	49 bc 00 00 ff 3f 80 	movabs $0x803fff0000,%r12
  804160786f:	00 00 00 
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8041607872:	49 bf e6 40 60 41 80 	movabs $0x80416040e6,%r15
  8041607879:	00 00 00 
  804160787c:	49 be 00 00 01 80 ff 	movabs $0xfffffeff80010000,%r14
  8041607883:	fe ff ff 
  8041607886:	48 b8 00 00 61 41 80 	movabs $0x8041610000,%rax
  804160788d:	00 00 00 
  8041607890:	49 01 c6             	add    %rax,%r14
  8041607893:	4c 89 e6             	mov    %r12,%rsi
  8041607896:	4c 89 ef             	mov    %r13,%rdi
  8041607899:	41 ff d7             	callq  *%r15
  804160789c:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  80416078a0:	48 39 d0             	cmp    %rdx,%rax
  80416078a3:	0f 85 99 01 00 00    	jne    8041607a42 <mem_init+0x27eb>
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
  80416078a9:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  80416078b0:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416078b7:	00 00 00 
  80416078ba:	49 39 c4             	cmp    %rax,%r12
  80416078bd:	75 d4                	jne    8041607893 <mem_init+0x263c>
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  80416078bf:	48 be 00 00 e0 3f 80 	movabs $0x803fe00000,%rsi
  80416078c6:	00 00 00 
  80416078c9:	4c 89 ef             	mov    %r13,%rdi
  80416078cc:	48 b8 e6 40 60 41 80 	movabs $0x80416040e6,%rax
  80416078d3:	00 00 00 
  80416078d6:	ff d0                	callq  *%rax
  80416078d8:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  80416078dc:	0f 85 95 01 00 00    	jne    8041607a77 <mem_init+0x2820>
  pdpe_t *pdpe = KADDR(PTE_ADDR(kern_pml4e[1]));
  80416078e2:	49 8b 4d 08          	mov    0x8(%r13),%rcx
  80416078e6:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  80416078ed:	48 89 c8             	mov    %rcx,%rax
  80416078f0:	48 c1 e8 0c          	shr    $0xc,%rax
  80416078f4:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  80416078f8:	0f 86 ae 01 00 00    	jbe    8041607aac <mem_init+0x2855>
  pde_t *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  80416078fe:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607905:	00 00 00 
  8041607908:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  804160790c:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041607913:	48 89 c8             	mov    %rcx,%rax
  8041607916:	48 c1 e8 0c          	shr    $0xc,%rax
  804160791a:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  804160791e:	0f 86 b3 01 00 00    	jbe    8041607ad7 <mem_init+0x2880>
  return (void *)(pa + KERNBASE);
  8041607924:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160792b:	00 00 00 
  804160792e:	48 01 c1             	add    %rax,%rcx
  for (i = 0; i < NPDENTRIES; i++) {
  8041607931:	e9 ef 01 00 00       	jmpq   8041607b25 <mem_init+0x28ce>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041607936:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  804160793a:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  8041607941:	00 00 00 
  8041607944:	be 47 04 00 00       	mov    $0x447,%esi
  8041607949:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607950:	00 00 00 
  8041607953:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607958:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160795f:	00 00 00 
  8041607962:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  8041607965:	48 b9 78 dd 60 41 80 	movabs $0x804160dd78,%rcx
  804160796c:	00 00 00 
  804160796f:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607976:	00 00 00 
  8041607979:	be 47 04 00 00       	mov    $0x447,%esi
  804160797e:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607985:	00 00 00 
  8041607988:	b8 00 00 00 00       	mov    $0x0,%eax
  804160798d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607994:	00 00 00 
  8041607997:	41 ff d0             	callq  *%r8
  804160799a:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  804160799e:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  80416079a5:	00 00 00 
  80416079a8:	be 4c 04 00 00       	mov    $0x44c,%esi
  80416079ad:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416079b4:	00 00 00 
  80416079b7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079bc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079c3:	00 00 00 
  80416079c6:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  80416079c9:	48 b9 b0 dd 60 41 80 	movabs $0x804160ddb0,%rcx
  80416079d0:	00 00 00 
  80416079d3:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416079da:	00 00 00 
  80416079dd:	be 4c 04 00 00       	mov    $0x44c,%esi
  80416079e2:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416079e9:	00 00 00 
  80416079ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079f1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079f8:	00 00 00 
  80416079fb:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  80416079fe:	48 b9 e8 dd 60 41 80 	movabs $0x804160dde8,%rcx
  8041607a05:	00 00 00 
  8041607a08:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607a0f:	00 00 00 
  8041607a12:	be 50 04 00 00       	mov    $0x450,%esi
  8041607a17:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607a1e:	00 00 00 
  8041607a21:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a26:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a2d:	00 00 00 
  8041607a30:	41 ff d0             	callq  *%r8
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607a33:	49 bc 00 00 ff 3f 80 	movabs $0x803fff0000,%r12
  8041607a3a:	00 00 00 
  8041607a3d:	e9 30 fe ff ff       	jmpq   8041607872 <mem_init+0x261b>
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8041607a42:	48 b9 10 de 60 41 80 	movabs $0x804160de10,%rcx
  8041607a49:	00 00 00 
  8041607a4c:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607a53:	00 00 00 
  8041607a56:	be 54 04 00 00       	mov    $0x454,%esi
  8041607a5b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607a62:	00 00 00 
  8041607a65:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a6a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a71:	00 00 00 
  8041607a74:	41 ff d0             	callq  *%r8
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  8041607a77:	48 b9 58 de 60 41 80 	movabs $0x804160de58,%rcx
  8041607a7e:	00 00 00 
  8041607a81:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607a88:	00 00 00 
  8041607a8b:	be 55 04 00 00       	mov    $0x455,%esi
  8041607a90:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607a97:	00 00 00 
  8041607a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a9f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607aa6:	00 00 00 
  8041607aa9:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041607aac:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607ab3:	00 00 00 
  8041607ab6:	be 57 04 00 00       	mov    $0x457,%esi
  8041607abb:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607ac2:	00 00 00 
  8041607ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607aca:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607ad1:	00 00 00 
  8041607ad4:	41 ff d0             	callq  *%r8
  8041607ad7:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041607ade:	00 00 00 
  8041607ae1:	be 58 04 00 00       	mov    $0x458,%esi
  8041607ae6:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607aed:	00 00 00 
  8041607af0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607af5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607afc:	00 00 00 
  8041607aff:	41 ff d0             	callq  *%r8
    switch (i) {
  8041607b02:	48 81 fb 00 00 08 00 	cmp    $0x80000,%rbx
  8041607b09:	75 32                	jne    8041607b3d <mem_init+0x28e6>
        assert(pgdir[i] & PTE_P);
  8041607b0b:	f6 01 01             	testb  $0x1,(%rcx)
  8041607b0e:	74 7a                	je     8041607b8a <mem_init+0x2933>
  for (i = 0; i < NPDENTRIES; i++) {
  8041607b10:	48 83 c3 01          	add    $0x1,%rbx
  8041607b14:	48 83 c1 08          	add    $0x8,%rcx
  8041607b18:	48 81 fb 00 02 00 00 	cmp    $0x200,%rbx
  8041607b1f:	0f 84 d8 00 00 00    	je     8041607bfd <mem_init+0x29a6>
    switch (i) {
  8041607b25:	48 81 fb ff 01 04 00 	cmp    $0x401ff,%rbx
  8041607b2c:	74 dd                	je     8041607b0b <mem_init+0x28b4>
  8041607b2e:	77 d2                	ja     8041607b02 <mem_init+0x28ab>
  8041607b30:	48 8d 83 1f fe fb ff 	lea    -0x401e1(%rbx),%rax
  8041607b37:	48 83 f8 01          	cmp    $0x1,%rax
  8041607b3b:	76 ce                	jbe    8041607b0b <mem_init+0x28b4>
        if (i >= VPD(KERNBASE)) {
  8041607b3d:	48 81 fb ff 01 04 00 	cmp    $0x401ff,%rbx
  8041607b44:	76 ca                	jbe    8041607b10 <mem_init+0x28b9>
          if (pgdir[i] & PTE_P)
  8041607b46:	48 8b 01             	mov    (%rcx),%rax
  8041607b49:	a8 01                	test   $0x1,%al
  8041607b4b:	74 72                	je     8041607bbf <mem_init+0x2968>
            assert(pgdir[i] & PTE_W);
  8041607b4d:	a8 02                	test   $0x2,%al
  8041607b4f:	0f 85 4a 07 00 00    	jne    804160829f <mem_init+0x3048>
  8041607b55:	48 b9 f2 e2 60 41 80 	movabs $0x804160e2f2,%rcx
  8041607b5c:	00 00 00 
  8041607b5f:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607b66:	00 00 00 
  8041607b69:	be 65 04 00 00       	mov    $0x465,%esi
  8041607b6e:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607b75:	00 00 00 
  8041607b78:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b7d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b84:	00 00 00 
  8041607b87:	41 ff d0             	callq  *%r8
        assert(pgdir[i] & PTE_P);
  8041607b8a:	48 b9 e1 e2 60 41 80 	movabs $0x804160e2e1,%rcx
  8041607b91:	00 00 00 
  8041607b94:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607b9b:	00 00 00 
  8041607b9e:	be 60 04 00 00       	mov    $0x460,%esi
  8041607ba3:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607baa:	00 00 00 
  8041607bad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607bb2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607bb9:	00 00 00 
  8041607bbc:	41 ff d0             	callq  *%r8
            assert(pgdir[i] == 0);
  8041607bbf:	48 85 c0             	test   %rax,%rax
  8041607bc2:	0f 84 d7 06 00 00    	je     804160829f <mem_init+0x3048>
  8041607bc8:	48 b9 03 e3 60 41 80 	movabs $0x804160e303,%rcx
  8041607bcf:	00 00 00 
  8041607bd2:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607bd9:	00 00 00 
  8041607bdc:	be 67 04 00 00       	mov    $0x467,%esi
  8041607be1:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607be8:	00 00 00 
  8041607beb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607bf0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607bf7:	00 00 00 
  8041607bfa:	41 ff d0             	callq  *%r8
  cprintf("check_kern_pml4e() succeeded!\n");
  8041607bfd:	48 bf 88 de 60 41 80 	movabs $0x804160de88,%rdi
  8041607c04:	00 00 00 
  8041607c07:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c0c:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041607c13:	00 00 00 
  8041607c16:	ff d2                	callq  *%rdx
  mmap_base = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)uefi_lp->MemoryMapVirt;
  8041607c18:	48 b9 00 00 62 41 80 	movabs $0x8041620000,%rcx
  8041607c1f:	00 00 00 
  8041607c22:	48 8b 11             	mov    (%rcx),%rdx
  8041607c25:	48 8b 42 30          	mov    0x30(%rdx),%rax
  8041607c29:	48 a3 f0 44 88 41 80 	movabs %rax,0x80418844f0
  8041607c30:	00 00 00 
  mmap_end  = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)uefi_lp->MemoryMapVirt + uefi_lp->MemoryMapSize);
  8041607c33:	48 03 42 38          	add    0x38(%rdx),%rax
  8041607c37:	48 a3 e8 44 88 41 80 	movabs %rax,0x80418844e8
  8041607c3e:	00 00 00 
  uefi_lp   = (LOADER_PARAMS *)uefi_lp->SelfVirtual;
  8041607c41:	48 8b 12             	mov    (%rdx),%rdx
  8041607c44:	48 89 11             	mov    %rdx,(%rcx)
  __asm __volatile("movq %0,%%cr3"
  8041607c47:	48 a1 48 5a 88 41 80 	movabs 0x8041885a48,%rax
  8041607c4e:	00 00 00 
  8041607c51:	0f 22 d8             	mov    %rax,%cr3
  __asm __volatile("movq %%cr0,%0"
  8041607c54:	0f 20 c0             	mov    %cr0,%rax
    cr0 &= ~(CR0_TS | CR0_EM);
  8041607c57:	48 83 e0 f3          	and    $0xfffffffffffffff3,%rax
  8041607c5b:	b9 23 00 05 80       	mov    $0x80050023,%ecx
  8041607c60:	48 09 c8             	or     %rcx,%rax
  __asm __volatile("movq %0,%%cr0"
  8041607c63:	0f 22 c0             	mov    %rax,%cr0
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607c66:	48 8b 4a 40          	mov    0x40(%rdx),%rcx
  uintptr_t size     = lp->FrameBufferSize;
  8041607c6a:	8b 52 48             	mov    0x48(%rdx),%edx
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607c6d:	48 bb 40 5a 88 41 80 	movabs $0x8041885a40,%rbx
  8041607c74:	00 00 00 
  8041607c77:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041607c7d:	48 be 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rsi
  8041607c84:	00 00 00 
  8041607c87:	48 8b 3b             	mov    (%rbx),%rdi
  8041607c8a:	48 b8 8d 4f 60 41 80 	movabs $0x8041604f8d,%rax
  8041607c91:	00 00 00 
  8041607c94:	ff d0                	callq  *%rax
check_page_installed_pml4(void) {
  struct PageInfo *pp0, *pp1, *pp2;
  pml4e_t pml4e_old; //used to store value instead of pointer

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041607c96:	48 8b 03             	mov    (%rbx),%rax
  8041607c99:	4c 8b 30             	mov    (%rax),%r14
  kern_pml4e[0] = 0;
  8041607c9c:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  8041607ca3:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607ca8:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041607caf:	00 00 00 
  8041607cb2:	ff d0                	callq  *%rax
  8041607cb4:	49 89 c4             	mov    %rax,%r12
  8041607cb7:	48 85 c0             	test   %rax,%rax
  8041607cba:	0f 84 aa 02 00 00    	je     8041607f6a <mem_init+0x2d13>
  assert((pp1 = page_alloc(0)));
  8041607cc0:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607cc5:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041607ccc:	00 00 00 
  8041607ccf:	ff d0                	callq  *%rax
  8041607cd1:	49 89 c5             	mov    %rax,%r13
  8041607cd4:	48 85 c0             	test   %rax,%rax
  8041607cd7:	0f 84 c2 02 00 00    	je     8041607f9f <mem_init+0x2d48>
  assert((pp2 = page_alloc(0)));
  8041607cdd:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607ce2:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  8041607ce9:	00 00 00 
  8041607cec:	ff d0                	callq  *%rax
  8041607cee:	48 89 c3             	mov    %rax,%rbx
  8041607cf1:	48 85 c0             	test   %rax,%rax
  8041607cf4:	0f 84 da 02 00 00    	je     8041607fd4 <mem_init+0x2d7d>
  page_free(pp0);
  8041607cfa:	4c 89 e7             	mov    %r12,%rdi
  8041607cfd:	48 b8 12 4b 60 41 80 	movabs $0x8041604b12,%rax
  8041607d04:	00 00 00 
  8041607d07:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607d09:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607d10:	00 00 00 
  8041607d13:	4c 89 e9             	mov    %r13,%rcx
  8041607d16:	48 2b 08             	sub    (%rax),%rcx
  8041607d19:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607d1d:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607d21:	48 89 ca             	mov    %rcx,%rdx
  8041607d24:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607d28:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041607d2f:	00 00 00 
  8041607d32:	48 3b 10             	cmp    (%rax),%rdx
  8041607d35:	0f 83 ce 02 00 00    	jae    8041608009 <mem_init+0x2db2>
  return (void *)(pa + KERNBASE);
  8041607d3b:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607d42:	00 00 00 
  8041607d45:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp1), 1, PGSIZE);
  8041607d48:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607d4d:	be 01 00 00 00       	mov    $0x1,%esi
  8041607d52:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041607d59:	00 00 00 
  8041607d5c:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607d5e:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607d65:	00 00 00 
  8041607d68:	48 89 d9             	mov    %rbx,%rcx
  8041607d6b:	48 2b 08             	sub    (%rax),%rcx
  8041607d6e:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607d72:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607d76:	48 89 ca             	mov    %rcx,%rdx
  8041607d79:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607d7d:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041607d84:	00 00 00 
  8041607d87:	48 3b 10             	cmp    (%rax),%rdx
  8041607d8a:	0f 83 a4 02 00 00    	jae    8041608034 <mem_init+0x2ddd>
  return (void *)(pa + KERNBASE);
  8041607d90:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607d97:	00 00 00 
  8041607d9a:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp2), 2, PGSIZE);
  8041607d9d:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607da2:	be 02 00 00 00       	mov    $0x2,%esi
  8041607da7:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041607dae:	00 00 00 
  8041607db1:	ff d0                	callq  *%rax
  page_insert(kern_pml4e, pp1, (void *)PGSIZE, PTE_W);
  8041607db3:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607db8:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607dbd:	4c 89 ee             	mov    %r13,%rsi
  8041607dc0:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607dc7:	00 00 00 
  8041607dca:	48 8b 38             	mov    (%rax),%rdi
  8041607dcd:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041607dd4:	00 00 00 
  8041607dd7:	ff d0                	callq  *%rax
  assert(pp1->pp_ref == 1);
  8041607dd9:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041607ddf:	0f 85 7a 02 00 00    	jne    804160805f <mem_init+0x2e08>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041607de5:	81 3c 25 00 10 00 00 	cmpl   $0x1010101,0x1000
  8041607dec:	01 01 01 01 
  8041607df0:	0f 85 9e 02 00 00    	jne    8041608094 <mem_init+0x2e3d>
  page_insert(kern_pml4e, pp2, (void *)PGSIZE, PTE_W);
  8041607df6:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607dfb:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607e00:	48 89 de             	mov    %rbx,%rsi
  8041607e03:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607e0a:	00 00 00 
  8041607e0d:	48 8b 38             	mov    (%rax),%rdi
  8041607e10:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  8041607e17:	00 00 00 
  8041607e1a:	ff d0                	callq  *%rax
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  8041607e1c:	81 3c 25 00 10 00 00 	cmpl   $0x2020202,0x1000
  8041607e23:	02 02 02 02 
  8041607e27:	0f 85 9c 02 00 00    	jne    80416080c9 <mem_init+0x2e72>
  assert(pp2->pp_ref == 1);
  8041607e2d:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041607e32:	0f 85 c6 02 00 00    	jne    80416080fe <mem_init+0x2ea7>
  assert(pp1->pp_ref == 0);
  8041607e38:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041607e3e:	0f 85 ef 02 00 00    	jne    8041608133 <mem_init+0x2edc>
  *(uint32_t *)PGSIZE = 0x03030303U;
  8041607e44:	c7 04 25 00 10 00 00 	movl   $0x3030303,0x1000
  8041607e4b:	03 03 03 03 
  return (pp - pages) << PGSHIFT;
  8041607e4f:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607e56:	00 00 00 
  8041607e59:	48 89 d9             	mov    %rbx,%rcx
  8041607e5c:	48 2b 08             	sub    (%rax),%rcx
  8041607e5f:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607e63:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607e67:	48 89 ca             	mov    %rcx,%rdx
  8041607e6a:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607e6e:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041607e75:	00 00 00 
  8041607e78:	48 3b 10             	cmp    (%rax),%rdx
  8041607e7b:	0f 83 e7 02 00 00    	jae    8041608168 <mem_init+0x2f11>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  8041607e81:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607e88:	00 00 00 
  8041607e8b:	81 3c 01 03 03 03 03 	cmpl   $0x3030303,(%rcx,%rax,1)
  8041607e92:	0f 85 fb 02 00 00    	jne    8041608193 <mem_init+0x2f3c>
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041607e98:	be 00 10 00 00       	mov    $0x1000,%esi
  8041607e9d:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607ea4:	00 00 00 
  8041607ea7:	48 8b 38             	mov    (%rax),%rdi
  8041607eaa:	48 b8 cb 50 60 41 80 	movabs $0x80416050cb,%rax
  8041607eb1:	00 00 00 
  8041607eb4:	ff d0                	callq  *%rax
  assert(pp2->pp_ref == 0);
  8041607eb6:	66 83 7b 08 00       	cmpw   $0x0,0x8(%rbx)
  8041607ebb:	0f 85 07 03 00 00    	jne    80416081c8 <mem_init+0x2f71>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  8041607ec1:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041607ec8:	00 00 00 
  8041607ecb:	48 8b 08             	mov    (%rax),%rcx
  8041607ece:	48 8b 11             	mov    (%rcx),%rdx
  8041607ed1:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041607ed8:	48 b8 58 5a 88 41 80 	movabs $0x8041885a58,%rax
  8041607edf:	00 00 00 
  8041607ee2:	4c 89 e3             	mov    %r12,%rbx
  8041607ee5:	48 2b 18             	sub    (%rax),%rbx
  8041607ee8:	48 89 d8             	mov    %rbx,%rax
  8041607eeb:	48 c1 f8 04          	sar    $0x4,%rax
  8041607eef:	48 c1 e0 0c          	shl    $0xc,%rax
  8041607ef3:	48 39 c2             	cmp    %rax,%rdx
  8041607ef6:	0f 85 01 03 00 00    	jne    80416081fd <mem_init+0x2fa6>
  kern_pml4e[0] = 0;
  8041607efc:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  assert(pp0->pp_ref == 1);
  8041607f03:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041607f0a:	0f 85 22 03 00 00    	jne    8041608232 <mem_init+0x2fdb>
  pp0->pp_ref = 0;
  8041607f10:	66 41 c7 44 24 08 00 	movw   $0x0,0x8(%r12)
  8041607f17:	00 

  // free the pages we took
  page_free(pp0);
  8041607f18:	4c 89 e7             	mov    %r12,%rdi
  8041607f1b:	48 b8 12 4b 60 41 80 	movabs $0x8041604b12,%rax
  8041607f22:	00 00 00 
  8041607f25:	ff d0                	callq  *%rax

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041607f27:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  8041607f2e:	00 00 00 
  8041607f31:	4c 89 30             	mov    %r14,(%rax)

  cprintf("check_page_installed_pml4() succeeded!\n");
  8041607f34:	48 bf 50 df 60 41 80 	movabs $0x804160df50,%rdi
  8041607f3b:	00 00 00 
  8041607f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f43:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041607f4a:	00 00 00 
  8041607f4d:	ff d2                	callq  *%rdx
  struct PageInfo *pp = page_free_list, *pt = NULL;
  8041607f4f:	48 b8 10 45 88 41 80 	movabs $0x8041884510,%rax
  8041607f56:	00 00 00 
  8041607f59:	48 8b 10             	mov    (%rax),%rdx
  while (pp) {
  8041607f5c:	48 85 d2             	test   %rdx,%rdx
  8041607f5f:	0f 85 05 03 00 00    	jne    804160826a <mem_init+0x3013>
  8041607f65:	e9 08 03 00 00       	jmpq   8041608272 <mem_init+0x301b>
  assert((pp0 = page_alloc(0)));
  8041607f6a:	48 b9 5c e2 60 41 80 	movabs $0x804160e25c,%rcx
  8041607f71:	00 00 00 
  8041607f74:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607f7b:	00 00 00 
  8041607f7e:	be 4b 05 00 00       	mov    $0x54b,%esi
  8041607f83:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607f8a:	00 00 00 
  8041607f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607f92:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607f99:	00 00 00 
  8041607f9c:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607f9f:	48 b9 72 e2 60 41 80 	movabs $0x804160e272,%rcx
  8041607fa6:	00 00 00 
  8041607fa9:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607fb0:	00 00 00 
  8041607fb3:	be 4c 05 00 00       	mov    $0x54c,%esi
  8041607fb8:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607fbf:	00 00 00 
  8041607fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fc7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607fce:	00 00 00 
  8041607fd1:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041607fd4:	48 b9 88 e2 60 41 80 	movabs $0x804160e288,%rcx
  8041607fdb:	00 00 00 
  8041607fde:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041607fe5:	00 00 00 
  8041607fe8:	be 4d 05 00 00       	mov    $0x54d,%esi
  8041607fed:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041607ff4:	00 00 00 
  8041607ff7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ffc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608003:	00 00 00 
  8041608006:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041608009:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041608010:	00 00 00 
  8041608013:	be 61 00 00 00       	mov    $0x61,%esi
  8041608018:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  804160801f:	00 00 00 
  8041608022:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608027:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160802e:	00 00 00 
  8041608031:	41 ff d0             	callq  *%r8
  8041608034:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160803b:	00 00 00 
  804160803e:	be 61 00 00 00       	mov    $0x61,%esi
  8041608043:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  804160804a:	00 00 00 
  804160804d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608052:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608059:	00 00 00 
  804160805c:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  804160805f:	48 b9 6d e1 60 41 80 	movabs $0x804160e16d,%rcx
  8041608066:	00 00 00 
  8041608069:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041608070:	00 00 00 
  8041608073:	be 52 05 00 00       	mov    $0x552,%esi
  8041608078:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160807f:	00 00 00 
  8041608082:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608087:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160808e:	00 00 00 
  8041608091:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041608094:	48 b9 a8 de 60 41 80 	movabs $0x804160dea8,%rcx
  804160809b:	00 00 00 
  804160809e:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416080a5:	00 00 00 
  80416080a8:	be 53 05 00 00       	mov    $0x553,%esi
  80416080ad:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416080b4:	00 00 00 
  80416080b7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080bc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080c3:	00 00 00 
  80416080c6:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  80416080c9:	48 b9 d0 de 60 41 80 	movabs $0x804160ded0,%rcx
  80416080d0:	00 00 00 
  80416080d3:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416080da:	00 00 00 
  80416080dd:	be 55 05 00 00       	mov    $0x555,%esi
  80416080e2:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416080e9:	00 00 00 
  80416080ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080f1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080f8:	00 00 00 
  80416080fb:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 1);
  80416080fe:	48 b9 11 e3 60 41 80 	movabs $0x804160e311,%rcx
  8041608105:	00 00 00 
  8041608108:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160810f:	00 00 00 
  8041608112:	be 56 05 00 00       	mov    $0x556,%esi
  8041608117:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160811e:	00 00 00 
  8041608121:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608126:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160812d:	00 00 00 
  8041608130:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041608133:	48 b9 e8 e1 60 41 80 	movabs $0x804160e1e8,%rcx
  804160813a:	00 00 00 
  804160813d:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041608144:	00 00 00 
  8041608147:	be 57 05 00 00       	mov    $0x557,%esi
  804160814c:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041608153:	00 00 00 
  8041608156:	b8 00 00 00 00       	mov    $0x0,%eax
  804160815b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608162:	00 00 00 
  8041608165:	41 ff d0             	callq  *%r8
  8041608168:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  804160816f:	00 00 00 
  8041608172:	be 61 00 00 00       	mov    $0x61,%esi
  8041608177:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  804160817e:	00 00 00 
  8041608181:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608186:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160818d:	00 00 00 
  8041608190:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  8041608193:	48 b9 f8 de 60 41 80 	movabs $0x804160def8,%rcx
  804160819a:	00 00 00 
  804160819d:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416081a4:	00 00 00 
  80416081a7:	be 59 05 00 00       	mov    $0x559,%esi
  80416081ac:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416081b3:	00 00 00 
  80416081b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081bb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081c2:	00 00 00 
  80416081c5:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 0);
  80416081c8:	48 b9 22 e3 60 41 80 	movabs $0x804160e322,%rcx
  80416081cf:	00 00 00 
  80416081d2:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  80416081d9:	00 00 00 
  80416081dc:	be 5b 05 00 00       	mov    $0x55b,%esi
  80416081e1:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416081e8:	00 00 00 
  80416081eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081f0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081f7:	00 00 00 
  80416081fa:	41 ff d0             	callq  *%r8
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  80416081fd:	48 b9 28 df 60 41 80 	movabs $0x804160df28,%rcx
  8041608204:	00 00 00 
  8041608207:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  804160820e:	00 00 00 
  8041608211:	be 5e 05 00 00       	mov    $0x55e,%esi
  8041608216:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160821d:	00 00 00 
  8041608220:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608225:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160822c:	00 00 00 
  804160822f:	41 ff d0             	callq  *%r8
  assert(pp0->pp_ref == 1);
  8041608232:	48 b9 33 e3 60 41 80 	movabs $0x804160e333,%rcx
  8041608239:	00 00 00 
  804160823c:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041608243:	00 00 00 
  8041608246:	be 60 05 00 00       	mov    $0x560,%esi
  804160824b:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  8041608252:	00 00 00 
  8041608255:	b8 00 00 00 00       	mov    $0x0,%eax
  804160825a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608261:	00 00 00 
  8041608264:	41 ff d0             	callq  *%r8
    pp = pp->pp_link;
  8041608267:	48 89 c2             	mov    %rax,%rdx
  804160826a:	48 8b 02             	mov    (%rdx),%rax
  while (pp) {
  804160826d:	48 85 c0             	test   %rax,%rax
  8041608270:	75 f5                	jne    8041608267 <mem_init+0x3010>
  page_free_list_top = evaluate_page_free_list_top();
  8041608272:	48 89 d0             	mov    %rdx,%rax
  8041608275:	48 a3 08 45 88 41 80 	movabs %rax,0x8041884508
  804160827c:	00 00 00 
  check_page_free_list(0);
  804160827f:	bf 00 00 00 00       	mov    $0x0,%edi
  8041608284:	48 b8 61 43 60 41 80 	movabs $0x8041604361,%rax
  804160828b:	00 00 00 
  804160828e:	ff d0                	callq  *%rax
}
  8041608290:	48 83 c4 38          	add    $0x38,%rsp
  8041608294:	5b                   	pop    %rbx
  8041608295:	41 5c                	pop    %r12
  8041608297:	41 5d                	pop    %r13
  8041608299:	41 5e                	pop    %r14
  804160829b:	41 5f                	pop    %r15
  804160829d:	5d                   	pop    %rbp
  804160829e:	c3                   	retq   
  for (i = 0; i < NPDENTRIES; i++) {
  804160829f:	48 83 c3 01          	add    $0x1,%rbx
  80416082a3:	48 83 c1 08          	add    $0x8,%rcx
  80416082a7:	e9 79 f8 ff ff       	jmpq   8041607b25 <mem_init+0x28ce>

00000080416082ac <mmio_map_region>:
mmio_map_region(physaddr_t pa, size_t size) {
  80416082ac:	55                   	push   %rbp
  80416082ad:	48 89 e5             	mov    %rsp,%rbp
  80416082b0:	53                   	push   %rbx
  80416082b1:	48 83 ec 08          	sub    $0x8,%rsp
  uintptr_t pa2 = ROUNDDOWN(pa, PGSIZE);
  80416082b5:	48 89 f9             	mov    %rdi,%rcx
  80416082b8:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (base + size >= MMIOLIM) {
  80416082bf:	48 a1 20 07 62 41 80 	movabs 0x8041620720,%rax
  80416082c6:	00 00 00 
  80416082c9:	4c 8d 04 30          	lea    (%rax,%rsi,1),%r8
  80416082cd:	48 ba ff ff df 3f 80 	movabs $0x803fdfffff,%rdx
  80416082d4:	00 00 00 
  80416082d7:	49 39 d0             	cmp    %rdx,%r8
  80416082da:	77 54                	ja     8041608330 <mmio_map_region+0x84>
  size = ROUNDUP(size + (pa - pa2 ), PGSIZE);
  80416082dc:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
  80416082e2:	48 8d 9c 3e ff 0f 00 	lea    0xfff(%rsi,%rdi,1),%rbx
  80416082e9:	00 
  80416082ea:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  boot_map_region(kern_pml4e, base, size, pa2, PTE_PCD | PTE_PWT | PTE_W);
  80416082f1:	41 b8 1a 00 00 00    	mov    $0x1a,%r8d
  80416082f7:	48 89 da             	mov    %rbx,%rdx
  80416082fa:	48 89 c6             	mov    %rax,%rsi
  80416082fd:	48 b8 40 5a 88 41 80 	movabs $0x8041885a40,%rax
  8041608304:	00 00 00 
  8041608307:	48 8b 38             	mov    (%rax),%rdi
  804160830a:	48 b8 8d 4f 60 41 80 	movabs $0x8041604f8d,%rax
  8041608311:	00 00 00 
  8041608314:	ff d0                	callq  *%rax
  void * new = (void *) base;
  8041608316:	48 ba 20 07 62 41 80 	movabs $0x8041620720,%rdx
  804160831d:	00 00 00 
  8041608320:	48 8b 02             	mov    (%rdx),%rax
  base += size;
  8041608323:	48 01 c3             	add    %rax,%rbx
  8041608326:	48 89 1a             	mov    %rbx,(%rdx)
}
  8041608329:	48 83 c4 08          	add    $0x8,%rsp
  804160832d:	5b                   	pop    %rbx
  804160832e:	5d                   	pop    %rbp
  804160832f:	c3                   	retq   
    panic("Allocated MMIO addr is too high! [0x%016lu;0x%016lu]",pa, pa+size);
  8041608330:	4c 8d 04 37          	lea    (%rdi,%rsi,1),%r8
  8041608334:	48 89 f9             	mov    %rdi,%rcx
  8041608337:	48 ba 78 df 60 41 80 	movabs $0x804160df78,%rdx
  804160833e:	00 00 00 
  8041608341:	be 4f 03 00 00       	mov    $0x34f,%esi
  8041608346:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  804160834d:	00 00 00 
  8041608350:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608355:	49 b9 5a 02 60 41 80 	movabs $0x804160025a,%r9
  804160835c:	00 00 00 
  804160835f:	41 ff d1             	callq  *%r9

0000008041608362 <mmio_remap_last_region>:
mmio_remap_last_region(physaddr_t pa, void *addr, size_t oldsize, size_t newsize) {
  8041608362:	55                   	push   %rbp
  8041608363:	48 89 e5             	mov    %rsp,%rbp
  if (base - oldsize != (uintptr_t)addr)
  8041608366:	48 a1 20 07 62 41 80 	movabs 0x8041620720,%rax
  804160836d:	00 00 00 
  8041608370:	4c 8d 04 06          	lea    (%rsi,%rax,1),%r8
  oldsize = ROUNDUP((uintptr_t)addr + oldsize, PGSIZE) - (uintptr_t)addr;
  8041608374:	48 8d 84 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%rax
  804160837b:	00 
  if (base - oldsize != (uintptr_t)addr)
  804160837c:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041608382:	49 29 c0             	sub    %rax,%r8
  8041608385:	4c 39 c6             	cmp    %r8,%rsi
  8041608388:	75 1e                	jne    80416083a8 <mmio_remap_last_region+0x46>
  base = (uintptr_t)addr;
  804160838a:	48 89 f0             	mov    %rsi,%rax
  804160838d:	48 a3 20 07 62 41 80 	movabs %rax,0x8041620720
  8041608394:	00 00 00 
  return mmio_map_region(pa, newsize);
  8041608397:	48 89 ce             	mov    %rcx,%rsi
  804160839a:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  80416083a1:	00 00 00 
  80416083a4:	ff d0                	callq  *%rax
}
  80416083a6:	5d                   	pop    %rbp
  80416083a7:	c3                   	retq   
    panic("You dare to remap non-last region?!");
  80416083a8:	48 ba b0 df 60 41 80 	movabs $0x804160dfb0,%rdx
  80416083af:	00 00 00 
  80416083b2:	be 60 03 00 00       	mov    $0x360,%esi
  80416083b7:	48 bf 0f e0 60 41 80 	movabs $0x804160e00f,%rdi
  80416083be:	00 00 00 
  80416083c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416083c6:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416083cd:	00 00 00 
  80416083d0:	ff d1                	callq  *%rcx

00000080416083d2 <user_mem_check>:
user_mem_check(struct Env *env, const void *va, size_t len, int perm) {
  80416083d2:	55                   	push   %rbp
  80416083d3:	48 89 e5             	mov    %rsp,%rbp
  80416083d6:	41 57                	push   %r15
  80416083d8:	41 56                	push   %r14
  80416083da:	41 55                	push   %r13
  80416083dc:	41 54                	push   %r12
  80416083de:	53                   	push   %rbx
  80416083df:	48 83 ec 18          	sub    $0x18,%rsp
  80416083e3:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  perm |= PTE_P;
  80416083e7:	83 c9 01             	or     $0x1,%ecx
  const void * end = va + len;
  80416083ea:	4c 8d 24 16          	lea    (%rsi,%rdx,1),%r12
  va = (void *)ROUNDDOWN(va, PGSIZE);
  80416083ee:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  while (va < end) {
  80416083f5:	49 39 f4             	cmp    %rsi,%r12
  80416083f8:	76 44                	jbe    804160843e <user_mem_check+0x6c>
  80416083fa:	49 89 fe             	mov    %rdi,%r14
  80416083fd:	41 89 cd             	mov    %ecx,%r13d
  8041608400:	48 89 f3             	mov    %rsi,%rbx
    pte_t * pte = pml4e_walk(env->env_pml4e, va, 0);
  8041608403:	49 bf 3c 4e 60 41 80 	movabs $0x8041604e3c,%r15
  804160840a:	00 00 00 
  804160840d:	49 8b be e8 00 00 00 	mov    0xe8(%r14),%rdi
  8041608414:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608419:	48 89 de             	mov    %rbx,%rsi
  804160841c:	41 ff d7             	callq  *%r15
    if (!pte || (*pte & perm) != perm) {
  804160841f:	48 85 c0             	test   %rax,%rax
  8041608422:	74 30                	je     8041608454 <user_mem_check+0x82>
  8041608424:	49 63 d5             	movslq %r13d,%rdx
  8041608427:	48 89 d1             	mov    %rdx,%rcx
  804160842a:	48 23 08             	and    (%rax),%rcx
  804160842d:	48 39 ca             	cmp    %rcx,%rdx
  8041608430:	75 22                	jne    8041608454 <user_mem_check+0x82>
    va += PGSIZE;
  8041608432:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  while (va < end) {
  8041608439:	49 39 dc             	cmp    %rbx,%r12
  804160843c:	77 cf                	ja     804160840d <user_mem_check+0x3b>
  if ((uintptr_t)end > ULIM) {
  804160843e:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  8041608445:	00 00 00 
  8041608448:	49 39 c4             	cmp    %rax,%r12
  804160844b:	77 30                	ja     804160847d <user_mem_check+0xab>
  return 0;
  804160844d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608452:	eb 1a                	jmp    804160846e <user_mem_check+0x9c>
      user_mem_check_addr = (uintptr_t)MAX(va, va2);
  8041608454:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041608458:	48 39 d8             	cmp    %rbx,%rax
  804160845b:	48 0f 42 c3          	cmovb  %rbx,%rax
  804160845f:	48 a3 00 45 88 41 80 	movabs %rax,0x8041884500
  8041608466:	00 00 00 
      return -E_FAULT;
  8041608469:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
}
  804160846e:	48 83 c4 18          	add    $0x18,%rsp
  8041608472:	5b                   	pop    %rbx
  8041608473:	41 5c                	pop    %r12
  8041608475:	41 5d                	pop    %r13
  8041608477:	41 5e                	pop    %r14
  8041608479:	41 5f                	pop    %r15
  804160847b:	5d                   	pop    %rbp
  804160847c:	c3                   	retq   
    user_mem_check_addr = MAX(ULIM, (uintptr_t)va2);
  804160847d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041608481:	48 39 c6             	cmp    %rax,%rsi
  8041608484:	48 0f 43 c6          	cmovae %rsi,%rax
  8041608488:	48 a3 00 45 88 41 80 	movabs %rax,0x8041884500
  804160848f:	00 00 00 
    return -E_FAULT;
  8041608492:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
  8041608497:	eb d5                	jmp    804160846e <user_mem_check+0x9c>

0000008041608499 <user_mem_assert>:
user_mem_assert(struct Env *env, const void *va, size_t len, int perm) {
  8041608499:	55                   	push   %rbp
  804160849a:	48 89 e5             	mov    %rsp,%rbp
  804160849d:	53                   	push   %rbx
  804160849e:	48 83 ec 08          	sub    $0x8,%rsp
  80416084a2:	48 89 fb             	mov    %rdi,%rbx
  if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
  80416084a5:	83 c9 04             	or     $0x4,%ecx
  80416084a8:	48 b8 d2 83 60 41 80 	movabs $0x80416083d2,%rax
  80416084af:	00 00 00 
  80416084b2:	ff d0                	callq  *%rax
  80416084b4:	85 c0                	test   %eax,%eax
  80416084b6:	78 07                	js     80416084bf <user_mem_assert+0x26>
}
  80416084b8:	48 83 c4 08          	add    $0x8,%rsp
  80416084bc:	5b                   	pop    %rbx
  80416084bd:	5d                   	pop    %rbp
  80416084be:	c3                   	retq   
    cprintf("[%08x] user_mem_check assertion failure for va %016lx\n",
  80416084bf:	8b b3 c8 00 00 00    	mov    0xc8(%rbx),%esi
  80416084c5:	48 b8 00 45 88 41 80 	movabs $0x8041884500,%rax
  80416084cc:	00 00 00 
  80416084cf:	48 8b 10             	mov    (%rax),%rdx
  80416084d2:	48 bf d8 df 60 41 80 	movabs $0x804160dfd8,%rdi
  80416084d9:	00 00 00 
  80416084dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416084e1:	48 b9 0d 92 60 41 80 	movabs $0x804160920d,%rcx
  80416084e8:	00 00 00 
  80416084eb:	ff d1                	callq  *%rcx
    env_destroy(env); // may not return
  80416084ed:	48 89 df             	mov    %rbx,%rdi
  80416084f0:	48 b8 d2 8d 60 41 80 	movabs $0x8041608dd2,%rax
  80416084f7:	00 00 00 
  80416084fa:	ff d0                	callq  *%rax
}
  80416084fc:	eb ba                	jmp    80416084b8 <user_mem_assert+0x1f>

00000080416084fe <region_alloc>:
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len) {
  80416084fe:	55                   	push   %rbp
  80416084ff:	48 89 e5             	mov    %rsp,%rbp
  8041608502:	41 57                	push   %r15
  8041608504:	41 56                	push   %r14
  8041608506:	41 55                	push   %r13
  8041608508:	41 54                	push   %r12
  804160850a:	53                   	push   %rbx
  804160850b:	48 83 ec 08          	sub    $0x8,%rsp
  //   'va' and 'len' values that are not page-aligned.
  //   You should round va down, and round (va + len) up.
  //   (Watch out for corner-cases!)

  // LAB 8 code
  void *end = ROUNDUP(va + len, PGSIZE);
  804160850f:	4c 8d a4 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%r12
  8041608516:	00 
  8041608517:	49 81 e4 00 f0 ff ff 	and    $0xfffffffffffff000,%r12
  va = ROUNDDOWN(va, PGSIZE);
  804160851e:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
	struct PageInfo *pi;

	while (va < end) {
  8041608525:	49 39 f4             	cmp    %rsi,%r12
  8041608528:	76 43                	jbe    804160856d <region_alloc+0x6f>
  804160852a:	48 89 f3             	mov    %rsi,%rbx
  804160852d:	49 89 fd             	mov    %rdi,%r13
    pi = page_alloc(ALLOC_ZERO);
  8041608530:	49 bf 19 4a 60 41 80 	movabs $0x8041604a19,%r15
  8041608537:	00 00 00 
    page_insert(e->env_pml4e, pi, va, PTE_U | PTE_W);
  804160853a:	49 be 26 51 60 41 80 	movabs $0x8041605126,%r14
  8041608541:	00 00 00 
    pi = page_alloc(ALLOC_ZERO);
  8041608544:	bf 01 00 00 00       	mov    $0x1,%edi
  8041608549:	41 ff d7             	callq  *%r15
    page_insert(e->env_pml4e, pi, va, PTE_U | PTE_W);
  804160854c:	49 8b bd e8 00 00 00 	mov    0xe8(%r13),%rdi
  8041608553:	b9 06 00 00 00       	mov    $0x6,%ecx
  8041608558:	48 89 da             	mov    %rbx,%rdx
  804160855b:	48 89 c6             	mov    %rax,%rsi
  804160855e:	41 ff d6             	callq  *%r14
    va += PGSIZE;
  8041608561:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
	while (va < end) {
  8041608568:	49 39 dc             	cmp    %rbx,%r12
  804160856b:	77 d7                	ja     8041608544 <region_alloc+0x46>
  }
  // LAB 8 code end
}
  804160856d:	48 83 c4 08          	add    $0x8,%rsp
  8041608571:	5b                   	pop    %rbx
  8041608572:	41 5c                	pop    %r12
  8041608574:	41 5d                	pop    %r13
  8041608576:	41 5e                	pop    %r14
  8041608578:	41 5f                	pop    %r15
  804160857a:	5d                   	pop    %rbp
  804160857b:	c3                   	retq   

000000804160857c <envid2env>:
  if (envid == 0) {
  804160857c:	85 ff                	test   %edi,%edi
  804160857e:	74 57                	je     80416085d7 <envid2env+0x5b>
  e = &envs[ENVX(envid)];
  8041608580:	89 f8                	mov    %edi,%eax
  8041608582:	25 ff 03 00 00       	and    $0x3ff,%eax
  8041608587:	48 8d 0c c0          	lea    (%rax,%rax,8),%rcx
  804160858b:	48 c1 e1 05          	shl    $0x5,%rcx
  804160858f:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  8041608596:	00 00 00 
  8041608599:	48 01 c1             	add    %rax,%rcx
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  804160859c:	83 b9 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rcx)
  80416085a3:	74 42                	je     80416085e7 <envid2env+0x6b>
  80416085a5:	39 b9 c8 00 00 00    	cmp    %edi,0xc8(%rcx)
  80416085ab:	75 3a                	jne    80416085e7 <envid2env+0x6b>
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  80416085ad:	84 d2                	test   %dl,%dl
  80416085af:	74 1d                	je     80416085ce <envid2env+0x52>
  80416085b1:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  80416085b8:	00 00 00 
  80416085bb:	48 39 c8             	cmp    %rcx,%rax
  80416085be:	74 0e                	je     80416085ce <envid2env+0x52>
  80416085c0:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  80416085c6:	39 81 cc 00 00 00    	cmp    %eax,0xcc(%rcx)
  80416085cc:	75 26                	jne    80416085f4 <envid2env+0x78>
  *env_store = e;
  80416085ce:	48 89 0e             	mov    %rcx,(%rsi)
  return 0;
  80416085d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416085d6:	c3                   	retq   
    *env_store = curenv;
  80416085d7:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  80416085de:	00 00 00 
  80416085e1:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  80416085e4:	89 f8                	mov    %edi,%eax
  80416085e6:	c3                   	retq   
    *env_store = 0;
  80416085e7:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416085ee:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  80416085f3:	c3                   	retq   
    *env_store = 0;
  80416085f4:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416085fb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041608600:	c3                   	retq   

0000008041608601 <env_init_percpu>:
env_init_percpu(void) {
  8041608601:	55                   	push   %rbp
  8041608602:	48 89 e5             	mov    %rsp,%rbp
  8041608605:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  8041608606:	48 b8 40 07 62 41 80 	movabs $0x8041620740,%rax
  804160860d:	00 00 00 
  8041608610:	0f 01 10             	lgdt   (%rax)
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  8041608613:	b8 33 00 00 00       	mov    $0x33,%eax
  8041608618:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  804160861a:	8e e0                	mov    %eax,%fs
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  804160861c:	b8 10 00 00 00       	mov    $0x10,%eax
  8041608621:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041608623:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041608625:	8e d0                	mov    %eax,%ss
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  8041608627:	bb 08 00 00 00       	mov    $0x8,%ebx
  804160862c:	53                   	push   %rbx
  804160862d:	48 b8 3a 86 60 41 80 	movabs $0x804160863a,%rax
  8041608634:	00 00 00 
  8041608637:	50                   	push   %rax
  8041608638:	48 cb                	lretq  
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  804160863a:	66 b8 00 00          	mov    $0x0,%ax
  804160863e:	0f 00 d0             	lldt   %ax
}
  8041608641:	5b                   	pop    %rbx
  8041608642:	5d                   	pop    %rbp
  8041608643:	c3                   	retq   

0000008041608644 <env_init>:
env_init(void) {
  8041608644:	55                   	push   %rbp
  8041608645:	48 89 e5             	mov    %rsp,%rbp
    envs[i].env_status = ENV_FREE;
  8041608648:	48 b8 28 45 88 41 80 	movabs $0x8041884528,%rax
  804160864f:	00 00 00 
  8041608652:	48 8b 38             	mov    (%rax),%rdi
  8041608655:	48 8d 87 e0 7e 04 00 	lea    0x47ee0(%rdi),%rax
  804160865c:	48 89 fe             	mov    %rdi,%rsi
  804160865f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608664:	eb 03                	jmp    8041608669 <env_init+0x25>
  8041608666:	48 89 c8             	mov    %rcx,%rax
  8041608669:	c7 80 d4 00 00 00 00 	movl   $0x0,0xd4(%rax)
  8041608670:	00 00 00 
    envs[i].env_link = env_free_list;
  8041608673:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    envs[i].env_id   = 0;
  804160867a:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%rax)
  8041608681:	00 00 00 
  for (int i = NENV - 1; i >= 0; i--) {
  8041608684:	48 8d 88 e0 fe ff ff 	lea    -0x120(%rax),%rcx
    env_free_list    = &envs[i];
  804160868b:	48 89 c2             	mov    %rax,%rdx
  for (int i = NENV - 1; i >= 0; i--) {
  804160868e:	48 39 f0             	cmp    %rsi,%rax
  8041608691:	75 d3                	jne    8041608666 <env_init+0x22>
  8041608693:	48 89 f8             	mov    %rdi,%rax
  8041608696:	48 a3 30 45 88 41 80 	movabs %rax,0x8041884530
  804160869d:	00 00 00 
  env_init_percpu();
  80416086a0:	48 b8 01 86 60 41 80 	movabs $0x8041608601,%rax
  80416086a7:	00 00 00 
  80416086aa:	ff d0                	callq  *%rax
}
  80416086ac:	5d                   	pop    %rbp
  80416086ad:	c3                   	retq   

00000080416086ae <env_alloc>:
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  80416086ae:	55                   	push   %rbp
  80416086af:	48 89 e5             	mov    %rsp,%rbp
  80416086b2:	41 55                	push   %r13
  80416086b4:	41 54                	push   %r12
  80416086b6:	53                   	push   %rbx
  80416086b7:	48 83 ec 08          	sub    $0x8,%rsp
  if (!(e = env_free_list)) {
  80416086bb:	48 b8 30 45 88 41 80 	movabs $0x8041884530,%rax
  80416086c2:	00 00 00 
  80416086c5:	48 8b 18             	mov    (%rax),%rbx
  80416086c8:	48 85 db             	test   %rbx,%rbx
  80416086cb:	0f 84 56 02 00 00    	je     8041608927 <env_alloc+0x279>
  80416086d1:	41 89 f5             	mov    %esi,%r13d
  80416086d4:	49 89 fc             	mov    %rdi,%r12
  if (!(p = page_alloc(ALLOC_ZERO)))
  80416086d7:	bf 01 00 00 00       	mov    $0x1,%edi
  80416086dc:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  80416086e3:	00 00 00 
  80416086e6:	ff d0                	callq  *%rax
  80416086e8:	48 85 c0             	test   %rax,%rax
  80416086eb:	0f 84 40 02 00 00    	je     8041608931 <env_alloc+0x283>
  return (pp - pages) << PGSHIFT;
  80416086f1:	48 b9 58 5a 88 41 80 	movabs $0x8041885a58,%rcx
  80416086f8:	00 00 00 
  80416086fb:	48 8b 09             	mov    (%rcx),%rcx
  80416086fe:	48 29 c8             	sub    %rcx,%rax
  8041608701:	48 c1 f8 04          	sar    $0x4,%rax
  8041608705:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  8041608709:	48 bf 50 5a 88 41 80 	movabs $0x8041885a50,%rdi
  8041608710:	00 00 00 
  8041608713:	48 8b 3f             	mov    (%rdi),%rdi
  8041608716:	48 89 c2             	mov    %rax,%rdx
  8041608719:	48 c1 ea 0c          	shr    $0xc,%rdx
  804160871d:	48 39 fa             	cmp    %rdi,%rdx
  8041608720:	0f 83 8e 01 00 00    	jae    80416088b4 <env_alloc+0x206>
  return (void *)(pa + KERNBASE);
  8041608726:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  804160872d:	00 00 00 
  8041608730:	48 01 c2             	add    %rax,%rdx
	e->env_pml4e = page2kva(p);
  8041608733:	48 89 93 e8 00 00 00 	mov    %rdx,0xe8(%rbx)
  e->env_cr3 = page2pa(p);
  804160873a:	48 89 83 f0 00 00 00 	mov    %rax,0xf0(%rbx)
  e->env_pml4e[1] = kern_pml4e[1];
  8041608741:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  8041608748:	00 00 00 
  804160874b:	48 8b 70 08          	mov    0x8(%rax),%rsi
  804160874f:	48 89 72 08          	mov    %rsi,0x8(%rdx)
  pa2page(PTE_ADDR(kern_pml4e[1]))->pp_ref++;
  8041608753:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PPN(pa) >= npages) {
  804160875a:	48 89 f0             	mov    %rsi,%rax
  804160875d:	48 c1 e8 0c          	shr    $0xc,%rax
  8041608761:	48 39 f8             	cmp    %rdi,%rax
  8041608764:	0f 83 78 01 00 00    	jae    80416088e2 <env_alloc+0x234>
  return &pages[PPN(pa)];
  804160876a:	48 c1 e0 04          	shl    $0x4,%rax
  804160876e:	66 83 44 01 08 01    	addw   $0x1,0x8(%rcx,%rax,1)
  e->env_pml4e[2] = e->env_cr3 | PTE_P | PTE_U;
  8041608774:	48 8b 93 e8 00 00 00 	mov    0xe8(%rbx),%rdx
  804160877b:	48 8b 83 f0 00 00 00 	mov    0xf0(%rbx),%rax
  8041608782:	48 83 c8 05          	or     $0x5,%rax
  8041608786:	48 89 42 10          	mov    %rax,0x10(%rdx)
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  804160878a:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  8041608790:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041608795:	25 00 fc ff ff       	and    $0xfffffc00,%eax
    generation = 1 << ENVGENSHIFT;
  804160879a:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160879f:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  80416087a2:	48 ba 28 45 88 41 80 	movabs $0x8041884528,%rdx
  80416087a9:	00 00 00 
  80416087ac:	48 89 d9             	mov    %rbx,%rcx
  80416087af:	48 2b 0a             	sub    (%rdx),%rcx
  80416087b2:	48 89 ca             	mov    %rcx,%rdx
  80416087b5:	48 c1 fa 05          	sar    $0x5,%rdx
  80416087b9:	69 d2 39 8e e3 38    	imul   $0x38e38e39,%edx,%edx
  80416087bf:	09 d0                	or     %edx,%eax
  80416087c1:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)
  e->env_parent_id = parent_id;
  80416087c7:	44 89 ab cc 00 00 00 	mov    %r13d,0xcc(%rbx)
  e->env_type      = ENV_TYPE_USER;
  80416087ce:	c7 83 d0 00 00 00 02 	movl   $0x2,0xd0(%rbx)
  80416087d5:	00 00 00 
  e->env_status = ENV_RUNNABLE;
  80416087d8:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  80416087df:	00 00 00 
  e->env_runs   = 0;
  80416087e2:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  80416087e9:	00 00 00 
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  80416087ec:	ba c0 00 00 00       	mov    $0xc0,%edx
  80416087f1:	be 00 00 00 00       	mov    $0x0,%esi
  80416087f6:	48 89 df             	mov    %rbx,%rdi
  80416087f9:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041608800:	00 00 00 
  8041608803:	ff d0                	callq  *%rax
  e->env_tf.tf_ds  = GD_UD | 3;
  8041608805:	66 c7 83 80 00 00 00 	movw   $0x33,0x80(%rbx)
  804160880c:	33 00 
  e->env_tf.tf_es  = GD_UD | 3;
  804160880e:	66 c7 43 78 33 00    	movw   $0x33,0x78(%rbx)
  e->env_tf.tf_ss  = GD_UD | 3;
  8041608814:	66 c7 83 b8 00 00 00 	movw   $0x33,0xb8(%rbx)
  804160881b:	33 00 
  e->env_tf.tf_rsp = USTACKTOP;
  804160881d:	48 b8 00 b0 ff ff 7f 	movabs $0x7fffffb000,%rax
  8041608824:	00 00 00 
  8041608827:	48 89 83 b0 00 00 00 	mov    %rax,0xb0(%rbx)
  e->env_tf.tf_cs  = GD_UT | 3;
  804160882e:	66 c7 83 a0 00 00 00 	movw   $0x2b,0xa0(%rbx)
  8041608835:	2b 00 
  e->env_tf.tf_rflags |= FL_IF;
  8041608837:	48 81 8b a8 00 00 00 	orq    $0x200,0xa8(%rbx)
  804160883e:	00 02 00 00 
  e->env_pgfault_upcall = 0;
  8041608842:	48 c7 83 f8 00 00 00 	movq   $0x0,0xf8(%rbx)
  8041608849:	00 00 00 00 
  e->env_ipc_recving = 0;
  804160884d:	c6 83 00 01 00 00 00 	movb   $0x0,0x100(%rbx)
  env_free_list = e->env_link;
  8041608854:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  804160885b:	48 a3 30 45 88 41 80 	movabs %rax,0x8041884530
  8041608862:	00 00 00 
  *newenv_store = e;
  8041608865:	49 89 1c 24          	mov    %rbx,(%r12)
  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608869:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  804160886f:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041608876:	00 00 00 
  8041608879:	be 00 00 00 00       	mov    $0x0,%esi
  804160887e:	48 85 c0             	test   %rax,%rax
  8041608881:	74 06                	je     8041608889 <env_alloc+0x1db>
  8041608883:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041608889:	48 bf 67 e3 60 41 80 	movabs $0x804160e367,%rdi
  8041608890:	00 00 00 
  8041608893:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608898:	48 b9 0d 92 60 41 80 	movabs $0x804160920d,%rcx
  804160889f:	00 00 00 
  80416088a2:	ff d1                	callq  *%rcx
  return 0;
  80416088a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416088a9:	48 83 c4 08          	add    $0x8,%rsp
  80416088ad:	5b                   	pop    %rbx
  80416088ae:	41 5c                	pop    %r12
  80416088b0:	41 5d                	pop    %r13
  80416088b2:	5d                   	pop    %rbp
  80416088b3:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416088b4:	48 89 c1             	mov    %rax,%rcx
  80416088b7:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  80416088be:	00 00 00 
  80416088c1:	be 61 00 00 00       	mov    $0x61,%esi
  80416088c6:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  80416088cd:	00 00 00 
  80416088d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416088d5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416088dc:	00 00 00 
  80416088df:	41 ff d0             	callq  *%r8
    cprintf("accessing %lx\n", (unsigned long)pa);
  80416088e2:	48 bf ba e0 60 41 80 	movabs $0x804160e0ba,%rdi
  80416088e9:	00 00 00 
  80416088ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416088f1:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416088f8:	00 00 00 
  80416088fb:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  80416088fd:	48 ba f8 d7 60 41 80 	movabs $0x804160d7f8,%rdx
  8041608904:	00 00 00 
  8041608907:	be 5a 00 00 00       	mov    $0x5a,%esi
  804160890c:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  8041608913:	00 00 00 
  8041608916:	b8 00 00 00 00       	mov    $0x0,%eax
  804160891b:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608922:	00 00 00 
  8041608925:	ff d1                	callq  *%rcx
    return -E_NO_FREE_ENV;
  8041608927:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  804160892c:	e9 78 ff ff ff       	jmpq   80416088a9 <env_alloc+0x1fb>
    return -E_NO_MEM;
  8041608931:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8041608936:	e9 6e ff ff ff       	jmpq   80416088a9 <env_alloc+0x1fb>

000000804160893b <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  804160893b:	55                   	push   %rbp
  804160893c:	48 89 e5             	mov    %rsp,%rbp
  804160893f:	41 57                	push   %r15
  8041608941:	41 56                	push   %r14
  8041608943:	41 55                	push   %r13
  8041608945:	41 54                	push   %r12
  8041608947:	53                   	push   %rbx
  8041608948:	48 83 ec 38          	sub    $0x38,%rsp
  804160894c:	49 89 fd             	mov    %rdi,%r13
  804160894f:	89 f3                	mov    %esi,%ebx
    
  // LAB 3 code
  struct Env *newenv;
  if (env_alloc(&newenv, 0) < 0) {
  8041608951:	be 00 00 00 00       	mov    $0x0,%esi
  8041608956:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160895a:	48 b8 ae 86 60 41 80 	movabs $0x80416086ae,%rax
  8041608961:	00 00 00 
  8041608964:	ff d0                	callq  *%rax
  8041608966:	85 c0                	test   %eax,%eax
  8041608968:	78 3f                	js     80416089a9 <env_create+0x6e>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  }
      
  newenv->env_type = type;
  804160896a:	4c 8b 7d c8          	mov    -0x38(%rbp),%r15
  804160896e:	41 89 9f d0 00 00 00 	mov    %ebx,0xd0(%r15)
  if (elf->e_magic != ELF_MAGIC) {
  8041608975:	41 81 7d 00 7f 45 4c 	cmpl   $0x464c457f,0x0(%r13)
  804160897c:	46 
  804160897d:	75 54                	jne    80416089d3 <env_create+0x98>
  struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff); // Proghdr = prog header. Он лежит со смещением elf->e_phoff относительно начала фаила
  804160897f:	49 8b 5d 20          	mov    0x20(%r13),%rbx
  __asm __volatile("movq %0,%%cr3"
  8041608983:	49 8b 87 f0 00 00 00 	mov    0xf0(%r15),%rax
  804160898a:	0f 22 d8             	mov    %rax,%cr3
  for (size_t i = 0; i < elf->e_phnum; i++) { // elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  804160898d:	66 41 83 7d 38 00    	cmpw   $0x0,0x38(%r13)
  8041608993:	0f 84 e9 00 00 00    	je     8041608a82 <env_create+0x147>
  8041608999:	4c 01 eb             	add    %r13,%rbx
  804160899c:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  80416089a3:	00 
  80416089a4:	e9 cf 00 00 00       	jmpq   8041608a78 <env_create+0x13d>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  80416089a9:	48 ba 48 e3 60 41 80 	movabs $0x804160e348,%rdx
  80416089b0:	00 00 00 
  80416089b3:	be 17 02 00 00       	mov    $0x217,%esi
  80416089b8:	48 bf 7c e3 60 41 80 	movabs $0x804160e37c,%rdi
  80416089bf:	00 00 00 
  80416089c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416089c7:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416089ce:	00 00 00 
  80416089d1:	ff d1                	callq  *%rcx
    cprintf("Unexpected ELF format\n");
  80416089d3:	48 bf 87 e3 60 41 80 	movabs $0x804160e387,%rdi
  80416089da:	00 00 00 
  80416089dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416089e2:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416089e9:	00 00 00 
  80416089ec:	ff d2                	callq  *%rdx
    return;
  80416089ee:	e9 c5 00 00 00       	jmpq   8041608ab8 <env_create+0x17d>
      void *src = (void *)(binary + ph[i].p_offset);
  80416089f3:	4c 89 e8             	mov    %r13,%rax
  80416089f6:	48 03 43 08          	add    0x8(%rbx),%rax
  80416089fa:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
      void *dst = (void *)ph[i].p_va;
  80416089fe:	4c 8b 73 10          	mov    0x10(%rbx),%r14
      size_t memsz  = ph[i].p_memsz;
  8041608a02:	4c 8b 63 28          	mov    0x28(%rbx),%r12
      size_t filesz = MIN(ph[i].p_filesz, memsz);
  8041608a06:	4c 39 63 20          	cmp    %r12,0x20(%rbx)
  8041608a0a:	4c 89 e0             	mov    %r12,%rax
  8041608a0d:	48 0f 46 43 20       	cmovbe 0x20(%rbx),%rax
  8041608a12:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
      region_alloc(e, (void *)dst, memsz);
  8041608a16:	4c 89 e2             	mov    %r12,%rdx
  8041608a19:	4c 89 f6             	mov    %r14,%rsi
  8041608a1c:	4c 89 ff             	mov    %r15,%rdi
  8041608a1f:	48 b9 fe 84 60 41 80 	movabs $0x80416084fe,%rcx
  8041608a26:	00 00 00 
  8041608a29:	ff d1                	callq  *%rcx
      memcpy(dst, src, filesz);
  8041608a2b:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041608a2f:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041608a33:	4c 89 f7             	mov    %r14,%rdi
  8041608a36:	48 b9 64 c5 60 41 80 	movabs $0x804160c564,%rcx
  8041608a3d:	00 00 00 
  8041608a40:	ff d1                	callq  *%rcx
      memset(dst + filesz, 0, memsz - filesz); // обнуление памяти по адресу dst + filesz, где количество нулей = memsz - filesz. Т.е. зануляем всю выделенную память сегмента кода, оставшуюяся после копирования src. Возможно, эта строка не нужна
  8041608a42:	4c 89 e2             	mov    %r12,%rdx
  8041608a45:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041608a49:	48 29 c2             	sub    %rax,%rdx
  8041608a4c:	49 8d 3c 06          	lea    (%r14,%rax,1),%rdi
  8041608a50:	be 00 00 00 00       	mov    $0x0,%esi
  8041608a55:	48 b8 b3 c4 60 41 80 	movabs $0x804160c4b3,%rax
  8041608a5c:	00 00 00 
  8041608a5f:	ff d0                	callq  *%rax
  for (size_t i = 0; i < elf->e_phnum; i++) { // elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041608a61:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  8041608a66:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041608a6a:	48 83 c3 38          	add    $0x38,%rbx
  8041608a6e:	41 0f b7 45 38       	movzwl 0x38(%r13),%eax
  8041608a73:	48 39 c1             	cmp    %rax,%rcx
  8041608a76:	73 0a                	jae    8041608a82 <env_create+0x147>
    if (ph[i].p_type == ELF_PROG_LOAD) {
  8041608a78:	83 3b 01             	cmpl   $0x1,(%rbx)
  8041608a7b:	75 e4                	jne    8041608a61 <env_create+0x126>
  8041608a7d:	e9 71 ff ff ff       	jmpq   80416089f3 <env_create+0xb8>
  8041608a82:	48 a1 48 5a 88 41 80 	movabs 0x8041885a48,%rax
  8041608a89:	00 00 00 
  8041608a8c:	0f 22 d8             	mov    %rax,%cr3
  e->env_tf.tf_rip = elf->e_entry; //Виртуальный адрес точки входа, которому система передает управление при запуске процесса. в регистр rip записываем адрес точки входа для выполнения процесса
  8041608a8f:	49 8b 45 18          	mov    0x18(%r13),%rax
  8041608a93:	49 89 87 98 00 00 00 	mov    %rax,0x98(%r15)
  region_alloc(e, (void *) (USTACKTOP - USTACKSIZE), USTACKSIZE);
  8041608a9a:	ba 00 40 00 00       	mov    $0x4000,%edx
  8041608a9f:	48 be 00 70 ff ff 7f 	movabs $0x7fffff7000,%rsi
  8041608aa6:	00 00 00 
  8041608aa9:	4c 89 ff             	mov    %r15,%rdi
  8041608aac:	48 b8 fe 84 60 41 80 	movabs $0x80416084fe,%rax
  8041608ab3:	00 00 00 
  8041608ab6:	ff d0                	callq  *%rax

  load_icode(newenv, binary); // load instruction code
  // LAB 3 code end
    
}
  8041608ab8:	48 83 c4 38          	add    $0x38,%rsp
  8041608abc:	5b                   	pop    %rbx
  8041608abd:	41 5c                	pop    %r12
  8041608abf:	41 5d                	pop    %r13
  8041608ac1:	41 5e                	pop    %r14
  8041608ac3:	41 5f                	pop    %r15
  8041608ac5:	5d                   	pop    %rbp
  8041608ac6:	c3                   	retq   

0000008041608ac7 <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041608ac7:	55                   	push   %rbp
  8041608ac8:	48 89 e5             	mov    %rsp,%rbp
  8041608acb:	53                   	push   %rbx
  8041608acc:	48 83 ec 08          	sub    $0x8,%rsp
  8041608ad0:	48 89 fb             	mov    %rdi,%rbx
  physaddr_t pa;

  // If freeing the current environment, switch to kern_pgdir
  // before freeing the page directory, just in case the page
  // gets reused.
  if (e == curenv)
  8041608ad3:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041608ada:	00 00 00 
  8041608add:	48 39 f8             	cmp    %rdi,%rax
  8041608ae0:	0f 84 96 01 00 00    	je     8041608c7c <env_free+0x1b5>
    lcr3(kern_cr3);
#endif

  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608ae6:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608aec:	be 00 00 00 00       	mov    $0x0,%esi
  8041608af1:	48 85 c0             	test   %rax,%rax
  8041608af4:	74 06                	je     8041608afc <env_free+0x35>
  8041608af6:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041608afc:	48 bf 9e e3 60 41 80 	movabs $0x804160e39e,%rdi
  8041608b03:	00 00 00 
  8041608b06:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608b0b:	48 b9 0d 92 60 41 80 	movabs $0x804160920d,%rcx
  8041608b12:	00 00 00 
  8041608b15:	ff d1                	callq  *%rcx
#ifndef CONFIG_KSPACE
  // Flush all mapped pages in the user portion of the address space
  static_assert(UTOP % PTSIZE == 0, "Misaligned UTOP");

  //UTOP < PDPE[1] start, so all mapped memory should be in first PDPE
  pdpe = KADDR(PTE_ADDR(e->env_pml4e[0]));
  8041608b17:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608b1e:	48 8b 08             	mov    (%rax),%rcx
  8041608b21:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041608b28:	48 a1 50 5a 88 41 80 	movabs 0x8041885a50,%rax
  8041608b2f:	00 00 00 
  8041608b32:	48 89 ca             	mov    %rcx,%rdx
  8041608b35:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041608b39:	48 39 d0             	cmp    %rdx,%rax
  8041608b3c:	0f 86 55 01 00 00    	jbe    8041608c97 <env_free+0x1d0>
  return (void *)(pa + KERNBASE);
  8041608b42:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041608b49:	00 00 00 
  8041608b4c:	48 01 d1             	add    %rdx,%rcx
  for (pdpeno = 0; pdpeno <= PDPE(UTOP); pdpeno++) {
    // only look at mapped page directory pointer index
    if (!(pdpe[pdpeno] & PTE_P))
  8041608b4f:	48 8b 31             	mov    (%rcx),%rsi
  8041608b52:	40 f6 c6 01          	test   $0x1,%sil
  8041608b56:	0f 84 63 02 00 00    	je     8041608dbf <env_free+0x2f8>
      continue;

    pgdir       = KADDR(PTE_ADDR(pdpe[pdpeno]));
  8041608b5c:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PGNUM(pa) >= npages)
  8041608b63:	48 89 f7             	mov    %rsi,%rdi
  8041608b66:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608b6a:	48 39 f8             	cmp    %rdi,%rax
  8041608b6d:	0f 86 4f 01 00 00    	jbe    8041608cc2 <env_free+0x1fb>
      page_decref(pa2page(pa));
    }

    // free the page directory
    pa           = PTE_ADDR(pdpe[pdpeno]);
    pdpe[pdpeno] = 0;
  8041608b73:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  if (PPN(pa) >= npages) {
  8041608b7a:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041608b81:	00 00 00 
  8041608b84:	48 3b 38             	cmp    (%rax),%rdi
  8041608b87:	0f 83 63 01 00 00    	jae    8041608cf0 <env_free+0x229>
  return &pages[PPN(pa)];
  8041608b8d:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608b91:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041608b98:	00 00 00 
  8041608b9b:	48 01 c7             	add    %rax,%rdi
    page_decref(pa2page(pa));
  8041608b9e:	48 b8 80 4b 60 41 80 	movabs $0x8041604b80,%rax
  8041608ba5:	00 00 00 
  8041608ba8:	ff d0                	callq  *%rax
  }
  // free the page directory pointer
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  8041608baa:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608bb1:	48 8b 30             	mov    (%rax),%rsi
  8041608bb4:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PPN(pa) >= npages) {
  8041608bbb:	48 89 f7             	mov    %rsi,%rdi
  8041608bbe:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608bc2:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041608bc9:	00 00 00 
  8041608bcc:	48 3b 38             	cmp    (%rax),%rdi
  8041608bcf:	0f 83 60 01 00 00    	jae    8041608d35 <env_free+0x26e>
  return &pages[PPN(pa)];
  8041608bd5:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608bd9:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041608be0:	00 00 00 
  8041608be3:	48 01 c7             	add    %rax,%rdi
  8041608be6:	48 b8 80 4b 60 41 80 	movabs $0x8041604b80,%rax
  8041608bed:	00 00 00 
  8041608bf0:	ff d0                	callq  *%rax
  // free the page map level 4 (PML4)
  e->env_pml4e[0] = 0;
  8041608bf2:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608bf9:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  pa              = e->env_cr3;
  8041608c00:	48 8b b3 f0 00 00 00 	mov    0xf0(%rbx),%rsi
  e->env_pml4e    = 0;
  8041608c07:	48 c7 83 e8 00 00 00 	movq   $0x0,0xe8(%rbx)
  8041608c0e:	00 00 00 00 
  e->env_cr3      = 0;
  8041608c12:	48 c7 83 f0 00 00 00 	movq   $0x0,0xf0(%rbx)
  8041608c19:	00 00 00 00 
  if (PPN(pa) >= npages) {
  8041608c1d:	48 89 f7             	mov    %rsi,%rdi
  8041608c20:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608c24:	48 b8 50 5a 88 41 80 	movabs $0x8041885a50,%rax
  8041608c2b:	00 00 00 
  8041608c2e:	48 3b 38             	cmp    (%rax),%rdi
  8041608c31:	0f 83 43 01 00 00    	jae    8041608d7a <env_free+0x2b3>
  return &pages[PPN(pa)];
  8041608c37:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608c3b:	48 a1 58 5a 88 41 80 	movabs 0x8041885a58,%rax
  8041608c42:	00 00 00 
  8041608c45:	48 01 c7             	add    %rax,%rdi
  page_decref(pa2page(pa));
  8041608c48:	48 b8 80 4b 60 41 80 	movabs $0x8041604b80,%rax
  8041608c4f:	00 00 00 
  8041608c52:	ff d0                	callq  *%rax
#endif
  // return the environment to the free list
  e->env_status = ENV_FREE;
  8041608c54:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  8041608c5b:	00 00 00 
  e->env_link   = env_free_list;
  8041608c5e:	48 b8 30 45 88 41 80 	movabs $0x8041884530,%rax
  8041608c65:	00 00 00 
  8041608c68:	48 8b 10             	mov    (%rax),%rdx
  8041608c6b:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  8041608c72:	48 89 18             	mov    %rbx,(%rax)
}
  8041608c75:	48 83 c4 08          	add    $0x8,%rsp
  8041608c79:	5b                   	pop    %rbx
  8041608c7a:	5d                   	pop    %rbp
  8041608c7b:	c3                   	retq   
  8041608c7c:	48 b9 48 5a 88 41 80 	movabs $0x8041885a48,%rcx
  8041608c83:	00 00 00 
  8041608c86:	48 8b 11             	mov    (%rcx),%rdx
  8041608c89:	0f 22 da             	mov    %rdx,%cr3
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608c8c:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608c92:	e9 5f fe ff ff       	jmpq   8041608af6 <env_free+0x2f>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041608c97:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041608c9e:	00 00 00 
  8041608ca1:	be 3d 02 00 00       	mov    $0x23d,%esi
  8041608ca6:	48 bf 7c e3 60 41 80 	movabs $0x804160e37c,%rdi
  8041608cad:	00 00 00 
  8041608cb0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608cb5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608cbc:	00 00 00 
  8041608cbf:	41 ff d0             	callq  *%r8
  8041608cc2:	48 89 f1             	mov    %rsi,%rcx
  8041608cc5:	48 ba c0 d6 60 41 80 	movabs $0x804160d6c0,%rdx
  8041608ccc:	00 00 00 
  8041608ccf:	be 43 02 00 00       	mov    $0x243,%esi
  8041608cd4:	48 bf 7c e3 60 41 80 	movabs $0x804160e37c,%rdi
  8041608cdb:	00 00 00 
  8041608cde:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ce3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608cea:	00 00 00 
  8041608ced:	41 ff d0             	callq  *%r8
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608cf0:	48 bf ba e0 60 41 80 	movabs $0x804160e0ba,%rdi
  8041608cf7:	00 00 00 
  8041608cfa:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608cff:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041608d06:	00 00 00 
  8041608d09:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608d0b:	48 ba f8 d7 60 41 80 	movabs $0x804160d7f8,%rdx
  8041608d12:	00 00 00 
  8041608d15:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608d1a:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  8041608d21:	00 00 00 
  8041608d24:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d29:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608d30:	00 00 00 
  8041608d33:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608d35:	48 bf ba e0 60 41 80 	movabs $0x804160e0ba,%rdi
  8041608d3c:	00 00 00 
  8041608d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d44:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041608d4b:	00 00 00 
  8041608d4e:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608d50:	48 ba f8 d7 60 41 80 	movabs $0x804160d7f8,%rdx
  8041608d57:	00 00 00 
  8041608d5a:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608d5f:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  8041608d66:	00 00 00 
  8041608d69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d6e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608d75:	00 00 00 
  8041608d78:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608d7a:	48 bf ba e0 60 41 80 	movabs $0x804160e0ba,%rdi
  8041608d81:	00 00 00 
  8041608d84:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d89:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041608d90:	00 00 00 
  8041608d93:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608d95:	48 ba f8 d7 60 41 80 	movabs $0x804160d7f8,%rdx
  8041608d9c:	00 00 00 
  8041608d9f:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608da4:	48 bf 9b e0 60 41 80 	movabs $0x804160e09b,%rdi
  8041608dab:	00 00 00 
  8041608dae:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608db3:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608dba:	00 00 00 
  8041608dbd:	ff d1                	callq  *%rcx
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  8041608dbf:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608dc6:	48 8b 38             	mov    (%rax),%rdi
  8041608dc9:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608dcd:	e9 03 fe ff ff       	jmpq   8041608bd5 <env_free+0x10e>

0000008041608dd2 <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) {
  8041608dd2:	55                   	push   %rbp
  8041608dd3:	48 89 e5             	mov    %rsp,%rbp
  8041608dd6:	53                   	push   %rbx
  8041608dd7:	48 83 ec 08          	sub    $0x8,%rsp
  8041608ddb:	48 89 fb             	mov    %rdi,%rbx
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
    
  // LAB 3 code
  e->env_status = ENV_DYING;
  8041608dde:	c7 87 d4 00 00 00 01 	movl   $0x1,0xd4(%rdi)
  8041608de5:	00 00 00 
  env_free(e);
  8041608de8:	48 b8 c7 8a 60 41 80 	movabs $0x8041608ac7,%rax
  8041608def:	00 00 00 
  8041608df2:	ff d0                	callq  *%rax
  if (e == curenv) {
  8041608df4:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041608dfb:	00 00 00 
  8041608dfe:	48 39 18             	cmp    %rbx,(%rax)
  8041608e01:	74 07                	je     8041608e0a <env_destroy+0x38>
    sched_yield();
  }
  // LAB 3 code end
}
  8041608e03:	48 83 c4 08          	add    $0x8,%rsp
  8041608e07:	5b                   	pop    %rbx
  8041608e08:	5d                   	pop    %rbp
  8041608e09:	c3                   	retq   
    sched_yield();
  8041608e0a:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  8041608e11:	00 00 00 
  8041608e14:	ff d0                	callq  *%rax

0000008041608e16 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041608e16:	55                   	push   %rbp
  8041608e17:	48 89 e5             	mov    %rsp,%rbp
        [ rd15 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r15)),
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
  __asm __volatile("movq %0,%%rsp\n" POPA
  8041608e1a:	48 89 fc             	mov    %rdi,%rsp
  8041608e1d:	4c 8b 3c 24          	mov    (%rsp),%r15
  8041608e21:	4c 8b 74 24 08       	mov    0x8(%rsp),%r14
  8041608e26:	4c 8b 6c 24 10       	mov    0x10(%rsp),%r13
  8041608e2b:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
  8041608e30:	4c 8b 5c 24 20       	mov    0x20(%rsp),%r11
  8041608e35:	4c 8b 54 24 28       	mov    0x28(%rsp),%r10
  8041608e3a:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
  8041608e3f:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
  8041608e44:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
  8041608e49:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
  8041608e4e:	48 8b 6c 24 50       	mov    0x50(%rsp),%rbp
  8041608e53:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
  8041608e58:	48 8b 4c 24 60       	mov    0x60(%rsp),%rcx
  8041608e5d:	48 8b 5c 24 68       	mov    0x68(%rsp),%rbx
  8041608e62:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
  8041608e67:	48 83 c4 78          	add    $0x78,%rsp
  8041608e6b:	8e 04 24             	mov    (%rsp),%es
  8041608e6e:	8e 5c 24 08          	mov    0x8(%rsp),%ds
  8041608e72:	48 83 c4 10          	add    $0x10,%rsp
  8041608e76:	48 83 c4 10          	add    $0x10,%rsp
  8041608e7a:	48 cf                	iretq  
                   "\tiretq"
                   :
                   : "g"(tf)
                   : "memory");
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041608e7c:	48 ba b4 e3 60 41 80 	movabs $0x804160e3b4,%rdx
  8041608e83:	00 00 00 
  8041608e86:	be d3 02 00 00       	mov    $0x2d3,%esi
  8041608e8b:	48 bf 7c e3 60 41 80 	movabs $0x804160e37c,%rdi
  8041608e92:	00 00 00 
  8041608e95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e9a:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608ea1:	00 00 00 
  8041608ea4:	ff d1                	callq  *%rcx

0000008041608ea6 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  8041608ea6:	55                   	push   %rbp
  8041608ea7:	48 89 e5             	mov    %rsp,%rbp
  8041608eaa:	41 54                	push   %r12
  8041608eac:	53                   	push   %rbx
  8041608ead:	48 89 fb             	mov    %rdi,%rbx
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //
    
  // LAB 3 code
  if (curenv) {  // if curenv == False, значит, какого-нибудь исполняемого процесса нет
  8041608eb0:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041608eb7:	00 00 00 
  8041608eba:	4c 8b 20             	mov    (%rax),%r12
  8041608ebd:	4d 85 e4             	test   %r12,%r12
  8041608ec0:	74 12                	je     8041608ed4 <env_run+0x2e>
    if (curenv->env_status == ENV_DYING) { // если процесс стал зомби
  8041608ec2:	41 8b 84 24 d4 00 00 	mov    0xd4(%r12),%eax
  8041608ec9:	00 
  8041608eca:	83 f8 01             	cmp    $0x1,%eax
  8041608ecd:	74 3c                	je     8041608f0b <env_run+0x65>
      struct Env *old = curenv;  // ставим старый адрес
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
      if (old == e) { // e - аргумент функции, который к нам пришел
        sched_yield();  // переключение системными вызовами
      }
    } else if (curenv->env_status == ENV_RUNNING) { // если процесс можем запустить
  8041608ecf:	83 f8 03             	cmp    $0x3,%eax
  8041608ed2:	74 57                	je     8041608f2b <env_run+0x85>
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
    }
  }
      
  curenv = e;  // текущая среда – е
  8041608ed4:	48 89 d8             	mov    %rbx,%rax
  8041608ed7:	48 a3 20 45 88 41 80 	movabs %rax,0x8041884520
  8041608ede:	00 00 00 
  curenv->env_status = ENV_RUNNING; // устанавливаем статус среды на "выполняется"
  8041608ee1:	c7 83 d4 00 00 00 03 	movl   $0x3,0xd4(%rbx)
  8041608ee8:	00 00 00 
  curenv->env_runs++; // обновляем количество работающих контекстов
  8041608eeb:	83 83 d8 00 00 00 01 	addl   $0x1,0xd8(%rbx)
  8041608ef2:	48 8b 83 f0 00 00 00 	mov    0xf0(%rbx),%rax
  8041608ef9:	0f 22 d8             	mov    %rax,%cr3
  // LAB 8 code
  lcr3(curenv->env_cr3);
  // LAB 8 code end

  // LAB 3 code
  env_pop_tf(&curenv->env_tf);
  8041608efc:	48 89 df             	mov    %rbx,%rdi
  8041608eff:	48 b8 16 8e 60 41 80 	movabs $0x8041608e16,%rax
  8041608f06:	00 00 00 
  8041608f09:	ff d0                	callq  *%rax
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
  8041608f0b:	4c 89 e7             	mov    %r12,%rdi
  8041608f0e:	48 b8 c7 8a 60 41 80 	movabs $0x8041608ac7,%rax
  8041608f15:	00 00 00 
  8041608f18:	ff d0                	callq  *%rax
      if (old == e) { // e - аргумент функции, который к нам пришел
  8041608f1a:	49 39 dc             	cmp    %rbx,%r12
  8041608f1d:	75 b5                	jne    8041608ed4 <env_run+0x2e>
        sched_yield();  // переключение системными вызовами
  8041608f1f:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  8041608f26:	00 00 00 
  8041608f29:	ff d0                	callq  *%rax
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
  8041608f2b:	41 c7 84 24 d4 00 00 	movl   $0x2,0xd4(%r12)
  8041608f32:	00 02 00 00 00 
  8041608f37:	eb 9b                	jmp    8041608ed4 <env_run+0x2e>

0000008041608f39 <rtc_timer_pic_interrupt>:
  pic_init();
  rtc_init();
}

static void
rtc_timer_pic_interrupt(void) {
  8041608f39:	55                   	push   %rbp
  8041608f3a:	48 89 e5             	mov    %rsp,%rbp
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  8041608f3d:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  8041608f44:	00 00 00 
  8041608f47:	89 c7                	mov    %eax,%edi
  8041608f49:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  8041608f4f:	48 b8 35 90 60 41 80 	movabs $0x8041609035,%rax
  8041608f56:	00 00 00 
  8041608f59:	ff d0                	callq  *%rax
}
  8041608f5b:	5d                   	pop    %rbp
  8041608f5c:	c3                   	retq   

0000008041608f5d <rtc_init>:
  __asm __volatile("inb %w1,%0"
  8041608f5d:	b9 70 00 00 00       	mov    $0x70,%ecx
  8041608f62:	89 ca                	mov    %ecx,%edx
  8041608f64:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) & ~NMI_LOCK);
}

static inline void
nmi_disable(void) {
  outb(0x70, inb(0x70) | NMI_LOCK);
  8041608f65:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  8041608f68:	ee                   	out    %al,(%dx)
  8041608f69:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041608f6e:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608f6f:	be 71 00 00 00       	mov    $0x71,%esi
  8041608f74:	89 f2                	mov    %esi,%edx
  8041608f76:	ec                   	in     (%dx),%al
  
  // меняем делитель частоты регистра часов А,
  // чтобы прерывания приходили раз в полсекунды
  outb(IO_RTC_CMND, RTC_AREG);
  reg_a = inb(IO_RTC_DATA);
  reg_a = reg_a | 0x0F; // биты 0-3 = 1 => 500 мс (2 Гц) 
  8041608f77:	83 c8 0f             	or     $0xf,%eax
  __asm __volatile("outb %0,%w1"
  8041608f7a:	ee                   	out    %al,(%dx)
  8041608f7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  8041608f80:	89 ca                	mov    %ecx,%edx
  8041608f82:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608f83:	89 f2                	mov    %esi,%edx
  8041608f85:	ec                   	in     (%dx),%al
  outb(IO_RTC_DATA, reg_a);

  // устанавливаем бит RTC_PIE в регистре часов В
  outb(IO_RTC_CMND, RTC_BREG);
  reg_b = inb(IO_RTC_DATA);
  reg_b = reg_b | RTC_PIE; 
  8041608f86:	83 c8 40             	or     $0x40,%eax
  __asm __volatile("outb %0,%w1"
  8041608f89:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608f8a:	89 ca                	mov    %ecx,%edx
  8041608f8c:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  8041608f8d:	83 e0 7f             	and    $0x7f,%eax
  8041608f90:	ee                   	out    %al,(%dx)
  outb(IO_RTC_DATA, reg_b);

  // разрешить прерывания
  nmi_enable();
  // LAB 4 code end
}
  8041608f91:	c3                   	retq   

0000008041608f92 <rtc_timer_init>:
rtc_timer_init(void) {
  8041608f92:	55                   	push   %rbp
  8041608f93:	48 89 e5             	mov    %rsp,%rbp
  pic_init();
  8041608f96:	48 b8 ef 90 60 41 80 	movabs $0x80416090ef,%rax
  8041608f9d:	00 00 00 
  8041608fa0:	ff d0                	callq  *%rax
  rtc_init();
  8041608fa2:	48 b8 5d 8f 60 41 80 	movabs $0x8041608f5d,%rax
  8041608fa9:	00 00 00 
  8041608fac:	ff d0                	callq  *%rax
}
  8041608fae:	5d                   	pop    %rbp
  8041608faf:	c3                   	retq   

0000008041608fb0 <rtc_check_status>:
  8041608fb0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041608fb5:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608fba:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608fbb:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608fc0:	ec                   	in     (%dx),%al
  outb(IO_RTC_CMND, RTC_CREG);
  status = inb(IO_RTC_DATA);
  // LAB 4 code end

  return status;
}
  8041608fc1:	c3                   	retq   

0000008041608fc2 <rtc_timer_pic_handle>:
rtc_timer_pic_handle(void) {
  8041608fc2:	55                   	push   %rbp
  8041608fc3:	48 89 e5             	mov    %rsp,%rbp
  rtc_check_status();
  8041608fc6:	48 b8 b0 8f 60 41 80 	movabs $0x8041608fb0,%rax
  8041608fcd:	00 00 00 
  8041608fd0:	ff d0                	callq  *%rax
  pic_send_eoi(IRQ_CLOCK);
  8041608fd2:	bf 08 00 00 00       	mov    $0x8,%edi
  8041608fd7:	48 b8 9a 91 60 41 80 	movabs $0x804160919a,%rax
  8041608fde:	00 00 00 
  8041608fe1:	ff d0                	callq  *%rax
}
  8041608fe3:	5d                   	pop    %rbp
  8041608fe4:	c3                   	retq   

0000008041608fe5 <mc146818_read>:
  __asm __volatile("outb %0,%w1"
  8041608fe5:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608fea:	89 f8                	mov    %edi,%eax
  8041608fec:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608fed:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608ff2:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg) {
  outb(IO_RTC_CMND, reg);
  return inb(IO_RTC_DATA);
  8041608ff3:	0f b6 c0             	movzbl %al,%eax
}
  8041608ff6:	c3                   	retq   

0000008041608ff7 <mc146818_write>:
  __asm __volatile("outb %0,%w1"
  8041608ff7:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608ffc:	89 f8                	mov    %edi,%eax
  8041608ffe:	ee                   	out    %al,(%dx)
  8041608fff:	ba 71 00 00 00       	mov    $0x71,%edx
  8041609004:	89 f0                	mov    %esi,%eax
  8041609006:	ee                   	out    %al,(%dx)

void
mc146818_write(unsigned reg, unsigned datum) {
  outb(IO_RTC_CMND, reg);
  outb(IO_RTC_DATA, datum);
}
  8041609007:	c3                   	retq   

0000008041609008 <mc146818_read16>:
  8041609008:	41 b8 70 00 00 00    	mov    $0x70,%r8d
  804160900e:	89 f8                	mov    %edi,%eax
  8041609010:	44 89 c2             	mov    %r8d,%edx
  8041609013:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041609014:	b9 71 00 00 00       	mov    $0x71,%ecx
  8041609019:	89 ca                	mov    %ecx,%edx
  804160901b:	ec                   	in     (%dx),%al
  804160901c:	89 c6                	mov    %eax,%esi

unsigned
mc146818_read16(unsigned reg) {
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  804160901e:	8d 47 01             	lea    0x1(%rdi),%eax
  __asm __volatile("outb %0,%w1"
  8041609021:	44 89 c2             	mov    %r8d,%edx
  8041609024:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041609025:	89 ca                	mov    %ecx,%edx
  8041609027:	ec                   	in     (%dx),%al
  return inb(IO_RTC_DATA);
  8041609028:	0f b6 c0             	movzbl %al,%eax
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  804160902b:	c1 e0 08             	shl    $0x8,%eax
  return inb(IO_RTC_DATA);
  804160902e:	40 0f b6 f6          	movzbl %sil,%esi
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041609032:	09 f0                	or     %esi,%eax
  8041609034:	c3                   	retq   

0000008041609035 <irq_setmask_8259A>:
}

void
irq_setmask_8259A(uint16_t mask) {
  int i;
  irq_mask_8259A = mask;
  8041609035:	89 f8                	mov    %edi,%eax
  8041609037:	66 a3 e8 07 62 41 80 	movabs %ax,0x80416207e8
  804160903e:	00 00 00 
  if (!didinit)
  8041609041:	48 b8 38 45 88 41 80 	movabs $0x8041884538,%rax
  8041609048:	00 00 00 
  804160904b:	80 38 00             	cmpb   $0x0,(%rax)
  804160904e:	75 01                	jne    8041609051 <irq_setmask_8259A+0x1c>
  8041609050:	c3                   	retq   
irq_setmask_8259A(uint16_t mask) {
  8041609051:	55                   	push   %rbp
  8041609052:	48 89 e5             	mov    %rsp,%rbp
  8041609055:	41 56                	push   %r14
  8041609057:	41 55                	push   %r13
  8041609059:	41 54                	push   %r12
  804160905b:	53                   	push   %rbx
  804160905c:	41 89 fc             	mov    %edi,%r12d
  804160905f:	89 f8                	mov    %edi,%eax
  __asm __volatile("outb %0,%w1"
  8041609061:	ba 21 00 00 00       	mov    $0x21,%edx
  8041609066:	ee                   	out    %al,(%dx)
    return;
  outb(IO_PIC1_DATA, (char)mask);
  outb(IO_PIC2_DATA, (char)(mask >> 8));
  8041609067:	66 c1 e8 08          	shr    $0x8,%ax
  804160906b:	ba a1 00 00 00       	mov    $0xa1,%edx
  8041609070:	ee                   	out    %al,(%dx)
  cprintf("enabled interrupts:");
  8041609071:	48 bf bc e3 60 41 80 	movabs $0x804160e3bc,%rdi
  8041609078:	00 00 00 
  804160907b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609080:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041609087:	00 00 00 
  804160908a:	ff d2                	callq  *%rdx
  for (i = 0; i < 16; i++)
  804160908c:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (~mask & (1 << i))
  8041609091:	45 0f b7 e4          	movzwl %r12w,%r12d
  8041609095:	41 f7 d4             	not    %r12d
      cprintf(" %d", i);
  8041609098:	49 be 60 ec 60 41 80 	movabs $0x804160ec60,%r14
  804160909f:	00 00 00 
  80416090a2:	49 bd 0d 92 60 41 80 	movabs $0x804160920d,%r13
  80416090a9:	00 00 00 
  80416090ac:	eb 15                	jmp    80416090c3 <irq_setmask_8259A+0x8e>
  80416090ae:	89 de                	mov    %ebx,%esi
  80416090b0:	4c 89 f7             	mov    %r14,%rdi
  80416090b3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416090b8:	41 ff d5             	callq  *%r13
  for (i = 0; i < 16; i++)
  80416090bb:	83 c3 01             	add    $0x1,%ebx
  80416090be:	83 fb 10             	cmp    $0x10,%ebx
  80416090c1:	74 08                	je     80416090cb <irq_setmask_8259A+0x96>
    if (~mask & (1 << i))
  80416090c3:	41 0f a3 dc          	bt     %ebx,%r12d
  80416090c7:	73 f2                	jae    80416090bb <irq_setmask_8259A+0x86>
  80416090c9:	eb e3                	jmp    80416090ae <irq_setmask_8259A+0x79>
  cprintf("\n");
  80416090cb:	48 bf 3f e2 60 41 80 	movabs $0x804160e23f,%rdi
  80416090d2:	00 00 00 
  80416090d5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416090da:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416090e1:	00 00 00 
  80416090e4:	ff d2                	callq  *%rdx
}
  80416090e6:	5b                   	pop    %rbx
  80416090e7:	41 5c                	pop    %r12
  80416090e9:	41 5d                	pop    %r13
  80416090eb:	41 5e                	pop    %r14
  80416090ed:	5d                   	pop    %rbp
  80416090ee:	c3                   	retq   

00000080416090ef <pic_init>:
  didinit = 1;
  80416090ef:	48 b8 38 45 88 41 80 	movabs $0x8041884538,%rax
  80416090f6:	00 00 00 
  80416090f9:	c6 00 01             	movb   $0x1,(%rax)
  80416090fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041609101:	be 21 00 00 00       	mov    $0x21,%esi
  8041609106:	89 f2                	mov    %esi,%edx
  8041609108:	ee                   	out    %al,(%dx)
  8041609109:	b9 a1 00 00 00       	mov    $0xa1,%ecx
  804160910e:	89 ca                	mov    %ecx,%edx
  8041609110:	ee                   	out    %al,(%dx)
  8041609111:	41 b9 11 00 00 00    	mov    $0x11,%r9d
  8041609117:	bf 20 00 00 00       	mov    $0x20,%edi
  804160911c:	44 89 c8             	mov    %r9d,%eax
  804160911f:	89 fa                	mov    %edi,%edx
  8041609121:	ee                   	out    %al,(%dx)
  8041609122:	b8 20 00 00 00       	mov    $0x20,%eax
  8041609127:	89 f2                	mov    %esi,%edx
  8041609129:	ee                   	out    %al,(%dx)
  804160912a:	b8 04 00 00 00       	mov    $0x4,%eax
  804160912f:	ee                   	out    %al,(%dx)
  8041609130:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  8041609136:	44 89 c0             	mov    %r8d,%eax
  8041609139:	ee                   	out    %al,(%dx)
  804160913a:	be a0 00 00 00       	mov    $0xa0,%esi
  804160913f:	44 89 c8             	mov    %r9d,%eax
  8041609142:	89 f2                	mov    %esi,%edx
  8041609144:	ee                   	out    %al,(%dx)
  8041609145:	b8 28 00 00 00       	mov    $0x28,%eax
  804160914a:	89 ca                	mov    %ecx,%edx
  804160914c:	ee                   	out    %al,(%dx)
  804160914d:	b8 02 00 00 00       	mov    $0x2,%eax
  8041609152:	ee                   	out    %al,(%dx)
  8041609153:	44 89 c0             	mov    %r8d,%eax
  8041609156:	ee                   	out    %al,(%dx)
  8041609157:	41 b8 68 00 00 00    	mov    $0x68,%r8d
  804160915d:	44 89 c0             	mov    %r8d,%eax
  8041609160:	89 fa                	mov    %edi,%edx
  8041609162:	ee                   	out    %al,(%dx)
  8041609163:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041609168:	89 c8                	mov    %ecx,%eax
  804160916a:	ee                   	out    %al,(%dx)
  804160916b:	44 89 c0             	mov    %r8d,%eax
  804160916e:	89 f2                	mov    %esi,%edx
  8041609170:	ee                   	out    %al,(%dx)
  8041609171:	89 c8                	mov    %ecx,%eax
  8041609173:	ee                   	out    %al,(%dx)
  if (irq_mask_8259A != 0xFFFF)
  8041609174:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  804160917b:	00 00 00 
  804160917e:	66 83 f8 ff          	cmp    $0xffff,%ax
  8041609182:	75 01                	jne    8041609185 <pic_init+0x96>
  8041609184:	c3                   	retq   
pic_init(void) {
  8041609185:	55                   	push   %rbp
  8041609186:	48 89 e5             	mov    %rsp,%rbp
    irq_setmask_8259A(irq_mask_8259A);
  8041609189:	0f b7 f8             	movzwl %ax,%edi
  804160918c:	48 b8 35 90 60 41 80 	movabs $0x8041609035,%rax
  8041609193:	00 00 00 
  8041609196:	ff d0                	callq  *%rax
}
  8041609198:	5d                   	pop    %rbp
  8041609199:	c3                   	retq   

000000804160919a <pic_send_eoi>:

void
pic_send_eoi(uint8_t irq) {
  if (irq >= 8)
  804160919a:	40 80 ff 07          	cmp    $0x7,%dil
  804160919e:	76 0b                	jbe    80416091ab <pic_send_eoi+0x11>
  80416091a0:	b8 20 00 00 00       	mov    $0x20,%eax
  80416091a5:	ba a0 00 00 00       	mov    $0xa0,%edx
  80416091aa:	ee                   	out    %al,(%dx)
  80416091ab:	b8 20 00 00 00       	mov    $0x20,%eax
  80416091b0:	ba 20 00 00 00       	mov    $0x20,%edx
  80416091b5:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_CMND, PIC_EOI);
  outb(IO_PIC1_CMND, PIC_EOI);
}
  80416091b6:	c3                   	retq   

00000080416091b7 <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  80416091b7:	55                   	push   %rbp
  80416091b8:	48 89 e5             	mov    %rsp,%rbp
  80416091bb:	53                   	push   %rbx
  80416091bc:	48 83 ec 08          	sub    $0x8,%rsp
  80416091c0:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  80416091c3:	48 b8 02 0d 60 41 80 	movabs $0x8041600d02,%rax
  80416091ca:	00 00 00 
  80416091cd:	ff d0                	callq  *%rax
  (*cnt)++;
  80416091cf:	83 03 01             	addl   $0x1,(%rbx)
}
  80416091d2:	48 83 c4 08          	add    $0x8,%rsp
  80416091d6:	5b                   	pop    %rbx
  80416091d7:	5d                   	pop    %rbp
  80416091d8:	c3                   	retq   

00000080416091d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  80416091d9:	55                   	push   %rbp
  80416091da:	48 89 e5             	mov    %rsp,%rbp
  80416091dd:	48 83 ec 10          	sub    $0x10,%rsp
  80416091e1:	48 89 fa             	mov    %rdi,%rdx
  80416091e4:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  80416091e7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  80416091ee:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  80416091f2:	48 bf b7 91 60 41 80 	movabs $0x80416091b7,%rdi
  80416091f9:	00 00 00 
  80416091fc:	48 b8 f5 b9 60 41 80 	movabs $0x804160b9f5,%rax
  8041609203:	00 00 00 
  8041609206:	ff d0                	callq  *%rax
  return cnt;
}
  8041609208:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804160920b:	c9                   	leaveq 
  804160920c:	c3                   	retq   

000000804160920d <cprintf>:

int
cprintf(const char *fmt, ...) {
  804160920d:	55                   	push   %rbp
  804160920e:	48 89 e5             	mov    %rsp,%rbp
  8041609211:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041609218:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  804160921f:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041609226:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160922d:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041609234:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160923b:	84 c0                	test   %al,%al
  804160923d:	74 20                	je     804160925f <cprintf+0x52>
  804160923f:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041609243:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041609247:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160924b:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160924f:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041609253:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041609257:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160925b:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  804160925f:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8041609266:	00 00 00 
  8041609269:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041609270:	00 00 00 
  8041609273:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041609277:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160927e:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041609285:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  804160928c:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041609293:	48 b8 d9 91 60 41 80 	movabs $0x80416091d9,%rax
  804160929a:	00 00 00 
  804160929d:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  804160929f:	c9                   	leaveq 
  80416092a0:	c3                   	retq   

00000080416092a1 <trap_init_percpu>:
// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void) {
  // Setup a TSS so that we get the right stack
  // when we trap to the kernel.
  ts.ts_esp0 = KSTACKTOP;
  80416092a1:	48 ba 60 55 88 41 80 	movabs $0x8041885560,%rdx
  80416092a8:	00 00 00 
  80416092ab:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416092b2:	00 00 00 
  80416092b5:	48 89 42 04          	mov    %rax,0x4(%rdx)

  // Initialize the TSS slot of the gdt.
  SETTSS((struct SystemSegdesc64 *)(&gdt[(GD_TSS0 >> 3)]), STS_T64A,
  80416092b9:	48 b8 60 07 62 41 80 	movabs $0x8041620760,%rax
  80416092c0:	00 00 00 
  80416092c3:	66 c7 40 38 68 00    	movw   $0x68,0x38(%rax)
  80416092c9:	66 89 50 3a          	mov    %dx,0x3a(%rax)
  80416092cd:	48 89 d1             	mov    %rdx,%rcx
  80416092d0:	48 c1 e9 10          	shr    $0x10,%rcx
  80416092d4:	88 48 3c             	mov    %cl,0x3c(%rax)
  80416092d7:	c6 40 3d 89          	movb   $0x89,0x3d(%rax)
  80416092db:	c6 40 3e 00          	movb   $0x0,0x3e(%rax)
  80416092df:	48 89 d1             	mov    %rdx,%rcx
  80416092e2:	48 c1 e9 18          	shr    $0x18,%rcx
  80416092e6:	88 48 3f             	mov    %cl,0x3f(%rax)
  80416092e9:	48 c1 ea 20          	shr    $0x20,%rdx
  80416092ed:	89 50 40             	mov    %edx,0x40(%rax)
  80416092f0:	c6 40 44 00          	movb   $0x0,0x44(%rax)
  80416092f4:	c6 40 45 00          	movb   $0x0,0x45(%rax)
  80416092f8:	66 c7 40 46 00 00    	movw   $0x0,0x46(%rax)
  __asm __volatile("ltr %0"
  80416092fe:	b8 38 00 00 00       	mov    $0x38,%eax
  8041609303:	0f 00 d8             	ltr    %ax
  __asm __volatile("lidt (%0)"
  8041609306:	48 b8 f0 07 62 41 80 	movabs $0x80416207f0,%rax
  804160930d:	00 00 00 
  8041609310:	0f 01 18             	lidt   (%rax)
  // bottom three bits are special; we leave them 0)
  ltr(GD_TSS0);

  // Load the IDT
  lidt(&idt_pd);
}
  8041609313:	c3                   	retq   

0000008041609314 <trap_init>:
trap_init(void) {
  8041609314:	55                   	push   %rbp
  8041609315:	48 89 e5             	mov    %rsp,%rbp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, (uint64_t) &divide_thdlr, 0);
  8041609318:	48 b8 40 45 88 41 80 	movabs $0x8041884540,%rax
  804160931f:	00 00 00 
  8041609322:	48 ba a4 9f 60 41 80 	movabs $0x8041609fa4,%rdx
  8041609329:	00 00 00 
  804160932c:	66 89 10             	mov    %dx,(%rax)
  804160932f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%rax)
  8041609335:	c6 40 04 00          	movb   $0x0,0x4(%rax)
  8041609339:	c6 40 05 8e          	movb   $0x8e,0x5(%rax)
  804160933d:	48 89 d1             	mov    %rdx,%rcx
  8041609340:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609344:	66 89 48 06          	mov    %cx,0x6(%rax)
  8041609348:	48 c1 ea 20          	shr    $0x20,%rdx
  804160934c:	89 50 08             	mov    %edx,0x8(%rax)
  804160934f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%rax)
	SETGATE(idt[T_DEBUG], 0, GD_KT, (uint64_t) &debug_thdlr, 0);
  8041609356:	48 ba aa 9f 60 41 80 	movabs $0x8041609faa,%rdx
  804160935d:	00 00 00 
  8041609360:	66 89 50 10          	mov    %dx,0x10(%rax)
  8041609364:	66 c7 40 12 08 00    	movw   $0x8,0x12(%rax)
  804160936a:	c6 40 14 00          	movb   $0x0,0x14(%rax)
  804160936e:	c6 40 15 8e          	movb   $0x8e,0x15(%rax)
  8041609372:	48 89 d1             	mov    %rdx,%rcx
  8041609375:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609379:	66 89 48 16          	mov    %cx,0x16(%rax)
  804160937d:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609381:	89 50 18             	mov    %edx,0x18(%rax)
  8041609384:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%rax)
	SETGATE(idt[T_NMI], 0, GD_KT, (uint64_t) &nmi_thdlr, 0);
  804160938b:	48 ba b4 9f 60 41 80 	movabs $0x8041609fb4,%rdx
  8041609392:	00 00 00 
  8041609395:	66 89 50 20          	mov    %dx,0x20(%rax)
  8041609399:	66 c7 40 22 08 00    	movw   $0x8,0x22(%rax)
  804160939f:	c6 40 24 00          	movb   $0x0,0x24(%rax)
  80416093a3:	c6 40 25 8e          	movb   $0x8e,0x25(%rax)
  80416093a7:	48 89 d1             	mov    %rdx,%rcx
  80416093aa:	48 c1 e9 10          	shr    $0x10,%rcx
  80416093ae:	66 89 48 26          	mov    %cx,0x26(%rax)
  80416093b2:	48 c1 ea 20          	shr    $0x20,%rdx
  80416093b6:	89 50 28             	mov    %edx,0x28(%rax)
  80416093b9:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%rax)
	SETGATE(idt[T_BRKPT], 0, GD_KT, (uint64_t) &brkpt_thdlr, 3);
  80416093c0:	48 ba be 9f 60 41 80 	movabs $0x8041609fbe,%rdx
  80416093c7:	00 00 00 
  80416093ca:	66 89 50 30          	mov    %dx,0x30(%rax)
  80416093ce:	66 c7 40 32 08 00    	movw   $0x8,0x32(%rax)
  80416093d4:	c6 40 34 00          	movb   $0x0,0x34(%rax)
  80416093d8:	c6 40 35 ee          	movb   $0xee,0x35(%rax)
  80416093dc:	48 89 d1             	mov    %rdx,%rcx
  80416093df:	48 c1 e9 10          	shr    $0x10,%rcx
  80416093e3:	66 89 48 36          	mov    %cx,0x36(%rax)
  80416093e7:	48 c1 ea 20          	shr    $0x20,%rdx
  80416093eb:	89 50 38             	mov    %edx,0x38(%rax)
  80416093ee:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%rax)
	SETGATE(idt[T_OFLOW], 0, GD_KT, (uint64_t) &oflow_thdlr, 0);
  80416093f5:	48 ba c8 9f 60 41 80 	movabs $0x8041609fc8,%rdx
  80416093fc:	00 00 00 
  80416093ff:	66 89 50 40          	mov    %dx,0x40(%rax)
  8041609403:	66 c7 40 42 08 00    	movw   $0x8,0x42(%rax)
  8041609409:	c6 40 44 00          	movb   $0x0,0x44(%rax)
  804160940d:	c6 40 45 8e          	movb   $0x8e,0x45(%rax)
  8041609411:	48 89 d1             	mov    %rdx,%rcx
  8041609414:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609418:	66 89 48 46          	mov    %cx,0x46(%rax)
  804160941c:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609420:	89 50 48             	mov    %edx,0x48(%rax)
  8041609423:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%rax)
	SETGATE(idt[T_BOUND], 0, GD_KT, (uint64_t) &bound_thdlr, 0);
  804160942a:	48 ba d2 9f 60 41 80 	movabs $0x8041609fd2,%rdx
  8041609431:	00 00 00 
  8041609434:	66 89 50 50          	mov    %dx,0x50(%rax)
  8041609438:	66 c7 40 52 08 00    	movw   $0x8,0x52(%rax)
  804160943e:	c6 40 54 00          	movb   $0x0,0x54(%rax)
  8041609442:	c6 40 55 8e          	movb   $0x8e,0x55(%rax)
  8041609446:	48 89 d1             	mov    %rdx,%rcx
  8041609449:	48 c1 e9 10          	shr    $0x10,%rcx
  804160944d:	66 89 48 56          	mov    %cx,0x56(%rax)
  8041609451:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609455:	89 50 58             	mov    %edx,0x58(%rax)
  8041609458:	c7 40 5c 00 00 00 00 	movl   $0x0,0x5c(%rax)
	SETGATE(idt[T_ILLOP], 0, GD_KT, (uint64_t) &illop_thdlr, 0);
  804160945f:	48 ba dc 9f 60 41 80 	movabs $0x8041609fdc,%rdx
  8041609466:	00 00 00 
  8041609469:	66 89 50 60          	mov    %dx,0x60(%rax)
  804160946d:	66 c7 40 62 08 00    	movw   $0x8,0x62(%rax)
  8041609473:	c6 40 64 00          	movb   $0x0,0x64(%rax)
  8041609477:	c6 40 65 8e          	movb   $0x8e,0x65(%rax)
  804160947b:	48 89 d1             	mov    %rdx,%rcx
  804160947e:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609482:	66 89 48 66          	mov    %cx,0x66(%rax)
  8041609486:	48 c1 ea 20          	shr    $0x20,%rdx
  804160948a:	89 50 68             	mov    %edx,0x68(%rax)
  804160948d:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%rax)
	SETGATE(idt[T_DEVICE], 0, GD_KT, (uint64_t) &device_thdlr, 0);
  8041609494:	48 ba e6 9f 60 41 80 	movabs $0x8041609fe6,%rdx
  804160949b:	00 00 00 
  804160949e:	66 89 50 70          	mov    %dx,0x70(%rax)
  80416094a2:	66 c7 40 72 08 00    	movw   $0x8,0x72(%rax)
  80416094a8:	c6 40 74 00          	movb   $0x0,0x74(%rax)
  80416094ac:	c6 40 75 8e          	movb   $0x8e,0x75(%rax)
  80416094b0:	48 89 d1             	mov    %rdx,%rcx
  80416094b3:	48 c1 e9 10          	shr    $0x10,%rcx
  80416094b7:	66 89 48 76          	mov    %cx,0x76(%rax)
  80416094bb:	48 c1 ea 20          	shr    $0x20,%rdx
  80416094bf:	89 50 78             	mov    %edx,0x78(%rax)
  80416094c2:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%rax)
	SETGATE(idt[T_TSS], 0, GD_KT, (uint64_t) &tss_thdlr, 0);
  80416094c9:	48 ba f8 9f 60 41 80 	movabs $0x8041609ff8,%rdx
  80416094d0:	00 00 00 
  80416094d3:	66 89 90 a0 00 00 00 	mov    %dx,0xa0(%rax)
  80416094da:	66 c7 80 a2 00 00 00 	movw   $0x8,0xa2(%rax)
  80416094e1:	08 00 
  80416094e3:	c6 80 a4 00 00 00 00 	movb   $0x0,0xa4(%rax)
  80416094ea:	c6 80 a5 00 00 00 8e 	movb   $0x8e,0xa5(%rax)
  80416094f1:	48 89 d1             	mov    %rdx,%rcx
  80416094f4:	48 c1 e9 10          	shr    $0x10,%rcx
  80416094f8:	66 89 88 a6 00 00 00 	mov    %cx,0xa6(%rax)
  80416094ff:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609503:	89 90 a8 00 00 00    	mov    %edx,0xa8(%rax)
  8041609509:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%rax)
  8041609510:	00 00 00 
	SETGATE(idt[T_SEGNP], 0, GD_KT, (uint64_t) &segnp_thdlr, 0);
  8041609513:	48 ba 00 a0 60 41 80 	movabs $0x804160a000,%rdx
  804160951a:	00 00 00 
  804160951d:	66 89 90 b0 00 00 00 	mov    %dx,0xb0(%rax)
  8041609524:	66 c7 80 b2 00 00 00 	movw   $0x8,0xb2(%rax)
  804160952b:	08 00 
  804160952d:	c6 80 b4 00 00 00 00 	movb   $0x0,0xb4(%rax)
  8041609534:	c6 80 b5 00 00 00 8e 	movb   $0x8e,0xb5(%rax)
  804160953b:	48 89 d1             	mov    %rdx,%rcx
  804160953e:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609542:	66 89 88 b6 00 00 00 	mov    %cx,0xb6(%rax)
  8041609549:	48 c1 ea 20          	shr    $0x20,%rdx
  804160954d:	89 90 b8 00 00 00    	mov    %edx,0xb8(%rax)
  8041609553:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%rax)
  804160955a:	00 00 00 
	SETGATE(idt[T_STACK], 0, GD_KT, (uint64_t) &stack_thdlr, 0);
  804160955d:	48 ba 08 a0 60 41 80 	movabs $0x804160a008,%rdx
  8041609564:	00 00 00 
  8041609567:	66 89 90 c0 00 00 00 	mov    %dx,0xc0(%rax)
  804160956e:	66 c7 80 c2 00 00 00 	movw   $0x8,0xc2(%rax)
  8041609575:	08 00 
  8041609577:	c6 80 c4 00 00 00 00 	movb   $0x0,0xc4(%rax)
  804160957e:	c6 80 c5 00 00 00 8e 	movb   $0x8e,0xc5(%rax)
  8041609585:	48 89 d1             	mov    %rdx,%rcx
  8041609588:	48 c1 e9 10          	shr    $0x10,%rcx
  804160958c:	66 89 88 c6 00 00 00 	mov    %cx,0xc6(%rax)
  8041609593:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609597:	89 90 c8 00 00 00    	mov    %edx,0xc8(%rax)
  804160959d:	c7 80 cc 00 00 00 00 	movl   $0x0,0xcc(%rax)
  80416095a4:	00 00 00 
	SETGATE(idt[T_GPFLT], 0, GD_KT, (uint64_t) &gpflt_thdlr, 0);
  80416095a7:	48 ba 10 a0 60 41 80 	movabs $0x804160a010,%rdx
  80416095ae:	00 00 00 
  80416095b1:	66 89 90 d0 00 00 00 	mov    %dx,0xd0(%rax)
  80416095b8:	66 c7 80 d2 00 00 00 	movw   $0x8,0xd2(%rax)
  80416095bf:	08 00 
  80416095c1:	c6 80 d4 00 00 00 00 	movb   $0x0,0xd4(%rax)
  80416095c8:	c6 80 d5 00 00 00 8e 	movb   $0x8e,0xd5(%rax)
  80416095cf:	48 89 d1             	mov    %rdx,%rcx
  80416095d2:	48 c1 e9 10          	shr    $0x10,%rcx
  80416095d6:	66 89 88 d6 00 00 00 	mov    %cx,0xd6(%rax)
  80416095dd:	48 c1 ea 20          	shr    $0x20,%rdx
  80416095e1:	89 90 d8 00 00 00    	mov    %edx,0xd8(%rax)
  80416095e7:	c7 80 dc 00 00 00 00 	movl   $0x0,0xdc(%rax)
  80416095ee:	00 00 00 
	SETGATE(idt[T_PGFLT], 0, GD_KT, (uint64_t) &pgflt_thdlr, 0);
  80416095f1:	48 ba 18 a0 60 41 80 	movabs $0x804160a018,%rdx
  80416095f8:	00 00 00 
  80416095fb:	66 89 90 e0 00 00 00 	mov    %dx,0xe0(%rax)
  8041609602:	66 c7 80 e2 00 00 00 	movw   $0x8,0xe2(%rax)
  8041609609:	08 00 
  804160960b:	c6 80 e4 00 00 00 00 	movb   $0x0,0xe4(%rax)
  8041609612:	c6 80 e5 00 00 00 8e 	movb   $0x8e,0xe5(%rax)
  8041609619:	48 89 d1             	mov    %rdx,%rcx
  804160961c:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609620:	66 89 88 e6 00 00 00 	mov    %cx,0xe6(%rax)
  8041609627:	48 c1 ea 20          	shr    $0x20,%rdx
  804160962b:	89 90 e8 00 00 00    	mov    %edx,0xe8(%rax)
  8041609631:	c7 80 ec 00 00 00 00 	movl   $0x0,0xec(%rax)
  8041609638:	00 00 00 
	SETGATE(idt[T_FPERR], 0, GD_KT, (uint64_t) &fperr_thdlr, 0);
  804160963b:	48 ba 20 a0 60 41 80 	movabs $0x804160a020,%rdx
  8041609642:	00 00 00 
  8041609645:	66 89 90 00 01 00 00 	mov    %dx,0x100(%rax)
  804160964c:	66 c7 80 02 01 00 00 	movw   $0x8,0x102(%rax)
  8041609653:	08 00 
  8041609655:	c6 80 04 01 00 00 00 	movb   $0x0,0x104(%rax)
  804160965c:	c6 80 05 01 00 00 8e 	movb   $0x8e,0x105(%rax)
  8041609663:	48 89 d1             	mov    %rdx,%rcx
  8041609666:	48 c1 e9 10          	shr    $0x10,%rcx
  804160966a:	66 89 88 06 01 00 00 	mov    %cx,0x106(%rax)
  8041609671:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609675:	89 90 08 01 00 00    	mov    %edx,0x108(%rax)
  804160967b:	c7 80 0c 01 00 00 00 	movl   $0x0,0x10c(%rax)
  8041609682:	00 00 00 
  SETGATE(idt[T_SYSCALL], 0, GD_KT, (uint64_t) &syscall_thdlr, 3);
  8041609685:	48 ba 46 a0 60 41 80 	movabs $0x804160a046,%rdx
  804160968c:	00 00 00 
  804160968f:	66 89 90 00 03 00 00 	mov    %dx,0x300(%rax)
  8041609696:	66 c7 80 02 03 00 00 	movw   $0x8,0x302(%rax)
  804160969d:	08 00 
  804160969f:	c6 80 04 03 00 00 00 	movb   $0x0,0x304(%rax)
  80416096a6:	c6 80 05 03 00 00 ee 	movb   $0xee,0x305(%rax)
  80416096ad:	48 89 d1             	mov    %rdx,%rcx
  80416096b0:	48 c1 e9 10          	shr    $0x10,%rcx
  80416096b4:	66 89 88 06 03 00 00 	mov    %cx,0x306(%rax)
  80416096bb:	48 c1 ea 20          	shr    $0x20,%rdx
  80416096bf:	89 90 08 03 00 00    	mov    %edx,0x308(%rax)
  80416096c5:	c7 80 0c 03 00 00 00 	movl   $0x0,0x30c(%rax)
  80416096cc:	00 00 00 
  trap_init_percpu();
  80416096cf:	48 b8 a1 92 60 41 80 	movabs $0x80416092a1,%rax
  80416096d6:	00 00 00 
  80416096d9:	ff d0                	callq  *%rax
}
  80416096db:	5d                   	pop    %rbp
  80416096dc:	c3                   	retq   

00000080416096dd <clock_idt_init>:

void
clock_idt_init(void) {
  extern void (*clock_thdlr)(void);
  // init idt structure
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  80416096dd:	48 ba 9e 9f 60 41 80 	movabs $0x8041609f9e,%rdx
  80416096e4:	00 00 00 
  80416096e7:	48 b8 40 45 88 41 80 	movabs $0x8041884540,%rax
  80416096ee:	00 00 00 
  80416096f1:	66 89 90 00 02 00 00 	mov    %dx,0x200(%rax)
  80416096f8:	66 c7 80 02 02 00 00 	movw   $0x8,0x202(%rax)
  80416096ff:	08 00 
  8041609701:	c6 80 04 02 00 00 00 	movb   $0x0,0x204(%rax)
  8041609708:	c6 80 05 02 00 00 8e 	movb   $0x8e,0x205(%rax)
  804160970f:	48 89 d6             	mov    %rdx,%rsi
  8041609712:	48 c1 ee 10          	shr    $0x10,%rsi
  8041609716:	66 89 b0 06 02 00 00 	mov    %si,0x206(%rax)
  804160971d:	48 89 d1             	mov    %rdx,%rcx
  8041609720:	48 c1 e9 20          	shr    $0x20,%rcx
  8041609724:	89 88 08 02 00 00    	mov    %ecx,0x208(%rax)
  804160972a:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%rax)
  8041609731:	00 00 00 
  SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041609734:	66 89 90 80 02 00 00 	mov    %dx,0x280(%rax)
  804160973b:	66 c7 80 82 02 00 00 	movw   $0x8,0x282(%rax)
  8041609742:	08 00 
  8041609744:	c6 80 84 02 00 00 00 	movb   $0x0,0x284(%rax)
  804160974b:	c6 80 85 02 00 00 8e 	movb   $0x8e,0x285(%rax)
  8041609752:	66 89 b0 86 02 00 00 	mov    %si,0x286(%rax)
  8041609759:	89 88 88 02 00 00    	mov    %ecx,0x288(%rax)
  804160975f:	c7 80 8c 02 00 00 00 	movl   $0x0,0x28c(%rax)
  8041609766:	00 00 00 
  8041609769:	48 b8 f0 07 62 41 80 	movabs $0x80416207f0,%rax
  8041609770:	00 00 00 
  8041609773:	0f 01 18             	lidt   (%rax)
  lidt(&idt_pd);
}
  8041609776:	c3                   	retq   

0000008041609777 <print_regs>:
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  }
}

void
print_regs(struct PushRegs *regs) {
  8041609777:	55                   	push   %rbp
  8041609778:	48 89 e5             	mov    %rsp,%rbp
  804160977b:	41 54                	push   %r12
  804160977d:	53                   	push   %rbx
  804160977e:	49 89 fc             	mov    %rdi,%r12
  cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  8041609781:	48 8b 37             	mov    (%rdi),%rsi
  8041609784:	48 bf d0 e3 60 41 80 	movabs $0x804160e3d0,%rdi
  804160978b:	00 00 00 
  804160978e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609793:	48 bb 0d 92 60 41 80 	movabs $0x804160920d,%rbx
  804160979a:	00 00 00 
  804160979d:	ff d3                	callq  *%rbx
  cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  804160979f:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
  80416097a4:	48 bf e0 e3 60 41 80 	movabs $0x804160e3e0,%rdi
  80416097ab:	00 00 00 
  80416097ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097b3:	ff d3                	callq  *%rbx
  cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  80416097b5:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  80416097ba:	48 bf f0 e3 60 41 80 	movabs $0x804160e3f0,%rdi
  80416097c1:	00 00 00 
  80416097c4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097c9:	ff d3                	callq  *%rbx
  cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  80416097cb:	49 8b 74 24 18       	mov    0x18(%r12),%rsi
  80416097d0:	48 bf 00 e4 60 41 80 	movabs $0x804160e400,%rdi
  80416097d7:	00 00 00 
  80416097da:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097df:	ff d3                	callq  *%rbx
  cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  80416097e1:	49 8b 74 24 20       	mov    0x20(%r12),%rsi
  80416097e6:	48 bf 10 e4 60 41 80 	movabs $0x804160e410,%rdi
  80416097ed:	00 00 00 
  80416097f0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097f5:	ff d3                	callq  *%rbx
  cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  80416097f7:	49 8b 74 24 28       	mov    0x28(%r12),%rsi
  80416097fc:	48 bf 20 e4 60 41 80 	movabs $0x804160e420,%rdi
  8041609803:	00 00 00 
  8041609806:	b8 00 00 00 00       	mov    $0x0,%eax
  804160980b:	ff d3                	callq  *%rbx
  cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  804160980d:	49 8b 74 24 30       	mov    0x30(%r12),%rsi
  8041609812:	48 bf 30 e4 60 41 80 	movabs $0x804160e430,%rdi
  8041609819:	00 00 00 
  804160981c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609821:	ff d3                	callq  *%rbx
  cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  8041609823:	49 8b 74 24 38       	mov    0x38(%r12),%rsi
  8041609828:	48 bf 40 e4 60 41 80 	movabs $0x804160e440,%rdi
  804160982f:	00 00 00 
  8041609832:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609837:	ff d3                	callq  *%rbx
  cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  8041609839:	49 8b 74 24 48       	mov    0x48(%r12),%rsi
  804160983e:	48 bf 50 e4 60 41 80 	movabs $0x804160e450,%rdi
  8041609845:	00 00 00 
  8041609848:	b8 00 00 00 00       	mov    $0x0,%eax
  804160984d:	ff d3                	callq  *%rbx
  cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  804160984f:	49 8b 74 24 40       	mov    0x40(%r12),%rsi
  8041609854:	48 bf 60 e4 60 41 80 	movabs $0x804160e460,%rdi
  804160985b:	00 00 00 
  804160985e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609863:	ff d3                	callq  *%rbx
  cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  8041609865:	49 8b 74 24 50       	mov    0x50(%r12),%rsi
  804160986a:	48 bf 70 e4 60 41 80 	movabs $0x804160e470,%rdi
  8041609871:	00 00 00 
  8041609874:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609879:	ff d3                	callq  *%rbx
  cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  804160987b:	49 8b 74 24 68       	mov    0x68(%r12),%rsi
  8041609880:	48 bf 80 e4 60 41 80 	movabs $0x804160e480,%rdi
  8041609887:	00 00 00 
  804160988a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160988f:	ff d3                	callq  *%rbx
  cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  8041609891:	49 8b 74 24 58       	mov    0x58(%r12),%rsi
  8041609896:	48 bf 90 e4 60 41 80 	movabs $0x804160e490,%rdi
  804160989d:	00 00 00 
  80416098a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098a5:	ff d3                	callq  *%rbx
  cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  80416098a7:	49 8b 74 24 60       	mov    0x60(%r12),%rsi
  80416098ac:	48 bf a0 e4 60 41 80 	movabs $0x804160e4a0,%rdi
  80416098b3:	00 00 00 
  80416098b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098bb:	ff d3                	callq  *%rbx
  cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
  80416098bd:	49 8b 74 24 70       	mov    0x70(%r12),%rsi
  80416098c2:	48 bf b0 e4 60 41 80 	movabs $0x804160e4b0,%rdi
  80416098c9:	00 00 00 
  80416098cc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098d1:	ff d3                	callq  *%rbx
}
  80416098d3:	5b                   	pop    %rbx
  80416098d4:	41 5c                	pop    %r12
  80416098d6:	5d                   	pop    %rbp
  80416098d7:	c3                   	retq   

00000080416098d8 <print_trapframe>:
print_trapframe(struct Trapframe *tf) {
  80416098d8:	55                   	push   %rbp
  80416098d9:	48 89 e5             	mov    %rsp,%rbp
  80416098dc:	41 54                	push   %r12
  80416098de:	53                   	push   %rbx
  80416098df:	48 89 fb             	mov    %rdi,%rbx
  cprintf("TRAP frame at %p\n", tf);
  80416098e2:	48 89 fe             	mov    %rdi,%rsi
  80416098e5:	48 bf 15 e5 60 41 80 	movabs $0x804160e515,%rdi
  80416098ec:	00 00 00 
  80416098ef:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098f4:	49 bc 0d 92 60 41 80 	movabs $0x804160920d,%r12
  80416098fb:	00 00 00 
  80416098fe:	41 ff d4             	callq  *%r12
  print_regs(&tf->tf_regs);
  8041609901:	48 89 df             	mov    %rbx,%rdi
  8041609904:	48 b8 77 97 60 41 80 	movabs $0x8041609777,%rax
  804160990b:	00 00 00 
  804160990e:	ff d0                	callq  *%rax
  cprintf("  es   0x----%04x\n", tf->tf_es);
  8041609910:	0f b7 73 78          	movzwl 0x78(%rbx),%esi
  8041609914:	48 bf 27 e5 60 41 80 	movabs $0x804160e527,%rdi
  804160991b:	00 00 00 
  804160991e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609923:	41 ff d4             	callq  *%r12
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  8041609926:	0f b7 b3 80 00 00 00 	movzwl 0x80(%rbx),%esi
  804160992d:	48 bf 3a e5 60 41 80 	movabs $0x804160e53a,%rdi
  8041609934:	00 00 00 
  8041609937:	b8 00 00 00 00       	mov    $0x0,%eax
  804160993c:	41 ff d4             	callq  *%r12
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  804160993f:	48 8b b3 88 00 00 00 	mov    0x88(%rbx),%rsi
  if (trapno < sizeof(excnames) / sizeof(excnames[0]))
  8041609946:	83 fe 13             	cmp    $0x13,%esi
  8041609949:	0f 86 68 01 00 00    	jbe    8041609ab7 <print_trapframe+0x1df>
    return "System call";
  804160994f:	48 ba c0 e4 60 41 80 	movabs $0x804160e4c0,%rdx
  8041609956:	00 00 00 
  if (trapno == T_SYSCALL)
  8041609959:	83 fe 30             	cmp    $0x30,%esi
  804160995c:	74 1e                	je     804160997c <print_trapframe+0xa4>
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  804160995e:	8d 46 e0             	lea    -0x20(%rsi),%eax
    return "Hardware Interrupt";
  8041609961:	83 f8 0f             	cmp    $0xf,%eax
  8041609964:	48 ba cc e4 60 41 80 	movabs $0x804160e4cc,%rdx
  804160996b:	00 00 00 
  804160996e:	48 b8 db e4 60 41 80 	movabs $0x804160e4db,%rax
  8041609975:	00 00 00 
  8041609978:	48 0f 46 d0          	cmovbe %rax,%rdx
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  804160997c:	48 bf 4d e5 60 41 80 	movabs $0x804160e54d,%rdi
  8041609983:	00 00 00 
  8041609986:	b8 00 00 00 00       	mov    $0x0,%eax
  804160998b:	48 b9 0d 92 60 41 80 	movabs $0x804160920d,%rcx
  8041609992:	00 00 00 
  8041609995:	ff d1                	callq  *%rcx
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041609997:	48 b8 40 55 88 41 80 	movabs $0x8041885540,%rax
  804160999e:	00 00 00 
  80416099a1:	48 39 18             	cmp    %rbx,(%rax)
  80416099a4:	0f 84 23 01 00 00    	je     8041609acd <print_trapframe+0x1f5>
  cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  80416099aa:	48 8b b3 90 00 00 00 	mov    0x90(%rbx),%rsi
  80416099b1:	48 bf 70 e5 60 41 80 	movabs $0x804160e570,%rdi
  80416099b8:	00 00 00 
  80416099bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416099c0:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  80416099c7:	00 00 00 
  80416099ca:	ff d2                	callq  *%rdx
  if (tf->tf_trapno == T_PGFLT)
  80416099cc:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  80416099d3:	0e 
  80416099d4:	0f 85 24 01 00 00    	jne    8041609afe <print_trapframe+0x226>
            tf->tf_err & 1 ? "protection" : "not-present");
  80416099da:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
    cprintf(" [%s, %s, %s]\n",
  80416099e1:	48 89 c2             	mov    %rax,%rdx
  80416099e4:	83 e2 01             	and    $0x1,%edx
  80416099e7:	48 b9 ee e4 60 41 80 	movabs $0x804160e4ee,%rcx
  80416099ee:	00 00 00 
  80416099f1:	48 ba f9 e4 60 41 80 	movabs $0x804160e4f9,%rdx
  80416099f8:	00 00 00 
  80416099fb:	48 0f 44 ca          	cmove  %rdx,%rcx
  80416099ff:	48 89 c2             	mov    %rax,%rdx
  8041609a02:	83 e2 02             	and    $0x2,%edx
  8041609a05:	48 ba 05 e5 60 41 80 	movabs $0x804160e505,%rdx
  8041609a0c:	00 00 00 
  8041609a0f:	48 be 0b e5 60 41 80 	movabs $0x804160e50b,%rsi
  8041609a16:	00 00 00 
  8041609a19:	48 0f 44 d6          	cmove  %rsi,%rdx
  8041609a1d:	83 e0 04             	and    $0x4,%eax
  8041609a20:	48 be 10 e5 60 41 80 	movabs $0x804160e510,%rsi
  8041609a27:	00 00 00 
  8041609a2a:	48 b8 55 e6 60 41 80 	movabs $0x804160e655,%rax
  8041609a31:	00 00 00 
  8041609a34:	48 0f 44 f0          	cmove  %rax,%rsi
  8041609a38:	48 bf 7f e5 60 41 80 	movabs $0x804160e57f,%rdi
  8041609a3f:	00 00 00 
  8041609a42:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a47:	49 b8 0d 92 60 41 80 	movabs $0x804160920d,%r8
  8041609a4e:	00 00 00 
  8041609a51:	41 ff d0             	callq  *%r8
  cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  8041609a54:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
  8041609a5b:	48 bf 8e e5 60 41 80 	movabs $0x804160e58e,%rdi
  8041609a62:	00 00 00 
  8041609a65:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a6a:	49 bc 0d 92 60 41 80 	movabs $0x804160920d,%r12
  8041609a71:	00 00 00 
  8041609a74:	41 ff d4             	callq  *%r12
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8041609a77:	0f b7 b3 a0 00 00 00 	movzwl 0xa0(%rbx),%esi
  8041609a7e:	48 bf 9e e5 60 41 80 	movabs $0x804160e59e,%rdi
  8041609a85:	00 00 00 
  8041609a88:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a8d:	41 ff d4             	callq  *%r12
  cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  8041609a90:	48 8b b3 a8 00 00 00 	mov    0xa8(%rbx),%rsi
  8041609a97:	48 bf b1 e5 60 41 80 	movabs $0x804160e5b1,%rdi
  8041609a9e:	00 00 00 
  8041609aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609aa6:	41 ff d4             	callq  *%r12
  if ((tf->tf_cs & 3) != 0) {
  8041609aa9:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041609ab0:	75 6c                	jne    8041609b1e <print_trapframe+0x246>
}
  8041609ab2:	5b                   	pop    %rbx
  8041609ab3:	41 5c                	pop    %r12
  8041609ab5:	5d                   	pop    %rbp
  8041609ab6:	c3                   	retq   
    return excnames[trapno];
  8041609ab7:	48 63 c6             	movslq %esi,%rax
  8041609aba:	48 ba e0 e7 60 41 80 	movabs $0x804160e7e0,%rdx
  8041609ac1:	00 00 00 
  8041609ac4:	48 8b 14 c2          	mov    (%rdx,%rax,8),%rdx
  8041609ac8:	e9 af fe ff ff       	jmpq   804160997c <print_trapframe+0xa4>
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041609acd:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041609ad4:	0e 
  8041609ad5:	0f 85 cf fe ff ff    	jne    80416099aa <print_trapframe+0xd2>
  __asm __volatile("movq %%cr2,%0"
  8041609adb:	0f 20 d6             	mov    %cr2,%rsi
    cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  8041609ade:	48 bf 60 e5 60 41 80 	movabs $0x804160e560,%rdi
  8041609ae5:	00 00 00 
  8041609ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609aed:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041609af4:	00 00 00 
  8041609af7:	ff d2                	callq  *%rdx
  8041609af9:	e9 ac fe ff ff       	jmpq   80416099aa <print_trapframe+0xd2>
    cprintf("\n");
  8041609afe:	48 bf 3f e2 60 41 80 	movabs $0x804160e23f,%rdi
  8041609b05:	00 00 00 
  8041609b08:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b0d:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041609b14:	00 00 00 
  8041609b17:	ff d2                	callq  *%rdx
  8041609b19:	e9 36 ff ff ff       	jmpq   8041609a54 <print_trapframe+0x17c>
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
  8041609b1e:	48 8b b3 b0 00 00 00 	mov    0xb0(%rbx),%rsi
  8041609b25:	48 bf c1 e5 60 41 80 	movabs $0x804160e5c1,%rdi
  8041609b2c:	00 00 00 
  8041609b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b34:	41 ff d4             	callq  *%r12
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  8041609b37:	0f b7 b3 b8 00 00 00 	movzwl 0xb8(%rbx),%esi
  8041609b3e:	48 bf d1 e5 60 41 80 	movabs $0x804160e5d1,%rdi
  8041609b45:	00 00 00 
  8041609b48:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b4d:	41 ff d4             	callq  *%r12
}
  8041609b50:	e9 5d ff ff ff       	jmpq   8041609ab2 <print_trapframe+0x1da>

0000008041609b55 <page_fault_handler>:
  else
    sched_yield();
}

void
page_fault_handler(struct Trapframe *tf) {
  8041609b55:	55                   	push   %rbp
  8041609b56:	48 89 e5             	mov    %rsp,%rbp
  8041609b59:	41 56                	push   %r14
  8041609b5b:	41 55                	push   %r13
  8041609b5d:	41 54                	push   %r12
  8041609b5f:	53                   	push   %rbx
  8041609b60:	41 0f 20 d4          	mov    %cr2,%r12
  fault_va = rcr2();

  // Handle kernel-mode page faults.

  // LAB 8 code
  if (!(tf->tf_cs & 3)) {
  8041609b64:	f6 87 a0 00 00 00 03 	testb  $0x3,0xa0(%rdi)
  8041609b6b:	74 78                	je     8041609be5 <page_fault_handler+0x90>
  8041609b6d:	48 89 fb             	mov    %rdi,%rbx

  // LAB 9 code
  struct UTrapframe *utf;
	uintptr_t uxrsp;

  if (curenv->env_pgfault_upcall) {
  8041609b70:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041609b77:	00 00 00 
  8041609b7a:	48 83 b8 f8 00 00 00 	cmpq   $0x0,0xf8(%rax)
  8041609b81:	00 
  8041609b82:	0f 85 87 00 00 00    	jne    8041609c0f <page_fault_handler+0xba>
  // LAB 9 code end

	// Destroy the environment that caused the fault.

  // LAB 8 code
	cprintf("[%08x] user fault va %08lx ip %08lx\n",
  8041609b88:	48 8b 8f 98 00 00 00 	mov    0x98(%rdi),%rcx
  8041609b8f:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041609b95:	4c 89 e2             	mov    %r12,%rdx
  8041609b98:	48 bf a0 e7 60 41 80 	movabs $0x804160e7a0,%rdi
  8041609b9f:	00 00 00 
  8041609ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ba7:	49 b8 0d 92 60 41 80 	movabs $0x804160920d,%r8
  8041609bae:	00 00 00 
  8041609bb1:	41 ff d0             	callq  *%r8
		curenv->env_id, fault_va, tf->tf_rip);
	print_trapframe(tf);
  8041609bb4:	48 89 df             	mov    %rbx,%rdi
  8041609bb7:	48 b8 d8 98 60 41 80 	movabs $0x80416098d8,%rax
  8041609bbe:	00 00 00 
  8041609bc1:	ff d0                	callq  *%rax
	env_destroy(curenv);
  8041609bc3:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609bca:	00 00 00 
  8041609bcd:	48 8b 38             	mov    (%rax),%rdi
  8041609bd0:	48 b8 d2 8d 60 41 80 	movabs $0x8041608dd2,%rax
  8041609bd7:	00 00 00 
  8041609bda:	ff d0                	callq  *%rax
  // LAB 8 code end
}
  8041609bdc:	5b                   	pop    %rbx
  8041609bdd:	41 5c                	pop    %r12
  8041609bdf:	41 5d                	pop    %r13
  8041609be1:	41 5e                	pop    %r14
  8041609be3:	5d                   	pop    %rbp
  8041609be4:	c3                   	retq   
		panic("page fault in kernel!");
  8041609be5:	48 ba e4 e5 60 41 80 	movabs $0x804160e5e4,%rdx
  8041609bec:	00 00 00 
  8041609bef:	be 44 01 00 00       	mov    $0x144,%esi
  8041609bf4:	48 bf fa e5 60 41 80 	movabs $0x804160e5fa,%rdi
  8041609bfb:	00 00 00 
  8041609bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c03:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609c0a:	00 00 00 
  8041609c0d:	ff d1                	callq  *%rcx
		if (tf->tf_rsp < UXSTACKTOP && tf->tf_rsp >= UXSTACKTOP - PGSIZE) {
  8041609c0f:	48 8b 8f b0 00 00 00 	mov    0xb0(%rdi),%rcx
  8041609c16:	48 ba 00 10 00 00 80 	movabs $0xffffff8000001000,%rdx
  8041609c1d:	ff ff ff 
  8041609c20:	48 01 ca             	add    %rcx,%rdx
		uxrsp = UXSTACKTOP;
  8041609c23:	49 bd 00 00 00 00 80 	movabs $0x8000000000,%r13
  8041609c2a:	00 00 00 
		if (tf->tf_rsp < UXSTACKTOP && tf->tf_rsp >= UXSTACKTOP - PGSIZE) {
  8041609c2d:	48 81 fa ff 0f 00 00 	cmp    $0xfff,%rdx
  8041609c34:	77 04                	ja     8041609c3a <page_fault_handler+0xe5>
			uxrsp = tf->tf_rsp - sizeof(uintptr_t);
  8041609c36:	4c 8d 69 f8          	lea    -0x8(%rcx),%r13
		uxrsp -= sizeof(struct UTrapframe);
  8041609c3a:	4d 8d b5 60 ff ff ff 	lea    -0xa0(%r13),%r14
		user_mem_assert(curenv, utf, sizeof (struct UTrapframe), PTE_W);
  8041609c41:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041609c46:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041609c4b:	4c 89 f6             	mov    %r14,%rsi
  8041609c4e:	48 89 c7             	mov    %rax,%rdi
  8041609c51:	48 b8 99 84 60 41 80 	movabs $0x8041608499,%rax
  8041609c58:	00 00 00 
  8041609c5b:	ff d0                	callq  *%rax
		utf->utf_fault_va = fault_va;
  8041609c5d:	4d 89 a5 60 ff ff ff 	mov    %r12,-0xa0(%r13)
		utf->utf_err = tf->tf_err;
  8041609c64:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
  8041609c6b:	49 89 85 68 ff ff ff 	mov    %rax,-0x98(%r13)
		utf->utf_regs = tf->tf_regs;
  8041609c72:	49 8d 7e 10          	lea    0x10(%r14),%rdi
  8041609c76:	b9 1e 00 00 00       	mov    $0x1e,%ecx
  8041609c7b:	48 89 de             	mov    %rbx,%rsi
  8041609c7e:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
		utf->utf_rip = tf->tf_rip;
  8041609c80:	48 8b 83 98 00 00 00 	mov    0x98(%rbx),%rax
  8041609c87:	49 89 45 e8          	mov    %rax,-0x18(%r13)
		utf->utf_rflags = tf->tf_rflags;
  8041609c8b:	48 8b 83 a8 00 00 00 	mov    0xa8(%rbx),%rax
  8041609c92:	49 89 45 f0          	mov    %rax,-0x10(%r13)
		utf->utf_rsp = tf->tf_rsp;
  8041609c96:	48 8b 83 b0 00 00 00 	mov    0xb0(%rbx),%rax
  8041609c9d:	49 89 45 f8          	mov    %rax,-0x8(%r13)
		tf->tf_rsp = uxrsp;
  8041609ca1:	4c 89 b3 b0 00 00 00 	mov    %r14,0xb0(%rbx)
		tf->tf_rip = (uintptr_t)curenv->env_pgfault_upcall;
  8041609ca8:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609caf:	00 00 00 
  8041609cb2:	48 8b 38             	mov    (%rax),%rdi
  8041609cb5:	48 8b 87 f8 00 00 00 	mov    0xf8(%rdi),%rax
  8041609cbc:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
		env_run(curenv);
  8041609cc3:	48 b8 a6 8e 60 41 80 	movabs $0x8041608ea6,%rax
  8041609cca:	00 00 00 
  8041609ccd:	ff d0                	callq  *%rax

0000008041609ccf <trap>:
trap(struct Trapframe *tf) {
  8041609ccf:	55                   	push   %rbp
  8041609cd0:	48 89 e5             	mov    %rsp,%rbp
  8041609cd3:	53                   	push   %rbx
  8041609cd4:	48 83 ec 08          	sub    $0x8,%rsp
  8041609cd8:	48 89 fe             	mov    %rdi,%rsi
  asm volatile("cld" ::
  8041609cdb:	fc                   	cld    
  if (panicstr)
  8041609cdc:	48 b8 80 42 88 41 80 	movabs $0x8041884280,%rax
  8041609ce3:	00 00 00 
  8041609ce6:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609cea:	74 01                	je     8041609ced <trap+0x1e>
    asm volatile("hlt");
  8041609cec:	f4                   	hlt    
  __asm __volatile("pushfq; popq %0"
  8041609ced:	9c                   	pushfq 
  8041609cee:	58                   	pop    %rax
  assert(!(read_rflags() & FL_IF));
  8041609cef:	f6 c4 02             	test   $0x2,%ah
  8041609cf2:	0f 85 da 00 00 00    	jne    8041609dd2 <trap+0x103>
  assert(curenv);
  8041609cf8:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041609cff:	00 00 00 
  8041609d02:	48 85 c0             	test   %rax,%rax
  8041609d05:	0f 84 fc 00 00 00    	je     8041609e07 <trap+0x138>
  if (curenv->env_status == ENV_DYING) {
  8041609d0b:	83 b8 d4 00 00 00 01 	cmpl   $0x1,0xd4(%rax)
  8041609d12:	0f 84 1f 01 00 00    	je     8041609e37 <trap+0x168>
  curenv->env_tf = *tf;
  8041609d18:	b9 30 00 00 00       	mov    $0x30,%ecx
  8041609d1d:	48 89 c7             	mov    %rax,%rdi
  8041609d20:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  tf = &curenv->env_tf;
  8041609d22:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609d29:	00 00 00 
  8041609d2c:	48 8b 18             	mov    (%rax),%rbx
  last_tf = tf;
  8041609d2f:	48 89 d8             	mov    %rbx,%rax
  8041609d32:	48 a3 40 55 88 41 80 	movabs %rax,0x8041885540
  8041609d39:	00 00 00 
  if (tf->tf_trapno == T_SYSCALL) {
  8041609d3c:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  8041609d43:	48 83 f8 30          	cmp    $0x30,%rax
  8041609d47:	0f 84 16 01 00 00    	je     8041609e63 <trap+0x194>
  if (tf->tf_trapno == T_PGFLT) {
  8041609d4d:	48 83 f8 0e          	cmp    $0xe,%rax
  8041609d51:	0f 84 39 01 00 00    	je     8041609e90 <trap+0x1c1>
  if (tf->tf_trapno == T_BRKPT) {
  8041609d57:	48 83 f8 03          	cmp    $0x3,%rax
  8041609d5b:	0f 84 43 01 00 00    	je     8041609ea4 <trap+0x1d5>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
  8041609d61:	48 83 f8 27          	cmp    $0x27,%rax
  8041609d65:	0f 84 4d 01 00 00    	je     8041609eb8 <trap+0x1e9>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {
  8041609d6b:	48 83 f8 28          	cmp    $0x28,%rax
  8041609d6f:	0f 84 63 01 00 00    	je     8041609ed8 <trap+0x209>
  print_trapframe(tf);
  8041609d75:	48 89 df             	mov    %rbx,%rdi
  8041609d78:	48 b8 d8 98 60 41 80 	movabs $0x80416098d8,%rax
  8041609d7f:	00 00 00 
  8041609d82:	ff d0                	callq  *%rax
  if (!(tf->tf_cs & 0x3)) {
  8041609d84:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041609d8b:	0f 84 60 01 00 00    	je     8041609ef1 <trap+0x222>
    env_destroy(curenv);
  8041609d91:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609d98:	00 00 00 
  8041609d9b:	48 8b 38             	mov    (%rax),%rdi
  8041609d9e:	48 b8 d2 8d 60 41 80 	movabs $0x8041608dd2,%rax
  8041609da5:	00 00 00 
  8041609da8:	ff d0                	callq  *%rax
  if (curenv && curenv->env_status == ENV_RUNNING)
  8041609daa:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  8041609db1:	00 00 00 
  8041609db4:	48 85 c0             	test   %rax,%rax
  8041609db7:	74 0d                	je     8041609dc6 <trap+0xf7>
  8041609db9:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  8041609dc0:	0f 84 55 01 00 00    	je     8041609f1b <trap+0x24c>
    sched_yield();
  8041609dc6:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  8041609dcd:	00 00 00 
  8041609dd0:	ff d0                	callq  *%rax
  assert(!(read_rflags() & FL_IF));
  8041609dd2:	48 b9 06 e6 60 41 80 	movabs $0x804160e606,%rcx
  8041609dd9:	00 00 00 
  8041609ddc:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041609de3:	00 00 00 
  8041609de6:	be 11 01 00 00       	mov    $0x111,%esi
  8041609deb:	48 bf fa e5 60 41 80 	movabs $0x804160e5fa,%rdi
  8041609df2:	00 00 00 
  8041609df5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609dfa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609e01:	00 00 00 
  8041609e04:	41 ff d0             	callq  *%r8
  assert(curenv);
  8041609e07:	48 b9 1f e6 60 41 80 	movabs $0x804160e61f,%rcx
  8041609e0e:	00 00 00 
  8041609e11:	48 ba d9 cf 60 41 80 	movabs $0x804160cfd9,%rdx
  8041609e18:	00 00 00 
  8041609e1b:	be 19 01 00 00       	mov    $0x119,%esi
  8041609e20:	48 bf fa e5 60 41 80 	movabs $0x804160e5fa,%rdi
  8041609e27:	00 00 00 
  8041609e2a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609e31:	00 00 00 
  8041609e34:	41 ff d0             	callq  *%r8
    env_free(curenv);
  8041609e37:	48 89 c7             	mov    %rax,%rdi
  8041609e3a:	48 b8 c7 8a 60 41 80 	movabs $0x8041608ac7,%rax
  8041609e41:	00 00 00 
  8041609e44:	ff d0                	callq  *%rax
    curenv = NULL;
  8041609e46:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  8041609e4d:	00 00 00 
  8041609e50:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    sched_yield();
  8041609e57:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  8041609e5e:	00 00 00 
  8041609e61:	ff d0                	callq  *%rax
    ret                 = syscall(syscallno, a1, a2, a3, a4, a5);
  8041609e63:	48 8b 4b 68          	mov    0x68(%rbx),%rcx
  8041609e67:	48 8b 53 60          	mov    0x60(%rbx),%rdx
  8041609e6b:	48 8b 73 58          	mov    0x58(%rbx),%rsi
  8041609e6f:	48 8b 7b 70          	mov    0x70(%rbx),%rdi
  8041609e73:	4c 8b 4b 40          	mov    0x40(%rbx),%r9
  8041609e77:	4c 8b 43 48          	mov    0x48(%rbx),%r8
  8041609e7b:	48 b8 d3 ad 60 41 80 	movabs $0x804160add3,%rax
  8041609e82:	00 00 00 
  8041609e85:	ff d0                	callq  *%rax
    tf->tf_regs.reg_rax = ret;
  8041609e87:	48 89 43 70          	mov    %rax,0x70(%rbx)
    return;
  8041609e8b:	e9 1a ff ff ff       	jmpq   8041609daa <trap+0xdb>
    page_fault_handler(tf);
  8041609e90:	48 89 df             	mov    %rbx,%rdi
  8041609e93:	48 b8 55 9b 60 41 80 	movabs $0x8041609b55,%rax
  8041609e9a:	00 00 00 
  8041609e9d:	ff d0                	callq  *%rax
    return;
  8041609e9f:	e9 06 ff ff ff       	jmpq   8041609daa <trap+0xdb>
    monitor(tf);
  8041609ea4:	48 89 df             	mov    %rbx,%rdi
  8041609ea7:	48 b8 09 3f 60 41 80 	movabs $0x8041603f09,%rax
  8041609eae:	00 00 00 
  8041609eb1:	ff d0                	callq  *%rax
    return;
  8041609eb3:	e9 f2 fe ff ff       	jmpq   8041609daa <trap+0xdb>
    cprintf("Spurious interrupt on irq 7\n");
  8041609eb8:	48 bf 26 e6 60 41 80 	movabs $0x804160e626,%rdi
  8041609ebf:	00 00 00 
  8041609ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ec7:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  8041609ece:	00 00 00 
  8041609ed1:	ff d2                	callq  *%rdx
    return;
  8041609ed3:	e9 d2 fe ff ff       	jmpq   8041609daa <trap+0xdb>
    timer_for_schedule->handle_interrupts();
  8041609ed8:	48 a1 60 5a 88 41 80 	movabs 0x8041885a60,%rax
  8041609edf:	00 00 00 
  8041609ee2:	ff 50 20             	callq  *0x20(%rax)
    sched_yield();
  8041609ee5:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  8041609eec:	00 00 00 
  8041609eef:	ff d0                	callq  *%rax
    panic("unhandled trap in kernel");
  8041609ef1:	48 ba 43 e6 60 41 80 	movabs $0x804160e643,%rdx
  8041609ef8:	00 00 00 
  8041609efb:	be fc 00 00 00       	mov    $0xfc,%esi
  8041609f00:	48 bf fa e5 60 41 80 	movabs $0x804160e5fa,%rdi
  8041609f07:	00 00 00 
  8041609f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609f0f:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609f16:	00 00 00 
  8041609f19:	ff d1                	callq  *%rcx
    env_run(curenv);
  8041609f1b:	48 89 c7             	mov    %rax,%rdi
  8041609f1e:	48 b8 a6 8e 60 41 80 	movabs $0x8041608ea6,%rax
  8041609f25:	00 00 00 
  8041609f28:	ff d0                	callq  *%rax

0000008041609f2a <_alltraps>:

.globl _alltraps
.type _alltraps, @function;
.align 2
_alltraps:
  subq $8,%rsp
  8041609f2a:	48 83 ec 08          	sub    $0x8,%rsp
  movw %ds,(%rsp)
  8041609f2e:	8c 1c 24             	mov    %ds,(%rsp)
  subq $8,%rsp
  8041609f31:	48 83 ec 08          	sub    $0x8,%rsp
  movw %es,(%rsp)
  8041609f35:	8c 04 24             	mov    %es,(%rsp)
  PUSHA
  8041609f38:	48 83 ec 78          	sub    $0x78,%rsp
  8041609f3c:	48 89 44 24 70       	mov    %rax,0x70(%rsp)
  8041609f41:	48 89 5c 24 68       	mov    %rbx,0x68(%rsp)
  8041609f46:	48 89 4c 24 60       	mov    %rcx,0x60(%rsp)
  8041609f4b:	48 89 54 24 58       	mov    %rdx,0x58(%rsp)
  8041609f50:	48 89 6c 24 50       	mov    %rbp,0x50(%rsp)
  8041609f55:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
  8041609f5a:	48 89 74 24 40       	mov    %rsi,0x40(%rsp)
  8041609f5f:	4c 89 44 24 38       	mov    %r8,0x38(%rsp)
  8041609f64:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
  8041609f69:	4c 89 54 24 28       	mov    %r10,0x28(%rsp)
  8041609f6e:	4c 89 5c 24 20       	mov    %r11,0x20(%rsp)
  8041609f73:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
  8041609f78:	4c 89 6c 24 10       	mov    %r13,0x10(%rsp)
  8041609f7d:	4c 89 74 24 08       	mov    %r14,0x8(%rsp)
  8041609f82:	4c 89 3c 24          	mov    %r15,(%rsp)
  movq $GD_KD,%rax
  8041609f86:	48 c7 c0 10 00 00 00 	mov    $0x10,%rax
  movq %rax,%ds
  8041609f8d:	48 8e d8             	mov    %rax,%ds
  movq %rax,%es
  8041609f90:	48 8e c0             	mov    %rax,%es
  movq %rsp,%rdi
  8041609f93:	48 89 e7             	mov    %rsp,%rdi
  call trap
  8041609f96:	e8 34 fd ff ff       	callq  8041609ccf <trap>
  jmp .
  8041609f9b:	eb fe                	jmp    8041609f9b <_alltraps+0x71>
  8041609f9d:	90                   	nop

0000008041609f9e <clock_thdlr>:
  xorl %ebp, %ebp
  movq %rsp,%rdi
  call trap
  jmp .
#else
TRAPHANDLER_NOEC(clock_thdlr, IRQ_OFFSET + IRQ_CLOCK)
  8041609f9e:	6a 00                	pushq  $0x0
  8041609fa0:	6a 28                	pushq  $0x28
  8041609fa2:	eb 86                	jmp    8041609f2a <_alltraps>

0000008041609fa4 <divide_thdlr>:
// LAB 8 code
TRAPHANDLER_NOEC(divide_thdlr, T_DIVIDE)
  8041609fa4:	6a 00                	pushq  $0x0
  8041609fa6:	6a 00                	pushq  $0x0
  8041609fa8:	eb 80                	jmp    8041609f2a <_alltraps>

0000008041609faa <debug_thdlr>:
TRAPHANDLER_NOEC(debug_thdlr, T_DEBUG)
  8041609faa:	6a 00                	pushq  $0x0
  8041609fac:	6a 01                	pushq  $0x1
  8041609fae:	e9 77 ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fb3:	90                   	nop

0000008041609fb4 <nmi_thdlr>:
TRAPHANDLER_NOEC(nmi_thdlr, T_NMI)
  8041609fb4:	6a 00                	pushq  $0x0
  8041609fb6:	6a 02                	pushq  $0x2
  8041609fb8:	e9 6d ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fbd:	90                   	nop

0000008041609fbe <brkpt_thdlr>:
TRAPHANDLER_NOEC(brkpt_thdlr, T_BRKPT)
  8041609fbe:	6a 00                	pushq  $0x0
  8041609fc0:	6a 03                	pushq  $0x3
  8041609fc2:	e9 63 ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fc7:	90                   	nop

0000008041609fc8 <oflow_thdlr>:
TRAPHANDLER_NOEC(oflow_thdlr, T_OFLOW)
  8041609fc8:	6a 00                	pushq  $0x0
  8041609fca:	6a 04                	pushq  $0x4
  8041609fcc:	e9 59 ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fd1:	90                   	nop

0000008041609fd2 <bound_thdlr>:
TRAPHANDLER_NOEC(bound_thdlr, T_BOUND)
  8041609fd2:	6a 00                	pushq  $0x0
  8041609fd4:	6a 05                	pushq  $0x5
  8041609fd6:	e9 4f ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fdb:	90                   	nop

0000008041609fdc <illop_thdlr>:
TRAPHANDLER_NOEC(illop_thdlr, T_ILLOP)
  8041609fdc:	6a 00                	pushq  $0x0
  8041609fde:	6a 06                	pushq  $0x6
  8041609fe0:	e9 45 ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fe5:	90                   	nop

0000008041609fe6 <device_thdlr>:
TRAPHANDLER_NOEC(device_thdlr, T_DEVICE)
  8041609fe6:	6a 00                	pushq  $0x0
  8041609fe8:	6a 07                	pushq  $0x7
  8041609fea:	e9 3b ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fef:	90                   	nop

0000008041609ff0 <dblflt_thdlr>:
TRAPHANDLER(dblflt_thdlr, T_DBLFLT)
  8041609ff0:	6a 08                	pushq  $0x8
  8041609ff2:	e9 33 ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609ff7:	90                   	nop

0000008041609ff8 <tss_thdlr>:
TRAPHANDLER(tss_thdlr, T_TSS)
  8041609ff8:	6a 0a                	pushq  $0xa
  8041609ffa:	e9 2b ff ff ff       	jmpq   8041609f2a <_alltraps>
  8041609fff:	90                   	nop

000000804160a000 <segnp_thdlr>:
TRAPHANDLER(segnp_thdlr, T_SEGNP)
  804160a000:	6a 0b                	pushq  $0xb
  804160a002:	e9 23 ff ff ff       	jmpq   8041609f2a <_alltraps>
  804160a007:	90                   	nop

000000804160a008 <stack_thdlr>:
TRAPHANDLER(stack_thdlr, T_STACK)
  804160a008:	6a 0c                	pushq  $0xc
  804160a00a:	e9 1b ff ff ff       	jmpq   8041609f2a <_alltraps>
  804160a00f:	90                   	nop

000000804160a010 <gpflt_thdlr>:
TRAPHANDLER(gpflt_thdlr, T_GPFLT)
  804160a010:	6a 0d                	pushq  $0xd
  804160a012:	e9 13 ff ff ff       	jmpq   8041609f2a <_alltraps>
  804160a017:	90                   	nop

000000804160a018 <pgflt_thdlr>:
TRAPHANDLER(pgflt_thdlr, T_PGFLT)
  804160a018:	6a 0e                	pushq  $0xe
  804160a01a:	e9 0b ff ff ff       	jmpq   8041609f2a <_alltraps>
  804160a01f:	90                   	nop

000000804160a020 <fperr_thdlr>:
TRAPHANDLER_NOEC(fperr_thdlr, T_FPERR)
  804160a020:	6a 00                	pushq  $0x0
  804160a022:	6a 10                	pushq  $0x10
  804160a024:	e9 01 ff ff ff       	jmpq   8041609f2a <_alltraps>
  804160a029:	90                   	nop

000000804160a02a <align_thdlr>:
TRAPHANDLER(align_thdlr, T_ALIGN)
  804160a02a:	6a 11                	pushq  $0x11
  804160a02c:	e9 f9 fe ff ff       	jmpq   8041609f2a <_alltraps>
  804160a031:	90                   	nop

000000804160a032 <mchk_thdlr>:
TRAPHANDLER_NOEC(mchk_thdlr, T_MCHK)
  804160a032:	6a 00                	pushq  $0x0
  804160a034:	6a 12                	pushq  $0x12
  804160a036:	e9 ef fe ff ff       	jmpq   8041609f2a <_alltraps>
  804160a03b:	90                   	nop

000000804160a03c <simderr_thdlr>:
TRAPHANDLER_NOEC(simderr_thdlr, T_SIMDERR)
  804160a03c:	6a 00                	pushq  $0x0
  804160a03e:	6a 13                	pushq  $0x13
  804160a040:	e9 e5 fe ff ff       	jmpq   8041609f2a <_alltraps>
  804160a045:	90                   	nop

000000804160a046 <syscall_thdlr>:
TRAPHANDLER_NOEC(syscall_thdlr, T_SYSCALL)
  804160a046:	6a 00                	pushq  $0x0
  804160a048:	6a 30                	pushq  $0x30
  804160a04a:	e9 db fe ff ff       	jmpq   8041609f2a <_alltraps>

000000804160a04f <acpi_find_table>:
  return krsdp;
}

// LAB 5 code
static void *
acpi_find_table(const char *sign) {
  804160a04f:	55                   	push   %rbp
  804160a050:	48 89 e5             	mov    %rsp,%rbp
  804160a053:	41 57                	push   %r15
  804160a055:	41 56                	push   %r14
  804160a057:	41 55                	push   %r13
  804160a059:	41 54                	push   %r12
  804160a05b:	53                   	push   %rbx
  804160a05c:	48 83 ec 28          	sub    $0x28,%rsp
  804160a060:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  static size_t krsdt_len;
  static size_t krsdt_entsz;

  uint8_t cksm = 0;

  if (!krsdt) {
  804160a064:	48 b8 e0 55 88 41 80 	movabs $0x80418855e0,%rax
  804160a06b:	00 00 00 
  804160a06e:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a072:	74 3d                	je     804160a0b1 <acpi_find_table+0x62>
    }
  }

  ACPISDTHeader *hd = NULL;

  for (size_t i = 0; i < krsdt_len; i++) {
  804160a074:	48 b8 d0 55 88 41 80 	movabs $0x80418855d0,%rax
  804160a07b:	00 00 00 
  804160a07e:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a082:	0f 84 f2 03 00 00    	je     804160a47a <acpi_find_table+0x42b>
  804160a088:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    /* Assume little endian */
    uint64_t fadt_pa = 0;
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  804160a08e:	49 bf d8 55 88 41 80 	movabs $0x80418855d8,%r15
  804160a095:	00 00 00 
  804160a098:	49 bd e0 55 88 41 80 	movabs $0x80418855e0,%r13
  804160a09f:	00 00 00 
  804160a0a2:	49 be 64 c5 60 41 80 	movabs $0x804160c564,%r14
  804160a0a9:	00 00 00 
  804160a0ac:	e9 04 03 00 00       	jmpq   804160a3b5 <acpi_find_table+0x366>
    if (!uefi_lp->ACPIRoot) {
  804160a0b1:	48 a1 00 00 62 41 80 	movabs 0x8041620000,%rax
  804160a0b8:	00 00 00 
  804160a0bb:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160a0bf:	48 85 ff             	test   %rdi,%rdi
  804160a0c2:	74 7c                	je     804160a140 <acpi_find_table+0xf1>
    RSDP *krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  804160a0c4:	be 24 00 00 00       	mov    $0x24,%esi
  804160a0c9:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  804160a0d0:	00 00 00 
  804160a0d3:	ff d0                	callq  *%rax
  804160a0d5:	49 89 c4             	mov    %rax,%r12
    if (strncmp(krsdp->Signature, "RSD PTR", 8))
  804160a0d8:	ba 08 00 00 00       	mov    $0x8,%edx
  804160a0dd:	48 be 9b e8 60 41 80 	movabs $0x804160e89b,%rsi
  804160a0e4:	00 00 00 
  804160a0e7:	48 89 c7             	mov    %rax,%rdi
  804160a0ea:	48 b8 21 c4 60 41 80 	movabs $0x804160c421,%rax
  804160a0f1:	00 00 00 
  804160a0f4:	ff d0                	callq  *%rax
  804160a0f6:	85 c0                	test   %eax,%eax
  804160a0f8:	74 70                	je     804160a16a <acpi_find_table+0x11b>
  804160a0fa:	4c 89 e0             	mov    %r12,%rax
  804160a0fd:	49 8d 54 24 14       	lea    0x14(%r12),%rdx
  uint8_t cksm = 0;
  804160a102:	bb 00 00 00 00       	mov    $0x0,%ebx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160a107:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < offsetof(RSDP, Length); i++)
  804160a109:	48 83 c0 01          	add    $0x1,%rax
  804160a10d:	48 39 d0             	cmp    %rdx,%rax
  804160a110:	75 f5                	jne    804160a107 <acpi_find_table+0xb8>
    if (cksm)
  804160a112:	84 db                	test   %bl,%bl
  804160a114:	74 59                	je     804160a16f <acpi_find_table+0x120>
      panic("Invalid RSDP");
  804160a116:	48 ba a3 e8 60 41 80 	movabs $0x804160e8a3,%rdx
  804160a11d:	00 00 00 
  804160a120:	be 7f 00 00 00       	mov    $0x7f,%esi
  804160a125:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a12c:	00 00 00 
  804160a12f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a134:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a13b:	00 00 00 
  804160a13e:	ff d1                	callq  *%rcx
      panic("No rsdp\n");
  804160a140:	48 ba 85 e8 60 41 80 	movabs $0x804160e885,%rdx
  804160a147:	00 00 00 
  804160a14a:	be 75 00 00 00       	mov    $0x75,%esi
  804160a14f:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a156:	00 00 00 
  804160a159:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a15e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a165:	00 00 00 
  804160a168:	ff d1                	callq  *%rcx
  uint8_t cksm = 0;
  804160a16a:	bb 00 00 00 00       	mov    $0x0,%ebx
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  804160a16f:	45 8b 74 24 10       	mov    0x10(%r12),%r14d
    krsdt_entsz      = 4;
  804160a174:	48 b8 d8 55 88 41 80 	movabs $0x80418855d8,%rax
  804160a17b:	00 00 00 
  804160a17e:	48 c7 00 04 00 00 00 	movq   $0x4,(%rax)
    if (krsdp->Revision) {
  804160a185:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a18b:	0f 84 1b 01 00 00    	je     804160a2ac <acpi_find_table+0x25d>
      for (size_t i = 0; i < krsdp->Length; i++)
  804160a191:	41 8b 54 24 14       	mov    0x14(%r12),%edx
  804160a196:	48 85 d2             	test   %rdx,%rdx
  804160a199:	74 11                	je     804160a1ac <acpi_find_table+0x15d>
  804160a19b:	4c 89 e0             	mov    %r12,%rax
  804160a19e:	4c 01 e2             	add    %r12,%rdx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160a1a1:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < krsdp->Length; i++)
  804160a1a3:	48 83 c0 01          	add    $0x1,%rax
  804160a1a7:	48 39 c2             	cmp    %rax,%rdx
  804160a1aa:	75 f5                	jne    804160a1a1 <acpi_find_table+0x152>
      if (cksm)
  804160a1ac:	84 db                	test   %bl,%bl
  804160a1ae:	0f 85 4c 01 00 00    	jne    804160a300 <acpi_find_table+0x2b1>
      rsdt_pa     = krsdp->XsdtAddress;
  804160a1b4:	4d 8b 74 24 18       	mov    0x18(%r12),%r14
      krsdt_entsz = 8;
  804160a1b9:	48 b8 d8 55 88 41 80 	movabs $0x80418855d8,%rax
  804160a1c0:	00 00 00 
  804160a1c3:	48 c7 00 08 00 00 00 	movq   $0x8,(%rax)
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  804160a1ca:	be 24 00 00 00       	mov    $0x24,%esi
  804160a1cf:	4c 89 f7             	mov    %r14,%rdi
  804160a1d2:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  804160a1d9:	00 00 00 
  804160a1dc:	ff d0                	callq  *%rax
  804160a1de:	49 bd e0 55 88 41 80 	movabs $0x80418855e0,%r13
  804160a1e5:	00 00 00 
  804160a1e8:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  804160a1ec:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a1ef:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a1f4:	48 89 c6             	mov    %rax,%rsi
  804160a1f7:	4c 89 f7             	mov    %r14,%rdi
  804160a1fa:	48 b8 62 83 60 41 80 	movabs $0x8041608362,%rax
  804160a201:	00 00 00 
  804160a204:	ff d0                	callq  *%rax
  804160a206:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a20a:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a20d:	48 85 c9             	test   %rcx,%rcx
  804160a210:	74 19                	je     804160a22b <acpi_find_table+0x1dc>
  804160a212:	48 89 c2             	mov    %rax,%rdx
  804160a215:	48 01 c1             	add    %rax,%rcx
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdt)[i]);
  804160a218:	02 1a                	add    (%rdx),%bl
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a21a:	48 83 c2 01          	add    $0x1,%rdx
  804160a21e:	48 39 d1             	cmp    %rdx,%rcx
  804160a221:	75 f5                	jne    804160a218 <acpi_find_table+0x1c9>
    if (cksm)
  804160a223:	84 db                	test   %bl,%bl
  804160a225:	0f 85 ff 00 00 00    	jne    804160a32a <acpi_find_table+0x2db>
    if (strncmp(krsdt->h.Signature, krsdp->Revision ? "XSDT" : "RSDT", 4))
  804160a22b:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a231:	48 be 80 e8 60 41 80 	movabs $0x804160e880,%rsi
  804160a238:	00 00 00 
  804160a23b:	48 ba b8 e8 60 41 80 	movabs $0x804160e8b8,%rdx
  804160a242:	00 00 00 
  804160a245:	48 0f 44 f2          	cmove  %rdx,%rsi
  804160a249:	ba 04 00 00 00       	mov    $0x4,%edx
  804160a24e:	48 89 c7             	mov    %rax,%rdi
  804160a251:	48 b8 21 c4 60 41 80 	movabs $0x804160c421,%rax
  804160a258:	00 00 00 
  804160a25b:	ff d0                	callq  *%rax
  804160a25d:	85 c0                	test   %eax,%eax
  804160a25f:	0f 85 ef 00 00 00    	jne    804160a354 <acpi_find_table+0x305>
    krsdt_len = (krsdt->h.Length - sizeof(RSDT)) / 4;
  804160a265:	48 a1 e0 55 88 41 80 	movabs 0x80418855e0,%rax
  804160a26c:	00 00 00 
  804160a26f:	8b 40 04             	mov    0x4(%rax),%eax
  804160a272:	48 8d 58 dc          	lea    -0x24(%rax),%rbx
  804160a276:	48 89 da             	mov    %rbx,%rdx
  804160a279:	48 c1 ea 02          	shr    $0x2,%rdx
  804160a27d:	48 89 d0             	mov    %rdx,%rax
  804160a280:	48 a3 d0 55 88 41 80 	movabs %rax,0x80418855d0
  804160a287:	00 00 00 
    if (krsdp->Revision) {
  804160a28a:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a290:	0f 84 de fd ff ff    	je     804160a074 <acpi_find_table+0x25>
      krsdt_len = krsdt_len / 2;
  804160a296:	48 89 d8             	mov    %rbx,%rax
  804160a299:	48 c1 e8 03          	shr    $0x3,%rax
  804160a29d:	48 a3 d0 55 88 41 80 	movabs %rax,0x80418855d0
  804160a2a4:	00 00 00 
  804160a2a7:	e9 c8 fd ff ff       	jmpq   804160a074 <acpi_find_table+0x25>
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  804160a2ac:	45 89 f6             	mov    %r14d,%r14d
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  804160a2af:	be 24 00 00 00       	mov    $0x24,%esi
  804160a2b4:	4c 89 f7             	mov    %r14,%rdi
  804160a2b7:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  804160a2be:	00 00 00 
  804160a2c1:	ff d0                	callq  *%rax
  804160a2c3:	49 bd e0 55 88 41 80 	movabs $0x80418855e0,%r13
  804160a2ca:	00 00 00 
  804160a2cd:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  804160a2d1:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a2d4:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a2d9:	48 89 c6             	mov    %rax,%rsi
  804160a2dc:	4c 89 f7             	mov    %r14,%rdi
  804160a2df:	48 b8 62 83 60 41 80 	movabs $0x8041608362,%rax
  804160a2e6:	00 00 00 
  804160a2e9:	ff d0                	callq  *%rax
  804160a2eb:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a2ef:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a2f2:	48 85 c9             	test   %rcx,%rcx
  804160a2f5:	0f 85 17 ff ff ff    	jne    804160a212 <acpi_find_table+0x1c3>
  804160a2fb:	e9 23 ff ff ff       	jmpq   804160a223 <acpi_find_table+0x1d4>
        panic("Invalid RSDP");
  804160a300:	48 ba a3 e8 60 41 80 	movabs $0x804160e8a3,%rdx
  804160a307:	00 00 00 
  804160a30a:	be 89 00 00 00       	mov    $0x89,%esi
  804160a30f:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a316:	00 00 00 
  804160a319:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a31e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a325:	00 00 00 
  804160a328:	ff d1                	callq  *%rcx
      panic("Invalid RSDP");
  804160a32a:	48 ba a3 e8 60 41 80 	movabs $0x804160e8a3,%rdx
  804160a331:	00 00 00 
  804160a334:	be 97 00 00 00       	mov    $0x97,%esi
  804160a339:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a340:	00 00 00 
  804160a343:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a348:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a34f:	00 00 00 
  804160a352:	ff d1                	callq  *%rcx
      panic("Invalid RSDT");
  804160a354:	48 ba b0 e8 60 41 80 	movabs $0x804160e8b0,%rdx
  804160a35b:	00 00 00 
  804160a35e:	be 9a 00 00 00       	mov    $0x9a,%esi
  804160a363:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a36a:	00 00 00 
  804160a36d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a372:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a379:	00 00 00 
  804160a37c:	ff d1                	callq  *%rcx

    for (size_t i = 0; i < hd->Length; i++)
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
    if (cksm)
      panic("ACPI table '%.4s' invalid", hd->Signature);
    if (!strncmp(hd->Signature, sign, 4))
  804160a37e:	ba 04 00 00 00       	mov    $0x4,%edx
  804160a383:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160a387:	48 89 df             	mov    %rbx,%rdi
  804160a38a:	48 b8 21 c4 60 41 80 	movabs $0x804160c421,%rax
  804160a391:	00 00 00 
  804160a394:	ff d0                	callq  *%rax
  804160a396:	85 c0                	test   %eax,%eax
  804160a398:	0f 84 ca 00 00 00    	je     804160a468 <acpi_find_table+0x419>
  for (size_t i = 0; i < krsdt_len; i++) {
  804160a39e:	49 83 c4 01          	add    $0x1,%r12
  804160a3a2:	48 b8 d0 55 88 41 80 	movabs $0x80418855d0,%rax
  804160a3a9:	00 00 00 
  804160a3ac:	4c 39 20             	cmp    %r12,(%rax)
  804160a3af:	0f 86 ae 00 00 00    	jbe    804160a463 <acpi_find_table+0x414>
    uint64_t fadt_pa = 0;
  804160a3b5:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160a3bc:	00 
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  804160a3bd:	49 8b 17             	mov    (%r15),%rdx
  804160a3c0:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  804160a3c4:	48 89 d0             	mov    %rdx,%rax
  804160a3c7:	49 0f af c4          	imul   %r12,%rax
  804160a3cb:	48 8d 74 01 24       	lea    0x24(%rcx,%rax,1),%rsi
  804160a3d0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160a3d4:	41 ff d6             	callq  *%r14
    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
  804160a3d7:	be 24 00 00 00       	mov    $0x24,%esi
  804160a3dc:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160a3e0:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  804160a3e7:	00 00 00 
  804160a3ea:	ff d0                	callq  *%rax
    hd = mmio_remap_last_region(fadt_pa, hd, sizeof(ACPISDTHeader), krsdt->h.Length);
  804160a3ec:	49 8b 55 00          	mov    0x0(%r13),%rdx
  804160a3f0:	8b 4a 04             	mov    0x4(%rdx),%ecx
  804160a3f3:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a3f8:	48 89 c6             	mov    %rax,%rsi
  804160a3fb:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160a3ff:	48 b8 62 83 60 41 80 	movabs $0x8041608362,%rax
  804160a406:	00 00 00 
  804160a409:	ff d0                	callq  *%rax
  804160a40b:	48 89 c3             	mov    %rax,%rbx
    for (size_t i = 0; i < hd->Length; i++)
  804160a40e:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a411:	48 85 c9             	test   %rcx,%rcx
  804160a414:	0f 84 64 ff ff ff    	je     804160a37e <acpi_find_table+0x32f>
  804160a41a:	48 01 c1             	add    %rax,%rcx
  804160a41d:	ba 00 00 00 00       	mov    $0x0,%edx
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
  804160a422:	02 10                	add    (%rax),%dl
    for (size_t i = 0; i < hd->Length; i++)
  804160a424:	48 83 c0 01          	add    $0x1,%rax
  804160a428:	48 39 c1             	cmp    %rax,%rcx
  804160a42b:	75 f5                	jne    804160a422 <acpi_find_table+0x3d3>
    if (cksm)
  804160a42d:	84 d2                	test   %dl,%dl
  804160a42f:	0f 84 49 ff ff ff    	je     804160a37e <acpi_find_table+0x32f>
      panic("ACPI table '%.4s' invalid", hd->Signature);
  804160a435:	48 89 d9             	mov    %rbx,%rcx
  804160a438:	48 ba bd e8 60 41 80 	movabs $0x804160e8bd,%rdx
  804160a43f:	00 00 00 
  804160a442:	be b0 00 00 00       	mov    $0xb0,%esi
  804160a447:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a44e:	00 00 00 
  804160a451:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a456:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160a45d:	00 00 00 
  804160a460:	41 ff d0             	callq  *%r8
      return hd;
  }

  return NULL;
  804160a463:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  804160a468:	48 89 d8             	mov    %rbx,%rax
  804160a46b:	48 83 c4 28          	add    $0x28,%rsp
  804160a46f:	5b                   	pop    %rbx
  804160a470:	41 5c                	pop    %r12
  804160a472:	41 5d                	pop    %r13
  804160a474:	41 5e                	pop    %r14
  804160a476:	41 5f                	pop    %r15
  804160a478:	5d                   	pop    %rbp
  804160a479:	c3                   	retq   
  return NULL;
  804160a47a:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160a47f:	eb e7                	jmp    804160a468 <acpi_find_table+0x419>

000000804160a481 <hpet_handle_interrupts_tim0>:
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  // LAB 5 code end
}

void
hpet_handle_interrupts_tim0(void) {
  804160a481:	55                   	push   %rbp
  804160a482:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_TIMER);
  804160a485:	bf 00 00 00 00       	mov    $0x0,%edi
  804160a48a:	48 b8 9a 91 60 41 80 	movabs $0x804160919a,%rax
  804160a491:	00 00 00 
  804160a494:	ff d0                	callq  *%rax
}
  804160a496:	5d                   	pop    %rbp
  804160a497:	c3                   	retq   

000000804160a498 <hpet_handle_interrupts_tim1>:

void
hpet_handle_interrupts_tim1(void) {
  804160a498:	55                   	push   %rbp
  804160a499:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_CLOCK);
  804160a49c:	bf 08 00 00 00       	mov    $0x8,%edi
  804160a4a1:	48 b8 9a 91 60 41 80 	movabs $0x804160919a,%rax
  804160a4a8:	00 00 00 
  804160a4ab:	ff d0                	callq  *%rax
}
  804160a4ad:	5d                   	pop    %rbp
  804160a4ae:	c3                   	retq   

000000804160a4af <hpet_cpu_frequency>:
// about pause instruction.
uint64_t
hpet_cpu_frequency(void) {
  // LAB 5 code
  uint64_t time_res = 100;
  uint64_t delta = 0, target = hpetFreq / time_res;
  804160a4af:	48 a1 f8 55 88 41 80 	movabs 0x80418855f8,%rax
  804160a4b6:	00 00 00 
  804160a4b9:	48 c1 e8 02          	shr    $0x2,%rax
  804160a4bd:	48 ba c3 f5 28 5c 8f 	movabs $0x28f5c28f5c28f5c3,%rdx
  804160a4c4:	c2 f5 28 
  804160a4c7:	48 f7 e2             	mul    %rdx
  804160a4ca:	48 89 d1             	mov    %rdx,%rcx
  804160a4cd:	48 c1 e9 02          	shr    $0x2,%rcx
  return hpetReg->MAIN_CNT;
  804160a4d1:	48 a1 08 56 88 41 80 	movabs 0x8041885608,%rax
  804160a4d8:	00 00 00 
  804160a4db:	48 8b b8 f0 00 00 00 	mov    0xf0(%rax),%rdi
  __asm __volatile("rdtsc"
  804160a4e2:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a4e4:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a4e8:	41 89 c0             	mov    %eax,%r8d
  804160a4eb:	49 09 d0             	or     %rdx,%r8
  804160a4ee:	48 be 08 56 88 41 80 	movabs $0x8041885608,%rsi
  804160a4f5:	00 00 00 

  uint64_t tick0 = hpet_get_main_cnt();
  uint64_t tsc0 = read_tsc();
  do {
    asm("pause");
  804160a4f8:	f3 90                	pause  
  return hpetReg->MAIN_CNT;
  804160a4fa:	48 8b 06             	mov    (%rsi),%rax
  804160a4fd:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
    delta = hpet_get_main_cnt() - tick0;
  804160a504:	48 29 f8             	sub    %rdi,%rax
  } while (delta < target);
  804160a507:	48 39 c1             	cmp    %rax,%rcx
  804160a50a:	77 ec                	ja     804160a4f8 <hpet_cpu_frequency+0x49>
  __asm __volatile("rdtsc"
  804160a50c:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a50e:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a512:	89 c0                	mov    %eax,%eax
  804160a514:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * time_res; 
  804160a517:	48 89 d0             	mov    %rdx,%rax
  804160a51a:	4c 29 c0             	sub    %r8,%rax
  804160a51d:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160a521:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160a525:	48 c1 e0 02          	shl    $0x2,%rax
  // LAB 5 code end
  // return 0;
}
  804160a529:	c3                   	retq   

000000804160a52a <hpet_enable_interrupts_tim1>:
hpet_enable_interrupts_tim1(void) {
  804160a52a:	55                   	push   %rbp
  804160a52b:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  804160a52e:	48 b8 08 56 88 41 80 	movabs $0x8041885608,%rax
  804160a535:	00 00 00 
  804160a538:	48 8b 08             	mov    (%rax),%rcx
  804160a53b:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160a53f:	48 83 c8 02          	or     $0x2,%rax
  804160a543:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM1_CONF = (IRQ_CLOCK << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  804160a547:	48 c7 81 20 01 00 00 	movq   $0x104c,0x120(%rcx)
  804160a54e:	4c 10 00 00 
  return hpetReg->MAIN_CNT;
  804160a552:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM1_COMP = hpet_get_main_cnt() + 3 * Peta / 2 / hpetFemto;
  804160a559:	48 bf 00 56 88 41 80 	movabs $0x8041885600,%rdi
  804160a560:	00 00 00 
  804160a563:	48 b8 00 c0 29 f7 3d 	movabs $0x5543df729c000,%rax
  804160a56a:	54 05 00 
  804160a56d:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a572:	48 f7 37             	divq   (%rdi)
  804160a575:	48 01 c6             	add    %rax,%rsi
  804160a578:	48 89 b1 28 01 00 00 	mov    %rsi,0x128(%rcx)
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  804160a57f:	48 89 81 28 01 00 00 	mov    %rax,0x128(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  804160a586:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  804160a58d:	00 00 00 
  804160a590:	89 c7                	mov    %eax,%edi
  804160a592:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  804160a598:	48 b8 35 90 60 41 80 	movabs $0x8041609035,%rax
  804160a59f:	00 00 00 
  804160a5a2:	ff d0                	callq  *%rax
}
  804160a5a4:	5d                   	pop    %rbp
  804160a5a5:	c3                   	retq   

000000804160a5a6 <hpet_enable_interrupts_tim0>:
hpet_enable_interrupts_tim0(void) {
  804160a5a6:	55                   	push   %rbp
  804160a5a7:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  804160a5aa:	48 b8 08 56 88 41 80 	movabs $0x8041885608,%rax
  804160a5b1:	00 00 00 
  804160a5b4:	48 8b 08             	mov    (%rax),%rcx
  804160a5b7:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160a5bb:	48 83 c8 02          	or     $0x2,%rax
  804160a5bf:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM0_CONF = (IRQ_TIMER << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  804160a5c3:	48 c7 81 00 01 00 00 	movq   $0x4c,0x100(%rcx)
  804160a5ca:	4c 00 00 00 
  return hpetReg->MAIN_CNT;
  804160a5ce:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM0_COMP = hpet_get_main_cnt() + Peta / 2 / hpetFemto;
  804160a5d5:	48 bf 00 56 88 41 80 	movabs $0x8041885600,%rdi
  804160a5dc:	00 00 00 
  804160a5df:	48 b8 00 40 63 52 bf 	movabs $0x1c6bf52634000,%rax
  804160a5e6:	c6 01 00 
  804160a5e9:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a5ee:	48 f7 37             	divq   (%rdi)
  804160a5f1:	48 01 c6             	add    %rax,%rsi
  804160a5f4:	48 89 b1 08 01 00 00 	mov    %rsi,0x108(%rcx)
  hpetReg->TIM0_COMP = Peta / 2 / hpetFemto;
  804160a5fb:	48 89 81 08 01 00 00 	mov    %rax,0x108(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_TIMER));
  804160a602:	66 a1 e8 07 62 41 80 	movabs 0x80416207e8,%ax
  804160a609:	00 00 00 
  804160a60c:	89 c7                	mov    %eax,%edi
  804160a60e:	81 e7 fe ff 00 00    	and    $0xfffe,%edi
  804160a614:	48 b8 35 90 60 41 80 	movabs $0x8041609035,%rax
  804160a61b:	00 00 00 
  804160a61e:	ff d0                	callq  *%rax
}
  804160a620:	5d                   	pop    %rbp
  804160a621:	c3                   	retq   

000000804160a622 <check_sum>:
  switch (type) {
  804160a622:	85 f6                	test   %esi,%esi
  804160a624:	74 0f                	je     804160a635 <check_sum+0x13>
  uint32_t len = 0;
  804160a626:	ba 00 00 00 00       	mov    $0x0,%edx
  switch (type) {
  804160a62b:	83 fe 01             	cmp    $0x1,%esi
  804160a62e:	75 08                	jne    804160a638 <check_sum+0x16>
      len = ((ACPISDTHeader *)Table)->Length;
  804160a630:	8b 57 04             	mov    0x4(%rdi),%edx
      break;
  804160a633:	eb 03                	jmp    804160a638 <check_sum+0x16>
      len = ((RSDP *)Table)->Length;
  804160a635:	8b 57 14             	mov    0x14(%rdi),%edx
  for (int i = 0; i < len; i++)
  804160a638:	85 d2                	test   %edx,%edx
  804160a63a:	74 24                	je     804160a660 <check_sum+0x3e>
  804160a63c:	48 89 f8             	mov    %rdi,%rax
  804160a63f:	8d 52 ff             	lea    -0x1(%rdx),%edx
  804160a642:	48 8d 74 17 01       	lea    0x1(%rdi,%rdx,1),%rsi
  int sum      = 0;
  804160a647:	ba 00 00 00 00       	mov    $0x0,%edx
    sum += ((uint8_t *)Table)[i];
  804160a64c:	0f b6 08             	movzbl (%rax),%ecx
  804160a64f:	01 ca                	add    %ecx,%edx
  for (int i = 0; i < len; i++)
  804160a651:	48 83 c0 01          	add    $0x1,%rax
  804160a655:	48 39 f0             	cmp    %rsi,%rax
  804160a658:	75 f2                	jne    804160a64c <check_sum+0x2a>
  if (sum % 0x100 == 0)
  804160a65a:	84 d2                	test   %dl,%dl
  804160a65c:	0f 94 c0             	sete   %al
}
  804160a65f:	c3                   	retq   
  int sum      = 0;
  804160a660:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a665:	eb f3                	jmp    804160a65a <check_sum+0x38>

000000804160a667 <get_rsdp>:
  if (krsdp != NULL)
  804160a667:	48 a1 f0 55 88 41 80 	movabs 0x80418855f0,%rax
  804160a66e:	00 00 00 
  804160a671:	48 85 c0             	test   %rax,%rax
  804160a674:	74 01                	je     804160a677 <get_rsdp+0x10>
}
  804160a676:	c3                   	retq   
get_rsdp(void) {
  804160a677:	55                   	push   %rbp
  804160a678:	48 89 e5             	mov    %rsp,%rbp
  if (uefi_lp->ACPIRoot == 0)
  804160a67b:	48 a1 00 00 62 41 80 	movabs 0x8041620000,%rax
  804160a682:	00 00 00 
  804160a685:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160a689:	48 85 ff             	test   %rdi,%rdi
  804160a68c:	74 1d                	je     804160a6ab <get_rsdp+0x44>
  krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  804160a68e:	be 24 00 00 00       	mov    $0x24,%esi
  804160a693:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  804160a69a:	00 00 00 
  804160a69d:	ff d0                	callq  *%rax
  804160a69f:	48 a3 f0 55 88 41 80 	movabs %rax,0x80418855f0
  804160a6a6:	00 00 00 
}
  804160a6a9:	5d                   	pop    %rbp
  804160a6aa:	c3                   	retq   
    panic("No rsdp\n");
  804160a6ab:	48 ba 85 e8 60 41 80 	movabs $0x804160e885,%rdx
  804160a6b2:	00 00 00 
  804160a6b5:	be 65 00 00 00       	mov    $0x65,%esi
  804160a6ba:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a6c1:	00 00 00 
  804160a6c4:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a6c9:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a6d0:	00 00 00 
  804160a6d3:	ff d1                	callq  *%rcx

000000804160a6d5 <get_fadt>:
  if (!kfadt) {
  804160a6d5:	48 b8 e8 55 88 41 80 	movabs $0x80418855e8,%rax
  804160a6dc:	00 00 00 
  804160a6df:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a6e3:	74 0b                	je     804160a6f0 <get_fadt+0x1b>
}
  804160a6e5:	48 a1 e8 55 88 41 80 	movabs 0x80418855e8,%rax
  804160a6ec:	00 00 00 
  804160a6ef:	c3                   	retq   
get_fadt(void) {
  804160a6f0:	55                   	push   %rbp
  804160a6f1:	48 89 e5             	mov    %rsp,%rbp
    kfadt = acpi_find_table("FACP");
  804160a6f4:	48 bf d7 e8 60 41 80 	movabs $0x804160e8d7,%rdi
  804160a6fb:	00 00 00 
  804160a6fe:	48 b8 4f a0 60 41 80 	movabs $0x804160a04f,%rax
  804160a705:	00 00 00 
  804160a708:	ff d0                	callq  *%rax
  804160a70a:	48 a3 e8 55 88 41 80 	movabs %rax,0x80418855e8
  804160a711:	00 00 00 
}
  804160a714:	48 a1 e8 55 88 41 80 	movabs 0x80418855e8,%rax
  804160a71b:	00 00 00 
  804160a71e:	5d                   	pop    %rbp
  804160a71f:	c3                   	retq   

000000804160a720 <acpi_enable>:
acpi_enable(void) {
  804160a720:	55                   	push   %rbp
  804160a721:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  804160a724:	48 b8 d5 a6 60 41 80 	movabs $0x804160a6d5,%rax
  804160a72b:	00 00 00 
  804160a72e:	ff d0                	callq  *%rax
  804160a730:	48 89 c1             	mov    %rax,%rcx
  __asm __volatile("outb %0,%w1"
  804160a733:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  804160a737:	8b 51 30             	mov    0x30(%rcx),%edx
  804160a73a:	ee                   	out    %al,(%dx)
  while ((inw(fadt->PM1aControlBlock) & 1) == 0) {
  804160a73b:	8b 51 40             	mov    0x40(%rcx),%edx
  __asm __volatile("inw %w1,%0"
  804160a73e:	66 ed                	in     (%dx),%ax
  804160a740:	a8 01                	test   $0x1,%al
  804160a742:	74 fa                	je     804160a73e <acpi_enable+0x1e>
}
  804160a744:	5d                   	pop    %rbp
  804160a745:	c3                   	retq   

000000804160a746 <get_hpet>:
  if (!khpet) {
  804160a746:	48 b8 c8 55 88 41 80 	movabs $0x80418855c8,%rax
  804160a74d:	00 00 00 
  804160a750:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a754:	74 0b                	je     804160a761 <get_hpet+0x1b>
}
  804160a756:	48 a1 c8 55 88 41 80 	movabs 0x80418855c8,%rax
  804160a75d:	00 00 00 
  804160a760:	c3                   	retq   
get_hpet(void) {
  804160a761:	55                   	push   %rbp
  804160a762:	48 89 e5             	mov    %rsp,%rbp
    khpet = acpi_find_table("HPET");
  804160a765:	48 bf dc e8 60 41 80 	movabs $0x804160e8dc,%rdi
  804160a76c:	00 00 00 
  804160a76f:	48 b8 4f a0 60 41 80 	movabs $0x804160a04f,%rax
  804160a776:	00 00 00 
  804160a779:	ff d0                	callq  *%rax
  804160a77b:	48 a3 c8 55 88 41 80 	movabs %rax,0x80418855c8
  804160a782:	00 00 00 
}
  804160a785:	48 a1 c8 55 88 41 80 	movabs 0x80418855c8,%rax
  804160a78c:	00 00 00 
  804160a78f:	5d                   	pop    %rbp
  804160a790:	c3                   	retq   

000000804160a791 <hpet_register>:
hpet_register(void) {
  804160a791:	55                   	push   %rbp
  804160a792:	48 89 e5             	mov    %rsp,%rbp
  HPET *hpet_timer = get_hpet();
  804160a795:	48 b8 46 a7 60 41 80 	movabs $0x804160a746,%rax
  804160a79c:	00 00 00 
  804160a79f:	ff d0                	callq  *%rax
  if (hpet_timer->address.address == 0)
  804160a7a1:	48 8b 78 2c          	mov    0x2c(%rax),%rdi
  804160a7a5:	48 85 ff             	test   %rdi,%rdi
  804160a7a8:	74 13                	je     804160a7bd <hpet_register+0x2c>
  return mmio_map_region(paddr, sizeof(HPETRegister));
  804160a7aa:	be 00 04 00 00       	mov    $0x400,%esi
  804160a7af:	48 b8 ac 82 60 41 80 	movabs $0x80416082ac,%rax
  804160a7b6:	00 00 00 
  804160a7b9:	ff d0                	callq  *%rax
}
  804160a7bb:	5d                   	pop    %rbp
  804160a7bc:	c3                   	retq   
    panic("hpet is unavailable\n");
  804160a7bd:	48 ba e1 e8 60 41 80 	movabs $0x804160e8e1,%rdx
  804160a7c4:	00 00 00 
  804160a7c7:	be de 00 00 00       	mov    $0xde,%esi
  804160a7cc:	48 bf 8e e8 60 41 80 	movabs $0x804160e88e,%rdi
  804160a7d3:	00 00 00 
  804160a7d6:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a7db:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a7e2:	00 00 00 
  804160a7e5:	ff d1                	callq  *%rcx

000000804160a7e7 <hpet_init>:
  if (hpetReg == NULL) {
  804160a7e7:	48 b8 08 56 88 41 80 	movabs $0x8041885608,%rax
  804160a7ee:	00 00 00 
  804160a7f1:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a7f5:	74 01                	je     804160a7f8 <hpet_init+0x11>
  804160a7f7:	c3                   	retq   
hpet_init() {
  804160a7f8:	55                   	push   %rbp
  804160a7f9:	48 89 e5             	mov    %rsp,%rbp
  804160a7fc:	53                   	push   %rbx
  804160a7fd:	48 83 ec 08          	sub    $0x8,%rsp
  __asm __volatile("inb %w1,%0"
  804160a801:	bb 70 00 00 00       	mov    $0x70,%ebx
  804160a806:	89 da                	mov    %ebx,%edx
  804160a808:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) | NMI_LOCK);
  804160a809:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  804160a80c:	ee                   	out    %al,(%dx)
    hpetReg   = hpet_register();
  804160a80d:	48 b8 91 a7 60 41 80 	movabs $0x804160a791,%rax
  804160a814:	00 00 00 
  804160a817:	ff d0                	callq  *%rax
  804160a819:	48 89 c6             	mov    %rax,%rsi
  804160a81c:	48 a3 08 56 88 41 80 	movabs %rax,0x8041885608
  804160a823:	00 00 00 
    hpetFemto = (uintptr_t)(hpetReg->GCAP_ID >> 32);
  804160a826:	48 8b 08             	mov    (%rax),%rcx
  804160a829:	48 c1 e9 20          	shr    $0x20,%rcx
  804160a82d:	48 89 c8             	mov    %rcx,%rax
  804160a830:	48 a3 00 56 88 41 80 	movabs %rax,0x8041885600
  804160a837:	00 00 00 
    hpetFreq = (1 * Peta) / hpetFemto;
  804160a83a:	48 b8 00 80 c6 a4 7e 	movabs $0x38d7ea4c68000,%rax
  804160a841:	8d 03 00 
  804160a844:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a849:	48 f7 f1             	div    %rcx
  804160a84c:	48 a3 f8 55 88 41 80 	movabs %rax,0x80418855f8
  804160a853:	00 00 00 
    hpetReg->GEN_CONF |= 1;
  804160a856:	48 8b 46 10          	mov    0x10(%rsi),%rax
  804160a85a:	48 83 c8 01          	or     $0x1,%rax
  804160a85e:	48 89 46 10          	mov    %rax,0x10(%rsi)
  __asm __volatile("inb %w1,%0"
  804160a862:	89 da                	mov    %ebx,%edx
  804160a864:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  804160a865:	83 e0 7f             	and    $0x7f,%eax
  804160a868:	ee                   	out    %al,(%dx)
}
  804160a869:	48 83 c4 08          	add    $0x8,%rsp
  804160a86d:	5b                   	pop    %rbx
  804160a86e:	5d                   	pop    %rbp
  804160a86f:	c3                   	retq   

000000804160a870 <hpet_print_struct>:
hpet_print_struct(void) {
  804160a870:	55                   	push   %rbp
  804160a871:	48 89 e5             	mov    %rsp,%rbp
  804160a874:	41 54                	push   %r12
  804160a876:	53                   	push   %rbx
  HPET *hpet = get_hpet();
  804160a877:	48 b8 46 a7 60 41 80 	movabs $0x804160a746,%rax
  804160a87e:	00 00 00 
  804160a881:	ff d0                	callq  *%rax
  804160a883:	49 89 c4             	mov    %rax,%r12
  cprintf("signature = %s\n", (hpet->h).Signature);
  804160a886:	48 89 c6             	mov    %rax,%rsi
  804160a889:	48 bf f6 e8 60 41 80 	movabs $0x804160e8f6,%rdi
  804160a890:	00 00 00 
  804160a893:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a898:	48 bb 0d 92 60 41 80 	movabs $0x804160920d,%rbx
  804160a89f:	00 00 00 
  804160a8a2:	ff d3                	callq  *%rbx
  cprintf("length = %08x\n", (hpet->h).Length);
  804160a8a4:	41 8b 74 24 04       	mov    0x4(%r12),%esi
  804160a8a9:	48 bf 06 e9 60 41 80 	movabs $0x804160e906,%rdi
  804160a8b0:	00 00 00 
  804160a8b3:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8b8:	ff d3                	callq  *%rbx
  cprintf("revision = %08x\n", (hpet->h).Revision);
  804160a8ba:	41 0f b6 74 24 08    	movzbl 0x8(%r12),%esi
  804160a8c0:	48 bf 2a e9 60 41 80 	movabs $0x804160e92a,%rdi
  804160a8c7:	00 00 00 
  804160a8ca:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8cf:	ff d3                	callq  *%rbx
  cprintf("checksum = %08x\n", (hpet->h).Checksum);
  804160a8d1:	41 0f b6 74 24 09    	movzbl 0x9(%r12),%esi
  804160a8d7:	48 bf 15 e9 60 41 80 	movabs $0x804160e915,%rdi
  804160a8de:	00 00 00 
  804160a8e1:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8e6:	ff d3                	callq  *%rbx
  cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  804160a8e8:	41 8b 74 24 18       	mov    0x18(%r12),%esi
  804160a8ed:	48 bf 26 e9 60 41 80 	movabs $0x804160e926,%rdi
  804160a8f4:	00 00 00 
  804160a8f7:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8fc:	ff d3                	callq  *%rbx
  cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  804160a8fe:	41 8b 74 24 1c       	mov    0x1c(%r12),%esi
  804160a903:	48 bf 3b e9 60 41 80 	movabs $0x804160e93b,%rdi
  804160a90a:	00 00 00 
  804160a90d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a912:	ff d3                	callq  *%rbx
  cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);
  804160a914:	41 8b 74 24 20       	mov    0x20(%r12),%esi
  804160a919:	48 bf 4e e9 60 41 80 	movabs $0x804160e94e,%rdi
  804160a920:	00 00 00 
  804160a923:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a928:	ff d3                	callq  *%rbx
  cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  804160a92a:	41 0f b6 74 24 24    	movzbl 0x24(%r12),%esi
  804160a930:	48 bf 67 e9 60 41 80 	movabs $0x804160e967,%rdi
  804160a937:	00 00 00 
  804160a93a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a93f:	ff d3                	callq  *%rbx
  cprintf("comparator_count = %08x\n", hpet->comparator_count);
  804160a941:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a947:	83 e6 1f             	and    $0x1f,%esi
  804160a94a:	48 bf 7f e9 60 41 80 	movabs $0x804160e97f,%rdi
  804160a951:	00 00 00 
  804160a954:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a959:	ff d3                	callq  *%rbx
  cprintf("counter_size = %08x\n", hpet->counter_size);
  804160a95b:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a961:	40 c0 ee 05          	shr    $0x5,%sil
  804160a965:	83 e6 01             	and    $0x1,%esi
  804160a968:	48 bf 98 e9 60 41 80 	movabs $0x804160e998,%rdi
  804160a96f:	00 00 00 
  804160a972:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a977:	ff d3                	callq  *%rbx
  cprintf("reserved = %08x\n", hpet->reserved);
  804160a979:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a97f:	40 c0 ee 06          	shr    $0x6,%sil
  804160a983:	83 e6 01             	and    $0x1,%esi
  804160a986:	48 bf ad e9 60 41 80 	movabs $0x804160e9ad,%rdi
  804160a98d:	00 00 00 
  804160a990:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a995:	ff d3                	callq  *%rbx
  cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  804160a997:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a99d:	40 c0 ee 07          	shr    $0x7,%sil
  804160a9a1:	40 0f b6 f6          	movzbl %sil,%esi
  804160a9a5:	48 bf be e9 60 41 80 	movabs $0x804160e9be,%rdi
  804160a9ac:	00 00 00 
  804160a9af:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9b4:	ff d3                	callq  *%rbx
  cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  804160a9b6:	41 0f b7 74 24 26    	movzwl 0x26(%r12),%esi
  804160a9bc:	48 bf d9 e9 60 41 80 	movabs $0x804160e9d9,%rdi
  804160a9c3:	00 00 00 
  804160a9c6:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9cb:	ff d3                	callq  *%rbx
  cprintf("hpet_number = %08x\n", hpet->hpet_number);
  804160a9cd:	41 0f b6 74 24 34    	movzbl 0x34(%r12),%esi
  804160a9d3:	48 bf ef e9 60 41 80 	movabs $0x804160e9ef,%rdi
  804160a9da:	00 00 00 
  804160a9dd:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9e2:	ff d3                	callq  *%rbx
  cprintf("minimum_tick = %08x\n", hpet->minimum_tick);
  804160a9e4:	41 0f b7 74 24 35    	movzwl 0x35(%r12),%esi
  804160a9ea:	48 bf 03 ea 60 41 80 	movabs $0x804160ea03,%rdi
  804160a9f1:	00 00 00 
  804160a9f4:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9f9:	ff d3                	callq  *%rbx
  cprintf("address_structure:\n");
  804160a9fb:	48 bf 18 ea 60 41 80 	movabs $0x804160ea18,%rdi
  804160aa02:	00 00 00 
  804160aa05:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa0a:	ff d3                	callq  *%rbx
  cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  804160aa0c:	41 0f b6 74 24 28    	movzbl 0x28(%r12),%esi
  804160aa12:	48 bf 2c ea 60 41 80 	movabs $0x804160ea2c,%rdi
  804160aa19:	00 00 00 
  804160aa1c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa21:	ff d3                	callq  *%rbx
  cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  804160aa23:	41 0f b6 74 24 29    	movzbl 0x29(%r12),%esi
  804160aa29:	48 bf 45 ea 60 41 80 	movabs $0x804160ea45,%rdi
  804160aa30:	00 00 00 
  804160aa33:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa38:	ff d3                	callq  *%rbx
  cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  804160aa3a:	41 0f b6 74 24 2a    	movzbl 0x2a(%r12),%esi
  804160aa40:	48 bf 60 ea 60 41 80 	movabs $0x804160ea60,%rdi
  804160aa47:	00 00 00 
  804160aa4a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa4f:	ff d3                	callq  *%rbx
  cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
  804160aa51:	49 8b 74 24 2c       	mov    0x2c(%r12),%rsi
  804160aa56:	48 bf 7c ea 60 41 80 	movabs $0x804160ea7c,%rdi
  804160aa5d:	00 00 00 
  804160aa60:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa65:	ff d3                	callq  *%rbx
}
  804160aa67:	5b                   	pop    %rbx
  804160aa68:	41 5c                	pop    %r12
  804160aa6a:	5d                   	pop    %rbp
  804160aa6b:	c3                   	retq   

000000804160aa6c <hpet_print_reg>:
hpet_print_reg(void) {
  804160aa6c:	55                   	push   %rbp
  804160aa6d:	48 89 e5             	mov    %rsp,%rbp
  804160aa70:	41 54                	push   %r12
  804160aa72:	53                   	push   %rbx
  cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  804160aa73:	49 bc 08 56 88 41 80 	movabs $0x8041885608,%r12
  804160aa7a:	00 00 00 
  804160aa7d:	49 8b 04 24          	mov    (%r12),%rax
  804160aa81:	48 8b 30             	mov    (%rax),%rsi
  804160aa84:	48 bf 8d ea 60 41 80 	movabs $0x804160ea8d,%rdi
  804160aa8b:	00 00 00 
  804160aa8e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa93:	48 bb 0d 92 60 41 80 	movabs $0x804160920d,%rbx
  804160aa9a:	00 00 00 
  804160aa9d:	ff d3                	callq  *%rbx
  cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  804160aa9f:	49 8b 04 24          	mov    (%r12),%rax
  804160aaa3:	48 8b 70 10          	mov    0x10(%rax),%rsi
  804160aaa7:	48 bf 9f ea 60 41 80 	movabs $0x804160ea9f,%rdi
  804160aaae:	00 00 00 
  804160aab1:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aab6:	ff d3                	callq  *%rbx
  cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  804160aab8:	49 8b 04 24          	mov    (%r12),%rax
  804160aabc:	48 8b 70 20          	mov    0x20(%rax),%rsi
  804160aac0:	48 bf b2 ea 60 41 80 	movabs $0x804160eab2,%rdi
  804160aac7:	00 00 00 
  804160aaca:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aacf:	ff d3                	callq  *%rbx
  cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  804160aad1:	49 8b 04 24          	mov    (%r12),%rax
  804160aad5:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
  804160aadc:	48 bf c6 ea 60 41 80 	movabs $0x804160eac6,%rdi
  804160aae3:	00 00 00 
  804160aae6:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aaeb:	ff d3                	callq  *%rbx
  cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  804160aaed:	49 8b 04 24          	mov    (%r12),%rax
  804160aaf1:	48 8b b0 00 01 00 00 	mov    0x100(%rax),%rsi
  804160aaf8:	48 bf d9 ea 60 41 80 	movabs $0x804160ead9,%rdi
  804160aaff:	00 00 00 
  804160ab02:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab07:	ff d3                	callq  *%rbx
  cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  804160ab09:	49 8b 04 24          	mov    (%r12),%rax
  804160ab0d:	48 8b b0 08 01 00 00 	mov    0x108(%rax),%rsi
  804160ab14:	48 bf ed ea 60 41 80 	movabs $0x804160eaed,%rdi
  804160ab1b:	00 00 00 
  804160ab1e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab23:	ff d3                	callq  *%rbx
  cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  804160ab25:	49 8b 04 24          	mov    (%r12),%rax
  804160ab29:	48 8b b0 10 01 00 00 	mov    0x110(%rax),%rsi
  804160ab30:	48 bf 01 eb 60 41 80 	movabs $0x804160eb01,%rdi
  804160ab37:	00 00 00 
  804160ab3a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab3f:	ff d3                	callq  *%rbx
  cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  804160ab41:	49 8b 04 24          	mov    (%r12),%rax
  804160ab45:	48 8b b0 20 01 00 00 	mov    0x120(%rax),%rsi
  804160ab4c:	48 bf 14 eb 60 41 80 	movabs $0x804160eb14,%rdi
  804160ab53:	00 00 00 
  804160ab56:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab5b:	ff d3                	callq  *%rbx
  cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  804160ab5d:	49 8b 04 24          	mov    (%r12),%rax
  804160ab61:	48 8b b0 28 01 00 00 	mov    0x128(%rax),%rsi
  804160ab68:	48 bf 28 eb 60 41 80 	movabs $0x804160eb28,%rdi
  804160ab6f:	00 00 00 
  804160ab72:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab77:	ff d3                	callq  *%rbx
  cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  804160ab79:	49 8b 04 24          	mov    (%r12),%rax
  804160ab7d:	48 8b b0 30 01 00 00 	mov    0x130(%rax),%rsi
  804160ab84:	48 bf 3c eb 60 41 80 	movabs $0x804160eb3c,%rdi
  804160ab8b:	00 00 00 
  804160ab8e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab93:	ff d3                	callq  *%rbx
  cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  804160ab95:	49 8b 04 24          	mov    (%r12),%rax
  804160ab99:	48 8b b0 40 01 00 00 	mov    0x140(%rax),%rsi
  804160aba0:	48 bf 4f eb 60 41 80 	movabs $0x804160eb4f,%rdi
  804160aba7:	00 00 00 
  804160abaa:	b8 00 00 00 00       	mov    $0x0,%eax
  804160abaf:	ff d3                	callq  *%rbx
  cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  804160abb1:	49 8b 04 24          	mov    (%r12),%rax
  804160abb5:	48 8b b0 48 01 00 00 	mov    0x148(%rax),%rsi
  804160abbc:	48 bf 63 eb 60 41 80 	movabs $0x804160eb63,%rdi
  804160abc3:	00 00 00 
  804160abc6:	b8 00 00 00 00       	mov    $0x0,%eax
  804160abcb:	ff d3                	callq  *%rbx
  cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
  804160abcd:	49 8b 04 24          	mov    (%r12),%rax
  804160abd1:	48 8b b0 50 01 00 00 	mov    0x150(%rax),%rsi
  804160abd8:	48 bf 77 eb 60 41 80 	movabs $0x804160eb77,%rdi
  804160abdf:	00 00 00 
  804160abe2:	b8 00 00 00 00       	mov    $0x0,%eax
  804160abe7:	ff d3                	callq  *%rbx
}
  804160abe9:	5b                   	pop    %rbx
  804160abea:	41 5c                	pop    %r12
  804160abec:	5d                   	pop    %rbp
  804160abed:	c3                   	retq   

000000804160abee <hpet_get_main_cnt>:
  return hpetReg->MAIN_CNT;
  804160abee:	48 a1 08 56 88 41 80 	movabs 0x8041885608,%rax
  804160abf5:	00 00 00 
  804160abf8:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
}
  804160abff:	c3                   	retq   

000000804160ac00 <pmtimer_get_timeval>:

uint32_t
pmtimer_get_timeval(void) {
  804160ac00:	55                   	push   %rbp
  804160ac01:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  804160ac04:	48 b8 d5 a6 60 41 80 	movabs $0x804160a6d5,%rax
  804160ac0b:	00 00 00 
  804160ac0e:	ff d0                	callq  *%rax
  __asm __volatile("inl %w1,%0"
  804160ac10:	8b 50 4c             	mov    0x4c(%rax),%edx
  804160ac13:	ed                   	in     (%dx),%eax
  return inl(fadt->PMTimerBlock);
}
  804160ac14:	5d                   	pop    %rbp
  804160ac15:	c3                   	retq   

000000804160ac16 <pmtimer_cpu_frequency>:
// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
// Hint: use pmtimer_get_timeval function and do not forget that ACPI PM timer
// can be 24-bit or 32-bit.
uint64_t
pmtimer_cpu_frequency(void) {
  804160ac16:	55                   	push   %rbp
  804160ac17:	48 89 e5             	mov    %rsp,%rbp
  804160ac1a:	41 55                	push   %r13
  804160ac1c:	41 54                	push   %r12
  804160ac1e:	53                   	push   %rbx
  804160ac1f:	48 83 ec 08          	sub    $0x8,%rsp
  // LAB 5 code
  uint32_t time_res = 100;
  uint32_t tick0 = pmtimer_get_timeval();
  804160ac23:	48 b8 00 ac 60 41 80 	movabs $0x804160ac00,%rax
  804160ac2a:	00 00 00 
  804160ac2d:	ff d0                	callq  *%rax
  804160ac2f:	89 c3                	mov    %eax,%ebx
  __asm __volatile("rdtsc"
  804160ac31:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ac33:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ac37:	89 c0                	mov    %eax,%eax
  804160ac39:	48 09 c2             	or     %rax,%rdx
  804160ac3c:	49 89 d5             	mov    %rdx,%r13

  uint64_t tsc0 = read_tsc();

  do {
    asm("pause");
    uint32_t tick1 = pmtimer_get_timeval();
  804160ac3f:	49 bc 00 ac 60 41 80 	movabs $0x804160ac00,%r12
  804160ac46:	00 00 00 
  804160ac49:	eb 17                	jmp    804160ac62 <pmtimer_cpu_frequency+0x4c>
    delta = tick1 - tick0;
    if (-delta <= 0xFFFFFF) {
      delta += 0xFFFFFF;
    } else if (tick0 > tick1) {
  804160ac4b:	39 c3                	cmp    %eax,%ebx
  804160ac4d:	76 0a                	jbe    804160ac59 <pmtimer_cpu_frequency+0x43>
      delta += 0xFFFFFFFF;
  804160ac4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160ac54:	48 01 c1             	add    %rax,%rcx
  804160ac57:	eb 28                	jmp    804160ac81 <pmtimer_cpu_frequency+0x6b>
    }
  } while (delta < target);
  804160ac59:	48 81 f9 d2 8b 00 00 	cmp    $0x8bd2,%rcx
  804160ac60:	77 1f                	ja     804160ac81 <pmtimer_cpu_frequency+0x6b>
    asm("pause");
  804160ac62:	f3 90                	pause  
    uint32_t tick1 = pmtimer_get_timeval();
  804160ac64:	41 ff d4             	callq  *%r12
    delta = tick1 - tick0;
  804160ac67:	89 c1                	mov    %eax,%ecx
  804160ac69:	29 d9                	sub    %ebx,%ecx
    if (-delta <= 0xFFFFFF) {
  804160ac6b:	48 89 ca             	mov    %rcx,%rdx
  804160ac6e:	48 f7 da             	neg    %rdx
  804160ac71:	48 81 fa ff ff ff 00 	cmp    $0xffffff,%rdx
  804160ac78:	77 d1                	ja     804160ac4b <pmtimer_cpu_frequency+0x35>
      delta += 0xFFFFFF;
  804160ac7a:	48 81 c1 ff ff ff 00 	add    $0xffffff,%rcx
  __asm __volatile("rdtsc"
  804160ac81:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ac83:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ac87:	89 c0                	mov    %eax,%eax
  804160ac89:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * PM_FREQ / delta;
  804160ac8c:	4c 29 ea             	sub    %r13,%rdx
  804160ac8f:	48 69 c2 99 9e 36 00 	imul   $0x369e99,%rdx,%rax
  804160ac96:	ba 00 00 00 00       	mov    $0x0,%edx
  804160ac9b:	48 f7 f1             	div    %rcx
  // LAB 5 code end
  // return 0;
}
  804160ac9e:	48 83 c4 08          	add    $0x8,%rsp
  804160aca2:	5b                   	pop    %rbx
  804160aca3:	41 5c                	pop    %r12
  804160aca5:	41 5d                	pop    %r13
  804160aca7:	5d                   	pop    %rbp
  804160aca8:	c3                   	retq   

000000804160aca9 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160aca9:	48 a1 28 45 88 41 80 	movabs 0x8041884528,%rax
  804160acb0:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  804160acb3:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  804160acb9:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160acbc:	83 fa 02             	cmp    $0x2,%edx
  804160acbf:	76 5f                	jbe    804160ad20 <sched_halt+0x77>
  804160acc1:	48 8d 90 f4 01 00 00 	lea    0x1f4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  804160acc8:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  804160accd:	8b 02                	mov    (%rdx),%eax
  804160accf:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160acd2:	83 f8 02             	cmp    $0x2,%eax
  804160acd5:	76 49                	jbe    804160ad20 <sched_halt+0x77>
  for (i = 0; i < NENV; i++) {
  804160acd7:	83 c1 01             	add    $0x1,%ecx
  804160acda:	48 81 c2 20 01 00 00 	add    $0x120,%rdx
  804160ace1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  804160ace7:	75 e4                	jne    804160accd <sched_halt+0x24>
sched_halt(void) {
  804160ace9:	55                   	push   %rbp
  804160acea:	48 89 e5             	mov    %rsp,%rbp
  804160aced:	53                   	push   %rbx
  804160acee:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  804160acf2:	48 bf 98 eb 60 41 80 	movabs $0x804160eb98,%rdi
  804160acf9:	00 00 00 
  804160acfc:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ad01:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160ad08:	00 00 00 
  804160ad0b:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  804160ad0d:	48 bb 09 3f 60 41 80 	movabs $0x8041603f09,%rbx
  804160ad14:	00 00 00 
  804160ad17:	bf 00 00 00 00       	mov    $0x0,%edi
  804160ad1c:	ff d3                	callq  *%rbx
    while (1)
  804160ad1e:	eb f7                	jmp    804160ad17 <sched_halt+0x6e>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  804160ad20:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  804160ad27:	00 00 00 
  804160ad2a:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  804160ad31:	48 a1 64 5b 88 41 80 	movabs 0x8041885b64,%rax
  804160ad38:	00 00 00 
  804160ad3b:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  804160ad42:	48 89 c4             	mov    %rax,%rsp
  804160ad45:	6a 00                	pushq  $0x0
  804160ad47:	6a 00                	pushq  $0x0
  804160ad49:	fb                   	sti    
  804160ad4a:	f4                   	hlt    
  804160ad4b:	c3                   	retq   

000000804160ad4c <sched_yield>:
sched_yield(void) {
  804160ad4c:	55                   	push   %rbp
  804160ad4d:	48 89 e5             	mov    %rsp,%rbp
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160ad50:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160ad57:	00 00 00 
  804160ad5a:	be 00 00 00 00       	mov    $0x0,%esi
  804160ad5f:	48 85 c0             	test   %rax,%rax
  804160ad62:	74 0c                	je     804160ad70 <sched_yield+0x24>
  804160ad64:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160ad6a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160ad70:	48 b8 28 45 88 41 80 	movabs $0x8041884528,%rax
  804160ad77:	00 00 00 
  804160ad7a:	4c 8b 00             	mov    (%rax),%r8
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160ad7d:	89 f2                	mov    %esi,%edx
  804160ad7f:	eb 04                	jmp    804160ad85 <sched_yield+0x39>
  } while (id != orig);
  804160ad81:	39 c6                	cmp    %eax,%esi
  804160ad83:	74 40                	je     804160adc5 <sched_yield+0x79>
    id = (id + 1) % NENV;
  804160ad85:	8d 42 01             	lea    0x1(%rdx),%eax
  804160ad88:	99                   	cltd   
  804160ad89:	c1 ea 16             	shr    $0x16,%edx
  804160ad8c:	01 d0                	add    %edx,%eax
  804160ad8e:	25 ff 03 00 00       	and    $0x3ff,%eax
  804160ad93:	29 d0                	sub    %edx,%eax
  804160ad95:	89 c2                	mov    %eax,%edx
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160ad97:	48 63 c8             	movslq %eax,%rcx
  804160ad9a:	48 8d 3c c9          	lea    (%rcx,%rcx,8),%rdi
  804160ad9e:	48 c1 e7 05          	shl    $0x5,%rdi
  804160ada2:	4c 01 c7             	add    %r8,%rdi
  804160ada5:	8b 8f d4 00 00 00    	mov    0xd4(%rdi),%ecx
  804160adab:	83 f9 02             	cmp    $0x2,%ecx
  804160adae:	74 09                	je     804160adb9 <sched_yield+0x6d>
       (id == orig && envs[id].env_status == ENV_RUNNING)) {
  804160adb0:	83 f9 03             	cmp    $0x3,%ecx
  804160adb3:	75 cc                	jne    804160ad81 <sched_yield+0x35>
  804160adb5:	39 c6                	cmp    %eax,%esi
  804160adb7:	75 c8                	jne    804160ad81 <sched_yield+0x35>
      env_run(envs + id);
  804160adb9:	48 b8 a6 8e 60 41 80 	movabs $0x8041608ea6,%rax
  804160adc0:	00 00 00 
  804160adc3:	ff d0                	callq  *%rax
  sched_halt();
  804160adc5:	48 b8 a9 ac 60 41 80 	movabs $0x804160aca9,%rax
  804160adcc:	00 00 00 
  804160adcf:	ff d0                	callq  *%rax
}
  804160add1:	5d                   	pop    %rbp
  804160add2:	c3                   	retq   

000000804160add3 <syscall>:
  // return -1;
}

// Dispatches to the correct kernel function, passing the arguments.
uintptr_t
syscall(uintptr_t syscallno, uintptr_t a1, uintptr_t a2, uintptr_t a3, uintptr_t a4, uintptr_t a5) {
  804160add3:	55                   	push   %rbp
  804160add4:	48 89 e5             	mov    %rsp,%rbp
  804160add7:	41 57                	push   %r15
  804160add9:	41 56                	push   %r14
  804160addb:	41 55                	push   %r13
  804160addd:	41 54                	push   %r12
  804160addf:	53                   	push   %rbx
  804160ade0:	48 83 ec 38          	sub    $0x38,%rsp
  804160ade4:	48 89 fb             	mov    %rdi,%rbx
  804160ade7:	49 89 f5             	mov    %rsi,%r13
  804160adea:	49 89 d4             	mov    %rdx,%r12
  804160aded:	4c 89 4d a8          	mov    %r9,-0x58(%rbp)
  // Call the function corresponding to the 'syscallno' parameter.
  // Return any appropriate return value.

  // LAB 8 code
  if (syscallno == SYS_cputs) {
  804160adf1:	48 85 ff             	test   %rdi,%rdi
  804160adf4:	0f 84 a9 00 00 00    	je     804160aea3 <syscall+0xd0>
  804160adfa:	49 89 ce             	mov    %rcx,%r14
  804160adfd:	4d 89 c7             	mov    %r8,%r15
    sys_cputs((const char *) a1, (size_t) a2);
    return 0;
  } else if (syscallno == SYS_cgetc) {
  804160ae00:	48 83 ff 01          	cmp    $0x1,%rdi
  804160ae04:	0f 84 ea 00 00 00    	je     804160aef4 <syscall+0x121>
    return sys_cgetc();
  } else if (syscallno == SYS_getenvid) {
  804160ae0a:	48 83 ff 02          	cmp    $0x2,%rdi
  804160ae0e:	0f 84 f0 00 00 00    	je     804160af04 <syscall+0x131>
    return sys_getenvid();
  } else if (syscallno == SYS_env_destroy) {
  804160ae14:	48 83 ff 03          	cmp    $0x3,%rdi
  804160ae18:	0f 84 f9 00 00 00    	je     804160af17 <syscall+0x144>
    return sys_env_destroy((envid_t) a1);
  // LAB 8 code end
  // LAB 9 code
  } else if (syscallno == SYS_exofork) {
  804160ae1e:	48 83 ff 07          	cmp    $0x7,%rdi
  804160ae22:	0f 84 84 01 00 00    	je     804160afac <syscall+0x1d9>
    return sys_exofork();
  } else if (syscallno == SYS_env_set_status) {
  804160ae28:	48 83 ff 08          	cmp    $0x8,%rdi
  804160ae2c:	0f 84 71 02 00 00    	je     804160b0a3 <syscall+0x2d0>
    return sys_env_set_status((envid_t) a1, (int) a2);
  } else if (syscallno == SYS_page_alloc) {
  804160ae32:	48 83 ff 04          	cmp    $0x4,%rdi
  804160ae36:	0f 84 b4 02 00 00    	je     804160b0f0 <syscall+0x31d>
    return sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
  } else if (syscallno == SYS_page_map) {
  804160ae3c:	48 83 ff 05          	cmp    $0x5,%rdi
  804160ae40:	0f 84 6e 03 00 00    	je     804160b1b4 <syscall+0x3e1>
    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
  } else if (syscallno == SYS_page_unmap) {
  804160ae46:	48 83 ff 06          	cmp    $0x6,%rdi
  804160ae4a:	0f 84 7f 04 00 00    	je     804160b2cf <syscall+0x4fc>
    return sys_page_unmap((envid_t) a1, (void *) a2);
  } else if (syscallno == SYS_env_set_pgfault_upcall) {
  804160ae50:	48 83 ff 09          	cmp    $0x9,%rdi
  804160ae54:	0f 84 e4 04 00 00    	je     804160b33e <syscall+0x56b>
    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
  } else if (syscallno == SYS_yield) {
  804160ae5a:	48 83 ff 0a          	cmp    $0xa,%rdi
  804160ae5e:	0f 84 14 05 00 00    	je     804160b378 <syscall+0x5a5>
    sys_yield();
    return 0;
  } else if (syscallno == SYS_ipc_try_send) {
  804160ae64:	48 83 ff 0b          	cmp    $0xb,%rdi
  804160ae68:	0f 84 16 05 00 00    	je     804160b384 <syscall+0x5b1>
    return sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
  } else if (syscallno == SYS_ipc_recv) {
    return sys_ipc_recv((void *) a1);
  // LAB 9 code end
  } else {
    return -E_INVAL;
  804160ae6e:	48 c7 c0 fd ff ff ff 	mov    $0xfffffffffffffffd,%rax
  } else if (syscallno == SYS_ipc_recv) {
  804160ae75:	48 83 ff 0c          	cmp    $0xc,%rdi
  804160ae79:	75 6a                	jne    804160aee5 <syscall+0x112>
  if ((uintptr_t)dstva < UTOP && PGOFF(dstva)) {
  804160ae7b:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160ae82:	00 00 00 
  804160ae85:	48 39 c6             	cmp    %rax,%rsi
  804160ae88:	0f 87 38 06 00 00    	ja     804160b4c6 <syscall+0x6f3>
  804160ae8e:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
  804160ae94:	0f 84 2c 06 00 00    	je     804160b4c6 <syscall+0x6f3>
    return sys_ipc_recv((void *) a1);
  804160ae9a:	48 c7 c0 fd ff ff ff 	mov    $0xfffffffffffffffd,%rax
  804160aea1:	eb 42                	jmp    804160aee5 <syscall+0x112>
  user_mem_assert(curenv, s, len, PTE_U);
  804160aea3:	b9 04 00 00 00       	mov    $0x4,%ecx
  804160aea8:	48 b8 20 45 88 41 80 	movabs $0x8041884520,%rax
  804160aeaf:	00 00 00 
  804160aeb2:	48 8b 38             	mov    (%rax),%rdi
  804160aeb5:	48 b8 99 84 60 41 80 	movabs $0x8041608499,%rax
  804160aebc:	00 00 00 
  804160aebf:	ff d0                	callq  *%rax
	cprintf("%.*s", (int)len, s);
  804160aec1:	4c 89 ea             	mov    %r13,%rdx
  804160aec4:	44 89 e6             	mov    %r12d,%esi
  804160aec7:	48 bf c1 eb 60 41 80 	movabs $0x804160ebc1,%rdi
  804160aece:	00 00 00 
  804160aed1:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aed6:	48 b9 0d 92 60 41 80 	movabs $0x804160920d,%rcx
  804160aedd:	00 00 00 
  804160aee0:	ff d1                	callq  *%rcx
    return 0;
  804160aee2:	48 89 d8             	mov    %rbx,%rax
  }
  
  // return -E_INVAL;
}
  804160aee5:	48 83 c4 38          	add    $0x38,%rsp
  804160aee9:	5b                   	pop    %rbx
  804160aeea:	41 5c                	pop    %r12
  804160aeec:	41 5d                	pop    %r13
  804160aeee:	41 5e                	pop    %r14
  804160aef0:	41 5f                	pop    %r15
  804160aef2:	5d                   	pop    %rbp
  804160aef3:	c3                   	retq   
  return cons_getc();
  804160aef4:	48 b8 00 0c 60 41 80 	movabs $0x8041600c00,%rax
  804160aefb:	00 00 00 
  804160aefe:	ff d0                	callq  *%rax
    return sys_cgetc();
  804160af00:	48 98                	cltq   
  804160af02:	eb e1                	jmp    804160aee5 <syscall+0x112>
    return sys_getenvid();
  804160af04:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160af0b:	00 00 00 
  804160af0e:	48 63 80 c8 00 00 00 	movslq 0xc8(%rax),%rax
  804160af15:	eb ce                	jmp    804160aee5 <syscall+0x112>
	if ((r = envid2env(envid, &e, 1)) < 0)
  804160af17:	ba 01 00 00 00       	mov    $0x1,%edx
  804160af1c:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160af20:	44 89 ef             	mov    %r13d,%edi
  804160af23:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160af2a:	00 00 00 
  804160af2d:	ff d0                	callq  *%rax
  804160af2f:	85 c0                	test   %eax,%eax
  804160af31:	78 4f                	js     804160af82 <syscall+0x1af>
	if (e == curenv)
  804160af33:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  804160af37:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160af3e:	00 00 00 
  804160af41:	48 39 c2             	cmp    %rax,%rdx
  804160af44:	74 43                	je     804160af89 <syscall+0x1b6>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
  804160af46:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  804160af4c:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160af52:	48 bf e1 eb 60 41 80 	movabs $0x804160ebe1,%rdi
  804160af59:	00 00 00 
  804160af5c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160af61:	48 b9 0d 92 60 41 80 	movabs $0x804160920d,%rcx
  804160af68:	00 00 00 
  804160af6b:	ff d1                	callq  *%rcx
	env_destroy(e);
  804160af6d:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160af71:	48 b8 d2 8d 60 41 80 	movabs $0x8041608dd2,%rax
  804160af78:	00 00 00 
  804160af7b:	ff d0                	callq  *%rax
	return 0;
  804160af7d:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_env_destroy((envid_t) a1);
  804160af82:	48 98                	cltq   
  804160af84:	e9 5c ff ff ff       	jmpq   804160aee5 <syscall+0x112>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
  804160af89:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160af8f:	48 bf c6 eb 60 41 80 	movabs $0x804160ebc6,%rdi
  804160af96:	00 00 00 
  804160af99:	b8 00 00 00 00       	mov    $0x0,%eax
  804160af9e:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160afa5:	00 00 00 
  804160afa8:	ff d2                	callq  *%rdx
  804160afaa:	eb c1                	jmp    804160af6d <syscall+0x19a>
  struct Env *e = NULL;
  804160afac:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160afb3:	00 
  if ((res = env_alloc(&e, curenv->env_id)) < 0) {
  804160afb4:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160afbb:	00 00 00 
  804160afbe:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160afc4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160afc8:	48 b8 ae 86 60 41 80 	movabs $0x80416086ae,%rax
  804160afcf:	00 00 00 
  804160afd2:	ff d0                	callq  *%rax
  804160afd4:	85 c0                	test   %eax,%eax
  804160afd6:	0f 88 c0 00 00 00    	js     804160b09c <syscall+0x2c9>
  e->env_status = ENV_NOT_RUNNABLE;
  804160afdc:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160afe0:	c7 80 d4 00 00 00 04 	movl   $0x4,0xd4(%rax)
  804160afe7:	00 00 00 
  e->env_tf = curenv->env_tf;
  804160afea:	48 b9 20 45 88 41 80 	movabs $0x8041884520,%rcx
  804160aff1:	00 00 00 
  804160aff4:	48 8b 11             	mov    (%rcx),%rdx
  804160aff7:	f3 0f 6f 02          	movdqu (%rdx),%xmm0
  804160affb:	0f 11 00             	movups %xmm0,(%rax)
  804160affe:	f3 0f 6f 4a 10       	movdqu 0x10(%rdx),%xmm1
  804160b003:	0f 11 48 10          	movups %xmm1,0x10(%rax)
  804160b007:	f3 0f 6f 52 20       	movdqu 0x20(%rdx),%xmm2
  804160b00c:	0f 11 50 20          	movups %xmm2,0x20(%rax)
  804160b010:	f3 0f 6f 5a 30       	movdqu 0x30(%rdx),%xmm3
  804160b015:	0f 11 58 30          	movups %xmm3,0x30(%rax)
  804160b019:	f3 0f 6f 62 40       	movdqu 0x40(%rdx),%xmm4
  804160b01e:	0f 11 60 40          	movups %xmm4,0x40(%rax)
  804160b022:	f3 0f 6f 6a 50       	movdqu 0x50(%rdx),%xmm5
  804160b027:	0f 11 68 50          	movups %xmm5,0x50(%rax)
  804160b02b:	f3 0f 6f 72 60       	movdqu 0x60(%rdx),%xmm6
  804160b030:	0f 11 70 60          	movups %xmm6,0x60(%rax)
  804160b034:	f3 0f 6f 7a 70       	movdqu 0x70(%rdx),%xmm7
  804160b039:	0f 11 78 70          	movups %xmm7,0x70(%rax)
  804160b03d:	f3 0f 6f 82 80 00 00 	movdqu 0x80(%rdx),%xmm0
  804160b044:	00 
  804160b045:	0f 11 80 80 00 00 00 	movups %xmm0,0x80(%rax)
  804160b04c:	f3 0f 6f 8a 90 00 00 	movdqu 0x90(%rdx),%xmm1
  804160b053:	00 
  804160b054:	0f 11 88 90 00 00 00 	movups %xmm1,0x90(%rax)
  804160b05b:	f3 0f 6f 92 a0 00 00 	movdqu 0xa0(%rdx),%xmm2
  804160b062:	00 
  804160b063:	0f 11 90 a0 00 00 00 	movups %xmm2,0xa0(%rax)
  804160b06a:	f3 0f 6f 9a b0 00 00 	movdqu 0xb0(%rdx),%xmm3
  804160b071:	00 
  804160b072:	0f 11 98 b0 00 00 00 	movups %xmm3,0xb0(%rax)
  e->env_pgfault_upcall = curenv->env_pgfault_upcall;
  804160b079:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b07d:	48 8b 11             	mov    (%rcx),%rdx
  804160b080:	48 8b 92 f8 00 00 00 	mov    0xf8(%rdx),%rdx
  804160b087:	48 89 90 f8 00 00 00 	mov    %rdx,0xf8(%rax)
	e->env_tf.tf_regs.reg_rax = 0;
  804160b08e:	48 c7 40 70 00 00 00 	movq   $0x0,0x70(%rax)
  804160b095:	00 
	return e->env_id; 
  804160b096:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
    return sys_exofork();
  804160b09c:	48 98                	cltq   
  804160b09e:	e9 42 fe ff ff       	jmpq   804160aee5 <syscall+0x112>
  if (envid2env(envid, &e, 1) < 0) {
  804160b0a3:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b0a8:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b0ac:	44 89 ef             	mov    %r13d,%edi
  804160b0af:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160b0b6:	00 00 00 
  804160b0b9:	ff d0                	callq  *%rax
  804160b0bb:	85 c0                	test   %eax,%eax
  804160b0bd:	78 23                	js     804160b0e2 <syscall+0x30f>
  if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE)) {
  804160b0bf:	41 8d 44 24 fe       	lea    -0x2(%r12),%eax
  804160b0c4:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
  804160b0c9:	75 1e                	jne    804160b0e9 <syscall+0x316>
  e->env_status = status;
  804160b0cb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b0cf:	44 89 a0 d4 00 00 00 	mov    %r12d,0xd4(%rax)
  return 0;
  804160b0d6:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_env_set_status((envid_t) a1, (int) a2);
  804160b0db:	48 98                	cltq   
  804160b0dd:	e9 03 fe ff ff       	jmpq   804160aee5 <syscall+0x112>
      return -E_BAD_ENV;
  804160b0e2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b0e7:	eb f2                	jmp    804160b0db <syscall+0x308>
      return -E_INVAL;
  804160b0e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b0ee:	eb eb                	jmp    804160b0db <syscall+0x308>
	if (envid2env(envid, &e, 1) < 0) {
  804160b0f0:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b0f5:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b0f9:	44 89 ef             	mov    %r13d,%edi
  804160b0fc:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160b103:	00 00 00 
  804160b106:	ff d0                	callq  *%rax
  804160b108:	85 c0                	test   %eax,%eax
  804160b10a:	0f 88 81 00 00 00    	js     804160b191 <syscall+0x3be>
  if ((uintptr_t) va >= UTOP || PGOFF(va)) {
  804160b110:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160b117:	00 00 00 
  804160b11a:	49 39 c4             	cmp    %rax,%r12
  804160b11d:	77 79                	ja     804160b198 <syscall+0x3c5>
  804160b11f:	41 f7 c4 ff 0f 00 00 	test   $0xfff,%r12d
  804160b126:	75 77                	jne    804160b19f <syscall+0x3cc>
  if (perm & ~PTE_SYSCALL) {
  804160b128:	44 89 f3             	mov    %r14d,%ebx
  804160b12b:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
  804160b131:	75 73                	jne    804160b1a6 <syscall+0x3d3>
  if (!(pp = page_alloc(ALLOC_ZERO))) {
  804160b133:	bf 01 00 00 00       	mov    $0x1,%edi
  804160b138:	48 b8 19 4a 60 41 80 	movabs $0x8041604a19,%rax
  804160b13f:	00 00 00 
  804160b142:	ff d0                	callq  *%rax
  804160b144:	49 89 c5             	mov    %rax,%r13
  804160b147:	48 85 c0             	test   %rax,%rax
  804160b14a:	74 61                	je     804160b1ad <syscall+0x3da>
  if (page_insert(e->env_pml4e, pp, va, perm | PTE_U) < 0) {
  804160b14c:	44 89 f1             	mov    %r14d,%ecx
  804160b14f:	83 c9 04             	or     $0x4,%ecx
  804160b152:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b156:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b15d:	4c 89 e2             	mov    %r12,%rdx
  804160b160:	4c 89 ee             	mov    %r13,%rsi
  804160b163:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  804160b16a:	00 00 00 
  804160b16d:	ff d0                	callq  *%rax
  804160b16f:	85 c0                	test   %eax,%eax
  804160b171:	78 08                	js     804160b17b <syscall+0x3a8>
    return sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
  804160b173:	48 63 c3             	movslq %ebx,%rax
  804160b176:	e9 6a fd ff ff       	jmpq   804160aee5 <syscall+0x112>
    page_free(pp);
  804160b17b:	4c 89 ef             	mov    %r13,%rdi
  804160b17e:	48 b8 12 4b 60 41 80 	movabs $0x8041604b12,%rax
  804160b185:	00 00 00 
  804160b188:	ff d0                	callq  *%rax
    return -E_NO_MEM;
  804160b18a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  804160b18f:	eb e2                	jmp    804160b173 <syscall+0x3a0>
		return -E_BAD_ENV;
  804160b191:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
  804160b196:	eb db                	jmp    804160b173 <syscall+0x3a0>
    return -E_INVAL;
  804160b198:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  804160b19d:	eb d4                	jmp    804160b173 <syscall+0x3a0>
  804160b19f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  804160b1a4:	eb cd                	jmp    804160b173 <syscall+0x3a0>
    return -E_INVAL;
  804160b1a6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
  804160b1ab:	eb c6                	jmp    804160b173 <syscall+0x3a0>
    return -E_NO_MEM;
  804160b1ad:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  804160b1b2:	eb bf                	jmp    804160b173 <syscall+0x3a0>
  if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0) {
  804160b1b4:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b1b9:	48 8d 75 b8          	lea    -0x48(%rbp),%rsi
  804160b1bd:	44 89 ef             	mov    %r13d,%edi
  804160b1c0:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160b1c7:	00 00 00 
  804160b1ca:	ff d0                	callq  *%rax
  804160b1cc:	85 c0                	test   %eax,%eax
  804160b1ce:	0f 88 c3 00 00 00    	js     804160b297 <syscall+0x4c4>
  804160b1d4:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b1d9:	48 8d 75 c0          	lea    -0x40(%rbp),%rsi
  804160b1dd:	44 89 f7             	mov    %r14d,%edi
  804160b1e0:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160b1e7:	00 00 00 
  804160b1ea:	ff d0                	callq  *%rax
  804160b1ec:	85 c0                	test   %eax,%eax
  804160b1ee:	0f 88 aa 00 00 00    	js     804160b29e <syscall+0x4cb>
  if ((uintptr_t) srcva >= UTOP || PGOFF(srcva) || 
  804160b1f4:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160b1fb:	00 00 00 
  804160b1fe:	49 39 c4             	cmp    %rax,%r12
  804160b201:	0f 87 9e 00 00 00    	ja     804160b2a5 <syscall+0x4d2>
  804160b207:	49 39 c7             	cmp    %rax,%r15
  804160b20a:	0f 87 9c 00 00 00    	ja     804160b2ac <syscall+0x4d9>
      (uintptr_t) dstva >= UTOP || PGOFF(dstva)) {
  804160b210:	4c 89 e0             	mov    %r12,%rax
  804160b213:	4c 09 f8             	or     %r15,%rax
  804160b216:	a9 ff 0f 00 00       	test   $0xfff,%eax
  804160b21b:	0f 85 92 00 00 00    	jne    804160b2b3 <syscall+0x4e0>
  if (perm & ~PTE_SYSCALL) {
  804160b221:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  804160b225:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
  804160b22b:	0f 85 89 00 00 00    	jne    804160b2ba <syscall+0x4e7>
  if (!(pp = page_lookup(srcenv->env_pml4e, srcva, &ptep))) { 
  804160b231:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  804160b235:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b23c:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160b240:	4c 89 e6             	mov    %r12,%rsi
  804160b243:	48 b8 05 50 60 41 80 	movabs $0x8041605005,%rax
  804160b24a:	00 00 00 
  804160b24d:	ff d0                	callq  *%rax
  804160b24f:	48 85 c0             	test   %rax,%rax
  804160b252:	74 6d                	je     804160b2c1 <syscall+0x4ee>
	if (!(*ptep & PTE_W) && (perm & PTE_W)) {
  804160b254:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  804160b258:	f6 02 02             	testb  $0x2,(%rdx)
  804160b25b:	75 05                	jne    804160b262 <syscall+0x48f>
  804160b25d:	f6 c3 02             	test   $0x2,%bl
  804160b260:	75 66                	jne    804160b2c8 <syscall+0x4f5>
	if (page_insert(dstenv->env_pml4e, pp, dstva, perm | PTE_U)) {
  804160b262:	8b 4d a8             	mov    -0x58(%rbp),%ecx
  804160b265:	83 c9 04             	or     $0x4,%ecx
  804160b268:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b26c:	48 8b ba e8 00 00 00 	mov    0xe8(%rdx),%rdi
  804160b273:	4c 89 fa             	mov    %r15,%rdx
  804160b276:	48 89 c6             	mov    %rax,%rsi
  804160b279:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  804160b280:	00 00 00 
  804160b283:	ff d0                	callq  *%rax
  804160b285:	85 c0                	test   %eax,%eax
  804160b287:	75 07                	jne    804160b290 <syscall+0x4bd>
    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
  804160b289:	48 98                	cltq   
  804160b28b:	e9 55 fc ff ff       	jmpq   804160aee5 <syscall+0x112>
		return -E_NO_MEM;
  804160b290:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  804160b295:	eb f2                	jmp    804160b289 <syscall+0x4b6>
    return -E_BAD_ENV;
  804160b297:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b29c:	eb eb                	jmp    804160b289 <syscall+0x4b6>
  804160b29e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b2a3:	eb e4                	jmp    804160b289 <syscall+0x4b6>
    return -E_INVAL;
  804160b2a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2aa:	eb dd                	jmp    804160b289 <syscall+0x4b6>
  804160b2ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2b1:	eb d6                	jmp    804160b289 <syscall+0x4b6>
  804160b2b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2b8:	eb cf                	jmp    804160b289 <syscall+0x4b6>
    return -E_INVAL;
  804160b2ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2bf:	eb c8                	jmp    804160b289 <syscall+0x4b6>
    return -E_INVAL;
  804160b2c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2c6:	eb c1                	jmp    804160b289 <syscall+0x4b6>
	  return -E_INVAL;
  804160b2c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b2cd:	eb ba                	jmp    804160b289 <syscall+0x4b6>
  if (envid2env(envid, &e, 1) < 0) {
  804160b2cf:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b2d4:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b2d8:	44 89 ef             	mov    %r13d,%edi
  804160b2db:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160b2e2:	00 00 00 
  804160b2e5:	ff d0                	callq  *%rax
  804160b2e7:	85 c0                	test   %eax,%eax
  804160b2e9:	78 3e                	js     804160b329 <syscall+0x556>
	if ((uintptr_t)va >= UTOP || PGOFF(va)) {
  804160b2eb:	48 b8 ff ff ff ff 7f 	movabs $0x7fffffffff,%rax
  804160b2f2:	00 00 00 
  804160b2f5:	49 39 c4             	cmp    %rax,%r12
  804160b2f8:	77 36                	ja     804160b330 <syscall+0x55d>
  804160b2fa:	41 f7 c4 ff 0f 00 00 	test   $0xfff,%r12d
  804160b301:	75 34                	jne    804160b337 <syscall+0x564>
	page_remove(e->env_pml4e, va);
  804160b303:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b307:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b30e:	4c 89 e6             	mov    %r12,%rsi
  804160b311:	48 b8 cb 50 60 41 80 	movabs $0x80416050cb,%rax
  804160b318:	00 00 00 
  804160b31b:	ff d0                	callq  *%rax
	return 0;
  804160b31d:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_page_unmap((envid_t) a1, (void *) a2);
  804160b322:	48 98                	cltq   
  804160b324:	e9 bc fb ff ff       	jmpq   804160aee5 <syscall+0x112>
    return -E_BAD_ENV;
  804160b329:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b32e:	eb f2                	jmp    804160b322 <syscall+0x54f>
    return -E_INVAL;
  804160b330:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b335:	eb eb                	jmp    804160b322 <syscall+0x54f>
  804160b337:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b33c:	eb e4                	jmp    804160b322 <syscall+0x54f>
  if (envid2env(envid, &e, 1) < 0) {
  804160b33e:	ba 01 00 00 00       	mov    $0x1,%edx
  804160b343:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160b347:	44 89 ef             	mov    %r13d,%edi
  804160b34a:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160b351:	00 00 00 
  804160b354:	ff d0                	callq  *%rax
  804160b356:	85 c0                	test   %eax,%eax
  804160b358:	78 17                	js     804160b371 <syscall+0x59e>
  e->env_pgfault_upcall = func;
  804160b35a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b35e:	4c 89 a0 f8 00 00 00 	mov    %r12,0xf8(%rax)
  return 0;
  804160b365:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
  804160b36a:	48 98                	cltq   
  804160b36c:	e9 74 fb ff ff       	jmpq   804160aee5 <syscall+0x112>
    return -E_BAD_ENV;
  804160b371:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b376:	eb f2                	jmp    804160b36a <syscall+0x597>
  sched_yield();
  804160b378:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  804160b37f:	00 00 00 
  804160b382:	ff d0                	callq  *%rax
	if (envid2env(envid, &e, 0) < 0) {
  804160b384:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b389:	48 8d 75 c0          	lea    -0x40(%rbp),%rsi
  804160b38d:	44 89 ef             	mov    %r13d,%edi
  804160b390:	48 b8 7c 85 60 41 80 	movabs $0x804160857c,%rax
  804160b397:	00 00 00 
  804160b39a:	ff d0                	callq  *%rax
  804160b39c:	85 c0                	test   %eax,%eax
  804160b39e:	0f 88 f8 00 00 00    	js     804160b49c <syscall+0x6c9>
	if (!e->env_ipc_recving) {
  804160b3a4:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160b3a8:	80 b8 00 01 00 00 00 	cmpb   $0x0,0x100(%rax)
  804160b3af:	0f 84 ee 00 00 00    	je     804160b4a3 <syscall+0x6d0>
	if ((uintptr_t) srcva < UTOP) {
  804160b3b5:	48 ba ff ff ff ff 7f 	movabs $0x7fffffffff,%rdx
  804160b3bc:	00 00 00 
  804160b3bf:	49 39 d6             	cmp    %rdx,%r14
  804160b3c2:	0f 87 89 00 00 00    	ja     804160b451 <syscall+0x67e>
		if (PGOFF(srcva)) {
  804160b3c8:	41 f7 c6 ff 0f 00 00 	test   $0xfff,%r14d
  804160b3cf:	0f 85 d5 00 00 00    	jne    804160b4aa <syscall+0x6d7>
		if ((perm & ~(PTE_U | PTE_P)) || (perm & ~PTE_SYSCALL)) {
  804160b3d5:	41 f7 c7 fa ff ff ff 	test   $0xfffffffa,%r15d
  804160b3dc:	0f 85 cf 00 00 00    	jne    804160b4b1 <syscall+0x6de>
		if (!(p = page_lookup(curenv->env_pml4e, srcva, &ptep))) {
  804160b3e2:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160b3e9:	00 00 00 
  804160b3ec:	48 8b b8 e8 00 00 00 	mov    0xe8(%rax),%rdi
  804160b3f3:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160b3f7:	4c 89 f6             	mov    %r14,%rsi
  804160b3fa:	48 b8 05 50 60 41 80 	movabs $0x8041605005,%rax
  804160b401:	00 00 00 
  804160b404:	ff d0                	callq  *%rax
  804160b406:	48 85 c0             	test   %rax,%rax
  804160b409:	0f 84 a9 00 00 00    	je     804160b4b8 <syscall+0x6e5>
		if (!(*ptep & PTE_W) && (perm & PTE_W)) {
  804160b40f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  804160b413:	f6 02 02             	testb  $0x2,(%rdx)
  804160b416:	75 0a                	jne    804160b422 <syscall+0x64f>
  804160b418:	41 f6 c7 02          	test   $0x2,%r15b
  804160b41c:	0f 85 9d 00 00 00    	jne    804160b4bf <syscall+0x6ec>
		if (page_insert(e->env_pml4e, p, e->env_ipc_dstva, perm)) {
  804160b422:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  804160b426:	48 8b 91 08 01 00 00 	mov    0x108(%rcx),%rdx
  804160b42d:	48 8b b9 e8 00 00 00 	mov    0xe8(%rcx),%rdi
  804160b434:	44 89 f9             	mov    %r15d,%ecx
  804160b437:	48 89 c6             	mov    %rax,%rsi
  804160b43a:	48 b8 26 51 60 41 80 	movabs $0x8041605126,%rax
  804160b441:	00 00 00 
  804160b444:	ff d0                	callq  *%rax
  804160b446:	85 c0                	test   %eax,%eax
  804160b448:	74 11                	je     804160b45b <syscall+0x688>
			return -E_NO_MEM;
  804160b44a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  804160b44f:	eb 44                	jmp    804160b495 <syscall+0x6c2>
		e->env_ipc_perm = 0;
  804160b451:	c7 80 18 01 00 00 00 	movl   $0x0,0x118(%rax)
  804160b458:	00 00 00 
	e->env_ipc_recving = 0;
  804160b45b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160b45f:	c6 80 00 01 00 00 00 	movb   $0x0,0x100(%rax)
	e->env_ipc_from = curenv->env_id;
  804160b466:	48 b9 20 45 88 41 80 	movabs $0x8041884520,%rcx
  804160b46d:	00 00 00 
  804160b470:	48 8b 11             	mov    (%rcx),%rdx
  804160b473:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  804160b479:	89 90 14 01 00 00    	mov    %edx,0x114(%rax)
	e->env_ipc_value = value;
  804160b47f:	44 89 a0 10 01 00 00 	mov    %r12d,0x110(%rax)
	e->env_status = ENV_RUNNABLE;
  804160b486:	c7 80 d4 00 00 00 02 	movl   $0x2,0xd4(%rax)
  804160b48d:	00 00 00 
	return 0;
  804160b490:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *) a3, (unsigned) a4);
  804160b495:	48 98                	cltq   
  804160b497:	e9 49 fa ff ff       	jmpq   804160aee5 <syscall+0x112>
		return -E_BAD_ENV;
  804160b49c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160b4a1:	eb f2                	jmp    804160b495 <syscall+0x6c2>
		return -E_IPC_NOT_RECV;
  804160b4a3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  804160b4a8:	eb eb                	jmp    804160b495 <syscall+0x6c2>
			return -E_INVAL;
  804160b4aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b4af:	eb e4                	jmp    804160b495 <syscall+0x6c2>
			return -E_INVAL;
  804160b4b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b4b6:	eb dd                	jmp    804160b495 <syscall+0x6c2>
			return -E_INVAL;
  804160b4b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b4bd:	eb d6                	jmp    804160b495 <syscall+0x6c2>
			return -E_INVAL;
  804160b4bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b4c4:	eb cf                	jmp    804160b495 <syscall+0x6c2>
	curenv->env_ipc_recving = 1;
  804160b4c6:	48 a1 20 45 88 41 80 	movabs 0x8041884520,%rax
  804160b4cd:	00 00 00 
  804160b4d0:	c6 80 00 01 00 00 01 	movb   $0x1,0x100(%rax)
	curenv->env_ipc_dstva = dstva;
  804160b4d7:	4c 89 a8 08 01 00 00 	mov    %r13,0x108(%rax)
	curenv->env_status = ENV_NOT_RUNNABLE;
  804160b4de:	c7 80 d4 00 00 00 04 	movl   $0x4,0xd4(%rax)
  804160b4e5:	00 00 00 
  curenv->env_tf.tf_regs.reg_rax = 0;
  804160b4e8:	48 c7 40 70 00 00 00 	movq   $0x0,0x70(%rax)
  804160b4ef:	00 
	sched_yield();
  804160b4f0:	48 b8 4c ad 60 41 80 	movabs $0x804160ad4c,%rax
  804160b4f7:	00 00 00 
  804160b4fa:	ff d0                	callq  *%rax

000000804160b4fc <load_kernel_dwarf_info>:
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  804160b4fc:	48 ba 00 00 62 41 80 	movabs $0x8041620000,%rdx
  804160b503:	00 00 00 
  804160b506:	48 8b 02             	mov    (%rdx),%rax
  804160b509:	48 8b 48 58          	mov    0x58(%rax),%rcx
  804160b50d:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  804160b511:	48 8b 48 60          	mov    0x60(%rax),%rcx
  804160b515:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  804160b519:	48 8b 40 68          	mov    0x68(%rax),%rax
  804160b51d:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  804160b520:	48 8b 02             	mov    (%rdx),%rax
  804160b523:	48 8b 50 70          	mov    0x70(%rax),%rdx
  804160b527:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  804160b52b:	48 8b 50 78          	mov    0x78(%rax),%rdx
  804160b52f:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  804160b533:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  804160b53a:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  804160b53e:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  804160b545:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  804160b549:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  804160b550:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  804160b554:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  804160b55b:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  804160b55f:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  804160b566:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  804160b56a:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  804160b571:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  804160b575:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  804160b57c:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  804160b580:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  804160b587:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  804160b58b:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  804160b592:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  804160b596:	c3                   	retq   

000000804160b597 <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  804160b597:	55                   	push   %rbp
  804160b598:	48 89 e5             	mov    %rsp,%rbp
  804160b59b:	41 57                	push   %r15
  804160b59d:	41 56                	push   %r14
  804160b59f:	41 55                	push   %r13
  804160b5a1:	41 54                	push   %r12
  804160b5a3:	53                   	push   %rbx
  804160b5a4:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  804160b5ab:	49 89 fc             	mov    %rdi,%r12
  804160b5ae:	48 89 f3             	mov    %rsi,%rbx
  // const struct Stab *stabs, *stab_end;
	// const char *stabstr, *stabstr_end;
  // LAB 8 code end

  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  804160b5b1:	48 be f9 eb 60 41 80 	movabs $0x804160ebf9,%rsi
  804160b5b8:	00 00 00 
  804160b5bb:	48 89 df             	mov    %rbx,%rdi
  804160b5be:	49 bd 42 c3 60 41 80 	movabs $0x804160c342,%r13
  804160b5c5:	00 00 00 
  804160b5c8:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  804160b5cb:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  804160b5d2:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  804160b5d5:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  804160b5dc:	48 be f9 eb 60 41 80 	movabs $0x804160ebf9,%rsi
  804160b5e3:	00 00 00 
  804160b5e6:	4c 89 f7             	mov    %r14,%rdi
  804160b5e9:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  804160b5ec:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  804160b5f3:	00 00 00 
  info->rip_fn_addr    = addr;
  804160b5f6:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  804160b5fd:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  804160b604:	00 00 00 

  if (!addr) {
  804160b607:	4d 85 e4             	test   %r12,%r12
  804160b60a:	0f 84 13 02 00 00    	je     804160b823 <debuginfo_rip+0x28c>
  __asm __volatile("movq %%cr3,%0"
  804160b610:	41 0f 20 df          	mov    %cr3,%r15
  // LAB 8: Your code here.

  struct Dwarf_Addrs addrs;
  // LAB 8 code
  uint64_t tmp_cr3 = rcr3();
  lcr3(PADDR(kern_pml4e));
  804160b614:	48 a1 40 5a 88 41 80 	movabs 0x8041885a40,%rax
  804160b61b:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  804160b61e:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160b625:	00 00 00 
  804160b628:	48 39 d0             	cmp    %rdx,%rax
  804160b62b:	0f 86 82 01 00 00    	jbe    804160b7b3 <debuginfo_rip+0x21c>
  return (physaddr_t)kva - KERNBASE;
  804160b631:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  804160b638:	ff ff ff 
  804160b63b:	48 01 c8             	add    %rcx,%rax
  __asm __volatile("movq %0,%%cr3"
  804160b63e:	0f 22 d8             	mov    %rax,%cr3
  // LAB 8 code end
  if (addr <= ULIM) {
  804160b641:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  804160b648:	00 00 00 
  804160b64b:	49 39 c4             	cmp    %rax,%r12
  804160b64e:	0f 86 8d 01 00 00    	jbe    804160b7e1 <debuginfo_rip+0x24a>
    // lcr3(tmp_cr3);
    // LAB 8 code end

    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  804160b654:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b65b:	48 b8 fc b4 60 41 80 	movabs $0x804160b4fc,%rax
  804160b662:	00 00 00 
  804160b665:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  804160b667:	48 c7 85 58 ff ff ff 	movq   $0x0,-0xa8(%rbp)
  804160b66e:	00 00 00 00 
  804160b672:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  804160b679:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  804160b67d:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160b684:	4c 89 e6             	mov    %r12,%rsi
  804160b687:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b68e:	48 b8 c0 16 60 41 80 	movabs $0x80416016c0,%rax
  804160b695:	00 00 00 
  804160b698:	ff d0                	callq  *%rax
  804160b69a:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  804160b69d:	85 c0                	test   %eax,%eax
  804160b69f:	0f 88 66 01 00 00    	js     804160b80b <debuginfo_rip+0x274>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  804160b6a5:	4c 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%r8
  804160b6ac:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160b6b1:	48 8d 95 48 ff ff ff 	lea    -0xb8(%rbp),%rdx
  804160b6b8:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160b6bf:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b6c6:	48 b8 6f 1d 60 41 80 	movabs $0x8041601d6f,%rax
  804160b6cd:	00 00 00 
  804160b6d0:	ff d0                	callq  *%rax
  804160b6d2:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  804160b6d5:	ba 00 01 00 00       	mov    $0x100,%edx
  804160b6da:	48 8b b5 48 ff ff ff 	mov    -0xb8(%rbp),%rsi
  804160b6e1:	48 89 df             	mov    %rbx,%rdi
  804160b6e4:	48 b8 90 c3 60 41 80 	movabs $0x804160c390,%rax
  804160b6eb:	00 00 00 
  804160b6ee:	ff d0                	callq  *%rax
  if (code < 0) {
  804160b6f0:	45 85 ed             	test   %r13d,%r13d
  804160b6f3:	0f 88 18 01 00 00    	js     804160b811 <debuginfo_rip+0x27a>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
    
  int lineno_store;
  addr = addr - 5;
  804160b6f9:	49 83 ec 05          	sub    $0x5,%r12
  code = line_for_address(&addrs, addr, line_offset, &lineno_store);
  804160b6fd:	48 8d 8d 44 ff ff ff 	lea    -0xbc(%rbp),%rcx
  804160b704:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  804160b70b:	4c 89 e6             	mov    %r12,%rsi
  804160b70e:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b715:	48 b8 b9 32 60 41 80 	movabs $0x80416032b9,%rax
  804160b71c:	00 00 00 
  804160b71f:	ff d0                	callq  *%rax
  804160b721:	41 89 c5             	mov    %eax,%r13d
  info->rip_line = lineno_store;
  804160b724:	8b 85 44 ff ff ff    	mov    -0xbc(%rbp),%eax
  804160b72a:	89 83 00 01 00 00    	mov    %eax,0x100(%rbx)
  if (code < 0) {
  804160b730:	45 85 ed             	test   %r13d,%r13d
  804160b733:	0f 88 de 00 00 00    	js     804160b817 <debuginfo_rip+0x280>
  }
    
  //LAB 2 code end

  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  804160b739:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  804160b740:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160b746:	48 8d 8d 48 ff ff ff 	lea    -0xb8(%rbp),%rcx
  804160b74d:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  804160b754:	4c 89 e6             	mov    %r12,%rsi
  804160b757:	48 8d bd 60 ff ff ff 	lea    -0xa0(%rbp),%rdi
  804160b75e:	48 b8 da 21 60 41 80 	movabs $0x80416021da,%rax
  804160b765:	00 00 00 
  804160b768:	ff d0                	callq  *%rax
  804160b76a:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  804160b76d:	ba 00 01 00 00       	mov    $0x100,%edx
  804160b772:	48 8b b5 48 ff ff ff 	mov    -0xb8(%rbp),%rsi
  804160b779:	4c 89 f7             	mov    %r14,%rdi
  804160b77c:	48 b8 90 c3 60 41 80 	movabs $0x804160c390,%rax
  804160b783:	00 00 00 
  804160b786:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  804160b788:	be 00 01 00 00       	mov    $0x100,%esi
  804160b78d:	4c 89 f7             	mov    %r14,%rdi
  804160b790:	48 b8 0d c3 60 41 80 	movabs $0x804160c30d,%rax
  804160b797:	00 00 00 
  804160b79a:	ff d0                	callq  *%rax
  804160b79c:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  804160b7a2:	45 85 ed             	test   %r13d,%r13d
  804160b7a5:	78 76                	js     804160b81d <debuginfo_rip+0x286>
  804160b7a7:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  }
  // LAB 8 code
  lcr3(tmp_cr3);
  // LAB 8 code end
  return 0;
  804160b7ab:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  804160b7b1:	eb 76                	jmp    804160b829 <debuginfo_rip+0x292>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160b7b3:	48 89 c1             	mov    %rax,%rcx
  804160b7b6:	48 ba e0 d6 60 41 80 	movabs $0x804160d6e0,%rdx
  804160b7bd:	00 00 00 
  804160b7c0:	be 42 00 00 00       	mov    $0x42,%esi
  804160b7c5:	48 bf 03 ec 60 41 80 	movabs $0x804160ec03,%rdi
  804160b7cc:	00 00 00 
  804160b7cf:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b7d4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160b7db:	00 00 00 
  804160b7de:	41 ff d0             	callq  *%r8
    panic("Can't search for user-level addresses yet!");
  804160b7e1:	48 ba 18 ec 60 41 80 	movabs $0x804160ec18,%rdx
  804160b7e8:	00 00 00 
  804160b7eb:	be 4d 00 00 00       	mov    $0x4d,%esi
  804160b7f0:	48 bf 03 ec 60 41 80 	movabs $0x804160ec03,%rdi
  804160b7f7:	00 00 00 
  804160b7fa:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b7ff:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160b806:	00 00 00 
  804160b809:	ff d1                	callq  *%rcx
  804160b80b:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b80f:	eb 18                	jmp    804160b829 <debuginfo_rip+0x292>
  804160b811:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b815:	eb 12                	jmp    804160b829 <debuginfo_rip+0x292>
  804160b817:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b81b:	eb 0c                	jmp    804160b829 <debuginfo_rip+0x292>
  804160b81d:	41 0f 22 df          	mov    %r15,%cr3
    return code;
  804160b821:	eb 06                	jmp    804160b829 <debuginfo_rip+0x292>
    return 0;
  804160b823:	41 bd 00 00 00 00    	mov    $0x0,%r13d
}
  804160b829:	44 89 e8             	mov    %r13d,%eax
  804160b82c:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  804160b833:	5b                   	pop    %rbx
  804160b834:	41 5c                	pop    %r12
  804160b836:	41 5d                	pop    %r13
  804160b838:	41 5e                	pop    %r14
  804160b83a:	41 5f                	pop    %r15
  804160b83c:	5d                   	pop    %rbp
  804160b83d:	c3                   	retq   

000000804160b83e <find_function>:

uintptr_t
find_function(const char *const fname) {
  804160b83e:	55                   	push   %rbp
  804160b83f:	48 89 e5             	mov    %rsp,%rbp
  804160b842:	53                   	push   %rbx
  804160b843:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  804160b84a:	48 89 fb             	mov    %rdi,%rbx
  // LAB 6 code
  #endif
  // LAB 6 code end
    
  struct Dwarf_Addrs addrs;
  load_kernel_dwarf_info(&addrs);
  804160b84d:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b851:	48 b8 fc b4 60 41 80 	movabs $0x804160b4fc,%rax
  804160b858:	00 00 00 
  804160b85b:	ff d0                	callq  *%rax
  uintptr_t offset = 0;
  804160b85d:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  804160b864:	00 00 00 00 

  if (!address_by_fname(&addrs, fname, &offset) && offset) {
  804160b868:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160b86f:	48 89 de             	mov    %rbx,%rsi
  804160b872:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b876:	48 b8 66 27 60 41 80 	movabs $0x8041602766,%rax
  804160b87d:	00 00 00 
  804160b880:	ff d0                	callq  *%rax
  804160b882:	85 c0                	test   %eax,%eax
  804160b884:	75 0c                	jne    804160b892 <find_function+0x54>
  804160b886:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160b88d:	48 85 d2             	test   %rdx,%rdx
  804160b890:	75 23                	jne    804160b8b5 <find_function+0x77>
    return offset;
  }

  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160b892:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160b899:	48 89 de             	mov    %rbx,%rsi
  804160b89c:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b8a0:	48 b8 64 2d 60 41 80 	movabs $0x8041602d64,%rax
  804160b8a7:	00 00 00 
  804160b8aa:	ff d0                	callq  *%rax
    return offset;
  }
  // LAB 3 code end

  return 0;
  804160b8ac:	ba 00 00 00 00       	mov    $0x0,%edx
  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160b8b1:	85 c0                	test   %eax,%eax
  804160b8b3:	74 0d                	je     804160b8c2 <find_function+0x84>
}
  804160b8b5:	48 89 d0             	mov    %rdx,%rax
  804160b8b8:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  804160b8bf:	5b                   	pop    %rbx
  804160b8c0:	5d                   	pop    %rbp
  804160b8c1:	c3                   	retq   
    return offset;
  804160b8c2:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160b8c9:	eb ea                	jmp    804160b8b5 <find_function+0x77>

000000804160b8cb <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  804160b8cb:	55                   	push   %rbp
  804160b8cc:	48 89 e5             	mov    %rsp,%rbp
  804160b8cf:	41 57                	push   %r15
  804160b8d1:	41 56                	push   %r14
  804160b8d3:	41 55                	push   %r13
  804160b8d5:	41 54                	push   %r12
  804160b8d7:	53                   	push   %rbx
  804160b8d8:	48 83 ec 18          	sub    $0x18,%rsp
  804160b8dc:	49 89 fc             	mov    %rdi,%r12
  804160b8df:	49 89 f5             	mov    %rsi,%r13
  804160b8e2:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160b8e6:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  804160b8e9:	41 89 cf             	mov    %ecx,%r15d
  804160b8ec:	49 39 d7             	cmp    %rdx,%r15
  804160b8ef:	76 45                	jbe    804160b936 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  804160b8f1:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160b8f5:	85 db                	test   %ebx,%ebx
  804160b8f7:	7e 0e                	jle    804160b907 <printnum+0x3c>
      putch(padc, putdat);
  804160b8f9:	4c 89 ee             	mov    %r13,%rsi
  804160b8fc:	44 89 f7             	mov    %r14d,%edi
  804160b8ff:	41 ff d4             	callq  *%r12
    while (--width > 0)
  804160b902:	83 eb 01             	sub    $0x1,%ebx
  804160b905:	75 f2                	jne    804160b8f9 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  804160b907:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b90b:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b910:	49 f7 f7             	div    %r15
  804160b913:	48 b8 43 ec 60 41 80 	movabs $0x804160ec43,%rax
  804160b91a:	00 00 00 
  804160b91d:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  804160b921:	4c 89 ee             	mov    %r13,%rsi
  804160b924:	41 ff d4             	callq  *%r12
}
  804160b927:	48 83 c4 18          	add    $0x18,%rsp
  804160b92b:	5b                   	pop    %rbx
  804160b92c:	41 5c                	pop    %r12
  804160b92e:	41 5d                	pop    %r13
  804160b930:	41 5e                	pop    %r14
  804160b932:	41 5f                	pop    %r15
  804160b934:	5d                   	pop    %rbp
  804160b935:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  804160b936:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b93a:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b93f:	49 f7 f7             	div    %r15
  804160b942:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  804160b946:	48 89 c2             	mov    %rax,%rdx
  804160b949:	48 b8 cb b8 60 41 80 	movabs $0x804160b8cb,%rax
  804160b950:	00 00 00 
  804160b953:	ff d0                	callq  *%rax
  804160b955:	eb b0                	jmp    804160b907 <printnum+0x3c>

000000804160b957 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  804160b957:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  804160b95b:	48 8b 06             	mov    (%rsi),%rax
  804160b95e:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  804160b962:	73 0a                	jae    804160b96e <sprintputch+0x17>
    *b->buf++ = ch;
  804160b964:	48 8d 50 01          	lea    0x1(%rax),%rdx
  804160b968:	48 89 16             	mov    %rdx,(%rsi)
  804160b96b:	40 88 38             	mov    %dil,(%rax)
}
  804160b96e:	c3                   	retq   

000000804160b96f <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  804160b96f:	55                   	push   %rbp
  804160b970:	48 89 e5             	mov    %rsp,%rbp
  804160b973:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160b97a:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160b981:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160b988:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160b98f:	84 c0                	test   %al,%al
  804160b991:	74 20                	je     804160b9b3 <printfmt+0x44>
  804160b993:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160b997:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160b99b:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160b99f:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160b9a3:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160b9a7:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160b9ab:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160b9af:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  804160b9b3:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160b9ba:	00 00 00 
  804160b9bd:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160b9c4:	00 00 00 
  804160b9c7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160b9cb:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160b9d2:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160b9d9:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  804160b9e0:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160b9e7:	48 b8 f5 b9 60 41 80 	movabs $0x804160b9f5,%rax
  804160b9ee:	00 00 00 
  804160b9f1:	ff d0                	callq  *%rax
}
  804160b9f3:	c9                   	leaveq 
  804160b9f4:	c3                   	retq   

000000804160b9f5 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  804160b9f5:	55                   	push   %rbp
  804160b9f6:	48 89 e5             	mov    %rsp,%rbp
  804160b9f9:	41 57                	push   %r15
  804160b9fb:	41 56                	push   %r14
  804160b9fd:	41 55                	push   %r13
  804160b9ff:	41 54                	push   %r12
  804160ba01:	53                   	push   %rbx
  804160ba02:	48 83 ec 48          	sub    $0x48,%rsp
  804160ba06:	49 89 fd             	mov    %rdi,%r13
  804160ba09:	49 89 f7             	mov    %rsi,%r15
  804160ba0c:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  804160ba0f:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  804160ba13:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  804160ba17:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160ba1b:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160ba1f:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  804160ba23:	41 0f b6 3e          	movzbl (%r14),%edi
  804160ba27:	83 ff 25             	cmp    $0x25,%edi
  804160ba2a:	74 18                	je     804160ba44 <vprintfmt+0x4f>
      if (ch == '\0')
  804160ba2c:	85 ff                	test   %edi,%edi
  804160ba2e:	0f 84 8c 06 00 00    	je     804160c0c0 <vprintfmt+0x6cb>
      putch(ch, putdat);
  804160ba34:	4c 89 fe             	mov    %r15,%rsi
  804160ba37:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160ba3a:	49 89 de             	mov    %rbx,%r14
  804160ba3d:	eb e0                	jmp    804160ba1f <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160ba3f:	49 89 de             	mov    %rbx,%r14
  804160ba42:	eb db                	jmp    804160ba1f <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  804160ba44:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  804160ba48:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  804160ba4c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  804160ba53:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  804160ba59:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  804160ba5d:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  804160ba62:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160ba68:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  804160ba6e:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  804160ba73:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  804160ba78:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  804160ba7c:	0f b6 13             	movzbl (%rbx),%edx
  804160ba7f:	8d 42 dd             	lea    -0x23(%rdx),%eax
  804160ba82:	3c 55                	cmp    $0x55,%al
  804160ba84:	0f 87 8b 05 00 00    	ja     804160c015 <vprintfmt+0x620>
  804160ba8a:	0f b6 c0             	movzbl %al,%eax
  804160ba8d:	49 bb 20 ed 60 41 80 	movabs $0x804160ed20,%r11
  804160ba94:	00 00 00 
  804160ba97:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  804160ba9b:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  804160ba9e:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  804160baa2:	eb d4                	jmp    804160ba78 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160baa4:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  804160baa7:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  804160baab:	eb cb                	jmp    804160ba78 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160baad:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  804160bab0:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  804160bab4:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  804160bab8:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160babb:	83 fa 09             	cmp    $0x9,%edx
  804160babe:	77 7e                	ja     804160bb3e <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  804160bac0:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  804160bac4:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  804160bac8:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  804160bacd:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  804160bad1:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160bad4:	83 fa 09             	cmp    $0x9,%edx
  804160bad7:	76 e7                	jbe    804160bac0 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  804160bad9:	4c 89 f3             	mov    %r14,%rbx
  804160badc:	eb 19                	jmp    804160baf7 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  804160bade:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bae1:	83 f8 2f             	cmp    $0x2f,%eax
  804160bae4:	77 2a                	ja     804160bb10 <vprintfmt+0x11b>
  804160bae6:	89 c2                	mov    %eax,%edx
  804160bae8:	4c 01 d2             	add    %r10,%rdx
  804160baeb:	83 c0 08             	add    $0x8,%eax
  804160baee:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160baf1:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  804160baf4:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  804160baf7:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160bafb:	0f 89 77 ff ff ff    	jns    804160ba78 <vprintfmt+0x83>
          width = precision, precision = -1;
  804160bb01:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160bb05:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  804160bb0b:	e9 68 ff ff ff       	jmpq   804160ba78 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  804160bb10:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bb14:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bb18:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bb1c:	eb d3                	jmp    804160baf1 <vprintfmt+0xfc>
        if (width < 0)
  804160bb1e:	8b 45 ac             	mov    -0x54(%rbp),%eax
  804160bb21:	85 c0                	test   %eax,%eax
  804160bb23:	41 0f 48 c0          	cmovs  %r8d,%eax
  804160bb27:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  804160bb2a:	4c 89 f3             	mov    %r14,%rbx
  804160bb2d:	e9 46 ff ff ff       	jmpq   804160ba78 <vprintfmt+0x83>
  804160bb32:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  804160bb35:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  804160bb39:	e9 3a ff ff ff       	jmpq   804160ba78 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160bb3e:	4c 89 f3             	mov    %r14,%rbx
  804160bb41:	eb b4                	jmp    804160baf7 <vprintfmt+0x102>
        lflag++;
  804160bb43:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  804160bb46:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  804160bb49:	e9 2a ff ff ff       	jmpq   804160ba78 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  804160bb4e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bb51:	83 f8 2f             	cmp    $0x2f,%eax
  804160bb54:	77 19                	ja     804160bb6f <vprintfmt+0x17a>
  804160bb56:	89 c2                	mov    %eax,%edx
  804160bb58:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bb5c:	83 c0 08             	add    $0x8,%eax
  804160bb5f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bb62:	4c 89 fe             	mov    %r15,%rsi
  804160bb65:	8b 3a                	mov    (%rdx),%edi
  804160bb67:	41 ff d5             	callq  *%r13
        break;
  804160bb6a:	e9 b0 fe ff ff       	jmpq   804160ba1f <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  804160bb6f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bb73:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bb77:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bb7b:	eb e5                	jmp    804160bb62 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  804160bb7d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bb80:	83 f8 2f             	cmp    $0x2f,%eax
  804160bb83:	77 5b                	ja     804160bbe0 <vprintfmt+0x1eb>
  804160bb85:	89 c2                	mov    %eax,%edx
  804160bb87:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bb8b:	83 c0 08             	add    $0x8,%eax
  804160bb8e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bb91:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  804160bb93:	89 c8                	mov    %ecx,%eax
  804160bb95:	c1 f8 1f             	sar    $0x1f,%eax
  804160bb98:	31 c1                	xor    %eax,%ecx
  804160bb9a:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  804160bb9c:	83 f9 0b             	cmp    $0xb,%ecx
  804160bb9f:	7f 4d                	jg     804160bbee <vprintfmt+0x1f9>
  804160bba1:	48 63 c1             	movslq %ecx,%rax
  804160bba4:	48 ba e0 ef 60 41 80 	movabs $0x804160efe0,%rdx
  804160bbab:	00 00 00 
  804160bbae:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  804160bbb2:	48 85 c0             	test   %rax,%rax
  804160bbb5:	74 37                	je     804160bbee <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  804160bbb7:	48 89 c1             	mov    %rax,%rcx
  804160bbba:	48 ba eb cf 60 41 80 	movabs $0x804160cfeb,%rdx
  804160bbc1:	00 00 00 
  804160bbc4:	4c 89 fe             	mov    %r15,%rsi
  804160bbc7:	4c 89 ef             	mov    %r13,%rdi
  804160bbca:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bbcf:	48 bb 6f b9 60 41 80 	movabs $0x804160b96f,%rbx
  804160bbd6:	00 00 00 
  804160bbd9:	ff d3                	callq  *%rbx
  804160bbdb:	e9 3f fe ff ff       	jmpq   804160ba1f <vprintfmt+0x2a>
        err = va_arg(aq, int);
  804160bbe0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bbe4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bbe8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bbec:	eb a3                	jmp    804160bb91 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  804160bbee:	48 ba 5b ec 60 41 80 	movabs $0x804160ec5b,%rdx
  804160bbf5:	00 00 00 
  804160bbf8:	4c 89 fe             	mov    %r15,%rsi
  804160bbfb:	4c 89 ef             	mov    %r13,%rdi
  804160bbfe:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bc03:	48 bb 6f b9 60 41 80 	movabs $0x804160b96f,%rbx
  804160bc0a:	00 00 00 
  804160bc0d:	ff d3                	callq  *%rbx
  804160bc0f:	e9 0b fe ff ff       	jmpq   804160ba1f <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  804160bc14:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bc17:	83 f8 2f             	cmp    $0x2f,%eax
  804160bc1a:	77 4b                	ja     804160bc67 <vprintfmt+0x272>
  804160bc1c:	89 c2                	mov    %eax,%edx
  804160bc1e:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bc22:	83 c0 08             	add    $0x8,%eax
  804160bc25:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bc28:	48 8b 02             	mov    (%rdx),%rax
  804160bc2b:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  804160bc2f:	48 85 c0             	test   %rax,%rax
  804160bc32:	0f 84 05 04 00 00    	je     804160c03d <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  804160bc38:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160bc3c:	7e 06                	jle    804160bc44 <vprintfmt+0x24f>
  804160bc3e:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160bc42:	75 31                	jne    804160bc75 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160bc44:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160bc48:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160bc4c:	0f b6 00             	movzbl (%rax),%eax
  804160bc4f:	0f be f8             	movsbl %al,%edi
  804160bc52:	85 ff                	test   %edi,%edi
  804160bc54:	0f 84 c3 00 00 00    	je     804160bd1d <vprintfmt+0x328>
  804160bc5a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160bc5e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160bc62:	e9 85 00 00 00       	jmpq   804160bcec <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  804160bc67:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bc6b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bc6f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bc73:	eb b3                	jmp    804160bc28 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160bc75:	49 63 f4             	movslq %r12d,%rsi
  804160bc78:	48 89 c7             	mov    %rax,%rdi
  804160bc7b:	48 b8 0d c3 60 41 80 	movabs $0x804160c30d,%rax
  804160bc82:	00 00 00 
  804160bc85:	ff d0                	callq  *%rax
  804160bc87:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160bc8a:	8b 75 ac             	mov    -0x54(%rbp),%esi
  804160bc8d:	85 f6                	test   %esi,%esi
  804160bc8f:	7e 22                	jle    804160bcb3 <vprintfmt+0x2be>
            putch(padc, putdat);
  804160bc91:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  804160bc95:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  804160bc99:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  804160bc9d:	4c 89 fe             	mov    %r15,%rsi
  804160bca0:	89 df                	mov    %ebx,%edi
  804160bca2:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  804160bca5:	41 83 ec 01          	sub    $0x1,%r12d
  804160bca9:	75 f2                	jne    804160bc9d <vprintfmt+0x2a8>
  804160bcab:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160bcaf:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160bcb3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160bcb7:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160bcbb:	0f b6 00             	movzbl (%rax),%eax
  804160bcbe:	0f be f8             	movsbl %al,%edi
  804160bcc1:	85 ff                	test   %edi,%edi
  804160bcc3:	0f 84 56 fd ff ff    	je     804160ba1f <vprintfmt+0x2a>
  804160bcc9:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160bccd:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160bcd1:	eb 19                	jmp    804160bcec <vprintfmt+0x2f7>
            putch(ch, putdat);
  804160bcd3:	4c 89 fe             	mov    %r15,%rsi
  804160bcd6:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160bcd9:	41 83 ee 01          	sub    $0x1,%r14d
  804160bcdd:	48 83 c3 01          	add    $0x1,%rbx
  804160bce1:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  804160bce5:	0f be f8             	movsbl %al,%edi
  804160bce8:	85 ff                	test   %edi,%edi
  804160bcea:	74 29                	je     804160bd15 <vprintfmt+0x320>
  804160bcec:	45 85 e4             	test   %r12d,%r12d
  804160bcef:	78 06                	js     804160bcf7 <vprintfmt+0x302>
  804160bcf1:	41 83 ec 01          	sub    $0x1,%r12d
  804160bcf5:	78 48                	js     804160bd3f <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  804160bcf7:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  804160bcfb:	74 d6                	je     804160bcd3 <vprintfmt+0x2de>
  804160bcfd:	0f be c0             	movsbl %al,%eax
  804160bd00:	83 e8 20             	sub    $0x20,%eax
  804160bd03:	83 f8 5e             	cmp    $0x5e,%eax
  804160bd06:	76 cb                	jbe    804160bcd3 <vprintfmt+0x2de>
            putch('?', putdat);
  804160bd08:	4c 89 fe             	mov    %r15,%rsi
  804160bd0b:	bf 3f 00 00 00       	mov    $0x3f,%edi
  804160bd10:	41 ff d5             	callq  *%r13
  804160bd13:	eb c4                	jmp    804160bcd9 <vprintfmt+0x2e4>
  804160bd15:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160bd19:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  804160bd1d:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  804160bd20:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160bd24:	0f 8e f5 fc ff ff    	jle    804160ba1f <vprintfmt+0x2a>
          putch(' ', putdat);
  804160bd2a:	4c 89 fe             	mov    %r15,%rsi
  804160bd2d:	bf 20 00 00 00       	mov    $0x20,%edi
  804160bd32:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  804160bd35:	83 eb 01             	sub    $0x1,%ebx
  804160bd38:	75 f0                	jne    804160bd2a <vprintfmt+0x335>
  804160bd3a:	e9 e0 fc ff ff       	jmpq   804160ba1f <vprintfmt+0x2a>
  804160bd3f:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160bd43:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  804160bd47:	eb d4                	jmp    804160bd1d <vprintfmt+0x328>
  if (lflag >= 2)
  804160bd49:	83 f9 01             	cmp    $0x1,%ecx
  804160bd4c:	7f 1d                	jg     804160bd6b <vprintfmt+0x376>
  else if (lflag)
  804160bd4e:	85 c9                	test   %ecx,%ecx
  804160bd50:	74 5e                	je     804160bdb0 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  804160bd52:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bd55:	83 f8 2f             	cmp    $0x2f,%eax
  804160bd58:	77 48                	ja     804160bda2 <vprintfmt+0x3ad>
  804160bd5a:	89 c2                	mov    %eax,%edx
  804160bd5c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bd60:	83 c0 08             	add    $0x8,%eax
  804160bd63:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bd66:	48 8b 1a             	mov    (%rdx),%rbx
  804160bd69:	eb 17                	jmp    804160bd82 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  804160bd6b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bd6e:	83 f8 2f             	cmp    $0x2f,%eax
  804160bd71:	77 21                	ja     804160bd94 <vprintfmt+0x39f>
  804160bd73:	89 c2                	mov    %eax,%edx
  804160bd75:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bd79:	83 c0 08             	add    $0x8,%eax
  804160bd7c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bd7f:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  804160bd82:	48 85 db             	test   %rbx,%rbx
  804160bd85:	78 50                	js     804160bdd7 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  804160bd87:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  804160bd8a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160bd8f:	e9 b4 01 00 00       	jmpq   804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  804160bd94:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bd98:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bd9c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bda0:	eb dd                	jmp    804160bd7f <vprintfmt+0x38a>
    return va_arg(*ap, long);
  804160bda2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bda6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bdaa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bdae:	eb b6                	jmp    804160bd66 <vprintfmt+0x371>
    return va_arg(*ap, int);
  804160bdb0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bdb3:	83 f8 2f             	cmp    $0x2f,%eax
  804160bdb6:	77 11                	ja     804160bdc9 <vprintfmt+0x3d4>
  804160bdb8:	89 c2                	mov    %eax,%edx
  804160bdba:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bdbe:	83 c0 08             	add    $0x8,%eax
  804160bdc1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bdc4:	48 63 1a             	movslq (%rdx),%rbx
  804160bdc7:	eb b9                	jmp    804160bd82 <vprintfmt+0x38d>
  804160bdc9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bdcd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bdd1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bdd5:	eb ed                	jmp    804160bdc4 <vprintfmt+0x3cf>
          putch('-', putdat);
  804160bdd7:	4c 89 fe             	mov    %r15,%rsi
  804160bdda:	bf 2d 00 00 00       	mov    $0x2d,%edi
  804160bddf:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  804160bde2:	48 89 da             	mov    %rbx,%rdx
  804160bde5:	48 f7 da             	neg    %rdx
        base = 10;
  804160bde8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160bded:	e9 56 01 00 00       	jmpq   804160bf48 <vprintfmt+0x553>
  if (lflag >= 2)
  804160bdf2:	83 f9 01             	cmp    $0x1,%ecx
  804160bdf5:	7f 25                	jg     804160be1c <vprintfmt+0x427>
  else if (lflag)
  804160bdf7:	85 c9                	test   %ecx,%ecx
  804160bdf9:	74 5e                	je     804160be59 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  804160bdfb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bdfe:	83 f8 2f             	cmp    $0x2f,%eax
  804160be01:	77 48                	ja     804160be4b <vprintfmt+0x456>
  804160be03:	89 c2                	mov    %eax,%edx
  804160be05:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160be09:	83 c0 08             	add    $0x8,%eax
  804160be0c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160be0f:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160be12:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160be17:	e9 2c 01 00 00       	jmpq   804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160be1c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160be1f:	83 f8 2f             	cmp    $0x2f,%eax
  804160be22:	77 19                	ja     804160be3d <vprintfmt+0x448>
  804160be24:	89 c2                	mov    %eax,%edx
  804160be26:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160be2a:	83 c0 08             	add    $0x8,%eax
  804160be2d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160be30:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160be33:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160be38:	e9 0b 01 00 00       	jmpq   804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160be3d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160be41:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160be45:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160be49:	eb e5                	jmp    804160be30 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  804160be4b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160be4f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160be53:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160be57:	eb b6                	jmp    804160be0f <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  804160be59:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160be5c:	83 f8 2f             	cmp    $0x2f,%eax
  804160be5f:	77 18                	ja     804160be79 <vprintfmt+0x484>
  804160be61:	89 c2                	mov    %eax,%edx
  804160be63:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160be67:	83 c0 08             	add    $0x8,%eax
  804160be6a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160be6d:	8b 12                	mov    (%rdx),%edx
        base = 10;
  804160be6f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160be74:	e9 cf 00 00 00       	jmpq   804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160be79:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160be7d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160be81:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160be85:	eb e6                	jmp    804160be6d <vprintfmt+0x478>
  if (lflag >= 2)
  804160be87:	83 f9 01             	cmp    $0x1,%ecx
  804160be8a:	7f 25                	jg     804160beb1 <vprintfmt+0x4bc>
  else if (lflag)
  804160be8c:	85 c9                	test   %ecx,%ecx
  804160be8e:	74 5b                	je     804160beeb <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  804160be90:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160be93:	83 f8 2f             	cmp    $0x2f,%eax
  804160be96:	77 45                	ja     804160bedd <vprintfmt+0x4e8>
  804160be98:	89 c2                	mov    %eax,%edx
  804160be9a:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160be9e:	83 c0 08             	add    $0x8,%eax
  804160bea1:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bea4:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160bea7:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160beac:	e9 97 00 00 00       	jmpq   804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160beb1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160beb4:	83 f8 2f             	cmp    $0x2f,%eax
  804160beb7:	77 16                	ja     804160becf <vprintfmt+0x4da>
  804160beb9:	89 c2                	mov    %eax,%edx
  804160bebb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bebf:	83 c0 08             	add    $0x8,%eax
  804160bec2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bec5:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160bec8:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160becd:	eb 79                	jmp    804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160becf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bed3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bed7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bedb:	eb e8                	jmp    804160bec5 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  804160bedd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bee1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bee5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bee9:	eb b9                	jmp    804160bea4 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  804160beeb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160beee:	83 f8 2f             	cmp    $0x2f,%eax
  804160bef1:	77 15                	ja     804160bf08 <vprintfmt+0x513>
  804160bef3:	89 c2                	mov    %eax,%edx
  804160bef5:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bef9:	83 c0 08             	add    $0x8,%eax
  804160befc:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160beff:	8b 12                	mov    (%rdx),%edx
        base = 8;
  804160bf01:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160bf06:	eb 40                	jmp    804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160bf08:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bf0c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bf10:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bf14:	eb e9                	jmp    804160beff <vprintfmt+0x50a>
        putch('0', putdat);
  804160bf16:	4c 89 fe             	mov    %r15,%rsi
  804160bf19:	bf 30 00 00 00       	mov    $0x30,%edi
  804160bf1e:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  804160bf21:	4c 89 fe             	mov    %r15,%rsi
  804160bf24:	bf 78 00 00 00       	mov    $0x78,%edi
  804160bf29:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160bf2c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bf2f:	83 f8 2f             	cmp    $0x2f,%eax
  804160bf32:	77 34                	ja     804160bf68 <vprintfmt+0x573>
  804160bf34:	89 c2                	mov    %eax,%edx
  804160bf36:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bf3a:	83 c0 08             	add    $0x8,%eax
  804160bf3d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bf40:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160bf43:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  804160bf48:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  804160bf4d:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  804160bf51:	4c 89 fe             	mov    %r15,%rsi
  804160bf54:	4c 89 ef             	mov    %r13,%rdi
  804160bf57:	48 b8 cb b8 60 41 80 	movabs $0x804160b8cb,%rax
  804160bf5e:	00 00 00 
  804160bf61:	ff d0                	callq  *%rax
        break;
  804160bf63:	e9 b7 fa ff ff       	jmpq   804160ba1f <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160bf68:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bf6c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bf70:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bf74:	eb ca                	jmp    804160bf40 <vprintfmt+0x54b>
  if (lflag >= 2)
  804160bf76:	83 f9 01             	cmp    $0x1,%ecx
  804160bf79:	7f 22                	jg     804160bf9d <vprintfmt+0x5a8>
  else if (lflag)
  804160bf7b:	85 c9                	test   %ecx,%ecx
  804160bf7d:	74 58                	je     804160bfd7 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  804160bf7f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bf82:	83 f8 2f             	cmp    $0x2f,%eax
  804160bf85:	77 42                	ja     804160bfc9 <vprintfmt+0x5d4>
  804160bf87:	89 c2                	mov    %eax,%edx
  804160bf89:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bf8d:	83 c0 08             	add    $0x8,%eax
  804160bf90:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bf93:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160bf96:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160bf9b:	eb ab                	jmp    804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160bf9d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bfa0:	83 f8 2f             	cmp    $0x2f,%eax
  804160bfa3:	77 16                	ja     804160bfbb <vprintfmt+0x5c6>
  804160bfa5:	89 c2                	mov    %eax,%edx
  804160bfa7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bfab:	83 c0 08             	add    $0x8,%eax
  804160bfae:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bfb1:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160bfb4:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160bfb9:	eb 8d                	jmp    804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160bfbb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bfbf:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bfc3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bfc7:	eb e8                	jmp    804160bfb1 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  804160bfc9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bfcd:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bfd1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160bfd5:	eb bc                	jmp    804160bf93 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  804160bfd7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160bfda:	83 f8 2f             	cmp    $0x2f,%eax
  804160bfdd:	77 18                	ja     804160bff7 <vprintfmt+0x602>
  804160bfdf:	89 c2                	mov    %eax,%edx
  804160bfe1:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160bfe5:	83 c0 08             	add    $0x8,%eax
  804160bfe8:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160bfeb:	8b 12                	mov    (%rdx),%edx
        base = 16;
  804160bfed:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160bff2:	e9 51 ff ff ff       	jmpq   804160bf48 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160bff7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160bffb:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160bfff:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160c003:	eb e6                	jmp    804160bfeb <vprintfmt+0x5f6>
        putch(ch, putdat);
  804160c005:	4c 89 fe             	mov    %r15,%rsi
  804160c008:	bf 25 00 00 00       	mov    $0x25,%edi
  804160c00d:	41 ff d5             	callq  *%r13
        break;
  804160c010:	e9 0a fa ff ff       	jmpq   804160ba1f <vprintfmt+0x2a>
        putch('%', putdat);
  804160c015:	4c 89 fe             	mov    %r15,%rsi
  804160c018:	bf 25 00 00 00       	mov    $0x25,%edi
  804160c01d:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160c020:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  804160c024:	0f 84 15 fa ff ff    	je     804160ba3f <vprintfmt+0x4a>
  804160c02a:	49 89 de             	mov    %rbx,%r14
  804160c02d:	49 83 ee 01          	sub    $0x1,%r14
  804160c031:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  804160c036:	75 f5                	jne    804160c02d <vprintfmt+0x638>
  804160c038:	e9 e2 f9 ff ff       	jmpq   804160ba1f <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  804160c03d:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160c041:	74 06                	je     804160c049 <vprintfmt+0x654>
  804160c043:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160c047:	7f 21                	jg     804160c06a <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160c049:	bf 28 00 00 00       	mov    $0x28,%edi
  804160c04e:	48 bb 55 ec 60 41 80 	movabs $0x804160ec55,%rbx
  804160c055:	00 00 00 
  804160c058:	b8 28 00 00 00       	mov    $0x28,%eax
  804160c05d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160c061:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160c065:	e9 82 fc ff ff       	jmpq   804160bcec <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160c06a:	49 63 f4             	movslq %r12d,%rsi
  804160c06d:	48 bf 54 ec 60 41 80 	movabs $0x804160ec54,%rdi
  804160c074:	00 00 00 
  804160c077:	48 b8 0d c3 60 41 80 	movabs $0x804160c30d,%rax
  804160c07e:	00 00 00 
  804160c081:	ff d0                	callq  *%rax
  804160c083:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160c086:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  804160c089:	48 be 54 ec 60 41 80 	movabs $0x804160ec54,%rsi
  804160c090:	00 00 00 
  804160c093:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  804160c097:	85 c0                	test   %eax,%eax
  804160c099:	0f 8f f2 fb ff ff    	jg     804160bc91 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160c09f:	48 bb 55 ec 60 41 80 	movabs $0x804160ec55,%rbx
  804160c0a6:	00 00 00 
  804160c0a9:	b8 28 00 00 00       	mov    $0x28,%eax
  804160c0ae:	bf 28 00 00 00       	mov    $0x28,%edi
  804160c0b3:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160c0b7:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160c0bb:	e9 2c fc ff ff       	jmpq   804160bcec <vprintfmt+0x2f7>
}
  804160c0c0:	48 83 c4 48          	add    $0x48,%rsp
  804160c0c4:	5b                   	pop    %rbx
  804160c0c5:	41 5c                	pop    %r12
  804160c0c7:	41 5d                	pop    %r13
  804160c0c9:	41 5e                	pop    %r14
  804160c0cb:	41 5f                	pop    %r15
  804160c0cd:	5d                   	pop    %rbp
  804160c0ce:	c3                   	retq   

000000804160c0cf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  804160c0cf:	55                   	push   %rbp
  804160c0d0:	48 89 e5             	mov    %rsp,%rbp
  804160c0d3:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  804160c0d7:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  804160c0db:	48 63 c6             	movslq %esi,%rax
  804160c0de:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  804160c0e3:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  804160c0e7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  804160c0ee:	48 85 ff             	test   %rdi,%rdi
  804160c0f1:	74 2a                	je     804160c11d <vsnprintf+0x4e>
  804160c0f3:	85 f6                	test   %esi,%esi
  804160c0f5:	7e 26                	jle    804160c11d <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  804160c0f7:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  804160c0fb:	48 bf 57 b9 60 41 80 	movabs $0x804160b957,%rdi
  804160c102:	00 00 00 
  804160c105:	48 b8 f5 b9 60 41 80 	movabs $0x804160b9f5,%rax
  804160c10c:	00 00 00 
  804160c10f:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  804160c111:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160c115:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  804160c118:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  804160c11b:	c9                   	leaveq 
  804160c11c:	c3                   	retq   
    return -E_INVAL;
  804160c11d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160c122:	eb f7                	jmp    804160c11b <vsnprintf+0x4c>

000000804160c124 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  804160c124:	55                   	push   %rbp
  804160c125:	48 89 e5             	mov    %rsp,%rbp
  804160c128:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160c12f:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160c136:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160c13d:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160c144:	84 c0                	test   %al,%al
  804160c146:	74 20                	je     804160c168 <snprintf+0x44>
  804160c148:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160c14c:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160c150:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160c154:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160c158:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160c15c:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160c160:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160c164:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  804160c168:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160c16f:	00 00 00 
  804160c172:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160c179:	00 00 00 
  804160c17c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160c180:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160c187:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160c18e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  804160c195:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160c19c:	48 b8 cf c0 60 41 80 	movabs $0x804160c0cf,%rax
  804160c1a3:	00 00 00 
  804160c1a6:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  804160c1a8:	c9                   	leaveq 
  804160c1a9:	c3                   	retq   

000000804160c1aa <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  804160c1aa:	55                   	push   %rbp
  804160c1ab:	48 89 e5             	mov    %rsp,%rbp
  804160c1ae:	41 57                	push   %r15
  804160c1b0:	41 56                	push   %r14
  804160c1b2:	41 55                	push   %r13
  804160c1b4:	41 54                	push   %r12
  804160c1b6:	53                   	push   %rbx
  804160c1b7:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  804160c1bb:	48 85 ff             	test   %rdi,%rdi
  804160c1be:	74 1e                	je     804160c1de <readline+0x34>
    cprintf("%s", prompt);
  804160c1c0:	48 89 fe             	mov    %rdi,%rsi
  804160c1c3:	48 bf eb cf 60 41 80 	movabs $0x804160cfeb,%rdi
  804160c1ca:	00 00 00 
  804160c1cd:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c1d2:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160c1d9:	00 00 00 
  804160c1dc:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  804160c1de:	bf 00 00 00 00       	mov    $0x0,%edi
  804160c1e3:	48 b8 34 0d 60 41 80 	movabs $0x8041600d34,%rax
  804160c1ea:	00 00 00 
  804160c1ed:	ff d0                	callq  *%rax
  804160c1ef:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  804160c1f2:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  804160c1f8:	49 bd 14 0d 60 41 80 	movabs $0x8041600d14,%r13
  804160c1ff:	00 00 00 
        cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  804160c202:	49 bf 02 0d 60 41 80 	movabs $0x8041600d02,%r15
  804160c209:	00 00 00 
  804160c20c:	eb 46                	jmp    804160c254 <readline+0xaa>
      return NULL;
  804160c20e:	b8 00 00 00 00       	mov    $0x0,%eax
      if (c != -E_EOF)
  804160c213:	83 fb f5             	cmp    $0xfffffff5,%ebx
  804160c216:	75 0f                	jne    804160c227 <readline+0x7d>
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  804160c218:	48 83 c4 08          	add    $0x8,%rsp
  804160c21c:	5b                   	pop    %rbx
  804160c21d:	41 5c                	pop    %r12
  804160c21f:	41 5d                	pop    %r13
  804160c221:	41 5e                	pop    %r14
  804160c223:	41 5f                	pop    %r15
  804160c225:	5d                   	pop    %rbp
  804160c226:	c3                   	retq   
        cprintf("read error: %i\n", c);
  804160c227:	89 de                	mov    %ebx,%esi
  804160c229:	48 bf 40 f0 60 41 80 	movabs $0x804160f040,%rdi
  804160c230:	00 00 00 
  804160c233:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160c23a:	00 00 00 
  804160c23d:	ff d2                	callq  *%rdx
      return NULL;
  804160c23f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c244:	eb d2                	jmp    804160c218 <readline+0x6e>
      if (i > 0) {
  804160c246:	45 85 e4             	test   %r12d,%r12d
  804160c249:	7e 09                	jle    804160c254 <readline+0xaa>
        if (echoing) {
  804160c24b:	45 85 f6             	test   %r14d,%r14d
  804160c24e:	75 41                	jne    804160c291 <readline+0xe7>
        i--;
  804160c250:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  804160c254:	41 ff d5             	callq  *%r13
  804160c257:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  804160c259:	85 c0                	test   %eax,%eax
  804160c25b:	78 b1                	js     804160c20e <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  804160c25d:	83 f8 08             	cmp    $0x8,%eax
  804160c260:	74 e4                	je     804160c246 <readline+0x9c>
  804160c262:	83 f8 7f             	cmp    $0x7f,%eax
  804160c265:	74 df                	je     804160c246 <readline+0x9c>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  804160c267:	83 f8 1f             	cmp    $0x1f,%eax
  804160c26a:	7e 46                	jle    804160c2b2 <readline+0x108>
  804160c26c:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  804160c273:	7f 3d                	jg     804160c2b2 <readline+0x108>
      if (echoing)
  804160c275:	45 85 f6             	test   %r14d,%r14d
  804160c278:	75 31                	jne    804160c2ab <readline+0x101>
      buf[i++] = c;
  804160c27a:	49 63 c4             	movslq %r12d,%rax
  804160c27d:	48 b9 20 56 88 41 80 	movabs $0x8041885620,%rcx
  804160c284:	00 00 00 
  804160c287:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  804160c28a:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  804160c28f:	eb c3                	jmp    804160c254 <readline+0xaa>
          cputchar('\b');
  804160c291:	bf 08 00 00 00       	mov    $0x8,%edi
  804160c296:	41 ff d7             	callq  *%r15
          cputchar(' ');
  804160c299:	bf 20 00 00 00       	mov    $0x20,%edi
  804160c29e:	41 ff d7             	callq  *%r15
          cputchar('\b');
  804160c2a1:	bf 08 00 00 00       	mov    $0x8,%edi
  804160c2a6:	41 ff d7             	callq  *%r15
  804160c2a9:	eb a5                	jmp    804160c250 <readline+0xa6>
        cputchar(c);
  804160c2ab:	89 c7                	mov    %eax,%edi
  804160c2ad:	41 ff d7             	callq  *%r15
  804160c2b0:	eb c8                	jmp    804160c27a <readline+0xd0>
    } else if (c == '\n' || c == '\r') {
  804160c2b2:	83 fb 0a             	cmp    $0xa,%ebx
  804160c2b5:	74 05                	je     804160c2bc <readline+0x112>
  804160c2b7:	83 fb 0d             	cmp    $0xd,%ebx
  804160c2ba:	75 98                	jne    804160c254 <readline+0xaa>
      if (echoing)
  804160c2bc:	45 85 f6             	test   %r14d,%r14d
  804160c2bf:	75 17                	jne    804160c2d8 <readline+0x12e>
      buf[i] = 0;
  804160c2c1:	48 b8 20 56 88 41 80 	movabs $0x8041885620,%rax
  804160c2c8:	00 00 00 
  804160c2cb:	4d 63 e4             	movslq %r12d,%r12
  804160c2ce:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  804160c2d3:	e9 40 ff ff ff       	jmpq   804160c218 <readline+0x6e>
        cputchar('\n');
  804160c2d8:	bf 0a 00 00 00       	mov    $0xa,%edi
  804160c2dd:	48 b8 02 0d 60 41 80 	movabs $0x8041600d02,%rax
  804160c2e4:	00 00 00 
  804160c2e7:	ff d0                	callq  *%rax
  804160c2e9:	eb d6                	jmp    804160c2c1 <readline+0x117>

000000804160c2eb <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  804160c2eb:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160c2ee:	74 17                	je     804160c307 <strlen+0x1c>
  804160c2f0:	48 89 fa             	mov    %rdi,%rdx
  804160c2f3:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160c2f8:	29 f9                	sub    %edi,%ecx
    n++;
  804160c2fa:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  804160c2fd:	48 83 c2 01          	add    $0x1,%rdx
  804160c301:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160c304:	75 f4                	jne    804160c2fa <strlen+0xf>
  804160c306:	c3                   	retq   
  804160c307:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160c30c:	c3                   	retq   

000000804160c30d <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160c30d:	48 85 f6             	test   %rsi,%rsi
  804160c310:	74 24                	je     804160c336 <strnlen+0x29>
  804160c312:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160c315:	74 25                	je     804160c33c <strnlen+0x2f>
  804160c317:	48 01 fe             	add    %rdi,%rsi
  804160c31a:	48 89 fa             	mov    %rdi,%rdx
  804160c31d:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160c322:	29 f9                	sub    %edi,%ecx
    n++;
  804160c324:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160c327:	48 83 c2 01          	add    $0x1,%rdx
  804160c32b:	48 39 f2             	cmp    %rsi,%rdx
  804160c32e:	74 11                	je     804160c341 <strnlen+0x34>
  804160c330:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160c333:	75 ef                	jne    804160c324 <strnlen+0x17>
  804160c335:	c3                   	retq   
  804160c336:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c33b:	c3                   	retq   
  804160c33c:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160c341:	c3                   	retq   

000000804160c342 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  804160c342:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  804160c345:	ba 00 00 00 00       	mov    $0x0,%edx
  804160c34a:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  804160c34e:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  804160c351:	48 83 c2 01          	add    $0x1,%rdx
  804160c355:	84 c9                	test   %cl,%cl
  804160c357:	75 f1                	jne    804160c34a <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  804160c359:	c3                   	retq   

000000804160c35a <strcat>:

char *
strcat(char *dst, const char *src) {
  804160c35a:	55                   	push   %rbp
  804160c35b:	48 89 e5             	mov    %rsp,%rbp
  804160c35e:	41 54                	push   %r12
  804160c360:	53                   	push   %rbx
  804160c361:	48 89 fb             	mov    %rdi,%rbx
  804160c364:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  804160c367:	48 b8 eb c2 60 41 80 	movabs $0x804160c2eb,%rax
  804160c36e:	00 00 00 
  804160c371:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  804160c373:	48 63 f8             	movslq %eax,%rdi
  804160c376:	48 01 df             	add    %rbx,%rdi
  804160c379:	4c 89 e6             	mov    %r12,%rsi
  804160c37c:	48 b8 42 c3 60 41 80 	movabs $0x804160c342,%rax
  804160c383:	00 00 00 
  804160c386:	ff d0                	callq  *%rax
  return dst;
}
  804160c388:	48 89 d8             	mov    %rbx,%rax
  804160c38b:	5b                   	pop    %rbx
  804160c38c:	41 5c                	pop    %r12
  804160c38e:	5d                   	pop    %rbp
  804160c38f:	c3                   	retq   

000000804160c390 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  804160c390:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  804160c393:	48 85 d2             	test   %rdx,%rdx
  804160c396:	74 1f                	je     804160c3b7 <strncpy+0x27>
  804160c398:	48 01 fa             	add    %rdi,%rdx
  804160c39b:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  804160c39e:	48 83 c1 01          	add    $0x1,%rcx
  804160c3a2:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160c3a6:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  804160c3aa:	41 80 f8 01          	cmp    $0x1,%r8b
  804160c3ae:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  804160c3b2:	48 39 ca             	cmp    %rcx,%rdx
  804160c3b5:	75 e7                	jne    804160c39e <strncpy+0xe>
  }
  return ret;
}
  804160c3b7:	c3                   	retq   

000000804160c3b8 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  804160c3b8:	48 89 f8             	mov    %rdi,%rax
  804160c3bb:	48 85 d2             	test   %rdx,%rdx
  804160c3be:	74 36                	je     804160c3f6 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  804160c3c0:	48 83 fa 01          	cmp    $0x1,%rdx
  804160c3c4:	74 2d                	je     804160c3f3 <strlcpy+0x3b>
  804160c3c6:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160c3ca:	45 84 c0             	test   %r8b,%r8b
  804160c3cd:	74 24                	je     804160c3f3 <strlcpy+0x3b>
  804160c3cf:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  804160c3d3:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  804160c3d8:	48 83 c0 01          	add    $0x1,%rax
  804160c3dc:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  804160c3e0:	48 39 d1             	cmp    %rdx,%rcx
  804160c3e3:	74 0e                	je     804160c3f3 <strlcpy+0x3b>
  804160c3e5:	48 83 c1 01          	add    $0x1,%rcx
  804160c3e9:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  804160c3ee:	45 84 c0             	test   %r8b,%r8b
  804160c3f1:	75 e5                	jne    804160c3d8 <strlcpy+0x20>
    *dst = '\0';
  804160c3f3:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  804160c3f6:	48 29 f8             	sub    %rdi,%rax
}
  804160c3f9:	c3                   	retq   

000000804160c3fa <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  804160c3fa:	0f b6 07             	movzbl (%rdi),%eax
  804160c3fd:	84 c0                	test   %al,%al
  804160c3ff:	74 17                	je     804160c418 <strcmp+0x1e>
  804160c401:	3a 06                	cmp    (%rsi),%al
  804160c403:	75 13                	jne    804160c418 <strcmp+0x1e>
    p++, q++;
  804160c405:	48 83 c7 01          	add    $0x1,%rdi
  804160c409:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  804160c40d:	0f b6 07             	movzbl (%rdi),%eax
  804160c410:	84 c0                	test   %al,%al
  804160c412:	74 04                	je     804160c418 <strcmp+0x1e>
  804160c414:	3a 06                	cmp    (%rsi),%al
  804160c416:	74 ed                	je     804160c405 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  804160c418:	0f b6 c0             	movzbl %al,%eax
  804160c41b:	0f b6 16             	movzbl (%rsi),%edx
  804160c41e:	29 d0                	sub    %edx,%eax
}
  804160c420:	c3                   	retq   

000000804160c421 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  804160c421:	48 85 d2             	test   %rdx,%rdx
  804160c424:	74 2f                	je     804160c455 <strncmp+0x34>
  804160c426:	0f b6 07             	movzbl (%rdi),%eax
  804160c429:	84 c0                	test   %al,%al
  804160c42b:	74 1f                	je     804160c44c <strncmp+0x2b>
  804160c42d:	3a 06                	cmp    (%rsi),%al
  804160c42f:	75 1b                	jne    804160c44c <strncmp+0x2b>
  804160c431:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  804160c434:	48 83 c7 01          	add    $0x1,%rdi
  804160c438:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  804160c43c:	48 39 d7             	cmp    %rdx,%rdi
  804160c43f:	74 1a                	je     804160c45b <strncmp+0x3a>
  804160c441:	0f b6 07             	movzbl (%rdi),%eax
  804160c444:	84 c0                	test   %al,%al
  804160c446:	74 04                	je     804160c44c <strncmp+0x2b>
  804160c448:	3a 06                	cmp    (%rsi),%al
  804160c44a:	74 e8                	je     804160c434 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  804160c44c:	0f b6 07             	movzbl (%rdi),%eax
  804160c44f:	0f b6 16             	movzbl (%rsi),%edx
  804160c452:	29 d0                	sub    %edx,%eax
}
  804160c454:	c3                   	retq   
    return 0;
  804160c455:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c45a:	c3                   	retq   
  804160c45b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c460:	c3                   	retq   

000000804160c461 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  804160c461:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  804160c463:	0f b6 07             	movzbl (%rdi),%eax
  804160c466:	84 c0                	test   %al,%al
  804160c468:	74 1e                	je     804160c488 <strchr+0x27>
    if (*s == c)
  804160c46a:	40 38 c6             	cmp    %al,%sil
  804160c46d:	74 1f                	je     804160c48e <strchr+0x2d>
  for (; *s; s++)
  804160c46f:	48 83 c7 01          	add    $0x1,%rdi
  804160c473:	0f b6 07             	movzbl (%rdi),%eax
  804160c476:	84 c0                	test   %al,%al
  804160c478:	74 08                	je     804160c482 <strchr+0x21>
    if (*s == c)
  804160c47a:	38 d0                	cmp    %dl,%al
  804160c47c:	75 f1                	jne    804160c46f <strchr+0xe>
  for (; *s; s++)
  804160c47e:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  804160c481:	c3                   	retq   
  return 0;
  804160c482:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c487:	c3                   	retq   
  804160c488:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c48d:	c3                   	retq   
    if (*s == c)
  804160c48e:	48 89 f8             	mov    %rdi,%rax
  804160c491:	c3                   	retq   

000000804160c492 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  804160c492:	48 89 f8             	mov    %rdi,%rax
  804160c495:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  804160c497:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  804160c49a:	40 38 f2             	cmp    %sil,%dl
  804160c49d:	74 13                	je     804160c4b2 <strfind+0x20>
  804160c49f:	84 d2                	test   %dl,%dl
  804160c4a1:	74 0f                	je     804160c4b2 <strfind+0x20>
  for (; *s; s++)
  804160c4a3:	48 83 c0 01          	add    $0x1,%rax
  804160c4a7:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  804160c4aa:	38 ca                	cmp    %cl,%dl
  804160c4ac:	74 04                	je     804160c4b2 <strfind+0x20>
  804160c4ae:	84 d2                	test   %dl,%dl
  804160c4b0:	75 f1                	jne    804160c4a3 <strfind+0x11>
      break;
  return (char *)s;
}
  804160c4b2:	c3                   	retq   

000000804160c4b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  804160c4b3:	48 85 d2             	test   %rdx,%rdx
  804160c4b6:	74 3a                	je     804160c4f2 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160c4b8:	48 89 f8             	mov    %rdi,%rax
  804160c4bb:	48 09 d0             	or     %rdx,%rax
  804160c4be:	a8 03                	test   $0x3,%al
  804160c4c0:	75 28                	jne    804160c4ea <memset+0x37>
    uint32_t k = c & 0xFFU;
  804160c4c2:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  804160c4c6:	89 f0                	mov    %esi,%eax
  804160c4c8:	c1 e0 08             	shl    $0x8,%eax
  804160c4cb:	89 f1                	mov    %esi,%ecx
  804160c4cd:	c1 e1 18             	shl    $0x18,%ecx
  804160c4d0:	41 89 f0             	mov    %esi,%r8d
  804160c4d3:	41 c1 e0 10          	shl    $0x10,%r8d
  804160c4d7:	44 09 c1             	or     %r8d,%ecx
  804160c4da:	09 ce                	or     %ecx,%esi
  804160c4dc:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  804160c4de:	48 c1 ea 02          	shr    $0x2,%rdx
  804160c4e2:	48 89 d1             	mov    %rdx,%rcx
  804160c4e5:	fc                   	cld    
  804160c4e6:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160c4e8:	eb 08                	jmp    804160c4f2 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  804160c4ea:	89 f0                	mov    %esi,%eax
  804160c4ec:	48 89 d1             	mov    %rdx,%rcx
  804160c4ef:	fc                   	cld    
  804160c4f0:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  804160c4f2:	48 89 f8             	mov    %rdi,%rax
  804160c4f5:	c3                   	retq   

000000804160c4f6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  804160c4f6:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  804160c4f9:	48 39 fe             	cmp    %rdi,%rsi
  804160c4fc:	73 40                	jae    804160c53e <memmove+0x48>
  804160c4fe:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  804160c502:	48 39 f9             	cmp    %rdi,%rcx
  804160c505:	76 37                	jbe    804160c53e <memmove+0x48>
    s += n;
    d += n;
  804160c507:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160c50b:	48 89 fe             	mov    %rdi,%rsi
  804160c50e:	48 09 d6             	or     %rdx,%rsi
  804160c511:	48 09 ce             	or     %rcx,%rsi
  804160c514:	40 f6 c6 03          	test   $0x3,%sil
  804160c518:	75 14                	jne    804160c52e <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  804160c51a:	48 83 ef 04          	sub    $0x4,%rdi
  804160c51e:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  804160c522:	48 c1 ea 02          	shr    $0x2,%rdx
  804160c526:	48 89 d1             	mov    %rdx,%rcx
  804160c529:	fd                   	std    
  804160c52a:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160c52c:	eb 0e                	jmp    804160c53c <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  804160c52e:	48 83 ef 01          	sub    $0x1,%rdi
  804160c532:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  804160c536:	48 89 d1             	mov    %rdx,%rcx
  804160c539:	fd                   	std    
  804160c53a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  804160c53c:	fc                   	cld    
  804160c53d:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160c53e:	48 89 c1             	mov    %rax,%rcx
  804160c541:	48 09 d1             	or     %rdx,%rcx
  804160c544:	48 09 f1             	or     %rsi,%rcx
  804160c547:	f6 c1 03             	test   $0x3,%cl
  804160c54a:	75 0e                	jne    804160c55a <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  804160c54c:	48 c1 ea 02          	shr    $0x2,%rdx
  804160c550:	48 89 d1             	mov    %rdx,%rcx
  804160c553:	48 89 c7             	mov    %rax,%rdi
  804160c556:	fc                   	cld    
  804160c557:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160c559:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  804160c55a:	48 89 c7             	mov    %rax,%rdi
  804160c55d:	48 89 d1             	mov    %rdx,%rcx
  804160c560:	fc                   	cld    
  804160c561:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  804160c563:	c3                   	retq   

000000804160c564 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  804160c564:	55                   	push   %rbp
  804160c565:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  804160c568:	48 b8 f6 c4 60 41 80 	movabs $0x804160c4f6,%rax
  804160c56f:	00 00 00 
  804160c572:	ff d0                	callq  *%rax
}
  804160c574:	5d                   	pop    %rbp
  804160c575:	c3                   	retq   

000000804160c576 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  804160c576:	55                   	push   %rbp
  804160c577:	48 89 e5             	mov    %rsp,%rbp
  804160c57a:	41 57                	push   %r15
  804160c57c:	41 56                	push   %r14
  804160c57e:	41 55                	push   %r13
  804160c580:	41 54                	push   %r12
  804160c582:	53                   	push   %rbx
  804160c583:	48 83 ec 08          	sub    $0x8,%rsp
  804160c587:	49 89 fe             	mov    %rdi,%r14
  804160c58a:	49 89 f7             	mov    %rsi,%r15
  804160c58d:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  804160c590:	48 89 f7             	mov    %rsi,%rdi
  804160c593:	48 b8 eb c2 60 41 80 	movabs $0x804160c2eb,%rax
  804160c59a:	00 00 00 
  804160c59d:	ff d0                	callq  *%rax
  804160c59f:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  804160c5a2:	4c 89 ee             	mov    %r13,%rsi
  804160c5a5:	4c 89 f7             	mov    %r14,%rdi
  804160c5a8:	48 b8 0d c3 60 41 80 	movabs $0x804160c30d,%rax
  804160c5af:	00 00 00 
  804160c5b2:	ff d0                	callq  *%rax
  804160c5b4:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  804160c5b7:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  804160c5bb:	4d 39 e5             	cmp    %r12,%r13
  804160c5be:	74 26                	je     804160c5e6 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  804160c5c0:	4c 89 e8             	mov    %r13,%rax
  804160c5c3:	4c 29 e0             	sub    %r12,%rax
  804160c5c6:	48 39 d8             	cmp    %rbx,%rax
  804160c5c9:	76 2a                	jbe    804160c5f5 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  804160c5cb:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  804160c5cf:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160c5d3:	4c 89 fe             	mov    %r15,%rsi
  804160c5d6:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160c5dd:	00 00 00 
  804160c5e0:	ff d0                	callq  *%rax
  return dstlen + srclen;
  804160c5e2:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  804160c5e6:	48 83 c4 08          	add    $0x8,%rsp
  804160c5ea:	5b                   	pop    %rbx
  804160c5eb:	41 5c                	pop    %r12
  804160c5ed:	41 5d                	pop    %r13
  804160c5ef:	41 5e                	pop    %r14
  804160c5f1:	41 5f                	pop    %r15
  804160c5f3:	5d                   	pop    %rbp
  804160c5f4:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  804160c5f5:	49 83 ed 01          	sub    $0x1,%r13
  804160c5f9:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160c5fd:	4c 89 ea             	mov    %r13,%rdx
  804160c600:	4c 89 fe             	mov    %r15,%rsi
  804160c603:	48 b8 64 c5 60 41 80 	movabs $0x804160c564,%rax
  804160c60a:	00 00 00 
  804160c60d:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  804160c60f:	4d 01 ee             	add    %r13,%r14
  804160c612:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  804160c617:	eb c9                	jmp    804160c5e2 <strlcat+0x6c>

000000804160c619 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  804160c619:	48 85 d2             	test   %rdx,%rdx
  804160c61c:	74 3a                	je     804160c658 <memcmp+0x3f>
    if (*s1 != *s2)
  804160c61e:	0f b6 0f             	movzbl (%rdi),%ecx
  804160c621:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160c625:	44 38 c1             	cmp    %r8b,%cl
  804160c628:	75 1d                	jne    804160c647 <memcmp+0x2e>
  804160c62a:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  804160c62f:	48 39 d0             	cmp    %rdx,%rax
  804160c632:	74 1e                	je     804160c652 <memcmp+0x39>
    if (*s1 != *s2)
  804160c634:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  804160c638:	48 83 c0 01          	add    $0x1,%rax
  804160c63c:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  804160c642:	44 38 c1             	cmp    %r8b,%cl
  804160c645:	74 e8                	je     804160c62f <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  804160c647:	0f b6 c1             	movzbl %cl,%eax
  804160c64a:	45 0f b6 c0          	movzbl %r8b,%r8d
  804160c64e:	44 29 c0             	sub    %r8d,%eax
  804160c651:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  804160c652:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c657:	c3                   	retq   
  804160c658:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160c65d:	c3                   	retq   

000000804160c65e <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  804160c65e:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  804160c662:	48 39 c7             	cmp    %rax,%rdi
  804160c665:	73 19                	jae    804160c680 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c667:	89 f2                	mov    %esi,%edx
  804160c669:	40 38 37             	cmp    %sil,(%rdi)
  804160c66c:	74 16                	je     804160c684 <memfind+0x26>
  for (; s < ends; s++)
  804160c66e:	48 83 c7 01          	add    $0x1,%rdi
  804160c672:	48 39 f8             	cmp    %rdi,%rax
  804160c675:	74 08                	je     804160c67f <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c677:	38 17                	cmp    %dl,(%rdi)
  804160c679:	75 f3                	jne    804160c66e <memfind+0x10>
  for (; s < ends; s++)
  804160c67b:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  804160c67e:	c3                   	retq   
  804160c67f:	c3                   	retq   
  for (; s < ends; s++)
  804160c680:	48 89 f8             	mov    %rdi,%rax
  804160c683:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c684:	48 89 f8             	mov    %rdi,%rax
  804160c687:	c3                   	retq   

000000804160c688 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  804160c688:	0f b6 07             	movzbl (%rdi),%eax
  804160c68b:	3c 20                	cmp    $0x20,%al
  804160c68d:	74 04                	je     804160c693 <strtol+0xb>
  804160c68f:	3c 09                	cmp    $0x9,%al
  804160c691:	75 0f                	jne    804160c6a2 <strtol+0x1a>
    s++;
  804160c693:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  804160c697:	0f b6 07             	movzbl (%rdi),%eax
  804160c69a:	3c 20                	cmp    $0x20,%al
  804160c69c:	74 f5                	je     804160c693 <strtol+0xb>
  804160c69e:	3c 09                	cmp    $0x9,%al
  804160c6a0:	74 f1                	je     804160c693 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  804160c6a2:	3c 2b                	cmp    $0x2b,%al
  804160c6a4:	74 2b                	je     804160c6d1 <strtol+0x49>
  int neg  = 0;
  804160c6a6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  804160c6ac:	3c 2d                	cmp    $0x2d,%al
  804160c6ae:	74 2d                	je     804160c6dd <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160c6b0:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  804160c6b6:	75 0f                	jne    804160c6c7 <strtol+0x3f>
  804160c6b8:	80 3f 30             	cmpb   $0x30,(%rdi)
  804160c6bb:	74 2c                	je     804160c6e9 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  804160c6bd:	85 d2                	test   %edx,%edx
  804160c6bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  804160c6c4:	0f 44 d0             	cmove  %eax,%edx
  804160c6c7:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  804160c6cc:	4c 63 d2             	movslq %edx,%r10
  804160c6cf:	eb 5c                	jmp    804160c72d <strtol+0xa5>
    s++;
  804160c6d1:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  804160c6d5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160c6db:	eb d3                	jmp    804160c6b0 <strtol+0x28>
    s++, neg = 1;
  804160c6dd:	48 83 c7 01          	add    $0x1,%rdi
  804160c6e1:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160c6e7:	eb c7                	jmp    804160c6b0 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160c6e9:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  804160c6ed:	74 0f                	je     804160c6fe <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  804160c6ef:	85 d2                	test   %edx,%edx
  804160c6f1:	75 d4                	jne    804160c6c7 <strtol+0x3f>
    s++, base = 8;
  804160c6f3:	48 83 c7 01          	add    $0x1,%rdi
  804160c6f7:	ba 08 00 00 00       	mov    $0x8,%edx
  804160c6fc:	eb c9                	jmp    804160c6c7 <strtol+0x3f>
    s += 2, base = 16;
  804160c6fe:	48 83 c7 02          	add    $0x2,%rdi
  804160c702:	ba 10 00 00 00       	mov    $0x10,%edx
  804160c707:	eb be                	jmp    804160c6c7 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  804160c709:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  804160c70d:	41 80 f8 19          	cmp    $0x19,%r8b
  804160c711:	77 2f                	ja     804160c742 <strtol+0xba>
      dig = *s - 'a' + 10;
  804160c713:	44 0f be c1          	movsbl %cl,%r8d
  804160c717:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  804160c71b:	39 d1                	cmp    %edx,%ecx
  804160c71d:	7d 37                	jge    804160c756 <strtol+0xce>
    s++, val = (val * base) + dig;
  804160c71f:	48 83 c7 01          	add    $0x1,%rdi
  804160c723:	49 0f af c2          	imul   %r10,%rax
  804160c727:	48 63 c9             	movslq %ecx,%rcx
  804160c72a:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  804160c72d:	0f b6 0f             	movzbl (%rdi),%ecx
  804160c730:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  804160c734:	41 80 f8 09          	cmp    $0x9,%r8b
  804160c738:	77 cf                	ja     804160c709 <strtol+0x81>
      dig = *s - '0';
  804160c73a:	0f be c9             	movsbl %cl,%ecx
  804160c73d:	83 e9 30             	sub    $0x30,%ecx
  804160c740:	eb d9                	jmp    804160c71b <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  804160c742:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  804160c746:	41 80 f8 19          	cmp    $0x19,%r8b
  804160c74a:	77 0a                	ja     804160c756 <strtol+0xce>
      dig = *s - 'A' + 10;
  804160c74c:	44 0f be c1          	movsbl %cl,%r8d
  804160c750:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  804160c754:	eb c5                	jmp    804160c71b <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  804160c756:	48 85 f6             	test   %rsi,%rsi
  804160c759:	74 03                	je     804160c75e <strtol+0xd6>
    *endptr = (char *)s;
  804160c75b:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  804160c75e:	48 89 c2             	mov    %rax,%rdx
  804160c761:	48 f7 da             	neg    %rdx
  804160c764:	45 85 c9             	test   %r9d,%r9d
  804160c767:	48 0f 45 c2          	cmovne %rdx,%rax
}
  804160c76b:	c3                   	retq   

000000804160c76c <tsc_calibrate>:
  delta /= i * 256 * 1000;
  return delta;
}

uint64_t
tsc_calibrate(void) {
  804160c76c:	55                   	push   %rbp
  804160c76d:	48 89 e5             	mov    %rsp,%rbp
  804160c770:	41 57                	push   %r15
  804160c772:	41 56                	push   %r14
  804160c774:	41 55                	push   %r13
  804160c776:	41 54                	push   %r12
  804160c778:	53                   	push   %rbx
  804160c779:	48 83 ec 28          	sub    $0x28,%rsp
  static uint64_t cpu_freq;

  if (cpu_freq == 0) {
  804160c77d:	48 a1 20 5a 88 41 80 	movabs 0x8041885a20,%rax
  804160c784:	00 00 00 
  804160c787:	48 85 c0             	test   %rax,%rax
  804160c78a:	0f 85 8c 01 00 00    	jne    804160c91c <tsc_calibrate+0x1b0>
    int i;
    for (i = 0; i < TIMES; i++) {
  804160c790:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  __asm __volatile("inb %w1,%0"
  804160c796:	41 bd 61 00 00 00    	mov    $0x61,%r13d
  __asm __volatile("outb %0,%w1"
  804160c79c:	41 bf ff ff ff ff    	mov    $0xffffffff,%r15d
  804160c7a2:	b9 42 00 00 00       	mov    $0x42,%ecx
  uint64_t tsc = 0;
  804160c7a7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160c7ab:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160c7af:	eb 35                	jmp    804160c7e6 <tsc_calibrate+0x7a>
  804160c7b1:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  for (count = 0; count < 50000; count++) {
  804160c7b5:	be 00 00 00 00       	mov    $0x0,%esi
  804160c7ba:	eb 72                	jmp    804160c82e <tsc_calibrate+0xc2>
  uint64_t tsc = 0;
  804160c7bc:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  for (count = 0; count < 50000; count++) {
  804160c7c0:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160c7c6:	e9 c0 00 00 00       	jmpq   804160c88b <tsc_calibrate+0x11f>
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160c7cb:	41 83 c4 01          	add    $0x1,%r12d
  804160c7cf:	83 eb 01             	sub    $0x1,%ebx
  804160c7d2:	41 83 fc 75          	cmp    $0x75,%r12d
  804160c7d6:	75 7a                	jne    804160c852 <tsc_calibrate+0xe6>
    for (i = 0; i < TIMES; i++) {
  804160c7d8:	41 83 c3 01          	add    $0x1,%r11d
  804160c7dc:	41 83 fb 64          	cmp    $0x64,%r11d
  804160c7e0:	0f 84 56 01 00 00    	je     804160c93c <tsc_calibrate+0x1d0>
  __asm __volatile("inb %w1,%0"
  804160c7e6:	44 89 ea             	mov    %r13d,%edx
  804160c7e9:	ec                   	in     (%dx),%al
  outb(0x61, (inb(0x61) & ~0x02) | 0x01);
  804160c7ea:	83 e0 fc             	and    $0xfffffffc,%eax
  804160c7ed:	83 c8 01             	or     $0x1,%eax
  __asm __volatile("outb %0,%w1"
  804160c7f0:	ee                   	out    %al,(%dx)
  804160c7f1:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
  804160c7f6:	ba 43 00 00 00       	mov    $0x43,%edx
  804160c7fb:	ee                   	out    %al,(%dx)
  804160c7fc:	44 89 f8             	mov    %r15d,%eax
  804160c7ff:	89 ca                	mov    %ecx,%edx
  804160c801:	ee                   	out    %al,(%dx)
  804160c802:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160c803:	ec                   	in     (%dx),%al
  804160c804:	ec                   	in     (%dx),%al
  804160c805:	ec                   	in     (%dx),%al
  804160c806:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c807:	3c ff                	cmp    $0xff,%al
  804160c809:	75 a6                	jne    804160c7b1 <tsc_calibrate+0x45>
  for (count = 0; count < 50000; count++) {
  804160c80b:	be 00 00 00 00       	mov    $0x0,%esi
  __asm __volatile("rdtsc"
  804160c810:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c812:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c816:	89 c7                	mov    %eax,%edi
  804160c818:	48 09 d7             	or     %rdx,%rdi
  804160c81b:	83 c6 01             	add    $0x1,%esi
  804160c81e:	81 fe 50 c3 00 00    	cmp    $0xc350,%esi
  804160c824:	74 08                	je     804160c82e <tsc_calibrate+0xc2>
  __asm __volatile("inb %w1,%0"
  804160c826:	89 ca                	mov    %ecx,%edx
  804160c828:	ec                   	in     (%dx),%al
  804160c829:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c82a:	3c ff                	cmp    $0xff,%al
  804160c82c:	74 e2                	je     804160c810 <tsc_calibrate+0xa4>
  __asm __volatile("rdtsc"
  804160c82e:	0f 31                	rdtsc  
  if (pit_expect_msb(0xff, &tsc, &d1)) {
  804160c830:	83 fe 05             	cmp    $0x5,%esi
  804160c833:	7e a3                	jle    804160c7d8 <tsc_calibrate+0x6c>
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c835:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c839:	89 c0                	mov    %eax,%eax
  804160c83b:	48 09 c2             	or     %rax,%rdx
  804160c83e:	49 89 d2             	mov    %rdx,%r10
  *deltap = read_tsc() - tsc;
  804160c841:	49 89 d6             	mov    %rdx,%r14
  804160c844:	49 29 fe             	sub    %rdi,%r14
  804160c847:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160c84c:	41 bc 01 00 00 00    	mov    $0x1,%r12d
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160c852:	44 88 65 cf          	mov    %r12b,-0x31(%rbp)
  __asm __volatile("inb %w1,%0"
  804160c856:	89 ca                	mov    %ecx,%edx
  804160c858:	ec                   	in     (%dx),%al
  804160c859:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c85a:	38 c3                	cmp    %al,%bl
  804160c85c:	0f 85 5a ff ff ff    	jne    804160c7bc <tsc_calibrate+0x50>
  for (count = 0; count < 50000; count++) {
  804160c862:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  __asm __volatile("rdtsc"
  804160c868:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c86a:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c86e:	89 c0                	mov    %eax,%eax
  804160c870:	48 89 d6             	mov    %rdx,%rsi
  804160c873:	48 09 c6             	or     %rax,%rsi
  804160c876:	41 83 c1 01          	add    $0x1,%r9d
  804160c87a:	41 81 f9 50 c3 00 00 	cmp    $0xc350,%r9d
  804160c881:	74 08                	je     804160c88b <tsc_calibrate+0x11f>
  __asm __volatile("inb %w1,%0"
  804160c883:	89 ca                	mov    %ecx,%edx
  804160c885:	ec                   	in     (%dx),%al
  804160c886:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c887:	38 d8                	cmp    %bl,%al
  804160c889:	74 dd                	je     804160c868 <tsc_calibrate+0xfc>
  __asm __volatile("rdtsc"
  804160c88b:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c88d:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c891:	89 c0                	mov    %eax,%eax
  804160c893:	48 09 c2             	or     %rax,%rdx
  *deltap = read_tsc() - tsc;
  804160c896:	48 29 f2             	sub    %rsi,%rdx
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160c899:	41 83 f9 05          	cmp    $0x5,%r9d
  804160c89d:	0f 8e 35 ff ff ff    	jle    804160c7d8 <tsc_calibrate+0x6c>
      delta -= tsc;
  804160c8a3:	48 29 fe             	sub    %rdi,%rsi
      if (d1 + d2 >= delta >> 11)
  804160c8a6:	4d 8d 04 16          	lea    (%r14,%rdx,1),%r8
  804160c8aa:	48 89 f0             	mov    %rsi,%rax
  804160c8ad:	48 c1 e8 0b          	shr    $0xb,%rax
  804160c8b1:	49 39 c0             	cmp    %rax,%r8
  804160c8b4:	0f 83 11 ff ff ff    	jae    804160c7cb <tsc_calibrate+0x5f>
  804160c8ba:	49 89 d0             	mov    %rdx,%r8
  __asm __volatile("inb %w1,%0"
  804160c8bd:	89 ca                	mov    %ecx,%edx
  804160c8bf:	ec                   	in     (%dx),%al
  804160c8c0:	ec                   	in     (%dx),%al
      if (!pit_verify_msb(0xfe - i))
  804160c8c1:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  804160c8c6:	2a 55 cf             	sub    -0x31(%rbp),%dl
  804160c8c9:	38 c2                	cmp    %al,%dl
  804160c8cb:	0f 85 07 ff ff ff    	jne    804160c7d8 <tsc_calibrate+0x6c>
  delta += (long)(d2 - d1) / 2;
  804160c8d1:	4c 29 d7             	sub    %r10,%rdi
  804160c8d4:	49 01 f8             	add    %rdi,%r8
  804160c8d7:	4c 89 c7             	mov    %r8,%rdi
  804160c8da:	48 c1 ef 3f          	shr    $0x3f,%rdi
  804160c8de:	49 01 f8             	add    %rdi,%r8
  804160c8e1:	49 d1 f8             	sar    %r8
  804160c8e4:	4c 01 c6             	add    %r8,%rsi
  delta *= PIT_TICK_RATE;
  804160c8e7:	48 69 f6 de 34 12 00 	imul   $0x1234de,%rsi,%rsi
  delta /= i * 256 * 1000;
  804160c8ee:	45 69 e4 00 e8 03 00 	imul   $0x3e800,%r12d,%r12d
  804160c8f5:	4d 63 e4             	movslq %r12d,%r12
  804160c8f8:	48 89 f0             	mov    %rsi,%rax
  804160c8fb:	ba 00 00 00 00       	mov    $0x0,%edx
  804160c900:	49 f7 f4             	div    %r12
      if ((cpu_freq = quick_pit_calibrate()))
  804160c903:	4c 39 e6             	cmp    %r12,%rsi
  804160c906:	0f 82 cc fe ff ff    	jb     804160c7d8 <tsc_calibrate+0x6c>
  804160c90c:	48 a3 20 5a 88 41 80 	movabs %rax,0x8041885a20
  804160c913:	00 00 00 
        break;
    }
    if (i == TIMES) {
  804160c916:	41 83 fb 64          	cmp    $0x64,%r11d
  804160c91a:	74 20                	je     804160c93c <tsc_calibrate+0x1d0>
      cpu_freq = DEFAULT_FREQ;
      cprintf("Can't calibrate pit timer. Using default frequency\n");
    }
  }

  return cpu_freq * 1000;
  804160c91c:	48 a1 20 5a 88 41 80 	movabs 0x8041885a20,%rax
  804160c923:	00 00 00 
  804160c926:	48 69 c0 e8 03 00 00 	imul   $0x3e8,%rax,%rax
}
  804160c92d:	48 83 c4 28          	add    $0x28,%rsp
  804160c931:	5b                   	pop    %rbx
  804160c932:	41 5c                	pop    %r12
  804160c934:	41 5d                	pop    %r13
  804160c936:	41 5e                	pop    %r14
  804160c938:	41 5f                	pop    %r15
  804160c93a:	5d                   	pop    %rbp
  804160c93b:	c3                   	retq   
      cpu_freq = DEFAULT_FREQ;
  804160c93c:	48 b8 20 5a 88 41 80 	movabs $0x8041885a20,%rax
  804160c943:	00 00 00 
  804160c946:	48 c7 00 a0 25 26 00 	movq   $0x2625a0,(%rax)
      cprintf("Can't calibrate pit timer. Using default frequency\n");
  804160c94d:	48 bf 50 f0 60 41 80 	movabs $0x804160f050,%rdi
  804160c954:	00 00 00 
  804160c957:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c95c:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160c963:	00 00 00 
  804160c966:	ff d2                	callq  *%rdx
  804160c968:	eb b2                	jmp    804160c91c <tsc_calibrate+0x1b0>

000000804160c96a <print_time>:

void
print_time(unsigned seconds) {
  804160c96a:	55                   	push   %rbp
  804160c96b:	48 89 e5             	mov    %rsp,%rbp
  804160c96e:	89 fe                	mov    %edi,%esi
  cprintf("%u\n", seconds);
  804160c970:	48 bf 88 f0 60 41 80 	movabs $0x804160f088,%rdi
  804160c977:	00 00 00 
  804160c97a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c97f:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160c986:	00 00 00 
  804160c989:	ff d2                	callq  *%rdx
}
  804160c98b:	5d                   	pop    %rbp
  804160c98c:	c3                   	retq   

000000804160c98d <print_timer_error>:

void
print_timer_error(void) {
  804160c98d:	55                   	push   %rbp
  804160c98e:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Timer Error\n");
  804160c991:	48 bf 8c f0 60 41 80 	movabs $0x804160f08c,%rdi
  804160c998:	00 00 00 
  804160c99b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c9a0:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160c9a7:	00 00 00 
  804160c9aa:	ff d2                	callq  *%rdx
}
  804160c9ac:	5d                   	pop    %rbp
  804160c9ad:	c3                   	retq   

000000804160c9ae <timer_start>:
static int timer_id       = -1;
static uint64_t timer     = 0;
static uint64_t freq      = 0;

void
timer_start(const char *name) {
  804160c9ae:	55                   	push   %rbp
  804160c9af:	48 89 e5             	mov    %rsp,%rbp
  804160c9b2:	41 56                	push   %r14
  804160c9b4:	41 55                	push   %r13
  804160c9b6:	41 54                	push   %r12
  804160c9b8:	53                   	push   %rbx
  804160c9b9:	49 89 fe             	mov    %rdi,%r14
  (void) timer_id;
  (void) timer;
  // DELETED in LAB 5 end

  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c9bc:	49 bc 80 5a 88 41 80 	movabs $0x8041885a80,%r12
  804160c9c3:	00 00 00 
  804160c9c6:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c9cb:	49 bd fa c3 60 41 80 	movabs $0x804160c3fa,%r13
  804160c9d2:	00 00 00 
  804160c9d5:	eb 0c                	jmp    804160c9e3 <timer_start+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c9d7:	83 c3 01             	add    $0x1,%ebx
  804160c9da:	49 83 c4 28          	add    $0x28,%r12
  804160c9de:	83 fb 05             	cmp    $0x5,%ebx
  804160c9e1:	74 61                	je     804160ca44 <timer_start+0x96>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c9e3:	49 8b 3c 24          	mov    (%r12),%rdi
  804160c9e7:	48 85 ff             	test   %rdi,%rdi
  804160c9ea:	74 eb                	je     804160c9d7 <timer_start+0x29>
  804160c9ec:	4c 89 f6             	mov    %r14,%rsi
  804160c9ef:	41 ff d5             	callq  *%r13
  804160c9f2:	85 c0                	test   %eax,%eax
  804160c9f4:	75 e1                	jne    804160c9d7 <timer_start+0x29>
      timer_id = i;
  804160c9f6:	89 d8                	mov    %ebx,%eax
  804160c9f8:	a3 c0 08 62 41 80 00 	movabs %eax,0x80416208c0
  804160c9ff:	00 00 
      timer_started = 1;
  804160ca01:	48 b8 38 5a 88 41 80 	movabs $0x8041885a38,%rax
  804160ca08:	00 00 00 
  804160ca0b:	c6 00 01             	movb   $0x1,(%rax)
  __asm __volatile("rdtsc"
  804160ca0e:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ca10:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ca14:	89 c0                	mov    %eax,%eax
  804160ca16:	48 09 d0             	or     %rdx,%rax
  804160ca19:	48 a3 30 5a 88 41 80 	movabs %rax,0x8041885a30
  804160ca20:	00 00 00 
      timer = read_tsc();
      freq = timertab[timer_id].get_cpu_freq();
  804160ca23:	48 63 db             	movslq %ebx,%rbx
  804160ca26:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160ca2a:	48 b8 80 5a 88 41 80 	movabs $0x8041885a80,%rax
  804160ca31:	00 00 00 
  804160ca34:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160ca38:	48 a3 28 5a 88 41 80 	movabs %rax,0x8041885a28
  804160ca3f:	00 00 00 
      return;
  804160ca42:	eb 1b                	jmp    804160ca5f <timer_start+0xb1>
    }
  }

  cprintf("Timer Error\n");
  804160ca44:	48 bf 8c f0 60 41 80 	movabs $0x804160f08c,%rdi
  804160ca4b:	00 00 00 
  804160ca4e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ca53:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160ca5a:	00 00 00 
  804160ca5d:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160ca5f:	5b                   	pop    %rbx
  804160ca60:	41 5c                	pop    %r12
  804160ca62:	41 5d                	pop    %r13
  804160ca64:	41 5e                	pop    %r14
  804160ca66:	5d                   	pop    %rbp
  804160ca67:	c3                   	retq   

000000804160ca68 <timer_stop>:

void
timer_stop(void) {
  804160ca68:	55                   	push   %rbp
  804160ca69:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  if (!timer_started || timer_id < 0) {
  804160ca6c:	48 b8 38 5a 88 41 80 	movabs $0x8041885a38,%rax
  804160ca73:	00 00 00 
  804160ca76:	80 38 00             	cmpb   $0x0,(%rax)
  804160ca79:	74 69                	je     804160cae4 <timer_stop+0x7c>
  804160ca7b:	48 b8 c0 08 62 41 80 	movabs $0x80416208c0,%rax
  804160ca82:	00 00 00 
  804160ca85:	83 38 00             	cmpl   $0x0,(%rax)
  804160ca88:	78 5a                	js     804160cae4 <timer_stop+0x7c>
  __asm __volatile("rdtsc"
  804160ca8a:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ca8c:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ca90:	89 c0                	mov    %eax,%eax
  804160ca92:	48 09 c2             	or     %rax,%rdx
    print_timer_error();
    return;
  }

  print_time((read_tsc() - timer) / freq);
  804160ca95:	48 b8 30 5a 88 41 80 	movabs $0x8041885a30,%rax
  804160ca9c:	00 00 00 
  804160ca9f:	48 2b 10             	sub    (%rax),%rdx
  804160caa2:	48 89 d0             	mov    %rdx,%rax
  804160caa5:	48 b9 28 5a 88 41 80 	movabs $0x8041885a28,%rcx
  804160caac:	00 00 00 
  804160caaf:	ba 00 00 00 00       	mov    $0x0,%edx
  804160cab4:	48 f7 31             	divq   (%rcx)
  804160cab7:	89 c7                	mov    %eax,%edi
  804160cab9:	48 b8 6a c9 60 41 80 	movabs $0x804160c96a,%rax
  804160cac0:	00 00 00 
  804160cac3:	ff d0                	callq  *%rax

  timer_id = -1;
  804160cac5:	48 b8 c0 08 62 41 80 	movabs $0x80416208c0,%rax
  804160cacc:	00 00 00 
  804160cacf:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%rax)
  timer_started = 0;
  804160cad5:	48 b8 38 5a 88 41 80 	movabs $0x8041885a38,%rax
  804160cadc:	00 00 00 
  804160cadf:	c6 00 00             	movb   $0x0,(%rax)
  804160cae2:	eb 0c                	jmp    804160caf0 <timer_stop+0x88>
    print_timer_error();
  804160cae4:	48 b8 8d c9 60 41 80 	movabs $0x804160c98d,%rax
  804160caeb:	00 00 00 
  804160caee:	ff d0                	callq  *%rax
  // LAB 5 code end
}
  804160caf0:	5d                   	pop    %rbp
  804160caf1:	c3                   	retq   

000000804160caf2 <timer_cpu_frequency>:

void
timer_cpu_frequency(const char *name) {
  804160caf2:	55                   	push   %rbp
  804160caf3:	48 89 e5             	mov    %rsp,%rbp
  804160caf6:	41 56                	push   %r14
  804160caf8:	41 55                	push   %r13
  804160cafa:	41 54                	push   %r12
  804160cafc:	53                   	push   %rbx
  804160cafd:	49 89 fe             	mov    %rdi,%r14
  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160cb00:	49 bc 80 5a 88 41 80 	movabs $0x8041885a80,%r12
  804160cb07:	00 00 00 
  804160cb0a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160cb0f:	49 bd fa c3 60 41 80 	movabs $0x804160c3fa,%r13
  804160cb16:	00 00 00 
  804160cb19:	eb 0c                	jmp    804160cb27 <timer_cpu_frequency+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160cb1b:	83 c3 01             	add    $0x1,%ebx
  804160cb1e:	49 83 c4 28          	add    $0x28,%r12
  804160cb22:	83 fb 05             	cmp    $0x5,%ebx
  804160cb25:	74 48                	je     804160cb6f <timer_cpu_frequency+0x7d>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160cb27:	49 8b 3c 24          	mov    (%r12),%rdi
  804160cb2b:	48 85 ff             	test   %rdi,%rdi
  804160cb2e:	74 eb                	je     804160cb1b <timer_cpu_frequency+0x29>
  804160cb30:	4c 89 f6             	mov    %r14,%rsi
  804160cb33:	41 ff d5             	callq  *%r13
  804160cb36:	85 c0                	test   %eax,%eax
  804160cb38:	75 e1                	jne    804160cb1b <timer_cpu_frequency+0x29>
      cprintf("%lu\n", timertab[i].get_cpu_freq());
  804160cb3a:	48 63 db             	movslq %ebx,%rbx
  804160cb3d:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160cb41:	48 b8 80 5a 88 41 80 	movabs $0x8041885a80,%rax
  804160cb48:	00 00 00 
  804160cb4b:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160cb4f:	48 89 c6             	mov    %rax,%rsi
  804160cb52:	48 bf 29 d3 60 41 80 	movabs $0x804160d329,%rdi
  804160cb59:	00 00 00 
  804160cb5c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160cb61:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160cb68:	00 00 00 
  804160cb6b:	ff d2                	callq  *%rdx
      return;
  804160cb6d:	eb 1b                	jmp    804160cb8a <timer_cpu_frequency+0x98>
    }
  }
  cprintf("Timer Error\n");
  804160cb6f:	48 bf 8c f0 60 41 80 	movabs $0x804160f08c,%rdi
  804160cb76:	00 00 00 
  804160cb79:	b8 00 00 00 00       	mov    $0x0,%eax
  804160cb7e:	48 ba 0d 92 60 41 80 	movabs $0x804160920d,%rdx
  804160cb85:	00 00 00 
  804160cb88:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160cb8a:	5b                   	pop    %rbx
  804160cb8b:	41 5c                	pop    %r12
  804160cb8d:	41 5d                	pop    %r13
  804160cb8f:	41 5e                	pop    %r14
  804160cb91:	5d                   	pop    %rbp
  804160cb92:	c3                   	retq   

000000804160cb93 <efi_call_in_32bit_mode>:
efi_call_in_32bit_mode(uint32_t func,
                       efi_registers *efi_reg,
                       void *stack_contents,
                       size_t stack_contents_size, /* 16-byte multiple */
                       uint32_t *efi_status) {
  if (func == 0) {
  804160cb93:	85 ff                	test   %edi,%edi
  804160cb95:	74 50                	je     804160cbe7 <efi_call_in_32bit_mode+0x54>
    return -E_INVAL;
  }

  if ((efi_reg == NULL) || (stack_contents == NULL) || (stack_contents_size % 16 != 0)) {
  804160cb97:	48 85 f6             	test   %rsi,%rsi
  804160cb9a:	74 51                	je     804160cbed <efi_call_in_32bit_mode+0x5a>
  804160cb9c:	48 85 d2             	test   %rdx,%rdx
  804160cb9f:	74 4c                	je     804160cbed <efi_call_in_32bit_mode+0x5a>
  804160cba1:	f6 c1 0f             	test   $0xf,%cl
  804160cba4:	75 4d                	jne    804160cbf3 <efi_call_in_32bit_mode+0x60>
                       uint32_t *efi_status) {
  804160cba6:	55                   	push   %rbp
  804160cba7:	48 89 e5             	mov    %rsp,%rbp
  804160cbaa:	41 54                	push   %r12
  804160cbac:	53                   	push   %rbx
  804160cbad:	4d 89 c4             	mov    %r8,%r12
  804160cbb0:	48 89 f3             	mov    %rsi,%rbx
    return -E_INVAL;
  }

  //We need to set up kernel data segments for 32 bit mode
  //before calling asm.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD32));
  804160cbb3:	b8 20 00 00 00       	mov    $0x20,%eax
  804160cbb8:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD32));
  804160cbba:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD32));
  804160cbbc:	8e d0                	mov    %eax,%ss
  _efi_call_in_32bit_mode_asm(func,
  804160cbbe:	48 b8 fa cb 60 41 80 	movabs $0x804160cbfa,%rax
  804160cbc5:	00 00 00 
  804160cbc8:	ff d0                	callq  *%rax
                              efi_reg,
                              stack_contents,
                              stack_contents_size);
  //Restore 64 bit kernel data segments.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  804160cbca:	b8 10 00 00 00       	mov    $0x10,%eax
  804160cbcf:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  804160cbd1:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  804160cbd3:	8e d0                	mov    %eax,%ss

  *efi_status = (uint32_t)efi_reg->rax;
  804160cbd5:	48 8b 43 20          	mov    0x20(%rbx),%rax
  804160cbd9:	41 89 04 24          	mov    %eax,(%r12)

  return 0;
  804160cbdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160cbe2:	5b                   	pop    %rbx
  804160cbe3:	41 5c                	pop    %r12
  804160cbe5:	5d                   	pop    %rbp
  804160cbe6:	c3                   	retq   
    return -E_INVAL;
  804160cbe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160cbec:	c3                   	retq   
    return -E_INVAL;
  804160cbed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160cbf2:	c3                   	retq   
  804160cbf3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  804160cbf8:	c3                   	retq   
  804160cbf9:	90                   	nop

000000804160cbfa <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  804160cbfa:	55                   	push   %rbp
    movq %rsp, %rbp
  804160cbfb:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  804160cbfe:	53                   	push   %rbx
	push	%r12
  804160cbff:	41 54                	push   %r12
	push	%r13
  804160cc01:	41 55                	push   %r13
	push	%r14
  804160cc03:	41 56                	push   %r14
	push	%r15
  804160cc05:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  804160cc07:	56                   	push   %rsi
	push	%rcx
  804160cc08:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  804160cc09:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  804160cc0a:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  804160cc0d:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

000000804160cc14 <copyloop>:
  804160cc14:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  804160cc18:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  804160cc1c:	49 83 c0 08          	add    $0x8,%r8
  804160cc20:	49 39 c8             	cmp    %rcx,%r8
  804160cc23:	75 ef                	jne    804160cc14 <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  804160cc25:	e8 00 00 00 00       	callq  804160cc2a <copyloop+0x16>
  804160cc2a:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  804160cc31:	00 
  804160cc32:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  804160cc39:	00 
  804160cc3a:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  804160cc3b:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  804160cc3d:	6a 08                	pushq  $0x8
  804160cc3f:	e8 00 00 00 00       	callq  804160cc44 <copyloop+0x30>
  804160cc44:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  804160cc4b:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  804160cc4c:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  804160cc50:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  804160cc54:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  804160cc58:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  804160cc5b:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  804160cc5c:	59                   	pop    %rcx
	pop	%rsi
  804160cc5d:	5e                   	pop    %rsi
	pop	%r15
  804160cc5e:	41 5f                	pop    %r15
	pop	%r14
  804160cc60:	41 5e                	pop    %r14
	pop	%r13
  804160cc62:	41 5d                	pop    %r13
	pop	%r12
  804160cc64:	41 5c                	pop    %r12
	pop	%rbx
  804160cc66:	5b                   	pop    %rbx

	leave
  804160cc67:	c9                   	leaveq 
	ret
  804160cc68:	c3                   	retq   

000000804160cc69 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name) {
  lk->locked = 0;
  804160cc69:	c7 07 00 00 00 00    	movl   $0x0,(%rdi)
#ifdef DEBUG_SPINLOCK
  lk->name = name;
#endif
}
  804160cc6f:	c3                   	retq   

000000804160cc70 <spin_lock>:
  asm volatile("lock; xchgl %0, %1"
  804160cc70:	b8 01 00 00 00       	mov    $0x1,%eax
  804160cc75:	f0 87 07             	lock xchg %eax,(%rdi)
#endif

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
  804160cc78:	85 c0                	test   %eax,%eax
  804160cc7a:	74 10                	je     804160cc8c <spin_lock+0x1c>
  804160cc7c:	ba 01 00 00 00       	mov    $0x1,%edx
    asm volatile("pause");
  804160cc81:	f3 90                	pause  
  804160cc83:	89 d0                	mov    %edx,%eax
  804160cc85:	f0 87 07             	lock xchg %eax,(%rdi)
  while (xchg(&lk->locked, 1) != 0)
  804160cc88:	85 c0                	test   %eax,%eax
  804160cc8a:	75 f5                	jne    804160cc81 <spin_lock+0x11>

    // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  get_caller_pcs(lk->pcs);
#endif
}
  804160cc8c:	c3                   	retq   

000000804160cc8d <spin_unlock>:
  804160cc8d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160cc92:	f0 87 07             	lock xchg %eax,(%rdi)
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
}
  804160cc95:	c3                   	retq   
  804160cc96:	66 90                	xchg   %ax,%ax
