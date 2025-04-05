# Makefile for Latin & Greek Dictionary CLI

PREFIX ?= /usr/local
USER_PREFIX = $(HOME)/.local

.PHONY: all install uninstall user-install user-uninstall \
	install-latin install-greek install-all \
	user-install-latin user-install-greek user-install-all \
	clean

all:
	@echo "Available targets:"
	@echo ""
	@echo "Installation targets:"
	@echo "  make install             - Install Latin dictionary system-wide (requires sudo)"
	@echo "  make install-greek       - Install Greek dictionary system-wide (requires sudo)"
	@echo "  make install-all         - Install both dictionaries system-wide (requires sudo)"
	@echo ""
	@echo "User installation targets:"
	@echo "  make user-install        - Install Latin dictionary for current user only"
	@echo "  make user-install-greek  - Install Greek dictionary for current user only"
	@echo "  make user-install-all    - Install both dictionaries for current user"
	@echo ""
	@echo "Uninstallation targets:"
	@echo "  make uninstall           - Uninstall system-wide installation"
	@echo "  make user-uninstall      - Uninstall user installation"
	@echo ""
	@echo "Or use the install.sh script for more options:"
	@echo "  ./install.sh --help"

install: install-latin

install-latin:
	./install.sh --force --latin

install-greek:
	./install.sh --force --greek

install-all:
	./install.sh --force --all

user-install: user-install-latin

user-install-latin:
	./install.sh --user --force --latin

user-install-greek:
	./install.sh --user --force --greek

user-install-all:
	./install.sh --user --force --all

uninstall:
	@echo "Removing system-wide installation..."
	@sudo rm -f $(PREFIX)/bin/lsdict
	@sudo rm -rf $(PREFIX)/share/lsdict
	@echo "Uninstallation complete."

user-uninstall:
	@echo "Removing user installation..."
	@rm -f $(USER_PREFIX)/bin/lsdict
	@rm -rf $(USER_PREFIX)/share/lsdict
	@echo "Uninstallation complete."

clean:
	@echo "Nothing to clean."
	@echo "Use uninstall targets to remove installed files."
