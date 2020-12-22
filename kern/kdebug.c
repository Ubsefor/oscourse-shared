#include <inc/assert.h>
#include <inc/dwarf.h>
#include <inc/elf.h>
#include <inc/memlayout.h>
#include <inc/string.h>
#include <inc/x86.h>

#include <inc/uefi.h>
#include <kern/env.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

void load_kernel_dwarf_info(struct Dwarf_Addrs *addrs) {
  addrs->aranges_begin = (unsigned char *)(uefi_lp->DebugArangesStart);
  addrs->aranges_end = (unsigned char *)(uefi_lp->DebugArangesEnd);
  addrs->abbrev_begin = (unsigned char *)(uefi_lp->DebugAbbrevStart);
  addrs->abbrev_end = (unsigned char *)(uefi_lp->DebugAbbrevEnd);
  addrs->info_begin = (unsigned char *)(uefi_lp->DebugInfoStart);
  addrs->info_end = (unsigned char *)(uefi_lp->DebugInfoEnd);
  addrs->line_begin = (unsigned char *)(uefi_lp->DebugLineStart);
  addrs->line_end = (unsigned char *)(uefi_lp->DebugLineEnd);
  addrs->str_begin = (unsigned char *)(uefi_lp->DebugStrStart);
  addrs->str_end = (unsigned char *)(uefi_lp->DebugStrEnd);
  addrs->pubnames_begin = (unsigned char *)(uefi_lp->DebugPubnamesStart);
  addrs->pubnames_end = (unsigned char *)(uefi_lp->DebugPubnamesEnd);
  addrs->pubtypes_begin = (unsigned char *)(uefi_lp->DebugPubtypesStart);
  addrs->pubtypes_end = (unsigned char *)(uefi_lp->DebugPubtypesEnd);
}

// debuginfo_rip(addr, info)
//
//	Fill in the 'info' structure with information about the specified
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info) {
  int code = 0;

  // LAB 8 code
  // const struct Stab *stabs, *stab_end;
  // const char *stabstr, *stabstr_end;
  // LAB 8 code end

  // Initialize *info
  strcpy(info->rip_file, "<unknown>");
  info->rip_line = 0;
  strcpy(info->rip_fn_name, "<unknown>");
  info->rip_fn_namelen = 9;
  info->rip_fn_addr = addr;
  info->rip_fn_narg = 0;

  if (!addr) {
    return 0;
  }

  // Temporarily load kernel cr3 and return back once done.
  // Make sure that you fully understand why it is necessary.
  // LAB 8: Your code here.

  struct Dwarf_Addrs addrs;
  // LAB 8 code
  uint64_t tmp_cr3 = rcr3();
  lcr3(PADDR(kern_pml4e));
  // LAB 8 code end
  if (addr <= ULIM) {

    // LAB 8 code
    // uint64_t tmp_cr3 = rcr3();
    // lcr3(PADDR(kern_pml4e));
    // load_kernel_dwarf_info(&addrs);
    // lcr3(tmp_cr3);
    // LAB 8 code end

    panic("Can't search for user-level addresses yet!");
  } else {
    load_kernel_dwarf_info(&addrs);
  }
  enum {
    BUFSIZE = 20,
  };
  Dwarf_Off offset = 0, line_offset = 0;
  code = info_by_address(&addrs, addr, &offset);
  if (code < 0) {
    // LAB 8 code
    lcr3(tmp_cr3);
    // LAB 8 code end
    return code;
  }
  char *tmp_buf;
  void *buf;
  buf = &tmp_buf;
  code = file_name_by_info(&addrs, offset, buf, sizeof(char *), &line_offset);
  strncpy(info->rip_file, tmp_buf, 256);
  if (code < 0) {
    // LAB 8 code
    lcr3(tmp_cr3);
    // LAB 8 code end
    return code;
  }

  // LAB 2 code

  // Find line number corresponding to given address.
  // Hint: note that we need the address of `call` instruction, but rip holds
  // address of the next instruction, so we should substract 5 from it.
  // Hint: use line_for_address from kern/dwarf_lines.c

  int lineno_store;
  addr = addr - 5;
  code = line_for_address(&addrs, addr, line_offset, &lineno_store);
  info->rip_line = lineno_store;
  if (code < 0) {
    // LAB 8 code
    lcr3(tmp_cr3);
    // LAB 8 code end
    return code;
  }

  // LAB 2 code end

  buf = &tmp_buf;
  code = function_by_info(&addrs, addr, offset, buf, sizeof(char *),
                          &info->rip_fn_addr);
  strncpy(info->rip_fn_name, tmp_buf, 256);
  info->rip_fn_namelen = strnlen(info->rip_fn_name, 256);
  if (code < 0) {
    // LAB 8 code
    lcr3(tmp_cr3);
    // LAB 8 code end
    return code;
  }
  // LAB 8 code
  lcr3(tmp_cr3);
  // LAB 8 code end
  return 0;
}

uintptr_t find_function(const char *const fname) {
// There are two functions for function name lookup.
// address_by_fname, which looks for function name in section .debug_pubnames
// and naive_address_by_fname which performs full traversal of DIE tree.

// LAB 3 code

// LAB 6 code
#ifdef CONFIG_KSPACE
  // LAB 6 code end
  struct {
    const char *name;
    uintptr_t addr;
  } scentry[] = {
      {"sys_yield", (uintptr_t)sys_yield},
      {"sys_exit", (uintptr_t)sys_exit},
  };

  for (size_t i = 0; i < sizeof(scentry) / sizeof(*scentry); i++) {
    if (!strcmp(scentry[i].name, fname)) {
      return scentry[i].addr;
    }
  }
// LAB 6 code
#endif
  // LAB 6 code end

  struct Dwarf_Addrs addrs;
  load_kernel_dwarf_info(&addrs);
  uintptr_t offset = 0;

  if (!address_by_fname(&addrs, fname, &offset) && offset) {
    return offset;
  }

  if (!naive_address_by_fname(&addrs, fname, &offset)) {
    return offset;
  }
  // LAB 3 code end

  return 0;
}
