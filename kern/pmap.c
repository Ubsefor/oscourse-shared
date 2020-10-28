/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/kclock.h>
#include <kern/env.h>
#include <inc/uefi.h>

#ifdef SANITIZE_SHADOW_BASE
// asan unpoison routine used for whitelisting regions.
void platform_asan_unpoison(void *addr, uint32_t size);
// not sanitized memset allows us to access "invalid" areas for extra poisoning.
void *__nosan_memset(void *, int, size_t);
#endif

extern uint64_t pml4phys;
// These variables are set by i386_detect_memory()
size_t npages;                // Amount of physical memory (in pages)
static size_t npages_basemem; // Amount of base memory (in pages)

// These variables are set in mem_init()
pde_t *kern_pml4e;                                 // Kernel's initial page directory
physaddr_t kern_cr3;                               // Physical address of boot time page directory
struct PageInfo *pages;                            // Physical page state array
static struct PageInfo *page_free_list     = NULL; // Free list of physical pages
static struct PageInfo *page_free_list_top = NULL;
//Pointers to start and end of UEFI memory map
EFI_MEMORY_DESCRIPTOR *mmap_base = NULL;
EFI_MEMORY_DESCRIPTOR *mmap_end  = NULL;
size_t mem_map_size              = 0;

// --------------------------------------------------------------
// Detect machine's physical memory setup.
// --------------------------------------------------------------

//Count all available to the system pages (checks for avaiability
//should be done in page_init).
static void
load_params_read(LOADER_PARAMS *desc, size_t *npages_basemem, size_t *npages_extmem) {
  EFI_MEMORY_DESCRIPTOR *mmap_curr;
  size_t num_pages = 0;
  mem_map_size     = desc->MemoryMapDescriptorSize;
  mmap_base        = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)desc->MemoryMap;
  mmap_end         = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)desc->MemoryMap + desc->MemoryMapSize);

  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
    num_pages += mmap_curr->NumberOfPages;
  }

  *npages_basemem = num_pages > (IOPHYSMEM / PGSIZE) ? IOPHYSMEM / PGSIZE : num_pages;
  *npages_extmem  = num_pages - *npages_basemem;
}

static void
i386_detect_memory(void) {
  size_t npages_extmem;
  size_t pextmem;

  if (uefi_lp && uefi_lp->MemoryMap) {
    load_params_read(uefi_lp, &npages_basemem, &npages_extmem);
  } else {
    // Use CMOS calls to measure available base & extended memory.
    // (CMOS calls return results in kilobytes.)
    npages_basemem = (mc146818_read16(NVRAM_BASELO) * 1024) / PGSIZE;
    npages_extmem  = (mc146818_read16(NVRAM_EXTLO) * 1024) / PGSIZE;
    pextmem        = ((size_t)mc146818_read16(NVRAM_PEXTLO) * 1024 * 64);
    if (pextmem)
      npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  }

  // Calculate the number of physical pages available in both base
  // and extended memory.
  if (npages_extmem)
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  else
    npages = npages_basemem;

  cprintf("Physical memory: %luM available, base = %luK, extended = %luK\n",
          (unsigned long)(npages * PGSIZE / 1024 / 1024),
          (unsigned long)(npages_basemem * PGSIZE / 1024),
          (unsigned long)(npages_extmem * PGSIZE / 1024));
}

//
//Check if page is allocatable according to saved UEFI MemMap.
//
bool
is_page_allocatable(size_t pgnum) {
  EFI_MEMORY_DESCRIPTOR *mmap_curr;
  size_t pg_start, pg_end;

  if (!mmap_base || !mmap_end)
    return true; //Assume page is allocabale if no loading parameters were passed.

  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
    pg_start = ((uintptr_t)mmap_curr->PhysicalStart >> EFI_PAGE_SHIFT);
    pg_end   = pg_start + mmap_curr->NumberOfPages;

    if (pgnum >= pg_start && pgnum < pg_end) {
      switch (mmap_curr->Type) {
        case EFI_LOADER_CODE:
        case EFI_LOADER_DATA:
        case EFI_BOOT_SERVICES_CODE:
        case EFI_BOOT_SERVICES_DATA:
        case EFI_CONVENTIONAL_MEMORY:
          if (mmap_curr->Attribute & EFI_MEMORY_WB)
            return true;
          else
            return false;
          break;
        default:
          return false;
          break;
      }
    }
  }
  //Assume page is allocatable if it's not found in MemMap.
  return true;
}

