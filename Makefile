# Makefile for Latin & Greek Dictionary CLI

PREFIX ?= /usr/local
USER_PREFIX = $(HOME)/.local

.PHONY: all install uninstall user-install user-uninstall \
	install-latin install-greek install-all \
	install-morpheus  \
	user-install-latin user-install-greek user-install-all \
	user-install-morpheus \
	clone-morpheus build-morpheus \
	clean

all:
	@echo "Available targets:"
	@echo ""
	@echo "Installation targets:"
	@echo "  make install                  - Install Latin dictionary system-wide (requires sudo)"
	@echo "  make install-greek            - Install Greek dictionary system-wide (requires sudo)"
	@echo "  make install-all              - Install both dictionaries system-wide (requires sudo)"
	@echo "  make install-morpheus         - Install Latin dictionary with Morpheus support (requires sudo)"
	@echo "  make install-all-with-morpheus - Install both dictionaries with Morpheus (requires sudo)"
	@echo ""
	@echo "User installation targets:"
	@echo "  make user-install             - Install Latin dictionary for current user only"
	@echo "  make user-install-greek       - Install Greek dictionary for current user only"
	@echo "  make user-install-all         - Install both dictionaries for current user"
	@echo "  make user-install-morpheus    - Install Latin with Morpheus for current user"
	@echo "  make user-install-all-with-morpheus - Install both with Morpheus for current user"
	@echo ""
	@echo "Morpheus build targets:"
	@echo "  make clone-morpheus           - Clone Morpheus repository"
	@echo "  make build-morpheus           - Build Morpheus"
	@echo ""
	@echo "Uninstallation targets:"
	@echo "  make uninstall                - Uninstall system-wide installation"
	@echo "  make user-uninstall           - Uninstall user installation"
	@echo ""
	@echo "Or use the install.sh script for more options:"
	@echo "  ./install.sh --help"

install: install-latin

install-latin:
	./install.sh --force --latin

install-greek:
	./install.sh --force --greek

install-all:
	./install.sh --force --all --morpheus

install-morpheus:
	./install.sh --force --latin --morpheus

user-install: user-install-latin

user-install-latin:
	./install.sh --user --force --latin

user-install-greek:
	./install.sh --user --force --greek

user-install-all:
	./install.sh --user --force --all --morpheus

user-install-morpheus:
	./install.sh --user --force --latin --morpheus

clone-morpheus:
	@if [ ! -d "morpheus" ]; then \
		echo "Cloning Morpheus repository..."; \
		git clone https://github.com/perseids-tools/morpheus.git; \
	else \
		echo "Morpheus repository already exists."; \
	fi

build-morpheus: clone-morpheus
	@echo "Building Morpheus..."
	@cd morpheus/src && make clean && CFLAGS='-std=gnu89 -fcommon' make
	@echo "Morpheus build complete."

uninstall:
	@echo "Removing system-wide installation..."
	@sudo rm -f $(PREFIX)/bin/lsdict
	@sudo rm -f $(PREFIX)/bin/classdict
	@sudo rm -f $(PREFIX)/bin/morpheus
	@sudo rm -rf $(PREFIX)/share/lsdict
	@sudo rm -rf $(PREFIX)/share/classdict
	@sudo rm -rf $(PREFIX)/share/morpheus
	@echo "Uninstallation complete."

user-uninstall:
	@echo "Removing user installation..."
	@rm -f $(USER_PREFIX)/bin/lsdict
	@rm -f $(USER_PREFIX)/bin/classdict
	@rm -f $(USER_PREFIX)/bin/morpheus
	@rm -rf $(USER_PREFIX)/share/lsdict
	@rm -rf $(USER_PREFIX)/share/classdict
	@rm -rf $(USER_PREFIX)/share/morpheus
	@echo "Uninstallation complete."

clean:
	@echo "Nothing to clean."
	@echo "Use uninstall targets to remove installed files."
