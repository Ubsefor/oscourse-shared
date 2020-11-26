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

void noop_dbg(){
  ;
}

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

  // LAB 6 code
  char * result;
  // LAB 6 code end

  // Initialize nextfree if this is the first time.
  // 'end' is a magic symbol automatically generated by the linker,
  // which points to the end of the kernel's bss segment:
  // the first virtual address that the linker did *not* assign
  // to any kernel code or global variables.

  // LAB 6 code
  if (!nextfree) {
		extern char end[];
		nextfree = ROUNDUP((char *)end, PGSIZE);
	}
  // LAB 6 code end

  // Allocate a chunk large enough to hold 'n' bytes, then update
  // nextfree.  Make sure nextfree is kept aligned
  // to a multiple of PGSIZE.

  // LAB 6 code
  if (!n) {
	    return nextfree;
	}
	result = nextfree;
	nextfree += ROUNDUP(n, PGSIZE);
	if (PADDR(nextfree) > PGSIZE * npages) {
	    panic("Not enough memory for boot!");
  }

  return result;
  // LAB 6 code end

  // (void)nextfree;
  // return NULL;
}

static struct PageInfo *
evaluate_page_free_list_top() {
  struct PageInfo *pp = page_free_list, *pt = NULL;
  while (pp) {
    pt = pp;
    pp = pp->pp_link;
  }
  return pt;
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
  size_t size_to_alloc;
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

  // LAB 6 code
  pages = (struct PageInfo *)boot_alloc(sizeof(* pages) * npages);
	memset(pages, 0, sizeof(*pages) * npages);
  // LAB 6 code end

  //////////////////////////////////////////////////////////////////////
  // Make 'envs' point to an array of size 'NENV' of 'struct Env'.

  // LAB 8 code 
  envs = (struct Env *)boot_alloc(sizeof(* envs) * NENV);
	memset(envs, 0, sizeof(*envs) * NENV);
  
  //////////////////////////////////////////////////////////////////////
  // Now that we've allocated the initial kernel data structures, we set
  // up the list of free physical pages. Once we've done so, all further
  // memory management will go through the page_* functions. In
  // particular, we can now map memory using boot_map_region
  // or page_insert
  page_init();

  check_page_free_list(1);
  check_page();
  check_page_alloc();

  //////////////////////////////////////////////////////////////////////
  // Now we set up virtual memory

  //////////////////////////////////////////////////////////////////////
  // Map 'pages' read-only by the user at linear address UPAGES
  // Permissions:
  //    - the new image at UPAGES -- kernel R, user R
  //      (ie. perm = PTE_U | PTE_P)
  //    - pages itself -- kernel RW, user NONE

  // LAB 7 code
  boot_map_region(kern_pml4e, UPAGES, ROUNDUP(npages * sizeof(*pages), PGSIZE), PADDR(pages), PTE_U | PTE_P);

  //////////////////////////////////////////////////////////////////////
  // Map the 'envs' array read-only by the user at linear address UENVS
  // (ie. perm = PTE_U | PTE_P).
  // Permissions:
  //    - the new image at UENVS  -- kernel R, user R
  //    - envs itself -- kernel RW, user NONE

  // LAB 8 code
  boot_map_region(kern_pml4e, UENVS, ROUNDUP(NENV * sizeof(*envs), PGSIZE), PADDR(envs), PTE_U | PTE_P);
  
  //////////////////////////////////////////////////////////////////////
  // Use the physical memory that 'bootstack' refers to as the kernel
  // stack.  The kernel stack grows down from virtual address KSTACKTOP.
  // We consider the entire range from [KSTACKTOP-PTSIZE, KSTACKTOP)
  // to be the kernel stack, but break this into two pieces:
  //     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
  //     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
  //       the kernel overflows its stack, it will fault rather than
  //       overwrite memory.  Known as a "guard page".
  //     Permissions: kernel RW, user NONE

  // LAB 7 code
  boot_map_region(kern_pml4e, KSTACKTOP - KSTKSIZE, KSTACKTOP - (KSTACKTOP - KSTKSIZE), PADDR(bootstack), PTE_W | PTE_P);

  // Additionally map stack to lower 32-bit addresses.
  boot_map_region(kern_pml4e, X86ADDR(KSTACKTOP - KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_P | PTE_W);

  //////////////////////////////////////////////////////////////////////
  // Map all of physical memory at KERNBASE.
  // Ie.  the VA range [KERNBASE, 2^32) should map to
  //      the PA range [0, 2^32 - KERNBASE)
  // We might not have 2^32 - KERNBASE bytes of physical memory, but
  // we just set up the mapping anyway.
  // Permissions: kernel RW, user NONE

  // LAB 7 code
  boot_map_region(kern_pml4e, KERNBASE, npages * PGSIZE, 0, PTE_W | PTE_P);

  // Additionally map kernel to lower 32-bit addresses. Assumes kernel should not exceed 50 mb.
  size_to_alloc = MIN(0x3200000, npages * PGSIZE);
  boot_map_region(kern_pml4e, X86ADDR(KERNBASE), size_to_alloc, 0, PTE_P | PTE_W);

  //////////////////////////////////////////////////////////////////////
  // Map the UEFI runtime virtual memory to it corresponding physical
  // address.
  //     Permissions: kernel RW, user NONE
  EFI_MEMORY_DESCRIPTOR *mmap_curr;
  uintptr_t phys_start, virt_start;

  for (mmap_curr = mmap_base; mmap_curr < mmap_end; mmap_curr = (EFI_MEMORY_DESCRIPTOR *)((uintptr_t)mmap_curr + mem_map_size)) {
    phys_start    = (uintptr_t)mmap_curr->PhysicalStart;
    virt_start    = (uintptr_t)mmap_curr->VirtualStart;
    size_to_alloc = mmap_curr->NumberOfPages * PGSIZE;
    if (mmap_curr->Attribute & EFI_MEMORY_RUNTIME) {
      boot_map_region(kern_pml4e, virt_start, size_to_alloc, phys_start, PTE_P | PTE_W);
    }
  }

  // Check that the initial page directory has been set up correctly.
  check_kern_pml4e();

  // Fix physical adresses to virtual ones before loading pml4.
  fix_lp_addresses();

  // Switch from the minimal entry page directory to the full kern_pml4e
  // page table we just created.	Our instruction pointer should be
  // somewhere between KERNBASE and KERNBASE+4MB right now, which is
  // mapped the same way by both page tables.
  //
  // If the machine reboots at this point, you've probably set up your
  // kern_pml4e wrong.
  lcr3(kern_cr3);

  // entry.S set the really important flags in cr0.
  // Here we configure the rest of the flags that we care about.
  {
    uintptr_t cr0 = rcr0();
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_MP;
    cr0 &= ~(CR0_TS | CR0_EM);
    lcr0(cr0);
  }

  //////////////////////////////////////////////////////////////////////
  // Map the frame buffer from UEFI using base address as physical address
  // and mapping only the required passed amount of memory.
  //     Permissions: kernel RW, user NONE
  LOADER_PARAMS *lp  = (LOADER_PARAMS *)uefi_lp;
  uintptr_t physaddr = lp->FrameBufferBase;
  uintptr_t size     = lp->FrameBufferSize;

  boot_map_region(kern_pml4e, FBUFFBASE, size, physaddr, PTE_P | PTE_W);

  // Some more checks, only possible after kern_pml4e is installed.
  check_page_installed_pml4();
  page_free_list_top = evaluate_page_free_list_top();

  check_page_free_list(0);
}

#ifdef SANITIZE_SHADOW_BASE
void
kasan_mem_init(void) {
  // Unpoison memory in which kernel was loaded
  platform_asan_unpoison((void *)KERNBASE, (uint64_t)(boot_alloc(0) - KERNBASE));

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
  // Hint: You may want to panic if pp->pp_ref is nonzero or
  // pp->pp_link is not NULL.
  if ((pp->pp_ref != 0) || (pp->pp_link != NULL)) {
    panic("page_free: Page cannot be freed!\n");
  }
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
  // LAB 7 code
  if (pml4e[PML4(va)] & PTE_P) {
		return pdpe_walk((pdpe_t *) KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
	}
	if (create) {
    struct PageInfo *np;
    np = page_alloc(ALLOC_ZERO);
    if (np) {
      np->pp_ref++;
      pml4e[PML4(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
      return pdpe_walk((pte_t *)KADDR(PTE_ADDR(pml4e[PML4(va)])), va, create);
    }
	}
	return NULL;
}

pte_t *
pdpe_walk(pdpe_t *pdpe, const void *va, int create) {
  // LAB 7 code
  if (pdpe[PDPE(va)] & PTE_P) {
		return pgdir_walk((pte_t *) KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
	}
	if (create) {
    struct PageInfo *np;
    np = page_alloc(ALLOC_ZERO);
    if (np) {
      np->pp_ref++;
      pdpe[PDPE(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
      return pgdir_walk((pte_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)])), va, create);
    }
	}
	return NULL;
}

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create) {
  // LAB 7 code
  if (pgdir[PDX(va)] & PTE_P) {
		return (pte_t *) KADDR(PTE_ADDR(pgdir[PDX(va)])) + PTX(va);
	}
	if (create) {
    struct PageInfo *np;
    np = page_alloc(ALLOC_ZERO);
    if (np) {
        np->pp_ref++;
        pgdir[PDX(va)] = page2pa(np) | PTE_U | PTE_P | PTE_W;
        return (pte_t *) page2kva(np) + PTX(va);
    }
	}
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
  // LAB 7 code
  size_t i;
  for (i = 0; i < size; i += PGSIZE) {
		*pml4e_walk(pml4e, (void *)(va + i), 1) = (pa + i) | perm | PTE_P;
	}
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
  // LAB 7 code
  pte_t *ptep;

	ptep = pml4e_walk(pml4e, va, 1);
	if (ptep == 0) {
		return -E_NO_MEM;
  }
	if (*ptep & PTE_P) {
		if (PTE_ADDR(*ptep) == page2pa(pp)) {
      *ptep = (*ptep & 0xfffff000) | perm | PTE_P;
    } else {
			page_remove(pml4e, va);
			*ptep = page2pa(pp) | perm | PTE_P;
			pp->pp_ref++;
			tlb_invalidate(pml4e, va);
		}
	} else {
		*ptep = page2pa(pp) | perm | PTE_P;
		pp->pp_ref++;
	}
  // LAB 7 code end
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
  // LAB 7 code
  pte_t * ptep;
    
	ptep = pml4e_walk(pml4e, va, 0);
	if (!ptep) {
		return NULL;
  }
	if (pte_store) {
		*pte_store = ptep;
  }
	return pa2page(PTE_ADDR(*ptep));
  // LAB 7 code end

  //return NULL;
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
  // LAB 7 code
  pte_t * ptep;
	struct PageInfo * pp;

	pp = page_lookup(pml4e, va, &ptep);
	if (pp) {
    page_decref(pp);
    *ptep = 0;
    tlb_invalidate(pml4e, va);
  }
  // LAB 7 code end
}

//
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pml4e_t *pml4e, void *va) {
  // Flush the entry only if we're modifying the current address space.
  if (!curenv || curenv->env_pml4e == pml4e)
    invlpg(va);
}

static uintptr_t base = MMIOBASE;

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

  // LAB 6 code
  uintptr_t pa2 = ROUNDDOWN(pa, PGSIZE);
  if (base + size >= MMIOLIM) {
    panic("Allocated MMIO addr is too high! [0x%016lu;0x%016lu]",pa, pa+size);
  }

  size = ROUNDUP(size + (pa - pa2 ), PGSIZE);
  boot_map_region(kern_pml4e, base, size, pa2, PTE_PCD | PTE_PWT | PTE_W);

  void * new = (void *) base;
  base += size;
  return new;
 // LAB 6 code end
}

void *
mmio_remap_last_region(physaddr_t pa, void *addr, size_t oldsize, size_t newsize) {

  oldsize = ROUNDUP((uintptr_t)addr + oldsize, PGSIZE) - (uintptr_t)addr;
  if (base - oldsize != (uintptr_t)addr)
    panic("You dare to remap non-last region?!");
  base = (uintptr_t)addr;
  return mmio_map_region(pa, newsize);
}

static uintptr_t user_mem_check_addr;

//
// Check that an environment is allowed to access the range of memory
// [va, va+len) with permissions 'perm | PTE_P'.
// Normally 'perm' will contain PTE_U at least, but this is not required.
// 'va' and 'len' need not be page-aligned; you must test every page that
// contains any of that range.  You will test either 'len/PGSIZE',
// 'len/PGSIZE + 1', or 'len/PGSIZE + 2' pages.
//
// A user program can access a virtual address if (1) the address is below
// ULIM, and (2) the page table gives it permission.  These are exactly
// the tests you should implement here.
//
// If there is an error, set the 'user_mem_check_addr' variable to the first
// erroneous virtual address.
//
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm) {
  // LAB 8 code

  perm = perm | PTE_P;


  const void *end = va + len;
  const void *va_b = va;
  va = (void*) ROUNDDOWN(va, PGSIZE);
  while (va < end)
  {
    pte_t *pte = pml4e_walk(env->env_pml4e, va, 0);
    if (!pte || (*pte & perm) != perm ){
      user_mem_check_addr = (uintptr_t) MAX(va,va_b);
      return -E_FAULT;
    }
    va += PGSIZE;
  }
  
  if ((uintptr_t) end > ULIM){
    user_mem_check_addr = MAX(ULIM, (uintptr_t)va_b);
    return -E_FAULT;
  }

  return 0;
}