// Fix loading params and memory map address to virtual ones.
static void
fix_lp_addresses(void) {
  mmap_base = (EFI_MEMORY_DESCRIPTOR *)(uintptr_t)uefi_lp->MemoryMapVirt;
  mmap_end  = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)uefi_lp->MemoryMapVirt + uefi_lp->MemoryMapSize);
  uefi_lp   = (LOADER_PARAMS *)uefi_lp->SelfVirtual;
}

// --------------------------------------------------------------
// Set up memory mappings above UTOP.
// --------------------------------------------------------------

static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm);
static void check_page_free_list(bool only_low_memory);
static void check_page_alloc(void);
static void check_kern_pml4e(void);
static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va);
static void check_page(void);
static void check_page_installed_pml4(void);

// This simple physical memory allocator is used only while JOS is setting
// up its virtual memory system.  page_alloc() is the real allocator.
//
// If n>0, allocates enough pages of contiguous physical memory to hold 'n'
// bytes.  Doesn't initialize the memory.  Returns a kernel virtual address.
//
// If n==0, returns the address of the next free page without allocating
// anything.
//
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n) {
  static char *nextfree; // virtual address of next byte of free memory
  char *result;

  // Initialize nextfree if this is the first time.
  // 'end' is a magic symbol automatically generated by the linker,
  // which points to the end of the kernel's bss segment:
  // the first virtual address that the linker did *not* assign
  // to any kernel code or global variables.

  if (!nextfree) {
    extern char end[];
    nextfree = ROUNDUP((char *)end, PGSIZE);
  }

  // Allocate a chunk large enough to hold 'n' bytes, then update
  // nextfree.  Make sure nextfree is kept aligned
  // to a multiple of PGSIZE.
  //
  // LAB 6: Your code here.

  if (!n) {
    return nextfree;
  }
  result = nextfree;
  nextfree += ROUNDUP(n, PGSIZE);
  if (PADDR(nextfree) > PGSIZE * npages) {
    panic("Out of memory on boot, what? how?!");
  }
// This is for sanitizers
#ifdef SANITIZE_SHADOW_BASE
  // Unpoison the result since it is now allocated.
  platform_asan_unpoison(result, n);
#endif

  return result;
}

// Set up a two-level page table:
//    kern_pml4e is its linear (virtual) address of the root
//
// This function only sets up the kernel part of the address space
// (ie. addresses >= UTOP).  The user part of the address space
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void) {
  pml4e_t *pml4e;

  // Find out how much memory the machine has (npages & npages_basemem).
  i386_detect_memory();

  // Remove this line when you're ready to test this function.
  // panic("mem_init: This function is not finished\n");

  //////////////////////////////////////////////////////////////////////
  // create initial page directory.
  pml4e = boot_alloc(PGSIZE);
  memset(pml4e, 0, PGSIZE);
  kern_pml4e = pml4e;
  kern_cr3   = PADDR(pml4e);

  //////////////////////////////////////////////////////////////////////
  // Recursively insert PD in itself as a page table, to form
  // a virtual page table at virtual address UVPT.
  // (For now, you don't have understand the greater purpose of the
  // following line.)

  // Permissions: kernel R, user R
  kern_pml4e[PML4(UVPT)] = kern_cr3 | PTE_P | PTE_U;

  //////////////////////////////////////////////////////////////////////
  // Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
  // The kernel uses this array to keep track of physical pages: for
  // each physical page, there is a corresponding struct PageInfo in this
  // array.  'npages' is the number of physical pages in memory.  Use memset
  // to initialize all fields of each struct PageInfo to 0.
  // LAB 6: Your code here.

  pages = (struct PageInfo *)boot_alloc(sizeof(*pages) * npages);
  memset(pages, 0, sizeof(*pages) * npages);

  //////////////////////////////////////////////////////////////////////
  // Now that we've allocated the initial kernel data structures, we set
  // up the list of free physical pages. Once we've done so, all further
  // memory management will go through the page_* functions. In
  // particular, we can now map memory using boot_map_region
  // or page_insert
  page_init();

  check_page_free_list(1);
  check_page_alloc();
}

