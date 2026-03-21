# Arch Linux + Hyprland Automated Setup

Minimal, opinionated automated installer for Arch Linux with Hyprland window manager, development tools, and modern CLI utilities.

## Prerequisites

- Fresh Arch Linux installation (or Arch-based distro)
- User account with sudo privileges
- Internet connection
- `git` (to clone this repository)

**Base Arch Install Summary:**

```bash
# During base install, you only need:
pacman -S base base-devel linux linux-firmware git sudo vim
# Then create user, add to wheel group, enable sudo, clone this repo

Installation

# Clone anywhere (e.g., /tmp or your home dir)

git clone https://github.com/YOUR_USERNAME/arch-hyprland-setup.git
cd arch-hyprland-setup

# Run main installer

./install.sh

Note: Do not run with sudo ./install.sh. The script will prompt for elevation internally.

What Gets Installed
System & Desktop
Window Manager: Hyprland (Wayland-based tiling WM)
Bar/Widgets: Waybar, Rofi, Dunst (notifications)
Login Manager: SDDM (if added) or manual start with Hyprland
Themes: Qt5ct/Qt6ct, nwg-look (theme matching)
Audio & Peripherals
Pipewire (modern audio server) + Wireplumber
Bluetooth: Bluez + Blueman applet
Network: NetworkManager + applet
Policies: Polkit (GUI auth dialogs)
Terminal & Development
Shell: Zsh + Starship prompt
Editors: Neovim, Ghostty (terminal)
Languages: Go, Node.js (via nvm), Python, TypeScript, Lua, C/C++
Tools: tmux, fzf, ripgrep, fd, bat, btop, yazi (file manager)
Applications
Browser: Brave
Files: Thunar with archive support
Media: OBS Studio, mpv (via imv), Zathura (PDF)
Gaming: Hyprland gaming utils (grimblast, hyprshot for screenshots)
Dotfiles
The script automatically calls install_dotfiles.sh at the end to set up your bare repository configuration.

Post-Installation
Reboot (required for services to start):

reboot

Login: Select Hyprland from SDDM (or run Hyprland from TTY if no display manager)

Complete dotfiles setup:

# Your dotfiles should already be cloned via install_dotfiles.sh

# If not, run:

bash ~/arch-hyprland-setup/install_dotfiles.sh

Set up Node.js versions:

nvm install node

Configure Neovim (if using Lazy.nvim):

nvim

# Then :Lazy sync

Configure Starship (optional):

starship preset pure-preset -o ~/.config/starship.toml

Troubleshooting
"command not found: yay"
The script installs yay automatically. If it fails:

rm -rf ~/.cache/yay
./install.sh # Re-run

Hyprland won't start (NVIDIA users)
NVIDIA requires proprietary drivers. This script installs hyprland-nvidia if available in repos, but you may need:

sudo pacman -S nvidia-dkms nvidia-utils

# Then rebuild initramfs

sudo mkinitcpio -P

Permission Denied (on scripts)
chmod +x install.sh install_dotfiles.sh

Dotfiles SSH Issues
If you get SSH authentication errors, ensure your SSH agent has your key:

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

Architecture
Modular: Each phase (base, aur, post-install) is self-contained
Idempotent: Safe to run multiple times (skips already-installed packages)
Non-root: Script elevates privileges only when needed via sudo
License
MIT - Use freely, modify for your needs.

```

```

```
