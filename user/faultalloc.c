// test user-level fault handler -- alloc pages to fix faults

#include <inc/lib.h>

void
handler(struct UTrapframe *utf) {
  int r;
  void *addr = (void *)utf->utf_fault_va;

  cprintf("fault %lx\n", (unsigned long)addr);
  if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0) {
    panic("allocating at %lx in page fault handler: %i", (unsigned long)addr, r);
  }
  snprintf((char *)addr, 100, "this string was faulted in at %lx", (unsigned long)addr);
}

void
umain(int argc, char **argv) {
  set_pgfault_handler(handler);
  cprintf("%s\n", (char *)0xBeefDead);
  cprintf("%s\n", (char *)0xCafeBffe);
}
