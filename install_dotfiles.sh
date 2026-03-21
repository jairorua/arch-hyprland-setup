#!/bin/bash

set -e

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_section() { echo -e "\n${BLUE}==>${NC} ${YELLOW}$1${NC}"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:yourusername/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"

check_prerequisites() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Do not run as root. Run as your user."
        exit 1
    fi
    if ! command -v git &> /dev/null; then
        print_error "git required"
        exit 1
    fi
}

backup_conflicts() {
    # Find files that would be overwritten
    local git_cmd="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"
    local conflicts=$($git_cmd checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' || true)
    
    if [ -n "$conflicts" ]; then
        print_section "Backing up existing configs"
        echo "$conflicts" | while read -r file; do
            if [ -e "$HOME/$file" ]; then
                mv "$HOME/$file" "$HOME/$file.backup.$(date +%s)"
                print_success "Backed up $file"
            fi
        done
    fi
}

setup_dotfiles() {
    print_section "Cloning dotfiles"
    
    if [ -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles already exist at $DOTFILES_DIR"
        read -p "Update to latest? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            (cd "$DOTFILES_DIR" && git fetch origin && git reset --hard origin/main)
        fi
        return
    fi
    
    # Try SSH first, fallback to HTTPS
    if ! git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR" 2>/dev/null; then
        print_error "SSH clone failed. Trying HTTPS..."
        HTTPS_REPO=$(echo "$DOTFILES_REPO" | sed 's|git@github.com:|https://github.com/|')
        git clone --bare "$HTTPS_REPO" "$DOTFILES_DIR"
    fi
    
    print_success "Repository cloned"
}

configure_dotfiles() {
    print_section "Configuring dotfiles environment"
    
    # Create helper function in current shell
    git_dot() { /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }
    
    # Checkout files
    git_dot checkout
    git_dot config --local status.showUntrackedFiles no
    git_dot config --local core.sparseCheckout false
    
    print_success "Dotfiles active"
}

setup_shell_alias() {
    local alias_def="alias dotfilesconfig='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'"
    local shell_rc=""
    
    if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi
    
    if [ -f "$shell_rc" ] && ! grep -q "dotfilesconfig" "$shell_rc"; then
        echo "$alias_def" >> "$shell_rc"
        print_success "Added alias to $shell_rc"
    fi
}

install_plugins() {
    print_section "Installing plugins"
    
    # TPM (Tmux)
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        print_success "TPM installed (open tmux, press prefix+I)"
    fi
    
    # Neovim (headless sync)
    if command -v nvim &> /dev/null; then
        print_info "Syncing Neovim plugins..."
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || print_error "Neovim sync failed (will retry on first launch)"
    fi
}

main() {
    echo -e "${GREEN}Dotfiles Setup${NC}\n"
    check_prerequisites
    setup_dotfiles
    backup_conflicts  # Run after clone so git knows what might conflict
    configure_dotfiles
    setup_shell_alias
    install_plugins
    
    echo -e "\n${GREEN}Complete!${NC} Reload shell: source ~/.zshrc"
}

main "$@"