//
// Checks that environment 'env' is allowed to access the range
// of memory [va, va+len) with permissions 'perm | PTE_U | PTE_P'.
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm) {
  int t = user_mem_check(env, va, len, perm | PTE_U | PTE_P);
  // cprintf("%d user mem check\n %d\n", t, -E_FAULT);
  if (t < 0) {
    cprintf("[%08x] user_mem_check assertion failure for va %016lx\n",
            env->env_id, (unsigned long)user_mem_check_addr);
    env_destroy(env); // may not return
  }
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

//
// Checks that the kernel part of virtual address space
// has been setup roughly correctly (by mem_init()).
//
// This function doesn't test every corner case,
// but it is a pretty good sanity check.
//

static void
check_kern_pml4e(void) {
  uint64_t i, n;
  pml4e_t *pml4e;

  pml4e = kern_pml4e;

  // check pages array
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);

  // check envs array (new test for lab 8)
  n = ROUNDUP(NENV * sizeof(struct Env), PGSIZE);
  for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pml4e, UENVS + i) == PADDR(envs) + i);

  // check phys mem
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
    assert(check_va2pa(pml4e, KERNBASE + i) == i);

  // check kernel stack
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  assert(check_va2pa(pml4e, KSTACKTOP - PTSIZE) == ~0);

  pdpe_t *pdpe = KADDR(PTE_ADDR(kern_pml4e[1]));
  pde_t *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  // check PDE permissions
  for (i = 0; i < NPDENTRIES; i++) {
    switch (i) {
      case VPD(UVPT):
      case VPD(KSTACKTOP - 1):
      case VPD(UPAGES):
      case VPD(UENVS):
        assert(pgdir[i] & PTE_P);
        break;
      default:
        if (i >= VPD(KERNBASE)) {
          if (pgdir[i] & PTE_P)
            assert(pgdir[i] & PTE_W);
          else
            assert(pgdir[i] == 0);
        }
        break;
    }
  }
  cprintf("check_kern_pml4e() succeeded!\n");
}

// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_kern_pml4e() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pml4e_t *pml4e, uintptr_t va) {
  pte_t *pte;
  pdpe_t *pdpe;
  pde_t *pde;
  // cprintf("%x", va);
  pml4e = &pml4e[PML4(va)];
  // cprintf(" %x %x " , PML4(va), *pml4e);
  if (!(*pml4e & PTE_P))
    return ~0;
  pdpe = (pdpe_t *)KADDR(PTE_ADDR(*pml4e));
  // cprintf(" %x %x " , pdpe, *pdpe);
  if (!(pdpe[PDPE(va)] & PTE_P))
    return ~0;
  pde = (pde_t *)KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  // cprintf(" %x %x " , pde, *pde);
  pde = &pde[PDX(va)];
  if (!(*pde & PTE_P))
    return ~0;
  pte = (pte_t *)KADDR(PTE_ADDR(*pde));
  // cprintf(" %x %x " , pte, *pte);
  if (!(pte[PTX(va)] & PTE_P))
    return ~0;
  // cprintf(" %x %x\n" , PTX(va),  PTE_ADDR(pte[PTX(va)]));
  return PTE_ADDR(pte[PTX(va)]);
}

// check page_insert, page_remove, &c
static void
check_page(void) {
  struct PageInfo *pp0, *pp1, *pp2, *pp3, *pp4, *pp5;
  struct PageInfo *fl;
  pte_t *ptep, *ptep1;
  pdpe_t *pdpe;
  pde_t *pde;
  pml4e_t pml4e_old; //used to store value instead of pointer
  void *va;
  int i;
  pp0 = pp1 = pp2 = pp3 = pp4 = pp5 = 0;

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  kern_pml4e[0] = 0;

  assert(pp0 = page_alloc(0));
  assert(pp1 = page_alloc(0));
  assert(pp2 = page_alloc(0));
  assert(pp3 = page_alloc(0));
  assert(pp4 = page_alloc(0));
  assert(pp5 = page_alloc(0));

  assert(pp0);
  assert(pp1 && pp1 != pp0);
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
  assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);

  // temporarily steal the rest of the free pages
  fl = page_free_list;
  assert(fl != NULL);
  page_free_list = NULL;

  // should be no free memory
  assert(!page_alloc(0));

  // there is no page allocated at address 0
  assert(page_lookup(kern_pml4e, (void *)0x0, &ptep) == NULL);

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) < 0);
  page_free(pp2);
  page_free(pp3);

  //cprintf("pp0 ref count = %d\n",pp0->pp_ref);
  //cprintf("pp2 ref count = %d\n",pp2->pp_ref);
  assert(page_insert(kern_pml4e, pp1, 0x0, 0) == 0);
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  assert(check_va2pa(kern_pml4e, 0x0) == page2pa(pp1));
  assert(pp1->pp_ref == 1);
  //should be able to map pp3 at PGSIZE because pp0 is already allocated for page table
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  assert(pp3->pp_ref == 2);

  // should be no free memory
  assert(!page_alloc(0));

  // should be able to map pp3 at PGSIZE because it's already there
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, 0) == 0);
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  assert(pp3->pp_ref == 2);

  // pp3 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
  // check that pgdir_walk returns a pointer to the pte
  pdpe = KADDR(PTE_ADDR(kern_pml4e[PML4(PGSIZE)]));
  pde  = KADDR(PTE_ADDR(pdpe[PDPE(PGSIZE)]));
  ptep = KADDR(PTE_ADDR(pde[PDX(PGSIZE)]));
  assert(pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));

  // should be able to change permissions too.
  assert(page_insert(kern_pml4e, pp3, (void *)PGSIZE, PTE_U) == 0);
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp3));
  assert(pp3->pp_ref == 2);
  assert(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U);
  assert(kern_pml4e[0] & PTE_U);

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pml4e, pp0, (void *)PTSIZE, 0) < 0);

  // insert pp1 at PGSIZE (replacing pp3)
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  assert(!(*pml4e_walk(kern_pml4e, (void *)PGSIZE, 0) & PTE_U));

  // should have pp1 at both 0 and PGSIZE
  assert(check_va2pa(kern_pml4e, 0) == page2pa(pp1));
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
  assert(pp3->pp_ref == 1);

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pml4e, 0x0);
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  assert(check_va2pa(kern_pml4e, PGSIZE) == page2pa(pp1));
  assert(pp1->pp_ref == 1);
  assert(pp3->pp_ref == 1);

  // Test re-inserting pp1 at PGSIZE.
  // Thanks to Varun Agrawal for suggesting this test case.
  assert(page_insert(kern_pml4e, pp1, (void *)PGSIZE, 0) == 0);
  assert(pp1->pp_ref);
  assert(pp1->pp_link == NULL);

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pml4e, (void *)PGSIZE);
  assert(check_va2pa(kern_pml4e, 0x0) == ~0);
  assert(check_va2pa(kern_pml4e, PGSIZE) == ~0);
  assert(pp1->pp_ref == 0);
  assert(pp3->pp_ref == 1);

