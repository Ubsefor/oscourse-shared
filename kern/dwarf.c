#include <inc/assert.h>
#include <inc/error.h>
#include <inc/dwarf.h>
#include <inc/string.h>
#include <inc/types.h>
#include <inc/stdio.h>

struct Slice {
  const void *mem;
  int len;
};

static int
info_by_address_debug_aranges(const struct Dwarf_Addrs *addrs,
                              uintptr_t p, Dwarf_Off *store) {
  const void *set = addrs->aranges_begin;
  while ((unsigned char *)set < addrs->aranges_end) {
    int count = 0;
    unsigned long len;
    const void *header = set;
    count              = dwarf_entry_len(set, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    } else {
      set += count;
    }
    const void *set_end = set + len;

    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(set, Dwarf_Half);
    set += sizeof(Dwarf_Half);
    assert(version == 2);
    Dwarf_Off offset = get_unaligned(set, uint32_t);
    set += count;
    Dwarf_Small address_size = get_unaligned(set++, Dwarf_Small);
    assert(address_size == 8);
    Dwarf_Small segment_size = get_unaligned(set++, Dwarf_Small);
    assert(segment_size == 0);

    void *addr          = NULL;
    uint32_t entry_size = 2 * address_size + segment_size;
    uint32_t remainder  = (set - header) % entry_size;
    if (remainder) {
      set += 2 * address_size - remainder;
    }
    Dwarf_Off size = 0;
    do {
      addr = (void *)get_unaligned(set, uintptr_t);
      set += address_size;
      size = get_unaligned(set, uint32_t);
      set += address_size;
      if ((uintptr_t)addr <= p &&
          p <= (uintptr_t)addr + size) {
        *store = offset;
        return 0;
      }
    } while (set < set_end);
    assert(set == set_end);
  }
  return -E_BAD_DWARF;
}

