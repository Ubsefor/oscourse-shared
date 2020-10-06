/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <kern/kclock.h>

void
rtc_init(void) {
  // LAB 4: Your code here
	nmi_disable();
  
  uint8_t areg, breg;
  outb(IO_RTC_CMND, RTC_AREG);
  areg = inb(IO_RTC_DATA);
  areg |= 0x0F; 
  outb(IO_RTC_DATA, areg);

  outb(IO_RTC_CMND, RTC_BREG);
  breg = inb(IO_RTC_DATA);
  breg |= RTC_PIE;
  outb(IO_RTC_DATA, breg);

	nmi_enable();
}

uint8_t
rtc_check_status(void) {
  uint8_t status = 0;
  // LAB 4: Your code here
  outb(IO_RTC_CMND, RTC_CREG);
  status = inb(IO_RTC_DATA);
	return status;
}
