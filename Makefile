DOTFILES := $(shell pwd)
BREW     := $(shell command -v brew 2>/dev/null || if [ "$$(uname -m)" = arm64 ]; then echo /opt/homebrew/bin/brew; else echo /usr/local/bin/brew; fi)
CODE     := $(shell command -v code 2>/dev/null || echo "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code")

.DEFAULT_GOAL := help
.PHONY: help all brew links secrets node vscode macos work dump doctor
.NOTPARALLEL:

## show available commands
help:
	@awk '/^## / {desc = substr($$0, 4); next} /^[a-z]+:/ && desc {sub(/:.*/, ""); printf "  make %-8s %s\n", $$0, desc} {desc = ""}' $(MAKEFILE_LIST)

## install everything personal (all but work)
all: brew secrets links node vscode macos

## install Homebrew and packages from Brewfile
brew:
	@if [ ! -x "$(BREW)" ]; then \
		echo "==> Installing Homebrew"; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@echo "==> brew bundle"
	@$(BREW) bundle --file="$(DOTFILES)/Brewfile"

## symlink configs into $HOME (from *.link files)
links:
	@DOTFILES="$(DOTFILES)" bash scripts/symlinks.sh

## create ~/.secrets.zsh from template (if missing)
secrets:
	@if [ -f "$$HOME/.secrets.zsh" ]; then echo "ok      ~/.secrets.zsh exists"; \
	else install -m 600 secrets/secrets.example.zsh "$$HOME/.secrets.zsh"; \
		echo "created ~/.secrets.zsh — fill in the values"; fi

## install node via nvm and global npm packages
node:
	@export NVM_DIR="$$HOME/.nvm"; mkdir -p "$$NVM_DIR"; \
	. "$$($(BREW) --prefix nvm)/nvm.sh" && \
	nvm install $$(cat node/version) && nvm alias default $$(cat node/version) && \
	npm install -g $$(cat node/globals.txt)

## install VS Code extensions
vscode:
	@xargs -n1 "$(CODE)" --install-extension < vscode/extensions.txt

## set up work layer from work/: apps, configs, MCP servers
work:
	@[ -f work/Brewfile ] || { echo "work/Brewfile not found — restore the private work repo into $(DOTFILES)/work"; exit 1; }
	@$(BREW) bundle --file="$(DOTFILES)/work/Brewfile"
	@DOTFILES="$(DOTFILES)" bash scripts/symlinks.sh "$(DOTFILES)/work"
	@export NVM_DIR="$$HOME/.nvm"; \
	. "$$($(BREW) --prefix nvm)/nvm.sh" && \
	nvm use $$(cat node/version) && bash work/claude/mcp.sh

## apply macOS settings
macos:
	@bash macos/defaults.sh

## show what is installed but missing from Brewfile / extensions.txt
dump:
	@set -e; snapshot=$$(mktemp -t dotfiles-brew); \
	trap 'rm -f "$$snapshot"' EXIT; \
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) bundle dump --file="$$snapshot" --force; \
	grep -E '^(tap|brew|cask|mas) ' "$$snapshot" | grep -vxFf Brewfile || true
	@"$(CODE)" --list-extensions | grep -vxFf vscode/extensions.txt || true

## check migration readiness without changing system settings
doctor:
	@DOTFILES="$(DOTFILES)" bash scripts/doctor.sh
