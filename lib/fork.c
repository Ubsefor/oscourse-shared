// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW 0x800

extern void _pgfault_upcall(void);

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
#ifdef SANITIZE_USER_SHADOW_BASE
void *__nosan_memcpy(void *dst, const void *src, size_t sz);
#endif
static void
pgfault(struct UTrapframe *utf) {
  // Check that the faulting access was (1) a write, and (2) to a
  // copy-on-write page.  If not, panic.
  // Hint:
  //   Use the read-only page table mappings at uvpt
  //   (see <inc/memlayout.h>).

  // LAB 9 code
  void *addr   = (void *)utf->utf_fault_va;
  uint64_t err = utf->utf_err;
  int r;

  if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & (PTE_COW)))) {
    panic("Not a WR or not a COW page! va: %lx err: %lx\n", (uint64_t)addr, err);
  }

  // Allocate a new page, map it at a temporary location (PFTEMP),
  // copy the data from the old page to the new page, then move the new
  // page to the old page's address.
  // Hint:
  //   You should make three system calls.
  //   No need to explicitly delete the old page's mapping.
  //   Make sure you DO NOT use sanitized memcpy/memset routines when using UASAN.

  // LAB 9 code
  if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_W)) < 0) {
    panic("pgfault error: sys_page_alloc: %i\n", r);
  }

#ifdef SANITIZE_USER_SHADOW_BASE
  __nosan_memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#else
  memmove((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
#endif

  if ((r = sys_page_map(0, (void *)PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W)) < 0) {
    panic("pgfault error: sys_page_map: %i\n", r);
  }

  if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0) {
    panic("pgfault error: sys_page_unmap: %i\n", r);
  }
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, uintptr_t pn) {

  // LAB 9 code
  pte_t ent = uvpt[pn] & PTE_SYSCALL;
  int r;
  envid_t id = sys_getenvid();

  if (uvpt[pn] & PTE_SHARE) {
    if ((r = sys_page_map(0, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent)) < 0) {
      panic("duppage error: sys_page_map PTE_SHARE: %i\n", r);
    }

  } else if (ent & (PTE_W | PTE_COW)) {
    ent = (ent | PTE_COW) & ~PTE_W;
    r   = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);

    if (r < 0) {
      return r;
    }
    r = sys_page_map(id, (void *)(pn * PGSIZE), id, (void *)(pn * PGSIZE), ent);
  } else {
    r = sys_page_map(id, (void *)(pn * PGSIZE), envid, (void *)(pn * PGSIZE), ent);
  }
  return r;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void) {
  // Duplicating shadow addresses is insane. Make sure to skip shadow addresses in COW above.

  // LAB 9 code
  envid_t e;
  int r;

  set_pgfault_handler(pgfault);

  if ((e = sys_exofork()) < 0) {
    panic("fork error: %i\n", (int)e);
  }

  if (!e) {
    thisenv = &envs[ENVX(sys_getenvid())];
    return 0;
  } else {
    uint64_t i;
    for (i = 0; i < UTOP / PGSIZE; i++) {
      if ((uvpml4e[VPML4E(i * PGSIZE)] & PTE_P) && (uvpde[VPDPE(i * PGSIZE)] & PTE_P) && (uvpd[VPD(i * PGSIZE)] & PTE_P)) {
        void *addr = (void *)(i * PGSIZE);

#ifdef SANITIZE_USER_SHADOW_BASE
        uintptr_t p = (uintptr_t)addr;
        if ((p >= SANITIZE_USER_SHADOW_BASE) && (p < SANITIZE_USER_SHADOW_BASE + SANITIZE_USER_SHADOW_SIZE)) {
          continue;
        }
        if ((p >= SANITIZE_USER_EXTRA_SHADOW_BASE) && (p < SANITIZE_USER_EXTRA_SHADOW_BASE + SANITIZE_USER_EXTRA_SHADOW_SIZE)) {
          continue;
        }
        if ((p >= SANITIZE_USER_STACK_SHADOW_BASE) && (p < SANITIZE_USER_STACK_SHADOW_BASE + SANITIZE_USER_STACK_SHADOW_SIZE)) {
          continue;
        }
        if ((p >= SANITIZE_USER_VPT_SHADOW_BASE) && (p < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE)) {
          continue;
        }
#endif

        if (((uintptr_t)addr < UTOP) && ((uintptr_t)addr != UXSTACKTOP - PGSIZE) && (uvpt[PGNUM(addr)] & PTE_P)) {
          if ((r = duppage(e, PGNUM(addr))) < 0) {
            return r;
          }
        }
      }
    }
    if ((r = sys_env_set_pgfault_upcall(e, thisenv->env_pgfault_upcall)) < 0) {
      panic("fork error: sys_env_set_pgfault_upcall: %i\n", r);
    }
    if ((r = sys_page_alloc(e, (void *)UXSTACKTOP - PGSIZE, PTE_W)) < 0) {
      panic("fork error: sys_page_alloc: %i\n", r);
    }

#ifdef SANITIZE_USER_SHADOW_BASE
    uintptr_t addr;
    for (addr = SANITIZE_USER_SHADOW_BASE; addr < SANITIZE_USER_SHADOW_BASE + SANITIZE_USER_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *)addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow base page: %i\n", r);
    for (addr = SANITIZE_USER_EXTRA_SHADOW_BASE; addr < SANITIZE_USER_EXTRA_SHADOW_BASE + SANITIZE_USER_EXTRA_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *)addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow extra base page: %i\n", r);
    for (addr = SANITIZE_USER_STACK_SHADOW_BASE; addr < SANITIZE_USER_STACK_SHADOW_BASE + SANITIZE_USER_STACK_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *)addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow stack base page: %i\n", r);
    for (addr = SANITIZE_USER_VPT_SHADOW_BASE; addr < SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE; addr += PGSIZE)
      if ((r = sys_page_alloc(e, (void *)addr, PTE_P | PTE_U | PTE_W)) < 0)
        panic("Fork: failed to alloc shadow vpt base page: %i\n", r);
#endif
    if ((r = sys_env_set_status(e, ENV_RUNNABLE)) < 0) {
      panic("fork error: sys_env_set_status: %i\n", r);
    }
    return e;
  }
}

// Challenge!
int
sfork(void) {
  panic("sfork not implemented");
  return -E_INVAL;
}
