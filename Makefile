# Makefile for Lewis & Short Latin Dictionary CLI

PREFIX ?= /usr/local
USER_PREFIX = $(HOME)/.local

.PHONY: all install uninstall user-install user-uninstall clean

all:
	@echo "Available targets:"
	@echo "  make install       - Install system-wide (requires sudo)"
	@echo "  make user-install  - Install for current user only"
	@echo "  make uninstall     - Uninstall system-wide installation"
	@echo "  make user-uninstall - Uninstall user installation"
	@echo ""
	@echo "Or use the install.sh script for more options"

install:
	./install.sh --force

user-install:
	./install.sh --user --force

uninstall:
	@echo "Removing system-wide installation..."
	@sudo rm -f $(PREFIX)/bin/lslatdict
	@sudo rm -rf $(PREFIX)/share/lslatdict
	@echo "Uninstallation complete."

user-uninstall:
	@echo "Removing user installation..."
	@rm -f $(USER_PREFIX)/bin/lslatdict
	@rm -rf $(USER_PREFIX)/share/lslatdict
	@echo "Uninstallation complete."

clean:
	@echo "Nothing to clean."
	@echo "Use uninstall targets to remove installed files."
