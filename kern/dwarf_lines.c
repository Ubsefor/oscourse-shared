#include <inc/assert.h>
#include <inc/dwarf.h>
#include <inc/error.h>
#include <inc/types.h>

// Line Number machine state. Some registers, considered in standard, are
// omitted:
// - Register `file`. We have already found source file name from function
// `file_name_by_info`.
// - Flag registers `is_stmt`, `basic_block`, `prologue_end`, `epilogue_begin`.
// These flags are needed primarily for debugger to know where it should place
// breakpoints.
// - Register `isa`. We work with x86 ISA only.
// In fact, we don't need also registers `column` and `discriminator`, but they
// are left for future extensions.
struct Line_Number_State {
  uintptr_t address;
  int line;
  int column;
  bool end_sequence;
  int discriminator;
};

struct Line_Number_Info {
  Dwarf_Small minimum_instruction_length;
  Dwarf_Small maximum_operations_per_instruction;
  signed char line_base;
  Dwarf_Small line_range;
  Dwarf_Small opcode_base;
  Dwarf_Small *standard_opcode_lengths;
};

// Execute the Line Number Program, starting at `program_addr` and ending at
// `end_addr`. Stop when next row of line number table corresponds to address
// which is greater than `destination_addr`. Last raw, which corresponds to
// address less or equal `destination_addr`, will be the raw we look for.
inline static void run_line_number_program(const void *program_addr,
                                           const void *end_addr,
                                           const struct Line_Number_Info *info,
                                           struct Line_Number_State *state,
                                           uintptr_t destination_addr) {
  struct Line_Number_State last_state;
  while (program_addr < end_addr) {
    Dwarf_Small opcode = get_unaligned(program_addr, Dwarf_Small);
    program_addr += sizeof(Dwarf_Small);
    if (opcode == 0) {
      // We have an extended opcode.
      unsigned length;
      unsigned long count = dwarf_read_uleb128(program_addr, &length);
      program_addr += count;
      const void *opcode_end = program_addr + length;
      opcode = get_unaligned(program_addr, Dwarf_Small);
      program_addr += sizeof(Dwarf_Small);

      switch (opcode) {
      case DW_LNE_end_sequence:
        state->end_sequence = true;
        if (last_state.address <= destination_addr &&
            destination_addr < state->address) {
          *state = last_state;
          return;
        }
        last_state = *state;
        state->address = 0;
        state->line = 1;
        state->column = 0;
        state->end_sequence = false;
        state->discriminator = 0;
        break;
      case DW_LNE_set_address: {
        uintptr_t addr = get_unaligned(program_addr, uintptr_t);
        state->address = addr;
        program_addr += sizeof(uintptr_t);
      } break;
      case DW_LNE_define_file: {
        // Skip file name
        while (*(char *)program_addr) {
          ++program_addr;
        }
        ++program_addr;
        unsigned dir_index;
        unsigned long count = dwarf_read_uleb128(program_addr, &dir_index);
        program_addr += count;

        unsigned last_mod;
        count = dwarf_read_uleb128(program_addr, &last_mod);
        program_addr += count;

        unsigned length;
        count = dwarf_read_uleb128(program_addr, &length);
        program_addr += count;
      } break;
      case DW_LNE_set_discriminator: {
        unsigned discriminator;
        unsigned long count = dwarf_read_uleb128(program_addr, &discriminator);
        state->discriminator = discriminator;
        program_addr += count;
      } break;
      default:
        panic("Unknown opcode: %x", opcode);
        break;
      }
      assert(program_addr == opcode_end);
    } else if (opcode < info->opcode_base) {
      // We have a standard opcode.
      switch (opcode) {
      case DW_LNS_copy:
        if (last_state.address <= destination_addr &&
            destination_addr < state->address) {
          *state = last_state;
          return;
        }
        last_state = *state;
        state->discriminator = 0;
        break;
      case DW_LNS_advance_pc: {
        unsigned op_advance;
        unsigned long count = dwarf_read_uleb128(program_addr, &op_advance);
        state->address +=
            info->minimum_instruction_length *
            (op_advance / info->maximum_operations_per_instruction);
        program_addr += count;
      } break;
      case DW_LNS_advance_line: {
        int line_incr;
        unsigned long count = dwarf_read_leb128(program_addr, &line_incr);
        state->line += line_incr;
        program_addr += count;
      } break;
      case DW_LNS_set_file: {
        unsigned file;
        unsigned long count = dwarf_read_uleb128(program_addr, &file);
        program_addr += count;
      } break;
      case DW_LNS_set_column: {
        unsigned column;
        unsigned long count = dwarf_read_uleb128(program_addr, &column);
        state->column = column;
        program_addr += count;
      } break;
      case DW_LNS_negate_stmt:
        // We don't have an `is_stmt` register, so we
        // don't need to do anything
        break;
      case DW_LNS_set_basic_block:
        // We don't have a `basic_block` register, so we
        // don't need to dy anything
        break;
      case DW_LNS_const_add_pc: {
        unsigned opcode = 255;
        Dwarf_Small adjusted_opcode = opcode - info->opcode_base;
        int op_advance = adjusted_opcode / info->line_range;
        state->address +=
            info->minimum_instruction_length *
            (op_advance / info->maximum_operations_per_instruction);
      } break;
      case DW_LNS_fixed_advance_pc: {
        Dwarf_Half pc_inc = get_unaligned(program_addr, Dwarf_Half);
        state->address += pc_inc;
        program_addr += sizeof(Dwarf_Half);
      } break;
      case DW_LNS_set_prologue_end:
        // We don't have a `basic_block` register, so we
        // don't need to do anything
        break;
      case DW_LNS_set_epilogue_begin:
        // We don't have a `basic_block` register, so we
        // don't need to do anything
        break;
      case DW_LNS_set_isa: {
        unsigned isa;
        unsigned long count = dwarf_read_uleb128(program_addr, &isa);
        program_addr += count;
      } break;
      default:
        panic("Unknown opcode: %x", opcode);
        break;
      }
    } else {
      // We have a special opcode.
      Dwarf_Small adjusted_opcode = opcode - info->opcode_base;
      int op_advance = adjusted_opcode / info->line_range;
      state->line += (info->line_base + (adjusted_opcode % info->line_range));
      state->address += info->minimum_instruction_length *
                        (op_advance / info->maximum_operations_per_instruction);
      state->discriminator = 0;
      if (last_state.address <= destination_addr &&
          destination_addr < state->address) {
        *state = last_state;
        return;
      }
      last_state = *state;
    }
  }
}