#ifdef SANITIZE_SHADOW_BASE
void
kasan_mem_init(void) {
  // Unpoison memory in which kernel was loaded
  platform_asan_unpoison((void *)KERNBASE, (uint32_t)(boot_alloc(0) - KERNBASE));

  // Go through all pages and unpoison pages which have at least one ref.
  for (int pgidx = 0; pgidx < npages; pgidx++) {
    if (pages[pgidx].pp_ref > 0) {
      platform_asan_unpoison(page2kva(&pages[pgidx]), PGSIZE);
    }
  }

  // Additinally map all UEFI runtime services corresponding shadow memory.
  EFI_MEMORY_DESCRIPTOR *mmap_curr;
  struct PageInfo *pg;
  uintptr_t virt_addr, virt_end;

  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
    virt_addr = ROUNDDOWN((uintptr_t)((mmap_curr->VirtualStart >> 3) +
                                      SANITIZE_SHADOW_OFF),
                          PGSIZE);
    virt_end  = ROUNDUP((uintptr_t)(virt_addr + (mmap_curr->NumberOfPages * PGSIZE >> 3)), PGSIZE);
    if (mmap_curr->Attribute & EFI_MEMORY_RUNTIME) {
      for (; virt_addr < virt_end; virt_addr += PGSIZE) {
        pg = page_alloc(ALLOC_ZERO);
        if (!pg)
          panic("region_alloc: page alloc failed!\n");

        if (page_insert(kern_pml4e, pg, (void *)virt_addr,
                        PTE_P | PTE_W) < 0)
          panic("Cannot allocate any memory for page directory allocation");
      }
    }
  }
}
#endif

// --------------------------------------------------------------
// Tracking of physical pages.
// The 'pages' array has one 'struct PageInfo' entry per physical page.
// Pages are reference counted, and free pages are kept on a linked list.
// --------------------------------------------------------------

//
// Initialize page structure and memory free list.
// After this is done, NEVER use boot_alloc again.  ONLY use the page
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void) {
  // The example code here marks all physical pages as free.
  // However this is not truly the case.  What memory is free?
  //  1) Mark physical page 0 as in use.
  //     This way we preserve the real-mode IDT and BIOS structures
  //     in case we ever need them.  (Currently we don't, but...)
  //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
  //     is free.
  //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
  //     never be allocated.
  //  4) Then extended memory [EXTPHYSMEM, ...).
  //     Some of it is in use, some is free. Where is the kernel
  //     in physical memory?  Which pages are already in use for
  //     page tables and other data structures?
  //
  // Change the code to reflect this.
  // NB: DO NOT actually touch the physical memory corresponding to
  // free pages!
  size_t i;
  uintptr_t first_free_page;
  struct PageInfo *last = NULL;

  //Mark physical page 0 as in use.
  pages[0].pp_ref  = 1;
  pages[0].pp_link = NULL;

  //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
  //     is free.
  pages[1].pp_ref = 0;
  page_free_list  = &pages[1];
  last            = &pages[1];
  for (i = 1; i < npages_basemem; i++) {
    if (is_page_allocatable(i)) {
      pages[i].pp_ref = 0;
      last->pp_link   = &pages[i];
      last            = &pages[i];
    } else {
      pages[i].pp_ref  = 1;
      pages[i].pp_link = NULL;
    }
  }

  //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
  //     never be allocated.
  first_free_page = PADDR(boot_alloc(0)) / PGSIZE;
  for (i = npages_basemem; i < first_free_page; i++) {
    pages[i].pp_ref  = 1;
    pages[i].pp_link = NULL;
  }

  //     Some of it is in use, some is free. Where is the kernel
  //     in physical memory?  Which pages are already in use for
  //     page tables and other data structures?
  for (i = first_free_page; i < npages; i++) {
    if (is_page_allocatable(i)) {
      pages[i].pp_ref = 0;
      last->pp_link   = &pages[i];
      last            = &pages[i];
    } else {
      pages[i].pp_ref  = 1;
      pages[i].pp_link = NULL;
    }
  }
}

//
// Allocates a physical page.  If (alloc_flags & ALLOC_ZERO), fills the entire
// returned physical page with '\0' bytes.  Does NOT increment the reference
// count of the page - the caller must do these if necessary (either explicitly
// or via page_insert).
//
// Be sure to set the pp_link field of the allocated page to NULL so
// page_free can check for double-free bugs.
//
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags) {

  // ne memory check
  if (!page_free_list) {
    return NULL;
  }

  struct PageInfo *return_page = page_free_list;
  page_free_list               = page_free_list->pp_link;
  return_page->pp_link         = NULL;

  if (!page_free_list) {
    page_free_list_top = NULL;
  }

#ifdef SANITIZE_SHADOW_BASE

  if ((uintptr_t)page2kva(return_page) >= SANITIZE_SHADOW_BASE) {
    cprintf("page_alloc: returning shadow memory page! Increase base address?\n");
    return NULL;
  }

  // Unpoison allocated memory before accessing it!
  platform_asan_unpoison(page2kva(return_page), PGSIZE);

#endif

  if (alloc_flags & ALLOC_ZERO) {
    memset(page2kva(return_page), 0, PGSIZE);
  }

  return return_page;
}

