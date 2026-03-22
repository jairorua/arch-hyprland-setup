#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AUR_HELPER="yay"
AUR_DIR="$HOME/.cache/yay"

# Package Lists
# Core system utilities
CORE_SYSTEM="
base-devel
openssh
rsync
wget
curl
unzip
p7zip
reflector
pacman-contrib
udisks2
gvfs
xdg-user-dirs
pciutils  
tree
"

# Hyprland ecosystem
HYPRLAND="
hyprland
hyprpaper
hyprlock
hypridle
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
qt5-wayland
qt6-wayland
qt5ct
qt6ct
nwg-look
"

# Audio, Bluetooth, Network
MULTIMEDIA="
pipewire
pipewire-pulse
pipewire-jack
pipewire-alsa
wireplumber
pamixer
bluez
bluez-utils
blueman
network-manager-applet
"

# Terminal & CLI tools (your requested list + enhancements)
CLI_TOOLS="
ripgrep
bat
fd
fzf
tldr
btop
tmux
wl-clipboard
cliphist
zoxide
eza
yazi
starship
zsh
neovim
"

# Development (your requested list)
DEVELOPMENT="
go
sqlite
python
python-pip
python-pynvim
nodejs
npm
pnpm
typescript
lua
meson
ninja
cmake
gcc
gdb
"

# GUI Applications (your requested list + essentials)
GUI_APPS="
thunar
thunar-archive-plugin
tumbler
ffmpegthumbnailer
imv
zathura
zathura-pdf-mupdf
pavucontrol
obs-studio
ghostty
obsidian
"

# Hyprland specific GUI tools
HYPRLAND_GUI="
waybar
rofi-wayland
dunst
polkit-gnome
grim
slurp
hyprpicker
sddm
swaync
"

# Fonts
FONTS="
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
ttf-jetbrains-mono
ttf-jetbrains-mono-nerd
ttf-liberation
ttf-dejavu
ttf-font-awesome
papirus-icon-theme
"

# AUR Packages (these require yay)
AUR_PACKAGES="
brave-bin
nvm
grimblast
hyprshot
wlogout
"

# Helper functions
print_section() {
    echo -e "\n${BLUE}==>${NC} ${YELLOW}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_arch() {
    if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
        print_error "This script is designed for Arch Linux"
        exit 1
    fi
}

install_yay() {
    if command -v yay &> /dev/null; then
        print_success "yay is already installed"
        return 0
    fi

    print_section "Installing yay (AUR Helper)"
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm base-devel
    
    # Clone and install yay
    if [ -d "$AUR_DIR" ]; then
        rm -rf "$AUR_DIR"
    fi
    
    git clone https://aur.archlinux.org/yay.git "$AUR_DIR"
    cd "$AUR_DIR"
    makepkg -si --noconfirm
    
    print_success "yay installed successfully"
}

detect_nvidia() {
    if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
        return 0
    else
        return 1
    fi
}

prompt_nvidia() {
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  NVIDIA GPU DETECTED                                   ║${NC}"
    echo -e "${YELLOW}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  Hyprland on NVIDIA requires proprietary drivers.      ║${NC}"
    echo -e "${YELLOW}║  This will install: nvidia-dkms, nvidia-utils          ║${NC}"
    echo -e "${YELLOW}║                                                          ║${NC}"
    echo -e "${YELLOW}║  Note: You'll need to add a kernel parameter after:      ║${NC}"
    echo -e "${YELLOW}║  nvidia-drm.modeset=1                                    ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Install NVIDIA proprietary drivers? [y/N]: " response
    [[ "$response" =~ ^[Yy]$ ]]
}

install_nvidia_drivers() {
    print_section "Installing NVIDIA Proprietary Drivers"
    
    sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils nvidia-settings
    
    print_success "NVIDIA drivers installed"
    
    # Important warning about kernel parameter
    echo ""
    echo -e "${RED}⚠ IMPORTANT - Manual Step Required:${NC}"
    echo "Add 'nvidia-drm.modeset=1' to your kernel parameters"
    echo ""
    echo -e "${YELLOW}For GRUB:${NC}"
    echo "  sudo nano /etc/default/grub"
    echo "  # Add to GRUB_CMDLINE_LINUX_DEFAULT: nvidia-drm.modeset=1"
    echo "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo ""
    echo -e "${YELLOW}For systemd-boot:${NC}"
    echo "  sudo nano /boot/loader/entries/arch.conf"
    echo "  # Add to options: nvidia-drm.modeset=1"
    echo ""
    read -p "Press Enter to continue..."
}

setup_keyboard() {
    print_section "Configuring Keyboard (Caps → Ctrl)"

    # Set layout + caps remap system-wide
    sudo localectl set-x11-keymap es "" "" ctrl:nocaps

    print_success "Caps Lock remapped to Ctrl (system-wide)"
}

