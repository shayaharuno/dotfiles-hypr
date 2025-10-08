#!/bin/bash

# Exit on error
set -e

echo "Starting Hyprland dotfiles installation..."

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "Error: This script is intended for Arch Linux only"
    exit 1
fi

# Function to install packages if not already installed
install_package() {
    if ! pacman -Qi "$1" >/dev/null 2>&1; then
        echo "Installing $1..."
        # Try installing with pacman first
        if sudo pacman -S --noconfirm "$1" 2>/dev/null; then
            echo "Installed $1 from official repositories"
        else
            # If pacman fails, try with yay
            echo "Package not found in official repositories, trying AUR..."
            yay -S --noconfirm "$1"
        fi
    fi
}

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    
    echo "Initializing yay..."
    yay -Y --gendb  # Generate local database
    yay             # Perform first sync
fi

# Required packages
PACKAGES=(
    "hyprland"
    "waybar"
    "tofi"
    "alacritty"
    "mako"
    "hyprshot"
    "hyprpicker"
    "swww"
    "wl-clipboard"
    "polkit-gnome"
    "pipewire"
    "wireplumber"
    "xdg-desktop-portal-hyprland"
    "librewolf-bin"
    "reflector"
    "fastfetch"
    "kcalc"
    "kate"
    "ark"
    "dolphin"
    "fish"
    "godot"
    "blender"
    "krita"
    "spotify"
    "telegram-desktop"
    "discord"
    "obs-studio"
    "steam"
    "qbittorrent"
    "ttf-jetbrains-mono-nerd"
    "ttf-mplus-nerd"
    "ttf-noto-emoji-monochrome"
    "ttf-sarasa-gothic"
)

# Install packages
echo "Installing required packages..."
for package in "${PACKAGES[@]}"; do
    install_package "$package"
done

# Create necessary directories
echo "Creating configuration directories..."
mkdir -p ~/.config

# Backup existing configurations
BACKUP_DIR="$HOME/.config/backup-$(date +%Y%m%d-%H%M%S)"
echo "Creating backup of existing configurations in $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# List of configs to manage
CONFIGS=(
    "hypr"
    "waybar"
    "tofi"
    "alacritty"
    "mako"
    "btop"
    "nwg-look"
    "qt5ct"
    "qt6ct"
    "fish"
    "godot"
    "fastfetch"
)

# Backup and copy configurations
for config in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$config" ]; then
        mv "$HOME/.config/$config" "$BACKUP_DIR/$config"
    fi
    if [ -d "$PWD/.config/$config" ]; then
        echo "Installing $config configuration..."
        cp -r "$PWD/.config/$config" "$HOME/.config/"
    fi
done

# Set up systemd services
systemctl --user enable --now wireplumber.service
systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service

echo "Installation complete!"
echo "Please log out and log back in to start Hyprland."
echo "Backup of old configurations can be found in: $BACKUP_DIR"