// Read value from .debug_abbrev table in buf. Returns number of bytes read.
static int
dwarf_read_abbrev_entry(const void *entry, unsigned form, void *buf,
                        int bufsize, unsigned address_size) {
  int bytes = 0;
  switch (form) {
    case DW_FORM_addr:
      if (buf && bufsize >= sizeof(uintptr_t)) {
        memcpy(buf, entry, sizeof(uintptr_t));
      }
      entry += address_size;
      bytes = address_size;
      break;
    case DW_FORM_block2: {
      // Read block of 2-byte length followed by 0 to 65535 contiguous information bytes
      // LAB 2: Your code here:
      Dwarf_Half length = get_unaligned(entry, Dwarf_Half);
      entry += sizeof(Dwarf_Half);
      struct Slice slice = {
          .mem = entry,
          .len = length,
      };
      if (buf) {
        memcpy(buf, &slice, sizeof(struct Slice));
      }
      entry += length;
      bytes = sizeof(Dwarf_Half) + length;
    } break;
    case DW_FORM_block4: {
      unsigned length = get_unaligned(entry, uint32_t);
      entry += sizeof(uint32_t);
      struct Slice slice = {
          .mem = entry,
          .len = length,
      };
      if (buf) {
        memcpy(buf, &slice, sizeof(struct Slice));
      }
      entry += length;
      bytes = sizeof(uint32_t) + length;
    } break;
    case DW_FORM_data2: {
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
      entry += sizeof(Dwarf_Half);
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
        put_unaligned(data, (Dwarf_Half *)buf);
      }
      bytes = sizeof(Dwarf_Half);
    } break;
    case DW_FORM_data4: {
      uint32_t data = get_unaligned(entry, uint32_t);
      entry += sizeof(uint32_t);
      if (buf && bufsize >= sizeof(uint32_t)) {
        put_unaligned(data, (uint32_t *)buf);
      }
      bytes = sizeof(uint32_t);
    } break;
    case DW_FORM_data8: {
      uint64_t data = get_unaligned(entry, uint64_t);
      entry += sizeof(uint64_t);
      if (buf && bufsize >= sizeof(uint64_t)) {
        put_unaligned(data, (uint64_t *)buf);
      }
      bytes = sizeof(uint64_t);
    } break;
    case DW_FORM_string: {
      if (buf && bufsize >= sizeof(char *)) {
        memcpy(buf, &entry, sizeof(char *));
      }
      bytes = strlen(entry) + 1;
    } break;
    case DW_FORM_block: {
      unsigned length     = 0;
      unsigned long count = dwarf_read_uleb128(entry, &length);
      entry += count;
      struct Slice slice = {
          .mem = entry,
          .len = length,
      };
      if (buf) {
        memcpy(buf, &slice, sizeof(struct Slice));
      }
      entry += length;
      bytes = count + length;
    } break;
    case DW_FORM_block1: {
      unsigned length = get_unaligned(entry, Dwarf_Small);
      entry += sizeof(Dwarf_Small);
      struct Slice slice = {
          .mem = entry,
          .len = length,
      };
      if (buf) {
        memcpy(buf, &slice, sizeof(struct Slice));
      }
      entry += length;
      bytes = length + sizeof(Dwarf_Small);
    } break;
    case DW_FORM_data1: {
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
      entry += sizeof(Dwarf_Small);
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
        put_unaligned(data, (Dwarf_Small *)buf);
      }
      bytes = sizeof(Dwarf_Small);
    } break;
    case DW_FORM_flag: {
      bool data = get_unaligned(entry, Dwarf_Small);
      entry += sizeof(Dwarf_Small);
      if (buf && bufsize >= sizeof(bool)) {
        put_unaligned(data, (bool *)buf);
      }
      bytes = sizeof(Dwarf_Small);
    } break;
    case DW_FORM_sdata: {
      int data  = 0;
      int count = dwarf_read_leb128(entry, &data);
      entry += count;
      if (buf && bufsize >= sizeof(int)) {
        put_unaligned(data, (int *)buf);
      }
      bytes = count;
    } break;
    case DW_FORM_strp: {
      unsigned long length = 0;
      int count            = dwarf_entry_len(entry, &length);
      entry += count;
      if (buf && bufsize >= sizeof(unsigned long)) {
        put_unaligned(length, (unsigned long *)buf);
      }
      bytes = count;
    } break;
    case DW_FORM_udata: {
      unsigned int data = 0;
      int count         = dwarf_read_uleb128(entry, &data);
      entry += count;
      if (buf && bufsize >= sizeof(unsigned int)) {
        put_unaligned(data, (unsigned int *)buf);
      }
      bytes = count;
    } break;
    case DW_FORM_ref_addr: {
      unsigned long length = 0;
      int count            = dwarf_entry_len(entry, &length);
      entry += count;
      if (buf && bufsize >= sizeof(unsigned long)) {
        put_unaligned(length, (unsigned long *)buf);
      }
      bytes = count;
    } break;
    case DW_FORM_ref1: {
      Dwarf_Small data = get_unaligned(entry, Dwarf_Small);
      entry += sizeof(Dwarf_Small);
      if (buf && bufsize >= sizeof(Dwarf_Small)) {
        put_unaligned(data, (Dwarf_Small *)buf);
      }
      bytes = sizeof(Dwarf_Small);
    } break;
    case DW_FORM_ref2: {
      Dwarf_Half data = get_unaligned(entry, Dwarf_Half);
      entry += sizeof(Dwarf_Half);
      if (buf && bufsize >= sizeof(Dwarf_Half)) {
        put_unaligned(data, (Dwarf_Half *)buf);
      }
      bytes = sizeof(Dwarf_Half);
    } break;
    case DW_FORM_ref4: {
      uint32_t data = get_unaligned(entry, uint32_t);
      entry += sizeof(uint32_t);
      if (buf && bufsize >= sizeof(uint32_t)) {
        put_unaligned(data, (uint32_t *)buf);
      }
      bytes = sizeof(uint32_t);
    } break;
    case DW_FORM_ref8: {
      uint64_t data = get_unaligned(entry, uint64_t);
      entry += sizeof(uint64_t);
      if (buf && bufsize >= sizeof(uint64_t)) {
        put_unaligned(data, (uint64_t *)buf);
      }
      bytes = sizeof(uint64_t);
    } break;
    case DW_FORM_ref_udata: {
      unsigned int data = 0;
      int count         = dwarf_read_uleb128(entry, &data);
      entry += count;
      if (buf && bufsize >= sizeof(unsigned int)) {
        put_unaligned(data, (unsigned int *)buf);
      }
      bytes = count;
    } break;
    case DW_FORM_indirect: {
      unsigned int form = 0;
      int count         = dwarf_read_uleb128(entry, &form);
      entry += count;
      int read = dwarf_read_abbrev_entry(entry, form, buf, bufsize,
                                         address_size);
      bytes    = count + read;
    } break;
    case DW_FORM_sec_offset: {
      unsigned long length = 0;
      int count            = dwarf_entry_len(entry, &length);
      entry += count;
      if (buf && bufsize >= sizeof(unsigned long)) {
        put_unaligned(length, (unsigned long *)buf);
      }
      bytes = count;
    } break;
    case DW_FORM_exprloc: {
      unsigned length     = 0;
      unsigned long count = dwarf_read_uleb128(entry, &length);
      entry += count;
      if (buf) {
        memcpy(buf, entry, MIN(length, bufsize));
      }
      entry += length;
      bytes = count + length;
    } break;
    case DW_FORM_flag_present:
      if (buf && sizeof(buf) >= sizeof(bool)) {
        put_unaligned(true, (bool *)buf);
      }
      bytes = 0;
      break;
    case DW_FORM_ref_sig8: {
      uint64_t data = get_unaligned(entry, uint64_t);
      entry += sizeof(uint64_t);
      if (buf && bufsize >= sizeof(uint64_t)) {
        put_unaligned(data, (uint64_t *)buf);
      }
      bytes = sizeof(uint64_t);
    } break;
  }
  return bytes;
}

