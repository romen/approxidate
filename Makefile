CFLAGS=-Wall -std=c11 -O3 -march=native
LDLIBS=-lm

all: approxidate test

#approxidate: LDFLAGS=-static
approxidate: cmd_approxidate.o approxidate.o approxidate.h

approxidate-test: approxidate-test.o approxidate.o approxidate.h

test: approxidate-test
	./approxidate-test

clean:
	rm -rf *.o
	rm -f approxidate-test
	rm -f approxidate
	$(MAKE) -C python clean

.PHONY: all test clean
