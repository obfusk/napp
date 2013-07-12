# --                                                            ; {{{1
#
# File        : Makefile
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

vsn         := $(shell git describe --always)

PREFIX      ?= /usr/local
PREFIX_LIB  ?= $(PREFIX)/lib/napp
PREFIX_DOC  ?= $(PREFIX)/share/doc/napp
PREFIX_RM   ?= $(PREFIX_DOC)

# --

bin     := $(wildcard bin/*[^~])
doc     := $(wildcard doc/*[^~])
lib     := $(shell find lib -name '*.rb')

# --

.PHONY: all install install-shallow clean archive

all:

install: all
	set -e                                          ;\
	DIR=$(PREFIX_LIB) DOC=$(PREFIX_DOC)             ;\
	mkdir -p $$DIR/bin $$DIR/lib $$DOC $(PREFIX_RM) ;\
	for FILE in $(lib); do                           \
	  DIR2=$$DIR/$$(dirname $$FILE)                 ;\
	  mkdir -p $$DIR2                               ;\
	  cp -vt $$DIR2 $$FILE                          ;\
	done                                            ;\
	cp -vt $$DIR/bin $(bin)                         ;\
	cp -vt $$DOC $(doc)                             ;\
	cp -vt $(PREFIX_RM) README.md

install-shallow:
	$(MAKE) install PREFIX=$(PREFIX)                \
	  PREFIX_LIB=$(PREFIX) PREFIX_DOC=$(PREFIX)/doc \
	  PREFIX_RM=$(PREFIX)

clean:
	rm -fr _archive *.gem *.tar

archive: all
	set -e                                          ;\
	DIR=_archive/napp-$(vsn)                        ;\
	rm -fr $$DIR                                    ;\
	$(MAKE) install-shallow PREFIX=$$DIR            ;\
	tar cf napp-$(vsn).tar -C _archive napp-$(vsn)

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
