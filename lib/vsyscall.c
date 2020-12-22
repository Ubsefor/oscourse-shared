#include <inc/vsyscall.h>
#include <inc/lib.h>

static inline uint64_t
vsyscall(int num) {
  // LAB 12: Your code here.
  if (num == VSYS_gettime) {
    return vsys[num];
  }
  return -E_INVAL;
  // LAB 12 code end
  return 0;
}

int
vsys_gettime(void) {
  return vsyscall(VSYS_gettime);
}
