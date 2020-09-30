
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
  8041600011:	e8 6b 02 00 00       	callq  8041600281 <i386_init>

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
  8041600019:	8f 05 41 3c 02 00    	popq   0x23c41(%rip)        # 8041623c60 <_g_ret>
  popq ret_rip(%rip)
  804160001f:	8f 05 4b 3c 02 00    	popq   0x23c4b(%rip)        # 8041623c70 <ret_rip>
  movq %rbp, rbp_reg(%rip)
  8041600025:	48 89 2d 3c 3c 02 00 	mov    %rbp,0x23c3c(%rip)        # 8041623c68 <rbp_reg>
  movq %rsp, rsp_reg(%rip)
  804160002c:	48 89 25 45 3c 02 00 	mov    %rsp,0x23c45(%rip)        # 8041623c78 <rsp_reg>
  movq $0x0,%rbp
  8041600033:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  leaq bootstacktop(%rip),%rsp
  804160003a:	48 8d 25 bf 6f 01 00 	lea    0x16fbf(%rip),%rsp        # 8041617000 <bootstacktop>
  pushq $GD_KD
  8041600041:	6a 10                	pushq  $0x10
  pushq rsp_reg(%rip)
  8041600043:	ff 35 2f 3c 02 00    	pushq  0x23c2f(%rip)        # 8041623c78 <rsp_reg>
  pushfq
  8041600049:	9c                   	pushfq 
  # Guard to avoid hard to debug errors due to cli misusage.
  orl $FL_IF, (%rsp)
  804160004a:	81 0c 24 00 02 00 00 	orl    $0x200,(%rsp)
  pushq $GD_KT
  8041600051:	6a 08                	pushq  $0x8
  pushq ret_rip(%rip)
  8041600053:	ff 35 17 3c 02 00    	pushq  0x23c17(%rip)        # 8041623c70 <ret_rip>
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
  8041600065:	ff 35 fd 3b 02 00    	pushq  0x23bfd(%rip)        # 8041623c68 <rbp_reg>
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
  8041600080:	ff 35 da 3b 02 00    	pushq  0x23bda(%rip)        # 8041623c60 <_g_ret>
  ret
  8041600086:	c3                   	retq   

0000008041600087 <sys_yield>:

.globl sys_yield
.type  sys_yield, @function
sys_yield:
  call _generall_syscall
  8041600087:	e8 8c ff ff ff       	callq  8041600018 <_generall_syscall>
  call csys_yield
  804160008c:	e8 54 3e 00 00       	callq  8041603ee5 <csys_yield>
  jmp .
  8041600091:	eb fe                	jmp    8041600091 <sys_yield+0xa>

0000008041600093 <sys_exit>:

# LAB 3: Your code here.
.globl sys_exit
.type  sys_exit, @function
sys_exit:
  call _generall_syscall
  8041600093:	e8 80 ff ff ff       	callq  8041600018 <_generall_syscall>
  call csys_exit
  8041600098:	e8 47 3e 00 00       	callq  8041603ee4 <csys_exit>
  jmp .
  804160009d:	eb fe                	jmp    804160009d <sys_exit+0xa>

000000804160009f <alloc_pde_early_boot>:
  //Assume pde1, pde2 is already used.
  extern uintptr_t pdefreestart, pdefreeend;
  pde_t *ret;
  static uintptr_t pdefree = (uintptr_t)&pdefreestart;

  if (pdefree >= (uintptr_t)&pdefreeend)
  804160009f:	48 b8 08 70 61 41 80 	movabs $0x8041617008,%rax
  80416000a6:	00 00 00 
  80416000a9:	48 8b 10             	mov    (%rax),%rdx
  80416000ac:	48 b8 00 c0 50 01 00 	movabs $0x150c000,%rax
  80416000b3:	00 00 00 
  80416000b6:	48 39 c2             	cmp    %rax,%rdx
  80416000b9:	73 1b                	jae    80416000d6 <alloc_pde_early_boot+0x37>
    return NULL;

  ret = (pde_t *)pdefree;
  80416000bb:	48 89 d1             	mov    %rdx,%rcx
  pdefree += PGSIZE;
  80416000be:	48 81 c2 00 10 00 00 	add    $0x1000,%rdx
  80416000c5:	48 89 d0             	mov    %rdx,%rax
  80416000c8:	48 a3 08 70 61 41 80 	movabs %rax,0x8041617008
  80416000cf:	00 00 00 
  return ret;
}
  80416000d2:	48 89 c8             	mov    %rcx,%rax
  80416000d5:	c3                   	retq   
    return NULL;
  80416000d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416000db:	eb f5                	jmp    80416000d2 <alloc_pde_early_boot+0x33>

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
  80416000ea:	48 83 ec 18          	sub    $0x18,%rsp
  pml4e_t *pml4 = &pml4phys;
  pdpe_t *pdpt;
  pde_t *pde;

  uintptr_t addr_curr, addr_curr_phys, addr_end;
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  80416000ee:	49 89 ff             	mov    %rdi,%r15
  80416000f1:	49 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%r15
  addr_curr_phys = ROUNDDOWN(addr_phys, PTSIZE);
  80416000f8:	48 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%rsi
  80416000ff:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  addr_end       = ROUNDUP(addr + sz, PTSIZE);
  8041600103:	4c 8d b4 17 ff ff 1f 	lea    0x1fffff(%rdi,%rdx,1),%r14
  804160010a:	00 
  804160010b:	49 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%r14

  pdpt = (pdpe_t *)PTE_ADDR(pml4[PML4(addr_curr)]);
  8041600112:	48 c1 ef 24          	shr    $0x24,%rdi
  8041600116:	81 e7 f8 0f 00 00    	and    $0xff8,%edi
  804160011c:	48 b8 00 10 50 01 00 	movabs $0x1501000,%rax
  8041600123:	00 00 00 
  8041600126:	48 8b 04 38          	mov    (%rax,%rdi,1),%rax
  804160012a:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041600130:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  8041600134:	4d 39 fe             	cmp    %r15,%r14
  8041600137:	76 67                	jbe    80416001a0 <map_addr_early_boot+0xc3>
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  8041600139:	4d 89 fc             	mov    %r15,%r12
  804160013c:	eb 3a                	jmp    8041600178 <map_addr_early_boot+0x9b>
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
    if (!pde) {
      pde                   = alloc_pde_early_boot();
  804160013e:	48 b8 9f 00 60 41 80 	movabs $0x804160009f,%rax
  8041600145:	00 00 00 
  8041600148:	ff d0                	callq  *%rax
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
  804160014a:	48 89 c2             	mov    %rax,%rdx
  804160014d:	48 83 ca 03          	or     $0x3,%rdx
  8041600151:	48 89 13             	mov    %rdx,(%rbx)
    }
    pde[PDX(addr_curr)] = addr_curr_phys | PTE_P | PTE_W | PTE_MBZ;
  8041600154:	4c 89 e2             	mov    %r12,%rdx
  8041600157:	48 c1 ea 15          	shr    $0x15,%rdx
  804160015b:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  8041600161:	49 81 cd 83 01 00 00 	or     $0x183,%r13
  8041600168:	4c 89 2c d0          	mov    %r13,(%rax,%rdx,8)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  804160016c:	49 81 c4 00 00 20 00 	add    $0x200000,%r12
  8041600173:	4d 39 e6             	cmp    %r12,%r14
  8041600176:	76 28                	jbe    80416001a0 <map_addr_early_boot+0xc3>
  8041600178:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
  804160017c:	4d 29 fd             	sub    %r15,%r13
  804160017f:	4d 01 e5             	add    %r12,%r13
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
  8041600182:	4c 89 e3             	mov    %r12,%rbx
  8041600185:	48 c1 eb 1b          	shr    $0x1b,%rbx
  8041600189:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  804160018f:	48 03 5d c0          	add    -0x40(%rbp),%rbx
    if (!pde) {
  8041600193:	48 8b 03             	mov    (%rbx),%rax
  8041600196:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  804160019c:	75 b6                	jne    8041600154 <map_addr_early_boot+0x77>
  804160019e:	eb 9e                	jmp    804160013e <map_addr_early_boot+0x61>
  }
}
  80416001a0:	48 83 c4 18          	add    $0x18,%rsp
  80416001a4:	5b                   	pop    %rbx
  80416001a5:	41 5c                	pop    %r12
  80416001a7:	41 5d                	pop    %r13
  80416001a9:	41 5e                	pop    %r14
  80416001ab:	41 5f                	pop    %r15
  80416001ad:	5d                   	pop    %rbp
  80416001ae:	c3                   	retq   

00000080416001af <early_boot_pml4_init>:
// Additionally maps pml4 memory so that we dont get memory errors on accessing
// uefi_lp, MemMap, KASAN functions.
void
early_boot_pml4_init(void) {
  80416001af:	55                   	push   %rbp
  80416001b0:	48 89 e5             	mov    %rsp,%rbp
  80416001b3:	41 54                	push   %r12
  80416001b5:	53                   	push   %rbx

  map_addr_early_boot((uintptr_t)uefi_lp, (uintptr_t)uefi_lp, sizeof(LOADER_PARAMS));
  80416001b6:	49 bc 00 70 61 41 80 	movabs $0x8041617000,%r12
  80416001bd:	00 00 00 
  80416001c0:	49 8b 3c 24          	mov    (%r12),%rdi
  80416001c4:	ba c8 00 00 00       	mov    $0xc8,%edx
  80416001c9:	48 89 fe             	mov    %rdi,%rsi
  80416001cc:	48 bb dd 00 60 41 80 	movabs $0x80416000dd,%rbx
  80416001d3:	00 00 00 
  80416001d6:	ff d3                	callq  *%rbx
  map_addr_early_boot((uintptr_t)uefi_lp->MemoryMap, (uintptr_t)uefi_lp->MemoryMap, uefi_lp->MemoryMapSize);
  80416001d8:	49 8b 04 24          	mov    (%r12),%rax
  80416001dc:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80416001e0:	48 8b 50 38          	mov    0x38(%rax),%rdx
  80416001e4:	48 89 fe             	mov    %rdi,%rsi
  80416001e7:	ff d3                	callq  *%rbx

#ifdef SANITIZE_SHADOW_BASE
  map_addr_early_boot(SANITIZE_SHADOW_BASE, SANITIZE_SHADOW_BASE - KERNBASE, SANITIZE_SHADOW_SIZE);
#endif

  map_addr_early_boot(FBUFFBASE, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
  80416001e9:	49 8b 04 24          	mov    (%r12),%rax
  80416001ed:	8b 50 48             	mov    0x48(%rax),%edx
  80416001f0:	48 8b 70 40          	mov    0x40(%rax),%rsi
  80416001f4:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416001fb:	00 00 00 
  80416001fe:	ff d3                	callq  *%rbx
}
  8041600200:	5b                   	pop    %rbx
  8041600201:	41 5c                	pop    %r12
  8041600203:	5d                   	pop    %rbp
  8041600204:	c3                   	retq   

0000008041600205 <test_backtrace>:

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x) {
  8041600205:	55                   	push   %rbp
  8041600206:	48 89 e5             	mov    %rsp,%rbp
  8041600209:	53                   	push   %rbx
  804160020a:	48 83 ec 08          	sub    $0x8,%rsp
  804160020e:	89 fb                	mov    %edi,%ebx
  cprintf("entering test_backtrace %d\n", x);
  8041600210:	89 fe                	mov    %edi,%esi
  8041600212:	48 bf 60 53 60 41 80 	movabs $0x8041605360,%rdi
  8041600219:	00 00 00 
  804160021c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600221:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041600228:	00 00 00 
  804160022b:	ff d2                	callq  *%rdx
  if (x > 0)
  804160022d:	85 db                	test   %ebx,%ebx
  804160022f:	7e 33                	jle    8041600264 <test_backtrace+0x5f>
    test_backtrace(x - 1);
  8041600231:	8d 7b ff             	lea    -0x1(%rbx),%edi
  8041600234:	48 b8 05 02 60 41 80 	movabs $0x8041600205,%rax
  804160023b:	00 00 00 
  804160023e:	ff d0                	callq  *%rax
  else
    mon_backtrace(0, 0, 0);
  cprintf("leaving test_backtrace %d\n", x);
  8041600240:	89 de                	mov    %ebx,%esi
  8041600242:	48 bf 7c 53 60 41 80 	movabs $0x804160537c,%rdi
  8041600249:	00 00 00 
  804160024c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600251:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041600258:	00 00 00 
  804160025b:	ff d2                	callq  *%rdx
}
  804160025d:	48 83 c4 08          	add    $0x8,%rsp
  8041600261:	5b                   	pop    %rbx
  8041600262:	5d                   	pop    %rbp
  8041600263:	c3                   	retq   
    mon_backtrace(0, 0, 0);
  8041600264:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600269:	be 00 00 00 00       	mov    $0x0,%esi
  804160026e:	bf 00 00 00 00       	mov    $0x0,%edi
  8041600273:	48 b8 f2 38 60 41 80 	movabs $0x80416038f2,%rax
  804160027a:	00 00 00 
  804160027d:	ff d0                	callq  *%rax
  804160027f:	eb bf                	jmp    8041600240 <test_backtrace+0x3b>

0000008041600281 <i386_init>:

void
i386_init(void) {
  8041600281:	55                   	push   %rbp
  8041600282:	48 89 e5             	mov    %rsp,%rbp
  8041600285:	41 54                	push   %r12
  8041600287:	53                   	push   %rbx
  extern char end[];

  early_boot_pml4_init();
  8041600288:	48 b8 af 01 60 41 80 	movabs $0x80416001af,%rax
  804160028f:	00 00 00 
  8041600292:	ff d0                	callq  *%rax

  // Initialize the console.
  // Can't call cprintf until after we do this!
  cons_init();
  8041600294:	48 b8 87 0b 60 41 80 	movabs $0x8041600b87,%rax
  804160029b:	00 00 00 
  804160029e:	ff d0                	callq  *%rax

  cprintf("6828 decimal is %o octal!\n", 6828);
  80416002a0:	be ac 1a 00 00       	mov    $0x1aac,%esi
  80416002a5:	48 bf 97 53 60 41 80 	movabs $0x8041605397,%rdi
  80416002ac:	00 00 00 
  80416002af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002b4:	48 bb 4c 40 60 41 80 	movabs $0x804160404c,%rbx
  80416002bb:	00 00 00 
  80416002be:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  80416002c0:	48 be 00 60 62 41 80 	movabs $0x8041626000,%rsi
  80416002c7:	00 00 00 
  80416002ca:	48 bf b2 53 60 41 80 	movabs $0x80416053b2,%rdi
  80416002d1:	00 00 00 
  80416002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002d9:	ff d3                	callq  *%rbx
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80416002db:	48 ba d0 35 62 41 80 	movabs $0x80416235d0,%rdx
  80416002e2:	00 00 00 
  80416002e5:	48 b8 d0 35 62 41 80 	movabs $0x80416235d0,%rax
  80416002ec:	00 00 00 
  80416002ef:	48 39 c2             	cmp    %rax,%rdx
  80416002f2:	73 23                	jae    8041600317 <i386_init+0x96>
  80416002f4:	48 89 d3             	mov    %rdx,%rbx
  80416002f7:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80416002fb:	48 29 d0             	sub    %rdx,%rax
  80416002fe:	48 c1 e8 03          	shr    $0x3,%rax
  8041600302:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  8041600307:	b8 00 00 00 00       	mov    $0x0,%eax
  804160030c:	ff 13                	callq  *(%rbx)
    ctor++;
  804160030e:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8041600312:	4c 39 e3             	cmp    %r12,%rbx
  8041600315:	75 f0                	jne    8041600307 <i386_init+0x86>
  }

  // Framebuffer init should be done after memory init.
  fb_init();
  8041600317:	48 b8 7a 0a 60 41 80 	movabs $0x8041600a7a,%rax
  804160031e:	00 00 00 
  8041600321:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  8041600323:	48 bf bb 53 60 41 80 	movabs $0x80416053bb,%rdi
  804160032a:	00 00 00 
  804160032d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600332:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041600339:	00 00 00 
  804160033c:	ff d2                	callq  *%rdx

  // user environment initialization functions
  env_init();
  804160033e:	48 b8 86 3c 60 41 80 	movabs $0x8041603c86,%rax
  8041600345:	00 00 00 
  8041600348:	ff d0                	callq  *%rax

#ifdef CONFIG_KSPACE
  // Touch all you want.
  ENV_CREATE_KERNEL_TYPE(prog_test1);
  804160034a:	be 01 00 00 00       	mov    $0x1,%esi
  804160034f:	48 bf 90 77 61 41 80 	movabs $0x8041617790,%rdi
  8041600356:	00 00 00 
  8041600359:	48 bb 73 3e 60 41 80 	movabs $0x8041603e73,%rbx
  8041600360:	00 00 00 
  8041600363:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test2);
  8041600365:	be 01 00 00 00       	mov    $0x1,%esi
  804160036a:	48 bf aa b6 61 41 80 	movabs $0x804161b6aa,%rdi
  8041600371:	00 00 00 
  8041600374:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test3);
  8041600376:	be 01 00 00 00       	mov    $0x1,%esi
  804160037b:	48 bf b4 f6 61 41 80 	movabs $0x804161f6b4,%rdi
  8041600382:	00 00 00 
  8041600385:	ff d3                	callq  *%rbx
#endif

  // Schedule and run the first user environment!
  sched_yield();
  8041600387:	48 b8 e0 40 60 41 80 	movabs $0x80416040e0,%rax
  804160038e:	00 00 00 
  8041600391:	ff d0                	callq  *%rax

0000008041600393 <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8041600393:	55                   	push   %rbp
  8041600394:	48 89 e5             	mov    %rsp,%rbp
  8041600397:	41 54                	push   %r12
  8041600399:	53                   	push   %rbx
  804160039a:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80416003a1:	49 89 d4             	mov    %rdx,%r12
  80416003a4:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  80416003ab:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80416003b2:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416003b9:	84 c0                	test   %al,%al
  80416003bb:	74 23                	je     80416003e0 <_panic+0x4d>
  80416003bd:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416003c4:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416003c8:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416003cc:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416003d0:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416003d4:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416003d8:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416003dc:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  if (panicstr)
  80416003e0:	48 b8 e0 35 62 41 80 	movabs $0x80416235e0,%rax
  80416003e7:	00 00 00 
  80416003ea:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416003ee:	74 13                	je     8041600403 <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416003f0:	48 bb f3 39 60 41 80 	movabs $0x80416039f3,%rbx
  80416003f7:	00 00 00 
  80416003fa:	bf 00 00 00 00       	mov    $0x0,%edi
  80416003ff:	ff d3                	callq  *%rbx
  while (1)
  8041600401:	eb f7                	jmp    80416003fa <_panic+0x67>
  panicstr = fmt;
  8041600403:	4c 89 e0             	mov    %r12,%rax
  8041600406:	48 a3 e0 35 62 41 80 	movabs %rax,0x80416235e0
  804160040d:	00 00 00 
  __asm __volatile("cli; cld");
  8041600410:	fa                   	cli    
  8041600411:	fc                   	cld    
  va_start(ap, fmt);
  8041600412:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  8041600419:	00 00 00 
  804160041c:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8041600423:	00 00 00 
  8041600426:	48 8d 45 10          	lea    0x10(%rbp),%rax
  804160042a:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  8041600431:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  8041600438:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel panic at %s:%d: ", file, line);
  804160043f:	89 f2                	mov    %esi,%edx
  8041600441:	48 89 fe             	mov    %rdi,%rsi
  8041600444:	48 bf d4 53 60 41 80 	movabs $0x80416053d4,%rdi
  804160044b:	00 00 00 
  804160044e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600453:	48 bb 4c 40 60 41 80 	movabs $0x804160404c,%rbx
  804160045a:	00 00 00 
  804160045d:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  804160045f:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600466:	4c 89 e7             	mov    %r12,%rdi
  8041600469:	48 b8 18 40 60 41 80 	movabs $0x8041604018,%rax
  8041600470:	00 00 00 
  8041600473:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600475:	48 bf a9 59 60 41 80 	movabs $0x80416059a9,%rdi
  804160047c:	00 00 00 
  804160047f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600484:	ff d3                	callq  *%rbx
  va_end(ap);
  8041600486:	e9 65 ff ff ff       	jmpq   80416003f0 <_panic+0x5d>

000000804160048b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  804160048b:	55                   	push   %rbp
  804160048c:	48 89 e5             	mov    %rsp,%rbp
  804160048f:	41 54                	push   %r12
  8041600491:	53                   	push   %rbx
  8041600492:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600499:	49 89 d4             	mov    %rdx,%r12
  804160049c:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  80416004a3:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80416004aa:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416004b1:	84 c0                	test   %al,%al
  80416004b3:	74 23                	je     80416004d8 <_warn+0x4d>
  80416004b5:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416004bc:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416004c0:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416004c4:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416004c8:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416004cc:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416004d0:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416004d4:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416004d8:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416004df:	00 00 00 
  80416004e2:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416004e9:	00 00 00 
  80416004ec:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416004f0:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416004f7:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416004fe:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  8041600505:	89 f2                	mov    %esi,%edx
  8041600507:	48 89 fe             	mov    %rdi,%rsi
  804160050a:	48 bf ec 53 60 41 80 	movabs $0x80416053ec,%rdi
  8041600511:	00 00 00 
  8041600514:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600519:	48 bb 4c 40 60 41 80 	movabs $0x804160404c,%rbx
  8041600520:	00 00 00 
  8041600523:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600525:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160052c:	4c 89 e7             	mov    %r12,%rdi
  804160052f:	48 b8 18 40 60 41 80 	movabs $0x8041604018,%rax
  8041600536:	00 00 00 
  8041600539:	ff d0                	callq  *%rax
  cprintf("\n");
  804160053b:	48 bf a9 59 60 41 80 	movabs $0x80416059a9,%rdi
  8041600542:	00 00 00 
  8041600545:	b8 00 00 00 00       	mov    $0x0,%eax
  804160054a:	ff d3                	callq  *%rbx
  va_end(ap);
}
  804160054c:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  8041600553:	5b                   	pop    %rbx
  8041600554:	41 5c                	pop    %r12
  8041600556:	5d                   	pop    %rbp
  8041600557:	c3                   	retq   

0000008041600558 <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  8041600558:	ba fd 03 00 00       	mov    $0x3fd,%edx
  804160055d:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  804160055e:	a8 01                	test   $0x1,%al
  8041600560:	74 0a                	je     804160056c <serial_proc_data+0x14>
  8041600562:	ba f8 03 00 00       	mov    $0x3f8,%edx
  8041600567:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  8041600568:	0f b6 c0             	movzbl %al,%eax
  804160056b:	c3                   	retq   
    return -1;
  804160056c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  8041600571:	c3                   	retq   

