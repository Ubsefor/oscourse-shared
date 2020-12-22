#include <inc/assert.h>
#include <inc/memlayout.h>
#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/types.h>
#include <inc/uefi.h>
#include <inc/x86.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/pmap.h>
#include <kern/timer.h>
#include <kern/trap.h>

#define kilo (1000ULL)
#define Mega (kilo * kilo)
#define Giga (kilo * Mega)
#define Tera (kilo * Giga)
#define Peta (kilo * Tera)
#define ULONG_MAX ~0UL

#if LAB <= 6
// Early variant of memory mapping that does 1:1 aligned area mapping
// in 2MB pages. You will need to reimplement this code with proper
// virtual memory mapping in the future.
static void *mmio_map_region(physaddr_t pa, size_t size) {
  void map_addr_early_boot(uintptr_t addr, uintptr_t addr_phys, size_t sz);
  const physaddr_t base_2mb = 0x200000;
  uintptr_t org = pa;
  size += pa & (base_2mb - 1);
  size += (base_2mb - 1);
  pa &= ~(base_2mb - 1);
  size &= ~(base_2mb - 1);
  map_addr_early_boot(pa, pa, size);
  return (void *)org;
}
#endif

struct Timer timertab[MAX_TIMERS];
struct Timer *timer_for_schedule;

struct Timer timer_hpet0 = {
    .timer_name = "hpet0",
    .timer_init = hpet_init,
    .get_cpu_freq = hpet_cpu_frequency,
    .enable_interrupts = hpet_enable_interrupts_tim0,
    .handle_interrupts = hpet_handle_interrupts_tim0,
};

struct Timer timer_hpet1 = {
    .timer_name = "hpet1",
    .timer_init = hpet_init,
    .get_cpu_freq = hpet_cpu_frequency,
    .enable_interrupts = hpet_enable_interrupts_tim1,
    .handle_interrupts = hpet_handle_interrupts_tim1,
};

struct Timer timer_acpipm = {
    .timer_name = "pm",
    .timer_init = acpi_enable,
    .get_cpu_freq = pmtimer_cpu_frequency,
};

bool check_sum(void *Table, int type) {
  int sum = 0;
  uint32_t len = 0;
  switch (type) {
  case 0:
    len = ((RSDP *)Table)->Length;
    break;
  case 1:
    len = ((ACPISDTHeader *)Table)->Length;
    break;
  default:
    break;
  }
  for (int i = 0; i < len; i++)
    sum += ((uint8_t *)Table)[i];
  if (sum % 0x100 == 0)
    return 1;
  return 0;
}

void acpi_enable(void) {
  FADT *fadt = get_fadt();
  outb(fadt->SMI_CommandPort, fadt->AcpiEnable);
  while ((inw(fadt->PM1aControlBlock) & 1) == 0) {
  }
}

// Obtain RSDP ACPI table address from bootloader.
RSDP *get_rsdp(void) {
  static void *krsdp = NULL;
  if (krsdp != NULL)
    return krsdp;
  if (uefi_lp->ACPIRoot == 0)
    panic("No rsdp\n");
  krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));
  return krsdp;
}

// LAB 5 code
static void *acpi_find_table(const char *sign) {
  static RSDT *krsdt;
  static size_t krsdt_len;
  static size_t krsdt_entsz;

  uint8_t cksm = 0;

  if (!krsdt) {
    if (!uefi_lp->ACPIRoot) {
      panic("No rsdp\n");
    }
    RSDP *krsdp = mmio_map_region(uefi_lp->ACPIRoot, sizeof(RSDP));

    if (strncmp(krsdp->Signature, "RSD PTR", 8))
      // panic("Invalid RSDP");

      for (size_t i = 0; i < offsetof(RSDP, Length); i++)
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
    if (cksm)
      panic("Invalid RSDP");

    uint64_t rsdt_pa = krsdp->RsdtAddress;
    krsdt_entsz = 4;

    if (krsdp->Revision) {
      /* ACPI version >= 2.0 */
      for (size_t i = 0; i < krsdp->Length; i++)
        cksm = (uint8_t)(cksm + ((uint8_t *)krsdp)[i]);
      if (cksm)
        panic("Invalid RSDP");

      rsdt_pa = krsdp->XsdtAddress;
      krsdt_entsz = 8;
    }

    krsdt = mmio_map_region(rsdt_pa, sizeof(RSDT));
    /* Remap since we can obtain table length only after mapping */
    krsdt =
        mmio_remap_last_region(rsdt_pa, krsdt, sizeof(RSDP), krsdt->h.Length);

    for (size_t i = 0; i < krsdt->h.Length; i++)
      cksm = (uint8_t)(cksm + ((uint8_t *)krsdt)[i]);

    if (cksm)
      panic("Invalid RSDP");

    if (strncmp(krsdt->h.Signature, krsdp->Revision ? "XSDT" : "RSDT", 4))
      panic("Invalid RSDT");

    krsdt_len = (krsdt->h.Length - sizeof(RSDT)) / 4;
    if (krsdp->Revision) {
      krsdt_len = krsdt_len / 2;
    }
  }

  ACPISDTHeader *hd = NULL;

  for (size_t i = 0; i < krsdt_len; i++) {
    /* Assume little endian */
    uint64_t fadt_pa = 0;
    memcpy(&fadt_pa, (uint8_t *)krsdt->PointerToOtherSDT + i * krsdt_entsz,
           krsdt_entsz);

    hd = mmio_map_region(fadt_pa, sizeof(ACPISDTHeader));
    /* Remap since we can obtain table length only after mapping */
    hd = mmio_remap_last_region(fadt_pa, hd, sizeof(ACPISDTHeader),
                                krsdt->h.Length);

    for (size_t i = 0; i < hd->Length; i++)
      cksm = (uint8_t)(cksm + ((uint8_t *)hd)[i]);
    if (cksm)
      panic("ACPI table '%.4s' invalid", hd->Signature);
    if (!strncmp(hd->Signature, sign, 4))
      return hd;
  }

  return NULL;
}

