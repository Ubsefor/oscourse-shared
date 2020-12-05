
#include "fs.h"

// Return the virtual address of this disk block.
void *
diskaddr(uint32_t blockno) {
  if (blockno == 0 || (super && blockno >= super->s_nblocks))
    panic("bad block number %08x in diskaddr", blockno);
  void *r = (void *)(uintptr_t)(DISKMAP + blockno * BLKSIZE);
#ifdef SANITIZE_USER_SHADOW_BASE
  platform_asan_unpoison(r, BLKSIZE);
#endif
  return r;
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va) {
  return ((uvpml4e[PML4(va)] & PTE_P) && (uvpde[VPDPE(va)] & PTE_P) &&
          (uvpd[VPD(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P));
}

// Is this virtual address dirty?
bool
va_is_dirty(void *va) {
  return (uvpt[PGNUM(va)] & PTE_D) != 0;
}

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf) {
  void *addr       = (void *)utf->utf_fault_va;
  uint32_t blockno = (uint32_t)((uintptr_t)addr - (uintptr_t)DISKMAP) / BLKSIZE;

  // Check that the fault was within the block cache region
  if (addr < (void *)DISKMAP || addr >= (void *)(DISKMAP + DISKSIZE))
    panic("page fault in FS: eip %p, va %p, err %04lx",
          (void *)utf->utf_rip, addr, (unsigned long)utf->utf_err);

  // Sanity check the block number.
  if (super && blockno >= super->s_nblocks)
    panic("reading non-existent block %08x out of %08x\n", blockno, super->s_nblocks);

  // Allocate a page in the disk map region, read the contents
  // of the block from the disk into that page.
  // Hint: first round addr to page boundary. fs/ide.c has code to read
  // the disk.
  
  // LAB 10 code
  int r;
  addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, addr, PTE_W)) < 0) {
		panic("bc_pgfault: sys_page_alloc: %i", r);
  }
	if ((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0) {
		panic("bc_pgfault: ide_read: %i", r);
  }

  // Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0) {
		panic("in bc_pgfault, sys_page_map: %i", r);
  }

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno)) {
		panic("reading free block %08x\n", blockno);
  }
  // LAB 10 code end
}

// Flush the contents of the block containing VA out to disk if
// necessary, then clear the PTE_D bit using sys_page_map.
// If the block is not in the block cache or is not dirty, does
// nothing.
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr) {
  uint32_t blockno = (uint32_t)((uintptr_t)addr - (uintptr_t)DISKMAP) / BLKSIZE;

  if (addr < (void *)(uintptr_t)DISKMAP || addr >= (void *)(uintptr_t)(DISKMAP + DISKSIZE))
    panic("flush_block of bad va %p", addr);
  if (super && blockno >= super->s_nblocks)
    panic("reading non-existent block %08x out of %08x\n", blockno, super->s_nblocks);

  // LAB 10 code
  if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE)) {
		panic("flush_block of bad va %p", addr);
  }

  addr = ROUNDDOWN(addr, PGSIZE);
	if (!va_is_mapped(addr) || !va_is_dirty(addr)) {
		return;
  }

  int r;
  if ((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0) {
		panic("flush_block: ide_write: %i", r);
    }
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0) {
		panic("flush_block: sys_page_map: %i", r);
    }
  // LAB 10 code end
}

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void) {
  struct Super backup;

  // back up super block
  memmove(&backup, diskaddr(1), sizeof backup);

  // smash it
  strcpy(diskaddr(1), "OOPS!\n");
  flush_block(diskaddr(1));
  assert(va_is_mapped(diskaddr(1)));
  assert(!va_is_dirty(diskaddr(1)));

  // clear it out
  sys_page_unmap(0, diskaddr(1));
  assert(!va_is_mapped(diskaddr(1)));

  // read it back in
  assert(strcmp(diskaddr(1), "OOPS!\n") == 0);

  // fix it
  memmove(diskaddr(1), &backup, sizeof backup);
  flush_block(diskaddr(1));

  cprintf("block cache is good\n");
}

void
bc_init(void) {
  struct Super super;
  set_pgfault_handler(bc_pgfault);
  check_bc();

  // cache the super block by reading it once
  memmove(&super, diskaddr(1), sizeof super);
}
