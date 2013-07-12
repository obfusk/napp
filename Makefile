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
	cp -t $$DIR/bin $(bin)                          ;\
	cp -t $$DIR/lib $(lib)                          ;\
	cp -t $$DOC $(doc) README.md

clean:
	rm -fr _archive

archive: all
	DIR=_archive/napp-$(vsn)                        ;\
	mkdir -p $$DIR/bin $$DIR/lib $$DIR/doc          ;\
	cp -t $$DIR/bin $(bin)                          ;\
	cp -t $$DIR/lib $(lib)                          ;\
	cp -t $$DIR/doc $(doc)                          ;\
	cp -t $$DIR README.md                           ;\
	tar cf napp-$(vsn).tar -C _archive napp-$(vsn)  ;\
	rm -fr _archive

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
