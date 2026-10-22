SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.PHONY: up up-agents home zhaw hexagon darwin nix-conf

# Update flake
up:
	nix flake update 2>&1 | nom
# Bump only the agent packages, between the weekly update pull requests
up-agents:
	nix flake update llm-agents 2>&1 | nom
home:
	nix run nixpkgs#home-manager -- switch --flake .#manuel 2>&1 | nom
zhaw:
	nix run nixpkgs#home-manager -- switch --flake .#zhaw 2>&1 | nom
hexagon:
	nix run nixpkgs#home-manager -- switch --impure --flake .#hexagon 2>&1 | nom
darwin:
	nix run nixpkgs#home-manager -- switch --flake .#manuel-darwin 2>&1 | nom

# Install the binary caches into /etc/nix/nix.custom.conf, where they are
# root-owned and therefore trusted by the daemon. Needed because this user is
# not in trusted-users, so the substituters in ~/.config/nix/nix.conf are
# ignored. Restarts the daemon so it rereads the config.
nix-conf:
	conf="$$(nix build --no-link --print-out-paths .#nixCustomConf)"; \
	if cmp -s "$$conf" /etc/nix/nix.custom.conf; then \
		echo "/etc/nix/nix.custom.conf already up to date"; \
	else \
		diff -u /etc/nix/nix.custom.conf "$$conf" || true; \
		sudo install -m 0644 "$$conf" /etc/nix/nix.custom.conf; \
		if [ "$$(uname)" = Darwin ]; then \
			sudo launchctl kickstart -k system/systems.determinate.nix-daemon; \
		else \
			sudo systemctl restart nix-daemon.service; \
		fi; \
	fi
