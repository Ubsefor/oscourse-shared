
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
  8041600011:	e8 61 02 00 00       	callq  8041600277 <i386_init>

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
  804160008c:	e8 78 3d 00 00       	callq  8041603e09 <csys_yield>
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
  //Assume pde1, pde2 is already used.
  extern uintptr_t pdefreestart, pdefreeend;
  pde_t *ret;
  static uintptr_t pdefree = (uintptr_t)&pdefreestart;

  if (pdefree >= (uintptr_t)&pdefreeend)
  8041600095:	48 b8 08 70 61 41 80 	movabs $0x8041617008,%rax
  804160009c:	00 00 00 
  804160009f:	48 8b 10             	mov    (%rax),%rdx
  80416000a2:	48 b8 00 c0 50 01 00 	movabs $0x150c000,%rax
  80416000a9:	00 00 00 
  80416000ac:	48 39 c2             	cmp    %rax,%rdx
  80416000af:	73 1b                	jae    80416000cc <alloc_pde_early_boot+0x37>
    return NULL;

  ret = (pde_t *)pdefree;
  80416000b1:	48 89 d1             	mov    %rdx,%rcx
  pdefree += PGSIZE;
  80416000b4:	48 81 c2 00 10 00 00 	add    $0x1000,%rdx
  80416000bb:	48 89 d0             	mov    %rdx,%rax
  80416000be:	48 a3 08 70 61 41 80 	movabs %rax,0x8041617008
  80416000c5:	00 00 00 
  return ret;
}
  80416000c8:	48 89 c8             	mov    %rcx,%rax
  80416000cb:	c3                   	retq   
    return NULL;
  80416000cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416000d1:	eb f5                	jmp    80416000c8 <alloc_pde_early_boot+0x33>

00000080416000d3 <map_addr_early_boot>:

void
map_addr_early_boot(uintptr_t addr, uintptr_t addr_phys, size_t sz) {
  80416000d3:	55                   	push   %rbp
  80416000d4:	48 89 e5             	mov    %rsp,%rbp
  80416000d7:	41 57                	push   %r15
  80416000d9:	41 56                	push   %r14
  80416000db:	41 55                	push   %r13
  80416000dd:	41 54                	push   %r12
  80416000df:	53                   	push   %rbx
  80416000e0:	48 83 ec 18          	sub    $0x18,%rsp
  pml4e_t *pml4 = &pml4phys;
  pdpe_t *pdpt;
  pde_t *pde;

  uintptr_t addr_curr, addr_curr_phys, addr_end;
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  80416000e4:	49 89 ff             	mov    %rdi,%r15
  80416000e7:	49 81 e7 00 00 e0 ff 	and    $0xffffffffffe00000,%r15
  addr_curr_phys = ROUNDDOWN(addr_phys, PTSIZE);
  80416000ee:	48 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%rsi
  80416000f5:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  addr_end       = ROUNDUP(addr + sz, PTSIZE);
  80416000f9:	4c 8d b4 17 ff ff 1f 	lea    0x1fffff(%rdi,%rdx,1),%r14
  8041600100:	00 
  8041600101:	49 81 e6 00 00 e0 ff 	and    $0xffffffffffe00000,%r14

  pdpt = (pdpe_t *)PTE_ADDR(pml4[PML4(addr_curr)]);
  8041600108:	48 c1 ef 24          	shr    $0x24,%rdi
  804160010c:	81 e7 f8 0f 00 00    	and    $0xff8,%edi
  8041600112:	48 b8 00 10 50 01 00 	movabs $0x1501000,%rax
  8041600119:	00 00 00 
  804160011c:	48 8b 04 38          	mov    (%rax,%rdi,1),%rax
  8041600120:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041600126:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  804160012a:	4d 39 fe             	cmp    %r15,%r14
  804160012d:	76 67                	jbe    8041600196 <map_addr_early_boot+0xc3>
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  804160012f:	4d 89 fc             	mov    %r15,%r12
  8041600132:	eb 3a                	jmp    804160016e <map_addr_early_boot+0x9b>
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
    if (!pde) {
      pde                   = alloc_pde_early_boot();
  8041600134:	48 b8 95 00 60 41 80 	movabs $0x8041600095,%rax
  804160013b:	00 00 00 
  804160013e:	ff d0                	callq  *%rax
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
  8041600140:	48 89 c2             	mov    %rax,%rdx
  8041600143:	48 83 ca 03          	or     $0x3,%rdx
  8041600147:	48 89 13             	mov    %rdx,(%rbx)
    }
    pde[PDX(addr_curr)] = addr_curr_phys | PTE_P | PTE_W | PTE_MBZ;
  804160014a:	4c 89 e2             	mov    %r12,%rdx
  804160014d:	48 c1 ea 15          	shr    $0x15,%rdx
  8041600151:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  8041600157:	49 81 cd 83 01 00 00 	or     $0x183,%r13
  804160015e:	4c 89 2c d0          	mov    %r13,(%rax,%rdx,8)
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
  8041600162:	49 81 c4 00 00 20 00 	add    $0x200000,%r12
  8041600169:	4d 39 e6             	cmp    %r12,%r14
  804160016c:	76 28                	jbe    8041600196 <map_addr_early_boot+0xc3>
  804160016e:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
  8041600172:	4d 29 fd             	sub    %r15,%r13
  8041600175:	4d 01 e5             	add    %r12,%r13
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
  8041600178:	4c 89 e3             	mov    %r12,%rbx
  804160017b:	48 c1 eb 1b          	shr    $0x1b,%rbx
  804160017f:	81 e3 f8 0f 00 00    	and    $0xff8,%ebx
  8041600185:	48 03 5d c0          	add    -0x40(%rbp),%rbx
    if (!pde) {
  8041600189:	48 8b 03             	mov    (%rbx),%rax
  804160018c:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8041600192:	75 b6                	jne    804160014a <map_addr_early_boot+0x77>
  8041600194:	eb 9e                	jmp    8041600134 <map_addr_early_boot+0x61>
  }
}
  8041600196:	48 83 c4 18          	add    $0x18,%rsp
  804160019a:	5b                   	pop    %rbx
  804160019b:	41 5c                	pop    %r12
  804160019d:	41 5d                	pop    %r13
  804160019f:	41 5e                	pop    %r14
  80416001a1:	41 5f                	pop    %r15
  80416001a3:	5d                   	pop    %rbp
  80416001a4:	c3                   	retq   

00000080416001a5 <early_boot_pml4_init>:
// Additionally maps pml4 memory so that we dont get memory errors on accessing
// uefi_lp, MemMap, KASAN functions.
void
early_boot_pml4_init(void) {
  80416001a5:	55                   	push   %rbp
  80416001a6:	48 89 e5             	mov    %rsp,%rbp
  80416001a9:	41 54                	push   %r12
  80416001ab:	53                   	push   %rbx

  map_addr_early_boot((uintptr_t)uefi_lp, (uintptr_t)uefi_lp, sizeof(LOADER_PARAMS));
  80416001ac:	49 bc 00 70 61 41 80 	movabs $0x8041617000,%r12
  80416001b3:	00 00 00 
  80416001b6:	49 8b 3c 24          	mov    (%r12),%rdi
  80416001ba:	ba c8 00 00 00       	mov    $0xc8,%edx
  80416001bf:	48 89 fe             	mov    %rdi,%rsi
  80416001c2:	48 bb d3 00 60 41 80 	movabs $0x80416000d3,%rbx
  80416001c9:	00 00 00 
  80416001cc:	ff d3                	callq  *%rbx
  map_addr_early_boot((uintptr_t)uefi_lp->MemoryMap, (uintptr_t)uefi_lp->MemoryMap, uefi_lp->MemoryMapSize);
  80416001ce:	49 8b 04 24          	mov    (%r12),%rax
  80416001d2:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80416001d6:	48 8b 50 38          	mov    0x38(%rax),%rdx
  80416001da:	48 89 fe             	mov    %rdi,%rsi
  80416001dd:	ff d3                	callq  *%rbx

#ifdef SANITIZE_SHADOW_BASE
  map_addr_early_boot(SANITIZE_SHADOW_BASE, SANITIZE_SHADOW_BASE - KERNBASE, SANITIZE_SHADOW_SIZE);
#endif

  map_addr_early_boot(FBUFFBASE, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
  80416001df:	49 8b 04 24          	mov    (%r12),%rax
  80416001e3:	8b 50 48             	mov    0x48(%rax),%edx
  80416001e6:	48 8b 70 40          	mov    0x40(%rax),%rsi
  80416001ea:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416001f1:	00 00 00 
  80416001f4:	ff d3                	callq  *%rbx
}
  80416001f6:	5b                   	pop    %rbx
  80416001f7:	41 5c                	pop    %r12
  80416001f9:	5d                   	pop    %rbp
  80416001fa:	c3                   	retq   

00000080416001fb <test_backtrace>:

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x) {
  80416001fb:	55                   	push   %rbp
  80416001fc:	48 89 e5             	mov    %rsp,%rbp
  80416001ff:	53                   	push   %rbx
  8041600200:	48 83 ec 08          	sub    $0x8,%rsp
  8041600204:	89 fb                	mov    %edi,%ebx
  cprintf("entering test_backtrace %d\n", x);
  8041600206:	89 fe                	mov    %edi,%esi
  8041600208:	48 bf 80 52 60 41 80 	movabs $0x8041605280,%rdi
  804160020f:	00 00 00 
  8041600212:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600217:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  804160021e:	00 00 00 
  8041600221:	ff d2                	callq  *%rdx
  if (x > 0)
  8041600223:	85 db                	test   %ebx,%ebx
  8041600225:	7e 33                	jle    804160025a <test_backtrace+0x5f>
    test_backtrace(x - 1);
  8041600227:	8d 7b ff             	lea    -0x1(%rbx),%edi
  804160022a:	48 b8 fb 01 60 41 80 	movabs $0x80416001fb,%rax
  8041600231:	00 00 00 
  8041600234:	ff d0                	callq  *%rax
  else
    mon_backtrace(0, 0, 0);
  cprintf("leaving test_backtrace %d\n", x);
  8041600236:	89 de                	mov    %ebx,%esi
  8041600238:	48 bf 9c 52 60 41 80 	movabs $0x804160529c,%rdi
  804160023f:	00 00 00 
  8041600242:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600247:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  804160024e:	00 00 00 
  8041600251:	ff d2                	callq  *%rdx
}
  8041600253:	48 83 c4 08          	add    $0x8,%rsp
  8041600257:	5b                   	pop    %rbx
  8041600258:	5d                   	pop    %rbp
  8041600259:	c3                   	retq   
    mon_backtrace(0, 0, 0);
  804160025a:	ba 00 00 00 00       	mov    $0x0,%edx
  804160025f:	be 00 00 00 00       	mov    $0x0,%esi
  8041600264:	bf 00 00 00 00       	mov    $0x0,%edi
  8041600269:	48 b8 e8 38 60 41 80 	movabs $0x80416038e8,%rax
  8041600270:	00 00 00 
  8041600273:	ff d0                	callq  *%rax
  8041600275:	eb bf                	jmp    8041600236 <test_backtrace+0x3b>

0000008041600277 <i386_init>:

void
i386_init(void) {
  8041600277:	55                   	push   %rbp
  8041600278:	48 89 e5             	mov    %rsp,%rbp
  804160027b:	41 54                	push   %r12
  804160027d:	53                   	push   %rbx
  extern char end[];

  early_boot_pml4_init();
  804160027e:	48 b8 a5 01 60 41 80 	movabs $0x80416001a5,%rax
  8041600285:	00 00 00 
  8041600288:	ff d0                	callq  *%rax

  // Initialize the console.
  // Can't call cprintf until after we do this!
  cons_init();
  804160028a:	48 b8 7d 0b 60 41 80 	movabs $0x8041600b7d,%rax
  8041600291:	00 00 00 
  8041600294:	ff d0                	callq  *%rax

  cprintf("6828 decimal is %o octal!\n", 6828);
  8041600296:	be ac 1a 00 00       	mov    $0x1aac,%esi
  804160029b:	48 bf b7 52 60 41 80 	movabs $0x80416052b7,%rdi
  80416002a2:	00 00 00 
  80416002a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002aa:	48 bb 70 3f 60 41 80 	movabs $0x8041603f70,%rbx
  80416002b1:	00 00 00 
  80416002b4:	ff d3                	callq  *%rbx
  cprintf("END: %p\n", end);
  80416002b6:	48 be 00 60 62 41 80 	movabs $0x8041626000,%rsi
  80416002bd:	00 00 00 
  80416002c0:	48 bf d2 52 60 41 80 	movabs $0x80416052d2,%rdi
  80416002c7:	00 00 00 
  80416002ca:	b8 00 00 00 00       	mov    $0x0,%eax
  80416002cf:	ff d3                	callq  *%rbx
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  80416002d1:	48 ba d0 35 62 41 80 	movabs $0x80416235d0,%rdx
  80416002d8:	00 00 00 
  80416002db:	48 b8 d0 35 62 41 80 	movabs $0x80416235d0,%rax
  80416002e2:	00 00 00 
  80416002e5:	48 39 c2             	cmp    %rax,%rdx
  80416002e8:	73 23                	jae    804160030d <i386_init+0x96>
  80416002ea:	48 89 d3             	mov    %rdx,%rbx
  80416002ed:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  80416002f1:	48 29 d0             	sub    %rdx,%rax
  80416002f4:	48 c1 e8 03          	shr    $0x3,%rax
  80416002f8:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80416002fd:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600302:	ff 13                	callq  *(%rbx)
    ctor++;
  8041600304:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  8041600308:	4c 39 e3             	cmp    %r12,%rbx
  804160030b:	75 f0                	jne    80416002fd <i386_init+0x86>
  }

  // Framebuffer init should be done after memory init.
  fb_init();
  804160030d:	48 b8 70 0a 60 41 80 	movabs $0x8041600a70,%rax
  8041600314:	00 00 00 
  8041600317:	ff d0                	callq  *%rax
  cprintf("Framebuffer initialised\n");
  8041600319:	48 bf db 52 60 41 80 	movabs $0x80416052db,%rdi
  8041600320:	00 00 00 
  8041600323:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600328:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  804160032f:	00 00 00 
  8041600332:	ff d2                	callq  *%rdx

  // user environment initialization functions
  env_init();
  8041600334:	48 b8 39 3c 60 41 80 	movabs $0x8041603c39,%rax
  804160033b:	00 00 00 
  804160033e:	ff d0                	callq  *%rax

#ifdef CONFIG_KSPACE
  // Touch all you want.
  ENV_CREATE_KERNEL_TYPE(prog_test1);
  8041600340:	be 01 00 00 00       	mov    $0x1,%esi
  8041600345:	48 bf 90 77 61 41 80 	movabs $0x8041617790,%rdi
  804160034c:	00 00 00 
  804160034f:	48 bb 97 3d 60 41 80 	movabs $0x8041603d97,%rbx
  8041600356:	00 00 00 
  8041600359:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test2);
  804160035b:	be 01 00 00 00       	mov    $0x1,%esi
  8041600360:	48 bf aa b6 61 41 80 	movabs $0x804161b6aa,%rdi
  8041600367:	00 00 00 
  804160036a:	ff d3                	callq  *%rbx
  ENV_CREATE_KERNEL_TYPE(prog_test3);
  804160036c:	be 01 00 00 00       	mov    $0x1,%esi
  8041600371:	48 bf b4 f6 61 41 80 	movabs $0x804161f6b4,%rdi
  8041600378:	00 00 00 
  804160037b:	ff d3                	callq  *%rbx
#endif

  // Schedule and run the first user environment!
  sched_yield();
  804160037d:	48 b8 04 40 60 41 80 	movabs $0x8041604004,%rax
  8041600384:	00 00 00 
  8041600387:	ff d0                	callq  *%rax

0000008041600389 <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  8041600389:	55                   	push   %rbp
  804160038a:	48 89 e5             	mov    %rsp,%rbp
  804160038d:	41 54                	push   %r12
  804160038f:	53                   	push   %rbx
  8041600390:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041600397:	49 89 d4             	mov    %rdx,%r12
  804160039a:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  80416003a1:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80416003a8:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416003af:	84 c0                	test   %al,%al
  80416003b1:	74 23                	je     80416003d6 <_panic+0x4d>
  80416003b3:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416003ba:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416003be:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416003c2:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416003c6:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416003ca:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416003ce:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416003d2:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  if (panicstr)
  80416003d6:	48 b8 e0 35 62 41 80 	movabs $0x80416235e0,%rax
  80416003dd:	00 00 00 
  80416003e0:	48 83 38 00          	cmpq   $0x0,(%rax)
  80416003e4:	74 13                	je     80416003f9 <_panic+0x70>
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
  80416003e6:	48 bb e9 39 60 41 80 	movabs $0x80416039e9,%rbx
  80416003ed:	00 00 00 
  80416003f0:	bf 00 00 00 00       	mov    $0x0,%edi
  80416003f5:	ff d3                	callq  *%rbx
  while (1)
  80416003f7:	eb f7                	jmp    80416003f0 <_panic+0x67>
  panicstr = fmt;
  80416003f9:	4c 89 e0             	mov    %r12,%rax
  80416003fc:	48 a3 e0 35 62 41 80 	movabs %rax,0x80416235e0
  8041600403:	00 00 00 
  __asm __volatile("cli; cld");
  8041600406:	fa                   	cli    
  8041600407:	fc                   	cld    
  va_start(ap, fmt);
  8041600408:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  804160040f:	00 00 00 
  8041600412:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  8041600419:	00 00 00 
  804160041c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041600420:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  8041600427:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  804160042e:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel panic at %s:%d: ", file, line);
  8041600435:	89 f2                	mov    %esi,%edx
  8041600437:	48 89 fe             	mov    %rdi,%rsi
  804160043a:	48 bf f4 52 60 41 80 	movabs $0x80416052f4,%rdi
  8041600441:	00 00 00 
  8041600444:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600449:	48 bb 70 3f 60 41 80 	movabs $0x8041603f70,%rbx
  8041600450:	00 00 00 
  8041600453:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  8041600455:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  804160045c:	4c 89 e7             	mov    %r12,%rdi
  804160045f:	48 b8 3c 3f 60 41 80 	movabs $0x8041603f3c,%rax
  8041600466:	00 00 00 
  8041600469:	ff d0                	callq  *%rax
  cprintf("\n");
  804160046b:	48 bf c9 58 60 41 80 	movabs $0x80416058c9,%rdi
  8041600472:	00 00 00 
  8041600475:	b8 00 00 00 00       	mov    $0x0,%eax
  804160047a:	ff d3                	callq  *%rbx
  va_end(ap);
  804160047c:	e9 65 ff ff ff       	jmpq   80416003e6 <_panic+0x5d>

0000008041600481 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  8041600481:	55                   	push   %rbp
  8041600482:	48 89 e5             	mov    %rsp,%rbp
  8041600485:	41 54                	push   %r12
  8041600487:	53                   	push   %rbx
  8041600488:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  804160048f:	49 89 d4             	mov    %rdx,%r12
  8041600492:	48 89 8d 58 ff ff ff 	mov    %rcx,-0xa8(%rbp)
  8041600499:	4c 89 85 60 ff ff ff 	mov    %r8,-0xa0(%rbp)
  80416004a0:	4c 89 8d 68 ff ff ff 	mov    %r9,-0x98(%rbp)
  80416004a7:	84 c0                	test   %al,%al
  80416004a9:	74 23                	je     80416004ce <_warn+0x4d>
  80416004ab:	0f 29 85 70 ff ff ff 	movaps %xmm0,-0x90(%rbp)
  80416004b2:	0f 29 4d 80          	movaps %xmm1,-0x80(%rbp)
  80416004b6:	0f 29 55 90          	movaps %xmm2,-0x70(%rbp)
  80416004ba:	0f 29 5d a0          	movaps %xmm3,-0x60(%rbp)
  80416004be:	0f 29 65 b0          	movaps %xmm4,-0x50(%rbp)
  80416004c2:	0f 29 6d c0          	movaps %xmm5,-0x40(%rbp)
  80416004c6:	0f 29 75 d0          	movaps %xmm6,-0x30(%rbp)
  80416004ca:	0f 29 7d e0          	movaps %xmm7,-0x20(%rbp)
  va_list ap;

  va_start(ap, fmt);
  80416004ce:	c7 85 28 ff ff ff 18 	movl   $0x18,-0xd8(%rbp)
  80416004d5:	00 00 00 
  80416004d8:	c7 85 2c ff ff ff 30 	movl   $0x30,-0xd4(%rbp)
  80416004df:	00 00 00 
  80416004e2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80416004e6:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  80416004ed:	48 8d 85 40 ff ff ff 	lea    -0xc0(%rbp),%rax
  80416004f4:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  cprintf("kernel warning at %s:%d: ", file, line);
  80416004fb:	89 f2                	mov    %esi,%edx
  80416004fd:	48 89 fe             	mov    %rdi,%rsi
  8041600500:	48 bf 0c 53 60 41 80 	movabs $0x804160530c,%rdi
  8041600507:	00 00 00 
  804160050a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160050f:	48 bb 70 3f 60 41 80 	movabs $0x8041603f70,%rbx
  8041600516:	00 00 00 
  8041600519:	ff d3                	callq  *%rbx
  vcprintf(fmt, ap);
  804160051b:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8041600522:	4c 89 e7             	mov    %r12,%rdi
  8041600525:	48 b8 3c 3f 60 41 80 	movabs $0x8041603f3c,%rax
  804160052c:	00 00 00 
  804160052f:	ff d0                	callq  *%rax
  cprintf("\n");
  8041600531:	48 bf c9 58 60 41 80 	movabs $0x80416058c9,%rdi
  8041600538:	00 00 00 
  804160053b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600540:	ff d3                	callq  *%rbx
  va_end(ap);
}
  8041600542:	48 81 c4 d0 00 00 00 	add    $0xd0,%rsp
  8041600549:	5b                   	pop    %rbx
  804160054a:	41 5c                	pop    %r12
  804160054c:	5d                   	pop    %rbp
  804160054d:	c3                   	retq   

000000804160054e <serial_proc_data>:
}

static __inline uint8_t
inb(int port) {
  uint8_t data;
  __asm __volatile("inb %w1,%0"
  804160054e:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600553:	ec                   	in     (%dx),%al
  }
}

static int
serial_proc_data(void) {
  if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
  8041600554:	a8 01                	test   $0x1,%al
  8041600556:	74 0a                	je     8041600562 <serial_proc_data+0x14>
  8041600558:	ba f8 03 00 00       	mov    $0x3f8,%edx
  804160055d:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1 + COM_RX);
  804160055e:	0f b6 c0             	movzbl %al,%eax
  8041600561:	c3                   	retq   
    return -1;
  8041600562:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  8041600567:	c3                   	retq   

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
  8041600572:	48 bb 20 36 62 41 80 	movabs $0x8041623620,%rbx
  8041600579:	00 00 00 
  while ((c = (*proc)()) != -1) {
  804160057c:	41 ff d4             	callq  *%r12
  804160057f:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041600582:	74 28                	je     80416005ac <cons_intr+0x44>
    if (c == 0)
  8041600584:	85 c0                	test   %eax,%eax
  8041600586:	74 f4                	je     804160057c <cons_intr+0x14>
    cons.buf[cons.wpos++] = c;
  8041600588:	8b 8b 04 02 00 00    	mov    0x204(%rbx),%ecx
  804160058e:	8d 51 01             	lea    0x1(%rcx),%edx
  8041600591:	89 c9                	mov    %ecx,%ecx
  8041600593:	88 04 0b             	mov    %al,(%rbx,%rcx,1)
    if (cons.wpos == CONSBUFSIZE)
  8041600596:	81 fa 00 02 00 00    	cmp    $0x200,%edx
      cons.wpos = 0;
  804160059c:	b8 00 00 00 00       	mov    $0x0,%eax
  80416005a1:	0f 44 d0             	cmove  %eax,%edx
  80416005a4:	89 93 04 02 00 00    	mov    %edx,0x204(%rbx)
  80416005aa:	eb d0                	jmp    804160057c <cons_intr+0x14>
  }
}
  80416005ac:	5b                   	pop    %rbx
  80416005ad:	41 5c                	pop    %r12
  80416005af:	5d                   	pop    %rbp
  80416005b0:	c3                   	retq   

00000080416005b1 <kbd_proc_data>:
kbd_proc_data(void) {
  80416005b1:	55                   	push   %rbp
  80416005b2:	48 89 e5             	mov    %rsp,%rbp
  80416005b5:	53                   	push   %rbx
  80416005b6:	48 83 ec 08          	sub    $0x8,%rsp
  80416005ba:	ba 64 00 00 00       	mov    $0x64,%edx
  80416005bf:	ec                   	in     (%dx),%al
  if ((inb(KBSTATP) & KBS_DIB) == 0)
  80416005c0:	a8 01                	test   $0x1,%al
  80416005c2:	0f 84 31 01 00 00    	je     80416006f9 <kbd_proc_data+0x148>
  80416005c8:	ba 60 00 00 00       	mov    $0x60,%edx
  80416005cd:	ec                   	in     (%dx),%al
  80416005ce:	89 c2                	mov    %eax,%edx
  if (data == 0xE0) {
  80416005d0:	3c e0                	cmp    $0xe0,%al
  80416005d2:	0f 84 84 00 00 00    	je     804160065c <kbd_proc_data+0xab>
  } else if (data & 0x80) {
  80416005d8:	84 c0                	test   %al,%al
  80416005da:	0f 88 97 00 00 00    	js     8041600677 <kbd_proc_data+0xc6>
  } else if (shift & E0ESC) {
  80416005e0:	48 bf 00 36 62 41 80 	movabs $0x8041623600,%rdi
  80416005e7:	00 00 00 
  80416005ea:	8b 0f                	mov    (%rdi),%ecx
  80416005ec:	f6 c1 40             	test   $0x40,%cl
  80416005ef:	74 0c                	je     80416005fd <kbd_proc_data+0x4c>
    data |= 0x80;
  80416005f1:	83 c8 80             	or     $0xffffff80,%eax
  80416005f4:	89 c2                	mov    %eax,%edx
    shift &= ~E0ESC;
  80416005f6:	89 c8                	mov    %ecx,%eax
  80416005f8:	83 e0 bf             	and    $0xffffffbf,%eax
  80416005fb:	89 07                	mov    %eax,(%rdi)
  shift |= shiftcode[data];
  80416005fd:	0f b6 f2             	movzbl %dl,%esi
  8041600600:	48 b8 80 54 60 41 80 	movabs $0x8041605480,%rax
  8041600607:	00 00 00 
  804160060a:	0f b6 04 30          	movzbl (%rax,%rsi,1),%eax
  804160060e:	48 b9 00 36 62 41 80 	movabs $0x8041623600,%rcx
  8041600615:	00 00 00 
  8041600618:	0b 01                	or     (%rcx),%eax
  shift ^= togglecode[data];
  804160061a:	48 bf 80 53 60 41 80 	movabs $0x8041605380,%rdi
  8041600621:	00 00 00 
  8041600624:	0f b6 34 37          	movzbl (%rdi,%rsi,1),%esi
  8041600628:	31 f0                	xor    %esi,%eax
  804160062a:	89 01                	mov    %eax,(%rcx)
  c = charcode[shift & (CTL | SHIFT)][data];
  804160062c:	89 c6                	mov    %eax,%esi
  804160062e:	83 e6 03             	and    $0x3,%esi
  8041600631:	0f b6 d2             	movzbl %dl,%edx
  8041600634:	48 b9 60 53 60 41 80 	movabs $0x8041605360,%rcx
  804160063b:	00 00 00 
  804160063e:	48 8b 0c f1          	mov    (%rcx,%rsi,8),%rcx
  8041600642:	0f b6 14 11          	movzbl (%rcx,%rdx,1),%edx
  8041600646:	0f b6 da             	movzbl %dl,%ebx
  if (shift & CAPSLOCK) {
  8041600649:	a8 08                	test   $0x8,%al
  804160064b:	74 73                	je     80416006c0 <kbd_proc_data+0x10f>
    if ('a' <= c && c <= 'z')
  804160064d:	89 da                	mov    %ebx,%edx
  804160064f:	8d 4b 9f             	lea    -0x61(%rbx),%ecx
  8041600652:	83 f9 19             	cmp    $0x19,%ecx
  8041600655:	77 5d                	ja     80416006b4 <kbd_proc_data+0x103>
      c += 'A' - 'a';
  8041600657:	83 eb 20             	sub    $0x20,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  804160065a:	eb 12                	jmp    804160066e <kbd_proc_data+0xbd>
    shift |= E0ESC;
  804160065c:	48 b8 00 36 62 41 80 	movabs $0x8041623600,%rax
  8041600663:	00 00 00 
  8041600666:	83 08 40             	orl    $0x40,(%rax)
    return 0;
  8041600669:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  804160066e:	89 d8                	mov    %ebx,%eax
  8041600670:	48 83 c4 08          	add    $0x8,%rsp
  8041600674:	5b                   	pop    %rbx
  8041600675:	5d                   	pop    %rbp
  8041600676:	c3                   	retq   
    data = (shift & E0ESC ? data : data & 0x7F);
  8041600677:	48 bf 00 36 62 41 80 	movabs $0x8041623600,%rdi
  804160067e:	00 00 00 
  8041600681:	8b 0f                	mov    (%rdi),%ecx
  8041600683:	89 ce                	mov    %ecx,%esi
  8041600685:	83 e6 40             	and    $0x40,%esi
  8041600688:	83 e0 7f             	and    $0x7f,%eax
  804160068b:	85 f6                	test   %esi,%esi
  804160068d:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
  8041600690:	0f b6 d2             	movzbl %dl,%edx
  8041600693:	48 b8 80 54 60 41 80 	movabs $0x8041605480,%rax
  804160069a:	00 00 00 
  804160069d:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
  80416006a1:	83 c8 40             	or     $0x40,%eax
  80416006a4:	0f b6 c0             	movzbl %al,%eax
  80416006a7:	f7 d0                	not    %eax
  80416006a9:	21 c8                	and    %ecx,%eax
  80416006ab:	89 07                	mov    %eax,(%rdi)
    return 0;
  80416006ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416006b2:	eb ba                	jmp    804160066e <kbd_proc_data+0xbd>
    else if ('A' <= c && c <= 'Z')
  80416006b4:	83 ea 41             	sub    $0x41,%edx
      c += 'a' - 'A';
  80416006b7:	8d 4b 20             	lea    0x20(%rbx),%ecx
  80416006ba:	83 fa 1a             	cmp    $0x1a,%edx
  80416006bd:	0f 42 d9             	cmovb  %ecx,%ebx
  if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  80416006c0:	f7 d0                	not    %eax
  80416006c2:	a8 06                	test   $0x6,%al
  80416006c4:	75 a8                	jne    804160066e <kbd_proc_data+0xbd>
  80416006c6:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
  80416006cc:	75 a0                	jne    804160066e <kbd_proc_data+0xbd>
    cprintf("Rebooting!\n");
  80416006ce:	48 bf 26 53 60 41 80 	movabs $0x8041605326,%rdi
  80416006d5:	00 00 00 
  80416006d8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416006dd:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  80416006e4:	00 00 00 
  80416006e7:	ff d2                	callq  *%rdx
                   : "memory", "cc");
}

static __inline void
outb(int port, uint8_t data) {
  __asm __volatile("outb %0,%w1"
  80416006e9:	b8 03 00 00 00       	mov    $0x3,%eax
  80416006ee:	ba 92 00 00 00       	mov    $0x92,%edx
  80416006f3:	ee                   	out    %al,(%dx)
  80416006f4:	e9 75 ff ff ff       	jmpq   804160066e <kbd_proc_data+0xbd>
    return -1;
  80416006f9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  80416006fe:	e9 6b ff ff ff       	jmpq   804160066e <kbd_proc_data+0xbd>

0000008041600703 <draw_char>:
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  8041600703:	48 b8 34 38 62 41 80 	movabs $0x8041623834,%rax
  804160070a:	00 00 00 
  804160070d:	44 8b 10             	mov    (%rax),%r10d
  8041600710:	41 0f af d2          	imul   %r10d,%edx
  8041600714:	01 f2                	add    %esi,%edx
  8041600716:	44 8d 0c d5 00 00 00 	lea    0x0(,%rdx,8),%r9d
  804160071d:	00 
  char *p = &(font8x8_basic[pos][0]); // Size of a font's character
  804160071e:	4d 0f be c0          	movsbq %r8b,%r8
  8041600722:	48 b8 20 73 61 41 80 	movabs $0x8041617320,%rax
  8041600729:	00 00 00 
  804160072c:	4a 8d 34 c0          	lea    (%rax,%r8,8),%rsi
  8041600730:	4c 8d 46 08          	lea    0x8(%rsi),%r8
  8041600734:	eb 25                	jmp    804160075b <draw_char+0x58>
    for (int w = 0; w < 8; w++) {
  8041600736:	83 c0 01             	add    $0x1,%eax
  8041600739:	83 f8 08             	cmp    $0x8,%eax
  804160073c:	74 11                	je     804160074f <draw_char+0x4c>
      if ((p[h] >> (w)) & 1) {
  804160073e:	0f be 16             	movsbl (%rsi),%edx
  8041600741:	0f a3 c2             	bt     %eax,%edx
  8041600744:	73 f0                	jae    8041600736 <draw_char+0x33>
        buffer[uefi_hres * SYMBOL_SIZE * y + uefi_hres * h + SYMBOL_SIZE * x + w] = color;
  8041600746:	42 8d 14 08          	lea    (%rax,%r9,1),%edx
  804160074a:	89 0c 97             	mov    %ecx,(%rdi,%rdx,4)
  804160074d:	eb e7                	jmp    8041600736 <draw_char+0x33>
  for (int h = 0; h < 8; h++) {
  804160074f:	45 01 d1             	add    %r10d,%r9d
  8041600752:	48 83 c6 01          	add    $0x1,%rsi
  8041600756:	4c 39 c6             	cmp    %r8,%rsi
  8041600759:	74 07                	je     8041600762 <draw_char+0x5f>
    for (int w = 0; w < 8; w++) {
  804160075b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600760:	eb dc                	jmp    804160073e <draw_char+0x3b>
}
  8041600762:	c3                   	retq   

0000008041600763 <cons_putc>:
  __asm __volatile("inb %w1,%0"
  8041600763:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600768:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8041600769:	a8 20                	test   $0x20,%al
  804160076b:	75 29                	jne    8041600796 <cons_putc+0x33>
  for (i = 0;
  804160076d:	be 00 00 00 00       	mov    $0x0,%esi
  8041600772:	b9 84 00 00 00       	mov    $0x84,%ecx
  8041600777:	41 b8 fd 03 00 00    	mov    $0x3fd,%r8d
  804160077d:	89 ca                	mov    %ecx,%edx
  804160077f:	ec                   	in     (%dx),%al
  8041600780:	ec                   	in     (%dx),%al
  8041600781:	ec                   	in     (%dx),%al
  8041600782:	ec                   	in     (%dx),%al
       i++)
  8041600783:	83 c6 01             	add    $0x1,%esi
  8041600786:	44 89 c2             	mov    %r8d,%edx
  8041600789:	ec                   	in     (%dx),%al
       !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  804160078a:	a8 20                	test   $0x20,%al
  804160078c:	75 08                	jne    8041600796 <cons_putc+0x33>
  804160078e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  8041600794:	7e e7                	jle    804160077d <cons_putc+0x1a>
  outb(COM1 + COM_TX, c);
  8041600796:	41 89 f8             	mov    %edi,%r8d
  __asm __volatile("outb %0,%w1"
  8041600799:	ba f8 03 00 00       	mov    $0x3f8,%edx
  804160079e:	89 f8                	mov    %edi,%eax
  80416007a0:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  80416007a1:	ba 79 03 00 00       	mov    $0x379,%edx
  80416007a6:	ec                   	in     (%dx),%al
  for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
  80416007a7:	84 c0                	test   %al,%al
  80416007a9:	78 29                	js     80416007d4 <cons_putc+0x71>
  80416007ab:	be 00 00 00 00       	mov    $0x0,%esi
  80416007b0:	b9 84 00 00 00       	mov    $0x84,%ecx
  80416007b5:	41 b9 79 03 00 00    	mov    $0x379,%r9d
  80416007bb:	89 ca                	mov    %ecx,%edx
  80416007bd:	ec                   	in     (%dx),%al
  80416007be:	ec                   	in     (%dx),%al
  80416007bf:	ec                   	in     (%dx),%al
  80416007c0:	ec                   	in     (%dx),%al
  80416007c1:	83 c6 01             	add    $0x1,%esi
  80416007c4:	44 89 ca             	mov    %r9d,%edx
  80416007c7:	ec                   	in     (%dx),%al
  80416007c8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
  80416007ce:	7f 04                	jg     80416007d4 <cons_putc+0x71>
  80416007d0:	84 c0                	test   %al,%al
  80416007d2:	79 e7                	jns    80416007bb <cons_putc+0x58>
  __asm __volatile("outb %0,%w1"
  80416007d4:	ba 78 03 00 00       	mov    $0x378,%edx
  80416007d9:	44 89 c0             	mov    %r8d,%eax
  80416007dc:	ee                   	out    %al,(%dx)
  80416007dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
  80416007e2:	b8 0d 00 00 00       	mov    $0xd,%eax
  80416007e7:	ee                   	out    %al,(%dx)
  80416007e8:	b8 08 00 00 00       	mov    $0x8,%eax
  80416007ed:	ee                   	out    %al,(%dx)
  if (!graphics_exists) {
  80416007ee:	48 b8 3c 38 62 41 80 	movabs $0x804162383c,%rax
  80416007f5:	00 00 00 
  80416007f8:	80 38 00             	cmpb   $0x0,(%rax)
  80416007fb:	0f 84 42 02 00 00    	je     8041600a43 <cons_putc+0x2e0>
  return 0;
}

// output a character to the console
static void
cons_putc(int c) {
  8041600801:	55                   	push   %rbp
  8041600802:	48 89 e5             	mov    %rsp,%rbp
  8041600805:	41 54                	push   %r12
  8041600807:	53                   	push   %rbx
  if (!(c & ~0xFF))
  8041600808:	89 fa                	mov    %edi,%edx
  804160080a:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
    c |= 0x0700;
  8041600810:	89 f8                	mov    %edi,%eax
  8041600812:	80 cc 07             	or     $0x7,%ah
  8041600815:	85 d2                	test   %edx,%edx
  8041600817:	0f 44 f8             	cmove  %eax,%edi
  switch (c & 0xff) {
  804160081a:	40 0f b6 c7          	movzbl %dil,%eax
  804160081e:	83 f8 09             	cmp    $0x9,%eax
  8041600821:	0f 84 e1 00 00 00    	je     8041600908 <cons_putc+0x1a5>
  8041600827:	7e 5c                	jle    8041600885 <cons_putc+0x122>
  8041600829:	83 f8 0a             	cmp    $0xa,%eax
  804160082c:	0f 84 b8 00 00 00    	je     80416008ea <cons_putc+0x187>
  8041600832:	83 f8 0d             	cmp    $0xd,%eax
  8041600835:	0f 85 ff 00 00 00    	jne    804160093a <cons_putc+0x1d7>
      crt_pos -= (crt_pos % crt_cols);
  804160083b:	48 be 28 38 62 41 80 	movabs $0x8041623828,%rsi
  8041600842:	00 00 00 
  8041600845:	0f b7 0e             	movzwl (%rsi),%ecx
  8041600848:	0f b7 c1             	movzwl %cx,%eax
  804160084b:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  8041600852:	00 00 00 
  8041600855:	ba 00 00 00 00       	mov    $0x0,%edx
  804160085a:	f7 33                	divl   (%rbx)
  804160085c:	29 d1                	sub    %edx,%ecx
  804160085e:	66 89 0e             	mov    %cx,(%rsi)
  if (crt_pos >= crt_size) {
  8041600861:	48 b8 28 38 62 41 80 	movabs $0x8041623828,%rax
  8041600868:	00 00 00 
  804160086b:	0f b7 10             	movzwl (%rax),%edx
  804160086e:	48 b8 2c 38 62 41 80 	movabs $0x804162382c,%rax
  8041600875:	00 00 00 
  8041600878:	3b 10                	cmp    (%rax),%edx
  804160087a:	0f 83 0f 01 00 00    	jae    804160098f <cons_putc+0x22c>
  serial_putc(c);
  lpt_putc(c);
  fb_putc(c);
}
  8041600880:	5b                   	pop    %rbx
  8041600881:	41 5c                	pop    %r12
  8041600883:	5d                   	pop    %rbp
  8041600884:	c3                   	retq   
  switch (c & 0xff) {
  8041600885:	83 f8 08             	cmp    $0x8,%eax
  8041600888:	0f 85 ac 00 00 00    	jne    804160093a <cons_putc+0x1d7>
      if (crt_pos > 0) {
  804160088e:	66 a1 28 38 62 41 80 	movabs 0x8041623828,%ax
  8041600895:	00 00 00 
  8041600898:	66 85 c0             	test   %ax,%ax
  804160089b:	74 c4                	je     8041600861 <cons_putc+0xfe>
        crt_pos--;
  804160089d:	83 e8 01             	sub    $0x1,%eax
  80416008a0:	66 a3 28 38 62 41 80 	movabs %ax,0x8041623828
  80416008a7:	00 00 00 
        draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0x0, 0x8);
  80416008aa:	0f b7 c0             	movzwl %ax,%eax
  80416008ad:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  80416008b4:	00 00 00 
  80416008b7:	8b 1b                	mov    (%rbx),%ebx
  80416008b9:	ba 00 00 00 00       	mov    $0x0,%edx
  80416008be:	f7 f3                	div    %ebx
  80416008c0:	89 d6                	mov    %edx,%esi
  80416008c2:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416008c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  80416008cd:	89 c2                	mov    %eax,%edx
  80416008cf:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416008d6:	00 00 00 
  80416008d9:	48 b8 03 07 60 41 80 	movabs $0x8041600703,%rax
  80416008e0:	00 00 00 
  80416008e3:	ff d0                	callq  *%rax
  80416008e5:	e9 77 ff ff ff       	jmpq   8041600861 <cons_putc+0xfe>
      crt_pos += crt_cols;
  80416008ea:	48 b8 28 38 62 41 80 	movabs $0x8041623828,%rax
  80416008f1:	00 00 00 
  80416008f4:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  80416008fb:	00 00 00 
  80416008fe:	8b 13                	mov    (%rbx),%edx
  8041600900:	66 01 10             	add    %dx,(%rax)
  8041600903:	e9 33 ff ff ff       	jmpq   804160083b <cons_putc+0xd8>
      cons_putc(' ');
  8041600908:	bf 20 00 00 00       	mov    $0x20,%edi
  804160090d:	48 bb 63 07 60 41 80 	movabs $0x8041600763,%rbx
  8041600914:	00 00 00 
  8041600917:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600919:	bf 20 00 00 00       	mov    $0x20,%edi
  804160091e:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600920:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600925:	ff d3                	callq  *%rbx
      cons_putc(' ');
  8041600927:	bf 20 00 00 00       	mov    $0x20,%edi
  804160092c:	ff d3                	callq  *%rbx
      cons_putc(' ');
  804160092e:	bf 20 00 00 00       	mov    $0x20,%edi
  8041600933:	ff d3                	callq  *%rbx
      break;
  8041600935:	e9 27 ff ff ff       	jmpq   8041600861 <cons_putc+0xfe>
      draw_char(crt_buf, crt_pos % crt_cols, crt_pos / crt_cols, 0xffffffff, (char)c); /* write the character */
  804160093a:	49 bc 28 38 62 41 80 	movabs $0x8041623828,%r12
  8041600941:	00 00 00 
  8041600944:	41 0f b7 1c 24       	movzwl (%r12),%ebx
  8041600949:	0f b7 c3             	movzwl %bx,%eax
  804160094c:	48 be 30 38 62 41 80 	movabs $0x8041623830,%rsi
  8041600953:	00 00 00 
  8041600956:	8b 36                	mov    (%rsi),%esi
  8041600958:	ba 00 00 00 00       	mov    $0x0,%edx
  804160095d:	f7 f6                	div    %esi
  804160095f:	89 d6                	mov    %edx,%esi
  8041600961:	44 0f be c7          	movsbl %dil,%r8d
  8041600965:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
  804160096a:	89 c2                	mov    %eax,%edx
  804160096c:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600973:	00 00 00 
  8041600976:	48 b8 03 07 60 41 80 	movabs $0x8041600703,%rax
  804160097d:	00 00 00 
  8041600980:	ff d0                	callq  *%rax
      crt_pos++;
  8041600982:	83 c3 01             	add    $0x1,%ebx
  8041600985:	66 41 89 1c 24       	mov    %bx,(%r12)
      break;
  804160098a:	e9 d2 fe ff ff       	jmpq   8041600861 <cons_putc+0xfe>
    memmove(crt_buf, crt_buf + uefi_hres * SYMBOL_SIZE, uefi_hres * (uefi_vres - SYMBOL_SIZE) * sizeof(uint32_t));
  804160098f:	48 bb 34 38 62 41 80 	movabs $0x8041623834,%rbx
  8041600996:	00 00 00 
  8041600999:	8b 03                	mov    (%rbx),%eax
  804160099b:	49 bc 38 38 62 41 80 	movabs $0x8041623838,%r12
  80416009a2:	00 00 00 
  80416009a5:	41 8b 3c 24          	mov    (%r12),%edi
  80416009a9:	8d 57 f8             	lea    -0x8(%rdi),%edx
  80416009ac:	0f af d0             	imul   %eax,%edx
  80416009af:	48 c1 e2 02          	shl    $0x2,%rdx
  80416009b3:	c1 e0 03             	shl    $0x3,%eax
  80416009b6:	89 c0                	mov    %eax,%eax
  80416009b8:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  80416009bf:	00 00 00 
  80416009c2:	48 8d 34 87          	lea    (%rdi,%rax,4),%rsi
  80416009c6:	48 b8 89 4f 60 41 80 	movabs $0x8041604f89,%rax
  80416009cd:	00 00 00 
  80416009d0:	ff d0                	callq  *%rax
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  80416009d2:	41 8b 04 24          	mov    (%r12),%eax
  80416009d6:	8b 0b                	mov    (%rbx),%ecx
  80416009d8:	89 c6                	mov    %eax,%esi
  80416009da:	83 e6 f8             	and    $0xfffffff8,%esi
  80416009dd:	83 ee 08             	sub    $0x8,%esi
  80416009e0:	0f af f1             	imul   %ecx,%esi
  80416009e3:	0f af c8             	imul   %eax,%ecx
  80416009e6:	39 f1                	cmp    %esi,%ecx
  80416009e8:	76 3b                	jbe    8041600a25 <cons_putc+0x2c2>
  80416009ea:	48 63 fe             	movslq %esi,%rdi
  80416009ed:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  80416009f4:	00 00 00 
  80416009f7:	48 8d 04 b8          	lea    (%rax,%rdi,4),%rax
  80416009fb:	8d 51 ff             	lea    -0x1(%rcx),%edx
  80416009fe:	89 d1                	mov    %edx,%ecx
  8041600a00:	29 f1                	sub    %esi,%ecx
  8041600a02:	48 ba 01 00 b0 0f 20 	movabs $0x200fb00001,%rdx
  8041600a09:	00 00 00 
  8041600a0c:	48 01 fa             	add    %rdi,%rdx
  8041600a0f:	48 01 ca             	add    %rcx,%rdx
  8041600a12:	48 c1 e2 02          	shl    $0x2,%rdx
      crt_buf[i] = 0;
  8041600a16:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (i = uefi_hres * (uefi_vres - (uefi_vres % SYMBOL_SIZE) - SYMBOL_SIZE); i < uefi_hres * uefi_vres; i++)
  8041600a1c:	48 83 c0 04          	add    $0x4,%rax
  8041600a20:	48 39 c2             	cmp    %rax,%rdx
  8041600a23:	75 f1                	jne    8041600a16 <cons_putc+0x2b3>
    crt_pos -= crt_cols;
  8041600a25:	48 b8 28 38 62 41 80 	movabs $0x8041623828,%rax
  8041600a2c:	00 00 00 
  8041600a2f:	48 bb 30 38 62 41 80 	movabs $0x8041623830,%rbx
  8041600a36:	00 00 00 
  8041600a39:	8b 13                	mov    (%rbx),%edx
  8041600a3b:	66 29 10             	sub    %dx,(%rax)
}
  8041600a3e:	e9 3d fe ff ff       	jmpq   8041600880 <cons_putc+0x11d>
  8041600a43:	c3                   	retq   

0000008041600a44 <serial_intr>:
  if (serial_exists)
  8041600a44:	48 b8 2a 38 62 41 80 	movabs $0x804162382a,%rax
  8041600a4b:	00 00 00 
  8041600a4e:	80 38 00             	cmpb   $0x0,(%rax)
  8041600a51:	75 01                	jne    8041600a54 <serial_intr+0x10>
  8041600a53:	c3                   	retq   
serial_intr(void) {
  8041600a54:	55                   	push   %rbp
  8041600a55:	48 89 e5             	mov    %rsp,%rbp
    cons_intr(serial_proc_data);
  8041600a58:	48 bf 4e 05 60 41 80 	movabs $0x804160054e,%rdi
  8041600a5f:	00 00 00 
  8041600a62:	48 b8 68 05 60 41 80 	movabs $0x8041600568,%rax
  8041600a69:	00 00 00 
  8041600a6c:	ff d0                	callq  *%rax
}
  8041600a6e:	5d                   	pop    %rbp
  8041600a6f:	c3                   	retq   

0000008041600a70 <fb_init>:
fb_init(void) {
  8041600a70:	55                   	push   %rbp
  8041600a71:	48 89 e5             	mov    %rsp,%rbp
  LOADER_PARAMS *lp = (LOADER_PARAMS *)uefi_lp;
  8041600a74:	48 b8 00 70 61 41 80 	movabs $0x8041617000,%rax
  8041600a7b:	00 00 00 
  8041600a7e:	48 8b 08             	mov    (%rax),%rcx
  uefi_vres         = lp->VerticalResolution;
  8041600a81:	8b 51 4c             	mov    0x4c(%rcx),%edx
  8041600a84:	89 d0                	mov    %edx,%eax
  8041600a86:	a3 38 38 62 41 80 00 	movabs %eax,0x8041623838
  8041600a8d:	00 00 
  uefi_hres         = lp->HorizontalResolution;
  8041600a8f:	8b 41 50             	mov    0x50(%rcx),%eax
  8041600a92:	a3 34 38 62 41 80 00 	movabs %eax,0x8041623834
  8041600a99:	00 00 
  crt_cols          = uefi_hres / SYMBOL_SIZE;
  8041600a9b:	c1 e8 03             	shr    $0x3,%eax
  8041600a9e:	89 c6                	mov    %eax,%esi
  8041600aa0:	a3 30 38 62 41 80 00 	movabs %eax,0x8041623830
  8041600aa7:	00 00 
  crt_rows          = uefi_vres / SYMBOL_SIZE;
  8041600aa9:	c1 ea 03             	shr    $0x3,%edx
  crt_size          = crt_rows * crt_cols;
  8041600aac:	0f af d0             	imul   %eax,%edx
  8041600aaf:	89 d0                	mov    %edx,%eax
  8041600ab1:	a3 2c 38 62 41 80 00 	movabs %eax,0x804162382c
  8041600ab8:	00 00 
  crt_pos           = crt_cols;
  8041600aba:	89 f0                	mov    %esi,%eax
  8041600abc:	66 a3 28 38 62 41 80 	movabs %ax,0x8041623828
  8041600ac3:	00 00 00 
  memset(crt_buf, 0, lp->FrameBufferSize);
  8041600ac6:	8b 51 48             	mov    0x48(%rcx),%edx
  8041600ac9:	be 00 00 00 00       	mov    $0x0,%esi
  8041600ace:	48 bf 00 00 c0 3e 80 	movabs $0x803ec00000,%rdi
  8041600ad5:	00 00 00 
  8041600ad8:	48 b8 46 4f 60 41 80 	movabs $0x8041604f46,%rax
  8041600adf:	00 00 00 
  8041600ae2:	ff d0                	callq  *%rax
  graphics_exists = true;
  8041600ae4:	48 b8 3c 38 62 41 80 	movabs $0x804162383c,%rax
  8041600aeb:	00 00 00 
  8041600aee:	c6 00 01             	movb   $0x1,(%rax)
}
  8041600af1:	5d                   	pop    %rbp
  8041600af2:	c3                   	retq   

0000008041600af3 <kbd_intr>:
kbd_intr(void) {
  8041600af3:	55                   	push   %rbp
  8041600af4:	48 89 e5             	mov    %rsp,%rbp
  cons_intr(kbd_proc_data);
  8041600af7:	48 bf b1 05 60 41 80 	movabs $0x80416005b1,%rdi
  8041600afe:	00 00 00 
  8041600b01:	48 b8 68 05 60 41 80 	movabs $0x8041600568,%rax
  8041600b08:	00 00 00 
  8041600b0b:	ff d0                	callq  *%rax
}
  8041600b0d:	5d                   	pop    %rbp
  8041600b0e:	c3                   	retq   

0000008041600b0f <cons_getc>:
cons_getc(void) {
  8041600b0f:	55                   	push   %rbp
  8041600b10:	48 89 e5             	mov    %rsp,%rbp
  serial_intr();
  8041600b13:	48 b8 44 0a 60 41 80 	movabs $0x8041600a44,%rax
  8041600b1a:	00 00 00 
  8041600b1d:	ff d0                	callq  *%rax
  kbd_intr();
  8041600b1f:	48 b8 f3 0a 60 41 80 	movabs $0x8041600af3,%rax
  8041600b26:	00 00 00 
  8041600b29:	ff d0                	callq  *%rax
  if (cons.rpos != cons.wpos) {
  8041600b2b:	48 b9 20 36 62 41 80 	movabs $0x8041623620,%rcx
  8041600b32:	00 00 00 
  8041600b35:	8b 91 00 02 00 00    	mov    0x200(%rcx),%edx
  return 0;
  8041600b3b:	b8 00 00 00 00       	mov    $0x0,%eax
  if (cons.rpos != cons.wpos) {
  8041600b40:	3b 91 04 02 00 00    	cmp    0x204(%rcx),%edx
  8041600b46:	74 21                	je     8041600b69 <cons_getc+0x5a>
    c = cons.buf[cons.rpos++];
  8041600b48:	8d 4a 01             	lea    0x1(%rdx),%ecx
  8041600b4b:	48 b8 20 36 62 41 80 	movabs $0x8041623620,%rax
  8041600b52:	00 00 00 
  8041600b55:	89 88 00 02 00 00    	mov    %ecx,0x200(%rax)
  8041600b5b:	89 d2                	mov    %edx,%edx
  8041600b5d:	0f b6 04 10          	movzbl (%rax,%rdx,1),%eax
    if (cons.rpos == CONSBUFSIZE)
  8041600b61:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  8041600b67:	74 02                	je     8041600b6b <cons_getc+0x5c>
}
  8041600b69:	5d                   	pop    %rbp
  8041600b6a:	c3                   	retq   
      cons.rpos = 0;
  8041600b6b:	48 be 20 38 62 41 80 	movabs $0x8041623820,%rsi
  8041600b72:	00 00 00 
  8041600b75:	c7 06 00 00 00 00    	movl   $0x0,(%rsi)
  8041600b7b:	eb ec                	jmp    8041600b69 <cons_getc+0x5a>

0000008041600b7d <cons_init>:
  8041600b7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041600b82:	bf fa 03 00 00       	mov    $0x3fa,%edi
  8041600b87:	89 c8                	mov    %ecx,%eax
  8041600b89:	89 fa                	mov    %edi,%edx
  8041600b8b:	ee                   	out    %al,(%dx)
  8041600b8c:	41 b9 fb 03 00 00    	mov    $0x3fb,%r9d
  8041600b92:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
  8041600b97:	44 89 ca             	mov    %r9d,%edx
  8041600b9a:	ee                   	out    %al,(%dx)
  8041600b9b:	be f8 03 00 00       	mov    $0x3f8,%esi
  8041600ba0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041600ba5:	89 f2                	mov    %esi,%edx
  8041600ba7:	ee                   	out    %al,(%dx)
  8041600ba8:	41 b8 f9 03 00 00    	mov    $0x3f9,%r8d
  8041600bae:	89 c8                	mov    %ecx,%eax
  8041600bb0:	44 89 c2             	mov    %r8d,%edx
  8041600bb3:	ee                   	out    %al,(%dx)
  8041600bb4:	b8 03 00 00 00       	mov    $0x3,%eax
  8041600bb9:	44 89 ca             	mov    %r9d,%edx
  8041600bbc:	ee                   	out    %al,(%dx)
  8041600bbd:	ba fc 03 00 00       	mov    $0x3fc,%edx
  8041600bc2:	89 c8                	mov    %ecx,%eax
  8041600bc4:	ee                   	out    %al,(%dx)
  8041600bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600bca:	44 89 c2             	mov    %r8d,%edx
  8041600bcd:	ee                   	out    %al,(%dx)
  __asm __volatile("inb %w1,%0"
  8041600bce:	ba fd 03 00 00       	mov    $0x3fd,%edx
  8041600bd3:	ec                   	in     (%dx),%al
  8041600bd4:	89 c1                	mov    %eax,%ecx
  serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  8041600bd6:	3c ff                	cmp    $0xff,%al
  8041600bd8:	0f 95 c0             	setne  %al
  8041600bdb:	a2 2a 38 62 41 80 00 	movabs %al,0x804162382a
  8041600be2:	00 00 
  8041600be4:	89 fa                	mov    %edi,%edx
  8041600be6:	ec                   	in     (%dx),%al
  8041600be7:	89 f2                	mov    %esi,%edx
  8041600be9:	ec                   	in     (%dx),%al
void
cons_init(void) {
  kbd_init();
  serial_init();

  if (!serial_exists)
  8041600bea:	80 f9 ff             	cmp    $0xff,%cl
  8041600bed:	74 01                	je     8041600bf0 <cons_init+0x73>
  8041600bef:	c3                   	retq   
cons_init(void) {
  8041600bf0:	55                   	push   %rbp
  8041600bf1:	48 89 e5             	mov    %rsp,%rbp
    cprintf("Serial port does not exist!\n");
  8041600bf4:	48 bf 32 53 60 41 80 	movabs $0x8041605332,%rdi
  8041600bfb:	00 00 00 
  8041600bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  8041600c03:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041600c0a:	00 00 00 
  8041600c0d:	ff d2                	callq  *%rdx
}
  8041600c0f:	5d                   	pop    %rbp
  8041600c10:	c3                   	retq   

0000008041600c11 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c) {
  8041600c11:	55                   	push   %rbp
  8041600c12:	48 89 e5             	mov    %rsp,%rbp
  cons_putc(c);
  8041600c15:	48 b8 63 07 60 41 80 	movabs $0x8041600763,%rax
  8041600c1c:	00 00 00 
  8041600c1f:	ff d0                	callq  *%rax
}
  8041600c21:	5d                   	pop    %rbp
  8041600c22:	c3                   	retq   

0000008041600c23 <getchar>:

int
getchar(void) {
  8041600c23:	55                   	push   %rbp
  8041600c24:	48 89 e5             	mov    %rsp,%rbp
  8041600c27:	53                   	push   %rbx
  8041600c28:	48 83 ec 08          	sub    $0x8,%rsp
  int c;

  while ((c = cons_getc()) == 0)
  8041600c2c:	48 bb 0f 0b 60 41 80 	movabs $0x8041600b0f,%rbx
  8041600c33:	00 00 00 
  8041600c36:	ff d3                	callq  *%rbx
  8041600c38:	85 c0                	test   %eax,%eax
  8041600c3a:	74 fa                	je     8041600c36 <getchar+0x13>
    /* do nothing */;
  return c;
}
  8041600c3c:	48 83 c4 08          	add    $0x8,%rsp
  8041600c40:	5b                   	pop    %rbx
  8041600c41:	5d                   	pop    %rbp
  8041600c42:	c3                   	retq   

0000008041600c43 <iscons>:

int
iscons(int fdnum) {
  // used by readline
  return 1;
}
  8041600c43:	b8 01 00 00 00       	mov    $0x1,%eax
  8041600c48:	c3                   	retq   

0000008041600c49 <dwarf_read_abbrev_entry>:
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  8041600c49:	55                   	push   %rbp
  8041600c4a:	48 89 e5             	mov    %rsp,%rbp
  8041600c4d:	41 56                	push   %r14
  8041600c4f:	41 55                	push   %r13
  8041600c51:	41 54                	push   %r12
  8041600c53:	53                   	push   %rbx
  8041600c54:	48 83 ec 20          	sub    $0x20,%rsp
  8041600c58:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  int bytes = 0;
  switch (form) {
  8041600c5c:	83 fe 20             	cmp    $0x20,%esi
  8041600c5f:	0f 87 48 09 00 00    	ja     80416015ad <dwarf_read_abbrev_entry+0x964>
  8041600c65:	44 89 c3             	mov    %r8d,%ebx
  8041600c68:	41 89 cd             	mov    %ecx,%r13d
  8041600c6b:	49 89 d4             	mov    %rdx,%r12
  8041600c6e:	89 f6                	mov    %esi,%esi
  8041600c70:	48 b8 38 56 60 41 80 	movabs $0x8041605638,%rax
  8041600c77:	00 00 00 
  8041600c7a:	ff 24 f0             	jmpq   *(%rax,%rsi,8)
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
  8041600c7d:	48 85 d2             	test   %rdx,%rdx
  8041600c80:	74 75                	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
  8041600c82:	83 f9 07             	cmp    $0x7,%ecx
  8041600c85:	76 70                	jbe    8041600cf7 <dwarf_read_abbrev_entry+0xae>
        memcpy(buf, entry, sizeof(uintptr_t));
  8041600c87:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600c8c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600c90:	4c 89 e7             	mov    %r12,%rdi
  8041600c93:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600c9a:	00 00 00 
  8041600c9d:	ff d0                	callq  *%rax
      }
      entry += address_size;
      bytes = address_size;
      break;
  8041600c9f:	eb 56                	jmp    8041600cf7 <dwarf_read_abbrev_entry+0xae>
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB 2: Your code here:
      Dwarf_Half length = get_unaligned(entry, Dwarf_Half);
  8041600ca1:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600ca6:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600caa:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600cae:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600cb5:	00 00 00 
  8041600cb8:	ff d0                	callq  *%rax
  8041600cba:	0f b7 5d d0          	movzwl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Half);
  8041600cbe:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600cc2:	48 83 c0 02          	add    $0x2,%rax
  8041600cc6:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600cca:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600cce:	0f b7 c3             	movzwl %bx,%eax
  8041600cd1:	89 45 d8             	mov    %eax,-0x28(%rbp)
          .mem = entry,
          .len = length,
      };
      if (buf) {
  8041600cd4:	4d 85 e4             	test   %r12,%r12
  8041600cd7:	74 18                	je     8041600cf1 <dwarf_read_abbrev_entry+0xa8>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600cd9:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600cde:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600ce2:	4c 89 e7             	mov    %r12,%rdi
  8041600ce5:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600cec:	00 00 00 
  8041600cef:	ff d0                	callq  *%rax
      }
      entry += length;
      bytes = sizeof(Dwarf_Half) + length;
  8041600cf1:	0f b7 db             	movzwl %bx,%ebx
  8041600cf4:	83 c3 02             	add    $0x2,%ebx
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}
  8041600cf7:	89 d8                	mov    %ebx,%eax
  8041600cf9:	48 83 c4 20          	add    $0x20,%rsp
  8041600cfd:	5b                   	pop    %rbx
  8041600cfe:	41 5c                	pop    %r12
  8041600d00:	41 5d                	pop    %r13
  8041600d02:	41 5e                	pop    %r14
  8041600d04:	5d                   	pop    %rbp
  8041600d05:	c3                   	retq   
      unsigned length = get_unaligned(entry, uint32_t);
  8041600d06:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600d0b:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d0f:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d13:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600d1a:	00 00 00 
  8041600d1d:	ff d0                	callq  *%rax
  8041600d1f:	8b 5d d0             	mov    -0x30(%rbp),%ebx
      entry += sizeof(uint32_t);
  8041600d22:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600d26:	48 83 c0 04          	add    $0x4,%rax
  8041600d2a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600d2e:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600d32:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600d35:	4d 85 e4             	test   %r12,%r12
  8041600d38:	74 18                	je     8041600d52 <dwarf_read_abbrev_entry+0x109>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600d3a:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600d3f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d43:	4c 89 e7             	mov    %r12,%rdi
  8041600d46:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600d4d:	00 00 00 
  8041600d50:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t) + length;
  8041600d52:	83 c3 04             	add    $0x4,%ebx
    } break;
  8041600d55:	eb a0                	jmp    8041600cf7 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041600d57:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d5c:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600d60:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600d64:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600d6b:	00 00 00 
  8041600d6e:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041600d70:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  8041600d75:	4d 85 e4             	test   %r12,%r12
  8041600d78:	74 06                	je     8041600d80 <dwarf_read_abbrev_entry+0x137>
  8041600d7a:	41 83 fd 01          	cmp    $0x1,%r13d
  8041600d7e:	77 0a                	ja     8041600d8a <dwarf_read_abbrev_entry+0x141>
      bytes = sizeof(Dwarf_Half);
  8041600d80:	bb 02 00 00 00       	mov    $0x2,%ebx
  8041600d85:	e9 6d ff ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600d8a:	ba 02 00 00 00       	mov    $0x2,%edx
  8041600d8f:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600d93:	4c 89 e7             	mov    %r12,%rdi
  8041600d96:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600d9d:	00 00 00 
  8041600da0:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  8041600da2:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  8041600da7:	e9 4b ff ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  8041600dac:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600db1:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600db5:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600db9:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600dc0:	00 00 00 
  8041600dc3:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  8041600dc5:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  8041600dca:	4d 85 e4             	test   %r12,%r12
  8041600dcd:	74 06                	je     8041600dd5 <dwarf_read_abbrev_entry+0x18c>
  8041600dcf:	41 83 fd 03          	cmp    $0x3,%r13d
  8041600dd3:	77 0a                	ja     8041600ddf <dwarf_read_abbrev_entry+0x196>
      bytes = sizeof(uint32_t);
  8041600dd5:	bb 04 00 00 00       	mov    $0x4,%ebx
  8041600dda:	e9 18 ff ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  8041600ddf:	ba 04 00 00 00       	mov    $0x4,%edx
  8041600de4:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600de8:	4c 89 e7             	mov    %r12,%rdi
  8041600deb:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600df2:	00 00 00 
  8041600df5:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041600df7:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041600dfc:	e9 f6 fe ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041600e01:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e06:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600e0a:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600e0e:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600e15:	00 00 00 
  8041600e18:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041600e1a:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041600e1f:	4d 85 e4             	test   %r12,%r12
  8041600e22:	74 06                	je     8041600e2a <dwarf_read_abbrev_entry+0x1e1>
  8041600e24:	41 83 fd 07          	cmp    $0x7,%r13d
  8041600e28:	77 0a                	ja     8041600e34 <dwarf_read_abbrev_entry+0x1eb>
      bytes = sizeof(uint64_t);
  8041600e2a:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041600e2f:	e9 c3 fe ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  8041600e34:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e39:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600e3d:	4c 89 e7             	mov    %r12,%rdi
  8041600e40:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600e47:	00 00 00 
  8041600e4a:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041600e4c:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  8041600e51:	e9 a1 fe ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      if (buf && bufsize >= sizeof(char *)) {
  8041600e56:	48 85 d2             	test   %rdx,%rdx
  8041600e59:	74 05                	je     8041600e60 <dwarf_read_abbrev_entry+0x217>
  8041600e5b:	83 f9 07             	cmp    $0x7,%ecx
  8041600e5e:	77 18                	ja     8041600e78 <dwarf_read_abbrev_entry+0x22f>
      bytes = strlen(entry) + 1;
  8041600e60:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  8041600e64:	48 b8 7e 4d 60 41 80 	movabs $0x8041604d7e,%rax
  8041600e6b:	00 00 00 
  8041600e6e:	ff d0                	callq  *%rax
  8041600e70:	8d 58 01             	lea    0x1(%rax),%ebx
    } break;
  8041600e73:	e9 7f fe ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        memcpy(buf, &entry, sizeof(char *));
  8041600e78:	ba 08 00 00 00       	mov    $0x8,%edx
  8041600e7d:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041600e81:	4c 89 e7             	mov    %r12,%rdi
  8041600e84:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600e8b:	00 00 00 
  8041600e8e:	ff d0                	callq  *%rax
  8041600e90:	eb ce                	jmp    8041600e60 <dwarf_read_abbrev_entry+0x217>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  8041600e92:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600e96:	4c 89 c2             	mov    %r8,%rdx
  unsigned char byte;
  int shift, count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600e99:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041600e9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600ea3:	bb 00 00 00 00       	mov    $0x0,%ebx

  while (1) {
    byte = *addr;
  8041600ea8:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600eab:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041600eaf:	83 c7 01             	add    $0x1,%edi

    result |= (byte & 0x7f) << shift;
  8041600eb2:	89 f0                	mov    %esi,%eax
  8041600eb4:	83 e0 7f             	and    $0x7f,%eax
  8041600eb7:	d3 e0                	shl    %cl,%eax
  8041600eb9:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041600ebb:	83 c1 07             	add    $0x7,%ecx

    if (!(byte & 0x80))
  8041600ebe:	40 84 f6             	test   %sil,%sil
  8041600ec1:	78 e5                	js     8041600ea8 <dwarf_read_abbrev_entry+0x25f>
      break;
  }

  *ret = result;

  return count;
  8041600ec3:	4c 63 ef             	movslq %edi,%r13
      entry += count;
  8041600ec6:	4d 01 e8             	add    %r13,%r8
  8041600ec9:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      struct Slice slice = {
  8041600ecd:	4c 89 45 d0          	mov    %r8,-0x30(%rbp)
  8041600ed1:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600ed4:	4d 85 e4             	test   %r12,%r12
  8041600ed7:	74 18                	je     8041600ef1 <dwarf_read_abbrev_entry+0x2a8>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600ed9:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600ede:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600ee2:	4c 89 e7             	mov    %r12,%rdi
  8041600ee5:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600eec:	00 00 00 
  8041600eef:	ff d0                	callq  *%rax
      bytes = count + length;
  8041600ef1:	44 01 eb             	add    %r13d,%ebx
    } break;
  8041600ef4:	e9 fe fd ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      unsigned length = get_unaligned(entry, Dwarf_Small);
  8041600ef9:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600efe:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f02:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f06:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600f0d:	00 00 00 
  8041600f10:	ff d0                	callq  *%rax
  8041600f12:	0f b6 5d d0          	movzbl -0x30(%rbp),%ebx
      entry += sizeof(Dwarf_Small);
  8041600f16:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8041600f1a:	48 83 c0 01          	add    $0x1,%rax
  8041600f1e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
      struct Slice slice = {
  8041600f22:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8041600f26:	89 5d d8             	mov    %ebx,-0x28(%rbp)
      if (buf) {
  8041600f29:	4d 85 e4             	test   %r12,%r12
  8041600f2c:	74 18                	je     8041600f46 <dwarf_read_abbrev_entry+0x2fd>
        memcpy(buf, &slice, sizeof(struct Slice));
  8041600f2e:	ba 10 00 00 00       	mov    $0x10,%edx
  8041600f33:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041600f37:	4c 89 e7             	mov    %r12,%rdi
  8041600f3a:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600f41:	00 00 00 
  8041600f44:	ff d0                	callq  *%rax
      bytes = length + sizeof(Dwarf_Small);
  8041600f46:	83 c3 01             	add    $0x1,%ebx
    } break;
  8041600f49:	e9 a9 fd ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041600f4e:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f53:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f57:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f5b:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600f62:	00 00 00 
  8041600f65:	ff d0                	callq  *%rax
  8041600f67:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041600f6b:	4d 85 e4             	test   %r12,%r12
  8041600f6e:	0f 84 43 06 00 00    	je     80416015b7 <dwarf_read_abbrev_entry+0x96e>
  8041600f74:	45 85 ed             	test   %r13d,%r13d
  8041600f77:	0f 84 3a 06 00 00    	je     80416015b7 <dwarf_read_abbrev_entry+0x96e>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f7d:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041600f81:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  8041600f86:	e9 6c fd ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600f8b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041600f90:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041600f94:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041600f98:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041600f9f:	00 00 00 
  8041600fa2:	ff d0                	callq  *%rax
  8041600fa4:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(bool)) {
  8041600fa8:	4d 85 e4             	test   %r12,%r12
  8041600fab:	0f 84 10 06 00 00    	je     80416015c1 <dwarf_read_abbrev_entry+0x978>
  8041600fb1:	45 85 ed             	test   %r13d,%r13d
  8041600fb4:	0f 84 07 06 00 00    	je     80416015c1 <dwarf_read_abbrev_entry+0x978>
      bool data = get_unaligned(entry, Dwarf_Small);
  8041600fba:	84 c0                	test   %al,%al
        put_unaligned(data, (bool *)buf);
  8041600fbc:	41 0f 95 04 24       	setne  (%r12)
      bytes = sizeof(Dwarf_Small);
  8041600fc1:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (bool *)buf);
  8041600fc6:	e9 2c fd ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      int count = dwarf_read_leb128(entry, &data);
  8041600fcb:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041600fcf:	4c 89 c2             	mov    %r8,%rdx
  int num_bits;
  int count;

  result = 0;
  shift  = 0;
  count  = 0;
  8041600fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  8041600fd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041600fdc:	bf 00 00 00 00       	mov    $0x0,%edi

  while (1) {
    byte = *addr;
  8041600fe1:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041600fe4:	48 83 c2 01          	add    $0x1,%rdx
    result |= (byte & 0x7f) << shift;
  8041600fe8:	89 f0                	mov    %esi,%eax
  8041600fea:	83 e0 7f             	and    $0x7f,%eax
  8041600fed:	d3 e0                	shl    %cl,%eax
  8041600fef:	09 c7                	or     %eax,%edi
    shift += 7;
  8041600ff1:	83 c1 07             	add    $0x7,%ecx
    count++;
  8041600ff4:	83 c3 01             	add    $0x1,%ebx

    if (!(byte & 0x80))
  8041600ff7:	40 84 f6             	test   %sil,%sil
  8041600ffa:	78 e5                	js     8041600fe1 <dwarf_read_abbrev_entry+0x398>
  }

  /* The number of bits in a signed integer. */
  num_bits = 8 * sizeof(result);

  if ((shift < num_bits) && (byte & 0x40))
  8041600ffc:	83 f9 1f             	cmp    $0x1f,%ecx
  8041600fff:	7f 0f                	jg     8041601010 <dwarf_read_abbrev_entry+0x3c7>
  8041601001:	40 f6 c6 40          	test   $0x40,%sil
  8041601005:	74 09                	je     8041601010 <dwarf_read_abbrev_entry+0x3c7>
    result |= (-1U << shift);
  8041601007:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  804160100c:	d3 e0                	shl    %cl,%eax
  804160100e:	09 c7                	or     %eax,%edi

  *ret = result;

  return count;
  8041601010:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601013:	49 01 c0             	add    %rax,%r8
  8041601016:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(int)) {
  804160101a:	4d 85 e4             	test   %r12,%r12
  804160101d:	0f 84 d4 fc ff ff    	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
  8041601023:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601027:	0f 86 ca fc ff ff    	jbe    8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (int *)buf);
  804160102d:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601030:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601035:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601039:	4c 89 e7             	mov    %r12,%rdi
  804160103c:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601043:	00 00 00 
  8041601046:	ff d0                	callq  *%rax
  8041601048:	e9 aa fc ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  804160104d:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601051:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601056:	4c 89 f6             	mov    %r14,%rsi
  8041601059:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160105d:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601064:	00 00 00 
  8041601067:	ff d0                	callq  *%rax
  8041601069:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160106c:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160106e:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601073:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601076:	76 2a                	jbe    80416010a2 <dwarf_read_abbrev_entry+0x459>
    if (initial_len == DW_EXT_DWARF64) {
  8041601078:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160107b:	74 60                	je     80416010dd <dwarf_read_abbrev_entry+0x494>
      cprintf("Unknown DWARF extension\n");
  804160107d:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  8041601084:	00 00 00 
  8041601087:	b8 00 00 00 00       	mov    $0x0,%eax
  804160108c:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041601093:	00 00 00 
  8041601096:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601098:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160109d:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416010a2:	48 63 c3             	movslq %ebx,%rax
  80416010a5:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416010a9:	4d 85 e4             	test   %r12,%r12
  80416010ac:	0f 84 45 fc ff ff    	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
  80416010b2:	41 83 fd 07          	cmp    $0x7,%r13d
  80416010b6:	0f 86 3b fc ff ff    	jbe    8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  80416010bc:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416010c0:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010c5:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416010c9:	4c 89 e7             	mov    %r12,%rdi
  80416010cc:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416010d3:	00 00 00 
  80416010d6:	ff d0                	callq  *%rax
  80416010d8:	e9 1a fc ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416010dd:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416010e1:	ba 08 00 00 00       	mov    $0x8,%edx
  80416010e6:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416010ea:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416010f1:	00 00 00 
  80416010f4:	ff d0                	callq  *%rax
  80416010f6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416010fa:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416010ff:	eb a1                	jmp    80416010a2 <dwarf_read_abbrev_entry+0x459>
      int count         = dwarf_read_uleb128(entry, &data);
  8041601101:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601105:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601108:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160110d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601112:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601117:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160111a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160111e:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  8041601121:	89 f0                	mov    %esi,%eax
  8041601123:	83 e0 7f             	and    $0x7f,%eax
  8041601126:	d3 e0                	shl    %cl,%eax
  8041601128:	09 c7                	or     %eax,%edi
    shift += 7;
  804160112a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160112d:	40 84 f6             	test   %sil,%sil
  8041601130:	78 e5                	js     8041601117 <dwarf_read_abbrev_entry+0x4ce>
  return count;
  8041601132:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601135:	49 01 c0             	add    %rax,%r8
  8041601138:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160113c:	4d 85 e4             	test   %r12,%r12
  804160113f:	0f 84 b2 fb ff ff    	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
  8041601145:	41 83 fd 03          	cmp    $0x3,%r13d
  8041601149:	0f 86 a8 fb ff ff    	jbe    8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  804160114f:	89 7d d0             	mov    %edi,-0x30(%rbp)
  8041601152:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601157:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160115b:	4c 89 e7             	mov    %r12,%rdi
  804160115e:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601165:	00 00 00 
  8041601168:	ff d0                	callq  *%rax
  804160116a:	e9 88 fb ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  804160116f:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  8041601173:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601178:	4c 89 f6             	mov    %r14,%rsi
  804160117b:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160117f:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601186:	00 00 00 
  8041601189:	ff d0                	callq  *%rax
  804160118b:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  804160118e:	89 c2                	mov    %eax,%edx
  count       = 4;
  8041601190:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601195:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601198:	76 2a                	jbe    80416011c4 <dwarf_read_abbrev_entry+0x57b>
    if (initial_len == DW_EXT_DWARF64) {
  804160119a:	83 f8 ff             	cmp    $0xffffffff,%eax
  804160119d:	74 60                	je     80416011ff <dwarf_read_abbrev_entry+0x5b6>
      cprintf("Unknown DWARF extension\n");
  804160119f:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  80416011a6:	00 00 00 
  80416011a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416011ae:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  80416011b5:	00 00 00 
  80416011b8:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  80416011ba:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  80416011bf:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  80416011c4:	48 63 c3             	movslq %ebx,%rax
  80416011c7:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  80416011cb:	4d 85 e4             	test   %r12,%r12
  80416011ce:	0f 84 23 fb ff ff    	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
  80416011d4:	41 83 fd 07          	cmp    $0x7,%r13d
  80416011d8:	0f 86 19 fb ff ff    	jbe    8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  80416011de:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80416011e2:	ba 08 00 00 00       	mov    $0x8,%edx
  80416011e7:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416011eb:	4c 89 e7             	mov    %r12,%rdi
  80416011ee:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416011f5:	00 00 00 
  80416011f8:	ff d0                	callq  *%rax
  80416011fa:	e9 f8 fa ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416011ff:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601203:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601208:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160120c:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601213:	00 00 00 
  8041601216:	ff d0                	callq  *%rax
  8041601218:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  804160121c:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041601221:	eb a1                	jmp    80416011c4 <dwarf_read_abbrev_entry+0x57b>
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
  8041601223:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601228:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  804160122c:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601230:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601237:	00 00 00 
  804160123a:	ff d0                	callq  *%rax
  804160123c:	0f b6 45 d0          	movzbl -0x30(%rbp),%eax
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
  8041601240:	4d 85 e4             	test   %r12,%r12
  8041601243:	0f 84 82 03 00 00    	je     80416015cb <dwarf_read_abbrev_entry+0x982>
  8041601249:	45 85 ed             	test   %r13d,%r13d
  804160124c:	0f 84 79 03 00 00    	je     80416015cb <dwarf_read_abbrev_entry+0x982>
        put_unaligned(data, (Dwarf_Small *)buf);
  8041601252:	41 88 04 24          	mov    %al,(%r12)
      bytes = sizeof(Dwarf_Small);
  8041601256:	bb 01 00 00 00       	mov    $0x1,%ebx
        put_unaligned(data, (Dwarf_Small *)buf);
  804160125b:	e9 97 fa ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
  8041601260:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601265:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601269:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160126d:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601274:	00 00 00 
  8041601277:	ff d0                	callq  *%rax
      entry += sizeof(Dwarf_Half);
  8041601279:	48 83 45 c8 02       	addq   $0x2,-0x38(%rbp)
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
  804160127e:	4d 85 e4             	test   %r12,%r12
  8041601281:	74 06                	je     8041601289 <dwarf_read_abbrev_entry+0x640>
  8041601283:	41 83 fd 01          	cmp    $0x1,%r13d
  8041601287:	77 0a                	ja     8041601293 <dwarf_read_abbrev_entry+0x64a>
      bytes = sizeof(Dwarf_Half);
  8041601289:	bb 02 00 00 00       	mov    $0x2,%ebx
  804160128e:	e9 64 fa ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (Dwarf_Half *)buf);
  8041601293:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601298:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  804160129c:	4c 89 e7             	mov    %r12,%rdi
  804160129f:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416012a6:	00 00 00 
  80416012a9:	ff d0                	callq  *%rax
      bytes = sizeof(Dwarf_Half);
  80416012ab:	bb 02 00 00 00       	mov    $0x2,%ebx
        put_unaligned(data, (Dwarf_Half *)buf);
  80416012b0:	e9 42 fa ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      uint32_t data = get_unaligned(entry, uint32_t);
  80416012b5:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012ba:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416012be:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416012c2:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416012c9:	00 00 00 
  80416012cc:	ff d0                	callq  *%rax
      entry += sizeof(uint32_t);
  80416012ce:	48 83 45 c8 04       	addq   $0x4,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint32_t)) {
  80416012d3:	4d 85 e4             	test   %r12,%r12
  80416012d6:	74 06                	je     80416012de <dwarf_read_abbrev_entry+0x695>
  80416012d8:	41 83 fd 03          	cmp    $0x3,%r13d
  80416012dc:	77 0a                	ja     80416012e8 <dwarf_read_abbrev_entry+0x69f>
      bytes = sizeof(uint32_t);
  80416012de:	bb 04 00 00 00       	mov    $0x4,%ebx
  80416012e3:	e9 0f fa ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint32_t *)buf);
  80416012e8:	ba 04 00 00 00       	mov    $0x4,%edx
  80416012ed:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416012f1:	4c 89 e7             	mov    %r12,%rdi
  80416012f4:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416012fb:	00 00 00 
  80416012fe:	ff d0                	callq  *%rax
      bytes = sizeof(uint32_t);
  8041601300:	bb 04 00 00 00       	mov    $0x4,%ebx
        put_unaligned(data, (uint32_t *)buf);
  8041601305:	e9 ed f9 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  804160130a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160130f:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601313:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601317:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  804160131e:	00 00 00 
  8041601321:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601323:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601328:	4d 85 e4             	test   %r12,%r12
  804160132b:	74 06                	je     8041601333 <dwarf_read_abbrev_entry+0x6ea>
  804160132d:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601331:	77 0a                	ja     804160133d <dwarf_read_abbrev_entry+0x6f4>
      bytes = sizeof(uint64_t);
  8041601333:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041601338:	e9 ba f9 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  804160133d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601342:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601346:	4c 89 e7             	mov    %r12,%rdi
  8041601349:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601350:	00 00 00 
  8041601353:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  8041601355:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  804160135a:	e9 98 f9 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &data);
  804160135f:	4c 8b 45 c8          	mov    -0x38(%rbp),%r8
  8041601363:	4c 89 c2             	mov    %r8,%rdx
  count  = 0;
  8041601366:	bb 00 00 00 00       	mov    $0x0,%ebx
  shift  = 0;
  804160136b:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601370:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041601375:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601378:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160137c:	83 c3 01             	add    $0x1,%ebx
    result |= (byte & 0x7f) << shift;
  804160137f:	89 f0                	mov    %esi,%eax
  8041601381:	83 e0 7f             	and    $0x7f,%eax
  8041601384:	d3 e0                	shl    %cl,%eax
  8041601386:	09 c7                	or     %eax,%edi
    shift += 7;
  8041601388:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160138b:	40 84 f6             	test   %sil,%sil
  804160138e:	78 e5                	js     8041601375 <dwarf_read_abbrev_entry+0x72c>
  return count;
  8041601390:	48 63 c3             	movslq %ebx,%rax
      entry += count;
  8041601393:	49 01 c0             	add    %rax,%r8
  8041601396:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned int)) {
  804160139a:	4d 85 e4             	test   %r12,%r12
  804160139d:	0f 84 54 f9 ff ff    	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
  80416013a3:	41 83 fd 03          	cmp    $0x3,%r13d
  80416013a7:	0f 86 4a f9 ff ff    	jbe    8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (unsigned int *)buf);
  80416013ad:	89 7d d0             	mov    %edi,-0x30(%rbp)
  80416013b0:	ba 04 00 00 00       	mov    $0x4,%edx
  80416013b5:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416013b9:	4c 89 e7             	mov    %r12,%rdi
  80416013bc:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416013c3:	00 00 00 
  80416013c6:	ff d0                	callq  *%rax
  80416013c8:	e9 2a f9 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      int count         = dwarf_read_uleb128(entry, &form);
  80416013cd:	48 8b 7d c8          	mov    -0x38(%rbp),%rdi
  80416013d1:	48 89 fa             	mov    %rdi,%rdx
  count  = 0;
  80416013d4:	41 be 00 00 00 00    	mov    $0x0,%r14d
  shift  = 0;
  80416013da:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416013df:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416013e4:	44 0f b6 02          	movzbl (%rdx),%r8d
    addr++;
  80416013e8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416013ec:	41 83 c6 01          	add    $0x1,%r14d
    result |= (byte & 0x7f) << shift;
  80416013f0:	44 89 c0             	mov    %r8d,%eax
  80416013f3:	83 e0 7f             	and    $0x7f,%eax
  80416013f6:	d3 e0                	shl    %cl,%eax
  80416013f8:	09 c6                	or     %eax,%esi
    shift += 7;
  80416013fa:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416013fd:	45 84 c0             	test   %r8b,%r8b
  8041601400:	78 e2                	js     80416013e4 <dwarf_read_abbrev_entry+0x79b>
  return count;
  8041601402:	49 63 c6             	movslq %r14d,%rax
      entry += count;
  8041601405:	48 01 c7             	add    %rax,%rdi
  8041601408:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
  804160140c:	41 89 d8             	mov    %ebx,%r8d
  804160140f:	44 89 e9             	mov    %r13d,%ecx
  8041601412:	4c 89 e2             	mov    %r12,%rdx
  8041601415:	48 b8 49 0c 60 41 80 	movabs $0x8041600c49,%rax
  804160141c:	00 00 00 
  804160141f:	ff d0                	callq  *%rax
      bytes    = count + read;
  8041601421:	42 8d 1c 30          	lea    (%rax,%r14,1),%ebx
    } break;
  8041601425:	e9 cd f8 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      int count            = dwarf_entry_len(entry, &length);
  804160142a:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  initial_len = get_unaligned(addr, uint32_t);
  804160142e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601433:	4c 89 f6             	mov    %r14,%rsi
  8041601436:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  804160143a:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601441:	00 00 00 
  8041601444:	ff d0                	callq  *%rax
  8041601446:	8b 45 d0             	mov    -0x30(%rbp),%eax
    *len = initial_len;
  8041601449:	89 c2                	mov    %eax,%edx
  count       = 4;
  804160144b:	bb 04 00 00 00       	mov    $0x4,%ebx
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601450:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601453:	76 2a                	jbe    804160147f <dwarf_read_abbrev_entry+0x836>
    if (initial_len == DW_EXT_DWARF64) {
  8041601455:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601458:	74 60                	je     80416014ba <dwarf_read_abbrev_entry+0x871>
      cprintf("Unknown DWARF extension\n");
  804160145a:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  8041601461:	00 00 00 
  8041601464:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601469:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041601470:	00 00 00 
  8041601473:	ff d2                	callq  *%rdx
      unsigned long length = 0;
  8041601475:	ba 00 00 00 00       	mov    $0x0,%edx
      count = 0;
  804160147a:	bb 00 00 00 00       	mov    $0x0,%ebx
      entry += count;
  804160147f:	48 63 c3             	movslq %ebx,%rax
  8041601482:	48 01 45 c8          	add    %rax,-0x38(%rbp)
      if (buf && bufsize >= sizeof(unsigned long)) {
  8041601486:	4d 85 e4             	test   %r12,%r12
  8041601489:	0f 84 68 f8 ff ff    	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
  804160148f:	41 83 fd 07          	cmp    $0x7,%r13d
  8041601493:	0f 86 5e f8 ff ff    	jbe    8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(length, (unsigned long *)buf);
  8041601499:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  804160149d:	ba 08 00 00 00       	mov    $0x8,%edx
  80416014a2:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80416014a6:	4c 89 e7             	mov    %r12,%rdi
  80416014a9:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416014b0:	00 00 00 
  80416014b3:	ff d0                	callq  *%rax
  80416014b5:	e9 3d f8 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416014ba:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416014be:	ba 08 00 00 00       	mov    $0x8,%edx
  80416014c3:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  80416014c7:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416014ce:	00 00 00 
  80416014d1:	ff d0                	callq  *%rax
  80416014d3:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
      count = 12;
  80416014d7:	bb 0c 00 00 00       	mov    $0xc,%ebx
  80416014dc:	eb a1                	jmp    804160147f <dwarf_read_abbrev_entry+0x836>
      unsigned long count = dwarf_read_uleb128(entry, &length);
  80416014de:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  80416014e2:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416014e5:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416014eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416014f0:	bb 00 00 00 00       	mov    $0x0,%ebx
    byte = *addr;
  80416014f5:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416014f8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416014fc:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041601500:	89 f8                	mov    %edi,%eax
  8041601502:	83 e0 7f             	and    $0x7f,%eax
  8041601505:	d3 e0                	shl    %cl,%eax
  8041601507:	09 c3                	or     %eax,%ebx
    shift += 7;
  8041601509:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160150c:	40 84 ff             	test   %dil,%dil
  804160150f:	78 e4                	js     80416014f5 <dwarf_read_abbrev_entry+0x8ac>
  return count;
  8041601511:	4d 63 f0             	movslq %r8d,%r14
      entry += count;
  8041601514:	4c 01 f6             	add    %r14,%rsi
  8041601517:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
      if (buf) {
  804160151b:	4d 85 e4             	test   %r12,%r12
  804160151e:	74 1a                	je     804160153a <dwarf_read_abbrev_entry+0x8f1>
        memcpy(buf, entry, MIN(length, bufsize));
  8041601520:	41 39 dd             	cmp    %ebx,%r13d
  8041601523:	44 89 ea             	mov    %r13d,%edx
  8041601526:	0f 47 d3             	cmova  %ebx,%edx
  8041601529:	89 d2                	mov    %edx,%edx
  804160152b:	4c 89 e7             	mov    %r12,%rdi
  804160152e:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601535:	00 00 00 
  8041601538:	ff d0                	callq  *%rax
      bytes = count + length;
  804160153a:	44 01 f3             	add    %r14d,%ebx
    } break;
  804160153d:	e9 b5 f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      bytes = 0;
  8041601542:	bb 00 00 00 00       	mov    $0x0,%ebx
      if (buf && sizeof(buf) >= sizeof(bool)) {
  8041601547:	48 85 d2             	test   %rdx,%rdx
  804160154a:	0f 84 a7 f7 ff ff    	je     8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(true, (bool *)buf);
  8041601550:	c6 02 01             	movb   $0x1,(%rdx)
  8041601553:	e9 9f f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      uint64_t data = get_unaligned(entry, uint64_t);
  8041601558:	ba 08 00 00 00       	mov    $0x8,%edx
  804160155d:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041601561:	48 8d 7d d0          	lea    -0x30(%rbp),%rdi
  8041601565:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  804160156c:	00 00 00 
  804160156f:	ff d0                	callq  *%rax
      entry += sizeof(uint64_t);
  8041601571:	48 83 45 c8 08       	addq   $0x8,-0x38(%rbp)
      if (buf && bufsize >= sizeof(uint64_t)) {
  8041601576:	4d 85 e4             	test   %r12,%r12
  8041601579:	74 06                	je     8041601581 <dwarf_read_abbrev_entry+0x938>
  804160157b:	41 83 fd 07          	cmp    $0x7,%r13d
  804160157f:	77 0a                	ja     804160158b <dwarf_read_abbrev_entry+0x942>
      bytes = sizeof(uint64_t);
  8041601581:	bb 08 00 00 00       	mov    $0x8,%ebx
  return bytes;
  8041601586:	e9 6c f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
        put_unaligned(data, (uint64_t *)buf);
  804160158b:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601590:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8041601594:	4c 89 e7             	mov    %r12,%rdi
  8041601597:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  804160159e:	00 00 00 
  80416015a1:	ff d0                	callq  *%rax
      bytes = sizeof(uint64_t);
  80416015a3:	bb 08 00 00 00       	mov    $0x8,%ebx
        put_unaligned(data, (uint64_t *)buf);
  80416015a8:	e9 4a f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
  int bytes = 0;
  80416015ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  80416015b2:	e9 40 f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015b7:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015bc:	e9 36 f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015c1:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015c6:	e9 2c f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>
      bytes = sizeof(Dwarf_Small);
  80416015cb:	bb 01 00 00 00       	mov    $0x1,%ebx
  80416015d0:	e9 22 f7 ff ff       	jmpq   8041600cf7 <dwarf_read_abbrev_entry+0xae>

00000080416015d5 <info_by_address>:
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  80416015d5:	55                   	push   %rbp
  80416015d6:	48 89 e5             	mov    %rsp,%rbp
  80416015d9:	41 57                	push   %r15
  80416015db:	41 56                	push   %r14
  80416015dd:	41 55                	push   %r13
  80416015df:	41 54                	push   %r12
  80416015e1:	53                   	push   %rbx
  80416015e2:	48 83 ec 48          	sub    $0x48,%rsp
  80416015e6:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80416015ea:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  80416015ee:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  const void *set = addrs->aranges_begin;
  80416015f2:	4c 8b 77 10          	mov    0x10(%rdi),%r14
  initial_len = get_unaligned(addr, uint32_t);
  80416015f6:	49 bd f7 4f 60 41 80 	movabs $0x8041604ff7,%r13
  80416015fd:	00 00 00 
  8041601600:	e9 bb 01 00 00       	jmpq   80416017c0 <info_by_address+0x1eb>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601605:	49 8d 76 20          	lea    0x20(%r14),%rsi
  8041601609:	ba 08 00 00 00       	mov    $0x8,%edx
  804160160e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601612:	41 ff d5             	callq  *%r13
  8041601615:	4c 8b 65 c8          	mov    -0x38(%rbp),%r12
      count = 12;
  8041601619:	bb 0c 00 00 00       	mov    $0xc,%ebx
  804160161e:	eb 08                	jmp    8041601628 <info_by_address+0x53>
    *len = initial_len;
  8041601620:	45 89 e4             	mov    %r12d,%r12d
  count       = 4;
  8041601623:	bb 04 00 00 00       	mov    $0x4,%ebx
      set += count;
  8041601628:	4c 63 fb             	movslq %ebx,%r15
  804160162b:	4b 8d 1c 3e          	lea    (%r14,%r15,1),%rbx
    const void *set_end = set + len;
  804160162f:	49 01 dc             	add    %rbx,%r12
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
  8041601632:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601637:	48 89 de             	mov    %rbx,%rsi
  804160163a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160163e:	41 ff d5             	callq  *%r13
    set += sizeof(Dwarf_Half);
  8041601641:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 2);
  8041601645:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  804160164a:	75 7a                	jne    80416016c6 <info_by_address+0xf1>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  804160164c:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601651:	48 89 de             	mov    %rbx,%rsi
  8041601654:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601658:	41 ff d5             	callq  *%r13
  804160165b:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160165e:	89 45 b0             	mov    %eax,-0x50(%rbp)
    set += count;
  8041601661:	4c 01 fb             	add    %r15,%rbx
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
  8041601664:	4c 8d 7b 01          	lea    0x1(%rbx),%r15
  8041601668:	ba 01 00 00 00       	mov    $0x1,%edx
  804160166d:	48 89 de             	mov    %rbx,%rsi
  8041601670:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601674:	41 ff d5             	callq  *%r13
    assert(address_size == 8);
  8041601677:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160167b:	75 7e                	jne    80416016fb <info_by_address+0x126>
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
  804160167d:	48 83 c3 02          	add    $0x2,%rbx
  8041601681:	ba 01 00 00 00       	mov    $0x1,%edx
  8041601686:	4c 89 fe             	mov    %r15,%rsi
  8041601689:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160168d:	41 ff d5             	callq  *%r13
    assert(segment_size == 0);
  8041601690:	80 7d c8 00          	cmpb   $0x0,-0x38(%rbp)
  8041601694:	0f 85 96 00 00 00    	jne    8041601730 <info_by_address+0x15b>
    uint32_t remainder  = (set - header) % entry_size;
  804160169a:	48 89 d8             	mov    %rbx,%rax
  804160169d:	4c 29 f0             	sub    %r14,%rax
  80416016a0:	48 99                	cqto   
  80416016a2:	48 c1 ea 3c          	shr    $0x3c,%rdx
  80416016a6:	48 01 d0             	add    %rdx,%rax
  80416016a9:	83 e0 0f             	and    $0xf,%eax
    if (remainder) {
  80416016ac:	48 29 d0             	sub    %rdx,%rax
  80416016af:	0f 84 b5 00 00 00    	je     804160176a <info_by_address+0x195>
      set += 2 * address_size - remainder;
  80416016b5:	ba 10 00 00 00       	mov    $0x10,%edx
  80416016ba:	89 d1                	mov    %edx,%ecx
  80416016bc:	29 c1                	sub    %eax,%ecx
  80416016be:	48 01 cb             	add    %rcx,%rbx
  80416016c1:	e9 a4 00 00 00       	jmpq   804160176a <info_by_address+0x195>
    assert(version == 2);
  80416016c6:	48 b9 fe 55 60 41 80 	movabs $0x80416055fe,%rcx
  80416016cd:	00 00 00 
  80416016d0:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  80416016d7:	00 00 00 
  80416016da:	be 20 00 00 00       	mov    $0x20,%esi
  80416016df:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  80416016e6:	00 00 00 
  80416016e9:	b8 00 00 00 00       	mov    $0x0,%eax
  80416016ee:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  80416016f5:	00 00 00 
  80416016f8:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  80416016fb:	48 b9 bb 55 60 41 80 	movabs $0x80416055bb,%rcx
  8041601702:	00 00 00 
  8041601705:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  804160170c:	00 00 00 
  804160170f:	be 24 00 00 00       	mov    $0x24,%esi
  8041601714:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  804160171b:	00 00 00 
  804160171e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601723:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  804160172a:	00 00 00 
  804160172d:	41 ff d0             	callq  *%r8
    assert(segment_size == 0);
  8041601730:	48 b9 cd 55 60 41 80 	movabs $0x80416055cd,%rcx
  8041601737:	00 00 00 
  804160173a:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601741:	00 00 00 
  8041601744:	be 26 00 00 00       	mov    $0x26,%esi
  8041601749:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601750:	00 00 00 
  8041601753:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601758:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  804160175f:	00 00 00 
  8041601762:	41 ff d0             	callq  *%r8
    } while (set < set_end);
  8041601765:	4c 39 e3             	cmp    %r12,%rbx
  8041601768:	73 51                	jae    80416017bb <info_by_address+0x1e6>
      addr = (void *)get_unaligned(set, uintptr_t);
  804160176a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160176f:	48 89 de             	mov    %rbx,%rsi
  8041601772:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601776:	41 ff d5             	callq  *%r13
  8041601779:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
      size = get_unaligned(set, uint32_t);
  804160177d:	48 8d 73 08          	lea    0x8(%rbx),%rsi
  8041601781:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601786:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160178a:	41 ff d5             	callq  *%r13
  804160178d:	8b 45 c8             	mov    -0x38(%rbp),%eax
      set += address_size;
  8041601790:	48 83 c3 10          	add    $0x10,%rbx
      if ((uintptr_t)addr <= p &&
  8041601794:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8041601798:	4c 39 f1             	cmp    %r14,%rcx
  804160179b:	72 c8                	jb     8041601765 <info_by_address+0x190>
      size = get_unaligned(set, uint32_t);
  804160179d:	89 c0                	mov    %eax,%eax
          p <= (uintptr_t)addr + size) {
  804160179f:	4c 01 f0             	add    %r14,%rax
      if ((uintptr_t)addr <= p &&
  80416017a2:	48 39 c1             	cmp    %rax,%rcx
  80416017a5:	77 be                	ja     8041601765 <info_by_address+0x190>
    Dwarf_Off offset = get_unaligned(set, uint32_t);
  80416017a7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416017ab:	8b 4d b0             	mov    -0x50(%rbp),%ecx
  80416017ae:	48 89 08             	mov    %rcx,(%rax)
        return 0;
  80416017b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416017b6:	e9 5a 04 00 00       	jmpq   8041601c15 <info_by_address+0x640>
      set += address_size;
  80416017bb:	49 89 de             	mov    %rbx,%r14
    assert(set == set_end);
  80416017be:	75 71                	jne    8041601831 <info_by_address+0x25c>
  while ((unsigned char *)set < addrs->aranges_end) {
  80416017c0:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80416017c4:	4c 3b 70 18          	cmp    0x18(%rax),%r14
  80416017c8:	73 42                	jae    804160180c <info_by_address+0x237>
  initial_len = get_unaligned(addr, uint32_t);
  80416017ca:	ba 04 00 00 00       	mov    $0x4,%edx
  80416017cf:	4c 89 f6             	mov    %r14,%rsi
  80416017d2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416017d6:	41 ff d5             	callq  *%r13
  80416017d9:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416017dd:	41 83 fc ef          	cmp    $0xffffffef,%r12d
  80416017e1:	0f 86 39 fe ff ff    	jbe    8041601620 <info_by_address+0x4b>
    if (initial_len == DW_EXT_DWARF64) {
  80416017e7:	41 83 fc ff          	cmp    $0xffffffff,%r12d
  80416017eb:	0f 84 14 fe ff ff    	je     8041601605 <info_by_address+0x30>
      cprintf("Unknown DWARF extension\n");
  80416017f1:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  80416017f8:	00 00 00 
  80416017fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601800:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041601807:	00 00 00 
  804160180a:	ff d2                	callq  *%rdx
  const void *entry = addrs->info_begin;
  804160180c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601810:	48 8b 58 20          	mov    0x20(%rax),%rbx
  8041601814:	48 89 5d b0          	mov    %rbx,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601818:	48 3b 58 28          	cmp    0x28(%rax),%rbx
  804160181c:	0f 83 5b 04 00 00    	jae    8041601c7d <info_by_address+0x6a8>
  initial_len = get_unaligned(addr, uint32_t);
  8041601822:	49 bf f7 4f 60 41 80 	movabs $0x8041604ff7,%r15
  8041601829:	00 00 00 
  804160182c:	e9 9f 03 00 00       	jmpq   8041601bd0 <info_by_address+0x5fb>
    assert(set == set_end);
  8041601831:	48 b9 df 55 60 41 80 	movabs $0x80416055df,%rcx
  8041601838:	00 00 00 
  804160183b:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601842:	00 00 00 
  8041601845:	be 3a 00 00 00       	mov    $0x3a,%esi
  804160184a:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601851:	00 00 00 
  8041601854:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601859:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601860:	00 00 00 
  8041601863:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601866:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160186a:	48 8d 70 20          	lea    0x20(%rax),%rsi
  804160186e:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601873:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601877:	41 ff d7             	callq  *%r15
  804160187a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  804160187e:	41 bc 0c 00 00 00    	mov    $0xc,%r12d
  8041601884:	eb 08                	jmp    804160188e <info_by_address+0x2b9>
    *len = initial_len;
  8041601886:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041601888:	41 bc 04 00 00 00    	mov    $0x4,%r12d
      entry += count;
  804160188e:	4d 63 e4             	movslq %r12d,%r12
  8041601891:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8041601895:	4a 8d 1c 21          	lea    (%rcx,%r12,1),%rbx
    const void *entry_end = entry + len;
  8041601899:	48 01 d8             	add    %rbx,%rax
  804160189c:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416018a0:	ba 02 00 00 00       	mov    $0x2,%edx
  80416018a5:	48 89 de             	mov    %rbx,%rsi
  80416018a8:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018ac:	41 ff d7             	callq  *%r15
    entry += sizeof(Dwarf_Half);
  80416018af:	48 83 c3 02          	add    $0x2,%rbx
    assert(version == 4 || version == 2);
  80416018b3:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416018b7:	83 e8 02             	sub    $0x2,%eax
  80416018ba:	66 a9 fd ff          	test   $0xfffd,%ax
  80416018be:	0f 85 07 01 00 00    	jne    80416019cb <info_by_address+0x3f6>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416018c4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416018c9:	48 89 de             	mov    %rbx,%rsi
  80416018cc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018d0:	41 ff d7             	callq  *%r15
  80416018d3:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
    entry += count;
  80416018d7:	4a 8d 34 23          	lea    (%rbx,%r12,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416018db:	4c 8d 66 01          	lea    0x1(%rsi),%r12
  80416018df:	ba 01 00 00 00       	mov    $0x1,%edx
  80416018e4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416018e8:	41 ff d7             	callq  *%r15
    assert(address_size == 8);
  80416018eb:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416018ef:	0f 85 0b 01 00 00    	jne    8041601a00 <info_by_address+0x42b>
  80416018f5:	4c 89 e6             	mov    %r12,%rsi
  count  = 0;
  80416018f8:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  80416018fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601902:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601907:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  804160190b:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  804160190f:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601912:	44 89 c7             	mov    %r8d,%edi
  8041601915:	83 e7 7f             	and    $0x7f,%edi
  8041601918:	d3 e7                	shl    %cl,%edi
  804160191a:	09 fa                	or     %edi,%edx
    shift += 7;
  804160191c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160191f:	45 84 c0             	test   %r8b,%r8b
  8041601922:	78 e3                	js     8041601907 <info_by_address+0x332>
  return count;
  8041601924:	48 98                	cltq   
    assert(abbrev_code != 0);
  8041601926:	85 d2                	test   %edx,%edx
  8041601928:	0f 84 07 01 00 00    	je     8041601a35 <info_by_address+0x460>
    entry += count;
  804160192e:	49 01 c4             	add    %rax,%r12
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  8041601931:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8041601935:	4c 03 28             	add    (%rax),%r13
  8041601938:	4c 89 ef             	mov    %r13,%rdi
  count  = 0;
  804160193b:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601940:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601945:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  804160194a:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  804160194e:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  8041601952:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601955:	45 89 c8             	mov    %r9d,%r8d
  8041601958:	41 83 e0 7f          	and    $0x7f,%r8d
  804160195c:	41 d3 e0             	shl    %cl,%r8d
  804160195f:	44 09 c6             	or     %r8d,%esi
    shift += 7;
  8041601962:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601965:	45 84 c9             	test   %r9b,%r9b
  8041601968:	78 e0                	js     804160194a <info_by_address+0x375>
  return count;
  804160196a:	48 98                	cltq   
    abbrev_entry += count;
  804160196c:	49 01 c5             	add    %rax,%r13
    assert(table_abbrev_code == abbrev_code);
  804160196f:	39 f2                	cmp    %esi,%edx
  8041601971:	0f 85 f3 00 00 00    	jne    8041601a6a <info_by_address+0x495>
  8041601977:	4c 89 ee             	mov    %r13,%rsi
  count  = 0;
  804160197a:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  804160197f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601984:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041601989:	44 0f b6 06          	movzbl (%rsi),%r8d
    addr++;
  804160198d:	48 83 c6 01          	add    $0x1,%rsi
    count++;
  8041601991:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601994:	44 89 c7             	mov    %r8d,%edi
  8041601997:	83 e7 7f             	and    $0x7f,%edi
  804160199a:	d3 e7                	shl    %cl,%edi
  804160199c:	09 fa                	or     %edi,%edx
    shift += 7;
  804160199e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416019a1:	45 84 c0             	test   %r8b,%r8b
  80416019a4:	78 e3                	js     8041601989 <info_by_address+0x3b4>
  return count;
  80416019a6:	48 98                	cltq   
    assert(tag == DW_TAG_compile_unit);
  80416019a8:	83 fa 11             	cmp    $0x11,%edx
  80416019ab:	0f 85 ee 00 00 00    	jne    8041601a9f <info_by_address+0x4ca>
    abbrev_entry++;
  80416019b1:	49 8d 5c 05 01       	lea    0x1(%r13,%rax,1),%rbx
    uintptr_t low_pc = 0, high_pc = 0;
  80416019b6:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  80416019bd:	00 
  80416019be:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  80416019c5:	00 
  80416019c6:	e9 2f 01 00 00       	jmpq   8041601afa <info_by_address+0x525>
    assert(version == 4 || version == 2);
  80416019cb:	48 b9 ee 55 60 41 80 	movabs $0x80416055ee,%rcx
  80416019d2:	00 00 00 
  80416019d5:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  80416019dc:	00 00 00 
  80416019df:	be 40 01 00 00       	mov    $0x140,%esi
  80416019e4:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  80416019eb:	00 00 00 
  80416019ee:	b8 00 00 00 00       	mov    $0x0,%eax
  80416019f3:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  80416019fa:	00 00 00 
  80416019fd:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041601a00:	48 b9 bb 55 60 41 80 	movabs $0x80416055bb,%rcx
  8041601a07:	00 00 00 
  8041601a0a:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601a11:	00 00 00 
  8041601a14:	be 44 01 00 00       	mov    $0x144,%esi
  8041601a19:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601a20:	00 00 00 
  8041601a23:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601a28:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601a2f:	00 00 00 
  8041601a32:	41 ff d0             	callq  *%r8
    assert(abbrev_code != 0);
  8041601a35:	48 b9 0b 56 60 41 80 	movabs $0x804160560b,%rcx
  8041601a3c:	00 00 00 
  8041601a3f:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601a46:	00 00 00 
  8041601a49:	be 49 01 00 00       	mov    $0x149,%esi
  8041601a4e:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601a55:	00 00 00 
  8041601a58:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601a5d:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601a64:	00 00 00 
  8041601a67:	41 ff d0             	callq  *%r8
    assert(table_abbrev_code == abbrev_code);
  8041601a6a:	48 b9 40 57 60 41 80 	movabs $0x8041605740,%rcx
  8041601a71:	00 00 00 
  8041601a74:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601a7b:	00 00 00 
  8041601a7e:	be 51 01 00 00       	mov    $0x151,%esi
  8041601a83:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601a8a:	00 00 00 
  8041601a8d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601a92:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601a99:	00 00 00 
  8041601a9c:	41 ff d0             	callq  *%r8
    assert(tag == DW_TAG_compile_unit);
  8041601a9f:	48 b9 1c 56 60 41 80 	movabs $0x804160561c,%rcx
  8041601aa6:	00 00 00 
  8041601aa9:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601ab0:	00 00 00 
  8041601ab3:	be 55 01 00 00       	mov    $0x155,%esi
  8041601ab8:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601abf:	00 00 00 
  8041601ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601ac7:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601ace:	00 00 00 
  8041601ad1:	41 ff d0             	callq  *%r8
        count = dwarf_read_abbrev_entry(
  8041601ad4:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601ada:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601adf:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601ae3:	44 89 f6             	mov    %r14d,%esi
  8041601ae6:	4c 89 e7             	mov    %r12,%rdi
  8041601ae9:	48 b8 49 0c 60 41 80 	movabs $0x8041600c49,%rax
  8041601af0:	00 00 00 
  8041601af3:	ff d0                	callq  *%rax
      entry += count;
  8041601af5:	48 98                	cltq   
  8041601af7:	49 01 c4             	add    %rax,%r12
  result = 0;
  8041601afa:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601afd:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601b02:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601b07:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601b0d:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601b10:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601b14:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601b17:	89 fe                	mov    %edi,%esi
  8041601b19:	83 e6 7f             	and    $0x7f,%esi
  8041601b1c:	d3 e6                	shl    %cl,%esi
  8041601b1e:	41 09 f5             	or     %esi,%r13d
    shift += 7;
  8041601b21:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601b24:	40 84 ff             	test   %dil,%dil
  8041601b27:	78 e4                	js     8041601b0d <info_by_address+0x538>
  return count;
  8041601b29:	48 98                	cltq   
      abbrev_entry += count;
  8041601b2b:	48 01 c3             	add    %rax,%rbx
  8041601b2e:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601b31:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  8041601b36:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601b3b:	41 be 00 00 00 00    	mov    $0x0,%r14d
    byte = *addr;
  8041601b41:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041601b44:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601b48:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041601b4b:	89 fe                	mov    %edi,%esi
  8041601b4d:	83 e6 7f             	and    $0x7f,%esi
  8041601b50:	d3 e6                	shl    %cl,%esi
  8041601b52:	41 09 f6             	or     %esi,%r14d
    shift += 7;
  8041601b55:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601b58:	40 84 ff             	test   %dil,%dil
  8041601b5b:	78 e4                	js     8041601b41 <info_by_address+0x56c>
  return count;
  8041601b5d:	48 98                	cltq   
      abbrev_entry += count;
  8041601b5f:	48 01 c3             	add    %rax,%rbx
      if (name == DW_AT_low_pc) {
  8041601b62:	41 83 fd 11          	cmp    $0x11,%r13d
  8041601b66:	0f 84 68 ff ff ff    	je     8041601ad4 <info_by_address+0x4ff>
      } else if (name == DW_AT_high_pc) {
  8041601b6c:	41 83 fd 12          	cmp    $0x12,%r13d
  8041601b70:	0f 84 ae 00 00 00    	je     8041601c24 <info_by_address+0x64f>
        count = dwarf_read_abbrev_entry(
  8041601b76:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601b81:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601b86:	44 89 f6             	mov    %r14d,%esi
  8041601b89:	4c 89 e7             	mov    %r12,%rdi
  8041601b8c:	48 b8 49 0c 60 41 80 	movabs $0x8041600c49,%rax
  8041601b93:	00 00 00 
  8041601b96:	ff d0                	callq  *%rax
      entry += count;
  8041601b98:	48 98                	cltq   
  8041601b9a:	49 01 c4             	add    %rax,%r12
    } while (name != 0 || form != 0);
  8041601b9d:	45 09 f5             	or     %r14d,%r13d
  8041601ba0:	0f 85 54 ff ff ff    	jne    8041601afa <info_by_address+0x525>
    if (p >= low_pc && p <= high_pc) {
  8041601ba6:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041601baa:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8041601bae:	72 0a                	jb     8041601bba <info_by_address+0x5e5>
  8041601bb0:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8041601bb4:	0f 86 a2 00 00 00    	jbe    8041601c5c <info_by_address+0x687>
    entry = entry_end;
  8041601bba:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8041601bbe:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  while ((unsigned char *)entry < addrs->info_end) {
  8041601bc2:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601bc6:	48 3b 41 28          	cmp    0x28(%rcx),%rax
  8041601bca:	0f 83 a6 00 00 00    	jae    8041601c76 <info_by_address+0x6a1>
  initial_len = get_unaligned(addr, uint32_t);
  8041601bd0:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601bd5:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8041601bd9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601bdd:	41 ff d7             	callq  *%r15
  8041601be0:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601be3:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601be6:	0f 86 9a fc ff ff    	jbe    8041601886 <info_by_address+0x2b1>
    if (initial_len == DW_EXT_DWARF64) {
  8041601bec:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601bef:	0f 84 71 fc ff ff    	je     8041601866 <info_by_address+0x291>
      cprintf("Unknown DWARF extension\n");
  8041601bf5:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  8041601bfc:	00 00 00 
  8041601bff:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c04:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041601c0b:	00 00 00 
  8041601c0e:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041601c10:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}
  8041601c15:	48 83 c4 48          	add    $0x48,%rsp
  8041601c19:	5b                   	pop    %rbx
  8041601c1a:	41 5c                	pop    %r12
  8041601c1c:	41 5d                	pop    %r13
  8041601c1e:	41 5e                	pop    %r14
  8041601c20:	41 5f                	pop    %r15
  8041601c22:	5d                   	pop    %rbp
  8041601c23:	c3                   	retq   
        count = dwarf_read_abbrev_entry(
  8041601c24:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601c2a:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601c2f:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041601c33:	44 89 f6             	mov    %r14d,%esi
  8041601c36:	4c 89 e7             	mov    %r12,%rdi
  8041601c39:	48 b8 49 0c 60 41 80 	movabs $0x8041600c49,%rax
  8041601c40:	00 00 00 
  8041601c43:	ff d0                	callq  *%rax
        if (form != DW_FORM_addr) {
  8041601c45:	41 83 fe 01          	cmp    $0x1,%r14d
  8041601c49:	0f 84 a6 fe ff ff    	je     8041601af5 <info_by_address+0x520>
          high_pc += low_pc;
  8041601c4f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041601c53:	48 01 55 c8          	add    %rdx,-0x38(%rbp)
  8041601c57:	e9 99 fe ff ff       	jmpq   8041601af5 <info_by_address+0x520>
          (const unsigned char *)header - addrs->info_begin;
  8041601c5c:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
  8041601c60:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041601c64:	48 2b 41 20          	sub    0x20(%rcx),%rax
      *store =
  8041601c68:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  8041601c6c:	48 89 01             	mov    %rax,(%rcx)
      return 0;
  8041601c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c74:	eb 9f                	jmp    8041601c15 <info_by_address+0x640>
  return 0;
  8041601c76:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c7b:	eb 98                	jmp    8041601c15 <info_by_address+0x640>
  8041601c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601c82:	eb 91                	jmp    8041601c15 <info_by_address+0x640>

0000008041601c84 <file_name_by_info>:

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  8041601c84:	55                   	push   %rbp
  8041601c85:	48 89 e5             	mov    %rsp,%rbp
  8041601c88:	41 57                	push   %r15
  8041601c8a:	41 56                	push   %r14
  8041601c8c:	41 55                	push   %r13
  8041601c8e:	41 54                	push   %r12
  8041601c90:	53                   	push   %rbx
  8041601c91:	48 83 ec 38          	sub    $0x38,%rsp
  if (offset > addrs->info_end - addrs->info_begin) {
  8041601c95:	48 8b 5f 20          	mov    0x20(%rdi),%rbx
  8041601c99:	48 8b 47 28          	mov    0x28(%rdi),%rax
  8041601c9d:	48 29 d8             	sub    %rbx,%rax
  8041601ca0:	48 39 f0             	cmp    %rsi,%rax
  8041601ca3:	0f 82 f5 02 00 00    	jb     8041601f9e <file_name_by_info+0x31a>
  8041601ca9:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  8041601cad:	89 4d b4             	mov    %ecx,-0x4c(%rbp)
  8041601cb0:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8041601cb4:	48 89 7d a0          	mov    %rdi,-0x60(%rbp)
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  8041601cb8:	48 01 f3             	add    %rsi,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041601cbb:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601cc0:	48 89 de             	mov    %rbx,%rsi
  8041601cc3:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601cc7:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601cce:	00 00 00 
  8041601cd1:	ff d0                	callq  *%rax
  8041601cd3:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041601cd6:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041601cd9:	0f 86 c9 02 00 00    	jbe    8041601fa8 <file_name_by_info+0x324>
    if (initial_len == DW_EXT_DWARF64) {
  8041601cdf:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041601ce2:	74 25                	je     8041601d09 <file_name_by_info+0x85>
      cprintf("Unknown DWARF extension\n");
  8041601ce4:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  8041601ceb:	00 00 00 
  8041601cee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601cf3:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041601cfa:	00 00 00 
  8041601cfd:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041601cff:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  8041601d04:	e9 00 02 00 00       	jmpq   8041601f09 <file_name_by_info+0x285>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041601d09:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041601d0d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601d12:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601d16:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601d1d:	00 00 00 
  8041601d20:	ff d0                	callq  *%rax
      count = 12;
  8041601d22:	41 bd 0c 00 00 00    	mov    $0xc,%r13d
  8041601d28:	e9 81 02 00 00       	jmpq   8041601fae <file_name_by_info+0x32a>
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  8041601d2d:	48 b9 ee 55 60 41 80 	movabs $0x80416055ee,%rcx
  8041601d34:	00 00 00 
  8041601d37:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601d3e:	00 00 00 
  8041601d41:	be 98 01 00 00       	mov    $0x198,%esi
  8041601d46:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601d4d:	00 00 00 
  8041601d50:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d55:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601d5c:	00 00 00 
  8041601d5f:	41 ff d0             	callq  *%r8
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);
  8041601d62:	48 b9 bb 55 60 41 80 	movabs $0x80416055bb,%rcx
  8041601d69:	00 00 00 
  8041601d6c:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601d73:	00 00 00 
  8041601d76:	be 9c 01 00 00       	mov    $0x19c,%esi
  8041601d7b:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601d82:	00 00 00 
  8041601d85:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601d8a:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601d91:	00 00 00 
  8041601d94:	41 ff d0             	callq  *%r8

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  8041601d97:	48 b9 0b 56 60 41 80 	movabs $0x804160560b,%rcx
  8041601d9e:	00 00 00 
  8041601da1:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601da8:	00 00 00 
  8041601dab:	be a1 01 00 00       	mov    $0x1a1,%esi
  8041601db0:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601db7:	00 00 00 
  8041601dba:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601dbf:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601dc6:	00 00 00 
  8041601dc9:	41 ff d0             	callq  *%r8
  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  8041601dcc:	48 b9 40 57 60 41 80 	movabs $0x8041605740,%rcx
  8041601dd3:	00 00 00 
  8041601dd6:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601ddd:	00 00 00 
  8041601de0:	be a9 01 00 00       	mov    $0x1a9,%esi
  8041601de5:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601dec:	00 00 00 
  8041601def:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601df4:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601dfb:	00 00 00 
  8041601dfe:	41 ff d0             	callq  *%r8
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  8041601e01:	48 b9 1c 56 60 41 80 	movabs $0x804160561c,%rcx
  8041601e08:	00 00 00 
  8041601e0b:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041601e12:	00 00 00 
  8041601e15:	be ad 01 00 00       	mov    $0x1ad,%esi
  8041601e1a:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041601e21:	00 00 00 
  8041601e24:	b8 00 00 00 00       	mov    $0x0,%eax
  8041601e29:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041601e30:	00 00 00 
  8041601e33:	41 ff d0             	callq  *%r8
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
  8041601e36:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041601e3a:	0f 84 d8 00 00 00    	je     8041601f18 <file_name_by_info+0x294>
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
  8041601e40:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601e46:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041601e49:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8041601e4d:	44 89 ee             	mov    %r13d,%esi
  8041601e50:	4c 89 f7             	mov    %r14,%rdi
  8041601e53:	41 ff d7             	callq  *%r15
  8041601e56:	41 89 c4             	mov    %eax,%r12d
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  8041601e59:	49 63 c4             	movslq %r12d,%rax
  8041601e5c:	49 01 c6             	add    %rax,%r14
  result = 0;
  8041601e5f:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601e62:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601e67:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601e6c:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041601e72:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601e75:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601e79:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601e7c:	89 f0                	mov    %esi,%eax
  8041601e7e:	83 e0 7f             	and    $0x7f,%eax
  8041601e81:	d3 e0                	shl    %cl,%eax
  8041601e83:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041601e86:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601e89:	40 84 f6             	test   %sil,%sil
  8041601e8c:	78 e4                	js     8041601e72 <file_name_by_info+0x1ee>
  return count;
  8041601e8e:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601e91:	48 01 fb             	add    %rdi,%rbx
  8041601e94:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041601e97:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041601e9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041601ea1:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041601ea7:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041601eaa:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041601eae:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041601eb1:	89 f0                	mov    %esi,%eax
  8041601eb3:	83 e0 7f             	and    $0x7f,%eax
  8041601eb6:	d3 e0                	shl    %cl,%eax
  8041601eb8:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041601ebb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041601ebe:	40 84 f6             	test   %sil,%sil
  8041601ec1:	78 e4                	js     8041601ea7 <file_name_by_info+0x223>
  return count;
  8041601ec3:	48 63 ff             	movslq %edi,%rdi
    abbrev_entry += count;
  8041601ec6:	48 01 fb             	add    %rdi,%rbx
    if (name == DW_AT_name) {
  8041601ec9:	41 83 fc 03          	cmp    $0x3,%r12d
  8041601ecd:	0f 84 63 ff ff ff    	je     8041601e36 <file_name_by_info+0x1b2>
    } else if (name == DW_AT_stmt_list) {
  8041601ed3:	41 83 fc 10          	cmp    $0x10,%r12d
  8041601ed7:	0f 84 a1 00 00 00    	je     8041601f7e <file_name_by_info+0x2fa>
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  8041601edd:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601ee3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041601ee8:	ba 00 00 00 00       	mov    $0x0,%edx
  8041601eed:	44 89 ee             	mov    %r13d,%esi
  8041601ef0:	4c 89 f7             	mov    %r14,%rdi
  8041601ef3:	41 ff d7             	callq  *%r15
    entry += count;
  8041601ef6:	48 98                	cltq   
  8041601ef8:	49 01 c6             	add    %rax,%r14
  } while (name != 0 || form != 0);
  8041601efb:	45 09 e5             	or     %r12d,%r13d
  8041601efe:	0f 85 5b ff ff ff    	jne    8041601e5f <file_name_by_info+0x1db>

  return 0;
  8041601f04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041601f09:	48 83 c4 38          	add    $0x38,%rsp
  8041601f0d:	5b                   	pop    %rbx
  8041601f0e:	41 5c                	pop    %r12
  8041601f10:	41 5d                	pop    %r13
  8041601f12:	41 5e                	pop    %r14
  8041601f14:	41 5f                	pop    %r15
  8041601f16:	5d                   	pop    %rbp
  8041601f17:	c3                   	retq   
        unsigned long offset = 0;
  8041601f18:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041601f1f:	00 
        count                = dwarf_read_abbrev_entry(
  8041601f20:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f26:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601f2b:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041601f2f:	be 0e 00 00 00       	mov    $0xe,%esi
  8041601f34:	4c 89 f7             	mov    %r14,%rdi
  8041601f37:	41 ff d7             	callq  *%r15
  8041601f3a:	41 89 c4             	mov    %eax,%r12d
        if (buf && buflen >= sizeof(const char **)) {
  8041601f3d:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8041601f41:	48 85 ff             	test   %rdi,%rdi
  8041601f44:	0f 84 0f ff ff ff    	je     8041601e59 <file_name_by_info+0x1d5>
  8041601f4a:	83 7d b4 07          	cmpl   $0x7,-0x4c(%rbp)
  8041601f4e:	0f 86 05 ff ff ff    	jbe    8041601e59 <file_name_by_info+0x1d5>
          put_unaligned(
  8041601f54:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8041601f58:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  8041601f5c:	48 03 41 40          	add    0x40(%rcx),%rax
  8041601f60:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041601f64:	ba 08 00 00 00       	mov    $0x8,%edx
  8041601f69:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041601f6d:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601f74:	00 00 00 
  8041601f77:	ff d0                	callq  *%rax
  8041601f79:	e9 db fe ff ff       	jmpq   8041601e59 <file_name_by_info+0x1d5>
      count = dwarf_read_abbrev_entry(entry, form, line_off,
  8041601f7e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041601f84:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041601f89:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8041601f8d:	44 89 ee             	mov    %r13d,%esi
  8041601f90:	4c 89 f7             	mov    %r14,%rdi
  8041601f93:	41 ff d7             	callq  *%r15
  8041601f96:	41 89 c4             	mov    %eax,%r12d
  8041601f99:	e9 bb fe ff ff       	jmpq   8041601e59 <file_name_by_info+0x1d5>
    return -E_INVAL;
  8041601f9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041601fa3:	e9 61 ff ff ff       	jmpq   8041601f09 <file_name_by_info+0x285>
  count       = 4;
  8041601fa8:	41 bd 04 00 00 00    	mov    $0x4,%r13d
    entry += count;
  8041601fae:	4d 63 ed             	movslq %r13d,%r13
  8041601fb1:	4c 01 eb             	add    %r13,%rbx
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041601fb4:	ba 02 00 00 00       	mov    $0x2,%edx
  8041601fb9:	48 89 de             	mov    %rbx,%rsi
  8041601fbc:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601fc0:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041601fc7:	00 00 00 
  8041601fca:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  8041601fcc:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  8041601fd0:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041601fd4:	83 e8 02             	sub    $0x2,%eax
  8041601fd7:	66 a9 fd ff          	test   $0xfffd,%ax
  8041601fdb:	0f 85 4c fd ff ff    	jne    8041601d2d <file_name_by_info+0xa9>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041601fe1:	ba 04 00 00 00       	mov    $0x4,%edx
  8041601fe6:	48 89 de             	mov    %rbx,%rsi
  8041601fe9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041601fed:	49 bf f7 4f 60 41 80 	movabs $0x8041604ff7,%r15
  8041601ff4:	00 00 00 
  8041601ff7:	41 ff d7             	callq  *%r15
  8041601ffa:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
  entry += count;
  8041601ffe:	4a 8d 34 2b          	lea    (%rbx,%r13,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602002:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  8041602006:	ba 01 00 00 00       	mov    $0x1,%edx
  804160200b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160200f:	41 ff d7             	callq  *%r15
  assert(address_size == 8);
  8041602012:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602016:	0f 85 46 fd ff ff    	jne    8041601d62 <file_name_by_info+0xde>
  804160201c:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  804160201f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602024:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602029:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  804160202f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602032:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602036:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602039:	89 f0                	mov    %esi,%eax
  804160203b:	83 e0 7f             	and    $0x7f,%eax
  804160203e:	d3 e0                	shl    %cl,%eax
  8041602040:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602043:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602046:	40 84 f6             	test   %sil,%sil
  8041602049:	78 e4                	js     804160202f <file_name_by_info+0x3ab>
  return count;
  804160204b:	48 63 ff             	movslq %edi,%rdi
  assert(abbrev_code != 0);
  804160204e:	45 85 c0             	test   %r8d,%r8d
  8041602051:	0f 84 40 fd ff ff    	je     8041601d97 <file_name_by_info+0x113>
  entry += count;
  8041602057:	49 01 fe             	add    %rdi,%r14
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  804160205a:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  804160205e:	4c 03 20             	add    (%rax),%r12
  8041602061:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  8041602064:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602069:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160206e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602074:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602077:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160207b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160207e:	89 f0                	mov    %esi,%eax
  8041602080:	83 e0 7f             	and    $0x7f,%eax
  8041602083:	d3 e0                	shl    %cl,%eax
  8041602085:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602088:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160208b:	40 84 f6             	test   %sil,%sil
  804160208e:	78 e4                	js     8041602074 <file_name_by_info+0x3f0>
  return count;
  8041602090:	48 63 ff             	movslq %edi,%rdi
  abbrev_entry += count;
  8041602093:	49 01 fc             	add    %rdi,%r12
  assert(table_abbrev_code == abbrev_code);
  8041602096:	45 39 c8             	cmp    %r9d,%r8d
  8041602099:	0f 85 2d fd ff ff    	jne    8041601dcc <file_name_by_info+0x148>
  804160209f:	4c 89 e2             	mov    %r12,%rdx
  count  = 0;
  80416020a2:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416020a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416020ac:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416020b2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416020b5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416020b9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416020bc:	89 f0                	mov    %esi,%eax
  80416020be:	83 e0 7f             	and    $0x7f,%eax
  80416020c1:	d3 e0                	shl    %cl,%eax
  80416020c3:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  80416020c6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416020c9:	40 84 f6             	test   %sil,%sil
  80416020cc:	78 e4                	js     80416020b2 <file_name_by_info+0x42e>
  return count;
  80416020ce:	48 63 ff             	movslq %edi,%rdi
  assert(tag == DW_TAG_compile_unit);
  80416020d1:	41 83 f8 11          	cmp    $0x11,%r8d
  80416020d5:	0f 85 26 fd ff ff    	jne    8041601e01 <file_name_by_info+0x17d>
  abbrev_entry++;
  80416020db:	49 8d 5c 3c 01       	lea    0x1(%r12,%rdi,1),%rbx
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
  80416020e0:	49 bf 49 0c 60 41 80 	movabs $0x8041600c49,%r15
  80416020e7:	00 00 00 
  80416020ea:	e9 70 fd ff ff       	jmpq   8041601e5f <file_name_by_info+0x1db>

00000080416020ef <function_by_info>:

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  80416020ef:	55                   	push   %rbp
  80416020f0:	48 89 e5             	mov    %rsp,%rbp
  80416020f3:	41 57                	push   %r15
  80416020f5:	41 56                	push   %r14
  80416020f7:	41 55                	push   %r13
  80416020f9:	41 54                	push   %r12
  80416020fb:	53                   	push   %rbx
  80416020fc:	48 83 ec 68          	sub    $0x68,%rsp
  8041602100:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  8041602104:	48 89 b5 78 ff ff ff 	mov    %rsi,-0x88(%rbp)
  804160210b:	48 89 4d 88          	mov    %rcx,-0x78(%rbp)
  804160210f:	44 89 45 a0          	mov    %r8d,-0x60(%rbp)
  8041602113:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
  const void *entry = addrs->info_begin + cu_offset;
  804160211a:	48 89 d3             	mov    %rdx,%rbx
  804160211d:	48 03 5f 20          	add    0x20(%rdi),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602121:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602126:	48 89 de             	mov    %rbx,%rsi
  8041602129:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160212d:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041602134:	00 00 00 
  8041602137:	ff d0                	callq  *%rax
  8041602139:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160213c:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160213f:	76 59                	jbe    804160219a <function_by_info+0xab>
    if (initial_len == DW_EXT_DWARF64) {
  8041602141:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602144:	74 2f                	je     8041602175 <function_by_info+0x86>
      cprintf("Unknown DWARF extension\n");
  8041602146:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  804160214d:	00 00 00 
  8041602150:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602155:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  804160215c:	00 00 00 
  804160215f:	ff d2                	callq  *%rdx
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041602161:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}
  8041602166:	48 83 c4 68          	add    $0x68,%rsp
  804160216a:	5b                   	pop    %rbx
  804160216b:	41 5c                	pop    %r12
  804160216d:	41 5d                	pop    %r13
  804160216f:	41 5e                	pop    %r14
  8041602171:	41 5f                	pop    %r15
  8041602173:	5d                   	pop    %rbp
  8041602174:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602175:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  8041602179:	ba 08 00 00 00       	mov    $0x8,%edx
  804160217e:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602182:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041602189:	00 00 00 
  804160218c:	ff d0                	callq  *%rax
  804160218e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602192:	41 be 0c 00 00 00    	mov    $0xc,%r14d
  8041602198:	eb 08                	jmp    80416021a2 <function_by_info+0xb3>
    *len = initial_len;
  804160219a:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160219c:	41 be 04 00 00 00    	mov    $0x4,%r14d
  entry += count;
  80416021a2:	4d 63 f6             	movslq %r14d,%r14
  80416021a5:	4c 01 f3             	add    %r14,%rbx
  const void *entry_end = entry + len;
  80416021a8:	48 01 d8             	add    %rbx,%rax
  80416021ab:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  80416021af:	ba 02 00 00 00       	mov    $0x2,%edx
  80416021b4:	48 89 de             	mov    %rbx,%rsi
  80416021b7:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021bb:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416021c2:	00 00 00 
  80416021c5:	ff d0                	callq  *%rax
  entry += sizeof(Dwarf_Half);
  80416021c7:	48 83 c3 02          	add    $0x2,%rbx
  assert(version == 4 || version == 2);
  80416021cb:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  80416021cf:	83 e8 02             	sub    $0x2,%eax
  80416021d2:	66 a9 fd ff          	test   $0xfffd,%ax
  80416021d6:	75 51                	jne    8041602229 <function_by_info+0x13a>
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416021d8:	ba 04 00 00 00       	mov    $0x4,%edx
  80416021dd:	48 89 de             	mov    %rbx,%rsi
  80416021e0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416021e4:	49 bc f7 4f 60 41 80 	movabs $0x8041604ff7,%r12
  80416021eb:	00 00 00 
  80416021ee:	41 ff d4             	callq  *%r12
  80416021f1:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  entry += count;
  80416021f5:	4a 8d 34 33          	lea    (%rbx,%r14,1),%rsi
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416021f9:	4c 8d 76 01          	lea    0x1(%rsi),%r14
  80416021fd:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602202:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602206:	41 ff d4             	callq  *%r12
  assert(address_size == 8);
  8041602209:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  804160220d:	75 4f                	jne    804160225e <function_by_info+0x16f>
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  804160220f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602213:	4c 03 28             	add    (%rax),%r13
  8041602216:	4c 89 6d 80          	mov    %r13,-0x80(%rbp)
        count = dwarf_read_abbrev_entry(
  804160221a:	49 bf 49 0c 60 41 80 	movabs $0x8041600c49,%r15
  8041602221:	00 00 00 
  while (entry < entry_end) {
  8041602224:	e9 07 02 00 00       	jmpq   8041602430 <function_by_info+0x341>
  assert(version == 4 || version == 2);
  8041602229:	48 b9 ee 55 60 41 80 	movabs $0x80416055ee,%rcx
  8041602230:	00 00 00 
  8041602233:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  804160223a:	00 00 00 
  804160223d:	be e6 01 00 00       	mov    $0x1e6,%esi
  8041602242:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041602249:	00 00 00 
  804160224c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602251:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041602258:	00 00 00 
  804160225b:	41 ff d0             	callq  *%r8
  assert(address_size == 8);
  804160225e:	48 b9 bb 55 60 41 80 	movabs $0x80416055bb,%rcx
  8041602265:	00 00 00 
  8041602268:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  804160226f:	00 00 00 
  8041602272:	be ea 01 00 00       	mov    $0x1ea,%esi
  8041602277:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  804160227e:	00 00 00 
  8041602281:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602286:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  804160228d:	00 00 00 
  8041602290:	41 ff d0             	callq  *%r8
           addrs->abbrev_end) { // unsafe needs to be replaced
  8041602293:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041602297:	4c 8b 50 08          	mov    0x8(%rax),%r10
    curr_abbrev_entry = abbrev_entry;
  804160229b:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
    unsigned name = 0, form = 0, tag = 0;
  804160229f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    while ((const unsigned char *)curr_abbrev_entry <
  80416022a5:	49 39 da             	cmp    %rbx,%r10
  80416022a8:	0f 86 e7 00 00 00    	jbe    8041602395 <function_by_info+0x2a6>
  80416022ae:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416022b1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  80416022b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416022bc:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416022c1:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416022c4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416022c8:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  80416022cc:	89 f8                	mov    %edi,%eax
  80416022ce:	83 e0 7f             	and    $0x7f,%eax
  80416022d1:	d3 e0                	shl    %cl,%eax
  80416022d3:	09 c6                	or     %eax,%esi
    shift += 7;
  80416022d5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416022d8:	40 84 ff             	test   %dil,%dil
  80416022db:	78 e4                	js     80416022c1 <function_by_info+0x1d2>
  return count;
  80416022dd:	4d 63 c0             	movslq %r8d,%r8
      curr_abbrev_entry += count;
  80416022e0:	4c 01 c3             	add    %r8,%rbx
  80416022e3:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416022e6:	41 bb 00 00 00 00    	mov    $0x0,%r11d
  shift  = 0;
  80416022ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416022f1:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  80416022f7:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  80416022fa:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416022fe:	41 83 c3 01          	add    $0x1,%r11d
    result |= (byte & 0x7f) << shift;
  8041602302:	89 f8                	mov    %edi,%eax
  8041602304:	83 e0 7f             	and    $0x7f,%eax
  8041602307:	d3 e0                	shl    %cl,%eax
  8041602309:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  804160230c:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160230f:	40 84 ff             	test   %dil,%dil
  8041602312:	78 e3                	js     80416022f7 <function_by_info+0x208>
  return count;
  8041602314:	4d 63 db             	movslq %r11d,%r11
      curr_abbrev_entry++;
  8041602317:	4a 8d 5c 1b 01       	lea    0x1(%rbx,%r11,1),%rbx
      if (table_abbrev_code == abbrev_code) {
  804160231c:	41 39 f1             	cmp    %esi,%r9d
  804160231f:	74 74                	je     8041602395 <function_by_info+0x2a6>
  result = 0;
  8041602321:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602324:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602329:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  804160232e:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602334:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602337:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160233b:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  804160233e:	89 f0                	mov    %esi,%eax
  8041602340:	83 e0 7f             	and    $0x7f,%eax
  8041602343:	d3 e0                	shl    %cl,%eax
  8041602345:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602348:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  804160234b:	40 84 f6             	test   %sil,%sil
  804160234e:	78 e4                	js     8041602334 <function_by_info+0x245>
  return count;
  8041602350:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602353:	48 01 fb             	add    %rdi,%rbx
  8041602356:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602359:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  804160235e:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602363:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602369:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  804160236c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602370:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602373:	89 f0                	mov    %esi,%eax
  8041602375:	83 e0 7f             	and    $0x7f,%eax
  8041602378:	d3 e0                	shl    %cl,%eax
  804160237a:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  804160237d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602380:	40 84 f6             	test   %sil,%sil
  8041602383:	78 e4                	js     8041602369 <function_by_info+0x27a>
  return count;
  8041602385:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602388:	48 01 fb             	add    %rdi,%rbx
      } while (name != 0 || form != 0);
  804160238b:	45 09 dc             	or     %r11d,%r12d
  804160238e:	75 91                	jne    8041602321 <function_by_info+0x232>
  8041602390:	e9 10 ff ff ff       	jmpq   80416022a5 <function_by_info+0x1b6>
    if (tag == DW_TAG_subprogram) {
  8041602395:	41 83 f8 2e          	cmp    $0x2e,%r8d
  8041602399:	0f 84 e9 00 00 00    	je     8041602488 <function_by_info+0x399>
            fn_name_entry = entry;
  804160239f:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023a2:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416023a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023ac:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  80416023b2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416023b5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023b9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416023bc:	89 f0                	mov    %esi,%eax
  80416023be:	83 e0 7f             	and    $0x7f,%eax
  80416023c1:	d3 e0                	shl    %cl,%eax
  80416023c3:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  80416023c6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023c9:	40 84 f6             	test   %sil,%sil
  80416023cc:	78 e4                	js     80416023b2 <function_by_info+0x2c3>
  return count;
  80416023ce:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416023d1:	48 01 fb             	add    %rdi,%rbx
  80416023d4:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416023d7:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416023dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416023e1:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416023e7:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416023ea:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416023ee:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416023f1:	89 f0                	mov    %esi,%eax
  80416023f3:	83 e0 7f             	and    $0x7f,%eax
  80416023f6:	d3 e0                	shl    %cl,%eax
  80416023f8:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416023fb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416023fe:	40 84 f6             	test   %sil,%sil
  8041602401:	78 e4                	js     80416023e7 <function_by_info+0x2f8>
  return count;
  8041602403:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  8041602406:	48 01 fb             	add    %rdi,%rbx
        count = dwarf_read_abbrev_entry(
  8041602409:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160240f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602414:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602419:	44 89 e6             	mov    %r12d,%esi
  804160241c:	4c 89 f7             	mov    %r14,%rdi
  804160241f:	41 ff d7             	callq  *%r15
        entry += count;
  8041602422:	48 98                	cltq   
  8041602424:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  8041602427:	45 09 ec             	or     %r13d,%r12d
  804160242a:	0f 85 6f ff ff ff    	jne    804160239f <function_by_info+0x2b0>
  while (entry < entry_end) {
  8041602430:	4c 3b 75 90          	cmp    -0x70(%rbp),%r14
  8041602434:	0f 83 37 02 00 00    	jae    8041602671 <function_by_info+0x582>
                 uintptr_t *offset) {
  804160243a:	4c 89 f2             	mov    %r14,%rdx
  count  = 0;
  804160243d:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602442:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602447:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  804160244d:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602450:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602454:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602457:	89 f0                	mov    %esi,%eax
  8041602459:	83 e0 7f             	and    $0x7f,%eax
  804160245c:	d3 e0                	shl    %cl,%eax
  804160245e:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602461:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602464:	40 84 f6             	test   %sil,%sil
  8041602467:	78 e4                	js     804160244d <function_by_info+0x35e>
  return count;
  8041602469:	48 63 ff             	movslq %edi,%rdi
    entry += count;
  804160246c:	49 01 fe             	add    %rdi,%r14
    if (abbrev_code == 0) {
  804160246f:	45 85 c9             	test   %r9d,%r9d
  8041602472:	0f 85 1b fe ff ff    	jne    8041602293 <function_by_info+0x1a4>
  while (entry < entry_end) {
  8041602478:	4c 39 75 90          	cmp    %r14,-0x70(%rbp)
  804160247c:	77 bc                	ja     804160243a <function_by_info+0x34b>
  return 0;
  804160247e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602483:	e9 de fc ff ff       	jmpq   8041602166 <function_by_info+0x77>
      uintptr_t low_pc = 0, high_pc = 0;
  8041602488:	48 c7 45 b0 00 00 00 	movq   $0x0,-0x50(%rbp)
  804160248f:	00 
  8041602490:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8041602497:	00 
      unsigned name_form        = 0;
  8041602498:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%rbp)
      const void *fn_name_entry = 0;
  804160249f:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80416024a6:	00 
  80416024a7:	eb 1d                	jmp    80416024c6 <function_by_info+0x3d7>
          count = dwarf_read_abbrev_entry(
  80416024a9:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416024af:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416024b4:	48 8d 55 b0          	lea    -0x50(%rbp),%rdx
  80416024b8:	44 89 ee             	mov    %r13d,%esi
  80416024bb:	4c 89 f7             	mov    %r14,%rdi
  80416024be:	41 ff d7             	callq  *%r15
        entry += count;
  80416024c1:	48 98                	cltq   
  80416024c3:	49 01 c6             	add    %rax,%r14
      const void *fn_name_entry = 0;
  80416024c6:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024c9:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  80416024ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  80416024d3:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  80416024d9:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  80416024dc:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416024e0:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  80416024e3:	89 f0                	mov    %esi,%eax
  80416024e5:	83 e0 7f             	and    $0x7f,%eax
  80416024e8:	d3 e0                	shl    %cl,%eax
  80416024ea:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  80416024ed:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416024f0:	40 84 f6             	test   %sil,%sil
  80416024f3:	78 e4                	js     80416024d9 <function_by_info+0x3ea>
  return count;
  80416024f5:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  80416024f8:	48 01 fb             	add    %rdi,%rbx
  80416024fb:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  80416024fe:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602503:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602508:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  804160250e:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602511:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602515:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602518:	89 f0                	mov    %esi,%eax
  804160251a:	83 e0 7f             	and    $0x7f,%eax
  804160251d:	d3 e0                	shl    %cl,%eax
  804160251f:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602522:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602525:	40 84 f6             	test   %sil,%sil
  8041602528:	78 e4                	js     804160250e <function_by_info+0x41f>
  return count;
  804160252a:	48 63 ff             	movslq %edi,%rdi
        curr_abbrev_entry += count;
  804160252d:	48 01 fb             	add    %rdi,%rbx
        if (name == DW_AT_low_pc) {
  8041602530:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602534:	0f 84 6f ff ff ff    	je     80416024a9 <function_by_info+0x3ba>
        } else if (name == DW_AT_high_pc) {
  804160253a:	41 83 fc 12          	cmp    $0x12,%r12d
  804160253e:	0f 84 99 00 00 00    	je     80416025dd <function_by_info+0x4ee>
    result |= (byte & 0x7f) << shift;
  8041602544:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602548:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  804160254b:	41 0f 44 c5          	cmove  %r13d,%eax
  804160254f:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  8041602552:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602556:	49 0f 44 c6          	cmove  %r14,%rax
  804160255a:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
          count = dwarf_read_abbrev_entry(
  804160255e:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602564:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602569:	ba 00 00 00 00       	mov    $0x0,%edx
  804160256e:	44 89 ee             	mov    %r13d,%esi
  8041602571:	4c 89 f7             	mov    %r14,%rdi
  8041602574:	41 ff d7             	callq  *%r15
        entry += count;
  8041602577:	48 98                	cltq   
  8041602579:	49 01 c6             	add    %rax,%r14
      } while (name != 0 || form != 0);
  804160257c:	45 09 e5             	or     %r12d,%r13d
  804160257f:	0f 85 41 ff ff ff    	jne    80416024c6 <function_by_info+0x3d7>
      if (p >= low_pc && p <= high_pc) {
  8041602585:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602589:	48 8b 9d 78 ff ff ff 	mov    -0x88(%rbp),%rbx
  8041602590:	48 39 d8             	cmp    %rbx,%rax
  8041602593:	0f 87 97 fe ff ff    	ja     8041602430 <function_by_info+0x341>
  8041602599:	48 39 5d b8          	cmp    %rbx,-0x48(%rbp)
  804160259d:	0f 82 8d fe ff ff    	jb     8041602430 <function_by_info+0x341>
        *offset = low_pc;
  80416025a3:	48 8b 9d 70 ff ff ff 	mov    -0x90(%rbp),%rbx
  80416025aa:	48 89 03             	mov    %rax,(%rbx)
        if (name_form == DW_FORM_strp) {
  80416025ad:	83 7d a4 0e          	cmpl   $0xe,-0x5c(%rbp)
  80416025b1:	74 59                	je     804160260c <function_by_info+0x51d>
          count = dwarf_read_abbrev_entry(
  80416025b3:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416025b9:	8b 4d a0             	mov    -0x60(%rbp),%ecx
  80416025bc:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  80416025c0:	8b 75 a4             	mov    -0x5c(%rbp),%esi
  80416025c3:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  80416025c7:	48 b8 49 0c 60 41 80 	movabs $0x8041600c49,%rax
  80416025ce:	00 00 00 
  80416025d1:	ff d0                	callq  *%rax
        return 0;
  80416025d3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416025d8:	e9 89 fb ff ff       	jmpq   8041602166 <function_by_info+0x77>
          count = dwarf_read_abbrev_entry(
  80416025dd:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416025e3:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416025e8:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  80416025ec:	44 89 ee             	mov    %r13d,%esi
  80416025ef:	4c 89 f7             	mov    %r14,%rdi
  80416025f2:	41 ff d7             	callq  *%r15
          if (form != DW_FORM_addr) {
  80416025f5:	41 83 fd 01          	cmp    $0x1,%r13d
  80416025f9:	0f 84 c2 fe ff ff    	je     80416024c1 <function_by_info+0x3d2>
            high_pc += low_pc;
  80416025ff:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8041602603:	48 01 55 b8          	add    %rdx,-0x48(%rbp)
  8041602607:	e9 b5 fe ff ff       	jmpq   80416024c1 <function_by_info+0x3d2>
          unsigned long str_offset = 0;
  804160260c:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602613:	00 
          count                    = dwarf_read_abbrev_entry(
  8041602614:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  804160261a:	b9 08 00 00 00       	mov    $0x8,%ecx
  804160261f:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602623:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602628:	48 8b 7d a8          	mov    -0x58(%rbp),%rdi
  804160262c:	48 b8 49 0c 60 41 80 	movabs $0x8041600c49,%rax
  8041602633:	00 00 00 
  8041602636:	ff d0                	callq  *%rax
          if (buf &&
  8041602638:	48 8b 7d 88          	mov    -0x78(%rbp),%rdi
  804160263c:	48 85 ff             	test   %rdi,%rdi
  804160263f:	74 92                	je     80416025d3 <function_by_info+0x4e4>
  8041602641:	83 7d a0 07          	cmpl   $0x7,-0x60(%rbp)
  8041602645:	76 8c                	jbe    80416025d3 <function_by_info+0x4e4>
            put_unaligned(
  8041602647:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160264b:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  804160264f:	48 03 43 40          	add    0x40(%rbx),%rax
  8041602653:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8041602657:	ba 08 00 00 00       	mov    $0x8,%edx
  804160265c:	48 8d 75 c8          	lea    -0x38(%rbp),%rsi
  8041602660:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041602667:	00 00 00 
  804160266a:	ff d0                	callq  *%rax
  804160266c:	e9 62 ff ff ff       	jmpq   80416025d3 <function_by_info+0x4e4>
  return 0;
  8041602671:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602676:	e9 eb fa ff ff       	jmpq   8041602166 <function_by_info+0x77>

000000804160267b <address_by_fname>:

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  804160267b:	55                   	push   %rbp
  804160267c:	48 89 e5             	mov    %rsp,%rbp
  804160267f:	41 57                	push   %r15
  8041602681:	41 56                	push   %r14
  8041602683:	41 55                	push   %r13
  8041602685:	41 54                	push   %r12
  8041602687:	53                   	push   %rbx
  8041602688:	48 83 ec 38          	sub    $0x38,%rsp
  804160268c:	49 89 ff             	mov    %rdi,%r15
  804160268f:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  8041602693:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  const int flen = strlen(fname);
  8041602697:	48 89 f7             	mov    %rsi,%rdi
  804160269a:	48 b8 7e 4d 60 41 80 	movabs $0x8041604d7e,%rax
  80416026a1:	00 00 00 
  80416026a4:	ff d0                	callq  *%rax
  80416026a6:	89 c3                	mov    %eax,%ebx
  if (flen == 0)
  80416026a8:	85 c0                	test   %eax,%eax
  80416026aa:	74 62                	je     804160270e <address_by_fname+0x93>
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  80416026ac:	4d 8b 67 50          	mov    0x50(%r15),%r12
  initial_len = get_unaligned(addr, uint32_t);
  80416026b0:	49 be f7 4f 60 41 80 	movabs $0x8041604ff7,%r14
  80416026b7:	00 00 00 
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
  80416026ba:	49 bf 8d 4e 60 41 80 	movabs $0x8041604e8d,%r15
  80416026c1:	00 00 00 
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
  80416026c4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416026c8:	4c 39 60 58          	cmp    %r12,0x58(%rax)
  80416026cc:	0f 86 91 02 00 00    	jbe    8041602963 <address_by_fname+0x2e8>
  80416026d2:	ba 04 00 00 00       	mov    $0x4,%edx
  80416026d7:	4c 89 e6             	mov    %r12,%rsi
  80416026da:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416026de:	41 ff d6             	callq  *%r14
  80416026e1:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416026e4:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416026e7:	76 52                	jbe    804160273b <address_by_fname+0xc0>
    if (initial_len == DW_EXT_DWARF64) {
  80416026e9:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416026ec:	74 31                	je     804160271f <address_by_fname+0xa4>
      cprintf("Unknown DWARF extension\n");
  80416026ee:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  80416026f5:	00 00 00 
  80416026f8:	b8 00 00 00 00       	mov    $0x0,%eax
  80416026fd:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041602704:	00 00 00 
  8041602707:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602709:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
      }
      pubnames_entry += strlen(pubnames_entry) + 1;
    }
  }
  return 0;
}
  804160270e:	89 d8                	mov    %ebx,%eax
  8041602710:	48 83 c4 38          	add    $0x38,%rsp
  8041602714:	5b                   	pop    %rbx
  8041602715:	41 5c                	pop    %r12
  8041602717:	41 5d                	pop    %r13
  8041602719:	41 5e                	pop    %r14
  804160271b:	41 5f                	pop    %r15
  804160271d:	5d                   	pop    %rbp
  804160271e:	c3                   	retq   
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  804160271f:	49 8d 74 24 20       	lea    0x20(%r12),%rsi
  8041602724:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602729:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160272d:	41 ff d6             	callq  *%r14
  8041602730:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602734:	ba 0c 00 00 00       	mov    $0xc,%edx
  8041602739:	eb 07                	jmp    8041602742 <address_by_fname+0xc7>
    *len = initial_len;
  804160273b:	89 c0                	mov    %eax,%eax
  count       = 4;
  804160273d:	ba 04 00 00 00       	mov    $0x4,%edx
    pubnames_entry += count;
  8041602742:	48 63 d2             	movslq %edx,%rdx
  8041602745:	49 01 d4             	add    %rdx,%r12
    const void *pubnames_entry_end = pubnames_entry + len;
  8041602748:	4c 01 e0             	add    %r12,%rax
  804160274b:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
  804160274f:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602754:	4c 89 e6             	mov    %r12,%rsi
  8041602757:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160275b:	41 ff d6             	callq  *%r14
    pubnames_entry += sizeof(Dwarf_Half);
  804160275e:	49 8d 74 24 02       	lea    0x2(%r12),%rsi
    assert(version == 2);
  8041602763:	66 83 7d c8 02       	cmpw   $0x2,-0x38(%rbp)
  8041602768:	0f 85 be 00 00 00    	jne    804160282c <address_by_fname+0x1b1>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160276e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602773:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602777:	41 ff d6             	callq  *%r14
  804160277a:	8b 45 c8             	mov    -0x38(%rbp),%eax
  804160277d:	89 45 a4             	mov    %eax,-0x5c(%rbp)
    pubnames_entry += sizeof(uint32_t);
  8041602780:	49 8d 5c 24 06       	lea    0x6(%r12),%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041602785:	ba 04 00 00 00       	mov    $0x4,%edx
  804160278a:	48 89 de             	mov    %rbx,%rsi
  804160278d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602791:	41 ff d6             	callq  *%r14
  8041602794:	8b 55 c8             	mov    -0x38(%rbp),%edx
  count       = 4;
  8041602797:	b8 04 00 00 00       	mov    $0x4,%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160279c:	83 fa ef             	cmp    $0xffffffef,%edx
  804160279f:	76 29                	jbe    80416027ca <address_by_fname+0x14f>
    if (initial_len == DW_EXT_DWARF64) {
  80416027a1:	83 fa ff             	cmp    $0xffffffff,%edx
  80416027a4:	0f 84 b7 00 00 00    	je     8041602861 <address_by_fname+0x1e6>
      cprintf("Unknown DWARF extension\n");
  80416027aa:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  80416027b1:	00 00 00 
  80416027b4:	b8 00 00 00 00       	mov    $0x0,%eax
  80416027b9:	48 be 70 3f 60 41 80 	movabs $0x8041603f70,%rsi
  80416027c0:	00 00 00 
  80416027c3:	ff d6                	callq  *%rsi
      count = 0;
  80416027c5:	b8 00 00 00 00       	mov    $0x0,%eax
    pubnames_entry += count;
  80416027ca:	48 98                	cltq   
  80416027cc:	4c 8d 24 03          	lea    (%rbx,%rax,1),%r12
    while (pubnames_entry < pubnames_entry_end) {
  80416027d0:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  80416027d4:	0f 86 ea fe ff ff    	jbe    80416026c4 <address_by_fname+0x49>
      func_offset = get_unaligned(pubnames_entry, uint32_t);
  80416027da:	ba 04 00 00 00       	mov    $0x4,%edx
  80416027df:	4c 89 e6             	mov    %r12,%rsi
  80416027e2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416027e6:	41 ff d6             	callq  *%r14
  80416027e9:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
      pubnames_entry += sizeof(uint32_t);
  80416027ed:	49 83 c4 04          	add    $0x4,%r12
      if (func_offset == 0) {
  80416027f1:	4d 85 ed             	test   %r13,%r13
  80416027f4:	0f 84 ca fe ff ff    	je     80416026c4 <address_by_fname+0x49>
      if (!strcmp(fname, pubnames_entry)) {
  80416027fa:	4c 89 e6             	mov    %r12,%rsi
  80416027fd:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  8041602801:	41 ff d7             	callq  *%r15
  8041602804:	89 c3                	mov    %eax,%ebx
  8041602806:	85 c0                	test   %eax,%eax
  8041602808:	74 72                	je     804160287c <address_by_fname+0x201>
      pubnames_entry += strlen(pubnames_entry) + 1;
  804160280a:	4c 89 e7             	mov    %r12,%rdi
  804160280d:	48 b8 7e 4d 60 41 80 	movabs $0x8041604d7e,%rax
  8041602814:	00 00 00 
  8041602817:	ff d0                	callq  *%rax
  8041602819:	83 c0 01             	add    $0x1,%eax
  804160281c:	48 98                	cltq   
  804160281e:	49 01 c4             	add    %rax,%r12
    while (pubnames_entry < pubnames_entry_end) {
  8041602821:	4c 39 65 b8          	cmp    %r12,-0x48(%rbp)
  8041602825:	77 b3                	ja     80416027da <address_by_fname+0x15f>
  8041602827:	e9 98 fe ff ff       	jmpq   80416026c4 <address_by_fname+0x49>
    assert(version == 2);
  804160282c:	48 b9 fe 55 60 41 80 	movabs $0x80416055fe,%rcx
  8041602833:	00 00 00 
  8041602836:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  804160283d:	00 00 00 
  8041602840:	be 73 02 00 00       	mov    $0x273,%esi
  8041602845:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  804160284c:	00 00 00 
  804160284f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602854:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  804160285b:	00 00 00 
  804160285e:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602861:	49 8d 74 24 26       	lea    0x26(%r12),%rsi
  8041602866:	ba 08 00 00 00       	mov    $0x8,%edx
  804160286b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160286f:	41 ff d6             	callq  *%r14
      count = 12;
  8041602872:	b8 0c 00 00 00       	mov    $0xc,%eax
  8041602877:	e9 4e ff ff ff       	jmpq   80416027ca <address_by_fname+0x14f>
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
  804160287c:	44 8b 75 a4          	mov    -0x5c(%rbp),%r14d
        const void *entry      = addrs->info_begin + cu_offset;
  8041602880:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602884:	4c 03 70 20          	add    0x20(%rax),%r14
        const void *func_entry = entry + func_offset;
  8041602888:	4d 01 f5             	add    %r14,%r13
  initial_len = get_unaligned(addr, uint32_t);
  804160288b:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602890:	4c 89 f6             	mov    %r14,%rsi
  8041602893:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602897:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  804160289e:	00 00 00 
  80416028a1:	ff d0                	callq  *%rax
  80416028a3:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  80416028a6:	83 f8 ef             	cmp    $0xffffffef,%eax
  80416028a9:	0f 86 be 00 00 00    	jbe    804160296d <address_by_fname+0x2f2>
    if (initial_len == DW_EXT_DWARF64) {
  80416028af:	83 f8 ff             	cmp    $0xffffffff,%eax
  80416028b2:	74 25                	je     80416028d9 <address_by_fname+0x25e>
      cprintf("Unknown DWARF extension\n");
  80416028b4:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  80416028bb:	00 00 00 
  80416028be:	b8 00 00 00 00       	mov    $0x0,%eax
  80416028c3:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  80416028ca:	00 00 00 
  80416028cd:	ff d2                	callq  *%rdx
          return -E_BAD_DWARF;
  80416028cf:	bb fa ff ff ff       	mov    $0xfffffffa,%ebx
  80416028d4:	e9 35 fe ff ff       	jmpq   804160270e <address_by_fname+0x93>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416028d9:	49 8d 76 20          	lea    0x20(%r14),%rsi
  80416028dd:	ba 08 00 00 00       	mov    $0x8,%edx
  80416028e2:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416028e6:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416028ed:	00 00 00 
  80416028f0:	ff d0                	callq  *%rax
      count = 12;
  80416028f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416028f7:	eb 79                	jmp    8041602972 <address_by_fname+0x2f7>
        assert(version == 4 || version == 2);
  80416028f9:	48 b9 ee 55 60 41 80 	movabs $0x80416055ee,%rcx
  8041602900:	00 00 00 
  8041602903:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  804160290a:	00 00 00 
  804160290d:	be 89 02 00 00       	mov    $0x289,%esi
  8041602912:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041602919:	00 00 00 
  804160291c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602921:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041602928:	00 00 00 
  804160292b:	41 ff d0             	callq  *%r8
        assert(address_size == 8);
  804160292e:	48 b9 bb 55 60 41 80 	movabs $0x80416055bb,%rcx
  8041602935:	00 00 00 
  8041602938:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  804160293f:	00 00 00 
  8041602942:	be 8e 02 00 00       	mov    $0x28e,%esi
  8041602947:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  804160294e:	00 00 00 
  8041602951:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602956:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  804160295d:	00 00 00 
  8041602960:	41 ff d0             	callq  *%r8
  return 0;
  8041602963:	bb 00 00 00 00       	mov    $0x0,%ebx
  8041602968:	e9 a1 fd ff ff       	jmpq   804160270e <address_by_fname+0x93>
  count       = 4;
  804160296d:	b8 04 00 00 00       	mov    $0x4,%eax
        entry += count;
  8041602972:	48 98                	cltq   
  8041602974:	49 01 c6             	add    %rax,%r14
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602977:	ba 02 00 00 00       	mov    $0x2,%edx
  804160297c:	4c 89 f6             	mov    %r14,%rsi
  804160297f:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602983:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  804160298a:	00 00 00 
  804160298d:	ff d0                	callq  *%rax
        entry += sizeof(Dwarf_Half);
  804160298f:	49 8d 76 02          	lea    0x2(%r14),%rsi
        assert(version == 4 || version == 2);
  8041602993:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602997:	83 e8 02             	sub    $0x2,%eax
  804160299a:	66 a9 fd ff          	test   $0xfffd,%ax
  804160299e:	0f 85 55 ff ff ff    	jne    80416028f9 <address_by_fname+0x27e>
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  80416029a4:	ba 04 00 00 00       	mov    $0x4,%edx
  80416029a9:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029ad:	49 bf f7 4f 60 41 80 	movabs $0x8041604ff7,%r15
  80416029b4:	00 00 00 
  80416029b7:	41 ff d7             	callq  *%r15
  80416029ba:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
  80416029be:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80416029c2:	4c 03 20             	add    (%rax),%r12
        entry += sizeof(uint32_t);
  80416029c5:	49 8d 76 06          	lea    0x6(%r14),%rsi
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  80416029c9:	ba 01 00 00 00       	mov    $0x1,%edx
  80416029ce:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416029d2:	41 ff d7             	callq  *%r15
        assert(address_size == 8);
  80416029d5:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  80416029d9:	0f 85 4f ff ff ff    	jne    804160292e <address_by_fname+0x2b3>
  shift  = 0;
  80416029df:	89 d9                	mov    %ebx,%ecx
  result = 0;
  80416029e1:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  80416029e6:	41 0f b6 55 00       	movzbl 0x0(%r13),%edx
    addr++;
  80416029eb:	49 83 c5 01          	add    $0x1,%r13
    result |= (byte & 0x7f) << shift;
  80416029ef:	89 d0                	mov    %edx,%eax
  80416029f1:	83 e0 7f             	and    $0x7f,%eax
  80416029f4:	d3 e0                	shl    %cl,%eax
  80416029f6:	09 c6                	or     %eax,%esi
    shift += 7;
  80416029f8:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  80416029fb:	84 d2                	test   %dl,%dl
  80416029fd:	78 e7                	js     80416029e6 <address_by_fname+0x36b>
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
  80416029ff:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8041602a03:	4c 8b 40 08          	mov    0x8(%rax),%r8
  8041602a07:	4d 39 e0             	cmp    %r12,%r8
  8041602a0a:	0f 86 fe fc ff ff    	jbe    804160270e <address_by_fname+0x93>
  count  = 0;
  8041602a10:	41 89 d9             	mov    %ebx,%r9d
  shift  = 0;
  8041602a13:	89 d9                	mov    %ebx,%ecx
  8041602a15:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a18:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602a1e:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602a21:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a25:	41 83 c1 01          	add    $0x1,%r9d
    result |= (byte & 0x7f) << shift;
  8041602a29:	89 f8                	mov    %edi,%eax
  8041602a2b:	83 e0 7f             	and    $0x7f,%eax
  8041602a2e:	d3 e0                	shl    %cl,%eax
  8041602a30:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602a33:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a36:	40 84 ff             	test   %dil,%dil
  8041602a39:	78 e3                	js     8041602a1e <address_by_fname+0x3a3>
  return count;
  8041602a3b:	4d 63 c9             	movslq %r9d,%r9
          abbrev_entry += count;
  8041602a3e:	4d 01 cc             	add    %r9,%r12
  count  = 0;
  8041602a41:	89 da                	mov    %ebx,%edx
  8041602a43:	4c 89 e0             	mov    %r12,%rax
    byte = *addr;
  8041602a46:	0f b6 08             	movzbl (%rax),%ecx
    addr++;
  8041602a49:	48 83 c0 01          	add    $0x1,%rax
    count++;
  8041602a4d:	83 c2 01             	add    $0x1,%edx
    if (!(byte & 0x80))
  8041602a50:	84 c9                	test   %cl,%cl
  8041602a52:	78 f2                	js     8041602a46 <address_by_fname+0x3cb>
  return count;
  8041602a54:	48 63 d2             	movslq %edx,%rdx
          abbrev_entry++;
  8041602a57:	4d 8d 64 14 01       	lea    0x1(%r12,%rdx,1),%r12
          if (table_abbrev_code == abbrev_code) {
  8041602a5c:	44 39 d6             	cmp    %r10d,%esi
  8041602a5f:	0f 84 a9 fc ff ff    	je     804160270e <address_by_fname+0x93>
  count  = 0;
  8041602a65:	41 89 da             	mov    %ebx,%r10d
  shift  = 0;
  8041602a68:	89 d9                	mov    %ebx,%ecx
  8041602a6a:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a6d:	bf 00 00 00 00       	mov    $0x0,%edi
    byte = *addr;
  8041602a72:	44 0f b6 0a          	movzbl (%rdx),%r9d
    addr++;
  8041602a76:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602a7a:	41 83 c2 01          	add    $0x1,%r10d
    result |= (byte & 0x7f) << shift;
  8041602a7e:	44 89 c8             	mov    %r9d,%eax
  8041602a81:	83 e0 7f             	and    $0x7f,%eax
  8041602a84:	d3 e0                	shl    %cl,%eax
  8041602a86:	09 c7                	or     %eax,%edi
    shift += 7;
  8041602a88:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602a8b:	45 84 c9             	test   %r9b,%r9b
  8041602a8e:	78 e2                	js     8041602a72 <address_by_fname+0x3f7>
  return count;
  8041602a90:	4d 63 d2             	movslq %r10d,%r10
            abbrev_entry += count;
  8041602a93:	4d 01 d4             	add    %r10,%r12
  count  = 0;
  8041602a96:	41 89 da             	mov    %ebx,%r10d
  shift  = 0;
  8041602a99:	89 d9                	mov    %ebx,%ecx
  8041602a9b:	4c 89 e2             	mov    %r12,%rdx
  result = 0;
  8041602a9e:	41 bb 00 00 00 00    	mov    $0x0,%r11d
    byte = *addr;
  8041602aa4:	44 0f b6 0a          	movzbl (%rdx),%r9d
    addr++;
  8041602aa8:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602aac:	41 83 c2 01          	add    $0x1,%r10d
    result |= (byte & 0x7f) << shift;
  8041602ab0:	44 89 c8             	mov    %r9d,%eax
  8041602ab3:	83 e0 7f             	and    $0x7f,%eax
  8041602ab6:	d3 e0                	shl    %cl,%eax
  8041602ab8:	41 09 c3             	or     %eax,%r11d
    shift += 7;
  8041602abb:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602abe:	45 84 c9             	test   %r9b,%r9b
  8041602ac1:	78 e1                	js     8041602aa4 <address_by_fname+0x429>
  return count;
  8041602ac3:	4d 63 d2             	movslq %r10d,%r10
            abbrev_entry += count;
  8041602ac6:	4d 01 d4             	add    %r10,%r12
          } while (name != 0 || form != 0);
  8041602ac9:	41 09 fb             	or     %edi,%r11d
  8041602acc:	75 97                	jne    8041602a65 <address_by_fname+0x3ea>
  8041602ace:	e9 34 ff ff ff       	jmpq   8041602a07 <address_by_fname+0x38c>

0000008041602ad3 <naive_address_by_fname>:

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  8041602ad3:	55                   	push   %rbp
  8041602ad4:	48 89 e5             	mov    %rsp,%rbp
  8041602ad7:	41 57                	push   %r15
  8041602ad9:	41 56                	push   %r14
  8041602adb:	41 55                	push   %r13
  8041602add:	41 54                	push   %r12
  8041602adf:	53                   	push   %rbx
  8041602ae0:	48 83 ec 48          	sub    $0x48,%rsp
  8041602ae4:	48 89 fb             	mov    %rdi,%rbx
  8041602ae7:	48 89 7d b0          	mov    %rdi,-0x50(%rbp)
  8041602aeb:	48 89 f7             	mov    %rsi,%rdi
  8041602aee:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  8041602af2:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  const int flen = strlen(fname);
  8041602af6:	48 b8 7e 4d 60 41 80 	movabs $0x8041604d7e,%rax
  8041602afd:	00 00 00 
  8041602b00:	ff d0                	callq  *%rax
  if (flen == 0)
  8041602b02:	85 c0                	test   %eax,%eax
  8041602b04:	0f 84 73 03 00 00    	je     8041602e7d <naive_address_by_fname+0x3aa>
    return 0;
  const void *entry = addrs->info_begin;
  8041602b0a:	4c 8b 7b 20          	mov    0x20(%rbx),%r15
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602b0e:	e9 0f 03 00 00       	jmpq   8041602e22 <naive_address_by_fname+0x34f>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041602b13:	49 8d 77 20          	lea    0x20(%r15),%rsi
  8041602b17:	ba 08 00 00 00       	mov    $0x8,%edx
  8041602b1c:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b20:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041602b27:	00 00 00 
  8041602b2a:	ff d0                	callq  *%rax
  8041602b2c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  8041602b30:	bb 0c 00 00 00       	mov    $0xc,%ebx
  8041602b35:	eb 07                	jmp    8041602b3e <naive_address_by_fname+0x6b>
    *len = initial_len;
  8041602b37:	89 c0                	mov    %eax,%eax
  count       = 4;
  8041602b39:	bb 04 00 00 00       	mov    $0x4,%ebx
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
  8041602b3e:	48 63 db             	movslq %ebx,%rbx
  8041602b41:	4d 8d 2c 1f          	lea    (%r15,%rbx,1),%r13
    const void *entry_end = entry + len;
  8041602b45:	4c 01 e8             	add    %r13,%rax
  8041602b48:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  8041602b4c:	ba 02 00 00 00       	mov    $0x2,%edx
  8041602b51:	4c 89 ee             	mov    %r13,%rsi
  8041602b54:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b58:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041602b5f:	00 00 00 
  8041602b62:	ff d0                	callq  *%rax
    entry += sizeof(Dwarf_Half);
  8041602b64:	49 83 c5 02          	add    $0x2,%r13
    assert(version == 4 || version == 2);
  8041602b68:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041602b6c:	83 e8 02             	sub    $0x2,%eax
  8041602b6f:	66 a9 fd ff          	test   $0xfffd,%ax
  8041602b73:	75 52                	jne    8041602bc7 <naive_address_by_fname+0xf4>
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  8041602b75:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602b7a:	4c 89 ee             	mov    %r13,%rsi
  8041602b7d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602b81:	49 be f7 4f 60 41 80 	movabs $0x8041604ff7,%r14
  8041602b88:	00 00 00 
  8041602b8b:	41 ff d6             	callq  *%r14
  8041602b8e:	44 8b 65 c8          	mov    -0x38(%rbp),%r12d
    entry += count;
  8041602b92:	49 8d 74 1d 00       	lea    0x0(%r13,%rbx,1),%rsi
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  8041602b97:	4c 8d 7e 01          	lea    0x1(%rsi),%r15
  8041602b9b:	ba 01 00 00 00       	mov    $0x1,%edx
  8041602ba0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602ba4:	41 ff d6             	callq  *%r14
    assert(address_size == 8);
  8041602ba7:	80 7d c8 08          	cmpb   $0x8,-0x38(%rbp)
  8041602bab:	75 4f                	jne    8041602bfc <naive_address_by_fname+0x129>
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  8041602bad:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602bb1:	4c 03 20             	add    (%rax),%r12
  8041602bb4:	4c 89 65 98          	mov    %r12,-0x68(%rbp)
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
  8041602bb8:	49 be 49 0c 60 41 80 	movabs $0x8041600c49,%r14
  8041602bbf:	00 00 00 
    while (entry < entry_end) {
  8041602bc2:	e9 11 02 00 00       	jmpq   8041602dd8 <naive_address_by_fname+0x305>
    assert(version == 4 || version == 2);
  8041602bc7:	48 b9 ee 55 60 41 80 	movabs $0x80416055ee,%rcx
  8041602bce:	00 00 00 
  8041602bd1:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041602bd8:	00 00 00 
  8041602bdb:	be d4 02 00 00       	mov    $0x2d4,%esi
  8041602be0:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041602be7:	00 00 00 
  8041602bea:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602bef:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041602bf6:	00 00 00 
  8041602bf9:	41 ff d0             	callq  *%r8
    assert(address_size == 8);
  8041602bfc:	48 b9 bb 55 60 41 80 	movabs $0x80416055bb,%rcx
  8041602c03:	00 00 00 
  8041602c06:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041602c0d:	00 00 00 
  8041602c10:	be d8 02 00 00       	mov    $0x2d8,%esi
  8041602c15:	48 bf ae 55 60 41 80 	movabs $0x80416055ae,%rdi
  8041602c1c:	00 00 00 
  8041602c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602c24:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041602c2b:	00 00 00 
  8041602c2e:	41 ff d0             	callq  *%r8
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602c31:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602c35:	4c 8b 58 08          	mov    0x8(%rax),%r11
      curr_abbrev_entry = abbrev_entry;
  8041602c39:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
      unsigned name = 0, form = 0, tag = 0;
  8041602c3d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
  8041602c43:	49 39 db             	cmp    %rbx,%r11
  8041602c46:	0f 86 e7 00 00 00    	jbe    8041602d33 <naive_address_by_fname+0x260>
  8041602c4c:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602c4f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602c55:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602c5a:	be 00 00 00 00       	mov    $0x0,%esi
    byte = *addr;
  8041602c5f:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602c62:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c66:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602c6a:	89 f8                	mov    %edi,%eax
  8041602c6c:	83 e0 7f             	and    $0x7f,%eax
  8041602c6f:	d3 e0                	shl    %cl,%eax
  8041602c71:	09 c6                	or     %eax,%esi
    shift += 7;
  8041602c73:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602c76:	40 84 ff             	test   %dil,%dil
  8041602c79:	78 e4                	js     8041602c5f <naive_address_by_fname+0x18c>
  return count;
  8041602c7b:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry += count;
  8041602c7e:	4c 01 c3             	add    %r8,%rbx
  8041602c81:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602c84:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  shift  = 0;
  8041602c8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602c8f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    byte = *addr;
  8041602c95:	0f b6 3a             	movzbl (%rdx),%edi
    addr++;
  8041602c98:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602c9c:	41 83 c0 01          	add    $0x1,%r8d
    result |= (byte & 0x7f) << shift;
  8041602ca0:	89 f8                	mov    %edi,%eax
  8041602ca2:	83 e0 7f             	and    $0x7f,%eax
  8041602ca5:	d3 e0                	shl    %cl,%eax
  8041602ca7:	41 09 c1             	or     %eax,%r9d
    shift += 7;
  8041602caa:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602cad:	40 84 ff             	test   %dil,%dil
  8041602cb0:	78 e3                	js     8041602c95 <naive_address_by_fname+0x1c2>
  return count;
  8041602cb2:	4d 63 c0             	movslq %r8d,%r8
        curr_abbrev_entry++;
  8041602cb5:	4a 8d 5c 03 01       	lea    0x1(%rbx,%r8,1),%rbx
        if (table_abbrev_code == abbrev_code) {
  8041602cba:	41 39 f2             	cmp    %esi,%r10d
  8041602cbd:	74 74                	je     8041602d33 <naive_address_by_fname+0x260>
  result = 0;
  8041602cbf:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602cc2:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602cc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602ccc:	41 b8 00 00 00 00    	mov    $0x0,%r8d
    byte = *addr;
  8041602cd2:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602cd5:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602cd9:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602cdc:	89 f0                	mov    %esi,%eax
  8041602cde:	83 e0 7f             	and    $0x7f,%eax
  8041602ce1:	d3 e0                	shl    %cl,%eax
  8041602ce3:	41 09 c0             	or     %eax,%r8d
    shift += 7;
  8041602ce6:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ce9:	40 84 f6             	test   %sil,%sil
  8041602cec:	78 e4                	js     8041602cd2 <naive_address_by_fname+0x1ff>
  return count;
  8041602cee:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602cf1:	48 01 fb             	add    %rdi,%rbx
  8041602cf4:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602cf7:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d01:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602d07:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d0a:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d0e:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602d11:	89 f0                	mov    %esi,%eax
  8041602d13:	83 e0 7f             	and    $0x7f,%eax
  8041602d16:	d3 e0                	shl    %cl,%eax
  8041602d18:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602d1b:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d1e:	40 84 f6             	test   %sil,%sil
  8041602d21:	78 e4                	js     8041602d07 <naive_address_by_fname+0x234>
  return count;
  8041602d23:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602d26:	48 01 fb             	add    %rdi,%rbx
        } while (name != 0 || form != 0);
  8041602d29:	45 09 c4             	or     %r8d,%r12d
  8041602d2c:	75 91                	jne    8041602cbf <naive_address_by_fname+0x1ec>
  8041602d2e:	e9 10 ff ff ff       	jmpq   8041602c43 <naive_address_by_fname+0x170>
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
  8041602d33:	41 83 f9 2e          	cmp    $0x2e,%r9d
  8041602d37:	0f 84 4f 01 00 00    	je     8041602e8c <naive_address_by_fname+0x3b9>
  8041602d3d:	41 83 f9 0a          	cmp    $0xa,%r9d
  8041602d41:	0f 84 45 01 00 00    	je     8041602e8c <naive_address_by_fname+0x3b9>
                found = 1;
  8041602d47:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602d4a:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602d4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d54:	41 bd 00 00 00 00    	mov    $0x0,%r13d
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
  8041602d6b:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602d6e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602d71:	40 84 f6             	test   %sil,%sil
  8041602d74:	78 e4                	js     8041602d5a <naive_address_by_fname+0x287>
  return count;
  8041602d76:	48 63 ff             	movslq %edi,%rdi
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
  8041602d79:	48 01 fb             	add    %rdi,%rbx
  8041602d7c:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602d7f:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602d84:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602d89:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602d8f:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602d92:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602d96:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602d99:	89 f0                	mov    %esi,%eax
  8041602d9b:	83 e0 7f             	and    $0x7f,%eax
  8041602d9e:	d3 e0                	shl    %cl,%eax
  8041602da0:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602da3:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602da6:	40 84 f6             	test   %sil,%sil
  8041602da9:	78 e4                	js     8041602d8f <naive_address_by_fname+0x2bc>
  return count;
  8041602dab:	48 63 ff             	movslq %edi,%rdi
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
  8041602dae:	48 01 fb             	add    %rdi,%rbx
          count = dwarf_read_abbrev_entry(
  8041602db1:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602db7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602dbc:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602dc1:	44 89 e6             	mov    %r12d,%esi
  8041602dc4:	4c 89 ff             	mov    %r15,%rdi
  8041602dc7:	41 ff d6             	callq  *%r14
              entry, form, NULL, 0,
              address_size);
          entry += count;
  8041602dca:	48 98                	cltq   
  8041602dcc:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041602dcf:	45 09 ec             	or     %r13d,%r12d
  8041602dd2:	0f 85 6f ff ff ff    	jne    8041602d47 <naive_address_by_fname+0x274>
    while (entry < entry_end) {
  8041602dd8:	4c 3b 7d a8          	cmp    -0x58(%rbp),%r15
  8041602ddc:	73 44                	jae    8041602e22 <naive_address_by_fname+0x34f>
                       uintptr_t *offset) {
  8041602dde:	4c 89 fa             	mov    %r15,%rdx
  count  = 0;
  8041602de1:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602de6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602deb:	41 ba 00 00 00 00    	mov    $0x0,%r10d
    byte = *addr;
  8041602df1:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602df4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602df8:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602dfb:	89 f0                	mov    %esi,%eax
  8041602dfd:	83 e0 7f             	and    $0x7f,%eax
  8041602e00:	d3 e0                	shl    %cl,%eax
  8041602e02:	41 09 c2             	or     %eax,%r10d
    shift += 7;
  8041602e05:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602e08:	40 84 f6             	test   %sil,%sil
  8041602e0b:	78 e4                	js     8041602df1 <naive_address_by_fname+0x31e>
  return count;
  8041602e0d:	48 63 ff             	movslq %edi,%rdi
      entry += count;
  8041602e10:	49 01 ff             	add    %rdi,%r15
      if (abbrev_code == 0) {
  8041602e13:	45 85 d2             	test   %r10d,%r10d
  8041602e16:	0f 85 15 fe ff ff    	jne    8041602c31 <naive_address_by_fname+0x15e>
    while (entry < entry_end) {
  8041602e1c:	4c 39 7d a8          	cmp    %r15,-0x58(%rbp)
  8041602e20:	77 bc                	ja     8041602dde <naive_address_by_fname+0x30b>
  while ((const unsigned char *)entry < addrs->info_end) {
  8041602e22:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602e26:	4c 39 78 28          	cmp    %r15,0x28(%rax)
  8041602e2a:	0f 86 ee 01 00 00    	jbe    804160301e <naive_address_by_fname+0x54b>
  initial_len = get_unaligned(addr, uint32_t);
  8041602e30:	ba 04 00 00 00       	mov    $0x4,%edx
  8041602e35:	4c 89 fe             	mov    %r15,%rsi
  8041602e38:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041602e3c:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041602e43:	00 00 00 
  8041602e46:	ff d0                	callq  *%rax
  8041602e48:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  8041602e4b:	83 f8 ef             	cmp    $0xffffffef,%eax
  8041602e4e:	0f 86 e3 fc ff ff    	jbe    8041602b37 <naive_address_by_fname+0x64>
    if (initial_len == DW_EXT_DWARF64) {
  8041602e54:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041602e57:	0f 84 b6 fc ff ff    	je     8041602b13 <naive_address_by_fname+0x40>
      cprintf("Unknown DWARF extension\n");
  8041602e5d:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  8041602e64:	00 00 00 
  8041602e67:	b8 00 00 00 00       	mov    $0x0,%eax
  8041602e6c:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041602e73:	00 00 00 
  8041602e76:	ff d2                	callq  *%rdx
      return -E_BAD_DWARF;
  8041602e78:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
      }
    }
  }

  return 0;
}
  8041602e7d:	48 83 c4 48          	add    $0x48,%rsp
  8041602e81:	5b                   	pop    %rbx
  8041602e82:	41 5c                	pop    %r12
  8041602e84:	41 5d                	pop    %r13
  8041602e86:	41 5e                	pop    %r14
  8041602e88:	41 5f                	pop    %r15
  8041602e8a:	5d                   	pop    %rbp
  8041602e8b:	c3                   	retq   
        uintptr_t low_pc = 0;
  8041602e8c:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8041602e93:	00 
        int found        = 0;
  8041602e94:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%rbp)
  8041602e9b:	eb 21                	jmp    8041602ebe <naive_address_by_fname+0x3eb>
            count = dwarf_read_abbrev_entry(
  8041602e9d:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602ea3:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602ea8:	48 8d 55 c0          	lea    -0x40(%rbp),%rdx
  8041602eac:	44 89 ee             	mov    %r13d,%esi
  8041602eaf:	4c 89 ff             	mov    %r15,%rdi
  8041602eb2:	41 ff d6             	callq  *%r14
  8041602eb5:	41 89 c4             	mov    %eax,%r12d
          entry += count;
  8041602eb8:	49 63 c4             	movslq %r12d,%rax
  8041602ebb:	49 01 c7             	add    %rax,%r15
        int found        = 0;
  8041602ebe:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ec1:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602ec6:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602ecb:	41 bc 00 00 00 00    	mov    $0x0,%r12d
    byte = *addr;
  8041602ed1:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602ed4:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602ed8:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602edb:	89 f0                	mov    %esi,%eax
  8041602edd:	83 e0 7f             	and    $0x7f,%eax
  8041602ee0:	d3 e0                	shl    %cl,%eax
  8041602ee2:	41 09 c4             	or     %eax,%r12d
    shift += 7;
  8041602ee5:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602ee8:	40 84 f6             	test   %sil,%sil
  8041602eeb:	78 e4                	js     8041602ed1 <naive_address_by_fname+0x3fe>
  return count;
  8041602eed:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602ef0:	48 01 fb             	add    %rdi,%rbx
  8041602ef3:	48 89 da             	mov    %rbx,%rdx
  count  = 0;
  8041602ef6:	bf 00 00 00 00       	mov    $0x0,%edi
  shift  = 0;
  8041602efb:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041602f00:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    byte = *addr;
  8041602f06:	0f b6 32             	movzbl (%rdx),%esi
    addr++;
  8041602f09:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041602f0d:	83 c7 01             	add    $0x1,%edi
    result |= (byte & 0x7f) << shift;
  8041602f10:	89 f0                	mov    %esi,%eax
  8041602f12:	83 e0 7f             	and    $0x7f,%eax
  8041602f15:	d3 e0                	shl    %cl,%eax
  8041602f17:	41 09 c5             	or     %eax,%r13d
    shift += 7;
  8041602f1a:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041602f1d:	40 84 f6             	test   %sil,%sil
  8041602f20:	78 e4                	js     8041602f06 <naive_address_by_fname+0x433>
  return count;
  8041602f22:	48 63 ff             	movslq %edi,%rdi
          curr_abbrev_entry += count;
  8041602f25:	48 01 fb             	add    %rdi,%rbx
          if (name == DW_AT_low_pc) {
  8041602f28:	41 83 fc 11          	cmp    $0x11,%r12d
  8041602f2c:	0f 84 6b ff ff ff    	je     8041602e9d <naive_address_by_fname+0x3ca>
          } else if (name == DW_AT_name) {
  8041602f32:	41 83 fc 03          	cmp    $0x3,%r12d
  8041602f36:	0f 85 9c 00 00 00    	jne    8041602fd8 <naive_address_by_fname+0x505>
            if (form == DW_FORM_strp) {
  8041602f3c:	41 83 fd 0e          	cmp    $0xe,%r13d
  8041602f40:	74 42                	je     8041602f84 <naive_address_by_fname+0x4b1>
              if (!strcmp(fname, entry)) {
  8041602f42:	4c 89 fe             	mov    %r15,%rsi
  8041602f45:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041602f49:	48 b8 8d 4e 60 41 80 	movabs $0x8041604e8d,%rax
  8041602f50:	00 00 00 
  8041602f53:	ff d0                	callq  *%rax
                found = 1;
  8041602f55:	85 c0                	test   %eax,%eax
  8041602f57:	b8 01 00 00 00       	mov    $0x1,%eax
  8041602f5c:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041602f60:	89 45 bc             	mov    %eax,-0x44(%rbp)
              count = dwarf_read_abbrev_entry(
  8041602f63:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f69:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602f6e:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602f73:	44 89 ee             	mov    %r13d,%esi
  8041602f76:	4c 89 ff             	mov    %r15,%rdi
  8041602f79:	41 ff d6             	callq  *%r14
  8041602f7c:	41 89 c4             	mov    %eax,%r12d
  8041602f7f:	e9 34 ff ff ff       	jmpq   8041602eb8 <naive_address_by_fname+0x3e5>
                  str_offset = 0;
  8041602f84:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8041602f8b:	00 
              count          = dwarf_read_abbrev_entry(
  8041602f8c:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602f92:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041602f97:	48 8d 55 c8          	lea    -0x38(%rbp),%rdx
  8041602f9b:	be 0e 00 00 00       	mov    $0xe,%esi
  8041602fa0:	4c 89 ff             	mov    %r15,%rdi
  8041602fa3:	41 ff d6             	callq  *%r14
  8041602fa6:	41 89 c4             	mov    %eax,%r12d
              if (!strcmp(
  8041602fa9:	48 8b 75 c8          	mov    -0x38(%rbp),%rsi
  8041602fad:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8041602fb1:	48 03 70 40          	add    0x40(%rax),%rsi
  8041602fb5:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8041602fb9:	48 b8 8d 4e 60 41 80 	movabs $0x8041604e8d,%rax
  8041602fc0:	00 00 00 
  8041602fc3:	ff d0                	callq  *%rax
                found = 1;
  8041602fc5:	85 c0                	test   %eax,%eax
  8041602fc7:	b8 01 00 00 00       	mov    $0x1,%eax
  8041602fcc:	0f 45 45 bc          	cmovne -0x44(%rbp),%eax
  8041602fd0:	89 45 bc             	mov    %eax,-0x44(%rbp)
  8041602fd3:	e9 e0 fe ff ff       	jmpq   8041602eb8 <naive_address_by_fname+0x3e5>
            count = dwarf_read_abbrev_entry(
  8041602fd8:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  8041602fde:	b9 00 00 00 00       	mov    $0x0,%ecx
  8041602fe3:	ba 00 00 00 00       	mov    $0x0,%edx
  8041602fe8:	44 89 ee             	mov    %r13d,%esi
  8041602feb:	4c 89 ff             	mov    %r15,%rdi
  8041602fee:	41 ff d6             	callq  *%r14
          entry += count;
  8041602ff1:	48 98                	cltq   
  8041602ff3:	49 01 c7             	add    %rax,%r15
        } while (name != 0 || form != 0);
  8041602ff6:	45 09 e5             	or     %r12d,%r13d
  8041602ff9:	0f 85 bf fe ff ff    	jne    8041602ebe <naive_address_by_fname+0x3eb>
        if (found) {
  8041602fff:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  8041603003:	0f 84 cf fd ff ff    	je     8041602dd8 <naive_address_by_fname+0x305>
          *offset = low_pc;
  8041603009:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  804160300d:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  8041603011:	48 89 03             	mov    %rax,(%rbx)
          return 0;
  8041603014:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603019:	e9 5f fe ff ff       	jmpq   8041602e7d <naive_address_by_fname+0x3aa>
  return 0;
  804160301e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603023:	e9 55 fe ff ff       	jmpq   8041602e7d <naive_address_by_fname+0x3aa>

0000008041603028 <line_for_address>:
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int
line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off line_offset, int *lineno_store) {
  8041603028:	55                   	push   %rbp
  8041603029:	48 89 e5             	mov    %rsp,%rbp
  804160302c:	41 57                	push   %r15
  804160302e:	41 56                	push   %r14
  8041603030:	41 55                	push   %r13
  8041603032:	41 54                	push   %r12
  8041603034:	53                   	push   %rbx
  8041603035:	48 83 ec 38          	sub    $0x38,%rsp
  if (line_offset > addrs->line_end - addrs->line_begin) {
  8041603039:	48 8b 5f 30          	mov    0x30(%rdi),%rbx
  804160303d:	48 8b 47 38          	mov    0x38(%rdi),%rax
  8041603041:	48 29 d8             	sub    %rbx,%rax
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
  8041603044:	48 39 d0             	cmp    %rdx,%rax
  8041603047:	0f 82 d9 06 00 00    	jb     8041603726 <line_for_address+0x6fe>
  804160304d:	48 85 c9             	test   %rcx,%rcx
  8041603050:	0f 84 d0 06 00 00    	je     8041603726 <line_for_address+0x6fe>
  8041603056:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
  804160305a:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
    return -E_INVAL;
  }
  const void *curr_addr                  = addrs->line_begin + line_offset;
  804160305e:	48 01 d3             	add    %rdx,%rbx
  initial_len = get_unaligned(addr, uint32_t);
  8041603061:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603066:	48 89 de             	mov    %rbx,%rsi
  8041603069:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160306d:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041603074:	00 00 00 
  8041603077:	ff d0                	callq  *%rax
  8041603079:	8b 45 c8             	mov    -0x38(%rbp),%eax
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160307c:	83 f8 ef             	cmp    $0xffffffef,%eax
  804160307f:	76 4e                	jbe    80416030cf <line_for_address+0xa7>
    if (initial_len == DW_EXT_DWARF64) {
  8041603081:	83 f8 ff             	cmp    $0xffffffff,%eax
  8041603084:	74 25                	je     80416030ab <line_for_address+0x83>
      cprintf("Unknown DWARF extension\n");
  8041603086:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  804160308d:	00 00 00 
  8041603090:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603095:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  804160309c:	00 00 00 
  804160309f:	ff d2                	callq  *%rdx

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  80416030a1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  80416030a6:	e9 6c 06 00 00       	jmpq   8041603717 <line_for_address+0x6ef>
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  80416030ab:	48 8d 73 20          	lea    0x20(%rbx),%rsi
  80416030af:	ba 08 00 00 00       	mov    $0x8,%edx
  80416030b4:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030b8:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416030bf:	00 00 00 
  80416030c2:	ff d0                	callq  *%rax
  80416030c4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
      count = 12;
  80416030c8:	be 0c 00 00 00       	mov    $0xc,%esi
  80416030cd:	eb 07                	jmp    80416030d6 <line_for_address+0xae>
    *len = initial_len;
  80416030cf:	89 c0                	mov    %eax,%eax
  count       = 4;
  80416030d1:	be 04 00 00 00       	mov    $0x4,%esi
  } else {
    curr_addr += count;
  80416030d6:	48 63 f6             	movslq %esi,%rsi
  80416030d9:	48 01 f3             	add    %rsi,%rbx
  }
  const void *unit_end = curr_addr + unit_length;
  80416030dc:	48 01 d8             	add    %rbx,%rax
  80416030df:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  Dwarf_Half version   = get_unaligned(curr_addr, Dwarf_Half);
  80416030e3:	ba 02 00 00 00       	mov    $0x2,%edx
  80416030e8:	48 89 de             	mov    %rbx,%rsi
  80416030eb:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416030ef:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416030f6:	00 00 00 
  80416030f9:	ff d0                	callq  *%rax
  80416030fb:	44 0f b7 7d c8       	movzwl -0x38(%rbp),%r15d
  curr_addr += sizeof(Dwarf_Half);
  8041603100:	4c 8d 63 02          	lea    0x2(%rbx),%r12
  assert(version == 4 || version == 3 || version == 2);
  8041603104:	41 8d 47 fe          	lea    -0x2(%r15),%eax
  8041603108:	66 83 f8 02          	cmp    $0x2,%ax
  804160310c:	77 51                	ja     804160315f <line_for_address+0x137>
  initial_len = get_unaligned(addr, uint32_t);
  804160310e:	ba 04 00 00 00       	mov    $0x4,%edx
  8041603113:	4c 89 e6             	mov    %r12,%rsi
  8041603116:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160311a:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041603121:	00 00 00 
  8041603124:	ff d0                	callq  *%rax
  8041603126:	44 8b 6d c8          	mov    -0x38(%rbp),%r13d
  if (initial_len >= DW_EXT_LO && initial_len <= DW_EXT_HI) {
  804160312a:	41 83 fd ef          	cmp    $0xffffffef,%r13d
  804160312e:	0f 86 84 00 00 00    	jbe    80416031b8 <line_for_address+0x190>
    if (initial_len == DW_EXT_DWARF64) {
  8041603134:	41 83 fd ff          	cmp    $0xffffffff,%r13d
  8041603138:	74 5a                	je     8041603194 <line_for_address+0x16c>
      cprintf("Unknown DWARF extension\n");
  804160313a:	48 bf 80 55 60 41 80 	movabs $0x8041605580,%rdi
  8041603141:	00 00 00 
  8041603144:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603149:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041603150:	00 00 00 
  8041603153:	ff d2                	callq  *%rdx
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  8041603155:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
  804160315a:	e9 b8 05 00 00       	jmpq   8041603717 <line_for_address+0x6ef>
  assert(version == 4 || version == 3 || version == 2);
  804160315f:	48 b9 a8 57 60 41 80 	movabs $0x80416057a8,%rcx
  8041603166:	00 00 00 
  8041603169:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041603170:	00 00 00 
  8041603173:	be fc 00 00 00       	mov    $0xfc,%esi
  8041603178:	48 bf 61 57 60 41 80 	movabs $0x8041605761,%rdi
  804160317f:	00 00 00 
  8041603182:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603187:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  804160318e:	00 00 00 
  8041603191:	41 ff d0             	callq  *%r8
      *len  = get_unaligned((uint64_t *)addr + 4, uint64_t);
  8041603194:	48 8d 73 22          	lea    0x22(%rbx),%rsi
  8041603198:	ba 08 00 00 00       	mov    $0x8,%edx
  804160319d:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031a1:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416031a8:	00 00 00 
  80416031ab:	ff d0                	callq  *%rax
  80416031ad:	4c 8b 6d c8          	mov    -0x38(%rbp),%r13
      count = 12;
  80416031b1:	b8 0c 00 00 00       	mov    $0xc,%eax
  80416031b6:	eb 08                	jmp    80416031c0 <line_for_address+0x198>
    *len = initial_len;
  80416031b8:	45 89 ed             	mov    %r13d,%r13d
  count       = 4;
  80416031bb:	b8 04 00 00 00       	mov    $0x4,%eax
  } else {
    curr_addr += count;
  80416031c0:	48 98                	cltq   
  80416031c2:	49 01 c4             	add    %rax,%r12
  }
  const void *program_addr = curr_addr + header_length;
  80416031c5:	4d 01 e5             	add    %r12,%r13
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  80416031c8:	ba 01 00 00 00       	mov    $0x1,%edx
  80416031cd:	4c 89 e6             	mov    %r12,%rsi
  80416031d0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416031d4:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416031db:	00 00 00 
  80416031de:	ff d0                	callq  *%rax
  assert(minimum_instruction_length == 1);
  80416031e0:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416031e4:	0f 85 89 00 00 00    	jne    8041603273 <line_for_address+0x24b>
  curr_addr += sizeof(Dwarf_Small);
  80416031ea:	49 8d 5c 24 01       	lea    0x1(%r12),%rbx
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
  80416031ef:	66 41 83 ff 04       	cmp    $0x4,%r15w
  80416031f4:	0f 84 ae 00 00 00    	je     80416032a8 <line_for_address+0x280>
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  80416031fa:	48 8d 73 01          	lea    0x1(%rbx),%rsi
  signed char line_base = get_unaligned(curr_addr, signed char);
  80416031fe:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603203:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603207:	49 bc f7 4f 60 41 80 	movabs $0x8041604ff7,%r12
  804160320e:	00 00 00 
  8041603211:	41 ff d4             	callq  *%r12
  8041603214:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041603218:	88 45 b9             	mov    %al,-0x47(%rbp)
  curr_addr += sizeof(signed char);
  804160321b:	48 8d 73 02          	lea    0x2(%rbx),%rsi
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  804160321f:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603224:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603228:	41 ff d4             	callq  *%r12
  804160322b:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  804160322f:	88 45 ba             	mov    %al,-0x46(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  8041603232:	48 8d 73 03          	lea    0x3(%rbx),%rsi
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  8041603236:	ba 01 00 00 00       	mov    $0x1,%edx
  804160323b:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160323f:	41 ff d4             	callq  *%r12
  8041603242:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
  8041603246:	88 45 bb             	mov    %al,-0x45(%rbp)
  curr_addr += sizeof(Dwarf_Small);
  8041603249:	48 8d 73 04          	lea    0x4(%rbx),%rsi
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  804160324d:	ba 08 00 00 00       	mov    $0x8,%edx
  8041603252:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603256:	41 ff d4             	callq  *%r12
  while (program_addr < end_addr) {
  8041603259:	4c 39 6d a8          	cmp    %r13,-0x58(%rbp)
  804160325d:	0f 86 90 04 00 00    	jbe    80416036f3 <line_for_address+0x6cb>
  struct Line_Number_State current_state = {
  8041603263:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  8041603269:	bb 00 00 00 00       	mov    $0x0,%ebx
  804160326e:	e9 32 04 00 00       	jmpq   80416036a5 <line_for_address+0x67d>
  assert(minimum_instruction_length == 1);
  8041603273:	48 b9 d8 57 60 41 80 	movabs $0x80416057d8,%rcx
  804160327a:	00 00 00 
  804160327d:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  8041603284:	00 00 00 
  8041603287:	be 07 01 00 00       	mov    $0x107,%esi
  804160328c:	48 bf 61 57 60 41 80 	movabs $0x8041605761,%rdi
  8041603293:	00 00 00 
  8041603296:	b8 00 00 00 00       	mov    $0x0,%eax
  804160329b:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  80416032a2:	00 00 00 
  80416032a5:	41 ff d0             	callq  *%r8
        get_unaligned(curr_addr, Dwarf_Small);
  80416032a8:	ba 01 00 00 00       	mov    $0x1,%edx
  80416032ad:	48 89 de             	mov    %rbx,%rsi
  80416032b0:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416032b4:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416032bb:	00 00 00 
  80416032be:	ff d0                	callq  *%rax
    curr_addr += sizeof(Dwarf_Small);
  80416032c0:	49 8d 5c 24 02       	lea    0x2(%r12),%rbx
  assert(maximum_operations_per_instruction == 1);
  80416032c5:	80 7d c8 01          	cmpb   $0x1,-0x38(%rbp)
  80416032c9:	0f 84 2b ff ff ff    	je     80416031fa <line_for_address+0x1d2>
  80416032cf:	48 b9 f8 57 60 41 80 	movabs $0x80416057f8,%rcx
  80416032d6:	00 00 00 
  80416032d9:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  80416032e0:	00 00 00 
  80416032e3:	be 11 01 00 00       	mov    $0x111,%esi
  80416032e8:	48 bf 61 57 60 41 80 	movabs $0x8041605761,%rdi
  80416032ef:	00 00 00 
  80416032f2:	b8 00 00 00 00       	mov    $0x0,%eax
  80416032f7:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  80416032fe:	00 00 00 
  8041603301:	41 ff d0             	callq  *%r8
    if (opcode == 0) {
  8041603304:	48 89 f0             	mov    %rsi,%rax
  count  = 0;
  8041603307:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  shift  = 0;
  804160330d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603312:	41 bf 00 00 00 00    	mov    $0x0,%r15d
    byte = *addr;
  8041603318:	0f b6 38             	movzbl (%rax),%edi
    addr++;
  804160331b:	48 83 c0 01          	add    $0x1,%rax
    count++;
  804160331f:	41 83 c5 01          	add    $0x1,%r13d
    result |= (byte & 0x7f) << shift;
  8041603323:	89 fa                	mov    %edi,%edx
  8041603325:	83 e2 7f             	and    $0x7f,%edx
  8041603328:	d3 e2                	shl    %cl,%edx
  804160332a:	41 09 d7             	or     %edx,%r15d
    shift += 7;
  804160332d:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603330:	40 84 ff             	test   %dil,%dil
  8041603333:	78 e3                	js     8041603318 <line_for_address+0x2f0>
  return count;
  8041603335:	4d 63 ed             	movslq %r13d,%r13
      program_addr += count;
  8041603338:	49 01 f5             	add    %rsi,%r13
      const void *opcode_end = program_addr + length;
  804160333b:	45 89 ff             	mov    %r15d,%r15d
  804160333e:	4d 01 ef             	add    %r13,%r15
      opcode                 = get_unaligned(program_addr, Dwarf_Small);
  8041603341:	ba 01 00 00 00       	mov    $0x1,%edx
  8041603346:	4c 89 ee             	mov    %r13,%rsi
  8041603349:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160334d:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041603354:	00 00 00 
  8041603357:	ff d0                	callq  *%rax
  8041603359:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
      program_addr += sizeof(Dwarf_Small);
  804160335d:	49 8d 75 01          	lea    0x1(%r13),%rsi
      switch (opcode) {
  8041603361:	3c 02                	cmp    $0x2,%al
  8041603363:	0f 84 dc 00 00 00    	je     8041603445 <line_for_address+0x41d>
  8041603369:	76 39                	jbe    80416033a4 <line_for_address+0x37c>
  804160336b:	3c 03                	cmp    $0x3,%al
  804160336d:	74 62                	je     80416033d1 <line_for_address+0x3a9>
  804160336f:	3c 04                	cmp    $0x4,%al
  8041603371:	0f 85 0c 01 00 00    	jne    8041603483 <line_for_address+0x45b>
  8041603377:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160337a:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  804160337f:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603382:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603386:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603389:	84 c9                	test   %cl,%cl
  804160338b:	78 f2                	js     804160337f <line_for_address+0x357>
  return count;
  804160338d:	48 98                	cltq   
          program_addr += count;
  804160338f:	48 01 c6             	add    %rax,%rsi
  8041603392:	44 89 e2             	mov    %r12d,%edx
  8041603395:	48 89 d8             	mov    %rbx,%rax
  8041603398:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  804160339c:	4c 89 f3             	mov    %r14,%rbx
  804160339f:	e9 c8 00 00 00       	jmpq   804160346c <line_for_address+0x444>
      switch (opcode) {
  80416033a4:	3c 01                	cmp    $0x1,%al
  80416033a6:	0f 85 d7 00 00 00    	jne    8041603483 <line_for_address+0x45b>
          if (last_state.address <= destination_addr &&
  80416033ac:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416033b0:	49 39 c6             	cmp    %rax,%r14
  80416033b3:	0f 87 f8 00 00 00    	ja     80416034b1 <line_for_address+0x489>
  80416033b9:	48 39 d8             	cmp    %rbx,%rax
  80416033bc:	0f 82 39 03 00 00    	jb     80416036fb <line_for_address+0x6d3>
          state->line          = 1;
  80416033c2:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  80416033c7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416033cc:	e9 9b 00 00 00       	jmpq   804160346c <line_for_address+0x444>
          while (*(char *)program_addr) {
  80416033d1:	41 80 7d 01 00       	cmpb   $0x0,0x1(%r13)
  80416033d6:	74 09                	je     80416033e1 <line_for_address+0x3b9>
            ++program_addr;
  80416033d8:	48 83 c6 01          	add    $0x1,%rsi
          while (*(char *)program_addr) {
  80416033dc:	80 3e 00             	cmpb   $0x0,(%rsi)
  80416033df:	75 f7                	jne    80416033d8 <line_for_address+0x3b0>
          ++program_addr;
  80416033e1:	48 83 c6 01          	add    $0x1,%rsi
  80416033e5:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416033e8:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416033ed:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416033f0:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416033f4:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416033f7:	84 c9                	test   %cl,%cl
  80416033f9:	78 f2                	js     80416033ed <line_for_address+0x3c5>
  return count;
  80416033fb:	48 98                	cltq   
          program_addr += count;
  80416033fd:	48 01 c6             	add    %rax,%rsi
  8041603400:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603403:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603408:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160340b:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160340f:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603412:	84 c9                	test   %cl,%cl
  8041603414:	78 f2                	js     8041603408 <line_for_address+0x3e0>
  return count;
  8041603416:	48 98                	cltq   
          program_addr += count;
  8041603418:	48 01 c6             	add    %rax,%rsi
  804160341b:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  804160341e:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603423:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  8041603426:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  804160342a:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  804160342d:	84 c9                	test   %cl,%cl
  804160342f:	78 f2                	js     8041603423 <line_for_address+0x3fb>
  return count;
  8041603431:	48 98                	cltq   
          program_addr += count;
  8041603433:	48 01 c6             	add    %rax,%rsi
  8041603436:	44 89 e2             	mov    %r12d,%edx
  8041603439:	48 89 d8             	mov    %rbx,%rax
  804160343c:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603440:	4c 89 f3             	mov    %r14,%rbx
  8041603443:	eb 27                	jmp    804160346c <line_for_address+0x444>
              get_unaligned(program_addr, uintptr_t);
  8041603445:	ba 08 00 00 00       	mov    $0x8,%edx
  804160344a:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  804160344e:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041603455:	00 00 00 
  8041603458:	ff d0                	callq  *%rax
  804160345a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
          program_addr += sizeof(uintptr_t);
  804160345e:	49 8d 75 09          	lea    0x9(%r13),%rsi
  8041603462:	44 89 e2             	mov    %r12d,%edx
  8041603465:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603469:	4c 89 f3             	mov    %r14,%rbx
      assert(program_addr == opcode_end);
  804160346c:	49 39 f7             	cmp    %rsi,%r15
  804160346f:	75 4c                	jne    80416034bd <line_for_address+0x495>
  8041603471:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603475:	41 89 d4             	mov    %edx,%r12d
  8041603478:	49 89 de             	mov    %rbx,%r14
  804160347b:	48 89 c3             	mov    %rax,%rbx
  804160347e:	e9 19 02 00 00       	jmpq   804160369c <line_for_address+0x674>
      switch (opcode) {
  8041603483:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603486:	48 ba 74 57 60 41 80 	movabs $0x8041605774,%rdx
  804160348d:	00 00 00 
  8041603490:	be 6b 00 00 00       	mov    $0x6b,%esi
  8041603495:	48 bf 61 57 60 41 80 	movabs $0x8041605761,%rdi
  804160349c:	00 00 00 
  804160349f:	b8 00 00 00 00       	mov    $0x0,%eax
  80416034a4:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  80416034ab:	00 00 00 
  80416034ae:	41 ff d0             	callq  *%r8
          state->line          = 1;
  80416034b1:	ba 01 00 00 00       	mov    $0x1,%edx
          state->address       = 0;
  80416034b6:	b8 00 00 00 00       	mov    $0x0,%eax
  80416034bb:	eb af                	jmp    804160346c <line_for_address+0x444>
      assert(program_addr == opcode_end);
  80416034bd:	48 b9 87 57 60 41 80 	movabs $0x8041605787,%rcx
  80416034c4:	00 00 00 
  80416034c7:	48 ba 99 55 60 41 80 	movabs $0x8041605599,%rdx
  80416034ce:	00 00 00 
  80416034d1:	be 6e 00 00 00       	mov    $0x6e,%esi
  80416034d6:	48 bf 61 57 60 41 80 	movabs $0x8041605761,%rdi
  80416034dd:	00 00 00 
  80416034e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416034e5:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  80416034ec:	00 00 00 
  80416034ef:	41 ff d0             	callq  *%r8
          if (last_state.address <= destination_addr &&
  80416034f2:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80416034f6:	49 39 c6             	cmp    %rax,%r14
  80416034f9:	0f 87 eb 01 00 00    	ja     80416036ea <line_for_address+0x6c2>
  80416034ff:	48 39 d8             	cmp    %rbx,%rax
  8041603502:	0f 82 f9 01 00 00    	jb     8041603701 <line_for_address+0x6d9>
          last_state           = *state;
  8041603508:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  804160350c:	49 89 de             	mov    %rbx,%r14
  804160350f:	e9 88 01 00 00       	jmpq   804160369c <line_for_address+0x674>
      switch (opcode) {
  8041603514:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  8041603517:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  804160351c:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603521:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603526:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  804160352a:	48 83 c7 01          	add    $0x1,%rdi
    count++;
  804160352e:	83 c0 01             	add    $0x1,%eax
    result |= (byte & 0x7f) << shift;
  8041603531:	45 89 c8             	mov    %r9d,%r8d
  8041603534:	41 83 e0 7f          	and    $0x7f,%r8d
  8041603538:	41 d3 e0             	shl    %cl,%r8d
  804160353b:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  804160353e:	83 c1 07             	add    $0x7,%ecx
    if (!(byte & 0x80))
  8041603541:	45 84 c9             	test   %r9b,%r9b
  8041603544:	78 e0                	js     8041603526 <line_for_address+0x4fe>
              info->minimum_instruction_length *
  8041603546:	89 d2                	mov    %edx,%edx
          state->address +=
  8041603548:	48 01 d3             	add    %rdx,%rbx
  return count;
  804160354b:	48 98                	cltq   
          program_addr += count;
  804160354d:	48 01 c6             	add    %rax,%rsi
        } break;
  8041603550:	e9 47 01 00 00       	jmpq   804160369c <line_for_address+0x674>
      switch (opcode) {
  8041603555:	48 89 f7             	mov    %rsi,%rdi
  count  = 0;
  8041603558:	b8 00 00 00 00       	mov    $0x0,%eax
  shift  = 0;
  804160355d:	b9 00 00 00 00       	mov    $0x0,%ecx
  result = 0;
  8041603562:	ba 00 00 00 00       	mov    $0x0,%edx
    byte = *addr;
  8041603567:	44 0f b6 0f          	movzbl (%rdi),%r9d
    addr++;
  804160356b:	48 83 c7 01          	add    $0x1,%rdi
    result |= (byte & 0x7f) << shift;
  804160356f:	45 89 c8             	mov    %r9d,%r8d
  8041603572:	41 83 e0 7f          	and    $0x7f,%r8d
  8041603576:	41 d3 e0             	shl    %cl,%r8d
  8041603579:	44 09 c2             	or     %r8d,%edx
    shift += 7;
  804160357c:	83 c1 07             	add    $0x7,%ecx
    count++;
  804160357f:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603582:	45 84 c9             	test   %r9b,%r9b
  8041603585:	78 e0                	js     8041603567 <line_for_address+0x53f>
  if ((shift < num_bits) && (byte & 0x40))
  8041603587:	83 f9 1f             	cmp    $0x1f,%ecx
  804160358a:	7f 0f                	jg     804160359b <line_for_address+0x573>
  804160358c:	41 f6 c1 40          	test   $0x40,%r9b
  8041603590:	74 09                	je     804160359b <line_for_address+0x573>
    result |= (-1U << shift);
  8041603592:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8041603597:	d3 e7                	shl    %cl,%edi
  8041603599:	09 fa                	or     %edi,%edx
          state->line += line_incr;
  804160359b:	41 01 d4             	add    %edx,%r12d
  return count;
  804160359e:	48 98                	cltq   
          program_addr += count;
  80416035a0:	48 01 c6             	add    %rax,%rsi
        } break;
  80416035a3:	e9 f4 00 00 00       	jmpq   804160369c <line_for_address+0x674>
      switch (opcode) {
  80416035a8:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416035ab:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416035b0:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416035b3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416035b7:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416035ba:	84 c9                	test   %cl,%cl
  80416035bc:	78 f2                	js     80416035b0 <line_for_address+0x588>
  return count;
  80416035be:	48 98                	cltq   
          program_addr += count;
  80416035c0:	48 01 c6             	add    %rax,%rsi
        } break;
  80416035c3:	e9 d4 00 00 00       	jmpq   804160369c <line_for_address+0x674>
      switch (opcode) {
  80416035c8:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  80416035cb:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  80416035d0:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  80416035d3:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  80416035d7:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  80416035da:	84 c9                	test   %cl,%cl
  80416035dc:	78 f2                	js     80416035d0 <line_for_address+0x5a8>
  return count;
  80416035de:	48 98                	cltq   
          program_addr += count;
  80416035e0:	48 01 c6             	add    %rax,%rsi
        } break;
  80416035e3:	e9 b4 00 00 00       	jmpq   804160369c <line_for_address+0x674>
          Dwarf_Small adjusted_opcode =
  80416035e8:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
  80416035ec:	f7 d0                	not    %eax
              adjusted_opcode / info->line_range;
  80416035ee:	0f b6 c0             	movzbl %al,%eax
  80416035f1:	f6 75 ba             	divb   -0x46(%rbp)
              info->minimum_instruction_length *
  80416035f4:	0f b6 c0             	movzbl %al,%eax
          state->address +=
  80416035f7:	48 01 c3             	add    %rax,%rbx
        } break;
  80416035fa:	e9 9d 00 00 00       	jmpq   804160369c <line_for_address+0x674>
              get_unaligned(program_addr, Dwarf_Half);
  80416035ff:	ba 02 00 00 00       	mov    $0x2,%edx
  8041603604:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  8041603608:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  804160360f:	00 00 00 
  8041603612:	ff d0                	callq  *%rax
          state->address += pc_inc;
  8041603614:	0f b7 45 c8          	movzwl -0x38(%rbp),%eax
  8041603618:	48 01 c3             	add    %rax,%rbx
          program_addr += sizeof(Dwarf_Half);
  804160361b:	49 8d 75 03          	lea    0x3(%r13),%rsi
        } break;
  804160361f:	eb 7b                	jmp    804160369c <line_for_address+0x674>
      switch (opcode) {
  8041603621:	48 89 f2             	mov    %rsi,%rdx
  count  = 0;
  8041603624:	b8 00 00 00 00       	mov    $0x0,%eax
    byte = *addr;
  8041603629:	0f b6 0a             	movzbl (%rdx),%ecx
    addr++;
  804160362c:	48 83 c2 01          	add    $0x1,%rdx
    count++;
  8041603630:	83 c0 01             	add    $0x1,%eax
    if (!(byte & 0x80))
  8041603633:	84 c9                	test   %cl,%cl
  8041603635:	78 f2                	js     8041603629 <line_for_address+0x601>
  return count;
  8041603637:	48 98                	cltq   
          program_addr += count;
  8041603639:	48 01 c6             	add    %rax,%rsi
        } break;
  804160363c:	eb 5e                	jmp    804160369c <line_for_address+0x674>
      switch (opcode) {
  804160363e:	0f b6 c8             	movzbl %al,%ecx
          panic("Unknown opcode: %x", opcode);
  8041603641:	48 ba 74 57 60 41 80 	movabs $0x8041605774,%rdx
  8041603648:	00 00 00 
  804160364b:	be c1 00 00 00       	mov    $0xc1,%esi
  8041603650:	48 bf 61 57 60 41 80 	movabs $0x8041605761,%rdi
  8041603657:	00 00 00 
  804160365a:	b8 00 00 00 00       	mov    $0x0,%eax
  804160365f:	49 b8 89 03 60 41 80 	movabs $0x8041600389,%r8
  8041603666:	00 00 00 
  8041603669:	41 ff d0             	callq  *%r8
      Dwarf_Small adjusted_opcode =
  804160366c:	2a 45 bb             	sub    -0x45(%rbp),%al
                      (adjusted_opcode % info->line_range));
  804160366f:	0f b6 c0             	movzbl %al,%eax
  8041603672:	f6 75 ba             	divb   -0x46(%rbp)
  8041603675:	0f b6 d4             	movzbl %ah,%edx
      state->line += (info->line_base +
  8041603678:	0f be 4d b9          	movsbl -0x47(%rbp),%ecx
  804160367c:	01 ca                	add    %ecx,%edx
  804160367e:	41 01 d4             	add    %edx,%r12d
          info->minimum_instruction_length *
  8041603681:	0f b6 c0             	movzbl %al,%eax
      state->address +=
  8041603684:	48 01 c3             	add    %rax,%rbx
      if (last_state.address <= destination_addr &&
  8041603687:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  804160368b:	49 39 c6             	cmp    %rax,%r14
  804160368e:	77 05                	ja     8041603695 <line_for_address+0x66d>
  8041603690:	48 39 d8             	cmp    %rbx,%rax
  8041603693:	72 72                	jb     8041603707 <line_for_address+0x6df>
      last_state = *state;
  8041603695:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  8041603699:	49 89 de             	mov    %rbx,%r14
  while (program_addr < end_addr) {
  804160369c:	48 39 75 a8          	cmp    %rsi,-0x58(%rbp)
  80416036a0:	76 69                	jbe    804160370b <line_for_address+0x6e3>
  80416036a2:	49 89 f5             	mov    %rsi,%r13
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
  80416036a5:	ba 01 00 00 00       	mov    $0x1,%edx
  80416036aa:	4c 89 ee             	mov    %r13,%rsi
  80416036ad:	48 8d 7d c8          	lea    -0x38(%rbp),%rdi
  80416036b1:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  80416036b8:	00 00 00 
  80416036bb:	ff d0                	callq  *%rax
  80416036bd:	0f b6 45 c8          	movzbl -0x38(%rbp),%eax
    program_addr += sizeof(Dwarf_Small);
  80416036c1:	49 8d 75 01          	lea    0x1(%r13),%rsi
    if (opcode == 0) {
  80416036c5:	84 c0                	test   %al,%al
  80416036c7:	0f 84 37 fc ff ff    	je     8041603304 <line_for_address+0x2dc>
    } else if (opcode < info->opcode_base) {
  80416036cd:	38 45 bb             	cmp    %al,-0x45(%rbp)
  80416036d0:	76 9a                	jbe    804160366c <line_for_address+0x644>
      switch (opcode) {
  80416036d2:	3c 0c                	cmp    $0xc,%al
  80416036d4:	0f 87 64 ff ff ff    	ja     804160363e <line_for_address+0x616>
  80416036da:	0f b6 d0             	movzbl %al,%edx
  80416036dd:	48 bf 20 58 60 41 80 	movabs $0x8041605820,%rdi
  80416036e4:	00 00 00 
  80416036e7:	ff 24 d7             	jmpq   *(%rdi,%rdx,8)
          last_state           = *state;
  80416036ea:	44 89 65 bc          	mov    %r12d,-0x44(%rbp)
  80416036ee:	49 89 de             	mov    %rbx,%r14
  80416036f1:	eb a9                	jmp    804160369c <line_for_address+0x674>
  struct Line_Number_State current_state = {
  80416036f3:	41 bc 01 00 00 00    	mov    $0x1,%r12d
  80416036f9:	eb 10                	jmp    804160370b <line_for_address+0x6e3>
            *state = last_state;
  80416036fb:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  80416036ff:	eb 0a                	jmp    804160370b <line_for_address+0x6e3>
            *state = last_state;
  8041603701:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  8041603705:	eb 04                	jmp    804160370b <line_for_address+0x6e3>
        *state = last_state;
  8041603707:	44 8b 65 bc          	mov    -0x44(%rbp),%r12d
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state,
                          p);

  *lineno_store = current_state.line;
  804160370b:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  804160370f:	44 89 20             	mov    %r12d,(%rax)

  return 0;
  8041603712:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603717:	48 83 c4 38          	add    $0x38,%rsp
  804160371b:	5b                   	pop    %rbx
  804160371c:	41 5c                	pop    %r12
  804160371e:	41 5d                	pop    %r13
  8041603720:	41 5e                	pop    %r14
  8041603722:	41 5f                	pop    %r15
  8041603724:	5d                   	pop    %rbp
  8041603725:	c3                   	retq   
    return -E_INVAL;
  8041603726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  804160372b:	eb ea                	jmp    8041603717 <line_for_address+0x6ef>

000000804160372d <mon_help>:
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  804160372d:	55                   	push   %rbp
  804160372e:	48 89 e5             	mov    %rsp,%rbp
  8041603731:	41 55                	push   %r13
  8041603733:	41 54                	push   %r12
  8041603735:	53                   	push   %rbx
  8041603736:	48 83 ec 08          	sub    $0x8,%rsp
  int i;

  for (i = 0; i < NCOMMANDS; i++)
  804160373a:	48 bb 80 5b 60 41 80 	movabs $0x8041605b80,%rbx
  8041603741:	00 00 00 
  8041603744:	4c 8d 6b 78          	lea    0x78(%rbx),%r13
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  8041603748:	49 bc 70 3f 60 41 80 	movabs $0x8041603f70,%r12
  804160374f:	00 00 00 
  8041603752:	48 8b 53 08          	mov    0x8(%rbx),%rdx
  8041603756:	48 8b 33             	mov    (%rbx),%rsi
  8041603759:	48 bf 88 58 60 41 80 	movabs $0x8041605888,%rdi
  8041603760:	00 00 00 
  8041603763:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603768:	41 ff d4             	callq  *%r12
  for (i = 0; i < NCOMMANDS; i++)
  804160376b:	48 83 c3 18          	add    $0x18,%rbx
  804160376f:	4c 39 eb             	cmp    %r13,%rbx
  8041603772:	75 de                	jne    8041603752 <mon_help+0x25>
  return 0;
}
  8041603774:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603779:	48 83 c4 08          	add    $0x8,%rsp
  804160377d:	5b                   	pop    %rbx
  804160377e:	41 5c                	pop    %r12
  8041603780:	41 5d                	pop    %r13
  8041603782:	5d                   	pop    %rbp
  8041603783:	c3                   	retq   

0000008041603784 <mon_hello>:

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  8041603784:	55                   	push   %rbp
  8041603785:	48 89 e5             	mov    %rsp,%rbp
  cprintf("Hello!\n");
  8041603788:	48 bf 91 58 60 41 80 	movabs $0x8041605891,%rdi
  804160378f:	00 00 00 
  8041603792:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603797:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  804160379e:	00 00 00 
  80416037a1:	ff d2                	callq  *%rdx
  return 0;
}
  80416037a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037a8:	5d                   	pop    %rbp
  80416037a9:	c3                   	retq   

00000080416037aa <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  80416037aa:	55                   	push   %rbp
  80416037ab:	48 89 e5             	mov    %rsp,%rbp
  80416037ae:	41 55                	push   %r13
  80416037b0:	41 54                	push   %r12
  80416037b2:	53                   	push   %rbx
  80416037b3:	48 83 ec 08          	sub    $0x8,%rsp
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  80416037b7:	48 bf 99 58 60 41 80 	movabs $0x8041605899,%rdi
  80416037be:	00 00 00 
  80416037c1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037c6:	49 bc 70 3f 60 41 80 	movabs $0x8041603f70,%r12
  80416037cd:	00 00 00 
  80416037d0:	41 ff d4             	callq  *%r12
  cprintf("  _head64                  %08lx (phys)\n",
  80416037d3:	48 be 00 00 50 01 00 	movabs $0x1500000,%rsi
  80416037da:	00 00 00 
  80416037dd:	48 bf e0 59 60 41 80 	movabs $0x80416059e0,%rdi
  80416037e4:	00 00 00 
  80416037e7:	b8 00 00 00 00       	mov    $0x0,%eax
  80416037ec:	41 ff d4             	callq  *%r12
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  80416037ef:	49 bd 00 00 60 41 80 	movabs $0x8041600000,%r13
  80416037f6:	00 00 00 
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
  80416037f9:	48 ba 00 00 60 01 00 	movabs $0x1600000,%rdx
  8041603800:	00 00 00 
  8041603803:	4c 89 ee             	mov    %r13,%rsi
  8041603806:	48 bf 10 5a 60 41 80 	movabs $0x8041605a10,%rdi
  804160380d:	00 00 00 
  8041603810:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603815:	41 ff d4             	callq  *%r12
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
  8041603818:	48 ba 70 52 60 01 00 	movabs $0x1605270,%rdx
  804160381f:	00 00 00 
  8041603822:	48 be 70 52 60 41 80 	movabs $0x8041605270,%rsi
  8041603829:	00 00 00 
  804160382c:	48 bf 38 5a 60 41 80 	movabs $0x8041605a38,%rdi
  8041603833:	00 00 00 
  8041603836:	b8 00 00 00 00       	mov    $0x0,%eax
  804160383b:	41 ff d4             	callq  *%r12
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
  804160383e:	48 ba d0 35 62 01 00 	movabs $0x16235d0,%rdx
  8041603845:	00 00 00 
  8041603848:	48 be d0 35 62 41 80 	movabs $0x80416235d0,%rsi
  804160384f:	00 00 00 
  8041603852:	48 bf 60 5a 60 41 80 	movabs $0x8041605a60,%rdi
  8041603859:	00 00 00 
  804160385c:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603861:	41 ff d4             	callq  *%r12
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  8041603864:	48 bb 00 60 62 41 80 	movabs $0x8041626000,%rbx
  804160386b:	00 00 00 
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
  804160386e:	48 ba 00 60 62 01 00 	movabs $0x1626000,%rdx
  8041603875:	00 00 00 
  8041603878:	48 89 de             	mov    %rbx,%rsi
  804160387b:	48 bf 88 5a 60 41 80 	movabs $0x8041605a88,%rdi
  8041603882:	00 00 00 
  8041603885:	b8 00 00 00 00       	mov    $0x0,%eax
  804160388a:	41 ff d4             	callq  *%r12
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  804160388d:	4c 29 eb             	sub    %r13,%rbx
  8041603890:	48 8d b3 ff 03 00 00 	lea    0x3ff(%rbx),%rsi
  cprintf("Kernel executable memory footprint: %luKB\n",
  8041603897:	48 c1 ee 0a          	shr    $0xa,%rsi
  804160389b:	48 bf b0 5a 60 41 80 	movabs $0x8041605ab0,%rdi
  80416038a2:	00 00 00 
  80416038a5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038aa:	41 ff d4             	callq  *%r12
  return 0;
}
  80416038ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038b2:	48 83 c4 08          	add    $0x8,%rsp
  80416038b6:	5b                   	pop    %rbx
  80416038b7:	41 5c                	pop    %r12
  80416038b9:	41 5d                	pop    %r13
  80416038bb:	5d                   	pop    %rbp
  80416038bc:	c3                   	retq   

00000080416038bd <mon_evenbeyond>:

int
mon_evenbeyond(int argc, char **argv, struct Trapframe *tf) {
  80416038bd:	55                   	push   %rbp
  80416038be:	48 89 e5             	mov    %rsp,%rbp
  cprintf("My CPU load is OVER %o \n", 9000);
  80416038c1:	be 28 23 00 00       	mov    $0x2328,%esi
  80416038c6:	48 bf b2 58 60 41 80 	movabs $0x80416058b2,%rdi
  80416038cd:	00 00 00 
  80416038d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038d5:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  80416038dc:	00 00 00 
  80416038df:	ff d2                	callq  *%rdx
  return 0;
}
  80416038e1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416038e6:	5d                   	pop    %rbp
  80416038e7:	c3                   	retq   

00000080416038e8 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  80416038e8:	55                   	push   %rbp
  80416038e9:	48 89 e5             	mov    %rsp,%rbp
  80416038ec:	41 57                	push   %r15
  80416038ee:	41 56                	push   %r14
  80416038f0:	41 55                	push   %r13
  80416038f2:	41 54                	push   %r12
  80416038f4:	53                   	push   %rbx
  80416038f5:	48 81 ec 28 02 00 00 	sub    $0x228,%rsp
  uint64_t *rbp = 0x0;
  uint64_t rip  = 0x0;

  struct Ripdebuginfo info;

  cprintf("Stack backtrace:\n");
  80416038fc:	48 bf cb 58 60 41 80 	movabs $0x80416058cb,%rdi
  8041603903:	00 00 00 
  8041603906:	b8 00 00 00 00       	mov    $0x0,%eax
  804160390b:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041603912:	00 00 00 
  8041603915:	ff d2                	callq  *%rdx
}

static __inline uint64_t
read_rbp(void) {
  uint64_t ebp;
  __asm __volatile("movq %%rbp,%0"
  8041603917:	48 89 e8             	mov    %rbp,%rax
  rbp = (uint64_t *)read_rbp();
  rip = rbp[1];

  if (rbp == 0x0 || rip == 0x0) {
  804160391a:	48 83 78 08 00       	cmpq   $0x0,0x8(%rax)
  804160391f:	0f 84 a2 00 00 00    	je     80416039c7 <mon_backtrace+0xdf>
  8041603925:	48 89 c3             	mov    %rax,%rbx
  8041603928:	48 85 c0             	test   %rax,%rax
  804160392b:	0f 84 96 00 00 00    	je     80416039c7 <mon_backtrace+0xdf>
    return -1;
  }

  do {
    rip = rbp[1];
    debuginfo_rip(rip, &info);
  8041603931:	49 bf 40 41 60 41 80 	movabs $0x8041604140,%r15
  8041603938:	00 00 00 

    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  804160393b:	49 bd 70 3f 60 41 80 	movabs $0x8041603f70,%r13
  8041603942:	00 00 00 
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  8041603945:	48 8d 85 b0 fd ff ff 	lea    -0x250(%rbp),%rax
  804160394c:	4c 8d b0 04 01 00 00 	lea    0x104(%rax),%r14
    rip = rbp[1];
  8041603953:	4c 8b 63 08          	mov    0x8(%rbx),%r12
    debuginfo_rip(rip, &info);
  8041603957:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  804160395e:	4c 89 e7             	mov    %r12,%rdi
  8041603961:	41 ff d7             	callq  *%r15
    cprintf("  rbp %016lx  rip %016lx\n", (long unsigned int)rbp, (long unsigned int)rip);
  8041603964:	4c 89 e2             	mov    %r12,%rdx
  8041603967:	48 89 de             	mov    %rbx,%rsi
  804160396a:	48 bf dd 58 60 41 80 	movabs $0x80416058dd,%rdi
  8041603971:	00 00 00 
  8041603974:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603979:	41 ff d5             	callq  *%r13
    cprintf("         %.256s:%d: %.*s+%ld\n", info.rip_file, info.rip_line,
  804160397c:	4d 89 e1             	mov    %r12,%r9
  804160397f:	4c 2b 4d b8          	sub    -0x48(%rbp),%r9
  8041603983:	4d 89 f0             	mov    %r14,%r8
  8041603986:	8b 4d b4             	mov    -0x4c(%rbp),%ecx
  8041603989:	8b 95 b0 fe ff ff    	mov    -0x150(%rbp),%edx
  804160398f:	48 8d b5 b0 fd ff ff 	lea    -0x250(%rbp),%rsi
  8041603996:	48 bf f7 58 60 41 80 	movabs $0x80416058f7,%rdi
  804160399d:	00 00 00 
  80416039a0:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039a5:	41 ff d5             	callq  *%r13
            info.rip_fn_namelen, info.rip_fn_name, (rip - info.rip_fn_addr));
    // cprintf(" args:%d \n", info.rip_fn_narg);
    rbp = (uint64_t *)rbp[0];
  80416039a8:	48 8b 1b             	mov    (%rbx),%rbx

  } while (rbp);
  80416039ab:	48 85 db             	test   %rbx,%rbx
  80416039ae:	75 a3                	jne    8041603953 <mon_backtrace+0x6b>

  return 0;
  80416039b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416039b5:	48 81 c4 28 02 00 00 	add    $0x228,%rsp
  80416039bc:	5b                   	pop    %rbx
  80416039bd:	41 5c                	pop    %r12
  80416039bf:	41 5d                	pop    %r13
  80416039c1:	41 5e                	pop    %r14
  80416039c3:	41 5f                	pop    %r15
  80416039c5:	5d                   	pop    %rbp
  80416039c6:	c3                   	retq   
    cprintf("JOS: ERR: Couldn't obtain backtrace...\n");
  80416039c7:	48 bf e0 5a 60 41 80 	movabs $0x8041605ae0,%rdi
  80416039ce:	00 00 00 
  80416039d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80416039d6:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  80416039dd:	00 00 00 
  80416039e0:	ff d2                	callq  *%rdx
    return -1;
  80416039e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80416039e7:	eb cc                	jmp    80416039b5 <mon_backtrace+0xcd>

00000080416039e9 <monitor>:
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  80416039e9:	55                   	push   %rbp
  80416039ea:	48 89 e5             	mov    %rsp,%rbp
  80416039ed:	41 57                	push   %r15
  80416039ef:	41 56                	push   %r14
  80416039f1:	41 55                	push   %r13
  80416039f3:	41 54                	push   %r12
  80416039f5:	53                   	push   %rbx
  80416039f6:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  80416039fd:	48 89 bd 48 ff ff ff 	mov    %rdi,-0xb8(%rbp)
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  8041603a04:	48 bf 08 5b 60 41 80 	movabs $0x8041605b08,%rdi
  8041603a0b:	00 00 00 
  8041603a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a13:	48 bb 70 3f 60 41 80 	movabs $0x8041603f70,%rbx
  8041603a1a:	00 00 00 
  8041603a1d:	ff d3                	callq  *%rbx
  cprintf("Type 'help' for a list of commands.\n");
  8041603a1f:	48 bf 30 5b 60 41 80 	movabs $0x8041605b30,%rdi
  8041603a26:	00 00 00 
  8041603a29:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603a2e:	ff d3                	callq  *%rbx

  while (1) {
    buf = readline("K> ");
  8041603a30:	49 bf 44 4c 60 41 80 	movabs $0x8041604c44,%r15
  8041603a37:	00 00 00 
    while (*buf && strchr(WHITESPACE, *buf))
  8041603a3a:	49 be f4 4e 60 41 80 	movabs $0x8041604ef4,%r14
  8041603a41:	00 00 00 
  8041603a44:	e9 ff 00 00 00       	jmpq   8041603b48 <monitor+0x15f>
  8041603a49:	40 0f be f6          	movsbl %sil,%esi
  8041603a4d:	48 bf 19 59 60 41 80 	movabs $0x8041605919,%rdi
  8041603a54:	00 00 00 
  8041603a57:	41 ff d6             	callq  *%r14
  8041603a5a:	48 85 c0             	test   %rax,%rax
  8041603a5d:	74 0c                	je     8041603a6b <monitor+0x82>
      *buf++ = 0;
  8041603a5f:	c6 03 00             	movb   $0x0,(%rbx)
  8041603a62:	45 89 e5             	mov    %r12d,%r13d
  8041603a65:	48 8d 5b 01          	lea    0x1(%rbx),%rbx
  8041603a69:	eb 49                	jmp    8041603ab4 <monitor+0xcb>
    if (*buf == 0)
  8041603a6b:	80 3b 00             	cmpb   $0x0,(%rbx)
  8041603a6e:	74 4f                	je     8041603abf <monitor+0xd6>
    if (argc == MAXARGS - 1) {
  8041603a70:	41 83 fc 0f          	cmp    $0xf,%r12d
  8041603a74:	0f 84 b3 00 00 00    	je     8041603b2d <monitor+0x144>
    argv[argc++] = buf;
  8041603a7a:	45 8d 6c 24 01       	lea    0x1(%r12),%r13d
  8041603a7f:	4d 63 e4             	movslq %r12d,%r12
  8041603a82:	4a 89 9c e5 50 ff ff 	mov    %rbx,-0xb0(%rbp,%r12,8)
  8041603a89:	ff 
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603a8a:	0f b6 33             	movzbl (%rbx),%esi
  8041603a8d:	40 84 f6             	test   %sil,%sil
  8041603a90:	74 22                	je     8041603ab4 <monitor+0xcb>
  8041603a92:	40 0f be f6          	movsbl %sil,%esi
  8041603a96:	48 bf 19 59 60 41 80 	movabs $0x8041605919,%rdi
  8041603a9d:	00 00 00 
  8041603aa0:	41 ff d6             	callq  *%r14
  8041603aa3:	48 85 c0             	test   %rax,%rax
  8041603aa6:	75 0c                	jne    8041603ab4 <monitor+0xcb>
      buf++;
  8041603aa8:	48 83 c3 01          	add    $0x1,%rbx
    while (*buf && !strchr(WHITESPACE, *buf))
  8041603aac:	0f b6 33             	movzbl (%rbx),%esi
  8041603aaf:	40 84 f6             	test   %sil,%sil
  8041603ab2:	75 de                	jne    8041603a92 <monitor+0xa9>
      *buf++ = 0;
  8041603ab4:	45 89 ec             	mov    %r13d,%r12d
    while (*buf && strchr(WHITESPACE, *buf))
  8041603ab7:	0f b6 33             	movzbl (%rbx),%esi
  8041603aba:	40 84 f6             	test   %sil,%sil
  8041603abd:	75 8a                	jne    8041603a49 <monitor+0x60>
  argv[argc] = 0;
  8041603abf:	49 63 c4             	movslq %r12d,%rax
  8041603ac2:	48 c7 84 c5 50 ff ff 	movq   $0x0,-0xb0(%rbp,%rax,8)
  8041603ac9:	ff 00 00 00 00 
  if (argc == 0)
  8041603ace:	45 85 e4             	test   %r12d,%r12d
  8041603ad1:	74 75                	je     8041603b48 <monitor+0x15f>
  8041603ad3:	49 bd 80 5b 60 41 80 	movabs $0x8041605b80,%r13
  8041603ada:	00 00 00 
  for (i = 0; i < NCOMMANDS; i++) {
  8041603add:	bb 00 00 00 00       	mov    $0x0,%ebx
    if (strcmp(argv[0], commands[i].name) == 0)
  8041603ae2:	49 8b 75 00          	mov    0x0(%r13),%rsi
  8041603ae6:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8041603aed:	48 b8 8d 4e 60 41 80 	movabs $0x8041604e8d,%rax
  8041603af4:	00 00 00 
  8041603af7:	ff d0                	callq  *%rax
  8041603af9:	85 c0                	test   %eax,%eax
  8041603afb:	74 76                	je     8041603b73 <monitor+0x18a>
  for (i = 0; i < NCOMMANDS; i++) {
  8041603afd:	83 c3 01             	add    $0x1,%ebx
  8041603b00:	49 83 c5 18          	add    $0x18,%r13
  8041603b04:	83 fb 05             	cmp    $0x5,%ebx
  8041603b07:	75 d9                	jne    8041603ae2 <monitor+0xf9>
  cprintf("Unknown command '%s'\n", argv[0]);
  8041603b09:	48 8b b5 50 ff ff ff 	mov    -0xb0(%rbp),%rsi
  8041603b10:	48 bf 3b 59 60 41 80 	movabs $0x804160593b,%rdi
  8041603b17:	00 00 00 
  8041603b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603b1f:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041603b26:	00 00 00 
  8041603b29:	ff d2                	callq  *%rdx
  return 0;
  8041603b2b:	eb 1b                	jmp    8041603b48 <monitor+0x15f>
      cprintf("Too many arguments (max %d)\n", MAXARGS);
  8041603b2d:	be 10 00 00 00       	mov    $0x10,%esi
  8041603b32:	48 bf 1e 59 60 41 80 	movabs $0x804160591e,%rdi
  8041603b39:	00 00 00 
  8041603b3c:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041603b43:	00 00 00 
  8041603b46:	ff d2                	callq  *%rdx
    buf = readline("K> ");
  8041603b48:	48 bf 15 59 60 41 80 	movabs $0x8041605915,%rdi
  8041603b4f:	00 00 00 
  8041603b52:	41 ff d7             	callq  *%r15
  8041603b55:	48 89 c3             	mov    %rax,%rbx
    if (buf != NULL)
  8041603b58:	48 85 c0             	test   %rax,%rax
  8041603b5b:	74 eb                	je     8041603b48 <monitor+0x15f>
  argv[argc] = 0;
  8041603b5d:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  8041603b64:	00 00 00 00 
  argc       = 0;
  8041603b68:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  8041603b6e:	e9 44 ff ff ff       	jmpq   8041603ab7 <monitor+0xce>
      return commands[i].func(argc, argv, tf);
  8041603b73:	48 63 db             	movslq %ebx,%rbx
  8041603b76:	48 8d 0c 5b          	lea    (%rbx,%rbx,2),%rcx
  8041603b7a:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  8041603b81:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  8041603b88:	44 89 e7             	mov    %r12d,%edi
  8041603b8b:	48 b8 80 5b 60 41 80 	movabs $0x8041605b80,%rax
  8041603b92:	00 00 00 
  8041603b95:	ff 54 c8 10          	callq  *0x10(%rax,%rcx,8)
      if (runcmd(buf, tf) < 0)
  8041603b99:	85 c0                	test   %eax,%eax
  8041603b9b:	79 ab                	jns    8041603b48 <monitor+0x15f>
        break;
  }
}
  8041603b9d:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8041603ba4:	5b                   	pop    %rbx
  8041603ba5:	41 5c                	pop    %r12
  8041603ba7:	41 5d                	pop    %r13
  8041603ba9:	41 5e                	pop    %r14
  8041603bab:	41 5f                	pop    %r15
  8041603bad:	5d                   	pop    %rbp
  8041603bae:	c3                   	retq   

0000008041603baf <envid2env>:
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
  8041603baf:	85 ff                	test   %edi,%edi
  8041603bb1:	74 5c                	je     8041603c0f <envid2env+0x60>
  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  8041603bb3:	89 f8                	mov    %edi,%eax
  8041603bb5:	83 e0 1f             	and    $0x1f,%eax
  8041603bb8:	48 8d 0c c5 00 00 00 	lea    0x0(,%rax,8),%rcx
  8041603bbf:	00 
  8041603bc0:	48 29 c1             	sub    %rax,%rcx
  8041603bc3:	48 c1 e1 05          	shl    $0x5,%rcx
  8041603bc7:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  8041603bce:	00 00 00 
  8041603bd1:	48 01 c1             	add    %rax,%rcx
  if (e->env_status == ENV_FREE || e->env_id != envid) {
  8041603bd4:	83 b9 d4 00 00 00 00 	cmpl   $0x0,0xd4(%rcx)
  8041603bdb:	74 42                	je     8041603c1f <envid2env+0x70>
  8041603bdd:	39 b9 c8 00 00 00    	cmp    %edi,0xc8(%rcx)
  8041603be3:	75 3a                	jne    8041603c1f <envid2env+0x70>
  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
  8041603be5:	84 d2                	test   %dl,%dl
  8041603be7:	74 1d                	je     8041603c06 <envid2env+0x57>
  8041603be9:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603bf0:	00 00 00 
  8041603bf3:	48 39 c8             	cmp    %rcx,%rax
  8041603bf6:	74 0e                	je     8041603c06 <envid2env+0x57>
  8041603bf8:	8b 80 c8 00 00 00    	mov    0xc8(%rax),%eax
  8041603bfe:	39 81 cc 00 00 00    	cmp    %eax,0xcc(%rcx)
  8041603c04:	75 26                	jne    8041603c2c <envid2env+0x7d>
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  8041603c06:	48 89 0e             	mov    %rcx,(%rsi)
  return 0;
  8041603c09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603c0e:	c3                   	retq   
    *env_store = curenv;
  8041603c0f:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603c16:	00 00 00 
  8041603c19:	48 89 06             	mov    %rax,(%rsi)
    return 0;
  8041603c1c:	89 f8                	mov    %edi,%eax
  8041603c1e:	c3                   	retq   
    *env_store = 0;
  8041603c1f:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603c26:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603c2b:	c3                   	retq   
    *env_store = 0;
  8041603c2c:	48 c7 06 00 00 00 00 	movq   $0x0,(%rsi)
    return -E_BAD_ENV;
  8041603c33:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8041603c38:	c3                   	retq   

0000008041603c39 <env_init>:
//
void
env_init(void) {
  // Set up envs array
  // LAB 3: Your code here.
}
  8041603c39:	c3                   	retq   

0000008041603c3a <env_init_percpu>:

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  8041603c3a:	55                   	push   %rbp
  8041603c3b:	48 89 e5             	mov    %rsp,%rbp
  8041603c3e:	53                   	push   %rbx
  __asm __volatile("lgdt (%0)"
  8041603c3f:	48 b8 20 77 61 41 80 	movabs $0x8041617720,%rax
  8041603c46:	00 00 00 
  8041603c49:	0f 01 10             	lgdt   (%rax)
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  8041603c4c:	b8 33 00 00 00       	mov    $0x33,%eax
  8041603c51:	8e e8                	mov    %eax,%gs
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  8041603c53:	8e e0                	mov    %eax,%fs
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  8041603c55:	b8 10 00 00 00       	mov    $0x10,%eax
  8041603c5a:	8e c0                	mov    %eax,%es
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  8041603c5c:	8e d8                	mov    %eax,%ds
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  8041603c5e:	8e d0                	mov    %eax,%ss
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
  8041603c60:	bb 08 00 00 00       	mov    $0x8,%ebx
  8041603c65:	53                   	push   %rbx
  8041603c66:	48 b8 73 3c 60 41 80 	movabs $0x8041603c73,%rax
  8041603c6d:	00 00 00 
  8041603c70:	50                   	push   %rax
  8041603c71:	48 cb                	lretq  
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
  8041603c73:	66 b8 00 00          	mov    $0x0,%ax
  8041603c77:	0f 00 d0             	lldt   %ax
               :
               :
               : "cc", "memory");
}
  8041603c7a:	5b                   	pop    %rbx
  8041603c7b:	5d                   	pop    %rbp
  8041603c7c:	c3                   	retq   

0000008041603c7d <env_alloc>:
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  8041603c7d:	55                   	push   %rbp
  8041603c7e:	48 89 e5             	mov    %rsp,%rbp
  8041603c81:	41 54                	push   %r12
  8041603c83:	53                   	push   %rbx
  int32_t generation;
  struct Env *e;

  if (!(e = env_free_list)) {
  8041603c84:	48 b8 48 38 62 41 80 	movabs $0x8041623848,%rax
  8041603c8b:	00 00 00 
  8041603c8e:	48 8b 18             	mov    (%rax),%rbx
  8041603c91:	48 85 db             	test   %rbx,%rbx
  8041603c94:	0f 84 f6 00 00 00    	je     8041603d90 <env_alloc+0x113>
  8041603c9a:	49 89 fc             	mov    %rdi,%r12
    return -E_NO_FREE_ENV;
  }

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  8041603c9d:	8b 83 c8 00 00 00    	mov    0xc8(%rbx),%eax
  8041603ca3:	05 00 10 00 00       	add    $0x1000,%eax
  if (generation <= 0) // Don't create a negative env_id.
  8041603ca8:	83 e0 e0             	and    $0xffffffe0,%eax
    generation = 1 << ENVGENSHIFT;
  8041603cab:	ba 00 10 00 00       	mov    $0x1000,%edx
  8041603cb0:	0f 4e c2             	cmovle %edx,%eax
  e->env_id = generation | (e - envs);
  8041603cb3:	48 ba 88 77 61 41 80 	movabs $0x8041617788,%rdx
  8041603cba:	00 00 00 
  8041603cbd:	48 89 d9             	mov    %rbx,%rcx
  8041603cc0:	48 2b 0a             	sub    (%rdx),%rcx
  8041603cc3:	48 89 ca             	mov    %rcx,%rdx
  8041603cc6:	48 c1 fa 05          	sar    $0x5,%rdx
  8041603cca:	69 d2 b7 6d db b6    	imul   $0xb6db6db7,%edx,%edx
  8041603cd0:	09 d0                	or     %edx,%eax
  8041603cd2:	89 83 c8 00 00 00    	mov    %eax,0xc8(%rbx)

  // Set the basic status variables.
  e->env_parent_id = parent_id;
  8041603cd8:	89 b3 cc 00 00 00    	mov    %esi,0xcc(%rbx)
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
  8041603cde:	c7 83 d0 00 00 00 01 	movl   $0x1,0xd0(%rbx)
  8041603ce5:	00 00 00 
#else
#endif
  e->env_status = ENV_RUNNABLE;
  8041603ce8:	c7 83 d4 00 00 00 02 	movl   $0x2,0xd4(%rbx)
  8041603cef:	00 00 00 
  e->env_runs   = 0;
  8041603cf2:	c7 83 d8 00 00 00 00 	movl   $0x0,0xd8(%rbx)
  8041603cf9:	00 00 00 

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));
  8041603cfc:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041603d01:	be 00 00 00 00       	mov    $0x0,%esi
  8041603d06:	48 89 df             	mov    %rbx,%rdi
  8041603d09:	48 b8 46 4f 60 41 80 	movabs $0x8041604f46,%rax
  8041603d10:	00 00 00 
  8041603d13:	ff d0                	callq  *%rax
  // Requestor Privilege Level (RPL); 3 means user mode, 0 - kernel mode.  When
  // we switch privilege levels, the hardware does various
  // checks involving the RPL and the Descriptor Privilege Level
  // (DPL) stored in the descriptors themselves.
#ifdef CONFIG_KSPACE
  e->env_tf.tf_ds = GD_KD | 0;
  8041603d15:	66 c7 83 80 00 00 00 	movw   $0x10,0x80(%rbx)
  8041603d1c:	10 00 
  e->env_tf.tf_es = GD_KD | 0;
  8041603d1e:	66 c7 43 78 10 00    	movw   $0x10,0x78(%rbx)
  e->env_tf.tf_ss = GD_KD | 0;
  8041603d24:	66 c7 83 b8 00 00 00 	movw   $0x10,0xb8(%rbx)
  8041603d2b:	10 00 
  e->env_tf.tf_cs = GD_KT | 0;
  8041603d2d:	66 c7 83 a0 00 00 00 	movw   $0x8,0xa0(%rbx)
  8041603d34:	08 00 
#else
#endif
  // You will set e->env_tf.tf_rip later.

  // commit the allocation
  env_free_list = e->env_link;
  8041603d36:	48 8b 83 c0 00 00 00 	mov    0xc0(%rbx),%rax
  8041603d3d:	48 a3 48 38 62 41 80 	movabs %rax,0x8041623848
  8041603d44:	00 00 00 
  *newenv_store = e;
  8041603d47:	49 89 1c 24          	mov    %rbx,(%r12)

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603d4b:	8b 93 c8 00 00 00    	mov    0xc8(%rbx),%edx
  8041603d51:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603d58:	00 00 00 
  8041603d5b:	be 00 00 00 00       	mov    $0x0,%esi
  8041603d60:	48 85 c0             	test   %rax,%rax
  8041603d63:	74 06                	je     8041603d6b <env_alloc+0xee>
  8041603d65:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041603d6b:	48 bf f8 5b 60 41 80 	movabs $0x8041605bf8,%rdi
  8041603d72:	00 00 00 
  8041603d75:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603d7a:	48 b9 70 3f 60 41 80 	movabs $0x8041603f70,%rcx
  8041603d81:	00 00 00 
  8041603d84:	ff d1                	callq  *%rcx

  return 0;
  8041603d86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8041603d8b:	5b                   	pop    %rbx
  8041603d8c:	41 5c                	pop    %r12
  8041603d8e:	5d                   	pop    %rbp
  8041603d8f:	c3                   	retq   
    return -E_NO_FREE_ENV;
  8041603d90:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
  8041603d95:	eb f4                	jmp    8041603d8b <env_alloc+0x10e>

0000008041603d97 <env_create>:
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {
  // LAB 3: Your code here.
}
  8041603d97:	c3                   	retq   

0000008041603d98 <env_free>:

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
  8041603d98:	55                   	push   %rbp
  8041603d99:	48 89 e5             	mov    %rsp,%rbp
  8041603d9c:	53                   	push   %rbx
  8041603d9d:	48 83 ec 08          	sub    $0x8,%rsp
  8041603da1:	48 89 fb             	mov    %rdi,%rbx
  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
  8041603da4:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041603daa:	48 a1 40 38 62 41 80 	movabs 0x8041623840,%rax
  8041603db1:	00 00 00 
  8041603db4:	be 00 00 00 00       	mov    $0x0,%esi
  8041603db9:	48 85 c0             	test   %rax,%rax
  8041603dbc:	74 06                	je     8041603dc4 <env_free+0x2c>
  8041603dbe:	8b b0 c8 00 00 00    	mov    0xc8(%rax),%esi
  8041603dc4:	48 bf 0d 5c 60 41 80 	movabs $0x8041605c0d,%rdi
  8041603dcb:	00 00 00 
  8041603dce:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603dd3:	48 b9 70 3f 60 41 80 	movabs $0x8041603f70,%rcx
  8041603dda:	00 00 00 
  8041603ddd:	ff d1                	callq  *%rcx

  // return the environment to the free list
  e->env_status = ENV_FREE;
  8041603ddf:	c7 83 d4 00 00 00 00 	movl   $0x0,0xd4(%rbx)
  8041603de6:	00 00 00 
  e->env_link   = env_free_list;
  8041603de9:	48 b8 48 38 62 41 80 	movabs $0x8041623848,%rax
  8041603df0:	00 00 00 
  8041603df3:	48 8b 10             	mov    (%rax),%rdx
  8041603df6:	48 89 93 c0 00 00 00 	mov    %rdx,0xc0(%rbx)
  env_free_list = e;
  8041603dfd:	48 89 18             	mov    %rbx,(%rax)
}
  8041603e00:	48 83 c4 08          	add    $0x8,%rsp
  8041603e04:	5b                   	pop    %rbx
  8041603e05:	5d                   	pop    %rbp
  8041603e06:	c3                   	retq   

0000008041603e07 <env_destroy>:
env_destroy(struct Env *e) {
  // LAB 3: Your code here.
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.
}
  8041603e07:	c3                   	retq   

0000008041603e08 <csys_exit>:

#ifdef CONFIG_KSPACE
void
csys_exit(void) {
  env_destroy(curenv);
}
  8041603e08:	c3                   	retq   

0000008041603e09 <csys_yield>:

void
csys_yield(struct Trapframe *tf) {
  8041603e09:	55                   	push   %rbp
  8041603e0a:	48 89 e5             	mov    %rsp,%rbp
  8041603e0d:	48 89 fe             	mov    %rdi,%rsi
  memcpy(&curenv->env_tf, tf, sizeof(struct Trapframe));
  8041603e10:	ba c0 00 00 00       	mov    $0xc0,%edx
  8041603e15:	48 b8 40 38 62 41 80 	movabs $0x8041623840,%rax
  8041603e1c:	00 00 00 
  8041603e1f:	48 8b 38             	mov    (%rax),%rdi
  8041603e22:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041603e29:	00 00 00 
  8041603e2c:	ff d0                	callq  *%rax
  sched_yield();
  8041603e2e:	48 b8 04 40 60 41 80 	movabs $0x8041604004,%rax
  8041603e35:	00 00 00 
  8041603e38:	ff d0                	callq  *%rax

0000008041603e3a <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
  8041603e3a:	55                   	push   %rbp
  8041603e3b:	48 89 e5             	mov    %rsp,%rbp
  8041603e3e:	53                   	push   %rbx
  8041603e3f:	48 83 ec 08          	sub    $0x8,%rsp
  8041603e43:	48 89 f8             	mov    %rdi,%rax
#ifdef CONFIG_KSPACE
  static uintptr_t rip = 0;
  rip                  = tf->tf_rip;

  asm volatile(
  8041603e46:	48 8b 58 68          	mov    0x68(%rax),%rbx
  8041603e4a:	48 8b 48 60          	mov    0x60(%rax),%rcx
  8041603e4e:	48 8b 50 58          	mov    0x58(%rax),%rdx
  8041603e52:	48 8b 70 40          	mov    0x40(%rax),%rsi
  8041603e56:	48 8b 78 48          	mov    0x48(%rax),%rdi
  8041603e5a:	48 8b 68 50          	mov    0x50(%rax),%rbp
  8041603e5e:	48 8b a0 b0 00 00 00 	mov    0xb0(%rax),%rsp
  8041603e65:	4c 8b 40 38          	mov    0x38(%rax),%r8
  8041603e69:	4c 8b 48 30          	mov    0x30(%rax),%r9
  8041603e6d:	4c 8b 50 28          	mov    0x28(%rax),%r10
  8041603e71:	4c 8b 58 20          	mov    0x20(%rax),%r11
  8041603e75:	4c 8b 60 18          	mov    0x18(%rax),%r12
  8041603e79:	4c 8b 68 10          	mov    0x10(%rax),%r13
  8041603e7d:	4c 8b 70 08          	mov    0x8(%rax),%r14
  8041603e81:	4c 8b 38             	mov    (%rax),%r15
  8041603e84:	ff b0 98 00 00 00    	pushq  0x98(%rax)
  8041603e8a:	ff b0 a8 00 00 00    	pushq  0xa8(%rax)
  8041603e90:	48 8b 40 70          	mov    0x70(%rax),%rax
  8041603e94:	9d                   	popfq  
  8041603e95:	c3                   	retq   
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
#endif
  panic("BUG"); /* mostly to placate the compiler */
  8041603e96:	48 ba 23 5c 60 41 80 	movabs $0x8041605c23,%rdx
  8041603e9d:	00 00 00 
  8041603ea0:	be 7f 01 00 00       	mov    $0x17f,%esi
  8041603ea5:	48 bf 27 5c 60 41 80 	movabs $0x8041605c27,%rdi
  8041603eac:	00 00 00 
  8041603eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603eb4:	48 b9 89 03 60 41 80 	movabs $0x8041600389,%rcx
  8041603ebb:	00 00 00 
  8041603ebe:	ff d1                	callq  *%rcx

0000008041603ec0 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
  8041603ec0:	55                   	push   %rbp
  8041603ec1:	48 89 e5             	mov    %rsp,%rbp
#ifdef CONFIG_KSPACE
  cprintf("envrun %s: %d\n",
  8041603ec4:	8b 97 c8 00 00 00    	mov    0xc8(%rdi),%edx
  8041603eca:	83 e2 1f             	and    $0x1f,%edx
          e->env_status == ENV_RUNNING ? "RUNNING" :
  8041603ecd:	8b 87 d4 00 00 00    	mov    0xd4(%rdi),%eax
  cprintf("envrun %s: %d\n",
  8041603ed3:	48 be 32 5c 60 41 80 	movabs $0x8041605c32,%rsi
  8041603eda:	00 00 00 
  8041603edd:	83 f8 03             	cmp    $0x3,%eax
  8041603ee0:	74 1b                	je     8041603efd <env_run+0x3d>
                                         e->env_status == ENV_RUNNABLE ? "RUNNABLE" : "(unknown)",
  8041603ee2:	83 f8 02             	cmp    $0x2,%eax
  8041603ee5:	48 be 3a 5c 60 41 80 	movabs $0x8041605c3a,%rsi
  8041603eec:	00 00 00 
  8041603eef:	48 b8 43 5c 60 41 80 	movabs $0x8041605c43,%rax
  8041603ef6:	00 00 00 
  8041603ef9:	48 0f 45 f0          	cmovne %rax,%rsi
  cprintf("envrun %s: %d\n",
  8041603efd:	48 bf 4d 5c 60 41 80 	movabs $0x8041605c4d,%rdi
  8041603f04:	00 00 00 
  8041603f07:	b8 00 00 00 00       	mov    $0x0,%eax
  8041603f0c:	48 b9 70 3f 60 41 80 	movabs $0x8041603f70,%rcx
  8041603f13:	00 00 00 
  8041603f16:	ff d1                	callq  *%rcx
  //	e->env_tf.  Go back through the code you wrote above
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //
  // LAB 3: Your code here.
  while(1) {}
  8041603f18:	eb fe                	jmp    8041603f18 <env_run+0x58>

0000008041603f1a <putch>:
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>

static void
putch(int ch, int *cnt) {
  8041603f1a:	55                   	push   %rbp
  8041603f1b:	48 89 e5             	mov    %rsp,%rbp
  8041603f1e:	53                   	push   %rbx
  8041603f1f:	48 83 ec 08          	sub    $0x8,%rsp
  8041603f23:	48 89 f3             	mov    %rsi,%rbx
  cputchar(ch);
  8041603f26:	48 b8 11 0c 60 41 80 	movabs $0x8041600c11,%rax
  8041603f2d:	00 00 00 
  8041603f30:	ff d0                	callq  *%rax
  (*cnt)++;
  8041603f32:	83 03 01             	addl   $0x1,(%rbx)
}
  8041603f35:	48 83 c4 08          	add    $0x8,%rsp
  8041603f39:	5b                   	pop    %rbx
  8041603f3a:	5d                   	pop    %rbp
  8041603f3b:	c3                   	retq   

0000008041603f3c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  8041603f3c:	55                   	push   %rbp
  8041603f3d:	48 89 e5             	mov    %rsp,%rbp
  8041603f40:	48 83 ec 10          	sub    $0x10,%rsp
  8041603f44:	48 89 fa             	mov    %rdi,%rdx
  8041603f47:	48 89 f1             	mov    %rsi,%rcx
  int cnt = 0;
  8041603f4a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)

  vprintfmt((void *)putch, &cnt, fmt, ap);
  8041603f51:	48 8d 75 fc          	lea    -0x4(%rbp),%rsi
  8041603f55:	48 bf 1a 3f 60 41 80 	movabs $0x8041603f1a,%rdi
  8041603f5c:	00 00 00 
  8041603f5f:	48 b8 8f 44 60 41 80 	movabs $0x804160448f,%rax
  8041603f66:	00 00 00 
  8041603f69:	ff d0                	callq  *%rax
  return cnt;
}
  8041603f6b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8041603f6e:	c9                   	leaveq 
  8041603f6f:	c3                   	retq   

0000008041603f70 <cprintf>:

int
cprintf(const char *fmt, ...) {
  8041603f70:	55                   	push   %rbp
  8041603f71:	48 89 e5             	mov    %rsp,%rbp
  8041603f74:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041603f7b:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8041603f82:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8041603f89:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041603f90:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041603f97:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041603f9e:	84 c0                	test   %al,%al
  8041603fa0:	74 20                	je     8041603fc2 <cprintf+0x52>
  8041603fa2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041603fa6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041603faa:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041603fae:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041603fb2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041603fb6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041603fba:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041603fbe:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  8041603fc2:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  8041603fc9:	00 00 00 
  8041603fcc:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041603fd3:	00 00 00 
  8041603fd6:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041603fda:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041603fe1:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041603fe8:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  8041603fef:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  8041603ff6:	48 b8 3c 3f 60 41 80 	movabs $0x8041603f3c,%rax
  8041603ffd:	00 00 00 
  8041604000:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  8041604002:	c9                   	leaveq 
  8041604003:	c3                   	retq   

0000008041604004 <sched_yield>:
  // If there are no runnable environments,
  // simply drop through to the code
  // below to halt the cpu.

  // LAB 3: Your code here.
}
  8041604004:	c3                   	retq   

0000008041604005 <sched_halt>:
  int i;

  // For debugging and testing purposes, if there are no runnable
  // environments in the system, then drop into the kernel monitor.
  for (i = 0; i < NENV; i++) {
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041604005:	48 a1 88 77 61 41 80 	movabs 0x8041617788,%rax
  804160400c:	00 00 00 
         envs[i].env_status == ENV_RUNNING ||
  804160400f:	8b b0 d4 00 00 00    	mov    0xd4(%rax),%esi
  8041604015:	8d 56 ff             	lea    -0x1(%rsi),%edx
    if ((envs[i].env_status == ENV_RUNNABLE ||
  8041604018:	83 fa 02             	cmp    $0x2,%edx
  804160401b:	76 5c                	jbe    8041604079 <sched_halt+0x74>
  804160401d:	48 8d 90 b4 01 00 00 	lea    0x1b4(%rax),%rdx
  for (i = 0; i < NENV; i++) {
  8041604024:	b9 01 00 00 00       	mov    $0x1,%ecx
         envs[i].env_status == ENV_RUNNING ||
  8041604029:	8b 02                	mov    (%rdx),%eax
  804160402b:	83 e8 01             	sub    $0x1,%eax
    if ((envs[i].env_status == ENV_RUNNABLE ||
  804160402e:	83 f8 02             	cmp    $0x2,%eax
  8041604031:	76 46                	jbe    8041604079 <sched_halt+0x74>
  for (i = 0; i < NENV; i++) {
  8041604033:	83 c1 01             	add    $0x1,%ecx
  8041604036:	48 81 c2 e0 00 00 00 	add    $0xe0,%rdx
  804160403d:	83 f9 20             	cmp    $0x20,%ecx
  8041604040:	75 e7                	jne    8041604029 <sched_halt+0x24>
sched_halt(void) {
  8041604042:	55                   	push   %rbp
  8041604043:	48 89 e5             	mov    %rsp,%rbp
  8041604046:	53                   	push   %rbx
  8041604047:	48 83 ec 08          	sub    $0x8,%rsp
         envs[i].env_status == ENV_DYING))
      break;
  }
  if (i == NENV) {
    cprintf("No runnable environments in the system!\n");
  804160404b:	48 bf 60 5c 60 41 80 	movabs $0x8041605c60,%rdi
  8041604052:	00 00 00 
  8041604055:	b8 00 00 00 00       	mov    $0x0,%eax
  804160405a:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041604061:	00 00 00 
  8041604064:	ff d2                	callq  *%rdx
    while (1)
      monitor(NULL);
  8041604066:	48 bb e9 39 60 41 80 	movabs $0x80416039e9,%rbx
  804160406d:	00 00 00 
  8041604070:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604075:	ff d3                	callq  *%rbx
    while (1)
  8041604077:	eb f7                	jmp    8041604070 <sched_halt+0x6b>
  }

  // Mark that no environment is running on CPU
  curenv = NULL;
  8041604079:	48 b8 40 38 62 41 80 	movabs $0x8041623840,%rax
  8041604080:	00 00 00 
  8041604083:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

  // Reset stack pointer, enable interrupts and then halt.
  asm volatile(
  804160408a:	48 a1 84 58 62 41 80 	movabs 0x8041625884,%rax
  8041604091:	00 00 00 
  8041604094:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  804160409b:	48 89 c4             	mov    %rax,%rsp
  804160409e:	6a 00                	pushq  $0x0
  80416040a0:	6a 00                	pushq  $0x0
  80416040a2:	fb                   	sti    
  80416040a3:	f4                   	hlt    
  80416040a4:	c3                   	retq   

00000080416040a5 <load_kernel_dwarf_info>:
#include <kern/env.h>
#include <inc/uefi.h>

void
load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin  = (unsigned char *)(uefi_lp->DebugArangesStart);
  80416040a5:	48 ba 00 70 61 41 80 	movabs $0x8041617000,%rdx
  80416040ac:	00 00 00 
  80416040af:	48 8b 02             	mov    (%rdx),%rax
  80416040b2:	48 8b 48 58          	mov    0x58(%rax),%rcx
  80416040b6:	48 89 4f 10          	mov    %rcx,0x10(%rdi)
  addrs->aranges_end    = (unsigned char *)(uefi_lp->DebugArangesEnd);
  80416040ba:	48 8b 48 60          	mov    0x60(%rax),%rcx
  80416040be:	48 89 4f 18          	mov    %rcx,0x18(%rdi)
  addrs->abbrev_begin   = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  80416040c2:	48 8b 40 68          	mov    0x68(%rax),%rax
  80416040c6:	48 89 07             	mov    %rax,(%rdi)
  addrs->abbrev_end     = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  80416040c9:	48 8b 02             	mov    (%rdx),%rax
  80416040cc:	48 8b 50 70          	mov    0x70(%rax),%rdx
  80416040d0:	48 89 57 08          	mov    %rdx,0x8(%rdi)
  addrs->info_begin     = (unsigned char *)(uefi_lp->DebugInfoStart);
  80416040d4:	48 8b 50 78          	mov    0x78(%rax),%rdx
  80416040d8:	48 89 57 20          	mov    %rdx,0x20(%rdi)
  addrs->info_end       = (unsigned char *)(uefi_lp->DebugInfoEnd);
  80416040dc:	48 8b 90 80 00 00 00 	mov    0x80(%rax),%rdx
  80416040e3:	48 89 57 28          	mov    %rdx,0x28(%rdi)
  addrs->line_begin     = (unsigned char *)(uefi_lp->DebugLineStart);
  80416040e7:	48 8b 90 88 00 00 00 	mov    0x88(%rax),%rdx
  80416040ee:	48 89 57 30          	mov    %rdx,0x30(%rdi)
  addrs->line_end       = (unsigned char *)(uefi_lp->DebugLineEnd);
  80416040f2:	48 8b 90 90 00 00 00 	mov    0x90(%rax),%rdx
  80416040f9:	48 89 57 38          	mov    %rdx,0x38(%rdi)
  addrs->str_begin      = (unsigned char *)(uefi_lp->DebugStrStart);
  80416040fd:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
  8041604104:	48 89 57 40          	mov    %rdx,0x40(%rdi)
  addrs->str_end        = (unsigned char *)(uefi_lp->DebugStrEnd);
  8041604108:	48 8b 90 a0 00 00 00 	mov    0xa0(%rax),%rdx
  804160410f:	48 89 57 48          	mov    %rdx,0x48(%rdi)
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  8041604113:	48 8b 90 a8 00 00 00 	mov    0xa8(%rax),%rdx
  804160411a:	48 89 57 50          	mov    %rdx,0x50(%rdi)
  addrs->pubnames_end   = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  804160411e:	48 8b 90 b0 00 00 00 	mov    0xb0(%rax),%rdx
  8041604125:	48 89 57 58          	mov    %rdx,0x58(%rdi)
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  8041604129:	48 8b 90 b8 00 00 00 	mov    0xb8(%rax),%rdx
  8041604130:	48 89 57 60          	mov    %rdx,0x60(%rdi)
  addrs->pubtypes_end   = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
  8041604134:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
  804160413b:	48 89 47 68          	mov    %rax,0x68(%rdi)
}
  804160413f:	c3                   	retq   

0000008041604140 <debuginfo_rip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  8041604140:	55                   	push   %rbp
  8041604141:	48 89 e5             	mov    %rsp,%rbp
  8041604144:	41 56                	push   %r14
  8041604146:	41 55                	push   %r13
  8041604148:	41 54                	push   %r12
  804160414a:	53                   	push   %rbx
  804160414b:	48 81 ec 90 00 00 00 	sub    $0x90,%rsp
  8041604152:	49 89 fc             	mov    %rdi,%r12
  8041604155:	48 89 f3             	mov    %rsi,%rbx
  int code = 0;
  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  8041604158:	48 be 89 5c 60 41 80 	movabs $0x8041605c89,%rsi
  804160415f:	00 00 00 
  8041604162:	48 89 df             	mov    %rbx,%rdi
  8041604165:	49 bd d5 4d 60 41 80 	movabs $0x8041604dd5,%r13
  804160416c:	00 00 00 
  804160416f:	41 ff d5             	callq  *%r13
  info->rip_line = 0;
  8041604172:	c7 83 00 01 00 00 00 	movl   $0x0,0x100(%rbx)
  8041604179:	00 00 00 
  strcpy(info->rip_fn_name, "<unknown>");
  804160417c:	4c 8d b3 04 01 00 00 	lea    0x104(%rbx),%r14
  8041604183:	48 be 89 5c 60 41 80 	movabs $0x8041605c89,%rsi
  804160418a:	00 00 00 
  804160418d:	4c 89 f7             	mov    %r14,%rdi
  8041604190:	41 ff d5             	callq  *%r13
  info->rip_fn_namelen = 9;
  8041604193:	c7 83 04 02 00 00 09 	movl   $0x9,0x204(%rbx)
  804160419a:	00 00 00 
  info->rip_fn_addr    = addr;
  804160419d:	4c 89 a3 08 02 00 00 	mov    %r12,0x208(%rbx)
  info->rip_fn_narg    = 0;
  80416041a4:	c7 83 10 02 00 00 00 	movl   $0x0,0x210(%rbx)
  80416041ab:	00 00 00 

  if (!addr) {
  80416041ae:	4d 85 e4             	test   %r12,%r12
  80416041b1:	0f 84 8f 01 00 00    	je     8041604346 <debuginfo_rip+0x206>
    return 0;
  }

  struct Dwarf_Addrs addrs;
  if (addr <= ULIM) {
  80416041b7:	48 b8 00 00 c0 3e 80 	movabs $0x803ec00000,%rax
  80416041be:	00 00 00 
  80416041c1:	49 39 c4             	cmp    %rax,%r12
  80416041c4:	0f 86 52 01 00 00    	jbe    804160431c <debuginfo_rip+0x1dc>
    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  80416041ca:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416041d1:	48 b8 a5 40 60 41 80 	movabs $0x80416040a5,%rax
  80416041d8:	00 00 00 
  80416041db:	ff d0                	callq  *%rax
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  80416041dd:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  80416041e4:	00 00 00 00 
  80416041e8:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  80416041ef:	00 00 00 00 
  code = info_by_address(&addrs, addr, &offset);
  80416041f3:	48 8d 95 68 ff ff ff 	lea    -0x98(%rbp),%rdx
  80416041fa:	4c 89 e6             	mov    %r12,%rsi
  80416041fd:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  8041604204:	48 b8 d5 15 60 41 80 	movabs $0x80416015d5,%rax
  804160420b:	00 00 00 
  804160420e:	ff d0                	callq  *%rax
  8041604210:	41 89 c5             	mov    %eax,%r13d
  if (code < 0) {
  8041604213:	85 c0                	test   %eax,%eax
  8041604215:	0f 88 31 01 00 00    	js     804160434c <debuginfo_rip+0x20c>
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf  = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  804160421b:	4c 8d 85 60 ff ff ff 	lea    -0xa0(%rbp),%r8
  8041604222:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604227:	48 8d 95 58 ff ff ff 	lea    -0xa8(%rbp),%rdx
  804160422e:	48 8b b5 68 ff ff ff 	mov    -0x98(%rbp),%rsi
  8041604235:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160423c:	48 b8 84 1c 60 41 80 	movabs $0x8041601c84,%rax
  8041604243:	00 00 00 
  8041604246:	ff d0                	callq  *%rax
  8041604248:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_file, tmp_buf, 256);
  804160424b:	ba 00 01 00 00       	mov    $0x100,%edx
  8041604250:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  8041604257:	48 89 df             	mov    %rbx,%rdi
  804160425a:	48 b8 23 4e 60 41 80 	movabs $0x8041604e23,%rax
  8041604261:	00 00 00 
  8041604264:	ff d0                	callq  *%rax
  if (code < 0) {
  8041604266:	45 85 ed             	test   %r13d,%r13d
  8041604269:	0f 88 dd 00 00 00    	js     804160434c <debuginfo_rip+0x20c>
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c
  // LAB 2: Your code here:
  buf  = &info->rip_line;
  addr = addr - 5;
  804160426f:	49 83 ec 05          	sub    $0x5,%r12
  buf  = &info->rip_line;
  8041604273:	48 8d 8b 00 01 00 00 	lea    0x100(%rbx),%rcx
  code = line_for_address(&addrs, addr, line_offset, buf);
  804160427a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8041604281:	4c 89 e6             	mov    %r12,%rsi
  8041604284:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  804160428b:	48 b8 28 30 60 41 80 	movabs $0x8041603028,%rax
  8041604292:	00 00 00 
  8041604295:	ff d0                	callq  *%rax
  if (code < 0) {
    return 0;
  8041604297:	41 bd 00 00 00 00    	mov    $0x0,%r13d
  if (code < 0) {
  804160429d:	85 c0                	test   %eax,%eax
  804160429f:	0f 88 a7 00 00 00    	js     804160434c <debuginfo_rip+0x20c>
  }
  
  buf  = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *), &info->rip_fn_addr);
  80416042a5:	4c 8d 8b 08 02 00 00 	lea    0x208(%rbx),%r9
  80416042ac:	41 b8 08 00 00 00    	mov    $0x8,%r8d
  80416042b2:	48 8d 8d 58 ff ff ff 	lea    -0xa8(%rbp),%rcx
  80416042b9:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  80416042c0:	4c 89 e6             	mov    %r12,%rsi
  80416042c3:	48 8d bd 70 ff ff ff 	lea    -0x90(%rbp),%rdi
  80416042ca:	48 b8 ef 20 60 41 80 	movabs $0x80416020ef,%rax
  80416042d1:	00 00 00 
  80416042d4:	ff d0                	callq  *%rax
  80416042d6:	41 89 c5             	mov    %eax,%r13d
  strncpy(info->rip_fn_name, tmp_buf, 256);
  80416042d9:	ba 00 01 00 00       	mov    $0x100,%edx
  80416042de:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  80416042e5:	4c 89 f7             	mov    %r14,%rdi
  80416042e8:	48 b8 23 4e 60 41 80 	movabs $0x8041604e23,%rax
  80416042ef:	00 00 00 
  80416042f2:	ff d0                	callq  *%rax
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  80416042f4:	be 00 01 00 00       	mov    $0x100,%esi
  80416042f9:	4c 89 f7             	mov    %r14,%rdi
  80416042fc:	48 b8 a0 4d 60 41 80 	movabs $0x8041604da0,%rax
  8041604303:	00 00 00 
  8041604306:	ff d0                	callq  *%rax
  8041604308:	89 83 04 02 00 00    	mov    %eax,0x204(%rbx)
  if (code < 0) {
  804160430e:	45 85 ed             	test   %r13d,%r13d
  8041604311:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604316:	44 0f 4f e8          	cmovg  %eax,%r13d
  804160431a:	eb 30                	jmp    804160434c <debuginfo_rip+0x20c>
    panic("Can't search for user-level addresses yet!");
  804160431c:	48 ba a8 5c 60 41 80 	movabs $0x8041605ca8,%rdx
  8041604323:	00 00 00 
  8041604326:	be 36 00 00 00       	mov    $0x36,%esi
  804160432b:	48 bf 93 5c 60 41 80 	movabs $0x8041605c93,%rdi
  8041604332:	00 00 00 
  8041604335:	b8 00 00 00 00       	mov    $0x0,%eax
  804160433a:	48 b9 89 03 60 41 80 	movabs $0x8041600389,%rcx
  8041604341:	00 00 00 
  8041604344:	ff d1                	callq  *%rcx
    return 0;
  8041604346:	41 bd 00 00 00 00    	mov    $0x0,%r13d
    return code;
  }
  return 0;
}
  804160434c:	44 89 e8             	mov    %r13d,%eax
  804160434f:	48 81 c4 90 00 00 00 	add    $0x90,%rsp
  8041604356:	5b                   	pop    %rbx
  8041604357:	41 5c                	pop    %r12
  8041604359:	41 5d                	pop    %r13
  804160435b:	41 5e                	pop    %r14
  804160435d:	5d                   	pop    %rbp
  804160435e:	c3                   	retq   

000000804160435f <find_function>:
  // address_by_fname, which looks for function name in section .debug_pubnames
  // and naive_address_by_fname which performs full traversal of DIE tree.
  // LAB 3: Your code here

  return 0;
}
  804160435f:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604364:	c3                   	retq   

0000008041604365 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  8041604365:	55                   	push   %rbp
  8041604366:	48 89 e5             	mov    %rsp,%rbp
  8041604369:	41 57                	push   %r15
  804160436b:	41 56                	push   %r14
  804160436d:	41 55                	push   %r13
  804160436f:	41 54                	push   %r12
  8041604371:	53                   	push   %rbx
  8041604372:	48 83 ec 18          	sub    $0x18,%rsp
  8041604376:	49 89 fc             	mov    %rdi,%r12
  8041604379:	49 89 f5             	mov    %rsi,%r13
  804160437c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8041604380:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  8041604383:	41 89 cf             	mov    %ecx,%r15d
  8041604386:	49 39 d7             	cmp    %rdx,%r15
  8041604389:	76 45                	jbe    80416043d0 <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  804160438b:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  804160438f:	85 db                	test   %ebx,%ebx
  8041604391:	7e 0e                	jle    80416043a1 <printnum+0x3c>
      putch(padc, putdat);
  8041604393:	4c 89 ee             	mov    %r13,%rsi
  8041604396:	44 89 f7             	mov    %r14d,%edi
  8041604399:	41 ff d4             	callq  *%r12
    while (--width > 0)
  804160439c:	83 eb 01             	sub    $0x1,%ebx
  804160439f:	75 f2                	jne    8041604393 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80416043a1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80416043a5:	ba 00 00 00 00       	mov    $0x0,%edx
  80416043aa:	49 f7 f7             	div    %r15
  80416043ad:	48 b8 d8 5c 60 41 80 	movabs $0x8041605cd8,%rax
  80416043b4:	00 00 00 
  80416043b7:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  80416043bb:	4c 89 ee             	mov    %r13,%rsi
  80416043be:	41 ff d4             	callq  *%r12
}
  80416043c1:	48 83 c4 18          	add    $0x18,%rsp
  80416043c5:	5b                   	pop    %rbx
  80416043c6:	41 5c                	pop    %r12
  80416043c8:	41 5d                	pop    %r13
  80416043ca:	41 5e                	pop    %r14
  80416043cc:	41 5f                	pop    %r15
  80416043ce:	5d                   	pop    %rbp
  80416043cf:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  80416043d0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80416043d4:	ba 00 00 00 00       	mov    $0x0,%edx
  80416043d9:	49 f7 f7             	div    %r15
  80416043dc:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  80416043e0:	48 89 c2             	mov    %rax,%rdx
  80416043e3:	48 b8 65 43 60 41 80 	movabs $0x8041604365,%rax
  80416043ea:	00 00 00 
  80416043ed:	ff d0                	callq  *%rax
  80416043ef:	eb b0                	jmp    80416043a1 <printnum+0x3c>

00000080416043f1 <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  80416043f1:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  80416043f5:	48 8b 06             	mov    (%rsi),%rax
  80416043f8:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  80416043fc:	73 0a                	jae    8041604408 <sprintputch+0x17>
    *b->buf++ = ch;
  80416043fe:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8041604402:	48 89 16             	mov    %rdx,(%rsi)
  8041604405:	40 88 38             	mov    %dil,(%rax)
}
  8041604408:	c3                   	retq   

0000008041604409 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  8041604409:	55                   	push   %rbp
  804160440a:	48 89 e5             	mov    %rsp,%rbp
  804160440d:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041604414:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  804160441b:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041604422:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604429:	84 c0                	test   %al,%al
  804160442b:	74 20                	je     804160444d <printfmt+0x44>
  804160442d:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604431:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604435:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604439:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  804160443d:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604441:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604445:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604449:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  804160444d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041604454:	00 00 00 
  8041604457:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  804160445e:	00 00 00 
  8041604461:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041604465:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  804160446c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041604473:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  804160447a:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8041604481:	48 b8 8f 44 60 41 80 	movabs $0x804160448f,%rax
  8041604488:	00 00 00 
  804160448b:	ff d0                	callq  *%rax
}
  804160448d:	c9                   	leaveq 
  804160448e:	c3                   	retq   

000000804160448f <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  804160448f:	55                   	push   %rbp
  8041604490:	48 89 e5             	mov    %rsp,%rbp
  8041604493:	41 57                	push   %r15
  8041604495:	41 56                	push   %r14
  8041604497:	41 55                	push   %r13
  8041604499:	41 54                	push   %r12
  804160449b:	53                   	push   %rbx
  804160449c:	48 83 ec 48          	sub    $0x48,%rsp
  80416044a0:	49 89 fd             	mov    %rdi,%r13
  80416044a3:	49 89 f7             	mov    %rsi,%r15
  80416044a6:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  80416044a9:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  80416044ad:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  80416044b1:	48 8b 41 10          	mov    0x10(%rcx),%rax
  80416044b5:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80416044b9:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  80416044bd:	41 0f b6 3e          	movzbl (%r14),%edi
  80416044c1:	83 ff 25             	cmp    $0x25,%edi
  80416044c4:	74 18                	je     80416044de <vprintfmt+0x4f>
      if (ch == '\0')
  80416044c6:	85 ff                	test   %edi,%edi
  80416044c8:	0f 84 8c 06 00 00    	je     8041604b5a <vprintfmt+0x6cb>
      putch(ch, putdat);
  80416044ce:	4c 89 fe             	mov    %r15,%rsi
  80416044d1:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  80416044d4:	49 89 de             	mov    %rbx,%r14
  80416044d7:	eb e0                	jmp    80416044b9 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  80416044d9:	49 89 de             	mov    %rbx,%r14
  80416044dc:	eb db                	jmp    80416044b9 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  80416044de:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  80416044e2:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  80416044e6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  80416044ed:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  80416044f3:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  80416044f7:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  80416044fc:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  8041604502:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  8041604508:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  804160450d:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  8041604512:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  8041604516:	0f b6 13             	movzbl (%rbx),%edx
  8041604519:	8d 42 dd             	lea    -0x23(%rdx),%eax
  804160451c:	3c 55                	cmp    $0x55,%al
  804160451e:	0f 87 8b 05 00 00    	ja     8041604aaf <vprintfmt+0x620>
  8041604524:	0f b6 c0             	movzbl %al,%eax
  8041604527:	49 bb 80 5d 60 41 80 	movabs $0x8041605d80,%r11
  804160452e:	00 00 00 
  8041604531:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  8041604535:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  8041604538:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  804160453c:	eb d4                	jmp    8041604512 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  804160453e:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  8041604541:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  8041604545:	eb cb                	jmp    8041604512 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8041604547:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  804160454a:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  804160454e:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  8041604552:	8d 50 d0             	lea    -0x30(%rax),%edx
  8041604555:	83 fa 09             	cmp    $0x9,%edx
  8041604558:	77 7e                	ja     80416045d8 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  804160455a:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  804160455e:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  8041604562:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  8041604567:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  804160456b:	8d 50 d0             	lea    -0x30(%rax),%edx
  804160456e:	83 fa 09             	cmp    $0x9,%edx
  8041604571:	76 e7                	jbe    804160455a <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  8041604573:	4c 89 f3             	mov    %r14,%rbx
  8041604576:	eb 19                	jmp    8041604591 <vprintfmt+0x102>
        precision = va_arg(aq, int);
  8041604578:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160457b:	83 f8 2f             	cmp    $0x2f,%eax
  804160457e:	77 2a                	ja     80416045aa <vprintfmt+0x11b>
  8041604580:	89 c2                	mov    %eax,%edx
  8041604582:	4c 01 d2             	add    %r10,%rdx
  8041604585:	83 c0 08             	add    $0x8,%eax
  8041604588:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160458b:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  804160458e:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  8041604591:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041604595:	0f 89 77 ff ff ff    	jns    8041604512 <vprintfmt+0x83>
          width = precision, precision = -1;
  804160459b:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  804160459f:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  80416045a5:	e9 68 ff ff ff       	jmpq   8041604512 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  80416045aa:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416045ae:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416045b2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416045b6:	eb d3                	jmp    804160458b <vprintfmt+0xfc>
        if (width < 0)
  80416045b8:	8b 45 ac             	mov    -0x54(%rbp),%eax
  80416045bb:	85 c0                	test   %eax,%eax
  80416045bd:	41 0f 48 c0          	cmovs  %r8d,%eax
  80416045c1:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  80416045c4:	4c 89 f3             	mov    %r14,%rbx
  80416045c7:	e9 46 ff ff ff       	jmpq   8041604512 <vprintfmt+0x83>
  80416045cc:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  80416045cf:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  80416045d3:	e9 3a ff ff ff       	jmpq   8041604512 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80416045d8:	4c 89 f3             	mov    %r14,%rbx
  80416045db:	eb b4                	jmp    8041604591 <vprintfmt+0x102>
        lflag++;
  80416045dd:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  80416045e0:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  80416045e3:	e9 2a ff ff ff       	jmpq   8041604512 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  80416045e8:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416045eb:	83 f8 2f             	cmp    $0x2f,%eax
  80416045ee:	77 19                	ja     8041604609 <vprintfmt+0x17a>
  80416045f0:	89 c2                	mov    %eax,%edx
  80416045f2:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416045f6:	83 c0 08             	add    $0x8,%eax
  80416045f9:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416045fc:	4c 89 fe             	mov    %r15,%rsi
  80416045ff:	8b 3a                	mov    (%rdx),%edi
  8041604601:	41 ff d5             	callq  *%r13
        break;
  8041604604:	e9 b0 fe ff ff       	jmpq   80416044b9 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  8041604609:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160460d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604611:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604615:	eb e5                	jmp    80416045fc <vprintfmt+0x16d>
        err = va_arg(aq, int);
  8041604617:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160461a:	83 f8 2f             	cmp    $0x2f,%eax
  804160461d:	77 5b                	ja     804160467a <vprintfmt+0x1eb>
  804160461f:	89 c2                	mov    %eax,%edx
  8041604621:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604625:	83 c0 08             	add    $0x8,%eax
  8041604628:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160462b:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  804160462d:	89 c8                	mov    %ecx,%eax
  804160462f:	c1 f8 1f             	sar    $0x1f,%eax
  8041604632:	31 c1                	xor    %eax,%ecx
  8041604634:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8041604636:	83 f9 08             	cmp    $0x8,%ecx
  8041604639:	7f 4d                	jg     8041604688 <vprintfmt+0x1f9>
  804160463b:	48 63 c1             	movslq %ecx,%rax
  804160463e:	48 ba 40 60 60 41 80 	movabs $0x8041606040,%rdx
  8041604645:	00 00 00 
  8041604648:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  804160464c:	48 85 c0             	test   %rax,%rax
  804160464f:	74 37                	je     8041604688 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  8041604651:	48 89 c1             	mov    %rax,%rcx
  8041604654:	48 ba ab 55 60 41 80 	movabs $0x80416055ab,%rdx
  804160465b:	00 00 00 
  804160465e:	4c 89 fe             	mov    %r15,%rsi
  8041604661:	4c 89 ef             	mov    %r13,%rdi
  8041604664:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604669:	48 bb 09 44 60 41 80 	movabs $0x8041604409,%rbx
  8041604670:	00 00 00 
  8041604673:	ff d3                	callq  *%rbx
  8041604675:	e9 3f fe ff ff       	jmpq   80416044b9 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  804160467a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160467e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604682:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604686:	eb a3                	jmp    804160462b <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  8041604688:	48 ba f0 5c 60 41 80 	movabs $0x8041605cf0,%rdx
  804160468f:	00 00 00 
  8041604692:	4c 89 fe             	mov    %r15,%rsi
  8041604695:	4c 89 ef             	mov    %r13,%rdi
  8041604698:	b8 00 00 00 00       	mov    $0x0,%eax
  804160469d:	48 bb 09 44 60 41 80 	movabs $0x8041604409,%rbx
  80416046a4:	00 00 00 
  80416046a7:	ff d3                	callq  *%rbx
  80416046a9:	e9 0b fe ff ff       	jmpq   80416044b9 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  80416046ae:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416046b1:	83 f8 2f             	cmp    $0x2f,%eax
  80416046b4:	77 4b                	ja     8041604701 <vprintfmt+0x272>
  80416046b6:	89 c2                	mov    %eax,%edx
  80416046b8:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416046bc:	83 c0 08             	add    $0x8,%eax
  80416046bf:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416046c2:	48 8b 02             	mov    (%rdx),%rax
  80416046c5:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80416046c9:	48 85 c0             	test   %rax,%rax
  80416046cc:	0f 84 05 04 00 00    	je     8041604ad7 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  80416046d2:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80416046d6:	7e 06                	jle    80416046de <vprintfmt+0x24f>
  80416046d8:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  80416046dc:	75 31                	jne    804160470f <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80416046de:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80416046e2:	48 8d 58 01          	lea    0x1(%rax),%rbx
  80416046e6:	0f b6 00             	movzbl (%rax),%eax
  80416046e9:	0f be f8             	movsbl %al,%edi
  80416046ec:	85 ff                	test   %edi,%edi
  80416046ee:	0f 84 c3 00 00 00    	je     80416047b7 <vprintfmt+0x328>
  80416046f4:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  80416046f8:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  80416046fc:	e9 85 00 00 00       	jmpq   8041604786 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8041604701:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604705:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604709:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160470d:	eb b3                	jmp    80416046c2 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  804160470f:	49 63 f4             	movslq %r12d,%rsi
  8041604712:	48 89 c7             	mov    %rax,%rdi
  8041604715:	48 b8 a0 4d 60 41 80 	movabs $0x8041604da0,%rax
  804160471c:	00 00 00 
  804160471f:	ff d0                	callq  *%rax
  8041604721:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8041604724:	8b 75 ac             	mov    -0x54(%rbp),%esi
  8041604727:	85 f6                	test   %esi,%esi
  8041604729:	7e 22                	jle    804160474d <vprintfmt+0x2be>
            putch(padc, putdat);
  804160472b:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  804160472f:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  8041604733:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  8041604737:	4c 89 fe             	mov    %r15,%rsi
  804160473a:	89 df                	mov    %ebx,%edi
  804160473c:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  804160473f:	41 83 ec 01          	sub    $0x1,%r12d
  8041604743:	75 f2                	jne    8041604737 <vprintfmt+0x2a8>
  8041604745:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  8041604749:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  804160474d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8041604751:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8041604755:	0f b6 00             	movzbl (%rax),%eax
  8041604758:	0f be f8             	movsbl %al,%edi
  804160475b:	85 ff                	test   %edi,%edi
  804160475d:	0f 84 56 fd ff ff    	je     80416044b9 <vprintfmt+0x2a>
  8041604763:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041604767:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  804160476b:	eb 19                	jmp    8041604786 <vprintfmt+0x2f7>
            putch(ch, putdat);
  804160476d:	4c 89 fe             	mov    %r15,%rsi
  8041604770:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604773:	41 83 ee 01          	sub    $0x1,%r14d
  8041604777:	48 83 c3 01          	add    $0x1,%rbx
  804160477b:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  804160477f:	0f be f8             	movsbl %al,%edi
  8041604782:	85 ff                	test   %edi,%edi
  8041604784:	74 29                	je     80416047af <vprintfmt+0x320>
  8041604786:	45 85 e4             	test   %r12d,%r12d
  8041604789:	78 06                	js     8041604791 <vprintfmt+0x302>
  804160478b:	41 83 ec 01          	sub    $0x1,%r12d
  804160478f:	78 48                	js     80416047d9 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  8041604791:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  8041604795:	74 d6                	je     804160476d <vprintfmt+0x2de>
  8041604797:	0f be c0             	movsbl %al,%eax
  804160479a:	83 e8 20             	sub    $0x20,%eax
  804160479d:	83 f8 5e             	cmp    $0x5e,%eax
  80416047a0:	76 cb                	jbe    804160476d <vprintfmt+0x2de>
            putch('?', putdat);
  80416047a2:	4c 89 fe             	mov    %r15,%rsi
  80416047a5:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80416047aa:	41 ff d5             	callq  *%r13
  80416047ad:	eb c4                	jmp    8041604773 <vprintfmt+0x2e4>
  80416047af:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80416047b3:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  80416047b7:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  80416047ba:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80416047be:	0f 8e f5 fc ff ff    	jle    80416044b9 <vprintfmt+0x2a>
          putch(' ', putdat);
  80416047c4:	4c 89 fe             	mov    %r15,%rsi
  80416047c7:	bf 20 00 00 00       	mov    $0x20,%edi
  80416047cc:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  80416047cf:	83 eb 01             	sub    $0x1,%ebx
  80416047d2:	75 f0                	jne    80416047c4 <vprintfmt+0x335>
  80416047d4:	e9 e0 fc ff ff       	jmpq   80416044b9 <vprintfmt+0x2a>
  80416047d9:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  80416047dd:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  80416047e1:	eb d4                	jmp    80416047b7 <vprintfmt+0x328>
  if (lflag >= 2)
  80416047e3:	83 f9 01             	cmp    $0x1,%ecx
  80416047e6:	7f 1d                	jg     8041604805 <vprintfmt+0x376>
  else if (lflag)
  80416047e8:	85 c9                	test   %ecx,%ecx
  80416047ea:	74 5e                	je     804160484a <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  80416047ec:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416047ef:	83 f8 2f             	cmp    $0x2f,%eax
  80416047f2:	77 48                	ja     804160483c <vprintfmt+0x3ad>
  80416047f4:	89 c2                	mov    %eax,%edx
  80416047f6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416047fa:	83 c0 08             	add    $0x8,%eax
  80416047fd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604800:	48 8b 1a             	mov    (%rdx),%rbx
  8041604803:	eb 17                	jmp    804160481c <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  8041604805:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604808:	83 f8 2f             	cmp    $0x2f,%eax
  804160480b:	77 21                	ja     804160482e <vprintfmt+0x39f>
  804160480d:	89 c2                	mov    %eax,%edx
  804160480f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604813:	83 c0 08             	add    $0x8,%eax
  8041604816:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604819:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  804160481c:	48 85 db             	test   %rbx,%rbx
  804160481f:	78 50                	js     8041604871 <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  8041604821:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  8041604824:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604829:	e9 b4 01 00 00       	jmpq   80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  804160482e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604832:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604836:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160483a:	eb dd                	jmp    8041604819 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  804160483c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604840:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604844:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604848:	eb b6                	jmp    8041604800 <vprintfmt+0x371>
    return va_arg(*ap, int);
  804160484a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160484d:	83 f8 2f             	cmp    $0x2f,%eax
  8041604850:	77 11                	ja     8041604863 <vprintfmt+0x3d4>
  8041604852:	89 c2                	mov    %eax,%edx
  8041604854:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604858:	83 c0 08             	add    $0x8,%eax
  804160485b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160485e:	48 63 1a             	movslq (%rdx),%rbx
  8041604861:	eb b9                	jmp    804160481c <vprintfmt+0x38d>
  8041604863:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604867:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160486b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160486f:	eb ed                	jmp    804160485e <vprintfmt+0x3cf>
          putch('-', putdat);
  8041604871:	4c 89 fe             	mov    %r15,%rsi
  8041604874:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8041604879:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  804160487c:	48 89 da             	mov    %rbx,%rdx
  804160487f:	48 f7 da             	neg    %rdx
        base = 10;
  8041604882:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8041604887:	e9 56 01 00 00       	jmpq   80416049e2 <vprintfmt+0x553>
  if (lflag >= 2)
  804160488c:	83 f9 01             	cmp    $0x1,%ecx
  804160488f:	7f 25                	jg     80416048b6 <vprintfmt+0x427>
  else if (lflag)
  8041604891:	85 c9                	test   %ecx,%ecx
  8041604893:	74 5e                	je     80416048f3 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  8041604895:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604898:	83 f8 2f             	cmp    $0x2f,%eax
  804160489b:	77 48                	ja     80416048e5 <vprintfmt+0x456>
  804160489d:	89 c2                	mov    %eax,%edx
  804160489f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416048a3:	83 c0 08             	add    $0x8,%eax
  80416048a6:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416048a9:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80416048ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416048b1:	e9 2c 01 00 00       	jmpq   80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80416048b6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416048b9:	83 f8 2f             	cmp    $0x2f,%eax
  80416048bc:	77 19                	ja     80416048d7 <vprintfmt+0x448>
  80416048be:	89 c2                	mov    %eax,%edx
  80416048c0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416048c4:	83 c0 08             	add    $0x8,%eax
  80416048c7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416048ca:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  80416048cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80416048d2:	e9 0b 01 00 00       	jmpq   80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  80416048d7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416048db:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416048df:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416048e3:	eb e5                	jmp    80416048ca <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  80416048e5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416048e9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416048ed:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416048f1:	eb b6                	jmp    80416048a9 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  80416048f3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416048f6:	83 f8 2f             	cmp    $0x2f,%eax
  80416048f9:	77 18                	ja     8041604913 <vprintfmt+0x484>
  80416048fb:	89 c2                	mov    %eax,%edx
  80416048fd:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604901:	83 c0 08             	add    $0x8,%eax
  8041604904:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604907:	8b 12                	mov    (%rdx),%edx
        base = 10;
  8041604909:	b9 0a 00 00 00       	mov    $0xa,%ecx
  804160490e:	e9 cf 00 00 00       	jmpq   80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8041604913:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604917:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160491b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  804160491f:	eb e6                	jmp    8041604907 <vprintfmt+0x478>
  if (lflag >= 2)
  8041604921:	83 f9 01             	cmp    $0x1,%ecx
  8041604924:	7f 25                	jg     804160494b <vprintfmt+0x4bc>
  else if (lflag)
  8041604926:	85 c9                	test   %ecx,%ecx
  8041604928:	74 5b                	je     8041604985 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  804160492a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160492d:	83 f8 2f             	cmp    $0x2f,%eax
  8041604930:	77 45                	ja     8041604977 <vprintfmt+0x4e8>
  8041604932:	89 c2                	mov    %eax,%edx
  8041604934:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604938:	83 c0 08             	add    $0x8,%eax
  804160493b:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160493e:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8041604941:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604946:	e9 97 00 00 00       	jmpq   80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  804160494b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  804160494e:	83 f8 2f             	cmp    $0x2f,%eax
  8041604951:	77 16                	ja     8041604969 <vprintfmt+0x4da>
  8041604953:	89 c2                	mov    %eax,%edx
  8041604955:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604959:	83 c0 08             	add    $0x8,%eax
  804160495c:	89 45 b8             	mov    %eax,-0x48(%rbp)
  804160495f:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  8041604962:	b9 08 00 00 00       	mov    $0x8,%ecx
  8041604967:	eb 79                	jmp    80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604969:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160496d:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604971:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604975:	eb e8                	jmp    804160495f <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  8041604977:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  804160497b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  804160497f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604983:	eb b9                	jmp    804160493e <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  8041604985:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604988:	83 f8 2f             	cmp    $0x2f,%eax
  804160498b:	77 15                	ja     80416049a2 <vprintfmt+0x513>
  804160498d:	89 c2                	mov    %eax,%edx
  804160498f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604993:	83 c0 08             	add    $0x8,%eax
  8041604996:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604999:	8b 12                	mov    (%rdx),%edx
        base = 8;
  804160499b:	b9 08 00 00 00       	mov    $0x8,%ecx
  80416049a0:	eb 40                	jmp    80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80416049a2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80416049a6:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80416049aa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80416049ae:	eb e9                	jmp    8041604999 <vprintfmt+0x50a>
        putch('0', putdat);
  80416049b0:	4c 89 fe             	mov    %r15,%rsi
  80416049b3:	bf 30 00 00 00       	mov    $0x30,%edi
  80416049b8:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  80416049bb:	4c 89 fe             	mov    %r15,%rsi
  80416049be:	bf 78 00 00 00       	mov    $0x78,%edi
  80416049c3:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  80416049c6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80416049c9:	83 f8 2f             	cmp    $0x2f,%eax
  80416049cc:	77 34                	ja     8041604a02 <vprintfmt+0x573>
  80416049ce:	89 c2                	mov    %eax,%edx
  80416049d0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80416049d4:	83 c0 08             	add    $0x8,%eax
  80416049d7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80416049da:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80416049dd:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  80416049e2:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  80416049e7:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  80416049eb:	4c 89 fe             	mov    %r15,%rsi
  80416049ee:	4c 89 ef             	mov    %r13,%rdi
  80416049f1:	48 b8 65 43 60 41 80 	movabs $0x8041604365,%rax
  80416049f8:	00 00 00 
  80416049fb:	ff d0                	callq  *%rax
        break;
  80416049fd:	e9 b7 fa ff ff       	jmpq   80416044b9 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8041604a02:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604a06:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604a0a:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a0e:	eb ca                	jmp    80416049da <vprintfmt+0x54b>
  if (lflag >= 2)
  8041604a10:	83 f9 01             	cmp    $0x1,%ecx
  8041604a13:	7f 22                	jg     8041604a37 <vprintfmt+0x5a8>
  else if (lflag)
  8041604a15:	85 c9                	test   %ecx,%ecx
  8041604a17:	74 58                	je     8041604a71 <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  8041604a19:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604a1c:	83 f8 2f             	cmp    $0x2f,%eax
  8041604a1f:	77 42                	ja     8041604a63 <vprintfmt+0x5d4>
  8041604a21:	89 c2                	mov    %eax,%edx
  8041604a23:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604a27:	83 c0 08             	add    $0x8,%eax
  8041604a2a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604a2d:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041604a30:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604a35:	eb ab                	jmp    80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604a37:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604a3a:	83 f8 2f             	cmp    $0x2f,%eax
  8041604a3d:	77 16                	ja     8041604a55 <vprintfmt+0x5c6>
  8041604a3f:	89 c2                	mov    %eax,%edx
  8041604a41:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604a45:	83 c0 08             	add    $0x8,%eax
  8041604a48:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604a4b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8041604a4e:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604a53:	eb 8d                	jmp    80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8041604a55:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604a59:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604a5d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a61:	eb e8                	jmp    8041604a4b <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  8041604a63:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604a67:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604a6b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a6f:	eb bc                	jmp    8041604a2d <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  8041604a71:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8041604a74:	83 f8 2f             	cmp    $0x2f,%eax
  8041604a77:	77 18                	ja     8041604a91 <vprintfmt+0x602>
  8041604a79:	89 c2                	mov    %eax,%edx
  8041604a7b:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8041604a7f:	83 c0 08             	add    $0x8,%eax
  8041604a82:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8041604a85:	8b 12                	mov    (%rdx),%edx
        base = 16;
  8041604a87:	b9 10 00 00 00       	mov    $0x10,%ecx
  8041604a8c:	e9 51 ff ff ff       	jmpq   80416049e2 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8041604a91:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8041604a95:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8041604a99:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8041604a9d:	eb e6                	jmp    8041604a85 <vprintfmt+0x5f6>
        putch(ch, putdat);
  8041604a9f:	4c 89 fe             	mov    %r15,%rsi
  8041604aa2:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604aa7:	41 ff d5             	callq  *%r13
        break;
  8041604aaa:	e9 0a fa ff ff       	jmpq   80416044b9 <vprintfmt+0x2a>
        putch('%', putdat);
  8041604aaf:	4c 89 fe             	mov    %r15,%rsi
  8041604ab2:	bf 25 00 00 00       	mov    $0x25,%edi
  8041604ab7:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8041604aba:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8041604abe:	0f 84 15 fa ff ff    	je     80416044d9 <vprintfmt+0x4a>
  8041604ac4:	49 89 de             	mov    %rbx,%r14
  8041604ac7:	49 83 ee 01          	sub    $0x1,%r14
  8041604acb:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8041604ad0:	75 f5                	jne    8041604ac7 <vprintfmt+0x638>
  8041604ad2:	e9 e2 f9 ff ff       	jmpq   80416044b9 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8041604ad7:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8041604adb:	74 06                	je     8041604ae3 <vprintfmt+0x654>
  8041604add:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8041604ae1:	7f 21                	jg     8041604b04 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604ae3:	bf 28 00 00 00       	mov    $0x28,%edi
  8041604ae8:	48 bb ea 5c 60 41 80 	movabs $0x8041605cea,%rbx
  8041604aef:	00 00 00 
  8041604af2:	b8 28 00 00 00       	mov    $0x28,%eax
  8041604af7:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041604afb:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8041604aff:	e9 82 fc ff ff       	jmpq   8041604786 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  8041604b04:	49 63 f4             	movslq %r12d,%rsi
  8041604b07:	48 bf e9 5c 60 41 80 	movabs $0x8041605ce9,%rdi
  8041604b0e:	00 00 00 
  8041604b11:	48 b8 a0 4d 60 41 80 	movabs $0x8041604da0,%rax
  8041604b18:	00 00 00 
  8041604b1b:	ff d0                	callq  *%rax
  8041604b1d:	29 45 ac             	sub    %eax,-0x54(%rbp)
  8041604b20:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  8041604b23:	48 be e9 5c 60 41 80 	movabs $0x8041605ce9,%rsi
  8041604b2a:	00 00 00 
  8041604b2d:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  8041604b31:	85 c0                	test   %eax,%eax
  8041604b33:	0f 8f f2 fb ff ff    	jg     804160472b <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8041604b39:	48 bb ea 5c 60 41 80 	movabs $0x8041605cea,%rbx
  8041604b40:	00 00 00 
  8041604b43:	b8 28 00 00 00       	mov    $0x28,%eax
  8041604b48:	bf 28 00 00 00       	mov    $0x28,%edi
  8041604b4d:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8041604b51:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8041604b55:	e9 2c fc ff ff       	jmpq   8041604786 <vprintfmt+0x2f7>
}
  8041604b5a:	48 83 c4 48          	add    $0x48,%rsp
  8041604b5e:	5b                   	pop    %rbx
  8041604b5f:	41 5c                	pop    %r12
  8041604b61:	41 5d                	pop    %r13
  8041604b63:	41 5e                	pop    %r14
  8041604b65:	41 5f                	pop    %r15
  8041604b67:	5d                   	pop    %rbp
  8041604b68:	c3                   	retq   

0000008041604b69 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  8041604b69:	55                   	push   %rbp
  8041604b6a:	48 89 e5             	mov    %rsp,%rbp
  8041604b6d:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  8041604b71:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  8041604b75:	48 63 c6             	movslq %esi,%rax
  8041604b78:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  8041604b7d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8041604b81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  8041604b88:	48 85 ff             	test   %rdi,%rdi
  8041604b8b:	74 2a                	je     8041604bb7 <vsnprintf+0x4e>
  8041604b8d:	85 f6                	test   %esi,%esi
  8041604b8f:	7e 26                	jle    8041604bb7 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  8041604b91:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  8041604b95:	48 bf f1 43 60 41 80 	movabs $0x80416043f1,%rdi
  8041604b9c:	00 00 00 
  8041604b9f:	48 b8 8f 44 60 41 80 	movabs $0x804160448f,%rax
  8041604ba6:	00 00 00 
  8041604ba9:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  8041604bab:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8041604baf:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  8041604bb2:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  8041604bb5:	c9                   	leaveq 
  8041604bb6:	c3                   	retq   
    return -E_INVAL;
  8041604bb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8041604bbc:	eb f7                	jmp    8041604bb5 <vsnprintf+0x4c>

0000008041604bbe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  8041604bbe:	55                   	push   %rbp
  8041604bbf:	48 89 e5             	mov    %rsp,%rbp
  8041604bc2:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8041604bc9:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8041604bd0:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8041604bd7:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8041604bde:	84 c0                	test   %al,%al
  8041604be0:	74 20                	je     8041604c02 <snprintf+0x44>
  8041604be2:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8041604be6:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8041604bea:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8041604bee:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8041604bf2:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8041604bf6:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8041604bfa:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8041604bfe:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  8041604c02:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8041604c09:	00 00 00 
  8041604c0c:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8041604c13:	00 00 00 
  8041604c16:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8041604c1a:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8041604c21:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8041604c28:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  8041604c2f:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8041604c36:	48 b8 69 4b 60 41 80 	movabs $0x8041604b69,%rax
  8041604c3d:	00 00 00 
  8041604c40:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  8041604c42:	c9                   	leaveq 
  8041604c43:	c3                   	retq   

0000008041604c44 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt) {
  8041604c44:	55                   	push   %rbp
  8041604c45:	48 89 e5             	mov    %rsp,%rbp
  8041604c48:	41 57                	push   %r15
  8041604c4a:	41 56                	push   %r14
  8041604c4c:	41 55                	push   %r13
  8041604c4e:	41 54                	push   %r12
  8041604c50:	53                   	push   %rbx
  8041604c51:	48 83 ec 08          	sub    $0x8,%rsp
  int i, c, echoing;

  if (prompt != NULL)
  8041604c55:	48 85 ff             	test   %rdi,%rdi
  8041604c58:	74 1e                	je     8041604c78 <readline+0x34>
    cprintf("%s", prompt);
  8041604c5a:	48 89 fe             	mov    %rdi,%rsi
  8041604c5d:	48 bf ab 55 60 41 80 	movabs $0x80416055ab,%rdi
  8041604c64:	00 00 00 
  8041604c67:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604c6c:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041604c73:	00 00 00 
  8041604c76:	ff d2                	callq  *%rdx

  i       = 0;
  echoing = iscons(0);
  8041604c78:	bf 00 00 00 00       	mov    $0x0,%edi
  8041604c7d:	48 b8 43 0c 60 41 80 	movabs $0x8041600c43,%rax
  8041604c84:	00 00 00 
  8041604c87:	ff d0                	callq  *%rax
  8041604c89:	41 89 c6             	mov    %eax,%r14d
  i       = 0;
  8041604c8c:	41 bc 00 00 00 00    	mov    $0x0,%r12d
  while (1) {
    c = getchar();
  8041604c92:	49 bd 23 0c 60 41 80 	movabs $0x8041600c23,%r13
  8041604c99:	00 00 00 
      cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
  8041604c9c:	49 bf 11 0c 60 41 80 	movabs $0x8041600c11,%r15
  8041604ca3:	00 00 00 
  8041604ca6:	eb 3f                	jmp    8041604ce7 <readline+0xa3>
      cprintf("read error: %i\n", c);
  8041604ca8:	89 c6                	mov    %eax,%esi
  8041604caa:	48 bf 88 60 60 41 80 	movabs $0x8041606088,%rdi
  8041604cb1:	00 00 00 
  8041604cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604cb9:	48 ba 70 3f 60 41 80 	movabs $0x8041603f70,%rdx
  8041604cc0:	00 00 00 
  8041604cc3:	ff d2                	callq  *%rdx
      return NULL;
  8041604cc5:	b8 00 00 00 00       	mov    $0x0,%eax
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
  8041604cca:	48 83 c4 08          	add    $0x8,%rsp
  8041604cce:	5b                   	pop    %rbx
  8041604ccf:	41 5c                	pop    %r12
  8041604cd1:	41 5d                	pop    %r13
  8041604cd3:	41 5e                	pop    %r14
  8041604cd5:	41 5f                	pop    %r15
  8041604cd7:	5d                   	pop    %rbp
  8041604cd8:	c3                   	retq   
      if (i > 0) {
  8041604cd9:	45 85 e4             	test   %r12d,%r12d
  8041604cdc:	7e 09                	jle    8041604ce7 <readline+0xa3>
        if (echoing) {
  8041604cde:	45 85 f6             	test   %r14d,%r14d
  8041604ce1:	75 41                	jne    8041604d24 <readline+0xe0>
        i--;
  8041604ce3:	41 83 ec 01          	sub    $0x1,%r12d
    c = getchar();
  8041604ce7:	41 ff d5             	callq  *%r13
  8041604cea:	89 c3                	mov    %eax,%ebx
    if (c < 0) {
  8041604cec:	85 c0                	test   %eax,%eax
  8041604cee:	78 b8                	js     8041604ca8 <readline+0x64>
    } else if ((c == '\b' || c == '\x7f')) {
  8041604cf0:	83 f8 08             	cmp    $0x8,%eax
  8041604cf3:	74 e4                	je     8041604cd9 <readline+0x95>
  8041604cf5:	83 f8 7f             	cmp    $0x7f,%eax
  8041604cf8:	74 df                	je     8041604cd9 <readline+0x95>
    } else if (c >= ' ' && i < BUFLEN - 1) {
  8041604cfa:	83 f8 1f             	cmp    $0x1f,%eax
  8041604cfd:	7e 46                	jle    8041604d45 <readline+0x101>
  8041604cff:	41 81 fc fe 03 00 00 	cmp    $0x3fe,%r12d
  8041604d06:	7f 3d                	jg     8041604d45 <readline+0x101>
      if (echoing)
  8041604d08:	45 85 f6             	test   %r14d,%r14d
  8041604d0b:	75 31                	jne    8041604d3e <readline+0xfa>
      buf[i++] = c;
  8041604d0d:	49 63 c4             	movslq %r12d,%rax
  8041604d10:	48 b9 60 38 62 41 80 	movabs $0x8041623860,%rcx
  8041604d17:	00 00 00 
  8041604d1a:	88 1c 01             	mov    %bl,(%rcx,%rax,1)
  8041604d1d:	45 8d 64 24 01       	lea    0x1(%r12),%r12d
  8041604d22:	eb c3                	jmp    8041604ce7 <readline+0xa3>
          cputchar('\b');
  8041604d24:	bf 08 00 00 00       	mov    $0x8,%edi
  8041604d29:	41 ff d7             	callq  *%r15
          cputchar(' ');
  8041604d2c:	bf 20 00 00 00       	mov    $0x20,%edi
  8041604d31:	41 ff d7             	callq  *%r15
          cputchar('\b');
  8041604d34:	bf 08 00 00 00       	mov    $0x8,%edi
  8041604d39:	41 ff d7             	callq  *%r15
  8041604d3c:	eb a5                	jmp    8041604ce3 <readline+0x9f>
        cputchar(c);
  8041604d3e:	89 c7                	mov    %eax,%edi
  8041604d40:	41 ff d7             	callq  *%r15
  8041604d43:	eb c8                	jmp    8041604d0d <readline+0xc9>
    } else if (c == '\n' || c == '\r') {
  8041604d45:	83 fb 0a             	cmp    $0xa,%ebx
  8041604d48:	74 05                	je     8041604d4f <readline+0x10b>
  8041604d4a:	83 fb 0d             	cmp    $0xd,%ebx
  8041604d4d:	75 98                	jne    8041604ce7 <readline+0xa3>
      if (echoing)
  8041604d4f:	45 85 f6             	test   %r14d,%r14d
  8041604d52:	75 17                	jne    8041604d6b <readline+0x127>
      buf[i] = 0;
  8041604d54:	48 b8 60 38 62 41 80 	movabs $0x8041623860,%rax
  8041604d5b:	00 00 00 
  8041604d5e:	4d 63 e4             	movslq %r12d,%r12
  8041604d61:	42 c6 04 20 00       	movb   $0x0,(%rax,%r12,1)
      return buf;
  8041604d66:	e9 5f ff ff ff       	jmpq   8041604cca <readline+0x86>
        cputchar('\n');
  8041604d6b:	bf 0a 00 00 00       	mov    $0xa,%edi
  8041604d70:	48 b8 11 0c 60 41 80 	movabs $0x8041600c11,%rax
  8041604d77:	00 00 00 
  8041604d7a:	ff d0                	callq  *%rax
  8041604d7c:	eb d6                	jmp    8041604d54 <readline+0x110>

0000008041604d7e <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  8041604d7e:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604d81:	74 17                	je     8041604d9a <strlen+0x1c>
  8041604d83:	48 89 fa             	mov    %rdi,%rdx
  8041604d86:	b9 01 00 00 00       	mov    $0x1,%ecx
  8041604d8b:	29 f9                	sub    %edi,%ecx
    n++;
  8041604d8d:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  8041604d90:	48 83 c2 01          	add    $0x1,%rdx
  8041604d94:	80 3a 00             	cmpb   $0x0,(%rdx)
  8041604d97:	75 f4                	jne    8041604d8d <strlen+0xf>
  8041604d99:	c3                   	retq   
  8041604d9a:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8041604d9f:	c3                   	retq   

0000008041604da0 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041604da0:	48 85 f6             	test   %rsi,%rsi
  8041604da3:	74 24                	je     8041604dc9 <strnlen+0x29>
  8041604da5:	80 3f 00             	cmpb   $0x0,(%rdi)
  8041604da8:	74 25                	je     8041604dcf <strnlen+0x2f>
  8041604daa:	48 01 fe             	add    %rdi,%rsi
  8041604dad:	48 89 fa             	mov    %rdi,%rdx
  8041604db0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8041604db5:	29 f9                	sub    %edi,%ecx
    n++;
  8041604db7:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8041604dba:	48 83 c2 01          	add    $0x1,%rdx
  8041604dbe:	48 39 f2             	cmp    %rsi,%rdx
  8041604dc1:	74 11                	je     8041604dd4 <strnlen+0x34>
  8041604dc3:	80 3a 00             	cmpb   $0x0,(%rdx)
  8041604dc6:	75 ef                	jne    8041604db7 <strnlen+0x17>
  8041604dc8:	c3                   	retq   
  8041604dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604dce:	c3                   	retq   
  8041604dcf:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  8041604dd4:	c3                   	retq   

0000008041604dd5 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  8041604dd5:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  8041604dd8:	ba 00 00 00 00       	mov    $0x0,%edx
  8041604ddd:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  8041604de1:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  8041604de4:	48 83 c2 01          	add    $0x1,%rdx
  8041604de8:	84 c9                	test   %cl,%cl
  8041604dea:	75 f1                	jne    8041604ddd <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  8041604dec:	c3                   	retq   

0000008041604ded <strcat>:

char *
strcat(char *dst, const char *src) {
  8041604ded:	55                   	push   %rbp
  8041604dee:	48 89 e5             	mov    %rsp,%rbp
  8041604df1:	41 54                	push   %r12
  8041604df3:	53                   	push   %rbx
  8041604df4:	48 89 fb             	mov    %rdi,%rbx
  8041604df7:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  8041604dfa:	48 b8 7e 4d 60 41 80 	movabs $0x8041604d7e,%rax
  8041604e01:	00 00 00 
  8041604e04:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  8041604e06:	48 63 f8             	movslq %eax,%rdi
  8041604e09:	48 01 df             	add    %rbx,%rdi
  8041604e0c:	4c 89 e6             	mov    %r12,%rsi
  8041604e0f:	48 b8 d5 4d 60 41 80 	movabs $0x8041604dd5,%rax
  8041604e16:	00 00 00 
  8041604e19:	ff d0                	callq  *%rax
  return dst;
}
  8041604e1b:	48 89 d8             	mov    %rbx,%rax
  8041604e1e:	5b                   	pop    %rbx
  8041604e1f:	41 5c                	pop    %r12
  8041604e21:	5d                   	pop    %rbp
  8041604e22:	c3                   	retq   

0000008041604e23 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8041604e23:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  8041604e26:	48 85 d2             	test   %rdx,%rdx
  8041604e29:	74 1f                	je     8041604e4a <strncpy+0x27>
  8041604e2b:	48 01 fa             	add    %rdi,%rdx
  8041604e2e:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  8041604e31:	48 83 c1 01          	add    $0x1,%rcx
  8041604e35:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041604e39:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  8041604e3d:	41 80 f8 01          	cmp    $0x1,%r8b
  8041604e41:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  8041604e45:	48 39 ca             	cmp    %rcx,%rdx
  8041604e48:	75 e7                	jne    8041604e31 <strncpy+0xe>
  }
  return ret;
}
  8041604e4a:	c3                   	retq   

0000008041604e4b <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  8041604e4b:	48 89 f8             	mov    %rdi,%rax
  8041604e4e:	48 85 d2             	test   %rdx,%rdx
  8041604e51:	74 36                	je     8041604e89 <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  8041604e53:	48 83 fa 01          	cmp    $0x1,%rdx
  8041604e57:	74 2d                	je     8041604e86 <strlcpy+0x3b>
  8041604e59:	44 0f b6 06          	movzbl (%rsi),%r8d
  8041604e5d:	45 84 c0             	test   %r8b,%r8b
  8041604e60:	74 24                	je     8041604e86 <strlcpy+0x3b>
  8041604e62:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  8041604e66:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  8041604e6b:	48 83 c0 01          	add    $0x1,%rax
  8041604e6f:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  8041604e73:	48 39 d1             	cmp    %rdx,%rcx
  8041604e76:	74 0e                	je     8041604e86 <strlcpy+0x3b>
  8041604e78:	48 83 c1 01          	add    $0x1,%rcx
  8041604e7c:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  8041604e81:	45 84 c0             	test   %r8b,%r8b
  8041604e84:	75 e5                	jne    8041604e6b <strlcpy+0x20>
    *dst = '\0';
  8041604e86:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  8041604e89:	48 29 f8             	sub    %rdi,%rax
}
  8041604e8c:	c3                   	retq   

0000008041604e8d <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  8041604e8d:	0f b6 07             	movzbl (%rdi),%eax
  8041604e90:	84 c0                	test   %al,%al
  8041604e92:	74 17                	je     8041604eab <strcmp+0x1e>
  8041604e94:	3a 06                	cmp    (%rsi),%al
  8041604e96:	75 13                	jne    8041604eab <strcmp+0x1e>
    p++, q++;
  8041604e98:	48 83 c7 01          	add    $0x1,%rdi
  8041604e9c:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  8041604ea0:	0f b6 07             	movzbl (%rdi),%eax
  8041604ea3:	84 c0                	test   %al,%al
  8041604ea5:	74 04                	je     8041604eab <strcmp+0x1e>
  8041604ea7:	3a 06                	cmp    (%rsi),%al
  8041604ea9:	74 ed                	je     8041604e98 <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  8041604eab:	0f b6 c0             	movzbl %al,%eax
  8041604eae:	0f b6 16             	movzbl (%rsi),%edx
  8041604eb1:	29 d0                	sub    %edx,%eax
}
  8041604eb3:	c3                   	retq   

0000008041604eb4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  8041604eb4:	48 85 d2             	test   %rdx,%rdx
  8041604eb7:	74 2f                	je     8041604ee8 <strncmp+0x34>
  8041604eb9:	0f b6 07             	movzbl (%rdi),%eax
  8041604ebc:	84 c0                	test   %al,%al
  8041604ebe:	74 1f                	je     8041604edf <strncmp+0x2b>
  8041604ec0:	3a 06                	cmp    (%rsi),%al
  8041604ec2:	75 1b                	jne    8041604edf <strncmp+0x2b>
  8041604ec4:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  8041604ec7:	48 83 c7 01          	add    $0x1,%rdi
  8041604ecb:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  8041604ecf:	48 39 d7             	cmp    %rdx,%rdi
  8041604ed2:	74 1a                	je     8041604eee <strncmp+0x3a>
  8041604ed4:	0f b6 07             	movzbl (%rdi),%eax
  8041604ed7:	84 c0                	test   %al,%al
  8041604ed9:	74 04                	je     8041604edf <strncmp+0x2b>
  8041604edb:	3a 06                	cmp    (%rsi),%al
  8041604edd:	74 e8                	je     8041604ec7 <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  8041604edf:	0f b6 07             	movzbl (%rdi),%eax
  8041604ee2:	0f b6 16             	movzbl (%rsi),%edx
  8041604ee5:	29 d0                	sub    %edx,%eax
}
  8041604ee7:	c3                   	retq   
    return 0;
  8041604ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604eed:	c3                   	retq   
  8041604eee:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604ef3:	c3                   	retq   

0000008041604ef4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  8041604ef4:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  8041604ef6:	0f b6 07             	movzbl (%rdi),%eax
  8041604ef9:	84 c0                	test   %al,%al
  8041604efb:	74 1e                	je     8041604f1b <strchr+0x27>
    if (*s == c)
  8041604efd:	40 38 c6             	cmp    %al,%sil
  8041604f00:	74 1f                	je     8041604f21 <strchr+0x2d>
  for (; *s; s++)
  8041604f02:	48 83 c7 01          	add    $0x1,%rdi
  8041604f06:	0f b6 07             	movzbl (%rdi),%eax
  8041604f09:	84 c0                	test   %al,%al
  8041604f0b:	74 08                	je     8041604f15 <strchr+0x21>
    if (*s == c)
  8041604f0d:	38 d0                	cmp    %dl,%al
  8041604f0f:	75 f1                	jne    8041604f02 <strchr+0xe>
  for (; *s; s++)
  8041604f11:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  8041604f14:	c3                   	retq   
  return 0;
  8041604f15:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f1a:	c3                   	retq   
  8041604f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  8041604f20:	c3                   	retq   
    if (*s == c)
  8041604f21:	48 89 f8             	mov    %rdi,%rax
  8041604f24:	c3                   	retq   

0000008041604f25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  8041604f25:	48 89 f8             	mov    %rdi,%rax
  8041604f28:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  8041604f2a:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  8041604f2d:	40 38 f2             	cmp    %sil,%dl
  8041604f30:	74 13                	je     8041604f45 <strfind+0x20>
  8041604f32:	84 d2                	test   %dl,%dl
  8041604f34:	74 0f                	je     8041604f45 <strfind+0x20>
  for (; *s; s++)
  8041604f36:	48 83 c0 01          	add    $0x1,%rax
  8041604f3a:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  8041604f3d:	38 ca                	cmp    %cl,%dl
  8041604f3f:	74 04                	je     8041604f45 <strfind+0x20>
  8041604f41:	84 d2                	test   %dl,%dl
  8041604f43:	75 f1                	jne    8041604f36 <strfind+0x11>
      break;
  return (char *)s;
}
  8041604f45:	c3                   	retq   

0000008041604f46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  8041604f46:	48 85 d2             	test   %rdx,%rdx
  8041604f49:	74 3a                	je     8041604f85 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8041604f4b:	48 89 f8             	mov    %rdi,%rax
  8041604f4e:	48 09 d0             	or     %rdx,%rax
  8041604f51:	a8 03                	test   $0x3,%al
  8041604f53:	75 28                	jne    8041604f7d <memset+0x37>
    uint32_t k = c & 0xFFU;
  8041604f55:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  8041604f59:	89 f0                	mov    %esi,%eax
  8041604f5b:	c1 e0 08             	shl    $0x8,%eax
  8041604f5e:	89 f1                	mov    %esi,%ecx
  8041604f60:	c1 e1 18             	shl    $0x18,%ecx
  8041604f63:	41 89 f0             	mov    %esi,%r8d
  8041604f66:	41 c1 e0 10          	shl    $0x10,%r8d
  8041604f6a:	44 09 c1             	or     %r8d,%ecx
  8041604f6d:	09 ce                	or     %ecx,%esi
  8041604f6f:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  8041604f71:	48 c1 ea 02          	shr    $0x2,%rdx
  8041604f75:	48 89 d1             	mov    %rdx,%rcx
  8041604f78:	fc                   	cld    
  8041604f79:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  8041604f7b:	eb 08                	jmp    8041604f85 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  8041604f7d:	89 f0                	mov    %esi,%eax
  8041604f7f:	48 89 d1             	mov    %rdx,%rcx
  8041604f82:	fc                   	cld    
  8041604f83:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  8041604f85:	48 89 f8             	mov    %rdi,%rax
  8041604f88:	c3                   	retq   

0000008041604f89 <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  8041604f89:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  8041604f8c:	48 39 fe             	cmp    %rdi,%rsi
  8041604f8f:	73 40                	jae    8041604fd1 <memmove+0x48>
  8041604f91:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  8041604f95:	48 39 f9             	cmp    %rdi,%rcx
  8041604f98:	76 37                	jbe    8041604fd1 <memmove+0x48>
    s += n;
    d += n;
  8041604f9a:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8041604f9e:	48 89 fe             	mov    %rdi,%rsi
  8041604fa1:	48 09 d6             	or     %rdx,%rsi
  8041604fa4:	48 09 ce             	or     %rcx,%rsi
  8041604fa7:	40 f6 c6 03          	test   $0x3,%sil
  8041604fab:	75 14                	jne    8041604fc1 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  8041604fad:	48 83 ef 04          	sub    $0x4,%rdi
  8041604fb1:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  8041604fb5:	48 c1 ea 02          	shr    $0x2,%rdx
  8041604fb9:	48 89 d1             	mov    %rdx,%rcx
  8041604fbc:	fd                   	std    
  8041604fbd:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8041604fbf:	eb 0e                	jmp    8041604fcf <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  8041604fc1:	48 83 ef 01          	sub    $0x1,%rdi
  8041604fc5:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  8041604fc9:	48 89 d1             	mov    %rdx,%rcx
  8041604fcc:	fd                   	std    
  8041604fcd:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  8041604fcf:	fc                   	cld    
  8041604fd0:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  8041604fd1:	48 89 c1             	mov    %rax,%rcx
  8041604fd4:	48 09 d1             	or     %rdx,%rcx
  8041604fd7:	48 09 f1             	or     %rsi,%rcx
  8041604fda:	f6 c1 03             	test   $0x3,%cl
  8041604fdd:	75 0e                	jne    8041604fed <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  8041604fdf:	48 c1 ea 02          	shr    $0x2,%rdx
  8041604fe3:	48 89 d1             	mov    %rdx,%rcx
  8041604fe6:	48 89 c7             	mov    %rax,%rdi
  8041604fe9:	fc                   	cld    
  8041604fea:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8041604fec:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  8041604fed:	48 89 c7             	mov    %rax,%rdi
  8041604ff0:	48 89 d1             	mov    %rdx,%rcx
  8041604ff3:	fc                   	cld    
  8041604ff4:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  8041604ff6:	c3                   	retq   

0000008041604ff7 <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  8041604ff7:	55                   	push   %rbp
  8041604ff8:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  8041604ffb:	48 b8 89 4f 60 41 80 	movabs $0x8041604f89,%rax
  8041605002:	00 00 00 
  8041605005:	ff d0                	callq  *%rax
}
  8041605007:	5d                   	pop    %rbp
  8041605008:	c3                   	retq   

0000008041605009 <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  8041605009:	55                   	push   %rbp
  804160500a:	48 89 e5             	mov    %rsp,%rbp
  804160500d:	41 57                	push   %r15
  804160500f:	41 56                	push   %r14
  8041605011:	41 55                	push   %r13
  8041605013:	41 54                	push   %r12
  8041605015:	53                   	push   %rbx
  8041605016:	48 83 ec 08          	sub    $0x8,%rsp
  804160501a:	49 89 fe             	mov    %rdi,%r14
  804160501d:	49 89 f7             	mov    %rsi,%r15
  8041605020:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  8041605023:	48 89 f7             	mov    %rsi,%rdi
  8041605026:	48 b8 7e 4d 60 41 80 	movabs $0x8041604d7e,%rax
  804160502d:	00 00 00 
  8041605030:	ff d0                	callq  *%rax
  8041605032:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  8041605035:	4c 89 ee             	mov    %r13,%rsi
  8041605038:	4c 89 f7             	mov    %r14,%rdi
  804160503b:	48 b8 a0 4d 60 41 80 	movabs $0x8041604da0,%rax
  8041605042:	00 00 00 
  8041605045:	ff d0                	callq  *%rax
  8041605047:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  804160504a:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  804160504e:	4d 39 e5             	cmp    %r12,%r13
  8041605051:	74 26                	je     8041605079 <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  8041605053:	4c 89 e8             	mov    %r13,%rax
  8041605056:	4c 29 e0             	sub    %r12,%rax
  8041605059:	48 39 d8             	cmp    %rbx,%rax
  804160505c:	76 2a                	jbe    8041605088 <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  804160505e:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  8041605062:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8041605066:	4c 89 fe             	mov    %r15,%rsi
  8041605069:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  8041605070:	00 00 00 
  8041605073:	ff d0                	callq  *%rax
  return dstlen + srclen;
  8041605075:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  8041605079:	48 83 c4 08          	add    $0x8,%rsp
  804160507d:	5b                   	pop    %rbx
  804160507e:	41 5c                	pop    %r12
  8041605080:	41 5d                	pop    %r13
  8041605082:	41 5e                	pop    %r14
  8041605084:	41 5f                	pop    %r15
  8041605086:	5d                   	pop    %rbp
  8041605087:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  8041605088:	49 83 ed 01          	sub    $0x1,%r13
  804160508c:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  8041605090:	4c 89 ea             	mov    %r13,%rdx
  8041605093:	4c 89 fe             	mov    %r15,%rsi
  8041605096:	48 b8 f7 4f 60 41 80 	movabs $0x8041604ff7,%rax
  804160509d:	00 00 00 
  80416050a0:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  80416050a2:	4d 01 ee             	add    %r13,%r14
  80416050a5:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  80416050aa:	eb c9                	jmp    8041605075 <strlcat+0x6c>

00000080416050ac <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  80416050ac:	48 85 d2             	test   %rdx,%rdx
  80416050af:	74 3a                	je     80416050eb <memcmp+0x3f>
    if (*s1 != *s2)
  80416050b1:	0f b6 0f             	movzbl (%rdi),%ecx
  80416050b4:	44 0f b6 06          	movzbl (%rsi),%r8d
  80416050b8:	44 38 c1             	cmp    %r8b,%cl
  80416050bb:	75 1d                	jne    80416050da <memcmp+0x2e>
  80416050bd:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  80416050c2:	48 39 d0             	cmp    %rdx,%rax
  80416050c5:	74 1e                	je     80416050e5 <memcmp+0x39>
    if (*s1 != *s2)
  80416050c7:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  80416050cb:	48 83 c0 01          	add    $0x1,%rax
  80416050cf:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  80416050d5:	44 38 c1             	cmp    %r8b,%cl
  80416050d8:	74 e8                	je     80416050c2 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  80416050da:	0f b6 c1             	movzbl %cl,%eax
  80416050dd:	45 0f b6 c0          	movzbl %r8b,%r8d
  80416050e1:	44 29 c0             	sub    %r8d,%eax
  80416050e4:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  80416050e5:	b8 00 00 00 00       	mov    $0x0,%eax
  80416050ea:	c3                   	retq   
  80416050eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80416050f0:	c3                   	retq   

00000080416050f1 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  80416050f1:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  80416050f5:	48 39 c7             	cmp    %rax,%rdi
  80416050f8:	73 19                	jae    8041605113 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  80416050fa:	89 f2                	mov    %esi,%edx
  80416050fc:	40 38 37             	cmp    %sil,(%rdi)
  80416050ff:	74 16                	je     8041605117 <memfind+0x26>
  for (; s < ends; s++)
  8041605101:	48 83 c7 01          	add    $0x1,%rdi
  8041605105:	48 39 f8             	cmp    %rdi,%rax
  8041605108:	74 08                	je     8041605112 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  804160510a:	38 17                	cmp    %dl,(%rdi)
  804160510c:	75 f3                	jne    8041605101 <memfind+0x10>
  for (; s < ends; s++)
  804160510e:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  8041605111:	c3                   	retq   
  8041605112:	c3                   	retq   
  for (; s < ends; s++)
  8041605113:	48 89 f8             	mov    %rdi,%rax
  8041605116:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  8041605117:	48 89 f8             	mov    %rdi,%rax
  804160511a:	c3                   	retq   

000000804160511b <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  804160511b:	0f b6 07             	movzbl (%rdi),%eax
  804160511e:	3c 20                	cmp    $0x20,%al
  8041605120:	74 04                	je     8041605126 <strtol+0xb>
  8041605122:	3c 09                	cmp    $0x9,%al
  8041605124:	75 0f                	jne    8041605135 <strtol+0x1a>
    s++;
  8041605126:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  804160512a:	0f b6 07             	movzbl (%rdi),%eax
  804160512d:	3c 20                	cmp    $0x20,%al
  804160512f:	74 f5                	je     8041605126 <strtol+0xb>
  8041605131:	3c 09                	cmp    $0x9,%al
  8041605133:	74 f1                	je     8041605126 <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  8041605135:	3c 2b                	cmp    $0x2b,%al
  8041605137:	74 2b                	je     8041605164 <strtol+0x49>
  int neg  = 0;
  8041605139:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  804160513f:	3c 2d                	cmp    $0x2d,%al
  8041605141:	74 2d                	je     8041605170 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8041605143:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  8041605149:	75 0f                	jne    804160515a <strtol+0x3f>
  804160514b:	80 3f 30             	cmpb   $0x30,(%rdi)
  804160514e:	74 2c                	je     804160517c <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  8041605150:	85 d2                	test   %edx,%edx
  8041605152:	b8 0a 00 00 00       	mov    $0xa,%eax
  8041605157:	0f 44 d0             	cmove  %eax,%edx
  804160515a:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  804160515f:	4c 63 d2             	movslq %edx,%r10
  8041605162:	eb 5c                	jmp    80416051c0 <strtol+0xa5>
    s++;
  8041605164:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  8041605168:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  804160516e:	eb d3                	jmp    8041605143 <strtol+0x28>
    s++, neg = 1;
  8041605170:	48 83 c7 01          	add    $0x1,%rdi
  8041605174:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  804160517a:	eb c7                	jmp    8041605143 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  804160517c:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  8041605180:	74 0f                	je     8041605191 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  8041605182:	85 d2                	test   %edx,%edx
  8041605184:	75 d4                	jne    804160515a <strtol+0x3f>
    s++, base = 8;
  8041605186:	48 83 c7 01          	add    $0x1,%rdi
  804160518a:	ba 08 00 00 00       	mov    $0x8,%edx
  804160518f:	eb c9                	jmp    804160515a <strtol+0x3f>
    s += 2, base = 16;
  8041605191:	48 83 c7 02          	add    $0x2,%rdi
  8041605195:	ba 10 00 00 00       	mov    $0x10,%edx
  804160519a:	eb be                	jmp    804160515a <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  804160519c:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  80416051a0:	41 80 f8 19          	cmp    $0x19,%r8b
  80416051a4:	77 2f                	ja     80416051d5 <strtol+0xba>
      dig = *s - 'a' + 10;
  80416051a6:	44 0f be c1          	movsbl %cl,%r8d
  80416051aa:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  80416051ae:	39 d1                	cmp    %edx,%ecx
  80416051b0:	7d 37                	jge    80416051e9 <strtol+0xce>
    s++, val = (val * base) + dig;
  80416051b2:	48 83 c7 01          	add    $0x1,%rdi
  80416051b6:	49 0f af c2          	imul   %r10,%rax
  80416051ba:	48 63 c9             	movslq %ecx,%rcx
  80416051bd:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  80416051c0:	0f b6 0f             	movzbl (%rdi),%ecx
  80416051c3:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  80416051c7:	41 80 f8 09          	cmp    $0x9,%r8b
  80416051cb:	77 cf                	ja     804160519c <strtol+0x81>
      dig = *s - '0';
  80416051cd:	0f be c9             	movsbl %cl,%ecx
  80416051d0:	83 e9 30             	sub    $0x30,%ecx
  80416051d3:	eb d9                	jmp    80416051ae <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  80416051d5:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  80416051d9:	41 80 f8 19          	cmp    $0x19,%r8b
  80416051dd:	77 0a                	ja     80416051e9 <strtol+0xce>
      dig = *s - 'A' + 10;
  80416051df:	44 0f be c1          	movsbl %cl,%r8d
  80416051e3:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  80416051e7:	eb c5                	jmp    80416051ae <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  80416051e9:	48 85 f6             	test   %rsi,%rsi
  80416051ec:	74 03                	je     80416051f1 <strtol+0xd6>
    *endptr = (char *)s;
  80416051ee:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  80416051f1:	48 89 c2             	mov    %rax,%rdx
  80416051f4:	48 f7 da             	neg    %rdx
  80416051f7:	45 85 c9             	test   %r9d,%r9d
  80416051fa:	48 0f 45 c2          	cmovne %rdx,%rax
}
  80416051fe:	c3                   	retq   
  80416051ff:	90                   	nop

0000008041605200 <_efi_call_in_32bit_mode_asm>:

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
  8041605200:	55                   	push   %rbp
    movq %rsp, %rbp
  8041605201:	48 89 e5             	mov    %rsp,%rbp
    /* save non-volatile registers */
	push	%rbx
  8041605204:	53                   	push   %rbx
	push	%r12
  8041605205:	41 54                	push   %r12
	push	%r13
  8041605207:	41 55                	push   %r13
	push	%r14
  8041605209:	41 56                	push   %r14
	push	%r15
  804160520b:	41 57                	push   %r15

	/* save parameters that we will need later */
	push	%rsi
  804160520d:	56                   	push   %rsi
	push	%rcx
  804160520e:	51                   	push   %rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
  804160520f:	55                   	push   %rbp
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */
  8041605210:	48 29 cc             	sub    %rcx,%rsp

	COPY_STACK(%rdx, %rcx, %r8)
  8041605213:	49 c7 c0 00 00 00 00 	mov    $0x0,%r8

000000804160521a <copyloop>:
  804160521a:	4a 8b 04 02          	mov    (%rdx,%r8,1),%rax
  804160521e:	4a 89 04 04          	mov    %rax,(%rsp,%r8,1)
  8041605222:	49 83 c0 08          	add    $0x8,%r8
  8041605226:	49 39 c8             	cmp    %rcx,%r8
  8041605229:	75 ef                	jne    804160521a <copyloop>
	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()
  804160522b:	e8 00 00 00 00       	callq  8041605230 <copyloop+0x16>
  8041605230:	48 81 04 24 11 00 00 	addq   $0x11,(%rsp)
  8041605237:	00 
  8041605238:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%rsp)
  804160523f:	00 
  8041605240:	cb                   	lret   

	call	*%edi			/* call EFI runtime */
  8041605241:	ff d7                	callq  *%rdi

	ENTER_64BIT_MODE()
  8041605243:	6a 08                	pushq  $0x8
  8041605245:	e8 00 00 00 00       	callq  804160524a <copyloop+0x30>
  804160524a:	81 04 24 08 00 00 00 	addl   $0x8,(%rsp)
  8041605251:	cb                   	lret   

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
  8041605252:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
	mov	%rax, 32(%rsi)		/* save RAX back */
  8041605256:	48 89 46 20          	mov    %rax,0x20(%rsi)

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
  804160525a:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
	add	%rcx, %rsp	/* discard stack contents */
  804160525e:	48 01 cc             	add    %rcx,%rsp
	pop	%rbp		/* restore full 64-bit frame pointer */
  8041605261:	5d                   	pop    %rbp
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
  8041605262:	59                   	pop    %rcx
	pop	%rsi
  8041605263:	5e                   	pop    %rsi
	pop	%r15
  8041605264:	41 5f                	pop    %r15
	pop	%r14
  8041605266:	41 5e                	pop    %r14
	pop	%r13
  8041605268:	41 5d                	pop    %r13
	pop	%r12
  804160526a:	41 5c                	pop    %r12
	pop	%rbx
  804160526c:	5b                   	pop    %rbx

	leave
  804160526d:	c9                   	leaveq 
	ret
  804160526e:	c3                   	retq   
  804160526f:	90                   	nop
