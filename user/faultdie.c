// test user-level fault handler -- just exit when we fault

#include <inc/lib.h>

void
handler(struct UTrapframe *utf) {
  void *addr   = (void *)utf->utf_fault_va;
  uint64_t err = utf->utf_err;
  cprintf("i faulted at va %lx, err %x\n",
          (unsigned long)addr, (unsigned)(err & 7));
  sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv) {
  set_pgfault_handler(handler);
  *(volatile int *)0xDeadBeef = 0;
}
