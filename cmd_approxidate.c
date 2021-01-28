#define _XOPEN_SOURCE
#define _POSIX_C_SOURCE 200809L
#include "approxidate.h"
#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define FORMAT "%Y-%m-%dT%H:%M:%S%z"

static
void usage(const char *progname)
{
    fprintf(stderr, "%s date_str\n", progname);
    exit(EXIT_FAILURE);
}

static
int format_timeval(struct timeval tv, char *out, size_t max)
{
    struct tm *tm = NULL;

    tm = localtime(&tv.tv_sec);

    return strftime(out, max, FORMAT, tm);
}

int main(int argc, const char *argv[])
{
    struct timeval t;
    static char buf[80] = { 0 };
    size_t max = sizeof(buf) - 1;

    if (argc != 2) {
        usage(argv[0]);
    }

    if (approxidate_relative(argv[1], &t, NULL) != 0)
        return EXIT_FAILURE;
    format_timeval(t, buf, max);
    printf("%s\n", buf);

	return EXIT_SUCCESS;
}
