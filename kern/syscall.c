/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len) {
  // Check that the user has permission to read memory [s, s+len).
  // Destroy the environment if not.

  // LAB 8: Your code here.
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void) {
  // LAB 8: Your code here.
  return 0;
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void) {
  // LAB 8: Your code here.
  return -1;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid) {
  // LAB 8: Your code here.
  return -1;
}

// Dispatches to the correct kernel function, passing the arguments.
uintptr_t
syscall(uintptr_t syscallno, uintptr_t a1, uintptr_t a2, uintptr_t a3, uintptr_t a4, uintptr_t a5) {
  // Call the function corresponding to the 'syscallno' parameter.
  // Return any appropriate return value.
  // LAB 8: Your code here.

  return -E_INVAL;
}
