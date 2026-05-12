CHEZMOI_SOURCE := $(shell chezmoi source-path 2>/dev/null || echo ~/.local/share/chezmoi)

.PHONY: all bootstrap brew macos chezmoi update

# Full fresh-machine setup
bootstrap: brew-bootstrap brew macos chezmoi

# Install chezmoi + ansible (the only two bootstrap deps)
brew-bootstrap:
	command -v brew || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install chezmoi ansible

# Install / sync all packages from Brewfile
brew:
	brew bundle install --file=$(CHEZMOI_SOURCE)/Brewfile

# Apply macOS system defaults
macos:
	ansible-galaxy collection install community.general --upgrade -q
	ansible-playbook $(CHEZMOI_SOURCE)/ansible/macos.yml

# Apply dotfiles
chezmoi:
	chezmoi apply

# Pull latest and re-apply everything
update:
	chezmoi update
	$(MAKE) brew macos
