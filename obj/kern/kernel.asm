
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
  8041600001:	48 89 0d f8 ef 01 00 	mov    %rcx,0x1eff8(%rip)        # 804161f000 <bootstacktop>

  # Set the stack pointer.
  leaq bootstacktop(%rip),%rsp
  8041600008:	48 8d 25 f1 ef 01 00 	lea    0x1eff1(%rip),%rsp        # 804161f000 <bootstacktop>

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
  8041600020:	48 bb 60 59 70 41 80 	movabs $0x8041705960,%rbx
  8041600027:	00 00 00 
  804160002a:	48 b8 c0 f7 61 41 80 	movabs $0x804161f7c0,%rax
  8041600031:	00 00 00 
  8041600034:	f3 0f 6f 00          	movdqu (%rax),%xmm0
  8041600038:	0f 11 03             	movups %xmm0,(%rbx)
  804160003b:	f3 0f 6f 48 10       	movdqu 0x10(%rax),%xmm1
  8041600040:	0f 11 4b 10          	movups %xmm1,0x10(%rbx)
  8041600044:	48 8b 40 20          	mov    0x20(%rax),%rax
  8041600048:	48 89 43 20          	mov    %rax,0x20(%rbx)
  timertab[1] = timer_pit;
  804160004c:	48 b8 e0 f8 61 41 80 	movabs $0x804161f8e0,%rax
  8041600053:	00 00 00 
  8041600056:	f3 0f 6f 10          	movdqu (%rax),%xmm2
  804160005a:	0f 11 53 28          	movups %xmm2,0x28(%rbx)
  804160005e:	f3 0f 6f 58 10       	movdqu 0x10(%rax),%xmm3
  8041600063:	0f 11 5b 38          	movups %xmm3,0x38(%rbx)
  8041600067:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160006b:	48 89 43 48          	mov    %rax,0x48(%rbx)
  timertab[2] = timer_acpipm;
  804160006f:	48 b8 00 f8 61 41 80 	movabs $0x804161f800,%rax
  8041600076:	00 00 00 
  8041600079:	f3 0f 6f 20          	movdqu (%rax),%xmm4
  804160007d:	0f 11 63 50          	movups %xmm4,0x50(%rbx)
  8041600081:	f3 0f 6f 68 10       	movdqu 0x10(%rax),%xmm5
  8041600086:	0f 11 6b 60          	movups %xmm5,0x60(%rbx)
  804160008a:	48 8b 40 20          	mov    0x20(%rax),%rax
  804160008e:	48 89 43 70          	mov    %rax,0x70(%rbx)
  timertab[3] = timer_hpet0;
  8041600092:	48 b8 80 f8 61 41 80 	movabs $0x804161f880,%rax
  8041600099:	00 00 00 
  804160009c:	f3 0f 6f 30          	movdqu (%rax),%xmm6
  80416000a0:	0f 11 73 78          	movups %xmm6,0x78(%rbx)
  80416000a4:	f3 0f 6f 78 10       	movdqu 0x10(%rax),%xmm7
  80416000a9:	0f 11 bb 88 00 00 00 	movups %xmm7,0x88(%rbx)
  80416000b0:	48 8b 40 20          	mov    0x20(%rax),%rax
  80416000b4:	48 89 83 98 00 00 00 	mov    %rax,0x98(%rbx)
  timertab[4] = timer_hpet1;
  80416000bb:	48 b8 40 f8 61 41 80 	movabs $0x804161f840,%rax
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
  804160010b:	48 b8 08 f0 61 41 80 	movabs $0x804161f008,%rax
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
  8041600134:	48 a3 08 f0 61 41 80 	movabs %rax,0x804161f008
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
  8041600222:	49 bc 00 f0 61 41 80 	movabs $0x804161f000,%r12
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
  80416002a7:	48 b8 60 41 70 41 80 	movabs $0x8041704160,%rax
  80416002ae:	00 00 00 
  80416002b1:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416002b5:	74 13                	je     80416002ca <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416002b7:	48 bb 47 3f 60 41 80 	movabs $0x8041603f47,%rbx
  80416002be:	00 00 00 
  80416002c1:	bf 00 00 00 00       	mov    $0x0,%edi
  80416002c6:	ff d3                	callq  *%rbx
  while (1)
  80416002c8:	eb f7                	jmp    80416002c1 <_panic+0x67>
  panicstr = fmt;
  80416002ca:	4c 89 e0             	mov    %r12,%rax
  80416002cd:	48 a3 60 41 70 41 80 	movabs %rax,0x8041704160
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
  804160030b:	48 bf a0 bc 60 41 80 	movabs $0x804160bca0,%rdi
  8041600312:	00 00 00 
  8041600315:	b8 00 00 00 00       	mov    $0x0,%eax
  804160031a:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  8041600321:	00 00 00 
  8041600324:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600326:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160032d:	4c 89 e7             	mov    %r12,%rdi
  8041600330:	48 b8 3a 8f 60 41 80 	movabs $0x8041608f3a,%rax
  8041600337:	00 00 00 
  804160033a:	ff d0                	callq  *%rax
  cprintf("\n");
  804160033c:	48 bf 4f d3 60 41 80 	movabs $0x804160d34f,%rdi
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
  8041600360:	49 bc 60 59 70 41 80 	movabs $0x8041705960,%r12
  8041600367:	00 00 00 
  804160036a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
  804160036f:	49 be 00 b4 60 41 80 	movabs $0x804160b400,%r14
  8041600376:	00 00 00 
  8041600379:	eb 3a                	jmp    80416003b5 <timers_schedule+0x63>
        panic("Timer %s does not support interrupts\n", name);
  804160037b:	4c 89 e9             	mov    %r13,%rcx
  804160037e:	48 ba 40 bd 60 41 80 	movabs $0x804160bd40,%rdx
  8041600385:	00 00 00 
  8041600388:	be 2d 00 00 00       	mov    $0x2d,%esi
  804160038d:	48 bf b8 bc 60 41 80 	movabs $0x804160bcb8,%rdi
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
  80416003cf:	48 b8 60 59 70 41 80 	movabs $0x8041705960,%rax
  80416003d6:	00 00 00 
  80416003d9:	48 8b 74 d0 18       	mov    0x18(%rax,%rdx,8),%rsi
  80416003de:	48 85 f6             	test   %rsi,%rsi
  80416003e1:	74 98                	je     804160037b <timers_schedule+0x29>
        timer_for_schedule = &timertab[i];
  80416003e3:	48 89 d1             	mov    %rdx,%rcx
  80416003e6:	48 8d 14 c8          	lea    (%rax,%rcx,8),%rdx
  80416003ea:	48 89 d0             	mov    %rdx,%rax
  80416003ed:	48 a3 40 59 70 41 80 	movabs %rax,0x8041705940
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
  8041600405:	48 ba c4 bc 60 41 80 	movabs $0x804160bcc4,%rdx
  804160040c:	00 00 00 
  804160040f:	be 33 00 00 00       	mov    $0x33,%esi
  8041600414:	48 bf b8 bc 60 41 80 	movabs $0x804160bcb8,%rdi
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
  8041600443:	48 b8 86 0c 60 41 80 	movabs $0x8041600c86,%rax
  804160044a:	00 00 00 
  804160044d:	ff d0                	callq  *%rax
  tsc_calibrate();
  804160044f:	48 b8 72 b7 60 41 80 	movabs $0x804160b772,%rax
  8041600456:	00 00 00 
  8041600459:	ff d0                	callq  *%rax
  cprintf("6828 decimal is %o octal!\n", 6828);
  804160045b:	be ac 1a 00 00       	mov    $0x1aac,%esi
  8041600460:	48 bf dd bc 60 41 80 	movabs $0x804160bcdd,%rdi
  8041600467:	00 00 00 
  804160046a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160046f:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  8041600476:	00 00 00 
  8041600479:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  804160047b:	48 be 00 60 70 41 80 	movabs $0x8041706000,%rsi
  8041600482:	00 00 00 
  8041600485:	48 bf f8 bc 60 41 80 	movabs $0x804160bcf8,%rdi
  804160048c:	00 00 00 
  804160048f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600494:	ff d3                	callq  *%rbx
  mem_init();
  8041600496:	48 b8 b4 52 60 41 80 	movabs $0x80416052b4,%rax
  804160049d:	00 00 00 
  80416004a0:	ff d0                	callq  *%rax
  while (ctor < &__ctors_end) {
  80416004a2:	48 ba 48 41 70 41 80 	movabs $0x8041704148,%rdx
  80416004a9:	00 00 00 
  80416004ac:	48 b8 48 41 70 41 80 	movabs $0x8041704148,%rax
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
  80416004de:	48 b8 50 8e 60 41 80 	movabs $0x8041608e50,%rax
  80416004e5:	00 00 00 
  80416004e8:	ff d0                	callq  *%rax
  rtc_init();
  80416004ea:	48 b8 ca 8c 60 41 80 	movabs $0x8041608cca,%rax
  80416004f1:	00 00 00 
  80416004f4:	ff d0                	callq  *%rax
  timers_init();
  80416004f6:	48 b8 19 00 60 41 80 	movabs $0x8041600019,%rax
  80416004fd:	00 00 00 
  8041600500:	ff d0                	callq  *%rax
  fb_init();
  8041600502:	48 b8 79 0b 60 41 80 	movabs $0x8041600b79,%rax
  8041600509:	00 00 00 
  804160050c:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  804160050e:	48 bf 01 bd 60 41 80 	movabs $0x804160bd01,%rdi
  8041600515:	00 00 00 
  8041600518:	b8 00 00 00 00       	mov    $0x0,%eax
  804160051d:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041600524:	00 00 00 
  8041600527:	ff d2                	callq  *%rdx
  env_init();
  8041600529:	48 b8 50 85 60 41 80 	movabs $0x8041608550,%rax
  8041600530:	00 00 00 
  8041600533:	ff d0                	callq  *%rax
  trap_init();
  8041600535:	48 b8 75 90 60 41 80 	movabs $0x8041609075,%rax
  804160053c:	00 00 00 
  804160053f:	ff d0                	callq  *%rax
  timers_schedule("hpet0");
  8041600541:	48 bf 1a bd 60 41 80 	movabs $0x804160bd1a,%rdi
  8041600548:	00 00 00 
  804160054b:	48 b8 52 03 60 41 80 	movabs $0x8041600352,%rax
  8041600552:	00 00 00 
  8041600555:	ff d0                	callq  *%rax
  clock_idt_init();
  8041600557:	48 b8 87 90 60 41 80 	movabs $0x8041609087,%rax
  804160055e:	00 00 00 
  8041600561:	ff d0                	callq  *%rax
  ENV_CREATE(user_hello, ENV_TYPE_USER);
  8041600563:	be 02 00 00 00       	mov    $0x2,%esi
  8041600568:	48 bf 08 f9 61 41 80 	movabs $0x804161f908,%rdi
  804160056f:	00 00 00 
  8041600572:	48 b8 17 87 60 41 80 	movabs $0x8041608717,%rax
  8041600579:	00 00 00 
  804160057c:	ff d0                	callq  *%rax
  sched_yield();
  804160057e:	48 b8 f4 a4 60 41 80 	movabs $0x804160a4f4,%rax
  8041600585:	00 00 00 
  8041600588:	ff d0                	callq  *%rax

000000804160058a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  804160058a:	55                   	push   %rbp
  804160058b:	48 89 e5             	mov    %rsp,%rbp
  804160058e:	41 54                	push   %r12
  8041600590:	53                   	push   %rbx
  8041600591:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600598:	49 89 d4             	mov    %rdx,%r12
  804160059b:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  80416005a2:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80416005a9:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416005b0:	84 c0                	test   %al,%al
  80416005b2:	74 23                	je     80416005d7 <_warn+0x4d>
  80416005b4:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416005bb:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416005bf:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416005c3:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416005c7:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416005cb:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416005cf:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416005d3:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416005d7:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416005de:	00 00 00 
  80416005e1:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416005e8:	00 00 00 
  80416005eb:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416005ef:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416005f6:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416005fd:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  8041600604:	89 f2                	mov    %esi,%edx
  8041600606:	48 89 fe             	mov    %rdi,%rsi
  8041600609:	48 bf 20 bd 60 41 80 	movabs $0x804160bd20,%rdi
  8041600610:	00 00 00 
  8041600613:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600618:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  804160061f:	00 00 00 
  8041600622:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600624:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160062b:	4c 89 e7             	mov    %r12,%rdi
  804160062e:	48 b8 3a 8f 60 41 80 	movabs $0x8041608f3a,%rax
  8041600635:	00 00 00 
  8041600638:	ff d0                	callq  *%rax
  cprintf("\n");
  804160063a:	48 bf 4f d3 60 41 80 	movabs $0x804160d34f,%rdi
  8041600641:	00 00 00 
  8041600644:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600649:	ff d3                	callq  *%rbx
  va_end(ap);
}
  804160064b:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  8041600652:	5b                   	pop    %rbx
  8041600653:	41 5c                	pop    %r12
  8041600655:	5d                   	pop    %rbp
  8041600656:	c3                   	retq   

0000008041600657 <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  8041600657:	ba fd 03 00 00       	mov    $0x3fd,%edx
  804160065c:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  804160065d:	a8 01                	test   $0x1,%al
  804160065f:	74 0a                	je     804160066b <serial_proc_data+0x14>
  8041600661:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600666:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  8041600667:	0f b6 c0             	movzbl %al,%eax
  804160066a:	c3                   	retq   
    return -1;
  804160066b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  8041600670:	c3                   	retq   

0000008041600671 <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  8041600671:	55                   	push   %rbp
  8041600672:	48 89 e5             	mov    %rsp,%rbp
  8041600675:	41 54                	push   %r12
  8041600677:	53                   	push   %rbx
  8041600678:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  804160067b:	48 bb a0 41 70 41 80 	movabs $0x80417041a0,%rbx
  8041600682:	00 00 00 
  while ((c = (*proc)()) != -1) {
  8041600685:	41 ff d4             	callq  *%r12
  8041600688:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160068b:	74 28                	je     80416006b5 <cons_intr+0x44>
    if (c == 0)
  804160068d:	85 c0                	test   %eax,%eax
  804160068f:	74 f4                	je     8041600685 <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  8041600691:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  8041600697:	8d 51 01             	lea    0x1(%rcx),%edx
  804160069a:	89 c9                	mov    %ecx,%ecx
  804160069c:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  804160069f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  80416006a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416006aa:	0f 44 d0             	cmove  %eax,%edx
  80416006ad:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  80416006b3:	eb d0                	jmp    8041600685 <cons_intr+0x14>
  }
}
  80416006b5:	5b                   	pop    %rbx
  80416006b6:	41 5c                	pop    %r12
  80416006b8:	5d                   	pop    %rbp
  80416006b9:	c3                   	retq   

00000080416006ba <kbd_proc_data>:
kbd_proc_data(void) {
  80416006ba:	55                   	push   %rbp
  80416006bb:	48 89 e5             	mov    %rsp,%rbp
  80416006be:	53                   	push   %rbx
  80416006bf:	48 83 ec 08          	sub    $0x8,%rsp
  80416006c3:	ba 64 00 00 00       	mov    $0x64,%edx
  80416006c8:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416006c9:	a8 01                	test   $0x1,%al
  80416006cb:	0f 84 31 01 00 00    	je     8041600802 <kbd_proc_data+0x148>
  80416006d1:	ba 60 00 00 00       	mov    $0x60,%edx
  80416006d6:	ec                   	in     (%dx),%al
  80416006d7:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416006d9:	3c e0                	cmp    $0xe0,%al
  80416006db:	0f 84 84 00 00 00    	je     8041600765 <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  80416006e1:	84 c0                	test   %al,%al
  80416006e3:	0f 88 97 00 00 00    	js     8041600780 <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  80416006e9:	48 bf 80 41 70 41 80 	movabs $0x8041704180,%rdi
  80416006f0:	00 00 00 
  80416006f3:	8b 0f                	mov    (%rdi),%ecx
  80416006f5:	f6 c1 40             	test   $0x40,%cl
  80416006f8:	74 0c                	je     8041600706 <kbd_proc_data+0x4c>
    data |= 0x80;
  80416006fa:	83 c8 80             	or     $0xffffff80,%eax
  80416006fd:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416006ff:	89 c8                	mov    %ecx,%eax
  8041600701:	83 e0 bf             	and    $0xffffffbf,%eax
  8041600704:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  8041600706:	0f b6 f2             	movzbl %dl,%esi
  8041600709:	48 b8 c0 be 60 41 80 	movabs $0x804160bec0,%rax
  8041600710:	00 00 00 
  8041600713:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  8041600717:	48 b9 80 41 70 41 80 	movabs $0x8041704180,%rcx
  804160071e:	00 00 00 
  8041600721:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  8041600723:	48 bf c0 bd 60 41 80 	movabs $0x804160bdc0,%rdi
  804160072a:	00 00 00 
  804160072d:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  8041600731:	31 f0                	xor    %esi,%eax
  8041600733:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  8041600735:	89 c6                	mov    %eax,%esi
  8041600737:	83 e6 03             	and    $0x3,%esi
  804160073a:	0f b6 d2             	movzbl %dl,%edx
  804160073d:	48 b9 a0 bd 60 41 80 	movabs $0x804160bda0,%rcx
  8041600744:	00 00 00 
  8041600747:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  804160074b:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  804160074f:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  8041600752:	a8 08                	test   $0x8,%al
  8041600754:	74 73                	je     80416007c9 <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  8041600756:	89 da                	mov    %ebx,%edx
  8041600758:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  804160075b:	83 f9 19             	cmp    $0x19,%ecx
  804160075e:	77 5d                	ja     80416007bd <kbd_proc_data+0x103>
      c += 'A' - 'a';
  8041600760:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8041600763:	eb 12                	jmp    8041600777 <kbd_proc_data+0xbd>
    shift |= E0ESC;
  8041600765:	48 b8 80 41 70 41 80 	movabs $0x8041704180,%rax
  804160076c:	00 00 00 
  804160076f:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  8041600772:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8041600777:	89 d8                	mov    %ebx,%eax
  8041600779:	48 83 c4 08          	add    $0x8,%rsp
  804160077d:	5b                   	pop    %rbx
  804160077e:	5d                   	pop    %rbp
  804160077f:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600780:	48 bf 80 41 70 41 80 	movabs $0x8041704180,%rdi
  8041600787:	00 00 00 
  804160078a:	8b 0f                	mov    (%rdi),%ecx
  804160078c:	89 ce                	mov    %ecx,%esi
  804160078e:	83 e6 40             	and    $0x40,%esi
  8041600791:	83 e0 7f             	and    $0x7f,%eax
  8041600794:	85 f6                	test   %esi,%esi
  8041600796:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  8041600799:	0f b6 d2             	movzbl %dl,%edx
  804160079c:	48 b8 c0 be 60 41 80 	movabs $0x804160bec0,%rax
  80416007a3:	00 00 00 
  80416007a6:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  80416007aa:	83 c8 40             	or     $0x40,%eax
  80416007ad:	0f b6 c0             	movzbl %al,%eax
  80416007b0:	f7 d0                	not    %eax
  80416007b2:	21 c8                	and    %ecx,%eax
  80416007b4:	89 07                	mov    %eax,(%rdi)
    return 0;
  80416007b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416007bb:	eb ba                	jmp    8041600777 <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  80416007bd:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416007c0:	8d 4b 20             	lea    0x20(%rbx),%ecx
  80416007c3:	83 fa 1a             	cmp    $0x1a,%edx
  80416007c6:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416007c9:	f7 d0                	not    %eax
  80416007cb:	a8 06                	test   $0x6,%al
  80416007cd:	75 a8                	jne    8041600777 <kbd_proc_data+0xbd>
  80416007cf:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  80416007d5:	75 a0                	jne    8041600777 <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  80416007d7:	48 bf 66 bd 60 41 80 	movabs $0x804160bd66,%rdi
  80416007de:	00 00 00 
  80416007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416007e6:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416007ed:	00 00 00 
  80416007f0:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416007f2:	b8 03 00 00 00       	mov    $0x3,%eax
  80416007f7:	ba 92 00 00 00       	mov    $0x92,%edx
  80416007fc:	ee                   	out    %al,(%dx)
  80416007fd:	e9 75 ff ff ff       	jmpq   8041600777 <kbd_proc_data+0xbd>
    return -1;
  8041600802:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8041600807:	e9 6b ff ff ff       	jmpq   8041600777 <kbd_proc_data+0xbd>

000000804160080c <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160080c:	48 b8 b4 43 70 41 80 	movabs $0x80417043b4,%rax
  8041600813:	00 00 00 
  8041600816:	44 8b 10             	mov    (%rax),%r10d
  8041600819:	41 0f af d2          	imul   %r10d,%edx
  804160081d:	01 f2                	add    %esi,%edx
  804160081f:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  8041600826:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  8041600827:	4d 0f be c0          	movsbq %r8b,%r8
  804160082b:	48 b8 20 f3 61 41 80 	movabs $0x804161f320,%rax
  8041600832:	00 00 00 
  8041600835:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  8041600839:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  804160083d:	eb 25                	jmp    8041600864 <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  804160083f:	83 c0 01             	add    $0x1,%eax
  8041600842:	83 f8 08             	cmp    $0x8,%eax
  8041600845:	74 11                	je     8041600858 <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  8041600847:	0f be 16             	movsbl (%rsi),%edx
  804160084a:	0f a3 c2             	bt     %eax,%edx
  804160084d:	73 f0                	jae    804160083f <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160084f:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  8041600853:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  8041600856:	eb e7                	jmp    804160083f <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  8041600858:	45 01 d1             	add    %r10d,%r9d
  804160085b:	48 83 c6 01          	add    $0x1,%rsi
  804160085f:	4c 39 c6             	cmp    %r8,%rsi
  8041600862:	74 07                	je     804160086b <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  8041600864:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600869:	eb dc                	jmp    8041600847 <draw_char+0x3b>
}
  804160086b:	c3                   	retq   

000000804160086c <cons_putc>:
  __asm __volatile("inb %w1,%0"
  804160086c:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600871:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600872:	a8 20                	test   $0x20,%al
  8041600874:	75 29                	jne    804160089f <cons_putc+0x33>
  for (i = 0;
  8041600876:	be 00 00 00 00       	mov    $0x0,%esi
  804160087b:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600880:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  8041600886:	89 ca                	mov    %ecx,%edx
  8041600888:	ec                   	in     (%dx),%al
  8041600889:	ec                   	in     (%dx),%al
  804160088a:	ec                   	in     (%dx),%al
  804160088b:	ec                   	in     (%dx),%al
       i++)
  804160088c:	83 c6 01             	add    $0x1,%esi
  804160088f:	44 89 c2             	mov    %r8d,%edx
  8041600892:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600893:	a8 20                	test   $0x20,%al
  8041600895:	75 08                	jne    804160089f <cons_putc+0x33>
  8041600897:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  804160089d:	7e e7                	jle    8041600886 <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  804160089f:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  80416008a2:	ba f8 03 00 00       	mov    $0x3f8,%edx
  80416008a7:	89 f8                	mov    %edi,%eax
  80416008a9:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416008aa:	ba 79 03 00 00       	mov    $0x379,%edx
  80416008af:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  80416008b0:	84 c0                	test   %al,%al
  80416008b2:	78 29                	js     80416008dd <cons_putc+0x71>
  80416008b4:	be 00 00 00 00       	mov    $0x0,%esi
  80416008b9:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416008be:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  80416008c4:	89 ca                	mov    %ecx,%edx
  80416008c6:	ec                   	in     (%dx),%al
  80416008c7:	ec                   	in     (%dx),%al
  80416008c8:	ec                   	in     (%dx),%al
  80416008c9:	ec                   	in     (%dx),%al
  80416008ca:	83 c6 01             	add    $0x1,%esi
  80416008cd:	44 89 ca             	mov    %r9d,%edx
  80416008d0:	ec                   	in     (%dx),%al
  80416008d1:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416008d7:	7f 04                	jg     80416008dd <cons_putc+0x71>
  80416008d9:	84 c0                	test   %al,%al
  80416008db:	79 e7                	jns    80416008c4 <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416008dd:	ba 78 03 00 00       	mov    $0x378,%edx
  80416008e2:	44 89 c0             	mov    %r8d,%eax
  80416008e5:	ee                   	out    %al,(%dx)
  80416008e6:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416008eb:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416008f0:	ee                   	out    %al,(%dx)
  80416008f1:	b8 08 00 00 00       	mov    $0x8,%eax
  80416008f6:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416008f7:	48 b8 bc 43 70 41 80 	movabs $0x80417043bc,%rax
  80416008fe:	00 00 00 
  8041600901:	80 38 00             	cmpb   $0x0,(%rax)
  8041600904:	0f 84 42 02 00 00    	je     8041600b4c <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  804160090a:	55                   	push   %rbp
  804160090b:	48 89 e5             	mov    %rsp,%rbp
  804160090e:	41 54                	push   %r12
  8041600910:	53                   	push   %rbx
  if (!(c & ~0xFF))
  8041600911:	89 fa                	mov    %edi,%edx
  8041600913:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  8041600919:	89 f8                	mov    %edi,%eax
  804160091b:	80 cc 07             	or     $0x7,%ah
  804160091e:	85 d2                	test   %edx,%edx
  8041600920:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  8041600923:	40 0f b6 c7          	movzbl %dil,%eax
  8041600927:	83 f8 09             	cmp    $0x9,%eax
  804160092a:	0f 84 e1 00 00 00    	je     8041600a11 <cons_putc+0x1a5>
  8041600930:	7e 5c                	jle    804160098e <cons_putc+0x122>
  8041600932:	83 f8 0a             	cmp    $0xa,%eax
  8041600935:	0f 84 b8 00 00 00    	je     80416009f3 <cons_putc+0x187>
  804160093b:	83 f8 0d             	cmp    $0xd,%eax
  804160093e:	0f 85 ff 00 00 00    	jne    8041600a43 <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  8041600944:	48 be a8 43 70 41 80 	movabs $0x80417043a8,%rsi
  804160094b:	00 00 00 
  804160094e:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600951:	0f b7 c1             	movzwl %cx,%eax
  8041600954:	48 bb b0 43 70 41 80 	movabs $0x80417043b0,%rbx
  804160095b:	00 00 00 
  804160095e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600963:	f7 33                	divl   (%rbx)
  8041600965:	29 d1                	sub    %edx,%ecx
  8041600967:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  804160096a:	48 b8 a8 43 70 41 80 	movabs $0x80417043a8,%rax
  8041600971:	00 00 00 
  8041600974:	0f b7 10             	movzwl (%rax),%edx
  8041600977:	48 b8 ac 43 70 41 80 	movabs $0x80417043ac,%rax
  804160097e:	00 00 00 
  8041600981:	3b 10                	cmp    (%rax),%edx
  8041600983:	0f 83 0f 01 00 00    	jae    8041600a98 <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  8041600989:	5b                   	pop    %rbx
  804160098a:	41 5c                	pop    %r12
  804160098c:	5d                   	pop    %rbp
  804160098d:	c3                   	retq   
  switch (c & 0xff) {
  804160098e:	83 f8 08             	cmp    $0x8,%eax
  8041600991:	0f 85 ac 00 00 00    	jne    8041600a43 <cons_putc+0x1d7>
      if (crt_pos > 0) {
  8041600997:	66 a1 a8 43 70 41 80 	movabs 0x80417043a8,%ax
  804160099e:	00 00 00 
  80416009a1:	66 85 c0             	test   %ax,%ax
  80416009a4:	74 c4                	je     804160096a <cons_putc+0xfe>
        crt_pos--;
  80416009a6:	83 e8 01             	sub    $0x1,%eax
  80416009a9:	66 a3 a8 43 70 41 80 	movabs %ax,0x80417043a8
  80416009b0:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  80416009b3:	0f b7 c0             	movzwl %ax,%eax
  80416009b6:	48 bb b0 43 70 41 80 	movabs $0x80417043b0,%rbx
  80416009bd:	00 00 00 
  80416009c0:	8b 1b                	mov    (%rbx),%ebx
  80416009c2:	ba 00 00 00 00       	mov    $0x0,%edx
  80416009c7:	f7 f3                	div    %ebx
  80416009c9:	89 d6                	mov    %edx,%esi
  80416009cb:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416009d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416009d6:	89 c2                	mov    %eax,%edx
  80416009d8:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  80416009df:	00 00 00 
  80416009e2:	48 b8 0c 08 60 41 80 	movabs $0x804160080c,%rax
  80416009e9:	00 00 00 
  80416009ec:	ff d0                	callq  *%rax
  80416009ee:	e9 77 ff ff ff       	jmpq   804160096a <cons_putc+0xfe>
      crt_pos += crt_cols;
  80416009f3:	48 b8 a8 43 70 41 80 	movabs $0x80417043a8,%rax
  80416009fa:	00 00 00 
  80416009fd:	48 bb b0 43 70 41 80 	movabs $0x80417043b0,%rbx
  8041600a04:	00 00 00 
  8041600a07:	8b 13                	mov    (%rbx),%edx
  8041600a09:	66 01 10             	add    %dx,(%rax)
  8041600a0c:	e9 33 ff ff ff       	jmpq   8041600944 <cons_putc+0xd8>
      cons_putc(' ');
  8041600a11:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a16:	48 bb 6c 08 60 41 80 	movabs $0x804160086c,%rbx
  8041600a1d:	00 00 00 
  8041600a20:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a22:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a27:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a29:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a2e:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a30:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a35:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a37:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a3c:	ff d3                	callq  *%rbx
      break;
  8041600a3e:	e9 27 ff ff ff       	jmpq   804160096a <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600a43:	49 bc a8 43 70 41 80 	movabs $0x80417043a8,%r12
  8041600a4a:	00 00 00 
  8041600a4d:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600a52:	0f b7 c3             	movzwl %bx,%eax
  8041600a55:	48 be b0 43 70 41 80 	movabs $0x80417043b0,%rsi
  8041600a5c:	00 00 00 
  8041600a5f:	8b 36                	mov    (%rsi),%esi
  8041600a61:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600a66:	f7 f6                	div    %esi
  8041600a68:	89 d6                	mov    %edx,%esi
  8041600a6a:	44 0f be c7          	movsbl %dil,%r8d
  8041600a6e:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600a73:	89 c2                	mov    %eax,%edx
  8041600a75:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600a7c:	00 00 00 
  8041600a7f:	48 b8 0c 08 60 41 80 	movabs $0x804160080c,%rax
  8041600a86:	00 00 00 
  8041600a89:	ff d0                	callq  *%rax
      crt_pos++;
  8041600a8b:	83 c3 01             	add    $0x1,%ebx
  8041600a8e:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  8041600a93:	e9 d2 fe ff ff       	jmpq   804160096a <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600a98:	48 bb b4 43 70 41 80 	movabs $0x80417043b4,%rbx
  8041600a9f:	00 00 00 
  8041600aa2:	8b 03                	mov    (%rbx),%eax
  8041600aa4:	49 bc b8 43 70 41 80 	movabs $0x80417043b8,%r12
  8041600aab:	00 00 00 
  8041600aae:	41 8b 3c 24          	mov    (%r12),%edi
  8041600ab2:	8d 57 f8             	lea    -0x8(%rdi),%edx
  8041600ab5:	0f af d0             	imul   %eax,%edx
  8041600ab8:	48 c1 e2 02          	shl    $0x2,%rdx
  8041600abc:	c1 e0 03             	shl    $0x3,%eax
  8041600abf:	89 c0                	mov    %eax,%eax
  8041600ac1:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600ac8:	00 00 00 
  8041600acb:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  8041600acf:	48 b8 fc b4 60 41 80 	movabs $0x804160b4fc,%rax
  8041600ad6:	00 00 00 
  8041600ad9:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600adb:	41 8b 04 24          	mov    (%r12),%eax
  8041600adf:	8b 0b                	mov    (%rbx),%ecx
  8041600ae1:	89 c6                	mov    %eax,%esi
  8041600ae3:	83 e6 f8             	and    $0xfffffff8,%esi
  8041600ae6:	83 ee 08             	sub    $0x8,%esi
  8041600ae9:	0f af f1             	imul   %ecx,%esi
  8041600aec:	0f af c8             	imul   %eax,%ecx
  8041600aef:	39 f1                	cmp    %esi,%ecx
  8041600af1:	76 3b                	jbe    8041600b2e <cons_putc+0x2c2>
  8041600af3:	48 63 fe             	movslq %esi,%rdi
  8041600af6:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  8041600afd:	00 00 00 
  8041600b00:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  8041600b04:	8d 51 ff             	lea    -0x1(%rcx),%edx
  8041600b07:	89 d1                	mov    %edx,%ecx
  8041600b09:	29 f1                	sub    %esi,%ecx
  8041600b0b:	48 ba 01 b8 b0 0f 20 	movabs $0x200fb0b801,%rdx
  8041600b12:	00 00 00 
  8041600b15:	48 01 fa             	add    %rdi,%rdx
  8041600b18:	48 01 ca             	add    %rcx,%rdx
  8041600b1b:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600b1f:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600b25:	48 83 c0 04          	add    $0x4,%rax
  8041600b29:	48 39 c2             	cmp    %rax,%rdx
  8041600b2c:	75 f1                	jne    8041600b1f <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600b2e:	48 b8 a8 43 70 41 80 	movabs $0x80417043a8,%rax
  8041600b35:	00 00 00 
  8041600b38:	48 bb b0 43 70 41 80 	movabs $0x80417043b0,%rbx
  8041600b3f:	00 00 00 
  8041600b42:	8b 13                	mov    (%rbx),%edx
  8041600b44:	66 29 10             	sub    %dx,(%rax)
}
  8041600b47:	e9 3d fe ff ff       	jmpq   8041600989 <cons_putc+0x11d>
  8041600b4c:	c3                   	retq   

0000008041600b4d <serial_intr>:
  if (serial_exists)
  8041600b4d:	48 b8 aa 43 70 41 80 	movabs $0x80417043aa,%rax
  8041600b54:	00 00 00 
  8041600b57:	80 38 00             	cmpb   $0x0,(%rax)
  8041600b5a:	75 01                	jne    8041600b5d <serial_intr+0x10>
  8041600b5c:	c3                   	retq   
serial_intr(void) {
  8041600b5d:	55                   	push   %rbp
  8041600b5e:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600b61:	48 bf 57 06 60 41 80 	movabs $0x8041600657,%rdi
  8041600b68:	00 00 00 
  8041600b6b:	48 b8 71 06 60 41 80 	movabs $0x8041600671,%rax
  8041600b72:	00 00 00 
  8041600b75:	ff d0                	callq  *%rax
}
  8041600b77:	5d                   	pop    %rbp
  8041600b78:	c3                   	retq   

0000008041600b79 <fb_init>:
fb_init(void) {
  8041600b79:	55                   	push   %rbp
  8041600b7a:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600b7d:	48 b8 00 f0 61 41 80 	movabs $0x804161f000,%rax
  8041600b84:	00 00 00 
  8041600b87:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600b8a:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600b8d:	89 d0                	mov    %edx,%eax
  8041600b8f:	a3 b8 43 70 41 80 00 	movabs %eax,0x80417043b8
  8041600b96:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600b98:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600b9b:	a3 b4 43 70 41 80 00 	movabs %eax,0x80417043b4
  8041600ba2:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600ba4:	c1 e8 03             	shr    $0x3,%eax
  8041600ba7:	89 c6                	mov    %eax,%esi
  8041600ba9:	a3 b0 43 70 41 80 00 	movabs %eax,0x80417043b0
  8041600bb0:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600bb2:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600bb5:	0f af d0             	imul   %eax,%edx
  8041600bb8:	89 d0                	mov    %edx,%eax
  8041600bba:	a3 ac 43 70 41 80 00 	movabs %eax,0x80417043ac
  8041600bc1:	00 00 
  crt_pos           = crt_cols;
  8041600bc3:	89 f0                	mov    %esi,%eax
  8041600bc5:	66 a3 a8 43 70 41 80 	movabs %ax,0x80417043a8
  8041600bcc:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600bcf:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600bd2:	be 00 00 00 00       	mov    $0x0,%esi
  8041600bd7:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600bde:	00 00 00 
  8041600be1:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041600be8:	00 00 00 
  8041600beb:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600bed:	48 b8 bc 43 70 41 80 	movabs $0x80417043bc,%rax
  8041600bf4:	00 00 00 
  8041600bf7:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600bfa:	5d                   	pop    %rbp
  8041600bfb:	c3                   	retq   

0000008041600bfc <kbd_intr>:
kbd_intr(void) {
  8041600bfc:	55                   	push   %rbp
  8041600bfd:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600c00:	48 bf ba 06 60 41 80 	movabs $0x80416006ba,%rdi
  8041600c07:	00 00 00 
  8041600c0a:	48 b8 71 06 60 41 80 	movabs $0x8041600671,%rax
  8041600c11:	00 00 00 
  8041600c14:	ff d0                	callq  *%rax
}
  8041600c16:	5d                   	pop    %rbp
  8041600c17:	c3                   	retq   

0000008041600c18 <cons_getc>:
cons_getc(void) {
  8041600c18:	55                   	push   %rbp
  8041600c19:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600c1c:	48 b8 4d 0b 60 41 80 	movabs $0x8041600b4d,%rax
  8041600c23:	00 00 00 
  8041600c26:	ff d0                	callq  *%rax
  kbd_intr();
  8041600c28:	48 b8 fc 0b 60 41 80 	movabs $0x8041600bfc,%rax
  8041600c2f:	00 00 00 
  8041600c32:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600c34:	48 b9 a0 41 70 41 80 	movabs $0x80417041a0,%rcx
  8041600c3b:	00 00 00 
  8041600c3e:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600c44:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600c49:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600c4f:	74 21                	je     8041600c72 <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600c51:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600c54:	48 b8 a0 41 70 41 80 	movabs $0x80417041a0,%rax
  8041600c5b:	00 00 00 
  8041600c5e:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600c64:	89 d2                	mov    %edx,%edx
  8041600c66:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600c6a:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600c70:	74 02                	je     8041600c74 <cons_getc+0x5c>
}
  8041600c72:	5d                   	pop    %rbp
  8041600c73:	c3                   	retq   
      cons.rpos = 0;
  8041600c74:	48 be a0 43 70 41 80 	movabs $0x80417043a0,%rsi
  8041600c7b:	00 00 00 
  8041600c7e:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600c84:	eb ec                	jmp    8041600c72 <cons_getc+0x5a>

0000008041600c86 <cons_init>:
  8041600c86:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600c8b:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600c90:	89 c8                	mov    %ecx,%eax
  8041600c92:	89 fa                	mov    %edi,%edx
  8041600c94:	ee                   	out    %al,(%dx)
  8041600c95:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600c9b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600ca0:	44 89 ca             	mov    %r9d,%edx
  8041600ca3:	ee                   	out    %al,(%dx)
  8041600ca4:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600ca9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600cae:	89 f2                	mov    %esi,%edx
  8041600cb0:	ee                   	out    %al,(%dx)
  8041600cb1:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600cb7:	89 c8                	mov    %ecx,%eax
  8041600cb9:	44 89 c2             	mov    %r8d,%edx
  8041600cbc:	ee                   	out    %al,(%dx)
  8041600cbd:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600cc2:	44 89 ca             	mov    %r9d,%edx
  8041600cc5:	ee                   	out    %al,(%dx)
  8041600cc6:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600ccb:	89 c8                	mov    %ecx,%eax
  8041600ccd:	ee                   	out    %al,(%dx)
  8041600cce:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600cd3:	44 89 c2             	mov    %r8d,%edx
  8041600cd6:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600cd7:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600cdc:	ec                   	in     (%dx),%al
  8041600cdd:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600cdf:	3c ff                	cmp    $0xff,%al
  8041600ce1:	0f 95 c0             	setne  %al
  8041600ce4:	a2 aa 43 70 41 80 00 	movabs %al,0x80417043aa
  8041600ceb:	00 00 
  8041600ced:	89 fa                	mov    %edi,%edx
  8041600cef:	ec                   	in     (%dx),%al
  8041600cf0:	89 f2                	mov    %esi,%edx
  8041600cf2:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600cf3:	80 f9 ff             	cmp    $0xff,%cl
  8041600cf6:	74 01                	je     8041600cf9 <cons_init+0x73>
  8041600cf8:	c3                   	retq   
cons_init(void) {
  8041600cf9:	55                   	push   %rbp
  8041600cfa:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600cfd:	48 bf 72 bd 60 41 80 	movabs $0x804160bd72,%rdi
  8041600d04:	00 00 00 
  8041600d07:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600d0c:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041600d13:	00 00 00 
  8041600d16:	ff d2                	callq  *%rdx
}
  8041600d18:	5d                   	pop    %rbp
  8041600d19:	c3                   	retq   

0000008041600d1a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600d1a:	55                   	push   %rbp
  8041600d1b:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600d1e:	48 b8 6c 08 60 41 80 	movabs $0x804160086c,%rax
  8041600d25:	00 00 00 
  8041600d28:	ff d0                	callq  *%rax
}
  8041600d2a:	5d                   	pop    %rbp
  8041600d2b:	c3                   	retq   

0000008041600d2c <getchar>:

int
getchar(void) {
  8041600d2c:	55                   	push   %rbp
  8041600d2d:	48 89 e5             	mov    %rsp,%rbp
  8041600d30:	53                   	push   %rbx
  8041600d31:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600d35:	48 bb 18 0c 60 41 80 	movabs $0x8041600c18,%rbx
  8041600d3c:	00 00 00 
  8041600d3f:	ff d3                	callq  *%rbx
  8041600d41:	85 c0                	test   %eax,%eax
  8041600d43:	74 fa                	je     8041600d3f <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600d45:	48 83 c4 08          	add    $0x8,%rsp
  8041600d49:	5b                   	pop    %rbx
  8041600d4a:	5d                   	pop    %rbp
  8041600d4b:	c3                   	retq   

0000008041600d4c <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600d51:	c3                   	retq   

0000008041600d52 <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600d52:	55                   	push   %rbp
  8041600d53:	48 89 e5             	mov    %rsp,%rbp
  8041600d56:	41 56                	push   %r14
  8041600d58:	41 55                	push   %r13
  8041600d5a:	41 54                	push   %r12
  8041600d5c:	53                   	push   %rbx
  8041600d5d:	48 83 ec 20          	sub    $0x20,%rsp
  8041600d61:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600d65:	83 fe 20             	cmp    $0x20,%esi
  8041600d68:	0f 87 42 09 00 00    	ja     80416016b0 <dwarf_read_abbrev_entry+0x95e>
  8041600d6e:	44 89 c3             	mov    %r8d,%ebx
  8041600d71:	41 89 cd             	mov    %ecx,%r13d
  8041600d74:	49 89 d4             	mov    %rdx,%r12
  8041600d77:	89 f6                	mov    %esi,%esi
  8041600d79:	48 b8 78 c0 60 41 80 	movabs $0x804160c078,%rax
  8041600d80:	00 00 00 
  8041600d83:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600d86:	48 85 d2             	test   %rdx,%rdx
  8041600d89:	74 6f                	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
  8041600d8b:	83 f9 07             	cmp    $0x7,%ecx
  8041600d8e:	76 6a                	jbe    8041600dfa <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600d90:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600d95:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d99:	4c 89 e7             	mov    %r12,%rdi
  8041600d9c:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600da3:	00 00 00 
  8041600da6:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600da8:	eb 50                	jmp    8041600dfa <dwarf_read_abbrev_entry+0xa8>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB2 code

      unsigned length = get_unaligned(entry, uint16_t);
  8041600daa:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600daf:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600db3:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600db7:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600dbe:	00 00 00 
  8041600dc1:	ff d0                	callq  *%rax
  8041600dc3:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(uint16_t);
  8041600dc7:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600dcb:	48 83 c0 02          	add    $0x2,%rax
  8041600dcf:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600dd3:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600dd7:	89 5d d8             	mov    %ebx,-0x28(%rbp)
          .mem = entry,
          .len = length,
      };
      if (buf) {
  8041600dda:	4d 85 e4             	test   %r12,%r12
  8041600ddd:	74 18                	je     8041600df7 <dwarf_read_abbrev_entry+0xa5>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600ddf:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600de4:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600de8:	4c 89 e7             	mov    %r12,%rdi
  8041600deb:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600df2:	00 00 00 
  8041600df5:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(uint16_t) + length;
  8041600df7:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600dfa:	89 d8                	mov    %ebx,%eax
  8041600dfc:	48 83 c4 20          	add    $0x20,%rsp
  8041600e00:	5b                   	pop    %rbx
  8041600e01:	41 5c                	pop    %r12
  8041600e03:	41 5d                	pop    %r13
  8041600e05:	41 5e                	pop    %r14
  8041600e07:	5d                   	pop    %rbp
  8041600e08:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600e09:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600e0e:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e12:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e16:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600e1d:	00 00 00 
  8041600e20:	ff d0                	callq  *%rax
  8041600e22:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600e25:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600e29:	48 83 c0 04          	add    $0x4,%rax
  8041600e2d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600e31:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600e35:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600e38:	4d 85 e4             	test   %r12,%r12
  8041600e3b:	74 18                	je     8041600e55 <dwarf_read_abbrev_entry+0x103>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600e3d:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600e42:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e46:	4c 89 e7             	mov    %r12,%rdi
  8041600e49:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600e50:	00 00 00 
  8041600e53:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600e55:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600e58:	eb a0                	jmp    8041600dfa <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600e5a:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e5f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e63:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e67:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600e6e:	00 00 00 
  8041600e71:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600e73:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600e78:	4d 85 e4             	test   %r12,%r12
  8041600e7b:	74 06                	je     8041600e83 <dwarf_read_abbrev_entry+0x131>
  8041600e7d:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600e81:	77 0a                	ja     8041600e8d <dwarf_read_abbrev_entry+0x13b>
      bytes = sizeof(Dwarf_Half);
  8041600e83:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600e88:	e9 6d ff ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600e8d:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e92:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e96:	4c 89 e7             	mov    %r12,%rdi
  8041600e99:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600ea0:	00 00 00 
  8041600ea3:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600ea5:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600eaa:	e9 4b ff ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600eaf:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600eb4:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600eb8:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ebc:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600ec3:	00 00 00 
  8041600ec6:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600ec8:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600ecd:	4d 85 e4             	test   %r12,%r12
  8041600ed0:	74 06                	je     8041600ed8 <dwarf_read_abbrev_entry+0x186>
  8041600ed2:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600ed6:	77 0a                	ja     8041600ee2 <dwarf_read_abbrev_entry+0x190>
      bytes = sizeof(uint32_t);
  8041600ed8:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600edd:	e9 18 ff ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  8041600ee2:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ee7:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600eeb:	4c 89 e7             	mov    %r12,%rdi
  8041600eee:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600ef5:	00 00 00 
  8041600ef8:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600efa:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600eff:	e9 f6 fe ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600f04:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f09:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f0d:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f11:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600f18:	00 00 00 
  8041600f1b:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600f1d:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600f22:	4d 85 e4             	test   %r12,%r12
  8041600f25:	74 06                	je     8041600f2d <dwarf_read_abbrev_entry+0x1db>
  8041600f27:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600f2b:	77 0a                	ja     8041600f37 <dwarf_read_abbrev_entry+0x1e5>
      bytes = sizeof(uint64_t);
  8041600f2d:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600f32:	e9 c3 fe ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041600f37:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f3c:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f40:	4c 89 e7             	mov    %r12,%rdi
  8041600f43:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600f4a:	00 00 00 
  8041600f4d:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600f4f:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600f54:	e9 a1 fe ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      if (buf && bufsize >= sizeof(char *)) {
  8041600f59:	48 85 d2             	test   %rdx,%rdx
  8041600f5c:	74 05                	je     8041600f63 <dwarf_read_abbrev_entry+0x211>
  8041600f5e:	83 f9 07             	cmp    $0x7,%ecx
  8041600f61:	77 18                	ja     8041600f7b <dwarf_read_abbrev_entry+0x229>
      bytes = strlen(entry) + 1;
  8041600f63:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600f67:	48 b8 f1 b2 60 41 80 	movabs $0x804160b2f1,%rax
  8041600f6e:	00 00 00 
  8041600f71:	ff d0                	callq  *%rax
  8041600f73:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600f76:	e9 7f fe ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &entry, sizeof(char *));
  8041600f7b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f80:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600f84:	4c 89 e7             	mov    %r12,%rdi
  8041600f87:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600f8e:	00 00 00 
  8041600f91:	ff d0                	callq  *%rax
  8041600f93:	eb ce                	jmp    8041600f63 <dwarf_read_abbrev_entry+0x211>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600f95:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600f99:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600f9c:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600fa1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600fa6:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600fab:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600fae:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600fb2:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600fb5:	89 f0                	mov    %esi,%eax
  8041600fb7:	83 e0 7f             	and    $0x7f,%eax
  8041600fba:	d3 e0                	shl    %cl,%eax
  8041600fbc:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600fbe:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600fc1:	40 84 f6             	test   %sil,%sil
  8041600fc4:	78 e5                	js     8041600fab <dwarf_read_abbrev_entry+0x259>
      break;
  }

  *ret = result;

  return count;
  8041600fc6:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600fc9:	4d 01 e8             	add    %r13,%r8
  8041600fcc:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600fd0:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600fd4:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600fd7:	4d 85 e4             	test   %r12,%r12
  8041600fda:	74 18                	je     8041600ff4 <dwarf_read_abbrev_entry+0x2a2>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600fdc:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600fe1:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600fe5:	4c 89 e7             	mov    %r12,%rdi
  8041600fe8:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041600fef:	00 00 00 
  8041600ff2:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600ff4:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600ff7:	e9 fe fd ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600ffc:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601001:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601005:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601009:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601010:	00 00 00 
  8041601013:	ff d0                	callq  *%rax
  8041601015:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041601019:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160101d:	48 83 c0 01          	add    $0x1,%rax
  8041601021:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041601025:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041601029:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  804160102c:	4d 85 e4             	test   %r12,%r12
  804160102f:	74 18                	je     8041601049 <dwarf_read_abbrev_entry+0x2f7>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041601031:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601036:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160103a:	4c 89 e7             	mov    %r12,%rdi
  804160103d:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601044:	00 00 00 
  8041601047:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041601049:	83 c3 01             	add    $0x1,%ebx
    } break;
  804160104c:	e9 a9 fd ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601051:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601056:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160105a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160105e:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601065:	00 00 00 
  8041601068:	ff d0                	callq  *%rax
  804160106a:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160106e:	4d 85 e4             	test   %r12,%r12
  8041601071:	0f 84 43 06 00 00    	je     80416016ba <dwarf_read_abbrev_entry+0x968>
  8041601077:	45 85 ed             	test   %r13d,%r13d
  804160107a:	0f 84 3a 06 00 00    	je     80416016ba <dwarf_read_abbrev_entry+0x968>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601080:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601084:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601089:	e9 6c fd ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      bool data = get_unaligned(entry, Dwarf_Small);
  804160108e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601093:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601097:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160109b:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416010a2:	00 00 00 
  80416010a5:	ff d0                	callq  *%rax
  80416010a7:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  80416010ab:	4d 85 e4             	test   %r12,%r12
  80416010ae:	0f 84 10 06 00 00    	je     80416016c4 <dwarf_read_abbrev_entry+0x972>
  80416010b4:	45 85 ed             	test   %r13d,%r13d
  80416010b7:	0f 84 07 06 00 00    	je     80416016c4 <dwarf_read_abbrev_entry+0x972>
      bool data = get_unaligned(entry, Dwarf_Small);
  80416010bd:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  80416010bf:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  80416010c4:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  80416010c9:	e9 2c fd ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      int count = dwarf_read_leb128(entry, &data);
  80416010ce:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416010d2:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  80416010d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416010da:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416010df:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  80416010e4:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416010e7:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  80416010eb:	89 f0                	mov    %esi,%eax
  80416010ed:	83 e0 7f             	and    $0x7f,%eax
  80416010f0:	d3 e0                	shl    %cl,%eax
  80416010f2:	09 c7                	or     %eax,%edi
    shift += 7;
  80416010f4:	83 c1 07             	add    $0x7,%ecx
    count++;
  80416010f7:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  80416010fa:	40 84 f6             	test   %sil,%sil
  80416010fd:	78 e5                	js     80416010e4 <dwarf_read_abbrev_entry+0x392>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  80416010ff:	83 f9 1f             	cmp    $0x1f,%ecx
  8041601102:	7f 0f                	jg     8041601113 <dwarf_read_abbrev_entry+0x3c1>
  8041601104:	40 f6 c6 40          	test   $0x40,%sil
  8041601108:	74 09                	je     8041601113 <dwarf_read_abbrev_entry+0x3c1>
    result |= (-1U << shift);
  804160110a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160110f:	d3 e0                	shl    %cl,%eax
  8041601111:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  8041601113:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601116:	49 01 c0             	add    %rax,%r8
  8041601119:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  804160111d:	4d 85 e4             	test   %r12,%r12
  8041601120:	0f 84 d4 fc ff ff    	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
  8041601126:	41 83 fd 03          	cmp    $0x3,%r13d
  804160112a:	0f 86 ca fc ff ff    	jbe    8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (int *)buf);
  8041601130:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601133:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601138:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160113c:	4c 89 e7             	mov    %r12,%rdi
  804160113f:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601146:	00 00 00 
  8041601149:	ff d0                	callq  *%rax
  804160114b:	e9 aa fc ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601150:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601154:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601159:	4c 89 f6             	mov    %r14,%rsi
  804160115c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601160:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601167:	00 00 00 
  804160116a:	ff d0                	callq  *%rax
  804160116c:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160116f:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601171:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601176:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601179:	76 2a                	jbe    80416011a5 <dwarf_read_abbrev_entry+0x453>
    if (initial_len == DW_EXT_DWARF64) {
  804160117b:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160117e:	74 60                	je     80416011e0 <dwarf_read_abbrev_entry+0x48e>
      cprintf("Unknown DWARF extension\n");
  8041601180:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  8041601187:	00 00 00 
  804160118a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160118f:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041601196:	00 00 00 
  8041601199:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  804160119b:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416011a0:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416011a5:	48 63 c3             	movslq %ebx,%rax
  80416011a8:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416011ac:	4d 85 e4             	test   %r12,%r12
  80416011af:	0f 84 45 fc ff ff    	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
  80416011b5:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011b9:	0f 86 3b fc ff ff    	jbe    8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416011bf:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416011c3:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011c8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011cc:	4c 89 e7             	mov    %r12,%rdi
  80416011cf:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416011d6:	00 00 00 
  80416011d9:	ff d0                	callq  *%rax
  80416011db:	e9 1a fc ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416011e0:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416011e4:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011e9:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416011ed:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416011f4:	00 00 00 
  80416011f7:	ff d0                	callq  *%rax
  80416011f9:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416011fd:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601202:	eb a1                	jmp    80416011a5 <dwarf_read_abbrev_entry+0x453>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601204:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601208:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  804160120b:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601210:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601215:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  804160121a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160121d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601221:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601224:	89 f0                	mov    %esi,%eax
  8041601226:	83 e0 7f             	and    $0x7f,%eax
  8041601229:	d3 e0                	shl    %cl,%eax
  804160122b:	09 c7                	or     %eax,%edi
    shift += 7;
  804160122d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601230:	40 84 f6             	test   %sil,%sil
  8041601233:	78 e5                	js     804160121a <dwarf_read_abbrev_entry+0x4c8>
  return count;
  8041601235:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601238:	49 01 c0             	add    %rax,%r8
  804160123b:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160123f:	4d 85 e4             	test   %r12,%r12
  8041601242:	0f 84 b2 fb ff ff    	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
  8041601248:	41 83 fd 03          	cmp    $0x3,%r13d
  804160124c:	0f 86 a8 fb ff ff    	jbe    8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  8041601252:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601255:	ba 04 00 00 00       	mov    $0x4,%edx
  804160125a:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160125e:	4c 89 e7             	mov    %r12,%rdi
  8041601261:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601268:	00 00 00 
  804160126b:	ff d0                	callq  *%rax
  804160126d:	e9 88 fb ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  8041601272:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601276:	ba 04 00 00 00       	mov    $0x4,%edx
  804160127b:	4c 89 f6             	mov    %r14,%rsi
  804160127e:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601282:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601289:	00 00 00 
  804160128c:	ff d0                	callq  *%rax
  804160128e:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601291:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601293:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601298:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160129b:	76 2a                	jbe    80416012c7 <dwarf_read_abbrev_entry+0x575>
    if (initial_len == DW_EXT_DWARF64) {
  804160129d:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416012a0:	74 60                	je     8041601302 <dwarf_read_abbrev_entry+0x5b0>
      cprintf("Unknown DWARF extension\n");
  80416012a2:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  80416012a9:	00 00 00 
  80416012ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80416012b1:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416012b8:	00 00 00 
  80416012bb:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416012bd:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416012c2:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416012c7:	48 63 c3             	movslq %ebx,%rax
  80416012ca:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416012ce:	4d 85 e4             	test   %r12,%r12
  80416012d1:	0f 84 23 fb ff ff    	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
  80416012d7:	41 83 fd 07          	cmp    $0x7,%r13d
  80416012db:	0f 86 19 fb ff ff    	jbe    8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416012e1:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416012e5:	ba 08 00 00 00       	mov    $0x8,%edx
  80416012ea:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012ee:	4c 89 e7             	mov    %r12,%rdi
  80416012f1:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416012f8:	00 00 00 
  80416012fb:	ff d0                	callq  *%rax
  80416012fd:	e9 f8 fa ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601302:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601306:	ba 08 00 00 00       	mov    $0x8,%edx
  804160130b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160130f:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601316:	00 00 00 
  8041601319:	ff d0                	callq  *%rax
  804160131b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  804160131f:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601324:	eb a1                	jmp    80416012c7 <dwarf_read_abbrev_entry+0x575>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601326:	ba 01 00 00 00       	mov    $0x1,%edx
  804160132b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160132f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601333:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160133a:	00 00 00 
  804160133d:	ff d0                	callq  *%rax
  804160133f:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601343:	4d 85 e4             	test   %r12,%r12
  8041601346:	0f 84 82 03 00 00    	je     80416016ce <dwarf_read_abbrev_entry+0x97c>
  804160134c:	45 85 ed             	test   %r13d,%r13d
  804160134f:	0f 84 79 03 00 00    	je     80416016ce <dwarf_read_abbrev_entry+0x97c>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601355:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601359:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  804160135e:	e9 97 fa ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041601363:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601368:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160136c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601370:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601377:	00 00 00 
  804160137a:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  804160137c:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041601381:	4d 85 e4             	test   %r12,%r12
  8041601384:	74 06                	je     804160138c <dwarf_read_abbrev_entry+0x63a>
  8041601386:	41 83 fd 01          	cmp    $0x1,%r13d
  804160138a:	77 0a                	ja     8041601396 <dwarf_read_abbrev_entry+0x644>
      bytes = sizeof(Dwarf_Half);
  804160138c:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041601391:	e9 64 fa ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041601396:	ba 02 00 00 00       	mov    $0x2,%edx
  804160139b:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160139f:	4c 89 e7             	mov    %r12,%rdi
  80416013a2:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416013a9:	00 00 00 
  80416013ac:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  80416013ae:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  80416013b3:	e9 42 fa ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416013b8:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013bd:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013c1:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416013c5:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416013cc:	00 00 00 
  80416013cf:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416013d1:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416013d6:	4d 85 e4             	test   %r12,%r12
  80416013d9:	74 06                	je     80416013e1 <dwarf_read_abbrev_entry+0x68f>
  80416013db:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013df:	77 0a                	ja     80416013eb <dwarf_read_abbrev_entry+0x699>
      bytes = sizeof(uint32_t);
  80416013e1:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416013e6:	e9 0f fa ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  80416013eb:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013f0:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013f4:	4c 89 e7             	mov    %r12,%rdi
  80416013f7:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416013fe:	00 00 00 
  8041601401:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041601403:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041601408:	e9 ed f9 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  804160140d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601412:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601416:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160141a:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601421:	00 00 00 
  8041601424:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601426:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  804160142b:	4d 85 e4             	test   %r12,%r12
  804160142e:	74 06                	je     8041601436 <dwarf_read_abbrev_entry+0x6e4>
  8041601430:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601434:	77 0a                	ja     8041601440 <dwarf_read_abbrev_entry+0x6ee>
      bytes = sizeof(uint64_t);
  8041601436:	bb 08 00 00 00       	mov    $0x8,%ebx
  804160143b:	e9 ba f9 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041601440:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601445:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601449:	4c 89 e7             	mov    %r12,%rdi
  804160144c:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601453:	00 00 00 
  8041601456:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601458:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  804160145d:	e9 98 f9 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601462:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601466:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601469:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160146e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601473:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601478:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160147b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160147f:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601482:	89 f0                	mov    %esi,%eax
  8041601484:	83 e0 7f             	and    $0x7f,%eax
  8041601487:	d3 e0                	shl    %cl,%eax
  8041601489:	09 c7                	or     %eax,%edi
    shift += 7;
  804160148b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160148e:	40 84 f6             	test   %sil,%sil
  8041601491:	78 e5                	js     8041601478 <dwarf_read_abbrev_entry+0x726>
  return count;
  8041601493:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601496:	49 01 c0             	add    %rax,%r8
  8041601499:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160149d:	4d 85 e4             	test   %r12,%r12
  80416014a0:	0f 84 54 f9 ff ff    	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
  80416014a6:	41 83 fd 03          	cmp    $0x3,%r13d
  80416014aa:	0f 86 4a f9 ff ff    	jbe    8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  80416014b0:	89 7d d0             	mov    %edi,-0x30(%rbp)
  80416014b3:	ba 04 00 00 00       	mov    $0x4,%edx
  80416014b8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416014bc:	4c 89 e7             	mov    %r12,%rdi
  80416014bf:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416014c6:	00 00 00 
  80416014c9:	ff d0                	callq  *%rax
  80416014cb:	e9 2a f9 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &form);
  80416014d0:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416014d4:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416014d7:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416014dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014e2:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416014e7:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416014eb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416014ef:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416014f3:	44 89 c0             	mov    %r8d,%eax
  80416014f6:	83 e0 7f             	and    $0x7f,%eax
  80416014f9:	d3 e0                	shl    %cl,%eax
  80416014fb:	09 c6                	or     %eax,%esi
    shift += 7;
  80416014fd:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601500:	45 84 c0             	test   %r8b,%r8b
  8041601503:	78 e2                	js     80416014e7 <dwarf_read_abbrev_entry+0x795>
  return count;
  8041601505:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  8041601508:	48 01 c7             	add    %rax,%rdi
  804160150b:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  804160150f:	41 89 d8             	mov    %ebx,%r8d
  8041601512:	44 89 e9             	mov    %r13d,%ecx
  8041601515:	4c 89 e2             	mov    %r12,%rdx
  8041601518:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  804160151f:	00 00 00 
  8041601522:	ff d0                	callq  *%rax
      bytes    = count + read;
  8041601524:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601528:	e9 cd f8 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160152d:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601531:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601536:	4c 89 f6             	mov    %r14,%rsi
  8041601539:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160153d:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601544:	00 00 00 
  8041601547:	ff d0                	callq  *%rax
  8041601549:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160154c:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160154e:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601553:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601556:	76 2a                	jbe    8041601582 <dwarf_read_abbrev_entry+0x830>
    if (initial_len == DW_EXT_DWARF64) {
  8041601558:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160155b:	74 60                	je     80416015bd <dwarf_read_abbrev_entry+0x86b>
      cprintf("Unknown DWARF extension\n");
  804160155d:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  8041601564:	00 00 00 
  8041601567:	b8 00 00 00 00       	mov    $0x0,%eax
  804160156c:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041601573:	00 00 00 
  8041601576:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601578:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160157d:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  8041601582:	48 63 c3             	movslq %ebx,%rax
  8041601585:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601589:	4d 85 e4             	test   %r12,%r12
  804160158c:	0f 84 68 f8 ff ff    	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
  8041601592:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601596:	0f 86 5e f8 ff ff    	jbe    8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  804160159c:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416015a0:	ba 08 00 00 00       	mov    $0x8,%edx
  80416015a5:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416015a9:	4c 89 e7             	mov    %r12,%rdi
  80416015ac:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416015b3:	00 00 00 
  80416015b6:	ff d0                	callq  *%rax
  80416015b8:	e9 3d f8 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416015bd:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416015c1:	ba 08 00 00 00       	mov    $0x8,%edx
  80416015c6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416015ca:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416015d1:	00 00 00 
  80416015d4:	ff d0                	callq  *%rax
  80416015d6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416015da:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416015df:	eb a1                	jmp    8041601582 <dwarf_read_abbrev_entry+0x830>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416015e1:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416015e5:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416015e8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416015ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416015f3:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416015f8:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416015fb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416015ff:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041601603:	89 f8                	mov    %edi,%eax
  8041601605:	83 e0 7f             	and    $0x7f,%eax
  8041601608:	d3 e0                	shl    %cl,%eax
  804160160a:	09 c3                	or     %eax,%ebx
    shift += 7;
  804160160c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160160f:	40 84 ff             	test   %dil,%dil
  8041601612:	78 e4                	js     80416015f8 <dwarf_read_abbrev_entry+0x8a6>
  return count;
  8041601614:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  8041601617:	4c 01 f6             	add    %r14,%rsi
  804160161a:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  804160161e:	4d 85 e4             	test   %r12,%r12
  8041601621:	74 1a                	je     804160163d <dwarf_read_abbrev_entry+0x8eb>
        memcpy(buf, entry, MIN(length, bufsize));
  8041601623:	41 39 dd             	cmp    %ebx,%r13d
  8041601626:	44 89 ea             	mov    %r13d,%edx
  8041601629:	0f 47 d3             	cmova  %ebx,%edx
  804160162c:	89 d2                	mov    %edx,%edx
  804160162e:	4c 89 e7             	mov    %r12,%rdi
  8041601631:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601638:	00 00 00 
  804160163b:	ff d0                	callq  *%rax
      bytes = count + length;
  804160163d:	44 01 f3             	add    %r14d,%ebx
    } break;
  8041601640:	e9 b5 f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      bytes = 0;
  8041601645:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  804160164a:	48 85 d2             	test   %rdx,%rdx
  804160164d:	0f 84 a7 f7 ff ff    	je     8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(true, (bool *)buf);
  8041601653:	c6 02 01             	movb   $0x1,(%rdx)
  8041601656:	e9 9f f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  804160165b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601660:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601664:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601668:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160166f:	00 00 00 
  8041601672:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601674:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601679:	4d 85 e4             	test   %r12,%r12
  804160167c:	74 06                	je     8041601684 <dwarf_read_abbrev_entry+0x932>
  804160167e:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601682:	77 0a                	ja     804160168e <dwarf_read_abbrev_entry+0x93c>
      bytes = sizeof(uint64_t);
  8041601684:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  8041601689:	e9 6c f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  804160168e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601693:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601697:	4c 89 e7             	mov    %r12,%rdi
  804160169a:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416016a1:	00 00 00 
  80416016a4:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  80416016a6:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  80416016ab:	e9 4a f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
  int bytes = 0;
  80416016b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416016b5:	e9 40 f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016ba:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016bf:	e9 36 f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016c4:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016c9:	e9 2c f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016ce:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016d3:	e9 22 f7 ff ff       	jmpq   8041600dfa <dwarf_read_abbrev_entry+0xa8>

00000080416016d8 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416016d8:	55                   	push   %rbp
  80416016d9:	48 89 e5             	mov    %rsp,%rbp
  80416016dc:	41 57                	push   %r15
  80416016de:	41 56                	push   %r14
  80416016e0:	41 55                	push   %r13
  80416016e2:	41 54                	push   %r12
  80416016e4:	53                   	push   %rbx
  80416016e5:	48 83 ec 48          	sub    $0x48,%rsp
  80416016e9:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80416016ed:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416016f1:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  80416016f5:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416016f9:	49 bd 6a b5 60 41 80 	movabs $0x804160b56a,%r13
  8041601700:	00 00 00 
  8041601703:	e9 bb 01 00 00       	jmpq   80416018c3 <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601708:	49 8d 76 20          	lea    0x20(%r14),%rsi
  804160170c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601711:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601715:	41 ff d5             	callq  *%r13
  8041601718:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  804160171c:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601721:	eb 08                	jmp    804160172b <info_by_address+0x53>
    *len = initial_len;
  8041601723:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  8041601726:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  804160172b:	4c 63 fb             	movslq %ebx,%r15
  804160172e:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  8041601732:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  8041601735:	ba 02 00 00 00       	mov    $0x2,%edx
  804160173a:	48 89 de             	mov    %rbx,%rsi
  804160173d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601741:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  8041601744:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  8041601748:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160174d:	75 7a                	jne    80416017c9 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  804160174f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601754:	48 89 de             	mov    %rbx,%rsi
  8041601757:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160175b:	41 ff d5             	callq  *%r13
  804160175e:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041601761:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  8041601764:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  8041601767:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  804160176b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601770:	48 89 de             	mov    %rbx,%rsi
  8041601773:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601777:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  804160177a:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160177e:	75 7e                	jne    80416017fe <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  8041601780:	48 83 c3 02          	add    $0x2,%rbx
  8041601784:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601789:	4c 89 fe             	mov    %r15,%rsi
  804160178c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601790:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  8041601793:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  8041601797:	0f 85 96 00 00 00    	jne    8041601833 <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  804160179d:	48 89 d8             	mov    %rbx,%rax
  80416017a0:	4c 29 f0             	sub    %r14,%rax
  80416017a3:	48 99                	cqto   
  80416017a5:	48 c1 ea 3c          	shr    $0x3c,%rdx
  80416017a9:	48 01 d0             	add    %rdx,%rax
  80416017ac:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  80416017af:	48 29 d0             	sub    %rdx,%rax
  80416017b2:	0f 84 b5 00 00 00    	je     804160186d <info_by_address+0x195>
      set += 2 * address_size - remainder;
  80416017b8:	ba 10 00 00 00       	mov    $0x10,%edx
  80416017bd:	89 d1                	mov    %edx,%ecx
  80416017bf:	29 c1                	sub    %eax,%ecx
  80416017c1:	48 01 cb             	add    %rcx,%rbx
  80416017c4:	e9 a4 00 00 00       	jmpq   804160186d <info_by_address+0x195>
    assert(version == 2);
  80416017c9:	48 b9 3e c0 60 41 80 	movabs $0x804160c03e,%rcx
  80416017d0:	00 00 00 
  80416017d3:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416017da:	00 00 00 
  80416017dd:	be 20 00 00 00       	mov    $0x20,%esi
  80416017e2:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  80416017e9:	00 00 00 
  80416017ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017f1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416017f8:	00 00 00 
  80416017fb:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416017fe:	48 b9 fb bf 60 41 80 	movabs $0x804160bffb,%rcx
  8041601805:	00 00 00 
  8041601808:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160180f:	00 00 00 
  8041601812:	be 24 00 00 00       	mov    $0x24,%esi
  8041601817:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  804160181e:	00 00 00 
  8041601821:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601826:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160182d:	00 00 00 
  8041601830:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  8041601833:	48 b9 0d c0 60 41 80 	movabs $0x804160c00d,%rcx
  804160183a:	00 00 00 
  804160183d:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601844:	00 00 00 
  8041601847:	be 26 00 00 00       	mov    $0x26,%esi
  804160184c:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601853:	00 00 00 
  8041601856:	b8 00 00 00 00       	mov    $0x0,%eax
  804160185b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601862:	00 00 00 
  8041601865:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601868:	4c 39 e3             	cmp    %r12,%rbx
  804160186b:	73 51                	jae    80416018be <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  804160186d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601872:	48 89 de             	mov    %rbx,%rsi
  8041601875:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601879:	41 ff d5             	callq  *%r13
  804160187c:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  8041601880:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  8041601884:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601889:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160188d:	41 ff d5             	callq  *%r13
  8041601890:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  8041601893:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  8041601897:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  804160189b:	4c 39 f1             	cmp    %r14,%rcx
  804160189e:	72 c8                	jb     8041601868 <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  80416018a0:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  80416018a2:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  80416018a5:	48 39 c1             	cmp    %rax,%rcx
  80416018a8:	77 be                	ja     8041601868 <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  80416018aa:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416018ae:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  80416018b1:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  80416018b4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018b9:	e9 5a 04 00 00       	jmpq   8041601d18 <info_by_address+0x640>
      set += address_size;
  80416018be:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  80416018c1:	75 71                	jne    8041601934 <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  80416018c3:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416018c7:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  80416018cb:	73 42                	jae    804160190f <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  80416018cd:	ba 04 00 00 00       	mov    $0x4,%edx
  80416018d2:	4c 89 f6             	mov    %r14,%rsi
  80416018d5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018d9:	41 ff d5             	callq  *%r13
  80416018dc:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416018e0:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  80416018e4:	0f 86 39 fe ff ff    	jbe    8041601723 <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  80416018ea:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  80416018ee:	0f 84 14 fe ff ff    	je     8041601708 <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  80416018f4:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  80416018fb:	00 00 00 
  80416018fe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601903:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160190a:	00 00 00 
  804160190d:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  804160190f:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601913:	48 8b 58 20          	mov    0x20(%rax),%rbx
  8041601917:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  804160191b:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  804160191f:	0f 83 5b 04 00 00    	jae    8041601d80 <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  8041601925:	49 bf 6a b5 60 41 80 	movabs $0x804160b56a,%r15
  804160192c:	00 00 00 
  804160192f:	e9 9f 03 00 00       	jmpq   8041601cd3 <info_by_address+0x5fb>
    assert(set == set_end);
  8041601934:	48 b9 1f c0 60 41 80 	movabs $0x804160c01f,%rcx
  804160193b:	00 00 00 
  804160193e:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601945:	00 00 00 
  8041601948:	be 3a 00 00 00       	mov    $0x3a,%esi
  804160194d:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601954:	00 00 00 
  8041601957:	b8 00 00 00 00       	mov    $0x0,%eax
  804160195c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601963:	00 00 00 
  8041601966:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601969:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160196d:	48 8d 70 20          	lea    0x20(%rax),%rsi
  8041601971:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601976:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160197a:	41 ff d7             	callq  *%r15
  804160197d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041601981:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601987:	eb 08                	jmp    8041601991 <info_by_address+0x2b9>
    *len = initial_len;
  8041601989:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160198b:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  8041601991:	4d 63 e4             	movslq %r12d,%r12
  8041601994:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041601998:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  804160199c:	48 01 d8             	add    %rbx,%rax
  804160199f:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416019a3:	ba 02 00 00 00       	mov    $0x2,%edx
  80416019a8:	48 89 de             	mov    %rbx,%rsi
  80416019ab:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019af:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  80416019b2:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  80416019b6:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416019ba:	83 e8 02             	sub    $0x2,%eax
  80416019bd:	66 a9 fd ff          	test   $0xfffd,%ax
  80416019c1:	0f 85 07 01 00 00    	jne    8041601ace <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416019c7:	ba 04 00 00 00       	mov    $0x4,%edx
  80416019cc:	48 89 de             	mov    %rbx,%rsi
  80416019cf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019d3:	41 ff d7             	callq  *%r15
  80416019d6:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  80416019da:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416019de:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  80416019e2:	ba 01 00 00 00       	mov    $0x1,%edx
  80416019e7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019eb:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  80416019ee:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416019f2:	0f 85 0b 01 00 00    	jne    8041601b03 <info_by_address+0x42b>
  80416019f8:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  80416019fb:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a00:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a05:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601a0a:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601a0e:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a12:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a15:	44 89 c7             	mov    %r8d,%edi
  8041601a18:	83 e7 7f             	and    $0x7f,%edi
  8041601a1b:	d3 e7                	shl    %cl,%edi
  8041601a1d:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a1f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a22:	45 84 c0             	test   %r8b,%r8b
  8041601a25:	78 e3                	js     8041601a0a <info_by_address+0x332>
  return count;
  8041601a27:	48 98                	cltq   
    assert(abbrev_code != 0);
  8041601a29:	85 d2                	test   %edx,%edx
  8041601a2b:	0f 84 07 01 00 00    	je     8041601b38 <info_by_address+0x460>
    entry += count;
  8041601a31:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601a34:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601a38:	4c 03 28             	add    (%rax),%r13
  8041601a3b:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  8041601a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a43:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a48:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601a4d:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041601a51:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041601a55:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a58:	45 89 c8             	mov    %r9d,%r8d
  8041601a5b:	41 83 e0 7f          	and    $0x7f,%r8d
  8041601a5f:	41 d3 e0             	shl    %cl,%r8d
  8041601a62:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  8041601a65:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a68:	45 84 c9             	test   %r9b,%r9b
  8041601a6b:	78 e0                	js     8041601a4d <info_by_address+0x375>
  return count;
  8041601a6d:	48 98                	cltq   
    abbrev_entry += count;
  8041601a6f:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  8041601a72:	39 f2                	cmp    %esi,%edx
  8041601a74:	0f 85 f3 00 00 00    	jne    8041601b6d <info_by_address+0x495>
  8041601a7a:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  8041601a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a82:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a87:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601a8c:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601a90:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a94:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a97:	44 89 c7             	mov    %r8d,%edi
  8041601a9a:	83 e7 7f             	and    $0x7f,%edi
  8041601a9d:	d3 e7                	shl    %cl,%edi
  8041601a9f:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601aa1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601aa4:	45 84 c0             	test   %r8b,%r8b
  8041601aa7:	78 e3                	js     8041601a8c <info_by_address+0x3b4>
  return count;
  8041601aa9:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  8041601aab:	83 fa 11             	cmp    $0x11,%edx
  8041601aae:	0f 85 ee 00 00 00    	jne    8041601ba2 <info_by_address+0x4ca>
    abbrev_entry++;
  8041601ab4:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601ab9:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601ac0:	00 
  8041601ac1:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601ac8:	00 
  8041601ac9:	e9 2f 01 00 00       	jmpq   8041601bfd <info_by_address+0x525>
    assert(version == 4 || version == 2);
  8041601ace:	48 b9 2e c0 60 41 80 	movabs $0x804160c02e,%rcx
  8041601ad5:	00 00 00 
  8041601ad8:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601adf:	00 00 00 
  8041601ae2:	be 43 01 00 00       	mov    $0x143,%esi
  8041601ae7:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601aee:	00 00 00 
  8041601af1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601af6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601afd:	00 00 00 
  8041601b00:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601b03:	48 b9 fb bf 60 41 80 	movabs $0x804160bffb,%rcx
  8041601b0a:	00 00 00 
  8041601b0d:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601b14:	00 00 00 
  8041601b17:	be 47 01 00 00       	mov    $0x147,%esi
  8041601b1c:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601b23:	00 00 00 
  8041601b26:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b2b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b32:	00 00 00 
  8041601b35:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601b38:	48 b9 4b c0 60 41 80 	movabs $0x804160c04b,%rcx
  8041601b3f:	00 00 00 
  8041601b42:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601b49:	00 00 00 
  8041601b4c:	be 4c 01 00 00       	mov    $0x14c,%esi
  8041601b51:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601b58:	00 00 00 
  8041601b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b60:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b67:	00 00 00 
  8041601b6a:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601b6d:	48 b9 80 c1 60 41 80 	movabs $0x804160c180,%rcx
  8041601b74:	00 00 00 
  8041601b77:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601b7e:	00 00 00 
  8041601b81:	be 54 01 00 00       	mov    $0x154,%esi
  8041601b86:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601b8d:	00 00 00 
  8041601b90:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b95:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b9c:	00 00 00 
  8041601b9f:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601ba2:	48 b9 5c c0 60 41 80 	movabs $0x804160c05c,%rcx
  8041601ba9:	00 00 00 
  8041601bac:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601bb3:	00 00 00 
  8041601bb6:	be 58 01 00 00       	mov    $0x158,%esi
  8041601bbb:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601bc2:	00 00 00 
  8041601bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601bca:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601bd1:	00 00 00 
  8041601bd4:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601bd7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601bdd:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601be2:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601be6:	44 89 f6             	mov    %r14d,%esi
  8041601be9:	4c 89 e7             	mov    %r12,%rdi
  8041601bec:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  8041601bf3:	00 00 00 
  8041601bf6:	ff d0                	callq  *%rax
      entry += count;
  8041601bf8:	48 98                	cltq   
  8041601bfa:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601bfd:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c00:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c05:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c0a:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601c10:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c13:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c17:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c1a:	89 fe                	mov    %edi,%esi
  8041601c1c:	83 e6 7f             	and    $0x7f,%esi
  8041601c1f:	d3 e6                	shl    %cl,%esi
  8041601c21:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601c24:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c27:	40 84 ff             	test   %dil,%dil
  8041601c2a:	78 e4                	js     8041601c10 <info_by_address+0x538>
  return count;
  8041601c2c:	48 98                	cltq   
      abbrev_entry += count;
  8041601c2e:	48 01 c3             	add    %rax,%rbx
  8041601c31:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c34:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c39:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c3e:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601c44:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c47:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c4b:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c4e:	89 fe                	mov    %edi,%esi
  8041601c50:	83 e6 7f             	and    $0x7f,%esi
  8041601c53:	d3 e6                	shl    %cl,%esi
  8041601c55:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601c58:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c5b:	40 84 ff             	test   %dil,%dil
  8041601c5e:	78 e4                	js     8041601c44 <info_by_address+0x56c>
  return count;
  8041601c60:	48 98                	cltq   
      abbrev_entry += count;
  8041601c62:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601c65:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601c69:	0f 84 68 ff ff ff    	je     8041601bd7 <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601c6f:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601c73:	0f 84 ae 00 00 00    	je     8041601d27 <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601c79:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601c84:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601c89:	44 89 f6             	mov    %r14d,%esi
  8041601c8c:	4c 89 e7             	mov    %r12,%rdi
  8041601c8f:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  8041601c96:	00 00 00 
  8041601c99:	ff d0                	callq  *%rax
      entry += count;
  8041601c9b:	48 98                	cltq   
  8041601c9d:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601ca0:	45 09 f5             	or     %r14d,%r13d
  8041601ca3:	0f 85 54 ff ff ff    	jne    8041601bfd <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601ca9:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601cad:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601cb1:	72 0a                	jb     8041601cbd <info_by_address+0x5e5>
  8041601cb3:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601cb7:	0f 86 a2 00 00 00    	jbe    8041601d5f <info_by_address+0x687>
    entry = entry_end;
  8041601cbd:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601cc1:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601cc5:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601cc9:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601ccd:	0f 83 a6 00 00 00    	jae    8041601d79 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601cd3:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601cd8:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601cdc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601ce0:	41 ff d7             	callq  *%r15
  8041601ce3:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601ce6:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601ce9:	0f 86 9a fc ff ff    	jbe    8041601989 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601cef:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601cf2:	0f 84 71 fc ff ff    	je     8041601969 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601cf8:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  8041601cff:	00 00 00 
  8041601d02:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d07:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041601d0e:	00 00 00 
  8041601d11:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601d13:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601d18:	48 83 c4 48          	add    $0x48,%rsp
  8041601d1c:	5b                   	pop    %rbx
  8041601d1d:	41 5c                	pop    %r12
  8041601d1f:	41 5d                	pop    %r13
  8041601d21:	41 5e                	pop    %r14
  8041601d23:	41 5f                	pop    %r15
  8041601d25:	5d                   	pop    %rbp
  8041601d26:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601d27:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601d2d:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601d32:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601d36:	44 89 f6             	mov    %r14d,%esi
  8041601d39:	4c 89 e7             	mov    %r12,%rdi
  8041601d3c:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  8041601d43:	00 00 00 
  8041601d46:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601d48:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601d4c:	0f 84 a6 fe ff ff    	je     8041601bf8 <info_by_address+0x520>
          high_pc += low_pc;
  8041601d52:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601d56:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601d5a:	e9 99 fe ff ff       	jmpq   8041601bf8 <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601d5f:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601d63:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601d67:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601d6b:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601d6f:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601d72:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d77:	eb 9f                	jmp    8041601d18 <info_by_address+0x640>
  return 0;
  8041601d79:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d7e:	eb 98                	jmp    8041601d18 <info_by_address+0x640>
  8041601d80:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d85:	eb 91                	jmp    8041601d18 <info_by_address+0x640>

0000008041601d87 <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601d87:	55                   	push   %rbp
  8041601d88:	48 89 e5             	mov    %rsp,%rbp
  8041601d8b:	41 57                	push   %r15
  8041601d8d:	41 56                	push   %r14
  8041601d8f:	41 55                	push   %r13
  8041601d91:	41 54                	push   %r12
  8041601d93:	53                   	push   %rbx
  8041601d94:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601d98:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601d9c:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601da0:	48 29 d8             	sub    %rbx,%rax
  8041601da3:	48 39 f0             	cmp    %rsi,%rax
  8041601da6:	0f 82 f5 02 00 00    	jb     80416020a1 <file_name_by_info+0x31a>
  8041601dac:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601db0:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601db3:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601db7:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601dbb:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601dbe:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601dc3:	48 89 de             	mov    %rbx,%rsi
  8041601dc6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601dca:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601dd1:	00 00 00 
  8041601dd4:	ff d0                	callq  *%rax
  8041601dd6:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601dd9:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601ddc:	0f 86 c9 02 00 00    	jbe    80416020ab <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601de2:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601de5:	74 25                	je     8041601e0c <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601de7:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  8041601dee:	00 00 00 
  8041601df1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601df6:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041601dfd:	00 00 00 
  8041601e00:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601e02:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601e07:	e9 00 02 00 00       	jmpq   804160200c <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601e0c:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601e10:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601e15:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601e19:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041601e20:	00 00 00 
  8041601e23:	ff d0                	callq  *%rax
      count = 12;
  8041601e25:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601e2b:	e9 81 02 00 00       	jmpq   80416020b1 <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601e30:	48 b9 2e c0 60 41 80 	movabs $0x804160c02e,%rcx
  8041601e37:	00 00 00 
  8041601e3a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601e41:	00 00 00 
  8041601e44:	be 9b 01 00 00       	mov    $0x19b,%esi
  8041601e49:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601e50:	00 00 00 
  8041601e53:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e58:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e5f:	00 00 00 
  8041601e62:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601e65:	48 b9 fb bf 60 41 80 	movabs $0x804160bffb,%rcx
  8041601e6c:	00 00 00 
  8041601e6f:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601e76:	00 00 00 
  8041601e79:	be 9f 01 00 00       	mov    $0x19f,%esi
  8041601e7e:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601e85:	00 00 00 
  8041601e88:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e8d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e94:	00 00 00 
  8041601e97:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601e9a:	48 b9 4b c0 60 41 80 	movabs $0x804160c04b,%rcx
  8041601ea1:	00 00 00 
  8041601ea4:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601eab:	00 00 00 
  8041601eae:	be a4 01 00 00       	mov    $0x1a4,%esi
  8041601eb3:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601eba:	00 00 00 
  8041601ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ec2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ec9:	00 00 00 
  8041601ecc:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601ecf:	48 b9 80 c1 60 41 80 	movabs $0x804160c180,%rcx
  8041601ed6:	00 00 00 
  8041601ed9:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601ee0:	00 00 00 
  8041601ee3:	be ac 01 00 00       	mov    $0x1ac,%esi
  8041601ee8:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601eef:	00 00 00 
  8041601ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ef7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601efe:	00 00 00 
  8041601f01:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601f04:	48 b9 5c c0 60 41 80 	movabs $0x804160c05c,%rcx
  8041601f0b:	00 00 00 
  8041601f0e:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041601f15:	00 00 00 
  8041601f18:	be b0 01 00 00       	mov    $0x1b0,%esi
  8041601f1d:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041601f24:	00 00 00 
  8041601f27:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f2c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601f33:	00 00 00 
  8041601f36:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601f39:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601f3d:	0f 84 d8 00 00 00    	je     804160201b <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601f43:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f49:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601f4c:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601f50:	44 89 ee             	mov    %r13d,%esi
  8041601f53:	4c 89 f7             	mov    %r14,%rdi
  8041601f56:	41 ff d7             	callq  *%r15
  8041601f59:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601f5c:	49 63 c4             	movslq %r12d,%rax
  8041601f5f:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601f62:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f65:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601f6f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601f75:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601f78:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601f7c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601f7f:	89 f0                	mov    %esi,%eax
  8041601f81:	83 e0 7f             	and    $0x7f,%eax
  8041601f84:	d3 e0                	shl    %cl,%eax
  8041601f86:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601f89:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601f8c:	40 84 f6             	test   %sil,%sil
  8041601f8f:	78 e4                	js     8041601f75 <file_name_by_info+0x1ee>
  return count;
  8041601f91:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601f94:	48 01 fb             	add    %rdi,%rbx
  8041601f97:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601f9a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601f9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601fa4:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601faa:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601fad:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601fb1:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601fb4:	89 f0                	mov    %esi,%eax
  8041601fb6:	83 e0 7f             	and    $0x7f,%eax
  8041601fb9:	d3 e0                	shl    %cl,%eax
  8041601fbb:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601fbe:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601fc1:	40 84 f6             	test   %sil,%sil
  8041601fc4:	78 e4                	js     8041601faa <file_name_by_info+0x223>
  return count;
  8041601fc6:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601fc9:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041601fcc:	41 83 fc 03          	cmp    $0x3,%r12d
  8041601fd0:	0f 84 63 ff ff ff    	je     8041601f39 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041601fd6:	41 83 fc 10          	cmp    $0x10,%r12d
  8041601fda:	0f 84 a1 00 00 00    	je     8041602081 <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601fe0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601feb:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601ff0:	44 89 ee             	mov    %r13d,%esi
  8041601ff3:	4c 89 f7             	mov    %r14,%rdi
  8041601ff6:	41 ff d7             	callq  *%r15
    entry += count;
  8041601ff9:	48 98                	cltq   
  8041601ffb:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601ffe:	45 09 e5             	or     %r12d,%r13d
  8041602001:	0f 85 5b ff ff ff    	jne    8041601f62 <file_name_by_info+0x1db>

  return 0;
  8041602007:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160200c:	48 83 c4 38          	add    $0x38,%rsp
  8041602010:	5b                   	pop    %rbx
  8041602011:	41 5c                	pop    %r12
  8041602013:	41 5d                	pop    %r13
  8041602015:	41 5e                	pop    %r14
  8041602017:	41 5f                	pop    %r15
  8041602019:	5d                   	pop    %rbp
  804160201a:	c3                   	retq   
        unsigned long offset = 0;
  804160201b:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602022:	00 
        count                = dwarf_read_abbrev_entry(
  8041602023:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602029:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160202e:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602032:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602037:	4c 89 f7             	mov    %r14,%rdi
  804160203a:	41 ff d7             	callq  *%r15
  804160203d:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  8041602040:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041602044:	48 85 ff             	test   %rdi,%rdi
  8041602047:	0f 84 0f ff ff ff    	je     8041601f5c <file_name_by_info+0x1d5>
  804160204d:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  8041602051:	0f 86 05 ff ff ff    	jbe    8041601f5c <file_name_by_info+0x1d5>
          put_unaligned(
  8041602057:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160205b:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  804160205f:	48 03 41 40          	add    0x40(%rcx),%rax
  8041602063:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602067:	ba 08 00 00 00       	mov    $0x8,%edx
  804160206c:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602070:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041602077:	00 00 00 
  804160207a:	ff d0                	callq  *%rax
  804160207c:	e9 db fe ff ff       	jmpq   8041601f5c <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  8041602081:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602087:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160208c:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041602090:	44 89 ee             	mov    %r13d,%esi
  8041602093:	4c 89 f7             	mov    %r14,%rdi
  8041602096:	41 ff d7             	callq  *%r15
  8041602099:	41 89 c4             	mov    %eax,%r12d
  804160209c:	e9 bb fe ff ff       	jmpq   8041601f5c <file_name_by_info+0x1d5>
    return -E_INVAL;
  80416020a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416020a6:	e9 61 ff ff ff       	jmpq   804160200c <file_name_by_info+0x285>
  count       = 4;
  80416020ab:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  80416020b1:	4d 63 ed             	movslq %r13d,%r13
  80416020b4:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416020b7:	ba 02 00 00 00       	mov    $0x2,%edx
  80416020bc:	48 89 de             	mov    %rbx,%rsi
  80416020bf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020c3:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416020ca:	00 00 00 
  80416020cd:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416020cf:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416020d3:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416020d7:	83 e8 02             	sub    $0x2,%eax
  80416020da:	66 a9 fd ff          	test   $0xfffd,%ax
  80416020de:	0f 85 4c fd ff ff    	jne    8041601e30 <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416020e4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416020e9:	48 89 de             	mov    %rbx,%rsi
  80416020ec:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416020f0:	49 bf 6a b5 60 41 80 	movabs $0x804160b56a,%r15
  80416020f7:	00 00 00 
  80416020fa:	41 ff d7             	callq  *%r15
  80416020fd:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  8041602101:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602105:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602109:	ba 01 00 00 00       	mov    $0x1,%edx
  804160210e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602112:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  8041602115:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602119:	0f 85 46 fd ff ff    	jne    8041601e65 <file_name_by_info+0xde>
  804160211f:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602122:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602127:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160212c:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602132:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602135:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602139:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160213c:	89 f0                	mov    %esi,%eax
  804160213e:	83 e0 7f             	and    $0x7f,%eax
  8041602141:	d3 e0                	shl    %cl,%eax
  8041602143:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602146:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602149:	40 84 f6             	test   %sil,%sil
  804160214c:	78 e4                	js     8041602132 <file_name_by_info+0x3ab>
  return count;
  804160214e:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  8041602151:	45 85 c0             	test   %r8d,%r8d
  8041602154:	0f 84 40 fd ff ff    	je     8041601e9a <file_name_by_info+0x113>
  entry += count;
  804160215a:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  804160215d:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041602161:	4c 03 20             	add    (%rax),%r12
  8041602164:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041602167:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160216c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602171:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602177:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160217a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160217e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602181:	89 f0                	mov    %esi,%eax
  8041602183:	83 e0 7f             	and    $0x7f,%eax
  8041602186:	d3 e0                	shl    %cl,%eax
  8041602188:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160218b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160218e:	40 84 f6             	test   %sil,%sil
  8041602191:	78 e4                	js     8041602177 <file_name_by_info+0x3f0>
  return count;
  8041602193:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  8041602196:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  8041602199:	45 39 c8             	cmp    %r9d,%r8d
  804160219c:	0f 85 2d fd ff ff    	jne    8041601ecf <file_name_by_info+0x148>
  80416021a2:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  80416021a5:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416021aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416021af:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416021b5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416021b8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416021bc:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416021bf:	89 f0                	mov    %esi,%eax
  80416021c1:	83 e0 7f             	and    $0x7f,%eax
  80416021c4:	d3 e0                	shl    %cl,%eax
  80416021c6:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416021c9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416021cc:	40 84 f6             	test   %sil,%sil
  80416021cf:	78 e4                	js     80416021b5 <file_name_by_info+0x42e>
  return count;
  80416021d1:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  80416021d4:	41 83 f8 11          	cmp    $0x11,%r8d
  80416021d8:	0f 85 26 fd ff ff    	jne    8041601f04 <file_name_by_info+0x17d>
  abbrev_entry++;
  80416021de:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  80416021e3:	49 bf 52 0d 60 41 80 	movabs $0x8041600d52,%r15
  80416021ea:	00 00 00 
  80416021ed:	e9 70 fd ff ff       	jmpq   8041601f62 <file_name_by_info+0x1db>

00000080416021f2 <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  80416021f2:	55                   	push   %rbp
  80416021f3:	48 89 e5             	mov    %rsp,%rbp
  80416021f6:	41 57                	push   %r15
  80416021f8:	41 56                	push   %r14
  80416021fa:	41 55                	push   %r13
  80416021fc:	41 54                	push   %r12
  80416021fe:	53                   	push   %rbx
  80416021ff:	48 83 ec 68          	sub    $0x68,%rsp
  8041602203:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  8041602207:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  804160220e:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  8041602212:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  8041602216:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  804160221d:	48 89 d3             	mov    %rdx,%rbx
  8041602220:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602224:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602229:	48 89 de             	mov    %rbx,%rsi
  804160222c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602230:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041602237:	00 00 00 
  804160223a:	ff d0                	callq  *%rax
  804160223c:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160223f:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602242:	76 59                	jbe    804160229d <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  8041602244:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602247:	74 2f                	je     8041602278 <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602249:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  8041602250:	00 00 00 
  8041602253:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602258:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160225f:	00 00 00 
  8041602262:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041602264:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602269:	48 83 c4 68          	add    $0x68,%rsp
  804160226d:	5b                   	pop    %rbx
  804160226e:	41 5c                	pop    %r12
  8041602270:	41 5d                	pop    %r13
  8041602272:	41 5e                	pop    %r14
  8041602274:	41 5f                	pop    %r15
  8041602276:	5d                   	pop    %rbp
  8041602277:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602278:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  804160227c:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602281:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602285:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160228c:	00 00 00 
  804160228f:	ff d0                	callq  *%rax
  8041602291:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602295:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  804160229b:	eb 08                	jmp    80416022a5 <function_by_info+0xb3>
    *len = initial_len;
  804160229d:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160229f:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  80416022a5:	4d 63 f6             	movslq %r14d,%r14
  80416022a8:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  80416022ab:	48 01 d8             	add    %rbx,%rax
  80416022ae:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416022b2:	ba 02 00 00 00       	mov    $0x2,%edx
  80416022b7:	48 89 de             	mov    %rbx,%rsi
  80416022ba:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022be:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416022c5:	00 00 00 
  80416022c8:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416022ca:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416022ce:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416022d2:	83 e8 02             	sub    $0x2,%eax
  80416022d5:	66 a9 fd ff          	test   $0xfffd,%ax
  80416022d9:	75 51                	jne    804160232c <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416022db:	ba 04 00 00 00       	mov    $0x4,%edx
  80416022e0:	48 89 de             	mov    %rbx,%rsi
  80416022e3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022e7:	49 bc 6a b5 60 41 80 	movabs $0x804160b56a,%r12
  80416022ee:	00 00 00 
  80416022f1:	41 ff d4             	callq  *%r12
  80416022f4:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  80416022f8:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416022fc:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602300:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602305:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602309:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  804160230c:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602310:	75 4f                	jne    8041602361 <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602312:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602316:	4c 03 28             	add    (%rax),%r13
  8041602319:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  804160231d:	49 bf 52 0d 60 41 80 	movabs $0x8041600d52,%r15
  8041602324:	00 00 00 
  while (entry < entry_end) {
  8041602327:	e9 07 02 00 00       	jmpq   8041602533 <function_by_info+0x341>
  assert(version == 4 || version == 2);
  804160232c:	48 b9 2e c0 60 41 80 	movabs $0x804160c02e,%rcx
  8041602333:	00 00 00 
  8041602336:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160233d:	00 00 00 
  8041602340:	be e9 01 00 00       	mov    $0x1e9,%esi
  8041602345:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  804160234c:	00 00 00 
  804160234f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602354:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160235b:	00 00 00 
  804160235e:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  8041602361:	48 b9 fb bf 60 41 80 	movabs $0x804160bffb,%rcx
  8041602368:	00 00 00 
  804160236b:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041602372:	00 00 00 
  8041602375:	be ed 01 00 00       	mov    $0x1ed,%esi
  804160237a:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041602381:	00 00 00 
  8041602384:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602389:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602390:	00 00 00 
  8041602393:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  8041602396:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160239a:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  804160239e:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  80416023a2:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  80416023a8:	49 39 da             	cmp    %rbx,%r10
  80416023ab:	0f 86 e7 00 00 00    	jbe    8041602498 <function_by_info+0x2a6>
  80416023b1:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023b4:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416023ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023bf:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416023c4:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023c7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023cb:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416023cf:	89 f8                	mov    %edi,%eax
  80416023d1:	83 e0 7f             	and    $0x7f,%eax
  80416023d4:	d3 e0                	shl    %cl,%eax
  80416023d6:	09 c6                	or     %eax,%esi
    shift += 7;
  80416023d8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023db:	40 84 ff             	test   %dil,%dil
  80416023de:	78 e4                	js     80416023c4 <function_by_info+0x1d2>
  return count;
  80416023e0:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  80416023e3:	4c 01 c3             	add    %r8,%rbx
  80416023e6:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023e9:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  80416023ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023f4:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416023fa:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416023fd:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602401:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  8041602405:	89 f8                	mov    %edi,%eax
  8041602407:	83 e0 7f             	and    $0x7f,%eax
  804160240a:	d3 e0                	shl    %cl,%eax
  804160240c:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  804160240f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602412:	40 84 ff             	test   %dil,%dil
  8041602415:	78 e3                	js     80416023fa <function_by_info+0x208>
  return count;
  8041602417:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  804160241a:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  804160241f:	41 39 f1             	cmp    %esi,%r9d
  8041602422:	74 74                	je     8041602498 <function_by_info+0x2a6>
  result = 0;
  8041602424:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602427:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160242c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602431:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602437:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160243a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160243e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602441:	89 f0                	mov    %esi,%eax
  8041602443:	83 e0 7f             	and    $0x7f,%eax
  8041602446:	d3 e0                	shl    %cl,%eax
  8041602448:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  804160244b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160244e:	40 84 f6             	test   %sil,%sil
  8041602451:	78 e4                	js     8041602437 <function_by_info+0x245>
  return count;
  8041602453:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602456:	48 01 fb             	add    %rdi,%rbx
  8041602459:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160245c:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602461:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602466:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  804160246c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160246f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602473:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602476:	89 f0                	mov    %esi,%eax
  8041602478:	83 e0 7f             	and    $0x7f,%eax
  804160247b:	d3 e0                	shl    %cl,%eax
  804160247d:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602480:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602483:	40 84 f6             	test   %sil,%sil
  8041602486:	78 e4                	js     804160246c <function_by_info+0x27a>
  return count;
  8041602488:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160248b:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  804160248e:	45 09 dc             	or     %r11d,%r12d
  8041602491:	75 91                	jne    8041602424 <function_by_info+0x232>
  8041602493:	e9 10 ff ff ff       	jmpq   80416023a8 <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  8041602498:	41 83 f8 2e          	cmp    $0x2e,%r8d
  804160249c:	0f 84 e9 00 00 00    	je     804160258b <function_by_info+0x399>
            fn_name_entry = entry;
  80416024a2:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024a5:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024af:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416024b5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024b8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024bc:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024bf:	89 f0                	mov    %esi,%eax
  80416024c1:	83 e0 7f             	and    $0x7f,%eax
  80416024c4:	d3 e0                	shl    %cl,%eax
  80416024c6:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416024c9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024cc:	40 84 f6             	test   %sil,%sil
  80416024cf:	78 e4                	js     80416024b5 <function_by_info+0x2c3>
  return count;
  80416024d1:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024d4:	48 01 fb             	add    %rdi,%rbx
  80416024d7:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024da:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024df:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024e4:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024ea:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024ed:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024f1:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024f4:	89 f0                	mov    %esi,%eax
  80416024f6:	83 e0 7f             	and    $0x7f,%eax
  80416024f9:	d3 e0                	shl    %cl,%eax
  80416024fb:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024fe:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602501:	40 84 f6             	test   %sil,%sil
  8041602504:	78 e4                	js     80416024ea <function_by_info+0x2f8>
  return count;
  8041602506:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602509:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  804160250c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602512:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602517:	ba 00 00 00 00       	mov    $0x0,%edx
  804160251c:	44 89 e6             	mov    %r12d,%esi
  804160251f:	4c 89 f7             	mov    %r14,%rdi
  8041602522:	41 ff d7             	callq  *%r15
        entry += count;
  8041602525:	48 98                	cltq   
  8041602527:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160252a:	45 09 ec             	or     %r13d,%r12d
  804160252d:	0f 85 6f ff ff ff    	jne    80416024a2 <function_by_info+0x2b0>
  while (entry < entry_end) {
  8041602533:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  8041602537:	0f 83 37 02 00 00    	jae    8041602774 <function_by_info+0x582>
                 uintptr_t *offset) {
  804160253d:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602540:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602545:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160254a:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602550:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602553:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602557:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160255a:	89 f0                	mov    %esi,%eax
  804160255c:	83 e0 7f             	and    $0x7f,%eax
  804160255f:	d3 e0                	shl    %cl,%eax
  8041602561:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602564:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602567:	40 84 f6             	test   %sil,%sil
  804160256a:	78 e4                	js     8041602550 <function_by_info+0x35e>
  return count;
  804160256c:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  804160256f:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  8041602572:	45 85 c9             	test   %r9d,%r9d
  8041602575:	0f 85 1b fe ff ff    	jne    8041602396 <function_by_info+0x1a4>
  while (entry < entry_end) {
  804160257b:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  804160257f:	77 bc                	ja     804160253d <function_by_info+0x34b>
  return 0;
  8041602581:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602586:	e9 de fc ff ff       	jmpq   8041602269 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  804160258b:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  8041602592:	00 
  8041602593:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  804160259a:	00 
      unsigned name_form        = 0;
  804160259b:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  80416025a2:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80416025a9:	00 
  80416025aa:	eb 1d                	jmp    80416025c9 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  80416025ac:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416025b2:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416025b7:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416025bb:	44 89 ee             	mov    %r13d,%esi
  80416025be:	4c 89 f7             	mov    %r14,%rdi
  80416025c1:	41 ff d7             	callq  *%r15
        entry += count;
  80416025c4:	48 98                	cltq   
  80416025c6:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  80416025c9:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416025cc:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416025d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416025d6:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416025dc:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416025df:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416025e3:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416025e6:	89 f0                	mov    %esi,%eax
  80416025e8:	83 e0 7f             	and    $0x7f,%eax
  80416025eb:	d3 e0                	shl    %cl,%eax
  80416025ed:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416025f0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025f3:	40 84 f6             	test   %sil,%sil
  80416025f6:	78 e4                	js     80416025dc <function_by_info+0x3ea>
  return count;
  80416025f8:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416025fb:	48 01 fb             	add    %rdi,%rbx
  80416025fe:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602601:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602606:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160260b:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602611:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602614:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602618:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160261b:	89 f0                	mov    %esi,%eax
  804160261d:	83 e0 7f             	and    $0x7f,%eax
  8041602620:	d3 e0                	shl    %cl,%eax
  8041602622:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602625:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602628:	40 84 f6             	test   %sil,%sil
  804160262b:	78 e4                	js     8041602611 <function_by_info+0x41f>
  return count;
  804160262d:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602630:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  8041602633:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602637:	0f 84 6f ff ff ff    	je     80416025ac <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  804160263d:	41 83 fc 12          	cmp    $0x12,%r12d
  8041602641:	0f 84 99 00 00 00    	je     80416026e0 <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  8041602647:	41 83 fc 03          	cmp    $0x3,%r12d
  804160264b:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  804160264e:	41 0f 44 c5          	cmove  %r13d,%eax
  8041602652:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  8041602655:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602659:	49 0f 44 c6          	cmove  %r14,%rax
  804160265d:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  8041602661:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602667:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160266c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602671:	44 89 ee             	mov    %r13d,%esi
  8041602674:	4c 89 f7             	mov    %r14,%rdi
  8041602677:	41 ff d7             	callq  *%r15
        entry += count;
  804160267a:	48 98                	cltq   
  804160267c:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160267f:	45 09 e5             	or     %r12d,%r13d
  8041602682:	0f 85 41 ff ff ff    	jne    80416025c9 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  8041602688:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160268c:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  8041602693:	48 39 d8             	cmp    %rbx,%rax
  8041602696:	0f 87 97 fe ff ff    	ja     8041602533 <function_by_info+0x341>
  804160269c:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  80416026a0:	0f 82 8d fe ff ff    	jb     8041602533 <function_by_info+0x341>
        *offset = low_pc;
  80416026a6:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  80416026ad:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  80416026b0:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  80416026b4:	74 59                	je     804160270f <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  80416026b6:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026bc:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  80416026bf:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  80416026c3:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  80416026c6:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  80416026ca:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  80416026d1:	00 00 00 
  80416026d4:	ff d0                	callq  *%rax
        return 0;
  80416026d6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026db:	e9 89 fb ff ff       	jmpq   8041602269 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  80416026e0:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026e6:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416026eb:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416026ef:	44 89 ee             	mov    %r13d,%esi
  80416026f2:	4c 89 f7             	mov    %r14,%rdi
  80416026f5:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  80416026f8:	41 83 fd 01          	cmp    $0x1,%r13d
  80416026fc:	0f 84 c2 fe ff ff    	je     80416025c4 <function_by_info+0x3d2>
            high_pc += low_pc;
  8041602702:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041602706:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  804160270a:	e9 b5 fe ff ff       	jmpq   80416025c4 <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  804160270f:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602716:	00 
          count                    = dwarf_read_abbrev_entry(
  8041602717:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160271d:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602722:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602726:	be 0e 00 00 00       	mov    $0xe,%esi
  804160272b:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  804160272f:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  8041602736:	00 00 00 
  8041602739:	ff d0                	callq  *%rax
          if (buf &&
  804160273b:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  804160273f:	48 85 ff             	test   %rdi,%rdi
  8041602742:	74 92                	je     80416026d6 <function_by_info+0x4e4>
  8041602744:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  8041602748:	76 8c                	jbe    80416026d6 <function_by_info+0x4e4>
            put_unaligned(
  804160274a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160274e:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602752:	48 03 43 40          	add    0x40(%rbx),%rax
  8041602756:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  804160275a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160275f:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602763:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160276a:	00 00 00 
  804160276d:	ff d0                	callq  *%rax
  804160276f:	e9 62 ff ff ff       	jmpq   80416026d6 <function_by_info+0x4e4>
  return 0;
  8041602774:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602779:	e9 eb fa ff ff       	jmpq   8041602269 <function_by_info+0x77>

000000804160277e <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  804160277e:	55                   	push   %rbp
  804160277f:	48 89 e5             	mov    %rsp,%rbp
  8041602782:	41 57                	push   %r15
  8041602784:	41 56                	push   %r14
  8041602786:	41 55                	push   %r13
  8041602788:	41 54                	push   %r12
  804160278a:	53                   	push   %rbx
  804160278b:	48 83 ec 48          	sub    $0x48,%rsp
  804160278f:	49 89 ff             	mov    %rdi,%r15
  8041602792:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  8041602796:	48 89 f7             	mov    %rsi,%rdi
  8041602799:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  804160279d:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const int flen = strlen(fname);
  80416027a1:	48 b8 f1 b2 60 41 80 	movabs $0x804160b2f1,%rax
  80416027a8:	00 00 00 
  80416027ab:	ff d0                	callq  *%rax
  80416027ad:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  80416027af:	85 c0                	test   %eax,%eax
  80416027b1:	74 62                	je     8041602815 <address_by_fname+0x97>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  80416027b3:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416027b7:	49 be 6a b5 60 41 80 	movabs $0x804160b56a,%r14
  80416027be:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  80416027c1:	49 bf 00 b4 60 41 80 	movabs $0x804160b400,%r15
  80416027c8:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  80416027cb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416027cf:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  80416027d3:	0f 86 0b 04 00 00    	jbe    8041602be4 <address_by_fname+0x466>
  80416027d9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027de:	4c 89 e6             	mov    %r12,%rsi
  80416027e1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027e5:	41 ff d6             	callq  *%r14
  80416027e8:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416027eb:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416027ee:	76 52                	jbe    8041602842 <address_by_fname+0xc4>
    if (initial_len == DW_EXT_DWARF64) {
  80416027f0:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416027f3:	74 31                	je     8041602826 <address_by_fname+0xa8>
      cprintf("Unknown DWARF extension\n");
  80416027f5:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  80416027fc:	00 00 00 
  80416027ff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602804:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160280b:	00 00 00 
  804160280e:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602810:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  8041602815:	89 d8                	mov    %ebx,%eax
  8041602817:	48 83 c4 48          	add    $0x48,%rsp
  804160281b:	5b                   	pop    %rbx
  804160281c:	41 5c                	pop    %r12
  804160281e:	41 5d                	pop    %r13
  8041602820:	41 5e                	pop    %r14
  8041602822:	41 5f                	pop    %r15
  8041602824:	5d                   	pop    %rbp
  8041602825:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602826:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  804160282b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602830:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602834:	41 ff d6             	callq  *%r14
  8041602837:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160283b:	ba 0c 00 00 00       	mov    $0xc,%edx
  8041602840:	eb 07                	jmp    8041602849 <address_by_fname+0xcb>
    *len = initial_len;
  8041602842:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602844:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  8041602849:	48 63 d2             	movslq %edx,%rdx
  804160284c:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  804160284f:	4c 01 e0             	add    %r12,%rax
  8041602852:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  8041602856:	ba 02 00 00 00       	mov    $0x2,%edx
  804160285b:	4c 89 e6             	mov    %r12,%rsi
  804160285e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602862:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  8041602865:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  804160286a:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160286f:	0f 85 be 00 00 00    	jne    8041602933 <address_by_fname+0x1b5>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602875:	ba 04 00 00 00       	mov    $0x4,%edx
  804160287a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160287e:	41 ff d6             	callq  *%r14
  8041602881:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041602884:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  8041602887:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160288c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602891:	48 89 de             	mov    %rbx,%rsi
  8041602894:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602898:	41 ff d6             	callq  *%r14
  804160289b:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  804160289e:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416028a3:	83 fa ef             	cmp    $0xffffffef,%edx
  80416028a6:	76 29                	jbe    80416028d1 <address_by_fname+0x153>
    if (initial_len == DW_EXT_DWARF64) {
  80416028a8:	83 fa ff             	cmp    $0xffffffff,%edx
  80416028ab:	0f 84 b7 00 00 00    	je     8041602968 <address_by_fname+0x1ea>
      cprintf("Unknown DWARF extension\n");
  80416028b1:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  80416028b8:	00 00 00 
  80416028bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028c0:	48 b9 6e 8f 60 41 80 	movabs $0x8041608f6e,%rcx
  80416028c7:	00 00 00 
  80416028ca:	ff d1                	callq  *%rcx
      count = 0;
  80416028cc:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  80416028d1:	48 98                	cltq   
  80416028d3:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416028d7:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416028db:	0f 86 ea fe ff ff    	jbe    80416027cb <address_by_fname+0x4d>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028e1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028e6:	4c 89 e6             	mov    %r12,%rsi
  80416028e9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028ed:	41 ff d6             	callq  *%r14
  80416028f0:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416028f4:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416028f8:	4d 85 ed             	test   %r13,%r13
  80416028fb:	0f 84 ca fe ff ff    	je     80416027cb <address_by_fname+0x4d>
      if (!strcmp(fname, pubnames_entry)) {
  8041602901:	4c 89 e6             	mov    %r12,%rsi
  8041602904:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  8041602908:	41 ff d7             	callq  *%r15
  804160290b:	89 c3                	mov    %eax,%ebx
  804160290d:	85 c0                	test   %eax,%eax
  804160290f:	74 72                	je     8041602983 <address_by_fname+0x205>
      pubnames_entry += strlen(pubnames_entry) + 1;
  8041602911:	4c 89 e7             	mov    %r12,%rdi
  8041602914:	48 b8 f1 b2 60 41 80 	movabs $0x804160b2f1,%rax
  804160291b:	00 00 00 
  804160291e:	ff d0                	callq  *%rax
  8041602920:	83 c0 01             	add    $0x1,%eax
  8041602923:	48 98                	cltq   
  8041602925:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602928:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  804160292c:	77 b3                	ja     80416028e1 <address_by_fname+0x163>
  804160292e:	e9 98 fe ff ff       	jmpq   80416027cb <address_by_fname+0x4d>
    assert(version == 2);
  8041602933:	48 b9 3e c0 60 41 80 	movabs $0x804160c03e,%rcx
  804160293a:	00 00 00 
  804160293d:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041602944:	00 00 00 
  8041602947:	be 76 02 00 00       	mov    $0x276,%esi
  804160294c:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041602953:	00 00 00 
  8041602956:	b8 00 00 00 00       	mov    $0x0,%eax
  804160295b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602962:	00 00 00 
  8041602965:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602968:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  804160296d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602972:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602976:	41 ff d6             	callq  *%r14
      count = 12;
  8041602979:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160297e:	e9 4e ff ff ff       	jmpq   80416028d1 <address_by_fname+0x153>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602983:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  8041602987:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160298b:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  804160298f:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  8041602993:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602998:	4c 89 e6             	mov    %r12,%rsi
  804160299b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160299f:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416029a6:	00 00 00 
  80416029a9:	ff d0                	callq  *%rax
  80416029ab:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416029ae:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416029b1:	0f 86 37 02 00 00    	jbe    8041602bee <address_by_fname+0x470>
    if (initial_len == DW_EXT_DWARF64) {
  80416029b7:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416029ba:	74 25                	je     80416029e1 <address_by_fname+0x263>
      cprintf("Unknown DWARF extension\n");
  80416029bc:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  80416029c3:	00 00 00 
  80416029c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416029cb:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416029d2:	00 00 00 
  80416029d5:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416029d7:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416029dc:	e9 34 fe ff ff       	jmpq   8041602815 <address_by_fname+0x97>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029e1:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  80416029e6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029eb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029ef:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416029f6:	00 00 00 
  80416029f9:	ff d0                	callq  *%rax
      count = 12;
  80416029fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602a00:	e9 ee 01 00 00       	jmpq   8041602bf3 <address_by_fname+0x475>
        assert(version == 4 || version == 2);
  8041602a05:	48 b9 2e c0 60 41 80 	movabs $0x804160c02e,%rcx
  8041602a0c:	00 00 00 
  8041602a0f:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041602a16:	00 00 00 
  8041602a19:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041602a1e:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041602a25:	00 00 00 
  8041602a28:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a2d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a34:	00 00 00 
  8041602a37:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a3a:	48 b9 fb bf 60 41 80 	movabs $0x804160bffb,%rcx
  8041602a41:	00 00 00 
  8041602a44:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041602a4b:	00 00 00 
  8041602a4e:	be 91 02 00 00       	mov    $0x291,%esi
  8041602a53:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041602a5a:	00 00 00 
  8041602a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a62:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a69:	00 00 00 
  8041602a6c:	41 ff d0             	callq  *%r8
        if (tag == DW_TAG_subprogram) {
  8041602a6f:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602a73:	0f 84 93 00 00 00    	je     8041602b0c <address_by_fname+0x38e>
  count  = 0;
  8041602a79:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602a7b:	89 d9                	mov    %ebx,%ecx
  8041602a7d:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a80:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602a86:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602a89:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a8d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602a90:	89 f0                	mov    %esi,%eax
  8041602a92:	83 e0 7f             	and    $0x7f,%eax
  8041602a95:	d3 e0                	shl    %cl,%eax
  8041602a97:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602a9a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a9d:	40 84 f6             	test   %sil,%sil
  8041602aa0:	78 e4                	js     8041602a86 <address_by_fname+0x308>
  return count;
  8041602aa2:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602aa5:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602aa8:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602aaa:	89 d9                	mov    %ebx,%ecx
  8041602aac:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602aaf:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602ab5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ab8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602abc:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602abf:	89 f0                	mov    %esi,%eax
  8041602ac1:	83 e0 7f             	and    $0x7f,%eax
  8041602ac4:	d3 e0                	shl    %cl,%eax
  8041602ac6:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602ac9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602acc:	40 84 f6             	test   %sil,%sil
  8041602acf:	78 e4                	js     8041602ab5 <address_by_fname+0x337>
  return count;
  8041602ad1:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602ad4:	49 01 fc             	add    %rdi,%r12
            count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602ad7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602add:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602ae7:	44 89 ee             	mov    %r13d,%esi
  8041602aea:	4c 89 ff             	mov    %r15,%rdi
  8041602aed:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  8041602af4:	00 00 00 
  8041602af7:	ff d0                	callq  *%rax
            entry += count;
  8041602af9:	48 98                	cltq   
  8041602afb:	49 01 c7             	add    %rax,%r15
          } while (name != 0 || form != 0);
  8041602afe:	45 09 f5             	or     %r14d,%r13d
  8041602b01:	0f 85 72 ff ff ff    	jne    8041602a79 <address_by_fname+0x2fb>
  8041602b07:	e9 09 fd ff ff       	jmpq   8041602815 <address_by_fname+0x97>
          uintptr_t low_pc = 0;
  8041602b0c:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602b13:	00 
  8041602b14:	eb 26                	jmp    8041602b3c <address_by_fname+0x3be>
              count = dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  8041602b16:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b1c:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602b21:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602b25:	44 89 f6             	mov    %r14d,%esi
  8041602b28:	4c 89 ff             	mov    %r15,%rdi
  8041602b2b:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  8041602b32:	00 00 00 
  8041602b35:	ff d0                	callq  *%rax
            entry += count;
  8041602b37:	48 98                	cltq   
  8041602b39:	49 01 c7             	add    %rax,%r15
  count  = 0;
  8041602b3c:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b3e:	89 d9                	mov    %ebx,%ecx
  8041602b40:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b43:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602b49:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b4c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b50:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b53:	89 f0                	mov    %esi,%eax
  8041602b55:	83 e0 7f             	and    $0x7f,%eax
  8041602b58:	d3 e0                	shl    %cl,%eax
  8041602b5a:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602b5d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b60:	40 84 f6             	test   %sil,%sil
  8041602b63:	78 e4                	js     8041602b49 <address_by_fname+0x3cb>
  return count;
  8041602b65:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b68:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602b6b:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b6d:	89 d9                	mov    %ebx,%ecx
  8041602b6f:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b72:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602b78:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b7b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b7f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b82:	89 f0                	mov    %esi,%eax
  8041602b84:	83 e0 7f             	and    $0x7f,%eax
  8041602b87:	d3 e0                	shl    %cl,%eax
  8041602b89:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602b8c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b8f:	40 84 f6             	test   %sil,%sil
  8041602b92:	78 e4                	js     8041602b78 <address_by_fname+0x3fa>
  return count;
  8041602b94:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b97:	49 01 fc             	add    %rdi,%r12
            if (name == DW_AT_low_pc) {
  8041602b9a:	41 83 fd 11          	cmp    $0x11,%r13d
  8041602b9e:	0f 84 72 ff ff ff    	je     8041602b16 <address_by_fname+0x398>
              count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602ba4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602baa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602baf:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602bb4:	44 89 f6             	mov    %r14d,%esi
  8041602bb7:	4c 89 ff             	mov    %r15,%rdi
  8041602bba:	48 b8 52 0d 60 41 80 	movabs $0x8041600d52,%rax
  8041602bc1:	00 00 00 
  8041602bc4:	ff d0                	callq  *%rax
            entry += count;
  8041602bc6:	48 98                	cltq   
  8041602bc8:	49 01 c7             	add    %rax,%r15
          } while (name || form);
  8041602bcb:	45 09 ee             	or     %r13d,%r14d
  8041602bce:	0f 85 68 ff ff ff    	jne    8041602b3c <address_by_fname+0x3be>
          *offset = low_pc;
  8041602bd4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041602bd8:	48 8b 7d 98          	mov    -0x68(%rbp),%rdi
  8041602bdc:	48 89 07             	mov    %rax,(%rdi)
  8041602bdf:	e9 31 fc ff ff       	jmpq   8041602815 <address_by_fname+0x97>
  return 0;
  8041602be4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602be9:	e9 27 fc ff ff       	jmpq   8041602815 <address_by_fname+0x97>
  count       = 4;
  8041602bee:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  8041602bf3:	48 98                	cltq   
  8041602bf5:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602bf9:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602bfe:	4c 89 ee             	mov    %r13,%rsi
  8041602c01:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c05:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041602c0c:	00 00 00 
  8041602c0f:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602c11:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  8041602c15:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602c19:	83 e8 02             	sub    $0x2,%eax
  8041602c1c:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602c20:	0f 85 df fd ff ff    	jne    8041602a05 <address_by_fname+0x287>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602c26:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602c2b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c2f:	49 be 6a b5 60 41 80 	movabs $0x804160b56a,%r14
  8041602c36:	00 00 00 
  8041602c39:	41 ff d6             	callq  *%r14
  8041602c3c:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602c40:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c44:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  8041602c47:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602c4b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602c50:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c54:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  8041602c57:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602c5b:	0f 85 d9 fd ff ff    	jne    8041602a3a <address_by_fname+0x2bc>
  count  = 0;
  8041602c61:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602c63:	89 d9                	mov    %ebx,%ecx
  8041602c65:	4c 89 fa             	mov    %r15,%rdx
  result = 0;
  8041602c68:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602c6e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602c71:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c75:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602c78:	89 f0                	mov    %esi,%eax
  8041602c7a:	83 e0 7f             	and    $0x7f,%eax
  8041602c7d:	d3 e0                	shl    %cl,%eax
  8041602c7f:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602c82:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c85:	40 84 f6             	test   %sil,%sil
  8041602c88:	78 e4                	js     8041602c6e <address_by_fname+0x4f0>
  return count;
  8041602c8a:	48 63 ff             	movslq %edi,%rdi
        entry += count;
  8041602c8d:	49 01 ff             	add    %rdi,%r15
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c90:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c94:	4c 8b 58 08          	mov    0x8(%rax),%r11
        unsigned name = 0, form = 0, tag = 0;
  8041602c98:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602c9e:	4d 39 e3             	cmp    %r12,%r11
  8041602ca1:	0f 86 c8 fd ff ff    	jbe    8041602a6f <address_by_fname+0x2f1>
  count  = 0;
  8041602ca7:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602caa:	89 d9                	mov    %ebx,%ecx
  8041602cac:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602caf:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602cb4:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602cb7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cbb:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cbf:	89 f8                	mov    %edi,%eax
  8041602cc1:	83 e0 7f             	and    $0x7f,%eax
  8041602cc4:	d3 e0                	shl    %cl,%eax
  8041602cc6:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602cc8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ccb:	40 84 ff             	test   %dil,%dil
  8041602cce:	78 e4                	js     8041602cb4 <address_by_fname+0x536>
  return count;
  8041602cd0:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry += count;
  8041602cd3:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602cd6:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602cd9:	89 d9                	mov    %ebx,%ecx
  8041602cdb:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602cde:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602ce4:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602ce7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ceb:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cef:	89 f8                	mov    %edi,%eax
  8041602cf1:	83 e0 7f             	and    $0x7f,%eax
  8041602cf4:	d3 e0                	shl    %cl,%eax
  8041602cf6:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602cf9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cfc:	40 84 ff             	test   %dil,%dil
  8041602cff:	78 e3                	js     8041602ce4 <address_by_fname+0x566>
  return count;
  8041602d01:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry++;
  8041602d04:	4f 8d 64 04 01       	lea    0x1(%r12,%r8,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602d09:	41 39 f2             	cmp    %esi,%r10d
  8041602d0c:	0f 84 5d fd ff ff    	je     8041602a6f <address_by_fname+0x2f1>
  count  = 0;
  8041602d12:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602d15:	89 d9                	mov    %ebx,%ecx
  8041602d17:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d1a:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602d1f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d22:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d26:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602d2a:	89 f0                	mov    %esi,%eax
  8041602d2c:	83 e0 7f             	and    $0x7f,%eax
  8041602d2f:	d3 e0                	shl    %cl,%eax
  8041602d31:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602d33:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d36:	40 84 f6             	test   %sil,%sil
  8041602d39:	78 e4                	js     8041602d1f <address_by_fname+0x5a1>
  return count;
  8041602d3b:	4d 63 c0             	movslq %r8d,%r8
            abbrev_entry += count;
  8041602d3e:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602d41:	41 89 dd             	mov    %ebx,%r13d
  shift  = 0;
  8041602d44:	89 d9                	mov    %ebx,%ecx
  8041602d46:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d49:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d4f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d52:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d56:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041602d5a:	89 f0                	mov    %esi,%eax
  8041602d5c:	83 e0 7f             	and    $0x7f,%eax
  8041602d5f:	d3 e0                	shl    %cl,%eax
  8041602d61:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602d64:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d67:	40 84 f6             	test   %sil,%sil
  8041602d6a:	78 e3                	js     8041602d4f <address_by_fname+0x5d1>
  return count;
  8041602d6c:	4d 63 ed             	movslq %r13d,%r13
            abbrev_entry += count;
  8041602d6f:	4d 01 ec             	add    %r13,%r12
          } while (name != 0 || form != 0);
  8041602d72:	41 09 f8             	or     %edi,%r8d
  8041602d75:	75 9b                	jne    8041602d12 <address_by_fname+0x594>
  8041602d77:	e9 22 ff ff ff       	jmpq   8041602c9e <address_by_fname+0x520>

0000008041602d7c <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602d7c:	55                   	push   %rbp
  8041602d7d:	48 89 e5             	mov    %rsp,%rbp
  8041602d80:	41 57                	push   %r15
  8041602d82:	41 56                	push   %r14
  8041602d84:	41 55                	push   %r13
  8041602d86:	41 54                	push   %r12
  8041602d88:	53                   	push   %rbx
  8041602d89:	48 83 ec 48          	sub    $0x48,%rsp
  8041602d8d:	48 89 fb             	mov    %rdi,%rbx
  8041602d90:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602d94:	48 89 f7             	mov    %rsi,%rdi
  8041602d97:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602d9b:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602d9f:	48 b8 f1 b2 60 41 80 	movabs $0x804160b2f1,%rax
  8041602da6:	00 00 00 
  8041602da9:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602dab:	85 c0                	test   %eax,%eax
  8041602dad:	0f 84 73 03 00 00    	je     8041603126 <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602db3:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602db7:	e9 0f 03 00 00       	jmpq   80416030cb <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602dbc:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602dc0:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602dc5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602dc9:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041602dd0:	00 00 00 
  8041602dd3:	ff d0                	callq  *%rax
  8041602dd5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602dd9:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602dde:	eb 07                	jmp    8041602de7 <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602de0:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602de2:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602de7:	48 63 db             	movslq %ebx,%rbx
  8041602dea:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602dee:	4c 01 e8             	add    %r13,%rax
  8041602df1:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602df5:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602dfa:	4c 89 ee             	mov    %r13,%rsi
  8041602dfd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e01:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041602e08:	00 00 00 
  8041602e0b:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602e0d:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602e11:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602e15:	83 e8 02             	sub    $0x2,%eax
  8041602e18:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602e1c:	75 52                	jne    8041602e70 <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602e1e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602e23:	4c 89 ee             	mov    %r13,%rsi
  8041602e26:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e2a:	49 be 6a b5 60 41 80 	movabs $0x804160b56a,%r14
  8041602e31:	00 00 00 
  8041602e34:	41 ff d6             	callq  *%r14
  8041602e37:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602e3b:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602e40:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602e44:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602e49:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e4d:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602e50:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602e54:	75 4f                	jne    8041602ea5 <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602e56:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e5a:	4c 03 20             	add    (%rax),%r12
  8041602e5d:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602e61:	49 be 52 0d 60 41 80 	movabs $0x8041600d52,%r14
  8041602e68:	00 00 00 
    while (entry < entry_end) {
  8041602e6b:	e9 11 02 00 00       	jmpq   8041603081 <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602e70:	48 b9 2e c0 60 41 80 	movabs $0x804160c02e,%rcx
  8041602e77:	00 00 00 
  8041602e7a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041602e81:	00 00 00 
  8041602e84:	be f0 02 00 00       	mov    $0x2f0,%esi
  8041602e89:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041602e90:	00 00 00 
  8041602e93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e98:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602e9f:	00 00 00 
  8041602ea2:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602ea5:	48 b9 fb bf 60 41 80 	movabs $0x804160bffb,%rcx
  8041602eac:	00 00 00 
  8041602eaf:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041602eb6:	00 00 00 
  8041602eb9:	be f4 02 00 00       	mov    $0x2f4,%esi
  8041602ebe:	48 bf ee bf 60 41 80 	movabs $0x804160bfee,%rdi
  8041602ec5:	00 00 00 
  8041602ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ecd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602ed4:	00 00 00 
  8041602ed7:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602eda:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602ede:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602ee2:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602ee6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602eec:	49 39 db             	cmp    %rbx,%r11
  8041602eef:	0f 86 e7 00 00 00    	jbe    8041602fdc <naive_address_by_fname+0x260>
  8041602ef5:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ef8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602efe:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f03:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602f08:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f0b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f0f:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f13:	89 f8                	mov    %edi,%eax
  8041602f15:	83 e0 7f             	and    $0x7f,%eax
  8041602f18:	d3 e0                	shl    %cl,%eax
  8041602f1a:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602f1c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f1f:	40 84 ff             	test   %dil,%dil
  8041602f22:	78 e4                	js     8041602f08 <naive_address_by_fname+0x18c>
  return count;
  8041602f24:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602f27:	4c 01 c3             	add    %r8,%rbx
  8041602f2a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f2d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602f33:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f38:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602f3e:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f41:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f45:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f49:	89 f8                	mov    %edi,%eax
  8041602f4b:	83 e0 7f             	and    $0x7f,%eax
  8041602f4e:	d3 e0                	shl    %cl,%eax
  8041602f50:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602f53:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f56:	40 84 ff             	test   %dil,%dil
  8041602f59:	78 e3                	js     8041602f3e <naive_address_by_fname+0x1c2>
  return count;
  8041602f5b:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602f5e:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602f63:	41 39 f2             	cmp    %esi,%r10d
  8041602f66:	74 74                	je     8041602fdc <naive_address_by_fname+0x260>
  result = 0;
  8041602f68:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f6b:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f70:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f75:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602f7b:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f7e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f82:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f85:	89 f0                	mov    %esi,%eax
  8041602f87:	83 e0 7f             	and    $0x7f,%eax
  8041602f8a:	d3 e0                	shl    %cl,%eax
  8041602f8c:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602f8f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f92:	40 84 f6             	test   %sil,%sil
  8041602f95:	78 e4                	js     8041602f7b <naive_address_by_fname+0x1ff>
  return count;
  8041602f97:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f9a:	48 01 fb             	add    %rdi,%rbx
  8041602f9d:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fa0:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602faa:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602fb0:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fb3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602fb7:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602fba:	89 f0                	mov    %esi,%eax
  8041602fbc:	83 e0 7f             	and    $0x7f,%eax
  8041602fbf:	d3 e0                	shl    %cl,%eax
  8041602fc1:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602fc4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602fc7:	40 84 f6             	test   %sil,%sil
  8041602fca:	78 e4                	js     8041602fb0 <naive_address_by_fname+0x234>
  return count;
  8041602fcc:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fcf:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  8041602fd2:	45 09 c4             	or     %r8d,%r12d
  8041602fd5:	75 91                	jne    8041602f68 <naive_address_by_fname+0x1ec>
  8041602fd7:	e9 10 ff ff ff       	jmpq   8041602eec <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602fdc:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602fe0:	0f 84 4f 01 00 00    	je     8041603135 <naive_address_by_fname+0x3b9>
  8041602fe6:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602fea:	0f 84 45 01 00 00    	je     8041603135 <naive_address_by_fname+0x3b9>
                found = 1;
  8041602ff0:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ff3:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602ff8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602ffd:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041603003:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603006:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160300a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160300d:	89 f0                	mov    %esi,%eax
  804160300f:	83 e0 7f             	and    $0x7f,%eax
  8041603012:	d3 e0                	shl    %cl,%eax
  8041603014:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041603017:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160301a:	40 84 f6             	test   %sil,%sil
  804160301d:	78 e4                	js     8041603003 <naive_address_by_fname+0x287>
  return count;
  804160301f:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  8041603022:	48 01 fb             	add    %rdi,%rbx
  8041603025:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603028:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160302d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603032:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603038:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160303b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160303f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603042:	89 f0                	mov    %esi,%eax
  8041603044:	83 e0 7f             	and    $0x7f,%eax
  8041603047:	d3 e0                	shl    %cl,%eax
  8041603049:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160304c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160304f:	40 84 f6             	test   %sil,%sil
  8041603052:	78 e4                	js     8041603038 <naive_address_by_fname+0x2bc>
  return count;
  8041603054:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  8041603057:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  804160305a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603060:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603065:	ba 00 00 00 00       	mov    $0x0,%edx
  804160306a:	44 89 e6             	mov    %r12d,%esi
  804160306d:	4c 89 ff             	mov    %r15,%rdi
  8041603070:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  8041603073:	48 98                	cltq   
  8041603075:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603078:	45 09 ec             	or     %r13d,%r12d
  804160307b:	0f 85 6f ff ff ff    	jne    8041602ff0 <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  8041603081:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  8041603085:	73 44                	jae    80416030cb <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  8041603087:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  804160308a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160308f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603094:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  804160309a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160309d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416030a1:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416030a4:	89 f0                	mov    %esi,%eax
  80416030a6:	83 e0 7f             	and    $0x7f,%eax
  80416030a9:	d3 e0                	shl    %cl,%eax
  80416030ab:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  80416030ae:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416030b1:	40 84 f6             	test   %sil,%sil
  80416030b4:	78 e4                	js     804160309a <naive_address_by_fname+0x31e>
  return count;
  80416030b6:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  80416030b9:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  80416030bc:	45 85 d2             	test   %r10d,%r10d
  80416030bf:	0f 85 15 fe ff ff    	jne    8041602eda <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  80416030c5:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  80416030c9:	77 bc                	ja     8041603087 <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  80416030cb:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416030cf:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  80416030d3:	0f 86 ee 01 00 00    	jbe    80416032c7 <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  80416030d9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416030de:	4c 89 fe             	mov    %r15,%rsi
  80416030e1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030e5:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416030ec:	00 00 00 
  80416030ef:	ff d0                	callq  *%rax
  80416030f1:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416030f4:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416030f7:	0f 86 e3 fc ff ff    	jbe    8041602de0 <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  80416030fd:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041603100:	0f 84 b6 fc ff ff    	je     8041602dbc <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  8041603106:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  804160310d:	00 00 00 
  8041603110:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603115:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160311c:	00 00 00 
  804160311f:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041603121:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  8041603126:	48 83 c4 48          	add    $0x48,%rsp
  804160312a:	5b                   	pop    %rbx
  804160312b:	41 5c                	pop    %r12
  804160312d:	41 5d                	pop    %r13
  804160312f:	41 5e                	pop    %r14
  8041603131:	41 5f                	pop    %r15
  8041603133:	5d                   	pop    %rbp
  8041603134:	c3                   	retq   
        uintptr_t low_pc = 0;
  8041603135:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160313c:	00 
        int found        = 0;
  804160313d:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041603144:	eb 21                	jmp    8041603167 <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  8041603146:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160314c:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603151:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041603155:	44 89 ee             	mov    %r13d,%esi
  8041603158:	4c 89 ff             	mov    %r15,%rdi
  804160315b:	41 ff d6             	callq  *%r14
  804160315e:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  8041603161:	49 63 c4             	movslq %r12d,%rax
  8041603164:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  8041603167:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160316a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160316f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603174:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  804160317a:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160317d:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603181:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041603184:	89 f0                	mov    %esi,%eax
  8041603186:	83 e0 7f             	and    $0x7f,%eax
  8041603189:	d3 e0                	shl    %cl,%eax
  804160318b:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160318e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603191:	40 84 f6             	test   %sil,%sil
  8041603194:	78 e4                	js     804160317a <naive_address_by_fname+0x3fe>
  return count;
  8041603196:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041603199:	48 01 fb             	add    %rdi,%rbx
  804160319c:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160319f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416031a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416031a9:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416031af:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416031b2:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416031b6:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416031b9:	89 f0                	mov    %esi,%eax
  80416031bb:	83 e0 7f             	and    $0x7f,%eax
  80416031be:	d3 e0                	shl    %cl,%eax
  80416031c0:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416031c3:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416031c6:	40 84 f6             	test   %sil,%sil
  80416031c9:	78 e4                	js     80416031af <naive_address_by_fname+0x433>
  return count;
  80416031cb:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  80416031ce:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  80416031d1:	41 83 fc 11          	cmp    $0x11,%r12d
  80416031d5:	0f 84 6b ff ff ff    	je     8041603146 <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  80416031db:	41 83 fc 03          	cmp    $0x3,%r12d
  80416031df:	0f 85 9c 00 00 00    	jne    8041603281 <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  80416031e5:	41 83 fd 0e          	cmp    $0xe,%r13d
  80416031e9:	74 42                	je     804160322d <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  80416031eb:	4c 89 fe             	mov    %r15,%rsi
  80416031ee:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  80416031f2:	48 b8 00 b4 60 41 80 	movabs $0x804160b400,%rax
  80416031f9:	00 00 00 
  80416031fc:	ff d0                	callq  *%rax
                found = 1;
  80416031fe:	85 c0                	test   %eax,%eax
  8041603200:	b8 01 00 00 00       	mov    $0x1,%eax
  8041603205:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603209:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  804160320c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603212:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603217:	ba 00 00 00 00       	mov    $0x0,%edx
  804160321c:	44 89 ee             	mov    %r13d,%esi
  804160321f:	4c 89 ff             	mov    %r15,%rdi
  8041603222:	41 ff d6             	callq  *%r14
  8041603225:	41 89 c4             	mov    %eax,%r12d
  8041603228:	e9 34 ff ff ff       	jmpq   8041603161 <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  804160322d:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041603234:	00 
              count          = dwarf_read_abbrev_entry(
  8041603235:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160323b:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041603240:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041603244:	be 0e 00 00 00       	mov    $0xe,%esi
  8041603249:	4c 89 ff             	mov    %r15,%rdi
  804160324c:	41 ff d6             	callq  *%r14
  804160324f:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  8041603252:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041603256:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160325a:	48 03 70 40          	add    0x40(%rax),%rsi
  804160325e:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041603262:	48 b8 00 b4 60 41 80 	movabs $0x804160b400,%rax
  8041603269:	00 00 00 
  804160326c:	ff d0                	callq  *%rax
                found = 1;
  804160326e:	85 c0                	test   %eax,%eax
  8041603270:	b8 01 00 00 00       	mov    $0x1,%eax
  8041603275:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603279:	89 45 bc             	mov    %eax,-0x44(%rbp)
  804160327c:	e9 e0 fe ff ff       	jmpq   8041603161 <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  8041603281:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603287:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160328c:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603291:	44 89 ee             	mov    %r13d,%esi
  8041603294:	4c 89 ff             	mov    %r15,%rdi
  8041603297:	41 ff d6             	callq  *%r14
          entry += count;
  804160329a:	48 98                	cltq   
  804160329c:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  804160329f:	45 09 e5             	or     %r12d,%r13d
  80416032a2:	0f 85 bf fe ff ff    	jne    8041603167 <naive_address_by_fname+0x3eb>
        if (found) {
  80416032a8:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  80416032ac:	0f 84 cf fd ff ff    	je     8041603081 <naive_address_by_fname+0x305>
          *offset = low_pc;
  80416032b2:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416032b6:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  80416032ba:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  80416032bd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032c2:	e9 5f fe ff ff       	jmpq   8041603126 <naive_address_by_fname+0x3aa>
  return 0;
  80416032c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032cc:	e9 55 fe ff ff       	jmpq   8041603126 <naive_address_by_fname+0x3aa>

00000080416032d1 <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  80416032d1:	55                   	push   %rbp
  80416032d2:	48 89 e5             	mov    %rsp,%rbp
  80416032d5:	41 57                	push   %r15
  80416032d7:	41 56                	push   %r14
  80416032d9:	41 55                	push   %r13
  80416032db:	41 54                	push   %r12
  80416032dd:	53                   	push   %rbx
  80416032de:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  80416032e2:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  80416032e6:	48 8b 47 38          	mov    0x38(%rdi),%rax
  80416032ea:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  80416032ed:	48 39 d0             	cmp    %rdx,%rax
  80416032f0:	0f 82 d9 06 00 00    	jb     80416039cf <line_for_address+0x6fe>
  80416032f6:	48 85 c9             	test   %rcx,%rcx
  80416032f9:	0f 84 d0 06 00 00    	je     80416039cf <line_for_address+0x6fe>
  80416032ff:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  8041603303:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  8041603307:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160330a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160330f:	48 89 de             	mov    %rbx,%rsi
  8041603312:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603316:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160331d:	00 00 00 
  8041603320:	ff d0                	callq  *%rax
  8041603322:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603325:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041603328:	76 4e                	jbe    8041603378 <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  804160332a:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160332d:	74 25                	je     8041603354 <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  804160332f:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  8041603336:	00 00 00 
  8041603339:	b8 00 00 00 00       	mov    $0x0,%eax
  804160333e:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041603345:	00 00 00 
  8041603348:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  804160334a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  804160334f:	e9 6c 06 00 00       	jmpq   80416039c0 <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603354:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041603358:	ba 08 00 00 00       	mov    $0x8,%edx
  804160335d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603361:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041603368:	00 00 00 
  804160336b:	ff d0                	callq  *%rax
  804160336d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041603371:	be 0c 00 00 00       	mov    $0xc,%esi
  8041603376:	eb 07                	jmp    804160337f <line_for_address+0xae>
    *len = initial_len;
  8041603378:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160337a:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  804160337f:	48 63 f6             	movslq %esi,%rsi
  8041603382:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  8041603385:	48 01 d8             	add    %rbx,%rax
  8041603388:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  804160338c:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603391:	48 89 de             	mov    %rbx,%rsi
  8041603394:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603398:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160339f:	00 00 00 
  80416033a2:	ff d0                	callq  *%rax
  80416033a4:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  80416033a9:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  80416033ad:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  80416033b1:	66 83 f8 02          	cmp    $0x2,%ax
  80416033b5:	77 51                	ja     8041603408 <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  80416033b7:	ba 04 00 00 00       	mov    $0x4,%edx
  80416033bc:	4c 89 e6             	mov    %r12,%rsi
  80416033bf:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416033c3:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416033ca:	00 00 00 
  80416033cd:	ff d0                	callq  *%rax
  80416033cf:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416033d3:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  80416033d7:	0f 86 84 00 00 00    	jbe    8041603461 <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  80416033dd:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  80416033e1:	74 5a                	je     804160343d <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  80416033e3:	48 bf c0 bf 60 41 80 	movabs $0x804160bfc0,%rdi
  80416033ea:	00 00 00 
  80416033ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033f2:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416033f9:	00 00 00 
  80416033fc:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416033fe:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041603403:	e9 b8 05 00 00       	jmpq   80416039c0 <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  8041603408:	48 b9 e8 c1 60 41 80 	movabs $0x804160c1e8,%rcx
  804160340f:	00 00 00 
  8041603412:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041603419:	00 00 00 
  804160341c:	be fc 00 00 00       	mov    $0xfc,%esi
  8041603421:	48 bf a1 c1 60 41 80 	movabs $0x804160c1a1,%rdi
  8041603428:	00 00 00 
  804160342b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603430:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603437:	00 00 00 
  804160343a:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160343d:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  8041603441:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603446:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160344a:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041603451:	00 00 00 
  8041603454:	ff d0                	callq  *%rax
  8041603456:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  804160345a:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160345f:	eb 08                	jmp    8041603469 <line_for_address+0x198>
    *len = initial_len;
  8041603461:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  8041603464:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  8041603469:	48 98                	cltq   
  804160346b:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  804160346e:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  8041603471:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603476:	4c 89 e6             	mov    %r12,%rsi
  8041603479:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160347d:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041603484:	00 00 00 
  8041603487:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  8041603489:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  804160348d:	0f 85 89 00 00 00    	jne    804160351c <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  8041603493:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  8041603498:	66 41 83 ff 04       	cmp    $0x4,%r15w
  804160349d:	0f 84 ae 00 00 00    	je     8041603551 <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  80416034a3:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  80416034a7:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034ac:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034b0:	49 bc 6a b5 60 41 80 	movabs $0x804160b56a,%r12
  80416034b7:	00 00 00 
  80416034ba:	41 ff d4             	callq  *%r12
  80416034bd:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034c1:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  80416034c4:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  80416034c8:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034cd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034d1:	41 ff d4             	callq  *%r12
  80416034d4:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034d8:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034db:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  80416034df:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034e4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034e8:	41 ff d4             	callq  *%r12
  80416034eb:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034ef:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  80416034f2:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  80416034f6:	ba 08 00 00 00       	mov    $0x8,%edx
  80416034fb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034ff:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  8041603502:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  8041603506:	0f 86 90 04 00 00    	jbe    804160399c <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  804160350c:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  8041603512:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041603517:	e9 32 04 00 00       	jmpq   804160394e <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  804160351c:	48 b9 18 c2 60 41 80 	movabs $0x804160c218,%rcx
  8041603523:	00 00 00 
  8041603526:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160352d:	00 00 00 
  8041603530:	be 07 01 00 00       	mov    $0x107,%esi
  8041603535:	48 bf a1 c1 60 41 80 	movabs $0x804160c1a1,%rdi
  804160353c:	00 00 00 
  804160353f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603544:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160354b:	00 00 00 
  804160354e:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  8041603551:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603556:	48 89 de             	mov    %rbx,%rsi
  8041603559:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160355d:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041603564:	00 00 00 
  8041603567:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  8041603569:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  804160356e:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  8041603572:	0f 84 2b ff ff ff    	je     80416034a3 <line_for_address+0x1d2>
  8041603578:	48 b9 38 c2 60 41 80 	movabs $0x804160c238,%rcx
  804160357f:	00 00 00 
  8041603582:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041603589:	00 00 00 
  804160358c:	be 11 01 00 00       	mov    $0x111,%esi
  8041603591:	48 bf a1 c1 60 41 80 	movabs $0x804160c1a1,%rdi
  8041603598:	00 00 00 
  804160359b:	b8 00 00 00 00       	mov    $0x0,%eax
  80416035a0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416035a7:	00 00 00 
  80416035aa:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  80416035ad:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  80416035b0:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  80416035b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416035bb:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  80416035c1:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  80416035c4:	48 83 c0 01          	add    $0x1,%rax
    count++;
  80416035c8:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  80416035cc:	89 fa                	mov    %edi,%edx
  80416035ce:	83 e2 7f             	and    $0x7f,%edx
  80416035d1:	d3 e2                	shl    %cl,%edx
  80416035d3:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  80416035d6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416035d9:	40 84 ff             	test   %dil,%dil
  80416035dc:	78 e3                	js     80416035c1 <line_for_address+0x2f0>
  return count;
  80416035de:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  80416035e1:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  80416035e4:	45 89 ff             	mov    %r15d,%r15d
  80416035e7:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  80416035ea:	ba 01 00 00 00       	mov    $0x1,%edx
  80416035ef:	4c 89 ee             	mov    %r13,%rsi
  80416035f2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416035f6:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416035fd:	00 00 00 
  8041603600:	ff d0                	callq  *%rax
  8041603602:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  8041603606:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  804160360a:	3c 02                	cmp    $0x2,%al
  804160360c:	0f 84 dc 00 00 00    	je     80416036ee <line_for_address+0x41d>
  8041603612:	76 39                	jbe    804160364d <line_for_address+0x37c>
  8041603614:	3c 03                	cmp    $0x3,%al
  8041603616:	74 62                	je     804160367a <line_for_address+0x3a9>
  8041603618:	3c 04                	cmp    $0x4,%al
  804160361a:	0f 85 0c 01 00 00    	jne    804160372c <line_for_address+0x45b>
  8041603620:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603623:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603628:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160362b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160362f:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603632:	84 c9                	test   %cl,%cl
  8041603634:	78 f2                	js     8041603628 <line_for_address+0x357>
  return count;
  8041603636:	48 98                	cltq   
          program_addr += count;
  8041603638:	48 01 c6             	add    %rax,%rsi
  804160363b:	44 89 e2             	mov    %r12d,%edx
  804160363e:	48 89 d8             	mov    %rbx,%rax
  8041603641:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603645:	4c 89 f3             	mov    %r14,%rbx
  8041603648:	e9 c8 00 00 00       	jmpq   8041603715 <line_for_address+0x444>
      switch (opcode) {
  804160364d:	3c 01                	cmp    $0x1,%al
  804160364f:	0f 85 d7 00 00 00    	jne    804160372c <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  8041603655:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603659:	49 39 c6             	cmp    %rax,%r14
  804160365c:	0f 87 f8 00 00 00    	ja     804160375a <line_for_address+0x489>
  8041603662:	48 39 d8             	cmp    %rbx,%rax
  8041603665:	0f 82 39 03 00 00    	jb     80416039a4 <line_for_address+0x6d3>
          state->line          = 1;
  804160366b:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  8041603670:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603675:	e9 9b 00 00 00       	jmpq   8041603715 <line_for_address+0x444>
          while (*(char *)program_addr) {
  804160367a:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  804160367f:	74 09                	je     804160368a <line_for_address+0x3b9>
            ++program_addr;
  8041603681:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  8041603685:	80 3e 00             	cmpb   $0x0,(%rsi)
  8041603688:	75 f7                	jne    8041603681 <line_for_address+0x3b0>
          ++program_addr;
  804160368a:	48 83 c6 01          	add    $0x1,%rsi
  804160368e:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603691:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603696:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603699:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160369d:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036a0:	84 c9                	test   %cl,%cl
  80416036a2:	78 f2                	js     8041603696 <line_for_address+0x3c5>
  return count;
  80416036a4:	48 98                	cltq   
          program_addr += count;
  80416036a6:	48 01 c6             	add    %rax,%rsi
  80416036a9:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416036ac:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036b1:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036b4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036b8:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036bb:	84 c9                	test   %cl,%cl
  80416036bd:	78 f2                	js     80416036b1 <line_for_address+0x3e0>
  return count;
  80416036bf:	48 98                	cltq   
          program_addr += count;
  80416036c1:	48 01 c6             	add    %rax,%rsi
  80416036c4:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416036c7:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036cc:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036cf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036d3:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036d6:	84 c9                	test   %cl,%cl
  80416036d8:	78 f2                	js     80416036cc <line_for_address+0x3fb>
  return count;
  80416036da:	48 98                	cltq   
          program_addr += count;
  80416036dc:	48 01 c6             	add    %rax,%rsi
  80416036df:	44 89 e2             	mov    %r12d,%edx
  80416036e2:	48 89 d8             	mov    %rbx,%rax
  80416036e5:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036e9:	4c 89 f3             	mov    %r14,%rbx
  80416036ec:	eb 27                	jmp    8041603715 <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  80416036ee:	ba 08 00 00 00       	mov    $0x8,%edx
  80416036f3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416036f7:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416036fe:	00 00 00 
  8041603701:	ff d0                	callq  *%rax
  8041603703:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  8041603707:	49 8d 75 09          	lea    0x9(%r13),%rsi
  804160370b:	44 89 e2             	mov    %r12d,%edx
  804160370e:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603712:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  8041603715:	49 39 f7             	cmp    %rsi,%r15
  8041603718:	75 4c                	jne    8041603766 <line_for_address+0x495>
  804160371a:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160371e:	41 89 d4             	mov    %edx,%r12d
  8041603721:	49 89 de             	mov    %rbx,%r14
  8041603724:	48 89 c3             	mov    %rax,%rbx
  8041603727:	e9 19 02 00 00       	jmpq   8041603945 <line_for_address+0x674>
      switch (opcode) {
  804160372c:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  804160372f:	48 ba b4 c1 60 41 80 	movabs $0x804160c1b4,%rdx
  8041603736:	00 00 00 
  8041603739:	be 6b 00 00 00       	mov    $0x6b,%esi
  804160373e:	48 bf a1 c1 60 41 80 	movabs $0x804160c1a1,%rdi
  8041603745:	00 00 00 
  8041603748:	b8 00 00 00 00       	mov    $0x0,%eax
  804160374d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603754:	00 00 00 
  8041603757:	41 ff d0             	callq  *%r8
          state->line          = 1;
  804160375a:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  804160375f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603764:	eb af                	jmp    8041603715 <line_for_address+0x444>
      assert(program_addr == opcode_end);
  8041603766:	48 b9 c7 c1 60 41 80 	movabs $0x804160c1c7,%rcx
  804160376d:	00 00 00 
  8041603770:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041603777:	00 00 00 
  804160377a:	be 6e 00 00 00       	mov    $0x6e,%esi
  804160377f:	48 bf a1 c1 60 41 80 	movabs $0x804160c1a1,%rdi
  8041603786:	00 00 00 
  8041603789:	b8 00 00 00 00       	mov    $0x0,%eax
  804160378e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603795:	00 00 00 
  8041603798:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  804160379b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160379f:	49 39 c6             	cmp    %rax,%r14
  80416037a2:	0f 87 eb 01 00 00    	ja     8041603993 <line_for_address+0x6c2>
  80416037a8:	48 39 d8             	cmp    %rbx,%rax
  80416037ab:	0f 82 f9 01 00 00    	jb     80416039aa <line_for_address+0x6d9>
          last_state           = *state;
  80416037b1:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416037b5:	49 89 de             	mov    %rbx,%r14
  80416037b8:	e9 88 01 00 00       	jmpq   8041603945 <line_for_address+0x674>
      switch (opcode) {
  80416037bd:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037c0:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416037c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416037ca:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  80416037cf:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  80416037d3:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  80416037d7:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  80416037da:	45 89 c8             	mov    %r9d,%r8d
  80416037dd:	41 83 e0 7f          	and    $0x7f,%r8d
  80416037e1:	41 d3 e0             	shl    %cl,%r8d
  80416037e4:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  80416037e7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416037ea:	45 84 c9             	test   %r9b,%r9b
  80416037ed:	78 e0                	js     80416037cf <line_for_address+0x4fe>
              info->minimum_instruction_length *
  80416037ef:	89 d2                	mov    %edx,%edx
          state->address +=
  80416037f1:	48 01 d3             	add    %rdx,%rbx
  return count;
  80416037f4:	48 98                	cltq   
          program_addr += count;
  80416037f6:	48 01 c6             	add    %rax,%rsi
        } break;
  80416037f9:	e9 47 01 00 00       	jmpq   8041603945 <line_for_address+0x674>
      switch (opcode) {
  80416037fe:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  8041603801:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041603806:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160380b:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603810:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041603814:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  8041603818:	45 89 c8             	mov    %r9d,%r8d
  804160381b:	41 83 e0 7f          	and    $0x7f,%r8d
  804160381f:	41 d3 e0             	shl    %cl,%r8d
  8041603822:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  8041603825:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041603828:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160382b:	45 84 c9             	test   %r9b,%r9b
  804160382e:	78 e0                	js     8041603810 <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  8041603830:	83 f9 1f             	cmp    $0x1f,%ecx
  8041603833:	7f 0f                	jg     8041603844 <line_for_address+0x573>
  8041603835:	41 f6 c1 40          	test   $0x40,%r9b
  8041603839:	74 09                	je     8041603844 <line_for_address+0x573>
    result |= (-1U << shift);
  804160383b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8041603840:	d3 e7                	shl    %cl,%edi
  8041603842:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  8041603844:	41 01 d4             	add    %edx,%r12d
  return count;
  8041603847:	48 98                	cltq   
          program_addr += count;
  8041603849:	48 01 c6             	add    %rax,%rsi
        } break;
  804160384c:	e9 f4 00 00 00       	jmpq   8041603945 <line_for_address+0x674>
      switch (opcode) {
  8041603851:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603854:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603859:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160385c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603860:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603863:	84 c9                	test   %cl,%cl
  8041603865:	78 f2                	js     8041603859 <line_for_address+0x588>
  return count;
  8041603867:	48 98                	cltq   
          program_addr += count;
  8041603869:	48 01 c6             	add    %rax,%rsi
        } break;
  804160386c:	e9 d4 00 00 00       	jmpq   8041603945 <line_for_address+0x674>
      switch (opcode) {
  8041603871:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603874:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603879:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160387c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603880:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603883:	84 c9                	test   %cl,%cl
  8041603885:	78 f2                	js     8041603879 <line_for_address+0x5a8>
  return count;
  8041603887:	48 98                	cltq   
          program_addr += count;
  8041603889:	48 01 c6             	add    %rax,%rsi
        } break;
  804160388c:	e9 b4 00 00 00       	jmpq   8041603945 <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  8041603891:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  8041603895:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  8041603897:	0f b6 c0             	movzbl %al,%eax
  804160389a:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  804160389d:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  80416038a0:	48 01 c3             	add    %rax,%rbx
        } break;
  80416038a3:	e9 9d 00 00 00       	jmpq   8041603945 <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  80416038a8:	ba 02 00 00 00       	mov    $0x2,%edx
  80416038ad:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416038b1:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  80416038b8:	00 00 00 
  80416038bb:	ff d0                	callq  *%rax
          state->address += pc_inc;
  80416038bd:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416038c1:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  80416038c4:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  80416038c8:	eb 7b                	jmp    8041603945 <line_for_address+0x674>
      switch (opcode) {
  80416038ca:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416038cd:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416038d2:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416038d5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416038d9:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416038dc:	84 c9                	test   %cl,%cl
  80416038de:	78 f2                	js     80416038d2 <line_for_address+0x601>
  return count;
  80416038e0:	48 98                	cltq   
          program_addr += count;
  80416038e2:	48 01 c6             	add    %rax,%rsi
        } break;
  80416038e5:	eb 5e                	jmp    8041603945 <line_for_address+0x674>
      switch (opcode) {
  80416038e7:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  80416038ea:	48 ba b4 c1 60 41 80 	movabs $0x804160c1b4,%rdx
  80416038f1:	00 00 00 
  80416038f4:	be c1 00 00 00       	mov    $0xc1,%esi
  80416038f9:	48 bf a1 c1 60 41 80 	movabs $0x804160c1a1,%rdi
  8041603900:	00 00 00 
  8041603903:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603908:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160390f:	00 00 00 
  8041603912:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  8041603915:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  8041603918:	0f b6 c0             	movzbl %al,%eax
  804160391b:	f6 75 ba             	divb   -0x46(%rbp)
  804160391e:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  8041603921:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  8041603925:	01 ca                	add    %ecx,%edx
  8041603927:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  804160392a:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  804160392d:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  8041603930:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603934:	49 39 c6             	cmp    %rax,%r14
  8041603937:	77 05                	ja     804160393e <line_for_address+0x66d>
  8041603939:	48 39 d8             	cmp    %rbx,%rax
  804160393c:	72 72                	jb     80416039b0 <line_for_address+0x6df>
      last_state = *state;
  804160393e:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603942:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  8041603945:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  8041603949:	76 69                	jbe    80416039b4 <line_for_address+0x6e3>
  804160394b:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  804160394e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603953:	4c 89 ee             	mov    %r13,%rsi
  8041603956:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160395a:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  8041603961:	00 00 00 
  8041603964:	ff d0                	callq  *%rax
  8041603966:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  804160396a:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  804160396e:	84 c0                	test   %al,%al
  8041603970:	0f 84 37 fc ff ff    	je     80416035ad <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  8041603976:	38 45 bb             	cmp    %al,-0x45(%rbp)
  8041603979:	76 9a                	jbe    8041603915 <line_for_address+0x644>
      switch (opcode) {
  804160397b:	3c 0c                	cmp    $0xc,%al
  804160397d:	0f 87 64 ff ff ff    	ja     80416038e7 <line_for_address+0x616>
  8041603983:	0f b6 d0             	movzbl %al,%edx
  8041603986:	48 bf 60 c2 60 41 80 	movabs $0x804160c260,%rdi
  804160398d:	00 00 00 
  8041603990:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  8041603993:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603997:	49 89 de             	mov    %rbx,%r14
  804160399a:	eb a9                	jmp    8041603945 <line_for_address+0x674>
  struct Line_Number_State current_state = {
  804160399c:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  80416039a2:	eb 10                	jmp    80416039b4 <line_for_address+0x6e3>
            *state = last_state;
  80416039a4:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416039a8:	eb 0a                	jmp    80416039b4 <line_for_address+0x6e3>
            *state = last_state;
  80416039aa:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416039ae:	eb 04                	jmp    80416039b4 <line_for_address+0x6e3>
        *state = last_state;
  80416039b0:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  80416039b4:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80416039b8:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  80416039bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416039c0:	48 83 c4 38          	add    $0x38,%rsp
  80416039c4:	5b                   	pop    %rbx
  80416039c5:	41 5c                	pop    %r12
  80416039c7:	41 5d                	pop    %r13
  80416039c9:	41 5e                	pop    %r14
  80416039cb:	41 5f                	pop    %r15
  80416039cd:	5d                   	pop    %rbp
  80416039ce:	c3                   	retq   
    return -E_INVAL;
  80416039cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416039d4:	eb ea                	jmp    80416039c0 <line_for_address+0x6ef>

00000080416039d6 <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  80416039d6:	55                   	push   %rbp
  80416039d7:	48 89 e5             	mov    %rsp,%rbp
  80416039da:	41 55                	push   %r13
  80416039dc:	41 54                	push   %r12
  80416039de:	53                   	push   %rbx
  80416039df:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  80416039e3:	48 bb 40 c6 60 41 80 	movabs $0x804160c640,%rbx
  80416039ea:	00 00 00 
  80416039ed:	4c 8d ab d8 00 00 00 	lea    0xd8(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  80416039f4:	49 bc 6e 8f 60 41 80 	movabs $0x8041608f6e,%r12
  80416039fb:	00 00 00 
  80416039fe:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  8041603a02:	48 8b 33             	mov    (%rbx),%rsi
  8041603a05:	48 bf c8 c2 60 41 80 	movabs $0x804160c2c8,%rdi
  8041603a0c:	00 00 00 
  8041603a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a14:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  8041603a17:	48 83 c3 18          	add    $0x18,%rbx
  8041603a1b:	4c 39 eb             	cmp    %r13,%rbx
  8041603a1e:	75 de                	jne    80416039fe <mon_help+0x28>
  return 0;
}
  8041603a20:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a25:	48 83 c4 08          	add    $0x8,%rsp
  8041603a29:	5b                   	pop    %rbx
  8041603a2a:	41 5c                	pop    %r12
  8041603a2c:	41 5d                	pop    %r13
  8041603a2e:	5d                   	pop    %rbp
  8041603a2f:	c3                   	retq   

0000008041603a30 <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  8041603a30:	55                   	push   %rbp
  8041603a31:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603a34:	48 bf d1 c2 60 41 80 	movabs $0x804160c2d1,%rdi
  8041603a3b:	00 00 00 
  8041603a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a43:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041603a4a:	00 00 00 
  8041603a4d:	ff d2                	callq  *%rdx
  return 0;
}
  8041603a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a54:	5d                   	pop    %rbp
  8041603a55:	c3                   	retq   

0000008041603a56 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  8041603a56:	55                   	push   %rbp
  8041603a57:	48 89 e5             	mov    %rsp,%rbp
  8041603a5a:	41 55                	push   %r13
  8041603a5c:	41 54                	push   %r12
  8041603a5e:	53                   	push   %rbx
  8041603a5f:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  8041603a63:	48 bf d9 c2 60 41 80 	movabs $0x804160c2d9,%rdi
  8041603a6a:	00 00 00 
  8041603a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a72:	49 bc 6e 8f 60 41 80 	movabs $0x8041608f6e,%r12
  8041603a79:	00 00 00 
  8041603a7c:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  8041603a7f:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  8041603a86:	00 00 00 
  8041603a89:	48 bf 70 c4 60 41 80 	movabs $0x804160c470,%rdi
  8041603a90:	00 00 00 
  8041603a93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a98:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  8041603a9b:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  8041603aa2:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  8041603aa5:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  8041603aac:	00 00 00 
  8041603aaf:	4c 89 ee             	mov    %r13,%rsi
  8041603ab2:	48 bf a0 c4 60 41 80 	movabs $0x804160c4a0,%rdi
  8041603ab9:	00 00 00 
  8041603abc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ac1:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603ac4:	48 ba a0 bc 60 01 00 	movabs $0x160bca0,%rdx
  8041603acb:	00 00 00 
  8041603ace:	48 be a0 bc 60 41 80 	movabs $0x804160bca0,%rsi
  8041603ad5:	00 00 00 
  8041603ad8:	48 bf c8 c4 60 41 80 	movabs $0x804160c4c8,%rdi
  8041603adf:	00 00 00 
  8041603ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ae7:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603aea:	48 ba 48 41 70 01 00 	movabs $0x1704148,%rdx
  8041603af1:	00 00 00 
  8041603af4:	48 be 48 41 70 41 80 	movabs $0x8041704148,%rsi
  8041603afb:	00 00 00 
  8041603afe:	48 bf f0 c4 60 41 80 	movabs $0x804160c4f0,%rdi
  8041603b05:	00 00 00 
  8041603b08:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b0d:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  8041603b10:	48 bb 00 60 70 41 80 	movabs $0x8041706000,%rbx
  8041603b17:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603b1a:	48 ba 00 60 70 01 00 	movabs $0x1706000,%rdx
  8041603b21:	00 00 00 
  8041603b24:	48 89 de             	mov    %rbx,%rsi
  8041603b27:	48 bf 18 c5 60 41 80 	movabs $0x804160c518,%rdi
  8041603b2e:	00 00 00 
  8041603b31:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b36:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603b39:	4c 29 eb             	sub    %r13,%rbx
  8041603b3c:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603b43:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603b47:	48 bf 40 c5 60 41 80 	movabs $0x804160c540,%rdi
  8041603b4e:	00 00 00 
  8041603b51:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b56:	41 ff d4             	callq  *%r12
  return 0;
}
  8041603b59:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b5e:	48 83 c4 08          	add    $0x8,%rsp
  8041603b62:	5b                   	pop    %rbx
  8041603b63:	41 5c                	pop    %r12
  8041603b65:	41 5d                	pop    %r13
  8041603b67:	5d                   	pop    %rbp
  8041603b68:	c3                   	retq   

0000008041603b69 <mon_mycommand>:

// LAB 2 code
int
mon_mycommand(int argc, char **argv, struct Trapframe *tf) {
  8041603b69:	55                   	push   %rbp
  8041603b6a:	48 89 e5             	mov    %rsp,%rbp
  cprintf("This is output for my command.\n");
  8041603b6d:	48 bf 70 c5 60 41 80 	movabs $0x804160c570,%rdi
  8041603b74:	00 00 00 
  8041603b77:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b7c:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041603b83:	00 00 00 
  8041603b86:	ff d2                	callq  *%rdx
  return 0;
}
  8041603b88:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b8d:	5d                   	pop    %rbp
  8041603b8e:	c3                   	retq   

0000008041603b8f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  8041603b8f:	55                   	push   %rbp
  8041603b90:	48 89 e5             	mov    %rsp,%rbp
  8041603b93:	41 57                	push   %r15
  8041603b95:	41 56                	push   %r14
  8041603b97:	41 55                	push   %r13
  8041603b99:	41 54                	push   %r12
  8041603b9b:	53                   	push   %rbx
  8041603b9c:	48 81 ec 38 02 00 00 	sub    $0x238,%rsp
  // LAB 2 code

  cprintf("Stack backtrace:\n");
  8041603ba3:	48 bf f2 c2 60 41 80 	movabs $0x804160c2f2,%rdi
  8041603baa:	00 00 00 
  8041603bad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603bb2:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041603bb9:	00 00 00 
  8041603bbc:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603bbe:	48 89 e8             	mov    %rbp,%rax
  uint64_t buf;
  int digits_16;
  int code;
  struct Ripdebuginfo info;

  while (rbp != 0) {
  8041603bc1:	48 85 c0             	test   %rax,%rax
  8041603bc4:	0f 84 c5 01 00 00    	je     8041603d8f <mon_backtrace+0x200>
  8041603bca:	49 89 c6             	mov    %rax,%r14
  8041603bcd:	49 89 c7             	mov    %rax,%r15
    while (buf != 0) {
      digits_16++;
      buf = buf / 16;
    }

    cprintf("  rbp ");
  8041603bd0:	49 bc 6e 8f 60 41 80 	movabs $0x8041608f6e,%r12
  8041603bd7:	00 00 00 
    cprintf("%lx\n", rip);

    // get and print debug info
    code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
    if (code == 0) {
      cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603bda:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603be1:	48 05 04 01 00 00    	add    $0x104,%rax
  8041603be7:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  8041603bee:	e9 37 01 00 00       	jmpq   8041603d2a <mon_backtrace+0x19b>
      buf = buf / 16;
  8041603bf3:	48 89 d0             	mov    %rdx,%rax
      digits_16++;
  8041603bf6:	83 c3 01             	add    $0x1,%ebx
      buf = buf / 16;
  8041603bf9:	48 89 c2             	mov    %rax,%rdx
  8041603bfc:	48 c1 ea 04          	shr    $0x4,%rdx
    while (buf != 0) {
  8041603c00:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603c04:	77 ed                	ja     8041603bf3 <mon_backtrace+0x64>
    cprintf("  rbp ");
  8041603c06:	48 bf 04 c3 60 41 80 	movabs $0x804160c304,%rdi
  8041603c0d:	00 00 00 
  8041603c10:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c15:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c18:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603c1e:	41 29 dd             	sub    %ebx,%r13d
  8041603c21:	45 85 ed             	test   %r13d,%r13d
  8041603c24:	7e 1f                	jle    8041603c45 <mon_backtrace+0xb6>
  8041603c26:	bb 01 00 00 00       	mov    $0x1,%ebx
      cprintf("0");
  8041603c2b:	48 bf 1f d1 60 41 80 	movabs $0x804160d11f,%rdi
  8041603c32:	00 00 00 
  8041603c35:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c3a:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c3d:	83 c3 01             	add    $0x1,%ebx
  8041603c40:	41 39 dd             	cmp    %ebx,%r13d
  8041603c43:	7d e6                	jge    8041603c2b <mon_backtrace+0x9c>
    cprintf("%lx", rbp);
  8041603c45:	4c 89 f6             	mov    %r14,%rsi
  8041603c48:	48 bf 0b c3 60 41 80 	movabs $0x804160c30b,%rdi
  8041603c4f:	00 00 00 
  8041603c52:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c57:	41 ff d4             	callq  *%r12
    rbp = *pointer;
  8041603c5a:	4d 8b 37             	mov    (%r15),%r14
    rip = *pointer;
  8041603c5d:	4d 8b 7f 08          	mov    0x8(%r15),%r15
    buf       = buf / 16;
  8041603c61:	4c 89 f8             	mov    %r15,%rax
  8041603c64:	48 c1 e8 04          	shr    $0x4,%rax
    while (buf != 0) {
  8041603c68:	49 83 ff 0f          	cmp    $0xf,%r15
  8041603c6c:	0f 86 e3 00 00 00    	jbe    8041603d55 <mon_backtrace+0x1c6>
    digits_16 = 1;
  8041603c72:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603c77:	eb 03                	jmp    8041603c7c <mon_backtrace+0xed>
      buf = buf / 16;
  8041603c79:	48 89 d0             	mov    %rdx,%rax
      digits_16++;
  8041603c7c:	83 c3 01             	add    $0x1,%ebx
      buf = buf / 16;
  8041603c7f:	48 89 c2             	mov    %rax,%rdx
  8041603c82:	48 c1 ea 04          	shr    $0x4,%rdx
    while (buf != 0) {
  8041603c86:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603c8a:	77 ed                	ja     8041603c79 <mon_backtrace+0xea>
    cprintf("  rip ");
  8041603c8c:	48 bf 0f c3 60 41 80 	movabs $0x804160c30f,%rdi
  8041603c93:	00 00 00 
  8041603c96:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c9b:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c9e:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603ca4:	41 29 dd             	sub    %ebx,%r13d
  8041603ca7:	45 85 ed             	test   %r13d,%r13d
  8041603caa:	7e 1f                	jle    8041603ccb <mon_backtrace+0x13c>
  8041603cac:	bb 01 00 00 00       	mov    $0x1,%ebx
      cprintf("0");
  8041603cb1:	48 bf 1f d1 60 41 80 	movabs $0x804160d11f,%rdi
  8041603cb8:	00 00 00 
  8041603cbb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cc0:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603cc3:	83 c3 01             	add    $0x1,%ebx
  8041603cc6:	44 39 eb             	cmp    %r13d,%ebx
  8041603cc9:	7e e6                	jle    8041603cb1 <mon_backtrace+0x122>
    cprintf("%lx\n", rip);
  8041603ccb:	4c 89 fe             	mov    %r15,%rsi
  8041603cce:	48 bf 7d d1 60 41 80 	movabs $0x804160d17d,%rdi
  8041603cd5:	00 00 00 
  8041603cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cdd:	41 ff d4             	callq  *%r12
    code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
  8041603ce0:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603ce7:	4c 89 ff             	mov    %r15,%rdi
  8041603cea:	48 b8 22 a6 60 41 80 	movabs $0x804160a622,%rax
  8041603cf1:	00 00 00 
  8041603cf4:	ff d0                	callq  *%rax
    if (code == 0) {
  8041603cf6:	85 c0                	test   %eax,%eax
  8041603cf8:	75 47                	jne    8041603d41 <mon_backtrace+0x1b2>
      cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603cfa:	4d 89 f8             	mov    %r15,%r8
  8041603cfd:	4c 2b 45 b8          	sub    -0x48(%rbp),%r8
  8041603d01:	48 8b 8d a8 fd ff ff 	mov    -0x258(%rbp),%rcx
  8041603d08:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603d0e:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603d15:	48 bf 16 c3 60 41 80 	movabs $0x804160c316,%rdi
  8041603d1c:	00 00 00 
  8041603d1f:	41 ff d4             	callq  *%r12
    } else {
      cprintf("Info not found");
    }

    pointer = (uintptr_t *)rbp;
  8041603d22:	4d 89 f7             	mov    %r14,%r15
  while (rbp != 0) {
  8041603d25:	4d 85 f6             	test   %r14,%r14
  8041603d28:	74 65                	je     8041603d8f <mon_backtrace+0x200>
    buf       = buf / 16;
  8041603d2a:	4c 89 f0             	mov    %r14,%rax
  8041603d2d:	48 c1 e8 04          	shr    $0x4,%rax
    while (buf != 0) {
  8041603d31:	49 83 fe 0f          	cmp    $0xf,%r14
  8041603d35:	76 3b                	jbe    8041603d72 <mon_backtrace+0x1e3>
    digits_16 = 1;
  8041603d37:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603d3c:	e9 b5 fe ff ff       	jmpq   8041603bf6 <mon_backtrace+0x67>
      cprintf("Info not found");
  8041603d41:	48 bf 2e c3 60 41 80 	movabs $0x804160c32e,%rdi
  8041603d48:	00 00 00 
  8041603d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d50:	41 ff d4             	callq  *%r12
  8041603d53:	eb cd                	jmp    8041603d22 <mon_backtrace+0x193>
    cprintf("  rip ");
  8041603d55:	48 bf 0f c3 60 41 80 	movabs $0x804160c30f,%rdi
  8041603d5c:	00 00 00 
  8041603d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d64:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d67:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d6d:	e9 3a ff ff ff       	jmpq   8041603cac <mon_backtrace+0x11d>
    cprintf("  rbp ");
  8041603d72:	48 bf 04 c3 60 41 80 	movabs $0x804160c304,%rdi
  8041603d79:	00 00 00 
  8041603d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d81:	41 ff d4             	callq  *%r12
    for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d84:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d8a:	e9 97 fe ff ff       	jmpq   8041603c26 <mon_backtrace+0x97>
  }

  return 0;
}
  8041603d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d94:	48 81 c4 38 02 00 00 	add    $0x238,%rsp
  8041603d9b:	5b                   	pop    %rbx
  8041603d9c:	41 5c                	pop    %r12
  8041603d9e:	41 5d                	pop    %r13
  8041603da0:	41 5e                	pop    %r14
  8041603da2:	41 5f                	pop    %r15
  8041603da4:	5d                   	pop    %rbp
  8041603da5:	c3                   	retq   

0000008041603da6 <mon_start>:
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
int
mon_start(int argc, char **argv, struct Trapframe *tf) {

  if (argc != 2) {
    return 1;
  8041603da6:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603dab:	83 ff 02             	cmp    $0x2,%edi
  8041603dae:	74 01                	je     8041603db1 <mon_start+0xb>
  }
  timer_start(argv[1]);

  return 0;
}
  8041603db0:	c3                   	retq   
mon_start(int argc, char **argv, struct Trapframe *tf) {
  8041603db1:	55                   	push   %rbp
  8041603db2:	48 89 e5             	mov    %rsp,%rbp
  timer_start(argv[1]);
  8041603db5:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603db9:	48 b8 b4 b9 60 41 80 	movabs $0x804160b9b4,%rax
  8041603dc0:	00 00 00 
  8041603dc3:	ff d0                	callq  *%rax
  return 0;
  8041603dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603dca:	5d                   	pop    %rbp
  8041603dcb:	c3                   	retq   

0000008041603dcc <mon_stop>:

int
mon_stop(int argc, char **argv, struct Trapframe *tf) {
  8041603dcc:	55                   	push   %rbp
  8041603dcd:	48 89 e5             	mov    %rsp,%rbp

  timer_stop();
  8041603dd0:	48 b8 6e ba 60 41 80 	movabs $0x804160ba6e,%rax
  8041603dd7:	00 00 00 
  8041603dda:	ff d0                	callq  *%rax

  return 0;
}
  8041603ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603de1:	5d                   	pop    %rbp
  8041603de2:	c3                   	retq   

0000008041603de3 <mon_frequency>:

int
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603de3:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603de8:	83 ff 02             	cmp    $0x2,%edi
  8041603deb:	74 01                	je     8041603dee <mon_frequency+0xb>
  }
  timer_cpu_frequency(argv[1]);

  return 0;
}
  8041603ded:	c3                   	retq   
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  8041603dee:	55                   	push   %rbp
  8041603def:	48 89 e5             	mov    %rsp,%rbp
  timer_cpu_frequency(argv[1]);
  8041603df2:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603df6:	48 b8 f8 ba 60 41 80 	movabs $0x804160baf8,%rax
  8041603dfd:	00 00 00 
  8041603e00:	ff d0                	callq  *%rax
  return 0;
  8041603e02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603e07:	5d                   	pop    %rbp
  8041603e08:	c3                   	retq   

0000008041603e09 <mon_memory>:
int
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  size_t i;
  int is_cur_free;

  for (i = 1; i <= npages; i++) {
  8041603e09:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041603e10:	00 00 00 
  8041603e13:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041603e17:	0f 84 24 01 00 00    	je     8041603f41 <mon_memory+0x138>
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  8041603e1d:	55                   	push   %rbp
  8041603e1e:	48 89 e5             	mov    %rsp,%rbp
  8041603e21:	41 57                	push   %r15
  8041603e23:	41 56                	push   %r14
  8041603e25:	41 55                	push   %r13
  8041603e27:	41 54                	push   %r12
  8041603e29:	53                   	push   %rbx
  8041603e2a:	48 83 ec 18          	sub    $0x18,%rsp
  for (i = 1; i <= npages; i++) {
  8041603e2e:	bb 01 00 00 00       	mov    $0x1,%ebx
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e33:	49 be 38 59 70 41 80 	movabs $0x8041705938,%r14
  8041603e3a:	00 00 00 
    cprintf("%lu", i);
  8041603e3d:	49 bf 6e 8f 60 41 80 	movabs $0x8041608f6e,%r15
  8041603e44:	00 00 00 
    if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e47:	49 89 c4             	mov    %rax,%r12
  8041603e4a:	eb 47                	jmp    8041603e93 <mon_memory+0x8a>
      while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
        i++;
      }
      cprintf("..%lu", i);
  8041603e4c:	48 89 de             	mov    %rbx,%rsi
  8041603e4f:	48 bf 50 c3 60 41 80 	movabs $0x804160c350,%rdi
  8041603e56:	00 00 00 
  8041603e59:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e5e:	41 ff d7             	callq  *%r15
    }
    cprintf(is_cur_free ? " FREE\n" : " ALLOCATED\n");
  8041603e61:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603e65:	48 bf 3d c3 60 41 80 	movabs $0x804160c33d,%rdi
  8041603e6c:	00 00 00 
  8041603e6f:	48 b8 44 c3 60 41 80 	movabs $0x804160c344,%rax
  8041603e76:	00 00 00 
  8041603e79:	48 0f 45 f8          	cmovne %rax,%rdi
  8041603e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e82:	41 ff d7             	callq  *%r15
  for (i = 1; i <= npages; i++) {
  8041603e85:	48 83 c3 01          	add    $0x1,%rbx
  8041603e89:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603e8d:	0f 82 9a 00 00 00    	jb     8041603f2d <mon_memory+0x124>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e93:	49 89 dd             	mov    %rbx,%r13
  8041603e96:	49 c1 e5 04          	shl    $0x4,%r13
  8041603e9a:	49 8b 06             	mov    (%r14),%rax
  8041603e9d:	4a 8d 7c 28 f0       	lea    -0x10(%rax,%r13,1),%rdi
  8041603ea2:	48 b8 23 4b 60 41 80 	movabs $0x8041604b23,%rax
  8041603ea9:	00 00 00 
  8041603eac:	ff d0                	callq  *%rax
  8041603eae:	89 45 cc             	mov    %eax,-0x34(%rbp)
    cprintf("%lu", i);
  8041603eb1:	48 89 de             	mov    %rbx,%rsi
  8041603eb4:	48 bf 52 c3 60 41 80 	movabs $0x804160c352,%rdi
  8041603ebb:	00 00 00 
  8041603ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ec3:	41 ff d7             	callq  *%r15
    if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603ec6:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603eca:	76 95                	jbe    8041603e61 <mon_memory+0x58>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603ecc:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603ed0:	0f 94 c0             	sete   %al
  8041603ed3:	0f b6 c0             	movzbl %al,%eax
  8041603ed6:	89 45 c8             	mov    %eax,-0x38(%rbp)
    if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603ed9:	4c 89 ef             	mov    %r13,%rdi
  8041603edc:	49 03 3e             	add    (%r14),%rdi
  8041603edf:	48 b8 23 4b 60 41 80 	movabs $0x8041604b23,%rax
  8041603ee6:	00 00 00 
  8041603ee9:	ff d0                	callq  *%rax
  8041603eeb:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603eee:	0f 84 6d ff ff ff    	je     8041603e61 <mon_memory+0x58>
      while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603ef4:	49 bd 23 4b 60 41 80 	movabs $0x8041604b23,%r13
  8041603efb:	00 00 00 
  8041603efe:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603f02:	0f 86 44 ff ff ff    	jbe    8041603e4c <mon_memory+0x43>
  8041603f08:	48 89 df             	mov    %rbx,%rdi
  8041603f0b:	48 c1 e7 04          	shl    $0x4,%rdi
  8041603f0f:	49 03 3e             	add    (%r14),%rdi
  8041603f12:	41 ff d5             	callq  *%r13
  8041603f15:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603f18:	0f 84 2e ff ff ff    	je     8041603e4c <mon_memory+0x43>
        i++;
  8041603f1e:	48 83 c3 01          	add    $0x1,%rbx
      while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603f22:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603f26:	77 e0                	ja     8041603f08 <mon_memory+0xff>
  8041603f28:	e9 1f ff ff ff       	jmpq   8041603e4c <mon_memory+0x43>
  }

  return 0;
}
  8041603f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f32:	48 83 c4 18          	add    $0x18,%rsp
  8041603f36:	5b                   	pop    %rbx
  8041603f37:	41 5c                	pop    %r12
  8041603f39:	41 5d                	pop    %r13
  8041603f3b:	41 5e                	pop    %r14
  8041603f3d:	41 5f                	pop    %r15
  8041603f3f:	5d                   	pop    %rbp
  8041603f40:	c3                   	retq   
  8041603f41:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f46:	c3                   	retq   

0000008041603f47 <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603f47:	55                   	push   %rbp
  8041603f48:	48 89 e5             	mov    %rsp,%rbp
  8041603f4b:	41 57                	push   %r15
  8041603f4d:	41 56                	push   %r14
  8041603f4f:	41 55                	push   %r13
  8041603f51:	41 54                	push   %r12
  8041603f53:	53                   	push   %rbx
  8041603f54:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603f5b:	49 89 ff             	mov    %rdi,%r15
  8041603f5e:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603f65:	48 bf 90 c5 60 41 80 	movabs $0x804160c590,%rdi
  8041603f6c:	00 00 00 
  8041603f6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f74:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  8041603f7b:	00 00 00 
  8041603f7e:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603f80:	48 bf b8 c5 60 41 80 	movabs $0x804160c5b8,%rdi
  8041603f87:	00 00 00 
  8041603f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f8f:	ff d3                	callq  *%rbx

  if (tf != NULL)
  8041603f91:	4d 85 ff             	test   %r15,%r15
  8041603f94:	74 0f                	je     8041603fa5 <monitor+0x5e>
    print_trapframe(tf);
  8041603f96:	4c 89 ff             	mov    %r15,%rdi
  8041603f99:	48 b8 82 92 60 41 80 	movabs $0x8041609282,%rax
  8041603fa0:	00 00 00 
  8041603fa3:	ff d0                	callq  *%rax

  while (1) {
    buf = readline("K> ");
  8041603fa5:	49 bf b7 b1 60 41 80 	movabs $0x804160b1b7,%r15
  8041603fac:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603faf:	49 be 67 b4 60 41 80 	movabs $0x804160b467,%r14
  8041603fb6:	00 00 00 
  8041603fb9:	e9 ff 00 00 00       	jmpq   80416040bd <monitor+0x176>
  8041603fbe:	40 0f be f6          	movsbl %sil,%esi
  8041603fc2:	48 bf 5a c3 60 41 80 	movabs $0x804160c35a,%rdi
  8041603fc9:	00 00 00 
  8041603fcc:	41 ff d6             	callq  *%r14
  8041603fcf:	48 85 c0             	test   %rax,%rax
  8041603fd2:	74 0c                	je     8041603fe0 <monitor+0x99>
      *buf++ = 0;
  8041603fd4:	c6 03 00             	movb   $0x0,(%rbx)
  8041603fd7:	45 89 e5             	mov    %r12d,%r13d
  8041603fda:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603fde:	eb 49                	jmp    8041604029 <monitor+0xe2>
    if (*buf == 0)
  8041603fe0:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603fe3:	74 4f                	je     8041604034 <monitor+0xed>
    if (argc == MAXARGS - 1) {
  8041603fe5:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603fe9:	0f 84 b3 00 00 00    	je     80416040a2 <monitor+0x15b>
    argv[argc++] = buf;
  8041603fef:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  8041603ff4:	4d 63 e4             	movslq %r12d,%r12
  8041603ff7:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041603ffe:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603fff:	0f b6 33             	movzbl (%rbx),%esi
  8041604002:	40 84 f6             	test   %sil,%sil
  8041604005:	74 22                	je     8041604029 <monitor+0xe2>
  8041604007:	40 0f be f6          	movsbl %sil,%esi
  804160400b:	48 bf 5a c3 60 41 80 	movabs $0x804160c35a,%rdi
  8041604012:	00 00 00 
  8041604015:	41 ff d6             	callq  *%r14
  8041604018:	48 85 c0             	test   %rax,%rax
  804160401b:	75 0c                	jne    8041604029 <monitor+0xe2>
      buf++;
  804160401d:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041604021:	0f b6 33             	movzbl (%rbx),%esi
  8041604024:	40 84 f6             	test   %sil,%sil
  8041604027:	75 de                	jne    8041604007 <monitor+0xc0>
      *buf++ = 0;
  8041604029:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  804160402c:	0f b6 33             	movzbl (%rbx),%esi
  804160402f:	40 84 f6             	test   %sil,%sil
  8041604032:	75 8a                	jne    8041603fbe <monitor+0x77>
  argv[argc] = 0;
  8041604034:	49 63 c4             	movslq %r12d,%rax
  8041604037:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  804160403e:	ff 00 00 00 00 
  if (argc == 0)
  8041604043:	45 85 e4             	test   %r12d,%r12d
  8041604046:	74 75                	je     80416040bd <monitor+0x176>
  8041604048:	49 bd 40 c6 60 41 80 	movabs $0x804160c640,%r13
  804160404f:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041604052:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  8041604057:	49 8b 75 00          	mov    0x0(%r13),%rsi
  804160405b:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041604062:	48 b8 00 b4 60 41 80 	movabs $0x804160b400,%rax
  8041604069:	00 00 00 
  804160406c:	ff d0                	callq  *%rax
  804160406e:	85 c0                	test   %eax,%eax
  8041604070:	74 76                	je     80416040e8 <monitor+0x1a1>
  for (i = 0; i < NCOMMANDS; i++) {
  8041604072:	83 c3 01             	add    $0x1,%ebx
  8041604075:	49 83 c5 18          	add    $0x18,%r13
  8041604079:	83 fb 09             	cmp    $0x9,%ebx
  804160407c:	75 d9                	jne    8041604057 <monitor+0x110>
  cprintf("Unknown command '%s'\n", argv[0]);
  804160407e:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041604085:	48 bf 7c c3 60 41 80 	movabs $0x804160c37c,%rdi
  804160408c:	00 00 00 
  804160408f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604094:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160409b:	00 00 00 
  804160409e:	ff d2                	callq  *%rdx
  return 0;
  80416040a0:	eb 1b                	jmp    80416040bd <monitor+0x176>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  80416040a2:	be 10 00 00 00       	mov    $0x10,%esi
  80416040a7:	48 bf 5f c3 60 41 80 	movabs $0x804160c35f,%rdi
  80416040ae:	00 00 00 
  80416040b1:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416040b8:	00 00 00 
  80416040bb:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  80416040bd:	48 bf 56 c3 60 41 80 	movabs $0x804160c356,%rdi
  80416040c4:	00 00 00 
  80416040c7:	41 ff d7             	callq  *%r15
  80416040ca:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  80416040cd:	48 85 c0             	test   %rax,%rax
  80416040d0:	74 eb                	je     80416040bd <monitor+0x176>
  argv[argc] = 0;
  80416040d2:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  80416040d9:	00 00 00 00 
  argc       = 0;
  80416040dd:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  80416040e3:	e9 44 ff ff ff       	jmpq   804160402c <monitor+0xe5>
      return commands[i].func(argc, argv, tf);
  80416040e8:	48 63 db             	movslq %ebx,%rbx
  80416040eb:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  80416040ef:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  80416040f6:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  80416040fd:	44 89 e7             	mov    %r12d,%edi
  8041604100:	48 b8 40 c6 60 41 80 	movabs $0x804160c640,%rax
  8041604107:	00 00 00 
  804160410a:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  804160410e:	85 c0                	test   %eax,%eax
  8041604110:	79 ab                	jns    80416040bd <monitor+0x176>
        break;
  }
}
  8041604112:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041604119:	5b                   	pop    %rbx
  804160411a:	41 5c                	pop    %r12
  804160411c:	41 5d                	pop    %r13
  804160411e:	41 5e                	pop    %r14
  8041604120:	41 5f                	pop    %r15
  8041604122:	5d                   	pop    %rbp
  8041604123:	c3                   	retq   

0000008041604124 <check_va2pa>:
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  pte_t *pte;
  pdpe_t *pdpe;
  pde_t *pde;
  //cprintf("1: Virtual addr: %ld\n", va);
  pml4e = &pml4e[PML4(va)];
  8041604124:	48 89 f0             	mov    %rsi,%rax
  8041604127:	48 c1 e8 27          	shr    $0x27,%rax
  804160412b:	25 ff 01 00 00       	and    $0x1ff,%eax
  //cprintf("2: PML4(va): %ld PML4E: %ld\n" , PML4(va), *pml4e);
  if (!(*pml4e & PTE_P))
  8041604130:	48 8b 0c c7          	mov    (%rdi,%rax,8),%rcx
  8041604134:	f6 c1 01             	test   $0x1,%cl
  8041604137:	0f 84 5a 01 00 00    	je     8041604297 <check_va2pa+0x173>
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  804160413d:	55                   	push   %rbp
  804160413e:	48 89 e5             	mov    %rsp,%rbp
    return ~0;
  pdpe = (pdpe_t *)KADDR(PTE_ADDR(*pml4e));
  8041604141:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
//CAUTION: use only before page detection!
#define _KADDR_NOCHECK(pa) (void *)((physaddr_t)pa + KERNBASE)

static inline void *
_kaddr(const char *file, int line, physaddr_t pa) {
  if (PGNUM(pa) >= npages)
  8041604148:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  804160414f:	00 00 00 
  8041604152:	48 8b 10             	mov    (%rax),%rdx
  8041604155:	48 89 c8             	mov    %rcx,%rax
  8041604158:	48 c1 e8 0c          	shr    $0xc,%rax
  804160415c:	48 39 c2             	cmp    %rax,%rdx
  804160415f:	0f 86 b1 00 00 00    	jbe    8041604216 <check_va2pa+0xf2>
  //cprintf("3: PDPE: %ln  PDPE Addr: %ld\n" , pdpe, *pdpe);
  if (!(pdpe[PDPE(va)] & PTE_P))
  8041604165:	48 89 f0             	mov    %rsi,%rax
  8041604168:	48 c1 e8 1b          	shr    $0x1b,%rax
  804160416c:	25 f8 0f 00 00       	and    $0xff8,%eax
  8041604171:	48 01 c1             	add    %rax,%rcx
  8041604174:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160417b:	00 00 00 
  804160417e:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  8041604182:	f6 c1 01             	test   $0x1,%cl
  8041604185:	0f 84 14 01 00 00    	je     804160429f <check_va2pa+0x17b>
    return ~0;
  pde = (pde_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  804160418b:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041604192:	48 89 c8             	mov    %rcx,%rax
  8041604195:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604199:	48 39 c2             	cmp    %rax,%rdx
  804160419c:	0f 86 9f 00 00 00    	jbe    8041604241 <check_va2pa+0x11d>
  //cprintf("4: PDE: %ln PDE Addr: %ld\n" , pde, *pde);
  pde = &pde[PDX(va)];
  80416041a2:	48 89 f0             	mov    %rsi,%rax
  80416041a5:	48 c1 e8 12          	shr    $0x12,%rax
  if (!(*pde & PTE_P))
  80416041a9:	25 f8 0f 00 00       	and    $0xff8,%eax
  80416041ae:	48 01 c1             	add    %rax,%rcx
  80416041b1:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416041b8:	00 00 00 
  80416041bb:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  80416041bf:	f6 c1 01             	test   $0x1,%cl
  80416041c2:	0f 84 e3 00 00 00    	je     80416042ab <check_va2pa+0x187>
    return ~0;
  pte = (pte_t *)KADDR(PTE_ADDR(*pde));
  80416041c8:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416041cf:	48 89 c8             	mov    %rcx,%rax
  80416041d2:	48 c1 e8 0c          	shr    $0xc,%rax
  80416041d6:	48 39 c2             	cmp    %rax,%rdx
  80416041d9:	0f 86 8d 00 00 00    	jbe    804160426c <check_va2pa+0x148>
  //cprintf("5: PTE: %ln PTE Addr: %ld\n" , pte, *pte);
  if (!(pte[PTX(va)] & PTE_P))
  80416041df:	48 c1 ee 09          	shr    $0x9,%rsi
  80416041e3:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
  80416041e9:	48 01 ce             	add    %rcx,%rsi
  80416041ec:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416041f3:	00 00 00 
  80416041f6:	48 8b 04 06          	mov    (%rsi,%rax,1),%rax
  80416041fa:	48 89 c2             	mov    %rax,%rdx
  80416041fd:	83 e2 01             	and    $0x1,%edx
    return ~0;
  //cprintf("6: PTX(va): %ld PTE Addr: %ld\n" , PTX(va),  PTE_ADDR(pte[PTX(va)]));
  return PTE_ADDR(pte[PTX(va)]);
  8041604200:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041604206:	48 85 d2             	test   %rdx,%rdx
  8041604209:	48 c7 c2 ff ff ff ff 	mov    $0xffffffffffffffff,%rdx
  8041604210:	48 0f 44 c2          	cmove  %rdx,%rax
}
  8041604214:	5d                   	pop    %rbp
  8041604215:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604216:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  804160421d:	00 00 00 
  8041604220:	be 5d 04 00 00       	mov    $0x45d,%esi
  8041604225:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160422c:	00 00 00 
  804160422f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604234:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160423b:	00 00 00 
  804160423e:	41 ff d0             	callq  *%r8
  8041604241:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604248:	00 00 00 
  804160424b:	be 61 04 00 00       	mov    $0x461,%esi
  8041604250:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604257:	00 00 00 
  804160425a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160425f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604266:	00 00 00 
  8041604269:	41 ff d0             	callq  *%r8
  804160426c:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604273:	00 00 00 
  8041604276:	be 66 04 00 00       	mov    $0x466,%esi
  804160427b:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604282:	00 00 00 
  8041604285:	b8 00 00 00 00       	mov    $0x0,%eax
  804160428a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604291:	00 00 00 
  8041604294:	41 ff d0             	callq  *%r8
    return ~0;
  8041604297:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
}
  804160429e:	c3                   	retq   
    return ~0;
  804160429f:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  80416042a6:	e9 69 ff ff ff       	jmpq   8041604214 <check_va2pa+0xf0>
    return ~0;
  80416042ab:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  80416042b2:	e9 5d ff ff ff       	jmpq   8041604214 <check_va2pa+0xf0>

00000080416042b7 <boot_alloc>:
boot_alloc(uint32_t n) {
  80416042b7:	55                   	push   %rbp
  80416042b8:	48 89 e5             	mov    %rsp,%rbp
  if (!nextfree) {
  80416042bb:	48 b8 d8 43 70 41 80 	movabs $0x80417043d8,%rax
  80416042c2:	00 00 00 
  80416042c5:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416042c9:	74 54                	je     804160431f <boot_alloc+0x68>
  result = nextfree;
  80416042cb:	48 b9 d8 43 70 41 80 	movabs $0x80417043d8,%rcx
  80416042d2:	00 00 00 
  80416042d5:	48 8b 01             	mov    (%rcx),%rax
  nextfree += ROUNDUP(n, PGSIZE);
  80416042d8:	48 8d 97 ff 0f 00 00 	lea    0xfff(%rdi),%rdx
  80416042df:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  80416042e5:	48 01 c2             	add    %rax,%rdx
  80416042e8:	48 89 11             	mov    %rdx,(%rcx)
  if ((uint64_t)kva < KERNBASE)
  80416042eb:	48 b9 ff ff ff 3f 80 	movabs $0x803fffffff,%rcx
  80416042f2:	00 00 00 
  80416042f5:	48 39 ca             	cmp    %rcx,%rdx
  80416042f8:	76 41                	jbe    804160433b <boot_alloc+0x84>
  if (PADDR(nextfree) > PGSIZE * npages) {
  80416042fa:	48 bf 30 59 70 41 80 	movabs $0x8041705930,%rdi
  8041604301:	00 00 00 
  8041604304:	48 8b 37             	mov    (%rdi),%rsi
  8041604307:	48 c1 e6 0c          	shl    $0xc,%rsi
  return (physaddr_t)kva - KERNBASE;
  804160430b:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  8041604312:	ff ff ff 
  8041604315:	48 01 ca             	add    %rcx,%rdx
  8041604318:	48 39 d6             	cmp    %rdx,%rsi
  804160431b:	72 4c                	jb     8041604369 <boot_alloc+0xb2>
}
  804160431d:	5d                   	pop    %rbp
  804160431e:	c3                   	retq   
    nextfree = ROUNDUP((char *)end, PGSIZE);
  804160431f:	48 b8 ff 6f 70 41 80 	movabs $0x8041706fff,%rax
  8041604326:	00 00 00 
  8041604329:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160432f:	48 a3 d8 43 70 41 80 	movabs %rax,0x80417043d8
  8041604336:	00 00 00 
  8041604339:	eb 90                	jmp    80416042cb <boot_alloc+0x14>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160433b:	48 89 d1             	mov    %rdx,%rcx
  804160433e:	48 ba 38 c7 60 41 80 	movabs $0x804160c738,%rdx
  8041604345:	00 00 00 
  8041604348:	be b6 00 00 00       	mov    $0xb6,%esi
  804160434d:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604354:	00 00 00 
  8041604357:	b8 00 00 00 00       	mov    $0x0,%eax
  804160435c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604363:	00 00 00 
  8041604366:	41 ff d0             	callq  *%r8
    panic("Out of memory on boot, what? how?!");
  8041604369:	48 ba 60 c7 60 41 80 	movabs $0x804160c760,%rdx
  8041604370:	00 00 00 
  8041604373:	be b7 00 00 00       	mov    $0xb7,%esi
  8041604378:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160437f:	00 00 00 
  8041604382:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604387:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160438e:	00 00 00 
  8041604391:	ff d1                	callq  *%rcx

0000008041604393 <check_page_free_list>:
check_page_free_list(bool only_low_memory) {
  8041604393:	55                   	push   %rbp
  8041604394:	48 89 e5             	mov    %rsp,%rbp
  8041604397:	53                   	push   %rbx
  8041604398:	48 83 ec 28          	sub    $0x28,%rsp
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  804160439c:	40 84 ff             	test   %dil,%dil
  804160439f:	0f 85 7f 03 00 00    	jne    8041604724 <check_page_free_list+0x391>
  if (!page_free_list)
  80416043a5:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  80416043ac:	00 00 00 
  80416043af:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416043b3:	0f 84 9f 00 00 00    	je     8041604458 <check_page_free_list+0xc5>
  first_free_page = (char *)boot_alloc(0);
  80416043b9:	bf 00 00 00 00       	mov    $0x0,%edi
  80416043be:	48 b8 b7 42 60 41 80 	movabs $0x80416042b7,%rax
  80416043c5:	00 00 00 
  80416043c8:	ff d0                	callq  *%rax
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  80416043ca:	48 bb e8 43 70 41 80 	movabs $0x80417043e8,%rbx
  80416043d1:	00 00 00 
  80416043d4:	48 8b 13             	mov    (%rbx),%rdx
  80416043d7:	48 85 d2             	test   %rdx,%rdx
  80416043da:	0f 84 0f 03 00 00    	je     80416046ef <check_page_free_list+0x35c>
    assert(pp >= pages);
  80416043e0:	48 bb 38 59 70 41 80 	movabs $0x8041705938,%rbx
  80416043e7:	00 00 00 
  80416043ea:	48 8b 3b             	mov    (%rbx),%rdi
  80416043ed:	48 39 fa             	cmp    %rdi,%rdx
  80416043f0:	0f 82 8c 00 00 00    	jb     8041604482 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  80416043f6:	48 bb 30 59 70 41 80 	movabs $0x8041705930,%rbx
  80416043fd:	00 00 00 
  8041604400:	4c 8b 1b             	mov    (%rbx),%r11
  8041604403:	4d 89 d8             	mov    %r11,%r8
  8041604406:	49 c1 e0 04          	shl    $0x4,%r8
  804160440a:	49 01 f8             	add    %rdi,%r8
  804160440d:	4c 39 c2             	cmp    %r8,%rdx
  8041604410:	0f 83 a1 00 00 00    	jae    80416044b7 <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  8041604416:	48 89 d1             	mov    %rdx,%rcx
  8041604419:	48 29 f9             	sub    %rdi,%rcx
  804160441c:	f6 c1 0f             	test   $0xf,%cl
  804160441f:	0f 85 c7 00 00 00    	jne    80416044ec <check_page_free_list+0x159>
int user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
  8041604425:	48 c1 f9 04          	sar    $0x4,%rcx
  8041604429:	48 c1 e1 0c          	shl    $0xc,%rcx
  804160442d:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  8041604430:	0f 84 eb 00 00 00    	je     8041604521 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604436:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  804160443d:	0f 84 13 01 00 00    	je     8041604556 <check_page_free_list+0x1c3>
  int nfree_basemem = 0, nfree_extmem = 0;
  8041604443:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  return (void *)(pa + KERNBASE);
  8041604449:	48 bb 00 00 00 40 80 	movabs $0x8040000000,%rbx
  8041604450:	00 00 00 
  8041604453:	e9 17 02 00 00       	jmpq   804160466f <check_page_free_list+0x2dc>
    panic("'page_free_list' is a null pointer!");
  8041604458:	48 ba 88 c7 60 41 80 	movabs $0x804160c788,%rdx
  804160445f:	00 00 00 
  8041604462:	be 8e 03 00 00       	mov    $0x38e,%esi
  8041604467:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160446e:	00 00 00 
  8041604471:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604476:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160447d:	00 00 00 
  8041604480:	ff d1                	callq  *%rcx
    assert(pp >= pages);
  8041604482:	48 b9 f0 d0 60 41 80 	movabs $0x804160d0f0,%rcx
  8041604489:	00 00 00 
  804160448c:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041604493:	00 00 00 
  8041604496:	be af 03 00 00       	mov    $0x3af,%esi
  804160449b:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416044a2:	00 00 00 
  80416044a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044aa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044b1:	00 00 00 
  80416044b4:	41 ff d0             	callq  *%r8
    assert(pp < pages + npages);
  80416044b7:	48 b9 fc d0 60 41 80 	movabs $0x804160d0fc,%rcx
  80416044be:	00 00 00 
  80416044c1:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416044c8:	00 00 00 
  80416044cb:	be b0 03 00 00       	mov    $0x3b0,%esi
  80416044d0:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416044d7:	00 00 00 
  80416044da:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044df:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044e6:	00 00 00 
  80416044e9:	41 ff d0             	callq  *%r8
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  80416044ec:	48 b9 b0 c7 60 41 80 	movabs $0x804160c7b0,%rcx
  80416044f3:	00 00 00 
  80416044f6:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416044fd:	00 00 00 
  8041604500:	be b1 03 00 00       	mov    $0x3b1,%esi
  8041604505:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160450c:	00 00 00 
  804160450f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604514:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160451b:	00 00 00 
  804160451e:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != 0);
  8041604521:	48 b9 10 d1 60 41 80 	movabs $0x804160d110,%rcx
  8041604528:	00 00 00 
  804160452b:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041604532:	00 00 00 
  8041604535:	be b4 03 00 00       	mov    $0x3b4,%esi
  804160453a:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604541:	00 00 00 
  8041604544:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604549:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604550:	00 00 00 
  8041604553:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != IOPHYSMEM);
  8041604556:	48 b9 21 d1 60 41 80 	movabs $0x804160d121,%rcx
  804160455d:	00 00 00 
  8041604560:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041604567:	00 00 00 
  804160456a:	be b5 03 00 00       	mov    $0x3b5,%esi
  804160456f:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604576:	00 00 00 
  8041604579:	b8 00 00 00 00       	mov    $0x0,%eax
  804160457e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604585:	00 00 00 
  8041604588:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  804160458b:	48 b9 e0 c7 60 41 80 	movabs $0x804160c7e0,%rcx
  8041604592:	00 00 00 
  8041604595:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160459c:	00 00 00 
  804160459f:	be b6 03 00 00       	mov    $0x3b6,%esi
  80416045a4:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416045ab:	00 00 00 
  80416045ae:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045b3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045ba:	00 00 00 
  80416045bd:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM);
  80416045c0:	48 b9 3a d1 60 41 80 	movabs $0x804160d13a,%rcx
  80416045c7:	00 00 00 
  80416045ca:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416045d1:	00 00 00 
  80416045d4:	be b7 03 00 00       	mov    $0x3b7,%esi
  80416045d9:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416045e0:	00 00 00 
  80416045e3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045e8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045ef:	00 00 00 
  80416045f2:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416045f5:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  80416045fc:	00 00 00 
  80416045ff:	be 63 00 00 00       	mov    $0x63,%esi
  8041604604:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  804160460b:	00 00 00 
  804160460e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604613:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160461a:	00 00 00 
  804160461d:	41 ff d0             	callq  *%r8
      ++nfree_extmem;
  8041604620:	41 83 c1 01          	add    $0x1,%r9d
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604624:	48 8b 12             	mov    (%rdx),%rdx
  8041604627:	48 85 d2             	test   %rdx,%rdx
  804160462a:	0f 84 b3 00 00 00    	je     80416046e3 <check_page_free_list+0x350>
    assert(pp >= pages);
  8041604630:	48 39 fa             	cmp    %rdi,%rdx
  8041604633:	0f 82 49 fe ff ff    	jb     8041604482 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  8041604639:	4c 39 c2             	cmp    %r8,%rdx
  804160463c:	0f 83 75 fe ff ff    	jae    80416044b7 <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  8041604642:	48 89 d1             	mov    %rdx,%rcx
  8041604645:	48 29 f9             	sub    %rdi,%rcx
  8041604648:	f6 c1 0f             	test   $0xf,%cl
  804160464b:	0f 85 9b fe ff ff    	jne    80416044ec <check_page_free_list+0x159>
  return (pp - pages) << PGSHIFT;
  8041604651:	48 c1 f9 04          	sar    $0x4,%rcx
  8041604655:	48 c1 e1 0c          	shl    $0xc,%rcx
  8041604659:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  804160465c:	0f 84 bf fe ff ff    	je     8041604521 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604662:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  8041604669:	0f 84 e7 fe ff ff    	je     8041604556 <check_page_free_list+0x1c3>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  804160466f:	48 81 fe 00 f0 0f 00 	cmp    $0xff000,%rsi
  8041604676:	0f 84 0f ff ff ff    	je     804160458b <check_page_free_list+0x1f8>
    assert(page2pa(pp) != EXTPHYSMEM);
  804160467c:	48 81 fe 00 00 10 00 	cmp    $0x100000,%rsi
  8041604683:	0f 84 37 ff ff ff    	je     80416045c0 <check_page_free_list+0x22d>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
  8041604689:	48 81 fe ff ff 0f 00 	cmp    $0xfffff,%rsi
  8041604690:	76 92                	jbe    8041604624 <check_page_free_list+0x291>
  if (PGNUM(pa) >= npages)
  8041604692:	49 89 f2             	mov    %rsi,%r10
  8041604695:	49 c1 ea 0c          	shr    $0xc,%r10
  8041604699:	4d 39 d3             	cmp    %r10,%r11
  804160469c:	0f 86 53 ff ff ff    	jbe    80416045f5 <check_page_free_list+0x262>
  return (void *)(pa + KERNBASE);
  80416046a2:	48 01 de             	add    %rbx,%rsi
  80416046a5:	48 39 f0             	cmp    %rsi,%rax
  80416046a8:	0f 86 72 ff ff ff    	jbe    8041604620 <check_page_free_list+0x28d>
  80416046ae:	48 b9 08 c8 60 41 80 	movabs $0x804160c808,%rcx
  80416046b5:	00 00 00 
  80416046b8:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416046bf:	00 00 00 
  80416046c2:	be b8 03 00 00       	mov    $0x3b8,%esi
  80416046c7:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416046ce:	00 00 00 
  80416046d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046d6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416046dd:	00 00 00 
  80416046e0:	41 ff d0             	callq  *%r8
  assert(nfree_extmem > 0);
  80416046e3:	45 85 c9             	test   %r9d,%r9d
  80416046e6:	7e 07                	jle    80416046ef <check_page_free_list+0x35c>
}
  80416046e8:	48 83 c4 28          	add    $0x28,%rsp
  80416046ec:	5b                   	pop    %rbx
  80416046ed:	5d                   	pop    %rbp
  80416046ee:	c3                   	retq   
  assert(nfree_extmem > 0);
  80416046ef:	48 b9 62 d1 60 41 80 	movabs $0x804160d162,%rcx
  80416046f6:	00 00 00 
  80416046f9:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041604700:	00 00 00 
  8041604703:	be c1 03 00 00       	mov    $0x3c1,%esi
  8041604708:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160470f:	00 00 00 
  8041604712:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604717:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160471e:	00 00 00 
  8041604721:	41 ff d0             	callq  *%r8
  if (!page_free_list)
  8041604724:	48 a1 e8 43 70 41 80 	movabs 0x80417043e8,%rax
  804160472b:	00 00 00 
  804160472e:	48 85 c0             	test   %rax,%rax
  8041604731:	0f 84 21 fd ff ff    	je     8041604458 <check_page_free_list+0xc5>
    struct PageInfo **tp[2] = {&pp1, &pp2};
  8041604737:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  804160473b:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  804160473f:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  8041604743:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  return (pp - pages) << PGSHIFT;
  8041604747:	48 be 38 59 70 41 80 	movabs $0x8041705938,%rsi
  804160474e:	00 00 00 
  8041604751:	48 89 c2             	mov    %rax,%rdx
  8041604754:	48 2b 16             	sub    (%rsi),%rdx
  8041604757:	48 c1 e2 08          	shl    $0x8,%rdx
      int pagetype  = VPN(page2pa(pp)) >= pdx_limit;
  804160475b:	48 c1 ea 0c          	shr    $0xc,%rdx
      *tp[pagetype] = pp;
  804160475f:	0f 95 c2             	setne  %dl
  8041604762:	0f b6 d2             	movzbl %dl,%edx
  8041604765:	48 8b 4c d5 e0       	mov    -0x20(%rbp,%rdx,8),%rcx
  804160476a:	48 89 01             	mov    %rax,(%rcx)
      tp[pagetype]  = &pp->pp_link;
  804160476d:	48 89 44 d5 e0       	mov    %rax,-0x20(%rbp,%rdx,8)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604772:	48 8b 00             	mov    (%rax),%rax
  8041604775:	48 85 c0             	test   %rax,%rax
  8041604778:	75 d7                	jne    8041604751 <check_page_free_list+0x3be>
    *tp[1]         = 0;
  804160477a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  804160477e:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    *tp[0]         = pp2;
  8041604785:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8041604789:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160478d:	48 89 10             	mov    %rdx,(%rax)
    page_free_list = pp1;
  8041604790:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8041604794:	48 a3 e8 43 70 41 80 	movabs %rax,0x80417043e8
  804160479b:	00 00 00 
  804160479e:	e9 16 fc ff ff       	jmpq   80416043b9 <check_page_free_list+0x26>

00000080416047a3 <is_page_allocatable>:
  if (!mmap_base || !mmap_end)
  80416047a3:	48 b8 d0 43 70 41 80 	movabs $0x80417043d0,%rax
  80416047aa:	00 00 00 
  80416047ad:	48 8b 10             	mov    (%rax),%rdx
  80416047b0:	48 85 d2             	test   %rdx,%rdx
  80416047b3:	0f 84 93 00 00 00    	je     804160484c <is_page_allocatable+0xa9>
  80416047b9:	48 b8 c8 43 70 41 80 	movabs $0x80417043c8,%rax
  80416047c0:	00 00 00 
  80416047c3:	48 8b 30             	mov    (%rax),%rsi
  80416047c6:	48 85 f6             	test   %rsi,%rsi
  80416047c9:	0f 84 83 00 00 00    	je     8041604852 <is_page_allocatable+0xaf>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047cf:	48 39 f2             	cmp    %rsi,%rdx
  80416047d2:	0f 83 80 00 00 00    	jae    8041604858 <is_page_allocatable+0xb5>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  80416047d8:	48 8b 42 08          	mov    0x8(%rdx),%rax
  80416047dc:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  80416047e0:	48 89 c1             	mov    %rax,%rcx
  80416047e3:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  80416047e7:	48 39 cf             	cmp    %rcx,%rdi
  80416047ea:	73 05                	jae    80416047f1 <is_page_allocatable+0x4e>
  80416047ec:	48 39 c7             	cmp    %rax,%rdi
  80416047ef:	73 34                	jae    8041604825 <is_page_allocatable+0x82>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047f1:	48 b8 c0 43 70 41 80 	movabs $0x80417043c0,%rax
  80416047f8:	00 00 00 
  80416047fb:	4c 8b 00             	mov    (%rax),%r8
  80416047fe:	4c 01 c2             	add    %r8,%rdx
  8041604801:	48 39 d6             	cmp    %rdx,%rsi
  8041604804:	76 40                	jbe    8041604846 <is_page_allocatable+0xa3>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  8041604806:	48 8b 42 08          	mov    0x8(%rdx),%rax
  804160480a:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  804160480e:	48 89 c1             	mov    %rax,%rcx
  8041604811:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  8041604815:	48 39 f9             	cmp    %rdi,%rcx
  8041604818:	0f 97 c1             	seta   %cl
  804160481b:	48 39 f8             	cmp    %rdi,%rax
  804160481e:	0f 96 c0             	setbe  %al
  8041604821:	84 c1                	test   %al,%cl
  8041604823:	74 d9                	je     80416047fe <is_page_allocatable+0x5b>
      switch (mmap_curr->Type) {
  8041604825:	8b 0a                	mov    (%rdx),%ecx
  8041604827:	85 c9                	test   %ecx,%ecx
  8041604829:	74 33                	je     804160485e <is_page_allocatable+0xbb>
  804160482b:	83 f9 04             	cmp    $0x4,%ecx
  804160482e:	76 0a                	jbe    804160483a <is_page_allocatable+0x97>
          return false;
  8041604830:	b8 00 00 00 00       	mov    $0x0,%eax
      switch (mmap_curr->Type) {
  8041604835:	83 f9 07             	cmp    $0x7,%ecx
  8041604838:	75 29                	jne    8041604863 <is_page_allocatable+0xc0>
          if (mmap_curr->Attribute & EFI_MEMORY_WB)
  804160483a:	48 8b 42 20          	mov    0x20(%rdx),%rax
  804160483e:	48 c1 e8 03          	shr    $0x3,%rax
  8041604842:	83 e0 01             	and    $0x1,%eax
  8041604845:	c3                   	retq   
  return true;
  8041604846:	b8 01 00 00 00       	mov    $0x1,%eax
  804160484b:	c3                   	retq   
    return true; //Assume page is allocabale if no loading parameters were passed.
  804160484c:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604851:	c3                   	retq   
  8041604852:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604857:	c3                   	retq   
  return true;
  8041604858:	b8 01 00 00 00       	mov    $0x1,%eax
  804160485d:	c3                   	retq   
          return false;
  804160485e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041604863:	c3                   	retq   

0000008041604864 <page_init>:
page_init(void) {
  8041604864:	55                   	push   %rbp
  8041604865:	48 89 e5             	mov    %rsp,%rbp
  8041604868:	41 57                	push   %r15
  804160486a:	41 56                	push   %r14
  804160486c:	41 55                	push   %r13
  804160486e:	41 54                	push   %r12
  8041604870:	53                   	push   %rbx
  8041604871:	48 83 ec 08          	sub    $0x8,%rsp
  pages[0].pp_ref  = 1;
  8041604875:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  804160487c:	00 00 00 
  804160487f:	48 8b 10             	mov    (%rax),%rdx
  8041604882:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
  pages[0].pp_link = NULL;
  8041604888:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  pages[1].pp_ref = 0;
  804160488f:	4c 8b 20             	mov    (%rax),%r12
  8041604892:	66 41 c7 44 24 18 00 	movw   $0x0,0x18(%r12)
  8041604899:	00 
  page_free_list  = &pages[1];
  804160489a:	49 83 c4 10          	add    $0x10,%r12
  804160489e:	4c 89 e0             	mov    %r12,%rax
  80416048a1:	48 a3 e8 43 70 41 80 	movabs %rax,0x80417043e8
  80416048a8:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  80416048ab:	48 b8 f0 43 70 41 80 	movabs $0x80417043f0,%rax
  80416048b2:	00 00 00 
  80416048b5:	48 83 38 01          	cmpq   $0x1,(%rax)
  80416048b9:	76 6a                	jbe    8041604925 <page_init+0xc1>
  80416048bb:	bb 01 00 00 00       	mov    $0x1,%ebx
    if (is_page_allocatable(i)) {
  80416048c0:	49 bf a3 47 60 41 80 	movabs $0x80416047a3,%r15
  80416048c7:	00 00 00 
      pages[i].pp_ref  = 1;
  80416048ca:	49 bd 38 59 70 41 80 	movabs $0x8041705938,%r13
  80416048d1:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  80416048d4:	49 89 c6             	mov    %rax,%r14
  80416048d7:	eb 21                	jmp    80416048fa <page_init+0x96>
      pages[i].pp_ref  = 1;
  80416048d9:	48 89 d8             	mov    %rbx,%rax
  80416048dc:	48 c1 e0 04          	shl    $0x4,%rax
  80416048e0:	49 03 45 00          	add    0x0(%r13),%rax
  80416048e4:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  80416048ea:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = 1; i < npages_basemem; i++) {
  80416048f1:	48 83 c3 01          	add    $0x1,%rbx
  80416048f5:	49 39 1e             	cmp    %rbx,(%r14)
  80416048f8:	76 2b                	jbe    8041604925 <page_init+0xc1>
    if (is_page_allocatable(i)) {
  80416048fa:	48 89 df             	mov    %rbx,%rdi
  80416048fd:	41 ff d7             	callq  *%r15
  8041604900:	84 c0                	test   %al,%al
  8041604902:	74 d5                	je     80416048d9 <page_init+0x75>
      pages[i].pp_ref = 0;
  8041604904:	48 89 d8             	mov    %rbx,%rax
  8041604907:	48 c1 e0 04          	shl    $0x4,%rax
  804160490b:	48 89 c2             	mov    %rax,%rdx
  804160490e:	49 03 55 00          	add    0x0(%r13),%rdx
  8041604912:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  8041604918:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  804160491c:	49 03 45 00          	add    0x0(%r13),%rax
  8041604920:	49 89 c4             	mov    %rax,%r12
  8041604923:	eb cc                	jmp    80416048f1 <page_init+0x8d>
  first_free_page = PADDR(boot_alloc(0)) / PGSIZE;
  8041604925:	bf 00 00 00 00       	mov    $0x0,%edi
  804160492a:	48 b8 b7 42 60 41 80 	movabs $0x80416042b7,%rax
  8041604931:	00 00 00 
  8041604934:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041604936:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160493d:	00 00 00 
  8041604940:	48 39 d0             	cmp    %rdx,%rax
  8041604943:	76 7d                	jbe    80416049c2 <page_init+0x15e>
  return (physaddr_t)kva - KERNBASE;
  8041604945:	48 bb 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rbx
  804160494c:	ff ff ff 
  804160494f:	48 01 c3             	add    %rax,%rbx
  8041604952:	48 c1 eb 0c          	shr    $0xc,%rbx
  for (i = npages_basemem; i < first_free_page; i++) {
  8041604956:	48 a1 f0 43 70 41 80 	movabs 0x80417043f0,%rax
  804160495d:	00 00 00 
  8041604960:	48 39 c3             	cmp    %rax,%rbx
  8041604963:	76 31                	jbe    8041604996 <page_init+0x132>
  8041604965:	48 c1 e0 04          	shl    $0x4,%rax
  8041604969:	48 89 de             	mov    %rbx,%rsi
  804160496c:	48 c1 e6 04          	shl    $0x4,%rsi
    pages[i].pp_ref  = 1;
  8041604970:	48 b9 38 59 70 41 80 	movabs $0x8041705938,%rcx
  8041604977:	00 00 00 
  804160497a:	48 89 c2             	mov    %rax,%rdx
  804160497d:	48 03 11             	add    (%rcx),%rdx
  8041604980:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
    pages[i].pp_link = NULL;
  8041604986:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  for (i = npages_basemem; i < first_free_page; i++) {
  804160498d:	48 83 c0 10          	add    $0x10,%rax
  8041604991:	48 39 f0             	cmp    %rsi,%rax
  8041604994:	75 e4                	jne    804160497a <page_init+0x116>
  for (i = first_free_page; i < npages; i++) {
  8041604996:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  804160499d:	00 00 00 
  80416049a0:	48 3b 18             	cmp    (%rax),%rbx
  80416049a3:	0f 83 93 00 00 00    	jae    8041604a3c <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  80416049a9:	49 bf a3 47 60 41 80 	movabs $0x80416047a3,%r15
  80416049b0:	00 00 00 
      pages[i].pp_ref  = 1;
  80416049b3:	49 bd 38 59 70 41 80 	movabs $0x8041705938,%r13
  80416049ba:	00 00 00 
  for (i = first_free_page; i < npages; i++) {
  80416049bd:	49 89 c6             	mov    %rax,%r14
  80416049c0:	eb 4f                	jmp    8041604a11 <page_init+0x1ad>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416049c2:	48 89 c1             	mov    %rax,%rcx
  80416049c5:	48 ba 38 c7 60 41 80 	movabs $0x804160c738,%rdx
  80416049cc:	00 00 00 
  80416049cf:	be d6 01 00 00       	mov    $0x1d6,%esi
  80416049d4:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416049db:	00 00 00 
  80416049de:	b8 00 00 00 00       	mov    $0x0,%eax
  80416049e3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416049ea:	00 00 00 
  80416049ed:	41 ff d0             	callq  *%r8
      pages[i].pp_ref  = 1;
  80416049f0:	48 89 d8             	mov    %rbx,%rax
  80416049f3:	48 c1 e0 04          	shl    $0x4,%rax
  80416049f7:	49 03 45 00          	add    0x0(%r13),%rax
  80416049fb:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  8041604a01:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = first_free_page; i < npages; i++) {
  8041604a08:	48 83 c3 01          	add    $0x1,%rbx
  8041604a0c:	49 39 1e             	cmp    %rbx,(%r14)
  8041604a0f:	76 2b                	jbe    8041604a3c <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  8041604a11:	48 89 df             	mov    %rbx,%rdi
  8041604a14:	41 ff d7             	callq  *%r15
  8041604a17:	84 c0                	test   %al,%al
  8041604a19:	74 d5                	je     80416049f0 <page_init+0x18c>
      pages[i].pp_ref = 0;
  8041604a1b:	48 89 d8             	mov    %rbx,%rax
  8041604a1e:	48 c1 e0 04          	shl    $0x4,%rax
  8041604a22:	48 89 c2             	mov    %rax,%rdx
  8041604a25:	49 03 55 00          	add    0x0(%r13),%rdx
  8041604a29:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  8041604a2f:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  8041604a33:	49 03 45 00          	add    0x0(%r13),%rax
  8041604a37:	49 89 c4             	mov    %rax,%r12
  8041604a3a:	eb cc                	jmp    8041604a08 <page_init+0x1a4>
}
  8041604a3c:	48 83 c4 08          	add    $0x8,%rsp
  8041604a40:	5b                   	pop    %rbx
  8041604a41:	41 5c                	pop    %r12
  8041604a43:	41 5d                	pop    %r13
  8041604a45:	41 5e                	pop    %r14
  8041604a47:	41 5f                	pop    %r15
  8041604a49:	5d                   	pop    %rbp
  8041604a4a:	c3                   	retq   

0000008041604a4b <page_alloc>:
page_alloc(int alloc_flags) {
  8041604a4b:	55                   	push   %rbp
  8041604a4c:	48 89 e5             	mov    %rsp,%rbp
  8041604a4f:	53                   	push   %rbx
  8041604a50:	48 83 ec 08          	sub    $0x8,%rsp
  if (!page_free_list) {
  8041604a54:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  8041604a5b:	00 00 00 
  8041604a5e:	48 8b 18             	mov    (%rax),%rbx
  8041604a61:	48 85 db             	test   %rbx,%rbx
  8041604a64:	74 1f                	je     8041604a85 <page_alloc+0x3a>
  page_free_list               = page_free_list->pp_link;
  8041604a66:	48 8b 03             	mov    (%rbx),%rax
  8041604a69:	48 a3 e8 43 70 41 80 	movabs %rax,0x80417043e8
  8041604a70:	00 00 00 
  return_page->pp_link         = NULL;
  8041604a73:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  if (!page_free_list) {
  8041604a7a:	48 85 c0             	test   %rax,%rax
  8041604a7d:	74 10                	je     8041604a8f <page_alloc+0x44>
  if (alloc_flags & ALLOC_ZERO) {
  8041604a7f:	40 f6 c7 01          	test   $0x1,%dil
  8041604a83:	75 1d                	jne    8041604aa2 <page_alloc+0x57>
}
  8041604a85:	48 89 d8             	mov    %rbx,%rax
  8041604a88:	48 83 c4 08          	add    $0x8,%rsp
  8041604a8c:	5b                   	pop    %rbx
  8041604a8d:	5d                   	pop    %rbp
  8041604a8e:	c3                   	retq   
    page_free_list_top = NULL;
  8041604a8f:	48 b8 e0 43 70 41 80 	movabs $0x80417043e0,%rax
  8041604a96:	00 00 00 
  8041604a99:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  8041604aa0:	eb dd                	jmp    8041604a7f <page_alloc+0x34>
  return (pp - pages) << PGSHIFT;
  8041604aa2:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041604aa9:	00 00 00 
  8041604aac:	48 89 df             	mov    %rbx,%rdi
  8041604aaf:	48 2b 38             	sub    (%rax),%rdi
  8041604ab2:	48 c1 ff 04          	sar    $0x4,%rdi
  8041604ab6:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041604aba:	48 89 fa             	mov    %rdi,%rdx
  8041604abd:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041604ac1:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041604ac8:	00 00 00 
  8041604acb:	48 3b 10             	cmp    (%rax),%rdx
  8041604ace:	73 25                	jae    8041604af5 <page_alloc+0xaa>
  return (void *)(pa + KERNBASE);
  8041604ad0:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604ad7:	00 00 00 
  8041604ada:	48 01 cf             	add    %rcx,%rdi
    memset(page2kva(return_page), 0, PGSIZE);
  8041604add:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041604ae2:	be 00 00 00 00       	mov    $0x0,%esi
  8041604ae7:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041604aee:	00 00 00 
  8041604af1:	ff d0                	callq  *%rax
  8041604af3:	eb 90                	jmp    8041604a85 <page_alloc+0x3a>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604af5:	48 89 f9             	mov    %rdi,%rcx
  8041604af8:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604aff:	00 00 00 
  8041604b02:	be 63 00 00 00       	mov    $0x63,%esi
  8041604b07:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041604b0e:	00 00 00 
  8041604b11:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b16:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604b1d:	00 00 00 
  8041604b20:	41 ff d0             	callq  *%r8

0000008041604b23 <page_is_allocated>:
  return !pp->pp_link && pp != page_free_list_top;
  8041604b23:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b28:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604b2c:	74 01                	je     8041604b2f <page_is_allocated+0xc>
}
  8041604b2e:	c3                   	retq   
  return !pp->pp_link && pp != page_free_list_top;
  8041604b2f:	48 b8 e0 43 70 41 80 	movabs $0x80417043e0,%rax
  8041604b36:	00 00 00 
  8041604b39:	48 39 38             	cmp    %rdi,(%rax)
  8041604b3c:	0f 95 c0             	setne  %al
  8041604b3f:	0f b6 c0             	movzbl %al,%eax
  8041604b42:	eb ea                	jmp    8041604b2e <page_is_allocated+0xb>

0000008041604b44 <page_free>:
page_free(struct PageInfo *pp) {
  8041604b44:	55                   	push   %rbp
  8041604b45:	48 89 e5             	mov    %rsp,%rbp
  if (pp->pp_ref) {
  8041604b48:	66 83 7f 08 00       	cmpw   $0x0,0x8(%rdi)
  8041604b4d:	75 2b                	jne    8041604b7a <page_free+0x36>
  if (pp->pp_link) {
  8041604b4f:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604b53:	75 4f                	jne    8041604ba4 <page_free+0x60>
  pp->pp_link    = page_free_list;
  8041604b55:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  8041604b5c:	00 00 00 
  8041604b5f:	48 8b 10             	mov    (%rax),%rdx
  8041604b62:	48 89 17             	mov    %rdx,(%rdi)
  page_free_list = pp;
  8041604b65:	48 89 38             	mov    %rdi,(%rax)
  if (!page_free_list_top) {
  8041604b68:	48 b8 e0 43 70 41 80 	movabs $0x80417043e0,%rax
  8041604b6f:	00 00 00 
  8041604b72:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604b76:	74 56                	je     8041604bce <page_free+0x8a>
}
  8041604b78:	5d                   	pop    %rbp
  8041604b79:	c3                   	retq   
    panic("page_free: Page is still referenced!\n");
  8041604b7a:	48 ba 50 c8 60 41 80 	movabs $0x804160c850,%rdx
  8041604b81:	00 00 00 
  8041604b84:	be 2a 02 00 00       	mov    $0x22a,%esi
  8041604b89:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604b90:	00 00 00 
  8041604b93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b98:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604b9f:	00 00 00 
  8041604ba2:	ff d1                	callq  *%rcx
    panic("page_free: Page is already freed!\n");
  8041604ba4:	48 ba 78 c8 60 41 80 	movabs $0x804160c878,%rdx
  8041604bab:	00 00 00 
  8041604bae:	be 2e 02 00 00       	mov    $0x22e,%esi
  8041604bb3:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604bba:	00 00 00 
  8041604bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604bc2:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604bc9:	00 00 00 
  8041604bcc:	ff d1                	callq  *%rcx
    page_free_list_top = pp;
  8041604bce:	48 89 f8             	mov    %rdi,%rax
  8041604bd1:	48 a3 e0 43 70 41 80 	movabs %rax,0x80417043e0
  8041604bd8:	00 00 00 
}
  8041604bdb:	eb 9b                	jmp    8041604b78 <page_free+0x34>

0000008041604bdd <page_decref>:
  if (--pp->pp_ref == 0)
  8041604bdd:	0f b7 47 08          	movzwl 0x8(%rdi),%eax
  8041604be1:	83 e8 01             	sub    $0x1,%eax
  8041604be4:	66 89 47 08          	mov    %ax,0x8(%rdi)
  8041604be8:	66 85 c0             	test   %ax,%ax
  8041604beb:	74 01                	je     8041604bee <page_decref+0x11>
  8041604bed:	c3                   	retq   
page_decref(struct PageInfo *pp) {
  8041604bee:	55                   	push   %rbp
  8041604bef:	48 89 e5             	mov    %rsp,%rbp
    page_free(pp);
  8041604bf2:	48 b8 44 4b 60 41 80 	movabs $0x8041604b44,%rax
  8041604bf9:	00 00 00 
  8041604bfc:	ff d0                	callq  *%rax
}
  8041604bfe:	5d                   	pop    %rbp
  8041604bff:	c3                   	retq   

0000008041604c00 <pgdir_walk>:
pgdir_walk(pde_t *pgdir, const void *va, int create) {
  8041604c00:	55                   	push   %rbp
  8041604c01:	48 89 e5             	mov    %rsp,%rbp
  8041604c04:	41 54                	push   %r12
  8041604c06:	53                   	push   %rbx
  8041604c07:	48 89 f3             	mov    %rsi,%rbx
  if (pgdir[PDX(va)] & PTE_P) {
  8041604c0a:	49 89 f4             	mov    %rsi,%r12
  8041604c0d:	49 c1 ec 12          	shr    $0x12,%r12
  8041604c11:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
  8041604c18:	49 01 fc             	add    %rdi,%r12
  8041604c1b:	49 8b 0c 24          	mov    (%r12),%rcx
  8041604c1f:	f6 c1 01             	test   $0x1,%cl
  8041604c22:	74 68                	je     8041604c8c <pgdir_walk+0x8c>
    return (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
  8041604c24:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604c2b:	48 89 c8             	mov    %rcx,%rax
  8041604c2e:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604c32:	48 ba 30 59 70 41 80 	movabs $0x8041705930,%rdx
  8041604c39:	00 00 00 
  8041604c3c:	48 39 02             	cmp    %rax,(%rdx)
  8041604c3f:	76 20                	jbe    8041604c61 <pgdir_walk+0x61>
  return (void *)(pa + KERNBASE);
  8041604c41:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041604c48:	00 00 00 
  8041604c4b:	48 01 c1             	add    %rax,%rcx
  8041604c4e:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604c52:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604c58:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
}
  8041604c5c:	5b                   	pop    %rbx
  8041604c5d:	41 5c                	pop    %r12
  8041604c5f:	5d                   	pop    %rbp
  8041604c60:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604c61:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604c68:	00 00 00 
  8041604c6b:	be 87 02 00 00       	mov    $0x287,%esi
  8041604c70:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604c77:	00 00 00 
  8041604c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604c7f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604c86:	00 00 00 
  8041604c89:	41 ff d0             	callq  *%r8
  if (create) {
  8041604c8c:	85 d2                	test   %edx,%edx
  8041604c8e:	0f 84 aa 00 00 00    	je     8041604d3e <pgdir_walk+0x13e>
    np = page_alloc(ALLOC_ZERO);
  8041604c94:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604c99:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041604ca0:	00 00 00 
  8041604ca3:	ff d0                	callq  *%rax
    if (np) {
  8041604ca5:	48 85 c0             	test   %rax,%rax
  8041604ca8:	74 b2                	je     8041604c5c <pgdir_walk+0x5c>
      np->pp_ref++;
  8041604caa:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604caf:	48 b9 38 59 70 41 80 	movabs $0x8041705938,%rcx
  8041604cb6:	00 00 00 
  8041604cb9:	48 89 c2             	mov    %rax,%rdx
  8041604cbc:	48 2b 11             	sub    (%rcx),%rdx
  8041604cbf:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604cc3:	48 c1 e2 0c          	shl    $0xc,%rdx
      pgdir[PDX(va)] = page2pa(np) | PTE_P | PTE_U | PTE_W;
  8041604cc7:	48 83 ca 07          	or     $0x7,%rdx
  8041604ccb:	49 89 14 24          	mov    %rdx,(%r12)
  8041604ccf:	48 2b 01             	sub    (%rcx),%rax
  8041604cd2:	48 c1 f8 04          	sar    $0x4,%rax
  8041604cd6:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  8041604cda:	48 89 c1             	mov    %rax,%rcx
  8041604cdd:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604ce1:	48 ba 30 59 70 41 80 	movabs $0x8041705930,%rdx
  8041604ce8:	00 00 00 
  8041604ceb:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604cee:	73 20                	jae    8041604d10 <pgdir_walk+0x110>
  return (void *)(pa + KERNBASE);
  8041604cf0:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604cf7:	00 00 00 
  8041604cfa:	48 01 c1             	add    %rax,%rcx
      return (pte_t *)page2kva(np) + PTX(va);
  8041604cfd:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604d01:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604d07:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
  8041604d0b:	e9 4c ff ff ff       	jmpq   8041604c5c <pgdir_walk+0x5c>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604d10:	48 89 c1             	mov    %rax,%rcx
  8041604d13:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604d1a:	00 00 00 
  8041604d1d:	be 63 00 00 00       	mov    $0x63,%esi
  8041604d22:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041604d29:	00 00 00 
  8041604d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d31:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604d38:	00 00 00 
  8041604d3b:	41 ff d0             	callq  *%r8
  return NULL;
  8041604d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d43:	e9 14 ff ff ff       	jmpq   8041604c5c <pgdir_walk+0x5c>

0000008041604d48 <pdpe_walk>:
pdpe_walk(pdpe_t *pdpe, const void *va, int create) {
  8041604d48:	55                   	push   %rbp
  8041604d49:	48 89 e5             	mov    %rsp,%rbp
  8041604d4c:	41 55                	push   %r13
  8041604d4e:	41 54                	push   %r12
  8041604d50:	53                   	push   %rbx
  8041604d51:	48 83 ec 08          	sub    $0x8,%rsp
  8041604d55:	48 89 f3             	mov    %rsi,%rbx
  8041604d58:	41 89 d4             	mov    %edx,%r12d
  if (pdpe[PDPE(va)] & PTE_P) {
  8041604d5b:	49 89 f5             	mov    %rsi,%r13
  8041604d5e:	49 c1 ed 1b          	shr    $0x1b,%r13
  8041604d62:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604d69:	49 01 fd             	add    %rdi,%r13
  8041604d6c:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604d70:	f6 c1 01             	test   $0x1,%cl
  8041604d73:	74 6f                	je     8041604de4 <pdpe_walk+0x9c>
    return pgdir_walk((pte_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604d75:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604d7c:	48 89 c8             	mov    %rcx,%rax
  8041604d7f:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604d83:	48 ba 30 59 70 41 80 	movabs $0x8041705930,%rdx
  8041604d8a:	00 00 00 
  8041604d8d:	48 39 02             	cmp    %rax,(%rdx)
  8041604d90:	76 27                	jbe    8041604db9 <pdpe_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604d92:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604d99:	00 00 00 
  8041604d9c:	48 01 cf             	add    %rcx,%rdi
  8041604d9f:	44 89 e2             	mov    %r12d,%edx
  8041604da2:	48 b8 00 4c 60 41 80 	movabs $0x8041604c00,%rax
  8041604da9:	00 00 00 
  8041604dac:	ff d0                	callq  *%rax
}
  8041604dae:	48 83 c4 08          	add    $0x8,%rsp
  8041604db2:	5b                   	pop    %rbx
  8041604db3:	41 5c                	pop    %r12
  8041604db5:	41 5d                	pop    %r13
  8041604db7:	5d                   	pop    %rbp
  8041604db8:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604db9:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604dc0:	00 00 00 
  8041604dc3:	be 74 02 00 00       	mov    $0x274,%esi
  8041604dc8:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604dcf:	00 00 00 
  8041604dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604dd7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604dde:	00 00 00 
  8041604de1:	41 ff d0             	callq  *%r8
  if (create) {
  8041604de4:	85 d2                	test   %edx,%edx
  8041604de6:	0f 84 a3 00 00 00    	je     8041604e8f <pdpe_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604dec:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604df1:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041604df8:	00 00 00 
  8041604dfb:	ff d0                	callq  *%rax
    if (np) {
  8041604dfd:	48 85 c0             	test   %rax,%rax
  8041604e00:	74 ac                	je     8041604dae <pdpe_walk+0x66>
      np->pp_ref++;
  8041604e02:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604e07:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  8041604e0e:	00 00 00 
  8041604e11:	48 2b 02             	sub    (%rdx),%rax
  8041604e14:	48 c1 f8 04          	sar    $0x4,%rax
  8041604e18:	48 c1 e0 0c          	shl    $0xc,%rax
      pdpe[PDPE(va)] = page2pa(np) | PTE_P | PTE_U | PTE_W;
  8041604e1c:	48 89 c2             	mov    %rax,%rdx
  8041604e1f:	48 83 ca 07          	or     $0x7,%rdx
  8041604e23:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604e27:	48 89 c1             	mov    %rax,%rcx
  8041604e2a:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604e2e:	48 ba 30 59 70 41 80 	movabs $0x8041705930,%rdx
  8041604e35:	00 00 00 
  8041604e38:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604e3b:	73 24                	jae    8041604e61 <pdpe_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604e3d:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604e44:	00 00 00 
  8041604e47:	48 01 c7             	add    %rax,%rdi
      return pgdir_walk((pte_t *) KADDR (PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604e4a:	44 89 e2             	mov    %r12d,%edx
  8041604e4d:	48 89 de             	mov    %rbx,%rsi
  8041604e50:	48 b8 00 4c 60 41 80 	movabs $0x8041604c00,%rax
  8041604e57:	00 00 00 
  8041604e5a:	ff d0                	callq  *%rax
  8041604e5c:	e9 4d ff ff ff       	jmpq   8041604dae <pdpe_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604e61:	48 89 c1             	mov    %rax,%rcx
  8041604e64:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604e6b:	00 00 00 
  8041604e6e:	be 7d 02 00 00       	mov    $0x27d,%esi
  8041604e73:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604e7a:	00 00 00 
  8041604e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e82:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604e89:	00 00 00 
  8041604e8c:	41 ff d0             	callq  *%r8
  return NULL;
  8041604e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e94:	e9 15 ff ff ff       	jmpq   8041604dae <pdpe_walk+0x66>

0000008041604e99 <pml4e_walk>:
pml4e_walk(pml4e_t *pml4e, const void *va, int create) {
  8041604e99:	55                   	push   %rbp
  8041604e9a:	48 89 e5             	mov    %rsp,%rbp
  8041604e9d:	41 55                	push   %r13
  8041604e9f:	41 54                	push   %r12
  8041604ea1:	53                   	push   %rbx
  8041604ea2:	48 83 ec 08          	sub    $0x8,%rsp
  8041604ea6:	48 89 f3             	mov    %rsi,%rbx
  8041604ea9:	41 89 d4             	mov    %edx,%r12d
  if (pml4e[PML4(va)] & PTE_P) {
  8041604eac:	49 89 f5             	mov    %rsi,%r13
  8041604eaf:	49 c1 ed 24          	shr    $0x24,%r13
  8041604eb3:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604eba:	49 01 fd             	add    %rdi,%r13
  8041604ebd:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604ec1:	f6 c1 01             	test   $0x1,%cl
  8041604ec4:	74 6f                	je     8041604f35 <pml4e_walk+0x9c>
    return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604ec6:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604ecd:	48 89 c8             	mov    %rcx,%rax
  8041604ed0:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604ed4:	48 ba 30 59 70 41 80 	movabs $0x8041705930,%rdx
  8041604edb:	00 00 00 
  8041604ede:	48 39 02             	cmp    %rax,(%rdx)
  8041604ee1:	76 27                	jbe    8041604f0a <pml4e_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604ee3:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604eea:	00 00 00 
  8041604eed:	48 01 cf             	add    %rcx,%rdi
  8041604ef0:	44 89 e2             	mov    %r12d,%edx
  8041604ef3:	48 b8 48 4d 60 41 80 	movabs $0x8041604d48,%rax
  8041604efa:	00 00 00 
  8041604efd:	ff d0                	callq  *%rax
}
  8041604eff:	48 83 c4 08          	add    $0x8,%rsp
  8041604f03:	5b                   	pop    %rbx
  8041604f04:	41 5c                	pop    %r12
  8041604f06:	41 5d                	pop    %r13
  8041604f08:	5d                   	pop    %rbp
  8041604f09:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604f0a:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604f11:	00 00 00 
  8041604f14:	be 60 02 00 00       	mov    $0x260,%esi
  8041604f19:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604f20:	00 00 00 
  8041604f23:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f28:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604f2f:	00 00 00 
  8041604f32:	41 ff d0             	callq  *%r8
  if (create) {
  8041604f35:	85 d2                	test   %edx,%edx
  8041604f37:	0f 84 a3 00 00 00    	je     8041604fe0 <pml4e_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604f3d:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604f42:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041604f49:	00 00 00 
  8041604f4c:	ff d0                	callq  *%rax
    if (np) {
  8041604f4e:	48 85 c0             	test   %rax,%rax
  8041604f51:	74 ac                	je     8041604eff <pml4e_walk+0x66>
      np->pp_ref++;
  8041604f53:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604f58:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  8041604f5f:	00 00 00 
  8041604f62:	48 2b 02             	sub    (%rdx),%rax
  8041604f65:	48 c1 f8 04          	sar    $0x4,%rax
  8041604f69:	48 c1 e0 0c          	shl    $0xc,%rax
      pml4e[PML4(va)] = page2pa(np) | PTE_P | PTE_U | PTE_W;
  8041604f6d:	48 89 c2             	mov    %rax,%rdx
  8041604f70:	48 83 ca 07          	or     $0x7,%rdx
  8041604f74:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604f78:	48 89 c1             	mov    %rax,%rcx
  8041604f7b:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604f7f:	48 ba 30 59 70 41 80 	movabs $0x8041705930,%rdx
  8041604f86:	00 00 00 
  8041604f89:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604f8c:	73 24                	jae    8041604fb2 <pml4e_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604f8e:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604f95:	00 00 00 
  8041604f98:	48 01 c7             	add    %rax,%rdi
      return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604f9b:	44 89 e2             	mov    %r12d,%edx
  8041604f9e:	48 89 de             	mov    %rbx,%rsi
  8041604fa1:	48 b8 48 4d 60 41 80 	movabs $0x8041604d48,%rax
  8041604fa8:	00 00 00 
  8041604fab:	ff d0                	callq  *%rax
  8041604fad:	e9 4d ff ff ff       	jmpq   8041604eff <pml4e_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604fb2:	48 89 c1             	mov    %rax,%rcx
  8041604fb5:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041604fbc:	00 00 00 
  8041604fbf:	be 69 02 00 00       	mov    $0x269,%esi
  8041604fc4:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041604fcb:	00 00 00 
  8041604fce:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fd3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604fda:	00 00 00 
  8041604fdd:	41 ff d0             	callq  *%r8
  return NULL;
  8041604fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fe5:	e9 15 ff ff ff       	jmpq   8041604eff <pml4e_walk+0x66>

0000008041604fea <boot_map_region>:
  for (i = 0; i < size; i += PGSIZE) {
  8041604fea:	48 85 d2             	test   %rdx,%rdx
  8041604fed:	74 72                	je     8041605061 <boot_map_region+0x77>
boot_map_region(pml4e_t *pml4e, uintptr_t va, size_t size, physaddr_t pa, int perm) {
  8041604fef:	55                   	push   %rbp
  8041604ff0:	48 89 e5             	mov    %rsp,%rbp
  8041604ff3:	41 57                	push   %r15
  8041604ff5:	41 56                	push   %r14
  8041604ff7:	41 55                	push   %r13
  8041604ff9:	41 54                	push   %r12
  8041604ffb:	53                   	push   %rbx
  8041604ffc:	48 83 ec 28          	sub    $0x28,%rsp
  8041605000:	44 89 45 bc          	mov    %r8d,-0x44(%rbp)
  8041605004:	49 89 ce             	mov    %rcx,%r14
  8041605007:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  804160500b:	49 89 f5             	mov    %rsi,%r13
  804160500e:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  for (i = 0; i < size; i += PGSIZE) {
  8041605012:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    *pml4e_walk(pml4e, (void *)(va + i), 1) = (pa + i) | perm | PTE_P;
  8041605018:	49 bf 99 4e 60 41 80 	movabs $0x8041604e99,%r15
  804160501f:	00 00 00 
  8041605022:	4b 8d 1c 26          	lea    (%r14,%r12,1),%rbx
  8041605026:	48 63 45 bc          	movslq -0x44(%rbp),%rax
  804160502a:	48 09 c3             	or     %rax,%rbx
  804160502d:	4b 8d 74 25 00       	lea    0x0(%r13,%r12,1),%rsi
  8041605032:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605037:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160503b:	41 ff d7             	callq  *%r15
  804160503e:	48 83 cb 01          	or     $0x1,%rbx
  8041605042:	48 89 18             	mov    %rbx,(%rax)
  for (i = 0; i < size; i += PGSIZE) {
  8041605045:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  804160504c:	4c 39 65 c0          	cmp    %r12,-0x40(%rbp)
  8041605050:	77 d0                	ja     8041605022 <boot_map_region+0x38>
}
  8041605052:	48 83 c4 28          	add    $0x28,%rsp
  8041605056:	5b                   	pop    %rbx
  8041605057:	41 5c                	pop    %r12
  8041605059:	41 5d                	pop    %r13
  804160505b:	41 5e                	pop    %r14
  804160505d:	41 5f                	pop    %r15
  804160505f:	5d                   	pop    %rbp
  8041605060:	c3                   	retq   
  8041605061:	c3                   	retq   

0000008041605062 <page_lookup>:
page_lookup(pml4e_t *pml4e, void *va, pte_t **pte_store) {
  8041605062:	55                   	push   %rbp
  8041605063:	48 89 e5             	mov    %rsp,%rbp
  8041605066:	53                   	push   %rbx
  8041605067:	48 83 ec 08          	sub    $0x8,%rsp
  804160506b:	48 89 d3             	mov    %rdx,%rbx
  ptep = pml4e_walk(pml4e, va, 0);
  804160506e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605073:	48 b8 99 4e 60 41 80 	movabs $0x8041604e99,%rax
  804160507a:	00 00 00 
  804160507d:	ff d0                	callq  *%rax
  if (!ptep) {
  804160507f:	48 85 c0             	test   %rax,%rax
  8041605082:	74 3c                	je     80416050c0 <page_lookup+0x5e>
  if (pte_store) {
  8041605084:	48 85 db             	test   %rbx,%rbx
  8041605087:	74 03                	je     804160508c <page_lookup+0x2a>
    *pte_store = ptep;
  8041605089:	48 89 03             	mov    %rax,(%rbx)
  return pa2page(PTE_ADDR(*ptep));
  804160508c:	48 8b 30             	mov    (%rax),%rsi
  804160508f:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
}

static inline struct PageInfo *
pa2page(physaddr_t pa) {
  if (PPN(pa) >= npages) {
  8041605096:	48 89 f0             	mov    %rsi,%rax
  8041605099:	48 c1 e8 0c          	shr    $0xc,%rax
  804160509d:	48 ba 30 59 70 41 80 	movabs $0x8041705930,%rdx
  80416050a4:	00 00 00 
  80416050a7:	48 3b 02             	cmp    (%rdx),%rax
  80416050aa:	73 1b                	jae    80416050c7 <page_lookup+0x65>
    cprintf("accessing %lx\n", (unsigned long)pa);
    panic("pa2page called with invalid pa");
  }
  return &pages[PPN(pa)];
  80416050ac:	48 c1 e0 04          	shl    $0x4,%rax
  80416050b0:	48 b9 38 59 70 41 80 	movabs $0x8041705938,%rcx
  80416050b7:	00 00 00 
  80416050ba:	48 8b 11             	mov    (%rcx),%rdx
  80416050bd:	48 01 d0             	add    %rdx,%rax
}
  80416050c0:	48 83 c4 08          	add    $0x8,%rsp
  80416050c4:	5b                   	pop    %rbx
  80416050c5:	5d                   	pop    %rbp
  80416050c6:	c3                   	retq   
    cprintf("accessing %lx\n", (unsigned long)pa);
  80416050c7:	48 bf 73 d1 60 41 80 	movabs $0x804160d173,%rdi
  80416050ce:	00 00 00 
  80416050d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050d6:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416050dd:	00 00 00 
  80416050e0:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  80416050e2:	48 ba a0 c8 60 41 80 	movabs $0x804160c8a0,%rdx
  80416050e9:	00 00 00 
  80416050ec:	be 5c 00 00 00       	mov    $0x5c,%esi
  80416050f1:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  80416050f8:	00 00 00 
  80416050fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605100:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041605107:	00 00 00 
  804160510a:	ff d1                	callq  *%rcx

000000804160510c <tlb_invalidate>:
  if (!curenv || curenv->env_pml4e == pml4e)
  804160510c:	48 a1 f8 43 70 41 80 	movabs 0x80417043f8,%rax
  8041605113:	00 00 00 
  8041605116:	48 85 c0             	test   %rax,%rax
  8041605119:	74 09                	je     8041605124 <tlb_invalidate+0x18>
  804160511b:	48 39 b8 e8 00 00 00 	cmp    %rdi,0xe8(%rax)
  8041605122:	75 03                	jne    8041605127 <tlb_invalidate+0x1b>
  __asm __volatile("invlpg (%0)"
  8041605124:	0f 01 3e             	invlpg (%rsi)
}
  8041605127:	c3                   	retq   

0000008041605128 <page_remove>:
page_remove(pml4e_t *pml4e, void *va) {
  8041605128:	55                   	push   %rbp
  8041605129:	48 89 e5             	mov    %rsp,%rbp
  804160512c:	41 54                	push   %r12
  804160512e:	53                   	push   %rbx
  804160512f:	48 83 ec 10          	sub    $0x10,%rsp
  8041605133:	48 89 fb             	mov    %rdi,%rbx
  8041605136:	49 89 f4             	mov    %rsi,%r12
  pp = page_lookup(pml4e, va, &ptep);
  8041605139:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  804160513d:	48 b8 62 50 60 41 80 	movabs $0x8041605062,%rax
  8041605144:	00 00 00 
  8041605147:	ff d0                	callq  *%rax
  if (pp) {
  8041605149:	48 85 c0             	test   %rax,%rax
  804160514c:	74 2c                	je     804160517a <page_remove+0x52>
    page_decref(pp);
  804160514e:	48 89 c7             	mov    %rax,%rdi
  8041605151:	48 b8 dd 4b 60 41 80 	movabs $0x8041604bdd,%rax
  8041605158:	00 00 00 
  804160515b:	ff d0                	callq  *%rax
    *ptep = 0;
  804160515d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8041605161:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    tlb_invalidate(pml4e, va);
  8041605168:	4c 89 e6             	mov    %r12,%rsi
  804160516b:	48 89 df             	mov    %rbx,%rdi
  804160516e:	48 b8 0c 51 60 41 80 	movabs $0x804160510c,%rax
  8041605175:	00 00 00 
  8041605178:	ff d0                	callq  *%rax
}
  804160517a:	48 83 c4 10          	add    $0x10,%rsp
  804160517e:	5b                   	pop    %rbx
  804160517f:	41 5c                	pop    %r12
  8041605181:	5d                   	pop    %rbp
  8041605182:	c3                   	retq   

0000008041605183 <page_insert>:
page_insert(pml4e_t *pml4e, struct PageInfo *pp, void *va, int perm) {
  8041605183:	55                   	push   %rbp
  8041605184:	48 89 e5             	mov    %rsp,%rbp
  8041605187:	41 57                	push   %r15
  8041605189:	41 56                	push   %r14
  804160518b:	41 55                	push   %r13
  804160518d:	41 54                	push   %r12
  804160518f:	53                   	push   %rbx
  8041605190:	48 83 ec 08          	sub    $0x8,%rsp
  8041605194:	49 89 fe             	mov    %rdi,%r14
  8041605197:	49 89 f4             	mov    %rsi,%r12
  804160519a:	49 89 d7             	mov    %rdx,%r15
  804160519d:	41 89 cd             	mov    %ecx,%r13d
  ptep = pml4e_walk(pml4e, va, 1);
  80416051a0:	ba 01 00 00 00       	mov    $0x1,%edx
  80416051a5:	4c 89 fe             	mov    %r15,%rsi
  80416051a8:	48 b8 99 4e 60 41 80 	movabs $0x8041604e99,%rax
  80416051af:	00 00 00 
  80416051b2:	ff d0                	callq  *%rax
  if (ptep == 0) {
  80416051b4:	48 85 c0             	test   %rax,%rax
  80416051b7:	0f 84 f0 00 00 00    	je     80416052ad <page_insert+0x12a>
  80416051bd:	48 89 c3             	mov    %rax,%rbx
  if (*ptep & PTE_P) {
  80416051c0:	48 8b 08             	mov    (%rax),%rcx
  80416051c3:	f6 c1 01             	test   $0x1,%cl
  80416051c6:	0f 84 a1 00 00 00    	je     804160526d <page_insert+0xea>
    if (PTE_ADDR(*ptep) == page2pa(pp)) {
  80416051cc:	48 89 ca             	mov    %rcx,%rdx
  80416051cf:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  80416051d6:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  80416051dd:	00 00 00 
  80416051e0:	4c 89 e6             	mov    %r12,%rsi
  80416051e3:	48 2b 30             	sub    (%rax),%rsi
  80416051e6:	48 89 f0             	mov    %rsi,%rax
  80416051e9:	48 c1 f8 04          	sar    $0x4,%rax
  80416051ed:	48 c1 e0 0c          	shl    $0xc,%rax
  80416051f1:	48 39 c2             	cmp    %rax,%rdx
  80416051f4:	75 1d                	jne    8041605213 <page_insert+0x90>
      *ptep = (*ptep & 0xfffff000) | perm | PTE_P;
  80416051f6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  80416051fc:	4d 63 ed             	movslq %r13d,%r13
  80416051ff:	4c 09 e9             	or     %r13,%rcx
  8041605202:	48 83 c9 01          	or     $0x1,%rcx
  8041605206:	48 89 0b             	mov    %rcx,(%rbx)
  return 0;
  8041605209:	b8 00 00 00 00       	mov    $0x0,%eax
  804160520e:	e9 8b 00 00 00       	jmpq   804160529e <page_insert+0x11b>
      page_remove(pml4e, va);
  8041605213:	4c 89 fe             	mov    %r15,%rsi
  8041605216:	4c 89 f7             	mov    %r14,%rdi
  8041605219:	48 b8 28 51 60 41 80 	movabs $0x8041605128,%rax
  8041605220:	00 00 00 
  8041605223:	ff d0                	callq  *%rax
  8041605225:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  804160522c:	00 00 00 
  804160522f:	4c 89 e7             	mov    %r12,%rdi
  8041605232:	48 2b 38             	sub    (%rax),%rdi
  8041605235:	48 89 f8             	mov    %rdi,%rax
  8041605238:	48 c1 f8 04          	sar    $0x4,%rax
  804160523c:	48 c1 e0 0c          	shl    $0xc,%rax
      *ptep = page2pa(pp) | perm | PTE_P;
  8041605240:	4d 63 ed             	movslq %r13d,%r13
  8041605243:	49 09 c5             	or     %rax,%r13
  8041605246:	49 83 cd 01          	or     $0x1,%r13
  804160524a:	4c 89 2b             	mov    %r13,(%rbx)
      pp->pp_ref++;
  804160524d:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
      tlb_invalidate(pml4e, va);
  8041605254:	4c 89 fe             	mov    %r15,%rsi
  8041605257:	4c 89 f7             	mov    %r14,%rdi
  804160525a:	48 b8 0c 51 60 41 80 	movabs $0x804160510c,%rax
  8041605261:	00 00 00 
  8041605264:	ff d0                	callq  *%rax
  return 0;
  8041605266:	b8 00 00 00 00       	mov    $0x0,%eax
  804160526b:	eb 31                	jmp    804160529e <page_insert+0x11b>
  804160526d:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041605274:	00 00 00 
  8041605277:	4c 89 e1             	mov    %r12,%rcx
  804160527a:	48 2b 08             	sub    (%rax),%rcx
  804160527d:	48 c1 f9 04          	sar    $0x4,%rcx
  8041605281:	48 c1 e1 0c          	shl    $0xc,%rcx
    *ptep = page2pa(pp) | perm | PTE_P;
  8041605285:	4d 63 ed             	movslq %r13d,%r13
  8041605288:	4c 09 e9             	or     %r13,%rcx
  804160528b:	48 83 c9 01          	or     $0x1,%rcx
  804160528f:	48 89 0b             	mov    %rcx,(%rbx)
    pp->pp_ref++;
  8041605292:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
  return 0;
  8041605299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160529e:	48 83 c4 08          	add    $0x8,%rsp
  80416052a2:	5b                   	pop    %rbx
  80416052a3:	41 5c                	pop    %r12
  80416052a5:	41 5d                	pop    %r13
  80416052a7:	41 5e                	pop    %r14
  80416052a9:	41 5f                	pop    %r15
  80416052ab:	5d                   	pop    %rbp
  80416052ac:	c3                   	retq   
    return -E_NO_MEM;
  80416052ad:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  80416052b2:	eb ea                	jmp    804160529e <page_insert+0x11b>

00000080416052b4 <mem_init>:
mem_init(void) {
  80416052b4:	55                   	push   %rbp
  80416052b5:	48 89 e5             	mov    %rsp,%rbp
  80416052b8:	41 57                	push   %r15
  80416052ba:	41 56                	push   %r14
  80416052bc:	41 55                	push   %r13
  80416052be:	41 54                	push   %r12
  80416052c0:	53                   	push   %rbx
  80416052c1:	48 83 ec 38          	sub    $0x38,%rsp
  if (uefi_lp && uefi_lp->MemoryMap) {
  80416052c5:	48 a1 00 f0 61 41 80 	movabs 0x804161f000,%rax
  80416052cc:	00 00 00 
  80416052cf:	48 85 c0             	test   %rax,%rax
  80416052d2:	74 0d                	je     80416052e1 <mem_init+0x2d>
  80416052d4:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80416052d8:	48 85 ff             	test   %rdi,%rdi
  80416052db:	0f 85 c4 11 00 00    	jne    80416064a5 <mem_init+0x11f1>
    npages_basemem = (mc146818_read16(NVRAM_BASELO) * 1024) / PGSIZE;
  80416052e1:	bf 15 00 00 00       	mov    $0x15,%edi
  80416052e6:	49 bc 69 8d 60 41 80 	movabs $0x8041608d69,%r12
  80416052ed:	00 00 00 
  80416052f0:	41 ff d4             	callq  *%r12
  80416052f3:	c1 e0 0a             	shl    $0xa,%eax
  80416052f6:	c1 e8 0c             	shr    $0xc,%eax
  80416052f9:	48 ba f0 43 70 41 80 	movabs $0x80417043f0,%rdx
  8041605300:	00 00 00 
  8041605303:	89 c0                	mov    %eax,%eax
  8041605305:	48 89 02             	mov    %rax,(%rdx)
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  8041605308:	bf 17 00 00 00       	mov    $0x17,%edi
  804160530d:	41 ff d4             	callq  *%r12
  8041605310:	89 c3                	mov    %eax,%ebx
    pextmem        = ((size_t)mc146818_read16(NVRAM_PEXTLO) * 1024 * 64);
  8041605312:	bf 34 00 00 00       	mov    $0x34,%edi
  8041605317:	41 ff d4             	callq  *%r12
  804160531a:	89 c0                	mov    %eax,%eax
    if (pextmem)
  804160531c:	48 c1 e0 10          	shl    $0x10,%rax
  8041605320:	0f 84 f9 11 00 00    	je     804160651f <mem_init+0x126b>
      npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  8041605326:	48 05 00 00 f0 00    	add    $0xf00000,%rax
  804160532c:	48 c1 e8 0c          	shr    $0xc,%rax
  8041605330:	48 89 c7             	mov    %rax,%rdi
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  8041605333:	48 8d b7 00 01 00 00 	lea    0x100(%rdi),%rsi
  804160533a:	48 89 f0             	mov    %rsi,%rax
  804160533d:	48 a3 30 59 70 41 80 	movabs %rax,0x8041705930
  8041605344:	00 00 00 
          (unsigned long)(npages_extmem * PGSIZE / 1024));
  8041605347:	48 89 f8             	mov    %rdi,%rax
  804160534a:	48 c1 e0 0c          	shl    $0xc,%rax
  804160534e:	48 c1 e8 0a          	shr    $0xa,%rax
  8041605352:	48 89 c1             	mov    %rax,%rcx
          (unsigned long)(npages_basemem * PGSIZE / 1024),
  8041605355:	48 b8 f0 43 70 41 80 	movabs $0x80417043f0,%rax
  804160535c:	00 00 00 
  804160535f:	48 8b 10             	mov    (%rax),%rdx
  8041605362:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605366:	48 c1 ea 0a          	shr    $0xa,%rdx
          (unsigned long)(npages * PGSIZE / 1024 / 1024),
  804160536a:	48 c1 e6 0c          	shl    $0xc,%rsi
  804160536e:	48 c1 ee 14          	shr    $0x14,%rsi
  cprintf("Physical memory: %luM available, base = %luK, extended = %luK\n",
  8041605372:	48 bf c0 c8 60 41 80 	movabs $0x804160c8c0,%rdi
  8041605379:	00 00 00 
  804160537c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605381:	49 b8 6e 8f 60 41 80 	movabs $0x8041608f6e,%r8
  8041605388:	00 00 00 
  804160538b:	41 ff d0             	callq  *%r8
  pml4e = boot_alloc(PGSIZE);
  804160538e:	bf 00 10 00 00       	mov    $0x1000,%edi
  8041605393:	48 b8 b7 42 60 41 80 	movabs $0x80416042b7,%rax
  804160539a:	00 00 00 
  804160539d:	ff d0                	callq  *%rax
  804160539f:	48 89 c3             	mov    %rax,%rbx
  memset(pml4e, 0, PGSIZE);
  80416053a2:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416053a7:	be 00 00 00 00       	mov    $0x0,%esi
  80416053ac:	48 89 c7             	mov    %rax,%rdi
  80416053af:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  80416053b6:	00 00 00 
  80416053b9:	ff d0                	callq  *%rax
  kern_pml4e = pml4e;
  80416053bb:	48 89 d8             	mov    %rbx,%rax
  80416053be:	48 a3 20 59 70 41 80 	movabs %rax,0x8041705920
  80416053c5:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  80416053c8:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  80416053cf:	00 00 00 
  80416053d2:	48 39 c3             	cmp    %rax,%rbx
  80416053d5:	0f 86 67 11 00 00    	jbe    8041606542 <mem_init+0x128e>
  return (physaddr_t)kva - KERNBASE;
  80416053db:	48 b8 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rax
  80416053e2:	ff ff ff 
  80416053e5:	48 01 d8             	add    %rbx,%rax
  kern_cr3   = PADDR(pml4e);
  80416053e8:	48 a3 28 59 70 41 80 	movabs %rax,0x8041705928
  80416053ef:	00 00 00 
  kern_pml4e[PML4(UVPT)] = kern_cr3 | PTE_P | PTE_U;
  80416053f2:	48 83 c8 05          	or     $0x5,%rax
  80416053f6:	48 89 43 10          	mov    %rax,0x10(%rbx)
  pages = (struct PageInfo *)boot_alloc(sizeof(*pages) * npages);
  80416053fa:	48 bb 30 59 70 41 80 	movabs $0x8041705930,%rbx
  8041605401:	00 00 00 
  8041605404:	8b 3b                	mov    (%rbx),%edi
  8041605406:	c1 e7 04             	shl    $0x4,%edi
  8041605409:	48 b8 b7 42 60 41 80 	movabs $0x80416042b7,%rax
  8041605410:	00 00 00 
  8041605413:	ff d0                	callq  *%rax
  8041605415:	48 a3 38 59 70 41 80 	movabs %rax,0x8041705938
  804160541c:	00 00 00 
  memset(pages, 0, sizeof(*pages) * npages);
  804160541f:	48 8b 13             	mov    (%rbx),%rdx
  8041605422:	48 c1 e2 04          	shl    $0x4,%rdx
  8041605426:	be 00 00 00 00       	mov    $0x0,%esi
  804160542b:	48 89 c7             	mov    %rax,%rdi
  804160542e:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041605435:	00 00 00 
  8041605438:	ff d0                	callq  *%rax
  page_init();
  804160543a:	48 b8 64 48 60 41 80 	movabs $0x8041604864,%rax
  8041605441:	00 00 00 
  8041605444:	ff d0                	callq  *%rax
  check_page_free_list(1);
  8041605446:	bf 01 00 00 00       	mov    $0x1,%edi
  804160544b:	48 b8 93 43 60 41 80 	movabs $0x8041604393,%rax
  8041605452:	00 00 00 
  8041605455:	ff d0                	callq  *%rax
  void *va;
  int i;
  pp0 = pp1 = pp2 = pp3 = pp4 = pp5 = 0;

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041605457:	48 a1 20 59 70 41 80 	movabs 0x8041705920,%rax
  804160545e:	00 00 00 
  8041605461:	48 8b 08             	mov    (%rax),%rcx
  8041605464:	48 89 4d a8          	mov    %rcx,-0x58(%rbp)
  kern_pml4e[0] = 0;
  8041605468:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  assert(pp0 = page_alloc(0));
  804160546f:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605474:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  804160547b:	00 00 00 
  804160547e:	ff d0                	callq  *%rax
  8041605480:	49 89 c6             	mov    %rax,%r14
  8041605483:	48 85 c0             	test   %rax,%rax
  8041605486:	0f 84 e4 10 00 00    	je     8041606570 <mem_init+0x12bc>
  assert(pp1 = page_alloc(0));
  804160548c:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605491:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041605498:	00 00 00 
  804160549b:	ff d0                	callq  *%rax
  804160549d:	49 89 c4             	mov    %rax,%r12
  80416054a0:	48 85 c0             	test   %rax,%rax
  80416054a3:	0f 84 fc 10 00 00    	je     80416065a5 <mem_init+0x12f1>
  assert(pp2 = page_alloc(0));
  80416054a9:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054ae:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  80416054b5:	00 00 00 
  80416054b8:	ff d0                	callq  *%rax
  80416054ba:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416054be:	48 85 c0             	test   %rax,%rax
  80416054c1:	0f 84 13 11 00 00    	je     80416065da <mem_init+0x1326>
  assert(pp3 = page_alloc(0));
  80416054c7:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054cc:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  80416054d3:	00 00 00 
  80416054d6:	ff d0                	callq  *%rax
  80416054d8:	49 89 c5             	mov    %rax,%r13
  80416054db:	48 85 c0             	test   %rax,%rax
  80416054de:	0f 84 26 11 00 00    	je     804160660a <mem_init+0x1356>
  assert(pp4 = page_alloc(0));
  80416054e4:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054e9:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  80416054f0:	00 00 00 
  80416054f3:	ff d0                	callq  *%rax
  80416054f5:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  80416054f9:	48 85 c0             	test   %rax,%rax
  80416054fc:	0f 84 3d 11 00 00    	je     804160663f <mem_init+0x138b>
  assert(pp5 = page_alloc(0));
  8041605502:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605507:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  804160550e:	00 00 00 
  8041605511:	ff d0                	callq  *%rax
  8041605513:	48 85 c0             	test   %rax,%rax
  8041605516:	0f 84 53 11 00 00    	je     804160666f <mem_init+0x13bb>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  804160551c:	4d 39 e6             	cmp    %r12,%r14
  804160551f:	0f 84 7a 11 00 00    	je     804160669f <mem_init+0x13eb>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041605525:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041605529:	49 39 cc             	cmp    %rcx,%r12
  804160552c:	0f 84 a2 11 00 00    	je     80416066d4 <mem_init+0x1420>
  8041605532:	49 39 ce             	cmp    %rcx,%r14
  8041605535:	0f 84 99 11 00 00    	je     80416066d4 <mem_init+0x1420>
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  804160553b:	4c 39 6d b8          	cmp    %r13,-0x48(%rbp)
  804160553f:	0f 84 c4 11 00 00    	je     8041606709 <mem_init+0x1455>
  8041605545:	4d 39 ec             	cmp    %r13,%r12
  8041605548:	0f 84 bb 11 00 00    	je     8041606709 <mem_init+0x1455>
  804160554e:	4d 39 ee             	cmp    %r13,%r14
  8041605551:	0f 84 b2 11 00 00    	je     8041606709 <mem_init+0x1455>
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  8041605557:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  804160555b:	49 39 fd             	cmp    %rdi,%r13
  804160555e:	0f 84 da 11 00 00    	je     804160673e <mem_init+0x148a>
  8041605564:	48 39 7d b8          	cmp    %rdi,-0x48(%rbp)
  8041605568:	0f 94 c1             	sete   %cl
  804160556b:	49 39 fc             	cmp    %rdi,%r12
  804160556e:	0f 94 c2             	sete   %dl
  8041605571:	08 d1                	or     %dl,%cl
  8041605573:	0f 85 c5 11 00 00    	jne    804160673e <mem_init+0x148a>
  8041605579:	49 39 fe             	cmp    %rdi,%r14
  804160557c:	0f 84 bc 11 00 00    	je     804160673e <mem_init+0x148a>
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  8041605582:	48 39 45 b0          	cmp    %rax,-0x50(%rbp)
  8041605586:	0f 84 e7 11 00 00    	je     8041606773 <mem_init+0x14bf>
  804160558c:	49 39 c5             	cmp    %rax,%r13
  804160558f:	0f 84 de 11 00 00    	je     8041606773 <mem_init+0x14bf>
  8041605595:	48 39 45 b8          	cmp    %rax,-0x48(%rbp)
  8041605599:	0f 84 d4 11 00 00    	je     8041606773 <mem_init+0x14bf>
  804160559f:	49 39 c4             	cmp    %rax,%r12
  80416055a2:	0f 84 cb 11 00 00    	je     8041606773 <mem_init+0x14bf>
  80416055a8:	49 39 c6             	cmp    %rax,%r14
  80416055ab:	0f 84 c2 11 00 00    	je     8041606773 <mem_init+0x14bf>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
  80416055b1:	48 a1 e8 43 70 41 80 	movabs 0x80417043e8,%rax
  80416055b8:	00 00 00 
  80416055bb:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  assert(fl != NULL);
  80416055bf:	48 85 c0             	test   %rax,%rax
  80416055c2:	0f 84 e0 11 00 00    	je     80416067a8 <mem_init+0x14f4>
  page_free_list = NULL;
  80416055c8:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  80416055cf:	00 00 00 
  80416055d2:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // should be no free memory
  assert(!page_alloc(0));
  80416055d9:	bf 00 00 00 00       	mov    $0x0,%edi
  80416055de:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  80416055e5:	00 00 00 
  80416055e8:	ff d0                	callq  *%rax
  80416055ea:	48 85 c0             	test   %rax,%rax
  80416055ed:	0f 85 e5 11 00 00    	jne    80416067d8 <mem_init+0x1524>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  80416055f3:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  80416055f7:	be 00 00 00 00       	mov    $0x0,%esi
  80416055fc:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605603:	00 00 00 
  8041605606:	48 8b 38             	mov    (%rax),%rdi
  8041605609:	48 b8 62 50 60 41 80 	movabs $0x8041605062,%rax
  8041605610:	00 00 00 
  8041605613:	ff d0                	callq  *%rax
  8041605615:	48 85 c0             	test   %rax,%rax
  8041605618:	0f 85 ef 11 00 00    	jne    804160680d <mem_init+0x1559>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  804160561e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605623:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605628:	4c 89 e6             	mov    %r12,%rsi
  804160562b:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605632:	00 00 00 
  8041605635:	48 8b 38             	mov    (%rax),%rdi
  8041605638:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  804160563f:	00 00 00 
  8041605642:	ff d0                	callq  *%rax
  8041605644:	85 c0                	test   %eax,%eax
  8041605646:	0f 89 f6 11 00 00    	jns    8041606842 <mem_init+0x158e>

  cprintf("pp0 ref count before free = %d\n", pp0->pp_ref);
  804160564c:	41 0f b7 76 08       	movzwl 0x8(%r14),%esi
  8041605651:	48 bf 48 ca 60 41 80 	movabs $0x804160ca48,%rdi
  8041605658:	00 00 00 
  804160565b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605660:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  8041605667:	00 00 00 
  804160566a:	ff d3                	callq  *%rbx
  cprintf("pp1 ref count before free = %d\n", pp1->pp_ref);
  804160566c:	41 0f b7 74 24 08    	movzwl 0x8(%r12),%esi
  8041605672:	48 bf 68 ca 60 41 80 	movabs $0x804160ca68,%rdi
  8041605679:	00 00 00 
  804160567c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605681:	ff d3                	callq  *%rbx
  cprintf("pp2 ref count before free = %d\n", pp2->pp_ref);
  8041605683:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605687:	0f b7 70 08          	movzwl 0x8(%rax),%esi
  804160568b:	48 bf 88 ca 60 41 80 	movabs $0x804160ca88,%rdi
  8041605692:	00 00 00 
  8041605695:	b8 00 00 00 00       	mov    $0x0,%eax
  804160569a:	ff d3                	callq  *%rbx

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
  804160569c:	4c 89 f7             	mov    %r14,%rdi
  804160569f:	48 b8 44 4b 60 41 80 	movabs $0x8041604b44,%rax
  80416056a6:	00 00 00 
  80416056a9:	ff d0                	callq  *%rax
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  80416056ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416056b0:	ba 00 00 00 00       	mov    $0x0,%edx
  80416056b5:	4c 89 e6             	mov    %r12,%rsi
  80416056b8:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  80416056bf:	00 00 00 
  80416056c2:	48 8b 38             	mov    (%rax),%rdi
  80416056c5:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  80416056cc:	00 00 00 
  80416056cf:	ff d0                	callq  *%rax
  80416056d1:	85 c0                	test   %eax,%eax
  80416056d3:	0f 89 9e 11 00 00    	jns    8041606877 <mem_init+0x15c3>
  page_free(pp2);
  80416056d9:	4c 8b 7d b8          	mov    -0x48(%rbp),%r15
  80416056dd:	4c 89 ff             	mov    %r15,%rdi
  80416056e0:	48 bb 44 4b 60 41 80 	movabs $0x8041604b44,%rbx
  80416056e7:	00 00 00 
  80416056ea:	ff d3                	callq  *%rbx
  page_free(pp3);
  80416056ec:	4c 89 ef             	mov    %r13,%rdi
  80416056ef:	ff d3                	callq  *%rbx

  cprintf("pp0 ref count = %d\n", pp0->pp_ref);
  80416056f1:	41 0f b7 76 08       	movzwl 0x8(%r14),%esi
  80416056f6:	48 bf 26 d2 60 41 80 	movabs $0x804160d226,%rdi
  80416056fd:	00 00 00 
  8041605700:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605705:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  804160570c:	00 00 00 
  804160570f:	ff d3                	callq  *%rbx
  cprintf("pp1 ref count = %d\n", pp1->pp_ref);
  8041605711:	41 0f b7 74 24 08    	movzwl 0x8(%r12),%esi
  8041605717:	48 bf 3a d2 60 41 80 	movabs $0x804160d23a,%rdi
  804160571e:	00 00 00 
  8041605721:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605726:	ff d3                	callq  *%rbx
  cprintf("pp2 ref count = %d\n", pp2->pp_ref);
  8041605728:	41 0f b7 77 08       	movzwl 0x8(%r15),%esi
  804160572d:	48 bf 4e d2 60 41 80 	movabs $0x804160d24e,%rdi
  8041605734:	00 00 00 
  8041605737:	b8 00 00 00 00       	mov    $0x0,%eax
  804160573c:	ff d3                	callq  *%rbx

  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  804160573e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605743:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605748:	4c 89 e6             	mov    %r12,%rsi
  804160574b:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605752:	00 00 00 
  8041605755:	48 8b 38             	mov    (%rax),%rdi
  8041605758:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  804160575f:	00 00 00 
  8041605762:	ff d0                	callq  *%rax
  8041605764:	85 c0                	test   %eax,%eax
  8041605766:	0f 85 40 11 00 00    	jne    80416068ac <mem_init+0x15f8>
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  804160576c:	48 a1 20 59 70 41 80 	movabs 0x8041705920,%rax
  8041605773:	00 00 00 
  8041605776:	48 8b 10             	mov    (%rax),%rdx
  8041605779:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041605780:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041605787:	00 00 00 
  804160578a:	48 8b 08             	mov    (%rax),%rcx
  804160578d:	4c 89 f0             	mov    %r14,%rax
  8041605790:	48 29 c8             	sub    %rcx,%rax
  8041605793:	48 c1 f8 04          	sar    $0x4,%rax
  8041605797:	48 c1 e0 0c          	shl    $0xc,%rax
  804160579b:	48 39 c2             	cmp    %rax,%rdx
  804160579e:	74 2b                	je     80416057cb <mem_init+0x517>
  80416057a0:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416057a4:	48 29 c8             	sub    %rcx,%rax
  80416057a7:	48 c1 f8 04          	sar    $0x4,%rax
  80416057ab:	48 c1 e0 0c          	shl    $0xc,%rax
  80416057af:	48 39 c2             	cmp    %rax,%rdx
  80416057b2:	74 17                	je     80416057cb <mem_init+0x517>
  80416057b4:	4c 89 e8             	mov    %r13,%rax
  80416057b7:	48 29 c8             	sub    %rcx,%rax
  80416057ba:	48 c1 f8 04          	sar    $0x4,%rax
  80416057be:	48 c1 e0 0c          	shl    $0xc,%rax
  80416057c2:	48 39 c2             	cmp    %rax,%rdx
  80416057c5:	0f 85 16 11 00 00    	jne    80416068e1 <mem_init+0x162d>
  80416057cb:	4c 89 e6             	mov    %r12,%rsi
  80416057ce:	48 29 ce             	sub    %rcx,%rsi
  80416057d1:	48 c1 fe 04          	sar    $0x4,%rsi
  80416057d5:	48 c1 e6 0c          	shl    $0xc,%rsi

  cprintf("Physical address pp1: %ld\n", page2pa(pp1));
  80416057d9:	48 bf 62 d2 60 41 80 	movabs $0x804160d262,%rdi
  80416057e0:	00 00 00 
  80416057e3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416057e8:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416057ef:	00 00 00 
  80416057f2:	ff d2                	callq  *%rdx

  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  80416057f4:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  80416057fb:	00 00 00 
  80416057fe:	48 8b 18             	mov    (%rax),%rbx
  8041605801:	be 00 00 00 00       	mov    $0x0,%esi
  8041605806:	48 89 df             	mov    %rbx,%rdi
  8041605809:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605810:	00 00 00 
  8041605813:	ff d0                	callq  *%rax
  8041605815:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  804160581c:	00 00 00 
  804160581f:	4c 89 e1             	mov    %r12,%rcx
  8041605822:	48 2b 0a             	sub    (%rdx),%rcx
  8041605825:	48 89 ca             	mov    %rcx,%rdx
  8041605828:	48 c1 fa 04          	sar    $0x4,%rdx
  804160582c:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605830:	48 39 d0             	cmp    %rdx,%rax
  8041605833:	0f 85 dd 10 00 00    	jne    8041606916 <mem_init+0x1662>
  assert(pp1->pp_ref == 1);
  8041605839:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041605840:	0f 85 05 11 00 00    	jne    804160694b <mem_init+0x1697>

  //should be able to map pp3 at PGSIZE because pp0 is already allocated for page table
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041605846:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160584b:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605850:	4c 89 ee             	mov    %r13,%rsi
  8041605853:	48 89 df             	mov    %rbx,%rdi
  8041605856:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  804160585d:	00 00 00 
  8041605860:	ff d0                	callq  *%rax
  8041605862:	85 c0                	test   %eax,%eax
  8041605864:	0f 85 16 11 00 00    	jne    8041606980 <mem_init+0x16cc>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  804160586a:	be 00 10 00 00       	mov    $0x1000,%esi
  804160586f:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605876:	00 00 00 
  8041605879:	48 8b 38             	mov    (%rax),%rdi
  804160587c:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605883:	00 00 00 
  8041605886:	ff d0                	callq  *%rax
  8041605888:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  804160588f:	00 00 00 
  8041605892:	4c 89 e9             	mov    %r13,%rcx
  8041605895:	48 2b 0a             	sub    (%rdx),%rcx
  8041605898:	48 89 ca             	mov    %rcx,%rdx
  804160589b:	48 c1 fa 04          	sar    $0x4,%rdx
  804160589f:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416058a3:	48 39 d0             	cmp    %rdx,%rax
  80416058a6:	0f 85 09 11 00 00    	jne    80416069b5 <mem_init+0x1701>
  assert(pp3->pp_ref == 2);
  80416058ac:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  80416058b2:	0f 85 32 11 00 00    	jne    80416069ea <mem_init+0x1736>

  // should be no free memory
  assert(!page_alloc(0));
  80416058b8:	bf 00 00 00 00       	mov    $0x0,%edi
  80416058bd:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  80416058c4:	00 00 00 
  80416058c7:	ff d0                	callq  *%rax
  80416058c9:	48 85 c0             	test   %rax,%rax
  80416058cc:	0f 85 4d 11 00 00    	jne    8041606a1f <mem_init+0x176b>

  // should be able to map pp3 at PGSIZE because it's already there
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  80416058d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416058d7:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416058dc:	4c 89 ee             	mov    %r13,%rsi
  80416058df:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  80416058e6:	00 00 00 
  80416058e9:	48 8b 38             	mov    (%rax),%rdi
  80416058ec:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  80416058f3:	00 00 00 
  80416058f6:	ff d0                	callq  *%rax
  80416058f8:	85 c0                	test   %eax,%eax
  80416058fa:	0f 85 54 11 00 00    	jne    8041606a54 <mem_init+0x17a0>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041605900:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605905:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  804160590c:	00 00 00 
  804160590f:	48 8b 38             	mov    (%rax),%rdi
  8041605912:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605919:	00 00 00 
  804160591c:	ff d0                	callq  *%rax
  804160591e:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  8041605925:	00 00 00 
  8041605928:	4c 89 e9             	mov    %r13,%rcx
  804160592b:	48 2b 0a             	sub    (%rdx),%rcx
  804160592e:	48 89 ca             	mov    %rcx,%rdx
  8041605931:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605935:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605939:	48 39 d0             	cmp    %rdx,%rax
  804160593c:	0f 85 47 11 00 00    	jne    8041606a89 <mem_init+0x17d5>
  assert(pp3->pp_ref == 2);
  8041605942:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  8041605948:	0f 85 70 11 00 00    	jne    8041606abe <mem_init+0x180a>

  // pp3 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
  804160594e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605953:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  804160595a:	00 00 00 
  804160595d:	ff d0                	callq  *%rax
  804160595f:	48 85 c0             	test   %rax,%rax
  8041605962:	0f 85 8b 11 00 00    	jne    8041606af3 <mem_init+0x183f>
  // check that pgdir_walk returns a pointer to the pte
  pdpe = KADDR(PTE_ADDR(kern_pml4e[PML4(PGSIZE)]));
  8041605968:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  804160596f:	00 00 00 
  8041605972:	48 8b 38             	mov    (%rax),%rdi
  8041605975:	48 8b 0f             	mov    (%rdi),%rcx
  8041605978:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  804160597f:	48 a1 30 59 70 41 80 	movabs 0x8041705930,%rax
  8041605986:	00 00 00 
  8041605989:	48 89 ca             	mov    %rcx,%rdx
  804160598c:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605990:	48 39 c2             	cmp    %rax,%rdx
  8041605993:	0f 83 8f 11 00 00    	jae    8041606b28 <mem_init+0x1874>
  pde  = KADDR(PTE_ADDR(pdpe[PDPE(PGSIZE)]));
  8041605999:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  80416059a0:	00 00 00 
  80416059a3:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  80416059a7:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416059ae:	48 89 ca             	mov    %rcx,%rdx
  80416059b1:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416059b5:	48 39 d0             	cmp    %rdx,%rax
  80416059b8:	0f 86 95 11 00 00    	jbe    8041606b53 <mem_init+0x189f>
  ptep = KADDR(PTE_ADDR(pde[PDX(PGSIZE)]));
  80416059be:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  80416059c5:	00 00 00 
  80416059c8:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  80416059cc:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416059d3:	48 89 ca             	mov    %rcx,%rdx
  80416059d6:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416059da:	48 39 d0             	cmp    %rdx,%rax
  80416059dd:	0f 86 9b 11 00 00    	jbe    8041606b7e <mem_init+0x18ca>
  return (void *)(pa + KERNBASE);
  80416059e3:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416059ea:	00 00 00 
  80416059ed:	48 01 c1             	add    %rax,%rcx
  80416059f0:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  80416059f4:	ba 00 00 00 00       	mov    $0x0,%edx
  80416059f9:	be 00 10 00 00       	mov    $0x1000,%esi
  80416059fe:	48 b8 99 4e 60 41 80 	movabs $0x8041604e99,%rax
  8041605a05:	00 00 00 
  8041605a08:	ff d0                	callq  *%rax
  8041605a0a:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041605a0e:	48 8d 57 08          	lea    0x8(%rdi),%rdx
  8041605a12:	48 39 d0             	cmp    %rdx,%rax
  8041605a15:	0f 85 8e 11 00 00    	jne    8041606ba9 <mem_init+0x18f5>

  // should be able to change permissions too.
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  8041605a1b:	b9 04 00 00 00       	mov    $0x4,%ecx
  8041605a20:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605a25:	4c 89 ee             	mov    %r13,%rsi
  8041605a28:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605a2f:	00 00 00 
  8041605a32:	48 8b 38             	mov    (%rax),%rdi
  8041605a35:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  8041605a3c:	00 00 00 
  8041605a3f:	ff d0                	callq  *%rax
  8041605a41:	85 c0                	test   %eax,%eax
  8041605a43:	0f 85 95 11 00 00    	jne    8041606bde <mem_init+0x192a>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041605a49:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605a50:	00 00 00 
  8041605a53:	48 8b 18             	mov    (%rax),%rbx
  8041605a56:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605a5b:	48 89 df             	mov    %rbx,%rdi
  8041605a5e:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605a65:	00 00 00 
  8041605a68:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041605a6a:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  8041605a71:	00 00 00 
  8041605a74:	4c 89 ee             	mov    %r13,%rsi
  8041605a77:	48 2b 32             	sub    (%rdx),%rsi
  8041605a7a:	48 89 f2             	mov    %rsi,%rdx
  8041605a7d:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605a81:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605a85:	48 39 d0             	cmp    %rdx,%rax
  8041605a88:	0f 85 85 11 00 00    	jne    8041606c13 <mem_init+0x195f>
  assert(pp3->pp_ref == 2);
  8041605a8e:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  8041605a94:	0f 85 ae 11 00 00    	jne    8041606c48 <mem_init+0x1994>
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041605a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605a9f:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605aa4:	48 89 df             	mov    %rbx,%rdi
  8041605aa7:	48 b8 99 4e 60 41 80 	movabs $0x8041604e99,%rax
  8041605aae:	00 00 00 
  8041605ab1:	ff d0                	callq  *%rax
  8041605ab3:	f6 00 04             	testb  $0x4,(%rax)
  8041605ab6:	0f 84 c1 11 00 00    	je     8041606c7d <mem_init+0x19c9>
  assert(kern_pml4e[0] & PTE_U);
  8041605abc:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605ac3:	00 00 00 
  8041605ac6:	48 8b 38             	mov    (%rax),%rdi
  8041605ac9:	f6 07 04             	testb  $0x4,(%rdi)
  8041605acc:	0f 84 e0 11 00 00    	je     8041606cb2 <mem_init+0x19fe>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041605ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605ad7:	ba 00 00 20 00       	mov    $0x200000,%edx
  8041605adc:	4c 89 f6             	mov    %r14,%rsi
  8041605adf:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  8041605ae6:	00 00 00 
  8041605ae9:	ff d0                	callq  *%rax
  8041605aeb:	85 c0                	test   %eax,%eax
  8041605aed:	0f 89 f4 11 00 00    	jns    8041606ce7 <mem_init+0x1a33>

  // insert pp1 at PGSIZE (replacing pp3)
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605af3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605af8:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605afd:	4c 89 e6             	mov    %r12,%rsi
  8041605b00:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605b07:	00 00 00 
  8041605b0a:	48 8b 38             	mov    (%rax),%rdi
  8041605b0d:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  8041605b14:	00 00 00 
  8041605b17:	ff d0                	callq  *%rax
  8041605b19:	85 c0                	test   %eax,%eax
  8041605b1b:	0f 85 fb 11 00 00    	jne    8041606d1c <mem_init+0x1a68>
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041605b21:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605b26:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b2b:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605b32:	00 00 00 
  8041605b35:	48 8b 38             	mov    (%rax),%rdi
  8041605b38:	48 b8 99 4e 60 41 80 	movabs $0x8041604e99,%rax
  8041605b3f:	00 00 00 
  8041605b42:	ff d0                	callq  *%rax
  8041605b44:	f6 00 04             	testb  $0x4,(%rax)
  8041605b47:	0f 85 04 12 00 00    	jne    8041606d51 <mem_init+0x1a9d>

  // should have pp1 at both 0 and PGSIZE
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041605b4d:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605b54:	00 00 00 
  8041605b57:	48 8b 18             	mov    (%rax),%rbx
  8041605b5a:	be 00 00 00 00       	mov    $0x0,%esi
  8041605b5f:	48 89 df             	mov    %rbx,%rdi
  8041605b62:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605b69:	00 00 00 
  8041605b6c:	ff d0                	callq  *%rax
  8041605b6e:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  8041605b75:	00 00 00 
  8041605b78:	4d 89 e7             	mov    %r12,%r15
  8041605b7b:	4c 2b 3a             	sub    (%rdx),%r15
  8041605b7e:	49 c1 ff 04          	sar    $0x4,%r15
  8041605b82:	49 c1 e7 0c          	shl    $0xc,%r15
  8041605b86:	4c 39 f8             	cmp    %r15,%rax
  8041605b89:	0f 85 f7 11 00 00    	jne    8041606d86 <mem_init+0x1ad2>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605b8f:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b94:	48 89 df             	mov    %rbx,%rdi
  8041605b97:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605b9e:	00 00 00 
  8041605ba1:	ff d0                	callq  *%rax
  8041605ba3:	49 39 c7             	cmp    %rax,%r15
  8041605ba6:	0f 85 0f 12 00 00    	jne    8041606dbb <mem_init+0x1b07>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
  8041605bac:	66 41 83 7c 24 08 02 	cmpw   $0x2,0x8(%r12)
  8041605bb3:	0f 85 37 12 00 00    	jne    8041606df0 <mem_init+0x1b3c>
  assert(pp3->pp_ref == 1);
  8041605bb9:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605bbf:	0f 85 60 12 00 00    	jne    8041606e25 <mem_init+0x1b71>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pml4e, 0x0);
  8041605bc5:	be 00 00 00 00       	mov    $0x0,%esi
  8041605bca:	48 89 df             	mov    %rbx,%rdi
  8041605bcd:	48 b8 28 51 60 41 80 	movabs $0x8041605128,%rax
  8041605bd4:	00 00 00 
  8041605bd7:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605bd9:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041605be0:	00 00 00 
  8041605be3:	48 8b 18             	mov    (%rax),%rbx
  8041605be6:	be 00 00 00 00       	mov    $0x0,%esi
  8041605beb:	48 89 df             	mov    %rbx,%rdi
  8041605bee:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605bf5:	00 00 00 
  8041605bf8:	ff d0                	callq  *%rax
  8041605bfa:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605bfe:	0f 85 56 12 00 00    	jne    8041606e5a <mem_init+0x1ba6>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605c04:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605c09:	48 89 df             	mov    %rbx,%rdi
  8041605c0c:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605c13:	00 00 00 
  8041605c16:	ff d0                	callq  *%rax
  8041605c18:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  8041605c1f:	00 00 00 
  8041605c22:	4c 89 e1             	mov    %r12,%rcx
  8041605c25:	48 2b 0a             	sub    (%rdx),%rcx
  8041605c28:	48 89 ca             	mov    %rcx,%rdx
  8041605c2b:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605c2f:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605c33:	48 39 d0             	cmp    %rdx,%rax
  8041605c36:	0f 85 53 12 00 00    	jne    8041606e8f <mem_init+0x1bdb>
  assert(pp1->pp_ref == 1);
  8041605c3c:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041605c43:	0f 85 7b 12 00 00    	jne    8041606ec4 <mem_init+0x1c10>
  assert(pp3->pp_ref == 1);
  8041605c49:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605c4f:	0f 85 a4 12 00 00    	jne    8041606ef9 <mem_init+0x1c45>

  // Test re-inserting pp1 at PGSIZE.
  // Thanks to Varun Agrawal for suggesting this test case.
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605c55:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605c5a:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605c5f:	4c 89 e6             	mov    %r12,%rsi
  8041605c62:	48 89 df             	mov    %rbx,%rdi
  8041605c65:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  8041605c6c:	00 00 00 
  8041605c6f:	ff d0                	callq  *%rax
  8041605c71:	89 c3                	mov    %eax,%ebx
  8041605c73:	85 c0                	test   %eax,%eax
  8041605c75:	0f 85 b3 12 00 00    	jne    8041606f2e <mem_init+0x1c7a>
  assert(pp1->pp_ref);
  8041605c7b:	66 41 83 7c 24 08 00 	cmpw   $0x0,0x8(%r12)
  8041605c82:	0f 84 db 12 00 00    	je     8041606f63 <mem_init+0x1caf>
  assert(pp1->pp_link == NULL);
  8041605c88:	49 83 3c 24 00       	cmpq   $0x0,(%r12)
  8041605c8d:	0f 85 05 13 00 00    	jne    8041606f98 <mem_init+0x1ce4>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041605c93:	49 bf 20 59 70 41 80 	movabs $0x8041705920,%r15
  8041605c9a:	00 00 00 
  8041605c9d:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605ca2:	49 8b 3f             	mov    (%r15),%rdi
  8041605ca5:	48 b8 28 51 60 41 80 	movabs $0x8041605128,%rax
  8041605cac:	00 00 00 
  8041605caf:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605cb1:	4d 8b 3f             	mov    (%r15),%r15
  8041605cb4:	be 00 00 00 00       	mov    $0x0,%esi
  8041605cb9:	4c 89 ff             	mov    %r15,%rdi
  8041605cbc:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605cc3:	00 00 00 
  8041605cc6:	ff d0                	callq  *%rax
  8041605cc8:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605ccc:	0f 85 fb 12 00 00    	jne    8041606fcd <mem_init+0x1d19>
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041605cd2:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605cd7:	4c 89 ff             	mov    %r15,%rdi
  8041605cda:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041605ce1:	00 00 00 
  8041605ce4:	ff d0                	callq  *%rax
  8041605ce6:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605cea:	0f 85 12 13 00 00    	jne    8041607002 <mem_init+0x1d4e>
  assert(pp1->pp_ref == 0);
  8041605cf0:	66 41 83 7c 24 08 00 	cmpw   $0x0,0x8(%r12)
  8041605cf7:	0f 85 3a 13 00 00    	jne    8041607037 <mem_init+0x1d83>
  assert(pp3->pp_ref == 1);
  8041605cfd:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605d03:	0f 85 63 13 00 00    	jne    804160706c <mem_init+0x1db8>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

  // forcibly take pp3 back
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041605d09:	49 8b 17             	mov    (%r15),%rdx
  8041605d0c:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  8041605d13:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041605d1a:	00 00 00 
  8041605d1d:	48 8b 08             	mov    (%rax),%rcx
  8041605d20:	4c 89 f0             	mov    %r14,%rax
  8041605d23:	48 29 c8             	sub    %rcx,%rax
  8041605d26:	48 c1 f8 04          	sar    $0x4,%rax
  8041605d2a:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605d2e:	48 39 c2             	cmp    %rax,%rdx
  8041605d31:	74 2b                	je     8041605d5e <mem_init+0xaaa>
  8041605d33:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605d37:	48 29 c8             	sub    %rcx,%rax
  8041605d3a:	48 c1 f8 04          	sar    $0x4,%rax
  8041605d3e:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605d42:	48 39 c2             	cmp    %rax,%rdx
  8041605d45:	74 17                	je     8041605d5e <mem_init+0xaaa>
  8041605d47:	4c 89 e8             	mov    %r13,%rax
  8041605d4a:	48 29 c8             	sub    %rcx,%rax
  8041605d4d:	48 c1 f8 04          	sar    $0x4,%rax
  8041605d51:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605d55:	48 39 c2             	cmp    %rax,%rdx
  8041605d58:	0f 85 43 13 00 00    	jne    80416070a1 <mem_init+0x1ded>
  kern_pml4e[0] = 0;
  8041605d5e:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
  assert(pp3->pp_ref == 1);
  8041605d65:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605d6b:	0f 85 65 13 00 00    	jne    80416070d6 <mem_init+0x1e22>
  page_decref(pp3);
  8041605d71:	4c 89 ef             	mov    %r13,%rdi
  8041605d74:	49 bd dd 4b 60 41 80 	movabs $0x8041604bdd,%r13
  8041605d7b:	00 00 00 
  8041605d7e:	41 ff d5             	callq  *%r13
  // check pointer arithmetic in pml4e_walk
  page_decref(pp0);
  8041605d81:	4c 89 f7             	mov    %r14,%rdi
  8041605d84:	41 ff d5             	callq  *%r13
  page_decref(pp2);
  8041605d87:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605d8b:	41 ff d5             	callq  *%r13
  va    = (void *)(PGSIZE * 100);
  ptep  = pml4e_walk(kern_pml4e, va, 1);
  8041605d8e:	49 bd 20 59 70 41 80 	movabs $0x8041705920,%r13
  8041605d95:	00 00 00 
  8041605d98:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605d9d:	be 00 40 06 00       	mov    $0x64000,%esi
  8041605da2:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041605da6:	48 b8 99 4e 60 41 80 	movabs $0x8041604e99,%rax
  8041605dad:	00 00 00 
  8041605db0:	ff d0                	callq  *%rax
  8041605db2:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  pdpe  = KADDR(PTE_ADDR(kern_pml4e[PML4(va)]));
  8041605db6:	49 8b 55 00          	mov    0x0(%r13),%rdx
  8041605dba:	48 8b 0a             	mov    (%rdx),%rcx
  8041605dbd:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605dc4:	48 be 30 59 70 41 80 	movabs $0x8041705930,%rsi
  8041605dcb:	00 00 00 
  8041605dce:	48 8b 16             	mov    (%rsi),%rdx
  8041605dd1:	48 89 ce             	mov    %rcx,%rsi
  8041605dd4:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605dd8:	48 39 d6             	cmp    %rdx,%rsi
  8041605ddb:	0f 83 2a 13 00 00    	jae    804160710b <mem_init+0x1e57>
  pde   = KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8041605de1:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605de8:	00 00 00 
  8041605deb:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605def:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605df6:	48 89 ce             	mov    %rcx,%rsi
  8041605df9:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605dfd:	48 39 f2             	cmp    %rsi,%rdx
  8041605e00:	0f 86 30 13 00 00    	jbe    8041607136 <mem_init+0x1e82>
  ptep1 = KADDR(PTE_ADDR(pde[PDX(va)]));
  8041605e06:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605e0d:	00 00 00 
  8041605e10:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605e14:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605e1b:	48 89 ce             	mov    %rcx,%rsi
  8041605e1e:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605e22:	48 39 f2             	cmp    %rsi,%rdx
  8041605e25:	0f 86 36 13 00 00    	jbe    8041607161 <mem_init+0x1ead>
  assert(ptep == ptep1 + PTX(va));
  8041605e2b:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605e32:	00 00 00 
  8041605e35:	48 8d 94 11 20 03 00 	lea    0x320(%rcx,%rdx,1),%rdx
  8041605e3c:	00 
  8041605e3d:	48 39 d0             	cmp    %rdx,%rax
  8041605e40:	0f 85 46 13 00 00    	jne    804160718c <mem_init+0x1ed8>

  // check that new page tables get cleared
  page_decref(pp4);
  8041605e46:	4c 8b 7d b0          	mov    -0x50(%rbp),%r15
  8041605e4a:	4c 89 ff             	mov    %r15,%rdi
  8041605e4d:	48 b8 dd 4b 60 41 80 	movabs $0x8041604bdd,%rax
  8041605e54:	00 00 00 
  8041605e57:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041605e59:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041605e60:	00 00 00 
  8041605e63:	4c 89 ff             	mov    %r15,%rdi
  8041605e66:	48 2b 38             	sub    (%rax),%rdi
  8041605e69:	48 c1 ff 04          	sar    $0x4,%rdi
  8041605e6d:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041605e71:	48 89 fa             	mov    %rdi,%rdx
  8041605e74:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605e78:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041605e7f:	00 00 00 
  8041605e82:	48 3b 10             	cmp    (%rax),%rdx
  8041605e85:	0f 83 36 13 00 00    	jae    80416071c1 <mem_init+0x1f0d>
  return (void *)(pa + KERNBASE);
  8041605e8b:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041605e92:	00 00 00 
  8041605e95:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp4), 0xFF, PGSIZE);
  8041605e98:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605e9d:	be ff 00 00 00       	mov    $0xff,%esi
  8041605ea2:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041605ea9:	00 00 00 
  8041605eac:	ff d0                	callq  *%rax
  pml4e_walk(kern_pml4e, 0x0, 1);
  8041605eae:	49 bd 20 59 70 41 80 	movabs $0x8041705920,%r13
  8041605eb5:	00 00 00 
  8041605eb8:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605ebd:	be 00 00 00 00       	mov    $0x0,%esi
  8041605ec2:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  8041605ec6:	48 b8 99 4e 60 41 80 	movabs $0x8041604e99,%rax
  8041605ecd:	00 00 00 
  8041605ed0:	ff d0                	callq  *%rax
  pdpe = KADDR(PTE_ADDR(kern_pml4e[0]));
  8041605ed2:	49 8b 55 00          	mov    0x0(%r13),%rdx
  8041605ed6:	48 8b 0a             	mov    (%rdx),%rcx
  8041605ed9:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605ee0:	48 a1 30 59 70 41 80 	movabs 0x8041705930,%rax
  8041605ee7:	00 00 00 
  8041605eea:	48 89 ce             	mov    %rcx,%rsi
  8041605eed:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605ef1:	48 39 c6             	cmp    %rax,%rsi
  8041605ef4:	0f 83 f5 12 00 00    	jae    80416071ef <mem_init+0x1f3b>
  pde  = KADDR(PTE_ADDR(pdpe[0]));
  8041605efa:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605f01:	00 00 00 
  8041605f04:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605f08:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605f0f:	48 89 ce             	mov    %rcx,%rsi
  8041605f12:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605f16:	48 39 f0             	cmp    %rsi,%rax
  8041605f19:	0f 86 fb 12 00 00    	jbe    804160721a <mem_init+0x1f66>
  ptep = KADDR(PTE_ADDR(pde[0]));
  8041605f1f:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605f26:	00 00 00 
  8041605f29:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605f2d:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605f34:	48 89 ce             	mov    %rcx,%rsi
  8041605f37:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605f3b:	48 39 f0             	cmp    %rsi,%rax
  8041605f3e:	0f 86 01 13 00 00    	jbe    8041607245 <mem_init+0x1f91>
  return (void *)(pa + KERNBASE);
  8041605f44:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041605f4b:	00 00 00 
  8041605f4e:	48 01 c8             	add    %rcx,%rax
  8041605f51:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
  8041605f55:	f6 00 01             	testb  $0x1,(%rax)
  8041605f58:	0f 85 12 13 00 00    	jne    8041607270 <mem_init+0x1fbc>
  8041605f5e:	48 b8 08 00 00 40 80 	movabs $0x8040000008,%rax
  8041605f65:	00 00 00 
  8041605f68:	48 01 c8             	add    %rcx,%rax
  8041605f6b:	48 be 00 10 00 40 80 	movabs $0x8040001000,%rsi
  8041605f72:	00 00 00 
  8041605f75:	48 01 f1             	add    %rsi,%rcx
  8041605f78:	4c 8b 28             	mov    (%rax),%r13
  8041605f7b:	41 83 e5 01          	and    $0x1,%r13d
  8041605f7f:	0f 85 eb 12 00 00    	jne    8041607270 <mem_init+0x1fbc>
  for (i = 0; i < NPTENTRIES; i++)
  8041605f85:	48 83 c0 08          	add    $0x8,%rax
  8041605f89:	48 39 c8             	cmp    %rcx,%rax
  8041605f8c:	75 ea                	jne    8041605f78 <mem_init+0xcc4>
  kern_pml4e[0] = 0;
  8041605f8e:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)

  // give free list back
  page_free_list = fl;
  8041605f95:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041605f99:	48 a3 e8 43 70 41 80 	movabs %rax,0x80417043e8
  8041605fa0:	00 00 00 

  // free the pages we took
  page_decref(pp0);
  8041605fa3:	4c 89 f7             	mov    %r14,%rdi
  8041605fa6:	49 be dd 4b 60 41 80 	movabs $0x8041604bdd,%r14
  8041605fad:	00 00 00 
  8041605fb0:	41 ff d6             	callq  *%r14
  page_decref(pp1);
  8041605fb3:	4c 89 e7             	mov    %r12,%rdi
  8041605fb6:	41 ff d6             	callq  *%r14
  page_decref(pp2);
  8041605fb9:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605fbd:	41 ff d6             	callq  *%r14

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041605fc0:	48 a1 20 59 70 41 80 	movabs 0x8041705920,%rax
  8041605fc7:	00 00 00 
  8041605fca:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8041605fce:	48 89 08             	mov    %rcx,(%rax)

  cprintf("check_page() succeeded!\n");
  8041605fd1:	48 bf 38 d3 60 41 80 	movabs $0x804160d338,%rdi
  8041605fd8:	00 00 00 
  8041605fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605fe0:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041605fe7:	00 00 00 
  8041605fea:	ff d2                	callq  *%rdx
  if (!pages)
  8041605fec:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041605ff3:	00 00 00 
  8041605ff6:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041605ffa:	0f 84 a5 12 00 00    	je     80416072a5 <mem_init+0x1ff1>
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041606000:	48 a1 e8 43 70 41 80 	movabs 0x80417043e8,%rax
  8041606007:	00 00 00 
  804160600a:	48 85 c0             	test   %rax,%rax
  804160600d:	74 0b                	je     804160601a <mem_init+0xd66>
    ++nfree;
  804160600f:	83 c3 01             	add    $0x1,%ebx
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041606012:	48 8b 00             	mov    (%rax),%rax
  8041606015:	48 85 c0             	test   %rax,%rax
  8041606018:	75 f5                	jne    804160600f <mem_init+0xd5b>
  assert((pp0 = page_alloc(0)));
  804160601a:	bf 00 00 00 00       	mov    $0x0,%edi
  804160601f:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606026:	00 00 00 
  8041606029:	ff d0                	callq  *%rax
  804160602b:	49 89 c7             	mov    %rax,%r15
  804160602e:	48 85 c0             	test   %rax,%rax
  8041606031:	0f 84 98 12 00 00    	je     80416072cf <mem_init+0x201b>
  assert((pp1 = page_alloc(0)));
  8041606037:	bf 00 00 00 00       	mov    $0x0,%edi
  804160603c:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606043:	00 00 00 
  8041606046:	ff d0                	callq  *%rax
  8041606048:	49 89 c6             	mov    %rax,%r14
  804160604b:	48 85 c0             	test   %rax,%rax
  804160604e:	0f 84 b0 12 00 00    	je     8041607304 <mem_init+0x2050>
  assert((pp2 = page_alloc(0)));
  8041606054:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606059:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606060:	00 00 00 
  8041606063:	ff d0                	callq  *%rax
  8041606065:	49 89 c4             	mov    %rax,%r12
  8041606068:	48 85 c0             	test   %rax,%rax
  804160606b:	0f 84 c8 12 00 00    	je     8041607339 <mem_init+0x2085>
  assert(pp1 && pp1 != pp0);
  8041606071:	4d 39 f7             	cmp    %r14,%r15
  8041606074:	0f 84 f4 12 00 00    	je     804160736e <mem_init+0x20ba>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  804160607a:	49 39 c7             	cmp    %rax,%r15
  804160607d:	0f 84 20 13 00 00    	je     80416073a3 <mem_init+0x20ef>
  8041606083:	49 39 c6             	cmp    %rax,%r14
  8041606086:	0f 84 17 13 00 00    	je     80416073a3 <mem_init+0x20ef>
  return (pp - pages) << PGSHIFT;
  804160608c:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041606093:	00 00 00 
  8041606096:	48 8b 08             	mov    (%rax),%rcx
  assert(page2pa(pp0) < npages * PGSIZE);
  8041606099:	48 a1 30 59 70 41 80 	movabs 0x8041705930,%rax
  80416060a0:	00 00 00 
  80416060a3:	48 c1 e0 0c          	shl    $0xc,%rax
  80416060a7:	4c 89 fa             	mov    %r15,%rdx
  80416060aa:	48 29 ca             	sub    %rcx,%rdx
  80416060ad:	48 c1 fa 04          	sar    $0x4,%rdx
  80416060b1:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416060b5:	48 39 c2             	cmp    %rax,%rdx
  80416060b8:	0f 83 1a 13 00 00    	jae    80416073d8 <mem_init+0x2124>
  80416060be:	4c 89 f2             	mov    %r14,%rdx
  80416060c1:	48 29 ca             	sub    %rcx,%rdx
  80416060c4:	48 c1 fa 04          	sar    $0x4,%rdx
  80416060c8:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp1) < npages * PGSIZE);
  80416060cc:	48 39 d0             	cmp    %rdx,%rax
  80416060cf:	0f 86 38 13 00 00    	jbe    804160740d <mem_init+0x2159>
  80416060d5:	4c 89 e2             	mov    %r12,%rdx
  80416060d8:	48 29 ca             	sub    %rcx,%rdx
  80416060db:	48 c1 fa 04          	sar    $0x4,%rdx
  80416060df:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp2) < npages * PGSIZE);
  80416060e3:	48 39 d0             	cmp    %rdx,%rax
  80416060e6:	0f 86 56 13 00 00    	jbe    8041607442 <mem_init+0x218e>
  fl             = page_free_list;
  80416060ec:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  80416060f3:	00 00 00 
  80416060f6:	48 8b 38             	mov    (%rax),%rdi
  80416060f9:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  page_free_list = 0;
  80416060fd:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  assert(!page_alloc(0));
  8041606104:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606109:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606110:	00 00 00 
  8041606113:	ff d0                	callq  *%rax
  8041606115:	48 85 c0             	test   %rax,%rax
  8041606118:	0f 85 59 13 00 00    	jne    8041607477 <mem_init+0x21c3>
  page_free(pp0);
  804160611e:	4c 89 ff             	mov    %r15,%rdi
  8041606121:	49 bf 44 4b 60 41 80 	movabs $0x8041604b44,%r15
  8041606128:	00 00 00 
  804160612b:	41 ff d7             	callq  *%r15
  page_free(pp1);
  804160612e:	4c 89 f7             	mov    %r14,%rdi
  8041606131:	41 ff d7             	callq  *%r15
  page_free(pp2);
  8041606134:	4c 89 e7             	mov    %r12,%rdi
  8041606137:	41 ff d7             	callq  *%r15
  assert((pp0 = page_alloc(0)));
  804160613a:	bf 00 00 00 00       	mov    $0x0,%edi
  804160613f:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606146:	00 00 00 
  8041606149:	ff d0                	callq  *%rax
  804160614b:	49 89 c4             	mov    %rax,%r12
  804160614e:	48 85 c0             	test   %rax,%rax
  8041606151:	0f 84 55 13 00 00    	je     80416074ac <mem_init+0x21f8>
  assert((pp1 = page_alloc(0)));
  8041606157:	bf 00 00 00 00       	mov    $0x0,%edi
  804160615c:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606163:	00 00 00 
  8041606166:	ff d0                	callq  *%rax
  8041606168:	49 89 c7             	mov    %rax,%r15
  804160616b:	48 85 c0             	test   %rax,%rax
  804160616e:	0f 84 6d 13 00 00    	je     80416074e1 <mem_init+0x222d>
  assert((pp2 = page_alloc(0)));
  8041606174:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606179:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606180:	00 00 00 
  8041606183:	ff d0                	callq  *%rax
  8041606185:	49 89 c6             	mov    %rax,%r14
  8041606188:	48 85 c0             	test   %rax,%rax
  804160618b:	0f 84 85 13 00 00    	je     8041607516 <mem_init+0x2262>
  assert(pp1 && pp1 != pp0);
  8041606191:	4d 39 fc             	cmp    %r15,%r12
  8041606194:	0f 84 b1 13 00 00    	je     804160754b <mem_init+0x2297>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  804160619a:	49 39 c7             	cmp    %rax,%r15
  804160619d:	0f 84 dd 13 00 00    	je     8041607580 <mem_init+0x22cc>
  80416061a3:	49 39 c4             	cmp    %rax,%r12
  80416061a6:	0f 84 d4 13 00 00    	je     8041607580 <mem_init+0x22cc>
  assert(!page_alloc(0));
  80416061ac:	bf 00 00 00 00       	mov    $0x0,%edi
  80416061b1:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  80416061b8:	00 00 00 
  80416061bb:	ff d0                	callq  *%rax
  80416061bd:	48 85 c0             	test   %rax,%rax
  80416061c0:	0f 85 ef 13 00 00    	jne    80416075b5 <mem_init+0x2301>
  80416061c6:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  80416061cd:	00 00 00 
  80416061d0:	4c 89 e7             	mov    %r12,%rdi
  80416061d3:	48 2b 38             	sub    (%rax),%rdi
  80416061d6:	48 c1 ff 04          	sar    $0x4,%rdi
  80416061da:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  80416061de:	48 89 fa             	mov    %rdi,%rdx
  80416061e1:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416061e5:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  80416061ec:	00 00 00 
  80416061ef:	48 3b 10             	cmp    (%rax),%rdx
  80416061f2:	0f 83 f2 13 00 00    	jae    80416075ea <mem_init+0x2336>
  return (void *)(pa + KERNBASE);
  80416061f8:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  80416061ff:	00 00 00 
  8041606202:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp0), 1, PGSIZE);
  8041606205:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160620a:	be 01 00 00 00       	mov    $0x1,%esi
  804160620f:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041606216:	00 00 00 
  8041606219:	ff d0                	callq  *%rax
  page_free(pp0);
  804160621b:	4c 89 e7             	mov    %r12,%rdi
  804160621e:	48 b8 44 4b 60 41 80 	movabs $0x8041604b44,%rax
  8041606225:	00 00 00 
  8041606228:	ff d0                	callq  *%rax
  assert((pp = page_alloc(ALLOC_ZERO)));
  804160622a:	bf 01 00 00 00       	mov    $0x1,%edi
  804160622f:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041606236:	00 00 00 
  8041606239:	ff d0                	callq  *%rax
  804160623b:	48 85 c0             	test   %rax,%rax
  804160623e:	0f 84 d4 13 00 00    	je     8041607618 <mem_init+0x2364>
  assert(pp && pp0 == pp);
  8041606244:	49 39 c4             	cmp    %rax,%r12
  8041606247:	0f 85 fb 13 00 00    	jne    8041607648 <mem_init+0x2394>
  return (pp - pages) << PGSHIFT;
  804160624d:	48 ba 38 59 70 41 80 	movabs $0x8041705938,%rdx
  8041606254:	00 00 00 
  8041606257:	48 2b 02             	sub    (%rdx),%rax
  804160625a:	48 89 c1             	mov    %rax,%rcx
  804160625d:	48 c1 f9 04          	sar    $0x4,%rcx
  8041606261:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041606265:	48 89 ca             	mov    %rcx,%rdx
  8041606268:	48 c1 ea 0c          	shr    $0xc,%rdx
  804160626c:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041606273:	00 00 00 
  8041606276:	48 3b 10             	cmp    (%rax),%rdx
  8041606279:	0f 83 fe 13 00 00    	jae    804160767d <mem_init+0x23c9>
    assert(c[i] == 0);
  804160627f:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041606286:	00 00 00 
  8041606289:	80 3c 01 00          	cmpb   $0x0,(%rcx,%rax,1)
  804160628d:	0f 85 15 14 00 00    	jne    80416076a8 <mem_init+0x23f4>
  8041606293:	48 8d 40 01          	lea    0x1(%rax),%rax
  8041606297:	48 01 c8             	add    %rcx,%rax
  804160629a:	48 ba 00 10 00 40 80 	movabs $0x8040001000,%rdx
  80416062a1:	00 00 00 
  80416062a4:	48 01 d1             	add    %rdx,%rcx
  80416062a7:	80 38 00             	cmpb   $0x0,(%rax)
  80416062aa:	0f 85 f8 13 00 00    	jne    80416076a8 <mem_init+0x23f4>
  for (i = 0; i < PGSIZE; i++)
  80416062b0:	48 83 c0 01          	add    $0x1,%rax
  80416062b4:	48 39 c1             	cmp    %rax,%rcx
  80416062b7:	75 ee                	jne    80416062a7 <mem_init+0xff3>
  page_free_list = fl;
  80416062b9:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  80416062c0:	00 00 00 
  80416062c3:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  80416062c7:	48 89 08             	mov    %rcx,(%rax)
  page_free(pp0);
  80416062ca:	4c 89 e7             	mov    %r12,%rdi
  80416062cd:	49 bc 44 4b 60 41 80 	movabs $0x8041604b44,%r12
  80416062d4:	00 00 00 
  80416062d7:	41 ff d4             	callq  *%r12
  page_free(pp1);
  80416062da:	4c 89 ff             	mov    %r15,%rdi
  80416062dd:	41 ff d4             	callq  *%r12
  page_free(pp2);
  80416062e0:	4c 89 f7             	mov    %r14,%rdi
  80416062e3:	41 ff d4             	callq  *%r12
  for (pp = page_free_list; pp; pp = pp->pp_link)
  80416062e6:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  80416062ed:	00 00 00 
  80416062f0:	48 8b 00             	mov    (%rax),%rax
  80416062f3:	48 85 c0             	test   %rax,%rax
  80416062f6:	74 0b                	je     8041606303 <mem_init+0x104f>
    --nfree;
  80416062f8:	83 eb 01             	sub    $0x1,%ebx
  for (pp = page_free_list; pp; pp = pp->pp_link)
  80416062fb:	48 8b 00             	mov    (%rax),%rax
  80416062fe:	48 85 c0             	test   %rax,%rax
  8041606301:	75 f5                	jne    80416062f8 <mem_init+0x1044>
  assert(nfree == 0);
  8041606303:	85 db                	test   %ebx,%ebx
  8041606305:	0f 85 d2 13 00 00    	jne    80416076dd <mem_init+0x2429>
  cprintf("check_page_alloc() succeeded!\n");
  804160630b:	48 bf 60 ce 60 41 80 	movabs $0x804160ce60,%rdi
  8041606312:	00 00 00 
  8041606315:	b8 00 00 00 00       	mov    $0x0,%eax
  804160631a:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041606321:	00 00 00 
  8041606324:	ff d2                	callq  *%rdx
  boot_map_region(kern_pml4e, UPAGES, ROUNDUP(npages * sizeof(*pages), PGSIZE), PADDR(pages), PTE_U | PTE_P);
  8041606326:	48 a1 38 59 70 41 80 	movabs 0x8041705938,%rax
  804160632d:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  8041606330:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041606337:	00 00 00 
  804160633a:	48 39 d0             	cmp    %rdx,%rax
  804160633d:	0f 86 cf 13 00 00    	jbe    8041607712 <mem_init+0x245e>
  return (physaddr_t)kva - KERNBASE;
  8041606343:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  804160634a:	ff ff ff 
  804160634d:	48 01 c1             	add    %rax,%rcx
  8041606350:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041606357:	00 00 00 
  804160635a:	48 8b 10             	mov    (%rax),%rdx
  804160635d:	48 c1 e2 04          	shl    $0x4,%rdx
  8041606361:	48 81 c2 ff 0f 00 00 	add    $0xfff,%rdx
  8041606368:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  804160636f:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  8041606375:	48 be 00 e0 42 3c 80 	movabs $0x803c42e000,%rsi
  804160637c:	00 00 00 
  804160637f:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041606386:	00 00 00 
  8041606389:	48 8b 38             	mov    (%rax),%rdi
  804160638c:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  8041606393:	00 00 00 
  8041606396:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041606398:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  804160639f:	00 00 00 
  80416063a2:	48 bb 00 f0 60 41 80 	movabs $0x804160f000,%rbx
  80416063a9:	00 00 00 
  80416063ac:	48 39 c3             	cmp    %rax,%rbx
  80416063af:	0f 86 8b 13 00 00    	jbe    8041607740 <mem_init+0x248c>
  return (physaddr_t)kva - KERNBASE;
  80416063b5:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  80416063bc:	ff ff ff 
  80416063bf:	48 b8 00 f0 60 41 80 	movabs $0x804160f000,%rax
  80416063c6:	00 00 00 
  80416063c9:	49 01 c6             	add    %rax,%r14
  boot_map_region(kern_pml4e, KSTACKTOP - KSTKSIZE, KSTACKTOP - (KSTACKTOP - KSTKSIZE), PADDR(bootstack), PTE_W | PTE_P);
  80416063cc:	49 bc 20 59 70 41 80 	movabs $0x8041705920,%r12
  80416063d3:	00 00 00 
  80416063d6:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416063dc:	4c 89 f1             	mov    %r14,%rcx
  80416063df:	ba 00 00 01 00       	mov    $0x10000,%edx
  80416063e4:	48 be 00 00 ff 3f 80 	movabs $0x803fff0000,%rsi
  80416063eb:	00 00 00 
  80416063ee:	49 8b 3c 24          	mov    (%r12),%rdi
  80416063f2:	48 bb ea 4f 60 41 80 	movabs $0x8041604fea,%rbx
  80416063f9:	00 00 00 
  80416063fc:	ff d3                	callq  *%rbx
  boot_map_region(kern_pml4e, X86ADDR(KSTACKTOP - KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
  80416063fe:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606404:	4c 89 f1             	mov    %r14,%rcx
  8041606407:	ba 00 00 01 00       	mov    $0x10000,%edx
  804160640c:	be 00 00 ff 3f       	mov    $0x3fff0000,%esi
  8041606411:	49 8b 3c 24          	mov    (%r12),%rdi
  8041606415:	ff d3                	callq  *%rbx
  boot_map_region(kern_pml4e, KERNBASE, npages * PGSIZE, 0, PTE_P | PTE_W);
  8041606417:	49 be 30 59 70 41 80 	movabs $0x8041705930,%r14
  804160641e:	00 00 00 
  8041606421:	49 8b 16             	mov    (%r14),%rdx
  8041606424:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041606428:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  804160642e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041606433:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  804160643a:	00 00 00 
  804160643d:	49 8b 3c 24          	mov    (%r12),%rdi
  8041606441:	ff d3                	callq  *%rbx
  size_to_alloc = MIN(0x3200000, npages * PGSIZE);
  8041606443:	49 8b 16             	mov    (%r14),%rdx
  8041606446:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160644a:	48 81 fa 00 00 20 03 	cmp    $0x3200000,%rdx
  8041606451:	b8 00 00 20 03       	mov    $0x3200000,%eax
  8041606456:	48 0f 47 d0          	cmova  %rax,%rdx
  boot_map_region(kern_pml4e, X86ADDR(KERNBASE), size_to_alloc, 0, PTE_P | PTE_W);
  804160645a:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606460:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041606465:	be 00 00 00 40       	mov    $0x40000000,%esi
  804160646a:	49 8b 3c 24          	mov    (%r12),%rdi
  804160646e:	ff d3                	callq  *%rbx
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606470:	48 b8 d0 43 70 41 80 	movabs $0x80417043d0,%rax
  8041606477:	00 00 00 
  804160647a:	48 8b 18             	mov    (%rax),%rbx
  804160647d:	48 b8 c8 43 70 41 80 	movabs $0x80417043c8,%rax
  8041606484:	00 00 00 
  8041606487:	48 3b 18             	cmp    (%rax),%rbx
  804160648a:	0f 83 1b 13 00 00    	jae    80416077ab <mem_init+0x24f7>
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  8041606490:	4d 89 e7             	mov    %r12,%r15
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606493:	49 be c0 43 70 41 80 	movabs $0x80417043c0,%r14
  804160649a:	00 00 00 
  804160649d:	49 89 c4             	mov    %rax,%r12
  80416064a0:	e9 d8 12 00 00       	jmpq   804160777d <mem_init+0x24c9>
  mem_map_size     = desc->MemoryMapDescriptorSize;
  80416064a5:	48 8b 70 20          	mov    0x20(%rax),%rsi
  80416064a9:	48 89 c3             	mov    %rax,%rbx
  80416064ac:	48 89 f0             	mov    %rsi,%rax
  80416064af:	48 a3 c0 43 70 41 80 	movabs %rax,0x80417043c0
  80416064b6:	00 00 00 
  mmap_base        = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)desc->MemoryMap;
  80416064b9:	48 89 fa             	mov    %rdi,%rdx
  80416064bc:	48 89 f8             	mov    %rdi,%rax
  80416064bf:	48 a3 d0 43 70 41 80 	movabs %rax,0x80417043d0
  80416064c6:	00 00 00 
  mmap_end         = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)desc->MemoryMap + desc->MemoryMapSize);
  80416064c9:	48 89 f9             	mov    %rdi,%rcx
  80416064cc:	48 03 4b 38          	add    0x38(%rbx),%rcx
  80416064d0:	48 89 c8             	mov    %rcx,%rax
  80416064d3:	48 a3 c8 43 70 41 80 	movabs %rax,0x80417043c8
  80416064da:	00 00 00 
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416064dd:	48 39 cf             	cmp    %rcx,%rdi
  80416064e0:	73 36                	jae    8041606518 <mem_init+0x1264>
  size_t num_pages = 0;
  80416064e2:	bb 00 00 00 00       	mov    $0x0,%ebx
    num_pages += mmap_curr->NumberOfPages;
  80416064e7:	48 03 5a 18          	add    0x18(%rdx),%rbx
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416064eb:	48 01 f2             	add    %rsi,%rdx
  80416064ee:	48 39 d1             	cmp    %rdx,%rcx
  80416064f1:	77 f4                	ja     80416064e7 <mem_init+0x1233>
  *npages_basemem = num_pages > (IOPHYSMEM / PGSIZE) ? IOPHYSMEM / PGSIZE : num_pages;
  80416064f3:	48 81 fb a0 00 00 00 	cmp    $0xa0,%rbx
  80416064fa:	ba a0 00 00 00       	mov    $0xa0,%edx
  80416064ff:	48 0f 46 d3          	cmovbe %rbx,%rdx
  8041606503:	48 89 d0             	mov    %rdx,%rax
  8041606506:	48 a3 f0 43 70 41 80 	movabs %rax,0x80417043f0
  804160650d:	00 00 00 
  *npages_extmem  = num_pages - *npages_basemem;
  8041606510:	48 29 d3             	sub    %rdx,%rbx
  8041606513:	48 89 df             	mov    %rbx,%rdi
  8041606516:	eb 0f                	jmp    8041606527 <mem_init+0x1273>
  size_t num_pages = 0;
  8041606518:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160651d:	eb d4                	jmp    80416064f3 <mem_init+0x123f>
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  804160651f:	c1 e3 0a             	shl    $0xa,%ebx
  8041606522:	c1 eb 0c             	shr    $0xc,%ebx
  8041606525:	89 df                	mov    %ebx,%edi
    npages = npages_basemem;
  8041606527:	48 b8 f0 43 70 41 80 	movabs $0x80417043f0,%rax
  804160652e:	00 00 00 
  8041606531:	48 8b 30             	mov    (%rax),%rsi
  if (npages_extmem)
  8041606534:	48 85 ff             	test   %rdi,%rdi
  8041606537:	0f 84 fd ed ff ff    	je     804160533a <mem_init+0x86>
  804160653d:	e9 f1 ed ff ff       	jmpq   8041605333 <mem_init+0x7f>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041606542:	48 89 d9             	mov    %rbx,%rcx
  8041606545:	48 ba 38 c7 60 41 80 	movabs $0x804160c738,%rdx
  804160654c:	00 00 00 
  804160654f:	be e4 00 00 00       	mov    $0xe4,%esi
  8041606554:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160655b:	00 00 00 
  804160655e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606563:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160656a:	00 00 00 
  804160656d:	41 ff d0             	callq  *%r8
  assert(pp0 = page_alloc(0));
  8041606570:	48 b9 82 d1 60 41 80 	movabs $0x804160d182,%rcx
  8041606577:	00 00 00 
  804160657a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606581:	00 00 00 
  8041606584:	be 7f 04 00 00       	mov    $0x47f,%esi
  8041606589:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606590:	00 00 00 
  8041606593:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606598:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160659f:	00 00 00 
  80416065a2:	41 ff d0             	callq  *%r8
  assert(pp1 = page_alloc(0));
  80416065a5:	48 b9 96 d1 60 41 80 	movabs $0x804160d196,%rcx
  80416065ac:	00 00 00 
  80416065af:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416065b6:	00 00 00 
  80416065b9:	be 80 04 00 00       	mov    $0x480,%esi
  80416065be:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416065c5:	00 00 00 
  80416065c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416065cd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065d4:	00 00 00 
  80416065d7:	41 ff d0             	callq  *%r8
  assert(pp2 = page_alloc(0));
  80416065da:	48 b9 aa d1 60 41 80 	movabs $0x804160d1aa,%rcx
  80416065e1:	00 00 00 
  80416065e4:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416065eb:	00 00 00 
  80416065ee:	be 81 04 00 00       	mov    $0x481,%esi
  80416065f3:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416065fa:	00 00 00 
  80416065fd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606604:	00 00 00 
  8041606607:	41 ff d0             	callq  *%r8
  assert(pp3 = page_alloc(0));
  804160660a:	48 b9 be d1 60 41 80 	movabs $0x804160d1be,%rcx
  8041606611:	00 00 00 
  8041606614:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160661b:	00 00 00 
  804160661e:	be 82 04 00 00       	mov    $0x482,%esi
  8041606623:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160662a:	00 00 00 
  804160662d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606632:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606639:	00 00 00 
  804160663c:	41 ff d0             	callq  *%r8
  assert(pp4 = page_alloc(0));
  804160663f:	48 b9 d2 d1 60 41 80 	movabs $0x804160d1d2,%rcx
  8041606646:	00 00 00 
  8041606649:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606650:	00 00 00 
  8041606653:	be 83 04 00 00       	mov    $0x483,%esi
  8041606658:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160665f:	00 00 00 
  8041606662:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606669:	00 00 00 
  804160666c:	41 ff d0             	callq  *%r8
  assert(pp5 = page_alloc(0));
  804160666f:	48 b9 e6 d1 60 41 80 	movabs $0x804160d1e6,%rcx
  8041606676:	00 00 00 
  8041606679:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606680:	00 00 00 
  8041606683:	be 84 04 00 00       	mov    $0x484,%esi
  8041606688:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160668f:	00 00 00 
  8041606692:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606699:	00 00 00 
  804160669c:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  804160669f:	48 b9 fa d1 60 41 80 	movabs $0x804160d1fa,%rcx
  80416066a6:	00 00 00 
  80416066a9:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416066b0:	00 00 00 
  80416066b3:	be 87 04 00 00       	mov    $0x487,%esi
  80416066b8:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416066bf:	00 00 00 
  80416066c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066c7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066ce:	00 00 00 
  80416066d1:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416066d4:	48 b9 00 c9 60 41 80 	movabs $0x804160c900,%rcx
  80416066db:	00 00 00 
  80416066de:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416066e5:	00 00 00 
  80416066e8:	be 88 04 00 00       	mov    $0x488,%esi
  80416066ed:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416066f4:	00 00 00 
  80416066f7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066fc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606703:	00 00 00 
  8041606706:	41 ff d0             	callq  *%r8
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  8041606709:	48 b9 20 c9 60 41 80 	movabs $0x804160c920,%rcx
  8041606710:	00 00 00 
  8041606713:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160671a:	00 00 00 
  804160671d:	be 89 04 00 00       	mov    $0x489,%esi
  8041606722:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606729:	00 00 00 
  804160672c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606731:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606738:	00 00 00 
  804160673b:	41 ff d0             	callq  *%r8
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  804160673e:	48 b9 50 c9 60 41 80 	movabs $0x804160c950,%rcx
  8041606745:	00 00 00 
  8041606748:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160674f:	00 00 00 
  8041606752:	be 8a 04 00 00       	mov    $0x48a,%esi
  8041606757:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160675e:	00 00 00 
  8041606761:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606766:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160676d:	00 00 00 
  8041606770:	41 ff d0             	callq  *%r8
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  8041606773:	48 b9 90 c9 60 41 80 	movabs $0x804160c990,%rcx
  804160677a:	00 00 00 
  804160677d:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606784:	00 00 00 
  8041606787:	be 8b 04 00 00       	mov    $0x48b,%esi
  804160678c:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606793:	00 00 00 
  8041606796:	b8 00 00 00 00       	mov    $0x0,%eax
  804160679b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067a2:	00 00 00 
  80416067a5:	41 ff d0             	callq  *%r8
  assert(fl != NULL);
  80416067a8:	48 b9 0c d2 60 41 80 	movabs $0x804160d20c,%rcx
  80416067af:	00 00 00 
  80416067b2:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416067b9:	00 00 00 
  80416067bc:	be 8f 04 00 00       	mov    $0x48f,%esi
  80416067c1:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416067c8:	00 00 00 
  80416067cb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067d2:	00 00 00 
  80416067d5:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416067d8:	48 b9 17 d2 60 41 80 	movabs $0x804160d217,%rcx
  80416067df:	00 00 00 
  80416067e2:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416067e9:	00 00 00 
  80416067ec:	be 93 04 00 00       	mov    $0x493,%esi
  80416067f1:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416067f8:	00 00 00 
  80416067fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606800:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606807:	00 00 00 
  804160680a:	41 ff d0             	callq  *%r8
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  804160680d:	48 b9 e0 c9 60 41 80 	movabs $0x804160c9e0,%rcx
  8041606814:	00 00 00 
  8041606817:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160681e:	00 00 00 
  8041606821:	be 96 04 00 00       	mov    $0x496,%esi
  8041606826:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160682d:	00 00 00 
  8041606830:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606835:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160683c:	00 00 00 
  804160683f:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  8041606842:	48 b9 18 ca 60 41 80 	movabs $0x804160ca18,%rcx
  8041606849:	00 00 00 
  804160684c:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606853:	00 00 00 
  8041606856:	be 99 04 00 00       	mov    $0x499,%esi
  804160685b:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606862:	00 00 00 
  8041606865:	b8 00 00 00 00       	mov    $0x0,%eax
  804160686a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606871:	00 00 00 
  8041606874:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  8041606877:	48 b9 18 ca 60 41 80 	movabs $0x804160ca18,%rcx
  804160687e:	00 00 00 
  8041606881:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606888:	00 00 00 
  804160688b:	be a1 04 00 00       	mov    $0x4a1,%esi
  8041606890:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606897:	00 00 00 
  804160689a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160689f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068a6:	00 00 00 
  80416068a9:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  80416068ac:	48 b9 a8 ca 60 41 80 	movabs $0x804160caa8,%rcx
  80416068b3:	00 00 00 
  80416068b6:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416068bd:	00 00 00 
  80416068c0:	be a9 04 00 00       	mov    $0x4a9,%esi
  80416068c5:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416068cc:	00 00 00 
  80416068cf:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068d4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068db:	00 00 00 
  80416068de:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  80416068e1:	48 b9 d8 ca 60 41 80 	movabs $0x804160cad8,%rcx
  80416068e8:	00 00 00 
  80416068eb:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416068f2:	00 00 00 
  80416068f5:	be aa 04 00 00       	mov    $0x4aa,%esi
  80416068fa:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606901:	00 00 00 
  8041606904:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606909:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606910:	00 00 00 
  8041606913:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  8041606916:	48 b9 58 cb 60 41 80 	movabs $0x804160cb58,%rcx
  804160691d:	00 00 00 
  8041606920:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606927:	00 00 00 
  804160692a:	be ae 04 00 00       	mov    $0x4ae,%esi
  804160692f:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606936:	00 00 00 
  8041606939:	b8 00 00 00 00       	mov    $0x0,%eax
  804160693e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606945:	00 00 00 
  8041606948:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  804160694b:	48 b9 7d d2 60 41 80 	movabs $0x804160d27d,%rcx
  8041606952:	00 00 00 
  8041606955:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160695c:	00 00 00 
  804160695f:	be af 04 00 00       	mov    $0x4af,%esi
  8041606964:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160696b:	00 00 00 
  804160696e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606973:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160697a:	00 00 00 
  804160697d:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041606980:	48 b9 88 cb 60 41 80 	movabs $0x804160cb88,%rcx
  8041606987:	00 00 00 
  804160698a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606991:	00 00 00 
  8041606994:	be b2 04 00 00       	mov    $0x4b2,%esi
  8041606999:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416069a0:	00 00 00 
  80416069a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069a8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069af:	00 00 00 
  80416069b2:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416069b5:	48 b9 c0 cb 60 41 80 	movabs $0x804160cbc0,%rcx
  80416069bc:	00 00 00 
  80416069bf:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416069c6:	00 00 00 
  80416069c9:	be b3 04 00 00       	mov    $0x4b3,%esi
  80416069ce:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416069d5:	00 00 00 
  80416069d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069dd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069e4:	00 00 00 
  80416069e7:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  80416069ea:	48 b9 8e d2 60 41 80 	movabs $0x804160d28e,%rcx
  80416069f1:	00 00 00 
  80416069f4:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416069fb:	00 00 00 
  80416069fe:	be b4 04 00 00       	mov    $0x4b4,%esi
  8041606a03:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606a0a:	00 00 00 
  8041606a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a12:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a19:	00 00 00 
  8041606a1c:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606a1f:	48 b9 17 d2 60 41 80 	movabs $0x804160d217,%rcx
  8041606a26:	00 00 00 
  8041606a29:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606a30:	00 00 00 
  8041606a33:	be b7 04 00 00       	mov    $0x4b7,%esi
  8041606a38:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606a3f:	00 00 00 
  8041606a42:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a47:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a4e:	00 00 00 
  8041606a51:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041606a54:	48 b9 88 cb 60 41 80 	movabs $0x804160cb88,%rcx
  8041606a5b:	00 00 00 
  8041606a5e:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606a65:	00 00 00 
  8041606a68:	be ba 04 00 00       	mov    $0x4ba,%esi
  8041606a6d:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606a74:	00 00 00 
  8041606a77:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a7c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a83:	00 00 00 
  8041606a86:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606a89:	48 b9 c0 cb 60 41 80 	movabs $0x804160cbc0,%rcx
  8041606a90:	00 00 00 
  8041606a93:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606a9a:	00 00 00 
  8041606a9d:	be bb 04 00 00       	mov    $0x4bb,%esi
  8041606aa2:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606aa9:	00 00 00 
  8041606aac:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ab1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ab8:	00 00 00 
  8041606abb:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606abe:	48 b9 8e d2 60 41 80 	movabs $0x804160d28e,%rcx
  8041606ac5:	00 00 00 
  8041606ac8:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606acf:	00 00 00 
  8041606ad2:	be bc 04 00 00       	mov    $0x4bc,%esi
  8041606ad7:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606ade:	00 00 00 
  8041606ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ae6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606aed:	00 00 00 
  8041606af0:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606af3:	48 b9 17 d2 60 41 80 	movabs $0x804160d217,%rcx
  8041606afa:	00 00 00 
  8041606afd:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606b04:	00 00 00 
  8041606b07:	be c0 04 00 00       	mov    $0x4c0,%esi
  8041606b0c:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606b13:	00 00 00 
  8041606b16:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b1b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b22:	00 00 00 
  8041606b25:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041606b28:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041606b2f:	00 00 00 
  8041606b32:	be c2 04 00 00       	mov    $0x4c2,%esi
  8041606b37:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606b3e:	00 00 00 
  8041606b41:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b46:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b4d:	00 00 00 
  8041606b50:	41 ff d0             	callq  *%r8
  8041606b53:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041606b5a:	00 00 00 
  8041606b5d:	be c3 04 00 00       	mov    $0x4c3,%esi
  8041606b62:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606b69:	00 00 00 
  8041606b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b71:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b78:	00 00 00 
  8041606b7b:	41 ff d0             	callq  *%r8
  8041606b7e:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041606b85:	00 00 00 
  8041606b88:	be c4 04 00 00       	mov    $0x4c4,%esi
  8041606b8d:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606b94:	00 00 00 
  8041606b97:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b9c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ba3:	00 00 00 
  8041606ba6:	41 ff d0             	callq  *%r8
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  8041606ba9:	48 b9 f0 cb 60 41 80 	movabs $0x804160cbf0,%rcx
  8041606bb0:	00 00 00 
  8041606bb3:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606bba:	00 00 00 
  8041606bbd:	be c5 04 00 00       	mov    $0x4c5,%esi
  8041606bc2:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606bc9:	00 00 00 
  8041606bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bd1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606bd8:	00 00 00 
  8041606bdb:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  8041606bde:	48 b9 30 cc 60 41 80 	movabs $0x804160cc30,%rcx
  8041606be5:	00 00 00 
  8041606be8:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606bef:	00 00 00 
  8041606bf2:	be c8 04 00 00       	mov    $0x4c8,%esi
  8041606bf7:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606bfe:	00 00 00 
  8041606c01:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c06:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c0d:	00 00 00 
  8041606c10:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606c13:	48 b9 c0 cb 60 41 80 	movabs $0x804160cbc0,%rcx
  8041606c1a:	00 00 00 
  8041606c1d:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606c24:	00 00 00 
  8041606c27:	be c9 04 00 00       	mov    $0x4c9,%esi
  8041606c2c:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606c33:	00 00 00 
  8041606c36:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c3b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c42:	00 00 00 
  8041606c45:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606c48:	48 b9 8e d2 60 41 80 	movabs $0x804160d28e,%rcx
  8041606c4f:	00 00 00 
  8041606c52:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606c59:	00 00 00 
  8041606c5c:	be ca 04 00 00       	mov    $0x4ca,%esi
  8041606c61:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606c68:	00 00 00 
  8041606c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c70:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c77:	00 00 00 
  8041606c7a:	41 ff d0             	callq  *%r8
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041606c7d:	48 b9 70 cc 60 41 80 	movabs $0x804160cc70,%rcx
  8041606c84:	00 00 00 
  8041606c87:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606c8e:	00 00 00 
  8041606c91:	be cb 04 00 00       	mov    $0x4cb,%esi
  8041606c96:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606c9d:	00 00 00 
  8041606ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ca5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606cac:	00 00 00 
  8041606caf:	41 ff d0             	callq  *%r8
  assert(kern_pml4e[0] & PTE_U);
  8041606cb2:	48 b9 9f d2 60 41 80 	movabs $0x804160d29f,%rcx
  8041606cb9:	00 00 00 
  8041606cbc:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606cc3:	00 00 00 
  8041606cc6:	be cc 04 00 00       	mov    $0x4cc,%esi
  8041606ccb:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606cd2:	00 00 00 
  8041606cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606cda:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ce1:	00 00 00 
  8041606ce4:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041606ce7:	48 b9 a8 cc 60 41 80 	movabs $0x804160cca8,%rcx
  8041606cee:	00 00 00 
  8041606cf1:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606cf8:	00 00 00 
  8041606cfb:	be cf 04 00 00       	mov    $0x4cf,%esi
  8041606d00:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606d07:	00 00 00 
  8041606d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d0f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d16:	00 00 00 
  8041606d19:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606d1c:	48 b9 e0 cc 60 41 80 	movabs $0x804160cce0,%rcx
  8041606d23:	00 00 00 
  8041606d26:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606d2d:	00 00 00 
  8041606d30:	be d2 04 00 00       	mov    $0x4d2,%esi
  8041606d35:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606d3c:	00 00 00 
  8041606d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d44:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d4b:	00 00 00 
  8041606d4e:	41 ff d0             	callq  *%r8
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041606d51:	48 b9 18 cd 60 41 80 	movabs $0x804160cd18,%rcx
  8041606d58:	00 00 00 
  8041606d5b:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606d62:	00 00 00 
  8041606d65:	be d3 04 00 00       	mov    $0x4d3,%esi
  8041606d6a:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606d71:	00 00 00 
  8041606d74:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d79:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d80:	00 00 00 
  8041606d83:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041606d86:	48 b9 50 cd 60 41 80 	movabs $0x804160cd50,%rcx
  8041606d8d:	00 00 00 
  8041606d90:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606d97:	00 00 00 
  8041606d9a:	be d6 04 00 00       	mov    $0x4d6,%esi
  8041606d9f:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606da6:	00 00 00 
  8041606da9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606dae:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606db5:	00 00 00 
  8041606db8:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606dbb:	48 b9 80 cd 60 41 80 	movabs $0x804160cd80,%rcx
  8041606dc2:	00 00 00 
  8041606dc5:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606dcc:	00 00 00 
  8041606dcf:	be d7 04 00 00       	mov    $0x4d7,%esi
  8041606dd4:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606ddb:	00 00 00 
  8041606dde:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606de3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606dea:	00 00 00 
  8041606ded:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 2);
  8041606df0:	48 b9 b5 d2 60 41 80 	movabs $0x804160d2b5,%rcx
  8041606df7:	00 00 00 
  8041606dfa:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606e01:	00 00 00 
  8041606e04:	be d9 04 00 00       	mov    $0x4d9,%esi
  8041606e09:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606e10:	00 00 00 
  8041606e13:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e18:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e1f:	00 00 00 
  8041606e22:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606e25:	48 b9 c6 d2 60 41 80 	movabs $0x804160d2c6,%rcx
  8041606e2c:	00 00 00 
  8041606e2f:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606e36:	00 00 00 
  8041606e39:	be da 04 00 00       	mov    $0x4da,%esi
  8041606e3e:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606e45:	00 00 00 
  8041606e48:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e4d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e54:	00 00 00 
  8041606e57:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606e5a:	48 b9 b0 cd 60 41 80 	movabs $0x804160cdb0,%rcx
  8041606e61:	00 00 00 
  8041606e64:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606e6b:	00 00 00 
  8041606e6e:	be de 04 00 00       	mov    $0x4de,%esi
  8041606e73:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606e7a:	00 00 00 
  8041606e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e82:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e89:	00 00 00 
  8041606e8c:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606e8f:	48 b9 80 cd 60 41 80 	movabs $0x804160cd80,%rcx
  8041606e96:	00 00 00 
  8041606e99:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606ea0:	00 00 00 
  8041606ea3:	be df 04 00 00       	mov    $0x4df,%esi
  8041606ea8:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606eaf:	00 00 00 
  8041606eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606eb7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ebe:	00 00 00 
  8041606ec1:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041606ec4:	48 b9 7d d2 60 41 80 	movabs $0x804160d27d,%rcx
  8041606ecb:	00 00 00 
  8041606ece:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606ed5:	00 00 00 
  8041606ed8:	be e0 04 00 00       	mov    $0x4e0,%esi
  8041606edd:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606ee4:	00 00 00 
  8041606ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606eec:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ef3:	00 00 00 
  8041606ef6:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606ef9:	48 b9 c6 d2 60 41 80 	movabs $0x804160d2c6,%rcx
  8041606f00:	00 00 00 
  8041606f03:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606f0a:	00 00 00 
  8041606f0d:	be e1 04 00 00       	mov    $0x4e1,%esi
  8041606f12:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606f19:	00 00 00 
  8041606f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f21:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f28:	00 00 00 
  8041606f2b:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606f2e:	48 b9 e0 cc 60 41 80 	movabs $0x804160cce0,%rcx
  8041606f35:	00 00 00 
  8041606f38:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606f3f:	00 00 00 
  8041606f42:	be e5 04 00 00       	mov    $0x4e5,%esi
  8041606f47:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606f4e:	00 00 00 
  8041606f51:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f56:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f5d:	00 00 00 
  8041606f60:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref);
  8041606f63:	48 b9 d7 d2 60 41 80 	movabs $0x804160d2d7,%rcx
  8041606f6a:	00 00 00 
  8041606f6d:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606f74:	00 00 00 
  8041606f77:	be e6 04 00 00       	mov    $0x4e6,%esi
  8041606f7c:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606f83:	00 00 00 
  8041606f86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f8b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f92:	00 00 00 
  8041606f95:	41 ff d0             	callq  *%r8
  assert(pp1->pp_link == NULL);
  8041606f98:	48 b9 e3 d2 60 41 80 	movabs $0x804160d2e3,%rcx
  8041606f9f:	00 00 00 
  8041606fa2:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606fa9:	00 00 00 
  8041606fac:	be e7 04 00 00       	mov    $0x4e7,%esi
  8041606fb1:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606fb8:	00 00 00 
  8041606fbb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606fc0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606fc7:	00 00 00 
  8041606fca:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606fcd:	48 b9 b0 cd 60 41 80 	movabs $0x804160cdb0,%rcx
  8041606fd4:	00 00 00 
  8041606fd7:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041606fde:	00 00 00 
  8041606fe1:	be eb 04 00 00       	mov    $0x4eb,%esi
  8041606fe6:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041606fed:	00 00 00 
  8041606ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ff5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ffc:	00 00 00 
  8041606fff:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041607002:	48 b9 d8 cd 60 41 80 	movabs $0x804160cdd8,%rcx
  8041607009:	00 00 00 
  804160700c:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607013:	00 00 00 
  8041607016:	be ec 04 00 00       	mov    $0x4ec,%esi
  804160701b:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607022:	00 00 00 
  8041607025:	b8 00 00 00 00       	mov    $0x0,%eax
  804160702a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607031:	00 00 00 
  8041607034:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041607037:	48 b9 f8 d2 60 41 80 	movabs $0x804160d2f8,%rcx
  804160703e:	00 00 00 
  8041607041:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607048:	00 00 00 
  804160704b:	be ed 04 00 00       	mov    $0x4ed,%esi
  8041607050:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607057:	00 00 00 
  804160705a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160705f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607066:	00 00 00 
  8041607069:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  804160706c:	48 b9 c6 d2 60 41 80 	movabs $0x804160d2c6,%rcx
  8041607073:	00 00 00 
  8041607076:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160707d:	00 00 00 
  8041607080:	be ee 04 00 00       	mov    $0x4ee,%esi
  8041607085:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160708c:	00 00 00 
  804160708f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607094:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160709b:	00 00 00 
  804160709e:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  80416070a1:	48 b9 d8 ca 60 41 80 	movabs $0x804160cad8,%rcx
  80416070a8:	00 00 00 
  80416070ab:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416070b2:	00 00 00 
  80416070b5:	be 01 05 00 00       	mov    $0x501,%esi
  80416070ba:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416070c1:	00 00 00 
  80416070c4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070c9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070d0:	00 00 00 
  80416070d3:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  80416070d6:	48 b9 c6 d2 60 41 80 	movabs $0x804160d2c6,%rcx
  80416070dd:	00 00 00 
  80416070e0:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416070e7:	00 00 00 
  80416070ea:	be 03 05 00 00       	mov    $0x503,%esi
  80416070ef:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416070f6:	00 00 00 
  80416070f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070fe:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607105:	00 00 00 
  8041607108:	41 ff d0             	callq  *%r8
  804160710b:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041607112:	00 00 00 
  8041607115:	be 0a 05 00 00       	mov    $0x50a,%esi
  804160711a:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607121:	00 00 00 
  8041607124:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607129:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607130:	00 00 00 
  8041607133:	41 ff d0             	callq  *%r8
  8041607136:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  804160713d:	00 00 00 
  8041607140:	be 0b 05 00 00       	mov    $0x50b,%esi
  8041607145:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160714c:	00 00 00 
  804160714f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607154:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160715b:	00 00 00 
  804160715e:	41 ff d0             	callq  *%r8
  8041607161:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041607168:	00 00 00 
  804160716b:	be 0c 05 00 00       	mov    $0x50c,%esi
  8041607170:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607177:	00 00 00 
  804160717a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160717f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607186:	00 00 00 
  8041607189:	41 ff d0             	callq  *%r8
  assert(ptep == ptep1 + PTX(va));
  804160718c:	48 b9 09 d3 60 41 80 	movabs $0x804160d309,%rcx
  8041607193:	00 00 00 
  8041607196:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160719d:	00 00 00 
  80416071a0:	be 0d 05 00 00       	mov    $0x50d,%esi
  80416071a5:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416071ac:	00 00 00 
  80416071af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071b4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071bb:	00 00 00 
  80416071be:	41 ff d0             	callq  *%r8
  80416071c1:	48 89 f9             	mov    %rdi,%rcx
  80416071c4:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  80416071cb:	00 00 00 
  80416071ce:	be 63 00 00 00       	mov    $0x63,%esi
  80416071d3:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  80416071da:	00 00 00 
  80416071dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071e2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071e9:	00 00 00 
  80416071ec:	41 ff d0             	callq  *%r8
  80416071ef:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  80416071f6:	00 00 00 
  80416071f9:	be 13 05 00 00       	mov    $0x513,%esi
  80416071fe:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607205:	00 00 00 
  8041607208:	b8 00 00 00 00       	mov    $0x0,%eax
  804160720d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607214:	00 00 00 
  8041607217:	41 ff d0             	callq  *%r8
  804160721a:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041607221:	00 00 00 
  8041607224:	be 14 05 00 00       	mov    $0x514,%esi
  8041607229:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607230:	00 00 00 
  8041607233:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607238:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160723f:	00 00 00 
  8041607242:	41 ff d0             	callq  *%r8
  8041607245:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  804160724c:	00 00 00 
  804160724f:	be 15 05 00 00       	mov    $0x515,%esi
  8041607254:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160725b:	00 00 00 
  804160725e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607263:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160726a:	00 00 00 
  804160726d:	41 ff d0             	callq  *%r8
    assert((ptep[i] & PTE_P) == 0);
  8041607270:	48 b9 21 d3 60 41 80 	movabs $0x804160d321,%rcx
  8041607277:	00 00 00 
  804160727a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607281:	00 00 00 
  8041607284:	be 17 05 00 00       	mov    $0x517,%esi
  8041607289:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607290:	00 00 00 
  8041607293:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607298:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160729f:	00 00 00 
  80416072a2:	41 ff d0             	callq  *%r8
    panic("'pages' is a null pointer!");
  80416072a5:	48 ba 51 d3 60 41 80 	movabs $0x804160d351,%rdx
  80416072ac:	00 00 00 
  80416072af:	be d1 03 00 00       	mov    $0x3d1,%esi
  80416072b4:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416072bb:	00 00 00 
  80416072be:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072c3:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416072ca:	00 00 00 
  80416072cd:	ff d1                	callq  *%rcx
  assert((pp0 = page_alloc(0)));
  80416072cf:	48 b9 6c d3 60 41 80 	movabs $0x804160d36c,%rcx
  80416072d6:	00 00 00 
  80416072d9:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416072e0:	00 00 00 
  80416072e3:	be d9 03 00 00       	mov    $0x3d9,%esi
  80416072e8:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416072ef:	00 00 00 
  80416072f2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072f7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072fe:	00 00 00 
  8041607301:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041607304:	48 b9 82 d3 60 41 80 	movabs $0x804160d382,%rcx
  804160730b:	00 00 00 
  804160730e:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607315:	00 00 00 
  8041607318:	be da 03 00 00       	mov    $0x3da,%esi
  804160731d:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607324:	00 00 00 
  8041607327:	b8 00 00 00 00       	mov    $0x0,%eax
  804160732c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607333:	00 00 00 
  8041607336:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041607339:	48 b9 98 d3 60 41 80 	movabs $0x804160d398,%rcx
  8041607340:	00 00 00 
  8041607343:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160734a:	00 00 00 
  804160734d:	be db 03 00 00       	mov    $0x3db,%esi
  8041607352:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607359:	00 00 00 
  804160735c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607361:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607368:	00 00 00 
  804160736b:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  804160736e:	48 b9 fa d1 60 41 80 	movabs $0x804160d1fa,%rcx
  8041607375:	00 00 00 
  8041607378:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160737f:	00 00 00 
  8041607382:	be de 03 00 00       	mov    $0x3de,%esi
  8041607387:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160738e:	00 00 00 
  8041607391:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607396:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160739d:	00 00 00 
  80416073a0:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416073a3:	48 b9 00 c9 60 41 80 	movabs $0x804160c900,%rcx
  80416073aa:	00 00 00 
  80416073ad:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416073b4:	00 00 00 
  80416073b7:	be df 03 00 00       	mov    $0x3df,%esi
  80416073bc:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416073c3:	00 00 00 
  80416073c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073cb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073d2:	00 00 00 
  80416073d5:	41 ff d0             	callq  *%r8
  assert(page2pa(pp0) < npages * PGSIZE);
  80416073d8:	48 b9 00 ce 60 41 80 	movabs $0x804160ce00,%rcx
  80416073df:	00 00 00 
  80416073e2:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416073e9:	00 00 00 
  80416073ec:	be e0 03 00 00       	mov    $0x3e0,%esi
  80416073f1:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416073f8:	00 00 00 
  80416073fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607400:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607407:	00 00 00 
  804160740a:	41 ff d0             	callq  *%r8
  assert(page2pa(pp1) < npages * PGSIZE);
  804160740d:	48 b9 20 ce 60 41 80 	movabs $0x804160ce20,%rcx
  8041607414:	00 00 00 
  8041607417:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160741e:	00 00 00 
  8041607421:	be e1 03 00 00       	mov    $0x3e1,%esi
  8041607426:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160742d:	00 00 00 
  8041607430:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607435:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160743c:	00 00 00 
  804160743f:	41 ff d0             	callq  *%r8
  assert(page2pa(pp2) < npages * PGSIZE);
  8041607442:	48 b9 40 ce 60 41 80 	movabs $0x804160ce40,%rcx
  8041607449:	00 00 00 
  804160744c:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607453:	00 00 00 
  8041607456:	be e2 03 00 00       	mov    $0x3e2,%esi
  804160745b:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607462:	00 00 00 
  8041607465:	b8 00 00 00 00       	mov    $0x0,%eax
  804160746a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607471:	00 00 00 
  8041607474:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041607477:	48 b9 17 d2 60 41 80 	movabs $0x804160d217,%rcx
  804160747e:	00 00 00 
  8041607481:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607488:	00 00 00 
  804160748b:	be e9 03 00 00       	mov    $0x3e9,%esi
  8041607490:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607497:	00 00 00 
  804160749a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160749f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074a6:	00 00 00 
  80416074a9:	41 ff d0             	callq  *%r8
  assert((pp0 = page_alloc(0)));
  80416074ac:	48 b9 6c d3 60 41 80 	movabs $0x804160d36c,%rcx
  80416074b3:	00 00 00 
  80416074b6:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416074bd:	00 00 00 
  80416074c0:	be f0 03 00 00       	mov    $0x3f0,%esi
  80416074c5:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416074cc:	00 00 00 
  80416074cf:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074d4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074db:	00 00 00 
  80416074de:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  80416074e1:	48 b9 82 d3 60 41 80 	movabs $0x804160d382,%rcx
  80416074e8:	00 00 00 
  80416074eb:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416074f2:	00 00 00 
  80416074f5:	be f1 03 00 00       	mov    $0x3f1,%esi
  80416074fa:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607501:	00 00 00 
  8041607504:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607509:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607510:	00 00 00 
  8041607513:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041607516:	48 b9 98 d3 60 41 80 	movabs $0x804160d398,%rcx
  804160751d:	00 00 00 
  8041607520:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607527:	00 00 00 
  804160752a:	be f2 03 00 00       	mov    $0x3f2,%esi
  804160752f:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607536:	00 00 00 
  8041607539:	b8 00 00 00 00       	mov    $0x0,%eax
  804160753e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607545:	00 00 00 
  8041607548:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  804160754b:	48 b9 fa d1 60 41 80 	movabs $0x804160d1fa,%rcx
  8041607552:	00 00 00 
  8041607555:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160755c:	00 00 00 
  804160755f:	be f4 03 00 00       	mov    $0x3f4,%esi
  8041607564:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160756b:	00 00 00 
  804160756e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607573:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160757a:	00 00 00 
  804160757d:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041607580:	48 b9 00 c9 60 41 80 	movabs $0x804160c900,%rcx
  8041607587:	00 00 00 
  804160758a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607591:	00 00 00 
  8041607594:	be f5 03 00 00       	mov    $0x3f5,%esi
  8041607599:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416075a0:	00 00 00 
  80416075a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075a8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075af:	00 00 00 
  80416075b2:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416075b5:	48 b9 17 d2 60 41 80 	movabs $0x804160d217,%rcx
  80416075bc:	00 00 00 
  80416075bf:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416075c6:	00 00 00 
  80416075c9:	be f6 03 00 00       	mov    $0x3f6,%esi
  80416075ce:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416075d5:	00 00 00 
  80416075d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075dd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075e4:	00 00 00 
  80416075e7:	41 ff d0             	callq  *%r8
  80416075ea:	48 89 f9             	mov    %rdi,%rcx
  80416075ed:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  80416075f4:	00 00 00 
  80416075f7:	be 63 00 00 00       	mov    $0x63,%esi
  80416075fc:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041607603:	00 00 00 
  8041607606:	b8 00 00 00 00       	mov    $0x0,%eax
  804160760b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607612:	00 00 00 
  8041607615:	41 ff d0             	callq  *%r8
  assert((pp = page_alloc(ALLOC_ZERO)));
  8041607618:	48 b9 ae d3 60 41 80 	movabs $0x804160d3ae,%rcx
  804160761f:	00 00 00 
  8041607622:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607629:	00 00 00 
  804160762c:	be fb 03 00 00       	mov    $0x3fb,%esi
  8041607631:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607638:	00 00 00 
  804160763b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607642:	00 00 00 
  8041607645:	41 ff d0             	callq  *%r8
  assert(pp && pp0 == pp);
  8041607648:	48 b9 cc d3 60 41 80 	movabs $0x804160d3cc,%rcx
  804160764f:	00 00 00 
  8041607652:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607659:	00 00 00 
  804160765c:	be fc 03 00 00       	mov    $0x3fc,%esi
  8041607661:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607668:	00 00 00 
  804160766b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607670:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607677:	00 00 00 
  804160767a:	41 ff d0             	callq  *%r8
  804160767d:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041607684:	00 00 00 
  8041607687:	be 63 00 00 00       	mov    $0x63,%esi
  804160768c:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041607693:	00 00 00 
  8041607696:	b8 00 00 00 00       	mov    $0x0,%eax
  804160769b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076a2:	00 00 00 
  80416076a5:	41 ff d0             	callq  *%r8
    assert(c[i] == 0);
  80416076a8:	48 b9 dc d3 60 41 80 	movabs $0x804160d3dc,%rcx
  80416076af:	00 00 00 
  80416076b2:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416076b9:	00 00 00 
  80416076bc:	be ff 03 00 00       	mov    $0x3ff,%esi
  80416076c1:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416076c8:	00 00 00 
  80416076cb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076d0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076d7:	00 00 00 
  80416076da:	41 ff d0             	callq  *%r8
  assert(nfree == 0);
  80416076dd:	48 b9 e6 d3 60 41 80 	movabs $0x804160d3e6,%rcx
  80416076e4:	00 00 00 
  80416076e7:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416076ee:	00 00 00 
  80416076f1:	be 0c 04 00 00       	mov    $0x40c,%esi
  80416076f6:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416076fd:	00 00 00 
  8041607700:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607705:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160770c:	00 00 00 
  804160770f:	41 ff d0             	callq  *%r8
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041607712:	48 89 c1             	mov    %rax,%rcx
  8041607715:	48 ba 38 c7 60 41 80 	movabs $0x804160c738,%rdx
  804160771c:	00 00 00 
  804160771f:	be 15 01 00 00       	mov    $0x115,%esi
  8041607724:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160772b:	00 00 00 
  804160772e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607733:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160773a:	00 00 00 
  804160773d:	41 ff d0             	callq  *%r8
  8041607740:	48 89 d9             	mov    %rbx,%rcx
  8041607743:	48 ba 38 c7 60 41 80 	movabs $0x804160c738,%rdx
  804160774a:	00 00 00 
  804160774d:	be 2b 01 00 00       	mov    $0x12b,%esi
  8041607752:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607759:	00 00 00 
  804160775c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607761:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607768:	00 00 00 
  804160776b:	41 ff d0             	callq  *%r8
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  804160776e:	48 89 d8             	mov    %rbx,%rax
  8041607771:	49 03 06             	add    (%r14),%rax
  8041607774:	48 89 c3             	mov    %rax,%rbx
  8041607777:	49 39 04 24          	cmp    %rax,(%r12)
  804160777b:	76 2e                	jbe    80416077ab <mem_init+0x24f7>
    if (mmap_curr->Attribute & EFI_MEMORY_RUNTIME) {
  804160777d:	48 83 7b 20 00       	cmpq   $0x0,0x20(%rbx)
  8041607782:	79 ea                	jns    804160776e <mem_init+0x24ba>
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  8041607784:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
    size_to_alloc = mmap_curr->NumberOfPages * PGSIZE;
  8041607788:	48 8b 53 18          	mov    0x18(%rbx),%rdx
  804160778c:	48 c1 e2 0c          	shl    $0xc,%rdx
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  8041607790:	48 8b 73 10          	mov    0x10(%rbx),%rsi
  8041607794:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  804160779a:	49 8b 3f             	mov    (%r15),%rdi
  804160779d:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  80416077a4:	00 00 00 
  80416077a7:	ff d0                	callq  *%rax
  80416077a9:	eb c3                	jmp    804160776e <mem_init+0x24ba>
  pml4e = kern_pml4e;
  80416077ab:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  80416077b2:	00 00 00 
  80416077b5:	4c 8b 20             	mov    (%rax),%r12
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
  80416077b8:	48 a1 30 59 70 41 80 	movabs 0x8041705930,%rax
  80416077bf:	00 00 00 
  80416077c2:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  80416077c6:	48 c1 e0 04          	shl    $0x4,%rax
  80416077ca:	48 05 ff 0f 00 00    	add    $0xfff,%rax
  for (i = 0; i < n; i += PGSIZE) {
  80416077d0:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416077d6:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416077da:	74 6d                	je     8041607849 <mem_init+0x2595>
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  80416077dc:	48 a1 38 59 70 41 80 	movabs 0x8041705938,%rax
  80416077e3:	00 00 00 
  80416077e6:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  if ((uint64_t)kva < KERNBASE)
  80416077ea:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  return (physaddr_t)kva - KERNBASE;
  80416077ee:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  80416077f5:	ff ff ff 
  80416077f8:	49 01 c6             	add    %rax,%r14
  for (i = 0; i < n; i += PGSIZE) {
  80416077fb:	4c 89 eb             	mov    %r13,%rbx
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  80416077fe:	49 bf 00 e0 42 3c 80 	movabs $0x803c42e000,%r15
  8041607805:	00 00 00 
  8041607808:	4a 8d 34 3b          	lea    (%rbx,%r15,1),%rsi
  804160780c:	4c 89 e7             	mov    %r12,%rdi
  804160780f:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041607816:	00 00 00 
  8041607819:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  804160781b:	48 be ff ff ff 3f 80 	movabs $0x803fffffff,%rsi
  8041607822:	00 00 00 
  8041607825:	48 39 75 b0          	cmp    %rsi,-0x50(%rbp)
  8041607829:	0f 86 b0 01 00 00    	jbe    80416079df <mem_init+0x272b>
  804160782f:	49 8d 14 1e          	lea    (%r14,%rbx,1),%rdx
  8041607833:	48 39 c2             	cmp    %rax,%rdx
  8041607836:	0f 85 d2 01 00 00    	jne    8041607a0e <mem_init+0x275a>
  for (i = 0; i < n; i += PGSIZE) {
  804160783c:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  8041607843:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  8041607847:	77 bf                	ja     8041607808 <mem_init+0x2554>
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  8041607849:	48 b8 00 44 70 41 80 	movabs $0x8041704400,%rax
  8041607850:	00 00 00 
  8041607853:	48 8b 18             	mov    (%rax),%rbx
  return (physaddr_t)kva - KERNBASE;
  8041607856:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  804160785d:	ff ff ff 
  8041607860:	49 01 de             	add    %rbx,%r14
  8041607863:	48 be 00 e0 22 3c 80 	movabs $0x803c22e000,%rsi
  804160786a:	00 00 00 
  804160786d:	4c 89 e7             	mov    %r12,%rdi
  8041607870:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  8041607877:	00 00 00 
  804160787a:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  804160787c:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041607883:	00 00 00 
  8041607886:	48 39 d3             	cmp    %rdx,%rbx
  8041607889:	0f 86 b4 01 00 00    	jbe    8041607a43 <mem_init+0x278f>
  804160788f:	4c 39 f0             	cmp    %r14,%rax
  8041607892:	0f 85 d9 01 00 00    	jne    8041607a71 <mem_init+0x27bd>
  8041607898:	48 be 00 f0 22 3c 80 	movabs $0x803c22f000,%rsi
  804160789f:	00 00 00 
  80416078a2:	4c 89 e7             	mov    %r12,%rdi
  80416078a5:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  80416078ac:	00 00 00 
  80416078af:	ff d0                	callq  *%rax
  80416078b1:	48 ba 00 10 00 c0 7f 	movabs $0xffffff7fc0001000,%rdx
  80416078b8:	ff ff ff 
  80416078bb:	48 01 d3             	add    %rdx,%rbx
  80416078be:	48 39 d8             	cmp    %rbx,%rax
  80416078c1:	0f 85 aa 01 00 00    	jne    8041607a71 <mem_init+0x27bd>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  80416078c7:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416078cb:	48 c1 e0 0c          	shl    $0xc,%rax
  80416078cf:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416078d3:	0f 84 02 02 00 00    	je     8041607adb <mem_init+0x2827>
  80416078d9:	4c 89 eb             	mov    %r13,%rbx
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  80416078dc:	49 bf 00 00 00 40 80 	movabs $0x8040000000,%r15
  80416078e3:	00 00 00 
  80416078e6:	49 be 24 41 60 41 80 	movabs $0x8041604124,%r14
  80416078ed:	00 00 00 
  80416078f0:	4a 8d 34 3b          	lea    (%rbx,%r15,1),%rsi
  80416078f4:	4c 89 e7             	mov    %r12,%rdi
  80416078f7:	41 ff d6             	callq  *%r14
  80416078fa:	48 39 d8             	cmp    %rbx,%rax
  80416078fd:	0f 85 a3 01 00 00    	jne    8041607aa6 <mem_init+0x27f2>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607903:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  804160790a:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  804160790e:	77 e0                	ja     80416078f0 <mem_init+0x263c>
  8041607910:	48 bb 00 00 ff 3f 80 	movabs $0x803fff0000,%rbx
  8041607917:	00 00 00 
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  804160791a:	49 bf 24 41 60 41 80 	movabs $0x8041604124,%r15
  8041607921:	00 00 00 
  8041607924:	49 be 00 00 01 80 ff 	movabs $0xfffffeff80010000,%r14
  804160792b:	fe ff ff 
  804160792e:	48 b8 00 f0 60 41 80 	movabs $0x804160f000,%rax
  8041607935:	00 00 00 
  8041607938:	49 01 c6             	add    %rax,%r14
  804160793b:	48 89 de             	mov    %rbx,%rsi
  804160793e:	4c 89 e7             	mov    %r12,%rdi
  8041607941:	41 ff d7             	callq  *%r15
  8041607944:	49 8d 14 1e          	lea    (%r14,%rbx,1),%rdx
  8041607948:	48 39 c2             	cmp    %rax,%rdx
  804160794b:	0f 85 99 01 00 00    	jne    8041607aea <mem_init+0x2836>
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
  8041607951:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  8041607958:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160795f:	00 00 00 
  8041607962:	48 39 c3             	cmp    %rax,%rbx
  8041607965:	75 d4                	jne    804160793b <mem_init+0x2687>
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  8041607967:	48 be 00 00 e0 3f 80 	movabs $0x803fe00000,%rsi
  804160796e:	00 00 00 
  8041607971:	4c 89 e7             	mov    %r12,%rdi
  8041607974:	48 b8 24 41 60 41 80 	movabs $0x8041604124,%rax
  804160797b:	00 00 00 
  804160797e:	ff d0                	callq  *%rax
  8041607980:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041607984:	0f 85 95 01 00 00    	jne    8041607b1f <mem_init+0x286b>
  pdpe_t *pdpe = KADDR(PTE_ADDR(kern_pml4e[1]));
  804160798a:	49 8b 4c 24 08       	mov    0x8(%r12),%rcx
  804160798f:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041607996:	48 89 c8             	mov    %rcx,%rax
  8041607999:	48 c1 e8 0c          	shr    $0xc,%rax
  804160799d:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  80416079a1:	0f 86 ad 01 00 00    	jbe    8041607b54 <mem_init+0x28a0>
  pde_t *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  80416079a7:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416079ae:	00 00 00 
  80416079b1:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  80416079b5:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416079bc:	48 89 c8             	mov    %rcx,%rax
  80416079bf:	48 c1 e8 0c          	shr    $0xc,%rax
  80416079c3:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  80416079c7:	0f 86 b2 01 00 00    	jbe    8041607b7f <mem_init+0x28cb>
  return (void *)(pa + KERNBASE);
  80416079cd:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416079d4:	00 00 00 
  80416079d7:	48 01 c1             	add    %rax,%rcx
  for (i = 0; i < NPDENTRIES; i++) {
  80416079da:	e9 ee 01 00 00       	jmpq   8041607bcd <mem_init+0x2919>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416079df:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  80416079e3:	48 ba 38 c7 60 41 80 	movabs $0x804160c738,%rdx
  80416079ea:	00 00 00 
  80416079ed:	be 24 04 00 00       	mov    $0x424,%esi
  80416079f2:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416079f9:	00 00 00 
  80416079fc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a01:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a08:	00 00 00 
  8041607a0b:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  8041607a0e:	48 b9 80 ce 60 41 80 	movabs $0x804160ce80,%rcx
  8041607a15:	00 00 00 
  8041607a18:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607a1f:	00 00 00 
  8041607a22:	be 24 04 00 00       	mov    $0x424,%esi
  8041607a27:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607a2e:	00 00 00 
  8041607a31:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a36:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a3d:	00 00 00 
  8041607a40:	41 ff d0             	callq  *%r8
  8041607a43:	48 89 d9             	mov    %rbx,%rcx
  8041607a46:	48 ba 38 c7 60 41 80 	movabs $0x804160c738,%rdx
  8041607a4d:	00 00 00 
  8041607a50:	be 2a 04 00 00       	mov    $0x42a,%esi
  8041607a55:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607a5c:	00 00 00 
  8041607a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a64:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a6b:	00 00 00 
  8041607a6e:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  8041607a71:	48 b9 b8 ce 60 41 80 	movabs $0x804160ceb8,%rcx
  8041607a78:	00 00 00 
  8041607a7b:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607a82:	00 00 00 
  8041607a85:	be 2a 04 00 00       	mov    $0x42a,%esi
  8041607a8a:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607a91:	00 00 00 
  8041607a94:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a99:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607aa0:	00 00 00 
  8041607aa3:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  8041607aa6:	48 b9 f0 ce 60 41 80 	movabs $0x804160cef0,%rcx
  8041607aad:	00 00 00 
  8041607ab0:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607ab7:	00 00 00 
  8041607aba:	be 2e 04 00 00       	mov    $0x42e,%esi
  8041607abf:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607ac6:	00 00 00 
  8041607ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ace:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607ad5:	00 00 00 
  8041607ad8:	41 ff d0             	callq  *%r8
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607adb:	48 bb 00 00 ff 3f 80 	movabs $0x803fff0000,%rbx
  8041607ae2:	00 00 00 
  8041607ae5:	e9 30 fe ff ff       	jmpq   804160791a <mem_init+0x2666>
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8041607aea:	48 b9 18 cf 60 41 80 	movabs $0x804160cf18,%rcx
  8041607af1:	00 00 00 
  8041607af4:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607afb:	00 00 00 
  8041607afe:	be 32 04 00 00       	mov    $0x432,%esi
  8041607b03:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607b0a:	00 00 00 
  8041607b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b12:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b19:	00 00 00 
  8041607b1c:	41 ff d0             	callq  *%r8
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  8041607b1f:	48 b9 60 cf 60 41 80 	movabs $0x804160cf60,%rcx
  8041607b26:	00 00 00 
  8041607b29:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607b30:	00 00 00 
  8041607b33:	be 34 04 00 00       	mov    $0x434,%esi
  8041607b38:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607b3f:	00 00 00 
  8041607b42:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b47:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b4e:	00 00 00 
  8041607b51:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041607b54:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041607b5b:	00 00 00 
  8041607b5e:	be 36 04 00 00       	mov    $0x436,%esi
  8041607b63:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607b6a:	00 00 00 
  8041607b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b72:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b79:	00 00 00 
  8041607b7c:	41 ff d0             	callq  *%r8
  8041607b7f:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041607b86:	00 00 00 
  8041607b89:	be 37 04 00 00       	mov    $0x437,%esi
  8041607b8e:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607b95:	00 00 00 
  8041607b98:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b9d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607ba4:	00 00 00 
  8041607ba7:	41 ff d0             	callq  *%r8
    switch (i) {
  8041607baa:	49 81 fd 00 00 08 00 	cmp    $0x80000,%r13
  8041607bb1:	75 32                	jne    8041607be5 <mem_init+0x2931>
        assert(pgdir[i] & PTE_P);
  8041607bb3:	f6 01 01             	testb  $0x1,(%rcx)
  8041607bb6:	74 7a                	je     8041607c32 <mem_init+0x297e>
  for (i = 0; i < NPDENTRIES; i++) {
  8041607bb8:	49 83 c5 01          	add    $0x1,%r13
  8041607bbc:	48 83 c1 08          	add    $0x8,%rcx
  8041607bc0:	49 81 fd 00 02 00 00 	cmp    $0x200,%r13
  8041607bc7:	0f 84 d8 00 00 00    	je     8041607ca5 <mem_init+0x29f1>
    switch (i) {
  8041607bcd:	49 81 fd ff 01 04 00 	cmp    $0x401ff,%r13
  8041607bd4:	74 dd                	je     8041607bb3 <mem_init+0x28ff>
  8041607bd6:	77 d2                	ja     8041607baa <mem_init+0x28f6>
  8041607bd8:	49 8d 85 1f fe fb ff 	lea    -0x401e1(%r13),%rax
  8041607bdf:	48 83 f8 01          	cmp    $0x1,%rax
  8041607be3:	76 ce                	jbe    8041607bb3 <mem_init+0x28ff>
        if (i >= VPD(KERNBASE)) {
  8041607be5:	49 81 fd ff 01 04 00 	cmp    $0x401ff,%r13
  8041607bec:	76 ca                	jbe    8041607bb8 <mem_init+0x2904>
          if (pgdir[i] & PTE_P)
  8041607bee:	48 8b 01             	mov    (%rcx),%rax
  8041607bf1:	a8 01                	test   $0x1,%al
  8041607bf3:	74 72                	je     8041607c67 <mem_init+0x29b3>
            assert(pgdir[i] & PTE_W);
  8041607bf5:	a8 02                	test   $0x2,%al
  8041607bf7:	0f 85 4a 07 00 00    	jne    8041608347 <mem_init+0x3093>
  8041607bfd:	48 b9 02 d4 60 41 80 	movabs $0x804160d402,%rcx
  8041607c04:	00 00 00 
  8041607c07:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607c0e:	00 00 00 
  8041607c11:	be 44 04 00 00       	mov    $0x444,%esi
  8041607c16:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607c1d:	00 00 00 
  8041607c20:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c25:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607c2c:	00 00 00 
  8041607c2f:	41 ff d0             	callq  *%r8
        assert(pgdir[i] & PTE_P);
  8041607c32:	48 b9 f1 d3 60 41 80 	movabs $0x804160d3f1,%rcx
  8041607c39:	00 00 00 
  8041607c3c:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607c43:	00 00 00 
  8041607c46:	be 3f 04 00 00       	mov    $0x43f,%esi
  8041607c4b:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607c52:	00 00 00 
  8041607c55:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c5a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607c61:	00 00 00 
  8041607c64:	41 ff d0             	callq  *%r8
            assert(pgdir[i] == 0);
  8041607c67:	48 85 c0             	test   %rax,%rax
  8041607c6a:	0f 84 d7 06 00 00    	je     8041608347 <mem_init+0x3093>
  8041607c70:	48 b9 13 d4 60 41 80 	movabs $0x804160d413,%rcx
  8041607c77:	00 00 00 
  8041607c7a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041607c81:	00 00 00 
  8041607c84:	be 46 04 00 00       	mov    $0x446,%esi
  8041607c89:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041607c90:	00 00 00 
  8041607c93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c98:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607c9f:	00 00 00 
  8041607ca2:	41 ff d0             	callq  *%r8
  cprintf("check_kern_pml4e() succeeded!\n");
  8041607ca5:	48 bf 90 cf 60 41 80 	movabs $0x804160cf90,%rdi
  8041607cac:	00 00 00 
  8041607caf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607cb4:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041607cbb:	00 00 00 
  8041607cbe:	ff d2                	callq  *%rdx
  mmap_base = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)uefi_lp->MemoryMapVirt;
  8041607cc0:	48 b9 00 f0 61 41 80 	movabs $0x804161f000,%rcx
  8041607cc7:	00 00 00 
  8041607cca:	48 8b 11             	mov    (%rcx),%rdx
  8041607ccd:	48 8b 42 30          	mov    0x30(%rdx),%rax
  8041607cd1:	48 a3 d0 43 70 41 80 	movabs %rax,0x80417043d0
  8041607cd8:	00 00 00 
  mmap_end  = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)uefi_lp->MemoryMapVirt + uefi_lp->MemoryMapSize);
  8041607cdb:	48 03 42 38          	add    0x38(%rdx),%rax
  8041607cdf:	48 a3 c8 43 70 41 80 	movabs %rax,0x80417043c8
  8041607ce6:	00 00 00 
  uefi_lp   = (LOADER_PARAMS *)uefi_lp->SelfVirtual;
  8041607ce9:	48 8b 12             	mov    (%rdx),%rdx
  8041607cec:	48 89 11             	mov    %rdx,(%rcx)
  __asm __volatile("movq %0,%%cr3"
  8041607cef:	48 a1 28 59 70 41 80 	movabs 0x8041705928,%rax
  8041607cf6:	00 00 00 
  8041607cf9:	0f 22 d8             	mov    %rax,%cr3
  __asm __volatile("movq %%cr0,%0"
  8041607cfc:	0f 20 c0             	mov    %cr0,%rax
    cr0 &= ~(CR0_TS | CR0_EM);
  8041607cff:	48 83 e0 f3          	and    $0xfffffffffffffff3,%rax
  8041607d03:	b9 23 00 05 80       	mov    $0x80050023,%ecx
  8041607d08:	48 09 c8             	or     %rcx,%rax
  __asm __volatile("movq %0,%%cr0"
  8041607d0b:	0f 22 c0             	mov    %rax,%cr0
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607d0e:	48 8b 4a 40          	mov    0x40(%rdx),%rcx
  uintptr_t size     = lp->FrameBufferSize;
  8041607d12:	8b 52 48             	mov    0x48(%rdx),%edx
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607d15:	48 bb 20 59 70 41 80 	movabs $0x8041705920,%rbx
  8041607d1c:	00 00 00 
  8041607d1f:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041607d25:	48 be 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rsi
  8041607d2c:	00 00 00 
  8041607d2f:	48 8b 3b             	mov    (%rbx),%rdi
  8041607d32:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  8041607d39:	00 00 00 
  8041607d3c:	ff d0                	callq  *%rax
check_page_installed_pml4(void) {
  struct PageInfo *pp0, *pp1, *pp2;
  pml4e_t pml4e_old; //used to store value instead of pointer

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041607d3e:	48 8b 03             	mov    (%rbx),%rax
  8041607d41:	4c 8b 30             	mov    (%rax),%r14
  kern_pml4e[0] = 0;
  8041607d44:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  8041607d4b:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607d50:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041607d57:	00 00 00 
  8041607d5a:	ff d0                	callq  *%rax
  8041607d5c:	48 89 c3             	mov    %rax,%rbx
  8041607d5f:	48 85 c0             	test   %rax,%rax
  8041607d62:	0f 84 aa 02 00 00    	je     8041608012 <mem_init+0x2d5e>
  assert((pp1 = page_alloc(0)));
  8041607d68:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607d6d:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041607d74:	00 00 00 
  8041607d77:	ff d0                	callq  *%rax
  8041607d79:	49 89 c5             	mov    %rax,%r13
  8041607d7c:	48 85 c0             	test   %rax,%rax
  8041607d7f:	0f 84 c2 02 00 00    	je     8041608047 <mem_init+0x2d93>
  assert((pp2 = page_alloc(0)));
  8041607d85:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607d8a:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  8041607d91:	00 00 00 
  8041607d94:	ff d0                	callq  *%rax
  8041607d96:	49 89 c4             	mov    %rax,%r12
  8041607d99:	48 85 c0             	test   %rax,%rax
  8041607d9c:	0f 84 da 02 00 00    	je     804160807c <mem_init+0x2dc8>
  page_free(pp0);
  8041607da2:	48 89 df             	mov    %rbx,%rdi
  8041607da5:	48 b8 44 4b 60 41 80 	movabs $0x8041604b44,%rax
  8041607dac:	00 00 00 
  8041607daf:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607db1:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041607db8:	00 00 00 
  8041607dbb:	4c 89 e9             	mov    %r13,%rcx
  8041607dbe:	48 2b 08             	sub    (%rax),%rcx
  8041607dc1:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607dc5:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607dc9:	48 89 ca             	mov    %rcx,%rdx
  8041607dcc:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607dd0:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041607dd7:	00 00 00 
  8041607dda:	48 3b 10             	cmp    (%rax),%rdx
  8041607ddd:	0f 83 ce 02 00 00    	jae    80416080b1 <mem_init+0x2dfd>
  return (void *)(pa + KERNBASE);
  8041607de3:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607dea:	00 00 00 
  8041607ded:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp1), 1, PGSIZE);
  8041607df0:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607df5:	be 01 00 00 00       	mov    $0x1,%esi
  8041607dfa:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041607e01:	00 00 00 
  8041607e04:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607e06:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041607e0d:	00 00 00 
  8041607e10:	4c 89 e1             	mov    %r12,%rcx
  8041607e13:	48 2b 08             	sub    (%rax),%rcx
  8041607e16:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607e1a:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607e1e:	48 89 ca             	mov    %rcx,%rdx
  8041607e21:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607e25:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041607e2c:	00 00 00 
  8041607e2f:	48 3b 10             	cmp    (%rax),%rdx
  8041607e32:	0f 83 a4 02 00 00    	jae    80416080dc <mem_init+0x2e28>
  return (void *)(pa + KERNBASE);
  8041607e38:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607e3f:	00 00 00 
  8041607e42:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp2), 2, PGSIZE);
  8041607e45:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607e4a:	be 02 00 00 00       	mov    $0x2,%esi
  8041607e4f:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041607e56:	00 00 00 
  8041607e59:	ff d0                	callq  *%rax
  page_insert(kern_pml4e, pp1, (void *)PGSIZE, PTE_W);
  8041607e5b:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607e60:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607e65:	4c 89 ee             	mov    %r13,%rsi
  8041607e68:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041607e6f:	00 00 00 
  8041607e72:	48 8b 38             	mov    (%rax),%rdi
  8041607e75:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  8041607e7c:	00 00 00 
  8041607e7f:	ff d0                	callq  *%rax
  assert(pp1->pp_ref == 1);
  8041607e81:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041607e87:	0f 85 7a 02 00 00    	jne    8041608107 <mem_init+0x2e53>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041607e8d:	81 3c 25 00 10 00 00 	cmpl   $0x1010101,0x1000
  8041607e94:	01 01 01 01 
  8041607e98:	0f 85 9e 02 00 00    	jne    804160813c <mem_init+0x2e88>
  page_insert(kern_pml4e, pp2, (void *)PGSIZE, PTE_W);
  8041607e9e:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607ea3:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607ea8:	4c 89 e6             	mov    %r12,%rsi
  8041607eab:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041607eb2:	00 00 00 
  8041607eb5:	48 8b 38             	mov    (%rax),%rdi
  8041607eb8:	48 b8 83 51 60 41 80 	movabs $0x8041605183,%rax
  8041607ebf:	00 00 00 
  8041607ec2:	ff d0                	callq  *%rax
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  8041607ec4:	81 3c 25 00 10 00 00 	cmpl   $0x2020202,0x1000
  8041607ecb:	02 02 02 02 
  8041607ecf:	0f 85 9c 02 00 00    	jne    8041608171 <mem_init+0x2ebd>
  assert(pp2->pp_ref == 1);
  8041607ed5:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041607edc:	0f 85 c4 02 00 00    	jne    80416081a6 <mem_init+0x2ef2>
  assert(pp1->pp_ref == 0);
  8041607ee2:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041607ee8:	0f 85 ed 02 00 00    	jne    80416081db <mem_init+0x2f27>
  *(uint32_t *)PGSIZE = 0x03030303U;
  8041607eee:	c7 04 25 00 10 00 00 	movl   $0x3030303,0x1000
  8041607ef5:	03 03 03 03 
  return (pp - pages) << PGSHIFT;
  8041607ef9:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041607f00:	00 00 00 
  8041607f03:	4c 89 e1             	mov    %r12,%rcx
  8041607f06:	48 2b 08             	sub    (%rax),%rcx
  8041607f09:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607f0d:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607f11:	48 89 ca             	mov    %rcx,%rdx
  8041607f14:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607f18:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041607f1f:	00 00 00 
  8041607f22:	48 3b 10             	cmp    (%rax),%rdx
  8041607f25:	0f 83 e5 02 00 00    	jae    8041608210 <mem_init+0x2f5c>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  8041607f2b:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607f32:	00 00 00 
  8041607f35:	81 3c 01 03 03 03 03 	cmpl   $0x3030303,(%rcx,%rax,1)
  8041607f3c:	0f 85 f9 02 00 00    	jne    804160823b <mem_init+0x2f87>
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041607f42:	be 00 10 00 00       	mov    $0x1000,%esi
  8041607f47:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041607f4e:	00 00 00 
  8041607f51:	48 8b 38             	mov    (%rax),%rdi
  8041607f54:	48 b8 28 51 60 41 80 	movabs $0x8041605128,%rax
  8041607f5b:	00 00 00 
  8041607f5e:	ff d0                	callq  *%rax
  assert(pp2->pp_ref == 0);
  8041607f60:	66 41 83 7c 24 08 00 	cmpw   $0x0,0x8(%r12)
  8041607f67:	0f 85 03 03 00 00    	jne    8041608270 <mem_init+0x2fbc>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  8041607f6d:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  8041607f74:	00 00 00 
  8041607f77:	48 8b 08             	mov    (%rax),%rcx
  8041607f7a:	48 8b 11             	mov    (%rcx),%rdx
  8041607f7d:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041607f84:	48 b8 38 59 70 41 80 	movabs $0x8041705938,%rax
  8041607f8b:	00 00 00 
  8041607f8e:	48 89 df             	mov    %rbx,%rdi
  8041607f91:	48 2b 38             	sub    (%rax),%rdi
  8041607f94:	48 89 f8             	mov    %rdi,%rax
  8041607f97:	48 c1 f8 04          	sar    $0x4,%rax
  8041607f9b:	48 c1 e0 0c          	shl    $0xc,%rax
  8041607f9f:	48 39 c2             	cmp    %rax,%rdx
  8041607fa2:	0f 85 fd 02 00 00    	jne    80416082a5 <mem_init+0x2ff1>
  kern_pml4e[0] = 0;
  8041607fa8:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  assert(pp0->pp_ref == 1);
  8041607faf:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041607fb4:	0f 85 20 03 00 00    	jne    80416082da <mem_init+0x3026>
  pp0->pp_ref = 0;
  8041607fba:	66 c7 43 08 00 00    	movw   $0x0,0x8(%rbx)

  // free the pages we took
  page_free(pp0);
  8041607fc0:	48 89 df             	mov    %rbx,%rdi
  8041607fc3:	48 b8 44 4b 60 41 80 	movabs $0x8041604b44,%rax
  8041607fca:	00 00 00 
  8041607fcd:	ff d0                	callq  *%rax

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041607fcf:	48 a1 20 59 70 41 80 	movabs 0x8041705920,%rax
  8041607fd6:	00 00 00 
  8041607fd9:	4c 89 30             	mov    %r14,(%rax)

  cprintf("check_page_installed_pml4() succeeded!\n");
  8041607fdc:	48 bf 58 d0 60 41 80 	movabs $0x804160d058,%rdi
  8041607fe3:	00 00 00 
  8041607fe6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607feb:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041607ff2:	00 00 00 
  8041607ff5:	ff d2                	callq  *%rdx
  struct PageInfo *pp = page_free_list, *pt = NULL;
  8041607ff7:	48 b8 e8 43 70 41 80 	movabs $0x80417043e8,%rax
  8041607ffe:	00 00 00 
  8041608001:	48 8b 10             	mov    (%rax),%rdx
  while (pp) {
  8041608004:	48 85 d2             	test   %rdx,%rdx
  8041608007:	0f 85 05 03 00 00    	jne    8041608312 <mem_init+0x305e>
  804160800d:	e9 08 03 00 00       	jmpq   804160831a <mem_init+0x3066>
  assert((pp0 = page_alloc(0)));
  8041608012:	48 b9 6c d3 60 41 80 	movabs $0x804160d36c,%rcx
  8041608019:	00 00 00 
  804160801c:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041608023:	00 00 00 
  8041608026:	be 34 05 00 00       	mov    $0x534,%esi
  804160802b:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041608032:	00 00 00 
  8041608035:	b8 00 00 00 00       	mov    $0x0,%eax
  804160803a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608041:	00 00 00 
  8041608044:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041608047:	48 b9 82 d3 60 41 80 	movabs $0x804160d382,%rcx
  804160804e:	00 00 00 
  8041608051:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041608058:	00 00 00 
  804160805b:	be 35 05 00 00       	mov    $0x535,%esi
  8041608060:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041608067:	00 00 00 
  804160806a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160806f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608076:	00 00 00 
  8041608079:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  804160807c:	48 b9 98 d3 60 41 80 	movabs $0x804160d398,%rcx
  8041608083:	00 00 00 
  8041608086:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160808d:	00 00 00 
  8041608090:	be 36 05 00 00       	mov    $0x536,%esi
  8041608095:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160809c:	00 00 00 
  804160809f:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080a4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080ab:	00 00 00 
  80416080ae:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416080b1:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  80416080b8:	00 00 00 
  80416080bb:	be 63 00 00 00       	mov    $0x63,%esi
  80416080c0:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  80416080c7:	00 00 00 
  80416080ca:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080cf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080d6:	00 00 00 
  80416080d9:	41 ff d0             	callq  *%r8
  80416080dc:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  80416080e3:	00 00 00 
  80416080e6:	be 63 00 00 00       	mov    $0x63,%esi
  80416080eb:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  80416080f2:	00 00 00 
  80416080f5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080fa:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608101:	00 00 00 
  8041608104:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041608107:	48 b9 7d d2 60 41 80 	movabs $0x804160d27d,%rcx
  804160810e:	00 00 00 
  8041608111:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041608118:	00 00 00 
  804160811b:	be 3b 05 00 00       	mov    $0x53b,%esi
  8041608120:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041608127:	00 00 00 
  804160812a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160812f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608136:	00 00 00 
  8041608139:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  804160813c:	48 b9 b0 cf 60 41 80 	movabs $0x804160cfb0,%rcx
  8041608143:	00 00 00 
  8041608146:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160814d:	00 00 00 
  8041608150:	be 3c 05 00 00       	mov    $0x53c,%esi
  8041608155:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160815c:	00 00 00 
  804160815f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608164:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160816b:	00 00 00 
  804160816e:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  8041608171:	48 b9 d8 cf 60 41 80 	movabs $0x804160cfd8,%rcx
  8041608178:	00 00 00 
  804160817b:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041608182:	00 00 00 
  8041608185:	be 3e 05 00 00       	mov    $0x53e,%esi
  804160818a:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041608191:	00 00 00 
  8041608194:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608199:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081a0:	00 00 00 
  80416081a3:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 1);
  80416081a6:	48 b9 21 d4 60 41 80 	movabs $0x804160d421,%rcx
  80416081ad:	00 00 00 
  80416081b0:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416081b7:	00 00 00 
  80416081ba:	be 3f 05 00 00       	mov    $0x53f,%esi
  80416081bf:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416081c6:	00 00 00 
  80416081c9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081ce:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081d5:	00 00 00 
  80416081d8:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  80416081db:	48 b9 f8 d2 60 41 80 	movabs $0x804160d2f8,%rcx
  80416081e2:	00 00 00 
  80416081e5:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416081ec:	00 00 00 
  80416081ef:	be 40 05 00 00       	mov    $0x540,%esi
  80416081f4:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416081fb:	00 00 00 
  80416081fe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608203:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160820a:	00 00 00 
  804160820d:	41 ff d0             	callq  *%r8
  8041608210:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041608217:	00 00 00 
  804160821a:	be 63 00 00 00       	mov    $0x63,%esi
  804160821f:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041608226:	00 00 00 
  8041608229:	b8 00 00 00 00       	mov    $0x0,%eax
  804160822e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608235:	00 00 00 
  8041608238:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  804160823b:	48 b9 00 d0 60 41 80 	movabs $0x804160d000,%rcx
  8041608242:	00 00 00 
  8041608245:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  804160824c:	00 00 00 
  804160824f:	be 42 05 00 00       	mov    $0x542,%esi
  8041608254:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  804160825b:	00 00 00 
  804160825e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608263:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160826a:	00 00 00 
  804160826d:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 0);
  8041608270:	48 b9 32 d4 60 41 80 	movabs $0x804160d432,%rcx
  8041608277:	00 00 00 
  804160827a:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041608281:	00 00 00 
  8041608284:	be 44 05 00 00       	mov    $0x544,%esi
  8041608289:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041608290:	00 00 00 
  8041608293:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608298:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160829f:	00 00 00 
  80416082a2:	41 ff d0             	callq  *%r8
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  80416082a5:	48 b9 30 d0 60 41 80 	movabs $0x804160d030,%rcx
  80416082ac:	00 00 00 
  80416082af:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416082b6:	00 00 00 
  80416082b9:	be 47 05 00 00       	mov    $0x547,%esi
  80416082be:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416082c5:	00 00 00 
  80416082c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416082cd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416082d4:	00 00 00 
  80416082d7:	41 ff d0             	callq  *%r8
  assert(pp0->pp_ref == 1);
  80416082da:	48 b9 43 d4 60 41 80 	movabs $0x804160d443,%rcx
  80416082e1:	00 00 00 
  80416082e4:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  80416082eb:	00 00 00 
  80416082ee:	be 49 05 00 00       	mov    $0x549,%esi
  80416082f3:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416082fa:	00 00 00 
  80416082fd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608302:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608309:	00 00 00 
  804160830c:	41 ff d0             	callq  *%r8
    pp = pp->pp_link;
  804160830f:	48 89 c2             	mov    %rax,%rdx
  8041608312:	48 8b 02             	mov    (%rdx),%rax
  while (pp) {
  8041608315:	48 85 c0             	test   %rax,%rax
  8041608318:	75 f5                	jne    804160830f <mem_init+0x305b>
  page_free_list_top = evaluate_page_free_list_top();
  804160831a:	48 89 d0             	mov    %rdx,%rax
  804160831d:	48 a3 e0 43 70 41 80 	movabs %rax,0x80417043e0
  8041608324:	00 00 00 
  check_page_free_list(0);
  8041608327:	bf 00 00 00 00       	mov    $0x0,%edi
  804160832c:	48 b8 93 43 60 41 80 	movabs $0x8041604393,%rax
  8041608333:	00 00 00 
  8041608336:	ff d0                	callq  *%rax
}
  8041608338:	48 83 c4 38          	add    $0x38,%rsp
  804160833c:	5b                   	pop    %rbx
  804160833d:	41 5c                	pop    %r12
  804160833f:	41 5d                	pop    %r13
  8041608341:	41 5e                	pop    %r14
  8041608343:	41 5f                	pop    %r15
  8041608345:	5d                   	pop    %rbp
  8041608346:	c3                   	retq   
  for (i = 0; i < NPDENTRIES; i++) {
  8041608347:	49 83 c5 01          	add    $0x1,%r13
  804160834b:	48 83 c1 08          	add    $0x8,%rcx
  804160834f:	e9 79 f8 ff ff       	jmpq   8041607bcd <mem_init+0x2919>

0000008041608354 <mmio_map_region>:
mmio_map_region(physaddr_t pa, size_t size) {
  8041608354:	55                   	push   %rbp
  8041608355:	48 89 e5             	mov    %rsp,%rbp
  8041608358:	53                   	push   %rbx
  8041608359:	48 83 ec 08          	sub    $0x8,%rsp
  uintptr_t pa2 = ROUNDDOWN(pa, PGSIZE);
  804160835d:	48 89 f9             	mov    %rdi,%rcx
  8041608360:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (base + size >= MMIOLIM)
  8041608367:	48 a1 20 f7 61 41 80 	movabs 0x804161f720,%rax
  804160836e:	00 00 00 
  8041608371:	4c 8d 04 30          	lea    (%rax,%rsi,1),%r8
  8041608375:	48 ba ff ff df 3f 80 	movabs $0x803fdfffff,%rdx
  804160837c:	00 00 00 
  804160837f:	49 39 d0             	cmp    %rdx,%r8
  8041608382:	77 54                	ja     80416083d8 <mmio_map_region+0x84>
  size = ROUNDUP(size + (pa - pa2), PGSIZE);
  8041608384:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
  804160838a:	48 8d 9c 3e ff 0f 00 	lea    0xfff(%rsi,%rdi,1),%rbx
  8041608391:	00 
  8041608392:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  boot_map_region(kern_pml4e, base, size, pa2, PTE_PCD | PTE_PWT | PTE_W);
  8041608399:	41 b8 1a 00 00 00    	mov    $0x1a,%r8d
  804160839f:	48 89 da             	mov    %rbx,%rdx
  80416083a2:	48 89 c6             	mov    %rax,%rsi
  80416083a5:	48 b8 20 59 70 41 80 	movabs $0x8041705920,%rax
  80416083ac:	00 00 00 
  80416083af:	48 8b 38             	mov    (%rax),%rdi
  80416083b2:	48 b8 ea 4f 60 41 80 	movabs $0x8041604fea,%rax
  80416083b9:	00 00 00 
  80416083bc:	ff d0                	callq  *%rax
  void *new = (void *)base;
  80416083be:	48 ba 20 f7 61 41 80 	movabs $0x804161f720,%rdx
  80416083c5:	00 00 00 
  80416083c8:	48 8b 02             	mov    (%rdx),%rax
  base += size;
  80416083cb:	48 01 c3             	add    %rax,%rbx
  80416083ce:	48 89 1a             	mov    %rbx,(%rdx)
}
  80416083d1:	48 83 c4 08          	add    $0x8,%rsp
  80416083d5:	5b                   	pop    %rbx
  80416083d6:	5d                   	pop    %rbp
  80416083d7:	c3                   	retq   
    panic("Allocated MMIO addr is too damn high! [0x%016lu;0x%016lu]", pa, pa + size);
  80416083d8:	4c 8d 04 37          	lea    (%rdi,%rsi,1),%r8
  80416083dc:	48 89 f9             	mov    %rdi,%rcx
  80416083df:	48 ba 80 d0 60 41 80 	movabs $0x804160d080,%rdx
  80416083e6:	00 00 00 
  80416083e9:	be 3f 03 00 00       	mov    $0x33f,%esi
  80416083ee:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  80416083f5:	00 00 00 
  80416083f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416083fd:	49 b9 5a 02 60 41 80 	movabs $0x804160025a,%r9
  8041608404:	00 00 00 
  8041608407:	41 ff d1             	callq  *%r9

000000804160840a <mmio_remap_last_region>:
mmio_remap_last_region(physaddr_t pa, void *addr, size_t oldsize, size_t newsize) {
  804160840a:	55                   	push   %rbp
  804160840b:	48 89 e5             	mov    %rsp,%rbp
  if (base - oldsize != (uintptr_t)addr)
  804160840e:	48 a1 20 f7 61 41 80 	movabs 0x804161f720,%rax
  8041608415:	00 00 00 
  8041608418:	4c 8d 04 06          	lea    (%rsi,%rax,1),%r8
  oldsize               = ROUNDUP((uintptr_t)addr + oldsize, PGSIZE) - (uintptr_t)addr;
  804160841c:	48 8d 84 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%rax
  8041608423:	00 
  if (base - oldsize != (uintptr_t)addr)
  8041608424:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160842a:	49 29 c0             	sub    %rax,%r8
  804160842d:	4c 39 c6             	cmp    %r8,%rsi
  8041608430:	75 1e                	jne    8041608450 <mmio_remap_last_region+0x46>
  base = (uintptr_t)addr;
  8041608432:	48 89 f0             	mov    %rsi,%rax
  8041608435:	48 a3 20 f7 61 41 80 	movabs %rax,0x804161f720
  804160843c:	00 00 00 
  return mmio_map_region(pa, newsize);
  804160843f:	48 89 ce             	mov    %rcx,%rsi
  8041608442:	48 b8 54 83 60 41 80 	movabs $0x8041608354,%rax
  8041608449:	00 00 00 
  804160844c:	ff d0                	callq  *%rax
}
  804160844e:	5d                   	pop    %rbp
  804160844f:	c3                   	retq   
    panic("You dare to remap non-last region?!");
  8041608450:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  8041608457:	00 00 00 
  804160845a:	be 4e 03 00 00       	mov    $0x34e,%esi
  804160845f:	48 bf e4 d0 60 41 80 	movabs $0x804160d0e4,%rdi
  8041608466:	00 00 00 
  8041608469:	b8 00 00 00 00       	mov    $0x0,%eax
  804160846e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608475:	00 00 00 
  8041608478:	ff d1                	callq  *%rcx

000000804160847a <user_mem_check>:
}
  804160847a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160847f:	c3                   	retq   

0000008041608480 <user_mem_assert>:
}
  8041608480:	c3                   	retq   

0000008041608481 <envid2env>:
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
  8041608481:	85 ff                	test   %edi,%edi
  8041608483:	74 5e                	je     80416084e3 <envid2env+0x62>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  8041608485:	89 f9                	mov    %edi,%ecx
  8041608487:	83 e1 1f             	and    $0x1f,%ecx
  804160848a:	48 89 c8             	mov    %rcx,%rax
  804160848d:	48 c1 e0 05          	shl    $0x5,%rax
  8041608491:	48 29 c8             	sub    %rcx,%rax
  8041608494:	48 b9 00 44 70 41 80 	movabs $0x8041704400,%rcx
  804160849b:	00 00 00 
  804160849e:	48 8b 09             	mov    (%rcx),%rcx
  80416084a1:	48 8d 04 c1          	lea    (%rcx,%rax,8),%rax
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  80416084a5:	83 b8 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rax)
  80416084ac:	74 45                	je     80416084f3 <envid2env+0x72>
  80416084ae:	39 b8 c8 00 00 00    	cmp    %edi,0xc8(%rax)
  80416084b4:	75 3d                	jne    80416084f3 <envid2env+0x72>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  80416084b6:	84 d2                	test   %dl,%dl
  80416084b8:	74 20                	je     80416084da <envid2env+0x59>
  80416084ba:	48 ba f8 43 70 41 80 	movabs $0x80417043f8,%rdx
  80416084c1:	00 00 00 
  80416084c4:	48 8b 12             	mov    (%rdx),%rdx
  80416084c7:	48 39 c2             	cmp    %rax,%rdx
  80416084ca:	74 0e                	je     80416084da <envid2env+0x59>
  80416084cc:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  80416084d2:	39 90 cc 00 00 00    	cmp    %edx,0xcc(%rax)
  80416084d8:	75 26                	jne    8041608500 <envid2env+0x7f>
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  80416084da:	48 89 06             	mov    %rax,(%rsi)
  return 0;
  80416084dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416084e2:	c3                   	retq   
    *env_store = curenv;
  80416084e3:	48 a1 f8 43 70 41 80 	movabs 0x80417043f8,%rax
  80416084ea:	00 00 00 
  80416084ed:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  80416084f0:	89 f8                	mov    %edi,%eax
  80416084f2:	c3                   	retq   
    *env_store = 0;
  80416084f3:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416084fa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  80416084ff:	c3                   	retq   
    *env_store = 0;
  8041608500:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041608507:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  804160850c:	c3                   	retq   

000000804160850d <env_init_percpu>:
  env_init_percpu();
}

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  804160850d:	55                   	push   %rbp
  804160850e:	48 89 e5             	mov    %rsp,%rbp
  8041608511:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  8041608512:	48 b8 40 f7 61 41 80 	movabs $0x804161f740,%rax
  8041608519:	00 00 00 
  804160851c:	0f 01 10             	lgdt   (%rax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  804160851f:	b8 33 00 00 00       	mov    $0x33,%eax
  8041608524:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  8041608526:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  8041608528:	b8 10 00 00 00       	mov    $0x10,%eax
  804160852d:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  804160852f:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041608531:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  8041608533:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041608538:	53                   	push   %rbx
  8041608539:	48 b8 46 85 60 41 80 	movabs $0x8041608546,%rax
  8041608540:	00 00 00 
  8041608543:	50                   	push   %rax
  8041608544:	48 cb                	lretq  
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  8041608546:	66 b8 00 00          	mov    $0x0,%ax
  804160854a:	0f 00 d0             	lldt   %ax
               :
               :
               : "cc", "memory");
}
  804160854d:	5b                   	pop    %rbx
  804160854e:	5d                   	pop    %rbp
  804160854f:	c3                   	retq   

0000008041608550 <env_init>:
env_init(void) {
  8041608550:	55                   	push   %rbp
  8041608551:	48 89 e5             	mov    %rsp,%rbp
    envs[i].env_link = env_free_list;
  8041608554:	48 b8 00 44 70 41 80 	movabs $0x8041704400,%rax
  804160855b:	00 00 00 
  804160855e:	48 8b 38             	mov    (%rax),%rdi
  8041608561:	48 8d 87 08 1e 00 00 	lea    0x1e08(%rdi),%rax
  8041608568:	48 89 fe             	mov    %rdi,%rsi
  804160856b:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608570:	eb 03                	jmp    8041608575 <env_init+0x25>
  8041608572:	48 89 c8             	mov    %rcx,%rax
  8041608575:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    envs[i].env_id   = 0;
  804160857c:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%rax)
  8041608583:	00 00 00 
  for (int i = NENV - 1; i >= 0; i--) {
  8041608586:	48 8d 88 08 ff ff ff 	lea    -0xf8(%rax),%rcx
    env_free_list    = &envs[i];
  804160858d:	48 89 c2             	mov    %rax,%rdx
  for (int i = NENV - 1; i >= 0; i--) {
  8041608590:	48 39 f0             	cmp    %rsi,%rax
  8041608593:	75 dd                	jne    8041608572 <env_init+0x22>
  8041608595:	48 89 f8             	mov    %rdi,%rax
  8041608598:	48 a3 08 44 70 41 80 	movabs %rax,0x8041704408
  804160859f:	00 00 00 
  env_init_percpu();
  80416085a2:	48 b8 0d 85 60 41 80 	movabs $0x804160850d,%rax
  80416085a9:	00 00 00 
  80416085ac:	ff d0                	callq  *%rax
}
  80416085ae:	5d                   	pop    %rbp
  80416085af:	c3                   	retq   

00000080416085b0 <env_alloc>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  80416085b0:	55                   	push   %rbp
  80416085b1:	48 89 e5             	mov    %rsp,%rbp
  80416085b4:	41 55                	push   %r13
  80416085b6:	41 54                	push   %r12
  80416085b8:	53                   	push   %rbx
  80416085b9:	48 83 ec 08          	sub    $0x8,%rsp
  int32_t generation;
  int r;
  struct Env *e;

  if (!(e = env_free_list)) {
  80416085bd:	48 b8 08 44 70 41 80 	movabs $0x8041704408,%rax
  80416085c4:	00 00 00 
  80416085c7:	48 8b 18             	mov    (%rax),%rbx
  80416085ca:	48 85 db             	test   %rbx,%rbx
  80416085cd:	0f 84 36 01 00 00    	je     8041608709 <env_alloc+0x159>
  80416085d3:	41 89 f5             	mov    %esi,%r13d
  80416085d6:	49 89 fc             	mov    %rdi,%r12
  if (!(p = page_alloc(ALLOC_ZERO)))
  80416085d9:	bf 01 00 00 00       	mov    $0x1,%edi
  80416085de:	48 b8 4b 4a 60 41 80 	movabs $0x8041604a4b,%rax
  80416085e5:	00 00 00 
  80416085e8:	ff d0                	callq  *%rax
  80416085ea:	48 85 c0             	test   %rax,%rax
  80416085ed:	0f 84 1d 01 00 00    	je     8041608710 <env_alloc+0x160>
  // Allocate and set up the page directory for this environment.
  if ((r = env_setup_vm(e)) < 0)
    return r;

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  80416085f3:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  80416085f9:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  80416085fe:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  8041608601:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041608606:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  8041608609:	48 ba 00 44 70 41 80 	movabs $0x8041704400,%rdx
  8041608610:	00 00 00 
  8041608613:	48 89 d9             	mov    %rbx,%rcx
  8041608616:	48 2b 0a             	sub    (%rdx),%rcx
  8041608619:	48 89 ca             	mov    %rcx,%rdx
  804160861c:	48 c1 fa 03          	sar    $0x3,%rdx
  8041608620:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
  8041608626:	09 d0                	or     %edx,%eax
  8041608628:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
  804160862e:	44 89 ab cc 00 00 00 	mov    %r13d,0xcc(%rbx)
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
#else
  e->env_type      = ENV_TYPE_USER;
  8041608635:	c7 83 d0 00 00 00 02 	movl   $0x2,0xd0(%rbx)
  804160863c:	00 00 00 
#endif
  e->env_status = ENV_RUNNABLE;
  804160863f:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  8041608646:	00 00 00 
  e->env_runs   = 0;
  8041608649:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  8041608650:	00 00 00 

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  8041608653:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041608658:	be 00 00 00 00       	mov    $0x0,%esi
  804160865d:	48 89 df             	mov    %rbx,%rdi
  8041608660:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041608667:	00 00 00 
  804160866a:	ff d0                	callq  *%rax
  // LAB 3 code
  static int STACK_TOP = 0x2000000;
  e->env_tf.tf_rsp     = STACK_TOP - (e - envs) * 2 * PGSIZE;

#else
  e->env_tf.tf_ds  = GD_UD | 3;
  804160866c:	66 c7 83 80 00 00 00 	movw   $0x33,0x80(%rbx)
  8041608673:	33 00 
  e->env_tf.tf_es  = GD_UD | 3;
  8041608675:	66 c7 43 78 33 00    	movw   $0x33,0x78(%rbx)
  e->env_tf.tf_ss  = GD_UD | 3;
  804160867b:	66 c7 83 b8 00 00 00 	movw   $0x33,0xb8(%rbx)
  8041608682:	33 00 
  e->env_tf.tf_rsp = USTACKTOP;
  8041608684:	48 b8 00 b0 ff ff 7f 	movabs $0x7fffffb000,%rax
  804160868b:	00 00 00 
  804160868e:	48 89 83 b0 00 00 00 	mov    %rax,0xb0(%rbx)
  e->env_tf.tf_cs  = GD_UT | 3;
  8041608695:	66 c7 83 a0 00 00 00 	movw   $0x2b,0xa0(%rbx)
  804160869c:	2b 00 
#endif

  e->env_tf.tf_rflags |= FL_IF;
  804160869e:	48 81 8b a8 00 00 00 	orq    $0x200,0xa8(%rbx)
  80416086a5:	00 02 00 00 

  // You will set e->env_tf.tf_rip later.

  // commit the allocation
  env_free_list = e->env_link;
  80416086a9:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  80416086b0:	48 a3 08 44 70 41 80 	movabs %rax,0x8041704408
  80416086b7:	00 00 00 
  *newenv_store = e;
  80416086ba:	49 89 1c 24          	mov    %rbx,(%r12)

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  80416086be:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  80416086c4:	48 a1 f8 43 70 41 80 	movabs 0x80417043f8,%rax
  80416086cb:	00 00 00 
  80416086ce:	be 00 00 00 00       	mov    $0x0,%esi
  80416086d3:	48 85 c0             	test   %rax,%rax
  80416086d6:	74 06                	je     80416086de <env_alloc+0x12e>
  80416086d8:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  80416086de:	48 bf 54 d4 60 41 80 	movabs $0x804160d454,%rdi
  80416086e5:	00 00 00 
  80416086e8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416086ed:	48 b9 6e 8f 60 41 80 	movabs $0x8041608f6e,%rcx
  80416086f4:	00 00 00 
  80416086f7:	ff d1                	callq  *%rcx

  return 0;
  80416086f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416086fe:	48 83 c4 08          	add    $0x8,%rsp
  8041608702:	5b                   	pop    %rbx
  8041608703:	41 5c                	pop    %r12
  8041608705:	41 5d                	pop    %r13
  8041608707:	5d                   	pop    %rbp
  8041608708:	c3                   	retq   
    return -E_NO_FREE_ENV;
  8041608709:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  804160870e:	eb ee                	jmp    80416086fe <env_alloc+0x14e>
    return -E_NO_MEM;
  8041608710:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8041608715:	eb e7                	jmp    80416086fe <env_alloc+0x14e>

0000008041608717 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  8041608717:	55                   	push   %rbp
  8041608718:	48 89 e5             	mov    %rsp,%rbp
  804160871b:	41 57                	push   %r15
  804160871d:	41 56                	push   %r14
  804160871f:	41 55                	push   %r13
  8041608721:	41 54                	push   %r12
  8041608723:	53                   	push   %rbx
  8041608724:	48 83 ec 28          	sub    $0x28,%rsp
  8041608728:	49 89 fc             	mov    %rdi,%r12
  804160872b:	89 f3                	mov    %esi,%ebx

  // LAB 3 code
  struct Env *newenv;
  if (env_alloc(&newenv, 0) < 0) {
  804160872d:	be 00 00 00 00       	mov    $0x0,%esi
  8041608732:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041608736:	48 b8 b0 85 60 41 80 	movabs $0x80416085b0,%rax
  804160873d:	00 00 00 
  8041608740:	ff d0                	callq  *%rax
  8041608742:	85 c0                	test   %eax,%eax
  8041608744:	78 33                	js     8041608779 <env_create+0x62>
    panic("Can't allocate new environment"); // попытка выделить среду – если нет – вылет по панике ядра
  }

  newenv->env_type = type;
  8041608746:	4c 8b 7d c8          	mov    -0x38(%rbp),%r15
  804160874a:	41 89 9f d0 00 00 00 	mov    %ebx,0xd0(%r15)
  if (elf->e_magic != ELF_MAGIC) {
  8041608751:	41 81 3c 24 7f 45 4c 	cmpl   $0x464c457f,(%r12)
  8041608758:	46 
  8041608759:	75 48                	jne    80416087a3 <env_create+0x8c>
  struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff); // Proghdr = prog header. Он лежит со смещением elf->e_phoff относительно начала фаила
  804160875b:	49 8b 5c 24 20       	mov    0x20(%r12),%rbx
  for (size_t i = 0; i < elf->e_phnum; i++) { //elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041608760:	66 41 83 7c 24 38 00 	cmpw   $0x0,0x38(%r12)
  8041608767:	74 55                	je     80416087be <env_create+0xa7>
  8041608769:	4c 01 e3             	add    %r12,%rbx
  804160876c:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8041608773:	00 
  8041608774:	e9 cc 00 00 00       	jmpq   8041608845 <env_create+0x12e>
    panic("Can't allocate new environment"); // попытка выделить среду – если нет – вылет по панике ядра
  8041608779:	48 ba a8 d4 60 41 80 	movabs $0x804160d4a8,%rdx
  8041608780:	00 00 00 
  8041608783:	be e2 01 00 00       	mov    $0x1e2,%esi
  8041608788:	48 bf 69 d4 60 41 80 	movabs $0x804160d469,%rdi
  804160878f:	00 00 00 
  8041608792:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608797:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160879e:	00 00 00 
  80416087a1:	ff d1                	callq  *%rcx
    cprintf("Unexpected ELF format\n");
  80416087a3:	48 bf 74 d4 60 41 80 	movabs $0x804160d474,%rdi
  80416087aa:	00 00 00 
  80416087ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80416087b2:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416087b9:	00 00 00 
  80416087bc:	ff d2                	callq  *%rdx

  load_icode(newenv, binary); // load instruction code
}
  80416087be:	48 83 c4 28          	add    $0x28,%rsp
  80416087c2:	5b                   	pop    %rbx
  80416087c3:	41 5c                	pop    %r12
  80416087c5:	41 5d                	pop    %r13
  80416087c7:	41 5e                	pop    %r14
  80416087c9:	41 5f                	pop    %r15
  80416087cb:	5d                   	pop    %rbp
  80416087cc:	c3                   	retq   
      void *dst = (void *)ph[i].p_va;
  80416087cd:	48 8b 43 10          	mov    0x10(%rbx),%rax
      size_t memsz  = ph[i].p_memsz;
  80416087d1:	4c 8b 6b 28          	mov    0x28(%rbx),%r13
      size_t filesz = MIN(ph[i].p_filesz, memsz);
  80416087d5:	4c 39 6b 20          	cmp    %r13,0x20(%rbx)
  80416087d9:	4d 89 ee             	mov    %r13,%r14
  80416087dc:	4c 0f 46 73 20       	cmovbe 0x20(%rbx),%r14
      void *src = binary + ph[i].p_offset;
  80416087e1:	4c 89 e6             	mov    %r12,%rsi
  80416087e4:	48 03 73 08          	add    0x8(%rbx),%rsi
      memcpy(dst, src, filesz);                // копируем в dst (дистинейшн) src (код) размера filesz
  80416087e8:	4c 89 f2             	mov    %r14,%rdx
  80416087eb:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  80416087ef:	48 89 c7             	mov    %rax,%rdi
  80416087f2:	48 b9 6a b5 60 41 80 	movabs $0x804160b56a,%rcx
  80416087f9:	00 00 00 
  80416087fc:	ff d1                	callq  *%rcx
      memset(dst + filesz, 0, memsz - filesz); // обнуление памяти по адресу dst + filesz, где количество нулей = memsz - filesz. Т.е. зануляем всю выделенную память сегмента кода, оставшуюяся после копирования src. Возможно, эта строка не нужна
  80416087fe:	4c 89 ea             	mov    %r13,%rdx
  8041608801:	4c 29 f2             	sub    %r14,%rdx
  8041608804:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041608808:	4a 8d 3c 30          	lea    (%rax,%r14,1),%rdi
  804160880c:	be 00 00 00 00       	mov    $0x0,%esi
  8041608811:	48 b8 b9 b4 60 41 80 	movabs $0x804160b4b9,%rax
  8041608818:	00 00 00 
  804160881b:	ff d0                	callq  *%rax
    e->env_tf.tf_rip = elf->e_entry; //Виртуальный адрес точки входа, которому система передает управление при запуске процесса. в регистр rip записываем адрес точки входа для выполнения процесса
  804160881d:	49 8b 44 24 18       	mov    0x18(%r12),%rax
  8041608822:	49 89 87 98 00 00 00 	mov    %rax,0x98(%r15)
  for (size_t i = 0; i < elf->e_phnum; i++) { //elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041608829:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  804160882e:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041608832:	48 83 c3 38          	add    $0x38,%rbx
  8041608836:	41 0f b7 44 24 38    	movzwl 0x38(%r12),%eax
  804160883c:	48 39 c1             	cmp    %rax,%rcx
  804160883f:	0f 83 79 ff ff ff    	jae    80416087be <env_create+0xa7>
    if (ph[i].p_type == ELF_PROG_LOAD) {
  8041608845:	83 3b 01             	cmpl   $0x1,(%rbx)
  8041608848:	75 d3                	jne    804160881d <env_create+0x106>
  804160884a:	eb 81                	jmp    80416087cd <env_create+0xb6>

000000804160884c <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  804160884c:	55                   	push   %rbp
  804160884d:	48 89 e5             	mov    %rsp,%rbp
  8041608850:	53                   	push   %rbx
  8041608851:	48 83 ec 08          	sub    $0x8,%rsp
  8041608855:	48 89 fb             	mov    %rdi,%rbx
  physaddr_t pa;

  // If freeing the current environment, switch to kern_pgdir
  // before freeing the page directory, just in case the page
  // gets reused.
  if (e == curenv)
  8041608858:	48 a1 f8 43 70 41 80 	movabs 0x80417043f8,%rax
  804160885f:	00 00 00 
  8041608862:	48 39 f8             	cmp    %rdi,%rax
  8041608865:	0f 84 96 01 00 00    	je     8041608a01 <env_free+0x1b5>
    lcr3(kern_cr3);
#endif

  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  804160886b:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608871:	be 00 00 00 00       	mov    $0x0,%esi
  8041608876:	48 85 c0             	test   %rax,%rax
  8041608879:	74 06                	je     8041608881 <env_free+0x35>
  804160887b:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041608881:	48 bf 8b d4 60 41 80 	movabs $0x804160d48b,%rdi
  8041608888:	00 00 00 
  804160888b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608890:	48 b9 6e 8f 60 41 80 	movabs $0x8041608f6e,%rcx
  8041608897:	00 00 00 
  804160889a:	ff d1                	callq  *%rcx
#ifndef CONFIG_KSPACE
  // Flush all mapped pages in the user portion of the address space
  static_assert(UTOP % PTSIZE == 0, "Misaligned UTOP");

  //UTOP < PDPE[1] start, so all mapped memory should be in first PDPE
  pdpe = KADDR(PTE_ADDR(e->env_pml4e[0]));
  804160889c:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  80416088a3:	48 8b 08             	mov    (%rax),%rcx
  80416088a6:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  80416088ad:	48 a1 30 59 70 41 80 	movabs 0x8041705930,%rax
  80416088b4:	00 00 00 
  80416088b7:	48 89 ca             	mov    %rcx,%rdx
  80416088ba:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416088be:	48 39 d0             	cmp    %rdx,%rax
  80416088c1:	0f 86 55 01 00 00    	jbe    8041608a1c <env_free+0x1d0>
  return (void *)(pa + KERNBASE);
  80416088c7:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  80416088ce:	00 00 00 
  80416088d1:	48 01 d1             	add    %rdx,%rcx
  for (pdpeno = 0; pdpeno <= PDPE(UTOP); pdpeno++) {
    // only look at mapped page directory pointer index
    if (!(pdpe[pdpeno] & PTE_P))
  80416088d4:	48 8b 31             	mov    (%rcx),%rsi
  80416088d7:	40 f6 c6 01          	test   $0x1,%sil
  80416088db:	0f 84 63 02 00 00    	je     8041608b44 <env_free+0x2f8>
      continue;

    pgdir       = KADDR(PTE_ADDR(pdpe[pdpeno]));
  80416088e1:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PGNUM(pa) >= npages)
  80416088e8:	48 89 f7             	mov    %rsi,%rdi
  80416088eb:	48 c1 ef 0c          	shr    $0xc,%rdi
  80416088ef:	48 39 f8             	cmp    %rdi,%rax
  80416088f2:	0f 86 4f 01 00 00    	jbe    8041608a47 <env_free+0x1fb>
      page_decref(pa2page(pa));
    }

    // free the page directory
    pa           = PTE_ADDR(pdpe[pdpeno]);
    pdpe[pdpeno] = 0;
  80416088f8:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  if (PPN(pa) >= npages) {
  80416088ff:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  8041608906:	00 00 00 
  8041608909:	48 3b 38             	cmp    (%rax),%rdi
  804160890c:	0f 83 63 01 00 00    	jae    8041608a75 <env_free+0x229>
  return &pages[PPN(pa)];
  8041608912:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608916:	48 a1 38 59 70 41 80 	movabs 0x8041705938,%rax
  804160891d:	00 00 00 
  8041608920:	48 01 c7             	add    %rax,%rdi
    page_decref(pa2page(pa));
  8041608923:	48 b8 dd 4b 60 41 80 	movabs $0x8041604bdd,%rax
  804160892a:	00 00 00 
  804160892d:	ff d0                	callq  *%rax
  }
  // free the page directory pointer
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  804160892f:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608936:	48 8b 30             	mov    (%rax),%rsi
  8041608939:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PPN(pa) >= npages) {
  8041608940:	48 89 f7             	mov    %rsi,%rdi
  8041608943:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608947:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  804160894e:	00 00 00 
  8041608951:	48 3b 38             	cmp    (%rax),%rdi
  8041608954:	0f 83 60 01 00 00    	jae    8041608aba <env_free+0x26e>
  return &pages[PPN(pa)];
  804160895a:	48 c1 e7 04          	shl    $0x4,%rdi
  804160895e:	48 a1 38 59 70 41 80 	movabs 0x8041705938,%rax
  8041608965:	00 00 00 
  8041608968:	48 01 c7             	add    %rax,%rdi
  804160896b:	48 b8 dd 4b 60 41 80 	movabs $0x8041604bdd,%rax
  8041608972:	00 00 00 
  8041608975:	ff d0                	callq  *%rax
  // free the page map level 4 (PML4)
  e->env_pml4e[0] = 0;
  8041608977:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  804160897e:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  pa              = e->env_cr3;
  8041608985:	48 8b b3 f0 00 00 00 	mov    0xf0(%rbx),%rsi
  e->env_pml4e    = 0;
  804160898c:	48 c7 83 e8 00 00 00 	movq   $0x0,0xe8(%rbx)
  8041608993:	00 00 00 00 
  e->env_cr3      = 0;
  8041608997:	48 c7 83 f0 00 00 00 	movq   $0x0,0xf0(%rbx)
  804160899e:	00 00 00 00 
  if (PPN(pa) >= npages) {
  80416089a2:	48 89 f7             	mov    %rsi,%rdi
  80416089a5:	48 c1 ef 0c          	shr    $0xc,%rdi
  80416089a9:	48 b8 30 59 70 41 80 	movabs $0x8041705930,%rax
  80416089b0:	00 00 00 
  80416089b3:	48 3b 38             	cmp    (%rax),%rdi
  80416089b6:	0f 83 43 01 00 00    	jae    8041608aff <env_free+0x2b3>
  return &pages[PPN(pa)];
  80416089bc:	48 c1 e7 04          	shl    $0x4,%rdi
  80416089c0:	48 a1 38 59 70 41 80 	movabs 0x8041705938,%rax
  80416089c7:	00 00 00 
  80416089ca:	48 01 c7             	add    %rax,%rdi
  page_decref(pa2page(pa));
  80416089cd:	48 b8 dd 4b 60 41 80 	movabs $0x8041604bdd,%rax
  80416089d4:	00 00 00 
  80416089d7:	ff d0                	callq  *%rax
#endif
  // return the environment to the free list
  e->env_status = ENV_FREE;
  80416089d9:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  80416089e0:	00 00 00 
  e->env_link   = env_free_list;
  80416089e3:	48 b8 08 44 70 41 80 	movabs $0x8041704408,%rax
  80416089ea:	00 00 00 
  80416089ed:	48 8b 10             	mov    (%rax),%rdx
  80416089f0:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  80416089f7:	48 89 18             	mov    %rbx,(%rax)
}
  80416089fa:	48 83 c4 08          	add    $0x8,%rsp
  80416089fe:	5b                   	pop    %rbx
  80416089ff:	5d                   	pop    %rbp
  8041608a00:	c3                   	retq   
  __asm __volatile("movq %0,%%cr3"
  8041608a01:	48 b9 28 59 70 41 80 	movabs $0x8041705928,%rcx
  8041608a08:	00 00 00 
  8041608a0b:	48 8b 11             	mov    (%rcx),%rdx
  8041608a0e:	0f 22 da             	mov    %rdx,%cr3
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608a11:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608a17:	e9 5f fe ff ff       	jmpq   804160887b <env_free+0x2f>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041608a1c:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041608a23:	00 00 00 
  8041608a26:	be 06 02 00 00       	mov    $0x206,%esi
  8041608a2b:	48 bf 69 d4 60 41 80 	movabs $0x804160d469,%rdi
  8041608a32:	00 00 00 
  8041608a35:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608a3a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608a41:	00 00 00 
  8041608a44:	41 ff d0             	callq  *%r8
  8041608a47:	48 89 f1             	mov    %rsi,%rcx
  8041608a4a:	48 ba 18 c7 60 41 80 	movabs $0x804160c718,%rdx
  8041608a51:	00 00 00 
  8041608a54:	be 0c 02 00 00       	mov    $0x20c,%esi
  8041608a59:	48 bf 69 d4 60 41 80 	movabs $0x804160d469,%rdi
  8041608a60:	00 00 00 
  8041608a63:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608a68:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608a6f:	00 00 00 
  8041608a72:	41 ff d0             	callq  *%r8
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608a75:	48 bf 73 d1 60 41 80 	movabs $0x804160d173,%rdi
  8041608a7c:	00 00 00 
  8041608a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608a84:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041608a8b:	00 00 00 
  8041608a8e:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608a90:	48 ba a0 c8 60 41 80 	movabs $0x804160c8a0,%rdx
  8041608a97:	00 00 00 
  8041608a9a:	be 5c 00 00 00       	mov    $0x5c,%esi
  8041608a9f:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041608aa6:	00 00 00 
  8041608aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608aae:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608ab5:	00 00 00 
  8041608ab8:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608aba:	48 bf 73 d1 60 41 80 	movabs $0x804160d173,%rdi
  8041608ac1:	00 00 00 
  8041608ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608ac9:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041608ad0:	00 00 00 
  8041608ad3:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608ad5:	48 ba a0 c8 60 41 80 	movabs $0x804160c8a0,%rdx
  8041608adc:	00 00 00 
  8041608adf:	be 5c 00 00 00       	mov    $0x5c,%esi
  8041608ae4:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041608aeb:	00 00 00 
  8041608aee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608af3:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608afa:	00 00 00 
  8041608afd:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608aff:	48 bf 73 d1 60 41 80 	movabs $0x804160d173,%rdi
  8041608b06:	00 00 00 
  8041608b09:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608b0e:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041608b15:	00 00 00 
  8041608b18:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608b1a:	48 ba a0 c8 60 41 80 	movabs $0x804160c8a0,%rdx
  8041608b21:	00 00 00 
  8041608b24:	be 5c 00 00 00       	mov    $0x5c,%esi
  8041608b29:	48 bf 54 d1 60 41 80 	movabs $0x804160d154,%rdi
  8041608b30:	00 00 00 
  8041608b33:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608b38:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608b3f:	00 00 00 
  8041608b42:	ff d1                	callq  *%rcx
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  8041608b44:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608b4b:	48 8b 38             	mov    (%rax),%rdi
  8041608b4e:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608b52:	e9 03 fe ff ff       	jmpq   804160895a <env_free+0x10e>

0000008041608b57 <env_destroy>:
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.

  // LAB 3 code
  e->env_status = ENV_DYING;
  8041608b57:	c7 87 d4 00 00 00 01 	movl   $0x1,0xd4(%rdi)
  8041608b5e:	00 00 00 
  if (e == curenv) {
  8041608b61:	48 b8 f8 43 70 41 80 	movabs $0x80417043f8,%rax
  8041608b68:	00 00 00 
  8041608b6b:	48 39 38             	cmp    %rdi,(%rax)
  8041608b6e:	74 01                	je     8041608b71 <env_destroy+0x1a>
  8041608b70:	c3                   	retq   
env_destroy(struct Env *e) {
  8041608b71:	55                   	push   %rbp
  8041608b72:	48 89 e5             	mov    %rsp,%rbp
    env_free(e);
  8041608b75:	48 b8 4c 88 60 41 80 	movabs $0x804160884c,%rax
  8041608b7c:	00 00 00 
  8041608b7f:	ff d0                	callq  *%rax
    sched_yield();
  8041608b81:	48 b8 f4 a4 60 41 80 	movabs $0x804160a4f4,%rax
  8041608b88:	00 00 00 
  8041608b8b:	ff d0                	callq  *%rax

0000008041608b8d <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041608b8d:	55                   	push   %rbp
  8041608b8e:	48 89 e5             	mov    %rsp,%rbp
        [ rd15 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r15)),
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
  __asm __volatile("movq %0,%%rsp\n" POPA
  8041608b91:	48 89 fc             	mov    %rdi,%rsp
  8041608b94:	4c 8b 3c 24          	mov    (%rsp),%r15
  8041608b98:	4c 8b 74 24 08       	mov    0x8(%rsp),%r14
  8041608b9d:	4c 8b 6c 24 10       	mov    0x10(%rsp),%r13
  8041608ba2:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
  8041608ba7:	4c 8b 5c 24 20       	mov    0x20(%rsp),%r11
  8041608bac:	4c 8b 54 24 28       	mov    0x28(%rsp),%r10
  8041608bb1:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
  8041608bb6:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
  8041608bbb:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
  8041608bc0:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
  8041608bc5:	48 8b 6c 24 50       	mov    0x50(%rsp),%rbp
  8041608bca:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
  8041608bcf:	48 8b 4c 24 60       	mov    0x60(%rsp),%rcx
  8041608bd4:	48 8b 5c 24 68       	mov    0x68(%rsp),%rbx
  8041608bd9:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
  8041608bde:	48 83 c4 78          	add    $0x78,%rsp
  8041608be2:	8e 04 24             	mov    (%rsp),%es
  8041608be5:	8e 5c 24 08          	mov    0x8(%rsp),%ds
  8041608be9:	48 83 c4 10          	add    $0x10,%rsp
  8041608bed:	48 83 c4 10          	add    $0x10,%rsp
  8041608bf1:	48 cf                	iretq  
                   "\tiretq"
                   :
                   : "g"(tf)
                   : "memory");
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041608bf3:	48 ba a1 d4 60 41 80 	movabs $0x804160d4a1,%rdx
  8041608bfa:	00 00 00 
  8041608bfd:	be 9b 02 00 00       	mov    $0x29b,%esi
  8041608c02:	48 bf 69 d4 60 41 80 	movabs $0x804160d469,%rdi
  8041608c09:	00 00 00 
  8041608c0c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608c11:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608c18:	00 00 00 
  8041608c1b:	ff d1                	callq  *%rcx

0000008041608c1d <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  8041608c1d:	55                   	push   %rbp
  8041608c1e:	48 89 e5             	mov    %rsp,%rbp
  8041608c21:	41 54                	push   %r12
  8041608c23:	53                   	push   %rbx
  8041608c24:	48 89 fb             	mov    %rdi,%rbx
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //

  // LAB 3 code
  if (curenv) {                            // if curenv == False, значит, какого-нибудь исполняемого процесса нет
  8041608c27:	48 b8 f8 43 70 41 80 	movabs $0x80417043f8,%rax
  8041608c2e:	00 00 00 
  8041608c31:	4c 8b 20             	mov    (%rax),%r12
  8041608c34:	4d 85 e4             	test   %r12,%r12
  8041608c37:	74 12                	je     8041608c4b <env_run+0x2e>
    if (curenv->env_status == ENV_DYING) { // если процесс стал зомби
  8041608c39:	41 8b 84 24 d4 00 00 	mov    0xd4(%r12),%eax
  8041608c40:	00 
  8041608c41:	83 f8 01             	cmp    $0x1,%eax
  8041608c44:	74 32                	je     8041608c78 <env_run+0x5b>
      struct Env *old = curenv;            // ставим старый адрес
      env_free(curenv);                    // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
      if (old == e) {                      // e - аргумент функции, который к нам пришел
        sched_yield();                     // переключение системными вызовами
      }
    } else if (curenv->env_status == ENV_RUNNING) { // если процесс можем запустить
  8041608c46:	83 f8 03             	cmp    $0x3,%eax
  8041608c49:	74 4d                	je     8041608c98 <env_run+0x7b>
      curenv->env_status = ENV_RUNNABLE;            // запускаем процесс
    }
  }

  curenv             = e;           // текущая среда – е
  8041608c4b:	48 89 d8             	mov    %rbx,%rax
  8041608c4e:	48 a3 f8 43 70 41 80 	movabs %rax,0x80417043f8
  8041608c55:	00 00 00 
  curenv->env_status = ENV_RUNNING; // устанавливаем статус среды на "выполняется"
  8041608c58:	c7 83 d4 00 00 00 03 	movl   $0x3,0xd4(%rbx)
  8041608c5f:	00 00 00 
  curenv->env_runs++;               // обновляем количество работающих контекстов
  8041608c62:	83 83 d8 00 00 00 01 	addl   $0x1,0xd8(%rbx)

  env_pop_tf(&curenv->env_tf);
  8041608c69:	48 89 df             	mov    %rbx,%rdi
  8041608c6c:	48 b8 8d 8b 60 41 80 	movabs $0x8041608b8d,%rax
  8041608c73:	00 00 00 
  8041608c76:	ff d0                	callq  *%rax
      env_free(curenv);                    // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
  8041608c78:	4c 89 e7             	mov    %r12,%rdi
  8041608c7b:	48 b8 4c 88 60 41 80 	movabs $0x804160884c,%rax
  8041608c82:	00 00 00 
  8041608c85:	ff d0                	callq  *%rax
      if (old == e) {                      // e - аргумент функции, который к нам пришел
  8041608c87:	49 39 dc             	cmp    %rbx,%r12
  8041608c8a:	75 bf                	jne    8041608c4b <env_run+0x2e>
        sched_yield();                     // переключение системными вызовами
  8041608c8c:	48 b8 f4 a4 60 41 80 	movabs $0x804160a4f4,%rax
  8041608c93:	00 00 00 
  8041608c96:	ff d0                	callq  *%rax
      curenv->env_status = ENV_RUNNABLE;            // запускаем процесс
  8041608c98:	41 c7 84 24 d4 00 00 	movl   $0x2,0xd4(%r12)
  8041608c9f:	00 02 00 00 00 
  8041608ca4:	eb a5                	jmp    8041608c4b <env_run+0x2e>

0000008041608ca6 <rtc_timer_pic_interrupt>:
  // DELETED in LAB 5 end
  rtc_init();
}

static void
rtc_timer_pic_interrupt(void) {
  8041608ca6:	55                   	push   %rbp
  8041608ca7:	48 89 e5             	mov    %rsp,%rbp
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  8041608caa:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  8041608cb1:	00 00 00 
  8041608cb4:	89 c7                	mov    %eax,%edi
  8041608cb6:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  8041608cbc:	48 b8 96 8d 60 41 80 	movabs $0x8041608d96,%rax
  8041608cc3:	00 00 00 
  8041608cc6:	ff d0                	callq  *%rax
}
  8041608cc8:	5d                   	pop    %rbp
  8041608cc9:	c3                   	retq   

0000008041608cca <rtc_init>:
  __asm __volatile("inb %w1,%0"
  8041608cca:	b9 70 00 00 00       	mov    $0x70,%ecx
  8041608ccf:	89 ca                	mov    %ecx,%edx
  8041608cd1:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) & ~NMI_LOCK);
}

static inline void
nmi_disable(void) {
  outb(0x70, inb(0x70) | NMI_LOCK);
  8041608cd2:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  8041608cd5:	ee                   	out    %al,(%dx)
  8041608cd6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041608cdb:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608cdc:	be 71 00 00 00       	mov    $0x71,%esi
  8041608ce1:	89 f2                	mov    %esi,%edx
  8041608ce3:	ec                   	in     (%dx),%al

  // меняем делитель частоты регистра часов А,
  // чтобы прерывания приходили раз в полсекунды
  outb(IO_RTC_CMND, RTC_AREG);
  reg_a = inb(IO_RTC_DATA);
  reg_a = reg_a | 0x0F; // биты 0-3 = 1 => 500 мс (2 Гц)
  8041608ce4:	83 c8 0f             	or     $0xf,%eax
  __asm __volatile("outb %0,%w1"
  8041608ce7:	ee                   	out    %al,(%dx)
  8041608ce8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8041608ced:	89 ca                	mov    %ecx,%edx
  8041608cef:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608cf0:	89 f2                	mov    %esi,%edx
  8041608cf2:	ec                   	in     (%dx),%al
  outb(IO_RTC_DATA, reg_a);

  // устанавливаем бит RTC_PIE в регистре часов В
  outb(IO_RTC_CMND, RTC_BREG);
  reg_b = inb(IO_RTC_DATA);
  reg_b = reg_b | RTC_PIE;
  8041608cf3:	83 c8 40             	or     $0x40,%eax
  __asm __volatile("outb %0,%w1"
  8041608cf6:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608cf7:	89 ca                	mov    %ecx,%edx
  8041608cf9:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  8041608cfa:	83 e0 7f             	and    $0x7f,%eax
  8041608cfd:	ee                   	out    %al,(%dx)
  outb(IO_RTC_DATA, reg_b);

  // разрешить прерывания
  nmi_enable();
  // LAB 4 code end
}
  8041608cfe:	c3                   	retq   

0000008041608cff <rtc_timer_init>:
rtc_timer_init(void) {
  8041608cff:	55                   	push   %rbp
  8041608d00:	48 89 e5             	mov    %rsp,%rbp
  rtc_init();
  8041608d03:	48 b8 ca 8c 60 41 80 	movabs $0x8041608cca,%rax
  8041608d0a:	00 00 00 
  8041608d0d:	ff d0                	callq  *%rax
}
  8041608d0f:	5d                   	pop    %rbp
  8041608d10:	c3                   	retq   

0000008041608d11 <rtc_check_status>:
  8041608d11:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041608d16:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608d1b:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608d1c:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608d21:	ec                   	in     (%dx),%al
  outb(IO_RTC_CMND, RTC_CREG);
  status = inb(IO_RTC_DATA);
  // LAB 4 code end

  return status;
}
  8041608d22:	c3                   	retq   

0000008041608d23 <rtc_timer_pic_handle>:
rtc_timer_pic_handle(void) {
  8041608d23:	55                   	push   %rbp
  8041608d24:	48 89 e5             	mov    %rsp,%rbp
  rtc_check_status();
  8041608d27:	48 b8 11 8d 60 41 80 	movabs $0x8041608d11,%rax
  8041608d2e:	00 00 00 
  8041608d31:	ff d0                	callq  *%rax
  pic_send_eoi(IRQ_CLOCK);
  8041608d33:	bf 08 00 00 00       	mov    $0x8,%edi
  8041608d38:	48 b8 fb 8e 60 41 80 	movabs $0x8041608efb,%rax
  8041608d3f:	00 00 00 
  8041608d42:	ff d0                	callq  *%rax
}
  8041608d44:	5d                   	pop    %rbp
  8041608d45:	c3                   	retq   

0000008041608d46 <mc146818_read>:
  __asm __volatile("outb %0,%w1"
  8041608d46:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608d4b:	89 f8                	mov    %edi,%eax
  8041608d4d:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608d4e:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608d53:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg) {
  outb(IO_RTC_CMND, reg);
  return inb(IO_RTC_DATA);
  8041608d54:	0f b6 c0             	movzbl %al,%eax
}
  8041608d57:	c3                   	retq   

0000008041608d58 <mc146818_write>:
  __asm __volatile("outb %0,%w1"
  8041608d58:	ba 70 00 00 00       	mov    $0x70,%edx
  8041608d5d:	89 f8                	mov    %edi,%eax
  8041608d5f:	ee                   	out    %al,(%dx)
  8041608d60:	ba 71 00 00 00       	mov    $0x71,%edx
  8041608d65:	89 f0                	mov    %esi,%eax
  8041608d67:	ee                   	out    %al,(%dx)

void
mc146818_write(unsigned reg, unsigned datum) {
  outb(IO_RTC_CMND, reg);
  outb(IO_RTC_DATA, datum);
}
  8041608d68:	c3                   	retq   

0000008041608d69 <mc146818_read16>:
  8041608d69:	41 b8 70 00 00 00    	mov    $0x70,%r8d
  8041608d6f:	89 f8                	mov    %edi,%eax
  8041608d71:	44 89 c2             	mov    %r8d,%edx
  8041608d74:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608d75:	b9 71 00 00 00       	mov    $0x71,%ecx
  8041608d7a:	89 ca                	mov    %ecx,%edx
  8041608d7c:	ec                   	in     (%dx),%al
  8041608d7d:	89 c6                	mov    %eax,%esi

unsigned
mc146818_read16(unsigned reg) {
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041608d7f:	8d 47 01             	lea    0x1(%rdi),%eax
  __asm __volatile("outb %0,%w1"
  8041608d82:	44 89 c2             	mov    %r8d,%edx
  8041608d85:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608d86:	89 ca                	mov    %ecx,%edx
  8041608d88:	ec                   	in     (%dx),%al
  return inb(IO_RTC_DATA);
  8041608d89:	0f b6 c0             	movzbl %al,%eax
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041608d8c:	c1 e0 08             	shl    $0x8,%eax
  return inb(IO_RTC_DATA);
  8041608d8f:	40 0f b6 f6          	movzbl %sil,%esi
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041608d93:	09 f0                	or     %esi,%eax
  8041608d95:	c3                   	retq   

0000008041608d96 <irq_setmask_8259A>:
}

void
irq_setmask_8259A(uint16_t mask) {
  int i;
  irq_mask_8259A = mask;
  8041608d96:	89 f8                	mov    %edi,%eax
  8041608d98:	66 a3 e8 f7 61 41 80 	movabs %ax,0x804161f7e8
  8041608d9f:	00 00 00 
  if (!didinit)
  8041608da2:	48 b8 10 44 70 41 80 	movabs $0x8041704410,%rax
  8041608da9:	00 00 00 
  8041608dac:	80 38 00             	cmpb   $0x0,(%rax)
  8041608daf:	75 01                	jne    8041608db2 <irq_setmask_8259A+0x1c>
  8041608db1:	c3                   	retq   
irq_setmask_8259A(uint16_t mask) {
  8041608db2:	55                   	push   %rbp
  8041608db3:	48 89 e5             	mov    %rsp,%rbp
  8041608db6:	41 56                	push   %r14
  8041608db8:	41 55                	push   %r13
  8041608dba:	41 54                	push   %r12
  8041608dbc:	53                   	push   %rbx
  8041608dbd:	41 89 fc             	mov    %edi,%r12d
  8041608dc0:	89 f8                	mov    %edi,%eax
  __asm __volatile("outb %0,%w1"
  8041608dc2:	ba 21 00 00 00       	mov    $0x21,%edx
  8041608dc7:	ee                   	out    %al,(%dx)
    return;
  outb(IO_PIC1_DATA, (char)mask);
  outb(IO_PIC2_DATA, (char)(mask >> 8));
  8041608dc8:	66 c1 e8 08          	shr    $0x8,%ax
  8041608dcc:	ba a1 00 00 00       	mov    $0xa1,%edx
  8041608dd1:	ee                   	out    %al,(%dx)
  cprintf("enabled interrupts:");
  8041608dd2:	48 bf cb d4 60 41 80 	movabs $0x804160d4cb,%rdi
  8041608dd9:	00 00 00 
  8041608ddc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608de1:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041608de8:	00 00 00 
  8041608deb:	ff d2                	callq  *%rdx
  for (i = 0; i < 16; i++)
  8041608ded:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (~mask & (1 << i))
  8041608df2:	45 0f b7 e4          	movzwl %r12w,%r12d
  8041608df6:	41 f7 d4             	not    %r12d
      cprintf(" %d", i);
  8041608df9:	49 be 08 dd 60 41 80 	movabs $0x804160dd08,%r14
  8041608e00:	00 00 00 
  8041608e03:	49 bd 6e 8f 60 41 80 	movabs $0x8041608f6e,%r13
  8041608e0a:	00 00 00 
  8041608e0d:	eb 15                	jmp    8041608e24 <irq_setmask_8259A+0x8e>
  8041608e0f:	89 de                	mov    %ebx,%esi
  8041608e11:	4c 89 f7             	mov    %r14,%rdi
  8041608e14:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e19:	41 ff d5             	callq  *%r13
  for (i = 0; i < 16; i++)
  8041608e1c:	83 c3 01             	add    $0x1,%ebx
  8041608e1f:	83 fb 10             	cmp    $0x10,%ebx
  8041608e22:	74 08                	je     8041608e2c <irq_setmask_8259A+0x96>
    if (~mask & (1 << i))
  8041608e24:	41 0f a3 dc          	bt     %ebx,%r12d
  8041608e28:	73 f2                	jae    8041608e1c <irq_setmask_8259A+0x86>
  8041608e2a:	eb e3                	jmp    8041608e0f <irq_setmask_8259A+0x79>
  cprintf("\n");
  8041608e2c:	48 bf 4f d3 60 41 80 	movabs $0x804160d34f,%rdi
  8041608e33:	00 00 00 
  8041608e36:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e3b:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041608e42:	00 00 00 
  8041608e45:	ff d2                	callq  *%rdx
}
  8041608e47:	5b                   	pop    %rbx
  8041608e48:	41 5c                	pop    %r12
  8041608e4a:	41 5d                	pop    %r13
  8041608e4c:	41 5e                	pop    %r14
  8041608e4e:	5d                   	pop    %rbp
  8041608e4f:	c3                   	retq   

0000008041608e50 <pic_init>:
  didinit = 1;
  8041608e50:	48 b8 10 44 70 41 80 	movabs $0x8041704410,%rax
  8041608e57:	00 00 00 
  8041608e5a:	c6 00 01             	movb   $0x1,(%rax)
  8041608e5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041608e62:	be 21 00 00 00       	mov    $0x21,%esi
  8041608e67:	89 f2                	mov    %esi,%edx
  8041608e69:	ee                   	out    %al,(%dx)
  8041608e6a:	b9 a1 00 00 00       	mov    $0xa1,%ecx
  8041608e6f:	89 ca                	mov    %ecx,%edx
  8041608e71:	ee                   	out    %al,(%dx)
  8041608e72:	41 b9 11 00 00 00    	mov    $0x11,%r9d
  8041608e78:	bf 20 00 00 00       	mov    $0x20,%edi
  8041608e7d:	44 89 c8             	mov    %r9d,%eax
  8041608e80:	89 fa                	mov    %edi,%edx
  8041608e82:	ee                   	out    %al,(%dx)
  8041608e83:	b8 20 00 00 00       	mov    $0x20,%eax
  8041608e88:	89 f2                	mov    %esi,%edx
  8041608e8a:	ee                   	out    %al,(%dx)
  8041608e8b:	b8 04 00 00 00       	mov    $0x4,%eax
  8041608e90:	ee                   	out    %al,(%dx)
  8041608e91:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  8041608e97:	44 89 c0             	mov    %r8d,%eax
  8041608e9a:	ee                   	out    %al,(%dx)
  8041608e9b:	be a0 00 00 00       	mov    $0xa0,%esi
  8041608ea0:	44 89 c8             	mov    %r9d,%eax
  8041608ea3:	89 f2                	mov    %esi,%edx
  8041608ea5:	ee                   	out    %al,(%dx)
  8041608ea6:	b8 28 00 00 00       	mov    $0x28,%eax
  8041608eab:	89 ca                	mov    %ecx,%edx
  8041608ead:	ee                   	out    %al,(%dx)
  8041608eae:	b8 02 00 00 00       	mov    $0x2,%eax
  8041608eb3:	ee                   	out    %al,(%dx)
  8041608eb4:	44 89 c0             	mov    %r8d,%eax
  8041608eb7:	ee                   	out    %al,(%dx)
  8041608eb8:	41 b8 68 00 00 00    	mov    $0x68,%r8d
  8041608ebe:	44 89 c0             	mov    %r8d,%eax
  8041608ec1:	89 fa                	mov    %edi,%edx
  8041608ec3:	ee                   	out    %al,(%dx)
  8041608ec4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041608ec9:	89 c8                	mov    %ecx,%eax
  8041608ecb:	ee                   	out    %al,(%dx)
  8041608ecc:	44 89 c0             	mov    %r8d,%eax
  8041608ecf:	89 f2                	mov    %esi,%edx
  8041608ed1:	ee                   	out    %al,(%dx)
  8041608ed2:	89 c8                	mov    %ecx,%eax
  8041608ed4:	ee                   	out    %al,(%dx)
  if (irq_mask_8259A != 0xFFFF)
  8041608ed5:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  8041608edc:	00 00 00 
  8041608edf:	66 83 f8 ff          	cmp    $0xffff,%ax
  8041608ee3:	75 01                	jne    8041608ee6 <pic_init+0x96>
  8041608ee5:	c3                   	retq   
pic_init(void) {
  8041608ee6:	55                   	push   %rbp
  8041608ee7:	48 89 e5             	mov    %rsp,%rbp
    irq_setmask_8259A(irq_mask_8259A);
  8041608eea:	0f b7 f8             	movzwl %ax,%edi
  8041608eed:	48 b8 96 8d 60 41 80 	movabs $0x8041608d96,%rax
  8041608ef4:	00 00 00 
  8041608ef7:	ff d0                	callq  *%rax
}
  8041608ef9:	5d                   	pop    %rbp
  8041608efa:	c3                   	retq   

0000008041608efb <pic_send_eoi>:

void
pic_send_eoi(uint8_t irq) {
  if (irq >= 8)
  8041608efb:	40 80 ff 07          	cmp    $0x7,%dil
  8041608eff:	76 0b                	jbe    8041608f0c <pic_send_eoi+0x11>
  8041608f01:	b8 20 00 00 00       	mov    $0x20,%eax
  8041608f06:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041608f0b:	ee                   	out    %al,(%dx)
  8041608f0c:	b8 20 00 00 00       	mov    $0x20,%eax
  8041608f11:	ba 20 00 00 00       	mov    $0x20,%edx
  8041608f16:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_CMND, PIC_EOI);
  outb(IO_PIC1_CMND, PIC_EOI);
}
  8041608f17:	c3                   	retq   

0000008041608f18 <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  8041608f18:	55                   	push   %rbp
  8041608f19:	48 89 e5             	mov    %rsp,%rbp
  8041608f1c:	53                   	push   %rbx
  8041608f1d:	48 83 ec 08          	sub    $0x8,%rsp
  8041608f21:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  8041608f24:	48 b8 1a 0d 60 41 80 	movabs $0x8041600d1a,%rax
  8041608f2b:	00 00 00 
  8041608f2e:	ff d0                	callq  *%rax
  (*cnt)++;
  8041608f30:	83 03 01             	addl   $0x1,(%rbx)
}
  8041608f33:	48 83 c4 08          	add    $0x8,%rsp
  8041608f37:	5b                   	pop    %rbx
  8041608f38:	5d                   	pop    %rbp
  8041608f39:	c3                   	retq   

0000008041608f3a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8041608f3a:	55                   	push   %rbp
  8041608f3b:	48 89 e5             	mov    %rsp,%rbp
  8041608f3e:	48 83 ec 10          	sub    $0x10,%rsp
  8041608f42:	48 89 fa             	mov    %rdi,%rdx
  8041608f45:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  8041608f48:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  8041608f4f:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  8041608f53:	48 bf 18 8f 60 41 80 	movabs $0x8041608f18,%rdi
  8041608f5a:	00 00 00 
  8041608f5d:	48 b8 02 aa 60 41 80 	movabs $0x804160aa02,%rax
  8041608f64:	00 00 00 
  8041608f67:	ff d0                	callq  *%rax
  return cnt;
}
  8041608f69:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041608f6c:	c9                   	leaveq 
  8041608f6d:	c3                   	retq   

0000008041608f6e <cprintf>:

int
cprintf(const char *fmt, ...) {
  8041608f6e:	55                   	push   %rbp
  8041608f6f:	48 89 e5             	mov    %rsp,%rbp
  8041608f72:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041608f79:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8041608f80:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041608f87:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041608f8e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041608f95:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041608f9c:	84 c0                	test   %al,%al
  8041608f9e:	74 20                	je     8041608fc0 <cprintf+0x52>
  8041608fa0:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041608fa4:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041608fa8:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041608fac:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041608fb0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041608fb4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041608fb8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041608fbc:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8041608fc0:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8041608fc7:	00 00 00 
  8041608fca:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041608fd1:	00 00 00 
  8041608fd4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041608fd8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041608fdf:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041608fe6:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8041608fed:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041608ff4:	48 b8 3a 8f 60 41 80 	movabs $0x8041608f3a,%rax
  8041608ffb:	00 00 00 
  8041608ffe:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8041609000:	c9                   	leaveq 
  8041609001:	c3                   	retq   

0000008041609002 <trap_init_percpu>:
// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void) {
  // Setup a TSS so that we get the right stack
  // when we trap to the kernel.
  ts.ts_esp0 = KSTACKTOP;
  8041609002:	48 ba 40 54 70 41 80 	movabs $0x8041705440,%rdx
  8041609009:	00 00 00 
  804160900c:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041609013:	00 00 00 
  8041609016:	48 89 42 04          	mov    %rax,0x4(%rdx)

  // Initialize the TSS slot of the gdt.
  SETTSS((struct SystemSegdesc64 *)(&gdt[(GD_TSS0 >> 3)]), STS_T64A,
  804160901a:	48 b8 60 f7 61 41 80 	movabs $0x804161f760,%rax
  8041609021:	00 00 00 
  8041609024:	66 c7 40 38 68 00    	movw   $0x68,0x38(%rax)
  804160902a:	66 89 50 3a          	mov    %dx,0x3a(%rax)
  804160902e:	48 89 d1             	mov    %rdx,%rcx
  8041609031:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609035:	88 48 3c             	mov    %cl,0x3c(%rax)
  8041609038:	c6 40 3d 89          	movb   $0x89,0x3d(%rax)
  804160903c:	c6 40 3e 00          	movb   $0x0,0x3e(%rax)
  8041609040:	48 89 d1             	mov    %rdx,%rcx
  8041609043:	48 c1 e9 18          	shr    $0x18,%rcx
  8041609047:	88 48 3f             	mov    %cl,0x3f(%rax)
  804160904a:	48 c1 ea 20          	shr    $0x20,%rdx
  804160904e:	89 50 40             	mov    %edx,0x40(%rax)
  8041609051:	c6 40 44 00          	movb   $0x0,0x44(%rax)
  8041609055:	c6 40 45 00          	movb   $0x0,0x45(%rax)
  8041609059:	66 c7 40 46 00 00    	movw   $0x0,0x46(%rax)
  __asm __volatile("ltr %0"
  804160905f:	b8 38 00 00 00       	mov    $0x38,%eax
  8041609064:	0f 00 d8             	ltr    %ax
  __asm __volatile("lidt (%0)"
  8041609067:	48 b8 f0 f7 61 41 80 	movabs $0x804161f7f0,%rax
  804160906e:	00 00 00 
  8041609071:	0f 01 18             	lidt   (%rax)
  // bottom three bits are special; we leave them 0)
  ltr(GD_TSS0);

  // Load the IDT
  lidt(&idt_pd);
}
  8041609074:	c3                   	retq   

0000008041609075 <trap_init>:
trap_init(void) {
  8041609075:	55                   	push   %rbp
  8041609076:	48 89 e5             	mov    %rsp,%rbp
  trap_init_percpu();
  8041609079:	48 b8 02 90 60 41 80 	movabs $0x8041609002,%rax
  8041609080:	00 00 00 
  8041609083:	ff d0                	callq  *%rax
}
  8041609085:	5d                   	pop    %rbp
  8041609086:	c3                   	retq   

0000008041609087 <clock_idt_init>:

void
clock_idt_init(void) {
  extern void (*clock_thdlr)(void);
  // init idt structure
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041609087:	48 ba f4 97 60 41 80 	movabs $0x80416097f4,%rdx
  804160908e:	00 00 00 
  8041609091:	48 b8 20 44 70 41 80 	movabs $0x8041704420,%rax
  8041609098:	00 00 00 
  804160909b:	66 89 90 00 02 00 00 	mov    %dx,0x200(%rax)
  80416090a2:	66 c7 80 02 02 00 00 	movw   $0x8,0x202(%rax)
  80416090a9:	08 00 
  80416090ab:	c6 80 04 02 00 00 00 	movb   $0x0,0x204(%rax)
  80416090b2:	c6 80 05 02 00 00 8e 	movb   $0x8e,0x205(%rax)
  80416090b9:	48 89 d6             	mov    %rdx,%rsi
  80416090bc:	48 c1 ee 10          	shr    $0x10,%rsi
  80416090c0:	66 89 b0 06 02 00 00 	mov    %si,0x206(%rax)
  80416090c7:	48 89 d1             	mov    %rdx,%rcx
  80416090ca:	48 c1 e9 20          	shr    $0x20,%rcx
  80416090ce:	89 88 08 02 00 00    	mov    %ecx,0x208(%rax)
  80416090d4:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%rax)
  80416090db:	00 00 00 
  SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  80416090de:	66 89 90 80 02 00 00 	mov    %dx,0x280(%rax)
  80416090e5:	66 c7 80 82 02 00 00 	movw   $0x8,0x282(%rax)
  80416090ec:	08 00 
  80416090ee:	c6 80 84 02 00 00 00 	movb   $0x0,0x284(%rax)
  80416090f5:	c6 80 85 02 00 00 8e 	movb   $0x8e,0x285(%rax)
  80416090fc:	66 89 b0 86 02 00 00 	mov    %si,0x286(%rax)
  8041609103:	89 88 88 02 00 00    	mov    %ecx,0x288(%rax)
  8041609109:	c7 80 8c 02 00 00 00 	movl   $0x0,0x28c(%rax)
  8041609110:	00 00 00 
  8041609113:	48 b8 f0 f7 61 41 80 	movabs $0x804161f7f0,%rax
  804160911a:	00 00 00 
  804160911d:	0f 01 18             	lidt   (%rax)
  lidt(&idt_pd);
}
  8041609120:	c3                   	retq   

0000008041609121 <print_regs>:
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  }
}

void
print_regs(struct PushRegs *regs) {
  8041609121:	55                   	push   %rbp
  8041609122:	48 89 e5             	mov    %rsp,%rbp
  8041609125:	41 54                	push   %r12
  8041609127:	53                   	push   %rbx
  8041609128:	49 89 fc             	mov    %rdi,%r12
  cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  804160912b:	48 8b 37             	mov    (%rdi),%rsi
  804160912e:	48 bf df d4 60 41 80 	movabs $0x804160d4df,%rdi
  8041609135:	00 00 00 
  8041609138:	b8 00 00 00 00       	mov    $0x0,%eax
  804160913d:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  8041609144:	00 00 00 
  8041609147:	ff d3                	callq  *%rbx
  cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  8041609149:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
  804160914e:	48 bf ef d4 60 41 80 	movabs $0x804160d4ef,%rdi
  8041609155:	00 00 00 
  8041609158:	b8 00 00 00 00       	mov    $0x0,%eax
  804160915d:	ff d3                	callq  *%rbx
  cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  804160915f:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  8041609164:	48 bf ff d4 60 41 80 	movabs $0x804160d4ff,%rdi
  804160916b:	00 00 00 
  804160916e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609173:	ff d3                	callq  *%rbx
  cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  8041609175:	49 8b 74 24 18       	mov    0x18(%r12),%rsi
  804160917a:	48 bf 0f d5 60 41 80 	movabs $0x804160d50f,%rdi
  8041609181:	00 00 00 
  8041609184:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609189:	ff d3                	callq  *%rbx
  cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  804160918b:	49 8b 74 24 20       	mov    0x20(%r12),%rsi
  8041609190:	48 bf 1f d5 60 41 80 	movabs $0x804160d51f,%rdi
  8041609197:	00 00 00 
  804160919a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160919f:	ff d3                	callq  *%rbx
  cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  80416091a1:	49 8b 74 24 28       	mov    0x28(%r12),%rsi
  80416091a6:	48 bf 2f d5 60 41 80 	movabs $0x804160d52f,%rdi
  80416091ad:	00 00 00 
  80416091b0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416091b5:	ff d3                	callq  *%rbx
  cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  80416091b7:	49 8b 74 24 30       	mov    0x30(%r12),%rsi
  80416091bc:	48 bf 3f d5 60 41 80 	movabs $0x804160d53f,%rdi
  80416091c3:	00 00 00 
  80416091c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416091cb:	ff d3                	callq  *%rbx
  cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  80416091cd:	49 8b 74 24 38       	mov    0x38(%r12),%rsi
  80416091d2:	48 bf 4f d5 60 41 80 	movabs $0x804160d54f,%rdi
  80416091d9:	00 00 00 
  80416091dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416091e1:	ff d3                	callq  *%rbx
  cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  80416091e3:	49 8b 74 24 48       	mov    0x48(%r12),%rsi
  80416091e8:	48 bf 5f d5 60 41 80 	movabs $0x804160d55f,%rdi
  80416091ef:	00 00 00 
  80416091f2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416091f7:	ff d3                	callq  *%rbx
  cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  80416091f9:	49 8b 74 24 40       	mov    0x40(%r12),%rsi
  80416091fe:	48 bf 6f d5 60 41 80 	movabs $0x804160d56f,%rdi
  8041609205:	00 00 00 
  8041609208:	b8 00 00 00 00       	mov    $0x0,%eax
  804160920d:	ff d3                	callq  *%rbx
  cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  804160920f:	49 8b 74 24 50       	mov    0x50(%r12),%rsi
  8041609214:	48 bf 7f d5 60 41 80 	movabs $0x804160d57f,%rdi
  804160921b:	00 00 00 
  804160921e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609223:	ff d3                	callq  *%rbx
  cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  8041609225:	49 8b 74 24 68       	mov    0x68(%r12),%rsi
  804160922a:	48 bf 8f d5 60 41 80 	movabs $0x804160d58f,%rdi
  8041609231:	00 00 00 
  8041609234:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609239:	ff d3                	callq  *%rbx
  cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  804160923b:	49 8b 74 24 58       	mov    0x58(%r12),%rsi
  8041609240:	48 bf 9f d5 60 41 80 	movabs $0x804160d59f,%rdi
  8041609247:	00 00 00 
  804160924a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160924f:	ff d3                	callq  *%rbx
  cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  8041609251:	49 8b 74 24 60       	mov    0x60(%r12),%rsi
  8041609256:	48 bf af d5 60 41 80 	movabs $0x804160d5af,%rdi
  804160925d:	00 00 00 
  8041609260:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609265:	ff d3                	callq  *%rbx
  cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
  8041609267:	49 8b 74 24 70       	mov    0x70(%r12),%rsi
  804160926c:	48 bf bf d5 60 41 80 	movabs $0x804160d5bf,%rdi
  8041609273:	00 00 00 
  8041609276:	b8 00 00 00 00       	mov    $0x0,%eax
  804160927b:	ff d3                	callq  *%rbx
}
  804160927d:	5b                   	pop    %rbx
  804160927e:	41 5c                	pop    %r12
  8041609280:	5d                   	pop    %rbp
  8041609281:	c3                   	retq   

0000008041609282 <print_trapframe>:
print_trapframe(struct Trapframe *tf) {
  8041609282:	55                   	push   %rbp
  8041609283:	48 89 e5             	mov    %rsp,%rbp
  8041609286:	41 54                	push   %r12
  8041609288:	53                   	push   %rbx
  8041609289:	48 89 fb             	mov    %rdi,%rbx
  cprintf("TRAP frame at %p\n", tf);
  804160928c:	48 89 fe             	mov    %rdi,%rsi
  804160928f:	48 bf 0f d7 60 41 80 	movabs $0x804160d70f,%rdi
  8041609296:	00 00 00 
  8041609299:	b8 00 00 00 00       	mov    $0x0,%eax
  804160929e:	49 bc 6e 8f 60 41 80 	movabs $0x8041608f6e,%r12
  80416092a5:	00 00 00 
  80416092a8:	41 ff d4             	callq  *%r12
  print_regs(&tf->tf_regs);
  80416092ab:	48 89 df             	mov    %rbx,%rdi
  80416092ae:	48 b8 21 91 60 41 80 	movabs $0x8041609121,%rax
  80416092b5:	00 00 00 
  80416092b8:	ff d0                	callq  *%rax
  cprintf("  es   0x----%04x\n", tf->tf_es);
  80416092ba:	0f b7 73 78          	movzwl 0x78(%rbx),%esi
  80416092be:	48 bf 24 d6 60 41 80 	movabs $0x804160d624,%rdi
  80416092c5:	00 00 00 
  80416092c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416092cd:	41 ff d4             	callq  *%r12
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  80416092d0:	0f b7 b3 80 00 00 00 	movzwl 0x80(%rbx),%esi
  80416092d7:	48 bf 37 d6 60 41 80 	movabs $0x804160d637,%rdi
  80416092de:	00 00 00 
  80416092e1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416092e6:	41 ff d4             	callq  *%r12
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  80416092e9:	48 8b b3 88 00 00 00 	mov    0x88(%rbx),%rsi
  if (trapno < sizeof(excnames) / sizeof(excnames[0]))
  80416092f0:	83 fe 13             	cmp    $0x13,%esi
  80416092f3:	0f 86 68 01 00 00    	jbe    8041609461 <print_trapframe+0x1df>
    return "System call";
  80416092f9:	48 ba cf d5 60 41 80 	movabs $0x804160d5cf,%rdx
  8041609300:	00 00 00 
  if (trapno == T_SYSCALL)
  8041609303:	83 fe 30             	cmp    $0x30,%esi
  8041609306:	74 1e                	je     8041609326 <print_trapframe+0xa4>
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  8041609308:	8d 46 e0             	lea    -0x20(%rsi),%eax
    return "Hardware Interrupt";
  804160930b:	83 f8 0f             	cmp    $0xf,%eax
  804160930e:	48 ba db d5 60 41 80 	movabs $0x804160d5db,%rdx
  8041609315:	00 00 00 
  8041609318:	48 b8 ea d5 60 41 80 	movabs $0x804160d5ea,%rax
  804160931f:	00 00 00 
  8041609322:	48 0f 46 d0          	cmovbe %rax,%rdx
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  8041609326:	48 bf 4a d6 60 41 80 	movabs $0x804160d64a,%rdi
  804160932d:	00 00 00 
  8041609330:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609335:	48 b9 6e 8f 60 41 80 	movabs $0x8041608f6e,%rcx
  804160933c:	00 00 00 
  804160933f:	ff d1                	callq  *%rcx
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041609341:	48 b8 20 54 70 41 80 	movabs $0x8041705420,%rax
  8041609348:	00 00 00 
  804160934b:	48 39 18             	cmp    %rbx,(%rax)
  804160934e:	0f 84 23 01 00 00    	je     8041609477 <print_trapframe+0x1f5>
  cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  8041609354:	48 8b b3 90 00 00 00 	mov    0x90(%rbx),%rsi
  804160935b:	48 bf 6d d6 60 41 80 	movabs $0x804160d66d,%rdi
  8041609362:	00 00 00 
  8041609365:	b8 00 00 00 00       	mov    $0x0,%eax
  804160936a:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041609371:	00 00 00 
  8041609374:	ff d2                	callq  *%rdx
  if (tf->tf_trapno == T_PGFLT)
  8041609376:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  804160937d:	0e 
  804160937e:	0f 85 24 01 00 00    	jne    80416094a8 <print_trapframe+0x226>
            tf->tf_err & 1 ? "protection" : "not-present");
  8041609384:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
    cprintf(" [%s, %s, %s]\n",
  804160938b:	48 89 c2             	mov    %rax,%rdx
  804160938e:	83 e2 01             	and    $0x1,%edx
  8041609391:	48 b9 fd d5 60 41 80 	movabs $0x804160d5fd,%rcx
  8041609398:	00 00 00 
  804160939b:	48 ba 08 d6 60 41 80 	movabs $0x804160d608,%rdx
  80416093a2:	00 00 00 
  80416093a5:	48 0f 44 ca          	cmove  %rdx,%rcx
  80416093a9:	48 89 c2             	mov    %rax,%rdx
  80416093ac:	83 e2 02             	and    $0x2,%edx
  80416093af:	48 ba 14 d6 60 41 80 	movabs $0x804160d614,%rdx
  80416093b6:	00 00 00 
  80416093b9:	48 be 1a d6 60 41 80 	movabs $0x804160d61a,%rsi
  80416093c0:	00 00 00 
  80416093c3:	48 0f 44 d6          	cmove  %rsi,%rdx
  80416093c7:	83 e0 04             	and    $0x4,%eax
  80416093ca:	48 be 1f d6 60 41 80 	movabs $0x804160d61f,%rsi
  80416093d1:	00 00 00 
  80416093d4:	48 b8 57 d7 60 41 80 	movabs $0x804160d757,%rax
  80416093db:	00 00 00 
  80416093de:	48 0f 44 f0          	cmove  %rax,%rsi
  80416093e2:	48 bf 7c d6 60 41 80 	movabs $0x804160d67c,%rdi
  80416093e9:	00 00 00 
  80416093ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416093f1:	49 b8 6e 8f 60 41 80 	movabs $0x8041608f6e,%r8
  80416093f8:	00 00 00 
  80416093fb:	41 ff d0             	callq  *%r8
  cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  80416093fe:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
  8041609405:	48 bf 8b d6 60 41 80 	movabs $0x804160d68b,%rdi
  804160940c:	00 00 00 
  804160940f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609414:	49 bc 6e 8f 60 41 80 	movabs $0x8041608f6e,%r12
  804160941b:	00 00 00 
  804160941e:	41 ff d4             	callq  *%r12
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8041609421:	0f b7 b3 a0 00 00 00 	movzwl 0xa0(%rbx),%esi
  8041609428:	48 bf 9b d6 60 41 80 	movabs $0x804160d69b,%rdi
  804160942f:	00 00 00 
  8041609432:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609437:	41 ff d4             	callq  *%r12
  cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  804160943a:	48 8b b3 a8 00 00 00 	mov    0xa8(%rbx),%rsi
  8041609441:	48 bf ae d6 60 41 80 	movabs $0x804160d6ae,%rdi
  8041609448:	00 00 00 
  804160944b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609450:	41 ff d4             	callq  *%r12
  if ((tf->tf_cs & 3) != 0) {
  8041609453:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  804160945a:	75 6c                	jne    80416094c8 <print_trapframe+0x246>
}
  804160945c:	5b                   	pop    %rbx
  804160945d:	41 5c                	pop    %r12
  804160945f:	5d                   	pop    %rbp
  8041609460:	c3                   	retq   
    return excnames[trapno];
  8041609461:	48 63 c6             	movslq %esi,%rax
  8041609464:	48 ba c0 d8 60 41 80 	movabs $0x804160d8c0,%rdx
  804160946b:	00 00 00 
  804160946e:	48 8b 14 c2          	mov    (%rdx,%rax,8),%rdx
  8041609472:	e9 af fe ff ff       	jmpq   8041609326 <print_trapframe+0xa4>
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041609477:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  804160947e:	0e 
  804160947f:	0f 85 cf fe ff ff    	jne    8041609354 <print_trapframe+0xd2>
  __asm __volatile("movq %%cr2,%0"
  8041609485:	0f 20 d6             	mov    %cr2,%rsi
    cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  8041609488:	48 bf 5d d6 60 41 80 	movabs $0x804160d65d,%rdi
  804160948f:	00 00 00 
  8041609492:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609497:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160949e:	00 00 00 
  80416094a1:	ff d2                	callq  *%rdx
  80416094a3:	e9 ac fe ff ff       	jmpq   8041609354 <print_trapframe+0xd2>
    cprintf("\n");
  80416094a8:	48 bf 4f d3 60 41 80 	movabs $0x804160d34f,%rdi
  80416094af:	00 00 00 
  80416094b2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416094b7:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  80416094be:	00 00 00 
  80416094c1:	ff d2                	callq  *%rdx
  80416094c3:	e9 36 ff ff ff       	jmpq   80416093fe <print_trapframe+0x17c>
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
  80416094c8:	48 8b b3 b0 00 00 00 	mov    0xb0(%rbx),%rsi
  80416094cf:	48 bf be d6 60 41 80 	movabs $0x804160d6be,%rdi
  80416094d6:	00 00 00 
  80416094d9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416094de:	41 ff d4             	callq  *%r12
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  80416094e1:	0f b7 b3 b8 00 00 00 	movzwl 0xb8(%rbx),%esi
  80416094e8:	48 bf ce d6 60 41 80 	movabs $0x804160d6ce,%rdi
  80416094ef:	00 00 00 
  80416094f2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416094f7:	41 ff d4             	callq  *%r12
}
  80416094fa:	e9 5d ff ff ff       	jmpq   804160945c <print_trapframe+0x1da>

00000080416094ff <trap>:
    env_destroy(curenv);
  }
}

void
trap(struct Trapframe *tf) {
  80416094ff:	55                   	push   %rbp
  8041609500:	48 89 e5             	mov    %rsp,%rbp
  8041609503:	41 54                	push   %r12
  8041609505:	53                   	push   %rbx
  8041609506:	48 89 fb             	mov    %rdi,%rbx
  // The environment may have set DF and some versions
  // of GCC rely on DF being clear
  asm volatile("cld" ::
  8041609509:	fc                   	cld    
                   : "cc");

  // Halt the CPU if some other CPU has called panic()
  extern char *panicstr;
  if (panicstr)
  804160950a:	48 b8 60 41 70 41 80 	movabs $0x8041704160,%rax
  8041609511:	00 00 00 
  8041609514:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609518:	74 01                	je     804160951b <trap+0x1c>
    asm volatile("hlt");
  804160951a:	f4                   	hlt    
  __asm __volatile("pushfq; popq %0"
  804160951b:	9c                   	pushfq 
  804160951c:	58                   	pop    %rax

  // Check that interrupts are disabled.  If this assertion
  // fails, DO NOT be tempted to fix it by inserting a "cli" in
  // the interrupt path.
  assert(!(read_rflags() & FL_IF));
  804160951d:	f6 c4 02             	test   $0x2,%ah
  8041609520:	74 35                	je     8041609557 <trap+0x58>
  8041609522:	48 b9 e1 d6 60 41 80 	movabs $0x804160d6e1,%rcx
  8041609529:	00 00 00 
  804160952c:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041609533:	00 00 00 
  8041609536:	be ea 00 00 00       	mov    $0xea,%esi
  804160953b:	48 bf fa d6 60 41 80 	movabs $0x804160d6fa,%rdi
  8041609542:	00 00 00 
  8041609545:	b8 00 00 00 00       	mov    $0x0,%eax
  804160954a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609551:	00 00 00 
  8041609554:	41 ff d0             	callq  *%r8

  if (debug) {
    cprintf("Incoming TRAP frame at %p\n", tf);
  8041609557:	48 89 de             	mov    %rbx,%rsi
  804160955a:	48 bf 06 d7 60 41 80 	movabs $0x804160d706,%rdi
  8041609561:	00 00 00 
  8041609564:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609569:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041609570:	00 00 00 
  8041609573:	ff d2                	callq  *%rdx
  }

  assert(curenv);
  8041609575:	48 a1 f8 43 70 41 80 	movabs 0x80417043f8,%rax
  804160957c:	00 00 00 
  804160957f:	48 85 c0             	test   %rax,%rax
  8041609582:	0f 84 cd 00 00 00    	je     8041609655 <trap+0x156>

  // Garbage collect if current enviroment is a zombie
  if (curenv->env_status == ENV_DYING) {
  8041609588:	83 b8 d4 00 00 00 01 	cmpl   $0x1,0xd4(%rax)
  804160958f:	0f 84 f0 00 00 00    	je     8041609685 <trap+0x186>
  }

  // Copy trap frame (which is currently on the stack)
  // into 'curenv->env_tf', so that running the environment
  // will restart at the trap point.
  curenv->env_tf = *tf;
  8041609595:	b9 30 00 00 00       	mov    $0x30,%ecx
  804160959a:	48 89 c7             	mov    %rax,%rdi
  804160959d:	48 89 de             	mov    %rbx,%rsi
  80416095a0:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  // The trapframe on the stack should be ignored from here on.
  tf = &curenv->env_tf;
  80416095a2:	48 b8 f8 43 70 41 80 	movabs $0x80417043f8,%rax
  80416095a9:	00 00 00 
  80416095ac:	48 8b 18             	mov    (%rax),%rbx

  // Record that tf is the last real trapframe so
  // print_trapframe can print some additional information.
  last_tf = tf;
  80416095af:	48 89 d8             	mov    %rbx,%rax
  80416095b2:	48 a3 20 54 70 41 80 	movabs %rax,0x8041705420
  80416095b9:	00 00 00 
  if (tf->tf_trapno == T_SYSCALL) {
  80416095bc:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  80416095c3:	48 83 f8 30          	cmp    $0x30,%rax
  80416095c7:	0f 84 e4 00 00 00    	je     80416096b1 <trap+0x1b2>
  if (tf->tf_trapno == T_PGFLT) {
  80416095cd:	48 83 f8 0e          	cmp    $0xe,%rax
  80416095d1:	0f 84 07 01 00 00    	je     80416096de <trap+0x1df>
  if (tf->tf_trapno == T_BRKPT) {
  80416095d7:	48 83 f8 03          	cmp    $0x3,%rax
  80416095db:	0f 84 05 01 00 00    	je     80416096e6 <trap+0x1e7>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
  80416095e1:	48 83 f8 27          	cmp    $0x27,%rax
  80416095e5:	0f 84 0f 01 00 00    	je     80416096fa <trap+0x1fb>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {
  80416095eb:	48 83 f8 28          	cmp    $0x28,%rax
  80416095ef:	0f 84 34 01 00 00    	je     8041609729 <trap+0x22a>
  print_trapframe(tf);
  80416095f5:	48 89 df             	mov    %rbx,%rdi
  80416095f8:	48 b8 82 92 60 41 80 	movabs $0x8041609282,%rax
  80416095ff:	00 00 00 
  8041609602:	ff d0                	callq  *%rax
  if (!(tf->tf_cs & 0x3)) {
  8041609604:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  804160960b:	0f 84 31 01 00 00    	je     8041609742 <trap+0x243>
    env_destroy(curenv);
  8041609611:	48 b8 f8 43 70 41 80 	movabs $0x80417043f8,%rax
  8041609618:	00 00 00 
  804160961b:	48 8b 38             	mov    (%rax),%rdi
  804160961e:	48 b8 57 8b 60 41 80 	movabs $0x8041608b57,%rax
  8041609625:	00 00 00 
  8041609628:	ff d0                	callq  *%rax
  trap_dispatch(tf);

  // If we made it to this point, then no other environment was
  // scheduled, so we should return to the current environment
  // if doing so makes sense.
  if (curenv && curenv->env_status == ENV_RUNNING)
  804160962a:	48 b8 f8 43 70 41 80 	movabs $0x80417043f8,%rax
  8041609631:	00 00 00 
  8041609634:	48 8b 18             	mov    (%rax),%rbx
  8041609637:	48 85 db             	test   %rbx,%rbx
  804160963a:	74 0d                	je     8041609649 <trap+0x14a>
  804160963c:	83 bb d4 00 00 00 03 	cmpl   $0x3,0xd4(%rbx)
  8041609643:	0f 84 23 01 00 00    	je     804160976c <trap+0x26d>
    env_run(curenv);
  else
    sched_yield();
  8041609649:	48 b8 f4 a4 60 41 80 	movabs $0x804160a4f4,%rax
  8041609650:	00 00 00 
  8041609653:	ff d0                	callq  *%rax
  assert(curenv);
  8041609655:	48 b9 21 d7 60 41 80 	movabs $0x804160d721,%rcx
  804160965c:	00 00 00 
  804160965f:	48 ba d9 bf 60 41 80 	movabs $0x804160bfd9,%rdx
  8041609666:	00 00 00 
  8041609669:	be f0 00 00 00       	mov    $0xf0,%esi
  804160966e:	48 bf fa d6 60 41 80 	movabs $0x804160d6fa,%rdi
  8041609675:	00 00 00 
  8041609678:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160967f:	00 00 00 
  8041609682:	41 ff d0             	callq  *%r8
    env_free(curenv);
  8041609685:	48 89 c7             	mov    %rax,%rdi
  8041609688:	48 b8 4c 88 60 41 80 	movabs $0x804160884c,%rax
  804160968f:	00 00 00 
  8041609692:	ff d0                	callq  *%rax
    curenv = NULL;
  8041609694:	48 b8 f8 43 70 41 80 	movabs $0x80417043f8,%rax
  804160969b:	00 00 00 
  804160969e:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    sched_yield();
  80416096a5:	48 b8 f4 a4 60 41 80 	movabs $0x804160a4f4,%rax
  80416096ac:	00 00 00 
  80416096af:	ff d0                	callq  *%rax
    ret                 = syscall(syscallno, a1, a2, a3, a4, a5);
  80416096b1:	48 8b 4b 68          	mov    0x68(%rbx),%rcx
  80416096b5:	48 8b 53 60          	mov    0x60(%rbx),%rdx
  80416096b9:	48 8b 73 58          	mov    0x58(%rbx),%rsi
  80416096bd:	48 8b 7b 70          	mov    0x70(%rbx),%rdi
  80416096c1:	4c 8b 4b 40          	mov    0x40(%rbx),%r9
  80416096c5:	4c 8b 43 48          	mov    0x48(%rbx),%r8
  80416096c9:	48 b8 7f a5 60 41 80 	movabs $0x804160a57f,%rax
  80416096d0:	00 00 00 
  80416096d3:	ff d0                	callq  *%rax
    tf->tf_regs.reg_rax = ret;
  80416096d5:	48 89 43 70          	mov    %rax,0x70(%rbx)
    return;
  80416096d9:	e9 4c ff ff ff       	jmpq   804160962a <trap+0x12b>
  __asm __volatile("movq %%cr2,%0"
  80416096de:	0f 20 d0             	mov    %cr2,%rax
  if (curenv && curenv->env_status == ENV_RUNNING)
  80416096e1:	e9 56 ff ff ff       	jmpq   804160963c <trap+0x13d>
    monitor(tf);
  80416096e6:	48 89 df             	mov    %rbx,%rdi
  80416096e9:	48 b8 47 3f 60 41 80 	movabs $0x8041603f47,%rax
  80416096f0:	00 00 00 
  80416096f3:	ff d0                	callq  *%rax
    return;
  80416096f5:	e9 30 ff ff ff       	jmpq   804160962a <trap+0x12b>
    cprintf("Spurious interrupt on irq 7\n");
  80416096fa:	48 bf 28 d7 60 41 80 	movabs $0x804160d728,%rdi
  8041609701:	00 00 00 
  8041609704:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609709:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  8041609710:	00 00 00 
  8041609713:	ff d2                	callq  *%rdx
    print_trapframe(tf);
  8041609715:	48 89 df             	mov    %rbx,%rdi
  8041609718:	48 b8 82 92 60 41 80 	movabs $0x8041609282,%rax
  804160971f:	00 00 00 
  8041609722:	ff d0                	callq  *%rax
    return;
  8041609724:	e9 01 ff ff ff       	jmpq   804160962a <trap+0x12b>
    timer_for_schedule->handle_interrupts();
  8041609729:	48 a1 40 59 70 41 80 	movabs 0x8041705940,%rax
  8041609730:	00 00 00 
  8041609733:	ff 50 20             	callq  *0x20(%rax)
    sched_yield();
  8041609736:	48 b8 f4 a4 60 41 80 	movabs $0x804160a4f4,%rax
  804160973d:	00 00 00 
  8041609740:	ff d0                	callq  *%rax
    panic("unhandled trap in kernel");
  8041609742:	48 ba 45 d7 60 41 80 	movabs $0x804160d745,%rdx
  8041609749:	00 00 00 
  804160974c:	be d5 00 00 00       	mov    $0xd5,%esi
  8041609751:	48 bf fa d6 60 41 80 	movabs $0x804160d6fa,%rdi
  8041609758:	00 00 00 
  804160975b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609760:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609767:	00 00 00 
  804160976a:	ff d1                	callq  *%rcx
    env_run(curenv);
  804160976c:	48 89 df             	mov    %rbx,%rdi
  804160976f:	48 b8 1d 8c 60 41 80 	movabs $0x8041608c1d,%rax
  8041609776:	00 00 00 
  8041609779:	ff d0                	callq  *%rax

000000804160977b <page_fault_handler>:
  804160977b:	0f 20 d0             	mov    %cr2,%rax
  // Handle kernel-mode page faults.

  // LAB 8: Your code here.


}
  804160977e:	c3                   	retq   
  804160977f:	90                   	nop

0000008041609780 <_alltraps>:

.globl _alltraps
.type _alltraps, @function;
.align 2
_alltraps:
  subq $8,%rsp
  8041609780:	48 83 ec 08          	sub    $0x8,%rsp
  movw %ds,(%rsp)
  8041609784:	8c 1c 24             	mov    %ds,(%rsp)
  subq $8,%rsp
  8041609787:	48 83 ec 08          	sub    $0x8,%rsp
  movw %es,(%rsp)
  804160978b:	8c 04 24             	mov    %es,(%rsp)
  PUSHA
  804160978e:	48 83 ec 78          	sub    $0x78,%rsp
  8041609792:	48 89 44 24 70       	mov    %rax,0x70(%rsp)
  8041609797:	48 89 5c 24 68       	mov    %rbx,0x68(%rsp)
  804160979c:	48 89 4c 24 60       	mov    %rcx,0x60(%rsp)
  80416097a1:	48 89 54 24 58       	mov    %rdx,0x58(%rsp)
  80416097a6:	48 89 6c 24 50       	mov    %rbp,0x50(%rsp)
  80416097ab:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
  80416097b0:	48 89 74 24 40       	mov    %rsi,0x40(%rsp)
  80416097b5:	4c 89 44 24 38       	mov    %r8,0x38(%rsp)
  80416097ba:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
  80416097bf:	4c 89 54 24 28       	mov    %r10,0x28(%rsp)
  80416097c4:	4c 89 5c 24 20       	mov    %r11,0x20(%rsp)
  80416097c9:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
  80416097ce:	4c 89 6c 24 10       	mov    %r13,0x10(%rsp)
  80416097d3:	4c 89 74 24 08       	mov    %r14,0x8(%rsp)
  80416097d8:	4c 89 3c 24          	mov    %r15,(%rsp)
  movq $GD_KD,%rax
  80416097dc:	48 c7 c0 10 00 00 00 	mov    $0x10,%rax
  movq %rax,%ds
  80416097e3:	48 8e d8             	mov    %rax,%ds
  movq %rax,%es
  80416097e6:	48 8e c0             	mov    %rax,%es
  movq %rsp,%rdi
  80416097e9:	48 89 e7             	mov    %rsp,%rdi
  call trap
  80416097ec:	e8 0e fd ff ff       	callq  80416094ff <trap>
  jmp .
  80416097f1:	eb fe                	jmp    80416097f1 <_alltraps+0x71>
  80416097f3:	90                   	nop

00000080416097f4 <clock_thdlr>:
  xorl %ebp, %ebp
  movq %rsp,%rdi
  call trap
  jmp .
#else
TRAPHANDLER_NOEC(clock_thdlr, IRQ_OFFSET + IRQ_CLOCK)
  80416097f4:	6a 00                	pushq  $0x0
  80416097f6:	6a 28                	pushq  $0x28
  80416097f8:	eb 86                	jmp    8041609780 <_alltraps>

00000080416097fa <acpi_find_table>:
  return krsdp;
}

// LAB 5 code
static void *
acpi_find_table(const char *sign) {
  80416097fa:	55                   	push   %rbp
  80416097fb:	48 89 e5             	mov    %rsp,%rbp
  80416097fe:	41 57                	push   %r15
  8041609800:	41 56                	push   %r14
  8041609802:	41 55                	push   %r13
  8041609804:	41 54                	push   %r12
  8041609806:	53                   	push   %rbx
  8041609807:	48 83 ec 28          	sub    $0x28,%rsp
  804160980b:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  static size_t krsdt_len;
  static size_t krsdt_entsz;

  uint8_t cksm = 0;

  if (!krsdt) {
  804160980f:	48 b8 c0 54 70 41 80 	movabs $0x80417054c0,%rax
  8041609816:	00 00 00 
  8041609819:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160981d:	74 3d                	je     804160985c <acpi_find_table+0x62>
    }
  }

  ACPISDTHeader *hd = NULL;

  for (size_t i = 0; i < krsdt_len; i++) {
  804160981f:	48 b8 b0 54 70 41 80 	movabs $0x80417054b0,%rax
  8041609826:	00 00 00 
  8041609829:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160982d:	0f 84 f2 03 00 00    	je     8041609c25 <acpi_find_table+0x42b>
  8041609833:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    /* Assume little endian */
    uint64_t fadt_pa = 0;
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  8041609839:	49 bf b8 54 70 41 80 	movabs $0x80417054b8,%r15
  8041609840:	00 00 00 
  8041609843:	49 bd c0 54 70 41 80 	movabs $0x80417054c0,%r13
  804160984a:	00 00 00 
  804160984d:	49 be 6a b5 60 41 80 	movabs $0x804160b56a,%r14
  8041609854:	00 00 00 
  8041609857:	e9 04 03 00 00       	jmpq   8041609b60 <acpi_find_table+0x366>
    if (!uefi_lp->ACPIRoot) {
  804160985c:	48 a1 00 f0 61 41 80 	movabs 0x804161f000,%rax
  8041609863:	00 00 00 
  8041609866:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160986a:	48 85 ff             	test   %rdi,%rdi
  804160986d:	74 7c                	je     80416098eb <acpi_find_table+0xf1>
    RSDP *krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  804160986f:	be 24 00 00 00       	mov    $0x24,%esi
  8041609874:	48 b8 54 83 60 41 80 	movabs $0x8041608354,%rax
  804160987b:	00 00 00 
  804160987e:	ff d0                	callq  *%rax
  8041609880:	49 89 c4             	mov    %rax,%r12
    if (strncmp(krsdp->Signature, "RSD PTR", 8))
  8041609883:	ba 08 00 00 00       	mov    $0x8,%edx
  8041609888:	48 be 7b d9 60 41 80 	movabs $0x804160d97b,%rsi
  804160988f:	00 00 00 
  8041609892:	48 89 c7             	mov    %rax,%rdi
  8041609895:	48 b8 27 b4 60 41 80 	movabs $0x804160b427,%rax
  804160989c:	00 00 00 
  804160989f:	ff d0                	callq  *%rax
  80416098a1:	85 c0                	test   %eax,%eax
  80416098a3:	74 70                	je     8041609915 <acpi_find_table+0x11b>
  80416098a5:	4c 89 e0             	mov    %r12,%rax
  80416098a8:	49 8d 54 24 14       	lea    0x14(%r12),%rdx
  uint8_t cksm = 0;
  80416098ad:	bb 00 00 00 00       	mov    $0x0,%ebx
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  80416098b2:	02 18                	add    (%rax),%bl
    for (size_t i = 0; i < offsetof(RSDP, Length); i++)
  80416098b4:	48 83 c0 01          	add    $0x1,%rax
  80416098b8:	48 39 d0             	cmp    %rdx,%rax
  80416098bb:	75 f5                	jne    80416098b2 <acpi_find_table+0xb8>
    if (cksm)
  80416098bd:	84 db                	test   %bl,%bl
  80416098bf:	74 59                	je     804160991a <acpi_find_table+0x120>
      panic("Invalid RSDP");
  80416098c1:	48 ba 83 d9 60 41 80 	movabs $0x804160d983,%rdx
  80416098c8:	00 00 00 
  80416098cb:	be 7e 00 00 00       	mov    $0x7e,%esi
  80416098d0:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  80416098d7:	00 00 00 
  80416098da:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098df:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416098e6:	00 00 00 
  80416098e9:	ff d1                	callq  *%rcx
      panic("No rsdp\n");
  80416098eb:	48 ba 65 d9 60 41 80 	movabs $0x804160d965,%rdx
  80416098f2:	00 00 00 
  80416098f5:	be 74 00 00 00       	mov    $0x74,%esi
  80416098fa:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  8041609901:	00 00 00 
  8041609904:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609909:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609910:	00 00 00 
  8041609913:	ff d1                	callq  *%rcx
  uint8_t cksm = 0;
  8041609915:	bb 00 00 00 00       	mov    $0x0,%ebx
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  804160991a:	45 8b 74 24 10       	mov    0x10(%r12),%r14d
    krsdt_entsz      = 4;
  804160991f:	48 b8 b8 54 70 41 80 	movabs $0x80417054b8,%rax
  8041609926:	00 00 00 
  8041609929:	48 c7 00 04 00 00 00 	movq   $0x4,(%rax)
    if (krsdp->Revision) {
  8041609930:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  8041609936:	0f 84 1b 01 00 00    	je     8041609a57 <acpi_find_table+0x25d>
      for (size_t i = 0; i < krsdp->Length; i++)
  804160993c:	41 8b 54 24 14       	mov    0x14(%r12),%edx
  8041609941:	48 85 d2             	test   %rdx,%rdx
  8041609944:	74 11                	je     8041609957 <acpi_find_table+0x15d>
  8041609946:	4c 89 e0             	mov    %r12,%rax
  8041609949:	4c 01 e2             	add    %r12,%rdx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160994c:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < krsdp->Length; i++)
  804160994e:	48 83 c0 01          	add    $0x1,%rax
  8041609952:	48 39 c2             	cmp    %rax,%rdx
  8041609955:	75 f5                	jne    804160994c <acpi_find_table+0x152>
      if (cksm)
  8041609957:	84 db                	test   %bl,%bl
  8041609959:	0f 85 4c 01 00 00    	jne    8041609aab <acpi_find_table+0x2b1>
      rsdt_pa     = krsdp->XsdtAddress;
  804160995f:	4d 8b 74 24 18       	mov    0x18(%r12),%r14
      krsdt_entsz = 8;
  8041609964:	48 b8 b8 54 70 41 80 	movabs $0x80417054b8,%rax
  804160996b:	00 00 00 
  804160996e:	48 c7 00 08 00 00 00 	movq   $0x8,(%rax)
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  8041609975:	be 24 00 00 00       	mov    $0x24,%esi
  804160997a:	4c 89 f7             	mov    %r14,%rdi
  804160997d:	48 b8 54 83 60 41 80 	movabs $0x8041608354,%rax
  8041609984:	00 00 00 
  8041609987:	ff d0                	callq  *%rax
  8041609989:	49 bd c0 54 70 41 80 	movabs $0x80417054c0,%r13
  8041609990:	00 00 00 
  8041609993:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  8041609997:	8b 48 04             	mov    0x4(%rax),%ecx
  804160999a:	ba 24 00 00 00       	mov    $0x24,%edx
  804160999f:	48 89 c6             	mov    %rax,%rsi
  80416099a2:	4c 89 f7             	mov    %r14,%rdi
  80416099a5:	48 b8 0a 84 60 41 80 	movabs $0x804160840a,%rax
  80416099ac:	00 00 00 
  80416099af:	ff d0                	callq  *%rax
  80416099b1:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  80416099b5:	8b 48 04             	mov    0x4(%rax),%ecx
  80416099b8:	48 85 c9             	test   %rcx,%rcx
  80416099bb:	74 19                	je     80416099d6 <acpi_find_table+0x1dc>
  80416099bd:	48 89 c2             	mov    %rax,%rdx
  80416099c0:	48 01 c1             	add    %rax,%rcx
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdt)[i]);
  80416099c3:	02 1a                	add    (%rdx),%bl
    for (size_t i = 0; i < krsdt->h.Length; i++)
  80416099c5:	48 83 c2 01          	add    $0x1,%rdx
  80416099c9:	48 39 d1             	cmp    %rdx,%rcx
  80416099cc:	75 f5                	jne    80416099c3 <acpi_find_table+0x1c9>
    if (cksm)
  80416099ce:	84 db                	test   %bl,%bl
  80416099d0:	0f 85 ff 00 00 00    	jne    8041609ad5 <acpi_find_table+0x2db>
    if (strncmp(krsdt->h.Signature, krsdp->Revision ? "XSDT" : "RSDT", 4))
  80416099d6:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  80416099dc:	48 be 60 d9 60 41 80 	movabs $0x804160d960,%rsi
  80416099e3:	00 00 00 
  80416099e6:	48 ba 98 d9 60 41 80 	movabs $0x804160d998,%rdx
  80416099ed:	00 00 00 
  80416099f0:	48 0f 44 f2          	cmove  %rdx,%rsi
  80416099f4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416099f9:	48 89 c7             	mov    %rax,%rdi
  80416099fc:	48 b8 27 b4 60 41 80 	movabs $0x804160b427,%rax
  8041609a03:	00 00 00 
  8041609a06:	ff d0                	callq  *%rax
  8041609a08:	85 c0                	test   %eax,%eax
  8041609a0a:	0f 85 ef 00 00 00    	jne    8041609aff <acpi_find_table+0x305>
    krsdt_len = (krsdt->h.Length - sizeof(RSDT)) / 4;
  8041609a10:	48 a1 c0 54 70 41 80 	movabs 0x80417054c0,%rax
  8041609a17:	00 00 00 
  8041609a1a:	8b 40 04             	mov    0x4(%rax),%eax
  8041609a1d:	48 8d 58 dc          	lea    -0x24(%rax),%rbx
  8041609a21:	48 89 da             	mov    %rbx,%rdx
  8041609a24:	48 c1 ea 02          	shr    $0x2,%rdx
  8041609a28:	48 89 d0             	mov    %rdx,%rax
  8041609a2b:	48 a3 b0 54 70 41 80 	movabs %rax,0x80417054b0
  8041609a32:	00 00 00 
    if (krsdp->Revision) {
  8041609a35:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  8041609a3b:	0f 84 de fd ff ff    	je     804160981f <acpi_find_table+0x25>
      krsdt_len = krsdt_len / 2;
  8041609a41:	48 89 d8             	mov    %rbx,%rax
  8041609a44:	48 c1 e8 03          	shr    $0x3,%rax
  8041609a48:	48 a3 b0 54 70 41 80 	movabs %rax,0x80417054b0
  8041609a4f:	00 00 00 
  8041609a52:	e9 c8 fd ff ff       	jmpq   804160981f <acpi_find_table+0x25>
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  8041609a57:	45 89 f6             	mov    %r14d,%r14d
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  8041609a5a:	be 24 00 00 00       	mov    $0x24,%esi
  8041609a5f:	4c 89 f7             	mov    %r14,%rdi
  8041609a62:	48 b8 54 83 60 41 80 	movabs $0x8041608354,%rax
  8041609a69:	00 00 00 
  8041609a6c:	ff d0                	callq  *%rax
  8041609a6e:	49 bd c0 54 70 41 80 	movabs $0x80417054c0,%r13
  8041609a75:	00 00 00 
  8041609a78:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  8041609a7c:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609a7f:	ba 24 00 00 00       	mov    $0x24,%edx
  8041609a84:	48 89 c6             	mov    %rax,%rsi
  8041609a87:	4c 89 f7             	mov    %r14,%rdi
  8041609a8a:	48 b8 0a 84 60 41 80 	movabs $0x804160840a,%rax
  8041609a91:	00 00 00 
  8041609a94:	ff d0                	callq  *%rax
  8041609a96:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  8041609a9a:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609a9d:	48 85 c9             	test   %rcx,%rcx
  8041609aa0:	0f 85 17 ff ff ff    	jne    80416099bd <acpi_find_table+0x1c3>
  8041609aa6:	e9 23 ff ff ff       	jmpq   80416099ce <acpi_find_table+0x1d4>
        panic("Invalid RSDP");
  8041609aab:	48 ba 83 d9 60 41 80 	movabs $0x804160d983,%rdx
  8041609ab2:	00 00 00 
  8041609ab5:	be 88 00 00 00       	mov    $0x88,%esi
  8041609aba:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  8041609ac1:	00 00 00 
  8041609ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ac9:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609ad0:	00 00 00 
  8041609ad3:	ff d1                	callq  *%rcx
      panic("Invalid RSDP");
  8041609ad5:	48 ba 83 d9 60 41 80 	movabs $0x804160d983,%rdx
  8041609adc:	00 00 00 
  8041609adf:	be 96 00 00 00       	mov    $0x96,%esi
  8041609ae4:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  8041609aeb:	00 00 00 
  8041609aee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609af3:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609afa:	00 00 00 
  8041609afd:	ff d1                	callq  *%rcx
      panic("Invalid RSDT");
  8041609aff:	48 ba 90 d9 60 41 80 	movabs $0x804160d990,%rdx
  8041609b06:	00 00 00 
  8041609b09:	be 99 00 00 00       	mov    $0x99,%esi
  8041609b0e:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  8041609b15:	00 00 00 
  8041609b18:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b1d:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609b24:	00 00 00 
  8041609b27:	ff d1                	callq  *%rcx

    for (size_t i = 0; i < hd->Length; i++)
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
    if (cksm)
      panic("ACPI table '%.4s' invalid", hd->Signature);
    if (!strncmp(hd->Signature, sign, 4))
  8041609b29:	ba 04 00 00 00       	mov    $0x4,%edx
  8041609b2e:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8041609b32:	48 89 df             	mov    %rbx,%rdi
  8041609b35:	48 b8 27 b4 60 41 80 	movabs $0x804160b427,%rax
  8041609b3c:	00 00 00 
  8041609b3f:	ff d0                	callq  *%rax
  8041609b41:	85 c0                	test   %eax,%eax
  8041609b43:	0f 84 ca 00 00 00    	je     8041609c13 <acpi_find_table+0x419>
  for (size_t i = 0; i < krsdt_len; i++) {
  8041609b49:	49 83 c4 01          	add    $0x1,%r12
  8041609b4d:	48 b8 b0 54 70 41 80 	movabs $0x80417054b0,%rax
  8041609b54:	00 00 00 
  8041609b57:	4c 39 20             	cmp    %r12,(%rax)
  8041609b5a:	0f 86 ae 00 00 00    	jbe    8041609c0e <acpi_find_table+0x414>
    uint64_t fadt_pa = 0;
  8041609b60:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041609b67:	00 
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  8041609b68:	49 8b 17             	mov    (%r15),%rdx
  8041609b6b:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041609b6f:	48 89 d0             	mov    %rdx,%rax
  8041609b72:	49 0f af c4          	imul   %r12,%rax
  8041609b76:	48 8d 74 01 24       	lea    0x24(%rcx,%rax,1),%rsi
  8041609b7b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041609b7f:	41 ff d6             	callq  *%r14
    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
  8041609b82:	be 24 00 00 00       	mov    $0x24,%esi
  8041609b87:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041609b8b:	48 b8 54 83 60 41 80 	movabs $0x8041608354,%rax
  8041609b92:	00 00 00 
  8041609b95:	ff d0                	callq  *%rax
    hd = mmio_remap_last_region(fadt_pa, hd, sizeof(ACPISDTHeader), krsdt->h.Length);
  8041609b97:	49 8b 55 00          	mov    0x0(%r13),%rdx
  8041609b9b:	8b 4a 04             	mov    0x4(%rdx),%ecx
  8041609b9e:	ba 24 00 00 00       	mov    $0x24,%edx
  8041609ba3:	48 89 c6             	mov    %rax,%rsi
  8041609ba6:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041609baa:	48 b8 0a 84 60 41 80 	movabs $0x804160840a,%rax
  8041609bb1:	00 00 00 
  8041609bb4:	ff d0                	callq  *%rax
  8041609bb6:	48 89 c3             	mov    %rax,%rbx
    for (size_t i = 0; i < hd->Length; i++)
  8041609bb9:	8b 48 04             	mov    0x4(%rax),%ecx
  8041609bbc:	48 85 c9             	test   %rcx,%rcx
  8041609bbf:	0f 84 64 ff ff ff    	je     8041609b29 <acpi_find_table+0x32f>
  8041609bc5:	48 01 c1             	add    %rax,%rcx
  8041609bc8:	ba 00 00 00 00       	mov    $0x0,%edx
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
  8041609bcd:	02 10                	add    (%rax),%dl
    for (size_t i = 0; i < hd->Length; i++)
  8041609bcf:	48 83 c0 01          	add    $0x1,%rax
  8041609bd3:	48 39 c1             	cmp    %rax,%rcx
  8041609bd6:	75 f5                	jne    8041609bcd <acpi_find_table+0x3d3>
    if (cksm)
  8041609bd8:	84 d2                	test   %dl,%dl
  8041609bda:	0f 84 49 ff ff ff    	je     8041609b29 <acpi_find_table+0x32f>
      panic("ACPI table '%.4s' invalid", hd->Signature);
  8041609be0:	48 89 d9             	mov    %rbx,%rcx
  8041609be3:	48 ba 9d d9 60 41 80 	movabs $0x804160d99d,%rdx
  8041609bea:	00 00 00 
  8041609bed:	be af 00 00 00       	mov    $0xaf,%esi
  8041609bf2:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  8041609bf9:	00 00 00 
  8041609bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c01:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609c08:	00 00 00 
  8041609c0b:	41 ff d0             	callq  *%r8
      return hd;
  }

  return NULL;
  8041609c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8041609c13:	48 89 d8             	mov    %rbx,%rax
  8041609c16:	48 83 c4 28          	add    $0x28,%rsp
  8041609c1a:	5b                   	pop    %rbx
  8041609c1b:	41 5c                	pop    %r12
  8041609c1d:	41 5d                	pop    %r13
  8041609c1f:	41 5e                	pop    %r14
  8041609c21:	41 5f                	pop    %r15
  8041609c23:	5d                   	pop    %rbp
  8041609c24:	c3                   	retq   
  return NULL;
  8041609c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041609c2a:	eb e7                	jmp    8041609c13 <acpi_find_table+0x419>

0000008041609c2c <hpet_handle_interrupts_tim0>:
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
}

void
hpet_handle_interrupts_tim0(void) {
  8041609c2c:	55                   	push   %rbp
  8041609c2d:	48 89 e5             	mov    %rsp,%rbp
  pic_send_eoi(IRQ_TIMER);
  8041609c30:	bf 00 00 00 00       	mov    $0x0,%edi
  8041609c35:	48 b8 fb 8e 60 41 80 	movabs $0x8041608efb,%rax
  8041609c3c:	00 00 00 
  8041609c3f:	ff d0                	callq  *%rax
}
  8041609c41:	5d                   	pop    %rbp
  8041609c42:	c3                   	retq   

0000008041609c43 <hpet_handle_interrupts_tim1>:

void
hpet_handle_interrupts_tim1(void) {
  8041609c43:	55                   	push   %rbp
  8041609c44:	48 89 e5             	mov    %rsp,%rbp
  pic_send_eoi(IRQ_CLOCK);
  8041609c47:	bf 08 00 00 00       	mov    $0x8,%edi
  8041609c4c:	48 b8 fb 8e 60 41 80 	movabs $0x8041608efb,%rax
  8041609c53:	00 00 00 
  8041609c56:	ff d0                	callq  *%rax
}
  8041609c58:	5d                   	pop    %rbp
  8041609c59:	c3                   	retq   

0000008041609c5a <hpet_cpu_frequency>:
// about pause instruction.
uint64_t
hpet_cpu_frequency(void) {
  // LAB 5 Your code here.
  uint64_t time_res = 100;
  uint64_t delta = 0, target = hpetFreq / time_res;
  8041609c5a:	48 a1 d8 54 70 41 80 	movabs 0x80417054d8,%rax
  8041609c61:	00 00 00 
  8041609c64:	48 c1 e8 02          	shr    $0x2,%rax
  8041609c68:	48 ba c3 f5 28 5c 8f 	movabs $0x28f5c28f5c28f5c3,%rdx
  8041609c6f:	c2 f5 28 
  8041609c72:	48 f7 e2             	mul    %rdx
  8041609c75:	48 89 d1             	mov    %rdx,%rcx
  8041609c78:	48 c1 e9 02          	shr    $0x2,%rcx
  return hpetReg->MAIN_CNT;
  8041609c7c:	48 a1 e8 54 70 41 80 	movabs 0x80417054e8,%rax
  8041609c83:	00 00 00 
  8041609c86:	48 8b b8 f0 00 00 00 	mov    0xf0(%rax),%rdi
  __asm __volatile("rdtsc"
  8041609c8d:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041609c8f:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609c93:	41 89 c0             	mov    %eax,%r8d
  8041609c96:	49 09 d0             	or     %rdx,%r8
  8041609c99:	48 be e8 54 70 41 80 	movabs $0x80417054e8,%rsi
  8041609ca0:	00 00 00 

  uint64_t tick0 = hpet_get_main_cnt();
  uint64_t tsc0  = read_tsc();
  do {
    asm("pause");
  8041609ca3:	f3 90                	pause  
  return hpetReg->MAIN_CNT;
  8041609ca5:	48 8b 06             	mov    (%rsi),%rax
  8041609ca8:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
    delta = hpet_get_main_cnt() - tick0;
  8041609caf:	48 29 f8             	sub    %rdi,%rax
  } while (delta < target);
  8041609cb2:	48 39 c1             	cmp    %rax,%rcx
  8041609cb5:	77 ec                	ja     8041609ca3 <hpet_cpu_frequency+0x49>
  __asm __volatile("rdtsc"
  8041609cb7:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  8041609cb9:	48 c1 e2 20          	shl    $0x20,%rdx
  8041609cbd:	89 c0                	mov    %eax,%eax
  8041609cbf:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * time_res;
  8041609cc2:	48 89 d0             	mov    %rdx,%rax
  8041609cc5:	4c 29 c0             	sub    %r8,%rax
  8041609cc8:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  8041609ccc:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  8041609cd0:	48 c1 e0 02          	shl    $0x2,%rax
}
  8041609cd4:	c3                   	retq   

0000008041609cd5 <hpet_enable_interrupts_tim1>:
hpet_enable_interrupts_tim1(void) {
  8041609cd5:	55                   	push   %rbp
  8041609cd6:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  8041609cd9:	48 b8 e8 54 70 41 80 	movabs $0x80417054e8,%rax
  8041609ce0:	00 00 00 
  8041609ce3:	48 8b 08             	mov    (%rax),%rcx
  8041609ce6:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041609cea:	48 83 c8 02          	or     $0x2,%rax
  8041609cee:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM1_CONF = (IRQ_CLOCK << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  8041609cf2:	48 c7 81 20 01 00 00 	movq   $0x104c,0x120(%rcx)
  8041609cf9:	4c 10 00 00 
  return hpetReg->MAIN_CNT;
  8041609cfd:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM1_COMP = hpet_get_main_cnt() + 3 * Peta / 2 / hpetFemto;
  8041609d04:	48 bf e0 54 70 41 80 	movabs $0x80417054e0,%rdi
  8041609d0b:	00 00 00 
  8041609d0e:	48 b8 00 c0 29 f7 3d 	movabs $0x5543df729c000,%rax
  8041609d15:	54 05 00 
  8041609d18:	ba 00 00 00 00       	mov    $0x0,%edx
  8041609d1d:	48 f7 37             	divq   (%rdi)
  8041609d20:	48 01 c6             	add    %rax,%rsi
  8041609d23:	48 89 b1 28 01 00 00 	mov    %rsi,0x128(%rcx)
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  8041609d2a:	48 89 81 28 01 00 00 	mov    %rax,0x128(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  8041609d31:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  8041609d38:	00 00 00 
  8041609d3b:	89 c7                	mov    %eax,%edi
  8041609d3d:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  8041609d43:	48 b8 96 8d 60 41 80 	movabs $0x8041608d96,%rax
  8041609d4a:	00 00 00 
  8041609d4d:	ff d0                	callq  *%rax
}
  8041609d4f:	5d                   	pop    %rbp
  8041609d50:	c3                   	retq   

0000008041609d51 <hpet_enable_interrupts_tim0>:
hpet_enable_interrupts_tim0(void) {
  8041609d51:	55                   	push   %rbp
  8041609d52:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  8041609d55:	48 b8 e8 54 70 41 80 	movabs $0x80417054e8,%rax
  8041609d5c:	00 00 00 
  8041609d5f:	48 8b 08             	mov    (%rax),%rcx
  8041609d62:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041609d66:	48 83 c8 02          	or     $0x2,%rax
  8041609d6a:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM0_CONF = (IRQ_TIMER << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  8041609d6e:	48 c7 81 00 01 00 00 	movq   $0x4c,0x100(%rcx)
  8041609d75:	4c 00 00 00 
  return hpetReg->MAIN_CNT;
  8041609d79:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM0_COMP = hpet_get_main_cnt() + Peta / 2 / hpetFemto;
  8041609d80:	48 bf e0 54 70 41 80 	movabs $0x80417054e0,%rdi
  8041609d87:	00 00 00 
  8041609d8a:	48 b8 00 40 63 52 bf 	movabs $0x1c6bf52634000,%rax
  8041609d91:	c6 01 00 
  8041609d94:	ba 00 00 00 00       	mov    $0x0,%edx
  8041609d99:	48 f7 37             	divq   (%rdi)
  8041609d9c:	48 01 c6             	add    %rax,%rsi
  8041609d9f:	48 89 b1 08 01 00 00 	mov    %rsi,0x108(%rcx)
  hpetReg->TIM0_COMP = Peta / 2 / hpetFemto;
  8041609da6:	48 89 81 08 01 00 00 	mov    %rax,0x108(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_TIMER));
  8041609dad:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  8041609db4:	00 00 00 
  8041609db7:	89 c7                	mov    %eax,%edi
  8041609db9:	81 e7 fe ff 00 00    	and    $0xfffe,%edi
  8041609dbf:	48 b8 96 8d 60 41 80 	movabs $0x8041608d96,%rax
  8041609dc6:	00 00 00 
  8041609dc9:	ff d0                	callq  *%rax
}
  8041609dcb:	5d                   	pop    %rbp
  8041609dcc:	c3                   	retq   

0000008041609dcd <check_sum>:
  switch (type) {
  8041609dcd:	85 f6                	test   %esi,%esi
  8041609dcf:	74 0f                	je     8041609de0 <check_sum+0x13>
  uint32_t len = 0;
  8041609dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  switch (type) {
  8041609dd6:	83 fe 01             	cmp    $0x1,%esi
  8041609dd9:	75 08                	jne    8041609de3 <check_sum+0x16>
      len = ((ACPISDTHeader *)Table)->Length;
  8041609ddb:	8b 57 04             	mov    0x4(%rdi),%edx
      break;
  8041609dde:	eb 03                	jmp    8041609de3 <check_sum+0x16>
      len = ((RSDP *)Table)->Length;
  8041609de0:	8b 57 14             	mov    0x14(%rdi),%edx
  for (int i = 0; i < len; i++)
  8041609de3:	85 d2                	test   %edx,%edx
  8041609de5:	74 24                	je     8041609e0b <check_sum+0x3e>
  8041609de7:	48 89 f8             	mov    %rdi,%rax
  8041609dea:	8d 52 ff             	lea    -0x1(%rdx),%edx
  8041609ded:	48 8d 74 17 01       	lea    0x1(%rdi,%rdx,1),%rsi
  int sum      = 0;
  8041609df2:	ba 00 00 00 00       	mov    $0x0,%edx
    sum += ((uint8_t *)Table)[i];
  8041609df7:	0f b6 08             	movzbl (%rax),%ecx
  8041609dfa:	01 ca                	add    %ecx,%edx
  for (int i = 0; i < len; i++)
  8041609dfc:	48 83 c0 01          	add    $0x1,%rax
  8041609e00:	48 39 f0             	cmp    %rsi,%rax
  8041609e03:	75 f2                	jne    8041609df7 <check_sum+0x2a>
  if (sum % 0x100 == 0)
  8041609e05:	84 d2                	test   %dl,%dl
  8041609e07:	0f 94 c0             	sete   %al
}
  8041609e0a:	c3                   	retq   
  int sum      = 0;
  8041609e0b:	ba 00 00 00 00       	mov    $0x0,%edx
  8041609e10:	eb f3                	jmp    8041609e05 <check_sum+0x38>

0000008041609e12 <get_rsdp>:
  if (krsdp != NULL)
  8041609e12:	48 a1 d0 54 70 41 80 	movabs 0x80417054d0,%rax
  8041609e19:	00 00 00 
  8041609e1c:	48 85 c0             	test   %rax,%rax
  8041609e1f:	74 01                	je     8041609e22 <get_rsdp+0x10>
}
  8041609e21:	c3                   	retq   
get_rsdp(void) {
  8041609e22:	55                   	push   %rbp
  8041609e23:	48 89 e5             	mov    %rsp,%rbp
  if (uefi_lp->ACPIRoot == 0)
  8041609e26:	48 a1 00 f0 61 41 80 	movabs 0x804161f000,%rax
  8041609e2d:	00 00 00 
  8041609e30:	48 8b 78 10          	mov    0x10(%rax),%rdi
  8041609e34:	48 85 ff             	test   %rdi,%rdi
  8041609e37:	74 1d                	je     8041609e56 <get_rsdp+0x44>
  krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  8041609e39:	be 24 00 00 00       	mov    $0x24,%esi
  8041609e3e:	48 b8 54 83 60 41 80 	movabs $0x8041608354,%rax
  8041609e45:	00 00 00 
  8041609e48:	ff d0                	callq  *%rax
  8041609e4a:	48 a3 d0 54 70 41 80 	movabs %rax,0x80417054d0
  8041609e51:	00 00 00 
}
  8041609e54:	5d                   	pop    %rbp
  8041609e55:	c3                   	retq   
    panic("No rsdp\n");
  8041609e56:	48 ba 65 d9 60 41 80 	movabs $0x804160d965,%rdx
  8041609e5d:	00 00 00 
  8041609e60:	be 64 00 00 00       	mov    $0x64,%esi
  8041609e65:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  8041609e6c:	00 00 00 
  8041609e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609e74:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609e7b:	00 00 00 
  8041609e7e:	ff d1                	callq  *%rcx

0000008041609e80 <get_fadt>:
  if (!kfadt) {
  8041609e80:	48 b8 c8 54 70 41 80 	movabs $0x80417054c8,%rax
  8041609e87:	00 00 00 
  8041609e8a:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609e8e:	74 0b                	je     8041609e9b <get_fadt+0x1b>
}
  8041609e90:	48 a1 c8 54 70 41 80 	movabs 0x80417054c8,%rax
  8041609e97:	00 00 00 
  8041609e9a:	c3                   	retq   
get_fadt(void) {
  8041609e9b:	55                   	push   %rbp
  8041609e9c:	48 89 e5             	mov    %rsp,%rbp
    kfadt = acpi_find_table("FACP");
  8041609e9f:	48 bf b7 d9 60 41 80 	movabs $0x804160d9b7,%rdi
  8041609ea6:	00 00 00 
  8041609ea9:	48 b8 fa 97 60 41 80 	movabs $0x80416097fa,%rax
  8041609eb0:	00 00 00 
  8041609eb3:	ff d0                	callq  *%rax
  8041609eb5:	48 a3 c8 54 70 41 80 	movabs %rax,0x80417054c8
  8041609ebc:	00 00 00 
}
  8041609ebf:	48 a1 c8 54 70 41 80 	movabs 0x80417054c8,%rax
  8041609ec6:	00 00 00 
  8041609ec9:	5d                   	pop    %rbp
  8041609eca:	c3                   	retq   

0000008041609ecb <acpi_enable>:
acpi_enable(void) {
  8041609ecb:	55                   	push   %rbp
  8041609ecc:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  8041609ecf:	48 b8 80 9e 60 41 80 	movabs $0x8041609e80,%rax
  8041609ed6:	00 00 00 
  8041609ed9:	ff d0                	callq  *%rax
  8041609edb:	48 89 c1             	mov    %rax,%rcx
  __asm __volatile("outb %0,%w1"
  8041609ede:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  8041609ee2:	8b 51 30             	mov    0x30(%rcx),%edx
  8041609ee5:	ee                   	out    %al,(%dx)
  while ((inw(fadt->PM1aControlBlock) & 1) == 0) {
  8041609ee6:	8b 51 40             	mov    0x40(%rcx),%edx
  __asm __volatile("inw %w1,%0"
  8041609ee9:	66 ed                	in     (%dx),%ax
  8041609eeb:	a8 01                	test   $0x1,%al
  8041609eed:	74 fa                	je     8041609ee9 <acpi_enable+0x1e>
}
  8041609eef:	5d                   	pop    %rbp
  8041609ef0:	c3                   	retq   

0000008041609ef1 <get_hpet>:
  if (!khpet) {
  8041609ef1:	48 b8 a8 54 70 41 80 	movabs $0x80417054a8,%rax
  8041609ef8:	00 00 00 
  8041609efb:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609eff:	74 0b                	je     8041609f0c <get_hpet+0x1b>
}
  8041609f01:	48 a1 a8 54 70 41 80 	movabs 0x80417054a8,%rax
  8041609f08:	00 00 00 
  8041609f0b:	c3                   	retq   
get_hpet(void) {
  8041609f0c:	55                   	push   %rbp
  8041609f0d:	48 89 e5             	mov    %rsp,%rbp
    khpet = acpi_find_table("HPET");
  8041609f10:	48 bf bc d9 60 41 80 	movabs $0x804160d9bc,%rdi
  8041609f17:	00 00 00 
  8041609f1a:	48 b8 fa 97 60 41 80 	movabs $0x80416097fa,%rax
  8041609f21:	00 00 00 
  8041609f24:	ff d0                	callq  *%rax
  8041609f26:	48 a3 a8 54 70 41 80 	movabs %rax,0x80417054a8
  8041609f2d:	00 00 00 
}
  8041609f30:	48 a1 a8 54 70 41 80 	movabs 0x80417054a8,%rax
  8041609f37:	00 00 00 
  8041609f3a:	5d                   	pop    %rbp
  8041609f3b:	c3                   	retq   

0000008041609f3c <hpet_register>:
hpet_register(void) {
  8041609f3c:	55                   	push   %rbp
  8041609f3d:	48 89 e5             	mov    %rsp,%rbp
  HPET *hpet_timer = get_hpet();
  8041609f40:	48 b8 f1 9e 60 41 80 	movabs $0x8041609ef1,%rax
  8041609f47:	00 00 00 
  8041609f4a:	ff d0                	callq  *%rax
  if (hpet_timer->address.address == 0)
  8041609f4c:	48 8b 78 2c          	mov    0x2c(%rax),%rdi
  8041609f50:	48 85 ff             	test   %rdi,%rdi
  8041609f53:	74 13                	je     8041609f68 <hpet_register+0x2c>
  return mmio_map_region(paddr, sizeof(HPETRegister));
  8041609f55:	be 00 04 00 00       	mov    $0x400,%esi
  8041609f5a:	48 b8 54 83 60 41 80 	movabs $0x8041608354,%rax
  8041609f61:	00 00 00 
  8041609f64:	ff d0                	callq  *%rax
}
  8041609f66:	5d                   	pop    %rbp
  8041609f67:	c3                   	retq   
    panic("hpet is unavailable\n");
  8041609f68:	48 ba c1 d9 60 41 80 	movabs $0x804160d9c1,%rdx
  8041609f6f:	00 00 00 
  8041609f72:	be db 00 00 00       	mov    $0xdb,%esi
  8041609f77:	48 bf 6e d9 60 41 80 	movabs $0x804160d96e,%rdi
  8041609f7e:	00 00 00 
  8041609f81:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609f86:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609f8d:	00 00 00 
  8041609f90:	ff d1                	callq  *%rcx

0000008041609f92 <hpet_init>:
  if (hpetReg == NULL) {
  8041609f92:	48 b8 e8 54 70 41 80 	movabs $0x80417054e8,%rax
  8041609f99:	00 00 00 
  8041609f9c:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609fa0:	74 01                	je     8041609fa3 <hpet_init+0x11>
  8041609fa2:	c3                   	retq   
hpet_init() {
  8041609fa3:	55                   	push   %rbp
  8041609fa4:	48 89 e5             	mov    %rsp,%rbp
  8041609fa7:	53                   	push   %rbx
  8041609fa8:	48 83 ec 08          	sub    $0x8,%rsp
  __asm __volatile("inb %w1,%0"
  8041609fac:	bb 70 00 00 00       	mov    $0x70,%ebx
  8041609fb1:	89 da                	mov    %ebx,%edx
  8041609fb3:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) | NMI_LOCK);
  8041609fb4:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  8041609fb7:	ee                   	out    %al,(%dx)
    hpetReg   = hpet_register();
  8041609fb8:	48 b8 3c 9f 60 41 80 	movabs $0x8041609f3c,%rax
  8041609fbf:	00 00 00 
  8041609fc2:	ff d0                	callq  *%rax
  8041609fc4:	48 89 c6             	mov    %rax,%rsi
  8041609fc7:	48 a3 e8 54 70 41 80 	movabs %rax,0x80417054e8
  8041609fce:	00 00 00 
    hpetFemto = (uintptr_t)(hpetReg->GCAP_ID >> 32);
  8041609fd1:	48 8b 08             	mov    (%rax),%rcx
  8041609fd4:	48 c1 e9 20          	shr    $0x20,%rcx
  8041609fd8:	48 89 c8             	mov    %rcx,%rax
  8041609fdb:	48 a3 e0 54 70 41 80 	movabs %rax,0x80417054e0
  8041609fe2:	00 00 00 
    hpetFreq = (1 * Peta) / hpetFemto;
  8041609fe5:	48 b8 00 80 c6 a4 7e 	movabs $0x38d7ea4c68000,%rax
  8041609fec:	8d 03 00 
  8041609fef:	ba 00 00 00 00       	mov    $0x0,%edx
  8041609ff4:	48 f7 f1             	div    %rcx
  8041609ff7:	48 a3 d8 54 70 41 80 	movabs %rax,0x80417054d8
  8041609ffe:	00 00 00 
    hpetReg->GEN_CONF |= 1;
  804160a001:	48 8b 46 10          	mov    0x10(%rsi),%rax
  804160a005:	48 83 c8 01          	or     $0x1,%rax
  804160a009:	48 89 46 10          	mov    %rax,0x10(%rsi)
  __asm __volatile("inb %w1,%0"
  804160a00d:	89 da                	mov    %ebx,%edx
  804160a00f:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  804160a010:	83 e0 7f             	and    $0x7f,%eax
  804160a013:	ee                   	out    %al,(%dx)
}
  804160a014:	48 83 c4 08          	add    $0x8,%rsp
  804160a018:	5b                   	pop    %rbx
  804160a019:	5d                   	pop    %rbp
  804160a01a:	c3                   	retq   

000000804160a01b <hpet_print_struct>:
hpet_print_struct(void) {
  804160a01b:	55                   	push   %rbp
  804160a01c:	48 89 e5             	mov    %rsp,%rbp
  804160a01f:	41 54                	push   %r12
  804160a021:	53                   	push   %rbx
  HPET *hpet = get_hpet();
  804160a022:	48 b8 f1 9e 60 41 80 	movabs $0x8041609ef1,%rax
  804160a029:	00 00 00 
  804160a02c:	ff d0                	callq  *%rax
  804160a02e:	49 89 c4             	mov    %rax,%r12
  cprintf("signature = %s\n", (hpet->h).Signature);
  804160a031:	48 89 c6             	mov    %rax,%rsi
  804160a034:	48 bf d6 d9 60 41 80 	movabs $0x804160d9d6,%rdi
  804160a03b:	00 00 00 
  804160a03e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a043:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  804160a04a:	00 00 00 
  804160a04d:	ff d3                	callq  *%rbx
  cprintf("length = %08x\n", (hpet->h).Length);
  804160a04f:	41 8b 74 24 04       	mov    0x4(%r12),%esi
  804160a054:	48 bf e6 d9 60 41 80 	movabs $0x804160d9e6,%rdi
  804160a05b:	00 00 00 
  804160a05e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a063:	ff d3                	callq  *%rbx
  cprintf("revision = %08x\n", (hpet->h).Revision);
  804160a065:	41 0f b6 74 24 08    	movzbl 0x8(%r12),%esi
  804160a06b:	48 bf 0a da 60 41 80 	movabs $0x804160da0a,%rdi
  804160a072:	00 00 00 
  804160a075:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a07a:	ff d3                	callq  *%rbx
  cprintf("checksum = %08x\n", (hpet->h).Checksum);
  804160a07c:	41 0f b6 74 24 09    	movzbl 0x9(%r12),%esi
  804160a082:	48 bf f5 d9 60 41 80 	movabs $0x804160d9f5,%rdi
  804160a089:	00 00 00 
  804160a08c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a091:	ff d3                	callq  *%rbx
  cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  804160a093:	41 8b 74 24 18       	mov    0x18(%r12),%esi
  804160a098:	48 bf 06 da 60 41 80 	movabs $0x804160da06,%rdi
  804160a09f:	00 00 00 
  804160a0a2:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a0a7:	ff d3                	callq  *%rbx
  cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  804160a0a9:	41 8b 74 24 1c       	mov    0x1c(%r12),%esi
  804160a0ae:	48 bf 1b da 60 41 80 	movabs $0x804160da1b,%rdi
  804160a0b5:	00 00 00 
  804160a0b8:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a0bd:	ff d3                	callq  *%rbx
  cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);
  804160a0bf:	41 8b 74 24 20       	mov    0x20(%r12),%esi
  804160a0c4:	48 bf 2e da 60 41 80 	movabs $0x804160da2e,%rdi
  804160a0cb:	00 00 00 
  804160a0ce:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a0d3:	ff d3                	callq  *%rbx
  cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  804160a0d5:	41 0f b6 74 24 24    	movzbl 0x24(%r12),%esi
  804160a0db:	48 bf 47 da 60 41 80 	movabs $0x804160da47,%rdi
  804160a0e2:	00 00 00 
  804160a0e5:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a0ea:	ff d3                	callq  *%rbx
  cprintf("comparator_count = %08x\n", hpet->comparator_count);
  804160a0ec:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a0f2:	83 e6 1f             	and    $0x1f,%esi
  804160a0f5:	48 bf 5f da 60 41 80 	movabs $0x804160da5f,%rdi
  804160a0fc:	00 00 00 
  804160a0ff:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a104:	ff d3                	callq  *%rbx
  cprintf("counter_size = %08x\n", hpet->counter_size);
  804160a106:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a10c:	40 c0 ee 05          	shr    $0x5,%sil
  804160a110:	83 e6 01             	and    $0x1,%esi
  804160a113:	48 bf 78 da 60 41 80 	movabs $0x804160da78,%rdi
  804160a11a:	00 00 00 
  804160a11d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a122:	ff d3                	callq  *%rbx
  cprintf("reserved = %08x\n", hpet->reserved);
  804160a124:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a12a:	40 c0 ee 06          	shr    $0x6,%sil
  804160a12e:	83 e6 01             	and    $0x1,%esi
  804160a131:	48 bf 8d da 60 41 80 	movabs $0x804160da8d,%rdi
  804160a138:	00 00 00 
  804160a13b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a140:	ff d3                	callq  *%rbx
  cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  804160a142:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a148:	40 c0 ee 07          	shr    $0x7,%sil
  804160a14c:	40 0f b6 f6          	movzbl %sil,%esi
  804160a150:	48 bf 9e da 60 41 80 	movabs $0x804160da9e,%rdi
  804160a157:	00 00 00 
  804160a15a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a15f:	ff d3                	callq  *%rbx
  cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  804160a161:	41 0f b7 74 24 26    	movzwl 0x26(%r12),%esi
  804160a167:	48 bf b9 da 60 41 80 	movabs $0x804160dab9,%rdi
  804160a16e:	00 00 00 
  804160a171:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a176:	ff d3                	callq  *%rbx
  cprintf("hpet_number = %08x\n", hpet->hpet_number);
  804160a178:	41 0f b6 74 24 34    	movzbl 0x34(%r12),%esi
  804160a17e:	48 bf cf da 60 41 80 	movabs $0x804160dacf,%rdi
  804160a185:	00 00 00 
  804160a188:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a18d:	ff d3                	callq  *%rbx
  cprintf("minimum_tick = %08x\n", hpet->minimum_tick);
  804160a18f:	41 0f b7 74 24 35    	movzwl 0x35(%r12),%esi
  804160a195:	48 bf e3 da 60 41 80 	movabs $0x804160dae3,%rdi
  804160a19c:	00 00 00 
  804160a19f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a1a4:	ff d3                	callq  *%rbx
  cprintf("address_structure:\n");
  804160a1a6:	48 bf f8 da 60 41 80 	movabs $0x804160daf8,%rdi
  804160a1ad:	00 00 00 
  804160a1b0:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a1b5:	ff d3                	callq  *%rbx
  cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  804160a1b7:	41 0f b6 74 24 28    	movzbl 0x28(%r12),%esi
  804160a1bd:	48 bf 0c db 60 41 80 	movabs $0x804160db0c,%rdi
  804160a1c4:	00 00 00 
  804160a1c7:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a1cc:	ff d3                	callq  *%rbx
  cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  804160a1ce:	41 0f b6 74 24 29    	movzbl 0x29(%r12),%esi
  804160a1d4:	48 bf 25 db 60 41 80 	movabs $0x804160db25,%rdi
  804160a1db:	00 00 00 
  804160a1de:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a1e3:	ff d3                	callq  *%rbx
  cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  804160a1e5:	41 0f b6 74 24 2a    	movzbl 0x2a(%r12),%esi
  804160a1eb:	48 bf 40 db 60 41 80 	movabs $0x804160db40,%rdi
  804160a1f2:	00 00 00 
  804160a1f5:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a1fa:	ff d3                	callq  *%rbx
  cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
  804160a1fc:	49 8b 74 24 2c       	mov    0x2c(%r12),%rsi
  804160a201:	48 bf 5c db 60 41 80 	movabs $0x804160db5c,%rdi
  804160a208:	00 00 00 
  804160a20b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a210:	ff d3                	callq  *%rbx
}
  804160a212:	5b                   	pop    %rbx
  804160a213:	41 5c                	pop    %r12
  804160a215:	5d                   	pop    %rbp
  804160a216:	c3                   	retq   

000000804160a217 <hpet_print_reg>:
hpet_print_reg(void) {
  804160a217:	55                   	push   %rbp
  804160a218:	48 89 e5             	mov    %rsp,%rbp
  804160a21b:	41 54                	push   %r12
  804160a21d:	53                   	push   %rbx
  cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  804160a21e:	49 bc e8 54 70 41 80 	movabs $0x80417054e8,%r12
  804160a225:	00 00 00 
  804160a228:	49 8b 04 24          	mov    (%r12),%rax
  804160a22c:	48 8b 30             	mov    (%rax),%rsi
  804160a22f:	48 bf 6d db 60 41 80 	movabs $0x804160db6d,%rdi
  804160a236:	00 00 00 
  804160a239:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a23e:	48 bb 6e 8f 60 41 80 	movabs $0x8041608f6e,%rbx
  804160a245:	00 00 00 
  804160a248:	ff d3                	callq  *%rbx
  cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  804160a24a:	49 8b 04 24          	mov    (%r12),%rax
  804160a24e:	48 8b 70 10          	mov    0x10(%rax),%rsi
  804160a252:	48 bf 7f db 60 41 80 	movabs $0x804160db7f,%rdi
  804160a259:	00 00 00 
  804160a25c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a261:	ff d3                	callq  *%rbx
  cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  804160a263:	49 8b 04 24          	mov    (%r12),%rax
  804160a267:	48 8b 70 20          	mov    0x20(%rax),%rsi
  804160a26b:	48 bf 92 db 60 41 80 	movabs $0x804160db92,%rdi
  804160a272:	00 00 00 
  804160a275:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a27a:	ff d3                	callq  *%rbx
  cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  804160a27c:	49 8b 04 24          	mov    (%r12),%rax
  804160a280:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
  804160a287:	48 bf a6 db 60 41 80 	movabs $0x804160dba6,%rdi
  804160a28e:	00 00 00 
  804160a291:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a296:	ff d3                	callq  *%rbx
  cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  804160a298:	49 8b 04 24          	mov    (%r12),%rax
  804160a29c:	48 8b b0 00 01 00 00 	mov    0x100(%rax),%rsi
  804160a2a3:	48 bf b9 db 60 41 80 	movabs $0x804160dbb9,%rdi
  804160a2aa:	00 00 00 
  804160a2ad:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a2b2:	ff d3                	callq  *%rbx
  cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  804160a2b4:	49 8b 04 24          	mov    (%r12),%rax
  804160a2b8:	48 8b b0 08 01 00 00 	mov    0x108(%rax),%rsi
  804160a2bf:	48 bf cd db 60 41 80 	movabs $0x804160dbcd,%rdi
  804160a2c6:	00 00 00 
  804160a2c9:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a2ce:	ff d3                	callq  *%rbx
  cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  804160a2d0:	49 8b 04 24          	mov    (%r12),%rax
  804160a2d4:	48 8b b0 10 01 00 00 	mov    0x110(%rax),%rsi
  804160a2db:	48 bf e1 db 60 41 80 	movabs $0x804160dbe1,%rdi
  804160a2e2:	00 00 00 
  804160a2e5:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a2ea:	ff d3                	callq  *%rbx
  cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  804160a2ec:	49 8b 04 24          	mov    (%r12),%rax
  804160a2f0:	48 8b b0 20 01 00 00 	mov    0x120(%rax),%rsi
  804160a2f7:	48 bf f4 db 60 41 80 	movabs $0x804160dbf4,%rdi
  804160a2fe:	00 00 00 
  804160a301:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a306:	ff d3                	callq  *%rbx
  cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  804160a308:	49 8b 04 24          	mov    (%r12),%rax
  804160a30c:	48 8b b0 28 01 00 00 	mov    0x128(%rax),%rsi
  804160a313:	48 bf 08 dc 60 41 80 	movabs $0x804160dc08,%rdi
  804160a31a:	00 00 00 
  804160a31d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a322:	ff d3                	callq  *%rbx
  cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  804160a324:	49 8b 04 24          	mov    (%r12),%rax
  804160a328:	48 8b b0 30 01 00 00 	mov    0x130(%rax),%rsi
  804160a32f:	48 bf 1c dc 60 41 80 	movabs $0x804160dc1c,%rdi
  804160a336:	00 00 00 
  804160a339:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a33e:	ff d3                	callq  *%rbx
  cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  804160a340:	49 8b 04 24          	mov    (%r12),%rax
  804160a344:	48 8b b0 40 01 00 00 	mov    0x140(%rax),%rsi
  804160a34b:	48 bf 2f dc 60 41 80 	movabs $0x804160dc2f,%rdi
  804160a352:	00 00 00 
  804160a355:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a35a:	ff d3                	callq  *%rbx
  cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  804160a35c:	49 8b 04 24          	mov    (%r12),%rax
  804160a360:	48 8b b0 48 01 00 00 	mov    0x148(%rax),%rsi
  804160a367:	48 bf 43 dc 60 41 80 	movabs $0x804160dc43,%rdi
  804160a36e:	00 00 00 
  804160a371:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a376:	ff d3                	callq  *%rbx
  cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
  804160a378:	49 8b 04 24          	mov    (%r12),%rax
  804160a37c:	48 8b b0 50 01 00 00 	mov    0x150(%rax),%rsi
  804160a383:	48 bf 57 dc 60 41 80 	movabs $0x804160dc57,%rdi
  804160a38a:	00 00 00 
  804160a38d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a392:	ff d3                	callq  *%rbx
}
  804160a394:	5b                   	pop    %rbx
  804160a395:	41 5c                	pop    %r12
  804160a397:	5d                   	pop    %rbp
  804160a398:	c3                   	retq   

000000804160a399 <hpet_get_main_cnt>:
  return hpetReg->MAIN_CNT;
  804160a399:	48 a1 e8 54 70 41 80 	movabs 0x80417054e8,%rax
  804160a3a0:	00 00 00 
  804160a3a3:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
}
  804160a3aa:	c3                   	retq   

000000804160a3ab <pmtimer_get_timeval>:

uint32_t
pmtimer_get_timeval(void) {
  804160a3ab:	55                   	push   %rbp
  804160a3ac:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  804160a3af:	48 b8 80 9e 60 41 80 	movabs $0x8041609e80,%rax
  804160a3b6:	00 00 00 
  804160a3b9:	ff d0                	callq  *%rax
  __asm __volatile("inl %w1,%0"
  804160a3bb:	8b 50 4c             	mov    0x4c(%rax),%edx
  804160a3be:	ed                   	in     (%dx),%eax
  return inl(fadt->PMTimerBlock);
}
  804160a3bf:	5d                   	pop    %rbp
  804160a3c0:	c3                   	retq   

000000804160a3c1 <pmtimer_cpu_frequency>:
// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
// Hint: use pmtimer_get_timeval function and do not forget that ACPI PM timer
// can be 24-bit or 32-bit.
uint64_t
pmtimer_cpu_frequency(void) {
  804160a3c1:	55                   	push   %rbp
  804160a3c2:	48 89 e5             	mov    %rsp,%rbp
  804160a3c5:	41 55                	push   %r13
  804160a3c7:	41 54                	push   %r12
  804160a3c9:	53                   	push   %rbx
  804160a3ca:	48 83 ec 08          	sub    $0x8,%rsp

  uint32_t time_res = 100;
  uint32_t tick0    = pmtimer_get_timeval();
  804160a3ce:	48 b8 ab a3 60 41 80 	movabs $0x804160a3ab,%rax
  804160a3d5:	00 00 00 
  804160a3d8:	ff d0                	callq  *%rax
  804160a3da:	89 c3                	mov    %eax,%ebx
  __asm __volatile("rdtsc"
  804160a3dc:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a3de:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a3e2:	89 c0                	mov    %eax,%eax
  804160a3e4:	48 09 c2             	or     %rax,%rdx
  804160a3e7:	49 89 d5             	mov    %rdx,%r13

  uint64_t tsc0 = read_tsc();

  do {
    asm("pause");
    uint32_t tick1 = pmtimer_get_timeval();
  804160a3ea:	49 bc ab a3 60 41 80 	movabs $0x804160a3ab,%r12
  804160a3f1:	00 00 00 
  804160a3f4:	eb 17                	jmp    804160a40d <pmtimer_cpu_frequency+0x4c>
    delta          = tick1 - tick0;
    if (-delta <= 0xFFFFFF) {
      delta += 0xFFFFFF;
    } else if (tick0 > tick1) {
  804160a3f6:	39 c3                	cmp    %eax,%ebx
  804160a3f8:	76 0a                	jbe    804160a404 <pmtimer_cpu_frequency+0x43>
      delta += 0xFFFFFFFF;
  804160a3fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160a3ff:	48 01 c1             	add    %rax,%rcx
  804160a402:	eb 28                	jmp    804160a42c <pmtimer_cpu_frequency+0x6b>
    }
  } while (delta < target);
  804160a404:	48 81 f9 d2 8b 00 00 	cmp    $0x8bd2,%rcx
  804160a40b:	77 1f                	ja     804160a42c <pmtimer_cpu_frequency+0x6b>
    asm("pause");
  804160a40d:	f3 90                	pause  
    uint32_t tick1 = pmtimer_get_timeval();
  804160a40f:	41 ff d4             	callq  *%r12
    delta          = tick1 - tick0;
  804160a412:	89 c1                	mov    %eax,%ecx
  804160a414:	29 d9                	sub    %ebx,%ecx
    if (-delta <= 0xFFFFFF) {
  804160a416:	48 89 ca             	mov    %rcx,%rdx
  804160a419:	48 f7 da             	neg    %rdx
  804160a41c:	48 81 fa ff ff ff 00 	cmp    $0xffffff,%rdx
  804160a423:	77 d1                	ja     804160a3f6 <pmtimer_cpu_frequency+0x35>
      delta += 0xFFFFFF;
  804160a425:	48 81 c1 ff ff ff 00 	add    $0xffffff,%rcx
  __asm __volatile("rdtsc"
  804160a42c:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a42e:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a432:	89 c0                	mov    %eax,%eax
  804160a434:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * PM_FREQ / delta;
  804160a437:	4c 29 ea             	sub    %r13,%rdx
  804160a43a:	48 69 c2 99 9e 36 00 	imul   $0x369e99,%rdx,%rax
  804160a441:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a446:	48 f7 f1             	div    %rcx
}
  804160a449:	48 83 c4 08          	add    $0x8,%rsp
  804160a44d:	5b                   	pop    %rbx
  804160a44e:	41 5c                	pop    %r12
  804160a450:	41 5d                	pop    %r13
  804160a452:	5d                   	pop    %rbp
  804160a453:	c3                   	retq   

000000804160a454 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160a454:	48 a1 00 44 70 41 80 	movabs 0x8041704400,%rax
  804160a45b:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  804160a45e:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  804160a464:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160a467:	83 fa 02             	cmp    $0x2,%edx
  804160a46a:	76 5c                	jbe    804160a4c8 <sched_halt+0x74>
  804160a46c:	48 8d 90 cc 01 00 00 	lea    0x1cc(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  804160a473:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  804160a478:	8b 02                	mov    (%rdx),%eax
  804160a47a:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160a47d:	83 f8 02             	cmp    $0x2,%eax
  804160a480:	76 46                	jbe    804160a4c8 <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  804160a482:	83 c1 01             	add    $0x1,%ecx
  804160a485:	48 81 c2 f8 00 00 00 	add    $0xf8,%rdx
  804160a48c:	83 f9 20             	cmp    $0x20,%ecx
  804160a48f:	75 e7                	jne    804160a478 <sched_halt+0x24>
sched_halt(void) {
  804160a491:	55                   	push   %rbp
  804160a492:	48 89 e5             	mov    %rsp,%rbp
  804160a495:	53                   	push   %rbx
  804160a496:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  804160a49a:	48 bf 78 dc 60 41 80 	movabs $0x804160dc78,%rdi
  804160a4a1:	00 00 00 
  804160a4a4:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a4a9:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160a4b0:	00 00 00 
  804160a4b3:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  804160a4b5:	48 bb 47 3f 60 41 80 	movabs $0x8041603f47,%rbx
  804160a4bc:	00 00 00 
  804160a4bf:	bf 00 00 00 00       	mov    $0x0,%edi
  804160a4c4:	ff d3                	callq  *%rbx
    while (1)
  804160a4c6:	eb f7                	jmp    804160a4bf <sched_halt+0x6b>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  804160a4c8:	48 b8 f8 43 70 41 80 	movabs $0x80417043f8,%rax
  804160a4cf:	00 00 00 
  804160a4d2:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  804160a4d9:	48 a1 44 5a 70 41 80 	movabs 0x8041705a44,%rax
  804160a4e0:	00 00 00 
  804160a4e3:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  804160a4ea:	48 89 c4             	mov    %rax,%rsp
  804160a4ed:	6a 00                	pushq  $0x0
  804160a4ef:	6a 00                	pushq  $0x0
  804160a4f1:	fb                   	sti    
  804160a4f2:	f4                   	hlt    
  804160a4f3:	c3                   	retq   

000000804160a4f4 <sched_yield>:
sched_yield(void) {
  804160a4f4:	55                   	push   %rbp
  804160a4f5:	48 89 e5             	mov    %rsp,%rbp
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160a4f8:	48 a1 f8 43 70 41 80 	movabs 0x80417043f8,%rax
  804160a4ff:	00 00 00 
  804160a502:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  804160a508:	48 85 c0             	test   %rax,%rax
  804160a50b:	74 0b                	je     804160a518 <sched_yield+0x24>
  804160a50d:	44 8b 80 c8 00 00 00 	mov    0xc8(%rax),%r8d
  804160a514:	41 83 e0 1f          	and    $0x1f,%r8d
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160a518:	48 b8 00 44 70 41 80 	movabs $0x8041704400,%rax
  804160a51f:	00 00 00 
  804160a522:	4c 8b 08             	mov    (%rax),%r9
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160a525:	44 89 c2             	mov    %r8d,%edx
  804160a528:	eb 05                	jmp    804160a52f <sched_yield+0x3b>
  } while (id != orig);
  804160a52a:	41 39 c0             	cmp    %eax,%r8d
  804160a52d:	74 42                	je     804160a571 <sched_yield+0x7d>
    id = (id + 1) % NENV;
  804160a52f:	8d 42 01             	lea    0x1(%rdx),%eax
  804160a532:	99                   	cltd   
  804160a533:	c1 ea 1b             	shr    $0x1b,%edx
  804160a536:	01 d0                	add    %edx,%eax
  804160a538:	83 e0 1f             	and    $0x1f,%eax
  804160a53b:	29 d0                	sub    %edx,%eax
  804160a53d:	89 c2                	mov    %eax,%edx
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160a53f:	48 63 f0             	movslq %eax,%rsi
  804160a542:	48 89 f1             	mov    %rsi,%rcx
  804160a545:	48 c1 e1 05          	shl    $0x5,%rcx
  804160a549:	48 29 f1             	sub    %rsi,%rcx
  804160a54c:	49 8d 3c c9          	lea    (%r9,%rcx,8),%rdi
  804160a550:	8b 8f d4 00 00 00    	mov    0xd4(%rdi),%ecx
  804160a556:	83 f9 02             	cmp    $0x2,%ecx
  804160a559:	74 0a                	je     804160a565 <sched_yield+0x71>
        (id == orig && envs[id].env_status == ENV_RUNNING)) {
  804160a55b:	83 f9 03             	cmp    $0x3,%ecx
  804160a55e:	75 ca                	jne    804160a52a <sched_yield+0x36>
  804160a560:	41 39 c0             	cmp    %eax,%r8d
  804160a563:	75 c5                	jne    804160a52a <sched_yield+0x36>
      env_run(envs + id);
  804160a565:	48 b8 1d 8c 60 41 80 	movabs $0x8041608c1d,%rax
  804160a56c:	00 00 00 
  804160a56f:	ff d0                	callq  *%rax
  sched_halt();
  804160a571:	48 b8 54 a4 60 41 80 	movabs $0x804160a454,%rax
  804160a578:	00 00 00 
  804160a57b:	ff d0                	callq  *%rax
}
  804160a57d:	5d                   	pop    %rbp
  804160a57e:	c3                   	retq   

000000804160a57f <syscall>:
  // Call the function corresponding to the 'syscallno' parameter.
  // Return any appropriate return value.
  // LAB 8: Your code here.

  return -E_INVAL;
}
  804160a57f:	48 c7 c0 fd ff ff ff 	mov    $0xfffffffffffffffd,%rax
  804160a586:	c3                   	retq   

000000804160a587 <load_kernel_dwarf_info>:
#include <kern/kdebug.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  804160a587:	48 ba 00 f0 61 41 80 	movabs $0x804161f000,%rdx
  804160a58e:	00 00 00 
  804160a591:	48 8b 02             	mov    (%rdx),%rax
  804160a594:	48 8b 48 58          	mov    0x58(%rax),%rcx
  804160a598:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  804160a59c:	48 8b 48 60          	mov    0x60(%rax),%rcx
  804160a5a0:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  804160a5a4:	48 8b 40 68          	mov    0x68(%rax),%rax
  804160a5a8:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  804160a5ab:	48 8b 02             	mov    (%rdx),%rax
  804160a5ae:	48 8b 50 70          	mov    0x70(%rax),%rdx
  804160a5b2:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  804160a5b6:	48 8b 50 78          	mov    0x78(%rax),%rdx
  804160a5ba:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  804160a5be:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  804160a5c5:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  804160a5c9:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  804160a5d0:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  804160a5d4:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  804160a5db:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  804160a5df:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  804160a5e6:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  804160a5ea:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  804160a5f1:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  804160a5f5:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  804160a5fc:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  804160a600:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  804160a607:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  804160a60b:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  804160a612:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  804160a616:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  804160a61d:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  804160a621:	c3                   	retq   

000000804160a622 <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  804160a622:	55                   	push   %rbp
  804160a623:	48 89 e5             	mov    %rsp,%rbp
  804160a626:	41 56                	push   %r14
  804160a628:	41 55                	push   %r13
  804160a62a:	41 54                	push   %r12
  804160a62c:	53                   	push   %rbx
  804160a62d:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  804160a634:	49 89 fc             	mov    %rdi,%r12
  804160a637:	48 89 f3             	mov    %rsi,%rbx
  int code = 0;
  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  804160a63a:	48 be a1 dc 60 41 80 	movabs $0x804160dca1,%rsi
  804160a641:	00 00 00 
  804160a644:	48 89 df             	mov    %rbx,%rdi
  804160a647:	49 bd 48 b3 60 41 80 	movabs $0x804160b348,%r13
  804160a64e:	00 00 00 
  804160a651:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  804160a654:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  804160a65b:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  804160a65e:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  804160a665:	48 be a1 dc 60 41 80 	movabs $0x804160dca1,%rsi
  804160a66c:	00 00 00 
  804160a66f:	4c 89 f7             	mov    %r14,%rdi
  804160a672:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  804160a675:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  804160a67c:	00 00 00 
  info->rip_fn_addr    = addr;
  804160a67f:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  804160a686:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  804160a68d:	00 00 00 

  if (!addr) {
  804160a690:	4d 85 e4             	test   %r12,%r12
  804160a693:	0f 84 99 01 00 00    	je     804160a832 <debuginfo_rip+0x210>
  // Temporarily load kernel cr3 and return back once done.
  // Make sure that you fully understand why it is necessary.
  // LAB 8: Your code here.

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  804160a699:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  804160a6a0:	00 00 00 
  804160a6a3:	49 39 c4             	cmp    %rax,%r12
  804160a6a6:	0f 86 5c 01 00 00    	jbe    804160a808 <debuginfo_rip+0x1e6>
    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  804160a6ac:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a6b3:	48 b8 87 a5 60 41 80 	movabs $0x804160a587,%rax
  804160a6ba:	00 00 00 
  804160a6bd:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  804160a6bf:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  804160a6c6:	00 00 00 00 
  804160a6ca:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  804160a6d1:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  804160a6d5:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  804160a6dc:	4c 89 e6             	mov    %r12,%rsi
  804160a6df:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a6e6:	48 b8 d8 16 60 41 80 	movabs $0x80416016d8,%rax
  804160a6ed:	00 00 00 
  804160a6f0:	ff d0                	callq  *%rax
  804160a6f2:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  804160a6f5:	85 c0                	test   %eax,%eax
  804160a6f7:	0f 88 3b 01 00 00    	js     804160a838 <debuginfo_rip+0x216>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  804160a6fd:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  804160a704:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160a709:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160a710:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  804160a717:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a71e:	48 b8 87 1d 60 41 80 	movabs $0x8041601d87,%rax
  804160a725:	00 00 00 
  804160a728:	ff d0                	callq  *%rax
  804160a72a:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  804160a72d:	ba 00 01 00 00       	mov    $0x100,%edx
  804160a732:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160a739:	48 89 df             	mov    %rbx,%rdi
  804160a73c:	48 b8 96 b3 60 41 80 	movabs $0x804160b396,%rax
  804160a743:	00 00 00 
  804160a746:	ff d0                	callq  *%rax
  if (code < 0) {
  804160a748:	45 85 ed             	test   %r13d,%r13d
  804160a74b:	0f 88 e7 00 00 00    	js     804160a838 <debuginfo_rip+0x216>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c

  int lineno_store;
  addr           = addr - 5;
  804160a751:	49 83 ec 05          	sub    $0x5,%r12
  code           = line_for_address(&addrs, addr, line_offset, &lineno_store);
  804160a755:	48 8d 8d 54 ff ff ff 	lea    -0xac(%rbp),%rcx
  804160a75c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  804160a763:	4c 89 e6             	mov    %r12,%rsi
  804160a766:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a76d:	48 b8 d1 32 60 41 80 	movabs $0x80416032d1,%rax
  804160a774:	00 00 00 
  804160a777:	ff d0                	callq  *%rax
  804160a779:	41 89 c5             	mov    %eax,%r13d
  info->rip_line = lineno_store;
  804160a77c:	8b 85 54 ff ff ff    	mov    -0xac(%rbp),%eax
  804160a782:	89 83 00 01 00 00    	mov    %eax,0x100(%rbx)
  if (code < 0) {
  804160a788:	45 85 ed             	test   %r13d,%r13d
  804160a78b:	0f 88 a7 00 00 00    	js     804160a838 <debuginfo_rip+0x216>
    return code;
  }

  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  804160a791:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  804160a798:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160a79e:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  804160a7a5:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  804160a7ac:	4c 89 e6             	mov    %r12,%rsi
  804160a7af:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160a7b6:	48 b8 f2 21 60 41 80 	movabs $0x80416021f2,%rax
  804160a7bd:	00 00 00 
  804160a7c0:	ff d0                	callq  *%rax
  804160a7c2:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  804160a7c5:	ba 00 01 00 00       	mov    $0x100,%edx
  804160a7ca:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160a7d1:	4c 89 f7             	mov    %r14,%rdi
  804160a7d4:	48 b8 96 b3 60 41 80 	movabs $0x804160b396,%rax
  804160a7db:	00 00 00 
  804160a7de:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  804160a7e0:	be 00 01 00 00       	mov    $0x100,%esi
  804160a7e5:	4c 89 f7             	mov    %r14,%rdi
  804160a7e8:	48 b8 13 b3 60 41 80 	movabs $0x804160b313,%rax
  804160a7ef:	00 00 00 
  804160a7f2:	ff d0                	callq  *%rax
  804160a7f4:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  804160a7fa:	45 85 ed             	test   %r13d,%r13d
  804160a7fd:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a802:	44 0f 4f e8          	cmovg  %eax,%r13d
  804160a806:	eb 30                	jmp    804160a838 <debuginfo_rip+0x216>
    panic("Can't search for user-level addresses yet!");
  804160a808:	48 ba c0 dc 60 41 80 	movabs $0x804160dcc0,%rdx
  804160a80f:	00 00 00 
  804160a812:	be 3c 00 00 00       	mov    $0x3c,%esi
  804160a817:	48 bf ab dc 60 41 80 	movabs $0x804160dcab,%rdi
  804160a81e:	00 00 00 
  804160a821:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a826:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a82d:	00 00 00 
  804160a830:	ff d1                	callq  *%rcx
    return 0;
  804160a832:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    return code;
  }
  return 0;
}
  804160a838:	44 89 e8             	mov    %r13d,%eax
  804160a83b:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  804160a842:	5b                   	pop    %rbx
  804160a843:	41 5c                	pop    %r12
  804160a845:	41 5d                	pop    %r13
  804160a847:	41 5e                	pop    %r14
  804160a849:	5d                   	pop    %rbp
  804160a84a:	c3                   	retq   

000000804160a84b <find_function>:

uintptr_t
find_function(const char *const fname) {
  804160a84b:	55                   	push   %rbp
  804160a84c:	48 89 e5             	mov    %rsp,%rbp
  804160a84f:	53                   	push   %rbx
  804160a850:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  804160a857:	48 89 fb             	mov    %rdi,%rbx
    }
  }
#endif

  struct Dwarf_Addrs addrs;
  load_kernel_dwarf_info(&addrs);
  804160a85a:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160a85e:	48 b8 87 a5 60 41 80 	movabs $0x804160a587,%rax
  804160a865:	00 00 00 
  804160a868:	ff d0                	callq  *%rax
  uintptr_t offset = 0;
  804160a86a:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  804160a871:	00 00 00 00 

  if (!address_by_fname(&addrs, fname, &offset) && offset) {
  804160a875:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160a87c:	48 89 de             	mov    %rbx,%rsi
  804160a87f:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160a883:	48 b8 7e 27 60 41 80 	movabs $0x804160277e,%rax
  804160a88a:	00 00 00 
  804160a88d:	ff d0                	callq  *%rax
  804160a88f:	85 c0                	test   %eax,%eax
  804160a891:	75 0c                	jne    804160a89f <find_function+0x54>
  804160a893:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160a89a:	48 85 d2             	test   %rdx,%rdx
  804160a89d:	75 23                	jne    804160a8c2 <find_function+0x77>
    return offset;
  }

  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160a89f:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160a8a6:	48 89 de             	mov    %rbx,%rsi
  804160a8a9:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160a8ad:	48 b8 7c 2d 60 41 80 	movabs $0x8041602d7c,%rax
  804160a8b4:	00 00 00 
  804160a8b7:	ff d0                	callq  *%rax
    return offset;
  }

  return 0;
  804160a8b9:	ba 00 00 00 00       	mov    $0x0,%edx
  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160a8be:	85 c0                	test   %eax,%eax
  804160a8c0:	74 0d                	je     804160a8cf <find_function+0x84>
}
  804160a8c2:	48 89 d0             	mov    %rdx,%rax
  804160a8c5:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  804160a8cc:	5b                   	pop    %rbx
  804160a8cd:	5d                   	pop    %rbp
  804160a8ce:	c3                   	retq   
    return offset;
  804160a8cf:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160a8d6:	eb ea                	jmp    804160a8c2 <find_function+0x77>

000000804160a8d8 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  804160a8d8:	55                   	push   %rbp
  804160a8d9:	48 89 e5             	mov    %rsp,%rbp
  804160a8dc:	41 57                	push   %r15
  804160a8de:	41 56                	push   %r14
  804160a8e0:	41 55                	push   %r13
  804160a8e2:	41 54                	push   %r12
  804160a8e4:	53                   	push   %rbx
  804160a8e5:	48 83 ec 18          	sub    $0x18,%rsp
  804160a8e9:	49 89 fc             	mov    %rdi,%r12
  804160a8ec:	49 89 f5             	mov    %rsi,%r13
  804160a8ef:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160a8f3:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  804160a8f6:	41 89 cf             	mov    %ecx,%r15d
  804160a8f9:	49 39 d7             	cmp    %rdx,%r15
  804160a8fc:	76 45                	jbe    804160a943 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  804160a8fe:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160a902:	85 db                	test   %ebx,%ebx
  804160a904:	7e 0e                	jle    804160a914 <printnum+0x3c>
      putch(padc, putdat);
  804160a906:	4c 89 ee             	mov    %r13,%rsi
  804160a909:	44 89 f7             	mov    %r14d,%edi
  804160a90c:	41 ff d4             	callq  *%r12
    while (--width > 0)
  804160a90f:	83 eb 01             	sub    $0x1,%ebx
  804160a912:	75 f2                	jne    804160a906 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  804160a914:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160a918:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a91d:	49 f7 f7             	div    %r15
  804160a920:	48 b8 eb dc 60 41 80 	movabs $0x804160dceb,%rax
  804160a927:	00 00 00 
  804160a92a:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  804160a92e:	4c 89 ee             	mov    %r13,%rsi
  804160a931:	41 ff d4             	callq  *%r12
}
  804160a934:	48 83 c4 18          	add    $0x18,%rsp
  804160a938:	5b                   	pop    %rbx
  804160a939:	41 5c                	pop    %r12
  804160a93b:	41 5d                	pop    %r13
  804160a93d:	41 5e                	pop    %r14
  804160a93f:	41 5f                	pop    %r15
  804160a941:	5d                   	pop    %rbp
  804160a942:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  804160a943:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160a947:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a94c:	49 f7 f7             	div    %r15
  804160a94f:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  804160a953:	48 89 c2             	mov    %rax,%rdx
  804160a956:	48 b8 d8 a8 60 41 80 	movabs $0x804160a8d8,%rax
  804160a95d:	00 00 00 
  804160a960:	ff d0                	callq  *%rax
  804160a962:	eb b0                	jmp    804160a914 <printnum+0x3c>

000000804160a964 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  804160a964:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  804160a968:	48 8b 06             	mov    (%rsi),%rax
  804160a96b:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  804160a96f:	73 0a                	jae    804160a97b <sprintputch+0x17>
    *b->buf++ = ch;
  804160a971:	48 8d 50 01          	lea    0x1(%rax),%rdx
  804160a975:	48 89 16             	mov    %rdx,(%rsi)
  804160a978:	40 88 38             	mov    %dil,(%rax)
}
  804160a97b:	c3                   	retq   

000000804160a97c <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  804160a97c:	55                   	push   %rbp
  804160a97d:	48 89 e5             	mov    %rsp,%rbp
  804160a980:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160a987:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160a98e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160a995:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160a99c:	84 c0                	test   %al,%al
  804160a99e:	74 20                	je     804160a9c0 <printfmt+0x44>
  804160a9a0:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160a9a4:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160a9a8:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160a9ac:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160a9b0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160a9b4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160a9b8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160a9bc:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  804160a9c0:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160a9c7:	00 00 00 
  804160a9ca:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160a9d1:	00 00 00 
  804160a9d4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160a9d8:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160a9df:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160a9e6:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  804160a9ed:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160a9f4:	48 b8 02 aa 60 41 80 	movabs $0x804160aa02,%rax
  804160a9fb:	00 00 00 
  804160a9fe:	ff d0                	callq  *%rax
}
  804160aa00:	c9                   	leaveq 
  804160aa01:	c3                   	retq   

000000804160aa02 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  804160aa02:	55                   	push   %rbp
  804160aa03:	48 89 e5             	mov    %rsp,%rbp
  804160aa06:	41 57                	push   %r15
  804160aa08:	41 56                	push   %r14
  804160aa0a:	41 55                	push   %r13
  804160aa0c:	41 54                	push   %r12
  804160aa0e:	53                   	push   %rbx
  804160aa0f:	48 83 ec 48          	sub    $0x48,%rsp
  804160aa13:	49 89 fd             	mov    %rdi,%r13
  804160aa16:	49 89 f7             	mov    %rsi,%r15
  804160aa19:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  804160aa1c:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  804160aa20:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  804160aa24:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160aa28:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160aa2c:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  804160aa30:	41 0f b6 3e          	movzbl (%r14),%edi
  804160aa34:	83 ff 25             	cmp    $0x25,%edi
  804160aa37:	74 18                	je     804160aa51 <vprintfmt+0x4f>
      if (ch == '\0')
  804160aa39:	85 ff                	test   %edi,%edi
  804160aa3b:	0f 84 8c 06 00 00    	je     804160b0cd <vprintfmt+0x6cb>
      putch(ch, putdat);
  804160aa41:	4c 89 fe             	mov    %r15,%rsi
  804160aa44:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160aa47:	49 89 de             	mov    %rbx,%r14
  804160aa4a:	eb e0                	jmp    804160aa2c <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160aa4c:	49 89 de             	mov    %rbx,%r14
  804160aa4f:	eb db                	jmp    804160aa2c <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  804160aa51:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  804160aa55:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  804160aa59:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  804160aa60:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  804160aa66:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  804160aa6a:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  804160aa6f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160aa75:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  804160aa7b:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  804160aa80:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  804160aa85:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  804160aa89:	0f b6 13             	movzbl (%rbx),%edx
  804160aa8c:	8d 42 dd             	lea    -0x23(%rdx),%eax
  804160aa8f:	3c 55                	cmp    $0x55,%al
  804160aa91:	0f 87 8b 05 00 00    	ja     804160b022 <vprintfmt+0x620>
  804160aa97:	0f b6 c0             	movzbl %al,%eax
  804160aa9a:	49 bb a0 dd 60 41 80 	movabs $0x804160dda0,%r11
  804160aaa1:	00 00 00 
  804160aaa4:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  804160aaa8:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  804160aaab:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  804160aaaf:	eb d4                	jmp    804160aa85 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160aab1:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  804160aab4:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  804160aab8:	eb cb                	jmp    804160aa85 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160aaba:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  804160aabd:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  804160aac1:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  804160aac5:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160aac8:	83 fa 09             	cmp    $0x9,%edx
  804160aacb:	77 7e                	ja     804160ab4b <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  804160aacd:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  804160aad1:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  804160aad5:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  804160aada:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  804160aade:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160aae1:	83 fa 09             	cmp    $0x9,%edx
  804160aae4:	76 e7                	jbe    804160aacd <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  804160aae6:	4c 89 f3             	mov    %r14,%rbx
  804160aae9:	eb 19                	jmp    804160ab04 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  804160aaeb:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160aaee:	83 f8 2f             	cmp    $0x2f,%eax
  804160aaf1:	77 2a                	ja     804160ab1d <vprintfmt+0x11b>
  804160aaf3:	89 c2                	mov    %eax,%edx
  804160aaf5:	4c 01 d2             	add    %r10,%rdx
  804160aaf8:	83 c0 08             	add    $0x8,%eax
  804160aafb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160aafe:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  804160ab01:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  804160ab04:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160ab08:	0f 89 77 ff ff ff    	jns    804160aa85 <vprintfmt+0x83>
          width = precision, precision = -1;
  804160ab0e:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160ab12:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  804160ab18:	e9 68 ff ff ff       	jmpq   804160aa85 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  804160ab1d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160ab21:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160ab25:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160ab29:	eb d3                	jmp    804160aafe <vprintfmt+0xfc>
        if (width < 0)
  804160ab2b:	8b 45 ac             	mov    -0x54(%rbp),%eax
  804160ab2e:	85 c0                	test   %eax,%eax
  804160ab30:	41 0f 48 c0          	cmovs  %r8d,%eax
  804160ab34:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  804160ab37:	4c 89 f3             	mov    %r14,%rbx
  804160ab3a:	e9 46 ff ff ff       	jmpq   804160aa85 <vprintfmt+0x83>
  804160ab3f:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  804160ab42:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  804160ab46:	e9 3a ff ff ff       	jmpq   804160aa85 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160ab4b:	4c 89 f3             	mov    %r14,%rbx
  804160ab4e:	eb b4                	jmp    804160ab04 <vprintfmt+0x102>
        lflag++;
  804160ab50:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  804160ab53:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  804160ab56:	e9 2a ff ff ff       	jmpq   804160aa85 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  804160ab5b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ab5e:	83 f8 2f             	cmp    $0x2f,%eax
  804160ab61:	77 19                	ja     804160ab7c <vprintfmt+0x17a>
  804160ab63:	89 c2                	mov    %eax,%edx
  804160ab65:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ab69:	83 c0 08             	add    $0x8,%eax
  804160ab6c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ab6f:	4c 89 fe             	mov    %r15,%rsi
  804160ab72:	8b 3a                	mov    (%rdx),%edi
  804160ab74:	41 ff d5             	callq  *%r13
        break;
  804160ab77:	e9 b0 fe ff ff       	jmpq   804160aa2c <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  804160ab7c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160ab80:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160ab84:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160ab88:	eb e5                	jmp    804160ab6f <vprintfmt+0x16d>
        err = va_arg(aq, int);
  804160ab8a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ab8d:	83 f8 2f             	cmp    $0x2f,%eax
  804160ab90:	77 5b                	ja     804160abed <vprintfmt+0x1eb>
  804160ab92:	89 c2                	mov    %eax,%edx
  804160ab94:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ab98:	83 c0 08             	add    $0x8,%eax
  804160ab9b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ab9e:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  804160aba0:	89 c8                	mov    %ecx,%eax
  804160aba2:	c1 f8 1f             	sar    $0x1f,%eax
  804160aba5:	31 c1                	xor    %eax,%ecx
  804160aba7:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  804160aba9:	83 f9 09             	cmp    $0x9,%ecx
  804160abac:	7f 4d                	jg     804160abfb <vprintfmt+0x1f9>
  804160abae:	48 63 c1             	movslq %ecx,%rax
  804160abb1:	48 ba 60 e0 60 41 80 	movabs $0x804160e060,%rdx
  804160abb8:	00 00 00 
  804160abbb:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  804160abbf:	48 85 c0             	test   %rax,%rax
  804160abc2:	74 37                	je     804160abfb <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  804160abc4:	48 89 c1             	mov    %rax,%rcx
  804160abc7:	48 ba eb bf 60 41 80 	movabs $0x804160bfeb,%rdx
  804160abce:	00 00 00 
  804160abd1:	4c 89 fe             	mov    %r15,%rsi
  804160abd4:	4c 89 ef             	mov    %r13,%rdi
  804160abd7:	b8 00 00 00 00       	mov    $0x0,%eax
  804160abdc:	48 bb 7c a9 60 41 80 	movabs $0x804160a97c,%rbx
  804160abe3:	00 00 00 
  804160abe6:	ff d3                	callq  *%rbx
  804160abe8:	e9 3f fe ff ff       	jmpq   804160aa2c <vprintfmt+0x2a>
        err = va_arg(aq, int);
  804160abed:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160abf1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160abf5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160abf9:	eb a3                	jmp    804160ab9e <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  804160abfb:	48 ba 03 dd 60 41 80 	movabs $0x804160dd03,%rdx
  804160ac02:	00 00 00 
  804160ac05:	4c 89 fe             	mov    %r15,%rsi
  804160ac08:	4c 89 ef             	mov    %r13,%rdi
  804160ac0b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ac10:	48 bb 7c a9 60 41 80 	movabs $0x804160a97c,%rbx
  804160ac17:	00 00 00 
  804160ac1a:	ff d3                	callq  *%rbx
  804160ac1c:	e9 0b fe ff ff       	jmpq   804160aa2c <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  804160ac21:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ac24:	83 f8 2f             	cmp    $0x2f,%eax
  804160ac27:	77 4b                	ja     804160ac74 <vprintfmt+0x272>
  804160ac29:	89 c2                	mov    %eax,%edx
  804160ac2b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ac2f:	83 c0 08             	add    $0x8,%eax
  804160ac32:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ac35:	48 8b 02             	mov    (%rdx),%rax
  804160ac38:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  804160ac3c:	48 85 c0             	test   %rax,%rax
  804160ac3f:	0f 84 05 04 00 00    	je     804160b04a <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  804160ac45:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160ac49:	7e 06                	jle    804160ac51 <vprintfmt+0x24f>
  804160ac4b:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160ac4f:	75 31                	jne    804160ac82 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160ac51:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160ac55:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160ac59:	0f b6 00             	movzbl (%rax),%eax
  804160ac5c:	0f be f8             	movsbl %al,%edi
  804160ac5f:	85 ff                	test   %edi,%edi
  804160ac61:	0f 84 c3 00 00 00    	je     804160ad2a <vprintfmt+0x328>
  804160ac67:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160ac6b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160ac6f:	e9 85 00 00 00       	jmpq   804160acf9 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  804160ac74:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160ac78:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160ac7c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160ac80:	eb b3                	jmp    804160ac35 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160ac82:	49 63 f4             	movslq %r12d,%rsi
  804160ac85:	48 89 c7             	mov    %rax,%rdi
  804160ac88:	48 b8 13 b3 60 41 80 	movabs $0x804160b313,%rax
  804160ac8f:	00 00 00 
  804160ac92:	ff d0                	callq  *%rax
  804160ac94:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160ac97:	8b 75 ac             	mov    -0x54(%rbp),%esi
  804160ac9a:	85 f6                	test   %esi,%esi
  804160ac9c:	7e 22                	jle    804160acc0 <vprintfmt+0x2be>
            putch(padc, putdat);
  804160ac9e:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  804160aca2:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  804160aca6:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  804160acaa:	4c 89 fe             	mov    %r15,%rsi
  804160acad:	89 df                	mov    %ebx,%edi
  804160acaf:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  804160acb2:	41 83 ec 01          	sub    $0x1,%r12d
  804160acb6:	75 f2                	jne    804160acaa <vprintfmt+0x2a8>
  804160acb8:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160acbc:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160acc0:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160acc4:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160acc8:	0f b6 00             	movzbl (%rax),%eax
  804160accb:	0f be f8             	movsbl %al,%edi
  804160acce:	85 ff                	test   %edi,%edi
  804160acd0:	0f 84 56 fd ff ff    	je     804160aa2c <vprintfmt+0x2a>
  804160acd6:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160acda:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160acde:	eb 19                	jmp    804160acf9 <vprintfmt+0x2f7>
            putch(ch, putdat);
  804160ace0:	4c 89 fe             	mov    %r15,%rsi
  804160ace3:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160ace6:	41 83 ee 01          	sub    $0x1,%r14d
  804160acea:	48 83 c3 01          	add    $0x1,%rbx
  804160acee:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  804160acf2:	0f be f8             	movsbl %al,%edi
  804160acf5:	85 ff                	test   %edi,%edi
  804160acf7:	74 29                	je     804160ad22 <vprintfmt+0x320>
  804160acf9:	45 85 e4             	test   %r12d,%r12d
  804160acfc:	78 06                	js     804160ad04 <vprintfmt+0x302>
  804160acfe:	41 83 ec 01          	sub    $0x1,%r12d
  804160ad02:	78 48                	js     804160ad4c <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  804160ad04:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  804160ad08:	74 d6                	je     804160ace0 <vprintfmt+0x2de>
  804160ad0a:	0f be c0             	movsbl %al,%eax
  804160ad0d:	83 e8 20             	sub    $0x20,%eax
  804160ad10:	83 f8 5e             	cmp    $0x5e,%eax
  804160ad13:	76 cb                	jbe    804160ace0 <vprintfmt+0x2de>
            putch('?', putdat);
  804160ad15:	4c 89 fe             	mov    %r15,%rsi
  804160ad18:	bf 3f 00 00 00       	mov    $0x3f,%edi
  804160ad1d:	41 ff d5             	callq  *%r13
  804160ad20:	eb c4                	jmp    804160ace6 <vprintfmt+0x2e4>
  804160ad22:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160ad26:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  804160ad2a:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  804160ad2d:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160ad31:	0f 8e f5 fc ff ff    	jle    804160aa2c <vprintfmt+0x2a>
          putch(' ', putdat);
  804160ad37:	4c 89 fe             	mov    %r15,%rsi
  804160ad3a:	bf 20 00 00 00       	mov    $0x20,%edi
  804160ad3f:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  804160ad42:	83 eb 01             	sub    $0x1,%ebx
  804160ad45:	75 f0                	jne    804160ad37 <vprintfmt+0x335>
  804160ad47:	e9 e0 fc ff ff       	jmpq   804160aa2c <vprintfmt+0x2a>
  804160ad4c:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160ad50:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  804160ad54:	eb d4                	jmp    804160ad2a <vprintfmt+0x328>
  if (lflag >= 2)
  804160ad56:	83 f9 01             	cmp    $0x1,%ecx
  804160ad59:	7f 1d                	jg     804160ad78 <vprintfmt+0x376>
  else if (lflag)
  804160ad5b:	85 c9                	test   %ecx,%ecx
  804160ad5d:	74 5e                	je     804160adbd <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  804160ad5f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ad62:	83 f8 2f             	cmp    $0x2f,%eax
  804160ad65:	77 48                	ja     804160adaf <vprintfmt+0x3ad>
  804160ad67:	89 c2                	mov    %eax,%edx
  804160ad69:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ad6d:	83 c0 08             	add    $0x8,%eax
  804160ad70:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ad73:	48 8b 1a             	mov    (%rdx),%rbx
  804160ad76:	eb 17                	jmp    804160ad8f <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  804160ad78:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ad7b:	83 f8 2f             	cmp    $0x2f,%eax
  804160ad7e:	77 21                	ja     804160ada1 <vprintfmt+0x39f>
  804160ad80:	89 c2                	mov    %eax,%edx
  804160ad82:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ad86:	83 c0 08             	add    $0x8,%eax
  804160ad89:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ad8c:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  804160ad8f:	48 85 db             	test   %rbx,%rbx
  804160ad92:	78 50                	js     804160ade4 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  804160ad94:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  804160ad97:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160ad9c:	e9 b4 01 00 00       	jmpq   804160af55 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  804160ada1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160ada5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160ada9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160adad:	eb dd                	jmp    804160ad8c <vprintfmt+0x38a>
    return va_arg(*ap, long);
  804160adaf:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160adb3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160adb7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160adbb:	eb b6                	jmp    804160ad73 <vprintfmt+0x371>
    return va_arg(*ap, int);
  804160adbd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160adc0:	83 f8 2f             	cmp    $0x2f,%eax
  804160adc3:	77 11                	ja     804160add6 <vprintfmt+0x3d4>
  804160adc5:	89 c2                	mov    %eax,%edx
  804160adc7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160adcb:	83 c0 08             	add    $0x8,%eax
  804160adce:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160add1:	48 63 1a             	movslq (%rdx),%rbx
  804160add4:	eb b9                	jmp    804160ad8f <vprintfmt+0x38d>
  804160add6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160adda:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160adde:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160ade2:	eb ed                	jmp    804160add1 <vprintfmt+0x3cf>
          putch('-', putdat);
  804160ade4:	4c 89 fe             	mov    %r15,%rsi
  804160ade7:	bf 2d 00 00 00       	mov    $0x2d,%edi
  804160adec:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  804160adef:	48 89 da             	mov    %rbx,%rdx
  804160adf2:	48 f7 da             	neg    %rdx
        base = 10;
  804160adf5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160adfa:	e9 56 01 00 00       	jmpq   804160af55 <vprintfmt+0x553>
  if (lflag >= 2)
  804160adff:	83 f9 01             	cmp    $0x1,%ecx
  804160ae02:	7f 25                	jg     804160ae29 <vprintfmt+0x427>
  else if (lflag)
  804160ae04:	85 c9                	test   %ecx,%ecx
  804160ae06:	74 5e                	je     804160ae66 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  804160ae08:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ae0b:	83 f8 2f             	cmp    $0x2f,%eax
  804160ae0e:	77 48                	ja     804160ae58 <vprintfmt+0x456>
  804160ae10:	89 c2                	mov    %eax,%edx
  804160ae12:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ae16:	83 c0 08             	add    $0x8,%eax
  804160ae19:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ae1c:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160ae1f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160ae24:	e9 2c 01 00 00       	jmpq   804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160ae29:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ae2c:	83 f8 2f             	cmp    $0x2f,%eax
  804160ae2f:	77 19                	ja     804160ae4a <vprintfmt+0x448>
  804160ae31:	89 c2                	mov    %eax,%edx
  804160ae33:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ae37:	83 c0 08             	add    $0x8,%eax
  804160ae3a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ae3d:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160ae40:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160ae45:	e9 0b 01 00 00       	jmpq   804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160ae4a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160ae4e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160ae52:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160ae56:	eb e5                	jmp    804160ae3d <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  804160ae58:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160ae5c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160ae60:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160ae64:	eb b6                	jmp    804160ae1c <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  804160ae66:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160ae69:	83 f8 2f             	cmp    $0x2f,%eax
  804160ae6c:	77 18                	ja     804160ae86 <vprintfmt+0x484>
  804160ae6e:	89 c2                	mov    %eax,%edx
  804160ae70:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160ae74:	83 c0 08             	add    $0x8,%eax
  804160ae77:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160ae7a:	8b 12                	mov    (%rdx),%edx
        base = 10;
  804160ae7c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160ae81:	e9 cf 00 00 00       	jmpq   804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160ae86:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160ae8a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160ae8e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160ae92:	eb e6                	jmp    804160ae7a <vprintfmt+0x478>
  if (lflag >= 2)
  804160ae94:	83 f9 01             	cmp    $0x1,%ecx
  804160ae97:	7f 25                	jg     804160aebe <vprintfmt+0x4bc>
  else if (lflag)
  804160ae99:	85 c9                	test   %ecx,%ecx
  804160ae9b:	74 5b                	je     804160aef8 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  804160ae9d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160aea0:	83 f8 2f             	cmp    $0x2f,%eax
  804160aea3:	77 45                	ja     804160aeea <vprintfmt+0x4e8>
  804160aea5:	89 c2                	mov    %eax,%edx
  804160aea7:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160aeab:	83 c0 08             	add    $0x8,%eax
  804160aeae:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160aeb1:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160aeb4:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160aeb9:	e9 97 00 00 00       	jmpq   804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160aebe:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160aec1:	83 f8 2f             	cmp    $0x2f,%eax
  804160aec4:	77 16                	ja     804160aedc <vprintfmt+0x4da>
  804160aec6:	89 c2                	mov    %eax,%edx
  804160aec8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160aecc:	83 c0 08             	add    $0x8,%eax
  804160aecf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160aed2:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160aed5:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160aeda:	eb 79                	jmp    804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160aedc:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160aee0:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160aee4:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160aee8:	eb e8                	jmp    804160aed2 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  804160aeea:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160aeee:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160aef2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160aef6:	eb b9                	jmp    804160aeb1 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  804160aef8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160aefb:	83 f8 2f             	cmp    $0x2f,%eax
  804160aefe:	77 15                	ja     804160af15 <vprintfmt+0x513>
  804160af00:	89 c2                	mov    %eax,%edx
  804160af02:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160af06:	83 c0 08             	add    $0x8,%eax
  804160af09:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160af0c:	8b 12                	mov    (%rdx),%edx
        base = 8;
  804160af0e:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160af13:	eb 40                	jmp    804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160af15:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160af19:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160af1d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160af21:	eb e9                	jmp    804160af0c <vprintfmt+0x50a>
        putch('0', putdat);
  804160af23:	4c 89 fe             	mov    %r15,%rsi
  804160af26:	bf 30 00 00 00       	mov    $0x30,%edi
  804160af2b:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  804160af2e:	4c 89 fe             	mov    %r15,%rsi
  804160af31:	bf 78 00 00 00       	mov    $0x78,%edi
  804160af36:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160af39:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160af3c:	83 f8 2f             	cmp    $0x2f,%eax
  804160af3f:	77 34                	ja     804160af75 <vprintfmt+0x573>
  804160af41:	89 c2                	mov    %eax,%edx
  804160af43:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160af47:	83 c0 08             	add    $0x8,%eax
  804160af4a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160af4d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160af50:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  804160af55:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  804160af5a:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  804160af5e:	4c 89 fe             	mov    %r15,%rsi
  804160af61:	4c 89 ef             	mov    %r13,%rdi
  804160af64:	48 b8 d8 a8 60 41 80 	movabs $0x804160a8d8,%rax
  804160af6b:	00 00 00 
  804160af6e:	ff d0                	callq  *%rax
        break;
  804160af70:	e9 b7 fa ff ff       	jmpq   804160aa2c <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160af75:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160af79:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160af7d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160af81:	eb ca                	jmp    804160af4d <vprintfmt+0x54b>
  if (lflag >= 2)
  804160af83:	83 f9 01             	cmp    $0x1,%ecx
  804160af86:	7f 22                	jg     804160afaa <vprintfmt+0x5a8>
  else if (lflag)
  804160af88:	85 c9                	test   %ecx,%ecx
  804160af8a:	74 58                	je     804160afe4 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  804160af8c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160af8f:	83 f8 2f             	cmp    $0x2f,%eax
  804160af92:	77 42                	ja     804160afd6 <vprintfmt+0x5d4>
  804160af94:	89 c2                	mov    %eax,%edx
  804160af96:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160af9a:	83 c0 08             	add    $0x8,%eax
  804160af9d:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160afa0:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160afa3:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160afa8:	eb ab                	jmp    804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160afaa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160afad:	83 f8 2f             	cmp    $0x2f,%eax
  804160afb0:	77 16                	ja     804160afc8 <vprintfmt+0x5c6>
  804160afb2:	89 c2                	mov    %eax,%edx
  804160afb4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160afb8:	83 c0 08             	add    $0x8,%eax
  804160afbb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160afbe:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160afc1:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160afc6:	eb 8d                	jmp    804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160afc8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160afcc:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160afd0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160afd4:	eb e8                	jmp    804160afbe <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  804160afd6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160afda:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160afde:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160afe2:	eb bc                	jmp    804160afa0 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  804160afe4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160afe7:	83 f8 2f             	cmp    $0x2f,%eax
  804160afea:	77 18                	ja     804160b004 <vprintfmt+0x602>
  804160afec:	89 c2                	mov    %eax,%edx
  804160afee:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160aff2:	83 c0 08             	add    $0x8,%eax
  804160aff5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160aff8:	8b 12                	mov    (%rdx),%edx
        base = 16;
  804160affa:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160afff:	e9 51 ff ff ff       	jmpq   804160af55 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160b004:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b008:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b00c:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b010:	eb e6                	jmp    804160aff8 <vprintfmt+0x5f6>
        putch(ch, putdat);
  804160b012:	4c 89 fe             	mov    %r15,%rsi
  804160b015:	bf 25 00 00 00       	mov    $0x25,%edi
  804160b01a:	41 ff d5             	callq  *%r13
        break;
  804160b01d:	e9 0a fa ff ff       	jmpq   804160aa2c <vprintfmt+0x2a>
        putch('%', putdat);
  804160b022:	4c 89 fe             	mov    %r15,%rsi
  804160b025:	bf 25 00 00 00       	mov    $0x25,%edi
  804160b02a:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160b02d:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  804160b031:	0f 84 15 fa ff ff    	je     804160aa4c <vprintfmt+0x4a>
  804160b037:	49 89 de             	mov    %rbx,%r14
  804160b03a:	49 83 ee 01          	sub    $0x1,%r14
  804160b03e:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  804160b043:	75 f5                	jne    804160b03a <vprintfmt+0x638>
  804160b045:	e9 e2 f9 ff ff       	jmpq   804160aa2c <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  804160b04a:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160b04e:	74 06                	je     804160b056 <vprintfmt+0x654>
  804160b050:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160b054:	7f 21                	jg     804160b077 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160b056:	bf 28 00 00 00       	mov    $0x28,%edi
  804160b05b:	48 bb fd dc 60 41 80 	movabs $0x804160dcfd,%rbx
  804160b062:	00 00 00 
  804160b065:	b8 28 00 00 00       	mov    $0x28,%eax
  804160b06a:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160b06e:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160b072:	e9 82 fc ff ff       	jmpq   804160acf9 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160b077:	49 63 f4             	movslq %r12d,%rsi
  804160b07a:	48 bf fc dc 60 41 80 	movabs $0x804160dcfc,%rdi
  804160b081:	00 00 00 
  804160b084:	48 b8 13 b3 60 41 80 	movabs $0x804160b313,%rax
  804160b08b:	00 00 00 
  804160b08e:	ff d0                	callq  *%rax
  804160b090:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160b093:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  804160b096:	48 be fc dc 60 41 80 	movabs $0x804160dcfc,%rsi
  804160b09d:	00 00 00 
  804160b0a0:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  804160b0a4:	85 c0                	test   %eax,%eax
  804160b0a6:	0f 8f f2 fb ff ff    	jg     804160ac9e <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160b0ac:	48 bb fd dc 60 41 80 	movabs $0x804160dcfd,%rbx
  804160b0b3:	00 00 00 
  804160b0b6:	b8 28 00 00 00       	mov    $0x28,%eax
  804160b0bb:	bf 28 00 00 00       	mov    $0x28,%edi
  804160b0c0:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160b0c4:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160b0c8:	e9 2c fc ff ff       	jmpq   804160acf9 <vprintfmt+0x2f7>
}
  804160b0cd:	48 83 c4 48          	add    $0x48,%rsp
  804160b0d1:	5b                   	pop    %rbx
  804160b0d2:	41 5c                	pop    %r12
  804160b0d4:	41 5d                	pop    %r13
  804160b0d6:	41 5e                	pop    %r14
  804160b0d8:	41 5f                	pop    %r15
  804160b0da:	5d                   	pop    %rbp
  804160b0db:	c3                   	retq   

000000804160b0dc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  804160b0dc:	55                   	push   %rbp
  804160b0dd:	48 89 e5             	mov    %rsp,%rbp
  804160b0e0:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  804160b0e4:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  804160b0e8:	48 63 c6             	movslq %esi,%rax
  804160b0eb:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  804160b0f0:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  804160b0f4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  804160b0fb:	48 85 ff             	test   %rdi,%rdi
  804160b0fe:	74 2a                	je     804160b12a <vsnprintf+0x4e>
  804160b100:	85 f6                	test   %esi,%esi
  804160b102:	7e 26                	jle    804160b12a <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  804160b104:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  804160b108:	48 bf 64 a9 60 41 80 	movabs $0x804160a964,%rdi
  804160b10f:	00 00 00 
  804160b112:	48 b8 02 aa 60 41 80 	movabs $0x804160aa02,%rax
  804160b119:	00 00 00 
  804160b11c:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  804160b11e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160b122:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  804160b125:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  804160b128:	c9                   	leaveq 
  804160b129:	c3                   	retq   
    return -E_INVAL;
  804160b12a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160b12f:	eb f7                	jmp    804160b128 <vsnprintf+0x4c>

000000804160b131 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  804160b131:	55                   	push   %rbp
  804160b132:	48 89 e5             	mov    %rsp,%rbp
  804160b135:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160b13c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160b143:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160b14a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160b151:	84 c0                	test   %al,%al
  804160b153:	74 20                	je     804160b175 <snprintf+0x44>
  804160b155:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160b159:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160b15d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160b161:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160b165:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160b169:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160b16d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160b171:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  804160b175:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160b17c:	00 00 00 
  804160b17f:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160b186:	00 00 00 
  804160b189:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160b18d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160b194:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160b19b:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  804160b1a2:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160b1a9:	48 b8 dc b0 60 41 80 	movabs $0x804160b0dc,%rax
  804160b1b0:	00 00 00 
  804160b1b3:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  804160b1b5:	c9                   	leaveq 
  804160b1b6:	c3                   	retq   

000000804160b1b7 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  804160b1b7:	55                   	push   %rbp
  804160b1b8:	48 89 e5             	mov    %rsp,%rbp
  804160b1bb:	41 57                	push   %r15
  804160b1bd:	41 56                	push   %r14
  804160b1bf:	41 55                	push   %r13
  804160b1c1:	41 54                	push   %r12
  804160b1c3:	53                   	push   %rbx
  804160b1c4:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  804160b1c8:	48 85 ff             	test   %rdi,%rdi
  804160b1cb:	74 1e                	je     804160b1eb <readline+0x34>
    cprintf("%s", prompt);
  804160b1cd:	48 89 fe             	mov    %rdi,%rsi
  804160b1d0:	48 bf eb bf 60 41 80 	movabs $0x804160bfeb,%rdi
  804160b1d7:	00 00 00 
  804160b1da:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b1df:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160b1e6:	00 00 00 
  804160b1e9:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  804160b1eb:	bf 00 00 00 00       	mov    $0x0,%edi
  804160b1f0:	48 b8 4c 0d 60 41 80 	movabs $0x8041600d4c,%rax
  804160b1f7:	00 00 00 
  804160b1fa:	ff d0                	callq  *%rax
  804160b1fc:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  804160b1ff:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  804160b205:	49 bd 2c 0d 60 41 80 	movabs $0x8041600d2c,%r13
  804160b20c:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  804160b20f:	49 bf 1a 0d 60 41 80 	movabs $0x8041600d1a,%r15
  804160b216:	00 00 00 
  804160b219:	eb 3f                	jmp    804160b25a <readline+0xa3>
      cprintf("read error: %i\n", c);
  804160b21b:	89 c6                	mov    %eax,%esi
  804160b21d:	48 bf b0 e0 60 41 80 	movabs $0x804160e0b0,%rdi
  804160b224:	00 00 00 
  804160b227:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b22c:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160b233:	00 00 00 
  804160b236:	ff d2                	callq  *%rdx
      return NULL;
  804160b238:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  804160b23d:	48 83 c4 08          	add    $0x8,%rsp
  804160b241:	5b                   	pop    %rbx
  804160b242:	41 5c                	pop    %r12
  804160b244:	41 5d                	pop    %r13
  804160b246:	41 5e                	pop    %r14
  804160b248:	41 5f                	pop    %r15
  804160b24a:	5d                   	pop    %rbp
  804160b24b:	c3                   	retq   
      if (i > 0) {
  804160b24c:	45 85 e4             	test   %r12d,%r12d
  804160b24f:	7e 09                	jle    804160b25a <readline+0xa3>
        if (echoing) {
  804160b251:	45 85 f6             	test   %r14d,%r14d
  804160b254:	75 41                	jne    804160b297 <readline+0xe0>
        i--;
  804160b256:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  804160b25a:	41 ff d5             	callq  *%r13
  804160b25d:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  804160b25f:	85 c0                	test   %eax,%eax
  804160b261:	78 b8                	js     804160b21b <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  804160b263:	83 f8 08             	cmp    $0x8,%eax
  804160b266:	74 e4                	je     804160b24c <readline+0x95>
  804160b268:	83 f8 7f             	cmp    $0x7f,%eax
  804160b26b:	74 df                	je     804160b24c <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  804160b26d:	83 f8 1f             	cmp    $0x1f,%eax
  804160b270:	7e 46                	jle    804160b2b8 <readline+0x101>
  804160b272:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  804160b279:	7f 3d                	jg     804160b2b8 <readline+0x101>
      if (echoing)
  804160b27b:	45 85 f6             	test   %r14d,%r14d
  804160b27e:	75 31                	jne    804160b2b1 <readline+0xfa>
      buf[i++] = c;
  804160b280:	49 63 c4             	movslq %r12d,%rax
  804160b283:	48 b9 00 55 70 41 80 	movabs $0x8041705500,%rcx
  804160b28a:	00 00 00 
  804160b28d:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  804160b290:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  804160b295:	eb c3                	jmp    804160b25a <readline+0xa3>
          cputchar('\b');
  804160b297:	bf 08 00 00 00       	mov    $0x8,%edi
  804160b29c:	41 ff d7             	callq  *%r15
          cputchar(' ');
  804160b29f:	bf 20 00 00 00       	mov    $0x20,%edi
  804160b2a4:	41 ff d7             	callq  *%r15
          cputchar('\b');
  804160b2a7:	bf 08 00 00 00       	mov    $0x8,%edi
  804160b2ac:	41 ff d7             	callq  *%r15
  804160b2af:	eb a5                	jmp    804160b256 <readline+0x9f>
        cputchar(c);
  804160b2b1:	89 c7                	mov    %eax,%edi
  804160b2b3:	41 ff d7             	callq  *%r15
  804160b2b6:	eb c8                	jmp    804160b280 <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  804160b2b8:	83 fb 0a             	cmp    $0xa,%ebx
  804160b2bb:	74 05                	je     804160b2c2 <readline+0x10b>
  804160b2bd:	83 fb 0d             	cmp    $0xd,%ebx
  804160b2c0:	75 98                	jne    804160b25a <readline+0xa3>
      if (echoing)
  804160b2c2:	45 85 f6             	test   %r14d,%r14d
  804160b2c5:	75 17                	jne    804160b2de <readline+0x127>
      buf[i] = 0;
  804160b2c7:	48 b8 00 55 70 41 80 	movabs $0x8041705500,%rax
  804160b2ce:	00 00 00 
  804160b2d1:	4d 63 e4             	movslq %r12d,%r12
  804160b2d4:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  804160b2d9:	e9 5f ff ff ff       	jmpq   804160b23d <readline+0x86>
        cputchar('\n');
  804160b2de:	bf 0a 00 00 00       	mov    $0xa,%edi
  804160b2e3:	48 b8 1a 0d 60 41 80 	movabs $0x8041600d1a,%rax
  804160b2ea:	00 00 00 
  804160b2ed:	ff d0                	callq  *%rax
  804160b2ef:	eb d6                	jmp    804160b2c7 <readline+0x110>

000000804160b2f1 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  804160b2f1:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160b2f4:	74 17                	je     804160b30d <strlen+0x1c>
  804160b2f6:	48 89 fa             	mov    %rdi,%rdx
  804160b2f9:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160b2fe:	29 f9                	sub    %edi,%ecx
    n++;
  804160b300:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  804160b303:	48 83 c2 01          	add    $0x1,%rdx
  804160b307:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160b30a:	75 f4                	jne    804160b300 <strlen+0xf>
  804160b30c:	c3                   	retq   
  804160b30d:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160b312:	c3                   	retq   

000000804160b313 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160b313:	48 85 f6             	test   %rsi,%rsi
  804160b316:	74 24                	je     804160b33c <strnlen+0x29>
  804160b318:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160b31b:	74 25                	je     804160b342 <strnlen+0x2f>
  804160b31d:	48 01 fe             	add    %rdi,%rsi
  804160b320:	48 89 fa             	mov    %rdi,%rdx
  804160b323:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160b328:	29 f9                	sub    %edi,%ecx
    n++;
  804160b32a:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160b32d:	48 83 c2 01          	add    $0x1,%rdx
  804160b331:	48 39 f2             	cmp    %rsi,%rdx
  804160b334:	74 11                	je     804160b347 <strnlen+0x34>
  804160b336:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160b339:	75 ef                	jne    804160b32a <strnlen+0x17>
  804160b33b:	c3                   	retq   
  804160b33c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b341:	c3                   	retq   
  804160b342:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160b347:	c3                   	retq   

000000804160b348 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  804160b348:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  804160b34b:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b350:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  804160b354:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  804160b357:	48 83 c2 01          	add    $0x1,%rdx
  804160b35b:	84 c9                	test   %cl,%cl
  804160b35d:	75 f1                	jne    804160b350 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  804160b35f:	c3                   	retq   

000000804160b360 <strcat>:

char *
strcat(char *dst, const char *src) {
  804160b360:	55                   	push   %rbp
  804160b361:	48 89 e5             	mov    %rsp,%rbp
  804160b364:	41 54                	push   %r12
  804160b366:	53                   	push   %rbx
  804160b367:	48 89 fb             	mov    %rdi,%rbx
  804160b36a:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  804160b36d:	48 b8 f1 b2 60 41 80 	movabs $0x804160b2f1,%rax
  804160b374:	00 00 00 
  804160b377:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  804160b379:	48 63 f8             	movslq %eax,%rdi
  804160b37c:	48 01 df             	add    %rbx,%rdi
  804160b37f:	4c 89 e6             	mov    %r12,%rsi
  804160b382:	48 b8 48 b3 60 41 80 	movabs $0x804160b348,%rax
  804160b389:	00 00 00 
  804160b38c:	ff d0                	callq  *%rax
  return dst;
}
  804160b38e:	48 89 d8             	mov    %rbx,%rax
  804160b391:	5b                   	pop    %rbx
  804160b392:	41 5c                	pop    %r12
  804160b394:	5d                   	pop    %rbp
  804160b395:	c3                   	retq   

000000804160b396 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  804160b396:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  804160b399:	48 85 d2             	test   %rdx,%rdx
  804160b39c:	74 1f                	je     804160b3bd <strncpy+0x27>
  804160b39e:	48 01 fa             	add    %rdi,%rdx
  804160b3a1:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  804160b3a4:	48 83 c1 01          	add    $0x1,%rcx
  804160b3a8:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160b3ac:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  804160b3b0:	41 80 f8 01          	cmp    $0x1,%r8b
  804160b3b4:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  804160b3b8:	48 39 ca             	cmp    %rcx,%rdx
  804160b3bb:	75 e7                	jne    804160b3a4 <strncpy+0xe>
  }
  return ret;
}
  804160b3bd:	c3                   	retq   

000000804160b3be <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  804160b3be:	48 89 f8             	mov    %rdi,%rax
  804160b3c1:	48 85 d2             	test   %rdx,%rdx
  804160b3c4:	74 36                	je     804160b3fc <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  804160b3c6:	48 83 fa 01          	cmp    $0x1,%rdx
  804160b3ca:	74 2d                	je     804160b3f9 <strlcpy+0x3b>
  804160b3cc:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160b3d0:	45 84 c0             	test   %r8b,%r8b
  804160b3d3:	74 24                	je     804160b3f9 <strlcpy+0x3b>
  804160b3d5:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  804160b3d9:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  804160b3de:	48 83 c0 01          	add    $0x1,%rax
  804160b3e2:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  804160b3e6:	48 39 d1             	cmp    %rdx,%rcx
  804160b3e9:	74 0e                	je     804160b3f9 <strlcpy+0x3b>
  804160b3eb:	48 83 c1 01          	add    $0x1,%rcx
  804160b3ef:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  804160b3f4:	45 84 c0             	test   %r8b,%r8b
  804160b3f7:	75 e5                	jne    804160b3de <strlcpy+0x20>
    *dst = '\0';
  804160b3f9:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  804160b3fc:	48 29 f8             	sub    %rdi,%rax
}
  804160b3ff:	c3                   	retq   

000000804160b400 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  804160b400:	0f b6 07             	movzbl (%rdi),%eax
  804160b403:	84 c0                	test   %al,%al
  804160b405:	74 17                	je     804160b41e <strcmp+0x1e>
  804160b407:	3a 06                	cmp    (%rsi),%al
  804160b409:	75 13                	jne    804160b41e <strcmp+0x1e>
    p++, q++;
  804160b40b:	48 83 c7 01          	add    $0x1,%rdi
  804160b40f:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  804160b413:	0f b6 07             	movzbl (%rdi),%eax
  804160b416:	84 c0                	test   %al,%al
  804160b418:	74 04                	je     804160b41e <strcmp+0x1e>
  804160b41a:	3a 06                	cmp    (%rsi),%al
  804160b41c:	74 ed                	je     804160b40b <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  804160b41e:	0f b6 c0             	movzbl %al,%eax
  804160b421:	0f b6 16             	movzbl (%rsi),%edx
  804160b424:	29 d0                	sub    %edx,%eax
}
  804160b426:	c3                   	retq   

000000804160b427 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  804160b427:	48 85 d2             	test   %rdx,%rdx
  804160b42a:	74 2f                	je     804160b45b <strncmp+0x34>
  804160b42c:	0f b6 07             	movzbl (%rdi),%eax
  804160b42f:	84 c0                	test   %al,%al
  804160b431:	74 1f                	je     804160b452 <strncmp+0x2b>
  804160b433:	3a 06                	cmp    (%rsi),%al
  804160b435:	75 1b                	jne    804160b452 <strncmp+0x2b>
  804160b437:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  804160b43a:	48 83 c7 01          	add    $0x1,%rdi
  804160b43e:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  804160b442:	48 39 d7             	cmp    %rdx,%rdi
  804160b445:	74 1a                	je     804160b461 <strncmp+0x3a>
  804160b447:	0f b6 07             	movzbl (%rdi),%eax
  804160b44a:	84 c0                	test   %al,%al
  804160b44c:	74 04                	je     804160b452 <strncmp+0x2b>
  804160b44e:	3a 06                	cmp    (%rsi),%al
  804160b450:	74 e8                	je     804160b43a <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  804160b452:	0f b6 07             	movzbl (%rdi),%eax
  804160b455:	0f b6 16             	movzbl (%rsi),%edx
  804160b458:	29 d0                	sub    %edx,%eax
}
  804160b45a:	c3                   	retq   
    return 0;
  804160b45b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b460:	c3                   	retq   
  804160b461:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b466:	c3                   	retq   

000000804160b467 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  804160b467:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  804160b469:	0f b6 07             	movzbl (%rdi),%eax
  804160b46c:	84 c0                	test   %al,%al
  804160b46e:	74 1e                	je     804160b48e <strchr+0x27>
    if (*s == c)
  804160b470:	40 38 c6             	cmp    %al,%sil
  804160b473:	74 1f                	je     804160b494 <strchr+0x2d>
  for (; *s; s++)
  804160b475:	48 83 c7 01          	add    $0x1,%rdi
  804160b479:	0f b6 07             	movzbl (%rdi),%eax
  804160b47c:	84 c0                	test   %al,%al
  804160b47e:	74 08                	je     804160b488 <strchr+0x21>
    if (*s == c)
  804160b480:	38 d0                	cmp    %dl,%al
  804160b482:	75 f1                	jne    804160b475 <strchr+0xe>
  for (; *s; s++)
  804160b484:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  804160b487:	c3                   	retq   
  return 0;
  804160b488:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b48d:	c3                   	retq   
  804160b48e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b493:	c3                   	retq   
    if (*s == c)
  804160b494:	48 89 f8             	mov    %rdi,%rax
  804160b497:	c3                   	retq   

000000804160b498 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  804160b498:	48 89 f8             	mov    %rdi,%rax
  804160b49b:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  804160b49d:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  804160b4a0:	40 38 f2             	cmp    %sil,%dl
  804160b4a3:	74 13                	je     804160b4b8 <strfind+0x20>
  804160b4a5:	84 d2                	test   %dl,%dl
  804160b4a7:	74 0f                	je     804160b4b8 <strfind+0x20>
  for (; *s; s++)
  804160b4a9:	48 83 c0 01          	add    $0x1,%rax
  804160b4ad:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  804160b4b0:	38 ca                	cmp    %cl,%dl
  804160b4b2:	74 04                	je     804160b4b8 <strfind+0x20>
  804160b4b4:	84 d2                	test   %dl,%dl
  804160b4b6:	75 f1                	jne    804160b4a9 <strfind+0x11>
      break;
  return (char *)s;
}
  804160b4b8:	c3                   	retq   

000000804160b4b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  804160b4b9:	48 85 d2             	test   %rdx,%rdx
  804160b4bc:	74 3a                	je     804160b4f8 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160b4be:	48 89 f8             	mov    %rdi,%rax
  804160b4c1:	48 09 d0             	or     %rdx,%rax
  804160b4c4:	a8 03                	test   $0x3,%al
  804160b4c6:	75 28                	jne    804160b4f0 <memset+0x37>
    uint32_t k = c & 0xFFU;
  804160b4c8:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  804160b4cc:	89 f0                	mov    %esi,%eax
  804160b4ce:	c1 e0 08             	shl    $0x8,%eax
  804160b4d1:	89 f1                	mov    %esi,%ecx
  804160b4d3:	c1 e1 18             	shl    $0x18,%ecx
  804160b4d6:	41 89 f0             	mov    %esi,%r8d
  804160b4d9:	41 c1 e0 10          	shl    $0x10,%r8d
  804160b4dd:	44 09 c1             	or     %r8d,%ecx
  804160b4e0:	09 ce                	or     %ecx,%esi
  804160b4e2:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  804160b4e4:	48 c1 ea 02          	shr    $0x2,%rdx
  804160b4e8:	48 89 d1             	mov    %rdx,%rcx
  804160b4eb:	fc                   	cld    
  804160b4ec:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160b4ee:	eb 08                	jmp    804160b4f8 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  804160b4f0:	89 f0                	mov    %esi,%eax
  804160b4f2:	48 89 d1             	mov    %rdx,%rcx
  804160b4f5:	fc                   	cld    
  804160b4f6:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  804160b4f8:	48 89 f8             	mov    %rdi,%rax
  804160b4fb:	c3                   	retq   

000000804160b4fc <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  804160b4fc:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  804160b4ff:	48 39 fe             	cmp    %rdi,%rsi
  804160b502:	73 40                	jae    804160b544 <memmove+0x48>
  804160b504:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  804160b508:	48 39 f9             	cmp    %rdi,%rcx
  804160b50b:	76 37                	jbe    804160b544 <memmove+0x48>
    s += n;
    d += n;
  804160b50d:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160b511:	48 89 fe             	mov    %rdi,%rsi
  804160b514:	48 09 d6             	or     %rdx,%rsi
  804160b517:	48 09 ce             	or     %rcx,%rsi
  804160b51a:	40 f6 c6 03          	test   $0x3,%sil
  804160b51e:	75 14                	jne    804160b534 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  804160b520:	48 83 ef 04          	sub    $0x4,%rdi
  804160b524:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  804160b528:	48 c1 ea 02          	shr    $0x2,%rdx
  804160b52c:	48 89 d1             	mov    %rdx,%rcx
  804160b52f:	fd                   	std    
  804160b530:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160b532:	eb 0e                	jmp    804160b542 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  804160b534:	48 83 ef 01          	sub    $0x1,%rdi
  804160b538:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  804160b53c:	48 89 d1             	mov    %rdx,%rcx
  804160b53f:	fd                   	std    
  804160b540:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  804160b542:	fc                   	cld    
  804160b543:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160b544:	48 89 c1             	mov    %rax,%rcx
  804160b547:	48 09 d1             	or     %rdx,%rcx
  804160b54a:	48 09 f1             	or     %rsi,%rcx
  804160b54d:	f6 c1 03             	test   $0x3,%cl
  804160b550:	75 0e                	jne    804160b560 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  804160b552:	48 c1 ea 02          	shr    $0x2,%rdx
  804160b556:	48 89 d1             	mov    %rdx,%rcx
  804160b559:	48 89 c7             	mov    %rax,%rdi
  804160b55c:	fc                   	cld    
  804160b55d:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160b55f:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  804160b560:	48 89 c7             	mov    %rax,%rdi
  804160b563:	48 89 d1             	mov    %rdx,%rcx
  804160b566:	fc                   	cld    
  804160b567:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  804160b569:	c3                   	retq   

000000804160b56a <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  804160b56a:	55                   	push   %rbp
  804160b56b:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  804160b56e:	48 b8 fc b4 60 41 80 	movabs $0x804160b4fc,%rax
  804160b575:	00 00 00 
  804160b578:	ff d0                	callq  *%rax
}
  804160b57a:	5d                   	pop    %rbp
  804160b57b:	c3                   	retq   

000000804160b57c <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  804160b57c:	55                   	push   %rbp
  804160b57d:	48 89 e5             	mov    %rsp,%rbp
  804160b580:	41 57                	push   %r15
  804160b582:	41 56                	push   %r14
  804160b584:	41 55                	push   %r13
  804160b586:	41 54                	push   %r12
  804160b588:	53                   	push   %rbx
  804160b589:	48 83 ec 08          	sub    $0x8,%rsp
  804160b58d:	49 89 fe             	mov    %rdi,%r14
  804160b590:	49 89 f7             	mov    %rsi,%r15
  804160b593:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  804160b596:	48 89 f7             	mov    %rsi,%rdi
  804160b599:	48 b8 f1 b2 60 41 80 	movabs $0x804160b2f1,%rax
  804160b5a0:	00 00 00 
  804160b5a3:	ff d0                	callq  *%rax
  804160b5a5:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  804160b5a8:	4c 89 ee             	mov    %r13,%rsi
  804160b5ab:	4c 89 f7             	mov    %r14,%rdi
  804160b5ae:	48 b8 13 b3 60 41 80 	movabs $0x804160b313,%rax
  804160b5b5:	00 00 00 
  804160b5b8:	ff d0                	callq  *%rax
  804160b5ba:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  804160b5bd:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  804160b5c1:	4d 39 e5             	cmp    %r12,%r13
  804160b5c4:	74 26                	je     804160b5ec <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  804160b5c6:	4c 89 e8             	mov    %r13,%rax
  804160b5c9:	4c 29 e0             	sub    %r12,%rax
  804160b5cc:	48 39 d8             	cmp    %rbx,%rax
  804160b5cf:	76 2a                	jbe    804160b5fb <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  804160b5d1:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  804160b5d5:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160b5d9:	4c 89 fe             	mov    %r15,%rsi
  804160b5dc:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160b5e3:	00 00 00 
  804160b5e6:	ff d0                	callq  *%rax
  return dstlen + srclen;
  804160b5e8:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  804160b5ec:	48 83 c4 08          	add    $0x8,%rsp
  804160b5f0:	5b                   	pop    %rbx
  804160b5f1:	41 5c                	pop    %r12
  804160b5f3:	41 5d                	pop    %r13
  804160b5f5:	41 5e                	pop    %r14
  804160b5f7:	41 5f                	pop    %r15
  804160b5f9:	5d                   	pop    %rbp
  804160b5fa:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  804160b5fb:	49 83 ed 01          	sub    $0x1,%r13
  804160b5ff:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160b603:	4c 89 ea             	mov    %r13,%rdx
  804160b606:	4c 89 fe             	mov    %r15,%rsi
  804160b609:	48 b8 6a b5 60 41 80 	movabs $0x804160b56a,%rax
  804160b610:	00 00 00 
  804160b613:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  804160b615:	4d 01 ee             	add    %r13,%r14
  804160b618:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  804160b61d:	eb c9                	jmp    804160b5e8 <strlcat+0x6c>

000000804160b61f <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  804160b61f:	48 85 d2             	test   %rdx,%rdx
  804160b622:	74 3a                	je     804160b65e <memcmp+0x3f>
    if (*s1 != *s2)
  804160b624:	0f b6 0f             	movzbl (%rdi),%ecx
  804160b627:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160b62b:	44 38 c1             	cmp    %r8b,%cl
  804160b62e:	75 1d                	jne    804160b64d <memcmp+0x2e>
  804160b630:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  804160b635:	48 39 d0             	cmp    %rdx,%rax
  804160b638:	74 1e                	je     804160b658 <memcmp+0x39>
    if (*s1 != *s2)
  804160b63a:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  804160b63e:	48 83 c0 01          	add    $0x1,%rax
  804160b642:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  804160b648:	44 38 c1             	cmp    %r8b,%cl
  804160b64b:	74 e8                	je     804160b635 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  804160b64d:	0f b6 c1             	movzbl %cl,%eax
  804160b650:	45 0f b6 c0          	movzbl %r8b,%r8d
  804160b654:	44 29 c0             	sub    %r8d,%eax
  804160b657:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  804160b658:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b65d:	c3                   	retq   
  804160b65e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160b663:	c3                   	retq   

000000804160b664 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  804160b664:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  804160b668:	48 39 c7             	cmp    %rax,%rdi
  804160b66b:	73 19                	jae    804160b686 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160b66d:	89 f2                	mov    %esi,%edx
  804160b66f:	40 38 37             	cmp    %sil,(%rdi)
  804160b672:	74 16                	je     804160b68a <memfind+0x26>
  for (; s < ends; s++)
  804160b674:	48 83 c7 01          	add    $0x1,%rdi
  804160b678:	48 39 f8             	cmp    %rdi,%rax
  804160b67b:	74 08                	je     804160b685 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160b67d:	38 17                	cmp    %dl,(%rdi)
  804160b67f:	75 f3                	jne    804160b674 <memfind+0x10>
  for (; s < ends; s++)
  804160b681:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  804160b684:	c3                   	retq   
  804160b685:	c3                   	retq   
  for (; s < ends; s++)
  804160b686:	48 89 f8             	mov    %rdi,%rax
  804160b689:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  804160b68a:	48 89 f8             	mov    %rdi,%rax
  804160b68d:	c3                   	retq   

000000804160b68e <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  804160b68e:	0f b6 07             	movzbl (%rdi),%eax
  804160b691:	3c 20                	cmp    $0x20,%al
  804160b693:	74 04                	je     804160b699 <strtol+0xb>
  804160b695:	3c 09                	cmp    $0x9,%al
  804160b697:	75 0f                	jne    804160b6a8 <strtol+0x1a>
    s++;
  804160b699:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  804160b69d:	0f b6 07             	movzbl (%rdi),%eax
  804160b6a0:	3c 20                	cmp    $0x20,%al
  804160b6a2:	74 f5                	je     804160b699 <strtol+0xb>
  804160b6a4:	3c 09                	cmp    $0x9,%al
  804160b6a6:	74 f1                	je     804160b699 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  804160b6a8:	3c 2b                	cmp    $0x2b,%al
  804160b6aa:	74 2b                	je     804160b6d7 <strtol+0x49>
  int neg  = 0;
  804160b6ac:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  804160b6b2:	3c 2d                	cmp    $0x2d,%al
  804160b6b4:	74 2d                	je     804160b6e3 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160b6b6:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  804160b6bc:	75 0f                	jne    804160b6cd <strtol+0x3f>
  804160b6be:	80 3f 30             	cmpb   $0x30,(%rdi)
  804160b6c1:	74 2c                	je     804160b6ef <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  804160b6c3:	85 d2                	test   %edx,%edx
  804160b6c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  804160b6ca:	0f 44 d0             	cmove  %eax,%edx
  804160b6cd:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  804160b6d2:	4c 63 d2             	movslq %edx,%r10
  804160b6d5:	eb 5c                	jmp    804160b733 <strtol+0xa5>
    s++;
  804160b6d7:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  804160b6db:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160b6e1:	eb d3                	jmp    804160b6b6 <strtol+0x28>
    s++, neg = 1;
  804160b6e3:	48 83 c7 01          	add    $0x1,%rdi
  804160b6e7:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160b6ed:	eb c7                	jmp    804160b6b6 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160b6ef:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  804160b6f3:	74 0f                	je     804160b704 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  804160b6f5:	85 d2                	test   %edx,%edx
  804160b6f7:	75 d4                	jne    804160b6cd <strtol+0x3f>
    s++, base = 8;
  804160b6f9:	48 83 c7 01          	add    $0x1,%rdi
  804160b6fd:	ba 08 00 00 00       	mov    $0x8,%edx
  804160b702:	eb c9                	jmp    804160b6cd <strtol+0x3f>
    s += 2, base = 16;
  804160b704:	48 83 c7 02          	add    $0x2,%rdi
  804160b708:	ba 10 00 00 00       	mov    $0x10,%edx
  804160b70d:	eb be                	jmp    804160b6cd <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  804160b70f:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  804160b713:	41 80 f8 19          	cmp    $0x19,%r8b
  804160b717:	77 2f                	ja     804160b748 <strtol+0xba>
      dig = *s - 'a' + 10;
  804160b719:	44 0f be c1          	movsbl %cl,%r8d
  804160b71d:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  804160b721:	39 d1                	cmp    %edx,%ecx
  804160b723:	7d 37                	jge    804160b75c <strtol+0xce>
    s++, val = (val * base) + dig;
  804160b725:	48 83 c7 01          	add    $0x1,%rdi
  804160b729:	49 0f af c2          	imul   %r10,%rax
  804160b72d:	48 63 c9             	movslq %ecx,%rcx
  804160b730:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  804160b733:	0f b6 0f             	movzbl (%rdi),%ecx
  804160b736:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  804160b73a:	41 80 f8 09          	cmp    $0x9,%r8b
  804160b73e:	77 cf                	ja     804160b70f <strtol+0x81>
      dig = *s - '0';
  804160b740:	0f be c9             	movsbl %cl,%ecx
  804160b743:	83 e9 30             	sub    $0x30,%ecx
  804160b746:	eb d9                	jmp    804160b721 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  804160b748:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  804160b74c:	41 80 f8 19          	cmp    $0x19,%r8b
  804160b750:	77 0a                	ja     804160b75c <strtol+0xce>
      dig = *s - 'A' + 10;
  804160b752:	44 0f be c1          	movsbl %cl,%r8d
  804160b756:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  804160b75a:	eb c5                	jmp    804160b721 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  804160b75c:	48 85 f6             	test   %rsi,%rsi
  804160b75f:	74 03                	je     804160b764 <strtol+0xd6>
    *endptr = (char *)s;
  804160b761:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  804160b764:	48 89 c2             	mov    %rax,%rdx
  804160b767:	48 f7 da             	neg    %rdx
  804160b76a:	45 85 c9             	test   %r9d,%r9d
  804160b76d:	48 0f 45 c2          	cmovne %rdx,%rax
}
  804160b771:	c3                   	retq   

000000804160b772 <tsc_calibrate>:
  delta /= i * 256 * 1000;
  return delta;
}

uint64_t
tsc_calibrate(void) {
  804160b772:	55                   	push   %rbp
  804160b773:	48 89 e5             	mov    %rsp,%rbp
  804160b776:	41 57                	push   %r15
  804160b778:	41 56                	push   %r14
  804160b77a:	41 55                	push   %r13
  804160b77c:	41 54                	push   %r12
  804160b77e:	53                   	push   %rbx
  804160b77f:	48 83 ec 28          	sub    $0x28,%rsp
  static uint64_t cpu_freq;

  if (cpu_freq == 0) {
  804160b783:	48 a1 00 59 70 41 80 	movabs 0x8041705900,%rax
  804160b78a:	00 00 00 
  804160b78d:	48 85 c0             	test   %rax,%rax
  804160b790:	0f 85 8c 01 00 00    	jne    804160b922 <tsc_calibrate+0x1b0>
    int i;
    for (i = 0; i < TIMES; i++) {
  804160b796:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  __asm __volatile("inb %w1,%0"
  804160b79c:	41 bd 61 00 00 00    	mov    $0x61,%r13d
  __asm __volatile("outb %0,%w1"
  804160b7a2:	41 bf ff ff ff ff    	mov    $0xffffffff,%r15d
  804160b7a8:	b9 42 00 00 00       	mov    $0x42,%ecx
  uint64_t tsc = 0;
  804160b7ad:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b7b1:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160b7b5:	eb 35                	jmp    804160b7ec <tsc_calibrate+0x7a>
  804160b7b7:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  for (count = 0; count < 50000; count++) {
  804160b7bb:	be 00 00 00 00       	mov    $0x0,%esi
  804160b7c0:	eb 72                	jmp    804160b834 <tsc_calibrate+0xc2>
  uint64_t tsc = 0;
  804160b7c2:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  for (count = 0; count < 50000; count++) {
  804160b7c6:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160b7cc:	e9 c0 00 00 00       	jmpq   804160b891 <tsc_calibrate+0x11f>
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160b7d1:	41 83 c4 01          	add    $0x1,%r12d
  804160b7d5:	83 eb 01             	sub    $0x1,%ebx
  804160b7d8:	41 83 fc 75          	cmp    $0x75,%r12d
  804160b7dc:	75 7a                	jne    804160b858 <tsc_calibrate+0xe6>
    for (i = 0; i < TIMES; i++) {
  804160b7de:	41 83 c3 01          	add    $0x1,%r11d
  804160b7e2:	41 83 fb 64          	cmp    $0x64,%r11d
  804160b7e6:	0f 84 56 01 00 00    	je     804160b942 <tsc_calibrate+0x1d0>
  __asm __volatile("inb %w1,%0"
  804160b7ec:	44 89 ea             	mov    %r13d,%edx
  804160b7ef:	ec                   	in     (%dx),%al
  outb(0x61, (inb(0x61) & ~0x02) | 0x01);
  804160b7f0:	83 e0 fc             	and    $0xfffffffc,%eax
  804160b7f3:	83 c8 01             	or     $0x1,%eax
  __asm __volatile("outb %0,%w1"
  804160b7f6:	ee                   	out    %al,(%dx)
  804160b7f7:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
  804160b7fc:	ba 43 00 00 00       	mov    $0x43,%edx
  804160b801:	ee                   	out    %al,(%dx)
  804160b802:	44 89 f8             	mov    %r15d,%eax
  804160b805:	89 ca                	mov    %ecx,%edx
  804160b807:	ee                   	out    %al,(%dx)
  804160b808:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160b809:	ec                   	in     (%dx),%al
  804160b80a:	ec                   	in     (%dx),%al
  804160b80b:	ec                   	in     (%dx),%al
  804160b80c:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b80d:	3c ff                	cmp    $0xff,%al
  804160b80f:	75 a6                	jne    804160b7b7 <tsc_calibrate+0x45>
  for (count = 0; count < 50000; count++) {
  804160b811:	be 00 00 00 00       	mov    $0x0,%esi
  __asm __volatile("rdtsc"
  804160b816:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b818:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b81c:	89 c7                	mov    %eax,%edi
  804160b81e:	48 09 d7             	or     %rdx,%rdi
  804160b821:	83 c6 01             	add    $0x1,%esi
  804160b824:	81 fe 50 c3 00 00    	cmp    $0xc350,%esi
  804160b82a:	74 08                	je     804160b834 <tsc_calibrate+0xc2>
  __asm __volatile("inb %w1,%0"
  804160b82c:	89 ca                	mov    %ecx,%edx
  804160b82e:	ec                   	in     (%dx),%al
  804160b82f:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b830:	3c ff                	cmp    $0xff,%al
  804160b832:	74 e2                	je     804160b816 <tsc_calibrate+0xa4>
  __asm __volatile("rdtsc"
  804160b834:	0f 31                	rdtsc  
  if (pit_expect_msb(0xff, &tsc, &d1)) {
  804160b836:	83 fe 05             	cmp    $0x5,%esi
  804160b839:	7e a3                	jle    804160b7de <tsc_calibrate+0x6c>
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b83b:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b83f:	89 c0                	mov    %eax,%eax
  804160b841:	48 09 c2             	or     %rax,%rdx
  804160b844:	49 89 d2             	mov    %rdx,%r10
  *deltap = read_tsc() - tsc;
  804160b847:	49 89 d6             	mov    %rdx,%r14
  804160b84a:	49 29 fe             	sub    %rdi,%r14
  804160b84d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160b852:	41 bc 01 00 00 00    	mov    $0x1,%r12d
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160b858:	44 88 65 cf          	mov    %r12b,-0x31(%rbp)
  __asm __volatile("inb %w1,%0"
  804160b85c:	89 ca                	mov    %ecx,%edx
  804160b85e:	ec                   	in     (%dx),%al
  804160b85f:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b860:	38 c3                	cmp    %al,%bl
  804160b862:	0f 85 5a ff ff ff    	jne    804160b7c2 <tsc_calibrate+0x50>
  for (count = 0; count < 50000; count++) {
  804160b868:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  __asm __volatile("rdtsc"
  804160b86e:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b870:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b874:	89 c0                	mov    %eax,%eax
  804160b876:	48 89 d6             	mov    %rdx,%rsi
  804160b879:	48 09 c6             	or     %rax,%rsi
  804160b87c:	41 83 c1 01          	add    $0x1,%r9d
  804160b880:	41 81 f9 50 c3 00 00 	cmp    $0xc350,%r9d
  804160b887:	74 08                	je     804160b891 <tsc_calibrate+0x11f>
  __asm __volatile("inb %w1,%0"
  804160b889:	89 ca                	mov    %ecx,%edx
  804160b88b:	ec                   	in     (%dx),%al
  804160b88c:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160b88d:	38 d8                	cmp    %bl,%al
  804160b88f:	74 dd                	je     804160b86e <tsc_calibrate+0xfc>
  __asm __volatile("rdtsc"
  804160b891:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160b893:	48 c1 e2 20          	shl    $0x20,%rdx
  804160b897:	89 c0                	mov    %eax,%eax
  804160b899:	48 09 c2             	or     %rax,%rdx
  *deltap = read_tsc() - tsc;
  804160b89c:	48 29 f2             	sub    %rsi,%rdx
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160b89f:	41 83 f9 05          	cmp    $0x5,%r9d
  804160b8a3:	0f 8e 35 ff ff ff    	jle    804160b7de <tsc_calibrate+0x6c>
      delta -= tsc;
  804160b8a9:	48 29 fe             	sub    %rdi,%rsi
      if (d1 + d2 >= delta >> 11)
  804160b8ac:	4d 8d 04 16          	lea    (%r14,%rdx,1),%r8
  804160b8b0:	48 89 f0             	mov    %rsi,%rax
  804160b8b3:	48 c1 e8 0b          	shr    $0xb,%rax
  804160b8b7:	49 39 c0             	cmp    %rax,%r8
  804160b8ba:	0f 83 11 ff ff ff    	jae    804160b7d1 <tsc_calibrate+0x5f>
  804160b8c0:	49 89 d0             	mov    %rdx,%r8
  __asm __volatile("inb %w1,%0"
  804160b8c3:	89 ca                	mov    %ecx,%edx
  804160b8c5:	ec                   	in     (%dx),%al
  804160b8c6:	ec                   	in     (%dx),%al
      if (!pit_verify_msb(0xfe - i))
  804160b8c7:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  804160b8cc:	2a 55 cf             	sub    -0x31(%rbp),%dl
  804160b8cf:	38 c2                	cmp    %al,%dl
  804160b8d1:	0f 85 07 ff ff ff    	jne    804160b7de <tsc_calibrate+0x6c>
  delta += (long)(d2 - d1) / 2;
  804160b8d7:	4c 29 d7             	sub    %r10,%rdi
  804160b8da:	49 01 f8             	add    %rdi,%r8
  804160b8dd:	4c 89 c7             	mov    %r8,%rdi
  804160b8e0:	48 c1 ef 3f          	shr    $0x3f,%rdi
  804160b8e4:	49 01 f8             	add    %rdi,%r8
  804160b8e7:	49 d1 f8             	sar    %r8
  804160b8ea:	4c 01 c6             	add    %r8,%rsi
  delta *= PIT_TICK_RATE;
  804160b8ed:	48 69 f6 de 34 12 00 	imul   $0x1234de,%rsi,%rsi
  delta /= i * 256 * 1000;
  804160b8f4:	45 69 e4 00 e8 03 00 	imul   $0x3e800,%r12d,%r12d
  804160b8fb:	4d 63 e4             	movslq %r12d,%r12
  804160b8fe:	48 89 f0             	mov    %rsi,%rax
  804160b901:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b906:	49 f7 f4             	div    %r12
      if ((cpu_freq = quick_pit_calibrate()))
  804160b909:	4c 39 e6             	cmp    %r12,%rsi
  804160b90c:	0f 82 cc fe ff ff    	jb     804160b7de <tsc_calibrate+0x6c>
  804160b912:	48 a3 00 59 70 41 80 	movabs %rax,0x8041705900
  804160b919:	00 00 00 
        break;
    }
    if (i == TIMES) {
  804160b91c:	41 83 fb 64          	cmp    $0x64,%r11d
  804160b920:	74 20                	je     804160b942 <tsc_calibrate+0x1d0>
      cpu_freq = DEFAULT_FREQ;
      cprintf("Can't calibrate pit timer. Using default frequency\n");
    }
  }

  return cpu_freq * 1000;
  804160b922:	48 a1 00 59 70 41 80 	movabs 0x8041705900,%rax
  804160b929:	00 00 00 
  804160b92c:	48 69 c0 e8 03 00 00 	imul   $0x3e8,%rax,%rax
}
  804160b933:	48 83 c4 28          	add    $0x28,%rsp
  804160b937:	5b                   	pop    %rbx
  804160b938:	41 5c                	pop    %r12
  804160b93a:	41 5d                	pop    %r13
  804160b93c:	41 5e                	pop    %r14
  804160b93e:	41 5f                	pop    %r15
  804160b940:	5d                   	pop    %rbp
  804160b941:	c3                   	retq   
      cpu_freq = DEFAULT_FREQ;
  804160b942:	48 b8 00 59 70 41 80 	movabs $0x8041705900,%rax
  804160b949:	00 00 00 
  804160b94c:	48 c7 00 a0 25 26 00 	movq   $0x2625a0,(%rax)
      cprintf("Can't calibrate pit timer. Using default frequency\n");
  804160b953:	48 bf c0 e0 60 41 80 	movabs $0x804160e0c0,%rdi
  804160b95a:	00 00 00 
  804160b95d:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b962:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160b969:	00 00 00 
  804160b96c:	ff d2                	callq  *%rdx
  804160b96e:	eb b2                	jmp    804160b922 <tsc_calibrate+0x1b0>

000000804160b970 <print_time>:

void
print_time(unsigned seconds) {
  804160b970:	55                   	push   %rbp
  804160b971:	48 89 e5             	mov    %rsp,%rbp
  804160b974:	89 fe                	mov    %edi,%esi
  cprintf("%u\n", seconds);
  804160b976:	48 bf f8 e0 60 41 80 	movabs $0x804160e0f8,%rdi
  804160b97d:	00 00 00 
  804160b980:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b985:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160b98c:	00 00 00 
  804160b98f:	ff d2                	callq  *%rdx
}
  804160b991:	5d                   	pop    %rbp
  804160b992:	c3                   	retq   

000000804160b993 <print_timer_error>:

void
print_timer_error(void) {
  804160b993:	55                   	push   %rbp
  804160b994:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Timer Error\n");
  804160b997:	48 bf fc e0 60 41 80 	movabs $0x804160e0fc,%rdi
  804160b99e:	00 00 00 
  804160b9a1:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b9a6:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160b9ad:	00 00 00 
  804160b9b0:	ff d2                	callq  *%rdx
}
  804160b9b2:	5d                   	pop    %rbp
  804160b9b3:	c3                   	retq   

000000804160b9b4 <timer_start>:
static int timer_id       = -1;
static uint64_t timer     = 0;
static uint64_t freq      = 0;

void
timer_start(const char *name) {
  804160b9b4:	55                   	push   %rbp
  804160b9b5:	48 89 e5             	mov    %rsp,%rbp
  804160b9b8:	41 56                	push   %r14
  804160b9ba:	41 55                	push   %r13
  804160b9bc:	41 54                	push   %r12
  804160b9be:	53                   	push   %rbx
  804160b9bf:	49 89 fe             	mov    %rdi,%r14
  (void)timer_id;
  (void)timer;
  // DELETED in LAB 5 end

  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160b9c2:	49 bc 60 59 70 41 80 	movabs $0x8041705960,%r12
  804160b9c9:	00 00 00 
  804160b9cc:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160b9d1:	49 bd 00 b4 60 41 80 	movabs $0x804160b400,%r13
  804160b9d8:	00 00 00 
  804160b9db:	eb 0c                	jmp    804160b9e9 <timer_start+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160b9dd:	83 c3 01             	add    $0x1,%ebx
  804160b9e0:	49 83 c4 28          	add    $0x28,%r12
  804160b9e4:	83 fb 05             	cmp    $0x5,%ebx
  804160b9e7:	74 61                	je     804160ba4a <timer_start+0x96>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160b9e9:	49 8b 3c 24          	mov    (%r12),%rdi
  804160b9ed:	48 85 ff             	test   %rdi,%rdi
  804160b9f0:	74 eb                	je     804160b9dd <timer_start+0x29>
  804160b9f2:	4c 89 f6             	mov    %r14,%rsi
  804160b9f5:	41 ff d5             	callq  *%r13
  804160b9f8:	85 c0                	test   %eax,%eax
  804160b9fa:	75 e1                	jne    804160b9dd <timer_start+0x29>
      timer_id      = i;
  804160b9fc:	89 d8                	mov    %ebx,%eax
  804160b9fe:	a3 c0 f8 61 41 80 00 	movabs %eax,0x804161f8c0
  804160ba05:	00 00 
      timer_started = 1;
  804160ba07:	48 b8 18 59 70 41 80 	movabs $0x8041705918,%rax
  804160ba0e:	00 00 00 
  804160ba11:	c6 00 01             	movb   $0x1,(%rax)
  __asm __volatile("rdtsc"
  804160ba14:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ba16:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ba1a:	89 c0                	mov    %eax,%eax
  804160ba1c:	48 09 d0             	or     %rdx,%rax
  804160ba1f:	48 a3 10 59 70 41 80 	movabs %rax,0x8041705910
  804160ba26:	00 00 00 
      timer         = read_tsc();
      freq          = timertab[timer_id].get_cpu_freq();
  804160ba29:	48 63 db             	movslq %ebx,%rbx
  804160ba2c:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160ba30:	48 b8 60 59 70 41 80 	movabs $0x8041705960,%rax
  804160ba37:	00 00 00 
  804160ba3a:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160ba3e:	48 a3 08 59 70 41 80 	movabs %rax,0x8041705908
  804160ba45:	00 00 00 
      return;
  804160ba48:	eb 1b                	jmp    804160ba65 <timer_start+0xb1>
    }
  }

  cprintf("Timer Error\n");
  804160ba4a:	48 bf fc e0 60 41 80 	movabs $0x804160e0fc,%rdi
  804160ba51:	00 00 00 
  804160ba54:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ba59:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160ba60:	00 00 00 
  804160ba63:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160ba65:	5b                   	pop    %rbx
  804160ba66:	41 5c                	pop    %r12
  804160ba68:	41 5d                	pop    %r13
  804160ba6a:	41 5e                	pop    %r14
  804160ba6c:	5d                   	pop    %rbp
  804160ba6d:	c3                   	retq   

000000804160ba6e <timer_stop>:

void
timer_stop(void) {
  804160ba6e:	55                   	push   %rbp
  804160ba6f:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  if (!timer_started || timer_id < 0) {
  804160ba72:	48 b8 18 59 70 41 80 	movabs $0x8041705918,%rax
  804160ba79:	00 00 00 
  804160ba7c:	80 38 00             	cmpb   $0x0,(%rax)
  804160ba7f:	74 69                	je     804160baea <timer_stop+0x7c>
  804160ba81:	48 b8 c0 f8 61 41 80 	movabs $0x804161f8c0,%rax
  804160ba88:	00 00 00 
  804160ba8b:	83 38 00             	cmpl   $0x0,(%rax)
  804160ba8e:	78 5a                	js     804160baea <timer_stop+0x7c>
  __asm __volatile("rdtsc"
  804160ba90:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ba92:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ba96:	89 c0                	mov    %eax,%eax
  804160ba98:	48 09 c2             	or     %rax,%rdx
    print_timer_error();
    return;
  }

  print_time((read_tsc() - timer) / freq);
  804160ba9b:	48 b8 10 59 70 41 80 	movabs $0x8041705910,%rax
  804160baa2:	00 00 00 
  804160baa5:	48 2b 10             	sub    (%rax),%rdx
  804160baa8:	48 89 d0             	mov    %rdx,%rax
  804160baab:	48 b9 08 59 70 41 80 	movabs $0x8041705908,%rcx
  804160bab2:	00 00 00 
  804160bab5:	ba 00 00 00 00       	mov    $0x0,%edx
  804160baba:	48 f7 31             	divq   (%rcx)
  804160babd:	89 c7                	mov    %eax,%edi
  804160babf:	48 b8 70 b9 60 41 80 	movabs $0x804160b970,%rax
  804160bac6:	00 00 00 
  804160bac9:	ff d0                	callq  *%rax

  timer_id      = -1;
  804160bacb:	48 b8 c0 f8 61 41 80 	movabs $0x804161f8c0,%rax
  804160bad2:	00 00 00 
  804160bad5:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%rax)
  timer_started = 0;
  804160badb:	48 b8 18 59 70 41 80 	movabs $0x8041705918,%rax
  804160bae2:	00 00 00 
  804160bae5:	c6 00 00             	movb   $0x0,(%rax)
  804160bae8:	eb 0c                	jmp    804160baf6 <timer_stop+0x88>
    print_timer_error();
  804160baea:	48 b8 93 b9 60 41 80 	movabs $0x804160b993,%rax
  804160baf1:	00 00 00 
  804160baf4:	ff d0                	callq  *%rax
  // LAB 5 code end
}
  804160baf6:	5d                   	pop    %rbp
  804160baf7:	c3                   	retq   

000000804160baf8 <timer_cpu_frequency>:

void
timer_cpu_frequency(const char *name) {
  804160baf8:	55                   	push   %rbp
  804160baf9:	48 89 e5             	mov    %rsp,%rbp
  804160bafc:	41 56                	push   %r14
  804160bafe:	41 55                	push   %r13
  804160bb00:	41 54                	push   %r12
  804160bb02:	53                   	push   %rbx
  804160bb03:	49 89 fe             	mov    %rdi,%r14
  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160bb06:	49 bc 60 59 70 41 80 	movabs $0x8041705960,%r12
  804160bb0d:	00 00 00 
  804160bb10:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160bb15:	49 bd 00 b4 60 41 80 	movabs $0x804160b400,%r13
  804160bb1c:	00 00 00 
  804160bb1f:	eb 0c                	jmp    804160bb2d <timer_cpu_frequency+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160bb21:	83 c3 01             	add    $0x1,%ebx
  804160bb24:	49 83 c4 28          	add    $0x28,%r12
  804160bb28:	83 fb 05             	cmp    $0x5,%ebx
  804160bb2b:	74 48                	je     804160bb75 <timer_cpu_frequency+0x7d>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160bb2d:	49 8b 3c 24          	mov    (%r12),%rdi
  804160bb31:	48 85 ff             	test   %rdi,%rdi
  804160bb34:	74 eb                	je     804160bb21 <timer_cpu_frequency+0x29>
  804160bb36:	4c 89 f6             	mov    %r14,%rsi
  804160bb39:	41 ff d5             	callq  *%r13
  804160bb3c:	85 c0                	test   %eax,%eax
  804160bb3e:	75 e1                	jne    804160bb21 <timer_cpu_frequency+0x29>
      cprintf("%lu\n", timertab[i].get_cpu_freq());
  804160bb40:	48 63 db             	movslq %ebx,%rbx
  804160bb43:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160bb47:	48 b8 60 59 70 41 80 	movabs $0x8041705960,%rax
  804160bb4e:	00 00 00 
  804160bb51:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160bb55:	48 89 c6             	mov    %rax,%rsi
  804160bb58:	48 bf 29 c3 60 41 80 	movabs $0x804160c329,%rdi
  804160bb5f:	00 00 00 
  804160bb62:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bb67:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160bb6e:	00 00 00 
  804160bb71:	ff d2                	callq  *%rdx
      return;
  804160bb73:	eb 1b                	jmp    804160bb90 <timer_cpu_frequency+0x98>
    }
  }
  cprintf("Timer Error\n");
  804160bb75:	48 bf fc e0 60 41 80 	movabs $0x804160e0fc,%rdi
  804160bb7c:	00 00 00 
  804160bb7f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bb84:	48 ba 6e 8f 60 41 80 	movabs $0x8041608f6e,%rdx
  804160bb8b:	00 00 00 
  804160bb8e:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160bb90:	5b                   	pop    %rbx
  804160bb91:	41 5c                	pop    %r12
  804160bb93:	41 5d                	pop    %r13
  804160bb95:	41 5e                	pop    %r14
  804160bb97:	5d                   	pop    %rbp
  804160bb98:	c3                   	retq   

000000804160bb99 <efi_call_in_32bit_mode>:
efi_call_in_32bit_mode(uint32_t func,
                       efi_registers *efi_reg,
                       void *stack_contents,
                       size_t stack_contents_size, /* 16-byte multiple */
                       uint32_t *efi_status) {
  if (func == 0) {
  804160bb99:	85 ff                	test   %edi,%edi
  804160bb9b:	74 50                	je     804160bbed <efi_call_in_32bit_mode+0x54>
    return -E_INVAL;
  }

  if ((efi_reg == NULL) || (stack_contents == NULL) || (stack_contents_size % 16 != 0)) {
  804160bb9d:	48 85 f6             	test   %rsi,%rsi
  804160bba0:	74 51                	je     804160bbf3 <efi_call_in_32bit_mode+0x5a>
  804160bba2:	48 85 d2             	test   %rdx,%rdx
  804160bba5:	74 4c                	je     804160bbf3 <efi_call_in_32bit_mode+0x5a>
  804160bba7:	f6 c1 0f             	test   $0xf,%cl
  804160bbaa:	75 4d                	jne    804160bbf9 <efi_call_in_32bit_mode+0x60>
                       uint32_t *efi_status) {
  804160bbac:	55                   	push   %rbp
  804160bbad:	48 89 e5             	mov    %rsp,%rbp
  804160bbb0:	41 54                	push   %r12
  804160bbb2:	53                   	push   %rbx
  804160bbb3:	4d 89 c4             	mov    %r8,%r12
  804160bbb6:	48 89 f3             	mov    %rsi,%rbx
    return -E_INVAL;
  }

  //We need to set up kernel data segments for 32 bit mode
  //before calling asm.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD32));
  804160bbb9:	b8 20 00 00 00       	mov    $0x20,%eax
  804160bbbe:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD32));
  804160bbc0:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD32));
  804160bbc2:	8e d0                	mov    %eax,%ss
  _efi_call_in_32bit_mode_asm(func,
  804160bbc4:	48 b8 00 bc 60 41 80 	movabs $0x804160bc00,%rax
  804160bbcb:	00 00 00 
  804160bbce:	ff d0                	callq  *%rax
                              efi_reg,
                              stack_contents,
                              stack_contents_size);
  //Restore 64 bit kernel data segments.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  804160bbd0:	b8 10 00 00 00       	mov    $0x10,%eax
  804160bbd5:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  804160bbd7:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  804160bbd9:	8e d0                	mov    %eax,%ss

  *efi_status = (uint32_t)efi_reg->rax;
  804160bbdb:	48 8b 43 20          	mov    0x20(%rbx),%rax
  804160bbdf:	41 89 04 24          	mov    %eax,(%r12)

  return 0;
  804160bbe3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160bbe8:	5b                   	pop    %rbx
  804160bbe9:	41 5c                	pop    %r12
  804160bbeb:	5d                   	pop    %rbp
  804160bbec:	c3                   	retq   
    return -E_INVAL;
  804160bbed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160bbf2:	c3                   	retq   
    return -E_INVAL;
  804160bbf3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160bbf8:	c3                   	retq   
  804160bbf9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  804160bbfe:	c3                   	retq   
  804160bbff:	90                   	nop

000000804160bc00 <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  804160bc00:	55                   	push   %rbp
    movq %rsp, %rbp
  804160bc01:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  804160bc04:	53                   	push   %rbx
	push	%r12
  804160bc05:	41 54                	push   %r12
	push	%r13
  804160bc07:	41 55                	push   %r13
	push	%r14
  804160bc09:	41 56                	push   %r14
	push	%r15
  804160bc0b:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  804160bc0d:	56                   	push   %rsi
	push	%rcx
  804160bc0e:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  804160bc0f:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  804160bc10:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  804160bc13:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

000000804160bc1a <copyloop>:
  804160bc1a:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  804160bc1e:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  804160bc22:	49 83 c0 08          	add    $0x8,%r8
  804160bc26:	49 39 c8             	cmp    %rcx,%r8
  804160bc29:	75 ef                	jne    804160bc1a <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  804160bc2b:	e8 00 00 00 00       	callq  804160bc30 <copyloop+0x16>
  804160bc30:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  804160bc37:	00 
  804160bc38:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  804160bc3f:	00 
  804160bc40:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  804160bc41:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  804160bc43:	6a 08                	pushq  $0x8
  804160bc45:	e8 00 00 00 00       	callq  804160bc4a <copyloop+0x30>
  804160bc4a:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  804160bc51:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  804160bc52:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  804160bc56:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  804160bc5a:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  804160bc5e:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  804160bc61:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  804160bc62:	59                   	pop    %rcx
	pop	%rsi
  804160bc63:	5e                   	pop    %rsi
	pop	%r15
  804160bc64:	41 5f                	pop    %r15
	pop	%r14
  804160bc66:	41 5e                	pop    %r14
	pop	%r13
  804160bc68:	41 5d                	pop    %r13
	pop	%r12
  804160bc6a:	41 5c                	pop    %r12
	pop	%rbx
  804160bc6c:	5b                   	pop    %rbx

	leave
  804160bc6d:	c9                   	leaveq 
	ret
  804160bc6e:	c3                   	retq   

000000804160bc6f <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name) {
  lk->locked = 0;
  804160bc6f:	c7 07 00 00 00 00    	movl   $0x0,(%rdi)
#ifdef DEBUG_SPINLOCK
  lk->name = name;
#endif
}
  804160bc75:	c3                   	retq   

000000804160bc76 <spin_lock>:
  asm volatile("lock; xchgl %0, %1"
  804160bc76:	b8 01 00 00 00       	mov    $0x1,%eax
  804160bc7b:	f0 87 07             	lock xchg %eax,(%rdi)
#endif

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
  804160bc7e:	85 c0                	test   %eax,%eax
  804160bc80:	74 10                	je     804160bc92 <spin_lock+0x1c>
  804160bc82:	ba 01 00 00 00       	mov    $0x1,%edx
    asm volatile("pause");
  804160bc87:	f3 90                	pause  
  804160bc89:	89 d0                	mov    %edx,%eax
  804160bc8b:	f0 87 07             	lock xchg %eax,(%rdi)
  while (xchg(&lk->locked, 1) != 0)
  804160bc8e:	85 c0                	test   %eax,%eax
  804160bc90:	75 f5                	jne    804160bc87 <spin_lock+0x11>

    // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  get_caller_pcs(lk->pcs);
#endif
}
  804160bc92:	c3                   	retq   

000000804160bc93 <spin_unlock>:
  804160bc93:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bc98:	f0 87 07             	lock xchg %eax,(%rdi)
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
}
  804160bc9b:	c3                   	retq   
  804160bc9c:	0f 1f 40 00          	nopl   0x0(%rax)