#if 0
	// should be able to page_insert to change a page
	// and see the new data immediately.
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	page_insert(boot_pgdir, pp1, 0x0, 0);
	assert(pp1->pp_ref == 1);
	assert(*(int*)0 == 0x01010101);
	page_insert(boot_pgdir, pp2, 0x0, 0);
	assert(*(int*)0 == 0x02020202);
	assert(pp2->pp_ref == 1);
	assert(pp1->pp_ref == 0);
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

  // forcibly take pp3 back
  assert((PTE_ADDR(kern_pml4e[0]) == page2pa(pp0) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp2) || PTE_ADDR(kern_pml4e[0]) == page2pa(pp3)));
  kern_pml4e[0] = 0;
  assert(pp3->pp_ref == 1);
  page_decref(pp3);
  // check pointer arithmetic in pml4e_walk
  page_decref(pp0);
  page_decref(pp2);
  va    = (void *)(PGSIZE * 100);
  ptep  = pml4e_walk(kern_pml4e, va, 1);
  pdpe  = KADDR(PTE_ADDR(kern_pml4e[PML4(va)]));
  pde   = KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  ptep1 = KADDR(PTE_ADDR(pde[PDX(va)]));
  assert(ptep == ptep1 + PTX(va));

  // check that new page tables get cleared
  page_decref(pp4);
  memset(page2kva(pp4), 0xFF, PGSIZE);
  pml4e_walk(kern_pml4e, 0x0, 1);
  pdpe = KADDR(PTE_ADDR(kern_pml4e[0]));
  pde  = KADDR(PTE_ADDR(pdpe[0]));
  ptep = KADDR(PTE_ADDR(pde[0]));
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
  kern_pml4e[0] = 0;

  // give free list back
  page_free_list = fl;

  // free the pages we took
  page_decref(pp0);
  page_decref(pp1);
  page_decref(pp2);

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;

  cprintf("check_page() succeeded!\n");
}

