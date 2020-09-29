#include <inc/mmu.h>
#include <inc/memlayout.h>

# Normal x86-64 4-level translation looks like CR3->PML4->PDPE->PDE->PTE.
# We set the PTE_MBZ bits in PDE (pgdir) to skip the last step.
.code64
.set pml4,   pml4phys
.set pdpt1,  pml4 + 0x1000
.set pdpt2,  pml4 + 2*0x1000
.set pde1,   pml4 + 3*0x1000
.set pde2,   pml4 + 4*0x1000

#define PML_SIZE 11264 ///< 4096/4 * 11

.text
.globl _head64
_head64:
  # Disable interrupts.
  cli

  # Save Loader_block pointer from Bootloader.c in r12.
  movq %rcx,%r12

  # Build an early boot pml4 at pml4phys (physical = virtual for it).

  # Initialize the page tables.
  movl $pml4,%edi
  xorl %eax,%eax
  movl $PML_SIZE,%ecx  # moving these many words to the 11 pages
  rep stosl

  # Creating a 4G boot page table...
  # Setting the 4-level page table with only the second entry needed (PML4).
  movl $pml4,%eax
  movl $pdpt1, %ebx
  orl $PTE_P,%ebx
  orl $PTE_W,%ebx
  movl %ebx,(%eax)

  movl $pdpt2, %ebx
  orl $PTE_P,%ebx
  orl $PTE_W,%ebx
  movl %ebx,0x8(%eax)

  # Setting the 3rd level page table (PDPE).
  # 4 entries (counter in ecx), point to the next four physical pages (pgdirs).
  # pgdirs in 0xa0000--0xd000.
  movl $pdpt1,%edi
  movl $pde1,%ebx
  orl $PTE_P,%ebx
  orl $PTE_W,%ebx
  movl %ebx,(%edi)

  movl $pdpt2,%edi
  movl $pde2,%ebx
  orl $PTE_P,%ebx
  orl $PTE_W,%ebx
  # 2nd entry - 0x8040000000
  movl %ebx,0x8(%edi)

  # Setting the pgdir so that the LA=PA.
  # Mapping first 1024mb of mem at KERNBASE.
  movl $512,%ecx
  # Start at the end and work backwards
  movl $pde1,%edi
  movl $pde2,%ebx
  # 1st entry - 0x8040000000

  # PTE_P|PTE_W|PTE_MBZ
  movl $0x00000183,%eax
1:
  movl %eax,(%edi)
  movl %eax,(%ebx)
  addl $0x8,%edi
  addl $0x8,%ebx
  addl $0x00200000,%eax
  subl $1,%ecx
  cmp $0x0,%ecx
  jne 1b

  # Update CR3 register.
  movq $pml4,%rax
  movq %rax, %cr3

  # Transition to high mem entry code and pass LoadParams address.
  movabs $entry,%rax
  movq %r12, %rcx
  jmpq *%rax

.data
.p2align PGSHIFT

.globl pml4phys
pml4phys:
.space 11*PGSIZE

.globl pdefreestart
.set pdefreestart, pde2 + PGSIZE

.globl pdefreeend
.set pdefreeend, pml4phys + 11*PGSIZE
