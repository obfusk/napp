# --                                                            ; {{{1
#
# File        : Makefile
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

VERSION     := $(shell git describe --always)

PREFIX      ?= /usr/local
PREFIX_BIN  ?= $(PREFIX)/bin
PREFIX_LIB  ?= $(PREFIX)/lib/napp
PREFIX_DOC  ?= $(PREFIX)/share/doc/napp
PREFIX_RM   ?= $(PREFIX_DOC)

SHELL       := /bin/bash
READLINK_F  ?= readlink -f

# --

BINS        := $(wildcard bin/*[^~])
DOCS        := $(wildcard doc/*[^~])
EXAMPLES    := $(wildcard examples/*[^~])
LIBS        := $(shell find lib -name '*.rb')

# --

# NB: be careful w/ recursion !!!
export VERSION READLINK_F BINS DOCS EXAMPLES LIBS
export PREFIX PREFIX_BIN PREFIX_LIB PREFIX_DOC PREFIX_RM

# --

.PHONY: all install install-shallow clean archive gem

all:

install: all
	./_scripts/install

# NB: we only need to pass modified PREFIX_* b/c they are exported
install-shallow:
	$(MAKE) install PREFIX_LIB=$(PREFIX) \
	  PREFIX_DOC=$(PREFIX)/doc PREFIX_RM=$(PREFIX)

clean:
	rm -fr *.gem *.tar _archive _tmp

archive: all
	./_scripts/archive

gem: all
	gem build napp.gemspec

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