// Find a compilation unit, which contains given address from .debug_info
// section.
static int
info_by_address_debug_info(const struct Dwarf_Addrs *addrs,
                           uintptr_t p, Dwarf_Off *store) {
  const void *entry = addrs->info_begin;
  while ((unsigned char *)entry < addrs->info_end) {
    int count = 0;
    unsigned long len;
    const void *header = entry;
    count              = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    } else {
      entry += count;
    }
    const void *entry_end = entry + len;

    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
    entry += sizeof(Dwarf_Half);
    assert(version == 4 || version == 2);
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
    entry += count;
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
    assert(address_size == 8);

    // Read abbreviation code
    unsigned abbrev_code = 0;
    count                = dwarf_read_uleb128(entry, &abbrev_code);
    assert(abbrev_code != 0);
    entry += count;

    // Read abbreviations table
    const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
    unsigned table_abbrev_code = 0;
    count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
    abbrev_entry += count;
    assert(table_abbrev_code == abbrev_code);
    unsigned tag = 0;
    count        = dwarf_read_uleb128(abbrev_entry, &tag);
    abbrev_entry += count;
    assert(tag == DW_TAG_compile_unit);
    abbrev_entry++;
    unsigned name = 0, form = 0;
    uintptr_t low_pc = 0, high_pc = 0;
    do {
      count = dwarf_read_uleb128(abbrev_entry, &name);
      abbrev_entry += count;
      count = dwarf_read_uleb128(abbrev_entry, &form);
      abbrev_entry += count;
      if (name == DW_AT_low_pc) {
        count = dwarf_read_abbrev_entry(
            entry, form, &low_pc, sizeof(low_pc),
            address_size);
      } else if (name == DW_AT_high_pc) {
        count = dwarf_read_abbrev_entry(
            entry, form, &high_pc, sizeof(high_pc),
            address_size);
        if (form != DW_FORM_addr) {
          high_pc += low_pc;
        }
      } else {
        count = dwarf_read_abbrev_entry(
            entry, form, NULL, 0, address_size);
      }
      entry += count;
    } while (name != 0 || form != 0);

    if (p >= low_pc && p <= high_pc) {
      *store =
          (const unsigned char *)header - addrs->info_begin;
      return 0;
    }

    entry = entry_end;
  }
  return 0;
}

