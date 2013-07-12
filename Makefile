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

vsn     := $(shell git describe --always)
PREFIX  ?= /usr/local

# --

bin     := $(wildcard bin/*[^~])
doc     := $(wildcard doc/*[^~])
lib     := $(shell find lib -name '*.rb')

# --

.PHONY: all install clean archive

all:

install: all
	DIR=$(PREFIX)/lib/napp                          ;\
	DOC=$(PREFIX)/share/doc/napp                    ;\
	mkdir -p $$DIR/bin $$DIR/lib $$DOC              ;\
	for FILE in $(lib); do                           \
	  DIR2=$$DIR/$$(dirname $$FILE)                 ;\
	  mkdir -p $$DIR2                               ;\
	  cp -vt $$DIR2 $$FILE                          ;\
	done                                            ;\
	cp -vt $$DIR/bin $(bin)                         ;\
	cp -vt $$DOC $(doc) README.md

clean:
	rm -fr _archive *.gem *.tar

archive: all
	DIR=_archive/napp-$(vsn)                        ;\
	rm -fr $$DIR                                    ;\
	mkdir -p $$DIR/bin $$DIR/lib $$DIR/doc          ;\
	for FILE in $(lib); do                           \
	  DIR2=$$DIR/$$(dirname $$FILE)                 ;\
	  mkdir -p $$DIR2                               ;\
	  cp -vt $$DIR2 $$FILE                          ;\
	done                                            ;\
	cp -vt $$DIR/bin $(bin)                         ;\
	cp -vt $$DIR/doc $(doc)                         ;\
	cp -vt $$DIR README.md                          ;\
	tar cf napp-$(vsn).tar -C _archive napp-$(vsn)

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
