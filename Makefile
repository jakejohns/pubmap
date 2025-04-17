MAKEFLAGS += --no-builtin-rules --no-builtin-variables --warn-undefined-variables

SRCDIR = src/
INSTALL_DIRS = $(shell find $(SRCDIR) -type d 2>/dev/null | sed 's|^$(SRCDIR)||')
INSTALL_FILES = $(shell find $(SRCDIR) -type f 2>/dev/null | sed 's|^$(SRCDIR)||')

TESTDIR = test/
TESTS = $(wildcard $(TESTDIR)*.csv)

# Destinations
PREFIX ?= $(HOME)/.local

# Optionally simulate the stow procedures
SIMULATE ?= false

# Stow options
STOW_OPTS ?= $(if $(filter true,$(SIMULATE)), --simulate) \
			 --no-folding --verbose --target=$(PREFIX) src

.PHONY: vars
vars:
	@echo "'make install' or 'make stow' to install"
	@echo "PREFIX: $(PREFIX)"
	@echo "INSTALL_DIRS: $(INSTALL_DIRS)"
	@echo "INSTALL_FILES: $(INSTALL_FILES)"
	@echo "TESTS: $(TESTS)"

.PHONY: install
install:
	@echo "Installing files"
	@for dir in $(INSTALL_DIRS); do mkdir -v -p $(PREFIX)/$$dir; done
	@for file in $(INSTALL_FILES); do cp -i -v $(SRCDIR)$$file $(PREFIX)/$$file; done

.PHONY: uninstall
uninstall:
	@echo "Uninstalling files"
	@for file in $(INSTALL_FILES); do rm -fv $(PREFIX)/$$file; done

.PHONY: stow
stow:
	@echo "Stowing files"
	@stow $(STOW_OPTS)

.PHONY: unstow
unstow:
	@echo "Un-stow files"
	@stow --delete $(STOW_OPTS)

.PHONY: restow
restow:
	@echo "Restow files"
	@stow --restow $(STOW_OPTS)
