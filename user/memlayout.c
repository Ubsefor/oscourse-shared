#include <inc/lib.h>

#ifndef PTE_COW
#define PTE_COW 0x800
#endif // PTE_COW
#ifndef PTE_SHARE
#define PTE_SHARE 0x400
#endif // PTE_SHARE

void
memlayout(void) {
  pte_t *pg;
  uintptr_t addr;
  size_t total_p   = 0;
  size_t total_u   = 0;
  size_t total_w   = 0;
  size_t total_cow = 0;

  cprintf("EID: %d, PEID: %d\n", thisenv->env_id, thisenv->env_parent_id);
  cprintf("pml4e: %lx, uvpd: %lx, uvpt: %lx\n",
          (unsigned long)thisenv->env_pml4e,
          (unsigned long)uvpd,
          (unsigned long)uvpt);

  for (addr = 0; addr < KERNBASE; addr += PGSIZE) {
    if ((uvpml4e[PML4(addr)] & PTE_P) == 0 ||
        (uvpde[VPDPE(addr)] & PTE_P) == 0 ||
        (uvpd[VPD(addr)] & PTE_P) == 0 ||
        uvpt[VPN(addr)] == 0)
      continue;
    pg = (pte_t *)uvpt + VPN(addr);
    cprintf("[%p] %lx -> %08lx: %c %c %c |%s%s\n",
            pg, (unsigned long)addr, (unsigned long)*pg,
            (*pg & PTE_P)   ? total_p++, 'P' : '-',
            (*pg & PTE_U)   ? total_u++, 'U' : '-',
            (*pg & PTE_W)   ? total_w++, 'W' : '-',
            (*pg & PTE_COW) ? total_cow++, " COW" : "",
            (*pg & PTE_SHARE) ? " SHARE" : "");
  }

  cprintf("Memory usage summary:\n");
  cprintf("  PTE_P: %lu\n", (unsigned long)total_p);
  cprintf("  PTE_U: %lu\n", (unsigned long)total_u);
  cprintf("  PTE_W: %lu\n", (unsigned long)total_w);
  cprintf("  PTE_COW: %lu\n", (unsigned long)total_cow);
}

void
umain(int argc, char *argv[]) {
  envid_t ceid;
  int pipefd[2];
  int res;

  memlayout();

  res = pipe(pipefd);
  if (res < 0)
    panic("pipe() failed\n");
  ceid = fork();
  if (ceid < 0)
    panic("fork() failed\n");

  if (ceid == 0) {
    // Child environment
    int i;
    cprintf("\n");
    for (i = 0; i < 102400; i++)
      sys_yield();
    cprintf("==== Child\n");
    memlayout();
    return;
  }

  cprintf("==== Parent\n");
  memlayout();
}