install_pacman_packages() {
    print_section "Installing Official Repository Packages"
    
    # Update system first
    sudo pacman -Syu --noconfirm
    
    # Combine all pacman packages
    ALL_PACKAGES="$CORE_SYSTEM $HYPRLAND $MULTIMEDIA $CLI_TOOLS $DEVELOPMENT $GUI_APPS $HYPRLAND_GUI $FONTS"
    
    # Install packages
    sudo pacman -S --needed --noconfirm $ALL_PACKAGES
    
    print_success "Pacman packages installed"
}

install_aur_packages() {
    print_section "Installing AUR Packages"
    
    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        print_error "yay is not installed. Cannot install AUR packages."
        return 1
    fi
    
    # Install AUR packages
    yay -S --needed --noconfirm $AUR_PACKAGES
    
    print_success "AUR packages installed"
}

post_install() {
    print_section "Running Post-Installation Setup"
    
    # Enable services
    print_section "Enabling System Services"
    sudo systemctl enable --now bluetooth
    sudo systemctl enable --now NetworkManager

    # Keyboard setup
    setup_keyboard
    
    # Add user to necessary groups (if not already)
    print_section "Configuring User Groups"
    sudo usermod -aG video,audio,lp,input,network,storage "$USER"
    
    # Install global npm packages (optional)
    if command -v npm &> /dev/null; then
        print_section "Installing global npm packages"
        sudo npm install -g neovim tree-sitter-cli
    fi
    
    # Set up zsh as default (optional)
    if command -v zsh &> /dev/null; then
        print_section "Setting up Zsh"
        chsh -s "$(which zsh)" || true
    fi
    
    # Create default directories
    xdg-user-dirs-update || true
    
    print_success "Post-installation complete"
}

verify_installation() {
    print_section "Verifying Key Installations"
    
    for cmd in hyprland waybar rofi dunst neovim tmux ghostty brave go node obsidian; do
        if command -v "$cmd" &> /dev/null; then
            echo -e "${GREEN}✓${NC} $cmd"
        else
            echo -e "${RED}✗${NC} $cmd"
        fi
    done
}

run_dotfiles_setup() {
    print_section "User Configuration"
    
    local script_dir="$(dirname "$(realpath "$0")")"
    local dotfiles_script="$script_dir/install_dotfiles.sh"
    
    if [ -f "$dotfiles_script" ]; then
        # Ensure we run as the actual user, not root (even if sudo was used for install.sh)
        if [ -n "$SUDO_USER" ]; then
            su -c "bash '$dotfiles_script'" "$SUDO_USER"
        else
            bash "$dotfiles_script"
        fi
    else
        print_error "install_dotfiles.sh not found"
    fi
}

main() {
    echo -e "${GREEN}Arch Linux + Hyprland Installation Script${NC}"
    echo -e "${YELLOW}This will install all required packages${NC}\n"
    
    check_arch
    
    # Check if running as root (should not be)
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root. It will use sudo when needed."
        exit 1
    fi

    # Check if user has sudo privileges
    if ! sudo -v &> /dev/null; then
        print_error "This script requires sudo privileges"
        exit 1
    fi

    # Detect NVIDIA and prompt
    NVIDIA_INSTALL=false
    if detect_nvidia; then
        if prompt_nvidia; then
            NVIDIA_INSTALL=true
        else
            print_section "Skipping NVIDIA drivers"
            echo -e "${YELLOW}Warning: Hyprland may not work correctly without proprietary NVIDIA drivers${NC}"
            sleep 2
        fi
    fi
    
    # Install yay first
    install_yay
    
    # Install packages
    install_pacman_packages

    # Install NVIDIA if selected
    if [ "$NVIDIA_INSTALL" = true ]; then
        install_nvidia_drivers
    fi

    # Continue with AUR packages
    install_aur_packages
    
    # Post installation
    post_install
    
    # Verify
    verify_installation
    
    print_success "Installation complete! Please reboot to ensure all services start correctly."

    if [ "$NVIDIA_INSTALL" = true ]; then
        echo ""
        echo -e "${RED}REMINDER:${NC} You must reboot and ensure 'nvidia-drm.modeset=1' kernel parameter is set"
    else
        echo -e "\n${YELLOW}Please reboot to ensure all services start correctly.${NC}"
    fi

    echo -e "\n${YELLOW}Post-install tips:${NC}"
    echo "1. Copy your Hyprland config from your other laptop"
    echo "2. Run 'nvm install node' to set up Node.js versions"
    echo "3. Install your Neovim plugins with ':Lazy sync' (if using lazy.nvim)"
    echo "4. Configure starship: 'starship preset pure-preset -o ~/.config/starship.toml'"

    echo -e "${GREEN}Running Dotfiles Installation${NC}"
    run_dotfiles_setup
    print_success "Dotfiles Installation complete!"
}

# Run main function
main "$@"
