
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
  8041600020:	48 bb 80 5b 70 41 80 	movabs $0x8041705b80,%rbx
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
  80416002a7:	48 b8 80 43 70 41 80 	movabs $0x8041704380,%rax
  80416002ae:	00 00 00 
  80416002b1:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416002b5:	74 13                	je     80416002ca <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416002b7:	48 bb 5e 3f 60 41 80 	movabs $0x8041603f5e,%rbx
  80416002be:	00 00 00 
  80416002c1:	bf 00 00 00 00       	mov    $0x0,%edi
  80416002c6:	ff d3                	callq  *%rbx
  while (1)
  80416002c8:	eb f7                	jmp    80416002c1 <_panic+0x67>
  panicstr = fmt;
  80416002ca:	4c 89 e0             	mov    %r12,%rax
  80416002cd:	48 a3 80 43 70 41 80 	movabs %rax,0x8041704380
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
  804160030b:	48 bf 40 c6 60 41 80 	movabs $0x804160c640,%rdi
  8041600312:	00 00 00 
  8041600315:	b8 00 00 00 00       	mov    $0x0,%eax
  804160031a:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  8041600321:	00 00 00 
  8041600324:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600326:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160032d:	4c 89 e7             	mov    %r12,%rdi
  8041600330:	48 b8 44 92 60 41 80 	movabs $0x8041609244,%rax
  8041600337:	00 00 00 
  804160033a:	ff d0                	callq  *%rax
  cprintf("\n");
  804160033c:	48 bf e4 db 60 41 80 	movabs $0x804160dbe4,%rdi
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
  8041600360:	49 bc 80 5b 70 41 80 	movabs $0x8041705b80,%r12
  8041600367:	00 00 00 
  804160036a:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
  804160036f:	49 be 91 bd 60 41 80 	movabs $0x804160bd91,%r14
  8041600376:	00 00 00 
  8041600379:	eb 3a                	jmp    80416003b5 <timers_schedule+0x63>
        panic("Timer %s does not support interrupts\n", name);
  804160037b:	4c 89 e9             	mov    %r13,%rcx
  804160037e:	48 ba f8 c6 60 41 80 	movabs $0x804160c6f8,%rdx
  8041600385:	00 00 00 
  8041600388:	be 2d 00 00 00       	mov    $0x2d,%esi
  804160038d:	48 bf 58 c6 60 41 80 	movabs $0x804160c658,%rdi
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
  80416003cf:	48 b8 80 5b 70 41 80 	movabs $0x8041705b80,%rax
  80416003d6:	00 00 00 
  80416003d9:	48 8b 74 d0 18       	mov    0x18(%rax,%rdx,8),%rsi
  80416003de:	48 85 f6             	test   %rsi,%rsi
  80416003e1:	74 98                	je     804160037b <timers_schedule+0x29>
        timer_for_schedule = &timertab[i];
  80416003e3:	48 89 d1             	mov    %rdx,%rcx
  80416003e6:	48 8d 14 c8          	lea    (%rax,%rcx,8),%rdx
  80416003ea:	48 89 d0             	mov    %rdx,%rax
  80416003ed:	48 a3 60 5b 70 41 80 	movabs %rax,0x8041705b60
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
  8041600405:	48 ba 64 c6 60 41 80 	movabs $0x804160c664,%rdx
  804160040c:	00 00 00 
  804160040f:	be 33 00 00 00       	mov    $0x33,%esi
  8041600414:	48 bf 58 c6 60 41 80 	movabs $0x804160c658,%rdi
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
  8041600443:	48 b8 c3 0c 60 41 80 	movabs $0x8041600cc3,%rax
  804160044a:	00 00 00 
  804160044d:	ff d0                	callq  *%rax
  tsc_calibrate();
  804160044f:	48 b8 03 c1 60 41 80 	movabs $0x804160c103,%rax
  8041600456:	00 00 00 
  8041600459:	ff d0                	callq  *%rax
  cprintf("6828 decimal is %o octal!\n", 6828);
  804160045b:	be ac 1a 00 00       	mov    $0x1aac,%esi
  8041600460:	48 bf 7d c6 60 41 80 	movabs $0x804160c67d,%rdi
  8041600467:	00 00 00 
  804160046a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160046f:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  8041600476:	00 00 00 
  8041600479:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  804160047b:	48 be 00 60 70 41 80 	movabs $0x8041706000,%rsi
  8041600482:	00 00 00 
  8041600485:	48 bf 98 c6 60 41 80 	movabs $0x804160c698,%rdi
  804160048c:	00 00 00 
  804160048f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600494:	ff d3                	callq  *%rbx
  mem_init();
  8041600496:	48 b8 ac 52 60 41 80 	movabs $0x80416052ac,%rax
  804160049d:	00 00 00 
  80416004a0:	ff d0                	callq  *%rax
  while (ctor < &__ctors_end) {
  80416004a2:	48 ba 68 43 70 41 80 	movabs $0x8041704368,%rdx
  80416004a9:	00 00 00 
  80416004ac:	48 b8 68 43 70 41 80 	movabs $0x8041704368,%rax
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
  80416004de:	48 b8 5a 91 60 41 80 	movabs $0x804160915a,%rax
  80416004e5:	00 00 00 
  80416004e8:	ff d0                	callq  *%rax
  rtc_init();
  80416004ea:	48 b8 d4 8f 60 41 80 	movabs $0x8041608fd4,%rax
  80416004f1:	00 00 00 
  80416004f4:	ff d0                	callq  *%rax
  timers_init();
  80416004f6:	48 b8 19 00 60 41 80 	movabs $0x8041600019,%rax
  80416004fd:	00 00 00 
  8041600500:	ff d0                	callq  *%rax
  fb_init();
  8041600502:	48 b8 b6 0b 60 41 80 	movabs $0x8041600bb6,%rax
  8041600509:	00 00 00 
  804160050c:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  804160050e:	48 bf a1 c6 60 41 80 	movabs $0x804160c6a1,%rdi
  8041600515:	00 00 00 
  8041600518:	b8 00 00 00 00       	mov    $0x0,%eax
  804160051d:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  8041600524:	00 00 00 
  8041600527:	ff d3                	callq  *%rbx
  env_init();
  8041600529:	48 b8 48 86 60 41 80 	movabs $0x8041608648,%rax
  8041600530:	00 00 00 
  8041600533:	ff d0                	callq  *%rax
  trap_init();
  8041600535:	48 b8 7f 93 60 41 80 	movabs $0x804160937f,%rax
  804160053c:	00 00 00 
  804160053f:	ff d0                	callq  *%rax
  timers_schedule("hpet0");
  8041600541:	48 bf ba c6 60 41 80 	movabs $0x804160c6ba,%rdi
  8041600548:	00 00 00 
  804160054b:	48 b8 52 03 60 41 80 	movabs $0x8041600352,%rax
  8041600552:	00 00 00 
  8041600555:	ff d0                	callq  *%rax
  clock_idt_init();
  8041600557:	48 b8 48 97 60 41 80 	movabs $0x8041609748,%rax
  804160055e:	00 00 00 
  8041600561:	ff d0                	callq  *%rax
  cprintf("\n\nTEST: %s\n", SS(TEST));
  8041600563:	48 be c0 c6 60 41 80 	movabs $0x804160c6c0,%rsi
  804160056a:	00 00 00 
  804160056d:	48 bf c5 c6 60 41 80 	movabs $0x804160c6c5,%rdi
  8041600574:	00 00 00 
  8041600577:	b8 00 00 00 00       	mov    $0x0,%eax
  804160057c:	ff d3                	callq  *%rbx
  cprintf("Hey boy\n");
  804160057e:	48 bf d1 c6 60 41 80 	movabs $0x804160c6d1,%rdi
  8041600585:	00 00 00 
  8041600588:	b8 00 00 00 00       	mov    $0x0,%eax
  804160058d:	ff d3                	callq  *%rbx
  ENV_CREATE(user_evilhello, ENV_TYPE_USER);
  804160058f:	be 02 00 00 00       	mov    $0x2,%esi
  8041600594:	48 bf 28 a7 64 41 80 	movabs $0x804164a728,%rdi
  804160059b:	00 00 00 
  804160059e:	48 b8 2b 89 60 41 80 	movabs $0x804160892b,%rax
  80416005a5:	00 00 00 
  80416005a8:	ff d0                	callq  *%rax
  cprintf("Im not running your tests for you today!\n");
  80416005aa:	48 bf 20 c7 60 41 80 	movabs $0x804160c720,%rdi
  80416005b1:	00 00 00 
  80416005b4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416005b9:	ff d3                	callq  *%rbx
  sched_yield();
  80416005bb:	48 b8 01 ad 60 41 80 	movabs $0x804160ad01,%rax
  80416005c2:	00 00 00 
  80416005c5:	ff d0                	callq  *%rax

00000080416005c7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  80416005c7:	55                   	push   %rbp
  80416005c8:	48 89 e5             	mov    %rsp,%rbp
  80416005cb:	41 54                	push   %r12
  80416005cd:	53                   	push   %rbx
  80416005ce:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80416005d5:	49 89 d4             	mov    %rdx,%r12
  80416005d8:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  80416005df:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80416005e6:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416005ed:	84 c0                	test   %al,%al
  80416005ef:	74 23                	je     8041600614 <_warn+0x4d>
  80416005f1:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416005f8:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416005fc:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  8041600600:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  8041600604:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  8041600608:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  804160060c:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  8041600610:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  8041600614:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  804160061b:	00 00 00 
  804160061e:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8041600625:	00 00 00 
  8041600628:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160062c:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  8041600633:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  804160063a:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  8041600641:	89 f2                	mov    %esi,%edx
  8041600643:	48 89 fe             	mov    %rdi,%rsi
  8041600646:	48 bf da c6 60 41 80 	movabs $0x804160c6da,%rdi
  804160064d:	00 00 00 
  8041600650:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600655:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  804160065c:	00 00 00 
  804160065f:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600661:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600668:	4c 89 e7             	mov    %r12,%rdi
  804160066b:	48 b8 44 92 60 41 80 	movabs $0x8041609244,%rax
  8041600672:	00 00 00 
  8041600675:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600677:	48 bf e4 db 60 41 80 	movabs $0x804160dbe4,%rdi
  804160067e:	00 00 00 
  8041600681:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600686:	ff d3                	callq  *%rbx
  va_end(ap);
}
  8041600688:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  804160068f:	5b                   	pop    %rbx
  8041600690:	41 5c                	pop    %r12
  8041600692:	5d                   	pop    %rbp
  8041600693:	c3                   	retq   

0000008041600694 <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  8041600694:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600699:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  804160069a:	a8 01                	test   $0x1,%al
  804160069c:	74 0a                	je     80416006a8 <serial_proc_data+0x14>
  804160069e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  80416006a3:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  80416006a4:	0f b6 c0             	movzbl %al,%eax
  80416006a7:	c3                   	retq   
    return -1;
  80416006a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  80416006ad:	c3                   	retq   

00000080416006ae <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  80416006ae:	55                   	push   %rbp
  80416006af:	48 89 e5             	mov    %rsp,%rbp
  80416006b2:	41 54                	push   %r12
  80416006b4:	53                   	push   %rbx
  80416006b5:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  80416006b8:	48 bb c0 43 70 41 80 	movabs $0x80417043c0,%rbx
  80416006bf:	00 00 00 
  while ((c = (*proc)()) != -1) {
  80416006c2:	41 ff d4             	callq  *%r12
  80416006c5:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416006c8:	74 28                	je     80416006f2 <cons_intr+0x44>
    if (c == 0)
  80416006ca:	85 c0                	test   %eax,%eax
  80416006cc:	74 f4                	je     80416006c2 <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  80416006ce:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  80416006d4:	8d 51 01             	lea    0x1(%rcx),%edx
  80416006d7:	89 c9                	mov    %ecx,%ecx
  80416006d9:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  80416006dc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  80416006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416006e7:	0f 44 d0             	cmove  %eax,%edx
  80416006ea:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  80416006f0:	eb d0                	jmp    80416006c2 <cons_intr+0x14>
  }
}
  80416006f2:	5b                   	pop    %rbx
  80416006f3:	41 5c                	pop    %r12
  80416006f5:	5d                   	pop    %rbp
  80416006f6:	c3                   	retq   

00000080416006f7 <kbd_proc_data>:
kbd_proc_data(void) {
  80416006f7:	55                   	push   %rbp
  80416006f8:	48 89 e5             	mov    %rsp,%rbp
  80416006fb:	53                   	push   %rbx
  80416006fc:	48 83 ec 08          	sub    $0x8,%rsp
  8041600700:	ba 64 00 00 00       	mov    $0x64,%edx
  8041600705:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  8041600706:	a8 01                	test   $0x1,%al
  8041600708:	0f 84 31 01 00 00    	je     804160083f <kbd_proc_data+0x148>
  804160070e:	ba 60 00 00 00       	mov    $0x60,%edx
  8041600713:	ec                   	in     (%dx),%al
  8041600714:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  8041600716:	3c e0                	cmp    $0xe0,%al
  8041600718:	0f 84 84 00 00 00    	je     80416007a2 <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  804160071e:	84 c0                	test   %al,%al
  8041600720:	0f 88 97 00 00 00    	js     80416007bd <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  8041600726:	48 bf a0 43 70 41 80 	movabs $0x80417043a0,%rdi
  804160072d:	00 00 00 
  8041600730:	8b 0f                	mov    (%rdi),%ecx
  8041600732:	f6 c1 40             	test   $0x40,%cl
  8041600735:	74 0c                	je     8041600743 <kbd_proc_data+0x4c>
    data |= 0x80;
  8041600737:	83 c8 80             	or     $0xffffff80,%eax
  804160073a:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  804160073c:	89 c8                	mov    %ecx,%eax
  804160073e:	83 e0 bf             	and    $0xffffffbf,%eax
  8041600741:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  8041600743:	0f b6 f2             	movzbl %dl,%esi
  8041600746:	48 b8 a0 c8 60 41 80 	movabs $0x804160c8a0,%rax
  804160074d:	00 00 00 
  8041600750:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  8041600754:	48 b9 a0 43 70 41 80 	movabs $0x80417043a0,%rcx
  804160075b:	00 00 00 
  804160075e:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  8041600760:	48 bf a0 c7 60 41 80 	movabs $0x804160c7a0,%rdi
  8041600767:	00 00 00 
  804160076a:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  804160076e:	31 f0                	xor    %esi,%eax
  8041600770:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  8041600772:	89 c6                	mov    %eax,%esi
  8041600774:	83 e6 03             	and    $0x3,%esi
  8041600777:	0f b6 d2             	movzbl %dl,%edx
  804160077a:	48 b9 80 c7 60 41 80 	movabs $0x804160c780,%rcx
  8041600781:	00 00 00 
  8041600784:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  8041600788:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  804160078c:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  804160078f:	a8 08                	test   $0x8,%al
  8041600791:	74 73                	je     8041600806 <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  8041600793:	89 da                	mov    %ebx,%edx
  8041600795:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  8041600798:	83 f9 19             	cmp    $0x19,%ecx
  804160079b:	77 5d                	ja     80416007fa <kbd_proc_data+0x103>
      c += 'A' - 'a';
  804160079d:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416007a0:	eb 12                	jmp    80416007b4 <kbd_proc_data+0xbd>
    shift |= E0ESC;
  80416007a2:	48 b8 a0 43 70 41 80 	movabs $0x80417043a0,%rax
  80416007a9:	00 00 00 
  80416007ac:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  80416007af:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  80416007b4:	89 d8                	mov    %ebx,%eax
  80416007b6:	48 83 c4 08          	add    $0x8,%rsp
  80416007ba:	5b                   	pop    %rbx
  80416007bb:	5d                   	pop    %rbp
  80416007bc:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  80416007bd:	48 bf a0 43 70 41 80 	movabs $0x80417043a0,%rdi
  80416007c4:	00 00 00 
  80416007c7:	8b 0f                	mov    (%rdi),%ecx
  80416007c9:	89 ce                	mov    %ecx,%esi
  80416007cb:	83 e6 40             	and    $0x40,%esi
  80416007ce:	83 e0 7f             	and    $0x7f,%eax
  80416007d1:	85 f6                	test   %esi,%esi
  80416007d3:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  80416007d6:	0f b6 d2             	movzbl %dl,%edx
  80416007d9:	48 b8 a0 c8 60 41 80 	movabs $0x804160c8a0,%rax
  80416007e0:	00 00 00 
  80416007e3:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  80416007e7:	83 c8 40             	or     $0x40,%eax
  80416007ea:	0f b6 c0             	movzbl %al,%eax
  80416007ed:	f7 d0                	not    %eax
  80416007ef:	21 c8                	and    %ecx,%eax
  80416007f1:	89 07                	mov    %eax,(%rdi)
    return 0;
  80416007f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416007f8:	eb ba                	jmp    80416007b4 <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  80416007fa:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416007fd:	8d 4b 20             	lea    0x20(%rbx),%ecx
  8041600800:	83 fa 1a             	cmp    $0x1a,%edx
  8041600803:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8041600806:	f7 d0                	not    %eax
  8041600808:	a8 06                	test   $0x6,%al
  804160080a:	75 a8                	jne    80416007b4 <kbd_proc_data+0xbd>
  804160080c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  8041600812:	75 a0                	jne    80416007b4 <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  8041600814:	48 bf 4a c7 60 41 80 	movabs $0x804160c74a,%rdi
  804160081b:	00 00 00 
  804160081e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600823:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160082a:	00 00 00 
  804160082d:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  804160082f:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600834:	ba 92 00 00 00       	mov    $0x92,%edx
  8041600839:	ee                   	out    %al,(%dx)
  804160083a:	e9 75 ff ff ff       	jmpq   80416007b4 <kbd_proc_data+0xbd>
    return -1;
  804160083f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8041600844:	e9 6b ff ff ff       	jmpq   80416007b4 <kbd_proc_data+0xbd>

0000008041600849 <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  8041600849:	48 b8 d4 45 70 41 80 	movabs $0x80417045d4,%rax
  8041600850:	00 00 00 
  8041600853:	44 8b 10             	mov    (%rax),%r10d
  8041600856:	41 0f af d2          	imul   %r10d,%edx
  804160085a:	01 f2                	add    %esi,%edx
  804160085c:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  8041600863:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  8041600864:	4d 0f be c0          	movsbq %r8b,%r8
  8041600868:	48 b8 20 f3 61 41 80 	movabs $0x804161f320,%rax
  804160086f:	00 00 00 
  8041600872:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  8041600876:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  804160087a:	eb 25                	jmp    80416008a1 <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  804160087c:	83 c0 01             	add    $0x1,%eax
  804160087f:	83 f8 08             	cmp    $0x8,%eax
  8041600882:	74 11                	je     8041600895 <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  8041600884:	0f be 16             	movsbl (%rsi),%edx
  8041600887:	0f a3 c2             	bt     %eax,%edx
  804160088a:	73 f0                	jae    804160087c <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160088c:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  8041600890:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  8041600893:	eb e7                	jmp    804160087c <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  8041600895:	45 01 d1             	add    %r10d,%r9d
  8041600898:	48 83 c6 01          	add    $0x1,%rsi
  804160089c:	4c 39 c6             	cmp    %r8,%rsi
  804160089f:	74 07                	je     80416008a8 <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  80416008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416008a6:	eb dc                	jmp    8041600884 <draw_char+0x3b>
}
  80416008a8:	c3                   	retq   

00000080416008a9 <cons_putc>:
  __asm __volatile("inb %w1,%0"
  80416008a9:	ba fd 03 00 00       	mov    $0x3fd,%edx
  80416008ae:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  80416008af:	a8 20                	test   $0x20,%al
  80416008b1:	75 29                	jne    80416008dc <cons_putc+0x33>
  for (i = 0;
  80416008b3:	be 00 00 00 00       	mov    $0x0,%esi
  80416008b8:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416008bd:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  80416008c3:	89 ca                	mov    %ecx,%edx
  80416008c5:	ec                   	in     (%dx),%al
  80416008c6:	ec                   	in     (%dx),%al
  80416008c7:	ec                   	in     (%dx),%al
  80416008c8:	ec                   	in     (%dx),%al
       i++)
  80416008c9:	83 c6 01             	add    $0x1,%esi
  80416008cc:	44 89 c2             	mov    %r8d,%edx
  80416008cf:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  80416008d0:	a8 20                	test   $0x20,%al
  80416008d2:	75 08                	jne    80416008dc <cons_putc+0x33>
  80416008d4:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416008da:	7e e7                	jle    80416008c3 <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  80416008dc:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  80416008df:	ba f8 03 00 00       	mov    $0x3f8,%edx
  80416008e4:	89 f8                	mov    %edi,%eax
  80416008e6:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416008e7:	ba 79 03 00 00       	mov    $0x379,%edx
  80416008ec:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  80416008ed:	84 c0                	test   %al,%al
  80416008ef:	78 29                	js     804160091a <cons_putc+0x71>
  80416008f1:	be 00 00 00 00       	mov    $0x0,%esi
  80416008f6:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416008fb:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  8041600901:	89 ca                	mov    %ecx,%edx
  8041600903:	ec                   	in     (%dx),%al
  8041600904:	ec                   	in     (%dx),%al
  8041600905:	ec                   	in     (%dx),%al
  8041600906:	ec                   	in     (%dx),%al
  8041600907:	83 c6 01             	add    $0x1,%esi
  804160090a:	44 89 ca             	mov    %r9d,%edx
  804160090d:	ec                   	in     (%dx),%al
  804160090e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  8041600914:	7f 04                	jg     804160091a <cons_putc+0x71>
  8041600916:	84 c0                	test   %al,%al
  8041600918:	79 e7                	jns    8041600901 <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  804160091a:	ba 78 03 00 00       	mov    $0x378,%edx
  804160091f:	44 89 c0             	mov    %r8d,%eax
  8041600922:	ee                   	out    %al,(%dx)
  8041600923:	ba 7a 03 00 00       	mov    $0x37a,%edx
  8041600928:	b8 0d 00 00 00       	mov    $0xd,%eax
  804160092d:	ee                   	out    %al,(%dx)
  804160092e:	b8 08 00 00 00       	mov    $0x8,%eax
  8041600933:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  8041600934:	48 b8 dc 45 70 41 80 	movabs $0x80417045dc,%rax
  804160093b:	00 00 00 
  804160093e:	80 38 00             	cmpb   $0x0,(%rax)
  8041600941:	0f 84 42 02 00 00    	je     8041600b89 <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  8041600947:	55                   	push   %rbp
  8041600948:	48 89 e5             	mov    %rsp,%rbp
  804160094b:	41 54                	push   %r12
  804160094d:	53                   	push   %rbx
  if (!(c & ~0xFF))
  804160094e:	89 fa                	mov    %edi,%edx
  8041600950:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  8041600956:	89 f8                	mov    %edi,%eax
  8041600958:	80 cc 07             	or     $0x7,%ah
  804160095b:	85 d2                	test   %edx,%edx
  804160095d:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  8041600960:	40 0f b6 c7          	movzbl %dil,%eax
  8041600964:	83 f8 09             	cmp    $0x9,%eax
  8041600967:	0f 84 e1 00 00 00    	je     8041600a4e <cons_putc+0x1a5>
  804160096d:	7e 5c                	jle    80416009cb <cons_putc+0x122>
  804160096f:	83 f8 0a             	cmp    $0xa,%eax
  8041600972:	0f 84 b8 00 00 00    	je     8041600a30 <cons_putc+0x187>
  8041600978:	83 f8 0d             	cmp    $0xd,%eax
  804160097b:	0f 85 ff 00 00 00    	jne    8041600a80 <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  8041600981:	48 be c8 45 70 41 80 	movabs $0x80417045c8,%rsi
  8041600988:	00 00 00 
  804160098b:	0f b7 0e             	movzwl (%rsi),%ecx
  804160098e:	0f b7 c1             	movzwl %cx,%eax
  8041600991:	48 bb d0 45 70 41 80 	movabs $0x80417045d0,%rbx
  8041600998:	00 00 00 
  804160099b:	ba 00 00 00 00       	mov    $0x0,%edx
  80416009a0:	f7 33                	divl   (%rbx)
  80416009a2:	29 d1                	sub    %edx,%ecx
  80416009a4:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  80416009a7:	48 b8 c8 45 70 41 80 	movabs $0x80417045c8,%rax
  80416009ae:	00 00 00 
  80416009b1:	0f b7 10             	movzwl (%rax),%edx
  80416009b4:	48 b8 cc 45 70 41 80 	movabs $0x80417045cc,%rax
  80416009bb:	00 00 00 
  80416009be:	3b 10                	cmp    (%rax),%edx
  80416009c0:	0f 83 0f 01 00 00    	jae    8041600ad5 <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  80416009c6:	5b                   	pop    %rbx
  80416009c7:	41 5c                	pop    %r12
  80416009c9:	5d                   	pop    %rbp
  80416009ca:	c3                   	retq   
  switch (c & 0xff) {
  80416009cb:	83 f8 08             	cmp    $0x8,%eax
  80416009ce:	0f 85 ac 00 00 00    	jne    8041600a80 <cons_putc+0x1d7>
      if (crt_pos > 0) {
  80416009d4:	66 a1 c8 45 70 41 80 	movabs 0x80417045c8,%ax
  80416009db:	00 00 00 
  80416009de:	66 85 c0             	test   %ax,%ax
  80416009e1:	74 c4                	je     80416009a7 <cons_putc+0xfe>
        crt_pos--;
  80416009e3:	83 e8 01             	sub    $0x1,%eax
  80416009e6:	66 a3 c8 45 70 41 80 	movabs %ax,0x80417045c8
  80416009ed:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  80416009f0:	0f b7 c0             	movzwl %ax,%eax
  80416009f3:	48 bb d0 45 70 41 80 	movabs $0x80417045d0,%rbx
  80416009fa:	00 00 00 
  80416009fd:	8b 1b                	mov    (%rbx),%ebx
  80416009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600a04:	f7 f3                	div    %ebx
  8041600a06:	89 d6                	mov    %edx,%esi
  8041600a08:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041600a0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600a13:	89 c2                	mov    %eax,%edx
  8041600a15:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600a1c:	00 00 00 
  8041600a1f:	48 b8 49 08 60 41 80 	movabs $0x8041600849,%rax
  8041600a26:	00 00 00 
  8041600a29:	ff d0                	callq  *%rax
  8041600a2b:	e9 77 ff ff ff       	jmpq   80416009a7 <cons_putc+0xfe>
      crt_pos += crt_cols;
  8041600a30:	48 b8 c8 45 70 41 80 	movabs $0x80417045c8,%rax
  8041600a37:	00 00 00 
  8041600a3a:	48 bb d0 45 70 41 80 	movabs $0x80417045d0,%rbx
  8041600a41:	00 00 00 
  8041600a44:	8b 13                	mov    (%rbx),%edx
  8041600a46:	66 01 10             	add    %dx,(%rax)
  8041600a49:	e9 33 ff ff ff       	jmpq   8041600981 <cons_putc+0xd8>
      cons_putc(' ');
  8041600a4e:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a53:	48 bb a9 08 60 41 80 	movabs $0x80416008a9,%rbx
  8041600a5a:	00 00 00 
  8041600a5d:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a5f:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a64:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a66:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a6b:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a6d:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a72:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600a74:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600a79:	ff d3                	callq  *%rbx
      break;
  8041600a7b:	e9 27 ff ff ff       	jmpq   80416009a7 <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600a80:	49 bc c8 45 70 41 80 	movabs $0x80417045c8,%r12
  8041600a87:	00 00 00 
  8041600a8a:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600a8f:	0f b7 c3             	movzwl %bx,%eax
  8041600a92:	48 be d0 45 70 41 80 	movabs $0x80417045d0,%rsi
  8041600a99:	00 00 00 
  8041600a9c:	8b 36                	mov    (%rsi),%esi
  8041600a9e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600aa3:	f7 f6                	div    %esi
  8041600aa5:	89 d6                	mov    %edx,%esi
  8041600aa7:	44 0f be c7          	movsbl %dil,%r8d
  8041600aab:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600ab0:	89 c2                	mov    %eax,%edx
  8041600ab2:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600ab9:	00 00 00 
  8041600abc:	48 b8 49 08 60 41 80 	movabs $0x8041600849,%rax
  8041600ac3:	00 00 00 
  8041600ac6:	ff d0                	callq  *%rax
      crt_pos++;
  8041600ac8:	83 c3 01             	add    $0x1,%ebx
  8041600acb:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  8041600ad0:	e9 d2 fe ff ff       	jmpq   80416009a7 <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600ad5:	48 bb d4 45 70 41 80 	movabs $0x80417045d4,%rbx
  8041600adc:	00 00 00 
  8041600adf:	8b 03                	mov    (%rbx),%eax
  8041600ae1:	49 bc d8 45 70 41 80 	movabs $0x80417045d8,%r12
  8041600ae8:	00 00 00 
  8041600aeb:	41 8b 3c 24          	mov    (%r12),%edi
  8041600aef:	8d 57 f8             	lea    -0x8(%rdi),%edx
  8041600af2:	0f af d0             	imul   %eax,%edx
  8041600af5:	48 c1 e2 02          	shl    $0x2,%rdx
  8041600af9:	c1 e0 03             	shl    $0x3,%eax
  8041600afc:	89 c0                	mov    %eax,%eax
  8041600afe:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600b05:	00 00 00 
  8041600b08:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  8041600b0c:	48 b8 8d be 60 41 80 	movabs $0x804160be8d,%rax
  8041600b13:	00 00 00 
  8041600b16:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600b18:	41 8b 04 24          	mov    (%r12),%eax
  8041600b1c:	8b 0b                	mov    (%rbx),%ecx
  8041600b1e:	89 c6                	mov    %eax,%esi
  8041600b20:	83 e6 f8             	and    $0xfffffff8,%esi
  8041600b23:	83 ee 08             	sub    $0x8,%esi
  8041600b26:	0f af f1             	imul   %ecx,%esi
  8041600b29:	0f af c8             	imul   %eax,%ecx
  8041600b2c:	39 f1                	cmp    %esi,%ecx
  8041600b2e:	76 3b                	jbe    8041600b6b <cons_putc+0x2c2>
  8041600b30:	48 63 fe             	movslq %esi,%rdi
  8041600b33:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  8041600b3a:	00 00 00 
  8041600b3d:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  8041600b41:	8d 51 ff             	lea    -0x1(%rcx),%edx
  8041600b44:	89 d1                	mov    %edx,%ecx
  8041600b46:	29 f1                	sub    %esi,%ecx
  8041600b48:	48 ba 01 b8 b0 0f 20 	movabs $0x200fb0b801,%rdx
  8041600b4f:	00 00 00 
  8041600b52:	48 01 fa             	add    %rdi,%rdx
  8041600b55:	48 01 ca             	add    %rcx,%rdx
  8041600b58:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600b5c:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600b62:	48 83 c0 04          	add    $0x4,%rax
  8041600b66:	48 39 c2             	cmp    %rax,%rdx
  8041600b69:	75 f1                	jne    8041600b5c <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600b6b:	48 b8 c8 45 70 41 80 	movabs $0x80417045c8,%rax
  8041600b72:	00 00 00 
  8041600b75:	48 bb d0 45 70 41 80 	movabs $0x80417045d0,%rbx
  8041600b7c:	00 00 00 
  8041600b7f:	8b 13                	mov    (%rbx),%edx
  8041600b81:	66 29 10             	sub    %dx,(%rax)
}
  8041600b84:	e9 3d fe ff ff       	jmpq   80416009c6 <cons_putc+0x11d>
  8041600b89:	c3                   	retq   

0000008041600b8a <serial_intr>:
  if (serial_exists)
  8041600b8a:	48 b8 ca 45 70 41 80 	movabs $0x80417045ca,%rax
  8041600b91:	00 00 00 
  8041600b94:	80 38 00             	cmpb   $0x0,(%rax)
  8041600b97:	75 01                	jne    8041600b9a <serial_intr+0x10>
  8041600b99:	c3                   	retq   
serial_intr(void) {
  8041600b9a:	55                   	push   %rbp
  8041600b9b:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600b9e:	48 bf 94 06 60 41 80 	movabs $0x8041600694,%rdi
  8041600ba5:	00 00 00 
  8041600ba8:	48 b8 ae 06 60 41 80 	movabs $0x80416006ae,%rax
  8041600baf:	00 00 00 
  8041600bb2:	ff d0                	callq  *%rax
}
  8041600bb4:	5d                   	pop    %rbp
  8041600bb5:	c3                   	retq   

0000008041600bb6 <fb_init>:
fb_init(void) {
  8041600bb6:	55                   	push   %rbp
  8041600bb7:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600bba:	48 b8 00 f0 61 41 80 	movabs $0x804161f000,%rax
  8041600bc1:	00 00 00 
  8041600bc4:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600bc7:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600bca:	89 d0                	mov    %edx,%eax
  8041600bcc:	a3 d8 45 70 41 80 00 	movabs %eax,0x80417045d8
  8041600bd3:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600bd5:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600bd8:	a3 d4 45 70 41 80 00 	movabs %eax,0x80417045d4
  8041600bdf:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600be1:	c1 e8 03             	shr    $0x3,%eax
  8041600be4:	89 c6                	mov    %eax,%esi
  8041600be6:	a3 d0 45 70 41 80 00 	movabs %eax,0x80417045d0
  8041600bed:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600bef:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600bf2:	0f af d0             	imul   %eax,%edx
  8041600bf5:	89 d0                	mov    %edx,%eax
  8041600bf7:	a3 cc 45 70 41 80 00 	movabs %eax,0x80417045cc
  8041600bfe:	00 00 
  crt_pos           = crt_cols;
  8041600c00:	89 f0                	mov    %esi,%eax
  8041600c02:	66 a3 c8 45 70 41 80 	movabs %ax,0x80417045c8
  8041600c09:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600c0c:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600c0f:	be 00 00 00 00       	mov    $0x0,%esi
  8041600c14:	48 bf 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rdi
  8041600c1b:	00 00 00 
  8041600c1e:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041600c25:	00 00 00 
  8041600c28:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600c2a:	48 b8 dc 45 70 41 80 	movabs $0x80417045dc,%rax
  8041600c31:	00 00 00 
  8041600c34:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600c37:	5d                   	pop    %rbp
  8041600c38:	c3                   	retq   

0000008041600c39 <kbd_intr>:
kbd_intr(void) {
  8041600c39:	55                   	push   %rbp
  8041600c3a:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600c3d:	48 bf f7 06 60 41 80 	movabs $0x80416006f7,%rdi
  8041600c44:	00 00 00 
  8041600c47:	48 b8 ae 06 60 41 80 	movabs $0x80416006ae,%rax
  8041600c4e:	00 00 00 
  8041600c51:	ff d0                	callq  *%rax
}
  8041600c53:	5d                   	pop    %rbp
  8041600c54:	c3                   	retq   

0000008041600c55 <cons_getc>:
cons_getc(void) {
  8041600c55:	55                   	push   %rbp
  8041600c56:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600c59:	48 b8 8a 0b 60 41 80 	movabs $0x8041600b8a,%rax
  8041600c60:	00 00 00 
  8041600c63:	ff d0                	callq  *%rax
  kbd_intr();
  8041600c65:	48 b8 39 0c 60 41 80 	movabs $0x8041600c39,%rax
  8041600c6c:	00 00 00 
  8041600c6f:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600c71:	48 b9 c0 43 70 41 80 	movabs $0x80417043c0,%rcx
  8041600c78:	00 00 00 
  8041600c7b:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600c81:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600c86:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600c8c:	74 21                	je     8041600caf <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600c8e:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600c91:	48 b8 c0 43 70 41 80 	movabs $0x80417043c0,%rax
  8041600c98:	00 00 00 
  8041600c9b:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600ca1:	89 d2                	mov    %edx,%edx
  8041600ca3:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600ca7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600cad:	74 02                	je     8041600cb1 <cons_getc+0x5c>
}
  8041600caf:	5d                   	pop    %rbp
  8041600cb0:	c3                   	retq   
      cons.rpos = 0;
  8041600cb1:	48 be c0 45 70 41 80 	movabs $0x80417045c0,%rsi
  8041600cb8:	00 00 00 
  8041600cbb:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600cc1:	eb ec                	jmp    8041600caf <cons_getc+0x5a>

0000008041600cc3 <cons_init>:
  8041600cc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600cc8:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600ccd:	89 c8                	mov    %ecx,%eax
  8041600ccf:	89 fa                	mov    %edi,%edx
  8041600cd1:	ee                   	out    %al,(%dx)
  8041600cd2:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600cd8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600cdd:	44 89 ca             	mov    %r9d,%edx
  8041600ce0:	ee                   	out    %al,(%dx)
  8041600ce1:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600ce6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600ceb:	89 f2                	mov    %esi,%edx
  8041600ced:	ee                   	out    %al,(%dx)
  8041600cee:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600cf4:	89 c8                	mov    %ecx,%eax
  8041600cf6:	44 89 c2             	mov    %r8d,%edx
  8041600cf9:	ee                   	out    %al,(%dx)
  8041600cfa:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600cff:	44 89 ca             	mov    %r9d,%edx
  8041600d02:	ee                   	out    %al,(%dx)
  8041600d03:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600d08:	89 c8                	mov    %ecx,%eax
  8041600d0a:	ee                   	out    %al,(%dx)
  8041600d0b:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600d10:	44 89 c2             	mov    %r8d,%edx
  8041600d13:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600d14:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600d19:	ec                   	in     (%dx),%al
  8041600d1a:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600d1c:	3c ff                	cmp    $0xff,%al
  8041600d1e:	0f 95 c0             	setne  %al
  8041600d21:	a2 ca 45 70 41 80 00 	movabs %al,0x80417045ca
  8041600d28:	00 00 
  8041600d2a:	89 fa                	mov    %edi,%edx
  8041600d2c:	ec                   	in     (%dx),%al
  8041600d2d:	89 f2                	mov    %esi,%edx
  8041600d2f:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600d30:	80 f9 ff             	cmp    $0xff,%cl
  8041600d33:	74 01                	je     8041600d36 <cons_init+0x73>
  8041600d35:	c3                   	retq   
cons_init(void) {
  8041600d36:	55                   	push   %rbp
  8041600d37:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600d3a:	48 bf 56 c7 60 41 80 	movabs $0x804160c756,%rdi
  8041600d41:	00 00 00 
  8041600d44:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600d49:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041600d50:	00 00 00 
  8041600d53:	ff d2                	callq  *%rdx
}
  8041600d55:	5d                   	pop    %rbp
  8041600d56:	c3                   	retq   

0000008041600d57 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600d57:	55                   	push   %rbp
  8041600d58:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600d5b:	48 b8 a9 08 60 41 80 	movabs $0x80416008a9,%rax
  8041600d62:	00 00 00 
  8041600d65:	ff d0                	callq  *%rax
}
  8041600d67:	5d                   	pop    %rbp
  8041600d68:	c3                   	retq   

0000008041600d69 <getchar>:

int
getchar(void) {
  8041600d69:	55                   	push   %rbp
  8041600d6a:	48 89 e5             	mov    %rsp,%rbp
  8041600d6d:	53                   	push   %rbx
  8041600d6e:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600d72:	48 bb 55 0c 60 41 80 	movabs $0x8041600c55,%rbx
  8041600d79:	00 00 00 
  8041600d7c:	ff d3                	callq  *%rbx
  8041600d7e:	85 c0                	test   %eax,%eax
  8041600d80:	74 fa                	je     8041600d7c <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600d82:	48 83 c4 08          	add    $0x8,%rsp
  8041600d86:	5b                   	pop    %rbx
  8041600d87:	5d                   	pop    %rbp
  8041600d88:	c3                   	retq   

0000008041600d89 <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600d89:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600d8e:	c3                   	retq   

0000008041600d8f <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600d8f:	55                   	push   %rbp
  8041600d90:	48 89 e5             	mov    %rsp,%rbp
  8041600d93:	41 56                	push   %r14
  8041600d95:	41 55                	push   %r13
  8041600d97:	41 54                	push   %r12
  8041600d99:	53                   	push   %rbx
  8041600d9a:	48 83 ec 20          	sub    $0x20,%rsp
  8041600d9e:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600da2:	83 fe 20             	cmp    $0x20,%esi
  8041600da5:	0f 87 42 09 00 00    	ja     80416016ed <dwarf_read_abbrev_entry+0x95e>
  8041600dab:	44 89 c3             	mov    %r8d,%ebx
  8041600dae:	41 89 cd             	mov    %ecx,%r13d
  8041600db1:	49 89 d4             	mov    %rdx,%r12
  8041600db4:	89 f6                	mov    %esi,%esi
  8041600db6:	48 b8 58 ca 60 41 80 	movabs $0x804160ca58,%rax
  8041600dbd:	00 00 00 
  8041600dc0:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600dc3:	48 85 d2             	test   %rdx,%rdx
  8041600dc6:	74 6f                	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
  8041600dc8:	83 f9 07             	cmp    $0x7,%ecx
  8041600dcb:	76 6a                	jbe    8041600e37 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600dcd:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600dd2:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600dd6:	4c 89 e7             	mov    %r12,%rdi
  8041600dd9:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600de0:	00 00 00 
  8041600de3:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600de5:	eb 50                	jmp    8041600e37 <dwarf_read_abbrev_entry+0xa8>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB2 code
        
      unsigned length = get_unaligned(entry, uint16_t);
  8041600de7:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600dec:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600df0:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600df4:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600dfb:	00 00 00 
  8041600dfe:	ff d0                	callq  *%rax
  8041600e00:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(uint16_t);
  8041600e04:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600e08:	48 83 c0 02          	add    $0x2,%rax
  8041600e0c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600e10:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600e14:	89 5d d8             	mov    %ebx,-0x28(%rbp)
        .mem = entry,
        .len = length,
      };
      if (buf) {
  8041600e17:	4d 85 e4             	test   %r12,%r12
  8041600e1a:	74 18                	je     8041600e34 <dwarf_read_abbrev_entry+0xa5>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600e1c:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600e21:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e25:	4c 89 e7             	mov    %r12,%rdi
  8041600e28:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600e2f:	00 00 00 
  8041600e32:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(uint16_t) + length;
  8041600e34:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600e37:	89 d8                	mov    %ebx,%eax
  8041600e39:	48 83 c4 20          	add    $0x20,%rsp
  8041600e3d:	5b                   	pop    %rbx
  8041600e3e:	41 5c                	pop    %r12
  8041600e40:	41 5d                	pop    %r13
  8041600e42:	41 5e                	pop    %r14
  8041600e44:	5d                   	pop    %rbp
  8041600e45:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600e46:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600e4b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e4f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e53:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600e5a:	00 00 00 
  8041600e5d:	ff d0                	callq  *%rax
  8041600e5f:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600e62:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600e66:	48 83 c0 04          	add    $0x4,%rax
  8041600e6a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600e6e:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600e72:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600e75:	4d 85 e4             	test   %r12,%r12
  8041600e78:	74 18                	je     8041600e92 <dwarf_read_abbrev_entry+0x103>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600e7a:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600e7f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e83:	4c 89 e7             	mov    %r12,%rdi
  8041600e86:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600e8d:	00 00 00 
  8041600e90:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600e92:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600e95:	eb a0                	jmp    8041600e37 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600e97:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600e9c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ea0:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ea4:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600eab:	00 00 00 
  8041600eae:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600eb0:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600eb5:	4d 85 e4             	test   %r12,%r12
  8041600eb8:	74 06                	je     8041600ec0 <dwarf_read_abbrev_entry+0x131>
  8041600eba:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600ebe:	77 0a                	ja     8041600eca <dwarf_read_abbrev_entry+0x13b>
      bytes = sizeof(Dwarf_Half);
  8041600ec0:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600ec5:	e9 6d ff ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600eca:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600ecf:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600ed3:	4c 89 e7             	mov    %r12,%rdi
  8041600ed6:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600edd:	00 00 00 
  8041600ee0:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600ee2:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600ee7:	e9 4b ff ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600eec:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600ef1:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600ef5:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600ef9:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600f00:	00 00 00 
  8041600f03:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600f05:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600f0a:	4d 85 e4             	test   %r12,%r12
  8041600f0d:	74 06                	je     8041600f15 <dwarf_read_abbrev_entry+0x186>
  8041600f0f:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600f13:	77 0a                	ja     8041600f1f <dwarf_read_abbrev_entry+0x190>
      bytes = sizeof(uint32_t);
  8041600f15:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600f1a:	e9 18 ff ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  8041600f1f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600f24:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f28:	4c 89 e7             	mov    %r12,%rdi
  8041600f2b:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600f32:	00 00 00 
  8041600f35:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600f37:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600f3c:	e9 f6 fe ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600f41:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f46:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f4a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f4e:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600f55:	00 00 00 
  8041600f58:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600f5a:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600f5f:	4d 85 e4             	test   %r12,%r12
  8041600f62:	74 06                	je     8041600f6a <dwarf_read_abbrev_entry+0x1db>
  8041600f64:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600f68:	77 0a                	ja     8041600f74 <dwarf_read_abbrev_entry+0x1e5>
      bytes = sizeof(uint64_t);
  8041600f6a:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600f6f:	e9 c3 fe ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  8041600f74:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600f79:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f7d:	4c 89 e7             	mov    %r12,%rdi
  8041600f80:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600f87:	00 00 00 
  8041600f8a:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600f8c:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600f91:	e9 a1 fe ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      if (buf && bufsize >= sizeof(char *)) {
  8041600f96:	48 85 d2             	test   %rdx,%rdx
  8041600f99:	74 05                	je     8041600fa0 <dwarf_read_abbrev_entry+0x211>
  8041600f9b:	83 f9 07             	cmp    $0x7,%ecx
  8041600f9e:	77 18                	ja     8041600fb8 <dwarf_read_abbrev_entry+0x229>
      bytes = strlen(entry) + 1;
  8041600fa0:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600fa4:	48 b8 82 bc 60 41 80 	movabs $0x804160bc82,%rax
  8041600fab:	00 00 00 
  8041600fae:	ff d0                	callq  *%rax
  8041600fb0:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600fb3:	e9 7f fe ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &entry, sizeof(char *));
  8041600fb8:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600fbd:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600fc1:	4c 89 e7             	mov    %r12,%rdi
  8041600fc4:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041600fcb:	00 00 00 
  8041600fce:	ff d0                	callq  *%rax
  8041600fd0:	eb ce                	jmp    8041600fa0 <dwarf_read_abbrev_entry+0x211>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600fd2:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600fd6:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600fd9:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600fde:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600fe3:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600fe8:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600feb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600fef:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600ff2:	89 f0                	mov    %esi,%eax
  8041600ff4:	83 e0 7f             	and    $0x7f,%eax
  8041600ff7:	d3 e0                	shl    %cl,%eax
  8041600ff9:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600ffb:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600ffe:	40 84 f6             	test   %sil,%sil
  8041601001:	78 e5                	js     8041600fe8 <dwarf_read_abbrev_entry+0x259>
      break;
  }

  *ret = result;

  return count;
  8041601003:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041601006:	4d 01 e8             	add    %r13,%r8
  8041601009:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  804160100d:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041601011:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041601014:	4d 85 e4             	test   %r12,%r12
  8041601017:	74 18                	je     8041601031 <dwarf_read_abbrev_entry+0x2a2>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041601019:	ba 10 00 00 00       	mov    $0x10,%edx
  804160101e:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601022:	4c 89 e7             	mov    %r12,%rdi
  8041601025:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160102c:	00 00 00 
  804160102f:	ff d0                	callq  *%rax
      bytes = count + length;
  8041601031:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041601034:	e9 fe fd ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041601039:	ba 01 00 00 00       	mov    $0x1,%edx
  804160103e:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601042:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601046:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160104d:	00 00 00 
  8041601050:	ff d0                	callq  *%rax
  8041601052:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041601056:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160105a:	48 83 c0 01          	add    $0x1,%rax
  804160105e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041601062:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041601066:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041601069:	4d 85 e4             	test   %r12,%r12
  804160106c:	74 18                	je     8041601086 <dwarf_read_abbrev_entry+0x2f7>
        memcpy(buf, &slice, sizeof(struct Slice));
  804160106e:	ba 10 00 00 00       	mov    $0x10,%edx
  8041601073:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601077:	4c 89 e7             	mov    %r12,%rdi
  804160107a:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601081:	00 00 00 
  8041601084:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041601086:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041601089:	e9 a9 fd ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  804160108e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601093:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601097:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160109b:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416010a2:	00 00 00 
  80416010a5:	ff d0                	callq  *%rax
  80416010a7:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  80416010ab:	4d 85 e4             	test   %r12,%r12
  80416010ae:	0f 84 43 06 00 00    	je     80416016f7 <dwarf_read_abbrev_entry+0x968>
  80416010b4:	45 85 ed             	test   %r13d,%r13d
  80416010b7:	0f 84 3a 06 00 00    	je     80416016f7 <dwarf_read_abbrev_entry+0x968>
        put_unaligned(data, (Dwarf_Small *)buf);
  80416010bd:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  80416010c1:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  80416010c6:	e9 6c fd ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      bool data = get_unaligned(entry, Dwarf_Small);
  80416010cb:	ba 01 00 00 00       	mov    $0x1,%edx
  80416010d0:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416010d4:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416010d8:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416010df:	00 00 00 
  80416010e2:	ff d0                	callq  *%rax
  80416010e4:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  80416010e8:	4d 85 e4             	test   %r12,%r12
  80416010eb:	0f 84 10 06 00 00    	je     8041601701 <dwarf_read_abbrev_entry+0x972>
  80416010f1:	45 85 ed             	test   %r13d,%r13d
  80416010f4:	0f 84 07 06 00 00    	je     8041601701 <dwarf_read_abbrev_entry+0x972>
      bool data = get_unaligned(entry, Dwarf_Small);
  80416010fa:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  80416010fc:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  8041601101:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  8041601106:	e9 2c fd ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      int count = dwarf_read_leb128(entry, &data);
  804160110b:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  804160110f:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041601112:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601117:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160111c:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  8041601121:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601124:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  8041601128:	89 f0                	mov    %esi,%eax
  804160112a:	83 e0 7f             	and    $0x7f,%eax
  804160112d:	d3 e0                	shl    %cl,%eax
  804160112f:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601131:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041601134:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  8041601137:	40 84 f6             	test   %sil,%sil
  804160113a:	78 e5                	js     8041601121 <dwarf_read_abbrev_entry+0x392>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  804160113c:	83 f9 1f             	cmp    $0x1f,%ecx
  804160113f:	7f 0f                	jg     8041601150 <dwarf_read_abbrev_entry+0x3c1>
  8041601141:	40 f6 c6 40          	test   $0x40,%sil
  8041601145:	74 09                	je     8041601150 <dwarf_read_abbrev_entry+0x3c1>
    result |= (-1U << shift);
  8041601147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160114c:	d3 e0                	shl    %cl,%eax
  804160114e:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  8041601150:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601153:	49 01 c0             	add    %rax,%r8
  8041601156:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  804160115a:	4d 85 e4             	test   %r12,%r12
  804160115d:	0f 84 d4 fc ff ff    	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
  8041601163:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601167:	0f 86 ca fc ff ff    	jbe    8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (int *)buf);
  804160116d:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601170:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601175:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601179:	4c 89 e7             	mov    %r12,%rdi
  804160117c:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601183:	00 00 00 
  8041601186:	ff d0                	callq  *%rax
  8041601188:	e9 aa fc ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160118d:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601191:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601196:	4c 89 f6             	mov    %r14,%rsi
  8041601199:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160119d:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416011a4:	00 00 00 
  80416011a7:	ff d0                	callq  *%rax
  80416011a9:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  80416011ac:	89 c2                	mov    %eax,%edx
  count       = 4;
  80416011ae:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416011b3:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416011b6:	76 2a                	jbe    80416011e2 <dwarf_read_abbrev_entry+0x453>
    if (initial_len == DW_EXT_DWARF64) {
  80416011b8:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416011bb:	74 60                	je     804160121d <dwarf_read_abbrev_entry+0x48e>
      cprintf("Unknown DWARF extension\n");
  80416011bd:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  80416011c4:	00 00 00 
  80416011c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416011cc:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416011d3:	00 00 00 
  80416011d6:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416011d8:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416011dd:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416011e2:	48 63 c3             	movslq %ebx,%rax
  80416011e5:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416011e9:	4d 85 e4             	test   %r12,%r12
  80416011ec:	0f 84 45 fc ff ff    	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
  80416011f2:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011f6:	0f 86 3b fc ff ff    	jbe    8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416011fc:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601200:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601205:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601209:	4c 89 e7             	mov    %r12,%rdi
  804160120c:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601213:	00 00 00 
  8041601216:	ff d0                	callq  *%rax
  8041601218:	e9 1a fc ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160121d:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601221:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601226:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160122a:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601231:	00 00 00 
  8041601234:	ff d0                	callq  *%rax
  8041601236:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  804160123a:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160123f:	eb a1                	jmp    80416011e2 <dwarf_read_abbrev_entry+0x453>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601241:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601245:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601248:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160124d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601252:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601257:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160125a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160125e:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601261:	89 f0                	mov    %esi,%eax
  8041601263:	83 e0 7f             	and    $0x7f,%eax
  8041601266:	d3 e0                	shl    %cl,%eax
  8041601268:	09 c7                	or     %eax,%edi
    shift += 7;
  804160126a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160126d:	40 84 f6             	test   %sil,%sil
  8041601270:	78 e5                	js     8041601257 <dwarf_read_abbrev_entry+0x4c8>
  return count;
  8041601272:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601275:	49 01 c0             	add    %rax,%r8
  8041601278:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160127c:	4d 85 e4             	test   %r12,%r12
  804160127f:	0f 84 b2 fb ff ff    	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
  8041601285:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601289:	0f 86 a8 fb ff ff    	jbe    8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  804160128f:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601292:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601297:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160129b:	4c 89 e7             	mov    %r12,%rdi
  804160129e:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416012a5:	00 00 00 
  80416012a8:	ff d0                	callq  *%rax
  80416012aa:	e9 88 fb ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  80416012af:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416012b3:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012b8:	4c 89 f6             	mov    %r14,%rsi
  80416012bb:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012bf:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416012c6:	00 00 00 
  80416012c9:	ff d0                	callq  *%rax
  80416012cb:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  80416012ce:	89 c2                	mov    %eax,%edx
  count       = 4;
  80416012d0:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416012d5:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416012d8:	76 2a                	jbe    8041601304 <dwarf_read_abbrev_entry+0x575>
    if (initial_len == DW_EXT_DWARF64) {
  80416012da:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416012dd:	74 60                	je     804160133f <dwarf_read_abbrev_entry+0x5b0>
      cprintf("Unknown DWARF extension\n");
  80416012df:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  80416012e6:	00 00 00 
  80416012e9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416012ee:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416012f5:	00 00 00 
  80416012f8:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416012fa:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416012ff:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  8041601304:	48 63 c3             	movslq %ebx,%rax
  8041601307:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  804160130b:	4d 85 e4             	test   %r12,%r12
  804160130e:	0f 84 23 fb ff ff    	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
  8041601314:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601318:	0f 86 19 fb ff ff    	jbe    8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  804160131e:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8041601322:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601327:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160132b:	4c 89 e7             	mov    %r12,%rdi
  804160132e:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601335:	00 00 00 
  8041601338:	ff d0                	callq  *%rax
  804160133a:	e9 f8 fa ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160133f:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601343:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601348:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160134c:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601353:	00 00 00 
  8041601356:	ff d0                	callq  *%rax
  8041601358:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  804160135c:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601361:	eb a1                	jmp    8041601304 <dwarf_read_abbrev_entry+0x575>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601363:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601368:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160136c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601370:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601377:	00 00 00 
  804160137a:	ff d0                	callq  *%rax
  804160137c:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601380:	4d 85 e4             	test   %r12,%r12
  8041601383:	0f 84 82 03 00 00    	je     804160170b <dwarf_read_abbrev_entry+0x97c>
  8041601389:	45 85 ed             	test   %r13d,%r13d
  804160138c:	0f 84 79 03 00 00    	je     804160170b <dwarf_read_abbrev_entry+0x97c>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601392:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601396:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  804160139b:	e9 97 fa ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  80416013a0:	ba 02 00 00 00       	mov    $0x2,%edx
  80416013a5:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013a9:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416013ad:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416013b4:	00 00 00 
  80416013b7:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  80416013b9:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  80416013be:	4d 85 e4             	test   %r12,%r12
  80416013c1:	74 06                	je     80416013c9 <dwarf_read_abbrev_entry+0x63a>
  80416013c3:	41 83 fd 01          	cmp    $0x1,%r13d
  80416013c7:	77 0a                	ja     80416013d3 <dwarf_read_abbrev_entry+0x644>
      bytes = sizeof(Dwarf_Half);
  80416013c9:	bb 02 00 00 00       	mov    $0x2,%ebx
  80416013ce:	e9 64 fa ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (Dwarf_Half *)buf);
  80416013d3:	ba 02 00 00 00       	mov    $0x2,%edx
  80416013d8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013dc:	4c 89 e7             	mov    %r12,%rdi
  80416013df:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416013e6:	00 00 00 
  80416013e9:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  80416013eb:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  80416013f0:	e9 42 fa ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416013f5:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013fa:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416013fe:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601402:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601409:	00 00 00 
  804160140c:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  804160140e:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041601413:	4d 85 e4             	test   %r12,%r12
  8041601416:	74 06                	je     804160141e <dwarf_read_abbrev_entry+0x68f>
  8041601418:	41 83 fd 03          	cmp    $0x3,%r13d
  804160141c:	77 0a                	ja     8041601428 <dwarf_read_abbrev_entry+0x699>
      bytes = sizeof(uint32_t);
  804160141e:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041601423:	e9 0f fa ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint32_t *)buf);
  8041601428:	ba 04 00 00 00       	mov    $0x4,%edx
  804160142d:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601431:	4c 89 e7             	mov    %r12,%rdi
  8041601434:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160143b:	00 00 00 
  804160143e:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041601440:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041601445:	e9 ed f9 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  804160144a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160144f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601453:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601457:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160145e:	00 00 00 
  8041601461:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601463:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601468:	4d 85 e4             	test   %r12,%r12
  804160146b:	74 06                	je     8041601473 <dwarf_read_abbrev_entry+0x6e4>
  804160146d:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601471:	77 0a                	ja     804160147d <dwarf_read_abbrev_entry+0x6ee>
      bytes = sizeof(uint64_t);
  8041601473:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041601478:	e9 ba f9 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  804160147d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601482:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601486:	4c 89 e7             	mov    %r12,%rdi
  8041601489:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601490:	00 00 00 
  8041601493:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601495:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  804160149a:	e9 98 f9 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &data);
  804160149f:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  80416014a3:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  80416014a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  80416014ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014b0:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  80416014b5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416014b8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416014bc:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  80416014bf:	89 f0                	mov    %esi,%eax
  80416014c1:	83 e0 7f             	and    $0x7f,%eax
  80416014c4:	d3 e0                	shl    %cl,%eax
  80416014c6:	09 c7                	or     %eax,%edi
    shift += 7;
  80416014c8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416014cb:	40 84 f6             	test   %sil,%sil
  80416014ce:	78 e5                	js     80416014b5 <dwarf_read_abbrev_entry+0x726>
  return count;
  80416014d0:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  80416014d3:	49 01 c0             	add    %rax,%r8
  80416014d6:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  80416014da:	4d 85 e4             	test   %r12,%r12
  80416014dd:	0f 84 54 f9 ff ff    	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
  80416014e3:	41 83 fd 03          	cmp    $0x3,%r13d
  80416014e7:	0f 86 4a f9 ff ff    	jbe    8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (unsigned int *)buf);
  80416014ed:	89 7d d0             	mov    %edi,-0x30(%rbp)
  80416014f0:	ba 04 00 00 00       	mov    $0x4,%edx
  80416014f5:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416014f9:	4c 89 e7             	mov    %r12,%rdi
  80416014fc:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601503:	00 00 00 
  8041601506:	ff d0                	callq  *%rax
  8041601508:	e9 2a f9 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      int count         = dwarf_read_uleb128(entry, &form);
  804160150d:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041601511:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  8041601514:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  804160151a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160151f:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601524:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  8041601528:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160152c:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  8041601530:	44 89 c0             	mov    %r8d,%eax
  8041601533:	83 e0 7f             	and    $0x7f,%eax
  8041601536:	d3 e0                	shl    %cl,%eax
  8041601538:	09 c6                	or     %eax,%esi
    shift += 7;
  804160153a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160153d:	45 84 c0             	test   %r8b,%r8b
  8041601540:	78 e2                	js     8041601524 <dwarf_read_abbrev_entry+0x795>
  return count;
  8041601542:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  8041601545:	48 01 c7             	add    %rax,%rdi
  8041601548:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  804160154c:	41 89 d8             	mov    %ebx,%r8d
  804160154f:	44 89 e9             	mov    %r13d,%ecx
  8041601552:	4c 89 e2             	mov    %r12,%rdx
  8041601555:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  804160155c:	00 00 00 
  804160155f:	ff d0                	callq  *%rax
      bytes    = count + read;
  8041601561:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601565:	e9 cd f8 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      int count            = dwarf_entry_len(entry, &length);
  804160156a:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160156e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601573:	4c 89 f6             	mov    %r14,%rsi
  8041601576:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160157a:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601581:	00 00 00 
  8041601584:	ff d0                	callq  *%rax
  8041601586:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601589:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160158b:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601590:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601593:	76 2a                	jbe    80416015bf <dwarf_read_abbrev_entry+0x830>
    if (initial_len == DW_EXT_DWARF64) {
  8041601595:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601598:	74 60                	je     80416015fa <dwarf_read_abbrev_entry+0x86b>
      cprintf("Unknown DWARF extension\n");
  804160159a:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  80416015a1:	00 00 00 
  80416015a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416015a9:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416015b0:	00 00 00 
  80416015b3:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416015b5:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416015ba:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416015bf:	48 63 c3             	movslq %ebx,%rax
  80416015c2:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416015c6:	4d 85 e4             	test   %r12,%r12
  80416015c9:	0f 84 68 f8 ff ff    	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
  80416015cf:	41 83 fd 07          	cmp    $0x7,%r13d
  80416015d3:	0f 86 5e f8 ff ff    	jbe    8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(length, (unsigned long *)buf);
  80416015d9:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416015dd:	ba 08 00 00 00       	mov    $0x8,%edx
  80416015e2:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416015e6:	4c 89 e7             	mov    %r12,%rdi
  80416015e9:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416015f0:	00 00 00 
  80416015f3:	ff d0                	callq  *%rax
  80416015f5:	e9 3d f8 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416015fa:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416015fe:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601603:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601607:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160160e:	00 00 00 
  8041601611:	ff d0                	callq  *%rax
  8041601613:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  8041601617:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160161c:	eb a1                	jmp    80416015bf <dwarf_read_abbrev_entry+0x830>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  804160161e:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601622:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041601625:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  804160162b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601630:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  8041601635:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601638:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160163c:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041601640:	89 f8                	mov    %edi,%eax
  8041601642:	83 e0 7f             	and    $0x7f,%eax
  8041601645:	d3 e0                	shl    %cl,%eax
  8041601647:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041601649:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160164c:	40 84 ff             	test   %dil,%dil
  804160164f:	78 e4                	js     8041601635 <dwarf_read_abbrev_entry+0x8a6>
  return count;
  8041601651:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  8041601654:	4c 01 f6             	add    %r14,%rsi
  8041601657:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  804160165b:	4d 85 e4             	test   %r12,%r12
  804160165e:	74 1a                	je     804160167a <dwarf_read_abbrev_entry+0x8eb>
        memcpy(buf, entry, MIN(length, bufsize));
  8041601660:	41 39 dd             	cmp    %ebx,%r13d
  8041601663:	44 89 ea             	mov    %r13d,%edx
  8041601666:	0f 47 d3             	cmova  %ebx,%edx
  8041601669:	89 d2                	mov    %edx,%edx
  804160166b:	4c 89 e7             	mov    %r12,%rdi
  804160166e:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601675:	00 00 00 
  8041601678:	ff d0                	callq  *%rax
      bytes = count + length;
  804160167a:	44 01 f3             	add    %r14d,%ebx
    } break;
  804160167d:	e9 b5 f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      bytes = 0;
  8041601682:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  8041601687:	48 85 d2             	test   %rdx,%rdx
  804160168a:	0f 84 a7 f7 ff ff    	je     8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(true, (bool *)buf);
  8041601690:	c6 02 01             	movb   $0x1,(%rdx)
  8041601693:	e9 9f f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601698:	ba 08 00 00 00       	mov    $0x8,%edx
  804160169d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416016a1:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416016a5:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416016ac:	00 00 00 
  80416016af:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  80416016b1:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  80416016b6:	4d 85 e4             	test   %r12,%r12
  80416016b9:	74 06                	je     80416016c1 <dwarf_read_abbrev_entry+0x932>
  80416016bb:	41 83 fd 07          	cmp    $0x7,%r13d
  80416016bf:	77 0a                	ja     80416016cb <dwarf_read_abbrev_entry+0x93c>
      bytes = sizeof(uint64_t);
  80416016c1:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  80416016c6:	e9 6c f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
        put_unaligned(data, (uint64_t *)buf);
  80416016cb:	ba 08 00 00 00       	mov    $0x8,%edx
  80416016d0:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416016d4:	4c 89 e7             	mov    %r12,%rdi
  80416016d7:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416016de:	00 00 00 
  80416016e1:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  80416016e3:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  80416016e8:	e9 4a f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
  int bytes = 0;
  80416016ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416016f2:	e9 40 f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  80416016f7:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416016fc:	e9 36 f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  8041601701:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041601706:	e9 2c f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>
      bytes = sizeof(Dwarf_Small);
  804160170b:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041601710:	e9 22 f7 ff ff       	jmpq   8041600e37 <dwarf_read_abbrev_entry+0xa8>

0000008041601715 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  8041601715:	55                   	push   %rbp
  8041601716:	48 89 e5             	mov    %rsp,%rbp
  8041601719:	41 57                	push   %r15
  804160171b:	41 56                	push   %r14
  804160171d:	41 55                	push   %r13
  804160171f:	41 54                	push   %r12
  8041601721:	53                   	push   %rbx
  8041601722:	48 83 ec 48          	sub    $0x48,%rsp
  8041601726:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  804160172a:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  804160172e:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  8041601732:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601736:	49 bd fb be 60 41 80 	movabs $0x804160befb,%r13
  804160173d:	00 00 00 
  8041601740:	e9 bb 01 00 00       	jmpq   8041601900 <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601745:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601749:	ba 08 00 00 00       	mov    $0x8,%edx
  804160174e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601752:	41 ff d5             	callq  *%r13
  8041601755:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  8041601759:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160175e:	eb 08                	jmp    8041601768 <info_by_address+0x53>
    *len = initial_len;
  8041601760:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  8041601763:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  8041601768:	4c 63 fb             	movslq %ebx,%r15
  804160176b:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  804160176f:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  8041601772:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601777:	48 89 de             	mov    %rbx,%rsi
  804160177a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160177e:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  8041601781:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  8041601785:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160178a:	75 7a                	jne    8041601806 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  804160178c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601791:	48 89 de             	mov    %rbx,%rsi
  8041601794:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601798:	41 ff d5             	callq  *%r13
  804160179b:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160179e:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  80416017a1:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  80416017a4:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  80416017a8:	ba 01 00 00 00       	mov    $0x1,%edx
  80416017ad:	48 89 de             	mov    %rbx,%rsi
  80416017b0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017b4:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  80416017b7:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416017bb:	75 7e                	jne    804160183b <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  80416017bd:	48 83 c3 02          	add    $0x2,%rbx
  80416017c1:	ba 01 00 00 00       	mov    $0x1,%edx
  80416017c6:	4c 89 fe             	mov    %r15,%rsi
  80416017c9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017cd:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  80416017d0:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  80416017d4:	0f 85 96 00 00 00    	jne    8041601870 <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  80416017da:	48 89 d8             	mov    %rbx,%rax
  80416017dd:	4c 29 f0             	sub    %r14,%rax
  80416017e0:	48 99                	cqto   
  80416017e2:	48 c1 ea 3c          	shr    $0x3c,%rdx
  80416017e6:	48 01 d0             	add    %rdx,%rax
  80416017e9:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  80416017ec:	48 29 d0             	sub    %rdx,%rax
  80416017ef:	0f 84 b5 00 00 00    	je     80416018aa <info_by_address+0x195>
      set += 2 * address_size - remainder;
  80416017f5:	ba 10 00 00 00       	mov    $0x10,%edx
  80416017fa:	89 d1                	mov    %edx,%ecx
  80416017fc:	29 c1                	sub    %eax,%ecx
  80416017fe:	48 01 cb             	add    %rcx,%rbx
  8041601801:	e9 a4 00 00 00       	jmpq   80416018aa <info_by_address+0x195>
    assert(version == 2);
  8041601806:	48 b9 1e ca 60 41 80 	movabs $0x804160ca1e,%rcx
  804160180d:	00 00 00 
  8041601810:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601817:	00 00 00 
  804160181a:	be 20 00 00 00       	mov    $0x20,%esi
  804160181f:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601826:	00 00 00 
  8041601829:	b8 00 00 00 00       	mov    $0x0,%eax
  804160182e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601835:	00 00 00 
  8041601838:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  804160183b:	48 b9 db c9 60 41 80 	movabs $0x804160c9db,%rcx
  8041601842:	00 00 00 
  8041601845:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160184c:	00 00 00 
  804160184f:	be 24 00 00 00       	mov    $0x24,%esi
  8041601854:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  804160185b:	00 00 00 
  804160185e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601863:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160186a:	00 00 00 
  804160186d:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  8041601870:	48 b9 ed c9 60 41 80 	movabs $0x804160c9ed,%rcx
  8041601877:	00 00 00 
  804160187a:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601881:	00 00 00 
  8041601884:	be 26 00 00 00       	mov    $0x26,%esi
  8041601889:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601890:	00 00 00 
  8041601893:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601898:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160189f:	00 00 00 
  80416018a2:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  80416018a5:	4c 39 e3             	cmp    %r12,%rbx
  80416018a8:	73 51                	jae    80416018fb <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  80416018aa:	ba 08 00 00 00       	mov    $0x8,%edx
  80416018af:	48 89 de             	mov    %rbx,%rsi
  80416018b2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018b6:	41 ff d5             	callq  *%r13
  80416018b9:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  80416018bd:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  80416018c1:	ba 04 00 00 00       	mov    $0x4,%edx
  80416018c6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018ca:	41 ff d5             	callq  *%r13
  80416018cd:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  80416018d0:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  80416018d4:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  80416018d8:	4c 39 f1             	cmp    %r14,%rcx
  80416018db:	72 c8                	jb     80416018a5 <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  80416018dd:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  80416018df:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  80416018e2:	48 39 c1             	cmp    %rax,%rcx
  80416018e5:	77 be                	ja     80416018a5 <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  80416018e7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416018eb:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  80416018ee:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  80416018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416018f6:	e9 5a 04 00 00       	jmpq   8041601d55 <info_by_address+0x640>
      set += address_size;
  80416018fb:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  80416018fe:	75 71                	jne    8041601971 <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  8041601900:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601904:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  8041601908:	73 42                	jae    804160194c <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  804160190a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160190f:	4c 89 f6             	mov    %r14,%rsi
  8041601912:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601916:	41 ff d5             	callq  *%r13
  8041601919:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160191d:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  8041601921:	0f 86 39 fe ff ff    	jbe    8041601760 <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  8041601927:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  804160192b:	0f 84 14 fe ff ff    	je     8041601745 <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  8041601931:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  8041601938:	00 00 00 
  804160193b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601940:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041601947:	00 00 00 
  804160194a:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  804160194c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601950:	48 8b 58 20          	mov    0x20(%rax),%rbx
  8041601954:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601958:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  804160195c:	0f 83 5b 04 00 00    	jae    8041601dbd <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  8041601962:	49 bf fb be 60 41 80 	movabs $0x804160befb,%r15
  8041601969:	00 00 00 
  804160196c:	e9 9f 03 00 00       	jmpq   8041601d10 <info_by_address+0x5fb>
    assert(set == set_end);
  8041601971:	48 b9 ff c9 60 41 80 	movabs $0x804160c9ff,%rcx
  8041601978:	00 00 00 
  804160197b:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601982:	00 00 00 
  8041601985:	be 3a 00 00 00       	mov    $0x3a,%esi
  804160198a:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601991:	00 00 00 
  8041601994:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601999:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416019a0:	00 00 00 
  80416019a3:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416019a6:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416019aa:	48 8d 70 20          	lea    0x20(%rax),%rsi
  80416019ae:	ba 08 00 00 00       	mov    $0x8,%edx
  80416019b3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019b7:	41 ff d7             	callq  *%r15
  80416019ba:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  80416019be:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  80416019c4:	eb 08                	jmp    80416019ce <info_by_address+0x2b9>
    *len = initial_len;
  80416019c6:	89 c0                	mov    %eax,%eax
  count       = 4;
  80416019c8:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  80416019ce:	4d 63 e4             	movslq %r12d,%r12
  80416019d1:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  80416019d5:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  80416019d9:	48 01 d8             	add    %rbx,%rax
  80416019dc:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416019e0:	ba 02 00 00 00       	mov    $0x2,%edx
  80416019e5:	48 89 de             	mov    %rbx,%rsi
  80416019e8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416019ec:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  80416019ef:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  80416019f3:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416019f7:	83 e8 02             	sub    $0x2,%eax
  80416019fa:	66 a9 fd ff          	test   $0xfffd,%ax
  80416019fe:	0f 85 07 01 00 00    	jne    8041601b0b <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601a04:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601a09:	48 89 de             	mov    %rbx,%rsi
  8041601a0c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601a10:	41 ff d7             	callq  *%r15
  8041601a13:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  8041601a17:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041601a1b:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  8041601a1f:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601a24:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601a28:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  8041601a2b:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601a2f:	0f 85 0b 01 00 00    	jne    8041601b40 <info_by_address+0x42b>
  8041601a35:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  8041601a38:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a42:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601a47:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601a4b:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601a4f:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a52:	44 89 c7             	mov    %r8d,%edi
  8041601a55:	83 e7 7f             	and    $0x7f,%edi
  8041601a58:	d3 e7                	shl    %cl,%edi
  8041601a5a:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601a5c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601a5f:	45 84 c0             	test   %r8b,%r8b
  8041601a62:	78 e3                	js     8041601a47 <info_by_address+0x332>
  return count;
  8041601a64:	48 98                	cltq   
    assert(abbrev_code != 0);
  8041601a66:	85 d2                	test   %edx,%edx
  8041601a68:	0f 84 07 01 00 00    	je     8041601b75 <info_by_address+0x460>
    entry += count;
  8041601a6e:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601a71:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601a75:	4c 03 28             	add    (%rax),%r13
  8041601a78:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  8041601a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601a80:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601a85:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601a8a:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041601a8e:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041601a92:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601a95:	45 89 c8             	mov    %r9d,%r8d
  8041601a98:	41 83 e0 7f          	and    $0x7f,%r8d
  8041601a9c:	41 d3 e0             	shl    %cl,%r8d
  8041601a9f:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  8041601aa2:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601aa5:	45 84 c9             	test   %r9b,%r9b
  8041601aa8:	78 e0                	js     8041601a8a <info_by_address+0x375>
  return count;
  8041601aaa:	48 98                	cltq   
    abbrev_entry += count;
  8041601aac:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  8041601aaf:	39 f2                	cmp    %esi,%edx
  8041601ab1:	0f 85 f3 00 00 00    	jne    8041601baa <info_by_address+0x495>
  8041601ab7:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  8041601aba:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601abf:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601ac4:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601ac9:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601acd:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601ad1:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601ad4:	44 89 c7             	mov    %r8d,%edi
  8041601ad7:	83 e7 7f             	and    $0x7f,%edi
  8041601ada:	d3 e7                	shl    %cl,%edi
  8041601adc:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601ade:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601ae1:	45 84 c0             	test   %r8b,%r8b
  8041601ae4:	78 e3                	js     8041601ac9 <info_by_address+0x3b4>
  return count;
  8041601ae6:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  8041601ae8:	83 fa 11             	cmp    $0x11,%edx
  8041601aeb:	0f 85 ee 00 00 00    	jne    8041601bdf <info_by_address+0x4ca>
    abbrev_entry++;
  8041601af1:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  8041601af6:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601afd:	00 
  8041601afe:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041601b05:	00 
  8041601b06:	e9 2f 01 00 00       	jmpq   8041601c3a <info_by_address+0x525>
    assert(version == 4 || version == 2);
  8041601b0b:	48 b9 0e ca 60 41 80 	movabs $0x804160ca0e,%rcx
  8041601b12:	00 00 00 
  8041601b15:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601b1c:	00 00 00 
  8041601b1f:	be 43 01 00 00       	mov    $0x143,%esi
  8041601b24:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601b2b:	00 00 00 
  8041601b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b33:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b3a:	00 00 00 
  8041601b3d:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601b40:	48 b9 db c9 60 41 80 	movabs $0x804160c9db,%rcx
  8041601b47:	00 00 00 
  8041601b4a:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601b51:	00 00 00 
  8041601b54:	be 47 01 00 00       	mov    $0x147,%esi
  8041601b59:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601b60:	00 00 00 
  8041601b63:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b68:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601b6f:	00 00 00 
  8041601b72:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601b75:	48 b9 2b ca 60 41 80 	movabs $0x804160ca2b,%rcx
  8041601b7c:	00 00 00 
  8041601b7f:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601b86:	00 00 00 
  8041601b89:	be 4c 01 00 00       	mov    $0x14c,%esi
  8041601b8e:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601b95:	00 00 00 
  8041601b98:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601b9d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ba4:	00 00 00 
  8041601ba7:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601baa:	48 b9 60 cb 60 41 80 	movabs $0x804160cb60,%rcx
  8041601bb1:	00 00 00 
  8041601bb4:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601bbb:	00 00 00 
  8041601bbe:	be 54 01 00 00       	mov    $0x154,%esi
  8041601bc3:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601bca:	00 00 00 
  8041601bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601bd2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601bd9:	00 00 00 
  8041601bdc:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601bdf:	48 b9 3c ca 60 41 80 	movabs $0x804160ca3c,%rcx
  8041601be6:	00 00 00 
  8041601be9:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601bf0:	00 00 00 
  8041601bf3:	be 58 01 00 00       	mov    $0x158,%esi
  8041601bf8:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601bff:	00 00 00 
  8041601c02:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c07:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601c0e:	00 00 00 
  8041601c11:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601c14:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c1a:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601c1f:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601c23:	44 89 f6             	mov    %r14d,%esi
  8041601c26:	4c 89 e7             	mov    %r12,%rdi
  8041601c29:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  8041601c30:	00 00 00 
  8041601c33:	ff d0                	callq  *%rax
      entry += count;
  8041601c35:	48 98                	cltq   
  8041601c37:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601c3a:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c47:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601c4d:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c50:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c54:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c57:	89 fe                	mov    %edi,%esi
  8041601c59:	83 e6 7f             	and    $0x7f,%esi
  8041601c5c:	d3 e6                	shl    %cl,%esi
  8041601c5e:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601c61:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c64:	40 84 ff             	test   %dil,%dil
  8041601c67:	78 e4                	js     8041601c4d <info_by_address+0x538>
  return count;
  8041601c69:	48 98                	cltq   
      abbrev_entry += count;
  8041601c6b:	48 01 c3             	add    %rax,%rbx
  8041601c6e:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601c71:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601c76:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601c7b:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601c81:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601c84:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601c88:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601c8b:	89 fe                	mov    %edi,%esi
  8041601c8d:	83 e6 7f             	and    $0x7f,%esi
  8041601c90:	d3 e6                	shl    %cl,%esi
  8041601c92:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601c95:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601c98:	40 84 ff             	test   %dil,%dil
  8041601c9b:	78 e4                	js     8041601c81 <info_by_address+0x56c>
  return count;
  8041601c9d:	48 98                	cltq   
      abbrev_entry += count;
  8041601c9f:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601ca2:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601ca6:	0f 84 68 ff ff ff    	je     8041601c14 <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601cac:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601cb0:	0f 84 ae 00 00 00    	je     8041601d64 <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601cb6:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601cbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601cc6:	44 89 f6             	mov    %r14d,%esi
  8041601cc9:	4c 89 e7             	mov    %r12,%rdi
  8041601ccc:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  8041601cd3:	00 00 00 
  8041601cd6:	ff d0                	callq  *%rax
      entry += count;
  8041601cd8:	48 98                	cltq   
  8041601cda:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601cdd:	45 09 f5             	or     %r14d,%r13d
  8041601ce0:	0f 85 54 ff ff ff    	jne    8041601c3a <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601ce6:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601cea:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601cee:	72 0a                	jb     8041601cfa <info_by_address+0x5e5>
  8041601cf0:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601cf4:	0f 86 a2 00 00 00    	jbe    8041601d9c <info_by_address+0x687>
    entry = entry_end;
  8041601cfa:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601cfe:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601d02:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601d06:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601d0a:	0f 83 a6 00 00 00    	jae    8041601db6 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601d10:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601d15:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601d19:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d1d:	41 ff d7             	callq  *%r15
  8041601d20:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601d23:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601d26:	0f 86 9a fc ff ff    	jbe    80416019c6 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601d2c:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601d2f:	0f 84 71 fc ff ff    	je     80416019a6 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601d35:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  8041601d3c:	00 00 00 
  8041601d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d44:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041601d4b:	00 00 00 
  8041601d4e:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601d50:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601d55:	48 83 c4 48          	add    $0x48,%rsp
  8041601d59:	5b                   	pop    %rbx
  8041601d5a:	41 5c                	pop    %r12
  8041601d5c:	41 5d                	pop    %r13
  8041601d5e:	41 5e                	pop    %r14
  8041601d60:	41 5f                	pop    %r15
  8041601d62:	5d                   	pop    %rbp
  8041601d63:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601d64:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601d6a:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601d6f:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601d73:	44 89 f6             	mov    %r14d,%esi
  8041601d76:	4c 89 e7             	mov    %r12,%rdi
  8041601d79:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  8041601d80:	00 00 00 
  8041601d83:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601d85:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601d89:	0f 84 a6 fe ff ff    	je     8041601c35 <info_by_address+0x520>
          high_pc += low_pc;
  8041601d8f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601d93:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601d97:	e9 99 fe ff ff       	jmpq   8041601c35 <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601d9c:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601da0:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601da4:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601da8:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601dac:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601daf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601db4:	eb 9f                	jmp    8041601d55 <info_by_address+0x640>
  return 0;
  8041601db6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dbb:	eb 98                	jmp    8041601d55 <info_by_address+0x640>
  8041601dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dc2:	eb 91                	jmp    8041601d55 <info_by_address+0x640>

0000008041601dc4 <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601dc4:	55                   	push   %rbp
  8041601dc5:	48 89 e5             	mov    %rsp,%rbp
  8041601dc8:	41 57                	push   %r15
  8041601dca:	41 56                	push   %r14
  8041601dcc:	41 55                	push   %r13
  8041601dce:	41 54                	push   %r12
  8041601dd0:	53                   	push   %rbx
  8041601dd1:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601dd5:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601dd9:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601ddd:	48 29 d8             	sub    %rbx,%rax
  8041601de0:	48 39 f0             	cmp    %rsi,%rax
  8041601de3:	0f 82 f5 02 00 00    	jb     80416020de <file_name_by_info+0x31a>
  8041601de9:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601ded:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601df0:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601df4:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601df8:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601dfb:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601e00:	48 89 de             	mov    %rbx,%rsi
  8041601e03:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601e07:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601e0e:	00 00 00 
  8041601e11:	ff d0                	callq  *%rax
  8041601e13:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601e16:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601e19:	0f 86 c9 02 00 00    	jbe    80416020e8 <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601e1f:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601e22:	74 25                	je     8041601e49 <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601e24:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  8041601e2b:	00 00 00 
  8041601e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e33:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041601e3a:	00 00 00 
  8041601e3d:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601e3f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601e44:	e9 00 02 00 00       	jmpq   8041602049 <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601e49:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601e4d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601e52:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601e56:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041601e5d:	00 00 00 
  8041601e60:	ff d0                	callq  *%rax
      count = 12;
  8041601e62:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601e68:	e9 81 02 00 00       	jmpq   80416020ee <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601e6d:	48 b9 0e ca 60 41 80 	movabs $0x804160ca0e,%rcx
  8041601e74:	00 00 00 
  8041601e77:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601e7e:	00 00 00 
  8041601e81:	be 9b 01 00 00       	mov    $0x19b,%esi
  8041601e86:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601e8d:	00 00 00 
  8041601e90:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e95:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601e9c:	00 00 00 
  8041601e9f:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601ea2:	48 b9 db c9 60 41 80 	movabs $0x804160c9db,%rcx
  8041601ea9:	00 00 00 
  8041601eac:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601eb3:	00 00 00 
  8041601eb6:	be 9f 01 00 00       	mov    $0x19f,%esi
  8041601ebb:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601ec2:	00 00 00 
  8041601ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601eca:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601ed1:	00 00 00 
  8041601ed4:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601ed7:	48 b9 2b ca 60 41 80 	movabs $0x804160ca2b,%rcx
  8041601ede:	00 00 00 
  8041601ee1:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601ee8:	00 00 00 
  8041601eeb:	be a4 01 00 00       	mov    $0x1a4,%esi
  8041601ef0:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601ef7:	00 00 00 
  8041601efa:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601eff:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601f06:	00 00 00 
  8041601f09:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601f0c:	48 b9 60 cb 60 41 80 	movabs $0x804160cb60,%rcx
  8041601f13:	00 00 00 
  8041601f16:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601f1d:	00 00 00 
  8041601f20:	be ac 01 00 00       	mov    $0x1ac,%esi
  8041601f25:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601f2c:	00 00 00 
  8041601f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f34:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601f3b:	00 00 00 
  8041601f3e:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601f41:	48 b9 3c ca 60 41 80 	movabs $0x804160ca3c,%rcx
  8041601f48:	00 00 00 
  8041601f4b:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041601f52:	00 00 00 
  8041601f55:	be b0 01 00 00       	mov    $0x1b0,%esi
  8041601f5a:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041601f61:	00 00 00 
  8041601f64:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601f69:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041601f70:	00 00 00 
  8041601f73:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601f76:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601f7a:	0f 84 d8 00 00 00    	je     8041602058 <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601f80:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f86:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601f89:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601f8d:	44 89 ee             	mov    %r13d,%esi
  8041601f90:	4c 89 f7             	mov    %r14,%rdi
  8041601f93:	41 ff d7             	callq  *%r15
  8041601f96:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601f99:	49 63 c4             	movslq %r12d,%rax
  8041601f9c:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601f9f:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601fa2:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601fa7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601fac:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601fb2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601fb5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601fb9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601fbc:	89 f0                	mov    %esi,%eax
  8041601fbe:	83 e0 7f             	and    $0x7f,%eax
  8041601fc1:	d3 e0                	shl    %cl,%eax
  8041601fc3:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601fc6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601fc9:	40 84 f6             	test   %sil,%sil
  8041601fcc:	78 e4                	js     8041601fb2 <file_name_by_info+0x1ee>
  return count;
  8041601fce:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601fd1:	48 01 fb             	add    %rdi,%rbx
  8041601fd4:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601fd7:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601fe1:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601fe7:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601fea:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601fee:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601ff1:	89 f0                	mov    %esi,%eax
  8041601ff3:	83 e0 7f             	and    $0x7f,%eax
  8041601ff6:	d3 e0                	shl    %cl,%eax
  8041601ff8:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601ffb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601ffe:	40 84 f6             	test   %sil,%sil
  8041602001:	78 e4                	js     8041601fe7 <file_name_by_info+0x223>
  return count;
  8041602003:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041602006:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041602009:	41 83 fc 03          	cmp    $0x3,%r12d
  804160200d:	0f 84 63 ff ff ff    	je     8041601f76 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041602013:	41 83 fc 10          	cmp    $0x10,%r12d
  8041602017:	0f 84 a1 00 00 00    	je     80416020be <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  804160201d:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602023:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602028:	ba 00 00 00 00       	mov    $0x0,%edx
  804160202d:	44 89 ee             	mov    %r13d,%esi
  8041602030:	4c 89 f7             	mov    %r14,%rdi
  8041602033:	41 ff d7             	callq  *%r15
    entry += count;
  8041602036:	48 98                	cltq   
  8041602038:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  804160203b:	45 09 e5             	or     %r12d,%r13d
  804160203e:	0f 85 5b ff ff ff    	jne    8041601f9f <file_name_by_info+0x1db>

  return 0;
  8041602044:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041602049:	48 83 c4 38          	add    $0x38,%rsp
  804160204d:	5b                   	pop    %rbx
  804160204e:	41 5c                	pop    %r12
  8041602050:	41 5d                	pop    %r13
  8041602052:	41 5e                	pop    %r14
  8041602054:	41 5f                	pop    %r15
  8041602056:	5d                   	pop    %rbp
  8041602057:	c3                   	retq   
        unsigned long offset = 0;
  8041602058:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160205f:	00 
        count                = dwarf_read_abbrev_entry(
  8041602060:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602066:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160206b:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160206f:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602074:	4c 89 f7             	mov    %r14,%rdi
  8041602077:	41 ff d7             	callq  *%r15
  804160207a:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  804160207d:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041602081:	48 85 ff             	test   %rdi,%rdi
  8041602084:	0f 84 0f ff ff ff    	je     8041601f99 <file_name_by_info+0x1d5>
  804160208a:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  804160208e:	0f 86 05 ff ff ff    	jbe    8041601f99 <file_name_by_info+0x1d5>
          put_unaligned(
  8041602094:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602098:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  804160209c:	48 03 41 40          	add    0x40(%rcx),%rax
  80416020a0:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  80416020a4:	ba 08 00 00 00       	mov    $0x8,%edx
  80416020a9:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  80416020ad:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416020b4:	00 00 00 
  80416020b7:	ff d0                	callq  *%rax
  80416020b9:	e9 db fe ff ff       	jmpq   8041601f99 <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  80416020be:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416020c4:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416020c9:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  80416020cd:	44 89 ee             	mov    %r13d,%esi
  80416020d0:	4c 89 f7             	mov    %r14,%rdi
  80416020d3:	41 ff d7             	callq  *%r15
  80416020d6:	41 89 c4             	mov    %eax,%r12d
  80416020d9:	e9 bb fe ff ff       	jmpq   8041601f99 <file_name_by_info+0x1d5>
    return -E_INVAL;
  80416020de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80416020e3:	e9 61 ff ff ff       	jmpq   8041602049 <file_name_by_info+0x285>
  count       = 4;
  80416020e8:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  80416020ee:	4d 63 ed             	movslq %r13d,%r13
  80416020f1:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416020f4:	ba 02 00 00 00       	mov    $0x2,%edx
  80416020f9:	48 89 de             	mov    %rbx,%rsi
  80416020fc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602100:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041602107:	00 00 00 
  804160210a:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  804160210c:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  8041602110:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602114:	83 e8 02             	sub    $0x2,%eax
  8041602117:	66 a9 fd ff          	test   $0xfffd,%ax
  804160211b:	0f 85 4c fd ff ff    	jne    8041601e6d <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602121:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602126:	48 89 de             	mov    %rbx,%rsi
  8041602129:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160212d:	49 bf fb be 60 41 80 	movabs $0x804160befb,%r15
  8041602134:	00 00 00 
  8041602137:	41 ff d7             	callq  *%r15
  804160213a:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  804160213e:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602142:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602146:	ba 01 00 00 00       	mov    $0x1,%edx
  804160214b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160214f:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  8041602152:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602156:	0f 85 46 fd ff ff    	jne    8041601ea2 <file_name_by_info+0xde>
  804160215c:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  804160215f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602164:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602169:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  804160216f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602172:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602176:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602179:	89 f0                	mov    %esi,%eax
  804160217b:	83 e0 7f             	and    $0x7f,%eax
  804160217e:	d3 e0                	shl    %cl,%eax
  8041602180:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602183:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602186:	40 84 f6             	test   %sil,%sil
  8041602189:	78 e4                	js     804160216f <file_name_by_info+0x3ab>
  return count;
  804160218b:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  804160218e:	45 85 c0             	test   %r8d,%r8d
  8041602191:	0f 84 40 fd ff ff    	je     8041601ed7 <file_name_by_info+0x113>
  entry += count;
  8041602197:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  804160219a:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  804160219e:	4c 03 20             	add    (%rax),%r12
  80416021a1:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  80416021a4:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416021a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416021ae:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  80416021b4:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416021b7:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416021bb:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416021be:	89 f0                	mov    %esi,%eax
  80416021c0:	83 e0 7f             	and    $0x7f,%eax
  80416021c3:	d3 e0                	shl    %cl,%eax
  80416021c5:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  80416021c8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416021cb:	40 84 f6             	test   %sil,%sil
  80416021ce:	78 e4                	js     80416021b4 <file_name_by_info+0x3f0>
  return count;
  80416021d0:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  80416021d3:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  80416021d6:	45 39 c8             	cmp    %r9d,%r8d
  80416021d9:	0f 85 2d fd ff ff    	jne    8041601f0c <file_name_by_info+0x148>
  80416021df:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  80416021e2:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416021e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416021ec:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416021f2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416021f5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416021f9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416021fc:	89 f0                	mov    %esi,%eax
  80416021fe:	83 e0 7f             	and    $0x7f,%eax
  8041602201:	d3 e0                	shl    %cl,%eax
  8041602203:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602206:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602209:	40 84 f6             	test   %sil,%sil
  804160220c:	78 e4                	js     80416021f2 <file_name_by_info+0x42e>
  return count;
  804160220e:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  8041602211:	41 83 f8 11          	cmp    $0x11,%r8d
  8041602215:	0f 85 26 fd ff ff    	jne    8041601f41 <file_name_by_info+0x17d>
  abbrev_entry++;
  804160221b:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041602220:	49 bf 8f 0d 60 41 80 	movabs $0x8041600d8f,%r15
  8041602227:	00 00 00 
  804160222a:	e9 70 fd ff ff       	jmpq   8041601f9f <file_name_by_info+0x1db>

000000804160222f <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  804160222f:	55                   	push   %rbp
  8041602230:	48 89 e5             	mov    %rsp,%rbp
  8041602233:	41 57                	push   %r15
  8041602235:	41 56                	push   %r14
  8041602237:	41 55                	push   %r13
  8041602239:	41 54                	push   %r12
  804160223b:	53                   	push   %rbx
  804160223c:	48 83 ec 68          	sub    $0x68,%rsp
  8041602240:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  8041602244:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  804160224b:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  804160224f:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  8041602253:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  804160225a:	48 89 d3             	mov    %rdx,%rbx
  804160225d:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602261:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602266:	48 89 de             	mov    %rbx,%rsi
  8041602269:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160226d:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041602274:	00 00 00 
  8041602277:	ff d0                	callq  *%rax
  8041602279:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160227c:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160227f:	76 59                	jbe    80416022da <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  8041602281:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602284:	74 2f                	je     80416022b5 <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602286:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  804160228d:	00 00 00 
  8041602290:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602295:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160229c:	00 00 00 
  804160229f:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416022a1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  80416022a6:	48 83 c4 68          	add    $0x68,%rsp
  80416022aa:	5b                   	pop    %rbx
  80416022ab:	41 5c                	pop    %r12
  80416022ad:	41 5d                	pop    %r13
  80416022af:	41 5e                	pop    %r14
  80416022b1:	41 5f                	pop    %r15
  80416022b3:	5d                   	pop    %rbp
  80416022b4:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416022b5:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  80416022b9:	ba 08 00 00 00       	mov    $0x8,%edx
  80416022be:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022c2:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416022c9:	00 00 00 
  80416022cc:	ff d0                	callq  *%rax
  80416022ce:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  80416022d2:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  80416022d8:	eb 08                	jmp    80416022e2 <function_by_info+0xb3>
    *len = initial_len;
  80416022da:	89 c0                	mov    %eax,%eax
  count       = 4;
  80416022dc:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  80416022e2:	4d 63 f6             	movslq %r14d,%r14
  80416022e5:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  80416022e8:	48 01 d8             	add    %rbx,%rax
  80416022eb:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416022ef:	ba 02 00 00 00       	mov    $0x2,%edx
  80416022f4:	48 89 de             	mov    %rbx,%rsi
  80416022f7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416022fb:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041602302:	00 00 00 
  8041602305:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  8041602307:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  804160230b:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  804160230f:	83 e8 02             	sub    $0x2,%eax
  8041602312:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602316:	75 51                	jne    8041602369 <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602318:	ba 04 00 00 00       	mov    $0x4,%edx
  804160231d:	48 89 de             	mov    %rbx,%rsi
  8041602320:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602324:	49 bc fb be 60 41 80 	movabs $0x804160befb,%r12
  804160232b:	00 00 00 
  804160232e:	41 ff d4             	callq  *%r12
  8041602331:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  8041602335:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602339:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  804160233d:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602342:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602346:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  8041602349:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160234d:	75 4f                	jne    804160239e <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  804160234f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602353:	4c 03 28             	add    (%rax),%r13
  8041602356:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  804160235a:	49 bf 8f 0d 60 41 80 	movabs $0x8041600d8f,%r15
  8041602361:	00 00 00 
  while (entry < entry_end) {
  8041602364:	e9 07 02 00 00       	jmpq   8041602570 <function_by_info+0x341>
  assert(version == 4 || version == 2);
  8041602369:	48 b9 0e ca 60 41 80 	movabs $0x804160ca0e,%rcx
  8041602370:	00 00 00 
  8041602373:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160237a:	00 00 00 
  804160237d:	be e9 01 00 00       	mov    $0x1e9,%esi
  8041602382:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041602389:	00 00 00 
  804160238c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602391:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602398:	00 00 00 
  804160239b:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  804160239e:	48 b9 db c9 60 41 80 	movabs $0x804160c9db,%rcx
  80416023a5:	00 00 00 
  80416023a8:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416023af:	00 00 00 
  80416023b2:	be ed 01 00 00       	mov    $0x1ed,%esi
  80416023b7:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  80416023be:	00 00 00 
  80416023c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416023c6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416023cd:	00 00 00 
  80416023d0:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  80416023d3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416023d7:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  80416023db:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  80416023df:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  80416023e5:	49 39 da             	cmp    %rbx,%r10
  80416023e8:	0f 86 e7 00 00 00    	jbe    80416024d5 <function_by_info+0x2a6>
  80416023ee:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023f1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416023f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023fc:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602401:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602404:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602408:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  804160240c:	89 f8                	mov    %edi,%eax
  804160240e:	83 e0 7f             	and    $0x7f,%eax
  8041602411:	d3 e0                	shl    %cl,%eax
  8041602413:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602415:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602418:	40 84 ff             	test   %dil,%dil
  804160241b:	78 e4                	js     8041602401 <function_by_info+0x1d2>
  return count;
  804160241d:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  8041602420:	4c 01 c3             	add    %r8,%rbx
  8041602423:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602426:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  804160242c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602431:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602437:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  804160243a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160243e:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  8041602442:	89 f8                	mov    %edi,%eax
  8041602444:	83 e0 7f             	and    $0x7f,%eax
  8041602447:	d3 e0                	shl    %cl,%eax
  8041602449:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  804160244c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160244f:	40 84 ff             	test   %dil,%dil
  8041602452:	78 e3                	js     8041602437 <function_by_info+0x208>
  return count;
  8041602454:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  8041602457:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  804160245c:	41 39 f1             	cmp    %esi,%r9d
  804160245f:	74 74                	je     80416024d5 <function_by_info+0x2a6>
  result = 0;
  8041602461:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602464:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602469:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160246e:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602474:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602477:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160247b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160247e:	89 f0                	mov    %esi,%eax
  8041602480:	83 e0 7f             	and    $0x7f,%eax
  8041602483:	d3 e0                	shl    %cl,%eax
  8041602485:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602488:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160248b:	40 84 f6             	test   %sil,%sil
  804160248e:	78 e4                	js     8041602474 <function_by_info+0x245>
  return count;
  8041602490:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602493:	48 01 fb             	add    %rdi,%rbx
  8041602496:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602499:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160249e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024a3:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024a9:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024ac:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024b0:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024b3:	89 f0                	mov    %esi,%eax
  80416024b5:	83 e0 7f             	and    $0x7f,%eax
  80416024b8:	d3 e0                	shl    %cl,%eax
  80416024ba:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024bd:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024c0:	40 84 f6             	test   %sil,%sil
  80416024c3:	78 e4                	js     80416024a9 <function_by_info+0x27a>
  return count;
  80416024c5:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024c8:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  80416024cb:	45 09 dc             	or     %r11d,%r12d
  80416024ce:	75 91                	jne    8041602461 <function_by_info+0x232>
  80416024d0:	e9 10 ff ff ff       	jmpq   80416023e5 <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  80416024d5:	41 83 f8 2e          	cmp    $0x2e,%r8d
  80416024d9:	0f 84 e9 00 00 00    	je     80416025c8 <function_by_info+0x399>
            fn_name_entry = entry;
  80416024df:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024e2:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024ec:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416024f2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024f5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024f9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024fc:	89 f0                	mov    %esi,%eax
  80416024fe:	83 e0 7f             	and    $0x7f,%eax
  8041602501:	d3 e0                	shl    %cl,%eax
  8041602503:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602506:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602509:	40 84 f6             	test   %sil,%sil
  804160250c:	78 e4                	js     80416024f2 <function_by_info+0x2c3>
  return count;
  804160250e:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602511:	48 01 fb             	add    %rdi,%rbx
  8041602514:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602517:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160251c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602521:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602527:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160252a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160252e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602531:	89 f0                	mov    %esi,%eax
  8041602533:	83 e0 7f             	and    $0x7f,%eax
  8041602536:	d3 e0                	shl    %cl,%eax
  8041602538:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160253b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160253e:	40 84 f6             	test   %sil,%sil
  8041602541:	78 e4                	js     8041602527 <function_by_info+0x2f8>
  return count;
  8041602543:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602546:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  8041602549:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160254f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602554:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602559:	44 89 e6             	mov    %r12d,%esi
  804160255c:	4c 89 f7             	mov    %r14,%rdi
  804160255f:	41 ff d7             	callq  *%r15
        entry += count;
  8041602562:	48 98                	cltq   
  8041602564:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602567:	45 09 ec             	or     %r13d,%r12d
  804160256a:	0f 85 6f ff ff ff    	jne    80416024df <function_by_info+0x2b0>
  while (entry < entry_end) {
  8041602570:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  8041602574:	0f 83 37 02 00 00    	jae    80416027b1 <function_by_info+0x582>
                 uintptr_t *offset) {
  804160257a:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  804160257d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602582:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602587:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160258d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602590:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602594:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602597:	89 f0                	mov    %esi,%eax
  8041602599:	83 e0 7f             	and    $0x7f,%eax
  804160259c:	d3 e0                	shl    %cl,%eax
  804160259e:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  80416025a1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416025a4:	40 84 f6             	test   %sil,%sil
  80416025a7:	78 e4                	js     804160258d <function_by_info+0x35e>
  return count;
  80416025a9:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  80416025ac:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  80416025af:	45 85 c9             	test   %r9d,%r9d
  80416025b2:	0f 85 1b fe ff ff    	jne    80416023d3 <function_by_info+0x1a4>
  while (entry < entry_end) {
  80416025b8:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  80416025bc:	77 bc                	ja     804160257a <function_by_info+0x34b>
  return 0;
  80416025be:	b8 00 00 00 00       	mov    $0x0,%eax
  80416025c3:	e9 de fc ff ff       	jmpq   80416022a6 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  80416025c8:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  80416025cf:	00 
  80416025d0:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  80416025d7:	00 
      unsigned name_form        = 0;
  80416025d8:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  80416025df:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80416025e6:	00 
  80416025e7:	eb 1d                	jmp    8041602606 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  80416025e9:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416025ef:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416025f4:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416025f8:	44 89 ee             	mov    %r13d,%esi
  80416025fb:	4c 89 f7             	mov    %r14,%rdi
  80416025fe:	41 ff d7             	callq  *%r15
        entry += count;
  8041602601:	48 98                	cltq   
  8041602603:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  8041602606:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602609:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160260e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602613:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602619:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160261c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602620:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602623:	89 f0                	mov    %esi,%eax
  8041602625:	83 e0 7f             	and    $0x7f,%eax
  8041602628:	d3 e0                	shl    %cl,%eax
  804160262a:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160262d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602630:	40 84 f6             	test   %sil,%sil
  8041602633:	78 e4                	js     8041602619 <function_by_info+0x3ea>
  return count;
  8041602635:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602638:	48 01 fb             	add    %rdi,%rbx
  804160263b:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160263e:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602643:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602648:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160264e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602651:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602655:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602658:	89 f0                	mov    %esi,%eax
  804160265a:	83 e0 7f             	and    $0x7f,%eax
  804160265d:	d3 e0                	shl    %cl,%eax
  804160265f:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602662:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602665:	40 84 f6             	test   %sil,%sil
  8041602668:	78 e4                	js     804160264e <function_by_info+0x41f>
  return count;
  804160266a:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160266d:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  8041602670:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602674:	0f 84 6f ff ff ff    	je     80416025e9 <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  804160267a:	41 83 fc 12          	cmp    $0x12,%r12d
  804160267e:	0f 84 99 00 00 00    	je     804160271d <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  8041602684:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602688:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  804160268b:	41 0f 44 c5          	cmove  %r13d,%eax
  804160268f:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  8041602692:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602696:	49 0f 44 c6          	cmove  %r14,%rax
  804160269a:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  804160269e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416026a9:	ba 00 00 00 00       	mov    $0x0,%edx
  80416026ae:	44 89 ee             	mov    %r13d,%esi
  80416026b1:	4c 89 f7             	mov    %r14,%rdi
  80416026b4:	41 ff d7             	callq  *%r15
        entry += count;
  80416026b7:	48 98                	cltq   
  80416026b9:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  80416026bc:	45 09 e5             	or     %r12d,%r13d
  80416026bf:	0f 85 41 ff ff ff    	jne    8041602606 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  80416026c5:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416026c9:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  80416026d0:	48 39 d8             	cmp    %rbx,%rax
  80416026d3:	0f 87 97 fe ff ff    	ja     8041602570 <function_by_info+0x341>
  80416026d9:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  80416026dd:	0f 82 8d fe ff ff    	jb     8041602570 <function_by_info+0x341>
        *offset = low_pc;
  80416026e3:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  80416026ea:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  80416026ed:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  80416026f1:	74 59                	je     804160274c <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  80416026f3:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416026f9:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  80416026fc:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  8041602700:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  8041602703:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602707:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  804160270e:	00 00 00 
  8041602711:	ff d0                	callq  *%rax
        return 0;
  8041602713:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602718:	e9 89 fb ff ff       	jmpq   80416022a6 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  804160271d:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602723:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602728:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  804160272c:	44 89 ee             	mov    %r13d,%esi
  804160272f:	4c 89 f7             	mov    %r14,%rdi
  8041602732:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  8041602735:	41 83 fd 01          	cmp    $0x1,%r13d
  8041602739:	0f 84 c2 fe ff ff    	je     8041602601 <function_by_info+0x3d2>
            high_pc += low_pc;
  804160273f:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041602743:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  8041602747:	e9 b5 fe ff ff       	jmpq   8041602601 <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  804160274c:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602753:	00 
          count                    = dwarf_read_abbrev_entry(
  8041602754:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160275a:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160275f:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602763:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602768:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  804160276c:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  8041602773:	00 00 00 
  8041602776:	ff d0                	callq  *%rax
          if (buf &&
  8041602778:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  804160277c:	48 85 ff             	test   %rdi,%rdi
  804160277f:	74 92                	je     8041602713 <function_by_info+0x4e4>
  8041602781:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  8041602785:	76 8c                	jbe    8041602713 <function_by_info+0x4e4>
            put_unaligned(
  8041602787:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160278b:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  804160278f:	48 03 43 40          	add    0x40(%rbx),%rax
  8041602793:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602797:	ba 08 00 00 00       	mov    $0x8,%edx
  804160279c:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  80416027a0:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416027a7:	00 00 00 
  80416027aa:	ff d0                	callq  *%rax
  80416027ac:	e9 62 ff ff ff       	jmpq   8041602713 <function_by_info+0x4e4>
  return 0;
  80416027b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416027b6:	e9 eb fa ff ff       	jmpq   80416022a6 <function_by_info+0x77>

00000080416027bb <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  80416027bb:	55                   	push   %rbp
  80416027bc:	48 89 e5             	mov    %rsp,%rbp
  80416027bf:	41 57                	push   %r15
  80416027c1:	41 56                	push   %r14
  80416027c3:	41 55                	push   %r13
  80416027c5:	41 54                	push   %r12
  80416027c7:	53                   	push   %rbx
  80416027c8:	48 83 ec 48          	sub    $0x48,%rsp
  80416027cc:	49 89 ff             	mov    %rdi,%r15
  80416027cf:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80416027d3:	48 89 f7             	mov    %rsi,%rdi
  80416027d6:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  80416027da:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const int flen = strlen(fname);
  80416027de:	48 b8 82 bc 60 41 80 	movabs $0x804160bc82,%rax
  80416027e5:	00 00 00 
  80416027e8:	ff d0                	callq  *%rax
  80416027ea:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  80416027ec:	85 c0                	test   %eax,%eax
  80416027ee:	74 62                	je     8041602852 <address_by_fname+0x97>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  80416027f0:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416027f4:	49 be fb be 60 41 80 	movabs $0x804160befb,%r14
  80416027fb:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  80416027fe:	49 bf 91 bd 60 41 80 	movabs $0x804160bd91,%r15
  8041602805:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  8041602808:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160280c:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  8041602810:	0f 86 0b 04 00 00    	jbe    8041602c21 <address_by_fname+0x466>
  8041602816:	ba 04 00 00 00       	mov    $0x4,%edx
  804160281b:	4c 89 e6             	mov    %r12,%rsi
  804160281e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602822:	41 ff d6             	callq  *%r14
  8041602825:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602828:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160282b:	76 52                	jbe    804160287f <address_by_fname+0xc4>
    if (initial_len == DW_EXT_DWARF64) {
  804160282d:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602830:	74 31                	je     8041602863 <address_by_fname+0xa8>
      cprintf("Unknown DWARF extension\n");
  8041602832:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  8041602839:	00 00 00 
  804160283c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602841:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041602848:	00 00 00 
  804160284b:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  804160284d:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  8041602852:	89 d8                	mov    %ebx,%eax
  8041602854:	48 83 c4 48          	add    $0x48,%rsp
  8041602858:	5b                   	pop    %rbx
  8041602859:	41 5c                	pop    %r12
  804160285b:	41 5d                	pop    %r13
  804160285d:	41 5e                	pop    %r14
  804160285f:	41 5f                	pop    %r15
  8041602861:	5d                   	pop    %rbp
  8041602862:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602863:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041602868:	ba 08 00 00 00       	mov    $0x8,%edx
  804160286d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602871:	41 ff d6             	callq  *%r14
  8041602874:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602878:	ba 0c 00 00 00       	mov    $0xc,%edx
  804160287d:	eb 07                	jmp    8041602886 <address_by_fname+0xcb>
    *len = initial_len;
  804160287f:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602881:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  8041602886:	48 63 d2             	movslq %edx,%rdx
  8041602889:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  804160288c:	4c 01 e0             	add    %r12,%rax
  804160288f:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  8041602893:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602898:	4c 89 e6             	mov    %r12,%rsi
  804160289b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160289f:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  80416028a2:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  80416028a7:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  80416028ac:	0f 85 be 00 00 00    	jne    8041602970 <address_by_fname+0x1b5>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  80416028b2:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028b7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028bb:	41 ff d6             	callq  *%r14
  80416028be:	8b 45 c8             	mov    -0x38(%rbp),%eax
  80416028c1:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  80416028c4:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  80416028c9:	ba 04 00 00 00       	mov    $0x4,%edx
  80416028ce:	48 89 de             	mov    %rbx,%rsi
  80416028d1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028d5:	41 ff d6             	callq  *%r14
  80416028d8:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  80416028db:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416028e0:	83 fa ef             	cmp    $0xffffffef,%edx
  80416028e3:	76 29                	jbe    804160290e <address_by_fname+0x153>
    if (initial_len == DW_EXT_DWARF64) {
  80416028e5:	83 fa ff             	cmp    $0xffffffff,%edx
  80416028e8:	0f 84 b7 00 00 00    	je     80416029a5 <address_by_fname+0x1ea>
      cprintf("Unknown DWARF extension\n");
  80416028ee:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  80416028f5:	00 00 00 
  80416028f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028fd:	48 b9 78 92 60 41 80 	movabs $0x8041609278,%rcx
  8041602904:	00 00 00 
  8041602907:	ff d1                	callq  *%rcx
      count = 0;
  8041602909:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  804160290e:	48 98                	cltq   
  8041602910:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602914:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041602918:	0f 86 ea fe ff ff    	jbe    8041602808 <address_by_fname+0x4d>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  804160291e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602923:	4c 89 e6             	mov    %r12,%rsi
  8041602926:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160292a:	41 ff d6             	callq  *%r14
  804160292d:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  8041602931:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  8041602935:	4d 85 ed             	test   %r13,%r13
  8041602938:	0f 84 ca fe ff ff    	je     8041602808 <address_by_fname+0x4d>
      if (!strcmp(fname, pubnames_entry)) {
  804160293e:	4c 89 e6             	mov    %r12,%rsi
  8041602941:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  8041602945:	41 ff d7             	callq  *%r15
  8041602948:	89 c3                	mov    %eax,%ebx
  804160294a:	85 c0                	test   %eax,%eax
  804160294c:	74 72                	je     80416029c0 <address_by_fname+0x205>
      pubnames_entry += strlen(pubnames_entry) + 1;
  804160294e:	4c 89 e7             	mov    %r12,%rdi
  8041602951:	48 b8 82 bc 60 41 80 	movabs $0x804160bc82,%rax
  8041602958:	00 00 00 
  804160295b:	ff d0                	callq  *%rax
  804160295d:	83 c0 01             	add    $0x1,%eax
  8041602960:	48 98                	cltq   
  8041602962:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602965:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041602969:	77 b3                	ja     804160291e <address_by_fname+0x163>
  804160296b:	e9 98 fe ff ff       	jmpq   8041602808 <address_by_fname+0x4d>
    assert(version == 2);
  8041602970:	48 b9 1e ca 60 41 80 	movabs $0x804160ca1e,%rcx
  8041602977:	00 00 00 
  804160297a:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041602981:	00 00 00 
  8041602984:	be 76 02 00 00       	mov    $0x276,%esi
  8041602989:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041602990:	00 00 00 
  8041602993:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602998:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160299f:	00 00 00 
  80416029a2:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416029a5:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  80416029aa:	ba 08 00 00 00       	mov    $0x8,%edx
  80416029af:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029b3:	41 ff d6             	callq  *%r14
      count = 12;
  80416029b6:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416029bb:	e9 4e ff ff ff       	jmpq   804160290e <address_by_fname+0x153>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  80416029c0:	44 8b 65 a4          	mov    -0x5c(%rbp),%r12d
        const void *entry      = addrs->info_begin + cu_offset;
  80416029c4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416029c8:	4c 03 60 20          	add    0x20(%rax),%r12
        const void *func_entry = entry + func_offset;
  80416029cc:	4f 8d 3c 2c          	lea    (%r12,%r13,1),%r15
  initial_len = get_unaligned(addr, uint32_t);
  80416029d0:	ba 04 00 00 00       	mov    $0x4,%edx
  80416029d5:	4c 89 e6             	mov    %r12,%rsi
  80416029d8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029dc:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416029e3:	00 00 00 
  80416029e6:	ff d0                	callq  *%rax
  80416029e8:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416029eb:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416029ee:	0f 86 37 02 00 00    	jbe    8041602c2b <address_by_fname+0x470>
    if (initial_len == DW_EXT_DWARF64) {
  80416029f4:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416029f7:	74 25                	je     8041602a1e <address_by_fname+0x263>
      cprintf("Unknown DWARF extension\n");
  80416029f9:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  8041602a00:	00 00 00 
  8041602a03:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a08:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041602a0f:	00 00 00 
  8041602a12:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  8041602a14:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  8041602a19:	e9 34 fe ff ff       	jmpq   8041602852 <address_by_fname+0x97>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602a1e:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041602a23:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602a28:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602a2c:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041602a33:	00 00 00 
  8041602a36:	ff d0                	callq  *%rax
      count = 12;
  8041602a38:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602a3d:	e9 ee 01 00 00       	jmpq   8041602c30 <address_by_fname+0x475>
        assert(version == 4 || version == 2);
  8041602a42:	48 b9 0e ca 60 41 80 	movabs $0x804160ca0e,%rcx
  8041602a49:	00 00 00 
  8041602a4c:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041602a53:	00 00 00 
  8041602a56:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041602a5b:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041602a62:	00 00 00 
  8041602a65:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a6a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602a71:	00 00 00 
  8041602a74:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602a77:	48 b9 db c9 60 41 80 	movabs $0x804160c9db,%rcx
  8041602a7e:	00 00 00 
  8041602a81:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041602a88:	00 00 00 
  8041602a8b:	be 91 02 00 00       	mov    $0x291,%esi
  8041602a90:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041602a97:	00 00 00 
  8041602a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602a9f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602aa6:	00 00 00 
  8041602aa9:	41 ff d0             	callq  *%r8
        if (tag == DW_TAG_subprogram) {
  8041602aac:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602ab0:	0f 84 93 00 00 00    	je     8041602b49 <address_by_fname+0x38e>
  count  = 0;
  8041602ab6:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602ab8:	89 d9                	mov    %ebx,%ecx
  8041602aba:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602abd:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602ac3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ac6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602aca:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602acd:	89 f0                	mov    %esi,%eax
  8041602acf:	83 e0 7f             	and    $0x7f,%eax
  8041602ad2:	d3 e0                	shl    %cl,%eax
  8041602ad4:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602ad7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ada:	40 84 f6             	test   %sil,%sil
  8041602add:	78 e4                	js     8041602ac3 <address_by_fname+0x308>
  return count;
  8041602adf:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602ae2:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602ae5:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602ae7:	89 d9                	mov    %ebx,%ecx
  8041602ae9:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602aec:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602af2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602af5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602af9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602afc:	89 f0                	mov    %esi,%eax
  8041602afe:	83 e0 7f             	and    $0x7f,%eax
  8041602b01:	d3 e0                	shl    %cl,%eax
  8041602b03:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602b06:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b09:	40 84 f6             	test   %sil,%sil
  8041602b0c:	78 e4                	js     8041602af2 <address_by_fname+0x337>
  return count;
  8041602b0e:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602b11:	49 01 fc             	add    %rdi,%r12
            count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602b14:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602b24:	44 89 ee             	mov    %r13d,%esi
  8041602b27:	4c 89 ff             	mov    %r15,%rdi
  8041602b2a:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  8041602b31:	00 00 00 
  8041602b34:	ff d0                	callq  *%rax
            entry += count;
  8041602b36:	48 98                	cltq   
  8041602b38:	49 01 c7             	add    %rax,%r15
          } while (name != 0 || form != 0);
  8041602b3b:	45 09 f5             	or     %r14d,%r13d
  8041602b3e:	0f 85 72 ff ff ff    	jne    8041602ab6 <address_by_fname+0x2fb>
  8041602b44:	e9 09 fd ff ff       	jmpq   8041602852 <address_by_fname+0x97>
          uintptr_t low_pc = 0;
  8041602b49:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602b50:	00 
  8041602b51:	eb 26                	jmp    8041602b79 <address_by_fname+0x3be>
              count = dwarf_read_abbrev_entry(entry, form, &low_pc, sizeof(low_pc), address_size);
  8041602b53:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602b59:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602b5e:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602b62:	44 89 f6             	mov    %r14d,%esi
  8041602b65:	4c 89 ff             	mov    %r15,%rdi
  8041602b68:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  8041602b6f:	00 00 00 
  8041602b72:	ff d0                	callq  *%rax
            entry += count;
  8041602b74:	48 98                	cltq   
  8041602b76:	49 01 c7             	add    %rax,%r15
  count  = 0;
  8041602b79:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602b7b:	89 d9                	mov    %ebx,%ecx
  8041602b7d:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602b80:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602b86:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602b89:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602b8d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602b90:	89 f0                	mov    %esi,%eax
  8041602b92:	83 e0 7f             	and    $0x7f,%eax
  8041602b95:	d3 e0                	shl    %cl,%eax
  8041602b97:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602b9a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602b9d:	40 84 f6             	test   %sil,%sil
  8041602ba0:	78 e4                	js     8041602b86 <address_by_fname+0x3cb>
  return count;
  8041602ba2:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602ba5:	49 01 fc             	add    %rdi,%r12
  count  = 0;
  8041602ba8:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602baa:	89 d9                	mov    %ebx,%ecx
  8041602bac:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602baf:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041602bb5:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602bb8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602bbc:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602bbf:	89 f0                	mov    %esi,%eax
  8041602bc1:	83 e0 7f             	and    $0x7f,%eax
  8041602bc4:	d3 e0                	shl    %cl,%eax
  8041602bc6:	41 09 c6             	or     %eax,%r14d
    shift += 7;
  8041602bc9:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602bcc:	40 84 f6             	test   %sil,%sil
  8041602bcf:	78 e4                	js     8041602bb5 <address_by_fname+0x3fa>
  return count;
  8041602bd1:	48 63 ff             	movslq %edi,%rdi
            abbrev_entry += count;
  8041602bd4:	49 01 fc             	add    %rdi,%r12
            if (name == DW_AT_low_pc) {
  8041602bd7:	41 83 fd 11          	cmp    $0x11,%r13d
  8041602bdb:	0f 84 72 ff ff ff    	je     8041602b53 <address_by_fname+0x398>
              count = dwarf_read_abbrev_entry(entry, form, NULL, 0, address_size);
  8041602be1:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602be7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602bec:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602bf1:	44 89 f6             	mov    %r14d,%esi
  8041602bf4:	4c 89 ff             	mov    %r15,%rdi
  8041602bf7:	48 b8 8f 0d 60 41 80 	movabs $0x8041600d8f,%rax
  8041602bfe:	00 00 00 
  8041602c01:	ff d0                	callq  *%rax
            entry += count;
  8041602c03:	48 98                	cltq   
  8041602c05:	49 01 c7             	add    %rax,%r15
          } while (name || form);
  8041602c08:	45 09 ee             	or     %r13d,%r14d
  8041602c0b:	0f 85 68 ff ff ff    	jne    8041602b79 <address_by_fname+0x3be>
          *offset = low_pc;
  8041602c11:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041602c15:	48 8b 7d 98          	mov    -0x68(%rbp),%rdi
  8041602c19:	48 89 07             	mov    %rax,(%rdi)
  8041602c1c:	e9 31 fc ff ff       	jmpq   8041602852 <address_by_fname+0x97>
  return 0;
  8041602c21:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602c26:	e9 27 fc ff ff       	jmpq   8041602852 <address_by_fname+0x97>
  count       = 4;
  8041602c2b:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  8041602c30:	48 98                	cltq   
  8041602c32:	4d 8d 2c 04          	lea    (%r12,%rax,1),%r13
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602c36:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602c3b:	4c 89 ee             	mov    %r13,%rsi
  8041602c3e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c42:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041602c49:	00 00 00 
  8041602c4c:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602c4e:	49 8d 75 02          	lea    0x2(%r13),%rsi
        assert(version == 4 || version == 2);
  8041602c52:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602c56:	83 e8 02             	sub    $0x2,%eax
  8041602c59:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602c5d:	0f 85 df fd ff ff    	jne    8041602a42 <address_by_fname+0x287>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602c63:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602c68:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c6c:	49 be fb be 60 41 80 	movabs $0x804160befb,%r14
  8041602c73:	00 00 00 
  8041602c76:	41 ff d6             	callq  *%r14
  8041602c79:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  8041602c7d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602c81:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  8041602c84:	49 8d 75 06          	lea    0x6(%r13),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602c88:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602c8d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602c91:	41 ff d6             	callq  *%r14
        assert(address_size == 8);
  8041602c94:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602c98:	0f 85 d9 fd ff ff    	jne    8041602a77 <address_by_fname+0x2bc>
  count  = 0;
  8041602c9e:	89 df                	mov    %ebx,%edi
  shift  = 0;
  8041602ca0:	89 d9                	mov    %ebx,%ecx
  8041602ca2:	4c 89 fa             	mov    %r15,%rdx
  result = 0;
  8041602ca5:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602cab:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602cae:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cb2:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602cb5:	89 f0                	mov    %esi,%eax
  8041602cb7:	83 e0 7f             	and    $0x7f,%eax
  8041602cba:	d3 e0                	shl    %cl,%eax
  8041602cbc:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602cbf:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cc2:	40 84 f6             	test   %sil,%sil
  8041602cc5:	78 e4                	js     8041602cab <address_by_fname+0x4f0>
  return count;
  8041602cc7:	48 63 ff             	movslq %edi,%rdi
        entry += count;
  8041602cca:	49 01 ff             	add    %rdi,%r15
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602ccd:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602cd1:	4c 8b 58 08          	mov    0x8(%rax),%r11
        unsigned name = 0, form = 0, tag = 0;
  8041602cd5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602cdb:	4d 39 e3             	cmp    %r12,%r11
  8041602cde:	0f 86 c8 fd ff ff    	jbe    8041602aac <address_by_fname+0x2f1>
  count  = 0;
  8041602ce4:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602ce7:	89 d9                	mov    %ebx,%ecx
  8041602ce9:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602cec:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602cf1:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602cf4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cf8:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602cfc:	89 f8                	mov    %edi,%eax
  8041602cfe:	83 e0 7f             	and    $0x7f,%eax
  8041602d01:	d3 e0                	shl    %cl,%eax
  8041602d03:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602d05:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d08:	40 84 ff             	test   %dil,%dil
  8041602d0b:	78 e4                	js     8041602cf1 <address_by_fname+0x536>
  return count;
  8041602d0d:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry += count;
  8041602d10:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602d13:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602d16:	89 d9                	mov    %ebx,%ecx
  8041602d18:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d1b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602d21:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602d24:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d28:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602d2c:	89 f8                	mov    %edi,%eax
  8041602d2e:	83 e0 7f             	and    $0x7f,%eax
  8041602d31:	d3 e0                	shl    %cl,%eax
  8041602d33:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602d36:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d39:	40 84 ff             	test   %dil,%dil
  8041602d3c:	78 e3                	js     8041602d21 <address_by_fname+0x566>
  return count;
  8041602d3e:	4d 63 c0             	movslq %r8d,%r8
          abbrev_entry++;
  8041602d41:	4f 8d 64 04 01       	lea    0x1(%r12,%r8,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602d46:	41 39 f2             	cmp    %esi,%r10d
  8041602d49:	0f 84 5d fd ff ff    	je     8041602aac <address_by_fname+0x2f1>
  count  = 0;
  8041602d4f:	41 89 d8             	mov    %ebx,%r8d
  shift  = 0;
  8041602d52:	89 d9                	mov    %ebx,%ecx
  8041602d54:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d57:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602d5c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d5f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d63:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602d67:	89 f0                	mov    %esi,%eax
  8041602d69:	83 e0 7f             	and    $0x7f,%eax
  8041602d6c:	d3 e0                	shl    %cl,%eax
  8041602d6e:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602d70:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d73:	40 84 f6             	test   %sil,%sil
  8041602d76:	78 e4                	js     8041602d5c <address_by_fname+0x5a1>
  return count;
  8041602d78:	4d 63 c0             	movslq %r8d,%r8
            abbrev_entry += count;
  8041602d7b:	4d 01 c4             	add    %r8,%r12
  count  = 0;
  8041602d7e:	41 89 dd             	mov    %ebx,%r13d
  shift  = 0;
  8041602d81:	89 d9                	mov    %ebx,%ecx
  8041602d83:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602d86:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602d8c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d8f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d93:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041602d97:	89 f0                	mov    %esi,%eax
  8041602d99:	83 e0 7f             	and    $0x7f,%eax
  8041602d9c:	d3 e0                	shl    %cl,%eax
  8041602d9e:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602da1:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602da4:	40 84 f6             	test   %sil,%sil
  8041602da7:	78 e3                	js     8041602d8c <address_by_fname+0x5d1>
  return count;
  8041602da9:	4d 63 ed             	movslq %r13d,%r13
            abbrev_entry += count;
  8041602dac:	4d 01 ec             	add    %r13,%r12
          } while (name != 0 || form != 0);
  8041602daf:	41 09 f8             	or     %edi,%r8d
  8041602db2:	75 9b                	jne    8041602d4f <address_by_fname+0x594>
  8041602db4:	e9 22 ff ff ff       	jmpq   8041602cdb <address_by_fname+0x520>

0000008041602db9 <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602db9:	55                   	push   %rbp
  8041602dba:	48 89 e5             	mov    %rsp,%rbp
  8041602dbd:	41 57                	push   %r15
  8041602dbf:	41 56                	push   %r14
  8041602dc1:	41 55                	push   %r13
  8041602dc3:	41 54                	push   %r12
  8041602dc5:	53                   	push   %rbx
  8041602dc6:	48 83 ec 48          	sub    $0x48,%rsp
  8041602dca:	48 89 fb             	mov    %rdi,%rbx
  8041602dcd:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602dd1:	48 89 f7             	mov    %rsi,%rdi
  8041602dd4:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602dd8:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602ddc:	48 b8 82 bc 60 41 80 	movabs $0x804160bc82,%rax
  8041602de3:	00 00 00 
  8041602de6:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602de8:	85 c0                	test   %eax,%eax
  8041602dea:	0f 84 73 03 00 00    	je     8041603163 <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602df0:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602df4:	e9 0f 03 00 00       	jmpq   8041603108 <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602df9:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602dfd:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602e02:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e06:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041602e0d:	00 00 00 
  8041602e10:	ff d0                	callq  *%rax
  8041602e12:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602e16:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602e1b:	eb 07                	jmp    8041602e24 <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602e1d:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602e1f:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602e24:	48 63 db             	movslq %ebx,%rbx
  8041602e27:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602e2b:	4c 01 e8             	add    %r13,%rax
  8041602e2e:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602e32:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602e37:	4c 89 ee             	mov    %r13,%rsi
  8041602e3a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e3e:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041602e45:	00 00 00 
  8041602e48:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602e4a:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602e4e:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602e52:	83 e8 02             	sub    $0x2,%eax
  8041602e55:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602e59:	75 52                	jne    8041602ead <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602e5b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602e60:	4c 89 ee             	mov    %r13,%rsi
  8041602e63:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e67:	49 be fb be 60 41 80 	movabs $0x804160befb,%r14
  8041602e6e:	00 00 00 
  8041602e71:	41 ff d6             	callq  *%r14
  8041602e74:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602e78:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602e7d:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602e81:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602e86:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e8a:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602e8d:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602e91:	75 4f                	jne    8041602ee2 <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602e93:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e97:	4c 03 20             	add    (%rax),%r12
  8041602e9a:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602e9e:	49 be 8f 0d 60 41 80 	movabs $0x8041600d8f,%r14
  8041602ea5:	00 00 00 
    while (entry < entry_end) {
  8041602ea8:	e9 11 02 00 00       	jmpq   80416030be <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602ead:	48 b9 0e ca 60 41 80 	movabs $0x804160ca0e,%rcx
  8041602eb4:	00 00 00 
  8041602eb7:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041602ebe:	00 00 00 
  8041602ec1:	be f1 02 00 00       	mov    $0x2f1,%esi
  8041602ec6:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041602ecd:	00 00 00 
  8041602ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602ed5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602edc:	00 00 00 
  8041602edf:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602ee2:	48 b9 db c9 60 41 80 	movabs $0x804160c9db,%rcx
  8041602ee9:	00 00 00 
  8041602eec:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041602ef3:	00 00 00 
  8041602ef6:	be f5 02 00 00       	mov    $0x2f5,%esi
  8041602efb:	48 bf ce c9 60 41 80 	movabs $0x804160c9ce,%rdi
  8041602f02:	00 00 00 
  8041602f05:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602f0a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041602f11:	00 00 00 
  8041602f14:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602f17:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602f1b:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602f1f:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602f23:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602f29:	49 39 db             	cmp    %rbx,%r11
  8041602f2c:	0f 86 e7 00 00 00    	jbe    8041603019 <naive_address_by_fname+0x260>
  8041602f32:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f35:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602f3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f40:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602f45:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f48:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f4c:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f50:	89 f8                	mov    %edi,%eax
  8041602f52:	83 e0 7f             	and    $0x7f,%eax
  8041602f55:	d3 e0                	shl    %cl,%eax
  8041602f57:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602f59:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f5c:	40 84 ff             	test   %dil,%dil
  8041602f5f:	78 e4                	js     8041602f45 <naive_address_by_fname+0x18c>
  return count;
  8041602f61:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602f64:	4c 01 c3             	add    %r8,%rbx
  8041602f67:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f6a:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602f70:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f75:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602f7b:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602f7e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f82:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602f86:	89 f8                	mov    %edi,%eax
  8041602f88:	83 e0 7f             	and    $0x7f,%eax
  8041602f8b:	d3 e0                	shl    %cl,%eax
  8041602f8d:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602f90:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f93:	40 84 ff             	test   %dil,%dil
  8041602f96:	78 e3                	js     8041602f7b <naive_address_by_fname+0x1c2>
  return count;
  8041602f98:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602f9b:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602fa0:	41 39 f2             	cmp    %esi,%r10d
  8041602fa3:	74 74                	je     8041603019 <naive_address_by_fname+0x260>
  result = 0;
  8041602fa5:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fa8:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fad:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fb2:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602fb8:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602fbb:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602fbf:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602fc2:	89 f0                	mov    %esi,%eax
  8041602fc4:	83 e0 7f             	and    $0x7f,%eax
  8041602fc7:	d3 e0                	shl    %cl,%eax
  8041602fc9:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602fcc:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602fcf:	40 84 f6             	test   %sil,%sil
  8041602fd2:	78 e4                	js     8041602fb8 <naive_address_by_fname+0x1ff>
  return count;
  8041602fd4:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602fd7:	48 01 fb             	add    %rdi,%rbx
  8041602fda:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602fdd:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602fe7:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602fed:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ff0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ff4:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602ff7:	89 f0                	mov    %esi,%eax
  8041602ff9:	83 e0 7f             	and    $0x7f,%eax
  8041602ffc:	d3 e0                	shl    %cl,%eax
  8041602ffe:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041603001:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603004:	40 84 f6             	test   %sil,%sil
  8041603007:	78 e4                	js     8041602fed <naive_address_by_fname+0x234>
  return count;
  8041603009:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  804160300c:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  804160300f:	45 09 c4             	or     %r8d,%r12d
  8041603012:	75 91                	jne    8041602fa5 <naive_address_by_fname+0x1ec>
  8041603014:	e9 10 ff ff ff       	jmpq   8041602f29 <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041603019:	41 83 f9 2e          	cmp    $0x2e,%r9d
  804160301d:	0f 84 4f 01 00 00    	je     8041603172 <naive_address_by_fname+0x3b9>
  8041603023:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041603027:	0f 84 45 01 00 00    	je     8041603172 <naive_address_by_fname+0x3b9>
                found = 1;
  804160302d:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603030:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041603035:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160303a:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041603040:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603043:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603047:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160304a:	89 f0                	mov    %esi,%eax
  804160304c:	83 e0 7f             	and    $0x7f,%eax
  804160304f:	d3 e0                	shl    %cl,%eax
  8041603051:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041603054:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603057:	40 84 f6             	test   %sil,%sil
  804160305a:	78 e4                	js     8041603040 <naive_address_by_fname+0x287>
  return count;
  804160305c:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  804160305f:	48 01 fb             	add    %rdi,%rbx
  8041603062:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041603065:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160306a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160306f:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041603075:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041603078:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160307c:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160307f:	89 f0                	mov    %esi,%eax
  8041603081:	83 e0 7f             	and    $0x7f,%eax
  8041603084:	d3 e0                	shl    %cl,%eax
  8041603086:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041603089:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160308c:	40 84 f6             	test   %sil,%sil
  804160308f:	78 e4                	js     8041603075 <naive_address_by_fname+0x2bc>
  return count;
  8041603091:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  8041603094:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041603097:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160309d:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416030a2:	ba 00 00 00 00       	mov    $0x0,%edx
  80416030a7:	44 89 e6             	mov    %r12d,%esi
  80416030aa:	4c 89 ff             	mov    %r15,%rdi
  80416030ad:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  80416030b0:	48 98                	cltq   
  80416030b2:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  80416030b5:	45 09 ec             	or     %r13d,%r12d
  80416030b8:	0f 85 6f ff ff ff    	jne    804160302d <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  80416030be:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  80416030c2:	73 44                	jae    8041603108 <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  80416030c4:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  80416030c7:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416030cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416030d1:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  80416030d7:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416030da:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416030de:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416030e1:	89 f0                	mov    %esi,%eax
  80416030e3:	83 e0 7f             	and    $0x7f,%eax
  80416030e6:	d3 e0                	shl    %cl,%eax
  80416030e8:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  80416030eb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416030ee:	40 84 f6             	test   %sil,%sil
  80416030f1:	78 e4                	js     80416030d7 <naive_address_by_fname+0x31e>
  return count;
  80416030f3:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  80416030f6:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  80416030f9:	45 85 d2             	test   %r10d,%r10d
  80416030fc:	0f 85 15 fe ff ff    	jne    8041602f17 <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  8041603102:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  8041603106:	77 bc                	ja     80416030c4 <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  8041603108:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160310c:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  8041603110:	0f 86 ee 01 00 00    	jbe    8041603304 <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  8041603116:	ba 04 00 00 00       	mov    $0x4,%edx
  804160311b:	4c 89 fe             	mov    %r15,%rsi
  804160311e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603122:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041603129:	00 00 00 
  804160312c:	ff d0                	callq  *%rax
  804160312e:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603131:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041603134:	0f 86 e3 fc ff ff    	jbe    8041602e1d <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  804160313a:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160313d:	0f 84 b6 fc ff ff    	je     8041602df9 <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  8041603143:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  804160314a:	00 00 00 
  804160314d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603152:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041603159:	00 00 00 
  804160315c:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  804160315e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  8041603163:	48 83 c4 48          	add    $0x48,%rsp
  8041603167:	5b                   	pop    %rbx
  8041603168:	41 5c                	pop    %r12
  804160316a:	41 5d                	pop    %r13
  804160316c:	41 5e                	pop    %r14
  804160316e:	41 5f                	pop    %r15
  8041603170:	5d                   	pop    %rbp
  8041603171:	c3                   	retq   
        uintptr_t low_pc = 0;
  8041603172:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041603179:	00 
        int found        = 0;
  804160317a:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041603181:	eb 21                	jmp    80416031a4 <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  8041603183:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603189:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160318e:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041603192:	44 89 ee             	mov    %r13d,%esi
  8041603195:	4c 89 ff             	mov    %r15,%rdi
  8041603198:	41 ff d6             	callq  *%r14
  804160319b:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  804160319e:	49 63 c4             	movslq %r12d,%rax
  80416031a1:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  80416031a4:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416031a7:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416031ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416031b1:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416031b7:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416031ba:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416031be:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416031c1:	89 f0                	mov    %esi,%eax
  80416031c3:	83 e0 7f             	and    $0x7f,%eax
  80416031c6:	d3 e0                	shl    %cl,%eax
  80416031c8:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416031cb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416031ce:	40 84 f6             	test   %sil,%sil
  80416031d1:	78 e4                	js     80416031b7 <naive_address_by_fname+0x3fe>
  return count;
  80416031d3:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  80416031d6:	48 01 fb             	add    %rdi,%rbx
  80416031d9:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416031dc:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416031e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416031e6:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416031ec:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416031ef:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416031f3:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416031f6:	89 f0                	mov    %esi,%eax
  80416031f8:	83 e0 7f             	and    $0x7f,%eax
  80416031fb:	d3 e0                	shl    %cl,%eax
  80416031fd:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041603200:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603203:	40 84 f6             	test   %sil,%sil
  8041603206:	78 e4                	js     80416031ec <naive_address_by_fname+0x433>
  return count;
  8041603208:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  804160320b:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  804160320e:	41 83 fc 11          	cmp    $0x11,%r12d
  8041603212:	0f 84 6b ff ff ff    	je     8041603183 <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  8041603218:	41 83 fc 03          	cmp    $0x3,%r12d
  804160321c:	0f 85 9c 00 00 00    	jne    80416032be <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  8041603222:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041603226:	74 42                	je     804160326a <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  8041603228:	4c 89 fe             	mov    %r15,%rsi
  804160322b:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  804160322f:	48 b8 91 bd 60 41 80 	movabs $0x804160bd91,%rax
  8041603236:	00 00 00 
  8041603239:	ff d0                	callq  *%rax
                found = 1;
  804160323b:	85 c0                	test   %eax,%eax
  804160323d:	b8 01 00 00 00       	mov    $0x1,%eax
  8041603242:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041603246:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  8041603249:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160324f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041603254:	ba 00 00 00 00       	mov    $0x0,%edx
  8041603259:	44 89 ee             	mov    %r13d,%esi
  804160325c:	4c 89 ff             	mov    %r15,%rdi
  804160325f:	41 ff d6             	callq  *%r14
  8041603262:	41 89 c4             	mov    %eax,%r12d
  8041603265:	e9 34 ff ff ff       	jmpq   804160319e <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  804160326a:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041603271:	00 
              count          = dwarf_read_abbrev_entry(
  8041603272:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041603278:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160327d:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041603281:	be 0e 00 00 00       	mov    $0xe,%esi
  8041603286:	4c 89 ff             	mov    %r15,%rdi
  8041603289:	41 ff d6             	callq  *%r14
  804160328c:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  804160328f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041603293:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603297:	48 03 70 40          	add    0x40(%rax),%rsi
  804160329b:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  804160329f:	48 b8 91 bd 60 41 80 	movabs $0x804160bd91,%rax
  80416032a6:	00 00 00 
  80416032a9:	ff d0                	callq  *%rax
                found = 1;
  80416032ab:	85 c0                	test   %eax,%eax
  80416032ad:	b8 01 00 00 00       	mov    $0x1,%eax
  80416032b2:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  80416032b6:	89 45 bc             	mov    %eax,-0x44(%rbp)
  80416032b9:	e9 e0 fe ff ff       	jmpq   804160319e <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  80416032be:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416032c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416032c9:	ba 00 00 00 00       	mov    $0x0,%edx
  80416032ce:	44 89 ee             	mov    %r13d,%esi
  80416032d1:	4c 89 ff             	mov    %r15,%rdi
  80416032d4:	41 ff d6             	callq  *%r14
          entry += count;
  80416032d7:	48 98                	cltq   
  80416032d9:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  80416032dc:	45 09 e5             	or     %r12d,%r13d
  80416032df:	0f 85 bf fe ff ff    	jne    80416031a4 <naive_address_by_fname+0x3eb>
        if (found) {
  80416032e5:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  80416032e9:	0f 84 cf fd ff ff    	je     80416030be <naive_address_by_fname+0x305>
          *offset = low_pc;
  80416032ef:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80416032f3:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  80416032f7:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  80416032fa:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032ff:	e9 5f fe ff ff       	jmpq   8041603163 <naive_address_by_fname+0x3aa>
  return 0;
  8041603304:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603309:	e9 55 fe ff ff       	jmpq   8041603163 <naive_address_by_fname+0x3aa>

000000804160330e <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  804160330e:	55                   	push   %rbp
  804160330f:	48 89 e5             	mov    %rsp,%rbp
  8041603312:	41 57                	push   %r15
  8041603314:	41 56                	push   %r14
  8041603316:	41 55                	push   %r13
  8041603318:	41 54                	push   %r12
  804160331a:	53                   	push   %rbx
  804160331b:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  804160331f:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  8041603323:	48 8b 47 38          	mov    0x38(%rdi),%rax
  8041603327:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  804160332a:	48 39 d0             	cmp    %rdx,%rax
  804160332d:	0f 82 d9 06 00 00    	jb     8041603a0c <line_for_address+0x6fe>
  8041603333:	48 85 c9             	test   %rcx,%rcx
  8041603336:	0f 84 d0 06 00 00    	je     8041603a0c <line_for_address+0x6fe>
  804160333c:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  8041603340:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  8041603344:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041603347:	ba 04 00 00 00       	mov    $0x4,%edx
  804160334c:	48 89 de             	mov    %rbx,%rsi
  804160334f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603353:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160335a:	00 00 00 
  804160335d:	ff d0                	callq  *%rax
  804160335f:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603362:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041603365:	76 4e                	jbe    80416033b5 <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  8041603367:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160336a:	74 25                	je     8041603391 <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  804160336c:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  8041603373:	00 00 00 
  8041603376:	b8 00 00 00 00       	mov    $0x0,%eax
  804160337b:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041603382:	00 00 00 
  8041603385:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041603387:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  804160338c:	e9 6c 06 00 00       	jmpq   80416039fd <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603391:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041603395:	ba 08 00 00 00       	mov    $0x8,%edx
  804160339a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160339e:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416033a5:	00 00 00 
  80416033a8:	ff d0                	callq  *%rax
  80416033aa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  80416033ae:	be 0c 00 00 00       	mov    $0xc,%esi
  80416033b3:	eb 07                	jmp    80416033bc <line_for_address+0xae>
    *len = initial_len;
  80416033b5:	89 c0                	mov    %eax,%eax
  count       = 4;
  80416033b7:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  80416033bc:	48 63 f6             	movslq %esi,%rsi
  80416033bf:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  80416033c2:	48 01 d8             	add    %rbx,%rax
  80416033c5:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  80416033c9:	ba 02 00 00 00       	mov    $0x2,%edx
  80416033ce:	48 89 de             	mov    %rbx,%rsi
  80416033d1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416033d5:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416033dc:	00 00 00 
  80416033df:	ff d0                	callq  *%rax
  80416033e1:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  80416033e6:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  80416033ea:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  80416033ee:	66 83 f8 02          	cmp    $0x2,%ax
  80416033f2:	77 51                	ja     8041603445 <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  80416033f4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416033f9:	4c 89 e6             	mov    %r12,%rsi
  80416033fc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603400:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  8041603407:	00 00 00 
  804160340a:	ff d0                	callq  *%rax
  804160340c:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603410:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  8041603414:	0f 86 84 00 00 00    	jbe    804160349e <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  804160341a:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  804160341e:	74 5a                	je     804160347a <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  8041603420:	48 bf a0 c9 60 41 80 	movabs $0x804160c9a0,%rdi
  8041603427:	00 00 00 
  804160342a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160342f:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041603436:	00 00 00 
  8041603439:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  804160343b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041603440:	e9 b8 05 00 00       	jmpq   80416039fd <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  8041603445:	48 b9 c8 cb 60 41 80 	movabs $0x804160cbc8,%rcx
  804160344c:	00 00 00 
  804160344f:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041603456:	00 00 00 
  8041603459:	be fc 00 00 00       	mov    $0xfc,%esi
  804160345e:	48 bf 81 cb 60 41 80 	movabs $0x804160cb81,%rdi
  8041603465:	00 00 00 
  8041603468:	b8 00 00 00 00       	mov    $0x0,%eax
  804160346d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603474:	00 00 00 
  8041603477:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160347a:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  804160347e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603483:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603487:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160348e:	00 00 00 
  8041603491:	ff d0                	callq  *%rax
  8041603493:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  8041603497:	b8 0c 00 00 00       	mov    $0xc,%eax
  804160349c:	eb 08                	jmp    80416034a6 <line_for_address+0x198>
    *len = initial_len;
  804160349e:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  80416034a1:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  80416034a6:	48 98                	cltq   
  80416034a8:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  80416034ab:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  80416034ae:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034b3:	4c 89 e6             	mov    %r12,%rsi
  80416034b6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034ba:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416034c1:	00 00 00 
  80416034c4:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  80416034c6:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416034ca:	0f 85 89 00 00 00    	jne    8041603559 <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  80416034d0:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  80416034d5:	66 41 83 ff 04       	cmp    $0x4,%r15w
  80416034da:	0f 84 ae 00 00 00    	je     804160358e <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  80416034e0:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  80416034e4:	ba 01 00 00 00       	mov    $0x1,%edx
  80416034e9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416034ed:	49 bc fb be 60 41 80 	movabs $0x804160befb,%r12
  80416034f4:	00 00 00 
  80416034f7:	41 ff d4             	callq  *%r12
  80416034fa:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  80416034fe:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  8041603501:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  8041603505:	ba 01 00 00 00       	mov    $0x1,%edx
  804160350a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160350e:	41 ff d4             	callq  *%r12
  8041603511:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041603515:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  8041603518:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  804160351c:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603521:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603525:	41 ff d4             	callq  *%r12
  8041603528:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  804160352c:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  804160352f:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  8041603533:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603538:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160353c:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  804160353f:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  8041603543:	0f 86 90 04 00 00    	jbe    80416039d9 <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  8041603549:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  804160354f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041603554:	e9 32 04 00 00       	jmpq   804160398b <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  8041603559:	48 b9 f8 cb 60 41 80 	movabs $0x804160cbf8,%rcx
  8041603560:	00 00 00 
  8041603563:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160356a:	00 00 00 
  804160356d:	be 07 01 00 00       	mov    $0x107,%esi
  8041603572:	48 bf 81 cb 60 41 80 	movabs $0x804160cb81,%rdi
  8041603579:	00 00 00 
  804160357c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603581:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603588:	00 00 00 
  804160358b:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  804160358e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603593:	48 89 de             	mov    %rbx,%rsi
  8041603596:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160359a:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416035a1:	00 00 00 
  80416035a4:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  80416035a6:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  80416035ab:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416035af:	0f 84 2b ff ff ff    	je     80416034e0 <line_for_address+0x1d2>
  80416035b5:	48 b9 18 cc 60 41 80 	movabs $0x804160cc18,%rcx
  80416035bc:	00 00 00 
  80416035bf:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416035c6:	00 00 00 
  80416035c9:	be 11 01 00 00       	mov    $0x111,%esi
  80416035ce:	48 bf 81 cb 60 41 80 	movabs $0x804160cb81,%rdi
  80416035d5:	00 00 00 
  80416035d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416035dd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416035e4:	00 00 00 
  80416035e7:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  80416035ea:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  80416035ed:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  80416035f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416035f8:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  80416035fe:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  8041603601:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603605:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041603609:	89 fa                	mov    %edi,%edx
  804160360b:	83 e2 7f             	and    $0x7f,%edx
  804160360e:	d3 e2                	shl    %cl,%edx
  8041603610:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  8041603613:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603616:	40 84 ff             	test   %dil,%dil
  8041603619:	78 e3                	js     80416035fe <line_for_address+0x2f0>
  return count;
  804160361b:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  804160361e:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  8041603621:	45 89 ff             	mov    %r15d,%r15d
  8041603624:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  8041603627:	ba 01 00 00 00       	mov    $0x1,%edx
  804160362c:	4c 89 ee             	mov    %r13,%rsi
  804160362f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603633:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160363a:	00 00 00 
  804160363d:	ff d0                	callq  *%rax
  804160363f:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  8041603643:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  8041603647:	3c 02                	cmp    $0x2,%al
  8041603649:	0f 84 dc 00 00 00    	je     804160372b <line_for_address+0x41d>
  804160364f:	76 39                	jbe    804160368a <line_for_address+0x37c>
  8041603651:	3c 03                	cmp    $0x3,%al
  8041603653:	74 62                	je     80416036b7 <line_for_address+0x3a9>
  8041603655:	3c 04                	cmp    $0x4,%al
  8041603657:	0f 85 0c 01 00 00    	jne    8041603769 <line_for_address+0x45b>
  804160365d:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603660:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603665:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603668:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160366c:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160366f:	84 c9                	test   %cl,%cl
  8041603671:	78 f2                	js     8041603665 <line_for_address+0x357>
  return count;
  8041603673:	48 98                	cltq   
          program_addr += count;
  8041603675:	48 01 c6             	add    %rax,%rsi
  8041603678:	44 89 e2             	mov    %r12d,%edx
  804160367b:	48 89 d8             	mov    %rbx,%rax
  804160367e:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603682:	4c 89 f3             	mov    %r14,%rbx
  8041603685:	e9 c8 00 00 00       	jmpq   8041603752 <line_for_address+0x444>
      switch (opcode) {
  804160368a:	3c 01                	cmp    $0x1,%al
  804160368c:	0f 85 d7 00 00 00    	jne    8041603769 <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  8041603692:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603696:	49 39 c6             	cmp    %rax,%r14
  8041603699:	0f 87 f8 00 00 00    	ja     8041603797 <line_for_address+0x489>
  804160369f:	48 39 d8             	cmp    %rbx,%rax
  80416036a2:	0f 82 39 03 00 00    	jb     80416039e1 <line_for_address+0x6d3>
          state->line          = 1;
  80416036a8:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  80416036ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80416036b2:	e9 9b 00 00 00       	jmpq   8041603752 <line_for_address+0x444>
          while (*(char *)program_addr) {
  80416036b7:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  80416036bc:	74 09                	je     80416036c7 <line_for_address+0x3b9>
            ++program_addr;
  80416036be:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  80416036c2:	80 3e 00             	cmpb   $0x0,(%rsi)
  80416036c5:	75 f7                	jne    80416036be <line_for_address+0x3b0>
          ++program_addr;
  80416036c7:	48 83 c6 01          	add    $0x1,%rsi
  80416036cb:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416036ce:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036d3:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036d6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036da:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036dd:	84 c9                	test   %cl,%cl
  80416036df:	78 f2                	js     80416036d3 <line_for_address+0x3c5>
  return count;
  80416036e1:	48 98                	cltq   
          program_addr += count;
  80416036e3:	48 01 c6             	add    %rax,%rsi
  80416036e6:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416036e9:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416036ee:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416036f1:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416036f5:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416036f8:	84 c9                	test   %cl,%cl
  80416036fa:	78 f2                	js     80416036ee <line_for_address+0x3e0>
  return count;
  80416036fc:	48 98                	cltq   
          program_addr += count;
  80416036fe:	48 01 c6             	add    %rax,%rsi
  8041603701:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603704:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603709:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160370c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603710:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603713:	84 c9                	test   %cl,%cl
  8041603715:	78 f2                	js     8041603709 <line_for_address+0x3fb>
  return count;
  8041603717:	48 98                	cltq   
          program_addr += count;
  8041603719:	48 01 c6             	add    %rax,%rsi
  804160371c:	44 89 e2             	mov    %r12d,%edx
  804160371f:	48 89 d8             	mov    %rbx,%rax
  8041603722:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603726:	4c 89 f3             	mov    %r14,%rbx
  8041603729:	eb 27                	jmp    8041603752 <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  804160372b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603730:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603734:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160373b:	00 00 00 
  804160373e:	ff d0                	callq  *%rax
  8041603740:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  8041603744:	49 8d 75 09          	lea    0x9(%r13),%rsi
  8041603748:	44 89 e2             	mov    %r12d,%edx
  804160374b:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160374f:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  8041603752:	49 39 f7             	cmp    %rsi,%r15
  8041603755:	75 4c                	jne    80416037a3 <line_for_address+0x495>
  8041603757:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160375b:	41 89 d4             	mov    %edx,%r12d
  804160375e:	49 89 de             	mov    %rbx,%r14
  8041603761:	48 89 c3             	mov    %rax,%rbx
  8041603764:	e9 19 02 00 00       	jmpq   8041603982 <line_for_address+0x674>
      switch (opcode) {
  8041603769:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  804160376c:	48 ba 94 cb 60 41 80 	movabs $0x804160cb94,%rdx
  8041603773:	00 00 00 
  8041603776:	be 6b 00 00 00       	mov    $0x6b,%esi
  804160377b:	48 bf 81 cb 60 41 80 	movabs $0x804160cb81,%rdi
  8041603782:	00 00 00 
  8041603785:	b8 00 00 00 00       	mov    $0x0,%eax
  804160378a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041603791:	00 00 00 
  8041603794:	41 ff d0             	callq  *%r8
          state->line          = 1;
  8041603797:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  804160379c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037a1:	eb af                	jmp    8041603752 <line_for_address+0x444>
      assert(program_addr == opcode_end);
  80416037a3:	48 b9 a7 cb 60 41 80 	movabs $0x804160cba7,%rcx
  80416037aa:	00 00 00 
  80416037ad:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416037b4:	00 00 00 
  80416037b7:	be 6e 00 00 00       	mov    $0x6e,%esi
  80416037bc:	48 bf 81 cb 60 41 80 	movabs $0x804160cb81,%rdi
  80416037c3:	00 00 00 
  80416037c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037cb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416037d2:	00 00 00 
  80416037d5:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  80416037d8:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416037dc:	49 39 c6             	cmp    %rax,%r14
  80416037df:	0f 87 eb 01 00 00    	ja     80416039d0 <line_for_address+0x6c2>
  80416037e5:	48 39 d8             	cmp    %rbx,%rax
  80416037e8:	0f 82 f9 01 00 00    	jb     80416039e7 <line_for_address+0x6d9>
          last_state           = *state;
  80416037ee:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416037f2:	49 89 de             	mov    %rbx,%r14
  80416037f5:	e9 88 01 00 00       	jmpq   8041603982 <line_for_address+0x674>
      switch (opcode) {
  80416037fa:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  80416037fd:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041603802:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603807:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  804160380c:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041603810:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041603814:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041603817:	45 89 c8             	mov    %r9d,%r8d
  804160381a:	41 83 e0 7f          	and    $0x7f,%r8d
  804160381e:	41 d3 e0             	shl    %cl,%r8d
  8041603821:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  8041603824:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603827:	45 84 c9             	test   %r9b,%r9b
  804160382a:	78 e0                	js     804160380c <line_for_address+0x4fe>
              info->minimum_instruction_length *
  804160382c:	89 d2                	mov    %edx,%edx
          state->address +=
  804160382e:	48 01 d3             	add    %rdx,%rbx
  return count;
  8041603831:	48 98                	cltq   
          program_addr += count;
  8041603833:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603836:	e9 47 01 00 00       	jmpq   8041603982 <line_for_address+0x674>
      switch (opcode) {
  804160383b:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  804160383e:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041603843:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603848:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  804160384d:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041603851:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  8041603855:	45 89 c8             	mov    %r9d,%r8d
  8041603858:	41 83 e0 7f          	and    $0x7f,%r8d
  804160385c:	41 d3 e0             	shl    %cl,%r8d
  804160385f:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  8041603862:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041603865:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603868:	45 84 c9             	test   %r9b,%r9b
  804160386b:	78 e0                	js     804160384d <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  804160386d:	83 f9 1f             	cmp    $0x1f,%ecx
  8041603870:	7f 0f                	jg     8041603881 <line_for_address+0x573>
  8041603872:	41 f6 c1 40          	test   $0x40,%r9b
  8041603876:	74 09                	je     8041603881 <line_for_address+0x573>
    result |= (-1U << shift);
  8041603878:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  804160387d:	d3 e7                	shl    %cl,%edi
  804160387f:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  8041603881:	41 01 d4             	add    %edx,%r12d
  return count;
  8041603884:	48 98                	cltq   
          program_addr += count;
  8041603886:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603889:	e9 f4 00 00 00       	jmpq   8041603982 <line_for_address+0x674>
      switch (opcode) {
  804160388e:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603891:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603896:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603899:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160389d:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416038a0:	84 c9                	test   %cl,%cl
  80416038a2:	78 f2                	js     8041603896 <line_for_address+0x588>
  return count;
  80416038a4:	48 98                	cltq   
          program_addr += count;
  80416038a6:	48 01 c6             	add    %rax,%rsi
        } break;
  80416038a9:	e9 d4 00 00 00       	jmpq   8041603982 <line_for_address+0x674>
      switch (opcode) {
  80416038ae:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416038b1:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416038b6:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416038b9:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416038bd:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416038c0:	84 c9                	test   %cl,%cl
  80416038c2:	78 f2                	js     80416038b6 <line_for_address+0x5a8>
  return count;
  80416038c4:	48 98                	cltq   
          program_addr += count;
  80416038c6:	48 01 c6             	add    %rax,%rsi
        } break;
  80416038c9:	e9 b4 00 00 00       	jmpq   8041603982 <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  80416038ce:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  80416038d2:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  80416038d4:	0f b6 c0             	movzbl %al,%eax
  80416038d7:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  80416038da:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  80416038dd:	48 01 c3             	add    %rax,%rbx
        } break;
  80416038e0:	e9 9d 00 00 00       	jmpq   8041603982 <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  80416038e5:	ba 02 00 00 00       	mov    $0x2,%edx
  80416038ea:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416038ee:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  80416038f5:	00 00 00 
  80416038f8:	ff d0                	callq  *%rax
          state->address += pc_inc;
  80416038fa:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416038fe:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  8041603901:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  8041603905:	eb 7b                	jmp    8041603982 <line_for_address+0x674>
      switch (opcode) {
  8041603907:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160390a:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  804160390f:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603912:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603916:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603919:	84 c9                	test   %cl,%cl
  804160391b:	78 f2                	js     804160390f <line_for_address+0x601>
  return count;
  804160391d:	48 98                	cltq   
          program_addr += count;
  804160391f:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603922:	eb 5e                	jmp    8041603982 <line_for_address+0x674>
      switch (opcode) {
  8041603924:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603927:	48 ba 94 cb 60 41 80 	movabs $0x804160cb94,%rdx
  804160392e:	00 00 00 
  8041603931:	be c1 00 00 00       	mov    $0xc1,%esi
  8041603936:	48 bf 81 cb 60 41 80 	movabs $0x804160cb81,%rdi
  804160393d:	00 00 00 
  8041603940:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603945:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160394c:	00 00 00 
  804160394f:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  8041603952:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  8041603955:	0f b6 c0             	movzbl %al,%eax
  8041603958:	f6 75 ba             	divb   -0x46(%rbp)
  804160395b:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  804160395e:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  8041603962:	01 ca                	add    %ecx,%edx
  8041603964:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  8041603967:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  804160396a:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  804160396d:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603971:	49 39 c6             	cmp    %rax,%r14
  8041603974:	77 05                	ja     804160397b <line_for_address+0x66d>
  8041603976:	48 39 d8             	cmp    %rbx,%rax
  8041603979:	72 72                	jb     80416039ed <line_for_address+0x6df>
      last_state = *state;
  804160397b:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160397f:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  8041603982:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  8041603986:	76 69                	jbe    80416039f1 <line_for_address+0x6e3>
  8041603988:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  804160398b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603990:	4c 89 ee             	mov    %r13,%rsi
  8041603993:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603997:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160399e:	00 00 00 
  80416039a1:	ff d0                	callq  *%rax
  80416039a3:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  80416039a7:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  80416039ab:	84 c0                	test   %al,%al
  80416039ad:	0f 84 37 fc ff ff    	je     80416035ea <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  80416039b3:	38 45 bb             	cmp    %al,-0x45(%rbp)
  80416039b6:	76 9a                	jbe    8041603952 <line_for_address+0x644>
      switch (opcode) {
  80416039b8:	3c 0c                	cmp    $0xc,%al
  80416039ba:	0f 87 64 ff ff ff    	ja     8041603924 <line_for_address+0x616>
  80416039c0:	0f b6 d0             	movzbl %al,%edx
  80416039c3:	48 bf 40 cc 60 41 80 	movabs $0x804160cc40,%rdi
  80416039ca:	00 00 00 
  80416039cd:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  80416039d0:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416039d4:	49 89 de             	mov    %rbx,%r14
  80416039d7:	eb a9                	jmp    8041603982 <line_for_address+0x674>
  struct Line_Number_State current_state = {
  80416039d9:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  80416039df:	eb 10                	jmp    80416039f1 <line_for_address+0x6e3>
            *state = last_state;
  80416039e1:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416039e5:	eb 0a                	jmp    80416039f1 <line_for_address+0x6e3>
            *state = last_state;
  80416039e7:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416039eb:	eb 04                	jmp    80416039f1 <line_for_address+0x6e3>
        *state = last_state;
  80416039ed:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  80416039f1:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80416039f5:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  80416039f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416039fd:	48 83 c4 38          	add    $0x38,%rsp
  8041603a01:	5b                   	pop    %rbx
  8041603a02:	41 5c                	pop    %r12
  8041603a04:	41 5d                	pop    %r13
  8041603a06:	41 5e                	pop    %r14
  8041603a08:	41 5f                	pop    %r15
  8041603a0a:	5d                   	pop    %rbp
  8041603a0b:	c3                   	retq   
    return -E_INVAL;
  8041603a0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041603a11:	eb ea                	jmp    80416039fd <line_for_address+0x6ef>

0000008041603a13 <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  8041603a13:	55                   	push   %rbp
  8041603a14:	48 89 e5             	mov    %rsp,%rbp
  8041603a17:	41 55                	push   %r13
  8041603a19:	41 54                	push   %r12
  8041603a1b:	53                   	push   %rbx
  8041603a1c:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  8041603a20:	48 bb e0 cf 60 41 80 	movabs $0x804160cfe0,%rbx
  8041603a27:	00 00 00 
  8041603a2a:	4c 8d ab c0 00 00 00 	lea    0xc0(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  8041603a31:	49 bc 78 92 60 41 80 	movabs $0x8041609278,%r12
  8041603a38:	00 00 00 
  8041603a3b:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  8041603a3f:	48 8b 33             	mov    (%rbx),%rsi
  8041603a42:	48 bf a8 cc 60 41 80 	movabs $0x804160cca8,%rdi
  8041603a49:	00 00 00 
  8041603a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a51:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  8041603a54:	48 83 c3 18          	add    $0x18,%rbx
  8041603a58:	4c 39 eb             	cmp    %r13,%rbx
  8041603a5b:	75 de                	jne    8041603a3b <mon_help+0x28>
  return 0;
}
  8041603a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a62:	48 83 c4 08          	add    $0x8,%rsp
  8041603a66:	5b                   	pop    %rbx
  8041603a67:	41 5c                	pop    %r12
  8041603a69:	41 5d                	pop    %r13
  8041603a6b:	5d                   	pop    %rbp
  8041603a6c:	c3                   	retq   

0000008041603a6d <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  8041603a6d:	55                   	push   %rbp
  8041603a6e:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603a71:	48 bf b1 cc 60 41 80 	movabs $0x804160ccb1,%rdi
  8041603a78:	00 00 00 
  8041603a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a80:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041603a87:	00 00 00 
  8041603a8a:	ff d2                	callq  *%rdx
  return 0;
}
  8041603a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a91:	5d                   	pop    %rbp
  8041603a92:	c3                   	retq   

0000008041603a93 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  8041603a93:	55                   	push   %rbp
  8041603a94:	48 89 e5             	mov    %rsp,%rbp
  8041603a97:	41 55                	push   %r13
  8041603a99:	41 54                	push   %r12
  8041603a9b:	53                   	push   %rbx
  8041603a9c:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  8041603aa0:	48 bf b9 cc 60 41 80 	movabs $0x804160ccb9,%rdi
  8041603aa7:	00 00 00 
  8041603aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603aaf:	49 bc 78 92 60 41 80 	movabs $0x8041609278,%r12
  8041603ab6:	00 00 00 
  8041603ab9:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  8041603abc:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  8041603ac3:	00 00 00 
  8041603ac6:	48 bf 28 ce 60 41 80 	movabs $0x804160ce28,%rdi
  8041603acd:	00 00 00 
  8041603ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603ad5:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  8041603ad8:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  8041603adf:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  8041603ae2:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  8041603ae9:	00 00 00 
  8041603aec:	4c 89 ee             	mov    %r13,%rsi
  8041603aef:	48 bf 58 ce 60 41 80 	movabs $0x804160ce58,%rdi
  8041603af6:	00 00 00 
  8041603af9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603afe:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603b01:	48 ba 30 c6 60 01 00 	movabs $0x160c630,%rdx
  8041603b08:	00 00 00 
  8041603b0b:	48 be 30 c6 60 41 80 	movabs $0x804160c630,%rsi
  8041603b12:	00 00 00 
  8041603b15:	48 bf 80 ce 60 41 80 	movabs $0x804160ce80,%rdi
  8041603b1c:	00 00 00 
  8041603b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b24:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603b27:	48 ba 68 43 70 01 00 	movabs $0x1704368,%rdx
  8041603b2e:	00 00 00 
  8041603b31:	48 be 68 43 70 41 80 	movabs $0x8041704368,%rsi
  8041603b38:	00 00 00 
  8041603b3b:	48 bf a8 ce 60 41 80 	movabs $0x804160cea8,%rdi
  8041603b42:	00 00 00 
  8041603b45:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b4a:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  8041603b4d:	48 bb 00 60 70 41 80 	movabs $0x8041706000,%rbx
  8041603b54:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603b57:	48 ba 00 60 70 01 00 	movabs $0x1706000,%rdx
  8041603b5e:	00 00 00 
  8041603b61:	48 89 de             	mov    %rbx,%rsi
  8041603b64:	48 bf d0 ce 60 41 80 	movabs $0x804160ced0,%rdi
  8041603b6b:	00 00 00 
  8041603b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b73:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603b76:	4c 29 eb             	sub    %r13,%rbx
  8041603b79:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603b80:	48 c1 ee 0a          	shr    $0xa,%rsi
  8041603b84:	48 bf f8 ce 60 41 80 	movabs $0x804160cef8,%rdi
  8041603b8b:	00 00 00 
  8041603b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b93:	41 ff d4             	callq  *%r12
  return 0;
}
  8041603b96:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b9b:	48 83 c4 08          	add    $0x8,%rsp
  8041603b9f:	5b                   	pop    %rbx
  8041603ba0:	41 5c                	pop    %r12
  8041603ba2:	41 5d                	pop    %r13
  8041603ba4:	5d                   	pop    %rbp
  8041603ba5:	c3                   	retq   

0000008041603ba6 <mon_backtrace>:
// }
// LAB 2 code end
// DELETED in LAB 5 end

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  8041603ba6:	55                   	push   %rbp
  8041603ba7:	48 89 e5             	mov    %rsp,%rbp
  8041603baa:	41 57                	push   %r15
  8041603bac:	41 56                	push   %r14
  8041603bae:	41 55                	push   %r13
  8041603bb0:	41 54                	push   %r12
  8041603bb2:	53                   	push   %rbx
  8041603bb3:	48 81 ec 38 02 00 00 	sub    $0x238,%rsp
  // LAB 2 code
  
  cprintf("Stack backtrace:\n");
  8041603bba:	48 bf d2 cc 60 41 80 	movabs $0x804160ccd2,%rdi
  8041603bc1:	00 00 00 
  8041603bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603bc9:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041603bd0:	00 00 00 
  8041603bd3:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603bd5:	48 89 e8             	mov    %rbp,%rax
  uint64_t buf;
  int digits_16;
  int code;
  struct Ripdebuginfo info;
    
  while (rbp != 0) {
  8041603bd8:	48 85 c0             	test   %rax,%rax
  8041603bdb:	0f 84 c5 01 00 00    	je     8041603da6 <mon_backtrace+0x200>
  8041603be1:	49 89 c6             	mov    %rax,%r14
  8041603be4:	49 89 c7             	mov    %rax,%r15
      while (buf != 0) {
        digits_16++;
        buf = buf / 16;
      }
      
      cprintf("  rbp ");
  8041603be7:	49 bc 78 92 60 41 80 	movabs $0x8041609278,%r12
  8041603bee:	00 00 00 
      cprintf("%lx\n", rip);
      
      // get and print debug info
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
      if (code == 0) {
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603bf1:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603bf8:	48 05 04 01 00 00    	add    $0x104,%rax
  8041603bfe:	48 89 85 a8 fd ff ff 	mov    %rax,-0x258(%rbp)
  8041603c05:	e9 37 01 00 00       	jmpq   8041603d41 <mon_backtrace+0x19b>
        buf = buf / 16;
  8041603c0a:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603c0d:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603c10:	48 89 c2             	mov    %rax,%rdx
  8041603c13:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603c17:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603c1b:	77 ed                	ja     8041603c0a <mon_backtrace+0x64>
      cprintf("  rbp ");
  8041603c1d:	48 bf e4 cc 60 41 80 	movabs $0x804160cce4,%rdi
  8041603c24:	00 00 00 
  8041603c27:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c2c:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c2f:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603c35:	41 29 dd             	sub    %ebx,%r13d
  8041603c38:	45 85 ed             	test   %r13d,%r13d
  8041603c3b:	7e 1f                	jle    8041603c5c <mon_backtrace+0xb6>
  8041603c3d:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603c42:	48 bf 0b da 60 41 80 	movabs $0x804160da0b,%rdi
  8041603c49:	00 00 00 
  8041603c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c51:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603c54:	83 c3 01             	add    $0x1,%ebx
  8041603c57:	41 39 dd             	cmp    %ebx,%r13d
  8041603c5a:	7d e6                	jge    8041603c42 <mon_backtrace+0x9c>
      cprintf("%lx", rbp);
  8041603c5c:	4c 89 f6             	mov    %r14,%rsi
  8041603c5f:	48 bf eb cc 60 41 80 	movabs $0x804160cceb,%rdi
  8041603c66:	00 00 00 
  8041603c69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603c6e:	41 ff d4             	callq  *%r12
      rbp = *pointer;
  8041603c71:	4d 8b 37             	mov    (%r15),%r14
      rip = *pointer;
  8041603c74:	4d 8b 7f 08          	mov    0x8(%r15),%r15
      buf = buf / 16;
  8041603c78:	4c 89 f8             	mov    %r15,%rax
  8041603c7b:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603c7f:	49 83 ff 0f          	cmp    $0xf,%r15
  8041603c83:	0f 86 e3 00 00 00    	jbe    8041603d6c <mon_backtrace+0x1c6>
      digits_16 = 1;
  8041603c89:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603c8e:	eb 03                	jmp    8041603c93 <mon_backtrace+0xed>
        buf = buf / 16;
  8041603c90:	48 89 d0             	mov    %rdx,%rax
        digits_16++;
  8041603c93:	83 c3 01             	add    $0x1,%ebx
        buf = buf / 16;
  8041603c96:	48 89 c2             	mov    %rax,%rdx
  8041603c99:	48 c1 ea 04          	shr    $0x4,%rdx
      while (buf != 0) {
  8041603c9d:	48 83 f8 0f          	cmp    $0xf,%rax
  8041603ca1:	77 ed                	ja     8041603c90 <mon_backtrace+0xea>
      cprintf("  rip ");
  8041603ca3:	48 bf ef cc 60 41 80 	movabs $0x804160ccef,%rdi
  8041603caa:	00 00 00 
  8041603cad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cb2:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603cb5:	41 bd 10 00 00 00    	mov    $0x10,%r13d
  8041603cbb:	41 29 dd             	sub    %ebx,%r13d
  8041603cbe:	45 85 ed             	test   %r13d,%r13d
  8041603cc1:	7e 1f                	jle    8041603ce2 <mon_backtrace+0x13c>
  8041603cc3:	bb 01 00 00 00       	mov    $0x1,%ebx
        cprintf("0");
  8041603cc8:	48 bf 0b da 60 41 80 	movabs $0x804160da0b,%rdi
  8041603ccf:	00 00 00 
  8041603cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cd7:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603cda:	83 c3 01             	add    $0x1,%ebx
  8041603cdd:	44 39 eb             	cmp    %r13d,%ebx
  8041603ce0:	7e e6                	jle    8041603cc8 <mon_backtrace+0x122>
      cprintf("%lx\n", rip);
  8041603ce2:	4c 89 fe             	mov    %r15,%rsi
  8041603ce5:	48 bf 69 da 60 41 80 	movabs $0x804160da69,%rdi
  8041603cec:	00 00 00 
  8041603cef:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603cf4:	41 ff d4             	callq  *%r12
      code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
  8041603cf7:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603cfe:	4c 89 ff             	mov    %r15,%rdi
  8041603d01:	48 b8 62 af 60 41 80 	movabs $0x804160af62,%rax
  8041603d08:	00 00 00 
  8041603d0b:	ff d0                	callq  *%rax
      if (code == 0) {
  8041603d0d:	85 c0                	test   %eax,%eax
  8041603d0f:	75 47                	jne    8041603d58 <mon_backtrace+0x1b2>
          cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
  8041603d11:	4d 89 f8             	mov    %r15,%r8
  8041603d14:	4c 2b 45 b8          	sub    -0x48(%rbp),%r8
  8041603d18:	48 8b 8d a8 fd ff ff 	mov    -0x258(%rbp),%rcx
  8041603d1f:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603d25:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603d2c:	48 bf f6 cc 60 41 80 	movabs $0x804160ccf6,%rdi
  8041603d33:	00 00 00 
  8041603d36:	41 ff d4             	callq  *%r12
      } else {
          cprintf("Info not found");
      }
      
      pointer = (uintptr_t *)rbp;
  8041603d39:	4d 89 f7             	mov    %r14,%r15
  while (rbp != 0) {
  8041603d3c:	4d 85 f6             	test   %r14,%r14
  8041603d3f:	74 65                	je     8041603da6 <mon_backtrace+0x200>
      buf = buf / 16;
  8041603d41:	4c 89 f0             	mov    %r14,%rax
  8041603d44:	48 c1 e8 04          	shr    $0x4,%rax
      while (buf != 0) {
  8041603d48:	49 83 fe 0f          	cmp    $0xf,%r14
  8041603d4c:	76 3b                	jbe    8041603d89 <mon_backtrace+0x1e3>
      digits_16 = 1;
  8041603d4e:	bb 01 00 00 00       	mov    $0x1,%ebx
  8041603d53:	e9 b5 fe ff ff       	jmpq   8041603c0d <mon_backtrace+0x67>
          cprintf("Info not found");
  8041603d58:	48 bf 0e cd 60 41 80 	movabs $0x804160cd0e,%rdi
  8041603d5f:	00 00 00 
  8041603d62:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d67:	41 ff d4             	callq  *%r12
  8041603d6a:	eb cd                	jmp    8041603d39 <mon_backtrace+0x193>
      cprintf("  rip ");
  8041603d6c:	48 bf ef cc 60 41 80 	movabs $0x804160ccef,%rdi
  8041603d73:	00 00 00 
  8041603d76:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d7b:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d7e:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603d84:	e9 3a ff ff ff       	jmpq   8041603cc3 <mon_backtrace+0x11d>
      cprintf("  rbp ");
  8041603d89:	48 bf e4 cc 60 41 80 	movabs $0x804160cce4,%rdi
  8041603d90:	00 00 00 
  8041603d93:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d98:	41 ff d4             	callq  *%r12
      for (int i = 1; i <= 16 - digits_16; i++) {
  8041603d9b:	41 bd 0f 00 00 00    	mov    $0xf,%r13d
  8041603da1:	e9 97 fe ff ff       	jmpq   8041603c3d <mon_backtrace+0x97>
    }
    
  // LAB 2 code end
  return 0;
}
  8041603da6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603dab:	48 81 c4 38 02 00 00 	add    $0x238,%rsp
  8041603db2:	5b                   	pop    %rbx
  8041603db3:	41 5c                	pop    %r12
  8041603db5:	41 5d                	pop    %r13
  8041603db7:	41 5e                	pop    %r14
  8041603db9:	41 5f                	pop    %r15
  8041603dbb:	5d                   	pop    %rbp
  8041603dbc:	c3                   	retq   

0000008041603dbd <mon_start>:
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
int
mon_start(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603dbd:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603dc2:	83 ff 02             	cmp    $0x2,%edi
  8041603dc5:	74 01                	je     8041603dc8 <mon_start+0xb>
  }
  timer_start(argv[1]);
  // LAB 5 code end

  return 0;
}
  8041603dc7:	c3                   	retq   
mon_start(int argc, char **argv, struct Trapframe *tf) {
  8041603dc8:	55                   	push   %rbp
  8041603dc9:	48 89 e5             	mov    %rsp,%rbp
  timer_start(argv[1]);
  8041603dcc:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603dd0:	48 b8 45 c3 60 41 80 	movabs $0x804160c345,%rax
  8041603dd7:	00 00 00 
  8041603dda:	ff d0                	callq  *%rax
  return 0;
  8041603ddc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603de1:	5d                   	pop    %rbp
  8041603de2:	c3                   	retq   

0000008041603de3 <mon_stop>:

int
mon_stop(int argc, char **argv, struct Trapframe *tf) {
  8041603de3:	55                   	push   %rbp
  8041603de4:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  timer_stop();
  8041603de7:	48 b8 ff c3 60 41 80 	movabs $0x804160c3ff,%rax
  8041603dee:	00 00 00 
  8041603df1:	ff d0                	callq  *%rax
  // LAB 5 code end

  return 0;
}
  8041603df3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603df8:	5d                   	pop    %rbp
  8041603df9:	c3                   	retq   

0000008041603dfa <mon_frequency>:

int
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  8041603dfa:	b8 01 00 00 00       	mov    $0x1,%eax
  if (argc != 2) {
  8041603dff:	83 ff 02             	cmp    $0x2,%edi
  8041603e02:	74 01                	je     8041603e05 <mon_frequency+0xb>
  }
  timer_cpu_frequency(argv[1]);
  // LAB 5 code end

  return 0;
}
  8041603e04:	c3                   	retq   
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  8041603e05:	55                   	push   %rbp
  8041603e06:	48 89 e5             	mov    %rsp,%rbp
  timer_cpu_frequency(argv[1]);
  8041603e09:	48 8b 7e 08          	mov    0x8(%rsi),%rdi
  8041603e0d:	48 b8 89 c4 60 41 80 	movabs $0x804160c489,%rax
  8041603e14:	00 00 00 
  8041603e17:	ff d0                	callq  *%rax
  return 0;
  8041603e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603e1e:	5d                   	pop    %rbp
  8041603e1f:	c3                   	retq   

0000008041603e20 <mon_memory>:
int 
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  size_t i;
	int is_cur_free;

	for (i = 1; i <= npages; i++) {
  8041603e20:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041603e27:	00 00 00 
  8041603e2a:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041603e2e:	0f 84 24 01 00 00    	je     8041603f58 <mon_memory+0x138>
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  8041603e34:	55                   	push   %rbp
  8041603e35:	48 89 e5             	mov    %rsp,%rbp
  8041603e38:	41 57                	push   %r15
  8041603e3a:	41 56                	push   %r14
  8041603e3c:	41 55                	push   %r13
  8041603e3e:	41 54                	push   %r12
  8041603e40:	53                   	push   %rbx
  8041603e41:	48 83 ec 18          	sub    $0x18,%rsp
	for (i = 1; i <= npages; i++) {
  8041603e45:	bb 01 00 00 00       	mov    $0x1,%ebx
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603e4a:	49 be 58 5b 70 41 80 	movabs $0x8041705b58,%r14
  8041603e51:	00 00 00 
		cprintf("%lu", i);
  8041603e54:	49 bf 78 92 60 41 80 	movabs $0x8041609278,%r15
  8041603e5b:	00 00 00 
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603e5e:	49 89 c4             	mov    %rax,%r12
  8041603e61:	eb 47                	jmp    8041603eaa <mon_memory+0x8a>
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
        i++;
      }
			cprintf("..%lu", i);
  8041603e63:	48 89 de             	mov    %rbx,%rsi
  8041603e66:	48 bf 30 cd 60 41 80 	movabs $0x804160cd30,%rdi
  8041603e6d:	00 00 00 
  8041603e70:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e75:	41 ff d7             	callq  *%r15
		}
		cprintf(is_cur_free ? " FREE\n" : " ALLOCATED\n");
  8041603e78:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603e7c:	48 bf 1d cd 60 41 80 	movabs $0x804160cd1d,%rdi
  8041603e83:	00 00 00 
  8041603e86:	48 b8 24 cd 60 41 80 	movabs $0x804160cd24,%rax
  8041603e8d:	00 00 00 
  8041603e90:	48 0f 45 f8          	cmovne %rax,%rdi
  8041603e94:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e99:	41 ff d7             	callq  *%r15
	for (i = 1; i <= npages; i++) {
  8041603e9c:	48 83 c3 01          	add    $0x1,%rbx
  8041603ea0:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603ea4:	0f 82 9a 00 00 00    	jb     8041603f44 <mon_memory+0x124>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603eaa:	49 89 dd             	mov    %rbx,%r13
  8041603ead:	49 c1 e5 04          	shl    $0x4,%r13
  8041603eb1:	49 8b 06             	mov    (%r14),%rax
  8041603eb4:	4a 8d 7c 28 f0       	lea    -0x10(%rax,%r13,1),%rdi
  8041603eb9:	48 b8 46 4b 60 41 80 	movabs $0x8041604b46,%rax
  8041603ec0:	00 00 00 
  8041603ec3:	ff d0                	callq  *%rax
  8041603ec5:	89 45 cc             	mov    %eax,-0x34(%rbp)
		cprintf("%lu", i);
  8041603ec8:	48 89 de             	mov    %rbx,%rsi
  8041603ecb:	48 bf 32 cd 60 41 80 	movabs $0x804160cd32,%rdi
  8041603ed2:	00 00 00 
  8041603ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603eda:	41 ff d7             	callq  *%r15
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603edd:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603ee1:	76 95                	jbe    8041603e78 <mon_memory+0x58>
    is_cur_free = !page_is_allocated(&pages[i - 1]);
  8041603ee3:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8041603ee7:	0f 94 c0             	sete   %al
  8041603eea:	0f b6 c0             	movzbl %al,%eax
  8041603eed:	89 45 c8             	mov    %eax,-0x38(%rbp)
		if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603ef0:	4c 89 ef             	mov    %r13,%rdi
  8041603ef3:	49 03 3e             	add    (%r14),%rdi
  8041603ef6:	48 b8 46 4b 60 41 80 	movabs $0x8041604b46,%rax
  8041603efd:	00 00 00 
  8041603f00:	ff d0                	callq  *%rax
  8041603f02:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603f05:	0f 84 6d ff ff ff    	je     8041603e78 <mon_memory+0x58>
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603f0b:	49 bd 46 4b 60 41 80 	movabs $0x8041604b46,%r13
  8041603f12:	00 00 00 
  8041603f15:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603f19:	0f 86 44 ff ff ff    	jbe    8041603e63 <mon_memory+0x43>
  8041603f1f:	48 89 df             	mov    %rbx,%rdi
  8041603f22:	48 c1 e7 04          	shl    $0x4,%rdi
  8041603f26:	49 03 3e             	add    (%r14),%rdi
  8041603f29:	41 ff d5             	callq  *%r13
  8041603f2c:	3b 45 c8             	cmp    -0x38(%rbp),%eax
  8041603f2f:	0f 84 2e ff ff ff    	je     8041603e63 <mon_memory+0x43>
        i++;
  8041603f35:	48 83 c3 01          	add    $0x1,%rbx
			while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
  8041603f39:	49 39 1c 24          	cmp    %rbx,(%r12)
  8041603f3d:	77 e0                	ja     8041603f1f <mon_memory+0xff>
  8041603f3f:	e9 1f ff ff ff       	jmpq   8041603e63 <mon_memory+0x43>
	}
	
  return 0;
}
  8041603f44:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f49:	48 83 c4 18          	add    $0x18,%rsp
  8041603f4d:	5b                   	pop    %rbx
  8041603f4e:	41 5c                	pop    %r12
  8041603f50:	41 5d                	pop    %r13
  8041603f52:	41 5e                	pop    %r14
  8041603f54:	41 5f                	pop    %r15
  8041603f56:	5d                   	pop    %rbp
  8041603f57:	c3                   	retq   
  8041603f58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f5d:	c3                   	retq   

0000008041603f5e <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  8041603f5e:	55                   	push   %rbp
  8041603f5f:	48 89 e5             	mov    %rsp,%rbp
  8041603f62:	41 57                	push   %r15
  8041603f64:	41 56                	push   %r14
  8041603f66:	41 55                	push   %r13
  8041603f68:	41 54                	push   %r12
  8041603f6a:	53                   	push   %rbx
  8041603f6b:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603f72:	49 89 ff             	mov    %rdi,%r15
  8041603f75:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603f7c:	48 bf 28 cf 60 41 80 	movabs $0x804160cf28,%rdi
  8041603f83:	00 00 00 
  8041603f86:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f8b:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  8041603f92:	00 00 00 
  8041603f95:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603f97:	48 bf 50 cf 60 41 80 	movabs $0x804160cf50,%rdi
  8041603f9e:	00 00 00 
  8041603fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603fa6:	ff d3                	callq  *%rbx

  if (tf != NULL)
  8041603fa8:	4d 85 ff             	test   %r15,%r15
  8041603fab:	74 0f                	je     8041603fbc <monitor+0x5e>
    print_trapframe(tf);
  8041603fad:	4c 89 ff             	mov    %r15,%rdi
  8041603fb0:	48 b8 43 99 60 41 80 	movabs $0x8041609943,%rax
  8041603fb7:	00 00 00 
  8041603fba:	ff d0                	callq  *%rax

  while (1) {
    buf = readline("K> ");
  8041603fbc:	49 bf 48 bb 60 41 80 	movabs $0x804160bb48,%r15
  8041603fc3:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603fc6:	49 be f8 bd 60 41 80 	movabs $0x804160bdf8,%r14
  8041603fcd:	00 00 00 
  8041603fd0:	e9 ff 00 00 00       	jmpq   80416040d4 <monitor+0x176>
  8041603fd5:	40 0f be f6          	movsbl %sil,%esi
  8041603fd9:	48 bf 3a cd 60 41 80 	movabs $0x804160cd3a,%rdi
  8041603fe0:	00 00 00 
  8041603fe3:	41 ff d6             	callq  *%r14
  8041603fe6:	48 85 c0             	test   %rax,%rax
  8041603fe9:	74 0c                	je     8041603ff7 <monitor+0x99>
      *buf++ = 0;
  8041603feb:	c6 03 00             	movb   $0x0,(%rbx)
  8041603fee:	45 89 e5             	mov    %r12d,%r13d
  8041603ff1:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603ff5:	eb 49                	jmp    8041604040 <monitor+0xe2>
    if (*buf == 0)
  8041603ff7:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603ffa:	74 4f                	je     804160404b <monitor+0xed>
    if (argc == MAXARGS - 1) {
  8041603ffc:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041604000:	0f 84 b3 00 00 00    	je     80416040b9 <monitor+0x15b>
    argv[argc++] = buf;
  8041604006:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  804160400b:	4d 63 e4             	movslq %r12d,%r12
  804160400e:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041604015:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041604016:	0f b6 33             	movzbl (%rbx),%esi
  8041604019:	40 84 f6             	test   %sil,%sil
  804160401c:	74 22                	je     8041604040 <monitor+0xe2>
  804160401e:	40 0f be f6          	movsbl %sil,%esi
  8041604022:	48 bf 3a cd 60 41 80 	movabs $0x804160cd3a,%rdi
  8041604029:	00 00 00 
  804160402c:	41 ff d6             	callq  *%r14
  804160402f:	48 85 c0             	test   %rax,%rax
  8041604032:	75 0c                	jne    8041604040 <monitor+0xe2>
      buf++;
  8041604034:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041604038:	0f b6 33             	movzbl (%rbx),%esi
  804160403b:	40 84 f6             	test   %sil,%sil
  804160403e:	75 de                	jne    804160401e <monitor+0xc0>
      *buf++ = 0;
  8041604040:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041604043:	0f b6 33             	movzbl (%rbx),%esi
  8041604046:	40 84 f6             	test   %sil,%sil
  8041604049:	75 8a                	jne    8041603fd5 <monitor+0x77>
  argv[argc] = 0;
  804160404b:	49 63 c4             	movslq %r12d,%rax
  804160404e:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041604055:	ff 00 00 00 00 
  if (argc == 0)
  804160405a:	45 85 e4             	test   %r12d,%r12d
  804160405d:	74 75                	je     80416040d4 <monitor+0x176>
  804160405f:	49 bd e0 cf 60 41 80 	movabs $0x804160cfe0,%r13
  8041604066:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041604069:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  804160406e:	49 8b 75 00          	mov    0x0(%r13),%rsi
  8041604072:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041604079:	48 b8 91 bd 60 41 80 	movabs $0x804160bd91,%rax
  8041604080:	00 00 00 
  8041604083:	ff d0                	callq  *%rax
  8041604085:	85 c0                	test   %eax,%eax
  8041604087:	74 76                	je     80416040ff <monitor+0x1a1>
  for (i = 0; i < NCOMMANDS; i++) {
  8041604089:	83 c3 01             	add    $0x1,%ebx
  804160408c:	49 83 c5 18          	add    $0x18,%r13
  8041604090:	83 fb 08             	cmp    $0x8,%ebx
  8041604093:	75 d9                	jne    804160406e <monitor+0x110>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041604095:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  804160409c:	48 bf 5c cd 60 41 80 	movabs $0x804160cd5c,%rdi
  80416040a3:	00 00 00 
  80416040a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416040ab:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416040b2:	00 00 00 
  80416040b5:	ff d2                	callq  *%rdx
  return 0;
  80416040b7:	eb 1b                	jmp    80416040d4 <monitor+0x176>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  80416040b9:	be 10 00 00 00       	mov    $0x10,%esi
  80416040be:	48 bf 3f cd 60 41 80 	movabs $0x804160cd3f,%rdi
  80416040c5:	00 00 00 
  80416040c8:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416040cf:	00 00 00 
  80416040d2:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  80416040d4:	48 bf 36 cd 60 41 80 	movabs $0x804160cd36,%rdi
  80416040db:	00 00 00 
  80416040de:	41 ff d7             	callq  *%r15
  80416040e1:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  80416040e4:	48 85 c0             	test   %rax,%rax
  80416040e7:	74 eb                	je     80416040d4 <monitor+0x176>
  argv[argc] = 0;
  80416040e9:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  80416040f0:	00 00 00 00 
  argc       = 0;
  80416040f4:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  80416040fa:	e9 44 ff ff ff       	jmpq   8041604043 <monitor+0xe5>
      return commands[i].func(argc, argv, tf);
  80416040ff:	48 63 db             	movslq %ebx,%rbx
  8041604102:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  8041604106:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  804160410d:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  8041604114:	44 89 e7             	mov    %r12d,%edi
  8041604117:	48 b8 e0 cf 60 41 80 	movabs $0x804160cfe0,%rax
  804160411e:	00 00 00 
  8041604121:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  8041604125:	85 c0                	test   %eax,%eax
  8041604127:	79 ab                	jns    80416040d4 <monitor+0x176>
        break;
  }
}
  8041604129:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041604130:	5b                   	pop    %rbx
  8041604131:	41 5c                	pop    %r12
  8041604133:	41 5d                	pop    %r13
  8041604135:	41 5e                	pop    %r14
  8041604137:	41 5f                	pop    %r15
  8041604139:	5d                   	pop    %rbp
  804160413a:	c3                   	retq   

000000804160413b <check_va2pa>:
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  pte_t *pte;
  pdpe_t *pdpe;
  pde_t *pde;
  // cprintf("%x", va);
  pml4e = &pml4e[PML4(va)];
  804160413b:	48 89 f0             	mov    %rsi,%rax
  804160413e:	48 c1 e8 27          	shr    $0x27,%rax
  8041604142:	25 ff 01 00 00       	and    $0x1ff,%eax
  // cprintf(" %x %x " , PML4(va), *pml4e);
  if (!(*pml4e & PTE_P))
  8041604147:	48 8b 0c c7          	mov    (%rdi,%rax,8),%rcx
  804160414b:	f6 c1 01             	test   $0x1,%cl
  804160414e:	0f 84 5a 01 00 00    	je     80416042ae <check_va2pa+0x173>
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  8041604154:	55                   	push   %rbp
  8041604155:	48 89 e5             	mov    %rsp,%rbp
    return ~0;
  pdpe = (pdpe_t *)KADDR(PTE_ADDR(*pml4e));
  8041604158:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
//CAUTION: use only before page detection!
#define _KADDR_NOCHECK(pa) (void *)((physaddr_t)pa + KERNBASE)

static inline void *
_kaddr(const char *file, int line, physaddr_t pa) {
  if (PGNUM(pa) >= npages)
  804160415f:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041604166:	00 00 00 
  8041604169:	48 8b 10             	mov    (%rax),%rdx
  804160416c:	48 89 c8             	mov    %rcx,%rax
  804160416f:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604173:	48 39 c2             	cmp    %rax,%rdx
  8041604176:	0f 86 b1 00 00 00    	jbe    804160422d <check_va2pa+0xf2>
  // cprintf(" %x %x " , pdpe, *pdpe);
  if (!(pdpe[PDPE(va)] & PTE_P))
  804160417c:	48 89 f0             	mov    %rsi,%rax
  804160417f:	48 c1 e8 1b          	shr    $0x1b,%rax
  8041604183:	25 f8 0f 00 00       	and    $0xff8,%eax
  8041604188:	48 01 c1             	add    %rax,%rcx
  804160418b:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041604192:	00 00 00 
  8041604195:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  8041604199:	f6 c1 01             	test   $0x1,%cl
  804160419c:	0f 84 14 01 00 00    	je     80416042b6 <check_va2pa+0x17b>
    return ~0;
  pde = (pde_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  80416041a2:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416041a9:	48 89 c8             	mov    %rcx,%rax
  80416041ac:	48 c1 e8 0c          	shr    $0xc,%rax
  80416041b0:	48 39 c2             	cmp    %rax,%rdx
  80416041b3:	0f 86 9f 00 00 00    	jbe    8041604258 <check_va2pa+0x11d>
  // cprintf(" %x %x " , pde, *pde);
  pde = &pde[PDX(va)];
  80416041b9:	48 89 f0             	mov    %rsi,%rax
  80416041bc:	48 c1 e8 12          	shr    $0x12,%rax
  if (!(*pde & PTE_P))
  80416041c0:	25 f8 0f 00 00       	and    $0xff8,%eax
  80416041c5:	48 01 c1             	add    %rax,%rcx
  80416041c8:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416041cf:	00 00 00 
  80416041d2:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  80416041d6:	f6 c1 01             	test   $0x1,%cl
  80416041d9:	0f 84 e3 00 00 00    	je     80416042c2 <check_va2pa+0x187>
    return ~0;
  pte = (pte_t *)KADDR(PTE_ADDR(*pde));
  80416041df:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416041e6:	48 89 c8             	mov    %rcx,%rax
  80416041e9:	48 c1 e8 0c          	shr    $0xc,%rax
  80416041ed:	48 39 c2             	cmp    %rax,%rdx
  80416041f0:	0f 86 8d 00 00 00    	jbe    8041604283 <check_va2pa+0x148>
  // cprintf(" %x %x " , pte, *pte);
  if (!(pte[PTX(va)] & PTE_P))
  80416041f6:	48 c1 ee 09          	shr    $0x9,%rsi
  80416041fa:	81 e6 f8 0f 00 00    	and    $0xff8,%esi
  8041604200:	48 01 ce             	add    %rcx,%rsi
  8041604203:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160420a:	00 00 00 
  804160420d:	48 8b 04 06          	mov    (%rsi,%rax,1),%rax
  8041604211:	48 89 c2             	mov    %rax,%rdx
  8041604214:	83 e2 01             	and    $0x1,%edx
    return ~0;
  // cprintf(" %x %x\n" , PTX(va),  PTE_ADDR(pte[PTX(va)]));
  return PTE_ADDR(pte[PTX(va)]);
  8041604217:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160421d:	48 85 d2             	test   %rdx,%rdx
  8041604220:	48 c7 c2 ff ff ff ff 	mov    $0xffffffffffffffff,%rdx
  8041604227:	48 0f 44 c2          	cmove  %rdx,%rax
}
  804160422b:	5d                   	pop    %rbp
  804160422c:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  804160422d:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604234:	00 00 00 
  8041604237:	be 79 04 00 00       	mov    $0x479,%esi
  804160423c:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604243:	00 00 00 
  8041604246:	b8 00 00 00 00       	mov    $0x0,%eax
  804160424b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604252:	00 00 00 
  8041604255:	41 ff d0             	callq  *%r8
  8041604258:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  804160425f:	00 00 00 
  8041604262:	be 7d 04 00 00       	mov    $0x47d,%esi
  8041604267:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160426e:	00 00 00 
  8041604271:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604276:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160427d:	00 00 00 
  8041604280:	41 ff d0             	callq  *%r8
  8041604283:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  804160428a:	00 00 00 
  804160428d:	be 82 04 00 00       	mov    $0x482,%esi
  8041604292:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604299:	00 00 00 
  804160429c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416042a1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416042a8:	00 00 00 
  80416042ab:	41 ff d0             	callq  *%r8
    return ~0;
  80416042ae:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
}
  80416042b5:	c3                   	retq   
    return ~0;
  80416042b6:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  80416042bd:	e9 69 ff ff ff       	jmpq   804160422b <check_va2pa+0xf0>
    return ~0;
  80416042c2:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  80416042c9:	e9 5d ff ff ff       	jmpq   804160422b <check_va2pa+0xf0>

00000080416042ce <boot_alloc>:
  if (!nextfree) {
  80416042ce:	48 b8 f8 45 70 41 80 	movabs $0x80417045f8,%rax
  80416042d5:	00 00 00 
  80416042d8:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416042dc:	74 5c                	je     804160433a <boot_alloc+0x6c>
  if (!n) {
  80416042de:	85 ff                	test   %edi,%edi
  80416042e0:	74 74                	je     8041604356 <boot_alloc+0x88>
boot_alloc(uint32_t n) {
  80416042e2:	55                   	push   %rbp
  80416042e3:	48 89 e5             	mov    %rsp,%rbp
	result = nextfree;
  80416042e6:	48 ba f8 45 70 41 80 	movabs $0x80417045f8,%rdx
  80416042ed:	00 00 00 
  80416042f0:	48 8b 02             	mov    (%rdx),%rax
	nextfree += ROUNDUP(n, PGSIZE);
  80416042f3:	48 8d 8f ff 0f 00 00 	lea    0xfff(%rdi),%rcx
  80416042fa:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  8041604300:	48 01 c1             	add    %rax,%rcx
  8041604303:	48 89 0a             	mov    %rcx,(%rdx)
  if ((uint64_t)kva < KERNBASE)
  8041604306:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160430d:	00 00 00 
  8041604310:	48 39 d1             	cmp    %rdx,%rcx
  8041604313:	76 4c                	jbe    8041604361 <boot_alloc+0x93>
	if (PADDR(nextfree) > PGSIZE * npages) {
  8041604315:	48 be 50 5b 70 41 80 	movabs $0x8041705b50,%rsi
  804160431c:	00 00 00 
  804160431f:	48 8b 16             	mov    (%rsi),%rdx
  8041604322:	48 c1 e2 0c          	shl    $0xc,%rdx
  return (physaddr_t)kva - KERNBASE;
  8041604326:	48 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rsi
  804160432d:	ff ff ff 
  8041604330:	48 01 f1             	add    %rsi,%rcx
  8041604333:	48 39 ca             	cmp    %rcx,%rdx
  8041604336:	72 54                	jb     804160438c <boot_alloc+0xbe>
}
  8041604338:	5d                   	pop    %rbp
  8041604339:	c3                   	retq   
		nextfree = ROUNDUP((char *)end, PGSIZE);
  804160433a:	48 b8 ff 6f 70 41 80 	movabs $0x8041706fff,%rax
  8041604341:	00 00 00 
  8041604344:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160434a:	48 a3 f8 45 70 41 80 	movabs %rax,0x80417045f8
  8041604351:	00 00 00 
  8041604354:	eb 88                	jmp    80416042de <boot_alloc+0x10>
	    return nextfree;
  8041604356:	48 a1 f8 45 70 41 80 	movabs 0x80417045f8,%rax
  804160435d:	00 00 00 
}
  8041604360:	c3                   	retq   
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041604361:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  8041604368:	00 00 00 
  804160436b:	be bd 00 00 00       	mov    $0xbd,%esi
  8041604370:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604377:	00 00 00 
  804160437a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160437f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604386:	00 00 00 
  8041604389:	41 ff d0             	callq  *%r8
	    panic("Not enough memory for boot!");
  804160438c:	48 ba c0 d9 60 41 80 	movabs $0x804160d9c0,%rdx
  8041604393:	00 00 00 
  8041604396:	be be 00 00 00       	mov    $0xbe,%esi
  804160439b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416043a2:	00 00 00 
  80416043a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416043aa:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416043b1:	00 00 00 
  80416043b4:	ff d1                	callq  *%rcx

00000080416043b6 <check_page_free_list>:
check_page_free_list(bool only_low_memory) {
  80416043b6:	55                   	push   %rbp
  80416043b7:	48 89 e5             	mov    %rsp,%rbp
  80416043ba:	53                   	push   %rbx
  80416043bb:	48 83 ec 28          	sub    $0x28,%rsp
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  80416043bf:	40 84 ff             	test   %dil,%dil
  80416043c2:	0f 85 7f 03 00 00    	jne    8041604747 <check_page_free_list+0x391>
  if (!page_free_list)
  80416043c8:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  80416043cf:	00 00 00 
  80416043d2:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416043d6:	0f 84 9f 00 00 00    	je     804160447b <check_page_free_list+0xc5>
  first_free_page = (char *)boot_alloc(0);
  80416043dc:	bf 00 00 00 00       	mov    $0x0,%edi
  80416043e1:	48 b8 ce 42 60 41 80 	movabs $0x80416042ce,%rax
  80416043e8:	00 00 00 
  80416043eb:	ff d0                	callq  *%rax
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  80416043ed:	48 bb 08 46 70 41 80 	movabs $0x8041704608,%rbx
  80416043f4:	00 00 00 
  80416043f7:	48 8b 13             	mov    (%rbx),%rdx
  80416043fa:	48 85 d2             	test   %rdx,%rdx
  80416043fd:	0f 84 0f 03 00 00    	je     8041604712 <check_page_free_list+0x35c>
    assert(pp >= pages);
  8041604403:	48 bb 58 5b 70 41 80 	movabs $0x8041705b58,%rbx
  804160440a:	00 00 00 
  804160440d:	48 8b 3b             	mov    (%rbx),%rdi
  8041604410:	48 39 fa             	cmp    %rdi,%rdx
  8041604413:	0f 82 8c 00 00 00    	jb     80416044a5 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  8041604419:	48 bb 50 5b 70 41 80 	movabs $0x8041705b50,%rbx
  8041604420:	00 00 00 
  8041604423:	4c 8b 1b             	mov    (%rbx),%r11
  8041604426:	4d 89 d8             	mov    %r11,%r8
  8041604429:	49 c1 e0 04          	shl    $0x4,%r8
  804160442d:	49 01 f8             	add    %rdi,%r8
  8041604430:	4c 39 c2             	cmp    %r8,%rdx
  8041604433:	0f 83 a1 00 00 00    	jae    80416044da <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  8041604439:	48 89 d1             	mov    %rdx,%rcx
  804160443c:	48 29 f9             	sub    %rdi,%rcx
  804160443f:	f6 c1 0f             	test   $0xf,%cl
  8041604442:	0f 85 c7 00 00 00    	jne    804160450f <check_page_free_list+0x159>
int user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
  8041604448:	48 c1 f9 04          	sar    $0x4,%rcx
  804160444c:	48 c1 e1 0c          	shl    $0xc,%rcx
  8041604450:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  8041604453:	0f 84 eb 00 00 00    	je     8041604544 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604459:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  8041604460:	0f 84 13 01 00 00    	je     8041604579 <check_page_free_list+0x1c3>
  int nfree_basemem = 0, nfree_extmem = 0;
  8041604466:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  return (void *)(pa + KERNBASE);
  804160446c:	48 bb 00 00 00 40 80 	movabs $0x8040000000,%rbx
  8041604473:	00 00 00 
  8041604476:	e9 17 02 00 00       	jmpq   8041604692 <check_page_free_list+0x2dc>
    panic("'page_free_list' is a null pointer!");
  804160447b:	48 ba e8 d0 60 41 80 	movabs $0x804160d0e8,%rdx
  8041604482:	00 00 00 
  8041604485:	be ad 03 00 00       	mov    $0x3ad,%esi
  804160448a:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604491:	00 00 00 
  8041604494:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604499:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416044a0:	00 00 00 
  80416044a3:	ff d1                	callq  *%rcx
    assert(pp >= pages);
  80416044a5:	48 b9 dc d9 60 41 80 	movabs $0x804160d9dc,%rcx
  80416044ac:	00 00 00 
  80416044af:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416044b6:	00 00 00 
  80416044b9:	be ce 03 00 00       	mov    $0x3ce,%esi
  80416044be:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416044c5:	00 00 00 
  80416044c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416044cd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416044d4:	00 00 00 
  80416044d7:	41 ff d0             	callq  *%r8
    assert(pp < pages + npages);
  80416044da:	48 b9 e8 d9 60 41 80 	movabs $0x804160d9e8,%rcx
  80416044e1:	00 00 00 
  80416044e4:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416044eb:	00 00 00 
  80416044ee:	be cf 03 00 00       	mov    $0x3cf,%esi
  80416044f3:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416044fa:	00 00 00 
  80416044fd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604502:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604509:	00 00 00 
  804160450c:	41 ff d0             	callq  *%r8
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  804160450f:	48 b9 10 d1 60 41 80 	movabs $0x804160d110,%rcx
  8041604516:	00 00 00 
  8041604519:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041604520:	00 00 00 
  8041604523:	be d0 03 00 00       	mov    $0x3d0,%esi
  8041604528:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160452f:	00 00 00 
  8041604532:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604537:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160453e:	00 00 00 
  8041604541:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != 0);
  8041604544:	48 b9 fc d9 60 41 80 	movabs $0x804160d9fc,%rcx
  804160454b:	00 00 00 
  804160454e:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041604555:	00 00 00 
  8041604558:	be d3 03 00 00       	mov    $0x3d3,%esi
  804160455d:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604564:	00 00 00 
  8041604567:	b8 00 00 00 00       	mov    $0x0,%eax
  804160456c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604573:	00 00 00 
  8041604576:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != IOPHYSMEM);
  8041604579:	48 b9 0d da 60 41 80 	movabs $0x804160da0d,%rcx
  8041604580:	00 00 00 
  8041604583:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160458a:	00 00 00 
  804160458d:	be d4 03 00 00       	mov    $0x3d4,%esi
  8041604592:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604599:	00 00 00 
  804160459c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045a1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045a8:	00 00 00 
  80416045ab:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  80416045ae:	48 b9 40 d1 60 41 80 	movabs $0x804160d140,%rcx
  80416045b5:	00 00 00 
  80416045b8:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416045bf:	00 00 00 
  80416045c2:	be d5 03 00 00       	mov    $0x3d5,%esi
  80416045c7:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416045ce:	00 00 00 
  80416045d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416045d6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416045dd:	00 00 00 
  80416045e0:	41 ff d0             	callq  *%r8
    assert(page2pa(pp) != EXTPHYSMEM);
  80416045e3:	48 b9 26 da 60 41 80 	movabs $0x804160da26,%rcx
  80416045ea:	00 00 00 
  80416045ed:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416045f4:	00 00 00 
  80416045f7:	be d6 03 00 00       	mov    $0x3d6,%esi
  80416045fc:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604603:	00 00 00 
  8041604606:	b8 00 00 00 00       	mov    $0x0,%eax
  804160460b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604612:	00 00 00 
  8041604615:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604618:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  804160461f:	00 00 00 
  8041604622:	be 61 00 00 00       	mov    $0x61,%esi
  8041604627:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  804160462e:	00 00 00 
  8041604631:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604636:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160463d:	00 00 00 
  8041604640:	41 ff d0             	callq  *%r8
      ++nfree_extmem;
  8041604643:	41 83 c1 01          	add    $0x1,%r9d
  for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604647:	48 8b 12             	mov    (%rdx),%rdx
  804160464a:	48 85 d2             	test   %rdx,%rdx
  804160464d:	0f 84 b3 00 00 00    	je     8041604706 <check_page_free_list+0x350>
    assert(pp >= pages);
  8041604653:	48 39 fa             	cmp    %rdi,%rdx
  8041604656:	0f 82 49 fe ff ff    	jb     80416044a5 <check_page_free_list+0xef>
    assert(pp < pages + npages);
  804160465c:	4c 39 c2             	cmp    %r8,%rdx
  804160465f:	0f 83 75 fe ff ff    	jae    80416044da <check_page_free_list+0x124>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
  8041604665:	48 89 d1             	mov    %rdx,%rcx
  8041604668:	48 29 f9             	sub    %rdi,%rcx
  804160466b:	f6 c1 0f             	test   $0xf,%cl
  804160466e:	0f 85 9b fe ff ff    	jne    804160450f <check_page_free_list+0x159>
  return (pp - pages) << PGSHIFT;
  8041604674:	48 c1 f9 04          	sar    $0x4,%rcx
  8041604678:	48 c1 e1 0c          	shl    $0xc,%rcx
  804160467c:	48 89 ce             	mov    %rcx,%rsi
    assert(page2pa(pp) != 0);
  804160467f:	0f 84 bf fe ff ff    	je     8041604544 <check_page_free_list+0x18e>
    assert(page2pa(pp) != IOPHYSMEM);
  8041604685:	48 81 f9 00 00 0a 00 	cmp    $0xa0000,%rcx
  804160468c:	0f 84 e7 fe ff ff    	je     8041604579 <check_page_free_list+0x1c3>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  8041604692:	48 81 fe 00 f0 0f 00 	cmp    $0xff000,%rsi
  8041604699:	0f 84 0f ff ff ff    	je     80416045ae <check_page_free_list+0x1f8>
    assert(page2pa(pp) != EXTPHYSMEM);
  804160469f:	48 81 fe 00 00 10 00 	cmp    $0x100000,%rsi
  80416046a6:	0f 84 37 ff ff ff    	je     80416045e3 <check_page_free_list+0x22d>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
  80416046ac:	48 81 fe ff ff 0f 00 	cmp    $0xfffff,%rsi
  80416046b3:	76 92                	jbe    8041604647 <check_page_free_list+0x291>
  if (PGNUM(pa) >= npages)
  80416046b5:	49 89 f2             	mov    %rsi,%r10
  80416046b8:	49 c1 ea 0c          	shr    $0xc,%r10
  80416046bc:	4d 39 d3             	cmp    %r10,%r11
  80416046bf:	0f 86 53 ff ff ff    	jbe    8041604618 <check_page_free_list+0x262>
  return (void *)(pa + KERNBASE);
  80416046c5:	48 01 de             	add    %rbx,%rsi
  80416046c8:	48 39 f0             	cmp    %rsi,%rax
  80416046cb:	0f 86 72 ff ff ff    	jbe    8041604643 <check_page_free_list+0x28d>
  80416046d1:	48 b9 68 d1 60 41 80 	movabs $0x804160d168,%rcx
  80416046d8:	00 00 00 
  80416046db:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416046e2:	00 00 00 
  80416046e5:	be d7 03 00 00       	mov    $0x3d7,%esi
  80416046ea:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416046f1:	00 00 00 
  80416046f4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416046f9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604700:	00 00 00 
  8041604703:	41 ff d0             	callq  *%r8
  assert(nfree_extmem > 0);
  8041604706:	45 85 c9             	test   %r9d,%r9d
  8041604709:	7e 07                	jle    8041604712 <check_page_free_list+0x35c>
}
  804160470b:	48 83 c4 28          	add    $0x28,%rsp
  804160470f:	5b                   	pop    %rbx
  8041604710:	5d                   	pop    %rbp
  8041604711:	c3                   	retq   
  assert(nfree_extmem > 0);
  8041604712:	48 b9 4e da 60 41 80 	movabs $0x804160da4e,%rcx
  8041604719:	00 00 00 
  804160471c:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041604723:	00 00 00 
  8041604726:	be e0 03 00 00       	mov    $0x3e0,%esi
  804160472b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604732:	00 00 00 
  8041604735:	b8 00 00 00 00       	mov    $0x0,%eax
  804160473a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604741:	00 00 00 
  8041604744:	41 ff d0             	callq  *%r8
  if (!page_free_list)
  8041604747:	48 a1 08 46 70 41 80 	movabs 0x8041704608,%rax
  804160474e:	00 00 00 
  8041604751:	48 85 c0             	test   %rax,%rax
  8041604754:	0f 84 21 fd ff ff    	je     804160447b <check_page_free_list+0xc5>
    struct PageInfo **tp[2] = {&pp1, &pp2};
  804160475a:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  804160475e:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  8041604762:	48 8d 55 d8          	lea    -0x28(%rbp),%rdx
  8041604766:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  return (pp - pages) << PGSHIFT;
  804160476a:	48 be 58 5b 70 41 80 	movabs $0x8041705b58,%rsi
  8041604771:	00 00 00 
  8041604774:	48 89 c2             	mov    %rax,%rdx
  8041604777:	48 2b 16             	sub    (%rsi),%rdx
  804160477a:	48 c1 e2 08          	shl    $0x8,%rdx
      int pagetype  = VPN(page2pa(pp)) >= pdx_limit;
  804160477e:	48 c1 ea 0c          	shr    $0xc,%rdx
      *tp[pagetype] = pp;
  8041604782:	0f 95 c2             	setne  %dl
  8041604785:	0f b6 d2             	movzbl %dl,%edx
  8041604788:	48 8b 4c d5 e0       	mov    -0x20(%rbp,%rdx,8),%rcx
  804160478d:	48 89 01             	mov    %rax,(%rcx)
      tp[pagetype]  = &pp->pp_link;
  8041604790:	48 89 44 d5 e0       	mov    %rax,-0x20(%rbp,%rdx,8)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  8041604795:	48 8b 00             	mov    (%rax),%rax
  8041604798:	48 85 c0             	test   %rax,%rax
  804160479b:	75 d7                	jne    8041604774 <check_page_free_list+0x3be>
    *tp[1]         = 0;
  804160479d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80416047a1:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    *tp[0]         = pp2;
  80416047a8:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  80416047ac:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80416047b0:	48 89 10             	mov    %rdx,(%rax)
    page_free_list = pp1;
  80416047b3:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80416047b7:	48 a3 08 46 70 41 80 	movabs %rax,0x8041704608
  80416047be:	00 00 00 
  80416047c1:	e9 16 fc ff ff       	jmpq   80416043dc <check_page_free_list+0x26>

00000080416047c6 <is_page_allocatable>:
  if (!mmap_base || !mmap_end)
  80416047c6:	48 b8 f0 45 70 41 80 	movabs $0x80417045f0,%rax
  80416047cd:	00 00 00 
  80416047d0:	48 8b 10             	mov    (%rax),%rdx
  80416047d3:	48 85 d2             	test   %rdx,%rdx
  80416047d6:	0f 84 93 00 00 00    	je     804160486f <is_page_allocatable+0xa9>
  80416047dc:	48 b8 e8 45 70 41 80 	movabs $0x80417045e8,%rax
  80416047e3:	00 00 00 
  80416047e6:	48 8b 30             	mov    (%rax),%rsi
  80416047e9:	48 85 f6             	test   %rsi,%rsi
  80416047ec:	0f 84 83 00 00 00    	je     8041604875 <is_page_allocatable+0xaf>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416047f2:	48 39 f2             	cmp    %rsi,%rdx
  80416047f5:	0f 83 80 00 00 00    	jae    804160487b <is_page_allocatable+0xb5>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  80416047fb:	48 8b 42 08          	mov    0x8(%rdx),%rax
  80416047ff:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  8041604803:	48 89 c1             	mov    %rax,%rcx
  8041604806:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  804160480a:	48 39 cf             	cmp    %rcx,%rdi
  804160480d:	73 05                	jae    8041604814 <is_page_allocatable+0x4e>
  804160480f:	48 39 c7             	cmp    %rax,%rdi
  8041604812:	73 34                	jae    8041604848 <is_page_allocatable+0x82>
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041604814:	48 b8 e0 45 70 41 80 	movabs $0x80417045e0,%rax
  804160481b:	00 00 00 
  804160481e:	4c 8b 00             	mov    (%rax),%r8
  8041604821:	4c 01 c2             	add    %r8,%rdx
  8041604824:	48 39 d6             	cmp    %rdx,%rsi
  8041604827:	76 40                	jbe    8041604869 <is_page_allocatable+0xa3>
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
  8041604829:	48 8b 42 08          	mov    0x8(%rdx),%rax
  804160482d:	48 c1 e8 0c          	shr    $0xc,%rax
    pg_end   = pg_start + mmap_curr->NumberOfPages;
  8041604831:	48 89 c1             	mov    %rax,%rcx
  8041604834:	48 03 4a 18          	add    0x18(%rdx),%rcx
    if (pgnum >= pg_start && pgnum < pg_end) {
  8041604838:	48 39 f9             	cmp    %rdi,%rcx
  804160483b:	0f 97 c1             	seta   %cl
  804160483e:	48 39 f8             	cmp    %rdi,%rax
  8041604841:	0f 96 c0             	setbe  %al
  8041604844:	84 c1                	test   %al,%cl
  8041604846:	74 d9                	je     8041604821 <is_page_allocatable+0x5b>
      switch (mmap_curr->Type) {
  8041604848:	8b 0a                	mov    (%rdx),%ecx
  804160484a:	85 c9                	test   %ecx,%ecx
  804160484c:	74 33                	je     8041604881 <is_page_allocatable+0xbb>
  804160484e:	83 f9 04             	cmp    $0x4,%ecx
  8041604851:	76 0a                	jbe    804160485d <is_page_allocatable+0x97>
          return false;
  8041604853:	b8 00 00 00 00       	mov    $0x0,%eax
      switch (mmap_curr->Type) {
  8041604858:	83 f9 07             	cmp    $0x7,%ecx
  804160485b:	75 29                	jne    8041604886 <is_page_allocatable+0xc0>
          if (mmap_curr->Attribute & EFI_MEMORY_WB)
  804160485d:	48 8b 42 20          	mov    0x20(%rdx),%rax
  8041604861:	48 c1 e8 03          	shr    $0x3,%rax
  8041604865:	83 e0 01             	and    $0x1,%eax
  8041604868:	c3                   	retq   
  return true;
  8041604869:	b8 01 00 00 00       	mov    $0x1,%eax
  804160486e:	c3                   	retq   
    return true; //Assume page is allocabale if no loading parameters were passed.
  804160486f:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604874:	c3                   	retq   
  8041604875:	b8 01 00 00 00       	mov    $0x1,%eax
  804160487a:	c3                   	retq   
  return true;
  804160487b:	b8 01 00 00 00       	mov    $0x1,%eax
  8041604880:	c3                   	retq   
          return false;
  8041604881:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041604886:	c3                   	retq   

0000008041604887 <page_init>:
page_init(void) {
  8041604887:	55                   	push   %rbp
  8041604888:	48 89 e5             	mov    %rsp,%rbp
  804160488b:	41 57                	push   %r15
  804160488d:	41 56                	push   %r14
  804160488f:	41 55                	push   %r13
  8041604891:	41 54                	push   %r12
  8041604893:	53                   	push   %rbx
  8041604894:	48 83 ec 08          	sub    $0x8,%rsp
  pages[0].pp_ref  = 1;
  8041604898:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  804160489f:	00 00 00 
  80416048a2:	48 8b 10             	mov    (%rax),%rdx
  80416048a5:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
  pages[0].pp_link = NULL;
  80416048ab:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  pages[1].pp_ref = 0;
  80416048b2:	4c 8b 20             	mov    (%rax),%r12
  80416048b5:	66 41 c7 44 24 18 00 	movw   $0x0,0x18(%r12)
  80416048bc:	00 
  page_free_list  = &pages[1];
  80416048bd:	49 83 c4 10          	add    $0x10,%r12
  80416048c1:	4c 89 e0             	mov    %r12,%rax
  80416048c4:	48 a3 08 46 70 41 80 	movabs %rax,0x8041704608
  80416048cb:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  80416048ce:	48 b8 10 46 70 41 80 	movabs $0x8041704610,%rax
  80416048d5:	00 00 00 
  80416048d8:	48 83 38 01          	cmpq   $0x1,(%rax)
  80416048dc:	76 6a                	jbe    8041604948 <page_init+0xc1>
  80416048de:	bb 01 00 00 00       	mov    $0x1,%ebx
    if (is_page_allocatable(i)) {
  80416048e3:	49 bf c6 47 60 41 80 	movabs $0x80416047c6,%r15
  80416048ea:	00 00 00 
      pages[i].pp_ref  = 1;
  80416048ed:	49 bd 58 5b 70 41 80 	movabs $0x8041705b58,%r13
  80416048f4:	00 00 00 
  for (i = 1; i < npages_basemem; i++) {
  80416048f7:	49 89 c6             	mov    %rax,%r14
  80416048fa:	eb 21                	jmp    804160491d <page_init+0x96>
      pages[i].pp_ref  = 1;
  80416048fc:	48 89 d8             	mov    %rbx,%rax
  80416048ff:	48 c1 e0 04          	shl    $0x4,%rax
  8041604903:	49 03 45 00          	add    0x0(%r13),%rax
  8041604907:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  804160490d:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = 1; i < npages_basemem; i++) {
  8041604914:	48 83 c3 01          	add    $0x1,%rbx
  8041604918:	49 39 1e             	cmp    %rbx,(%r14)
  804160491b:	76 2b                	jbe    8041604948 <page_init+0xc1>
    if (is_page_allocatable(i)) {
  804160491d:	48 89 df             	mov    %rbx,%rdi
  8041604920:	41 ff d7             	callq  *%r15
  8041604923:	84 c0                	test   %al,%al
  8041604925:	74 d5                	je     80416048fc <page_init+0x75>
      pages[i].pp_ref = 0;
  8041604927:	48 89 d8             	mov    %rbx,%rax
  804160492a:	48 c1 e0 04          	shl    $0x4,%rax
  804160492e:	48 89 c2             	mov    %rax,%rdx
  8041604931:	49 03 55 00          	add    0x0(%r13),%rdx
  8041604935:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  804160493b:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  804160493f:	49 03 45 00          	add    0x0(%r13),%rax
  8041604943:	49 89 c4             	mov    %rax,%r12
  8041604946:	eb cc                	jmp    8041604914 <page_init+0x8d>
  first_free_page = PADDR(boot_alloc(0)) / PGSIZE;
  8041604948:	bf 00 00 00 00       	mov    $0x0,%edi
  804160494d:	48 b8 ce 42 60 41 80 	movabs $0x80416042ce,%rax
  8041604954:	00 00 00 
  8041604957:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041604959:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041604960:	00 00 00 
  8041604963:	48 39 d0             	cmp    %rdx,%rax
  8041604966:	76 7d                	jbe    80416049e5 <page_init+0x15e>
  return (physaddr_t)kva - KERNBASE;
  8041604968:	48 bb 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rbx
  804160496f:	ff ff ff 
  8041604972:	48 01 c3             	add    %rax,%rbx
  8041604975:	48 c1 eb 0c          	shr    $0xc,%rbx
  for (i = npages_basemem; i < first_free_page; i++) {
  8041604979:	48 a1 10 46 70 41 80 	movabs 0x8041704610,%rax
  8041604980:	00 00 00 
  8041604983:	48 39 c3             	cmp    %rax,%rbx
  8041604986:	76 31                	jbe    80416049b9 <page_init+0x132>
  8041604988:	48 c1 e0 04          	shl    $0x4,%rax
  804160498c:	48 89 de             	mov    %rbx,%rsi
  804160498f:	48 c1 e6 04          	shl    $0x4,%rsi
    pages[i].pp_ref  = 1;
  8041604993:	48 b9 58 5b 70 41 80 	movabs $0x8041705b58,%rcx
  804160499a:	00 00 00 
  804160499d:	48 89 c2             	mov    %rax,%rdx
  80416049a0:	48 03 11             	add    (%rcx),%rdx
  80416049a3:	66 c7 42 08 01 00    	movw   $0x1,0x8(%rdx)
    pages[i].pp_link = NULL;
  80416049a9:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)
  for (i = npages_basemem; i < first_free_page; i++) {
  80416049b0:	48 83 c0 10          	add    $0x10,%rax
  80416049b4:	48 39 f0             	cmp    %rsi,%rax
  80416049b7:	75 e4                	jne    804160499d <page_init+0x116>
  for (i = first_free_page; i < npages; i++) {
  80416049b9:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  80416049c0:	00 00 00 
  80416049c3:	48 3b 18             	cmp    (%rax),%rbx
  80416049c6:	0f 83 93 00 00 00    	jae    8041604a5f <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  80416049cc:	49 bf c6 47 60 41 80 	movabs $0x80416047c6,%r15
  80416049d3:	00 00 00 
      pages[i].pp_ref  = 1;
  80416049d6:	49 bd 58 5b 70 41 80 	movabs $0x8041705b58,%r13
  80416049dd:	00 00 00 
  for (i = first_free_page; i < npages; i++) {
  80416049e0:	49 89 c6             	mov    %rax,%r14
  80416049e3:	eb 4f                	jmp    8041604a34 <page_init+0x1ad>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416049e5:	48 89 c1             	mov    %rax,%rcx
  80416049e8:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  80416049ef:	00 00 00 
  80416049f2:	be e9 01 00 00       	mov    $0x1e9,%esi
  80416049f7:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416049fe:	00 00 00 
  8041604a01:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604a06:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604a0d:	00 00 00 
  8041604a10:	41 ff d0             	callq  *%r8
      pages[i].pp_ref  = 1;
  8041604a13:	48 89 d8             	mov    %rbx,%rax
  8041604a16:	48 c1 e0 04          	shl    $0x4,%rax
  8041604a1a:	49 03 45 00          	add    0x0(%r13),%rax
  8041604a1e:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
      pages[i].pp_link = NULL;
  8041604a24:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  for (i = first_free_page; i < npages; i++) {
  8041604a2b:	48 83 c3 01          	add    $0x1,%rbx
  8041604a2f:	49 39 1e             	cmp    %rbx,(%r14)
  8041604a32:	76 2b                	jbe    8041604a5f <page_init+0x1d8>
    if (is_page_allocatable(i)) {
  8041604a34:	48 89 df             	mov    %rbx,%rdi
  8041604a37:	41 ff d7             	callq  *%r15
  8041604a3a:	84 c0                	test   %al,%al
  8041604a3c:	74 d5                	je     8041604a13 <page_init+0x18c>
      pages[i].pp_ref = 0;
  8041604a3e:	48 89 d8             	mov    %rbx,%rax
  8041604a41:	48 c1 e0 04          	shl    $0x4,%rax
  8041604a45:	48 89 c2             	mov    %rax,%rdx
  8041604a48:	49 03 55 00          	add    0x0(%r13),%rdx
  8041604a4c:	66 c7 42 08 00 00    	movw   $0x0,0x8(%rdx)
      last->pp_link   = &pages[i];
  8041604a52:	49 89 14 24          	mov    %rdx,(%r12)
      last            = &pages[i];
  8041604a56:	49 03 45 00          	add    0x0(%r13),%rax
  8041604a5a:	49 89 c4             	mov    %rax,%r12
  8041604a5d:	eb cc                	jmp    8041604a2b <page_init+0x1a4>
}
  8041604a5f:	48 83 c4 08          	add    $0x8,%rsp
  8041604a63:	5b                   	pop    %rbx
  8041604a64:	41 5c                	pop    %r12
  8041604a66:	41 5d                	pop    %r13
  8041604a68:	41 5e                	pop    %r14
  8041604a6a:	41 5f                	pop    %r15
  8041604a6c:	5d                   	pop    %rbp
  8041604a6d:	c3                   	retq   

0000008041604a6e <page_alloc>:
page_alloc(int alloc_flags) {
  8041604a6e:	55                   	push   %rbp
  8041604a6f:	48 89 e5             	mov    %rsp,%rbp
  8041604a72:	53                   	push   %rbx
  8041604a73:	48 83 ec 08          	sub    $0x8,%rsp
  if (!page_free_list) {
  8041604a77:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  8041604a7e:	00 00 00 
  8041604a81:	48 8b 18             	mov    (%rax),%rbx
  8041604a84:	48 85 db             	test   %rbx,%rbx
  8041604a87:	74 1f                	je     8041604aa8 <page_alloc+0x3a>
  page_free_list               = page_free_list->pp_link;
  8041604a89:	48 8b 03             	mov    (%rbx),%rax
  8041604a8c:	48 a3 08 46 70 41 80 	movabs %rax,0x8041704608
  8041604a93:	00 00 00 
  return_page->pp_link         = NULL;
  8041604a96:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  if (!page_free_list) {
  8041604a9d:	48 85 c0             	test   %rax,%rax
  8041604aa0:	74 10                	je     8041604ab2 <page_alloc+0x44>
  if (alloc_flags & ALLOC_ZERO) {
  8041604aa2:	40 f6 c7 01          	test   $0x1,%dil
  8041604aa6:	75 1d                	jne    8041604ac5 <page_alloc+0x57>
}
  8041604aa8:	48 89 d8             	mov    %rbx,%rax
  8041604aab:	48 83 c4 08          	add    $0x8,%rsp
  8041604aaf:	5b                   	pop    %rbx
  8041604ab0:	5d                   	pop    %rbp
  8041604ab1:	c3                   	retq   
    page_free_list_top = NULL;
  8041604ab2:	48 b8 00 46 70 41 80 	movabs $0x8041704600,%rax
  8041604ab9:	00 00 00 
  8041604abc:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  8041604ac3:	eb dd                	jmp    8041604aa2 <page_alloc+0x34>
  return (pp - pages) << PGSHIFT;
  8041604ac5:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041604acc:	00 00 00 
  8041604acf:	48 89 df             	mov    %rbx,%rdi
  8041604ad2:	48 2b 38             	sub    (%rax),%rdi
  8041604ad5:	48 c1 ff 04          	sar    $0x4,%rdi
  8041604ad9:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041604add:	48 89 fa             	mov    %rdi,%rdx
  8041604ae0:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041604ae4:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041604aeb:	00 00 00 
  8041604aee:	48 3b 10             	cmp    (%rax),%rdx
  8041604af1:	73 25                	jae    8041604b18 <page_alloc+0xaa>
  return (void *)(pa + KERNBASE);
  8041604af3:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604afa:	00 00 00 
  8041604afd:	48 01 cf             	add    %rcx,%rdi
    memset(page2kva(return_page), 0, PGSIZE);
  8041604b00:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041604b05:	be 00 00 00 00       	mov    $0x0,%esi
  8041604b0a:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041604b11:	00 00 00 
  8041604b14:	ff d0                	callq  *%rax
  8041604b16:	eb 90                	jmp    8041604aa8 <page_alloc+0x3a>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604b18:	48 89 f9             	mov    %rdi,%rcx
  8041604b1b:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604b22:	00 00 00 
  8041604b25:	be 61 00 00 00       	mov    $0x61,%esi
  8041604b2a:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041604b31:	00 00 00 
  8041604b34:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b39:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604b40:	00 00 00 
  8041604b43:	41 ff d0             	callq  *%r8

0000008041604b46 <page_is_allocated>:
  return !pp->pp_link && pp != page_free_list_top;
  8041604b46:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604b4b:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604b4f:	74 01                	je     8041604b52 <page_is_allocated+0xc>
}
  8041604b51:	c3                   	retq   
  return !pp->pp_link && pp != page_free_list_top;
  8041604b52:	48 b8 00 46 70 41 80 	movabs $0x8041704600,%rax
  8041604b59:	00 00 00 
  8041604b5c:	48 39 38             	cmp    %rdi,(%rax)
  8041604b5f:	0f 95 c0             	setne  %al
  8041604b62:	0f b6 c0             	movzbl %al,%eax
  8041604b65:	eb ea                	jmp    8041604b51 <page_is_allocated+0xb>

0000008041604b67 <page_free>:
  if ((pp->pp_ref != 0) || (pp->pp_link != NULL)) {
  8041604b67:	66 83 7f 08 00       	cmpw   $0x0,0x8(%rdi)
  8041604b6c:	75 2a                	jne    8041604b98 <page_free+0x31>
  8041604b6e:	48 83 3f 00          	cmpq   $0x0,(%rdi)
  8041604b72:	75 24                	jne    8041604b98 <page_free+0x31>
  pp->pp_link    = page_free_list;
  8041604b74:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  8041604b7b:	00 00 00 
  8041604b7e:	48 8b 10             	mov    (%rax),%rdx
  8041604b81:	48 89 17             	mov    %rdx,(%rdi)
  page_free_list = pp;
  8041604b84:	48 89 38             	mov    %rdi,(%rax)
  if (!page_free_list_top) {
  8041604b87:	48 b8 00 46 70 41 80 	movabs $0x8041704600,%rax
  8041604b8e:	00 00 00 
  8041604b91:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041604b95:	74 2f                	je     8041604bc6 <page_free+0x5f>
  8041604b97:	c3                   	retq   
page_free(struct PageInfo *pp) {
  8041604b98:	55                   	push   %rbp
  8041604b99:	48 89 e5             	mov    %rsp,%rbp
    panic("page_free: Page cannot be freed!\n");
  8041604b9c:	48 ba b0 d1 60 41 80 	movabs $0x804160d1b0,%rdx
  8041604ba3:	00 00 00 
  8041604ba6:	be 35 02 00 00       	mov    $0x235,%esi
  8041604bab:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604bb2:	00 00 00 
  8041604bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604bba:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041604bc1:	00 00 00 
  8041604bc4:	ff d1                	callq  *%rcx
    page_free_list_top = pp;
  8041604bc6:	48 89 f8             	mov    %rdi,%rax
  8041604bc9:	48 a3 00 46 70 41 80 	movabs %rax,0x8041704600
  8041604bd0:	00 00 00 
}
  8041604bd3:	eb c2                	jmp    8041604b97 <page_free+0x30>

0000008041604bd5 <page_decref>:
  if (--pp->pp_ref == 0)
  8041604bd5:	0f b7 47 08          	movzwl 0x8(%rdi),%eax
  8041604bd9:	83 e8 01             	sub    $0x1,%eax
  8041604bdc:	66 89 47 08          	mov    %ax,0x8(%rdi)
  8041604be0:	66 85 c0             	test   %ax,%ax
  8041604be3:	74 01                	je     8041604be6 <page_decref+0x11>
  8041604be5:	c3                   	retq   
page_decref(struct PageInfo *pp) {
  8041604be6:	55                   	push   %rbp
  8041604be7:	48 89 e5             	mov    %rsp,%rbp
    page_free(pp);
  8041604bea:	48 b8 67 4b 60 41 80 	movabs $0x8041604b67,%rax
  8041604bf1:	00 00 00 
  8041604bf4:	ff d0                	callq  *%rax
}
  8041604bf6:	5d                   	pop    %rbp
  8041604bf7:	c3                   	retq   

0000008041604bf8 <pgdir_walk>:
pgdir_walk(pde_t *pgdir, const void *va, int create) {
  8041604bf8:	55                   	push   %rbp
  8041604bf9:	48 89 e5             	mov    %rsp,%rbp
  8041604bfc:	41 54                	push   %r12
  8041604bfe:	53                   	push   %rbx
  8041604bff:	48 89 f3             	mov    %rsi,%rbx
  if (pgdir[PDX(va)] & PTE_P) {
  8041604c02:	49 89 f4             	mov    %rsi,%r12
  8041604c05:	49 c1 ec 12          	shr    $0x12,%r12
  8041604c09:	41 81 e4 f8 0f 00 00 	and    $0xff8,%r12d
  8041604c10:	49 01 fc             	add    %rdi,%r12
  8041604c13:	49 8b 0c 24          	mov    (%r12),%rcx
  8041604c17:	f6 c1 01             	test   $0x1,%cl
  8041604c1a:	74 68                	je     8041604c84 <pgdir_walk+0x8c>
		return (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
  8041604c1c:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604c23:	48 89 c8             	mov    %rcx,%rax
  8041604c26:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604c2a:	48 ba 50 5b 70 41 80 	movabs $0x8041705b50,%rdx
  8041604c31:	00 00 00 
  8041604c34:	48 39 02             	cmp    %rax,(%rdx)
  8041604c37:	76 20                	jbe    8041604c59 <pgdir_walk+0x61>
  return (void *)(pa + KERNBASE);
  8041604c39:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041604c40:	00 00 00 
  8041604c43:	48 01 c1             	add    %rax,%rcx
  8041604c46:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604c4a:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604c50:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
}
  8041604c54:	5b                   	pop    %rbx
  8041604c55:	41 5c                	pop    %r12
  8041604c57:	5d                   	pop    %rbp
  8041604c58:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604c59:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604c60:	00 00 00 
  8041604c63:	be 8c 02 00 00       	mov    $0x28c,%esi
  8041604c68:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604c6f:	00 00 00 
  8041604c72:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604c77:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604c7e:	00 00 00 
  8041604c81:	41 ff d0             	callq  *%r8
	if (create) {
  8041604c84:	85 d2                	test   %edx,%edx
  8041604c86:	0f 84 aa 00 00 00    	je     8041604d36 <pgdir_walk+0x13e>
    np = page_alloc(ALLOC_ZERO);
  8041604c8c:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604c91:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041604c98:	00 00 00 
  8041604c9b:	ff d0                	callq  *%rax
    if (np) {
  8041604c9d:	48 85 c0             	test   %rax,%rax
  8041604ca0:	74 b2                	je     8041604c54 <pgdir_walk+0x5c>
        np->pp_ref++;
  8041604ca2:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604ca7:	48 b9 58 5b 70 41 80 	movabs $0x8041705b58,%rcx
  8041604cae:	00 00 00 
  8041604cb1:	48 89 c2             	mov    %rax,%rdx
  8041604cb4:	48 2b 11             	sub    (%rcx),%rdx
  8041604cb7:	48 c1 fa 04          	sar    $0x4,%rdx
  8041604cbb:	48 c1 e2 0c          	shl    $0xc,%rdx
        pgdir[PDX(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604cbf:	48 83 ca 07          	or     $0x7,%rdx
  8041604cc3:	49 89 14 24          	mov    %rdx,(%r12)
  8041604cc7:	48 2b 01             	sub    (%rcx),%rax
  8041604cca:	48 c1 f8 04          	sar    $0x4,%rax
  8041604cce:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  8041604cd2:	48 89 c1             	mov    %rax,%rcx
  8041604cd5:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604cd9:	48 ba 50 5b 70 41 80 	movabs $0x8041705b50,%rdx
  8041604ce0:	00 00 00 
  8041604ce3:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604ce6:	73 20                	jae    8041604d08 <pgdir_walk+0x110>
  return (void *)(pa + KERNBASE);
  8041604ce8:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041604cef:	00 00 00 
  8041604cf2:	48 01 c1             	add    %rax,%rcx
        return (pte_t *) page2kva(np) + PTX(va);
  8041604cf5:	48 c1 eb 09          	shr    $0x9,%rbx
  8041604cf9:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041604cff:	48 8d 04 19          	lea    (%rcx,%rbx,1),%rax
  8041604d03:	e9 4c ff ff ff       	jmpq   8041604c54 <pgdir_walk+0x5c>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604d08:	48 89 c1             	mov    %rax,%rcx
  8041604d0b:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604d12:	00 00 00 
  8041604d15:	be 61 00 00 00       	mov    $0x61,%esi
  8041604d1a:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041604d21:	00 00 00 
  8041604d24:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d29:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604d30:	00 00 00 
  8041604d33:	41 ff d0             	callq  *%r8
	return NULL;
  8041604d36:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d3b:	e9 14 ff ff ff       	jmpq   8041604c54 <pgdir_walk+0x5c>

0000008041604d40 <pdpe_walk>:
pdpe_walk(pdpe_t *pdpe, const void *va, int create) {
  8041604d40:	55                   	push   %rbp
  8041604d41:	48 89 e5             	mov    %rsp,%rbp
  8041604d44:	41 55                	push   %r13
  8041604d46:	41 54                	push   %r12
  8041604d48:	53                   	push   %rbx
  8041604d49:	48 83 ec 08          	sub    $0x8,%rsp
  8041604d4d:	48 89 f3             	mov    %rsi,%rbx
  8041604d50:	41 89 d4             	mov    %edx,%r12d
  if (pdpe[PDPE(va)] & PTE_P) {
  8041604d53:	49 89 f5             	mov    %rsi,%r13
  8041604d56:	49 c1 ed 1b          	shr    $0x1b,%r13
  8041604d5a:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604d61:	49 01 fd             	add    %rdi,%r13
  8041604d64:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604d68:	f6 c1 01             	test   $0x1,%cl
  8041604d6b:	74 6f                	je     8041604ddc <pdpe_walk+0x9c>
		return pgdir_walk((pte_t *) KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604d6d:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604d74:	48 89 c8             	mov    %rcx,%rax
  8041604d77:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604d7b:	48 ba 50 5b 70 41 80 	movabs $0x8041705b50,%rdx
  8041604d82:	00 00 00 
  8041604d85:	48 39 02             	cmp    %rax,(%rdx)
  8041604d88:	76 27                	jbe    8041604db1 <pdpe_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604d8a:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604d91:	00 00 00 
  8041604d94:	48 01 cf             	add    %rcx,%rdi
  8041604d97:	44 89 e2             	mov    %r12d,%edx
  8041604d9a:	48 b8 f8 4b 60 41 80 	movabs $0x8041604bf8,%rax
  8041604da1:	00 00 00 
  8041604da4:	ff d0                	callq  *%rax
}
  8041604da6:	48 83 c4 08          	add    $0x8,%rsp
  8041604daa:	5b                   	pop    %rbx
  8041604dab:	41 5c                	pop    %r12
  8041604dad:	41 5d                	pop    %r13
  8041604daf:	5d                   	pop    %rbp
  8041604db0:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604db1:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604db8:	00 00 00 
  8041604dbb:	be 77 02 00 00       	mov    $0x277,%esi
  8041604dc0:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604dc7:	00 00 00 
  8041604dca:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604dcf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604dd6:	00 00 00 
  8041604dd9:	41 ff d0             	callq  *%r8
	if (create) {
  8041604ddc:	85 d2                	test   %edx,%edx
  8041604dde:	0f 84 a3 00 00 00    	je     8041604e87 <pdpe_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604de4:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604de9:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041604df0:	00 00 00 
  8041604df3:	ff d0                	callq  *%rax
    if (np) {
  8041604df5:	48 85 c0             	test   %rax,%rax
  8041604df8:	74 ac                	je     8041604da6 <pdpe_walk+0x66>
      np->pp_ref++;
  8041604dfa:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604dff:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  8041604e06:	00 00 00 
  8041604e09:	48 2b 02             	sub    (%rdx),%rax
  8041604e0c:	48 c1 f8 04          	sar    $0x4,%rax
  8041604e10:	48 c1 e0 0c          	shl    $0xc,%rax
      pdpe[PDPE(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604e14:	48 89 c2             	mov    %rax,%rdx
  8041604e17:	48 83 ca 07          	or     $0x7,%rdx
  8041604e1b:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604e1f:	48 89 c1             	mov    %rax,%rcx
  8041604e22:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604e26:	48 ba 50 5b 70 41 80 	movabs $0x8041705b50,%rdx
  8041604e2d:	00 00 00 
  8041604e30:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604e33:	73 24                	jae    8041604e59 <pdpe_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604e35:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604e3c:	00 00 00 
  8041604e3f:	48 01 c7             	add    %rax,%rdi
      return pgdir_walk((pte_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
  8041604e42:	44 89 e2             	mov    %r12d,%edx
  8041604e45:	48 89 de             	mov    %rbx,%rsi
  8041604e48:	48 b8 f8 4b 60 41 80 	movabs $0x8041604bf8,%rax
  8041604e4f:	00 00 00 
  8041604e52:	ff d0                	callq  *%rax
  8041604e54:	e9 4d ff ff ff       	jmpq   8041604da6 <pdpe_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604e59:	48 89 c1             	mov    %rax,%rcx
  8041604e5c:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604e63:	00 00 00 
  8041604e66:	be 7f 02 00 00       	mov    $0x27f,%esi
  8041604e6b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604e72:	00 00 00 
  8041604e75:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e7a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604e81:	00 00 00 
  8041604e84:	41 ff d0             	callq  *%r8
	return NULL;
  8041604e87:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604e8c:	e9 15 ff ff ff       	jmpq   8041604da6 <pdpe_walk+0x66>

0000008041604e91 <pml4e_walk>:
pml4e_walk(pml4e_t *pml4e, const void *va, int create) {
  8041604e91:	55                   	push   %rbp
  8041604e92:	48 89 e5             	mov    %rsp,%rbp
  8041604e95:	41 55                	push   %r13
  8041604e97:	41 54                	push   %r12
  8041604e99:	53                   	push   %rbx
  8041604e9a:	48 83 ec 08          	sub    $0x8,%rsp
  8041604e9e:	48 89 f3             	mov    %rsi,%rbx
  8041604ea1:	41 89 d4             	mov    %edx,%r12d
  if (pml4e[PML4(va)] & PTE_P) {
  8041604ea4:	49 89 f5             	mov    %rsi,%r13
  8041604ea7:	49 c1 ed 24          	shr    $0x24,%r13
  8041604eab:	41 81 e5 f8 0f 00 00 	and    $0xff8,%r13d
  8041604eb2:	49 01 fd             	add    %rdi,%r13
  8041604eb5:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  8041604eb9:	f6 c1 01             	test   $0x1,%cl
  8041604ebc:	74 6f                	je     8041604f2d <pml4e_walk+0x9c>
		return pdpe_walk((pdpe_t *) KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604ebe:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041604ec5:	48 89 c8             	mov    %rcx,%rax
  8041604ec8:	48 c1 e8 0c          	shr    $0xc,%rax
  8041604ecc:	48 ba 50 5b 70 41 80 	movabs $0x8041705b50,%rdx
  8041604ed3:	00 00 00 
  8041604ed6:	48 39 02             	cmp    %rax,(%rdx)
  8041604ed9:	76 27                	jbe    8041604f02 <pml4e_walk+0x71>
  return (void *)(pa + KERNBASE);
  8041604edb:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604ee2:	00 00 00 
  8041604ee5:	48 01 cf             	add    %rcx,%rdi
  8041604ee8:	44 89 e2             	mov    %r12d,%edx
  8041604eeb:	48 b8 40 4d 60 41 80 	movabs $0x8041604d40,%rax
  8041604ef2:	00 00 00 
  8041604ef5:	ff d0                	callq  *%rax
}
  8041604ef7:	48 83 c4 08          	add    $0x8,%rsp
  8041604efb:	5b                   	pop    %rbx
  8041604efc:	41 5c                	pop    %r12
  8041604efe:	41 5d                	pop    %r13
  8041604f00:	5d                   	pop    %rbp
  8041604f01:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604f02:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604f09:	00 00 00 
  8041604f0c:	be 62 02 00 00       	mov    $0x262,%esi
  8041604f11:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604f18:	00 00 00 
  8041604f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f20:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604f27:	00 00 00 
  8041604f2a:	41 ff d0             	callq  *%r8
	if (create) {
  8041604f2d:	85 d2                	test   %edx,%edx
  8041604f2f:	0f 84 a3 00 00 00    	je     8041604fd8 <pml4e_walk+0x147>
    np = page_alloc(ALLOC_ZERO);
  8041604f35:	bf 01 00 00 00       	mov    $0x1,%edi
  8041604f3a:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041604f41:	00 00 00 
  8041604f44:	ff d0                	callq  *%rax
    if (np) {
  8041604f46:	48 85 c0             	test   %rax,%rax
  8041604f49:	74 ac                	je     8041604ef7 <pml4e_walk+0x66>
      np->pp_ref++;
  8041604f4b:	66 83 40 08 01       	addw   $0x1,0x8(%rax)
  return (pp - pages) << PGSHIFT;
  8041604f50:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  8041604f57:	00 00 00 
  8041604f5a:	48 2b 02             	sub    (%rdx),%rax
  8041604f5d:	48 c1 f8 04          	sar    $0x4,%rax
  8041604f61:	48 c1 e0 0c          	shl    $0xc,%rax
      pml4e[PML4(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
  8041604f65:	48 89 c2             	mov    %rax,%rdx
  8041604f68:	48 83 ca 07          	or     $0x7,%rdx
  8041604f6c:	49 89 55 00          	mov    %rdx,0x0(%r13)
  if (PGNUM(pa) >= npages)
  8041604f70:	48 89 c1             	mov    %rax,%rcx
  8041604f73:	48 c1 e9 0c          	shr    $0xc,%rcx
  8041604f77:	48 ba 50 5b 70 41 80 	movabs $0x8041705b50,%rdx
  8041604f7e:	00 00 00 
  8041604f81:	48 3b 0a             	cmp    (%rdx),%rcx
  8041604f84:	73 24                	jae    8041604faa <pml4e_walk+0x119>
  return (void *)(pa + KERNBASE);
  8041604f86:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041604f8d:	00 00 00 
  8041604f90:	48 01 c7             	add    %rax,%rdi
      return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
  8041604f93:	44 89 e2             	mov    %r12d,%edx
  8041604f96:	48 89 de             	mov    %rbx,%rsi
  8041604f99:	48 b8 40 4d 60 41 80 	movabs $0x8041604d40,%rax
  8041604fa0:	00 00 00 
  8041604fa3:	ff d0                	callq  *%rax
  8041604fa5:	e9 4d ff ff ff       	jmpq   8041604ef7 <pml4e_walk+0x66>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041604faa:	48 89 c1             	mov    %rax,%rcx
  8041604fad:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041604fb4:	00 00 00 
  8041604fb7:	be 6a 02 00 00       	mov    $0x26a,%esi
  8041604fbc:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041604fc3:	00 00 00 
  8041604fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fcb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041604fd2:	00 00 00 
  8041604fd5:	41 ff d0             	callq  *%r8
	return NULL;
  8041604fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fdd:	e9 15 ff ff ff       	jmpq   8041604ef7 <pml4e_walk+0x66>

0000008041604fe2 <boot_map_region>:
  for (i = 0; i < size; i += PGSIZE) {
  8041604fe2:	48 85 d2             	test   %rdx,%rdx
  8041604fe5:	74 72                	je     8041605059 <boot_map_region+0x77>
boot_map_region(pml4e_t *pml4e, uintptr_t va, size_t size, physaddr_t pa, int perm) {
  8041604fe7:	55                   	push   %rbp
  8041604fe8:	48 89 e5             	mov    %rsp,%rbp
  8041604feb:	41 57                	push   %r15
  8041604fed:	41 56                	push   %r14
  8041604fef:	41 55                	push   %r13
  8041604ff1:	41 54                	push   %r12
  8041604ff3:	53                   	push   %rbx
  8041604ff4:	48 83 ec 28          	sub    $0x28,%rsp
  8041604ff8:	44 89 45 bc          	mov    %r8d,-0x44(%rbp)
  8041604ffc:	49 89 ce             	mov    %rcx,%r14
  8041604fff:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8041605003:	49 89 f5             	mov    %rsi,%r13
  8041605006:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  for (i = 0; i < size; i += PGSIZE) {
  804160500a:	41 bc 00 00 00 00    	mov    $0x0,%r12d
		*pml4e_walk(pml4e, (void *)(va + i), 1) = (pa + i) | perm | PTE_P;
  8041605010:	49 bf 91 4e 60 41 80 	movabs $0x8041604e91,%r15
  8041605017:	00 00 00 
  804160501a:	4b 8d 1c 26          	lea    (%r14,%r12,1),%rbx
  804160501e:	48 63 45 bc          	movslq -0x44(%rbp),%rax
  8041605022:	48 09 c3             	or     %rax,%rbx
  8041605025:	4b 8d 74 25 00       	lea    0x0(%r13,%r12,1),%rsi
  804160502a:	ba 01 00 00 00       	mov    $0x1,%edx
  804160502f:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041605033:	41 ff d7             	callq  *%r15
  8041605036:	48 83 cb 01          	or     $0x1,%rbx
  804160503a:	48 89 18             	mov    %rbx,(%rax)
  for (i = 0; i < size; i += PGSIZE) {
  804160503d:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041605044:	4c 39 65 c0          	cmp    %r12,-0x40(%rbp)
  8041605048:	77 d0                	ja     804160501a <boot_map_region+0x38>
}
  804160504a:	48 83 c4 28          	add    $0x28,%rsp
  804160504e:	5b                   	pop    %rbx
  804160504f:	41 5c                	pop    %r12
  8041605051:	41 5d                	pop    %r13
  8041605053:	41 5e                	pop    %r14
  8041605055:	41 5f                	pop    %r15
  8041605057:	5d                   	pop    %rbp
  8041605058:	c3                   	retq   
  8041605059:	c3                   	retq   

000000804160505a <page_lookup>:
page_lookup(pml4e_t *pml4e, void *va, pte_t **pte_store) {
  804160505a:	55                   	push   %rbp
  804160505b:	48 89 e5             	mov    %rsp,%rbp
  804160505e:	53                   	push   %rbx
  804160505f:	48 83 ec 08          	sub    $0x8,%rsp
  8041605063:	48 89 d3             	mov    %rdx,%rbx
	ptep = pml4e_walk(pml4e, va, 0);
  8041605066:	ba 00 00 00 00       	mov    $0x0,%edx
  804160506b:	48 b8 91 4e 60 41 80 	movabs $0x8041604e91,%rax
  8041605072:	00 00 00 
  8041605075:	ff d0                	callq  *%rax
	if (!ptep) {
  8041605077:	48 85 c0             	test   %rax,%rax
  804160507a:	74 3c                	je     80416050b8 <page_lookup+0x5e>
	if (pte_store) {
  804160507c:	48 85 db             	test   %rbx,%rbx
  804160507f:	74 03                	je     8041605084 <page_lookup+0x2a>
		*pte_store = ptep;
  8041605081:	48 89 03             	mov    %rax,(%rbx)
	return pa2page(PTE_ADDR(*ptep));
  8041605084:	48 8b 30             	mov    (%rax),%rsi
  8041605087:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
}

static inline struct PageInfo *
pa2page(physaddr_t pa) {
  if (PPN(pa) >= npages) {
  804160508e:	48 89 f0             	mov    %rsi,%rax
  8041605091:	48 c1 e8 0c          	shr    $0xc,%rax
  8041605095:	48 ba 50 5b 70 41 80 	movabs $0x8041705b50,%rdx
  804160509c:	00 00 00 
  804160509f:	48 3b 02             	cmp    (%rdx),%rax
  80416050a2:	73 1b                	jae    80416050bf <page_lookup+0x65>
    cprintf("accessing %lx\n", (unsigned long)pa);
    panic("pa2page called with invalid pa");
  }
  return &pages[PPN(pa)];
  80416050a4:	48 c1 e0 04          	shl    $0x4,%rax
  80416050a8:	48 b9 58 5b 70 41 80 	movabs $0x8041705b58,%rcx
  80416050af:	00 00 00 
  80416050b2:	48 8b 11             	mov    (%rcx),%rdx
  80416050b5:	48 01 d0             	add    %rdx,%rax
}
  80416050b8:	48 83 c4 08          	add    $0x8,%rsp
  80416050bc:	5b                   	pop    %rbx
  80416050bd:	5d                   	pop    %rbp
  80416050be:	c3                   	retq   
    cprintf("accessing %lx\n", (unsigned long)pa);
  80416050bf:	48 bf 5f da 60 41 80 	movabs $0x804160da5f,%rdi
  80416050c6:	00 00 00 
  80416050c9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050ce:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416050d5:	00 00 00 
  80416050d8:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  80416050da:	48 ba d8 d1 60 41 80 	movabs $0x804160d1d8,%rdx
  80416050e1:	00 00 00 
  80416050e4:	be 5a 00 00 00       	mov    $0x5a,%esi
  80416050e9:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  80416050f0:	00 00 00 
  80416050f3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050f8:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416050ff:	00 00 00 
  8041605102:	ff d1                	callq  *%rcx

0000008041605104 <tlb_invalidate>:
  if (!curenv || curenv->env_pml4e == pml4e)
  8041605104:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  804160510b:	00 00 00 
  804160510e:	48 85 c0             	test   %rax,%rax
  8041605111:	74 09                	je     804160511c <tlb_invalidate+0x18>
  8041605113:	48 39 b8 e8 00 00 00 	cmp    %rdi,0xe8(%rax)
  804160511a:	75 03                	jne    804160511f <tlb_invalidate+0x1b>
  __asm __volatile("invlpg (%0)"
  804160511c:	0f 01 3e             	invlpg (%rsi)
}
  804160511f:	c3                   	retq   

0000008041605120 <page_remove>:
page_remove(pml4e_t *pml4e, void *va) {
  8041605120:	55                   	push   %rbp
  8041605121:	48 89 e5             	mov    %rsp,%rbp
  8041605124:	41 54                	push   %r12
  8041605126:	53                   	push   %rbx
  8041605127:	48 83 ec 10          	sub    $0x10,%rsp
  804160512b:	48 89 fb             	mov    %rdi,%rbx
  804160512e:	49 89 f4             	mov    %rsi,%r12
	pp = page_lookup(pml4e, va, &ptep);
  8041605131:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
  8041605135:	48 b8 5a 50 60 41 80 	movabs $0x804160505a,%rax
  804160513c:	00 00 00 
  804160513f:	ff d0                	callq  *%rax
	if (pp) {
  8041605141:	48 85 c0             	test   %rax,%rax
  8041605144:	74 2c                	je     8041605172 <page_remove+0x52>
    page_decref(pp);
  8041605146:	48 89 c7             	mov    %rax,%rdi
  8041605149:	48 b8 d5 4b 60 41 80 	movabs $0x8041604bd5,%rax
  8041605150:	00 00 00 
  8041605153:	ff d0                	callq  *%rax
    *ptep = 0;
  8041605155:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8041605159:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    tlb_invalidate(pml4e, va);
  8041605160:	4c 89 e6             	mov    %r12,%rsi
  8041605163:	48 89 df             	mov    %rbx,%rdi
  8041605166:	48 b8 04 51 60 41 80 	movabs $0x8041605104,%rax
  804160516d:	00 00 00 
  8041605170:	ff d0                	callq  *%rax
}
  8041605172:	48 83 c4 10          	add    $0x10,%rsp
  8041605176:	5b                   	pop    %rbx
  8041605177:	41 5c                	pop    %r12
  8041605179:	5d                   	pop    %rbp
  804160517a:	c3                   	retq   

000000804160517b <page_insert>:
page_insert(pml4e_t *pml4e, struct PageInfo *pp, void *va, int perm) {
  804160517b:	55                   	push   %rbp
  804160517c:	48 89 e5             	mov    %rsp,%rbp
  804160517f:	41 57                	push   %r15
  8041605181:	41 56                	push   %r14
  8041605183:	41 55                	push   %r13
  8041605185:	41 54                	push   %r12
  8041605187:	53                   	push   %rbx
  8041605188:	48 83 ec 08          	sub    $0x8,%rsp
  804160518c:	49 89 fe             	mov    %rdi,%r14
  804160518f:	49 89 f4             	mov    %rsi,%r12
  8041605192:	49 89 d7             	mov    %rdx,%r15
  8041605195:	41 89 cd             	mov    %ecx,%r13d
	ptep = pml4e_walk(pml4e, va, 1);
  8041605198:	ba 01 00 00 00       	mov    $0x1,%edx
  804160519d:	4c 89 fe             	mov    %r15,%rsi
  80416051a0:	48 b8 91 4e 60 41 80 	movabs $0x8041604e91,%rax
  80416051a7:	00 00 00 
  80416051aa:	ff d0                	callq  *%rax
	if (ptep == 0) {
  80416051ac:	48 85 c0             	test   %rax,%rax
  80416051af:	0f 84 f0 00 00 00    	je     80416052a5 <page_insert+0x12a>
  80416051b5:	48 89 c3             	mov    %rax,%rbx
	if (*ptep & PTE_P) {
  80416051b8:	48 8b 08             	mov    (%rax),%rcx
  80416051bb:	f6 c1 01             	test   $0x1,%cl
  80416051be:	0f 84 a1 00 00 00    	je     8041605265 <page_insert+0xea>
		if (PTE_ADDR(*ptep) == page2pa(pp)) {
  80416051c4:	48 89 ca             	mov    %rcx,%rdx
  80416051c7:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  80416051ce:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  80416051d5:	00 00 00 
  80416051d8:	4c 89 e6             	mov    %r12,%rsi
  80416051db:	48 2b 30             	sub    (%rax),%rsi
  80416051de:	48 89 f0             	mov    %rsi,%rax
  80416051e1:	48 c1 f8 04          	sar    $0x4,%rax
  80416051e5:	48 c1 e0 0c          	shl    $0xc,%rax
  80416051e9:	48 39 c2             	cmp    %rax,%rdx
  80416051ec:	75 1d                	jne    804160520b <page_insert+0x90>
      *ptep = (*ptep & 0xfffff000) | perm | PTE_P;
  80416051ee:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  80416051f4:	4d 63 ed             	movslq %r13d,%r13
  80416051f7:	4c 09 e9             	or     %r13,%rcx
  80416051fa:	48 83 c9 01          	or     $0x1,%rcx
  80416051fe:	48 89 0b             	mov    %rcx,(%rbx)
  return 0;
  8041605201:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605206:	e9 8b 00 00 00       	jmpq   8041605296 <page_insert+0x11b>
			page_remove(pml4e, va);
  804160520b:	4c 89 fe             	mov    %r15,%rsi
  804160520e:	4c 89 f7             	mov    %r14,%rdi
  8041605211:	48 b8 20 51 60 41 80 	movabs $0x8041605120,%rax
  8041605218:	00 00 00 
  804160521b:	ff d0                	callq  *%rax
  804160521d:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041605224:	00 00 00 
  8041605227:	4c 89 e7             	mov    %r12,%rdi
  804160522a:	48 2b 38             	sub    (%rax),%rdi
  804160522d:	48 89 f8             	mov    %rdi,%rax
  8041605230:	48 c1 f8 04          	sar    $0x4,%rax
  8041605234:	48 c1 e0 0c          	shl    $0xc,%rax
			*ptep = page2pa(pp) | perm | PTE_P;
  8041605238:	4d 63 ed             	movslq %r13d,%r13
  804160523b:	49 09 c5             	or     %rax,%r13
  804160523e:	49 83 cd 01          	or     $0x1,%r13
  8041605242:	4c 89 2b             	mov    %r13,(%rbx)
			pp->pp_ref++;
  8041605245:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
			tlb_invalidate(pml4e, va);
  804160524c:	4c 89 fe             	mov    %r15,%rsi
  804160524f:	4c 89 f7             	mov    %r14,%rdi
  8041605252:	48 b8 04 51 60 41 80 	movabs $0x8041605104,%rax
  8041605259:	00 00 00 
  804160525c:	ff d0                	callq  *%rax
  return 0;
  804160525e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605263:	eb 31                	jmp    8041605296 <page_insert+0x11b>
  8041605265:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  804160526c:	00 00 00 
  804160526f:	4c 89 e1             	mov    %r12,%rcx
  8041605272:	48 2b 08             	sub    (%rax),%rcx
  8041605275:	48 c1 f9 04          	sar    $0x4,%rcx
  8041605279:	48 c1 e1 0c          	shl    $0xc,%rcx
		*ptep = page2pa(pp) | perm | PTE_P;
  804160527d:	4d 63 ed             	movslq %r13d,%r13
  8041605280:	4c 09 e9             	or     %r13,%rcx
  8041605283:	48 83 c9 01          	or     $0x1,%rcx
  8041605287:	48 89 0b             	mov    %rcx,(%rbx)
		pp->pp_ref++;
  804160528a:	66 41 83 44 24 08 01 	addw   $0x1,0x8(%r12)
  return 0;
  8041605291:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041605296:	48 83 c4 08          	add    $0x8,%rsp
  804160529a:	5b                   	pop    %rbx
  804160529b:	41 5c                	pop    %r12
  804160529d:	41 5d                	pop    %r13
  804160529f:	41 5e                	pop    %r14
  80416052a1:	41 5f                	pop    %r15
  80416052a3:	5d                   	pop    %rbp
  80416052a4:	c3                   	retq   
		return -E_NO_MEM;
  80416052a5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  80416052aa:	eb ea                	jmp    8041605296 <page_insert+0x11b>

00000080416052ac <mem_init>:
mem_init(void) {
  80416052ac:	55                   	push   %rbp
  80416052ad:	48 89 e5             	mov    %rsp,%rbp
  80416052b0:	41 57                	push   %r15
  80416052b2:	41 56                	push   %r14
  80416052b4:	41 55                	push   %r13
  80416052b6:	41 54                	push   %r12
  80416052b8:	53                   	push   %rbx
  80416052b9:	48 83 ec 38          	sub    $0x38,%rsp
  if (uefi_lp && uefi_lp->MemoryMap) {
  80416052bd:	48 a1 00 f0 61 41 80 	movabs 0x804161f000,%rax
  80416052c4:	00 00 00 
  80416052c7:	48 85 c0             	test   %rax,%rax
  80416052ca:	74 0d                	je     80416052d9 <mem_init+0x2d>
  80416052cc:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80416052d0:	48 85 ff             	test   %rdi,%rdi
  80416052d3:	0f 85 5a 11 00 00    	jne    8041606433 <mem_init+0x1187>
    npages_basemem = (mc146818_read16(NVRAM_BASELO) * 1024) / PGSIZE;
  80416052d9:	bf 15 00 00 00       	mov    $0x15,%edi
  80416052de:	49 bc 73 90 60 41 80 	movabs $0x8041609073,%r12
  80416052e5:	00 00 00 
  80416052e8:	41 ff d4             	callq  *%r12
  80416052eb:	c1 e0 0a             	shl    $0xa,%eax
  80416052ee:	c1 e8 0c             	shr    $0xc,%eax
  80416052f1:	48 ba 10 46 70 41 80 	movabs $0x8041704610,%rdx
  80416052f8:	00 00 00 
  80416052fb:	89 c0                	mov    %eax,%eax
  80416052fd:	48 89 02             	mov    %rax,(%rdx)
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  8041605300:	bf 17 00 00 00       	mov    $0x17,%edi
  8041605305:	41 ff d4             	callq  *%r12
  8041605308:	89 c3                	mov    %eax,%ebx
    pextmem        = ((size_t)mc146818_read16(NVRAM_PEXTLO) * 1024 * 64);
  804160530a:	bf 34 00 00 00       	mov    $0x34,%edi
  804160530f:	41 ff d4             	callq  *%r12
  8041605312:	89 c0                	mov    %eax,%eax
    if (pextmem)
  8041605314:	48 c1 e0 10          	shl    $0x10,%rax
  8041605318:	0f 84 8c 11 00 00    	je     80416064aa <mem_init+0x11fe>
      npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  804160531e:	48 05 00 00 f0 00    	add    $0xf00000,%rax
  8041605324:	48 c1 e8 0c          	shr    $0xc,%rax
  8041605328:	48 89 c3             	mov    %rax,%rbx
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  804160532b:	48 8d b3 00 01 00 00 	lea    0x100(%rbx),%rsi
  8041605332:	48 89 f0             	mov    %rsi,%rax
  8041605335:	48 a3 50 5b 70 41 80 	movabs %rax,0x8041705b50
  804160533c:	00 00 00 
          (unsigned long)(npages_extmem * PGSIZE / 1024));
  804160533f:	48 89 d8             	mov    %rbx,%rax
  8041605342:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605346:	48 c1 e8 0a          	shr    $0xa,%rax
  804160534a:	48 89 c1             	mov    %rax,%rcx
          (unsigned long)(npages_basemem * PGSIZE / 1024),
  804160534d:	48 b8 10 46 70 41 80 	movabs $0x8041704610,%rax
  8041605354:	00 00 00 
  8041605357:	48 8b 10             	mov    (%rax),%rdx
  804160535a:	48 c1 e2 0c          	shl    $0xc,%rdx
  804160535e:	48 c1 ea 0a          	shr    $0xa,%rdx
          (unsigned long)(npages * PGSIZE / 1024 / 1024),
  8041605362:	48 c1 e6 0c          	shl    $0xc,%rsi
  8041605366:	48 c1 ee 14          	shr    $0x14,%rsi
  cprintf("Physical memory: %luM available, base = %luK, extended = %luK\n",
  804160536a:	48 bf f8 d1 60 41 80 	movabs $0x804160d1f8,%rdi
  8041605371:	00 00 00 
  8041605374:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605379:	49 b8 78 92 60 41 80 	movabs $0x8041609278,%r8
  8041605380:	00 00 00 
  8041605383:	41 ff d0             	callq  *%r8
  pml4e = boot_alloc(PGSIZE);
  8041605386:	bf 00 10 00 00       	mov    $0x1000,%edi
  804160538b:	48 b8 ce 42 60 41 80 	movabs $0x80416042ce,%rax
  8041605392:	00 00 00 
  8041605395:	ff d0                	callq  *%rax
  8041605397:	48 89 c3             	mov    %rax,%rbx
  memset(pml4e, 0, PGSIZE);
  804160539a:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160539f:	be 00 00 00 00       	mov    $0x0,%esi
  80416053a4:	48 89 c7             	mov    %rax,%rdi
  80416053a7:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  80416053ae:	00 00 00 
  80416053b1:	ff d0                	callq  *%rax
  kern_pml4e = pml4e;
  80416053b3:	48 89 d8             	mov    %rbx,%rax
  80416053b6:	48 a3 40 5b 70 41 80 	movabs %rax,0x8041705b40
  80416053bd:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  80416053c0:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  80416053c7:	00 00 00 
  80416053ca:	48 39 c3             	cmp    %rax,%rbx
  80416053cd:	0f 86 fa 10 00 00    	jbe    80416064cd <mem_init+0x1221>
  return (physaddr_t)kva - KERNBASE;
  80416053d3:	48 b8 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rax
  80416053da:	ff ff ff 
  80416053dd:	48 01 d8             	add    %rbx,%rax
  kern_cr3   = PADDR(pml4e);
  80416053e0:	48 a3 48 5b 70 41 80 	movabs %rax,0x8041705b48
  80416053e7:	00 00 00 
  kern_pml4e[PML4(UVPT)] = kern_cr3 | PTE_P | PTE_U;
  80416053ea:	48 83 c8 05          	or     $0x5,%rax
  80416053ee:	48 89 43 10          	mov    %rax,0x10(%rbx)
  pages = (struct PageInfo *)boot_alloc(sizeof(* pages) * npages);
  80416053f2:	48 bb 50 5b 70 41 80 	movabs $0x8041705b50,%rbx
  80416053f9:	00 00 00 
  80416053fc:	8b 3b                	mov    (%rbx),%edi
  80416053fe:	c1 e7 04             	shl    $0x4,%edi
  8041605401:	49 bd ce 42 60 41 80 	movabs $0x80416042ce,%r13
  8041605408:	00 00 00 
  804160540b:	41 ff d5             	callq  *%r13
  804160540e:	49 bc 58 5b 70 41 80 	movabs $0x8041705b58,%r12
  8041605415:	00 00 00 
  8041605418:	49 89 04 24          	mov    %rax,(%r12)
	memset(pages, 0, sizeof(*pages) * npages);
  804160541c:	48 8b 13             	mov    (%rbx),%rdx
  804160541f:	48 c1 e2 04          	shl    $0x4,%rdx
  8041605423:	be 00 00 00 00       	mov    $0x0,%esi
  8041605428:	48 89 c7             	mov    %rax,%rdi
  804160542b:	48 bb 4a be 60 41 80 	movabs $0x804160be4a,%rbx
  8041605432:	00 00 00 
  8041605435:	ff d3                	callq  *%rbx
  envs = (struct Env *)boot_alloc(sizeof(* envs) * NENV);
  8041605437:	bf 00 1f 00 00       	mov    $0x1f00,%edi
  804160543c:	41 ff d5             	callq  *%r13
  804160543f:	48 a3 20 46 70 41 80 	movabs %rax,0x8041704620
  8041605446:	00 00 00 
	memset(pages, 0, sizeof(*envs) * NENV);
  8041605449:	ba 00 1f 00 00       	mov    $0x1f00,%edx
  804160544e:	be 00 00 00 00       	mov    $0x0,%esi
  8041605453:	49 8b 3c 24          	mov    (%r12),%rdi
  8041605457:	ff d3                	callq  *%rbx
  page_init();
  8041605459:	48 b8 87 48 60 41 80 	movabs $0x8041604887,%rax
  8041605460:	00 00 00 
  8041605463:	ff d0                	callq  *%rax
  check_page_free_list(1);
  8041605465:	bf 01 00 00 00       	mov    $0x1,%edi
  804160546a:	48 b8 b6 43 60 41 80 	movabs $0x80416043b6,%rax
  8041605471:	00 00 00 
  8041605474:	ff d0                	callq  *%rax
  void *va;
  int i;
  pp0 = pp1 = pp2 = pp3 = pp4 = pp5 = 0;

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041605476:	48 a1 40 5b 70 41 80 	movabs 0x8041705b40,%rax
  804160547d:	00 00 00 
  8041605480:	48 8b 18             	mov    (%rax),%rbx
  8041605483:	48 89 5d a8          	mov    %rbx,-0x58(%rbp)
  kern_pml4e[0] = 0;
  8041605487:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  assert(pp0 = page_alloc(0));
  804160548e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605493:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  804160549a:	00 00 00 
  804160549d:	ff d0                	callq  *%rax
  804160549f:	49 89 c6             	mov    %rax,%r14
  80416054a2:	48 85 c0             	test   %rax,%rax
  80416054a5:	0f 84 50 10 00 00    	je     80416064fb <mem_init+0x124f>
  assert(pp1 = page_alloc(0));
  80416054ab:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054b0:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  80416054b7:	00 00 00 
  80416054ba:	ff d0                	callq  *%rax
  80416054bc:	49 89 c5             	mov    %rax,%r13
  80416054bf:	48 85 c0             	test   %rax,%rax
  80416054c2:	0f 84 68 10 00 00    	je     8041606530 <mem_init+0x1284>
  assert(pp2 = page_alloc(0));
  80416054c8:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054cd:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  80416054d4:	00 00 00 
  80416054d7:	ff d0                	callq  *%rax
  80416054d9:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  80416054dd:	48 85 c0             	test   %rax,%rax
  80416054e0:	0f 84 7f 10 00 00    	je     8041606565 <mem_init+0x12b9>
  assert(pp3 = page_alloc(0));
  80416054e6:	bf 00 00 00 00       	mov    $0x0,%edi
  80416054eb:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  80416054f2:	00 00 00 
  80416054f5:	ff d0                	callq  *%rax
  80416054f7:	48 89 c3             	mov    %rax,%rbx
  80416054fa:	48 85 c0             	test   %rax,%rax
  80416054fd:	0f 84 92 10 00 00    	je     8041606595 <mem_init+0x12e9>
  assert(pp4 = page_alloc(0));
  8041605503:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605508:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  804160550f:	00 00 00 
  8041605512:	ff d0                	callq  *%rax
  8041605514:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8041605518:	48 85 c0             	test   %rax,%rax
  804160551b:	0f 84 a9 10 00 00    	je     80416065ca <mem_init+0x131e>
  assert(pp5 = page_alloc(0));
  8041605521:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605526:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  804160552d:	00 00 00 
  8041605530:	ff d0                	callq  *%rax
  8041605532:	48 85 c0             	test   %rax,%rax
  8041605535:	0f 84 bf 10 00 00    	je     80416065fa <mem_init+0x134e>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  804160553b:	4d 39 ee             	cmp    %r13,%r14
  804160553e:	0f 84 e6 10 00 00    	je     804160662a <mem_init+0x137e>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041605544:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041605548:	49 39 cd             	cmp    %rcx,%r13
  804160554b:	0f 84 0e 11 00 00    	je     804160665f <mem_init+0x13b3>
  8041605551:	49 39 ce             	cmp    %rcx,%r14
  8041605554:	0f 84 05 11 00 00    	je     804160665f <mem_init+0x13b3>
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  804160555a:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  804160555e:	0f 84 30 11 00 00    	je     8041606694 <mem_init+0x13e8>
  8041605564:	49 39 dd             	cmp    %rbx,%r13
  8041605567:	0f 84 27 11 00 00    	je     8041606694 <mem_init+0x13e8>
  804160556d:	49 39 de             	cmp    %rbx,%r14
  8041605570:	0f 84 1e 11 00 00    	je     8041606694 <mem_init+0x13e8>
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  8041605576:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  804160557a:	48 39 f3             	cmp    %rsi,%rbx
  804160557d:	0f 84 46 11 00 00    	je     80416066c9 <mem_init+0x141d>
  8041605583:	48 39 75 b8          	cmp    %rsi,-0x48(%rbp)
  8041605587:	0f 94 c1             	sete   %cl
  804160558a:	49 39 f5             	cmp    %rsi,%r13
  804160558d:	0f 94 c2             	sete   %dl
  8041605590:	08 d1                	or     %dl,%cl
  8041605592:	0f 85 31 11 00 00    	jne    80416066c9 <mem_init+0x141d>
  8041605598:	49 39 f6             	cmp    %rsi,%r14
  804160559b:	0f 84 28 11 00 00    	je     80416066c9 <mem_init+0x141d>
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  80416055a1:	48 39 45 b0          	cmp    %rax,-0x50(%rbp)
  80416055a5:	0f 84 53 11 00 00    	je     80416066fe <mem_init+0x1452>
  80416055ab:	48 39 c3             	cmp    %rax,%rbx
  80416055ae:	0f 84 4a 11 00 00    	je     80416066fe <mem_init+0x1452>
  80416055b4:	48 39 45 b8          	cmp    %rax,-0x48(%rbp)
  80416055b8:	0f 84 40 11 00 00    	je     80416066fe <mem_init+0x1452>
  80416055be:	49 39 c5             	cmp    %rax,%r13
  80416055c1:	0f 84 37 11 00 00    	je     80416066fe <mem_init+0x1452>
  80416055c7:	49 39 c6             	cmp    %rax,%r14
  80416055ca:	0f 84 2e 11 00 00    	je     80416066fe <mem_init+0x1452>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
  80416055d0:	48 a1 08 46 70 41 80 	movabs 0x8041704608,%rax
  80416055d7:	00 00 00 
  80416055da:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  assert(fl != NULL);
  80416055de:	48 85 c0             	test   %rax,%rax
  80416055e1:	0f 84 4c 11 00 00    	je     8041606733 <mem_init+0x1487>
  page_free_list = NULL;
  80416055e7:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  80416055ee:	00 00 00 
  80416055f1:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // should be no free memory
  assert(!page_alloc(0));
  80416055f8:	bf 00 00 00 00       	mov    $0x0,%edi
  80416055fd:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041605604:	00 00 00 
  8041605607:	ff d0                	callq  *%rax
  8041605609:	48 85 c0             	test   %rax,%rax
  804160560c:	0f 85 51 11 00 00    	jne    8041606763 <mem_init+0x14b7>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  8041605612:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041605616:	be 00 00 00 00       	mov    $0x0,%esi
  804160561b:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605622:	00 00 00 
  8041605625:	48 8b 38             	mov    (%rax),%rdi
  8041605628:	48 b8 5a 50 60 41 80 	movabs $0x804160505a,%rax
  804160562f:	00 00 00 
  8041605632:	ff d0                	callq  *%rax
  8041605634:	48 85 c0             	test   %rax,%rax
  8041605637:	0f 85 5b 11 00 00    	jne    8041606798 <mem_init+0x14ec>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  804160563d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605642:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605647:	4c 89 ee             	mov    %r13,%rsi
  804160564a:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605651:	00 00 00 
  8041605654:	48 8b 38             	mov    (%rax),%rdi
  8041605657:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  804160565e:	00 00 00 
  8041605661:	ff d0                	callq  *%rax
  8041605663:	85 c0                	test   %eax,%eax
  8041605665:	0f 89 62 11 00 00    	jns    80416067cd <mem_init+0x1521>

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
  804160566b:	4c 89 f7             	mov    %r14,%rdi
  804160566e:	48 b8 67 4b 60 41 80 	movabs $0x8041604b67,%rax
  8041605675:	00 00 00 
  8041605678:	ff d0                	callq  *%rax
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  804160567a:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160567f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605684:	4c 89 ee             	mov    %r13,%rsi
  8041605687:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  804160568e:	00 00 00 
  8041605691:	48 8b 38             	mov    (%rax),%rdi
  8041605694:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  804160569b:	00 00 00 
  804160569e:	ff d0                	callq  *%rax
  80416056a0:	85 c0                	test   %eax,%eax
  80416056a2:	0f 89 5a 11 00 00    	jns    8041606802 <mem_init+0x1556>
  page_free(pp2);
  80416056a8:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  80416056ac:	49 bc 67 4b 60 41 80 	movabs $0x8041604b67,%r12
  80416056b3:	00 00 00 
  80416056b6:	41 ff d4             	callq  *%r12
  page_free(pp3);
  80416056b9:	48 89 df             	mov    %rbx,%rdi
  80416056bc:	41 ff d4             	callq  *%r12

  //cprintf("pp0 ref count = %d\n",pp0->pp_ref);
  //cprintf("pp2 ref count = %d\n",pp2->pp_ref);
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  80416056bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416056c4:	ba 00 00 00 00       	mov    $0x0,%edx
  80416056c9:	4c 89 ee             	mov    %r13,%rsi
  80416056cc:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  80416056d3:	00 00 00 
  80416056d6:	48 8b 38             	mov    (%rax),%rdi
  80416056d9:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  80416056e0:	00 00 00 
  80416056e3:	ff d0                	callq  *%rax
  80416056e5:	85 c0                	test   %eax,%eax
  80416056e7:	0f 85 4a 11 00 00    	jne    8041606837 <mem_init+0x158b>
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  80416056ed:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  80416056f4:	00 00 00 
  80416056f7:	4c 8b 20             	mov    (%rax),%r12
  80416056fa:	49 8b 14 24          	mov    (%r12),%rdx
  80416056fe:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041605705:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  804160570c:	00 00 00 
  804160570f:	4c 8b 38             	mov    (%rax),%r15
  8041605712:	4c 89 f0             	mov    %r14,%rax
  8041605715:	4c 29 f8             	sub    %r15,%rax
  8041605718:	48 c1 f8 04          	sar    $0x4,%rax
  804160571c:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605720:	48 39 c2             	cmp    %rax,%rdx
  8041605723:	74 2b                	je     8041605750 <mem_init+0x4a4>
  8041605725:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605729:	4c 29 f8             	sub    %r15,%rax
  804160572c:	48 c1 f8 04          	sar    $0x4,%rax
  8041605730:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605734:	48 39 c2             	cmp    %rax,%rdx
  8041605737:	74 17                	je     8041605750 <mem_init+0x4a4>
  8041605739:	48 89 d8             	mov    %rbx,%rax
  804160573c:	4c 29 f8             	sub    %r15,%rax
  804160573f:	48 c1 f8 04          	sar    $0x4,%rax
  8041605743:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605747:	48 39 c2             	cmp    %rax,%rdx
  804160574a:	0f 85 1c 11 00 00    	jne    804160686c <mem_init+0x15c0>
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  8041605750:	be 00 00 00 00       	mov    $0x0,%esi
  8041605755:	4c 89 e7             	mov    %r12,%rdi
  8041605758:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  804160575f:	00 00 00 
  8041605762:	ff d0                	callq  *%rax
  8041605764:	4c 89 ea             	mov    %r13,%rdx
  8041605767:	4c 29 fa             	sub    %r15,%rdx
  804160576a:	48 c1 fa 04          	sar    $0x4,%rdx
  804160576e:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605772:	48 39 d0             	cmp    %rdx,%rax
  8041605775:	0f 85 26 11 00 00    	jne    80416068a1 <mem_init+0x15f5>
  assert(pp1->pp_ref == 1);
  804160577b:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605781:	0f 85 4f 11 00 00    	jne    80416068d6 <mem_init+0x162a>
  //should be able to map pp3 at PGSIZE because pp0 is already allocated for page table
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041605787:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160578c:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605791:	48 89 de             	mov    %rbx,%rsi
  8041605794:	4c 89 e7             	mov    %r12,%rdi
  8041605797:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  804160579e:	00 00 00 
  80416057a1:	ff d0                	callq  *%rax
  80416057a3:	85 c0                	test   %eax,%eax
  80416057a5:	0f 85 60 11 00 00    	jne    804160690b <mem_init+0x165f>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  80416057ab:	be 00 10 00 00       	mov    $0x1000,%esi
  80416057b0:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  80416057b7:	00 00 00 
  80416057ba:	48 8b 38             	mov    (%rax),%rdi
  80416057bd:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  80416057c4:	00 00 00 
  80416057c7:	ff d0                	callq  *%rax
  80416057c9:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  80416057d0:	00 00 00 
  80416057d3:	48 89 df             	mov    %rbx,%rdi
  80416057d6:	48 2b 3a             	sub    (%rdx),%rdi
  80416057d9:	48 89 fa             	mov    %rdi,%rdx
  80416057dc:	48 c1 fa 04          	sar    $0x4,%rdx
  80416057e0:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416057e4:	48 39 d0             	cmp    %rdx,%rax
  80416057e7:	0f 85 53 11 00 00    	jne    8041606940 <mem_init+0x1694>
  assert(pp3->pp_ref == 2);
  80416057ed:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  80416057f2:	0f 85 7d 11 00 00    	jne    8041606975 <mem_init+0x16c9>

  // should be no free memory
  assert(!page_alloc(0));
  80416057f8:	bf 00 00 00 00       	mov    $0x0,%edi
  80416057fd:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041605804:	00 00 00 
  8041605807:	ff d0                	callq  *%rax
  8041605809:	48 85 c0             	test   %rax,%rax
  804160580c:	0f 85 98 11 00 00    	jne    80416069aa <mem_init+0x16fe>

  // should be able to map pp3 at PGSIZE because it's already there
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  8041605812:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605817:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160581c:	48 89 de             	mov    %rbx,%rsi
  804160581f:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605826:	00 00 00 
  8041605829:	48 8b 38             	mov    (%rax),%rdi
  804160582c:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  8041605833:	00 00 00 
  8041605836:	ff d0                	callq  *%rax
  8041605838:	85 c0                	test   %eax,%eax
  804160583a:	0f 85 9f 11 00 00    	jne    80416069df <mem_init+0x1733>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041605840:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605845:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  804160584c:	00 00 00 
  804160584f:	48 8b 38             	mov    (%rax),%rdi
  8041605852:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041605859:	00 00 00 
  804160585c:	ff d0                	callq  *%rax
  804160585e:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  8041605865:	00 00 00 
  8041605868:	48 89 d9             	mov    %rbx,%rcx
  804160586b:	48 2b 0a             	sub    (%rdx),%rcx
  804160586e:	48 89 ca             	mov    %rcx,%rdx
  8041605871:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605875:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605879:	48 39 d0             	cmp    %rdx,%rax
  804160587c:	0f 85 92 11 00 00    	jne    8041606a14 <mem_init+0x1768>
  assert(pp3->pp_ref == 2);
  8041605882:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  8041605887:	0f 85 bc 11 00 00    	jne    8041606a49 <mem_init+0x179d>

  // pp3 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
  804160588d:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605892:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041605899:	00 00 00 
  804160589c:	ff d0                	callq  *%rax
  804160589e:	48 85 c0             	test   %rax,%rax
  80416058a1:	0f 85 d7 11 00 00    	jne    8041606a7e <mem_init+0x17d2>
  // check that pgdir_walk returns a pointer to the pte
  pdpe = KADDR(PTE_ADDR(kern_pml4e[PML4(PGSIZE)]));
  80416058a7:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  80416058ae:	00 00 00 
  80416058b1:	48 8b 38             	mov    (%rax),%rdi
  80416058b4:	48 8b 0f             	mov    (%rdi),%rcx
  80416058b7:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  80416058be:	48 a1 50 5b 70 41 80 	movabs 0x8041705b50,%rax
  80416058c5:	00 00 00 
  80416058c8:	48 89 ca             	mov    %rcx,%rdx
  80416058cb:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416058cf:	48 39 c2             	cmp    %rax,%rdx
  80416058d2:	0f 83 db 11 00 00    	jae    8041606ab3 <mem_init+0x1807>
  pde  = KADDR(PTE_ADDR(pdpe[PDPE(PGSIZE)]));
  80416058d8:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  80416058df:	00 00 00 
  80416058e2:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  80416058e6:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  80416058ed:	48 89 ca             	mov    %rcx,%rdx
  80416058f0:	48 c1 ea 0c          	shr    $0xc,%rdx
  80416058f4:	48 39 d0             	cmp    %rdx,%rax
  80416058f7:	0f 86 e1 11 00 00    	jbe    8041606ade <mem_init+0x1832>
  ptep = KADDR(PTE_ADDR(pde[PDX(PGSIZE)]));
  80416058fd:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605904:	00 00 00 
  8041605907:	48 8b 0c 11          	mov    (%rcx,%rdx,1),%rcx
  804160590b:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605912:	48 89 ca             	mov    %rcx,%rdx
  8041605915:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605919:	48 39 d0             	cmp    %rdx,%rax
  804160591c:	0f 86 e7 11 00 00    	jbe    8041606b09 <mem_init+0x185d>
  return (void *)(pa + KERNBASE);
  8041605922:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041605929:	00 00 00 
  804160592c:	48 01 c1             	add    %rax,%rcx
  804160592f:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  8041605933:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605938:	be 00 10 00 00       	mov    $0x1000,%esi
  804160593d:	48 b8 91 4e 60 41 80 	movabs $0x8041604e91,%rax
  8041605944:	00 00 00 
  8041605947:	ff d0                	callq  *%rax
  8041605949:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160594d:	48 8d 57 08          	lea    0x8(%rdi),%rdx
  8041605951:	48 39 d0             	cmp    %rdx,%rax
  8041605954:	0f 85 da 11 00 00    	jne    8041606b34 <mem_init+0x1888>

  // should be able to change permissions too.
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  804160595a:	b9 04 00 00 00       	mov    $0x4,%ecx
  804160595f:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605964:	48 89 de             	mov    %rbx,%rsi
  8041605967:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  804160596e:	00 00 00 
  8041605971:	48 8b 38             	mov    (%rax),%rdi
  8041605974:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  804160597b:	00 00 00 
  804160597e:	ff d0                	callq  *%rax
  8041605980:	85 c0                	test   %eax,%eax
  8041605982:	0f 85 e1 11 00 00    	jne    8041606b69 <mem_init+0x18bd>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041605988:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  804160598f:	00 00 00 
  8041605992:	4c 8b 20             	mov    (%rax),%r12
  8041605995:	be 00 10 00 00       	mov    $0x1000,%esi
  804160599a:	4c 89 e7             	mov    %r12,%rdi
  804160599d:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  80416059a4:	00 00 00 
  80416059a7:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  80416059a9:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  80416059b0:	00 00 00 
  80416059b3:	48 89 de             	mov    %rbx,%rsi
  80416059b6:	48 2b 32             	sub    (%rdx),%rsi
  80416059b9:	48 89 f2             	mov    %rsi,%rdx
  80416059bc:	48 c1 fa 04          	sar    $0x4,%rdx
  80416059c0:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416059c4:	48 39 d0             	cmp    %rdx,%rax
  80416059c7:	0f 85 d1 11 00 00    	jne    8041606b9e <mem_init+0x18f2>
  assert(pp3->pp_ref == 2);
  80416059cd:	66 83 7b 08 02       	cmpw   $0x2,0x8(%rbx)
  80416059d2:	0f 85 fb 11 00 00    	jne    8041606bd3 <mem_init+0x1927>
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  80416059d8:	ba 00 00 00 00       	mov    $0x0,%edx
  80416059dd:	be 00 10 00 00       	mov    $0x1000,%esi
  80416059e2:	4c 89 e7             	mov    %r12,%rdi
  80416059e5:	48 b8 91 4e 60 41 80 	movabs $0x8041604e91,%rax
  80416059ec:	00 00 00 
  80416059ef:	ff d0                	callq  *%rax
  80416059f1:	f6 00 04             	testb  $0x4,(%rax)
  80416059f4:	0f 84 0e 12 00 00    	je     8041606c08 <mem_init+0x195c>
  assert(kern_pml4e[0] & PTE_U);
  80416059fa:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605a01:	00 00 00 
  8041605a04:	48 8b 38             	mov    (%rax),%rdi
  8041605a07:	f6 07 04             	testb  $0x4,(%rdi)
  8041605a0a:	0f 84 2d 12 00 00    	je     8041606c3d <mem_init+0x1991>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041605a10:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605a15:	ba 00 00 20 00       	mov    $0x200000,%edx
  8041605a1a:	4c 89 f6             	mov    %r14,%rsi
  8041605a1d:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  8041605a24:	00 00 00 
  8041605a27:	ff d0                	callq  *%rax
  8041605a29:	85 c0                	test   %eax,%eax
  8041605a2b:	0f 89 41 12 00 00    	jns    8041606c72 <mem_init+0x19c6>

  // insert pp1 at PGSIZE (replacing pp3)
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605a31:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605a36:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605a3b:	4c 89 ee             	mov    %r13,%rsi
  8041605a3e:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605a45:	00 00 00 
  8041605a48:	48 8b 38             	mov    (%rax),%rdi
  8041605a4b:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  8041605a52:	00 00 00 
  8041605a55:	ff d0                	callq  *%rax
  8041605a57:	85 c0                	test   %eax,%eax
  8041605a59:	0f 85 48 12 00 00    	jne    8041606ca7 <mem_init+0x19fb>
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041605a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041605a64:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605a69:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605a70:	00 00 00 
  8041605a73:	48 8b 38             	mov    (%rax),%rdi
  8041605a76:	48 b8 91 4e 60 41 80 	movabs $0x8041604e91,%rax
  8041605a7d:	00 00 00 
  8041605a80:	ff d0                	callq  *%rax
  8041605a82:	f6 00 04             	testb  $0x4,(%rax)
  8041605a85:	0f 85 51 12 00 00    	jne    8041606cdc <mem_init+0x1a30>

  // should have pp1 at both 0 and PGSIZE
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041605a8b:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605a92:	00 00 00 
  8041605a95:	4c 8b 20             	mov    (%rax),%r12
  8041605a98:	be 00 00 00 00       	mov    $0x0,%esi
  8041605a9d:	4c 89 e7             	mov    %r12,%rdi
  8041605aa0:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041605aa7:	00 00 00 
  8041605aaa:	ff d0                	callq  *%rax
  8041605aac:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  8041605ab3:	00 00 00 
  8041605ab6:	4d 89 ef             	mov    %r13,%r15
  8041605ab9:	4c 2b 3a             	sub    (%rdx),%r15
  8041605abc:	49 c1 ff 04          	sar    $0x4,%r15
  8041605ac0:	49 c1 e7 0c          	shl    $0xc,%r15
  8041605ac4:	4c 39 f8             	cmp    %r15,%rax
  8041605ac7:	0f 85 44 12 00 00    	jne    8041606d11 <mem_init+0x1a65>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605acd:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605ad2:	4c 89 e7             	mov    %r12,%rdi
  8041605ad5:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041605adc:	00 00 00 
  8041605adf:	ff d0                	callq  *%rax
  8041605ae1:	49 39 c7             	cmp    %rax,%r15
  8041605ae4:	0f 85 5c 12 00 00    	jne    8041606d46 <mem_init+0x1a9a>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
  8041605aea:	66 41 83 7d 08 02    	cmpw   $0x2,0x8(%r13)
  8041605af0:	0f 85 85 12 00 00    	jne    8041606d7b <mem_init+0x1acf>
  assert(pp3->pp_ref == 1);
  8041605af6:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605afb:	0f 85 af 12 00 00    	jne    8041606db0 <mem_init+0x1b04>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pml4e, 0x0);
  8041605b01:	be 00 00 00 00       	mov    $0x0,%esi
  8041605b06:	4c 89 e7             	mov    %r12,%rdi
  8041605b09:	48 b8 20 51 60 41 80 	movabs $0x8041605120,%rax
  8041605b10:	00 00 00 
  8041605b13:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605b15:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041605b1c:	00 00 00 
  8041605b1f:	4c 8b 20             	mov    (%rax),%r12
  8041605b22:	be 00 00 00 00       	mov    $0x0,%esi
  8041605b27:	4c 89 e7             	mov    %r12,%rdi
  8041605b2a:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041605b31:	00 00 00 
  8041605b34:	ff d0                	callq  *%rax
  8041605b36:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605b3a:	0f 85 a5 12 00 00    	jne    8041606de5 <mem_init+0x1b39>
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041605b40:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605b45:	4c 89 e7             	mov    %r12,%rdi
  8041605b48:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041605b4f:	00 00 00 
  8041605b52:	ff d0                	callq  *%rax
  8041605b54:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  8041605b5b:	00 00 00 
  8041605b5e:	4c 89 ef             	mov    %r13,%rdi
  8041605b61:	48 2b 3a             	sub    (%rdx),%rdi
  8041605b64:	48 89 fa             	mov    %rdi,%rdx
  8041605b67:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605b6b:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605b6f:	48 39 d0             	cmp    %rdx,%rax
  8041605b72:	0f 85 a2 12 00 00    	jne    8041606e1a <mem_init+0x1b6e>
  assert(pp1->pp_ref == 1);
  8041605b78:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041605b7e:	0f 85 cb 12 00 00    	jne    8041606e4f <mem_init+0x1ba3>
  assert(pp3->pp_ref == 1);
  8041605b84:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605b89:	0f 85 f5 12 00 00    	jne    8041606e84 <mem_init+0x1bd8>

  // Test re-inserting pp1 at PGSIZE.
  // Thanks to Varun Agrawal for suggesting this test case.
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041605b8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041605b94:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605b99:	4c 89 ee             	mov    %r13,%rsi
  8041605b9c:	4c 89 e7             	mov    %r12,%rdi
  8041605b9f:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  8041605ba6:	00 00 00 
  8041605ba9:	ff d0                	callq  *%rax
  8041605bab:	41 89 c4             	mov    %eax,%r12d
  8041605bae:	85 c0                	test   %eax,%eax
  8041605bb0:	0f 85 03 13 00 00    	jne    8041606eb9 <mem_init+0x1c0d>
  assert(pp1->pp_ref);
  8041605bb6:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041605bbc:	0f 84 2c 13 00 00    	je     8041606eee <mem_init+0x1c42>
  assert(pp1->pp_link == NULL);
  8041605bc2:	49 83 7d 00 00       	cmpq   $0x0,0x0(%r13)
  8041605bc7:	0f 85 56 13 00 00    	jne    8041606f23 <mem_init+0x1c77>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041605bcd:	49 bf 40 5b 70 41 80 	movabs $0x8041705b40,%r15
  8041605bd4:	00 00 00 
  8041605bd7:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605bdc:	49 8b 3f             	mov    (%r15),%rdi
  8041605bdf:	48 b8 20 51 60 41 80 	movabs $0x8041605120,%rax
  8041605be6:	00 00 00 
  8041605be9:	ff d0                	callq  *%rax
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041605beb:	4d 8b 3f             	mov    (%r15),%r15
  8041605bee:	be 00 00 00 00       	mov    $0x0,%esi
  8041605bf3:	4c 89 ff             	mov    %r15,%rdi
  8041605bf6:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041605bfd:	00 00 00 
  8041605c00:	ff d0                	callq  *%rax
  8041605c02:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605c06:	0f 85 4c 13 00 00    	jne    8041606f58 <mem_init+0x1cac>
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041605c0c:	be 00 10 00 00       	mov    $0x1000,%esi
  8041605c11:	4c 89 ff             	mov    %r15,%rdi
  8041605c14:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041605c1b:	00 00 00 
  8041605c1e:	ff d0                	callq  *%rax
  8041605c20:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041605c24:	0f 85 63 13 00 00    	jne    8041606f8d <mem_init+0x1ce1>
  assert(pp1->pp_ref == 0);
  8041605c2a:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041605c30:	0f 85 8c 13 00 00    	jne    8041606fc2 <mem_init+0x1d16>
  assert(pp3->pp_ref == 1);
  8041605c36:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605c3b:	0f 85 b6 13 00 00    	jne    8041606ff7 <mem_init+0x1d4b>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

  // forcibly take pp3 back
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  8041605c41:	49 8b 17             	mov    (%r15),%rdx
  8041605c44:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  8041605c4b:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041605c52:	00 00 00 
  8041605c55:	48 8b 08             	mov    (%rax),%rcx
  8041605c58:	4c 89 f0             	mov    %r14,%rax
  8041605c5b:	48 29 c8             	sub    %rcx,%rax
  8041605c5e:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c62:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c66:	48 39 c2             	cmp    %rax,%rdx
  8041605c69:	74 2b                	je     8041605c96 <mem_init+0x9ea>
  8041605c6b:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041605c6f:	48 29 c8             	sub    %rcx,%rax
  8041605c72:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c76:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c7a:	48 39 c2             	cmp    %rax,%rdx
  8041605c7d:	74 17                	je     8041605c96 <mem_init+0x9ea>
  8041605c7f:	48 89 d8             	mov    %rbx,%rax
  8041605c82:	48 29 c8             	sub    %rcx,%rax
  8041605c85:	48 c1 f8 04          	sar    $0x4,%rax
  8041605c89:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605c8d:	48 39 c2             	cmp    %rax,%rdx
  8041605c90:	0f 85 96 13 00 00    	jne    804160702c <mem_init+0x1d80>
  kern_pml4e[0] = 0;
  8041605c96:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
  assert(pp3->pp_ref == 1);
  8041605c9d:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041605ca2:	0f 85 b9 13 00 00    	jne    8041607061 <mem_init+0x1db5>
  page_decref(pp3);
  8041605ca8:	48 89 df             	mov    %rbx,%rdi
  8041605cab:	48 bb d5 4b 60 41 80 	movabs $0x8041604bd5,%rbx
  8041605cb2:	00 00 00 
  8041605cb5:	ff d3                	callq  *%rbx
  // check pointer arithmetic in pml4e_walk
  page_decref(pp0);
  8041605cb7:	4c 89 f7             	mov    %r14,%rdi
  8041605cba:	ff d3                	callq  *%rbx
  page_decref(pp2);
  8041605cbc:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605cc0:	ff d3                	callq  *%rbx
  va    = (void *)(PGSIZE * 100);
  ptep  = pml4e_walk(kern_pml4e, va, 1);
  8041605cc2:	48 bb 40 5b 70 41 80 	movabs $0x8041705b40,%rbx
  8041605cc9:	00 00 00 
  8041605ccc:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605cd1:	be 00 40 06 00       	mov    $0x64000,%esi
  8041605cd6:	48 8b 3b             	mov    (%rbx),%rdi
  8041605cd9:	48 b8 91 4e 60 41 80 	movabs $0x8041604e91,%rax
  8041605ce0:	00 00 00 
  8041605ce3:	ff d0                	callq  *%rax
  8041605ce5:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  pdpe  = KADDR(PTE_ADDR(kern_pml4e[PML4(va)]));
  8041605ce9:	48 8b 13             	mov    (%rbx),%rdx
  8041605cec:	48 8b 0a             	mov    (%rdx),%rcx
  8041605cef:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605cf6:	48 bb 50 5b 70 41 80 	movabs $0x8041705b50,%rbx
  8041605cfd:	00 00 00 
  8041605d00:	48 8b 13             	mov    (%rbx),%rdx
  8041605d03:	48 89 ce             	mov    %rcx,%rsi
  8041605d06:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605d0a:	48 39 d6             	cmp    %rdx,%rsi
  8041605d0d:	0f 83 83 13 00 00    	jae    8041607096 <mem_init+0x1dea>
  pde   = KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8041605d13:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605d1a:	00 00 00 
  8041605d1d:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605d21:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605d28:	48 89 ce             	mov    %rcx,%rsi
  8041605d2b:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605d2f:	48 39 f2             	cmp    %rsi,%rdx
  8041605d32:	0f 86 89 13 00 00    	jbe    80416070c1 <mem_init+0x1e15>
  ptep1 = KADDR(PTE_ADDR(pde[PDX(va)]));
  8041605d38:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605d3f:	00 00 00 
  8041605d42:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605d46:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605d4d:	48 89 ce             	mov    %rcx,%rsi
  8041605d50:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605d54:	48 39 f2             	cmp    %rsi,%rdx
  8041605d57:	0f 86 8f 13 00 00    	jbe    80416070ec <mem_init+0x1e40>
  assert(ptep == ptep1 + PTX(va));
  8041605d5d:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041605d64:	00 00 00 
  8041605d67:	48 8d 94 11 20 03 00 	lea    0x320(%rcx,%rdx,1),%rdx
  8041605d6e:	00 
  8041605d6f:	48 39 d0             	cmp    %rdx,%rax
  8041605d72:	0f 85 9f 13 00 00    	jne    8041607117 <mem_init+0x1e6b>

  // check that new page tables get cleared
  page_decref(pp4);
  8041605d78:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  8041605d7c:	48 89 df             	mov    %rbx,%rdi
  8041605d7f:	48 b8 d5 4b 60 41 80 	movabs $0x8041604bd5,%rax
  8041605d86:	00 00 00 
  8041605d89:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041605d8b:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041605d92:	00 00 00 
  8041605d95:	48 2b 18             	sub    (%rax),%rbx
  8041605d98:	48 89 df             	mov    %rbx,%rdi
  8041605d9b:	48 c1 ff 04          	sar    $0x4,%rdi
  8041605d9f:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  8041605da3:	48 89 fa             	mov    %rdi,%rdx
  8041605da6:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041605daa:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041605db1:	00 00 00 
  8041605db4:	48 3b 10             	cmp    (%rax),%rdx
  8041605db7:	0f 83 8f 13 00 00    	jae    804160714c <mem_init+0x1ea0>
  return (void *)(pa + KERNBASE);
  8041605dbd:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  8041605dc4:	00 00 00 
  8041605dc7:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp4), 0xFF, PGSIZE);
  8041605dca:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041605dcf:	be ff 00 00 00       	mov    $0xff,%esi
  8041605dd4:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041605ddb:	00 00 00 
  8041605dde:	ff d0                	callq  *%rax
  pml4e_walk(kern_pml4e, 0x0, 1);
  8041605de0:	48 bb 40 5b 70 41 80 	movabs $0x8041705b40,%rbx
  8041605de7:	00 00 00 
  8041605dea:	ba 01 00 00 00       	mov    $0x1,%edx
  8041605def:	be 00 00 00 00       	mov    $0x0,%esi
  8041605df4:	48 8b 3b             	mov    (%rbx),%rdi
  8041605df7:	48 b8 91 4e 60 41 80 	movabs $0x8041604e91,%rax
  8041605dfe:	00 00 00 
  8041605e01:	ff d0                	callq  *%rax
  pdpe = KADDR(PTE_ADDR(kern_pml4e[0]));
  8041605e03:	48 8b 13             	mov    (%rbx),%rdx
  8041605e06:	48 8b 0a             	mov    (%rdx),%rcx
  8041605e09:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041605e10:	48 a1 50 5b 70 41 80 	movabs 0x8041705b50,%rax
  8041605e17:	00 00 00 
  8041605e1a:	48 89 ce             	mov    %rcx,%rsi
  8041605e1d:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605e21:	48 39 c6             	cmp    %rax,%rsi
  8041605e24:	0f 83 50 13 00 00    	jae    804160717a <mem_init+0x1ece>
  pde  = KADDR(PTE_ADDR(pdpe[0]));
  8041605e2a:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605e31:	00 00 00 
  8041605e34:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605e38:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605e3f:	48 89 ce             	mov    %rcx,%rsi
  8041605e42:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605e46:	48 39 f0             	cmp    %rsi,%rax
  8041605e49:	0f 86 56 13 00 00    	jbe    80416071a5 <mem_init+0x1ef9>
  ptep = KADDR(PTE_ADDR(pde[0]));
  8041605e4f:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  8041605e56:	00 00 00 
  8041605e59:	48 8b 0c 31          	mov    (%rcx,%rsi,1),%rcx
  8041605e5d:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041605e64:	48 89 ce             	mov    %rcx,%rsi
  8041605e67:	48 c1 ee 0c          	shr    $0xc,%rsi
  8041605e6b:	48 39 f0             	cmp    %rsi,%rax
  8041605e6e:	0f 86 5c 13 00 00    	jbe    80416071d0 <mem_init+0x1f24>
  return (void *)(pa + KERNBASE);
  8041605e74:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041605e7b:	00 00 00 
  8041605e7e:	48 01 c8             	add    %rcx,%rax
  8041605e81:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
  8041605e85:	f6 00 01             	testb  $0x1,(%rax)
  8041605e88:	0f 85 6d 13 00 00    	jne    80416071fb <mem_init+0x1f4f>
  8041605e8e:	48 b8 08 00 00 40 80 	movabs $0x8040000008,%rax
  8041605e95:	00 00 00 
  8041605e98:	48 01 c8             	add    %rcx,%rax
  8041605e9b:	48 be 00 10 00 40 80 	movabs $0x8040001000,%rsi
  8041605ea2:	00 00 00 
  8041605ea5:	48 01 f1             	add    %rsi,%rcx
  8041605ea8:	48 8b 18             	mov    (%rax),%rbx
  8041605eab:	83 e3 01             	and    $0x1,%ebx
  8041605eae:	0f 85 47 13 00 00    	jne    80416071fb <mem_init+0x1f4f>
  for (i = 0; i < NPTENTRIES; i++)
  8041605eb4:	48 83 c0 08          	add    $0x8,%rax
  8041605eb8:	48 39 c8             	cmp    %rcx,%rax
  8041605ebb:	75 eb                	jne    8041605ea8 <mem_init+0xbfc>
  kern_pml4e[0] = 0;
  8041605ebd:	48 c7 02 00 00 00 00 	movq   $0x0,(%rdx)

  // give free list back
  page_free_list = fl;
  8041605ec4:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041605ec8:	48 a3 08 46 70 41 80 	movabs %rax,0x8041704608
  8041605ecf:	00 00 00 

  // free the pages we took
  page_decref(pp0);
  8041605ed2:	4c 89 f7             	mov    %r14,%rdi
  8041605ed5:	49 be d5 4b 60 41 80 	movabs $0x8041604bd5,%r14
  8041605edc:	00 00 00 
  8041605edf:	41 ff d6             	callq  *%r14
  page_decref(pp1);
  8041605ee2:	4c 89 ef             	mov    %r13,%rdi
  8041605ee5:	41 ff d6             	callq  *%r14
  page_decref(pp2);
  8041605ee8:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041605eec:	41 ff d6             	callq  *%r14

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041605eef:	48 a1 40 5b 70 41 80 	movabs 0x8041705b40,%rax
  8041605ef6:	00 00 00 
  8041605ef9:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8041605efd:	48 89 08             	mov    %rcx,(%rax)

  cprintf("check_page() succeeded!\n");
  8041605f00:	48 bf cd db 60 41 80 	movabs $0x804160dbcd,%rdi
  8041605f07:	00 00 00 
  8041605f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041605f0f:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041605f16:	00 00 00 
  8041605f19:	ff d2                	callq  *%rdx
  if (!pages)
  8041605f1b:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041605f22:	00 00 00 
  8041605f25:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041605f29:	0f 84 01 13 00 00    	je     8041607230 <mem_init+0x1f84>
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605f2f:	48 a1 08 46 70 41 80 	movabs 0x8041704608,%rax
  8041605f36:	00 00 00 
  8041605f39:	48 85 c0             	test   %rax,%rax
  8041605f3c:	74 0c                	je     8041605f4a <mem_init+0xc9e>
    ++nfree;
  8041605f3e:	41 83 c4 01          	add    $0x1,%r12d
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
  8041605f42:	48 8b 00             	mov    (%rax),%rax
  8041605f45:	48 85 c0             	test   %rax,%rax
  8041605f48:	75 f4                	jne    8041605f3e <mem_init+0xc92>
  assert((pp0 = page_alloc(0)));
  8041605f4a:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605f4f:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041605f56:	00 00 00 
  8041605f59:	ff d0                	callq  *%rax
  8041605f5b:	49 89 c5             	mov    %rax,%r13
  8041605f5e:	48 85 c0             	test   %rax,%rax
  8041605f61:	0f 84 f3 12 00 00    	je     804160725a <mem_init+0x1fae>
  assert((pp1 = page_alloc(0)));
  8041605f67:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605f6c:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041605f73:	00 00 00 
  8041605f76:	ff d0                	callq  *%rax
  8041605f78:	49 89 c7             	mov    %rax,%r15
  8041605f7b:	48 85 c0             	test   %rax,%rax
  8041605f7e:	0f 84 0b 13 00 00    	je     804160728f <mem_init+0x1fe3>
  assert((pp2 = page_alloc(0)));
  8041605f84:	bf 00 00 00 00       	mov    $0x0,%edi
  8041605f89:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041605f90:	00 00 00 
  8041605f93:	ff d0                	callq  *%rax
  8041605f95:	49 89 c6             	mov    %rax,%r14
  8041605f98:	48 85 c0             	test   %rax,%rax
  8041605f9b:	0f 84 23 13 00 00    	je     80416072c4 <mem_init+0x2018>
  assert(pp1 && pp1 != pp0);
  8041605fa1:	4d 39 fd             	cmp    %r15,%r13
  8041605fa4:	0f 84 4f 13 00 00    	je     80416072f9 <mem_init+0x204d>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8041605faa:	49 39 c5             	cmp    %rax,%r13
  8041605fad:	0f 84 7b 13 00 00    	je     804160732e <mem_init+0x2082>
  8041605fb3:	49 39 c7             	cmp    %rax,%r15
  8041605fb6:	0f 84 72 13 00 00    	je     804160732e <mem_init+0x2082>
  return (pp - pages) << PGSHIFT;
  8041605fbc:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041605fc3:	00 00 00 
  8041605fc6:	48 8b 08             	mov    (%rax),%rcx
  assert(page2pa(pp0) < npages * PGSIZE);
  8041605fc9:	48 a1 50 5b 70 41 80 	movabs 0x8041705b50,%rax
  8041605fd0:	00 00 00 
  8041605fd3:	48 c1 e0 0c          	shl    $0xc,%rax
  8041605fd7:	4c 89 ea             	mov    %r13,%rdx
  8041605fda:	48 29 ca             	sub    %rcx,%rdx
  8041605fdd:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605fe1:	48 c1 e2 0c          	shl    $0xc,%rdx
  8041605fe5:	48 39 c2             	cmp    %rax,%rdx
  8041605fe8:	0f 83 75 13 00 00    	jae    8041607363 <mem_init+0x20b7>
  8041605fee:	4c 89 fa             	mov    %r15,%rdx
  8041605ff1:	48 29 ca             	sub    %rcx,%rdx
  8041605ff4:	48 c1 fa 04          	sar    $0x4,%rdx
  8041605ff8:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp1) < npages * PGSIZE);
  8041605ffc:	48 39 d0             	cmp    %rdx,%rax
  8041605fff:	0f 86 93 13 00 00    	jbe    8041607398 <mem_init+0x20ec>
  8041606005:	4c 89 f2             	mov    %r14,%rdx
  8041606008:	48 29 ca             	sub    %rcx,%rdx
  804160600b:	48 c1 fa 04          	sar    $0x4,%rdx
  804160600f:	48 c1 e2 0c          	shl    $0xc,%rdx
  assert(page2pa(pp2) < npages * PGSIZE);
  8041606013:	48 39 d0             	cmp    %rdx,%rax
  8041606016:	0f 86 b1 13 00 00    	jbe    80416073cd <mem_init+0x2121>
  fl             = page_free_list;
  804160601c:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  8041606023:	00 00 00 
  8041606026:	48 8b 38             	mov    (%rax),%rdi
  8041606029:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  page_free_list = 0;
  804160602d:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  assert(!page_alloc(0));
  8041606034:	bf 00 00 00 00       	mov    $0x0,%edi
  8041606039:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041606040:	00 00 00 
  8041606043:	ff d0                	callq  *%rax
  8041606045:	48 85 c0             	test   %rax,%rax
  8041606048:	0f 85 b4 13 00 00    	jne    8041607402 <mem_init+0x2156>
  page_free(pp0);
  804160604e:	4c 89 ef             	mov    %r13,%rdi
  8041606051:	49 bd 67 4b 60 41 80 	movabs $0x8041604b67,%r13
  8041606058:	00 00 00 
  804160605b:	41 ff d5             	callq  *%r13
  page_free(pp1);
  804160605e:	4c 89 ff             	mov    %r15,%rdi
  8041606061:	41 ff d5             	callq  *%r13
  page_free(pp2);
  8041606064:	4c 89 f7             	mov    %r14,%rdi
  8041606067:	41 ff d5             	callq  *%r13
  assert((pp0 = page_alloc(0)));
  804160606a:	bf 00 00 00 00       	mov    $0x0,%edi
  804160606f:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041606076:	00 00 00 
  8041606079:	ff d0                	callq  *%rax
  804160607b:	49 89 c5             	mov    %rax,%r13
  804160607e:	48 85 c0             	test   %rax,%rax
  8041606081:	0f 84 b0 13 00 00    	je     8041607437 <mem_init+0x218b>
  assert((pp1 = page_alloc(0)));
  8041606087:	bf 00 00 00 00       	mov    $0x0,%edi
  804160608c:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041606093:	00 00 00 
  8041606096:	ff d0                	callq  *%rax
  8041606098:	49 89 c7             	mov    %rax,%r15
  804160609b:	48 85 c0             	test   %rax,%rax
  804160609e:	0f 84 c8 13 00 00    	je     804160746c <mem_init+0x21c0>
  assert((pp2 = page_alloc(0)));
  80416060a4:	bf 00 00 00 00       	mov    $0x0,%edi
  80416060a9:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  80416060b0:	00 00 00 
  80416060b3:	ff d0                	callq  *%rax
  80416060b5:	49 89 c6             	mov    %rax,%r14
  80416060b8:	48 85 c0             	test   %rax,%rax
  80416060bb:	0f 84 e0 13 00 00    	je     80416074a1 <mem_init+0x21f5>
  assert(pp1 && pp1 != pp0);
  80416060c1:	4d 39 fd             	cmp    %r15,%r13
  80416060c4:	0f 84 0c 14 00 00    	je     80416074d6 <mem_init+0x222a>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80416060ca:	49 39 c7             	cmp    %rax,%r15
  80416060cd:	0f 84 38 14 00 00    	je     804160750b <mem_init+0x225f>
  80416060d3:	49 39 c5             	cmp    %rax,%r13
  80416060d6:	0f 84 2f 14 00 00    	je     804160750b <mem_init+0x225f>
  assert(!page_alloc(0));
  80416060dc:	bf 00 00 00 00       	mov    $0x0,%edi
  80416060e1:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  80416060e8:	00 00 00 
  80416060eb:	ff d0                	callq  *%rax
  80416060ed:	48 85 c0             	test   %rax,%rax
  80416060f0:	0f 85 4a 14 00 00    	jne    8041607540 <mem_init+0x2294>
  80416060f6:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  80416060fd:	00 00 00 
  8041606100:	4c 89 ef             	mov    %r13,%rdi
  8041606103:	48 2b 38             	sub    (%rax),%rdi
  8041606106:	48 c1 ff 04          	sar    $0x4,%rdi
  804160610a:	48 c1 e7 0c          	shl    $0xc,%rdi
  if (PGNUM(pa) >= npages)
  804160610e:	48 89 fa             	mov    %rdi,%rdx
  8041606111:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041606115:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  804160611c:	00 00 00 
  804160611f:	48 3b 10             	cmp    (%rax),%rdx
  8041606122:	0f 83 4d 14 00 00    	jae    8041607575 <mem_init+0x22c9>
  return (void *)(pa + KERNBASE);
  8041606128:	48 b9 00 00 00 40 80 	movabs $0x8040000000,%rcx
  804160612f:	00 00 00 
  8041606132:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp0), 1, PGSIZE);
  8041606135:	ba 00 10 00 00       	mov    $0x1000,%edx
  804160613a:	be 01 00 00 00       	mov    $0x1,%esi
  804160613f:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041606146:	00 00 00 
  8041606149:	ff d0                	callq  *%rax
  page_free(pp0);
  804160614b:	4c 89 ef             	mov    %r13,%rdi
  804160614e:	48 b8 67 4b 60 41 80 	movabs $0x8041604b67,%rax
  8041606155:	00 00 00 
  8041606158:	ff d0                	callq  *%rax
  assert((pp = page_alloc(ALLOC_ZERO)));
  804160615a:	bf 01 00 00 00       	mov    $0x1,%edi
  804160615f:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041606166:	00 00 00 
  8041606169:	ff d0                	callq  *%rax
  804160616b:	48 85 c0             	test   %rax,%rax
  804160616e:	0f 84 2f 14 00 00    	je     80416075a3 <mem_init+0x22f7>
  assert(pp && pp0 == pp);
  8041606174:	49 39 c5             	cmp    %rax,%r13
  8041606177:	0f 85 56 14 00 00    	jne    80416075d3 <mem_init+0x2327>
  return (pp - pages) << PGSHIFT;
  804160617d:	48 ba 58 5b 70 41 80 	movabs $0x8041705b58,%rdx
  8041606184:	00 00 00 
  8041606187:	48 2b 02             	sub    (%rdx),%rax
  804160618a:	48 89 c1             	mov    %rax,%rcx
  804160618d:	48 c1 f9 04          	sar    $0x4,%rcx
  8041606191:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041606195:	48 89 ca             	mov    %rcx,%rdx
  8041606198:	48 c1 ea 0c          	shr    $0xc,%rdx
  804160619c:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  80416061a3:	00 00 00 
  80416061a6:	48 3b 10             	cmp    (%rax),%rdx
  80416061a9:	0f 83 59 14 00 00    	jae    8041607608 <mem_init+0x235c>
    assert(c[i] == 0);
  80416061af:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  80416061b6:	00 00 00 
  80416061b9:	80 3c 01 00          	cmpb   $0x0,(%rcx,%rax,1)
  80416061bd:	0f 85 70 14 00 00    	jne    8041607633 <mem_init+0x2387>
  80416061c3:	48 8d 40 01          	lea    0x1(%rax),%rax
  80416061c7:	48 01 c8             	add    %rcx,%rax
  80416061ca:	48 ba 00 10 00 40 80 	movabs $0x8040001000,%rdx
  80416061d1:	00 00 00 
  80416061d4:	48 01 d1             	add    %rdx,%rcx
  80416061d7:	80 38 00             	cmpb   $0x0,(%rax)
  80416061da:	0f 85 53 14 00 00    	jne    8041607633 <mem_init+0x2387>
  for (i = 0; i < PGSIZE; i++)
  80416061e0:	48 83 c0 01          	add    $0x1,%rax
  80416061e4:	48 39 c1             	cmp    %rax,%rcx
  80416061e7:	75 ee                	jne    80416061d7 <mem_init+0xf2b>
  page_free_list = fl;
  80416061e9:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  80416061f0:	00 00 00 
  80416061f3:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  80416061f7:	48 89 08             	mov    %rcx,(%rax)
  page_free(pp0);
  80416061fa:	4c 89 ef             	mov    %r13,%rdi
  80416061fd:	49 bd 67 4b 60 41 80 	movabs $0x8041604b67,%r13
  8041606204:	00 00 00 
  8041606207:	41 ff d5             	callq  *%r13
  page_free(pp1);
  804160620a:	4c 89 ff             	mov    %r15,%rdi
  804160620d:	41 ff d5             	callq  *%r13
  page_free(pp2);
  8041606210:	4c 89 f7             	mov    %r14,%rdi
  8041606213:	41 ff d5             	callq  *%r13
  for (pp = page_free_list; pp; pp = pp->pp_link)
  8041606216:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  804160621d:	00 00 00 
  8041606220:	48 8b 00             	mov    (%rax),%rax
  8041606223:	48 85 c0             	test   %rax,%rax
  8041606226:	74 0c                	je     8041606234 <mem_init+0xf88>
    --nfree;
  8041606228:	41 83 ec 01          	sub    $0x1,%r12d
  for (pp = page_free_list; pp; pp = pp->pp_link)
  804160622c:	48 8b 00             	mov    (%rax),%rax
  804160622f:	48 85 c0             	test   %rax,%rax
  8041606232:	75 f4                	jne    8041606228 <mem_init+0xf7c>
  assert(nfree == 0);
  8041606234:	45 85 e4             	test   %r12d,%r12d
  8041606237:	0f 85 2b 14 00 00    	jne    8041607668 <mem_init+0x23bc>
  cprintf("check_page_alloc() succeeded!\n");
  804160623d:	48 bf 38 d7 60 41 80 	movabs $0x804160d738,%rdi
  8041606244:	00 00 00 
  8041606247:	b8 00 00 00 00       	mov    $0x0,%eax
  804160624c:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041606253:	00 00 00 
  8041606256:	ff d2                	callq  *%rdx
  boot_map_region(kern_pml4e, UPAGES, ROUNDUP(npages * sizeof(*pages), PGSIZE), PADDR(pages), PTE_U | PTE_P);
  8041606258:	48 a1 58 5b 70 41 80 	movabs 0x8041705b58,%rax
  804160625f:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  8041606262:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041606269:	00 00 00 
  804160626c:	48 39 d0             	cmp    %rdx,%rax
  804160626f:	0f 86 28 14 00 00    	jbe    804160769d <mem_init+0x23f1>
  return (physaddr_t)kva - KERNBASE;
  8041606275:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  804160627c:	ff ff ff 
  804160627f:	48 01 c1             	add    %rax,%rcx
  8041606282:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041606289:	00 00 00 
  804160628c:	48 8b 10             	mov    (%rax),%rdx
  804160628f:	48 c1 e2 04          	shl    $0x4,%rdx
  8041606293:	48 81 c2 ff 0f 00 00 	add    $0xfff,%rdx
  804160629a:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  80416062a1:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  80416062a7:	48 be 00 e0 42 3c 80 	movabs $0x803c42e000,%rsi
  80416062ae:	00 00 00 
  80416062b1:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  80416062b8:	00 00 00 
  80416062bb:	48 8b 38             	mov    (%rax),%rdi
  80416062be:	48 b8 e2 4f 60 41 80 	movabs $0x8041604fe2,%rax
  80416062c5:	00 00 00 
  80416062c8:	ff d0                	callq  *%rax
  boot_map_region(kern_pml4e, UENVS, ROUNDUP(NENV * sizeof(*envs), PGSIZE), PADDR(envs), PTE_U | PTE_P);
  80416062ca:	48 a1 20 46 70 41 80 	movabs 0x8041704620,%rax
  80416062d1:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  80416062d4:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  80416062db:	00 00 00 
  80416062de:	48 39 d0             	cmp    %rdx,%rax
  80416062e1:	0f 86 e4 13 00 00    	jbe    80416076cb <mem_init+0x241f>
  return (physaddr_t)kva - KERNBASE;
  80416062e7:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  80416062ee:	ff ff ff 
  80416062f1:	48 01 c1             	add    %rax,%rcx
  80416062f4:	41 b8 05 00 00 00    	mov    $0x5,%r8d
  80416062fa:	ba 00 20 00 00       	mov    $0x2000,%edx
  80416062ff:	48 be 00 e0 22 3c 80 	movabs $0x803c22e000,%rsi
  8041606306:	00 00 00 
  8041606309:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041606310:	00 00 00 
  8041606313:	48 8b 38             	mov    (%rax),%rdi
  8041606316:	48 b8 e2 4f 60 41 80 	movabs $0x8041604fe2,%rax
  804160631d:	00 00 00 
  8041606320:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041606322:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  8041606329:	00 00 00 
  804160632c:	48 bf 00 f0 60 41 80 	movabs $0x804160f000,%rdi
  8041606333:	00 00 00 
  8041606336:	48 39 c7             	cmp    %rax,%rdi
  8041606339:	0f 86 ba 13 00 00    	jbe    80416076f9 <mem_init+0x244d>
  return (physaddr_t)kva - KERNBASE;
  804160633f:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  8041606346:	ff ff ff 
  8041606349:	48 b8 00 f0 60 41 80 	movabs $0x804160f000,%rax
  8041606350:	00 00 00 
  8041606353:	49 01 c6             	add    %rax,%r14
  boot_map_region(kern_pml4e, KSTACKTOP - KSTKSIZE, KSTACKTOP - (KSTACKTOP - KSTKSIZE), PADDR(bootstack), PTE_W | PTE_P);
  8041606356:	49 bd 40 5b 70 41 80 	movabs $0x8041705b40,%r13
  804160635d:	00 00 00 
  8041606360:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041606366:	4c 89 f1             	mov    %r14,%rcx
  8041606369:	ba 00 00 01 00       	mov    $0x10000,%edx
  804160636e:	48 be 00 00 ff 3f 80 	movabs $0x803fff0000,%rsi
  8041606375:	00 00 00 
  8041606378:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  804160637c:	49 bc e2 4f 60 41 80 	movabs $0x8041604fe2,%r12
  8041606383:	00 00 00 
  8041606386:	41 ff d4             	callq  *%r12
  boot_map_region(kern_pml4e, X86ADDR(KSTACKTOP - KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);
  8041606389:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  804160638f:	4c 89 f1             	mov    %r14,%rcx
  8041606392:	ba 00 00 01 00       	mov    $0x10000,%edx
  8041606397:	be 00 00 ff 3f       	mov    $0x3fff0000,%esi
  804160639c:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  80416063a0:	41 ff d4             	callq  *%r12
  boot_map_region(kern_pml4e, KERNBASE, npages * PGSIZE, 0, PTE_W | PTE_P);
  80416063a3:	49 be 50 5b 70 41 80 	movabs $0x8041705b50,%r14
  80416063aa:	00 00 00 
  80416063ad:	49 8b 16             	mov    (%r14),%rdx
  80416063b0:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416063b4:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416063ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416063bf:	48 be 00 00 00 40 80 	movabs $0x8040000000,%rsi
  80416063c6:	00 00 00 
  80416063c9:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  80416063cd:	41 ff d4             	callq  *%r12
  size_to_alloc = MIN(0x3200000, npages * PGSIZE);
  80416063d0:	49 8b 16             	mov    (%r14),%rdx
  80416063d3:	48 c1 e2 0c          	shl    $0xc,%rdx
  80416063d7:	48 81 fa 00 00 20 03 	cmp    $0x3200000,%rdx
  80416063de:	b8 00 00 20 03       	mov    $0x3200000,%eax
  80416063e3:	48 0f 47 d0          	cmova  %rax,%rdx
  boot_map_region(kern_pml4e, X86ADDR(KERNBASE), size_to_alloc, 0, PTE_P | PTE_W);
  80416063e7:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  80416063ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416063f2:	be 00 00 00 40       	mov    $0x40000000,%esi
  80416063f7:	49 8b 7d 00          	mov    0x0(%r13),%rdi
  80416063fb:	41 ff d4             	callq  *%r12
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  80416063fe:	48 b8 f0 45 70 41 80 	movabs $0x80417045f0,%rax
  8041606405:	00 00 00 
  8041606408:	4c 8b 20             	mov    (%rax),%r12
  804160640b:	48 b8 e8 45 70 41 80 	movabs $0x80417045e8,%rax
  8041606412:	00 00 00 
  8041606415:	4c 3b 20             	cmp    (%rax),%r12
  8041606418:	0f 83 4a 13 00 00    	jae    8041607768 <mem_init+0x24bc>
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  804160641e:	4d 89 ef             	mov    %r13,%r15
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606421:	49 be e0 45 70 41 80 	movabs $0x80417045e0,%r14
  8041606428:	00 00 00 
  804160642b:	49 89 c5             	mov    %rax,%r13
  804160642e:	e9 2b 13 00 00       	jmpq   804160775e <mem_init+0x24b2>
  mem_map_size     = desc->MemoryMapDescriptorSize;
  8041606433:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8041606437:	48 89 c3             	mov    %rax,%rbx
  804160643a:	48 89 f0             	mov    %rsi,%rax
  804160643d:	48 a3 e0 45 70 41 80 	movabs %rax,0x80417045e0
  8041606444:	00 00 00 
  mmap_base        = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)desc->MemoryMap;
  8041606447:	48 89 fa             	mov    %rdi,%rdx
  804160644a:	48 89 f8             	mov    %rdi,%rax
  804160644d:	48 a3 f0 45 70 41 80 	movabs %rax,0x80417045f0
  8041606454:	00 00 00 
  mmap_end         = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)desc->MemoryMap + desc->MemoryMapSize);
  8041606457:	48 89 f9             	mov    %rdi,%rcx
  804160645a:	48 03 4b 38          	add    0x38(%rbx),%rcx
  804160645e:	48 89 c8             	mov    %rcx,%rax
  8041606461:	48 a3 e8 45 70 41 80 	movabs %rax,0x80417045e8
  8041606468:	00 00 00 
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  804160646b:	48 39 cf             	cmp    %rcx,%rdi
  804160646e:	73 33                	jae    80416064a3 <mem_init+0x11f7>
  size_t num_pages = 0;
  8041606470:	bb 00 00 00 00       	mov    $0x0,%ebx
    num_pages += mmap_curr->NumberOfPages;
  8041606475:	48 03 5a 18          	add    0x18(%rdx),%rbx
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  8041606479:	48 01 f2             	add    %rsi,%rdx
  804160647c:	48 39 d1             	cmp    %rdx,%rcx
  804160647f:	77 f4                	ja     8041606475 <mem_init+0x11c9>
  *npages_basemem = num_pages > (IOPHYSMEM / PGSIZE) ? IOPHYSMEM / PGSIZE : num_pages;
  8041606481:	48 81 fb a0 00 00 00 	cmp    $0xa0,%rbx
  8041606488:	ba a0 00 00 00       	mov    $0xa0,%edx
  804160648d:	48 0f 46 d3          	cmovbe %rbx,%rdx
  8041606491:	48 89 d0             	mov    %rdx,%rax
  8041606494:	48 a3 10 46 70 41 80 	movabs %rax,0x8041704610
  804160649b:	00 00 00 
  *npages_extmem  = num_pages - *npages_basemem;
  804160649e:	48 29 d3             	sub    %rdx,%rbx
  80416064a1:	eb 0f                	jmp    80416064b2 <mem_init+0x1206>
  size_t num_pages = 0;
  80416064a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416064a8:	eb d7                	jmp    8041606481 <mem_init+0x11d5>
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
  80416064aa:	c1 e3 0a             	shl    $0xa,%ebx
  80416064ad:	c1 eb 0c             	shr    $0xc,%ebx
  80416064b0:	89 db                	mov    %ebx,%ebx
    npages = npages_basemem;
  80416064b2:	48 b8 10 46 70 41 80 	movabs $0x8041704610,%rax
  80416064b9:	00 00 00 
  80416064bc:	48 8b 30             	mov    (%rax),%rsi
  if (npages_extmem)
  80416064bf:	48 85 db             	test   %rbx,%rbx
  80416064c2:	0f 84 6a ee ff ff    	je     8041605332 <mem_init+0x86>
  80416064c8:	e9 5e ee ff ff       	jmpq   804160532b <mem_init+0x7f>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  80416064cd:	48 89 d9             	mov    %rbx,%rcx
  80416064d0:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  80416064d7:	00 00 00 
  80416064da:	be ea 00 00 00       	mov    $0xea,%esi
  80416064df:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416064e6:	00 00 00 
  80416064e9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416064ee:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416064f5:	00 00 00 
  80416064f8:	41 ff d0             	callq  *%r8
  assert(pp0 = page_alloc(0));
  80416064fb:	48 b9 6e da 60 41 80 	movabs $0x804160da6e,%rcx
  8041606502:	00 00 00 
  8041606505:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160650c:	00 00 00 
  804160650f:	be 9b 04 00 00       	mov    $0x49b,%esi
  8041606514:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160651b:	00 00 00 
  804160651e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606523:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160652a:	00 00 00 
  804160652d:	41 ff d0             	callq  *%r8
  assert(pp1 = page_alloc(0));
  8041606530:	48 b9 82 da 60 41 80 	movabs $0x804160da82,%rcx
  8041606537:	00 00 00 
  804160653a:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606541:	00 00 00 
  8041606544:	be 9c 04 00 00       	mov    $0x49c,%esi
  8041606549:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606550:	00 00 00 
  8041606553:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606558:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160655f:	00 00 00 
  8041606562:	41 ff d0             	callq  *%r8
  assert(pp2 = page_alloc(0));
  8041606565:	48 b9 96 da 60 41 80 	movabs $0x804160da96,%rcx
  804160656c:	00 00 00 
  804160656f:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606576:	00 00 00 
  8041606579:	be 9d 04 00 00       	mov    $0x49d,%esi
  804160657e:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606585:	00 00 00 
  8041606588:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160658f:	00 00 00 
  8041606592:	41 ff d0             	callq  *%r8
  assert(pp3 = page_alloc(0));
  8041606595:	48 b9 aa da 60 41 80 	movabs $0x804160daaa,%rcx
  804160659c:	00 00 00 
  804160659f:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416065a6:	00 00 00 
  80416065a9:	be 9e 04 00 00       	mov    $0x49e,%esi
  80416065ae:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416065b5:	00 00 00 
  80416065b8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416065bd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065c4:	00 00 00 
  80416065c7:	41 ff d0             	callq  *%r8
  assert(pp4 = page_alloc(0));
  80416065ca:	48 b9 be da 60 41 80 	movabs $0x804160dabe,%rcx
  80416065d1:	00 00 00 
  80416065d4:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416065db:	00 00 00 
  80416065de:	be 9f 04 00 00       	mov    $0x49f,%esi
  80416065e3:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416065ea:	00 00 00 
  80416065ed:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416065f4:	00 00 00 
  80416065f7:	41 ff d0             	callq  *%r8
  assert(pp5 = page_alloc(0));
  80416065fa:	48 b9 d2 da 60 41 80 	movabs $0x804160dad2,%rcx
  8041606601:	00 00 00 
  8041606604:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160660b:	00 00 00 
  804160660e:	be a0 04 00 00       	mov    $0x4a0,%esi
  8041606613:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160661a:	00 00 00 
  804160661d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606624:	00 00 00 
  8041606627:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  804160662a:	48 b9 e6 da 60 41 80 	movabs $0x804160dae6,%rcx
  8041606631:	00 00 00 
  8041606634:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160663b:	00 00 00 
  804160663e:	be a3 04 00 00       	mov    $0x4a3,%esi
  8041606643:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160664a:	00 00 00 
  804160664d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606652:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606659:	00 00 00 
  804160665c:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  804160665f:	48 b9 38 d2 60 41 80 	movabs $0x804160d238,%rcx
  8041606666:	00 00 00 
  8041606669:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606670:	00 00 00 
  8041606673:	be a4 04 00 00       	mov    $0x4a4,%esi
  8041606678:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160667f:	00 00 00 
  8041606682:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606687:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160668e:	00 00 00 
  8041606691:	41 ff d0             	callq  *%r8
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  8041606694:	48 b9 58 d2 60 41 80 	movabs $0x804160d258,%rcx
  804160669b:	00 00 00 
  804160669e:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416066a5:	00 00 00 
  80416066a8:	be a5 04 00 00       	mov    $0x4a5,%esi
  80416066ad:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416066b4:	00 00 00 
  80416066b7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066bc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066c3:	00 00 00 
  80416066c6:	41 ff d0             	callq  *%r8
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  80416066c9:	48 b9 88 d2 60 41 80 	movabs $0x804160d288,%rcx
  80416066d0:	00 00 00 
  80416066d3:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416066da:	00 00 00 
  80416066dd:	be a6 04 00 00       	mov    $0x4a6,%esi
  80416066e2:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416066e9:	00 00 00 
  80416066ec:	b8 00 00 00 00       	mov    $0x0,%eax
  80416066f1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416066f8:	00 00 00 
  80416066fb:	41 ff d0             	callq  *%r8
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  80416066fe:	48 b9 c8 d2 60 41 80 	movabs $0x804160d2c8,%rcx
  8041606705:	00 00 00 
  8041606708:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160670f:	00 00 00 
  8041606712:	be a7 04 00 00       	mov    $0x4a7,%esi
  8041606717:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160671e:	00 00 00 
  8041606721:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606726:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160672d:	00 00 00 
  8041606730:	41 ff d0             	callq  *%r8
  assert(fl != NULL);
  8041606733:	48 b9 f8 da 60 41 80 	movabs $0x804160daf8,%rcx
  804160673a:	00 00 00 
  804160673d:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606744:	00 00 00 
  8041606747:	be ab 04 00 00       	mov    $0x4ab,%esi
  804160674c:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606753:	00 00 00 
  8041606756:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160675d:	00 00 00 
  8041606760:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606763:	48 b9 03 db 60 41 80 	movabs $0x804160db03,%rcx
  804160676a:	00 00 00 
  804160676d:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606774:	00 00 00 
  8041606777:	be af 04 00 00       	mov    $0x4af,%esi
  804160677c:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606783:	00 00 00 
  8041606786:	b8 00 00 00 00       	mov    $0x0,%eax
  804160678b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606792:	00 00 00 
  8041606795:	41 ff d0             	callq  *%r8
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);
  8041606798:	48 b9 18 d3 60 41 80 	movabs $0x804160d318,%rcx
  804160679f:	00 00 00 
  80416067a2:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416067a9:	00 00 00 
  80416067ac:	be b2 04 00 00       	mov    $0x4b2,%esi
  80416067b1:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416067b8:	00 00 00 
  80416067bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067c0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067c7:	00 00 00 
  80416067ca:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  80416067cd:	48 b9 50 d3 60 41 80 	movabs $0x804160d350,%rcx
  80416067d4:	00 00 00 
  80416067d7:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416067de:	00 00 00 
  80416067e1:	be b5 04 00 00       	mov    $0x4b5,%esi
  80416067e6:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416067ed:	00 00 00 
  80416067f0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416067f5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416067fc:	00 00 00 
  80416067ff:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  8041606802:	48 b9 50 d3 60 41 80 	movabs $0x804160d350,%rcx
  8041606809:	00 00 00 
  804160680c:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606813:	00 00 00 
  8041606816:	be b9 04 00 00       	mov    $0x4b9,%esi
  804160681b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606822:	00 00 00 
  8041606825:	b8 00 00 00 00       	mov    $0x0,%eax
  804160682a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606831:	00 00 00 
  8041606834:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  8041606837:	48 b9 80 d3 60 41 80 	movabs $0x804160d380,%rcx
  804160683e:	00 00 00 
  8041606841:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606848:	00 00 00 
  804160684b:	be bf 04 00 00       	mov    $0x4bf,%esi
  8041606850:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606857:	00 00 00 
  804160685a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160685f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606866:	00 00 00 
  8041606869:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  804160686c:	48 b9 b0 d3 60 41 80 	movabs $0x804160d3b0,%rcx
  8041606873:	00 00 00 
  8041606876:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160687d:	00 00 00 
  8041606880:	be c0 04 00 00       	mov    $0x4c0,%esi
  8041606885:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160688c:	00 00 00 
  804160688f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606894:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160689b:	00 00 00 
  804160689e:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  80416068a1:	48 b9 30 d4 60 41 80 	movabs $0x804160d430,%rcx
  80416068a8:	00 00 00 
  80416068ab:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416068b2:	00 00 00 
  80416068b5:	be c1 04 00 00       	mov    $0x4c1,%esi
  80416068ba:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416068c1:	00 00 00 
  80416068c4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068c9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416068d0:	00 00 00 
  80416068d3:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  80416068d6:	48 b9 12 db 60 41 80 	movabs $0x804160db12,%rcx
  80416068dd:	00 00 00 
  80416068e0:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416068e7:	00 00 00 
  80416068ea:	be c2 04 00 00       	mov    $0x4c2,%esi
  80416068ef:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416068f6:	00 00 00 
  80416068f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416068fe:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606905:	00 00 00 
  8041606908:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  804160690b:	48 b9 60 d4 60 41 80 	movabs $0x804160d460,%rcx
  8041606912:	00 00 00 
  8041606915:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160691c:	00 00 00 
  804160691f:	be c4 04 00 00       	mov    $0x4c4,%esi
  8041606924:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160692b:	00 00 00 
  804160692e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606933:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160693a:	00 00 00 
  804160693d:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606940:	48 b9 98 d4 60 41 80 	movabs $0x804160d498,%rcx
  8041606947:	00 00 00 
  804160694a:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606951:	00 00 00 
  8041606954:	be c5 04 00 00       	mov    $0x4c5,%esi
  8041606959:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606960:	00 00 00 
  8041606963:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606968:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160696f:	00 00 00 
  8041606972:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606975:	48 b9 23 db 60 41 80 	movabs $0x804160db23,%rcx
  804160697c:	00 00 00 
  804160697f:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606986:	00 00 00 
  8041606989:	be c6 04 00 00       	mov    $0x4c6,%esi
  804160698e:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606995:	00 00 00 
  8041606998:	b8 00 00 00 00       	mov    $0x0,%eax
  804160699d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069a4:	00 00 00 
  80416069a7:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  80416069aa:	48 b9 03 db 60 41 80 	movabs $0x804160db03,%rcx
  80416069b1:	00 00 00 
  80416069b4:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416069bb:	00 00 00 
  80416069be:	be c9 04 00 00       	mov    $0x4c9,%esi
  80416069c3:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416069ca:	00 00 00 
  80416069cd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416069d2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416069d9:	00 00 00 
  80416069dc:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  80416069df:	48 b9 60 d4 60 41 80 	movabs $0x804160d460,%rcx
  80416069e6:	00 00 00 
  80416069e9:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416069f0:	00 00 00 
  80416069f3:	be cc 04 00 00       	mov    $0x4cc,%esi
  80416069f8:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416069ff:	00 00 00 
  8041606a02:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a07:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a0e:	00 00 00 
  8041606a11:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606a14:	48 b9 98 d4 60 41 80 	movabs $0x804160d498,%rcx
  8041606a1b:	00 00 00 
  8041606a1e:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606a25:	00 00 00 
  8041606a28:	be cd 04 00 00       	mov    $0x4cd,%esi
  8041606a2d:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606a34:	00 00 00 
  8041606a37:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a3c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a43:	00 00 00 
  8041606a46:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606a49:	48 b9 23 db 60 41 80 	movabs $0x804160db23,%rcx
  8041606a50:	00 00 00 
  8041606a53:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606a5a:	00 00 00 
  8041606a5d:	be ce 04 00 00       	mov    $0x4ce,%esi
  8041606a62:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606a69:	00 00 00 
  8041606a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606a71:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606a78:	00 00 00 
  8041606a7b:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041606a7e:	48 b9 03 db 60 41 80 	movabs $0x804160db03,%rcx
  8041606a85:	00 00 00 
  8041606a88:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606a8f:	00 00 00 
  8041606a92:	be d2 04 00 00       	mov    $0x4d2,%esi
  8041606a97:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606a9e:	00 00 00 
  8041606aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606aa6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606aad:	00 00 00 
  8041606ab0:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041606ab3:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041606aba:	00 00 00 
  8041606abd:	be d4 04 00 00       	mov    $0x4d4,%esi
  8041606ac2:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606ac9:	00 00 00 
  8041606acc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ad1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ad8:	00 00 00 
  8041606adb:	41 ff d0             	callq  *%r8
  8041606ade:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041606ae5:	00 00 00 
  8041606ae8:	be d5 04 00 00       	mov    $0x4d5,%esi
  8041606aed:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606af4:	00 00 00 
  8041606af7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606afc:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b03:	00 00 00 
  8041606b06:	41 ff d0             	callq  *%r8
  8041606b09:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041606b10:	00 00 00 
  8041606b13:	be d6 04 00 00       	mov    $0x4d6,%esi
  8041606b18:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606b1f:	00 00 00 
  8041606b22:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b27:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b2e:	00 00 00 
  8041606b31:	41 ff d0             	callq  *%r8
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
  8041606b34:	48 b9 c8 d4 60 41 80 	movabs $0x804160d4c8,%rcx
  8041606b3b:	00 00 00 
  8041606b3e:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606b45:	00 00 00 
  8041606b48:	be d7 04 00 00       	mov    $0x4d7,%esi
  8041606b4d:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606b54:	00 00 00 
  8041606b57:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b5c:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b63:	00 00 00 
  8041606b66:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  8041606b69:	48 b9 08 d5 60 41 80 	movabs $0x804160d508,%rcx
  8041606b70:	00 00 00 
  8041606b73:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606b7a:	00 00 00 
  8041606b7d:	be da 04 00 00       	mov    $0x4da,%esi
  8041606b82:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606b89:	00 00 00 
  8041606b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606b91:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606b98:	00 00 00 
  8041606b9b:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  8041606b9e:	48 b9 98 d4 60 41 80 	movabs $0x804160d498,%rcx
  8041606ba5:	00 00 00 
  8041606ba8:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606baf:	00 00 00 
  8041606bb2:	be db 04 00 00       	mov    $0x4db,%esi
  8041606bb7:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606bbe:	00 00 00 
  8041606bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bc6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606bcd:	00 00 00 
  8041606bd0:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 2);
  8041606bd3:	48 b9 23 db 60 41 80 	movabs $0x804160db23,%rcx
  8041606bda:	00 00 00 
  8041606bdd:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606be4:	00 00 00 
  8041606be7:	be dc 04 00 00       	mov    $0x4dc,%esi
  8041606bec:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606bf3:	00 00 00 
  8041606bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606bfb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c02:	00 00 00 
  8041606c05:	41 ff d0             	callq  *%r8
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  8041606c08:	48 b9 48 d5 60 41 80 	movabs $0x804160d548,%rcx
  8041606c0f:	00 00 00 
  8041606c12:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606c19:	00 00 00 
  8041606c1c:	be dd 04 00 00       	mov    $0x4dd,%esi
  8041606c21:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606c28:	00 00 00 
  8041606c2b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c30:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c37:	00 00 00 
  8041606c3a:	41 ff d0             	callq  *%r8
  assert(kern_pml4e[0] & PTE_U);
  8041606c3d:	48 b9 34 db 60 41 80 	movabs $0x804160db34,%rcx
  8041606c44:	00 00 00 
  8041606c47:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606c4e:	00 00 00 
  8041606c51:	be de 04 00 00       	mov    $0x4de,%esi
  8041606c56:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606c5d:	00 00 00 
  8041606c60:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c65:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606c6c:	00 00 00 
  8041606c6f:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);
  8041606c72:	48 b9 80 d5 60 41 80 	movabs $0x804160d580,%rcx
  8041606c79:	00 00 00 
  8041606c7c:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606c83:	00 00 00 
  8041606c86:	be e1 04 00 00       	mov    $0x4e1,%esi
  8041606c8b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606c92:	00 00 00 
  8041606c95:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606c9a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ca1:	00 00 00 
  8041606ca4:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606ca7:	48 b9 b8 d5 60 41 80 	movabs $0x804160d5b8,%rcx
  8041606cae:	00 00 00 
  8041606cb1:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606cb8:	00 00 00 
  8041606cbb:	be e4 04 00 00       	mov    $0x4e4,%esi
  8041606cc0:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606cc7:	00 00 00 
  8041606cca:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ccf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606cd6:	00 00 00 
  8041606cd9:	41 ff d0             	callq  *%r8
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));
  8041606cdc:	48 b9 f0 d5 60 41 80 	movabs $0x804160d5f0,%rcx
  8041606ce3:	00 00 00 
  8041606ce6:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606ced:	00 00 00 
  8041606cf0:	be e5 04 00 00       	mov    $0x4e5,%esi
  8041606cf5:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606cfc:	00 00 00 
  8041606cff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d04:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d0b:	00 00 00 
  8041606d0e:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  8041606d11:	48 b9 28 d6 60 41 80 	movabs $0x804160d628,%rcx
  8041606d18:	00 00 00 
  8041606d1b:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606d22:	00 00 00 
  8041606d25:	be e8 04 00 00       	mov    $0x4e8,%esi
  8041606d2a:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606d31:	00 00 00 
  8041606d34:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d39:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d40:	00 00 00 
  8041606d43:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606d46:	48 b9 58 d6 60 41 80 	movabs $0x804160d658,%rcx
  8041606d4d:	00 00 00 
  8041606d50:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606d57:	00 00 00 
  8041606d5a:	be e9 04 00 00       	mov    $0x4e9,%esi
  8041606d5f:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606d66:	00 00 00 
  8041606d69:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606d6e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606d75:	00 00 00 
  8041606d78:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 2);
  8041606d7b:	48 b9 4a db 60 41 80 	movabs $0x804160db4a,%rcx
  8041606d82:	00 00 00 
  8041606d85:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606d8c:	00 00 00 
  8041606d8f:	be eb 04 00 00       	mov    $0x4eb,%esi
  8041606d94:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606d9b:	00 00 00 
  8041606d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606da3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606daa:	00 00 00 
  8041606dad:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606db0:	48 b9 5b db 60 41 80 	movabs $0x804160db5b,%rcx
  8041606db7:	00 00 00 
  8041606dba:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606dc1:	00 00 00 
  8041606dc4:	be ec 04 00 00       	mov    $0x4ec,%esi
  8041606dc9:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606dd0:	00 00 00 
  8041606dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606dd8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ddf:	00 00 00 
  8041606de2:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606de5:	48 b9 88 d6 60 41 80 	movabs $0x804160d688,%rcx
  8041606dec:	00 00 00 
  8041606def:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606df6:	00 00 00 
  8041606df9:	be f0 04 00 00       	mov    $0x4f0,%esi
  8041606dfe:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606e05:	00 00 00 
  8041606e08:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e0d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e14:	00 00 00 
  8041606e17:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  8041606e1a:	48 b9 58 d6 60 41 80 	movabs $0x804160d658,%rcx
  8041606e21:	00 00 00 
  8041606e24:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606e2b:	00 00 00 
  8041606e2e:	be f1 04 00 00       	mov    $0x4f1,%esi
  8041606e33:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606e3a:	00 00 00 
  8041606e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e42:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e49:	00 00 00 
  8041606e4c:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  8041606e4f:	48 b9 12 db 60 41 80 	movabs $0x804160db12,%rcx
  8041606e56:	00 00 00 
  8041606e59:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606e60:	00 00 00 
  8041606e63:	be f2 04 00 00       	mov    $0x4f2,%esi
  8041606e68:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606e6f:	00 00 00 
  8041606e72:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606e77:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606e7e:	00 00 00 
  8041606e81:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606e84:	48 b9 5b db 60 41 80 	movabs $0x804160db5b,%rcx
  8041606e8b:	00 00 00 
  8041606e8e:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606e95:	00 00 00 
  8041606e98:	be f3 04 00 00       	mov    $0x4f3,%esi
  8041606e9d:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606ea4:	00 00 00 
  8041606ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606eac:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606eb3:	00 00 00 
  8041606eb6:	41 ff d0             	callq  *%r8
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  8041606eb9:	48 b9 b8 d5 60 41 80 	movabs $0x804160d5b8,%rcx
  8041606ec0:	00 00 00 
  8041606ec3:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606eca:	00 00 00 
  8041606ecd:	be f7 04 00 00       	mov    $0x4f7,%esi
  8041606ed2:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606ed9:	00 00 00 
  8041606edc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606ee1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ee8:	00 00 00 
  8041606eeb:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref);
  8041606eee:	48 b9 6c db 60 41 80 	movabs $0x804160db6c,%rcx
  8041606ef5:	00 00 00 
  8041606ef8:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606eff:	00 00 00 
  8041606f02:	be f8 04 00 00       	mov    $0x4f8,%esi
  8041606f07:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606f0e:	00 00 00 
  8041606f11:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f16:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f1d:	00 00 00 
  8041606f20:	41 ff d0             	callq  *%r8
  assert(pp1->pp_link == NULL);
  8041606f23:	48 b9 78 db 60 41 80 	movabs $0x804160db78,%rcx
  8041606f2a:	00 00 00 
  8041606f2d:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606f34:	00 00 00 
  8041606f37:	be f9 04 00 00       	mov    $0x4f9,%esi
  8041606f3c:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606f43:	00 00 00 
  8041606f46:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f4b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f52:	00 00 00 
  8041606f55:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  8041606f58:	48 b9 88 d6 60 41 80 	movabs $0x804160d688,%rcx
  8041606f5f:	00 00 00 
  8041606f62:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606f69:	00 00 00 
  8041606f6c:	be fd 04 00 00       	mov    $0x4fd,%esi
  8041606f71:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606f78:	00 00 00 
  8041606f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606f80:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606f87:	00 00 00 
  8041606f8a:	41 ff d0             	callq  *%r8
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  8041606f8d:	48 b9 b0 d6 60 41 80 	movabs $0x804160d6b0,%rcx
  8041606f94:	00 00 00 
  8041606f97:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606f9e:	00 00 00 
  8041606fa1:	be fe 04 00 00       	mov    $0x4fe,%esi
  8041606fa6:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606fad:	00 00 00 
  8041606fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606fb5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606fbc:	00 00 00 
  8041606fbf:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041606fc2:	48 b9 8d db 60 41 80 	movabs $0x804160db8d,%rcx
  8041606fc9:	00 00 00 
  8041606fcc:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041606fd3:	00 00 00 
  8041606fd6:	be ff 04 00 00       	mov    $0x4ff,%esi
  8041606fdb:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041606fe2:	00 00 00 
  8041606fe5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041606fea:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041606ff1:	00 00 00 
  8041606ff4:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041606ff7:	48 b9 5b db 60 41 80 	movabs $0x804160db5b,%rcx
  8041606ffe:	00 00 00 
  8041607001:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607008:	00 00 00 
  804160700b:	be 00 05 00 00       	mov    $0x500,%esi
  8041607010:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607017:	00 00 00 
  804160701a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160701f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607026:	00 00 00 
  8041607029:	41 ff d0             	callq  *%r8
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  804160702c:	48 b9 b0 d3 60 41 80 	movabs $0x804160d3b0,%rcx
  8041607033:	00 00 00 
  8041607036:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160703d:	00 00 00 
  8041607040:	be 13 05 00 00       	mov    $0x513,%esi
  8041607045:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160704c:	00 00 00 
  804160704f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607054:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160705b:	00 00 00 
  804160705e:	41 ff d0             	callq  *%r8
  assert(pp3->pp_ref == 1);
  8041607061:	48 b9 5b db 60 41 80 	movabs $0x804160db5b,%rcx
  8041607068:	00 00 00 
  804160706b:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607072:	00 00 00 
  8041607075:	be 15 05 00 00       	mov    $0x515,%esi
  804160707a:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607081:	00 00 00 
  8041607084:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607089:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607090:	00 00 00 
  8041607093:	41 ff d0             	callq  *%r8
  8041607096:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  804160709d:	00 00 00 
  80416070a0:	be 1c 05 00 00       	mov    $0x51c,%esi
  80416070a5:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416070ac:	00 00 00 
  80416070af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070b4:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070bb:	00 00 00 
  80416070be:	41 ff d0             	callq  *%r8
  80416070c1:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  80416070c8:	00 00 00 
  80416070cb:	be 1d 05 00 00       	mov    $0x51d,%esi
  80416070d0:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416070d7:	00 00 00 
  80416070da:	b8 00 00 00 00       	mov    $0x0,%eax
  80416070df:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416070e6:	00 00 00 
  80416070e9:	41 ff d0             	callq  *%r8
  80416070ec:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  80416070f3:	00 00 00 
  80416070f6:	be 1e 05 00 00       	mov    $0x51e,%esi
  80416070fb:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607102:	00 00 00 
  8041607105:	b8 00 00 00 00       	mov    $0x0,%eax
  804160710a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607111:	00 00 00 
  8041607114:	41 ff d0             	callq  *%r8
  assert(ptep == ptep1 + PTX(va));
  8041607117:	48 b9 9e db 60 41 80 	movabs $0x804160db9e,%rcx
  804160711e:	00 00 00 
  8041607121:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607128:	00 00 00 
  804160712b:	be 1f 05 00 00       	mov    $0x51f,%esi
  8041607130:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607137:	00 00 00 
  804160713a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160713f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607146:	00 00 00 
  8041607149:	41 ff d0             	callq  *%r8
  804160714c:	48 89 f9             	mov    %rdi,%rcx
  804160714f:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041607156:	00 00 00 
  8041607159:	be 61 00 00 00       	mov    $0x61,%esi
  804160715e:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041607165:	00 00 00 
  8041607168:	b8 00 00 00 00       	mov    $0x0,%eax
  804160716d:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607174:	00 00 00 
  8041607177:	41 ff d0             	callq  *%r8
  804160717a:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041607181:	00 00 00 
  8041607184:	be 25 05 00 00       	mov    $0x525,%esi
  8041607189:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607190:	00 00 00 
  8041607193:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607198:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160719f:	00 00 00 
  80416071a2:	41 ff d0             	callq  *%r8
  80416071a5:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  80416071ac:	00 00 00 
  80416071af:	be 26 05 00 00       	mov    $0x526,%esi
  80416071b4:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416071bb:	00 00 00 
  80416071be:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071c3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071ca:	00 00 00 
  80416071cd:	41 ff d0             	callq  *%r8
  80416071d0:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  80416071d7:	00 00 00 
  80416071da:	be 27 05 00 00       	mov    $0x527,%esi
  80416071df:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416071e6:	00 00 00 
  80416071e9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416071ee:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416071f5:	00 00 00 
  80416071f8:	41 ff d0             	callq  *%r8
    assert((ptep[i] & PTE_P) == 0);
  80416071fb:	48 b9 b6 db 60 41 80 	movabs $0x804160dbb6,%rcx
  8041607202:	00 00 00 
  8041607205:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160720c:	00 00 00 
  804160720f:	be 29 05 00 00       	mov    $0x529,%esi
  8041607214:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160721b:	00 00 00 
  804160721e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607223:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160722a:	00 00 00 
  804160722d:	41 ff d0             	callq  *%r8
    panic("'pages' is a null pointer!");
  8041607230:	48 ba e6 db 60 41 80 	movabs $0x804160dbe6,%rdx
  8041607237:	00 00 00 
  804160723a:	be f0 03 00 00       	mov    $0x3f0,%esi
  804160723f:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607246:	00 00 00 
  8041607249:	b8 00 00 00 00       	mov    $0x0,%eax
  804160724e:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041607255:	00 00 00 
  8041607258:	ff d1                	callq  *%rcx
  assert((pp0 = page_alloc(0)));
  804160725a:	48 b9 01 dc 60 41 80 	movabs $0x804160dc01,%rcx
  8041607261:	00 00 00 
  8041607264:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160726b:	00 00 00 
  804160726e:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041607273:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160727a:	00 00 00 
  804160727d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607282:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607289:	00 00 00 
  804160728c:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  804160728f:	48 b9 17 dc 60 41 80 	movabs $0x804160dc17,%rcx
  8041607296:	00 00 00 
  8041607299:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416072a0:	00 00 00 
  80416072a3:	be f9 03 00 00       	mov    $0x3f9,%esi
  80416072a8:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416072af:	00 00 00 
  80416072b2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072b7:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072be:	00 00 00 
  80416072c1:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  80416072c4:	48 b9 2d dc 60 41 80 	movabs $0x804160dc2d,%rcx
  80416072cb:	00 00 00 
  80416072ce:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416072d5:	00 00 00 
  80416072d8:	be fa 03 00 00       	mov    $0x3fa,%esi
  80416072dd:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416072e4:	00 00 00 
  80416072e7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416072ec:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416072f3:	00 00 00 
  80416072f6:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  80416072f9:	48 b9 e6 da 60 41 80 	movabs $0x804160dae6,%rcx
  8041607300:	00 00 00 
  8041607303:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160730a:	00 00 00 
  804160730d:	be fd 03 00 00       	mov    $0x3fd,%esi
  8041607312:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607319:	00 00 00 
  804160731c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607321:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607328:	00 00 00 
  804160732b:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  804160732e:	48 b9 38 d2 60 41 80 	movabs $0x804160d238,%rcx
  8041607335:	00 00 00 
  8041607338:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160733f:	00 00 00 
  8041607342:	be fe 03 00 00       	mov    $0x3fe,%esi
  8041607347:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160734e:	00 00 00 
  8041607351:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607356:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160735d:	00 00 00 
  8041607360:	41 ff d0             	callq  *%r8
  assert(page2pa(pp0) < npages * PGSIZE);
  8041607363:	48 b9 d8 d6 60 41 80 	movabs $0x804160d6d8,%rcx
  804160736a:	00 00 00 
  804160736d:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607374:	00 00 00 
  8041607377:	be ff 03 00 00       	mov    $0x3ff,%esi
  804160737c:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607383:	00 00 00 
  8041607386:	b8 00 00 00 00       	mov    $0x0,%eax
  804160738b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607392:	00 00 00 
  8041607395:	41 ff d0             	callq  *%r8
  assert(page2pa(pp1) < npages * PGSIZE);
  8041607398:	48 b9 f8 d6 60 41 80 	movabs $0x804160d6f8,%rcx
  804160739f:	00 00 00 
  80416073a2:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416073a9:	00 00 00 
  80416073ac:	be 00 04 00 00       	mov    $0x400,%esi
  80416073b1:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416073b8:	00 00 00 
  80416073bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073c0:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073c7:	00 00 00 
  80416073ca:	41 ff d0             	callq  *%r8
  assert(page2pa(pp2) < npages * PGSIZE);
  80416073cd:	48 b9 18 d7 60 41 80 	movabs $0x804160d718,%rcx
  80416073d4:	00 00 00 
  80416073d7:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416073de:	00 00 00 
  80416073e1:	be 01 04 00 00       	mov    $0x401,%esi
  80416073e6:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416073ed:	00 00 00 
  80416073f0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416073f5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416073fc:	00 00 00 
  80416073ff:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041607402:	48 b9 03 db 60 41 80 	movabs $0x804160db03,%rcx
  8041607409:	00 00 00 
  804160740c:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607413:	00 00 00 
  8041607416:	be 08 04 00 00       	mov    $0x408,%esi
  804160741b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607422:	00 00 00 
  8041607425:	b8 00 00 00 00       	mov    $0x0,%eax
  804160742a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607431:	00 00 00 
  8041607434:	41 ff d0             	callq  *%r8
  assert((pp0 = page_alloc(0)));
  8041607437:	48 b9 01 dc 60 41 80 	movabs $0x804160dc01,%rcx
  804160743e:	00 00 00 
  8041607441:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607448:	00 00 00 
  804160744b:	be 0f 04 00 00       	mov    $0x40f,%esi
  8041607450:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607457:	00 00 00 
  804160745a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160745f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607466:	00 00 00 
  8041607469:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  804160746c:	48 b9 17 dc 60 41 80 	movabs $0x804160dc17,%rcx
  8041607473:	00 00 00 
  8041607476:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160747d:	00 00 00 
  8041607480:	be 10 04 00 00       	mov    $0x410,%esi
  8041607485:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160748c:	00 00 00 
  804160748f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607494:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160749b:	00 00 00 
  804160749e:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  80416074a1:	48 b9 2d dc 60 41 80 	movabs $0x804160dc2d,%rcx
  80416074a8:	00 00 00 
  80416074ab:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416074b2:	00 00 00 
  80416074b5:	be 11 04 00 00       	mov    $0x411,%esi
  80416074ba:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416074c1:	00 00 00 
  80416074c4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074c9:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416074d0:	00 00 00 
  80416074d3:	41 ff d0             	callq  *%r8
  assert(pp1 && pp1 != pp0);
  80416074d6:	48 b9 e6 da 60 41 80 	movabs $0x804160dae6,%rcx
  80416074dd:	00 00 00 
  80416074e0:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416074e7:	00 00 00 
  80416074ea:	be 13 04 00 00       	mov    $0x413,%esi
  80416074ef:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416074f6:	00 00 00 
  80416074f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416074fe:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607505:	00 00 00 
  8041607508:	41 ff d0             	callq  *%r8
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  804160750b:	48 b9 38 d2 60 41 80 	movabs $0x804160d238,%rcx
  8041607512:	00 00 00 
  8041607515:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160751c:	00 00 00 
  804160751f:	be 14 04 00 00       	mov    $0x414,%esi
  8041607524:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160752b:	00 00 00 
  804160752e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607533:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160753a:	00 00 00 
  804160753d:	41 ff d0             	callq  *%r8
  assert(!page_alloc(0));
  8041607540:	48 b9 03 db 60 41 80 	movabs $0x804160db03,%rcx
  8041607547:	00 00 00 
  804160754a:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607551:	00 00 00 
  8041607554:	be 15 04 00 00       	mov    $0x415,%esi
  8041607559:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607560:	00 00 00 
  8041607563:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607568:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160756f:	00 00 00 
  8041607572:	41 ff d0             	callq  *%r8
  8041607575:	48 89 f9             	mov    %rdi,%rcx
  8041607578:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  804160757f:	00 00 00 
  8041607582:	be 61 00 00 00       	mov    $0x61,%esi
  8041607587:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  804160758e:	00 00 00 
  8041607591:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607596:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160759d:	00 00 00 
  80416075a0:	41 ff d0             	callq  *%r8
  assert((pp = page_alloc(ALLOC_ZERO)));
  80416075a3:	48 b9 43 dc 60 41 80 	movabs $0x804160dc43,%rcx
  80416075aa:	00 00 00 
  80416075ad:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416075b4:	00 00 00 
  80416075b7:	be 1a 04 00 00       	mov    $0x41a,%esi
  80416075bc:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416075c3:	00 00 00 
  80416075c6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416075cd:	00 00 00 
  80416075d0:	41 ff d0             	callq  *%r8
  assert(pp && pp0 == pp);
  80416075d3:	48 b9 61 dc 60 41 80 	movabs $0x804160dc61,%rcx
  80416075da:	00 00 00 
  80416075dd:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416075e4:	00 00 00 
  80416075e7:	be 1b 04 00 00       	mov    $0x41b,%esi
  80416075ec:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416075f3:	00 00 00 
  80416075f6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416075fb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607602:	00 00 00 
  8041607605:	41 ff d0             	callq  *%r8
  8041607608:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  804160760f:	00 00 00 
  8041607612:	be 61 00 00 00       	mov    $0x61,%esi
  8041607617:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  804160761e:	00 00 00 
  8041607621:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607626:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160762d:	00 00 00 
  8041607630:	41 ff d0             	callq  *%r8
    assert(c[i] == 0);
  8041607633:	48 b9 71 dc 60 41 80 	movabs $0x804160dc71,%rcx
  804160763a:	00 00 00 
  804160763d:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607644:	00 00 00 
  8041607647:	be 1e 04 00 00       	mov    $0x41e,%esi
  804160764c:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607653:	00 00 00 
  8041607656:	b8 00 00 00 00       	mov    $0x0,%eax
  804160765b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607662:	00 00 00 
  8041607665:	41 ff d0             	callq  *%r8
  assert(nfree == 0);
  8041607668:	48 b9 7b dc 60 41 80 	movabs $0x804160dc7b,%rcx
  804160766f:	00 00 00 
  8041607672:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607679:	00 00 00 
  804160767c:	be 2b 04 00 00       	mov    $0x42b,%esi
  8041607681:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607688:	00 00 00 
  804160768b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607690:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607697:	00 00 00 
  804160769a:	41 ff d0             	callq  *%r8
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160769d:	48 89 c1             	mov    %rax,%rcx
  80416076a0:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  80416076a7:	00 00 00 
  80416076aa:	be 20 01 00 00       	mov    $0x120,%esi
  80416076af:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416076b6:	00 00 00 
  80416076b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076be:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076c5:	00 00 00 
  80416076c8:	41 ff d0             	callq  *%r8
  80416076cb:	48 89 c1             	mov    %rax,%rcx
  80416076ce:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  80416076d5:	00 00 00 
  80416076d8:	be 2b 01 00 00       	mov    $0x12b,%esi
  80416076dd:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416076e4:	00 00 00 
  80416076e7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416076ec:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416076f3:	00 00 00 
  80416076f6:	41 ff d0             	callq  *%r8
  80416076f9:	48 89 f9             	mov    %rdi,%rcx
  80416076fc:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  8041607703:	00 00 00 
  8041607706:	be 3a 01 00 00       	mov    $0x13a,%esi
  804160770b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607712:	00 00 00 
  8041607715:	b8 00 00 00 00       	mov    $0x0,%eax
  804160771a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607721:	00 00 00 
  8041607724:	41 ff d0             	callq  *%r8
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  8041607727:	49 8b 4c 24 08       	mov    0x8(%r12),%rcx
    size_to_alloc = mmap_curr->NumberOfPages * PGSIZE;
  804160772c:	49 8b 54 24 18       	mov    0x18(%r12),%rdx
  8041607731:	48 c1 e2 0c          	shl    $0xc,%rdx
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
  8041607735:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  804160773a:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041607740:	49 8b 3f             	mov    (%r15),%rdi
  8041607743:	48 b8 e2 4f 60 41 80 	movabs $0x8041604fe2,%rax
  804160774a:	00 00 00 
  804160774d:	ff d0                	callq  *%rax
  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
  804160774f:	4c 89 e0             	mov    %r12,%rax
  8041607752:	49 03 06             	add    (%r14),%rax
  8041607755:	49 89 c4             	mov    %rax,%r12
  8041607758:	49 39 45 00          	cmp    %rax,0x0(%r13)
  804160775c:	76 0a                	jbe    8041607768 <mem_init+0x24bc>
    if (mmap_curr->Attribute & EFI_MEMORY_RUNTIME) {
  804160775e:	49 83 7c 24 20 00    	cmpq   $0x0,0x20(%r12)
  8041607764:	79 e9                	jns    804160774f <mem_init+0x24a3>
  8041607766:	eb bf                	jmp    8041607727 <mem_init+0x247b>
  pml4e = kern_pml4e;
  8041607768:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  804160776f:	00 00 00 
  8041607772:	4c 8b 28             	mov    (%rax),%r13
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
  8041607775:	48 a1 50 5b 70 41 80 	movabs 0x8041705b50,%rax
  804160777c:	00 00 00 
  804160777f:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  8041607783:	48 c1 e0 04          	shl    $0x4,%rax
  8041607787:	48 05 ff 0f 00 00    	add    $0xfff,%rax
  for (i = 0; i < n; i += PGSIZE)
  804160778d:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041607793:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041607797:	74 6d                	je     8041607806 <mem_init+0x255a>
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  8041607799:	48 a1 58 5b 70 41 80 	movabs 0x8041705b58,%rax
  80416077a0:	00 00 00 
  80416077a3:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  if ((uint64_t)kva < KERNBASE)
  80416077a7:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  return (physaddr_t)kva - KERNBASE;
  80416077ab:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  80416077b2:	ff ff ff 
  80416077b5:	49 01 c6             	add    %rax,%r14
  for (i = 0; i < n; i += PGSIZE)
  80416077b8:	49 89 dc             	mov    %rbx,%r12
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  80416077bb:	49 bf 00 e0 42 3c 80 	movabs $0x803c42e000,%r15
  80416077c2:	00 00 00 
  80416077c5:	4b 8d 34 3c          	lea    (%r12,%r15,1),%rsi
  80416077c9:	4c 89 ef             	mov    %r13,%rdi
  80416077cc:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  80416077d3:	00 00 00 
  80416077d6:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  80416077d8:	48 bf ff ff ff 3f 80 	movabs $0x803fffffff,%rdi
  80416077df:	00 00 00 
  80416077e2:	48 39 7d b0          	cmp    %rdi,-0x50(%rbp)
  80416077e6:	0f 86 af 01 00 00    	jbe    804160799b <mem_init+0x26ef>
  80416077ec:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  80416077f0:	48 39 c2             	cmp    %rax,%rdx
  80416077f3:	0f 85 d1 01 00 00    	jne    80416079ca <mem_init+0x271e>
  for (i = 0; i < n; i += PGSIZE)
  80416077f9:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041607800:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041607804:	77 bf                	ja     80416077c5 <mem_init+0x2519>
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  8041607806:	48 b8 20 46 70 41 80 	movabs $0x8041704620,%rax
  804160780d:	00 00 00 
  8041607810:	4c 8b 20             	mov    (%rax),%r12
  return (physaddr_t)kva - KERNBASE;
  8041607813:	49 be 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%r14
  804160781a:	ff ff ff 
  804160781d:	4d 01 e6             	add    %r12,%r14
  8041607820:	48 be 00 e0 22 3c 80 	movabs $0x803c22e000,%rsi
  8041607827:	00 00 00 
  804160782a:	4c 89 ef             	mov    %r13,%rdi
  804160782d:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041607834:	00 00 00 
  8041607837:	ff d0                	callq  *%rax
  if ((uint64_t)kva < KERNBASE)
  8041607839:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041607840:	00 00 00 
  8041607843:	49 39 d4             	cmp    %rdx,%r12
  8041607846:	0f 86 b3 01 00 00    	jbe    80416079ff <mem_init+0x2753>
  804160784c:	4c 39 f0             	cmp    %r14,%rax
  804160784f:	0f 85 d8 01 00 00    	jne    8041607a2d <mem_init+0x2781>
  8041607855:	48 be 00 f0 22 3c 80 	movabs $0x803c22f000,%rsi
  804160785c:	00 00 00 
  804160785f:	4c 89 ef             	mov    %r13,%rdi
  8041607862:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041607869:	00 00 00 
  804160786c:	ff d0                	callq  *%rax
  804160786e:	48 ba 00 10 00 c0 7f 	movabs $0xffffff7fc0001000,%rdx
  8041607875:	ff ff ff 
  8041607878:	49 01 d4             	add    %rdx,%r12
  804160787b:	4c 39 e0             	cmp    %r12,%rax
  804160787e:	0f 85 a9 01 00 00    	jne    8041607a2d <mem_init+0x2781>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607884:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041607888:	48 c1 e0 0c          	shl    $0xc,%rax
  804160788c:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8041607890:	0f 84 01 02 00 00    	je     8041607a97 <mem_init+0x27eb>
  8041607896:	49 89 dc             	mov    %rbx,%r12
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  8041607899:	49 bf 00 00 00 40 80 	movabs $0x8040000000,%r15
  80416078a0:	00 00 00 
  80416078a3:	49 be 3b 41 60 41 80 	movabs $0x804160413b,%r14
  80416078aa:	00 00 00 
  80416078ad:	4b 8d 34 3c          	lea    (%r12,%r15,1),%rsi
  80416078b1:	4c 89 ef             	mov    %r13,%rdi
  80416078b4:	41 ff d6             	callq  *%r14
  80416078b7:	4c 39 e0             	cmp    %r12,%rax
  80416078ba:	0f 85 a2 01 00 00    	jne    8041607a62 <mem_init+0x27b6>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  80416078c0:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  80416078c7:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416078cb:	77 e0                	ja     80416078ad <mem_init+0x2601>
  80416078cd:	49 bc 00 00 ff 3f 80 	movabs $0x803fff0000,%r12
  80416078d4:	00 00 00 
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  80416078d7:	49 bf 3b 41 60 41 80 	movabs $0x804160413b,%r15
  80416078de:	00 00 00 
  80416078e1:	49 be 00 00 01 80 ff 	movabs $0xfffffeff80010000,%r14
  80416078e8:	fe ff ff 
  80416078eb:	48 b8 00 f0 60 41 80 	movabs $0x804160f000,%rax
  80416078f2:	00 00 00 
  80416078f5:	49 01 c6             	add    %rax,%r14
  80416078f8:	4c 89 e6             	mov    %r12,%rsi
  80416078fb:	4c 89 ef             	mov    %r13,%rdi
  80416078fe:	41 ff d7             	callq  *%r15
  8041607901:	4b 8d 14 26          	lea    (%r14,%r12,1),%rdx
  8041607905:	48 39 c2             	cmp    %rax,%rdx
  8041607908:	0f 85 98 01 00 00    	jne    8041607aa6 <mem_init+0x27fa>
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
  804160790e:	49 81 c4 00 10 00 00 	add    $0x1000,%r12
  8041607915:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160791c:	00 00 00 
  804160791f:	49 39 c4             	cmp    %rax,%r12
  8041607922:	75 d4                	jne    80416078f8 <mem_init+0x264c>
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  8041607924:	48 be 00 00 e0 3f 80 	movabs $0x803fe00000,%rsi
  804160792b:	00 00 00 
  804160792e:	4c 89 ef             	mov    %r13,%rdi
  8041607931:	48 b8 3b 41 60 41 80 	movabs $0x804160413b,%rax
  8041607938:	00 00 00 
  804160793b:	ff d0                	callq  *%rax
  804160793d:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8041607941:	0f 85 94 01 00 00    	jne    8041607adb <mem_init+0x282f>
  pdpe_t *pdpe = KADDR(PTE_ADDR(kern_pml4e[1]));
  8041607947:	49 8b 4d 08          	mov    0x8(%r13),%rcx
  804160794b:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041607952:	48 89 c8             	mov    %rcx,%rax
  8041607955:	48 c1 e8 0c          	shr    $0xc,%rax
  8041607959:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  804160795d:	0f 86 ad 01 00 00    	jbe    8041607b10 <mem_init+0x2864>
  pde_t *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  8041607963:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160796a:	00 00 00 
  804160796d:	48 8b 0c 01          	mov    (%rcx,%rax,1),%rcx
  8041607971:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  8041607978:	48 89 c8             	mov    %rcx,%rax
  804160797b:	48 c1 e8 0c          	shr    $0xc,%rax
  804160797f:	48 39 45 a8          	cmp    %rax,-0x58(%rbp)
  8041607983:	0f 86 b2 01 00 00    	jbe    8041607b3b <mem_init+0x288f>
  return (void *)(pa + KERNBASE);
  8041607989:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607990:	00 00 00 
  8041607993:	48 01 c1             	add    %rax,%rcx
  for (i = 0; i < NPDENTRIES; i++) {
  8041607996:	e9 ee 01 00 00       	jmpq   8041607b89 <mem_init+0x28dd>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160799b:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  804160799f:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  80416079a6:	00 00 00 
  80416079a9:	be 42 04 00 00       	mov    $0x442,%esi
  80416079ae:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416079b5:	00 00 00 
  80416079b8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079bd:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079c4:	00 00 00 
  80416079c7:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  80416079ca:	48 b9 58 d7 60 41 80 	movabs $0x804160d758,%rcx
  80416079d1:	00 00 00 
  80416079d4:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416079db:	00 00 00 
  80416079de:	be 42 04 00 00       	mov    $0x442,%esi
  80416079e3:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416079ea:	00 00 00 
  80416079ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416079f2:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416079f9:	00 00 00 
  80416079fc:	41 ff d0             	callq  *%r8
  80416079ff:	4c 89 e1             	mov    %r12,%rcx
  8041607a02:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  8041607a09:	00 00 00 
  8041607a0c:	be 47 04 00 00       	mov    $0x447,%esi
  8041607a11:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607a18:	00 00 00 
  8041607a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a20:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a27:	00 00 00 
  8041607a2a:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);
  8041607a2d:	48 b9 90 d7 60 41 80 	movabs $0x804160d790,%rcx
  8041607a34:	00 00 00 
  8041607a37:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607a3e:	00 00 00 
  8041607a41:	be 47 04 00 00       	mov    $0x447,%esi
  8041607a46:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607a4d:	00 00 00 
  8041607a50:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a55:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a5c:	00 00 00 
  8041607a5f:	41 ff d0             	callq  *%r8
    assert(check_va2pa(pml4e, KERNBASE + i) == i);
  8041607a62:	48 b9 c8 d7 60 41 80 	movabs $0x804160d7c8,%rcx
  8041607a69:	00 00 00 
  8041607a6c:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607a73:	00 00 00 
  8041607a76:	be 4b 04 00 00       	mov    $0x44b,%esi
  8041607a7b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607a82:	00 00 00 
  8041607a85:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607a8a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607a91:	00 00 00 
  8041607a94:	41 ff d0             	callq  *%r8
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8041607a97:	49 bc 00 00 ff 3f 80 	movabs $0x803fff0000,%r12
  8041607a9e:	00 00 00 
  8041607aa1:	e9 31 fe ff ff       	jmpq   80416078d7 <mem_init+0x262b>
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8041607aa6:	48 b9 f0 d7 60 41 80 	movabs $0x804160d7f0,%rcx
  8041607aad:	00 00 00 
  8041607ab0:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607ab7:	00 00 00 
  8041607aba:	be 4f 04 00 00       	mov    $0x44f,%esi
  8041607abf:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607ac6:	00 00 00 
  8041607ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ace:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607ad5:	00 00 00 
  8041607ad8:	41 ff d0             	callq  *%r8
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);
  8041607adb:	48 b9 38 d8 60 41 80 	movabs $0x804160d838,%rcx
  8041607ae2:	00 00 00 
  8041607ae5:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607aec:	00 00 00 
  8041607aef:	be 50 04 00 00       	mov    $0x450,%esi
  8041607af4:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607afb:	00 00 00 
  8041607afe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b03:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b0a:	00 00 00 
  8041607b0d:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041607b10:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041607b17:	00 00 00 
  8041607b1a:	be 52 04 00 00       	mov    $0x452,%esi
  8041607b1f:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607b26:	00 00 00 
  8041607b29:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b2e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b35:	00 00 00 
  8041607b38:	41 ff d0             	callq  *%r8
  8041607b3b:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041607b42:	00 00 00 
  8041607b45:	be 53 04 00 00       	mov    $0x453,%esi
  8041607b4a:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607b51:	00 00 00 
  8041607b54:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607b59:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607b60:	00 00 00 
  8041607b63:	41 ff d0             	callq  *%r8
    switch (i) {
  8041607b66:	48 81 fb 00 00 08 00 	cmp    $0x80000,%rbx
  8041607b6d:	75 32                	jne    8041607ba1 <mem_init+0x28f5>
        assert(pgdir[i] & PTE_P);
  8041607b6f:	f6 01 01             	testb  $0x1,(%rcx)
  8041607b72:	74 7a                	je     8041607bee <mem_init+0x2942>
  for (i = 0; i < NPDENTRIES; i++) {
  8041607b74:	48 83 c3 01          	add    $0x1,%rbx
  8041607b78:	48 83 c1 08          	add    $0x8,%rcx
  8041607b7c:	48 81 fb 00 02 00 00 	cmp    $0x200,%rbx
  8041607b83:	0f 84 d8 00 00 00    	je     8041607c61 <mem_init+0x29b5>
    switch (i) {
  8041607b89:	48 81 fb ff 01 04 00 	cmp    $0x401ff,%rbx
  8041607b90:	74 dd                	je     8041607b6f <mem_init+0x28c3>
  8041607b92:	77 d2                	ja     8041607b66 <mem_init+0x28ba>
  8041607b94:	48 8d 83 1f fe fb ff 	lea    -0x401e1(%rbx),%rax
  8041607b9b:	48 83 f8 01          	cmp    $0x1,%rax
  8041607b9f:	76 ce                	jbe    8041607b6f <mem_init+0x28c3>
        if (i >= VPD(KERNBASE)) {
  8041607ba1:	48 81 fb ff 01 04 00 	cmp    $0x401ff,%rbx
  8041607ba8:	76 ca                	jbe    8041607b74 <mem_init+0x28c8>
          if (pgdir[i] & PTE_P)
  8041607baa:	48 8b 01             	mov    (%rcx),%rax
  8041607bad:	a8 01                	test   $0x1,%al
  8041607baf:	74 72                	je     8041607c23 <mem_init+0x2977>
            assert(pgdir[i] & PTE_W);
  8041607bb1:	a8 02                	test   $0x2,%al
  8041607bb3:	0f 85 4a 07 00 00    	jne    8041608303 <mem_init+0x3057>
  8041607bb9:	48 b9 97 dc 60 41 80 	movabs $0x804160dc97,%rcx
  8041607bc0:	00 00 00 
  8041607bc3:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607bca:	00 00 00 
  8041607bcd:	be 60 04 00 00       	mov    $0x460,%esi
  8041607bd2:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607bd9:	00 00 00 
  8041607bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607be1:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607be8:	00 00 00 
  8041607beb:	41 ff d0             	callq  *%r8
        assert(pgdir[i] & PTE_P);
  8041607bee:	48 b9 86 dc 60 41 80 	movabs $0x804160dc86,%rcx
  8041607bf5:	00 00 00 
  8041607bf8:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607bff:	00 00 00 
  8041607c02:	be 5b 04 00 00       	mov    $0x45b,%esi
  8041607c07:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607c0e:	00 00 00 
  8041607c11:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c16:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607c1d:	00 00 00 
  8041607c20:	41 ff d0             	callq  *%r8
            assert(pgdir[i] == 0);
  8041607c23:	48 85 c0             	test   %rax,%rax
  8041607c26:	0f 84 d7 06 00 00    	je     8041608303 <mem_init+0x3057>
  8041607c2c:	48 b9 a8 dc 60 41 80 	movabs $0x804160dca8,%rcx
  8041607c33:	00 00 00 
  8041607c36:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607c3d:	00 00 00 
  8041607c40:	be 62 04 00 00       	mov    $0x462,%esi
  8041607c45:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607c4c:	00 00 00 
  8041607c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c54:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607c5b:	00 00 00 
  8041607c5e:	41 ff d0             	callq  *%r8
  cprintf("check_kern_pml4e() succeeded!\n");
  8041607c61:	48 bf 68 d8 60 41 80 	movabs $0x804160d868,%rdi
  8041607c68:	00 00 00 
  8041607c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607c70:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041607c77:	00 00 00 
  8041607c7a:	ff d2                	callq  *%rdx
  mmap_base = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)uefi_lp->MemoryMapVirt;
  8041607c7c:	48 b9 00 f0 61 41 80 	movabs $0x804161f000,%rcx
  8041607c83:	00 00 00 
  8041607c86:	48 8b 11             	mov    (%rcx),%rdx
  8041607c89:	48 8b 42 30          	mov    0x30(%rdx),%rax
  8041607c8d:	48 a3 f0 45 70 41 80 	movabs %rax,0x80417045f0
  8041607c94:	00 00 00 
  mmap_end  = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)uefi_lp->MemoryMapVirt + uefi_lp->MemoryMapSize);
  8041607c97:	48 03 42 38          	add    0x38(%rdx),%rax
  8041607c9b:	48 a3 e8 45 70 41 80 	movabs %rax,0x80417045e8
  8041607ca2:	00 00 00 
  uefi_lp   = (LOADER_PARAMS *)uefi_lp->SelfVirtual;
  8041607ca5:	48 8b 12             	mov    (%rdx),%rdx
  8041607ca8:	48 89 11             	mov    %rdx,(%rcx)
  __asm __volatile("movq %0,%%cr3"
  8041607cab:	48 a1 48 5b 70 41 80 	movabs 0x8041705b48,%rax
  8041607cb2:	00 00 00 
  8041607cb5:	0f 22 d8             	mov    %rax,%cr3
  __asm __volatile("movq %%cr0,%0"
  8041607cb8:	0f 20 c0             	mov    %cr0,%rax
    cr0 &= ~(CR0_TS | CR0_EM);
  8041607cbb:	48 83 e0 f3          	and    $0xfffffffffffffff3,%rax
  8041607cbf:	b9 23 00 05 80       	mov    $0x80050023,%ecx
  8041607cc4:	48 09 c8             	or     %rcx,%rax
  __asm __volatile("movq %0,%%cr0"
  8041607cc7:	0f 22 c0             	mov    %rax,%cr0
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607cca:	48 8b 4a 40          	mov    0x40(%rdx),%rcx
  uintptr_t size     = lp->FrameBufferSize;
  8041607cce:	8b 52 48             	mov    0x48(%rdx),%edx
  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);
  8041607cd1:	48 bb 40 5b 70 41 80 	movabs $0x8041705b40,%rbx
  8041607cd8:	00 00 00 
  8041607cdb:	41 b8 03 00 00 00    	mov    $0x3,%r8d
  8041607ce1:	48 be 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rsi
  8041607ce8:	00 00 00 
  8041607ceb:	48 8b 3b             	mov    (%rbx),%rdi
  8041607cee:	48 b8 e2 4f 60 41 80 	movabs $0x8041604fe2,%rax
  8041607cf5:	00 00 00 
  8041607cf8:	ff d0                	callq  *%rax
check_page_installed_pml4(void) {
  struct PageInfo *pp0, *pp1, *pp2;
  pml4e_t pml4e_old; //used to store value instead of pointer

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  8041607cfa:	48 8b 03             	mov    (%rbx),%rax
  8041607cfd:	4c 8b 30             	mov    (%rax),%r14
  kern_pml4e[0] = 0;
  8041607d00:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  8041607d07:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607d0c:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041607d13:	00 00 00 
  8041607d16:	ff d0                	callq  *%rax
  8041607d18:	48 89 c3             	mov    %rax,%rbx
  8041607d1b:	48 85 c0             	test   %rax,%rax
  8041607d1e:	0f 84 aa 02 00 00    	je     8041607fce <mem_init+0x2d22>
  assert((pp1 = page_alloc(0)));
  8041607d24:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607d29:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041607d30:	00 00 00 
  8041607d33:	ff d0                	callq  *%rax
  8041607d35:	49 89 c5             	mov    %rax,%r13
  8041607d38:	48 85 c0             	test   %rax,%rax
  8041607d3b:	0f 84 c2 02 00 00    	je     8041608003 <mem_init+0x2d57>
  assert((pp2 = page_alloc(0)));
  8041607d41:	bf 00 00 00 00       	mov    $0x0,%edi
  8041607d46:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  8041607d4d:	00 00 00 
  8041607d50:	ff d0                	callq  *%rax
  8041607d52:	49 89 c4             	mov    %rax,%r12
  8041607d55:	48 85 c0             	test   %rax,%rax
  8041607d58:	0f 84 da 02 00 00    	je     8041608038 <mem_init+0x2d8c>
  page_free(pp0);
  8041607d5e:	48 89 df             	mov    %rbx,%rdi
  8041607d61:	48 b8 67 4b 60 41 80 	movabs $0x8041604b67,%rax
  8041607d68:	00 00 00 
  8041607d6b:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607d6d:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041607d74:	00 00 00 
  8041607d77:	4c 89 e9             	mov    %r13,%rcx
  8041607d7a:	48 2b 08             	sub    (%rax),%rcx
  8041607d7d:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607d81:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607d85:	48 89 ca             	mov    %rcx,%rdx
  8041607d88:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607d8c:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041607d93:	00 00 00 
  8041607d96:	48 3b 10             	cmp    (%rax),%rdx
  8041607d99:	0f 83 ce 02 00 00    	jae    804160806d <mem_init+0x2dc1>
  return (void *)(pa + KERNBASE);
  8041607d9f:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607da6:	00 00 00 
  8041607da9:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp1), 1, PGSIZE);
  8041607dac:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607db1:	be 01 00 00 00       	mov    $0x1,%esi
  8041607db6:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041607dbd:	00 00 00 
  8041607dc0:	ff d0                	callq  *%rax
  return (pp - pages) << PGSHIFT;
  8041607dc2:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041607dc9:	00 00 00 
  8041607dcc:	4c 89 e1             	mov    %r12,%rcx
  8041607dcf:	48 2b 08             	sub    (%rax),%rcx
  8041607dd2:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607dd6:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607dda:	48 89 ca             	mov    %rcx,%rdx
  8041607ddd:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607de1:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041607de8:	00 00 00 
  8041607deb:	48 3b 10             	cmp    (%rax),%rdx
  8041607dee:	0f 83 a4 02 00 00    	jae    8041608098 <mem_init+0x2dec>
  return (void *)(pa + KERNBASE);
  8041607df4:	48 bf 00 00 00 40 80 	movabs $0x8040000000,%rdi
  8041607dfb:	00 00 00 
  8041607dfe:	48 01 cf             	add    %rcx,%rdi
  memset(page2kva(pp2), 2, PGSIZE);
  8041607e01:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607e06:	be 02 00 00 00       	mov    $0x2,%esi
  8041607e0b:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041607e12:	00 00 00 
  8041607e15:	ff d0                	callq  *%rax
  page_insert(kern_pml4e, pp1, (void *)PGSIZE, PTE_W);
  8041607e17:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607e1c:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607e21:	4c 89 ee             	mov    %r13,%rsi
  8041607e24:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041607e2b:	00 00 00 
  8041607e2e:	48 8b 38             	mov    (%rax),%rdi
  8041607e31:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  8041607e38:	00 00 00 
  8041607e3b:	ff d0                	callq  *%rax
  assert(pp1->pp_ref == 1);
  8041607e3d:	66 41 83 7d 08 01    	cmpw   $0x1,0x8(%r13)
  8041607e43:	0f 85 7a 02 00 00    	jne    80416080c3 <mem_init+0x2e17>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  8041607e49:	81 3c 25 00 10 00 00 	cmpl   $0x1010101,0x1000
  8041607e50:	01 01 01 01 
  8041607e54:	0f 85 9e 02 00 00    	jne    80416080f8 <mem_init+0x2e4c>
  page_insert(kern_pml4e, pp2, (void *)PGSIZE, PTE_W);
  8041607e5a:	b9 02 00 00 00       	mov    $0x2,%ecx
  8041607e5f:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041607e64:	4c 89 e6             	mov    %r12,%rsi
  8041607e67:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041607e6e:	00 00 00 
  8041607e71:	48 8b 38             	mov    (%rax),%rdi
  8041607e74:	48 b8 7b 51 60 41 80 	movabs $0x804160517b,%rax
  8041607e7b:	00 00 00 
  8041607e7e:	ff d0                	callq  *%rax
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  8041607e80:	81 3c 25 00 10 00 00 	cmpl   $0x2020202,0x1000
  8041607e87:	02 02 02 02 
  8041607e8b:	0f 85 9c 02 00 00    	jne    804160812d <mem_init+0x2e81>
  assert(pp2->pp_ref == 1);
  8041607e91:	66 41 83 7c 24 08 01 	cmpw   $0x1,0x8(%r12)
  8041607e98:	0f 85 c4 02 00 00    	jne    8041608162 <mem_init+0x2eb6>
  assert(pp1->pp_ref == 0);
  8041607e9e:	66 41 83 7d 08 00    	cmpw   $0x0,0x8(%r13)
  8041607ea4:	0f 85 ed 02 00 00    	jne    8041608197 <mem_init+0x2eeb>
  *(uint32_t *)PGSIZE = 0x03030303U;
  8041607eaa:	c7 04 25 00 10 00 00 	movl   $0x3030303,0x1000
  8041607eb1:	03 03 03 03 
  return (pp - pages) << PGSHIFT;
  8041607eb5:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041607ebc:	00 00 00 
  8041607ebf:	4c 89 e1             	mov    %r12,%rcx
  8041607ec2:	48 2b 08             	sub    (%rax),%rcx
  8041607ec5:	48 c1 f9 04          	sar    $0x4,%rcx
  8041607ec9:	48 c1 e1 0c          	shl    $0xc,%rcx
  if (PGNUM(pa) >= npages)
  8041607ecd:	48 89 ca             	mov    %rcx,%rdx
  8041607ed0:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041607ed4:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041607edb:	00 00 00 
  8041607ede:	48 3b 10             	cmp    (%rax),%rdx
  8041607ee1:	0f 83 e5 02 00 00    	jae    80416081cc <mem_init+0x2f20>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  8041607ee7:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  8041607eee:	00 00 00 
  8041607ef1:	81 3c 01 03 03 03 03 	cmpl   $0x3030303,(%rcx,%rax,1)
  8041607ef8:	0f 85 f9 02 00 00    	jne    80416081f7 <mem_init+0x2f4b>
  page_remove(kern_pml4e, (void *)PGSIZE);
  8041607efe:	be 00 10 00 00       	mov    $0x1000,%esi
  8041607f03:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041607f0a:	00 00 00 
  8041607f0d:	48 8b 38             	mov    (%rax),%rdi
  8041607f10:	48 b8 20 51 60 41 80 	movabs $0x8041605120,%rax
  8041607f17:	00 00 00 
  8041607f1a:	ff d0                	callq  *%rax
  assert(pp2->pp_ref == 0);
  8041607f1c:	66 41 83 7c 24 08 00 	cmpw   $0x0,0x8(%r12)
  8041607f23:	0f 85 03 03 00 00    	jne    804160822c <mem_init+0x2f80>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  8041607f29:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041607f30:	00 00 00 
  8041607f33:	48 8b 08             	mov    (%rax),%rcx
  8041607f36:	48 8b 11             	mov    (%rcx),%rdx
  8041607f39:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  return (pp - pages) << PGSHIFT;
  8041607f40:	48 b8 58 5b 70 41 80 	movabs $0x8041705b58,%rax
  8041607f47:	00 00 00 
  8041607f4a:	48 89 df             	mov    %rbx,%rdi
  8041607f4d:	48 2b 38             	sub    (%rax),%rdi
  8041607f50:	48 89 f8             	mov    %rdi,%rax
  8041607f53:	48 c1 f8 04          	sar    $0x4,%rax
  8041607f57:	48 c1 e0 0c          	shl    $0xc,%rax
  8041607f5b:	48 39 c2             	cmp    %rax,%rdx
  8041607f5e:	0f 85 fd 02 00 00    	jne    8041608261 <mem_init+0x2fb5>
  kern_pml4e[0] = 0;
  8041607f64:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  assert(pp0->pp_ref == 1);
  8041607f6b:	66 83 7b 08 01       	cmpw   $0x1,0x8(%rbx)
  8041607f70:	0f 85 20 03 00 00    	jne    8041608296 <mem_init+0x2fea>
  pp0->pp_ref = 0;
  8041607f76:	66 c7 43 08 00 00    	movw   $0x0,0x8(%rbx)

  // free the pages we took
  page_free(pp0);
  8041607f7c:	48 89 df             	mov    %rbx,%rdi
  8041607f7f:	48 b8 67 4b 60 41 80 	movabs $0x8041604b67,%rax
  8041607f86:	00 00 00 
  8041607f89:	ff d0                	callq  *%rax

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;
  8041607f8b:	48 a1 40 5b 70 41 80 	movabs 0x8041705b40,%rax
  8041607f92:	00 00 00 
  8041607f95:	4c 89 30             	mov    %r14,(%rax)

  cprintf("check_page_installed_pml4() succeeded!\n");
  8041607f98:	48 bf 30 d9 60 41 80 	movabs $0x804160d930,%rdi
  8041607f9f:	00 00 00 
  8041607fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607fa7:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041607fae:	00 00 00 
  8041607fb1:	ff d2                	callq  *%rdx
  struct PageInfo *pp = page_free_list, *pt = NULL;
  8041607fb3:	48 b8 08 46 70 41 80 	movabs $0x8041704608,%rax
  8041607fba:	00 00 00 
  8041607fbd:	48 8b 10             	mov    (%rax),%rdx
  while (pp) {
  8041607fc0:	48 85 d2             	test   %rdx,%rdx
  8041607fc3:	0f 85 05 03 00 00    	jne    80416082ce <mem_init+0x3022>
  8041607fc9:	e9 08 03 00 00       	jmpq   80416082d6 <mem_init+0x302a>
  assert((pp0 = page_alloc(0)));
  8041607fce:	48 b9 01 dc 60 41 80 	movabs $0x804160dc01,%rcx
  8041607fd5:	00 00 00 
  8041607fd8:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041607fdf:	00 00 00 
  8041607fe2:	be 46 05 00 00       	mov    $0x546,%esi
  8041607fe7:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041607fee:	00 00 00 
  8041607ff1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041607ff6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041607ffd:	00 00 00 
  8041608000:	41 ff d0             	callq  *%r8
  assert((pp1 = page_alloc(0)));
  8041608003:	48 b9 17 dc 60 41 80 	movabs $0x804160dc17,%rcx
  804160800a:	00 00 00 
  804160800d:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041608014:	00 00 00 
  8041608017:	be 47 05 00 00       	mov    $0x547,%esi
  804160801c:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041608023:	00 00 00 
  8041608026:	b8 00 00 00 00       	mov    $0x0,%eax
  804160802b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608032:	00 00 00 
  8041608035:	41 ff d0             	callq  *%r8
  assert((pp2 = page_alloc(0)));
  8041608038:	48 b9 2d dc 60 41 80 	movabs $0x804160dc2d,%rcx
  804160803f:	00 00 00 
  8041608042:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041608049:	00 00 00 
  804160804c:	be 48 05 00 00       	mov    $0x548,%esi
  8041608051:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041608058:	00 00 00 
  804160805b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608060:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608067:	00 00 00 
  804160806a:	41 ff d0             	callq  *%r8
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  804160806d:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041608074:	00 00 00 
  8041608077:	be 61 00 00 00       	mov    $0x61,%esi
  804160807c:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041608083:	00 00 00 
  8041608086:	b8 00 00 00 00       	mov    $0x0,%eax
  804160808b:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608092:	00 00 00 
  8041608095:	41 ff d0             	callq  *%r8
  8041608098:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  804160809f:	00 00 00 
  80416080a2:	be 61 00 00 00       	mov    $0x61,%esi
  80416080a7:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  80416080ae:	00 00 00 
  80416080b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080b6:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080bd:	00 00 00 
  80416080c0:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 1);
  80416080c3:	48 b9 12 db 60 41 80 	movabs $0x804160db12,%rcx
  80416080ca:	00 00 00 
  80416080cd:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416080d4:	00 00 00 
  80416080d7:	be 4d 05 00 00       	mov    $0x54d,%esi
  80416080dc:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416080e3:	00 00 00 
  80416080e6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416080eb:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416080f2:	00 00 00 
  80416080f5:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  80416080f8:	48 b9 88 d8 60 41 80 	movabs $0x804160d888,%rcx
  80416080ff:	00 00 00 
  8041608102:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041608109:	00 00 00 
  804160810c:	be 4e 05 00 00       	mov    $0x54e,%esi
  8041608111:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041608118:	00 00 00 
  804160811b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608120:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608127:	00 00 00 
  804160812a:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  804160812d:	48 b9 b0 d8 60 41 80 	movabs $0x804160d8b0,%rcx
  8041608134:	00 00 00 
  8041608137:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160813e:	00 00 00 
  8041608141:	be 50 05 00 00       	mov    $0x550,%esi
  8041608146:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160814d:	00 00 00 
  8041608150:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608155:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160815c:	00 00 00 
  804160815f:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 1);
  8041608162:	48 b9 b6 dc 60 41 80 	movabs $0x804160dcb6,%rcx
  8041608169:	00 00 00 
  804160816c:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041608173:	00 00 00 
  8041608176:	be 51 05 00 00       	mov    $0x551,%esi
  804160817b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041608182:	00 00 00 
  8041608185:	b8 00 00 00 00       	mov    $0x0,%eax
  804160818a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608191:	00 00 00 
  8041608194:	41 ff d0             	callq  *%r8
  assert(pp1->pp_ref == 0);
  8041608197:	48 b9 8d db 60 41 80 	movabs $0x804160db8d,%rcx
  804160819e:	00 00 00 
  80416081a1:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416081a8:	00 00 00 
  80416081ab:	be 52 05 00 00       	mov    $0x552,%esi
  80416081b0:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416081b7:	00 00 00 
  80416081ba:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081bf:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081c6:	00 00 00 
  80416081c9:	41 ff d0             	callq  *%r8
  80416081cc:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  80416081d3:	00 00 00 
  80416081d6:	be 61 00 00 00       	mov    $0x61,%esi
  80416081db:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  80416081e2:	00 00 00 
  80416081e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416081ea:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416081f1:	00 00 00 
  80416081f4:	41 ff d0             	callq  *%r8
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  80416081f7:	48 b9 d8 d8 60 41 80 	movabs $0x804160d8d8,%rcx
  80416081fe:	00 00 00 
  8041608201:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041608208:	00 00 00 
  804160820b:	be 54 05 00 00       	mov    $0x554,%esi
  8041608210:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041608217:	00 00 00 
  804160821a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160821f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608226:	00 00 00 
  8041608229:	41 ff d0             	callq  *%r8
  assert(pp2->pp_ref == 0);
  804160822c:	48 b9 c7 dc 60 41 80 	movabs $0x804160dcc7,%rcx
  8041608233:	00 00 00 
  8041608236:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  804160823d:	00 00 00 
  8041608240:	be 56 05 00 00       	mov    $0x556,%esi
  8041608245:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  804160824c:	00 00 00 
  804160824f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608254:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160825b:	00 00 00 
  804160825e:	41 ff d0             	callq  *%r8
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  8041608261:	48 b9 08 d9 60 41 80 	movabs $0x804160d908,%rcx
  8041608268:	00 00 00 
  804160826b:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041608272:	00 00 00 
  8041608275:	be 59 05 00 00       	mov    $0x559,%esi
  804160827a:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041608281:	00 00 00 
  8041608284:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608289:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608290:	00 00 00 
  8041608293:	41 ff d0             	callq  *%r8
  assert(pp0->pp_ref == 1);
  8041608296:	48 b9 d8 dc 60 41 80 	movabs $0x804160dcd8,%rcx
  804160829d:	00 00 00 
  80416082a0:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  80416082a7:	00 00 00 
  80416082aa:	be 5b 05 00 00       	mov    $0x55b,%esi
  80416082af:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416082b6:	00 00 00 
  80416082b9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416082be:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416082c5:	00 00 00 
  80416082c8:	41 ff d0             	callq  *%r8
    pp = pp->pp_link;
  80416082cb:	48 89 c2             	mov    %rax,%rdx
  80416082ce:	48 8b 02             	mov    (%rdx),%rax
  while (pp) {
  80416082d1:	48 85 c0             	test   %rax,%rax
  80416082d4:	75 f5                	jne    80416082cb <mem_init+0x301f>
  page_free_list_top = evaluate_page_free_list_top();
  80416082d6:	48 89 d0             	mov    %rdx,%rax
  80416082d9:	48 a3 00 46 70 41 80 	movabs %rax,0x8041704600
  80416082e0:	00 00 00 
  check_page_free_list(0);
  80416082e3:	bf 00 00 00 00       	mov    $0x0,%edi
  80416082e8:	48 b8 b6 43 60 41 80 	movabs $0x80416043b6,%rax
  80416082ef:	00 00 00 
  80416082f2:	ff d0                	callq  *%rax
}
  80416082f4:	48 83 c4 38          	add    $0x38,%rsp
  80416082f8:	5b                   	pop    %rbx
  80416082f9:	41 5c                	pop    %r12
  80416082fb:	41 5d                	pop    %r13
  80416082fd:	41 5e                	pop    %r14
  80416082ff:	41 5f                	pop    %r15
  8041608301:	5d                   	pop    %rbp
  8041608302:	c3                   	retq   
  for (i = 0; i < NPDENTRIES; i++) {
  8041608303:	48 83 c3 01          	add    $0x1,%rbx
  8041608307:	48 83 c1 08          	add    $0x8,%rcx
  804160830b:	e9 79 f8 ff ff       	jmpq   8041607b89 <mem_init+0x28dd>

0000008041608310 <mmio_map_region>:
mmio_map_region(physaddr_t pa, size_t size) {
  8041608310:	55                   	push   %rbp
  8041608311:	48 89 e5             	mov    %rsp,%rbp
  8041608314:	53                   	push   %rbx
  8041608315:	48 83 ec 08          	sub    $0x8,%rsp
  uintptr_t pa2 = ROUNDDOWN(pa, PGSIZE);
  8041608319:	48 89 f9             	mov    %rdi,%rcx
  804160831c:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (base + size >= MMIOLIM) {
  8041608323:	48 a1 20 f7 61 41 80 	movabs 0x804161f720,%rax
  804160832a:	00 00 00 
  804160832d:	4c 8d 04 30          	lea    (%rax,%rsi,1),%r8
  8041608331:	48 ba ff ff df 3f 80 	movabs $0x803fdfffff,%rdx
  8041608338:	00 00 00 
  804160833b:	49 39 d0             	cmp    %rdx,%r8
  804160833e:	77 54                	ja     8041608394 <mmio_map_region+0x84>
  size = ROUNDUP(size + (pa - pa2 ), PGSIZE);
  8041608340:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
  8041608346:	48 8d 9c 3e ff 0f 00 	lea    0xfff(%rsi,%rdi,1),%rbx
  804160834d:	00 
  804160834e:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  boot_map_region(kern_pml4e, base, size, pa2, PTE_PCD | PTE_PWT | PTE_W);
  8041608355:	41 b8 1a 00 00 00    	mov    $0x1a,%r8d
  804160835b:	48 89 da             	mov    %rbx,%rdx
  804160835e:	48 89 c6             	mov    %rax,%rsi
  8041608361:	48 b8 40 5b 70 41 80 	movabs $0x8041705b40,%rax
  8041608368:	00 00 00 
  804160836b:	48 8b 38             	mov    (%rax),%rdi
  804160836e:	48 b8 e2 4f 60 41 80 	movabs $0x8041604fe2,%rax
  8041608375:	00 00 00 
  8041608378:	ff d0                	callq  *%rax
  void * new = (void *) base;
  804160837a:	48 ba 20 f7 61 41 80 	movabs $0x804161f720,%rdx
  8041608381:	00 00 00 
  8041608384:	48 8b 02             	mov    (%rdx),%rax
  base += size;
  8041608387:	48 01 c3             	add    %rax,%rbx
  804160838a:	48 89 1a             	mov    %rbx,(%rdx)
}
  804160838d:	48 83 c4 08          	add    $0x8,%rsp
  8041608391:	5b                   	pop    %rbx
  8041608392:	5d                   	pop    %rbp
  8041608393:	c3                   	retq   
    panic("Allocated MMIO addr is too high! [0x%016lu;0x%016lu]",pa, pa+size);
  8041608394:	4c 8d 04 37          	lea    (%rdi,%rsi,1),%r8
  8041608398:	48 89 f9             	mov    %rdi,%rcx
  804160839b:	48 ba 58 d9 60 41 80 	movabs $0x804160d958,%rdx
  80416083a2:	00 00 00 
  80416083a5:	be 4f 03 00 00       	mov    $0x34f,%esi
  80416083aa:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  80416083b1:	00 00 00 
  80416083b4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416083b9:	49 b9 5a 02 60 41 80 	movabs $0x804160025a,%r9
  80416083c0:	00 00 00 
  80416083c3:	41 ff d1             	callq  *%r9

00000080416083c6 <mmio_remap_last_region>:
mmio_remap_last_region(physaddr_t pa, void *addr, size_t oldsize, size_t newsize) {
  80416083c6:	55                   	push   %rbp
  80416083c7:	48 89 e5             	mov    %rsp,%rbp
  if (base - oldsize != (uintptr_t)addr)
  80416083ca:	48 a1 20 f7 61 41 80 	movabs 0x804161f720,%rax
  80416083d1:	00 00 00 
  80416083d4:	4c 8d 04 06          	lea    (%rsi,%rax,1),%r8
  oldsize = ROUNDUP((uintptr_t)addr + oldsize, PGSIZE) - (uintptr_t)addr;
  80416083d8:	48 8d 84 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%rax
  80416083df:	00 
  if (base - oldsize != (uintptr_t)addr)
  80416083e0:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80416083e6:	49 29 c0             	sub    %rax,%r8
  80416083e9:	4c 39 c6             	cmp    %r8,%rsi
  80416083ec:	75 1e                	jne    804160840c <mmio_remap_last_region+0x46>
  base = (uintptr_t)addr;
  80416083ee:	48 89 f0             	mov    %rsi,%rax
  80416083f1:	48 a3 20 f7 61 41 80 	movabs %rax,0x804161f720
  80416083f8:	00 00 00 
  return mmio_map_region(pa, newsize);
  80416083fb:	48 89 ce             	mov    %rcx,%rsi
  80416083fe:	48 b8 10 83 60 41 80 	movabs $0x8041608310,%rax
  8041608405:	00 00 00 
  8041608408:	ff d0                	callq  *%rax
}
  804160840a:	5d                   	pop    %rbp
  804160840b:	c3                   	retq   
    panic("You dare to remap non-last region?!");
  804160840c:	48 ba 90 d9 60 41 80 	movabs $0x804160d990,%rdx
  8041608413:	00 00 00 
  8041608416:	be 60 03 00 00       	mov    $0x360,%esi
  804160841b:	48 bf b4 d9 60 41 80 	movabs $0x804160d9b4,%rdi
  8041608422:	00 00 00 
  8041608425:	b8 00 00 00 00       	mov    $0x0,%eax
  804160842a:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608431:	00 00 00 
  8041608434:	ff d1                	callq  *%rcx

0000008041608436 <user_mem_check>:
user_mem_check(struct Env *env, const void *va, size_t len, int perm) {
  8041608436:	55                   	push   %rbp
  8041608437:	48 89 e5             	mov    %rsp,%rbp
  804160843a:	41 57                	push   %r15
  804160843c:	41 56                	push   %r14
  804160843e:	41 55                	push   %r13
  8041608440:	41 54                	push   %r12
  8041608442:	53                   	push   %rbx
  8041608443:	48 83 ec 18          	sub    $0x18,%rsp
	for (i_va = ROUNDDOWN((uintptr_t) va, PGSIZE); i_va < ROUNDUP((uintptr_t) va + len, PGSIZE); i_va += PGSIZE) {
  8041608447:	48 89 f3             	mov    %rsi,%rbx
  804160844a:	48 81 e3 00 f0 ff ff 	and    $0xfffffffffffff000,%rbx
  8041608451:	4c 8d ac 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%r13
  8041608458:	00 
  8041608459:	49 81 e5 00 f0 ff ff 	and    $0xfffffffffffff000,%r13
  8041608460:	4c 39 eb             	cmp    %r13,%rbx
  8041608463:	73 7a                	jae    80416084df <user_mem_check+0xa9>
		if (i_va >= ULIM || !page_lookup(env->env_pml4e, (void *) i_va, &ptep) || (*ptep & perm) != perm) {
  8041608465:	48 b8 ff df c2 3e 80 	movabs $0x803ec2dfff,%rax
  804160846c:	00 00 00 
  804160846f:	48 39 c3             	cmp    %rax,%rbx
  8041608472:	77 50                	ja     80416084c4 <user_mem_check+0x8e>
  8041608474:	49 89 fe             	mov    %rdi,%r14
  8041608477:	49 bf 5a 50 60 41 80 	movabs $0x804160505a,%r15
  804160847e:	00 00 00 
  8041608481:	4c 63 e1             	movslq %ecx,%r12
  8041608484:	49 8b be e8 00 00 00 	mov    0xe8(%r14),%rdi
  804160848b:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  804160848f:	48 89 de             	mov    %rbx,%rsi
  8041608492:	41 ff d7             	callq  *%r15
  8041608495:	48 85 c0             	test   %rax,%rax
  8041608498:	74 2a                	je     80416084c4 <user_mem_check+0x8e>
  804160849a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160849e:	4c 89 e1             	mov    %r12,%rcx
  80416084a1:	48 23 08             	and    (%rax),%rcx
  80416084a4:	49 39 cc             	cmp    %rcx,%r12
  80416084a7:	75 1b                	jne    80416084c4 <user_mem_check+0x8e>
	for (i_va = ROUNDDOWN((uintptr_t) va, PGSIZE); i_va < ROUNDUP((uintptr_t) va + len, PGSIZE); i_va += PGSIZE) {
  80416084a9:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
  80416084b0:	4c 39 eb             	cmp    %r13,%rbx
  80416084b3:	73 23                	jae    80416084d8 <user_mem_check+0xa2>
		if (i_va >= ULIM || !page_lookup(env->env_pml4e, (void *) i_va, &ptep) || (*ptep & perm) != perm) {
  80416084b5:	48 b8 ff df c2 3e 80 	movabs $0x803ec2dfff,%rax
  80416084bc:	00 00 00 
  80416084bf:	48 39 c3             	cmp    %rax,%rbx
  80416084c2:	76 c0                	jbe    8041608484 <user_mem_check+0x4e>
			return -E_FAULT;
  80416084c4:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
}
  80416084c9:	48 83 c4 18          	add    $0x18,%rsp
  80416084cd:	5b                   	pop    %rbx
  80416084ce:	41 5c                	pop    %r12
  80416084d0:	41 5d                	pop    %r13
  80416084d2:	41 5e                	pop    %r14
  80416084d4:	41 5f                	pop    %r15
  80416084d6:	5d                   	pop    %rbp
  80416084d7:	c3                   	retq   
  return 0;
  80416084d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416084dd:	eb ea                	jmp    80416084c9 <user_mem_check+0x93>
  80416084df:	b8 00 00 00 00       	mov    $0x0,%eax
  80416084e4:	eb e3                	jmp    80416084c9 <user_mem_check+0x93>

00000080416084e6 <user_mem_assert>:
user_mem_assert(struct Env *env, const void *va, size_t len, int perm) {
  80416084e6:	55                   	push   %rbp
  80416084e7:	48 89 e5             	mov    %rsp,%rbp
  int t = user_mem_check(env, va, len, perm | PTE_U | PTE_P) < 0;
  80416084ea:	83 c9 05             	or     $0x5,%ecx
  80416084ed:	48 b8 36 84 60 41 80 	movabs $0x8041608436,%rax
  80416084f4:	00 00 00 
  80416084f7:	ff d0                	callq  *%rax
}
  80416084f9:	5d                   	pop    %rbp
  80416084fa:	c3                   	retq   

00000080416084fb <region_alloc>:
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len) {
  80416084fb:	55                   	push   %rbp
  80416084fc:	48 89 e5             	mov    %rsp,%rbp
  80416084ff:	41 57                	push   %r15
  8041608501:	41 56                	push   %r14
  8041608503:	41 55                	push   %r13
  8041608505:	41 54                	push   %r12
  8041608507:	53                   	push   %rbx
  8041608508:	48 83 ec 08          	sub    $0x8,%rsp
  //   'va' and 'len' values that are not page-aligned.
  //   You should round va down, and round (va + len) up.
  //   (Watch out for corner-cases!)

  // LAB 8 code
  void *end = ROUNDUP(va + len, PGSIZE);
  804160850c:	4c 8d a4 16 ff 0f 00 	lea    0xfff(%rsi,%rdx,1),%r12
  8041608513:	00 
  8041608514:	49 81 e4 00 f0 ff ff 	and    $0xfffffffffffff000,%r12
  va = ROUNDDOWN(va, PGSIZE);
  804160851b:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
	struct PageInfo *pi;

	while (va < end) {
  8041608522:	49 39 f4             	cmp    %rsi,%r12
  8041608525:	76 43                	jbe    804160856a <region_alloc+0x6f>
  8041608527:	48 89 f3             	mov    %rsi,%rbx
  804160852a:	49 89 fd             	mov    %rdi,%r13
    pi = page_alloc(0);
  804160852d:	49 bf 6e 4a 60 41 80 	movabs $0x8041604a6e,%r15
  8041608534:	00 00 00 
    page_insert(e->env_pml4e, pi, va, PTE_U | PTE_W);
  8041608537:	49 be 7b 51 60 41 80 	movabs $0x804160517b,%r14
  804160853e:	00 00 00 
    pi = page_alloc(0);
  8041608541:	bf 00 00 00 00       	mov    $0x0,%edi
  8041608546:	41 ff d7             	callq  *%r15
    page_insert(e->env_pml4e, pi, va, PTE_U | PTE_W);
  8041608549:	49 8b bd e8 00 00 00 	mov    0xe8(%r13),%rdi
  8041608550:	b9 06 00 00 00       	mov    $0x6,%ecx
  8041608555:	48 89 da             	mov    %rbx,%rdx
  8041608558:	48 89 c6             	mov    %rax,%rsi
  804160855b:	41 ff d6             	callq  *%r14
    va += PGSIZE;
  804160855e:	48 81 c3 00 10 00 00 	add    $0x1000,%rbx
	while (va < end) {
  8041608565:	49 39 dc             	cmp    %rbx,%r12
  8041608568:	77 d7                	ja     8041608541 <region_alloc+0x46>
  }
  // LAB 8 code end
}
  804160856a:	48 83 c4 08          	add    $0x8,%rsp
  804160856e:	5b                   	pop    %rbx
  804160856f:	41 5c                	pop    %r12
  8041608571:	41 5d                	pop    %r13
  8041608573:	41 5e                	pop    %r14
  8041608575:	41 5f                	pop    %r15
  8041608577:	5d                   	pop    %rbp
  8041608578:	c3                   	retq   

0000008041608579 <envid2env>:
  if (envid == 0) {
  8041608579:	85 ff                	test   %edi,%edi
  804160857b:	74 5e                	je     80416085db <envid2env+0x62>
  e = &envs[ENVX(envid)];
  804160857d:	89 f9                	mov    %edi,%ecx
  804160857f:	83 e1 1f             	and    $0x1f,%ecx
  8041608582:	48 89 c8             	mov    %rcx,%rax
  8041608585:	48 c1 e0 05          	shl    $0x5,%rax
  8041608589:	48 29 c8             	sub    %rcx,%rax
  804160858c:	48 b9 20 46 70 41 80 	movabs $0x8041704620,%rcx
  8041608593:	00 00 00 
  8041608596:	48 8b 09             	mov    (%rcx),%rcx
  8041608599:	48 8d 04 c1          	lea    (%rcx,%rax,8),%rax
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  804160859d:	83 b8 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rax)
  80416085a4:	74 45                	je     80416085eb <envid2env+0x72>
  80416085a6:	39 b8 c8 00 00 00    	cmp    %edi,0xc8(%rax)
  80416085ac:	75 3d                	jne    80416085eb <envid2env+0x72>
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  80416085ae:	84 d2                	test   %dl,%dl
  80416085b0:	74 20                	je     80416085d2 <envid2env+0x59>
  80416085b2:	48 ba 18 46 70 41 80 	movabs $0x8041704618,%rdx
  80416085b9:	00 00 00 
  80416085bc:	48 8b 12             	mov    (%rdx),%rdx
  80416085bf:	48 39 c2             	cmp    %rax,%rdx
  80416085c2:	74 0e                	je     80416085d2 <envid2env+0x59>
  80416085c4:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  80416085ca:	39 90 cc 00 00 00    	cmp    %edx,0xcc(%rax)
  80416085d0:	75 26                	jne    80416085f8 <envid2env+0x7f>
  *env_store = e;
  80416085d2:	48 89 06             	mov    %rax,(%rsi)
  return 0;
  80416085d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416085da:	c3                   	retq   
    *env_store = curenv;
  80416085db:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  80416085e2:	00 00 00 
  80416085e5:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  80416085e8:	89 f8                	mov    %edi,%eax
  80416085ea:	c3                   	retq   
    *env_store = 0;
  80416085eb:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416085f2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  80416085f7:	c3                   	retq   
    *env_store = 0;
  80416085f8:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  80416085ff:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041608604:	c3                   	retq   

0000008041608605 <env_init_percpu>:
env_init_percpu(void) {
  8041608605:	55                   	push   %rbp
  8041608606:	48 89 e5             	mov    %rsp,%rbp
  8041608609:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  804160860a:	48 b8 40 f7 61 41 80 	movabs $0x804161f740,%rax
  8041608611:	00 00 00 
  8041608614:	0f 01 10             	lgdt   (%rax)
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  8041608617:	b8 33 00 00 00       	mov    $0x33,%eax
  804160861c:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  804160861e:	8e e0                	mov    %eax,%fs
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  8041608620:	b8 10 00 00 00       	mov    $0x10,%eax
  8041608625:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041608627:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041608629:	8e d0                	mov    %eax,%ss
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  804160862b:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041608630:	53                   	push   %rbx
  8041608631:	48 b8 3e 86 60 41 80 	movabs $0x804160863e,%rax
  8041608638:	00 00 00 
  804160863b:	50                   	push   %rax
  804160863c:	48 cb                	lretq  
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  804160863e:	66 b8 00 00          	mov    $0x0,%ax
  8041608642:	0f 00 d0             	lldt   %ax
}
  8041608645:	5b                   	pop    %rbx
  8041608646:	5d                   	pop    %rbp
  8041608647:	c3                   	retq   

0000008041608648 <env_init>:
env_init(void) {
  8041608648:	55                   	push   %rbp
  8041608649:	48 89 e5             	mov    %rsp,%rbp
    envs[i].env_status = ENV_FREE;
  804160864c:	48 b8 20 46 70 41 80 	movabs $0x8041704620,%rax
  8041608653:	00 00 00 
  8041608656:	48 8b 38             	mov    (%rax),%rdi
  8041608659:	48 8d 87 08 1e 00 00 	lea    0x1e08(%rdi),%rax
  8041608660:	48 89 fe             	mov    %rdi,%rsi
  8041608663:	ba 00 00 00 00       	mov    $0x0,%edx
  8041608668:	eb 03                	jmp    804160866d <env_init+0x25>
  804160866a:	48 89 c8             	mov    %rcx,%rax
  804160866d:	c7 80 d4 00 00 00 00 	movl   $0x0,0xd4(%rax)
  8041608674:	00 00 00 
    envs[i].env_link = env_free_list;
  8041608677:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    envs[i].env_id   = 0;
  804160867e:	c7 80 c8 00 00 00 00 	movl   $0x0,0xc8(%rax)
  8041608685:	00 00 00 
  for (int i = NENV - 1; i >= 0; i--) {
  8041608688:	48 8d 88 08 ff ff ff 	lea    -0xf8(%rax),%rcx
    env_free_list    = &envs[i];
  804160868f:	48 89 c2             	mov    %rax,%rdx
  for (int i = NENV - 1; i >= 0; i--) {
  8041608692:	48 39 f0             	cmp    %rsi,%rax
  8041608695:	75 d3                	jne    804160866a <env_init+0x22>
  8041608697:	48 89 f8             	mov    %rdi,%rax
  804160869a:	48 a3 28 46 70 41 80 	movabs %rax,0x8041704628
  80416086a1:	00 00 00 
  env_init_percpu();
  80416086a4:	48 b8 05 86 60 41 80 	movabs $0x8041608605,%rax
  80416086ab:	00 00 00 
  80416086ae:	ff d0                	callq  *%rax
}
  80416086b0:	5d                   	pop    %rbp
  80416086b1:	c3                   	retq   

00000080416086b2 <env_alloc>:
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  80416086b2:	55                   	push   %rbp
  80416086b3:	48 89 e5             	mov    %rsp,%rbp
  80416086b6:	41 55                	push   %r13
  80416086b8:	41 54                	push   %r12
  80416086ba:	53                   	push   %rbx
  80416086bb:	48 83 ec 08          	sub    $0x8,%rsp
  if (!(e = env_free_list)) {
  80416086bf:	48 b8 28 46 70 41 80 	movabs $0x8041704628,%rax
  80416086c6:	00 00 00 
  80416086c9:	48 8b 18             	mov    (%rax),%rbx
  80416086cc:	48 85 db             	test   %rbx,%rbx
  80416086cf:	0f 84 42 02 00 00    	je     8041608917 <env_alloc+0x265>
  80416086d5:	41 89 f5             	mov    %esi,%r13d
  80416086d8:	49 89 fc             	mov    %rdi,%r12
  if (!(p = page_alloc(ALLOC_ZERO)))
  80416086db:	bf 01 00 00 00       	mov    $0x1,%edi
  80416086e0:	48 b8 6e 4a 60 41 80 	movabs $0x8041604a6e,%rax
  80416086e7:	00 00 00 
  80416086ea:	ff d0                	callq  *%rax
  80416086ec:	48 85 c0             	test   %rax,%rax
  80416086ef:	0f 84 2c 02 00 00    	je     8041608921 <env_alloc+0x26f>
  return (pp - pages) << PGSHIFT;
  80416086f5:	48 b9 58 5b 70 41 80 	movabs $0x8041705b58,%rcx
  80416086fc:	00 00 00 
  80416086ff:	48 8b 09             	mov    (%rcx),%rcx
  8041608702:	48 29 c8             	sub    %rcx,%rax
  8041608705:	48 c1 f8 04          	sar    $0x4,%rax
  8041608709:	48 c1 e0 0c          	shl    $0xc,%rax
  if (PGNUM(pa) >= npages)
  804160870d:	48 bf 50 5b 70 41 80 	movabs $0x8041705b50,%rdi
  8041608714:	00 00 00 
  8041608717:	48 8b 3f             	mov    (%rdi),%rdi
  804160871a:	48 89 c2             	mov    %rax,%rdx
  804160871d:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041608721:	48 39 fa             	cmp    %rdi,%rdx
  8041608724:	0f 83 7a 01 00 00    	jae    80416088a4 <env_alloc+0x1f2>
  return (void *)(pa + KERNBASE);
  804160872a:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041608731:	00 00 00 
  8041608734:	48 01 c2             	add    %rax,%rdx
	e->env_pml4e = page2kva(p);
  8041608737:	48 89 93 e8 00 00 00 	mov    %rdx,0xe8(%rbx)
  e->env_cr3 = page2pa(p);
  804160873e:	48 89 83 f0 00 00 00 	mov    %rax,0xf0(%rbx)
  e->env_pml4e[1] = kern_pml4e[1];
  8041608745:	48 a1 40 5b 70 41 80 	movabs 0x8041705b40,%rax
  804160874c:	00 00 00 
  804160874f:	48 8b 70 08          	mov    0x8(%rax),%rsi
  8041608753:	48 89 72 08          	mov    %rsi,0x8(%rdx)
  pa2page(PTE_ADDR(kern_pml4e[1]))->pp_ref++;
  8041608757:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PPN(pa) >= npages) {
  804160875e:	48 89 f0             	mov    %rsi,%rax
  8041608761:	48 c1 e8 0c          	shr    $0xc,%rax
  8041608765:	48 39 f8             	cmp    %rdi,%rax
  8041608768:	0f 83 64 01 00 00    	jae    80416088d2 <env_alloc+0x220>
  return &pages[PPN(pa)];
  804160876e:	48 c1 e0 04          	shl    $0x4,%rax
  8041608772:	66 83 44 01 08 01    	addw   $0x1,0x8(%rcx,%rax,1)
  e->env_pml4e[2] = e->env_cr3 | PTE_P | PTE_U;
  8041608778:	48 8b 93 e8 00 00 00 	mov    0xe8(%rbx),%rdx
  804160877f:	48 8b 83 f0 00 00 00 	mov    0xf0(%rbx),%rax
  8041608786:	48 83 c8 05          	or     $0x5,%rax
  804160878a:	48 89 42 10          	mov    %rax,0x10(%rdx)
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  804160878e:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  8041608794:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041608799:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  804160879c:	ba 00 10 00 00       	mov    $0x1000,%edx
  80416087a1:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  80416087a4:	48 ba 20 46 70 41 80 	movabs $0x8041704620,%rdx
  80416087ab:	00 00 00 
  80416087ae:	48 89 d9             	mov    %rbx,%rcx
  80416087b1:	48 2b 0a             	sub    (%rdx),%rcx
  80416087b4:	48 89 ca             	mov    %rcx,%rdx
  80416087b7:	48 c1 fa 03          	sar    $0x3,%rdx
  80416087bb:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
  80416087c1:	09 d0                	or     %edx,%eax
  80416087c3:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)
  e->env_parent_id = parent_id;
  80416087c9:	44 89 ab cc 00 00 00 	mov    %r13d,0xcc(%rbx)
  e->env_type      = ENV_TYPE_USER;
  80416087d0:	c7 83 d0 00 00 00 02 	movl   $0x2,0xd0(%rbx)
  80416087d7:	00 00 00 
  e->env_status = ENV_RUNNABLE;
  80416087da:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  80416087e1:	00 00 00 
  e->env_runs   = 0;
  80416087e4:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  80416087eb:	00 00 00 
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  80416087ee:	ba c0 00 00 00       	mov    $0xc0,%edx
  80416087f3:	be 00 00 00 00       	mov    $0x0,%esi
  80416087f8:	48 89 df             	mov    %rbx,%rdi
  80416087fb:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041608802:	00 00 00 
  8041608805:	ff d0                	callq  *%rax
  e->env_tf.tf_ds  = GD_UD | 3;
  8041608807:	66 c7 83 80 00 00 00 	movw   $0x33,0x80(%rbx)
  804160880e:	33 00 
  e->env_tf.tf_es  = GD_UD | 3;
  8041608810:	66 c7 43 78 33 00    	movw   $0x33,0x78(%rbx)
  e->env_tf.tf_ss  = GD_UD | 3;
  8041608816:	66 c7 83 b8 00 00 00 	movw   $0x33,0xb8(%rbx)
  804160881d:	33 00 
  e->env_tf.tf_rsp = USTACKTOP;
  804160881f:	48 b8 00 b0 ff ff 7f 	movabs $0x7fffffb000,%rax
  8041608826:	00 00 00 
  8041608829:	48 89 83 b0 00 00 00 	mov    %rax,0xb0(%rbx)
  e->env_tf.tf_cs  = GD_UT | 3;
  8041608830:	66 c7 83 a0 00 00 00 	movw   $0x2b,0xa0(%rbx)
  8041608837:	2b 00 
  e->env_tf.tf_rflags |= FL_IF;
  8041608839:	48 81 8b a8 00 00 00 	orq    $0x200,0xa8(%rbx)
  8041608840:	00 02 00 00 
  env_free_list = e->env_link;
  8041608844:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  804160884b:	48 a3 28 46 70 41 80 	movabs %rax,0x8041704628
  8041608852:	00 00 00 
  *newenv_store = e;
  8041608855:	49 89 1c 24          	mov    %rbx,(%r12)
  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608859:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  804160885f:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  8041608866:	00 00 00 
  8041608869:	be 00 00 00 00       	mov    $0x0,%esi
  804160886e:	48 85 c0             	test   %rax,%rax
  8041608871:	74 06                	je     8041608879 <env_alloc+0x1c7>
  8041608873:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041608879:	48 bf 0f dd 60 41 80 	movabs $0x804160dd0f,%rdi
  8041608880:	00 00 00 
  8041608883:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608888:	48 b9 78 92 60 41 80 	movabs $0x8041609278,%rcx
  804160888f:	00 00 00 
  8041608892:	ff d1                	callq  *%rcx
  return 0;
  8041608894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041608899:	48 83 c4 08          	add    $0x8,%rsp
  804160889d:	5b                   	pop    %rbx
  804160889e:	41 5c                	pop    %r12
  80416088a0:	41 5d                	pop    %r13
  80416088a2:	5d                   	pop    %rbp
  80416088a3:	c3                   	retq   
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  80416088a4:	48 89 c1             	mov    %rax,%rcx
  80416088a7:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  80416088ae:	00 00 00 
  80416088b1:	be 61 00 00 00       	mov    $0x61,%esi
  80416088b6:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  80416088bd:	00 00 00 
  80416088c0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416088c5:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  80416088cc:	00 00 00 
  80416088cf:	41 ff d0             	callq  *%r8
    cprintf("accessing %lx\n", (unsigned long)pa);
  80416088d2:	48 bf 5f da 60 41 80 	movabs $0x804160da5f,%rdi
  80416088d9:	00 00 00 
  80416088dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80416088e1:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416088e8:	00 00 00 
  80416088eb:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  80416088ed:	48 ba d8 d1 60 41 80 	movabs $0x804160d1d8,%rdx
  80416088f4:	00 00 00 
  80416088f7:	be 5a 00 00 00       	mov    $0x5a,%esi
  80416088fc:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041608903:	00 00 00 
  8041608906:	b8 00 00 00 00       	mov    $0x0,%eax
  804160890b:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608912:	00 00 00 
  8041608915:	ff d1                	callq  *%rcx
    return -E_NO_FREE_ENV;
  8041608917:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  804160891c:	e9 78 ff ff ff       	jmpq   8041608899 <env_alloc+0x1e7>
    return -E_NO_MEM;
  8041608921:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8041608926:	e9 6e ff ff ff       	jmpq   8041608899 <env_alloc+0x1e7>

000000804160892b <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  804160892b:	55                   	push   %rbp
  804160892c:	48 89 e5             	mov    %rsp,%rbp
  804160892f:	41 57                	push   %r15
  8041608931:	41 56                	push   %r14
  8041608933:	41 55                	push   %r13
  8041608935:	41 54                	push   %r12
  8041608937:	53                   	push   %rbx
  8041608938:	48 83 ec 38          	sub    $0x38,%rsp
  804160893c:	49 89 fc             	mov    %rdi,%r12
  804160893f:	89 f3                	mov    %esi,%ebx
    
  // LAB 3 code
  struct Env *newenv;
  if (env_alloc(&newenv, 0) < 0) {
  8041608941:	be 00 00 00 00       	mov    $0x0,%esi
  8041608946:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160894a:	48 b8 b2 86 60 41 80 	movabs $0x80416086b2,%rax
  8041608951:	00 00 00 
  8041608954:	ff d0                	callq  *%rax
  8041608956:	85 c0                	test   %eax,%eax
  8041608958:	78 5d                	js     80416089b7 <env_create+0x8c>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  }
      
  newenv->env_type = type;
  804160895a:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  804160895e:	41 89 9e d0 00 00 00 	mov    %ebx,0xd0(%r14)
  if (elf->e_magic != ELF_MAGIC) {
  8041608965:	41 81 3c 24 7f 45 4c 	cmpl   $0x464c457f,(%r12)
  804160896c:	46 
  804160896d:	75 72                	jne    80416089e1 <env_create+0xb6>
  struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff); // Proghdr = prog header. Он лежит со смещением elf->e_phoff относительно начала фаила
  804160896f:	49 8b 5c 24 20       	mov    0x20(%r12),%rbx
  lcr3(PADDR(e->env_pml4e));
  8041608974:	49 8b 8e e8 00 00 00 	mov    0xe8(%r14),%rcx
  if ((uint64_t)kva < KERNBASE)
  804160897b:	48 b8 ff ff ff 3f 80 	movabs $0x803fffffff,%rax
  8041608982:	00 00 00 
  8041608985:	48 39 c1             	cmp    %rax,%rcx
  8041608988:	76 77                	jbe    8041608a01 <env_create+0xd6>
  return (physaddr_t)kva - KERNBASE;
  804160898a:	48 b8 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rax
  8041608991:	ff ff ff 
  8041608994:	48 01 c1             	add    %rax,%rcx
  __asm __volatile("movq %0,%%cr3"
  8041608997:	0f 22 d9             	mov    %rcx,%cr3
  for (size_t i = 0; i < elf->e_phnum; i++) { // elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  804160899a:	66 41 83 7c 24 38 00 	cmpw   $0x0,0x38(%r12)
  80416089a1:	0f 84 15 01 00 00    	je     8041608abc <env_create+0x191>
  80416089a7:	4c 01 e3             	add    %r12,%rbx
  80416089aa:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  80416089b1:	00 
  80416089b2:	e9 fb 00 00 00       	jmpq   8041608ab2 <env_create+0x187>
    panic("Can't allocate new environment");  // попытка выделить среду – если нет – вылет по панике ядра
  80416089b7:	48 ba f0 dc 60 41 80 	movabs $0x804160dcf0,%rdx
  80416089be:	00 00 00 
  80416089c1:	be 02 02 00 00       	mov    $0x202,%esi
  80416089c6:	48 bf 24 dd 60 41 80 	movabs $0x804160dd24,%rdi
  80416089cd:	00 00 00 
  80416089d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416089d5:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  80416089dc:	00 00 00 
  80416089df:	ff d1                	callq  *%rcx
    cprintf("Unexpected ELF format\n");
  80416089e1:	48 bf 2f dd 60 41 80 	movabs $0x804160dd2f,%rdi
  80416089e8:	00 00 00 
  80416089eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416089f0:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416089f7:	00 00 00 
  80416089fa:	ff d2                	callq  *%rdx
    return;
  80416089fc:	e9 0e 01 00 00       	jmpq   8041608b0f <env_create+0x1e4>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041608a01:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  8041608a08:	00 00 00 
  8041608a0b:	be d8 01 00 00       	mov    $0x1d8,%esi
  8041608a10:	48 bf 24 dd 60 41 80 	movabs $0x804160dd24,%rdi
  8041608a17:	00 00 00 
  8041608a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608a1f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608a26:	00 00 00 
  8041608a29:	41 ff d0             	callq  *%r8
      void *src = (void *)(binary + ph[i].p_offset);
  8041608a2c:	4c 89 e0             	mov    %r12,%rax
  8041608a2f:	48 03 43 08          	add    0x8(%rbx),%rax
  8041608a33:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
      void *dst = (void *)ph[i].p_va;
  8041608a37:	48 8b 43 10          	mov    0x10(%rbx),%rax
      size_t memsz  = ph[i].p_memsz;
  8041608a3b:	4c 8b 6b 28          	mov    0x28(%rbx),%r13
      size_t filesz = MIN(ph[i].p_filesz, memsz);
  8041608a3f:	4c 39 6b 20          	cmp    %r13,0x20(%rbx)
  8041608a43:	4d 89 ef             	mov    %r13,%r15
  8041608a46:	4c 0f 46 7b 20       	cmovbe 0x20(%rbx),%r15
      region_alloc(e, (void *)dst, filesz);
  8041608a4b:	4c 89 fa             	mov    %r15,%rdx
  8041608a4e:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8041608a52:	48 89 c6             	mov    %rax,%rsi
  8041608a55:	4c 89 f7             	mov    %r14,%rdi
  8041608a58:	48 b9 fb 84 60 41 80 	movabs $0x80416084fb,%rcx
  8041608a5f:	00 00 00 
  8041608a62:	ff d1                	callq  *%rcx
      memcpy(dst, src, filesz);                // копируем в dst (дистинейшн) src (код) размера filesz
  8041608a64:	4c 89 fa             	mov    %r15,%rdx
  8041608a67:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  8041608a6b:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  8041608a6f:	48 b9 fb be 60 41 80 	movabs $0x804160befb,%rcx
  8041608a76:	00 00 00 
  8041608a79:	ff d1                	callq  *%rcx
      memset(dst + filesz, 0, memsz - filesz); // обнуление памяти по адресу dst + filesz, где количество нулей = memsz - filesz. Т.е. зануляем всю выделенную память сегмента кода, оставшуюяся после копирования src. Возможно, эта строка не нужна
  8041608a7b:	4c 89 ea             	mov    %r13,%rdx
  8041608a7e:	4c 29 fa             	sub    %r15,%rdx
  8041608a81:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041608a85:	4a 8d 3c 38          	lea    (%rax,%r15,1),%rdi
  8041608a89:	be 00 00 00 00       	mov    $0x0,%esi
  8041608a8e:	48 b8 4a be 60 41 80 	movabs $0x804160be4a,%rax
  8041608a95:	00 00 00 
  8041608a98:	ff d0                	callq  *%rax
  for (size_t i = 0; i < elf->e_phnum; i++) { // elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
  8041608a9a:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  8041608a9f:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041608aa3:	48 83 c3 38          	add    $0x38,%rbx
  8041608aa7:	41 0f b7 44 24 38    	movzwl 0x38(%r12),%eax
  8041608aad:	48 39 c1             	cmp    %rax,%rcx
  8041608ab0:	73 0a                	jae    8041608abc <env_create+0x191>
    if (ph[i].p_type == ELF_PROG_LOAD) {
  8041608ab2:	83 3b 01             	cmpl   $0x1,(%rbx)
  8041608ab5:	75 e3                	jne    8041608a9a <env_create+0x16f>
  8041608ab7:	e9 70 ff ff ff       	jmpq   8041608a2c <env_create+0x101>
  lcr3(PADDR(kern_pml4e));
  8041608abc:	48 a1 40 5b 70 41 80 	movabs 0x8041705b40,%rax
  8041608ac3:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  8041608ac6:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  8041608acd:	00 00 00 
  8041608ad0:	48 39 d0             	cmp    %rdx,%rax
  8041608ad3:	76 49                	jbe    8041608b1e <env_create+0x1f3>
  return (physaddr_t)kva - KERNBASE;
  8041608ad5:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  8041608adc:	ff ff ff 
  8041608adf:	48 01 c8             	add    %rcx,%rax
  8041608ae2:	0f 22 d8             	mov    %rax,%cr3
  e->env_tf.tf_rip = elf->e_entry; //Виртуальный адрес точки входа, которому система передает управление при запуске процесса. в регистр rip записываем адрес точки входа для выполнения процесса
  8041608ae5:	49 8b 44 24 18       	mov    0x18(%r12),%rax
  8041608aea:	49 89 86 98 00 00 00 	mov    %rax,0x98(%r14)
  region_alloc(e, (void *) (USTACKTOP - USTACKSIZE), USTACKSIZE);
  8041608af1:	ba 00 40 00 00       	mov    $0x4000,%edx
  8041608af6:	48 be 00 70 ff ff 7f 	movabs $0x7fffff7000,%rsi
  8041608afd:	00 00 00 
  8041608b00:	4c 89 f7             	mov    %r14,%rdi
  8041608b03:	48 b8 fb 84 60 41 80 	movabs $0x80416084fb,%rax
  8041608b0a:	00 00 00 
  8041608b0d:	ff d0                	callq  *%rax

  load_icode(newenv, binary); // load instruction code
  // LAB 3 code end
    
}
  8041608b0f:	48 83 c4 38          	add    $0x38,%rsp
  8041608b13:	5b                   	pop    %rbx
  8041608b14:	41 5c                	pop    %r12
  8041608b16:	41 5d                	pop    %r13
  8041608b18:	41 5e                	pop    %r14
  8041608b1a:	41 5f                	pop    %r15
  8041608b1c:	5d                   	pop    %rbp
  8041608b1d:	c3                   	retq   
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  8041608b1e:	48 89 c1             	mov    %rax,%rcx
  8041608b21:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  8041608b28:	00 00 00 
  8041608b2b:	be e9 01 00 00       	mov    $0x1e9,%esi
  8041608b30:	48 bf 24 dd 60 41 80 	movabs $0x804160dd24,%rdi
  8041608b37:	00 00 00 
  8041608b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608b3f:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608b46:	00 00 00 
  8041608b49:	41 ff d0             	callq  *%r8

0000008041608b4c <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041608b4c:	55                   	push   %rbp
  8041608b4d:	48 89 e5             	mov    %rsp,%rbp
  8041608b50:	53                   	push   %rbx
  8041608b51:	48 83 ec 08          	sub    $0x8,%rsp
  8041608b55:	48 89 fb             	mov    %rdi,%rbx
  physaddr_t pa;

  // If freeing the current environment, switch to kern_pgdir
  // before freeing the page directory, just in case the page
  // gets reused.
  if (e == curenv)
  8041608b58:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  8041608b5f:	00 00 00 
  8041608b62:	48 39 f8             	cmp    %rdi,%rax
  8041608b65:	0f 84 96 01 00 00    	je     8041608d01 <env_free+0x1b5>
    lcr3(kern_cr3);
#endif

  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608b6b:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608b71:	be 00 00 00 00       	mov    $0x0,%esi
  8041608b76:	48 85 c0             	test   %rax,%rax
  8041608b79:	74 06                	je     8041608b81 <env_free+0x35>
  8041608b7b:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041608b81:	48 bf 46 dd 60 41 80 	movabs $0x804160dd46,%rdi
  8041608b88:	00 00 00 
  8041608b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608b90:	48 b9 78 92 60 41 80 	movabs $0x8041609278,%rcx
  8041608b97:	00 00 00 
  8041608b9a:	ff d1                	callq  *%rcx
#ifndef CONFIG_KSPACE
  // Flush all mapped pages in the user portion of the address space
  static_assert(UTOP % PTSIZE == 0, "Misaligned UTOP");

  //UTOP < PDPE[1] start, so all mapped memory should be in first PDPE
  pdpe = KADDR(PTE_ADDR(e->env_pml4e[0]));
  8041608b9c:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608ba3:	48 8b 08             	mov    (%rax),%rcx
  8041608ba6:	48 81 e1 00 f0 ff ff 	and    $0xfffffffffffff000,%rcx
  if (PGNUM(pa) >= npages)
  8041608bad:	48 a1 50 5b 70 41 80 	movabs 0x8041705b50,%rax
  8041608bb4:	00 00 00 
  8041608bb7:	48 89 ca             	mov    %rcx,%rdx
  8041608bba:	48 c1 ea 0c          	shr    $0xc,%rdx
  8041608bbe:	48 39 d0             	cmp    %rdx,%rax
  8041608bc1:	0f 86 55 01 00 00    	jbe    8041608d1c <env_free+0x1d0>
  return (void *)(pa + KERNBASE);
  8041608bc7:	48 ba 00 00 00 40 80 	movabs $0x8040000000,%rdx
  8041608bce:	00 00 00 
  8041608bd1:	48 01 d1             	add    %rdx,%rcx
  for (pdpeno = 0; pdpeno <= PDPE(UTOP); pdpeno++) {
    // only look at mapped page directory pointer index
    if (!(pdpe[pdpeno] & PTE_P))
  8041608bd4:	48 8b 31             	mov    (%rcx),%rsi
  8041608bd7:	40 f6 c6 01          	test   $0x1,%sil
  8041608bdb:	0f 84 63 02 00 00    	je     8041608e44 <env_free+0x2f8>
      continue;

    pgdir       = KADDR(PTE_ADDR(pdpe[pdpeno]));
  8041608be1:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PGNUM(pa) >= npages)
  8041608be8:	48 89 f7             	mov    %rsi,%rdi
  8041608beb:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608bef:	48 39 f8             	cmp    %rdi,%rax
  8041608bf2:	0f 86 4f 01 00 00    	jbe    8041608d47 <env_free+0x1fb>
      page_decref(pa2page(pa));
    }

    // free the page directory
    pa           = PTE_ADDR(pdpe[pdpeno]);
    pdpe[pdpeno] = 0;
  8041608bf8:	48 c7 01 00 00 00 00 	movq   $0x0,(%rcx)
  if (PPN(pa) >= npages) {
  8041608bff:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041608c06:	00 00 00 
  8041608c09:	48 3b 38             	cmp    (%rax),%rdi
  8041608c0c:	0f 83 63 01 00 00    	jae    8041608d75 <env_free+0x229>
  return &pages[PPN(pa)];
  8041608c12:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608c16:	48 a1 58 5b 70 41 80 	movabs 0x8041705b58,%rax
  8041608c1d:	00 00 00 
  8041608c20:	48 01 c7             	add    %rax,%rdi
    page_decref(pa2page(pa));
  8041608c23:	48 b8 d5 4b 60 41 80 	movabs $0x8041604bd5,%rax
  8041608c2a:	00 00 00 
  8041608c2d:	ff d0                	callq  *%rax
  }
  // free the page directory pointer
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  8041608c2f:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608c36:	48 8b 30             	mov    (%rax),%rsi
  8041608c39:	48 81 e6 00 f0 ff ff 	and    $0xfffffffffffff000,%rsi
  if (PPN(pa) >= npages) {
  8041608c40:	48 89 f7             	mov    %rsi,%rdi
  8041608c43:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608c47:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041608c4e:	00 00 00 
  8041608c51:	48 3b 38             	cmp    (%rax),%rdi
  8041608c54:	0f 83 60 01 00 00    	jae    8041608dba <env_free+0x26e>
  return &pages[PPN(pa)];
  8041608c5a:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608c5e:	48 a1 58 5b 70 41 80 	movabs 0x8041705b58,%rax
  8041608c65:	00 00 00 
  8041608c68:	48 01 c7             	add    %rax,%rdi
  8041608c6b:	48 b8 d5 4b 60 41 80 	movabs $0x8041604bd5,%rax
  8041608c72:	00 00 00 
  8041608c75:	ff d0                	callq  *%rax
  // free the page map level 4 (PML4)
  e->env_pml4e[0] = 0;
  8041608c77:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608c7e:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  pa              = e->env_cr3;
  8041608c85:	48 8b b3 f0 00 00 00 	mov    0xf0(%rbx),%rsi
  e->env_pml4e    = 0;
  8041608c8c:	48 c7 83 e8 00 00 00 	movq   $0x0,0xe8(%rbx)
  8041608c93:	00 00 00 00 
  e->env_cr3      = 0;
  8041608c97:	48 c7 83 f0 00 00 00 	movq   $0x0,0xf0(%rbx)
  8041608c9e:	00 00 00 00 
  if (PPN(pa) >= npages) {
  8041608ca2:	48 89 f7             	mov    %rsi,%rdi
  8041608ca5:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608ca9:	48 b8 50 5b 70 41 80 	movabs $0x8041705b50,%rax
  8041608cb0:	00 00 00 
  8041608cb3:	48 3b 38             	cmp    (%rax),%rdi
  8041608cb6:	0f 83 43 01 00 00    	jae    8041608dff <env_free+0x2b3>
  return &pages[PPN(pa)];
  8041608cbc:	48 c1 e7 04          	shl    $0x4,%rdi
  8041608cc0:	48 a1 58 5b 70 41 80 	movabs 0x8041705b58,%rax
  8041608cc7:	00 00 00 
  8041608cca:	48 01 c7             	add    %rax,%rdi
  page_decref(pa2page(pa));
  8041608ccd:	48 b8 d5 4b 60 41 80 	movabs $0x8041604bd5,%rax
  8041608cd4:	00 00 00 
  8041608cd7:	ff d0                	callq  *%rax
#endif
  // return the environment to the free list
  e->env_status = ENV_FREE;
  8041608cd9:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  8041608ce0:	00 00 00 
  e->env_link   = env_free_list;
  8041608ce3:	48 b8 28 46 70 41 80 	movabs $0x8041704628,%rax
  8041608cea:	00 00 00 
  8041608ced:	48 8b 10             	mov    (%rax),%rdx
  8041608cf0:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  8041608cf7:	48 89 18             	mov    %rbx,(%rax)
}
  8041608cfa:	48 83 c4 08          	add    $0x8,%rsp
  8041608cfe:	5b                   	pop    %rbx
  8041608cff:	5d                   	pop    %rbp
  8041608d00:	c3                   	retq   
  8041608d01:	48 b9 48 5b 70 41 80 	movabs $0x8041705b48,%rcx
  8041608d08:	00 00 00 
  8041608d0b:	48 8b 11             	mov    (%rcx),%rdx
  8041608d0e:	0f 22 da             	mov    %rdx,%cr3
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041608d11:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041608d17:	e9 5f fe ff ff       	jmpq   8041608b7b <env_free+0x2f>
    _panic(file, line, "KADDR called with invalid pa %p", (void *)pa);
  8041608d1c:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041608d23:	00 00 00 
  8041608d26:	be 28 02 00 00       	mov    $0x228,%esi
  8041608d2b:	48 bf 24 dd 60 41 80 	movabs $0x804160dd24,%rdi
  8041608d32:	00 00 00 
  8041608d35:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d3a:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608d41:	00 00 00 
  8041608d44:	41 ff d0             	callq  *%r8
  8041608d47:	48 89 f1             	mov    %rsi,%rcx
  8041608d4a:	48 ba a0 d0 60 41 80 	movabs $0x804160d0a0,%rdx
  8041608d51:	00 00 00 
  8041608d54:	be 2e 02 00 00       	mov    $0x22e,%esi
  8041608d59:	48 bf 24 dd 60 41 80 	movabs $0x804160dd24,%rdi
  8041608d60:	00 00 00 
  8041608d63:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d68:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041608d6f:	00 00 00 
  8041608d72:	41 ff d0             	callq  *%r8
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608d75:	48 bf 5f da 60 41 80 	movabs $0x804160da5f,%rdi
  8041608d7c:	00 00 00 
  8041608d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608d84:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041608d8b:	00 00 00 
  8041608d8e:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608d90:	48 ba d8 d1 60 41 80 	movabs $0x804160d1d8,%rdx
  8041608d97:	00 00 00 
  8041608d9a:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608d9f:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041608da6:	00 00 00 
  8041608da9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608dae:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608db5:	00 00 00 
  8041608db8:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608dba:	48 bf 5f da 60 41 80 	movabs $0x804160da5f,%rdi
  8041608dc1:	00 00 00 
  8041608dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608dc9:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041608dd0:	00 00 00 
  8041608dd3:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608dd5:	48 ba d8 d1 60 41 80 	movabs $0x804160d1d8,%rdx
  8041608ddc:	00 00 00 
  8041608ddf:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608de4:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041608deb:	00 00 00 
  8041608dee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608df3:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608dfa:	00 00 00 
  8041608dfd:	ff d1                	callq  *%rcx
    cprintf("accessing %lx\n", (unsigned long)pa);
  8041608dff:	48 bf 5f da 60 41 80 	movabs $0x804160da5f,%rdi
  8041608e06:	00 00 00 
  8041608e09:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e0e:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041608e15:	00 00 00 
  8041608e18:	ff d2                	callq  *%rdx
    panic("pa2page called with invalid pa");
  8041608e1a:	48 ba d8 d1 60 41 80 	movabs $0x804160d1d8,%rdx
  8041608e21:	00 00 00 
  8041608e24:	be 5a 00 00 00       	mov    $0x5a,%esi
  8041608e29:	48 bf 40 da 60 41 80 	movabs $0x804160da40,%rdi
  8041608e30:	00 00 00 
  8041608e33:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608e38:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608e3f:	00 00 00 
  8041608e42:	ff d1                	callq  *%rcx
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  8041608e44:	48 8b 83 e8 00 00 00 	mov    0xe8(%rbx),%rax
  8041608e4b:	48 8b 38             	mov    (%rax),%rdi
  8041608e4e:	48 c1 ef 0c          	shr    $0xc,%rdi
  8041608e52:	e9 03 fe ff ff       	jmpq   8041608c5a <env_free+0x10e>

0000008041608e57 <env_destroy>:
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
    
  // LAB 3 code
  e->env_status = ENV_DYING;
  8041608e57:	c7 87 d4 00 00 00 01 	movl   $0x1,0xd4(%rdi)
  8041608e5e:	00 00 00 
  if (e == curenv) {
  8041608e61:	48 b8 18 46 70 41 80 	movabs $0x8041704618,%rax
  8041608e68:	00 00 00 
  8041608e6b:	48 39 38             	cmp    %rdi,(%rax)
  8041608e6e:	74 01                	je     8041608e71 <env_destroy+0x1a>
  8041608e70:	c3                   	retq   
env_destroy(struct Env *e) {
  8041608e71:	55                   	push   %rbp
  8041608e72:	48 89 e5             	mov    %rsp,%rbp
    env_free(e);
  8041608e75:	48 b8 4c 8b 60 41 80 	movabs $0x8041608b4c,%rax
  8041608e7c:	00 00 00 
  8041608e7f:	ff d0                	callq  *%rax
    sched_yield();
  8041608e81:	48 b8 01 ad 60 41 80 	movabs $0x804160ad01,%rax
  8041608e88:	00 00 00 
  8041608e8b:	ff d0                	callq  *%rax

0000008041608e8d <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041608e8d:	55                   	push   %rbp
  8041608e8e:	48 89 e5             	mov    %rsp,%rbp
        [ rd15 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r15)),
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
  __asm __volatile("movq %0,%%rsp\n" POPA
  8041608e91:	48 89 fc             	mov    %rdi,%rsp
  8041608e94:	4c 8b 3c 24          	mov    (%rsp),%r15
  8041608e98:	4c 8b 74 24 08       	mov    0x8(%rsp),%r14
  8041608e9d:	4c 8b 6c 24 10       	mov    0x10(%rsp),%r13
  8041608ea2:	4c 8b 64 24 18       	mov    0x18(%rsp),%r12
  8041608ea7:	4c 8b 5c 24 20       	mov    0x20(%rsp),%r11
  8041608eac:	4c 8b 54 24 28       	mov    0x28(%rsp),%r10
  8041608eb1:	4c 8b 4c 24 30       	mov    0x30(%rsp),%r9
  8041608eb6:	4c 8b 44 24 38       	mov    0x38(%rsp),%r8
  8041608ebb:	48 8b 74 24 40       	mov    0x40(%rsp),%rsi
  8041608ec0:	48 8b 7c 24 48       	mov    0x48(%rsp),%rdi
  8041608ec5:	48 8b 6c 24 50       	mov    0x50(%rsp),%rbp
  8041608eca:	48 8b 54 24 58       	mov    0x58(%rsp),%rdx
  8041608ecf:	48 8b 4c 24 60       	mov    0x60(%rsp),%rcx
  8041608ed4:	48 8b 5c 24 68       	mov    0x68(%rsp),%rbx
  8041608ed9:	48 8b 44 24 70       	mov    0x70(%rsp),%rax
  8041608ede:	48 83 c4 78          	add    $0x78,%rsp
  8041608ee2:	8e 04 24             	mov    (%rsp),%es
  8041608ee5:	8e 5c 24 08          	mov    0x8(%rsp),%ds
  8041608ee9:	48 83 c4 10          	add    $0x10,%rsp
  8041608eed:	48 83 c4 10          	add    $0x10,%rsp
  8041608ef1:	48 cf                	iretq  
                   "\tiretq"
                   :
                   : "g"(tf)
                   : "memory");
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041608ef3:	48 ba 5c dd 60 41 80 	movabs $0x804160dd5c,%rdx
  8041608efa:	00 00 00 
  8041608efd:	be be 02 00 00       	mov    $0x2be,%esi
  8041608f02:	48 bf 24 dd 60 41 80 	movabs $0x804160dd24,%rdi
  8041608f09:	00 00 00 
  8041608f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041608f11:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041608f18:	00 00 00 
  8041608f1b:	ff d1                	callq  *%rcx

0000008041608f1d <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  8041608f1d:	55                   	push   %rbp
  8041608f1e:	48 89 e5             	mov    %rsp,%rbp
  8041608f21:	41 54                	push   %r12
  8041608f23:	53                   	push   %rbx
  8041608f24:	48 89 fb             	mov    %rdi,%rbx
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //
    
  // LAB 3 code
  if (curenv) {  // if curenv == False, значит, какого-нибудь исполняемого процесса нет
  8041608f27:	48 b8 18 46 70 41 80 	movabs $0x8041704618,%rax
  8041608f2e:	00 00 00 
  8041608f31:	4c 8b 20             	mov    (%rax),%r12
  8041608f34:	4d 85 e4             	test   %r12,%r12
  8041608f37:	74 12                	je     8041608f4b <env_run+0x2e>
    if (curenv->env_status == ENV_DYING) { // если процесс стал зомби
  8041608f39:	41 8b 84 24 d4 00 00 	mov    0xd4(%r12),%eax
  8041608f40:	00 
  8041608f41:	83 f8 01             	cmp    $0x1,%eax
  8041608f44:	74 3c                	je     8041608f82 <env_run+0x65>
      struct Env *old = curenv;  // ставим старый адрес
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
      if (old == e) { // e - аргумент функции, который к нам пришел
        sched_yield();  // переключение системными вызовами
      }
    } else if (curenv->env_status == ENV_RUNNING) { // если процесс можем запустить
  8041608f46:	83 f8 03             	cmp    $0x3,%eax
  8041608f49:	74 57                	je     8041608fa2 <env_run+0x85>
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
    }
  }
      
  curenv = e;  // текущая среда – е
  8041608f4b:	48 89 d8             	mov    %rbx,%rax
  8041608f4e:	48 a3 18 46 70 41 80 	movabs %rax,0x8041704618
  8041608f55:	00 00 00 
  curenv->env_status = ENV_RUNNING; // устанавливаем статус среды на "выполняется"
  8041608f58:	c7 83 d4 00 00 00 03 	movl   $0x3,0xd4(%rbx)
  8041608f5f:	00 00 00 
  curenv->env_runs++; // обновляем количество работающих контекстов
  8041608f62:	83 83 d8 00 00 00 01 	addl   $0x1,0xd8(%rbx)
  8041608f69:	48 8b 83 f0 00 00 00 	mov    0xf0(%rbx),%rax
  8041608f70:	0f 22 d8             	mov    %rax,%cr3
  // LAB 8 code
  lcr3(curenv->env_cr3);
  // LAB 8 code end

  // LAB 3 code
  env_pop_tf(&curenv->env_tf);
  8041608f73:	48 89 df             	mov    %rbx,%rdi
  8041608f76:	48 b8 8d 8e 60 41 80 	movabs $0x8041608e8d,%rax
  8041608f7d:	00 00 00 
  8041608f80:	ff d0                	callq  *%rax
      env_free(curenv);  // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
  8041608f82:	4c 89 e7             	mov    %r12,%rdi
  8041608f85:	48 b8 4c 8b 60 41 80 	movabs $0x8041608b4c,%rax
  8041608f8c:	00 00 00 
  8041608f8f:	ff d0                	callq  *%rax
      if (old == e) { // e - аргумент функции, который к нам пришел
  8041608f91:	49 39 dc             	cmp    %rbx,%r12
  8041608f94:	75 b5                	jne    8041608f4b <env_run+0x2e>
        sched_yield();  // переключение системными вызовами
  8041608f96:	48 b8 01 ad 60 41 80 	movabs $0x804160ad01,%rax
  8041608f9d:	00 00 00 
  8041608fa0:	ff d0                	callq  *%rax
      curenv->env_status = ENV_RUNNABLE;  // запускаем процесс
  8041608fa2:	41 c7 84 24 d4 00 00 	movl   $0x2,0xd4(%r12)
  8041608fa9:	00 02 00 00 00 
  8041608fae:	eb 9b                	jmp    8041608f4b <env_run+0x2e>

0000008041608fb0 <rtc_timer_pic_interrupt>:
  // DELETED in LAB 5 end
  rtc_init();
}

static void
rtc_timer_pic_interrupt(void) {
  8041608fb0:	55                   	push   %rbp
  8041608fb1:	48 89 e5             	mov    %rsp,%rbp
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  8041608fb4:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  8041608fbb:	00 00 00 
  8041608fbe:	89 c7                	mov    %eax,%edi
  8041608fc0:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  8041608fc6:	48 b8 a0 90 60 41 80 	movabs $0x80416090a0,%rax
  8041608fcd:	00 00 00 
  8041608fd0:	ff d0                	callq  *%rax
}
  8041608fd2:	5d                   	pop    %rbp
  8041608fd3:	c3                   	retq   

0000008041608fd4 <rtc_init>:
  __asm __volatile("inb %w1,%0"
  8041608fd4:	b9 70 00 00 00       	mov    $0x70,%ecx
  8041608fd9:	89 ca                	mov    %ecx,%edx
  8041608fdb:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) & ~NMI_LOCK);
}

static inline void
nmi_disable(void) {
  outb(0x70, inb(0x70) | NMI_LOCK);
  8041608fdc:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  8041608fdf:	ee                   	out    %al,(%dx)
  8041608fe0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041608fe5:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608fe6:	be 71 00 00 00       	mov    $0x71,%esi
  8041608feb:	89 f2                	mov    %esi,%edx
  8041608fed:	ec                   	in     (%dx),%al
  
  // меняем делитель частоты регистра часов А,
  // чтобы прерывания приходили раз в полсекунды
  outb(IO_RTC_CMND, RTC_AREG);
  reg_a = inb(IO_RTC_DATA);
  reg_a = reg_a | 0x0F; // биты 0-3 = 1 => 500 мс (2 Гц) 
  8041608fee:	83 c8 0f             	or     $0xf,%eax
  __asm __volatile("outb %0,%w1"
  8041608ff1:	ee                   	out    %al,(%dx)
  8041608ff2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8041608ff7:	89 ca                	mov    %ecx,%edx
  8041608ff9:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041608ffa:	89 f2                	mov    %esi,%edx
  8041608ffc:	ec                   	in     (%dx),%al
  outb(IO_RTC_DATA, reg_a);

  // устанавливаем бит RTC_PIE в регистре часов В
  outb(IO_RTC_CMND, RTC_BREG);
  reg_b = inb(IO_RTC_DATA);
  reg_b = reg_b | RTC_PIE; 
  8041608ffd:	83 c8 40             	or     $0x40,%eax
  __asm __volatile("outb %0,%w1"
  8041609000:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041609001:	89 ca                	mov    %ecx,%edx
  8041609003:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  8041609004:	83 e0 7f             	and    $0x7f,%eax
  8041609007:	ee                   	out    %al,(%dx)
  outb(IO_RTC_DATA, reg_b);

  // разрешить прерывания
  nmi_enable();
  // LAB 4 code end
}
  8041609008:	c3                   	retq   

0000008041609009 <rtc_timer_init>:
rtc_timer_init(void) {
  8041609009:	55                   	push   %rbp
  804160900a:	48 89 e5             	mov    %rsp,%rbp
  rtc_init();
  804160900d:	48 b8 d4 8f 60 41 80 	movabs $0x8041608fd4,%rax
  8041609014:	00 00 00 
  8041609017:	ff d0                	callq  *%rax
}
  8041609019:	5d                   	pop    %rbp
  804160901a:	c3                   	retq   

000000804160901b <rtc_check_status>:
  804160901b:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041609020:	ba 70 00 00 00       	mov    $0x70,%edx
  8041609025:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041609026:	ba 71 00 00 00       	mov    $0x71,%edx
  804160902b:	ec                   	in     (%dx),%al
  outb(IO_RTC_CMND, RTC_CREG);
  status = inb(IO_RTC_DATA);
  // LAB 4 code end

  return status;
}
  804160902c:	c3                   	retq   

000000804160902d <rtc_timer_pic_handle>:
rtc_timer_pic_handle(void) {
  804160902d:	55                   	push   %rbp
  804160902e:	48 89 e5             	mov    %rsp,%rbp
  rtc_check_status();
  8041609031:	48 b8 1b 90 60 41 80 	movabs $0x804160901b,%rax
  8041609038:	00 00 00 
  804160903b:	ff d0                	callq  *%rax
  pic_send_eoi(IRQ_CLOCK);
  804160903d:	bf 08 00 00 00       	mov    $0x8,%edi
  8041609042:	48 b8 05 92 60 41 80 	movabs $0x8041609205,%rax
  8041609049:	00 00 00 
  804160904c:	ff d0                	callq  *%rax
}
  804160904e:	5d                   	pop    %rbp
  804160904f:	c3                   	retq   

0000008041609050 <mc146818_read>:
  __asm __volatile("outb %0,%w1"
  8041609050:	ba 70 00 00 00       	mov    $0x70,%edx
  8041609055:	89 f8                	mov    %edi,%eax
  8041609057:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041609058:	ba 71 00 00 00       	mov    $0x71,%edx
  804160905d:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg) {
  outb(IO_RTC_CMND, reg);
  return inb(IO_RTC_DATA);
  804160905e:	0f b6 c0             	movzbl %al,%eax
}
  8041609061:	c3                   	retq   

0000008041609062 <mc146818_write>:
  __asm __volatile("outb %0,%w1"
  8041609062:	ba 70 00 00 00       	mov    $0x70,%edx
  8041609067:	89 f8                	mov    %edi,%eax
  8041609069:	ee                   	out    %al,(%dx)
  804160906a:	ba 71 00 00 00       	mov    $0x71,%edx
  804160906f:	89 f0                	mov    %esi,%eax
  8041609071:	ee                   	out    %al,(%dx)

void
mc146818_write(unsigned reg, unsigned datum) {
  outb(IO_RTC_CMND, reg);
  outb(IO_RTC_DATA, datum);
}
  8041609072:	c3                   	retq   

0000008041609073 <mc146818_read16>:
  8041609073:	41 b8 70 00 00 00    	mov    $0x70,%r8d
  8041609079:	89 f8                	mov    %edi,%eax
  804160907b:	44 89 c2             	mov    %r8d,%edx
  804160907e:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160907f:	b9 71 00 00 00       	mov    $0x71,%ecx
  8041609084:	89 ca                	mov    %ecx,%edx
  8041609086:	ec                   	in     (%dx),%al
  8041609087:	89 c6                	mov    %eax,%esi

unsigned
mc146818_read16(unsigned reg) {
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041609089:	8d 47 01             	lea    0x1(%rdi),%eax
  __asm __volatile("outb %0,%w1"
  804160908c:	44 89 c2             	mov    %r8d,%edx
  804160908f:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041609090:	89 ca                	mov    %ecx,%edx
  8041609092:	ec                   	in     (%dx),%al
  return inb(IO_RTC_DATA);
  8041609093:	0f b6 c0             	movzbl %al,%eax
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  8041609096:	c1 e0 08             	shl    $0x8,%eax
  return inb(IO_RTC_DATA);
  8041609099:	40 0f b6 f6          	movzbl %sil,%esi
  return mc146818_read(reg) | (mc146818_read(reg + 1) << 8);
  804160909d:	09 f0                	or     %esi,%eax
  804160909f:	c3                   	retq   

00000080416090a0 <irq_setmask_8259A>:
}

void
irq_setmask_8259A(uint16_t mask) {
  int i;
  irq_mask_8259A = mask;
  80416090a0:	89 f8                	mov    %edi,%eax
  80416090a2:	66 a3 e8 f7 61 41 80 	movabs %ax,0x804161f7e8
  80416090a9:	00 00 00 
  if (!didinit)
  80416090ac:	48 b8 30 46 70 41 80 	movabs $0x8041704630,%rax
  80416090b3:	00 00 00 
  80416090b6:	80 38 00             	cmpb   $0x0,(%rax)
  80416090b9:	75 01                	jne    80416090bc <irq_setmask_8259A+0x1c>
  80416090bb:	c3                   	retq   
irq_setmask_8259A(uint16_t mask) {
  80416090bc:	55                   	push   %rbp
  80416090bd:	48 89 e5             	mov    %rsp,%rbp
  80416090c0:	41 56                	push   %r14
  80416090c2:	41 55                	push   %r13
  80416090c4:	41 54                	push   %r12
  80416090c6:	53                   	push   %rbx
  80416090c7:	41 89 fc             	mov    %edi,%r12d
  80416090ca:	89 f8                	mov    %edi,%eax
  __asm __volatile("outb %0,%w1"
  80416090cc:	ba 21 00 00 00       	mov    $0x21,%edx
  80416090d1:	ee                   	out    %al,(%dx)
    return;
  outb(IO_PIC1_DATA, (char)mask);
  outb(IO_PIC2_DATA, (char)(mask >> 8));
  80416090d2:	66 c1 e8 08          	shr    $0x8,%ax
  80416090d6:	ba a1 00 00 00       	mov    $0xa1,%edx
  80416090db:	ee                   	out    %al,(%dx)
  cprintf("enabled interrupts:");
  80416090dc:	48 bf 64 dd 60 41 80 	movabs $0x804160dd64,%rdi
  80416090e3:	00 00 00 
  80416090e6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416090eb:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  80416090f2:	00 00 00 
  80416090f5:	ff d2                	callq  *%rdx
  for (i = 0; i < 16; i++)
  80416090f7:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (~mask & (1 << i))
  80416090fc:	45 0f b7 e4          	movzwl %r12w,%r12d
  8041609100:	41 f7 d4             	not    %r12d
      cprintf(" %d", i);
  8041609103:	49 be ce e5 60 41 80 	movabs $0x804160e5ce,%r14
  804160910a:	00 00 00 
  804160910d:	49 bd 78 92 60 41 80 	movabs $0x8041609278,%r13
  8041609114:	00 00 00 
  8041609117:	eb 15                	jmp    804160912e <irq_setmask_8259A+0x8e>
  8041609119:	89 de                	mov    %ebx,%esi
  804160911b:	4c 89 f7             	mov    %r14,%rdi
  804160911e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609123:	41 ff d5             	callq  *%r13
  for (i = 0; i < 16; i++)
  8041609126:	83 c3 01             	add    $0x1,%ebx
  8041609129:	83 fb 10             	cmp    $0x10,%ebx
  804160912c:	74 08                	je     8041609136 <irq_setmask_8259A+0x96>
    if (~mask & (1 << i))
  804160912e:	41 0f a3 dc          	bt     %ebx,%r12d
  8041609132:	73 f2                	jae    8041609126 <irq_setmask_8259A+0x86>
  8041609134:	eb e3                	jmp    8041609119 <irq_setmask_8259A+0x79>
  cprintf("\n");
  8041609136:	48 bf e4 db 60 41 80 	movabs $0x804160dbe4,%rdi
  804160913d:	00 00 00 
  8041609140:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609145:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160914c:	00 00 00 
  804160914f:	ff d2                	callq  *%rdx
}
  8041609151:	5b                   	pop    %rbx
  8041609152:	41 5c                	pop    %r12
  8041609154:	41 5d                	pop    %r13
  8041609156:	41 5e                	pop    %r14
  8041609158:	5d                   	pop    %rbp
  8041609159:	c3                   	retq   

000000804160915a <pic_init>:
  didinit = 1;
  804160915a:	48 b8 30 46 70 41 80 	movabs $0x8041704630,%rax
  8041609161:	00 00 00 
  8041609164:	c6 00 01             	movb   $0x1,(%rax)
  8041609167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160916c:	be 21 00 00 00       	mov    $0x21,%esi
  8041609171:	89 f2                	mov    %esi,%edx
  8041609173:	ee                   	out    %al,(%dx)
  8041609174:	b9 a1 00 00 00       	mov    $0xa1,%ecx
  8041609179:	89 ca                	mov    %ecx,%edx
  804160917b:	ee                   	out    %al,(%dx)
  804160917c:	41 b9 11 00 00 00    	mov    $0x11,%r9d
  8041609182:	bf 20 00 00 00       	mov    $0x20,%edi
  8041609187:	44 89 c8             	mov    %r9d,%eax
  804160918a:	89 fa                	mov    %edi,%edx
  804160918c:	ee                   	out    %al,(%dx)
  804160918d:	b8 20 00 00 00       	mov    $0x20,%eax
  8041609192:	89 f2                	mov    %esi,%edx
  8041609194:	ee                   	out    %al,(%dx)
  8041609195:	b8 04 00 00 00       	mov    $0x4,%eax
  804160919a:	ee                   	out    %al,(%dx)
  804160919b:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  80416091a1:	44 89 c0             	mov    %r8d,%eax
  80416091a4:	ee                   	out    %al,(%dx)
  80416091a5:	be a0 00 00 00       	mov    $0xa0,%esi
  80416091aa:	44 89 c8             	mov    %r9d,%eax
  80416091ad:	89 f2                	mov    %esi,%edx
  80416091af:	ee                   	out    %al,(%dx)
  80416091b0:	b8 28 00 00 00       	mov    $0x28,%eax
  80416091b5:	89 ca                	mov    %ecx,%edx
  80416091b7:	ee                   	out    %al,(%dx)
  80416091b8:	b8 02 00 00 00       	mov    $0x2,%eax
  80416091bd:	ee                   	out    %al,(%dx)
  80416091be:	44 89 c0             	mov    %r8d,%eax
  80416091c1:	ee                   	out    %al,(%dx)
  80416091c2:	41 b8 68 00 00 00    	mov    $0x68,%r8d
  80416091c8:	44 89 c0             	mov    %r8d,%eax
  80416091cb:	89 fa                	mov    %edi,%edx
  80416091cd:	ee                   	out    %al,(%dx)
  80416091ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416091d3:	89 c8                	mov    %ecx,%eax
  80416091d5:	ee                   	out    %al,(%dx)
  80416091d6:	44 89 c0             	mov    %r8d,%eax
  80416091d9:	89 f2                	mov    %esi,%edx
  80416091db:	ee                   	out    %al,(%dx)
  80416091dc:	89 c8                	mov    %ecx,%eax
  80416091de:	ee                   	out    %al,(%dx)
  if (irq_mask_8259A != 0xFFFF)
  80416091df:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  80416091e6:	00 00 00 
  80416091e9:	66 83 f8 ff          	cmp    $0xffff,%ax
  80416091ed:	75 01                	jne    80416091f0 <pic_init+0x96>
  80416091ef:	c3                   	retq   
pic_init(void) {
  80416091f0:	55                   	push   %rbp
  80416091f1:	48 89 e5             	mov    %rsp,%rbp
    irq_setmask_8259A(irq_mask_8259A);
  80416091f4:	0f b7 f8             	movzwl %ax,%edi
  80416091f7:	48 b8 a0 90 60 41 80 	movabs $0x80416090a0,%rax
  80416091fe:	00 00 00 
  8041609201:	ff d0                	callq  *%rax
}
  8041609203:	5d                   	pop    %rbp
  8041609204:	c3                   	retq   

0000008041609205 <pic_send_eoi>:

void
pic_send_eoi(uint8_t irq) {
  if (irq >= 8)
  8041609205:	40 80 ff 07          	cmp    $0x7,%dil
  8041609209:	76 0b                	jbe    8041609216 <pic_send_eoi+0x11>
  804160920b:	b8 20 00 00 00       	mov    $0x20,%eax
  8041609210:	ba a0 00 00 00       	mov    $0xa0,%edx
  8041609215:	ee                   	out    %al,(%dx)
  8041609216:	b8 20 00 00 00       	mov    $0x20,%eax
  804160921b:	ba 20 00 00 00       	mov    $0x20,%edx
  8041609220:	ee                   	out    %al,(%dx)
    outb(IO_PIC2_CMND, PIC_EOI);
  outb(IO_PIC1_CMND, PIC_EOI);
}
  8041609221:	c3                   	retq   

0000008041609222 <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  8041609222:	55                   	push   %rbp
  8041609223:	48 89 e5             	mov    %rsp,%rbp
  8041609226:	53                   	push   %rbx
  8041609227:	48 83 ec 08          	sub    $0x8,%rsp
  804160922b:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  804160922e:	48 b8 57 0d 60 41 80 	movabs $0x8041600d57,%rax
  8041609235:	00 00 00 
  8041609238:	ff d0                	callq  *%rax
  (*cnt)++;
  804160923a:	83 03 01             	addl   $0x1,(%rbx)
}
  804160923d:	48 83 c4 08          	add    $0x8,%rsp
  8041609241:	5b                   	pop    %rbx
  8041609242:	5d                   	pop    %rbp
  8041609243:	c3                   	retq   

0000008041609244 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8041609244:	55                   	push   %rbp
  8041609245:	48 89 e5             	mov    %rsp,%rbp
  8041609248:	48 83 ec 10          	sub    $0x10,%rsp
  804160924c:	48 89 fa             	mov    %rdi,%rdx
  804160924f:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  8041609252:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  8041609259:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  804160925d:	48 bf 22 92 60 41 80 	movabs $0x8041609222,%rdi
  8041609264:	00 00 00 
  8041609267:	48 b8 93 b3 60 41 80 	movabs $0x804160b393,%rax
  804160926e:	00 00 00 
  8041609271:	ff d0                	callq  *%rax
  return cnt;
}
  8041609273:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041609276:	c9                   	leaveq 
  8041609277:	c3                   	retq   

0000008041609278 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8041609278:	55                   	push   %rbp
  8041609279:	48 89 e5             	mov    %rsp,%rbp
  804160927c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041609283:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  804160928a:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041609291:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041609298:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160929f:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80416092a6:	84 c0                	test   %al,%al
  80416092a8:	74 20                	je     80416092ca <cprintf+0x52>
  80416092aa:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80416092ae:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80416092b2:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80416092b6:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80416092ba:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80416092be:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80416092c2:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80416092c6:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  80416092ca:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80416092d1:	00 00 00 
  80416092d4:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80416092db:	00 00 00 
  80416092de:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416092e2:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80416092e9:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80416092f0:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80416092f7:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80416092fe:	48 b8 44 92 60 41 80 	movabs $0x8041609244,%rax
  8041609305:	00 00 00 
  8041609308:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  804160930a:	c9                   	leaveq 
  804160930b:	c3                   	retq   

000000804160930c <trap_init_percpu>:
// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void) {
  // Setup a TSS so that we get the right stack
  // when we trap to the kernel.
  ts.ts_esp0 = KSTACKTOP;
  804160930c:	48 ba 60 56 70 41 80 	movabs $0x8041705660,%rdx
  8041609313:	00 00 00 
  8041609316:	48 b8 00 00 00 40 80 	movabs $0x8040000000,%rax
  804160931d:	00 00 00 
  8041609320:	48 89 42 04          	mov    %rax,0x4(%rdx)

  // Initialize the TSS slot of the gdt.
  SETTSS((struct SystemSegdesc64 *)(&gdt[(GD_TSS0 >> 3)]), STS_T64A,
  8041609324:	48 b8 60 f7 61 41 80 	movabs $0x804161f760,%rax
  804160932b:	00 00 00 
  804160932e:	66 c7 40 38 68 00    	movw   $0x68,0x38(%rax)
  8041609334:	66 89 50 3a          	mov    %dx,0x3a(%rax)
  8041609338:	48 89 d1             	mov    %rdx,%rcx
  804160933b:	48 c1 e9 10          	shr    $0x10,%rcx
  804160933f:	88 48 3c             	mov    %cl,0x3c(%rax)
  8041609342:	c6 40 3d 89          	movb   $0x89,0x3d(%rax)
  8041609346:	c6 40 3e 00          	movb   $0x0,0x3e(%rax)
  804160934a:	48 89 d1             	mov    %rdx,%rcx
  804160934d:	48 c1 e9 18          	shr    $0x18,%rcx
  8041609351:	88 48 3f             	mov    %cl,0x3f(%rax)
  8041609354:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609358:	89 50 40             	mov    %edx,0x40(%rax)
  804160935b:	c6 40 44 00          	movb   $0x0,0x44(%rax)
  804160935f:	c6 40 45 00          	movb   $0x0,0x45(%rax)
  8041609363:	66 c7 40 46 00 00    	movw   $0x0,0x46(%rax)
  __asm __volatile("ltr %0"
  8041609369:	b8 38 00 00 00       	mov    $0x38,%eax
  804160936e:	0f 00 d8             	ltr    %ax
  __asm __volatile("lidt (%0)"
  8041609371:	48 b8 f0 f7 61 41 80 	movabs $0x804161f7f0,%rax
  8041609378:	00 00 00 
  804160937b:	0f 01 18             	lidt   (%rax)
  // bottom three bits are special; we leave them 0)
  ltr(GD_TSS0);

  // Load the IDT
  lidt(&idt_pd);
}
  804160937e:	c3                   	retq   

000000804160937f <trap_init>:
trap_init(void) {
  804160937f:	55                   	push   %rbp
  8041609380:	48 89 e5             	mov    %rsp,%rbp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, (uint64_t) &divide_thdlr, 0);
  8041609383:	48 b8 40 46 70 41 80 	movabs $0x8041704640,%rax
  804160938a:	00 00 00 
  804160938d:	48 ba 5c 9f 60 41 80 	movabs $0x8041609f5c,%rdx
  8041609394:	00 00 00 
  8041609397:	66 89 10             	mov    %dx,(%rax)
  804160939a:	66 c7 40 02 08 00    	movw   $0x8,0x2(%rax)
  80416093a0:	c6 40 04 00          	movb   $0x0,0x4(%rax)
  80416093a4:	c6 40 05 8e          	movb   $0x8e,0x5(%rax)
  80416093a8:	48 89 d1             	mov    %rdx,%rcx
  80416093ab:	48 c1 e9 10          	shr    $0x10,%rcx
  80416093af:	66 89 48 06          	mov    %cx,0x6(%rax)
  80416093b3:	48 c1 ea 20          	shr    $0x20,%rdx
  80416093b7:	89 50 08             	mov    %edx,0x8(%rax)
  80416093ba:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%rax)
	SETGATE(idt[T_DEBUG], 0, GD_KT, (uint64_t) &debug_thdlr, 0);
  80416093c1:	48 ba 62 9f 60 41 80 	movabs $0x8041609f62,%rdx
  80416093c8:	00 00 00 
  80416093cb:	66 89 50 10          	mov    %dx,0x10(%rax)
  80416093cf:	66 c7 40 12 08 00    	movw   $0x8,0x12(%rax)
  80416093d5:	c6 40 14 00          	movb   $0x0,0x14(%rax)
  80416093d9:	c6 40 15 8e          	movb   $0x8e,0x15(%rax)
  80416093dd:	48 89 d1             	mov    %rdx,%rcx
  80416093e0:	48 c1 e9 10          	shr    $0x10,%rcx
  80416093e4:	66 89 48 16          	mov    %cx,0x16(%rax)
  80416093e8:	48 c1 ea 20          	shr    $0x20,%rdx
  80416093ec:	89 50 18             	mov    %edx,0x18(%rax)
  80416093ef:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%rax)
	SETGATE(idt[T_NMI], 0, GD_KT, (uint64_t) &nmi_thdlr, 0);
  80416093f6:	48 ba 6c 9f 60 41 80 	movabs $0x8041609f6c,%rdx
  80416093fd:	00 00 00 
  8041609400:	66 89 50 20          	mov    %dx,0x20(%rax)
  8041609404:	66 c7 40 22 08 00    	movw   $0x8,0x22(%rax)
  804160940a:	c6 40 24 00          	movb   $0x0,0x24(%rax)
  804160940e:	c6 40 25 8e          	movb   $0x8e,0x25(%rax)
  8041609412:	48 89 d1             	mov    %rdx,%rcx
  8041609415:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609419:	66 89 48 26          	mov    %cx,0x26(%rax)
  804160941d:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609421:	89 50 28             	mov    %edx,0x28(%rax)
  8041609424:	c7 40 2c 00 00 00 00 	movl   $0x0,0x2c(%rax)
	SETGATE(idt[T_BRKPT], 0, GD_KT, (uint64_t) &brkpt_thdlr, 3);
  804160942b:	48 ba 76 9f 60 41 80 	movabs $0x8041609f76,%rdx
  8041609432:	00 00 00 
  8041609435:	66 89 50 30          	mov    %dx,0x30(%rax)
  8041609439:	66 c7 40 32 08 00    	movw   $0x8,0x32(%rax)
  804160943f:	c6 40 34 00          	movb   $0x0,0x34(%rax)
  8041609443:	c6 40 35 ee          	movb   $0xee,0x35(%rax)
  8041609447:	48 89 d1             	mov    %rdx,%rcx
  804160944a:	48 c1 e9 10          	shr    $0x10,%rcx
  804160944e:	66 89 48 36          	mov    %cx,0x36(%rax)
  8041609452:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609456:	89 50 38             	mov    %edx,0x38(%rax)
  8041609459:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%rax)
	SETGATE(idt[T_OFLOW], 0, GD_KT, (uint64_t) &oflow_thdlr, 0);
  8041609460:	48 ba 80 9f 60 41 80 	movabs $0x8041609f80,%rdx
  8041609467:	00 00 00 
  804160946a:	66 89 50 40          	mov    %dx,0x40(%rax)
  804160946e:	66 c7 40 42 08 00    	movw   $0x8,0x42(%rax)
  8041609474:	c6 40 44 00          	movb   $0x0,0x44(%rax)
  8041609478:	c6 40 45 8e          	movb   $0x8e,0x45(%rax)
  804160947c:	48 89 d1             	mov    %rdx,%rcx
  804160947f:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609483:	66 89 48 46          	mov    %cx,0x46(%rax)
  8041609487:	48 c1 ea 20          	shr    $0x20,%rdx
  804160948b:	89 50 48             	mov    %edx,0x48(%rax)
  804160948e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%rax)
	SETGATE(idt[T_BOUND], 0, GD_KT, (uint64_t) &bound_thdlr, 0);
  8041609495:	48 ba 8a 9f 60 41 80 	movabs $0x8041609f8a,%rdx
  804160949c:	00 00 00 
  804160949f:	66 89 50 50          	mov    %dx,0x50(%rax)
  80416094a3:	66 c7 40 52 08 00    	movw   $0x8,0x52(%rax)
  80416094a9:	c6 40 54 00          	movb   $0x0,0x54(%rax)
  80416094ad:	c6 40 55 8e          	movb   $0x8e,0x55(%rax)
  80416094b1:	48 89 d1             	mov    %rdx,%rcx
  80416094b4:	48 c1 e9 10          	shr    $0x10,%rcx
  80416094b8:	66 89 48 56          	mov    %cx,0x56(%rax)
  80416094bc:	48 c1 ea 20          	shr    $0x20,%rdx
  80416094c0:	89 50 58             	mov    %edx,0x58(%rax)
  80416094c3:	c7 40 5c 00 00 00 00 	movl   $0x0,0x5c(%rax)
	SETGATE(idt[T_ILLOP], 0, GD_KT, (uint64_t) &illop_thdlr, 0);
  80416094ca:	48 ba 94 9f 60 41 80 	movabs $0x8041609f94,%rdx
  80416094d1:	00 00 00 
  80416094d4:	66 89 50 60          	mov    %dx,0x60(%rax)
  80416094d8:	66 c7 40 62 08 00    	movw   $0x8,0x62(%rax)
  80416094de:	c6 40 64 00          	movb   $0x0,0x64(%rax)
  80416094e2:	c6 40 65 8e          	movb   $0x8e,0x65(%rax)
  80416094e6:	48 89 d1             	mov    %rdx,%rcx
  80416094e9:	48 c1 e9 10          	shr    $0x10,%rcx
  80416094ed:	66 89 48 66          	mov    %cx,0x66(%rax)
  80416094f1:	48 c1 ea 20          	shr    $0x20,%rdx
  80416094f5:	89 50 68             	mov    %edx,0x68(%rax)
  80416094f8:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%rax)
	SETGATE(idt[T_DEVICE], 0, GD_KT, (uint64_t) &device_thdlr, 0);
  80416094ff:	48 ba 9e 9f 60 41 80 	movabs $0x8041609f9e,%rdx
  8041609506:	00 00 00 
  8041609509:	66 89 50 70          	mov    %dx,0x70(%rax)
  804160950d:	66 c7 40 72 08 00    	movw   $0x8,0x72(%rax)
  8041609513:	c6 40 74 00          	movb   $0x0,0x74(%rax)
  8041609517:	c6 40 75 8e          	movb   $0x8e,0x75(%rax)
  804160951b:	48 89 d1             	mov    %rdx,%rcx
  804160951e:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609522:	66 89 48 76          	mov    %cx,0x76(%rax)
  8041609526:	48 c1 ea 20          	shr    $0x20,%rdx
  804160952a:	89 50 78             	mov    %edx,0x78(%rax)
  804160952d:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%rax)
	SETGATE(idt[T_TSS], 0, GD_KT, (uint64_t) &tss_thdlr, 0);
  8041609534:	48 ba b0 9f 60 41 80 	movabs $0x8041609fb0,%rdx
  804160953b:	00 00 00 
  804160953e:	66 89 90 a0 00 00 00 	mov    %dx,0xa0(%rax)
  8041609545:	66 c7 80 a2 00 00 00 	movw   $0x8,0xa2(%rax)
  804160954c:	08 00 
  804160954e:	c6 80 a4 00 00 00 00 	movb   $0x0,0xa4(%rax)
  8041609555:	c6 80 a5 00 00 00 8e 	movb   $0x8e,0xa5(%rax)
  804160955c:	48 89 d1             	mov    %rdx,%rcx
  804160955f:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609563:	66 89 88 a6 00 00 00 	mov    %cx,0xa6(%rax)
  804160956a:	48 c1 ea 20          	shr    $0x20,%rdx
  804160956e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%rax)
  8041609574:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%rax)
  804160957b:	00 00 00 
	SETGATE(idt[T_SEGNP], 0, GD_KT, (uint64_t) &segnp_thdlr, 0);
  804160957e:	48 ba b8 9f 60 41 80 	movabs $0x8041609fb8,%rdx
  8041609585:	00 00 00 
  8041609588:	66 89 90 b0 00 00 00 	mov    %dx,0xb0(%rax)
  804160958f:	66 c7 80 b2 00 00 00 	movw   $0x8,0xb2(%rax)
  8041609596:	08 00 
  8041609598:	c6 80 b4 00 00 00 00 	movb   $0x0,0xb4(%rax)
  804160959f:	c6 80 b5 00 00 00 8e 	movb   $0x8e,0xb5(%rax)
  80416095a6:	48 89 d1             	mov    %rdx,%rcx
  80416095a9:	48 c1 e9 10          	shr    $0x10,%rcx
  80416095ad:	66 89 88 b6 00 00 00 	mov    %cx,0xb6(%rax)
  80416095b4:	48 c1 ea 20          	shr    $0x20,%rdx
  80416095b8:	89 90 b8 00 00 00    	mov    %edx,0xb8(%rax)
  80416095be:	c7 80 bc 00 00 00 00 	movl   $0x0,0xbc(%rax)
  80416095c5:	00 00 00 
	SETGATE(idt[T_STACK], 0, GD_KT, (uint64_t) &stack_thdlr, 0);
  80416095c8:	48 ba c0 9f 60 41 80 	movabs $0x8041609fc0,%rdx
  80416095cf:	00 00 00 
  80416095d2:	66 89 90 c0 00 00 00 	mov    %dx,0xc0(%rax)
  80416095d9:	66 c7 80 c2 00 00 00 	movw   $0x8,0xc2(%rax)
  80416095e0:	08 00 
  80416095e2:	c6 80 c4 00 00 00 00 	movb   $0x0,0xc4(%rax)
  80416095e9:	c6 80 c5 00 00 00 8e 	movb   $0x8e,0xc5(%rax)
  80416095f0:	48 89 d1             	mov    %rdx,%rcx
  80416095f3:	48 c1 e9 10          	shr    $0x10,%rcx
  80416095f7:	66 89 88 c6 00 00 00 	mov    %cx,0xc6(%rax)
  80416095fe:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609602:	89 90 c8 00 00 00    	mov    %edx,0xc8(%rax)
  8041609608:	c7 80 cc 00 00 00 00 	movl   $0x0,0xcc(%rax)
  804160960f:	00 00 00 
	SETGATE(idt[T_GPFLT], 0, GD_KT, (uint64_t) &gpflt_thdlr, 0);
  8041609612:	48 ba c8 9f 60 41 80 	movabs $0x8041609fc8,%rdx
  8041609619:	00 00 00 
  804160961c:	66 89 90 d0 00 00 00 	mov    %dx,0xd0(%rax)
  8041609623:	66 c7 80 d2 00 00 00 	movw   $0x8,0xd2(%rax)
  804160962a:	08 00 
  804160962c:	c6 80 d4 00 00 00 00 	movb   $0x0,0xd4(%rax)
  8041609633:	c6 80 d5 00 00 00 8e 	movb   $0x8e,0xd5(%rax)
  804160963a:	48 89 d1             	mov    %rdx,%rcx
  804160963d:	48 c1 e9 10          	shr    $0x10,%rcx
  8041609641:	66 89 88 d6 00 00 00 	mov    %cx,0xd6(%rax)
  8041609648:	48 c1 ea 20          	shr    $0x20,%rdx
  804160964c:	89 90 d8 00 00 00    	mov    %edx,0xd8(%rax)
  8041609652:	c7 80 dc 00 00 00 00 	movl   $0x0,0xdc(%rax)
  8041609659:	00 00 00 
	SETGATE(idt[T_PGFLT], 0, GD_KT, (uint64_t) &pgflt_thdlr, 0);
  804160965c:	48 ba d0 9f 60 41 80 	movabs $0x8041609fd0,%rdx
  8041609663:	00 00 00 
  8041609666:	66 89 90 e0 00 00 00 	mov    %dx,0xe0(%rax)
  804160966d:	66 c7 80 e2 00 00 00 	movw   $0x8,0xe2(%rax)
  8041609674:	08 00 
  8041609676:	c6 80 e4 00 00 00 00 	movb   $0x0,0xe4(%rax)
  804160967d:	c6 80 e5 00 00 00 8e 	movb   $0x8e,0xe5(%rax)
  8041609684:	48 89 d1             	mov    %rdx,%rcx
  8041609687:	48 c1 e9 10          	shr    $0x10,%rcx
  804160968b:	66 89 88 e6 00 00 00 	mov    %cx,0xe6(%rax)
  8041609692:	48 c1 ea 20          	shr    $0x20,%rdx
  8041609696:	89 90 e8 00 00 00    	mov    %edx,0xe8(%rax)
  804160969c:	c7 80 ec 00 00 00 00 	movl   $0x0,0xec(%rax)
  80416096a3:	00 00 00 
	SETGATE(idt[T_FPERR], 0, GD_KT, (uint64_t) &fperr_thdlr, 0);
  80416096a6:	48 ba d8 9f 60 41 80 	movabs $0x8041609fd8,%rdx
  80416096ad:	00 00 00 
  80416096b0:	66 89 90 00 01 00 00 	mov    %dx,0x100(%rax)
  80416096b7:	66 c7 80 02 01 00 00 	movw   $0x8,0x102(%rax)
  80416096be:	08 00 
  80416096c0:	c6 80 04 01 00 00 00 	movb   $0x0,0x104(%rax)
  80416096c7:	c6 80 05 01 00 00 8e 	movb   $0x8e,0x105(%rax)
  80416096ce:	48 89 d1             	mov    %rdx,%rcx
  80416096d1:	48 c1 e9 10          	shr    $0x10,%rcx
  80416096d5:	66 89 88 06 01 00 00 	mov    %cx,0x106(%rax)
  80416096dc:	48 c1 ea 20          	shr    $0x20,%rdx
  80416096e0:	89 90 08 01 00 00    	mov    %edx,0x108(%rax)
  80416096e6:	c7 80 0c 01 00 00 00 	movl   $0x0,0x10c(%rax)
  80416096ed:	00 00 00 
  SETGATE(idt[T_SYSCALL], 0, GD_KT, (uint64_t) &syscall_thdlr, 3);
  80416096f0:	48 ba fe 9f 60 41 80 	movabs $0x8041609ffe,%rdx
  80416096f7:	00 00 00 
  80416096fa:	66 89 90 00 03 00 00 	mov    %dx,0x300(%rax)
  8041609701:	66 c7 80 02 03 00 00 	movw   $0x8,0x302(%rax)
  8041609708:	08 00 
  804160970a:	c6 80 04 03 00 00 00 	movb   $0x0,0x304(%rax)
  8041609711:	c6 80 05 03 00 00 ee 	movb   $0xee,0x305(%rax)
  8041609718:	48 89 d1             	mov    %rdx,%rcx
  804160971b:	48 c1 e9 10          	shr    $0x10,%rcx
  804160971f:	66 89 88 06 03 00 00 	mov    %cx,0x306(%rax)
  8041609726:	48 c1 ea 20          	shr    $0x20,%rdx
  804160972a:	89 90 08 03 00 00    	mov    %edx,0x308(%rax)
  8041609730:	c7 80 0c 03 00 00 00 	movl   $0x0,0x30c(%rax)
  8041609737:	00 00 00 
  trap_init_percpu();
  804160973a:	48 b8 0c 93 60 41 80 	movabs $0x804160930c,%rax
  8041609741:	00 00 00 
  8041609744:	ff d0                	callq  *%rax
}
  8041609746:	5d                   	pop    %rbp
  8041609747:	c3                   	retq   

0000008041609748 <clock_idt_init>:

void
clock_idt_init(void) {
  extern void (*clock_thdlr)(void);
  // init idt structure
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  8041609748:	48 ba 56 9f 60 41 80 	movabs $0x8041609f56,%rdx
  804160974f:	00 00 00 
  8041609752:	48 b8 40 46 70 41 80 	movabs $0x8041704640,%rax
  8041609759:	00 00 00 
  804160975c:	66 89 90 00 02 00 00 	mov    %dx,0x200(%rax)
  8041609763:	66 c7 80 02 02 00 00 	movw   $0x8,0x202(%rax)
  804160976a:	08 00 
  804160976c:	c6 80 04 02 00 00 00 	movb   $0x0,0x204(%rax)
  8041609773:	c6 80 05 02 00 00 8e 	movb   $0x8e,0x205(%rax)
  804160977a:	48 89 d6             	mov    %rdx,%rsi
  804160977d:	48 c1 ee 10          	shr    $0x10,%rsi
  8041609781:	66 89 b0 06 02 00 00 	mov    %si,0x206(%rax)
  8041609788:	48 89 d1             	mov    %rdx,%rcx
  804160978b:	48 c1 e9 20          	shr    $0x20,%rcx
  804160978f:	89 88 08 02 00 00    	mov    %ecx,0x208(%rax)
  8041609795:	c7 80 0c 02 00 00 00 	movl   $0x0,0x20c(%rax)
  804160979c:	00 00 00 
  SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  804160979f:	66 89 90 80 02 00 00 	mov    %dx,0x280(%rax)
  80416097a6:	66 c7 80 82 02 00 00 	movw   $0x8,0x282(%rax)
  80416097ad:	08 00 
  80416097af:	c6 80 84 02 00 00 00 	movb   $0x0,0x284(%rax)
  80416097b6:	c6 80 85 02 00 00 8e 	movb   $0x8e,0x285(%rax)
  80416097bd:	66 89 b0 86 02 00 00 	mov    %si,0x286(%rax)
  80416097c4:	89 88 88 02 00 00    	mov    %ecx,0x288(%rax)
  80416097ca:	c7 80 8c 02 00 00 00 	movl   $0x0,0x28c(%rax)
  80416097d1:	00 00 00 
  80416097d4:	48 b8 f0 f7 61 41 80 	movabs $0x804161f7f0,%rax
  80416097db:	00 00 00 
  80416097de:	0f 01 18             	lidt   (%rax)
  lidt(&idt_pd);
}
  80416097e1:	c3                   	retq   

00000080416097e2 <print_regs>:
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  }
}

void
print_regs(struct PushRegs *regs) {
  80416097e2:	55                   	push   %rbp
  80416097e3:	48 89 e5             	mov    %rsp,%rbp
  80416097e6:	41 54                	push   %r12
  80416097e8:	53                   	push   %rbx
  80416097e9:	49 89 fc             	mov    %rdi,%r12
  cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  80416097ec:	48 8b 37             	mov    (%rdi),%rsi
  80416097ef:	48 bf 78 dd 60 41 80 	movabs $0x804160dd78,%rdi
  80416097f6:	00 00 00 
  80416097f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416097fe:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  8041609805:	00 00 00 
  8041609808:	ff d3                	callq  *%rbx
  cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  804160980a:	49 8b 74 24 08       	mov    0x8(%r12),%rsi
  804160980f:	48 bf 88 dd 60 41 80 	movabs $0x804160dd88,%rdi
  8041609816:	00 00 00 
  8041609819:	b8 00 00 00 00       	mov    $0x0,%eax
  804160981e:	ff d3                	callq  *%rbx
  cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  8041609820:	49 8b 74 24 10       	mov    0x10(%r12),%rsi
  8041609825:	48 bf 98 dd 60 41 80 	movabs $0x804160dd98,%rdi
  804160982c:	00 00 00 
  804160982f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609834:	ff d3                	callq  *%rbx
  cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  8041609836:	49 8b 74 24 18       	mov    0x18(%r12),%rsi
  804160983b:	48 bf a8 dd 60 41 80 	movabs $0x804160dda8,%rdi
  8041609842:	00 00 00 
  8041609845:	b8 00 00 00 00       	mov    $0x0,%eax
  804160984a:	ff d3                	callq  *%rbx
  cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  804160984c:	49 8b 74 24 20       	mov    0x20(%r12),%rsi
  8041609851:	48 bf b8 dd 60 41 80 	movabs $0x804160ddb8,%rdi
  8041609858:	00 00 00 
  804160985b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609860:	ff d3                	callq  *%rbx
  cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  8041609862:	49 8b 74 24 28       	mov    0x28(%r12),%rsi
  8041609867:	48 bf c8 dd 60 41 80 	movabs $0x804160ddc8,%rdi
  804160986e:	00 00 00 
  8041609871:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609876:	ff d3                	callq  *%rbx
  cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  8041609878:	49 8b 74 24 30       	mov    0x30(%r12),%rsi
  804160987d:	48 bf d8 dd 60 41 80 	movabs $0x804160ddd8,%rdi
  8041609884:	00 00 00 
  8041609887:	b8 00 00 00 00       	mov    $0x0,%eax
  804160988c:	ff d3                	callq  *%rbx
  cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  804160988e:	49 8b 74 24 38       	mov    0x38(%r12),%rsi
  8041609893:	48 bf e8 dd 60 41 80 	movabs $0x804160dde8,%rdi
  804160989a:	00 00 00 
  804160989d:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098a2:	ff d3                	callq  *%rbx
  cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  80416098a4:	49 8b 74 24 48       	mov    0x48(%r12),%rsi
  80416098a9:	48 bf f8 dd 60 41 80 	movabs $0x804160ddf8,%rdi
  80416098b0:	00 00 00 
  80416098b3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098b8:	ff d3                	callq  *%rbx
  cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  80416098ba:	49 8b 74 24 40       	mov    0x40(%r12),%rsi
  80416098bf:	48 bf 08 de 60 41 80 	movabs $0x804160de08,%rdi
  80416098c6:	00 00 00 
  80416098c9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098ce:	ff d3                	callq  *%rbx
  cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  80416098d0:	49 8b 74 24 50       	mov    0x50(%r12),%rsi
  80416098d5:	48 bf 18 de 60 41 80 	movabs $0x804160de18,%rdi
  80416098dc:	00 00 00 
  80416098df:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098e4:	ff d3                	callq  *%rbx
  cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  80416098e6:	49 8b 74 24 68       	mov    0x68(%r12),%rsi
  80416098eb:	48 bf 28 de 60 41 80 	movabs $0x804160de28,%rdi
  80416098f2:	00 00 00 
  80416098f5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416098fa:	ff d3                	callq  *%rbx
  cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  80416098fc:	49 8b 74 24 58       	mov    0x58(%r12),%rsi
  8041609901:	48 bf 38 de 60 41 80 	movabs $0x804160de38,%rdi
  8041609908:	00 00 00 
  804160990b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609910:	ff d3                	callq  *%rbx
  cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  8041609912:	49 8b 74 24 60       	mov    0x60(%r12),%rsi
  8041609917:	48 bf 48 de 60 41 80 	movabs $0x804160de48,%rdi
  804160991e:	00 00 00 
  8041609921:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609926:	ff d3                	callq  *%rbx
  cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
  8041609928:	49 8b 74 24 70       	mov    0x70(%r12),%rsi
  804160992d:	48 bf 58 de 60 41 80 	movabs $0x804160de58,%rdi
  8041609934:	00 00 00 
  8041609937:	b8 00 00 00 00       	mov    $0x0,%eax
  804160993c:	ff d3                	callq  *%rbx
}
  804160993e:	5b                   	pop    %rbx
  804160993f:	41 5c                	pop    %r12
  8041609941:	5d                   	pop    %rbp
  8041609942:	c3                   	retq   

0000008041609943 <print_trapframe>:
print_trapframe(struct Trapframe *tf) {
  8041609943:	55                   	push   %rbp
  8041609944:	48 89 e5             	mov    %rsp,%rbp
  8041609947:	41 54                	push   %r12
  8041609949:	53                   	push   %rbx
  804160994a:	48 89 fb             	mov    %rdi,%rbx
  cprintf("TRAP frame at %p\n", tf);
  804160994d:	48 89 fe             	mov    %rdi,%rsi
  8041609950:	48 bf be df 60 41 80 	movabs $0x804160dfbe,%rdi
  8041609957:	00 00 00 
  804160995a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160995f:	49 bc 78 92 60 41 80 	movabs $0x8041609278,%r12
  8041609966:	00 00 00 
  8041609969:	41 ff d4             	callq  *%r12
  print_regs(&tf->tf_regs);
  804160996c:	48 89 df             	mov    %rbx,%rdi
  804160996f:	48 b8 e2 97 60 41 80 	movabs $0x80416097e2,%rax
  8041609976:	00 00 00 
  8041609979:	ff d0                	callq  *%rax
  cprintf("  es   0x----%04x\n", tf->tf_es);
  804160997b:	0f b7 73 78          	movzwl 0x78(%rbx),%esi
  804160997f:	48 bf bd de 60 41 80 	movabs $0x804160debd,%rdi
  8041609986:	00 00 00 
  8041609989:	b8 00 00 00 00       	mov    $0x0,%eax
  804160998e:	41 ff d4             	callq  *%r12
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  8041609991:	0f b7 b3 80 00 00 00 	movzwl 0x80(%rbx),%esi
  8041609998:	48 bf d0 de 60 41 80 	movabs $0x804160ded0,%rdi
  804160999f:	00 00 00 
  80416099a2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416099a7:	41 ff d4             	callq  *%r12
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  80416099aa:	48 8b b3 88 00 00 00 	mov    0x88(%rbx),%rsi
  if (trapno < sizeof(excnames) / sizeof(excnames[0]))
  80416099b1:	83 fe 13             	cmp    $0x13,%esi
  80416099b4:	0f 86 68 01 00 00    	jbe    8041609b22 <print_trapframe+0x1df>
    return "System call";
  80416099ba:	48 ba 68 de 60 41 80 	movabs $0x804160de68,%rdx
  80416099c1:	00 00 00 
  if (trapno == T_SYSCALL)
  80416099c4:	83 fe 30             	cmp    $0x30,%esi
  80416099c7:	74 1e                	je     80416099e7 <print_trapframe+0xa4>
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  80416099c9:	8d 46 e0             	lea    -0x20(%rsi),%eax
    return "Hardware Interrupt";
  80416099cc:	83 f8 0f             	cmp    $0xf,%eax
  80416099cf:	48 ba 74 de 60 41 80 	movabs $0x804160de74,%rdx
  80416099d6:	00 00 00 
  80416099d9:	48 b8 83 de 60 41 80 	movabs $0x804160de83,%rax
  80416099e0:	00 00 00 
  80416099e3:	48 0f 46 d0          	cmovbe %rax,%rdx
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  80416099e7:	48 bf e3 de 60 41 80 	movabs $0x804160dee3,%rdi
  80416099ee:	00 00 00 
  80416099f1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416099f6:	48 b9 78 92 60 41 80 	movabs $0x8041609278,%rcx
  80416099fd:	00 00 00 
  8041609a00:	ff d1                	callq  *%rcx
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041609a02:	48 b8 40 56 70 41 80 	movabs $0x8041705640,%rax
  8041609a09:	00 00 00 
  8041609a0c:	48 39 18             	cmp    %rbx,(%rax)
  8041609a0f:	0f 84 23 01 00 00    	je     8041609b38 <print_trapframe+0x1f5>
  cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  8041609a15:	48 8b b3 90 00 00 00 	mov    0x90(%rbx),%rsi
  8041609a1c:	48 bf 06 df 60 41 80 	movabs $0x804160df06,%rdi
  8041609a23:	00 00 00 
  8041609a26:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609a2b:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041609a32:	00 00 00 
  8041609a35:	ff d2                	callq  *%rdx
  if (tf->tf_trapno == T_PGFLT)
  8041609a37:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041609a3e:	0e 
  8041609a3f:	0f 85 24 01 00 00    	jne    8041609b69 <print_trapframe+0x226>
            tf->tf_err & 1 ? "protection" : "not-present");
  8041609a45:	48 8b 83 90 00 00 00 	mov    0x90(%rbx),%rax
    cprintf(" [%s, %s, %s]\n",
  8041609a4c:	48 89 c2             	mov    %rax,%rdx
  8041609a4f:	83 e2 01             	and    $0x1,%edx
  8041609a52:	48 b9 96 de 60 41 80 	movabs $0x804160de96,%rcx
  8041609a59:	00 00 00 
  8041609a5c:	48 ba a1 de 60 41 80 	movabs $0x804160dea1,%rdx
  8041609a63:	00 00 00 
  8041609a66:	48 0f 44 ca          	cmove  %rdx,%rcx
  8041609a6a:	48 89 c2             	mov    %rax,%rdx
  8041609a6d:	83 e2 02             	and    $0x2,%edx
  8041609a70:	48 ba ad de 60 41 80 	movabs $0x804160dead,%rdx
  8041609a77:	00 00 00 
  8041609a7a:	48 be b3 de 60 41 80 	movabs $0x804160deb3,%rsi
  8041609a81:	00 00 00 
  8041609a84:	48 0f 44 d6          	cmove  %rsi,%rdx
  8041609a88:	83 e0 04             	and    $0x4,%eax
  8041609a8b:	48 be b8 de 60 41 80 	movabs $0x804160deb8,%rsi
  8041609a92:	00 00 00 
  8041609a95:	48 b8 06 e0 60 41 80 	movabs $0x804160e006,%rax
  8041609a9c:	00 00 00 
  8041609a9f:	48 0f 44 f0          	cmove  %rax,%rsi
  8041609aa3:	48 bf 15 df 60 41 80 	movabs $0x804160df15,%rdi
  8041609aaa:	00 00 00 
  8041609aad:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ab2:	49 b8 78 92 60 41 80 	movabs $0x8041609278,%r8
  8041609ab9:	00 00 00 
  8041609abc:	41 ff d0             	callq  *%r8
  cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  8041609abf:	48 8b b3 98 00 00 00 	mov    0x98(%rbx),%rsi
  8041609ac6:	48 bf 24 df 60 41 80 	movabs $0x804160df24,%rdi
  8041609acd:	00 00 00 
  8041609ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ad5:	49 bc 78 92 60 41 80 	movabs $0x8041609278,%r12
  8041609adc:	00 00 00 
  8041609adf:	41 ff d4             	callq  *%r12
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
  8041609ae2:	0f b7 b3 a0 00 00 00 	movzwl 0xa0(%rbx),%esi
  8041609ae9:	48 bf 34 df 60 41 80 	movabs $0x804160df34,%rdi
  8041609af0:	00 00 00 
  8041609af3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609af8:	41 ff d4             	callq  *%r12
  cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  8041609afb:	48 8b b3 a8 00 00 00 	mov    0xa8(%rbx),%rsi
  8041609b02:	48 bf 47 df 60 41 80 	movabs $0x804160df47,%rdi
  8041609b09:	00 00 00 
  8041609b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b11:	41 ff d4             	callq  *%r12
  if ((tf->tf_cs & 3) != 0) {
  8041609b14:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041609b1b:	75 6c                	jne    8041609b89 <print_trapframe+0x246>
}
  8041609b1d:	5b                   	pop    %rbx
  8041609b1e:	41 5c                	pop    %r12
  8041609b20:	5d                   	pop    %rbp
  8041609b21:	c3                   	retq   
    return excnames[trapno];
  8041609b22:	48 63 c6             	movslq %esi,%rax
  8041609b25:	48 ba 80 e1 60 41 80 	movabs $0x804160e180,%rdx
  8041609b2c:	00 00 00 
  8041609b2f:	48 8b 14 c2          	mov    (%rdx,%rax,8),%rdx
  8041609b33:	e9 af fe ff ff       	jmpq   80416099e7 <print_trapframe+0xa4>
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  8041609b38:	48 83 bb 88 00 00 00 	cmpq   $0xe,0x88(%rbx)
  8041609b3f:	0e 
  8041609b40:	0f 85 cf fe ff ff    	jne    8041609a15 <print_trapframe+0xd2>
  __asm __volatile("movq %%cr2,%0"
  8041609b46:	0f 20 d6             	mov    %cr2,%rsi
    cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  8041609b49:	48 bf f6 de 60 41 80 	movabs $0x804160def6,%rdi
  8041609b50:	00 00 00 
  8041609b53:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b58:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041609b5f:	00 00 00 
  8041609b62:	ff d2                	callq  *%rdx
  8041609b64:	e9 ac fe ff ff       	jmpq   8041609a15 <print_trapframe+0xd2>
    cprintf("\n");
  8041609b69:	48 bf e4 db 60 41 80 	movabs $0x804160dbe4,%rdi
  8041609b70:	00 00 00 
  8041609b73:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b78:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041609b7f:	00 00 00 
  8041609b82:	ff d2                	callq  *%rdx
  8041609b84:	e9 36 ff ff ff       	jmpq   8041609abf <print_trapframe+0x17c>
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
  8041609b89:	48 8b b3 b0 00 00 00 	mov    0xb0(%rbx),%rsi
  8041609b90:	48 bf 57 df 60 41 80 	movabs $0x804160df57,%rdi
  8041609b97:	00 00 00 
  8041609b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609b9f:	41 ff d4             	callq  *%r12
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  8041609ba2:	0f b7 b3 b8 00 00 00 	movzwl 0xb8(%rbx),%esi
  8041609ba9:	48 bf 67 df 60 41 80 	movabs $0x804160df67,%rdi
  8041609bb0:	00 00 00 
  8041609bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609bb8:	41 ff d4             	callq  *%r12
}
  8041609bbb:	e9 5d ff ff ff       	jmpq   8041609b1d <print_trapframe+0x1da>

0000008041609bc0 <page_fault_handler>:
  else
    sched_yield();
}

void
page_fault_handler(struct Trapframe *tf) {
  8041609bc0:	55                   	push   %rbp
  8041609bc1:	48 89 e5             	mov    %rsp,%rbp
  8041609bc4:	41 54                	push   %r12
  8041609bc6:	53                   	push   %rbx
  8041609bc7:	0f 20 d2             	mov    %cr2,%rdx
  fault_va = rcr2();

  // Handle kernel-mode page faults.

  // LAB 8 code
  if (!(tf->tf_cs & 3)) {
  8041609bca:	f6 87 a0 00 00 00 03 	testb  $0x3,0xa0(%rdi)
  8041609bd1:	74 5e                	je     8041609c31 <page_fault_handler+0x71>
  8041609bd3:	48 89 fb             	mov    %rdi,%rbx

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf(".%08x. user fault va %08lx ip %08lx\n",
  8041609bd6:	48 8b 8f 98 00 00 00 	mov    0x98(%rdi),%rcx
  8041609bdd:	49 bc 18 46 70 41 80 	movabs $0x8041704618,%r12
  8041609be4:	00 00 00 
  8041609be7:	49 8b 04 24          	mov    (%r12),%rax
  8041609beb:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041609bf1:	48 bf 50 e1 60 41 80 	movabs $0x804160e150,%rdi
  8041609bf8:	00 00 00 
  8041609bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c00:	49 b8 78 92 60 41 80 	movabs $0x8041609278,%r8
  8041609c07:	00 00 00 
  8041609c0a:	41 ff d0             	callq  *%r8
		curenv->env_id, fault_va, tf->tf_rip);
	print_trapframe(tf);
  8041609c0d:	48 89 df             	mov    %rbx,%rdi
  8041609c10:	48 b8 43 99 60 41 80 	movabs $0x8041609943,%rax
  8041609c17:	00 00 00 
  8041609c1a:	ff d0                	callq  *%rax
	env_destroy(curenv);
  8041609c1c:	49 8b 3c 24          	mov    (%r12),%rdi
  8041609c20:	48 b8 57 8e 60 41 80 	movabs $0x8041608e57,%rax
  8041609c27:	00 00 00 
  8041609c2a:	ff d0                	callq  *%rax
  // LAB 8 code end

}
  8041609c2c:	5b                   	pop    %rbx
  8041609c2d:	41 5c                	pop    %r12
  8041609c2f:	5d                   	pop    %rbp
  8041609c30:	c3                   	retq   
		panic("page fault in kernel!");
  8041609c31:	48 ba 7a df 60 41 80 	movabs $0x804160df7a,%rdx
  8041609c38:	00 00 00 
  8041609c3b:	be 43 01 00 00       	mov    $0x143,%esi
  8041609c40:	48 bf 90 df 60 41 80 	movabs $0x804160df90,%rdi
  8041609c47:	00 00 00 
  8041609c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609c4f:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609c56:	00 00 00 
  8041609c59:	ff d1                	callq  *%rcx

0000008041609c5b <trap>:
trap(struct Trapframe *tf) {
  8041609c5b:	55                   	push   %rbp
  8041609c5c:	48 89 e5             	mov    %rsp,%rbp
  8041609c5f:	53                   	push   %rbx
  8041609c60:	48 83 ec 08          	sub    $0x8,%rsp
  8041609c64:	48 89 fb             	mov    %rdi,%rbx
  asm volatile("cld" ::
  8041609c67:	fc                   	cld    
  if (panicstr)
  8041609c68:	48 b8 80 43 70 41 80 	movabs $0x8041704380,%rax
  8041609c6f:	00 00 00 
  8041609c72:	48 83 38 00          	cmpq   $0x0,(%rax)
  8041609c76:	74 01                	je     8041609c79 <trap+0x1e>
    asm volatile("hlt");
  8041609c78:	f4                   	hlt    
  __asm __volatile("pushfq; popq %0"
  8041609c79:	9c                   	pushfq 
  8041609c7a:	58                   	pop    %rax
  assert(!(read_rflags() & FL_IF));
  8041609c7b:	f6 c4 02             	test   $0x2,%ah
  8041609c7e:	74 35                	je     8041609cb5 <trap+0x5a>
  8041609c80:	48 b9 9c df 60 41 80 	movabs $0x804160df9c,%rcx
  8041609c87:	00 00 00 
  8041609c8a:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041609c91:	00 00 00 
  8041609c94:	be 10 01 00 00       	mov    $0x110,%esi
  8041609c99:	48 bf 90 df 60 41 80 	movabs $0x804160df90,%rdi
  8041609ca0:	00 00 00 
  8041609ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ca8:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609caf:	00 00 00 
  8041609cb2:	41 ff d0             	callq  *%r8
    cprintf("Incoming TRAP frame at %p\n", tf);
  8041609cb5:	48 89 de             	mov    %rbx,%rsi
  8041609cb8:	48 bf b5 df 60 41 80 	movabs $0x804160dfb5,%rdi
  8041609cbf:	00 00 00 
  8041609cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609cc7:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041609cce:	00 00 00 
  8041609cd1:	ff d2                	callq  *%rdx
  assert(curenv);
  8041609cd3:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  8041609cda:	00 00 00 
  8041609cdd:	48 85 c0             	test   %rax,%rax
  8041609ce0:	0f 84 ca 00 00 00    	je     8041609db0 <trap+0x155>
  if (curenv->env_status == ENV_DYING) {
  8041609ce6:	83 b8 d4 00 00 00 01 	cmpl   $0x1,0xd4(%rax)
  8041609ced:	0f 84 ed 00 00 00    	je     8041609de0 <trap+0x185>
  curenv->env_tf = *tf;
  8041609cf3:	b9 30 00 00 00       	mov    $0x30,%ecx
  8041609cf8:	48 89 c7             	mov    %rax,%rdi
  8041609cfb:	48 89 de             	mov    %rbx,%rsi
  8041609cfe:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  tf = &curenv->env_tf;
  8041609d00:	48 b8 18 46 70 41 80 	movabs $0x8041704618,%rax
  8041609d07:	00 00 00 
  8041609d0a:	48 8b 18             	mov    (%rax),%rbx
  last_tf = tf;
  8041609d0d:	48 89 d8             	mov    %rbx,%rax
  8041609d10:	48 a3 40 56 70 41 80 	movabs %rax,0x8041705640
  8041609d17:	00 00 00 
  if (tf->tf_trapno == T_SYSCALL) {
  8041609d1a:	48 8b 83 88 00 00 00 	mov    0x88(%rbx),%rax
  8041609d21:	48 83 f8 30          	cmp    $0x30,%rax
  8041609d25:	0f 84 e1 00 00 00    	je     8041609e0c <trap+0x1b1>
  if (tf->tf_trapno == T_PGFLT) {
  8041609d2b:	48 83 f8 0e          	cmp    $0xe,%rax
  8041609d2f:	0f 84 13 01 00 00    	je     8041609e48 <trap+0x1ed>
  if (tf->tf_trapno == T_BRKPT) {
  8041609d35:	48 83 f8 03          	cmp    $0x3,%rax
  8041609d39:	0f 84 1d 01 00 00    	je     8041609e5c <trap+0x201>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
  8041609d3f:	48 83 f8 27          	cmp    $0x27,%rax
  8041609d43:	0f 84 27 01 00 00    	je     8041609e70 <trap+0x215>
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {
  8041609d49:	48 83 f8 28          	cmp    $0x28,%rax
  8041609d4d:	0f 84 3d 01 00 00    	je     8041609e90 <trap+0x235>
  print_trapframe(tf);
  8041609d53:	48 89 df             	mov    %rbx,%rdi
  8041609d56:	48 b8 43 99 60 41 80 	movabs $0x8041609943,%rax
  8041609d5d:	00 00 00 
  8041609d60:	ff d0                	callq  *%rax
  if (!(tf->tf_cs & 0x3)) {
  8041609d62:	f6 83 a0 00 00 00 03 	testb  $0x3,0xa0(%rbx)
  8041609d69:	0f 84 3a 01 00 00    	je     8041609ea9 <trap+0x24e>
    env_destroy(curenv);
  8041609d6f:	48 b8 18 46 70 41 80 	movabs $0x8041704618,%rax
  8041609d76:	00 00 00 
  8041609d79:	48 8b 38             	mov    (%rax),%rdi
  8041609d7c:	48 b8 57 8e 60 41 80 	movabs $0x8041608e57,%rax
  8041609d83:	00 00 00 
  8041609d86:	ff d0                	callq  *%rax
  if (curenv && curenv->env_status == ENV_RUNNING)
  8041609d88:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  8041609d8f:	00 00 00 
  8041609d92:	48 85 c0             	test   %rax,%rax
  8041609d95:	74 0d                	je     8041609da4 <trap+0x149>
  8041609d97:	83 b8 d4 00 00 00 03 	cmpl   $0x3,0xd4(%rax)
  8041609d9e:	0f 84 2f 01 00 00    	je     8041609ed3 <trap+0x278>
    sched_yield();
  8041609da4:	48 b8 01 ad 60 41 80 	movabs $0x804160ad01,%rax
  8041609dab:	00 00 00 
  8041609dae:	ff d0                	callq  *%rax
  assert(curenv);
  8041609db0:	48 b9 d0 df 60 41 80 	movabs $0x804160dfd0,%rcx
  8041609db7:	00 00 00 
  8041609dba:	48 ba b9 c9 60 41 80 	movabs $0x804160c9b9,%rdx
  8041609dc1:	00 00 00 
  8041609dc4:	be 18 01 00 00       	mov    $0x118,%esi
  8041609dc9:	48 bf 90 df 60 41 80 	movabs $0x804160df90,%rdi
  8041609dd0:	00 00 00 
  8041609dd3:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  8041609dda:	00 00 00 
  8041609ddd:	41 ff d0             	callq  *%r8
    env_free(curenv);
  8041609de0:	48 89 c7             	mov    %rax,%rdi
  8041609de3:	48 b8 4c 8b 60 41 80 	movabs $0x8041608b4c,%rax
  8041609dea:	00 00 00 
  8041609ded:	ff d0                	callq  *%rax
    curenv = NULL;
  8041609def:	48 b8 18 46 70 41 80 	movabs $0x8041704618,%rax
  8041609df6:	00 00 00 
  8041609df9:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    sched_yield();
  8041609e00:	48 b8 01 ad 60 41 80 	movabs $0x804160ad01,%rax
  8041609e07:	00 00 00 
  8041609e0a:	ff d0                	callq  *%rax
    ret                 = syscall(syscallno, a1, a2, a3, a4, a5);
  8041609e0c:	48 8b 4b 68          	mov    0x68(%rbx),%rcx
  8041609e10:	48 8b 53 60          	mov    0x60(%rbx),%rdx
  8041609e14:	48 8b 73 58          	mov    0x58(%rbx),%rsi
  8041609e18:	48 8b 7b 70          	mov    0x70(%rbx),%rdi
  8041609e1c:	4c 8b 4b 40          	mov    0x40(%rbx),%r9
  8041609e20:	4c 8b 43 48          	mov    0x48(%rbx),%r8
  8041609e24:	48 b8 8c ad 60 41 80 	movabs $0x804160ad8c,%rax
  8041609e2b:	00 00 00 
  8041609e2e:	ff d0                	callq  *%rax
    tf->tf_regs.reg_rax = ret;
  8041609e30:	48 89 43 70          	mov    %rax,0x70(%rbx)
    print_trapframe(tf);
  8041609e34:	48 89 df             	mov    %rbx,%rdi
  8041609e37:	48 b8 43 99 60 41 80 	movabs $0x8041609943,%rax
  8041609e3e:	00 00 00 
  8041609e41:	ff d0                	callq  *%rax
    return;
  8041609e43:	e9 40 ff ff ff       	jmpq   8041609d88 <trap+0x12d>
    page_fault_handler(tf);
  8041609e48:	48 89 df             	mov    %rbx,%rdi
  8041609e4b:	48 b8 c0 9b 60 41 80 	movabs $0x8041609bc0,%rax
  8041609e52:	00 00 00 
  8041609e55:	ff d0                	callq  *%rax
    return;
  8041609e57:	e9 2c ff ff ff       	jmpq   8041609d88 <trap+0x12d>
    monitor(tf);
  8041609e5c:	48 89 df             	mov    %rbx,%rdi
  8041609e5f:	48 b8 5e 3f 60 41 80 	movabs $0x8041603f5e,%rax
  8041609e66:	00 00 00 
  8041609e69:	ff d0                	callq  *%rax
    return;
  8041609e6b:	e9 18 ff ff ff       	jmpq   8041609d88 <trap+0x12d>
    cprintf("Spurious interrupt on irq 7\n");
  8041609e70:	48 bf d7 df 60 41 80 	movabs $0x804160dfd7,%rdi
  8041609e77:	00 00 00 
  8041609e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609e7f:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  8041609e86:	00 00 00 
  8041609e89:	ff d2                	callq  *%rdx
    return;
  8041609e8b:	e9 f8 fe ff ff       	jmpq   8041609d88 <trap+0x12d>
    timer_for_schedule->handle_interrupts();
  8041609e90:	48 a1 60 5b 70 41 80 	movabs 0x8041705b60,%rax
  8041609e97:	00 00 00 
  8041609e9a:	ff 50 20             	callq  *0x20(%rax)
    sched_yield();
  8041609e9d:	48 b8 01 ad 60 41 80 	movabs $0x804160ad01,%rax
  8041609ea4:	00 00 00 
  8041609ea7:	ff d0                	callq  *%rax
    panic("unhandled trap in kernel");
  8041609ea9:	48 ba f4 df 60 41 80 	movabs $0x804160dff4,%rdx
  8041609eb0:	00 00 00 
  8041609eb3:	be fb 00 00 00       	mov    $0xfb,%esi
  8041609eb8:	48 bf 90 df 60 41 80 	movabs $0x804160df90,%rdi
  8041609ebf:	00 00 00 
  8041609ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041609ec7:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  8041609ece:	00 00 00 
  8041609ed1:	ff d1                	callq  *%rcx
    env_run(curenv);
  8041609ed3:	48 89 c7             	mov    %rax,%rdi
  8041609ed6:	48 b8 1d 8f 60 41 80 	movabs $0x8041608f1d,%rax
  8041609edd:	00 00 00 
  8041609ee0:	ff d0                	callq  *%rax

0000008041609ee2 <_alltraps>:

.globl _alltraps
.type _alltraps, @function;
.align 2
_alltraps:
  subq $8,%rsp
  8041609ee2:	48 83 ec 08          	sub    $0x8,%rsp
  movw %ds,(%rsp)
  8041609ee6:	8c 1c 24             	mov    %ds,(%rsp)
  subq $8,%rsp
  8041609ee9:	48 83 ec 08          	sub    $0x8,%rsp
  movw %es,(%rsp)
  8041609eed:	8c 04 24             	mov    %es,(%rsp)
  PUSHA
  8041609ef0:	48 83 ec 78          	sub    $0x78,%rsp
  8041609ef4:	48 89 44 24 70       	mov    %rax,0x70(%rsp)
  8041609ef9:	48 89 5c 24 68       	mov    %rbx,0x68(%rsp)
  8041609efe:	48 89 4c 24 60       	mov    %rcx,0x60(%rsp)
  8041609f03:	48 89 54 24 58       	mov    %rdx,0x58(%rsp)
  8041609f08:	48 89 6c 24 50       	mov    %rbp,0x50(%rsp)
  8041609f0d:	48 89 7c 24 48       	mov    %rdi,0x48(%rsp)
  8041609f12:	48 89 74 24 40       	mov    %rsi,0x40(%rsp)
  8041609f17:	4c 89 44 24 38       	mov    %r8,0x38(%rsp)
  8041609f1c:	4c 89 4c 24 30       	mov    %r9,0x30(%rsp)
  8041609f21:	4c 89 54 24 28       	mov    %r10,0x28(%rsp)
  8041609f26:	4c 89 5c 24 20       	mov    %r11,0x20(%rsp)
  8041609f2b:	4c 89 64 24 18       	mov    %r12,0x18(%rsp)
  8041609f30:	4c 89 6c 24 10       	mov    %r13,0x10(%rsp)
  8041609f35:	4c 89 74 24 08       	mov    %r14,0x8(%rsp)
  8041609f3a:	4c 89 3c 24          	mov    %r15,(%rsp)
  movq $GD_KD,%rax
  8041609f3e:	48 c7 c0 10 00 00 00 	mov    $0x10,%rax
  movq %rax,%ds
  8041609f45:	48 8e d8             	mov    %rax,%ds
  movq %rax,%es
  8041609f48:	48 8e c0             	mov    %rax,%es
  movq %rsp,%rdi
  8041609f4b:	48 89 e7             	mov    %rsp,%rdi
  call trap
  8041609f4e:	e8 08 fd ff ff       	callq  8041609c5b <trap>
  jmp .
  8041609f53:	eb fe                	jmp    8041609f53 <_alltraps+0x71>
  8041609f55:	90                   	nop

0000008041609f56 <clock_thdlr>:
  xorl %ebp, %ebp
  movq %rsp,%rdi
  call trap
  jmp .
#else
TRAPHANDLER_NOEC(clock_thdlr, IRQ_OFFSET + IRQ_CLOCK)
  8041609f56:	6a 00                	pushq  $0x0
  8041609f58:	6a 28                	pushq  $0x28
  8041609f5a:	eb 86                	jmp    8041609ee2 <_alltraps>

0000008041609f5c <divide_thdlr>:
// LAB 8 code
TRAPHANDLER_NOEC(divide_thdlr, T_DIVIDE)
  8041609f5c:	6a 00                	pushq  $0x0
  8041609f5e:	6a 00                	pushq  $0x0
  8041609f60:	eb 80                	jmp    8041609ee2 <_alltraps>

0000008041609f62 <debug_thdlr>:
TRAPHANDLER_NOEC(debug_thdlr, T_DEBUG)
  8041609f62:	6a 00                	pushq  $0x0
  8041609f64:	6a 01                	pushq  $0x1
  8041609f66:	e9 77 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609f6b:	90                   	nop

0000008041609f6c <nmi_thdlr>:
TRAPHANDLER_NOEC(nmi_thdlr, T_NMI)
  8041609f6c:	6a 00                	pushq  $0x0
  8041609f6e:	6a 02                	pushq  $0x2
  8041609f70:	e9 6d ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609f75:	90                   	nop

0000008041609f76 <brkpt_thdlr>:
TRAPHANDLER_NOEC(brkpt_thdlr, T_BRKPT)
  8041609f76:	6a 00                	pushq  $0x0
  8041609f78:	6a 03                	pushq  $0x3
  8041609f7a:	e9 63 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609f7f:	90                   	nop

0000008041609f80 <oflow_thdlr>:
TRAPHANDLER_NOEC(oflow_thdlr, T_OFLOW)
  8041609f80:	6a 00                	pushq  $0x0
  8041609f82:	6a 04                	pushq  $0x4
  8041609f84:	e9 59 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609f89:	90                   	nop

0000008041609f8a <bound_thdlr>:
TRAPHANDLER_NOEC(bound_thdlr, T_BOUND)
  8041609f8a:	6a 00                	pushq  $0x0
  8041609f8c:	6a 05                	pushq  $0x5
  8041609f8e:	e9 4f ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609f93:	90                   	nop

0000008041609f94 <illop_thdlr>:
TRAPHANDLER_NOEC(illop_thdlr, T_ILLOP)
  8041609f94:	6a 00                	pushq  $0x0
  8041609f96:	6a 06                	pushq  $0x6
  8041609f98:	e9 45 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609f9d:	90                   	nop

0000008041609f9e <device_thdlr>:
TRAPHANDLER_NOEC(device_thdlr, T_DEVICE)
  8041609f9e:	6a 00                	pushq  $0x0
  8041609fa0:	6a 07                	pushq  $0x7
  8041609fa2:	e9 3b ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fa7:	90                   	nop

0000008041609fa8 <dblflt_thdlr>:
TRAPHANDLER(dblflt_thdlr, T_DBLFLT)
  8041609fa8:	6a 08                	pushq  $0x8
  8041609faa:	e9 33 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609faf:	90                   	nop

0000008041609fb0 <tss_thdlr>:
TRAPHANDLER(tss_thdlr, T_TSS)
  8041609fb0:	6a 0a                	pushq  $0xa
  8041609fb2:	e9 2b ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fb7:	90                   	nop

0000008041609fb8 <segnp_thdlr>:
TRAPHANDLER(segnp_thdlr, T_SEGNP)
  8041609fb8:	6a 0b                	pushq  $0xb
  8041609fba:	e9 23 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fbf:	90                   	nop

0000008041609fc0 <stack_thdlr>:
TRAPHANDLER(stack_thdlr, T_STACK)
  8041609fc0:	6a 0c                	pushq  $0xc
  8041609fc2:	e9 1b ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fc7:	90                   	nop

0000008041609fc8 <gpflt_thdlr>:
TRAPHANDLER(gpflt_thdlr, T_GPFLT)
  8041609fc8:	6a 0d                	pushq  $0xd
  8041609fca:	e9 13 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fcf:	90                   	nop

0000008041609fd0 <pgflt_thdlr>:
TRAPHANDLER(pgflt_thdlr, T_PGFLT)
  8041609fd0:	6a 0e                	pushq  $0xe
  8041609fd2:	e9 0b ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fd7:	90                   	nop

0000008041609fd8 <fperr_thdlr>:
TRAPHANDLER_NOEC(fperr_thdlr, T_FPERR)
  8041609fd8:	6a 00                	pushq  $0x0
  8041609fda:	6a 10                	pushq  $0x10
  8041609fdc:	e9 01 ff ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fe1:	90                   	nop

0000008041609fe2 <align_thdlr>:
TRAPHANDLER(align_thdlr, T_ALIGN)
  8041609fe2:	6a 11                	pushq  $0x11
  8041609fe4:	e9 f9 fe ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609fe9:	90                   	nop

0000008041609fea <mchk_thdlr>:
TRAPHANDLER_NOEC(mchk_thdlr, T_MCHK)
  8041609fea:	6a 00                	pushq  $0x0
  8041609fec:	6a 12                	pushq  $0x12
  8041609fee:	e9 ef fe ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609ff3:	90                   	nop

0000008041609ff4 <simderr_thdlr>:
TRAPHANDLER_NOEC(simderr_thdlr, T_SIMDERR)
  8041609ff4:	6a 00                	pushq  $0x0
  8041609ff6:	6a 13                	pushq  $0x13
  8041609ff8:	e9 e5 fe ff ff       	jmpq   8041609ee2 <_alltraps>
  8041609ffd:	90                   	nop

0000008041609ffe <syscall_thdlr>:
TRAPHANDLER_NOEC(syscall_thdlr, T_SYSCALL)
  8041609ffe:	6a 00                	pushq  $0x0
  804160a000:	6a 30                	pushq  $0x30
  804160a002:	e9 db fe ff ff       	jmpq   8041609ee2 <_alltraps>

000000804160a007 <acpi_find_table>:
  return krsdp;
}

// LAB 5 code
static void *
acpi_find_table(const char *sign) {
  804160a007:	55                   	push   %rbp
  804160a008:	48 89 e5             	mov    %rsp,%rbp
  804160a00b:	41 57                	push   %r15
  804160a00d:	41 56                	push   %r14
  804160a00f:	41 55                	push   %r13
  804160a011:	41 54                	push   %r12
  804160a013:	53                   	push   %rbx
  804160a014:	48 83 ec 28          	sub    $0x28,%rsp
  804160a018:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  static size_t krsdt_len;
  static size_t krsdt_entsz;

  uint8_t cksm = 0;

  if (!krsdt) {
  804160a01c:	48 b8 e0 56 70 41 80 	movabs $0x80417056e0,%rax
  804160a023:	00 00 00 
  804160a026:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a02a:	74 3d                	je     804160a069 <acpi_find_table+0x62>
    }
  }

  ACPISDTHeader *hd = NULL;

  for (size_t i = 0; i < krsdt_len; i++) {
  804160a02c:	48 b8 d0 56 70 41 80 	movabs $0x80417056d0,%rax
  804160a033:	00 00 00 
  804160a036:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a03a:	0f 84 f2 03 00 00    	je     804160a432 <acpi_find_table+0x42b>
  804160a040:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    /* Assume little endian */
    uint64_t fadt_pa = 0;
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  804160a046:	49 bf d8 56 70 41 80 	movabs $0x80417056d8,%r15
  804160a04d:	00 00 00 
  804160a050:	49 bd e0 56 70 41 80 	movabs $0x80417056e0,%r13
  804160a057:	00 00 00 
  804160a05a:	49 be fb be 60 41 80 	movabs $0x804160befb,%r14
  804160a061:	00 00 00 
  804160a064:	e9 04 03 00 00       	jmpq   804160a36d <acpi_find_table+0x366>
    if (!uefi_lp->ACPIRoot) {
  804160a069:	48 a1 00 f0 61 41 80 	movabs 0x804161f000,%rax
  804160a070:	00 00 00 
  804160a073:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160a077:	48 85 ff             	test   %rdi,%rdi
  804160a07a:	74 7c                	je     804160a0f8 <acpi_find_table+0xf1>
    RSDP *krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  804160a07c:	be 24 00 00 00       	mov    $0x24,%esi
  804160a081:	48 b8 10 83 60 41 80 	movabs $0x8041608310,%rax
  804160a088:	00 00 00 
  804160a08b:	ff d0                	callq  *%rax
  804160a08d:	49 89 c4             	mov    %rax,%r12
    if (strncmp(krsdp->Signature, "RSD PTR", 8))
  804160a090:	ba 08 00 00 00       	mov    $0x8,%edx
  804160a095:	48 be 3b e2 60 41 80 	movabs $0x804160e23b,%rsi
  804160a09c:	00 00 00 
  804160a09f:	48 89 c7             	mov    %rax,%rdi
  804160a0a2:	48 b8 b8 bd 60 41 80 	movabs $0x804160bdb8,%rax
  804160a0a9:	00 00 00 
  804160a0ac:	ff d0                	callq  *%rax
  804160a0ae:	85 c0                	test   %eax,%eax
  804160a0b0:	74 70                	je     804160a122 <acpi_find_table+0x11b>
  804160a0b2:	4c 89 e0             	mov    %r12,%rax
  804160a0b5:	49 8d 54 24 14       	lea    0x14(%r12),%rdx
  uint8_t cksm = 0;
  804160a0ba:	bb 00 00 00 00       	mov    $0x0,%ebx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160a0bf:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < offsetof(RSDP, Length); i++)
  804160a0c1:	48 83 c0 01          	add    $0x1,%rax
  804160a0c5:	48 39 d0             	cmp    %rdx,%rax
  804160a0c8:	75 f5                	jne    804160a0bf <acpi_find_table+0xb8>
    if (cksm)
  804160a0ca:	84 db                	test   %bl,%bl
  804160a0cc:	74 59                	je     804160a127 <acpi_find_table+0x120>
      panic("Invalid RSDP");
  804160a0ce:	48 ba 43 e2 60 41 80 	movabs $0x804160e243,%rdx
  804160a0d5:	00 00 00 
  804160a0d8:	be 7f 00 00 00       	mov    $0x7f,%esi
  804160a0dd:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a0e4:	00 00 00 
  804160a0e7:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a0ec:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a0f3:	00 00 00 
  804160a0f6:	ff d1                	callq  *%rcx
      panic("No rsdp\n");
  804160a0f8:	48 ba 25 e2 60 41 80 	movabs $0x804160e225,%rdx
  804160a0ff:	00 00 00 
  804160a102:	be 75 00 00 00       	mov    $0x75,%esi
  804160a107:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a10e:	00 00 00 
  804160a111:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a116:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a11d:	00 00 00 
  804160a120:	ff d1                	callq  *%rcx
  uint8_t cksm = 0;
  804160a122:	bb 00 00 00 00       	mov    $0x0,%ebx
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  804160a127:	45 8b 74 24 10       	mov    0x10(%r12),%r14d
    krsdt_entsz      = 4;
  804160a12c:	48 b8 d8 56 70 41 80 	movabs $0x80417056d8,%rax
  804160a133:	00 00 00 
  804160a136:	48 c7 00 04 00 00 00 	movq   $0x4,(%rax)
    if (krsdp->Revision) {
  804160a13d:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a143:	0f 84 1b 01 00 00    	je     804160a264 <acpi_find_table+0x25d>
      for (size_t i = 0; i < krsdp->Length; i++)
  804160a149:	41 8b 54 24 14       	mov    0x14(%r12),%edx
  804160a14e:	48 85 d2             	test   %rdx,%rdx
  804160a151:	74 11                	je     804160a164 <acpi_find_table+0x15d>
  804160a153:	4c 89 e0             	mov    %r12,%rax
  804160a156:	4c 01 e2             	add    %r12,%rdx
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
  804160a159:	02 18                	add    (%rax),%bl
      for (size_t i = 0; i < krsdp->Length; i++)
  804160a15b:	48 83 c0 01          	add    $0x1,%rax
  804160a15f:	48 39 c2             	cmp    %rax,%rdx
  804160a162:	75 f5                	jne    804160a159 <acpi_find_table+0x152>
      if (cksm)
  804160a164:	84 db                	test   %bl,%bl
  804160a166:	0f 85 4c 01 00 00    	jne    804160a2b8 <acpi_find_table+0x2b1>
      rsdt_pa     = krsdp->XsdtAddress;
  804160a16c:	4d 8b 74 24 18       	mov    0x18(%r12),%r14
      krsdt_entsz = 8;
  804160a171:	48 b8 d8 56 70 41 80 	movabs $0x80417056d8,%rax
  804160a178:	00 00 00 
  804160a17b:	48 c7 00 08 00 00 00 	movq   $0x8,(%rax)
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  804160a182:	be 24 00 00 00       	mov    $0x24,%esi
  804160a187:	4c 89 f7             	mov    %r14,%rdi
  804160a18a:	48 b8 10 83 60 41 80 	movabs $0x8041608310,%rax
  804160a191:	00 00 00 
  804160a194:	ff d0                	callq  *%rax
  804160a196:	49 bd e0 56 70 41 80 	movabs $0x80417056e0,%r13
  804160a19d:	00 00 00 
  804160a1a0:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  804160a1a4:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a1a7:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a1ac:	48 89 c6             	mov    %rax,%rsi
  804160a1af:	4c 89 f7             	mov    %r14,%rdi
  804160a1b2:	48 b8 c6 83 60 41 80 	movabs $0x80416083c6,%rax
  804160a1b9:	00 00 00 
  804160a1bc:	ff d0                	callq  *%rax
  804160a1be:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a1c2:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a1c5:	48 85 c9             	test   %rcx,%rcx
  804160a1c8:	74 19                	je     804160a1e3 <acpi_find_table+0x1dc>
  804160a1ca:	48 89 c2             	mov    %rax,%rdx
  804160a1cd:	48 01 c1             	add    %rax,%rcx
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdt)[i]);
  804160a1d0:	02 1a                	add    (%rdx),%bl
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a1d2:	48 83 c2 01          	add    $0x1,%rdx
  804160a1d6:	48 39 d1             	cmp    %rdx,%rcx
  804160a1d9:	75 f5                	jne    804160a1d0 <acpi_find_table+0x1c9>
    if (cksm)
  804160a1db:	84 db                	test   %bl,%bl
  804160a1dd:	0f 85 ff 00 00 00    	jne    804160a2e2 <acpi_find_table+0x2db>
    if (strncmp(krsdt->h.Signature, krsdp->Revision ? "XSDT" : "RSDT", 4))
  804160a1e3:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a1e9:	48 be 20 e2 60 41 80 	movabs $0x804160e220,%rsi
  804160a1f0:	00 00 00 
  804160a1f3:	48 ba 58 e2 60 41 80 	movabs $0x804160e258,%rdx
  804160a1fa:	00 00 00 
  804160a1fd:	48 0f 44 f2          	cmove  %rdx,%rsi
  804160a201:	ba 04 00 00 00       	mov    $0x4,%edx
  804160a206:	48 89 c7             	mov    %rax,%rdi
  804160a209:	48 b8 b8 bd 60 41 80 	movabs $0x804160bdb8,%rax
  804160a210:	00 00 00 
  804160a213:	ff d0                	callq  *%rax
  804160a215:	85 c0                	test   %eax,%eax
  804160a217:	0f 85 ef 00 00 00    	jne    804160a30c <acpi_find_table+0x305>
    krsdt_len = (krsdt->h.Length - sizeof(RSDT)) / 4;
  804160a21d:	48 a1 e0 56 70 41 80 	movabs 0x80417056e0,%rax
  804160a224:	00 00 00 
  804160a227:	8b 40 04             	mov    0x4(%rax),%eax
  804160a22a:	48 8d 58 dc          	lea    -0x24(%rax),%rbx
  804160a22e:	48 89 da             	mov    %rbx,%rdx
  804160a231:	48 c1 ea 02          	shr    $0x2,%rdx
  804160a235:	48 89 d0             	mov    %rdx,%rax
  804160a238:	48 a3 d0 56 70 41 80 	movabs %rax,0x80417056d0
  804160a23f:	00 00 00 
    if (krsdp->Revision) {
  804160a242:	41 80 7c 24 0f 00    	cmpb   $0x0,0xf(%r12)
  804160a248:	0f 84 de fd ff ff    	je     804160a02c <acpi_find_table+0x25>
      krsdt_len = krsdt_len / 2;
  804160a24e:	48 89 d8             	mov    %rbx,%rax
  804160a251:	48 c1 e8 03          	shr    $0x3,%rax
  804160a255:	48 a3 d0 56 70 41 80 	movabs %rax,0x80417056d0
  804160a25c:	00 00 00 
  804160a25f:	e9 c8 fd ff ff       	jmpq   804160a02c <acpi_find_table+0x25>
    uint64_t rsdt_pa = krsdp->RsdtAddress;
  804160a264:	45 89 f6             	mov    %r14d,%r14d
    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
  804160a267:	be 24 00 00 00       	mov    $0x24,%esi
  804160a26c:	4c 89 f7             	mov    %r14,%rdi
  804160a26f:	48 b8 10 83 60 41 80 	movabs $0x8041608310,%rax
  804160a276:	00 00 00 
  804160a279:	ff d0                	callq  *%rax
  804160a27b:	49 bd e0 56 70 41 80 	movabs $0x80417056e0,%r13
  804160a282:	00 00 00 
  804160a285:	49 89 45 00          	mov    %rax,0x0(%r13)
    krsdt = mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);
  804160a289:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a28c:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a291:	48 89 c6             	mov    %rax,%rsi
  804160a294:	4c 89 f7             	mov    %r14,%rdi
  804160a297:	48 b8 c6 83 60 41 80 	movabs $0x80416083c6,%rax
  804160a29e:	00 00 00 
  804160a2a1:	ff d0                	callq  *%rax
  804160a2a3:	49 89 45 00          	mov    %rax,0x0(%r13)
    for (size_t i = 0; i < krsdt->h.Length; i++)
  804160a2a7:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a2aa:	48 85 c9             	test   %rcx,%rcx
  804160a2ad:	0f 85 17 ff ff ff    	jne    804160a1ca <acpi_find_table+0x1c3>
  804160a2b3:	e9 23 ff ff ff       	jmpq   804160a1db <acpi_find_table+0x1d4>
        panic("Invalid RSDP");
  804160a2b8:	48 ba 43 e2 60 41 80 	movabs $0x804160e243,%rdx
  804160a2bf:	00 00 00 
  804160a2c2:	be 89 00 00 00       	mov    $0x89,%esi
  804160a2c7:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a2ce:	00 00 00 
  804160a2d1:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a2d6:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a2dd:	00 00 00 
  804160a2e0:	ff d1                	callq  *%rcx
      panic("Invalid RSDP");
  804160a2e2:	48 ba 43 e2 60 41 80 	movabs $0x804160e243,%rdx
  804160a2e9:	00 00 00 
  804160a2ec:	be 97 00 00 00       	mov    $0x97,%esi
  804160a2f1:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a2f8:	00 00 00 
  804160a2fb:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a300:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a307:	00 00 00 
  804160a30a:	ff d1                	callq  *%rcx
      panic("Invalid RSDT");
  804160a30c:	48 ba 50 e2 60 41 80 	movabs $0x804160e250,%rdx
  804160a313:	00 00 00 
  804160a316:	be 9a 00 00 00       	mov    $0x9a,%esi
  804160a31b:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a322:	00 00 00 
  804160a325:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a32a:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a331:	00 00 00 
  804160a334:	ff d1                	callq  *%rcx

    for (size_t i = 0; i < hd->Length; i++)
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
    if (cksm)
      panic("ACPI table '%.4s' invalid", hd->Signature);
    if (!strncmp(hd->Signature, sign, 4))
  804160a336:	ba 04 00 00 00       	mov    $0x4,%edx
  804160a33b:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  804160a33f:	48 89 df             	mov    %rbx,%rdi
  804160a342:	48 b8 b8 bd 60 41 80 	movabs $0x804160bdb8,%rax
  804160a349:	00 00 00 
  804160a34c:	ff d0                	callq  *%rax
  804160a34e:	85 c0                	test   %eax,%eax
  804160a350:	0f 84 ca 00 00 00    	je     804160a420 <acpi_find_table+0x419>
  for (size_t i = 0; i < krsdt_len; i++) {
  804160a356:	49 83 c4 01          	add    $0x1,%r12
  804160a35a:	48 b8 d0 56 70 41 80 	movabs $0x80417056d0,%rax
  804160a361:	00 00 00 
  804160a364:	4c 39 20             	cmp    %r12,(%rax)
  804160a367:	0f 86 ae 00 00 00    	jbe    804160a41b <acpi_find_table+0x414>
    uint64_t fadt_pa = 0;
  804160a36d:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  804160a374:	00 
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz, krsdt_entsz);
  804160a375:	49 8b 17             	mov    (%r15),%rdx
  804160a378:	49 8b 4d 00          	mov    0x0(%r13),%rcx
  804160a37c:	48 89 d0             	mov    %rdx,%rax
  804160a37f:	49 0f af c4          	imul   %r12,%rax
  804160a383:	48 8d 74 01 24       	lea    0x24(%rcx,%rax,1),%rsi
  804160a388:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160a38c:	41 ff d6             	callq  *%r14
    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
  804160a38f:	be 24 00 00 00       	mov    $0x24,%esi
  804160a394:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160a398:	48 b8 10 83 60 41 80 	movabs $0x8041608310,%rax
  804160a39f:	00 00 00 
  804160a3a2:	ff d0                	callq  *%rax
    hd = mmio_remap_last_region(fadt_pa, hd, sizeof(ACPISDTHeader), krsdt->h.Length);
  804160a3a4:	49 8b 55 00          	mov    0x0(%r13),%rdx
  804160a3a8:	8b 4a 04             	mov    0x4(%rdx),%ecx
  804160a3ab:	ba 24 00 00 00       	mov    $0x24,%edx
  804160a3b0:	48 89 c6             	mov    %rax,%rsi
  804160a3b3:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  804160a3b7:	48 b8 c6 83 60 41 80 	movabs $0x80416083c6,%rax
  804160a3be:	00 00 00 
  804160a3c1:	ff d0                	callq  *%rax
  804160a3c3:	48 89 c3             	mov    %rax,%rbx
    for (size_t i = 0; i < hd->Length; i++)
  804160a3c6:	8b 48 04             	mov    0x4(%rax),%ecx
  804160a3c9:	48 85 c9             	test   %rcx,%rcx
  804160a3cc:	0f 84 64 ff ff ff    	je     804160a336 <acpi_find_table+0x32f>
  804160a3d2:	48 01 c1             	add    %rax,%rcx
  804160a3d5:	ba 00 00 00 00       	mov    $0x0,%edx
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
  804160a3da:	02 10                	add    (%rax),%dl
    for (size_t i = 0; i < hd->Length; i++)
  804160a3dc:	48 83 c0 01          	add    $0x1,%rax
  804160a3e0:	48 39 c1             	cmp    %rax,%rcx
  804160a3e3:	75 f5                	jne    804160a3da <acpi_find_table+0x3d3>
    if (cksm)
  804160a3e5:	84 d2                	test   %dl,%dl
  804160a3e7:	0f 84 49 ff ff ff    	je     804160a336 <acpi_find_table+0x32f>
      panic("ACPI table '%.4s' invalid", hd->Signature);
  804160a3ed:	48 89 d9             	mov    %rbx,%rcx
  804160a3f0:	48 ba 5d e2 60 41 80 	movabs $0x804160e25d,%rdx
  804160a3f7:	00 00 00 
  804160a3fa:	be b0 00 00 00       	mov    $0xb0,%esi
  804160a3ff:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a406:	00 00 00 
  804160a409:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a40e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160a415:	00 00 00 
  804160a418:	41 ff d0             	callq  *%r8
      return hd;
  }

  return NULL;
  804160a41b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  804160a420:	48 89 d8             	mov    %rbx,%rax
  804160a423:	48 83 c4 28          	add    $0x28,%rsp
  804160a427:	5b                   	pop    %rbx
  804160a428:	41 5c                	pop    %r12
  804160a42a:	41 5d                	pop    %r13
  804160a42c:	41 5e                	pop    %r14
  804160a42e:	41 5f                	pop    %r15
  804160a430:	5d                   	pop    %rbp
  804160a431:	c3                   	retq   
  return NULL;
  804160a432:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160a437:	eb e7                	jmp    804160a420 <acpi_find_table+0x419>

000000804160a439 <hpet_handle_interrupts_tim0>:
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  // LAB 5 code end
}

void
hpet_handle_interrupts_tim0(void) {
  804160a439:	55                   	push   %rbp
  804160a43a:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_TIMER);
  804160a43d:	bf 00 00 00 00       	mov    $0x0,%edi
  804160a442:	48 b8 05 92 60 41 80 	movabs $0x8041609205,%rax
  804160a449:	00 00 00 
  804160a44c:	ff d0                	callq  *%rax
}
  804160a44e:	5d                   	pop    %rbp
  804160a44f:	c3                   	retq   

000000804160a450 <hpet_handle_interrupts_tim1>:

void
hpet_handle_interrupts_tim1(void) {
  804160a450:	55                   	push   %rbp
  804160a451:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_CLOCK);
  804160a454:	bf 08 00 00 00       	mov    $0x8,%edi
  804160a459:	48 b8 05 92 60 41 80 	movabs $0x8041609205,%rax
  804160a460:	00 00 00 
  804160a463:	ff d0                	callq  *%rax
}
  804160a465:	5d                   	pop    %rbp
  804160a466:	c3                   	retq   

000000804160a467 <hpet_cpu_frequency>:
// about pause instruction.
uint64_t
hpet_cpu_frequency(void) {
  // LAB 5 code
  uint64_t time_res = 100;
  uint64_t delta = 0, target = hpetFreq / time_res;
  804160a467:	48 a1 f8 56 70 41 80 	movabs 0x80417056f8,%rax
  804160a46e:	00 00 00 
  804160a471:	48 c1 e8 02          	shr    $0x2,%rax
  804160a475:	48 ba c3 f5 28 5c 8f 	movabs $0x28f5c28f5c28f5c3,%rdx
  804160a47c:	c2 f5 28 
  804160a47f:	48 f7 e2             	mul    %rdx
  804160a482:	48 89 d1             	mov    %rdx,%rcx
  804160a485:	48 c1 e9 02          	shr    $0x2,%rcx
  return hpetReg->MAIN_CNT;
  804160a489:	48 a1 08 57 70 41 80 	movabs 0x8041705708,%rax
  804160a490:	00 00 00 
  804160a493:	48 8b b8 f0 00 00 00 	mov    0xf0(%rax),%rdi
  __asm __volatile("rdtsc"
  804160a49a:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a49c:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a4a0:	41 89 c0             	mov    %eax,%r8d
  804160a4a3:	49 09 d0             	or     %rdx,%r8
  804160a4a6:	48 be 08 57 70 41 80 	movabs $0x8041705708,%rsi
  804160a4ad:	00 00 00 

  uint64_t tick0 = hpet_get_main_cnt();
  uint64_t tsc0 = read_tsc();
  do {
    asm("pause");
  804160a4b0:	f3 90                	pause  
  return hpetReg->MAIN_CNT;
  804160a4b2:	48 8b 06             	mov    (%rsi),%rax
  804160a4b5:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
    delta = hpet_get_main_cnt() - tick0;
  804160a4bc:	48 29 f8             	sub    %rdi,%rax
  } while (delta < target);
  804160a4bf:	48 39 c1             	cmp    %rax,%rcx
  804160a4c2:	77 ec                	ja     804160a4b0 <hpet_cpu_frequency+0x49>
  __asm __volatile("rdtsc"
  804160a4c4:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160a4c6:	48 c1 e2 20          	shl    $0x20,%rdx
  804160a4ca:	89 c0                	mov    %eax,%eax
  804160a4cc:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * time_res; 
  804160a4cf:	48 89 d0             	mov    %rdx,%rax
  804160a4d2:	4c 29 c0             	sub    %r8,%rax
  804160a4d5:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160a4d9:	48 8d 04 80          	lea    (%rax,%rax,4),%rax
  804160a4dd:	48 c1 e0 02          	shl    $0x2,%rax
  // LAB 5 code end
  // return 0;
}
  804160a4e1:	c3                   	retq   

000000804160a4e2 <hpet_enable_interrupts_tim1>:
hpet_enable_interrupts_tim1(void) {
  804160a4e2:	55                   	push   %rbp
  804160a4e3:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  804160a4e6:	48 b8 08 57 70 41 80 	movabs $0x8041705708,%rax
  804160a4ed:	00 00 00 
  804160a4f0:	48 8b 08             	mov    (%rax),%rcx
  804160a4f3:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160a4f7:	48 83 c8 02          	or     $0x2,%rax
  804160a4fb:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM1_CONF = (IRQ_CLOCK << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  804160a4ff:	48 c7 81 20 01 00 00 	movq   $0x104c,0x120(%rcx)
  804160a506:	4c 10 00 00 
  return hpetReg->MAIN_CNT;
  804160a50a:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM1_COMP = hpet_get_main_cnt() + 3 * Peta / 2 / hpetFemto;
  804160a511:	48 bf 00 57 70 41 80 	movabs $0x8041705700,%rdi
  804160a518:	00 00 00 
  804160a51b:	48 b8 00 c0 29 f7 3d 	movabs $0x5543df729c000,%rax
  804160a522:	54 05 00 
  804160a525:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a52a:	48 f7 37             	divq   (%rdi)
  804160a52d:	48 01 c6             	add    %rax,%rsi
  804160a530:	48 89 b1 28 01 00 00 	mov    %rsi,0x128(%rcx)
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  804160a537:	48 89 81 28 01 00 00 	mov    %rax,0x128(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  804160a53e:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  804160a545:	00 00 00 
  804160a548:	89 c7                	mov    %eax,%edi
  804160a54a:	81 e7 ff fe 00 00    	and    $0xfeff,%edi
  804160a550:	48 b8 a0 90 60 41 80 	movabs $0x80416090a0,%rax
  804160a557:	00 00 00 
  804160a55a:	ff d0                	callq  *%rax
}
  804160a55c:	5d                   	pop    %rbp
  804160a55d:	c3                   	retq   

000000804160a55e <hpet_enable_interrupts_tim0>:
hpet_enable_interrupts_tim0(void) {
  804160a55e:	55                   	push   %rbp
  804160a55f:	48 89 e5             	mov    %rsp,%rbp
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  804160a562:	48 b8 08 57 70 41 80 	movabs $0x8041705708,%rax
  804160a569:	00 00 00 
  804160a56c:	48 8b 08             	mov    (%rax),%rcx
  804160a56f:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160a573:	48 83 c8 02          	or     $0x2,%rax
  804160a577:	48 89 41 10          	mov    %rax,0x10(%rcx)
  hpetReg->TIM0_CONF = (IRQ_TIMER << 9) | HPET_TN_TYPE_CNF | HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  804160a57b:	48 c7 81 00 01 00 00 	movq   $0x4c,0x100(%rcx)
  804160a582:	4c 00 00 00 
  return hpetReg->MAIN_CNT;
  804160a586:	48 8b b1 f0 00 00 00 	mov    0xf0(%rcx),%rsi
  hpetReg->TIM0_COMP = hpet_get_main_cnt() + Peta / 2 / hpetFemto;
  804160a58d:	48 bf 00 57 70 41 80 	movabs $0x8041705700,%rdi
  804160a594:	00 00 00 
  804160a597:	48 b8 00 40 63 52 bf 	movabs $0x1c6bf52634000,%rax
  804160a59e:	c6 01 00 
  804160a5a1:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a5a6:	48 f7 37             	divq   (%rdi)
  804160a5a9:	48 01 c6             	add    %rax,%rsi
  804160a5ac:	48 89 b1 08 01 00 00 	mov    %rsi,0x108(%rcx)
  hpetReg->TIM0_COMP = Peta / 2 / hpetFemto;
  804160a5b3:	48 89 81 08 01 00 00 	mov    %rax,0x108(%rcx)
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_TIMER));
  804160a5ba:	66 a1 e8 f7 61 41 80 	movabs 0x804161f7e8,%ax
  804160a5c1:	00 00 00 
  804160a5c4:	89 c7                	mov    %eax,%edi
  804160a5c6:	81 e7 fe ff 00 00    	and    $0xfffe,%edi
  804160a5cc:	48 b8 a0 90 60 41 80 	movabs $0x80416090a0,%rax
  804160a5d3:	00 00 00 
  804160a5d6:	ff d0                	callq  *%rax
}
  804160a5d8:	5d                   	pop    %rbp
  804160a5d9:	c3                   	retq   

000000804160a5da <check_sum>:
  switch (type) {
  804160a5da:	85 f6                	test   %esi,%esi
  804160a5dc:	74 0f                	je     804160a5ed <check_sum+0x13>
  uint32_t len = 0;
  804160a5de:	ba 00 00 00 00       	mov    $0x0,%edx
  switch (type) {
  804160a5e3:	83 fe 01             	cmp    $0x1,%esi
  804160a5e6:	75 08                	jne    804160a5f0 <check_sum+0x16>
      len = ((ACPISDTHeader *)Table)->Length;
  804160a5e8:	8b 57 04             	mov    0x4(%rdi),%edx
      break;
  804160a5eb:	eb 03                	jmp    804160a5f0 <check_sum+0x16>
      len = ((RSDP *)Table)->Length;
  804160a5ed:	8b 57 14             	mov    0x14(%rdi),%edx
  for (int i = 0; i < len; i++)
  804160a5f0:	85 d2                	test   %edx,%edx
  804160a5f2:	74 24                	je     804160a618 <check_sum+0x3e>
  804160a5f4:	48 89 f8             	mov    %rdi,%rax
  804160a5f7:	8d 52 ff             	lea    -0x1(%rdx),%edx
  804160a5fa:	48 8d 74 17 01       	lea    0x1(%rdi,%rdx,1),%rsi
  int sum      = 0;
  804160a5ff:	ba 00 00 00 00       	mov    $0x0,%edx
    sum += ((uint8_t *)Table)[i];
  804160a604:	0f b6 08             	movzbl (%rax),%ecx
  804160a607:	01 ca                	add    %ecx,%edx
  for (int i = 0; i < len; i++)
  804160a609:	48 83 c0 01          	add    $0x1,%rax
  804160a60d:	48 39 f0             	cmp    %rsi,%rax
  804160a610:	75 f2                	jne    804160a604 <check_sum+0x2a>
  if (sum % 0x100 == 0)
  804160a612:	84 d2                	test   %dl,%dl
  804160a614:	0f 94 c0             	sete   %al
}
  804160a617:	c3                   	retq   
  int sum      = 0;
  804160a618:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a61d:	eb f3                	jmp    804160a612 <check_sum+0x38>

000000804160a61f <get_rsdp>:
  if (krsdp != NULL)
  804160a61f:	48 a1 f0 56 70 41 80 	movabs 0x80417056f0,%rax
  804160a626:	00 00 00 
  804160a629:	48 85 c0             	test   %rax,%rax
  804160a62c:	74 01                	je     804160a62f <get_rsdp+0x10>
}
  804160a62e:	c3                   	retq   
get_rsdp(void) {
  804160a62f:	55                   	push   %rbp
  804160a630:	48 89 e5             	mov    %rsp,%rbp
  if (uefi_lp->ACPIRoot == 0)
  804160a633:	48 a1 00 f0 61 41 80 	movabs 0x804161f000,%rax
  804160a63a:	00 00 00 
  804160a63d:	48 8b 78 10          	mov    0x10(%rax),%rdi
  804160a641:	48 85 ff             	test   %rdi,%rdi
  804160a644:	74 1d                	je     804160a663 <get_rsdp+0x44>
  krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  804160a646:	be 24 00 00 00       	mov    $0x24,%esi
  804160a64b:	48 b8 10 83 60 41 80 	movabs $0x8041608310,%rax
  804160a652:	00 00 00 
  804160a655:	ff d0                	callq  *%rax
  804160a657:	48 a3 f0 56 70 41 80 	movabs %rax,0x80417056f0
  804160a65e:	00 00 00 
}
  804160a661:	5d                   	pop    %rbp
  804160a662:	c3                   	retq   
    panic("No rsdp\n");
  804160a663:	48 ba 25 e2 60 41 80 	movabs $0x804160e225,%rdx
  804160a66a:	00 00 00 
  804160a66d:	be 65 00 00 00       	mov    $0x65,%esi
  804160a672:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a679:	00 00 00 
  804160a67c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a681:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a688:	00 00 00 
  804160a68b:	ff d1                	callq  *%rcx

000000804160a68d <get_fadt>:
  if (!kfadt) {
  804160a68d:	48 b8 e8 56 70 41 80 	movabs $0x80417056e8,%rax
  804160a694:	00 00 00 
  804160a697:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a69b:	74 0b                	je     804160a6a8 <get_fadt+0x1b>
}
  804160a69d:	48 a1 e8 56 70 41 80 	movabs 0x80417056e8,%rax
  804160a6a4:	00 00 00 
  804160a6a7:	c3                   	retq   
get_fadt(void) {
  804160a6a8:	55                   	push   %rbp
  804160a6a9:	48 89 e5             	mov    %rsp,%rbp
    kfadt = acpi_find_table("FACP");
  804160a6ac:	48 bf 77 e2 60 41 80 	movabs $0x804160e277,%rdi
  804160a6b3:	00 00 00 
  804160a6b6:	48 b8 07 a0 60 41 80 	movabs $0x804160a007,%rax
  804160a6bd:	00 00 00 
  804160a6c0:	ff d0                	callq  *%rax
  804160a6c2:	48 a3 e8 56 70 41 80 	movabs %rax,0x80417056e8
  804160a6c9:	00 00 00 
}
  804160a6cc:	48 a1 e8 56 70 41 80 	movabs 0x80417056e8,%rax
  804160a6d3:	00 00 00 
  804160a6d6:	5d                   	pop    %rbp
  804160a6d7:	c3                   	retq   

000000804160a6d8 <acpi_enable>:
acpi_enable(void) {
  804160a6d8:	55                   	push   %rbp
  804160a6d9:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  804160a6dc:	48 b8 8d a6 60 41 80 	movabs $0x804160a68d,%rax
  804160a6e3:	00 00 00 
  804160a6e6:	ff d0                	callq  *%rax
  804160a6e8:	48 89 c1             	mov    %rax,%rcx
  __asm __volatile("outb %0,%w1"
  804160a6eb:	0f b6 40 34          	movzbl 0x34(%rax),%eax
  804160a6ef:	8b 51 30             	mov    0x30(%rcx),%edx
  804160a6f2:	ee                   	out    %al,(%dx)
  while ((inw(fadt->PM1aControlBlock) & 1) == 0) {
  804160a6f3:	8b 51 40             	mov    0x40(%rcx),%edx
  __asm __volatile("inw %w1,%0"
  804160a6f6:	66 ed                	in     (%dx),%ax
  804160a6f8:	a8 01                	test   $0x1,%al
  804160a6fa:	74 fa                	je     804160a6f6 <acpi_enable+0x1e>
}
  804160a6fc:	5d                   	pop    %rbp
  804160a6fd:	c3                   	retq   

000000804160a6fe <get_hpet>:
  if (!khpet) {
  804160a6fe:	48 b8 c8 56 70 41 80 	movabs $0x80417056c8,%rax
  804160a705:	00 00 00 
  804160a708:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a70c:	74 0b                	je     804160a719 <get_hpet+0x1b>
}
  804160a70e:	48 a1 c8 56 70 41 80 	movabs 0x80417056c8,%rax
  804160a715:	00 00 00 
  804160a718:	c3                   	retq   
get_hpet(void) {
  804160a719:	55                   	push   %rbp
  804160a71a:	48 89 e5             	mov    %rsp,%rbp
    khpet = acpi_find_table("HPET");
  804160a71d:	48 bf 7c e2 60 41 80 	movabs $0x804160e27c,%rdi
  804160a724:	00 00 00 
  804160a727:	48 b8 07 a0 60 41 80 	movabs $0x804160a007,%rax
  804160a72e:	00 00 00 
  804160a731:	ff d0                	callq  *%rax
  804160a733:	48 a3 c8 56 70 41 80 	movabs %rax,0x80417056c8
  804160a73a:	00 00 00 
}
  804160a73d:	48 a1 c8 56 70 41 80 	movabs 0x80417056c8,%rax
  804160a744:	00 00 00 
  804160a747:	5d                   	pop    %rbp
  804160a748:	c3                   	retq   

000000804160a749 <hpet_register>:
hpet_register(void) {
  804160a749:	55                   	push   %rbp
  804160a74a:	48 89 e5             	mov    %rsp,%rbp
  HPET *hpet_timer = get_hpet();
  804160a74d:	48 b8 fe a6 60 41 80 	movabs $0x804160a6fe,%rax
  804160a754:	00 00 00 
  804160a757:	ff d0                	callq  *%rax
  if (hpet_timer->address.address == 0)
  804160a759:	48 8b 78 2c          	mov    0x2c(%rax),%rdi
  804160a75d:	48 85 ff             	test   %rdi,%rdi
  804160a760:	74 13                	je     804160a775 <hpet_register+0x2c>
  return mmio_map_region(paddr, sizeof(HPETRegister));
  804160a762:	be 00 04 00 00       	mov    $0x400,%esi
  804160a767:	48 b8 10 83 60 41 80 	movabs $0x8041608310,%rax
  804160a76e:	00 00 00 
  804160a771:	ff d0                	callq  *%rax
}
  804160a773:	5d                   	pop    %rbp
  804160a774:	c3                   	retq   
    panic("hpet is unavailable\n");
  804160a775:	48 ba 81 e2 60 41 80 	movabs $0x804160e281,%rdx
  804160a77c:	00 00 00 
  804160a77f:	be de 00 00 00       	mov    $0xde,%esi
  804160a784:	48 bf 2e e2 60 41 80 	movabs $0x804160e22e,%rdi
  804160a78b:	00 00 00 
  804160a78e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a793:	48 b9 5a 02 60 41 80 	movabs $0x804160025a,%rcx
  804160a79a:	00 00 00 
  804160a79d:	ff d1                	callq  *%rcx

000000804160a79f <hpet_init>:
  if (hpetReg == NULL) {
  804160a79f:	48 b8 08 57 70 41 80 	movabs $0x8041705708,%rax
  804160a7a6:	00 00 00 
  804160a7a9:	48 83 38 00          	cmpq   $0x0,(%rax)
  804160a7ad:	74 01                	je     804160a7b0 <hpet_init+0x11>
  804160a7af:	c3                   	retq   
hpet_init() {
  804160a7b0:	55                   	push   %rbp
  804160a7b1:	48 89 e5             	mov    %rsp,%rbp
  804160a7b4:	53                   	push   %rbx
  804160a7b5:	48 83 ec 08          	sub    $0x8,%rsp
  __asm __volatile("inb %w1,%0"
  804160a7b9:	bb 70 00 00 00       	mov    $0x70,%ebx
  804160a7be:	89 da                	mov    %ebx,%edx
  804160a7c0:	ec                   	in     (%dx),%al
  outb(0x70, inb(0x70) | NMI_LOCK);
  804160a7c1:	83 c8 80             	or     $0xffffff80,%eax
  __asm __volatile("outb %0,%w1"
  804160a7c4:	ee                   	out    %al,(%dx)
    hpetReg   = hpet_register();
  804160a7c5:	48 b8 49 a7 60 41 80 	movabs $0x804160a749,%rax
  804160a7cc:	00 00 00 
  804160a7cf:	ff d0                	callq  *%rax
  804160a7d1:	48 89 c6             	mov    %rax,%rsi
  804160a7d4:	48 a3 08 57 70 41 80 	movabs %rax,0x8041705708
  804160a7db:	00 00 00 
    hpetFemto = (uintptr_t)(hpetReg->GCAP_ID >> 32);
  804160a7de:	48 8b 08             	mov    (%rax),%rcx
  804160a7e1:	48 c1 e9 20          	shr    $0x20,%rcx
  804160a7e5:	48 89 c8             	mov    %rcx,%rax
  804160a7e8:	48 a3 00 57 70 41 80 	movabs %rax,0x8041705700
  804160a7ef:	00 00 00 
    hpetFreq = (1 * Peta) / hpetFemto;
  804160a7f2:	48 b8 00 80 c6 a4 7e 	movabs $0x38d7ea4c68000,%rax
  804160a7f9:	8d 03 00 
  804160a7fc:	ba 00 00 00 00       	mov    $0x0,%edx
  804160a801:	48 f7 f1             	div    %rcx
  804160a804:	48 a3 f8 56 70 41 80 	movabs %rax,0x80417056f8
  804160a80b:	00 00 00 
    hpetReg->GEN_CONF |= 1;
  804160a80e:	48 8b 46 10          	mov    0x10(%rsi),%rax
  804160a812:	48 83 c8 01          	or     $0x1,%rax
  804160a816:	48 89 46 10          	mov    %rax,0x10(%rsi)
  __asm __volatile("inb %w1,%0"
  804160a81a:	89 da                	mov    %ebx,%edx
  804160a81c:	ec                   	in     (%dx),%al
  __asm __volatile("outb %0,%w1"
  804160a81d:	83 e0 7f             	and    $0x7f,%eax
  804160a820:	ee                   	out    %al,(%dx)
}
  804160a821:	48 83 c4 08          	add    $0x8,%rsp
  804160a825:	5b                   	pop    %rbx
  804160a826:	5d                   	pop    %rbp
  804160a827:	c3                   	retq   

000000804160a828 <hpet_print_struct>:
hpet_print_struct(void) {
  804160a828:	55                   	push   %rbp
  804160a829:	48 89 e5             	mov    %rsp,%rbp
  804160a82c:	41 54                	push   %r12
  804160a82e:	53                   	push   %rbx
  HPET *hpet = get_hpet();
  804160a82f:	48 b8 fe a6 60 41 80 	movabs $0x804160a6fe,%rax
  804160a836:	00 00 00 
  804160a839:	ff d0                	callq  *%rax
  804160a83b:	49 89 c4             	mov    %rax,%r12
  cprintf("signature = %s\n", (hpet->h).Signature);
  804160a83e:	48 89 c6             	mov    %rax,%rsi
  804160a841:	48 bf 96 e2 60 41 80 	movabs $0x804160e296,%rdi
  804160a848:	00 00 00 
  804160a84b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a850:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  804160a857:	00 00 00 
  804160a85a:	ff d3                	callq  *%rbx
  cprintf("length = %08x\n", (hpet->h).Length);
  804160a85c:	41 8b 74 24 04       	mov    0x4(%r12),%esi
  804160a861:	48 bf a6 e2 60 41 80 	movabs $0x804160e2a6,%rdi
  804160a868:	00 00 00 
  804160a86b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a870:	ff d3                	callq  *%rbx
  cprintf("revision = %08x\n", (hpet->h).Revision);
  804160a872:	41 0f b6 74 24 08    	movzbl 0x8(%r12),%esi
  804160a878:	48 bf ca e2 60 41 80 	movabs $0x804160e2ca,%rdi
  804160a87f:	00 00 00 
  804160a882:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a887:	ff d3                	callq  *%rbx
  cprintf("checksum = %08x\n", (hpet->h).Checksum);
  804160a889:	41 0f b6 74 24 09    	movzbl 0x9(%r12),%esi
  804160a88f:	48 bf b5 e2 60 41 80 	movabs $0x804160e2b5,%rdi
  804160a896:	00 00 00 
  804160a899:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a89e:	ff d3                	callq  *%rbx
  cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  804160a8a0:	41 8b 74 24 18       	mov    0x18(%r12),%esi
  804160a8a5:	48 bf c6 e2 60 41 80 	movabs $0x804160e2c6,%rdi
  804160a8ac:	00 00 00 
  804160a8af:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8b4:	ff d3                	callq  *%rbx
  cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  804160a8b6:	41 8b 74 24 1c       	mov    0x1c(%r12),%esi
  804160a8bb:	48 bf db e2 60 41 80 	movabs $0x804160e2db,%rdi
  804160a8c2:	00 00 00 
  804160a8c5:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8ca:	ff d3                	callq  *%rbx
  cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);
  804160a8cc:	41 8b 74 24 20       	mov    0x20(%r12),%esi
  804160a8d1:	48 bf ee e2 60 41 80 	movabs $0x804160e2ee,%rdi
  804160a8d8:	00 00 00 
  804160a8db:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8e0:	ff d3                	callq  *%rbx
  cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  804160a8e2:	41 0f b6 74 24 24    	movzbl 0x24(%r12),%esi
  804160a8e8:	48 bf 07 e3 60 41 80 	movabs $0x804160e307,%rdi
  804160a8ef:	00 00 00 
  804160a8f2:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a8f7:	ff d3                	callq  *%rbx
  cprintf("comparator_count = %08x\n", hpet->comparator_count);
  804160a8f9:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a8ff:	83 e6 1f             	and    $0x1f,%esi
  804160a902:	48 bf 1f e3 60 41 80 	movabs $0x804160e31f,%rdi
  804160a909:	00 00 00 
  804160a90c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a911:	ff d3                	callq  *%rbx
  cprintf("counter_size = %08x\n", hpet->counter_size);
  804160a913:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a919:	40 c0 ee 05          	shr    $0x5,%sil
  804160a91d:	83 e6 01             	and    $0x1,%esi
  804160a920:	48 bf 38 e3 60 41 80 	movabs $0x804160e338,%rdi
  804160a927:	00 00 00 
  804160a92a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a92f:	ff d3                	callq  *%rbx
  cprintf("reserved = %08x\n", hpet->reserved);
  804160a931:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a937:	40 c0 ee 06          	shr    $0x6,%sil
  804160a93b:	83 e6 01             	and    $0x1,%esi
  804160a93e:	48 bf 4d e3 60 41 80 	movabs $0x804160e34d,%rdi
  804160a945:	00 00 00 
  804160a948:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a94d:	ff d3                	callq  *%rbx
  cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  804160a94f:	41 0f b6 74 24 25    	movzbl 0x25(%r12),%esi
  804160a955:	40 c0 ee 07          	shr    $0x7,%sil
  804160a959:	40 0f b6 f6          	movzbl %sil,%esi
  804160a95d:	48 bf 5e e3 60 41 80 	movabs $0x804160e35e,%rdi
  804160a964:	00 00 00 
  804160a967:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a96c:	ff d3                	callq  *%rbx
  cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  804160a96e:	41 0f b7 74 24 26    	movzwl 0x26(%r12),%esi
  804160a974:	48 bf 79 e3 60 41 80 	movabs $0x804160e379,%rdi
  804160a97b:	00 00 00 
  804160a97e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a983:	ff d3                	callq  *%rbx
  cprintf("hpet_number = %08x\n", hpet->hpet_number);
  804160a985:	41 0f b6 74 24 34    	movzbl 0x34(%r12),%esi
  804160a98b:	48 bf 8f e3 60 41 80 	movabs $0x804160e38f,%rdi
  804160a992:	00 00 00 
  804160a995:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a99a:	ff d3                	callq  *%rbx
  cprintf("minimum_tick = %08x\n", hpet->minimum_tick);
  804160a99c:	41 0f b7 74 24 35    	movzwl 0x35(%r12),%esi
  804160a9a2:	48 bf a3 e3 60 41 80 	movabs $0x804160e3a3,%rdi
  804160a9a9:	00 00 00 
  804160a9ac:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9b1:	ff d3                	callq  *%rbx
  cprintf("address_structure:\n");
  804160a9b3:	48 bf b8 e3 60 41 80 	movabs $0x804160e3b8,%rdi
  804160a9ba:	00 00 00 
  804160a9bd:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9c2:	ff d3                	callq  *%rbx
  cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  804160a9c4:	41 0f b6 74 24 28    	movzbl 0x28(%r12),%esi
  804160a9ca:	48 bf cc e3 60 41 80 	movabs $0x804160e3cc,%rdi
  804160a9d1:	00 00 00 
  804160a9d4:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9d9:	ff d3                	callq  *%rbx
  cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  804160a9db:	41 0f b6 74 24 29    	movzbl 0x29(%r12),%esi
  804160a9e1:	48 bf e5 e3 60 41 80 	movabs $0x804160e3e5,%rdi
  804160a9e8:	00 00 00 
  804160a9eb:	b8 00 00 00 00       	mov    $0x0,%eax
  804160a9f0:	ff d3                	callq  *%rbx
  cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  804160a9f2:	41 0f b6 74 24 2a    	movzbl 0x2a(%r12),%esi
  804160a9f8:	48 bf 00 e4 60 41 80 	movabs $0x804160e400,%rdi
  804160a9ff:	00 00 00 
  804160aa02:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa07:	ff d3                	callq  *%rbx
  cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
  804160aa09:	49 8b 74 24 2c       	mov    0x2c(%r12),%rsi
  804160aa0e:	48 bf 1c e4 60 41 80 	movabs $0x804160e41c,%rdi
  804160aa15:	00 00 00 
  804160aa18:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa1d:	ff d3                	callq  *%rbx
}
  804160aa1f:	5b                   	pop    %rbx
  804160aa20:	41 5c                	pop    %r12
  804160aa22:	5d                   	pop    %rbp
  804160aa23:	c3                   	retq   

000000804160aa24 <hpet_print_reg>:
hpet_print_reg(void) {
  804160aa24:	55                   	push   %rbp
  804160aa25:	48 89 e5             	mov    %rsp,%rbp
  804160aa28:	41 54                	push   %r12
  804160aa2a:	53                   	push   %rbx
  cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  804160aa2b:	49 bc 08 57 70 41 80 	movabs $0x8041705708,%r12
  804160aa32:	00 00 00 
  804160aa35:	49 8b 04 24          	mov    (%r12),%rax
  804160aa39:	48 8b 30             	mov    (%rax),%rsi
  804160aa3c:	48 bf 2d e4 60 41 80 	movabs $0x804160e42d,%rdi
  804160aa43:	00 00 00 
  804160aa46:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa4b:	48 bb 78 92 60 41 80 	movabs $0x8041609278,%rbx
  804160aa52:	00 00 00 
  804160aa55:	ff d3                	callq  *%rbx
  cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  804160aa57:	49 8b 04 24          	mov    (%r12),%rax
  804160aa5b:	48 8b 70 10          	mov    0x10(%rax),%rsi
  804160aa5f:	48 bf 3f e4 60 41 80 	movabs $0x804160e43f,%rdi
  804160aa66:	00 00 00 
  804160aa69:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa6e:	ff d3                	callq  *%rbx
  cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  804160aa70:	49 8b 04 24          	mov    (%r12),%rax
  804160aa74:	48 8b 70 20          	mov    0x20(%rax),%rsi
  804160aa78:	48 bf 52 e4 60 41 80 	movabs $0x804160e452,%rdi
  804160aa7f:	00 00 00 
  804160aa82:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aa87:	ff d3                	callq  *%rbx
  cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  804160aa89:	49 8b 04 24          	mov    (%r12),%rax
  804160aa8d:	48 8b b0 f0 00 00 00 	mov    0xf0(%rax),%rsi
  804160aa94:	48 bf 66 e4 60 41 80 	movabs $0x804160e466,%rdi
  804160aa9b:	00 00 00 
  804160aa9e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aaa3:	ff d3                	callq  *%rbx
  cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  804160aaa5:	49 8b 04 24          	mov    (%r12),%rax
  804160aaa9:	48 8b b0 00 01 00 00 	mov    0x100(%rax),%rsi
  804160aab0:	48 bf 79 e4 60 41 80 	movabs $0x804160e479,%rdi
  804160aab7:	00 00 00 
  804160aaba:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aabf:	ff d3                	callq  *%rbx
  cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  804160aac1:	49 8b 04 24          	mov    (%r12),%rax
  804160aac5:	48 8b b0 08 01 00 00 	mov    0x108(%rax),%rsi
  804160aacc:	48 bf 8d e4 60 41 80 	movabs $0x804160e48d,%rdi
  804160aad3:	00 00 00 
  804160aad6:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aadb:	ff d3                	callq  *%rbx
  cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  804160aadd:	49 8b 04 24          	mov    (%r12),%rax
  804160aae1:	48 8b b0 10 01 00 00 	mov    0x110(%rax),%rsi
  804160aae8:	48 bf a1 e4 60 41 80 	movabs $0x804160e4a1,%rdi
  804160aaef:	00 00 00 
  804160aaf2:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aaf7:	ff d3                	callq  *%rbx
  cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  804160aaf9:	49 8b 04 24          	mov    (%r12),%rax
  804160aafd:	48 8b b0 20 01 00 00 	mov    0x120(%rax),%rsi
  804160ab04:	48 bf b4 e4 60 41 80 	movabs $0x804160e4b4,%rdi
  804160ab0b:	00 00 00 
  804160ab0e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab13:	ff d3                	callq  *%rbx
  cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  804160ab15:	49 8b 04 24          	mov    (%r12),%rax
  804160ab19:	48 8b b0 28 01 00 00 	mov    0x128(%rax),%rsi
  804160ab20:	48 bf c8 e4 60 41 80 	movabs $0x804160e4c8,%rdi
  804160ab27:	00 00 00 
  804160ab2a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab2f:	ff d3                	callq  *%rbx
  cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  804160ab31:	49 8b 04 24          	mov    (%r12),%rax
  804160ab35:	48 8b b0 30 01 00 00 	mov    0x130(%rax),%rsi
  804160ab3c:	48 bf dc e4 60 41 80 	movabs $0x804160e4dc,%rdi
  804160ab43:	00 00 00 
  804160ab46:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab4b:	ff d3                	callq  *%rbx
  cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  804160ab4d:	49 8b 04 24          	mov    (%r12),%rax
  804160ab51:	48 8b b0 40 01 00 00 	mov    0x140(%rax),%rsi
  804160ab58:	48 bf ef e4 60 41 80 	movabs $0x804160e4ef,%rdi
  804160ab5f:	00 00 00 
  804160ab62:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab67:	ff d3                	callq  *%rbx
  cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  804160ab69:	49 8b 04 24          	mov    (%r12),%rax
  804160ab6d:	48 8b b0 48 01 00 00 	mov    0x148(%rax),%rsi
  804160ab74:	48 bf 03 e5 60 41 80 	movabs $0x804160e503,%rdi
  804160ab7b:	00 00 00 
  804160ab7e:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab83:	ff d3                	callq  *%rbx
  cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
  804160ab85:	49 8b 04 24          	mov    (%r12),%rax
  804160ab89:	48 8b b0 50 01 00 00 	mov    0x150(%rax),%rsi
  804160ab90:	48 bf 17 e5 60 41 80 	movabs $0x804160e517,%rdi
  804160ab97:	00 00 00 
  804160ab9a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ab9f:	ff d3                	callq  *%rbx
}
  804160aba1:	5b                   	pop    %rbx
  804160aba2:	41 5c                	pop    %r12
  804160aba4:	5d                   	pop    %rbp
  804160aba5:	c3                   	retq   

000000804160aba6 <hpet_get_main_cnt>:
  return hpetReg->MAIN_CNT;
  804160aba6:	48 a1 08 57 70 41 80 	movabs 0x8041705708,%rax
  804160abad:	00 00 00 
  804160abb0:	48 8b 80 f0 00 00 00 	mov    0xf0(%rax),%rax
}
  804160abb7:	c3                   	retq   

000000804160abb8 <pmtimer_get_timeval>:

uint32_t
pmtimer_get_timeval(void) {
  804160abb8:	55                   	push   %rbp
  804160abb9:	48 89 e5             	mov    %rsp,%rbp
  FADT *fadt = get_fadt();
  804160abbc:	48 b8 8d a6 60 41 80 	movabs $0x804160a68d,%rax
  804160abc3:	00 00 00 
  804160abc6:	ff d0                	callq  *%rax
  __asm __volatile("inl %w1,%0"
  804160abc8:	8b 50 4c             	mov    0x4c(%rax),%edx
  804160abcb:	ed                   	in     (%dx),%eax
  return inl(fadt->PMTimerBlock);
}
  804160abcc:	5d                   	pop    %rbp
  804160abcd:	c3                   	retq   

000000804160abce <pmtimer_cpu_frequency>:
// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
// Hint: use pmtimer_get_timeval function and do not forget that ACPI PM timer
// can be 24-bit or 32-bit.
uint64_t
pmtimer_cpu_frequency(void) {
  804160abce:	55                   	push   %rbp
  804160abcf:	48 89 e5             	mov    %rsp,%rbp
  804160abd2:	41 55                	push   %r13
  804160abd4:	41 54                	push   %r12
  804160abd6:	53                   	push   %rbx
  804160abd7:	48 83 ec 08          	sub    $0x8,%rsp
  // LAB 5 code
  uint32_t time_res = 100;
  uint32_t tick0 = pmtimer_get_timeval();
  804160abdb:	48 b8 b8 ab 60 41 80 	movabs $0x804160abb8,%rax
  804160abe2:	00 00 00 
  804160abe5:	ff d0                	callq  *%rax
  804160abe7:	89 c3                	mov    %eax,%ebx
  __asm __volatile("rdtsc"
  804160abe9:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160abeb:	48 c1 e2 20          	shl    $0x20,%rdx
  804160abef:	89 c0                	mov    %eax,%eax
  804160abf1:	48 09 c2             	or     %rax,%rdx
  804160abf4:	49 89 d5             	mov    %rdx,%r13

  uint64_t tsc0 = read_tsc();

  do {
    asm("pause");
    uint32_t tick1 = pmtimer_get_timeval();
  804160abf7:	49 bc b8 ab 60 41 80 	movabs $0x804160abb8,%r12
  804160abfe:	00 00 00 
  804160ac01:	eb 17                	jmp    804160ac1a <pmtimer_cpu_frequency+0x4c>
    delta = tick1 - tick0;
    if (-delta <= 0xFFFFFF) {
      delta += 0xFFFFFF;
    } else if (tick0 > tick1) {
  804160ac03:	39 c3                	cmp    %eax,%ebx
  804160ac05:	76 0a                	jbe    804160ac11 <pmtimer_cpu_frequency+0x43>
      delta += 0xFFFFFFFF;
  804160ac07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160ac0c:	48 01 c1             	add    %rax,%rcx
  804160ac0f:	eb 28                	jmp    804160ac39 <pmtimer_cpu_frequency+0x6b>
    }
  } while (delta < target);
  804160ac11:	48 81 f9 d2 8b 00 00 	cmp    $0x8bd2,%rcx
  804160ac18:	77 1f                	ja     804160ac39 <pmtimer_cpu_frequency+0x6b>
    asm("pause");
  804160ac1a:	f3 90                	pause  
    uint32_t tick1 = pmtimer_get_timeval();
  804160ac1c:	41 ff d4             	callq  *%r12
    delta = tick1 - tick0;
  804160ac1f:	89 c1                	mov    %eax,%ecx
  804160ac21:	29 d9                	sub    %ebx,%ecx
    if (-delta <= 0xFFFFFF) {
  804160ac23:	48 89 ca             	mov    %rcx,%rdx
  804160ac26:	48 f7 da             	neg    %rdx
  804160ac29:	48 81 fa ff ff ff 00 	cmp    $0xffffff,%rdx
  804160ac30:	77 d1                	ja     804160ac03 <pmtimer_cpu_frequency+0x35>
      delta += 0xFFFFFF;
  804160ac32:	48 81 c1 ff ff ff 00 	add    $0xffffff,%rcx
  __asm __volatile("rdtsc"
  804160ac39:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160ac3b:	48 c1 e2 20          	shl    $0x20,%rdx
  804160ac3f:	89 c0                	mov    %eax,%eax
  804160ac41:	48 09 c2             	or     %rax,%rdx

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * PM_FREQ / delta;
  804160ac44:	4c 29 ea             	sub    %r13,%rdx
  804160ac47:	48 69 c2 99 9e 36 00 	imul   $0x369e99,%rdx,%rax
  804160ac4e:	ba 00 00 00 00       	mov    $0x0,%edx
  804160ac53:	48 f7 f1             	div    %rcx
  // LAB 5 code end
  // return 0;
}
  804160ac56:	48 83 c4 08          	add    $0x8,%rsp
  804160ac5a:	5b                   	pop    %rbx
  804160ac5b:	41 5c                	pop    %r12
  804160ac5d:	41 5d                	pop    %r13
  804160ac5f:	5d                   	pop    %rbp
  804160ac60:	c3                   	retq   

000000804160ac61 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160ac61:	48 a1 20 46 70 41 80 	movabs 0x8041704620,%rax
  804160ac68:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  804160ac6b:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  804160ac71:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160ac74:	83 fa 02             	cmp    $0x2,%edx
  804160ac77:	76 5c                	jbe    804160acd5 <sched_halt+0x74>
  804160ac79:	48 8d 90 cc 01 00 00 	lea    0x1cc(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  804160ac80:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  804160ac85:	8b 02                	mov    (%rdx),%eax
  804160ac87:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160ac8a:	83 f8 02             	cmp    $0x2,%eax
  804160ac8d:	76 46                	jbe    804160acd5 <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  804160ac8f:	83 c1 01             	add    $0x1,%ecx
  804160ac92:	48 81 c2 f8 00 00 00 	add    $0xf8,%rdx
  804160ac99:	83 f9 20             	cmp    $0x20,%ecx
  804160ac9c:	75 e7                	jne    804160ac85 <sched_halt+0x24>
sched_halt(void) {
  804160ac9e:	55                   	push   %rbp
  804160ac9f:	48 89 e5             	mov    %rsp,%rbp
  804160aca2:	53                   	push   %rbx
  804160aca3:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  804160aca7:	48 bf 38 e5 60 41 80 	movabs $0x804160e538,%rdi
  804160acae:	00 00 00 
  804160acb1:	b8 00 00 00 00       	mov    $0x0,%eax
  804160acb6:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160acbd:	00 00 00 
  804160acc0:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  804160acc2:	48 bb 5e 3f 60 41 80 	movabs $0x8041603f5e,%rbx
  804160acc9:	00 00 00 
  804160accc:	bf 00 00 00 00       	mov    $0x0,%edi
  804160acd1:	ff d3                	callq  *%rbx
    while (1)
  804160acd3:	eb f7                	jmp    804160accc <sched_halt+0x6b>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  804160acd5:	48 b8 18 46 70 41 80 	movabs $0x8041704618,%rax
  804160acdc:	00 00 00 
  804160acdf:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  804160ace6:	48 a1 64 5c 70 41 80 	movabs 0x8041705c64,%rax
  804160aced:	00 00 00 
  804160acf0:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  804160acf7:	48 89 c4             	mov    %rax,%rsp
  804160acfa:	6a 00                	pushq  $0x0
  804160acfc:	6a 00                	pushq  $0x0
  804160acfe:	fb                   	sti    
  804160acff:	f4                   	hlt    
  804160ad00:	c3                   	retq   

000000804160ad01 <sched_yield>:
sched_yield(void) {
  804160ad01:	55                   	push   %rbp
  804160ad02:	48 89 e5             	mov    %rsp,%rbp
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160ad05:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  804160ad0c:	00 00 00 
  804160ad0f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  804160ad15:	48 85 c0             	test   %rax,%rax
  804160ad18:	74 0b                	je     804160ad25 <sched_yield+0x24>
  804160ad1a:	44 8b 80 c8 00 00 00 	mov    0xc8(%rax),%r8d
  804160ad21:	41 83 e0 1f          	and    $0x1f,%r8d
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160ad25:	48 b8 20 46 70 41 80 	movabs $0x8041704620,%rax
  804160ad2c:	00 00 00 
  804160ad2f:	4c 8b 08             	mov    (%rax),%r9
  int id   = curenv ? ENVX(curenv_getid()) : 0;
  804160ad32:	44 89 c2             	mov    %r8d,%edx
  804160ad35:	eb 05                	jmp    804160ad3c <sched_yield+0x3b>
  } while (id != orig);
  804160ad37:	41 39 c0             	cmp    %eax,%r8d
  804160ad3a:	74 42                	je     804160ad7e <sched_yield+0x7d>
    id = (id + 1) % NENV;
  804160ad3c:	8d 42 01             	lea    0x1(%rdx),%eax
  804160ad3f:	99                   	cltd   
  804160ad40:	c1 ea 1b             	shr    $0x1b,%edx
  804160ad43:	01 d0                	add    %edx,%eax
  804160ad45:	83 e0 1f             	and    $0x1f,%eax
  804160ad48:	29 d0                	sub    %edx,%eax
  804160ad4a:	89 c2                	mov    %eax,%edx
    if (envs[id].env_status == ENV_RUNNABLE ||
  804160ad4c:	48 63 f0             	movslq %eax,%rsi
  804160ad4f:	48 89 f1             	mov    %rsi,%rcx
  804160ad52:	48 c1 e1 05          	shl    $0x5,%rcx
  804160ad56:	48 29 f1             	sub    %rsi,%rcx
  804160ad59:	49 8d 3c c9          	lea    (%r9,%rcx,8),%rdi
  804160ad5d:	8b 8f d4 00 00 00    	mov    0xd4(%rdi),%ecx
  804160ad63:	83 f9 02             	cmp    $0x2,%ecx
  804160ad66:	74 0a                	je     804160ad72 <sched_yield+0x71>
       (id == orig && envs[id].env_status == ENV_RUNNING)) {
  804160ad68:	83 f9 03             	cmp    $0x3,%ecx
  804160ad6b:	75 ca                	jne    804160ad37 <sched_yield+0x36>
  804160ad6d:	41 39 c0             	cmp    %eax,%r8d
  804160ad70:	75 c5                	jne    804160ad37 <sched_yield+0x36>
      env_run(envs + id);
  804160ad72:	48 b8 1d 8f 60 41 80 	movabs $0x8041608f1d,%rax
  804160ad79:	00 00 00 
  804160ad7c:	ff d0                	callq  *%rax
  sched_halt();
  804160ad7e:	48 b8 61 ac 60 41 80 	movabs $0x804160ac61,%rax
  804160ad85:	00 00 00 
  804160ad88:	ff d0                	callq  *%rax
}
  804160ad8a:	5d                   	pop    %rbp
  804160ad8b:	c3                   	retq   

000000804160ad8c <syscall>:
  // LAB 8 code end
}

// Dispatches to the correct kernel function, passing the arguments.
uintptr_t
syscall(uintptr_t syscallno, uintptr_t a1, uintptr_t a2, uintptr_t a3, uintptr_t a4, uintptr_t a5) {
  804160ad8c:	55                   	push   %rbp
  804160ad8d:	48 89 e5             	mov    %rsp,%rbp
  804160ad90:	41 55                	push   %r13
  804160ad92:	41 54                	push   %r12
  804160ad94:	53                   	push   %rbx
  804160ad95:	48 83 ec 18          	sub    $0x18,%rsp
  804160ad99:	48 89 fb             	mov    %rdi,%rbx
  804160ad9c:	49 89 f4             	mov    %rsi,%r12
  // Call the function corresponding to the 'syscallno' parameter.
  // Return any appropriate return value.

  // LAB 8 code
  if (syscallno == SYS_cputs) {
  804160ad9f:	48 85 ff             	test   %rdi,%rdi
  804160ada2:	74 24                	je     804160adc8 <syscall+0x3c>
    sys_cputs((const char *) a1, (size_t) a2);
    return 0;
  } else if (syscallno == SYS_cgetc) {
  804160ada4:	48 83 ff 01          	cmp    $0x1,%rdi
  804160ada8:	74 65                	je     804160ae0f <syscall+0x83>
    return sys_cgetc();
  } else if (syscallno == SYS_getenvid) {
  804160adaa:	48 83 ff 02          	cmp    $0x2,%rdi
  804160adae:	74 6f                	je     804160ae1f <syscall+0x93>
    return sys_getenvid();
  } else if (syscallno == SYS_env_destroy) {
    return sys_env_destroy((envid_t) a1);
  } else {
    return -E_INVAL;
  804160adb0:	48 c7 c0 fd ff ff ff 	mov    $0xfffffffffffffffd,%rax
  } else if (syscallno == SYS_env_destroy) {
  804160adb7:	48 83 ff 03          	cmp    $0x3,%rdi
  804160adbb:	74 75                	je     804160ae32 <syscall+0xa6>
  }
  // LAB 8 code end
  
  // return -E_INVAL;
}
  804160adbd:	48 83 c4 18          	add    $0x18,%rsp
  804160adc1:	5b                   	pop    %rbx
  804160adc2:	41 5c                	pop    %r12
  804160adc4:	41 5d                	pop    %r13
  804160adc6:	5d                   	pop    %rbp
  804160adc7:	c3                   	retq   
  804160adc8:	49 89 d5             	mov    %rdx,%r13
  user_mem_assert(curenv, s, len, PTE_U);
  804160adcb:	b9 04 00 00 00       	mov    $0x4,%ecx
  804160add0:	48 b8 18 46 70 41 80 	movabs $0x8041704618,%rax
  804160add7:	00 00 00 
  804160adda:	48 8b 38             	mov    (%rax),%rdi
  804160addd:	48 b8 e6 84 60 41 80 	movabs $0x80416084e6,%rax
  804160ade4:	00 00 00 
  804160ade7:	ff d0                	callq  *%rax
	cprintf("%.*s", (int)len, s);
  804160ade9:	4c 89 e2             	mov    %r12,%rdx
  804160adec:	44 89 ee             	mov    %r13d,%esi
  804160adef:	48 bf 61 e5 60 41 80 	movabs $0x804160e561,%rdi
  804160adf6:	00 00 00 
  804160adf9:	b8 00 00 00 00       	mov    $0x0,%eax
  804160adfe:	48 b9 78 92 60 41 80 	movabs $0x8041609278,%rcx
  804160ae05:	00 00 00 
  804160ae08:	ff d1                	callq  *%rcx
    return 0;
  804160ae0a:	48 89 d8             	mov    %rbx,%rax
  804160ae0d:	eb ae                	jmp    804160adbd <syscall+0x31>
  return cons_getc();
  804160ae0f:	48 b8 55 0c 60 41 80 	movabs $0x8041600c55,%rax
  804160ae16:	00 00 00 
  804160ae19:	ff d0                	callq  *%rax
    return sys_cgetc();
  804160ae1b:	48 98                	cltq   
  804160ae1d:	eb 9e                	jmp    804160adbd <syscall+0x31>
    return sys_getenvid();
  804160ae1f:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  804160ae26:	00 00 00 
  804160ae29:	48 63 80 c8 00 00 00 	movslq 0xc8(%rax),%rax
  804160ae30:	eb 8b                	jmp    804160adbd <syscall+0x31>
	if ((r = envid2env(envid, &e, 1)) < 0)
  804160ae32:	ba 01 00 00 00       	mov    $0x1,%edx
  804160ae37:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  804160ae3b:	44 89 e7             	mov    %r12d,%edi
  804160ae3e:	48 b8 79 85 60 41 80 	movabs $0x8041608579,%rax
  804160ae45:	00 00 00 
  804160ae48:	ff d0                	callq  *%rax
  804160ae4a:	85 c0                	test   %eax,%eax
  804160ae4c:	78 4f                	js     804160ae9d <syscall+0x111>
	if (e == curenv)
  804160ae4e:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  804160ae52:	48 a1 18 46 70 41 80 	movabs 0x8041704618,%rax
  804160ae59:	00 00 00 
  804160ae5c:	48 39 c2             	cmp    %rax,%rdx
  804160ae5f:	74 43                	je     804160aea4 <syscall+0x118>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
  804160ae61:	8b 92 c8 00 00 00    	mov    0xc8(%rdx),%edx
  804160ae67:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160ae6d:	48 bf 81 e5 60 41 80 	movabs $0x804160e581,%rdi
  804160ae74:	00 00 00 
  804160ae77:	b8 00 00 00 00       	mov    $0x0,%eax
  804160ae7c:	48 b9 78 92 60 41 80 	movabs $0x8041609278,%rcx
  804160ae83:	00 00 00 
  804160ae86:	ff d1                	callq  *%rcx
	env_destroy(e);
  804160ae88:	48 8b 7d d8          	mov    -0x28(%rbp),%rdi
  804160ae8c:	48 b8 57 8e 60 41 80 	movabs $0x8041608e57,%rax
  804160ae93:	00 00 00 
  804160ae96:	ff d0                	callq  *%rax
	return 0;
  804160ae98:	b8 00 00 00 00       	mov    $0x0,%eax
    return sys_env_destroy((envid_t) a1);
  804160ae9d:	48 98                	cltq   
  804160ae9f:	e9 19 ff ff ff       	jmpq   804160adbd <syscall+0x31>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
  804160aea4:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  804160aeaa:	48 bf 66 e5 60 41 80 	movabs $0x804160e566,%rdi
  804160aeb1:	00 00 00 
  804160aeb4:	b8 00 00 00 00       	mov    $0x0,%eax
  804160aeb9:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160aec0:	00 00 00 
  804160aec3:	ff d2                	callq  *%rdx
  804160aec5:	eb c1                	jmp    804160ae88 <syscall+0xfc>

000000804160aec7 <load_kernel_dwarf_info>:
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  804160aec7:	48 ba 00 f0 61 41 80 	movabs $0x804161f000,%rdx
  804160aece:	00 00 00 
  804160aed1:	48 8b 02             	mov    (%rdx),%rax
  804160aed4:	48 8b 48 58          	mov    0x58(%rax),%rcx
  804160aed8:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  804160aedc:	48 8b 48 60          	mov    0x60(%rax),%rcx
  804160aee0:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  804160aee4:	48 8b 40 68          	mov    0x68(%rax),%rax
  804160aee8:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  804160aeeb:	48 8b 02             	mov    (%rdx),%rax
  804160aeee:	48 8b 50 70          	mov    0x70(%rax),%rdx
  804160aef2:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  804160aef6:	48 8b 50 78          	mov    0x78(%rax),%rdx
  804160aefa:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  804160aefe:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  804160af05:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  804160af09:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  804160af10:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  804160af14:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  804160af1b:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  804160af1f:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  804160af26:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  804160af2a:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  804160af31:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  804160af35:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  804160af3c:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  804160af40:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  804160af47:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  804160af4b:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  804160af52:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  804160af56:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  804160af5d:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  804160af61:	c3                   	retq   

000000804160af62 <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  804160af62:	55                   	push   %rbp
  804160af63:	48 89 e5             	mov    %rsp,%rbp
  804160af66:	41 56                	push   %r14
  804160af68:	41 55                	push   %r13
  804160af6a:	41 54                	push   %r12
  804160af6c:	53                   	push   %rbx
  804160af6d:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  804160af74:	49 89 fc             	mov    %rdi,%r12
  804160af77:	48 89 f3             	mov    %rsi,%rbx
  // const struct Stab *stabs, *stab_end;
	// const char *stabstr, *stabstr_end;
  // LAB 8 code end

  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  804160af7a:	48 be 99 e5 60 41 80 	movabs $0x804160e599,%rsi
  804160af81:	00 00 00 
  804160af84:	48 89 df             	mov    %rbx,%rdi
  804160af87:	49 bd d9 bc 60 41 80 	movabs $0x804160bcd9,%r13
  804160af8e:	00 00 00 
  804160af91:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  804160af94:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  804160af9b:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  804160af9e:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  804160afa5:	48 be 99 e5 60 41 80 	movabs $0x804160e599,%rsi
  804160afac:	00 00 00 
  804160afaf:	4c 89 f7             	mov    %r14,%rdi
  804160afb2:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  804160afb5:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  804160afbc:	00 00 00 
  info->rip_fn_addr    = addr;
  804160afbf:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  804160afc6:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  804160afcd:	00 00 00 

  if (!addr) {
  804160afd0:	4d 85 e4             	test   %r12,%r12
  804160afd3:	0f 84 ea 01 00 00    	je     804160b1c3 <debuginfo_rip+0x261>
  // Temporarily load kernel cr3 and return back once done.
  // Make sure that you fully understand why it is necessary.
  // LAB 8: Your code here.

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  804160afd9:	48 b8 00 e0 c2 3e 80 	movabs $0x803ec2e000,%rax
  804160afe0:	00 00 00 
  804160afe3:	49 39 c4             	cmp    %rax,%r12
  804160afe6:	0f 87 bf 01 00 00    	ja     804160b1ab <debuginfo_rip+0x249>
  __asm __volatile("movq %%cr3,%0"
  804160afec:	41 0f 20 dd          	mov    %cr3,%r13

    // LAB 8 code
    uint64_t tmp_cr3 = rcr3();
    lcr3(PADDR(kern_pml4e));
  804160aff0:	48 a1 40 5b 70 41 80 	movabs 0x8041705b40,%rax
  804160aff7:	00 00 00 
  if ((uint64_t)kva < KERNBASE)
  804160affa:	48 ba ff ff ff 3f 80 	movabs $0x803fffffff,%rdx
  804160b001:	00 00 00 
  804160b004:	48 39 d0             	cmp    %rdx,%rax
  804160b007:	0f 86 70 01 00 00    	jbe    804160b17d <debuginfo_rip+0x21b>
  return (physaddr_t)kva - KERNBASE;
  804160b00d:	48 b9 00 00 00 c0 7f 	movabs $0xffffff7fc0000000,%rcx
  804160b014:	ff ff ff 
  804160b017:	48 01 c8             	add    %rcx,%rax
  __asm __volatile("movq %0,%%cr3"
  804160b01a:	0f 22 d8             	mov    %rax,%cr3
    load_kernel_dwarf_info(&addrs);
  804160b01d:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160b024:	48 b8 c7 ae 60 41 80 	movabs $0x804160aec7,%rax
  804160b02b:	00 00 00 
  804160b02e:	ff d0                	callq  *%rax
  804160b030:	41 0f 22 dd          	mov    %r13,%cr3
    load_kernel_dwarf_info(&addrs);
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  804160b034:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  804160b03b:	00 00 00 00 
  804160b03f:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  804160b046:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  804160b04a:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  804160b051:	4c 89 e6             	mov    %r12,%rsi
  804160b054:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160b05b:	48 b8 15 17 60 41 80 	movabs $0x8041601715,%rax
  804160b062:	00 00 00 
  804160b065:	ff d0                	callq  *%rax
  804160b067:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  804160b06a:	85 c0                	test   %eax,%eax
  804160b06c:	0f 88 57 01 00 00    	js     804160b1c9 <debuginfo_rip+0x267>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  804160b072:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  804160b079:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160b07e:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160b085:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  804160b08c:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160b093:	48 b8 c4 1d 60 41 80 	movabs $0x8041601dc4,%rax
  804160b09a:	00 00 00 
  804160b09d:	ff d0                	callq  *%rax
  804160b09f:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  804160b0a2:	ba 00 01 00 00       	mov    $0x100,%edx
  804160b0a7:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160b0ae:	48 89 df             	mov    %rbx,%rdi
  804160b0b1:	48 b8 27 bd 60 41 80 	movabs $0x804160bd27,%rax
  804160b0b8:	00 00 00 
  804160b0bb:	ff d0                	callq  *%rax
  if (code < 0) {
  804160b0bd:	45 85 ed             	test   %r13d,%r13d
  804160b0c0:	0f 88 03 01 00 00    	js     804160b1c9 <debuginfo_rip+0x267>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
    
  int lineno_store;
  addr = addr - 5;
  804160b0c6:	49 83 ec 05          	sub    $0x5,%r12
  code = line_for_address(&addrs, addr, line_offset, &lineno_store);
  804160b0ca:	48 8d 8d 54 ff ff ff 	lea    -0xac(%rbp),%rcx
  804160b0d1:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  804160b0d8:	4c 89 e6             	mov    %r12,%rsi
  804160b0db:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160b0e2:	48 b8 0e 33 60 41 80 	movabs $0x804160330e,%rax
  804160b0e9:	00 00 00 
  804160b0ec:	ff d0                	callq  *%rax
  804160b0ee:	41 89 c5             	mov    %eax,%r13d
  info->rip_line = lineno_store;
  804160b0f1:	8b 85 54 ff ff ff    	mov    -0xac(%rbp),%eax
  804160b0f7:	89 83 00 01 00 00    	mov    %eax,0x100(%rbx)
  if (code < 0) {
  804160b0fd:	45 85 ed             	test   %r13d,%r13d
  804160b100:	0f 88 c3 00 00 00    	js     804160b1c9 <debuginfo_rip+0x267>
  }
    
  //LAB 2 code end

  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  804160b106:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  804160b10d:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160b113:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  804160b11a:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  804160b121:	4c 89 e6             	mov    %r12,%rsi
  804160b124:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160b12b:	48 b8 2f 22 60 41 80 	movabs $0x804160222f,%rax
  804160b132:	00 00 00 
  804160b135:	ff d0                	callq  *%rax
  804160b137:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  804160b13a:	ba 00 01 00 00       	mov    $0x100,%edx
  804160b13f:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  804160b146:	4c 89 f7             	mov    %r14,%rdi
  804160b149:	48 b8 27 bd 60 41 80 	movabs $0x804160bd27,%rax
  804160b150:	00 00 00 
  804160b153:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  804160b155:	be 00 01 00 00       	mov    $0x100,%esi
  804160b15a:	4c 89 f7             	mov    %r14,%rdi
  804160b15d:	48 b8 a4 bc 60 41 80 	movabs $0x804160bca4,%rax
  804160b164:	00 00 00 
  804160b167:	ff d0                	callq  *%rax
  804160b169:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  804160b16f:	45 85 ed             	test   %r13d,%r13d
  804160b172:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b177:	44 0f 4f e8          	cmovg  %eax,%r13d
  804160b17b:	eb 4c                	jmp    804160b1c9 <debuginfo_rip+0x267>
    _panic(file, line, "PADDR called with invalid kva %p", kva);
  804160b17d:	48 89 c1             	mov    %rax,%rcx
  804160b180:	48 ba c0 d0 60 41 80 	movabs $0x804160d0c0,%rdx
  804160b187:	00 00 00 
  804160b18a:	be 44 00 00 00       	mov    $0x44,%esi
  804160b18f:	48 bf a3 e5 60 41 80 	movabs $0x804160e5a3,%rdi
  804160b196:	00 00 00 
  804160b199:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b19e:	49 b8 5a 02 60 41 80 	movabs $0x804160025a,%r8
  804160b1a5:	00 00 00 
  804160b1a8:	41 ff d0             	callq  *%r8
    load_kernel_dwarf_info(&addrs);
  804160b1ab:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160b1b2:	48 b8 c7 ae 60 41 80 	movabs $0x804160aec7,%rax
  804160b1b9:	00 00 00 
  804160b1bc:	ff d0                	callq  *%rax
  804160b1be:	e9 71 fe ff ff       	jmpq   804160b034 <debuginfo_rip+0xd2>
    return 0;
  804160b1c3:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    return code;
  }
  return 0;
}
  804160b1c9:	44 89 e8             	mov    %r13d,%eax
  804160b1cc:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  804160b1d3:	5b                   	pop    %rbx
  804160b1d4:	41 5c                	pop    %r12
  804160b1d6:	41 5d                	pop    %r13
  804160b1d8:	41 5e                	pop    %r14
  804160b1da:	5d                   	pop    %rbp
  804160b1db:	c3                   	retq   

000000804160b1dc <find_function>:

uintptr_t
find_function(const char *const fname) {
  804160b1dc:	55                   	push   %rbp
  804160b1dd:	48 89 e5             	mov    %rsp,%rbp
  804160b1e0:	53                   	push   %rbx
  804160b1e1:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  804160b1e8:	48 89 fb             	mov    %rdi,%rbx
  // LAB 6 code
  #endif
  // LAB 6 code end
    
  struct Dwarf_Addrs addrs;
  load_kernel_dwarf_info(&addrs);
  804160b1eb:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b1ef:	48 b8 c7 ae 60 41 80 	movabs $0x804160aec7,%rax
  804160b1f6:	00 00 00 
  804160b1f9:	ff d0                	callq  *%rax
  uintptr_t offset = 0;
  804160b1fb:	48 c7 85 78 ff ff ff 	movq   $0x0,-0x88(%rbp)
  804160b202:	00 00 00 00 

  if (!address_by_fname(&addrs, fname, &offset) && offset) {
  804160b206:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160b20d:	48 89 de             	mov    %rbx,%rsi
  804160b210:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b214:	48 b8 bb 27 60 41 80 	movabs $0x80416027bb,%rax
  804160b21b:	00 00 00 
  804160b21e:	ff d0                	callq  *%rax
  804160b220:	85 c0                	test   %eax,%eax
  804160b222:	75 0c                	jne    804160b230 <find_function+0x54>
  804160b224:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160b22b:	48 85 d2             	test   %rdx,%rdx
  804160b22e:	75 23                	jne    804160b253 <find_function+0x77>
    return offset;
  }

  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160b230:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  804160b237:	48 89 de             	mov    %rbx,%rsi
  804160b23a:	48 8d 7d 80          	lea    -0x80(%rbp),%rdi
  804160b23e:	48 b8 b9 2d 60 41 80 	movabs $0x8041602db9,%rax
  804160b245:	00 00 00 
  804160b248:	ff d0                	callq  *%rax
    return offset;
  }
  // LAB 3 code end

  return 0;
  804160b24a:	ba 00 00 00 00       	mov    $0x0,%edx
  if (!naive_address_by_fname(&addrs, fname, &offset)) {
  804160b24f:	85 c0                	test   %eax,%eax
  804160b251:	74 0d                	je     804160b260 <find_function+0x84>
}
  804160b253:	48 89 d0             	mov    %rdx,%rax
  804160b256:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  804160b25d:	5b                   	pop    %rbx
  804160b25e:	5d                   	pop    %rbp
  804160b25f:	c3                   	retq   
    return offset;
  804160b260:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  804160b267:	eb ea                	jmp    804160b253 <find_function+0x77>

000000804160b269 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  804160b269:	55                   	push   %rbp
  804160b26a:	48 89 e5             	mov    %rsp,%rbp
  804160b26d:	41 57                	push   %r15
  804160b26f:	41 56                	push   %r14
  804160b271:	41 55                	push   %r13
  804160b273:	41 54                	push   %r12
  804160b275:	53                   	push   %rbx
  804160b276:	48 83 ec 18          	sub    $0x18,%rsp
  804160b27a:	49 89 fc             	mov    %rdi,%r12
  804160b27d:	49 89 f5             	mov    %rsi,%r13
  804160b280:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160b284:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  804160b287:	41 89 cf             	mov    %ecx,%r15d
  804160b28a:	49 39 d7             	cmp    %rdx,%r15
  804160b28d:	76 45                	jbe    804160b2d4 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  804160b28f:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160b293:	85 db                	test   %ebx,%ebx
  804160b295:	7e 0e                	jle    804160b2a5 <printnum+0x3c>
      putch(padc, putdat);
  804160b297:	4c 89 ee             	mov    %r13,%rsi
  804160b29a:	44 89 f7             	mov    %r14d,%edi
  804160b29d:	41 ff d4             	callq  *%r12
    while (--width > 0)
  804160b2a0:	83 eb 01             	sub    $0x1,%ebx
  804160b2a3:	75 f2                	jne    804160b297 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  804160b2a5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b2a9:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b2ae:	49 f7 f7             	div    %r15
  804160b2b1:	48 b8 b1 e5 60 41 80 	movabs $0x804160e5b1,%rax
  804160b2b8:	00 00 00 
  804160b2bb:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  804160b2bf:	4c 89 ee             	mov    %r13,%rsi
  804160b2c2:	41 ff d4             	callq  *%r12
}
  804160b2c5:	48 83 c4 18          	add    $0x18,%rsp
  804160b2c9:	5b                   	pop    %rbx
  804160b2ca:	41 5c                	pop    %r12
  804160b2cc:	41 5d                	pop    %r13
  804160b2ce:	41 5e                	pop    %r14
  804160b2d0:	41 5f                	pop    %r15
  804160b2d2:	5d                   	pop    %rbp
  804160b2d3:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  804160b2d4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  804160b2d8:	ba 00 00 00 00       	mov    $0x0,%edx
  804160b2dd:	49 f7 f7             	div    %r15
  804160b2e0:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  804160b2e4:	48 89 c2             	mov    %rax,%rdx
  804160b2e7:	48 b8 69 b2 60 41 80 	movabs $0x804160b269,%rax
  804160b2ee:	00 00 00 
  804160b2f1:	ff d0                	callq  *%rax
  804160b2f3:	eb b0                	jmp    804160b2a5 <printnum+0x3c>

000000804160b2f5 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  804160b2f5:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  804160b2f9:	48 8b 06             	mov    (%rsi),%rax
  804160b2fc:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  804160b300:	73 0a                	jae    804160b30c <sprintputch+0x17>
    *b->buf++ = ch;
  804160b302:	48 8d 50 01          	lea    0x1(%rax),%rdx
  804160b306:	48 89 16             	mov    %rdx,(%rsi)
  804160b309:	40 88 38             	mov    %dil,(%rax)
}
  804160b30c:	c3                   	retq   

000000804160b30d <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  804160b30d:	55                   	push   %rbp
  804160b30e:	48 89 e5             	mov    %rsp,%rbp
  804160b311:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160b318:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160b31f:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160b326:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160b32d:	84 c0                	test   %al,%al
  804160b32f:	74 20                	je     804160b351 <printfmt+0x44>
  804160b331:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160b335:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160b339:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160b33d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160b341:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160b345:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160b349:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160b34d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  804160b351:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160b358:	00 00 00 
  804160b35b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160b362:	00 00 00 
  804160b365:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160b369:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160b370:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160b377:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  804160b37e:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160b385:	48 b8 93 b3 60 41 80 	movabs $0x804160b393,%rax
  804160b38c:	00 00 00 
  804160b38f:	ff d0                	callq  *%rax
}
  804160b391:	c9                   	leaveq 
  804160b392:	c3                   	retq   

000000804160b393 <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  804160b393:	55                   	push   %rbp
  804160b394:	48 89 e5             	mov    %rsp,%rbp
  804160b397:	41 57                	push   %r15
  804160b399:	41 56                	push   %r14
  804160b39b:	41 55                	push   %r13
  804160b39d:	41 54                	push   %r12
  804160b39f:	53                   	push   %rbx
  804160b3a0:	48 83 ec 48          	sub    $0x48,%rsp
  804160b3a4:	49 89 fd             	mov    %rdi,%r13
  804160b3a7:	49 89 f7             	mov    %rsi,%r15
  804160b3aa:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  804160b3ad:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  804160b3b1:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  804160b3b5:	48 8b 41 10          	mov    0x10(%rcx),%rax
  804160b3b9:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160b3bd:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  804160b3c1:	41 0f b6 3e          	movzbl (%r14),%edi
  804160b3c5:	83 ff 25             	cmp    $0x25,%edi
  804160b3c8:	74 18                	je     804160b3e2 <vprintfmt+0x4f>
      if (ch == '\0')
  804160b3ca:	85 ff                	test   %edi,%edi
  804160b3cc:	0f 84 8c 06 00 00    	je     804160ba5e <vprintfmt+0x6cb>
      putch(ch, putdat);
  804160b3d2:	4c 89 fe             	mov    %r15,%rsi
  804160b3d5:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  804160b3d8:	49 89 de             	mov    %rbx,%r14
  804160b3db:	eb e0                	jmp    804160b3bd <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160b3dd:	49 89 de             	mov    %rbx,%r14
  804160b3e0:	eb db                	jmp    804160b3bd <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  804160b3e2:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  804160b3e6:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  804160b3ea:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  804160b3f1:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  804160b3f7:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  804160b3fb:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  804160b400:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160b406:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  804160b40c:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  804160b411:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  804160b416:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  804160b41a:	0f b6 13             	movzbl (%rbx),%edx
  804160b41d:	8d 42 dd             	lea    -0x23(%rdx),%eax
  804160b420:	3c 55                	cmp    $0x55,%al
  804160b422:	0f 87 8b 05 00 00    	ja     804160b9b3 <vprintfmt+0x620>
  804160b428:	0f b6 c0             	movzbl %al,%eax
  804160b42b:	49 bb 60 e6 60 41 80 	movabs $0x804160e660,%r11
  804160b432:	00 00 00 
  804160b435:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  804160b439:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  804160b43c:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  804160b440:	eb d4                	jmp    804160b416 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160b442:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  804160b445:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  804160b449:	eb cb                	jmp    804160b416 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160b44b:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  804160b44e:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  804160b452:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  804160b456:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160b459:	83 fa 09             	cmp    $0x9,%edx
  804160b45c:	77 7e                	ja     804160b4dc <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  804160b45e:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  804160b462:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  804160b466:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  804160b46b:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  804160b46f:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160b472:	83 fa 09             	cmp    $0x9,%edx
  804160b475:	76 e7                	jbe    804160b45e <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  804160b477:	4c 89 f3             	mov    %r14,%rbx
  804160b47a:	eb 19                	jmp    804160b495 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  804160b47c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b47f:	83 f8 2f             	cmp    $0x2f,%eax
  804160b482:	77 2a                	ja     804160b4ae <vprintfmt+0x11b>
  804160b484:	89 c2                	mov    %eax,%edx
  804160b486:	4c 01 d2             	add    %r10,%rdx
  804160b489:	83 c0 08             	add    $0x8,%eax
  804160b48c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b48f:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  804160b492:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  804160b495:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160b499:	0f 89 77 ff ff ff    	jns    804160b416 <vprintfmt+0x83>
          width = precision, precision = -1;
  804160b49f:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160b4a3:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  804160b4a9:	e9 68 ff ff ff       	jmpq   804160b416 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  804160b4ae:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b4b2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b4b6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b4ba:	eb d3                	jmp    804160b48f <vprintfmt+0xfc>
        if (width < 0)
  804160b4bc:	8b 45 ac             	mov    -0x54(%rbp),%eax
  804160b4bf:	85 c0                	test   %eax,%eax
  804160b4c1:	41 0f 48 c0          	cmovs  %r8d,%eax
  804160b4c5:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  804160b4c8:	4c 89 f3             	mov    %r14,%rbx
  804160b4cb:	e9 46 ff ff ff       	jmpq   804160b416 <vprintfmt+0x83>
  804160b4d0:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  804160b4d3:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  804160b4d7:	e9 3a ff ff ff       	jmpq   804160b416 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160b4dc:	4c 89 f3             	mov    %r14,%rbx
  804160b4df:	eb b4                	jmp    804160b495 <vprintfmt+0x102>
        lflag++;
  804160b4e1:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  804160b4e4:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  804160b4e7:	e9 2a ff ff ff       	jmpq   804160b416 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  804160b4ec:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b4ef:	83 f8 2f             	cmp    $0x2f,%eax
  804160b4f2:	77 19                	ja     804160b50d <vprintfmt+0x17a>
  804160b4f4:	89 c2                	mov    %eax,%edx
  804160b4f6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b4fa:	83 c0 08             	add    $0x8,%eax
  804160b4fd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b500:	4c 89 fe             	mov    %r15,%rsi
  804160b503:	8b 3a                	mov    (%rdx),%edi
  804160b505:	41 ff d5             	callq  *%r13
        break;
  804160b508:	e9 b0 fe ff ff       	jmpq   804160b3bd <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  804160b50d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b511:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b515:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b519:	eb e5                	jmp    804160b500 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  804160b51b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b51e:	83 f8 2f             	cmp    $0x2f,%eax
  804160b521:	77 5b                	ja     804160b57e <vprintfmt+0x1eb>
  804160b523:	89 c2                	mov    %eax,%edx
  804160b525:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b529:	83 c0 08             	add    $0x8,%eax
  804160b52c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b52f:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  804160b531:	89 c8                	mov    %ecx,%eax
  804160b533:	c1 f8 1f             	sar    $0x1f,%eax
  804160b536:	31 c1                	xor    %eax,%ecx
  804160b538:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  804160b53a:	83 f9 09             	cmp    $0x9,%ecx
  804160b53d:	7f 4d                	jg     804160b58c <vprintfmt+0x1f9>
  804160b53f:	48 63 c1             	movslq %ecx,%rax
  804160b542:	48 ba 20 e9 60 41 80 	movabs $0x804160e920,%rdx
  804160b549:	00 00 00 
  804160b54c:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  804160b550:	48 85 c0             	test   %rax,%rax
  804160b553:	74 37                	je     804160b58c <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  804160b555:	48 89 c1             	mov    %rax,%rcx
  804160b558:	48 ba cb c9 60 41 80 	movabs $0x804160c9cb,%rdx
  804160b55f:	00 00 00 
  804160b562:	4c 89 fe             	mov    %r15,%rsi
  804160b565:	4c 89 ef             	mov    %r13,%rdi
  804160b568:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b56d:	48 bb 0d b3 60 41 80 	movabs $0x804160b30d,%rbx
  804160b574:	00 00 00 
  804160b577:	ff d3                	callq  *%rbx
  804160b579:	e9 3f fe ff ff       	jmpq   804160b3bd <vprintfmt+0x2a>
        err = va_arg(aq, int);
  804160b57e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b582:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b586:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b58a:	eb a3                	jmp    804160b52f <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  804160b58c:	48 ba c9 e5 60 41 80 	movabs $0x804160e5c9,%rdx
  804160b593:	00 00 00 
  804160b596:	4c 89 fe             	mov    %r15,%rsi
  804160b599:	4c 89 ef             	mov    %r13,%rdi
  804160b59c:	b8 00 00 00 00       	mov    $0x0,%eax
  804160b5a1:	48 bb 0d b3 60 41 80 	movabs $0x804160b30d,%rbx
  804160b5a8:	00 00 00 
  804160b5ab:	ff d3                	callq  *%rbx
  804160b5ad:	e9 0b fe ff ff       	jmpq   804160b3bd <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  804160b5b2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b5b5:	83 f8 2f             	cmp    $0x2f,%eax
  804160b5b8:	77 4b                	ja     804160b605 <vprintfmt+0x272>
  804160b5ba:	89 c2                	mov    %eax,%edx
  804160b5bc:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b5c0:	83 c0 08             	add    $0x8,%eax
  804160b5c3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b5c6:	48 8b 02             	mov    (%rdx),%rax
  804160b5c9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  804160b5cd:	48 85 c0             	test   %rax,%rax
  804160b5d0:	0f 84 05 04 00 00    	je     804160b9db <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  804160b5d6:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160b5da:	7e 06                	jle    804160b5e2 <vprintfmt+0x24f>
  804160b5dc:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160b5e0:	75 31                	jne    804160b613 <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160b5e2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160b5e6:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160b5ea:	0f b6 00             	movzbl (%rax),%eax
  804160b5ed:	0f be f8             	movsbl %al,%edi
  804160b5f0:	85 ff                	test   %edi,%edi
  804160b5f2:	0f 84 c3 00 00 00    	je     804160b6bb <vprintfmt+0x328>
  804160b5f8:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160b5fc:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160b600:	e9 85 00 00 00       	jmpq   804160b68a <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  804160b605:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b609:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b60d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b611:	eb b3                	jmp    804160b5c6 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160b613:	49 63 f4             	movslq %r12d,%rsi
  804160b616:	48 89 c7             	mov    %rax,%rdi
  804160b619:	48 b8 a4 bc 60 41 80 	movabs $0x804160bca4,%rax
  804160b620:	00 00 00 
  804160b623:	ff d0                	callq  *%rax
  804160b625:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160b628:	8b 75 ac             	mov    -0x54(%rbp),%esi
  804160b62b:	85 f6                	test   %esi,%esi
  804160b62d:	7e 22                	jle    804160b651 <vprintfmt+0x2be>
            putch(padc, putdat);
  804160b62f:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  804160b633:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  804160b637:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  804160b63b:	4c 89 fe             	mov    %r15,%rsi
  804160b63e:	89 df                	mov    %ebx,%edi
  804160b640:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  804160b643:	41 83 ec 01          	sub    $0x1,%r12d
  804160b647:	75 f2                	jne    804160b63b <vprintfmt+0x2a8>
  804160b649:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160b64d:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160b651:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160b655:	48 8d 58 01          	lea    0x1(%rax),%rbx
  804160b659:	0f b6 00             	movzbl (%rax),%eax
  804160b65c:	0f be f8             	movsbl %al,%edi
  804160b65f:	85 ff                	test   %edi,%edi
  804160b661:	0f 84 56 fd ff ff    	je     804160b3bd <vprintfmt+0x2a>
  804160b667:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160b66b:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160b66f:	eb 19                	jmp    804160b68a <vprintfmt+0x2f7>
            putch(ch, putdat);
  804160b671:	4c 89 fe             	mov    %r15,%rsi
  804160b674:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160b677:	41 83 ee 01          	sub    $0x1,%r14d
  804160b67b:	48 83 c3 01          	add    $0x1,%rbx
  804160b67f:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  804160b683:	0f be f8             	movsbl %al,%edi
  804160b686:	85 ff                	test   %edi,%edi
  804160b688:	74 29                	je     804160b6b3 <vprintfmt+0x320>
  804160b68a:	45 85 e4             	test   %r12d,%r12d
  804160b68d:	78 06                	js     804160b695 <vprintfmt+0x302>
  804160b68f:	41 83 ec 01          	sub    $0x1,%r12d
  804160b693:	78 48                	js     804160b6dd <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  804160b695:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  804160b699:	74 d6                	je     804160b671 <vprintfmt+0x2de>
  804160b69b:	0f be c0             	movsbl %al,%eax
  804160b69e:	83 e8 20             	sub    $0x20,%eax
  804160b6a1:	83 f8 5e             	cmp    $0x5e,%eax
  804160b6a4:	76 cb                	jbe    804160b671 <vprintfmt+0x2de>
            putch('?', putdat);
  804160b6a6:	4c 89 fe             	mov    %r15,%rsi
  804160b6a9:	bf 3f 00 00 00       	mov    $0x3f,%edi
  804160b6ae:	41 ff d5             	callq  *%r13
  804160b6b1:	eb c4                	jmp    804160b677 <vprintfmt+0x2e4>
  804160b6b3:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160b6b7:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  804160b6bb:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  804160b6be:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160b6c2:	0f 8e f5 fc ff ff    	jle    804160b3bd <vprintfmt+0x2a>
          putch(' ', putdat);
  804160b6c8:	4c 89 fe             	mov    %r15,%rsi
  804160b6cb:	bf 20 00 00 00       	mov    $0x20,%edi
  804160b6d0:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  804160b6d3:	83 eb 01             	sub    $0x1,%ebx
  804160b6d6:	75 f0                	jne    804160b6c8 <vprintfmt+0x335>
  804160b6d8:	e9 e0 fc ff ff       	jmpq   804160b3bd <vprintfmt+0x2a>
  804160b6dd:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160b6e1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  804160b6e5:	eb d4                	jmp    804160b6bb <vprintfmt+0x328>
  if (lflag >= 2)
  804160b6e7:	83 f9 01             	cmp    $0x1,%ecx
  804160b6ea:	7f 1d                	jg     804160b709 <vprintfmt+0x376>
  else if (lflag)
  804160b6ec:	85 c9                	test   %ecx,%ecx
  804160b6ee:	74 5e                	je     804160b74e <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  804160b6f0:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b6f3:	83 f8 2f             	cmp    $0x2f,%eax
  804160b6f6:	77 48                	ja     804160b740 <vprintfmt+0x3ad>
  804160b6f8:	89 c2                	mov    %eax,%edx
  804160b6fa:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b6fe:	83 c0 08             	add    $0x8,%eax
  804160b701:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b704:	48 8b 1a             	mov    (%rdx),%rbx
  804160b707:	eb 17                	jmp    804160b720 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  804160b709:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b70c:	83 f8 2f             	cmp    $0x2f,%eax
  804160b70f:	77 21                	ja     804160b732 <vprintfmt+0x39f>
  804160b711:	89 c2                	mov    %eax,%edx
  804160b713:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b717:	83 c0 08             	add    $0x8,%eax
  804160b71a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b71d:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  804160b720:	48 85 db             	test   %rbx,%rbx
  804160b723:	78 50                	js     804160b775 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  804160b725:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  804160b728:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160b72d:	e9 b4 01 00 00       	jmpq   804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  804160b732:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b736:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b73a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b73e:	eb dd                	jmp    804160b71d <vprintfmt+0x38a>
    return va_arg(*ap, long);
  804160b740:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b744:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b748:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b74c:	eb b6                	jmp    804160b704 <vprintfmt+0x371>
    return va_arg(*ap, int);
  804160b74e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b751:	83 f8 2f             	cmp    $0x2f,%eax
  804160b754:	77 11                	ja     804160b767 <vprintfmt+0x3d4>
  804160b756:	89 c2                	mov    %eax,%edx
  804160b758:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b75c:	83 c0 08             	add    $0x8,%eax
  804160b75f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b762:	48 63 1a             	movslq (%rdx),%rbx
  804160b765:	eb b9                	jmp    804160b720 <vprintfmt+0x38d>
  804160b767:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b76b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b76f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b773:	eb ed                	jmp    804160b762 <vprintfmt+0x3cf>
          putch('-', putdat);
  804160b775:	4c 89 fe             	mov    %r15,%rsi
  804160b778:	bf 2d 00 00 00       	mov    $0x2d,%edi
  804160b77d:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  804160b780:	48 89 da             	mov    %rbx,%rdx
  804160b783:	48 f7 da             	neg    %rdx
        base = 10;
  804160b786:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160b78b:	e9 56 01 00 00       	jmpq   804160b8e6 <vprintfmt+0x553>
  if (lflag >= 2)
  804160b790:	83 f9 01             	cmp    $0x1,%ecx
  804160b793:	7f 25                	jg     804160b7ba <vprintfmt+0x427>
  else if (lflag)
  804160b795:	85 c9                	test   %ecx,%ecx
  804160b797:	74 5e                	je     804160b7f7 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  804160b799:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b79c:	83 f8 2f             	cmp    $0x2f,%eax
  804160b79f:	77 48                	ja     804160b7e9 <vprintfmt+0x456>
  804160b7a1:	89 c2                	mov    %eax,%edx
  804160b7a3:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b7a7:	83 c0 08             	add    $0x8,%eax
  804160b7aa:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b7ad:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160b7b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160b7b5:	e9 2c 01 00 00       	jmpq   804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160b7ba:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b7bd:	83 f8 2f             	cmp    $0x2f,%eax
  804160b7c0:	77 19                	ja     804160b7db <vprintfmt+0x448>
  804160b7c2:	89 c2                	mov    %eax,%edx
  804160b7c4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b7c8:	83 c0 08             	add    $0x8,%eax
  804160b7cb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b7ce:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  804160b7d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160b7d6:	e9 0b 01 00 00       	jmpq   804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160b7db:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b7df:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b7e3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b7e7:	eb e5                	jmp    804160b7ce <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  804160b7e9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b7ed:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b7f1:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b7f5:	eb b6                	jmp    804160b7ad <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  804160b7f7:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b7fa:	83 f8 2f             	cmp    $0x2f,%eax
  804160b7fd:	77 18                	ja     804160b817 <vprintfmt+0x484>
  804160b7ff:	89 c2                	mov    %eax,%edx
  804160b801:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b805:	83 c0 08             	add    $0x8,%eax
  804160b808:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b80b:	8b 12                	mov    (%rdx),%edx
        base = 10;
  804160b80d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160b812:	e9 cf 00 00 00       	jmpq   804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160b817:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b81b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b81f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b823:	eb e6                	jmp    804160b80b <vprintfmt+0x478>
  if (lflag >= 2)
  804160b825:	83 f9 01             	cmp    $0x1,%ecx
  804160b828:	7f 25                	jg     804160b84f <vprintfmt+0x4bc>
  else if (lflag)
  804160b82a:	85 c9                	test   %ecx,%ecx
  804160b82c:	74 5b                	je     804160b889 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  804160b82e:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b831:	83 f8 2f             	cmp    $0x2f,%eax
  804160b834:	77 45                	ja     804160b87b <vprintfmt+0x4e8>
  804160b836:	89 c2                	mov    %eax,%edx
  804160b838:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b83c:	83 c0 08             	add    $0x8,%eax
  804160b83f:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b842:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160b845:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160b84a:	e9 97 00 00 00       	jmpq   804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160b84f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b852:	83 f8 2f             	cmp    $0x2f,%eax
  804160b855:	77 16                	ja     804160b86d <vprintfmt+0x4da>
  804160b857:	89 c2                	mov    %eax,%edx
  804160b859:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b85d:	83 c0 08             	add    $0x8,%eax
  804160b860:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b863:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  804160b866:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160b86b:	eb 79                	jmp    804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160b86d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b871:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b875:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b879:	eb e8                	jmp    804160b863 <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  804160b87b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b87f:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b883:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b887:	eb b9                	jmp    804160b842 <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  804160b889:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b88c:	83 f8 2f             	cmp    $0x2f,%eax
  804160b88f:	77 15                	ja     804160b8a6 <vprintfmt+0x513>
  804160b891:	89 c2                	mov    %eax,%edx
  804160b893:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b897:	83 c0 08             	add    $0x8,%eax
  804160b89a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b89d:	8b 12                	mov    (%rdx),%edx
        base = 8;
  804160b89f:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160b8a4:	eb 40                	jmp    804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160b8a6:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b8aa:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b8ae:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b8b2:	eb e9                	jmp    804160b89d <vprintfmt+0x50a>
        putch('0', putdat);
  804160b8b4:	4c 89 fe             	mov    %r15,%rsi
  804160b8b7:	bf 30 00 00 00       	mov    $0x30,%edi
  804160b8bc:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  804160b8bf:	4c 89 fe             	mov    %r15,%rsi
  804160b8c2:	bf 78 00 00 00       	mov    $0x78,%edi
  804160b8c7:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160b8ca:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b8cd:	83 f8 2f             	cmp    $0x2f,%eax
  804160b8d0:	77 34                	ja     804160b906 <vprintfmt+0x573>
  804160b8d2:	89 c2                	mov    %eax,%edx
  804160b8d4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b8d8:	83 c0 08             	add    $0x8,%eax
  804160b8db:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b8de:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160b8e1:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  804160b8e6:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  804160b8eb:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  804160b8ef:	4c 89 fe             	mov    %r15,%rsi
  804160b8f2:	4c 89 ef             	mov    %r13,%rdi
  804160b8f5:	48 b8 69 b2 60 41 80 	movabs $0x804160b269,%rax
  804160b8fc:	00 00 00 
  804160b8ff:	ff d0                	callq  *%rax
        break;
  804160b901:	e9 b7 fa ff ff       	jmpq   804160b3bd <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  804160b906:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b90a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b90e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b912:	eb ca                	jmp    804160b8de <vprintfmt+0x54b>
  if (lflag >= 2)
  804160b914:	83 f9 01             	cmp    $0x1,%ecx
  804160b917:	7f 22                	jg     804160b93b <vprintfmt+0x5a8>
  else if (lflag)
  804160b919:	85 c9                	test   %ecx,%ecx
  804160b91b:	74 58                	je     804160b975 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  804160b91d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b920:	83 f8 2f             	cmp    $0x2f,%eax
  804160b923:	77 42                	ja     804160b967 <vprintfmt+0x5d4>
  804160b925:	89 c2                	mov    %eax,%edx
  804160b927:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b92b:	83 c0 08             	add    $0x8,%eax
  804160b92e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b931:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160b934:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160b939:	eb ab                	jmp    804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160b93b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b93e:	83 f8 2f             	cmp    $0x2f,%eax
  804160b941:	77 16                	ja     804160b959 <vprintfmt+0x5c6>
  804160b943:	89 c2                	mov    %eax,%edx
  804160b945:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b949:	83 c0 08             	add    $0x8,%eax
  804160b94c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b94f:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  804160b952:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160b957:	eb 8d                	jmp    804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160b959:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b95d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b961:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b965:	eb e8                	jmp    804160b94f <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  804160b967:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b96b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b96f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b973:	eb bc                	jmp    804160b931 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  804160b975:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160b978:	83 f8 2f             	cmp    $0x2f,%eax
  804160b97b:	77 18                	ja     804160b995 <vprintfmt+0x602>
  804160b97d:	89 c2                	mov    %eax,%edx
  804160b97f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160b983:	83 c0 08             	add    $0x8,%eax
  804160b986:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160b989:	8b 12                	mov    (%rdx),%edx
        base = 16;
  804160b98b:	b9 10 00 00 00       	mov    $0x10,%ecx
  804160b990:	e9 51 ff ff ff       	jmpq   804160b8e6 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  804160b995:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160b999:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160b99d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160b9a1:	eb e6                	jmp    804160b989 <vprintfmt+0x5f6>
        putch(ch, putdat);
  804160b9a3:	4c 89 fe             	mov    %r15,%rsi
  804160b9a6:	bf 25 00 00 00       	mov    $0x25,%edi
  804160b9ab:	41 ff d5             	callq  *%r13
        break;
  804160b9ae:	e9 0a fa ff ff       	jmpq   804160b3bd <vprintfmt+0x2a>
        putch('%', putdat);
  804160b9b3:	4c 89 fe             	mov    %r15,%rsi
  804160b9b6:	bf 25 00 00 00       	mov    $0x25,%edi
  804160b9bb:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  804160b9be:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  804160b9c2:	0f 84 15 fa ff ff    	je     804160b3dd <vprintfmt+0x4a>
  804160b9c8:	49 89 de             	mov    %rbx,%r14
  804160b9cb:	49 83 ee 01          	sub    $0x1,%r14
  804160b9cf:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  804160b9d4:	75 f5                	jne    804160b9cb <vprintfmt+0x638>
  804160b9d6:	e9 e2 f9 ff ff       	jmpq   804160b3bd <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  804160b9db:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  804160b9df:	74 06                	je     804160b9e7 <vprintfmt+0x654>
  804160b9e1:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160b9e5:	7f 21                	jg     804160ba08 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160b9e7:	bf 28 00 00 00       	mov    $0x28,%edi
  804160b9ec:	48 bb c3 e5 60 41 80 	movabs $0x804160e5c3,%rbx
  804160b9f3:	00 00 00 
  804160b9f6:	b8 28 00 00 00       	mov    $0x28,%eax
  804160b9fb:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160b9ff:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160ba03:	e9 82 fc ff ff       	jmpq   804160b68a <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160ba08:	49 63 f4             	movslq %r12d,%rsi
  804160ba0b:	48 bf c2 e5 60 41 80 	movabs $0x804160e5c2,%rdi
  804160ba12:	00 00 00 
  804160ba15:	48 b8 a4 bc 60 41 80 	movabs $0x804160bca4,%rax
  804160ba1c:	00 00 00 
  804160ba1f:	ff d0                	callq  *%rax
  804160ba21:	29 45 ac             	sub    %eax,-0x54(%rbp)
  804160ba24:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  804160ba27:	48 be c2 e5 60 41 80 	movabs $0x804160e5c2,%rsi
  804160ba2e:	00 00 00 
  804160ba31:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  804160ba35:	85 c0                	test   %eax,%eax
  804160ba37:	0f 8f f2 fb ff ff    	jg     804160b62f <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160ba3d:	48 bb c3 e5 60 41 80 	movabs $0x804160e5c3,%rbx
  804160ba44:	00 00 00 
  804160ba47:	b8 28 00 00 00       	mov    $0x28,%eax
  804160ba4c:	bf 28 00 00 00       	mov    $0x28,%edi
  804160ba51:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  804160ba55:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160ba59:	e9 2c fc ff ff       	jmpq   804160b68a <vprintfmt+0x2f7>
}
  804160ba5e:	48 83 c4 48          	add    $0x48,%rsp
  804160ba62:	5b                   	pop    %rbx
  804160ba63:	41 5c                	pop    %r12
  804160ba65:	41 5d                	pop    %r13
  804160ba67:	41 5e                	pop    %r14
  804160ba69:	41 5f                	pop    %r15
  804160ba6b:	5d                   	pop    %rbp
  804160ba6c:	c3                   	retq   

000000804160ba6d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  804160ba6d:	55                   	push   %rbp
  804160ba6e:	48 89 e5             	mov    %rsp,%rbp
  804160ba71:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  804160ba75:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  804160ba79:	48 63 c6             	movslq %esi,%rax
  804160ba7c:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  804160ba81:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  804160ba85:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  804160ba8c:	48 85 ff             	test   %rdi,%rdi
  804160ba8f:	74 2a                	je     804160babb <vsnprintf+0x4e>
  804160ba91:	85 f6                	test   %esi,%esi
  804160ba93:	7e 26                	jle    804160babb <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  804160ba95:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  804160ba99:	48 bf f5 b2 60 41 80 	movabs $0x804160b2f5,%rdi
  804160baa0:	00 00 00 
  804160baa3:	48 b8 93 b3 60 41 80 	movabs $0x804160b393,%rax
  804160baaa:	00 00 00 
  804160baad:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  804160baaf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  804160bab3:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  804160bab6:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  804160bab9:	c9                   	leaveq 
  804160baba:	c3                   	retq   
    return -E_INVAL;
  804160babb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160bac0:	eb f7                	jmp    804160bab9 <vsnprintf+0x4c>

000000804160bac2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  804160bac2:	55                   	push   %rbp
  804160bac3:	48 89 e5             	mov    %rsp,%rbp
  804160bac6:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160bacd:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160bad4:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  804160badb:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160bae2:	84 c0                	test   %al,%al
  804160bae4:	74 20                	je     804160bb06 <snprintf+0x44>
  804160bae6:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160baea:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  804160baee:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160baf2:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160baf6:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160bafa:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  804160bafe:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160bb02:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  804160bb06:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  804160bb0d:	00 00 00 
  804160bb10:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160bb17:	00 00 00 
  804160bb1a:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160bb1e:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160bb25:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160bb2c:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  804160bb33:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160bb3a:	48 b8 6d ba 60 41 80 	movabs $0x804160ba6d,%rax
  804160bb41:	00 00 00 
  804160bb44:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  804160bb46:	c9                   	leaveq 
  804160bb47:	c3                   	retq   

000000804160bb48 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  804160bb48:	55                   	push   %rbp
  804160bb49:	48 89 e5             	mov    %rsp,%rbp
  804160bb4c:	41 57                	push   %r15
  804160bb4e:	41 56                	push   %r14
  804160bb50:	41 55                	push   %r13
  804160bb52:	41 54                	push   %r12
  804160bb54:	53                   	push   %rbx
  804160bb55:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  804160bb59:	48 85 ff             	test   %rdi,%rdi
  804160bb5c:	74 1e                	je     804160bb7c <readline+0x34>
    cprintf("%s", prompt);
  804160bb5e:	48 89 fe             	mov    %rdi,%rsi
  804160bb61:	48 bf cb c9 60 41 80 	movabs $0x804160c9cb,%rdi
  804160bb68:	00 00 00 
  804160bb6b:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bb70:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160bb77:	00 00 00 
  804160bb7a:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  804160bb7c:	bf 00 00 00 00       	mov    $0x0,%edi
  804160bb81:	48 b8 89 0d 60 41 80 	movabs $0x8041600d89,%rax
  804160bb88:	00 00 00 
  804160bb8b:	ff d0                	callq  *%rax
  804160bb8d:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  804160bb90:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  804160bb96:	49 bd 69 0d 60 41 80 	movabs $0x8041600d69,%r13
  804160bb9d:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  804160bba0:	49 bf 57 0d 60 41 80 	movabs $0x8041600d57,%r15
  804160bba7:	00 00 00 
  804160bbaa:	eb 3f                	jmp    804160bbeb <readline+0xa3>
      cprintf("read error: %i\n", c);
  804160bbac:	89 c6                	mov    %eax,%esi
  804160bbae:	48 bf 70 e9 60 41 80 	movabs $0x804160e970,%rdi
  804160bbb5:	00 00 00 
  804160bbb8:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bbbd:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160bbc4:	00 00 00 
  804160bbc7:	ff d2                	callq  *%rdx
      return NULL;
  804160bbc9:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  804160bbce:	48 83 c4 08          	add    $0x8,%rsp
  804160bbd2:	5b                   	pop    %rbx
  804160bbd3:	41 5c                	pop    %r12
  804160bbd5:	41 5d                	pop    %r13
  804160bbd7:	41 5e                	pop    %r14
  804160bbd9:	41 5f                	pop    %r15
  804160bbdb:	5d                   	pop    %rbp
  804160bbdc:	c3                   	retq   
      if (i > 0) {
  804160bbdd:	45 85 e4             	test   %r12d,%r12d
  804160bbe0:	7e 09                	jle    804160bbeb <readline+0xa3>
        if (echoing) {
  804160bbe2:	45 85 f6             	test   %r14d,%r14d
  804160bbe5:	75 41                	jne    804160bc28 <readline+0xe0>
        i--;
  804160bbe7:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  804160bbeb:	41 ff d5             	callq  *%r13
  804160bbee:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  804160bbf0:	85 c0                	test   %eax,%eax
  804160bbf2:	78 b8                	js     804160bbac <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  804160bbf4:	83 f8 08             	cmp    $0x8,%eax
  804160bbf7:	74 e4                	je     804160bbdd <readline+0x95>
  804160bbf9:	83 f8 7f             	cmp    $0x7f,%eax
  804160bbfc:	74 df                	je     804160bbdd <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  804160bbfe:	83 f8 1f             	cmp    $0x1f,%eax
  804160bc01:	7e 46                	jle    804160bc49 <readline+0x101>
  804160bc03:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  804160bc0a:	7f 3d                	jg     804160bc49 <readline+0x101>
      if (echoing)
  804160bc0c:	45 85 f6             	test   %r14d,%r14d
  804160bc0f:	75 31                	jne    804160bc42 <readline+0xfa>
      buf[i++] = c;
  804160bc11:	49 63 c4             	movslq %r12d,%rax
  804160bc14:	48 b9 20 57 70 41 80 	movabs $0x8041705720,%rcx
  804160bc1b:	00 00 00 
  804160bc1e:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  804160bc21:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  804160bc26:	eb c3                	jmp    804160bbeb <readline+0xa3>
          cputchar('\b');
  804160bc28:	bf 08 00 00 00       	mov    $0x8,%edi
  804160bc2d:	41 ff d7             	callq  *%r15
          cputchar(' ');
  804160bc30:	bf 20 00 00 00       	mov    $0x20,%edi
  804160bc35:	41 ff d7             	callq  *%r15
          cputchar('\b');
  804160bc38:	bf 08 00 00 00       	mov    $0x8,%edi
  804160bc3d:	41 ff d7             	callq  *%r15
  804160bc40:	eb a5                	jmp    804160bbe7 <readline+0x9f>
        cputchar(c);
  804160bc42:	89 c7                	mov    %eax,%edi
  804160bc44:	41 ff d7             	callq  *%r15
  804160bc47:	eb c8                	jmp    804160bc11 <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  804160bc49:	83 fb 0a             	cmp    $0xa,%ebx
  804160bc4c:	74 05                	je     804160bc53 <readline+0x10b>
  804160bc4e:	83 fb 0d             	cmp    $0xd,%ebx
  804160bc51:	75 98                	jne    804160bbeb <readline+0xa3>
      if (echoing)
  804160bc53:	45 85 f6             	test   %r14d,%r14d
  804160bc56:	75 17                	jne    804160bc6f <readline+0x127>
      buf[i] = 0;
  804160bc58:	48 b8 20 57 70 41 80 	movabs $0x8041705720,%rax
  804160bc5f:	00 00 00 
  804160bc62:	4d 63 e4             	movslq %r12d,%r12
  804160bc65:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  804160bc6a:	e9 5f ff ff ff       	jmpq   804160bbce <readline+0x86>
        cputchar('\n');
  804160bc6f:	bf 0a 00 00 00       	mov    $0xa,%edi
  804160bc74:	48 b8 57 0d 60 41 80 	movabs $0x8041600d57,%rax
  804160bc7b:	00 00 00 
  804160bc7e:	ff d0                	callq  *%rax
  804160bc80:	eb d6                	jmp    804160bc58 <readline+0x110>

000000804160bc82 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  804160bc82:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160bc85:	74 17                	je     804160bc9e <strlen+0x1c>
  804160bc87:	48 89 fa             	mov    %rdi,%rdx
  804160bc8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160bc8f:	29 f9                	sub    %edi,%ecx
    n++;
  804160bc91:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  804160bc94:	48 83 c2 01          	add    $0x1,%rdx
  804160bc98:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160bc9b:	75 f4                	jne    804160bc91 <strlen+0xf>
  804160bc9d:	c3                   	retq   
  804160bc9e:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160bca3:	c3                   	retq   

000000804160bca4 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160bca4:	48 85 f6             	test   %rsi,%rsi
  804160bca7:	74 24                	je     804160bccd <strnlen+0x29>
  804160bca9:	80 3f 00             	cmpb   $0x0,(%rdi)
  804160bcac:	74 25                	je     804160bcd3 <strnlen+0x2f>
  804160bcae:	48 01 fe             	add    %rdi,%rsi
  804160bcb1:	48 89 fa             	mov    %rdi,%rdx
  804160bcb4:	b9 01 00 00 00       	mov    $0x1,%ecx
  804160bcb9:	29 f9                	sub    %edi,%ecx
    n++;
  804160bcbb:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  804160bcbe:	48 83 c2 01          	add    $0x1,%rdx
  804160bcc2:	48 39 f2             	cmp    %rsi,%rdx
  804160bcc5:	74 11                	je     804160bcd8 <strnlen+0x34>
  804160bcc7:	80 3a 00             	cmpb   $0x0,(%rdx)
  804160bcca:	75 ef                	jne    804160bcbb <strnlen+0x17>
  804160bccc:	c3                   	retq   
  804160bccd:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bcd2:	c3                   	retq   
  804160bcd3:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  804160bcd8:	c3                   	retq   

000000804160bcd9 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  804160bcd9:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  804160bcdc:	ba 00 00 00 00       	mov    $0x0,%edx
  804160bce1:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  804160bce5:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  804160bce8:	48 83 c2 01          	add    $0x1,%rdx
  804160bcec:	84 c9                	test   %cl,%cl
  804160bcee:	75 f1                	jne    804160bce1 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  804160bcf0:	c3                   	retq   

000000804160bcf1 <strcat>:

char *
strcat(char *dst, const char *src) {
  804160bcf1:	55                   	push   %rbp
  804160bcf2:	48 89 e5             	mov    %rsp,%rbp
  804160bcf5:	41 54                	push   %r12
  804160bcf7:	53                   	push   %rbx
  804160bcf8:	48 89 fb             	mov    %rdi,%rbx
  804160bcfb:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  804160bcfe:	48 b8 82 bc 60 41 80 	movabs $0x804160bc82,%rax
  804160bd05:	00 00 00 
  804160bd08:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  804160bd0a:	48 63 f8             	movslq %eax,%rdi
  804160bd0d:	48 01 df             	add    %rbx,%rdi
  804160bd10:	4c 89 e6             	mov    %r12,%rsi
  804160bd13:	48 b8 d9 bc 60 41 80 	movabs $0x804160bcd9,%rax
  804160bd1a:	00 00 00 
  804160bd1d:	ff d0                	callq  *%rax
  return dst;
}
  804160bd1f:	48 89 d8             	mov    %rbx,%rax
  804160bd22:	5b                   	pop    %rbx
  804160bd23:	41 5c                	pop    %r12
  804160bd25:	5d                   	pop    %rbp
  804160bd26:	c3                   	retq   

000000804160bd27 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  804160bd27:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  804160bd2a:	48 85 d2             	test   %rdx,%rdx
  804160bd2d:	74 1f                	je     804160bd4e <strncpy+0x27>
  804160bd2f:	48 01 fa             	add    %rdi,%rdx
  804160bd32:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  804160bd35:	48 83 c1 01          	add    $0x1,%rcx
  804160bd39:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160bd3d:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  804160bd41:	41 80 f8 01          	cmp    $0x1,%r8b
  804160bd45:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  804160bd49:	48 39 ca             	cmp    %rcx,%rdx
  804160bd4c:	75 e7                	jne    804160bd35 <strncpy+0xe>
  }
  return ret;
}
  804160bd4e:	c3                   	retq   

000000804160bd4f <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  804160bd4f:	48 89 f8             	mov    %rdi,%rax
  804160bd52:	48 85 d2             	test   %rdx,%rdx
  804160bd55:	74 36                	je     804160bd8d <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  804160bd57:	48 83 fa 01          	cmp    $0x1,%rdx
  804160bd5b:	74 2d                	je     804160bd8a <strlcpy+0x3b>
  804160bd5d:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160bd61:	45 84 c0             	test   %r8b,%r8b
  804160bd64:	74 24                	je     804160bd8a <strlcpy+0x3b>
  804160bd66:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  804160bd6a:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  804160bd6f:	48 83 c0 01          	add    $0x1,%rax
  804160bd73:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  804160bd77:	48 39 d1             	cmp    %rdx,%rcx
  804160bd7a:	74 0e                	je     804160bd8a <strlcpy+0x3b>
  804160bd7c:	48 83 c1 01          	add    $0x1,%rcx
  804160bd80:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  804160bd85:	45 84 c0             	test   %r8b,%r8b
  804160bd88:	75 e5                	jne    804160bd6f <strlcpy+0x20>
    *dst = '\0';
  804160bd8a:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  804160bd8d:	48 29 f8             	sub    %rdi,%rax
}
  804160bd90:	c3                   	retq   

000000804160bd91 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  804160bd91:	0f b6 07             	movzbl (%rdi),%eax
  804160bd94:	84 c0                	test   %al,%al
  804160bd96:	74 17                	je     804160bdaf <strcmp+0x1e>
  804160bd98:	3a 06                	cmp    (%rsi),%al
  804160bd9a:	75 13                	jne    804160bdaf <strcmp+0x1e>
    p++, q++;
  804160bd9c:	48 83 c7 01          	add    $0x1,%rdi
  804160bda0:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  804160bda4:	0f b6 07             	movzbl (%rdi),%eax
  804160bda7:	84 c0                	test   %al,%al
  804160bda9:	74 04                	je     804160bdaf <strcmp+0x1e>
  804160bdab:	3a 06                	cmp    (%rsi),%al
  804160bdad:	74 ed                	je     804160bd9c <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  804160bdaf:	0f b6 c0             	movzbl %al,%eax
  804160bdb2:	0f b6 16             	movzbl (%rsi),%edx
  804160bdb5:	29 d0                	sub    %edx,%eax
}
  804160bdb7:	c3                   	retq   

000000804160bdb8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  804160bdb8:	48 85 d2             	test   %rdx,%rdx
  804160bdbb:	74 2f                	je     804160bdec <strncmp+0x34>
  804160bdbd:	0f b6 07             	movzbl (%rdi),%eax
  804160bdc0:	84 c0                	test   %al,%al
  804160bdc2:	74 1f                	je     804160bde3 <strncmp+0x2b>
  804160bdc4:	3a 06                	cmp    (%rsi),%al
  804160bdc6:	75 1b                	jne    804160bde3 <strncmp+0x2b>
  804160bdc8:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  804160bdcb:	48 83 c7 01          	add    $0x1,%rdi
  804160bdcf:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  804160bdd3:	48 39 d7             	cmp    %rdx,%rdi
  804160bdd6:	74 1a                	je     804160bdf2 <strncmp+0x3a>
  804160bdd8:	0f b6 07             	movzbl (%rdi),%eax
  804160bddb:	84 c0                	test   %al,%al
  804160bddd:	74 04                	je     804160bde3 <strncmp+0x2b>
  804160bddf:	3a 06                	cmp    (%rsi),%al
  804160bde1:	74 e8                	je     804160bdcb <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  804160bde3:	0f b6 07             	movzbl (%rdi),%eax
  804160bde6:	0f b6 16             	movzbl (%rsi),%edx
  804160bde9:	29 d0                	sub    %edx,%eax
}
  804160bdeb:	c3                   	retq   
    return 0;
  804160bdec:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bdf1:	c3                   	retq   
  804160bdf2:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bdf7:	c3                   	retq   

000000804160bdf8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  804160bdf8:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  804160bdfa:	0f b6 07             	movzbl (%rdi),%eax
  804160bdfd:	84 c0                	test   %al,%al
  804160bdff:	74 1e                	je     804160be1f <strchr+0x27>
    if (*s == c)
  804160be01:	40 38 c6             	cmp    %al,%sil
  804160be04:	74 1f                	je     804160be25 <strchr+0x2d>
  for (; *s; s++)
  804160be06:	48 83 c7 01          	add    $0x1,%rdi
  804160be0a:	0f b6 07             	movzbl (%rdi),%eax
  804160be0d:	84 c0                	test   %al,%al
  804160be0f:	74 08                	je     804160be19 <strchr+0x21>
    if (*s == c)
  804160be11:	38 d0                	cmp    %dl,%al
  804160be13:	75 f1                	jne    804160be06 <strchr+0xe>
  for (; *s; s++)
  804160be15:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  804160be18:	c3                   	retq   
  return 0;
  804160be19:	b8 00 00 00 00       	mov    $0x0,%eax
  804160be1e:	c3                   	retq   
  804160be1f:	b8 00 00 00 00       	mov    $0x0,%eax
  804160be24:	c3                   	retq   
    if (*s == c)
  804160be25:	48 89 f8             	mov    %rdi,%rax
  804160be28:	c3                   	retq   

000000804160be29 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  804160be29:	48 89 f8             	mov    %rdi,%rax
  804160be2c:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  804160be2e:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  804160be31:	40 38 f2             	cmp    %sil,%dl
  804160be34:	74 13                	je     804160be49 <strfind+0x20>
  804160be36:	84 d2                	test   %dl,%dl
  804160be38:	74 0f                	je     804160be49 <strfind+0x20>
  for (; *s; s++)
  804160be3a:	48 83 c0 01          	add    $0x1,%rax
  804160be3e:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  804160be41:	38 ca                	cmp    %cl,%dl
  804160be43:	74 04                	je     804160be49 <strfind+0x20>
  804160be45:	84 d2                	test   %dl,%dl
  804160be47:	75 f1                	jne    804160be3a <strfind+0x11>
      break;
  return (char *)s;
}
  804160be49:	c3                   	retq   

000000804160be4a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  804160be4a:	48 85 d2             	test   %rdx,%rdx
  804160be4d:	74 3a                	je     804160be89 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160be4f:	48 89 f8             	mov    %rdi,%rax
  804160be52:	48 09 d0             	or     %rdx,%rax
  804160be55:	a8 03                	test   $0x3,%al
  804160be57:	75 28                	jne    804160be81 <memset+0x37>
    uint32_t k = c & 0xFFU;
  804160be59:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  804160be5d:	89 f0                	mov    %esi,%eax
  804160be5f:	c1 e0 08             	shl    $0x8,%eax
  804160be62:	89 f1                	mov    %esi,%ecx
  804160be64:	c1 e1 18             	shl    $0x18,%ecx
  804160be67:	41 89 f0             	mov    %esi,%r8d
  804160be6a:	41 c1 e0 10          	shl    $0x10,%r8d
  804160be6e:	44 09 c1             	or     %r8d,%ecx
  804160be71:	09 ce                	or     %ecx,%esi
  804160be73:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  804160be75:	48 c1 ea 02          	shr    $0x2,%rdx
  804160be79:	48 89 d1             	mov    %rdx,%rcx
  804160be7c:	fc                   	cld    
  804160be7d:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  804160be7f:	eb 08                	jmp    804160be89 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  804160be81:	89 f0                	mov    %esi,%eax
  804160be83:	48 89 d1             	mov    %rdx,%rcx
  804160be86:	fc                   	cld    
  804160be87:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  804160be89:	48 89 f8             	mov    %rdi,%rax
  804160be8c:	c3                   	retq   

000000804160be8d <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  804160be8d:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  804160be90:	48 39 fe             	cmp    %rdi,%rsi
  804160be93:	73 40                	jae    804160bed5 <memmove+0x48>
  804160be95:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  804160be99:	48 39 f9             	cmp    %rdi,%rcx
  804160be9c:	76 37                	jbe    804160bed5 <memmove+0x48>
    s += n;
    d += n;
  804160be9e:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160bea2:	48 89 fe             	mov    %rdi,%rsi
  804160bea5:	48 09 d6             	or     %rdx,%rsi
  804160bea8:	48 09 ce             	or     %rcx,%rsi
  804160beab:	40 f6 c6 03          	test   $0x3,%sil
  804160beaf:	75 14                	jne    804160bec5 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  804160beb1:	48 83 ef 04          	sub    $0x4,%rdi
  804160beb5:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  804160beb9:	48 c1 ea 02          	shr    $0x2,%rdx
  804160bebd:	48 89 d1             	mov    %rdx,%rcx
  804160bec0:	fd                   	std    
  804160bec1:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160bec3:	eb 0e                	jmp    804160bed3 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  804160bec5:	48 83 ef 01          	sub    $0x1,%rdi
  804160bec9:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  804160becd:	48 89 d1             	mov    %rdx,%rcx
  804160bed0:	fd                   	std    
  804160bed1:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  804160bed3:	fc                   	cld    
  804160bed4:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160bed5:	48 89 c1             	mov    %rax,%rcx
  804160bed8:	48 09 d1             	or     %rdx,%rcx
  804160bedb:	48 09 f1             	or     %rsi,%rcx
  804160bede:	f6 c1 03             	test   $0x3,%cl
  804160bee1:	75 0e                	jne    804160bef1 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  804160bee3:	48 c1 ea 02          	shr    $0x2,%rdx
  804160bee7:	48 89 d1             	mov    %rdx,%rcx
  804160beea:	48 89 c7             	mov    %rax,%rdi
  804160beed:	fc                   	cld    
  804160beee:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160bef0:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  804160bef1:	48 89 c7             	mov    %rax,%rdi
  804160bef4:	48 89 d1             	mov    %rdx,%rcx
  804160bef7:	fc                   	cld    
  804160bef8:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  804160befa:	c3                   	retq   

000000804160befb <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  804160befb:	55                   	push   %rbp
  804160befc:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  804160beff:	48 b8 8d be 60 41 80 	movabs $0x804160be8d,%rax
  804160bf06:	00 00 00 
  804160bf09:	ff d0                	callq  *%rax
}
  804160bf0b:	5d                   	pop    %rbp
  804160bf0c:	c3                   	retq   

000000804160bf0d <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  804160bf0d:	55                   	push   %rbp
  804160bf0e:	48 89 e5             	mov    %rsp,%rbp
  804160bf11:	41 57                	push   %r15
  804160bf13:	41 56                	push   %r14
  804160bf15:	41 55                	push   %r13
  804160bf17:	41 54                	push   %r12
  804160bf19:	53                   	push   %rbx
  804160bf1a:	48 83 ec 08          	sub    $0x8,%rsp
  804160bf1e:	49 89 fe             	mov    %rdi,%r14
  804160bf21:	49 89 f7             	mov    %rsi,%r15
  804160bf24:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  804160bf27:	48 89 f7             	mov    %rsi,%rdi
  804160bf2a:	48 b8 82 bc 60 41 80 	movabs $0x804160bc82,%rax
  804160bf31:	00 00 00 
  804160bf34:	ff d0                	callq  *%rax
  804160bf36:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  804160bf39:	4c 89 ee             	mov    %r13,%rsi
  804160bf3c:	4c 89 f7             	mov    %r14,%rdi
  804160bf3f:	48 b8 a4 bc 60 41 80 	movabs $0x804160bca4,%rax
  804160bf46:	00 00 00 
  804160bf49:	ff d0                	callq  *%rax
  804160bf4b:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  804160bf4e:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  804160bf52:	4d 39 e5             	cmp    %r12,%r13
  804160bf55:	74 26                	je     804160bf7d <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  804160bf57:	4c 89 e8             	mov    %r13,%rax
  804160bf5a:	4c 29 e0             	sub    %r12,%rax
  804160bf5d:	48 39 d8             	cmp    %rbx,%rax
  804160bf60:	76 2a                	jbe    804160bf8c <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  804160bf62:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  804160bf66:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160bf6a:	4c 89 fe             	mov    %r15,%rsi
  804160bf6d:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160bf74:	00 00 00 
  804160bf77:	ff d0                	callq  *%rax
  return dstlen + srclen;
  804160bf79:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  804160bf7d:	48 83 c4 08          	add    $0x8,%rsp
  804160bf81:	5b                   	pop    %rbx
  804160bf82:	41 5c                	pop    %r12
  804160bf84:	41 5d                	pop    %r13
  804160bf86:	41 5e                	pop    %r14
  804160bf88:	41 5f                	pop    %r15
  804160bf8a:	5d                   	pop    %rbp
  804160bf8b:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  804160bf8c:	49 83 ed 01          	sub    $0x1,%r13
  804160bf90:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160bf94:	4c 89 ea             	mov    %r13,%rdx
  804160bf97:	4c 89 fe             	mov    %r15,%rsi
  804160bf9a:	48 b8 fb be 60 41 80 	movabs $0x804160befb,%rax
  804160bfa1:	00 00 00 
  804160bfa4:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  804160bfa6:	4d 01 ee             	add    %r13,%r14
  804160bfa9:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  804160bfae:	eb c9                	jmp    804160bf79 <strlcat+0x6c>

000000804160bfb0 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  804160bfb0:	48 85 d2             	test   %rdx,%rdx
  804160bfb3:	74 3a                	je     804160bfef <memcmp+0x3f>
    if (*s1 != *s2)
  804160bfb5:	0f b6 0f             	movzbl (%rdi),%ecx
  804160bfb8:	44 0f b6 06          	movzbl (%rsi),%r8d
  804160bfbc:	44 38 c1             	cmp    %r8b,%cl
  804160bfbf:	75 1d                	jne    804160bfde <memcmp+0x2e>
  804160bfc1:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  804160bfc6:	48 39 d0             	cmp    %rdx,%rax
  804160bfc9:	74 1e                	je     804160bfe9 <memcmp+0x39>
    if (*s1 != *s2)
  804160bfcb:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  804160bfcf:	48 83 c0 01          	add    $0x1,%rax
  804160bfd3:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  804160bfd9:	44 38 c1             	cmp    %r8b,%cl
  804160bfdc:	74 e8                	je     804160bfc6 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  804160bfde:	0f b6 c1             	movzbl %cl,%eax
  804160bfe1:	45 0f b6 c0          	movzbl %r8b,%r8d
  804160bfe5:	44 29 c0             	sub    %r8d,%eax
  804160bfe8:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  804160bfe9:	b8 00 00 00 00       	mov    $0x0,%eax
  804160bfee:	c3                   	retq   
  804160bfef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160bff4:	c3                   	retq   

000000804160bff5 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  804160bff5:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  804160bff9:	48 39 c7             	cmp    %rax,%rdi
  804160bffc:	73 19                	jae    804160c017 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160bffe:	89 f2                	mov    %esi,%edx
  804160c000:	40 38 37             	cmp    %sil,(%rdi)
  804160c003:	74 16                	je     804160c01b <memfind+0x26>
  for (; s < ends; s++)
  804160c005:	48 83 c7 01          	add    $0x1,%rdi
  804160c009:	48 39 f8             	cmp    %rdi,%rax
  804160c00c:	74 08                	je     804160c016 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c00e:	38 17                	cmp    %dl,(%rdi)
  804160c010:	75 f3                	jne    804160c005 <memfind+0x10>
  for (; s < ends; s++)
  804160c012:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  804160c015:	c3                   	retq   
  804160c016:	c3                   	retq   
  for (; s < ends; s++)
  804160c017:	48 89 f8             	mov    %rdi,%rax
  804160c01a:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  804160c01b:	48 89 f8             	mov    %rdi,%rax
  804160c01e:	c3                   	retq   

000000804160c01f <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  804160c01f:	0f b6 07             	movzbl (%rdi),%eax
  804160c022:	3c 20                	cmp    $0x20,%al
  804160c024:	74 04                	je     804160c02a <strtol+0xb>
  804160c026:	3c 09                	cmp    $0x9,%al
  804160c028:	75 0f                	jne    804160c039 <strtol+0x1a>
    s++;
  804160c02a:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  804160c02e:	0f b6 07             	movzbl (%rdi),%eax
  804160c031:	3c 20                	cmp    $0x20,%al
  804160c033:	74 f5                	je     804160c02a <strtol+0xb>
  804160c035:	3c 09                	cmp    $0x9,%al
  804160c037:	74 f1                	je     804160c02a <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  804160c039:	3c 2b                	cmp    $0x2b,%al
  804160c03b:	74 2b                	je     804160c068 <strtol+0x49>
  int neg  = 0;
  804160c03d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  804160c043:	3c 2d                	cmp    $0x2d,%al
  804160c045:	74 2d                	je     804160c074 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160c047:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  804160c04d:	75 0f                	jne    804160c05e <strtol+0x3f>
  804160c04f:	80 3f 30             	cmpb   $0x30,(%rdi)
  804160c052:	74 2c                	je     804160c080 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  804160c054:	85 d2                	test   %edx,%edx
  804160c056:	b8 0a 00 00 00       	mov    $0xa,%eax
  804160c05b:	0f 44 d0             	cmove  %eax,%edx
  804160c05e:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  804160c063:	4c 63 d2             	movslq %edx,%r10
  804160c066:	eb 5c                	jmp    804160c0c4 <strtol+0xa5>
    s++;
  804160c068:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  804160c06c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160c072:	eb d3                	jmp    804160c047 <strtol+0x28>
    s++, neg = 1;
  804160c074:	48 83 c7 01          	add    $0x1,%rdi
  804160c078:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160c07e:	eb c7                	jmp    804160c047 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160c080:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  804160c084:	74 0f                	je     804160c095 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  804160c086:	85 d2                	test   %edx,%edx
  804160c088:	75 d4                	jne    804160c05e <strtol+0x3f>
    s++, base = 8;
  804160c08a:	48 83 c7 01          	add    $0x1,%rdi
  804160c08e:	ba 08 00 00 00       	mov    $0x8,%edx
  804160c093:	eb c9                	jmp    804160c05e <strtol+0x3f>
    s += 2, base = 16;
  804160c095:	48 83 c7 02          	add    $0x2,%rdi
  804160c099:	ba 10 00 00 00       	mov    $0x10,%edx
  804160c09e:	eb be                	jmp    804160c05e <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  804160c0a0:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  804160c0a4:	41 80 f8 19          	cmp    $0x19,%r8b
  804160c0a8:	77 2f                	ja     804160c0d9 <strtol+0xba>
      dig = *s - 'a' + 10;
  804160c0aa:	44 0f be c1          	movsbl %cl,%r8d
  804160c0ae:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  804160c0b2:	39 d1                	cmp    %edx,%ecx
  804160c0b4:	7d 37                	jge    804160c0ed <strtol+0xce>
    s++, val = (val * base) + dig;
  804160c0b6:	48 83 c7 01          	add    $0x1,%rdi
  804160c0ba:	49 0f af c2          	imul   %r10,%rax
  804160c0be:	48 63 c9             	movslq %ecx,%rcx
  804160c0c1:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  804160c0c4:	0f b6 0f             	movzbl (%rdi),%ecx
  804160c0c7:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  804160c0cb:	41 80 f8 09          	cmp    $0x9,%r8b
  804160c0cf:	77 cf                	ja     804160c0a0 <strtol+0x81>
      dig = *s - '0';
  804160c0d1:	0f be c9             	movsbl %cl,%ecx
  804160c0d4:	83 e9 30             	sub    $0x30,%ecx
  804160c0d7:	eb d9                	jmp    804160c0b2 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  804160c0d9:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  804160c0dd:	41 80 f8 19          	cmp    $0x19,%r8b
  804160c0e1:	77 0a                	ja     804160c0ed <strtol+0xce>
      dig = *s - 'A' + 10;
  804160c0e3:	44 0f be c1          	movsbl %cl,%r8d
  804160c0e7:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  804160c0eb:	eb c5                	jmp    804160c0b2 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  804160c0ed:	48 85 f6             	test   %rsi,%rsi
  804160c0f0:	74 03                	je     804160c0f5 <strtol+0xd6>
    *endptr = (char *)s;
  804160c0f2:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  804160c0f5:	48 89 c2             	mov    %rax,%rdx
  804160c0f8:	48 f7 da             	neg    %rdx
  804160c0fb:	45 85 c9             	test   %r9d,%r9d
  804160c0fe:	48 0f 45 c2          	cmovne %rdx,%rax
}
  804160c102:	c3                   	retq   

000000804160c103 <tsc_calibrate>:
  delta /= i * 256 * 1000;
  return delta;
}

uint64_t
tsc_calibrate(void) {
  804160c103:	55                   	push   %rbp
  804160c104:	48 89 e5             	mov    %rsp,%rbp
  804160c107:	41 57                	push   %r15
  804160c109:	41 56                	push   %r14
  804160c10b:	41 55                	push   %r13
  804160c10d:	41 54                	push   %r12
  804160c10f:	53                   	push   %rbx
  804160c110:	48 83 ec 28          	sub    $0x28,%rsp
  static uint64_t cpu_freq;

  if (cpu_freq == 0) {
  804160c114:	48 a1 20 5b 70 41 80 	movabs 0x8041705b20,%rax
  804160c11b:	00 00 00 
  804160c11e:	48 85 c0             	test   %rax,%rax
  804160c121:	0f 85 8c 01 00 00    	jne    804160c2b3 <tsc_calibrate+0x1b0>
    int i;
    for (i = 0; i < TIMES; i++) {
  804160c127:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  __asm __volatile("inb %w1,%0"
  804160c12d:	41 bd 61 00 00 00    	mov    $0x61,%r13d
  __asm __volatile("outb %0,%w1"
  804160c133:	41 bf ff ff ff ff    	mov    $0xffffffff,%r15d
  804160c139:	b9 42 00 00 00       	mov    $0x42,%ecx
  uint64_t tsc = 0;
  804160c13e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160c142:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  804160c146:	eb 35                	jmp    804160c17d <tsc_calibrate+0x7a>
  804160c148:	48 8b 7d c0          	mov    -0x40(%rbp),%rdi
  for (count = 0; count < 50000; count++) {
  804160c14c:	be 00 00 00 00       	mov    $0x0,%esi
  804160c151:	eb 72                	jmp    804160c1c5 <tsc_calibrate+0xc2>
  uint64_t tsc = 0;
  804160c153:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  for (count = 0; count < 50000; count++) {
  804160c157:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160c15d:	e9 c0 00 00 00       	jmpq   804160c222 <tsc_calibrate+0x11f>
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160c162:	41 83 c4 01          	add    $0x1,%r12d
  804160c166:	83 eb 01             	sub    $0x1,%ebx
  804160c169:	41 83 fc 75          	cmp    $0x75,%r12d
  804160c16d:	75 7a                	jne    804160c1e9 <tsc_calibrate+0xe6>
    for (i = 0; i < TIMES; i++) {
  804160c16f:	41 83 c3 01          	add    $0x1,%r11d
  804160c173:	41 83 fb 64          	cmp    $0x64,%r11d
  804160c177:	0f 84 56 01 00 00    	je     804160c2d3 <tsc_calibrate+0x1d0>
  __asm __volatile("inb %w1,%0"
  804160c17d:	44 89 ea             	mov    %r13d,%edx
  804160c180:	ec                   	in     (%dx),%al
  outb(0x61, (inb(0x61) & ~0x02) | 0x01);
  804160c181:	83 e0 fc             	and    $0xfffffffc,%eax
  804160c184:	83 c8 01             	or     $0x1,%eax
  __asm __volatile("outb %0,%w1"
  804160c187:	ee                   	out    %al,(%dx)
  804160c188:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
  804160c18d:	ba 43 00 00 00       	mov    $0x43,%edx
  804160c192:	ee                   	out    %al,(%dx)
  804160c193:	44 89 f8             	mov    %r15d,%eax
  804160c196:	89 ca                	mov    %ecx,%edx
  804160c198:	ee                   	out    %al,(%dx)
  804160c199:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  804160c19a:	ec                   	in     (%dx),%al
  804160c19b:	ec                   	in     (%dx),%al
  804160c19c:	ec                   	in     (%dx),%al
  804160c19d:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c19e:	3c ff                	cmp    $0xff,%al
  804160c1a0:	75 a6                	jne    804160c148 <tsc_calibrate+0x45>
  for (count = 0; count < 50000; count++) {
  804160c1a2:	be 00 00 00 00       	mov    $0x0,%esi
  __asm __volatile("rdtsc"
  804160c1a7:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c1a9:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c1ad:	89 c7                	mov    %eax,%edi
  804160c1af:	48 09 d7             	or     %rdx,%rdi
  804160c1b2:	83 c6 01             	add    $0x1,%esi
  804160c1b5:	81 fe 50 c3 00 00    	cmp    $0xc350,%esi
  804160c1bb:	74 08                	je     804160c1c5 <tsc_calibrate+0xc2>
  __asm __volatile("inb %w1,%0"
  804160c1bd:	89 ca                	mov    %ecx,%edx
  804160c1bf:	ec                   	in     (%dx),%al
  804160c1c0:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c1c1:	3c ff                	cmp    $0xff,%al
  804160c1c3:	74 e2                	je     804160c1a7 <tsc_calibrate+0xa4>
  __asm __volatile("rdtsc"
  804160c1c5:	0f 31                	rdtsc  
  if (pit_expect_msb(0xff, &tsc, &d1)) {
  804160c1c7:	83 fe 05             	cmp    $0x5,%esi
  804160c1ca:	7e a3                	jle    804160c16f <tsc_calibrate+0x6c>
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c1cc:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c1d0:	89 c0                	mov    %eax,%eax
  804160c1d2:	48 09 c2             	or     %rax,%rdx
  804160c1d5:	49 89 d2             	mov    %rdx,%r10
  *deltap = read_tsc() - tsc;
  804160c1d8:	49 89 d6             	mov    %rdx,%r14
  804160c1db:	49 29 fe             	sub    %rdi,%r14
  804160c1de:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
    for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
  804160c1e3:	41 bc 01 00 00 00    	mov    $0x1,%r12d
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160c1e9:	44 88 65 cf          	mov    %r12b,-0x31(%rbp)
  __asm __volatile("inb %w1,%0"
  804160c1ed:	89 ca                	mov    %ecx,%edx
  804160c1ef:	ec                   	in     (%dx),%al
  804160c1f0:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c1f1:	38 c3                	cmp    %al,%bl
  804160c1f3:	0f 85 5a ff ff ff    	jne    804160c153 <tsc_calibrate+0x50>
  for (count = 0; count < 50000; count++) {
  804160c1f9:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  __asm __volatile("rdtsc"
  804160c1ff:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c201:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c205:	89 c0                	mov    %eax,%eax
  804160c207:	48 89 d6             	mov    %rdx,%rsi
  804160c20a:	48 09 c6             	or     %rax,%rsi
  804160c20d:	41 83 c1 01          	add    $0x1,%r9d
  804160c211:	41 81 f9 50 c3 00 00 	cmp    $0xc350,%r9d
  804160c218:	74 08                	je     804160c222 <tsc_calibrate+0x11f>
  __asm __volatile("inb %w1,%0"
  804160c21a:	89 ca                	mov    %ecx,%edx
  804160c21c:	ec                   	in     (%dx),%al
  804160c21d:	ec                   	in     (%dx),%al
    if (!pit_verify_msb(val))
  804160c21e:	38 d8                	cmp    %bl,%al
  804160c220:	74 dd                	je     804160c1ff <tsc_calibrate+0xfc>
  __asm __volatile("rdtsc"
  804160c222:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c224:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c228:	89 c0                	mov    %eax,%eax
  804160c22a:	48 09 c2             	or     %rax,%rdx
  *deltap = read_tsc() - tsc;
  804160c22d:	48 29 f2             	sub    %rsi,%rdx
      if (!pit_expect_msb(0xff - i, &delta, &d2))
  804160c230:	41 83 f9 05          	cmp    $0x5,%r9d
  804160c234:	0f 8e 35 ff ff ff    	jle    804160c16f <tsc_calibrate+0x6c>
      delta -= tsc;
  804160c23a:	48 29 fe             	sub    %rdi,%rsi
      if (d1 + d2 >= delta >> 11)
  804160c23d:	4d 8d 04 16          	lea    (%r14,%rdx,1),%r8
  804160c241:	48 89 f0             	mov    %rsi,%rax
  804160c244:	48 c1 e8 0b          	shr    $0xb,%rax
  804160c248:	49 39 c0             	cmp    %rax,%r8
  804160c24b:	0f 83 11 ff ff ff    	jae    804160c162 <tsc_calibrate+0x5f>
  804160c251:	49 89 d0             	mov    %rdx,%r8
  __asm __volatile("inb %w1,%0"
  804160c254:	89 ca                	mov    %ecx,%edx
  804160c256:	ec                   	in     (%dx),%al
  804160c257:	ec                   	in     (%dx),%al
      if (!pit_verify_msb(0xfe - i))
  804160c258:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  804160c25d:	2a 55 cf             	sub    -0x31(%rbp),%dl
  804160c260:	38 c2                	cmp    %al,%dl
  804160c262:	0f 85 07 ff ff ff    	jne    804160c16f <tsc_calibrate+0x6c>
  delta += (long)(d2 - d1) / 2;
  804160c268:	4c 29 d7             	sub    %r10,%rdi
  804160c26b:	49 01 f8             	add    %rdi,%r8
  804160c26e:	4c 89 c7             	mov    %r8,%rdi
  804160c271:	48 c1 ef 3f          	shr    $0x3f,%rdi
  804160c275:	49 01 f8             	add    %rdi,%r8
  804160c278:	49 d1 f8             	sar    %r8
  804160c27b:	4c 01 c6             	add    %r8,%rsi
  delta *= PIT_TICK_RATE;
  804160c27e:	48 69 f6 de 34 12 00 	imul   $0x1234de,%rsi,%rsi
  delta /= i * 256 * 1000;
  804160c285:	45 69 e4 00 e8 03 00 	imul   $0x3e800,%r12d,%r12d
  804160c28c:	4d 63 e4             	movslq %r12d,%r12
  804160c28f:	48 89 f0             	mov    %rsi,%rax
  804160c292:	ba 00 00 00 00       	mov    $0x0,%edx
  804160c297:	49 f7 f4             	div    %r12
      if ((cpu_freq = quick_pit_calibrate()))
  804160c29a:	4c 39 e6             	cmp    %r12,%rsi
  804160c29d:	0f 82 cc fe ff ff    	jb     804160c16f <tsc_calibrate+0x6c>
  804160c2a3:	48 a3 20 5b 70 41 80 	movabs %rax,0x8041705b20
  804160c2aa:	00 00 00 
        break;
    }
    if (i == TIMES) {
  804160c2ad:	41 83 fb 64          	cmp    $0x64,%r11d
  804160c2b1:	74 20                	je     804160c2d3 <tsc_calibrate+0x1d0>
      cpu_freq = DEFAULT_FREQ;
      cprintf("Can't calibrate pit timer. Using default frequency\n");
    }
  }

  return cpu_freq * 1000;
  804160c2b3:	48 a1 20 5b 70 41 80 	movabs 0x8041705b20,%rax
  804160c2ba:	00 00 00 
  804160c2bd:	48 69 c0 e8 03 00 00 	imul   $0x3e8,%rax,%rax
}
  804160c2c4:	48 83 c4 28          	add    $0x28,%rsp
  804160c2c8:	5b                   	pop    %rbx
  804160c2c9:	41 5c                	pop    %r12
  804160c2cb:	41 5d                	pop    %r13
  804160c2cd:	41 5e                	pop    %r14
  804160c2cf:	41 5f                	pop    %r15
  804160c2d1:	5d                   	pop    %rbp
  804160c2d2:	c3                   	retq   
      cpu_freq = DEFAULT_FREQ;
  804160c2d3:	48 b8 20 5b 70 41 80 	movabs $0x8041705b20,%rax
  804160c2da:	00 00 00 
  804160c2dd:	48 c7 00 a0 25 26 00 	movq   $0x2625a0,(%rax)
      cprintf("Can't calibrate pit timer. Using default frequency\n");
  804160c2e4:	48 bf 80 e9 60 41 80 	movabs $0x804160e980,%rdi
  804160c2eb:	00 00 00 
  804160c2ee:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c2f3:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160c2fa:	00 00 00 
  804160c2fd:	ff d2                	callq  *%rdx
  804160c2ff:	eb b2                	jmp    804160c2b3 <tsc_calibrate+0x1b0>

000000804160c301 <print_time>:

void
print_time(unsigned seconds) {
  804160c301:	55                   	push   %rbp
  804160c302:	48 89 e5             	mov    %rsp,%rbp
  804160c305:	89 fe                	mov    %edi,%esi
  cprintf("%u\n", seconds);
  804160c307:	48 bf b8 e9 60 41 80 	movabs $0x804160e9b8,%rdi
  804160c30e:	00 00 00 
  804160c311:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c316:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160c31d:	00 00 00 
  804160c320:	ff d2                	callq  *%rdx
}
  804160c322:	5d                   	pop    %rbp
  804160c323:	c3                   	retq   

000000804160c324 <print_timer_error>:

void
print_timer_error(void) {
  804160c324:	55                   	push   %rbp
  804160c325:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Timer Error\n");
  804160c328:	48 bf bc e9 60 41 80 	movabs $0x804160e9bc,%rdi
  804160c32f:	00 00 00 
  804160c332:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c337:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160c33e:	00 00 00 
  804160c341:	ff d2                	callq  *%rdx
}
  804160c343:	5d                   	pop    %rbp
  804160c344:	c3                   	retq   

000000804160c345 <timer_start>:
static int timer_id       = -1;
static uint64_t timer     = 0;
static uint64_t freq      = 0;

void
timer_start(const char *name) {
  804160c345:	55                   	push   %rbp
  804160c346:	48 89 e5             	mov    %rsp,%rbp
  804160c349:	41 56                	push   %r14
  804160c34b:	41 55                	push   %r13
  804160c34d:	41 54                	push   %r12
  804160c34f:	53                   	push   %rbx
  804160c350:	49 89 fe             	mov    %rdi,%r14
  (void) timer_id;
  (void) timer;
  // DELETED in LAB 5 end

  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c353:	49 bc 80 5b 70 41 80 	movabs $0x8041705b80,%r12
  804160c35a:	00 00 00 
  804160c35d:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c362:	49 bd 91 bd 60 41 80 	movabs $0x804160bd91,%r13
  804160c369:	00 00 00 
  804160c36c:	eb 0c                	jmp    804160c37a <timer_start+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c36e:	83 c3 01             	add    $0x1,%ebx
  804160c371:	49 83 c4 28          	add    $0x28,%r12
  804160c375:	83 fb 05             	cmp    $0x5,%ebx
  804160c378:	74 61                	je     804160c3db <timer_start+0x96>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c37a:	49 8b 3c 24          	mov    (%r12),%rdi
  804160c37e:	48 85 ff             	test   %rdi,%rdi
  804160c381:	74 eb                	je     804160c36e <timer_start+0x29>
  804160c383:	4c 89 f6             	mov    %r14,%rsi
  804160c386:	41 ff d5             	callq  *%r13
  804160c389:	85 c0                	test   %eax,%eax
  804160c38b:	75 e1                	jne    804160c36e <timer_start+0x29>
      timer_id = i;
  804160c38d:	89 d8                	mov    %ebx,%eax
  804160c38f:	a3 c0 f8 61 41 80 00 	movabs %eax,0x804161f8c0
  804160c396:	00 00 
      timer_started = 1;
  804160c398:	48 b8 38 5b 70 41 80 	movabs $0x8041705b38,%rax
  804160c39f:	00 00 00 
  804160c3a2:	c6 00 01             	movb   $0x1,(%rax)
  __asm __volatile("rdtsc"
  804160c3a5:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c3a7:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c3ab:	89 c0                	mov    %eax,%eax
  804160c3ad:	48 09 d0             	or     %rdx,%rax
  804160c3b0:	48 a3 30 5b 70 41 80 	movabs %rax,0x8041705b30
  804160c3b7:	00 00 00 
      timer = read_tsc();
      freq = timertab[timer_id].get_cpu_freq();
  804160c3ba:	48 63 db             	movslq %ebx,%rbx
  804160c3bd:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160c3c1:	48 b8 80 5b 70 41 80 	movabs $0x8041705b80,%rax
  804160c3c8:	00 00 00 
  804160c3cb:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160c3cf:	48 a3 28 5b 70 41 80 	movabs %rax,0x8041705b28
  804160c3d6:	00 00 00 
      return;
  804160c3d9:	eb 1b                	jmp    804160c3f6 <timer_start+0xb1>
    }
  }

  cprintf("Timer Error\n");
  804160c3db:	48 bf bc e9 60 41 80 	movabs $0x804160e9bc,%rdi
  804160c3e2:	00 00 00 
  804160c3e5:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c3ea:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160c3f1:	00 00 00 
  804160c3f4:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160c3f6:	5b                   	pop    %rbx
  804160c3f7:	41 5c                	pop    %r12
  804160c3f9:	41 5d                	pop    %r13
  804160c3fb:	41 5e                	pop    %r14
  804160c3fd:	5d                   	pop    %rbp
  804160c3fe:	c3                   	retq   

000000804160c3ff <timer_stop>:

void
timer_stop(void) {
  804160c3ff:	55                   	push   %rbp
  804160c400:	48 89 e5             	mov    %rsp,%rbp
  // LAB 5 code
  if (!timer_started || timer_id < 0) {
  804160c403:	48 b8 38 5b 70 41 80 	movabs $0x8041705b38,%rax
  804160c40a:	00 00 00 
  804160c40d:	80 38 00             	cmpb   $0x0,(%rax)
  804160c410:	74 69                	je     804160c47b <timer_stop+0x7c>
  804160c412:	48 b8 c0 f8 61 41 80 	movabs $0x804161f8c0,%rax
  804160c419:	00 00 00 
  804160c41c:	83 38 00             	cmpl   $0x0,(%rax)
  804160c41f:	78 5a                	js     804160c47b <timer_stop+0x7c>
  __asm __volatile("rdtsc"
  804160c421:	0f 31                	rdtsc  
  res = (uint64_t)lo | ((uint64_t)hi << 32);
  804160c423:	48 c1 e2 20          	shl    $0x20,%rdx
  804160c427:	89 c0                	mov    %eax,%eax
  804160c429:	48 09 c2             	or     %rax,%rdx
    print_timer_error();
    return;
  }

  print_time((read_tsc() - timer) / freq);
  804160c42c:	48 b8 30 5b 70 41 80 	movabs $0x8041705b30,%rax
  804160c433:	00 00 00 
  804160c436:	48 2b 10             	sub    (%rax),%rdx
  804160c439:	48 89 d0             	mov    %rdx,%rax
  804160c43c:	48 b9 28 5b 70 41 80 	movabs $0x8041705b28,%rcx
  804160c443:	00 00 00 
  804160c446:	ba 00 00 00 00       	mov    $0x0,%edx
  804160c44b:	48 f7 31             	divq   (%rcx)
  804160c44e:	89 c7                	mov    %eax,%edi
  804160c450:	48 b8 01 c3 60 41 80 	movabs $0x804160c301,%rax
  804160c457:	00 00 00 
  804160c45a:	ff d0                	callq  *%rax

  timer_id = -1;
  804160c45c:	48 b8 c0 f8 61 41 80 	movabs $0x804161f8c0,%rax
  804160c463:	00 00 00 
  804160c466:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%rax)
  timer_started = 0;
  804160c46c:	48 b8 38 5b 70 41 80 	movabs $0x8041705b38,%rax
  804160c473:	00 00 00 
  804160c476:	c6 00 00             	movb   $0x0,(%rax)
  804160c479:	eb 0c                	jmp    804160c487 <timer_stop+0x88>
    print_timer_error();
  804160c47b:	48 b8 24 c3 60 41 80 	movabs $0x804160c324,%rax
  804160c482:	00 00 00 
  804160c485:	ff d0                	callq  *%rax
  // LAB 5 code end
}
  804160c487:	5d                   	pop    %rbp
  804160c488:	c3                   	retq   

000000804160c489 <timer_cpu_frequency>:

void
timer_cpu_frequency(const char *name) {
  804160c489:	55                   	push   %rbp
  804160c48a:	48 89 e5             	mov    %rsp,%rbp
  804160c48d:	41 56                	push   %r14
  804160c48f:	41 55                	push   %r13
  804160c491:	41 54                	push   %r12
  804160c493:	53                   	push   %rbx
  804160c494:	49 89 fe             	mov    %rdi,%r14
  // LAB 5 code
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c497:	49 bc 80 5b 70 41 80 	movabs $0x8041705b80,%r12
  804160c49e:	00 00 00 
  804160c4a1:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c4a6:	49 bd 91 bd 60 41 80 	movabs $0x804160bd91,%r13
  804160c4ad:	00 00 00 
  804160c4b0:	eb 0c                	jmp    804160c4be <timer_cpu_frequency+0x35>
  for (int i = 0; i < MAX_TIMERS; i++) {
  804160c4b2:	83 c3 01             	add    $0x1,%ebx
  804160c4b5:	49 83 c4 28          	add    $0x28,%r12
  804160c4b9:	83 fb 05             	cmp    $0x5,%ebx
  804160c4bc:	74 48                	je     804160c506 <timer_cpu_frequency+0x7d>
    if (timertab[i].timer_name && !strcmp(timertab[i].timer_name, name)) {
  804160c4be:	49 8b 3c 24          	mov    (%r12),%rdi
  804160c4c2:	48 85 ff             	test   %rdi,%rdi
  804160c4c5:	74 eb                	je     804160c4b2 <timer_cpu_frequency+0x29>
  804160c4c7:	4c 89 f6             	mov    %r14,%rsi
  804160c4ca:	41 ff d5             	callq  *%r13
  804160c4cd:	85 c0                	test   %eax,%eax
  804160c4cf:	75 e1                	jne    804160c4b2 <timer_cpu_frequency+0x29>
      cprintf("%lu\n", timertab[i].get_cpu_freq());
  804160c4d1:	48 63 db             	movslq %ebx,%rbx
  804160c4d4:	48 8d 14 9b          	lea    (%rbx,%rbx,4),%rdx
  804160c4d8:	48 b8 80 5b 70 41 80 	movabs $0x8041705b80,%rax
  804160c4df:	00 00 00 
  804160c4e2:	ff 54 d0 10          	callq  *0x10(%rax,%rdx,8)
  804160c4e6:	48 89 c6             	mov    %rax,%rsi
  804160c4e9:	48 bf 09 cd 60 41 80 	movabs $0x804160cd09,%rdi
  804160c4f0:	00 00 00 
  804160c4f3:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c4f8:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160c4ff:	00 00 00 
  804160c502:	ff d2                	callq  *%rdx
      return;
  804160c504:	eb 1b                	jmp    804160c521 <timer_cpu_frequency+0x98>
    }
  }
  cprintf("Timer Error\n");
  804160c506:	48 bf bc e9 60 41 80 	movabs $0x804160e9bc,%rdi
  804160c50d:	00 00 00 
  804160c510:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c515:	48 ba 78 92 60 41 80 	movabs $0x8041609278,%rdx
  804160c51c:	00 00 00 
  804160c51f:	ff d2                	callq  *%rdx
  // LAB 5 code end
}
  804160c521:	5b                   	pop    %rbx
  804160c522:	41 5c                	pop    %r12
  804160c524:	41 5d                	pop    %r13
  804160c526:	41 5e                	pop    %r14
  804160c528:	5d                   	pop    %rbp
  804160c529:	c3                   	retq   

000000804160c52a <efi_call_in_32bit_mode>:
efi_call_in_32bit_mode(uint32_t func,
                       efi_registers *efi_reg,
                       void *stack_contents,
                       size_t stack_contents_size, /* 16-byte multiple */
                       uint32_t *efi_status) {
  if (func == 0) {
  804160c52a:	85 ff                	test   %edi,%edi
  804160c52c:	74 50                	je     804160c57e <efi_call_in_32bit_mode+0x54>
    return -E_INVAL;
  }

  if ((efi_reg == NULL) || (stack_contents == NULL) || (stack_contents_size % 16 != 0)) {
  804160c52e:	48 85 f6             	test   %rsi,%rsi
  804160c531:	74 51                	je     804160c584 <efi_call_in_32bit_mode+0x5a>
  804160c533:	48 85 d2             	test   %rdx,%rdx
  804160c536:	74 4c                	je     804160c584 <efi_call_in_32bit_mode+0x5a>
  804160c538:	f6 c1 0f             	test   $0xf,%cl
  804160c53b:	75 4d                	jne    804160c58a <efi_call_in_32bit_mode+0x60>
                       uint32_t *efi_status) {
  804160c53d:	55                   	push   %rbp
  804160c53e:	48 89 e5             	mov    %rsp,%rbp
  804160c541:	41 54                	push   %r12
  804160c543:	53                   	push   %rbx
  804160c544:	4d 89 c4             	mov    %r8,%r12
  804160c547:	48 89 f3             	mov    %rsi,%rbx
    return -E_INVAL;
  }

  //We need to set up kernel data segments for 32 bit mode
  //before calling asm.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD32));
  804160c54a:	b8 20 00 00 00       	mov    $0x20,%eax
  804160c54f:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD32));
  804160c551:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD32));
  804160c553:	8e d0                	mov    %eax,%ss
  _efi_call_in_32bit_mode_asm(func,
  804160c555:	48 b8 90 c5 60 41 80 	movabs $0x804160c590,%rax
  804160c55c:	00 00 00 
  804160c55f:	ff d0                	callq  *%rax
                              efi_reg,
                              stack_contents,
                              stack_contents_size);
  //Restore 64 bit kernel data segments.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  804160c561:	b8 10 00 00 00       	mov    $0x10,%eax
  804160c566:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  804160c568:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  804160c56a:	8e d0                	mov    %eax,%ss

  *efi_status = (uint32_t)efi_reg->rax;
  804160c56c:	48 8b 43 20          	mov    0x20(%rbx),%rax
  804160c570:	41 89 04 24          	mov    %eax,(%r12)

  return 0;
  804160c574:	b8 00 00 00 00       	mov    $0x0,%eax
}
  804160c579:	5b                   	pop    %rbx
  804160c57a:	41 5c                	pop    %r12
  804160c57c:	5d                   	pop    %rbp
  804160c57d:	c3                   	retq   
    return -E_INVAL;
  804160c57e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160c583:	c3                   	retq   
    return -E_INVAL;
  804160c584:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160c589:	c3                   	retq   
  804160c58a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  804160c58f:	c3                   	retq   

000000804160c590 <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  804160c590:	55                   	push   %rbp
    movq %rsp, %rbp
  804160c591:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  804160c594:	53                   	push   %rbx
	push	%r12
  804160c595:	41 54                	push   %r12
	push	%r13
  804160c597:	41 55                	push   %r13
	push	%r14
  804160c599:	41 56                	push   %r14
	push	%r15
  804160c59b:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  804160c59d:	56                   	push   %rsi
	push	%rcx
  804160c59e:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  804160c59f:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  804160c5a0:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  804160c5a3:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

000000804160c5aa <copyloop>:
  804160c5aa:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  804160c5ae:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  804160c5b2:	49 83 c0 08          	add    $0x8,%r8
  804160c5b6:	49 39 c8             	cmp    %rcx,%r8
  804160c5b9:	75 ef                	jne    804160c5aa <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  804160c5bb:	e8 00 00 00 00       	callq  804160c5c0 <copyloop+0x16>
  804160c5c0:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  804160c5c7:	00 
  804160c5c8:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  804160c5cf:	00 
  804160c5d0:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  804160c5d1:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  804160c5d3:	6a 08                	pushq  $0x8
  804160c5d5:	e8 00 00 00 00       	callq  804160c5da <copyloop+0x30>
  804160c5da:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  804160c5e1:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  804160c5e2:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  804160c5e6:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  804160c5ea:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  804160c5ee:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  804160c5f1:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  804160c5f2:	59                   	pop    %rcx
	pop	%rsi
  804160c5f3:	5e                   	pop    %rsi
	pop	%r15
  804160c5f4:	41 5f                	pop    %r15
	pop	%r14
  804160c5f6:	41 5e                	pop    %r14
	pop	%r13
  804160c5f8:	41 5d                	pop    %r13
	pop	%r12
  804160c5fa:	41 5c                	pop    %r12
	pop	%rbx
  804160c5fc:	5b                   	pop    %rbx

	leave
  804160c5fd:	c9                   	leaveq 
	ret
  804160c5fe:	c3                   	retq   

000000804160c5ff <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name) {
  lk->locked = 0;
  804160c5ff:	c7 07 00 00 00 00    	movl   $0x0,(%rdi)
#ifdef DEBUG_SPINLOCK
  lk->name = name;
#endif
}
  804160c605:	c3                   	retq   

000000804160c606 <spin_lock>:
  asm volatile("lock; xchgl %0, %1"
  804160c606:	b8 01 00 00 00       	mov    $0x1,%eax
  804160c60b:	f0 87 07             	lock xchg %eax,(%rdi)
#endif

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it.
  while (xchg(&lk->locked, 1) != 0)
  804160c60e:	85 c0                	test   %eax,%eax
  804160c610:	74 10                	je     804160c622 <spin_lock+0x1c>
  804160c612:	ba 01 00 00 00       	mov    $0x1,%edx
    asm volatile("pause");
  804160c617:	f3 90                	pause  
  804160c619:	89 d0                	mov    %edx,%eax
  804160c61b:	f0 87 07             	lock xchg %eax,(%rdi)
  while (xchg(&lk->locked, 1) != 0)
  804160c61e:	85 c0                	test   %eax,%eax
  804160c620:	75 f5                	jne    804160c617 <spin_lock+0x11>

    // Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
  get_caller_pcs(lk->pcs);
#endif
}
  804160c622:	c3                   	retq   

000000804160c623 <spin_unlock>:
  804160c623:	b8 00 00 00 00       	mov    $0x0,%eax
  804160c628:	f0 87 07             	lock xchg %eax,(%rdi)
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
}
  804160c62b:	c3                   	retq   
  804160c62c:	0f 1f 40 00          	nopl   0x0(%rax)
