#!/bin/bash

# Exit on error
set -e

echo "Starting post-installation setup..."

# Change default shell to fish
if [ "$SHELL" != "/usr/bin/fish" ]; then
    echo "Changing default shell to fish..."
    if ! grep -q "/usr/bin/fish" /etc/shells; then
        echo "/usr/bin/fish" | sudo tee -a /etc/shells
    fi
    chsh -s /usr/bin/fish
    echo "Default shell changed to fish. Will take effect after reboot."
fi

# Enable Bluetooth service
echo "Enabling Bluetooth service..."
sudo systemctl enable --now bluetooth.service

# Enable TRIM timer for SSDs
echo "Enabling TRIM timer for SSDs..."
sudo systemctl enable fstrim.timer

# Install Hyprland split-monitor-workspaces plugin
echo "Installing Hyprland split-monitor-workspaces plugin..."
if ! hyprpm update; then
    echo "Error updating hyprpm"
    exit 1
fi

if ! hyprpm add https://github.com/Duckonaut/split-monitor-workspaces; then
    echo "Error adding split-monitor-workspaces plugin"
    exit 1
fi

if ! hyprpm enable split-monitor-workspacesplugin; then
    echo "Error enabling split-monitor-workspaces plugin"
    exit 1
fi

if ! hyprpm reload; then
    echo "Error reloading hyprpm"
    exit 1
fi

if ! hyprpm update; then
    echo "Error performing final hyprpm update"
    exit 1
fi

echo "All post-installation tasks completed successfully!"
echo "System will reboot in 10 seconds. Press Ctrl+C to cancel."
sleep 10
sudo reboot