// LAB 5 code end

// LAB 5: your code here
// Obtain and map FADT ACPI table address.
FADT *get_fadt(void) {
  // LAB 5 code
  static FADT *kfadt;

  if (!kfadt) {
    kfadt = acpi_find_table("FACP");
  }

  return kfadt;
  // LAB 5 code end

  // return NULL;
}

// LAB 5: Your code here.
// Obtain and map RSDP ACPI table address.
HPET *get_hpet(void) {
  // LAB 5 code
  static HPET *khpet;
  if (!khpet) {
    khpet = acpi_find_table("HPET");
  }
  return khpet;
  // LAB 5 code end
  return NULL;
}

// Getting physical HPET timer address from its table.
HPETRegister *hpet_register(void) {
  HPET *hpet_timer = get_hpet();
  if (hpet_timer->address.address == 0)
    panic("hpet is unavailable\n");

  uintptr_t paddr = hpet_timer->address.address;
  return mmio_map_region(paddr, sizeof(HPETRegister));
}

// Debug HPET timer state.
void hpet_print_struct(void) {
  HPET *hpet = get_hpet();
  cprintf("signature = %s\n", (hpet->h).Signature);
  cprintf("length = %08x\n", (hpet->h).Length);
  cprintf("revision = %08x\n", (hpet->h).Revision);
  cprintf("checksum = %08x\n", (hpet->h).Checksum);

  cprintf("oem_revision = %08x\n", (hpet->h).OEMRevision);
  cprintf("creator_id = %08x\n", (hpet->h).CreatorID);
  cprintf("creator_revision = %08x\n", (hpet->h).CreatorRevision);

  cprintf("hardware_rev_id = %08x\n", hpet->hardware_rev_id);
  cprintf("comparator_count = %08x\n", hpet->comparator_count);
  cprintf("counter_size = %08x\n", hpet->counter_size);
  cprintf("reserved = %08x\n", hpet->reserved);
  cprintf("legacy_replacement = %08x\n", hpet->legacy_replacement);
  cprintf("pci_vendor_id = %08x\n", hpet->pci_vendor_id);
  cprintf("hpet_number = %08x\n", hpet->hpet_number);
  cprintf("minimum_tick = %08x\n", hpet->minimum_tick);

  cprintf("address_structure:\n");
  cprintf("address_space_id = %08x\n", (hpet->address).address_space_id);
  cprintf("register_bit_width = %08x\n", (hpet->address).register_bit_width);
  cprintf("register_bit_offset = %08x\n", (hpet->address).register_bit_offset);
  cprintf("address = %08lx\n", (unsigned long)(hpet->address).address);
}

static volatile HPETRegister *hpetReg;
// HPET timer period (in femtoseconds)
static uint64_t hpetFemto = 0;
// HPET timer frequency
static uint64_t hpetFreq = 0;

// HPET timer initialisation
void hpet_init() {
  if (hpetReg == NULL) {
    nmi_disable();
    hpetReg = hpet_register();
    hpetFemto = (uintptr_t)(hpetReg->GCAP_ID >> 32);
    // cprintf("hpetFemto = %llu\n", hpetFemto);
    hpetFreq = (1 * Peta) / hpetFemto;
    // cprintf("HPET: Frequency = %d.%03dMHz\n", (uintptr_t)(hpetFreq / Mega),
    // (uintptr_t)(hpetFreq % Mega)); Enable ENABLE_CNF bit to enable timer.
    hpetReg->GEN_CONF |= 1;
    nmi_enable();
  }
}

