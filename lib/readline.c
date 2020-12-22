#include <inc/error.h>
#include <inc/stdio.h>
#include <inc/string.h>

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt) {
  int i, c, echoing;

  if (prompt != NULL) {
#if JOS_KERNEL
    cprintf("%s", prompt);
#else
    fprintf(1, "%s", prompt);
#endif
  }

  i = 0;
  echoing = iscons(0);
  while (1) {
    c = getchar();
    if (c < 0) {
      if (c != -E_EOF)
        cprintf("read error: %i\n", c);
      return NULL;
    } else if ((c == '\b' || c == '\x7f')) {
      if (i > 0) {
        if (echoing) {
          cputchar('\b');
          cputchar(' ');
          cputchar('\b');
        }
        i--;
      }
    } else if (c >= ' ' && i < BUFLEN - 1) {
      if (echoing)
        cputchar(c);
      buf[i++] = c;
    } else if (c == '\n' || c == '\r') {
      if (echoing)
        cputchar('\n');
      buf[i] = 0;
      return buf;
    }
  }
}
