#!/usr/bin/env bash
# am-lite: Automated installer script for systems engineering best practices.
set -euo pipefail

REPO="jerrygoodboi/am-lite"
RAW_URL="https://raw.githubusercontent.com/$REPO/main"

# Determine install directories based on privileges
if [ "$EUID" -eq 0 ]; then
	BIN_DIR="/usr/local/bin"
	MAN_DIR="/usr/local/share/man/man1"
	BASH_COMP="/usr/share/bash-completion/completions"
	ZSH_COMP="/usr/share/zsh/site-functions"
	CONF_DIR="/etc"
else
	BIN_DIR="$HOME/.local/bin"
	MAN_DIR="$HOME/.local/share/man/man1"
	BASH_COMP="$HOME/.local/share/bash-completion/completions"
	ZSH_COMP="$HOME/.local/share/zsh/site-functions"
	CONF_DIR="$HOME/.config/am-lite"
fi

echo "Installing am-lite to $BIN_DIR..."

mkdir -p "$BIN_DIR" "$MAN_DIR" "$BASH_COMP" "$ZSH_COMP" "$CONF_DIR"

# Download files
curl -fsSL "$RAW_URL/am-lite" -o "$BIN_DIR/am-lite"
chmod +x "$BIN_DIR/am-lite"

curl -fsSL "$RAW_URL/am-lite.1" -o "$MAN_DIR/am-lite.1" || true

# Autocompletions
curl -fsSL "$RAW_URL/completions/am-lite.bash" -o "$BASH_COMP/am-lite" || true
curl -fsSL "$RAW_URL/completions/am-lite.zsh" -o "$ZSH_COMP/_am-lite" || true

# Config template
if [ ! -f "$CONF_DIR/am-lite.conf" ] && [ ! -f "$CONF_DIR/config" ]; then
	if [ "$EUID" -eq 0 ]; then
		curl -fsSL "$RAW_URL/am-lite.conf.example" -o "$CONF_DIR/am-lite.conf" || true
	else
		curl -fsSL "$RAW_URL/am-lite.conf.example" -o "$CONF_DIR/config" || true
	fi
fi

echo "am-lite installed successfully!"
if [ "$EUID" -ne 0 ]; then
	case :$PATH: in
		*:"$BIN_DIR":*) ;;
		*)
			echo "WARNING: $BIN_DIR is not in your PATH."
			echo "Add this to your shell profile (.bashrc or .zshrc):"
			echo "  export PATH=\"\$PATH:$BIN_DIR\""
			;;
	esac
fi
