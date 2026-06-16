PREFIX ?= /usr/local
DESTDIR ?=

BATS ?= $(shell command -v bats 2>/dev/null || echo ~/.nix-profile/bin/bats)
SHELLCHECK ?= $(shell command -v shellcheck 2>/dev/null || echo ~/.nix-profile/bin/shellcheck)

.PHONY: all install uninstall lint test clean

all:
	@echo "am-lite is a bash utility. Run 'make install' to install it."

install:
	# Install binary
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 am-lite $(DESTDIR)$(PREFIX)/bin/am-lite

	# Install config template
	install -d $(DESTDIR)/etc
	install -m 644 am-lite.conf.example $(DESTDIR)/etc/am-lite.conf.example

	# Install manpage
	install -d $(DESTDIR)$(PREFIX)/share/man/man1
	install -m 644 am-lite.1 $(DESTDIR)$(PREFIX)/share/man/man1/am-lite.1

	# Install Bash completion
	install -d $(DESTDIR)/usr/share/bash-completion/completions
	install -m 644 completions/am-lite.bash $(DESTDIR)/usr/share/bash-completion/completions/am-lite

	# Install Zsh completion
	install -d $(DESTDIR)/usr/share/zsh/site-functions
	install -m 644 completions/am-lite.zsh $(DESTDIR)/usr/share/zsh/site-functions/_am-lite

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/am-lite
	rm -f $(DESTDIR)/etc/am-lite.conf.example
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/am-lite.1
	rm -f $(DESTDIR)/usr/share/bash-completion/completions/am-lite
	rm -f $(DESTDIR)/usr/share/zsh/site-functions/_am-lite

lint:
	# Run shellcheck
	$(SHELLCHECK) am-lite

test:
	# Run bats tests
	$(BATS) tests/test_am_lite.bats

clean:
	@echo "Nothing to clean."
