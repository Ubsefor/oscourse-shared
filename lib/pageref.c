#include <inc/lib.h>

int pageref(void *v) {
  pte_t pte;

  if (!(uvpml4e[PML4(v)] & PTE_P) || !(uvpde[VPDPE(v)] & PTE_P) ||
      !(uvpd[VPD(v)] & PTE_P) || !(uvpt[PGNUM(v)] & PTE_P))
    return 0;
  pte = uvpt[PGNUM(v)];
  if (!(pte & PTE_P))
    return 0;
  return pages[PPN(pte)].pp_ref;
}
