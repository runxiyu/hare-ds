# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2021-2025 Hare authors <https://harelang.org>
# SPDX-FileCopyrightText: 2025 Runxi Yu <https://runxiyu.org>

.POSIX:
.SUFFIXES:
HARE=hare
HAREFLAGS=

DESTDIR=
PREFIX=/usr/local
SRCDIR=$(PREFIX)/src
HARESRCDIR=$(SRCDIR)/hare
THIRDPARTYDIR=$(HARESRCDIR)/third-party

check:
	$(HARE) $(HAREFLAGS) test

install:
	install -dm644 ds/ $(DESTDIR)$(THIRDPARTYDIR)/

uninstall:
	rm -rf $(DESTDIR)$(THIRDPARTYDIR)/ds/

html:
	mkdir -p html
	for d in $$(scripts/moddirs); do \
		find $$d -type d | sed -E '/(\+|-)/d'; \
	done \
	| while read path; do \
		mod=$$(echo $$path | sed -E 's@/@::@g'); \
		echo $$mod; \
		mkdir -p html/$$path; \
		echo haredoc -Fhtml $$mod; \
		haredoc -Fhtml $$mod | sed "s@<a href='/'>stdlib</a>@third-party@g" > html/$$path/index.html; \
	done

.PHONY: check install uninstall html
