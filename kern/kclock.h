/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_KCLOCK_H
#define JOS_KERN_KCLOCK_H
#ifndef JOS_KERNEL
#error "This is a JOS kernel header; user programs should not #include it"
#endif

#define IO_RTC_CMND 0x070 /* RTC control port */
#define IO_RTC_DATA 0x071 /* RTC data port */

#define NON_RATE_MASK(X)          (X & 0xF0)
#define SET_NEW_RATE(input, rate) (NON_RATE_MASK(input) | rate)
#define RTC_500MS_RATE            0x0F

#define RTC_AREG 0x0A
#define RTC_BREG 0x0B
#define RTC_CREG 0x0C
#define RTC_DREG 0x0D

#define RTC_SEC  0x00
#define RTC_MIN  0x02
#define RTC_HOUR 0x04

#define RTC_DAY  0x07
#define RTC_MON  0x08
#define RTC_YEAR 0x09

#define RTC_UPDATE_IN_PROGRESS 0x80

#define RTC_PIE 0x40
#define RTC_AIE 0x20
#define RTC_UIE 0x10

void rtc_init(void);
uint8_t rtc_check_status(void);

#endif // !JOS_KERN_KCLOCK_H