int
info_by_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                Dwarf_Off *store) {
  int code = info_by_address_debug_aranges(addrs, p, store);
  if (code < 0) {
    code = info_by_address_debug_info(addrs, p, store);
  }
  return code;
}

int
file_name_by_info(const struct Dwarf_Addrs *addrs, Dwarf_Off offset,
                  char *buf, int buflen, Dwarf_Off *line_off) {
  if (offset > addrs->info_end - addrs->info_begin) {
    return -E_INVAL;
  }
  const void *entry = addrs->info_begin + offset;
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    entry += count;
  }

  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);

  // Read abbreviation code
  unsigned abbrev_code = 0;
  count                = dwarf_read_uleb128(entry, &abbrev_code);
  assert(abbrev_code != 0);
  entry += count;

  // Read abbreviations table
  const void *abbrev_entry   = addrs->abbrev_begin + abbrev_offset;
  unsigned table_abbrev_code = 0;
  count                      = dwarf_read_uleb128(abbrev_entry, &table_abbrev_code);
  abbrev_entry += count;
  assert(table_abbrev_code == abbrev_code);
  unsigned tag = 0;
  count        = dwarf_read_uleb128(abbrev_entry, &tag);
  abbrev_entry += count;
  assert(tag == DW_TAG_compile_unit);
  abbrev_entry++;
  unsigned name = 0, form = 0;
  do {
    count = dwarf_read_uleb128(abbrev_entry, &name);
    abbrev_entry += count;
    count = dwarf_read_uleb128(abbrev_entry, &form);
    abbrev_entry += count;
    if (name == DW_AT_name) {
      if (form == DW_FORM_strp) {
        unsigned long offset = 0;
        count                = dwarf_read_abbrev_entry(
            entry, form, &offset, sizeof(unsigned long),
            address_size);
        if (buf && buflen >= sizeof(const char **)) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpointer-to-int-cast"
          put_unaligned(
              (const char *)addrs->str_begin +
                  offset,
              (char **)buf);
#pragma GCC diagnostic pop
        }
      } else {
        count = dwarf_read_abbrev_entry(
            entry, form, buf, buflen, address_size);
      }
    } else if (name == DW_AT_stmt_list) {
      count = dwarf_read_abbrev_entry(entry, form, line_off,
                                      sizeof(Dwarf_Off),
                                      address_size);
    } else {
      count = dwarf_read_abbrev_entry(entry, form, NULL, 0,
                                      address_size);
    }
    entry += count;
  } while (name != 0 || form != 0);

  return 0;
}