int
page_is_allocated(const struct PageInfo *pp) {
  return !pp->pp_link && pp != page_free_list_top;
}

//
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp) {
  // LAB 6: Fill this function in
  // Hint: You may want to panic if pp->pp_ref is nonzero or
  // pp->pp_link is not NULL.

  if (pp->pp_ref) {
    panic("page_free: Page is still referenced!\n");
  }

  if (pp->pp_link) {
    panic("page_free: Page is already freed!\n");
  }

  if (pp->pp_ref != 0 || pp->pp_link != NULL)
    panic("page_free: Page cannot be freed!\n");

  pp->pp_link    = page_free_list;
  page_free_list = pp;

  if (!page_free_list_top) {
    page_free_list_top = pp;
  }
}

//
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo *pp) {
  if (--pp->pp_ref == 0)
    page_free(pp);
}

// Given 'pgdir', a pointer to a page directory, pgdir_walk returns
// a pointer to the page table entry (PTE) for linear address 'va'.
// This requires walking the two-level page table structure.
//
// The relevant page table page might not exist yet.
// If this is true, and create == false, then pgdir_walk returns NULL.
// Otherwise, pgdir_walk allocates a new page table page with page_alloc.
//    - If the allocation fails, pgdir_walk returns NULL.
//    - Otherwise, the new page's reference count is incremented,
//	the page is cleared,
//	and pgdir_walk returns a pointer into the new page table page.
//
// Hint 1: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
//
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// directory more permissive than strictly necessary.
//
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pml4e_walk(pml4e_t *pml4e, const void *va, int create) {
  // LAB 7: Fill this function in
  return NULL;
}

pte_t *
pdpe_walk(pdpe_t *pdpe, const void *va, int create) {
  // LAB 7: Fill this function in
  return NULL;
}

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create) {
  // LAB 7: Fill this function in
  return NULL;
}

//
// Map [va, va+size) of virtual address space to physical [pa, pa+size)
// in the page table rooted at pgdir.  Size is a multiple of PGSIZE, and
// va and pa are both page-aligned.
// Use permission bits perm|PTE_P for the entries.
//
// This function is only intended to set up the ``static'' mappings
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pml4e_t *pml4e, uintptr_t va, size_t size, physaddr_t pa, int perm) {
  //  static void
  //  boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm){
  // LAB 7: Fill this function in
}

//
// Map the physical page 'pp' at virtual address 'va'.
// The permissions (the low 12 bits) of the page table entry
// should be set to 'perm|PTE_P'.
//
// Requirements
//   - If there is already a page mapped at 'va', it should be page_remove()d.
//   - If necessary, on demand, a page table should be allocated and inserted
//     into 'pgdir'.
//   - pp->pp_ref should be incremented if the insertion succeeds.
//   - The TLB must be invalidated if a page was formerly present at 'va'.
//
// Corner-case hint: Make sure to consider what happens when the same
// pp is re-inserted at the same virtual address in the same pgdir.
// However, try not to distinguish this case in your code, as this
// frequently leads to subtle bugs; there's an elegant way to handle
// everything in one code path.
//
// RETURNS:
//   0 on success
//   -E_NO_MEM, if page table couldn't be allocated
//
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pml4e_t *pml4e, struct PageInfo *pp, void *va, int perm) {
  // LAB 7: Fill this function in
  return 0;
}

//
// Return the page mapped at virtual address 'va'.
// If pte_store is not zero, then we store in it the address
// of the pte for this page.  This is used by page_remove and
// can be used to verify page permissions for syscall arguments,
// but should not be used by most callers.
//
// Return NULL if there is no page mapped at va.
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pml4e_t *pml4e, void *va, pte_t **pte_store) {
  // LAB 7: Fill this function in
  return NULL;
}

//
// Unmaps the physical page at virtual address 'va'.
// If there is no physical page at that address, silently does nothing.
//
// Details:
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
//   - The pg table entry corresponding to 'va' should be set to 0.
//     (if such a PTE exists)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
//
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pml4e_t *pml4e, void *va) {
  // LAB 7: Fill this function in
}

//
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pml4e_t *pml4e, void *va) {
  // Flush the entry only if we're modifying the current address space.
  // For now, there is only one address space, so always invalidate.
  invlpg(va);
}

