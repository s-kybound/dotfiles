# makefile for managing stow-based dotfiles

STOW = stow
MODULE ?=

# list all subdirs (modules) for autocompletion etc.
MODULES = $(shell find . -mindepth 1 -maxdepth 1 -type d -not -name '.*' -exec basename {} \;)

# adding a new module (adopt)
.PHONY: preview-add
preview-add:
	@if [ -z "$(MODULE)" ]; then \
		echo "✖ Error: Please specify MODULE=<module>"; exit 1; \
	fi
	@echo ">>> Previewing adopt for $(MODULE)..."
	$(STOW) -nv --adopt $(MODULE)

.PHONY: add
add:
	@if [ -z "$(MODULE)" ]; then \
		echo "✖ Error: Please specify MODULE=<module>"; exit 1; \
	fi
	@echo ">>> Adopting $(MODULE)..."
	$(STOW) -v --adopt $(MODULE)

# refresh symlinks for a module
.PHONY: refresh
refresh:
	@if [ -z "$(MODULE)" ]; then \
		echo "✖ Error: Please specify MODULE=<module>"; exit 1; \
	fi
	@echo ">>> Refreshing symlinks for $(MODULE)..."
	$(STOW) -R $(MODULE)

# refresh symlinks for all modules
.PHONY: refreshall
refreshall:
	@echo ">>> Refreshing all modules..."
	@for module in $(MODULES); do \
		echo "→ Refreshing $$module..."; \
		$(STOW) -R $$module; \
	done

# show available modules
.PHONY: list-modules
list-modules:
	@echo "Available modules:"
	@echo $(MODULES) | tr ' ' '\n'

# help
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make preview-add MODULE=<module> # Preview adopt for a new module"
	@echo "  make add MODULE=<module>         # Adopt a new module"
	@echo "  make refresh MODULE=<module>     # Refresh symlinks for a module"
	@echo "  make refreshall                  # Refresh all modules"
	@echo "  make list-modules                # List all available modules"

