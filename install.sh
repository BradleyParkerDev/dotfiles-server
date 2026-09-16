#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo " Ubuntu Server Bootstrap"
echo "======================================"
echo "Dotfiles: $DOTFILES"
echo ""

# ------------------------------------------------------
# Verify Ubuntu / Debian
# ------------------------------------------------------

if ! command -v apt >/dev/null 2>&1; then
    echo "ERROR: This installer requires Ubuntu/Debian."
    exit 1
fi

# ------------------------------------------------------
# Validate repository structure
# ------------------------------------------------------

if [[ ! -f "$DOTFILES/.zshrc" ]]; then
    echo "ERROR: $DOTFILES/.zshrc not found."
    exit 1
fi

if [[ ! -f "$DOTFILES/.config/mise/config.toml" ]]; then
    echo "ERROR: $DOTFILES/.config/mise/config.toml not found."
    exit 1
fi

# ------------------------------------------------------
# System packages
# ------------------------------------------------------

echo "Updating system packages..."

sudo apt update
sudo apt upgrade -y

echo "Installing server dependencies..."

sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    software-properties-common \
    zsh \
    nginx \
    certbot \
    python3-certbot-nginx \
    openssl \
    sqlite3 \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libgd-dev \
    libgmp-dev \
    libsodium-dev \
    pkg-config \
    autoconf \
    bison \
    re2c

# ------------------------------------------------------
# Server directories
# ------------------------------------------------------

echo "Creating server directories..."

sudo mkdir -p /var/www/apps
sudo chown -R "$USER":"$USER" /var/www/apps

mkdir -p "$HOME/.config/mise"

# ------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."

    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed."
fi

# ------------------------------------------------------
# Symlink configuration
# ------------------------------------------------------

echo "Linking .zshrc..."

ln -sfn \
    "$DOTFILES/.zshrc" \
    "$HOME/.zshrc"

echo "Linking mise config..."

ln -sfn \
    "$DOTFILES/.config/mise/config.toml" \
    "$HOME/.config/mise/config.toml"

# ------------------------------------------------------
# mise
# ------------------------------------------------------

if [[ ! -x "$HOME/.local/bin/mise" ]] && ! command -v mise >/dev/null 2>&1; then
    echo "Installing mise..."

    curl -fsSL https://mise.run | sh
else
    echo "mise already installed."
fi

export PATH="$HOME/.local/bin:$PATH"

eval "$(mise activate bash)"

echo "Trusting mise configuration..."

mise trust "$DOTFILES/.config/mise/config.toml" || true
mise trust "$HOME/.config/mise/config.toml" || true

echo "Installing mise runtimes..."

if ! mise install; then
    echo ""
    echo "WARNING: One or more mise runtimes failed to install."
    echo "Continuing with the rest of the bootstrap."
    echo ""
fi

mise reshim || true

# ------------------------------------------------------
# PM2
# ------------------------------------------------------

if command -v npm >/dev/null 2>&1; then
    if ! command -v pm2 >/dev/null 2>&1; then
        echo "Installing PM2..."
        npm install -g pm2
    else
        echo "PM2 already installed."
    fi
else
    echo "WARNING: npm is unavailable. Skipping PM2 installation."
fi

# ------------------------------------------------------
# Vite+
# ------------------------------------------------------

if [[ ! -f "$HOME/.vite-plus/env" ]]; then
    echo "Installing Vite+..."

    curl -fsSL https://vite.plus | bash
else
    echo "Vite+ already installed."
fi

if [[ -f "$HOME/.vite-plus/env" ]]; then
    # shellcheck disable=SC1090
    source "$HOME/.vite-plus/env"
fi

if command -v vp >/dev/null 2>&1; then
    echo "Configuring Vite+ to use the mise-managed Node.js runtime..."
    vp env off || true
fi

# ------------------------------------------------------
# Nginx
# ------------------------------------------------------

echo "Enabling Nginx..."

sudo systemctl enable --now nginx

# ------------------------------------------------------
# Change default shell
# ------------------------------------------------------

ZSH_PATH="$(command -v zsh)"

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    echo "Changing login shell to Zsh..."
    chsh -s "$ZSH_PATH"
else
    echo "Zsh is already the default shell."
fi

# ------------------------------------------------------
# Complete
# ------------------------------------------------------

echo ""
echo "======================================"
echo " Server bootstrap complete"
echo "======================================"
echo ""
echo "Dotfiles:"
echo "  $DOTFILES"
echo ""
echo "Applications:"
echo "  /var/www/apps"
echo ""
echo "Run:"
echo ""
echo "  exec zsh"
echo ""
echo "Then verify:"
echo ""
echo "  mise doctor"
echo "  mise list"
echo "  nginx -v"
echo "  certbot --version"
echo "  zsh --version"
echo "  pm2 --version"
echo "  vp --version"
echo ""