//
// Reserve size bytes in the MMIO region and map [pa,pa+size) at this
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size) {
  // Where to start the next region.  Initially, this is the
  // beginning of the MMIO region.  Because this is static, its
  // value will be preserved between calls to mmio_map_region
  // (just like nextfree in boot_alloc).
  static uintptr_t base = MMIOBASE;

  // Reserve size bytes of virtual memory starting at base and
  // map physical pages [pa,pa+size) to virtual addresses
  // [base,base+size).  Since this is device memory and not
  // regular DRAM, you'll have to tell the CPU that it isn't
  // safe to cache access to this memory.  Luckily, the page
  // tables provide bits for this purpose; simply create the
  // mapping with PTE_PCD|PTE_PWT (cache-disable and
  // write-through) in addition to PTE_W.  (If you're interested
  // in more details on this, see section 10.5 of IA32 volume
  // 3A.)
  //
  // Be sure to round size up to a multiple of PGSIZE and to
  // handle if this reservation would overflow MMIOLIM (it's
  // okay to simply panic if this happens).
  //
  // Hint: The staff solution uses boot_map_region.
  //
  // LAB 6: Your code here:

  (void)base;
  return NULL;
}

// --------------------------------------------------------------
// Checking functions.
// --------------------------------------------------------------

//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory) {
  struct PageInfo *pp;
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  int nfree_basemem = 0, nfree_extmem = 0;
  char *first_free_page;

  if (!page_free_list)
    panic("'page_free_list' is a null pointer!");

  if (only_low_memory) {
    // Move pages with lower addresses first in the free
    // list, since entry_pgdir does not map all pages.
    struct PageInfo *pp1, *pp2;
    struct PageInfo **tp[2] = {&pp1, &pp2};
    for (pp = page_free_list; pp; pp = pp->pp_link) {
      int pagetype  = VPN(page2pa(pp)) >= pdx_limit;
      *tp[pagetype] = pp;
      tp[pagetype]  = &pp->pp_link;
    }
    *tp[1]         = 0;
    *tp[0]         = pp2;
    page_free_list = pp1;
  }

  // if there's a page that shouldn't be on the free list,
  // try to make sure it eventually causes trouble.
  /*for (pp = page_free_list; pp; pp = pp->pp_link) {
		if (VPN(page2pa(pp)) < pdx_limit) {
#ifdef SANITIZE_SHADOW_BASE
			// This is technically invalid memory, access it via unsanitized routine.
			__nosan_memset(page2kva(pp), 0x97, 128);
#else
			memset(page2kva(pp), 0x97, 128);
#endif
		}
	}*/

  first_free_page = (char *)boot_alloc(0);
  for (pp = page_free_list; pp; pp = pp->pp_link) {
    // check that we didn't corrupt the free list itself
    assert(pp >= pages);
    assert(pp < pages + npages);
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);

    // check a few pages that shouldn't be on the free list
    assert(page2pa(pp) != 0);
    assert(page2pa(pp) != IOPHYSMEM);
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
    assert(page2pa(pp) != EXTPHYSMEM);
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);

    if (page2pa(pp) < EXTPHYSMEM)
      ++nfree_basemem;
    else
      ++nfree_extmem;
  }

  //assert(nfree_basemem > 0);
  assert(nfree_extmem > 0);
}

//
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void) {
  struct PageInfo *pp, *pp0, *pp1, *pp2;
  int nfree;
  struct PageInfo *fl;
  char *c;
  int i;

  if (!pages)
    panic("'pages' is a null pointer!");

  // check number of free pages
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
    ++nfree;

  // should be able to allocate three pages
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  assert((pp1 = page_alloc(0)));
  assert((pp2 = page_alloc(0)));

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  assert(page2pa(pp0) < npages * PGSIZE);
  assert(page2pa(pp1) < npages * PGSIZE);
  assert(page2pa(pp2) < npages * PGSIZE);

  // temporarily steal the rest of the free pages
  fl             = page_free_list;
  page_free_list = 0;

  // should be no free memory
  assert(!page_alloc(0));

  // free and re-allocate?
  page_free(pp0);
  page_free(pp1);
  page_free(pp2);
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  assert((pp1 = page_alloc(0)));
  assert((pp2 = page_alloc(0)));
  assert(pp0);
  assert(pp1 && pp1 != pp0);
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  assert(!page_alloc(0));

  // test flags
  memset(page2kva(pp0), 1, PGSIZE);
  page_free(pp0);
  assert((pp = page_alloc(ALLOC_ZERO)));
  assert(pp && pp0 == pp);
  c = page2kva(pp);
  for (i = 0; i < PGSIZE; i++)
    assert(c[i] == 0);

  // give free list back
  page_free_list = fl;

  // free the pages we took
  page_free(pp0);
  page_free(pp1);
  page_free(pp2);

  // number of free pages should be the same
  for (pp = page_free_list; pp; pp = pp->pp_link)
    --nfree;
  assert(nfree == 0);

  cprintf("check_page_alloc() succeeded!\n");
}