int
function_by_info(const struct Dwarf_Addrs *addrs, uintptr_t p,
                 Dwarf_Off cu_offset, char *buf, int buflen,
                 uintptr_t *offset) {
  const void *entry = addrs->info_begin + cu_offset;
  int count         = 0;
  unsigned long len = 0;
  count             = dwarf_entry_len(entry, &len);
  if (count == 0) {
    return -E_BAD_DWARF;
  }
  entry += count;
  const void *entry_end = entry + len;
  // Parse compilation unit header.
  Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
  entry += sizeof(Dwarf_Half);
  assert(version == 4 || version == 2);
  Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
  entry += count;
  Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
  assert(address_size == 8);

  // Parse abbrev and info sections
  unsigned abbrev_code          = 0;
  unsigned table_abbrev_code    = 0;
  const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
  const void *curr_abbrev_entry = abbrev_entry;
  while (entry < entry_end) {
    // Read info abbreviation code
    count = dwarf_read_uleb128(entry, &abbrev_code);
    entry += count;
    if (abbrev_code == 0) {
      continue;
    }
    // Find abbreviation in abbrev section
    curr_abbrev_entry = abbrev_entry;
    unsigned name = 0, form = 0, tag = 0;
    while ((const unsigned char *)curr_abbrev_entry <
           addrs->abbrev_end) { // unsafe needs to be replaced
      count = dwarf_read_uleb128(curr_abbrev_entry,
                                 &table_abbrev_code);
      curr_abbrev_entry += count;
      count = dwarf_read_uleb128(curr_abbrev_entry, &tag);
      curr_abbrev_entry += count;
      curr_abbrev_entry++;
      if (table_abbrev_code == abbrev_code) {
        break;
      }
      // skip attributes
      do {
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &name);
        curr_abbrev_entry += count;
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &form);
        curr_abbrev_entry += count;
      } while (name != 0 || form != 0);
    }
    // parse subprogram DIE
    if (tag == DW_TAG_subprogram) {
      uintptr_t low_pc = 0, high_pc = 0;
      const void *fn_name_entry = 0;
      unsigned name_form        = 0;
      do {
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &name);
        curr_abbrev_entry += count;
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &form);
        curr_abbrev_entry += count;
        if (name == DW_AT_low_pc) {
          count = dwarf_read_abbrev_entry(
              entry, form, &low_pc,
              sizeof(low_pc), address_size);
        } else if (name == DW_AT_high_pc) {
          count = dwarf_read_abbrev_entry(
              entry, form, &high_pc,
              sizeof(high_pc), address_size);
          if (form != DW_FORM_addr) {
            high_pc += low_pc;
          }
        } else {
          if (name == DW_AT_name) {
            fn_name_entry = entry;
            name_form     = form;
          }
          count = dwarf_read_abbrev_entry(
              entry, form, NULL, 0, address_size);
        }
        entry += count;
      } while (name != 0 || form != 0);
      // load info and finish if addr in function
      if (p >= low_pc && p <= high_pc) {
        *offset = low_pc;
        if (name_form == DW_FORM_strp) {
          unsigned long str_offset = 0;
          count                    = dwarf_read_abbrev_entry(
              fn_name_entry, name_form,
              &str_offset, sizeof(unsigned long),
              address_size);
          if (buf &&
              buflen >= sizeof(const char **)) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpointer-to-int-cast"
            put_unaligned(
                (const char *)
                        addrs->str_begin +
                    str_offset,
                (char **)buf);
#pragma GCC diagnostic pop
          }
        } else {
          count = dwarf_read_abbrev_entry(
              fn_name_entry, name_form, buf,
              buflen, address_size);
        }
        return 0;
      }
    } else {
      // skip if not a subprogram
      do {
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &name);
        curr_abbrev_entry += count;
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &form);
        curr_abbrev_entry += count;
        count = dwarf_read_abbrev_entry(
            entry, form, NULL, 0, address_size);
        entry += count;
      } while (name != 0 || form != 0);
    }
  }
  return 0;
}