// HPET register contents debugging.
void hpet_print_reg(void) {
  cprintf("GCAP_ID = %016lx\n", (unsigned long)hpetReg->GCAP_ID);
  cprintf("GEN_CONF = %016lx\n", (unsigned long)hpetReg->GEN_CONF);
  cprintf("GINTR_STA = %016lx\n", (unsigned long)hpetReg->GINTR_STA);
  cprintf("MAIN_CNT = %016lx\n", (unsigned long)hpetReg->MAIN_CNT);
  cprintf("TIM0_CONF = %016lx\n", (unsigned long)hpetReg->TIM0_CONF);
  cprintf("TIM0_COMP = %016lx\n", (unsigned long)hpetReg->TIM0_COMP);
  cprintf("TIM0_FSB = %016lx\n", (unsigned long)hpetReg->TIM0_FSB);
  cprintf("TIM1_CONF = %016lx\n", (unsigned long)hpetReg->TIM1_CONF);
  cprintf("TIM1_COMP = %016lx\n", (unsigned long)hpetReg->TIM1_COMP);
  cprintf("TIM1_FSB = %016lx\n", (unsigned long)hpetReg->TIM1_FSB);
  cprintf("TIM2_CONF = %016lx\n", (unsigned long)hpetReg->TIM2_CONF);
  cprintf("TIM2_COMP = %016lx\n", (unsigned long)hpetReg->TIM2_COMP);
  cprintf("TIM2_FSB = %016lx\n", (unsigned long)hpetReg->TIM2_FSB);
}

// HPET main timer counter value.
uint64_t hpet_get_main_cnt(void) { return hpetReg->MAIN_CNT; }

// LAB 5: Your code here.
// - Configure HPET timer 0 to trigger every 0.5 seconds
// on IRQ_TIMER line.
// - Configure HPET timer 1 to trigger every 1.5 seconds
// on IRQ_CLOCK line.
// Hint: to be able to use HPET as PIT replacement consult
// LegacyReplacement functionality in HPET spec.

#define HPET_TN_TYPE_CNF (1 << 3)
#define HPET_TN_INT_ENB_CNF (1 << 2)
#define HPET_TN_VAL_SET_CNF (1 << 6)
#define HPET_LEG_RT_CNF (1 << 1)

void hpet_enable_interrupts_tim0(void) {
  // LAB 5 code
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  hpetReg->TIM0_CONF = (IRQ_TIMER << 9) | HPET_TN_TYPE_CNF |
                       HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  hpetReg->TIM0_COMP = hpet_get_main_cnt() + Peta / 2 / hpetFemto;
  hpetReg->TIM0_COMP = Peta / 2 / hpetFemto;
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_TIMER));
  // LAB 5 code end
}

void hpet_enable_interrupts_tim1(void) {
  // LAB 5 code
  hpetReg->GEN_CONF |= HPET_LEG_RT_CNF;
  hpetReg->TIM1_CONF = (IRQ_CLOCK << 9) | HPET_TN_TYPE_CNF |
                       HPET_TN_INT_ENB_CNF | HPET_TN_VAL_SET_CNF;
  hpetReg->TIM1_COMP = hpet_get_main_cnt() + 3 * Peta / 2 / hpetFemto;
  hpetReg->TIM1_COMP = 3 * Peta / 2 / hpetFemto;
  irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_CLOCK));
  // LAB 5 code end
}

void hpet_handle_interrupts_tim0(void) {
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_TIMER);
}

void hpet_handle_interrupts_tim1(void) {
  // LAB 5 code

  // LAB 5 code end
  pic_send_eoi(IRQ_CLOCK);
}

// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with HPET timer.
// Hint: use hpet_get_main_cnt function and do not forget about
// about pause instruction.
uint64_t hpet_cpu_frequency(void) {
  // LAB 5 code
  uint64_t time_res = 100;
  uint64_t delta = 0, target = hpetFreq / time_res;

  uint64_t tick0 = hpet_get_main_cnt();
  uint64_t tsc0 = read_tsc();
  do {
    asm("pause");
    delta = hpet_get_main_cnt() - tick0;
  } while (delta < target);

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * time_res;
  // LAB 5 code end
  // return 0;
}

uint32_t pmtimer_get_timeval(void) {
  FADT *fadt = get_fadt();
  return inl(fadt->PMTimerBlock);
}

#define PM_FREQ 3579545

// LAB 5: Your code here.
// Calculate CPU frequency in Hz with the help with ACPI PowerManagement timer.
// Hint: use pmtimer_get_timeval function and do not forget that ACPI PM timer
// can be 24-bit or 32-bit.
uint64_t pmtimer_cpu_frequency(void) {
  // LAB 5 code
  uint32_t time_res = 100;
  uint32_t tick0 = pmtimer_get_timeval();
  uint64_t delta = 0, target = PM_FREQ / time_res;

  uint64_t tsc0 = read_tsc();

  do {
    asm("pause");
    uint32_t tick1 = pmtimer_get_timeval();
    delta = tick1 - tick0;
    if (-delta <= 0xFFFFFF) {
      delta += 0xFFFFFF;
    } else if (tick0 > tick1) {
      delta += 0xFFFFFFFF;
    }
  } while (delta < target);

  uint64_t tsc1 = read_tsc();

  return (tsc1 - tsc0) * PM_FREQ / delta;
  // LAB 5 code end
  // return 0;
}