0000008041600572 <cons_intr>:
} cons;

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void)) {
  8041600572:	55                   	push   %rbp
  8041600573:	48 89 e5             	mov    %rsp,%rbp
  8041600576:	41 54                	push   %r12
  8041600578:	53                   	push   %rbx
  8041600579:	49 89 fc             	mov    %rdi,%r12
  int c;

  while ((c = (*proc)()) != -1) {
    if (c == 0)
      continue;
    cons.buf[cons.wpos++] = c;
  804160057c:	48 bb 20 36 62 41 80 	movabs $0x8041623620,%rbx
  8041600583:	00 00 00 
  while ((c = (*proc)()) != -1) {
  8041600586:	41 ff d4             	callq  *%r12
  8041600589:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160058c:	74 28                	je     80416005b6 <cons_intr+0x44>
    if (c == 0)
  804160058e:	85 c0                	test   %eax,%eax
  8041600590:	74 f4                	je     8041600586 <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  8041600592:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  8041600598:	8d 51 01             	lea    0x1(%rcx),%edx
  804160059b:	89 c9                	mov    %ecx,%ecx
  804160059d:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  80416005a0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  80416005a6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416005ab:	0f 44 d0             	cmove  %eax,%edx
  80416005ae:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  80416005b4:	eb d0                	jmp    8041600586 <cons_intr+0x14>
  }
}
  80416005b6:	5b                   	pop    %rbx
  80416005b7:	41 5c                	pop    %r12
  80416005b9:	5d                   	pop    %rbp
  80416005ba:	c3                   	retq   

00000080416005bb <kbd_proc_data>:
kbd_proc_data(void) {
  80416005bb:	55                   	push   %rbp
  80416005bc:	48 89 e5             	mov    %rsp,%rbp
  80416005bf:	53                   	push   %rbx
  80416005c0:	48 83 ec 08          	sub    $0x8,%rsp
  80416005c4:	ba 64 00 00 00       	mov    $0x64,%edx
  80416005c9:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416005ca:	a8 01                	test   $0x1,%al
  80416005cc:	0f 84 31 01 00 00    	je     8041600703 <kbd_proc_data+0x148>
  80416005d2:	ba 60 00 00 00       	mov    $0x60,%edx
  80416005d7:	ec                   	in     (%dx),%al
  80416005d8:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416005da:	3c e0                	cmp    $0xe0,%al
  80416005dc:	0f 84 84 00 00 00    	je     8041600666 <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  80416005e2:	84 c0                	test   %al,%al
  80416005e4:	0f 88 97 00 00 00    	js     8041600681 <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  80416005ea:	48 bf 00 36 62 41 80 	movabs $0x8041623600,%rdi
  80416005f1:	00 00 00 
  80416005f4:	8b 0f                	mov    (%rdi),%ecx
  80416005f6:	f6 c1 40             	test   $0x40,%cl
  80416005f9:	74 0c                	je     8041600607 <kbd_proc_data+0x4c>
    data |= 0x80;
  80416005fb:	83 c8 80             	or     $0xffffff80,%eax
  80416005fe:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  8041600600:	89 c8                	mov    %ecx,%eax
  8041600602:	83 e0 bf             	and    $0xffffffbf,%eax
  8041600605:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  8041600607:	0f b6 f2             	movzbl %dl,%esi
  804160060a:	48 b8 60 55 60 41 80 	movabs $0x8041605560,%rax
  8041600611:	00 00 00 
  8041600614:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  8041600618:	48 b9 00 36 62 41 80 	movabs $0x8041623600,%rcx
  804160061f:	00 00 00 
  8041600622:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  8041600624:	48 bf 60 54 60 41 80 	movabs $0x8041605460,%rdi
  804160062b:	00 00 00 
  804160062e:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  8041600632:	31 f0                	xor    %esi,%eax
  8041600634:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  8041600636:	89 c6                	mov    %eax,%esi
  8041600638:	83 e6 03             	and    $0x3,%esi
  804160063b:	0f b6 d2             	movzbl %dl,%edx
  804160063e:	48 b9 40 54 60 41 80 	movabs $0x8041605440,%rcx
  8041600645:	00 00 00 
  8041600648:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  804160064c:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  8041600650:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  8041600653:	a8 08                	test   $0x8,%al
  8041600655:	74 73                	je     80416006ca <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  8041600657:	89 da                	mov    %ebx,%edx
  8041600659:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  804160065c:	83 f9 19             	cmp    $0x19,%ecx
  804160065f:	77 5d                	ja     80416006be <kbd_proc_data+0x103>
      c += 'A' - 'a';
  8041600661:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8041600664:	eb 12                	jmp    8041600678 <kbd_proc_data+0xbd>
    shift |= E0ESC;
  8041600666:	48 b8 00 36 62 41 80 	movabs $0x8041623600,%rax
  804160066d:	00 00 00 
  8041600670:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  8041600673:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8041600678:	89 d8                	mov    %ebx,%eax
  804160067a:	48 83 c4 08          	add    $0x8,%rsp
  804160067e:	5b                   	pop    %rbx
  804160067f:	5d                   	pop    %rbp
  8041600680:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600681:	48 bf 00 36 62 41 80 	movabs $0x8041623600,%rdi
  8041600688:	00 00 00 
  804160068b:	8b 0f                	mov    (%rdi),%ecx
  804160068d:	89 ce                	mov    %ecx,%esi
  804160068f:	83 e6 40             	and    $0x40,%esi
  8041600692:	83 e0 7f             	and    $0x7f,%eax
  8041600695:	85 f6                	test   %esi,%esi
  8041600697:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  804160069a:	0f b6 d2             	movzbl %dl,%edx
  804160069d:	48 b8 60 55 60 41 80 	movabs $0x8041605560,%rax
  80416006a4:	00 00 00 
  80416006a7:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  80416006ab:	83 c8 40             	or     $0x40,%eax
  80416006ae:	0f b6 c0             	movzbl %al,%eax
  80416006b1:	f7 d0                	not    %eax
  80416006b3:	21 c8                	and    %ecx,%eax
  80416006b5:	89 07                	mov    %eax,(%rdi)
    return 0;
  80416006b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416006bc:	eb ba                	jmp    8041600678 <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  80416006be:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416006c1:	8d 4b 20             	lea    0x20(%rbx),%ecx
  80416006c4:	83 fa 1a             	cmp    $0x1a,%edx
  80416006c7:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416006ca:	f7 d0                	not    %eax
  80416006cc:	a8 06                	test   $0x6,%al
  80416006ce:	75 a8                	jne    8041600678 <kbd_proc_data+0xbd>
  80416006d0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  80416006d6:	75 a0                	jne    8041600678 <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  80416006d8:	48 bf 06 54 60 41 80 	movabs $0x8041605406,%rdi
  80416006df:	00 00 00 
  80416006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416006e7:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  80416006ee:	00 00 00 
  80416006f1:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416006f3:	b8 03 00 00 00       	mov    $0x3,%eax
  80416006f8:	ba 92 00 00 00       	mov    $0x92,%edx
  80416006fd:	ee                   	out    %al,(%dx)
  80416006fe:	e9 75 ff ff ff       	jmpq   8041600678 <kbd_proc_data+0xbd>
    return -1;
  8041600703:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  8041600708:	e9 6b ff ff ff       	jmpq   8041600678 <kbd_proc_data+0xbd>

000000804160070d <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  804160070d:	48 b8 34 38 62 41 80 	movabs $0x8041623834,%rax
  8041600714:	00 00 00 
  8041600717:	44 8b 10             	mov    (%rax),%r10d
  804160071a:	41 0f af d2          	imul   %r10d,%edx
  804160071e:	01 f2                	add    %esi,%edx
  8041600720:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  8041600727:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  8041600728:	4d 0f be c0          	movsbq %r8b,%r8
  804160072c:	48 b8 20 73 61 41 80 	movabs $0x8041617320,%rax
  8041600733:	00 00 00 
  8041600736:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  804160073a:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  804160073e:	eb 25                	jmp    8041600765 <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  8041600740:	83 c0 01             	add    $0x1,%eax
  8041600743:	83 f8 08             	cmp    $0x8,%eax
  8041600746:	74 11                	je     8041600759 <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  8041600748:	0f be 16             	movsbl (%rsi),%edx
  804160074b:	0f a3 c2             	bt     %eax,%edx
  804160074e:	73 f0                	jae    8041600740 <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  8041600750:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  8041600754:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  8041600757:	eb e7                	jmp    8041600740 <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  8041600759:	45 01 d1             	add    %r10d,%r9d
  804160075c:	48 83 c6 01          	add    $0x1,%rsi
  8041600760:	4c 39 c6             	cmp    %r8,%rsi
  8041600763:	74 07                	je     804160076c <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  8041600765:	b8 00 00 00 00       	mov    $0x0,%eax
  804160076a:	eb dc                	jmp    8041600748 <draw_char+0x3b>
}
  804160076c:	c3                   	retq   

000000804160076d <cons_putc>:
  __asm __volatile("inb %w1,%0"
  804160076d:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600772:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600773:	a8 20                	test   $0x20,%al
  8041600775:	75 29                	jne    80416007a0 <cons_putc+0x33>
  for (i = 0;
  8041600777:	be 00 00 00 00       	mov    $0x0,%esi
  804160077c:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600781:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  8041600787:	89 ca                	mov    %ecx,%edx
  8041600789:	ec                   	in     (%dx),%al
  804160078a:	ec                   	in     (%dx),%al
  804160078b:	ec                   	in     (%dx),%al
  804160078c:	ec                   	in     (%dx),%al
       i++)
  804160078d:	83 c6 01             	add    $0x1,%esi
  8041600790:	44 89 c2             	mov    %r8d,%edx
  8041600793:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600794:	a8 20                	test   $0x20,%al
  8041600796:	75 08                	jne    80416007a0 <cons_putc+0x33>
  8041600798:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  804160079e:	7e e7                	jle    8041600787 <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  80416007a0:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  80416007a3:	ba f8 03 00 00       	mov    $0x3f8,%edx
  80416007a8:	89 f8                	mov    %edi,%eax
  80416007aa:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416007ab:	ba 79 03 00 00       	mov    $0x379,%edx
  80416007b0:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  80416007b1:	84 c0                	test   %al,%al
  80416007b3:	78 29                	js     80416007de <cons_putc+0x71>
  80416007b5:	be 00 00 00 00       	mov    $0x0,%esi
  80416007ba:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416007bf:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  80416007c5:	89 ca                	mov    %ecx,%edx
  80416007c7:	ec                   	in     (%dx),%al
  80416007c8:	ec                   	in     (%dx),%al
  80416007c9:	ec                   	in     (%dx),%al
  80416007ca:	ec                   	in     (%dx),%al
  80416007cb:	83 c6 01             	add    $0x1,%esi
  80416007ce:	44 89 ca             	mov    %r9d,%edx
  80416007d1:	ec                   	in     (%dx),%al
  80416007d2:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416007d8:	7f 04                	jg     80416007de <cons_putc+0x71>
  80416007da:	84 c0                	test   %al,%al
  80416007dc:	79 e7                	jns    80416007c5 <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416007de:	ba 78 03 00 00       	mov    $0x378,%edx
  80416007e3:	44 89 c0             	mov    %r8d,%eax
  80416007e6:	ee                   	out    %al,(%dx)
  80416007e7:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416007ec:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416007f1:	ee                   	out    %al,(%dx)
  80416007f2:	b8 08 00 00 00       	mov    $0x8,%eax
  80416007f7:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416007f8:	48 b8 3c 38 62 41 80 	movabs $0x804162383c,%rax
  80416007ff:	00 00 00 
  8041600802:	80 38 00             	cmpb   $0x0,(%rax)
  8041600805:	0f 84 42 02 00 00    	je     8041600a4d <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  804160080b:	55                   	push   %rbp
  804160080c:	48 89 e5             	mov    %rsp,%rbp
  804160080f:	41 54                	push   %r12
  8041600811:	53                   	push   %rbx
  if (!(c & ~0xFF))
  8041600812:	89 fa                	mov    %edi,%edx
  8041600814:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  804160081a:	89 f8                	mov    %edi,%eax
  804160081c:	80 cc 07             	or     $0x7,%ah
  804160081f:	85 d2                	test   %edx,%edx
  8041600821:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  8041600824:	40 0f b6 c7          	movzbl %dil,%eax
  8041600828:	83 f8 09             	cmp    $0x9,%eax
  804160082b:	0f 84 e1 00 00 00    	je     8041600912 <cons_putc+0x1a5>
  8041600831:	7e 5c                	jle    804160088f <cons_putc+0x122>
  8041600833:	83 f8 0a             	cmp    $0xa,%eax
  8041600836:	0f 84 b8 00 00 00    	je     80416008f4 <cons_putc+0x187>
  804160083c:	83 f8 0d             	cmp    $0xd,%eax
  804160083f:	0f 85 ff 00 00 00    	jne    8041600944 <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  8041600845:	48 be 28 38 62 41 80 	movabs $0x8041623828,%rsi
  804160084c:	00 00 00 
  804160084f:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600852:	0f b7 c1             	movzwl %cx,%eax
  8041600855:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  804160085c:	00 00 00 
  804160085f:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600864:	f7 33                	divl   (%rbx)
  8041600866:	29 d1                	sub    %edx,%ecx
  8041600868:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  804160086b:	48 b8 28 38 62 41 80 	movabs $0x8041623828,%rax
  8041600872:	00 00 00 
  8041600875:	0f b7 10             	movzwl (%rax),%edx
  8041600878:	48 b8 2c 38 62 41 80 	movabs $0x804162382c,%rax
  804160087f:	00 00 00 
  8041600882:	3b 10                	cmp    (%rax),%edx
  8041600884:	0f 83 0f 01 00 00    	jae    8041600999 <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  804160088a:	5b                   	pop    %rbx
  804160088b:	41 5c                	pop    %r12
  804160088d:	5d                   	pop    %rbp
  804160088e:	c3                   	retq   
  switch (c & 0xff) {
  804160088f:	83 f8 08             	cmp    $0x8,%eax
  8041600892:	0f 85 ac 00 00 00    	jne    8041600944 <cons_putc+0x1d7>
      if (crt_pos > 0) {
  8041600898:	66 a1 28 38 62 41 80 	movabs 0x8041623828,%ax
  804160089f:	00 00 00 
  80416008a2:	66 85 c0             	test   %ax,%ax
  80416008a5:	74 c4                	je     804160086b <cons_putc+0xfe>
        crt_pos--;
  80416008a7:	83 e8 01             	sub    $0x1,%eax
  80416008aa:	66 a3 28 38 62 41 80 	movabs %ax,0x8041623828
  80416008b1:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  80416008b4:	0f b7 c0             	movzwl %ax,%eax
  80416008b7:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  80416008be:	00 00 00 
  80416008c1:	8b 1b                	mov    (%rbx),%ebx
  80416008c3:	ba 00 00 00 00       	mov    $0x0,%edx
  80416008c8:	f7 f3                	div    %ebx
  80416008ca:	89 d6                	mov    %edx,%esi
  80416008cc:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416008d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416008d7:	89 c2                	mov    %eax,%edx
  80416008d9:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416008e0:	00 00 00 
  80416008e3:	48 b8 0d 07 60 41 80 	movabs $0x804160070d,%rax
  80416008ea:	00 00 00 
  80416008ed:	ff d0                	callq  *%rax
  80416008ef:	e9 77 ff ff ff       	jmpq   804160086b <cons_putc+0xfe>
      crt_pos += crt_cols;
  80416008f4:	48 b8 28 38 62 41 80 	movabs $0x8041623828,%rax
  80416008fb:	00 00 00 
  80416008fe:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  8041600905:	00 00 00 
  8041600908:	8b 13                	mov    (%rbx),%edx
  804160090a:	66 01 10             	add    %dx,(%rax)
  804160090d:	e9 33 ff ff ff       	jmpq   8041600845 <cons_putc+0xd8>
      cons_putc(' ');
  8041600912:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600917:	48 bb 6d 07 60 41 80 	movabs $0x804160076d,%rbx
  804160091e:	00 00 00 
  8041600921:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600923:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600928:	ff d3                	callq  *%rbx
      cons_putc(' ');
  804160092a:	bf 20 00 00 00       	mov    $0x20,%edi
  804160092f:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600931:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600936:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600938:	bf 20 00 00 00       	mov    $0x20,%edi
  804160093d:	ff d3                	callq  *%rbx
      break;
  804160093f:	e9 27 ff ff ff       	jmpq   804160086b <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  8041600944:	49 bc 28 38 62 41 80 	movabs $0x8041623828,%r12
  804160094b:	00 00 00 
  804160094e:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600953:	0f b7 c3             	movzwl %bx,%eax
  8041600956:	48 be 30 38 62 41 80 	movabs $0x8041623830,%rsi
  804160095d:	00 00 00 
  8041600960:	8b 36                	mov    (%rsi),%esi
  8041600962:	ba 00 00 00 00       	mov    $0x0,%edx
  8041600967:	f7 f6                	div    %esi
  8041600969:	89 d6                	mov    %edx,%esi
  804160096b:	44 0f be c7          	movsbl %dil,%r8d
  804160096f:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  8041600974:	89 c2                	mov    %eax,%edx
  8041600976:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  804160097d:	00 00 00 
  8041600980:	48 b8 0d 07 60 41 80 	movabs $0x804160070d,%rax
  8041600987:	00 00 00 
  804160098a:	ff d0                	callq  *%rax
      crt_pos++;
  804160098c:	83 c3 01             	add    $0x1,%ebx
  804160098f:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  8041600994:	e9 d2 fe ff ff       	jmpq   804160086b <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  8041600999:	48 bb 34 38 62 41 80 	movabs $0x8041623834,%rbx
  80416009a0:	00 00 00 
  80416009a3:	8b 03                	mov    (%rbx),%eax
  80416009a5:	49 bc 38 38 62 41 80 	movabs $0x8041623838,%r12
  80416009ac:	00 00 00 
  80416009af:	41 8b 3c 24          	mov    (%r12),%edi
  80416009b3:	8d 57 f8             	lea    -0x8(%rdi),%edx
  80416009b6:	0f af d0             	imul   %eax,%edx
  80416009b9:	48 c1 e2 02          	shl    $0x2,%rdx
  80416009bd:	c1 e0 03             	shl    $0x3,%eax
  80416009c0:	89 c0                	mov    %eax,%eax
  80416009c2:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416009c9:	00 00 00 
  80416009cc:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  80416009d0:	48 b8 65 50 60 41 80 	movabs $0x8041605065,%rax
  80416009d7:	00 00 00 
  80416009da:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  80416009dc:	41 8b 04 24          	mov    (%r12),%eax
  80416009e0:	8b 0b                	mov    (%rbx),%ecx
  80416009e2:	89 c6                	mov    %eax,%esi
  80416009e4:	83 e6 f8             	and    $0xfffffff8,%esi
  80416009e7:	83 ee 08             	sub    $0x8,%esi
  80416009ea:	0f af f1             	imul   %ecx,%esi
  80416009ed:	0f af c8             	imul   %eax,%ecx
  80416009f0:	39 f1                	cmp    %esi,%ecx
  80416009f2:	76 3b                	jbe    8041600a2f <cons_putc+0x2c2>
  80416009f4:	48 63 fe             	movslq %esi,%rdi
  80416009f7:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  80416009fe:	00 00 00 
  8041600a01:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  8041600a05:	8d 51 ff             	lea    -0x1(%rcx),%edx
  8041600a08:	89 d1                	mov    %edx,%ecx
  8041600a0a:	29 f1                	sub    %esi,%ecx
  8041600a0c:	48 ba 01 00 b0 0f 20 	movabs $0x200fb00001,%rdx
  8041600a13:	00 00 00 
  8041600a16:	48 01 fa             	add    %rdi,%rdx
  8041600a19:	48 01 ca             	add    %rcx,%rdx
  8041600a1c:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600a20:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600a26:	48 83 c0 04          	add    $0x4,%rax
  8041600a2a:	48 39 c2             	cmp    %rax,%rdx
  8041600a2d:	75 f1                	jne    8041600a20 <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600a2f:	48 b8 28 38 62 41 80 	movabs $0x8041623828,%rax
  8041600a36:	00 00 00 
  8041600a39:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  8041600a40:	00 00 00 
  8041600a43:	8b 13                	mov    (%rbx),%edx
  8041600a45:	66 29 10             	sub    %dx,(%rax)
}
  8041600a48:	e9 3d fe ff ff       	jmpq   804160088a <cons_putc+0x11d>
  8041600a4d:	c3                   	retq   

0000008041600a4e <serial_intr>:
  if (serial_exists)
  8041600a4e:	48 b8 2a 38 62 41 80 	movabs $0x804162382a,%rax
  8041600a55:	00 00 00 
  8041600a58:	80 38 00             	cmpb   $0x0,(%rax)
  8041600a5b:	75 01                	jne    8041600a5e <serial_intr+0x10>
  8041600a5d:	c3                   	retq   
serial_intr(void) {
  8041600a5e:	55                   	push   %rbp
  8041600a5f:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600a62:	48 bf 58 05 60 41 80 	movabs $0x8041600558,%rdi
  8041600a69:	00 00 00 
  8041600a6c:	48 b8 72 05 60 41 80 	movabs $0x8041600572,%rax
  8041600a73:	00 00 00 
  8041600a76:	ff d0                	callq  *%rax
}
  8041600a78:	5d                   	pop    %rbp
  8041600a79:	c3                   	retq   

0000008041600a7a <fb_init>:
fb_init(void) {
  8041600a7a:	55                   	push   %rbp
  8041600a7b:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600a7e:	48 b8 00 70 61 41 80 	movabs $0x8041617000,%rax
  8041600a85:	00 00 00 
  8041600a88:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600a8b:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600a8e:	89 d0                	mov    %edx,%eax
  8041600a90:	a3 38 38 62 41 80 00 	movabs %eax,0x8041623838
  8041600a97:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600a99:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600a9c:	a3 34 38 62 41 80 00 	movabs %eax,0x8041623834
  8041600aa3:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600aa5:	c1 e8 03             	shr    $0x3,%eax
  8041600aa8:	89 c6                	mov    %eax,%esi
  8041600aaa:	a3 30 38 62 41 80 00 	movabs %eax,0x8041623830
  8041600ab1:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600ab3:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600ab6:	0f af d0             	imul   %eax,%edx
  8041600ab9:	89 d0                	mov    %edx,%eax
  8041600abb:	a3 2c 38 62 41 80 00 	movabs %eax,0x804162382c
  8041600ac2:	00 00 
  crt_pos           = crt_cols;
  8041600ac4:	89 f0                	mov    %esi,%eax
  8041600ac6:	66 a3 28 38 62 41 80 	movabs %ax,0x8041623828
  8041600acd:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600ad0:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600ad3:	be 00 00 00 00       	mov    $0x0,%esi
  8041600ad8:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600adf:	00 00 00 
  8041600ae2:	48 b8 22 50 60 41 80 	movabs $0x8041605022,%rax
  8041600ae9:	00 00 00 
  8041600aec:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600aee:	48 b8 3c 38 62 41 80 	movabs $0x804162383c,%rax
  8041600af5:	00 00 00 
  8041600af8:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600afb:	5d                   	pop    %rbp
  8041600afc:	c3                   	retq   

0000008041600afd <kbd_intr>:
kbd_intr(void) {
  8041600afd:	55                   	push   %rbp
  8041600afe:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600b01:	48 bf bb 05 60 41 80 	movabs $0x80416005bb,%rdi
  8041600b08:	00 00 00 
  8041600b0b:	48 b8 72 05 60 41 80 	movabs $0x8041600572,%rax
  8041600b12:	00 00 00 
  8041600b15:	ff d0                	callq  *%rax
}
  8041600b17:	5d                   	pop    %rbp
  8041600b18:	c3                   	retq   

0000008041600b19 <cons_getc>:
cons_getc(void) {
  8041600b19:	55                   	push   %rbp
  8041600b1a:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600b1d:	48 b8 4e 0a 60 41 80 	movabs $0x8041600a4e,%rax
  8041600b24:	00 00 00 
  8041600b27:	ff d0                	callq  *%rax
  kbd_intr();
  8041600b29:	48 b8 fd 0a 60 41 80 	movabs $0x8041600afd,%rax
  8041600b30:	00 00 00 
  8041600b33:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600b35:	48 b9 20 36 62 41 80 	movabs $0x8041623620,%rcx
  8041600b3c:	00 00 00 
  8041600b3f:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600b45:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600b4a:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600b50:	74 21                	je     8041600b73 <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600b52:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600b55:	48 b8 20 36 62 41 80 	movabs $0x8041623620,%rax
  8041600b5c:	00 00 00 
  8041600b5f:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600b65:	89 d2                	mov    %edx,%edx
  8041600b67:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600b6b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600b71:	74 02                	je     8041600b75 <cons_getc+0x5c>
}
  8041600b73:	5d                   	pop    %rbp
  8041600b74:	c3                   	retq   
      cons.rpos = 0;
  8041600b75:	48 be 20 38 62 41 80 	movabs $0x8041623820,%rsi
  8041600b7c:	00 00 00 
  8041600b7f:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600b85:	eb ec                	jmp    8041600b73 <cons_getc+0x5a>

0000008041600b87 <cons_init>:
  8041600b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600b8c:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600b91:	89 c8                	mov    %ecx,%eax
  8041600b93:	89 fa                	mov    %edi,%edx
  8041600b95:	ee                   	out    %al,(%dx)
  8041600b96:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600b9c:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600ba1:	44 89 ca             	mov    %r9d,%edx
  8041600ba4:	ee                   	out    %al,(%dx)
  8041600ba5:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600baa:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600baf:	89 f2                	mov    %esi,%edx
  8041600bb1:	ee                   	out    %al,(%dx)
  8041600bb2:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600bb8:	89 c8                	mov    %ecx,%eax
  8041600bba:	44 89 c2             	mov    %r8d,%edx
  8041600bbd:	ee                   	out    %al,(%dx)
  8041600bbe:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600bc3:	44 89 ca             	mov    %r9d,%edx
  8041600bc6:	ee                   	out    %al,(%dx)
  8041600bc7:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600bcc:	89 c8                	mov    %ecx,%eax
  8041600bce:	ee                   	out    %al,(%dx)
  8041600bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600bd4:	44 89 c2             	mov    %r8d,%edx
  8041600bd7:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600bd8:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600bdd:	ec                   	in     (%dx),%al
  8041600bde:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600be0:	3c ff                	cmp    $0xff,%al
  8041600be2:	0f 95 c0             	setne  %al
  8041600be5:	a2 2a 38 62 41 80 00 	movabs %al,0x804162382a
  8041600bec:	00 00 
  8041600bee:	89 fa                	mov    %edi,%edx
  8041600bf0:	ec                   	in     (%dx),%al
  8041600bf1:	89 f2                	mov    %esi,%edx
  8041600bf3:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600bf4:	80 f9 ff             	cmp    $0xff,%cl
  8041600bf7:	74 01                	je     8041600bfa <cons_init+0x73>
  8041600bf9:	c3                   	retq   
cons_init(void) {
  8041600bfa:	55                   	push   %rbp
  8041600bfb:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600bfe:	48 bf 12 54 60 41 80 	movabs $0x8041605412,%rdi
  8041600c05:	00 00 00 
  8041600c08:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600c0d:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041600c14:	00 00 00 
  8041600c17:	ff d2                	callq  *%rdx
}
  8041600c19:	5d                   	pop    %rbp
  8041600c1a:	c3                   	retq   

0000008041600c1b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600c1b:	55                   	push   %rbp
  8041600c1c:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600c1f:	48 b8 6d 07 60 41 80 	movabs $0x804160076d,%rax
  8041600c26:	00 00 00 
  8041600c29:	ff d0                	callq  *%rax
}
  8041600c2b:	5d                   	pop    %rbp
  8041600c2c:	c3                   	retq   

0000008041600c2d <getchar>:

int
getchar(void) {
  8041600c2d:	55                   	push   %rbp
  8041600c2e:	48 89 e5             	mov    %rsp,%rbp
  8041600c31:	53                   	push   %rbx
  8041600c32:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600c36:	48 bb 19 0b 60 41 80 	movabs $0x8041600b19,%rbx
  8041600c3d:	00 00 00 
  8041600c40:	ff d3                	callq  *%rbx
  8041600c42:	85 c0                	test   %eax,%eax
  8041600c44:	74 fa                	je     8041600c40 <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600c46:	48 83 c4 08          	add    $0x8,%rsp
  8041600c4a:	5b                   	pop    %rbx
  8041600c4b:	5d                   	pop    %rbp
  8041600c4c:	c3                   	retq   

0000008041600c4d <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600c4d:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600c52:	c3                   	retq   

0000008041600c53 <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600c53:	55                   	push   %rbp
  8041600c54:	48 89 e5             	mov    %rsp,%rbp
  8041600c57:	41 56                	push   %r14
  8041600c59:	41 55                	push   %r13
  8041600c5b:	41 54                	push   %r12
  8041600c5d:	53                   	push   %rbx
  8041600c5e:	48 83 ec 20          	sub    $0x20,%rsp
  8041600c62:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600c66:	83 fe 20             	cmp    $0x20,%esi
  8041600c69:	0f 87 48 09 00 00    	ja     80416015b7 <dwarf_read_abbrev_entry+0x964>
  8041600c6f:	44 89 c3             	mov    %r8d,%ebx
  8041600c72:	41 89 cd             	mov    %ecx,%r13d
  8041600c75:	49 89 d4             	mov    %rdx,%r12
  8041600c78:	89 f6                	mov    %esi,%esi
  8041600c7a:	48 b8 18 57 60 41 80 	movabs $0x8041605718,%rax
  8041600c81:	00 00 00 
  8041600c84:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600c87:	48 85 d2             	test   %rdx,%rdx
  8041600c8a:	74 75                	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
  8041600c8c:	83 f9 07             	cmp    $0x7,%ecx
  8041600c8f:	76 70                	jbe    8041600d01 <dwarf_read_abbrev_entry+0xae>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600c91:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600c96:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600c9a:	4c 89 e7             	mov    %r12,%rdi
  8041600c9d:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600ca4:	00 00 00 
  8041600ca7:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600ca9:	eb 56                	jmp    8041600d01 <dwarf_read_abbrev_entry+0xae>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB 2: Your code here:
      Dwarf_Half length = get_unaligned(entry, Dwarf_Half);
  8041600cab:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600cb0:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600cb4:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600cb8:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600cbf:	00 00 00 
  8041600cc2:	ff d0                	callq  *%rax
  8041600cc4:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Half);
  8041600cc8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600ccc:	48 83 c0 02          	add    $0x2,%rax
  8041600cd0:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600cd4:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600cd8:	0f b7 c3             	movzwl %bx,%eax
  8041600cdb:	89 45 d8             	mov    %eax,-0x28(%rbp)
          .mem = entry,
          .len = length,
      };
      if (buf) {
  8041600cde:	4d 85 e4             	test   %r12,%r12
  8041600ce1:	74 18                	je     8041600cfb <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600ce3:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600ce8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600cec:	4c 89 e7             	mov    %r12,%rdi
  8041600cef:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600cf6:	00 00 00 
  8041600cf9:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(Dwarf_Half) + length;
  8041600cfb:	0f b7 db             	movzwl %bx,%ebx
  8041600cfe:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600d01:	89 d8                	mov    %ebx,%eax
  8041600d03:	48 83 c4 20          	add    $0x20,%rsp
  8041600d07:	5b                   	pop    %rbx
  8041600d08:	41 5c                	pop    %r12
  8041600d0a:	41 5d                	pop    %r13
  8041600d0c:	41 5e                	pop    %r14
  8041600d0e:	5d                   	pop    %rbp
  8041600d0f:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600d10:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600d15:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d19:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d1d:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600d24:	00 00 00 
  8041600d27:	ff d0                	callq  *%rax
  8041600d29:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600d2c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600d30:	48 83 c0 04          	add    $0x4,%rax
  8041600d34:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600d38:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600d3c:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600d3f:	4d 85 e4             	test   %r12,%r12
  8041600d42:	74 18                	je     8041600d5c <dwarf_read_abbrev_entry+0x109>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600d44:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600d49:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d4d:	4c 89 e7             	mov    %r12,%rdi
  8041600d50:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600d57:	00 00 00 
  8041600d5a:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600d5c:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600d5f:	eb a0                	jmp    8041600d01 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600d61:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d66:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d6a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d6e:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600d75:	00 00 00 
  8041600d78:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600d7a:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600d7f:	4d 85 e4             	test   %r12,%r12
  8041600d82:	74 06                	je     8041600d8a <dwarf_read_abbrev_entry+0x137>
  8041600d84:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600d88:	77 0a                	ja     8041600d94 <dwarf_read_abbrev_entry+0x141>
      bytes = sizeof(Dwarf_Half);
  8041600d8a:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600d8f:	e9 6d ff ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600d94:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d99:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d9d:	4c 89 e7             	mov    %r12,%rdi
  8041600da0:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600da7:	00 00 00 
  8041600daa:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600dac:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600db1:	e9 4b ff ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600db6:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600dbb:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600dbf:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600dc3:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600dca:	00 00 00 
  8041600dcd:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600dcf:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600dd4:	4d 85 e4             	test   %r12,%r12
  8041600dd7:	74 06                	je     8041600ddf <dwarf_read_abbrev_entry+0x18c>
  8041600dd9:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600ddd:	77 0a                	ja     8041600de9 <dwarf_read_abbrev_entry+0x196>
      bytes = sizeof(uint32_t);
  8041600ddf:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600de4:	e9 18 ff ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  8041600de9:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600dee:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600df2:	4c 89 e7             	mov    %r12,%rdi
  8041600df5:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600dfc:	00 00 00 
  8041600dff:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600e01:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600e06:	e9 f6 fe ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600e0b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e10:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e14:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e18:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600e1f:	00 00 00 
  8041600e22:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600e24:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600e29:	4d 85 e4             	test   %r12,%r12
  8041600e2c:	74 06                	je     8041600e34 <dwarf_read_abbrev_entry+0x1e1>
  8041600e2e:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600e32:	77 0a                	ja     8041600e3e <dwarf_read_abbrev_entry+0x1eb>
      bytes = sizeof(uint64_t);
  8041600e34:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600e39:	e9 c3 fe ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041600e3e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e43:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e47:	4c 89 e7             	mov    %r12,%rdi
  8041600e4a:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600e51:	00 00 00 
  8041600e54:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600e56:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600e5b:	e9 a1 fe ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      if (buf && bufsize >= sizeof(char *)) {
  8041600e60:	48 85 d2             	test   %rdx,%rdx
  8041600e63:	74 05                	je     8041600e6a <dwarf_read_abbrev_entry+0x217>
  8041600e65:	83 f9 07             	cmp    $0x7,%ecx
  8041600e68:	77 18                	ja     8041600e82 <dwarf_read_abbrev_entry+0x22f>
      bytes = strlen(entry) + 1;
  8041600e6a:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600e6e:	48 b8 5a 4e 60 41 80 	movabs $0x8041604e5a,%rax
  8041600e75:	00 00 00 
  8041600e78:	ff d0                	callq  *%rax
  8041600e7a:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600e7d:	e9 7f fe ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        memcpy(buf, &entry, sizeof(char *));
  8041600e82:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e87:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600e8b:	4c 89 e7             	mov    %r12,%rdi
  8041600e8e:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600e95:	00 00 00 
  8041600e98:	ff d0                	callq  *%rax
  8041600e9a:	eb ce                	jmp    8041600e6a <dwarf_read_abbrev_entry+0x217>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600e9c:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600ea0:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600ea3:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600ead:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600eb2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600eb5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600eb9:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600ebc:	89 f0                	mov    %esi,%eax
  8041600ebe:	83 e0 7f             	and    $0x7f,%eax
  8041600ec1:	d3 e0                	shl    %cl,%eax
  8041600ec3:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600ec5:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600ec8:	40 84 f6             	test   %sil,%sil
  8041600ecb:	78 e5                	js     8041600eb2 <dwarf_read_abbrev_entry+0x25f>
      break;
  }

  *ret = result;

  return count;
  8041600ecd:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600ed0:	4d 01 e8             	add    %r13,%r8
  8041600ed3:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600ed7:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600edb:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600ede:	4d 85 e4             	test   %r12,%r12
  8041600ee1:	74 18                	je     8041600efb <dwarf_read_abbrev_entry+0x2a8>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600ee3:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600ee8:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600eec:	4c 89 e7             	mov    %r12,%rdi
  8041600eef:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600ef6:	00 00 00 
  8041600ef9:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600efb:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600efe:	e9 fe fd ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600f03:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f08:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f0c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f10:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600f17:	00 00 00 
  8041600f1a:	ff d0                	callq  *%rax
  8041600f1c:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041600f20:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600f24:	48 83 c0 01          	add    $0x1,%rax
  8041600f28:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600f2c:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600f30:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600f33:	4d 85 e4             	test   %r12,%r12
  8041600f36:	74 18                	je     8041600f50 <dwarf_read_abbrev_entry+0x2fd>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600f38:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600f3d:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f41:	4c 89 e7             	mov    %r12,%rdi
  8041600f44:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600f4b:	00 00 00 
  8041600f4e:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041600f50:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041600f53:	e9 a9 fd ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041600f58:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f5d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f61:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f65:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600f6c:	00 00 00 
  8041600f6f:	ff d0                	callq  *%rax
  8041600f71:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041600f75:	4d 85 e4             	test   %r12,%r12
  8041600f78:	0f 84 43 06 00 00    	je     80416015c1 <dwarf_read_abbrev_entry+0x96e>
  8041600f7e:	45 85 ed             	test   %r13d,%r13d
  8041600f81:	0f 84 3a 06 00 00    	je     80416015c1 <dwarf_read_abbrev_entry+0x96e>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f87:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041600f8b:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f90:	e9 6c fd ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600f95:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f9a:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f9e:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600fa2:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041600fa9:	00 00 00 
  8041600fac:	ff d0                	callq  *%rax
  8041600fae:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  8041600fb2:	4d 85 e4             	test   %r12,%r12
  8041600fb5:	0f 84 10 06 00 00    	je     80416015cb <dwarf_read_abbrev_entry+0x978>
  8041600fbb:	45 85 ed             	test   %r13d,%r13d
  8041600fbe:	0f 84 07 06 00 00    	je     80416015cb <dwarf_read_abbrev_entry+0x978>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600fc4:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  8041600fc6:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  8041600fcb:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  8041600fd0:	e9 2c fd ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      int count = dwarf_read_leb128(entry, &data);
  8041600fd5:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600fd9:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600fdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041600fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600fe6:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  8041600feb:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600fee:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  8041600ff2:	89 f0                	mov    %esi,%eax
  8041600ff4:	83 e0 7f             	and    $0x7f,%eax
  8041600ff7:	d3 e0                	shl    %cl,%eax
  8041600ff9:	09 c7                	or     %eax,%edi
    shift += 7;
  8041600ffb:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041600ffe:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  8041601001:	40 84 f6             	test   %sil,%sil
  8041601004:	78 e5                	js     8041600feb <dwarf_read_abbrev_entry+0x398>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  8041601006:	83 f9 1f             	cmp    $0x1f,%ecx
  8041601009:	7f 0f                	jg     804160101a <dwarf_read_abbrev_entry+0x3c7>
  804160100b:	40 f6 c6 40          	test   $0x40,%sil
  804160100f:	74 09                	je     804160101a <dwarf_read_abbrev_entry+0x3c7>
    result |= (-1U << shift);
  8041601011:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8041601016:	d3 e0                	shl    %cl,%eax
  8041601018:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  804160101a:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  804160101d:	49 01 c0             	add    %rax,%r8
  8041601020:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  8041601024:	4d 85 e4             	test   %r12,%r12
  8041601027:	0f 84 d4 fc ff ff    	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
  804160102d:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601031:	0f 86 ca fc ff ff    	jbe    8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (int *)buf);
  8041601037:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160103a:	ba 04 00 00 00       	mov    $0x4,%edx
  804160103f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601043:	4c 89 e7             	mov    %r12,%rdi
  8041601046:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160104d:	00 00 00 
  8041601050:	ff d0                	callq  *%rax
  8041601052:	e9 aa fc ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  8041601057:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160105b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601060:	4c 89 f6             	mov    %r14,%rsi
  8041601063:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601067:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160106e:	00 00 00 
  8041601071:	ff d0                	callq  *%rax
  8041601073:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601076:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601078:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160107d:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601080:	76 2a                	jbe    80416010ac <dwarf_read_abbrev_entry+0x459>
    if (initial_len == DW_EXT_DWARF64) {
  8041601082:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601085:	74 60                	je     80416010e7 <dwarf_read_abbrev_entry+0x494>
      cprintf("Unknown DWARF extension\n");
  8041601087:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  804160108e:	00 00 00 
  8041601091:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601096:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  804160109d:	00 00 00 
  80416010a0:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416010a2:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416010ac:	48 63 c3             	movslq %ebx,%rax
  80416010af:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416010b3:	4d 85 e4             	test   %r12,%r12
  80416010b6:	0f 84 45 fc ff ff    	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
  80416010bc:	41 83 fd 07          	cmp    $0x7,%r13d
  80416010c0:	0f 86 3b fc ff ff    	jbe    8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  80416010c6:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416010ca:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010cf:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416010d3:	4c 89 e7             	mov    %r12,%rdi
  80416010d6:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416010dd:	00 00 00 
  80416010e0:	ff d0                	callq  *%rax
  80416010e2:	e9 1a fc ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416010e7:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416010eb:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010f0:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416010f4:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416010fb:	00 00 00 
  80416010fe:	ff d0                	callq  *%rax
  8041601100:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  8041601104:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601109:	eb a1                	jmp    80416010ac <dwarf_read_abbrev_entry+0x459>
      int count         = dwarf_read_uleb128(entry, &data);
  804160110b:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  804160110f:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601112:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601117:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160111c:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601121:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601124:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601128:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160112b:	89 f0                	mov    %esi,%eax
  804160112d:	83 e0 7f             	and    $0x7f,%eax
  8041601130:	d3 e0                	shl    %cl,%eax
  8041601132:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601134:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601137:	40 84 f6             	test   %sil,%sil
  804160113a:	78 e5                	js     8041601121 <dwarf_read_abbrev_entry+0x4ce>
  return count;
  804160113c:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  804160113f:	49 01 c0             	add    %rax,%r8
  8041601142:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  8041601146:	4d 85 e4             	test   %r12,%r12
  8041601149:	0f 84 b2 fb ff ff    	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
  804160114f:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601153:	0f 86 a8 fb ff ff    	jbe    8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  8041601159:	89 7d d0             	mov    %edi,-0x30(%rbp)
  804160115c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601161:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601165:	4c 89 e7             	mov    %r12,%rdi
  8041601168:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160116f:	00 00 00 
  8041601172:	ff d0                	callq  *%rax
  8041601174:	e9 88 fb ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  8041601179:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160117d:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601182:	4c 89 f6             	mov    %r14,%rsi
  8041601185:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601189:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601190:	00 00 00 
  8041601193:	ff d0                	callq  *%rax
  8041601195:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601198:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160119a:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160119f:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416011a2:	76 2a                	jbe    80416011ce <dwarf_read_abbrev_entry+0x57b>
    if (initial_len == DW_EXT_DWARF64) {
  80416011a4:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416011a7:	74 60                	je     8041601209 <dwarf_read_abbrev_entry+0x5b6>
      cprintf("Unknown DWARF extension\n");
  80416011a9:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  80416011b0:	00 00 00 
  80416011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416011b8:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  80416011bf:	00 00 00 
  80416011c2:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416011c4:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416011c9:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416011ce:	48 63 c3             	movslq %ebx,%rax
  80416011d1:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416011d5:	4d 85 e4             	test   %r12,%r12
  80416011d8:	0f 84 23 fb ff ff    	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
  80416011de:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011e2:	0f 86 19 fb ff ff    	jbe    8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  80416011e8:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416011ec:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011f1:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011f5:	4c 89 e7             	mov    %r12,%rdi
  80416011f8:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416011ff:	00 00 00 
  8041601202:	ff d0                	callq  *%rax
  8041601204:	e9 f8 fa ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601209:	49 8d 76 20          	lea    0x20(%r14),%rsi
  804160120d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601212:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601216:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160121d:	00 00 00 
  8041601220:	ff d0                	callq  *%rax
  8041601222:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  8041601226:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160122b:	eb a1                	jmp    80416011ce <dwarf_read_abbrev_entry+0x57b>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  804160122d:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601232:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601236:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160123a:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601241:	00 00 00 
  8041601244:	ff d0                	callq  *%rax
  8041601246:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  804160124a:	4d 85 e4             	test   %r12,%r12
  804160124d:	0f 84 82 03 00 00    	je     80416015d5 <dwarf_read_abbrev_entry+0x982>
  8041601253:	45 85 ed             	test   %r13d,%r13d
  8041601256:	0f 84 79 03 00 00    	je     80416015d5 <dwarf_read_abbrev_entry+0x982>
        put_unaligned(data, (Dwarf_Small *)buf);
  804160125c:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601260:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601265:	e9 97 fa ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  804160126a:	ba 02 00 00 00       	mov    $0x2,%edx
  804160126f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601273:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601277:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160127e:	00 00 00 
  8041601281:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041601283:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041601288:	4d 85 e4             	test   %r12,%r12
  804160128b:	74 06                	je     8041601293 <dwarf_read_abbrev_entry+0x640>
  804160128d:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601291:	77 0a                	ja     804160129d <dwarf_read_abbrev_entry+0x64a>
      bytes = sizeof(Dwarf_Half);
  8041601293:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041601298:	e9 64 fa ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  804160129d:	ba 02 00 00 00       	mov    $0x2,%edx
  80416012a2:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012a6:	4c 89 e7             	mov    %r12,%rdi
  80416012a9:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416012b0:	00 00 00 
  80416012b3:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  80416012b5:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  80416012ba:	e9 42 fa ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416012bf:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012c4:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416012c8:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012cc:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416012d3:	00 00 00 
  80416012d6:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416012d8:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416012dd:	4d 85 e4             	test   %r12,%r12
  80416012e0:	74 06                	je     80416012e8 <dwarf_read_abbrev_entry+0x695>
  80416012e2:	41 83 fd 03          	cmp    $0x3,%r13d
  80416012e6:	77 0a                	ja     80416012f2 <dwarf_read_abbrev_entry+0x69f>
      bytes = sizeof(uint32_t);
  80416012e8:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416012ed:	e9 0f fa ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  80416012f2:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012f7:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012fb:	4c 89 e7             	mov    %r12,%rdi
  80416012fe:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601305:	00 00 00 
  8041601308:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  804160130a:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  804160130f:	e9 ed f9 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601314:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601319:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160131d:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601321:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601328:	00 00 00 
  804160132b:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  804160132d:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601332:	4d 85 e4             	test   %r12,%r12
  8041601335:	74 06                	je     804160133d <dwarf_read_abbrev_entry+0x6ea>
  8041601337:	41 83 fd 07          	cmp    $0x7,%r13d
  804160133b:	77 0a                	ja     8041601347 <dwarf_read_abbrev_entry+0x6f4>
      bytes = sizeof(uint64_t);
  804160133d:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041601342:	e9 ba f9 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041601347:	ba 08 00 00 00       	mov    $0x8,%edx
  804160134c:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601350:	4c 89 e7             	mov    %r12,%rdi
  8041601353:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160135a:	00 00 00 
  804160135d:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  804160135f:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041601364:	e9 98 f9 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601369:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  804160136d:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601370:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041601375:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160137a:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  804160137f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601382:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601386:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601389:	89 f0                	mov    %esi,%eax
  804160138b:	83 e0 7f             	and    $0x7f,%eax
  804160138e:	d3 e0                	shl    %cl,%eax
  8041601390:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601392:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601395:	40 84 f6             	test   %sil,%sil
  8041601398:	78 e5                	js     804160137f <dwarf_read_abbrev_entry+0x72c>
  return count;
  804160139a:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  804160139d:	49 01 c0             	add    %rax,%r8
  80416013a0:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  80416013a4:	4d 85 e4             	test   %r12,%r12
  80416013a7:	0f 84 54 f9 ff ff    	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
  80416013ad:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013b1:	0f 86 4a f9 ff ff    	jbe    8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  80416013b7:	89 7d d0             	mov    %edi,-0x30(%rbp)
  80416013ba:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013bf:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013c3:	4c 89 e7             	mov    %r12,%rdi
  80416013c6:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416013cd:	00 00 00 
  80416013d0:	ff d0                	callq  *%rax
  80416013d2:	e9 2a f9 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &form);
  80416013d7:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416013db:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416013de:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416013e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416013e9:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416013ee:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416013f2:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416013f6:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416013fa:	44 89 c0             	mov    %r8d,%eax
  80416013fd:	83 e0 7f             	and    $0x7f,%eax
  8041601400:	d3 e0                	shl    %cl,%eax
  8041601402:	09 c6                	or     %eax,%esi
    shift += 7;
  8041601404:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601407:	45 84 c0             	test   %r8b,%r8b
  804160140a:	78 e2                	js     80416013ee <dwarf_read_abbrev_entry+0x79b>
  return count;
  804160140c:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  804160140f:	48 01 c7             	add    %rax,%rdi
  8041601412:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  8041601416:	41 89 d8             	mov    %ebx,%r8d
  8041601419:	44 89 e9             	mov    %r13d,%ecx
  804160141c:	4c 89 e2             	mov    %r12,%rdx
  804160141f:	48 b8 53 0c 60 41 80 	movabs $0x8041600c53,%rax
  8041601426:	00 00 00 
  8041601429:	ff d0                	callq  *%rax
      bytes    = count + read;
  804160142b:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  804160142f:	e9 cd f8 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  8041601434:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601438:	ba 04 00 00 00       	mov    $0x4,%edx
  804160143d:	4c 89 f6             	mov    %r14,%rsi
  8041601440:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601444:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160144b:	00 00 00 
  804160144e:	ff d0                	callq  *%rax
  8041601450:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601453:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601455:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160145a:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160145d:	76 2a                	jbe    8041601489 <dwarf_read_abbrev_entry+0x836>
    if (initial_len == DW_EXT_DWARF64) {
  804160145f:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601462:	74 60                	je     80416014c4 <dwarf_read_abbrev_entry+0x871>
      cprintf("Unknown DWARF extension\n");
  8041601464:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  804160146b:	00 00 00 
  804160146e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601473:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  804160147a:	00 00 00 
  804160147d:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  804160147f:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  8041601484:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  8041601489:	48 63 c3             	movslq %ebx,%rax
  804160148c:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601490:	4d 85 e4             	test   %r12,%r12
  8041601493:	0f 84 68 f8 ff ff    	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
  8041601499:	41 83 fd 07          	cmp    $0x7,%r13d
  804160149d:	0f 86 5e f8 ff ff    	jbe    8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  80416014a3:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416014a7:	ba 08 00 00 00       	mov    $0x8,%edx
  80416014ac:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416014b0:	4c 89 e7             	mov    %r12,%rdi
  80416014b3:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416014ba:	00 00 00 
  80416014bd:	ff d0                	callq  *%rax
  80416014bf:	e9 3d f8 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416014c4:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416014c8:	ba 08 00 00 00       	mov    $0x8,%edx
  80416014cd:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416014d1:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416014d8:	00 00 00 
  80416014db:	ff d0                	callq  *%rax
  80416014dd:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416014e1:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416014e6:	eb a1                	jmp    8041601489 <dwarf_read_abbrev_entry+0x836>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416014e8:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416014ec:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416014ef:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416014f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014fa:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416014ff:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601502:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601506:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  804160150a:	89 f8                	mov    %edi,%eax
  804160150c:	83 e0 7f             	and    $0x7f,%eax
  804160150f:	d3 e0                	shl    %cl,%eax
  8041601511:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041601513:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601516:	40 84 ff             	test   %dil,%dil
  8041601519:	78 e4                	js     80416014ff <dwarf_read_abbrev_entry+0x8ac>
  return count;
  804160151b:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  804160151e:	4c 01 f6             	add    %r14,%rsi
  8041601521:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  8041601525:	4d 85 e4             	test   %r12,%r12
  8041601528:	74 1a                	je     8041601544 <dwarf_read_abbrev_entry+0x8f1>
        memcpy(buf, entry, MIN(length, bufsize));
  804160152a:	41 39 dd             	cmp    %ebx,%r13d
  804160152d:	44 89 ea             	mov    %r13d,%edx
  8041601530:	0f 47 d3             	cmova  %ebx,%edx
  8041601533:	89 d2                	mov    %edx,%edx
  8041601535:	4c 89 e7             	mov    %r12,%rdi
  8041601538:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160153f:	00 00 00 
  8041601542:	ff d0                	callq  *%rax
      bytes = count + length;
  8041601544:	44 01 f3             	add    %r14d,%ebx
    } break;
  8041601547:	e9 b5 f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      bytes = 0;
  804160154c:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  8041601551:	48 85 d2             	test   %rdx,%rdx
  8041601554:	0f 84 a7 f7 ff ff    	je     8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(true, (bool *)buf);
  804160155a:	c6 02 01             	movb   $0x1,(%rdx)
  804160155d:	e9 9f f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601562:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601567:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160156b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160156f:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601576:	00 00 00 
  8041601579:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  804160157b:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601580:	4d 85 e4             	test   %r12,%r12
  8041601583:	74 06                	je     804160158b <dwarf_read_abbrev_entry+0x938>
  8041601585:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601589:	77 0a                	ja     8041601595 <dwarf_read_abbrev_entry+0x942>
      bytes = sizeof(uint64_t);
  804160158b:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  8041601590:	e9 6c f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041601595:	ba 08 00 00 00       	mov    $0x8,%edx
  804160159a:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160159e:	4c 89 e7             	mov    %r12,%rdi
  80416015a1:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416015a8:	00 00 00 
  80416015ab:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  80416015ad:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  80416015b2:	e9 4a f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
  int bytes = 0;
  80416015b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416015bc:	e9 40 f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015c1:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015c6:	e9 36 f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015cb:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015d0:	e9 2c f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015d5:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015da:	e9 22 f7 ff ff       	jmpq   8041600d01 <dwarf_read_abbrev_entry+0xae>

00000080416015df <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416015df:	55                   	push   %rbp
  80416015e0:	48 89 e5             	mov    %rsp,%rbp
  80416015e3:	41 57                	push   %r15
  80416015e5:	41 56                	push   %r14
  80416015e7:	41 55                	push   %r13
  80416015e9:	41 54                	push   %r12
  80416015eb:	53                   	push   %rbx
  80416015ec:	48 83 ec 48          	sub    $0x48,%rsp
  80416015f0:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80416015f4:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416015f8:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  80416015fc:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601600:	49 bd d3 50 60 41 80 	movabs $0x80416050d3,%r13
  8041601607:	00 00 00 
  804160160a:	e9 bb 01 00 00       	jmpq   80416017ca <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160160f:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601613:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601618:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160161c:	41 ff d5             	callq  *%r13
  804160161f:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  8041601623:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601628:	eb 08                	jmp    8041601632 <info_by_address+0x53>
    *len = initial_len;
  804160162a:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  804160162d:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  8041601632:	4c 63 fb             	movslq %ebx,%r15
  8041601635:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  8041601639:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  804160163c:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601641:	48 89 de             	mov    %rbx,%rsi
  8041601644:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601648:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  804160164b:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  804160164f:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041601654:	75 7a                	jne    80416016d0 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  8041601656:	ba 04 00 00 00       	mov    $0x4,%edx
  804160165b:	48 89 de             	mov    %rbx,%rsi
  804160165e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601662:	41 ff d5             	callq  *%r13
  8041601665:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041601668:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  804160166b:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  804160166e:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  8041601672:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601677:	48 89 de             	mov    %rbx,%rsi
  804160167a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160167e:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  8041601681:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041601685:	75 7e                	jne    8041601705 <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  8041601687:	48 83 c3 02          	add    $0x2,%rbx
  804160168b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601690:	4c 89 fe             	mov    %r15,%rsi
  8041601693:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601697:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  804160169a:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  804160169e:	0f 85 96 00 00 00    	jne    804160173a <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  80416016a4:	48 89 d8             	mov    %rbx,%rax
  80416016a7:	4c 29 f0             	sub    %r14,%rax
  80416016aa:	48 99                	cqto   
  80416016ac:	48 c1 ea 3c          	shr    $0x3c,%rdx
  80416016b0:	48 01 d0             	add    %rdx,%rax
  80416016b3:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  80416016b6:	48 29 d0             	sub    %rdx,%rax
  80416016b9:	0f 84 b5 00 00 00    	je     8041601774 <info_by_address+0x195>
      set += 2 * address_size - remainder;
  80416016bf:	ba 10 00 00 00       	mov    $0x10,%edx
  80416016c4:	89 d1                	mov    %edx,%ecx
  80416016c6:	29 c1                	sub    %eax,%ecx
  80416016c8:	48 01 cb             	add    %rcx,%rbx
  80416016cb:	e9 a4 00 00 00       	jmpq   8041601774 <info_by_address+0x195>
    assert(version == 2);
  80416016d0:	48 b9 de 56 60 41 80 	movabs $0x80416056de,%rcx
  80416016d7:	00 00 00 
  80416016da:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  80416016e1:	00 00 00 
  80416016e4:	be 20 00 00 00       	mov    $0x20,%esi
  80416016e9:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  80416016f0:	00 00 00 
  80416016f3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416016f8:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  80416016ff:	00 00 00 
  8041601702:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601705:	48 b9 9b 56 60 41 80 	movabs $0x804160569b,%rcx
  804160170c:	00 00 00 
  804160170f:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601716:	00 00 00 
  8041601719:	be 24 00 00 00       	mov    $0x24,%esi
  804160171e:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601725:	00 00 00 
  8041601728:	b8 00 00 00 00       	mov    $0x0,%eax
  804160172d:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601734:	00 00 00 
  8041601737:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  804160173a:	48 b9 ad 56 60 41 80 	movabs $0x80416056ad,%rcx
  8041601741:	00 00 00 
  8041601744:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  804160174b:	00 00 00 
  804160174e:	be 26 00 00 00       	mov    $0x26,%esi
  8041601753:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  804160175a:	00 00 00 
  804160175d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601762:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601769:	00 00 00 
  804160176c:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  804160176f:	4c 39 e3             	cmp    %r12,%rbx
  8041601772:	73 51                	jae    80416017c5 <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  8041601774:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601779:	48 89 de             	mov    %rbx,%rsi
  804160177c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601780:	41 ff d5             	callq  *%r13
  8041601783:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  8041601787:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  804160178b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601790:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601794:	41 ff d5             	callq  *%r13
  8041601797:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  804160179a:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  804160179e:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  80416017a2:	4c 39 f1             	cmp    %r14,%rcx
  80416017a5:	72 c8                	jb     804160176f <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  80416017a7:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  80416017a9:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  80416017ac:	48 39 c1             	cmp    %rax,%rcx
  80416017af:	77 be                	ja     804160176f <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  80416017b1:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416017b5:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  80416017b8:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  80416017bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017c0:	e9 5a 04 00 00       	jmpq   8041601c1f <info_by_address+0x640>
      set += address_size;
  80416017c5:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  80416017c8:	75 71                	jne    804160183b <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  80416017ca:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416017ce:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  80416017d2:	73 42                	jae    8041601816 <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  80416017d4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416017d9:	4c 89 f6             	mov    %r14,%rsi
  80416017dc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017e0:	41 ff d5             	callq  *%r13
  80416017e3:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416017e7:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  80416017eb:	0f 86 39 fe ff ff    	jbe    804160162a <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  80416017f1:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  80416017f5:	0f 84 14 fe ff ff    	je     804160160f <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  80416017fb:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  8041601802:	00 00 00 
  8041601805:	b8 00 00 00 00       	mov    $0x0,%eax
  804160180a:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041601811:	00 00 00 
  8041601814:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  8041601816:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  804160181a:	48 8b 58 20          	mov    0x20(%rax),%rbx
  804160181e:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601822:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  8041601826:	0f 83 5b 04 00 00    	jae    8041601c87 <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  804160182c:	49 bf d3 50 60 41 80 	movabs $0x80416050d3,%r15
  8041601833:	00 00 00 
  8041601836:	e9 9f 03 00 00       	jmpq   8041601bda <info_by_address+0x5fb>
    assert(set == set_end);
  804160183b:	48 b9 bf 56 60 41 80 	movabs $0x80416056bf,%rcx
  8041601842:	00 00 00 
  8041601845:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  804160184c:	00 00 00 
  804160184f:	be 3a 00 00 00       	mov    $0x3a,%esi
  8041601854:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  804160185b:	00 00 00 
  804160185e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601863:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  804160186a:	00 00 00 
  804160186d:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601870:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601874:	48 8d 70 20          	lea    0x20(%rax),%rsi
  8041601878:	ba 08 00 00 00       	mov    $0x8,%edx
  804160187d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601881:	41 ff d7             	callq  *%r15
  8041601884:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041601888:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  804160188e:	eb 08                	jmp    8041601898 <info_by_address+0x2b9>
    *len = initial_len;
  8041601890:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041601892:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  8041601898:	4d 63 e4             	movslq %r12d,%r12
  804160189b:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  804160189f:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  80416018a3:	48 01 d8             	add    %rbx,%rax
  80416018a6:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416018aa:	ba 02 00 00 00       	mov    $0x2,%edx
  80416018af:	48 89 de             	mov    %rbx,%rsi
  80416018b2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018b6:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  80416018b9:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  80416018bd:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416018c1:	83 e8 02             	sub    $0x2,%eax
  80416018c4:	66 a9 fd ff          	test   $0xfffd,%ax
  80416018c8:	0f 85 07 01 00 00    	jne    80416019d5 <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416018ce:	ba 04 00 00 00       	mov    $0x4,%edx
  80416018d3:	48 89 de             	mov    %rbx,%rsi
  80416018d6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018da:	41 ff d7             	callq  *%r15
  80416018dd:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  80416018e1:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416018e5:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  80416018e9:	ba 01 00 00 00       	mov    $0x1,%edx
  80416018ee:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018f2:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  80416018f5:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416018f9:	0f 85 0b 01 00 00    	jne    8041601a0a <info_by_address+0x42b>
  80416018ff:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  8041601902:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601907:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160190c:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601911:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601915:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601919:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  804160191c:	44 89 c7             	mov    %r8d,%edi
  804160191f:	83 e7 7f             	and    $0x7f,%edi
  8041601922:	d3 e7                	shl    %cl,%edi
  8041601924:	09 fa                	or     %edi,%edx
    shift += 7;
  8041601926:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601929:	45 84 c0             	test   %r8b,%r8b
  804160192c:	78 e3                	js     8041601911 <info_by_address+0x332>
  return count;
  804160192e:	48 98                	cltq   
    assert(abbrev_code != 0);
  8041601930:	85 d2                	test   %edx,%edx
  8041601932:	0f 84 07 01 00 00    	je     8041601a3f <info_by_address+0x460>
    entry += count;
  8041601938:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  804160193b:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  804160193f:	4c 03 28             	add    (%rax),%r13
  8041601942:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  8041601945:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  804160194a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160194f:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041601954:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041601958:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  804160195c:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  804160195f:	45 89 c8             	mov    %r9d,%r8d
  8041601962:	41 83 e0 7f          	and    $0x7f,%r8d
  8041601966:	41 d3 e0             	shl    %cl,%r8d
  8041601969:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  804160196c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160196f:	45 84 c9             	test   %r9b,%r9b
  8041601972:	78 e0                	js     8041601954 <info_by_address+0x375>
  return count;
  8041601974:	48 98                	cltq   
    abbrev_entry += count;
  8041601976:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  8041601979:	39 f2                	cmp    %esi,%edx
  804160197b:	0f 85 f3 00 00 00    	jne    8041601a74 <info_by_address+0x495>
  8041601981:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  8041601984:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601989:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160198e:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601993:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  8041601997:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  804160199b:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  804160199e:	44 89 c7             	mov    %r8d,%edi
  80416019a1:	83 e7 7f             	and    $0x7f,%edi
  80416019a4:	d3 e7                	shl    %cl,%edi
  80416019a6:	09 fa                	or     %edi,%edx
    shift += 7;
  80416019a8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416019ab:	45 84 c0             	test   %r8b,%r8b
  80416019ae:	78 e3                	js     8041601993 <info_by_address+0x3b4>
  return count;
  80416019b0:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  80416019b2:	83 fa 11             	cmp    $0x11,%edx
  80416019b5:	0f 85 ee 00 00 00    	jne    8041601aa9 <info_by_address+0x4ca>
    abbrev_entry++;
  80416019bb:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  80416019c0:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  80416019c7:	00 
  80416019c8:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  80416019cf:	00 
  80416019d0:	e9 2f 01 00 00       	jmpq   8041601b04 <info_by_address+0x525>
    assert(version == 4 || version == 2);
  80416019d5:	48 b9 ce 56 60 41 80 	movabs $0x80416056ce,%rcx
  80416019dc:	00 00 00 
  80416019df:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  80416019e6:	00 00 00 
  80416019e9:	be 40 01 00 00       	mov    $0x140,%esi
  80416019ee:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  80416019f5:	00 00 00 
  80416019f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416019fd:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601a04:	00 00 00 
  8041601a07:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601a0a:	48 b9 9b 56 60 41 80 	movabs $0x804160569b,%rcx
  8041601a11:	00 00 00 
  8041601a14:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601a1b:	00 00 00 
  8041601a1e:	be 44 01 00 00       	mov    $0x144,%esi
  8041601a23:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601a2a:	00 00 00 
  8041601a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601a32:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601a39:	00 00 00 
  8041601a3c:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601a3f:	48 b9 eb 56 60 41 80 	movabs $0x80416056eb,%rcx
  8041601a46:	00 00 00 
  8041601a49:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601a50:	00 00 00 
  8041601a53:	be 49 01 00 00       	mov    $0x149,%esi
  8041601a58:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601a5f:	00 00 00 
  8041601a62:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601a67:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601a6e:	00 00 00 
  8041601a71:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601a74:	48 b9 20 58 60 41 80 	movabs $0x8041605820,%rcx
  8041601a7b:	00 00 00 
  8041601a7e:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601a85:	00 00 00 
  8041601a88:	be 51 01 00 00       	mov    $0x151,%esi
  8041601a8d:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601a94:	00 00 00 
  8041601a97:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601a9c:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601aa3:	00 00 00 
  8041601aa6:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601aa9:	48 b9 fc 56 60 41 80 	movabs $0x80416056fc,%rcx
  8041601ab0:	00 00 00 
  8041601ab3:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601aba:	00 00 00 
  8041601abd:	be 55 01 00 00       	mov    $0x155,%esi
  8041601ac2:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601ac9:	00 00 00 
  8041601acc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ad1:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601ad8:	00 00 00 
  8041601adb:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601ade:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601ae4:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601ae9:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601aed:	44 89 f6             	mov    %r14d,%esi
  8041601af0:	4c 89 e7             	mov    %r12,%rdi
  8041601af3:	48 b8 53 0c 60 41 80 	movabs $0x8041600c53,%rax
  8041601afa:	00 00 00 
  8041601afd:	ff d0                	callq  *%rax
      entry += count;
  8041601aff:	48 98                	cltq   
  8041601b01:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601b04:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601b07:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601b0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601b11:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601b17:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601b1a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601b1e:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601b21:	89 fe                	mov    %edi,%esi
  8041601b23:	83 e6 7f             	and    $0x7f,%esi
  8041601b26:	d3 e6                	shl    %cl,%esi
  8041601b28:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601b2b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601b2e:	40 84 ff             	test   %dil,%dil
  8041601b31:	78 e4                	js     8041601b17 <info_by_address+0x538>
  return count;
  8041601b33:	48 98                	cltq   
      abbrev_entry += count;
  8041601b35:	48 01 c3             	add    %rax,%rbx
  8041601b38:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601b40:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601b45:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601b4b:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601b4e:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601b52:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601b55:	89 fe                	mov    %edi,%esi
  8041601b57:	83 e6 7f             	and    $0x7f,%esi
  8041601b5a:	d3 e6                	shl    %cl,%esi
  8041601b5c:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601b5f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601b62:	40 84 ff             	test   %dil,%dil
  8041601b65:	78 e4                	js     8041601b4b <info_by_address+0x56c>
  return count;
  8041601b67:	48 98                	cltq   
      abbrev_entry += count;
  8041601b69:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601b6c:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601b70:	0f 84 68 ff ff ff    	je     8041601ade <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601b76:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601b7a:	0f 84 ae 00 00 00    	je     8041601c2e <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601b80:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601b90:	44 89 f6             	mov    %r14d,%esi
  8041601b93:	4c 89 e7             	mov    %r12,%rdi
  8041601b96:	48 b8 53 0c 60 41 80 	movabs $0x8041600c53,%rax
  8041601b9d:	00 00 00 
  8041601ba0:	ff d0                	callq  *%rax
      entry += count;
  8041601ba2:	48 98                	cltq   
  8041601ba4:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601ba7:	45 09 f5             	or     %r14d,%r13d
  8041601baa:	0f 85 54 ff ff ff    	jne    8041601b04 <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601bb0:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601bb4:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601bb8:	72 0a                	jb     8041601bc4 <info_by_address+0x5e5>
  8041601bba:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601bbe:	0f 86 a2 00 00 00    	jbe    8041601c66 <info_by_address+0x687>
    entry = entry_end;
  8041601bc4:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601bc8:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601bcc:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601bd0:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601bd4:	0f 83 a6 00 00 00    	jae    8041601c80 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601bda:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601bdf:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601be3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601be7:	41 ff d7             	callq  *%r15
  8041601bea:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601bed:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601bf0:	0f 86 9a fc ff ff    	jbe    8041601890 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601bf6:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601bf9:	0f 84 71 fc ff ff    	je     8041601870 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601bff:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  8041601c06:	00 00 00 
  8041601c09:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c0e:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041601c15:	00 00 00 
  8041601c18:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601c1a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601c1f:	48 83 c4 48          	add    $0x48,%rsp
  8041601c23:	5b                   	pop    %rbx
  8041601c24:	41 5c                	pop    %r12
  8041601c26:	41 5d                	pop    %r13
  8041601c28:	41 5e                	pop    %r14
  8041601c2a:	41 5f                	pop    %r15
  8041601c2c:	5d                   	pop    %rbp
  8041601c2d:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601c2e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c34:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601c39:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601c3d:	44 89 f6             	mov    %r14d,%esi
  8041601c40:	4c 89 e7             	mov    %r12,%rdi
  8041601c43:	48 b8 53 0c 60 41 80 	movabs $0x8041600c53,%rax
  8041601c4a:	00 00 00 
  8041601c4d:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601c4f:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601c53:	0f 84 a6 fe ff ff    	je     8041601aff <info_by_address+0x520>
          high_pc += low_pc;
  8041601c59:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601c5d:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601c61:	e9 99 fe ff ff       	jmpq   8041601aff <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601c66:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601c6a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601c6e:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601c72:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601c76:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601c79:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c7e:	eb 9f                	jmp    8041601c1f <info_by_address+0x640>
  return 0;
  8041601c80:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c85:	eb 98                	jmp    8041601c1f <info_by_address+0x640>
  8041601c87:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c8c:	eb 91                	jmp    8041601c1f <info_by_address+0x640>

0000008041601c8e <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601c8e:	55                   	push   %rbp
  8041601c8f:	48 89 e5             	mov    %rsp,%rbp
  8041601c92:	41 57                	push   %r15
  8041601c94:	41 56                	push   %r14
  8041601c96:	41 55                	push   %r13
  8041601c98:	41 54                	push   %r12
  8041601c9a:	53                   	push   %rbx
  8041601c9b:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601c9f:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601ca3:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601ca7:	48 29 d8             	sub    %rbx,%rax
  8041601caa:	48 39 f0             	cmp    %rsi,%rax
  8041601cad:	0f 82 f5 02 00 00    	jb     8041601fa8 <file_name_by_info+0x31a>
  8041601cb3:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601cb7:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601cba:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601cbe:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601cc2:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601cc5:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601cca:	48 89 de             	mov    %rbx,%rsi
  8041601ccd:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601cd1:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601cd8:	00 00 00 
  8041601cdb:	ff d0                	callq  *%rax
  8041601cdd:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601ce0:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601ce3:	0f 86 c9 02 00 00    	jbe    8041601fb2 <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601ce9:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601cec:	74 25                	je     8041601d13 <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601cee:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  8041601cf5:	00 00 00 
  8041601cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cfd:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041601d04:	00 00 00 
  8041601d07:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601d09:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601d0e:	e9 00 02 00 00       	jmpq   8041601f13 <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601d13:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601d17:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601d1c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d20:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601d27:	00 00 00 
  8041601d2a:	ff d0                	callq  *%rax
      count = 12;
  8041601d2c:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601d32:	e9 81 02 00 00       	jmpq   8041601fb8 <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601d37:	48 b9 ce 56 60 41 80 	movabs $0x80416056ce,%rcx
  8041601d3e:	00 00 00 
  8041601d41:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601d48:	00 00 00 
  8041601d4b:	be 98 01 00 00       	mov    $0x198,%esi
  8041601d50:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601d57:	00 00 00 
  8041601d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d5f:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601d66:	00 00 00 
  8041601d69:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601d6c:	48 b9 9b 56 60 41 80 	movabs $0x804160569b,%rcx
  8041601d73:	00 00 00 
  8041601d76:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601d7d:	00 00 00 
  8041601d80:	be 9c 01 00 00       	mov    $0x19c,%esi
  8041601d85:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601d8c:	00 00 00 
  8041601d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d94:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601d9b:	00 00 00 
  8041601d9e:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601da1:	48 b9 eb 56 60 41 80 	movabs $0x80416056eb,%rcx
  8041601da8:	00 00 00 
  8041601dab:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601db2:	00 00 00 
  8041601db5:	be a1 01 00 00       	mov    $0x1a1,%esi
  8041601dba:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601dc1:	00 00 00 
  8041601dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dc9:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601dd0:	00 00 00 
  8041601dd3:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601dd6:	48 b9 20 58 60 41 80 	movabs $0x8041605820,%rcx
  8041601ddd:	00 00 00 
  8041601de0:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601de7:	00 00 00 
  8041601dea:	be a9 01 00 00       	mov    $0x1a9,%esi
  8041601def:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601df6:	00 00 00 
  8041601df9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dfe:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601e05:	00 00 00 
  8041601e08:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601e0b:	48 b9 fc 56 60 41 80 	movabs $0x80416056fc,%rcx
  8041601e12:	00 00 00 
  8041601e15:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041601e1c:	00 00 00 
  8041601e1f:	be ad 01 00 00       	mov    $0x1ad,%esi
  8041601e24:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041601e2b:	00 00 00 
  8041601e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e33:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041601e3a:	00 00 00 
  8041601e3d:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601e40:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601e44:	0f 84 d8 00 00 00    	je     8041601f22 <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601e4a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601e50:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601e53:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601e57:	44 89 ee             	mov    %r13d,%esi
  8041601e5a:	4c 89 f7             	mov    %r14,%rdi
  8041601e5d:	41 ff d7             	callq  *%r15
  8041601e60:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601e63:	49 63 c4             	movslq %r12d,%rax
  8041601e66:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601e69:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601e6c:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601e71:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601e76:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601e7c:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601e7f:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601e83:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601e86:	89 f0                	mov    %esi,%eax
  8041601e88:	83 e0 7f             	and    $0x7f,%eax
  8041601e8b:	d3 e0                	shl    %cl,%eax
  8041601e8d:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601e90:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601e93:	40 84 f6             	test   %sil,%sil
  8041601e96:	78 e4                	js     8041601e7c <file_name_by_info+0x1ee>
  return count;
  8041601e98:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601e9b:	48 01 fb             	add    %rdi,%rbx
  8041601e9e:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601ea1:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601ea6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601eab:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601eb1:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601eb4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601eb8:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601ebb:	89 f0                	mov    %esi,%eax
  8041601ebd:	83 e0 7f             	and    $0x7f,%eax
  8041601ec0:	d3 e0                	shl    %cl,%eax
  8041601ec2:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601ec5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601ec8:	40 84 f6             	test   %sil,%sil
  8041601ecb:	78 e4                	js     8041601eb1 <file_name_by_info+0x223>
  return count;
  8041601ecd:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601ed0:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041601ed3:	41 83 fc 03          	cmp    $0x3,%r12d
  8041601ed7:	0f 84 63 ff ff ff    	je     8041601e40 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041601edd:	41 83 fc 10          	cmp    $0x10,%r12d
  8041601ee1:	0f 84 a1 00 00 00    	je     8041601f88 <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601ee7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601eed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601ef2:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601ef7:	44 89 ee             	mov    %r13d,%esi
  8041601efa:	4c 89 f7             	mov    %r14,%rdi
  8041601efd:	41 ff d7             	callq  *%r15
    entry += count;
  8041601f00:	48 98                	cltq   
  8041601f02:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601f05:	45 09 e5             	or     %r12d,%r13d
  8041601f08:	0f 85 5b ff ff ff    	jne    8041601e69 <file_name_by_info+0x1db>

  return 0;
  8041601f0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601f13:	48 83 c4 38          	add    $0x38,%rsp
  8041601f17:	5b                   	pop    %rbx
  8041601f18:	41 5c                	pop    %r12
  8041601f1a:	41 5d                	pop    %r13
  8041601f1c:	41 5e                	pop    %r14
  8041601f1e:	41 5f                	pop    %r15
  8041601f20:	5d                   	pop    %rbp
  8041601f21:	c3                   	retq   
        unsigned long offset = 0;
  8041601f22:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601f29:	00 
        count                = dwarf_read_abbrev_entry(
  8041601f2a:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f30:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601f35:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601f39:	be 0e 00 00 00       	mov    $0xe,%esi
  8041601f3e:	4c 89 f7             	mov    %r14,%rdi
  8041601f41:	41 ff d7             	callq  *%r15
  8041601f44:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  8041601f47:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041601f4b:	48 85 ff             	test   %rdi,%rdi
  8041601f4e:	0f 84 0f ff ff ff    	je     8041601e63 <file_name_by_info+0x1d5>
  8041601f54:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  8041601f58:	0f 86 05 ff ff ff    	jbe    8041601e63 <file_name_by_info+0x1d5>
          put_unaligned(
  8041601f5e:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041601f62:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  8041601f66:	48 03 41 40          	add    0x40(%rcx),%rax
  8041601f6a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041601f6e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601f73:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041601f77:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601f7e:	00 00 00 
  8041601f81:	ff d0                	callq  *%rax
  8041601f83:	e9 db fe ff ff       	jmpq   8041601e63 <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  8041601f88:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f8e:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601f93:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041601f97:	44 89 ee             	mov    %r13d,%esi
  8041601f9a:	4c 89 f7             	mov    %r14,%rdi
  8041601f9d:	41 ff d7             	callq  *%r15
  8041601fa0:	41 89 c4             	mov    %eax,%r12d
  8041601fa3:	e9 bb fe ff ff       	jmpq   8041601e63 <file_name_by_info+0x1d5>
    return -E_INVAL;
  8041601fa8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041601fad:	e9 61 ff ff ff       	jmpq   8041601f13 <file_name_by_info+0x285>
  count       = 4;
  8041601fb2:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  8041601fb8:	4d 63 ed             	movslq %r13d,%r13
  8041601fbb:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601fbe:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601fc3:	48 89 de             	mov    %rbx,%rsi
  8041601fc6:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601fca:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041601fd1:	00 00 00 
  8041601fd4:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  8041601fd6:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  8041601fda:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601fde:	83 e8 02             	sub    $0x2,%eax
  8041601fe1:	66 a9 fd ff          	test   $0xfffd,%ax
  8041601fe5:	0f 85 4c fd ff ff    	jne    8041601d37 <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601feb:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601ff0:	48 89 de             	mov    %rbx,%rsi
  8041601ff3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601ff7:	49 bf d3 50 60 41 80 	movabs $0x80416050d3,%r15
  8041601ffe:	00 00 00 
  8041602001:	41 ff d7             	callq  *%r15
  8041602004:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  8041602008:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  804160200c:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602010:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602015:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602019:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  804160201c:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602020:	0f 85 46 fd ff ff    	jne    8041601d6c <file_name_by_info+0xde>
  8041602026:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602029:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160202e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602033:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602039:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160203c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602040:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602043:	89 f0                	mov    %esi,%eax
  8041602045:	83 e0 7f             	and    $0x7f,%eax
  8041602048:	d3 e0                	shl    %cl,%eax
  804160204a:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  804160204d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602050:	40 84 f6             	test   %sil,%sil
  8041602053:	78 e4                	js     8041602039 <file_name_by_info+0x3ab>
  return count;
  8041602055:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  8041602058:	45 85 c0             	test   %r8d,%r8d
  804160205b:	0f 84 40 fd ff ff    	je     8041601da1 <file_name_by_info+0x113>
  entry += count;
  8041602061:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041602064:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041602068:	4c 03 20             	add    (%rax),%r12
  804160206b:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  804160206e:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602073:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602078:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160207e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602081:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602085:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602088:	89 f0                	mov    %esi,%eax
  804160208a:	83 e0 7f             	and    $0x7f,%eax
  804160208d:	d3 e0                	shl    %cl,%eax
  804160208f:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602092:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602095:	40 84 f6             	test   %sil,%sil
  8041602098:	78 e4                	js     804160207e <file_name_by_info+0x3f0>
  return count;
  804160209a:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  804160209d:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  80416020a0:	45 39 c8             	cmp    %r9d,%r8d
  80416020a3:	0f 85 2d fd ff ff    	jne    8041601dd6 <file_name_by_info+0x148>
  80416020a9:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  80416020ac:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416020b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416020b6:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416020bc:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416020bf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416020c3:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416020c6:	89 f0                	mov    %esi,%eax
  80416020c8:	83 e0 7f             	and    $0x7f,%eax
  80416020cb:	d3 e0                	shl    %cl,%eax
  80416020cd:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416020d0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416020d3:	40 84 f6             	test   %sil,%sil
  80416020d6:	78 e4                	js     80416020bc <file_name_by_info+0x42e>
  return count;
  80416020d8:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  80416020db:	41 83 f8 11          	cmp    $0x11,%r8d
  80416020df:	0f 85 26 fd ff ff    	jne    8041601e0b <file_name_by_info+0x17d>
  abbrev_entry++;
  80416020e5:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  80416020ea:	49 bf 53 0c 60 41 80 	movabs $0x8041600c53,%r15
  80416020f1:	00 00 00 
  80416020f4:	e9 70 fd ff ff       	jmpq   8041601e69 <file_name_by_info+0x1db>

00000080416020f9 <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  80416020f9:	55                   	push   %rbp
  80416020fa:	48 89 e5             	mov    %rsp,%rbp
  80416020fd:	41 57                	push   %r15
  80416020ff:	41 56                	push   %r14
  8041602101:	41 55                	push   %r13
  8041602103:	41 54                	push   %r12
  8041602105:	53                   	push   %rbx
  8041602106:	48 83 ec 68          	sub    $0x68,%rsp
  804160210a:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  804160210e:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  8041602115:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  8041602119:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  804160211d:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  8041602124:	48 89 d3             	mov    %rdx,%rbx
  8041602127:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160212b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602130:	48 89 de             	mov    %rbx,%rsi
  8041602133:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602137:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160213e:	00 00 00 
  8041602141:	ff d0                	callq  *%rax
  8041602143:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602146:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602149:	76 59                	jbe    80416021a4 <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  804160214b:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160214e:	74 2f                	je     804160217f <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602150:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  8041602157:	00 00 00 
  804160215a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160215f:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041602166:	00 00 00 
  8041602169:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  804160216b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602170:	48 83 c4 68          	add    $0x68,%rsp
  8041602174:	5b                   	pop    %rbx
  8041602175:	41 5c                	pop    %r12
  8041602177:	41 5d                	pop    %r13
  8041602179:	41 5e                	pop    %r14
  804160217b:	41 5f                	pop    %r15
  804160217d:	5d                   	pop    %rbp
  804160217e:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160217f:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041602183:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602188:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160218c:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041602193:	00 00 00 
  8041602196:	ff d0                	callq  *%rax
  8041602198:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160219c:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  80416021a2:	eb 08                	jmp    80416021ac <function_by_info+0xb3>
    *len = initial_len;
  80416021a4:	89 c0                	mov    %eax,%eax
  count       = 4;
  80416021a6:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  80416021ac:	4d 63 f6             	movslq %r14d,%r14
  80416021af:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  80416021b2:	48 01 d8             	add    %rbx,%rax
  80416021b5:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416021b9:	ba 02 00 00 00       	mov    $0x2,%edx
  80416021be:	48 89 de             	mov    %rbx,%rsi
  80416021c1:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021c5:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416021cc:	00 00 00 
  80416021cf:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416021d1:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416021d5:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416021d9:	83 e8 02             	sub    $0x2,%eax
  80416021dc:	66 a9 fd ff          	test   $0xfffd,%ax
  80416021e0:	75 51                	jne    8041602233 <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416021e2:	ba 04 00 00 00       	mov    $0x4,%edx
  80416021e7:	48 89 de             	mov    %rbx,%rsi
  80416021ea:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021ee:	49 bc d3 50 60 41 80 	movabs $0x80416050d3,%r12
  80416021f5:	00 00 00 
  80416021f8:	41 ff d4             	callq  *%r12
  80416021fb:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  80416021ff:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602203:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602207:	ba 01 00 00 00       	mov    $0x1,%edx
  804160220c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602210:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  8041602213:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602217:	75 4f                	jne    8041602268 <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602219:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160221d:	4c 03 28             	add    (%rax),%r13
  8041602220:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  8041602224:	49 bf 53 0c 60 41 80 	movabs $0x8041600c53,%r15
  804160222b:	00 00 00 
  while (entry < entry_end) {
  804160222e:	e9 07 02 00 00       	jmpq   804160243a <function_by_info+0x341>
  assert(version == 4 || version == 2);
  8041602233:	48 b9 ce 56 60 41 80 	movabs $0x80416056ce,%rcx
  804160223a:	00 00 00 
  804160223d:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041602244:	00 00 00 
  8041602247:	be e6 01 00 00       	mov    $0x1e6,%esi
  804160224c:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041602253:	00 00 00 
  8041602256:	b8 00 00 00 00       	mov    $0x0,%eax
  804160225b:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041602262:	00 00 00 
  8041602265:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  8041602268:	48 b9 9b 56 60 41 80 	movabs $0x804160569b,%rcx
  804160226f:	00 00 00 
  8041602272:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041602279:	00 00 00 
  804160227c:	be ea 01 00 00       	mov    $0x1ea,%esi
  8041602281:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041602288:	00 00 00 
  804160228b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602290:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041602297:	00 00 00 
  804160229a:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  804160229d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416022a1:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  80416022a5:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  80416022a9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  80416022af:	49 39 da             	cmp    %rbx,%r10
  80416022b2:	0f 86 e7 00 00 00    	jbe    804160239f <function_by_info+0x2a6>
  80416022b8:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416022bb:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416022c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416022c6:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416022cb:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416022ce:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416022d2:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416022d6:	89 f8                	mov    %edi,%eax
  80416022d8:	83 e0 7f             	and    $0x7f,%eax
  80416022db:	d3 e0                	shl    %cl,%eax
  80416022dd:	09 c6                	or     %eax,%esi
    shift += 7;
  80416022df:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416022e2:	40 84 ff             	test   %dil,%dil
  80416022e5:	78 e4                	js     80416022cb <function_by_info+0x1d2>
  return count;
  80416022e7:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  80416022ea:	4c 01 c3             	add    %r8,%rbx
  80416022ed:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416022f0:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  80416022f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416022fb:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602301:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602304:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602308:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  804160230c:	89 f8                	mov    %edi,%eax
  804160230e:	83 e0 7f             	and    $0x7f,%eax
  8041602311:	d3 e0                	shl    %cl,%eax
  8041602313:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602316:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602319:	40 84 ff             	test   %dil,%dil
  804160231c:	78 e3                	js     8041602301 <function_by_info+0x208>
  return count;
  804160231e:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  8041602321:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  8041602326:	41 39 f1             	cmp    %esi,%r9d
  8041602329:	74 74                	je     804160239f <function_by_info+0x2a6>
  result = 0;
  804160232b:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  804160232e:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602333:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602338:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  804160233e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602341:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602345:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602348:	89 f0                	mov    %esi,%eax
  804160234a:	83 e0 7f             	and    $0x7f,%eax
  804160234d:	d3 e0                	shl    %cl,%eax
  804160234f:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602352:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602355:	40 84 f6             	test   %sil,%sil
  8041602358:	78 e4                	js     804160233e <function_by_info+0x245>
  return count;
  804160235a:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160235d:	48 01 fb             	add    %rdi,%rbx
  8041602360:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602363:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602368:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160236d:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602373:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602376:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160237a:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160237d:	89 f0                	mov    %esi,%eax
  804160237f:	83 e0 7f             	and    $0x7f,%eax
  8041602382:	d3 e0                	shl    %cl,%eax
  8041602384:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602387:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160238a:	40 84 f6             	test   %sil,%sil
  804160238d:	78 e4                	js     8041602373 <function_by_info+0x27a>
  return count;
  804160238f:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602392:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  8041602395:	45 09 dc             	or     %r11d,%r12d
  8041602398:	75 91                	jne    804160232b <function_by_info+0x232>
  804160239a:	e9 10 ff ff ff       	jmpq   80416022af <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  804160239f:	41 83 f8 2e          	cmp    $0x2e,%r8d
  80416023a3:	0f 84 e9 00 00 00    	je     8041602492 <function_by_info+0x399>
            fn_name_entry = entry;
  80416023a9:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023ac:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416023b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023b6:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416023bc:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416023bf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023c3:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416023c6:	89 f0                	mov    %esi,%eax
  80416023c8:	83 e0 7f             	and    $0x7f,%eax
  80416023cb:	d3 e0                	shl    %cl,%eax
  80416023cd:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416023d0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023d3:	40 84 f6             	test   %sil,%sil
  80416023d6:	78 e4                	js     80416023bc <function_by_info+0x2c3>
  return count;
  80416023d8:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416023db:	48 01 fb             	add    %rdi,%rbx
  80416023de:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023e1:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416023e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023eb:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416023f1:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416023f4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023f8:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416023fb:	89 f0                	mov    %esi,%eax
  80416023fd:	83 e0 7f             	and    $0x7f,%eax
  8041602400:	d3 e0                	shl    %cl,%eax
  8041602402:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602405:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602408:	40 84 f6             	test   %sil,%sil
  804160240b:	78 e4                	js     80416023f1 <function_by_info+0x2f8>
  return count;
  804160240d:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602410:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  8041602413:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602419:	b9 00 00 00 00       	mov    $0x0,%ecx
  804160241e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602423:	44 89 e6             	mov    %r12d,%esi
  8041602426:	4c 89 f7             	mov    %r14,%rdi
  8041602429:	41 ff d7             	callq  *%r15
        entry += count;
  804160242c:	48 98                	cltq   
  804160242e:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602431:	45 09 ec             	or     %r13d,%r12d
  8041602434:	0f 85 6f ff ff ff    	jne    80416023a9 <function_by_info+0x2b0>
  while (entry < entry_end) {
  804160243a:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  804160243e:	0f 83 37 02 00 00    	jae    804160267b <function_by_info+0x582>
                 uintptr_t *offset) {
  8041602444:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  8041602447:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160244c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602451:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602457:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160245a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160245e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602461:	89 f0                	mov    %esi,%eax
  8041602463:	83 e0 7f             	and    $0x7f,%eax
  8041602466:	d3 e0                	shl    %cl,%eax
  8041602468:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  804160246b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160246e:	40 84 f6             	test   %sil,%sil
  8041602471:	78 e4                	js     8041602457 <function_by_info+0x35e>
  return count;
  8041602473:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  8041602476:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  8041602479:	45 85 c9             	test   %r9d,%r9d
  804160247c:	0f 85 1b fe ff ff    	jne    804160229d <function_by_info+0x1a4>
  while (entry < entry_end) {
  8041602482:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  8041602486:	77 bc                	ja     8041602444 <function_by_info+0x34b>
  return 0;
  8041602488:	b8 00 00 00 00       	mov    $0x0,%eax
  804160248d:	e9 de fc ff ff       	jmpq   8041602170 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  8041602492:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  8041602499:	00 
  804160249a:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  80416024a1:	00 
      unsigned name_form        = 0;
  80416024a2:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  80416024a9:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80416024b0:	00 
  80416024b1:	eb 1d                	jmp    80416024d0 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  80416024b3:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416024b9:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416024be:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416024c2:	44 89 ee             	mov    %r13d,%esi
  80416024c5:	4c 89 f7             	mov    %r14,%rdi
  80416024c8:	41 ff d7             	callq  *%r15
        entry += count;
  80416024cb:	48 98                	cltq   
  80416024cd:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  80416024d0:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024d3:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024dd:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024e3:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024e6:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024ea:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024ed:	89 f0                	mov    %esi,%eax
  80416024ef:	83 e0 7f             	and    $0x7f,%eax
  80416024f2:	d3 e0                	shl    %cl,%eax
  80416024f4:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024f7:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024fa:	40 84 f6             	test   %sil,%sil
  80416024fd:	78 e4                	js     80416024e3 <function_by_info+0x3ea>
  return count;
  80416024ff:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602502:	48 01 fb             	add    %rdi,%rbx
  8041602505:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602508:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160250d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602512:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602518:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160251b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160251f:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602522:	89 f0                	mov    %esi,%eax
  8041602524:	83 e0 7f             	and    $0x7f,%eax
  8041602527:	d3 e0                	shl    %cl,%eax
  8041602529:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  804160252c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160252f:	40 84 f6             	test   %sil,%sil
  8041602532:	78 e4                	js     8041602518 <function_by_info+0x41f>
  return count;
  8041602534:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602537:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  804160253a:	41 83 fc 11          	cmp    $0x11,%r12d
  804160253e:	0f 84 6f ff ff ff    	je     80416024b3 <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  8041602544:	41 83 fc 12          	cmp    $0x12,%r12d
  8041602548:	0f 84 99 00 00 00    	je     80416025e7 <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  804160254e:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602552:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  8041602555:	41 0f 44 c5          	cmove  %r13d,%eax
  8041602559:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  804160255c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602560:	49 0f 44 c6          	cmove  %r14,%rax
  8041602564:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  8041602568:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160256e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602573:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602578:	44 89 ee             	mov    %r13d,%esi
  804160257b:	4c 89 f7             	mov    %r14,%rdi
  804160257e:	41 ff d7             	callq  *%r15
        entry += count;
  8041602581:	48 98                	cltq   
  8041602583:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602586:	45 09 e5             	or     %r12d,%r13d
  8041602589:	0f 85 41 ff ff ff    	jne    80416024d0 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  804160258f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602593:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  804160259a:	48 39 d8             	cmp    %rbx,%rax
  804160259d:	0f 87 97 fe ff ff    	ja     804160243a <function_by_info+0x341>
  80416025a3:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  80416025a7:	0f 82 8d fe ff ff    	jb     804160243a <function_by_info+0x341>
        *offset = low_pc;
  80416025ad:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  80416025b4:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  80416025b7:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  80416025bb:	74 59                	je     8041602616 <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  80416025bd:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416025c3:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  80416025c6:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  80416025ca:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  80416025cd:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  80416025d1:	48 b8 53 0c 60 41 80 	movabs $0x8041600c53,%rax
  80416025d8:	00 00 00 
  80416025db:	ff d0                	callq  *%rax
        return 0;
  80416025dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80416025e2:	e9 89 fb ff ff       	jmpq   8041602170 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  80416025e7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416025ed:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416025f2:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416025f6:	44 89 ee             	mov    %r13d,%esi
  80416025f9:	4c 89 f7             	mov    %r14,%rdi
  80416025fc:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  80416025ff:	41 83 fd 01          	cmp    $0x1,%r13d
  8041602603:	0f 84 c2 fe ff ff    	je     80416024cb <function_by_info+0x3d2>
            high_pc += low_pc;
  8041602609:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  804160260d:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  8041602611:	e9 b5 fe ff ff       	jmpq   80416024cb <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  8041602616:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  804160261d:	00 
          count                    = dwarf_read_abbrev_entry(
  804160261e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602624:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602629:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  804160262d:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602632:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  8041602636:	48 b8 53 0c 60 41 80 	movabs $0x8041600c53,%rax
  804160263d:	00 00 00 
  8041602640:	ff d0                	callq  *%rax
          if (buf &&
  8041602642:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  8041602646:	48 85 ff             	test   %rdi,%rdi
  8041602649:	74 92                	je     80416025dd <function_by_info+0x4e4>
  804160264b:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  804160264f:	76 8c                	jbe    80416025dd <function_by_info+0x4e4>
            put_unaligned(
  8041602651:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041602655:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  8041602659:	48 03 43 40          	add    0x40(%rbx),%rax
  804160265d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602661:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602666:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  804160266a:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041602671:	00 00 00 
  8041602674:	ff d0                	callq  *%rax
  8041602676:	e9 62 ff ff ff       	jmpq   80416025dd <function_by_info+0x4e4>
  return 0;
  804160267b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602680:	e9 eb fa ff ff       	jmpq   8041602170 <function_by_info+0x77>

0000008041602685 <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  8041602685:	55                   	push   %rbp
  8041602686:	48 89 e5             	mov    %rsp,%rbp
  8041602689:	41 57                	push   %r15
  804160268b:	41 56                	push   %r14
  804160268d:	41 55                	push   %r13
  804160268f:	41 54                	push   %r12
  8041602691:	53                   	push   %rbx
  8041602692:	48 83 ec 38          	sub    $0x38,%rsp
  8041602696:	49 89 ff             	mov    %rdi,%r15
  8041602699:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  804160269d:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  const int flen = strlen(fname);
  80416026a1:	48 89 f7             	mov    %rsi,%rdi
  80416026a4:	48 b8 5a 4e 60 41 80 	movabs $0x8041604e5a,%rax
  80416026ab:	00 00 00 
  80416026ae:	ff d0                	callq  *%rax
  80416026b0:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  80416026b2:	85 c0                	test   %eax,%eax
  80416026b4:	74 62                	je     8041602718 <address_by_fname+0x93>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  80416026b6:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416026ba:	49 be d3 50 60 41 80 	movabs $0x80416050d3,%r14
  80416026c1:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  80416026c4:	49 bf 69 4f 60 41 80 	movabs $0x8041604f69,%r15
  80416026cb:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  80416026ce:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416026d2:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  80416026d6:	0f 86 91 02 00 00    	jbe    804160296d <address_by_fname+0x2e8>
  80416026dc:	ba 04 00 00 00       	mov    $0x4,%edx
  80416026e1:	4c 89 e6             	mov    %r12,%rsi
  80416026e4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416026e8:	41 ff d6             	callq  *%r14
  80416026eb:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416026ee:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416026f1:	76 52                	jbe    8041602745 <address_by_fname+0xc0>
    if (initial_len == DW_EXT_DWARF64) {
  80416026f3:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416026f6:	74 31                	je     8041602729 <address_by_fname+0xa4>
      cprintf("Unknown DWARF extension\n");
  80416026f8:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  80416026ff:	00 00 00 
  8041602702:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602707:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  804160270e:	00 00 00 
  8041602711:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602713:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  8041602718:	89 d8                	mov    %ebx,%eax
  804160271a:	48 83 c4 38          	add    $0x38,%rsp
  804160271e:	5b                   	pop    %rbx
  804160271f:	41 5c                	pop    %r12
  8041602721:	41 5d                	pop    %r13
  8041602723:	41 5e                	pop    %r14
  8041602725:	41 5f                	pop    %r15
  8041602727:	5d                   	pop    %rbp
  8041602728:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602729:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  804160272e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602733:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602737:	41 ff d6             	callq  *%r14
  804160273a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160273e:	ba 0c 00 00 00       	mov    $0xc,%edx
  8041602743:	eb 07                	jmp    804160274c <address_by_fname+0xc7>
    *len = initial_len;
  8041602745:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602747:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  804160274c:	48 63 d2             	movslq %edx,%rdx
  804160274f:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  8041602752:	4c 01 e0             	add    %r12,%rax
  8041602755:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  8041602759:	ba 02 00 00 00       	mov    $0x2,%edx
  804160275e:	4c 89 e6             	mov    %r12,%rsi
  8041602761:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602765:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  8041602768:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  804160276d:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041602772:	0f 85 be 00 00 00    	jne    8041602836 <address_by_fname+0x1b1>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602778:	ba 04 00 00 00       	mov    $0x4,%edx
  804160277d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602781:	41 ff d6             	callq  *%r14
  8041602784:	8b 45 c8             	mov    -0x38(%rbp),%eax
  8041602787:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  804160278a:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160278f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602794:	48 89 de             	mov    %rbx,%rsi
  8041602797:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160279b:	41 ff d6             	callq  *%r14
  804160279e:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  80416027a1:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416027a6:	83 fa ef             	cmp    $0xffffffef,%edx
  80416027a9:	76 29                	jbe    80416027d4 <address_by_fname+0x14f>
    if (initial_len == DW_EXT_DWARF64) {
  80416027ab:	83 fa ff             	cmp    $0xffffffff,%edx
  80416027ae:	0f 84 b7 00 00 00    	je     804160286b <address_by_fname+0x1e6>
      cprintf("Unknown DWARF extension\n");
  80416027b4:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  80416027bb:	00 00 00 
  80416027be:	b8 00 00 00 00       	mov    $0x0,%eax
  80416027c3:	48 be 4c 40 60 41 80 	movabs $0x804160404c,%rsi
  80416027ca:	00 00 00 
  80416027cd:	ff d6                	callq  *%rsi
      count = 0;
  80416027cf:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  80416027d4:	48 98                	cltq   
  80416027d6:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416027da:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416027de:	0f 86 ea fe ff ff    	jbe    80416026ce <address_by_fname+0x49>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416027e4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027e9:	4c 89 e6             	mov    %r12,%rsi
  80416027ec:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027f0:	41 ff d6             	callq  *%r14
  80416027f3:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416027f7:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416027fb:	4d 85 ed             	test   %r13,%r13
  80416027fe:	0f 84 ca fe ff ff    	je     80416026ce <address_by_fname+0x49>
      if (!strcmp(fname, pubnames_entry)) {
  8041602804:	4c 89 e6             	mov    %r12,%rsi
  8041602807:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  804160280b:	41 ff d7             	callq  *%r15
  804160280e:	89 c3                	mov    %eax,%ebx
  8041602810:	85 c0                	test   %eax,%eax
  8041602812:	74 72                	je     8041602886 <address_by_fname+0x201>
      pubnames_entry += strlen(pubnames_entry) + 1;
  8041602814:	4c 89 e7             	mov    %r12,%rdi
  8041602817:	48 b8 5a 4e 60 41 80 	movabs $0x8041604e5a,%rax
  804160281e:	00 00 00 
  8041602821:	ff d0                	callq  *%rax
  8041602823:	83 c0 01             	add    $0x1,%eax
  8041602826:	48 98                	cltq   
  8041602828:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  804160282b:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  804160282f:	77 b3                	ja     80416027e4 <address_by_fname+0x15f>
  8041602831:	e9 98 fe ff ff       	jmpq   80416026ce <address_by_fname+0x49>
    assert(version == 2);
  8041602836:	48 b9 de 56 60 41 80 	movabs $0x80416056de,%rcx
  804160283d:	00 00 00 
  8041602840:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041602847:	00 00 00 
  804160284a:	be 73 02 00 00       	mov    $0x273,%esi
  804160284f:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041602856:	00 00 00 
  8041602859:	b8 00 00 00 00       	mov    $0x0,%eax
  804160285e:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041602865:	00 00 00 
  8041602868:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160286b:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  8041602870:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602875:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602879:	41 ff d6             	callq  *%r14
      count = 12;
  804160287c:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602881:	e9 4e ff ff ff       	jmpq   80416027d4 <address_by_fname+0x14f>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  8041602886:	44 8b 75 a4          	mov    -0x5c(%rbp),%r14d
        const void *entry      = addrs->info_begin + cu_offset;
  804160288a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  804160288e:	4c 03 70 20          	add    0x20(%rax),%r14
        const void *func_entry = entry + func_offset;
  8041602892:	4d 01 f5             	add    %r14,%r13
  initial_len = get_unaligned(addr, uint32_t);
  8041602895:	ba 04 00 00 00       	mov    $0x4,%edx
  804160289a:	4c 89 f6             	mov    %r14,%rsi
  804160289d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028a1:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416028a8:	00 00 00 
  80416028ab:	ff d0                	callq  *%rax
  80416028ad:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416028b0:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416028b3:	0f 86 be 00 00 00    	jbe    8041602977 <address_by_fname+0x2f2>
    if (initial_len == DW_EXT_DWARF64) {
  80416028b9:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416028bc:	74 25                	je     80416028e3 <address_by_fname+0x25e>
      cprintf("Unknown DWARF extension\n");
  80416028be:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  80416028c5:	00 00 00 
  80416028c8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028cd:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  80416028d4:	00 00 00 
  80416028d7:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416028d9:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416028de:	e9 35 fe ff ff       	jmpq   8041602718 <address_by_fname+0x93>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416028e3:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416028e7:	ba 08 00 00 00       	mov    $0x8,%edx
  80416028ec:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028f0:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416028f7:	00 00 00 
  80416028fa:	ff d0                	callq  *%rax
      count = 12;
  80416028fc:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602901:	eb 79                	jmp    804160297c <address_by_fname+0x2f7>
        assert(version == 4 || version == 2);
  8041602903:	48 b9 ce 56 60 41 80 	movabs $0x80416056ce,%rcx
  804160290a:	00 00 00 
  804160290d:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041602914:	00 00 00 
  8041602917:	be 89 02 00 00       	mov    $0x289,%esi
  804160291c:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041602923:	00 00 00 
  8041602926:	b8 00 00 00 00       	mov    $0x0,%eax
  804160292b:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041602932:	00 00 00 
  8041602935:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  8041602938:	48 b9 9b 56 60 41 80 	movabs $0x804160569b,%rcx
  804160293f:	00 00 00 
  8041602942:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041602949:	00 00 00 
  804160294c:	be 8e 02 00 00       	mov    $0x28e,%esi
  8041602951:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041602958:	00 00 00 
  804160295b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602960:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041602967:	00 00 00 
  804160296a:	41 ff d0             	callq  *%r8
  return 0;
  804160296d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602972:	e9 a1 fd ff ff       	jmpq   8041602718 <address_by_fname+0x93>
  count       = 4;
  8041602977:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  804160297c:	48 98                	cltq   
  804160297e:	49 01 c6             	add    %rax,%r14
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602981:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602986:	4c 89 f6             	mov    %r14,%rsi
  8041602989:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160298d:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041602994:	00 00 00 
  8041602997:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  8041602999:	49 8d 76 02          	lea    0x2(%r14),%rsi
        assert(version == 4 || version == 2);
  804160299d:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416029a1:	83 e8 02             	sub    $0x2,%eax
  80416029a4:	66 a9 fd ff          	test   $0xfffd,%ax
  80416029a8:	0f 85 55 ff ff ff    	jne    8041602903 <address_by_fname+0x27e>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416029ae:	ba 04 00 00 00       	mov    $0x4,%edx
  80416029b3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029b7:	49 bf d3 50 60 41 80 	movabs $0x80416050d3,%r15
  80416029be:	00 00 00 
  80416029c1:	41 ff d7             	callq  *%r15
  80416029c4:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  80416029c8:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416029cc:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  80416029cf:	49 8d 76 06          	lea    0x6(%r14),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416029d3:	ba 01 00 00 00       	mov    $0x1,%edx
  80416029d8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029dc:	41 ff d7             	callq  *%r15
        assert(address_size == 8);
  80416029df:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416029e3:	0f 85 4f ff ff ff    	jne    8041602938 <address_by_fname+0x2b3>
  shift  = 0;
  80416029e9:	89 d9                	mov    %ebx,%ecx
  result = 0;
  80416029eb:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416029f0:	41 0f b6 55 00       	movzbl 0x0(%r13),%edx
    addr++;
  80416029f5:	49 83 c5 01          	add    $0x1,%r13
    result |= (byte & 0x7f) << shift;
  80416029f9:	89 d0                	mov    %edx,%eax
  80416029fb:	83 e0 7f             	and    $0x7f,%eax
  80416029fe:	d3 e0                	shl    %cl,%eax
  8041602a00:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602a02:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a05:	84 d2                	test   %dl,%dl
  8041602a07:	78 e7                	js     80416029f0 <address_by_fname+0x36b>
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  8041602a09:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602a0d:	4c 8b 40 08          	mov    0x8(%rax),%r8
  8041602a11:	4d 39 e0             	cmp    %r12,%r8
  8041602a14:	0f 86 fe fc ff ff    	jbe    8041602718 <address_by_fname+0x93>
  count  = 0;
  8041602a1a:	41 89 d9             	mov    %ebx,%r9d
  shift  = 0;
  8041602a1d:	89 d9                	mov    %ebx,%ecx
  8041602a1f:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a22:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602a28:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602a2b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a2f:	41 83 c1 01          	add    $0x1,%r9d
    result |= (byte & 0x7f) << shift;
  8041602a33:	89 f8                	mov    %edi,%eax
  8041602a35:	83 e0 7f             	and    $0x7f,%eax
  8041602a38:	d3 e0                	shl    %cl,%eax
  8041602a3a:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602a3d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a40:	40 84 ff             	test   %dil,%dil
  8041602a43:	78 e3                	js     8041602a28 <address_by_fname+0x3a3>
  return count;
  8041602a45:	4d 63 c9             	movslq %r9d,%r9
          abbrev_entry += count;
  8041602a48:	4d 01 cc             	add    %r9,%r12
  count  = 0;
  8041602a4b:	89 da                	mov    %ebx,%edx
  8041602a4d:	4c 89 e0             	mov    %r12,%rax
    byte = *addr;
  8041602a50:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041602a53:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041602a57:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041602a5a:	84 c9                	test   %cl,%cl
  8041602a5c:	78 f2                	js     8041602a50 <address_by_fname+0x3cb>
  return count;
  8041602a5e:	48 63 d2             	movslq %edx,%rdx
          abbrev_entry++;
  8041602a61:	4d 8d 64 14 01       	lea    0x1(%r12,%rdx,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602a66:	44 39 d6             	cmp    %r10d,%esi
  8041602a69:	0f 84 a9 fc ff ff    	je     8041602718 <address_by_fname+0x93>
  count  = 0;
  8041602a6f:	41 89 da             	mov    %ebx,%r10d
  shift  = 0;
  8041602a72:	89 d9                	mov    %ebx,%ecx
  8041602a74:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a77:	bf 00 00 00 00       	mov    $0x0,%edi
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
  8041602a90:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602a92:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a95:	45 84 c9             	test   %r9b,%r9b
  8041602a98:	78 e2                	js     8041602a7c <address_by_fname+0x3f7>
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
  8041602acb:	78 e1                	js     8041602aae <address_by_fname+0x429>
  return count;
  8041602acd:	4d 63 d2             	movslq %r10d,%r10
            abbrev_entry += count;
  8041602ad0:	4d 01 d4             	add    %r10,%r12
          } while (name != 0 || form != 0);
  8041602ad3:	41 09 fb             	or     %edi,%r11d
  8041602ad6:	75 97                	jne    8041602a6f <address_by_fname+0x3ea>
  8041602ad8:	e9 34 ff ff ff       	jmpq   8041602a11 <address_by_fname+0x38c>

0000008041602add <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602add:	55                   	push   %rbp
  8041602ade:	48 89 e5             	mov    %rsp,%rbp
  8041602ae1:	41 57                	push   %r15
  8041602ae3:	41 56                	push   %r14
  8041602ae5:	41 55                	push   %r13
  8041602ae7:	41 54                	push   %r12
  8041602ae9:	53                   	push   %rbx
  8041602aea:	48 83 ec 48          	sub    $0x48,%rsp
  8041602aee:	48 89 fb             	mov    %rdi,%rbx
  8041602af1:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602af5:	48 89 f7             	mov    %rsi,%rdi
  8041602af8:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602afc:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602b00:	48 b8 5a 4e 60 41 80 	movabs $0x8041604e5a,%rax
  8041602b07:	00 00 00 
  8041602b0a:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602b0c:	85 c0                	test   %eax,%eax
  8041602b0e:	0f 84 73 03 00 00    	je     8041602e87 <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602b14:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602b18:	e9 0f 03 00 00       	jmpq   8041602e2c <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602b1d:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602b21:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602b26:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b2a:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041602b31:	00 00 00 
  8041602b34:	ff d0                	callq  *%rax
  8041602b36:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602b3a:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602b3f:	eb 07                	jmp    8041602b48 <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602b41:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602b43:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602b48:	48 63 db             	movslq %ebx,%rbx
  8041602b4b:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602b4f:	4c 01 e8             	add    %r13,%rax
  8041602b52:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602b56:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602b5b:	4c 89 ee             	mov    %r13,%rsi
  8041602b5e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b62:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041602b69:	00 00 00 
  8041602b6c:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602b6e:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602b72:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602b76:	83 e8 02             	sub    $0x2,%eax
  8041602b79:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602b7d:	75 52                	jne    8041602bd1 <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602b7f:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602b84:	4c 89 ee             	mov    %r13,%rsi
  8041602b87:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b8b:	49 be d3 50 60 41 80 	movabs $0x80416050d3,%r14
  8041602b92:	00 00 00 
  8041602b95:	41 ff d6             	callq  *%r14
  8041602b98:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602b9c:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602ba1:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602ba5:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602baa:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602bae:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602bb1:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602bb5:	75 4f                	jne    8041602c06 <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602bb7:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602bbb:	4c 03 20             	add    (%rax),%r12
  8041602bbe:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602bc2:	49 be 53 0c 60 41 80 	movabs $0x8041600c53,%r14
  8041602bc9:	00 00 00 
    while (entry < entry_end) {
  8041602bcc:	e9 11 02 00 00       	jmpq   8041602de2 <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602bd1:	48 b9 ce 56 60 41 80 	movabs $0x80416056ce,%rcx
  8041602bd8:	00 00 00 
  8041602bdb:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041602be2:	00 00 00 
  8041602be5:	be d4 02 00 00       	mov    $0x2d4,%esi
  8041602bea:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041602bf1:	00 00 00 
  8041602bf4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602bf9:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041602c00:	00 00 00 
  8041602c03:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602c06:	48 b9 9b 56 60 41 80 	movabs $0x804160569b,%rcx
  8041602c0d:	00 00 00 
  8041602c10:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  8041602c17:	00 00 00 
  8041602c1a:	be d8 02 00 00       	mov    $0x2d8,%esi
  8041602c1f:	48 bf 8e 56 60 41 80 	movabs $0x804160568e,%rdi
  8041602c26:	00 00 00 
  8041602c29:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602c2e:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041602c35:	00 00 00 
  8041602c38:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602c3b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602c3f:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602c43:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602c47:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602c4d:	49 39 db             	cmp    %rbx,%r11
  8041602c50:	0f 86 e7 00 00 00    	jbe    8041602d3d <naive_address_by_fname+0x260>
  8041602c56:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602c59:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602c5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602c64:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602c69:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602c6c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c70:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602c74:	89 f8                	mov    %edi,%eax
  8041602c76:	83 e0 7f             	and    $0x7f,%eax
  8041602c79:	d3 e0                	shl    %cl,%eax
  8041602c7b:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602c7d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c80:	40 84 ff             	test   %dil,%dil
  8041602c83:	78 e4                	js     8041602c69 <naive_address_by_fname+0x18c>
  return count;
  8041602c85:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602c88:	4c 01 c3             	add    %r8,%rbx
  8041602c8b:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602c8e:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602c94:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602c99:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602c9f:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602ca2:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ca6:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602caa:	89 f8                	mov    %edi,%eax
  8041602cac:	83 e0 7f             	and    $0x7f,%eax
  8041602caf:	d3 e0                	shl    %cl,%eax
  8041602cb1:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602cb4:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cb7:	40 84 ff             	test   %dil,%dil
  8041602cba:	78 e3                	js     8041602c9f <naive_address_by_fname+0x1c2>
  return count;
  8041602cbc:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602cbf:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602cc4:	41 39 f2             	cmp    %esi,%r10d
  8041602cc7:	74 74                	je     8041602d3d <naive_address_by_fname+0x260>
  result = 0;
  8041602cc9:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ccc:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602cd6:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602cdc:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602cdf:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ce3:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602ce6:	89 f0                	mov    %esi,%eax
  8041602ce8:	83 e0 7f             	and    $0x7f,%eax
  8041602ceb:	d3 e0                	shl    %cl,%eax
  8041602ced:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602cf0:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cf3:	40 84 f6             	test   %sil,%sil
  8041602cf6:	78 e4                	js     8041602cdc <naive_address_by_fname+0x1ff>
  return count;
  8041602cf8:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602cfb:	48 01 fb             	add    %rdi,%rbx
  8041602cfe:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602d01:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602d06:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d0b:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602d11:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d14:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d18:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602d1b:	89 f0                	mov    %esi,%eax
  8041602d1d:	83 e0 7f             	and    $0x7f,%eax
  8041602d20:	d3 e0                	shl    %cl,%eax
  8041602d22:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602d25:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d28:	40 84 f6             	test   %sil,%sil
  8041602d2b:	78 e4                	js     8041602d11 <naive_address_by_fname+0x234>
  return count;
  8041602d2d:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602d30:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  8041602d33:	45 09 c4             	or     %r8d,%r12d
  8041602d36:	75 91                	jne    8041602cc9 <naive_address_by_fname+0x1ec>
  8041602d38:	e9 10 ff ff ff       	jmpq   8041602c4d <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602d3d:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602d41:	0f 84 4f 01 00 00    	je     8041602e96 <naive_address_by_fname+0x3b9>
  8041602d47:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602d4b:	0f 84 45 01 00 00    	je     8041602e96 <naive_address_by_fname+0x3b9>
                found = 1;
  8041602d51:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602d54:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602d59:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d5e:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602d64:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d67:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d6b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602d6e:	89 f0                	mov    %esi,%eax
  8041602d70:	83 e0 7f             	and    $0x7f,%eax
  8041602d73:	d3 e0                	shl    %cl,%eax
  8041602d75:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602d78:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d7b:	40 84 f6             	test   %sil,%sil
  8041602d7e:	78 e4                	js     8041602d64 <naive_address_by_fname+0x287>
  return count;
  8041602d80:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  8041602d83:	48 01 fb             	add    %rdi,%rbx
  8041602d86:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602d89:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602d8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d93:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602d99:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d9c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602da0:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602da3:	89 f0                	mov    %esi,%eax
  8041602da5:	83 e0 7f             	and    $0x7f,%eax
  8041602da8:	d3 e0                	shl    %cl,%eax
  8041602daa:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602dad:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602db0:	40 84 f6             	test   %sil,%sil
  8041602db3:	78 e4                	js     8041602d99 <naive_address_by_fname+0x2bc>
  return count;
  8041602db5:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  8041602db8:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041602dbb:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602dc6:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602dcb:	44 89 e6             	mov    %r12d,%esi
  8041602dce:	4c 89 ff             	mov    %r15,%rdi
  8041602dd1:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  8041602dd4:	48 98                	cltq   
  8041602dd6:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041602dd9:	45 09 ec             	or     %r13d,%r12d
  8041602ddc:	0f 85 6f ff ff ff    	jne    8041602d51 <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  8041602de2:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  8041602de6:	73 44                	jae    8041602e2c <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  8041602de8:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  8041602deb:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602df0:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602df5:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602dfb:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602dfe:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602e02:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602e05:	89 f0                	mov    %esi,%eax
  8041602e07:	83 e0 7f             	and    $0x7f,%eax
  8041602e0a:	d3 e0                	shl    %cl,%eax
  8041602e0c:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602e0f:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602e12:	40 84 f6             	test   %sil,%sil
  8041602e15:	78 e4                	js     8041602dfb <naive_address_by_fname+0x31e>
  return count;
  8041602e17:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  8041602e1a:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  8041602e1d:	45 85 d2             	test   %r10d,%r10d
  8041602e20:	0f 85 15 fe ff ff    	jne    8041602c3b <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  8041602e26:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  8041602e2a:	77 bc                	ja     8041602de8 <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602e2c:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e30:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  8041602e34:	0f 86 ee 01 00 00    	jbe    8041603028 <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  8041602e3a:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602e3f:	4c 89 fe             	mov    %r15,%rsi
  8041602e42:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e46:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041602e4d:	00 00 00 
  8041602e50:	ff d0                	callq  *%rax
  8041602e52:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602e55:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602e58:	0f 86 e3 fc ff ff    	jbe    8041602b41 <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  8041602e5e:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602e61:	0f 84 b6 fc ff ff    	je     8041602b1d <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  8041602e67:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  8041602e6e:	00 00 00 
  8041602e71:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e76:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041602e7d:	00 00 00 
  8041602e80:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602e82:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  8041602e87:	48 83 c4 48          	add    $0x48,%rsp
  8041602e8b:	5b                   	pop    %rbx
  8041602e8c:	41 5c                	pop    %r12
  8041602e8e:	41 5d                	pop    %r13
  8041602e90:	41 5e                	pop    %r14
  8041602e92:	41 5f                	pop    %r15
  8041602e94:	5d                   	pop    %rbp
  8041602e95:	c3                   	retq   
        uintptr_t low_pc = 0;
  8041602e96:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602e9d:	00 
        int found        = 0;
  8041602e9e:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041602ea5:	eb 21                	jmp    8041602ec8 <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  8041602ea7:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602ead:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602eb2:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602eb6:	44 89 ee             	mov    %r13d,%esi
  8041602eb9:	4c 89 ff             	mov    %r15,%rdi
  8041602ebc:	41 ff d6             	callq  *%r14
  8041602ebf:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  8041602ec2:	49 63 c4             	movslq %r12d,%rax
  8041602ec5:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  8041602ec8:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ecb:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602ed0:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602ed5:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602edb:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ede:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ee2:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602ee5:	89 f0                	mov    %esi,%eax
  8041602ee7:	83 e0 7f             	and    $0x7f,%eax
  8041602eea:	d3 e0                	shl    %cl,%eax
  8041602eec:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602eef:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ef2:	40 84 f6             	test   %sil,%sil
  8041602ef5:	78 e4                	js     8041602edb <naive_address_by_fname+0x3fe>
  return count;
  8041602ef7:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602efa:	48 01 fb             	add    %rdi,%rbx
  8041602efd:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602f00:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602f05:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f0a:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602f10:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f13:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f17:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f1a:	89 f0                	mov    %esi,%eax
  8041602f1c:	83 e0 7f             	and    $0x7f,%eax
  8041602f1f:	d3 e0                	shl    %cl,%eax
  8041602f21:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602f24:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f27:	40 84 f6             	test   %sil,%sil
  8041602f2a:	78 e4                	js     8041602f10 <naive_address_by_fname+0x433>
  return count;
  8041602f2c:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f2f:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  8041602f32:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602f36:	0f 84 6b ff ff ff    	je     8041602ea7 <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  8041602f3c:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602f40:	0f 85 9c 00 00 00    	jne    8041602fe2 <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  8041602f46:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041602f4a:	74 42                	je     8041602f8e <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  8041602f4c:	4c 89 fe             	mov    %r15,%rsi
  8041602f4f:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041602f53:	48 b8 69 4f 60 41 80 	movabs $0x8041604f69,%rax
  8041602f5a:	00 00 00 
  8041602f5d:	ff d0                	callq  *%rax
                found = 1;
  8041602f5f:	85 c0                	test   %eax,%eax
  8041602f61:	b8 01 00 00 00       	mov    $0x1,%eax
  8041602f66:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041602f6a:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  8041602f6d:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f73:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602f78:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602f7d:	44 89 ee             	mov    %r13d,%esi
  8041602f80:	4c 89 ff             	mov    %r15,%rdi
  8041602f83:	41 ff d6             	callq  *%r14
  8041602f86:	41 89 c4             	mov    %eax,%r12d
  8041602f89:	e9 34 ff ff ff       	jmpq   8041602ec2 <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  8041602f8e:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602f95:	00 
              count          = dwarf_read_abbrev_entry(
  8041602f96:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f9c:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602fa1:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602fa5:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602faa:	4c 89 ff             	mov    %r15,%rdi
  8041602fad:	41 ff d6             	callq  *%r14
  8041602fb0:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  8041602fb3:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041602fb7:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602fbb:	48 03 70 40          	add    0x40(%rax),%rsi
  8041602fbf:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041602fc3:	48 b8 69 4f 60 41 80 	movabs $0x8041604f69,%rax
  8041602fca:	00 00 00 
  8041602fcd:	ff d0                	callq  *%rax
                found = 1;
  8041602fcf:	85 c0                	test   %eax,%eax
  8041602fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  8041602fd6:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041602fda:	89 45 bc             	mov    %eax,-0x44(%rbp)
  8041602fdd:	e9 e0 fe ff ff       	jmpq   8041602ec2 <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  8041602fe2:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602fe8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602fed:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602ff2:	44 89 ee             	mov    %r13d,%esi
  8041602ff5:	4c 89 ff             	mov    %r15,%rdi
  8041602ff8:	41 ff d6             	callq  *%r14
          entry += count;
  8041602ffb:	48 98                	cltq   
  8041602ffd:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041603000:	45 09 e5             	or     %r12d,%r13d
  8041603003:	0f 85 bf fe ff ff    	jne    8041602ec8 <naive_address_by_fname+0x3eb>
        if (found) {
  8041603009:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  804160300d:	0f 84 cf fd ff ff    	je     8041602de2 <naive_address_by_fname+0x305>
          *offset = low_pc;
  8041603013:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041603017:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  804160301b:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  804160301e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603023:	e9 5f fe ff ff       	jmpq   8041602e87 <naive_address_by_fname+0x3aa>
  return 0;
  8041603028:	b8 00 00 00 00       	mov    $0x0,%eax
  804160302d:	e9 55 fe ff ff       	jmpq   8041602e87 <naive_address_by_fname+0x3aa>

0000008041603032 <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  8041603032:	55                   	push   %rbp
  8041603033:	48 89 e5             	mov    %rsp,%rbp
  8041603036:	41 57                	push   %r15
  8041603038:	41 56                	push   %r14
  804160303a:	41 55                	push   %r13
  804160303c:	41 54                	push   %r12
  804160303e:	53                   	push   %rbx
  804160303f:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  8041603043:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  8041603047:	48 8b 47 38          	mov    0x38(%rdi),%rax
  804160304b:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  804160304e:	48 39 d0             	cmp    %rdx,%rax
  8041603051:	0f 82 d9 06 00 00    	jb     8041603730 <line_for_address+0x6fe>
  8041603057:	48 85 c9             	test   %rcx,%rcx
  804160305a:	0f 84 d0 06 00 00    	je     8041603730 <line_for_address+0x6fe>
  8041603060:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  8041603064:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  8041603068:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  804160306b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603070:	48 89 de             	mov    %rbx,%rsi
  8041603073:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603077:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160307e:	00 00 00 
  8041603081:	ff d0                	callq  *%rax
  8041603083:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603086:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041603089:	76 4e                	jbe    80416030d9 <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  804160308b:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160308e:	74 25                	je     80416030b5 <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  8041603090:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  8041603097:	00 00 00 
  804160309a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160309f:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  80416030a6:	00 00 00 
  80416030a9:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416030ab:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416030b0:	e9 6c 06 00 00       	jmpq   8041603721 <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416030b5:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  80416030b9:	ba 08 00 00 00       	mov    $0x8,%edx
  80416030be:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030c2:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416030c9:	00 00 00 
  80416030cc:	ff d0                	callq  *%rax
  80416030ce:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  80416030d2:	be 0c 00 00 00       	mov    $0xc,%esi
  80416030d7:	eb 07                	jmp    80416030e0 <line_for_address+0xae>
    *len = initial_len;
  80416030d9:	89 c0                	mov    %eax,%eax
  count       = 4;
  80416030db:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  80416030e0:	48 63 f6             	movslq %esi,%rsi
  80416030e3:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  80416030e6:	48 01 d8             	add    %rbx,%rax
  80416030e9:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  80416030ed:	ba 02 00 00 00       	mov    $0x2,%edx
  80416030f2:	48 89 de             	mov    %rbx,%rsi
  80416030f5:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030f9:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041603100:	00 00 00 
  8041603103:	ff d0                	callq  *%rax
  8041603105:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  804160310a:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  804160310e:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  8041603112:	66 83 f8 02          	cmp    $0x2,%ax
  8041603116:	77 51                	ja     8041603169 <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  8041603118:	ba 04 00 00 00       	mov    $0x4,%edx
  804160311d:	4c 89 e6             	mov    %r12,%rsi
  8041603120:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603124:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160312b:	00 00 00 
  804160312e:	ff d0                	callq  *%rax
  8041603130:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041603134:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  8041603138:	0f 86 84 00 00 00    	jbe    80416031c2 <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  804160313e:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  8041603142:	74 5a                	je     804160319e <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  8041603144:	48 bf 60 56 60 41 80 	movabs $0x8041605660,%rdi
  804160314b:	00 00 00 
  804160314e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603153:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  804160315a:	00 00 00 
  804160315d:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  804160315f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041603164:	e9 b8 05 00 00       	jmpq   8041603721 <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  8041603169:	48 b9 88 58 60 41 80 	movabs $0x8041605888,%rcx
  8041603170:	00 00 00 
  8041603173:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  804160317a:	00 00 00 
  804160317d:	be fc 00 00 00       	mov    $0xfc,%esi
  8041603182:	48 bf 41 58 60 41 80 	movabs $0x8041605841,%rdi
  8041603189:	00 00 00 
  804160318c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603191:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041603198:	00 00 00 
  804160319b:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160319e:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  80416031a2:	ba 08 00 00 00       	mov    $0x8,%edx
  80416031a7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031ab:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416031b2:	00 00 00 
  80416031b5:	ff d0                	callq  *%rax
  80416031b7:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  80416031bb:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416031c0:	eb 08                	jmp    80416031ca <line_for_address+0x198>
    *len = initial_len;
  80416031c2:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  80416031c5:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  80416031ca:	48 98                	cltq   
  80416031cc:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  80416031cf:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  80416031d2:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031d7:	4c 89 e6             	mov    %r12,%rsi
  80416031da:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031de:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416031e5:	00 00 00 
  80416031e8:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  80416031ea:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416031ee:	0f 85 89 00 00 00    	jne    804160327d <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  80416031f4:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  80416031f9:	66 41 83 ff 04       	cmp    $0x4,%r15w
  80416031fe:	0f 84 ae 00 00 00    	je     80416032b2 <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  8041603204:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  8041603208:	ba 01 00 00 00       	mov    $0x1,%edx
  804160320d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603211:	49 bc d3 50 60 41 80 	movabs $0x80416050d3,%r12
  8041603218:	00 00 00 
  804160321b:	41 ff d4             	callq  *%r12
  804160321e:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041603222:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  8041603225:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  8041603229:	ba 01 00 00 00       	mov    $0x1,%edx
  804160322e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603232:	41 ff d4             	callq  *%r12
  8041603235:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041603239:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  804160323c:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  8041603240:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603245:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603249:	41 ff d4             	callq  *%r12
  804160324c:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041603250:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  8041603253:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  8041603257:	ba 08 00 00 00       	mov    $0x8,%edx
  804160325c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603260:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  8041603263:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  8041603267:	0f 86 90 04 00 00    	jbe    80416036fd <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  804160326d:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  8041603273:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041603278:	e9 32 04 00 00       	jmpq   80416036af <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  804160327d:	48 b9 b8 58 60 41 80 	movabs $0x80416058b8,%rcx
  8041603284:	00 00 00 
  8041603287:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  804160328e:	00 00 00 
  8041603291:	be 07 01 00 00       	mov    $0x107,%esi
  8041603296:	48 bf 41 58 60 41 80 	movabs $0x8041605841,%rdi
  804160329d:	00 00 00 
  80416032a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032a5:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  80416032ac:	00 00 00 
  80416032af:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  80416032b2:	ba 01 00 00 00       	mov    $0x1,%edx
  80416032b7:	48 89 de             	mov    %rbx,%rsi
  80416032ba:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416032be:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416032c5:	00 00 00 
  80416032c8:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  80416032ca:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  80416032cf:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416032d3:	0f 84 2b ff ff ff    	je     8041603204 <line_for_address+0x1d2>
  80416032d9:	48 b9 d8 58 60 41 80 	movabs $0x80416058d8,%rcx
  80416032e0:	00 00 00 
  80416032e3:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  80416032ea:	00 00 00 
  80416032ed:	be 11 01 00 00       	mov    $0x111,%esi
  80416032f2:	48 bf 41 58 60 41 80 	movabs $0x8041605841,%rdi
  80416032f9:	00 00 00 
  80416032fc:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603301:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041603308:	00 00 00 
  804160330b:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  804160330e:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  8041603311:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  8041603317:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160331c:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  8041603322:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  8041603325:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041603329:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  804160332d:	89 fa                	mov    %edi,%edx
  804160332f:	83 e2 7f             	and    $0x7f,%edx
  8041603332:	d3 e2                	shl    %cl,%edx
  8041603334:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  8041603337:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160333a:	40 84 ff             	test   %dil,%dil
  804160333d:	78 e3                	js     8041603322 <line_for_address+0x2f0>
  return count;
  804160333f:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  8041603342:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  8041603345:	45 89 ff             	mov    %r15d,%r15d
  8041603348:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  804160334b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603350:	4c 89 ee             	mov    %r13,%rsi
  8041603353:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603357:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160335e:	00 00 00 
  8041603361:	ff d0                	callq  *%rax
  8041603363:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  8041603367:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  804160336b:	3c 02                	cmp    $0x2,%al
  804160336d:	0f 84 dc 00 00 00    	je     804160344f <line_for_address+0x41d>
  8041603373:	76 39                	jbe    80416033ae <line_for_address+0x37c>
  8041603375:	3c 03                	cmp    $0x3,%al
  8041603377:	74 62                	je     80416033db <line_for_address+0x3a9>
  8041603379:	3c 04                	cmp    $0x4,%al
  804160337b:	0f 85 0c 01 00 00    	jne    804160348d <line_for_address+0x45b>
  8041603381:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603384:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603389:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160338c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603390:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603393:	84 c9                	test   %cl,%cl
  8041603395:	78 f2                	js     8041603389 <line_for_address+0x357>
  return count;
  8041603397:	48 98                	cltq   
          program_addr += count;
  8041603399:	48 01 c6             	add    %rax,%rsi
  804160339c:	44 89 e2             	mov    %r12d,%edx
  804160339f:	48 89 d8             	mov    %rbx,%rax
  80416033a2:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416033a6:	4c 89 f3             	mov    %r14,%rbx
  80416033a9:	e9 c8 00 00 00       	jmpq   8041603476 <line_for_address+0x444>
      switch (opcode) {
  80416033ae:	3c 01                	cmp    $0x1,%al
  80416033b0:	0f 85 d7 00 00 00    	jne    804160348d <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  80416033b6:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416033ba:	49 39 c6             	cmp    %rax,%r14
  80416033bd:	0f 87 f8 00 00 00    	ja     80416034bb <line_for_address+0x489>
  80416033c3:	48 39 d8             	cmp    %rbx,%rax
  80416033c6:	0f 82 39 03 00 00    	jb     8041603705 <line_for_address+0x6d3>
          state->line          = 1;
  80416033cc:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  80416033d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033d6:	e9 9b 00 00 00       	jmpq   8041603476 <line_for_address+0x444>
          while (*(char *)program_addr) {
  80416033db:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  80416033e0:	74 09                	je     80416033eb <line_for_address+0x3b9>
            ++program_addr;
  80416033e2:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  80416033e6:	80 3e 00             	cmpb   $0x0,(%rsi)
  80416033e9:	75 f7                	jne    80416033e2 <line_for_address+0x3b0>
          ++program_addr;
  80416033eb:	48 83 c6 01          	add    $0x1,%rsi
  80416033ef:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416033f2:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416033f7:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416033fa:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416033fe:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603401:	84 c9                	test   %cl,%cl
  8041603403:	78 f2                	js     80416033f7 <line_for_address+0x3c5>
  return count;
  8041603405:	48 98                	cltq   
          program_addr += count;
  8041603407:	48 01 c6             	add    %rax,%rsi
  804160340a:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160340d:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603412:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603415:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603419:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160341c:	84 c9                	test   %cl,%cl
  804160341e:	78 f2                	js     8041603412 <line_for_address+0x3e0>
  return count;
  8041603420:	48 98                	cltq   
          program_addr += count;
  8041603422:	48 01 c6             	add    %rax,%rsi
  8041603425:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603428:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  804160342d:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603430:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603434:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603437:	84 c9                	test   %cl,%cl
  8041603439:	78 f2                	js     804160342d <line_for_address+0x3fb>
  return count;
  804160343b:	48 98                	cltq   
          program_addr += count;
  804160343d:	48 01 c6             	add    %rax,%rsi
  8041603440:	44 89 e2             	mov    %r12d,%edx
  8041603443:	48 89 d8             	mov    %rbx,%rax
  8041603446:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160344a:	4c 89 f3             	mov    %r14,%rbx
  804160344d:	eb 27                	jmp    8041603476 <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  804160344f:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603454:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603458:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160345f:	00 00 00 
  8041603462:	ff d0                	callq  *%rax
  8041603464:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  8041603468:	49 8d 75 09          	lea    0x9(%r13),%rsi
  804160346c:	44 89 e2             	mov    %r12d,%edx
  804160346f:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603473:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  8041603476:	49 39 f7             	cmp    %rsi,%r15
  8041603479:	75 4c                	jne    80416034c7 <line_for_address+0x495>
  804160347b:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160347f:	41 89 d4             	mov    %edx,%r12d
  8041603482:	49 89 de             	mov    %rbx,%r14
  8041603485:	48 89 c3             	mov    %rax,%rbx
  8041603488:	e9 19 02 00 00       	jmpq   80416036a6 <line_for_address+0x674>
      switch (opcode) {
  804160348d:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603490:	48 ba 54 58 60 41 80 	movabs $0x8041605854,%rdx
  8041603497:	00 00 00 
  804160349a:	be 6b 00 00 00       	mov    $0x6b,%esi
  804160349f:	48 bf 41 58 60 41 80 	movabs $0x8041605841,%rdi
  80416034a6:	00 00 00 
  80416034a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416034ae:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  80416034b5:	00 00 00 
  80416034b8:	41 ff d0             	callq  *%r8
          state->line          = 1;
  80416034bb:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  80416034c0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416034c5:	eb af                	jmp    8041603476 <line_for_address+0x444>
      assert(program_addr == opcode_end);
  80416034c7:	48 b9 67 58 60 41 80 	movabs $0x8041605867,%rcx
  80416034ce:	00 00 00 
  80416034d1:	48 ba 79 56 60 41 80 	movabs $0x8041605679,%rdx
  80416034d8:	00 00 00 
  80416034db:	be 6e 00 00 00       	mov    $0x6e,%esi
  80416034e0:	48 bf 41 58 60 41 80 	movabs $0x8041605841,%rdi
  80416034e7:	00 00 00 
  80416034ea:	b8 00 00 00 00       	mov    $0x0,%eax
  80416034ef:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  80416034f6:	00 00 00 
  80416034f9:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  80416034fc:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603500:	49 39 c6             	cmp    %rax,%r14
  8041603503:	0f 87 eb 01 00 00    	ja     80416036f4 <line_for_address+0x6c2>
  8041603509:	48 39 d8             	cmp    %rbx,%rax
  804160350c:	0f 82 f9 01 00 00    	jb     804160370b <line_for_address+0x6d9>
          last_state           = *state;
  8041603512:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603516:	49 89 de             	mov    %rbx,%r14
  8041603519:	e9 88 01 00 00       	jmpq   80416036a6 <line_for_address+0x674>
      switch (opcode) {
  804160351e:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  8041603521:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041603526:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160352b:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603530:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041603534:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041603538:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  804160353b:	45 89 c8             	mov    %r9d,%r8d
  804160353e:	41 83 e0 7f          	and    $0x7f,%r8d
  8041603542:	41 d3 e0             	shl    %cl,%r8d
  8041603545:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  8041603548:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160354b:	45 84 c9             	test   %r9b,%r9b
  804160354e:	78 e0                	js     8041603530 <line_for_address+0x4fe>
              info->minimum_instruction_length *
  8041603550:	89 d2                	mov    %edx,%edx
          state->address +=
  8041603552:	48 01 d3             	add    %rdx,%rbx
  return count;
  8041603555:	48 98                	cltq   
          program_addr += count;
  8041603557:	48 01 c6             	add    %rax,%rsi
        } break;
  804160355a:	e9 47 01 00 00       	jmpq   80416036a6 <line_for_address+0x674>
      switch (opcode) {
  804160355f:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  8041603562:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041603567:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160356c:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603571:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  8041603575:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  8041603579:	45 89 c8             	mov    %r9d,%r8d
  804160357c:	41 83 e0 7f          	and    $0x7f,%r8d
  8041603580:	41 d3 e0             	shl    %cl,%r8d
  8041603583:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  8041603586:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041603589:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160358c:	45 84 c9             	test   %r9b,%r9b
  804160358f:	78 e0                	js     8041603571 <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  8041603591:	83 f9 1f             	cmp    $0x1f,%ecx
  8041603594:	7f 0f                	jg     80416035a5 <line_for_address+0x573>
  8041603596:	41 f6 c1 40          	test   $0x40,%r9b
  804160359a:	74 09                	je     80416035a5 <line_for_address+0x573>
    result |= (-1U << shift);
  804160359c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80416035a1:	d3 e7                	shl    %cl,%edi
  80416035a3:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  80416035a5:	41 01 d4             	add    %edx,%r12d
  return count;
  80416035a8:	48 98                	cltq   
          program_addr += count;
  80416035aa:	48 01 c6             	add    %rax,%rsi
        } break;
  80416035ad:	e9 f4 00 00 00       	jmpq   80416036a6 <line_for_address+0x674>
      switch (opcode) {
  80416035b2:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416035b5:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416035ba:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416035bd:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416035c1:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416035c4:	84 c9                	test   %cl,%cl
  80416035c6:	78 f2                	js     80416035ba <line_for_address+0x588>
  return count;
  80416035c8:	48 98                	cltq   
          program_addr += count;
  80416035ca:	48 01 c6             	add    %rax,%rsi
        } break;
  80416035cd:	e9 d4 00 00 00       	jmpq   80416036a6 <line_for_address+0x674>
      switch (opcode) {
  80416035d2:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416035d5:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416035da:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416035dd:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416035e1:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416035e4:	84 c9                	test   %cl,%cl
  80416035e6:	78 f2                	js     80416035da <line_for_address+0x5a8>
  return count;
  80416035e8:	48 98                	cltq   
          program_addr += count;
  80416035ea:	48 01 c6             	add    %rax,%rsi
        } break;
  80416035ed:	e9 b4 00 00 00       	jmpq   80416036a6 <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  80416035f2:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  80416035f6:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  80416035f8:	0f b6 c0             	movzbl %al,%eax
  80416035fb:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  80416035fe:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  8041603601:	48 01 c3             	add    %rax,%rbx
        } break;
  8041603604:	e9 9d 00 00 00       	jmpq   80416036a6 <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  8041603609:	ba 02 00 00 00       	mov    $0x2,%edx
  804160360e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603612:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041603619:	00 00 00 
  804160361c:	ff d0                	callq  *%rax
          state->address += pc_inc;
  804160361e:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041603622:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  8041603625:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  8041603629:	eb 7b                	jmp    80416036a6 <line_for_address+0x674>
      switch (opcode) {
  804160362b:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160362e:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603633:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603636:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160363a:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160363d:	84 c9                	test   %cl,%cl
  804160363f:	78 f2                	js     8041603633 <line_for_address+0x601>
  return count;
  8041603641:	48 98                	cltq   
          program_addr += count;
  8041603643:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603646:	eb 5e                	jmp    80416036a6 <line_for_address+0x674>
      switch (opcode) {
  8041603648:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  804160364b:	48 ba 54 58 60 41 80 	movabs $0x8041605854,%rdx
  8041603652:	00 00 00 
  8041603655:	be c1 00 00 00       	mov    $0xc1,%esi
  804160365a:	48 bf 41 58 60 41 80 	movabs $0x8041605841,%rdi
  8041603661:	00 00 00 
  8041603664:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603669:	49 b8 93 03 60 41 80 	movabs $0x8041600393,%r8
  8041603670:	00 00 00 
  8041603673:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  8041603676:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  8041603679:	0f b6 c0             	movzbl %al,%eax
  804160367c:	f6 75 ba             	divb   -0x46(%rbp)
  804160367f:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  8041603682:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  8041603686:	01 ca                	add    %ecx,%edx
  8041603688:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  804160368b:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  804160368e:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  8041603691:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041603695:	49 39 c6             	cmp    %rax,%r14
  8041603698:	77 05                	ja     804160369f <line_for_address+0x66d>
  804160369a:	48 39 d8             	cmp    %rbx,%rax
  804160369d:	72 72                	jb     8041603711 <line_for_address+0x6df>
      last_state = *state;
  804160369f:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416036a3:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  80416036a6:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  80416036aa:	76 69                	jbe    8041603715 <line_for_address+0x6e3>
  80416036ac:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  80416036af:	ba 01 00 00 00       	mov    $0x1,%edx
  80416036b4:	4c 89 ee             	mov    %r13,%rsi
  80416036b7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416036bb:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  80416036c2:	00 00 00 
  80416036c5:	ff d0                	callq  *%rax
  80416036c7:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  80416036cb:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  80416036cf:	84 c0                	test   %al,%al
  80416036d1:	0f 84 37 fc ff ff    	je     804160330e <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  80416036d7:	38 45 bb             	cmp    %al,-0x45(%rbp)
  80416036da:	76 9a                	jbe    8041603676 <line_for_address+0x644>
      switch (opcode) {
  80416036dc:	3c 0c                	cmp    $0xc,%al
  80416036de:	0f 87 64 ff ff ff    	ja     8041603648 <line_for_address+0x616>
  80416036e4:	0f b6 d0             	movzbl %al,%edx
  80416036e7:	48 bf 00 59 60 41 80 	movabs $0x8041605900,%rdi
  80416036ee:	00 00 00 
  80416036f1:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  80416036f4:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416036f8:	49 89 de             	mov    %rbx,%r14
  80416036fb:	eb a9                	jmp    80416036a6 <line_for_address+0x674>
  struct Line_Number_State current_state = {
  80416036fd:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  8041603703:	eb 10                	jmp    8041603715 <line_for_address+0x6e3>
            *state = last_state;
  8041603705:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603709:	eb 0a                	jmp    8041603715 <line_for_address+0x6e3>
            *state = last_state;
  804160370b:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160370f:	eb 04                	jmp    8041603715 <line_for_address+0x6e3>
        *state = last_state;
  8041603711:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  8041603715:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041603719:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  804160371c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603721:	48 83 c4 38          	add    $0x38,%rsp
  8041603725:	5b                   	pop    %rbx
  8041603726:	41 5c                	pop    %r12
  8041603728:	41 5d                	pop    %r13
  804160372a:	41 5e                	pop    %r14
  804160372c:	41 5f                	pop    %r15
  804160372e:	5d                   	pop    %rbp
  804160372f:	c3                   	retq   
    return -E_INVAL;
  8041603730:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041603735:	eb ea                	jmp    8041603721 <line_for_address+0x6ef>

0000008041603737 <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  8041603737:	55                   	push   %rbp
  8041603738:	48 89 e5             	mov    %rsp,%rbp
  804160373b:	41 55                	push   %r13
  804160373d:	41 54                	push   %r12
  804160373f:	53                   	push   %rbx
  8041603740:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  8041603744:	48 bb 60 5c 60 41 80 	movabs $0x8041605c60,%rbx
  804160374b:	00 00 00 
  804160374e:	4c 8d 6b 78          	lea    0x78(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  8041603752:	49 bc 4c 40 60 41 80 	movabs $0x804160404c,%r12
  8041603759:	00 00 00 
  804160375c:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  8041603760:	48 8b 33             	mov    (%rbx),%rsi
  8041603763:	48 bf 68 59 60 41 80 	movabs $0x8041605968,%rdi
  804160376a:	00 00 00 
  804160376d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603772:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  8041603775:	48 83 c3 18          	add    $0x18,%rbx
  8041603779:	4c 39 eb             	cmp    %r13,%rbx
  804160377c:	75 de                	jne    804160375c <mon_help+0x25>
  return 0;
}
  804160377e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603783:	48 83 c4 08          	add    $0x8,%rsp
  8041603787:	5b                   	pop    %rbx
  8041603788:	41 5c                	pop    %r12
  804160378a:	41 5d                	pop    %r13
  804160378c:	5d                   	pop    %rbp
  804160378d:	c3                   	retq   

000000804160378e <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  804160378e:	55                   	push   %rbp
  804160378f:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603792:	48 bf 71 59 60 41 80 	movabs $0x8041605971,%rdi
  8041603799:	00 00 00 
  804160379c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037a1:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  80416037a8:	00 00 00 
  80416037ab:	ff d2                	callq  *%rdx
  return 0;
}
  80416037ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037b2:	5d                   	pop    %rbp
  80416037b3:	c3                   	retq   

00000080416037b4 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  80416037b4:	55                   	push   %rbp
  80416037b5:	48 89 e5             	mov    %rsp,%rbp
  80416037b8:	41 55                	push   %r13
  80416037ba:	41 54                	push   %r12
  80416037bc:	53                   	push   %rbx
  80416037bd:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  80416037c1:	48 bf 79 59 60 41 80 	movabs $0x8041605979,%rdi
  80416037c8:	00 00 00 
  80416037cb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037d0:	49 bc 4c 40 60 41 80 	movabs $0x804160404c,%r12
  80416037d7:	00 00 00 
  80416037da:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  80416037dd:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  80416037e4:	00 00 00 
  80416037e7:	48 bf c0 5a 60 41 80 	movabs $0x8041605ac0,%rdi
  80416037ee:	00 00 00 
  80416037f1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037f6:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  80416037f9:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  8041603800:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  8041603803:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  804160380a:	00 00 00 
  804160380d:	4c 89 ee             	mov    %r13,%rsi
  8041603810:	48 bf f0 5a 60 41 80 	movabs $0x8041605af0,%rdi
  8041603817:	00 00 00 
  804160381a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160381f:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603822:	48 ba 50 53 60 01 00 	movabs $0x1605350,%rdx
  8041603829:	00 00 00 
  804160382c:	48 be 50 53 60 41 80 	movabs $0x8041605350,%rsi
  8041603833:	00 00 00 
  8041603836:	48 bf 18 5b 60 41 80 	movabs $0x8041605b18,%rdi
  804160383d:	00 00 00 
  8041603840:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603845:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  8041603848:	48 ba d0 35 62 01 00 	movabs $0x16235d0,%rdx
  804160384f:	00 00 00 
  8041603852:	48 be d0 35 62 41 80 	movabs $0x80416235d0,%rsi
  8041603859:	00 00 00 
  804160385c:	48 bf 40 5b 60 41 80 	movabs $0x8041605b40,%rdi
  8041603863:	00 00 00 
  8041603866:	b8 00 00 00 00       	mov    $0x0,%eax
  804160386b:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  804160386e:	48 bb 00 60 62 41 80 	movabs $0x8041626000,%rbx
  8041603875:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  8041603878:	48 ba 00 60 62 01 00 	movabs $0x1626000,%rdx
  804160387f:	00 00 00 
  8041603882:	48 89 de             	mov    %rbx,%rsi
  8041603885:	48 bf 68 5b 60 41 80 	movabs $0x8041605b68,%rdi
  804160388c:	00 00 00 
  804160388f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603894:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  8041603897:	4c 29 eb             	sub    %r13,%rbx
  804160389a:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  80416038a1:	48 c1 ee 0a          	shr    $0xa,%rsi
  80416038a5:	48 bf 90 5b 60 41 80 	movabs $0x8041605b90,%rdi
  80416038ac:	00 00 00 
  80416038af:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038b4:	41 ff d4             	callq  *%r12
  return 0;
}
  80416038b7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038bc:	48 83 c4 08          	add    $0x8,%rsp
  80416038c0:	5b                   	pop    %rbx
  80416038c1:	41 5c                	pop    %r12
  80416038c3:	41 5d                	pop    %r13
  80416038c5:	5d                   	pop    %rbp
  80416038c6:	c3                   	retq   

00000080416038c7 <mon_evenbeyond>:

int
mon_evenbeyond(int argc, char **argv, struct Trapframe *tf) {
  80416038c7:	55                   	push   %rbp
  80416038c8:	48 89 e5             	mov    %rsp,%rbp
  cprintf("My CPU load is OVER %o \n", 9000);
  80416038cb:	be 28 23 00 00       	mov    $0x2328,%esi
  80416038d0:	48 bf 92 59 60 41 80 	movabs $0x8041605992,%rdi
  80416038d7:	00 00 00 
  80416038da:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038df:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  80416038e6:	00 00 00 
  80416038e9:	ff d2                	callq  *%rdx
  return 0;
}
  80416038eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038f0:	5d                   	pop    %rbp
  80416038f1:	c3                   	retq   

00000080416038f2 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  80416038f2:	55                   	push   %rbp
  80416038f3:	48 89 e5             	mov    %rsp,%rbp
  80416038f6:	41 57                	push   %r15
  80416038f8:	41 56                	push   %r14
  80416038fa:	41 55                	push   %r13
  80416038fc:	41 54                	push   %r12
  80416038fe:	53                   	push   %rbx
  80416038ff:	48 81 ec 28 02 00 00 	sub    $0x228,%rsp
  uint64_t *rbp = 0x0;
  uint64_t rip  = 0x0;

  struct Ripdebuginfo info;

  cprintf("Stack backtrace:\n");
  8041603906:	48 bf ab 59 60 41 80 	movabs $0x80416059ab,%rdi
  804160390d:	00 00 00 
  8041603910:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603915:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  804160391c:	00 00 00 
  804160391f:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603921:	48 89 e8             	mov    %rbp,%rax
  rbp = (uint64_t *)read_rbp();
  rip = rbp[1];

  if (rbp == 0x0 || rip == 0x0) {
  8041603924:	48 83 78 08 00       	cmpq   $0x0,0x8(%rax)
  8041603929:	0f 84 a2 00 00 00    	je     80416039d1 <mon_backtrace+0xdf>
  804160392f:	48 89 c3             	mov    %rax,%rbx
  8041603932:	48 85 c0             	test   %rax,%rax
  8041603935:	0f 84 96 00 00 00    	je     80416039d1 <mon_backtrace+0xdf>
    return -1;
  }

  do {
    rip = rbp[1];
    debuginfo_rip(rip, &info);
  804160393b:	49 bf 1c 42 60 41 80 	movabs $0x804160421c,%r15
  8041603942:	00 00 00 

    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  8041603945:	49 bd 4c 40 60 41 80 	movabs $0x804160404c,%r13
  804160394c:	00 00 00 
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  804160394f:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  8041603956:	4c 8d b0 04 01 00 00 	lea    0x104(%rax),%r14
    rip = rbp[1];
  804160395d:	4c 8b 63 08          	mov    0x8(%rbx),%r12
    debuginfo_rip(rip, &info);
  8041603961:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603968:	4c 89 e7             	mov    %r12,%rdi
  804160396b:	41 ff d7             	callq  *%r15
    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  804160396e:	4c 89 e2             	mov    %r12,%rdx
  8041603971:	48 89 de             	mov    %rbx,%rsi
  8041603974:	48 bf bd 59 60 41 80 	movabs $0x80416059bd,%rdi
  804160397b:	00 00 00 
  804160397e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603983:	41 ff d5             	callq  *%r13
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  8041603986:	4d 89 e1             	mov    %r12,%r9
  8041603989:	4c 2b 4d b8          	sub    -0x48(%rbp),%r9
  804160398d:	4d 89 f0             	mov    %r14,%r8
  8041603990:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041603993:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  8041603999:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  80416039a0:	48 bf d7 59 60 41 80 	movabs $0x80416059d7,%rdi
  80416039a7:	00 00 00 
  80416039aa:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039af:	41 ff d5             	callq  *%r13
            info.rip_fn_namelen, info.rip_fn_name, (rip - info.rip_fn_addr));
    // cprintf(" args:%d \n", info.rip_fn_narg);
    rbp = (uint64_t *)rbp[0];
  80416039b2:	48 8b 1b             	mov    (%rbx),%rbx

  } while (rbp);
  80416039b5:	48 85 db             	test   %rbx,%rbx
  80416039b8:	75 a3                	jne    804160395d <mon_backtrace+0x6b>

  return 0;
  80416039ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416039bf:	48 81 c4 28 02 00 00 	add    $0x228,%rsp
  80416039c6:	5b                   	pop    %rbx
  80416039c7:	41 5c                	pop    %r12
  80416039c9:	41 5d                	pop    %r13
  80416039cb:	41 5e                	pop    %r14
  80416039cd:	41 5f                	pop    %r15
  80416039cf:	5d                   	pop    %rbp
  80416039d0:	c3                   	retq   
    cprintf("JOS: ERR: Couldn't obtain backtrace...\n");
  80416039d1:	48 bf c0 5b 60 41 80 	movabs $0x8041605bc0,%rdi
  80416039d8:	00 00 00 
  80416039db:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039e0:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  80416039e7:	00 00 00 
  80416039ea:	ff d2                	callq  *%rdx
    return -1;
  80416039ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416039f1:	eb cc                	jmp    80416039bf <mon_backtrace+0xcd>

00000080416039f3 <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  80416039f3:	55                   	push   %rbp
  80416039f4:	48 89 e5             	mov    %rsp,%rbp
  80416039f7:	41 57                	push   %r15
  80416039f9:	41 56                	push   %r14
  80416039fb:	41 55                	push   %r13
  80416039fd:	41 54                	push   %r12
  80416039ff:	53                   	push   %rbx
  8041603a00:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8041603a07:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603a0e:	48 bf e8 5b 60 41 80 	movabs $0x8041605be8,%rdi
  8041603a15:	00 00 00 
  8041603a18:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a1d:	48 bb 4c 40 60 41 80 	movabs $0x804160404c,%rbx
  8041603a24:	00 00 00 
  8041603a27:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603a29:	48 bf 10 5c 60 41 80 	movabs $0x8041605c10,%rdi
  8041603a30:	00 00 00 
  8041603a33:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a38:	ff d3                	callq  *%rbx

  while (1) {
    buf = readline("K> ");
  8041603a3a:	49 bf 20 4d 60 41 80 	movabs $0x8041604d20,%r15
  8041603a41:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603a44:	49 be d0 4f 60 41 80 	movabs $0x8041604fd0,%r14
  8041603a4b:	00 00 00 
  8041603a4e:	e9 ff 00 00 00       	jmpq   8041603b52 <monitor+0x15f>
  8041603a53:	40 0f be f6          	movsbl %sil,%esi
  8041603a57:	48 bf f9 59 60 41 80 	movabs $0x80416059f9,%rdi
  8041603a5e:	00 00 00 
  8041603a61:	41 ff d6             	callq  *%r14
  8041603a64:	48 85 c0             	test   %rax,%rax
  8041603a67:	74 0c                	je     8041603a75 <monitor+0x82>
      *buf++ = 0;
  8041603a69:	c6 03 00             	movb   $0x0,(%rbx)
  8041603a6c:	45 89 e5             	mov    %r12d,%r13d
  8041603a6f:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603a73:	eb 49                	jmp    8041603abe <monitor+0xcb>
    if (*buf == 0)
  8041603a75:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603a78:	74 4f                	je     8041603ac9 <monitor+0xd6>
    if (argc == MAXARGS - 1) {
  8041603a7a:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603a7e:	0f 84 b3 00 00 00    	je     8041603b37 <monitor+0x144>
    argv[argc++] = buf;
  8041603a84:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  8041603a89:	4d 63 e4             	movslq %r12d,%r12
  8041603a8c:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041603a93:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603a94:	0f b6 33             	movzbl (%rbx),%esi
  8041603a97:	40 84 f6             	test   %sil,%sil
  8041603a9a:	74 22                	je     8041603abe <monitor+0xcb>
  8041603a9c:	40 0f be f6          	movsbl %sil,%esi
  8041603aa0:	48 bf f9 59 60 41 80 	movabs $0x80416059f9,%rdi
  8041603aa7:	00 00 00 
  8041603aaa:	41 ff d6             	callq  *%r14
  8041603aad:	48 85 c0             	test   %rax,%rax
  8041603ab0:	75 0c                	jne    8041603abe <monitor+0xcb>
      buf++;
  8041603ab2:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603ab6:	0f b6 33             	movzbl (%rbx),%esi
  8041603ab9:	40 84 f6             	test   %sil,%sil
  8041603abc:	75 de                	jne    8041603a9c <monitor+0xa9>
      *buf++ = 0;
  8041603abe:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603ac1:	0f b6 33             	movzbl (%rbx),%esi
  8041603ac4:	40 84 f6             	test   %sil,%sil
  8041603ac7:	75 8a                	jne    8041603a53 <monitor+0x60>
  argv[argc] = 0;
  8041603ac9:	49 63 c4             	movslq %r12d,%rax
  8041603acc:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041603ad3:	ff 00 00 00 00 
  if (argc == 0)
  8041603ad8:	45 85 e4             	test   %r12d,%r12d
  8041603adb:	74 75                	je     8041603b52 <monitor+0x15f>
  8041603add:	49 bd 60 5c 60 41 80 	movabs $0x8041605c60,%r13
  8041603ae4:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041603ae7:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  8041603aec:	49 8b 75 00          	mov    0x0(%r13),%rsi
  8041603af0:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041603af7:	48 b8 69 4f 60 41 80 	movabs $0x8041604f69,%rax
  8041603afe:	00 00 00 
  8041603b01:	ff d0                	callq  *%rax
  8041603b03:	85 c0                	test   %eax,%eax
  8041603b05:	74 76                	je     8041603b7d <monitor+0x18a>
  for (i = 0; i < NCOMMANDS; i++) {
  8041603b07:	83 c3 01             	add    $0x1,%ebx
  8041603b0a:	49 83 c5 18          	add    $0x18,%r13
  8041603b0e:	83 fb 05             	cmp    $0x5,%ebx
  8041603b11:	75 d9                	jne    8041603aec <monitor+0xf9>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041603b13:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041603b1a:	48 bf 1b 5a 60 41 80 	movabs $0x8041605a1b,%rdi
  8041603b21:	00 00 00 
  8041603b24:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b29:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041603b30:	00 00 00 
  8041603b33:	ff d2                	callq  *%rdx
  return 0;
  8041603b35:	eb 1b                	jmp    8041603b52 <monitor+0x15f>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041603b37:	be 10 00 00 00       	mov    $0x10,%esi
  8041603b3c:	48 bf fe 59 60 41 80 	movabs $0x80416059fe,%rdi
  8041603b43:	00 00 00 
  8041603b46:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041603b4d:	00 00 00 
  8041603b50:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  8041603b52:	48 bf f5 59 60 41 80 	movabs $0x80416059f5,%rdi
  8041603b59:	00 00 00 
  8041603b5c:	41 ff d7             	callq  *%r15
  8041603b5f:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  8041603b62:	48 85 c0             	test   %rax,%rax
  8041603b65:	74 eb                	je     8041603b52 <monitor+0x15f>
  argv[argc] = 0;
  8041603b67:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  8041603b6e:	00 00 00 00 
  argc       = 0;
  8041603b72:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041603b78:	e9 44 ff ff ff       	jmpq   8041603ac1 <monitor+0xce>
      return commands[i].func(argc, argv, tf);
  8041603b7d:	48 63 db             	movslq %ebx,%rbx
  8041603b80:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  8041603b84:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  8041603b8b:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  8041603b92:	44 89 e7             	mov    %r12d,%edi
  8041603b95:	48 b8 60 5c 60 41 80 	movabs $0x8041605c60,%rax
  8041603b9c:	00 00 00 
  8041603b9f:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  8041603ba3:	85 c0                	test   %eax,%eax
  8041603ba5:	79 ab                	jns    8041603b52 <monitor+0x15f>
        break;
  }
}
  8041603ba7:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041603bae:	5b                   	pop    %rbx
  8041603baf:	41 5c                	pop    %r12
  8041603bb1:	41 5d                	pop    %r13
  8041603bb3:	41 5e                	pop    %r14
  8041603bb5:	41 5f                	pop    %r15
  8041603bb7:	5d                   	pop    %rbp
  8041603bb8:	c3                   	retq   

0000008041603bb9 <envid2env>:
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
  8041603bb9:	85 ff                	test   %edi,%edi
  8041603bbb:	74 5c                	je     8041603c19 <envid2env+0x60>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  8041603bbd:	89 f8                	mov    %edi,%eax
  8041603bbf:	83 e0 1f             	and    $0x1f,%eax
  8041603bc2:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
  8041603bc9:	00 
  8041603bca:	48 29 c1             	sub    %rax,%rcx
  8041603bcd:	48 c1 e1 05          	shl    $0x5,%rcx
  8041603bd1:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  8041603bd8:	00 00 00 
  8041603bdb:	48 01 c1             	add    %rax,%rcx
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  8041603bde:	83 b9 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rcx)
  8041603be5:	74 42                	je     8041603c29 <envid2env+0x70>
  8041603be7:	39 b9 c8 00 00 00    	cmp    %edi,0xc8(%rcx)
  8041603bed:	75 3a                	jne    8041603c29 <envid2env+0x70>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  8041603bef:	84 d2                	test   %dl,%dl
  8041603bf1:	74 1d                	je     8041603c10 <envid2env+0x57>
  8041603bf3:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603bfa:	00 00 00 
  8041603bfd:	48 39 c8             	cmp    %rcx,%rax
  8041603c00:	74 0e                	je     8041603c10 <envid2env+0x57>
  8041603c02:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8041603c08:	39 81 cc 00 00 00    	cmp    %eax,0xcc(%rcx)
  8041603c0e:	75 26                	jne    8041603c36 <envid2env+0x7d>
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  8041603c10:	48 89 0e             	mov    %rcx,(%rsi)
  return 0;
  8041603c13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603c18:	c3                   	retq   
    *env_store = curenv;
  8041603c19:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603c20:	00 00 00 
  8041603c23:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  8041603c26:	89 f8                	mov    %edi,%eax
  8041603c28:	c3                   	retq   
    *env_store = 0;
  8041603c29:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603c30:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603c35:	c3                   	retq   
    *env_store = 0;
  8041603c36:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603c3d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603c42:	c3                   	retq   

0000008041603c43 <env_init_percpu>:
  env_init_percpu();
};

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  8041603c43:	55                   	push   %rbp
  8041603c44:	48 89 e5             	mov    %rsp,%rbp
  8041603c47:	53                   	push   %rbx
                   : "r"(sel));
}

static __inline void
lgdt(void *p) {
  __asm __volatile("lgdt (%0)"
  8041603c48:	48 b8 20 77 61 41 80 	movabs $0x8041617720,%rax
  8041603c4f:	00 00 00 
  8041603c52:	0f 01 10             	lgdt   (%rax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  8041603c55:	b8 33 00 00 00       	mov    $0x33,%eax
  8041603c5a:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  8041603c5c:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  8041603c5e:	b8 10 00 00 00       	mov    $0x10,%eax
  8041603c63:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041603c65:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041603c67:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  8041603c69:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041603c6e:	53                   	push   %rbx
  8041603c6f:	48 b8 7c 3c 60 41 80 	movabs $0x8041603c7c,%rax
  8041603c76:	00 00 00 
  8041603c79:	50                   	push   %rax
  8041603c7a:	48 cb                	lretq  
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  8041603c7c:	66 b8 00 00          	mov    $0x0,%ax
  8041603c80:	0f 00 d0             	lldt   %ax
               :
               :
               : "cc", "memory");
}
  8041603c83:	5b                   	pop    %rbx
  8041603c84:	5d                   	pop    %rbp
  8041603c85:	c3                   	retq   

0000008041603c86 <env_init>:
env_init(void) {
  8041603c86:	55                   	push   %rbp
  8041603c87:	48 89 e5             	mov    %rsp,%rbp
  env_free_list = envs; // env_free_list = &envs[0]; ?????
  8041603c8a:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  8041603c91:	00 00 00 
  8041603c94:	48 a3 48 38 62 41 80 	movabs %rax,0x8041623848
  8041603c9b:	00 00 00 
  8041603c9e:	41 b9 00 00 00 02    	mov    $0x2000000,%r9d
  8041603ca4:	be 00 00 00 00       	mov    $0x0,%esi
  for (uint32_t i = 0; i < NENV; ++i) {
  8041603ca9:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    envs[i].env_status = ENV_FREE;
  8041603caf:	49 ba 88 77 61 41 80 	movabs $0x8041617788,%r10
  8041603cb6:	00 00 00 
      envs[i].env_link = &envs[i + 1];
  8041603cb9:	b8 00 00 00 00       	mov    $0x0,%eax
    envs[i].env_status = ENV_FREE;
  8041603cbe:	49 8b 0a             	mov    (%r10),%rcx
  8041603cc1:	48 8d 14 31          	lea    (%rcx,%rsi,1),%rdx
  8041603cc5:	c7 82 d4 00 00 00 00 	movl   $0x0,0xd4(%rdx)
  8041603ccc:	00 00 00 
      envs[i].env_link = &envs[i + 1];
  8041603ccf:	48 8d 8c 31 e0 00 00 	lea    0xe0(%rcx,%rsi,1),%rcx
  8041603cd6:	00 
  8041603cd7:	41 83 f8 1f          	cmp    $0x1f,%r8d
  8041603cdb:	48 0f 44 c8          	cmove  %rax,%rcx
  8041603cdf:	48 89 8a c0 00 00 00 	mov    %rcx,0xc0(%rdx)
    envs[i].env_type = ENV_TYPE_KERNEL;
  8041603ce6:	c7 82 d0 00 00 00 01 	movl   $0x1,0xd0(%rdx)
  8041603ced:	00 00 00 
    envs[i].env_id = 0;
  8041603cf0:	c7 82 c8 00 00 00 00 	movl   $0x0,0xc8(%rdx)
  8041603cf7:	00 00 00 
    envs[i].env_parent_id = 0;
  8041603cfa:	c7 82 cc 00 00 00 00 	movl   $0x0,0xcc(%rdx)
  8041603d01:	00 00 00 
    envs[i].env_tf = (const struct Trapframe){ 0 };
  8041603d04:	b9 18 00 00 00       	mov    $0x18,%ecx
  8041603d09:	48 89 d7             	mov    %rdx,%rdi
  8041603d0c:	f3 48 ab             	rep stos %rax,%es:(%rdi)
    envs[i].env_tf.tf_rflags = read_rflags();
  8041603d0f:	48 89 f2             	mov    %rsi,%rdx
  8041603d12:	49 03 12             	add    (%r10),%rdx
}

static __inline uint64_t
read_rflags(void) {
  uint64_t rflags;
  __asm __volatile("pushfq; popq %0"
  8041603d15:	9c                   	pushfq 
  8041603d16:	59                   	pop    %rcx
  8041603d17:	48 89 8a a8 00 00 00 	mov    %rcx,0xa8(%rdx)
    envs[i].env_runs = 0;
  8041603d1e:	c7 82 d8 00 00 00 00 	movl   $0x0,0xd8(%rdx)
  8041603d25:	00 00 00 
    envs[i].env_tf.tf_rsp = STACK_TOP + i * 4 * PGSIZE;
  8041603d28:	4c 89 8a b0 00 00 00 	mov    %r9,0xb0(%rdx)
  for (uint32_t i = 0; i < NENV; ++i) {
  8041603d2f:	41 83 c0 01          	add    $0x1,%r8d
  8041603d33:	48 81 c6 e0 00 00 00 	add    $0xe0,%rsi
  8041603d3a:	49 81 c1 00 40 00 00 	add    $0x4000,%r9
  8041603d41:	41 83 f8 20          	cmp    $0x20,%r8d
  8041603d45:	0f 85 73 ff ff ff    	jne    8041603cbe <env_init+0x38>
  env_init_percpu();
  8041603d4b:	48 b8 43 3c 60 41 80 	movabs $0x8041603c43,%rax
  8041603d52:	00 00 00 
  8041603d55:	ff d0                	callq  *%rax
};
  8041603d57:	5d                   	pop    %rbp
  8041603d58:	c3                   	retq   

0000008041603d59 <env_alloc>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  8041603d59:	55                   	push   %rbp
  8041603d5a:	48 89 e5             	mov    %rsp,%rbp
  8041603d5d:	41 54                	push   %r12
  8041603d5f:	53                   	push   %rbx
  int32_t generation;
  struct Env *e;

  if (!(e = env_free_list)) {
  8041603d60:	48 b8 48 38 62 41 80 	movabs $0x8041623848,%rax
  8041603d67:	00 00 00 
  8041603d6a:	48 8b 18             	mov    (%rax),%rbx
  8041603d6d:	48 85 db             	test   %rbx,%rbx
  8041603d70:	0f 84 f6 00 00 00    	je     8041603e6c <env_alloc+0x113>
  8041603d76:	49 89 fc             	mov    %rdi,%r12
    return -E_NO_FREE_ENV;
  }

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  8041603d79:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  8041603d7f:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041603d84:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  8041603d87:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041603d8c:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  8041603d8f:	48 ba 88 77 61 41 80 	movabs $0x8041617788,%rdx
  8041603d96:	00 00 00 
  8041603d99:	48 89 d9             	mov    %rbx,%rcx
  8041603d9c:	48 2b 0a             	sub    (%rdx),%rcx
  8041603d9f:	48 89 ca             	mov    %rcx,%rdx
  8041603da2:	48 c1 fa 05          	sar    $0x5,%rdx
  8041603da6:	69 d2 b7 6d db b6    	imul   $0xb6db6db7,%edx,%edx
  8041603dac:	09 d0                	or     %edx,%eax
  8041603dae:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
  8041603db4:	89 b3 cc 00 00 00    	mov    %esi,0xcc(%rbx)
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
  8041603dba:	c7 83 d0 00 00 00 01 	movl   $0x1,0xd0(%rbx)
  8041603dc1:	00 00 00 
#else
#endif
  e->env_status = ENV_RUNNABLE;
  8041603dc4:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  8041603dcb:	00 00 00 
  e->env_runs   = 0;
  8041603dce:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  8041603dd5:	00 00 00 

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  8041603dd8:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041603ddd:	be 00 00 00 00       	mov    $0x0,%esi
  8041603de2:	48 89 df             	mov    %rbx,%rdi
  8041603de5:	48 b8 22 50 60 41 80 	movabs $0x8041605022,%rax
  8041603dec:	00 00 00 
  8041603def:	ff d0                	callq  *%rax
  // Requestor Privilege Level (RPL); 3 means user mode, 0 - kernel mode.  When
  // we switch privilege levels, the hardware does various
  // checks involving the RPL and the Descriptor Privilege Level
  // (DPL) stored in the descriptors themselves.
#ifdef CONFIG_KSPACE
  e->env_tf.tf_ds = GD_KD | 0;
  8041603df1:	66 c7 83 80 00 00 00 	movw   $0x10,0x80(%rbx)
  8041603df8:	10 00 
  e->env_tf.tf_es = GD_KD | 0;
  8041603dfa:	66 c7 43 78 10 00    	movw   $0x10,0x78(%rbx)
  e->env_tf.tf_ss = GD_KD | 0;
  8041603e00:	66 c7 83 b8 00 00 00 	movw   $0x10,0xb8(%rbx)
  8041603e07:	10 00 
  e->env_tf.tf_cs = GD_KT | 0;
  8041603e09:	66 c7 83 a0 00 00 00 	movw   $0x8,0xa0(%rbx)
  8041603e10:	08 00 
#else
#endif
  // You will set e->env_tf.tf_rip later.

  // commit the allocation
  env_free_list = e->env_link;
  8041603e12:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  8041603e19:	48 a3 48 38 62 41 80 	movabs %rax,0x8041623848
  8041603e20:	00 00 00 
  *newenv_store = e;
  8041603e23:	49 89 1c 24          	mov    %rbx,(%r12)

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603e27:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  8041603e2d:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603e34:	00 00 00 
  8041603e37:	be 00 00 00 00       	mov    $0x0,%esi
  8041603e3c:	48 85 c0             	test   %rax,%rax
  8041603e3f:	74 06                	je     8041603e47 <env_alloc+0xee>
  8041603e41:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041603e47:	48 bf d8 5c 60 41 80 	movabs $0x8041605cd8,%rdi
  8041603e4e:	00 00 00 
  8041603e51:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603e56:	48 b9 4c 40 60 41 80 	movabs $0x804160404c,%rcx
  8041603e5d:	00 00 00 
  8041603e60:	ff d1                	callq  *%rcx

  return 0;
  8041603e62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603e67:	5b                   	pop    %rbx
  8041603e68:	41 5c                	pop    %r12
  8041603e6a:	5d                   	pop    %rbp
  8041603e6b:	c3                   	retq   
    return -E_NO_FREE_ENV;
  8041603e6c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  8041603e71:	eb f4                	jmp    8041603e67 <env_alloc+0x10e>

0000008041603e73 <env_create>:
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  // LAB 3: Your code here.
}
  8041603e73:	c3                   	retq   

0000008041603e74 <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041603e74:	55                   	push   %rbp
  8041603e75:	48 89 e5             	mov    %rsp,%rbp
  8041603e78:	53                   	push   %rbx
  8041603e79:	48 83 ec 08          	sub    $0x8,%rsp
  8041603e7d:	48 89 fb             	mov    %rdi,%rbx
  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603e80:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041603e86:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603e8d:	00 00 00 
  8041603e90:	be 00 00 00 00       	mov    $0x0,%esi
  8041603e95:	48 85 c0             	test   %rax,%rax
  8041603e98:	74 06                	je     8041603ea0 <env_free+0x2c>
  8041603e9a:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041603ea0:	48 bf ed 5c 60 41 80 	movabs $0x8041605ced,%rdi
  8041603ea7:	00 00 00 
  8041603eaa:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603eaf:	48 b9 4c 40 60 41 80 	movabs $0x804160404c,%rcx
  8041603eb6:	00 00 00 
  8041603eb9:	ff d1                	callq  *%rcx

  // return the environment to the free list
  e->env_status = ENV_FREE;
  8041603ebb:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  8041603ec2:	00 00 00 
  e->env_link   = env_free_list;
  8041603ec5:	48 b8 48 38 62 41 80 	movabs $0x8041623848,%rax
  8041603ecc:	00 00 00 
  8041603ecf:	48 8b 10             	mov    (%rax),%rdx
  8041603ed2:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  8041603ed9:	48 89 18             	mov    %rbx,(%rax)
}
  8041603edc:	48 83 c4 08          	add    $0x8,%rsp
  8041603ee0:	5b                   	pop    %rbx
  8041603ee1:	5d                   	pop    %rbp
  8041603ee2:	c3                   	retq   

0000008041603ee3 <env_destroy>:
env_destroy(struct Env *e) {
  // LAB 3: Your code here.
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
}
  8041603ee3:	c3                   	retq   

0000008041603ee4 <csys_exit>:

#ifdef CONFIG_KSPACE
void
csys_exit(void) {
  env_destroy(curenv);
}
  8041603ee4:	c3                   	retq   

0000008041603ee5 <csys_yield>:

void
csys_yield(struct Trapframe *tf) {
  8041603ee5:	55                   	push   %rbp
  8041603ee6:	48 89 e5             	mov    %rsp,%rbp
  8041603ee9:	48 89 fe             	mov    %rdi,%rsi
  memcpy(&curenv->env_tf, tf, sizeof(struct Trapframe));
  8041603eec:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041603ef1:	48 b8 40 38 62 41 80 	movabs $0x8041623840,%rax
  8041603ef8:	00 00 00 
  8041603efb:	48 8b 38             	mov    (%rax),%rdi
  8041603efe:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041603f05:	00 00 00 
  8041603f08:	ff d0                	callq  *%rax
  sched_yield();
  8041603f0a:	48 b8 e0 40 60 41 80 	movabs $0x80416040e0,%rax
  8041603f11:	00 00 00 
  8041603f14:	ff d0                	callq  *%rax

0000008041603f16 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041603f16:	55                   	push   %rbp
  8041603f17:	48 89 e5             	mov    %rsp,%rbp
  8041603f1a:	53                   	push   %rbx
  8041603f1b:	48 83 ec 08          	sub    $0x8,%rsp
  8041603f1f:	48 89 f8             	mov    %rdi,%rax
#ifdef CONFIG_KSPACE
  static uintptr_t rip = 0;
  rip                  = tf->tf_rip;

  asm volatile(
  8041603f22:	48 8b 58 68          	mov    0x68(%rax),%rbx
  8041603f26:	48 8b 48 60          	mov    0x60(%rax),%rcx
  8041603f2a:	48 8b 50 58          	mov    0x58(%rax),%rdx
  8041603f2e:	48 8b 70 40          	mov    0x40(%rax),%rsi
  8041603f32:	48 8b 78 48          	mov    0x48(%rax),%rdi
  8041603f36:	48 8b 68 50          	mov    0x50(%rax),%rbp
  8041603f3a:	48 8b a0 b0 00 00 00 	mov    0xb0(%rax),%rsp
  8041603f41:	4c 8b 40 38          	mov    0x38(%rax),%r8
  8041603f45:	4c 8b 48 30          	mov    0x30(%rax),%r9
  8041603f49:	4c 8b 50 28          	mov    0x28(%rax),%r10
  8041603f4d:	4c 8b 58 20          	mov    0x20(%rax),%r11
  8041603f51:	4c 8b 60 18          	mov    0x18(%rax),%r12
  8041603f55:	4c 8b 68 10          	mov    0x10(%rax),%r13
  8041603f59:	4c 8b 70 08          	mov    0x8(%rax),%r14
  8041603f5d:	4c 8b 38             	mov    (%rax),%r15
  8041603f60:	ff b0 98 00 00 00    	pushq  0x98(%rax)
  8041603f66:	ff b0 a8 00 00 00    	pushq  0xa8(%rax)
  8041603f6c:	48 8b 40 70          	mov    0x70(%rax),%rax
  8041603f70:	9d                   	popfq  
  8041603f71:	c3                   	retq   
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041603f72:	48 ba 03 5d 60 41 80 	movabs $0x8041605d03,%rdx
  8041603f79:	00 00 00 
  8041603f7c:	be c1 01 00 00       	mov    $0x1c1,%esi
  8041603f81:	48 bf 07 5d 60 41 80 	movabs $0x8041605d07,%rdi
  8041603f88:	00 00 00 
  8041603f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f90:	48 b9 93 03 60 41 80 	movabs $0x8041600393,%rcx
  8041603f97:	00 00 00 
  8041603f9a:	ff d1                	callq  *%rcx

0000008041603f9c <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  8041603f9c:	55                   	push   %rbp
  8041603f9d:	48 89 e5             	mov    %rsp,%rbp
#ifdef CONFIG_KSPACE
  cprintf("envrun %s: %d\n",
  8041603fa0:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041603fa6:	83 e2 1f             	and    $0x1f,%edx
          e->env_status == ENV_RUNNING ? "RUNNING" :
  8041603fa9:	8b 87 d4 00 00 00    	mov    0xd4(%rdi),%eax
  cprintf("envrun %s: %d\n",
  8041603faf:	48 be 12 5d 60 41 80 	movabs $0x8041605d12,%rsi
  8041603fb6:	00 00 00 
  8041603fb9:	83 f8 03             	cmp    $0x3,%eax
  8041603fbc:	74 1b                	je     8041603fd9 <env_run+0x3d>
                                         e->env_status == ENV_RUNNABLE ? "RUNNABLE" : "(unknown)",
  8041603fbe:	83 f8 02             	cmp    $0x2,%eax
  8041603fc1:	48 be 1a 5d 60 41 80 	movabs $0x8041605d1a,%rsi
  8041603fc8:	00 00 00 
  8041603fcb:	48 b8 23 5d 60 41 80 	movabs $0x8041605d23,%rax
  8041603fd2:	00 00 00 
  8041603fd5:	48 0f 45 f0          	cmovne %rax,%rsi
  cprintf("envrun %s: %d\n",
  8041603fd9:	48 bf 2d 5d 60 41 80 	movabs $0x8041605d2d,%rdi
  8041603fe0:	00 00 00 
  8041603fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603fe8:	48 b9 4c 40 60 41 80 	movabs $0x804160404c,%rcx
  8041603fef:	00 00 00 
  8041603ff2:	ff d1                	callq  *%rcx
  //	e->env_tf to sensible values.
  //
  // LAB 3: Your code here.
  
  
  while(1) {}
  8041603ff4:	eb fe                	jmp    8041603ff4 <env_run+0x58>

0000008041603ff6 <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  8041603ff6:	55                   	push   %rbp
  8041603ff7:	48 89 e5             	mov    %rsp,%rbp
  8041603ffa:	53                   	push   %rbx
  8041603ffb:	48 83 ec 08          	sub    $0x8,%rsp
  8041603fff:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  8041604002:	48 b8 1b 0c 60 41 80 	movabs $0x8041600c1b,%rax
  8041604009:	00 00 00 
  804160400c:	ff d0                	callq  *%rax
  (*cnt)++;
  804160400e:	83 03 01             	addl   $0x1,(%rbx)
}
  8041604011:	48 83 c4 08          	add    $0x8,%rsp
  8041604015:	5b                   	pop    %rbx
  8041604016:	5d                   	pop    %rbp
  8041604017:	c3                   	retq   

0000008041604018 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8041604018:	55                   	push   %rbp
  8041604019:	48 89 e5             	mov    %rsp,%rbp
  804160401c:	48 83 ec 10          	sub    $0x10,%rsp
  8041604020:	48 89 fa             	mov    %rdi,%rdx
  8041604023:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  8041604026:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  804160402d:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  8041604031:	48 bf f6 3f 60 41 80 	movabs $0x8041603ff6,%rdi
  8041604038:	00 00 00 
  804160403b:	48 b8 6b 45 60 41 80 	movabs $0x804160456b,%rax
  8041604042:	00 00 00 
  8041604045:	ff d0                	callq  *%rax
  return cnt;
}
  8041604047:	8b 45 fc             	mov    -0x4(%rbp),%eax
  804160404a:	c9                   	leaveq 
  804160404b:	c3                   	retq   

000000804160404c <cprintf>:

int
cprintf(const char *fmt, ...) {
  804160404c:	55                   	push   %rbp
  804160404d:	48 89 e5             	mov    %rsp,%rbp
  8041604050:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041604057:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  804160405e:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041604065:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160406c:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041604073:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  804160407a:	84 c0                	test   %al,%al
  804160407c:	74 20                	je     804160409e <cprintf+0x52>
  804160407e:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604082:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604086:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  804160408a:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160408e:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604092:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604096:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  804160409a:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  804160409e:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  80416040a5:	00 00 00 
  80416040a8:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80416040af:	00 00 00 
  80416040b2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416040b6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80416040bd:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80416040c4:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80416040cb:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  80416040d2:	48 b8 18 40 60 41 80 	movabs $0x8041604018,%rax
  80416040d9:	00 00 00 
  80416040dc:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  80416040de:	c9                   	leaveq 
  80416040df:	c3                   	retq   

00000080416040e0 <sched_yield>:
  // If there are no runnable environments,
  // simply drop through to the code
  // below to halt the cpu.

  // LAB 3: Your code here.
}
  80416040e0:	c3                   	retq   

00000080416040e1 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  80416040e1:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  80416040e8:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  80416040eb:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  80416040f1:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  80416040f4:	83 fa 02             	cmp    $0x2,%edx
  80416040f7:	76 5c                	jbe    8041604155 <sched_halt+0x74>
  80416040f9:	48 8d 90 b4 01 00 00 	lea    0x1b4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  8041604100:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  8041604105:	8b 02                	mov    (%rdx),%eax
  8041604107:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160410a:	83 f8 02             	cmp    $0x2,%eax
  804160410d:	76 46                	jbe    8041604155 <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  804160410f:	83 c1 01             	add    $0x1,%ecx
  8041604112:	48 81 c2 e0 00 00 00 	add    $0xe0,%rdx
  8041604119:	83 f9 20             	cmp    $0x20,%ecx
  804160411c:	75 e7                	jne    8041604105 <sched_halt+0x24>
sched_halt(void) {
  804160411e:	55                   	push   %rbp
  804160411f:	48 89 e5             	mov    %rsp,%rbp
  8041604122:	53                   	push   %rbx
  8041604123:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  8041604127:	48 bf 40 5d 60 41 80 	movabs $0x8041605d40,%rdi
  804160412e:	00 00 00 
  8041604131:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604136:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  804160413d:	00 00 00 
  8041604140:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  8041604142:	48 bb f3 39 60 41 80 	movabs $0x80416039f3,%rbx
  8041604149:	00 00 00 
  804160414c:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604151:	ff d3                	callq  *%rbx
    while (1)
  8041604153:	eb f7                	jmp    804160414c <sched_halt+0x6b>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  8041604155:	48 b8 40 38 62 41 80 	movabs $0x8041623840,%rax
  804160415c:	00 00 00 
  804160415f:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  8041604166:	48 a1 84 58 62 41 80 	movabs 0x8041625884,%rax
  804160416d:	00 00 00 
  8041604170:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  8041604177:	48 89 c4             	mov    %rax,%rsp
  804160417a:	6a 00                	pushq  $0x0
  804160417c:	6a 00                	pushq  $0x0
  804160417e:	fb                   	sti    
  804160417f:	f4                   	hlt    
  8041604180:	c3                   	retq   

0000008041604181 <load_kernel_dwarf_info>:
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  8041604181:	48 ba 00 70 61 41 80 	movabs $0x8041617000,%rdx
  8041604188:	00 00 00 
  804160418b:	48 8b 02             	mov    (%rdx),%rax
  804160418e:	48 8b 48 58          	mov    0x58(%rax),%rcx
  8041604192:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  8041604196:	48 8b 48 60          	mov    0x60(%rax),%rcx
  804160419a:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  804160419e:	48 8b 40 68          	mov    0x68(%rax),%rax
  80416041a2:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  80416041a5:	48 8b 02             	mov    (%rdx),%rax
  80416041a8:	48 8b 50 70          	mov    0x70(%rax),%rdx
  80416041ac:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  80416041b0:	48 8b 50 78          	mov    0x78(%rax),%rdx
  80416041b4:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  80416041b8:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  80416041bf:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  80416041c3:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  80416041ca:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  80416041ce:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  80416041d5:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  80416041d9:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  80416041e0:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  80416041e4:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  80416041eb:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  80416041ef:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  80416041f6:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  80416041fa:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  8041604201:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  8041604205:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  804160420c:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  8041604210:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  8041604217:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  804160421b:	c3                   	retq   

000000804160421c <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  804160421c:	55                   	push   %rbp
  804160421d:	48 89 e5             	mov    %rsp,%rbp
  8041604220:	41 56                	push   %r14
  8041604222:	41 55                	push   %r13
  8041604224:	41 54                	push   %r12
  8041604226:	53                   	push   %rbx
  8041604227:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  804160422e:	49 89 fc             	mov    %rdi,%r12
  8041604231:	48 89 f3             	mov    %rsi,%rbx
  int code = 0;
  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  8041604234:	48 be 69 5d 60 41 80 	movabs $0x8041605d69,%rsi
  804160423b:	00 00 00 
  804160423e:	48 89 df             	mov    %rbx,%rdi
  8041604241:	49 bd b1 4e 60 41 80 	movabs $0x8041604eb1,%r13
  8041604248:	00 00 00 
  804160424b:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  804160424e:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  8041604255:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  8041604258:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  804160425f:	48 be 69 5d 60 41 80 	movabs $0x8041605d69,%rsi
  8041604266:	00 00 00 
  8041604269:	4c 89 f7             	mov    %r14,%rdi
  804160426c:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  804160426f:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  8041604276:	00 00 00 
  info->rip_fn_addr    = addr;
  8041604279:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  8041604280:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  8041604287:	00 00 00 

  if (!addr) {
  804160428a:	4d 85 e4             	test   %r12,%r12
  804160428d:	0f 84 8f 01 00 00    	je     8041604422 <debuginfo_rip+0x206>
    return 0;
  }

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  8041604293:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  804160429a:	00 00 00 
  804160429d:	49 39 c4             	cmp    %rax,%r12
  80416042a0:	0f 86 52 01 00 00    	jbe    80416043f8 <debuginfo_rip+0x1dc>
    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  80416042a6:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416042ad:	48 b8 81 41 60 41 80 	movabs $0x8041604181,%rax
  80416042b4:	00 00 00 
  80416042b7:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  80416042b9:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  80416042c0:	00 00 00 00 
  80416042c4:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  80416042cb:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  80416042cf:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  80416042d6:	4c 89 e6             	mov    %r12,%rsi
  80416042d9:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416042e0:	48 b8 df 15 60 41 80 	movabs $0x80416015df,%rax
  80416042e7:	00 00 00 
  80416042ea:	ff d0                	callq  *%rax
  80416042ec:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  80416042ef:	85 c0                	test   %eax,%eax
  80416042f1:	0f 88 31 01 00 00    	js     8041604428 <debuginfo_rip+0x20c>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  80416042f7:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  80416042fe:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604303:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160430a:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  8041604311:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041604318:	48 b8 8e 1c 60 41 80 	movabs $0x8041601c8e,%rax
  804160431f:	00 00 00 
  8041604322:	ff d0                	callq  *%rax
  8041604324:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  8041604327:	ba 00 01 00 00       	mov    $0x100,%edx
  804160432c:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041604333:	48 89 df             	mov    %rbx,%rdi
  8041604336:	48 b8 ff 4e 60 41 80 	movabs $0x8041604eff,%rax
  804160433d:	00 00 00 
  8041604340:	ff d0                	callq  *%rax
  if (code < 0) {
  8041604342:	45 85 ed             	test   %r13d,%r13d
  8041604345:	0f 88 dd 00 00 00    	js     8041604428 <debuginfo_rip+0x20c>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
  // LAB 2: Your code here:
  buf  = &info->rip_line;
  addr = addr - 5;
  804160434b:	49 83 ec 05          	sub    $0x5,%r12
  buf  = &info->rip_line;
  804160434f:	48 8d 8b 00 01 00 00 	lea    0x100(%rbx),%rcx
  code = line_for_address(&addrs, addr, line_offset, buf);
  8041604356:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  804160435d:	4c 89 e6             	mov    %r12,%rsi
  8041604360:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041604367:	48 b8 32 30 60 41 80 	movabs $0x8041603032,%rax
  804160436e:	00 00 00 
  8041604371:	ff d0                	callq  *%rax
  if (code < 0) {
    return 0;
  8041604373:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  if (code < 0) {
  8041604379:	85 c0                	test   %eax,%eax
  804160437b:	0f 88 a7 00 00 00    	js     8041604428 <debuginfo_rip+0x20c>
  }
  
  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  8041604381:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  8041604388:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160438e:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  8041604395:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  804160439c:	4c 89 e6             	mov    %r12,%rsi
  804160439f:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416043a6:	48 b8 f9 20 60 41 80 	movabs $0x80416020f9,%rax
  80416043ad:	00 00 00 
  80416043b0:	ff d0                	callq  *%rax
  80416043b2:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  80416043b5:	ba 00 01 00 00       	mov    $0x100,%edx
  80416043ba:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  80416043c1:	4c 89 f7             	mov    %r14,%rdi
  80416043c4:	48 b8 ff 4e 60 41 80 	movabs $0x8041604eff,%rax
  80416043cb:	00 00 00 
  80416043ce:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  80416043d0:	be 00 01 00 00       	mov    $0x100,%esi
  80416043d5:	4c 89 f7             	mov    %r14,%rdi
  80416043d8:	48 b8 7c 4e 60 41 80 	movabs $0x8041604e7c,%rax
  80416043df:	00 00 00 
  80416043e2:	ff d0                	callq  *%rax
  80416043e4:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  80416043ea:	45 85 ed             	test   %r13d,%r13d
  80416043ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80416043f2:	44 0f 4f e8          	cmovg  %eax,%r13d
  80416043f6:	eb 30                	jmp    8041604428 <debuginfo_rip+0x20c>
    panic("Can't search for user-level addresses yet!");
  80416043f8:	48 ba 88 5d 60 41 80 	movabs $0x8041605d88,%rdx
  80416043ff:	00 00 00 
  8041604402:	be 36 00 00 00       	mov    $0x36,%esi
  8041604407:	48 bf 73 5d 60 41 80 	movabs $0x8041605d73,%rdi
  804160440e:	00 00 00 
  8041604411:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604416:	48 b9 93 03 60 41 80 	movabs $0x8041600393,%rcx
  804160441d:	00 00 00 
  8041604420:	ff d1                	callq  *%rcx
    return 0;
  8041604422:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    return code;
  }
  return 0;
}
  8041604428:	44 89 e8             	mov    %r13d,%eax
  804160442b:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  8041604432:	5b                   	pop    %rbx
  8041604433:	41 5c                	pop    %r12
  8041604435:	41 5d                	pop    %r13
  8041604437:	41 5e                	pop    %r14
  8041604439:	5d                   	pop    %rbp
  804160443a:	c3                   	retq   

000000804160443b <find_function>:
  // address_by_fname, which looks for function name in section .debug_pubnames
  // and naive_address_by_fname which performs full traversal of DIE tree.
  // LAB 3: Your code here

  return 0;
}
  804160443b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604440:	c3                   	retq   

0000008041604441 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8041604441:	55                   	push   %rbp
  8041604442:	48 89 e5             	mov    %rsp,%rbp
  8041604445:	41 57                	push   %r15
  8041604447:	41 56                	push   %r14
  8041604449:	41 55                	push   %r13
  804160444b:	41 54                	push   %r12
  804160444d:	53                   	push   %rbx
  804160444e:	48 83 ec 18          	sub    $0x18,%rsp
  8041604452:	49 89 fc             	mov    %rdi,%r12
  8041604455:	49 89 f5             	mov    %rsi,%r13
  8041604458:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  804160445c:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  804160445f:	41 89 cf             	mov    %ecx,%r15d
  8041604462:	49 39 d7             	cmp    %rdx,%r15
  8041604465:	76 45                	jbe    80416044ac <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  8041604467:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160446b:	85 db                	test   %ebx,%ebx
  804160446d:	7e 0e                	jle    804160447d <printnum+0x3c>
      putch(padc, putdat);
  804160446f:	4c 89 ee             	mov    %r13,%rsi
  8041604472:	44 89 f7             	mov    %r14d,%edi
  8041604475:	41 ff d4             	callq  *%r12
    while (--width > 0)
  8041604478:	83 eb 01             	sub    $0x1,%ebx
  804160447b:	75 f2                	jne    804160446f <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  804160447d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041604481:	ba 00 00 00 00       	mov    $0x0,%edx
  8041604486:	49 f7 f7             	div    %r15
  8041604489:	48 b8 b8 5d 60 41 80 	movabs $0x8041605db8,%rax
  8041604490:	00 00 00 
  8041604493:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8041604497:	4c 89 ee             	mov    %r13,%rsi
  804160449a:	41 ff d4             	callq  *%r12
}
  804160449d:	48 83 c4 18          	add    $0x18,%rsp
  80416044a1:	5b                   	pop    %rbx
  80416044a2:	41 5c                	pop    %r12
  80416044a4:	41 5d                	pop    %r13
  80416044a6:	41 5e                	pop    %r14
  80416044a8:	41 5f                	pop    %r15
  80416044aa:	5d                   	pop    %rbp
  80416044ab:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80416044ac:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80416044b0:	ba 00 00 00 00       	mov    $0x0,%edx
  80416044b5:	49 f7 f7             	div    %r15
  80416044b8:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80416044bc:	48 89 c2             	mov    %rax,%rdx
  80416044bf:	48 b8 41 44 60 41 80 	movabs $0x8041604441,%rax
  80416044c6:	00 00 00 
  80416044c9:	ff d0                	callq  *%rax
  80416044cb:	eb b0                	jmp    804160447d <printnum+0x3c>

00000080416044cd <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80416044cd:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80416044d1:	48 8b 06             	mov    (%rsi),%rax
  80416044d4:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80416044d8:	73 0a                	jae    80416044e4 <sprintputch+0x17>
    *b->buf++ = ch;
  80416044da:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80416044de:	48 89 16             	mov    %rdx,(%rsi)
  80416044e1:	40 88 38             	mov    %dil,(%rax)
}
  80416044e4:	c3                   	retq   

00000080416044e5 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  80416044e5:	55                   	push   %rbp
  80416044e6:	48 89 e5             	mov    %rsp,%rbp
  80416044e9:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  80416044f0:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80416044f7:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80416044fe:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604505:	84 c0                	test   %al,%al
  8041604507:	74 20                	je     8041604529 <printfmt+0x44>
  8041604509:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  804160450d:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604511:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604515:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041604519:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  804160451d:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604521:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604525:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  8041604529:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041604530:	00 00 00 
  8041604533:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160453a:	00 00 00 
  804160453d:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041604541:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041604548:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  804160454f:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  8041604556:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  804160455d:	48 b8 6b 45 60 41 80 	movabs $0x804160456b,%rax
  8041604564:	00 00 00 
  8041604567:	ff d0                	callq  *%rax
}
  8041604569:	c9                   	leaveq 
  804160456a:	c3                   	retq   

000000804160456b <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  804160456b:	55                   	push   %rbp
  804160456c:	48 89 e5             	mov    %rsp,%rbp
  804160456f:	41 57                	push   %r15
  8041604571:	41 56                	push   %r14
  8041604573:	41 55                	push   %r13
  8041604575:	41 54                	push   %r12
  8041604577:	53                   	push   %rbx
  8041604578:	48 83 ec 48          	sub    $0x48,%rsp
  804160457c:	49 89 fd             	mov    %rdi,%r13
  804160457f:	49 89 f7             	mov    %rsi,%r15
  8041604582:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8041604585:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8041604589:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  804160458d:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8041604591:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8041604595:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8041604599:	41 0f b6 3e          	movzbl (%r14),%edi
  804160459d:	83 ff 25             	cmp    $0x25,%edi
  80416045a0:	74 18                	je     80416045ba <vprintfmt+0x4f>
      if (ch == '\0')
  80416045a2:	85 ff                	test   %edi,%edi
  80416045a4:	0f 84 8c 06 00 00    	je     8041604c36 <vprintfmt+0x6cb>
      putch(ch, putdat);
  80416045aa:	4c 89 fe             	mov    %r15,%rsi
  80416045ad:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80416045b0:	49 89 de             	mov    %rbx,%r14
  80416045b3:	eb e0                	jmp    8041604595 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80416045b5:	49 89 de             	mov    %rbx,%r14
  80416045b8:	eb db                	jmp    8041604595 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80416045ba:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80416045be:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80416045c2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80416045c9:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80416045cf:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80416045d3:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80416045d8:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  80416045de:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  80416045e4:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80416045e9:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  80416045ee:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  80416045f2:	0f b6 13             	movzbl (%rbx),%edx
  80416045f5:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80416045f8:	3c 55                	cmp    $0x55,%al
  80416045fa:	0f 87 8b 05 00 00    	ja     8041604b8b <vprintfmt+0x620>
  8041604600:	0f b6 c0             	movzbl %al,%eax
  8041604603:	49 bb 60 5e 60 41 80 	movabs $0x8041605e60,%r11
  804160460a:	00 00 00 
  804160460d:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8041604611:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8041604614:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  8041604618:	eb d4                	jmp    80416045ee <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160461a:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  804160461d:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8041604621:	eb cb                	jmp    80416045ee <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8041604623:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  8041604626:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  804160462a:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  804160462e:	8d 50 d0             	lea    -0x30(%rax),%edx
  8041604631:	83 fa 09             	cmp    $0x9,%edx
  8041604634:	77 7e                	ja     80416046b4 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  8041604636:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  804160463a:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  804160463e:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8041604643:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  8041604647:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160464a:	83 fa 09             	cmp    $0x9,%edx
  804160464d:	76 e7                	jbe    8041604636 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  804160464f:	4c 89 f3             	mov    %r14,%rbx
  8041604652:	eb 19                	jmp    804160466d <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8041604654:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604657:	83 f8 2f             	cmp    $0x2f,%eax
  804160465a:	77 2a                	ja     8041604686 <vprintfmt+0x11b>
  804160465c:	89 c2                	mov    %eax,%edx
  804160465e:	4c 01 d2             	add    %r10,%rdx
  8041604661:	83 c0 08             	add    $0x8,%eax
  8041604664:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604667:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  804160466a:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  804160466d:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041604671:	0f 89 77 ff ff ff    	jns    80416045ee <vprintfmt+0x83>
          width = precision, precision = -1;
  8041604677:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160467b:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8041604681:	e9 68 ff ff ff       	jmpq   80416045ee <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8041604686:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160468a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160468e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604692:	eb d3                	jmp    8041604667 <vprintfmt+0xfc>
        if (width < 0)
  8041604694:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8041604697:	85 c0                	test   %eax,%eax
  8041604699:	41 0f 48 c0          	cmovs  %r8d,%eax
  804160469d:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80416046a0:	4c 89 f3             	mov    %r14,%rbx
  80416046a3:	e9 46 ff ff ff       	jmpq   80416045ee <vprintfmt+0x83>
  80416046a8:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80416046ab:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80416046af:	e9 3a ff ff ff       	jmpq   80416045ee <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80416046b4:	4c 89 f3             	mov    %r14,%rbx
  80416046b7:	eb b4                	jmp    804160466d <vprintfmt+0x102>
        lflag++;
  80416046b9:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80416046bc:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80416046bf:	e9 2a ff ff ff       	jmpq   80416045ee <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80416046c4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416046c7:	83 f8 2f             	cmp    $0x2f,%eax
  80416046ca:	77 19                	ja     80416046e5 <vprintfmt+0x17a>
  80416046cc:	89 c2                	mov    %eax,%edx
  80416046ce:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416046d2:	83 c0 08             	add    $0x8,%eax
  80416046d5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416046d8:	4c 89 fe             	mov    %r15,%rsi
  80416046db:	8b 3a                	mov    (%rdx),%edi
  80416046dd:	41 ff d5             	callq  *%r13
        break;
  80416046e0:	e9 b0 fe ff ff       	jmpq   8041604595 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  80416046e5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416046e9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416046ed:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416046f1:	eb e5                	jmp    80416046d8 <vprintfmt+0x16d>
        err = va_arg(aq, int);
  80416046f3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416046f6:	83 f8 2f             	cmp    $0x2f,%eax
  80416046f9:	77 5b                	ja     8041604756 <vprintfmt+0x1eb>
  80416046fb:	89 c2                	mov    %eax,%edx
  80416046fd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604701:	83 c0 08             	add    $0x8,%eax
  8041604704:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604707:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  8041604709:	89 c8                	mov    %ecx,%eax
  804160470b:	c1 f8 1f             	sar    $0x1f,%eax
  804160470e:	31 c1                	xor    %eax,%ecx
  8041604710:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8041604712:	83 f9 08             	cmp    $0x8,%ecx
  8041604715:	7f 4d                	jg     8041604764 <vprintfmt+0x1f9>
  8041604717:	48 63 c1             	movslq %ecx,%rax
  804160471a:	48 ba 20 61 60 41 80 	movabs $0x8041606120,%rdx
  8041604721:	00 00 00 
  8041604724:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  8041604728:	48 85 c0             	test   %rax,%rax
  804160472b:	74 37                	je     8041604764 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  804160472d:	48 89 c1             	mov    %rax,%rcx
  8041604730:	48 ba 8b 56 60 41 80 	movabs $0x804160568b,%rdx
  8041604737:	00 00 00 
  804160473a:	4c 89 fe             	mov    %r15,%rsi
  804160473d:	4c 89 ef             	mov    %r13,%rdi
  8041604740:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604745:	48 bb e5 44 60 41 80 	movabs $0x80416044e5,%rbx
  804160474c:	00 00 00 
  804160474f:	ff d3                	callq  *%rbx
  8041604751:	e9 3f fe ff ff       	jmpq   8041604595 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  8041604756:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160475a:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160475e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604762:	eb a3                	jmp    8041604707 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8041604764:	48 ba d0 5d 60 41 80 	movabs $0x8041605dd0,%rdx
  804160476b:	00 00 00 
  804160476e:	4c 89 fe             	mov    %r15,%rsi
  8041604771:	4c 89 ef             	mov    %r13,%rdi
  8041604774:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604779:	48 bb e5 44 60 41 80 	movabs $0x80416044e5,%rbx
  8041604780:	00 00 00 
  8041604783:	ff d3                	callq  *%rbx
  8041604785:	e9 0b fe ff ff       	jmpq   8041604595 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  804160478a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160478d:	83 f8 2f             	cmp    $0x2f,%eax
  8041604790:	77 4b                	ja     80416047dd <vprintfmt+0x272>
  8041604792:	89 c2                	mov    %eax,%edx
  8041604794:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604798:	83 c0 08             	add    $0x8,%eax
  804160479b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160479e:	48 8b 02             	mov    (%rdx),%rax
  80416047a1:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80416047a5:	48 85 c0             	test   %rax,%rax
  80416047a8:	0f 84 05 04 00 00    	je     8041604bb3 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80416047ae:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80416047b2:	7e 06                	jle    80416047ba <vprintfmt+0x24f>
  80416047b4:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80416047b8:	75 31                	jne    80416047eb <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80416047ba:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416047be:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80416047c2:	0f b6 00             	movzbl (%rax),%eax
  80416047c5:	0f be f8             	movsbl %al,%edi
  80416047c8:	85 ff                	test   %edi,%edi
  80416047ca:	0f 84 c3 00 00 00    	je     8041604893 <vprintfmt+0x328>
  80416047d0:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80416047d4:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80416047d8:	e9 85 00 00 00       	jmpq   8041604862 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  80416047dd:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416047e1:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416047e5:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416047e9:	eb b3                	jmp    804160479e <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80416047eb:	49 63 f4             	movslq %r12d,%rsi
  80416047ee:	48 89 c7             	mov    %rax,%rdi
  80416047f1:	48 b8 7c 4e 60 41 80 	movabs $0x8041604e7c,%rax
  80416047f8:	00 00 00 
  80416047fb:	ff d0                	callq  *%rax
  80416047fd:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8041604800:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8041604803:	85 f6                	test   %esi,%esi
  8041604805:	7e 22                	jle    8041604829 <vprintfmt+0x2be>
            putch(padc, putdat);
  8041604807:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  804160480b:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  804160480f:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8041604813:	4c 89 fe             	mov    %r15,%rsi
  8041604816:	89 df                	mov    %ebx,%edi
  8041604818:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  804160481b:	41 83 ec 01          	sub    $0x1,%r12d
  804160481f:	75 f2                	jne    8041604813 <vprintfmt+0x2a8>
  8041604821:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8041604825:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604829:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  804160482d:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8041604831:	0f b6 00             	movzbl (%rax),%eax
  8041604834:	0f be f8             	movsbl %al,%edi
  8041604837:	85 ff                	test   %edi,%edi
  8041604839:	0f 84 56 fd ff ff    	je     8041604595 <vprintfmt+0x2a>
  804160483f:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041604843:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8041604847:	eb 19                	jmp    8041604862 <vprintfmt+0x2f7>
            putch(ch, putdat);
  8041604849:	4c 89 fe             	mov    %r15,%rsi
  804160484c:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160484f:	41 83 ee 01          	sub    $0x1,%r14d
  8041604853:	48 83 c3 01          	add    $0x1,%rbx
  8041604857:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  804160485b:	0f be f8             	movsbl %al,%edi
  804160485e:	85 ff                	test   %edi,%edi
  8041604860:	74 29                	je     804160488b <vprintfmt+0x320>
  8041604862:	45 85 e4             	test   %r12d,%r12d
  8041604865:	78 06                	js     804160486d <vprintfmt+0x302>
  8041604867:	41 83 ec 01          	sub    $0x1,%r12d
  804160486b:	78 48                	js     80416048b5 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  804160486d:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8041604871:	74 d6                	je     8041604849 <vprintfmt+0x2de>
  8041604873:	0f be c0             	movsbl %al,%eax
  8041604876:	83 e8 20             	sub    $0x20,%eax
  8041604879:	83 f8 5e             	cmp    $0x5e,%eax
  804160487c:	76 cb                	jbe    8041604849 <vprintfmt+0x2de>
            putch('?', putdat);
  804160487e:	4c 89 fe             	mov    %r15,%rsi
  8041604881:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8041604886:	41 ff d5             	callq  *%r13
  8041604889:	eb c4                	jmp    804160484f <vprintfmt+0x2e4>
  804160488b:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  804160488f:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8041604893:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8041604896:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  804160489a:	0f 8e f5 fc ff ff    	jle    8041604595 <vprintfmt+0x2a>
          putch(' ', putdat);
  80416048a0:	4c 89 fe             	mov    %r15,%rsi
  80416048a3:	bf 20 00 00 00       	mov    $0x20,%edi
  80416048a8:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80416048ab:	83 eb 01             	sub    $0x1,%ebx
  80416048ae:	75 f0                	jne    80416048a0 <vprintfmt+0x335>
  80416048b0:	e9 e0 fc ff ff       	jmpq   8041604595 <vprintfmt+0x2a>
  80416048b5:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80416048b9:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80416048bd:	eb d4                	jmp    8041604893 <vprintfmt+0x328>
  if (lflag >= 2)
  80416048bf:	83 f9 01             	cmp    $0x1,%ecx
  80416048c2:	7f 1d                	jg     80416048e1 <vprintfmt+0x376>
  else if (lflag)
  80416048c4:	85 c9                	test   %ecx,%ecx
  80416048c6:	74 5e                	je     8041604926 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80416048c8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416048cb:	83 f8 2f             	cmp    $0x2f,%eax
  80416048ce:	77 48                	ja     8041604918 <vprintfmt+0x3ad>
  80416048d0:	89 c2                	mov    %eax,%edx
  80416048d2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416048d6:	83 c0 08             	add    $0x8,%eax
  80416048d9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416048dc:	48 8b 1a             	mov    (%rdx),%rbx
  80416048df:	eb 17                	jmp    80416048f8 <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  80416048e1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416048e4:	83 f8 2f             	cmp    $0x2f,%eax
  80416048e7:	77 21                	ja     804160490a <vprintfmt+0x39f>
  80416048e9:	89 c2                	mov    %eax,%edx
  80416048eb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416048ef:	83 c0 08             	add    $0x8,%eax
  80416048f2:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416048f5:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80416048f8:	48 85 db             	test   %rbx,%rbx
  80416048fb:	78 50                	js     804160494d <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80416048fd:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8041604900:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604905:	e9 b4 01 00 00       	jmpq   8041604abe <vprintfmt+0x553>
    return va_arg(*ap, long long);
  804160490a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160490e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604912:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604916:	eb dd                	jmp    80416048f5 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  8041604918:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160491c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604920:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604924:	eb b6                	jmp    80416048dc <vprintfmt+0x371>
    return va_arg(*ap, int);
  8041604926:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604929:	83 f8 2f             	cmp    $0x2f,%eax
  804160492c:	77 11                	ja     804160493f <vprintfmt+0x3d4>
  804160492e:	89 c2                	mov    %eax,%edx
  8041604930:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604934:	83 c0 08             	add    $0x8,%eax
  8041604937:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160493a:	48 63 1a             	movslq (%rdx),%rbx
  804160493d:	eb b9                	jmp    80416048f8 <vprintfmt+0x38d>
  804160493f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604943:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604947:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160494b:	eb ed                	jmp    804160493a <vprintfmt+0x3cf>
          putch('-', putdat);
  804160494d:	4c 89 fe             	mov    %r15,%rsi
  8041604950:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8041604955:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  8041604958:	48 89 da             	mov    %rbx,%rdx
  804160495b:	48 f7 da             	neg    %rdx
        base = 10;
  804160495e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604963:	e9 56 01 00 00       	jmpq   8041604abe <vprintfmt+0x553>
  if (lflag >= 2)
  8041604968:	83 f9 01             	cmp    $0x1,%ecx
  804160496b:	7f 25                	jg     8041604992 <vprintfmt+0x427>
  else if (lflag)
  804160496d:	85 c9                	test   %ecx,%ecx
  804160496f:	74 5e                	je     80416049cf <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8041604971:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604974:	83 f8 2f             	cmp    $0x2f,%eax
  8041604977:	77 48                	ja     80416049c1 <vprintfmt+0x456>
  8041604979:	89 c2                	mov    %eax,%edx
  804160497b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  804160497f:	83 c0 08             	add    $0x8,%eax
  8041604982:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604985:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8041604988:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160498d:	e9 2c 01 00 00       	jmpq   8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604992:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604995:	83 f8 2f             	cmp    $0x2f,%eax
  8041604998:	77 19                	ja     80416049b3 <vprintfmt+0x448>
  804160499a:	89 c2                	mov    %eax,%edx
  804160499c:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416049a0:	83 c0 08             	add    $0x8,%eax
  80416049a3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416049a6:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80416049a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416049ae:	e9 0b 01 00 00       	jmpq   8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80416049b3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416049b7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416049bb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416049bf:	eb e5                	jmp    80416049a6 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80416049c1:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416049c5:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416049c9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416049cd:	eb b6                	jmp    8041604985 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80416049cf:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416049d2:	83 f8 2f             	cmp    $0x2f,%eax
  80416049d5:	77 18                	ja     80416049ef <vprintfmt+0x484>
  80416049d7:	89 c2                	mov    %eax,%edx
  80416049d9:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416049dd:	83 c0 08             	add    $0x8,%eax
  80416049e0:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416049e3:	8b 12                	mov    (%rdx),%edx
        base = 10;
  80416049e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416049ea:	e9 cf 00 00 00       	jmpq   8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80416049ef:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416049f3:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416049f7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416049fb:	eb e6                	jmp    80416049e3 <vprintfmt+0x478>
  if (lflag >= 2)
  80416049fd:	83 f9 01             	cmp    $0x1,%ecx
  8041604a00:	7f 25                	jg     8041604a27 <vprintfmt+0x4bc>
  else if (lflag)
  8041604a02:	85 c9                	test   %ecx,%ecx
  8041604a04:	74 5b                	je     8041604a61 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  8041604a06:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604a09:	83 f8 2f             	cmp    $0x2f,%eax
  8041604a0c:	77 45                	ja     8041604a53 <vprintfmt+0x4e8>
  8041604a0e:	89 c2                	mov    %eax,%edx
  8041604a10:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604a14:	83 c0 08             	add    $0x8,%eax
  8041604a17:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604a1a:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8041604a1d:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604a22:	e9 97 00 00 00       	jmpq   8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604a27:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604a2a:	83 f8 2f             	cmp    $0x2f,%eax
  8041604a2d:	77 16                	ja     8041604a45 <vprintfmt+0x4da>
  8041604a2f:	89 c2                	mov    %eax,%edx
  8041604a31:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604a35:	83 c0 08             	add    $0x8,%eax
  8041604a38:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604a3b:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8041604a3e:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604a43:	eb 79                	jmp    8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604a45:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604a49:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604a4d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a51:	eb e8                	jmp    8041604a3b <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8041604a53:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604a57:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604a5b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a5f:	eb b9                	jmp    8041604a1a <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8041604a61:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604a64:	83 f8 2f             	cmp    $0x2f,%eax
  8041604a67:	77 15                	ja     8041604a7e <vprintfmt+0x513>
  8041604a69:	89 c2                	mov    %eax,%edx
  8041604a6b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604a6f:	83 c0 08             	add    $0x8,%eax
  8041604a72:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604a75:	8b 12                	mov    (%rdx),%edx
        base = 8;
  8041604a77:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604a7c:	eb 40                	jmp    8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8041604a7e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604a82:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604a86:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a8a:	eb e9                	jmp    8041604a75 <vprintfmt+0x50a>
        putch('0', putdat);
  8041604a8c:	4c 89 fe             	mov    %r15,%rsi
  8041604a8f:	bf 30 00 00 00       	mov    $0x30,%edi
  8041604a94:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8041604a97:	4c 89 fe             	mov    %r15,%rsi
  8041604a9a:	bf 78 00 00 00       	mov    $0x78,%edi
  8041604a9f:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041604aa2:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604aa5:	83 f8 2f             	cmp    $0x2f,%eax
  8041604aa8:	77 34                	ja     8041604ade <vprintfmt+0x573>
  8041604aaa:	89 c2                	mov    %eax,%edx
  8041604aac:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604ab0:	83 c0 08             	add    $0x8,%eax
  8041604ab3:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604ab6:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041604ab9:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8041604abe:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8041604ac3:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8041604ac7:	4c 89 fe             	mov    %r15,%rsi
  8041604aca:	4c 89 ef             	mov    %r13,%rdi
  8041604acd:	48 b8 41 44 60 41 80 	movabs $0x8041604441,%rax
  8041604ad4:	00 00 00 
  8041604ad7:	ff d0                	callq  *%rax
        break;
  8041604ad9:	e9 b7 fa ff ff       	jmpq   8041604595 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041604ade:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604ae2:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604ae6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604aea:	eb ca                	jmp    8041604ab6 <vprintfmt+0x54b>
  if (lflag >= 2)
  8041604aec:	83 f9 01             	cmp    $0x1,%ecx
  8041604aef:	7f 22                	jg     8041604b13 <vprintfmt+0x5a8>
  else if (lflag)
  8041604af1:	85 c9                	test   %ecx,%ecx
  8041604af3:	74 58                	je     8041604b4d <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8041604af5:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604af8:	83 f8 2f             	cmp    $0x2f,%eax
  8041604afb:	77 42                	ja     8041604b3f <vprintfmt+0x5d4>
  8041604afd:	89 c2                	mov    %eax,%edx
  8041604aff:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604b03:	83 c0 08             	add    $0x8,%eax
  8041604b06:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604b09:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041604b0c:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604b11:	eb ab                	jmp    8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604b13:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604b16:	83 f8 2f             	cmp    $0x2f,%eax
  8041604b19:	77 16                	ja     8041604b31 <vprintfmt+0x5c6>
  8041604b1b:	89 c2                	mov    %eax,%edx
  8041604b1d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604b21:	83 c0 08             	add    $0x8,%eax
  8041604b24:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604b27:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041604b2a:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604b2f:	eb 8d                	jmp    8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604b31:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604b35:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604b39:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604b3d:	eb e8                	jmp    8041604b27 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  8041604b3f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604b43:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604b47:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604b4b:	eb bc                	jmp    8041604b09 <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  8041604b4d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604b50:	83 f8 2f             	cmp    $0x2f,%eax
  8041604b53:	77 18                	ja     8041604b6d <vprintfmt+0x602>
  8041604b55:	89 c2                	mov    %eax,%edx
  8041604b57:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604b5b:	83 c0 08             	add    $0x8,%eax
  8041604b5e:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604b61:	8b 12                	mov    (%rdx),%edx
        base = 16;
  8041604b63:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604b68:	e9 51 ff ff ff       	jmpq   8041604abe <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8041604b6d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604b71:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604b75:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604b79:	eb e6                	jmp    8041604b61 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8041604b7b:	4c 89 fe             	mov    %r15,%rsi
  8041604b7e:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604b83:	41 ff d5             	callq  *%r13
        break;
  8041604b86:	e9 0a fa ff ff       	jmpq   8041604595 <vprintfmt+0x2a>
        putch('%', putdat);
  8041604b8b:	4c 89 fe             	mov    %r15,%rsi
  8041604b8e:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604b93:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8041604b96:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8041604b9a:	0f 84 15 fa ff ff    	je     80416045b5 <vprintfmt+0x4a>
  8041604ba0:	49 89 de             	mov    %rbx,%r14
  8041604ba3:	49 83 ee 01          	sub    $0x1,%r14
  8041604ba7:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8041604bac:	75 f5                	jne    8041604ba3 <vprintfmt+0x638>
  8041604bae:	e9 e2 f9 ff ff       	jmpq   8041604595 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8041604bb3:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041604bb7:	74 06                	je     8041604bbf <vprintfmt+0x654>
  8041604bb9:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041604bbd:	7f 21                	jg     8041604be0 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604bbf:	bf 28 00 00 00       	mov    $0x28,%edi
  8041604bc4:	48 bb ca 5d 60 41 80 	movabs $0x8041605dca,%rbx
  8041604bcb:	00 00 00 
  8041604bce:	b8 28 00 00 00       	mov    $0x28,%eax
  8041604bd3:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041604bd7:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8041604bdb:	e9 82 fc ff ff       	jmpq   8041604862 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8041604be0:	49 63 f4             	movslq %r12d,%rsi
  8041604be3:	48 bf c9 5d 60 41 80 	movabs $0x8041605dc9,%rdi
  8041604bea:	00 00 00 
  8041604bed:	48 b8 7c 4e 60 41 80 	movabs $0x8041604e7c,%rax
  8041604bf4:	00 00 00 
  8041604bf7:	ff d0                	callq  *%rax
  8041604bf9:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8041604bfc:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  8041604bff:	48 be c9 5d 60 41 80 	movabs $0x8041605dc9,%rsi
  8041604c06:	00 00 00 
  8041604c09:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  8041604c0d:	85 c0                	test   %eax,%eax
  8041604c0f:	0f 8f f2 fb ff ff    	jg     8041604807 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604c15:	48 bb ca 5d 60 41 80 	movabs $0x8041605dca,%rbx
  8041604c1c:	00 00 00 
  8041604c1f:	b8 28 00 00 00       	mov    $0x28,%eax
  8041604c24:	bf 28 00 00 00       	mov    $0x28,%edi
  8041604c29:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041604c2d:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8041604c31:	e9 2c fc ff ff       	jmpq   8041604862 <vprintfmt+0x2f7>
}
  8041604c36:	48 83 c4 48          	add    $0x48,%rsp
  8041604c3a:	5b                   	pop    %rbx
  8041604c3b:	41 5c                	pop    %r12
  8041604c3d:	41 5d                	pop    %r13
  8041604c3f:	41 5e                	pop    %r14
  8041604c41:	41 5f                	pop    %r15
  8041604c43:	5d                   	pop    %rbp
  8041604c44:	c3                   	retq   

0000008041604c45 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8041604c45:	55                   	push   %rbp
  8041604c46:	48 89 e5             	mov    %rsp,%rbp
  8041604c49:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  8041604c4d:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  8041604c51:	48 63 c6             	movslq %esi,%rax
  8041604c54:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  8041604c59:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8041604c5d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  8041604c64:	48 85 ff             	test   %rdi,%rdi
  8041604c67:	74 2a                	je     8041604c93 <vsnprintf+0x4e>
  8041604c69:	85 f6                	test   %esi,%esi
  8041604c6b:	7e 26                	jle    8041604c93 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  8041604c6d:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  8041604c71:	48 bf cd 44 60 41 80 	movabs $0x80416044cd,%rdi
  8041604c78:	00 00 00 
  8041604c7b:	48 b8 6b 45 60 41 80 	movabs $0x804160456b,%rax
  8041604c82:	00 00 00 
  8041604c85:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  8041604c87:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8041604c8b:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  8041604c8e:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  8041604c91:	c9                   	leaveq 
  8041604c92:	c3                   	retq   
    return -E_INVAL;
  8041604c93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041604c98:	eb f7                	jmp    8041604c91 <vsnprintf+0x4c>

0000008041604c9a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  8041604c9a:	55                   	push   %rbp
  8041604c9b:	48 89 e5             	mov    %rsp,%rbp
  8041604c9e:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041604ca5:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041604cac:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041604cb3:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604cba:	84 c0                	test   %al,%al
  8041604cbc:	74 20                	je     8041604cde <snprintf+0x44>
  8041604cbe:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604cc2:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604cc6:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604cca:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041604cce:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604cd2:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604cd6:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604cda:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  8041604cde:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041604ce5:	00 00 00 
  8041604ce8:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041604cef:	00 00 00 
  8041604cf2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041604cf6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041604cfd:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041604d04:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  8041604d0b:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8041604d12:	48 b8 45 4c 60 41 80 	movabs $0x8041604c45,%rax
  8041604d19:	00 00 00 
  8041604d1c:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  8041604d1e:	c9                   	leaveq 
  8041604d1f:	c3                   	retq   

0000008041604d20 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  8041604d20:	55                   	push   %rbp
  8041604d21:	48 89 e5             	mov    %rsp,%rbp
  8041604d24:	41 57                	push   %r15
  8041604d26:	41 56                	push   %r14
  8041604d28:	41 55                	push   %r13
  8041604d2a:	41 54                	push   %r12
  8041604d2c:	53                   	push   %rbx
  8041604d2d:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  8041604d31:	48 85 ff             	test   %rdi,%rdi
  8041604d34:	74 1e                	je     8041604d54 <readline+0x34>
    cprintf("%s", prompt);
  8041604d36:	48 89 fe             	mov    %rdi,%rsi
  8041604d39:	48 bf 8b 56 60 41 80 	movabs $0x804160568b,%rdi
  8041604d40:	00 00 00 
  8041604d43:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d48:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041604d4f:	00 00 00 
  8041604d52:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  8041604d54:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604d59:	48 b8 4d 0c 60 41 80 	movabs $0x8041600c4d,%rax
  8041604d60:	00 00 00 
  8041604d63:	ff d0                	callq  *%rax
  8041604d65:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  8041604d68:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  8041604d6e:	49 bd 2d 0c 60 41 80 	movabs $0x8041600c2d,%r13
  8041604d75:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  8041604d78:	49 bf 1b 0c 60 41 80 	movabs $0x8041600c1b,%r15
  8041604d7f:	00 00 00 
  8041604d82:	eb 3f                	jmp    8041604dc3 <readline+0xa3>
      cprintf("read error: %i\n", c);
  8041604d84:	89 c6                	mov    %eax,%esi
  8041604d86:	48 bf 68 61 60 41 80 	movabs $0x8041606168,%rdi
  8041604d8d:	00 00 00 
  8041604d90:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604d95:	48 ba 4c 40 60 41 80 	movabs $0x804160404c,%rdx
  8041604d9c:	00 00 00 
  8041604d9f:	ff d2                	callq  *%rdx
      return NULL;
  8041604da1:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  8041604da6:	48 83 c4 08          	add    $0x8,%rsp
  8041604daa:	5b                   	pop    %rbx
  8041604dab:	41 5c                	pop    %r12
  8041604dad:	41 5d                	pop    %r13
  8041604daf:	41 5e                	pop    %r14
  8041604db1:	41 5f                	pop    %r15
  8041604db3:	5d                   	pop    %rbp
  8041604db4:	c3                   	retq   
      if (i > 0) {
  8041604db5:	45 85 e4             	test   %r12d,%r12d
  8041604db8:	7e 09                	jle    8041604dc3 <readline+0xa3>
        if (echoing) {
  8041604dba:	45 85 f6             	test   %r14d,%r14d
  8041604dbd:	75 41                	jne    8041604e00 <readline+0xe0>
        i--;
  8041604dbf:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  8041604dc3:	41 ff d5             	callq  *%r13
  8041604dc6:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  8041604dc8:	85 c0                	test   %eax,%eax
  8041604dca:	78 b8                	js     8041604d84 <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  8041604dcc:	83 f8 08             	cmp    $0x8,%eax
  8041604dcf:	74 e4                	je     8041604db5 <readline+0x95>
  8041604dd1:	83 f8 7f             	cmp    $0x7f,%eax
  8041604dd4:	74 df                	je     8041604db5 <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  8041604dd6:	83 f8 1f             	cmp    $0x1f,%eax
  8041604dd9:	7e 46                	jle    8041604e21 <readline+0x101>
  8041604ddb:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  8041604de2:	7f 3d                	jg     8041604e21 <readline+0x101>
      if (echoing)
  8041604de4:	45 85 f6             	test   %r14d,%r14d
  8041604de7:	75 31                	jne    8041604e1a <readline+0xfa>
      buf[i++] = c;
  8041604de9:	49 63 c4             	movslq %r12d,%rax
  8041604dec:	48 b9 60 38 62 41 80 	movabs $0x8041623860,%rcx
  8041604df3:	00 00 00 
  8041604df6:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  8041604df9:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  8041604dfe:	eb c3                	jmp    8041604dc3 <readline+0xa3>
          cputchar('\b');
  8041604e00:	bf 08 00 00 00       	mov    $0x8,%edi
  8041604e05:	41 ff d7             	callq  *%r15
          cputchar(' ');
  8041604e08:	bf 20 00 00 00       	mov    $0x20,%edi
  8041604e0d:	41 ff d7             	callq  *%r15
          cputchar('\b');
  8041604e10:	bf 08 00 00 00       	mov    $0x8,%edi
  8041604e15:	41 ff d7             	callq  *%r15
  8041604e18:	eb a5                	jmp    8041604dbf <readline+0x9f>
        cputchar(c);
  8041604e1a:	89 c7                	mov    %eax,%edi
  8041604e1c:	41 ff d7             	callq  *%r15
  8041604e1f:	eb c8                	jmp    8041604de9 <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  8041604e21:	83 fb 0a             	cmp    $0xa,%ebx
  8041604e24:	74 05                	je     8041604e2b <readline+0x10b>
  8041604e26:	83 fb 0d             	cmp    $0xd,%ebx
  8041604e29:	75 98                	jne    8041604dc3 <readline+0xa3>
      if (echoing)
  8041604e2b:	45 85 f6             	test   %r14d,%r14d
  8041604e2e:	75 17                	jne    8041604e47 <readline+0x127>
      buf[i] = 0;
  8041604e30:	48 b8 60 38 62 41 80 	movabs $0x8041623860,%rax
  8041604e37:	00 00 00 
  8041604e3a:	4d 63 e4             	movslq %r12d,%r12
  8041604e3d:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  8041604e42:	e9 5f ff ff ff       	jmpq   8041604da6 <readline+0x86>
        cputchar('\n');
  8041604e47:	bf 0a 00 00 00       	mov    $0xa,%edi
  8041604e4c:	48 b8 1b 0c 60 41 80 	movabs $0x8041600c1b,%rax
  8041604e53:	00 00 00 
  8041604e56:	ff d0                	callq  *%rax
  8041604e58:	eb d6                	jmp    8041604e30 <readline+0x110>

0000008041604e5a <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  8041604e5a:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604e5d:	74 17                	je     8041604e76 <strlen+0x1c>
  8041604e5f:	48 89 fa             	mov    %rdi,%rdx
  8041604e62:	b9 01 00 00 00       	mov    $0x1,%ecx
  8041604e67:	29 f9                	sub    %edi,%ecx
    n++;
  8041604e69:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  8041604e6c:	48 83 c2 01          	add    $0x1,%rdx
  8041604e70:	80 3a 00             	cmpb   $0x0,(%rdx)
  8041604e73:	75 f4                	jne    8041604e69 <strlen+0xf>
  8041604e75:	c3                   	retq   
  8041604e76:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8041604e7b:	c3                   	retq   

0000008041604e7c <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041604e7c:	48 85 f6             	test   %rsi,%rsi
  8041604e7f:	74 24                	je     8041604ea5 <strnlen+0x29>
  8041604e81:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604e84:	74 25                	je     8041604eab <strnlen+0x2f>
  8041604e86:	48 01 fe             	add    %rdi,%rsi
  8041604e89:	48 89 fa             	mov    %rdi,%rdx
  8041604e8c:	b9 01 00 00 00       	mov    $0x1,%ecx
  8041604e91:	29 f9                	sub    %edi,%ecx
    n++;
  8041604e93:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041604e96:	48 83 c2 01          	add    $0x1,%rdx
  8041604e9a:	48 39 f2             	cmp    %rsi,%rdx
  8041604e9d:	74 11                	je     8041604eb0 <strnlen+0x34>
  8041604e9f:	80 3a 00             	cmpb   $0x0,(%rdx)
  8041604ea2:	75 ef                	jne    8041604e93 <strnlen+0x17>
  8041604ea4:	c3                   	retq   
  8041604ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604eaa:	c3                   	retq   
  8041604eab:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8041604eb0:	c3                   	retq   

0000008041604eb1 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  8041604eb1:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8041604eb4:	ba 00 00 00 00       	mov    $0x0,%edx
  8041604eb9:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  8041604ebd:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  8041604ec0:	48 83 c2 01          	add    $0x1,%rdx
  8041604ec4:	84 c9                	test   %cl,%cl
  8041604ec6:	75 f1                	jne    8041604eb9 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  8041604ec8:	c3                   	retq   

0000008041604ec9 <strcat>:

char *
strcat(char *dst, const char *src) {
  8041604ec9:	55                   	push   %rbp
  8041604eca:	48 89 e5             	mov    %rsp,%rbp
  8041604ecd:	41 54                	push   %r12
  8041604ecf:	53                   	push   %rbx
  8041604ed0:	48 89 fb             	mov    %rdi,%rbx
  8041604ed3:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  8041604ed6:	48 b8 5a 4e 60 41 80 	movabs $0x8041604e5a,%rax
  8041604edd:	00 00 00 
  8041604ee0:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  8041604ee2:	48 63 f8             	movslq %eax,%rdi
  8041604ee5:	48 01 df             	add    %rbx,%rdi
  8041604ee8:	4c 89 e6             	mov    %r12,%rsi
  8041604eeb:	48 b8 b1 4e 60 41 80 	movabs $0x8041604eb1,%rax
  8041604ef2:	00 00 00 
  8041604ef5:	ff d0                	callq  *%rax
  return dst;
}
  8041604ef7:	48 89 d8             	mov    %rbx,%rax
  8041604efa:	5b                   	pop    %rbx
  8041604efb:	41 5c                	pop    %r12
  8041604efd:	5d                   	pop    %rbp
  8041604efe:	c3                   	retq   

0000008041604eff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8041604eff:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8041604f02:	48 85 d2             	test   %rdx,%rdx
  8041604f05:	74 1f                	je     8041604f26 <strncpy+0x27>
  8041604f07:	48 01 fa             	add    %rdi,%rdx
  8041604f0a:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  8041604f0d:	48 83 c1 01          	add    $0x1,%rcx
  8041604f11:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041604f15:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8041604f19:	41 80 f8 01          	cmp    $0x1,%r8b
  8041604f1d:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  8041604f21:	48 39 ca             	cmp    %rcx,%rdx
  8041604f24:	75 e7                	jne    8041604f0d <strncpy+0xe>
  }
  return ret;
}
  8041604f26:	c3                   	retq   

0000008041604f27 <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8041604f27:	48 89 f8             	mov    %rdi,%rax
  8041604f2a:	48 85 d2             	test   %rdx,%rdx
  8041604f2d:	74 36                	je     8041604f65 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  8041604f2f:	48 83 fa 01          	cmp    $0x1,%rdx
  8041604f33:	74 2d                	je     8041604f62 <strlcpy+0x3b>
  8041604f35:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041604f39:	45 84 c0             	test   %r8b,%r8b
  8041604f3c:	74 24                	je     8041604f62 <strlcpy+0x3b>
  8041604f3e:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  8041604f42:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  8041604f47:	48 83 c0 01          	add    $0x1,%rax
  8041604f4b:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  8041604f4f:	48 39 d1             	cmp    %rdx,%rcx
  8041604f52:	74 0e                	je     8041604f62 <strlcpy+0x3b>
  8041604f54:	48 83 c1 01          	add    $0x1,%rcx
  8041604f58:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  8041604f5d:	45 84 c0             	test   %r8b,%r8b
  8041604f60:	75 e5                	jne    8041604f47 <strlcpy+0x20>
    *dst = '\0';
  8041604f62:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  8041604f65:	48 29 f8             	sub    %rdi,%rax
}
  8041604f68:	c3                   	retq   

0000008041604f69 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  8041604f69:	0f b6 07             	movzbl (%rdi),%eax
  8041604f6c:	84 c0                	test   %al,%al
  8041604f6e:	74 17                	je     8041604f87 <strcmp+0x1e>
  8041604f70:	3a 06                	cmp    (%rsi),%al
  8041604f72:	75 13                	jne    8041604f87 <strcmp+0x1e>
    p++, q++;
  8041604f74:	48 83 c7 01          	add    $0x1,%rdi
  8041604f78:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  8041604f7c:	0f b6 07             	movzbl (%rdi),%eax
  8041604f7f:	84 c0                	test   %al,%al
  8041604f81:	74 04                	je     8041604f87 <strcmp+0x1e>
  8041604f83:	3a 06                	cmp    (%rsi),%al
  8041604f85:	74 ed                	je     8041604f74 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8041604f87:	0f b6 c0             	movzbl %al,%eax
  8041604f8a:	0f b6 16             	movzbl (%rsi),%edx
  8041604f8d:	29 d0                	sub    %edx,%eax
}
  8041604f8f:	c3                   	retq   

0000008041604f90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8041604f90:	48 85 d2             	test   %rdx,%rdx
  8041604f93:	74 2f                	je     8041604fc4 <strncmp+0x34>
  8041604f95:	0f b6 07             	movzbl (%rdi),%eax
  8041604f98:	84 c0                	test   %al,%al
  8041604f9a:	74 1f                	je     8041604fbb <strncmp+0x2b>
  8041604f9c:	3a 06                	cmp    (%rsi),%al
  8041604f9e:	75 1b                	jne    8041604fbb <strncmp+0x2b>
  8041604fa0:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8041604fa3:	48 83 c7 01          	add    $0x1,%rdi
  8041604fa7:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8041604fab:	48 39 d7             	cmp    %rdx,%rdi
  8041604fae:	74 1a                	je     8041604fca <strncmp+0x3a>
  8041604fb0:	0f b6 07             	movzbl (%rdi),%eax
  8041604fb3:	84 c0                	test   %al,%al
  8041604fb5:	74 04                	je     8041604fbb <strncmp+0x2b>
  8041604fb7:	3a 06                	cmp    (%rsi),%al
  8041604fb9:	74 e8                	je     8041604fa3 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8041604fbb:	0f b6 07             	movzbl (%rdi),%eax
  8041604fbe:	0f b6 16             	movzbl (%rsi),%edx
  8041604fc1:	29 d0                	sub    %edx,%eax
}
  8041604fc3:	c3                   	retq   
    return 0;
  8041604fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fc9:	c3                   	retq   
  8041604fca:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604fcf:	c3                   	retq   

0000008041604fd0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8041604fd0:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8041604fd2:	0f b6 07             	movzbl (%rdi),%eax
  8041604fd5:	84 c0                	test   %al,%al
  8041604fd7:	74 1e                	je     8041604ff7 <strchr+0x27>
    if (*s == c)
  8041604fd9:	40 38 c6             	cmp    %al,%sil
  8041604fdc:	74 1f                	je     8041604ffd <strchr+0x2d>
  for (; *s; s++)
  8041604fde:	48 83 c7 01          	add    $0x1,%rdi
  8041604fe2:	0f b6 07             	movzbl (%rdi),%eax
  8041604fe5:	84 c0                	test   %al,%al
  8041604fe7:	74 08                	je     8041604ff1 <strchr+0x21>
    if (*s == c)
  8041604fe9:	38 d0                	cmp    %dl,%al
  8041604feb:	75 f1                	jne    8041604fde <strchr+0xe>
  for (; *s; s++)
  8041604fed:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8041604ff0:	c3                   	retq   
  return 0;
  8041604ff1:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ff6:	c3                   	retq   
  8041604ff7:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ffc:	c3                   	retq   
    if (*s == c)
  8041604ffd:	48 89 f8             	mov    %rdi,%rax
  8041605000:	c3                   	retq   

0000008041605001 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  8041605001:	48 89 f8             	mov    %rdi,%rax
  8041605004:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  8041605006:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  8041605009:	40 38 f2             	cmp    %sil,%dl
  804160500c:	74 13                	je     8041605021 <strfind+0x20>
  804160500e:	84 d2                	test   %dl,%dl
  8041605010:	74 0f                	je     8041605021 <strfind+0x20>
  for (; *s; s++)
  8041605012:	48 83 c0 01          	add    $0x1,%rax
  8041605016:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  8041605019:	38 ca                	cmp    %cl,%dl
  804160501b:	74 04                	je     8041605021 <strfind+0x20>
  804160501d:	84 d2                	test   %dl,%dl
  804160501f:	75 f1                	jne    8041605012 <strfind+0x11>
      break;
  return (char *)s;
}
  8041605021:	c3                   	retq   

0000008041605022 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  8041605022:	48 85 d2             	test   %rdx,%rdx
  8041605025:	74 3a                	je     8041605061 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8041605027:	48 89 f8             	mov    %rdi,%rax
  804160502a:	48 09 d0             	or     %rdx,%rax
  804160502d:	a8 03                	test   $0x3,%al
  804160502f:	75 28                	jne    8041605059 <memset+0x37>
    uint32_t k = c & 0xFFU;
  8041605031:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  8041605035:	89 f0                	mov    %esi,%eax
  8041605037:	c1 e0 08             	shl    $0x8,%eax
  804160503a:	89 f1                	mov    %esi,%ecx
  804160503c:	c1 e1 18             	shl    $0x18,%ecx
  804160503f:	41 89 f0             	mov    %esi,%r8d
  8041605042:	41 c1 e0 10          	shl    $0x10,%r8d
  8041605046:	44 09 c1             	or     %r8d,%ecx
  8041605049:	09 ce                	or     %ecx,%esi
  804160504b:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  804160504d:	48 c1 ea 02          	shr    $0x2,%rdx
  8041605051:	48 89 d1             	mov    %rdx,%rcx
  8041605054:	fc                   	cld    
  8041605055:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8041605057:	eb 08                	jmp    8041605061 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  8041605059:	89 f0                	mov    %esi,%eax
  804160505b:	48 89 d1             	mov    %rdx,%rcx
  804160505e:	fc                   	cld    
  804160505f:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  8041605061:	48 89 f8             	mov    %rdi,%rax
  8041605064:	c3                   	retq   

0000008041605065 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  8041605065:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8041605068:	48 39 fe             	cmp    %rdi,%rsi
  804160506b:	73 40                	jae    80416050ad <memmove+0x48>
  804160506d:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  8041605071:	48 39 f9             	cmp    %rdi,%rcx
  8041605074:	76 37                	jbe    80416050ad <memmove+0x48>
    s += n;
    d += n;
  8041605076:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  804160507a:	48 89 fe             	mov    %rdi,%rsi
  804160507d:	48 09 d6             	or     %rdx,%rsi
  8041605080:	48 09 ce             	or     %rcx,%rsi
  8041605083:	40 f6 c6 03          	test   $0x3,%sil
  8041605087:	75 14                	jne    804160509d <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8041605089:	48 83 ef 04          	sub    $0x4,%rdi
  804160508d:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8041605091:	48 c1 ea 02          	shr    $0x2,%rdx
  8041605095:	48 89 d1             	mov    %rdx,%rcx
  8041605098:	fd                   	std    
  8041605099:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  804160509b:	eb 0e                	jmp    80416050ab <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  804160509d:	48 83 ef 01          	sub    $0x1,%rdi
  80416050a1:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  80416050a5:	48 89 d1             	mov    %rdx,%rcx
  80416050a8:	fd                   	std    
  80416050a9:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  80416050ab:	fc                   	cld    
  80416050ac:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  80416050ad:	48 89 c1             	mov    %rax,%rcx
  80416050b0:	48 09 d1             	or     %rdx,%rcx
  80416050b3:	48 09 f1             	or     %rsi,%rcx
  80416050b6:	f6 c1 03             	test   $0x3,%cl
  80416050b9:	75 0e                	jne    80416050c9 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  80416050bb:	48 c1 ea 02          	shr    $0x2,%rdx
  80416050bf:	48 89 d1             	mov    %rdx,%rcx
  80416050c2:	48 89 c7             	mov    %rax,%rdi
  80416050c5:	fc                   	cld    
  80416050c6:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80416050c8:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  80416050c9:	48 89 c7             	mov    %rax,%rdi
  80416050cc:	48 89 d1             	mov    %rdx,%rcx
  80416050cf:	fc                   	cld    
  80416050d0:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  80416050d2:	c3                   	retq   

00000080416050d3 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  80416050d3:	55                   	push   %rbp
  80416050d4:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  80416050d7:	48 b8 65 50 60 41 80 	movabs $0x8041605065,%rax
  80416050de:	00 00 00 
  80416050e1:	ff d0                	callq  *%rax
}
  80416050e3:	5d                   	pop    %rbp
  80416050e4:	c3                   	retq   

00000080416050e5 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  80416050e5:	55                   	push   %rbp
  80416050e6:	48 89 e5             	mov    %rsp,%rbp
  80416050e9:	41 57                	push   %r15
  80416050eb:	41 56                	push   %r14
  80416050ed:	41 55                	push   %r13
  80416050ef:	41 54                	push   %r12
  80416050f1:	53                   	push   %rbx
  80416050f2:	48 83 ec 08          	sub    $0x8,%rsp
  80416050f6:	49 89 fe             	mov    %rdi,%r14
  80416050f9:	49 89 f7             	mov    %rsi,%r15
  80416050fc:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  80416050ff:	48 89 f7             	mov    %rsi,%rdi
  8041605102:	48 b8 5a 4e 60 41 80 	movabs $0x8041604e5a,%rax
  8041605109:	00 00 00 
  804160510c:	ff d0                	callq  *%rax
  804160510e:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  8041605111:	4c 89 ee             	mov    %r13,%rsi
  8041605114:	4c 89 f7             	mov    %r14,%rdi
  8041605117:	48 b8 7c 4e 60 41 80 	movabs $0x8041604e7c,%rax
  804160511e:	00 00 00 
  8041605121:	ff d0                	callq  *%rax
  8041605123:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  8041605126:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  804160512a:	4d 39 e5             	cmp    %r12,%r13
  804160512d:	74 26                	je     8041605155 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  804160512f:	4c 89 e8             	mov    %r13,%rax
  8041605132:	4c 29 e0             	sub    %r12,%rax
  8041605135:	48 39 d8             	cmp    %rbx,%rax
  8041605138:	76 2a                	jbe    8041605164 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  804160513a:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  804160513e:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8041605142:	4c 89 fe             	mov    %r15,%rsi
  8041605145:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  804160514c:	00 00 00 
  804160514f:	ff d0                	callq  *%rax
  return dstlen + srclen;
  8041605151:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  8041605155:	48 83 c4 08          	add    $0x8,%rsp
  8041605159:	5b                   	pop    %rbx
  804160515a:	41 5c                	pop    %r12
  804160515c:	41 5d                	pop    %r13
  804160515e:	41 5e                	pop    %r14
  8041605160:	41 5f                	pop    %r15
  8041605162:	5d                   	pop    %rbp
  8041605163:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  8041605164:	49 83 ed 01          	sub    $0x1,%r13
  8041605168:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  804160516c:	4c 89 ea             	mov    %r13,%rdx
  804160516f:	4c 89 fe             	mov    %r15,%rsi
  8041605172:	48 b8 d3 50 60 41 80 	movabs $0x80416050d3,%rax
  8041605179:	00 00 00 
  804160517c:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  804160517e:	4d 01 ee             	add    %r13,%r14
  8041605181:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  8041605186:	eb c9                	jmp    8041605151 <strlcat+0x6c>

0000008041605188 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  8041605188:	48 85 d2             	test   %rdx,%rdx
  804160518b:	74 3a                	je     80416051c7 <memcmp+0x3f>
    if (*s1 != *s2)
  804160518d:	0f b6 0f             	movzbl (%rdi),%ecx
  8041605190:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041605194:	44 38 c1             	cmp    %r8b,%cl
  8041605197:	75 1d                	jne    80416051b6 <memcmp+0x2e>
  8041605199:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  804160519e:	48 39 d0             	cmp    %rdx,%rax
  80416051a1:	74 1e                	je     80416051c1 <memcmp+0x39>
    if (*s1 != *s2)
  80416051a3:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80416051a7:	48 83 c0 01          	add    $0x1,%rax
  80416051ab:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  80416051b1:	44 38 c1             	cmp    %r8b,%cl
  80416051b4:	74 e8                	je     804160519e <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80416051b6:	0f b6 c1             	movzbl %cl,%eax
  80416051b9:	45 0f b6 c0          	movzbl %r8b,%r8d
  80416051bd:	44 29 c0             	sub    %r8d,%eax
  80416051c0:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  80416051c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416051c6:	c3                   	retq   
  80416051c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416051cc:	c3                   	retq   

00000080416051cd <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80416051cd:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  80416051d1:	48 39 c7             	cmp    %rax,%rdi
  80416051d4:	73 19                	jae    80416051ef <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80416051d6:	89 f2                	mov    %esi,%edx
  80416051d8:	40 38 37             	cmp    %sil,(%rdi)
  80416051db:	74 16                	je     80416051f3 <memfind+0x26>
  for (; s < ends; s++)
  80416051dd:	48 83 c7 01          	add    $0x1,%rdi
  80416051e1:	48 39 f8             	cmp    %rdi,%rax
  80416051e4:	74 08                	je     80416051ee <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  80416051e6:	38 17                	cmp    %dl,(%rdi)
  80416051e8:	75 f3                	jne    80416051dd <memfind+0x10>
  for (; s < ends; s++)
  80416051ea:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  80416051ed:	c3                   	retq   
  80416051ee:	c3                   	retq   
  for (; s < ends; s++)
  80416051ef:	48 89 f8             	mov    %rdi,%rax
  80416051f2:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  80416051f3:	48 89 f8             	mov    %rdi,%rax
  80416051f6:	c3                   	retq   

00000080416051f7 <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  80416051f7:	0f b6 07             	movzbl (%rdi),%eax
  80416051fa:	3c 20                	cmp    $0x20,%al
  80416051fc:	74 04                	je     8041605202 <strtol+0xb>
  80416051fe:	3c 09                	cmp    $0x9,%al
  8041605200:	75 0f                	jne    8041605211 <strtol+0x1a>
    s++;
  8041605202:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  8041605206:	0f b6 07             	movzbl (%rdi),%eax
  8041605209:	3c 20                	cmp    $0x20,%al
  804160520b:	74 f5                	je     8041605202 <strtol+0xb>
  804160520d:	3c 09                	cmp    $0x9,%al
  804160520f:	74 f1                	je     8041605202 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8041605211:	3c 2b                	cmp    $0x2b,%al
  8041605213:	74 2b                	je     8041605240 <strtol+0x49>
  int neg  = 0;
  8041605215:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  804160521b:	3c 2d                	cmp    $0x2d,%al
  804160521d:	74 2d                	je     804160524c <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160521f:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8041605225:	75 0f                	jne    8041605236 <strtol+0x3f>
  8041605227:	80 3f 30             	cmpb   $0x30,(%rdi)
  804160522a:	74 2c                	je     8041605258 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  804160522c:	85 d2                	test   %edx,%edx
  804160522e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041605233:	0f 44 d0             	cmove  %eax,%edx
  8041605236:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  804160523b:	4c 63 d2             	movslq %edx,%r10
  804160523e:	eb 5c                	jmp    804160529c <strtol+0xa5>
    s++;
  8041605240:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8041605244:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160524a:	eb d3                	jmp    804160521f <strtol+0x28>
    s++, neg = 1;
  804160524c:	48 83 c7 01          	add    $0x1,%rdi
  8041605250:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8041605256:	eb c7                	jmp    804160521f <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8041605258:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  804160525c:	74 0f                	je     804160526d <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  804160525e:	85 d2                	test   %edx,%edx
  8041605260:	75 d4                	jne    8041605236 <strtol+0x3f>
    s++, base = 8;
  8041605262:	48 83 c7 01          	add    $0x1,%rdi
  8041605266:	ba 08 00 00 00       	mov    $0x8,%edx
  804160526b:	eb c9                	jmp    8041605236 <strtol+0x3f>
    s += 2, base = 16;
  804160526d:	48 83 c7 02          	add    $0x2,%rdi
  8041605271:	ba 10 00 00 00       	mov    $0x10,%edx
  8041605276:	eb be                	jmp    8041605236 <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  8041605278:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  804160527c:	41 80 f8 19          	cmp    $0x19,%r8b
  8041605280:	77 2f                	ja     80416052b1 <strtol+0xba>
      dig = *s - 'a' + 10;
  8041605282:	44 0f be c1          	movsbl %cl,%r8d
  8041605286:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  804160528a:	39 d1                	cmp    %edx,%ecx
  804160528c:	7d 37                	jge    80416052c5 <strtol+0xce>
    s++, val = (val * base) + dig;
  804160528e:	48 83 c7 01          	add    $0x1,%rdi
  8041605292:	49 0f af c2          	imul   %r10,%rax
  8041605296:	48 63 c9             	movslq %ecx,%rcx
  8041605299:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  804160529c:	0f b6 0f             	movzbl (%rdi),%ecx
  804160529f:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80416052a3:	41 80 f8 09          	cmp    $0x9,%r8b
  80416052a7:	77 cf                	ja     8041605278 <strtol+0x81>
      dig = *s - '0';
  80416052a9:	0f be c9             	movsbl %cl,%ecx
  80416052ac:	83 e9 30             	sub    $0x30,%ecx
  80416052af:	eb d9                	jmp    804160528a <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80416052b1:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80416052b5:	41 80 f8 19          	cmp    $0x19,%r8b
  80416052b9:	77 0a                	ja     80416052c5 <strtol+0xce>
      dig = *s - 'A' + 10;
  80416052bb:	44 0f be c1          	movsbl %cl,%r8d
  80416052bf:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80416052c3:	eb c5                	jmp    804160528a <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80416052c5:	48 85 f6             	test   %rsi,%rsi
  80416052c8:	74 03                	je     80416052cd <strtol+0xd6>
    *endptr = (char *)s;
  80416052ca:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80416052cd:	48 89 c2             	mov    %rax,%rdx
  80416052d0:	48 f7 da             	neg    %rdx
  80416052d3:	45 85 c9             	test   %r9d,%r9d
  80416052d6:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80416052da:	c3                   	retq   
  80416052db:	90                   	nop

00000080416052dc <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  80416052dc:	55                   	push   %rbp
    movq %rsp, %rbp
  80416052dd:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  80416052e0:	53                   	push   %rbx
	push	%r12
  80416052e1:	41 54                	push   %r12
	push	%r13
  80416052e3:	41 55                	push   %r13
	push	%r14
  80416052e5:	41 56                	push   %r14
	push	%r15
  80416052e7:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  80416052e9:	56                   	push   %rsi
	push	%rcx
  80416052ea:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  80416052eb:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  80416052ec:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  80416052ef:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

00000080416052f6 <copyloop>:
  80416052f6:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  80416052fa:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  80416052fe:	49 83 c0 08          	add    $0x8,%r8
  8041605302:	49 39 c8             	cmp    %rcx,%r8
  8041605305:	75 ef                	jne    80416052f6 <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  8041605307:	e8 00 00 00 00       	callq  804160530c <copyloop+0x16>
  804160530c:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  8041605313:	00 
  8041605314:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  804160531b:	00 
  804160531c:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  804160531d:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  804160531f:	6a 08                	pushq  $0x8
  8041605321:	e8 00 00 00 00       	callq  8041605326 <copyloop+0x30>
  8041605326:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  804160532d:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  804160532e:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  8041605332:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  8041605336:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  804160533a:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  804160533d:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  804160533e:	59                   	pop    %rcx
	pop	%rsi
  804160533f:	5e                   	pop    %rsi
	pop	%r15
  8041605340:	41 5f                	pop    %r15
	pop	%r14
  8041605342:	41 5e                	pop    %r14
	pop	%r13
  8041605344:	41 5d                	pop    %r13
	pop	%r12
  8041605346:	41 5c                	pop    %r12
	pop	%rbx
  8041605348:	5b                   	pop    %rbx

	leave
  8041605349:	c9                   	leaveq 
	ret
  804160534a:	c3                   	retq   
  804160534b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