int
address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                 uintptr_t *offset) {
  const int flen = strlen(fname);
  if (flen == 0)
    return 0;
  const void *pubnames_entry = addrs->pubnames_begin;
  int count                  = 0;
  unsigned long len          = 0;
  Dwarf_Off cu_offset        = 0;
  Dwarf_Off func_offset      = 0;
  // parse pubnames section
  while ((const unsigned char *)pubnames_entry < addrs->pubnames_end) {
    count = dwarf_entry_len(pubnames_entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    pubnames_entry += count;
    const void *pubnames_entry_end = pubnames_entry + len;
    Dwarf_Half version             = get_unaligned(pubnames_entry, Dwarf_Half);
    pubnames_entry += sizeof(Dwarf_Half);
    assert(version == 2);
    cu_offset = get_unaligned(pubnames_entry, uint32_t);
    pubnames_entry += sizeof(uint32_t);
    count = dwarf_entry_len(pubnames_entry, &len);
    pubnames_entry += count;
    while (pubnames_entry < pubnames_entry_end) {
      func_offset = get_unaligned(pubnames_entry, uint32_t);
      pubnames_entry += sizeof(uint32_t);
      if (func_offset == 0) {
        break;
      }
      if (!strcmp(fname, pubnames_entry)) {
        // parse compilation unit header
        const void *entry      = addrs->info_begin + cu_offset;
        const void *func_entry = entry + func_offset;
        count                  = dwarf_entry_len(entry, &len);
        if (count == 0) {
          return -E_BAD_DWARF;
        }
        entry += count;
        Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
        entry += sizeof(Dwarf_Half);
        assert(version == 4 || version == 2);
        Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
        entry += sizeof(uint32_t);
        const void *abbrev_entry = addrs->abbrev_begin + abbrev_offset;
        Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
        assert(address_size == 8);
        entry                      = func_entry;
        unsigned abbrev_code       = 0;
        unsigned table_abbrev_code = 0;
        count                      = dwarf_read_uleb128(entry, &abbrev_code);
        entry += count;
        unsigned name = 0, form = 0, tag = 0;
        // find abbreviation in abbrev section
        while ((const unsigned char *)abbrev_entry < addrs->abbrev_end) { // unsafe needs
                                                                          // to be replaced
          count = dwarf_read_uleb128(
              abbrev_entry, &table_abbrev_code);
          abbrev_entry += count;
          count = dwarf_read_uleb128(
              abbrev_entry, &tag);
          abbrev_entry += count;
          abbrev_entry++;
          if (table_abbrev_code == abbrev_code) {
            break;
          }
          // skip attributes
          do {
            count = dwarf_read_uleb128(
                abbrev_entry, &name);
            abbrev_entry += count;
            count = dwarf_read_uleb128(
                abbrev_entry, &form);
            abbrev_entry += count;
          } while (name != 0 || form != 0);
        }
        // find low_pc
        if (tag == DW_TAG_subprogram) {
          // At this point entry points to the beginning of function's DIE attributes
          // and abbrev_entry points to abbreviation table entry corresponding to this DIE.
          // Abbreviation table entry consists of pairs of unsigned LEB128 numbers, the first
          // encodes name of attribute and the second encodes its form. Attribute entry ends
          // with a pair where both name and form equal zero.
          // Address of a function is encoded in attribute with name DW_AT_low_pc.
          // To find it, we need to scan both abbreviation table and attribute values.
          // You can read unsigned LEB128 number using dwarf_read_uleb128 function.
          // Attribute value can be obtained using dwarf_read_abbrev_entry function.
          // LAB 3: Your code here:

          uintptr_t low_pc = 0;
          do {
            count = dwarf_read_uleb128( abbrev_entry, &name );
            abbrev_entry += count;
            count = dwarf_read_uleb128( abbrev_entry, &form );
            abbrev_entry = abbrev_entry + count;
            if ( name == DW_AT_low_pc ) {
              count = dwarf_read_abbrev_entry( entry, form, &low_pc, sizeof(low_pc), address_size );
            } else {
              count = dwarf_read_abbrev_entry( entry, form, NULL, 0, address_size );
            }
            entry += count;
          } while ( name || form );
          *offset = low_pc;
        } else {
          // skip if not a subprogram or label
          do {
            count = dwarf_read_uleb128( abbrev_entry, &name );
            abbrev_entry += count;
            count = dwarf_read_uleb128( abbrev_entry, &form );
            abbrev_entry += count;
            count = dwarf_read_abbrev_entry( entry, form, NULL, 0, address_size );
            entry += count;
          } while ( name != 0 || form != 0 );
        }
        return 0;
      }
      pubnames_entry += strlen( pubnames_entry ) + 1;
    }
  }
  return 0;
}

int
naive_address_by_fname(const struct Dwarf_Addrs *addrs, const char *fname,
                       uintptr_t *offset) {
  const int flen = strlen(fname);
  if (flen == 0)
    return 0;
  const void *entry = addrs->info_begin;
  int count         = 0;
  while ((const unsigned char *)entry < addrs->info_end) {
    unsigned long len = 0;
    count             = dwarf_entry_len(entry, &len);
    if (count == 0) {
      return -E_BAD_DWARF;
    }
    entry += count;
    const void *entry_end = entry + len;
    // Parse compilation unit header.
    Dwarf_Half version = get_unaligned(entry, Dwarf_Half);
    entry += sizeof(Dwarf_Half);
    assert(version == 4 || version == 2);
    Dwarf_Off abbrev_offset = get_unaligned(entry, uint32_t);
    entry += count;
    Dwarf_Small address_size = get_unaligned(entry++, Dwarf_Small);
    assert(address_size == 8);
    // Parse related DIE's
    unsigned abbrev_code          = 0;
    unsigned table_abbrev_code    = 0;
    const void *abbrev_entry      = addrs->abbrev_begin + abbrev_offset;
    const void *curr_abbrev_entry = abbrev_entry;
    while (entry < entry_end) {
      // Read info abbreviation code
      count = dwarf_read_uleb128(entry, &abbrev_code);
      entry += count;
      if (abbrev_code == 0) {
        continue;
      }
      // Find abbreviation in abbrev section
      curr_abbrev_entry = abbrev_entry;
      unsigned name = 0, form = 0, tag = 0;
      while ((const unsigned char *)curr_abbrev_entry < addrs->abbrev_end) { // unsafe needs to be
                                                                             // replaced
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &table_abbrev_code);
        curr_abbrev_entry += count;
        count = dwarf_read_uleb128(curr_abbrev_entry,
                                   &tag);
        curr_abbrev_entry += count;
        curr_abbrev_entry++;
        if (table_abbrev_code == abbrev_code) {
          break;
        }
        // skip attributes
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
        } while (name != 0 || form != 0);
      }
      // parse subprogram or label DIE
      if (tag == DW_TAG_subprogram || tag == DW_TAG_label) {
        uintptr_t low_pc = 0;
        int found        = 0;
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
          if (name == DW_AT_low_pc) {
            count = dwarf_read_abbrev_entry(
                entry, form, &low_pc,
                sizeof(low_pc),
                address_size);
          } else if (name == DW_AT_name) {
            if (form == DW_FORM_strp) {
              unsigned long
                  str_offset = 0;
              count          = dwarf_read_abbrev_entry(
                  entry, form,
                  &str_offset,
                  sizeof(
                      unsigned long),
                  address_size);
              if (!strcmp(
                      fname,
                      (const char
                           *)addrs
                              ->str_begin +
                          str_offset)) {
                found = 1;
              }
            } else {
              if (!strcmp(fname, entry)) {
                found = 1;
              }
              count = dwarf_read_abbrev_entry(
                  entry, form,
                  NULL, 0,
                  address_size);
            }
          } else {
            count = dwarf_read_abbrev_entry(
                entry, form, NULL, 0,
                address_size);
          }
          entry += count;
        } while (name != 0 || form != 0);
        if (found) {
          // finish if fname found
          *offset = low_pc;
          return 0;
        }
      } else {
        // skip if not a subprogram or label
        do {
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &name);
          curr_abbrev_entry += count;
          count = dwarf_read_uleb128(
              curr_abbrev_entry, &form);
          curr_abbrev_entry += count;
          count = dwarf_read_abbrev_entry(
              entry, form, NULL, 0,
              address_size);
          entry += count;
        } while (name != 0 || form != 0);
      }
    }
  }

  return 0;
}
