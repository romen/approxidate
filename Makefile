CFLAGS=-Wall -std=c11 -O3 -march=native
LDLIBS=-lm

MKDIR=mkdir
INSTALL=install
INSTALL_PROGRAM=${INSTALL}
INSTALL_DATA=${INSTALL} -m 644
INSTALL_BIN=${INSTALL} -m 755

prefix=/usr/local
bindir=$(prefix)/bin
includedir=$(prefix)/include
libdir=$(prefix)/lib

CMDTARGET=approxidate
CMDTARGET_SHARED=approxidate-shared
CMDTARGET_STATIC=approxidate-static
CMDTARGET_DEFAULT=$(CMDTARGET_SHARED)
LIBTARGET_SHARED=libapproxidate.so
LIBTARGET_STATIC=libapproxidate.a

all: test $(LIBTARGET_SHARED) $(LIBTARGET_STATIC) $(CMDTARGET)

mkinstalldir:
	$(MKDIR) -p $(DESTDIR)$(bindir)/
	$(MKDIR) -p $(DESTDIR)$(libdir)/
	$(MKDIR) -p $(DESTDIR)$(includedir)/

install: all mkinstalldir
	$(INSTALL_BIN) $(CMDTARGET) $(DESTDIR)$(bindir)/
	$(INSTALL_DATA) $(LIBTARGET_SHARED) $(LIBTARGET_STATIC) $(DESTDIR)$(libdir)/
	$(INSTALL_DATA) approxidate.h $(DESTDIR)$(includedir)/
uninstall:
	$(RM) $(DESTDIR)$(bindir)/$(CMDTARGET)
	$(RM) $(DESTDIR)$(libdir)/$(LIBTARGET_SHARED)
	$(RM) $(DESTDIR)$(libdir)/$(LIBTARGET_STATIC)
	$(RM) $(DESTDIR)$(includedir)/approxidate.h


$(CMDTARGET): $(CMDTARGET_DEFAULT)
	cp $< $@

$(CMDTARGET_SHARED): LDFLAGS_LOCAL+=-Wl,--enable-new-dtags,-rpath,$(libdir)
$(CMDTARGET_SHARED): LDFLAGS_LOCAL+=-L.
$(CMDTARGET_SHARED): LDLIBS_LOCAL+=-lapproxidate
$(CMDTARGET_SHARED): cmd_approxidate.o $(LIBTARGET_SHARED)
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS_LOCAL) $(LDLIBS_LOCAL) $(LDFLAGS) $(LDLIBS)
$(CMDTARGET_STATIC): cmd_approxidate.o $(LIBTARGET_STATIC)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS) $(LDLIBS)

$(LIBTARGET_SHARED): CFLAGS+=-fPIC -shared
$(LIBTARGET_SHARED): approxidate.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS) $(LDLIBS)

$(LIBTARGET_STATIC): CFLAGS+=-static
$(LIBTARGET_STATIC): approxidate.o
	$(AR) rcs $@ $^

approxidate-test: approxidate-test.o $(LIBTARGET_STATIC)

test: approxidate-test $(CMDTARGET_SHARED)
	./approxidate-test

clean:
	rm -rf *.o
	rm -f $(LIBTARGET_SHARED) $(LIBTARGET_STATIC) $(CMDTARGET_SHARED) $(CMDTARGET_STATIC)
	rm -f $(CMDTARGET)
	rm -f approxidate-test
	$(MAKE) -C python clean

.PHONY: all test clean mkinstalldir install
