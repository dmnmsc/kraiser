PREFIX_DIR := $(HOME)/.local/bin
TARGET := $(PREFIX_DIR)/kraiser

.DEFAULT_GOAL := help

.PHONY: help install update uninstall

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  help       Show this help message (default)"
	@echo "  install    Install kraiser to $(TARGET)"
	@echo "  update     Pull the latest changes from git and reinstall"
	@echo "  uninstall  Remove $(TARGET)"

install:
	@mkdir -p "$(PREFIX_DIR)"
	@install -m 755 kraiser.sh "$(TARGET)"
	@echo "Installed kraiser to $(TARGET)"
	@case ":$$PATH:" in \
		*":$(PREFIX_DIR):"*) ;; \
		*) echo "WARNING: $(PREFIX_DIR) is not in your PATH."; \
		   echo "Add this to your ~/.bashrc or ~/.zshrc:"; \
		   echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\"" ;; \
	esac

update:
	@git pull
	@$(MAKE) install

uninstall:
	@rm -f "$(TARGET)"
	@echo "Removed $(TARGET)"