// Get line number, corresponding to address `p` and store it to `lineno_store`.
// `addrs` should contain addresses of .debug_* sections and line_offset should
// contain an offset in .debug_line of entry associated with compilation unit,
// in which we search address `p`. This offset can be obtained from .debug_info
// section, using the `file_name_by_info` function.
int line_for_address(const struct Dwarf_Addrs *addrs, uintptr_t p,
                     Dwarf_Off line_offset, int *lineno_store) {
  if (line_offset > addrs->line_end - addrs->line_begin) {
    return -E_INVAL;
  }
  if (lineno_store == NULL) {
    return -E_INVAL;
  }
  const void *curr_addr = addrs->line_begin + line_offset;
  struct Line_Number_State current_state = {
      .address = 0,
      .line = 1,
      .column = 0,
      .end_sequence = false,
      .discriminator = 0,
  };

  // Parse Line Number Program Header.
  unsigned long unit_length;
  int count = dwarf_entry_len(curr_addr, &unit_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    curr_addr += count;
  }
  const void *unit_end = curr_addr + unit_length;
  Dwarf_Half version = get_unaligned(curr_addr, Dwarf_Half);
  curr_addr += sizeof(Dwarf_Half);
  assert(version == 4 || version == 3 || version == 2);
  unsigned long header_length;
  count = dwarf_entry_len(curr_addr, &header_length);
  if (count == 0) {
    return -E_BAD_DWARF;
  } else {
    curr_addr += count;
  }
  const void *program_addr = curr_addr + header_length;
  Dwarf_Small minimum_instruction_length =
      get_unaligned(curr_addr, Dwarf_Small);
  assert(minimum_instruction_length == 1);
  curr_addr += sizeof(Dwarf_Small);
  Dwarf_Small maximum_operations_per_instruction;
  if (version == 4) {
    maximum_operations_per_instruction = get_unaligned(curr_addr, Dwarf_Small);
    curr_addr += sizeof(Dwarf_Small);
  } else {
    maximum_operations_per_instruction = 1;
  }
  assert(maximum_operations_per_instruction == 1);
  // Skip default_is_stmt as we don't need it.
  curr_addr += sizeof(Dwarf_Small);
  signed char line_base = get_unaligned(curr_addr, signed char);
  curr_addr += sizeof(signed char);
  Dwarf_Small line_range = get_unaligned(curr_addr, Dwarf_Small);
  curr_addr += sizeof(Dwarf_Small);
  Dwarf_Small opcode_base = get_unaligned(curr_addr, Dwarf_Small);
  curr_addr += sizeof(Dwarf_Small);
  Dwarf_Small *standard_opcode_lengths =
      (Dwarf_Small *)get_unaligned(curr_addr, Dwarf_Small *);
  // Skip rest of the header, as we don't need include directories and
  // file_names and run line number program.
  struct Line_Number_Info info = {
      .minimum_instruction_length = minimum_instruction_length,
      .maximum_operations_per_instruction = maximum_operations_per_instruction,
      .line_base = line_base,
      .line_range = line_range,
      .opcode_base = opcode_base,
      .standard_opcode_lengths = standard_opcode_lengths,
  };

  run_line_number_program(program_addr, unit_end, &info, &current_state, p);

  *lineno_store = current_state.line;

  return 0;
}