// check page_insert, page_remove, &c, with an installed kern_pml4e
static void
check_page_installed_pml4(void) {
  struct PageInfo *pp0, *pp1, *pp2;
  pml4e_t pml4e_old; //used to store value instead of pointer

  //Save old pml4[0] entry and temporarily set it to 0.
  pml4e_old     = kern_pml4e[0];
  kern_pml4e[0] = 0;

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
  assert((pp1 = page_alloc(0)));
  assert((pp2 = page_alloc(0)));
  page_free(pp0);
  memset(page2kva(pp1), 1, PGSIZE);
  memset(page2kva(pp2), 2, PGSIZE);
  page_insert(kern_pml4e, pp1, (void *)PGSIZE, PTE_W);
  assert(pp1->pp_ref == 1);
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
  page_insert(kern_pml4e, pp2, (void *)PGSIZE, PTE_W);
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
  assert(pp2->pp_ref == 1);
  assert(pp1->pp_ref == 0);
  *(uint32_t *)PGSIZE = 0x03030303U;
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
  page_remove(kern_pml4e, (void *)PGSIZE);
  assert(pp2->pp_ref == 0);

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pml4e[0]) == page2pa(pp0));
  kern_pml4e[0] = 0;
  assert(pp0->pp_ref == 1);
  pp0->pp_ref = 0;

  // free the pages we took
  page_free(pp0);

  // resotre pml4[0]
  kern_pml4e[0] = pml4e_old;

  cprintf("check_page_installed_pml4() succeeded!\n");
}
